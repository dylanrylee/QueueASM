define(QUEUESIZE, 8)                                    // these are defining macros
define(MODMASK, 0x7)
define(FALSE, 0)
define(TRUE, 1)

fp      .req    x29                                     // these are for better readability
lr      .req    x30

                .bss                                    // allocates in the bss section
                .balign 4
                .global queue_m                         // makes this variable global
queue_m:        .skip   QUEUESIZE * 4

                .data                                   // allocates in the data section
                .balign 4
                .global head_m                          // makes this variable global
head_m:         .word   -1

                .data                                   // allocates in the data section
                .balign 4
                .global tail_m                          // makes this variable global
tail_m:         .word   -1

                .text
                .balign 4
enqueuefmt1:    .string "\nQueue overflow! Cannot enqueue into a full queue.\n"
dequeuefmt1:    .string "\nQueue underflow! Cannot dequeue from an empty queue.\n"
displayfmt1:    .string "\nEmpty queue\n"
displayfmt2:    .string "\nCurrent queue contents:\n"
displayfmt3:    .string "  %d"
displayfmt4:    .string " <-- head of queue"
displayfmt5:    .string " <-- tail of queue"
displayfmt6:    .string "\n"
enqueueError:   .string "\nError: Enter a Positive Number.\n"

                .text                                   // this allocates in the text section
                .balign 4
                .global enqueue                         // makes this function global
enqueue:        stp     fp, lr, [sp, -16]!
                mov     fp, sp

                mov     w9, w0                          // w9 = value = w0
                cmp     w9, 0                           // this compares w9 and 0
                b.ge    enqif1                          // if it is not negative, then proceed
                ldr     x0, =enqueueError               // loads x0 with the enqueueError string
                bl      printf                          // jumps to printf
                b       enqret                          // jumps to the return

        enqif1: bl      queueFull                       // jumps to queueFull
                mov     w10, w0                         // moves the returned value from queueFull to w10
                cmp     w10, TRUE                       // compares w10 and TRUE
                b.ne    enqb1                           // if w10 != TRUE, then jump to enqb1
                ldr     x0, =enqueuefmt1                // loads x0 with the enqueuefmt1 string
                bl      printf                          // jumps to printf function
                b       enqret                          // jumps to the return

        enqb1:  adrp    x19, head_m                     // calculates the base address
                add     x19, x19, :lo12:head_m
                ldr     w20, [x19]                      // w20 = head
                adrp    x19, tail_m
                add     x19, x19, :lo12:tail_m
                ldr     w21, [x19]                      // w21 = tail

        enqif2: bl      queueEmpty                      // this jumps to queueEmpty
                mov     w10, w0                         // this moves the returned value from queueEmpty to w10
                cmp     w10, TRUE                       // this compares w10 and TRUE
                b.ne    enqel1                          // if w10 != TRUE, then jump to enqel1
                mov     w21, 0                          // w21 = tail = 0
                mov     w20, w21                        // w20 = head = w21 = tail = 0
                b       enqb2                           // this jumps to enqb2

        enqel1: add     w21, w21, 1                     // incrementing tail
                and     w21, w21, MODMASK               // tail = w21 = w21 & MODMASK

        enqb2:  adrp    x19, head_m
                add     x19, x19, :lo12:head_m
                str     w20, [x19]                      // storing head back
                adrp    x19, tail_m
                add     x19, x19, :lo12:tail_m
                str     w21, [x19]                      // storing tail back
                adrp    x11, queue_m
                add     x11, x11, :lo12:queue_m
                str     w9, [x11, w21, SXTW 2]          // queue[tail] = value


        enqret: ldp     fp, lr, [sp], 16
                ret

                .global dequeue                         // this makes the dequeue function global
dequeue:        stp     fp, lr, [sp, -16]!
                mov     fp, sp

                mov     w24, 0                          // register int value

        deqif1: bl      queueEmpty                      // this jumps to the queueEmpty function
                mov     w9, w0                          // this stores the ret value from queueEmpty to w10
                cmp     w9, TRUE                        // this compares w10 and TRUE
                b.ne    deqb1                           // if w10 != TRUE, then jump to deqb1
                ldr     x0, =dequeuefmt1                // this is the argument for printing
                bl      printf                          // this jumps to the printf function
                mov     w0, -1                          // this stores -1 in w0
                b       deqret                          // this goes to deqret to return w0 = -1

        deqb1:  adrp    x19, head_m
                add     x19, x19, :lo12:head_m
                ldr     w20, [x19]                      // w20 = head
                adrp    x11, queue_m
                add     x11, x11, :lo12:queue_m
                ldr     w24, [x11, w20, SXTW 2]         // value = queue[head]

        deqif2: adrp    x19, tail_m
                add     x19, x19, :lo12:tail_m
                ldr     w21, [x19]                      // w21 = tail
                cmp     w20, w21
                b.ne    deqel1
                mov     w21, -1                         // w21 = tail = -1
                mov     w20, w21                        // w20 = head = w21 = tail = -1
                b       deqb2                           // this jumps to the deqb2

        deqel1: add     w20, w20, 1                     // ++head
                and     w20, w20, MODMASK               // head = ++head & MODMASK

        deqb2:  adrp    x19, head_m
                add     x19, x19, :lo12:head_m
                str     w20, [x19]                      // storing head back
                adrp    x19, tail_m
                add     x19, x19, :lo12:tail_m
                str     w21, [x19]                      // storing tail back

                mov     w0, w24                         // moving the int value into w0 for return

        deqret: ldp     fp, lr, [sp], 16
                ret

                .global queueFull                       // this makes queueFull function global
queueFull:      stp     fp, lr, [sp, -16]!
                mov     fp, sp

                adrp    x19, head_m
                add     x19, x19, :lo12:head_m
                ldr     w20, [x19]                      // w20 = head
                adrp    x19, tail_m
                add     x19, x19, :lo12:tail_m
                ldr     w21, [x19]                      // w21 = tail

                add     w22, w21, 1                     // w22 = tail + 1
                and     w22, w22, MODMASK               // w22 = w22 & MODMASK = (tail + 1) & MODMASK
                cmp     w22, w20
                b.ne    fulel1
                mov     w0, TRUE                        // w0 = TRUE
                b       fulret

        fulel1: mov     w0, FALSE                       // w0 = FALSE

        fulret: ldp     fp, lr, [sp], 16
                ret

                .global queueEmpty
queueEmpty:     stp     fp, lr, [sp, -16]!
                mov     fp, sp

                adrp    x19, head_m
                add     x19, x19, :lo12:head_m
                ldr     w20, [x19]                      // w20 = head

        empif1: cmp     w20, -1                         // compares w20 to -1
                b.ne    empel1                          // if head != -1, then jump to empel1
                mov     w0, TRUE                        // this moves TRUE to w0 for return
                b       empret                          // this jumps to empret

        empel1: mov     w0, FALSE                       // this moves FALSE to w0 for return

        empret: ldp     fp, lr, [sp], 16
                ret

                .global display                         // this turns display function global
display:        stp     fp, lr, [sp, -16]!
                mov     fp, sp

                adrp    x19, head_m
                add     x19, x19, :lo12:head_m
                ldr     w20, [x19]                      // w20 = head
                adrp    x19, tail_m
                add     x19, x19, :lo12:tail_m
                ldr     w21, [x19]                      // w21 = tail

                mov     w22, 0                          // w22 = register int i
                mov     w23, 0                          // w23 = register int j
                mov     w24, 0                          // w24 = register int count

        disif1: bl      queueEmpty                      // this jumps to queueEmpty
                mov     w9, w0                          // this stores the returned value from queueEmpty to w9
                cmp     w9, TRUE                        // this compares w9 and TRUE
                b.ne    disb1                           // if w9 != TRUE, jump to disb1
                ldr     x0, =displayfmt1                // this loads x0 with displayfmt1 string
                bl      printf                          // this jumps to the printf function
                b       disret                          // this jumps to the return

        disb1:  sub     w24, w21, w20                   // w24 = count = tail - head
                add     w24, w24, 1                     // w24 = count = tail - head + 1

        disif2: cmp     w24, 0
                b.gt    disb2
                add     w24, w24, QUEUESIZE             // w24 = count += QUEUESIZE

        disb2:  ldr     x0, =displayfmt2                // x0 is loaded with the displayfmt2 string
                bl      printf                          // jumps to the printf function
                mov     w22, w20                        // w22 = i = w20 = head
                b       looptst                         // this jumps to the looptst

        loop:   adrp    x11, queue_m
                add     x11, x11, :lo12:queue_m
                ldr     x0, =displayfmt3                // x0 is loaded with displayfmt3 string
                ldr     w1, [x11, w22, SXTW 2]          // w1 = queue[i]
                bl      printf

        disif3: cmp     w22, w20                        // this compares i and the head
                b.ne    disif4                          // if i != head, jump to disif4
                ldr     x0, =displayfmt4                // loads x0 with the displayfmt4 string
                bl      printf                          // this jumps to the printf function

        disif4: cmp     w22, w21                        // this compares i and the tail
                b.ne    disb3                           // if i != tail, jump to disb3
                ldr     x0, =displayfmt5                // loads x0 with displayfmt5 string
                bl      printf

        disb3:  ldr     x0, =displayfmt6                // loads x0 with displayfmt6 string
                bl      printf                          // jumps to the printf function
                add     w22, w22, 1                     // increments register int i by 1
                and     w22, w22, MODMASK               // i = ++1 & MODMASK

                add     w23, w23, 1                     // w23 = j++

        looptst:cmp     w23, w24                        // compares int j to int count
                b.lt    loop                            // this jumps back to the top of the loop

        disret: ldp     fp, lr, [sp], 16
                ret
