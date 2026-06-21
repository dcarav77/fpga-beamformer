# rate_test.py
import serial
import time

PORT = "/dev/ttyUSB1"
BAUD = 115200
START_BYTE = 0xAA

ser = serial.Serial(PORT, BAUD, timeout=1)
ser.reset_input_buffer()
time.sleep(0.5)

print("Counting packets for 10 seconds...")
print("(Move your hand near the HC-SR04)")

count = 0
start = time.time()

while time.time() - start < 10:
    b = ser.read(1)
    if b and b[0] == START_BYTE:
        data = ser.read(4)
        if len(data) == 4:
            count += 1
            echo_count = int.from_bytes(data, byteorder="little", signed=False)
            distance_cm = echo_count / 100_000_000 * 343.0 / 2 * 100
            print(f"Packet {count}: distance={distance_cm:.2f} cm", end="\r")

print(f"\n\nReceived {count} packets in 10 seconds")
print(f"Rate: {count/10:.1f} packets/second")