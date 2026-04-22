// Programador: José Ramón Anguiano Rivas
// Curso: Lenguajes de Interfaz
// Práctica: Mini Cloud Log Analyzer
// Variante: C (detectar primer 503)

// Descripción:
// Lee códigos HTTP desde stdin y termina inmediatamente
// al detectar el primer código 503.


// ========================================
// PSEUDOCÓDIGO – VARIANTE C
// Detectar el primer evento crítico (503)
// =======================================

// 1. Inicializar:
//   numero_actual ← 0
//   tiene_digitos ← falso

// 2. Mientras haya datos en stdin:

//   2.1 Leer un bloque de bytes

//   2.2 Para cada byte del bloque:


//   a) Si el byte es un dígito ('0' a '9'):
//        numero_actual ← numero_actual * 10 + valor_digito
//        tiene_digitos ← verdadero

//   b) Si el byte es salto de línea ('\n'):

//        Si tiene_digitos es verdadero:

//             VERIFICAR EVENTO CRÍTICO
//            Si numero_actual == 503:
//                imprimir "CRITICO 503"
//                terminar programa inmediatamente

//        Reiniciar:
//            numero_actual ← 0
//            tiene_digitos ← falso

//   c) Si el byte no es dígito ni salto de línea:
//        ignorarlo

// 3. Fin del archivo (EOF):

//   Si tiene_digitos es verdadero:
//   Si numero_actual == 503:
//   imprimir "CRITICO 503"
//   terminar programa

// 4. Terminar programa (sin imprimir nada si no hubo 503)


.equ SYS_read,   63
.equ SYS_write,  64
.equ SYS_exit,   93
.equ STDIN_FD,    0
.equ STDOUT_FD,   1

.section .bss
.align 4
buffer:     .skip 4096

.section .data
msg_critico:    .asciz "CRITICO 503\n"

.section .text
.global _start

_start:

```
// estado del parser
mov x22, #0      // numero_actual
mov x23, #0      // flag tiene_digitos
```

leer_bloque:
mov x0, #STDIN_FD
adrp x1, buffer
add x1, x1, :lo12:buffer
mov x2, #4096
mov x8, #SYS_read
svc #0

```
cmp x0, #0
beq fin_programa
blt salir_error

mov x24, #0      // índice
mov x25, x0      // bytes leídos
```

procesar_byte:
cmp x24, x25
b.ge leer_bloque

```
adrp x1, buffer
add x1, x1, :lo12:buffer
ldrb w26, [x1, x24]
add x24, x24, #1

// si es '\n'
cmp w26, #10
b.eq fin_numero

// si no es dígito, ignorar
cmp w26, #'0'
b.lt procesar_byte
cmp w26, #'9'
b.gt procesar_byte

// numero_actual = numero_actual * 10 + digito
mov x27, #10
mul x22, x22, x27
sub w26, w26, #'0'
uxtw x26, w26
add x22, x22, x26
mov x23, #1

b procesar_byte
```

fin_numero:
cbz x23, reset_num

```
mov x0, x22
bl verificar_503
```

reset_num:
mov x22, #0
mov x23, #0
b procesar_byte

fin_programa:
// EOF sin encontrar 503
mov x0, #0
mov x8, #SYS_exit
svc #0

salir_error:
mov x0, #1
mov x8, #SYS_exit
svc #0

// =======================================
// verificar_503(x0 = codigo HTTP)
// =======================================
verificar_503:

```
mov x1, #503
cmp x0, x1
b.ne fin_verificacion

// imprimir mensaje crítico
adrp x0, msg_critico
add x0, x0, :lo12:msg_critico

// calcular longitud y escribir
mov x1, x0
mov x2, #0
```

len_loop:
ldrb w3, [x1, x2]
cbz w3, len_done
add x2, x2, #1
b len_loop

len_done:
mov x1, x0
mov x0, #STDOUT_FD
mov x8, #SYS_write
svc #0

```
// salir inmediatamente
mov x0, #0
mov x8, #SYS_exit
svc #0
```

fin_verificacion:
ret

