
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
 6dc:	91222000 	add	x0, x0, #0x888
 6e0:	a90363f7 	stp	x23, x24, [sp,#48]
 6e4:	a90153f3 	stp	x19, x20, [sp,#16]
 6e8:	a9025bf5 	stp	x21, x22, [sp,#32]
 6ec:	f90023f9 	str	x25, [sp,#64]
 6f0:	90000018 	adrp	x24, 0 <printf@plt-0x670>
 6f4:	97ffffe7 	bl	690 <puts@plt>
 6f8:	90000019 	adrp	x25, 0 <printf@plt-0x670>
 6fc:	52800021 	mov	w1, #0x1                   	// #1
 700:	d2800033 	mov	x19, #0x1                   	// #1
 704:	b9405bb7 	ldr	w23, [x29,#88]
 708:	91228339 	add	x25, x25, #0x8a0
 70c:	b94063b6 	ldr	w22, [x29,#96]
 710:	9123e318 	add	x24, x24, #0x8f8
 714:	b9005fa1 	str	w1, [x29,#92]
 718:	14000008 	b	738 <main+0x68>
 71c:	97ffffd5 	bl	670 <printf@plt>
 720:	aa1503e0 	mov	x0, x21
 724:	aa1403e1 	mov	x1, x20
 728:	97ffffd6 	bl	680 <munmap@plt>
 72c:	11000662 	add	w2, w19, #0x1
 730:	91000673 	add	x19, x19, #0x1
 734:	b9005fa2 	str	w2, [x29,#92]
 738:	2a1303e6 	mov	w6, w19
 73c:	2a1603e7 	mov	w7, w22
 740:	2a1303e2 	mov	w2, w19
 744:	aa1303e3 	mov	x3, x19
 748:	2a1303e4 	mov	w4, w19
 74c:	2a1703e5 	mov	w5, w23
 750:	52800021 	mov	w1, #0x1                   	// #1
 754:	aa1903e0 	mov	x0, x25
 758:	d36cae74 	lsl	x20, x19, #20
 75c:	97ffffc5 	bl	670 <printf@plt>
 760:	d2800000 	mov	x0, #0x0                   	// #0
 764:	aa1403e1 	mov	x1, x20
 768:	52800062 	mov	w2, #0x3                   	// #3
 76c:	52800443 	mov	w3, #0x22                  	// #34
 770:	12800004 	mov	w4, #0xffffffff            	// #-1
 774:	aa0003e5 	mov	x5, x0
 778:	97ffffca 	bl	6a0 <mmap@plt>
 77c:	aa0003f5 	mov	x21, x0
 780:	b10006bf 	cmn	x21, #0x1
 784:	2a1303e2 	mov	w2, w19
 788:	aa1303e3 	mov	x3, x19
 78c:	2a1303e4 	mov	w4, w19
 790:	2a1303e6 	mov	w6, w19
 794:	2a1703e5 	mov	w5, w23
 798:	2a1603e7 	mov	w7, w22
 79c:	aa1803e0 	mov	x0, x24
 7a0:	52800021 	mov	w1, #0x1                   	// #1
 7a4:	54fffbc1 	b.ne	71c <main+0x4c>
 7a8:	90000003 	adrp	x3, 0 <printf@plt-0x670>
 7ac:	2a1303e1 	mov	w1, w19
 7b0:	aa1303e2 	mov	x2, x19
 7b4:	91232060 	add	x0, x3, #0x8c8
 7b8:	97ffffae 	bl	670 <printf@plt>
 7bc:	f94023f9 	ldr	x25, [sp,#64]
 7c0:	52800020 	mov	w0, #0x1                   	// #1
 7c4:	a94153f3 	ldp	x19, x20, [sp,#16]
 7c8:	a9425bf5 	ldp	x21, x22, [sp,#32]
 7cc:	a94363f7 	ldp	x23, x24, [sp,#48]
 7d0:	a8c67bfd 	ldp	x29, x30, [sp],#96
 7d4:	d65f03c0 	ret
 7d8:	a9bc7bfd 	stp	x29, x30, [sp,#-64]!
 7dc:	910003fd 	mov	x29, sp
 7e0:	f9000fa0 	str	x0, [x29,#24]
 7e4:	9100a3a0 	add	x0, x29, #0x28
 7e8:	90000081 	adrp	x1, 10000 <main+0xf930>
 7ec:	f947fc21 	ldr	x1, [x1,#4088]
 7f0:	f9000001 	str	x1, [x0]
 7f4:	9100a3a0 	add	x0, x29, #0x28
 7f8:	90000081 	adrp	x1, 10000 <main+0xf930>
 7fc:	f947f421 	ldr	x1, [x1,#4072]
 800:	f9000401 	str	x1, [x0,#8]
 804:	9100a3a0 	add	x0, x29, #0x28
 808:	90000081 	adrp	x1, 10000 <main+0xf930>
 80c:	f947f021 	ldr	x1, [x1,#4064]
 810:	f9000801 	str	x1, [x0,#16]
 814:	90000080 	adrp	x0, 10000 <main+0xf930>
 818:	f947f802 	ldr	x2, [x0,#4080]
 81c:	9100a3a3 	add	x3, x29, #0x28
 820:	f9400fa0 	ldr	x0, [x29,#24]
 824:	d2800001 	mov	x1, #0x0                   	// #0
 828:	97ffffa2 	bl	6b0 <__libc_init@plt>
 82c:	8b3f63e0 	add	x0, sp, xzr
 830:	17ffffea 	b	7d8 <main+0x108>
 834:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 838:	910003fd 	mov	x29, sp
 83c:	f9000fa0 	str	x0, [x29,#24]
 840:	f9400fa0 	ldr	x0, [x29,#24]
 844:	eb1f001f 	cmp	x0, xzr
 848:	54000060 	b.eq	854 <main+0x184>
 84c:	f9400fa0 	ldr	x0, [x29,#24]
 850:	d63f0000 	blr	x0
 854:	a8c27bfd 	ldp	x29, x30, [sp],#32
 858:	d65f03c0 	ret
 85c:	a9be7bfd 	stp	x29, x30, [sp,#-32]!
 860:	910003fd 	mov	x29, sp
 864:	f9000fa0 	str	x0, [x29,#24]
 868:	90000000 	adrp	x0, 0 <printf@plt-0x670>
 86c:	9120d000 	add	x0, x0, #0x834
 870:	b0000081 	adrp	x1, 11000 <__FINI_ARRAY__+0x260>
 874:	91000022 	add	x2, x1, #0x0
 878:	f9400fa1 	ldr	x1, [x29,#24]
 87c:	97ffff91 	bl	6c0 <__cxa_atexit@plt>
 880:	a8c27bfd 	ldp	x29, x30, [sp],#32
 884:	d65f03c0 	ret
