# Sterowanie LED przez iPhone i Apple Watch / ESP32 Lighting Control

## Polski

### O projekcie

Stworzyłem aplikację na **iPhone** oraz **Apple Watch**, która pozwala zdalnie sterować oświetleniem LED poprzez sieć Wi-Fi.  
Urządzeniem wykonawczym jest **ESP32** działające w **MicroPythonie**, obsługujące PWM, efekty fade oraz przełączanie LED.

Aplikacja umożliwia zmianę jasności, włączanie i wyłączanie wyjść oraz sterowanie animacjami światła — wszystko w czasie rzeczywistym.

### Funkcjonalności

- Sterowanie LED z iPhone i Apple Watch  
- Regulacja jasności (PWM)  
- Efekt **fade** LED  
- Osobne sterowanie "LED Okno" i "LED Choinka"  
- Obsługa przez Wi-Fi (HTTP GET)  
- Debounce przy zmianie jasności  
- Wspólny **NetworkManager** ułatwiający komunikację

### Technologie

- **SwiftUI** — aplikacja iOS + watchOS  
- **MicroPython** — logika sterowania na **ESP32**  
- **PWM**, **Timer**, **Socket server**  
- Protokół HTTP do łatwej komunikacji urządzeń w sieci lokalnej

---

## English

### About the Project

This project includes an **iPhone** and **Apple Watch** app that remotely controls LED lighting over Wi-Fi.  
The hardware controller is an **ESP32** running **MicroPython**, handling PWM brightness, fade effects, and LED switching.

The system allows real-time brightness control, toggling outputs, and light animations — all from your wrist or phone.

### Features

- LED control from iPhone and Apple Watch  
- PWM brightness adjustment  
- Smooth **fade** lighting effect  
- Separate control for “Window LED” and “Tree LED”  
- Wi-Fi communication (HTTP GET)  
- Built-in debounce for smoother UI  
- Shared **NetworkManager** networking layer

### Technologies

- **SwiftUI** — iOS + watchOS apps  
- **MicroPython** — ESP32 controller  
- PWM + Timers + lightweight HTTP server  
- Simple local network communication

