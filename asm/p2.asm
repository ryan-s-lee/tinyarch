#define INLO 0
#define INHI 1
#define OUTLO 2
#define OUTHI 3
mvi 4           # set frame pointer to address 4
sfp r7

sac r4          # get r4 = sign
ldi INHI
mov r2 r4       # put high bits into r2, as it will be used later
mvi 0x80
ban r7

// get the exponent
sac r0          # set accumulator to r0
ldi INHI        # get high bits, where exponent is located
mvi 0x7c        # get exponent mask
ban r7          # mask exponent
rsi 2           # shift exponent into place
mvi -15         # remove exponent bias
adr r7          # remove exponent bias

// if exponent is negative, exit early
sac r1          # r1 will store our decision
mov r1 r0       # r0 is the exponent we want to check
mvi 0x80        # mask the sign bit out
ban r7
lne             # if sign bit is 1 (negative), DONT skip the early exit. So, NOT it.
nzs 3
sti OUTLO
sti OUTHI
ext

// if exponent is greater than or equal to 15, return an infinity
// again, r1 will store our decision.
mov r1 r0       # r0 is the exponent to check
mvi -15         # subtract 15
adr r7
mvi 0x80        # mask the sign bit out of the difference
ban r7          # a positive diff means (exponent >= 15)
lne             # 
nzs 4           # if diff was positive, r1 will be nonzero. return one of the infinities based on sign
mvi .handle_nontrivial hi       # otherwise, jump to the code handling the nontrivial case.
mov r6 r7
mvi .handle_nontrivial lo
jmp

sac r4
nzs 6
// float was positive
sac r7
mvi 0x7f
sti OUTHI
mvi 0xff
sti OUTLO
ext
// float was negative
sti OUTHI       # conveniently, r4 stores the high bits of the value we want to return
sac r7
mvi 0x00
sti OUTLO
ext

// exponent is not too small/big for ints. We have an actual nontrivial integer on our hands
// Compute the amount we have to shift the mantissa with leading 1 to obtain
// final answer
.handle_nontrivial
sac r0          # r0 = exponent, so set it as the accumulator
mvi -10         # shift amount is (exponent - 10)
adr r7          # 

//get the mantissa, stored in {r2, r3}
sac r3          # do low mantissa first; want to operate on high mantissa after
ldi INLO
sac r2          # high mantissa previously stored in r2
mvi 0x03        # mask out non-mantissa bits
ban r7

// stick a one in front of the mantissa
mvi 0x04
bor r7

// shift the mantissa with the 1 until it becomes the integer value
// recall the shift amount was stored in r0
sac r5      # let r5 decide whether we will shift {r2, r3} right or not.
mov r5 r0
mvi 0x80    # mask sign bit
ban r7
nzs 5       # if r5 is nonzero, then r0 (the shift amount) was negative. shift r1 first.
sac r3      # r0 was positive if we reached this instruction. shift r2 first.
lsr r0      
sac r2      # continue shift with r1
sho
skp 7       # skip the next 4 instructions, which are used to shift r1 to the right first.
sac r0      # arithmetic negate r0, because I forgot to implement shifting with negative nums
bne
adi 1
sac r2      # shift {r2, r3} by r0, which is the amount needed to shift mantissa into place
rsr r0
sac r3      # continue shift with r3
sho

// if the float was signed, negate.
// utilize r4, which contains the float sign.
sac r4
lne         # if sign is negative (1), DONT skip. so we have to NOT r4.
nzs 4
sac r3
bne
adi 1
sac r2
bne
adc

// Final integer is stored in {r2, r3}.
sac r2
sti OUTHI
sac r3
sti OUTLO
ext
