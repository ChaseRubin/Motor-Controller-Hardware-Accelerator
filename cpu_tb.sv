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
    
end

initial begin
    clk   = 0;
    reset = 1;

    // --- Instruction Memory Setup ---
    
    // 1. addi x5, x0, 9  -> 0x00a00293 (x5 = 9)
    DUT.IMEM.mem[0] = 32'h00100293; 
    
    // 2. addi x6, x0, 10  -> 0x00a00313 (x6 = 10)
    DUT.IMEM.mem[1] = 32'h00a00313;

    // 3. blt x5, x6, offset 8 -> 0x00628463 
    // This should jump from PC 8 to PC 16 (skipping the instruction at PC 12)
    DUT.IMEM.mem[2] = 32'h0062C463;

    // 4. addi x7, x0, 1   -> 0x00100393 (x7 = 1) 
    // SHOULD BE SKIPPED
    DUT.IMEM.mem[3] = 32'h00100393;

    // 5. addi x8, x0, 2   -> 0x00200413 (x8 = 2)
    // TARGET OF BRANCH
    DUT.IMEM.mem[4] = 32'h00200413;

    // 6. ebreak (halt)    -> 0x00100073
    DUT.IMEM.mem[5] = 32'h00100073;

    #12;
    reset = 0;

    // Wait for the halt signal (triggered by ebreak)
    wait(halt);

    #5;
    $display("\nFINAL REGISTER CHECK (BEQ Test):");
    $display("x5 (Value 9) = %d", DUT.RF.regs[5]);
    $display("x6 (Value 10) = %d", DUT.RF.regs[6]);
    $display("x7 (Should be 0 if skipped) = %d", DUT.RF.regs[7]);
    $display("x8 (Target, should be 2)    = %d", DUT.RF.regs[8]);

    if (DUT.RF.regs[7] === 32'h0 && DUT.RF.regs[8] === 32'd2) begin
        $display("SUCCESS: Branch taken, x7 remained 0.");
    end else begin
        $display("FAILURE: Branch not taken or incorrect target.");
    end

    $finish;
end



endmodule