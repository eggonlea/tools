
/home/lli5/apt-sc01/server_tree/main_loki/git/out/target/product/t210/system/bin/mmap64:     file format elf64-littleaarch64


Disassembly of section .plt:

0000000000000650 <printf@plt-0x20>:
 650:	a9bf7bf0 	stp	x16, x30, [sp,#-16]!
 654:	90000090 	adrp	x16, 10000 <main+0xf930>
 658:	f947d211 	ldr	x17, [x16,#4000]
 65c:	913e8210 	add	x16, x16, #0xfa0
 660:	d61f0220 	br	x17
 664:	d503201f 	nop
 668:	d503201f 	nop
 66c:	d503201f 	nop

0000000000000670 <printf@plt>:
 670:	90000090 	adrp	x16, 10000 <main+0xf930>
 674:	f947d611 	ldr	x17, [x16,#4008]
 678:	913ea210 	add	x16, x16, #0xfa8
 67c:	d61f0220 	br	x17

0000000000000680 <munmap@plt>:
 680:	90000090 	adrp	x16, 10000 <main+0xf930>
 684:	f947da11 	ldr	x17, [x16,#4016]
 688:	913ec210 	add	x16, x16, #0xfb0
 68c:	d61f0220 	br	x17

0000000000000690 <puts@plt>:
 690:	90000090 	adrp	x16, 10000 <main+0xf930>
 694:	f947de11 	ldr	x17, [x16,#4024]
 698:	913ee210 	add	x16, x16, #0xfb8
 69c:	d61f0220 	br	x17

00000000000006a0 <mmap@plt>:
 6a0:	90000090 	adrp	x16, 10000 <main+0xf930>
 6a4:	f947e211 	ldr	x17, [x16,#4032]
 6a8:	913f0210 	add	x16, x16, #0xfc0
 6ac:	d61f0220 	br	x17

00000000000006b0 <__libc_init@plt>:
 6b0:	90000090 	adrp	x16, 10000 <main+0xf930>
 6b4:	f947e611 	ldr	x17, [x16,#4040]
 6b8:	913f2210 	add	x16, x16, #0xfc8
 6bc:	d61f0220 	br	x17

00000000000006c0 <__cxa_atexit@plt>:
 6c0:	90000090 	adrp	x16, 10000 <main+0xf930>
 6c4:	f947ea11 	ldr	x17, [x16,#4048]
 6c8:	913f4210 	add	x16, x16, #0xfd0
 6cc:	d61f0220 	br	x17

Disassembly of section .text:

00000000000006d0 <main>:
 6d0:	a9ba7bfd 	stp	x29, x30, [sp,#-96]!
 6d4:	90000000 	adrp	x0, 0 <printf@plt-0x670>
 6d8:	910003fd 	mov	x29, sp
 6dc:	9122a000 	add	x0, x0, #0x8a8
 6e0:	a9046bf9 	stp	x25, x26, [sp,#64]
 6e4:	a90153f3 	stp	x19, x20, [sp,#16]
 6e8:	a90363f7 	stp	x23, x24, [sp,#48]
 6ec:	a9025bf5 	stp	x21, x22, [sp,#32]
 6f0:	97ffffe8 	bl	690 <puts@plt>
 6f4:	9000001a 	adrp	x26, 0 <printf@plt-0x670>
 6f8:	d2800021 	mov	x1, #0x1                   	// #1
 6fc:	90000019 	adrp	x25, 0 <printf@plt-0x670>
 700:	b94057b8 	ldr	w24, [x29,#84]
 704:	aa0103f3 	mov	x19, x1
 708:	f9002fa1 	str	x1, [x29,#88]
 70c:	9123035a 	add	x26, x26, #0x8c0
 710:	91246339 	add	x25, x25, #0x918
 714:	14000009 	b	738 <main+0x68>
 718:	97ffffd6 	bl	670 <printf@plt>
 71c:	91000673 	add	x19, x19, #0x1
 720:	aa1703e0 	mov	x0, x23
 724:	aa1603e1 	mov	x1, x22
 728:	97ffffd6 	bl	680 <munmap@plt>
 72c:	f9002fb3 	str	x19, [x29,#88]
 730:	f1242a7f 	cmp	x19, #0x90a
 734:	540004c0 	b.eq	7cc <main+0xfc>
 738:	b9405bb4 	ldr	w20, [x29,#88]
 73c:	2a1303e2 	mov	w2, w19
 740:	b9405fb5 	ldr	w21, [x29,#92]
 744:	aa1303e3 	mov	x3, x19
 748:	2a1403e6 	mov	w6, w20
 74c:	52800021 	mov	w1, #0x1                   	// #1
 750:	2a1503e7 	mov	w7, w21
 754:	2a1403e4 	mov	w4, w20
 758:	2a1803e5 	mov	w5, w24
 75c:	aa1a03e0 	mov	x0, x26
 760:	d36cae76 	lsl	x22, x19, #20
 764:	97ffffc3 	bl	670 <printf@plt>
 768:	d2800000 	mov	x0, #0x0                   	// #0
 76c:	aa1603e1 	mov	x1, x22
 770:	52800062 	mov	w2, #0x3                   	// #3
 774:	52800443 	mov	w3, #0x22                  	// #34
 778:	12800004 	mov	w4, #0xffffffff            	// #-1
 77c:	aa0003e5 	mov	x5, x0
 780:	97ffffc8 	bl	6a0 <mmap@plt>
 784:	aa0003f7 	mov	x23, x0
 788:	b10006ff 	cmn	x23, #0x1
 78c:	2a1303e2 	mov	w2, w19
 790:	aa1303e3 	mov	x3, x19
 794:	2a1403e4 	mov	w4, w20
 798:	2a1803e5 	mov	w5, w24
 79c:	2a1403e6 	mov	w6, w20
 7a0:	2a1503e7 	mov	w7, w21
 7a4:	aa1903e0 	mov	x0, x25
 7a8:	52800021 	mov	w1, #0x1                   	// #1
 7ac:	54fffb61 	b.ne	718 <main+0x48>
 7b0:	90000003 	adrp	x3, 0 <printf@plt-0x670>
 7b4:	2a1303e1 	mov	w1, w19
 7b8:	9123a060 	add	x0, x3, #0x8e8
 7bc:	aa1303e2 	mov	x2, x19
 7c0:	97ffffac 	bl	670 <printf@plt>
 7c4:	52800020 	mov	w0, #0x1                   	// #1
 7c8:	14000005 	b	7dc <main+0x10c>
 7cc:	90000002 	adrp	x2, 0 <printf@plt-0x670>
 7d0:	91250040 	add	x0, x2, #0x940
 7d4:	97ffffaf 	bl	690 <puts@plt>
 7d8:	52800000 	mov	w0, #0x0                   	// #0
 7dc:	a94153f3 	ldp	x19, x20, [sp,#16]
 7e0:	a9425bf5 	ldp	x21, x22, [sp,#32]
 7e4:	a94363f7 	ldp	x23, x24, [sp,#48]
 7e8:	a9446bf9 	ldp	x25, x26, [sp,#64]
 7ec:	a8c67bfd 	ldp	x29, x30, [sp],#96
 7f0:	d65f03c0 	ret
 7f4:	a9bc7bfd 	stp	x29, x30, [sp,#-64]!
 7f8:	910003fd 	mov	x29, sp
 7fc:	f9000fa0 	str	x0, [x29,#24]
 800:	9100a3a0 	add	x0, x29, #0x28
 804:	90000081 	adrp	x1, 10000 <main+0xf930>
 808:	f947fc21 	ldr	x1, [x1,#4088]
 80c:	f9000001 	str	x1, [x0]
 810:	9100a3a0 	add	x0, x29, #0x28
 814:	90000081 	adrp	x1, 10000 <main+0xf930>
 818:	f947f421 	ldr	x1, [x1,#4072]
 81c:	f9000401 	str	x1, [x0,#8]
 820:	9100a3a0 	add	x0, x29, #0x28
 824:	90000081 	adrp	x1, 10000 <main+0xf930>
 828:	f947f021 	ldr	x1, [x1,#4064]
 82c:	f9000801 	str	x1, [x0,#16]
 830:	90000080 	adrp	x0, 10000 <main+0xf930>
 834:	f947f802 	ldr	x2, [x0,#4080]
 838:	9100a3a3 	add	x3, x29, #0x28
 83c:	f9400fa0 	ldr	x0, [x29,#24]
 840:	d2800001 	mov	x1, #0x0                   	// #0
 844:	97ffff9b 	bl	6b0 <__libc_init@plt>
 848:	8b3f63e0 	add	x0, sp, xzr
 84c:	17ffffea 	b	7f4 <main+0x124>
 850:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 854:	910003fd 	mov	x29, sp
 858:	f9000fa0 	str	x0, [x29,#24]
 85c:	f9400fa0 	ldr	x0, [x29,#24]
 860:	eb1f001f 	cmp	x0, xzr
 864:	54000060 	b.eq	870 <main+0x1a0>
 868:	f9400fa0 	ldr	x0, [x29,#24]
 86c:	d63f0000 	blr	x0
 870:	a8c27bfd 	ldp	x29, x30, [sp],#32
 874:	d65f03c0 	ret
 878:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 87c:	910003fd 	mov	x29, sp
 880:	f9000fa0 	str	x0, [x29,#24]
 884:	90000000 	adrp	x0, 0 <printf@plt-0x670>
 888:	91214000 	add	x0, x0, #0x850
 88c:	b0000081 	adrp	x1, 11000 <__FINI_ARRAY__+0x260>
 890:	91000022 	add	x2, x1, #0x0
 894:	f9400fa1 	ldr	x1, [x29,#24]
 898:	97ffff8a 	bl	6c0 <__cxa_atexit@plt>
 89c:	a8c27bfd 	ldp	x29, x30, [sp],#32
 8a0:	d65f03c0 	ret
