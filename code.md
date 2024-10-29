# Program 1: int 2 float

## Pseudocode

```
int_to_float(in):
    # f16 is SEEEEEMMMMMMMMMM
    # Sign bit
    out[16];
    if in == 0:
        out = 0
        ack
    out[15] = in[15];
    magnitude = in[15] ? -in : in;
    exp_consume = magnitude
    exponent = -1;
    while exp_consume is not 0:
        exp_consume = exp_consume >> 1
        exponent += 1;
    mantissa = magnitude << (10 - exponent)
    exponent = exponent + 15
    
    
    out[14:10] = exponent[4:0]
    out[9:0] = mantissa[15:];
```

## Assembly 

```
// high in is stored at mem_core [0]
// low in is stored at mem_core [1]

#define INLO 0
#define INHI 1
#define OUTLO 2
#define OUTHI 3
#define SIGN 4
#define EXP 5
#define MANTLO 6
#define MANTHI 7
#define UNSIGNLO 8
#define UNSIGNLO 9

// load integer value for conversion
mvi 0           # set frame pointer to address 0
sfp r7
sac r2          # put low bits of input into r2
ldi INLO

sac r0          # set accumulator to r0
ldi INHI        # load high input bits into r0 from mem
mov r0 r1       # copy high input bits into r1. We will need that later.

// determine sign
mvi 0x80        # mask only the high bits
ban r7


// decide whether to skip sign flip
skp 4
mvi .get_exp hi
mov r6 r7
mvi .get_exp lo
jmp

// sign was negative. get positive complement
// simultaneously store unsigned int, as will come in handy later.
sac r2
bne
adi 1
sti UNSIGNLO
sac r1
bne
adc
sti UNSIGNHI

// at this moment we have the unsigned int. if it is 0, the original input was
// 0 and we should exist right away, as the remaining code requires the input
// to be nonzero
sac r3
mov r1 r3
bor r2 r3
skp 4
sac r1  # if r1 and r2 were nonzero, we would have skipped this. so r1 = 0
sti OUTHI
sti OUTLO
ext

// Recall: r0 -> sign, {r1, r2} -> unsigned integer input
// now, make r3 -> exponent
// use r4 -> condition for branching (is 0 while {r1, r2} is 0, and nonzero if not)
.get_exp
mvi -1
mov r3 r7

// while loop
.get_exp_l
// shift input integer downward
sac r1
rsi 1
sac r2
sho
sac r3
adi 1

// loop back to beginning of while loop
sac r4
mov r4 r1
bor r2
lne
skp 4
mvi .get_exp_l hi
mov r6 r7
mvi .get_exp_l lo
jmp

.get_mant
// The mantissa is simply the unsigned value's 10 highest elements.
// An easy way to extract it is to exploit the exponent we just got
sac r4
mov r4 r3   # move exponent into r4
bne         # negate it
adi 1
mvi 10      # add 10 to the negated exponent
adr r7

mvi 0x03    # prepare mask to extract mantissa only
sac r1      # shift {r1, r2} by r4, which is the amount needed to shift mantissa into place
lsh r4      # note that if r4 is negative, a right shift will occur (as intended)
and r7      # mask mantissa
sac r2      # continue shift with r2
sho

// Now that we've used the exponent to determine the shift amount
// we have the opportunity to bias it and shift it into place
sac r3
mvi 15
adr r7
lsi 2

// recall: r0 -> sign, {r1, r2} -> mantissa, r3 -> exponent
// since we're at r3, might as well build our high byte there.
bor r0
bor r1

// done!
sti OUTHI
sac r2
sti OUTLO
```

# Program 2: float 2 int

## Pseudocode

```
float_to_int(in):
    out[16];
    exponent = in[14:10] - 15
    # ignore numbers less than 1. Works for normalized, denormalized numbers and 0s
    if exponent is negative:
        out = 0
        ack
    left_shift_amount = exponent - 10
    out[14:0] = {1, in[9:0]} << left_shift_amount
    if in[15]:
        out = -out
    ack
```

## Assembly

```
#define INLO 0
#define INHI 1
#define OUTLO 2
#define OUTHI 3
mvi 4           # set frame pointer to address 4
sfp r7
sac r2          # put low bits of input into r2
ldi INLO

sac r0          # set accumulator to r0
```

# Program 3: float addition

## Pseudocode

```
float_add(f1, f2):
    out[16];
    subtracting = f1[15] ^ f2[15]
    # get difference between exponent
    exp1 = f1[14:10] - 15
    if f1[14:9] == 1:
        exp1 += 1
    exp2 = f2[14:10] - 15
    if f2[14:9] == 1:
        exp2 += 1
    exp_diff = f1[14:10] - f2[14:10]
    
    sign = f1[15]
    if exp_diff is negative:
        exp_diff = -expdiff
        max_mant = {1, f2}
        min_mant = {1, f1}
        exp = exp2
        sign = !sign
    else:
        max_mant = f1
        min_mant = f2
        exp = exp1

    if exp_diff > 11:
        out = {sign, exp, max_mant}
        ack

    min_mant = min_mant >> exp_diff
    if subtracting:
        sum = max_mant - min_mant
        if sum < 0:
            sum = -sum  # in the case that exp_diff == 0 and we didn't catch that min_mant was actually larger
            sign = !sign
        # shift down
        while sum[15:10] != 1:
            sum << 1
    else:
        sum = max_mant + min_mant

        if sum[11]:
            exp += 1
            sum >> 1
    result = {sign[0], exp[4:0], sum[9:0]}
```
