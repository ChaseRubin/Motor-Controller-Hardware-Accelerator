`timescale 1ns/1ps

module regfile_tb;

reg clk;
reg w_en;
reg [4:0] rs1, rs2, rd;
reg [31:0] wd;
wire [31:0] rd1, rd2;

initial begin
    clk = 0;
    w_en = 0;

    //step 1: x1 = 10
    rd = 5'd1; //destination reg set to 1
    wd = 32'd10; //data to be written is 10
    w_en = 1; //write is enabled so rd now = 10
    #10

    //step 2: x2 = 20
    rd = 5'd2; //same process
    wd = 32'd20;
    #10

    w_en = 0;

    //step 3: read x1 and x2
    rs1 = 5'd1; //rs1 is set to register 1
    rs2 = 5'd2; //rs2 is set to register 2
    #5;

    //testbench add
    wd = rd1 + rd2; // add command: write data is set to rd1 + rd2

    //write result into x3
    rd = 5'd3; //desitnation reg is set to reg3
    w_en = 1; //write is enabled so reg3 will become whatever is on the write data
    #10

    w_en = 0;

    //verify x3

    rs1 = 5'd3; //source register 1 is set to reg 3
        #5;

        $display("x3 = %d (should be 30)", rd1); //source register 1 value is displayed

    #10;
    //SUB instruction sim
    //step 1

    rd = 5'd1; // dest reg set to reg 1
    wd = 32'd10; //write data is 10
    w_en = 1; //write is set to 1 so reg 1 is now equal to 10

    //step 2
    rd = 5'd2; // dest reg set to reg 2
    wd = 32'd5; //write data is 5   
    #10
    w_en = 0;

    //step 3: read x1 and x2
    rs1 = 5'd1;
    rs2 = 5'd2;
    #5;

    wd = rd1 - rd2;
    rd = 5'd3;

    w_en = 1;
    #10

    w_en = 0;

    rs1 = 5'd3; //source register 1 is set to reg 3
        #5;

        $display("x3 = %d (should be 5)", rd1); //source register 1 value is displayed

$finish;
end

always begin
    #5 clk = ~clk;
end

regfile uut (
        .clk(clk),
        .w_en(w_en),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

endmodule