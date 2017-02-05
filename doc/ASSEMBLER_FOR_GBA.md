# Assembler for the GBA

Originally from [Touched/asm-tutorial][tutorial].

[tutorial]: https://github.com/Touched/asm-tutorial/blob/master/doc.md

## Introduction

This is a document designed to increase your knowledge of assembly hacking on the Game Boy Advance. It is not a tutorial where I give you a template piece of ASM and you execute it and are left wondering what the fuck you just did. The purpose of this document is not to get you to write ASM just yet, but rather to allow you to understand ASM and hopefully provide you with some pointers (no pun intended) on where to go next. I write this document expecting the reader to have some baseline knowledge about computers and ROM hacking. I expect you to be able to search online and read Wikipedia articles. I expect you to consult GBATEK, a fantastic resource on everything GBA related.

I do not aim to teach you "all the opcodes" or provide a guide on how to implement a certain feature. I do aim to increase your level of understanding and then go off and learn these things yourself. As hackers, we spend a vast amount of time researching and reading assembly code. You cannot write what you cannot read and understand. If you cannot learn to do these things for yourself, you might as well stop reading. If you relish the challenge of understanding something complex and technical, then read on.

Be warned, this document contains lots of theory and may look like a wall of text. I have tried to explain it in as friendly a way as possible. If something is not clear, please open an issue and I will do my best to rectify it. 

## Chapter 1: Memory

### Addressing and The Bus
A CPU is very good at performing computations, but not very good at remembering the results of those computations. This is where memory comes into play. The GBA has various blocks of memory, each with their own purpose. Despite these blocks of memory being physically distinct (they are typically on different chips), the software sees them as (almost) a single, contiguous block.
In order to access this memory, we use what is known as an *address*. The address carries with it two pieces of information: the memory block or region to access, and the offset from the start of that location. This is viewed as a single, 32 bit number. The 8 most significant bits of this number are the block, and the remaining bits are the offset.

For example, the address 08123456:

| Prefix | Offset |
|--------|--------|
| 08     | 123456 |

In the above example, we see an address marked by the number `08`, which indicates that the address we are looking for is in the ROM. The number `123456` indicates that the data we are looking for in the ROM can be found 123456 bytes from the beginning of the ROM region. Each region in the memory is mapped using a specific number:

| Prefix | Region  |
|--------|---------|
| 08-09  | ROM     |
| 02     | EWRAM   |
| 03     | IWRAM   |
| 05     | Palettes|

A more complete list can be found on GBATEK.

Each block of memory is accessed via an *Address Bus*. The bus is simply a connection which allows data to travel to (and from) the block of memory. The width of the address bus dictates how much data can travel over that bus at any given time. For example, the ROM's address bus is 16 bits wide. This means that only 16 bits can travel over the bus at any time. It is possible to read 32 bits (and more) from the ROM, however it requires 2 (or more) trips across the bus to get that.
You might've heard that there are two types of instruction set on the GBA. THUMB and ARM, and that THUMB is faster. Well there is your reason. THUMB is "faster" because it uses 16 bit per instruction, whereas ARM uses 32 bits. In order to read a single ARM instruction from the ROM, you must take two trips across the bus before you can execute it. THUMB only takes one trip, thus executing THUMB from the ROM is faster than executing ARM.
If you were to copy ARM code over to block of RAM with a 32 bit bus, it would be just as fast.
You may be wondering about the difference between the IWRAM (Internal Work RAM) and the EWRAM (External Work RAM) in the table above. The IWRAM has a 32 bit address bus, while the EWRAM has a 16 bit address bus. While the EWRAM is bigger, the IWRAM provides faster 32 bit reads (and is faster in general). Data that is accessed often and 32 bit data (like pointers) are often stored in the IWRAM, while other data is stored in EWRAM. 

## Chapter 2: The CPU

### Architecture
The CPU in the GBA is called the ARM7TDMI. ARM7 refers to the series of chips and TDMI are names given to the features supported by this chip. For example, the 'T' indicates that this chip supports THUMB mode. The ARM7TDMI implements the ARMv4 instruction set and supports two versions of the instruction set. The 32 bit ARM instruction set and the 16 bit THUMB instruction set. An instruction set is the list of operations that a CPU can perform. Each instruction is represented by an *opcode* which has various *operands* which control the functioning of the opcode. Opcodes are difficult for humans to understand and thus are mapped to letter sequences called *mnemonics* which are easier for humans to remember, read and write. THUMB is often the preferred instruction set, as the GBA Gamepak only has a 16 bit address bus, this means only 16 bits can be read in one go from the ROM - this makes THUMB execute faster.

### Registers
Registers are small data containers which can be directly accessed and manipulated by the CPU at high speed. In order to manipulate data, a CPU must load data from memory into a register. Once in a register, data can be freely manipulated and then compared, or it may be stored in memory again to be accessed later. In the ARM7TDMI, registers are numbered `r0` through `r15`, the last 3 typically having special meaning. Each register is 32 bits or 4 bytes in size. The registers are divided: `r8` through `r15` being *high registers* and `r0` through `r7` being *low registers*. THUMB mode is mostly limited to using the low registers; high registers can only be handled by a select few opcodes.

### Words and Data Sizes
A *word* is the name given the to the unit of data that the CPU process in one go, i.e. the size of a register. On the ARM7TDMI, we have a 32 bit word. A Halfword is thus 16 bits. In addition to this, we have the byte, which is 8 bits.

### Special Registers
We have three special registers in THUMB:
1. `r13` - Stack Pointer (`SP`)
2. `r14` - Link Register (`LR`)
3. `r15` - Program Counter (`PC`)

#### Program Counter
Perhaps the easiest to understand, the Program Counter keeps track of the current instruction to be executed. This value, if read by code, is often a few opcodes ahead due to prefetch. However, if theory it should be the address of the current instruction. PC, like most of the special registers, is rarely modified directly. It is automatically updated by the processor every opcode as well as being modified by branching instructions.

#### Stack Pointer
The stack pointer is the key element with which we access the stack. The stack is an incredibly simple data structure which allows arbitrary data storage. It is most commonly used as a way to 'back up' registers at the start of a subroutine. The stack is often a huge source of confusion for newbies, who have many misconceptions about reasons for its use.

The stack is known as a LIFO (Last in, First out) data structure. This simply means that the last item to be added to the stack is the first item to leave it. Imagine this as a pile of books, when you add a book to the pile, you simply place it on the top. When removing a book, we take the top book off - we can't take something off the bottom lest pile collapse. The topmost book would be the last (most recent ) book we added, while the bottom would have been the first to be added. Thus, the pile is a LIFO structure.

The stack contains words (just like books - look how far my analogy extends!). However, all we know about the stack is the location of the most recent item - this is the stack pointer. The stack pointer must thus be a multiple of 4. This ensures the stack is properly aligned. Alignment is critical to preserve the data on the stack. The reason the stack can be used for generic data storage is because the stack stores data indiscriminately (as long as it is word aligned). The stack does not care where the data came from, or what you do with it, just so long as you keep it aligned. This is a common source of confusion for newbies who assume (due to the syntax of push and pop), that the stack "remembers" what registers you added to it. It does not - it only remembers the values they contain. The order in which you add to and remove from the stack is thus critical.

Keep in mind the stack pointer is just some arbitrary memory address (it actually starts at a fixed location, but it is impossible to keep track of once it starts growing). It only points to a value. The pointer just tells us where to find the data on the stack. You actually have to go there and read it from the location to see what is actually there. A common misconception is that the stack contains registers or is somehow tied to registers. This is incorrect. The registers are just a container for data, and are independent of that data. When storing a value on the stack, you're doing just that: storing a value. You are in no way storing the register. If you picture the register as a box, storing on the stack would be taking a book out the box and putting on the pile of books. You don't know which box that book came from, or indeed, that it even came from a box. You could just as easily take that book off the stack and put it in another box. It doesn't matter. The important thing to remember is that the data is independent of its container, whether it be on the stack or in a register.

Luckily, push and pop work in a very specific order to minimize the work you have to do to preserve register values.
The fact that the stack does not care where the data came from makes it useful for a number of things. We can use it to swap the value of registers without using another. For example,
```
mov r0, #3
mov r1, #1

push {r0}
mov r0, r1
pop {r1} ; not a typo
```
This code swaps the values of `r0` and `r1` simply by putting the value of `r0` on the stack, then copying `r1` onto `r0`. It then removes the value that was on `r0` but places it on `r1` instead. This might be thoroughly confusing, so here is another, step by step explanation. 

1. First we set the values of `r0` and `r1` using `MOV`. This is just setting up the example.
2. Next, we back up the value of r0 on the stack
3. `mov r0, r1` **copies*** r1 onto r0. At this point the original value of r0 is lost. This is half of the swap.
4. Now, we get the original value of r0 back. Instead of restoring it back onto r0 (this would put us back where we started), we pop it onto r1. 
5. The swap is now complete: `r1` is now 3 and `r0` is now 1.

Push and pop are very useful, however they can be a bit confusing since a lot of their operation is hidden. Whenever we push, we simply decrement the stack pointer by 4, and then store the value of the register at the new pointer. Pop is the reverse: we increment the stack pointer by 4 and then read the value at the new pointer. Thus, we have rough equivalents,
```
@ push {r0} equivalent
sub sp, #4
str r0, [sp]

@ pop {r0} equivalent
add sp, #4
ldr r0, [sp]
```

The stack grows downwards by convention, thus we subtract from `SP` when adding to the stack, and add to it when removing. Thus, smaller values of `SP` indicate a larger stack and vice versa.

The stack does have a storage limit - when we run out of space on the stack it is called *Stack Overflow*. This type of error is commonly seen in recursive functions which recurse too many times.

#### Link Register
Link register is used to keep track of the return location when calling subroutines. Whenever a `BL` instruction is encountered, LR is automatically set to PC + 4. Since BL is 4 bytes long (even in THUMB), PC + 4 is the next instruction. When the subroutine is done execution, it returns execution back to the calling routine by setting PC = LR. This is done in a number of ways:

If we have not pushed LR, we can return with the following code,
```
bx lr
```
However, if we had a nested subroutine and needed to save LR on the stack, the following code is often seen,
```
pop {r0}
bx r0
```
This code is used when ARM-THUMB interworking is desired and there is no return value. Since `BX` is the only way to return to ARM code from THUMB code (and vice versa), we must return using this opcode in order to set the correct mode of execution. If there is a return value, then `r1` is simply used instead. 

If ARM-THUMB interworking is not necessary, then we can return with
```
mov pc, lr
```

or 

```
pop {pc}
```

Which are equivalent to the respective snippets above. These instructions will cause the code returned to to be executed in the same mode as the code however.

## Chapter 3: Control Flow

### Subroutines
Subroutines are the basic unit of computation in a program. They are a sequence of instructions to executed and are analogous to a function in C. Since most GBA games are programmed in C, it can be helpful to think of the code in terms of a collection of functions. The GBA is a single threaded, so no two functions are executed in parallel. When viewing code in a typical GBA game, almost all code belongs to a subroutine.

Subroutines can take arguments, which generally modify the operation of a function, and can return a value, which is the output of a function. Some functions will also modify the external environment by setting RAM addresses. These are known as *impure functions*. Functions that only use their input arguments and return a value are known as *pure functions*.

### Calling Convention
Since there are a number of ways arguments can be supplied to a function, and a number of ways values could be returned, we need to establish a *calling convention* which describes how functions do these tasks. The only important thing about a convention is that it is consistent, i.e. it is used everywhere. This is important, since a program might use code that it does have the source code of. Without a convention in place, code consuming that compiled code would be unable to pass arguments or read a return value.

There are many possible calling conventions, but the typical one we see in ARM code is:

- Arguments are passed in registers `R0`-`R3`
- Any arguments beyond that are to be passed on the stack
- Return values are sent back in r0
- Registers `R4`-`R11` and `SP` must be preserved by a function
- Functions return to the address in `LR`, i.e. they set `PC` to `LR` after completing.

This is the standard calling convention for all 32 bit ARM code. More about this convention and other calling conventions in general can be found on the [Wikipedia page](https://en.wikipedia.org/wiki/Calling_convention#ARM_.28A32.29).

Because we expect parameters to be contained in `R0` to `R3`, we do not need to push them to the stack when calling a function. Any routine calling a function in the ARM convention must expect `R0` to `R3` to hold different values coming out of a function than they had going in. A typical function in ARM will look like

````
push {r4-r5, lr}
bl some_other_function
pop {r4-r5}
pop {r1}
bx r1
````

It can also take the form,

````
push {r4-r5, lr}
bl some_other_function
pop {r4-r5, pc}
````

The latter case is when ARM-THUMB inter-working is not required. Please see the Branch and Exchange section for more information about this.

### Comparisons

In order to make decisions, a CPU has to be able to compare two values together. In ARMv4, this is done with the compare instruction, `CMP` (or the compare negative instruction, `CMN`). With this instruction, you can compare two registers and move to a different area of code based on the result of this comparison. Compare by itself does nothing, and needs to be followed by a branch instruction in order to have any effect.

### Branches

Branches allow you to move to another area of code. There are four classes of branch that will be discussed, starting with the simplest

#### Unconditional Branch

The unconditional branch instruction `B` simply increments PC. In assembly, you typically provide a label and then it will calculate the distance to jump upon assembling the code. This is deceptive as it creates the illusion that you can jump an arbitrary distance backwards or forwards. Rather, the unconditional branch function is limited to a distance of 2048 bytes backwards and 2046 bytes forwards. The unconditional branch is typically used to jump over blocks of data in a routine or provide a fall-through case for a condition, such as looping.

#### Conditional Branching

The conditional branch is more obviously useful. These typically (not always) follow a compare instruction and will jump when the condition is true. For example,

````
cmp r0, r1
beq some_place
````

This code will jump to the label `some_place` when r0 and r1 are equal because of the Branch if Equal instruction `BEQ`.

See [GBATEK](http://problemkaputt.de/gbatek.htm#thumbopcodesjumpsandcalls) for more conditional branches.

A conditional branch can only jump 128 instructions backwards or 127 instructions forwards. The perceptive among you will notice that that is the range of a signed byte. That is because the opcodes for conditional branches only contain 8 bits for the offset of the branch.

#### Branch with Link

Functions must return to their calling functions after they finish. As discussed above, the return location for a function is stored in `LR`. How does this register get set? When calling a function, we use a special instruction `BL` (Branch with Link). This function sets `LR` to the address of the instruction proceeding it, or more succinctly,

````
LR = PC + 4
````

Why plus four? Aren't instructions in THUMB 16 bits long? Well `BL` is the exception to this rule. It is the only instruction which occupies 4 bytes. Thus the address for the instruction after the `BL` would be four bytes after the value in `PC`. Because `BL` sets `LR`, the function is calls knows where to jump back to when it is finished doing its work. As shown in the calling convention, functions must return to this address themselves.

`BL` takes 4 bytes to allow an increased range, however it is not limitless. It has a range of 22 bits, so it can be 0x400000 bytes back, or 0x3FFFFE bytes forward. 

#### Branch and Exchange

The last branch type in ARMv4 is called *B*ranch and E*x*change or `BX`. This branch is the only one to have an unlimited range, and the only one to allow a register. All the other branches are relative and thus require a distance or a label.

The "exchange" part of this branch means that it change switch between ARM and THUMB code. This can *only* happen with this instruction. All other branches, as well as direct modification of `PC` will assume the target code is in THUMB mode.

We saw an example of a function earlier,

````
push {r4-r5, lr}
bl some_other_function
pop {r4-r5}
pop {r1}
bx r1
````

The reason for the `BX` is now clear: This function allows you to return to ARM code, thus it can be called from either ARM or THUMB code and it will work as expected.

If you are calling a function using an address in a register, such as

````
ldr r0, some_address
bx r0
````

You must specify whether that address is in ARM mode or in THUMB mode. Since THUMB mode is 2 bytes per instruction and ARM is 4, both modes must be on an even address. Even addresses have the property that the right-most bit is *always* zero. Thus, we can use that bit to indicate ARM or THUMB mode. When calling THUMB mode, we make the address odd, thus THUMB routines called with BX are always the address of the function plus one.

#### Long Branch with Link

What happens if we want to combine the unlimited range of `BX` with the function calling capabilities of `BL`? ARMv5 and above contain an extra branching instruction `BLX`. This works exactly like `BX`, except it sets `LR`. However, since the GBA uses ARMv4, we don't have access to this instruction. Therefore, you'll see a common hack in assembly code to do this.

````
@ Some code
ldr r0, some_function
bl linker
@ Rest of my code - function will return here

linker:
bx r0
````

This hack preloads the function address, then uses `BL` to set the `LR` to the location directly after it. The `BL` then calls our `linker` function, which just branches to the function address we preloaded. The function will then return to the code after the `BL`. This is a common pattern seen in hackers' ASM code. It allows us to overcome the range limitation of `BL` and call built-in functions from free space. You will also see this pattern in game code when the address of the function being called is only known at run time.

### CPSR

The CPSR stands for Current Program Status Register, and is terribly under-utilised by most hackers, but is responsible for controlling the operation conditional branches. In ARMv4, this register (it is separate from the standard 16) contains four flags: Zero (Z), Overflow (V), Sign (N) and Carry (C). Most instructions will set one or more of these flags. Compare sets them all. Each conditonal branch checks one or more of these flags and acts accordingly. See GBATEK for more.

Most hackers have no understanding of how `CMP` works. The process is simple. It simply subtracts the two registers and sets the flags based on the result:

- Zero: When the result of the subtraction is zero, this flag is set. Otherwise it is cleared. `BEQ` checks if Z is set because the only time that `a - b = 0` is when `a = b`.

- Sign: When the result is negative, this is set, otherwise it is cleared. `BMI` (Branch if minus) checks if N is set, because that would mean the result is negative

- Carry: When the right hand side of the subtraction is bigger than the left, you must carry (think basic arithmetic: you have to "carry" the value when subtracting 16 from 15). This is used to compare unsigned numbers. `BHI` (Branch if higher) checks if C is set, because that would mean the right hand side of the subtraction is higher. It also checks Z = 0, because that would indicate equality.

- Overflow: Overflow is similar to carry, but for signed numbers. When the subtraction causes the register to "overflow", it is set. `BGT` (branch greater than) checks if V=N because overflow checks if the sign changed. If the changed sign matches the result sign, the right hand side of the compare is larger (signed).

The differences between Overflow and Carry are confusing. For a great explanation on this, see [this page](http://teaching.idallen.com/dat2343/10f/notes/040_overflow.txt).

## Next Steps and Further Reading

The internet is a fantastic resource for learning. Check out some of the ASM tutorials on The Pokecommunity, Read [GBATEK](http://problemkaputt.de/gbatek.htm), Check out [tonc](http://coranac.com/tonc/text/) for some C programming for the GBA (C is incredibly helpful to learn). Find yourself a copy of IDA Pro and use the [IDBs](http://caveoforig.in/?m=proj) to view the ROM code. I might cover some IDA disassembly in a later version of this document.
