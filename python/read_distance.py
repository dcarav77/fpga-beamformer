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
    b = ser.read(1)

    if len(b) != 1:
        print("waiting for start byte...")
        continue

    if b[0] != START_BYTE:
        continue

    data = ser.read(4)

    if len(data) != 4:
        print(f"incomplete packet: got {len(data)} data bytes")
        continue

    echo_count = int.from_bytes(data, byteorder="little", signed=False)
    distance_cm = echo_count_to_distance_cm(echo_count)

    print(
        f"raw={data.hex()} "
        f"echo_count={echo_count:10d} "
        f"distance_cm={distance_cm:8.2f}"
    )