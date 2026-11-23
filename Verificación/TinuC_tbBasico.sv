module Tinuc_tbBasico();

logic CLOCK,RESET;

parameter T=20;

logic ram_we,ram_re;

logic [31:0] ram_address,ram_data_in,ram_data_out,data_in,data_out,pc,instruction;

RAM ram ()
