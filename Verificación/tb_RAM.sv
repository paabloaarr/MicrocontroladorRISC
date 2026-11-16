`timescale 1ns/1ps

module tb_RAM();

parameter addr_width = 10; 
parameter data_width = 32; 

logic CLK; 
logic [addr_width-1:0] addr; 
logic [data_width-1:0] data_in; 
logic [data_width-1:0] data_out; 
logic MemWrite; 

RAM DUV (
.CLK(CLK),
.addr(addr),
.data_in(data_in),
.data_out(data_out),
.MemWrite(MemWrite)
);


always #5 CLK = ~CLK;

task escritura(input logic [9:0]addr_aux,input logic [31:0] data_in_aux);
addr = addr_aux;
data_in = data_in_aux;
#10;
MemWrite = 1;
#10;
MemWrite = 0;
#1;
assert(data_in == data_out)                                            // Lee el dato de salida que se habia escirto en cierta dirección; comprueba escritura/lecturra
    $display("Dato escrito correctamente");
    else
    $display("Dato escrito incorrectamente");
endtask

task lectura(input logic [9:0]addr_aux,input logic [31:0] data_esperado);
addr = addr_aux;
#1;
assert(data_esperado == data_out)
		$display("Dato leido correctamente");
		else
		$display("Dato no leido correctamente");
endtask

initial begin
CLK = 0;
MemWrite = 0;
data_in = 32'd0;
addr = 10'd0;

#10;

escritura(10'd0,32'h12345678);
#1;
escritura(10'd1,32'h87654321);
#1;
escritura(10'd2,32'h11111111);

lectura(10'd0,32'h12345678);
lectura(10'd1,32'h87654321);
lectura(10'd2,32'h11111111);

#20;
$stop;
end

endmodule
