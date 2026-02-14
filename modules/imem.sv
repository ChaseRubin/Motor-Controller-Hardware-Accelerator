`timescale 1ns/1ps

module imem(

input wire [31:0] pc,
output reg [31:0] instr //32-bit instruction 
);

reg [31:0] mem [0:1023]; // 1024 memory instruction registers = 4 KB

    assign instr = mem[pc[31:2]]; // async read

initial begin
    // hex file, one 32-bit word per line
    $readmemh("imem.hex", mem);
end

endmodule