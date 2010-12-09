int GREEN_LED_PIN = 9;
int RED_LED_PIN = 11;

int DEBUG_LED_PIN = 13;

int colorByte = 0;
int RED = 103;
int GREEN = 114;
int YELLOW = 121;

long MS_BETWEEN_PULSES = 1000;
int FADE_MS = 3000;
int PULSE_MS = 3000;

void setup() {
  pinMode(DEBUG_LED_PIN, OUTPUT);
  analogWrite(RED_LED_PIN, 0);
  analogWrite(GREEN_LED_PIN, 0);
  Serial.begin(9600);
}

void fade(int level, int fromColorPin, int toColorPin) {
  analogWrite(fromColorPin, 255 - level);
  analogWrite(toColorPin, level);
  delay(1);
}

void fade_both(int level, int firstColorPin, int secondColorPin) {
  analogWrite(firstColorPin, level);
  analogWrite(secondColorPin, level);
  delay(1);
}

void fadeGreen() {
  for (int i = 0; i < FADE_MS; ++i) {
    fade( i * 255.0 / FADE_MS, RED_LED_PIN, GREEN_LED_PIN);
  }
}

void fadeRed() {
  for (int i = 0; i < FADE_MS; ++i) {
    fade( i * 255.0 / FADE_MS, GREEN_LED_PIN, RED_LED_PIN);
  }
}

void fadeYellow() {
  for (int i = 0; i < FADE_MS; ++i) {
    fade_both( i * 255.0 / FADE_MS, GREEN_LED_PIN, RED_LED_PIN);
  }
}

void loop() {
  if (Serial.available() > 0) {
    // read the incoming byte:
    colorByte = Serial.read();

    Serial.print("I received: ");
    Serial.println(colorByte, DEC);

    // say what you got:
    if (colorByte == RED) {
      fadeRed();
    } else if (colorByte == GREEN) {
      fadeGreen();
    } else if (colorByte == YELLOW) {
      fadeYellow();
    }
  }
}

