#!/usr/bin/env python3
#-------------------------------------------------------------------------------
# read_distance.py
#
# Purpose:
# Read and decode ultrasonic distance measurements from the FPGA over UART.
#
# Hardware Pipeline:
#   HC-SR04 → FPGA → UART → USB → Linux (/dev/ttyUSB1) → Python
#
# Packet Format (5 bytes total):
#   [0xAA] [byte0] [byte1] [byte2] [byte3]
#      ↑      ↑       ↑       ↑       ↑
#   Start   echo_count[7:0]  [15:8]  [23:16] [31:24]
#   Byte    (LSB)                    (MSB)
#
# How Python Receives and Decodes:
#
#   1. BYTE RECEPTION:
#      - The FTDI chip on the Basys 3 converts the serial UART bits back into bytes
#      - Linux presents these bytes through /dev/ttyUSB1 as a continuous stream
#      - Python's pyserial library reads bytes one at a time via ser.read()
#
#   2. PACKET SYNCHRONIZATION:
#      - The UART stream has no inherent packet boundaries
#      - The FPGA starts every measurement packet with 0xAA (start byte)
#      - Python scans the byte stream until it finds 0xAA
#      - This guarantees we're aligned to the start of a packet
#
#   3. DATA EXTRACTION:
#      - After finding 0xAA, Python reads exactly 4 bytes
#      - These 4 bytes contain the 32-bit echo_count (LSB first)
#      - int.from_bytes() recombines the 4 bytes into a single integer
#
#   4. DISTANCE CALCULATION:
#      - echo_count = number of clock cycles the ECHO pulse lasted
#      - echo_time_s = echo_count / CLOCK_HZ (convert cycles to seconds)
#      - distance_m = echo_time_s * SPEED_OF_SOUND_M_S / 2 (round-trip / 2)
#      - distance_cm = distance_m * 100 (convert to centimeters)
#
# Data Flow Example:
#   FPGA sends:     AA 51 B6 01 00
#   Python finds:   AA (start byte)
#   Reads next 4:   51 B6 01 00
#   Reconstructs:   0x0001B651 = 112,209
#   Calculates:     112,209 / 100,000,000 * 343 / 2 * 100 = 19.24 cm
#
# Notes:
#   - The HC-SR04 has a range of 2 cm to 400 cm
#   - Values outside this range indicate noise or misalignment
#   - Packet framing (0xAA) ensures we never misalign with the byte stream
#-------------------------------------------------------------------------------

import serial

PORT = "/dev/ttyUSB1"
BAUD = 115200

START_BYTE = 0xAA

CLOCK_HZ = 100_000_000
SPEED_OF_SOUND_M_S = 343.0

def echo_count_to_distance_cm(echo_count):
    echo_time_s = echo_count / CLOCK_HZ
    return echo_time_s * SPEED_OF_SOUND_M_S / 2 * 100

ser = serial.Serial(PORT, BAUD, timeout=2)
ser.reset_input_buffer()

print(f"Opened {PORT} at {BAUD}")
print("Looking for framed packets: AA + 4 data bytes")

while True:
    # Step 1: Read one byte from the UART stream
    # This byte is already grouped by the FTDI chip (hardware)
    b = ser.read(1)

    if len(b) != 1:
        print("waiting for start byte...")
        continue

    # Step 2: Check if this byte is the start of a packet (0xAA)
    if b[0] != START_BYTE:
        continue

    # Step 3: Found start byte! Read the next 4 bytes (the data payload)
    data = ser.read(4)

    if len(data) != 4:
        print(f"incomplete packet: got {len(data)} data bytes")
        continue

    # Step 4: Combine 4 bytes into a 32-bit integer (little-endian)
    # Example: [0x51, 0xB6, 0x01, 0x00] → 0x0001B651
    echo_count = int.from_bytes(data, byteorder="little", signed=False)

    # Step 5: Convert echo_count to distance in centimeters
    distance_cm = echo_count_to_distance_cm(echo_count)

    # Step 6: Display the result
    print(
        f"raw={data.hex()} "
        f"echo_count={echo_count:10d} "
        f"distance_cm={distance_cm:8.2f}"
    )