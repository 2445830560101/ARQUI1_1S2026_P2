.section .data

msg_gs_titulo:  .asciz "\n══ MÉTODO DE GAUSS ═══════════════════\n"
msg_gs_orig:    .asciz "Matriz original:\n"
msg_gs_result:  .asciz "\n[INFO] Método de Gauss no implementado para este tamaño aún.\n"


.section .text
.extern print_str
.extern imprimir_matriz

.global calcular_gauss
calcular_gauss:
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]

    mov     x19, x0
    mov     x20, x1
    mov     x21, x2

    ldr     x0, =msg_gs_titulo
    bl      print_str
    ldr     x0, =msg_gs_orig
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    ldr     x0, =msg_gs_result
    bl      print_str

    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret