
/home/lli5/apt-sc01/server_tree/main_loki/git/out/target/product/t210/symbols/system/bin/mmap64:     file format elf64-littleaarch64


Disassembly of section .plt:

00000000000005a0 <munmap@plt-0x20>:
 5a0:	a9bf7bf0 	stp	x16, x30, [sp,#-16]!
 5a4:	90000090 	adrp	x16, 10000 <atexit+0xf924>
 5a8:	f947da11 	ldr	x17, [x16,#4016]
 5ac:	913ec210 	add	x16, x16, #0xfb0
 5b0:	d61f0220 	br	x17
 5b4:	d503201f 	nop
 5b8:	d503201f 	nop
 5bc:	d503201f 	nop

00000000000005c0 <munmap@plt>:
 5c0:	90000090 	adrp	x16, 10000 <atexit+0xf924>
 5c4:	f947de11 	ldr	x17, [x16,#4024]
 5c8:	913ee210 	add	x16, x16, #0xfb8
 5cc:	d61f0220 	br	x17

00000000000005d0 <mmap@plt>:
 5d0:	90000090 	adrp	x16, 10000 <atexit+0xf924>
 5d4:	f947e211 	ldr	x17, [x16,#4032]
 5d8:	913f0210 	add	x16, x16, #0xfc0
 5dc:	d61f0220 	br	x17

00000000000005e0 <__libc_init@plt>:
 5e0:	90000090 	adrp	x16, 10000 <atexit+0xf924>
 5e4:	f947e611 	ldr	x17, [x16,#4040]
 5e8:	913f2210 	add	x16, x16, #0xfc8
 5ec:	d61f0220 	br	x17

00000000000005f0 <__cxa_atexit@plt>:
 5f0:	90000090 	adrp	x16, 10000 <atexit+0xf924>
 5f4:	f947ea11 	ldr	x17, [x16,#4048]
 5f8:	913f4210 	add	x16, x16, #0xfd0
 5fc:	d61f0220 	br	x17

Disassembly of section .text:

0000000000000600 <main>:
 600:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 604:	910003fd 	mov	x29, sp
 608:	a90153f3 	stp	x19, x20, [sp,#16]
 60c:	d2a00213 	mov	x19, #0x100000              	// #1048576
 610:	14000002 	b	618 <main+0x18>
 614:	97ffffeb 	bl	5c0 <munmap@plt>
 618:	d2800000 	mov	x0, #0x0                   	// #0
 61c:	aa1303e1 	mov	x1, x19
 620:	52800062 	mov	w2, #0x3                   	// #3
 624:	52800443 	mov	w3, #0x22                  	// #34
 628:	12800004 	mov	w4, #0xffffffff            	// #-1
 62c:	aa0003e5 	mov	x5, x0
 630:	91440274 	add	x20, x19, #0x100, lsl #12
 634:	97ffffe7 	bl	5d0 <mmap@plt>
 638:	b100041f 	cmn	x0, #0x1
 63c:	aa1303e1 	mov	x1, x19
 640:	aa1403f3 	mov	x19, x20
 644:	54fffe81 	b.ne	614 <main+0x14>
 648:	52800020 	mov	w0, #0x1                   	// #1
 64c:	a94153f3 	ldp	x19, x20, [sp,#16]
 650:	a8c27bfd 	ldp	x29, x30, [sp],#32
 654:	d65f03c0 	ret

0000000000000658 <do_arm64_start>:
 658:	a9bc7bfd 	stp	x29, x30, [sp,#-64]!
 65c:	910003fd 	mov	x29, sp
 660:	f9000fa0 	str	x0, [x29,#24]
 664:	9100a3a0 	add	x0, x29, #0x28
 668:	90000081 	adrp	x1, 10000 <atexit+0xf924>
 66c:	f947fc21 	ldr	x1, [x1,#4088]
 670:	f9000001 	str	x1, [x0]
 674:	9100a3a0 	add	x0, x29, #0x28
 678:	90000081 	adrp	x1, 10000 <atexit+0xf924>
 67c:	f947f421 	ldr	x1, [x1,#4072]
 680:	f9000401 	str	x1, [x0,#8]
 684:	9100a3a0 	add	x0, x29, #0x28
 688:	90000081 	adrp	x1, 10000 <atexit+0xf924>
 68c:	f947f021 	ldr	x1, [x1,#4064]
 690:	f9000801 	str	x1, [x0,#16]
 694:	90000080 	adrp	x0, 10000 <atexit+0xf924>
 698:	f947f802 	ldr	x2, [x0,#4080]
 69c:	9100a3a3 	add	x3, x29, #0x28
 6a0:	f9400fa0 	ldr	x0, [x29,#24]
 6a4:	d2800001 	mov	x1, #0x0                   	// #0
 6a8:	97ffffce 	bl	5e0 <__libc_init@plt>

00000000000006ac <_start>:
 6ac:	8b3f63e0 	add	x0, sp, xzr
 6b0:	17ffffea 	b	658 <do_arm64_start>

00000000000006b4 <__atexit_handler_wrapper>:
 6b4:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 6b8:	910003fd 	mov	x29, sp
 6bc:	f9000fa0 	str	x0, [x29,#24]
 6c0:	f9400fa0 	ldr	x0, [x29,#24]
 6c4:	eb1f001f 	cmp	x0, xzr
 6c8:	54000060 	b.eq	6d4 <__atexit_handler_wrapper+0x20>
 6cc:	f9400fa0 	ldr	x0, [x29,#24]
 6d0:	d63f0000 	blr	x0
 6d4:	a8c27bfd 	ldp	x29, x30, [sp],#32
 6d8:	d65f03c0 	ret

00000000000006dc <atexit>:
 6dc:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 6e0:	910003fd 	mov	x29, sp
 6e4:	f9000fa0 	str	x0, [x29,#24]
 6e8:	90000000 	adrp	x0, 0 <munmap@plt-0x5c0>
 6ec:	911ad000 	add	x0, x0, #0x6b4
 6f0:	b0000081 	adrp	x1, 11000 <__dso_handle>
 6f4:	91000022 	add	x2, x1, #0x0
 6f8:	f9400fa1 	ldr	x1, [x29,#24]
 6fc:	97ffffbd 	bl	5f0 <__cxa_atexit@plt>
 700:	a8c27bfd 	ldp	x29, x30, [sp],#32
 704:	d65f03c0 	ret
