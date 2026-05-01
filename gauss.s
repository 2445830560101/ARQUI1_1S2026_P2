.section .data
//199812349 Edy Donaldo López Anavizca
msg_gs_titulo:  .asciz "\n══ MÉTODO DE GAUSS ═══════════════════\n"
msg_gs_orig:    .asciz "Matriz original:\n"
msg_gs_result:  .asciz "\nMatriz triangular superior:\n"
msg_gs_step:    .asciz "\nPaso "
msg_gs_colon:   .asciz ":\n"

.section .text
.extern print_str
.extern imprimir_matriz
.extern print_int

.global calcular_gauss
calcular_gauss:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]

    mov x19, x0             // n
    mov x20, x1             // m
    mov x21, x2             // ptr

    ldr x0, =msg_gs_titulo
    bl print_str
    ldr x0, =msg_gs_orig
    bl print_str
    mov x0, x19
    mov x1, x20
    mov x2, x21
    bl imprimir_matriz

    // Gauss elimination
    mov x22, #0             // columna/fila pivote
    
.Lgauss_col:
    cmp x22, x19
    b.ge .Lgauss_done
    cmp x22, x20
    b.ge .Lgauss_done
    
    // Buscar pivote no cero
    mov x23, x22
.Lgauss_find:
    cmp x23, x19
    b.ge .Lgauss_error
    
    mul x24, x23, x20
    add x24, x24, x22
    lsl x24, x24, #3
    ldr x25, [x21, x24]
    cbnz x25, .Lgauss_found
    add x23, x23, #1
    b .Lgauss_find

.Lgauss_found:
    // Intercambiar filas si es necesario
    cmp x23, x22
    b.eq .Lgauss_elim
    
    // Intercambiar fila x22 y x23
    mov x24, #0
.Lgauss_swap:
    cmp x24, x20
    b.ge .Lgauss_elim
    
    mul x25, x22, x20
    add x25, x25, x24
    lsl x25, x25, #3
    ldr x26, [x21, x25]
    
    mul x27, x23, x20
    add x27, x27, x24
    lsl x27, x27, #3
    ldr x28, [x21, x27]
    
    str x28, [x21, x25]
    str x26, [x21, x27]
    
    add x24, x24, #1
    b .Lgauss_swap

.Lgauss_elim:
    // Eliminar debajo del pivote
    mov x23, x22
    add x23, x23, #1
    
.Lgauss_elim_row:
    cmp x23, x19
    b.ge .Lgauss_next
    
    // Calcular factor = A[j][i] / A[i][i]
    mul x24, x22, x20
    add x24, x24, x22
    lsl x24, x24, #3
    ldr x25, [x21, x24]     // pivote
    
    mul x26, x23, x20
    add x26, x26, x22
    lsl x26, x26, #3
    ldr x27, [x21, x26]     // A[j][i]
    
    cbz x27, .Lgauss_next_row
    
    // Para cada columna k
    mov x9, x22
.Lgauss_elim_col:
    cmp x9, x20
    b.ge .Lgauss_next_row
    
    // A[j][k] = A[j][k] - (A[j][i] * A[i][k]) / pivote
    mul x10, x23, x20
    add x10, x10, x9
    lsl x10, x10, #3
    ldr x11, [x21, x10]     // A[j][k]
    
    mul x12, x22, x20
    add x12, x12, x9
    lsl x12, x12, #3
    ldr x13, [x21, x12]     // A[i][k]
    
    mul x14, x13, x27       // A[i][k] * A[j][i]
    sdiv x14, x14, x25      // / pivote
    sub x11, x11, x14
    
    str x11, [x21, x10]
    
    add x9, x9, #1
    b .Lgauss_elim_col

.Lgauss_next_row:
    add x23, x23, #1
    b .Lgauss_elim_row

.Lgauss_next:
    add x22, x22, #1
    b .Lgauss_col

.Lgauss_error:
    // Pivote no encontrado (matriz singular)
    // Continuar con siguiente columna
    add x22, x22, #1
    b .Lgauss_col

.Lgauss_done:
    ldr x0, =msg_gs_result
    bl print_str
    mov x0, x19
    mov x1, x20
    mov x2, x21
    bl imprimir_matriz

.Lgauss_fin:
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret



