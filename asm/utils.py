from typing import Dict, Tuple
from errors import ZeroExtendError


class Context:
    def __init__(self) -> None:
        self.pc = 0
        self.macros: Dict[bytes, bytes] = {}
        self.labels: Dict[bytes, Tuple[bytes, bytes]] = {}

    def __add__(self, other) -> "Context":
        if type(other) is int:
            self.pc += other
        else:
            raise ValueError("Cannot add anything other than an integer to Context")
        return self

    def reset_pc(self):
        self.pc = 0

    def add_label(self, label):
        addr_encod = zero_extend(bin(self.pc)[2:].encode(), 16)
        # print(f"{label}: {addr_encod}")
        self.labels[label] = (addr_encod[0:8], addr_encod[8:])

    def add_macro(self, macro, value):
        self.macros[macro] = value

    def del_macro(self, macro):
        del self.macros[macro]


def literal_as_bytes(literal: bytes, is_shift_imm_lit=False) -> bytes:
    literal_as_int = int(literal, 0) & 0b11111111
    if is_shift_imm_lit:
        literal_as_int -= 1
    return bin(literal_as_int)[2:].encode()


def zero_extend(to_extend: bytes, new_len: int):
    if (len(to_extend) > new_len):
        raise ZeroExtendError()
    return (b"0" * (new_len - len(to_extend))) + to_extend


def reg_as_bytes(reg_token: bytes) -> bytes:
    if not reg_token.startswith(b"r"):
        raise SyntaxError()
    return zero_extend(literal_as_bytes(reg_token[1:]), 3)
