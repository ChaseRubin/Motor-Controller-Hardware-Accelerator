`timescale 1ns/1ps

module imem_tb;

reg [31:0] pc;
wire [31:0] instr;

initial begin

pc = 2;

#5

pc = 6;

#5

pc = 10;

$finish;
end

initial begin
    $monitor("t=%0t pc=%b instr=%b",
             $time, pc, instr);
    
end

imem U0 (

.pc(pc),
.instr(instr)

);


endmodule