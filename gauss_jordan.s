.section .data
//199812349 Edy Donaldo López Anavizca
msg_gj_titulo:  .asciz "\n══ GAUSS-JORDAN (RREF) ═══════════════\n"
msg_gj_orig:    .asciz "Matriz original:\n"
msg_gj_result:  .asciz "\nForma reducida por filas (resultado):\n"
msg_gj_info:    .asciz "\n[INFO] Gauss-Jordan simplificado (solo muestra matriz original)\n"


.section .text
.extern print_str
.extern imprimir_matriz

.global calcular_gauss_jordan
calcular_gauss_jordan:
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]

    mov     x19, x0
    mov     x20, x1
    mov     x21, x2

    ldr     x0, =msg_gj_titulo
    bl      print_str
    ldr     x0, =msg_gj_orig
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // Versión simplificada - solo muestra mensaje
    ldr     x0, =msg_gj_info
    bl      print_str

    ldr     x0, =msg_gj_result
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret


