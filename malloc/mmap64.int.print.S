
/home/lli5/apt-sc01/server_tree/main_loki/git/out/target/product/t210/symbols/system/bin/mmap64:     file format elf64-littleaarch64


Disassembly of section .plt:

00000000000005e0 <printf@plt-0x20>:
 5e0:	a9bf7bf0 	stp	x16, x30, [sp,#-16]!
 5e4:	90000090 	adrp	x16, 10000 <atexit+0xf8ac>
 5e8:	f947d611 	ldr	x17, [x16,#4008]
 5ec:	913ea210 	add	x16, x16, #0xfa8
 5f0:	d61f0220 	br	x17
 5f4:	d503201f 	nop
 5f8:	d503201f 	nop
 5fc:	d503201f 	nop

0000000000000600 <printf@plt>:
 600:	90000090 	adrp	x16, 10000 <atexit+0xf8ac>
 604:	f947da11 	ldr	x17, [x16,#4016]
 608:	913ec210 	add	x16, x16, #0xfb0
 60c:	d61f0220 	br	x17

0000000000000610 <munmap@plt>:
 610:	90000090 	adrp	x16, 10000 <atexit+0xf8ac>
 614:	f947de11 	ldr	x17, [x16,#4024]
 618:	913ee210 	add	x16, x16, #0xfb8
 61c:	d61f0220 	br	x17

0000000000000620 <mmap@plt>:
 620:	90000090 	adrp	x16, 10000 <atexit+0xf8ac>
 624:	f947e211 	ldr	x17, [x16,#4032]
 628:	913f0210 	add	x16, x16, #0xfc0
 62c:	d61f0220 	br	x17

0000000000000630 <__libc_init@plt>:
 630:	90000090 	adrp	x16, 10000 <atexit+0xf8ac>
 634:	f947e611 	ldr	x17, [x16,#4040]
 638:	913f2210 	add	x16, x16, #0xfc8
 63c:	d61f0220 	br	x17

0000000000000640 <__cxa_atexit@plt>:
 640:	90000090 	adrp	x16, 10000 <atexit+0xf8ac>
 644:	f947ea11 	ldr	x17, [x16,#4048]
 648:	913f4210 	add	x16, x16, #0xfd0
 64c:	d61f0220 	br	x17

Disassembly of section .text:

0000000000000650 <main>:
 650:	a9bd7bfd 	stp	x29, x30, [sp,#-48]!
 654:	910003fd 	mov	x29, sp
 658:	a9025bf5 	stp	x21, x22, [sp,#32]
 65c:	90000016 	adrp	x22, 0 <printf@plt-0x600>
 660:	a90153f3 	stp	x19, x20, [sp,#16]
 664:	911e02d6 	add	x22, x22, #0x780
 668:	d2a00213 	mov	x19, #0x100000              	// #1048576
 66c:	52800034 	mov	w20, #0x1                   	// #1
 670:	14000002 	b	678 <main+0x28>
 674:	97ffffe7 	bl	610 <munmap@plt>
 678:	2a1403e2 	mov	w2, w20
 67c:	52800021 	mov	w1, #0x1                   	// #1
 680:	aa1603e0 	mov	x0, x22
 684:	0b010294 	add	w20, w20, w1
 688:	91440275 	add	x21, x19, #0x100, lsl #12
 68c:	97ffffdd 	bl	600 <printf@plt>
 690:	d2800000 	mov	x0, #0x0                   	// #0
 694:	aa1303e1 	mov	x1, x19
 698:	52800062 	mov	w2, #0x3                   	// #3
 69c:	52800443 	mov	w3, #0x22                  	// #34
 6a0:	12800004 	mov	w4, #0xffffffff            	// #-1
 6a4:	aa0003e5 	mov	x5, x0
 6a8:	97ffffde 	bl	620 <mmap@plt>
 6ac:	b100041f 	cmn	x0, #0x1
 6b0:	aa1303e1 	mov	x1, x19
 6b4:	aa1503f3 	mov	x19, x21
 6b8:	54fffde1 	b.ne	674 <main+0x24>
 6bc:	52800020 	mov	w0, #0x1                   	// #1
 6c0:	a94153f3 	ldp	x19, x20, [sp,#16]
 6c4:	a9425bf5 	ldp	x21, x22, [sp,#32]
 6c8:	a8c37bfd 	ldp	x29, x30, [sp],#48
 6cc:	d65f03c0 	ret

00000000000006d0 <do_arm64_start>:
 6d0:	a9bc7bfd 	stp	x29, x30, [sp,#-64]!
 6d4:	910003fd 	mov	x29, sp
 6d8:	f9000fa0 	str	x0, [x29,#24]
 6dc:	9100a3a0 	add	x0, x29, #0x28
 6e0:	90000081 	adrp	x1, 10000 <atexit+0xf8ac>
 6e4:	f947fc21 	ldr	x1, [x1,#4088]
 6e8:	f9000001 	str	x1, [x0]
 6ec:	9100a3a0 	add	x0, x29, #0x28
 6f0:	90000081 	adrp	x1, 10000 <atexit+0xf8ac>
 6f4:	f947f421 	ldr	x1, [x1,#4072]
 6f8:	f9000401 	str	x1, [x0,#8]
 6fc:	9100a3a0 	add	x0, x29, #0x28
 700:	90000081 	adrp	x1, 10000 <atexit+0xf8ac>
 704:	f947f021 	ldr	x1, [x1,#4064]
 708:	f9000801 	str	x1, [x0,#16]
 70c:	90000080 	adrp	x0, 10000 <atexit+0xf8ac>
 710:	f947f802 	ldr	x2, [x0,#4080]
 714:	9100a3a3 	add	x3, x29, #0x28
 718:	f9400fa0 	ldr	x0, [x29,#24]
 71c:	d2800001 	mov	x1, #0x0                   	// #0
 720:	97ffffc4 	bl	630 <__libc_init@plt>

0000000000000724 <_start>:
 724:	8b3f63e0 	add	x0, sp, xzr
 728:	17ffffea 	b	6d0 <do_arm64_start>

000000000000072c <__atexit_handler_wrapper>:
 72c:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 730:	910003fd 	mov	x29, sp
 734:	f9000fa0 	str	x0, [x29,#24]
 738:	f9400fa0 	ldr	x0, [x29,#24]
 73c:	eb1f001f 	cmp	x0, xzr
 740:	54000060 	b.eq	74c <__atexit_handler_wrapper+0x20>
 744:	f9400fa0 	ldr	x0, [x29,#24]
 748:	d63f0000 	blr	x0
 74c:	a8c27bfd 	ldp	x29, x30, [sp],#32
 750:	d65f03c0 	ret

0000000000000754 <atexit>:
 754:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 758:	910003fd 	mov	x29, sp
 75c:	f9000fa0 	str	x0, [x29,#24]
 760:	90000000 	adrp	x0, 0 <printf@plt-0x600>
 764:	911cb000 	add	x0, x0, #0x72c
 768:	b0000081 	adrp	x1, 11000 <__dso_handle>
 76c:	91000022 	add	x2, x1, #0x0
 770:	f9400fa1 	ldr	x1, [x29,#24]
 774:	97ffffb3 	bl	640 <__cxa_atexit@plt>
 778:	a8c27bfd 	ldp	x29, x30, [sp],#32
 77c:	d65f03c0 	ret
