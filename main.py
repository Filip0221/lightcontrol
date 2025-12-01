import network
import socket
from machine import Pin, PWM, Timer
import _thread
import time

# Konfiguracja sieci WiFi
SSID = 'PLAY_Swiatlowodowy_5499'
PASSWORD = 'hZ1FvRaG$Enq'
STATIC_IP = '192.168.0.147'
SUBNET_MASK = '255.255.255.0'
GATEWAY = '192.168.0.1'
DNS = '192.168.0.1'

# Połączenie z WiFi
def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.ifconfig((STATIC_IP, SUBNET_MASK, GATEWAY, DNS))
    wlan.connect(SSID, PASSWORD)
    while not wlan.isconnected():
        pass
    print('Połączono z WiFi:', wlan.ifconfig())

# Ustawienie pinów wyjściowych
pwm_pin1 = PWM(Pin(6), freq=1000)
pwm_pin2 = PWM(Pin(7), freq=1000)
pwm_pin3 = PWM(Pin(5), freq=1000)
timer = Timer(0)
timer0 = True
wypelnienie = 1
toggle = True
fade_timer = Timer(-1)
czy_pracowac = False

# Funkcje uruchamijące piny
def zmiana(timer0):
    global toggle, wypelnienie
    if timer0:
        if toggle:
            pwm_pin1.duty_u16(65534 // wypelnienie)  # 100% wypełnienia dla pwm_pin1
            pwm_pin2.duty_u16(0)  # 0% wypełnienia dla pwm_pin2
        else:
            pwm_pin1.duty_u16(0)  # 0% wypełnienia dla pwm_pin1
            pwm_pin2.duty_u16(65534 // wypelnienie)  # 100% wypełnienia dla pwm_pin2

        toggle = not toggle  # Zmiana stanu

def timer_thread():
    global czy_pracowac
    czy_pracuje = True
    while True:
        if czy_pracowac and czy_pracuje:
            timer.init(period=10, mode=Timer.PERIODIC, callback=lambda t: zmiana(timer0))
            czy_pracuje = False
        elif czy_pracowac == False:
            timer.deinit()
            pwm_pin1.duty_u16(0)
            pwm_pin2.duty_u16(0)
            czy_pracuje = True
        time.sleep(0.01)  # Dodaj niewielkie opóźnienie, aby zmniejszyć obciążenie procesora

# Uruchomienie timera w osobnym wątku
_thread.start_new_thread(timer_thread, ())
    
def led_fade():
    duty = 0
    direction = 1

    def fade(t):
        nonlocal duty, direction
        duty += direction * 500  # Reduce the step size for smoother fading
        if duty >= 65535:
            duty = 65535
            direction = -1
        elif duty <= 10000:
            duty = 10000
            direction = 1
        pwm_pin3.duty_u16(duty)

    fade_timer.init(period=20, mode=Timer.PERIODIC, callback=fade)  # Reduce period for faster updates

# Funkcja zatrzymania efektu fade
def stop_fade():
    fade_timer.deinit()
    pwm_pin3.duty_u16(0)  # Ustawienie wypełnienia na 0

# Funkcja włączenia stałego świecenia LED na pwm_pin3
def led_on():
    stop_fade()  # Najpierw zatrzymaj fade, jeśli jest aktywny
    pwm_pin3.duty_u16(65535)  # Ustawienie maksymalnego wypełnienia

# Start połączenia z WiFi
connect_wifi()

# Utworzenie gniazda serwera
addr = socket.getaddrinfo('0.0.0.0', 80)[0][-1]
s = socket.socket()
s.bind(addr)
s.listen(1)

print('Oczekiwanie na połączenie...')

while True:
    cl, addr = s.accept()
    print('Połączenie od', addr)
    request = cl.recv(1024)
    request = str(request)
    
    # Parsowanie żądania HTTP
    if '/on1' in request:
        czy_pracowac = True
        response_code = 200
    elif '/off1' in request:
        czy_pracowac = False
        response_code = 200
    elif '/on2' in request:
        led_on()
        response_code = 200
    elif '/fade' in request:
        led_fade()
        response_code = 200
    elif '/off2' in request:
        stop_fade()
        response_code = 200
    elif 'update_var' in request:
        try:
            value = request.split('update_var?value=')[1].split(' ')[0]
            wypelnienie = int(value)
            response += f"Variable updated to: {wypelnienie}"
            print(f"Variable updated to: {wypelnienie}")
        except Exception as e:
            print('Error:', e)
            response += "Invalid variable update request"
    else:
        response_code = 404
    
    
    # Przygotowanie odpowiedzi HTML
    response = """
    <html>
    <head>
        <title>Sterowanie ESP32</title>
    </head>
    <body>
        <h1>Sterowanie wyjściami ESP32</h1>
        <p><a href="/on1">wlacz led okno </a></p>
        <p><a href="/off1">wylacz led okno</a></p>
        <p><a href="/on2">wlacz led choinka</a></p>
        <p><a href="/fade">wlacz fade</a></p>
        <p><a href="/off2">wylacz led choinka</a></p>
    </body>
    </html>
    """
    
    # Wysłanie odpowiedzi
    cl.send('HTTP/1.1 200 OK\r\n')
    cl.send('Content-Type: text/html\r\n')
    cl.send('Connection: close\r\n\r\n')
    cl.sendall(response)
    cl.close()
