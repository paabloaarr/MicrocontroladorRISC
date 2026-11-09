# TinuC: microcontrolador RISC-V básico a nivel RTL

Proyecto de la **Tarea 2** de *Integración de Sistemas Digitales* (ISDIG), Universitat Politècnica de València, curso 2026/27.

El objetivo es diseñar, verificar y validar experimentalmente **TinuC**, un microcontrolador sencillo con un procesador de 32 bits que ejecuta un subconjunto del juego de instrucciones **RISC-V (RV32I)**. El diseño se describe en SystemVerilog sintetizable, se implementa en la FPGA Cyclone IV E de la placa **DE2-115** y se valida en el laboratorio con una aplicación propia que usa los recursos de la placa.

El proyecto abarca la descripción de hardware, la verificación funcional, la segmentación de un procesador con su control de riesgos y la programación en ensamblador de RISC-V.

## Integrantes

- Joan Bertomeu Alemany
- Mikel Pons Berastegui
- Rubén Quiñones Lara
- Aaron Ayela Martín
- Chentang Abascal Gómez
- Pablo Arribas Huerta

## El procesador

- Core de 32 bits con 31 registros de propósito general (`x1`–`x31`) y el registro `x0` cableado a 0.
- Contador de programa `pc`.
- Instrucciones de 32 bits en los formatos R, I, S, SB, U y UJ, alineadas a 4 bytes.
- Versión final segmentada en 5 etapas: búsqueda de instrucción (IF), decodificación y lectura de registros (ID), ejecución (EX), acceso a memoria (MEM) y escritura en registros (WB).

### Juego de instrucciones

| Grupo | Instrucciones |
|---|---|
| Aritmético-lógicas con inmediato | `ADDI`, `SLTI`, `SLTIU`, `ANDI`, `ORI`, `XORI`, `LUI`, `AUIPC`, `SLLI`, `SRLI`, `SRAI` |
| Aritmético-lógicas con registros | `ADD`, `SUB`, `SLT`, `SLTU`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA` |
| Saltos condicionales | `BEQ`, `BNE` |
| Carga y almacenamiento | `LW`, `SW` |
| Extensión de control de flujo | `JAL`, `JALR`, `BLT`, `BLTU`, `BGE`, `BGEU` |

No incluye instrucciones de sistema ni interrupciones.

## El microcontrolador

TinuC se compone de los siguientes bloques:

- **Core RV32I:** el procesador.
- **IMEM:** memoria de instrucciones de 1024 palabras de 32 bits, inicializada desde un fichero con el programa.
- **DMEM:** memoria de datos de 1024 palabras de 32 bits.
- **GPIO:** módulo de entradas y salidas con 16 pines de entrada y 16 de salida, conectados a interruptores, pulsadores, LEDs o displays de la placa.
- **Controlador de memoria (MEM_CTRL):** decide si cada lectura o escritura de datos va a la DMEM o al GPIO, que está mapeado en memoria justo después de la DMEM.

Dentro del core, las unidades principales son la ALU, el banco de registros (2 lecturas y 1 escritura simultáneas), el generador de inmediatos y la unidad de control.

## Fases

El diseño avanza por fases y cada una se valida antes de pasar a la siguiente.

1. **Unidades funcionales.** Diseño y verificación de las memorias, la ALU y el banco de registros. También se programan en ensamblador dos programas de prueba: la serie de **Fibonacci** y la **ordenación por selección**.
2. **Procesador *single-cycle*.** Procesador que ejecuta cada instrucción en un ciclo de reloj. Se verifica con los programas de prueba y con programas que cubren todas las instrucciones, y después con un testbench automatizado. Sirve como modelo de referencia (*golden model*) para la fase siguiente.
3. **Procesador segmentado.** Pipeline de 5 etapas verificado frente al *single-cycle*, con análisis de temporización y de uso de recursos.
   - **3.1:** ampliación con `JAL`, `JALR`, `BLT`, `BLTU`, `BGE` y `BGEU`.
   - **3.2 (opcional):** detección y resolución de riesgos de datos (adelantamiento y detenciones) y de control.
4. **Implementación en la DE2-115.** Montaje del microcontrolador completo en la FPGA y desarrollo de una aplicación interactiva en ensamblador que use las entradas y salidas del GPIO, como un juego de LEDs, un temporizador con displays de 7 segmentos o una calculadora.

## Documentación

El enunciado completo, la rúbrica, las plantillas de entrega y la documentación de referencia de RISC-V y de la DE2-115 están en la carpeta [`Docs/`](Docs/).
