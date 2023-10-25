`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2023 22:28:32
// Design Name: 
// Module Name: Microcontroller
// Name - Kaushal Kumar Kumawat
// Roll No.- 21PHC1R15
//////////////////////////////////////////////////////////////////////////////////


module Microcontroller(clk,rst);
input clk,rst;

parameter LOAD = 2'b00, FETCH = 2'b01, DECODE = 2'B10, EXECUTE = 2'B11;
reg [1:0] current_state,next_state;
reg [11:0] program_mem [9:0];
reg load_done;
reg [7:0] load_addr;
reg [7:0] PC,  DR, Acc;
reg [11:0] IR;
reg [3:0]  SR;
reg PC_clr,Acc_clr,SR_clr,DR_clr,IR_clr;

wire [11:0] load_instr;
wire PC_E,Acc_E,SR_E,DR_E,IR_E;
wire [7:0] PC_updated,DR_updated;
wire[11:0] IR_updated;
wire[3:0] SR_updated;
wire PMem_E,DMem_E,DMem_WE,ALU_E,PMem_LE,MUX1_Sel,MUX2_Sel;
wire [3:0] ALU_Mode;
wire [7:0] Adder_Out;
wire [7:0] ALU_Out,ALU_Oper2;

// Load instruction memory
initial
begin
    $readmemb("program_mem.dat",program_mem,0,9);
end

// ALU
ALU ALU_unit( 
    .Operand1(Acc), 
    .Operand2(ALU_Oper2), 
    .E(ALU_E), 
    .Mode(ALU_Mode), 
    .CFlags(SR), 
    .Out(ALU_Out), 
    .Flags(SR_updated));

// MUX2
MUX1 MUX2_unit( 
    .In2(IR[7:0]), 
    .In1(DR), 
    .Sel(MUX2_Sel), 
    .Out(ALU_Oper2)); 

// Data Memory
Data_Memory DMem_unit( 
    .clk(clk),
    .E(DMem_E), 
    .WE(DMem_WE), 
    .Addr(IR[3:0]),  
    .DI(ALU_Out), 
    .DO(DR_updated));
 
// Program memory
PMem PMem_unit( 
    .clk(clk), 
    .E(PMem_E), 
    .Addr(PC), 
    .I(IR_updated), 
    .LE(PMem_LE),  
    .LA(load_addr), 
    .LI(load_instr));

// PC ADder
Adder PC_Adder_unit( 
    .In(PC), 
    .Out(Adder_Out));
 
// MUX1
MUX1 MUX1_unit(
    .In1(Adder_Out), 
    .In2(IR[7:0]), 
    .Sel(MUX1_Sel), 
    .Out(PC_updated));
 
// Control logic
Control_Unit Control_Logic_Unit( .stage(current_state),
    .IR(IR),
    .SR(SR),
    .PC_E(PC_E),
    .Acc_E(Acc_E),
    .SR_E(SR_E),
    .IR_E(IR_E),
    .DR_E(DR_E),
    .PMem_E(PMem_E),
    .DMem_E(DMem_E),
    .DMem_WE(DMem_WE),
    .ALU_E(ALU_E),
    .MUX1_Sel(MUX1_Sel),
    .MUX2_Sel(MUX2_Sel),
    .PMem_LE(PMem_LE),
    .ALU_Mode(ALU_Mode));
 
// LOAD
always @(posedge clk)
begin
    if(rst == 1)
        begin
            load_addr <= 0;
            load_done <= 1'b0;
        end 
    else if(PMem_LE==1)
        begin 
            load_addr <= load_addr + 8'd1;
                if(load_addr == 8'd9)
                    begin
                        load_addr <= 8'd0;
                        load_done <= 1'b1;
                    end
                else
                    begin
                        load_done <= 1'b0;
                    end
        end 
end
 
assign load_instr = program_mem[load_addr];
 
// next state
always @(posedge clk)
begin
    if(rst==1)
        current_state <= LOAD;
    else
        current_state <= next_state;
end

always @(*)
begin
    PC_clr = 0;
    Acc_clr = 0;
    SR_clr = 0;
    DR_clr = 0; 
    IR_clr = 0;
    case(current_state)
        LOAD:   begin
                    if(load_done==1) 
                        begin
                            next_state = FETCH;
                            PC_clr = 1;
                            Acc_clr = 1;
                            SR_clr = 1;
                            DR_clr = 1; 
                            IR_clr = 1;
                        end
                    else
                        next_state = LOAD;
                end
        FETCH:  begin
                    next_state = DECODE;
                end
        DECODE: begin
                    next_state = EXECUTE;
                end
        EXECUTE:    begin
                        next_state = FETCH;
                    end 
    endcase
end
 
// 3 programmer visible register
always @(posedge clk)
begin
    if(rst==1) 
        begin
            PC <= 8'd0;
            Acc <= 8'd0;
            SR <= 4'd0;
        end
    else 
        begin
            if(PC_E==1'd1) 
                PC <= PC_updated;
            else if (PC_clr==1)
                PC <= 8'd0;
            if(Acc_E==1'd1) 
                Acc <= ALU_Out;
            else if (Acc_clr==1)
                Acc <= 8'd0;
            if(SR_E==1'd1) 
                SR <= SR_updated; 
            else if (SR_clr==1)
                SR <= 4'd0; 
        end
end

// 2 programmer invisible register
always @(posedge clk)
begin
    if(DR_E==1'd1) 
        DR <= DR_updated;
    else if (DR_clr==1)
        DR  <= 8'd0;
    if(IR_E==1'd1) 
        IR <= IR_updated;
    else if(IR_clr==1)
        IR <= 12'd0;
end  
 
endmodule



module ALU(Operand1,Operand2,E,Mode,CFlags,Out,Flags);

// Dexlaring the ports and their parameters
input [7:0] Operand1,Operand2;
input E; // Enable input for ALU
input [3:0] Mode; // Selecting the mode of operation (Binary encoding IR[7:4])
input [3:0] CFlags; // Current status of the flags (Z,C,S,O - MSB to LSB format)
output [7:0] Out; // Output of the ALU after performing operation
output [3:0] Flags; // Output of ALU for changing flags (Z,C,S,O - MSB to LSB format)

wire Z,S,O;
reg CarryOut;
reg [7:0] Out_ALU;

always @(*)
begin
case(Mode) // IR[7:4] = Mode
    4'b0000:    {CarryOut,Out_ALU} = Operand1 + Operand2; // Addition Operation
    4'b0001:    begin  // SUBAM Operation
                        Out_ALU = Operand1 - Operand2;
                        CarryOut = !Out_ALU[7];
                end 
    4'b0010:    Out_ALU = Operand1; // MOVAM 
    4'b0011:    Out_ALU = Operand2; // MOVMA
    4'b0100:    Out_ALU = Operand1 & Operand2; // Bitwise AND Operation
    4'b0101:    Out_ALU = Operand1 | Operand2; // Bitwise OR Operation
    4'b0110:    Out_ALU = Operand1 ^ Operand2; // Bitwise XOR Operation
    4'b0111:    begin // SUBMA Operation
                        Out_ALU = Operand2 - Operand1;
                        CarryOut = !Out_ALU[7];
                end
    4'b1000:    {CarryOut,Out_ALU} = Operand2 + 8'h1; // INCREAMENT Operation       
    4'b1001:    begin // DECREAMENT Operation 
                        Out_ALU = Operand2 - 8'h1;
                        CarryOut = !Out_ALU[7];
                end
    4'b1010:    Out_ALU = (Operand2 << Operand1[2:0]) | (Operand2 >> Operand1[2:0]); // ROTATE LEFT OPERATION
    4'b1011:    Out_ALU = (Operand2 >> Operand1[2:0]) | (Operand2 << Operand1[2:0]); // ROTATE RIGHT OPERATION
    4'B1100:    Out_ALU = Operand2 << Operand1[2:0]; // SHIFT LEFT LOGICAL OPERATION
    4'b1101:    Out_ALU = Operand2 >> Operand1[2:0]; // SHIFT RIGHT LOGICAL OPERATION
    4'b1110:    Out_ALU = Operand2 >>> Operand1[2:0]; // SHIFT RIGHT ARITHMETIC OPERATION
    4'b1111:    begin // COMPLIMENT OPERATION
                      Out_ALU = 8'h0 - Operand2;
                        CarryOut = !Out_ALU[7];
                end  
    default:    Out_ALU = Operand2;  
                
endcase
end

assign O = Out_ALU[7] ^ Out_ALU[6];
assign Z = (Out_ALU == 0)? 1'b1 : 1'b0;
assign S = Out_ALU[7];
assign Flags = {Z,CarryOut,S,O};
assign Out = Out_ALU;
endmodule


module Control_Unit(stage,IR,SR,PC_E,Acc_E,SR_E,IR_E,DR_E,PMem_E,DMem_E,DMem_WE,ALU_E,MUX1_Sel,MUX2_Sel,PMem_LE,ALU_Mode);

input [1:0] stage;
input [11:0] IR;
input [3:0] SR;
output reg [3:0] ALU_Mode;
output reg PC_E,Acc_E,SR_E,IR_E,DR_E,PMem_E,DMem_E,DMem_WE,ALU_E,MUX1_Sel,MUX2_Sel,PMem_LE;

parameter LOAD = 2'b00, FETCH = 2'b01, DECODE = 2'b10, EXECUTE = 2'b11;

always @(*)
begin
    PMem_E = 0;
    PC_E = 0;
    Acc_E = 0;
    SR_E = 0;
    IR_E = 0;
    DR_E = 0;
    PMem_E = 0;
    DMem_E = 0;
    DMem_WE = 0;
    ALU_E = 0;
    ALU_Mode = 4'D0;
    MUX1_Sel = 0;
    MUX2_Sel = 0;
    if (stage == LOAD)
        begin
            PMem_LE = 1;
            PMem_E = 1;
        end    
    else if (stage == DECODE)
        if (IR[11:9] == 3'b001)
            begin
                DR_E = 1;
                DMem_E = 1;
            end
        else
            begin
                DR_E = 0;
                DMem_E = 0;
            end
    else if(stage == EXECUTE)
        begin
            if(IR[11] == 1) // ALU I-TYPE
                begin
                    PC_E = 1;
                    Acc_E = 1;
                    SR_E = 1;
                    ALU_E = 1;
                    ALU_Mode = IR[10:8];
                    MUX1_Sel = 1;
                    MUX2_Sel = 0;
                end
            else if(IR[10] == 1) // JZ, JC, JS, JO
                begin
                    PC_E = 1;
                    MUX1_Sel = SR[IR[9:8]];
                end
            else if(IR[9] == 1) // ALU M-TYPE
                begin
                    PC_E = 1;
                    Acc_E = IR[8];
                    SR_E = 1;
                    DMem_E = !IR[8];
                    DMem_WE = !IR[8];
                    ALU_E = 1;
                    ALU_Mode = IR[7:4];
                    MUX1_Sel = 1;
                    MUX2_Sel = 1;
                end
            else if(IR[8] ==0)
                begin
                    PC_E = 1;
                    MUX1_Sel = 1;
                end
            else
                begin
                    PC_E = 1;
                    MUX1_Sel = 0;
                end
        end
end
endmodule


module PMem(clk,E,Addr,I,LE,LA,LI);
input clk; // Clock input
input E; // Enable port
input [7:0] Addr; // Address port
// 3 special ports are used to load program to the memory
input LE; // Load enable port
input [7:0] LA; // Load address port
input [11:0] LI; // Load instruction port
output [11:0] I; // Instruction port

reg [11:0] Prog_Mem [255:0];

always @(posedge clk)
    begin
        if (LE == 1)
            begin
                Prog_Mem[LA] <= LI;
            end
    end
    
assign I = (E == 1) ? Prog_Mem[Addr] : 0;


endmodule


module Data_Memory(clk,E,WE,Addr,DI,DO);

// port declaration
input clk; // clock input
input E; // Enable port
input WE; // Write enable port
input [3:0] Addr; // Address port
input [7:0] DI; // Data input port
output [7:0] DO; // Data output port

reg [7:0] data_mem [255:0];

always @(posedge clk)
begin
    if(E == 1 && WE == 1)
     data_mem [Addr] <= DI;
end

assign DO = ( E == 1)? data_mem[Addr] : 0;
endmodule


module MUX1(In1,In2,Sel,Out);
input [7:0] In1,In2;
input Sel;
output [7:0] Out;

assign Out = (Sel == 1)? In1 : In2;

endmodule


module Adder(In,Out);
input [7:0] In;
output [7:0] Out;

assign Out = In + 1;
   
endmodule
