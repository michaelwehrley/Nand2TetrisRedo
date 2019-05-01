# Nand2Tetris

HACK
* https://www.coursera.org/learn/build-a-computer

Resources:
* https://www.nand2tetris.org/software
* https://www.nand2tetris.org/copy-of-nestedcall-1
* https://docs.google.com/presentation/d/1khaFGc6JihgjT9I24X1f33Me_oOpwaI-a2wTbBPhuoc/edit#slide=id.g4d42afba8a_1_179

```
|---------------------|--[ Monitor ]
|  The HACK Computer  |
|                     |
| ROM <=> CPU <=> RAM |
|---------------------|--[ Keyboard ]
```

* To get started with the *Hardware simulator* (b/c we aren't actually building chips): `$ HardwareSimulator.sh`
* Load `.hdl` script first, then the `.tst` file.

Weekly Projects
1. Elementary Logic Gates
1. Arithmetic-Logic Gates
1. Registers and Memory
1. Writing Low-Level
1. Comptuer Architecture
1. Develop Assembler

### Lesson Notes

* 8-bit, 16-bit, 32-bit and 64-bit all refer to a processor's **word** size. A **word** in processor parlance means the native size of information it can place into a **register** and process without special instructions. It also refers to the _size of the memory address space_.
* Several Tesla products move data across a 512-bit memory bus.

`Not(x) == Not(x And x)`
|x|x|NAND|
|0|0|1|
|1|1|0|

Gate Interface v. Gate Implementation

##### Gate Diagram:

   +------+
a=>|      |
   | NAND |O=>out
b=>|      |
   +------+

###### Standard Elementary Logic Gates
*And*:
`|)`

*Or*:
`)>`

*Not*:
`|>o`

##### Functional Specificiation:

`if (a == 1 and b == 1) then out = 0 else out = 1`

##### Truth Table:

Truth Table
|x|y|NAND|
|-|-|----|
|0|0| 1  |
|0|1| 1  |
|1|0| 1  |
|1|1| 0  |

##### Circut Implementation:

AND Gate (i.e., electrial engineering implementation)

______/ ____/ ______
|      a     b     |
|                  |
|_(power)____(out)_|

##### Hardware Description Language
* *Declarative/functional* language - it is a static description;
* Order doesn't matter b/c it is a functional language;
* Not procedural - there is no procedure running;
* There is an assumption that something/agent will *pipe* values from bottom to end/left to right;
* Examples: `VHDL`, `Verilog`

##### Multi-Bit Buses

* A bus is a a group of an array of bits.

Example: Addition of two 16-bit integers:
* 32 wires going in (i.e., 2 numbers going in).
* 16 wires coming out (i.e., 1 number coming out).

                +--------+
a == 16 bits ==>|        |
                | 16-bit |== 16 bits ==> out
                | adder  |
b == 16 bits ==>|        |
                +--------+
##### Interesting Gates & Programmable Gate

*Multiplexor (Mux)*
- A multiplexor is a device which takes in multiple signals and outputs a single signal. It works as an electronic switch.
- 3 inputs (`a`, `b`, and `sel`) and `if sel == 0 then out is a else b or if sel == 1 then out is b else a`

|sel|out|
|---|---|
| 0 | a |
| 1 | b |


Additional Example: AndMuxOr / **Programmable Gate**


     +----------+
a ==>|          |
     | AndMuxOr |==> out
b ==>|          |
     +----------+
          ^
          |
         sel

```
if sel == 0
  out = (is a AND b)
else # (i.e., sel == 1)
  out = (is a OR b)
```

*Demultiplexor (DMux)* The inverse of a multiplexor.

### Combinational Chips

These chips help build the ALU (Arithmetic Logic Unit)
* FullAdder is built using 2 HalfAdders :-)
* One thing to remeber is that the first 6 bits are for finding if it is a negative number! Whoops!
* Status outputs: `zr` and `ng` - zero and negative
* The ALU  and Inc16 took me quite some time!

### Sequential Chips

We need a way to store memory!  That is why we have RAM (Random Access Memory)
* We assume in this course that the DFF gate (Data Flip Flop gate) is a primitive chip.  It can be built using Nand Chips though.
* We can build a **register** from a DFF and build more registers to create a 16-bit register.
* With 16-bit registers, we can then create a x-number of registers to create a RAM memory unit built of 16-bit address combination: 65,536 bits ~ 64K. In this unit, we are building a 16K 16-bit RAM unit.
* The Program Counter (i.e., PC) too me fooooooorrever! :-)

### Machine Language

`$ CPUEmulator.sh`

|                 Memory             |
|====================================|
|         ROM        |      RAM      |
|--------------------|---------------|
|     Read-Only      |               |
|--------------------|---------------|
| Instruction Memory |  Data Memory  |
|                    |    (memory)   |
|--------------------|---------------|

* ROM is read only and reads the instructions that are loaded into it, kind of like a game cartridge.
* Labels help with readability
* Variables also help with readability.  Variables are assigned to memory greater than `n`
* **Loaders** help with **Relocatable Code**.
