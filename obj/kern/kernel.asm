
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 61 00 00 00       	call   f010009f <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f0100047:	83 3d 00 70 21 f0 00 	cmpl   $0x0,0xf0217000
f010004e:	74 0f                	je     f010005f <_panic+0x1f>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100050:	83 ec 0c             	sub    $0xc,%esp
f0100053:	6a 00                	push   $0x0
f0100055:	e8 96 08 00 00       	call   f01008f0 <monitor>
f010005a:	83 c4 10             	add    $0x10,%esp
f010005d:	eb f1                	jmp    f0100050 <_panic+0x10>
	panicstr = fmt;
f010005f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100062:	a3 00 70 21 f0       	mov    %eax,0xf0217000
	asm volatile("cli; cld");
f0100067:	fa                   	cli    
f0100068:	fc                   	cld    
	va_start(ap, fmt);
f0100069:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006c:	e8 cf 5a 00 00       	call   f0105b40 <cpunum>
f0100071:	ff 75 0c             	push   0xc(%ebp)
f0100074:	ff 75 08             	push   0x8(%ebp)
f0100077:	50                   	push   %eax
f0100078:	68 80 61 10 f0       	push   $0xf0106180
f010007d:	e8 b0 38 00 00       	call   f0103932 <cprintf>
	vcprintf(fmt, ap);
f0100082:	83 c4 08             	add    $0x8,%esp
f0100085:	53                   	push   %ebx
f0100086:	ff 75 10             	push   0x10(%ebp)
f0100089:	e8 7e 38 00 00       	call   f010390c <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 ac 73 10 f0 	movl   $0xf01073ac,(%esp)
f0100095:	e8 98 38 00 00       	call   f0103932 <cprintf>
f010009a:	83 c4 10             	add    $0x10,%esp
f010009d:	eb b1                	jmp    f0100050 <_panic+0x10>

f010009f <i386_init>:
{
f010009f:	55                   	push   %ebp
f01000a0:	89 e5                	mov    %esp,%ebp
f01000a2:	53                   	push   %ebx
f01000a3:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a6:	e8 7e 05 00 00       	call   f0100629 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ab:	83 ec 08             	sub    $0x8,%esp
f01000ae:	68 ac 1a 00 00       	push   $0x1aac
f01000b3:	68 ec 61 10 f0       	push   $0xf01061ec
f01000b8:	e8 75 38 00 00       	call   f0103932 <cprintf>
	mem_init();
f01000bd:	e8 b7 11 00 00       	call   f0101279 <mem_init>
	env_init();
f01000c2:	e8 62 30 00 00       	call   f0103129 <env_init>
	trap_init();
f01000c7:	e8 48 39 00 00       	call   f0103a14 <trap_init>
	mp_init();
f01000cc:	e8 89 57 00 00       	call   f010585a <mp_init>
	lapic_init();
f01000d1:	e8 80 5a 00 00       	call   f0105b56 <lapic_init>
	pic_init();
f01000d6:	e8 78 37 00 00       	call   f0103853 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000db:	c7 04 24 80 44 12 f0 	movl   $0xf0124480,(%esp)
f01000e2:	e8 c9 5c 00 00       	call   f0105db0 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e7:	83 c4 10             	add    $0x10,%esp
f01000ea:	83 3d 60 72 21 f0 07 	cmpl   $0x7,0xf0217260
f01000f1:	76 27                	jbe    f010011a <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f3:	83 ec 04             	sub    $0x4,%esp
f01000f6:	b8 b6 57 10 f0       	mov    $0xf01057b6,%eax
f01000fb:	2d 3c 57 10 f0       	sub    $0xf010573c,%eax
f0100100:	50                   	push   %eax
f0100101:	68 3c 57 10 f0       	push   $0xf010573c
f0100106:	68 00 70 00 f0       	push   $0xf0007000
f010010b:	e8 81 54 00 00       	call   f0105591 <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100110:	83 c4 10             	add    $0x10,%esp
f0100113:	bb 20 80 25 f0       	mov    $0xf0258020,%ebx
f0100118:	eb 19                	jmp    f0100133 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011a:	68 00 70 00 00       	push   $0x7000
f010011f:	68 a4 61 10 f0       	push   $0xf01061a4
f0100124:	6a 52                	push   $0x52
f0100126:	68 07 62 10 f0       	push   $0xf0106207
f010012b:	e8 10 ff ff ff       	call   f0100040 <_panic>
f0100130:	83 c3 74             	add    $0x74,%ebx
f0100133:	6b 05 00 80 25 f0 74 	imul   $0x74,0xf0258000,%eax
f010013a:	05 20 80 25 f0       	add    $0xf0258020,%eax
f010013f:	39 c3                	cmp    %eax,%ebx
f0100141:	73 4d                	jae    f0100190 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f0100143:	e8 f8 59 00 00       	call   f0105b40 <cpunum>
f0100148:	6b c0 74             	imul   $0x74,%eax,%eax
f010014b:	05 20 80 25 f0       	add    $0xf0258020,%eax
f0100150:	39 c3                	cmp    %eax,%ebx
f0100152:	74 dc                	je     f0100130 <i386_init+0x91>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100154:	89 d8                	mov    %ebx,%eax
f0100156:	2d 20 80 25 f0       	sub    $0xf0258020,%eax
f010015b:	c1 f8 02             	sar    $0x2,%eax
f010015e:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100164:	c1 e0 0f             	shl    $0xf,%eax
f0100167:	8d 80 00 00 22 f0    	lea    -0xfde0000(%eax),%eax
f010016d:	a3 04 70 21 f0       	mov    %eax,0xf0217004
		lapic_startap(c->cpu_id, PADDR(code));
f0100172:	83 ec 08             	sub    $0x8,%esp
f0100175:	68 00 70 00 00       	push   $0x7000
f010017a:	0f b6 03             	movzbl (%ebx),%eax
f010017d:	50                   	push   %eax
f010017e:	e8 25 5b 00 00       	call   f0105ca8 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100183:	83 c4 10             	add    $0x10,%esp
f0100186:	8b 43 04             	mov    0x4(%ebx),%eax
f0100189:	83 f8 01             	cmp    $0x1,%eax
f010018c:	75 f8                	jne    f0100186 <i386_init+0xe7>
f010018e:	eb a0                	jmp    f0100130 <i386_init+0x91>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100190:	83 ec 08             	sub    $0x8,%esp
f0100193:	6a 00                	push   $0x0
f0100195:	68 ac de 20 f0       	push   $0xf020deac
f010019a:	e8 85 31 00 00       	call   f0103324 <env_create>
	sched_yield();
f010019f:	e8 2d 41 00 00       	call   f01042d1 <sched_yield>

f01001a4 <mp_main>:
{
f01001a4:	55                   	push   %ebp
f01001a5:	89 e5                	mov    %esp,%ebp
f01001a7:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001aa:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001af:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001b4:	76 52                	jbe    f0100208 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f01001b6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001bb:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001be:	e8 7d 59 00 00       	call   f0105b40 <cpunum>
f01001c3:	83 ec 08             	sub    $0x8,%esp
f01001c6:	50                   	push   %eax
f01001c7:	68 13 62 10 f0       	push   $0xf0106213
f01001cc:	e8 61 37 00 00       	call   f0103932 <cprintf>
	lapic_init();
f01001d1:	e8 80 59 00 00       	call   f0105b56 <lapic_init>
	env_init_percpu();
f01001d6:	e8 22 2f 00 00       	call   f01030fd <env_init_percpu>
	trap_init_percpu();
f01001db:	e8 66 37 00 00       	call   f0103946 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001e0:	e8 5b 59 00 00       	call   f0105b40 <cpunum>
f01001e5:	6b d0 74             	imul   $0x74,%eax,%edx
f01001e8:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01001f0:	f0 87 82 20 80 25 f0 	lock xchg %eax,-0xfda7fe0(%edx)
f01001f7:	c7 04 24 80 44 12 f0 	movl   $0xf0124480,(%esp)
f01001fe:	e8 ad 5b 00 00       	call   f0105db0 <spin_lock>
	sched_yield();
f0100203:	e8 c9 40 00 00       	call   f01042d1 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100208:	50                   	push   %eax
f0100209:	68 c8 61 10 f0       	push   $0xf01061c8
f010020e:	6a 69                	push   $0x69
f0100210:	68 07 62 10 f0       	push   $0xf0106207
f0100215:	e8 26 fe ff ff       	call   f0100040 <_panic>

f010021a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010021a:	55                   	push   %ebp
f010021b:	89 e5                	mov    %esp,%ebp
f010021d:	53                   	push   %ebx
f010021e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100221:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100224:	ff 75 0c             	push   0xc(%ebp)
f0100227:	ff 75 08             	push   0x8(%ebp)
f010022a:	68 29 62 10 f0       	push   $0xf0106229
f010022f:	e8 fe 36 00 00       	call   f0103932 <cprintf>
	vcprintf(fmt, ap);
f0100234:	83 c4 08             	add    $0x8,%esp
f0100237:	53                   	push   %ebx
f0100238:	ff 75 10             	push   0x10(%ebp)
f010023b:	e8 cc 36 00 00       	call   f010390c <vcprintf>
	cprintf("\n");
f0100240:	c7 04 24 ac 73 10 f0 	movl   $0xf01073ac,(%esp)
f0100247:	e8 e6 36 00 00       	call   f0103932 <cprintf>
	va_end(ap);
}
f010024c:	83 c4 10             	add    $0x10,%esp
f010024f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100252:	c9                   	leave  
f0100253:	c3                   	ret    

f0100254 <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100254:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100259:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010025a:	a8 01                	test   $0x1,%al
f010025c:	74 0a                	je     f0100268 <serial_proc_data+0x14>
f010025e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100263:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100264:	0f b6 c0             	movzbl %al,%eax
f0100267:	c3                   	ret    
		return -1;
f0100268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010026d:	c3                   	ret    

f010026e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026e:	55                   	push   %ebp
f010026f:	89 e5                	mov    %esp,%ebp
f0100271:	53                   	push   %ebx
f0100272:	83 ec 04             	sub    $0x4,%esp
f0100275:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100277:	eb 23                	jmp    f010029c <cons_intr+0x2e>
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100279:	8b 0d 44 72 21 f0    	mov    0xf0217244,%ecx
f010027f:	8d 51 01             	lea    0x1(%ecx),%edx
f0100282:	88 81 40 70 21 f0    	mov    %al,-0xfde8fc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100288:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010028e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100293:	0f 44 d0             	cmove  %eax,%edx
f0100296:	89 15 44 72 21 f0    	mov    %edx,0xf0217244
	while ((c = (*proc)()) != -1) {
f010029c:	ff d3                	call   *%ebx
f010029e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a1:	74 06                	je     f01002a9 <cons_intr+0x3b>
		if (c == 0)
f01002a3:	85 c0                	test   %eax,%eax
f01002a5:	75 d2                	jne    f0100279 <cons_intr+0xb>
f01002a7:	eb f3                	jmp    f010029c <cons_intr+0x2e>
	}
}
f01002a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002ac:	c9                   	leave  
f01002ad:	c3                   	ret    

f01002ae <kbd_proc_data>:
{
f01002ae:	55                   	push   %ebp
f01002af:	89 e5                	mov    %esp,%ebp
f01002b1:	53                   	push   %ebx
f01002b2:	83 ec 04             	sub    $0x4,%esp
f01002b5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ba:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002bb:	a8 01                	test   $0x1,%al
f01002bd:	0f 84 ee 00 00 00    	je     f01003b1 <kbd_proc_data+0x103>
	if (stat & KBS_TERR)
f01002c3:	a8 20                	test   $0x20,%al
f01002c5:	0f 85 ed 00 00 00    	jne    f01003b8 <kbd_proc_data+0x10a>
f01002cb:	ba 60 00 00 00       	mov    $0x60,%edx
f01002d0:	ec                   	in     (%dx),%al
f01002d1:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002d3:	3c e0                	cmp    $0xe0,%al
f01002d5:	74 61                	je     f0100338 <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f01002d7:	84 c0                	test   %al,%al
f01002d9:	78 70                	js     f010034b <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f01002db:	8b 0d 20 70 21 f0    	mov    0xf0217020,%ecx
f01002e1:	f6 c1 40             	test   $0x40,%cl
f01002e4:	74 0e                	je     f01002f4 <kbd_proc_data+0x46>
		data |= 0x80;
f01002e6:	83 c8 80             	or     $0xffffff80,%eax
f01002e9:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002eb:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002ee:	89 0d 20 70 21 f0    	mov    %ecx,0xf0217020
	shift |= shiftcode[data];
f01002f4:	0f b6 d2             	movzbl %dl,%edx
f01002f7:	0f b6 82 a0 63 10 f0 	movzbl -0xfef9c60(%edx),%eax
f01002fe:	0b 05 20 70 21 f0    	or     0xf0217020,%eax
	shift ^= togglecode[data];
f0100304:	0f b6 8a a0 62 10 f0 	movzbl -0xfef9d60(%edx),%ecx
f010030b:	31 c8                	xor    %ecx,%eax
f010030d:	a3 20 70 21 f0       	mov    %eax,0xf0217020
	c = charcode[shift & (CTL | SHIFT)][data];
f0100312:	89 c1                	mov    %eax,%ecx
f0100314:	83 e1 03             	and    $0x3,%ecx
f0100317:	8b 0c 8d 80 62 10 f0 	mov    -0xfef9d80(,%ecx,4),%ecx
f010031e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100322:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100325:	a8 08                	test   $0x8,%al
f0100327:	74 5d                	je     f0100386 <kbd_proc_data+0xd8>
		if ('a' <= c && c <= 'z')
f0100329:	89 da                	mov    %ebx,%edx
f010032b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010032e:	83 f9 19             	cmp    $0x19,%ecx
f0100331:	77 47                	ja     f010037a <kbd_proc_data+0xcc>
			c += 'A' - 'a';
f0100333:	83 eb 20             	sub    $0x20,%ebx
f0100336:	eb 0c                	jmp    f0100344 <kbd_proc_data+0x96>
		shift |= E0ESC;
f0100338:	83 0d 20 70 21 f0 40 	orl    $0x40,0xf0217020
		return 0;
f010033f:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100344:	89 d8                	mov    %ebx,%eax
f0100346:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100349:	c9                   	leave  
f010034a:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010034b:	8b 0d 20 70 21 f0    	mov    0xf0217020,%ecx
f0100351:	83 e0 7f             	and    $0x7f,%eax
f0100354:	f6 c1 40             	test   $0x40,%cl
f0100357:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010035a:	0f b6 d2             	movzbl %dl,%edx
f010035d:	0f b6 82 a0 63 10 f0 	movzbl -0xfef9c60(%edx),%eax
f0100364:	83 c8 40             	or     $0x40,%eax
f0100367:	0f b6 c0             	movzbl %al,%eax
f010036a:	f7 d0                	not    %eax
f010036c:	21 c8                	and    %ecx,%eax
f010036e:	a3 20 70 21 f0       	mov    %eax,0xf0217020
		return 0;
f0100373:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100378:	eb ca                	jmp    f0100344 <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f010037a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010037d:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100380:	83 fa 1a             	cmp    $0x1a,%edx
f0100383:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100386:	f7 d0                	not    %eax
f0100388:	a8 06                	test   $0x6,%al
f010038a:	75 b8                	jne    f0100344 <kbd_proc_data+0x96>
f010038c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100392:	75 b0                	jne    f0100344 <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f0100394:	83 ec 0c             	sub    $0xc,%esp
f0100397:	68 43 62 10 f0       	push   $0xf0106243
f010039c:	e8 91 35 00 00       	call   f0103932 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a1:	b8 03 00 00 00       	mov    $0x3,%eax
f01003a6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003ab:	ee                   	out    %al,(%dx)
}
f01003ac:	83 c4 10             	add    $0x10,%esp
f01003af:	eb 93                	jmp    f0100344 <kbd_proc_data+0x96>
		return -1;
f01003b1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003b6:	eb 8c                	jmp    f0100344 <kbd_proc_data+0x96>
		return -1;
f01003b8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003bd:	eb 85                	jmp    f0100344 <kbd_proc_data+0x96>

f01003bf <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003bf:	55                   	push   %ebp
f01003c0:	89 e5                	mov    %esp,%ebp
f01003c2:	57                   	push   %edi
f01003c3:	56                   	push   %esi
f01003c4:	53                   	push   %ebx
f01003c5:	83 ec 1c             	sub    $0x1c,%esp
f01003c8:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cf:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003d4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d9:	89 f2                	mov    %esi,%edx
f01003db:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003dc:	a8 20                	test   $0x20,%al
f01003de:	75 13                	jne    f01003f3 <cons_putc+0x34>
f01003e0:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003e6:	7f 0b                	jg     f01003f3 <cons_putc+0x34>
f01003e8:	89 ca                	mov    %ecx,%edx
f01003ea:	ec                   	in     (%dx),%al
f01003eb:	ec                   	in     (%dx),%al
f01003ec:	ec                   	in     (%dx),%al
f01003ed:	ec                   	in     (%dx),%al
	     i++)
f01003ee:	83 c3 01             	add    $0x1,%ebx
f01003f1:	eb e6                	jmp    f01003d9 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f01003f3:	89 f8                	mov    %edi,%eax
f01003f5:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003fd:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003fe:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100403:	be 79 03 00 00       	mov    $0x379,%esi
f0100408:	b9 84 00 00 00       	mov    $0x84,%ecx
f010040d:	89 f2                	mov    %esi,%edx
f010040f:	ec                   	in     (%dx),%al
f0100410:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100416:	7f 0f                	jg     f0100427 <cons_putc+0x68>
f0100418:	84 c0                	test   %al,%al
f010041a:	78 0b                	js     f0100427 <cons_putc+0x68>
f010041c:	89 ca                	mov    %ecx,%edx
f010041e:	ec                   	in     (%dx),%al
f010041f:	ec                   	in     (%dx),%al
f0100420:	ec                   	in     (%dx),%al
f0100421:	ec                   	in     (%dx),%al
f0100422:	83 c3 01             	add    $0x1,%ebx
f0100425:	eb e6                	jmp    f010040d <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100427:	ba 78 03 00 00       	mov    $0x378,%edx
f010042c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100430:	ee                   	out    %al,(%dx)
f0100431:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100436:	b8 0d 00 00 00       	mov    $0xd,%eax
f010043b:	ee                   	out    %al,(%dx)
f010043c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100441:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100442:	89 f8                	mov    %edi,%eax
f0100444:	80 cc 07             	or     $0x7,%ah
f0100447:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010044d:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100450:	89 f8                	mov    %edi,%eax
f0100452:	0f b6 c0             	movzbl %al,%eax
f0100455:	89 fb                	mov    %edi,%ebx
f0100457:	80 fb 0a             	cmp    $0xa,%bl
f010045a:	0f 84 e1 00 00 00    	je     f0100541 <cons_putc+0x182>
f0100460:	83 f8 0a             	cmp    $0xa,%eax
f0100463:	7f 46                	jg     f01004ab <cons_putc+0xec>
f0100465:	83 f8 08             	cmp    $0x8,%eax
f0100468:	0f 84 a7 00 00 00    	je     f0100515 <cons_putc+0x156>
f010046e:	83 f8 09             	cmp    $0x9,%eax
f0100471:	0f 85 d7 00 00 00    	jne    f010054e <cons_putc+0x18f>
		cons_putc(' ');
f0100477:	b8 20 00 00 00       	mov    $0x20,%eax
f010047c:	e8 3e ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f0100481:	b8 20 00 00 00       	mov    $0x20,%eax
f0100486:	e8 34 ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f010048b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100490:	e8 2a ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f0100495:	b8 20 00 00 00       	mov    $0x20,%eax
f010049a:	e8 20 ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f010049f:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a4:	e8 16 ff ff ff       	call   f01003bf <cons_putc>
		break;
f01004a9:	eb 25                	jmp    f01004d0 <cons_putc+0x111>
	switch (c & 0xff) {
f01004ab:	83 f8 0d             	cmp    $0xd,%eax
f01004ae:	0f 85 9a 00 00 00    	jne    f010054e <cons_putc+0x18f>
		crt_pos -= (crt_pos % CRT_COLS);
f01004b4:	0f b7 05 48 72 21 f0 	movzwl 0xf0217248,%eax
f01004bb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004c1:	c1 e8 16             	shr    $0x16,%eax
f01004c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004c7:	c1 e0 04             	shl    $0x4,%eax
f01004ca:	66 a3 48 72 21 f0    	mov    %ax,0xf0217248
	if (crt_pos >= CRT_SIZE) {
f01004d0:	66 81 3d 48 72 21 f0 	cmpw   $0x7cf,0xf0217248
f01004d7:	cf 07 
f01004d9:	0f 87 92 00 00 00    	ja     f0100571 <cons_putc+0x1b2>
	outb(addr_6845, 14);
f01004df:	8b 0d 50 72 21 f0    	mov    0xf0217250,%ecx
f01004e5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ea:	89 ca                	mov    %ecx,%edx
f01004ec:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004ed:	0f b7 1d 48 72 21 f0 	movzwl 0xf0217248,%ebx
f01004f4:	8d 71 01             	lea    0x1(%ecx),%esi
f01004f7:	89 d8                	mov    %ebx,%eax
f01004f9:	66 c1 e8 08          	shr    $0x8,%ax
f01004fd:	89 f2                	mov    %esi,%edx
f01004ff:	ee                   	out    %al,(%dx)
f0100500:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100505:	89 ca                	mov    %ecx,%edx
f0100507:	ee                   	out    %al,(%dx)
f0100508:	89 d8                	mov    %ebx,%eax
f010050a:	89 f2                	mov    %esi,%edx
f010050c:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010050d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100510:	5b                   	pop    %ebx
f0100511:	5e                   	pop    %esi
f0100512:	5f                   	pop    %edi
f0100513:	5d                   	pop    %ebp
f0100514:	c3                   	ret    
		if (crt_pos > 0) {
f0100515:	0f b7 05 48 72 21 f0 	movzwl 0xf0217248,%eax
f010051c:	66 85 c0             	test   %ax,%ax
f010051f:	74 be                	je     f01004df <cons_putc+0x120>
			crt_pos--;
f0100521:	83 e8 01             	sub    $0x1,%eax
f0100524:	66 a3 48 72 21 f0    	mov    %ax,0xf0217248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010052a:	0f b7 c0             	movzwl %ax,%eax
f010052d:	66 81 e7 00 ff       	and    $0xff00,%di
f0100532:	83 cf 20             	or     $0x20,%edi
f0100535:	8b 15 4c 72 21 f0    	mov    0xf021724c,%edx
f010053b:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010053f:	eb 8f                	jmp    f01004d0 <cons_putc+0x111>
		crt_pos += CRT_COLS;
f0100541:	66 83 05 48 72 21 f0 	addw   $0x50,0xf0217248
f0100548:	50 
f0100549:	e9 66 ff ff ff       	jmp    f01004b4 <cons_putc+0xf5>
		crt_buf[crt_pos++] = c;		/* write the character */
f010054e:	0f b7 05 48 72 21 f0 	movzwl 0xf0217248,%eax
f0100555:	8d 50 01             	lea    0x1(%eax),%edx
f0100558:	66 89 15 48 72 21 f0 	mov    %dx,0xf0217248
f010055f:	0f b7 c0             	movzwl %ax,%eax
f0100562:	8b 15 4c 72 21 f0    	mov    0xf021724c,%edx
f0100568:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010056c:	e9 5f ff ff ff       	jmp    f01004d0 <cons_putc+0x111>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100571:	a1 4c 72 21 f0       	mov    0xf021724c,%eax
f0100576:	83 ec 04             	sub    $0x4,%esp
f0100579:	68 00 0f 00 00       	push   $0xf00
f010057e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100584:	52                   	push   %edx
f0100585:	50                   	push   %eax
f0100586:	e8 06 50 00 00       	call   f0105591 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010058b:	8b 15 4c 72 21 f0    	mov    0xf021724c,%edx
f0100591:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100597:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010059d:	83 c4 10             	add    $0x10,%esp
f01005a0:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a5:	83 c0 02             	add    $0x2,%eax
f01005a8:	39 d0                	cmp    %edx,%eax
f01005aa:	75 f4                	jne    f01005a0 <cons_putc+0x1e1>
		crt_pos -= CRT_COLS;
f01005ac:	66 83 2d 48 72 21 f0 	subw   $0x50,0xf0217248
f01005b3:	50 
f01005b4:	e9 26 ff ff ff       	jmp    f01004df <cons_putc+0x120>

f01005b9 <serial_intr>:
	if (serial_exists)
f01005b9:	80 3d 54 72 21 f0 00 	cmpb   $0x0,0xf0217254
f01005c0:	75 01                	jne    f01005c3 <serial_intr+0xa>
f01005c2:	c3                   	ret    
{
f01005c3:	55                   	push   %ebp
f01005c4:	89 e5                	mov    %esp,%ebp
f01005c6:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005c9:	b8 54 02 10 f0       	mov    $0xf0100254,%eax
f01005ce:	e8 9b fc ff ff       	call   f010026e <cons_intr>
}
f01005d3:	c9                   	leave  
f01005d4:	c3                   	ret    

f01005d5 <kbd_intr>:
{
f01005d5:	55                   	push   %ebp
f01005d6:	89 e5                	mov    %esp,%ebp
f01005d8:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005db:	b8 ae 02 10 f0       	mov    $0xf01002ae,%eax
f01005e0:	e8 89 fc ff ff       	call   f010026e <cons_intr>
}
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <cons_getc>:
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01005ed:	e8 c7 ff ff ff       	call   f01005b9 <serial_intr>
	kbd_intr();
f01005f2:	e8 de ff ff ff       	call   f01005d5 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005f7:	a1 40 72 21 f0       	mov    0xf0217240,%eax
	return 0;
f01005fc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100601:	3b 05 44 72 21 f0    	cmp    0xf0217244,%eax
f0100607:	74 1c                	je     f0100625 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f0100609:	8d 48 01             	lea    0x1(%eax),%ecx
f010060c:	0f b6 90 40 70 21 f0 	movzbl -0xfde8fc0(%eax),%edx
			cons.rpos = 0;
f0100613:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100618:	b8 00 00 00 00       	mov    $0x0,%eax
f010061d:	0f 45 c1             	cmovne %ecx,%eax
f0100620:	a3 40 72 21 f0       	mov    %eax,0xf0217240
}
f0100625:	89 d0                	mov    %edx,%eax
f0100627:	c9                   	leave  
f0100628:	c3                   	ret    

f0100629 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100629:	55                   	push   %ebp
f010062a:	89 e5                	mov    %esp,%ebp
f010062c:	57                   	push   %edi
f010062d:	56                   	push   %esi
f010062e:	53                   	push   %ebx
f010062f:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100632:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100639:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100640:	5a a5 
	if (*cp != 0xA55A) {
f0100642:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100649:	bb b4 03 00 00       	mov    $0x3b4,%ebx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010064e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	if (*cp != 0xA55A) {
f0100653:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100657:	0f 84 c3 00 00 00    	je     f0100720 <cons_init+0xf7>
		addr_6845 = MONO_BASE;
f010065d:	89 1d 50 72 21 f0    	mov    %ebx,0xf0217250
f0100663:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100668:	89 da                	mov    %ebx,%edx
f010066a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010066b:	8d 7b 01             	lea    0x1(%ebx),%edi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066e:	89 fa                	mov    %edi,%edx
f0100670:	ec                   	in     (%dx),%al
f0100671:	0f b6 c8             	movzbl %al,%ecx
f0100674:	c1 e1 08             	shl    $0x8,%ecx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100677:	b8 0f 00 00 00       	mov    $0xf,%eax
f010067c:	89 da                	mov    %ebx,%edx
f010067e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067f:	89 fa                	mov    %edi,%edx
f0100681:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100682:	89 35 4c 72 21 f0    	mov    %esi,0xf021724c
	pos |= inb(addr_6845 + 1);
f0100688:	0f b6 c0             	movzbl %al,%eax
f010068b:	09 c8                	or     %ecx,%eax
	crt_pos = pos;
f010068d:	66 a3 48 72 21 f0    	mov    %ax,0xf0217248
	kbd_intr();
f0100693:	e8 3d ff ff ff       	call   f01005d5 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100698:	83 ec 0c             	sub    $0xc,%esp
f010069b:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f01006a2:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006a7:	50                   	push   %eax
f01006a8:	e8 23 31 00 00       	call   f01037d0 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b2:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006b7:	89 c8                	mov    %ecx,%eax
f01006b9:	89 da                	mov    %ebx,%edx
f01006bb:	ee                   	out    %al,(%dx)
f01006bc:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006c1:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c6:	89 fa                	mov    %edi,%edx
f01006c8:	ee                   	out    %al,(%dx)
f01006c9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006d3:	ee                   	out    %al,(%dx)
f01006d4:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006d9:	89 c8                	mov    %ecx,%eax
f01006db:	89 f2                	mov    %esi,%edx
f01006dd:	ee                   	out    %al,(%dx)
f01006de:	b8 03 00 00 00       	mov    $0x3,%eax
f01006e3:	89 fa                	mov    %edi,%edx
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006eb:	89 c8                	mov    %ecx,%eax
f01006ed:	ee                   	out    %al,(%dx)
f01006ee:	b8 01 00 00 00       	mov    $0x1,%eax
f01006f3:	89 f2                	mov    %esi,%edx
f01006f5:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006fb:	ec                   	in     (%dx),%al
f01006fc:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006fe:	83 c4 10             	add    $0x10,%esp
f0100701:	3c ff                	cmp    $0xff,%al
f0100703:	0f 95 05 54 72 21 f0 	setne  0xf0217254
f010070a:	89 da                	mov    %ebx,%edx
f010070c:	ec                   	in     (%dx),%al
f010070d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100712:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100713:	80 f9 ff             	cmp    $0xff,%cl
f0100716:	74 1e                	je     f0100736 <cons_init+0x10d>
		cprintf("Serial port does not exist!\n");
}
f0100718:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010071b:	5b                   	pop    %ebx
f010071c:	5e                   	pop    %esi
f010071d:	5f                   	pop    %edi
f010071e:	5d                   	pop    %ebp
f010071f:	c3                   	ret    
		*cp = was;
f0100720:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100727:	bb d4 03 00 00       	mov    $0x3d4,%ebx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010072c:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100731:	e9 27 ff ff ff       	jmp    f010065d <cons_init+0x34>
		cprintf("Serial port does not exist!\n");
f0100736:	83 ec 0c             	sub    $0xc,%esp
f0100739:	68 4f 62 10 f0       	push   $0xf010624f
f010073e:	e8 ef 31 00 00       	call   f0103932 <cprintf>
f0100743:	83 c4 10             	add    $0x10,%esp
}
f0100746:	eb d0                	jmp    f0100718 <cons_init+0xef>

f0100748 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100748:	55                   	push   %ebp
f0100749:	89 e5                	mov    %esp,%ebp
f010074b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010074e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100751:	e8 69 fc ff ff       	call   f01003bf <cons_putc>
}
f0100756:	c9                   	leave  
f0100757:	c3                   	ret    

f0100758 <getchar>:

int
getchar(void)
{
f0100758:	55                   	push   %ebp
f0100759:	89 e5                	mov    %esp,%ebp
f010075b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010075e:	e8 84 fe ff ff       	call   f01005e7 <cons_getc>
f0100763:	85 c0                	test   %eax,%eax
f0100765:	74 f7                	je     f010075e <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100767:	c9                   	leave  
f0100768:	c3                   	ret    

f0100769 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100769:	b8 01 00 00 00       	mov    $0x1,%eax
f010076e:	c3                   	ret    

f010076f <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010076f:	55                   	push   %ebp
f0100770:	89 e5                	mov    %esp,%ebp
f0100772:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100775:	68 a0 64 10 f0       	push   $0xf01064a0
f010077a:	68 be 64 10 f0       	push   $0xf01064be
f010077f:	68 c3 64 10 f0       	push   $0xf01064c3
f0100784:	e8 a9 31 00 00       	call   f0103932 <cprintf>
f0100789:	83 c4 0c             	add    $0xc,%esp
f010078c:	68 60 65 10 f0       	push   $0xf0106560
f0100791:	68 cc 64 10 f0       	push   $0xf01064cc
f0100796:	68 c3 64 10 f0       	push   $0xf01064c3
f010079b:	e8 92 31 00 00       	call   f0103932 <cprintf>
f01007a0:	83 c4 0c             	add    $0xc,%esp
f01007a3:	68 88 65 10 f0       	push   $0xf0106588
f01007a8:	68 d5 64 10 f0       	push   $0xf01064d5
f01007ad:	68 c3 64 10 f0       	push   $0xf01064c3
f01007b2:	e8 7b 31 00 00       	call   f0103932 <cprintf>
	return 0;
}
f01007b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bc:	c9                   	leave  
f01007bd:	c3                   	ret    

f01007be <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007be:	55                   	push   %ebp
f01007bf:	89 e5                	mov    %esp,%ebp
f01007c1:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c4:	68 df 64 10 f0       	push   $0xf01064df
f01007c9:	e8 64 31 00 00       	call   f0103932 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ce:	83 c4 08             	add    $0x8,%esp
f01007d1:	68 0c 00 10 00       	push   $0x10000c
f01007d6:	68 ac 65 10 f0       	push   $0xf01065ac
f01007db:	e8 52 31 00 00       	call   f0103932 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e0:	83 c4 0c             	add    $0xc,%esp
f01007e3:	68 0c 00 10 00       	push   $0x10000c
f01007e8:	68 0c 00 10 f0       	push   $0xf010000c
f01007ed:	68 d4 65 10 f0       	push   $0xf01065d4
f01007f2:	e8 3b 31 00 00       	call   f0103932 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007f7:	83 c4 0c             	add    $0xc,%esp
f01007fa:	68 71 61 10 00       	push   $0x106171
f01007ff:	68 71 61 10 f0       	push   $0xf0106171
f0100804:	68 f8 65 10 f0       	push   $0xf01065f8
f0100809:	e8 24 31 00 00       	call   f0103932 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010080e:	83 c4 0c             	add    $0xc,%esp
f0100811:	68 00 70 21 00       	push   $0x217000
f0100816:	68 00 70 21 f0       	push   $0xf0217000
f010081b:	68 1c 66 10 f0       	push   $0xf010661c
f0100820:	e8 0d 31 00 00       	call   f0103932 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100825:	83 c4 0c             	add    $0xc,%esp
f0100828:	68 c8 83 25 00       	push   $0x2583c8
f010082d:	68 c8 83 25 f0       	push   $0xf02583c8
f0100832:	68 40 66 10 f0       	push   $0xf0106640
f0100837:	e8 f6 30 00 00       	call   f0103932 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010083c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010083f:	b8 c8 83 25 f0       	mov    $0xf02583c8,%eax
f0100844:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100849:	c1 f8 0a             	sar    $0xa,%eax
f010084c:	50                   	push   %eax
f010084d:	68 64 66 10 f0       	push   $0xf0106664
f0100852:	e8 db 30 00 00       	call   f0103932 <cprintf>
	return 0;
}
f0100857:	b8 00 00 00 00       	mov    $0x0,%eax
f010085c:	c9                   	leave  
f010085d:	c3                   	ret    

f010085e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010085e:	55                   	push   %ebp
f010085f:	89 e5                	mov    %esp,%ebp
f0100861:	57                   	push   %edi
f0100862:	56                   	push   %esi
f0100863:	53                   	push   %ebx
f0100864:	83 ec 38             	sub    $0x38,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100867:	89 eb                	mov    %ebp,%ebx
	uint32_t *ebp, eip;
	struct Eipdebuginfo info;
	ebp = (uint32_t*)read_ebp();

	cprintf("Stack backtrace:\n");
f0100869:	68 f8 64 10 f0       	push   $0xf01064f8
f010086e:	e8 bf 30 00 00       	call   f0103932 <cprintf>
	while (ebp != 0x0) {
f0100873:	83 c4 10             	add    $0x10,%esp
		eip = *(ebp + 1);
		cprintf("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
			ebp, eip, *(ebp + 2), *(ebp + 3), *(ebp + 4), *(ebp + 5), *(ebp + 6));
		debuginfo_eip((uintptr_t)eip, &info);
f0100876:	8d 7d d0             	lea    -0x30(%ebp),%edi
	while (ebp != 0x0) {
f0100879:	eb 64                	jmp    f01008df <mon_backtrace+0x81>
		eip = *(ebp + 1);
f010087b:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
f010087e:	ff 73 18             	push   0x18(%ebx)
f0100881:	ff 73 14             	push   0x14(%ebx)
f0100884:	ff 73 10             	push   0x10(%ebx)
f0100887:	ff 73 0c             	push   0xc(%ebx)
f010088a:	ff 73 08             	push   0x8(%ebx)
f010088d:	56                   	push   %esi
f010088e:	53                   	push   %ebx
f010088f:	68 90 66 10 f0       	push   $0xf0106690
f0100894:	e8 99 30 00 00       	call   f0103932 <cprintf>
		debuginfo_eip((uintptr_t)eip, &info);
f0100899:	83 c4 18             	add    $0x18,%esp
f010089c:	57                   	push   %edi
f010089d:	56                   	push   %esi
f010089e:	e8 e2 41 00 00       	call   f0104a85 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f01008a3:	83 c4 0c             	add    $0xc,%esp
f01008a6:	ff 75 d4             	push   -0x2c(%ebp)
f01008a9:	ff 75 d0             	push   -0x30(%ebp)
f01008ac:	68 0a 65 10 f0       	push   $0xf010650a
f01008b1:	e8 7c 30 00 00       	call   f0103932 <cprintf>
		cprintf("%.*s+", info.eip_fn_namelen, info.eip_fn_name);
f01008b6:	83 c4 0c             	add    $0xc,%esp
f01008b9:	ff 75 d8             	push   -0x28(%ebp)
f01008bc:	ff 75 dc             	push   -0x24(%ebp)
f01008bf:	68 1b 65 10 f0       	push   $0xf010651b
f01008c4:	e8 69 30 00 00       	call   f0103932 <cprintf>
		cprintf("%d\n", eip - info.eip_fn_addr);
f01008c9:	83 c4 08             	add    $0x8,%esp
f01008cc:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01008cf:	56                   	push   %esi
f01008d0:	68 63 75 10 f0       	push   $0xf0107563
f01008d5:	e8 58 30 00 00       	call   f0103932 <cprintf>
		ebp = (uint32_t*)*ebp;
f01008da:	8b 1b                	mov    (%ebx),%ebx
f01008dc:	83 c4 10             	add    $0x10,%esp
	while (ebp != 0x0) {
f01008df:	85 db                	test   %ebx,%ebx
f01008e1:	75 98                	jne    f010087b <mon_backtrace+0x1d>
	}
	return 0;
}
f01008e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008eb:	5b                   	pop    %ebx
f01008ec:	5e                   	pop    %esi
f01008ed:	5f                   	pop    %edi
f01008ee:	5d                   	pop    %ebp
f01008ef:	c3                   	ret    

f01008f0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008f0:	55                   	push   %ebp
f01008f1:	89 e5                	mov    %esp,%ebp
f01008f3:	57                   	push   %edi
f01008f4:	56                   	push   %esi
f01008f5:	53                   	push   %ebx
f01008f6:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008f9:	68 c4 66 10 f0       	push   $0xf01066c4
f01008fe:	e8 2f 30 00 00       	call   f0103932 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100903:	c7 04 24 e8 66 10 f0 	movl   $0xf01066e8,(%esp)
f010090a:	e8 23 30 00 00       	call   f0103932 <cprintf>

	if (tf != NULL)
f010090f:	83 c4 10             	add    $0x10,%esp
f0100912:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100916:	74 57                	je     f010096f <monitor+0x7f>
		print_trapframe(tf);
f0100918:	83 ec 0c             	sub    $0xc,%esp
f010091b:	ff 75 08             	push   0x8(%ebp)
f010091e:	e8 25 32 00 00       	call   f0103b48 <print_trapframe>
f0100923:	83 c4 10             	add    $0x10,%esp
f0100926:	eb 47                	jmp    f010096f <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100928:	83 ec 08             	sub    $0x8,%esp
f010092b:	0f be c0             	movsbl %al,%eax
f010092e:	50                   	push   %eax
f010092f:	68 25 65 10 f0       	push   $0xf0106525
f0100934:	e8 d3 4b 00 00       	call   f010550c <strchr>
f0100939:	83 c4 10             	add    $0x10,%esp
f010093c:	85 c0                	test   %eax,%eax
f010093e:	74 0a                	je     f010094a <monitor+0x5a>
			*buf++ = 0;
f0100940:	c6 03 00             	movb   $0x0,(%ebx)
f0100943:	89 f7                	mov    %esi,%edi
f0100945:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100948:	eb 6b                	jmp    f01009b5 <monitor+0xc5>
		if (*buf == 0)
f010094a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010094d:	74 73                	je     f01009c2 <monitor+0xd2>
		if (argc == MAXARGS-1) {
f010094f:	83 fe 0f             	cmp    $0xf,%esi
f0100952:	74 09                	je     f010095d <monitor+0x6d>
		argv[argc++] = buf;
f0100954:	8d 7e 01             	lea    0x1(%esi),%edi
f0100957:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f010095b:	eb 39                	jmp    f0100996 <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010095d:	83 ec 08             	sub    $0x8,%esp
f0100960:	6a 10                	push   $0x10
f0100962:	68 2a 65 10 f0       	push   $0xf010652a
f0100967:	e8 c6 2f 00 00       	call   f0103932 <cprintf>
			return 0;
f010096c:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010096f:	83 ec 0c             	sub    $0xc,%esp
f0100972:	68 21 65 10 f0       	push   $0xf0106521
f0100977:	e8 62 49 00 00       	call   f01052de <readline>
f010097c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010097e:	83 c4 10             	add    $0x10,%esp
f0100981:	85 c0                	test   %eax,%eax
f0100983:	74 ea                	je     f010096f <monitor+0x7f>
	argv[argc] = 0;
f0100985:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f010098c:	be 00 00 00 00       	mov    $0x0,%esi
f0100991:	eb 24                	jmp    f01009b7 <monitor+0xc7>
			buf++;
f0100993:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100996:	0f b6 03             	movzbl (%ebx),%eax
f0100999:	84 c0                	test   %al,%al
f010099b:	74 18                	je     f01009b5 <monitor+0xc5>
f010099d:	83 ec 08             	sub    $0x8,%esp
f01009a0:	0f be c0             	movsbl %al,%eax
f01009a3:	50                   	push   %eax
f01009a4:	68 25 65 10 f0       	push   $0xf0106525
f01009a9:	e8 5e 4b 00 00       	call   f010550c <strchr>
f01009ae:	83 c4 10             	add    $0x10,%esp
f01009b1:	85 c0                	test   %eax,%eax
f01009b3:	74 de                	je     f0100993 <monitor+0xa3>
			*buf++ = 0;
f01009b5:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01009b7:	0f b6 03             	movzbl (%ebx),%eax
f01009ba:	84 c0                	test   %al,%al
f01009bc:	0f 85 66 ff ff ff    	jne    f0100928 <monitor+0x38>
	argv[argc] = 0;
f01009c2:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009c9:	00 
	if (argc == 0)
f01009ca:	85 f6                	test   %esi,%esi
f01009cc:	74 a1                	je     f010096f <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009ce:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f01009d3:	83 ec 08             	sub    $0x8,%esp
f01009d6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009d9:	ff 34 85 20 67 10 f0 	push   -0xfef98e0(,%eax,4)
f01009e0:	ff 75 a8             	push   -0x58(%ebp)
f01009e3:	e8 c4 4a 00 00       	call   f01054ac <strcmp>
f01009e8:	83 c4 10             	add    $0x10,%esp
f01009eb:	85 c0                	test   %eax,%eax
f01009ed:	74 20                	je     f0100a0f <monitor+0x11f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009ef:	83 c3 01             	add    $0x1,%ebx
f01009f2:	83 fb 03             	cmp    $0x3,%ebx
f01009f5:	75 dc                	jne    f01009d3 <monitor+0xe3>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009f7:	83 ec 08             	sub    $0x8,%esp
f01009fa:	ff 75 a8             	push   -0x58(%ebp)
f01009fd:	68 47 65 10 f0       	push   $0xf0106547
f0100a02:	e8 2b 2f 00 00       	call   f0103932 <cprintf>
	return 0;
f0100a07:	83 c4 10             	add    $0x10,%esp
f0100a0a:	e9 60 ff ff ff       	jmp    f010096f <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100a0f:	83 ec 04             	sub    $0x4,%esp
f0100a12:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a15:	ff 75 08             	push   0x8(%ebp)
f0100a18:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a1b:	52                   	push   %edx
f0100a1c:	56                   	push   %esi
f0100a1d:	ff 14 85 28 67 10 f0 	call   *-0xfef98d8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a24:	83 c4 10             	add    $0x10,%esp
f0100a27:	85 c0                	test   %eax,%eax
f0100a29:	0f 89 40 ff ff ff    	jns    f010096f <monitor+0x7f>
				break;
	}
}
f0100a2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a32:	5b                   	pop    %ebx
f0100a33:	5e                   	pop    %esi
f0100a34:	5f                   	pop    %edi
f0100a35:	5d                   	pop    %ebp
f0100a36:	c3                   	ret    

f0100a37 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a37:	55                   	push   %ebp
f0100a38:	89 e5                	mov    %esp,%ebp
f0100a3a:	56                   	push   %esi
f0100a3b:	53                   	push   %ebx
f0100a3c:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a3e:	83 ec 0c             	sub    $0xc,%esp
f0100a41:	50                   	push   %eax
f0100a42:	e8 5b 2d 00 00       	call   f01037a2 <mc146818_read>
f0100a47:	89 c6                	mov    %eax,%esi
f0100a49:	83 c3 01             	add    $0x1,%ebx
f0100a4c:	89 1c 24             	mov    %ebx,(%esp)
f0100a4f:	e8 4e 2d 00 00       	call   f01037a2 <mc146818_read>
f0100a54:	c1 e0 08             	shl    $0x8,%eax
f0100a57:	09 f0                	or     %esi,%eax
}
f0100a59:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a5c:	5b                   	pop    %ebx
f0100a5d:	5e                   	pop    %esi
f0100a5e:	5d                   	pop    %ebp
f0100a5f:	c3                   	ret    

f0100a60 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a60:	55                   	push   %ebp
f0100a61:	89 e5                	mov    %esp,%ebp
f0100a63:	83 ec 08             	sub    $0x8,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a66:	83 3d 64 72 21 f0 00 	cmpl   $0x0,0xf0217264
f0100a6d:	74 34                	je     f0100aa3 <boot_alloc+0x43>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	result = nextfree;
f0100a6f:	8b 15 64 72 21 f0    	mov    0xf0217264,%edx
	nextfree += ROUNDUP(n, PGSIZE);
f0100a75:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100a7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a7f:	01 d0                	add    %edx,%eax
f0100a81:	a3 64 72 21 f0       	mov    %eax,0xf0217264
	if ((uint32_t)kva < KERNBASE)
f0100a86:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100a8b:	76 29                	jbe    f0100ab6 <boot_alloc+0x56>

	if (PADDR(nextfree) >= npages * PGSIZE) {
f0100a8d:	8b 0d 60 72 21 f0    	mov    0xf0217260,%ecx
f0100a93:	c1 e1 0c             	shl    $0xc,%ecx
	return (physaddr_t)kva - KERNBASE;
f0100a96:	05 00 00 00 10       	add    $0x10000000,%eax
f0100a9b:	39 c1                	cmp    %eax,%ecx
f0100a9d:	76 29                	jbe    f0100ac8 <boot_alloc+0x68>
		panic("boot_alloc: out of memeory");
	}

	return (void *)result;
}
f0100a9f:	89 d0                	mov    %edx,%eax
f0100aa1:	c9                   	leave  
f0100aa2:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aa3:	ba c7 93 25 f0       	mov    $0xf02593c7,%edx
f0100aa8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aae:	89 15 64 72 21 f0    	mov    %edx,0xf0217264
f0100ab4:	eb b9                	jmp    f0100a6f <boot_alloc+0xf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ab6:	50                   	push   %eax
f0100ab7:	68 c8 61 10 f0       	push   $0xf01061c8
f0100abc:	6a 6d                	push   $0x6d
f0100abe:	68 8d 70 10 f0       	push   $0xf010708d
f0100ac3:	e8 78 f5 ff ff       	call   f0100040 <_panic>
		panic("boot_alloc: out of memeory");
f0100ac8:	83 ec 04             	sub    $0x4,%esp
f0100acb:	68 99 70 10 f0       	push   $0xf0107099
f0100ad0:	6a 6e                	push   $0x6e
f0100ad2:	68 8d 70 10 f0       	push   $0xf010708d
f0100ad7:	e8 64 f5 ff ff       	call   f0100040 <_panic>

f0100adc <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100adc:	89 d1                	mov    %edx,%ecx
f0100ade:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ae1:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ae4:	a8 01                	test   $0x1,%al
f0100ae6:	74 51                	je     f0100b39 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ae8:	89 c1                	mov    %eax,%ecx
f0100aea:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100af0:	c1 e8 0c             	shr    $0xc,%eax
f0100af3:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0100af9:	73 23                	jae    f0100b1e <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100afb:	c1 ea 0c             	shr    $0xc,%edx
f0100afe:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b04:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b0b:	89 d0                	mov    %edx,%eax
f0100b0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b12:	f6 c2 01             	test   $0x1,%dl
f0100b15:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b1a:	0f 44 c2             	cmove  %edx,%eax
f0100b1d:	c3                   	ret    
{
f0100b1e:	55                   	push   %ebp
f0100b1f:	89 e5                	mov    %esp,%ebp
f0100b21:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b24:	51                   	push   %ecx
f0100b25:	68 a4 61 10 f0       	push   $0xf01061a4
f0100b2a:	68 bf 03 00 00       	push   $0x3bf
f0100b2f:	68 8d 70 10 f0       	push   $0xf010708d
f0100b34:	e8 07 f5 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b3e:	c3                   	ret    

f0100b3f <check_page_free_list>:
{
f0100b3f:	55                   	push   %ebp
f0100b40:	89 e5                	mov    %esp,%ebp
f0100b42:	57                   	push   %edi
f0100b43:	56                   	push   %esi
f0100b44:	53                   	push   %ebx
f0100b45:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b48:	84 c0                	test   %al,%al
f0100b4a:	0f 85 77 02 00 00    	jne    f0100dc7 <check_page_free_list+0x288>
	if (!page_free_list)
f0100b50:	83 3d 6c 72 21 f0 00 	cmpl   $0x0,0xf021726c
f0100b57:	74 0a                	je     f0100b63 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b59:	be 00 04 00 00       	mov    $0x400,%esi
f0100b5e:	e9 bf 02 00 00       	jmp    f0100e22 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100b63:	83 ec 04             	sub    $0x4,%esp
f0100b66:	68 44 67 10 f0       	push   $0xf0106744
f0100b6b:	68 f2 02 00 00       	push   $0x2f2
f0100b70:	68 8d 70 10 f0       	push   $0xf010708d
f0100b75:	e8 c6 f4 ff ff       	call   f0100040 <_panic>
f0100b7a:	50                   	push   %eax
f0100b7b:	68 a4 61 10 f0       	push   $0xf01061a4
f0100b80:	6a 58                	push   $0x58
f0100b82:	68 b4 70 10 f0       	push   $0xf01070b4
f0100b87:	e8 b4 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b8c:	8b 1b                	mov    (%ebx),%ebx
f0100b8e:	85 db                	test   %ebx,%ebx
f0100b90:	74 41                	je     f0100bd3 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b92:	89 d8                	mov    %ebx,%eax
f0100b94:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0100b9a:	c1 f8 03             	sar    $0x3,%eax
f0100b9d:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ba0:	89 c2                	mov    %eax,%edx
f0100ba2:	c1 ea 16             	shr    $0x16,%edx
f0100ba5:	39 f2                	cmp    %esi,%edx
f0100ba7:	73 e3                	jae    f0100b8c <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100ba9:	89 c2                	mov    %eax,%edx
f0100bab:	c1 ea 0c             	shr    $0xc,%edx
f0100bae:	3b 15 60 72 21 f0    	cmp    0xf0217260,%edx
f0100bb4:	73 c4                	jae    f0100b7a <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bb6:	83 ec 04             	sub    $0x4,%esp
f0100bb9:	68 80 00 00 00       	push   $0x80
f0100bbe:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bc3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bc8:	50                   	push   %eax
f0100bc9:	e8 7d 49 00 00       	call   f010554b <memset>
f0100bce:	83 c4 10             	add    $0x10,%esp
f0100bd1:	eb b9                	jmp    f0100b8c <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100bd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bd8:	e8 83 fe ff ff       	call   f0100a60 <boot_alloc>
f0100bdd:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be0:	8b 15 6c 72 21 f0    	mov    0xf021726c,%edx
		assert(pp >= pages);
f0100be6:	8b 0d 58 72 21 f0    	mov    0xf0217258,%ecx
		assert(pp < pages + npages);
f0100bec:	a1 60 72 21 f0       	mov    0xf0217260,%eax
f0100bf1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100bf4:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bf7:	bf 00 00 00 00       	mov    $0x0,%edi
f0100bfc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bff:	e9 f9 00 00 00       	jmp    f0100cfd <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100c04:	68 c2 70 10 f0       	push   $0xf01070c2
f0100c09:	68 ce 70 10 f0       	push   $0xf01070ce
f0100c0e:	68 0c 03 00 00       	push   $0x30c
f0100c13:	68 8d 70 10 f0       	push   $0xf010708d
f0100c18:	e8 23 f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c1d:	68 e3 70 10 f0       	push   $0xf01070e3
f0100c22:	68 ce 70 10 f0       	push   $0xf01070ce
f0100c27:	68 0d 03 00 00       	push   $0x30d
f0100c2c:	68 8d 70 10 f0       	push   $0xf010708d
f0100c31:	e8 0a f4 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c36:	68 68 67 10 f0       	push   $0xf0106768
f0100c3b:	68 ce 70 10 f0       	push   $0xf01070ce
f0100c40:	68 0e 03 00 00       	push   $0x30e
f0100c45:	68 8d 70 10 f0       	push   $0xf010708d
f0100c4a:	e8 f1 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c4f:	68 f7 70 10 f0       	push   $0xf01070f7
f0100c54:	68 ce 70 10 f0       	push   $0xf01070ce
f0100c59:	68 11 03 00 00       	push   $0x311
f0100c5e:	68 8d 70 10 f0       	push   $0xf010708d
f0100c63:	e8 d8 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c68:	68 08 71 10 f0       	push   $0xf0107108
f0100c6d:	68 ce 70 10 f0       	push   $0xf01070ce
f0100c72:	68 12 03 00 00       	push   $0x312
f0100c77:	68 8d 70 10 f0       	push   $0xf010708d
f0100c7c:	e8 bf f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c81:	68 9c 67 10 f0       	push   $0xf010679c
f0100c86:	68 ce 70 10 f0       	push   $0xf01070ce
f0100c8b:	68 13 03 00 00       	push   $0x313
f0100c90:	68 8d 70 10 f0       	push   $0xf010708d
f0100c95:	e8 a6 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c9a:	68 21 71 10 f0       	push   $0xf0107121
f0100c9f:	68 ce 70 10 f0       	push   $0xf01070ce
f0100ca4:	68 14 03 00 00       	push   $0x314
f0100ca9:	68 8d 70 10 f0       	push   $0xf010708d
f0100cae:	e8 8d f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100cb3:	89 c3                	mov    %eax,%ebx
f0100cb5:	c1 eb 0c             	shr    $0xc,%ebx
f0100cb8:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100cbb:	76 0f                	jbe    f0100ccc <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100cbd:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cc2:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100cc5:	77 17                	ja     f0100cde <check_page_free_list+0x19f>
			++nfree_extmem;
f0100cc7:	83 c7 01             	add    $0x1,%edi
f0100cca:	eb 2f                	jmp    f0100cfb <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ccc:	50                   	push   %eax
f0100ccd:	68 a4 61 10 f0       	push   $0xf01061a4
f0100cd2:	6a 58                	push   $0x58
f0100cd4:	68 b4 70 10 f0       	push   $0xf01070b4
f0100cd9:	e8 62 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cde:	68 c0 67 10 f0       	push   $0xf01067c0
f0100ce3:	68 ce 70 10 f0       	push   $0xf01070ce
f0100ce8:	68 15 03 00 00       	push   $0x315
f0100ced:	68 8d 70 10 f0       	push   $0xf010708d
f0100cf2:	e8 49 f3 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100cf7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cfb:	8b 12                	mov    (%edx),%edx
f0100cfd:	85 d2                	test   %edx,%edx
f0100cff:	74 74                	je     f0100d75 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100d01:	39 d1                	cmp    %edx,%ecx
f0100d03:	0f 87 fb fe ff ff    	ja     f0100c04 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100d09:	39 d6                	cmp    %edx,%esi
f0100d0b:	0f 86 0c ff ff ff    	jbe    f0100c1d <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d11:	89 d0                	mov    %edx,%eax
f0100d13:	29 c8                	sub    %ecx,%eax
f0100d15:	a8 07                	test   $0x7,%al
f0100d17:	0f 85 19 ff ff ff    	jne    f0100c36 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100d1d:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d20:	c1 e0 0c             	shl    $0xc,%eax
f0100d23:	0f 84 26 ff ff ff    	je     f0100c4f <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d29:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d2e:	0f 84 34 ff ff ff    	je     f0100c68 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d34:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d39:	0f 84 42 ff ff ff    	je     f0100c81 <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d3f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d44:	0f 84 50 ff ff ff    	je     f0100c9a <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d4a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d4f:	0f 87 5e ff ff ff    	ja     f0100cb3 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d55:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d5a:	75 9b                	jne    f0100cf7 <check_page_free_list+0x1b8>
f0100d5c:	68 3b 71 10 f0       	push   $0xf010713b
f0100d61:	68 ce 70 10 f0       	push   $0xf01070ce
f0100d66:	68 17 03 00 00       	push   $0x317
f0100d6b:	68 8d 70 10 f0       	push   $0xf010708d
f0100d70:	e8 cb f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100d75:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d78:	85 db                	test   %ebx,%ebx
f0100d7a:	7e 19                	jle    f0100d95 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100d7c:	85 ff                	test   %edi,%edi
f0100d7e:	7e 2e                	jle    f0100dae <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100d80:	83 ec 0c             	sub    $0xc,%esp
f0100d83:	68 08 68 10 f0       	push   $0xf0106808
f0100d88:	e8 a5 2b 00 00       	call   f0103932 <cprintf>
}
f0100d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d90:	5b                   	pop    %ebx
f0100d91:	5e                   	pop    %esi
f0100d92:	5f                   	pop    %edi
f0100d93:	5d                   	pop    %ebp
f0100d94:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d95:	68 58 71 10 f0       	push   $0xf0107158
f0100d9a:	68 ce 70 10 f0       	push   $0xf01070ce
f0100d9f:	68 1f 03 00 00       	push   $0x31f
f0100da4:	68 8d 70 10 f0       	push   $0xf010708d
f0100da9:	e8 92 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100dae:	68 6a 71 10 f0       	push   $0xf010716a
f0100db3:	68 ce 70 10 f0       	push   $0xf01070ce
f0100db8:	68 20 03 00 00       	push   $0x320
f0100dbd:	68 8d 70 10 f0       	push   $0xf010708d
f0100dc2:	e8 79 f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100dc7:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f0100dcc:	85 c0                	test   %eax,%eax
f0100dce:	0f 84 8f fd ff ff    	je     f0100b63 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100dd4:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100dd7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100dda:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ddd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100de0:	89 c2                	mov    %eax,%edx
f0100de2:	2b 15 58 72 21 f0    	sub    0xf0217258,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100de8:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100dee:	0f 95 c2             	setne  %dl
f0100df1:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100df4:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100df8:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100dfa:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dfe:	8b 00                	mov    (%eax),%eax
f0100e00:	85 c0                	test   %eax,%eax
f0100e02:	75 dc                	jne    f0100de0 <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100e04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e0d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e13:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e15:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e18:	a3 6c 72 21 f0       	mov    %eax,0xf021726c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e1d:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e22:	8b 1d 6c 72 21 f0    	mov    0xf021726c,%ebx
f0100e28:	e9 61 fd ff ff       	jmp    f0100b8e <check_page_free_list+0x4f>

f0100e2d <page_init>:
{
f0100e2d:	55                   	push   %ebp
f0100e2e:	89 e5                	mov    %esp,%ebp
f0100e30:	56                   	push   %esi
f0100e31:	53                   	push   %ebx
	page_free_list = NULL;
f0100e32:	c7 05 6c 72 21 f0 00 	movl   $0x0,0xf021726c
f0100e39:	00 00 00 
	int nextfree = ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f0100e3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e41:	e8 1a fc ff ff       	call   f0100a60 <boot_alloc>
f0100e46:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0100e4c:	c1 eb 0c             	shr    $0xc,%ebx
	pages[0].pp_ref = 1;
f0100e4f:	a1 58 72 21 f0       	mov    0xf0217258,%eax
f0100e54:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f0100e5a:	b8 08 00 00 00       	mov    $0x8,%eax
f0100e5f:	ba 00 00 00 00       	mov    $0x0,%edx
			pages[i].pp_ref = 0;
f0100e64:	89 c1                	mov    %eax,%ecx
f0100e66:	03 0d 58 72 21 f0    	add    0xf0217258,%ecx
f0100e6c:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;
f0100e72:	89 11                	mov    %edx,(%ecx)
			page_free_list = &pages[i];
f0100e74:	8b 0d 58 72 21 f0    	mov    0xf0217258,%ecx
f0100e7a:	8d 14 01             	lea    (%ecx,%eax,1),%edx
		for(i=1; i < MPENTRY_PADDR / PGSIZE ; i++)
f0100e7d:	83 c0 08             	add    $0x8,%eax
f0100e80:	83 f8 38             	cmp    $0x38,%eax
f0100e83:	75 df                	jne    f0100e64 <page_init+0x37>
f0100e85:	89 15 6c 72 21 f0    	mov    %edx,0xf021726c
		for(i = npages_basemem ;  i < (EXTPHYSMEM-IOPHYSMEM)/PGSIZE + nextfree + npages_basemem ; i++)
f0100e8b:	8b 35 70 72 21 f0    	mov    0xf0217270,%esi
f0100e91:	89 f0                	mov    %esi,%eax
f0100e93:	8d 5c 33 60          	lea    0x60(%ebx,%esi,1),%ebx
f0100e97:	eb 0a                	jmp    f0100ea3 <page_init+0x76>
			pages[i].pp_ref = 1;
f0100e99:	66 c7 44 c1 04 01 00 	movw   $0x1,0x4(%ecx,%eax,8)
		for(i = npages_basemem ;  i < (EXTPHYSMEM-IOPHYSMEM)/PGSIZE + nextfree + npages_basemem ; i++)
f0100ea0:	83 c0 01             	add    $0x1,%eax
f0100ea3:	39 c3                	cmp    %eax,%ebx
f0100ea5:	77 f2                	ja     f0100e99 <page_init+0x6c>
f0100ea7:	b9 00 00 00 00       	mov    $0x0,%ecx
		for(; i < npages ; i++)	 
f0100eac:	be 01 00 00 00       	mov    $0x1,%esi
f0100eb1:	eb 24                	jmp    f0100ed7 <page_init+0xaa>
f0100eb3:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
			pages[i].pp_ref = 0;
f0100eba:	89 cb                	mov    %ecx,%ebx
f0100ebc:	03 1d 58 72 21 f0    	add    0xf0217258,%ebx
f0100ec2:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
			pages[i].pp_link = page_free_list; // next page free on page free list
f0100ec8:	89 13                	mov    %edx,(%ebx)
	 		page_free_list = &pages[i];	        //set free list on i-th page
f0100eca:	89 ca                	mov    %ecx,%edx
f0100ecc:	03 15 58 72 21 f0    	add    0xf0217258,%edx
		for(; i < npages ; i++)	 
f0100ed2:	83 c0 01             	add    $0x1,%eax
f0100ed5:	89 f1                	mov    %esi,%ecx
f0100ed7:	39 05 60 72 21 f0    	cmp    %eax,0xf0217260
f0100edd:	77 d4                	ja     f0100eb3 <page_init+0x86>
f0100edf:	84 c9                	test   %cl,%cl
f0100ee1:	74 06                	je     f0100ee9 <page_init+0xbc>
f0100ee3:	89 15 6c 72 21 f0    	mov    %edx,0xf021726c
}
f0100ee9:	5b                   	pop    %ebx
f0100eea:	5e                   	pop    %esi
f0100eeb:	5d                   	pop    %ebp
f0100eec:	c3                   	ret    

f0100eed <page_alloc>:
{
f0100eed:	55                   	push   %ebp
f0100eee:	89 e5                	mov    %esp,%ebp
f0100ef0:	53                   	push   %ebx
f0100ef1:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list) {
f0100ef4:	8b 1d 6c 72 21 f0    	mov    0xf021726c,%ebx
f0100efa:	85 db                	test   %ebx,%ebx
f0100efc:	74 13                	je     f0100f11 <page_alloc+0x24>
		page_free_list = page_free_list->pp_link;
f0100efe:	8b 03                	mov    (%ebx),%eax
f0100f00:	a3 6c 72 21 f0       	mov    %eax,0xf021726c
		result->pp_link = NULL;
f0100f05:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f0100f0b:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f0f:	75 07                	jne    f0100f18 <page_alloc+0x2b>
}
f0100f11:	89 d8                	mov    %ebx,%eax
f0100f13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f16:	c9                   	leave  
f0100f17:	c3                   	ret    
f0100f18:	89 d8                	mov    %ebx,%eax
f0100f1a:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0100f20:	c1 f8 03             	sar    $0x3,%eax
f0100f23:	89 c2                	mov    %eax,%edx
f0100f25:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f28:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f2d:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0100f33:	73 1b                	jae    f0100f50 <page_alloc+0x63>
			memset(page2kva(result), 0, PGSIZE);
f0100f35:	83 ec 04             	sub    $0x4,%esp
f0100f38:	68 00 10 00 00       	push   $0x1000
f0100f3d:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f3f:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f45:	52                   	push   %edx
f0100f46:	e8 00 46 00 00       	call   f010554b <memset>
f0100f4b:	83 c4 10             	add    $0x10,%esp
	return result;
f0100f4e:	eb c1                	jmp    f0100f11 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f50:	52                   	push   %edx
f0100f51:	68 a4 61 10 f0       	push   $0xf01061a4
f0100f56:	6a 58                	push   $0x58
f0100f58:	68 b4 70 10 f0       	push   $0xf01070b4
f0100f5d:	e8 de f0 ff ff       	call   f0100040 <_panic>

f0100f62 <page_free>:
{
f0100f62:	55                   	push   %ebp
f0100f63:	89 e5                	mov    %esp,%ebp
f0100f65:	83 ec 08             	sub    $0x8,%esp
f0100f68:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp);
f0100f6b:	85 c0                	test   %eax,%eax
f0100f6d:	74 1b                	je     f0100f8a <page_free+0x28>
	assert(pp->pp_ref == 0);
f0100f6f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f74:	75 2d                	jne    f0100fa3 <page_free+0x41>
	assert(pp->pp_link == NULL);
f0100f76:	83 38 00             	cmpl   $0x0,(%eax)
f0100f79:	75 41                	jne    f0100fbc <page_free+0x5a>
	pp->pp_link = page_free_list;
f0100f7b:	8b 15 6c 72 21 f0    	mov    0xf021726c,%edx
f0100f81:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f83:	a3 6c 72 21 f0       	mov    %eax,0xf021726c
}
f0100f88:	c9                   	leave  
f0100f89:	c3                   	ret    
	assert(pp);
f0100f8a:	68 9f 72 10 f0       	push   $0xf010729f
f0100f8f:	68 ce 70 10 f0       	push   $0xf01070ce
f0100f94:	68 b7 01 00 00       	push   $0x1b7
f0100f99:	68 8d 70 10 f0       	push   $0xf010708d
f0100f9e:	e8 9d f0 ff ff       	call   f0100040 <_panic>
	assert(pp->pp_ref == 0);
f0100fa3:	68 7b 71 10 f0       	push   $0xf010717b
f0100fa8:	68 ce 70 10 f0       	push   $0xf01070ce
f0100fad:	68 b8 01 00 00       	push   $0x1b8
f0100fb2:	68 8d 70 10 f0       	push   $0xf010708d
f0100fb7:	e8 84 f0 ff ff       	call   f0100040 <_panic>
	assert(pp->pp_link == NULL);
f0100fbc:	68 8b 71 10 f0       	push   $0xf010718b
f0100fc1:	68 ce 70 10 f0       	push   $0xf01070ce
f0100fc6:	68 b9 01 00 00       	push   $0x1b9
f0100fcb:	68 8d 70 10 f0       	push   $0xf010708d
f0100fd0:	e8 6b f0 ff ff       	call   f0100040 <_panic>

f0100fd5 <page_decref>:
{
f0100fd5:	55                   	push   %ebp
f0100fd6:	89 e5                	mov    %esp,%ebp
f0100fd8:	83 ec 08             	sub    $0x8,%esp
f0100fdb:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fde:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fe2:	83 e8 01             	sub    $0x1,%eax
f0100fe5:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fe9:	66 85 c0             	test   %ax,%ax
f0100fec:	74 02                	je     f0100ff0 <page_decref+0x1b>
}
f0100fee:	c9                   	leave  
f0100fef:	c3                   	ret    
		page_free(pp);
f0100ff0:	83 ec 0c             	sub    $0xc,%esp
f0100ff3:	52                   	push   %edx
f0100ff4:	e8 69 ff ff ff       	call   f0100f62 <page_free>
f0100ff9:	83 c4 10             	add    $0x10,%esp
}
f0100ffc:	eb f0                	jmp    f0100fee <page_decref+0x19>

f0100ffe <pgdir_walk>:
{
f0100ffe:	55                   	push   %ebp
f0100fff:	89 e5                	mov    %esp,%ebp
f0101001:	56                   	push   %esi
f0101002:	53                   	push   %ebx
f0101003:	8b 75 0c             	mov    0xc(%ebp),%esi
	pgt = pgdir + PDX(va);
f0101006:	89 f3                	mov    %esi,%ebx
f0101008:	c1 eb 16             	shr    $0x16,%ebx
f010100b:	c1 e3 02             	shl    $0x2,%ebx
f010100e:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pgt & PTE_P)) {
f0101011:	f6 03 01             	testb  $0x1,(%ebx)
f0101014:	75 2d                	jne    f0101043 <pgdir_walk+0x45>
		if (!create) return NULL;
f0101016:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010101a:	74 68                	je     f0101084 <pgdir_walk+0x86>
		pp = page_alloc(ALLOC_ZERO);
f010101c:	83 ec 0c             	sub    $0xc,%esp
f010101f:	6a 01                	push   $0x1
f0101021:	e8 c7 fe ff ff       	call   f0100eed <page_alloc>
		if (pp == NULL) return NULL;
f0101026:	83 c4 10             	add    $0x10,%esp
f0101029:	85 c0                	test   %eax,%eax
f010102b:	74 3b                	je     f0101068 <pgdir_walk+0x6a>
		pp->pp_ref++;
f010102d:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101032:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101038:	c1 f8 03             	sar    $0x3,%eax
f010103b:	c1 e0 0c             	shl    $0xc,%eax
		*pgt = page2pa(pp) | PTE_P | PTE_W | PTE_U;
f010103e:	83 c8 07             	or     $0x7,%eax
f0101041:	89 03                	mov    %eax,(%ebx)
	return (pte_t *)KADDR(PTE_ADDR(*pgt)) + PTX(va);
f0101043:	8b 03                	mov    (%ebx),%eax
f0101045:	89 c2                	mov    %eax,%edx
f0101047:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010104d:	c1 e8 0c             	shr    $0xc,%eax
f0101050:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0101056:	73 17                	jae    f010106f <pgdir_walk+0x71>
f0101058:	c1 ee 0a             	shr    $0xa,%esi
f010105b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101061:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f0101068:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010106b:	5b                   	pop    %ebx
f010106c:	5e                   	pop    %esi
f010106d:	5d                   	pop    %ebp
f010106e:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010106f:	52                   	push   %edx
f0101070:	68 a4 61 10 f0       	push   $0xf01061a4
f0101075:	68 f0 01 00 00       	push   $0x1f0
f010107a:	68 8d 70 10 f0       	push   $0xf010708d
f010107f:	e8 bc ef ff ff       	call   f0100040 <_panic>
		if (!create) return NULL;
f0101084:	b8 00 00 00 00       	mov    $0x0,%eax
f0101089:	eb dd                	jmp    f0101068 <pgdir_walk+0x6a>

f010108b <boot_map_region>:
{
f010108b:	55                   	push   %ebp
f010108c:	89 e5                	mov    %esp,%ebp
f010108e:	57                   	push   %edi
f010108f:	56                   	push   %esi
f0101090:	53                   	push   %ebx
f0101091:	83 ec 1c             	sub    $0x1c,%esp
f0101094:	89 c7                	mov    %eax,%edi
f0101096:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101099:	89 ce                	mov    %ecx,%esi
	for (i = 0; i < size; i += PGSIZE) {
f010109b:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010a0:	eb 29                	jmp    f01010cb <boot_map_region+0x40>
		pte = pgdir_walk(pgdir, (void *)(va + i), true);
f01010a2:	83 ec 04             	sub    $0x4,%esp
f01010a5:	6a 01                	push   $0x1
f01010a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010aa:	01 d8                	add    %ebx,%eax
f01010ac:	50                   	push   %eax
f01010ad:	57                   	push   %edi
f01010ae:	e8 4b ff ff ff       	call   f0100ffe <pgdir_walk>
f01010b3:	89 c2                	mov    %eax,%edx
		*pte = (pa + i) | perm | PTE_P;
f01010b5:	89 d8                	mov    %ebx,%eax
f01010b7:	03 45 08             	add    0x8(%ebp),%eax
f01010ba:	0b 45 0c             	or     0xc(%ebp),%eax
f01010bd:	83 c8 01             	or     $0x1,%eax
f01010c0:	89 02                	mov    %eax,(%edx)
	for (i = 0; i < size; i += PGSIZE) {
f01010c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010c8:	83 c4 10             	add    $0x10,%esp
f01010cb:	39 f3                	cmp    %esi,%ebx
f01010cd:	72 d3                	jb     f01010a2 <boot_map_region+0x17>
}
f01010cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010d2:	5b                   	pop    %ebx
f01010d3:	5e                   	pop    %esi
f01010d4:	5f                   	pop    %edi
f01010d5:	5d                   	pop    %ebp
f01010d6:	c3                   	ret    

f01010d7 <page_lookup>:
{
f01010d7:	55                   	push   %ebp
f01010d8:	89 e5                	mov    %esp,%ebp
f01010da:	53                   	push   %ebx
f01010db:	83 ec 08             	sub    $0x8,%esp
f01010de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte = pgdir_walk(pgdir, va, false);
f01010e1:	6a 00                	push   $0x0
f01010e3:	ff 75 0c             	push   0xc(%ebp)
f01010e6:	ff 75 08             	push   0x8(%ebp)
f01010e9:	e8 10 ff ff ff       	call   f0100ffe <pgdir_walk>
	if (pte_store) *pte_store = pte;
f01010ee:	83 c4 10             	add    $0x10,%esp
f01010f1:	85 db                	test   %ebx,%ebx
f01010f3:	74 02                	je     f01010f7 <page_lookup+0x20>
f01010f5:	89 03                	mov    %eax,(%ebx)
	if (pte && (*pte & PTE_P)) {
f01010f7:	85 c0                	test   %eax,%eax
f01010f9:	74 0c                	je     f0101107 <page_lookup+0x30>
f01010fb:	8b 10                	mov    (%eax),%edx
	return NULL;
f01010fd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte && (*pte & PTE_P)) {
f0101102:	f6 c2 01             	test   $0x1,%dl
f0101105:	75 05                	jne    f010110c <page_lookup+0x35>
}
f0101107:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010110a:	c9                   	leave  
f010110b:	c3                   	ret    
f010110c:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010110f:	39 15 60 72 21 f0    	cmp    %edx,0xf0217260
f0101115:	76 0a                	jbe    f0101121 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101117:	a1 58 72 21 f0       	mov    0xf0217258,%eax
f010111c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return pa2page(PTE_ADDR(*pte));
f010111f:	eb e6                	jmp    f0101107 <page_lookup+0x30>
		panic("pa2page called with invalid pa");
f0101121:	83 ec 04             	sub    $0x4,%esp
f0101124:	68 2c 68 10 f0       	push   $0xf010682c
f0101129:	6a 51                	push   $0x51
f010112b:	68 b4 70 10 f0       	push   $0xf01070b4
f0101130:	e8 0b ef ff ff       	call   f0100040 <_panic>

f0101135 <tlb_invalidate>:
{
f0101135:	55                   	push   %ebp
f0101136:	89 e5                	mov    %esp,%ebp
f0101138:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f010113b:	e8 00 4a 00 00       	call   f0105b40 <cpunum>
f0101140:	6b c0 74             	imul   $0x74,%eax,%eax
f0101143:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f010114a:	74 16                	je     f0101162 <tlb_invalidate+0x2d>
f010114c:	e8 ef 49 00 00       	call   f0105b40 <cpunum>
f0101151:	6b c0 74             	imul   $0x74,%eax,%eax
f0101154:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f010115a:	8b 55 08             	mov    0x8(%ebp),%edx
f010115d:	39 50 60             	cmp    %edx,0x60(%eax)
f0101160:	75 06                	jne    f0101168 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101162:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101165:	0f 01 38             	invlpg (%eax)
}
f0101168:	c9                   	leave  
f0101169:	c3                   	ret    

f010116a <page_remove>:
{
f010116a:	55                   	push   %ebp
f010116b:	89 e5                	mov    %esp,%ebp
f010116d:	56                   	push   %esi
f010116e:	53                   	push   %ebx
f010116f:	83 ec 14             	sub    $0x14,%esp
f0101172:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101175:	8b 75 0c             	mov    0xc(%ebp),%esi
	pp = page_lookup(pgdir, va, &pte);
f0101178:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010117b:	50                   	push   %eax
f010117c:	56                   	push   %esi
f010117d:	53                   	push   %ebx
f010117e:	e8 54 ff ff ff       	call   f01010d7 <page_lookup>
	if (pp == NULL) return;
f0101183:	83 c4 10             	add    $0x10,%esp
f0101186:	85 c0                	test   %eax,%eax
f0101188:	74 1f                	je     f01011a9 <page_remove+0x3f>
	*pte = 0;
f010118a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010118d:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(pp);
f0101193:	83 ec 0c             	sub    $0xc,%esp
f0101196:	50                   	push   %eax
f0101197:	e8 39 fe ff ff       	call   f0100fd5 <page_decref>
	tlb_invalidate(pgdir, va);
f010119c:	83 c4 08             	add    $0x8,%esp
f010119f:	56                   	push   %esi
f01011a0:	53                   	push   %ebx
f01011a1:	e8 8f ff ff ff       	call   f0101135 <tlb_invalidate>
f01011a6:	83 c4 10             	add    $0x10,%esp
}
f01011a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011ac:	5b                   	pop    %ebx
f01011ad:	5e                   	pop    %esi
f01011ae:	5d                   	pop    %ebp
f01011af:	c3                   	ret    

f01011b0 <page_insert>:
{
f01011b0:	55                   	push   %ebp
f01011b1:	89 e5                	mov    %esp,%ebp
f01011b3:	57                   	push   %edi
f01011b4:	56                   	push   %esi
f01011b5:	53                   	push   %ebx
f01011b6:	83 ec 10             	sub    $0x10,%esp
f01011b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011bc:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte = pgdir_walk(pgdir, va, true);
f01011bf:	6a 01                	push   $0x1
f01011c1:	57                   	push   %edi
f01011c2:	ff 75 08             	push   0x8(%ebp)
f01011c5:	e8 34 fe ff ff       	call   f0100ffe <pgdir_walk>
	if (pte == NULL) return -E_NO_MEM;
f01011ca:	83 c4 10             	add    $0x10,%esp
f01011cd:	85 c0                	test   %eax,%eax
f01011cf:	74 3e                	je     f010120f <page_insert+0x5f>
f01011d1:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01011d3:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) page_remove(pgdir, va);
f01011d8:	f6 00 01             	testb  $0x1,(%eax)
f01011db:	75 21                	jne    f01011fe <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;
f01011dd:	2b 1d 58 72 21 f0    	sub    0xf0217258,%ebx
f01011e3:	c1 fb 03             	sar    $0x3,%ebx
f01011e6:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f01011e9:	0b 5d 14             	or     0x14(%ebp),%ebx
f01011ec:	83 cb 01             	or     $0x1,%ebx
f01011ef:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01011f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011f9:	5b                   	pop    %ebx
f01011fa:	5e                   	pop    %esi
f01011fb:	5f                   	pop    %edi
f01011fc:	5d                   	pop    %ebp
f01011fd:	c3                   	ret    
	if (*pte & PTE_P) page_remove(pgdir, va);
f01011fe:	83 ec 08             	sub    $0x8,%esp
f0101201:	57                   	push   %edi
f0101202:	ff 75 08             	push   0x8(%ebp)
f0101205:	e8 60 ff ff ff       	call   f010116a <page_remove>
f010120a:	83 c4 10             	add    $0x10,%esp
f010120d:	eb ce                	jmp    f01011dd <page_insert+0x2d>
	if (pte == NULL) return -E_NO_MEM;
f010120f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101214:	eb e0                	jmp    f01011f6 <page_insert+0x46>

f0101216 <mmio_map_region>:
{
f0101216:	55                   	push   %ebp
f0101217:	89 e5                	mov    %esp,%ebp
f0101219:	53                   	push   %ebx
f010121a:	83 ec 04             	sub    $0x4,%esp
	sz = ROUNDUP(size, PGSIZE);
f010121d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101220:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101226:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + sz > MMIOLIM) {
f010122c:	8b 15 00 43 12 f0    	mov    0xf0124300,%edx
f0101232:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0101235:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010123a:	77 26                	ja     f0101262 <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir, base, sz, pa, PTE_W|PTE_PCD|PTE_PWT);
f010123c:	83 ec 08             	sub    $0x8,%esp
f010123f:	6a 1a                	push   $0x1a
f0101241:	ff 75 08             	push   0x8(%ebp)
f0101244:	89 d9                	mov    %ebx,%ecx
f0101246:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f010124b:	e8 3b fe ff ff       	call   f010108b <boot_map_region>
	result = (void *)base;
f0101250:	a1 00 43 12 f0       	mov    0xf0124300,%eax
	base += sz;
f0101255:	01 c3                	add    %eax,%ebx
f0101257:	89 1d 00 43 12 f0    	mov    %ebx,0xf0124300
}
f010125d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101260:	c9                   	leave  
f0101261:	c3                   	ret    
		panic("mmio_map_region: size overflow MMIOLIM");
f0101262:	83 ec 04             	sub    $0x4,%esp
f0101265:	68 4c 68 10 f0       	push   $0xf010684c
f010126a:	68 93 02 00 00       	push   $0x293
f010126f:	68 8d 70 10 f0       	push   $0xf010708d
f0101274:	e8 c7 ed ff ff       	call   f0100040 <_panic>

f0101279 <mem_init>:
{
f0101279:	55                   	push   %ebp
f010127a:	89 e5                	mov    %esp,%ebp
f010127c:	57                   	push   %edi
f010127d:	56                   	push   %esi
f010127e:	53                   	push   %ebx
f010127f:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101282:	b8 15 00 00 00       	mov    $0x15,%eax
f0101287:	e8 ab f7 ff ff       	call   f0100a37 <nvram_read>
f010128c:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010128e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101293:	e8 9f f7 ff ff       	call   f0100a37 <nvram_read>
f0101298:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010129a:	b8 34 00 00 00       	mov    $0x34,%eax
f010129f:	e8 93 f7 ff ff       	call   f0100a37 <nvram_read>
	if (ext16mem)
f01012a4:	c1 e0 06             	shl    $0x6,%eax
f01012a7:	0f 84 c3 00 00 00    	je     f0101370 <mem_init+0xf7>
		totalmem = 16 * 1024 + ext16mem;
f01012ad:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01012b2:	89 c2                	mov    %eax,%edx
f01012b4:	c1 ea 02             	shr    $0x2,%edx
f01012b7:	89 15 60 72 21 f0    	mov    %edx,0xf0217260
	npages_basemem = basemem / (PGSIZE / 1024);
f01012bd:	89 da                	mov    %ebx,%edx
f01012bf:	c1 ea 02             	shr    $0x2,%edx
f01012c2:	89 15 70 72 21 f0    	mov    %edx,0xf0217270
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012c8:	89 c2                	mov    %eax,%edx
f01012ca:	29 da                	sub    %ebx,%edx
f01012cc:	52                   	push   %edx
f01012cd:	53                   	push   %ebx
f01012ce:	50                   	push   %eax
f01012cf:	68 74 68 10 f0       	push   $0xf0106874
f01012d4:	e8 59 26 00 00       	call   f0103932 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01012d9:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012de:	e8 7d f7 ff ff       	call   f0100a60 <boot_alloc>
f01012e3:	a3 5c 72 21 f0       	mov    %eax,0xf021725c
	memset(kern_pgdir, 0, PGSIZE);
f01012e8:	83 c4 0c             	add    $0xc,%esp
f01012eb:	68 00 10 00 00       	push   $0x1000
f01012f0:	6a 00                	push   $0x0
f01012f2:	50                   	push   %eax
f01012f3:	e8 53 42 00 00       	call   f010554b <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01012f8:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f01012fd:	83 c4 10             	add    $0x10,%esp
f0101300:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101305:	76 79                	jbe    f0101380 <mem_init+0x107>
	return (physaddr_t)kva - KERNBASE;
f0101307:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010130d:	83 ca 05             	or     $0x5,%edx
f0101310:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	n = npages * sizeof(struct PageInfo);
f0101316:	a1 60 72 21 f0       	mov    0xf0217260,%eax
f010131b:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f0101322:	89 d8                	mov    %ebx,%eax
f0101324:	e8 37 f7 ff ff       	call   f0100a60 <boot_alloc>
f0101329:	a3 58 72 21 f0       	mov    %eax,0xf0217258
	memset(pages, 0, n);
f010132e:	83 ec 04             	sub    $0x4,%esp
f0101331:	53                   	push   %ebx
f0101332:	6a 00                	push   $0x0
f0101334:	50                   	push   %eax
f0101335:	e8 11 42 00 00       	call   f010554b <memset>
	envs = (struct Env *) boot_alloc(n);
f010133a:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010133f:	e8 1c f7 ff ff       	call   f0100a60 <boot_alloc>
f0101344:	a3 74 72 21 f0       	mov    %eax,0xf0217274
	page_init();
f0101349:	e8 df fa ff ff       	call   f0100e2d <page_init>
	check_page_free_list(1);
f010134e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101353:	e8 e7 f7 ff ff       	call   f0100b3f <check_page_free_list>
	if (!pages)
f0101358:	83 c4 10             	add    $0x10,%esp
f010135b:	83 3d 58 72 21 f0 00 	cmpl   $0x0,0xf0217258
f0101362:	74 31                	je     f0101395 <mem_init+0x11c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101364:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f0101369:	bb 00 00 00 00       	mov    $0x0,%ebx
f010136e:	eb 41                	jmp    f01013b1 <mem_init+0x138>
		totalmem = 1 * 1024 + extmem;
f0101370:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101376:	85 f6                	test   %esi,%esi
f0101378:	0f 44 c3             	cmove  %ebx,%eax
f010137b:	e9 32 ff ff ff       	jmp    f01012b2 <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101380:	50                   	push   %eax
f0101381:	68 c8 61 10 f0       	push   $0xf01061c8
f0101386:	68 92 00 00 00       	push   $0x92
f010138b:	68 8d 70 10 f0       	push   $0xf010708d
f0101390:	e8 ab ec ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101395:	83 ec 04             	sub    $0x4,%esp
f0101398:	68 9f 71 10 f0       	push   $0xf010719f
f010139d:	68 33 03 00 00       	push   $0x333
f01013a2:	68 8d 70 10 f0       	push   $0xf010708d
f01013a7:	e8 94 ec ff ff       	call   f0100040 <_panic>
		++nfree;
f01013ac:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013af:	8b 00                	mov    (%eax),%eax
f01013b1:	85 c0                	test   %eax,%eax
f01013b3:	75 f7                	jne    f01013ac <mem_init+0x133>
	assert((pp0 = page_alloc(0)));
f01013b5:	83 ec 0c             	sub    $0xc,%esp
f01013b8:	6a 00                	push   $0x0
f01013ba:	e8 2e fb ff ff       	call   f0100eed <page_alloc>
f01013bf:	89 c7                	mov    %eax,%edi
f01013c1:	83 c4 10             	add    $0x10,%esp
f01013c4:	85 c0                	test   %eax,%eax
f01013c6:	0f 84 1f 02 00 00    	je     f01015eb <mem_init+0x372>
	assert((pp1 = page_alloc(0)));
f01013cc:	83 ec 0c             	sub    $0xc,%esp
f01013cf:	6a 00                	push   $0x0
f01013d1:	e8 17 fb ff ff       	call   f0100eed <page_alloc>
f01013d6:	89 c6                	mov    %eax,%esi
f01013d8:	83 c4 10             	add    $0x10,%esp
f01013db:	85 c0                	test   %eax,%eax
f01013dd:	0f 84 21 02 00 00    	je     f0101604 <mem_init+0x38b>
	assert((pp2 = page_alloc(0)));
f01013e3:	83 ec 0c             	sub    $0xc,%esp
f01013e6:	6a 00                	push   $0x0
f01013e8:	e8 00 fb ff ff       	call   f0100eed <page_alloc>
f01013ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013f0:	83 c4 10             	add    $0x10,%esp
f01013f3:	85 c0                	test   %eax,%eax
f01013f5:	0f 84 22 02 00 00    	je     f010161d <mem_init+0x3a4>
	assert(pp1 && pp1 != pp0);
f01013fb:	39 f7                	cmp    %esi,%edi
f01013fd:	0f 84 33 02 00 00    	je     f0101636 <mem_init+0x3bd>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101403:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101406:	39 c7                	cmp    %eax,%edi
f0101408:	0f 84 41 02 00 00    	je     f010164f <mem_init+0x3d6>
f010140e:	39 c6                	cmp    %eax,%esi
f0101410:	0f 84 39 02 00 00    	je     f010164f <mem_init+0x3d6>
	return (pp - pages) << PGSHIFT;
f0101416:	8b 0d 58 72 21 f0    	mov    0xf0217258,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010141c:	8b 15 60 72 21 f0    	mov    0xf0217260,%edx
f0101422:	c1 e2 0c             	shl    $0xc,%edx
f0101425:	89 f8                	mov    %edi,%eax
f0101427:	29 c8                	sub    %ecx,%eax
f0101429:	c1 f8 03             	sar    $0x3,%eax
f010142c:	c1 e0 0c             	shl    $0xc,%eax
f010142f:	39 d0                	cmp    %edx,%eax
f0101431:	0f 83 31 02 00 00    	jae    f0101668 <mem_init+0x3ef>
f0101437:	89 f0                	mov    %esi,%eax
f0101439:	29 c8                	sub    %ecx,%eax
f010143b:	c1 f8 03             	sar    $0x3,%eax
f010143e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101441:	39 c2                	cmp    %eax,%edx
f0101443:	0f 86 38 02 00 00    	jbe    f0101681 <mem_init+0x408>
f0101449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010144c:	29 c8                	sub    %ecx,%eax
f010144e:	c1 f8 03             	sar    $0x3,%eax
f0101451:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101454:	39 c2                	cmp    %eax,%edx
f0101456:	0f 86 3e 02 00 00    	jbe    f010169a <mem_init+0x421>
	fl = page_free_list;
f010145c:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f0101461:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101464:	c7 05 6c 72 21 f0 00 	movl   $0x0,0xf021726c
f010146b:	00 00 00 
	assert(!page_alloc(0));
f010146e:	83 ec 0c             	sub    $0xc,%esp
f0101471:	6a 00                	push   $0x0
f0101473:	e8 75 fa ff ff       	call   f0100eed <page_alloc>
f0101478:	83 c4 10             	add    $0x10,%esp
f010147b:	85 c0                	test   %eax,%eax
f010147d:	0f 85 30 02 00 00    	jne    f01016b3 <mem_init+0x43a>
	page_free(pp0);
f0101483:	83 ec 0c             	sub    $0xc,%esp
f0101486:	57                   	push   %edi
f0101487:	e8 d6 fa ff ff       	call   f0100f62 <page_free>
	page_free(pp1);
f010148c:	89 34 24             	mov    %esi,(%esp)
f010148f:	e8 ce fa ff ff       	call   f0100f62 <page_free>
	page_free(pp2);
f0101494:	83 c4 04             	add    $0x4,%esp
f0101497:	ff 75 d4             	push   -0x2c(%ebp)
f010149a:	e8 c3 fa ff ff       	call   f0100f62 <page_free>
	assert((pp0 = page_alloc(0)));
f010149f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014a6:	e8 42 fa ff ff       	call   f0100eed <page_alloc>
f01014ab:	89 c6                	mov    %eax,%esi
f01014ad:	83 c4 10             	add    $0x10,%esp
f01014b0:	85 c0                	test   %eax,%eax
f01014b2:	0f 84 14 02 00 00    	je     f01016cc <mem_init+0x453>
	assert((pp1 = page_alloc(0)));
f01014b8:	83 ec 0c             	sub    $0xc,%esp
f01014bb:	6a 00                	push   $0x0
f01014bd:	e8 2b fa ff ff       	call   f0100eed <page_alloc>
f01014c2:	89 c7                	mov    %eax,%edi
f01014c4:	83 c4 10             	add    $0x10,%esp
f01014c7:	85 c0                	test   %eax,%eax
f01014c9:	0f 84 16 02 00 00    	je     f01016e5 <mem_init+0x46c>
	assert((pp2 = page_alloc(0)));
f01014cf:	83 ec 0c             	sub    $0xc,%esp
f01014d2:	6a 00                	push   $0x0
f01014d4:	e8 14 fa ff ff       	call   f0100eed <page_alloc>
f01014d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014dc:	83 c4 10             	add    $0x10,%esp
f01014df:	85 c0                	test   %eax,%eax
f01014e1:	0f 84 17 02 00 00    	je     f01016fe <mem_init+0x485>
	assert(pp1 && pp1 != pp0);
f01014e7:	39 fe                	cmp    %edi,%esi
f01014e9:	0f 84 28 02 00 00    	je     f0101717 <mem_init+0x49e>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014f2:	39 c7                	cmp    %eax,%edi
f01014f4:	0f 84 36 02 00 00    	je     f0101730 <mem_init+0x4b7>
f01014fa:	39 c6                	cmp    %eax,%esi
f01014fc:	0f 84 2e 02 00 00    	je     f0101730 <mem_init+0x4b7>
	assert(!page_alloc(0));
f0101502:	83 ec 0c             	sub    $0xc,%esp
f0101505:	6a 00                	push   $0x0
f0101507:	e8 e1 f9 ff ff       	call   f0100eed <page_alloc>
f010150c:	83 c4 10             	add    $0x10,%esp
f010150f:	85 c0                	test   %eax,%eax
f0101511:	0f 85 32 02 00 00    	jne    f0101749 <mem_init+0x4d0>
f0101517:	89 f0                	mov    %esi,%eax
f0101519:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f010151f:	c1 f8 03             	sar    $0x3,%eax
f0101522:	89 c2                	mov    %eax,%edx
f0101524:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101527:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010152c:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0101532:	0f 83 2a 02 00 00    	jae    f0101762 <mem_init+0x4e9>
	memset(page2kva(pp0), 1, PGSIZE);
f0101538:	83 ec 04             	sub    $0x4,%esp
f010153b:	68 00 10 00 00       	push   $0x1000
f0101540:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101542:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101548:	52                   	push   %edx
f0101549:	e8 fd 3f 00 00       	call   f010554b <memset>
	page_free(pp0);
f010154e:	89 34 24             	mov    %esi,(%esp)
f0101551:	e8 0c fa ff ff       	call   f0100f62 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101556:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010155d:	e8 8b f9 ff ff       	call   f0100eed <page_alloc>
f0101562:	83 c4 10             	add    $0x10,%esp
f0101565:	85 c0                	test   %eax,%eax
f0101567:	0f 84 07 02 00 00    	je     f0101774 <mem_init+0x4fb>
	assert(pp && pp0 == pp);
f010156d:	39 c6                	cmp    %eax,%esi
f010156f:	0f 85 18 02 00 00    	jne    f010178d <mem_init+0x514>
	return (pp - pages) << PGSHIFT;
f0101575:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f010157b:	c1 f8 03             	sar    $0x3,%eax
f010157e:	89 c2                	mov    %eax,%edx
f0101580:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101583:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101588:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f010158e:	0f 83 12 02 00 00    	jae    f01017a6 <mem_init+0x52d>
	return (void *)(pa + KERNBASE);
f0101594:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010159a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01015a0:	80 38 00             	cmpb   $0x0,(%eax)
f01015a3:	0f 85 0f 02 00 00    	jne    f01017b8 <mem_init+0x53f>
	for (i = 0; i < PGSIZE; i++)
f01015a9:	83 c0 01             	add    $0x1,%eax
f01015ac:	39 d0                	cmp    %edx,%eax
f01015ae:	75 f0                	jne    f01015a0 <mem_init+0x327>
	page_free_list = fl;
f01015b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015b3:	a3 6c 72 21 f0       	mov    %eax,0xf021726c
	page_free(pp0);
f01015b8:	83 ec 0c             	sub    $0xc,%esp
f01015bb:	56                   	push   %esi
f01015bc:	e8 a1 f9 ff ff       	call   f0100f62 <page_free>
	page_free(pp1);
f01015c1:	89 3c 24             	mov    %edi,(%esp)
f01015c4:	e8 99 f9 ff ff       	call   f0100f62 <page_free>
	page_free(pp2);
f01015c9:	83 c4 04             	add    $0x4,%esp
f01015cc:	ff 75 d4             	push   -0x2c(%ebp)
f01015cf:	e8 8e f9 ff ff       	call   f0100f62 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015d4:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f01015d9:	83 c4 10             	add    $0x10,%esp
f01015dc:	85 c0                	test   %eax,%eax
f01015de:	0f 84 ed 01 00 00    	je     f01017d1 <mem_init+0x558>
		--nfree;
f01015e4:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015e7:	8b 00                	mov    (%eax),%eax
f01015e9:	eb f1                	jmp    f01015dc <mem_init+0x363>
	assert((pp0 = page_alloc(0)));
f01015eb:	68 ba 71 10 f0       	push   $0xf01071ba
f01015f0:	68 ce 70 10 f0       	push   $0xf01070ce
f01015f5:	68 3b 03 00 00       	push   $0x33b
f01015fa:	68 8d 70 10 f0       	push   $0xf010708d
f01015ff:	e8 3c ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101604:	68 d0 71 10 f0       	push   $0xf01071d0
f0101609:	68 ce 70 10 f0       	push   $0xf01070ce
f010160e:	68 3c 03 00 00       	push   $0x33c
f0101613:	68 8d 70 10 f0       	push   $0xf010708d
f0101618:	e8 23 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010161d:	68 e6 71 10 f0       	push   $0xf01071e6
f0101622:	68 ce 70 10 f0       	push   $0xf01070ce
f0101627:	68 3d 03 00 00       	push   $0x33d
f010162c:	68 8d 70 10 f0       	push   $0xf010708d
f0101631:	e8 0a ea ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101636:	68 fc 71 10 f0       	push   $0xf01071fc
f010163b:	68 ce 70 10 f0       	push   $0xf01070ce
f0101640:	68 40 03 00 00       	push   $0x340
f0101645:	68 8d 70 10 f0       	push   $0xf010708d
f010164a:	e8 f1 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010164f:	68 b0 68 10 f0       	push   $0xf01068b0
f0101654:	68 ce 70 10 f0       	push   $0xf01070ce
f0101659:	68 41 03 00 00       	push   $0x341
f010165e:	68 8d 70 10 f0       	push   $0xf010708d
f0101663:	e8 d8 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101668:	68 0e 72 10 f0       	push   $0xf010720e
f010166d:	68 ce 70 10 f0       	push   $0xf01070ce
f0101672:	68 42 03 00 00       	push   $0x342
f0101677:	68 8d 70 10 f0       	push   $0xf010708d
f010167c:	e8 bf e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101681:	68 2b 72 10 f0       	push   $0xf010722b
f0101686:	68 ce 70 10 f0       	push   $0xf01070ce
f010168b:	68 43 03 00 00       	push   $0x343
f0101690:	68 8d 70 10 f0       	push   $0xf010708d
f0101695:	e8 a6 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010169a:	68 48 72 10 f0       	push   $0xf0107248
f010169f:	68 ce 70 10 f0       	push   $0xf01070ce
f01016a4:	68 44 03 00 00       	push   $0x344
f01016a9:	68 8d 70 10 f0       	push   $0xf010708d
f01016ae:	e8 8d e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01016b3:	68 65 72 10 f0       	push   $0xf0107265
f01016b8:	68 ce 70 10 f0       	push   $0xf01070ce
f01016bd:	68 4b 03 00 00       	push   $0x34b
f01016c2:	68 8d 70 10 f0       	push   $0xf010708d
f01016c7:	e8 74 e9 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01016cc:	68 ba 71 10 f0       	push   $0xf01071ba
f01016d1:	68 ce 70 10 f0       	push   $0xf01070ce
f01016d6:	68 52 03 00 00       	push   $0x352
f01016db:	68 8d 70 10 f0       	push   $0xf010708d
f01016e0:	e8 5b e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016e5:	68 d0 71 10 f0       	push   $0xf01071d0
f01016ea:	68 ce 70 10 f0       	push   $0xf01070ce
f01016ef:	68 53 03 00 00       	push   $0x353
f01016f4:	68 8d 70 10 f0       	push   $0xf010708d
f01016f9:	e8 42 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016fe:	68 e6 71 10 f0       	push   $0xf01071e6
f0101703:	68 ce 70 10 f0       	push   $0xf01070ce
f0101708:	68 54 03 00 00       	push   $0x354
f010170d:	68 8d 70 10 f0       	push   $0xf010708d
f0101712:	e8 29 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101717:	68 fc 71 10 f0       	push   $0xf01071fc
f010171c:	68 ce 70 10 f0       	push   $0xf01070ce
f0101721:	68 56 03 00 00       	push   $0x356
f0101726:	68 8d 70 10 f0       	push   $0xf010708d
f010172b:	e8 10 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101730:	68 b0 68 10 f0       	push   $0xf01068b0
f0101735:	68 ce 70 10 f0       	push   $0xf01070ce
f010173a:	68 57 03 00 00       	push   $0x357
f010173f:	68 8d 70 10 f0       	push   $0xf010708d
f0101744:	e8 f7 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101749:	68 65 72 10 f0       	push   $0xf0107265
f010174e:	68 ce 70 10 f0       	push   $0xf01070ce
f0101753:	68 58 03 00 00       	push   $0x358
f0101758:	68 8d 70 10 f0       	push   $0xf010708d
f010175d:	e8 de e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101762:	52                   	push   %edx
f0101763:	68 a4 61 10 f0       	push   $0xf01061a4
f0101768:	6a 58                	push   $0x58
f010176a:	68 b4 70 10 f0       	push   $0xf01070b4
f010176f:	e8 cc e8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101774:	68 74 72 10 f0       	push   $0xf0107274
f0101779:	68 ce 70 10 f0       	push   $0xf01070ce
f010177e:	68 5d 03 00 00       	push   $0x35d
f0101783:	68 8d 70 10 f0       	push   $0xf010708d
f0101788:	e8 b3 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010178d:	68 92 72 10 f0       	push   $0xf0107292
f0101792:	68 ce 70 10 f0       	push   $0xf01070ce
f0101797:	68 5e 03 00 00       	push   $0x35e
f010179c:	68 8d 70 10 f0       	push   $0xf010708d
f01017a1:	e8 9a e8 ff ff       	call   f0100040 <_panic>
f01017a6:	52                   	push   %edx
f01017a7:	68 a4 61 10 f0       	push   $0xf01061a4
f01017ac:	6a 58                	push   $0x58
f01017ae:	68 b4 70 10 f0       	push   $0xf01070b4
f01017b3:	e8 88 e8 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f01017b8:	68 a2 72 10 f0       	push   $0xf01072a2
f01017bd:	68 ce 70 10 f0       	push   $0xf01070ce
f01017c2:	68 61 03 00 00       	push   $0x361
f01017c7:	68 8d 70 10 f0       	push   $0xf010708d
f01017cc:	e8 6f e8 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f01017d1:	85 db                	test   %ebx,%ebx
f01017d3:	0f 85 c7 09 00 00    	jne    f01021a0 <mem_init+0xf27>
	cprintf("check_page_alloc() succeeded!\n");
f01017d9:	83 ec 0c             	sub    $0xc,%esp
f01017dc:	68 d0 68 10 f0       	push   $0xf01068d0
f01017e1:	e8 4c 21 00 00       	call   f0103932 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ed:	e8 fb f6 ff ff       	call   f0100eed <page_alloc>
f01017f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017f5:	83 c4 10             	add    $0x10,%esp
f01017f8:	85 c0                	test   %eax,%eax
f01017fa:	0f 84 b9 09 00 00    	je     f01021b9 <mem_init+0xf40>
	assert((pp1 = page_alloc(0)));
f0101800:	83 ec 0c             	sub    $0xc,%esp
f0101803:	6a 00                	push   $0x0
f0101805:	e8 e3 f6 ff ff       	call   f0100eed <page_alloc>
f010180a:	89 c3                	mov    %eax,%ebx
f010180c:	83 c4 10             	add    $0x10,%esp
f010180f:	85 c0                	test   %eax,%eax
f0101811:	0f 84 bb 09 00 00    	je     f01021d2 <mem_init+0xf59>
	assert((pp2 = page_alloc(0)));
f0101817:	83 ec 0c             	sub    $0xc,%esp
f010181a:	6a 00                	push   $0x0
f010181c:	e8 cc f6 ff ff       	call   f0100eed <page_alloc>
f0101821:	89 c6                	mov    %eax,%esi
f0101823:	83 c4 10             	add    $0x10,%esp
f0101826:	85 c0                	test   %eax,%eax
f0101828:	0f 84 bd 09 00 00    	je     f01021eb <mem_init+0xf72>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010182e:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101831:	0f 84 cd 09 00 00    	je     f0102204 <mem_init+0xf8b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101837:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010183a:	0f 84 dd 09 00 00    	je     f010221d <mem_init+0xfa4>
f0101840:	39 c3                	cmp    %eax,%ebx
f0101842:	0f 84 d5 09 00 00    	je     f010221d <mem_init+0xfa4>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101848:	a1 6c 72 21 f0       	mov    0xf021726c,%eax
f010184d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101850:	c7 05 6c 72 21 f0 00 	movl   $0x0,0xf021726c
f0101857:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010185a:	83 ec 0c             	sub    $0xc,%esp
f010185d:	6a 00                	push   $0x0
f010185f:	e8 89 f6 ff ff       	call   f0100eed <page_alloc>
f0101864:	83 c4 10             	add    $0x10,%esp
f0101867:	85 c0                	test   %eax,%eax
f0101869:	0f 85 c7 09 00 00    	jne    f0102236 <mem_init+0xfbd>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010186f:	83 ec 04             	sub    $0x4,%esp
f0101872:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101875:	50                   	push   %eax
f0101876:	6a 00                	push   $0x0
f0101878:	ff 35 5c 72 21 f0    	push   0xf021725c
f010187e:	e8 54 f8 ff ff       	call   f01010d7 <page_lookup>
f0101883:	83 c4 10             	add    $0x10,%esp
f0101886:	85 c0                	test   %eax,%eax
f0101888:	0f 85 c1 09 00 00    	jne    f010224f <mem_init+0xfd6>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010188e:	6a 02                	push   $0x2
f0101890:	6a 00                	push   $0x0
f0101892:	53                   	push   %ebx
f0101893:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101899:	e8 12 f9 ff ff       	call   f01011b0 <page_insert>
f010189e:	83 c4 10             	add    $0x10,%esp
f01018a1:	85 c0                	test   %eax,%eax
f01018a3:	0f 89 bf 09 00 00    	jns    f0102268 <mem_init+0xfef>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01018a9:	83 ec 0c             	sub    $0xc,%esp
f01018ac:	ff 75 d4             	push   -0x2c(%ebp)
f01018af:	e8 ae f6 ff ff       	call   f0100f62 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01018b4:	6a 02                	push   $0x2
f01018b6:	6a 00                	push   $0x0
f01018b8:	53                   	push   %ebx
f01018b9:	ff 35 5c 72 21 f0    	push   0xf021725c
f01018bf:	e8 ec f8 ff ff       	call   f01011b0 <page_insert>
f01018c4:	83 c4 20             	add    $0x20,%esp
f01018c7:	85 c0                	test   %eax,%eax
f01018c9:	0f 85 b2 09 00 00    	jne    f0102281 <mem_init+0x1008>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018cf:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
	return (pp - pages) << PGSHIFT;
f01018d5:	8b 0d 58 72 21 f0    	mov    0xf0217258,%ecx
f01018db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01018de:	8b 17                	mov    (%edi),%edx
f01018e0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018e9:	29 c8                	sub    %ecx,%eax
f01018eb:	c1 f8 03             	sar    $0x3,%eax
f01018ee:	c1 e0 0c             	shl    $0xc,%eax
f01018f1:	39 c2                	cmp    %eax,%edx
f01018f3:	0f 85 a1 09 00 00    	jne    f010229a <mem_init+0x1021>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01018f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01018fe:	89 f8                	mov    %edi,%eax
f0101900:	e8 d7 f1 ff ff       	call   f0100adc <check_va2pa>
f0101905:	89 c2                	mov    %eax,%edx
f0101907:	89 d8                	mov    %ebx,%eax
f0101909:	2b 45 d0             	sub    -0x30(%ebp),%eax
f010190c:	c1 f8 03             	sar    $0x3,%eax
f010190f:	c1 e0 0c             	shl    $0xc,%eax
f0101912:	39 c2                	cmp    %eax,%edx
f0101914:	0f 85 99 09 00 00    	jne    f01022b3 <mem_init+0x103a>
	assert(pp1->pp_ref == 1);
f010191a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010191f:	0f 85 a7 09 00 00    	jne    f01022cc <mem_init+0x1053>
	assert(pp0->pp_ref == 1);
f0101925:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101928:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010192d:	0f 85 b2 09 00 00    	jne    f01022e5 <mem_init+0x106c>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101933:	6a 02                	push   $0x2
f0101935:	68 00 10 00 00       	push   $0x1000
f010193a:	56                   	push   %esi
f010193b:	57                   	push   %edi
f010193c:	e8 6f f8 ff ff       	call   f01011b0 <page_insert>
f0101941:	83 c4 10             	add    $0x10,%esp
f0101944:	85 c0                	test   %eax,%eax
f0101946:	0f 85 b2 09 00 00    	jne    f01022fe <mem_init+0x1085>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010194c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101951:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0101956:	e8 81 f1 ff ff       	call   f0100adc <check_va2pa>
f010195b:	89 c2                	mov    %eax,%edx
f010195d:	89 f0                	mov    %esi,%eax
f010195f:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101965:	c1 f8 03             	sar    $0x3,%eax
f0101968:	c1 e0 0c             	shl    $0xc,%eax
f010196b:	39 c2                	cmp    %eax,%edx
f010196d:	0f 85 a4 09 00 00    	jne    f0102317 <mem_init+0x109e>
	assert(pp2->pp_ref == 1);
f0101973:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101978:	0f 85 b2 09 00 00    	jne    f0102330 <mem_init+0x10b7>

	// should be no free memory
	assert(!page_alloc(0));
f010197e:	83 ec 0c             	sub    $0xc,%esp
f0101981:	6a 00                	push   $0x0
f0101983:	e8 65 f5 ff ff       	call   f0100eed <page_alloc>
f0101988:	83 c4 10             	add    $0x10,%esp
f010198b:	85 c0                	test   %eax,%eax
f010198d:	0f 85 b6 09 00 00    	jne    f0102349 <mem_init+0x10d0>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101993:	6a 02                	push   $0x2
f0101995:	68 00 10 00 00       	push   $0x1000
f010199a:	56                   	push   %esi
f010199b:	ff 35 5c 72 21 f0    	push   0xf021725c
f01019a1:	e8 0a f8 ff ff       	call   f01011b0 <page_insert>
f01019a6:	83 c4 10             	add    $0x10,%esp
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	0f 85 b1 09 00 00    	jne    f0102362 <mem_init+0x10e9>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019b1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019b6:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f01019bb:	e8 1c f1 ff ff       	call   f0100adc <check_va2pa>
f01019c0:	89 c2                	mov    %eax,%edx
f01019c2:	89 f0                	mov    %esi,%eax
f01019c4:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f01019ca:	c1 f8 03             	sar    $0x3,%eax
f01019cd:	c1 e0 0c             	shl    $0xc,%eax
f01019d0:	39 c2                	cmp    %eax,%edx
f01019d2:	0f 85 a3 09 00 00    	jne    f010237b <mem_init+0x1102>
	assert(pp2->pp_ref == 1);
f01019d8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019dd:	0f 85 b1 09 00 00    	jne    f0102394 <mem_init+0x111b>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019e3:	83 ec 0c             	sub    $0xc,%esp
f01019e6:	6a 00                	push   $0x0
f01019e8:	e8 00 f5 ff ff       	call   f0100eed <page_alloc>
f01019ed:	83 c4 10             	add    $0x10,%esp
f01019f0:	85 c0                	test   %eax,%eax
f01019f2:	0f 85 b5 09 00 00    	jne    f01023ad <mem_init+0x1134>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019f8:	8b 15 5c 72 21 f0    	mov    0xf021725c,%edx
f01019fe:	8b 02                	mov    (%edx),%eax
f0101a00:	89 c7                	mov    %eax,%edi
f0101a02:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101a08:	c1 e8 0c             	shr    $0xc,%eax
f0101a0b:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0101a11:	0f 83 af 09 00 00    	jae    f01023c6 <mem_init+0x114d>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a17:	83 ec 04             	sub    $0x4,%esp
f0101a1a:	6a 00                	push   $0x0
f0101a1c:	68 00 10 00 00       	push   $0x1000
f0101a21:	52                   	push   %edx
f0101a22:	e8 d7 f5 ff ff       	call   f0100ffe <pgdir_walk>
f0101a27:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101a2d:	83 c4 10             	add    $0x10,%esp
f0101a30:	39 f8                	cmp    %edi,%eax
f0101a32:	0f 85 a3 09 00 00    	jne    f01023db <mem_init+0x1162>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a38:	6a 06                	push   $0x6
f0101a3a:	68 00 10 00 00       	push   $0x1000
f0101a3f:	56                   	push   %esi
f0101a40:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101a46:	e8 65 f7 ff ff       	call   f01011b0 <page_insert>
f0101a4b:	83 c4 10             	add    $0x10,%esp
f0101a4e:	85 c0                	test   %eax,%eax
f0101a50:	0f 85 9e 09 00 00    	jne    f01023f4 <mem_init+0x117b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a56:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
f0101a5c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a61:	89 f8                	mov    %edi,%eax
f0101a63:	e8 74 f0 ff ff       	call   f0100adc <check_va2pa>
f0101a68:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101a6a:	89 f0                	mov    %esi,%eax
f0101a6c:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101a72:	c1 f8 03             	sar    $0x3,%eax
f0101a75:	c1 e0 0c             	shl    $0xc,%eax
f0101a78:	39 c2                	cmp    %eax,%edx
f0101a7a:	0f 85 8d 09 00 00    	jne    f010240d <mem_init+0x1194>
	assert(pp2->pp_ref == 1);
f0101a80:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a85:	0f 85 9b 09 00 00    	jne    f0102426 <mem_init+0x11ad>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a8b:	83 ec 04             	sub    $0x4,%esp
f0101a8e:	6a 00                	push   $0x0
f0101a90:	68 00 10 00 00       	push   $0x1000
f0101a95:	57                   	push   %edi
f0101a96:	e8 63 f5 ff ff       	call   f0100ffe <pgdir_walk>
f0101a9b:	83 c4 10             	add    $0x10,%esp
f0101a9e:	f6 00 04             	testb  $0x4,(%eax)
f0101aa1:	0f 84 98 09 00 00    	je     f010243f <mem_init+0x11c6>
	assert(kern_pgdir[0] & PTE_U);
f0101aa7:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0101aac:	f6 00 04             	testb  $0x4,(%eax)
f0101aaf:	0f 84 a3 09 00 00    	je     f0102458 <mem_init+0x11df>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ab5:	6a 02                	push   $0x2
f0101ab7:	68 00 10 00 00       	push   $0x1000
f0101abc:	56                   	push   %esi
f0101abd:	50                   	push   %eax
f0101abe:	e8 ed f6 ff ff       	call   f01011b0 <page_insert>
f0101ac3:	83 c4 10             	add    $0x10,%esp
f0101ac6:	85 c0                	test   %eax,%eax
f0101ac8:	0f 85 a3 09 00 00    	jne    f0102471 <mem_init+0x11f8>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ace:	83 ec 04             	sub    $0x4,%esp
f0101ad1:	6a 00                	push   $0x0
f0101ad3:	68 00 10 00 00       	push   $0x1000
f0101ad8:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101ade:	e8 1b f5 ff ff       	call   f0100ffe <pgdir_walk>
f0101ae3:	83 c4 10             	add    $0x10,%esp
f0101ae6:	f6 00 02             	testb  $0x2,(%eax)
f0101ae9:	0f 84 9b 09 00 00    	je     f010248a <mem_init+0x1211>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101aef:	83 ec 04             	sub    $0x4,%esp
f0101af2:	6a 00                	push   $0x0
f0101af4:	68 00 10 00 00       	push   $0x1000
f0101af9:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101aff:	e8 fa f4 ff ff       	call   f0100ffe <pgdir_walk>
f0101b04:	83 c4 10             	add    $0x10,%esp
f0101b07:	f6 00 04             	testb  $0x4,(%eax)
f0101b0a:	0f 85 93 09 00 00    	jne    f01024a3 <mem_init+0x122a>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b10:	6a 02                	push   $0x2
f0101b12:	68 00 00 40 00       	push   $0x400000
f0101b17:	ff 75 d4             	push   -0x2c(%ebp)
f0101b1a:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101b20:	e8 8b f6 ff ff       	call   f01011b0 <page_insert>
f0101b25:	83 c4 10             	add    $0x10,%esp
f0101b28:	85 c0                	test   %eax,%eax
f0101b2a:	0f 89 8c 09 00 00    	jns    f01024bc <mem_init+0x1243>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b30:	6a 02                	push   $0x2
f0101b32:	68 00 10 00 00       	push   $0x1000
f0101b37:	53                   	push   %ebx
f0101b38:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101b3e:	e8 6d f6 ff ff       	call   f01011b0 <page_insert>
f0101b43:	83 c4 10             	add    $0x10,%esp
f0101b46:	85 c0                	test   %eax,%eax
f0101b48:	0f 85 87 09 00 00    	jne    f01024d5 <mem_init+0x125c>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b4e:	83 ec 04             	sub    $0x4,%esp
f0101b51:	6a 00                	push   $0x0
f0101b53:	68 00 10 00 00       	push   $0x1000
f0101b58:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101b5e:	e8 9b f4 ff ff       	call   f0100ffe <pgdir_walk>
f0101b63:	83 c4 10             	add    $0x10,%esp
f0101b66:	f6 00 04             	testb  $0x4,(%eax)
f0101b69:	0f 85 7f 09 00 00    	jne    f01024ee <mem_init+0x1275>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101b6f:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0101b74:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101b77:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b7c:	e8 5b ef ff ff       	call   f0100adc <check_va2pa>
f0101b81:	89 df                	mov    %ebx,%edi
f0101b83:	2b 3d 58 72 21 f0    	sub    0xf0217258,%edi
f0101b89:	c1 ff 03             	sar    $0x3,%edi
f0101b8c:	c1 e7 0c             	shl    $0xc,%edi
f0101b8f:	39 f8                	cmp    %edi,%eax
f0101b91:	0f 85 70 09 00 00    	jne    f0102507 <mem_init+0x128e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101b97:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b9f:	e8 38 ef ff ff       	call   f0100adc <check_va2pa>
f0101ba4:	39 c7                	cmp    %eax,%edi
f0101ba6:	0f 85 74 09 00 00    	jne    f0102520 <mem_init+0x12a7>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101bac:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101bb1:	0f 85 82 09 00 00    	jne    f0102539 <mem_init+0x12c0>
	assert(pp2->pp_ref == 0);
f0101bb7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101bbc:	0f 85 90 09 00 00    	jne    f0102552 <mem_init+0x12d9>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101bc2:	83 ec 0c             	sub    $0xc,%esp
f0101bc5:	6a 00                	push   $0x0
f0101bc7:	e8 21 f3 ff ff       	call   f0100eed <page_alloc>
f0101bcc:	83 c4 10             	add    $0x10,%esp
f0101bcf:	85 c0                	test   %eax,%eax
f0101bd1:	0f 84 94 09 00 00    	je     f010256b <mem_init+0x12f2>
f0101bd7:	39 c6                	cmp    %eax,%esi
f0101bd9:	0f 85 8c 09 00 00    	jne    f010256b <mem_init+0x12f2>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101bdf:	83 ec 08             	sub    $0x8,%esp
f0101be2:	6a 00                	push   $0x0
f0101be4:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101bea:	e8 7b f5 ff ff       	call   f010116a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101bef:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
f0101bf5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bfa:	89 f8                	mov    %edi,%eax
f0101bfc:	e8 db ee ff ff       	call   f0100adc <check_va2pa>
f0101c01:	83 c4 10             	add    $0x10,%esp
f0101c04:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c07:	0f 85 77 09 00 00    	jne    f0102584 <mem_init+0x130b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c0d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c12:	89 f8                	mov    %edi,%eax
f0101c14:	e8 c3 ee ff ff       	call   f0100adc <check_va2pa>
f0101c19:	89 c2                	mov    %eax,%edx
f0101c1b:	89 d8                	mov    %ebx,%eax
f0101c1d:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101c23:	c1 f8 03             	sar    $0x3,%eax
f0101c26:	c1 e0 0c             	shl    $0xc,%eax
f0101c29:	39 c2                	cmp    %eax,%edx
f0101c2b:	0f 85 6c 09 00 00    	jne    f010259d <mem_init+0x1324>
	assert(pp1->pp_ref == 1);
f0101c31:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c36:	0f 85 7a 09 00 00    	jne    f01025b6 <mem_init+0x133d>
	assert(pp2->pp_ref == 0);
f0101c3c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c41:	0f 85 88 09 00 00    	jne    f01025cf <mem_init+0x1356>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101c47:	6a 00                	push   $0x0
f0101c49:	68 00 10 00 00       	push   $0x1000
f0101c4e:	53                   	push   %ebx
f0101c4f:	57                   	push   %edi
f0101c50:	e8 5b f5 ff ff       	call   f01011b0 <page_insert>
f0101c55:	83 c4 10             	add    $0x10,%esp
f0101c58:	85 c0                	test   %eax,%eax
f0101c5a:	0f 85 88 09 00 00    	jne    f01025e8 <mem_init+0x136f>
	assert(pp1->pp_ref);
f0101c60:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c65:	0f 84 96 09 00 00    	je     f0102601 <mem_init+0x1388>
	assert(pp1->pp_link == NULL);
f0101c6b:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101c6e:	0f 85 a6 09 00 00    	jne    f010261a <mem_init+0x13a1>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101c74:	83 ec 08             	sub    $0x8,%esp
f0101c77:	68 00 10 00 00       	push   $0x1000
f0101c7c:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101c82:	e8 e3 f4 ff ff       	call   f010116a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c87:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
f0101c8d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c92:	89 f8                	mov    %edi,%eax
f0101c94:	e8 43 ee ff ff       	call   f0100adc <check_va2pa>
f0101c99:	83 c4 10             	add    $0x10,%esp
f0101c9c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c9f:	0f 85 8e 09 00 00    	jne    f0102633 <mem_init+0x13ba>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ca5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101caa:	89 f8                	mov    %edi,%eax
f0101cac:	e8 2b ee ff ff       	call   f0100adc <check_va2pa>
f0101cb1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cb4:	0f 85 92 09 00 00    	jne    f010264c <mem_init+0x13d3>
	assert(pp1->pp_ref == 0);
f0101cba:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cbf:	0f 85 a0 09 00 00    	jne    f0102665 <mem_init+0x13ec>
	assert(pp2->pp_ref == 0);
f0101cc5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cca:	0f 85 ae 09 00 00    	jne    f010267e <mem_init+0x1405>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101cd0:	83 ec 0c             	sub    $0xc,%esp
f0101cd3:	6a 00                	push   $0x0
f0101cd5:	e8 13 f2 ff ff       	call   f0100eed <page_alloc>
f0101cda:	83 c4 10             	add    $0x10,%esp
f0101cdd:	39 c3                	cmp    %eax,%ebx
f0101cdf:	0f 85 b2 09 00 00    	jne    f0102697 <mem_init+0x141e>
f0101ce5:	85 c0                	test   %eax,%eax
f0101ce7:	0f 84 aa 09 00 00    	je     f0102697 <mem_init+0x141e>

	// should be no free memory
	assert(!page_alloc(0));
f0101ced:	83 ec 0c             	sub    $0xc,%esp
f0101cf0:	6a 00                	push   $0x0
f0101cf2:	e8 f6 f1 ff ff       	call   f0100eed <page_alloc>
f0101cf7:	83 c4 10             	add    $0x10,%esp
f0101cfa:	85 c0                	test   %eax,%eax
f0101cfc:	0f 85 ae 09 00 00    	jne    f01026b0 <mem_init+0x1437>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d02:	8b 0d 5c 72 21 f0    	mov    0xf021725c,%ecx
f0101d08:	8b 11                	mov    (%ecx),%edx
f0101d0a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d13:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101d19:	c1 f8 03             	sar    $0x3,%eax
f0101d1c:	c1 e0 0c             	shl    $0xc,%eax
f0101d1f:	39 c2                	cmp    %eax,%edx
f0101d21:	0f 85 a2 09 00 00    	jne    f01026c9 <mem_init+0x1450>
	kern_pgdir[0] = 0;
f0101d27:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d2d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d30:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d35:	0f 85 a7 09 00 00    	jne    f01026e2 <mem_init+0x1469>
	pp0->pp_ref = 0;
f0101d3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d3e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101d44:	83 ec 0c             	sub    $0xc,%esp
f0101d47:	50                   	push   %eax
f0101d48:	e8 15 f2 ff ff       	call   f0100f62 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101d4d:	83 c4 0c             	add    $0xc,%esp
f0101d50:	6a 01                	push   $0x1
f0101d52:	68 00 10 40 00       	push   $0x401000
f0101d57:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101d5d:	e8 9c f2 ff ff       	call   f0100ffe <pgdir_walk>
f0101d62:	89 45 d0             	mov    %eax,-0x30(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101d65:	8b 0d 5c 72 21 f0    	mov    0xf021725c,%ecx
f0101d6b:	8b 41 04             	mov    0x4(%ecx),%eax
f0101d6e:	89 c7                	mov    %eax,%edi
f0101d70:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101d76:	8b 15 60 72 21 f0    	mov    0xf0217260,%edx
f0101d7c:	c1 e8 0c             	shr    $0xc,%eax
f0101d7f:	83 c4 10             	add    $0x10,%esp
f0101d82:	39 d0                	cmp    %edx,%eax
f0101d84:	0f 83 71 09 00 00    	jae    f01026fb <mem_init+0x1482>
	assert(ptep == ptep1 + PTX(va));
f0101d8a:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101d90:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101d93:	0f 85 77 09 00 00    	jne    f0102710 <mem_init+0x1497>
	kern_pgdir[PDX(va)] = 0;
f0101d99:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101da0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101da9:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101daf:	c1 f8 03             	sar    $0x3,%eax
f0101db2:	89 c1                	mov    %eax,%ecx
f0101db4:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101db7:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101dbc:	39 c2                	cmp    %eax,%edx
f0101dbe:	0f 86 65 09 00 00    	jbe    f0102729 <mem_init+0x14b0>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101dc4:	83 ec 04             	sub    $0x4,%esp
f0101dc7:	68 00 10 00 00       	push   $0x1000
f0101dcc:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101dd1:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101dd7:	51                   	push   %ecx
f0101dd8:	e8 6e 37 00 00       	call   f010554b <memset>
	page_free(pp0);
f0101ddd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101de0:	89 3c 24             	mov    %edi,(%esp)
f0101de3:	e8 7a f1 ff ff       	call   f0100f62 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101de8:	83 c4 0c             	add    $0xc,%esp
f0101deb:	6a 01                	push   $0x1
f0101ded:	6a 00                	push   $0x0
f0101def:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101df5:	e8 04 f2 ff ff       	call   f0100ffe <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101dfa:	89 f8                	mov    %edi,%eax
f0101dfc:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0101e02:	c1 f8 03             	sar    $0x3,%eax
f0101e05:	89 c2                	mov    %eax,%edx
f0101e07:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e0a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e0f:	83 c4 10             	add    $0x10,%esp
f0101e12:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0101e18:	0f 83 1d 09 00 00    	jae    f010273b <mem_init+0x14c2>
	return (void *)(pa + KERNBASE);
f0101e1e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101e24:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e2a:	f6 00 01             	testb  $0x1,(%eax)
f0101e2d:	0f 85 1a 09 00 00    	jne    f010274d <mem_init+0x14d4>
	for(i=0; i<NPTENTRIES; i++)
f0101e33:	83 c0 04             	add    $0x4,%eax
f0101e36:	39 d0                	cmp    %edx,%eax
f0101e38:	75 f0                	jne    f0101e2a <mem_init+0xbb1>
	kern_pgdir[0] = 0;
f0101e3a:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0101e3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101e45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e48:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101e4e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101e51:	89 0d 6c 72 21 f0    	mov    %ecx,0xf021726c

	// free the pages we took
	page_free(pp0);
f0101e57:	83 ec 0c             	sub    $0xc,%esp
f0101e5a:	50                   	push   %eax
f0101e5b:	e8 02 f1 ff ff       	call   f0100f62 <page_free>
	page_free(pp1);
f0101e60:	89 1c 24             	mov    %ebx,(%esp)
f0101e63:	e8 fa f0 ff ff       	call   f0100f62 <page_free>
	page_free(pp2);
f0101e68:	89 34 24             	mov    %esi,(%esp)
f0101e6b:	e8 f2 f0 ff ff       	call   f0100f62 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101e70:	83 c4 08             	add    $0x8,%esp
f0101e73:	68 01 10 00 00       	push   $0x1001
f0101e78:	6a 00                	push   $0x0
f0101e7a:	e8 97 f3 ff ff       	call   f0101216 <mmio_map_region>
f0101e7f:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101e81:	83 c4 08             	add    $0x8,%esp
f0101e84:	68 00 10 00 00       	push   $0x1000
f0101e89:	6a 00                	push   $0x0
f0101e8b:	e8 86 f3 ff ff       	call   f0101216 <mmio_map_region>
f0101e90:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101e92:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101e98:	83 c4 10             	add    $0x10,%esp
f0101e9b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101ea1:	0f 86 bf 08 00 00    	jbe    f0102766 <mem_init+0x14ed>
f0101ea7:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101eac:	0f 87 b4 08 00 00    	ja     f0102766 <mem_init+0x14ed>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101eb2:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101eb8:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101ebe:	0f 87 bb 08 00 00    	ja     f010277f <mem_init+0x1506>
f0101ec4:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101eca:	0f 86 af 08 00 00    	jbe    f010277f <mem_init+0x1506>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101ed0:	89 da                	mov    %ebx,%edx
f0101ed2:	09 f2                	or     %esi,%edx
f0101ed4:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101eda:	0f 85 b8 08 00 00    	jne    f0102798 <mem_init+0x151f>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101ee0:	39 c6                	cmp    %eax,%esi
f0101ee2:	0f 82 c9 08 00 00    	jb     f01027b1 <mem_init+0x1538>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101ee8:	8b 3d 5c 72 21 f0    	mov    0xf021725c,%edi
f0101eee:	89 da                	mov    %ebx,%edx
f0101ef0:	89 f8                	mov    %edi,%eax
f0101ef2:	e8 e5 eb ff ff       	call   f0100adc <check_va2pa>
f0101ef7:	85 c0                	test   %eax,%eax
f0101ef9:	0f 85 cb 08 00 00    	jne    f01027ca <mem_init+0x1551>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101eff:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f05:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f08:	89 c2                	mov    %eax,%edx
f0101f0a:	89 f8                	mov    %edi,%eax
f0101f0c:	e8 cb eb ff ff       	call   f0100adc <check_va2pa>
f0101f11:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101f16:	0f 85 c7 08 00 00    	jne    f01027e3 <mem_init+0x156a>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101f1c:	89 f2                	mov    %esi,%edx
f0101f1e:	89 f8                	mov    %edi,%eax
f0101f20:	e8 b7 eb ff ff       	call   f0100adc <check_va2pa>
f0101f25:	85 c0                	test   %eax,%eax
f0101f27:	0f 85 cf 08 00 00    	jne    f01027fc <mem_init+0x1583>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101f2d:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101f33:	89 f8                	mov    %edi,%eax
f0101f35:	e8 a2 eb ff ff       	call   f0100adc <check_va2pa>
f0101f3a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f3d:	0f 85 d2 08 00 00    	jne    f0102815 <mem_init+0x159c>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101f43:	83 ec 04             	sub    $0x4,%esp
f0101f46:	6a 00                	push   $0x0
f0101f48:	53                   	push   %ebx
f0101f49:	57                   	push   %edi
f0101f4a:	e8 af f0 ff ff       	call   f0100ffe <pgdir_walk>
f0101f4f:	83 c4 10             	add    $0x10,%esp
f0101f52:	f6 00 1a             	testb  $0x1a,(%eax)
f0101f55:	0f 84 d3 08 00 00    	je     f010282e <mem_init+0x15b5>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0101f5b:	83 ec 04             	sub    $0x4,%esp
f0101f5e:	6a 00                	push   $0x0
f0101f60:	53                   	push   %ebx
f0101f61:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101f67:	e8 92 f0 ff ff       	call   f0100ffe <pgdir_walk>
f0101f6c:	8b 00                	mov    (%eax),%eax
f0101f6e:	83 c4 10             	add    $0x10,%esp
f0101f71:	83 e0 04             	and    $0x4,%eax
f0101f74:	89 c7                	mov    %eax,%edi
f0101f76:	0f 85 cb 08 00 00    	jne    f0102847 <mem_init+0x15ce>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0101f7c:	83 ec 04             	sub    $0x4,%esp
f0101f7f:	6a 00                	push   $0x0
f0101f81:	53                   	push   %ebx
f0101f82:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101f88:	e8 71 f0 ff ff       	call   f0100ffe <pgdir_walk>
f0101f8d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0101f93:	83 c4 0c             	add    $0xc,%esp
f0101f96:	6a 00                	push   $0x0
f0101f98:	ff 75 d4             	push   -0x2c(%ebp)
f0101f9b:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101fa1:	e8 58 f0 ff ff       	call   f0100ffe <pgdir_walk>
f0101fa6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0101fac:	83 c4 0c             	add    $0xc,%esp
f0101faf:	6a 00                	push   $0x0
f0101fb1:	56                   	push   %esi
f0101fb2:	ff 35 5c 72 21 f0    	push   0xf021725c
f0101fb8:	e8 41 f0 ff ff       	call   f0100ffe <pgdir_walk>
f0101fbd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0101fc3:	c7 04 24 95 73 10 f0 	movl   $0xf0107395,(%esp)
f0101fca:	e8 63 19 00 00       	call   f0103932 <cprintf>
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0101fcf:	a1 60 72 21 f0       	mov    0xf0217260,%eax
f0101fd4:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0101fdb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f0101fe1:	a1 58 72 21 f0       	mov    0xf0217258,%eax
	if ((uint32_t)kva < KERNBASE)
f0101fe6:	83 c4 10             	add    $0x10,%esp
f0101fe9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101fee:	0f 86 6c 08 00 00    	jbe    f0102860 <mem_init+0x15e7>
f0101ff4:	83 ec 08             	sub    $0x8,%esp
f0101ff7:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101ff9:	05 00 00 00 10       	add    $0x10000000,%eax
f0101ffe:	50                   	push   %eax
f0101fff:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102004:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f0102009:	e8 7d f0 ff ff       	call   f010108b <boot_map_region>
	page_insert(kern_pgdir, pages, (void *)pages, PTE_W);
f010200e:	a1 58 72 21 f0       	mov    0xf0217258,%eax
f0102013:	6a 02                	push   $0x2
f0102015:	50                   	push   %eax
f0102016:	50                   	push   %eax
f0102017:	ff 35 5c 72 21 f0    	push   0xf021725c
f010201d:	e8 8e f1 ff ff       	call   f01011b0 <page_insert>
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), PTE_U | PTE_P);
f0102022:	a1 74 72 21 f0       	mov    0xf0217274,%eax
	if ((uint32_t)kva < KERNBASE)
f0102027:	83 c4 20             	add    $0x20,%esp
f010202a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010202f:	0f 86 40 08 00 00    	jbe    f0102875 <mem_init+0x15fc>
f0102035:	83 ec 08             	sub    $0x8,%esp
f0102038:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010203a:	05 00 00 00 10       	add    $0x10000000,%eax
f010203f:	50                   	push   %eax
f0102040:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102045:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010204a:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f010204f:	e8 37 f0 ff ff       	call   f010108b <boot_map_region>
	page_insert(kern_pgdir, pa2page(PADDR(envs)), (void *)envs, PTE_W);
f0102054:	8b 15 74 72 21 f0    	mov    0xf0217274,%edx
	if ((uint32_t)kva < KERNBASE)
f010205a:	83 c4 10             	add    $0x10,%esp
f010205d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102063:	0f 86 21 08 00 00    	jbe    f010288a <mem_init+0x1611>
	return (physaddr_t)kva - KERNBASE;
f0102069:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
	if (PGNUM(pa) >= npages)
f010206f:	c1 e8 0c             	shr    $0xc,%eax
f0102072:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0102078:	0f 83 21 08 00 00    	jae    f010289f <mem_init+0x1626>
f010207e:	6a 02                	push   $0x2
f0102080:	52                   	push   %edx
	return &pages[PGNUM(pa)];
f0102081:	8b 15 58 72 21 f0    	mov    0xf0217258,%edx
f0102087:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010208a:	50                   	push   %eax
f010208b:	ff 35 5c 72 21 f0    	push   0xf021725c
f0102091:	e8 1a f1 ff ff       	call   f01011b0 <page_insert>
	if ((uint32_t)kva < KERNBASE)
f0102096:	83 c4 10             	add    $0x10,%esp
f0102099:	b8 00 a0 11 f0       	mov    $0xf011a000,%eax
f010209e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020a3:	0f 86 0a 08 00 00    	jbe    f01028b3 <mem_init+0x163a>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01020a9:	83 ec 08             	sub    $0x8,%esp
f01020ac:	6a 02                	push   $0x2
f01020ae:	68 00 a0 11 00       	push   $0x11a000
f01020b3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020b8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020bd:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f01020c2:	e8 c4 ef ff ff       	call   f010108b <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE + 1, 0, PTE_W);
f01020c7:	83 c4 08             	add    $0x8,%esp
f01020ca:	6a 02                	push   $0x2
f01020cc:	6a 00                	push   $0x0
f01020ce:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01020d3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020d8:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f01020dd:	e8 a9 ef ff ff       	call   f010108b <boot_map_region>
f01020e2:	c7 45 d4 00 80 21 f0 	movl   $0xf0218000,-0x2c(%ebp)
f01020e9:	83 c4 10             	add    $0x10,%esp
f01020ec:	bb 00 80 21 f0       	mov    $0xf0218000,%ebx
f01020f1:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01020f6:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01020fc:	0f 86 c6 07 00 00    	jbe    f01028c8 <mem_init+0x164f>
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102102:	83 ec 08             	sub    $0x8,%esp
f0102105:	6a 02                	push   $0x2
f0102107:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010210d:	50                   	push   %eax
f010210e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102113:	89 f2                	mov    %esi,%edx
f0102115:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f010211a:	e8 6c ef ff ff       	call   f010108b <boot_map_region>
	for (i = 0; i < NCPU; i++) {
f010211f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102125:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f010212b:	83 c4 10             	add    $0x10,%esp
f010212e:	81 fb 00 80 25 f0    	cmp    $0xf0258000,%ebx
f0102134:	75 c0                	jne    f01020f6 <mem_init+0xe7d>
	pgdir = kern_pgdir;
f0102136:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
f010213b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010213e:	a1 60 72 21 f0       	mov    0xf0217260,%eax
f0102143:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102146:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010214d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102152:	8b 35 58 72 21 f0    	mov    0xf0217258,%esi
	return (physaddr_t)kva - KERNBASE;
f0102158:	8d 8e 00 00 00 10    	lea    0x10000000(%esi),%ecx
f010215e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102161:	89 fb                	mov    %edi,%ebx
f0102163:	89 7d c8             	mov    %edi,-0x38(%ebp)
f0102166:	89 c7                	mov    %eax,%edi
f0102168:	39 df                	cmp    %ebx,%edi
f010216a:	0f 86 9b 07 00 00    	jbe    f010290b <mem_init+0x1692>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102170:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102176:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102179:	e8 5e e9 ff ff       	call   f0100adc <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010217e:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102184:	0f 86 53 07 00 00    	jbe    f01028dd <mem_init+0x1664>
f010218a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010218d:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102190:	39 d0                	cmp    %edx,%eax
f0102192:	0f 85 5a 07 00 00    	jne    f01028f2 <mem_init+0x1679>
	for (i = 0; i < n; i += PGSIZE)
f0102198:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010219e:	eb c8                	jmp    f0102168 <mem_init+0xeef>
	assert(nfree == 0);
f01021a0:	68 ac 72 10 f0       	push   $0xf01072ac
f01021a5:	68 ce 70 10 f0       	push   $0xf01070ce
f01021aa:	68 6e 03 00 00       	push   $0x36e
f01021af:	68 8d 70 10 f0       	push   $0xf010708d
f01021b4:	e8 87 de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01021b9:	68 ba 71 10 f0       	push   $0xf01071ba
f01021be:	68 ce 70 10 f0       	push   $0xf01070ce
f01021c3:	68 d4 03 00 00       	push   $0x3d4
f01021c8:	68 8d 70 10 f0       	push   $0xf010708d
f01021cd:	e8 6e de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021d2:	68 d0 71 10 f0       	push   $0xf01071d0
f01021d7:	68 ce 70 10 f0       	push   $0xf01070ce
f01021dc:	68 d5 03 00 00       	push   $0x3d5
f01021e1:	68 8d 70 10 f0       	push   $0xf010708d
f01021e6:	e8 55 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01021eb:	68 e6 71 10 f0       	push   $0xf01071e6
f01021f0:	68 ce 70 10 f0       	push   $0xf01070ce
f01021f5:	68 d6 03 00 00       	push   $0x3d6
f01021fa:	68 8d 70 10 f0       	push   $0xf010708d
f01021ff:	e8 3c de ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0102204:	68 fc 71 10 f0       	push   $0xf01071fc
f0102209:	68 ce 70 10 f0       	push   $0xf01070ce
f010220e:	68 d9 03 00 00       	push   $0x3d9
f0102213:	68 8d 70 10 f0       	push   $0xf010708d
f0102218:	e8 23 de ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010221d:	68 b0 68 10 f0       	push   $0xf01068b0
f0102222:	68 ce 70 10 f0       	push   $0xf01070ce
f0102227:	68 da 03 00 00       	push   $0x3da
f010222c:	68 8d 70 10 f0       	push   $0xf010708d
f0102231:	e8 0a de ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102236:	68 65 72 10 f0       	push   $0xf0107265
f010223b:	68 ce 70 10 f0       	push   $0xf01070ce
f0102240:	68 e1 03 00 00       	push   $0x3e1
f0102245:	68 8d 70 10 f0       	push   $0xf010708d
f010224a:	e8 f1 dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010224f:	68 f0 68 10 f0       	push   $0xf01068f0
f0102254:	68 ce 70 10 f0       	push   $0xf01070ce
f0102259:	68 e4 03 00 00       	push   $0x3e4
f010225e:	68 8d 70 10 f0       	push   $0xf010708d
f0102263:	e8 d8 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102268:	68 28 69 10 f0       	push   $0xf0106928
f010226d:	68 ce 70 10 f0       	push   $0xf01070ce
f0102272:	68 e7 03 00 00       	push   $0x3e7
f0102277:	68 8d 70 10 f0       	push   $0xf010708d
f010227c:	e8 bf dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102281:	68 58 69 10 f0       	push   $0xf0106958
f0102286:	68 ce 70 10 f0       	push   $0xf01070ce
f010228b:	68 eb 03 00 00       	push   $0x3eb
f0102290:	68 8d 70 10 f0       	push   $0xf010708d
f0102295:	e8 a6 dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010229a:	68 88 69 10 f0       	push   $0xf0106988
f010229f:	68 ce 70 10 f0       	push   $0xf01070ce
f01022a4:	68 ec 03 00 00       	push   $0x3ec
f01022a9:	68 8d 70 10 f0       	push   $0xf010708d
f01022ae:	e8 8d dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022b3:	68 b0 69 10 f0       	push   $0xf01069b0
f01022b8:	68 ce 70 10 f0       	push   $0xf01070ce
f01022bd:	68 ed 03 00 00       	push   $0x3ed
f01022c2:	68 8d 70 10 f0       	push   $0xf010708d
f01022c7:	e8 74 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01022cc:	68 b7 72 10 f0       	push   $0xf01072b7
f01022d1:	68 ce 70 10 f0       	push   $0xf01070ce
f01022d6:	68 ee 03 00 00       	push   $0x3ee
f01022db:	68 8d 70 10 f0       	push   $0xf010708d
f01022e0:	e8 5b dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01022e5:	68 c8 72 10 f0       	push   $0xf01072c8
f01022ea:	68 ce 70 10 f0       	push   $0xf01070ce
f01022ef:	68 ef 03 00 00       	push   $0x3ef
f01022f4:	68 8d 70 10 f0       	push   $0xf010708d
f01022f9:	e8 42 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022fe:	68 e0 69 10 f0       	push   $0xf01069e0
f0102303:	68 ce 70 10 f0       	push   $0xf01070ce
f0102308:	68 f2 03 00 00       	push   $0x3f2
f010230d:	68 8d 70 10 f0       	push   $0xf010708d
f0102312:	e8 29 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102317:	68 1c 6a 10 f0       	push   $0xf0106a1c
f010231c:	68 ce 70 10 f0       	push   $0xf01070ce
f0102321:	68 f3 03 00 00       	push   $0x3f3
f0102326:	68 8d 70 10 f0       	push   $0xf010708d
f010232b:	e8 10 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102330:	68 d9 72 10 f0       	push   $0xf01072d9
f0102335:	68 ce 70 10 f0       	push   $0xf01070ce
f010233a:	68 f4 03 00 00       	push   $0x3f4
f010233f:	68 8d 70 10 f0       	push   $0xf010708d
f0102344:	e8 f7 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102349:	68 65 72 10 f0       	push   $0xf0107265
f010234e:	68 ce 70 10 f0       	push   $0xf01070ce
f0102353:	68 f7 03 00 00       	push   $0x3f7
f0102358:	68 8d 70 10 f0       	push   $0xf010708d
f010235d:	e8 de dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102362:	68 e0 69 10 f0       	push   $0xf01069e0
f0102367:	68 ce 70 10 f0       	push   $0xf01070ce
f010236c:	68 fa 03 00 00       	push   $0x3fa
f0102371:	68 8d 70 10 f0       	push   $0xf010708d
f0102376:	e8 c5 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010237b:	68 1c 6a 10 f0       	push   $0xf0106a1c
f0102380:	68 ce 70 10 f0       	push   $0xf01070ce
f0102385:	68 fb 03 00 00       	push   $0x3fb
f010238a:	68 8d 70 10 f0       	push   $0xf010708d
f010238f:	e8 ac dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102394:	68 d9 72 10 f0       	push   $0xf01072d9
f0102399:	68 ce 70 10 f0       	push   $0xf01070ce
f010239e:	68 fc 03 00 00       	push   $0x3fc
f01023a3:	68 8d 70 10 f0       	push   $0xf010708d
f01023a8:	e8 93 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01023ad:	68 65 72 10 f0       	push   $0xf0107265
f01023b2:	68 ce 70 10 f0       	push   $0xf01070ce
f01023b7:	68 00 04 00 00       	push   $0x400
f01023bc:	68 8d 70 10 f0       	push   $0xf010708d
f01023c1:	e8 7a dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023c6:	57                   	push   %edi
f01023c7:	68 a4 61 10 f0       	push   $0xf01061a4
f01023cc:	68 03 04 00 00       	push   $0x403
f01023d1:	68 8d 70 10 f0       	push   $0xf010708d
f01023d6:	e8 65 dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023db:	68 4c 6a 10 f0       	push   $0xf0106a4c
f01023e0:	68 ce 70 10 f0       	push   $0xf01070ce
f01023e5:	68 04 04 00 00       	push   $0x404
f01023ea:	68 8d 70 10 f0       	push   $0xf010708d
f01023ef:	e8 4c dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023f4:	68 8c 6a 10 f0       	push   $0xf0106a8c
f01023f9:	68 ce 70 10 f0       	push   $0xf01070ce
f01023fe:	68 07 04 00 00       	push   $0x407
f0102403:	68 8d 70 10 f0       	push   $0xf010708d
f0102408:	e8 33 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010240d:	68 1c 6a 10 f0       	push   $0xf0106a1c
f0102412:	68 ce 70 10 f0       	push   $0xf01070ce
f0102417:	68 08 04 00 00       	push   $0x408
f010241c:	68 8d 70 10 f0       	push   $0xf010708d
f0102421:	e8 1a dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102426:	68 d9 72 10 f0       	push   $0xf01072d9
f010242b:	68 ce 70 10 f0       	push   $0xf01070ce
f0102430:	68 09 04 00 00       	push   $0x409
f0102435:	68 8d 70 10 f0       	push   $0xf010708d
f010243a:	e8 01 dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010243f:	68 cc 6a 10 f0       	push   $0xf0106acc
f0102444:	68 ce 70 10 f0       	push   $0xf01070ce
f0102449:	68 0a 04 00 00       	push   $0x40a
f010244e:	68 8d 70 10 f0       	push   $0xf010708d
f0102453:	e8 e8 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102458:	68 ea 72 10 f0       	push   $0xf01072ea
f010245d:	68 ce 70 10 f0       	push   $0xf01070ce
f0102462:	68 0b 04 00 00       	push   $0x40b
f0102467:	68 8d 70 10 f0       	push   $0xf010708d
f010246c:	e8 cf db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102471:	68 e0 69 10 f0       	push   $0xf01069e0
f0102476:	68 ce 70 10 f0       	push   $0xf01070ce
f010247b:	68 0e 04 00 00       	push   $0x40e
f0102480:	68 8d 70 10 f0       	push   $0xf010708d
f0102485:	e8 b6 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010248a:	68 00 6b 10 f0       	push   $0xf0106b00
f010248f:	68 ce 70 10 f0       	push   $0xf01070ce
f0102494:	68 0f 04 00 00       	push   $0x40f
f0102499:	68 8d 70 10 f0       	push   $0xf010708d
f010249e:	e8 9d db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024a3:	68 34 6b 10 f0       	push   $0xf0106b34
f01024a8:	68 ce 70 10 f0       	push   $0xf01070ce
f01024ad:	68 10 04 00 00       	push   $0x410
f01024b2:	68 8d 70 10 f0       	push   $0xf010708d
f01024b7:	e8 84 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024bc:	68 6c 6b 10 f0       	push   $0xf0106b6c
f01024c1:	68 ce 70 10 f0       	push   $0xf01070ce
f01024c6:	68 13 04 00 00       	push   $0x413
f01024cb:	68 8d 70 10 f0       	push   $0xf010708d
f01024d0:	e8 6b db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024d5:	68 a4 6b 10 f0       	push   $0xf0106ba4
f01024da:	68 ce 70 10 f0       	push   $0xf01070ce
f01024df:	68 16 04 00 00       	push   $0x416
f01024e4:	68 8d 70 10 f0       	push   $0xf010708d
f01024e9:	e8 52 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024ee:	68 34 6b 10 f0       	push   $0xf0106b34
f01024f3:	68 ce 70 10 f0       	push   $0xf01070ce
f01024f8:	68 17 04 00 00       	push   $0x417
f01024fd:	68 8d 70 10 f0       	push   $0xf010708d
f0102502:	e8 39 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102507:	68 e0 6b 10 f0       	push   $0xf0106be0
f010250c:	68 ce 70 10 f0       	push   $0xf01070ce
f0102511:	68 1a 04 00 00       	push   $0x41a
f0102516:	68 8d 70 10 f0       	push   $0xf010708d
f010251b:	e8 20 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102520:	68 0c 6c 10 f0       	push   $0xf0106c0c
f0102525:	68 ce 70 10 f0       	push   $0xf01070ce
f010252a:	68 1b 04 00 00       	push   $0x41b
f010252f:	68 8d 70 10 f0       	push   $0xf010708d
f0102534:	e8 07 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102539:	68 00 73 10 f0       	push   $0xf0107300
f010253e:	68 ce 70 10 f0       	push   $0xf01070ce
f0102543:	68 1d 04 00 00       	push   $0x41d
f0102548:	68 8d 70 10 f0       	push   $0xf010708d
f010254d:	e8 ee da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102552:	68 11 73 10 f0       	push   $0xf0107311
f0102557:	68 ce 70 10 f0       	push   $0xf01070ce
f010255c:	68 1e 04 00 00       	push   $0x41e
f0102561:	68 8d 70 10 f0       	push   $0xf010708d
f0102566:	e8 d5 da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010256b:	68 3c 6c 10 f0       	push   $0xf0106c3c
f0102570:	68 ce 70 10 f0       	push   $0xf01070ce
f0102575:	68 21 04 00 00       	push   $0x421
f010257a:	68 8d 70 10 f0       	push   $0xf010708d
f010257f:	e8 bc da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102584:	68 60 6c 10 f0       	push   $0xf0106c60
f0102589:	68 ce 70 10 f0       	push   $0xf01070ce
f010258e:	68 25 04 00 00       	push   $0x425
f0102593:	68 8d 70 10 f0       	push   $0xf010708d
f0102598:	e8 a3 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010259d:	68 0c 6c 10 f0       	push   $0xf0106c0c
f01025a2:	68 ce 70 10 f0       	push   $0xf01070ce
f01025a7:	68 26 04 00 00       	push   $0x426
f01025ac:	68 8d 70 10 f0       	push   $0xf010708d
f01025b1:	e8 8a da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025b6:	68 b7 72 10 f0       	push   $0xf01072b7
f01025bb:	68 ce 70 10 f0       	push   $0xf01070ce
f01025c0:	68 27 04 00 00       	push   $0x427
f01025c5:	68 8d 70 10 f0       	push   $0xf010708d
f01025ca:	e8 71 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025cf:	68 11 73 10 f0       	push   $0xf0107311
f01025d4:	68 ce 70 10 f0       	push   $0xf01070ce
f01025d9:	68 28 04 00 00       	push   $0x428
f01025de:	68 8d 70 10 f0       	push   $0xf010708d
f01025e3:	e8 58 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01025e8:	68 84 6c 10 f0       	push   $0xf0106c84
f01025ed:	68 ce 70 10 f0       	push   $0xf01070ce
f01025f2:	68 2b 04 00 00       	push   $0x42b
f01025f7:	68 8d 70 10 f0       	push   $0xf010708d
f01025fc:	e8 3f da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102601:	68 22 73 10 f0       	push   $0xf0107322
f0102606:	68 ce 70 10 f0       	push   $0xf01070ce
f010260b:	68 2c 04 00 00       	push   $0x42c
f0102610:	68 8d 70 10 f0       	push   $0xf010708d
f0102615:	e8 26 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010261a:	68 2e 73 10 f0       	push   $0xf010732e
f010261f:	68 ce 70 10 f0       	push   $0xf01070ce
f0102624:	68 2d 04 00 00       	push   $0x42d
f0102629:	68 8d 70 10 f0       	push   $0xf010708d
f010262e:	e8 0d da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102633:	68 60 6c 10 f0       	push   $0xf0106c60
f0102638:	68 ce 70 10 f0       	push   $0xf01070ce
f010263d:	68 31 04 00 00       	push   $0x431
f0102642:	68 8d 70 10 f0       	push   $0xf010708d
f0102647:	e8 f4 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010264c:	68 bc 6c 10 f0       	push   $0xf0106cbc
f0102651:	68 ce 70 10 f0       	push   $0xf01070ce
f0102656:	68 32 04 00 00       	push   $0x432
f010265b:	68 8d 70 10 f0       	push   $0xf010708d
f0102660:	e8 db d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102665:	68 43 73 10 f0       	push   $0xf0107343
f010266a:	68 ce 70 10 f0       	push   $0xf01070ce
f010266f:	68 33 04 00 00       	push   $0x433
f0102674:	68 8d 70 10 f0       	push   $0xf010708d
f0102679:	e8 c2 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010267e:	68 11 73 10 f0       	push   $0xf0107311
f0102683:	68 ce 70 10 f0       	push   $0xf01070ce
f0102688:	68 34 04 00 00       	push   $0x434
f010268d:	68 8d 70 10 f0       	push   $0xf010708d
f0102692:	e8 a9 d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102697:	68 e4 6c 10 f0       	push   $0xf0106ce4
f010269c:	68 ce 70 10 f0       	push   $0xf01070ce
f01026a1:	68 37 04 00 00       	push   $0x437
f01026a6:	68 8d 70 10 f0       	push   $0xf010708d
f01026ab:	e8 90 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01026b0:	68 65 72 10 f0       	push   $0xf0107265
f01026b5:	68 ce 70 10 f0       	push   $0xf01070ce
f01026ba:	68 3a 04 00 00       	push   $0x43a
f01026bf:	68 8d 70 10 f0       	push   $0xf010708d
f01026c4:	e8 77 d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026c9:	68 88 69 10 f0       	push   $0xf0106988
f01026ce:	68 ce 70 10 f0       	push   $0xf01070ce
f01026d3:	68 3d 04 00 00       	push   $0x43d
f01026d8:	68 8d 70 10 f0       	push   $0xf010708d
f01026dd:	e8 5e d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01026e2:	68 c8 72 10 f0       	push   $0xf01072c8
f01026e7:	68 ce 70 10 f0       	push   $0xf01070ce
f01026ec:	68 3f 04 00 00       	push   $0x43f
f01026f1:	68 8d 70 10 f0       	push   $0xf010708d
f01026f6:	e8 45 d9 ff ff       	call   f0100040 <_panic>
f01026fb:	57                   	push   %edi
f01026fc:	68 a4 61 10 f0       	push   $0xf01061a4
f0102701:	68 46 04 00 00       	push   $0x446
f0102706:	68 8d 70 10 f0       	push   $0xf010708d
f010270b:	e8 30 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102710:	68 54 73 10 f0       	push   $0xf0107354
f0102715:	68 ce 70 10 f0       	push   $0xf01070ce
f010271a:	68 47 04 00 00       	push   $0x447
f010271f:	68 8d 70 10 f0       	push   $0xf010708d
f0102724:	e8 17 d9 ff ff       	call   f0100040 <_panic>
f0102729:	51                   	push   %ecx
f010272a:	68 a4 61 10 f0       	push   $0xf01061a4
f010272f:	6a 58                	push   $0x58
f0102731:	68 b4 70 10 f0       	push   $0xf01070b4
f0102736:	e8 05 d9 ff ff       	call   f0100040 <_panic>
f010273b:	52                   	push   %edx
f010273c:	68 a4 61 10 f0       	push   $0xf01061a4
f0102741:	6a 58                	push   $0x58
f0102743:	68 b4 70 10 f0       	push   $0xf01070b4
f0102748:	e8 f3 d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010274d:	68 6c 73 10 f0       	push   $0xf010736c
f0102752:	68 ce 70 10 f0       	push   $0xf01070ce
f0102757:	68 51 04 00 00       	push   $0x451
f010275c:	68 8d 70 10 f0       	push   $0xf010708d
f0102761:	e8 da d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102766:	68 08 6d 10 f0       	push   $0xf0106d08
f010276b:	68 ce 70 10 f0       	push   $0xf01070ce
f0102770:	68 61 04 00 00       	push   $0x461
f0102775:	68 8d 70 10 f0       	push   $0xf010708d
f010277a:	e8 c1 d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010277f:	68 30 6d 10 f0       	push   $0xf0106d30
f0102784:	68 ce 70 10 f0       	push   $0xf01070ce
f0102789:	68 62 04 00 00       	push   $0x462
f010278e:	68 8d 70 10 f0       	push   $0xf010708d
f0102793:	e8 a8 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102798:	68 58 6d 10 f0       	push   $0xf0106d58
f010279d:	68 ce 70 10 f0       	push   $0xf01070ce
f01027a2:	68 64 04 00 00       	push   $0x464
f01027a7:	68 8d 70 10 f0       	push   $0xf010708d
f01027ac:	e8 8f d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027b1:	68 83 73 10 f0       	push   $0xf0107383
f01027b6:	68 ce 70 10 f0       	push   $0xf01070ce
f01027bb:	68 66 04 00 00       	push   $0x466
f01027c0:	68 8d 70 10 f0       	push   $0xf010708d
f01027c5:	e8 76 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01027ca:	68 80 6d 10 f0       	push   $0xf0106d80
f01027cf:	68 ce 70 10 f0       	push   $0xf01070ce
f01027d4:	68 68 04 00 00       	push   $0x468
f01027d9:	68 8d 70 10 f0       	push   $0xf010708d
f01027de:	e8 5d d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01027e3:	68 a4 6d 10 f0       	push   $0xf0106da4
f01027e8:	68 ce 70 10 f0       	push   $0xf01070ce
f01027ed:	68 69 04 00 00       	push   $0x469
f01027f2:	68 8d 70 10 f0       	push   $0xf010708d
f01027f7:	e8 44 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01027fc:	68 d4 6d 10 f0       	push   $0xf0106dd4
f0102801:	68 ce 70 10 f0       	push   $0xf01070ce
f0102806:	68 6a 04 00 00       	push   $0x46a
f010280b:	68 8d 70 10 f0       	push   $0xf010708d
f0102810:	e8 2b d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102815:	68 f8 6d 10 f0       	push   $0xf0106df8
f010281a:	68 ce 70 10 f0       	push   $0xf01070ce
f010281f:	68 6b 04 00 00       	push   $0x46b
f0102824:	68 8d 70 10 f0       	push   $0xf010708d
f0102829:	e8 12 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010282e:	68 24 6e 10 f0       	push   $0xf0106e24
f0102833:	68 ce 70 10 f0       	push   $0xf01070ce
f0102838:	68 6d 04 00 00       	push   $0x46d
f010283d:	68 8d 70 10 f0       	push   $0xf010708d
f0102842:	e8 f9 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102847:	68 68 6e 10 f0       	push   $0xf0106e68
f010284c:	68 ce 70 10 f0       	push   $0xf01070ce
f0102851:	68 6e 04 00 00       	push   $0x46e
f0102856:	68 8d 70 10 f0       	push   $0xf010708d
f010285b:	e8 e0 d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102860:	50                   	push   %eax
f0102861:	68 c8 61 10 f0       	push   $0xf01061c8
f0102866:	68 bc 00 00 00       	push   $0xbc
f010286b:	68 8d 70 10 f0       	push   $0xf010708d
f0102870:	e8 cb d7 ff ff       	call   f0100040 <_panic>
f0102875:	50                   	push   %eax
f0102876:	68 c8 61 10 f0       	push   $0xf01061c8
f010287b:	68 c7 00 00 00       	push   $0xc7
f0102880:	68 8d 70 10 f0       	push   $0xf010708d
f0102885:	e8 b6 d7 ff ff       	call   f0100040 <_panic>
f010288a:	52                   	push   %edx
f010288b:	68 c8 61 10 f0       	push   $0xf01061c8
f0102890:	68 c8 00 00 00       	push   $0xc8
f0102895:	68 8d 70 10 f0       	push   $0xf010708d
f010289a:	e8 a1 d7 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f010289f:	83 ec 04             	sub    $0x4,%esp
f01028a2:	68 2c 68 10 f0       	push   $0xf010682c
f01028a7:	6a 51                	push   $0x51
f01028a9:	68 b4 70 10 f0       	push   $0xf01070b4
f01028ae:	e8 8d d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028b3:	50                   	push   %eax
f01028b4:	68 c8 61 10 f0       	push   $0xf01061c8
f01028b9:	68 d5 00 00 00       	push   $0xd5
f01028be:	68 8d 70 10 f0       	push   $0xf010708d
f01028c3:	e8 78 d7 ff ff       	call   f0100040 <_panic>
f01028c8:	53                   	push   %ebx
f01028c9:	68 c8 61 10 f0       	push   $0xf01061c8
f01028ce:	68 18 01 00 00       	push   $0x118
f01028d3:	68 8d 70 10 f0       	push   $0xf010708d
f01028d8:	e8 63 d7 ff ff       	call   f0100040 <_panic>
f01028dd:	56                   	push   %esi
f01028de:	68 c8 61 10 f0       	push   $0xf01061c8
f01028e3:	68 86 03 00 00       	push   $0x386
f01028e8:	68 8d 70 10 f0       	push   $0xf010708d
f01028ed:	e8 4e d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028f2:	68 9c 6e 10 f0       	push   $0xf0106e9c
f01028f7:	68 ce 70 10 f0       	push   $0xf01070ce
f01028fc:	68 86 03 00 00       	push   $0x386
f0102901:	68 8d 70 10 f0       	push   $0xf010708d
f0102906:	e8 35 d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010290b:	8b 35 74 72 21 f0    	mov    0xf0217274,%esi
	if ((uint32_t)kva < KERNBASE)
f0102911:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102916:	8d 86 00 00 40 21    	lea    0x21400000(%esi),%eax
f010291c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010291f:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102922:	89 da                	mov    %ebx,%edx
f0102924:	89 f8                	mov    %edi,%eax
f0102926:	e8 b1 e1 ff ff       	call   f0100adc <check_va2pa>
f010292b:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102931:	76 46                	jbe    f0102979 <mem_init+0x1700>
f0102933:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102936:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102939:	39 d0                	cmp    %edx,%eax
f010293b:	75 51                	jne    f010298e <mem_init+0x1715>
	for (i = 0; i < n; i += PGSIZE)
f010293d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102943:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102949:	75 d7                	jne    f0102922 <mem_init+0x16a9>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010294b:	8b 7d c8             	mov    -0x38(%ebp),%edi
f010294e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102951:	c1 e6 0c             	shl    $0xc,%esi
f0102954:	89 fb                	mov    %edi,%ebx
f0102956:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102959:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010295c:	39 f3                	cmp    %esi,%ebx
f010295e:	73 60                	jae    f01029c0 <mem_init+0x1747>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102960:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102966:	89 f8                	mov    %edi,%eax
f0102968:	e8 6f e1 ff ff       	call   f0100adc <check_va2pa>
f010296d:	39 c3                	cmp    %eax,%ebx
f010296f:	75 36                	jne    f01029a7 <mem_init+0x172e>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102971:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102977:	eb e3                	jmp    f010295c <mem_init+0x16e3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102979:	56                   	push   %esi
f010297a:	68 c8 61 10 f0       	push   $0xf01061c8
f010297f:	68 8b 03 00 00       	push   $0x38b
f0102984:	68 8d 70 10 f0       	push   $0xf010708d
f0102989:	e8 b2 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010298e:	68 d0 6e 10 f0       	push   $0xf0106ed0
f0102993:	68 ce 70 10 f0       	push   $0xf01070ce
f0102998:	68 8b 03 00 00       	push   $0x38b
f010299d:	68 8d 70 10 f0       	push   $0xf010708d
f01029a2:	e8 99 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029a7:	68 04 6f 10 f0       	push   $0xf0106f04
f01029ac:	68 ce 70 10 f0       	push   $0xf01070ce
f01029b1:	68 8f 03 00 00       	push   $0x38f
f01029b6:	68 8d 70 10 f0       	push   $0xf010708d
f01029bb:	e8 80 d6 ff ff       	call   f0100040 <_panic>
f01029c0:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01029c3:	c7 45 c0 00 80 22 00 	movl   $0x228000,-0x40(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029ca:	c7 45 c4 00 00 00 f0 	movl   $0xf0000000,-0x3c(%ebp)
f01029d1:	c7 45 c8 00 80 ff ef 	movl   $0xefff8000,-0x38(%ebp)
f01029d8:	89 7d b8             	mov    %edi,-0x48(%ebp)
f01029db:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01029de:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f01029e1:	8d b3 00 80 ff ff    	lea    -0x8000(%ebx),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029ea:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01029ed:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01029f0:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f01029f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029f8:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01029fb:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01029fe:	89 da                	mov    %ebx,%edx
f0102a00:	89 f8                	mov    %edi,%eax
f0102a02:	e8 d5 e0 ff ff       	call   f0100adc <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a07:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102a0e:	76 66                	jbe    f0102a76 <mem_init+0x17fd>
f0102a10:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102a13:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102a16:	39 d0                	cmp    %edx,%eax
f0102a18:	75 73                	jne    f0102a8d <mem_init+0x1814>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a1a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a20:	39 f3                	cmp    %esi,%ebx
f0102a22:	75 da                	jne    f01029fe <mem_init+0x1785>
f0102a24:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102a27:	8b 5d c8             	mov    -0x38(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a2a:	89 f2                	mov    %esi,%edx
f0102a2c:	89 f8                	mov    %edi,%eax
f0102a2e:	e8 a9 e0 ff ff       	call   f0100adc <check_va2pa>
f0102a33:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a36:	75 6e                	jne    f0102aa6 <mem_init+0x182d>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a38:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102a3e:	39 de                	cmp    %ebx,%esi
f0102a40:	75 e8                	jne    f0102a2a <mem_init+0x17b1>
	for (n = 0; n < NCPU; n++) {
f0102a42:	89 d8                	mov    %ebx,%eax
f0102a44:	2d 00 00 01 00       	sub    $0x10000,%eax
f0102a49:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102a4c:	81 6d c4 00 00 01 00 	subl   $0x10000,-0x3c(%ebp)
f0102a53:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
f0102a5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a5d:	81 45 c0 00 80 01 00 	addl   $0x18000,-0x40(%ebp)
f0102a64:	3d 00 80 25 f0       	cmp    $0xf0258000,%eax
f0102a69:	0f 85 6f ff ff ff    	jne    f01029de <mem_init+0x1765>
f0102a6f:	89 fa                	mov    %edi,%edx
f0102a71:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0102a74:	eb 7e                	jmp    f0102af4 <mem_init+0x187b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a76:	ff 75 bc             	push   -0x44(%ebp)
f0102a79:	68 c8 61 10 f0       	push   $0xf01061c8
f0102a7e:	68 97 03 00 00       	push   $0x397
f0102a83:	68 8d 70 10 f0       	push   $0xf010708d
f0102a88:	e8 b3 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a8d:	68 2c 6f 10 f0       	push   $0xf0106f2c
f0102a92:	68 ce 70 10 f0       	push   $0xf01070ce
f0102a97:	68 96 03 00 00       	push   $0x396
f0102a9c:	68 8d 70 10 f0       	push   $0xf010708d
f0102aa1:	e8 9a d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102aa6:	68 74 6f 10 f0       	push   $0xf0106f74
f0102aab:	68 ce 70 10 f0       	push   $0xf01070ce
f0102ab0:	68 99 03 00 00       	push   $0x399
f0102ab5:	68 8d 70 10 f0       	push   $0xf010708d
f0102aba:	e8 81 d5 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102abf:	f6 04 ba 01          	testb  $0x1,(%edx,%edi,4)
f0102ac3:	75 48                	jne    f0102b0d <mem_init+0x1894>
f0102ac5:	68 ae 73 10 f0       	push   $0xf01073ae
f0102aca:	68 ce 70 10 f0       	push   $0xf01070ce
f0102acf:	68 a4 03 00 00       	push   $0x3a4
f0102ad4:	68 8d 70 10 f0       	push   $0xf010708d
f0102ad9:	e8 62 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102ade:	8b 04 ba             	mov    (%edx,%edi,4),%eax
f0102ae1:	a8 01                	test   $0x1,%al
f0102ae3:	74 2d                	je     f0102b12 <mem_init+0x1899>
				assert(pgdir[i] & PTE_W);
f0102ae5:	a8 02                	test   $0x2,%al
f0102ae7:	74 42                	je     f0102b2b <mem_init+0x18b2>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ae9:	83 c7 01             	add    $0x1,%edi
f0102aec:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102af2:	74 69                	je     f0102b5d <mem_init+0x18e4>
		switch (i) {
f0102af4:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102afa:	83 f8 04             	cmp    $0x4,%eax
f0102afd:	76 c0                	jbe    f0102abf <mem_init+0x1846>
			if (i >= PDX(KERNBASE)) {
f0102aff:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102b05:	77 d7                	ja     f0102ade <mem_init+0x1865>
				assert(pgdir[i] == 0);
f0102b07:	83 3c ba 00          	cmpl   $0x0,(%edx,%edi,4)
f0102b0b:	75 37                	jne    f0102b44 <mem_init+0x18cb>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b0d:	83 c7 01             	add    $0x1,%edi
f0102b10:	eb e2                	jmp    f0102af4 <mem_init+0x187b>
				assert(pgdir[i] & PTE_P);
f0102b12:	68 ae 73 10 f0       	push   $0xf01073ae
f0102b17:	68 ce 70 10 f0       	push   $0xf01070ce
f0102b1c:	68 a8 03 00 00       	push   $0x3a8
f0102b21:	68 8d 70 10 f0       	push   $0xf010708d
f0102b26:	e8 15 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102b2b:	68 bf 73 10 f0       	push   $0xf01073bf
f0102b30:	68 ce 70 10 f0       	push   $0xf01070ce
f0102b35:	68 a9 03 00 00       	push   $0x3a9
f0102b3a:	68 8d 70 10 f0       	push   $0xf010708d
f0102b3f:	e8 fc d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b44:	68 d0 73 10 f0       	push   $0xf01073d0
f0102b49:	68 ce 70 10 f0       	push   $0xf01070ce
f0102b4e:	68 ab 03 00 00       	push   $0x3ab
f0102b53:	68 8d 70 10 f0       	push   $0xf010708d
f0102b58:	e8 e3 d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b5d:	83 ec 0c             	sub    $0xc,%esp
f0102b60:	68 98 6f 10 f0       	push   $0xf0106f98
f0102b65:	e8 c8 0d 00 00       	call   f0103932 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b6a:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b6f:	83 c4 10             	add    $0x10,%esp
f0102b72:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b77:	0f 86 03 02 00 00    	jbe    f0102d80 <mem_init+0x1b07>
	return (physaddr_t)kva - KERNBASE;
f0102b7d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b82:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b85:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b8a:	e8 b0 df ff ff       	call   f0100b3f <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b8f:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b92:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b95:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b9a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b9d:	83 ec 0c             	sub    $0xc,%esp
f0102ba0:	6a 00                	push   $0x0
f0102ba2:	e8 46 e3 ff ff       	call   f0100eed <page_alloc>
f0102ba7:	89 c3                	mov    %eax,%ebx
f0102ba9:	83 c4 10             	add    $0x10,%esp
f0102bac:	85 c0                	test   %eax,%eax
f0102bae:	0f 84 e1 01 00 00    	je     f0102d95 <mem_init+0x1b1c>
	assert((pp1 = page_alloc(0)));
f0102bb4:	83 ec 0c             	sub    $0xc,%esp
f0102bb7:	6a 00                	push   $0x0
f0102bb9:	e8 2f e3 ff ff       	call   f0100eed <page_alloc>
f0102bbe:	89 c7                	mov    %eax,%edi
f0102bc0:	83 c4 10             	add    $0x10,%esp
f0102bc3:	85 c0                	test   %eax,%eax
f0102bc5:	0f 84 e3 01 00 00    	je     f0102dae <mem_init+0x1b35>
	assert((pp2 = page_alloc(0)));
f0102bcb:	83 ec 0c             	sub    $0xc,%esp
f0102bce:	6a 00                	push   $0x0
f0102bd0:	e8 18 e3 ff ff       	call   f0100eed <page_alloc>
f0102bd5:	89 c6                	mov    %eax,%esi
f0102bd7:	83 c4 10             	add    $0x10,%esp
f0102bda:	85 c0                	test   %eax,%eax
f0102bdc:	0f 84 e5 01 00 00    	je     f0102dc7 <mem_init+0x1b4e>
	page_free(pp0);
f0102be2:	83 ec 0c             	sub    $0xc,%esp
f0102be5:	53                   	push   %ebx
f0102be6:	e8 77 e3 ff ff       	call   f0100f62 <page_free>
	return (pp - pages) << PGSHIFT;
f0102beb:	89 f8                	mov    %edi,%eax
f0102bed:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0102bf3:	c1 f8 03             	sar    $0x3,%eax
f0102bf6:	89 c2                	mov    %eax,%edx
f0102bf8:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102bfb:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c00:	83 c4 10             	add    $0x10,%esp
f0102c03:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0102c09:	0f 83 d1 01 00 00    	jae    f0102de0 <mem_init+0x1b67>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c0f:	83 ec 04             	sub    $0x4,%esp
f0102c12:	68 00 10 00 00       	push   $0x1000
f0102c17:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c19:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c1f:	52                   	push   %edx
f0102c20:	e8 26 29 00 00       	call   f010554b <memset>
	return (pp - pages) << PGSHIFT;
f0102c25:	89 f0                	mov    %esi,%eax
f0102c27:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0102c2d:	c1 f8 03             	sar    $0x3,%eax
f0102c30:	89 c2                	mov    %eax,%edx
f0102c32:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c35:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c3a:	83 c4 10             	add    $0x10,%esp
f0102c3d:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0102c43:	0f 83 a9 01 00 00    	jae    f0102df2 <mem_init+0x1b79>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c49:	83 ec 04             	sub    $0x4,%esp
f0102c4c:	68 00 10 00 00       	push   $0x1000
f0102c51:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c53:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c59:	52                   	push   %edx
f0102c5a:	e8 ec 28 00 00       	call   f010554b <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c5f:	6a 02                	push   $0x2
f0102c61:	68 00 10 00 00       	push   $0x1000
f0102c66:	57                   	push   %edi
f0102c67:	ff 35 5c 72 21 f0    	push   0xf021725c
f0102c6d:	e8 3e e5 ff ff       	call   f01011b0 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c72:	83 c4 20             	add    $0x20,%esp
f0102c75:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c7a:	0f 85 84 01 00 00    	jne    f0102e04 <mem_init+0x1b8b>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c80:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c87:	01 01 01 
f0102c8a:	0f 85 8d 01 00 00    	jne    f0102e1d <mem_init+0x1ba4>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c90:	6a 02                	push   $0x2
f0102c92:	68 00 10 00 00       	push   $0x1000
f0102c97:	56                   	push   %esi
f0102c98:	ff 35 5c 72 21 f0    	push   0xf021725c
f0102c9e:	e8 0d e5 ff ff       	call   f01011b0 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ca3:	83 c4 10             	add    $0x10,%esp
f0102ca6:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cad:	02 02 02 
f0102cb0:	0f 85 80 01 00 00    	jne    f0102e36 <mem_init+0x1bbd>
	assert(pp2->pp_ref == 1);
f0102cb6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cbb:	0f 85 8e 01 00 00    	jne    f0102e4f <mem_init+0x1bd6>
	assert(pp1->pp_ref == 0);
f0102cc1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cc6:	0f 85 9c 01 00 00    	jne    f0102e68 <mem_init+0x1bef>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102ccc:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cd3:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102cd6:	89 f0                	mov    %esi,%eax
f0102cd8:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0102cde:	c1 f8 03             	sar    $0x3,%eax
f0102ce1:	89 c2                	mov    %eax,%edx
f0102ce3:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102ce6:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102ceb:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0102cf1:	0f 83 8a 01 00 00    	jae    f0102e81 <mem_init+0x1c08>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cf7:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102cfe:	03 03 03 
f0102d01:	0f 85 8c 01 00 00    	jne    f0102e93 <mem_init+0x1c1a>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d07:	83 ec 08             	sub    $0x8,%esp
f0102d0a:	68 00 10 00 00       	push   $0x1000
f0102d0f:	ff 35 5c 72 21 f0    	push   0xf021725c
f0102d15:	e8 50 e4 ff ff       	call   f010116a <page_remove>
	assert(pp2->pp_ref == 0);
f0102d1a:	83 c4 10             	add    $0x10,%esp
f0102d1d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d22:	0f 85 84 01 00 00    	jne    f0102eac <mem_init+0x1c33>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d28:	8b 0d 5c 72 21 f0    	mov    0xf021725c,%ecx
f0102d2e:	8b 11                	mov    (%ecx),%edx
f0102d30:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d36:	89 d8                	mov    %ebx,%eax
f0102d38:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f0102d3e:	c1 f8 03             	sar    $0x3,%eax
f0102d41:	c1 e0 0c             	shl    $0xc,%eax
f0102d44:	39 c2                	cmp    %eax,%edx
f0102d46:	0f 85 79 01 00 00    	jne    f0102ec5 <mem_init+0x1c4c>
	kern_pgdir[0] = 0;
f0102d4c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d52:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d57:	0f 85 81 01 00 00    	jne    f0102ede <mem_init+0x1c65>
	pp0->pp_ref = 0;
f0102d5d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d63:	83 ec 0c             	sub    $0xc,%esp
f0102d66:	53                   	push   %ebx
f0102d67:	e8 f6 e1 ff ff       	call   f0100f62 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d6c:	c7 04 24 2c 70 10 f0 	movl   $0xf010702c,(%esp)
f0102d73:	e8 ba 0b 00 00       	call   f0103932 <cprintf>
}
f0102d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d7b:	5b                   	pop    %ebx
f0102d7c:	5e                   	pop    %esi
f0102d7d:	5f                   	pop    %edi
f0102d7e:	5d                   	pop    %ebp
f0102d7f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d80:	50                   	push   %eax
f0102d81:	68 c8 61 10 f0       	push   $0xf01061c8
f0102d86:	68 ee 00 00 00       	push   $0xee
f0102d8b:	68 8d 70 10 f0       	push   $0xf010708d
f0102d90:	e8 ab d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d95:	68 ba 71 10 f0       	push   $0xf01071ba
f0102d9a:	68 ce 70 10 f0       	push   $0xf01070ce
f0102d9f:	68 83 04 00 00       	push   $0x483
f0102da4:	68 8d 70 10 f0       	push   $0xf010708d
f0102da9:	e8 92 d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102dae:	68 d0 71 10 f0       	push   $0xf01071d0
f0102db3:	68 ce 70 10 f0       	push   $0xf01070ce
f0102db8:	68 84 04 00 00       	push   $0x484
f0102dbd:	68 8d 70 10 f0       	push   $0xf010708d
f0102dc2:	e8 79 d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102dc7:	68 e6 71 10 f0       	push   $0xf01071e6
f0102dcc:	68 ce 70 10 f0       	push   $0xf01070ce
f0102dd1:	68 85 04 00 00       	push   $0x485
f0102dd6:	68 8d 70 10 f0       	push   $0xf010708d
f0102ddb:	e8 60 d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102de0:	52                   	push   %edx
f0102de1:	68 a4 61 10 f0       	push   $0xf01061a4
f0102de6:	6a 58                	push   $0x58
f0102de8:	68 b4 70 10 f0       	push   $0xf01070b4
f0102ded:	e8 4e d2 ff ff       	call   f0100040 <_panic>
f0102df2:	52                   	push   %edx
f0102df3:	68 a4 61 10 f0       	push   $0xf01061a4
f0102df8:	6a 58                	push   $0x58
f0102dfa:	68 b4 70 10 f0       	push   $0xf01070b4
f0102dff:	e8 3c d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102e04:	68 b7 72 10 f0       	push   $0xf01072b7
f0102e09:	68 ce 70 10 f0       	push   $0xf01070ce
f0102e0e:	68 8a 04 00 00       	push   $0x48a
f0102e13:	68 8d 70 10 f0       	push   $0xf010708d
f0102e18:	e8 23 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e1d:	68 b8 6f 10 f0       	push   $0xf0106fb8
f0102e22:	68 ce 70 10 f0       	push   $0xf01070ce
f0102e27:	68 8b 04 00 00       	push   $0x48b
f0102e2c:	68 8d 70 10 f0       	push   $0xf010708d
f0102e31:	e8 0a d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e36:	68 dc 6f 10 f0       	push   $0xf0106fdc
f0102e3b:	68 ce 70 10 f0       	push   $0xf01070ce
f0102e40:	68 8d 04 00 00       	push   $0x48d
f0102e45:	68 8d 70 10 f0       	push   $0xf010708d
f0102e4a:	e8 f1 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e4f:	68 d9 72 10 f0       	push   $0xf01072d9
f0102e54:	68 ce 70 10 f0       	push   $0xf01070ce
f0102e59:	68 8e 04 00 00       	push   $0x48e
f0102e5e:	68 8d 70 10 f0       	push   $0xf010708d
f0102e63:	e8 d8 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e68:	68 43 73 10 f0       	push   $0xf0107343
f0102e6d:	68 ce 70 10 f0       	push   $0xf01070ce
f0102e72:	68 8f 04 00 00       	push   $0x48f
f0102e77:	68 8d 70 10 f0       	push   $0xf010708d
f0102e7c:	e8 bf d1 ff ff       	call   f0100040 <_panic>
f0102e81:	52                   	push   %edx
f0102e82:	68 a4 61 10 f0       	push   $0xf01061a4
f0102e87:	6a 58                	push   $0x58
f0102e89:	68 b4 70 10 f0       	push   $0xf01070b4
f0102e8e:	e8 ad d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e93:	68 00 70 10 f0       	push   $0xf0107000
f0102e98:	68 ce 70 10 f0       	push   $0xf01070ce
f0102e9d:	68 91 04 00 00       	push   $0x491
f0102ea2:	68 8d 70 10 f0       	push   $0xf010708d
f0102ea7:	e8 94 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102eac:	68 11 73 10 f0       	push   $0xf0107311
f0102eb1:	68 ce 70 10 f0       	push   $0xf01070ce
f0102eb6:	68 93 04 00 00       	push   $0x493
f0102ebb:	68 8d 70 10 f0       	push   $0xf010708d
f0102ec0:	e8 7b d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ec5:	68 88 69 10 f0       	push   $0xf0106988
f0102eca:	68 ce 70 10 f0       	push   $0xf01070ce
f0102ecf:	68 96 04 00 00       	push   $0x496
f0102ed4:	68 8d 70 10 f0       	push   $0xf010708d
f0102ed9:	e8 62 d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102ede:	68 c8 72 10 f0       	push   $0xf01072c8
f0102ee3:	68 ce 70 10 f0       	push   $0xf01070ce
f0102ee8:	68 98 04 00 00       	push   $0x498
f0102eed:	68 8d 70 10 f0       	push   $0xf010708d
f0102ef2:	e8 49 d1 ff ff       	call   f0100040 <_panic>

f0102ef7 <user_mem_check>:
{
f0102ef7:	55                   	push   %ebp
f0102ef8:	89 e5                	mov    %esp,%ebp
f0102efa:	57                   	push   %edi
f0102efb:	56                   	push   %esi
f0102efc:	53                   	push   %ebx
f0102efd:	83 ec 2c             	sub    $0x2c,%esp
	sa = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f0102f00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f03:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	ea = (uintptr_t)ROUNDUP((uintptr_t)va + len, PGSIZE);
f0102f09:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f0f:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0102f16:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	perm |= PTE_P;
f0102f1e:	8b 75 14             	mov    0x14(%ebp),%esi
f0102f21:	83 ce 01             	or     $0x1,%esi
		pp = page_lookup(env->env_pgdir, (void *)sa, &pte);
f0102f24:	8d 7d e4             	lea    -0x1c(%ebp),%edi
	for (; sa < ea; sa += PGSIZE) {
f0102f27:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102f2a:	73 59                	jae    f0102f85 <user_mem_check+0x8e>
		pp = page_lookup(env->env_pgdir, (void *)sa, &pte);
f0102f2c:	83 ec 04             	sub    $0x4,%esp
f0102f2f:	57                   	push   %edi
f0102f30:	53                   	push   %ebx
f0102f31:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f34:	ff 70 60             	push   0x60(%eax)
f0102f37:	e8 9b e1 ff ff       	call   f01010d7 <page_lookup>
		if (sa < ULIM && pp && (*pte & perm) == perm) 
f0102f3c:	83 c4 10             	add    $0x10,%esp
f0102f3f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f45:	77 0f                	ja     f0102f56 <user_mem_check+0x5f>
f0102f47:	85 c0                	test   %eax,%eax
f0102f49:	74 0b                	je     f0102f56 <user_mem_check+0x5f>
f0102f4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f4e:	89 f2                	mov    %esi,%edx
f0102f50:	23 10                	and    (%eax),%edx
f0102f52:	39 d6                	cmp    %edx,%esi
f0102f54:	74 1a                	je     f0102f70 <user_mem_check+0x79>
		if (sa <= (uintptr_t)va) {
f0102f56:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102f59:	77 1d                	ja     f0102f78 <user_mem_check+0x81>
			user_mem_check_addr = (uintptr_t)va;
f0102f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f5e:	a3 68 72 21 f0       	mov    %eax,0xf0217268
		return -E_FAULT;
f0102f63:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f6b:	5b                   	pop    %ebx
f0102f6c:	5e                   	pop    %esi
f0102f6d:	5f                   	pop    %edi
f0102f6e:	5d                   	pop    %ebp
f0102f6f:	c3                   	ret    
	for (; sa < ea; sa += PGSIZE) {
f0102f70:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f76:	eb af                	jmp    f0102f27 <user_mem_check+0x30>
			user_mem_check_addr = sa;
f0102f78:	89 1d 68 72 21 f0    	mov    %ebx,0xf0217268
		return -E_FAULT;
f0102f7e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f83:	eb e3                	jmp    f0102f68 <user_mem_check+0x71>
	return 0;
f0102f85:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f8a:	eb dc                	jmp    f0102f68 <user_mem_check+0x71>

f0102f8c <user_mem_assert>:
{
f0102f8c:	55                   	push   %ebp
f0102f8d:	89 e5                	mov    %esp,%ebp
f0102f8f:	53                   	push   %ebx
f0102f90:	83 ec 04             	sub    $0x4,%esp
f0102f93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U | PTE_P) < 0) {
f0102f96:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f99:	83 c8 05             	or     $0x5,%eax
f0102f9c:	50                   	push   %eax
f0102f9d:	ff 75 10             	push   0x10(%ebp)
f0102fa0:	ff 75 0c             	push   0xc(%ebp)
f0102fa3:	53                   	push   %ebx
f0102fa4:	e8 4e ff ff ff       	call   f0102ef7 <user_mem_check>
f0102fa9:	83 c4 10             	add    $0x10,%esp
f0102fac:	85 c0                	test   %eax,%eax
f0102fae:	78 05                	js     f0102fb5 <user_mem_assert+0x29>
}
f0102fb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fb3:	c9                   	leave  
f0102fb4:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fb5:	83 ec 04             	sub    $0x4,%esp
f0102fb8:	ff 35 68 72 21 f0    	push   0xf0217268
f0102fbe:	ff 73 48             	push   0x48(%ebx)
f0102fc1:	68 58 70 10 f0       	push   $0xf0107058
f0102fc6:	e8 67 09 00 00       	call   f0103932 <cprintf>
		env_destroy(env);	// may not return
f0102fcb:	89 1c 24             	mov    %ebx,(%esp)
f0102fce:	e8 59 06 00 00       	call   f010362c <env_destroy>
f0102fd3:	83 c4 10             	add    $0x10,%esp
}
f0102fd6:	eb d8                	jmp    f0102fb0 <user_mem_assert+0x24>

f0102fd8 <region_alloc>:
	//   (Watch out for corner-cases!)
	uintptr_t sa, ea;
	int r;
	struct PageInfo* p;

	if (len > 0) {
f0102fd8:	85 c9                	test   %ecx,%ecx
f0102fda:	0f 84 83 00 00 00    	je     f0103063 <region_alloc+0x8b>
{
f0102fe0:	55                   	push   %ebp
f0102fe1:	89 e5                	mov    %esp,%ebp
f0102fe3:	57                   	push   %edi
f0102fe4:	56                   	push   %esi
f0102fe5:	53                   	push   %ebx
f0102fe6:	83 ec 0c             	sub    $0xc,%esp
f0102fe9:	89 c6                	mov    %eax,%esi
		sa = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f0102feb:	89 d3                	mov    %edx,%ebx
f0102fed:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		ea = (uintptr_t)ROUNDUP((uintptr_t)va + len, PGSIZE);
f0102ff3:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102ffa:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

		for (; sa < ea; sa += PGSIZE) {
f0103000:	39 fb                	cmp    %edi,%ebx
f0103002:	73 57                	jae    f010305b <region_alloc+0x83>
			if (!(p = page_alloc(ALLOC_ZERO))) {
f0103004:	83 ec 0c             	sub    $0xc,%esp
f0103007:	6a 01                	push   $0x1
f0103009:	e8 df de ff ff       	call   f0100eed <page_alloc>
f010300e:	83 c4 10             	add    $0x10,%esp
f0103011:	85 c0                	test   %eax,%eax
f0103013:	74 1b                	je     f0103030 <region_alloc+0x58>
				r = -E_NO_MEM;
				panic("page_alloc: %e", r);
			}
			r = page_insert(e->env_pgdir, p, (void *)sa, PTE_P | PTE_U | PTE_W);
f0103015:	6a 07                	push   $0x7
f0103017:	53                   	push   %ebx
f0103018:	50                   	push   %eax
f0103019:	ff 76 60             	push   0x60(%esi)
f010301c:	e8 8f e1 ff ff       	call   f01011b0 <page_insert>
			if (r != 0) {
f0103021:	83 c4 10             	add    $0x10,%esp
f0103024:	85 c0                	test   %eax,%eax
f0103026:	75 1e                	jne    f0103046 <region_alloc+0x6e>
		for (; sa < ea; sa += PGSIZE) {
f0103028:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010302e:	eb d0                	jmp    f0103000 <region_alloc+0x28>
				panic("page_alloc: %e", r);
f0103030:	6a fc                	push   $0xfffffffc
f0103032:	68 de 73 10 f0       	push   $0xf01073de
f0103037:	68 35 01 00 00       	push   $0x135
f010303c:	68 ed 73 10 f0       	push   $0xf01073ed
f0103041:	e8 fa cf ff ff       	call   f0100040 <_panic>
				panic("page_insert: %e", r);
f0103046:	50                   	push   %eax
f0103047:	68 f8 73 10 f0       	push   $0xf01073f8
f010304c:	68 39 01 00 00       	push   $0x139
f0103051:	68 ed 73 10 f0       	push   $0xf01073ed
f0103056:	e8 e5 cf ff ff       	call   f0100040 <_panic>
			}
		}
	}
}
f010305b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010305e:	5b                   	pop    %ebx
f010305f:	5e                   	pop    %esi
f0103060:	5f                   	pop    %edi
f0103061:	5d                   	pop    %ebp
f0103062:	c3                   	ret    
f0103063:	c3                   	ret    

f0103064 <envid2env>:
{
f0103064:	55                   	push   %ebp
f0103065:	89 e5                	mov    %esp,%ebp
f0103067:	56                   	push   %esi
f0103068:	53                   	push   %ebx
f0103069:	8b 75 08             	mov    0x8(%ebp),%esi
f010306c:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f010306f:	85 f6                	test   %esi,%esi
f0103071:	74 2e                	je     f01030a1 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f0103073:	89 f3                	mov    %esi,%ebx
f0103075:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010307b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010307e:	03 1d 74 72 21 f0    	add    0xf0217274,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103084:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103088:	74 5b                	je     f01030e5 <envid2env+0x81>
f010308a:	39 73 48             	cmp    %esi,0x48(%ebx)
f010308d:	75 62                	jne    f01030f1 <envid2env+0x8d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010308f:	84 c0                	test   %al,%al
f0103091:	75 20                	jne    f01030b3 <envid2env+0x4f>
	return 0;
f0103093:	b8 00 00 00 00       	mov    $0x0,%eax
		*env_store = curenv;
f0103098:	8b 55 0c             	mov    0xc(%ebp),%edx
f010309b:	89 1a                	mov    %ebx,(%edx)
}
f010309d:	5b                   	pop    %ebx
f010309e:	5e                   	pop    %esi
f010309f:	5d                   	pop    %ebp
f01030a0:	c3                   	ret    
		*env_store = curenv;
f01030a1:	e8 9a 2a 00 00       	call   f0105b40 <cpunum>
f01030a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01030a9:	8b 98 28 80 25 f0    	mov    -0xfda7fd8(%eax),%ebx
		return 0;
f01030af:	89 f0                	mov    %esi,%eax
f01030b1:	eb e5                	jmp    f0103098 <envid2env+0x34>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030b3:	e8 88 2a 00 00       	call   f0105b40 <cpunum>
f01030b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01030bb:	39 98 28 80 25 f0    	cmp    %ebx,-0xfda7fd8(%eax)
f01030c1:	74 d0                	je     f0103093 <envid2env+0x2f>
f01030c3:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01030c6:	e8 75 2a 00 00       	call   f0105b40 <cpunum>
f01030cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ce:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01030d4:	3b 70 48             	cmp    0x48(%eax),%esi
f01030d7:	74 ba                	je     f0103093 <envid2env+0x2f>
f01030d9:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f01030de:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030e3:	eb b3                	jmp    f0103098 <envid2env+0x34>
f01030e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f01030ea:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030ef:	eb a7                	jmp    f0103098 <envid2env+0x34>
f01030f1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01030f6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030fb:	eb 9b                	jmp    f0103098 <envid2env+0x34>

f01030fd <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f01030fd:	b8 20 43 12 f0       	mov    $0xf0124320,%eax
f0103102:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103105:	b8 23 00 00 00       	mov    $0x23,%eax
f010310a:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010310c:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010310e:	b8 10 00 00 00       	mov    $0x10,%eax
f0103113:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103115:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103117:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103119:	ea 20 31 10 f0 08 00 	ljmp   $0x8,$0xf0103120
	asm volatile("lldt %0" : : "r" (sel));
f0103120:	b8 00 00 00 00       	mov    $0x0,%eax
f0103125:	0f 00 d0             	lldt   %ax
}
f0103128:	c3                   	ret    

f0103129 <env_init>:
{
f0103129:	55                   	push   %ebp
f010312a:	89 e5                	mov    %esp,%ebp
f010312c:	53                   	push   %ebx
f010312d:	83 ec 04             	sub    $0x4,%esp
		e = &envs[i];
f0103130:	8b 1d 74 72 21 f0    	mov    0xf0217274,%ebx
f0103136:	8b 15 78 72 21 f0    	mov    0xf0217278,%edx
f010313c:	8d 83 84 ef 01 00    	lea    0x1ef84(%ebx),%eax
f0103142:	89 d1                	mov    %edx,%ecx
f0103144:	89 c2                	mov    %eax,%edx
		e->env_id = 0;
f0103146:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		e->env_status = ENV_FREE;
f010314d:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		e->env_link = env_free_list;
f0103154:	89 48 44             	mov    %ecx,0x44(%eax)
	for(i = NENV - 1 ; i >= 0; i--) {
f0103157:	83 e8 7c             	sub    $0x7c,%eax
f010315a:	39 da                	cmp    %ebx,%edx
f010315c:	75 e4                	jne    f0103142 <env_init+0x19>
f010315e:	89 1d 78 72 21 f0    	mov    %ebx,0xf0217278
	env_init_percpu();
f0103164:	e8 94 ff ff ff       	call   f01030fd <env_init_percpu>
}
f0103169:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010316c:	c9                   	leave  
f010316d:	c3                   	ret    

f010316e <env_alloc>:
{
f010316e:	55                   	push   %ebp
f010316f:	89 e5                	mov    %esp,%ebp
f0103171:	56                   	push   %esi
f0103172:	53                   	push   %ebx
	if (!(e = env_free_list))
f0103173:	8b 1d 78 72 21 f0    	mov    0xf0217278,%ebx
f0103179:	85 db                	test   %ebx,%ebx
f010317b:	0f 84 95 01 00 00    	je     f0103316 <env_alloc+0x1a8>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103181:	83 ec 0c             	sub    $0xc,%esp
f0103184:	6a 01                	push   $0x1
f0103186:	e8 62 dd ff ff       	call   f0100eed <page_alloc>
f010318b:	89 c6                	mov    %eax,%esi
f010318d:	83 c4 10             	add    $0x10,%esp
f0103190:	85 c0                	test   %eax,%eax
f0103192:	0f 84 85 01 00 00    	je     f010331d <env_alloc+0x1af>
	return (pp - pages) << PGSHIFT;
f0103198:	2b 05 58 72 21 f0    	sub    0xf0217258,%eax
f010319e:	c1 f8 03             	sar    $0x3,%eax
f01031a1:	89 c2                	mov    %eax,%edx
f01031a3:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01031a6:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01031ab:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f01031b1:	0f 83 38 01 00 00    	jae    f01032ef <env_alloc+0x181>
	return (void *)(pa + KERNBASE);
f01031b7:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = page2kva(p);
f01031bd:	89 43 60             	mov    %eax,0x60(%ebx)
	memset(e->env_pgdir, 0, PGSIZE);
f01031c0:	83 ec 04             	sub    $0x4,%esp
f01031c3:	68 00 10 00 00       	push   $0x1000
f01031c8:	6a 00                	push   $0x0
f01031ca:	50                   	push   %eax
f01031cb:	e8 7b 23 00 00       	call   f010554b <memset>
	p->pp_ref++;
f01031d0:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
f01031d5:	83 c4 10             	add    $0x10,%esp
f01031d8:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[i] = kern_pgdir[i];
f01031dd:	8b 15 5c 72 21 f0    	mov    0xf021725c,%edx
f01031e3:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01031e6:	8b 53 60             	mov    0x60(%ebx),%edx
f01031e9:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
f01031ec:	83 c0 04             	add    $0x4,%eax
f01031ef:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01031f4:	75 e7                	jne    f01031dd <env_alloc+0x6f>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031f6:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01031f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031fe:	0f 86 fd 00 00 00    	jbe    f0103301 <env_alloc+0x193>
	return (physaddr_t)kva - KERNBASE;
f0103204:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010320a:	83 ca 05             	or     $0x5,%edx
f010320d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103213:	8b 43 48             	mov    0x48(%ebx),%eax
f0103216:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f010321b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103220:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103225:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103228:	89 da                	mov    %ebx,%edx
f010322a:	2b 15 74 72 21 f0    	sub    0xf0217274,%edx
f0103230:	c1 fa 02             	sar    $0x2,%edx
f0103233:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103239:	09 d0                	or     %edx,%eax
f010323b:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f010323e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103241:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103244:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010324b:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103252:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103259:	83 ec 04             	sub    $0x4,%esp
f010325c:	6a 44                	push   $0x44
f010325e:	6a 00                	push   $0x0
f0103260:	53                   	push   %ebx
f0103261:	e8 e5 22 00 00       	call   f010554b <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103266:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010326c:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103272:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103278:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010327f:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f0103285:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f010328c:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103293:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103297:	8b 43 44             	mov    0x44(%ebx),%eax
f010329a:	a3 78 72 21 f0       	mov    %eax,0xf0217278
	*newenv_store = e;
f010329f:	8b 45 08             	mov    0x8(%ebp),%eax
f01032a2:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032a4:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01032a7:	e8 94 28 00 00       	call   f0105b40 <cpunum>
f01032ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01032af:	83 c4 10             	add    $0x10,%esp
f01032b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01032b7:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f01032be:	74 11                	je     f01032d1 <env_alloc+0x163>
f01032c0:	e8 7b 28 00 00       	call   f0105b40 <cpunum>
f01032c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01032c8:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01032ce:	8b 50 48             	mov    0x48(%eax),%edx
f01032d1:	83 ec 04             	sub    $0x4,%esp
f01032d4:	53                   	push   %ebx
f01032d5:	52                   	push   %edx
f01032d6:	68 08 74 10 f0       	push   $0xf0107408
f01032db:	e8 52 06 00 00       	call   f0103932 <cprintf>
	return 0;
f01032e0:	83 c4 10             	add    $0x10,%esp
f01032e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01032eb:	5b                   	pop    %ebx
f01032ec:	5e                   	pop    %esi
f01032ed:	5d                   	pop    %ebp
f01032ee:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032ef:	52                   	push   %edx
f01032f0:	68 a4 61 10 f0       	push   $0xf01061a4
f01032f5:	6a 58                	push   $0x58
f01032f7:	68 b4 70 10 f0       	push   $0xf01070b4
f01032fc:	e8 3f cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103301:	50                   	push   %eax
f0103302:	68 c8 61 10 f0       	push   $0xf01061c8
f0103307:	68 cb 00 00 00       	push   $0xcb
f010330c:	68 ed 73 10 f0       	push   $0xf01073ed
f0103311:	e8 2a cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f0103316:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010331b:	eb cb                	jmp    f01032e8 <env_alloc+0x17a>
		return -E_NO_MEM;
f010331d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103322:	eb c4                	jmp    f01032e8 <env_alloc+0x17a>

f0103324 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103324:	55                   	push   %ebp
f0103325:	89 e5                	mov    %esp,%ebp
f0103327:	57                   	push   %edi
f0103328:	56                   	push   %esi
f0103329:	53                   	push   %ebx
f010332a:	83 ec 34             	sub    $0x34,%esp
f010332d:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *newenv;
	int r;
	if ((r = env_alloc(&newenv, 0)) < 0)
f0103330:	6a 00                	push   $0x0
f0103332:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103335:	50                   	push   %eax
f0103336:	e8 33 fe ff ff       	call   f010316e <env_alloc>
f010333b:	83 c4 10             	add    $0x10,%esp
f010333e:	85 c0                	test   %eax,%eax
f0103340:	78 28                	js     f010336a <env_create+0x46>
		panic("env_alloc: %e", r);

	load_icode(newenv, binary);
f0103342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103345:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103348:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010334b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103350:	76 2d                	jbe    f010337f <env_create+0x5b>
	return (physaddr_t)kva - KERNBASE;
f0103352:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103357:	0f 22 d8             	mov    %eax,%cr3
	ph = (struct Proghdr *) (binary + elfhdr ->e_phoff);
f010335a:	89 fb                	mov    %edi,%ebx
f010335c:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f010335f:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103363:	c1 e6 05             	shl    $0x5,%esi
f0103366:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++) {
f0103368:	eb 66                	jmp    f01033d0 <env_create+0xac>
		panic("env_alloc: %e", r);
f010336a:	50                   	push   %eax
f010336b:	68 1d 74 10 f0       	push   $0xf010741d
f0103370:	68 9f 01 00 00       	push   $0x19f
f0103375:	68 ed 73 10 f0       	push   $0xf01073ed
f010337a:	e8 c1 cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010337f:	50                   	push   %eax
f0103380:	68 c8 61 10 f0       	push   $0xf01061c8
f0103385:	68 78 01 00 00       	push   $0x178
f010338a:	68 ed 73 10 f0       	push   $0xf01073ed
f010338f:	e8 ac cc ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void *)(ph->p_va), ph->p_memsz);
f0103394:	8b 53 08             	mov    0x8(%ebx),%edx
f0103397:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010339a:	e8 39 fc ff ff       	call   f0102fd8 <region_alloc>
			memcpy((void *)(ph->p_va), (void *)(binary + ph->p_offset), ph->p_filesz);
f010339f:	83 ec 04             	sub    $0x4,%esp
f01033a2:	ff 73 10             	push   0x10(%ebx)
f01033a5:	89 f8                	mov    %edi,%eax
f01033a7:	03 43 04             	add    0x4(%ebx),%eax
f01033aa:	50                   	push   %eax
f01033ab:	ff 73 08             	push   0x8(%ebx)
f01033ae:	e8 40 22 00 00       	call   f01055f3 <memcpy>
			memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01033b3:	8b 43 10             	mov    0x10(%ebx),%eax
f01033b6:	83 c4 0c             	add    $0xc,%esp
f01033b9:	8b 53 14             	mov    0x14(%ebx),%edx
f01033bc:	29 c2                	sub    %eax,%edx
f01033be:	52                   	push   %edx
f01033bf:	6a 00                	push   $0x0
f01033c1:	03 43 08             	add    0x8(%ebx),%eax
f01033c4:	50                   	push   %eax
f01033c5:	e8 81 21 00 00       	call   f010554b <memset>
f01033ca:	83 c4 10             	add    $0x10,%esp
	for (; ph < eph; ph++) {
f01033cd:	83 c3 20             	add    $0x20,%ebx
f01033d0:	39 de                	cmp    %ebx,%esi
f01033d2:	76 26                	jbe    f01033fa <env_create+0xd6>
		if (ph->p_type == ELF_PROG_LOAD) {
f01033d4:	83 3b 01             	cmpl   $0x1,(%ebx)
f01033d7:	75 f4                	jne    f01033cd <env_create+0xa9>
			assert(ph->p_filesz <= ph->p_memsz);
f01033d9:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01033dc:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01033df:	76 b3                	jbe    f0103394 <env_create+0x70>
f01033e1:	68 2b 74 10 f0       	push   $0xf010742b
f01033e6:	68 ce 70 10 f0       	push   $0xf01070ce
f01033eb:	68 80 01 00 00       	push   $0x180
f01033f0:	68 ed 73 10 f0       	push   $0xf01073ed
f01033f5:	e8 46 cc ff ff       	call   f0100040 <_panic>
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f01033fa:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033ff:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103404:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103407:	e8 cc fb ff ff       	call   f0102fd8 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f010340c:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103411:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103416:	76 22                	jbe    f010343a <env_create+0x116>
	return (physaddr_t)kva - KERNBASE;
f0103418:	05 00 00 00 10       	add    $0x10000000,%eax
f010341d:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = elfhdr->e_entry;
f0103420:	8b 47 18             	mov    0x18(%edi),%eax
f0103423:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103426:	89 47 30             	mov    %eax,0x30(%edi)

	newenv->env_type = type;
f0103429:	8b 55 0c             	mov    0xc(%ebp),%edx
f010342c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010342f:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103432:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103435:	5b                   	pop    %ebx
f0103436:	5e                   	pop    %esi
f0103437:	5f                   	pop    %edi
f0103438:	5d                   	pop    %ebp
f0103439:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010343a:	50                   	push   %eax
f010343b:	68 c8 61 10 f0       	push   $0xf01061c8
f0103440:	68 8d 01 00 00       	push   $0x18d
f0103445:	68 ed 73 10 f0       	push   $0xf01073ed
f010344a:	e8 f1 cb ff ff       	call   f0100040 <_panic>

f010344f <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010344f:	55                   	push   %ebp
f0103450:	89 e5                	mov    %esp,%ebp
f0103452:	57                   	push   %edi
f0103453:	56                   	push   %esi
f0103454:	53                   	push   %ebx
f0103455:	83 ec 1c             	sub    $0x1c,%esp
f0103458:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010345b:	e8 e0 26 00 00       	call   f0105b40 <cpunum>
f0103460:	6b c0 74             	imul   $0x74,%eax,%eax
f0103463:	39 b8 28 80 25 f0    	cmp    %edi,-0xfda7fd8(%eax)
f0103469:	74 48                	je     f01034b3 <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010346b:	8b 5f 48             	mov    0x48(%edi),%ebx
f010346e:	e8 cd 26 00 00       	call   f0105b40 <cpunum>
f0103473:	6b c0 74             	imul   $0x74,%eax,%eax
f0103476:	ba 00 00 00 00       	mov    $0x0,%edx
f010347b:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f0103482:	74 11                	je     f0103495 <env_free+0x46>
f0103484:	e8 b7 26 00 00       	call   f0105b40 <cpunum>
f0103489:	6b c0 74             	imul   $0x74,%eax,%eax
f010348c:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103492:	8b 50 48             	mov    0x48(%eax),%edx
f0103495:	83 ec 04             	sub    $0x4,%esp
f0103498:	53                   	push   %ebx
f0103499:	52                   	push   %edx
f010349a:	68 47 74 10 f0       	push   $0xf0107447
f010349f:	e8 8e 04 00 00       	call   f0103932 <cprintf>
f01034a4:	83 c4 10             	add    $0x10,%esp
f01034a7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01034ae:	e9 a9 00 00 00       	jmp    f010355c <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f01034b3:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f01034b8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034bd:	76 0a                	jbe    f01034c9 <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f01034bf:	05 00 00 00 10       	add    $0x10000000,%eax
f01034c4:	0f 22 d8             	mov    %eax,%cr3
}
f01034c7:	eb a2                	jmp    f010346b <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034c9:	50                   	push   %eax
f01034ca:	68 c8 61 10 f0       	push   $0xf01061c8
f01034cf:	68 b4 01 00 00       	push   $0x1b4
f01034d4:	68 ed 73 10 f0       	push   $0xf01073ed
f01034d9:	e8 62 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034de:	56                   	push   %esi
f01034df:	68 a4 61 10 f0       	push   $0xf01061a4
f01034e4:	68 c3 01 00 00       	push   $0x1c3
f01034e9:	68 ed 73 10 f0       	push   $0xf01073ed
f01034ee:	e8 4d cb ff ff       	call   f0100040 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034f3:	83 c6 04             	add    $0x4,%esi
f01034f6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034fc:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f0103502:	74 1b                	je     f010351f <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f0103504:	f6 06 01             	testb  $0x1,(%esi)
f0103507:	74 ea                	je     f01034f3 <env_free+0xa4>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103509:	83 ec 08             	sub    $0x8,%esp
f010350c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010350f:	09 d8                	or     %ebx,%eax
f0103511:	50                   	push   %eax
f0103512:	ff 77 60             	push   0x60(%edi)
f0103515:	e8 50 dc ff ff       	call   f010116a <page_remove>
f010351a:	83 c4 10             	add    $0x10,%esp
f010351d:	eb d4                	jmp    f01034f3 <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010351f:	8b 47 60             	mov    0x60(%edi),%eax
f0103522:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103525:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f010352c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010352f:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f0103535:	73 65                	jae    f010359c <env_free+0x14d>
		page_decref(pa2page(pa));
f0103537:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010353a:	a1 58 72 21 f0       	mov    0xf0217258,%eax
f010353f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103542:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103545:	50                   	push   %eax
f0103546:	e8 8a da ff ff       	call   f0100fd5 <page_decref>
f010354b:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010354e:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103552:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103555:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010355a:	74 54                	je     f01035b0 <env_free+0x161>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010355c:	8b 47 60             	mov    0x60(%edi),%eax
f010355f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103562:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0103565:	a8 01                	test   $0x1,%al
f0103567:	74 e5                	je     f010354e <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103569:	89 c6                	mov    %eax,%esi
f010356b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103571:	c1 e8 0c             	shr    $0xc,%eax
f0103574:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103577:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f010357d:	0f 83 5b ff ff ff    	jae    f01034de <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f0103583:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103589:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010358c:	c1 e0 14             	shl    $0x14,%eax
f010358f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103592:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103597:	e9 68 ff ff ff       	jmp    f0103504 <env_free+0xb5>
		panic("pa2page called with invalid pa");
f010359c:	83 ec 04             	sub    $0x4,%esp
f010359f:	68 2c 68 10 f0       	push   $0xf010682c
f01035a4:	6a 51                	push   $0x51
f01035a6:	68 b4 70 10 f0       	push   $0xf01070b4
f01035ab:	e8 90 ca ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035b0:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01035b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035b8:	76 49                	jbe    f0103603 <env_free+0x1b4>
	e->env_pgdir = 0;
f01035ba:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01035c1:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01035c6:	c1 e8 0c             	shr    $0xc,%eax
f01035c9:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f01035cf:	73 47                	jae    f0103618 <env_free+0x1c9>
	page_decref(pa2page(pa));
f01035d1:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01035d4:	8b 15 58 72 21 f0    	mov    0xf0217258,%edx
f01035da:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01035dd:	50                   	push   %eax
f01035de:	e8 f2 d9 ff ff       	call   f0100fd5 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01035e3:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01035ea:	a1 78 72 21 f0       	mov    0xf0217278,%eax
f01035ef:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01035f2:	89 3d 78 72 21 f0    	mov    %edi,0xf0217278
}
f01035f8:	83 c4 10             	add    $0x10,%esp
f01035fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035fe:	5b                   	pop    %ebx
f01035ff:	5e                   	pop    %esi
f0103600:	5f                   	pop    %edi
f0103601:	5d                   	pop    %ebp
f0103602:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103603:	50                   	push   %eax
f0103604:	68 c8 61 10 f0       	push   $0xf01061c8
f0103609:	68 d1 01 00 00       	push   $0x1d1
f010360e:	68 ed 73 10 f0       	push   $0xf01073ed
f0103613:	e8 28 ca ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f0103618:	83 ec 04             	sub    $0x4,%esp
f010361b:	68 2c 68 10 f0       	push   $0xf010682c
f0103620:	6a 51                	push   $0x51
f0103622:	68 b4 70 10 f0       	push   $0xf01070b4
f0103627:	e8 14 ca ff ff       	call   f0100040 <_panic>

f010362c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010362c:	55                   	push   %ebp
f010362d:	89 e5                	mov    %esp,%ebp
f010362f:	53                   	push   %ebx
f0103630:	83 ec 04             	sub    $0x4,%esp
f0103633:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103636:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010363a:	74 21                	je     f010365d <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f010363c:	83 ec 0c             	sub    $0xc,%esp
f010363f:	53                   	push   %ebx
f0103640:	e8 0a fe ff ff       	call   f010344f <env_free>

	if (curenv == e) {
f0103645:	e8 f6 24 00 00       	call   f0105b40 <cpunum>
f010364a:	6b c0 74             	imul   $0x74,%eax,%eax
f010364d:	83 c4 10             	add    $0x10,%esp
f0103650:	39 98 28 80 25 f0    	cmp    %ebx,-0xfda7fd8(%eax)
f0103656:	74 1e                	je     f0103676 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103658:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010365b:	c9                   	leave  
f010365c:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010365d:	e8 de 24 00 00       	call   f0105b40 <cpunum>
f0103662:	6b c0 74             	imul   $0x74,%eax,%eax
f0103665:	39 98 28 80 25 f0    	cmp    %ebx,-0xfda7fd8(%eax)
f010366b:	74 cf                	je     f010363c <env_destroy+0x10>
		e->env_status = ENV_DYING;
f010366d:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103674:	eb e2                	jmp    f0103658 <env_destroy+0x2c>
		curenv = NULL;
f0103676:	e8 c5 24 00 00       	call   f0105b40 <cpunum>
f010367b:	6b c0 74             	imul   $0x74,%eax,%eax
f010367e:	c7 80 28 80 25 f0 00 	movl   $0x0,-0xfda7fd8(%eax)
f0103685:	00 00 00 
		sched_yield();
f0103688:	e8 44 0c 00 00       	call   f01042d1 <sched_yield>

f010368d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010368d:	55                   	push   %ebp
f010368e:	89 e5                	mov    %esp,%ebp
f0103690:	53                   	push   %ebx
f0103691:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103694:	e8 a7 24 00 00       	call   f0105b40 <cpunum>
f0103699:	6b c0 74             	imul   $0x74,%eax,%eax
f010369c:	8b 98 28 80 25 f0    	mov    -0xfda7fd8(%eax),%ebx
f01036a2:	e8 99 24 00 00       	call   f0105b40 <cpunum>
f01036a7:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036aa:	8b 65 08             	mov    0x8(%ebp),%esp
f01036ad:	61                   	popa   
f01036ae:	07                   	pop    %es
f01036af:	1f                   	pop    %ds
f01036b0:	83 c4 08             	add    $0x8,%esp
f01036b3:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036b4:	83 ec 04             	sub    $0x4,%esp
f01036b7:	68 5d 74 10 f0       	push   $0xf010745d
f01036bc:	68 08 02 00 00       	push   $0x208
f01036c1:	68 ed 73 10 f0       	push   $0xf01073ed
f01036c6:	e8 75 c9 ff ff       	call   f0100040 <_panic>

f01036cb <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01036cb:	55                   	push   %ebp
f01036cc:	89 e5                	mov    %esp,%ebp
f01036ce:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01036d1:	e8 6a 24 00 00       	call   f0105b40 <cpunum>
f01036d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d9:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f01036e0:	74 14                	je     f01036f6 <env_run+0x2b>
f01036e2:	e8 59 24 00 00       	call   f0105b40 <cpunum>
f01036e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ea:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01036f0:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01036f4:	74 7d                	je     f0103773 <env_run+0xa8>
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f01036f6:	e8 45 24 00 00       	call   f0105b40 <cpunum>
f01036fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01036fe:	8b 55 08             	mov    0x8(%ebp),%edx
f0103701:	89 90 28 80 25 f0    	mov    %edx,-0xfda7fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103707:	e8 34 24 00 00       	call   f0105b40 <cpunum>
f010370c:	6b c0 74             	imul   $0x74,%eax,%eax
f010370f:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103715:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs ++;
f010371c:	e8 1f 24 00 00       	call   f0105b40 <cpunum>
f0103721:	6b c0 74             	imul   $0x74,%eax,%eax
f0103724:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f010372a:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f010372e:	e8 0d 24 00 00       	call   f0105b40 <cpunum>
f0103733:	6b c0 74             	imul   $0x74,%eax,%eax
f0103736:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f010373c:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010373f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103744:	76 47                	jbe    f010378d <env_run+0xc2>
	return (physaddr_t)kva - KERNBASE;
f0103746:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010374b:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010374e:	83 ec 0c             	sub    $0xc,%esp
f0103751:	68 80 44 12 f0       	push   $0xf0124480
f0103756:	e8 ef 26 00 00       	call   f0105e4a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010375b:	f3 90                	pause  
	unlock_kernel(); //
	env_pop_tf(&(curenv->env_tf)); // push process's registers in usermde environment
f010375d:	e8 de 23 00 00       	call   f0105b40 <cpunum>
f0103762:	83 c4 04             	add    $0x4,%esp
f0103765:	6b c0 74             	imul   $0x74,%eax,%eax
f0103768:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f010376e:	e8 1a ff ff ff       	call   f010368d <env_pop_tf>
		curenv->env_status = ENV_RUNNABLE;
f0103773:	e8 c8 23 00 00       	call   f0105b40 <cpunum>
f0103778:	6b c0 74             	imul   $0x74,%eax,%eax
f010377b:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103781:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103788:	e9 69 ff ff ff       	jmp    f01036f6 <env_run+0x2b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010378d:	50                   	push   %eax
f010378e:	68 c8 61 10 f0       	push   $0xf01061c8
f0103793:	68 2c 02 00 00       	push   $0x22c
f0103798:	68 ed 73 10 f0       	push   $0xf01073ed
f010379d:	e8 9e c8 ff ff       	call   f0100040 <_panic>

f01037a2 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037a2:	55                   	push   %ebp
f01037a3:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01037a8:	ba 70 00 00 00       	mov    $0x70,%edx
f01037ad:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01037ae:	ba 71 00 00 00       	mov    $0x71,%edx
f01037b3:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01037b4:	0f b6 c0             	movzbl %al,%eax
}
f01037b7:	5d                   	pop    %ebp
f01037b8:	c3                   	ret    

f01037b9 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01037b9:	55                   	push   %ebp
f01037ba:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01037bf:	ba 70 00 00 00       	mov    $0x70,%edx
f01037c4:	ee                   	out    %al,(%dx)
f01037c5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037c8:	ba 71 00 00 00       	mov    $0x71,%edx
f01037cd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01037ce:	5d                   	pop    %ebp
f01037cf:	c3                   	ret    

f01037d0 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01037d0:	55                   	push   %ebp
f01037d1:	89 e5                	mov    %esp,%ebp
f01037d3:	56                   	push   %esi
f01037d4:	53                   	push   %ebx
f01037d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	irq_mask_8259A = mask;
f01037d8:	66 89 0d a8 43 12 f0 	mov    %cx,0xf01243a8
	if (!didinit)
f01037df:	80 3d 7c 72 21 f0 00 	cmpb   $0x0,0xf021727c
f01037e6:	75 07                	jne    f01037ef <irq_setmask_8259A+0x1f>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f01037e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037eb:	5b                   	pop    %ebx
f01037ec:	5e                   	pop    %esi
f01037ed:	5d                   	pop    %ebp
f01037ee:	c3                   	ret    
f01037ef:	89 ce                	mov    %ecx,%esi
f01037f1:	ba 21 00 00 00       	mov    $0x21,%edx
f01037f6:	89 c8                	mov    %ecx,%eax
f01037f8:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01037f9:	89 c8                	mov    %ecx,%eax
f01037fb:	66 c1 e8 08          	shr    $0x8,%ax
f01037ff:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103804:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103805:	83 ec 0c             	sub    $0xc,%esp
f0103808:	68 69 74 10 f0       	push   $0xf0107469
f010380d:	e8 20 01 00 00       	call   f0103932 <cprintf>
f0103812:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103815:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010381a:	0f b7 f6             	movzwl %si,%esi
f010381d:	f7 d6                	not    %esi
f010381f:	eb 08                	jmp    f0103829 <irq_setmask_8259A+0x59>
	for (i = 0; i < 16; i++)
f0103821:	83 c3 01             	add    $0x1,%ebx
f0103824:	83 fb 10             	cmp    $0x10,%ebx
f0103827:	74 18                	je     f0103841 <irq_setmask_8259A+0x71>
		if (~mask & (1<<i))
f0103829:	0f a3 de             	bt     %ebx,%esi
f010382c:	73 f3                	jae    f0103821 <irq_setmask_8259A+0x51>
			cprintf(" %d", i);
f010382e:	83 ec 08             	sub    $0x8,%esp
f0103831:	53                   	push   %ebx
f0103832:	68 1b 79 10 f0       	push   $0xf010791b
f0103837:	e8 f6 00 00 00       	call   f0103932 <cprintf>
f010383c:	83 c4 10             	add    $0x10,%esp
f010383f:	eb e0                	jmp    f0103821 <irq_setmask_8259A+0x51>
	cprintf("\n");
f0103841:	83 ec 0c             	sub    $0xc,%esp
f0103844:	68 ac 73 10 f0       	push   $0xf01073ac
f0103849:	e8 e4 00 00 00       	call   f0103932 <cprintf>
f010384e:	83 c4 10             	add    $0x10,%esp
f0103851:	eb 95                	jmp    f01037e8 <irq_setmask_8259A+0x18>

f0103853 <pic_init>:
{
f0103853:	55                   	push   %ebp
f0103854:	89 e5                	mov    %esp,%ebp
f0103856:	57                   	push   %edi
f0103857:	56                   	push   %esi
f0103858:	53                   	push   %ebx
f0103859:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f010385c:	c6 05 7c 72 21 f0 01 	movb   $0x1,0xf021727c
f0103863:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103868:	bb 21 00 00 00       	mov    $0x21,%ebx
f010386d:	89 da                	mov    %ebx,%edx
f010386f:	ee                   	out    %al,(%dx)
f0103870:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103875:	89 ca                	mov    %ecx,%edx
f0103877:	ee                   	out    %al,(%dx)
f0103878:	bf 11 00 00 00       	mov    $0x11,%edi
f010387d:	be 20 00 00 00       	mov    $0x20,%esi
f0103882:	89 f8                	mov    %edi,%eax
f0103884:	89 f2                	mov    %esi,%edx
f0103886:	ee                   	out    %al,(%dx)
f0103887:	b8 20 00 00 00       	mov    $0x20,%eax
f010388c:	89 da                	mov    %ebx,%edx
f010388e:	ee                   	out    %al,(%dx)
f010388f:	b8 04 00 00 00       	mov    $0x4,%eax
f0103894:	ee                   	out    %al,(%dx)
f0103895:	b8 03 00 00 00       	mov    $0x3,%eax
f010389a:	ee                   	out    %al,(%dx)
f010389b:	bb a0 00 00 00       	mov    $0xa0,%ebx
f01038a0:	89 f8                	mov    %edi,%eax
f01038a2:	89 da                	mov    %ebx,%edx
f01038a4:	ee                   	out    %al,(%dx)
f01038a5:	b8 28 00 00 00       	mov    $0x28,%eax
f01038aa:	89 ca                	mov    %ecx,%edx
f01038ac:	ee                   	out    %al,(%dx)
f01038ad:	b8 02 00 00 00       	mov    $0x2,%eax
f01038b2:	ee                   	out    %al,(%dx)
f01038b3:	b8 01 00 00 00       	mov    $0x1,%eax
f01038b8:	ee                   	out    %al,(%dx)
f01038b9:	bf 68 00 00 00       	mov    $0x68,%edi
f01038be:	89 f8                	mov    %edi,%eax
f01038c0:	89 f2                	mov    %esi,%edx
f01038c2:	ee                   	out    %al,(%dx)
f01038c3:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01038c8:	89 c8                	mov    %ecx,%eax
f01038ca:	ee                   	out    %al,(%dx)
f01038cb:	89 f8                	mov    %edi,%eax
f01038cd:	89 da                	mov    %ebx,%edx
f01038cf:	ee                   	out    %al,(%dx)
f01038d0:	89 c8                	mov    %ecx,%eax
f01038d2:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f01038d3:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f01038da:	66 83 f8 ff          	cmp    $0xffff,%ax
f01038de:	75 08                	jne    f01038e8 <pic_init+0x95>
}
f01038e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01038e3:	5b                   	pop    %ebx
f01038e4:	5e                   	pop    %esi
f01038e5:	5f                   	pop    %edi
f01038e6:	5d                   	pop    %ebp
f01038e7:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01038e8:	83 ec 0c             	sub    $0xc,%esp
f01038eb:	0f b7 c0             	movzwl %ax,%eax
f01038ee:	50                   	push   %eax
f01038ef:	e8 dc fe ff ff       	call   f01037d0 <irq_setmask_8259A>
f01038f4:	83 c4 10             	add    $0x10,%esp
}
f01038f7:	eb e7                	jmp    f01038e0 <pic_init+0x8d>

f01038f9 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01038f9:	55                   	push   %ebp
f01038fa:	89 e5                	mov    %esp,%ebp
f01038fc:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01038ff:	ff 75 08             	push   0x8(%ebp)
f0103902:	e8 41 ce ff ff       	call   f0100748 <cputchar>
	*cnt++;
}
f0103907:	83 c4 10             	add    $0x10,%esp
f010390a:	c9                   	leave  
f010390b:	c3                   	ret    

f010390c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010390c:	55                   	push   %ebp
f010390d:	89 e5                	mov    %esp,%ebp
f010390f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103912:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103919:	ff 75 0c             	push   0xc(%ebp)
f010391c:	ff 75 08             	push   0x8(%ebp)
f010391f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103922:	50                   	push   %eax
f0103923:	68 f9 38 10 f0       	push   $0xf01038f9
f0103928:	e8 09 15 00 00       	call   f0104e36 <vprintfmt>
	return cnt;
}
f010392d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103930:	c9                   	leave  
f0103931:	c3                   	ret    

f0103932 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103932:	55                   	push   %ebp
f0103933:	89 e5                	mov    %esp,%ebp
f0103935:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103938:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010393b:	50                   	push   %eax
f010393c:	ff 75 08             	push   0x8(%ebp)
f010393f:	e8 c8 ff ff ff       	call   f010390c <vcprintf>
	va_end(ap);

	return cnt;
}
f0103944:	c9                   	leave  
f0103945:	c3                   	ret    

f0103946 <trap_init_percpu>:

#endif

void
trap_init_percpu(void)
{
f0103946:	55                   	push   %ebp
f0103947:	89 e5                	mov    %esp,%ebp
f0103949:	57                   	push   %edi
f010394a:	56                   	push   %esi
f010394b:	53                   	push   %ebx
f010394c:	83 ec 1c             	sub    $0x1c,%esp
	uint8_t i = thiscpu->cpu_id;
f010394f:	e8 ec 21 00 00       	call   f0105b40 <cpunum>
f0103954:	6b c0 74             	imul   $0x74,%eax,%eax
f0103957:	0f b6 b8 20 80 25 f0 	movzbl -0xfda7fe0(%eax),%edi
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t) (percpu_kstacks[i] + KSTKSIZE);
f010395e:	e8 dd 21 00 00       	call   f0105b40 <cpunum>
f0103963:	6b c0 74             	imul   $0x74,%eax,%eax
f0103966:	89 f9                	mov    %edi,%ecx
f0103968:	0f b6 d9             	movzbl %cl,%ebx
f010396b:	89 da                	mov    %ebx,%edx
f010396d:	c1 e2 0f             	shl    $0xf,%edx
f0103970:	8d 92 00 00 22 f0    	lea    -0xfde0000(%edx),%edx
f0103976:	89 90 30 80 25 f0    	mov    %edx,-0xfda7fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f010397c:	e8 bf 21 00 00       	call   f0105b40 <cpunum>
f0103981:	6b c0 74             	imul   $0x74,%eax,%eax
f0103984:	66 c7 80 34 80 25 f0 	movw   $0x10,-0xfda7fcc(%eax)
f010398b:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f010398d:	83 c3 05             	add    $0x5,%ebx
f0103990:	e8 ab 21 00 00       	call   f0105b40 <cpunum>
f0103995:	89 c6                	mov    %eax,%esi
f0103997:	e8 a4 21 00 00       	call   f0105b40 <cpunum>
f010399c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010399f:	e8 9c 21 00 00       	call   f0105b40 <cpunum>
f01039a4:	66 c7 04 dd 40 43 12 	movw   $0x67,-0xfedbcc0(,%ebx,8)
f01039ab:	f0 67 00 
f01039ae:	6b f6 74             	imul   $0x74,%esi,%esi
f01039b1:	81 c6 2c 80 25 f0    	add    $0xf025802c,%esi
f01039b7:	66 89 34 dd 42 43 12 	mov    %si,-0xfedbcbe(,%ebx,8)
f01039be:	f0 
f01039bf:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f01039c3:	81 c2 2c 80 25 f0    	add    $0xf025802c,%edx
f01039c9:	c1 ea 10             	shr    $0x10,%edx
f01039cc:	88 14 dd 44 43 12 f0 	mov    %dl,-0xfedbcbc(,%ebx,8)
f01039d3:	c6 04 dd 46 43 12 f0 	movb   $0x40,-0xfedbcba(,%ebx,8)
f01039da:	40 
f01039db:	6b c0 74             	imul   $0x74,%eax,%eax
f01039de:	05 2c 80 25 f0       	add    $0xf025802c,%eax
f01039e3:	c1 e8 18             	shr    $0x18,%eax
f01039e6:	88 04 dd 47 43 12 f0 	mov    %al,-0xfedbcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f01039ed:	c6 04 dd 45 43 12 f0 	movb   $0x89,-0xfedbcbb(,%ebx,8)
f01039f4:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3) );
f01039f5:	89 f8                	mov    %edi,%eax
f01039f7:	0f b6 f8             	movzbl %al,%edi
f01039fa:	8d 3c fd 28 00 00 00 	lea    0x28(,%edi,8),%edi
	asm volatile("ltr %0" : : "r" (sel));
f0103a01:	0f 00 df             	ltr    %di
	asm volatile("lidt (%0)" : : "r" (p));
f0103a04:	b8 ac 43 12 f0       	mov    $0xf01243ac,%eax
f0103a09:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103a0c:	83 c4 1c             	add    $0x1c,%esp
f0103a0f:	5b                   	pop    %ebx
f0103a10:	5e                   	pop    %esi
f0103a11:	5f                   	pop    %edi
f0103a12:	5d                   	pop    %ebp
f0103a13:	c3                   	ret    

f0103a14 <trap_init>:
{
f0103a14:	55                   	push   %ebp
f0103a15:	89 e5                	mov    %esp,%ebp
f0103a17:	83 ec 08             	sub    $0x8,%esp
	for (i = 0; i < 256; i++) {
f0103a1a:	b8 00 00 00 00       	mov    $0x0,%eax
		SETGATE(idt[i], 0, GD_KT, traphandlertbl[i], 0); //initialize the idt to point to each entry points defined in trapentry.S
f0103a1f:	8b 14 85 b2 43 12 f0 	mov    -0xfedbc4e(,%eax,4),%edx
f0103a26:	66 89 14 c5 80 72 21 	mov    %dx,-0xfde8d80(,%eax,8)
f0103a2d:	f0 
f0103a2e:	66 c7 04 c5 82 72 21 	movw   $0x8,-0xfde8d7e(,%eax,8)
f0103a35:	f0 08 00 
f0103a38:	c6 04 c5 84 72 21 f0 	movb   $0x0,-0xfde8d7c(,%eax,8)
f0103a3f:	00 
f0103a40:	c6 04 c5 85 72 21 f0 	movb   $0x8e,-0xfde8d7b(,%eax,8)
f0103a47:	8e 
f0103a48:	c1 ea 10             	shr    $0x10,%edx
f0103a4b:	66 89 14 c5 86 72 21 	mov    %dx,-0xfde8d7a(,%eax,8)
f0103a52:	f0 
	for (i = 0; i < 256; i++) {
f0103a53:	83 c0 01             	add    $0x1,%eax
f0103a56:	3d 00 01 00 00       	cmp    $0x100,%eax
f0103a5b:	75 c2                	jne    f0103a1f <trap_init+0xb>
	SETGATE(idt[T_BRKPT], 0, GD_KT, traphandlertbl[T_BRKPT], 3);
f0103a5d:	a1 be 43 12 f0       	mov    0xf01243be,%eax
f0103a62:	66 a3 98 72 21 f0    	mov    %ax,0xf0217298
f0103a68:	66 c7 05 9a 72 21 f0 	movw   $0x8,0xf021729a
f0103a6f:	08 00 
f0103a71:	c6 05 9c 72 21 f0 00 	movb   $0x0,0xf021729c
f0103a78:	c6 05 9d 72 21 f0 ee 	movb   $0xee,0xf021729d
f0103a7f:	c1 e8 10             	shr    $0x10,%eax
f0103a82:	66 a3 9e 72 21 f0    	mov    %ax,0xf021729e
	SETGATE(idt[T_SYSCALL], 0, GD_KT, traphandlertbl[T_SYSCALL], 3);
f0103a88:	a1 72 44 12 f0       	mov    0xf0124472,%eax
f0103a8d:	66 a3 00 74 21 f0    	mov    %ax,0xf0217400
f0103a93:	66 c7 05 02 74 21 f0 	movw   $0x8,0xf0217402
f0103a9a:	08 00 
f0103a9c:	c6 05 04 74 21 f0 00 	movb   $0x0,0xf0217404
f0103aa3:	c6 05 05 74 21 f0 ee 	movb   $0xee,0xf0217405
f0103aaa:	c1 e8 10             	shr    $0x10,%eax
f0103aad:	66 a3 06 74 21 f0    	mov    %ax,0xf0217406
	trap_init_percpu();
f0103ab3:	e8 8e fe ff ff       	call   f0103946 <trap_init_percpu>
}
f0103ab8:	c9                   	leave  
f0103ab9:	c3                   	ret    

f0103aba <print_regs>:
}

void
print_regs(struct PushRegs *regs)

{
f0103aba:	55                   	push   %ebp
f0103abb:	89 e5                	mov    %esp,%ebp
f0103abd:	53                   	push   %ebx
f0103abe:	83 ec 0c             	sub    $0xc,%esp
f0103ac1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ac4:	ff 33                	push   (%ebx)
f0103ac6:	68 7d 74 10 f0       	push   $0xf010747d
f0103acb:	e8 62 fe ff ff       	call   f0103932 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ad0:	83 c4 08             	add    $0x8,%esp
f0103ad3:	ff 73 04             	push   0x4(%ebx)
f0103ad6:	68 8c 74 10 f0       	push   $0xf010748c
f0103adb:	e8 52 fe ff ff       	call   f0103932 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ae0:	83 c4 08             	add    $0x8,%esp
f0103ae3:	ff 73 08             	push   0x8(%ebx)
f0103ae6:	68 9b 74 10 f0       	push   $0xf010749b
f0103aeb:	e8 42 fe ff ff       	call   f0103932 <cprintf>
	cprintf(" oesp 0x%08x\n", regs->reg_oesp);
f0103af0:	83 c4 08             	add    $0x8,%esp
f0103af3:	ff 73 0c             	push   0xc(%ebx)
f0103af6:	68 aa 74 10 f0       	push   $0xf01074aa
f0103afb:	e8 32 fe ff ff       	call   f0103932 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103b00:	83 c4 08             	add    $0x8,%esp
f0103b03:	ff 73 10             	push   0x10(%ebx)
f0103b06:	68 b8 74 10 f0       	push   $0xf01074b8
f0103b0b:	e8 22 fe ff ff       	call   f0103932 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103b10:	83 c4 08             	add    $0x8,%esp
f0103b13:	ff 73 14             	push   0x14(%ebx)
f0103b16:	68 c7 74 10 f0       	push   $0xf01074c7
f0103b1b:	e8 12 fe ff ff       	call   f0103932 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103b20:	83 c4 08             	add    $0x8,%esp
f0103b23:	ff 73 18             	push   0x18(%ebx)
f0103b26:	68 d6 74 10 f0       	push   $0xf01074d6
f0103b2b:	e8 02 fe ff ff       	call   f0103932 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103b30:	83 c4 08             	add    $0x8,%esp
f0103b33:	ff 73 1c             	push   0x1c(%ebx)
f0103b36:	68 e5 74 10 f0       	push   $0xf01074e5
f0103b3b:	e8 f2 fd ff ff       	call   f0103932 <cprintf>
}
f0103b40:	83 c4 10             	add    $0x10,%esp
f0103b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b46:	c9                   	leave  
f0103b47:	c3                   	ret    

f0103b48 <print_trapframe>:
{
f0103b48:	55                   	push   %ebp
f0103b49:	89 e5                	mov    %esp,%ebp
f0103b4b:	56                   	push   %esi
f0103b4c:	53                   	push   %ebx
f0103b4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103b50:	e8 eb 1f 00 00       	call   f0105b40 <cpunum>
f0103b55:	83 ec 04             	sub    $0x4,%esp
f0103b58:	50                   	push   %eax
f0103b59:	53                   	push   %ebx
f0103b5a:	68 49 75 10 f0       	push   $0xf0107549
f0103b5f:	e8 ce fd ff ff       	call   f0103932 <cprintf>
	print_regs(&tf->tf_regs);
f0103b64:	89 1c 24             	mov    %ebx,(%esp)
f0103b67:	e8 4e ff ff ff       	call   f0103aba <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103b6c:	83 c4 08             	add    $0x8,%esp
f0103b6f:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103b73:	50                   	push   %eax
f0103b74:	68 67 75 10 f0       	push   $0xf0107567
f0103b79:	e8 b4 fd ff ff       	call   f0103932 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103b7e:	83 c4 08             	add    $0x8,%esp
f0103b81:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103b85:	50                   	push   %eax
f0103b86:	68 7a 75 10 f0       	push   $0xf010757a
f0103b8b:	e8 a2 fd ff ff       	call   f0103932 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103b90:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103b93:	83 c4 10             	add    $0x10,%esp
f0103b96:	83 f8 13             	cmp    $0x13,%eax
f0103b99:	0f 86 da 00 00 00    	jbe    f0103c79 <print_trapframe+0x131>
		return "System call";
f0103b9f:	ba f4 74 10 f0       	mov    $0xf01074f4,%edx
	if (trapno == T_SYSCALL)
f0103ba4:	83 f8 30             	cmp    $0x30,%eax
f0103ba7:	74 13                	je     f0103bbc <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103ba9:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0103bac:	83 fa 0f             	cmp    $0xf,%edx
f0103baf:	ba 00 75 10 f0       	mov    $0xf0107500,%edx
f0103bb4:	b9 0f 75 10 f0       	mov    $0xf010750f,%ecx
f0103bb9:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103bbc:	83 ec 04             	sub    $0x4,%esp
f0103bbf:	52                   	push   %edx
f0103bc0:	50                   	push   %eax
f0103bc1:	68 8d 75 10 f0       	push   $0xf010758d
f0103bc6:	e8 67 fd ff ff       	call   f0103932 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103bcb:	83 c4 10             	add    $0x10,%esp
f0103bce:	39 1d 80 7a 21 f0    	cmp    %ebx,0xf0217a80
f0103bd4:	0f 84 ab 00 00 00    	je     f0103c85 <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0103bda:	83 ec 08             	sub    $0x8,%esp
f0103bdd:	ff 73 2c             	push   0x2c(%ebx)
f0103be0:	68 ae 75 10 f0       	push   $0xf01075ae
f0103be5:	e8 48 fd ff ff       	call   f0103932 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103bea:	83 c4 10             	add    $0x10,%esp
f0103bed:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103bf1:	0f 85 b1 00 00 00    	jne    f0103ca8 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103bf7:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103bfa:	a8 01                	test   $0x1,%al
f0103bfc:	b9 22 75 10 f0       	mov    $0xf0107522,%ecx
f0103c01:	ba 2d 75 10 f0       	mov    $0xf010752d,%edx
f0103c06:	0f 44 ca             	cmove  %edx,%ecx
f0103c09:	a8 02                	test   $0x2,%al
f0103c0b:	ba 39 75 10 f0       	mov    $0xf0107539,%edx
f0103c10:	be 3f 75 10 f0       	mov    $0xf010753f,%esi
f0103c15:	0f 44 d6             	cmove  %esi,%edx
f0103c18:	a8 04                	test   $0x4,%al
f0103c1a:	b8 44 75 10 f0       	mov    $0xf0107544,%eax
f0103c1f:	be 8e 76 10 f0       	mov    $0xf010768e,%esi
f0103c24:	0f 44 c6             	cmove  %esi,%eax
f0103c27:	51                   	push   %ecx
f0103c28:	52                   	push   %edx
f0103c29:	50                   	push   %eax
f0103c2a:	68 bc 75 10 f0       	push   $0xf01075bc
f0103c2f:	e8 fe fc ff ff       	call   f0103932 <cprintf>
f0103c34:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103c37:	83 ec 08             	sub    $0x8,%esp
f0103c3a:	ff 73 30             	push   0x30(%ebx)
f0103c3d:	68 cb 75 10 f0       	push   $0xf01075cb
f0103c42:	e8 eb fc ff ff       	call   f0103932 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103c47:	83 c4 08             	add    $0x8,%esp
f0103c4a:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103c4e:	50                   	push   %eax
f0103c4f:	68 da 75 10 f0       	push   $0xf01075da
f0103c54:	e8 d9 fc ff ff       	call   f0103932 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103c59:	83 c4 08             	add    $0x8,%esp
f0103c5c:	ff 73 38             	push   0x38(%ebx)
f0103c5f:	68 ed 75 10 f0       	push   $0xf01075ed
f0103c64:	e8 c9 fc ff ff       	call   f0103932 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103c69:	83 c4 10             	add    $0x10,%esp
f0103c6c:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103c70:	75 4b                	jne    f0103cbd <print_trapframe+0x175>
}
f0103c72:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103c75:	5b                   	pop    %ebx
f0103c76:	5e                   	pop    %esi
f0103c77:	5d                   	pop    %ebp
f0103c78:	c3                   	ret    
		return excnames[trapno];
f0103c79:	8b 14 85 00 78 10 f0 	mov    -0xfef8800(,%eax,4),%edx
f0103c80:	e9 37 ff ff ff       	jmp    f0103bbc <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103c85:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103c89:	0f 85 4b ff ff ff    	jne    f0103bda <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103c8f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103c92:	83 ec 08             	sub    $0x8,%esp
f0103c95:	50                   	push   %eax
f0103c96:	68 9f 75 10 f0       	push   $0xf010759f
f0103c9b:	e8 92 fc ff ff       	call   f0103932 <cprintf>
f0103ca0:	83 c4 10             	add    $0x10,%esp
f0103ca3:	e9 32 ff ff ff       	jmp    f0103bda <print_trapframe+0x92>
		cprintf("\n");
f0103ca8:	83 ec 0c             	sub    $0xc,%esp
f0103cab:	68 ac 73 10 f0       	push   $0xf01073ac
f0103cb0:	e8 7d fc ff ff       	call   f0103932 <cprintf>
f0103cb5:	83 c4 10             	add    $0x10,%esp
f0103cb8:	e9 7a ff ff ff       	jmp    f0103c37 <print_trapframe+0xef>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103cbd:	83 ec 08             	sub    $0x8,%esp
f0103cc0:	ff 73 3c             	push   0x3c(%ebx)
f0103cc3:	68 fc 75 10 f0       	push   $0xf01075fc
f0103cc8:	e8 65 fc ff ff       	call   f0103932 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ccd:	83 c4 08             	add    $0x8,%esp
f0103cd0:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103cd4:	50                   	push   %eax
f0103cd5:	68 0b 76 10 f0       	push   $0xf010760b
f0103cda:	e8 53 fc ff ff       	call   f0103932 <cprintf>
f0103cdf:	83 c4 10             	add    $0x10,%esp
}
f0103ce2:	eb 8e                	jmp    f0103c72 <print_trapframe+0x12a>

f0103ce4 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ce4:	55                   	push   %ebp
f0103ce5:	89 e5                	mov    %esp,%ebp
f0103ce7:	57                   	push   %edi
f0103ce8:	56                   	push   %esi
f0103ce9:	53                   	push   %ebx
f0103cea:	83 ec 1c             	sub    $0x1c,%esp
f0103ced:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103cf0:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 0x3) == 0) {
f0103cf3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103cf7:	74 5d                	je     f0103d56 <page_fault_handler+0x72>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall != NULL) 
f0103cf9:	e8 42 1e 00 00       	call   f0105b40 <cpunum>
f0103cfe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d01:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103d07:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103d0b:	75 69                	jne    f0103d76 <page_fault_handler+0x92>
		curenv->env_tf.tf_esp = (uintptr_t)utf; // change stack pointer to Utrapframe
		env_run(curenv); //drop into user mode and resume execution.
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103d0d:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103d10:	e8 2b 1e 00 00       	call   f0105b40 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103d15:	57                   	push   %edi
f0103d16:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103d17:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103d1a:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103d20:	ff 70 48             	push   0x48(%eax)
f0103d23:	68 d8 77 10 f0       	push   $0xf01077d8
f0103d28:	e8 05 fc ff ff       	call   f0103932 <cprintf>
	print_trapframe(tf);
f0103d2d:	89 1c 24             	mov    %ebx,(%esp)
f0103d30:	e8 13 fe ff ff       	call   f0103b48 <print_trapframe>
	env_destroy(curenv);
f0103d35:	e8 06 1e 00 00       	call   f0105b40 <cpunum>
f0103d3a:	83 c4 04             	add    $0x4,%esp
f0103d3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d40:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0103d46:	e8 e1 f8 ff ff       	call   f010362c <env_destroy>
}
f0103d4b:	83 c4 10             	add    $0x10,%esp
f0103d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d51:	5b                   	pop    %ebx
f0103d52:	5e                   	pop    %esi
f0103d53:	5f                   	pop    %edi
f0103d54:	5d                   	pop    %ebp
f0103d55:	c3                   	ret    
		print_trapframe(tf);
f0103d56:	83 ec 0c             	sub    $0xc,%esp
f0103d59:	53                   	push   %ebx
f0103d5a:	e8 e9 fd ff ff       	call   f0103b48 <print_trapframe>
		panic("page fault in kernel");
f0103d5f:	83 c4 0c             	add    $0xc,%esp
f0103d62:	68 1e 76 10 f0       	push   $0xf010761e
f0103d67:	68 54 01 00 00       	push   $0x154
f0103d6c:	68 33 76 10 f0       	push   $0xf0107633
f0103d71:	e8 ca c2 ff ff       	call   f0100040 <_panic>
		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp < UXSTACKTOP) //If the user environment is already running on the user exception stack when an exception occurs, then the page fault handler itself has faulted
f0103d76:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103d79:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			stktop = (char *)tf->tf_esp;
f0103d7f:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103d85:	b9 00 00 c0 ee       	mov    $0xeec00000,%ecx
f0103d8a:	0f 47 c1             	cmova  %ecx,%eax
f0103d8d:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0103d93:	19 ff                	sbb    %edi,%edi
f0103d95:	83 e7 04             	and    $0x4,%edi
f0103d98:	83 c7 34             	add    $0x34,%edi
		user_mem_assert(curenv, stktop - sz, sz, PTE_U | PTE_W);
f0103d9b:	89 c2                	mov    %eax,%edx
f0103d9d:	29 fa                	sub    %edi,%edx
f0103d9f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103da2:	e8 99 1d 00 00       	call   f0105b40 <cpunum>
f0103da7:	6a 06                	push   $0x6
f0103da9:	57                   	push   %edi
f0103daa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103dad:	57                   	push   %edi
f0103dae:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db1:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0103db7:	e8 d0 f1 ff ff       	call   f0102f8c <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0103dbc:	89 fa                	mov    %edi,%edx
f0103dbe:	89 37                	mov    %esi,(%edi)
		utf->utf_eip = tf->tf_eip;
f0103dc0:	8b 43 30             	mov    0x30(%ebx),%eax
f0103dc3:	89 47 28             	mov    %eax,0x28(%edi)
		utf->utf_esp = tf->tf_esp;
f0103dc6:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103dc9:	89 47 30             	mov    %eax,0x30(%edi)
		utf->utf_eflags = tf->tf_eflags;
f0103dcc:	8b 43 38             	mov    0x38(%ebx),%eax
f0103dcf:	89 47 2c             	mov    %eax,0x2c(%edi)
		utf->utf_regs = tf->tf_regs;
f0103dd2:	8d 7f 08             	lea    0x8(%edi),%edi
f0103dd5:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103dda:	89 de                	mov    %ebx,%esi
f0103ddc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_err = tf->tf_err;
f0103dde:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103de1:	89 d6                	mov    %edx,%esi
f0103de3:	89 42 04             	mov    %eax,0x4(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall; // first set iret set eip to page_fault handler
f0103de6:	e8 55 1d 00 00       	call   f0105b40 <cpunum>
f0103deb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dee:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103df4:	8b 58 64             	mov    0x64(%eax),%ebx
f0103df7:	e8 44 1d 00 00       	call   f0105b40 <cpunum>
f0103dfc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dff:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103e05:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp = (uintptr_t)utf; // change stack pointer to Utrapframe
f0103e08:	e8 33 1d 00 00       	call   f0105b40 <cpunum>
f0103e0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e10:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103e16:	89 70 3c             	mov    %esi,0x3c(%eax)
		env_run(curenv); //drop into user mode and resume execution.
f0103e19:	e8 22 1d 00 00       	call   f0105b40 <cpunum>
f0103e1e:	83 c4 04             	add    $0x4,%esp
f0103e21:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e24:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0103e2a:	e8 9c f8 ff ff       	call   f01036cb <env_run>

f0103e2f <trap>:
{
f0103e2f:	55                   	push   %ebp
f0103e30:	89 e5                	mov    %esp,%ebp
f0103e32:	57                   	push   %edi
f0103e33:	56                   	push   %esi
f0103e34:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0103e37:	fc                   	cld    
	if (panicstr)
f0103e38:	83 3d 00 70 21 f0 00 	cmpl   $0x0,0xf0217000
f0103e3f:	74 01                	je     f0103e42 <trap+0x13>
		asm volatile("hlt");
f0103e41:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103e42:	e8 f9 1c 00 00       	call   f0105b40 <cpunum>
f0103e47:	6b d0 74             	imul   $0x74,%eax,%edx
f0103e4a:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0103e4d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e52:	f0 87 82 20 80 25 f0 	lock xchg %eax,-0xfda7fe0(%edx)
f0103e59:	83 f8 02             	cmp    $0x2,%eax
f0103e5c:	0f 84 87 00 00 00    	je     f0103ee9 <trap+0xba>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103e62:	9c                   	pushf  
f0103e63:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0103e64:	f6 c4 02             	test   $0x2,%ah
f0103e67:	0f 85 91 00 00 00    	jne    f0103efe <trap+0xcf>
	if ((tf->tf_cs & 3) == 3) 
f0103e6d:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103e71:	83 e0 03             	and    $0x3,%eax
f0103e74:	66 83 f8 03          	cmp    $0x3,%ax
f0103e78:	0f 84 99 00 00 00    	je     f0103f17 <trap+0xe8>
	last_tf = tf;
f0103e7e:	89 35 80 7a 21 f0    	mov    %esi,0xf0217a80
	switch (tf->tf_trapno) {
f0103e84:	8b 46 28             	mov    0x28(%esi),%eax
f0103e87:	83 f8 0e             	cmp    $0xe,%eax
f0103e8a:	0f 84 2c 01 00 00    	je     f0103fbc <trap+0x18d>
f0103e90:	83 f8 30             	cmp    $0x30,%eax
f0103e93:	0f 84 67 01 00 00    	je     f0104000 <trap+0x1d1>
f0103e99:	83 f8 03             	cmp    $0x3,%eax
f0103e9c:	0f 84 50 01 00 00    	je     f0103ff2 <trap+0x1c3>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103ea2:	83 f8 27             	cmp    $0x27,%eax
f0103ea5:	0f 84 76 01 00 00    	je     f0104021 <trap+0x1f2>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0103eab:	83 f8 20             	cmp    $0x20,%eax
f0103eae:	0f 84 87 01 00 00    	je     f010403b <trap+0x20c>
	print_trapframe(tf);
f0103eb4:	83 ec 0c             	sub    $0xc,%esp
f0103eb7:	56                   	push   %esi
f0103eb8:	e8 8b fc ff ff       	call   f0103b48 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103ebd:	83 c4 10             	add    $0x10,%esp
f0103ec0:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103ec5:	0f 84 7a 01 00 00    	je     f0104045 <trap+0x216>
		env_destroy(curenv);
f0103ecb:	e8 70 1c 00 00       	call   f0105b40 <cpunum>
f0103ed0:	83 ec 0c             	sub    $0xc,%esp
f0103ed3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ed6:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0103edc:	e8 4b f7 ff ff       	call   f010362c <env_destroy>
		return;
f0103ee1:	83 c4 10             	add    $0x10,%esp
f0103ee4:	e9 df 00 00 00       	jmp    f0103fc8 <trap+0x199>
	spin_lock(&kernel_lock);
f0103ee9:	83 ec 0c             	sub    $0xc,%esp
f0103eec:	68 80 44 12 f0       	push   $0xf0124480
f0103ef1:	e8 ba 1e 00 00       	call   f0105db0 <spin_lock>
}
f0103ef6:	83 c4 10             	add    $0x10,%esp
f0103ef9:	e9 64 ff ff ff       	jmp    f0103e62 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0103efe:	68 3f 76 10 f0       	push   $0xf010763f
f0103f03:	68 ce 70 10 f0       	push   $0xf01070ce
f0103f08:	68 17 01 00 00       	push   $0x117
f0103f0d:	68 33 76 10 f0       	push   $0xf0107633
f0103f12:	e8 29 c1 ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f0103f17:	83 ec 0c             	sub    $0xc,%esp
f0103f1a:	68 80 44 12 f0       	push   $0xf0124480
f0103f1f:	e8 8c 1e 00 00       	call   f0105db0 <spin_lock>
		assert(curenv);
f0103f24:	e8 17 1c 00 00       	call   f0105b40 <cpunum>
f0103f29:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f2c:	83 c4 10             	add    $0x10,%esp
f0103f2f:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f0103f36:	74 3e                	je     f0103f76 <trap+0x147>
		if (curenv->env_status == ENV_DYING) 
f0103f38:	e8 03 1c 00 00       	call   f0105b40 <cpunum>
f0103f3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f40:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103f46:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103f4a:	74 43                	je     f0103f8f <trap+0x160>
		curenv->env_tf = *tf;
f0103f4c:	e8 ef 1b 00 00       	call   f0105b40 <cpunum>
f0103f51:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f54:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103f5a:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103f5f:	89 c7                	mov    %eax,%edi
f0103f61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0103f63:	e8 d8 1b 00 00       	call   f0105b40 <cpunum>
f0103f68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f6b:	8b b0 28 80 25 f0    	mov    -0xfda7fd8(%eax),%esi
f0103f71:	e9 08 ff ff ff       	jmp    f0103e7e <trap+0x4f>
		assert(curenv);
f0103f76:	68 58 76 10 f0       	push   $0xf0107658
f0103f7b:	68 ce 70 10 f0       	push   $0xf01070ce
f0103f80:	68 21 01 00 00       	push   $0x121
f0103f85:	68 33 76 10 f0       	push   $0xf0107633
f0103f8a:	e8 b1 c0 ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0103f8f:	e8 ac 1b 00 00       	call   f0105b40 <cpunum>
f0103f94:	83 ec 0c             	sub    $0xc,%esp
f0103f97:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f9a:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0103fa0:	e8 aa f4 ff ff       	call   f010344f <env_free>
			curenv = NULL;
f0103fa5:	e8 96 1b 00 00       	call   f0105b40 <cpunum>
f0103faa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fad:	c7 80 28 80 25 f0 00 	movl   $0x0,-0xfda7fd8(%eax)
f0103fb4:	00 00 00 
			sched_yield();
f0103fb7:	e8 15 03 00 00       	call   f01042d1 <sched_yield>
		page_fault_handler(tf);
f0103fbc:	83 ec 0c             	sub    $0xc,%esp
f0103fbf:	56                   	push   %esi
f0103fc0:	e8 1f fd ff ff       	call   f0103ce4 <page_fault_handler>
		return;
f0103fc5:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103fc8:	e8 73 1b 00 00       	call   f0105b40 <cpunum>
f0103fcd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd0:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f0103fd7:	74 14                	je     f0103fed <trap+0x1be>
f0103fd9:	e8 62 1b 00 00       	call   f0105b40 <cpunum>
f0103fde:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fe1:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0103fe7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103feb:	74 6f                	je     f010405c <trap+0x22d>
		sched_yield();
f0103fed:	e8 df 02 00 00       	call   f01042d1 <sched_yield>
		monitor(tf);
f0103ff2:	83 ec 0c             	sub    $0xc,%esp
f0103ff5:	56                   	push   %esi
f0103ff6:	e8 f5 c8 ff ff       	call   f01008f0 <monitor>
		return;
f0103ffb:	83 c4 10             	add    $0x10,%esp
f0103ffe:	eb c8                	jmp    f0103fc8 <trap+0x199>
		tf->tf_regs.reg_eax = syscall(
f0104000:	83 ec 08             	sub    $0x8,%esp
f0104003:	ff 76 04             	push   0x4(%esi)
f0104006:	ff 36                	push   (%esi)
f0104008:	ff 76 10             	push   0x10(%esi)
f010400b:	ff 76 18             	push   0x18(%esi)
f010400e:	ff 76 14             	push   0x14(%esi)
f0104011:	ff 76 1c             	push   0x1c(%esi)
f0104014:	e8 65 03 00 00       	call   f010437e <syscall>
f0104019:	89 46 1c             	mov    %eax,0x1c(%esi)
		return;
f010401c:	83 c4 20             	add    $0x20,%esp
f010401f:	eb a7                	jmp    f0103fc8 <trap+0x199>
		cprintf("Spurious interrupt on irq 7\n");
f0104021:	83 ec 0c             	sub    $0xc,%esp
f0104024:	68 5f 76 10 f0       	push   $0xf010765f
f0104029:	e8 04 f9 ff ff       	call   f0103932 <cprintf>
		print_trapframe(tf);
f010402e:	89 34 24             	mov    %esi,(%esp)
f0104031:	e8 12 fb ff ff       	call   f0103b48 <print_trapframe>
		return;
f0104036:	83 c4 10             	add    $0x10,%esp
f0104039:	eb 8d                	jmp    f0103fc8 <trap+0x199>
		lapic_eoi();
f010403b:	e8 47 1c 00 00       	call   f0105c87 <lapic_eoi>
		sched_yield();
f0104040:	e8 8c 02 00 00       	call   f01042d1 <sched_yield>
		panic("unhandled trap in kernel");
f0104045:	83 ec 04             	sub    $0x4,%esp
f0104048:	68 7c 76 10 f0       	push   $0xf010767c
f010404d:	68 fd 00 00 00       	push   $0xfd
f0104052:	68 33 76 10 f0       	push   $0xf0107633
f0104057:	e8 e4 bf ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f010405c:	e8 df 1a 00 00       	call   f0105b40 <cpunum>
f0104061:	83 ec 0c             	sub    $0xc,%esp
f0104064:	6b c0 74             	imul   $0x74,%eax,%eax
f0104067:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f010406d:	e8 59 f6 ff ff       	call   f01036cb <env_run>

f0104072 <traphandler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(traphandler0, 0)
f0104072:	6a 00                	push   $0x0
f0104074:	6a 00                	push   $0x0
f0104076:	e9 7b 01 00 00       	jmp    f01041f6 <_alltraps>
f010407b:	90                   	nop

f010407c <traphandler1>:
TRAPHANDLER_NOEC(traphandler1, 1)
f010407c:	6a 00                	push   $0x0
f010407e:	6a 01                	push   $0x1
f0104080:	e9 71 01 00 00       	jmp    f01041f6 <_alltraps>
f0104085:	90                   	nop

f0104086 <traphandler2>:
TRAPHANDLER_NOEC(traphandler2, 2)
f0104086:	6a 00                	push   $0x0
f0104088:	6a 02                	push   $0x2
f010408a:	e9 67 01 00 00       	jmp    f01041f6 <_alltraps>
f010408f:	90                   	nop

f0104090 <traphandler3>:
TRAPHANDLER_NOEC(traphandler3, 3)
f0104090:	6a 00                	push   $0x0
f0104092:	6a 03                	push   $0x3
f0104094:	e9 5d 01 00 00       	jmp    f01041f6 <_alltraps>
f0104099:	90                   	nop

f010409a <traphandler4>:
TRAPHANDLER_NOEC(traphandler4, 4)
f010409a:	6a 00                	push   $0x0
f010409c:	6a 04                	push   $0x4
f010409e:	e9 53 01 00 00       	jmp    f01041f6 <_alltraps>
f01040a3:	90                   	nop

f01040a4 <traphandler5>:
TRAPHANDLER_NOEC(traphandler5, 5)
f01040a4:	6a 00                	push   $0x0
f01040a6:	6a 05                	push   $0x5
f01040a8:	e9 49 01 00 00       	jmp    f01041f6 <_alltraps>
f01040ad:	90                   	nop

f01040ae <traphandler6>:
TRAPHANDLER_NOEC(traphandler6, 6)
f01040ae:	6a 00                	push   $0x0
f01040b0:	6a 06                	push   $0x6
f01040b2:	e9 3f 01 00 00       	jmp    f01041f6 <_alltraps>
f01040b7:	90                   	nop

f01040b8 <traphandler7>:
TRAPHANDLER_NOEC(traphandler7, 7)
f01040b8:	6a 00                	push   $0x0
f01040ba:	6a 07                	push   $0x7
f01040bc:	e9 35 01 00 00       	jmp    f01041f6 <_alltraps>
f01040c1:	90                   	nop

f01040c2 <traphandler8>:
TRAPHANDLER(traphandler8, 8)
f01040c2:	6a 08                	push   $0x8
f01040c4:	e9 2d 01 00 00       	jmp    f01041f6 <_alltraps>
f01040c9:	90                   	nop

f01040ca <traphandler9>:
TRAPHANDLER_NOEC(traphandler9, 9) /* reserved */
f01040ca:	6a 00                	push   $0x0
f01040cc:	6a 09                	push   $0x9
f01040ce:	e9 23 01 00 00       	jmp    f01041f6 <_alltraps>
f01040d3:	90                   	nop

f01040d4 <traphandler10>:
TRAPHANDLER(traphandler10, 10)
f01040d4:	6a 0a                	push   $0xa
f01040d6:	e9 1b 01 00 00       	jmp    f01041f6 <_alltraps>
f01040db:	90                   	nop

f01040dc <traphandler11>:
TRAPHANDLER(traphandler11, 11)
f01040dc:	6a 0b                	push   $0xb
f01040de:	e9 13 01 00 00       	jmp    f01041f6 <_alltraps>
f01040e3:	90                   	nop

f01040e4 <traphandler12>:
TRAPHANDLER(traphandler12, 12)
f01040e4:	6a 0c                	push   $0xc
f01040e6:	e9 0b 01 00 00       	jmp    f01041f6 <_alltraps>
f01040eb:	90                   	nop

f01040ec <traphandler13>:
TRAPHANDLER(traphandler13, 13)
f01040ec:	6a 0d                	push   $0xd
f01040ee:	e9 03 01 00 00       	jmp    f01041f6 <_alltraps>
f01040f3:	90                   	nop

f01040f4 <traphandler14>:
TRAPHANDLER(traphandler14, 14)
f01040f4:	6a 0e                	push   $0xe
f01040f6:	e9 fb 00 00 00       	jmp    f01041f6 <_alltraps>
f01040fb:	90                   	nop

f01040fc <traphandler15>:
TRAPHANDLER_NOEC(traphandler15, 15) /* reserved */
f01040fc:	6a 00                	push   $0x0
f01040fe:	6a 0f                	push   $0xf
f0104100:	e9 f1 00 00 00       	jmp    f01041f6 <_alltraps>
f0104105:	90                   	nop

f0104106 <traphandler16>:
TRAPHANDLER_NOEC(traphandler16, 16)
f0104106:	6a 00                	push   $0x0
f0104108:	6a 10                	push   $0x10
f010410a:	e9 e7 00 00 00       	jmp    f01041f6 <_alltraps>
f010410f:	90                   	nop

f0104110 <traphandler17>:
TRAPHANDLER(traphandler17, 17)
f0104110:	6a 11                	push   $0x11
f0104112:	e9 df 00 00 00       	jmp    f01041f6 <_alltraps>
f0104117:	90                   	nop

f0104118 <traphandler18>:
TRAPHANDLER_NOEC(traphandler18, 18)
f0104118:	6a 00                	push   $0x0
f010411a:	6a 12                	push   $0x12
f010411c:	e9 d5 00 00 00       	jmp    f01041f6 <_alltraps>
f0104121:	90                   	nop

f0104122 <traphandler19>:
TRAPHANDLER_NOEC(traphandler19, 19)
f0104122:	6a 00                	push   $0x0
f0104124:	6a 13                	push   $0x13
f0104126:	e9 cb 00 00 00       	jmp    f01041f6 <_alltraps>
f010412b:	90                   	nop

f010412c <traphandler20>:
TRAPHANDLER_NOEC(traphandler20, 20)
f010412c:	6a 00                	push   $0x0
f010412e:	6a 14                	push   $0x14
f0104130:	e9 c1 00 00 00       	jmp    f01041f6 <_alltraps>
f0104135:	90                   	nop

f0104136 <traphandler21>:
TRAPHANDLER_NOEC(traphandler21, 21)
f0104136:	6a 00                	push   $0x0
f0104138:	6a 15                	push   $0x15
f010413a:	e9 b7 00 00 00       	jmp    f01041f6 <_alltraps>
f010413f:	90                   	nop

f0104140 <traphandler22>:
TRAPHANDLER_NOEC(traphandler22, 22)
f0104140:	6a 00                	push   $0x0
f0104142:	6a 16                	push   $0x16
f0104144:	e9 ad 00 00 00       	jmp    f01041f6 <_alltraps>
f0104149:	90                   	nop

f010414a <traphandler23>:
TRAPHANDLER_NOEC(traphandler23, 23)
f010414a:	6a 00                	push   $0x0
f010414c:	6a 17                	push   $0x17
f010414e:	e9 a3 00 00 00       	jmp    f01041f6 <_alltraps>
f0104153:	90                   	nop

f0104154 <traphandler24>:
TRAPHANDLER_NOEC(traphandler24, 24)
f0104154:	6a 00                	push   $0x0
f0104156:	6a 18                	push   $0x18
f0104158:	e9 99 00 00 00       	jmp    f01041f6 <_alltraps>
f010415d:	90                   	nop

f010415e <traphandler25>:
TRAPHANDLER_NOEC(traphandler25, 25)
f010415e:	6a 00                	push   $0x0
f0104160:	6a 19                	push   $0x19
f0104162:	e9 8f 00 00 00       	jmp    f01041f6 <_alltraps>
f0104167:	90                   	nop

f0104168 <traphandler26>:
TRAPHANDLER_NOEC(traphandler26, 26)
f0104168:	6a 00                	push   $0x0
f010416a:	6a 1a                	push   $0x1a
f010416c:	e9 85 00 00 00       	jmp    f01041f6 <_alltraps>
f0104171:	90                   	nop

f0104172 <traphandler27>:
TRAPHANDLER_NOEC(traphandler27, 27)
f0104172:	6a 00                	push   $0x0
f0104174:	6a 1b                	push   $0x1b
f0104176:	eb 7e                	jmp    f01041f6 <_alltraps>

f0104178 <traphandler28>:
TRAPHANDLER_NOEC(traphandler28, 28)
f0104178:	6a 00                	push   $0x0
f010417a:	6a 1c                	push   $0x1c
f010417c:	eb 78                	jmp    f01041f6 <_alltraps>

f010417e <traphandler29>:
TRAPHANDLER_NOEC(traphandler29, 29)
f010417e:	6a 00                	push   $0x0
f0104180:	6a 1d                	push   $0x1d
f0104182:	eb 72                	jmp    f01041f6 <_alltraps>

f0104184 <traphandler30>:
TRAPHANDLER_NOEC(traphandler30, 30)
f0104184:	6a 00                	push   $0x0
f0104186:	6a 1e                	push   $0x1e
f0104188:	eb 6c                	jmp    f01041f6 <_alltraps>

f010418a <traphandler31>:
TRAPHANDLER_NOEC(traphandler31, 31)
f010418a:	6a 00                	push   $0x0
f010418c:	6a 1f                	push   $0x1f
f010418e:	eb 66                	jmp    f01041f6 <_alltraps>

f0104190 <traphandler32>:
TRAPHANDLER_NOEC(traphandler32, 32)
f0104190:	6a 00                	push   $0x0
f0104192:	6a 20                	push   $0x20
f0104194:	eb 60                	jmp    f01041f6 <_alltraps>

f0104196 <traphandler33>:
TRAPHANDLER_NOEC(traphandler33, 33)
f0104196:	6a 00                	push   $0x0
f0104198:	6a 21                	push   $0x21
f010419a:	eb 5a                	jmp    f01041f6 <_alltraps>

f010419c <traphandler34>:
TRAPHANDLER_NOEC(traphandler34, 34)
f010419c:	6a 00                	push   $0x0
f010419e:	6a 22                	push   $0x22
f01041a0:	eb 54                	jmp    f01041f6 <_alltraps>

f01041a2 <traphandler35>:
TRAPHANDLER_NOEC(traphandler35, 35)
f01041a2:	6a 00                	push   $0x0
f01041a4:	6a 23                	push   $0x23
f01041a6:	eb 4e                	jmp    f01041f6 <_alltraps>

f01041a8 <traphandler36>:
TRAPHANDLER_NOEC(traphandler36, 36)
f01041a8:	6a 00                	push   $0x0
f01041aa:	6a 24                	push   $0x24
f01041ac:	eb 48                	jmp    f01041f6 <_alltraps>

f01041ae <traphandler37>:
TRAPHANDLER_NOEC(traphandler37, 37)
f01041ae:	6a 00                	push   $0x0
f01041b0:	6a 25                	push   $0x25
f01041b2:	eb 42                	jmp    f01041f6 <_alltraps>

f01041b4 <traphandler38>:
TRAPHANDLER_NOEC(traphandler38, 38)
f01041b4:	6a 00                	push   $0x0
f01041b6:	6a 26                	push   $0x26
f01041b8:	eb 3c                	jmp    f01041f6 <_alltraps>

f01041ba <traphandler39>:
TRAPHANDLER_NOEC(traphandler39, 39)
f01041ba:	6a 00                	push   $0x0
f01041bc:	6a 27                	push   $0x27
f01041be:	eb 36                	jmp    f01041f6 <_alltraps>

f01041c0 <traphandler40>:
TRAPHANDLER_NOEC(traphandler40, 40)
f01041c0:	6a 00                	push   $0x0
f01041c2:	6a 28                	push   $0x28
f01041c4:	eb 30                	jmp    f01041f6 <_alltraps>

f01041c6 <traphandler41>:
TRAPHANDLER_NOEC(traphandler41, 41)
f01041c6:	6a 00                	push   $0x0
f01041c8:	6a 29                	push   $0x29
f01041ca:	eb 2a                	jmp    f01041f6 <_alltraps>

f01041cc <traphandler42>:
TRAPHANDLER_NOEC(traphandler42, 42)
f01041cc:	6a 00                	push   $0x0
f01041ce:	6a 2a                	push   $0x2a
f01041d0:	eb 24                	jmp    f01041f6 <_alltraps>

f01041d2 <traphandler43>:
TRAPHANDLER_NOEC(traphandler43, 43)
f01041d2:	6a 00                	push   $0x0
f01041d4:	6a 2b                	push   $0x2b
f01041d6:	eb 1e                	jmp    f01041f6 <_alltraps>

f01041d8 <traphandler44>:
TRAPHANDLER_NOEC(traphandler44, 44)
f01041d8:	6a 00                	push   $0x0
f01041da:	6a 2c                	push   $0x2c
f01041dc:	eb 18                	jmp    f01041f6 <_alltraps>

f01041de <traphandler45>:
TRAPHANDLER_NOEC(traphandler45, 45)
f01041de:	6a 00                	push   $0x0
f01041e0:	6a 2d                	push   $0x2d
f01041e2:	eb 12                	jmp    f01041f6 <_alltraps>

f01041e4 <traphandler46>:
TRAPHANDLER_NOEC(traphandler46, 46)
f01041e4:	6a 00                	push   $0x0
f01041e6:	6a 2e                	push   $0x2e
f01041e8:	eb 0c                	jmp    f01041f6 <_alltraps>

f01041ea <traphandler47>:
TRAPHANDLER_NOEC(traphandler47, 47)
f01041ea:	6a 00                	push   $0x0
f01041ec:	6a 2f                	push   $0x2f
f01041ee:	eb 06                	jmp    f01041f6 <_alltraps>

f01041f0 <traphandler48>:
TRAPHANDLER_NOEC(traphandler48, 48)
f01041f0:	6a 00                	push   $0x0
f01041f2:	6a 30                	push   $0x30
f01041f4:	eb 00                	jmp    f01041f6 <_alltraps>

f01041f6 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps traps refered as interrupts, standard Xv6 name
 */
.text
_alltraps:
	pushl %es
f01041f6:	06                   	push   %es
	pushl %ds
f01041f7:	1e                   	push   %ds

	pushal
f01041f8:	60                   	pusha  

	movw $GD_KD,%ax
f01041f9:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax,%ds
f01041fd:	8e d8                	mov    %eax,%ds
	movw %ax,%es
f01041ff:	8e c0                	mov    %eax,%es

	pushl %esp
f0104201:	54                   	push   %esp

	call trap
f0104202:	e8 28 fc ff ff       	call   f0103e2f <trap>

f0104207 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104207:	55                   	push   %ebp
f0104208:	89 e5                	mov    %esp,%ebp
f010420a:	83 ec 08             	sub    $0x8,%esp
f010420d:	a1 74 72 21 f0       	mov    0xf0217274,%eax
f0104212:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104215:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010421a:	8b 02                	mov    (%edx),%eax
f010421c:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010421f:	83 f8 02             	cmp    $0x2,%eax
f0104222:	76 2d                	jbe    f0104251 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f0104224:	83 c1 01             	add    $0x1,%ecx
f0104227:	83 c2 7c             	add    $0x7c,%edx
f010422a:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104230:	75 e8                	jne    f010421a <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104232:	83 ec 0c             	sub    $0xc,%esp
f0104235:	68 50 78 10 f0       	push   $0xf0107850
f010423a:	e8 f3 f6 ff ff       	call   f0103932 <cprintf>
f010423f:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104242:	83 ec 0c             	sub    $0xc,%esp
f0104245:	6a 00                	push   $0x0
f0104247:	e8 a4 c6 ff ff       	call   f01008f0 <monitor>
f010424c:	83 c4 10             	add    $0x10,%esp
f010424f:	eb f1                	jmp    f0104242 <sched_halt+0x3b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104251:	e8 ea 18 00 00       	call   f0105b40 <cpunum>
f0104256:	6b c0 74             	imul   $0x74,%eax,%eax
f0104259:	c7 80 28 80 25 f0 00 	movl   $0x0,-0xfda7fd8(%eax)
f0104260:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104263:	a1 5c 72 21 f0       	mov    0xf021725c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104268:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010426d:	76 50                	jbe    f01042bf <sched_halt+0xb8>
	return (physaddr_t)kva - KERNBASE;
f010426f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104274:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104277:	e8 c4 18 00 00       	call   f0105b40 <cpunum>
f010427c:	6b d0 74             	imul   $0x74,%eax,%edx
f010427f:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104282:	b8 02 00 00 00       	mov    $0x2,%eax
f0104287:	f0 87 82 20 80 25 f0 	lock xchg %eax,-0xfda7fe0(%edx)
	spin_unlock(&kernel_lock);
f010428e:	83 ec 0c             	sub    $0xc,%esp
f0104291:	68 80 44 12 f0       	push   $0xf0124480
f0104296:	e8 af 1b 00 00       	call   f0105e4a <spin_unlock>
	asm volatile("pause");
f010429b:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010429d:	e8 9e 18 00 00       	call   f0105b40 <cpunum>
f01042a2:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01042a5:	8b 80 30 80 25 f0    	mov    -0xfda7fd0(%eax),%eax
f01042ab:	bd 00 00 00 00       	mov    $0x0,%ebp
f01042b0:	89 c4                	mov    %eax,%esp
f01042b2:	6a 00                	push   $0x0
f01042b4:	6a 00                	push   $0x0
f01042b6:	fb                   	sti    
f01042b7:	f4                   	hlt    
f01042b8:	eb fd                	jmp    f01042b7 <sched_halt+0xb0>
}
f01042ba:	83 c4 10             	add    $0x10,%esp
f01042bd:	c9                   	leave  
f01042be:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01042bf:	50                   	push   %eax
f01042c0:	68 c8 61 10 f0       	push   $0xf01061c8
f01042c5:	6a 50                	push   $0x50
f01042c7:	68 79 78 10 f0       	push   $0xf0107879
f01042cc:	e8 6f bd ff ff       	call   f0100040 <_panic>

f01042d1 <sched_yield>:
{
f01042d1:	55                   	push   %ebp
f01042d2:	89 e5                	mov    %esp,%ebp
f01042d4:	56                   	push   %esi
f01042d5:	53                   	push   %ebx
	if (curenv) {
f01042d6:	e8 65 18 00 00       	call   f0105b40 <cpunum>
f01042db:	6b c0 74             	imul   $0x74,%eax,%eax
	int i, c = 0;
f01042de:	ba 00 00 00 00       	mov    $0x0,%edx
	if (curenv) {
f01042e3:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f01042ea:	74 17                	je     f0104303 <sched_yield+0x32>
		c = ENVX(curenv->env_id); // ENVX(process's id) equals the environment's index in the 'envs[]' array.
f01042ec:	e8 4f 18 00 00       	call   f0105b40 <cpunum>
f01042f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f4:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01042fa:	8b 50 48             	mov    0x48(%eax),%edx
f01042fd:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
		if (envs[i].env_status == ENV_RUNNABLE)
f0104303:	8b 0d 74 72 21 f0    	mov    0xf0217274,%ecx
	for (i = c;;)
f0104309:	89 d0                	mov    %edx,%eax
		i = (i + 1) % NENV; 
f010430b:	83 c0 01             	add    $0x1,%eax
f010430e:	89 c3                	mov    %eax,%ebx
f0104310:	c1 fb 1f             	sar    $0x1f,%ebx
f0104313:	c1 eb 16             	shr    $0x16,%ebx
f0104316:	01 d8                	add    %ebx,%eax
f0104318:	25 ff 03 00 00       	and    $0x3ff,%eax
f010431d:	29 d8                	sub    %ebx,%eax
		if (envs[i].env_status == ENV_RUNNABLE)
f010431f:	6b d8 7c             	imul   $0x7c,%eax,%ebx
f0104322:	01 cb                	add    %ecx,%ebx
f0104324:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104328:	74 35                	je     f010435f <sched_yield+0x8e>
		if (i == c) break;
f010432a:	39 c2                	cmp    %eax,%edx
f010432c:	75 dd                	jne    f010430b <sched_yield+0x3a>
	if (curenv && curenv->env_status == ENV_RUNNING) {
f010432e:	e8 0d 18 00 00       	call   f0105b40 <cpunum>
f0104333:	6b c0 74             	imul   $0x74,%eax,%eax
f0104336:	83 b8 28 80 25 f0 00 	cmpl   $0x0,-0xfda7fd8(%eax)
f010433d:	74 14                	je     f0104353 <sched_yield+0x82>
f010433f:	e8 fc 17 00 00       	call   f0105b40 <cpunum>
f0104344:	6b c0 74             	imul   $0x74,%eax,%eax
f0104347:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f010434d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104351:	74 15                	je     f0104368 <sched_yield+0x97>
	sched_halt();
f0104353:	e8 af fe ff ff       	call   f0104207 <sched_halt>
}
f0104358:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010435b:	5b                   	pop    %ebx
f010435c:	5e                   	pop    %esi
f010435d:	5d                   	pop    %ebp
f010435e:	c3                   	ret    
			env_run(&envs[i]);
f010435f:	83 ec 0c             	sub    $0xc,%esp
f0104362:	53                   	push   %ebx
f0104363:	e8 63 f3 ff ff       	call   f01036cb <env_run>
		env_run(curenv);
f0104368:	e8 d3 17 00 00       	call   f0105b40 <cpunum>
f010436d:	83 ec 0c             	sub    $0xc,%esp
f0104370:	6b c0 74             	imul   $0x74,%eax,%eax
f0104373:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0104379:	e8 4d f3 ff ff       	call   f01036cb <env_run>

f010437e <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010437e:	55                   	push   %ebp
f010437f:	89 e5                	mov    %esp,%ebp
f0104381:	57                   	push   %edi
f0104382:	56                   	push   %esi
f0104383:	53                   	push   %ebx
f0104384:	83 ec 2c             	sub    $0x2c,%esp
f0104387:	8b 45 08             	mov    0x8(%ebp),%eax
f010438a:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f010438d:	83 f8 0c             	cmp    $0xc,%eax
f0104390:	0f 87 a2 05 00 00    	ja     f0104938 <syscall+0x5ba>
f0104396:	ff 24 85 c0 78 10 f0 	jmp    *-0xfef8740(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U | PTE_P);
f010439d:	e8 9e 17 00 00       	call   f0105b40 <cpunum>
f01043a2:	6a 05                	push   $0x5
f01043a4:	56                   	push   %esi
f01043a5:	ff 75 0c             	push   0xc(%ebp)
f01043a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ab:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f01043b1:	e8 d6 eb ff ff       	call   f0102f8c <user_mem_assert>
	cprintf("%.*s", len, s);
f01043b6:	83 c4 0c             	add    $0xc,%esp
f01043b9:	ff 75 0c             	push   0xc(%ebp)
f01043bc:	56                   	push   %esi
f01043bd:	68 86 78 10 f0       	push   $0xf0107886
f01043c2:	e8 6b f5 ff ff       	call   f0103932 <cprintf>
}
f01043c7:	83 c4 10             	add    $0x10,%esp
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		return 0;
f01043ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	default:
		return -E_INVAL;
	}
}
f01043cf:	89 d8                	mov    %ebx,%eax
f01043d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043d4:	5b                   	pop    %ebx
f01043d5:	5e                   	pop    %esi
f01043d6:	5f                   	pop    %edi
f01043d7:	5d                   	pop    %ebp
f01043d8:	c3                   	ret    
	return cons_getc();
f01043d9:	e8 09 c2 ff ff       	call   f01005e7 <cons_getc>
f01043de:	89 c3                	mov    %eax,%ebx
		return sys_cgetc();
f01043e0:	eb ed                	jmp    f01043cf <syscall+0x51>
	return curenv->env_id;
f01043e2:	e8 59 17 00 00       	call   f0105b40 <cpunum>
f01043e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ea:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f01043f0:	8b 58 48             	mov    0x48(%eax),%ebx
		return sys_getenvid();
f01043f3:	eb da                	jmp    f01043cf <syscall+0x51>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01043f5:	83 ec 04             	sub    $0x4,%esp
f01043f8:	6a 01                	push   $0x1
f01043fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01043fd:	50                   	push   %eax
f01043fe:	ff 75 0c             	push   0xc(%ebp)
f0104401:	e8 5e ec ff ff       	call   f0103064 <envid2env>
f0104406:	89 c3                	mov    %eax,%ebx
f0104408:	83 c4 10             	add    $0x10,%esp
f010440b:	85 c0                	test   %eax,%eax
f010440d:	78 c0                	js     f01043cf <syscall+0x51>
	if (e == curenv)
f010440f:	e8 2c 17 00 00       	call   f0105b40 <cpunum>
f0104414:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104417:	6b c0 74             	imul   $0x74,%eax,%eax
f010441a:	39 90 28 80 25 f0    	cmp    %edx,-0xfda7fd8(%eax)
f0104420:	74 3d                	je     f010445f <syscall+0xe1>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104422:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104425:	e8 16 17 00 00       	call   f0105b40 <cpunum>
f010442a:	83 ec 04             	sub    $0x4,%esp
f010442d:	53                   	push   %ebx
f010442e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104431:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104437:	ff 70 48             	push   0x48(%eax)
f010443a:	68 a6 78 10 f0       	push   $0xf01078a6
f010443f:	e8 ee f4 ff ff       	call   f0103932 <cprintf>
f0104444:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104447:	83 ec 0c             	sub    $0xc,%esp
f010444a:	ff 75 e4             	push   -0x1c(%ebp)
f010444d:	e8 da f1 ff ff       	call   f010362c <env_destroy>
	return 0;
f0104452:	83 c4 10             	add    $0x10,%esp
f0104455:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_destroy(a1);
f010445a:	e9 70 ff ff ff       	jmp    f01043cf <syscall+0x51>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010445f:	e8 dc 16 00 00       	call   f0105b40 <cpunum>
f0104464:	83 ec 08             	sub    $0x8,%esp
f0104467:	6b c0 74             	imul   $0x74,%eax,%eax
f010446a:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104470:	ff 70 48             	push   0x48(%eax)
f0104473:	68 8b 78 10 f0       	push   $0xf010788b
f0104478:	e8 b5 f4 ff ff       	call   f0103932 <cprintf>
f010447d:	83 c4 10             	add    $0x10,%esp
f0104480:	eb c5                	jmp    f0104447 <syscall+0xc9>
	sched_yield();
f0104482:	e8 4a fe ff ff       	call   f01042d1 <sched_yield>
	if ((ret = env_alloc(&e, curenv->env_id)) != 0) {
f0104487:	e8 b4 16 00 00       	call   f0105b40 <cpunum>
f010448c:	83 ec 08             	sub    $0x8,%esp
f010448f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104492:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104498:	ff 70 48             	push   0x48(%eax)
f010449b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010449e:	50                   	push   %eax
f010449f:	e8 ca ec ff ff       	call   f010316e <env_alloc>
f01044a4:	89 c3                	mov    %eax,%ebx
f01044a6:	83 c4 10             	add    $0x10,%esp
f01044a9:	85 c0                	test   %eax,%eax
f01044ab:	0f 85 1e ff ff ff    	jne    f01043cf <syscall+0x51>
	e->env_status = ENV_NOT_RUNNABLE;
f01044b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044b4:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf = curenv->env_tf;
f01044bb:	e8 80 16 00 00       	call   f0105b40 <cpunum>
f01044c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c3:	8b b0 28 80 25 f0    	mov    -0xfda7fd8(%eax),%esi
f01044c9:	b9 11 00 00 00       	mov    $0x11,%ecx
f01044ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01044d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f01044d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044d6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f01044dd:	8b 58 48             	mov    0x48(%eax),%ebx
		return sys_exofork();
f01044e0:	e9 ea fe ff ff       	jmp    f01043cf <syscall+0x51>
	if (envid2env(envid, &e, 1) != 0) {
f01044e5:	83 ec 04             	sub    $0x4,%esp
f01044e8:	6a 01                	push   $0x1
f01044ea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01044ed:	50                   	push   %eax
f01044ee:	ff 75 0c             	push   0xc(%ebp)
f01044f1:	e8 6e eb ff ff       	call   f0103064 <envid2env>
f01044f6:	89 c3                	mov    %eax,%ebx
f01044f8:	83 c4 10             	add    $0x10,%esp
f01044fb:	85 c0                	test   %eax,%eax
f01044fd:	75 15                	jne    f0104514 <syscall+0x196>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f01044ff:	8d 46 fe             	lea    -0x2(%esi),%eax
f0104502:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104507:	75 15                	jne    f010451e <syscall+0x1a0>
	e->env_status = status;
f0104509:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010450c:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f010450f:	e9 bb fe ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_BAD_ENV;
f0104514:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104519:	e9 b1 fe ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f010451e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_env_set_status(a1, a2);
f0104523:	e9 a7 fe ff ff       	jmp    f01043cf <syscall+0x51>
	if (envid2env(envid, &e, 1) != 0) {
f0104528:	83 ec 04             	sub    $0x4,%esp
f010452b:	6a 01                	push   $0x1
f010452d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104530:	50                   	push   %eax
f0104531:	ff 75 0c             	push   0xc(%ebp)
f0104534:	e8 2b eb ff ff       	call   f0103064 <envid2env>
f0104539:	83 c4 10             	add    $0x10,%esp
f010453c:	85 c0                	test   %eax,%eax
f010453e:	75 71                	jne    f01045b1 <syscall+0x233>
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) {
f0104540:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104546:	77 73                	ja     f01045bb <syscall+0x23d>
f0104548:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f010454e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104553:	39 c6                	cmp    %eax,%esi
f0104555:	75 6e                	jne    f01045c5 <syscall+0x247>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)
f0104557:	8b 45 14             	mov    0x14(%ebp),%eax
f010455a:	83 e0 05             	and    $0x5,%eax
f010455d:	83 f8 05             	cmp    $0x5,%eax
f0104560:	75 6d                	jne    f01045cf <syscall+0x251>
		|| (perm | PTE_SYSCALL) != PTE_SYSCALL) {
f0104562:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104569:	75 6e                	jne    f01045d9 <syscall+0x25b>
	if ((pp = page_alloc(ALLOC_ZERO)) == NULL) {
f010456b:	83 ec 0c             	sub    $0xc,%esp
f010456e:	6a 01                	push   $0x1
f0104570:	e8 78 c9 ff ff       	call   f0100eed <page_alloc>
f0104575:	89 c7                	mov    %eax,%edi
f0104577:	83 c4 10             	add    $0x10,%esp
f010457a:	85 c0                	test   %eax,%eax
f010457c:	74 65                	je     f01045e3 <syscall+0x265>
	if (page_insert(e->env_pgdir, pp, va, perm) != 0) {
f010457e:	ff 75 14             	push   0x14(%ebp)
f0104581:	56                   	push   %esi
f0104582:	50                   	push   %eax
f0104583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104586:	ff 70 60             	push   0x60(%eax)
f0104589:	e8 22 cc ff ff       	call   f01011b0 <page_insert>
f010458e:	89 c3                	mov    %eax,%ebx
f0104590:	83 c4 10             	add    $0x10,%esp
f0104593:	85 c0                	test   %eax,%eax
f0104595:	0f 84 34 fe ff ff    	je     f01043cf <syscall+0x51>
		page_free(pp);
f010459b:	83 ec 0c             	sub    $0xc,%esp
f010459e:	57                   	push   %edi
f010459f:	e8 be c9 ff ff       	call   f0100f62 <page_free>
		return -E_NO_MEM;
f01045a4:	83 c4 10             	add    $0x10,%esp
f01045a7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01045ac:	e9 1e fe ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_BAD_ENV;
f01045b1:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01045b6:	e9 14 fe ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f01045bb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01045c0:	e9 0a fe ff ff       	jmp    f01043cf <syscall+0x51>
f01045c5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01045ca:	e9 00 fe ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f01045cf:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01045d4:	e9 f6 fd ff ff       	jmp    f01043cf <syscall+0x51>
f01045d9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01045de:	e9 ec fd ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_NO_MEM;
f01045e3:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		return sys_page_alloc(a1, (void *)a2, a3);
f01045e8:	e9 e2 fd ff ff       	jmp    f01043cf <syscall+0x51>
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f01045ed:	8b 5d 18             	mov    0x18(%ebp),%ebx
	if (envid2env(srcenvid, &srce, 1) != 0
f01045f0:	83 ec 04             	sub    $0x4,%esp
f01045f3:	6a 01                	push   $0x1
f01045f5:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01045f8:	50                   	push   %eax
f01045f9:	ff 75 0c             	push   0xc(%ebp)
f01045fc:	e8 63 ea ff ff       	call   f0103064 <envid2env>
f0104601:	83 c4 10             	add    $0x10,%esp
f0104604:	85 c0                	test   %eax,%eax
f0104606:	0f 85 c0 00 00 00    	jne    f01046cc <syscall+0x34e>
		|| envid2env(dstenvid, &dste, 1) != 0) {
f010460c:	83 ec 04             	sub    $0x4,%esp
f010460f:	6a 01                	push   $0x1
f0104611:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104614:	50                   	push   %eax
f0104615:	ff 75 14             	push   0x14(%ebp)
f0104618:	e8 47 ea ff ff       	call   f0103064 <envid2env>
f010461d:	83 c4 10             	add    $0x10,%esp
f0104620:	85 c0                	test   %eax,%eax
f0104622:	0f 85 ae 00 00 00    	jne    f01046d6 <syscall+0x358>
	if ((uintptr_t)srcva >= UTOP || ROUNDUP(srcva, PGSIZE) != srcva
f0104628:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f010462e:	0f 87 ac 00 00 00    	ja     f01046e0 <syscall+0x362>
f0104634:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f010463a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		|| (uintptr_t)dstva >= UTOP || ROUNDUP(dstva, PGSIZE) != dstva) {
f010463f:	39 c6                	cmp    %eax,%esi
f0104641:	0f 85 a3 00 00 00    	jne    f01046ea <syscall+0x36c>
f0104647:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010464e:	0f 87 96 00 00 00    	ja     f01046ea <syscall+0x36c>
f0104654:	8b 45 18             	mov    0x18(%ebp),%eax
f0104657:	05 ff 0f 00 00       	add    $0xfff,%eax
f010465c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104661:	39 c3                	cmp    %eax,%ebx
f0104663:	0f 85 8b 00 00 00    	jne    f01046f4 <syscall+0x376>
	if ((pp = page_lookup(srce->env_pgdir, srcva, &pte)) == NULL) {
f0104669:	83 ec 04             	sub    $0x4,%esp
f010466c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010466f:	50                   	push   %eax
f0104670:	56                   	push   %esi
f0104671:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104674:	ff 70 60             	push   0x60(%eax)
f0104677:	e8 5b ca ff ff       	call   f01010d7 <page_lookup>
f010467c:	83 c4 10             	add    $0x10,%esp
f010467f:	85 c0                	test   %eax,%eax
f0104681:	74 7b                	je     f01046fe <syscall+0x380>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)
f0104683:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104686:	83 e2 05             	and    $0x5,%edx
f0104689:	83 fa 05             	cmp    $0x5,%edx
f010468c:	75 7a                	jne    f0104708 <syscall+0x38a>
		|| (perm | PTE_SYSCALL) != PTE_SYSCALL
f010468e:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104695:	75 7b                	jne    f0104712 <syscall+0x394>
		|| ((perm & PTE_W) && !(*pte & PTE_W))) {
f0104697:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010469b:	74 08                	je     f01046a5 <syscall+0x327>
f010469d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046a0:	f6 02 02             	testb  $0x2,(%edx)
f01046a3:	74 77                	je     f010471c <syscall+0x39e>
	if (page_insert(dste->env_pgdir, pp, dstva, perm) != 0) {
f01046a5:	ff 75 1c             	push   0x1c(%ebp)
f01046a8:	53                   	push   %ebx
f01046a9:	50                   	push   %eax
f01046aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046ad:	ff 70 60             	push   0x60(%eax)
f01046b0:	e8 fb ca ff ff       	call   f01011b0 <page_insert>
f01046b5:	89 c3                	mov    %eax,%ebx
f01046b7:	83 c4 10             	add    $0x10,%esp
f01046ba:	85 c0                	test   %eax,%eax
f01046bc:	0f 84 0d fd ff ff    	je     f01043cf <syscall+0x51>
		return -E_NO_MEM;
f01046c2:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01046c7:	e9 03 fd ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_BAD_ENV;
f01046cc:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01046d1:	e9 f9 fc ff ff       	jmp    f01043cf <syscall+0x51>
f01046d6:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01046db:	e9 ef fc ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f01046e0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046e5:	e9 e5 fc ff ff       	jmp    f01043cf <syscall+0x51>
f01046ea:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046ef:	e9 db fc ff ff       	jmp    f01043cf <syscall+0x51>
f01046f4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046f9:	e9 d1 fc ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f01046fe:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104703:	e9 c7 fc ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f0104708:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010470d:	e9 bd fc ff ff       	jmp    f01043cf <syscall+0x51>
f0104712:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104717:	e9 b3 fc ff ff       	jmp    f01043cf <syscall+0x51>
f010471c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f0104721:	e9 a9 fc ff ff       	jmp    f01043cf <syscall+0x51>
	if (envid2env(envid, &e, 1) != 0) 
f0104726:	83 ec 04             	sub    $0x4,%esp
f0104729:	6a 01                	push   $0x1
f010472b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010472e:	50                   	push   %eax
f010472f:	ff 75 0c             	push   0xc(%ebp)
f0104732:	e8 2d e9 ff ff       	call   f0103064 <envid2env>
f0104737:	89 c3                	mov    %eax,%ebx
f0104739:	83 c4 10             	add    $0x10,%esp
f010473c:	85 c0                	test   %eax,%eax
f010473e:	75 1f                	jne    f010475f <syscall+0x3e1>
	if ((uintptr_t)va >= UTOP) 
f0104740:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104746:	77 21                	ja     f0104769 <syscall+0x3eb>
	page_remove(e->env_pgdir, va);
f0104748:	83 ec 08             	sub    $0x8,%esp
f010474b:	56                   	push   %esi
f010474c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010474f:	ff 70 60             	push   0x60(%eax)
f0104752:	e8 13 ca ff ff       	call   f010116a <page_remove>
	return 0;
f0104757:	83 c4 10             	add    $0x10,%esp
f010475a:	e9 70 fc ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_BAD_ENV;
f010475f:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104764:	e9 66 fc ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f0104769:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		return sys_page_unmap(a1, (void *)a2);
f010476e:	e9 5c fc ff ff       	jmp    f01043cf <syscall+0x51>
	if (envid2env(envid, &e, 1) != 0) //Converts an envid to an env pointer.
f0104773:	83 ec 04             	sub    $0x4,%esp
f0104776:	6a 01                	push   $0x1
f0104778:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010477b:	50                   	push   %eax
f010477c:	ff 75 0c             	push   0xc(%ebp)
f010477f:	e8 e0 e8 ff ff       	call   f0103064 <envid2env>
f0104784:	89 c3                	mov    %eax,%ebx
f0104786:	83 c4 10             	add    $0x10,%esp
f0104789:	85 c0                	test   %eax,%eax
f010478b:	75 0b                	jne    f0104798 <syscall+0x41a>
	e->env_pgfault_upcall = func;
f010478d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104790:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0104793:	e9 37 fc ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_BAD_ENV;
f0104798:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
f010479d:	e9 2d fc ff ff       	jmp    f01043cf <syscall+0x51>
	if (envid2env(envid, &e, 0) != 0) 
f01047a2:	83 ec 04             	sub    $0x4,%esp
f01047a5:	6a 00                	push   $0x0
f01047a7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01047aa:	50                   	push   %eax
f01047ab:	ff 75 0c             	push   0xc(%ebp)
f01047ae:	e8 b1 e8 ff ff       	call   f0103064 <envid2env>
f01047b3:	89 c3                	mov    %eax,%ebx
f01047b5:	83 c4 10             	add    $0x10,%esp
f01047b8:	85 c0                	test   %eax,%eax
f01047ba:	0f 85 d2 00 00 00    	jne    f0104892 <syscall+0x514>
	if (!e->env_ipc_recving)
f01047c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047c3:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01047c7:	0f 84 cf 00 00 00    	je     f010489c <syscall+0x51e>
	send = (uintptr_t)srcva < UTOP && (uintptr_t)e->env_ipc_dstva < UTOP;
f01047cd:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01047d4:	0f 87 72 01 00 00    	ja     f010494c <syscall+0x5ce>
f01047da:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f01047e1:	0f 96 45 d7          	setbe  -0x29(%ebp)
	if ((uintptr_t)srcva < UTOP && ROUNDUP(srcva, PGSIZE) != srcva) 
f01047e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01047e8:	05 ff 0f 00 00       	add    $0xfff,%eax
f01047ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01047f2:	39 45 14             	cmp    %eax,0x14(%ebp)
f01047f5:	0f 85 ab 00 00 00    	jne    f01048a6 <syscall+0x528>
	if ((uintptr_t)srcva < UTOP && (perm | PTE_SYSCALL) != PTE_SYSCALL) 
f01047fb:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104802:	0f 85 a8 00 00 00    	jne    f01048b0 <syscall+0x532>
	if ((uintptr_t)srcva < UTOP && !(pp = page_lookup(curenv->env_pgdir, srcva, &pte))) 
f0104808:	e8 33 13 00 00       	call   f0105b40 <cpunum>
f010480d:	83 ec 04             	sub    $0x4,%esp
f0104810:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104813:	52                   	push   %edx
f0104814:	ff 75 14             	push   0x14(%ebp)
f0104817:	6b c0 74             	imul   $0x74,%eax,%eax
f010481a:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104820:	ff 70 60             	push   0x60(%eax)
f0104823:	e8 af c8 ff ff       	call   f01010d7 <page_lookup>
f0104828:	89 c7                	mov    %eax,%edi
f010482a:	83 c4 10             	add    $0x10,%esp
f010482d:	85 c0                	test   %eax,%eax
f010482f:	0f 84 85 00 00 00    	je     f01048ba <syscall+0x53c>
	if ((perm & PTE_W) && !(*pte & PTE_W)) 
f0104835:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104839:	74 0e                	je     f0104849 <syscall+0x4cb>
f010483b:	eb 04                	jmp    f0104841 <syscall+0x4c3>
	send = (uintptr_t)srcva < UTOP && (uintptr_t)e->env_ipc_dstva < UTOP;
f010483d:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
	if ((perm & PTE_W) && !(*pte & PTE_W)) 
f0104841:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104844:	f6 00 02             	testb  $0x2,(%eax)
f0104847:	74 7b                	je     f01048c4 <syscall+0x546>
	if (send && page_insert(e->env_pgdir, pp, e->env_ipc_dstva , perm) < 0) 
f0104849:	80 7d d7 00          	cmpb   $0x0,-0x29(%ebp)
f010484d:	0f 84 03 01 00 00    	je     f0104956 <syscall+0x5d8>
f0104853:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104856:	ff 75 18             	push   0x18(%ebp)
f0104859:	ff 70 6c             	push   0x6c(%eax)
f010485c:	57                   	push   %edi
f010485d:	ff 70 60             	push   0x60(%eax)
f0104860:	e8 4b c9 ff ff       	call   f01011b0 <page_insert>
f0104865:	83 c4 10             	add    $0x10,%esp
f0104868:	85 c0                	test   %eax,%eax
f010486a:	78 62                	js     f01048ce <syscall+0x550>
	e->env_ipc_recving = 0;
f010486c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010486f:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = curenv->env_id;
f0104873:	e8 c8 12 00 00       	call   f0105b40 <cpunum>
f0104878:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010487b:	6b c0 74             	imul   $0x74,%eax,%eax
f010487e:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104884:	8b 40 48             	mov    0x48(%eax),%eax
f0104887:	89 42 74             	mov    %eax,0x74(%edx)
	e->env_ipc_value = value;
f010488a:	89 72 70             	mov    %esi,0x70(%edx)
f010488d:	e9 ec 00 00 00       	jmp    f010497e <syscall+0x600>
		return -E_BAD_ENV;
f0104892:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104897:	e9 33 fb ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_IPC_NOT_RECV;
f010489c:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f01048a1:	e9 29 fb ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f01048a6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048ab:	e9 1f fb ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f01048b0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048b5:	e9 15 fb ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f01048ba:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048bf:	e9 0b fb ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f01048c4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048c9:	e9 01 fb ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_NO_MEM;
f01048ce:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f01048d3:	e9 f7 fa ff ff       	jmp    f01043cf <syscall+0x51>
	if ((uintptr_t)dstva < UTOP && ROUNDUP(dstva, PGSIZE) != dstva) {
f01048d8:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01048df:	77 12                	ja     f01048f3 <syscall+0x575>
f01048e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01048e4:	05 ff 0f 00 00       	add    $0xfff,%eax
f01048e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01048ee:	39 45 0c             	cmp    %eax,0xc(%ebp)
f01048f1:	75 4f                	jne    f0104942 <syscall+0x5c4>
	curenv->env_ipc_recving = 1;
f01048f3:	e8 48 12 00 00       	call   f0105b40 <cpunum>
f01048f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01048fb:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104901:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104905:	e8 36 12 00 00       	call   f0105b40 <cpunum>
f010490a:	6b c0 74             	imul   $0x74,%eax,%eax
f010490d:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104913:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104916:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104919:	e8 22 12 00 00       	call   f0105b40 <cpunum>
f010491e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104921:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f0104927:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	return 0;
f010492e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104933:	e9 97 fa ff ff       	jmp    f01043cf <syscall+0x51>
	switch (syscallno) {
f0104938:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010493d:	e9 8d fa ff ff       	jmp    f01043cf <syscall+0x51>
		return -E_INVAL;
f0104942:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104947:	e9 83 fa ff ff       	jmp    f01043cf <syscall+0x51>
	if ((perm & PTE_W) && !(*pte & PTE_W)) 
f010494c:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104950:	0f 85 e7 fe ff ff    	jne    f010483d <syscall+0x4bf>
	e->env_ipc_recving = 0;
f0104956:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104959:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = curenv->env_id;
f010495d:	e8 de 11 00 00       	call   f0105b40 <cpunum>
f0104962:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104965:	6b c0 74             	imul   $0x74,%eax,%eax
f0104968:	8b 80 28 80 25 f0    	mov    -0xfda7fd8(%eax),%eax
f010496e:	8b 40 48             	mov    0x48(%eax),%eax
f0104971:	89 42 74             	mov    %eax,0x74(%edx)
	e->env_ipc_value = value;
f0104974:	89 72 70             	mov    %esi,0x70(%edx)
f0104977:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
	e->env_ipc_perm = send ? perm : 0;
f010497e:	8b 45 18             	mov    0x18(%ebp),%eax
f0104981:	89 42 78             	mov    %eax,0x78(%edx)
	e->env_status = ENV_RUNNABLE;
f0104984:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	return 0;
f010498b:	e9 3f fa ff ff       	jmp    f01043cf <syscall+0x51>

f0104990 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104990:	55                   	push   %ebp
f0104991:	89 e5                	mov    %esp,%ebp
f0104993:	57                   	push   %edi
f0104994:	56                   	push   %esi
f0104995:	53                   	push   %ebx
f0104996:	83 ec 14             	sub    $0x14,%esp
f0104999:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010499c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010499f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01049a2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01049a5:	8b 1a                	mov    (%edx),%ebx
f01049a7:	8b 01                	mov    (%ecx),%eax
f01049a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01049ac:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01049b3:	eb 2f                	jmp    f01049e4 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01049b5:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01049b8:	39 c3                	cmp    %eax,%ebx
f01049ba:	7f 4e                	jg     f0104a0a <stab_binsearch+0x7a>
f01049bc:	0f b6 0a             	movzbl (%edx),%ecx
f01049bf:	83 ea 0c             	sub    $0xc,%edx
f01049c2:	39 f1                	cmp    %esi,%ecx
f01049c4:	75 ef                	jne    f01049b5 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01049c6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01049c9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01049cc:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01049d0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01049d3:	73 3a                	jae    f0104a0f <stab_binsearch+0x7f>
			*region_left = m;
f01049d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01049d8:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01049da:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01049dd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01049e4:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01049e7:	7f 53                	jg     f0104a3c <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01049e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01049ec:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01049ef:	89 d0                	mov    %edx,%eax
f01049f1:	c1 e8 1f             	shr    $0x1f,%eax
f01049f4:	01 d0                	add    %edx,%eax
f01049f6:	89 c7                	mov    %eax,%edi
f01049f8:	d1 ff                	sar    %edi
f01049fa:	83 e0 fe             	and    $0xfffffffe,%eax
f01049fd:	01 f8                	add    %edi,%eax
f01049ff:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a02:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104a06:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104a08:	eb ae                	jmp    f01049b8 <stab_binsearch+0x28>
			l = true_m + 1;
f0104a0a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104a0d:	eb d5                	jmp    f01049e4 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104a0f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104a12:	76 14                	jbe    f0104a28 <stab_binsearch+0x98>
			*region_right = m - 1;
f0104a14:	83 e8 01             	sub    $0x1,%eax
f0104a17:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a1a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104a1d:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104a1f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104a26:	eb bc                	jmp    f01049e4 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104a28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a2b:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104a2d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104a31:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104a33:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104a3a:	eb a8                	jmp    f01049e4 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104a3c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104a40:	75 15                	jne    f0104a57 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104a42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a45:	8b 00                	mov    (%eax),%eax
f0104a47:	83 e8 01             	sub    $0x1,%eax
f0104a4a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104a4d:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104a4f:	83 c4 14             	add    $0x14,%esp
f0104a52:	5b                   	pop    %ebx
f0104a53:	5e                   	pop    %esi
f0104a54:	5f                   	pop    %edi
f0104a55:	5d                   	pop    %ebp
f0104a56:	c3                   	ret    
		for (l = *region_right;
f0104a57:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a5a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104a5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a5f:	8b 0f                	mov    (%edi),%ecx
f0104a61:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a64:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104a67:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104a6b:	39 c1                	cmp    %eax,%ecx
f0104a6d:	7d 0f                	jge    f0104a7e <stab_binsearch+0xee>
f0104a6f:	0f b6 1a             	movzbl (%edx),%ebx
f0104a72:	83 ea 0c             	sub    $0xc,%edx
f0104a75:	39 f3                	cmp    %esi,%ebx
f0104a77:	74 05                	je     f0104a7e <stab_binsearch+0xee>
		     l--)
f0104a79:	83 e8 01             	sub    $0x1,%eax
f0104a7c:	eb ed                	jmp    f0104a6b <stab_binsearch+0xdb>
		*region_left = l;
f0104a7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a81:	89 07                	mov    %eax,(%edi)
}
f0104a83:	eb ca                	jmp    f0104a4f <stab_binsearch+0xbf>

f0104a85 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104a85:	55                   	push   %ebp
f0104a86:	89 e5                	mov    %esp,%ebp
f0104a88:	57                   	push   %edi
f0104a89:	56                   	push   %esi
f0104a8a:	53                   	push   %ebx
f0104a8b:	83 ec 4c             	sub    $0x4c,%esp
f0104a8e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104a91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104a94:	c7 03 f4 78 10 f0    	movl   $0xf01078f4,(%ebx)
	info->eip_line = 0;
f0104a9a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104aa1:	c7 43 08 f4 78 10 f0 	movl   $0xf01078f4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104aa8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104aaf:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104ab2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104ab9:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104abf:	0f 86 30 01 00 00    	jbe    f0104bf5 <debuginfo_eip+0x170>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104ac5:	c7 45 c0 f2 9d 11 f0 	movl   $0xf0119df2,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104acc:	c7 45 bc b1 34 11 f0 	movl   $0xf01134b1,-0x44(%ebp)
		stab_end = __STAB_END__;
f0104ad3:	be b0 34 11 f0       	mov    $0xf01134b0,%esi
		stabs = __STAB_BEGIN__;
f0104ad8:	c7 45 c4 d4 7d 10 f0 	movl   $0xf0107dd4,-0x3c(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104adf:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104ae2:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0104ae5:	0f 83 46 02 00 00    	jae    f0104d31 <debuginfo_eip+0x2ac>
f0104aeb:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104aef:	0f 85 43 02 00 00    	jne    f0104d38 <debuginfo_eip+0x2b3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104af5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104afc:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0104aff:	c1 fe 02             	sar    $0x2,%esi
f0104b02:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104b08:	83 e8 01             	sub    $0x1,%eax
f0104b0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104b0e:	83 ec 08             	sub    $0x8,%esp
f0104b11:	57                   	push   %edi
f0104b12:	6a 64                	push   $0x64
f0104b14:	8d 75 e0             	lea    -0x20(%ebp),%esi
f0104b17:	89 f1                	mov    %esi,%ecx
f0104b19:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104b1c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104b1f:	e8 6c fe ff ff       	call   f0104990 <stab_binsearch>
	if (lfile == 0)
f0104b24:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b27:	83 c4 10             	add    $0x10,%esp
f0104b2a:	85 f6                	test   %esi,%esi
f0104b2c:	0f 84 0d 02 00 00    	je     f0104d3f <debuginfo_eip+0x2ba>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104b32:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f0104b35:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b38:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104b3b:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104b3e:	83 ec 08             	sub    $0x8,%esp
f0104b41:	57                   	push   %edi
f0104b42:	6a 24                	push   $0x24
f0104b44:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104b47:	89 d1                	mov    %edx,%ecx
f0104b49:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104b4c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104b4f:	e8 3c fe ff ff       	call   f0104990 <stab_binsearch>

	if (lfun <= rfun) {
f0104b54:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104b57:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f0104b5a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104b5d:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0104b60:	83 c4 10             	add    $0x10,%esp
f0104b63:	39 c2                	cmp    %eax,%edx
f0104b65:	0f 8f 3a 01 00 00    	jg     f0104ca5 <debuginfo_eip+0x220>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104b6b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104b6e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104b71:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104b74:	8b 02                	mov    (%edx),%eax
f0104b76:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104b79:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f0104b7c:	39 c8                	cmp    %ecx,%eax
f0104b7e:	73 06                	jae    f0104b86 <debuginfo_eip+0x101>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104b80:	03 45 bc             	add    -0x44(%ebp),%eax
f0104b83:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104b86:	8b 42 08             	mov    0x8(%edx),%eax
		addr -= info->eip_fn_addr;
f0104b89:	29 c7                	sub    %eax,%edi
f0104b8b:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104b8e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0104b91:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104b94:	89 43 10             	mov    %eax,0x10(%ebx)
		// Search within the function definition for the line number.
		lline = lfun;
f0104b97:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0104b9a:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104b9d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104ba0:	83 ec 08             	sub    $0x8,%esp
f0104ba3:	6a 3a                	push   $0x3a
f0104ba5:	ff 73 08             	push   0x8(%ebx)
f0104ba8:	e8 82 09 00 00       	call   f010552f <strfind>
f0104bad:	2b 43 08             	sub    0x8(%ebx),%eax
f0104bb0:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104bb3:	83 c4 08             	add    $0x8,%esp
f0104bb6:	57                   	push   %edi
f0104bb7:	6a 44                	push   $0x44
f0104bb9:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104bbc:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104bbf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104bc2:	89 f8                	mov    %edi,%eax
f0104bc4:	e8 c7 fd ff ff       	call   f0104990 <stab_binsearch>
	if (lline <= rline) {
f0104bc9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104bcc:	83 c4 10             	add    $0x10,%esp
		// stabs[lline] points to the line number
		info->eip_line = stabs[lline].n_desc;
	} else {
		// Couldn't find line number stab! return -1
		info->eip_line = -1;
f0104bcf:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	if (lline <= rline) {
f0104bd4:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104bd7:	7f 08                	jg     f0104be1 <debuginfo_eip+0x15c>
		info->eip_line = stabs[lline].n_desc;
f0104bd9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104bdc:	0f b7 54 97 06       	movzwl 0x6(%edi,%edx,4),%edx
f0104be1:	89 53 04             	mov    %edx,0x4(%ebx)
f0104be4:	89 c2                	mov    %eax,%edx
f0104be6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104be9:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104bec:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
f0104bf0:	e9 bf 00 00 00       	jmp    f0104cb4 <debuginfo_eip+0x22f>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_P | PTE_U)) {
f0104bf5:	e8 46 0f 00 00       	call   f0105b40 <cpunum>
f0104bfa:	6a 05                	push   $0x5
f0104bfc:	6a 10                	push   $0x10
f0104bfe:	68 00 00 20 00       	push   $0x200000
f0104c03:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c06:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0104c0c:	e8 e6 e2 ff ff       	call   f0102ef7 <user_mem_check>
f0104c11:	83 c4 10             	add    $0x10,%esp
f0104c14:	85 c0                	test   %eax,%eax
f0104c16:	0f 85 07 01 00 00    	jne    f0104d23 <debuginfo_eip+0x29e>
		stabs = usd->stabs;
f0104c1c:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104c22:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104c25:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104c2b:	a1 08 00 20 00       	mov    0x200008,%eax
f0104c30:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0104c33:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104c38:	89 45 c0             	mov    %eax,-0x40(%ebp)
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_P | PTE_U)) {
f0104c3b:	e8 00 0f 00 00       	call   f0105b40 <cpunum>
f0104c40:	89 c2                	mov    %eax,%edx
f0104c42:	6a 05                	push   $0x5
f0104c44:	89 f0                	mov    %esi,%eax
f0104c46:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104c49:	29 c8                	sub    %ecx,%eax
f0104c4b:	c1 f8 02             	sar    $0x2,%eax
f0104c4e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104c54:	50                   	push   %eax
f0104c55:	51                   	push   %ecx
f0104c56:	6b d2 74             	imul   $0x74,%edx,%edx
f0104c59:	ff b2 28 80 25 f0    	push   -0xfda7fd8(%edx)
f0104c5f:	e8 93 e2 ff ff       	call   f0102ef7 <user_mem_check>
f0104c64:	83 c4 10             	add    $0x10,%esp
f0104c67:	85 c0                	test   %eax,%eax
f0104c69:	0f 85 bb 00 00 00    	jne    f0104d2a <debuginfo_eip+0x2a5>
		if (user_mem_check(curenv, usd, stabstr_end - stabstr, PTE_P | PTE_U)) {
f0104c6f:	e8 cc 0e 00 00       	call   f0105b40 <cpunum>
f0104c74:	6a 05                	push   $0x5
f0104c76:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104c79:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0104c7c:	52                   	push   %edx
f0104c7d:	68 00 00 20 00       	push   $0x200000
f0104c82:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c85:	ff b0 28 80 25 f0    	push   -0xfda7fd8(%eax)
f0104c8b:	e8 67 e2 ff ff       	call   f0102ef7 <user_mem_check>
f0104c90:	83 c4 10             	add    $0x10,%esp
f0104c93:	85 c0                	test   %eax,%eax
f0104c95:	0f 84 44 fe ff ff    	je     f0104adf <debuginfo_eip+0x5a>
			return -1;
f0104c9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ca0:	e9 a6 00 00 00       	jmp    f0104d4b <debuginfo_eip+0x2c6>
f0104ca5:	89 f8                	mov    %edi,%eax
f0104ca7:	89 f2                	mov    %esi,%edx
f0104ca9:	e9 e6 fe ff ff       	jmp    f0104b94 <debuginfo_eip+0x10f>
f0104cae:	83 ea 01             	sub    $0x1,%edx
f0104cb1:	83 e8 0c             	sub    $0xc,%eax
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104cb4:	39 d6                	cmp    %edx,%esi
f0104cb6:	7f 2e                	jg     f0104ce6 <debuginfo_eip+0x261>
	       && stabs[lline].n_type != N_SOL
f0104cb8:	0f b6 08             	movzbl (%eax),%ecx
f0104cbb:	80 f9 84             	cmp    $0x84,%cl
f0104cbe:	74 0b                	je     f0104ccb <debuginfo_eip+0x246>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104cc0:	80 f9 64             	cmp    $0x64,%cl
f0104cc3:	75 e9                	jne    f0104cae <debuginfo_eip+0x229>
f0104cc5:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104cc9:	74 e3                	je     f0104cae <debuginfo_eip+0x229>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ccb:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104cce:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104cd1:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104cd4:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104cd7:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104cda:	29 f8                	sub    %edi,%eax
f0104cdc:	39 c2                	cmp    %eax,%edx
f0104cde:	73 06                	jae    f0104ce6 <debuginfo_eip+0x261>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104ce0:	89 f8                	mov    %edi,%eax
f0104ce2:	01 d0                	add    %edx,%eax
f0104ce4:	89 03                	mov    %eax,(%ebx)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ce6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104ceb:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104cee:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0104cf1:	39 f7                	cmp    %esi,%edi
f0104cf3:	7d 56                	jge    f0104d4b <debuginfo_eip+0x2c6>
		for (lline = lfun + 1;
f0104cf5:	83 c7 01             	add    $0x1,%edi
f0104cf8:	89 f8                	mov    %edi,%eax
f0104cfa:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f0104cfd:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104d00:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104d04:	eb 04                	jmp    f0104d0a <debuginfo_eip+0x285>
			info->eip_fn_narg++;
f0104d06:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104d0a:	39 c6                	cmp    %eax,%esi
f0104d0c:	7e 38                	jle    f0104d46 <debuginfo_eip+0x2c1>
f0104d0e:	0f b6 0a             	movzbl (%edx),%ecx
f0104d11:	83 c0 01             	add    $0x1,%eax
f0104d14:	83 c2 0c             	add    $0xc,%edx
f0104d17:	80 f9 a0             	cmp    $0xa0,%cl
f0104d1a:	74 ea                	je     f0104d06 <debuginfo_eip+0x281>
	return 0;
f0104d1c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d21:	eb 28                	jmp    f0104d4b <debuginfo_eip+0x2c6>
			return -1;
f0104d23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d28:	eb 21                	jmp    f0104d4b <debuginfo_eip+0x2c6>
			return -1;
f0104d2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d2f:	eb 1a                	jmp    f0104d4b <debuginfo_eip+0x2c6>
		return -1;
f0104d31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d36:	eb 13                	jmp    f0104d4b <debuginfo_eip+0x2c6>
f0104d38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d3d:	eb 0c                	jmp    f0104d4b <debuginfo_eip+0x2c6>
		return -1;
f0104d3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d44:	eb 05                	jmp    f0104d4b <debuginfo_eip+0x2c6>
	return 0;
f0104d46:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d4e:	5b                   	pop    %ebx
f0104d4f:	5e                   	pop    %esi
f0104d50:	5f                   	pop    %edi
f0104d51:	5d                   	pop    %ebp
f0104d52:	c3                   	ret    

f0104d53 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104d53:	55                   	push   %ebp
f0104d54:	89 e5                	mov    %esp,%ebp
f0104d56:	57                   	push   %edi
f0104d57:	56                   	push   %esi
f0104d58:	53                   	push   %ebx
f0104d59:	83 ec 1c             	sub    $0x1c,%esp
f0104d5c:	89 c7                	mov    %eax,%edi
f0104d5e:	89 d6                	mov    %edx,%esi
f0104d60:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d63:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d66:	89 d1                	mov    %edx,%ecx
f0104d68:	89 c2                	mov    %eax,%edx
f0104d6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d6d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104d70:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d73:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104d76:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104d79:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104d80:	39 c2                	cmp    %eax,%edx
f0104d82:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0104d85:	72 3e                	jb     f0104dc5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104d87:	83 ec 0c             	sub    $0xc,%esp
f0104d8a:	ff 75 18             	push   0x18(%ebp)
f0104d8d:	83 eb 01             	sub    $0x1,%ebx
f0104d90:	53                   	push   %ebx
f0104d91:	50                   	push   %eax
f0104d92:	83 ec 08             	sub    $0x8,%esp
f0104d95:	ff 75 e4             	push   -0x1c(%ebp)
f0104d98:	ff 75 e0             	push   -0x20(%ebp)
f0104d9b:	ff 75 dc             	push   -0x24(%ebp)
f0104d9e:	ff 75 d8             	push   -0x28(%ebp)
f0104da1:	e8 9a 11 00 00       	call   f0105f40 <__udivdi3>
f0104da6:	83 c4 18             	add    $0x18,%esp
f0104da9:	52                   	push   %edx
f0104daa:	50                   	push   %eax
f0104dab:	89 f2                	mov    %esi,%edx
f0104dad:	89 f8                	mov    %edi,%eax
f0104daf:	e8 9f ff ff ff       	call   f0104d53 <printnum>
f0104db4:	83 c4 20             	add    $0x20,%esp
f0104db7:	eb 13                	jmp    f0104dcc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104db9:	83 ec 08             	sub    $0x8,%esp
f0104dbc:	56                   	push   %esi
f0104dbd:	ff 75 18             	push   0x18(%ebp)
f0104dc0:	ff d7                	call   *%edi
f0104dc2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104dc5:	83 eb 01             	sub    $0x1,%ebx
f0104dc8:	85 db                	test   %ebx,%ebx
f0104dca:	7f ed                	jg     f0104db9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104dcc:	83 ec 08             	sub    $0x8,%esp
f0104dcf:	56                   	push   %esi
f0104dd0:	83 ec 04             	sub    $0x4,%esp
f0104dd3:	ff 75 e4             	push   -0x1c(%ebp)
f0104dd6:	ff 75 e0             	push   -0x20(%ebp)
f0104dd9:	ff 75 dc             	push   -0x24(%ebp)
f0104ddc:	ff 75 d8             	push   -0x28(%ebp)
f0104ddf:	e8 7c 12 00 00       	call   f0106060 <__umoddi3>
f0104de4:	83 c4 14             	add    $0x14,%esp
f0104de7:	0f be 80 fe 78 10 f0 	movsbl -0xfef8702(%eax),%eax
f0104dee:	50                   	push   %eax
f0104def:	ff d7                	call   *%edi
}
f0104df1:	83 c4 10             	add    $0x10,%esp
f0104df4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104df7:	5b                   	pop    %ebx
f0104df8:	5e                   	pop    %esi
f0104df9:	5f                   	pop    %edi
f0104dfa:	5d                   	pop    %ebp
f0104dfb:	c3                   	ret    

f0104dfc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104dfc:	55                   	push   %ebp
f0104dfd:	89 e5                	mov    %esp,%ebp
f0104dff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104e02:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104e06:	8b 10                	mov    (%eax),%edx
f0104e08:	3b 50 04             	cmp    0x4(%eax),%edx
f0104e0b:	73 0a                	jae    f0104e17 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104e0d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104e10:	89 08                	mov    %ecx,(%eax)
f0104e12:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e15:	88 02                	mov    %al,(%edx)
}
f0104e17:	5d                   	pop    %ebp
f0104e18:	c3                   	ret    

f0104e19 <printfmt>:
{
f0104e19:	55                   	push   %ebp
f0104e1a:	89 e5                	mov    %esp,%ebp
f0104e1c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104e1f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104e22:	50                   	push   %eax
f0104e23:	ff 75 10             	push   0x10(%ebp)
f0104e26:	ff 75 0c             	push   0xc(%ebp)
f0104e29:	ff 75 08             	push   0x8(%ebp)
f0104e2c:	e8 05 00 00 00       	call   f0104e36 <vprintfmt>
}
f0104e31:	83 c4 10             	add    $0x10,%esp
f0104e34:	c9                   	leave  
f0104e35:	c3                   	ret    

f0104e36 <vprintfmt>:
{
f0104e36:	55                   	push   %ebp
f0104e37:	89 e5                	mov    %esp,%ebp
f0104e39:	57                   	push   %edi
f0104e3a:	56                   	push   %esi
f0104e3b:	53                   	push   %ebx
f0104e3c:	83 ec 3c             	sub    $0x3c,%esp
f0104e3f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e45:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e48:	eb 0a                	jmp    f0104e54 <vprintfmt+0x1e>
			putch(ch, putdat);
f0104e4a:	83 ec 08             	sub    $0x8,%esp
f0104e4d:	53                   	push   %ebx
f0104e4e:	50                   	push   %eax
f0104e4f:	ff d6                	call   *%esi
f0104e51:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104e54:	83 c7 01             	add    $0x1,%edi
f0104e57:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104e5b:	83 f8 25             	cmp    $0x25,%eax
f0104e5e:	74 0c                	je     f0104e6c <vprintfmt+0x36>
			if (ch == '\0')
f0104e60:	85 c0                	test   %eax,%eax
f0104e62:	75 e6                	jne    f0104e4a <vprintfmt+0x14>
}
f0104e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e67:	5b                   	pop    %ebx
f0104e68:	5e                   	pop    %esi
f0104e69:	5f                   	pop    %edi
f0104e6a:	5d                   	pop    %ebp
f0104e6b:	c3                   	ret    
		padc = ' ';
f0104e6c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0104e70:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0104e77:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0104e7e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104e85:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104e8a:	8d 47 01             	lea    0x1(%edi),%eax
f0104e8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104e90:	0f b6 17             	movzbl (%edi),%edx
f0104e93:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104e96:	3c 55                	cmp    $0x55,%al
f0104e98:	0f 87 bb 03 00 00    	ja     f0105259 <vprintfmt+0x423>
f0104e9e:	0f b6 c0             	movzbl %al,%eax
f0104ea1:	ff 24 85 c0 79 10 f0 	jmp    *-0xfef8640(,%eax,4)
f0104ea8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104eab:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0104eaf:	eb d9                	jmp    f0104e8a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104eb1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104eb4:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0104eb8:	eb d0                	jmp    f0104e8a <vprintfmt+0x54>
f0104eba:	0f b6 d2             	movzbl %dl,%edx
f0104ebd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104ec0:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ec5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104ec8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104ecb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104ecf:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104ed2:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104ed5:	83 f9 09             	cmp    $0x9,%ecx
f0104ed8:	77 55                	ja     f0104f2f <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
f0104eda:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104edd:	eb e9                	jmp    f0104ec8 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f0104edf:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ee2:	8b 00                	mov    (%eax),%eax
f0104ee4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ee7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eea:	8d 40 04             	lea    0x4(%eax),%eax
f0104eed:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104ef0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104ef3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ef7:	79 91                	jns    f0104e8a <vprintfmt+0x54>
				width = precision, precision = -1;
f0104ef9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104efc:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104eff:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104f06:	eb 82                	jmp    f0104e8a <vprintfmt+0x54>
f0104f08:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104f0b:	85 d2                	test   %edx,%edx
f0104f0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f12:	0f 49 c2             	cmovns %edx,%eax
f0104f15:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104f18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104f1b:	e9 6a ff ff ff       	jmp    f0104e8a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f0104f20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104f23:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0104f2a:	e9 5b ff ff ff       	jmp    f0104e8a <vprintfmt+0x54>
f0104f2f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104f32:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f35:	eb bc                	jmp    f0104ef3 <vprintfmt+0xbd>
			lflag++;
f0104f37:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104f3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104f3d:	e9 48 ff ff ff       	jmp    f0104e8a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f0104f42:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f45:	8d 78 04             	lea    0x4(%eax),%edi
f0104f48:	83 ec 08             	sub    $0x8,%esp
f0104f4b:	53                   	push   %ebx
f0104f4c:	ff 30                	push   (%eax)
f0104f4e:	ff d6                	call   *%esi
			break;
f0104f50:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104f53:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104f56:	e9 9d 02 00 00       	jmp    f01051f8 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
f0104f5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f5e:	8d 78 04             	lea    0x4(%eax),%edi
f0104f61:	8b 10                	mov    (%eax),%edx
f0104f63:	89 d0                	mov    %edx,%eax
f0104f65:	f7 d8                	neg    %eax
f0104f67:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104f6a:	83 f8 08             	cmp    $0x8,%eax
f0104f6d:	7f 23                	jg     f0104f92 <vprintfmt+0x15c>
f0104f6f:	8b 14 85 20 7b 10 f0 	mov    -0xfef84e0(,%eax,4),%edx
f0104f76:	85 d2                	test   %edx,%edx
f0104f78:	74 18                	je     f0104f92 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
f0104f7a:	52                   	push   %edx
f0104f7b:	68 e0 70 10 f0       	push   $0xf01070e0
f0104f80:	53                   	push   %ebx
f0104f81:	56                   	push   %esi
f0104f82:	e8 92 fe ff ff       	call   f0104e19 <printfmt>
f0104f87:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104f8a:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104f8d:	e9 66 02 00 00       	jmp    f01051f8 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
f0104f92:	50                   	push   %eax
f0104f93:	68 16 79 10 f0       	push   $0xf0107916
f0104f98:	53                   	push   %ebx
f0104f99:	56                   	push   %esi
f0104f9a:	e8 7a fe ff ff       	call   f0104e19 <printfmt>
f0104f9f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104fa2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104fa5:	e9 4e 02 00 00       	jmp    f01051f8 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
f0104faa:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fad:	83 c0 04             	add    $0x4,%eax
f0104fb0:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104fb3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fb6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0104fb8:	85 d2                	test   %edx,%edx
f0104fba:	b8 0f 79 10 f0       	mov    $0xf010790f,%eax
f0104fbf:	0f 45 c2             	cmovne %edx,%eax
f0104fc2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0104fc5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104fc9:	7e 06                	jle    f0104fd1 <vprintfmt+0x19b>
f0104fcb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0104fcf:	75 0d                	jne    f0104fde <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104fd1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104fd4:	89 c7                	mov    %eax,%edi
f0104fd6:	03 45 e0             	add    -0x20(%ebp),%eax
f0104fd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104fdc:	eb 55                	jmp    f0105033 <vprintfmt+0x1fd>
f0104fde:	83 ec 08             	sub    $0x8,%esp
f0104fe1:	ff 75 d8             	push   -0x28(%ebp)
f0104fe4:	ff 75 cc             	push   -0x34(%ebp)
f0104fe7:	e8 ec 03 00 00       	call   f01053d8 <strnlen>
f0104fec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104fef:	29 c1                	sub    %eax,%ecx
f0104ff1:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0104ff4:	83 c4 10             	add    $0x10,%esp
f0104ff7:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
f0104ff9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0104ffd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105000:	eb 0f                	jmp    f0105011 <vprintfmt+0x1db>
					putch(padc, putdat);
f0105002:	83 ec 08             	sub    $0x8,%esp
f0105005:	53                   	push   %ebx
f0105006:	ff 75 e0             	push   -0x20(%ebp)
f0105009:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010500b:	83 ef 01             	sub    $0x1,%edi
f010500e:	83 c4 10             	add    $0x10,%esp
f0105011:	85 ff                	test   %edi,%edi
f0105013:	7f ed                	jg     f0105002 <vprintfmt+0x1cc>
f0105015:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105018:	85 d2                	test   %edx,%edx
f010501a:	b8 00 00 00 00       	mov    $0x0,%eax
f010501f:	0f 49 c2             	cmovns %edx,%eax
f0105022:	29 c2                	sub    %eax,%edx
f0105024:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105027:	eb a8                	jmp    f0104fd1 <vprintfmt+0x19b>
					putch(ch, putdat);
f0105029:	83 ec 08             	sub    $0x8,%esp
f010502c:	53                   	push   %ebx
f010502d:	52                   	push   %edx
f010502e:	ff d6                	call   *%esi
f0105030:	83 c4 10             	add    $0x10,%esp
f0105033:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105036:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105038:	83 c7 01             	add    $0x1,%edi
f010503b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010503f:	0f be d0             	movsbl %al,%edx
f0105042:	85 d2                	test   %edx,%edx
f0105044:	74 4b                	je     f0105091 <vprintfmt+0x25b>
f0105046:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010504a:	78 06                	js     f0105052 <vprintfmt+0x21c>
f010504c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0105050:	78 1e                	js     f0105070 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
f0105052:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105056:	74 d1                	je     f0105029 <vprintfmt+0x1f3>
f0105058:	0f be c0             	movsbl %al,%eax
f010505b:	83 e8 20             	sub    $0x20,%eax
f010505e:	83 f8 5e             	cmp    $0x5e,%eax
f0105061:	76 c6                	jbe    f0105029 <vprintfmt+0x1f3>
					putch('?', putdat);
f0105063:	83 ec 08             	sub    $0x8,%esp
f0105066:	53                   	push   %ebx
f0105067:	6a 3f                	push   $0x3f
f0105069:	ff d6                	call   *%esi
f010506b:	83 c4 10             	add    $0x10,%esp
f010506e:	eb c3                	jmp    f0105033 <vprintfmt+0x1fd>
f0105070:	89 cf                	mov    %ecx,%edi
f0105072:	eb 0e                	jmp    f0105082 <vprintfmt+0x24c>
				putch(' ', putdat);
f0105074:	83 ec 08             	sub    $0x8,%esp
f0105077:	53                   	push   %ebx
f0105078:	6a 20                	push   $0x20
f010507a:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010507c:	83 ef 01             	sub    $0x1,%edi
f010507f:	83 c4 10             	add    $0x10,%esp
f0105082:	85 ff                	test   %edi,%edi
f0105084:	7f ee                	jg     f0105074 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
f0105086:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105089:	89 45 14             	mov    %eax,0x14(%ebp)
f010508c:	e9 67 01 00 00       	jmp    f01051f8 <vprintfmt+0x3c2>
f0105091:	89 cf                	mov    %ecx,%edi
f0105093:	eb ed                	jmp    f0105082 <vprintfmt+0x24c>
	if (lflag >= 2)
f0105095:	83 f9 01             	cmp    $0x1,%ecx
f0105098:	7f 1b                	jg     f01050b5 <vprintfmt+0x27f>
	else if (lflag)
f010509a:	85 c9                	test   %ecx,%ecx
f010509c:	74 63                	je     f0105101 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
f010509e:	8b 45 14             	mov    0x14(%ebp),%eax
f01050a1:	8b 00                	mov    (%eax),%eax
f01050a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01050a6:	99                   	cltd   
f01050a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01050aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01050ad:	8d 40 04             	lea    0x4(%eax),%eax
f01050b0:	89 45 14             	mov    %eax,0x14(%ebp)
f01050b3:	eb 17                	jmp    f01050cc <vprintfmt+0x296>
		return va_arg(*ap, long long);
f01050b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01050b8:	8b 50 04             	mov    0x4(%eax),%edx
f01050bb:	8b 00                	mov    (%eax),%eax
f01050bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01050c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01050c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01050c6:	8d 40 08             	lea    0x8(%eax),%eax
f01050c9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01050cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01050cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01050d2:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
f01050d7:	85 c9                	test   %ecx,%ecx
f01050d9:	0f 89 ff 00 00 00    	jns    f01051de <vprintfmt+0x3a8>
				putch('-', putdat);
f01050df:	83 ec 08             	sub    $0x8,%esp
f01050e2:	53                   	push   %ebx
f01050e3:	6a 2d                	push   $0x2d
f01050e5:	ff d6                	call   *%esi
				num = -(long long) num;
f01050e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01050ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01050ed:	f7 da                	neg    %edx
f01050ef:	83 d1 00             	adc    $0x0,%ecx
f01050f2:	f7 d9                	neg    %ecx
f01050f4:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01050f7:	bf 0a 00 00 00       	mov    $0xa,%edi
f01050fc:	e9 dd 00 00 00       	jmp    f01051de <vprintfmt+0x3a8>
		return va_arg(*ap, int);
f0105101:	8b 45 14             	mov    0x14(%ebp),%eax
f0105104:	8b 00                	mov    (%eax),%eax
f0105106:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105109:	99                   	cltd   
f010510a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010510d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105110:	8d 40 04             	lea    0x4(%eax),%eax
f0105113:	89 45 14             	mov    %eax,0x14(%ebp)
f0105116:	eb b4                	jmp    f01050cc <vprintfmt+0x296>
	if (lflag >= 2)
f0105118:	83 f9 01             	cmp    $0x1,%ecx
f010511b:	7f 1e                	jg     f010513b <vprintfmt+0x305>
	else if (lflag)
f010511d:	85 c9                	test   %ecx,%ecx
f010511f:	74 32                	je     f0105153 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
f0105121:	8b 45 14             	mov    0x14(%ebp),%eax
f0105124:	8b 10                	mov    (%eax),%edx
f0105126:	b9 00 00 00 00       	mov    $0x0,%ecx
f010512b:	8d 40 04             	lea    0x4(%eax),%eax
f010512e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105131:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
f0105136:	e9 a3 00 00 00       	jmp    f01051de <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f010513b:	8b 45 14             	mov    0x14(%ebp),%eax
f010513e:	8b 10                	mov    (%eax),%edx
f0105140:	8b 48 04             	mov    0x4(%eax),%ecx
f0105143:	8d 40 08             	lea    0x8(%eax),%eax
f0105146:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105149:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
f010514e:	e9 8b 00 00 00       	jmp    f01051de <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f0105153:	8b 45 14             	mov    0x14(%ebp),%eax
f0105156:	8b 10                	mov    (%eax),%edx
f0105158:	b9 00 00 00 00       	mov    $0x0,%ecx
f010515d:	8d 40 04             	lea    0x4(%eax),%eax
f0105160:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105163:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
f0105168:	eb 74                	jmp    f01051de <vprintfmt+0x3a8>
	if (lflag >= 2)
f010516a:	83 f9 01             	cmp    $0x1,%ecx
f010516d:	7f 1b                	jg     f010518a <vprintfmt+0x354>
	else if (lflag)
f010516f:	85 c9                	test   %ecx,%ecx
f0105171:	74 2c                	je     f010519f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
f0105173:	8b 45 14             	mov    0x14(%ebp),%eax
f0105176:	8b 10                	mov    (%eax),%edx
f0105178:	b9 00 00 00 00       	mov    $0x0,%ecx
f010517d:	8d 40 04             	lea    0x4(%eax),%eax
f0105180:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105183:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
f0105188:	eb 54                	jmp    f01051de <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f010518a:	8b 45 14             	mov    0x14(%ebp),%eax
f010518d:	8b 10                	mov    (%eax),%edx
f010518f:	8b 48 04             	mov    0x4(%eax),%ecx
f0105192:	8d 40 08             	lea    0x8(%eax),%eax
f0105195:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105198:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
f010519d:	eb 3f                	jmp    f01051de <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f010519f:	8b 45 14             	mov    0x14(%ebp),%eax
f01051a2:	8b 10                	mov    (%eax),%edx
f01051a4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01051a9:	8d 40 04             	lea    0x4(%eax),%eax
f01051ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01051af:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
f01051b4:	eb 28                	jmp    f01051de <vprintfmt+0x3a8>
			putch('0', putdat);
f01051b6:	83 ec 08             	sub    $0x8,%esp
f01051b9:	53                   	push   %ebx
f01051ba:	6a 30                	push   $0x30
f01051bc:	ff d6                	call   *%esi
			putch('x', putdat);
f01051be:	83 c4 08             	add    $0x8,%esp
f01051c1:	53                   	push   %ebx
f01051c2:	6a 78                	push   $0x78
f01051c4:	ff d6                	call   *%esi
			num = (unsigned long long)
f01051c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c9:	8b 10                	mov    (%eax),%edx
f01051cb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01051d0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01051d3:	8d 40 04             	lea    0x4(%eax),%eax
f01051d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01051d9:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
f01051de:	83 ec 0c             	sub    $0xc,%esp
f01051e1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01051e5:	50                   	push   %eax
f01051e6:	ff 75 e0             	push   -0x20(%ebp)
f01051e9:	57                   	push   %edi
f01051ea:	51                   	push   %ecx
f01051eb:	52                   	push   %edx
f01051ec:	89 da                	mov    %ebx,%edx
f01051ee:	89 f0                	mov    %esi,%eax
f01051f0:	e8 5e fb ff ff       	call   f0104d53 <printnum>
			break;
f01051f5:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01051f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01051fb:	e9 54 fc ff ff       	jmp    f0104e54 <vprintfmt+0x1e>
	if (lflag >= 2)
f0105200:	83 f9 01             	cmp    $0x1,%ecx
f0105203:	7f 1b                	jg     f0105220 <vprintfmt+0x3ea>
	else if (lflag)
f0105205:	85 c9                	test   %ecx,%ecx
f0105207:	74 2c                	je     f0105235 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
f0105209:	8b 45 14             	mov    0x14(%ebp),%eax
f010520c:	8b 10                	mov    (%eax),%edx
f010520e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105213:	8d 40 04             	lea    0x4(%eax),%eax
f0105216:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105219:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
f010521e:	eb be                	jmp    f01051de <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0105220:	8b 45 14             	mov    0x14(%ebp),%eax
f0105223:	8b 10                	mov    (%eax),%edx
f0105225:	8b 48 04             	mov    0x4(%eax),%ecx
f0105228:	8d 40 08             	lea    0x8(%eax),%eax
f010522b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010522e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
f0105233:	eb a9                	jmp    f01051de <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f0105235:	8b 45 14             	mov    0x14(%ebp),%eax
f0105238:	8b 10                	mov    (%eax),%edx
f010523a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010523f:	8d 40 04             	lea    0x4(%eax),%eax
f0105242:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105245:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
f010524a:	eb 92                	jmp    f01051de <vprintfmt+0x3a8>
			putch(ch, putdat);
f010524c:	83 ec 08             	sub    $0x8,%esp
f010524f:	53                   	push   %ebx
f0105250:	6a 25                	push   $0x25
f0105252:	ff d6                	call   *%esi
			break;
f0105254:	83 c4 10             	add    $0x10,%esp
f0105257:	eb 9f                	jmp    f01051f8 <vprintfmt+0x3c2>
			putch('%', putdat);
f0105259:	83 ec 08             	sub    $0x8,%esp
f010525c:	53                   	push   %ebx
f010525d:	6a 25                	push   $0x25
f010525f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105261:	83 c4 10             	add    $0x10,%esp
f0105264:	89 f8                	mov    %edi,%eax
f0105266:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010526a:	74 05                	je     f0105271 <vprintfmt+0x43b>
f010526c:	83 e8 01             	sub    $0x1,%eax
f010526f:	eb f5                	jmp    f0105266 <vprintfmt+0x430>
f0105271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105274:	eb 82                	jmp    f01051f8 <vprintfmt+0x3c2>

f0105276 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105276:	55                   	push   %ebp
f0105277:	89 e5                	mov    %esp,%ebp
f0105279:	83 ec 18             	sub    $0x18,%esp
f010527c:	8b 45 08             	mov    0x8(%ebp),%eax
f010527f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105282:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105285:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105289:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010528c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105293:	85 c0                	test   %eax,%eax
f0105295:	74 26                	je     f01052bd <vsnprintf+0x47>
f0105297:	85 d2                	test   %edx,%edx
f0105299:	7e 22                	jle    f01052bd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010529b:	ff 75 14             	push   0x14(%ebp)
f010529e:	ff 75 10             	push   0x10(%ebp)
f01052a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01052a4:	50                   	push   %eax
f01052a5:	68 fc 4d 10 f0       	push   $0xf0104dfc
f01052aa:	e8 87 fb ff ff       	call   f0104e36 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01052af:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01052b2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01052b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052b8:	83 c4 10             	add    $0x10,%esp
}
f01052bb:	c9                   	leave  
f01052bc:	c3                   	ret    
		return -E_INVAL;
f01052bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01052c2:	eb f7                	jmp    f01052bb <vsnprintf+0x45>

f01052c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01052c4:	55                   	push   %ebp
f01052c5:	89 e5                	mov    %esp,%ebp
f01052c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01052ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01052cd:	50                   	push   %eax
f01052ce:	ff 75 10             	push   0x10(%ebp)
f01052d1:	ff 75 0c             	push   0xc(%ebp)
f01052d4:	ff 75 08             	push   0x8(%ebp)
f01052d7:	e8 9a ff ff ff       	call   f0105276 <vsnprintf>
	va_end(ap);

	return rc;
}
f01052dc:	c9                   	leave  
f01052dd:	c3                   	ret    

f01052de <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01052de:	55                   	push   %ebp
f01052df:	89 e5                	mov    %esp,%ebp
f01052e1:	57                   	push   %edi
f01052e2:	56                   	push   %esi
f01052e3:	53                   	push   %ebx
f01052e4:	83 ec 0c             	sub    $0xc,%esp
f01052e7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01052ea:	85 c0                	test   %eax,%eax
f01052ec:	74 11                	je     f01052ff <readline+0x21>
		cprintf("%s", prompt);
f01052ee:	83 ec 08             	sub    $0x8,%esp
f01052f1:	50                   	push   %eax
f01052f2:	68 e0 70 10 f0       	push   $0xf01070e0
f01052f7:	e8 36 e6 ff ff       	call   f0103932 <cprintf>
f01052fc:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01052ff:	83 ec 0c             	sub    $0xc,%esp
f0105302:	6a 00                	push   $0x0
f0105304:	e8 60 b4 ff ff       	call   f0100769 <iscons>
f0105309:	89 c7                	mov    %eax,%edi
f010530b:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010530e:	be 00 00 00 00       	mov    $0x0,%esi
f0105313:	eb 3f                	jmp    f0105354 <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0105315:	83 ec 08             	sub    $0x8,%esp
f0105318:	50                   	push   %eax
f0105319:	68 44 7b 10 f0       	push   $0xf0107b44
f010531e:	e8 0f e6 ff ff       	call   f0103932 <cprintf>
			return NULL;
f0105323:	83 c4 10             	add    $0x10,%esp
f0105326:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010532b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010532e:	5b                   	pop    %ebx
f010532f:	5e                   	pop    %esi
f0105330:	5f                   	pop    %edi
f0105331:	5d                   	pop    %ebp
f0105332:	c3                   	ret    
			if (echoing)
f0105333:	85 ff                	test   %edi,%edi
f0105335:	75 05                	jne    f010533c <readline+0x5e>
			i--;
f0105337:	83 ee 01             	sub    $0x1,%esi
f010533a:	eb 18                	jmp    f0105354 <readline+0x76>
				cputchar('\b');
f010533c:	83 ec 0c             	sub    $0xc,%esp
f010533f:	6a 08                	push   $0x8
f0105341:	e8 02 b4 ff ff       	call   f0100748 <cputchar>
f0105346:	83 c4 10             	add    $0x10,%esp
f0105349:	eb ec                	jmp    f0105337 <readline+0x59>
			buf[i++] = c;
f010534b:	88 9e a0 7a 21 f0    	mov    %bl,-0xfde8560(%esi)
f0105351:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105354:	e8 ff b3 ff ff       	call   f0100758 <getchar>
f0105359:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010535b:	85 c0                	test   %eax,%eax
f010535d:	78 b6                	js     f0105315 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010535f:	83 f8 08             	cmp    $0x8,%eax
f0105362:	0f 94 c0             	sete   %al
f0105365:	83 fb 7f             	cmp    $0x7f,%ebx
f0105368:	0f 94 c2             	sete   %dl
f010536b:	08 d0                	or     %dl,%al
f010536d:	74 04                	je     f0105373 <readline+0x95>
f010536f:	85 f6                	test   %esi,%esi
f0105371:	7f c0                	jg     f0105333 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105373:	83 fb 1f             	cmp    $0x1f,%ebx
f0105376:	7e 1a                	jle    f0105392 <readline+0xb4>
f0105378:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010537e:	7f 12                	jg     f0105392 <readline+0xb4>
			if (echoing)
f0105380:	85 ff                	test   %edi,%edi
f0105382:	74 c7                	je     f010534b <readline+0x6d>
				cputchar(c);
f0105384:	83 ec 0c             	sub    $0xc,%esp
f0105387:	53                   	push   %ebx
f0105388:	e8 bb b3 ff ff       	call   f0100748 <cputchar>
f010538d:	83 c4 10             	add    $0x10,%esp
f0105390:	eb b9                	jmp    f010534b <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f0105392:	83 fb 0a             	cmp    $0xa,%ebx
f0105395:	74 05                	je     f010539c <readline+0xbe>
f0105397:	83 fb 0d             	cmp    $0xd,%ebx
f010539a:	75 b8                	jne    f0105354 <readline+0x76>
			if (echoing)
f010539c:	85 ff                	test   %edi,%edi
f010539e:	75 11                	jne    f01053b1 <readline+0xd3>
			buf[i] = 0;
f01053a0:	c6 86 a0 7a 21 f0 00 	movb   $0x0,-0xfde8560(%esi)
			return buf;
f01053a7:	b8 a0 7a 21 f0       	mov    $0xf0217aa0,%eax
f01053ac:	e9 7a ff ff ff       	jmp    f010532b <readline+0x4d>
				cputchar('\n');
f01053b1:	83 ec 0c             	sub    $0xc,%esp
f01053b4:	6a 0a                	push   $0xa
f01053b6:	e8 8d b3 ff ff       	call   f0100748 <cputchar>
f01053bb:	83 c4 10             	add    $0x10,%esp
f01053be:	eb e0                	jmp    f01053a0 <readline+0xc2>

f01053c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01053c0:	55                   	push   %ebp
f01053c1:	89 e5                	mov    %esp,%ebp
f01053c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01053c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01053cb:	eb 03                	jmp    f01053d0 <strlen+0x10>
		n++;
f01053cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01053d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01053d4:	75 f7                	jne    f01053cd <strlen+0xd>
	return n;
}
f01053d6:	5d                   	pop    %ebp
f01053d7:	c3                   	ret    

f01053d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01053d8:	55                   	push   %ebp
f01053d9:	89 e5                	mov    %esp,%ebp
f01053db:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01053e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01053e6:	eb 03                	jmp    f01053eb <strnlen+0x13>
		n++;
f01053e8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01053eb:	39 d0                	cmp    %edx,%eax
f01053ed:	74 08                	je     f01053f7 <strnlen+0x1f>
f01053ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01053f3:	75 f3                	jne    f01053e8 <strnlen+0x10>
f01053f5:	89 c2                	mov    %eax,%edx
	return n;
}
f01053f7:	89 d0                	mov    %edx,%eax
f01053f9:	5d                   	pop    %ebp
f01053fa:	c3                   	ret    

f01053fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01053fb:	55                   	push   %ebp
f01053fc:	89 e5                	mov    %esp,%ebp
f01053fe:	53                   	push   %ebx
f01053ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105402:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105405:	b8 00 00 00 00       	mov    $0x0,%eax
f010540a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f010540e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105411:	83 c0 01             	add    $0x1,%eax
f0105414:	84 d2                	test   %dl,%dl
f0105416:	75 f2                	jne    f010540a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105418:	89 c8                	mov    %ecx,%eax
f010541a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010541d:	c9                   	leave  
f010541e:	c3                   	ret    

f010541f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010541f:	55                   	push   %ebp
f0105420:	89 e5                	mov    %esp,%ebp
f0105422:	53                   	push   %ebx
f0105423:	83 ec 10             	sub    $0x10,%esp
f0105426:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105429:	53                   	push   %ebx
f010542a:	e8 91 ff ff ff       	call   f01053c0 <strlen>
f010542f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105432:	ff 75 0c             	push   0xc(%ebp)
f0105435:	01 d8                	add    %ebx,%eax
f0105437:	50                   	push   %eax
f0105438:	e8 be ff ff ff       	call   f01053fb <strcpy>
	return dst;
}
f010543d:	89 d8                	mov    %ebx,%eax
f010543f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105442:	c9                   	leave  
f0105443:	c3                   	ret    

f0105444 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105444:	55                   	push   %ebp
f0105445:	89 e5                	mov    %esp,%ebp
f0105447:	56                   	push   %esi
f0105448:	53                   	push   %ebx
f0105449:	8b 75 08             	mov    0x8(%ebp),%esi
f010544c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010544f:	89 f3                	mov    %esi,%ebx
f0105451:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105454:	89 f0                	mov    %esi,%eax
f0105456:	eb 0f                	jmp    f0105467 <strncpy+0x23>
		*dst++ = *src;
f0105458:	83 c0 01             	add    $0x1,%eax
f010545b:	0f b6 0a             	movzbl (%edx),%ecx
f010545e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105461:	80 f9 01             	cmp    $0x1,%cl
f0105464:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0105467:	39 d8                	cmp    %ebx,%eax
f0105469:	75 ed                	jne    f0105458 <strncpy+0x14>
	}
	return ret;
}
f010546b:	89 f0                	mov    %esi,%eax
f010546d:	5b                   	pop    %ebx
f010546e:	5e                   	pop    %esi
f010546f:	5d                   	pop    %ebp
f0105470:	c3                   	ret    

f0105471 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105471:	55                   	push   %ebp
f0105472:	89 e5                	mov    %esp,%ebp
f0105474:	56                   	push   %esi
f0105475:	53                   	push   %ebx
f0105476:	8b 75 08             	mov    0x8(%ebp),%esi
f0105479:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010547c:	8b 55 10             	mov    0x10(%ebp),%edx
f010547f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105481:	85 d2                	test   %edx,%edx
f0105483:	74 21                	je     f01054a6 <strlcpy+0x35>
f0105485:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105489:	89 f2                	mov    %esi,%edx
f010548b:	eb 09                	jmp    f0105496 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010548d:	83 c1 01             	add    $0x1,%ecx
f0105490:	83 c2 01             	add    $0x1,%edx
f0105493:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0105496:	39 c2                	cmp    %eax,%edx
f0105498:	74 09                	je     f01054a3 <strlcpy+0x32>
f010549a:	0f b6 19             	movzbl (%ecx),%ebx
f010549d:	84 db                	test   %bl,%bl
f010549f:	75 ec                	jne    f010548d <strlcpy+0x1c>
f01054a1:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01054a3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01054a6:	29 f0                	sub    %esi,%eax
}
f01054a8:	5b                   	pop    %ebx
f01054a9:	5e                   	pop    %esi
f01054aa:	5d                   	pop    %ebp
f01054ab:	c3                   	ret    

f01054ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01054ac:	55                   	push   %ebp
f01054ad:	89 e5                	mov    %esp,%ebp
f01054af:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01054b5:	eb 06                	jmp    f01054bd <strcmp+0x11>
		p++, q++;
f01054b7:	83 c1 01             	add    $0x1,%ecx
f01054ba:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01054bd:	0f b6 01             	movzbl (%ecx),%eax
f01054c0:	84 c0                	test   %al,%al
f01054c2:	74 04                	je     f01054c8 <strcmp+0x1c>
f01054c4:	3a 02                	cmp    (%edx),%al
f01054c6:	74 ef                	je     f01054b7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01054c8:	0f b6 c0             	movzbl %al,%eax
f01054cb:	0f b6 12             	movzbl (%edx),%edx
f01054ce:	29 d0                	sub    %edx,%eax
}
f01054d0:	5d                   	pop    %ebp
f01054d1:	c3                   	ret    

f01054d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01054d2:	55                   	push   %ebp
f01054d3:	89 e5                	mov    %esp,%ebp
f01054d5:	53                   	push   %ebx
f01054d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01054d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054dc:	89 c3                	mov    %eax,%ebx
f01054de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01054e1:	eb 06                	jmp    f01054e9 <strncmp+0x17>
		n--, p++, q++;
f01054e3:	83 c0 01             	add    $0x1,%eax
f01054e6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01054e9:	39 d8                	cmp    %ebx,%eax
f01054eb:	74 18                	je     f0105505 <strncmp+0x33>
f01054ed:	0f b6 08             	movzbl (%eax),%ecx
f01054f0:	84 c9                	test   %cl,%cl
f01054f2:	74 04                	je     f01054f8 <strncmp+0x26>
f01054f4:	3a 0a                	cmp    (%edx),%cl
f01054f6:	74 eb                	je     f01054e3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01054f8:	0f b6 00             	movzbl (%eax),%eax
f01054fb:	0f b6 12             	movzbl (%edx),%edx
f01054fe:	29 d0                	sub    %edx,%eax
}
f0105500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105503:	c9                   	leave  
f0105504:	c3                   	ret    
		return 0;
f0105505:	b8 00 00 00 00       	mov    $0x0,%eax
f010550a:	eb f4                	jmp    f0105500 <strncmp+0x2e>

f010550c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010550c:	55                   	push   %ebp
f010550d:	89 e5                	mov    %esp,%ebp
f010550f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105512:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105516:	eb 03                	jmp    f010551b <strchr+0xf>
f0105518:	83 c0 01             	add    $0x1,%eax
f010551b:	0f b6 10             	movzbl (%eax),%edx
f010551e:	84 d2                	test   %dl,%dl
f0105520:	74 06                	je     f0105528 <strchr+0x1c>
		if (*s == c)
f0105522:	38 ca                	cmp    %cl,%dl
f0105524:	75 f2                	jne    f0105518 <strchr+0xc>
f0105526:	eb 05                	jmp    f010552d <strchr+0x21>
			return (char *) s;
	return 0;
f0105528:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010552d:	5d                   	pop    %ebp
f010552e:	c3                   	ret    

f010552f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010552f:	55                   	push   %ebp
f0105530:	89 e5                	mov    %esp,%ebp
f0105532:	8b 45 08             	mov    0x8(%ebp),%eax
f0105535:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105539:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010553c:	38 ca                	cmp    %cl,%dl
f010553e:	74 09                	je     f0105549 <strfind+0x1a>
f0105540:	84 d2                	test   %dl,%dl
f0105542:	74 05                	je     f0105549 <strfind+0x1a>
	for (; *s; s++)
f0105544:	83 c0 01             	add    $0x1,%eax
f0105547:	eb f0                	jmp    f0105539 <strfind+0xa>
			break;
	return (char *) s;
}
f0105549:	5d                   	pop    %ebp
f010554a:	c3                   	ret    

f010554b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010554b:	55                   	push   %ebp
f010554c:	89 e5                	mov    %esp,%ebp
f010554e:	57                   	push   %edi
f010554f:	56                   	push   %esi
f0105550:	53                   	push   %ebx
f0105551:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105554:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105557:	85 c9                	test   %ecx,%ecx
f0105559:	74 2f                	je     f010558a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010555b:	89 f8                	mov    %edi,%eax
f010555d:	09 c8                	or     %ecx,%eax
f010555f:	a8 03                	test   $0x3,%al
f0105561:	75 21                	jne    f0105584 <memset+0x39>
		c &= 0xFF;
f0105563:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105567:	89 d0                	mov    %edx,%eax
f0105569:	c1 e0 08             	shl    $0x8,%eax
f010556c:	89 d3                	mov    %edx,%ebx
f010556e:	c1 e3 18             	shl    $0x18,%ebx
f0105571:	89 d6                	mov    %edx,%esi
f0105573:	c1 e6 10             	shl    $0x10,%esi
f0105576:	09 f3                	or     %esi,%ebx
f0105578:	09 da                	or     %ebx,%edx
f010557a:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010557c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010557f:	fc                   	cld    
f0105580:	f3 ab                	rep stos %eax,%es:(%edi)
f0105582:	eb 06                	jmp    f010558a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105584:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105587:	fc                   	cld    
f0105588:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010558a:	89 f8                	mov    %edi,%eax
f010558c:	5b                   	pop    %ebx
f010558d:	5e                   	pop    %esi
f010558e:	5f                   	pop    %edi
f010558f:	5d                   	pop    %ebp
f0105590:	c3                   	ret    

f0105591 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105591:	55                   	push   %ebp
f0105592:	89 e5                	mov    %esp,%ebp
f0105594:	57                   	push   %edi
f0105595:	56                   	push   %esi
f0105596:	8b 45 08             	mov    0x8(%ebp),%eax
f0105599:	8b 75 0c             	mov    0xc(%ebp),%esi
f010559c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010559f:	39 c6                	cmp    %eax,%esi
f01055a1:	73 32                	jae    f01055d5 <memmove+0x44>
f01055a3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01055a6:	39 c2                	cmp    %eax,%edx
f01055a8:	76 2b                	jbe    f01055d5 <memmove+0x44>
		s += n;
		d += n;
f01055aa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055ad:	89 d6                	mov    %edx,%esi
f01055af:	09 fe                	or     %edi,%esi
f01055b1:	09 ce                	or     %ecx,%esi
f01055b3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01055b9:	75 0e                	jne    f01055c9 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01055bb:	83 ef 04             	sub    $0x4,%edi
f01055be:	8d 72 fc             	lea    -0x4(%edx),%esi
f01055c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01055c4:	fd                   	std    
f01055c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01055c7:	eb 09                	jmp    f01055d2 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01055c9:	83 ef 01             	sub    $0x1,%edi
f01055cc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01055cf:	fd                   	std    
f01055d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01055d2:	fc                   	cld    
f01055d3:	eb 1a                	jmp    f01055ef <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055d5:	89 f2                	mov    %esi,%edx
f01055d7:	09 c2                	or     %eax,%edx
f01055d9:	09 ca                	or     %ecx,%edx
f01055db:	f6 c2 03             	test   $0x3,%dl
f01055de:	75 0a                	jne    f01055ea <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01055e0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01055e3:	89 c7                	mov    %eax,%edi
f01055e5:	fc                   	cld    
f01055e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01055e8:	eb 05                	jmp    f01055ef <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01055ea:	89 c7                	mov    %eax,%edi
f01055ec:	fc                   	cld    
f01055ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01055ef:	5e                   	pop    %esi
f01055f0:	5f                   	pop    %edi
f01055f1:	5d                   	pop    %ebp
f01055f2:	c3                   	ret    

f01055f3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01055f3:	55                   	push   %ebp
f01055f4:	89 e5                	mov    %esp,%ebp
f01055f6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01055f9:	ff 75 10             	push   0x10(%ebp)
f01055fc:	ff 75 0c             	push   0xc(%ebp)
f01055ff:	ff 75 08             	push   0x8(%ebp)
f0105602:	e8 8a ff ff ff       	call   f0105591 <memmove>
}
f0105607:	c9                   	leave  
f0105608:	c3                   	ret    

f0105609 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105609:	55                   	push   %ebp
f010560a:	89 e5                	mov    %esp,%ebp
f010560c:	56                   	push   %esi
f010560d:	53                   	push   %ebx
f010560e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105611:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105614:	89 c6                	mov    %eax,%esi
f0105616:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105619:	eb 06                	jmp    f0105621 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010561b:	83 c0 01             	add    $0x1,%eax
f010561e:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0105621:	39 f0                	cmp    %esi,%eax
f0105623:	74 14                	je     f0105639 <memcmp+0x30>
		if (*s1 != *s2)
f0105625:	0f b6 08             	movzbl (%eax),%ecx
f0105628:	0f b6 1a             	movzbl (%edx),%ebx
f010562b:	38 d9                	cmp    %bl,%cl
f010562d:	74 ec                	je     f010561b <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f010562f:	0f b6 c1             	movzbl %cl,%eax
f0105632:	0f b6 db             	movzbl %bl,%ebx
f0105635:	29 d8                	sub    %ebx,%eax
f0105637:	eb 05                	jmp    f010563e <memcmp+0x35>
	}

	return 0;
f0105639:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010563e:	5b                   	pop    %ebx
f010563f:	5e                   	pop    %esi
f0105640:	5d                   	pop    %ebp
f0105641:	c3                   	ret    

f0105642 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105642:	55                   	push   %ebp
f0105643:	89 e5                	mov    %esp,%ebp
f0105645:	8b 45 08             	mov    0x8(%ebp),%eax
f0105648:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010564b:	89 c2                	mov    %eax,%edx
f010564d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105650:	eb 03                	jmp    f0105655 <memfind+0x13>
f0105652:	83 c0 01             	add    $0x1,%eax
f0105655:	39 d0                	cmp    %edx,%eax
f0105657:	73 04                	jae    f010565d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105659:	38 08                	cmp    %cl,(%eax)
f010565b:	75 f5                	jne    f0105652 <memfind+0x10>
			break;
	return (void *) s;
}
f010565d:	5d                   	pop    %ebp
f010565e:	c3                   	ret    

f010565f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010565f:	55                   	push   %ebp
f0105660:	89 e5                	mov    %esp,%ebp
f0105662:	57                   	push   %edi
f0105663:	56                   	push   %esi
f0105664:	53                   	push   %ebx
f0105665:	8b 55 08             	mov    0x8(%ebp),%edx
f0105668:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010566b:	eb 03                	jmp    f0105670 <strtol+0x11>
		s++;
f010566d:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0105670:	0f b6 02             	movzbl (%edx),%eax
f0105673:	3c 20                	cmp    $0x20,%al
f0105675:	74 f6                	je     f010566d <strtol+0xe>
f0105677:	3c 09                	cmp    $0x9,%al
f0105679:	74 f2                	je     f010566d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010567b:	3c 2b                	cmp    $0x2b,%al
f010567d:	74 2a                	je     f01056a9 <strtol+0x4a>
	int neg = 0;
f010567f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105684:	3c 2d                	cmp    $0x2d,%al
f0105686:	74 2b                	je     f01056b3 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105688:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010568e:	75 0f                	jne    f010569f <strtol+0x40>
f0105690:	80 3a 30             	cmpb   $0x30,(%edx)
f0105693:	74 28                	je     f01056bd <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105695:	85 db                	test   %ebx,%ebx
f0105697:	b8 0a 00 00 00       	mov    $0xa,%eax
f010569c:	0f 44 d8             	cmove  %eax,%ebx
f010569f:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056a4:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01056a7:	eb 46                	jmp    f01056ef <strtol+0x90>
		s++;
f01056a9:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f01056ac:	bf 00 00 00 00       	mov    $0x0,%edi
f01056b1:	eb d5                	jmp    f0105688 <strtol+0x29>
		s++, neg = 1;
f01056b3:	83 c2 01             	add    $0x1,%edx
f01056b6:	bf 01 00 00 00       	mov    $0x1,%edi
f01056bb:	eb cb                	jmp    f0105688 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01056bd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01056c1:	74 0e                	je     f01056d1 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f01056c3:	85 db                	test   %ebx,%ebx
f01056c5:	75 d8                	jne    f010569f <strtol+0x40>
		s++, base = 8;
f01056c7:	83 c2 01             	add    $0x1,%edx
f01056ca:	bb 08 00 00 00       	mov    $0x8,%ebx
f01056cf:	eb ce                	jmp    f010569f <strtol+0x40>
		s += 2, base = 16;
f01056d1:	83 c2 02             	add    $0x2,%edx
f01056d4:	bb 10 00 00 00       	mov    $0x10,%ebx
f01056d9:	eb c4                	jmp    f010569f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01056db:	0f be c0             	movsbl %al,%eax
f01056de:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01056e1:	3b 45 10             	cmp    0x10(%ebp),%eax
f01056e4:	7d 3a                	jge    f0105720 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01056e6:	83 c2 01             	add    $0x1,%edx
f01056e9:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f01056ed:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f01056ef:	0f b6 02             	movzbl (%edx),%eax
f01056f2:	8d 70 d0             	lea    -0x30(%eax),%esi
f01056f5:	89 f3                	mov    %esi,%ebx
f01056f7:	80 fb 09             	cmp    $0x9,%bl
f01056fa:	76 df                	jbe    f01056db <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f01056fc:	8d 70 9f             	lea    -0x61(%eax),%esi
f01056ff:	89 f3                	mov    %esi,%ebx
f0105701:	80 fb 19             	cmp    $0x19,%bl
f0105704:	77 08                	ja     f010570e <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105706:	0f be c0             	movsbl %al,%eax
f0105709:	83 e8 57             	sub    $0x57,%eax
f010570c:	eb d3                	jmp    f01056e1 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f010570e:	8d 70 bf             	lea    -0x41(%eax),%esi
f0105711:	89 f3                	mov    %esi,%ebx
f0105713:	80 fb 19             	cmp    $0x19,%bl
f0105716:	77 08                	ja     f0105720 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105718:	0f be c0             	movsbl %al,%eax
f010571b:	83 e8 37             	sub    $0x37,%eax
f010571e:	eb c1                	jmp    f01056e1 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105720:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105724:	74 05                	je     f010572b <strtol+0xcc>
		*endptr = (char *) s;
f0105726:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105729:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f010572b:	89 c8                	mov    %ecx,%eax
f010572d:	f7 d8                	neg    %eax
f010572f:	85 ff                	test   %edi,%edi
f0105731:	0f 45 c8             	cmovne %eax,%ecx
}
f0105734:	89 c8                	mov    %ecx,%eax
f0105736:	5b                   	pop    %ebx
f0105737:	5e                   	pop    %esi
f0105738:	5f                   	pop    %edi
f0105739:	5d                   	pop    %ebp
f010573a:	c3                   	ret    
f010573b:	90                   	nop

f010573c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010573c:	fa                   	cli    

	xorw    %ax, %ax
f010573d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010573f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105741:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105743:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105745:	0f 01 16             	lgdtl  (%esi)
f0105748:	74 70                	je     f01057ba <mpsearch1+0x3>
	movl    %cr0, %eax
f010574a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010574d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105751:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105754:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010575a:	08 00                	or     %al,(%eax)

f010575c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010575c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105760:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105762:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105764:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105766:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010576a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010576c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010576e:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f0105773:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105776:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105779:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010577e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105781:	8b 25 04 70 21 f0    	mov    0xf0217004,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105787:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010578c:	b8 a4 01 10 f0       	mov    $0xf01001a4,%eax
	call    *%eax
f0105791:	ff d0                	call   *%eax

f0105793 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105793:	eb fe                	jmp    f0105793 <spin>
f0105795:	8d 76 00             	lea    0x0(%esi),%esi

f0105798 <gdt>:
	...
f01057a0:	ff                   	(bad)  
f01057a1:	ff 00                	incl   (%eax)
f01057a3:	00 00                	add    %al,(%eax)
f01057a5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01057ac:	00                   	.byte 0x0
f01057ad:	92                   	xchg   %eax,%edx
f01057ae:	cf                   	iret   
	...

f01057b0 <gdtdesc>:
f01057b0:	17                   	pop    %ss
f01057b1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01057b6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01057b6:	90                   	nop

f01057b7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01057b7:	55                   	push   %ebp
f01057b8:	89 e5                	mov    %esp,%ebp
f01057ba:	57                   	push   %edi
f01057bb:	56                   	push   %esi
f01057bc:	53                   	push   %ebx
f01057bd:	83 ec 1c             	sub    $0x1c,%esp
f01057c0:	89 c6                	mov    %eax,%esi
	if (PGNUM(pa) >= npages)
f01057c2:	8b 0d 60 72 21 f0    	mov    0xf0217260,%ecx
f01057c8:	c1 e8 0c             	shr    $0xc,%eax
f01057cb:	39 c8                	cmp    %ecx,%eax
f01057cd:	73 22                	jae    f01057f1 <mpsearch1+0x3a>
	return (void *)(pa + KERNBASE);
f01057cf:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01057d5:	8d 04 32             	lea    (%edx,%esi,1),%eax
	if (PGNUM(pa) >= npages)
f01057d8:	89 c2                	mov    %eax,%edx
f01057da:	c1 ea 0c             	shr    $0xc,%edx
f01057dd:	39 ca                	cmp    %ecx,%edx
f01057df:	73 22                	jae    f0105803 <mpsearch1+0x4c>
	return (void *)(pa + KERNBASE);
f01057e1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01057e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01057e9:	81 ee f0 ff ff 0f    	sub    $0xffffff0,%esi

	for (; mp < end; mp++)
f01057ef:	eb 2a                	jmp    f010581b <mpsearch1+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057f1:	56                   	push   %esi
f01057f2:	68 a4 61 10 f0       	push   $0xf01061a4
f01057f7:	6a 57                	push   $0x57
f01057f9:	68 e1 7c 10 f0       	push   $0xf0107ce1
f01057fe:	e8 3d a8 ff ff       	call   f0100040 <_panic>
f0105803:	50                   	push   %eax
f0105804:	68 a4 61 10 f0       	push   $0xf01061a4
f0105809:	6a 57                	push   $0x57
f010580b:	68 e1 7c 10 f0       	push   $0xf0107ce1
f0105810:	e8 2b a8 ff ff       	call   f0100040 <_panic>
f0105815:	83 c7 10             	add    $0x10,%edi
f0105818:	83 c6 10             	add    $0x10,%esi
f010581b:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f010581e:	73 2b                	jae    f010584b <mpsearch1+0x94>
f0105820:	89 fb                	mov    %edi,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105822:	83 ec 04             	sub    $0x4,%esp
f0105825:	6a 04                	push   $0x4
f0105827:	68 f1 7c 10 f0       	push   $0xf0107cf1
f010582c:	57                   	push   %edi
f010582d:	e8 d7 fd ff ff       	call   f0105609 <memcmp>
f0105832:	83 c4 10             	add    $0x10,%esp
f0105835:	85 c0                	test   %eax,%eax
f0105837:	75 dc                	jne    f0105815 <mpsearch1+0x5e>
		sum += ((uint8_t *)addr)[i];
f0105839:	0f b6 13             	movzbl (%ebx),%edx
f010583c:	01 d0                	add    %edx,%eax
	for (i = 0; i < len; i++)
f010583e:	83 c3 01             	add    $0x1,%ebx
f0105841:	39 f3                	cmp    %esi,%ebx
f0105843:	75 f4                	jne    f0105839 <mpsearch1+0x82>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105845:	84 c0                	test   %al,%al
f0105847:	75 cc                	jne    f0105815 <mpsearch1+0x5e>
f0105849:	eb 05                	jmp    f0105850 <mpsearch1+0x99>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010584b:	bf 00 00 00 00       	mov    $0x0,%edi
}
f0105850:	89 f8                	mov    %edi,%eax
f0105852:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105855:	5b                   	pop    %ebx
f0105856:	5e                   	pop    %esi
f0105857:	5f                   	pop    %edi
f0105858:	5d                   	pop    %ebp
f0105859:	c3                   	ret    

f010585a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010585a:	55                   	push   %ebp
f010585b:	89 e5                	mov    %esp,%ebp
f010585d:	57                   	push   %edi
f010585e:	56                   	push   %esi
f010585f:	53                   	push   %ebx
f0105860:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105863:	c7 05 08 80 25 f0 20 	movl   $0xf0258020,0xf0258008
f010586a:	80 25 f0 
	if (PGNUM(pa) >= npages)
f010586d:	83 3d 60 72 21 f0 00 	cmpl   $0x0,0xf0217260
f0105874:	0f 84 86 00 00 00    	je     f0105900 <mp_init+0xa6>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010587a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105881:	85 c0                	test   %eax,%eax
f0105883:	0f 84 8d 00 00 00    	je     f0105916 <mp_init+0xbc>
		p <<= 4;	// Translate from segment to PA
f0105889:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010588c:	ba 00 04 00 00       	mov    $0x400,%edx
f0105891:	e8 21 ff ff ff       	call   f01057b7 <mpsearch1>
f0105896:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105899:	85 c0                	test   %eax,%eax
f010589b:	75 1a                	jne    f01058b7 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f010589d:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058a2:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01058a7:	e8 0b ff ff ff       	call   f01057b7 <mpsearch1>
f01058ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01058af:	85 c0                	test   %eax,%eax
f01058b1:	0f 84 20 02 00 00    	je     f0105ad7 <mp_init+0x27d>
	if (mp->physaddr == 0 || mp->type != 0) {
f01058b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058ba:	8b 58 04             	mov    0x4(%eax),%ebx
f01058bd:	85 db                	test   %ebx,%ebx
f01058bf:	74 7a                	je     f010593b <mp_init+0xe1>
f01058c1:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01058c5:	75 74                	jne    f010593b <mp_init+0xe1>
f01058c7:	89 d8                	mov    %ebx,%eax
f01058c9:	c1 e8 0c             	shr    $0xc,%eax
f01058cc:	3b 05 60 72 21 f0    	cmp    0xf0217260,%eax
f01058d2:	73 7c                	jae    f0105950 <mp_init+0xf6>
	return (void *)(pa + KERNBASE);
f01058d4:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f01058da:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01058dc:	83 ec 04             	sub    $0x4,%esp
f01058df:	6a 04                	push   $0x4
f01058e1:	68 f6 7c 10 f0       	push   $0xf0107cf6
f01058e6:	53                   	push   %ebx
f01058e7:	e8 1d fd ff ff       	call   f0105609 <memcmp>
f01058ec:	83 c4 10             	add    $0x10,%esp
f01058ef:	85 c0                	test   %eax,%eax
f01058f1:	75 72                	jne    f0105965 <mp_init+0x10b>
f01058f3:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f01058f7:	01 df                	add    %ebx,%edi
	sum = 0;
f01058f9:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f01058fb:	e9 82 00 00 00       	jmp    f0105982 <mp_init+0x128>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105900:	68 00 04 00 00       	push   $0x400
f0105905:	68 a4 61 10 f0       	push   $0xf01061a4
f010590a:	6a 6f                	push   $0x6f
f010590c:	68 e1 7c 10 f0       	push   $0xf0107ce1
f0105911:	e8 2a a7 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105916:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010591d:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105920:	2d 00 04 00 00       	sub    $0x400,%eax
f0105925:	ba 00 04 00 00       	mov    $0x400,%edx
f010592a:	e8 88 fe ff ff       	call   f01057b7 <mpsearch1>
f010592f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105932:	85 c0                	test   %eax,%eax
f0105934:	75 81                	jne    f01058b7 <mp_init+0x5d>
f0105936:	e9 62 ff ff ff       	jmp    f010589d <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f010593b:	83 ec 0c             	sub    $0xc,%esp
f010593e:	68 54 7b 10 f0       	push   $0xf0107b54
f0105943:	e8 ea df ff ff       	call   f0103932 <cprintf>
		return NULL;
f0105948:	83 c4 10             	add    $0x10,%esp
f010594b:	e9 87 01 00 00       	jmp    f0105ad7 <mp_init+0x27d>
f0105950:	53                   	push   %ebx
f0105951:	68 a4 61 10 f0       	push   $0xf01061a4
f0105956:	68 90 00 00 00       	push   $0x90
f010595b:	68 e1 7c 10 f0       	push   $0xf0107ce1
f0105960:	e8 db a6 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105965:	83 ec 0c             	sub    $0xc,%esp
f0105968:	68 84 7b 10 f0       	push   $0xf0107b84
f010596d:	e8 c0 df ff ff       	call   f0103932 <cprintf>
		return NULL;
f0105972:	83 c4 10             	add    $0x10,%esp
f0105975:	e9 5d 01 00 00       	jmp    f0105ad7 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f010597a:	0f b6 0b             	movzbl (%ebx),%ecx
f010597d:	01 ca                	add    %ecx,%edx
f010597f:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105982:	39 fb                	cmp    %edi,%ebx
f0105984:	75 f4                	jne    f010597a <mp_init+0x120>
	if (sum(conf, conf->length) != 0) {
f0105986:	84 d2                	test   %dl,%dl
f0105988:	75 16                	jne    f01059a0 <mp_init+0x146>
	if (conf->version != 1 && conf->version != 4) {
f010598a:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f010598e:	80 fa 01             	cmp    $0x1,%dl
f0105991:	74 05                	je     f0105998 <mp_init+0x13e>
f0105993:	80 fa 04             	cmp    $0x4,%dl
f0105996:	75 1d                	jne    f01059b5 <mp_init+0x15b>
f0105998:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f010599c:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f010599e:	eb 36                	jmp    f01059d6 <mp_init+0x17c>
		cprintf("SMP: Bad MP configuration checksum\n");
f01059a0:	83 ec 0c             	sub    $0xc,%esp
f01059a3:	68 b8 7b 10 f0       	push   $0xf0107bb8
f01059a8:	e8 85 df ff ff       	call   f0103932 <cprintf>
		return NULL;
f01059ad:	83 c4 10             	add    $0x10,%esp
f01059b0:	e9 22 01 00 00       	jmp    f0105ad7 <mp_init+0x27d>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01059b5:	83 ec 08             	sub    $0x8,%esp
f01059b8:	0f b6 d2             	movzbl %dl,%edx
f01059bb:	52                   	push   %edx
f01059bc:	68 dc 7b 10 f0       	push   $0xf0107bdc
f01059c1:	e8 6c df ff ff       	call   f0103932 <cprintf>
		return NULL;
f01059c6:	83 c4 10             	add    $0x10,%esp
f01059c9:	e9 09 01 00 00       	jmp    f0105ad7 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f01059ce:	0f b6 13             	movzbl (%ebx),%edx
f01059d1:	01 d0                	add    %edx,%eax
f01059d3:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f01059d6:	39 d9                	cmp    %ebx,%ecx
f01059d8:	75 f4                	jne    f01059ce <mp_init+0x174>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01059da:	02 46 2a             	add    0x2a(%esi),%al
f01059dd:	75 1c                	jne    f01059fb <mp_init+0x1a1>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f01059df:	c7 05 04 80 25 f0 01 	movl   $0x1,0xf0258004
f01059e6:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01059e9:	8b 46 24             	mov    0x24(%esi),%eax
f01059ec:	a3 c4 83 25 f0       	mov    %eax,0xf02583c4

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01059f1:	8d 7e 2c             	lea    0x2c(%esi),%edi
f01059f4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01059f9:	eb 4d                	jmp    f0105a48 <mp_init+0x1ee>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01059fb:	83 ec 0c             	sub    $0xc,%esp
f01059fe:	68 fc 7b 10 f0       	push   $0xf0107bfc
f0105a03:	e8 2a df ff ff       	call   f0103932 <cprintf>
		return NULL;
f0105a08:	83 c4 10             	add    $0x10,%esp
f0105a0b:	e9 c7 00 00 00       	jmp    f0105ad7 <mp_init+0x27d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105a10:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105a14:	74 11                	je     f0105a27 <mp_init+0x1cd>
				bootcpu = &cpus[ncpu];
f0105a16:	6b 05 00 80 25 f0 74 	imul   $0x74,0xf0258000,%eax
f0105a1d:	05 20 80 25 f0       	add    $0xf0258020,%eax
f0105a22:	a3 08 80 25 f0       	mov    %eax,0xf0258008
			if (ncpu < NCPU) {
f0105a27:	a1 00 80 25 f0       	mov    0xf0258000,%eax
f0105a2c:	83 f8 07             	cmp    $0x7,%eax
f0105a2f:	7f 33                	jg     f0105a64 <mp_init+0x20a>
				cpus[ncpu].cpu_id = ncpu;
f0105a31:	6b d0 74             	imul   $0x74,%eax,%edx
f0105a34:	88 82 20 80 25 f0    	mov    %al,-0xfda7fe0(%edx)
				ncpu++;
f0105a3a:	83 c0 01             	add    $0x1,%eax
f0105a3d:	a3 00 80 25 f0       	mov    %eax,0xf0258000
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105a42:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105a45:	83 c3 01             	add    $0x1,%ebx
f0105a48:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105a4c:	39 d8                	cmp    %ebx,%eax
f0105a4e:	76 4f                	jbe    f0105a9f <mp_init+0x245>
		switch (*p) {
f0105a50:	0f b6 07             	movzbl (%edi),%eax
f0105a53:	84 c0                	test   %al,%al
f0105a55:	74 b9                	je     f0105a10 <mp_init+0x1b6>
f0105a57:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105a5a:	80 fa 03             	cmp    $0x3,%dl
f0105a5d:	77 1c                	ja     f0105a7b <mp_init+0x221>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105a5f:	83 c7 08             	add    $0x8,%edi
			continue;
f0105a62:	eb e1                	jmp    f0105a45 <mp_init+0x1eb>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105a64:	83 ec 08             	sub    $0x8,%esp
f0105a67:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105a6b:	50                   	push   %eax
f0105a6c:	68 2c 7c 10 f0       	push   $0xf0107c2c
f0105a71:	e8 bc de ff ff       	call   f0103932 <cprintf>
f0105a76:	83 c4 10             	add    $0x10,%esp
f0105a79:	eb c7                	jmp    f0105a42 <mp_init+0x1e8>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105a7b:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105a7e:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105a81:	50                   	push   %eax
f0105a82:	68 54 7c 10 f0       	push   $0xf0107c54
f0105a87:	e8 a6 de ff ff       	call   f0103932 <cprintf>
			ismp = 0;
f0105a8c:	c7 05 04 80 25 f0 00 	movl   $0x0,0xf0258004
f0105a93:	00 00 00 
			i = conf->entry;
f0105a96:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105a9a:	83 c4 10             	add    $0x10,%esp
f0105a9d:	eb a6                	jmp    f0105a45 <mp_init+0x1eb>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105a9f:	a1 08 80 25 f0       	mov    0xf0258008,%eax
f0105aa4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105aab:	83 3d 04 80 25 f0 00 	cmpl   $0x0,0xf0258004
f0105ab2:	74 2b                	je     f0105adf <mp_init+0x285>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105ab4:	83 ec 04             	sub    $0x4,%esp
f0105ab7:	ff 35 00 80 25 f0    	push   0xf0258000
f0105abd:	0f b6 00             	movzbl (%eax),%eax
f0105ac0:	50                   	push   %eax
f0105ac1:	68 fb 7c 10 f0       	push   $0xf0107cfb
f0105ac6:	e8 67 de ff ff       	call   f0103932 <cprintf>

	if (mp->imcrp) {
f0105acb:	83 c4 10             	add    $0x10,%esp
f0105ace:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ad1:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105ad5:	75 2e                	jne    f0105b05 <mp_init+0x2ab>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ada:	5b                   	pop    %ebx
f0105adb:	5e                   	pop    %esi
f0105adc:	5f                   	pop    %edi
f0105add:	5d                   	pop    %ebp
f0105ade:	c3                   	ret    
		ncpu = 1;
f0105adf:	c7 05 00 80 25 f0 01 	movl   $0x1,0xf0258000
f0105ae6:	00 00 00 
		lapicaddr = 0;
f0105ae9:	c7 05 c4 83 25 f0 00 	movl   $0x0,0xf02583c4
f0105af0:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105af3:	83 ec 0c             	sub    $0xc,%esp
f0105af6:	68 74 7c 10 f0       	push   $0xf0107c74
f0105afb:	e8 32 de ff ff       	call   f0103932 <cprintf>
		return;
f0105b00:	83 c4 10             	add    $0x10,%esp
f0105b03:	eb d2                	jmp    f0105ad7 <mp_init+0x27d>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105b05:	83 ec 0c             	sub    $0xc,%esp
f0105b08:	68 a0 7c 10 f0       	push   $0xf0107ca0
f0105b0d:	e8 20 de ff ff       	call   f0103932 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b12:	b8 70 00 00 00       	mov    $0x70,%eax
f0105b17:	ba 22 00 00 00       	mov    $0x22,%edx
f0105b1c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105b1d:	ba 23 00 00 00       	mov    $0x23,%edx
f0105b22:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105b23:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b26:	ee                   	out    %al,(%dx)
}
f0105b27:	83 c4 10             	add    $0x10,%esp
f0105b2a:	eb ab                	jmp    f0105ad7 <mp_init+0x27d>

f0105b2c <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105b2c:	8b 0d c0 83 25 f0    	mov    0xf02583c0,%ecx
f0105b32:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105b35:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105b37:	a1 c0 83 25 f0       	mov    0xf02583c0,%eax
f0105b3c:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105b3f:	c3                   	ret    

f0105b40 <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f0105b40:	8b 15 c0 83 25 f0    	mov    0xf02583c0,%edx
		return lapic[ID] >> 24;
	return 0;
f0105b46:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105b4b:	85 d2                	test   %edx,%edx
f0105b4d:	74 06                	je     f0105b55 <cpunum+0x15>
		return lapic[ID] >> 24;
f0105b4f:	8b 42 20             	mov    0x20(%edx),%eax
f0105b52:	c1 e8 18             	shr    $0x18,%eax
}
f0105b55:	c3                   	ret    

f0105b56 <lapic_init>:
	if (!lapicaddr)
f0105b56:	a1 c4 83 25 f0       	mov    0xf02583c4,%eax
f0105b5b:	85 c0                	test   %eax,%eax
f0105b5d:	75 01                	jne    f0105b60 <lapic_init+0xa>
f0105b5f:	c3                   	ret    
{
f0105b60:	55                   	push   %ebp
f0105b61:	89 e5                	mov    %esp,%ebp
f0105b63:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105b66:	68 00 10 00 00       	push   $0x1000
f0105b6b:	50                   	push   %eax
f0105b6c:	e8 a5 b6 ff ff       	call   f0101216 <mmio_map_region>
f0105b71:	a3 c0 83 25 f0       	mov    %eax,0xf02583c0
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105b76:	ba 27 01 00 00       	mov    $0x127,%edx
f0105b7b:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105b80:	e8 a7 ff ff ff       	call   f0105b2c <lapicw>
	lapicw(TDCR, X1);
f0105b85:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105b8a:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105b8f:	e8 98 ff ff ff       	call   f0105b2c <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105b94:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105b99:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105b9e:	e8 89 ff ff ff       	call   f0105b2c <lapicw>
	lapicw(TICR, 10000000); 
f0105ba3:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105ba8:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105bad:	e8 7a ff ff ff       	call   f0105b2c <lapicw>
	if (thiscpu != bootcpu)
f0105bb2:	e8 89 ff ff ff       	call   f0105b40 <cpunum>
f0105bb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bba:	05 20 80 25 f0       	add    $0xf0258020,%eax
f0105bbf:	83 c4 10             	add    $0x10,%esp
f0105bc2:	39 05 08 80 25 f0    	cmp    %eax,0xf0258008
f0105bc8:	74 0f                	je     f0105bd9 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0105bca:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105bcf:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105bd4:	e8 53 ff ff ff       	call   f0105b2c <lapicw>
	lapicw(LINT1, MASKED);
f0105bd9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105bde:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105be3:	e8 44 ff ff ff       	call   f0105b2c <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105be8:	a1 c0 83 25 f0       	mov    0xf02583c0,%eax
f0105bed:	8b 40 30             	mov    0x30(%eax),%eax
f0105bf0:	c1 e8 10             	shr    $0x10,%eax
f0105bf3:	a8 fc                	test   $0xfc,%al
f0105bf5:	75 7c                	jne    f0105c73 <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105bf7:	ba 33 00 00 00       	mov    $0x33,%edx
f0105bfc:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105c01:	e8 26 ff ff ff       	call   f0105b2c <lapicw>
	lapicw(ESR, 0);
f0105c06:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c0b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c10:	e8 17 ff ff ff       	call   f0105b2c <lapicw>
	lapicw(ESR, 0);
f0105c15:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c1a:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c1f:	e8 08 ff ff ff       	call   f0105b2c <lapicw>
	lapicw(EOI, 0);
f0105c24:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c29:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105c2e:	e8 f9 fe ff ff       	call   f0105b2c <lapicw>
	lapicw(ICRHI, 0);
f0105c33:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c38:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c3d:	e8 ea fe ff ff       	call   f0105b2c <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105c42:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105c47:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c4c:	e8 db fe ff ff       	call   f0105b2c <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105c51:	8b 15 c0 83 25 f0    	mov    0xf02583c0,%edx
f0105c57:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105c5d:	f6 c4 10             	test   $0x10,%ah
f0105c60:	75 f5                	jne    f0105c57 <lapic_init+0x101>
	lapicw(TPR, 0);
f0105c62:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c67:	b8 20 00 00 00       	mov    $0x20,%eax
f0105c6c:	e8 bb fe ff ff       	call   f0105b2c <lapicw>
}
f0105c71:	c9                   	leave  
f0105c72:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105c73:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c78:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105c7d:	e8 aa fe ff ff       	call   f0105b2c <lapicw>
f0105c82:	e9 70 ff ff ff       	jmp    f0105bf7 <lapic_init+0xa1>

f0105c87 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105c87:	83 3d c0 83 25 f0 00 	cmpl   $0x0,0xf02583c0
f0105c8e:	74 17                	je     f0105ca7 <lapic_eoi+0x20>
{
f0105c90:	55                   	push   %ebp
f0105c91:	89 e5                	mov    %esp,%ebp
f0105c93:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0105c96:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c9b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ca0:	e8 87 fe ff ff       	call   f0105b2c <lapicw>
}
f0105ca5:	c9                   	leave  
f0105ca6:	c3                   	ret    
f0105ca7:	c3                   	ret    

f0105ca8 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ca8:	55                   	push   %ebp
f0105ca9:	89 e5                	mov    %esp,%ebp
f0105cab:	56                   	push   %esi
f0105cac:	53                   	push   %ebx
f0105cad:	8b 75 08             	mov    0x8(%ebp),%esi
f0105cb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105cb3:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105cb8:	ba 70 00 00 00       	mov    $0x70,%edx
f0105cbd:	ee                   	out    %al,(%dx)
f0105cbe:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105cc3:	ba 71 00 00 00       	mov    $0x71,%edx
f0105cc8:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105cc9:	83 3d 60 72 21 f0 00 	cmpl   $0x0,0xf0217260
f0105cd0:	74 7e                	je     f0105d50 <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105cd2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105cd9:	00 00 
	wrv[1] = addr >> 4;
f0105cdb:	89 d8                	mov    %ebx,%eax
f0105cdd:	c1 e8 04             	shr    $0x4,%eax
f0105ce0:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105ce6:	c1 e6 18             	shl    $0x18,%esi
f0105ce9:	89 f2                	mov    %esi,%edx
f0105ceb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105cf0:	e8 37 fe ff ff       	call   f0105b2c <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105cf5:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105cfa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105cff:	e8 28 fe ff ff       	call   f0105b2c <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105d04:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105d09:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d0e:	e8 19 fe ff ff       	call   f0105b2c <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d13:	c1 eb 0c             	shr    $0xc,%ebx
f0105d16:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105d19:	89 f2                	mov    %esi,%edx
f0105d1b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d20:	e8 07 fe ff ff       	call   f0105b2c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d25:	89 da                	mov    %ebx,%edx
f0105d27:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d2c:	e8 fb fd ff ff       	call   f0105b2c <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105d31:	89 f2                	mov    %esi,%edx
f0105d33:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d38:	e8 ef fd ff ff       	call   f0105b2c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d3d:	89 da                	mov    %ebx,%edx
f0105d3f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d44:	e8 e3 fd ff ff       	call   f0105b2c <lapicw>
		microdelay(200);
	}
}
f0105d49:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105d4c:	5b                   	pop    %ebx
f0105d4d:	5e                   	pop    %esi
f0105d4e:	5d                   	pop    %ebp
f0105d4f:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d50:	68 67 04 00 00       	push   $0x467
f0105d55:	68 a4 61 10 f0       	push   $0xf01061a4
f0105d5a:	68 98 00 00 00       	push   $0x98
f0105d5f:	68 18 7d 10 f0       	push   $0xf0107d18
f0105d64:	e8 d7 a2 ff ff       	call   f0100040 <_panic>

f0105d69 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105d69:	55                   	push   %ebp
f0105d6a:	89 e5                	mov    %esp,%ebp
f0105d6c:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105d6f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105d72:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105d78:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d7d:	e8 aa fd ff ff       	call   f0105b2c <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105d82:	8b 15 c0 83 25 f0    	mov    0xf02583c0,%edx
f0105d88:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d8e:	f6 c4 10             	test   $0x10,%ah
f0105d91:	75 f5                	jne    f0105d88 <lapic_ipi+0x1f>
		;
}
f0105d93:	c9                   	leave  
f0105d94:	c3                   	ret    

f0105d95 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105d95:	55                   	push   %ebp
f0105d96:	89 e5                	mov    %esp,%ebp
f0105d98:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105d9b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105da1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105da4:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105da7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105dae:	5d                   	pop    %ebp
f0105daf:	c3                   	ret    

f0105db0 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105db0:	55                   	push   %ebp
f0105db1:	89 e5                	mov    %esp,%ebp
f0105db3:	56                   	push   %esi
f0105db4:	53                   	push   %ebx
f0105db5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105db8:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105dbb:	75 07                	jne    f0105dc4 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0105dbd:	ba 01 00 00 00       	mov    $0x1,%edx
f0105dc2:	eb 34                	jmp    f0105df8 <spin_lock+0x48>
f0105dc4:	8b 73 08             	mov    0x8(%ebx),%esi
f0105dc7:	e8 74 fd ff ff       	call   f0105b40 <cpunum>
f0105dcc:	6b c0 74             	imul   $0x74,%eax,%eax
f0105dcf:	05 20 80 25 f0       	add    $0xf0258020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105dd4:	39 c6                	cmp    %eax,%esi
f0105dd6:	75 e5                	jne    f0105dbd <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105dd8:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105ddb:	e8 60 fd ff ff       	call   f0105b40 <cpunum>
f0105de0:	83 ec 0c             	sub    $0xc,%esp
f0105de3:	53                   	push   %ebx
f0105de4:	50                   	push   %eax
f0105de5:	68 28 7d 10 f0       	push   $0xf0107d28
f0105dea:	6a 41                	push   $0x41
f0105dec:	68 8a 7d 10 f0       	push   $0xf0107d8a
f0105df1:	e8 4a a2 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105df6:	f3 90                	pause  
f0105df8:	89 d0                	mov    %edx,%eax
f0105dfa:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0105dfd:	85 c0                	test   %eax,%eax
f0105dff:	75 f5                	jne    f0105df6 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105e01:	e8 3a fd ff ff       	call   f0105b40 <cpunum>
f0105e06:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e09:	05 20 80 25 f0       	add    $0xf0258020,%eax
f0105e0e:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105e11:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0105e13:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105e18:	83 f8 09             	cmp    $0x9,%eax
f0105e1b:	7f 21                	jg     f0105e3e <spin_lock+0x8e>
f0105e1d:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105e23:	76 19                	jbe    f0105e3e <spin_lock+0x8e>
		pcs[i] = ebp[1];          // saved %eip
f0105e25:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105e28:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105e2c:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0105e2e:	83 c0 01             	add    $0x1,%eax
f0105e31:	eb e5                	jmp    f0105e18 <spin_lock+0x68>
		pcs[i] = 0;
f0105e33:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0105e3a:	00 
	for (; i < 10; i++)
f0105e3b:	83 c0 01             	add    $0x1,%eax
f0105e3e:	83 f8 09             	cmp    $0x9,%eax
f0105e41:	7e f0                	jle    f0105e33 <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f0105e43:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e46:	5b                   	pop    %ebx
f0105e47:	5e                   	pop    %esi
f0105e48:	5d                   	pop    %ebp
f0105e49:	c3                   	ret    

f0105e4a <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105e4a:	55                   	push   %ebp
f0105e4b:	89 e5                	mov    %esp,%ebp
f0105e4d:	57                   	push   %edi
f0105e4e:	56                   	push   %esi
f0105e4f:	53                   	push   %ebx
f0105e50:	83 ec 4c             	sub    $0x4c,%esp
f0105e53:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105e56:	83 3e 00             	cmpl   $0x0,(%esi)
f0105e59:	75 35                	jne    f0105e90 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105e5b:	83 ec 04             	sub    $0x4,%esp
f0105e5e:	6a 28                	push   $0x28
f0105e60:	8d 46 0c             	lea    0xc(%esi),%eax
f0105e63:	50                   	push   %eax
f0105e64:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105e67:	53                   	push   %ebx
f0105e68:	e8 24 f7 ff ff       	call   f0105591 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105e6d:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105e70:	0f b6 38             	movzbl (%eax),%edi
f0105e73:	8b 76 04             	mov    0x4(%esi),%esi
f0105e76:	e8 c5 fc ff ff       	call   f0105b40 <cpunum>
f0105e7b:	57                   	push   %edi
f0105e7c:	56                   	push   %esi
f0105e7d:	50                   	push   %eax
f0105e7e:	68 54 7d 10 f0       	push   $0xf0107d54
f0105e83:	e8 aa da ff ff       	call   f0103932 <cprintf>
f0105e88:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105e8b:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105e8e:	eb 4e                	jmp    f0105ede <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f0105e90:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105e93:	e8 a8 fc ff ff       	call   f0105b40 <cpunum>
f0105e98:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e9b:	05 20 80 25 f0       	add    $0xf0258020,%eax
	if (!holding(lk)) {
f0105ea0:	39 c3                	cmp    %eax,%ebx
f0105ea2:	75 b7                	jne    f0105e5b <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105ea4:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105eab:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0105eb2:	b8 00 00 00 00       	mov    $0x0,%eax
f0105eb7:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ebd:	5b                   	pop    %ebx
f0105ebe:	5e                   	pop    %esi
f0105ebf:	5f                   	pop    %edi
f0105ec0:	5d                   	pop    %ebp
f0105ec1:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0105ec2:	83 ec 08             	sub    $0x8,%esp
f0105ec5:	ff 36                	push   (%esi)
f0105ec7:	68 b1 7d 10 f0       	push   $0xf0107db1
f0105ecc:	e8 61 da ff ff       	call   f0103932 <cprintf>
f0105ed1:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105ed4:	83 c3 04             	add    $0x4,%ebx
f0105ed7:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105eda:	39 c3                	cmp    %eax,%ebx
f0105edc:	74 40                	je     f0105f1e <spin_unlock+0xd4>
f0105ede:	89 de                	mov    %ebx,%esi
f0105ee0:	8b 03                	mov    (%ebx),%eax
f0105ee2:	85 c0                	test   %eax,%eax
f0105ee4:	74 38                	je     f0105f1e <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105ee6:	83 ec 08             	sub    $0x8,%esp
f0105ee9:	57                   	push   %edi
f0105eea:	50                   	push   %eax
f0105eeb:	e8 95 eb ff ff       	call   f0104a85 <debuginfo_eip>
f0105ef0:	83 c4 10             	add    $0x10,%esp
f0105ef3:	85 c0                	test   %eax,%eax
f0105ef5:	78 cb                	js     f0105ec2 <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f0105ef7:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105ef9:	83 ec 04             	sub    $0x4,%esp
f0105efc:	89 c2                	mov    %eax,%edx
f0105efe:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105f01:	52                   	push   %edx
f0105f02:	ff 75 b0             	push   -0x50(%ebp)
f0105f05:	ff 75 b4             	push   -0x4c(%ebp)
f0105f08:	ff 75 ac             	push   -0x54(%ebp)
f0105f0b:	ff 75 a8             	push   -0x58(%ebp)
f0105f0e:	50                   	push   %eax
f0105f0f:	68 9a 7d 10 f0       	push   $0xf0107d9a
f0105f14:	e8 19 da ff ff       	call   f0103932 <cprintf>
f0105f19:	83 c4 20             	add    $0x20,%esp
f0105f1c:	eb b6                	jmp    f0105ed4 <spin_unlock+0x8a>
		panic("spin_unlock");
f0105f1e:	83 ec 04             	sub    $0x4,%esp
f0105f21:	68 b9 7d 10 f0       	push   $0xf0107db9
f0105f26:	6a 67                	push   $0x67
f0105f28:	68 8a 7d 10 f0       	push   $0xf0107d8a
f0105f2d:	e8 0e a1 ff ff       	call   f0100040 <_panic>
f0105f32:	66 90                	xchg   %ax,%ax
f0105f34:	66 90                	xchg   %ax,%ax
f0105f36:	66 90                	xchg   %ax,%ax
f0105f38:	66 90                	xchg   %ax,%ax
f0105f3a:	66 90                	xchg   %ax,%ax
f0105f3c:	66 90                	xchg   %ax,%ax
f0105f3e:	66 90                	xchg   %ax,%ax

f0105f40 <__udivdi3>:
f0105f40:	f3 0f 1e fb          	endbr32 
f0105f44:	55                   	push   %ebp
f0105f45:	57                   	push   %edi
f0105f46:	56                   	push   %esi
f0105f47:	53                   	push   %ebx
f0105f48:	83 ec 1c             	sub    $0x1c,%esp
f0105f4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0105f4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105f53:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105f57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105f5b:	85 c0                	test   %eax,%eax
f0105f5d:	75 19                	jne    f0105f78 <__udivdi3+0x38>
f0105f5f:	39 f3                	cmp    %esi,%ebx
f0105f61:	76 4d                	jbe    f0105fb0 <__udivdi3+0x70>
f0105f63:	31 ff                	xor    %edi,%edi
f0105f65:	89 e8                	mov    %ebp,%eax
f0105f67:	89 f2                	mov    %esi,%edx
f0105f69:	f7 f3                	div    %ebx
f0105f6b:	89 fa                	mov    %edi,%edx
f0105f6d:	83 c4 1c             	add    $0x1c,%esp
f0105f70:	5b                   	pop    %ebx
f0105f71:	5e                   	pop    %esi
f0105f72:	5f                   	pop    %edi
f0105f73:	5d                   	pop    %ebp
f0105f74:	c3                   	ret    
f0105f75:	8d 76 00             	lea    0x0(%esi),%esi
f0105f78:	39 f0                	cmp    %esi,%eax
f0105f7a:	76 14                	jbe    f0105f90 <__udivdi3+0x50>
f0105f7c:	31 ff                	xor    %edi,%edi
f0105f7e:	31 c0                	xor    %eax,%eax
f0105f80:	89 fa                	mov    %edi,%edx
f0105f82:	83 c4 1c             	add    $0x1c,%esp
f0105f85:	5b                   	pop    %ebx
f0105f86:	5e                   	pop    %esi
f0105f87:	5f                   	pop    %edi
f0105f88:	5d                   	pop    %ebp
f0105f89:	c3                   	ret    
f0105f8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105f90:	0f bd f8             	bsr    %eax,%edi
f0105f93:	83 f7 1f             	xor    $0x1f,%edi
f0105f96:	75 48                	jne    f0105fe0 <__udivdi3+0xa0>
f0105f98:	39 f0                	cmp    %esi,%eax
f0105f9a:	72 06                	jb     f0105fa2 <__udivdi3+0x62>
f0105f9c:	31 c0                	xor    %eax,%eax
f0105f9e:	39 eb                	cmp    %ebp,%ebx
f0105fa0:	77 de                	ja     f0105f80 <__udivdi3+0x40>
f0105fa2:	b8 01 00 00 00       	mov    $0x1,%eax
f0105fa7:	eb d7                	jmp    f0105f80 <__udivdi3+0x40>
f0105fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105fb0:	89 d9                	mov    %ebx,%ecx
f0105fb2:	85 db                	test   %ebx,%ebx
f0105fb4:	75 0b                	jne    f0105fc1 <__udivdi3+0x81>
f0105fb6:	b8 01 00 00 00       	mov    $0x1,%eax
f0105fbb:	31 d2                	xor    %edx,%edx
f0105fbd:	f7 f3                	div    %ebx
f0105fbf:	89 c1                	mov    %eax,%ecx
f0105fc1:	31 d2                	xor    %edx,%edx
f0105fc3:	89 f0                	mov    %esi,%eax
f0105fc5:	f7 f1                	div    %ecx
f0105fc7:	89 c6                	mov    %eax,%esi
f0105fc9:	89 e8                	mov    %ebp,%eax
f0105fcb:	89 f7                	mov    %esi,%edi
f0105fcd:	f7 f1                	div    %ecx
f0105fcf:	89 fa                	mov    %edi,%edx
f0105fd1:	83 c4 1c             	add    $0x1c,%esp
f0105fd4:	5b                   	pop    %ebx
f0105fd5:	5e                   	pop    %esi
f0105fd6:	5f                   	pop    %edi
f0105fd7:	5d                   	pop    %ebp
f0105fd8:	c3                   	ret    
f0105fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105fe0:	89 f9                	mov    %edi,%ecx
f0105fe2:	ba 20 00 00 00       	mov    $0x20,%edx
f0105fe7:	29 fa                	sub    %edi,%edx
f0105fe9:	d3 e0                	shl    %cl,%eax
f0105feb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105fef:	89 d1                	mov    %edx,%ecx
f0105ff1:	89 d8                	mov    %ebx,%eax
f0105ff3:	d3 e8                	shr    %cl,%eax
f0105ff5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105ff9:	09 c1                	or     %eax,%ecx
f0105ffb:	89 f0                	mov    %esi,%eax
f0105ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106001:	89 f9                	mov    %edi,%ecx
f0106003:	d3 e3                	shl    %cl,%ebx
f0106005:	89 d1                	mov    %edx,%ecx
f0106007:	d3 e8                	shr    %cl,%eax
f0106009:	89 f9                	mov    %edi,%ecx
f010600b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010600f:	89 eb                	mov    %ebp,%ebx
f0106011:	d3 e6                	shl    %cl,%esi
f0106013:	89 d1                	mov    %edx,%ecx
f0106015:	d3 eb                	shr    %cl,%ebx
f0106017:	09 f3                	or     %esi,%ebx
f0106019:	89 c6                	mov    %eax,%esi
f010601b:	89 f2                	mov    %esi,%edx
f010601d:	89 d8                	mov    %ebx,%eax
f010601f:	f7 74 24 08          	divl   0x8(%esp)
f0106023:	89 d6                	mov    %edx,%esi
f0106025:	89 c3                	mov    %eax,%ebx
f0106027:	f7 64 24 0c          	mull   0xc(%esp)
f010602b:	39 d6                	cmp    %edx,%esi
f010602d:	72 19                	jb     f0106048 <__udivdi3+0x108>
f010602f:	89 f9                	mov    %edi,%ecx
f0106031:	d3 e5                	shl    %cl,%ebp
f0106033:	39 c5                	cmp    %eax,%ebp
f0106035:	73 04                	jae    f010603b <__udivdi3+0xfb>
f0106037:	39 d6                	cmp    %edx,%esi
f0106039:	74 0d                	je     f0106048 <__udivdi3+0x108>
f010603b:	89 d8                	mov    %ebx,%eax
f010603d:	31 ff                	xor    %edi,%edi
f010603f:	e9 3c ff ff ff       	jmp    f0105f80 <__udivdi3+0x40>
f0106044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106048:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010604b:	31 ff                	xor    %edi,%edi
f010604d:	e9 2e ff ff ff       	jmp    f0105f80 <__udivdi3+0x40>
f0106052:	66 90                	xchg   %ax,%ax
f0106054:	66 90                	xchg   %ax,%ax
f0106056:	66 90                	xchg   %ax,%ax
f0106058:	66 90                	xchg   %ax,%ax
f010605a:	66 90                	xchg   %ax,%ax
f010605c:	66 90                	xchg   %ax,%ax
f010605e:	66 90                	xchg   %ax,%ax

f0106060 <__umoddi3>:
f0106060:	f3 0f 1e fb          	endbr32 
f0106064:	55                   	push   %ebp
f0106065:	57                   	push   %edi
f0106066:	56                   	push   %esi
f0106067:	53                   	push   %ebx
f0106068:	83 ec 1c             	sub    $0x1c,%esp
f010606b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010606f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106073:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0106077:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f010607b:	89 f0                	mov    %esi,%eax
f010607d:	89 da                	mov    %ebx,%edx
f010607f:	85 ff                	test   %edi,%edi
f0106081:	75 15                	jne    f0106098 <__umoddi3+0x38>
f0106083:	39 dd                	cmp    %ebx,%ebp
f0106085:	76 39                	jbe    f01060c0 <__umoddi3+0x60>
f0106087:	f7 f5                	div    %ebp
f0106089:	89 d0                	mov    %edx,%eax
f010608b:	31 d2                	xor    %edx,%edx
f010608d:	83 c4 1c             	add    $0x1c,%esp
f0106090:	5b                   	pop    %ebx
f0106091:	5e                   	pop    %esi
f0106092:	5f                   	pop    %edi
f0106093:	5d                   	pop    %ebp
f0106094:	c3                   	ret    
f0106095:	8d 76 00             	lea    0x0(%esi),%esi
f0106098:	39 df                	cmp    %ebx,%edi
f010609a:	77 f1                	ja     f010608d <__umoddi3+0x2d>
f010609c:	0f bd cf             	bsr    %edi,%ecx
f010609f:	83 f1 1f             	xor    $0x1f,%ecx
f01060a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01060a6:	75 40                	jne    f01060e8 <__umoddi3+0x88>
f01060a8:	39 df                	cmp    %ebx,%edi
f01060aa:	72 04                	jb     f01060b0 <__umoddi3+0x50>
f01060ac:	39 f5                	cmp    %esi,%ebp
f01060ae:	77 dd                	ja     f010608d <__umoddi3+0x2d>
f01060b0:	89 da                	mov    %ebx,%edx
f01060b2:	89 f0                	mov    %esi,%eax
f01060b4:	29 e8                	sub    %ebp,%eax
f01060b6:	19 fa                	sbb    %edi,%edx
f01060b8:	eb d3                	jmp    f010608d <__umoddi3+0x2d>
f01060ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01060c0:	89 e9                	mov    %ebp,%ecx
f01060c2:	85 ed                	test   %ebp,%ebp
f01060c4:	75 0b                	jne    f01060d1 <__umoddi3+0x71>
f01060c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01060cb:	31 d2                	xor    %edx,%edx
f01060cd:	f7 f5                	div    %ebp
f01060cf:	89 c1                	mov    %eax,%ecx
f01060d1:	89 d8                	mov    %ebx,%eax
f01060d3:	31 d2                	xor    %edx,%edx
f01060d5:	f7 f1                	div    %ecx
f01060d7:	89 f0                	mov    %esi,%eax
f01060d9:	f7 f1                	div    %ecx
f01060db:	89 d0                	mov    %edx,%eax
f01060dd:	31 d2                	xor    %edx,%edx
f01060df:	eb ac                	jmp    f010608d <__umoddi3+0x2d>
f01060e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01060e8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01060ec:	ba 20 00 00 00       	mov    $0x20,%edx
f01060f1:	29 c2                	sub    %eax,%edx
f01060f3:	89 c1                	mov    %eax,%ecx
f01060f5:	89 e8                	mov    %ebp,%eax
f01060f7:	d3 e7                	shl    %cl,%edi
f01060f9:	89 d1                	mov    %edx,%ecx
f01060fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01060ff:	d3 e8                	shr    %cl,%eax
f0106101:	89 c1                	mov    %eax,%ecx
f0106103:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106107:	09 f9                	or     %edi,%ecx
f0106109:	89 df                	mov    %ebx,%edi
f010610b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010610f:	89 c1                	mov    %eax,%ecx
f0106111:	d3 e5                	shl    %cl,%ebp
f0106113:	89 d1                	mov    %edx,%ecx
f0106115:	d3 ef                	shr    %cl,%edi
f0106117:	89 c1                	mov    %eax,%ecx
f0106119:	89 f0                	mov    %esi,%eax
f010611b:	d3 e3                	shl    %cl,%ebx
f010611d:	89 d1                	mov    %edx,%ecx
f010611f:	89 fa                	mov    %edi,%edx
f0106121:	d3 e8                	shr    %cl,%eax
f0106123:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106128:	09 d8                	or     %ebx,%eax
f010612a:	f7 74 24 08          	divl   0x8(%esp)
f010612e:	89 d3                	mov    %edx,%ebx
f0106130:	d3 e6                	shl    %cl,%esi
f0106132:	f7 e5                	mul    %ebp
f0106134:	89 c7                	mov    %eax,%edi
f0106136:	89 d1                	mov    %edx,%ecx
f0106138:	39 d3                	cmp    %edx,%ebx
f010613a:	72 06                	jb     f0106142 <__umoddi3+0xe2>
f010613c:	75 0e                	jne    f010614c <__umoddi3+0xec>
f010613e:	39 c6                	cmp    %eax,%esi
f0106140:	73 0a                	jae    f010614c <__umoddi3+0xec>
f0106142:	29 e8                	sub    %ebp,%eax
f0106144:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106148:	89 d1                	mov    %edx,%ecx
f010614a:	89 c7                	mov    %eax,%edi
f010614c:	89 f5                	mov    %esi,%ebp
f010614e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106152:	29 fd                	sub    %edi,%ebp
f0106154:	19 cb                	sbb    %ecx,%ebx
f0106156:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f010615b:	89 d8                	mov    %ebx,%eax
f010615d:	d3 e0                	shl    %cl,%eax
f010615f:	89 f1                	mov    %esi,%ecx
f0106161:	d3 ed                	shr    %cl,%ebp
f0106163:	d3 eb                	shr    %cl,%ebx
f0106165:	09 e8                	or     %ebp,%eax
f0106167:	89 da                	mov    %ebx,%edx
f0106169:	83 c4 1c             	add    $0x1c,%esp
f010616c:	5b                   	pop    %ebx
f010616d:	5e                   	pop    %esi
f010616e:	5f                   	pop    %edi
f010616f:	5d                   	pop    %ebp
f0106170:	c3                   	ret    
