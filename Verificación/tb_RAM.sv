`timescale 1ns/1ps

module tb_RAM();

parameter addr_width = 10; 
parameter data_width = 32; 

logic CLK; 
logic [addr_width-1:0] RAM_Addr; 
logic [data_width-1:0] RAM_W_Data; 
logic [data_width-1:0] RAM_R_Data; 
logic RAM_memRead; 
logic RAM_memWrite;

RAM DUV (
.CLK(CLK),
.RAM_Addr(RAM_Addr),
.RAM_W_Data(RAM_W_Data),
.RAM_R_Data(RAM_R_Data),
.RAM_memRead(RAM_memRead),
.RAM_memWrite(RAM_memWrite)
);


always #5 CLK = ~CLK;

task escritura(input logic [9:0]addr_aux,input logic [31:0] data_in_aux);
RAM_Addr = addr_aux;
RAM_W_Data = data_in_aux;
RAM_memRead = 0;
#10;
RAM_memWrite = 1;
#10;
RAM_memWrite = 0;

RAM_memRead = 1;
#1;
assert(RAM_W_Data == RAM_R_Data)                                            // Lee el dato de salida que se habia escirto en cierta dirección; comprueba escritura/lecturra
    $display("Dato escrito correctamente");
    else
    $display("Dato escrito incorrectamente");
endtask

task lectura(input logic [9:0]addr_aux,input logic [31:0] data_esperado);
RAM_Addr = addr_aux;
RAM_memRead = 1;
#1;
assert(data_esperado == RAM_R_Data)
		$display("Dato leido correctamente");
		else
		$display("Dato no leido correctamente");
endtask

initial begin
CLK = 0;
RAM_memWrite = 0;
RAM_memRead = 0;
RAM_W_Data = 32'd0;
RAM_Addr = 10'd0;

#10;

escritura(10'd0,32'h12345678);
#1;
escritura(10'd1,32'h87654321);
#1;
escritura(10'd2,32'h11111111);

lectura(10'd0,32'h12345678);
lectura(10'd1,32'h87654321);
lectura(10'd2,32'h11111111);
#1
RAM_memRead = 0;
#1
assert(RAM_R_Data == 32'b0)
	$display("Salida 0 cuando RAM_MemRead = 0");
else
	$display("Error la salida no es 0 cuando RAM_MemRead = 0");
#20;
$stop;
end

endmodule
