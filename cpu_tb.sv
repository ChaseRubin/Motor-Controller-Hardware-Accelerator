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

    // 1. Set base address x5 = 16 
    DUT.IMEM.mem[0] = 32'h01000293; 
    
    // 2. Set data x6 = 0xABCD
    DUT.IMEM.mem[1] = 32'habc00313;

    // 3. sh x6, 0(x5)
    DUT.IMEM.mem[2] = 32'h00629023;

    #12;
    reset = 0;

    #100;

    $display("\nFINAL MEMORY CHECK (Halfword Store):");
    $display("Memory Word [4] (Address 16-19) = %h", DUT.memory.mem[4]);
    
    // We expect the lower two bytes of Word 4 to be ABCD
    if (DUT.memory.mem[4][15:0] === 16'hABCD) begin
        $display("SUCCESS: sh stored 0xABCD at address 16");
    end else begin
        $display("FAILURE: Expected ABCD in bits [15:0], got %h", DUT.memory.mem[4][15:0]);
    end

    $finish;
end



endmodule