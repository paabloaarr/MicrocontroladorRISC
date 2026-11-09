# Verificación

Esta carpeta contiene los testbenches para verificar los diseños hardware.

`top_tb.sv` es un ejemplo que instancia `top`, prueba las cuatro combinaciones de entrada y comprueba la salida de la puerta AND.

`tb_ALU.sv` instancia `ALU` con `Data1 = 10` y `Data2 = 5` y recorre los códigos de operación del 0 al 9, uno por ciclo de un reloj de 20 ns.

Para simular, compila el diseño y su testbench en un simulador compatible con SystemVerilog (por ejemplo, `Diseño/ALU.sv` y `Verificación/tb_ALU.sv`) y selecciona el testbench (`tb_ALU`) como módulo principal de simulación.

Estos archivos no se añaden como fuentes de síntesis al QSF. La tarea de compilación de Quartus no ejecuta el testbench.
