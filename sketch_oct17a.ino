

//Incluir la librería del servomotor
#include <Servo.h>
//Definir los pines LDR
#define LDR1 A0
#define LDR2 A1
//Definir el valor de error
#define error 10
//Punto inicial del servomotor
int Spoint =  90;
//Objeto del servomotor
Servo servo;

void setup() {
//Pin PWM servomotor
  servo.attach(11);
//Punto inicial del servomotor
  servo.write(Spoint);
  delay(1000);
}

void loop() {
//Valor del sensor LDR
  int ldr1 = analogRead(LDR1);
//Valor del otro sensor LDR
  int ldr2 = analogRead(LDR2);

//Obten la diferencia
  int value1 = abs(ldr1 - ldr2);
  int value2 = abs(ldr2 - ldr1);

//Comparar los datos con el error
  if ((value1 <= error) || (value2 <= error)) {

  } else {
    if (ldr1 > ldr2) {
      Spoint = --Spoint;
    }
    if (ldr1 < ldr2) {
      Spoint = ++Spoint;
    }
  }
//Enviar los datos al servomotor
  servo.write(Spoint);
  delay(80);
}
