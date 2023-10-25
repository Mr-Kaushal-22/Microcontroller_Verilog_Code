`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.03.2023 00:01:35
// Design Name: 
// Module Name: Microcontroller_tb
// Name - Kaushal Kumar Kumawat
// Roll No.- 21PHC1R15
//////////////////////////////////////////////////////////////////////////////////


module Microcontroller_tb();
// Inputs
reg clk;
reg rst;
// Instantiate the Unit Under Test (UUT)
MicroController uut ( .clk(clk), .rst(rst));
initial 
begin
// Initialize Inputs
rst = 1;
// Wait 100 ns for global reset to finish
    #100; 
    rst = 0;
end
initial 
begin 
    clk = 0;
    forever #10 clk = ~clk;
end 
endmodule 
