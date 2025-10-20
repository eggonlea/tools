
/home/lli5/apt-sc01/server_tree/main_loki/git/out/target/product/t210/symbols/system/bin/mmap64:     file format elf64-littleaarch64


Disassembly of section .plt:

00000000000005a0 <munmap@plt-0x20>:
 5a0:	a9bf7bf0 	stp	x16, x30, [sp,#-16]!
 5a4:	90000090 	adrp	x16, 10000 <atexit+0xf914>
 5a8:	f947da11 	ldr	x17, [x16,#4016]
 5ac:	913ec210 	add	x16, x16, #0xfb0
 5b0:	d61f0220 	br	x17
 5b4:	d503201f 	nop
 5b8:	d503201f 	nop
 5bc:	d503201f 	nop

00000000000005c0 <munmap@plt>:
 5c0:	90000090 	adrp	x16, 10000 <atexit+0xf914>
 5c4:	f947de11 	ldr	x17, [x16,#4024]
 5c8:	913ee210 	add	x16, x16, #0xfb8
 5cc:	d61f0220 	br	x17

00000000000005d0 <mmap@plt>:
 5d0:	90000090 	adrp	x16, 10000 <atexit+0xf914>
 5d4:	f947e211 	ldr	x17, [x16,#4032]
 5d8:	913f0210 	add	x16, x16, #0xfc0
 5dc:	d61f0220 	br	x17

00000000000005e0 <__libc_init@plt>:
 5e0:	90000090 	adrp	x16, 10000 <atexit+0xf914>
 5e4:	f947e611 	ldr	x17, [x16,#4040]
 5e8:	913f2210 	add	x16, x16, #0xfc8
 5ec:	d61f0220 	br	x17

00000000000005f0 <__cxa_atexit@plt>:
 5f0:	90000090 	adrp	x16, 10000 <atexit+0xf914>
 5f4:	f947ea11 	ldr	x17, [x16,#4048]
 5f8:	913f4210 	add	x16, x16, #0xfd0
 5fc:	d61f0220 	br	x17

Disassembly of section .text:

0000000000000600 <main>:
 600:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 604:	910003fd 	mov	x29, sp
 608:	a90153f3 	stp	x19, x20, [sp,#16]
 60c:	d2a00213 	mov	x19, #0x100000              	// #1048576
 610:	d2b21414 	mov	x20, #0x90a00000            	// #2426404864
 614:	14000004 	b	624 <main+0x24>
 618:	97ffffea 	bl	5c0 <munmap@plt>
 61c:	eb14027f 	cmp	x19, x20
 620:	54000200 	b.eq	660 <main+0x60>
 624:	d2800000 	mov	x0, #0x0                   	// #0
 628:	aa1303e1 	mov	x1, x19
 62c:	52800062 	mov	w2, #0x3                   	// #3
 630:	52800443 	mov	w3, #0x22                  	// #34
 634:	12800004 	mov	w4, #0xffffffff            	// #-1
 638:	aa0003e5 	mov	x5, x0
 63c:	97ffffe5 	bl	5d0 <mmap@plt>
 640:	b100041f 	cmn	x0, #0x1
 644:	aa1303e1 	mov	x1, x19
 648:	91440273 	add	x19, x19, #0x100, lsl #12
 64c:	54fffe61 	b.ne	618 <main+0x18>
 650:	52800020 	mov	w0, #0x1                   	// #1
 654:	a94153f3 	ldp	x19, x20, [sp,#16]
 658:	a8c27bfd 	ldp	x29, x30, [sp],#32
 65c:	d65f03c0 	ret
 660:	52800000 	mov	w0, #0x0                   	// #0
 664:	17fffffc 	b	654 <main+0x54>

0000000000000668 <do_arm64_start>:
 668:	a9bc7bfd 	stp	x29, x30, [sp,#-64]!
 66c:	910003fd 	mov	x29, sp
 670:	f9000fa0 	str	x0, [x29,#24]
 674:	9100a3a0 	add	x0, x29, #0x28
 678:	90000081 	adrp	x1, 10000 <atexit+0xf914>
 67c:	f947fc21 	ldr	x1, [x1,#4088]
 680:	f9000001 	str	x1, [x0]
 684:	9100a3a0 	add	x0, x29, #0x28
 688:	90000081 	adrp	x1, 10000 <atexit+0xf914>
 68c:	f947f421 	ldr	x1, [x1,#4072]
 690:	f9000401 	str	x1, [x0,#8]
 694:	9100a3a0 	add	x0, x29, #0x28
 698:	90000081 	adrp	x1, 10000 <atexit+0xf914>
 69c:	f947f021 	ldr	x1, [x1,#4064]
 6a0:	f9000801 	str	x1, [x0,#16]
 6a4:	90000080 	adrp	x0, 10000 <atexit+0xf914>
 6a8:	f947f802 	ldr	x2, [x0,#4080]
 6ac:	9100a3a3 	add	x3, x29, #0x28
 6b0:	f9400fa0 	ldr	x0, [x29,#24]
 6b4:	d2800001 	mov	x1, #0x0                   	// #0
 6b8:	97ffffca 	bl	5e0 <__libc_init@plt>

00000000000006bc <_start>:
 6bc:	8b3f63e0 	add	x0, sp, xzr
 6c0:	17ffffea 	b	668 <do_arm64_start>

00000000000006c4 <__atexit_handler_wrapper>:
 6c4:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 6c8:	910003fd 	mov	x29, sp
 6cc:	f9000fa0 	str	x0, [x29,#24]
 6d0:	f9400fa0 	ldr	x0, [x29,#24]
 6d4:	eb1f001f 	cmp	x0, xzr
 6d8:	54000060 	b.eq	6e4 <__atexit_handler_wrapper+0x20>
 6dc:	f9400fa0 	ldr	x0, [x29,#24]
 6e0:	d63f0000 	blr	x0
 6e4:	a8c27bfd 	ldp	x29, x30, [sp],#32
 6e8:	d65f03c0 	ret

00000000000006ec <atexit>:
 6ec:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 6f0:	910003fd 	mov	x29, sp
 6f4:	f9000fa0 	str	x0, [x29,#24]
 6f8:	90000000 	adrp	x0, 0 <munmap@plt-0x5c0>
 6fc:	911b1000 	add	x0, x0, #0x6c4
 700:	b0000081 	adrp	x1, 11000 <__dso_handle>
 704:	91000022 	add	x2, x1, #0x0
 708:	f9400fa1 	ldr	x1, [x29,#24]
 70c:	97ffffb9 	bl	5f0 <__cxa_atexit@plt>
 710:	a8c27bfd 	ldp	x29, x30, [sp],#32
 714:	d65f03c0 	ret
