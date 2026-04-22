# ☁️ Mini Cloud Log Analyzer (ARM64 Assembly)

## 📌 Información General

* **Alumno:** José Ramón Anguiano Rivas
* **Curso:** Lenguajes de Interfaz
* **Práctica:** Mini Cloud Log Analyzer
* **Arquitectura:** ARM64 (AArch64)
* **Sistema:** Linux (Ubuntu ARM)

---

## 🎯 Objetivo

Al finalizar esta práctica, el estudiante será capaz de:
1. Compilar y enlazar un programa ARM64 sin C ni libc.
2. Invocar syscalls Linux (`read`, `write`, `exit`).
3. Parsear enteros desde flujo de bytes (`stdin`).
4. Diseñar lógica condicional para análisis de códigos HTTP.
5. Validar resultados con scripts de prueba reproducibles.

---

## 🔀 Variante C – Detección de evento crítico (503)

Esta variante consiste en:

> Detectar el primer código HTTP **503 (Service Unavailable)** y finalizar inmediatamente la ejecución del programa.

---

## Lógica implementada para la variante C

```asm
verificar_503:

    mov x1, #503
    cmp x0, x1
    b.ne fin_verificacion

    // imprimir mensaje crítico
    adrp x0, msg_critico
    add x0, x0, :lo12:msg_critico

    // calcular longitud y escribir
    mov x1, x0
    mov x2, #0

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

    // salida inmediata
    mov x0, #0
    mov x8, #SYS_exit
    svc #0

fin_verificacion:
    ret
```

    
---

## 🧠 Descripción del funcionamiento
Implemente un analizador de logs de servidor en ARM64 Assembly que reciba por `stdin` una secuencia de códigos HTTP (un entero por línea), y procese la información según la variante asignada por el docente.

El programa:

1. Lee datos desde `stdin` en bloques de bytes.
2. Procesa la entrada **carácter por carácter**.
3. Construye números enteros (códigos HTTP) a partir de dígitos.
4. Detecta el final de cada número mediante el carácter `\n`.
5. Verifica si el código es **503**:

   * ✔ Si lo es → imprime `"CRITICO 503"` y termina.
   * ❌ Si no → continúa procesando.
6. Si no se detecta ningún 503, el programa termina sin salida.

---

## ⚙️ Tecnologías utilizadas

* Ensamblador **ARM64 (AArch64)**
* Syscalls de Linux:

  * `read` (63)
  * `write` (64)
  * `exit` (93)

---
## 🎥 Video en Asciinema del proceso de compilación y ejecución


👉 https://asciinema.org/a/amLLXxgzopxvQ4RM


[![asciicast](https://asciinema.org/a/amLLXxgzopxvQ4RM.svg)](https://asciinema.org/a/amLLXxgzopxvQ4RM)


## 🚀 Compilación

```bash
as -o analyzer.o src/analyzer.s
ld -o analyzer analyzer.o
```
<img width="1001" height="155" alt="Captura de pantalla 2026-04-21 171619" src="https://github.com/user-attachments/assets/4a780b46-7f90-4b78-91ee-8eb9f64adbf9" />

---

## ▶️ Ejecución

```bash
cat data/logs_C.txt | ./analyzer
```
<img width="1246" height="73" alt="Captura de pantalla 2026-04-21 172145" src="https://github.com/user-attachments/assets/dbf86407-3979-4f99-b7c3-47afed19eae0" />

---

## 📤 Salida esperada

```
CRITICO 503
```

👉 El programa finaliza inmediatamente después de detectar el código 503.


---

## 🧩 Pseudocódigo

```
leer entrada por bloques
para cada byte:
    si es dígito:
        construir número
    si es '\n':
        si número == 503:
            imprimir mensaje
            terminar programa
        reiniciar número
```

---

## 🧠 Conclusión

Una vez concluida la práctica pudimos comprender el manejo  de la entrada/salida a bajo nivel en ARM64, además de esto, pudimos analizar el control de flujo sin el uso de los lenguajes de alto nivel.

---



