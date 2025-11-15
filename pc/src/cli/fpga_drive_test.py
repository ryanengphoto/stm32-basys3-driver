# Test script to test fpga ALU via UART communication directly from PC

import serial
import time

# -------------------------
# UART configuration
# -------------------------
COM_PORT = 'COM8'
BAUD = 115200
TIMEOUT = 0.1  # seconds

s = serial.Serial(COM_PORT, BAUD, timeout=TIMEOUT)

# -------------------------
# Helper functions
# -------------------------

def send_alu_packet(alu_sel, in_a, in_b):
    """
    Sends a 4-byte packet over UART to the ALU.
    Format: [in_a(14b) << 18 | in_b(14b) << 4 | alu_sel(4b)] little-endian
    """
    packet_val = (in_a << 18) | (in_b << 4) | (alu_sel & 0xF)
    packet_bytes = packet_val.to_bytes(4, byteorder='little')
    s.write(packet_bytes)
    return packet_val, packet_bytes

def read_alu_response():
    """
    Reads a 4-byte response from the ALU.
    """
    resp = s.read(4)
    if len(resp) != 4:
        return None
    return int.from_bytes(resp, byteorder='little')

def run_test(alu_sel, in_a, in_b, expected):
    """
    Sends a packet, reads response, checks against expected.
    """
    val, bytes_sent = send_alu_packet(alu_sel, in_a, in_b)
    print(f"Testing ALU sel={alu_sel}, a={in_a}, b={in_b}")
    print(f"Sent packet: 0x{val:08X} -> bytes {[hex(b) for b in bytes_sent]}")

    time.sleep(0.05)  # wait for MCU response

    resp_val = read_alu_response()
    if resp_val is None:
        print("FAIL: No response or timeout.")
        return False

    if resp_val == expected:
        print(f"PASS: got 0x{resp_val:08X} ({resp_val})")
        return True
    else:
        print(f"FAIL: got 0x{resp_val:08X} ({resp_val}), expected 0x{expected:08X} ({expected})")
        return False

# -------------------------
# Test vector list
# Format: (alu_sel, in_a, in_b, expected)
# -------------------------
test_vectors = [
    (0x0, 5, 3, 5 & 3),           # AND
    (0x1, 5, 3, 5 | 3),           # OR
    (0x2, 2, 3, 2 + 3),           # ADD
    (0x3, 5, 3, 5 ^ 3),           # XOR
    (0x4, 1, 2, 1 << 2),          # SLL
    (0x5, 8, 1, 8 >> 1),          # SRL
    (0x6, 5, 3, 5 - 3),           # SUB
    (0x7, 0xF0, 4, 0xF0 >> 4),    # SRA
    (0x8, -3 & 0x3FFF, 2, 1),     # SLT signed: -3 < 2
    (0x9, 1, 2, 1),               # SLTU unsigned: 1 < 2
    (0xA, 5, 3, ~(5 | 3) & 0xFFFFFFFF), # NOR
    (0xB, 5, 0, 6),               # INC
    (0xC, 5, 0, 4),               # DEC
    (0xD, 1, 2, ((1 << 2) | (1 >> (32 - 2))) & 0xFFFFFFFF), # ROL
    (0xE, 4, 1, ((4 >> 1) | (4 << (32 - 1))) & 0xFFFFFFFF), # ROR
]

# -------------------------
# Run all tests
# -------------------------
passed = 0
for alu_sel, in_a, in_b, expected in test_vectors:
    if run_test(alu_sel, in_a, in_b, expected):
        passed += 1
    time.sleep(0.05)

print(f"\nTest summary: {passed}/{len(test_vectors)} passed.")

# Close serial port
s.close()
