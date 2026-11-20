module CORE (
	input logic CLK,
	input logic RSTn,
	input logic [31:0] ROM_Ins,
	input logic [31:0] RAM_R_Data,
	input logic [31:0] PC_out,
	output logic CONTROL_MemRead,
	output logic CONTROL_MemtoReg,
	output logic CONTROL_MemWrite,
	output logic [31:0] RAM_W_Data,
	output logic [31:0] RAM_Addr
);


endmodule
