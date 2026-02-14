`timescale 1ns/1ps

module regfile (
    input  wire        clk,
    input  wire        w_en, //write enable
    input  wire [4:0]  rs1, rs2, rd, //rd is write port
    input  wire [31:0] wd, //write data
    output wire [31:0] rd1, rd2 // destination registers
);
    reg [31:0] regs [0:31];

    // x0 hardwire
    assign rd1 = (rs1 == 0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 0) ? 32'b0 : regs[rs2];

    // synchronous write
    always @(posedge clk) begin
        if (w_en && (rd != 0))
            regs[rd] <= wd;
    end
endmodule
