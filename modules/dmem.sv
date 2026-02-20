`timescale 1ns/1ps

module dmem(
    input  wire        clk,         
    input  wire [31:0] address,
    input  wire        mem_read,
    input  wire [31:0] write_data,
    input  wire [3:0]  byte_en, 
    output wire [31:0] data
);

    // 4 KB memory -> 1024 words
    reg [31:0] mem [0:1023];
    assign data = (mem_read) ? mem[address[11:2]] : 32'b0;

    
    always @(posedge clk) begin
        //occurs if at least one byte_en bit is high
        if (byte_en[0]) mem[address[11:2]][7:0]   <= write_data[7:0];
        if (byte_en[1]) mem[address[11:2]][15:8]  <= write_data[15:8];
        if (byte_en[2]) mem[address[11:2]][23:16] <= write_data[23:16];
        if (byte_en[3]) mem[address[11:2]][31:24] <= write_data[31:24];
    end

    initial begin
        $readmemh("dmem.hex", mem);
    end

endmodule