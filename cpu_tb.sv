`timescale 1ns/1ps

module cpu_tb;

reg clk;
reg reset;


// Instantiate DUT
cpu DUT (
    .clk(clk),
    .reset(reset),
    .halt(halt)
);

always #5 clk = ~clk;   // 10 ns period

always @(posedge clk) begin
    if (halt) $finish;
    $display(
        "t=%0t | PC=%0d | x1=%0d | x5=%0d | x6=%0d | x7=%0d",
        $time,
        DUT.pc_val,
        DUT.RF.regs[1],   // return address register
        DUT.RF.regs[5],   // jump target base
        DUT.RF.regs[6],   // function body result
        DUT.RF.regs[7]    // post-return result
    );
end

initial begin
    clk   = 0;
    reset = 1;


    // PC=0   -> x5 = 16
    DUT.IMEM.mem[0] = 32'h01000293; // addi x5,x0,16

    // PC=4   -> call function @16, save return addr in x1 (=8)
    DUT.IMEM.mem[1] = 32'h000280E7; // jalr x1,0(x5)

    // PC=8   -> should execute AFTER return
    DUT.IMEM.mem[2] = 32'h06300393; // addi x7,x0,99

    // PC=12  -> infinite loop to stop runaway PC
    DUT.IMEM.mem[3] = 32'b00000000000100000000000001110011; // jalr x0,0(x0)

    // PC=16  -> "function body"
    DUT.IMEM.mem[4] = 32'h02A00313; // addi x6,x0,42

    // PC=20  -> return to x1 (=8)
    DUT.IMEM.mem[5] = 32'h00008067; // jalr x0,0(x1)

    DUT.RF.regs[1] = 0;
    DUT.RF.regs[5] = 0;
    DUT.RF.regs[6] = 0;
    DUT.RF.regs[7] = 0;

    #12;
    reset = 0;

    
    #200;
    $display("\nFINAL STATE:");
    $display("x1 (return addr) = %0d (expect 8)", DUT.RF.regs[1]);
    $display("x6 (function val) = %0d (expect 42)", DUT.RF.regs[6]);
    $display("x7 (after return) = %0d (expect 99)", DUT.RF.regs[7]);

    $finish;
end

endmodule
