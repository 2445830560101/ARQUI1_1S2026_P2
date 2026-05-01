.section .data
//199812349 Edy Donaldo López Anavizca
msg_ar_menu:
    .asciz "\n══ ARITMÉTICA DE MATRICES ════════════\n 1. Suma        (A + B)\n 2. Resta       (A - B)\n 3. Mult. punto (A ⊙ B)\n 4. Mult. cruz  (A × B)\n 5. División    (A / B)\n 6. Volver al menú principal\n══════════════════════════════════════\nOpción: "

msg_ar_ingresar_b: .asciz "\nIngrese la matriz B:\n"
msg_ar_dim_error:  .asciz "\n[ERROR] Dimensiones incompatibles para esta operación.\n"
msg_ar_resultado:  .asciz "\nResultado:\n"
msg_ar_div_cero:   .asciz "\n[ERROR] División por cero detectada.\n"

.section .text
.extern print_str
.extern read_int
.extern ingresar_matriz
.extern imprimir_matriz
.extern malloc

.global menu_aritmetica
menu_aritmetica:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    stp x9, x10, [sp, #96]
    
    // Guardar matriz A
    mov x19, x0             // filas_A
    mov x20, x1             // cols_A
    mov x21, x2             // ptr_A

.Lar_menu_loop:
    ldr x0, =msg_ar_menu
    bl print_str
    bl read_int
    mov x22, x0

    cmp x22, #6
    b.eq .Lar_fin

    // Ingresar matriz B
    ldr x0, =msg_ar_ingresar_b
    bl print_str
    bl ingresar_matriz
    mov x23, x0             // filas_B
    mov x24, x1             // cols_B
    mov x25, x2             // ptr_B

    cmp x22, #1
    b.eq .Lar_suma
    cmp x22, #2
    b.eq .Lar_resta
    cmp x22, #3
    b.eq .Lar_mult_punto
    cmp x22, #4
    b.eq .Lar_mult_cruz
    cmp x22, #5
    b.eq .Lar_division
    b .Lar_menu_loop

// ========== SUMA ==========
.Lar_suma:
    cmp x19, x23
    b.ne .Lar_dim_error
    cmp x20, x24
    b.ne .Lar_dim_error

    mul x0, x19, x20
    lsl x0, x0, #3
    bl malloc
    mov x26, x0
    cbz x26, .Lar_menu_loop

    mov x27, #0             // i
.Lar_suma_i:
    cmp x27, x19
    b.ge .Lar_suma_mostrar
    mov x28, #0             // j
.Lar_suma_j:
    cmp x28, x20
    b.ge .Lar_suma_next_i

    mul x9, x27, x20
    add x9, x9, x28
    lsl x9, x9, #3

    ldr x10, [x21, x9]
    ldr x11, [x25, x9]
    add x10, x10, x11
    str x10, [x26, x9]

    add x28, x28, #1
    b .Lar_suma_j
.Lar_suma_next_i:
    add x27, x27, #1
    b .Lar_suma_i

.Lar_suma_mostrar:
    ldr x0, =msg_ar_resultado
    bl print_str
    mov x0, x19
    mov x1, x20
    mov x2, x26
    bl imprimir_matriz
    b .Lar_menu_loop

// ========== RESTA ==========
.Lar_resta:
    cmp x19, x23
    b.ne .Lar_dim_error
    cmp x20, x24
    b.ne .Lar_dim_error

    mul x0, x19, x20
    lsl x0, x0, #3
    bl malloc
    mov x26, x0
    cbz x26, .Lar_menu_loop

    mov x27, #0
.Lar_resta_i:
    cmp x27, x19
    b.ge .Lar_resta_mostrar
    mov x28, #0
.Lar_resta_j:
    cmp x28, x20
    b.ge .Lar_resta_next_i
    mul x9, x27, x20
    add x9, x9, x28
    lsl x9, x9, #3
    ldr x10, [x21, x9]
    ldr x11, [x25, x9]
    sub x10, x10, x11
    str x10, [x26, x9]
    add x28, x28, #1
    b .Lar_resta_j
.Lar_resta_next_i:
    add x27, x27, #1
    b .Lar_resta_i

.Lar_resta_mostrar:
    ldr x0, =msg_ar_resultado
    bl print_str
    mov x0, x19
    mov x1, x20
    mov x2, x26
    bl imprimir_matriz
    b .Lar_menu_loop

// ========== MULTIPLICACIÓN PUNTO ==========
.Lar_mult_punto:
    cmp x19, x23
    b.ne .Lar_dim_error
    cmp x20, x24
    b.ne .Lar_dim_error

    mul x0, x19, x20
    lsl x0, x0, #3
    bl malloc
    mov x26, x0
    cbz x26, .Lar_menu_loop

    mov x27, #0
.Lar_punto_i:
    cmp x27, x19
    b.ge .Lar_punto_mostrar
    mov x28, #0
.Lar_punto_j:
    cmp x28, x20
    b.ge .Lar_punto_next_i
    mul x9, x27, x20
    add x9, x9, x28
    lsl x9, x9, #3
    ldr x10, [x21, x9]
    ldr x11, [x25, x9]
    mul x10, x10, x11
    str x10, [x26, x9]
    add x28, x28, #1
    b .Lar_punto_j
.Lar_punto_next_i:
    add x27, x27, #1
    b .Lar_punto_i

.Lar_punto_mostrar:
    ldr x0, =msg_ar_resultado
    bl print_str
    mov x0, x19
    mov x1, x20
    mov x2, x26
    bl imprimir_matriz
    b .Lar_menu_loop

// ========== MULTIPLICACIÓN CRUZ ==========
.Lar_mult_cruz:
    cmp x20, x23
    b.ne .Lar_dim_error

    mov x26, x19            // filas_C
    mov x27, x24            // cols_C

    mul x0, x26, x27
    lsl x0, x0, #3
    bl malloc
    mov x28, x0
    cbz x28, .Lar_menu_loop

    // Inicializar resultado a cero
    mov x9, #0
    mul x10, x26, x27
    mov x11, #0
.Lar_cruz_zero:
    cmp x11, x10
    b.ge .Lar_cruz_calc
    str xzr, [x28, x11, lsl #3]
    add x11, x11, #1
    b .Lar_cruz_zero

.Lar_cruz_calc:
    mov x9, #0              // i
.Lar_cruz_i:
    cmp x9, x19
    b.ge .Lar_cruz_mostrar
    mov x10, #0             // j
.Lar_cruz_j:
    cmp x10, x24
    b.ge .Lar_cruz_next_i
    mov x11, #0             // k
    mov x12, #0             // acumulador
.Lar_cruz_k:
    cmp x11, x20
    b.ge .Lar_cruz_store
    // A[i][k]
    mul x13, x9, x20
    add x13, x13, x11
    lsl x13, x13, #3
    ldr x14, [x21, x13]
    // B[k][j]
    mul x15, x11, x24
    add x15, x15, x10
    lsl x15, x15, #3
    ldr x16, [x25, x15]
    mul x14, x14, x16
    add x12, x12, x14
    add x11, x11, #1
    b .Lar_cruz_k
.Lar_cruz_store:
    mul x13, x9, x27
    add x13, x13, x10
    str x12, [x28, x13, lsl #3]
    add x10, x10, #1
    b .Lar_cruz_j
.Lar_cruz_next_i:
    add x9, x9, #1
    b .Lar_cruz_i

.Lar_cruz_mostrar:
    ldr x0, =msg_ar_resultado
    bl print_str
    mov x0, x26
    mov x1, x27
    mov x2, x28
    bl imprimir_matriz
    b .Lar_menu_loop

// ========== DIVISIÓN ==========
.Lar_division:
    cmp x19, x23
    b.ne .Lar_dim_error
    cmp x20, x24
    b.ne .Lar_dim_error

    mul x0, x19, x20
    lsl x0, x0, #3
    bl malloc
    mov x26, x0
    cbz x26, .Lar_menu_loop

    mov x27, #0
.Lar_div_i:
    cmp x27, x19
    b.ge .Lar_div_mostrar
    mov x28, #0
.Lar_div_j:
    cmp x28, x20
    b.ge .Lar_div_next_i
    mul x9, x27, x20
    add x9, x9, x28
    lsl x9, x9, #3
    ldr x10, [x25, x9]      // B[i][j]
    cbz x10, .Lar_div_cero
    ldr x11, [x21, x9]      // A[i][j]
    sdiv x11, x11, x10
    str x11, [x26, x9]
    add x28, x28, #1
    b .Lar_div_j
.Lar_div_next_i:
    add x27, x27, #1
    b .Lar_div_i

.Lar_div_cero:
    ldr x0, =msg_ar_div_cero
    bl print_str
    b .Lar_menu_loop

.Lar_div_mostrar:
    ldr x0, =msg_ar_resultado
    bl print_str
    mov x0, x19
    mov x1, x20
    mov x2, x26
    bl imprimir_matriz
    b .Lar_menu_loop

.Lar_dim_error:
    ldr x0, =msg_ar_dim_error
    bl print_str
    b .Lar_menu_loop
 

.Lar_fin:
    ldp x9, x10, [sp, #96]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret