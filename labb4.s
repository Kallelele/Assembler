#include <idtcpu.h>
#include <iregdef.h>

#define INT3 0x2000
#define INT4 0x4000
#define HGRON 0x80
#define KGRON 0x01
#define INTERRUPT	0xbfa00000
#define KNAPP1 0x2
#define KNAPP11 0x5
#define TIMER 0x4
#define LIGHT 0xbf900000
#define EXCMASK 0x003C
.data
 time: .word 0
 ljus2gron: .word 0
 bilpa2: .word 0

.text

.globl intstub
.ent intstub
.set noreorder

intstub: 
j int_routine
nop

.end intstub

.set reorder
.globl int_routine
.ent int_routine

int_routine:	#AVBROTTSRUTINEN
subu sp,sp,44
sw s7,40(sp)
sw t1,36(sp)
sw t0,32(sp)
sw s6,28(sp)
sw s5,24(sp)
sw s0,20(sp)
sw s1,16(sp)
sw s2,12(sp)
sw s3,8(sp)
sw s4,4(sp)

mfc0 k0,C0_CAUSE

//andi s7,k0,EXCMASK
la s4,INTERRUPT
lb s6,0(s4)

nop

nop
lw t0, time
nop
// Kolla om knapp är tryckt 

andi s5,s6,TIMER
nop
bne s5,TIMER,SLUT
nop
bge t0,9,TIMELABEL
nop
addi t0,t0,1
sw t0, time
b SLUT
nop

TIMELABEL:
lw s1,bilpa2
nop
lw t2, ljus2gron
nop
beq s1,1,CAR
nop
beq t2,0,SLUT
nop
sw zero,time
sw zero,ljus2gron
li s0, HGRON
sb s0, LIGHT
b SLUT

CAR:
sw zero,time
li t2,1
sw t2,ljus2gron
sw zero,bilpa2
li s0, KGRON
sb s0, LIGHT
b SLUT

KNAPP:
lw t1,bilpa2
nop
lw t2,ljus2gron
nop
beq t2,1,Restore
nop
addi t1,zero,1
sw t1,bilpa2
b Restore

SLUT:
andi s5,s6,KNAPP1
beq s5,KNAPP1,KNAPP
nop

Restore:
addi t0,zero,1
nop
sb t0,0xbfa00000
lw s7,40(sp)
lw t1,36(sp)
lw t0,32(sp)
lw s6,28(sp)
lw s5,24(sp)
lw s0,20(sp)
lw s1,16(sp)
lw s2,12(sp)
lw s3,8(sp)
lw s4,4(sp)
addu sp,sp,44


mfc0 k0,C0_EPC
.set noreorder
jr k0
rfe
.set reorder
.end int_routine

.globl start
.ent start

start:
la t0,intstub
la t1,0x80000080
lw t2,0(t0)
lw t3,4(t0)
sw t2,0(t1)
sw t3,4(t1)

mfc0 t0,C0_SR
ori t0,t0,1

ori t0,t0,INT3
ori t0,t0,INT4

mtc0 t0,C0_SR

li t6, HGRON
sb t6, LIGHT

L:
	b L
	nop

.end start
