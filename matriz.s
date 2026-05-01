.section .data
//199812349 Edy Donaldo López Anavizca
msg_pedir_filas:    .asciz "\nIngrese número de filas: "
msg_pedir_cols:     .asciz "Ingrese número de columnas: "
msg_matriz_cargada: .asciz "\n✅  Matriz cargada correctamente.\n"
msg_mostrar_mat:    .asciz "\nMatriz actual:\n"
msg_espacio:        .asciz "  "
msg_newline:        .asciz "\n"
msg_corchete_ab:    .asciz "[ "
msg_corchete_ci:    .asciz "]\n"

// Buffer para pedir cada celda: "a[i][j] = "
msg_celda_prefix:   .asciz "  a["
msg_celda_mid1:     .asciz "]["
msg_celda_mid2:     .asciz "] = "


.section .text
.extern print_str
.extern read_int
.extern print_int
.extern malloc

.global ingresar_matriz
ingresar_matriz:
    stp     x29, x30, [sp, #-64]!
    mov     x29, sp
    // Guardar registros callee-saved que usaremos
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]

    // ── Leer número de filas ─────────────────────────────────
    ldr     x0, =msg_pedir_filas
    bl      print_str
    bl      read_int
    mov     x19, x0             // x19 = filas

    // ── Leer número de columnas ──────────────────────────────
    ldr     x0, =msg_pedir_cols
    bl      print_str
    bl      read_int
    mov     x20, x0             // x20 = columnas

    // ── Reservar memoria: filas * cols * 8 bytes ─────────────
    //  syscall mmap(NULL, size, PROT_READ|PROT_WRITE,
    //               MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)
    mul     x0, x19, x20        // x1 = filas * cols
    lsl     x0, x0, #3          // x1 = bytes (× 8 por .quad)
    bl      malloc
    mov   x21,x0
    cbz   x21,.Lerror_mem
    mov   x22,#0
    mul  x23, x19, x20

.Linit_zero:

    cmp x22,x23
    bge .Lpedir_elementos
    str xzr, [x21,x22,lsl #3]
    add x22,x22,#1
    b .Linit_zero

.Lpedir_elementos:
    mov x22,#0

.Lloop_filas:
    cmp     x22, x19
    b.ge    .Lfin_ingreso

    mov     x23, #0             // j = 0  (x23 en stack si lo necesitas)
.Lloop_cols:
    cmp     x23, x20
    b.ge    .Lsig_fila

    // Mostrar "  a[i][j] = "
    ldr     x0, =msg_celda_prefix
    bl      print_str
    mov     x0, x22
    bl      print_int
    ldr     x0, =msg_celda_mid1
    bl      print_str
    mov     x0, x23
    bl      print_int
    ldr     x0, =msg_celda_mid2
    bl      print_str

    // Leer valor
    bl      read_int            // x0 = valor ingresado

    // Guardar en memoria: dirección = base + (i*cols + j)*8
    mul     x24, x22, x20       // i * cols
    add     x24, x24, x23       // + j
    str     x0, [x21, x24, lsl #3]  // A[i][j] = valor
    add     x23, x23, #1        // j++
    b       .Lloop_cols

    //lsl     x24, x24, #3        // × 8 bytes
    //str     x0, [x21, x24]      // A[i][j] = valor

    //add     x23, x23, #1        // j++
    //b       .Lloop_cols

.Lsig_fila:
    add     x22, x22, #1        // i++
    b       .Lloop_filas

.Lfin_ingreso:
    ldr     x0, =msg_matriz_cargada
    bl      print_str

    // Mostrar la matriz recién ingresada
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // Retornar filas, cols, puntero
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    b .Lret

.Lerror_mem:
    // Manejar error de malloc (por simplicidad, solo imprimir mensaje y retornar 0)
    mov     x0, #0
    mov     x1, #0
    mov     x2, #0

.Lret:
        ldp     x23, x24, [sp, #48]
        ldp     x21, x22, [sp, #32]
        ldp     x19, x20, [sp, #16]
        ldp     x29, x30, [sp], #64
        ret




    //ldp     x21, x22, [sp, #32]
    //ldp     x19, x20, [sp, #16]
    //ldp     x29, x30, [sp], #48
    //ret

.global imprimir_matriz
imprimir_matriz:
    stp     x29, x30, [sp, #-64]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]
    stp     x23, x24, [sp, #48]


    mov     x19, x0             // filas
    mov     x20, x1             // cols
    mov     x21, x2             // ptr

    ldr     x0, =msg_mostrar_mat
    bl      print_str

    mov     x22, #0             // i = 0
.Lprint_fila:
    cmp     x22, x19
    b.ge    .Lprint_fin

    ldr     x0, =msg_corchete_ab
    bl      print_str

    mov     x23, #0             // j = 0
.Lprint_col:
    cmp     x23, x20
    b.ge    .Lprint_sig_fila

    // Cargar A[i][j]
    mul     x24, x22, x20
    add     x24, x24, x23
    lsl     x24, x24, #3
    ldr     x0, [x21, x24]
    bl      print_int           // imprimir el número

    ldr     x0, =msg_espacio
    bl      print_str

    add     x23, x23, #1
    b       .Lprint_col

.Lprint_sig_fila:
    ldr     x0, =msg_corchete_ci
    bl      print_str
    add     x22, x22, #1
    b       .Lprint_fila
.Lprint_error:
    ldr x0,=msg_matriz_cargada
    bl print_str

    
.Lprint_fin:
    ldp     x23,x24,[sp,#48]
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #64
    ret


// ================================================================
//  acceder_elemento — Accede a A[i][j] en row-major
//  Entrada: x0=i, x1=j, x2=cols, x3=puntero base
//  Salida:  x0 = valor A[i][j]
// ================================================================
.global acceder_elemento
acceder_elemento:
    mul     x4, x0, x2          // i * cols
    add     x4, x4, x1          // + j
    lsl     x4, x4, #3          // × 8 bytes
    ldr     x0, [x3, x4]        // cargar valor
    ret


// ================================================================
//  print_int — Imprime un entero con signo en consola
//  Entrada: x0 = valor a imprimir
//  (Versión simplificada: funciona para valores 0-9999)
// ================================================================
// print_int está implementada en io.s — no duplicar aquí
.extern print_intclear