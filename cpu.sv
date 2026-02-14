`timescale 1ns/1ps

module cpu (
    input clk,
    input reset
);

//control signals
reg reg_write;
reg [3:0] alu_op;

wire [31:0] pc_val;
wire [31:0] pc_next;
wire [31:0] instr;


wire [31:0] rd1, rd2;
wire [31:0] alu_out;

//memory controls 
reg mem_read;
reg mem_to_reg;
wire [31:0] mem_data;
wire [31:0] address;
assign address = alu_out;
wire [7:0] selected_byte;

assign selected_byte =
    (address[1:0] == 2'b00) ? mem_data[7:0]   :
    (address[1:0] == 2'b01) ? mem_data[15:8]  :
    (address[1:0] == 2'b10) ? mem_data[23:16] :
                              mem_data[31:24];

wire [31:0] lb_data = {{24{selected_byte[7]}}, selected_byte};
wire [31:0] write_data;
assign write_data = (mem_to_reg) ? lb_data : alu_out;


//decode wires
wire [6:0] opcode = instr[6:0];
wire [2:0] funct3 = instr[14:12];
wire [6:0] funct7 = instr[31:25];
wire [4:0] rs1 = instr[19:15];
wire [4:0] rs2 = instr[24:20];
wire [4:0] rd  = instr[11:7];

wire [31:0] alu_input_b;

//decode for I-type
wire [31:0] imm_ext = {{20{instr[31]}}, instr[31:20]}; //concadonates the signed bit to fit the 32 bit alu

reg alu_src;

assign pc_next = pc_val + 32'd4; //pc inc

assign alu_input_b = (alu_src) ? imm_ext : rd2; //need to fix

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
    .address(address),
    .mem_read(mem_read),
    .data(mem_data)

);

always @(*) begin
    //default control signals
    reg_write = 1'b0;
    alu_op    = 4'b0000;
    alu_src = 1'b0;
    mem_read  = 0;
    mem_to_reg = 0;

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
            
        7'b0000011: begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            mem_read  = 1;   // read memory
            mem_to_reg = 1;  // write memory data back


            case (funct3)
                3'b000: alu_op =  4'b0000; //single bite load
                //3'b001: //left off here 
                //3'b010:
                //3'b100:
                //3'b101:

            endcase

        end

        default: begin
            // keep default values
        end

    endcase
end



endmodule
