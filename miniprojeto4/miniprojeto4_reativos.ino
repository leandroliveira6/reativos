#include <Servo.h>

Servo servo;
int pos=90;
int LED_STATE = LOW;

void toggleLED() {
  if (LED_STATE == LOW) {
    digitalWrite(LED_BUILTIN, HIGH);
    LED_STATE = HIGH;
  } else {
    digitalWrite(LED_BUILTIN, LOW);
    LED_STATE = LOW;
  }
}

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  Serial.begin(115200);
  Serial.flush();
  servo.attach(8);
  servo.write(pos);
}

// the loop function runs over and over again forever
void loop() {
  char input = Serial.read();
  if (input != -1) {
    Serial.flush();
    Serial.println(input);
    if (input == '+') {
      if (pos > 90) 
        pos = 80;
      else if (pos != 20)
        pos = pos-10;

      toggleLED();
      servo.write(pos);
    }
    else if (input == '-') { 
      if (pos < 90) 
        pos = 100;
      else if (pos != 170)
        pos = pos+10;

      toggleLED();
      servo.write(pos);
    }
    else if (input == 'M') { 
      pos = 90;
      toggleLED();
      servo.write(pos);
    }
  }
  delay(100);
}
