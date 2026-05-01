.section .data

msg_id_titulo:  .asciz "\n══ MATRIZ IDENTIDAD ══════════════════\n"
msg_id_original:.asciz "Matriz original:\n"
msg_id_result:  .asciz "\nMatriz identidad resultante:\n"
msg_id_error:   .asciz "\n[ERROR] La matriz debe ser cuadrada (filas == columnas)\n"
msg_id_proceso: .asciz "\nProceso: poniendo 1 en diagonal, 0 en el resto...\n"

//199812349 Edy Donaldo López Anavizca


.section .text
.extern print_str
.extern imprimir_matriz


// ================================================================
//  calcular_identidad
//  Transforma la matriz en su identidad equivalente.
//  Entrada: x0=filas, x1=cols, x2=ptr
// ================================================================
.global calcular_identidad
calcular_identidad:
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]

    mov     x19, x0             // filas
    mov     x20, x1             // cols
    mov     x21, x2             // ptr base

    // ── Mostrar título ───────────────────────────────────────
    ldr     x0, =msg_id_titulo
    bl      print_str

    // ── Verificar que sea cuadrada ───────────────────────────
    cmp     x19, x20
    b.ne    .Lid_error

    // ── Mostrar matriz original antes de transformar ─────────
    ldr     x0, =msg_id_original
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    ldr     x0, =msg_id_proceso
    bl      print_str

    // ── Recorrer toda la matriz y asignar 0 o 1 ─────────────
    //    A[i][j] = 1 si i == j  (diagonal principal)
    //    A[i][j] = 0 si i != j
    mov     x22, #0             // i = 0

.Lid_loop_i:
    cmp     x22, x19
    b.ge    .Lid_mostrar

    mov     x23, #0             // j = 0

.Lid_loop_j:
    cmp     x23, x20
    b.ge    .Lid_sig_fila

    // Calcular offset: (i * cols + j) * 8
    mul     x24, x22, x20       // i * cols
    add     x24, x24, x23       // + j
    lsl     x24, x24, #3        // × 8

    // Decidir valor: 1 si i==j, 0 si i!=j
    cmp     x22, x23
    b.eq    .Lid_poner_uno
    mov     x25, #0
    b       .Lid_guardar
.Lid_poner_uno:
    mov     x25, #1

.Lid_guardar:
    str     x25, [x21, x24]     // guardar en A[i][j]

    add     x23, x23, #1        // j++
    b       .Lid_loop_j

.Lid_sig_fila:
    add     x22, x22, #1        // i++
    b       .Lid_loop_i

.Lid_mostrar:
    // ── Mostrar resultado ────────────────────────────────────
    ldr     x0, =msg_id_result
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz
    b       .Lid_fin

.Lid_error:
    ldr     x0, =msg_id_error
    bl      print_str

.Lid_fin:
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret