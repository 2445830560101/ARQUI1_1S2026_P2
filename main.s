.section .data

// ── Mensajes del menú principal ──────────────────────────────
msg_bienvenida:
    .asciz "\n╔══════════════════════════════════════╗\n║  Motor de Álgebra Lineal en ARM64    ║\n║  ARQUI1 — USAC  2026                ║\n╚══════════════════════════════════════╝\n\n"

msg_menu:
    .asciz "\n═══════════ MENÚ PRINCIPAL ═══════════\n 1. Ingresar nueva matriz\n 2. Matriz Identidad\n 3. Matriz Transpuesta\n 4. Método de Gauss\n 5. Gauss-Jordan\n 6. Matriz Inversa\n 7. Aritmética (suma/resta/mult/div)\n 8. Determinante\n 9. Salir\n═══════════════════════════════════════\nSeleccione una opción: "

msg_opcion_invalida:
    .asciz "\n[ERROR] Opción inválida. Intente de nuevo.\n"

msg_adios:
    .asciz "\n¡Hasta luego!\n\n"

msg_sin_matriz:
    .asciz "\n[ERROR] Primero debe ingresar una matriz (opción 1).\n"


// ── Sección de texto (código) ─────────────────────────────────
.section .text
.global _start

// ── Declarar rutinas externas (definidas en otros .s) ────────
.extern ingresar_matriz
.extern imprimir_matriz
.extern calcular_identidad
.extern calcular_transpuesta
.extern calcular_gauss
.extern calcular_gauss_jordan
.extern calcular_inversa
.extern menu_aritmetica
.extern calcular_determinante


// ================================================================
//  _start — Punto de entrada del programa
// ================================================================
_start:
    // Guardar frame pointer
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // Inicializar: aún no hay matriz ingresada
    mov     x19, #0         // filas = 0 (señal de "sin matriz")
    mov     x20, #0         // columnas = 0
    mov     x21, #0         // puntero = NULL

    // Mostrar bienvenida
    ldr     x0, =msg_bienvenida
    bl      print_str

// ================================================================
//  loop_menu — Ciclo principal del menú
// ================================================================
loop_menu:
    // Mostrar menú y leer opción
    ldr     x0, =msg_menu
    bl      print_str
    bl      read_int        // x0 = opción elegida

    // Comparar y saltar a la rutina correspondiente
    cmp     x0, #1
    b.eq    opcion_1_ingresar

    cmp     x0, #2
    b.eq    opcion_requiere_matriz

    cmp     x0, #3
    b.eq    opcion_requiere_matriz_3

    cmp     x0, #4
    b.eq    opcion_requiere_matriz_4

    cmp     x0, #5
    b.eq    opcion_requiere_matriz_5

    cmp     x0, #6
    b.eq    opcion_requiere_matriz_6

    cmp     x0, #7
    b.eq    opcion_requiere_matriz_7

    cmp     x0, #8
    b.eq    opcion_requiere_matriz_8

    cmp     x0, #9
    b.eq    opcion_9_salir

    // Opción inválida
    ldr     x0, =msg_opcion_invalida
    bl      print_str
    b       loop_menu


// ── Opción 1: Ingresar matriz ────────────────────────────────
opcion_1_ingresar:
    bl      ingresar_matriz     // retorna: x0=filas, x1=cols, x2=ptr
    mov     x19, x0             // guardar filas
    mov     x20, x1             // guardar columnas
    mov     x21, x2             // guardar puntero a datos
    b       loop_menu


// ── Verificar que existe una matriz antes de operar ──────────
//    (opciones 2-8 la necesitan)

opcion_requiere_matriz:
    cbz     x19, no_hay_matriz
    // Opción 2: Identidad
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      calcular_identidad
    b       loop_menu

opcion_requiere_matriz_3:
    cbz     x19, no_hay_matriz
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      calcular_transpuesta
    b       loop_menu

opcion_requiere_matriz_4:
    cbz     x19, no_hay_matriz
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      calcular_gauss
    b       loop_menu

opcion_requiere_matriz_5:
    cbz     x19, no_hay_matriz
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      calcular_gauss_jordan
    b       loop_menu

opcion_requiere_matriz_6:
    cbz     x19, no_hay_matriz
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      calcular_inversa
    b       loop_menu

opcion_requiere_matriz_7:
    cbz     x19, no_hay_matriz
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      menu_aritmetica
    b       loop_menu

opcion_requiere_matriz_8:
    cbz     x19, no_hay_matriz
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      calcular_determinante
    b       loop_menu

no_hay_matriz:
    ldr     x0, =msg_sin_matriz
    bl      print_str
    b       loop_menu


// ── Opción 9: Salir ──────────────────────────────────────────
opcion_9_salir:
    ldr     x0, =msg_adios
    bl      print_str
    // syscall exit(0)
    mov     x0, #0
    mov     x8, #93
    svc     #0


// print_str y read_int están definidas en io.s
.extern print_str
.extern read_int