import re
from typing import List
from errors import ZeroExtendError
from utils import literal_as_bytes, reg_as_bytes, zero_extend, Context


def mov_handler(ctx, args: List[bytes], linenum):
    try:
        return b"100" + reg_as_bytes(args[1]) + reg_as_bytes(args[2])
    except ValueError:
        raise ValueError(  # add a custom message
            f"Register at line {linenum} could not be addressed."
            "Only registers 0 through 7 may be addressed (r0 - r7)"
        )
    except ZeroExtendError:
        raise SyntaxError(f"Frame base offset too large at line {linenum}.")


def single_immediate_handler(
    ctx: Context, args: List[bytes], linenum: int, opcod: bytes, instruction_width=9
):
    try:
        # TODO/BUG: labels should only really be used with mvi, but
        # the way this code is written we can get cryptic messages
        # if we misuse labels. Make code more robust (e.g. check if
        # final opcode is too small)
        if args[1] in ctx.labels:
            hi, lo = ctx.labels[args[1]]
            if args[2] not in [b"hi", b"lo"]:
                bad_label_ref = b" ".join(args[1:2])
                raise SyntaxError(f"Illegal label ref at line {linenum}: {bad_label_ref}")
            return opcod + (hi if args[2] == b"hi" else lo)
        return opcod + zero_extend(
            literal_as_bytes(args[1], is_shift_imm_lit=(args[0] in [b"rsi", b"lsi"])), instruction_width - len(opcod)
        )
    except ZeroExtendError:
        raise SyntaxError(
            f"Immediate was too large for opcod {opcod} at line {linenum}"
        )


def single_reg_handler(ctx, args, linenum, opcod):
    try:
        return opcod + reg_as_bytes(args[1])
    except ValueError:
        raise ValueError(  # add a custom message
            f"Register at line {linenum} could not be addressed."
            "Only registers 0 through 7 may be addressed (r0 - r7)"
        )


def skip_handler(ctx, args, linenum, opcod):
    # nzs imm(1 thru 8)
    # replace the immediate text with a version with 1 subtracted
    # BUG: as args is mutated here, bugs may occur if args is reused after
    # skip_handler is called.
    args[1] = str(int(args[1]) - 1).encode()
    return single_immediate_handler(ctx, args, linenum, opcod)


# macro handlers

def macro_handler_define(ctx: Context, args: List[bytes]) -> None:
    ctx.add_macro(args[1], b" ".join(args[2:]) if len(args) > 2 else None)


def macro_handler_undefine(ctx: Context, args: List[bytes]) -> None:
    ctx.del_macro(args[1])


def macros_applied(ctx: Context, line: bytes) -> bytes:
    regex = br"(\s+)"
    macros_separated = re.split(regex, line)
    for i in range(len(macros_separated)):
        if macros_separated[i].startswith(b"#"):
            macros_separated = macros_separated[0:i] + [b"\n"]
            break
        if (macros_separated[i] in ctx.macros):
            macros_separated[i] = ctx.macros[macros_separated[i]]

    return b"".join(macros_separated)
