.section .data

io_minus_sign:  .asciz "-"
io_newline:     .asciz "\n"

// Buffer interno para conversión de enteros a texto
// (21 dígitos máximo para un int64 + signo + null)
io_int_buffer:  .space 24


.section .text


.global print_str
print_str:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    mov     x1, x0              // buffer = ptr al string
    // Calcular longitud recorriendo hasta encontrar \0
    mov     x2, #0
.Lps_count:
    ldrb    w3, [x1, x2]
    cbz     w3, .Lps_write
    add     x2, x2, #1
    b       .Lps_count
.Lps_write:
    cbz     x2, .Lps_done       // no imprimir si está vacío
    mov     x0, #1              // fd = stdout
    mov     x8, #64             // syscall write
    svc     #0
.Lps_done:
    ldp     x29, x30, [sp], #16
    ret


// ================================================================
//  print_newline — Imprime un salto de línea
// ================================================================
.global print_newline
print_newline:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    ldr     x0, =io_newline
    bl      print_str
    ldp     x29, x30, [sp], #16
    ret


// ================================================================
//  print_int — Imprime un entero con signo de 64 bits
//  Entrada: x0 = valor int64 a imprimir
//
//  Algoritmo:
//    1. Si negativo, imprimir "-" y negar el valor
//    2. Dividir por 10 repetidamente para extraer dígitos
//    3. Guardar dígitos en buffer (de derecha a izquierda)
//    4. Imprimir el buffer
// ================================================================
.global print_int
print_int:
    stp     x29, x30, [sp, #-32]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]

    mov     x19, x0             // guardar valor original




    // ── Manejar cero ────────────────────────────────────────
    cbnz    x19, .Lpi_nonzero
    // Es cero: imprimir "0"
    ldr     x1, =io_int_buffer
    mov     w2, #48             // '0'
    strb    w2, [x1]
    mov     w2, #0
    strb    w2, [x1, #1]
    mov     x0, x1
    bl      print_str
    b       .Lpi_done

.Lpi_nonzero:
    // ── Manejar signo negativo ───────────────────────────────
    cmp     x19, #0
    b.ge    .Lpi_positive
    ldr     x0, =io_minus_sign
    bl      print_str
    neg     x19, x19            // x19 = -x19

.Lpi_positive:
    // ── Convertir a string de dígitos ────────────────────────
    ldr     x20, =io_int_buffer
    add     x20, x20, #21       // puntero al FINAL del buffer
    mov     w2, #0
    strb    w2, [x20]           // null terminator al final
    sub     x20, x20, #1        // retroceder una posición

    mov     x1, x19             // x1 = valor a convertir
    mov     x2, #10             // divisor

.Lpi_loop:
    // x1 = x1 / 10, x3 = x1 % 10
    udiv    x3, x1, x2          // x3 = cociente
    msub    x4, x3, x2, x1      // x4 = x1 - x3*10 = resto
    add     w4, w4, #48         // convertir dígito a ASCII
    strb    w4, [x20]           // guardar en buffer
    sub     x20, x20, #1        // retroceder
    mov     x1, x3              // siguiente iteración con cociente
    cbnz    x1, .Lpi_loop       // continuar si no llegamos a 0

    // Imprimir desde x20+1 hasta null
    add     x0, x20, #1
    bl      print_str

.Lpi_done:
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret


// ================================================================
//  read_int — Lee un entero con signo desde stdin
//  Salida: x0 = valor entero leído (soporta multi-dígito)
//
//  Algoritmo:
//    1. Leer hasta 20 caracteres con syscall 63
//    2. Detectar signo negativo opcional
//    3. Acumular dígitos: valor = valor * 10 + dígito
// ================================================================
.global read_int
read_int:
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]

    // Buffer de lectura en stack (20 chars + null)
    sub     sp, sp, #32
    mov     x19, sp             // x19 = ptr al buffer

    // syscall read(0, buffer, 20)
    mov     x0, #0              // fd = stdin
    mov     x1, x19             // buffer
    mov     x2, #20             // max chars
    mov     x8, #63             // syscall read
    svc     #0

    // ── Procesar los caracteres leídos ───────────────────────
    mov     x20, #0             // índice i = 0
    mov     x21, #0             // acumulador resultado = 0
    mov     x22, #0             // flag negativo = 0

    // Detectar signo '-'
    ldrb    w3, [x19, x20]
    cmp     w3, #45             // '-' = ASCII 45
    b.ne    .Lri_loop
    mov     x22, #1             // es negativo
    add     x20, x20, #1        // avanzar al siguiente char

.Lri_loop:
    ldrb    w3, [x19, x20]      // cargar char
    cmp     w3, #48             // menor que '0'?
    b.lt    .Lri_done
    cmp     w3, #57             // mayor que '9'?
    b.gt    .Lri_done

    // Dígito válido: resultado = resultado * 10 + (char - '0')
    mov     x4, #10
    mul     x21, x21, x4
    sub     w3, w3, #48         // char → dígito
    add     x21, x21, x3
    add     x20, x20, #1        // i++
    b       .Lri_loop

.Lri_done:
    // Aplicar signo si era negativo
    cbz     x22, .Lri_ret
    neg     x21, x21

.Lri_ret:
    mov     x0, x21             // retornar en x0

    add     sp, sp, #32
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret
.global malloc
malloc:
    mov     x1, x0              // size
    mov     x0, #0              // addr = NULL (kernel elige)
    mov     x2, #3              // PROT_READ | PROT_WRITE
    mov     x3, #0x22           // MAP_PRIVATE | MAP_ANONYMOUS
    mov     x4, #-1             // fd = -1
    mov     x5, #0              // offset = 0
    mov     x8, #222            // syscall mmap
    svc     #0
    ret