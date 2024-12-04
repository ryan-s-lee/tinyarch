#!/usr/bin/python
import sys
import argparse
from tempfile import TemporaryFile
from typing import Optional
from handlers import (
    macro_handler_define,
    macro_handler_undefine,
    macros_applied,
    mov_handler,
    single_immediate_handler,
    single_reg_handler,
    skip_handler,
)
from utils import Context

"""
Command argument: an assembly file for tinyarch
Side effect: emit a text file with binary translations of each instruction
on each line
"""

bytecode_emission_functable = {
    b"mvi": lambda ctx, args, linenum: single_immediate_handler(
        ctx, args, linenum, opcod=b"0"
    ),
    b"mov": lambda ctx, args, linenum: mov_handler(ctx, args, linenum),
    b"ldi": lambda ctx, args, linenum: single_immediate_handler(
        ctx, args, linenum, opcod=b"1010"
    ),
    b"sti": lambda ctx, args, linenum: single_immediate_handler(
        ctx, args, linenum, opcod=b"1011"
    ),
    b"adi": lambda ctx, args, linenum: single_immediate_handler(
        ctx, args, linenum, opcod=b"110000"
    ),
    b"adr": lambda ctx, args, linenum: single_reg_handler(
        ctx, args, linenum, opcod=b"110001"
    ),
    b"rsi": lambda ctx, args, linenum: single_immediate_handler(
        ctx, args, linenum, opcod=b"110010"
    ),
    b"rsr": lambda ctx, args, linenum: single_reg_handler(
        ctx, args, linenum, opcod=b"110011"
    ),
    b"lsi": lambda ctx, args, linenum: single_immediate_handler(
        ctx, args, linenum, opcod=b"110100"
    ),
    b"lsr": lambda ctx, args, linenum: single_reg_handler(
        ctx, args, linenum, opcod=b"110101"
    ),
    b"nzs": lambda ctx, args, linenum: skip_handler(
        ctx, args, linenum, opcod=b"110110"
    ),
    b"bor": lambda ctx, args, linenum: single_reg_handler(
        ctx, args, linenum, opcod=b"110111"
    ),
    b"skp": lambda ctx, args, linenum: skip_handler(
        ctx, args, linenum, opcod=b"111000"
    ),
    b"ban": lambda ctx, args, linenum: single_reg_handler(
        ctx, args, linenum, opcod=b"111001"
    ),
    b"lod": lambda ctx, args, linenum: single_reg_handler(
        ctx, args, linenum, opcod=b"111010"
    ),
    b"str": lambda ctx, args, linenum: single_reg_handler(
        ctx, args, linenum, opcod=b"111011"
    ),
    b"sac": lambda ctx, args, linenum: single_reg_handler(
        ctx, args, linenum, opcod=b"111100"
    ),
    b"sfp": lambda ctx, args, linenum: single_reg_handler(
        ctx, args, linenum, opcod=b"111101"
    ),
    b"bne": lambda _0, _1, _2: b"111111000",
    b"lne": lambda _0, _1, _2: b"111111001",
    b"sho": lambda _0, _1, _2: b"111111010",
    b"adc": lambda _0, _1, _2: b"111111011",
    b"ext": lambda _0, _1, _2: b"111111100",
    b"nop": lambda _0, _1, _2: b"111111101",
    b"jmp": lambda _0, _1, _2: b"111111110",
}

macro_behavior_functable = {
    b"#define": macro_handler_define,
    b"#undefine": macro_handler_undefine,
}


def translate_line(ctx: Context, line: bytes, linenum) -> Optional[bytes]:
    """
    TODO:
    - Label handling
    """
    args = line.split()
    if len(args) == 0 or args[0].startswith(b"//"):
        return None
    try:
        emitted_bytecode = bytecode_emission_functable[line[0:3]](
            ctx, line.split(), linenum
        )
    except KeyError:
        raise SyntaxError(f"Could not find command at line {linenum}.\n{linenum}: {line}")
    except Exception as e:
        raise Exception(f"an unexpected error occurd.\n{linenum}: {line}") from e

    ctx += 1
    return emitted_bytecode


def preprocess_line(ctx: Context, line: bytes, linenum: int) -> Optional[bytes]:
    # if the line is a macro or a label, update context
    # if it is a comment or a blank line, remove it.
    tokenized_line = line.split()
    if not tokenized_line or tokenized_line[0].startswith(b"//"):
        return None
    elif tokenized_line[0].startswith(b"#"):
        macro_behavior_functable[tokenized_line[0]](ctx, tokenized_line)
        return None
    elif tokenized_line[0].startswith(b"."):
        ctx.add_label(tokenized_line[0])
        return None
    else:
        preprocessed_line = macros_applied(ctx, line)
        ctx += 1
        return preprocessed_line


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="Eepy ISA Assembler", usage="./tinyasm.py <asmfile>"
    )
    parser.add_argument("asmfile")
    parser.add_argument("-p", "--preprocessed", action="store_true")
    # TODO: add option to output preprocessed file, for testing.
    args = parser.parse_args()

    outf = sys.stdout.buffer

    with open(args.asmfile, "br") as asmf, TemporaryFile() as tmpf:
        ctx = Context()
        # preprocess
        if args.preprocessed:
            tmpf = outf
        for i, line in enumerate(asmf):
            if (preprocessed_line := preprocess_line(ctx, line, i)) is not None:
                tmpf.write(preprocessed_line)
        if args.preprocessed:
            exit()

        # assemble
        tmpf.flush()
        tmpf.seek(0)
        ctx.reset_pc()
        for i, line in enumerate(tmpf):
            # outf.write(line)
            if (bytecode := translate_line(ctx, line, i)) is not None:
                outf.write(bytecode + b"\n")
