//Some conventions used:
//IF-Instruction Fetch Cycle
//ID-Instruction decode cyle
//EX-Execute cycle
//MEM-memory access cyle
//WB-Write back cycle.
//


module mips_pipe(clk1, clk2);
input clk1, clk2;
//implementing two separate clocks for proper computation
reg [31:0] Mem [1023:0];
//this is memory bank
reg [31:0] regb [31:0]; 

//this is register bank

reg [31:0] IF_ID_IR, IF_ID_NPC;

//these(and the registers in the following lines) are registers
//use to avoid hazards, unnecessary running of instructions etc.

reg [31:0] ID_EX_IR, PC, IF_EX_NPC,ID_EX_A,ID_EX_B,ID_EX_Imm;
//spaces that hold the Instruction register, the New program counter, the A register
//the B register, the NPC, the Immediate value.

reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
//another set of latches.

reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;

//latches to hold the IR, data coming out of ALU, and the B register.

reg        EX_MEM_cond;
//a flag to check whether a branch was taken or not

reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type; 

//to hold type of the instruction
//motivation: to understand whether it is storing/memory/arithmetic instruction

parameter ADD= 6'b000000, SUB=6'b000001, AND=6'b000010, OR=6'b000011, SLT=6'b000100, 
MUL=6'b000101, HLT=6'b111111, LW=6'b001000, SW=6'b001001,
ADDI=6'b001010, SUBI=6'b001011, SLTI=6'b001100, BNEQZ=6'b001101, BEQZ=6'b001110;

//this list of parameters is created to improve readability of code. Since every execution
//depends on opcodes

parameter RR_ALU=3'b000, RM_ALU=3'b001, LOAD=3'b010, STORE=3'b011, BRANCH=3'b100,
HALT=3'b101;

//the above list of parameters define the type of instruction, whether it is register-register
//or Register memory or others.

reg HALTED;
//to check whether the current instruction is that of halt, so that we dont decrease
//processor efficiency by undergoing extra computation

reg TAKEN_BRANCH;
//to check whether the instruction is branch instruction or not

//the stage below is the instruction fetch stage
always ( @posedge clk1)
    if(HALTED==0)
        begin
            if(((EX_MEM_IR[31:26]==BEQZ)&&(EX_MEM_cond==1))||((EX_MEM_IR[31:26]==BNEQZ)&&(EX_MEM_cond=0)))//to check for branching
                begin
                    IF_ID_IR <= #2 Memory[EX_MEM_ALUOut];
                    //since new address is calculated at the end of the branch instructiom-
                   
                    //by definition only
                    TAKEN_BRANCH <= #2 1'b1;
                    IF_ID_NPC <= #2 EX_MEM_ALUOut +1;
                   
                    PC <= #2 EX_MEM_ALUOut+1;
                    //PC will be incremented by 1.
                end
            else
            //else normal execution will take place
                begin
                    IF_ID_IR <= #2 Memory[PC];
                    IF_ID_NPC <= #2 PC+1;
                    PC <= #2 PC+1;
                end
        end
//check the ID stage below.
always (@ posedge clk2)
    if(HALTED ==0)
    begin 
        if(IF_ID_IR[25:21]==5'b00000) ID_EX_A==32'h00000000;
        //this is to check whether we are accessing R0,if so, simply allot its value
        else ID_EX_A == regb[IF_ID_IR[25:21]];
        //ifnot, whatever the instruction format specifies, go to that register value.

        if(IF_ID_IR[20:16]==5'b00000) ID_EX_B=32'h00000000;
        else ID_EX_B == regb[IF_ID_IR[20:16]];
        ID_EX_NPC <= #2 IF_ID_NPC;
        ID_EX_IR <= #2 IF_ID_IR;

        //pass on these latches to the next stage

        ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}},{IF_ID_IR[15:0]}
        //we need to prepare a 32 bit intermediate, we do so by sign extension, 
        //so we concatenated the sign 16 times

        case(IF_ID_IR[31:26])

            ADD,SUB,AND,OR,SLT,MUL: ID_EX_type <= #2 RR_ALU;

            //pass on the type of the instruction to the specific latch in the next stage
            ADDI,SUBI,SLTI: ID_EX_type <= #2 RM_ALU;
            SW: ID_EX_type <= #2 STORE;
            LW: ID_EX_type <= #2 LOAD;
            BNEQZ,BEQZ: ID_EX_type <= #2 BRANCH;
            HLT: ID_EX_type <= #2 HALT;
            default: ID_EX_type <= #2 HALT;
        endcase
    end
//consider the EX(execute stage) implemented below
always (@ posedge clk1)
    if(HALTED==0)
    begin
        EX_MEM_type <= #2 ID_EX_type;
        EX_MEM_IR <= #2 ID_EX_IR;
        TAKEN_BRANCH <= #2 0;
        case(ID_EX_type):
        RR_ALU:begin
            case(ID_EX_IR[31:26])
            //perform required computation according to opcode
                ADD: EX_MEM_ALUOut <= #2 ID_EX_A +ID_EX_B;
                SUB: EX_MEM_ALUOut <= #2 ID_EX_A -ID_EX_B;
                AND: EX_MEM_ALUOut <= #2 ID_EX_A &ID_EX_B;
                OR: EX_MEM_ALUOut <= #2 ID_EX_A |ID_EX_B;
                SLT: EX_MEM_ALUOut <= #2 ID_EX_A <ID_EX_B;
                //here EX_MEM_ALUOut is essentially a buffer using which
                //send data onto the memory
                MUL:SUB: EX_MEM_ALUOut <= #2 ID_EX_A *ID_EX_B;
                default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;//in case of no previous match store default
            endcase
        end
        RM_ALU:begin
        case(ID_EX_IR[31:26])
            ADDI: EX_MEM_ALUOut <= #2 ID_EX_A+ ID_EX_Imm;
            SUBI: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
            SLTI: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
            default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
        endcase
        end
        LOAD,STORE:begin
            EX_MEM_ALUOut <=  #2 ID_EX_A + ID_EX_Imm;
            EX_MEM_B <=  #2 ID_EX_B;
            //need the destination address/ destination register
        end
        BRANCH: begin
            EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
            //calculate the address to where it has to go
            EX_MEM_cond <= #2 (ID_EX_A ==0)
            //calculate to set or reset the flag
        end
        

        endcase
    end
//let's consider the MA(Memory access) stage below
always (@posedge clk2)
begin
    if(HALTED==0)
    begin
        MEM_WB_type <= #2 EX_MEM_type;

        //forward values from previous latch to another

        MEM_WB_IR <= #2 EX_MEM_IR;
        case (MEM_WB_type)
        RR_ALU, RM_ALU:MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
        //simply forward the result of the computation
        LOAD: MEM_WB_ALUOut <= #2 Mem[EX_MEM_ALUOut];
        //we find out the data element to be loaded, since EX_MEM_ALUOut contains
        //the address of the data element to be loaded
        STORE: begin
            if(TAKEN_BRANCH ==0)
        begin
            MEM_WB_ALUOut <= #2 EX_MEM_B;
            //we find out the address at which data element to be stored
        end
        end
        endcase
    end
end
//check the WB(Write back) stage given below
always (@posedge clk1)
begin
    if(TAKEN_BRANCH ==0)
    begin
        case(MEM_WB_type)
        RR_ALU: regb[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut;
        //put the result of the computation in the required register
        //according to the R type of Instruction
        RM_ALU: regb[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut;
        //same as above
        STORE: regb[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;
        HALT:HALTED <= #2 1'b1;
        endcase
    end
end
endmodule