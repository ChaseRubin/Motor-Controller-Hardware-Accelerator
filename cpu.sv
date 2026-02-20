`timescale 1ns/1ps

module cpu (
    input clk,
    input reset,
    output reg halt
);

//control signals
reg reg_write;
reg [3:0] alu_op;

wire [31:0] pc_val;
wire [31:0] pc_next;
wire [31:0] instr;


wire [31:0] rd1, rd2;
wire [31:0] alu_out;

reg [1:0] pc_sel;

wire [31:0] jalr_target = {alu_out[31:1], 1'b0};
wire [31:0] jal_target = pc_val + imm_j;
wire [31:0] imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};


//decode wires
wire [6:0] opcode = instr[6:0];
wire [2:0] funct3 = instr[14:12];
wire [6:0] funct7 = instr[31:25];
wire [4:0] rs1 = instr[19:15];
wire [4:0] rs2 = instr[24:20];
wire [4:0] rd  = instr[11:7];

wire [31:0] alu_input_b;

//memory controls 
reg mem_read;
reg [1:0] mem_to_reg;
wire [31:0] mem_data;
wire [31:0] address;
assign address = alu_out;
wire [7:0] selected_byte;
wire [15:0] selected_half;
wire [31:0] reg_to_mem;
wire [3:0] mem_byte_en;
wire [31:0] mem_write_data;

// Generate  4 bit mask based on address and instruction typ
assign mem_byte_en = (opcode == 7'b0100011 && funct3 == 3'b000) ? 
                     (4'b0001 << address[1:0]) : 4'b0000;

assign mem_write_data = rs2 << (8 * address[1:0]);

assign selected_byte =
    (address[1:0] == 2'b00) ? mem_data[7:0]   :
    (address[1:0] == 2'b01) ? mem_data[15:8]  :
    (address[1:0] == 2'b10) ? mem_data[23:16] :
                              mem_data[31:24];

assign selected_half = 
    (address[1] == 1'b0) ? mem_data[15:0] : // Lower half (Addresses ending in 00 or 01)
                           mem_data[31:16]; // Upper half (Addresses ending in 10 or 11)

//types of loads
wire [31:0] lb_data = {{24{selected_byte[7]}}, selected_byte}; //byte
wire [31:0] lh_data = {{16{selected_half[15]}}, selected_half}; //half word
wire [31:0] w_data = mem_data; 
wire [31:0] lbu_data = {24'b0, selected_byte}; //load byte unsigned
wire [31:0] lhu_data = {16'b0, selected_half}; //loads half unsigned

wire [31:0] write_data;
logic [31:0] load_data;

//logic to chose alu_out data or the usual alu_output to send to register

// Continuous assignments (outside the always block)
assign load_data = (funct3 == 3'b000) ? lb_data : 
                   (funct3 == 3'b001) ? lh_data : 
                   (funct3 == 3'b010) ? w_data :
                   (funct3 == 3'b100) ? lbu_data:
                   (funct3 == 3'b101) ? lhu_data:
                                        mem_data;

// 00: ALU, 01: Memory, 10: PC+4
assign write_data = (mem_to_reg == 2'b00) ? alu_out :
                    (mem_to_reg == 2'b01) ? load_data :
                    (mem_to_reg == 2'b10) ? (pc_val + 4) :
                                            alu_out;

//decode for I-type and B-type
wire [31:0] imm_ext = {{20{instr[31]}}, instr[31:20]}; //concadonates the signed bit to fit the 32 bit alu
wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};


reg alu_src;

assign pc_next = (pc_sel == 2'b01) ? jal_target : //JAR
                 (pc_sel == 2'b10) ? jalr_target : //JARL
                                     pc_val + 4; //normal pc increment


assign alu_input_b = (opcode == 7'b0100011) ? imm_s : 
                     (alu_src) ? imm_ext : rd2;


pc PC (
    .clk(clk),
    .reset(reset),
    .pc_next(pc_next),
    .pc_out(pc_val)
);

imem IMEM (
    .pc(pc_val),
    .instr(instr)
);

regfile RF (
    .clk(clk),
    .w_en(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wd(write_data),
    .rd1(rd1),
    .rd2(rd2)
);

alu ALU (
    .a(rd1),
    .b(alu_input_b),
    .op(alu_op),
    .alu_out(alu_out)
);

dmem memory(
    .clk(clk),
    .address(address),
    .mem_read(mem_read),
    .data(mem_data),
    .byte_en(mem_byte_en),
    .write_data(mem_write_data)
);

always @(*) begin
    //default control signals
    reg_write = 1'b0;
    alu_op    = 4'b0000;
    alu_src = 1'b0;
    mem_read  = 0;
    mem_to_reg = 0;

    pc_sel     = 2'b00; //pc selected to normal
    halt = 0;


    case (opcode)

        // R-type instructions
        7'b0110011: begin
            reg_write = 1'b1;

            case ({funct7, funct3})
                10'b0000000000: alu_op = 4'b0000; //ADD
                10'b0100000000: alu_op = 4'b0001; //SUB
                10'b0000000001: alu_op = 4'b0010; //SLL (shift left logical)
                10'b0000000010: alu_op = 4'b0011; //SLT (set less than)
                10'b0000000011: alu_op = 4'b0100; //STLU (set less than unsigned)
                10'b0000000100: alu_op = 4'b0101; //XOR
                10'b0000000101: alu_op = 4'b0110; //SLR (shift right)
                10'b0100000101: alu_op = 4'b0111; //SRA (shift right arithmatic)
                10'b0000000110: alu_op = 4'b1000; //OR
                10'b0000000111: alu_op = 4'b1001; //AND

            endcase

        end

        7'b0010011: begin
            reg_write = 1'b1;
            alu_src = 1;

            case ({instr[30], funct3})
                4'b0000: alu_op = 4'b0000; //addi
                4'b0010: alu_op = 4'b0011; //slti
                4'b0011: alu_op = 4'b0100; //left off here. Test slti first and then go do this
                4'b0100: alu_op = 4'b0101; //xor imm
                4'b0110: alu_op = 4'b1000; //or imm
                4'b0111: alu_op = 4'b1000; //and imm
                4'b0001: alu_op = 4'b0010; //slli
                4'b0101: alu_op = 4'b0110; //srli
                4'b1101: alu_op = 4'b0111; //srai

            endcase
        end
            
        7'b0000011: begin //load instructions
            reg_write = 1'b1;
            alu_src = 1'b1;
            mem_read  = 1;   // read memory
            mem_to_reg = 2'b01;  // write memory data back
            alu_op = 4'b0000;
        end

        7'b1100111: begin //JARL command
        if (funct3 == 3'b000) begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_op = 4'b0000;
            mem_read = 0;
            pc_sel = 2'b10; //selects JARL target for the next pc
            mem_to_reg = 2'b10; //2'b10 selects PC+4
        end
        end

        //fence instructions (both FENCE and FENCE.i are convered in this instruction)
        7'b0001111: begin
            mem_read  = 0;
            mem_to_reg = 0;
        end

        //ecall and ebreak
        7'b1110011: begin
        halt = 1;
        if (instr[20] == 1'b1) begin
                $display("BREAKPOINT: EBREAK executed at PC=0x%h", pc_val);
            end else begin
                $display("SYSTEM CALL: ECALL executed at PC=0x%h", pc_val);
            end

        end

        //B-type
        7'b0100011: begin
        alu_src = 1;      // imm for address calculation
        reg_write = 0;
        mem_read = 0;

            case(funct3)
            
            //sb
            3'b000: begin
            alu_op = 4'b0000;
            
            end

            endcase

        end

        default: begin
            // keep default values
        end

    endcase
end

endmodule
