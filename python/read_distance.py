# python/read_distance.py

import serial

PORT = "/dev/ttyUSB1"
BAUD = 115200

CLOCK_HZ = 100_000_000
SPEED_OF_SOUND_M_S = 343.0

def echo_count_to_distance_cm(echo_count):
    echo_time_s = echo_count / CLOCK_HZ
    distance_m = echo_time_s * SPEED_OF_SOUND_M_S / 2
    return distance_m * 100

ser = serial.Serial(PORT, BAUD, timeout=1)

while True:
    data = ser.read(4)

    if len(data) != 4:
        continue

    echo_count = int.from_bytes(data, byteorder="little", signed=False)
    distance_cm = echo_count_to_distance_cm(echo_count)

    print(f"echo_count={echo_count} distance_cm={distance_cm:.2f}")