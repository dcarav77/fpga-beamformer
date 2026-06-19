#!/usr/bin/env python3

import serial
import time

PORT = "/dev/ttyUSB1"
BAUD = 115200

def main():

    ser = serial.Serial(PORT, BAUD, timeout=2)

    print(f"Opened {PORT} at {BAUD} baud")
    print("Waiting for UART data...")
    print("Press Ctrl+C to stop\n")

    try:

        while True:

            data = ser.read(100)

            if data:

                print(f"Received {len(data)} bytes")

                print(f"Hex:   {data.hex()}")

                print(f"Dec:   {list(data)}")

                print(
                    f"ASCII: "
                    f"{data.decode('ascii', errors='replace')!r}"
                )

                print()

            else:

                print(".", end="", flush=True)

                time.sleep(0.1)

    except KeyboardInterrupt:

        print("\nStopped")

    finally:

        ser.close()


if __name__ == "__main__":
    main()