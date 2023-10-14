module mips_pipe(clk1, clk2);
reg [31:0] Memory [1023:0];//this is memory bank
reg [31:0] registers [31:0]; //this is register bank
reg [31:0] IF_ID_IR, PC, IF_ID_NPC;//these(and the registers in the following lines) are registers
//use to avoid hazards, unnecessary running of instructions etc.
reg [31:0] ID_EX_IR, PC, IF_ID_NPC,ID_EX_A,ID_EX_B,ID_EX_Imm;//essentially latches
reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type; //to hold type of the instruction
endmodule;