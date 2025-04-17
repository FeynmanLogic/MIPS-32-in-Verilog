`timescale 1ns/1ps

module mips_pipe_tb;
  reg clk1, clk2;
  integer k;

  // Instantiate the mips_pipe module
  mips_pipe uut(clk1, clk2);

  initial begin
    // Initialize memory and registers
    for (k = 0; k < 1024; k = k + 1)
      uut.Mem[k] = 32'h00000000;

    for (k = 0; k < 32; k = k + 1)
      uut.regb[k] = k;

    // Example instruction initialization:
    // Format: opcode (6 bits) + rs (5 bits) + rt (5 bits) + rd (5 bits) + shamt + funct (for R-type)
    // ADD R1 = R2 + R3
    uut.Mem[0] = {6'b000000, 5'd2, 5'd3, 5'd1, 5'd0, 6'b000000}; // ADD R1, R2, R3
    // ADDI R4 = R1 + 10
    uut.Mem[1] = {6'b001010, 5'd1, 5'd4, 16'd10};               // ADDI R4, R1, 10
    // SUB R5 = R4 - R3
    uut.Mem[2] = {6'b000001, 5'd4, 5'd3, 5'd5, 5'd0, 6'b000000}; // SUB R5, R4, R3
    // HLT
    uut.Mem[3] = {6'b111111, 26'd0};                            // HLT

    // Initialize control signals
    uut.PC = 0;
    uut.HALTED = 0;
    uut.TAKEN_BRANCH = 0;
  end

  // Clock generators
  always begin
    clk1 = 0; clk2 = 0;
    #5 clk1 = 1; #5 clk1 = 0;
    #5 clk2 = 1; #5 clk2 = 0;
  end

  // Monitor values (for debugging)
  always @(posedge clk1) begin
    $display("Time = %d", $time);
    $display("R1 = %d, R4 = %d, R5 = %d", uut.regb[1], uut.regb[4], uut.regb[5]);
    if (uut.HALTED) begin
      $display("Processor halted.");
      $finish;
    end
  end
endmodule
