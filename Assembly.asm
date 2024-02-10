;NO HE PROBADO LA FUNCIONALIDAD DE ESTE CÓDIGO
;I HAVEN'T TRIED THE FUNCTIONALITY OF THIS CODE

.include "m328pdef.inc"

.equ LDR1, 0       ; Definir el pin A0 como LDR1
.equ LDR2, 1       ; Definir el pin A1 como LDR2
.equ SERVO_PIN, 3  ; Definir el pin 3 como el pin del servomotor

.equ SPOINT, 90    ; Definir el punto inicial del servomotor

; Definir constantes de error y tiempo de espera
.equ ERROR, 10
.equ DELAY_TIME, 80

; Definir las direcciones de memoria de los registros de periféricos
.equ DDRB_REG, 0x24   ; Registro de dirección de datos para el puerto B
.equ PORTB_REG, 0x25  ; Registro de salida para el puerto B

.org 0x0000
    rjmp main

main:
    ldi r16, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)  ; Habilitar ADC con prescaler de 128
    out ADCSRA, r16
    
    ldi r16, (1 << REFS0)  ; Seleccionar referencia de voltaje AVCC
    out ADMUX, r16
    
    ldi r16, 0xFF  ; Configurar todos los pines del puerto B como salida
    out DDRB_REG, r16
    
    ldi r16, SPOINT
    call update_servo_position

loop:
    call read_ldr_values
    call calculate_difference
    call check_error
    brne servo_adjust
    rjmp delay_loop

read_ldr_values:
    ldi r30, LDR1
    call read_adc
    mov r18, r24

    ldi r30, LDR2
    call read_adc
    mov r19, r24
    ret

calculate_difference:
    sub r20, r18, r19
    sub r21, r19, r18
    ret

check_error:
    cpi r20, ERROR
    brsh error_occurred
    cpi r21, ERROR
    brsh error_occurred
    ret

error_occurred:
    ret

servo_adjust:
    ldi r16, 1
    call update_servo_position
    rjmp delay_loop

update_servo_position:
    cp r16, 0
    brlt decrease_position
    brge increase_position

increase_position:
    inc r22
    rjmp set_servo_position

decrease_position:
    dec r22
    rjmp set_servo_position

set_servo_position:
    cpi r22, 0
    brsh servo_within_range
    ldi r22, 0

servo_within_range:
    cpi r22, 180
    brlo servo_within_min
    ldi r22, 180

servo_within_min:
    out PORTB_REG, r22
    ret

delay_loop:
    ldi r16, DELAY_TIME
    call delay_ms
    ret

delay_ms:
    delay_loop:
        ldi r17, 5
    outer_loop:
        ldi r18, 100
    inner_loop:
        dec r18
        brne inner_loop
        dec r17
        brne outer_loop
        dec r16
        brne delay_loop
    ret

read_adc:
    sbic ADCSRA, ADSC
    rjmp read_adc
    in r24, ADC
    ret
