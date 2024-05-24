# Queue Data Structure in Assembly ARMv8-A
UofC CPSC 355 Assignment 5\\
This code is an implementation of the queue data structure but in Assembly ARMv8-A. 

## What I did/learned
- Understanding Subroutines: Developed proficiency in creating and utilizing subroutines in assembly language to encapsulate queue operations efficiently while using Vim.
- Parameter Passing: Learned how to effectively pass parameters to subroutines, enabling flexible and modular queue implementations.
- Separate Compilation: Mastered the technique of separate compilation in assembly, facilitating modular code development and easier maintenance of queue-related functions

### Here is how to compile:
```
vim a5aMain.c
vim a5a.asm
m4 a5a.asm > a5a.s
gcc -c a5aMain.c
as a5a.s -o sum.o
gcc a5aMain.o sum.o -o myprog
./myprog
```
### Here is a small demo:

https://github.com/dylanrylee/QueueASM/assets/109629195/a906f6ca-afec-4d08-9569-2397adb00db8

