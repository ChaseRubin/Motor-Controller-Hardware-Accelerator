`timescale 1ns/1ps

module alu(

//The alu takes in two inputs and one operation, operates and provides the result 
input wire [31:0] a,
input wire [31:0] b,
input wire [3:0] op,
output reg [31:0] alu_out

);

always_comb begin                   
    case(op)
    //opcode convention for R-Type instructions:
    //funt7+funct3+opcode
    4'b0000 : alu_out = a + b; //add
    4'b0001 : alu_out = a - b; //subtract
    4'b0010 : alu_out = a << b; //SLL (shift left logical)
    4'b0011 : alu_out = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; //SLT (set less than)
    4'b0100 : alu_out = (a < b) ? 32'd1 : 32'd0; //STLU (set less than unsigned)
    4'b0101: alu_out = a ^ b; //xor
    4'b0110 : alu_out = a >> b; //SRL shift right (shifts in 0's on the left)
    4'b0111 : alu_out = $signed(a) >>> b; //SRA shift right arithmatic
    4'b1000 : alu_out = a | b; //OR
    4'b1001 : alu_out = a & b; //AND

    default : alu_out = 17'b00000000000000000;
endcase

end

endmodule 