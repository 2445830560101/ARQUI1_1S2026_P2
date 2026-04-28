.section .data

msg_tr_titulo:  .asciz "\n══ MATRIZ TRANSPUESTA ════════════════\n"
msg_tr_orig:    .asciz "Matriz original A:\n"
msg_tr_result:  .asciz "\nMatriz transpuesta A^T:\n"
msg_tr_proceso: .asciz "\nIntercambiando filas por columnas...\n"


.section .text
.extern print_str
.extern imprimir_matriz

.global calcular_transpuesta
calcular_transpuesta:
    stp     x29, x30, [sp, #-64]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]

    mov     x19, x0             // filas_A  (= cols de A^T)
    mov     x20, x1             // cols_A   (= filas de A^T)
    mov     x21, x2             // ptr_A

    // ── Título y mostrar original ────────────────────────────
    ldr     x0, =msg_tr_titulo
    bl      print_str
    ldr     x0, =msg_tr_orig
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    ldr     x0, =msg_tr_proceso
    bl      print_str

    // ── Reservar memoria para A^T: cols_A × filas_A × 8 bytes
    //    A^T tiene dimensiones: cols_A (filas) × filas_A (cols)
    mul     x1, x19, x20        // total elementos = mismo que A
    lsl     x1, x1, #3          // × 8 bytes
    mov     x0, #0
    mov     x2, #3              // PROT_READ|PROT_WRITE
    mov     x3, #0x22           // MAP_PRIVATE|MAP_ANONYMOUS
    mov     x4, #-1
    mov     x5, #0
    mov     x8, #222            // mmap
    svc     #0
    mov     x22, x0             // x22 = ptr a A^T

    // ── Construir A^T[i][j] = A[j][i] ───────────────────────
    //    Iterar i de 0 a cols_A-1 (filas de A^T)
    //    Iterar j de 0 a filas_A-1 (cols de A^T)

    mov     x23, #0             // i = 0 (fila de A^T)
.Ltr_loop_i:
    cmp     x23, x20            // i < cols_A?
    b.ge    .Ltr_mostrar

    mov     x24, #0             // j = 0 (col de A^T)
.Ltr_loop_j:
    cmp     x24, x19            // j < filas_A?
    b.ge    .Ltr_sig_i

    // Leer A[j][i]:  offset = (j * cols_A + i) * 8
    mul     x25, x24, x20       // j * cols_A
    add     x25, x25, x23       // + i
    lsl     x25, x25, #3
    ldr     x26, [x21, x25]     // valor = A[j][i]

    // Escribir A^T[i][j]:  offset = (i * filas_A + j) * 8
    mul     x25, x23, x19       // i * filas_A
    add     x25, x25, x24       // + j
    lsl     x25, x25, #3
    str     x26, [x22, x25]     // A^T[i][j] = valor

    add     x24, x24, #1        // j++
    b       .Ltr_loop_j

.Ltr_sig_i:
    add     x23, x23, #1        // i++
    b       .Ltr_loop_i

.Ltr_mostrar:
    // ── Mostrar A^T ─────────────────────────────────────────
    // Dimensiones de A^T: filas = cols_A (x20), cols = filas_A (x19)
    ldr     x0, =msg_tr_result
    bl      print_str
    mov     x0, x20             // filas de A^T = cols originales
    mov     x1, x19             // cols de A^T = filas originales
    mov     x2, x22             // ptr A^T
    bl      imprimir_matriz

    ldp     x23, x24, [sp, #48]
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #64
    ret