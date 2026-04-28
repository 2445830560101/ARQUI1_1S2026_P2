.section .data

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


.global menu_aritmetica
menu_aritmetica:
    stp     x29, x30, [sp, #-64]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]

    mov     x19, x0             // filas_A
    mov     x20, x1             // cols_A
    mov     x21, x2             // ptr_A

.Lar_menu_loop:
    ldr     x0, =msg_ar_menu
    bl      print_str
    bl      read_int

    cmp     x0, #6
    b.eq    .Lar_fin

    // Guardar opción
    mov     x22, x0

    // Pedir matriz B para todas las operaciones
    ldr     x0, =msg_ar_ingresar_b
    bl      print_str
    bl      ingresar_matriz     // x0=filas_B, x1=cols_B, x2=ptr_B
    mov     x23, x0             // filas_B
    mov     x24, x1             // cols_B
    // ptr_B en x2

    // Despachar según opción
    cmp     x22, #1
    b.eq    .Lar_suma
    cmp     x22, #2
    b.eq    .Lar_resta
    cmp     x22, #3
    b.eq    .Lar_mult_punto
    cmp     x22, #4
    b.eq    .Lar_mult_cruz
    cmp     x22, #5
    b.eq    .Lar_division
    b       .Lar_menu_loop

// ========== SUMA ==========
.Lar_suma:
    // Verificar dimensiones iguales
    cmp     x19, x23        // filas_A vs filas_B
    b.ne    .Lar_dim_error
    cmp     x20, x24        // cols_A vs cols_B
    b.ne    .Lar_dim_error

    // Reservar memoria para resultado C
    mul     x1, x19, x20
    lsl     x1, x1, #3
    mov     x0, #0
    mov     x2, #3
    mov     x3, #0x22
    mov     x4, #-1
    mov     x5, #0
    mov     x8, #222
    svc     #0
    mov     x25, x0         // ptr_C

    // i = 0 .. filas-1
    mov     x26, #0         // i
.Lar_suma_i:
    cmp     x26, x19
    b.ge    .Lar_suma_mostrar
    mov     x27, #0         // j
.Lar_suma_j:
    cmp     x27, x20
    b.ge    .Lar_suma_next_i

    // offset = (i*cols + j)*8
    mul     x28, x26, x20
    add     x28, x28, x27
    lsl     x28, x28, #3

    ldr     x29, [x21, x28] // A[i][j]
    ldr     x30, [x2, x28]  // B[i][j] (x2 tiene ptr_B)
    add     x29, x29, x30
    str     x29, [x25, x28]

    add     x27, x27, #1
    b       .Lar_suma_j
.Lar_suma_next_i:
    add     x26, x26, #1
    b       .Lar_suma_i

.Lar_suma_mostrar:
    ldr     x0, =msg_ar_resultado
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x25
    bl      imprimir_matriz
    b       .Lar_menu_loop

// ========== RESTA ==========
.Lar_resta:
    cmp     x19, x23
    b.ne    .Lar_dim_error
    cmp     x20, x24
    b.ne    .Lar_dim_error

    mul     x1, x19, x20
    lsl     x1, x1, #3
    mov     x0, #0
    mov     x2, #3
    mov     x3, #0x22
    mov     x4, #-1
    mov     x5, #0
    mov     x8, #222
    svc     #0
    mov     x25, x0

    mov     x26, #0
.Lar_resta_i:
    cmp     x26, x19
    b.ge    .Lar_resta_mostrar
    mov     x27, #0
.Lar_resta_j:
    cmp     x27, x20
    b.ge    .Lar_resta_next_i
    mul     x28, x26, x20
    add     x28, x28, x27
    lsl     x28, x28, #3
    ldr     x29, [x21, x28]
    ldr     x30, [x2, x28]
    sub     x29, x29, x30
    str     x29, [x25, x28]
    add     x27, x27, #1
    b       .Lar_resta_j
.Lar_resta_next_i:
    add     x26, x26, #1
    b       .Lar_resta_i
.Lar_resta_mostrar:
    ldr     x0, =msg_ar_resultado
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x25
    bl      imprimir_matriz
    b       .Lar_menu_loop

// ========== MULTIPLICACIÓN PUNTO ==========
.Lar_mult_punto:
    cmp     x19, x23
    b.ne    .Lar_dim_error
    cmp     x20, x24
    b.ne    .Lar_dim_error

    mul     x1, x19, x20
    lsl     x1, x1, #3
    mov     x0, #0
    mov     x2, #3
    mov     x3, #0x22
    mov     x4, #-1
    mov     x5, #0
    mov     x8, #222
    svc     #0
    mov     x25, x0

    mov     x26, #0
.Lar_punto_i:
    cmp     x26, x19
    b.ge    .Lar_punto_mostrar
    mov     x27, #0
.Lar_punto_j:
    cmp     x27, x20
    b.ge    .Lar_punto_next_i
    mul     x28, x26, x20
    add     x28, x28, x27
    lsl     x28, x28, #3
    ldr     x29, [x21, x28]
    ldr     x30, [x2, x28]
    mul     x29, x29, x30
    str     x29, [x25, x28]
    add     x27, x27, #1
    b       .Lar_punto_j
.Lar_punto_next_i:
    add     x26, x26, #1
    b       .Lar_punto_i
.Lar_punto_mostrar:
    ldr     x0, =msg_ar_resultado
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x25
    bl      imprimir_matriz
    b       .Lar_menu_loop

// ========== MULTIPLICACIÓN CRUZ ==========
.Lar_mult_cruz:
    // Verificar cols_A == filas_B
    cmp     x20, x23
    b.ne    .Lar_dim_error

    // Resultado: filas_A x cols_B
    mov     x26, x19        // filas_C = filas_A
    mov     x27, x24        // cols_C = cols_B

    // Reservar memoria: filas_C * cols_C * 8
    mul     x1, x26, x27
    lsl     x1, x1, #3
    mov     x0, #0
    mov     x2, #3
    mov     x3, #0x22
    mov     x4, #-1
    mov     x5, #0
    mov     x8, #222
    svc     #0
    mov     x25, x0         // ptr_C

    // i = 0 .. filas_A-1
    mov     x28, #0         // i
.Lar_cruz_i:
    cmp     x28, x19
    b.ge    .Lar_cruz_mostrar
    // j = 0 .. cols_B-1
    mov     x29, #0         // j
.Lar_cruz_j:
    cmp     x29, x24
    b.ge    .Lar_cruz_next_i
    // C[i][j] = sum_k A[i][k] * B[k][j]
    mov     x30, #0         // acumulador
    mov     x10, #0         // k
.Lar_cruz_k:
    cmp     x10, x20        // k < cols_A
    b.ge    .Lar_cruz_store

    // A[i][k]
    mul     x11, x28, x20
    add     x11, x11, x10
    lsl     x11, x11, #3
    ldr     x12, [x21, x11]

    // B[k][j]  (B tiene filas_B=x23, cols_B=x24)
    mul     x13, x10, x24
    add     x13, x13, x29
    lsl     x13, x13, #3
    ldr     x14, [x2, x13]

    mul     x12, x12, x14
    add     x30, x30, x12

    add     x10, x10, #1
    b       .Lar_cruz_k

.Lar_cruz_store:
    // offset C: (i * cols_C + j) * 8
    mul     x11, x28, x27
    add     x11, x11, x29
    lsl     x11, x11, #3
    str     x30, [x25, x11]

    add     x29, x29, #1
    b       .Lar_cruz_j
.Lar_cruz_next_i:
    add     x28, x28, #1
    b       .Lar_cruz_i

.Lar_cruz_mostrar:
    ldr     x0, =msg_ar_resultado
    bl      print_str
    mov     x0, x26
    mov     x1, x27
    mov     x2, x25
    bl      imprimir_matriz
    b       .Lar_menu_loop

// ========== DIVISIÓN ==========
.Lar_division:
    cmp     x19, x23
    b.ne    .Lar_dim_error
    cmp     x20, x24
    b.ne    .Lar_dim_error

    mul     x1, x19, x20
    lsl     x1, x1, #3
    mov     x0, #0
    mov     x2, #3
    mov     x3, #0x22
    mov     x4, #-1
    mov     x5, #0
    mov     x8, #222
    svc     #0
    mov     x25, x0

    mov     x26, #0
.Lar_div_i:
    cmp     x26, x19
    b.ge    .Lar_div_mostrar
    mov     x27, #0
.Lar_div_j:
    cmp     x27, x20
    b.ge    .Lar_div_next_i
    mul     x28, x26, x20
    add     x28, x28, x27
    lsl     x28, x28, #3
    ldr     x29, [x2, x28]      // B[i][j]
    cbz     x29, .Lar_div_cero
    ldr     x30, [x21, x28]     // A[i][j]
    // División entera: A / B
    sdiv    x30, x30, x29
    str     x30, [x25, x28]
    add     x27, x27, #1
    b       .Lar_div_j
.Lar_div_next_i:
    add     x26, x26, #1
    b       .Lar_div_i

.Lar_div_cero:
    ldr     x0, =msg_ar_div_cero
    bl      print_str
    b       .Lar_menu_loop

.Lar_div_mostrar:
    ldr     x0, =msg_ar_resultado
    bl      print_str
    mov     x0, x19
    mov     x1, x20
    mov     x2, x25
    bl      imprimir_matriz
    b       .Lar_menu_loop

.Lar_dim_error:
    ldr     x0, =msg_ar_dim_error
    bl      print_str
    b       .Lar_menu_loop

.Lar_fin:
    ldp     x23, x24, [sp, #48]
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #64
    ret