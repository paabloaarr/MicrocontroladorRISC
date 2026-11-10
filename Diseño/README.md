# Diseño

Esta carpeta contiene los diseños hardware.

`ALU.sv` es la unidad aritmético-lógica combinacional de 32 bits del core: hace suma, resta, operaciones lógicas, desplazamientos y comparaciones según un código de operación de 4 bits, y da el resultado y el flag `Zero`. Es la entidad de nivel superior en `TinuC.qsf`.
Los archivos de diseño deben registrarse en `TinuC.qsf`, con rutas relativas a la raíz del proyecto.
