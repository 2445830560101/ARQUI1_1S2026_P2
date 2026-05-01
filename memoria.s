.global malloc_sized
malloc_sized:
    stp     x29, x30, [sp, #-32]!
    mov     x29, sp
    str     x19, [sp, #16]
    mov     x19, x0             // size en bytes
    add     x0,x0,#8
    mov     x1, x0
    mov     x0, #0
    mov     x2, #3
    mov     x3, #0x22
    mov     x4, #-1
    mov     x5, #0
    mov     x8, #222
    svc     #0           // flags = 0

    cmp     x0, #0
    b.ne    .Lmalloc_error


    str     x19,[x0]
    add     x0,x0,#8
    b       .Lmalloc_done
.Lmalloc_error:
    mov     x0, #0
.Lmalloc_done:
    ldr     x19, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret  
.global free_sized
free_sized:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    cbz     x0, .Lfree_sized_done

    // Obtener puntero original (header está 8 bytes antes)
    sub     x0, x0, #8

    // Obtener tamaño
    ldr     x1, [x0]            // tamaño original
    add     x1, x1, #8          // + tamaño del header

    // syscall munmap(addr, size)
    mov     x8, #215
    svc     #0

.Lfree_sized_done:
    ldp     x29, x30, [sp], #16
    ret    