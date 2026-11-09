# Verificación

Esta carpeta contiene los testbenches para verificar los diseños hardware.

`top_tb.sv` es un ejemplo que instancia `top`, prueba las cuatro combinaciones de entrada y comprueba la salida de la puerta AND.

`ALU_tb.sv` comprueba todas las operaciones de `ALU`, incluidos el desbordamiento de la suma, las comparaciones con y sin signo, los desplazamientos aritméticos con números negativos, los desplazamientos de más de 31 posiciones y el flag `Zero`.

Para simular, compila `Diseño/top.sv` y `Verificación/top_tb.sv` en un simulador compatible con SystemVerilog y selecciona `top_tb` como módulo principal de simulación.

Estos archivos no se añaden como fuentes de síntesis al QSF. La tarea de compilación de Quartus no ejecuta el testbench.
