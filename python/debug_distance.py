# debug_raw.py - Shows every byte received
import serial

ser = serial.Serial("/dev/ttyUSB1", 115200, timeout=1)
ser.reset_input_buffer()

print("Raw bytes from FPGA (hex):")
print("Press Ctrl+C to stop")

while True:
    data = ser.read(ser.in_waiting or 1)
    if data:
        for b in data:
            print(f"{b:02X} ", end="", flush=True)