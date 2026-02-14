`timescale 1ns/1ps

module dmem(
    input  wire [31:0] address,
    input  wire        mem_read,
    output wire [31:0] data
);

    // 4 KB memory -> 1024 words
    reg [31:0] mem [0:1023];
    
    assign data = (mem_read) ? mem[address[11:2]] : 32'b0;

    initial begin
        $readmemh("dmem.hex", mem);
    end

endmodule
