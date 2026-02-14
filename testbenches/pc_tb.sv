`timescale 1ns/1ps
module pc_tb;

reg clk;
reg reset;
reg load; 
reg enable; 
reg [31:0] load_value;
wire [31:0] pc_out;

initial begin
    clk = 0;
    reset = 1;
    load = 0;
    enable = 0;
    load_value = 32'h0;

    #20 reset = 0;
    enable = 1;

    #40 enable = 0;
    load_value = 011111111;
    load = 1;
    

    #20 $finish;
  end

initial begin
    $monitor("t=%0t clk=%b rst=%b load=%b en=%b pc=%h",
             $time, clk, reset, load, enable, pc_out);
    

end

always begin
    #5 clk = ~clk;
end

pc U0 (

.clk(clk),
.reset(reset),
.load(load),
.enable(enable),
.load_value(load_value),
.pc_out(pc_out)

);


endmodule