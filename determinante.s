.section .data

msg_det_titulo: .asciz "\n══ DETERMINANTE ══════════════════════\n"
msg_det_error:  .asciz "\n[ERROR] La matriz debe ser cuadrada.\n"
msg_det_result: .asciz "\ndet(A) = "
msg_det_newline:.asciz "\n"


.section .text
.extern print_str
.extern print_int
.extern imprimir_matriz

.global calcular_determinante
calcular_determinante:
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]

    mov     x19, x0
    mov     x20, x1
    mov     x21, x2

    ldr     x0, =msg_det_titulo
    bl      print_str

    // Verificar cuadrada
    cmp     x19, x20
    b.ne    .Ldet_error

    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // ── Caso especial: 1×1 ──────────────────────────────────
    cmp     x19, #1
    b.ne    .Ldet_2x2
    ldr     x0, [x21]
    b       .Ldet_mostrar

.Ldet_2x2:
    // ── Caso especial: 2×2 ──────────────────────────────────
    cmp     x19, #2
    b.ne    .Ldet_nxn

    ldr     x0, [x21, #0]       // a = A[0][0]
    ldr     x1, [x21, #8]       // b = A[0][1]
    ldr     x2, [x21, #16]      // c = A[1][0]
    ldr     x3, [x21, #24]      // d = A[1][1]
    mul     x4, x0, x3          // a*d
    mul     x5, x1, x2          // b*c
    sub     x0, x4, x5          // det = a*d - b*c
    b       .Ldet_mostrar

.Ldet_nxn:
    // Por ahora, solo mostrar mensaje de que no está implementado
    ldr     x0, =msg_det_result
    bl      print_str
    mov     x0, #0
    bl      print_int
    ldr     x0, =msg_det_newline
    bl      print_str
    b       .Ldet_fin

.Ldet_mostrar:
    stp     x0, x0, [sp, #-16]!
    ldr     x1, =msg_det_result
    mov     x2, x0
    ldr     x0, =msg_det_result
    bl      print_str
    ldp     x0, x1, [sp], #16
    bl      print_int
    ldr     x0, =msg_det_newline
    bl      print_str
    b       .Ldet_fin

.Ldet_error:
    ldr     x0, =msg_det_error
    bl      print_str

.Ldet_fin:
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret