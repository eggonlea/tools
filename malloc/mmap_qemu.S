
mmap:     file format elf32-littlearm


00008d70 <main>:
    8d70:	e92d4830 	push	{r4, r5, fp, lr}
    8d74:	e28db00c 	add	fp, sp, #12
    8d78:	e24dd030 	sub	sp, sp, #48	; 0x30
    8d7c:	e24b3020 	sub	r3, fp, #32
    8d80:	e50b301c 	str	r3, [fp, #-28]
    8d84:	e24b3020 	sub	r3, fp, #32
    8d88:	e50b3018 	str	r3, [fp, #-24]
    8d8c:	e59f0198 	ldr	r0, [pc, #408]	; 8f2c <main+0x1bc>
    8d90:	eb0003bd 	bl	9c8c <_IO_puts>
    8d94:	e3a03001 	mov	r3, #1
    8d98:	e50b3020 	str	r3, [fp, #-32]
    8d9c:	ea000058 	b	8f04 <main+0x194>
    8da0:	e51b3020 	ldr	r3, [fp, #-32]
    8da4:	e1a03a03 	lsl	r3, r3, #20
    8da8:	e50b3014 	str	r3, [fp, #-20]
    8dac:	e51b2020 	ldr	r2, [fp, #-32]
    8db0:	e59f3178 	ldr	r3, [pc, #376]	; 8f30 <main+0x1c0>
    8db4:	e1520003 	cmp	r2, r3
    8db8:	c3a03000 	movgt	r3, #0
    8dbc:	d3a03001 	movle	r3, #1
    8dc0:	e20330ff 	and	r3, r3, #255	; 0xff
    8dc4:	e1a01003 	mov	r1, r3
    8dc8:	e51b2020 	ldr	r2, [fp, #-32]
    8dcc:	e51b0020 	ldr	r0, [fp, #-32]
    8dd0:	e1a03000 	mov	r3, r0
    8dd4:	e1a04fc3 	asr	r4, r3, #31
    8dd8:	e51b001c 	ldr	r0, [fp, #-28]
    8ddc:	e5905000 	ldr	r5, [r0]
    8de0:	e51b001c 	ldr	r0, [fp, #-28]
    8de4:	e2400004 	sub	r0, r0, #4
    8de8:	e590e000 	ldr	lr, [r0]
    8dec:	e51b0018 	ldr	r0, [fp, #-24]
    8df0:	e590c000 	ldr	ip, [r0]
    8df4:	e51b0018 	ldr	r0, [fp, #-24]
    8df8:	e2800004 	add	r0, r0, #4
    8dfc:	e5900000 	ldr	r0, [r0]
    8e00:	e88d0018 	stm	sp, {r3, r4}
    8e04:	e58d5008 	str	r5, [sp, #8]
    8e08:	e58de00c 	str	lr, [sp, #12]
    8e0c:	e58dc010 	str	ip, [sp, #16]
    8e10:	e58d0014 	str	r0, [sp, #20]
    8e14:	e59f0118 	ldr	r0, [pc, #280]	; 8f34 <main+0x1c4>
    8e18:	eb00038c 	bl	9c50 <_IO_printf>
    8e1c:	e3e03000 	mvn	r3, #0
    8e20:	e58d3000 	str	r3, [sp]
    8e24:	e3a03000 	mov	r3, #0
    8e28:	e58d3004 	str	r3, [sp, #4]
    8e2c:	e3a00000 	mov	r0, #0
    8e30:	e51b1014 	ldr	r1, [fp, #-20]
    8e34:	e3a02003 	mov	r2, #3
    8e38:	e3a03022 	mov	r3, #34	; 0x22
    8e3c:	eb0030ab 	bl	150f0 <__mmap>
    8e40:	e50b0010 	str	r0, [fp, #-16]
    8e44:	e51b3010 	ldr	r3, [fp, #-16]
    8e48:	e3730001 	cmn	r3, #1
    8e4c:	1a00000a 	bne	8e7c <main+0x10c>
    8e50:	e51b2020 	ldr	r2, [fp, #-32]
    8e54:	e51b1020 	ldr	r1, [fp, #-32]
    8e58:	e1a03001 	mov	r3, r1
    8e5c:	e1a04fc3 	asr	r4, r3, #31
    8e60:	e59f00d0 	ldr	r0, [pc, #208]	; 8f38 <main+0x1c8>
    8e64:	e1a01002 	mov	r1, r2
    8e68:	e1a02003 	mov	r2, r3
    8e6c:	e1a03004 	mov	r3, r4
    8e70:	eb000376 	bl	9c50 <_IO_printf>
    8e74:	e3a03001 	mov	r3, #1
    8e78:	ea000028 	b	8f20 <main+0x1b0>
    8e7c:	e51b2020 	ldr	r2, [fp, #-32]
    8e80:	e59f30a8 	ldr	r3, [pc, #168]	; 8f30 <main+0x1c0>
    8e84:	e1520003 	cmp	r2, r3
    8e88:	c3a03000 	movgt	r3, #0
    8e8c:	d3a03001 	movle	r3, #1
    8e90:	e20330ff 	and	r3, r3, #255	; 0xff
    8e94:	e1a01003 	mov	r1, r3
    8e98:	e51b2020 	ldr	r2, [fp, #-32]
    8e9c:	e51b0020 	ldr	r0, [fp, #-32]
    8ea0:	e1a03000 	mov	r3, r0
    8ea4:	e1a04fc3 	asr	r4, r3, #31
    8ea8:	e51b001c 	ldr	r0, [fp, #-28]
    8eac:	e5905000 	ldr	r5, [r0]
    8eb0:	e51b001c 	ldr	r0, [fp, #-28]
    8eb4:	e2400004 	sub	r0, r0, #4
    8eb8:	e590e000 	ldr	lr, [r0]
    8ebc:	e51b0018 	ldr	r0, [fp, #-24]
    8ec0:	e590c000 	ldr	ip, [r0]
    8ec4:	e51b0018 	ldr	r0, [fp, #-24]
    8ec8:	e2800004 	add	r0, r0, #4
    8ecc:	e5900000 	ldr	r0, [r0]
    8ed0:	e88d0018 	stm	sp, {r3, r4}
    8ed4:	e58d5008 	str	r5, [sp, #8]
    8ed8:	e58de00c 	str	lr, [sp, #12]
    8edc:	e58dc010 	str	ip, [sp, #16]
    8ee0:	e58d0014 	str	r0, [sp, #20]
    8ee4:	e59f0050 	ldr	r0, [pc, #80]	; 8f3c <main+0x1cc>
    8ee8:	eb000358 	bl	9c50 <_IO_printf>
    8eec:	e51b0010 	ldr	r0, [fp, #-16]
    8ef0:	e51b1014 	ldr	r1, [fp, #-20]
    8ef4:	eb003091 	bl	15140 <__munmap>
    8ef8:	e51b3020 	ldr	r3, [fp, #-32]
    8efc:	e2833001 	add	r3, r3, #1
    8f00:	e50b3020 	str	r3, [fp, #-32]
    8f04:	e51b2020 	ldr	r2, [fp, #-32]
    8f08:	e59f3020 	ldr	r3, [pc, #32]	; 8f30 <main+0x1c0>
    8f0c:	e1520003 	cmp	r2, r3
    8f10:	daffffa2 	ble	8da0 <main+0x30>
    8f14:	e59f0024 	ldr	r0, [pc, #36]	; 8f40 <main+0x1d0>
    8f18:	eb00035b 	bl	9c8c <_IO_puts>
    8f1c:	e3a03000 	mov	r3, #0
    8f20:	e1a00003 	mov	r0, r3
    8f24:	e24bd00c 	sub	sp, fp, #12
    8f28:	e8bd8830 	pop	{r4, r5, fp, pc}
    8f2c:	0006b18c 	.word	0x0006b18c
    8f30:	00000909 	.word	0x00000909
    8f34:	0006b1a0 	.word	0x0006b1a0
    8f38:	0006b1c8 	.word	0x0006b1c8
    8f3c:	0006b1f4 	.word	0x0006b1f4
    8f40:	0006b21c 	.word	0x0006b21c

