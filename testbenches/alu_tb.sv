`timescale 1ns/1ps

module alu_tb;

reg [31:0] a;
reg [31:0] b;
reg [16:0] op;
wire [31:0] alu_out;

initial begin

op = 17'b00000000100110011;
a = 5;
b = 6;

#10

op = 17'b00000000000110011;
a = 7;
b = 6;

#1
$finish;

end

initial begin
    $monitor("t=%0t a=%h b=%h op=%h alu_out=%h",
             $time, a, b, op, alu_out);
    
end


alu U0 (

.a(a),
.b(b),
.op(op),
.alu_out(alu_out)

);

endmodule