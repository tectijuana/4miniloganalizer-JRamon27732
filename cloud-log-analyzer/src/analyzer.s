# /*

Programador: José Ramón Anguiano Rivas
Curso: Lenguajes de Interfaz
Práctica: Mini Cloud Log Analyzer
Variante: C (detectar primer 503)

*/

.equ SYS_read,   63
.equ SYS_write,  64
.equ SYS_exit,   93
.equ STDIN_FD,    0
.equ STDOUT_FD,   1

.section .bss
.align 4
buffer:     .skip 4096
num_buf:    .skip 32

.section .data
msg_critico:    .asciz "CRITICO 503\n"

.section .text
.global _start

_start:
// contadores
mov x19, #0      // 2xx
mov x20, #0      // 4xx
mov x21, #0      // 5xx

```
// parser
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
beq fin_lectura
blt salir_error

mov x24, #0      // i
mov x25, x0      // bytes leidos
```

procesar_byte:
cmp x24, x25
b.ge leer_bloque

```
adrp x1, buffer
add x1, x1, :lo12:buffer
ldrb w26, [x1, x24]
add x24, x24, #1

// newline
cmp w26, #10
b.eq fin_numero

// digito?
cmp w26, #'0'
b.lt procesar_byte
cmp w26, #'9'
b.gt procesar_byte

// numero = numero * 10 + digito
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
bl procesar_codigo
```

reset_num:
mov x22, #0
mov x23, #0
b procesar_byte

fin_lectura:
cbz x23, salir_ok
mov x0, x22
bl procesar_codigo

salir_ok:
mov x0, #0
mov x8, #SYS_exit
svc #0

salir_error:
mov x0, #1
mov x8, #SYS_exit
svc #0

// =======================================
// procesar_codigo(x0 = codigo HTTP)
// =======================================
procesar_codigo:

```
// DETECTAR 503
mov x1, #503
cmp x0, x1
b.ne clasificar

// imprimir mensaje
adrp x0, msg_critico
add x0, x0, :lo12:msg_critico
bl write_cstr

// salir inmediatamente
mov x0, #0
mov x8, #SYS_exit
svc #0
```

clasificar:

```
// 2xx
cmp x0, #200
b.lt fin_proc
cmp x0, #299
b.gt check4
add x19, x19, #1
b fin_proc
```

check4:
cmp x0, #400
b.lt fin_proc
cmp x0, #499
b.gt check5
add x20, x20, #1
b fin_proc

check5:
cmp x0, #500
b.lt fin_proc
cmp x0, #599
b.gt fin_proc
add x21, x21, #1

fin_proc:
ret

// =======================================
// write_cstr
// =======================================
write_cstr:
mov x9, x0
mov x10, #0

len_loop:
ldrb w11, [x9, x10]
cbz w11, len_done
add x10, x10, #1
b len_loop

len_done:
mov x1, x9
mov x2, x10
mov x0, #STDOUT_FD
mov x8, #SYS_write
svc #0
ret

