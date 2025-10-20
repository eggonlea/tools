.syntax unified
.arch armv7-a
.thumb

.macro ENTRY name
	.text
	.type \name, #function
	.hidden \name
	.global \name
	.balign 16
\name:
	.cfi_startproc
	.fnstart
.endm

.macro END name
	.fnend
	.cfi_endproc
	.size \name, .-\name
.endm

	.balign 16
_clock_gettime:
	.word __clock_gettime

ENTRY __getTickCount
	push	{lr}
	sub	sp, #12
 	movs	r0, #1
 	mov	r1, sp
 	ldr	r2, _clock_gettime
	ldr	r3, [r2]
	blx	r3
 	ldr	r3, [sp, #4]
 	movw	r2, #56963	/* 0xde83 */
 	movt	r2, #17179	/* 0x431b */
 	movw	r0, #1000	/* 0x3e8 */
 	smull	r1, r2, r2, r3
 	asrs	r3, r3, #31
 	rsb	r3, r3, r2, asr #18
 	ldr	r2, [sp, #0]
 	mla	r0, r0, r2, r3
	mov	r1, #0
 	add	sp, #12
 	pop	{pc}
 	nop
END __getTickCount

ENTRY __bench_asm_memwrite
	/* ptr in r0, size in r1 */
	stmdb	sp!, {r4, r5, r6, r7, r8, lr}
	/* bl loadLib */
	/* blx malloc */
	movs	r4, #0		/* score */
	movw	r7, #999	/* 0x270f */
	mov	r6, r0		/* ptr */
	bl	__getTickCount
	mov	r8, r0		/* begin */
_outer_loop:
	movs	r3, #0		/* i = 0 */
	mov	r2, r6		/* ptr */
_inner_loop:
#if 1
	str.w	r3, [r2], #4	/* ptr[i] = i */
#else
	str.w   r3, [r2, r3, lsl #2]
#endif
	adds	r3, #1		/* i++ */
	cmp.w	r3, #262144	/* 0x40000 */

	bne.n	_inner_loop
	bl	__getTickCount
	adds	r4, #1		/* score++ */
	rsb	r5, r8, r0	/* end */
	cmp	r5, r7
	ble.n	_outer_loop
	mov	r0, r6		/* ptr */
	/* blx free */
zzzz:
	mov	r0, r4
	ldmia	sp!, {r4, r5, r6, r7, r8, pc}
	
	vmov	s13, r5		/* duration */
	vcvt.f32.s32	s14, s13
	vldr	s15, _score_ratio
	vmov	s13, r4		/* score */
	vdiv.f32	s15, s14, s15	/* duration / ratio */
	vcvt.f32.s32	s14, s13
	vdiv.f32	s15, s14, s15	/* score * ratio / duration */
	vcvt.s32.f32	s15, s15
	vmov	r0, s15
	asrs	r1, r0, #31
	ldmia	sp!, {r4, r5, r6, r7, r8, pc}
END __bench_asm_memwrite

	.balign 16
_score_ratio:
	.word 0x447a0000

ENTRY __pTestSuspend
	bx	lr
END __pTestSuspend

ENTRY __pAllocArrayResolved
	mov	r0, r6
	bx	lr
END __pAllocArrayResolved

ENTRY __pF2l
	vcvt.s32.f32	s16, s16
	vmov	r0, s16
	mov	r1, #0
	bx	lr
END __pF2l

/*
 * V register <-> C stack mapping
 * v15 <-> [sp, #72]
 * v7  <-> [sp, #40] (wide)
 * v9  <-> [sp, #48] (wide)
 * v11 <-> [sp, #56] (wide)
 */
ENTRY __bench_java_memwrite
	/* ptr_array in r0, sc in r4 */
	mov	r6, r0
	add	r7, pc, _getTickCount3
	ldr	r4, _dummy_sc

	subs    r12, sp, #8192
	ldr.w   r12, [r12, #0]
	/* suspend point dex PC: 0x0000 */
	push    {r5, r6, r7, r8, r10, r11, lr}
	vpush.f32 {s16-s20}
	sub     sp, sp, #80
	str     r0, [sp, #0]

	/* const/high16 v15, #int +262144 (0x40000) */
	mov.w   r2, #262144
	str     r2, [sp, #72]

	/* const-wide/16 v0, #+0 */
	mov.w   r8, #0
	mov.w   r10, #0

	/* invoke-static {}, BenchJava.getTickCount() */
	mov     r0, r7
	ldr     lr, [r0, #12]
	ldr.w   lr, [r0, #1840]
	ldr.w   lr, [r0, #44]	/* getTickCount */
	blx     __getTickCount

	/* suspend point dex PC: 0x0004 */
	ldr.w   lr, __pAllocArrayResolved

	/* move-result-wide v7
	 * move-wide v9, v7
	 */
	strd    r0, r1, [sp, #+40]
	mov     r3, r0
	mov     r12, r1
	strd    r3, r12, [sp, #+48]

	/* new-array v2, v15, int[] */
	mov.w   r2, #262144
	mov     r1, r7
	movw    r0, #7240
	movt    r0, #28642
	blx     __pAllocArrayResolved

	/* suspend point dex PC: 0x0009 */
	mov	r6, r0

	/* sub-long v11, v9, v7
	 * if-ltz v11, +14
	 */
loop_head:
	ldrd    lr, r0, [sp, #+48]
	ldrd    r1, r2, [sp, #+40]
	subs.w  r3, lr, r1
	sbcs.w  r12, r0, r2
	strd    r3, r12, [sp, #+56]
	/* ldrd    r0, r1, [pc, #+304] */
	ldrd	r0, r1, _tick_duration
	strd    r0, r1, [sp, #+64]

	cmp     r12, r1
	blt.w   loop_start
	bgt.w   loop_end

	cmp     r3, r0
	bcc.w   loop_start

loop_end:
mov r0, r8
b zzz
	vmov.f64 d0, r8, r10
	vldr.f64 d3, _score_ratio3		/* 0x41f0000000000000 */
	vcvt.f64.s32 d1, s1
	vcvt.f64.u32 d2, s0
	vmla.f64 d2, d1, d3
	vcvt.f64.f32 d24, s4
	ldrd    r2,r3, [sp, #+48]
	ldrd    r12,lr, [sp, #+40]
	subs.w  r0, r2, r12
	sbcs.w  r1, r3, lr
	strd    r0,r1, [sp, #+56]
	vmov.f64 d4, r0, r1
	vldr.f64 d7, _score_ratio3		/* 0x41f0000000000000 */
	vcvt.f64.s32 d5, s9
	vcvt.f64.u32 d6, s8
	vmla.f64 d6, d5, d7
	vcvt.f64.f32 d25, s12
	vldr.f32 s20, _score_ratio2	/* 0x447a0000 */
	vdiv.f32 s18, s19, s20
	vdiv.f32 s16, s17, s18

	ldr.w   lr, _pF2l
	vmov.f32 r0, s16
	blx     lr

	strd    r0, r1, [sp, #+56]
	subs    r4, #1
	beq.w   test_suspend_1
post_test_suspend_1:
	ldrd    r0, r1, [sp, #+56]
zzz:
	add     sp, sp, #80
	vpop.f32 {s16-s20}
	pop     {r5, r6, r7, r8, r10, r11, pc}

loop_start:
	movs    r5, #0
	cbz     r6, loop_inner_head_bc

	ldr     r2, [r6, #8]	/* array.Length */
	mov     r3, r5
	cmp     r3, r2
	bcs.w   loop_inner_head_bc

	mov.w   r3, #262144
	subs    r3, r3, #1
	cmp     r3, r2
	bcs.w   loop_inner_head_bc

	adds    r1, r6, #12
loop_inner_head_nobc:
post_test_suspend_2:
	cmp.w   r5, #262144
	blt     loop_inner_body_nobc

	/* const-wide/16 v11, #+1
	 * add-long/2addr v0, v11
	 * invoke-static {}, BenchJava.getTickCount()
	 * move-result-wide v9
	 * goto -30
	 */
loop_inner_exit:
	mov.w   r12, #1
	movs    r0, #0
	strd    r12,r0, [sp, #+56]
	adds    r8, r8, #1
	adcs    r10, r10, #0

	/* invoke-static {}, BenchJava.getTickCount() */
	mov     r0, r7
	ldr     lr, [r0, #12]
	ldr.w   lr, [r0, #1840]
	ldr.w   lr, [r0, #44]	/* getTickCount */
	blx     __getTickCount

	/* suspend point dex PC: 0x0025 */
	/* GC map objects:  v2 (r6) */
	strd    r0, r1, [sp, #+48]
	b       loop_head

loop_inner_body_nobc:
	/*adds    r1, r6, #12*/
	str.w   r5, [r1, r5, lsl #2]
	adds    r5, r5, #1

	cmp	r5, #262144
	blt	loop_inner_body_nobc
	b	loop_inner_exit
#if 0
_inner_loop:
	str.w	r3, [r2], #4	/* ptr[i] = i */
	adds	r3, #1		/* i++ */
	cmp.w	r3, #262144	/* 0x40000 */
	bne.n	_inner_loop
	bl	__getTickCount
#endif

	/*subs    r4, #1*/
	bne.w   loop_inner_head_nobc
	b       test_suspend_2

loop_inner_head_bc:
post_test_suspend_3:
	cmp.w   r5, #262144
	blt     loop_inner_body_bc
	b       loop_inner_exit

loop_inner_body_bc:
	ldr     r3, [r6, #8]	/* array.Length */
	adds    r2, r6, #12
	cmp     r5, r3
	bcs.w   err_array_bound
	str.w   r5, [r2, r5, lsl #2]
	adds    r5, r5, #1
	subs    r4, #1
	bne.w   loop_inner_head_bc
	b       test_suspend_3

test_suspend_1:
	ldr.w   lr, __pTestSuspend
	blx     lr
	/* suspend point dex PC: 0x001e */
	/* b       -146 (0x00036bf0) */
	b	post_test_suspend_1

test_suspend_2:
	ldr.w   lr, __pTestSuspend
	blx     lr
	/* suspend point dex PC: 0x002e */
	/* GC map objects:  v2 (r6) */
	/* b       -114 (0x00036c18) */
	b	post_test_suspend_2

err_array_bound:
	ldr.w   lr, [r9, #568]  /* pThrowArrayBounds */
	mov     r0, r5
	mov     r1, r3
	blx     lr
	/* suspend point dex PC: 0x002a */

test_suspend_3:
	/* GC map objects:  v2 (r6) */
	ldr.w   lr, __pTestSuspend
	blx     lr
	/* suspend point dex PC: 0x002e */
	/* GC map objects:  v2 (r6) */
	/* b       -70 (0x00036c56) */
	b	post_test_suspend_3

	lsls    r0, r0, #0
	lsls    r0, r0, #0
	add     r2, pc
	lsls    r0, r0, #0
	lsls    r0, r0, #0
	lsls    r0, r0, #0
	ror     r0, r6
	movs    r7, #16
	lsls    r0, r0, #0
	lsls    r0, r0, #0
	lsls    r0, r0, #0
END   __bench_java_memwrite

	.balign 16
_pF2l:
	.word __pF2l
_tick_duration:
	.word 1000
	.word 0
_score_ratio3:
	.word 0
	.word 0x41f00000
_score_ratio2:
	.word 0x447a0000
_getTickCount3:
	.zero 12
	.word _getTickCount2
_getTickCount2:
	.zero 1840
	.word _getTickCount1
_getTickCount1:
	.zero 44
	.word __getTickCount
_dummy_sc:
	.word 0xffffffff	/* r4 */
