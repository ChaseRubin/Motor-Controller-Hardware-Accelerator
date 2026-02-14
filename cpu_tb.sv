`timescale 1ns/1ps

module cpu_tb;

reg clk;
reg reset;

cpu DUT (
    .clk(clk),
    .reset(reset)
);

// Clock
always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;


    DUT.IMEM.mem[0] = 32'b00000000000000001010000100000011;

    DUT.memory.mem[0] = 32'b01010101010101010101010101010100;
    
    // Preload register
    DUT.RF.regs[1] = 32'd0;  // x2 = 0

    $display("x1 = %b", DUT.RF.regs[1]);

    #10;
    reset = 0;

    //execute one cycle
    #20;

    #20;

    //result
    $display("x2 = %b", DUT.RF.regs[2]);

    $finish;
end

endmodule
