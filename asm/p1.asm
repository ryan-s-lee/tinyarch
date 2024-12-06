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

// load integer value for conversion
mvi 0           # set frame pointer to address 0
sfp r7
sac r2          # put low bits of input into r2. It will become the mantissa.
ldi INLO
sti MANTLO

sac r0          # set accumulator to r0
ldi INHI        # load high input bits into r0 from mem. r0 will be the sign.
sti MANTHI
mov r1 r0       # copy high input bits into r1.

// determine sign
mvi 0x80        # mask only the high bits
ban r7


// decide whether to skip sign flip
nzs 4
mvi .get_exp hi
mov r6 r7
mvi .get_exp lo
jmp

// sign was negative. get positive complement
// simultaneously store unsigned int, as will come in handy later.
sac r2
bne
adi 1
sac r1
bne
adc
sti MANTHI
sac r2
sti MANTLO

// at this moment we have the unsigned int. if it is 0, the original input was
// 0 and we should exit right away, as the remaining code requires the input
// to be nonzero
.get_exp
sac r3
mov r3 r1
bor r2 r3
nzs 4
sac r1  # if r1 and r2 were nonzero, we would have skipped this. so r1 = 0
sti OUTHI
sti OUTLO
ext

// Recall: r0 -> sign, {r1, r2} -> unsigned integer input
// now, make r3 -> exponent
// use r4 -> condition for branching (is 0 while {r1, r2} is 0, and nonzero if not)
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

// if {r1, r2} != 0, loop back to beginning of while loop
sac r4
mov r4 r1
bor r2
lne
nzs 4
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
// now, r4 = 10 - exponent. This is the shift amount.

// before we get our mantissa, we have to load the input containing the mantissa back into {r1, r2}.
sac r1
ldi MANTHI
sac r2
ldi MANTLO

// move mantissa into place. If r4 is negative, move r2 first. Otherwise, move r1.
// TODO: Fix this! The shift amount is wrong. We can only shift between 1-8
sac r5      # let r5 decide whether to shift right or not.
mov r5 r4
mvi 0x80    # mask sign bit of r5 (shift amount).
ban r7
nzs 5       # if r5 is nonzero, then r4 (the shift amount) was negative/rightward. shift r1 first.
sac r2      # r4 was positive if we reached this instruction. shift r2 first, leftward.
lsr r4      
sac r1      # continue shift with r1
sho
skp 7       # skip the next 7 instructions, which are used to shift r1 to the right first.
sac r4      # flip the sign of the shift amount
bne
adi 1
sac r1      # shift {r1, r2} by r4, which is the amount needed to shift mantissa into place
rsr r4
sac r2      # continue shift with r2
sho

// mask mantissa
sac r1
mvi 0x03    # prepare mask to extract mantissa only
ban r7      # mask mantissa

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
ext
