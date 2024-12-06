#define F0HI 0
#define F0LO 1
#define F1HI 2
#define F1LO 3
#define OUTHI 4
#define OUTLO 5

// Local
#define sign 6
#define f0exp 7
#define f1exp 8
#define f0manthi 9
#define f0mantlo 1
#define f1manthi 11
#define f1mantlo 3
#define expdiff 13
#define mantsumlo 14
#define mantsumhi 15
#define SIGNMASK 0x80
#define EXPMASK 0x7c
#define HIMANTMASK 0x3
#define BIT3MASK 0x08
#define BIT2MASK 0x04

#define IMPLIEDONE 0x04
#define IMPLIEDZERO 0xfb

mvi 128
sfp r7

// extract sign from f0hi
sac r0
ldi F0HI
mvi SIGNMASK
ban r7
sti sign

// extract biased exponents and hi mantissas from f0hi and f1hi
// place the implied 1 in front of both mantissas. Will be undone for denormed floats
ldi F0HI
mvi EXPMASK
ban r7
rsi 2
sti f0exp

ldi F0HI
mvi HIMANTMASK
ban r7
mvi IMPLIEDONE
bor r7
sti f0manthi

ldi F1HI
mvi EXPMASK
ban r7
rsi 2
sti f1exp

ldi F1HI
mvi HIMANTMASK
ban r7
mvi IMPLIEDONE
bor r7
sti f1manthi

// if f0exp = 0, go to 0 special case code. Otherwise, jump past it.
ldi f0exp
lne
nzs 4
mvi .f1_exp_zero_check hi
mov r6 r7
mvi .f1_exp_zero_check lo
jmp

// f0exp = 0. If manthi and mantlo are 0, then the whole number is just 0.
ldi f0manthi
mvi HIMANTMASK  # mask out the implied 1 we just inserted, which interferes
ban r7
mov r1 r0
ldi f0mantlo
bor r1
// if 0, f0 = 0, so return f1; otherwise jump past to the f0 = denorm case.
nzs 5
ldi F1HI
sti OUTHI
ldi F1LO
sti OUTLO
ext

// f0 is a denormalized float representation.
// add 1 to exponent (to "normalize") and get rid of implied 1.
ldi f0manthi
mvi IMPLIEDZERO    # 0 out the implied one
ban r7
sti f0manthi
ldi f0exp
adi 1
sti f0exp

// repeat check and special case for f1
.f1_exp_zero_check
// if f1exp = 0, go to 0 special case code. Otherwise, jump past it.
ldi f1exp
lne
nzs 4
mvi .get_expdiff hi
mov r6 r7
mvi .get_expdiff lo
jmp

// f1exp = 0. If manthi and mantlo are 0, then the whole number is just 0.
ldi f1manthi
mvi HIMANTMASK  # mask out the implied 1 we just inserted, which interferes
ban r7
mov r1 r0
ldi f1mantlo
bor r1
// if 0, f1 = 0, so return f0; otherwise jump past to the f1 = denorm case.
nzs 5
ldi F0HI
sti OUTHI
ldi F0LO
sti OUTLO
ext

// f1 is a denormalized float representation.
// add 1 to exponent (to "normalize") and get rid of implied 1.
ldi f1manthi
mvi IMPLIEDZERO    # 0 out the implied one
ban r7
sti f1manthi
ldi f1exp
adi 1
sti f1exp

.get_expdiff
ldi f1exp
bne
adi 1
mov r1 r0
ldi f0exp
adr r1
sti expdiff

// If difference in exponents is less than 0, then f1exp > f0exp
mvi SIGNMASK
ban r7
nzs 4
mvi .shift_f1 hi
mov r6 r7
mvi .shift_f1 lo
jmp

// f1exp > f0exp, but we only shift f1. So swap all f1 values with f0 values
// swap f0exp with f1exp
ldi f0exp
mov r1 r0
ldi f1exp
sti f0exp
mov r0 r1
sti f1exp

// swap f0manthi with f1manthi
ldi f0manthi
mov r1 r0
ldi f1manthi
sti f0manthi
mov r0 r1
sti f1manthi

// swap f0mantlo with f1mantlo
ldi f0mantlo
mov r1 r0
ldi f1mantlo
sti f0mantlo
mov r0 r1
sti f1mantlo

// now that f0exp > f1exp, swap the sign of the expdiff, for later use
ldi expdiff
bne
adi 1
sti expdiff

.shift_f1
// shift f1 mantissa by expdiff
ldi expdiff
mov r1 r0
ldi f1manthi
rsr r1
sti f1manthi
ldi f1mantlo
sho
sti f1mantlo

// add the mantissas; no need to account for rounding to nearest even
ldi f1manthi
mov r3 r0
ldi f0manthi
mov r2 r0
ldi f1mantlo
mov r1 r0
ldi f0mantlo
adr r1
sac r2
adc
adr r3
sti mantsumhi
sac r0
sti mantsumlo

// if bit3 of mantissa high word is 1, the mantissa must be shifted down to fit lowest 10 bits
ldi mantsumhi
mvi BIT3MASK
ban r7
nzs 4           # if bit3 is 0, skip to the bit2 check
mvi .mantsumhi_bit2_check hi
mov r6 r7
mvi .mantsumhi_bit2_check lo
jmp

ldi mantsumhi
rsi 1
sti mantsumhi
ldi mantsumlo
sho
sti mantsumlo
ldi f0exp
adi 1
sti f0exp
// if bit3 was 1, we don't want to check bit2 anymore.
mvi .avengers_assemble hi
mov r6 r7
mvi .avengers_assemble lo
jmp

.mantsumhi_bit2_check
ldi mantsumhi
mvi BIT2MASK
ban r7
nzs 3
mvi 0
mov r7 r0
sti f0exp

.avengers_assemble
ldi mantsumhi
mvi IMPLIEDZERO
ban r7
mov r1 r0
ldi f0exp
lsi 2
bor r1
mov r1 r0
ldi sign
bor r1
sti OUTHI
ldi mantsumlo
sti OUTLO
ext
