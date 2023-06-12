
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
// Test the stack backtrace function (lab 1 only)
#if 1

void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 98 01 00 00       	call   f01001e2 <__x86.get_pc_thunk.bx>
f010004a:	81 c3 c2 72 01 00    	add    $0x172c2,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 d4 cc fe ff    	lea    -0x1332c(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 32 2f 00 00       	call   f0102f95 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else // tested with arguments
		mon_backtrace(1, NULL , NULL);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 f0 cc fe ff    	lea    -0x13310(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 0c 2f 00 00       	call   f0102f95 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(1, NULL , NULL);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 01                	push   $0x1
f010009c:	e8 13 08 00 00       	call   f01008b4 <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

#endif

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 30 01 00 00       	call   f01001e2 <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 5a 72 01 00    	add    $0x1725a,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 90 11 f0    	mov    $0xf0119060,%edx
f01000be:	c7 c0 e0 96 11 f0    	mov    $0xf01196e0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 d8 3a 00 00       	call   f0103ba7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 64 05 00 00       	call   f0100638 <cons_init>
    //cprintf("x=%d y=%d", 3);
    cprintf("x=%d y=%d z=%d", 3, 4);
f01000d4:	83 c4 0c             	add    $0xc,%esp
f01000d7:	6a 04                	push   $0x4
f01000d9:	6a 03                	push   $0x3
f01000db:	8d 83 0b cd fe ff    	lea    -0x132f5(%ebx),%eax
f01000e1:	50                   	push   %eax
f01000e2:	e8 ae 2e 00 00       	call   f0102f95 <cprintf>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000e7:	83 c4 08             	add    $0x8,%esp
f01000ea:	68 ac 1a 00 00       	push   $0x1aac
f01000ef:	8d 83 1a cd fe ff    	lea    -0x132e6(%ebx),%eax
f01000f5:	50                   	push   %eax
f01000f6:	e8 9a 2e 00 00       	call   f0102f95 <cprintf>
    cprintf("\033[31;1;4mThe World is black and white! \033[0m\n");
f01000fb:	8d 83 68 cd fe ff    	lea    -0x13298(%ebx),%eax
f0100101:	89 04 24             	mov    %eax,(%esp)
f0100104:	e8 8c 2e 00 00       	call   f0102f95 <cprintf>
	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100109:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100110:	e8 2b ff ff ff       	call   f0100040 <test_backtrace>
	mem_init();
f0100115:	e8 4e 15 00 00       	call   f0101668 <mem_init>
f010011a:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010011d:	83 ec 0c             	sub    $0xc,%esp
f0100120:	6a 00                	push   $0x0
f0100122:	e8 24 08 00 00       	call   f010094b <monitor>
f0100127:	83 c4 10             	add    $0x10,%esp
f010012a:	eb f1                	jmp    f010011d <i386_init+0x77>

f010012c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010012c:	55                   	push   %ebp
f010012d:	89 e5                	mov    %esp,%ebp
f010012f:	56                   	push   %esi
f0100130:	53                   	push   %ebx
f0100131:	e8 ac 00 00 00       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0100136:	81 c3 d6 71 01 00    	add    $0x171d6,%ebx
	va_list ap;

	if (panicstr)
f010013c:	83 bb 54 1d 00 00 00 	cmpl   $0x0,0x1d54(%ebx)
f0100143:	74 0f                	je     f0100154 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100145:	83 ec 0c             	sub    $0xc,%esp
f0100148:	6a 00                	push   $0x0
f010014a:	e8 fc 07 00 00       	call   f010094b <monitor>
f010014f:	83 c4 10             	add    $0x10,%esp
f0100152:	eb f1                	jmp    f0100145 <_panic+0x19>
	panicstr = fmt;
f0100154:	8b 45 10             	mov    0x10(%ebp),%eax
f0100157:	89 83 54 1d 00 00    	mov    %eax,0x1d54(%ebx)
	asm volatile("cli; cld");
f010015d:	fa                   	cli    
f010015e:	fc                   	cld    
	va_start(ap, fmt);
f010015f:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100162:	83 ec 04             	sub    $0x4,%esp
f0100165:	ff 75 0c             	push   0xc(%ebp)
f0100168:	ff 75 08             	push   0x8(%ebp)
f010016b:	8d 83 35 cd fe ff    	lea    -0x132cb(%ebx),%eax
f0100171:	50                   	push   %eax
f0100172:	e8 1e 2e 00 00       	call   f0102f95 <cprintf>
	vcprintf(fmt, ap);
f0100177:	83 c4 08             	add    $0x8,%esp
f010017a:	56                   	push   %esi
f010017b:	ff 75 10             	push   0x10(%ebp)
f010017e:	e8 db 2d 00 00       	call   f0102f5e <vcprintf>
	cprintf("\n");
f0100183:	8d 83 43 dd fe ff    	lea    -0x122bd(%ebx),%eax
f0100189:	89 04 24             	mov    %eax,(%esp)
f010018c:	e8 04 2e 00 00       	call   f0102f95 <cprintf>
f0100191:	83 c4 10             	add    $0x10,%esp
f0100194:	eb af                	jmp    f0100145 <_panic+0x19>

f0100196 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	56                   	push   %esi
f010019a:	53                   	push   %ebx
f010019b:	e8 42 00 00 00       	call   f01001e2 <__x86.get_pc_thunk.bx>
f01001a0:	81 c3 6c 71 01 00    	add    $0x1716c,%ebx
	va_list ap;

	va_start(ap, fmt);
f01001a6:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f01001a9:	83 ec 04             	sub    $0x4,%esp
f01001ac:	ff 75 0c             	push   0xc(%ebp)
f01001af:	ff 75 08             	push   0x8(%ebp)
f01001b2:	8d 83 4d cd fe ff    	lea    -0x132b3(%ebx),%eax
f01001b8:	50                   	push   %eax
f01001b9:	e8 d7 2d 00 00       	call   f0102f95 <cprintf>
	vcprintf(fmt, ap);
f01001be:	83 c4 08             	add    $0x8,%esp
f01001c1:	56                   	push   %esi
f01001c2:	ff 75 10             	push   0x10(%ebp)
f01001c5:	e8 94 2d 00 00       	call   f0102f5e <vcprintf>
	cprintf("\n");
f01001ca:	8d 83 43 dd fe ff    	lea    -0x122bd(%ebx),%eax
f01001d0:	89 04 24             	mov    %eax,(%esp)
f01001d3:	e8 bd 2d 00 00       	call   f0102f95 <cprintf>
	va_end(ap);
}
f01001d8:	83 c4 10             	add    $0x10,%esp
f01001db:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001de:	5b                   	pop    %ebx
f01001df:	5e                   	pop    %esi
f01001e0:	5d                   	pop    %ebp
f01001e1:	c3                   	ret    

f01001e2 <__x86.get_pc_thunk.bx>:
f01001e2:	8b 1c 24             	mov    (%esp),%ebx
f01001e5:	c3                   	ret    

f01001e6 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001eb:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001ec:	a8 01                	test   $0x1,%al
f01001ee:	74 0a                	je     f01001fa <serial_proc_data+0x14>
f01001f0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001f5:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001f6:	0f b6 c0             	movzbl %al,%eax
f01001f9:	c3                   	ret    
		return -1;
f01001fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001ff:	c3                   	ret    

f0100200 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100200:	55                   	push   %ebp
f0100201:	89 e5                	mov    %esp,%ebp
f0100203:	57                   	push   %edi
f0100204:	56                   	push   %esi
f0100205:	53                   	push   %ebx
f0100206:	83 ec 1c             	sub    $0x1c,%esp
f0100209:	e8 6a 05 00 00       	call   f0100778 <__x86.get_pc_thunk.si>
f010020e:	81 c6 fe 70 01 00    	add    $0x170fe,%esi
f0100214:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100216:	8d 1d 94 1d 00 00    	lea    0x1d94,%ebx
f010021c:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010021f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100222:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100225:	eb 25                	jmp    f010024c <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100227:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f010022e:	8d 51 01             	lea    0x1(%ecx),%edx
f0100231:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100234:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100237:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010023d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100242:	0f 44 d0             	cmove  %eax,%edx
f0100245:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f010024c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010024f:	ff d0                	call   *%eax
f0100251:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100254:	74 06                	je     f010025c <cons_intr+0x5c>
		if (c == 0)
f0100256:	85 c0                	test   %eax,%eax
f0100258:	75 cd                	jne    f0100227 <cons_intr+0x27>
f010025a:	eb f0                	jmp    f010024c <cons_intr+0x4c>
	}
}
f010025c:	83 c4 1c             	add    $0x1c,%esp
f010025f:	5b                   	pop    %ebx
f0100260:	5e                   	pop    %esi
f0100261:	5f                   	pop    %edi
f0100262:	5d                   	pop    %ebp
f0100263:	c3                   	ret    

f0100264 <kbd_proc_data>:
{
f0100264:	55                   	push   %ebp
f0100265:	89 e5                	mov    %esp,%ebp
f0100267:	56                   	push   %esi
f0100268:	53                   	push   %ebx
f0100269:	e8 74 ff ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f010026e:	81 c3 9e 70 01 00    	add    $0x1709e,%ebx
f0100274:	ba 64 00 00 00       	mov    $0x64,%edx
f0100279:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010027a:	a8 01                	test   $0x1,%al
f010027c:	0f 84 f7 00 00 00    	je     f0100379 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100282:	a8 20                	test   $0x20,%al
f0100284:	0f 85 f6 00 00 00    	jne    f0100380 <kbd_proc_data+0x11c>
f010028a:	ba 60 00 00 00       	mov    $0x60,%edx
f010028f:	ec                   	in     (%dx),%al
f0100290:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100292:	3c e0                	cmp    $0xe0,%al
f0100294:	74 64                	je     f01002fa <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100296:	84 c0                	test   %al,%al
f0100298:	78 75                	js     f010030f <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010029a:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f01002a0:	f6 c1 40             	test   $0x40,%cl
f01002a3:	74 0e                	je     f01002b3 <kbd_proc_data+0x4f>
		data |= 0x80;
f01002a5:	83 c8 80             	or     $0xffffff80,%eax
f01002a8:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002aa:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002ad:	89 8b 74 1d 00 00    	mov    %ecx,0x1d74(%ebx)
	shift |= shiftcode[data];
f01002b3:	0f b6 d2             	movzbl %dl,%edx
f01002b6:	0f b6 84 13 d4 ce fe 	movzbl -0x1312c(%ebx,%edx,1),%eax
f01002bd:	ff 
f01002be:	0b 83 74 1d 00 00    	or     0x1d74(%ebx),%eax
	shift ^= togglecode[data];
f01002c4:	0f b6 8c 13 d4 cd fe 	movzbl -0x1322c(%ebx,%edx,1),%ecx
f01002cb:	ff 
f01002cc:	31 c8                	xor    %ecx,%eax
f01002ce:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002d4:	89 c1                	mov    %eax,%ecx
f01002d6:	83 e1 03             	and    $0x3,%ecx
f01002d9:	8b 8c 8b f4 1c 00 00 	mov    0x1cf4(%ebx,%ecx,4),%ecx
f01002e0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002e4:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002e7:	a8 08                	test   $0x8,%al
f01002e9:	74 61                	je     f010034c <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002eb:	89 f2                	mov    %esi,%edx
f01002ed:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002f0:	83 f9 19             	cmp    $0x19,%ecx
f01002f3:	77 4b                	ja     f0100340 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002f5:	83 ee 20             	sub    $0x20,%esi
f01002f8:	eb 0c                	jmp    f0100306 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002fa:	83 8b 74 1d 00 00 40 	orl    $0x40,0x1d74(%ebx)
		return 0;
f0100301:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100306:	89 f0                	mov    %esi,%eax
f0100308:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010030b:	5b                   	pop    %ebx
f010030c:	5e                   	pop    %esi
f010030d:	5d                   	pop    %ebp
f010030e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010030f:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f0100315:	83 e0 7f             	and    $0x7f,%eax
f0100318:	f6 c1 40             	test   $0x40,%cl
f010031b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031e:	0f b6 d2             	movzbl %dl,%edx
f0100321:	0f b6 84 13 d4 ce fe 	movzbl -0x1312c(%ebx,%edx,1),%eax
f0100328:	ff 
f0100329:	83 c8 40             	or     $0x40,%eax
f010032c:	0f b6 c0             	movzbl %al,%eax
f010032f:	f7 d0                	not    %eax
f0100331:	21 c8                	and    %ecx,%eax
f0100333:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
		return 0;
f0100339:	be 00 00 00 00       	mov    $0x0,%esi
f010033e:	eb c6                	jmp    f0100306 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f0100340:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100343:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100346:	83 fa 1a             	cmp    $0x1a,%edx
f0100349:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010034c:	f7 d0                	not    %eax
f010034e:	a8 06                	test   $0x6,%al
f0100350:	75 b4                	jne    f0100306 <kbd_proc_data+0xa2>
f0100352:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100358:	75 ac                	jne    f0100306 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f010035a:	83 ec 0c             	sub    $0xc,%esp
f010035d:	8d 83 95 cd fe ff    	lea    -0x1326b(%ebx),%eax
f0100363:	50                   	push   %eax
f0100364:	e8 2c 2c 00 00       	call   f0102f95 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f0100369:	b8 03 00 00 00       	mov    $0x3,%eax
f010036e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100373:	ee                   	out    %al,(%dx)
}
f0100374:	83 c4 10             	add    $0x10,%esp
f0100377:	eb 8d                	jmp    f0100306 <kbd_proc_data+0xa2>
		return -1;
f0100379:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010037e:	eb 86                	jmp    f0100306 <kbd_proc_data+0xa2>
		return -1;
f0100380:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100385:	e9 7c ff ff ff       	jmp    f0100306 <kbd_proc_data+0xa2>

f010038a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010038a:	55                   	push   %ebp
f010038b:	89 e5                	mov    %esp,%ebp
f010038d:	57                   	push   %edi
f010038e:	56                   	push   %esi
f010038f:	53                   	push   %ebx
f0100390:	83 ec 1c             	sub    $0x1c,%esp
f0100393:	e8 4a fe ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0100398:	81 c3 74 6f 01 00    	add    $0x16f74,%ebx
f010039e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f01003a1:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a6:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01003ab:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b0:	89 fa                	mov    %edi,%edx
f01003b2:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003b3:	a8 20                	test   $0x20,%al
f01003b5:	75 13                	jne    f01003ca <cons_putc+0x40>
f01003b7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003bd:	7f 0b                	jg     f01003ca <cons_putc+0x40>
f01003bf:	89 ca                	mov    %ecx,%edx
f01003c1:	ec                   	in     (%dx),%al
f01003c2:	ec                   	in     (%dx),%al
f01003c3:	ec                   	in     (%dx),%al
f01003c4:	ec                   	in     (%dx),%al
	     i++)
f01003c5:	83 c6 01             	add    $0x1,%esi
f01003c8:	eb e6                	jmp    f01003b0 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003ca:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003ce:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f01003d1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003d6:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003d7:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003dc:	bf 79 03 00 00       	mov    $0x379,%edi
f01003e1:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003e6:	89 fa                	mov    %edi,%edx
f01003e8:	ec                   	in     (%dx),%al
f01003e9:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ef:	7f 0f                	jg     f0100400 <cons_putc+0x76>
f01003f1:	84 c0                	test   %al,%al
f01003f3:	78 0b                	js     f0100400 <cons_putc+0x76>
f01003f5:	89 ca                	mov    %ecx,%edx
f01003f7:	ec                   	in     (%dx),%al
f01003f8:	ec                   	in     (%dx),%al
f01003f9:	ec                   	in     (%dx),%al
f01003fa:	ec                   	in     (%dx),%al
f01003fb:	83 c6 01             	add    $0x1,%esi
f01003fe:	eb e6                	jmp    f01003e6 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f0100400:	ba 78 03 00 00       	mov    $0x378,%edx
f0100405:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100409:	ee                   	out    %al,(%dx)
f010040a:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010040f:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100414:	ee                   	out    %al,(%dx)
f0100415:	b8 08 00 00 00       	mov    $0x8,%eax
f010041a:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010041e:	89 f8                	mov    %edi,%eax
f0100420:	80 cc 07             	or     $0x7,%ah
f0100423:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100429:	0f 45 c7             	cmovne %edi,%eax
f010042c:	89 c7                	mov    %eax,%edi
f010042e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100431:	0f b6 c0             	movzbl %al,%eax
f0100434:	89 f9                	mov    %edi,%ecx
f0100436:	80 f9 0a             	cmp    $0xa,%cl
f0100439:	0f 84 e4 00 00 00    	je     f0100523 <cons_putc+0x199>
f010043f:	83 f8 0a             	cmp    $0xa,%eax
f0100442:	7f 46                	jg     f010048a <cons_putc+0x100>
f0100444:	83 f8 08             	cmp    $0x8,%eax
f0100447:	0f 84 a8 00 00 00    	je     f01004f5 <cons_putc+0x16b>
f010044d:	83 f8 09             	cmp    $0x9,%eax
f0100450:	0f 85 da 00 00 00    	jne    f0100530 <cons_putc+0x1a6>
		cons_putc(' ');
f0100456:	b8 20 00 00 00       	mov    $0x20,%eax
f010045b:	e8 2a ff ff ff       	call   f010038a <cons_putc>
		cons_putc(' ');
f0100460:	b8 20 00 00 00       	mov    $0x20,%eax
f0100465:	e8 20 ff ff ff       	call   f010038a <cons_putc>
		cons_putc(' ');
f010046a:	b8 20 00 00 00       	mov    $0x20,%eax
f010046f:	e8 16 ff ff ff       	call   f010038a <cons_putc>
		cons_putc(' ');
f0100474:	b8 20 00 00 00       	mov    $0x20,%eax
f0100479:	e8 0c ff ff ff       	call   f010038a <cons_putc>
		cons_putc(' ');
f010047e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100483:	e8 02 ff ff ff       	call   f010038a <cons_putc>
		break;
f0100488:	eb 26                	jmp    f01004b0 <cons_putc+0x126>
	switch (c & 0xff) {
f010048a:	83 f8 0d             	cmp    $0xd,%eax
f010048d:	0f 85 9d 00 00 00    	jne    f0100530 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100493:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f010049a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004a0:	c1 e8 16             	shr    $0x16,%eax
f01004a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004a6:	c1 e0 04             	shl    $0x4,%eax
f01004a9:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01004b0:	66 81 bb 9c 1f 00 00 	cmpw   $0x7cf,0x1f9c(%ebx)
f01004b7:	cf 07 
f01004b9:	0f 87 98 00 00 00    	ja     f0100557 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f01004bf:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f01004c5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ca:	89 ca                	mov    %ecx,%edx
f01004cc:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004cd:	0f b7 9b 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%ebx
f01004d4:	8d 71 01             	lea    0x1(%ecx),%esi
f01004d7:	89 d8                	mov    %ebx,%eax
f01004d9:	66 c1 e8 08          	shr    $0x8,%ax
f01004dd:	89 f2                	mov    %esi,%edx
f01004df:	ee                   	out    %al,(%dx)
f01004e0:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004e5:	89 ca                	mov    %ecx,%edx
f01004e7:	ee                   	out    %al,(%dx)
f01004e8:	89 d8                	mov    %ebx,%eax
f01004ea:	89 f2                	mov    %esi,%edx
f01004ec:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004f0:	5b                   	pop    %ebx
f01004f1:	5e                   	pop    %esi
f01004f2:	5f                   	pop    %edi
f01004f3:	5d                   	pop    %ebp
f01004f4:	c3                   	ret    
		if (crt_pos > 0) {
f01004f5:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f01004fc:	66 85 c0             	test   %ax,%ax
f01004ff:	74 be                	je     f01004bf <cons_putc+0x135>
			crt_pos--;
f0100501:	83 e8 01             	sub    $0x1,%eax
f0100504:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010050b:	0f b7 c0             	movzwl %ax,%eax
f010050e:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100512:	b2 00                	mov    $0x0,%dl
f0100514:	83 ca 20             	or     $0x20,%edx
f0100517:	8b 8b a0 1f 00 00    	mov    0x1fa0(%ebx),%ecx
f010051d:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100521:	eb 8d                	jmp    f01004b0 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f0100523:	66 83 83 9c 1f 00 00 	addw   $0x50,0x1f9c(%ebx)
f010052a:	50 
f010052b:	e9 63 ff ff ff       	jmp    f0100493 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100530:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f0100537:	8d 50 01             	lea    0x1(%eax),%edx
f010053a:	66 89 93 9c 1f 00 00 	mov    %dx,0x1f9c(%ebx)
f0100541:	0f b7 c0             	movzwl %ax,%eax
f0100544:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f010054a:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f010054e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100552:	e9 59 ff ff ff       	jmp    f01004b0 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100557:	8b 83 a0 1f 00 00    	mov    0x1fa0(%ebx),%eax
f010055d:	83 ec 04             	sub    $0x4,%esp
f0100560:	68 00 0f 00 00       	push   $0xf00
f0100565:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010056b:	52                   	push   %edx
f010056c:	50                   	push   %eax
f010056d:	e8 7b 36 00 00       	call   f0103bed <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100572:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f0100578:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010057e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100584:	83 c4 10             	add    $0x10,%esp
f0100587:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010058c:	83 c0 02             	add    $0x2,%eax
f010058f:	39 d0                	cmp    %edx,%eax
f0100591:	75 f4                	jne    f0100587 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100593:	66 83 ab 9c 1f 00 00 	subw   $0x50,0x1f9c(%ebx)
f010059a:	50 
f010059b:	e9 1f ff ff ff       	jmp    f01004bf <cons_putc+0x135>

f01005a0 <serial_intr>:
{
f01005a0:	e8 cf 01 00 00       	call   f0100774 <__x86.get_pc_thunk.ax>
f01005a5:	05 67 6d 01 00       	add    $0x16d67,%eax
	if (serial_exists)
f01005aa:	80 b8 a8 1f 00 00 00 	cmpb   $0x0,0x1fa8(%eax)
f01005b1:	75 01                	jne    f01005b4 <serial_intr+0x14>
f01005b3:	c3                   	ret    
{
f01005b4:	55                   	push   %ebp
f01005b5:	89 e5                	mov    %esp,%ebp
f01005b7:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005ba:	8d 80 da 8e fe ff    	lea    -0x17126(%eax),%eax
f01005c0:	e8 3b fc ff ff       	call   f0100200 <cons_intr>
}
f01005c5:	c9                   	leave  
f01005c6:	c3                   	ret    

f01005c7 <kbd_intr>:
{
f01005c7:	55                   	push   %ebp
f01005c8:	89 e5                	mov    %esp,%ebp
f01005ca:	83 ec 08             	sub    $0x8,%esp
f01005cd:	e8 a2 01 00 00       	call   f0100774 <__x86.get_pc_thunk.ax>
f01005d2:	05 3a 6d 01 00       	add    $0x16d3a,%eax
	cons_intr(kbd_proc_data);
f01005d7:	8d 80 58 8f fe ff    	lea    -0x170a8(%eax),%eax
f01005dd:	e8 1e fc ff ff       	call   f0100200 <cons_intr>
}
f01005e2:	c9                   	leave  
f01005e3:	c3                   	ret    

f01005e4 <cons_getc>:
{
f01005e4:	55                   	push   %ebp
f01005e5:	89 e5                	mov    %esp,%ebp
f01005e7:	53                   	push   %ebx
f01005e8:	83 ec 04             	sub    $0x4,%esp
f01005eb:	e8 f2 fb ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f01005f0:	81 c3 1c 6d 01 00    	add    $0x16d1c,%ebx
	serial_intr();
f01005f6:	e8 a5 ff ff ff       	call   f01005a0 <serial_intr>
	kbd_intr();
f01005fb:	e8 c7 ff ff ff       	call   f01005c7 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100600:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
	return 0;
f0100606:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010060b:	3b 83 98 1f 00 00    	cmp    0x1f98(%ebx),%eax
f0100611:	74 1e                	je     f0100631 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f0100613:	8d 48 01             	lea    0x1(%eax),%ecx
f0100616:	0f b6 94 03 94 1d 00 	movzbl 0x1d94(%ebx,%eax,1),%edx
f010061d:	00 
			cons.rpos = 0;
f010061e:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100623:	b8 00 00 00 00       	mov    $0x0,%eax
f0100628:	0f 45 c1             	cmovne %ecx,%eax
f010062b:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
}
f0100631:	89 d0                	mov    %edx,%eax
f0100633:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100636:	c9                   	leave  
f0100637:	c3                   	ret    

f0100638 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100638:	55                   	push   %ebp
f0100639:	89 e5                	mov    %esp,%ebp
f010063b:	57                   	push   %edi
f010063c:	56                   	push   %esi
f010063d:	53                   	push   %ebx
f010063e:	83 ec 1c             	sub    $0x1c,%esp
f0100641:	e8 9c fb ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0100646:	81 c3 c6 6c 01 00    	add    $0x16cc6,%ebx
	was = *cp;
f010064c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100653:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010065a:	5a a5 
	if (*cp != 0xA55A) {
f010065c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100663:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100668:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f010066d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100671:	0f 84 ac 00 00 00    	je     f0100723 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100677:	89 8b a4 1f 00 00    	mov    %ecx,0x1fa4(%ebx)
f010067d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100682:	89 ca                	mov    %ecx,%edx
f0100684:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100685:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100688:	89 f2                	mov    %esi,%edx
f010068a:	ec                   	in     (%dx),%al
f010068b:	0f b6 c0             	movzbl %al,%eax
f010068e:	c1 e0 08             	shl    $0x8,%eax
f0100691:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f0100694:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100699:	89 ca                	mov    %ecx,%edx
f010069b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069c:	89 f2                	mov    %esi,%edx
f010069e:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010069f:	89 bb a0 1f 00 00    	mov    %edi,0x1fa0(%ebx)
	pos |= inb(addr_6845 + 1);
f01006a5:	0f b6 c0             	movzbl %al,%eax
f01006a8:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f01006ab:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f01006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b7:	89 c8                	mov    %ecx,%eax
f01006b9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006be:	ee                   	out    %al,(%dx)
f01006bf:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006c4:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c9:	89 fa                	mov    %edi,%edx
f01006cb:	ee                   	out    %al,(%dx)
f01006cc:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006d1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006d6:	ee                   	out    %al,(%dx)
f01006d7:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006dc:	89 c8                	mov    %ecx,%eax
f01006de:	89 f2                	mov    %esi,%edx
f01006e0:	ee                   	out    %al,(%dx)
f01006e1:	b8 03 00 00 00       	mov    $0x3,%eax
f01006e6:	89 fa                	mov    %edi,%edx
f01006e8:	ee                   	out    %al,(%dx)
f01006e9:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006ee:	89 c8                	mov    %ecx,%eax
f01006f0:	ee                   	out    %al,(%dx)
f01006f1:	b8 01 00 00 00       	mov    $0x1,%eax
f01006f6:	89 f2                	mov    %esi,%edx
f01006f8:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f9:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006fe:	ec                   	in     (%dx),%al
f01006ff:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100701:	3c ff                	cmp    $0xff,%al
f0100703:	0f 95 83 a8 1f 00 00 	setne  0x1fa8(%ebx)
f010070a:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010070f:	ec                   	in     (%dx),%al
f0100710:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100715:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100716:	80 f9 ff             	cmp    $0xff,%cl
f0100719:	74 1e                	je     f0100739 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f010071b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010071e:	5b                   	pop    %ebx
f010071f:	5e                   	pop    %esi
f0100720:	5f                   	pop    %edi
f0100721:	5d                   	pop    %ebp
f0100722:	c3                   	ret    
		*cp = was;
f0100723:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f010072a:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010072f:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f0100734:	e9 3e ff ff ff       	jmp    f0100677 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f0100739:	83 ec 0c             	sub    $0xc,%esp
f010073c:	8d 83 a1 cd fe ff    	lea    -0x1325f(%ebx),%eax
f0100742:	50                   	push   %eax
f0100743:	e8 4d 28 00 00       	call   f0102f95 <cprintf>
f0100748:	83 c4 10             	add    $0x10,%esp
}
f010074b:	eb ce                	jmp    f010071b <cons_init+0xe3>

f010074d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074d:	55                   	push   %ebp
f010074e:	89 e5                	mov    %esp,%ebp
f0100750:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100753:	8b 45 08             	mov    0x8(%ebp),%eax
f0100756:	e8 2f fc ff ff       	call   f010038a <cons_putc>
}
f010075b:	c9                   	leave  
f010075c:	c3                   	ret    

f010075d <getchar>:

int
getchar(void)
{
f010075d:	55                   	push   %ebp
f010075e:	89 e5                	mov    %esp,%ebp
f0100760:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100763:	e8 7c fe ff ff       	call   f01005e4 <cons_getc>
f0100768:	85 c0                	test   %eax,%eax
f010076a:	74 f7                	je     f0100763 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010076c:	c9                   	leave  
f010076d:	c3                   	ret    

f010076e <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f010076e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100773:	c3                   	ret    

f0100774 <__x86.get_pc_thunk.ax>:
f0100774:	8b 04 24             	mov    (%esp),%eax
f0100777:	c3                   	ret    

f0100778 <__x86.get_pc_thunk.si>:
f0100778:	8b 34 24             	mov    (%esp),%esi
f010077b:	c3                   	ret    

f010077c <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010077c:	55                   	push   %ebp
f010077d:	89 e5                	mov    %esp,%ebp
f010077f:	56                   	push   %esi
f0100780:	53                   	push   %ebx
f0100781:	e8 5c fa ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0100786:	81 c3 86 6b 01 00    	add    $0x16b86,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010078c:	83 ec 04             	sub    $0x4,%esp
f010078f:	8d 83 d4 cf fe ff    	lea    -0x1302c(%ebx),%eax
f0100795:	50                   	push   %eax
f0100796:	8d 83 f2 cf fe ff    	lea    -0x1300e(%ebx),%eax
f010079c:	50                   	push   %eax
f010079d:	8d b3 f7 cf fe ff    	lea    -0x13009(%ebx),%esi
f01007a3:	56                   	push   %esi
f01007a4:	e8 ec 27 00 00       	call   f0102f95 <cprintf>
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	8d 83 78 d0 fe ff    	lea    -0x12f88(%ebx),%eax
f01007b2:	50                   	push   %eax
f01007b3:	8d 83 00 d0 fe ff    	lea    -0x13000(%ebx),%eax
f01007b9:	50                   	push   %eax
f01007ba:	56                   	push   %esi
f01007bb:	e8 d5 27 00 00       	call   f0102f95 <cprintf>
f01007c0:	83 c4 0c             	add    $0xc,%esp
f01007c3:	8d 83 a0 d0 fe ff    	lea    -0x12f60(%ebx),%eax
f01007c9:	50                   	push   %eax
f01007ca:	8d 83 09 d0 fe ff    	lea    -0x12ff7(%ebx),%eax
f01007d0:	50                   	push   %eax
f01007d1:	56                   	push   %esi
f01007d2:	e8 be 27 00 00       	call   f0102f95 <cprintf>
	return 0;
}
f01007d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007df:	5b                   	pop    %ebx
f01007e0:	5e                   	pop    %esi
f01007e1:	5d                   	pop    %ebp
f01007e2:	c3                   	ret    

f01007e3 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007e3:	55                   	push   %ebp
f01007e4:	89 e5                	mov    %esp,%ebp
f01007e6:	57                   	push   %edi
f01007e7:	56                   	push   %esi
f01007e8:	53                   	push   %ebx
f01007e9:	83 ec 18             	sub    $0x18,%esp
f01007ec:	e8 f1 f9 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f01007f1:	81 c3 1b 6b 01 00    	add    $0x16b1b,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f7:	8d 83 13 d0 fe ff    	lea    -0x12fed(%ebx),%eax
f01007fd:	50                   	push   %eax
f01007fe:	e8 92 27 00 00       	call   f0102f95 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100803:	83 c4 08             	add    $0x8,%esp
f0100806:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f010080c:	8d 83 d0 d0 fe ff    	lea    -0x12f30(%ebx),%eax
f0100812:	50                   	push   %eax
f0100813:	e8 7d 27 00 00       	call   f0102f95 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100818:	83 c4 0c             	add    $0xc,%esp
f010081b:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100821:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100827:	50                   	push   %eax
f0100828:	57                   	push   %edi
f0100829:	8d 83 f8 d0 fe ff    	lea    -0x12f08(%ebx),%eax
f010082f:	50                   	push   %eax
f0100830:	e8 60 27 00 00       	call   f0102f95 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	c7 c0 d1 3f 10 f0    	mov    $0xf0103fd1,%eax
f010083e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100844:	52                   	push   %edx
f0100845:	50                   	push   %eax
f0100846:	8d 83 1c d1 fe ff    	lea    -0x12ee4(%ebx),%eax
f010084c:	50                   	push   %eax
f010084d:	e8 43 27 00 00       	call   f0102f95 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100852:	83 c4 0c             	add    $0xc,%esp
f0100855:	c7 c0 60 90 11 f0    	mov    $0xf0119060,%eax
f010085b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100861:	52                   	push   %edx
f0100862:	50                   	push   %eax
f0100863:	8d 83 40 d1 fe ff    	lea    -0x12ec0(%ebx),%eax
f0100869:	50                   	push   %eax
f010086a:	e8 26 27 00 00       	call   f0102f95 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086f:	83 c4 0c             	add    $0xc,%esp
f0100872:	c7 c6 e0 96 11 f0    	mov    $0xf01196e0,%esi
f0100878:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010087e:	50                   	push   %eax
f010087f:	56                   	push   %esi
f0100880:	8d 83 64 d1 fe ff    	lea    -0x12e9c(%ebx),%eax
f0100886:	50                   	push   %eax
f0100887:	e8 09 27 00 00       	call   f0102f95 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088f:	29 fe                	sub    %edi,%esi
f0100891:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100897:	c1 fe 0a             	sar    $0xa,%esi
f010089a:	56                   	push   %esi
f010089b:	8d 83 88 d1 fe ff    	lea    -0x12e78(%ebx),%eax
f01008a1:	50                   	push   %eax
f01008a2:	e8 ee 26 00 00       	call   f0102f95 <cprintf>
	return 0;
}
f01008a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008af:	5b                   	pop    %ebx
f01008b0:	5e                   	pop    %esi
f01008b1:	5f                   	pop    %edi
f01008b2:	5d                   	pop    %ebp
f01008b3:	c3                   	ret    

f01008b4 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b4:	55                   	push   %ebp
f01008b5:	89 e5                	mov    %esp,%ebp
f01008b7:	57                   	push   %edi
f01008b8:	56                   	push   %esi
f01008b9:	53                   	push   %ebx
f01008ba:	83 ec 48             	sub    $0x48,%esp
f01008bd:	e8 20 f9 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f01008c2:	81 c3 4a 6a 01 00    	add    $0x16a4a,%ebx

static inline uint32_t
read_esp(void)
{
	uint32_t esp;
	asm volatile("movl %%esp,%0" : "=r" (esp));
f01008c8:	89 e6                	mov    %esp,%esi

    reg_ebp=read_esp();
    ebp_ptr=(int*) reg_ebp ;  // typecast adress into int
    

    cprintf("Backtracing current STACK functions : ");
f01008ca:	8d 83 b4 d1 fe ff    	lea    -0x12e4c(%ebx),%eax
f01008d0:	50                   	push   %eax
f01008d1:	e8 bf 26 00 00       	call   f0102f95 <cprintf>

    while( ebp_ptr != NULL)
f01008d6:	83 c4 10             	add    $0x10,%esp
    {

    cprintf("Stack bactrace: \n\r epb %x eip %x args  %08x %08x %08x %08x ", (int)ebp_ptr, *(ebp_ptr+1), *(ebp_ptr+2),
f01008d9:	8d bb dc d1 fe ff    	lea    -0x12e24(%ebx),%edi
     *(ebp_ptr+2), *(ebp_ptr+3), *(ebp_ptr+4), *(ebp_ptr+5), *(ebp_ptr+6));
	
	debuginfo_eip(*(ebp_ptr + 1), &info);

	cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name,
f01008df:	8d 83 2c d0 fe ff    	lea    -0x12fd4(%ebx),%eax
f01008e5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    while( ebp_ptr != NULL)
f01008e8:	eb 50                	jmp    f010093a <mon_backtrace+0x86>
    cprintf("Stack bactrace: \n\r epb %x eip %x args  %08x %08x %08x %08x ", (int)ebp_ptr, *(ebp_ptr+1), *(ebp_ptr+2),
f01008ea:	8b 46 08             	mov    0x8(%esi),%eax
f01008ed:	83 ec 0c             	sub    $0xc,%esp
f01008f0:	ff 76 18             	push   0x18(%esi)
f01008f3:	ff 76 14             	push   0x14(%esi)
f01008f6:	ff 76 10             	push   0x10(%esi)
f01008f9:	ff 76 0c             	push   0xc(%esi)
f01008fc:	50                   	push   %eax
f01008fd:	50                   	push   %eax
f01008fe:	ff 76 04             	push   0x4(%esi)
f0100901:	56                   	push   %esi
f0100902:	57                   	push   %edi
f0100903:	e8 8d 26 00 00       	call   f0102f95 <cprintf>
	debuginfo_eip(*(ebp_ptr + 1), &info);
f0100908:	83 c4 28             	add    $0x28,%esp
f010090b:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010090e:	50                   	push   %eax
f010090f:	ff 76 04             	push   0x4(%esi)
f0100912:	e8 87 27 00 00       	call   f010309e <debuginfo_eip>
	cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name,
f0100917:	83 c4 08             	add    $0x8,%esp
f010091a:	8b 46 04             	mov    0x4(%esi),%eax
f010091d:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100920:	50                   	push   %eax
f0100921:	ff 75 d8             	push   -0x28(%ebp)
f0100924:	ff 75 dc             	push   -0x24(%ebp)
f0100927:	ff 75 d4             	push   -0x2c(%ebp)
f010092a:	ff 75 d0             	push   -0x30(%ebp)
f010092d:	ff 75 c4             	push   -0x3c(%ebp)
f0100930:	e8 60 26 00 00       	call   f0102f95 <cprintf>
	 *(ebp_ptr + 1) - info.eip_fn_addr);
		
	ebp_ptr = (int *)*ebp_ptr;
f0100935:	8b 36                	mov    (%esi),%esi
f0100937:	83 c4 20             	add    $0x20,%esp
    while( ebp_ptr != NULL)
f010093a:	85 f6                	test   %esi,%esi
f010093c:	75 ac                	jne    f01008ea <mon_backtrace+0x36>


	}    
        
	return 0;
}
f010093e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100943:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100946:	5b                   	pop    %ebx
f0100947:	5e                   	pop    %esi
f0100948:	5f                   	pop    %edi
f0100949:	5d                   	pop    %ebp
f010094a:	c3                   	ret    

f010094b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010094b:	55                   	push   %ebp
f010094c:	89 e5                	mov    %esp,%ebp
f010094e:	57                   	push   %edi
f010094f:	56                   	push   %esi
f0100950:	53                   	push   %ebx
f0100951:	83 ec 68             	sub    $0x68,%esp
f0100954:	e8 89 f8 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0100959:	81 c3 b3 69 01 00    	add    $0x169b3,%ebx
	char *buf=NULL;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010095f:	8d 83 18 d2 fe ff    	lea    -0x12de8(%ebx),%eax
f0100965:	50                   	push   %eax
f0100966:	e8 2a 26 00 00       	call   f0102f95 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010096b:	8d 83 3c d2 fe ff    	lea    -0x12dc4(%ebx),%eax
f0100971:	89 04 24             	mov    %eax,(%esp)
f0100974:	e8 1c 26 00 00       	call   f0102f95 <cprintf>
f0100979:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010097c:	8d bb 40 d0 fe ff    	lea    -0x12fc0(%ebx),%edi
f0100982:	eb 4a                	jmp    f01009ce <monitor+0x83>
f0100984:	83 ec 08             	sub    $0x8,%esp
f0100987:	0f be c0             	movsbl %al,%eax
f010098a:	50                   	push   %eax
f010098b:	57                   	push   %edi
f010098c:	e8 d7 31 00 00       	call   f0103b68 <strchr>
f0100991:	83 c4 10             	add    $0x10,%esp
f0100994:	85 c0                	test   %eax,%eax
f0100996:	74 08                	je     f01009a0 <monitor+0x55>
			*buf++ = 0;
f0100998:	c6 06 00             	movb   $0x0,(%esi)
f010099b:	8d 76 01             	lea    0x1(%esi),%esi
f010099e:	eb 76                	jmp    f0100a16 <monitor+0xcb>
		if (*buf == 0)
f01009a0:	80 3e 00             	cmpb   $0x0,(%esi)
f01009a3:	74 7c                	je     f0100a21 <monitor+0xd6>
		if (argc == MAXARGS-1) {
f01009a5:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009a9:	74 0f                	je     f01009ba <monitor+0x6f>
		argv[argc++] = buf;
f01009ab:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009ae:	8d 48 01             	lea    0x1(%eax),%ecx
f01009b1:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009b4:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009b8:	eb 41                	jmp    f01009fb <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009ba:	83 ec 08             	sub    $0x8,%esp
f01009bd:	6a 10                	push   $0x10
f01009bf:	8d 83 45 d0 fe ff    	lea    -0x12fbb(%ebx),%eax
f01009c5:	50                   	push   %eax
f01009c6:	e8 ca 25 00 00       	call   f0102f95 <cprintf>
			return 0;
f01009cb:	83 c4 10             	add    $0x10,%esp

#if 1
	while (1) {
		buf = readline("K> ");
f01009ce:	8d 83 3c d0 fe ff    	lea    -0x12fc4(%ebx),%eax
f01009d4:	89 c6                	mov    %eax,%esi
f01009d6:	83 ec 0c             	sub    $0xc,%esp
f01009d9:	56                   	push   %esi
f01009da:	e8 38 2f 00 00       	call   f0103917 <readline>
		if (buf != NULL)
f01009df:	83 c4 10             	add    $0x10,%esp
f01009e2:	85 c0                	test   %eax,%eax
f01009e4:	74 f0                	je     f01009d6 <monitor+0x8b>
	argv[argc] = 0;
f01009e6:	89 c6                	mov    %eax,%esi
f01009e8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009ef:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009f6:	eb 1e                	jmp    f0100a16 <monitor+0xcb>
			buf++;
f01009f8:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009fb:	0f b6 06             	movzbl (%esi),%eax
f01009fe:	84 c0                	test   %al,%al
f0100a00:	74 14                	je     f0100a16 <monitor+0xcb>
f0100a02:	83 ec 08             	sub    $0x8,%esp
f0100a05:	0f be c0             	movsbl %al,%eax
f0100a08:	50                   	push   %eax
f0100a09:	57                   	push   %edi
f0100a0a:	e8 59 31 00 00       	call   f0103b68 <strchr>
f0100a0f:	83 c4 10             	add    $0x10,%esp
f0100a12:	85 c0                	test   %eax,%eax
f0100a14:	74 e2                	je     f01009f8 <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a16:	0f b6 06             	movzbl (%esi),%eax
f0100a19:	84 c0                	test   %al,%al
f0100a1b:	0f 85 63 ff ff ff    	jne    f0100984 <monitor+0x39>
	argv[argc] = 0;
f0100a21:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a24:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a2b:	00 
	if (argc == 0)
f0100a2c:	85 c0                	test   %eax,%eax
f0100a2e:	74 9e                	je     f01009ce <monitor+0x83>
f0100a30:	8d b3 14 1d 00 00    	lea    0x1d14(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a36:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a3b:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a3e:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a40:	83 ec 08             	sub    $0x8,%esp
f0100a43:	ff 36                	push   (%esi)
f0100a45:	ff 75 a8             	push   -0x58(%ebp)
f0100a48:	e8 bb 30 00 00       	call   f0103b08 <strcmp>
f0100a4d:	83 c4 10             	add    $0x10,%esp
f0100a50:	85 c0                	test   %eax,%eax
f0100a52:	74 28                	je     f0100a7c <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a54:	83 c7 01             	add    $0x1,%edi
f0100a57:	83 c6 0c             	add    $0xc,%esi
f0100a5a:	83 ff 03             	cmp    $0x3,%edi
f0100a5d:	75 e1                	jne    f0100a40 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a5f:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a62:	83 ec 08             	sub    $0x8,%esp
f0100a65:	ff 75 a8             	push   -0x58(%ebp)
f0100a68:	8d 83 62 d0 fe ff    	lea    -0x12f9e(%ebx),%eax
f0100a6e:	50                   	push   %eax
f0100a6f:	e8 21 25 00 00       	call   f0102f95 <cprintf>
	return 0;
f0100a74:	83 c4 10             	add    $0x10,%esp
f0100a77:	e9 52 ff ff ff       	jmp    f01009ce <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a7c:	89 f8                	mov    %edi,%eax
f0100a7e:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a81:	83 ec 04             	sub    $0x4,%esp
f0100a84:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a87:	ff 75 08             	push   0x8(%ebp)
f0100a8a:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a8d:	52                   	push   %edx
f0100a8e:	ff 75 a4             	push   -0x5c(%ebp)
f0100a91:	ff 94 83 1c 1d 00 00 	call   *0x1d1c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a98:	83 c4 10             	add    $0x10,%esp
f0100a9b:	85 c0                	test   %eax,%eax
f0100a9d:	0f 89 2b ff ff ff    	jns    f01009ce <monitor+0x83>
				break;
	}

#endif
}
f0100aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa6:	5b                   	pop    %ebx
f0100aa7:	5e                   	pop    %esi
f0100aa8:	5f                   	pop    %edi
f0100aa9:	5d                   	pop    %ebp
f0100aaa:	c3                   	ret    

f0100aab <nvram_read>:
// --------------------------------------------------------------
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int nvram_read(int r)
{
f0100aab:	55                   	push   %ebp
f0100aac:	89 e5                	mov    %esp,%ebp
f0100aae:	57                   	push   %edi
f0100aaf:	56                   	push   %esi
f0100ab0:	53                   	push   %ebx
f0100ab1:	83 ec 18             	sub    $0x18,%esp
f0100ab4:	e8 29 f7 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0100ab9:	81 c3 53 68 01 00    	add    $0x16853,%ebx
f0100abf:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac1:	50                   	push   %eax
f0100ac2:	e8 47 24 00 00       	call   f0102f0e <mc146818_read>
f0100ac7:	89 c7                	mov    %eax,%edi
f0100ac9:	83 c6 01             	add    $0x1,%esi
f0100acc:	89 34 24             	mov    %esi,(%esp)
f0100acf:	e8 3a 24 00 00       	call   f0102f0e <mc146818_read>
f0100ad4:	c1 e0 08             	shl    $0x8,%eax
f0100ad7:	09 f8                	or     %edi,%eax
}
f0100ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100adc:	5b                   	pop    %ebx
f0100add:	5e                   	pop    %esi
f0100ade:	5f                   	pop    %edi
f0100adf:	5d                   	pop    %ebp
f0100ae0:	c3                   	ret    

f0100ae1 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ae1:	55                   	push   %ebp
f0100ae2:	89 e5                	mov    %esp,%ebp
f0100ae4:	53                   	push   %ebx
f0100ae5:	83 ec 04             	sub    $0x4,%esp
f0100ae8:	e8 15 24 00 00       	call   f0102f02 <__x86.get_pc_thunk.dx>
f0100aed:	81 c2 1f 68 01 00    	add    $0x1681f,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100af3:	83 ba b8 1f 00 00 00 	cmpl   $0x0,0x1fb8(%edx)
f0100afa:	74 31                	je     f0100b2d <boot_alloc+0x4c>
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	 
		//uint32_t array[n];
	result=nextfree ; // return resulting next free byte 
f0100afc:	8b 9a b8 1f 00 00    	mov    0x1fb8(%edx),%ebx

	nextfree=ROUNDUP(nextfree+n,PGSIZE); // "n bytes" must be multiple of PGSIZE segment
f0100b02:	8d 84 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%eax
f0100b09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b0e:	89 82 b8 1f 00 00    	mov    %eax,0x1fb8(%edx)
	
	if( (uint32_t) nextfree- KERNBASE > npages*PGSIZE)  // counting in bytes, not pages (npages*PGSIZE)
f0100b14:	05 00 00 00 10       	add    $0x10000000,%eax
f0100b19:	8b 8a b4 1f 00 00    	mov    0x1fb4(%edx),%ecx
f0100b1f:	c1 e1 0c             	shl    $0xc,%ecx
f0100b22:	39 c8                	cmp    %ecx,%eax
f0100b24:	77 21                	ja     f0100b47 <boot_alloc+0x66>
		{
			panic("boot_aloc : we are not having enough memory for VA to intialise \n");
		}
			
	return result;
}
f0100b26:	89 d8                	mov    %ebx,%eax
f0100b28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b2b:	c9                   	leave  
f0100b2c:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE); 
f0100b2d:	c7 c1 e0 96 11 f0    	mov    $0xf01196e0,%ecx
f0100b33:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100b39:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100b3f:	89 8a b8 1f 00 00    	mov    %ecx,0x1fb8(%edx)
f0100b45:	eb b5                	jmp    f0100afc <boot_alloc+0x1b>
			panic("boot_aloc : we are not having enough memory for VA to intialise \n");
f0100b47:	83 ec 04             	sub    $0x4,%esp
f0100b4a:	8d 82 64 d2 fe ff    	lea    -0x12d9c(%edx),%eax
f0100b50:	50                   	push   %eax
f0100b51:	6a 70                	push   $0x70
f0100b53:	8d 82 1d da fe ff    	lea    -0x125e3(%edx),%eax
f0100b59:	50                   	push   %eax
f0100b5a:	89 d3                	mov    %edx,%ebx
f0100b5c:	e8 cb f5 ff ff       	call   f010012c <_panic>

f0100b61 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b61:	55                   	push   %ebp
f0100b62:	89 e5                	mov    %esp,%ebp
f0100b64:	53                   	push   %ebx
f0100b65:	83 ec 04             	sub    $0x4,%esp
f0100b68:	e8 99 23 00 00       	call   f0102f06 <__x86.get_pc_thunk.cx>
f0100b6d:	81 c1 9f 67 01 00    	add    $0x1679f,%ecx
f0100b73:	89 c3                	mov    %eax,%ebx
f0100b75:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b77:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100b7a:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f0100b7d:	f6 c2 01             	test   $0x1,%dl
f0100b80:	74 54                	je     f0100bd6 <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b82:	89 d3                	mov    %edx,%ebx
f0100b84:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b8a:	c1 ea 0c             	shr    $0xc,%edx
f0100b8d:	3b 91 b4 1f 00 00    	cmp    0x1fb4(%ecx),%edx
f0100b93:	73 26                	jae    f0100bbb <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100b95:	c1 e8 0c             	shr    $0xc,%eax
f0100b98:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100b9d:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ba4:	89 d0                	mov    %edx,%eax
f0100ba6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bab:	f6 c2 01             	test   $0x1,%dl
f0100bae:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bb3:	0f 44 c2             	cmove  %edx,%eax
}
f0100bb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bb9:	c9                   	leave  
f0100bba:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bbb:	53                   	push   %ebx
f0100bbc:	8d 81 a8 d2 fe ff    	lea    -0x12d58(%ecx),%eax
f0100bc2:	50                   	push   %eax
f0100bc3:	68 37 03 00 00       	push   $0x337
f0100bc8:	8d 81 1d da fe ff    	lea    -0x125e3(%ecx),%eax
f0100bce:	50                   	push   %eax
f0100bcf:	89 cb                	mov    %ecx,%ebx
f0100bd1:	e8 56 f5 ff ff       	call   f010012c <_panic>
		return ~0;
f0100bd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bdb:	eb d9                	jmp    f0100bb6 <check_va2pa+0x55>

f0100bdd <check_page_free_list>:
{
f0100bdd:	55                   	push   %ebp
f0100bde:	89 e5                	mov    %esp,%ebp
f0100be0:	57                   	push   %edi
f0100be1:	56                   	push   %esi
f0100be2:	53                   	push   %ebx
f0100be3:	83 ec 2c             	sub    $0x2c,%esp
f0100be6:	e8 1f 23 00 00       	call   f0102f0a <__x86.get_pc_thunk.di>
f0100beb:	81 c7 21 67 01 00    	add    $0x16721,%edi
f0100bf1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bf4:	84 c0                	test   %al,%al
f0100bf6:	0f 85 dc 02 00 00    	jne    f0100ed8 <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100bfc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100bff:	83 b8 bc 1f 00 00 00 	cmpl   $0x0,0x1fbc(%eax)
f0100c06:	74 0a                	je     f0100c12 <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c08:	bf 00 04 00 00       	mov    $0x400,%edi
f0100c0d:	e9 29 03 00 00       	jmp    f0100f3b <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100c12:	83 ec 04             	sub    $0x4,%esp
f0100c15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c18:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100c1e:	50                   	push   %eax
f0100c1f:	68 77 02 00 00       	push   $0x277
f0100c24:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100c2a:	50                   	push   %eax
f0100c2b:	e8 fc f4 ff ff       	call   f010012c <_panic>
f0100c30:	50                   	push   %eax
f0100c31:	89 cb                	mov    %ecx,%ebx
f0100c33:	8d 81 a8 d2 fe ff    	lea    -0x12d58(%ecx),%eax
f0100c39:	50                   	push   %eax
f0100c3a:	6a 55                	push   $0x55
f0100c3c:	8d 81 29 da fe ff    	lea    -0x125d7(%ecx),%eax
f0100c42:	50                   	push   %eax
f0100c43:	e8 e4 f4 ff ff       	call   f010012c <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c48:	8b 36                	mov    (%esi),%esi
f0100c4a:	85 f6                	test   %esi,%esi
f0100c4c:	74 47                	je     f0100c95 <check_page_free_list+0xb8>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0100c4e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100c51:	89 f0                	mov    %esi,%eax
f0100c53:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0100c59:	c1 f8 03             	sar    $0x3,%eax
f0100c5c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c5f:	89 c2                	mov    %eax,%edx
f0100c61:	c1 ea 16             	shr    $0x16,%edx
f0100c64:	39 fa                	cmp    %edi,%edx
f0100c66:	73 e0                	jae    f0100c48 <check_page_free_list+0x6b>
	if (PGNUM(pa) >= npages)
f0100c68:	89 c2                	mov    %eax,%edx
f0100c6a:	c1 ea 0c             	shr    $0xc,%edx
f0100c6d:	3b 91 b4 1f 00 00    	cmp    0x1fb4(%ecx),%edx
f0100c73:	73 bb                	jae    f0100c30 <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100c75:	83 ec 04             	sub    $0x4,%esp
f0100c78:	68 80 00 00 00       	push   $0x80
f0100c7d:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c82:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c87:	50                   	push   %eax
f0100c88:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c8b:	e8 17 2f 00 00       	call   f0103ba7 <memset>
f0100c90:	83 c4 10             	add    $0x10,%esp
f0100c93:	eb b3                	jmp    f0100c48 <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100c95:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c9a:	e8 42 fe ff ff       	call   f0100ae1 <boot_alloc>
f0100c9f:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ca5:	8b 90 bc 1f 00 00    	mov    0x1fbc(%eax),%edx
		assert(pp >= pages);
f0100cab:	8b 88 ac 1f 00 00    	mov    0x1fac(%eax),%ecx
		assert(pp < pages + npages);
f0100cb1:	8b 80 b4 1f 00 00    	mov    0x1fb4(%eax),%eax
f0100cb7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100cba:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cbd:	bf 00 00 00 00       	mov    $0x0,%edi
f0100cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cc7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cca:	e9 07 01 00 00       	jmp    f0100dd6 <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0100ccf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cd2:	8d 83 37 da fe ff    	lea    -0x125c9(%ebx),%eax
f0100cd8:	50                   	push   %eax
f0100cd9:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100cdf:	50                   	push   %eax
f0100ce0:	68 91 02 00 00       	push   $0x291
f0100ce5:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100ceb:	50                   	push   %eax
f0100cec:	e8 3b f4 ff ff       	call   f010012c <_panic>
		assert(pp < pages + npages);
f0100cf1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cf4:	8d 83 58 da fe ff    	lea    -0x125a8(%ebx),%eax
f0100cfa:	50                   	push   %eax
f0100cfb:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100d01:	50                   	push   %eax
f0100d02:	68 92 02 00 00       	push   $0x292
f0100d07:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100d0d:	50                   	push   %eax
f0100d0e:	e8 19 f4 ff ff       	call   f010012c <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d13:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d16:	8d 83 f0 d2 fe ff    	lea    -0x12d10(%ebx),%eax
f0100d1c:	50                   	push   %eax
f0100d1d:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100d23:	50                   	push   %eax
f0100d24:	68 93 02 00 00       	push   $0x293
f0100d29:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100d2f:	50                   	push   %eax
f0100d30:	e8 f7 f3 ff ff       	call   f010012c <_panic>
		assert(page2pa(pp) != 0);
f0100d35:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d38:	8d 83 6c da fe ff    	lea    -0x12594(%ebx),%eax
f0100d3e:	50                   	push   %eax
f0100d3f:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100d45:	50                   	push   %eax
f0100d46:	68 96 02 00 00       	push   $0x296
f0100d4b:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100d51:	50                   	push   %eax
f0100d52:	e8 d5 f3 ff ff       	call   f010012c <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d57:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d5a:	8d 83 7d da fe ff    	lea    -0x12583(%ebx),%eax
f0100d60:	50                   	push   %eax
f0100d61:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100d67:	50                   	push   %eax
f0100d68:	68 97 02 00 00       	push   $0x297
f0100d6d:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100d73:	50                   	push   %eax
f0100d74:	e8 b3 f3 ff ff       	call   f010012c <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d79:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d7c:	8d 83 24 d3 fe ff    	lea    -0x12cdc(%ebx),%eax
f0100d82:	50                   	push   %eax
f0100d83:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100d89:	50                   	push   %eax
f0100d8a:	68 98 02 00 00       	push   $0x298
f0100d8f:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100d95:	50                   	push   %eax
f0100d96:	e8 91 f3 ff ff       	call   f010012c <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d9b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d9e:	8d 83 96 da fe ff    	lea    -0x1256a(%ebx),%eax
f0100da4:	50                   	push   %eax
f0100da5:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100dab:	50                   	push   %eax
f0100dac:	68 99 02 00 00       	push   $0x299
f0100db1:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100db7:	50                   	push   %eax
f0100db8:	e8 6f f3 ff ff       	call   f010012c <_panic>
	if (PGNUM(pa) >= npages)
f0100dbd:	89 c3                	mov    %eax,%ebx
f0100dbf:	c1 eb 0c             	shr    $0xc,%ebx
f0100dc2:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100dc5:	76 6d                	jbe    f0100e34 <check_page_free_list+0x257>
	return (void *)(pa + KERNBASE);
f0100dc7:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dcc:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100dcf:	77 7c                	ja     f0100e4d <check_page_free_list+0x270>
			++nfree_extmem;
f0100dd1:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dd4:	8b 12                	mov    (%edx),%edx
f0100dd6:	85 d2                	test   %edx,%edx
f0100dd8:	0f 84 91 00 00 00    	je     f0100e6f <check_page_free_list+0x292>
		assert(pp >= pages);
f0100dde:	39 d1                	cmp    %edx,%ecx
f0100de0:	0f 87 e9 fe ff ff    	ja     f0100ccf <check_page_free_list+0xf2>
		assert(pp < pages + npages);
f0100de6:	39 d6                	cmp    %edx,%esi
f0100de8:	0f 86 03 ff ff ff    	jbe    f0100cf1 <check_page_free_list+0x114>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dee:	89 d0                	mov    %edx,%eax
f0100df0:	29 c8                	sub    %ecx,%eax
f0100df2:	a8 07                	test   $0x7,%al
f0100df4:	0f 85 19 ff ff ff    	jne    f0100d13 <check_page_free_list+0x136>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0100dfa:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100dfd:	c1 e0 0c             	shl    $0xc,%eax
f0100e00:	0f 84 2f ff ff ff    	je     f0100d35 <check_page_free_list+0x158>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e06:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e0b:	0f 84 46 ff ff ff    	je     f0100d57 <check_page_free_list+0x17a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e11:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e16:	0f 84 5d ff ff ff    	je     f0100d79 <check_page_free_list+0x19c>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e1c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e21:	0f 84 74 ff ff ff    	je     f0100d9b <check_page_free_list+0x1be>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e27:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e2c:	77 8f                	ja     f0100dbd <check_page_free_list+0x1e0>
			++nfree_basemem;
f0100e2e:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100e32:	eb a0                	jmp    f0100dd4 <check_page_free_list+0x1f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e34:	50                   	push   %eax
f0100e35:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e38:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0100e3e:	50                   	push   %eax
f0100e3f:	6a 55                	push   $0x55
f0100e41:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f0100e47:	50                   	push   %eax
f0100e48:	e8 df f2 ff ff       	call   f010012c <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e4d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e50:	8d 83 48 d3 fe ff    	lea    -0x12cb8(%ebx),%eax
f0100e56:	50                   	push   %eax
f0100e57:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100e5d:	50                   	push   %eax
f0100e5e:	68 9a 02 00 00       	push   $0x29a
f0100e63:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100e69:	50                   	push   %eax
f0100e6a:	e8 bd f2 ff ff       	call   f010012c <_panic>
	assert(nfree_basemem > 0);
f0100e6f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e72:	85 db                	test   %ebx,%ebx
f0100e74:	7e 1e                	jle    f0100e94 <check_page_free_list+0x2b7>
	assert(nfree_extmem > 0);
f0100e76:	85 ff                	test   %edi,%edi
f0100e78:	7e 3c                	jle    f0100eb6 <check_page_free_list+0x2d9>
	cprintf("check_page_free_list() succeeded!\n");
f0100e7a:	83 ec 0c             	sub    $0xc,%esp
f0100e7d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e80:	8d 83 90 d3 fe ff    	lea    -0x12c70(%ebx),%eax
f0100e86:	50                   	push   %eax
f0100e87:	e8 09 21 00 00       	call   f0102f95 <cprintf>
}
f0100e8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e8f:	5b                   	pop    %ebx
f0100e90:	5e                   	pop    %esi
f0100e91:	5f                   	pop    %edi
f0100e92:	5d                   	pop    %ebp
f0100e93:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e94:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e97:	8d 83 b0 da fe ff    	lea    -0x12550(%ebx),%eax
f0100e9d:	50                   	push   %eax
f0100e9e:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100ea4:	50                   	push   %eax
f0100ea5:	68 a2 02 00 00       	push   $0x2a2
f0100eaa:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100eb0:	50                   	push   %eax
f0100eb1:	e8 76 f2 ff ff       	call   f010012c <_panic>
	assert(nfree_extmem > 0);
f0100eb6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100eb9:	8d 83 c2 da fe ff    	lea    -0x1253e(%ebx),%eax
f0100ebf:	50                   	push   %eax
f0100ec0:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0100ec6:	50                   	push   %eax
f0100ec7:	68 a3 02 00 00       	push   $0x2a3
f0100ecc:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0100ed2:	50                   	push   %eax
f0100ed3:	e8 54 f2 ff ff       	call   f010012c <_panic>
	if (!page_free_list)
f0100ed8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100edb:	8b 80 bc 1f 00 00    	mov    0x1fbc(%eax),%eax
f0100ee1:	85 c0                	test   %eax,%eax
f0100ee3:	0f 84 29 fd ff ff    	je     f0100c12 <check_page_free_list+0x35>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ee9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100eec:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100eef:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ef2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0100ef5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100ef8:	89 c2                	mov    %eax,%edx
f0100efa:	2b 97 ac 1f 00 00    	sub    0x1fac(%edi),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f00:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f06:	0f 95 c2             	setne  %dl
f0100f09:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f0c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f10:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f12:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f16:	8b 00                	mov    (%eax),%eax
f0100f18:	85 c0                	test   %eax,%eax
f0100f1a:	75 d9                	jne    f0100ef5 <check_page_free_list+0x318>
		*tp[1] = 0;
f0100f1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f1f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f25:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f28:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f2b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f2d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f30:	89 87 bc 1f 00 00    	mov    %eax,0x1fbc(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f36:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f3e:	8b b0 bc 1f 00 00    	mov    0x1fbc(%eax),%esi
f0100f44:	e9 01 fd ff ff       	jmp    f0100c4a <check_page_free_list+0x6d>

f0100f49 <page_init>:
{
f0100f49:	55                   	push   %ebp
f0100f4a:	89 e5                	mov    %esp,%ebp
f0100f4c:	57                   	push   %edi
f0100f4d:	56                   	push   %esi
f0100f4e:	53                   	push   %ebx
f0100f4f:	83 ec 1c             	sub    $0x1c,%esp
f0100f52:	e8 8b f2 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0100f57:	81 c3 b5 63 01 00    	add    $0x163b5,%ebx
	page_free_list=NULL;
f0100f5d:	c7 83 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%ebx)
f0100f64:	00 00 00 
	uint32_t next_free_address= ((uint32_t) boot_alloc(0) / PGSIZE); // return next free char pointer addr
f0100f67:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f6c:	e8 70 fb ff ff       	call   f0100ae1 <boot_alloc>
		if( i >=  npages_basemem  &&  i <  npages_basemem + IOPHYSMEM-EXTPHYSMEM/PGSIZE+ next_free_address )
f0100f71:	8b bb c0 1f 00 00    	mov    0x1fc0(%ebx),%edi
	uint32_t next_free_address= ((uint32_t) boot_alloc(0) / PGSIZE); // return next free char pointer addr
f0100f77:	c1 e8 0c             	shr    $0xc,%eax
		if( i >=  npages_basemem  &&  i <  npages_basemem + IOPHYSMEM-EXTPHYSMEM/PGSIZE+ next_free_address )
f0100f7a:	8d 84 07 00 ff 09 00 	lea    0x9ff00(%edi,%eax,1),%eax
f0100f81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for ( i  =1 ; i < npages; i++) {
f0100f84:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f89:	be 00 00 00 00       	mov    $0x0,%esi
f0100f8e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f93:	eb 3b                	jmp    f0100fd0 <page_init+0x87>
			pages[i].pp_ref = 1;
f0100f95:	8b 93 ac 1f 00 00    	mov    0x1fac(%ebx),%edx
f0100f9b:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100fa1:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
			continue;							//continue in for loop
f0100fa7:	eb 24                	jmp    f0100fcd <page_init+0x84>
f0100fa9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0; 				
f0100fb0:	89 d1                	mov    %edx,%ecx
f0100fb2:	03 8b ac 1f 00 00    	add    0x1fac(%ebx),%ecx
f0100fb8:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;  // next page free on page free list
f0100fbe:	89 31                	mov    %esi,(%ecx)
			page_free_list = &pages[i];	        //set free list on i-th page 
f0100fc0:	89 d6                	mov    %edx,%esi
f0100fc2:	03 b3 ac 1f 00 00    	add    0x1fac(%ebx),%esi
f0100fc8:	b9 01 00 00 00       	mov    $0x1,%ecx
	for ( i  =1 ; i < npages; i++) {
f0100fcd:	83 c0 01             	add    $0x1,%eax
f0100fd0:	39 83 b4 1f 00 00    	cmp    %eax,0x1fb4(%ebx)
f0100fd6:	76 24                	jbe    f0100ffc <page_init+0xb3>
		if(i==0)
f0100fd8:	85 c0                	test   %eax,%eax
f0100fda:	74 b9                	je     f0100f95 <page_init+0x4c>
		if( i >=  npages_basemem  &&  i <  npages_basemem + IOPHYSMEM-EXTPHYSMEM/PGSIZE+ next_free_address )
f0100fdc:	39 c7                	cmp    %eax,%edi
f0100fde:	77 c9                	ja     f0100fa9 <page_init+0x60>
f0100fe0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0100fe3:	76 c4                	jbe    f0100fa9 <page_init+0x60>
			pages[i].pp_ref = 0;	
f0100fe5:	8b 93 ac 1f 00 00    	mov    0x1fac(%ebx),%edx
f0100feb:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f0100fee:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = NULL;
f0100ff4:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
			continue;	
f0100ffa:	eb d1                	jmp    f0100fcd <page_init+0x84>
f0100ffc:	84 c9                	test   %cl,%cl
f0100ffe:	74 06                	je     f0101006 <page_init+0xbd>
f0101000:	89 b3 bc 1f 00 00    	mov    %esi,0x1fbc(%ebx)
	}
f0101006:	83 c4 1c             	add    $0x1c,%esp
f0101009:	5b                   	pop    %ebx
f010100a:	5e                   	pop    %esi
f010100b:	5f                   	pop    %edi
f010100c:	5d                   	pop    %ebp
f010100d:	c3                   	ret    

f010100e <page_alloc>:
{
f010100e:	55                   	push   %ebp
f010100f:	89 e5                	mov    %esp,%ebp
f0101011:	56                   	push   %esi
f0101012:	53                   	push   %ebx
f0101013:	e8 ca f1 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0101018:	81 c3 f4 62 01 00    	add    $0x162f4,%ebx
	new_page=page_free_list;
f010101e:	8b b3 bc 1f 00 00    	mov    0x1fbc(%ebx),%esi
	page_free_list=page_free_list->pp_link; // switch free page to next free page in memoroy 
f0101024:	8b 06                	mov    (%esi),%eax
f0101026:	89 83 bc 1f 00 00    	mov    %eax,0x1fbc(%ebx)
	new_page->pp_link=NULL;
f010102c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(page_free_list==NULL) // out of free memory
f0101032:	85 c0                	test   %eax,%eax
f0101034:	74 5d                	je     f0101093 <page_alloc+0x85>
	if(alloc_flags & ALLOC_ZERO)
f0101036:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010103a:	75 09                	jne    f0101045 <page_alloc+0x37>
}
f010103c:	89 f0                	mov    %esi,%eax
f010103e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101041:	5b                   	pop    %ebx
f0101042:	5e                   	pop    %esi
f0101043:	5d                   	pop    %ebp
f0101044:	c3                   	ret    
f0101045:	89 f0                	mov    %esi,%eax
f0101047:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f010104d:	c1 f8 03             	sar    $0x3,%eax
f0101050:	89 c2                	mov    %eax,%edx
f0101052:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101055:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010105a:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0101060:	73 1b                	jae    f010107d <page_alloc+0x6f>
		memset(page2kva(new_page),0,PGSIZE);
f0101062:	83 ec 04             	sub    $0x4,%esp
f0101065:	68 00 10 00 00       	push   $0x1000
f010106a:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010106c:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101072:	52                   	push   %edx
f0101073:	e8 2f 2b 00 00       	call   f0103ba7 <memset>
f0101078:	83 c4 10             	add    $0x10,%esp
f010107b:	eb bf                	jmp    f010103c <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010107d:	52                   	push   %edx
f010107e:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0101084:	50                   	push   %eax
f0101085:	6a 55                	push   $0x55
f0101087:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f010108d:	50                   	push   %eax
f010108e:	e8 99 f0 ff ff       	call   f010012c <_panic>
		return NULL;
f0101093:	89 c6                	mov    %eax,%esi
f0101095:	eb a5                	jmp    f010103c <page_alloc+0x2e>

f0101097 <page_free>:
{
f0101097:	55                   	push   %ebp
f0101098:	89 e5                	mov    %esp,%ebp
f010109a:	53                   	push   %ebx
f010109b:	83 ec 04             	sub    $0x4,%esp
f010109e:	e8 3f f1 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f01010a3:	81 c3 69 62 01 00    	add    $0x16269,%ebx
f01010a9:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp->pp_ref==0);
f01010ac:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010b1:	75 18                	jne    f01010cb <page_free+0x34>
	assert(pp->pp_link==NULL);
f01010b3:	83 38 00             	cmpl   $0x0,(%eax)
f01010b6:	75 32                	jne    f01010ea <page_free+0x53>
	pp->pp_link=page_free_list;
f01010b8:	8b 8b bc 1f 00 00    	mov    0x1fbc(%ebx),%ecx
f01010be:	89 08                	mov    %ecx,(%eax)
	page_free_list=pp;
f01010c0:	89 83 bc 1f 00 00    	mov    %eax,0x1fbc(%ebx)
}
f01010c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010c9:	c9                   	leave  
f01010ca:	c3                   	ret    
	assert(pp->pp_ref==0);
f01010cb:	8d 83 d3 da fe ff    	lea    -0x1252d(%ebx),%eax
f01010d1:	50                   	push   %eax
f01010d2:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01010d8:	50                   	push   %eax
f01010d9:	68 73 01 00 00       	push   $0x173
f01010de:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01010e4:	50                   	push   %eax
f01010e5:	e8 42 f0 ff ff       	call   f010012c <_panic>
	assert(pp->pp_link==NULL);
f01010ea:	8d 83 e1 da fe ff    	lea    -0x1251f(%ebx),%eax
f01010f0:	50                   	push   %eax
f01010f1:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01010f7:	50                   	push   %eax
f01010f8:	68 74 01 00 00       	push   $0x174
f01010fd:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101103:	50                   	push   %eax
f0101104:	e8 23 f0 ff ff       	call   f010012c <_panic>

f0101109 <page_decref>:
{
f0101109:	55                   	push   %ebp
f010110a:	89 e5                	mov    %esp,%ebp
f010110c:	83 ec 08             	sub    $0x8,%esp
f010110f:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101112:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101116:	83 e8 01             	sub    $0x1,%eax
f0101119:	66 89 42 04          	mov    %ax,0x4(%edx)
f010111d:	66 85 c0             	test   %ax,%ax
f0101120:	74 02                	je     f0101124 <page_decref+0x1b>
}
f0101122:	c9                   	leave  
f0101123:	c3                   	ret    
		page_free(pp);
f0101124:	83 ec 0c             	sub    $0xc,%esp
f0101127:	52                   	push   %edx
f0101128:	e8 6a ff ff ff       	call   f0101097 <page_free>
f010112d:	83 c4 10             	add    $0x10,%esp
}
f0101130:	eb f0                	jmp    f0101122 <page_decref+0x19>

f0101132 <pgdir_walk>:
{
f0101132:	55                   	push   %ebp
f0101133:	89 e5                	mov    %esp,%ebp
f0101135:	57                   	push   %edi
f0101136:	56                   	push   %esi
f0101137:	53                   	push   %ebx
f0101138:	83 ec 0c             	sub    $0xc,%esp
f010113b:	e8 ca 1d 00 00       	call   f0102f0a <__x86.get_pc_thunk.di>
f0101140:	81 c7 cc 61 01 00    	add    $0x161cc,%edi
f0101146:	8b 45 08             	mov    0x8(%ebp),%eax
f0101149:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	assert(pgdir!=NULL); // panic if pgdir is NULL pointer
f010114c:	85 c0                	test   %eax,%eax
f010114e:	74 6b                	je     f01011bb <pgdir_walk+0x89>
	pointer_table_page_index=&pgdir[PDX(va)]; // PDX page directory index adress
f0101150:	89 da                	mov    %ebx,%edx
f0101152:	c1 ea 16             	shr    $0x16,%edx
f0101155:	8d 34 90             	lea    (%eax,%edx,4),%esi
	if( !(*pointer_table_page_index & PTE_P) )   // if flag PTE_P (present ) and tp_index
f0101158:	f6 06 01             	testb  $0x1,(%esi)
f010115b:	75 31                	jne    f010118e <pgdir_walk+0x5c>
		if(!create)
f010115d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101161:	0f 84 90 00 00 00    	je     f01011f7 <pgdir_walk+0xc5>
		newly_page=page_alloc(ALLOC_ZERO);    // return physical page adress
f0101167:	83 ec 0c             	sub    $0xc,%esp
f010116a:	6a 01                	push   $0x1
f010116c:	e8 9d fe ff ff       	call   f010100e <page_alloc>
		if(newly_page==NULL) // alloc not succesful 
f0101171:	83 c4 10             	add    $0x10,%esp
f0101174:	85 c0                	test   %eax,%eax
f0101176:	74 3b                	je     f01011b3 <pgdir_walk+0x81>
		newly_page->pp_ref++;  // add reference to new physicial page
f0101178:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f010117d:	2b 87 ac 1f 00 00    	sub    0x1fac(%edi),%eax
f0101183:	c1 f8 03             	sar    $0x3,%eax
f0101186:	c1 e0 0c             	shl    $0xc,%eax
		*pointer_table_page_index=(page2pa(newly_page) | PTE_P | PTE_U | PTE_W ); // page2pa returns va of page // prezent, read, user flags
f0101189:	83 c8 07             	or     $0x7,%eax
f010118c:	89 06                	mov    %eax,(%esi)
page_table=KADDR(PTE_ADDR(*pointer_table_page_index));  // virutal adress of adress in page directory entry
f010118e:	8b 06                	mov    (%esi),%eax
f0101190:	89 c2                	mov    %eax,%edx
f0101192:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101198:	c1 e8 0c             	shr    $0xc,%eax
f010119b:	3b 87 b4 1f 00 00    	cmp    0x1fb4(%edi),%eax
f01011a1:	73 39                	jae    f01011dc <pgdir_walk+0xaa>
return &page_table[PTX(va)] ; // return index of page table
f01011a3:	c1 eb 0a             	shr    $0xa,%ebx
f01011a6:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01011ac:	8d 84 1a 00 00 00 f0 	lea    -0x10000000(%edx,%ebx,1),%eax
}
f01011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011b6:	5b                   	pop    %ebx
f01011b7:	5e                   	pop    %esi
f01011b8:	5f                   	pop    %edi
f01011b9:	5d                   	pop    %ebp
f01011ba:	c3                   	ret    
	assert(pgdir!=NULL); // panic if pgdir is NULL pointer
f01011bb:	8d 87 f3 da fe ff    	lea    -0x1250d(%edi),%eax
f01011c1:	50                   	push   %eax
f01011c2:	8d 87 43 da fe ff    	lea    -0x125bd(%edi),%eax
f01011c8:	50                   	push   %eax
f01011c9:	68 a5 01 00 00       	push   $0x1a5
f01011ce:	8d 87 1d da fe ff    	lea    -0x125e3(%edi),%eax
f01011d4:	50                   	push   %eax
f01011d5:	89 fb                	mov    %edi,%ebx
f01011d7:	e8 50 ef ff ff       	call   f010012c <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011dc:	52                   	push   %edx
f01011dd:	8d 87 a8 d2 fe ff    	lea    -0x12d58(%edi),%eax
f01011e3:	50                   	push   %eax
f01011e4:	68 c1 01 00 00       	push   $0x1c1
f01011e9:	8d 87 1d da fe ff    	lea    -0x125e3(%edi),%eax
f01011ef:	50                   	push   %eax
f01011f0:	89 fb                	mov    %edi,%ebx
f01011f2:	e8 35 ef ff ff       	call   f010012c <_panic>
		return NULL;
f01011f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01011fc:	eb b5                	jmp    f01011b3 <pgdir_walk+0x81>

f01011fe <boot_map_region>:
{
f01011fe:	55                   	push   %ebp
f01011ff:	89 e5                	mov    %esp,%ebp
f0101201:	57                   	push   %edi
f0101202:	56                   	push   %esi
f0101203:	53                   	push   %ebx
f0101204:	83 ec 1c             	sub    $0x1c,%esp
f0101207:	e8 fe 1c 00 00       	call   f0102f0a <__x86.get_pc_thunk.di>
f010120c:	81 c7 00 61 01 00    	add    $0x16100,%edi
f0101212:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0101215:	89 c7                	mov    %eax,%edi
f0101217:	8b 45 08             	mov    0x8(%ebp),%eax
f010121a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101220:	8d 34 01             	lea    (%ecx,%eax,1),%esi
	for(i=0; i< n_size ; i++)
f0101223:	89 c3                	mov    %eax,%ebx
		page_table_entry = pgdir_walk(pgdir, (void*) va, 1);
f0101225:	29 c2                	sub    %eax,%edx
f0101227:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for(i=0; i< n_size ; i++)
f010122a:	39 f3                	cmp    %esi,%ebx
f010122c:	74 4c                	je     f010127a <boot_map_region+0x7c>
		page_table_entry = pgdir_walk(pgdir, (void*) va, 1);
f010122e:	83 ec 04             	sub    $0x4,%esp
f0101231:	6a 01                	push   $0x1
f0101233:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101236:	01 d8                	add    %ebx,%eax
f0101238:	50                   	push   %eax
f0101239:	57                   	push   %edi
f010123a:	e8 f3 fe ff ff       	call   f0101132 <pgdir_walk>
		assert(page_table_entry != NULL);     // panic if zero
f010123f:	83 c4 10             	add    $0x10,%esp
f0101242:	85 c0                	test   %eax,%eax
f0101244:	74 12                	je     f0101258 <boot_map_region+0x5a>
		*page_table_entry=(pa|PTE_P|perm);
f0101246:	89 da                	mov    %ebx,%edx
f0101248:	0b 55 0c             	or     0xc(%ebp),%edx
f010124b:	83 ca 01             	or     $0x1,%edx
f010124e:	89 10                	mov    %edx,(%eax)
		pa+=PGSIZE;
f0101250:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101256:	eb d2                	jmp    f010122a <boot_map_region+0x2c>
		assert(page_table_entry != NULL);     // panic if zero
f0101258:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010125b:	8d 83 ff da fe ff    	lea    -0x12501(%ebx),%eax
f0101261:	50                   	push   %eax
f0101262:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101268:	50                   	push   %eax
f0101269:	68 de 01 00 00       	push   $0x1de
f010126e:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101274:	50                   	push   %eax
f0101275:	e8 b2 ee ff ff       	call   f010012c <_panic>
}
f010127a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010127d:	5b                   	pop    %ebx
f010127e:	5e                   	pop    %esi
f010127f:	5f                   	pop    %edi
f0101280:	5d                   	pop    %ebp
f0101281:	c3                   	ret    

f0101282 <page_lookup>:
{
f0101282:	55                   	push   %ebp
f0101283:	89 e5                	mov    %esp,%ebp
f0101285:	56                   	push   %esi
f0101286:	53                   	push   %ebx
f0101287:	e8 56 ef ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f010128c:	81 c3 80 60 01 00    	add    $0x16080,%ebx
f0101292:	8b 75 10             	mov    0x10(%ebp),%esi
	entry_of_page_table=pgdir_walk(pgdir,va,0);
f0101295:	83 ec 04             	sub    $0x4,%esp
f0101298:	6a 00                	push   $0x0
f010129a:	ff 75 0c             	push   0xc(%ebp)
f010129d:	ff 75 08             	push   0x8(%ebp)
f01012a0:	e8 8d fe ff ff       	call   f0101132 <pgdir_walk>
	if(entry_of_page_table==NULL)
f01012a5:	83 c4 10             	add    $0x10,%esp
f01012a8:	85 c0                	test   %eax,%eax
f01012aa:	74 42                	je     f01012ee <page_lookup+0x6c>
	if(!(*entry_of_page_table & PTE_P))
f01012ac:	8b 10                	mov    (%eax),%edx
f01012ae:	f6 c2 01             	test   $0x1,%dl
f01012b1:	74 3f                	je     f01012f2 <page_lookup+0x70>
f01012b3:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012b6:	39 93 b4 1f 00 00    	cmp    %edx,0x1fb4(%ebx)
f01012bc:	76 18                	jbe    f01012d6 <page_lookup+0x54>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012be:	8b 8b ac 1f 00 00    	mov    0x1fac(%ebx),%ecx
f01012c4:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	if(pte_store != NULL)
f01012c7:	85 f6                	test   %esi,%esi
f01012c9:	74 02                	je     f01012cd <page_lookup+0x4b>
		*pte_store=entry_of_page_table;
f01012cb:	89 06                	mov    %eax,(%esi)
}
f01012cd:	89 d0                	mov    %edx,%eax
f01012cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012d2:	5b                   	pop    %ebx
f01012d3:	5e                   	pop    %esi
f01012d4:	5d                   	pop    %ebp
f01012d5:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01012d6:	83 ec 04             	sub    $0x4,%esp
f01012d9:	8d 83 b4 d3 fe ff    	lea    -0x12c4c(%ebx),%eax
f01012df:	50                   	push   %eax
f01012e0:	6a 4e                	push   $0x4e
f01012e2:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f01012e8:	50                   	push   %eax
f01012e9:	e8 3e ee ff ff       	call   f010012c <_panic>
		return NULL;
f01012ee:	89 c2                	mov    %eax,%edx
f01012f0:	eb db                	jmp    f01012cd <page_lookup+0x4b>
		return NULL;
f01012f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01012f7:	eb d4                	jmp    f01012cd <page_lookup+0x4b>

f01012f9 <page_remove>:
{
f01012f9:	55                   	push   %ebp
f01012fa:	89 e5                	mov    %esp,%ebp
f01012fc:	53                   	push   %ebx
f01012fd:	83 ec 18             	sub    $0x18,%esp
f0101300:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *entry_of_page_table = NULL;
f0101303:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *page = page_lookup(pgdir, va, &entry_of_page_table);
f010130a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010130d:	50                   	push   %eax
f010130e:	53                   	push   %ebx
f010130f:	ff 75 08             	push   0x8(%ebp)
f0101312:	e8 6b ff ff ff       	call   f0101282 <page_lookup>
	if (page == NULL)
f0101317:	83 c4 10             	add    $0x10,%esp
f010131a:	85 c0                	test   %eax,%eax
f010131c:	74 18                	je     f0101336 <page_remove+0x3d>
	page_decref(page);
f010131e:	83 ec 0c             	sub    $0xc,%esp
f0101321:	50                   	push   %eax
f0101322:	e8 e2 fd ff ff       	call   f0101109 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101327:	0f 01 3b             	invlpg (%ebx)
	*entry_of_page_table = 0;
f010132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010132d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101333:	83 c4 10             	add    $0x10,%esp
}
f0101336:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101339:	c9                   	leave  
f010133a:	c3                   	ret    

f010133b <page_insert>:
{
f010133b:	55                   	push   %ebp
f010133c:	89 e5                	mov    %esp,%ebp
f010133e:	57                   	push   %edi
f010133f:	56                   	push   %esi
f0101340:	53                   	push   %ebx
f0101341:	83 ec 10             	sub    $0x10,%esp
f0101344:	e8 c1 1b 00 00       	call   f0102f0a <__x86.get_pc_thunk.di>
f0101349:	81 c7 c3 5f 01 00    	add    $0x15fc3,%edi
f010134f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pyhsical_page_entry = pgdir_walk(pgdir,va,1); // return me adress of page entry of new page
f0101352:	6a 01                	push   $0x1
f0101354:	ff 75 10             	push   0x10(%ebp)
f0101357:	ff 75 08             	push   0x8(%ebp)
f010135a:	e8 d3 fd ff ff       	call   f0101132 <pgdir_walk>
	if(pyhsical_page_entry==NULL)
f010135f:	83 c4 10             	add    $0x10,%esp
f0101362:	85 c0                	test   %eax,%eax
f0101364:	74 46                	je     f01013ac <page_insert+0x71>
f0101366:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101368:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if(PTE_P & *pyhsical_page_entry) // remove if exists
f010136d:	f6 00 01             	testb  $0x1,(%eax)
f0101370:	75 21                	jne    f0101393 <page_insert+0x58>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0101372:	2b 9f ac 1f 00 00    	sub    0x1fac(%edi),%ebx
f0101378:	c1 fb 03             	sar    $0x3,%ebx
f010137b:	c1 e3 0c             	shl    $0xc,%ebx
	*pyhsical_page_entry=(page2pa(pp) | perm | PTE_P); // set permissions of page table entry
f010137e:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101381:	83 cb 01             	or     $0x1,%ebx
f0101384:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101386:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010138b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010138e:	5b                   	pop    %ebx
f010138f:	5e                   	pop    %esi
f0101390:	5f                   	pop    %edi
f0101391:	5d                   	pop    %ebp
f0101392:	c3                   	ret    
f0101393:	8b 45 10             	mov    0x10(%ebp),%eax
f0101396:	0f 01 38             	invlpg (%eax)
		page_remove(pgdir,va);	
f0101399:	83 ec 08             	sub    $0x8,%esp
f010139c:	ff 75 10             	push   0x10(%ebp)
f010139f:	ff 75 08             	push   0x8(%ebp)
f01013a2:	e8 52 ff ff ff       	call   f01012f9 <page_remove>
f01013a7:	83 c4 10             	add    $0x10,%esp
f01013aa:	eb c6                	jmp    f0101372 <page_insert+0x37>
		return -E_NO_MEM;
f01013ac:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01013b1:	eb d8                	jmp    f010138b <page_insert+0x50>

f01013b3 <tlb_invalidate>:
{
f01013b3:	55                   	push   %ebp
f01013b4:	89 e5                	mov    %esp,%ebp
f01013b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013b9:	0f 01 38             	invlpg (%eax)
}
f01013bc:	5d                   	pop    %ebp
f01013bd:	c3                   	ret    

f01013be <check_kern_pgdir>:
{
f01013be:	55                   	push   %ebp
f01013bf:	89 e5                	mov    %esp,%ebp
f01013c1:	57                   	push   %edi
f01013c2:	56                   	push   %esi
f01013c3:	53                   	push   %ebx
f01013c4:	83 ec 1c             	sub    $0x1c,%esp
f01013c7:	e8 3e 1b 00 00       	call   f0102f0a <__x86.get_pc_thunk.di>
f01013cc:	81 c7 40 5f 01 00    	add    $0x15f40,%edi
f01013d2:	89 7d dc             	mov    %edi,-0x24(%ebp)
	pgdir = kern_pgdir;
f01013d5:	8b 9f b0 1f 00 00    	mov    0x1fb0(%edi),%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01013db:	8b 87 b4 1f 00 00    	mov    0x1fb4(%edi),%eax
f01013e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013e4:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01013eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01013f0:	8b bf ac 1f 00 00    	mov    0x1fac(%edi),%edi
	return (physaddr_t)kva - KERNBASE;
f01013f6:	8d 8f 00 00 00 10    	lea    0x10000000(%edi),%ecx
f01013fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01013ff:	be 00 00 00 00       	mov    $0x0,%esi
f0101404:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101407:	89 c3                	mov    %eax,%ebx
f0101409:	39 de                	cmp    %ebx,%esi
f010140b:	73 66                	jae    f0101473 <check_kern_pgdir+0xb5>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010140d:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0101413:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101416:	e8 46 f7 ff ff       	call   f0100b61 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010141b:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0101421:	76 12                	jbe    f0101435 <check_kern_pgdir+0x77>
f0101423:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101426:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101429:	39 d0                	cmp    %edx,%eax
f010142b:	75 24                	jne    f0101451 <check_kern_pgdir+0x93>
	for (i = 0; i < n; i += PGSIZE)
f010142d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101433:	eb d4                	jmp    f0101409 <check_kern_pgdir+0x4b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101435:	57                   	push   %edi
f0101436:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101439:	8d 83 d4 d3 fe ff    	lea    -0x12c2c(%ebx),%eax
f010143f:	50                   	push   %eax
f0101440:	68 0a 03 00 00       	push   $0x30a
f0101445:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f010144b:	50                   	push   %eax
f010144c:	e8 db ec ff ff       	call   f010012c <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101451:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101454:	8d 83 f8 d3 fe ff    	lea    -0x12c08(%ebx),%eax
f010145a:	50                   	push   %eax
f010145b:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101461:	50                   	push   %eax
f0101462:	68 0a 03 00 00       	push   $0x30a
f0101467:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f010146d:	50                   	push   %eax
f010146e:	e8 b9 ec ff ff       	call   f010012c <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101473:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101476:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0101479:	c1 e7 0c             	shl    $0xc,%edi
f010147c:	be 00 00 00 00       	mov    $0x0,%esi
f0101481:	39 f7                	cmp    %esi,%edi
f0101483:	76 3b                	jbe    f01014c0 <check_kern_pgdir+0x102>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0101485:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010148b:	89 d8                	mov    %ebx,%eax
f010148d:	e8 cf f6 ff ff       	call   f0100b61 <check_va2pa>
f0101492:	39 f0                	cmp    %esi,%eax
f0101494:	75 08                	jne    f010149e <check_kern_pgdir+0xe0>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101496:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010149c:	eb e3                	jmp    f0101481 <check_kern_pgdir+0xc3>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010149e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01014a1:	8d 83 2c d4 fe ff    	lea    -0x12bd4(%ebx),%eax
f01014a7:	50                   	push   %eax
f01014a8:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01014ae:	50                   	push   %eax
f01014af:	68 0f 03 00 00       	push   $0x30f
f01014b4:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01014ba:	50                   	push   %eax
f01014bb:	e8 6c ec ff ff       	call   f010012c <_panic>
f01014c0:	be 00 80 ff ef       	mov    $0xefff8000,%esi
	if ((uint32_t)kva < KERNBASE)
f01014c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01014c8:	c7 c7 00 e0 10 f0    	mov    $0xf010e000,%edi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01014ce:	8d 87 00 80 00 20    	lea    0x20008000(%edi),%eax
f01014d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014d7:	89 f2                	mov    %esi,%edx
f01014d9:	89 d8                	mov    %ebx,%eax
f01014db:	e8 81 f6 ff ff       	call   f0100b61 <check_va2pa>
f01014e0:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01014e6:	76 33                	jbe    f010151b <check_kern_pgdir+0x15d>
f01014e8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01014eb:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f01014ee:	39 d0                	cmp    %edx,%eax
f01014f0:	75 4a                	jne    f010153c <check_kern_pgdir+0x17e>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01014f2:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01014f8:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01014fe:	75 d7                	jne    f01014d7 <check_kern_pgdir+0x119>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0101500:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0101505:	89 d8                	mov    %ebx,%eax
f0101507:	e8 55 f6 ff ff       	call   f0100b61 <check_va2pa>
f010150c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010150f:	75 4d                	jne    f010155e <check_kern_pgdir+0x1a0>
	for (i = 0; i < NPDENTRIES; i++) {
f0101511:	b8 00 00 00 00       	mov    $0x0,%eax
f0101516:	e9 8e 00 00 00       	jmp    f01015a9 <check_kern_pgdir+0x1eb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010151b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010151e:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0101524:	8d 83 d4 d3 fe ff    	lea    -0x12c2c(%ebx),%eax
f010152a:	50                   	push   %eax
f010152b:	68 13 03 00 00       	push   $0x313
f0101530:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101536:	50                   	push   %eax
f0101537:	e8 f0 eb ff ff       	call   f010012c <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010153c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010153f:	8d 83 54 d4 fe ff    	lea    -0x12bac(%ebx),%eax
f0101545:	50                   	push   %eax
f0101546:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f010154c:	50                   	push   %eax
f010154d:	68 13 03 00 00       	push   $0x313
f0101552:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101558:	50                   	push   %eax
f0101559:	e8 ce eb ff ff       	call   f010012c <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010155e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101561:	8d 83 9c d4 fe ff    	lea    -0x12b64(%ebx),%eax
f0101567:	50                   	push   %eax
f0101568:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f010156e:	50                   	push   %eax
f010156f:	68 14 03 00 00       	push   $0x314
f0101574:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f010157a:	50                   	push   %eax
f010157b:	e8 ac eb ff ff       	call   f010012c <_panic>
		switch (i) {
f0101580:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0101585:	75 22                	jne    f01015a9 <check_kern_pgdir+0x1eb>
			assert(pgdir[i] & PTE_P);
f0101587:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010158b:	74 4b                	je     f01015d8 <check_kern_pgdir+0x21a>
	for (i = 0; i < NPDENTRIES; i++) {
f010158d:	83 c0 01             	add    $0x1,%eax
f0101590:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0101595:	0f 87 b0 00 00 00    	ja     f010164b <check_kern_pgdir+0x28d>
		switch (i) {
f010159b:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01015a0:	77 de                	ja     f0101580 <check_kern_pgdir+0x1c2>
f01015a2:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01015a7:	77 de                	ja     f0101587 <check_kern_pgdir+0x1c9>
			if (i >= PDX(KERNBASE)) {
f01015a9:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01015ae:	77 4a                	ja     f01015fa <check_kern_pgdir+0x23c>
				assert(pgdir[i] == 0);
f01015b0:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01015b4:	74 d7                	je     f010158d <check_kern_pgdir+0x1cf>
f01015b6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01015b9:	8d 83 3a db fe ff    	lea    -0x124c6(%ebx),%eax
f01015bf:	50                   	push   %eax
f01015c0:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01015c6:	50                   	push   %eax
f01015c7:	68 23 03 00 00       	push   $0x323
f01015cc:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01015d2:	50                   	push   %eax
f01015d3:	e8 54 eb ff ff       	call   f010012c <_panic>
			assert(pgdir[i] & PTE_P);
f01015d8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01015db:	8d 83 18 db fe ff    	lea    -0x124e8(%ebx),%eax
f01015e1:	50                   	push   %eax
f01015e2:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01015e8:	50                   	push   %eax
f01015e9:	68 1c 03 00 00       	push   $0x31c
f01015ee:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01015f4:	50                   	push   %eax
f01015f5:	e8 32 eb ff ff       	call   f010012c <_panic>
				assert(pgdir[i] & PTE_P);
f01015fa:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01015fd:	f6 c2 01             	test   $0x1,%dl
f0101600:	74 27                	je     f0101629 <check_kern_pgdir+0x26b>
				assert(pgdir[i] & PTE_W);
f0101602:	f6 c2 02             	test   $0x2,%dl
f0101605:	75 86                	jne    f010158d <check_kern_pgdir+0x1cf>
f0101607:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010160a:	8d 83 29 db fe ff    	lea    -0x124d7(%ebx),%eax
f0101610:	50                   	push   %eax
f0101611:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101617:	50                   	push   %eax
f0101618:	68 21 03 00 00       	push   $0x321
f010161d:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101623:	50                   	push   %eax
f0101624:	e8 03 eb ff ff       	call   f010012c <_panic>
				assert(pgdir[i] & PTE_P);
f0101629:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010162c:	8d 83 18 db fe ff    	lea    -0x124e8(%ebx),%eax
f0101632:	50                   	push   %eax
f0101633:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101639:	50                   	push   %eax
f010163a:	68 20 03 00 00       	push   $0x320
f010163f:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101645:	50                   	push   %eax
f0101646:	e8 e1 ea ff ff       	call   f010012c <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f010164b:	83 ec 0c             	sub    $0xc,%esp
f010164e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101651:	8d 83 cc d4 fe ff    	lea    -0x12b34(%ebx),%eax
f0101657:	50                   	push   %eax
f0101658:	e8 38 19 00 00       	call   f0102f95 <cprintf>
}
f010165d:	83 c4 10             	add    $0x10,%esp
f0101660:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101663:	5b                   	pop    %ebx
f0101664:	5e                   	pop    %esi
f0101665:	5f                   	pop    %edi
f0101666:	5d                   	pop    %ebp
f0101667:	c3                   	ret    

f0101668 <mem_init>:
{
f0101668:	55                   	push   %ebp
f0101669:	89 e5                	mov    %esp,%ebp
f010166b:	57                   	push   %edi
f010166c:	56                   	push   %esi
f010166d:	53                   	push   %ebx
f010166e:	83 ec 2c             	sub    $0x2c,%esp
f0101671:	e8 6c eb ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0101676:	81 c3 96 5c 01 00    	add    $0x15c96,%ebx
	basemem = nvram_read(NVRAM_BASELO);
f010167c:	b8 15 00 00 00       	mov    $0x15,%eax
f0101681:	e8 25 f4 ff ff       	call   f0100aab <nvram_read>
f0101686:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101688:	b8 17 00 00 00       	mov    $0x17,%eax
f010168d:	e8 19 f4 ff ff       	call   f0100aab <nvram_read>
f0101692:	89 c7                	mov    %eax,%edi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101694:	b8 34 00 00 00       	mov    $0x34,%eax
f0101699:	e8 0d f4 ff ff       	call   f0100aab <nvram_read>
	if (ext16mem)
f010169e:	c1 e0 06             	shl    $0x6,%eax
f01016a1:	0f 84 be 00 00 00    	je     f0101765 <mem_init+0xfd>
		totalmem = 16 * 1024 + ext16mem;
f01016a7:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01016ac:	89 c2                	mov    %eax,%edx
f01016ae:	c1 ea 02             	shr    $0x2,%edx
f01016b1:	89 93 b4 1f 00 00    	mov    %edx,0x1fb4(%ebx)
	npages_basemem = basemem / (PGSIZE / 1024);
f01016b7:	89 f2                	mov    %esi,%edx
f01016b9:	c1 ea 02             	shr    $0x2,%edx
f01016bc:	89 93 c0 1f 00 00    	mov    %edx,0x1fc0(%ebx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016c2:	89 c2                	mov    %eax,%edx
f01016c4:	29 f2                	sub    %esi,%edx
f01016c6:	52                   	push   %edx
f01016c7:	56                   	push   %esi
f01016c8:	50                   	push   %eax
f01016c9:	8d 83 ec d4 fe ff    	lea    -0x12b14(%ebx),%eax
f01016cf:	50                   	push   %eax
f01016d0:	e8 c0 18 00 00       	call   f0102f95 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01016d5:	b8 00 10 00 00       	mov    $0x1000,%eax
f01016da:	e8 02 f4 ff ff       	call   f0100ae1 <boot_alloc>
f01016df:	89 83 b0 1f 00 00    	mov    %eax,0x1fb0(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f01016e5:	83 c4 0c             	add    $0xc,%esp
f01016e8:	68 00 10 00 00       	push   $0x1000
f01016ed:	6a 00                	push   $0x0
f01016ef:	50                   	push   %eax
f01016f0:	e8 b2 24 00 00       	call   f0103ba7 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01016f5:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01016fb:	83 c4 10             	add    $0x10,%esp
f01016fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101703:	76 70                	jbe    f0101775 <mem_init+0x10d>
	return (physaddr_t)kva - KERNBASE;
f0101705:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010170b:	83 ca 05             	or     $0x5,%edx
f010170e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
		pages=(struct PageInfo*) boot_alloc(npages*sizeof(struct PageInfo));
f0101714:	8b 83 b4 1f 00 00    	mov    0x1fb4(%ebx),%eax
f010171a:	c1 e0 03             	shl    $0x3,%eax
f010171d:	e8 bf f3 ff ff       	call   f0100ae1 <boot_alloc>
f0101722:	89 83 ac 1f 00 00    	mov    %eax,0x1fac(%ebx)
		memset( pages ,0,npages * sizeof(struct PageInfo));  // from to np*sizeof to zero, initalize pages array members to zero
f0101728:	83 ec 04             	sub    $0x4,%esp
f010172b:	8b 93 b4 1f 00 00    	mov    0x1fb4(%ebx),%edx
f0101731:	c1 e2 03             	shl    $0x3,%edx
f0101734:	52                   	push   %edx
f0101735:	6a 00                	push   $0x0
f0101737:	50                   	push   %eax
f0101738:	e8 6a 24 00 00       	call   f0103ba7 <memset>
	page_init();
f010173d:	e8 07 f8 ff ff       	call   f0100f49 <page_init>
	check_page_free_list(1);
f0101742:	b8 01 00 00 00       	mov    $0x1,%eax
f0101747:	e8 91 f4 ff ff       	call   f0100bdd <check_page_free_list>
	if (!pages)
f010174c:	83 c4 10             	add    $0x10,%esp
f010174f:	83 bb ac 1f 00 00 00 	cmpl   $0x0,0x1fac(%ebx)
f0101756:	74 36                	je     f010178e <mem_init+0x126>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101758:	8b 83 bc 1f 00 00    	mov    0x1fbc(%ebx),%eax
f010175e:	be 00 00 00 00       	mov    $0x0,%esi
f0101763:	eb 49                	jmp    f01017ae <mem_init+0x146>
		totalmem = 1 * 1024 + extmem;
f0101765:	8d 87 00 04 00 00    	lea    0x400(%edi),%eax
f010176b:	85 ff                	test   %edi,%edi
f010176d:	0f 44 c6             	cmove  %esi,%eax
f0101770:	e9 37 ff ff ff       	jmp    f01016ac <mem_init+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101775:	50                   	push   %eax
f0101776:	8d 83 d4 d3 fe ff    	lea    -0x12c2c(%ebx),%eax
f010177c:	50                   	push   %eax
f010177d:	68 96 00 00 00       	push   $0x96
f0101782:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101788:	50                   	push   %eax
f0101789:	e8 9e e9 ff ff       	call   f010012c <_panic>
		panic("'pages' is a null pointer!");
f010178e:	83 ec 04             	sub    $0x4,%esp
f0101791:	8d 83 48 db fe ff    	lea    -0x124b8(%ebx),%eax
f0101797:	50                   	push   %eax
f0101798:	68 b6 02 00 00       	push   $0x2b6
f010179d:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01017a3:	50                   	push   %eax
f01017a4:	e8 83 e9 ff ff       	call   f010012c <_panic>
		++nfree;
f01017a9:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017ac:	8b 00                	mov    (%eax),%eax
f01017ae:	85 c0                	test   %eax,%eax
f01017b0:	75 f7                	jne    f01017a9 <mem_init+0x141>
	assert((pp0 = page_alloc(0)));
f01017b2:	83 ec 0c             	sub    $0xc,%esp
f01017b5:	6a 00                	push   $0x0
f01017b7:	e8 52 f8 ff ff       	call   f010100e <page_alloc>
f01017bc:	89 c7                	mov    %eax,%edi
f01017be:	83 c4 10             	add    $0x10,%esp
f01017c1:	85 c0                	test   %eax,%eax
f01017c3:	0f 84 2f 02 00 00    	je     f01019f8 <mem_init+0x390>
	assert((pp1 = page_alloc(0)));
f01017c9:	83 ec 0c             	sub    $0xc,%esp
f01017cc:	6a 00                	push   $0x0
f01017ce:	e8 3b f8 ff ff       	call   f010100e <page_alloc>
f01017d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017d6:	83 c4 10             	add    $0x10,%esp
f01017d9:	85 c0                	test   %eax,%eax
f01017db:	0f 84 36 02 00 00    	je     f0101a17 <mem_init+0x3af>
	assert((pp2 = page_alloc(0)));
f01017e1:	83 ec 0c             	sub    $0xc,%esp
f01017e4:	6a 00                	push   $0x0
f01017e6:	e8 23 f8 ff ff       	call   f010100e <page_alloc>
f01017eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01017ee:	83 c4 10             	add    $0x10,%esp
f01017f1:	85 c0                	test   %eax,%eax
f01017f3:	0f 84 3d 02 00 00    	je     f0101a36 <mem_init+0x3ce>
	assert(pp1 && pp1 != pp0);
f01017f9:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017fc:	0f 84 53 02 00 00    	je     f0101a55 <mem_init+0x3ed>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101802:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101805:	39 c7                	cmp    %eax,%edi
f0101807:	0f 84 67 02 00 00    	je     f0101a74 <mem_init+0x40c>
f010180d:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101810:	0f 84 5e 02 00 00    	je     f0101a74 <mem_init+0x40c>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0101816:	8b 8b ac 1f 00 00    	mov    0x1fac(%ebx),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010181c:	8b 93 b4 1f 00 00    	mov    0x1fb4(%ebx),%edx
f0101822:	c1 e2 0c             	shl    $0xc,%edx
f0101825:	89 f8                	mov    %edi,%eax
f0101827:	29 c8                	sub    %ecx,%eax
f0101829:	c1 f8 03             	sar    $0x3,%eax
f010182c:	c1 e0 0c             	shl    $0xc,%eax
f010182f:	39 d0                	cmp    %edx,%eax
f0101831:	0f 83 5c 02 00 00    	jae    f0101a93 <mem_init+0x42b>
f0101837:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010183a:	29 c8                	sub    %ecx,%eax
f010183c:	c1 f8 03             	sar    $0x3,%eax
f010183f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101842:	39 c2                	cmp    %eax,%edx
f0101844:	0f 86 68 02 00 00    	jbe    f0101ab2 <mem_init+0x44a>
f010184a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010184d:	29 c8                	sub    %ecx,%eax
f010184f:	c1 f8 03             	sar    $0x3,%eax
f0101852:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101855:	39 c2                	cmp    %eax,%edx
f0101857:	0f 86 74 02 00 00    	jbe    f0101ad1 <mem_init+0x469>
	fl = page_free_list;
f010185d:	8b 83 bc 1f 00 00    	mov    0x1fbc(%ebx),%eax
f0101863:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101866:	c7 83 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%ebx)
f010186d:	00 00 00 
	assert(!page_alloc(0));
f0101870:	83 ec 0c             	sub    $0xc,%esp
f0101873:	6a 00                	push   $0x0
f0101875:	e8 94 f7 ff ff       	call   f010100e <page_alloc>
f010187a:	83 c4 10             	add    $0x10,%esp
f010187d:	85 c0                	test   %eax,%eax
f010187f:	0f 85 6b 02 00 00    	jne    f0101af0 <mem_init+0x488>
	page_free(pp0);
f0101885:	83 ec 0c             	sub    $0xc,%esp
f0101888:	57                   	push   %edi
f0101889:	e8 09 f8 ff ff       	call   f0101097 <page_free>
	page_free(pp1);
f010188e:	83 c4 04             	add    $0x4,%esp
f0101891:	ff 75 d4             	push   -0x2c(%ebp)
f0101894:	e8 fe f7 ff ff       	call   f0101097 <page_free>
	page_free(pp2);
f0101899:	83 c4 04             	add    $0x4,%esp
f010189c:	ff 75 d0             	push   -0x30(%ebp)
f010189f:	e8 f3 f7 ff ff       	call   f0101097 <page_free>
	assert((pp0 = page_alloc(0)));
f01018a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ab:	e8 5e f7 ff ff       	call   f010100e <page_alloc>
f01018b0:	89 c7                	mov    %eax,%edi
f01018b2:	83 c4 10             	add    $0x10,%esp
f01018b5:	85 c0                	test   %eax,%eax
f01018b7:	0f 84 52 02 00 00    	je     f0101b0f <mem_init+0x4a7>
	assert((pp1 = page_alloc(0)));
f01018bd:	83 ec 0c             	sub    $0xc,%esp
f01018c0:	6a 00                	push   $0x0
f01018c2:	e8 47 f7 ff ff       	call   f010100e <page_alloc>
f01018c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018ca:	83 c4 10             	add    $0x10,%esp
f01018cd:	85 c0                	test   %eax,%eax
f01018cf:	0f 84 59 02 00 00    	je     f0101b2e <mem_init+0x4c6>
	assert((pp2 = page_alloc(0)));
f01018d5:	83 ec 0c             	sub    $0xc,%esp
f01018d8:	6a 00                	push   $0x0
f01018da:	e8 2f f7 ff ff       	call   f010100e <page_alloc>
f01018df:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01018e2:	83 c4 10             	add    $0x10,%esp
f01018e5:	85 c0                	test   %eax,%eax
f01018e7:	0f 84 60 02 00 00    	je     f0101b4d <mem_init+0x4e5>
	assert(pp1 && pp1 != pp0);
f01018ed:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01018f0:	0f 84 76 02 00 00    	je     f0101b6c <mem_init+0x504>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018f9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018fc:	0f 84 89 02 00 00    	je     f0101b8b <mem_init+0x523>
f0101902:	39 c7                	cmp    %eax,%edi
f0101904:	0f 84 81 02 00 00    	je     f0101b8b <mem_init+0x523>
	assert(!page_alloc(0));
f010190a:	83 ec 0c             	sub    $0xc,%esp
f010190d:	6a 00                	push   $0x0
f010190f:	e8 fa f6 ff ff       	call   f010100e <page_alloc>
f0101914:	83 c4 10             	add    $0x10,%esp
f0101917:	85 c0                	test   %eax,%eax
f0101919:	0f 85 8b 02 00 00    	jne    f0101baa <mem_init+0x542>
f010191f:	89 f8                	mov    %edi,%eax
f0101921:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101927:	c1 f8 03             	sar    $0x3,%eax
f010192a:	89 c2                	mov    %eax,%edx
f010192c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010192f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101934:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f010193a:	0f 83 89 02 00 00    	jae    f0101bc9 <mem_init+0x561>
	memset(page2kva(pp0), 1, PGSIZE);
f0101940:	83 ec 04             	sub    $0x4,%esp
f0101943:	68 00 10 00 00       	push   $0x1000
f0101948:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010194a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101950:	52                   	push   %edx
f0101951:	e8 51 22 00 00       	call   f0103ba7 <memset>
	page_free(pp0);
f0101956:	89 3c 24             	mov    %edi,(%esp)
f0101959:	e8 39 f7 ff ff       	call   f0101097 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010195e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101965:	e8 a4 f6 ff ff       	call   f010100e <page_alloc>
f010196a:	83 c4 10             	add    $0x10,%esp
f010196d:	85 c0                	test   %eax,%eax
f010196f:	0f 84 6a 02 00 00    	je     f0101bdf <mem_init+0x577>
	assert(pp && pp0 == pp);
f0101975:	39 c7                	cmp    %eax,%edi
f0101977:	0f 85 81 02 00 00    	jne    f0101bfe <mem_init+0x596>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f010197d:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101983:	c1 f8 03             	sar    $0x3,%eax
f0101986:	89 c2                	mov    %eax,%edx
f0101988:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010198b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101990:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0101996:	0f 83 81 02 00 00    	jae    f0101c1d <mem_init+0x5b5>
	return (void *)(pa + KERNBASE);
f010199c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01019a2:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01019a8:	80 38 00             	cmpb   $0x0,(%eax)
f01019ab:	0f 85 82 02 00 00    	jne    f0101c33 <mem_init+0x5cb>
	for (i = 0; i < PGSIZE; i++)
f01019b1:	83 c0 01             	add    $0x1,%eax
f01019b4:	39 d0                	cmp    %edx,%eax
f01019b6:	75 f0                	jne    f01019a8 <mem_init+0x340>
	page_free_list = fl;
f01019b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01019bb:	89 83 bc 1f 00 00    	mov    %eax,0x1fbc(%ebx)
	page_free(pp0);
f01019c1:	83 ec 0c             	sub    $0xc,%esp
f01019c4:	57                   	push   %edi
f01019c5:	e8 cd f6 ff ff       	call   f0101097 <page_free>
	page_free(pp1);
f01019ca:	83 c4 04             	add    $0x4,%esp
f01019cd:	ff 75 d4             	push   -0x2c(%ebp)
f01019d0:	e8 c2 f6 ff ff       	call   f0101097 <page_free>
	page_free(pp2);
f01019d5:	83 c4 04             	add    $0x4,%esp
f01019d8:	ff 75 d0             	push   -0x30(%ebp)
f01019db:	e8 b7 f6 ff ff       	call   f0101097 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019e0:	8b 83 bc 1f 00 00    	mov    0x1fbc(%ebx),%eax
f01019e6:	83 c4 10             	add    $0x10,%esp
f01019e9:	85 c0                	test   %eax,%eax
f01019eb:	0f 84 61 02 00 00    	je     f0101c52 <mem_init+0x5ea>
		--nfree;
f01019f1:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019f4:	8b 00                	mov    (%eax),%eax
f01019f6:	eb f1                	jmp    f01019e9 <mem_init+0x381>
	assert((pp0 = page_alloc(0)));
f01019f8:	8d 83 63 db fe ff    	lea    -0x1249d(%ebx),%eax
f01019fe:	50                   	push   %eax
f01019ff:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101a05:	50                   	push   %eax
f0101a06:	68 be 02 00 00       	push   $0x2be
f0101a0b:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101a11:	50                   	push   %eax
f0101a12:	e8 15 e7 ff ff       	call   f010012c <_panic>
	assert((pp1 = page_alloc(0)));
f0101a17:	8d 83 79 db fe ff    	lea    -0x12487(%ebx),%eax
f0101a1d:	50                   	push   %eax
f0101a1e:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101a24:	50                   	push   %eax
f0101a25:	68 bf 02 00 00       	push   $0x2bf
f0101a2a:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101a30:	50                   	push   %eax
f0101a31:	e8 f6 e6 ff ff       	call   f010012c <_panic>
	assert((pp2 = page_alloc(0)));
f0101a36:	8d 83 8f db fe ff    	lea    -0x12471(%ebx),%eax
f0101a3c:	50                   	push   %eax
f0101a3d:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101a43:	50                   	push   %eax
f0101a44:	68 c0 02 00 00       	push   $0x2c0
f0101a49:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101a4f:	50                   	push   %eax
f0101a50:	e8 d7 e6 ff ff       	call   f010012c <_panic>
	assert(pp1 && pp1 != pp0);
f0101a55:	8d 83 a5 db fe ff    	lea    -0x1245b(%ebx),%eax
f0101a5b:	50                   	push   %eax
f0101a5c:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101a62:	50                   	push   %eax
f0101a63:	68 c3 02 00 00       	push   $0x2c3
f0101a68:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101a6e:	50                   	push   %eax
f0101a6f:	e8 b8 e6 ff ff       	call   f010012c <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a74:	8d 83 28 d5 fe ff    	lea    -0x12ad8(%ebx),%eax
f0101a7a:	50                   	push   %eax
f0101a7b:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101a81:	50                   	push   %eax
f0101a82:	68 c4 02 00 00       	push   $0x2c4
f0101a87:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101a8d:	50                   	push   %eax
f0101a8e:	e8 99 e6 ff ff       	call   f010012c <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101a93:	8d 83 b7 db fe ff    	lea    -0x12449(%ebx),%eax
f0101a99:	50                   	push   %eax
f0101a9a:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101aa0:	50                   	push   %eax
f0101aa1:	68 c5 02 00 00       	push   $0x2c5
f0101aa6:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101aac:	50                   	push   %eax
f0101aad:	e8 7a e6 ff ff       	call   f010012c <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101ab2:	8d 83 d4 db fe ff    	lea    -0x1242c(%ebx),%eax
f0101ab8:	50                   	push   %eax
f0101ab9:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101abf:	50                   	push   %eax
f0101ac0:	68 c6 02 00 00       	push   $0x2c6
f0101ac5:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101acb:	50                   	push   %eax
f0101acc:	e8 5b e6 ff ff       	call   f010012c <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101ad1:	8d 83 f1 db fe ff    	lea    -0x1240f(%ebx),%eax
f0101ad7:	50                   	push   %eax
f0101ad8:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101ade:	50                   	push   %eax
f0101adf:	68 c7 02 00 00       	push   $0x2c7
f0101ae4:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101aea:	50                   	push   %eax
f0101aeb:	e8 3c e6 ff ff       	call   f010012c <_panic>
	assert(!page_alloc(0));
f0101af0:	8d 83 0e dc fe ff    	lea    -0x123f2(%ebx),%eax
f0101af6:	50                   	push   %eax
f0101af7:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101afd:	50                   	push   %eax
f0101afe:	68 ce 02 00 00       	push   $0x2ce
f0101b03:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101b09:	50                   	push   %eax
f0101b0a:	e8 1d e6 ff ff       	call   f010012c <_panic>
	assert((pp0 = page_alloc(0)));
f0101b0f:	8d 83 63 db fe ff    	lea    -0x1249d(%ebx),%eax
f0101b15:	50                   	push   %eax
f0101b16:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101b1c:	50                   	push   %eax
f0101b1d:	68 d5 02 00 00       	push   $0x2d5
f0101b22:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101b28:	50                   	push   %eax
f0101b29:	e8 fe e5 ff ff       	call   f010012c <_panic>
	assert((pp1 = page_alloc(0)));
f0101b2e:	8d 83 79 db fe ff    	lea    -0x12487(%ebx),%eax
f0101b34:	50                   	push   %eax
f0101b35:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101b3b:	50                   	push   %eax
f0101b3c:	68 d6 02 00 00       	push   $0x2d6
f0101b41:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101b47:	50                   	push   %eax
f0101b48:	e8 df e5 ff ff       	call   f010012c <_panic>
	assert((pp2 = page_alloc(0)));
f0101b4d:	8d 83 8f db fe ff    	lea    -0x12471(%ebx),%eax
f0101b53:	50                   	push   %eax
f0101b54:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101b5a:	50                   	push   %eax
f0101b5b:	68 d7 02 00 00       	push   $0x2d7
f0101b60:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101b66:	50                   	push   %eax
f0101b67:	e8 c0 e5 ff ff       	call   f010012c <_panic>
	assert(pp1 && pp1 != pp0);
f0101b6c:	8d 83 a5 db fe ff    	lea    -0x1245b(%ebx),%eax
f0101b72:	50                   	push   %eax
f0101b73:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101b79:	50                   	push   %eax
f0101b7a:	68 d9 02 00 00       	push   $0x2d9
f0101b7f:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101b85:	50                   	push   %eax
f0101b86:	e8 a1 e5 ff ff       	call   f010012c <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b8b:	8d 83 28 d5 fe ff    	lea    -0x12ad8(%ebx),%eax
f0101b91:	50                   	push   %eax
f0101b92:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101b98:	50                   	push   %eax
f0101b99:	68 da 02 00 00       	push   $0x2da
f0101b9e:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101ba4:	50                   	push   %eax
f0101ba5:	e8 82 e5 ff ff       	call   f010012c <_panic>
	assert(!page_alloc(0));
f0101baa:	8d 83 0e dc fe ff    	lea    -0x123f2(%ebx),%eax
f0101bb0:	50                   	push   %eax
f0101bb1:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101bb7:	50                   	push   %eax
f0101bb8:	68 db 02 00 00       	push   $0x2db
f0101bbd:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101bc3:	50                   	push   %eax
f0101bc4:	e8 63 e5 ff ff       	call   f010012c <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bc9:	52                   	push   %edx
f0101bca:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0101bd0:	50                   	push   %eax
f0101bd1:	6a 55                	push   $0x55
f0101bd3:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f0101bd9:	50                   	push   %eax
f0101bda:	e8 4d e5 ff ff       	call   f010012c <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101bdf:	8d 83 1d dc fe ff    	lea    -0x123e3(%ebx),%eax
f0101be5:	50                   	push   %eax
f0101be6:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101bec:	50                   	push   %eax
f0101bed:	68 e0 02 00 00       	push   $0x2e0
f0101bf2:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101bf8:	50                   	push   %eax
f0101bf9:	e8 2e e5 ff ff       	call   f010012c <_panic>
	assert(pp && pp0 == pp);
f0101bfe:	8d 83 3b dc fe ff    	lea    -0x123c5(%ebx),%eax
f0101c04:	50                   	push   %eax
f0101c05:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101c0b:	50                   	push   %eax
f0101c0c:	68 e1 02 00 00       	push   $0x2e1
f0101c11:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101c17:	50                   	push   %eax
f0101c18:	e8 0f e5 ff ff       	call   f010012c <_panic>
f0101c1d:	52                   	push   %edx
f0101c1e:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0101c24:	50                   	push   %eax
f0101c25:	6a 55                	push   $0x55
f0101c27:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f0101c2d:	50                   	push   %eax
f0101c2e:	e8 f9 e4 ff ff       	call   f010012c <_panic>
		assert(c[i] == 0);
f0101c33:	8d 83 4b dc fe ff    	lea    -0x123b5(%ebx),%eax
f0101c39:	50                   	push   %eax
f0101c3a:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0101c40:	50                   	push   %eax
f0101c41:	68 e4 02 00 00       	push   $0x2e4
f0101c46:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0101c4c:	50                   	push   %eax
f0101c4d:	e8 da e4 ff ff       	call   f010012c <_panic>
	assert(nfree == 0);
f0101c52:	85 f6                	test   %esi,%esi
f0101c54:	0f 85 81 09 00 00    	jne    f01025db <mem_init+0xf73>
	cprintf("check_page_alloc() succeeded!\n");
f0101c5a:	83 ec 0c             	sub    $0xc,%esp
f0101c5d:	8d 83 48 d5 fe ff    	lea    -0x12ab8(%ebx),%eax
f0101c63:	50                   	push   %eax
f0101c64:	e8 2c 13 00 00       	call   f0102f95 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c70:	e8 99 f3 ff ff       	call   f010100e <page_alloc>
f0101c75:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c78:	83 c4 10             	add    $0x10,%esp
f0101c7b:	85 c0                	test   %eax,%eax
f0101c7d:	0f 84 77 09 00 00    	je     f01025fa <mem_init+0xf92>
	assert((pp1 = page_alloc(0)));
f0101c83:	83 ec 0c             	sub    $0xc,%esp
f0101c86:	6a 00                	push   $0x0
f0101c88:	e8 81 f3 ff ff       	call   f010100e <page_alloc>
f0101c8d:	89 c7                	mov    %eax,%edi
f0101c8f:	83 c4 10             	add    $0x10,%esp
f0101c92:	85 c0                	test   %eax,%eax
f0101c94:	0f 84 7f 09 00 00    	je     f0102619 <mem_init+0xfb1>
	assert((pp2 = page_alloc(0)));
f0101c9a:	83 ec 0c             	sub    $0xc,%esp
f0101c9d:	6a 00                	push   $0x0
f0101c9f:	e8 6a f3 ff ff       	call   f010100e <page_alloc>
f0101ca4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ca7:	83 c4 10             	add    $0x10,%esp
f0101caa:	85 c0                	test   %eax,%eax
f0101cac:	0f 84 86 09 00 00    	je     f0102638 <mem_init+0xfd0>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cb2:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101cb5:	0f 84 9c 09 00 00    	je     f0102657 <mem_init+0xfef>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cbb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cbe:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101cc1:	0f 84 af 09 00 00    	je     f0102676 <mem_init+0x100e>
f0101cc7:	39 c7                	cmp    %eax,%edi
f0101cc9:	0f 84 a7 09 00 00    	je     f0102676 <mem_init+0x100e>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ccf:	8b 83 bc 1f 00 00    	mov    0x1fbc(%ebx),%eax
f0101cd5:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101cd8:	c7 83 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%ebx)
f0101cdf:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ce2:	83 ec 0c             	sub    $0xc,%esp
f0101ce5:	6a 00                	push   $0x0
f0101ce7:	e8 22 f3 ff ff       	call   f010100e <page_alloc>
f0101cec:	83 c4 10             	add    $0x10,%esp
f0101cef:	85 c0                	test   %eax,%eax
f0101cf1:	0f 85 9e 09 00 00    	jne    f0102695 <mem_init+0x102d>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101cf7:	83 ec 04             	sub    $0x4,%esp
f0101cfa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101cfd:	50                   	push   %eax
f0101cfe:	6a 00                	push   $0x0
f0101d00:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101d06:	e8 77 f5 ff ff       	call   f0101282 <page_lookup>
f0101d0b:	83 c4 10             	add    $0x10,%esp
f0101d0e:	85 c0                	test   %eax,%eax
f0101d10:	0f 85 9e 09 00 00    	jne    f01026b4 <mem_init+0x104c>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d16:	6a 02                	push   $0x2
f0101d18:	6a 00                	push   $0x0
f0101d1a:	57                   	push   %edi
f0101d1b:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101d21:	e8 15 f6 ff ff       	call   f010133b <page_insert>
f0101d26:	83 c4 10             	add    $0x10,%esp
f0101d29:	85 c0                	test   %eax,%eax
f0101d2b:	0f 89 a2 09 00 00    	jns    f01026d3 <mem_init+0x106b>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d31:	83 ec 0c             	sub    $0xc,%esp
f0101d34:	ff 75 d0             	push   -0x30(%ebp)
f0101d37:	e8 5b f3 ff ff       	call   f0101097 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d3c:	6a 02                	push   $0x2
f0101d3e:	6a 00                	push   $0x0
f0101d40:	57                   	push   %edi
f0101d41:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101d47:	e8 ef f5 ff ff       	call   f010133b <page_insert>
f0101d4c:	83 c4 20             	add    $0x20,%esp
f0101d4f:	85 c0                	test   %eax,%eax
f0101d51:	0f 85 9b 09 00 00    	jne    f01026f2 <mem_init+0x108a>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d57:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0101d5d:	8b 8b ac 1f 00 00    	mov    0x1fac(%ebx),%ecx
f0101d63:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101d66:	8b 16                	mov    (%esi),%edx
f0101d68:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d71:	29 c8                	sub    %ecx,%eax
f0101d73:	c1 f8 03             	sar    $0x3,%eax
f0101d76:	c1 e0 0c             	shl    $0xc,%eax
f0101d79:	39 c2                	cmp    %eax,%edx
f0101d7b:	0f 85 90 09 00 00    	jne    f0102711 <mem_init+0x10a9>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d81:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d86:	89 f0                	mov    %esi,%eax
f0101d88:	e8 d4 ed ff ff       	call   f0100b61 <check_va2pa>
f0101d8d:	89 c2                	mov    %eax,%edx
f0101d8f:	89 f8                	mov    %edi,%eax
f0101d91:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101d94:	c1 f8 03             	sar    $0x3,%eax
f0101d97:	c1 e0 0c             	shl    $0xc,%eax
f0101d9a:	39 c2                	cmp    %eax,%edx
f0101d9c:	0f 85 8e 09 00 00    	jne    f0102730 <mem_init+0x10c8>
	assert(pp1->pp_ref == 1);
f0101da2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101da7:	0f 85 a2 09 00 00    	jne    f010274f <mem_init+0x10e7>
	assert(pp0->pp_ref == 1);
f0101dad:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101db0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101db5:	0f 85 b3 09 00 00    	jne    f010276e <mem_init+0x1106>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dbb:	6a 02                	push   $0x2
f0101dbd:	68 00 10 00 00       	push   $0x1000
f0101dc2:	ff 75 d4             	push   -0x2c(%ebp)
f0101dc5:	56                   	push   %esi
f0101dc6:	e8 70 f5 ff ff       	call   f010133b <page_insert>
f0101dcb:	83 c4 10             	add    $0x10,%esp
f0101dce:	85 c0                	test   %eax,%eax
f0101dd0:	0f 85 b7 09 00 00    	jne    f010278d <mem_init+0x1125>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dd6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ddb:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101de1:	e8 7b ed ff ff       	call   f0100b61 <check_va2pa>
f0101de6:	89 c2                	mov    %eax,%edx
f0101de8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101deb:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101df1:	c1 f8 03             	sar    $0x3,%eax
f0101df4:	c1 e0 0c             	shl    $0xc,%eax
f0101df7:	39 c2                	cmp    %eax,%edx
f0101df9:	0f 85 ad 09 00 00    	jne    f01027ac <mem_init+0x1144>
	assert(pp2->pp_ref == 1);
f0101dff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e02:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e07:	0f 85 be 09 00 00    	jne    f01027cb <mem_init+0x1163>

	// should be no free memory
	assert(!page_alloc(0));
f0101e0d:	83 ec 0c             	sub    $0xc,%esp
f0101e10:	6a 00                	push   $0x0
f0101e12:	e8 f7 f1 ff ff       	call   f010100e <page_alloc>
f0101e17:	83 c4 10             	add    $0x10,%esp
f0101e1a:	85 c0                	test   %eax,%eax
f0101e1c:	0f 85 c8 09 00 00    	jne    f01027ea <mem_init+0x1182>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e22:	6a 02                	push   $0x2
f0101e24:	68 00 10 00 00       	push   $0x1000
f0101e29:	ff 75 d4             	push   -0x2c(%ebp)
f0101e2c:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101e32:	e8 04 f5 ff ff       	call   f010133b <page_insert>
f0101e37:	83 c4 10             	add    $0x10,%esp
f0101e3a:	85 c0                	test   %eax,%eax
f0101e3c:	0f 85 c7 09 00 00    	jne    f0102809 <mem_init+0x11a1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e42:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e47:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101e4d:	e8 0f ed ff ff       	call   f0100b61 <check_va2pa>
f0101e52:	89 c2                	mov    %eax,%edx
f0101e54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e57:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101e5d:	c1 f8 03             	sar    $0x3,%eax
f0101e60:	c1 e0 0c             	shl    $0xc,%eax
f0101e63:	39 c2                	cmp    %eax,%edx
f0101e65:	0f 85 bd 09 00 00    	jne    f0102828 <mem_init+0x11c0>
	assert(pp2->pp_ref == 1);
f0101e6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e6e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e73:	0f 85 ce 09 00 00    	jne    f0102847 <mem_init+0x11df>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e79:	83 ec 0c             	sub    $0xc,%esp
f0101e7c:	6a 00                	push   $0x0
f0101e7e:	e8 8b f1 ff ff       	call   f010100e <page_alloc>
f0101e83:	83 c4 10             	add    $0x10,%esp
f0101e86:	85 c0                	test   %eax,%eax
f0101e88:	0f 85 d8 09 00 00    	jne    f0102866 <mem_init+0x11fe>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e8e:	8b 93 b0 1f 00 00    	mov    0x1fb0(%ebx),%edx
f0101e94:	8b 02                	mov    (%edx),%eax
f0101e96:	89 c6                	mov    %eax,%esi
f0101e98:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101e9e:	c1 e8 0c             	shr    $0xc,%eax
f0101ea1:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0101ea7:	0f 83 d8 09 00 00    	jae    f0102885 <mem_init+0x121d>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ead:	83 ec 04             	sub    $0x4,%esp
f0101eb0:	6a 00                	push   $0x0
f0101eb2:	68 00 10 00 00       	push   $0x1000
f0101eb7:	52                   	push   %edx
f0101eb8:	e8 75 f2 ff ff       	call   f0101132 <pgdir_walk>
f0101ebd:	81 ee fc ff ff 0f    	sub    $0xffffffc,%esi
f0101ec3:	83 c4 10             	add    $0x10,%esp
f0101ec6:	39 f0                	cmp    %esi,%eax
f0101ec8:	0f 85 d0 09 00 00    	jne    f010289e <mem_init+0x1236>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ece:	6a 06                	push   $0x6
f0101ed0:	68 00 10 00 00       	push   $0x1000
f0101ed5:	ff 75 d4             	push   -0x2c(%ebp)
f0101ed8:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101ede:	e8 58 f4 ff ff       	call   f010133b <page_insert>
f0101ee3:	83 c4 10             	add    $0x10,%esp
f0101ee6:	85 c0                	test   %eax,%eax
f0101ee8:	0f 85 cf 09 00 00    	jne    f01028bd <mem_init+0x1255>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eee:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
f0101ef4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ef9:	89 f0                	mov    %esi,%eax
f0101efb:	e8 61 ec ff ff       	call   f0100b61 <check_va2pa>
f0101f00:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0101f02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f05:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101f0b:	c1 f8 03             	sar    $0x3,%eax
f0101f0e:	c1 e0 0c             	shl    $0xc,%eax
f0101f11:	39 c2                	cmp    %eax,%edx
f0101f13:	0f 85 c3 09 00 00    	jne    f01028dc <mem_init+0x1274>
	assert(pp2->pp_ref == 1);
f0101f19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f1c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f21:	0f 85 d4 09 00 00    	jne    f01028fb <mem_init+0x1293>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f27:	83 ec 04             	sub    $0x4,%esp
f0101f2a:	6a 00                	push   $0x0
f0101f2c:	68 00 10 00 00       	push   $0x1000
f0101f31:	56                   	push   %esi
f0101f32:	e8 fb f1 ff ff       	call   f0101132 <pgdir_walk>
f0101f37:	83 c4 10             	add    $0x10,%esp
f0101f3a:	f6 00 04             	testb  $0x4,(%eax)
f0101f3d:	0f 84 d7 09 00 00    	je     f010291a <mem_init+0x12b2>
	assert(kern_pgdir[0] & PTE_U);
f0101f43:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101f49:	f6 00 04             	testb  $0x4,(%eax)
f0101f4c:	0f 84 e7 09 00 00    	je     f0102939 <mem_init+0x12d1>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f52:	6a 02                	push   $0x2
f0101f54:	68 00 10 00 00       	push   $0x1000
f0101f59:	ff 75 d4             	push   -0x2c(%ebp)
f0101f5c:	50                   	push   %eax
f0101f5d:	e8 d9 f3 ff ff       	call   f010133b <page_insert>
f0101f62:	83 c4 10             	add    $0x10,%esp
f0101f65:	85 c0                	test   %eax,%eax
f0101f67:	0f 85 eb 09 00 00    	jne    f0102958 <mem_init+0x12f0>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f6d:	83 ec 04             	sub    $0x4,%esp
f0101f70:	6a 00                	push   $0x0
f0101f72:	68 00 10 00 00       	push   $0x1000
f0101f77:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101f7d:	e8 b0 f1 ff ff       	call   f0101132 <pgdir_walk>
f0101f82:	83 c4 10             	add    $0x10,%esp
f0101f85:	f6 00 02             	testb  $0x2,(%eax)
f0101f88:	0f 84 e9 09 00 00    	je     f0102977 <mem_init+0x130f>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f8e:	83 ec 04             	sub    $0x4,%esp
f0101f91:	6a 00                	push   $0x0
f0101f93:	68 00 10 00 00       	push   $0x1000
f0101f98:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101f9e:	e8 8f f1 ff ff       	call   f0101132 <pgdir_walk>
f0101fa3:	83 c4 10             	add    $0x10,%esp
f0101fa6:	f6 00 04             	testb  $0x4,(%eax)
f0101fa9:	0f 85 e7 09 00 00    	jne    f0102996 <mem_init+0x132e>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101faf:	6a 02                	push   $0x2
f0101fb1:	68 00 00 40 00       	push   $0x400000
f0101fb6:	ff 75 d0             	push   -0x30(%ebp)
f0101fb9:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101fbf:	e8 77 f3 ff ff       	call   f010133b <page_insert>
f0101fc4:	83 c4 10             	add    $0x10,%esp
f0101fc7:	85 c0                	test   %eax,%eax
f0101fc9:	0f 89 e6 09 00 00    	jns    f01029b5 <mem_init+0x134d>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fcf:	6a 02                	push   $0x2
f0101fd1:	68 00 10 00 00       	push   $0x1000
f0101fd6:	57                   	push   %edi
f0101fd7:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101fdd:	e8 59 f3 ff ff       	call   f010133b <page_insert>
f0101fe2:	83 c4 10             	add    $0x10,%esp
f0101fe5:	85 c0                	test   %eax,%eax
f0101fe7:	0f 85 e7 09 00 00    	jne    f01029d4 <mem_init+0x136c>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fed:	83 ec 04             	sub    $0x4,%esp
f0101ff0:	6a 00                	push   $0x0
f0101ff2:	68 00 10 00 00       	push   $0x1000
f0101ff7:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101ffd:	e8 30 f1 ff ff       	call   f0101132 <pgdir_walk>
f0102002:	83 c4 10             	add    $0x10,%esp
f0102005:	f6 00 04             	testb  $0x4,(%eax)
f0102008:	0f 85 e5 09 00 00    	jne    f01029f3 <mem_init+0x138b>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010200e:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0102014:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102017:	ba 00 00 00 00       	mov    $0x0,%edx
f010201c:	e8 40 eb ff ff       	call   f0100b61 <check_va2pa>
f0102021:	89 fe                	mov    %edi,%esi
f0102023:	2b b3 ac 1f 00 00    	sub    0x1fac(%ebx),%esi
f0102029:	c1 fe 03             	sar    $0x3,%esi
f010202c:	c1 e6 0c             	shl    $0xc,%esi
f010202f:	39 f0                	cmp    %esi,%eax
f0102031:	0f 85 db 09 00 00    	jne    f0102a12 <mem_init+0x13aa>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102037:	ba 00 10 00 00       	mov    $0x1000,%edx
f010203c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010203f:	e8 1d eb ff ff       	call   f0100b61 <check_va2pa>
f0102044:	39 c6                	cmp    %eax,%esi
f0102046:	0f 85 e5 09 00 00    	jne    f0102a31 <mem_init+0x13c9>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010204c:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102051:	0f 85 f9 09 00 00    	jne    f0102a50 <mem_init+0x13e8>
	assert(pp2->pp_ref == 0);
f0102057:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010205a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010205f:	0f 85 0a 0a 00 00    	jne    f0102a6f <mem_init+0x1407>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102065:	83 ec 0c             	sub    $0xc,%esp
f0102068:	6a 00                	push   $0x0
f010206a:	e8 9f ef ff ff       	call   f010100e <page_alloc>
f010206f:	83 c4 10             	add    $0x10,%esp
f0102072:	85 c0                	test   %eax,%eax
f0102074:	0f 84 14 0a 00 00    	je     f0102a8e <mem_init+0x1426>
f010207a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010207d:	0f 85 0b 0a 00 00    	jne    f0102a8e <mem_init+0x1426>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102083:	83 ec 08             	sub    $0x8,%esp
f0102086:	6a 00                	push   $0x0
f0102088:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f010208e:	e8 66 f2 ff ff       	call   f01012f9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102093:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
f0102099:	ba 00 00 00 00       	mov    $0x0,%edx
f010209e:	89 f0                	mov    %esi,%eax
f01020a0:	e8 bc ea ff ff       	call   f0100b61 <check_va2pa>
f01020a5:	83 c4 10             	add    $0x10,%esp
f01020a8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020ab:	0f 85 fc 09 00 00    	jne    f0102aad <mem_init+0x1445>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020b1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020b6:	89 f0                	mov    %esi,%eax
f01020b8:	e8 a4 ea ff ff       	call   f0100b61 <check_va2pa>
f01020bd:	89 c2                	mov    %eax,%edx
f01020bf:	89 f8                	mov    %edi,%eax
f01020c1:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f01020c7:	c1 f8 03             	sar    $0x3,%eax
f01020ca:	c1 e0 0c             	shl    $0xc,%eax
f01020cd:	39 c2                	cmp    %eax,%edx
f01020cf:	0f 85 f7 09 00 00    	jne    f0102acc <mem_init+0x1464>
	assert(pp1->pp_ref == 1);
f01020d5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01020da:	0f 85 0b 0a 00 00    	jne    f0102aeb <mem_init+0x1483>
	assert(pp2->pp_ref == 0);
f01020e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020e3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01020e8:	0f 85 1c 0a 00 00    	jne    f0102b0a <mem_init+0x14a2>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01020ee:	6a 00                	push   $0x0
f01020f0:	68 00 10 00 00       	push   $0x1000
f01020f5:	57                   	push   %edi
f01020f6:	56                   	push   %esi
f01020f7:	e8 3f f2 ff ff       	call   f010133b <page_insert>
f01020fc:	83 c4 10             	add    $0x10,%esp
f01020ff:	85 c0                	test   %eax,%eax
f0102101:	0f 85 22 0a 00 00    	jne    f0102b29 <mem_init+0x14c1>
	assert(pp1->pp_ref);
f0102107:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010210c:	0f 84 36 0a 00 00    	je     f0102b48 <mem_init+0x14e0>
	assert(pp1->pp_link == NULL);
f0102112:	83 3f 00             	cmpl   $0x0,(%edi)
f0102115:	0f 85 4c 0a 00 00    	jne    f0102b67 <mem_init+0x14ff>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010211b:	83 ec 08             	sub    $0x8,%esp
f010211e:	68 00 10 00 00       	push   $0x1000
f0102123:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0102129:	e8 cb f1 ff ff       	call   f01012f9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010212e:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
f0102134:	ba 00 00 00 00       	mov    $0x0,%edx
f0102139:	89 f0                	mov    %esi,%eax
f010213b:	e8 21 ea ff ff       	call   f0100b61 <check_va2pa>
f0102140:	83 c4 10             	add    $0x10,%esp
f0102143:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102146:	0f 85 3a 0a 00 00    	jne    f0102b86 <mem_init+0x151e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010214c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102151:	89 f0                	mov    %esi,%eax
f0102153:	e8 09 ea ff ff       	call   f0100b61 <check_va2pa>
f0102158:	83 f8 ff             	cmp    $0xffffffff,%eax
f010215b:	0f 85 44 0a 00 00    	jne    f0102ba5 <mem_init+0x153d>
	assert(pp1->pp_ref == 0);
f0102161:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102166:	0f 85 58 0a 00 00    	jne    f0102bc4 <mem_init+0x155c>
	assert(pp2->pp_ref == 0);
f010216c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010216f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102174:	0f 85 69 0a 00 00    	jne    f0102be3 <mem_init+0x157b>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010217a:	83 ec 0c             	sub    $0xc,%esp
f010217d:	6a 00                	push   $0x0
f010217f:	e8 8a ee ff ff       	call   f010100e <page_alloc>
f0102184:	83 c4 10             	add    $0x10,%esp
f0102187:	39 c7                	cmp    %eax,%edi
f0102189:	0f 85 73 0a 00 00    	jne    f0102c02 <mem_init+0x159a>
f010218f:	85 c0                	test   %eax,%eax
f0102191:	0f 84 6b 0a 00 00    	je     f0102c02 <mem_init+0x159a>

	// should be no free memory
	assert(!page_alloc(0));
f0102197:	83 ec 0c             	sub    $0xc,%esp
f010219a:	6a 00                	push   $0x0
f010219c:	e8 6d ee ff ff       	call   f010100e <page_alloc>
f01021a1:	83 c4 10             	add    $0x10,%esp
f01021a4:	85 c0                	test   %eax,%eax
f01021a6:	0f 85 75 0a 00 00    	jne    f0102c21 <mem_init+0x15b9>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01021ac:	8b 8b b0 1f 00 00    	mov    0x1fb0(%ebx),%ecx
f01021b2:	8b 11                	mov    (%ecx),%edx
f01021b4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01021bd:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f01021c3:	c1 f8 03             	sar    $0x3,%eax
f01021c6:	c1 e0 0c             	shl    $0xc,%eax
f01021c9:	39 c2                	cmp    %eax,%edx
f01021cb:	0f 85 6f 0a 00 00    	jne    f0102c40 <mem_init+0x15d8>
	kern_pgdir[0] = 0;
f01021d1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01021d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01021da:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021df:	0f 85 7a 0a 00 00    	jne    f0102c5f <mem_init+0x15f7>
	pp0->pp_ref = 0;
f01021e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01021e8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021ee:	83 ec 0c             	sub    $0xc,%esp
f01021f1:	50                   	push   %eax
f01021f2:	e8 a0 ee ff ff       	call   f0101097 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021f7:	83 c4 0c             	add    $0xc,%esp
f01021fa:	6a 01                	push   $0x1
f01021fc:	68 00 10 40 00       	push   $0x401000
f0102201:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0102207:	e8 26 ef ff ff       	call   f0101132 <pgdir_walk>
f010220c:	89 45 cc             	mov    %eax,-0x34(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010220f:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
f0102215:	8b 46 04             	mov    0x4(%esi),%eax
f0102218:	89 c2                	mov    %eax,%edx
f010221a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102220:	8b 8b b4 1f 00 00    	mov    0x1fb4(%ebx),%ecx
f0102226:	c1 e8 0c             	shr    $0xc,%eax
f0102229:	83 c4 10             	add    $0x10,%esp
f010222c:	39 c8                	cmp    %ecx,%eax
f010222e:	0f 83 4a 0a 00 00    	jae    f0102c7e <mem_init+0x1616>
	assert(ptep == ptep1 + PTX(va));
f0102234:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010223a:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f010223d:	0f 85 54 0a 00 00    	jne    f0102c97 <mem_init+0x162f>
	kern_pgdir[PDX(va)] = 0;
f0102243:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	pp0->pp_ref = 0;
f010224a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010224d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0102253:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0102259:	c1 f8 03             	sar    $0x3,%eax
f010225c:	89 c2                	mov    %eax,%edx
f010225e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102261:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102266:	39 c1                	cmp    %eax,%ecx
f0102268:	0f 86 48 0a 00 00    	jbe    f0102cb6 <mem_init+0x164e>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010226e:	83 ec 04             	sub    $0x4,%esp
f0102271:	68 00 10 00 00       	push   $0x1000
f0102276:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010227b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102281:	52                   	push   %edx
f0102282:	e8 20 19 00 00       	call   f0103ba7 <memset>
	page_free(pp0);
f0102287:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010228a:	89 34 24             	mov    %esi,(%esp)
f010228d:	e8 05 ee ff ff       	call   f0101097 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102292:	83 c4 0c             	add    $0xc,%esp
f0102295:	6a 01                	push   $0x1
f0102297:	6a 00                	push   $0x0
f0102299:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f010229f:	e8 8e ee ff ff       	call   f0101132 <pgdir_walk>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f01022a4:	89 f0                	mov    %esi,%eax
f01022a6:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f01022ac:	c1 f8 03             	sar    $0x3,%eax
f01022af:	89 c2                	mov    %eax,%edx
f01022b1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01022b4:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01022b9:	83 c4 10             	add    $0x10,%esp
f01022bc:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f01022c2:	0f 83 04 0a 00 00    	jae    f0102ccc <mem_init+0x1664>
	return (void *)(pa + KERNBASE);
f01022c8:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01022ce:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022d4:	f6 00 01             	testb  $0x1,(%eax)
f01022d7:	0f 85 05 0a 00 00    	jne    f0102ce2 <mem_init+0x167a>
	for(i=0; i<NPTENTRIES; i++)
f01022dd:	83 c0 04             	add    $0x4,%eax
f01022e0:	39 c2                	cmp    %eax,%edx
f01022e2:	75 f0                	jne    f01022d4 <mem_init+0xc6c>
	kern_pgdir[0] = 0;
f01022e4:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f01022ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01022f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01022f3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01022f9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01022fc:	89 8b bc 1f 00 00    	mov    %ecx,0x1fbc(%ebx)

	// free the pages we took
	page_free(pp0);
f0102302:	83 ec 0c             	sub    $0xc,%esp
f0102305:	50                   	push   %eax
f0102306:	e8 8c ed ff ff       	call   f0101097 <page_free>
	page_free(pp1);
f010230b:	89 3c 24             	mov    %edi,(%esp)
f010230e:	e8 84 ed ff ff       	call   f0101097 <page_free>
	page_free(pp2);
f0102313:	83 c4 04             	add    $0x4,%esp
f0102316:	ff 75 d4             	push   -0x2c(%ebp)
f0102319:	e8 79 ed ff ff       	call   f0101097 <page_free>

	cprintf("check_page() succeeded!\n");
f010231e:	8d 83 2c dd fe ff    	lea    -0x122d4(%ebx),%eax
f0102324:	89 04 24             	mov    %eax,(%esp)
f0102327:	e8 69 0c 00 00       	call   f0102f95 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010232c:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102332:	83 c4 10             	add    $0x10,%esp
f0102335:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010233a:	0f 86 c1 09 00 00    	jbe    f0102d01 <mem_init+0x1699>
f0102340:	83 ec 08             	sub    $0x8,%esp
f0102343:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102345:	05 00 00 00 10       	add    $0x10000000,%eax
f010234a:	50                   	push   %eax
f010234b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102350:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102355:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f010235b:	e8 9e ee ff ff       	call   f01011fe <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102360:	c7 c0 00 e0 10 f0    	mov    $0xf010e000,%eax
f0102366:	83 c4 10             	add    $0x10,%esp
f0102369:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010236e:	0f 86 a6 09 00 00    	jbe    f0102d1a <mem_init+0x16b2>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102374:	83 ec 08             	sub    $0x8,%esp
f0102377:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102379:	05 00 00 00 10       	add    $0x10000000,%eax
f010237e:	50                   	push   %eax
f010237f:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102384:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102389:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f010238f:	e8 6a ee ff ff       	call   f01011fe <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f0102394:	83 c4 08             	add    $0x8,%esp
f0102397:	6a 02                	push   $0x2
f0102399:	6a 00                	push   $0x0
f010239b:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01023a0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01023a5:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f01023ab:	e8 4e ee ff ff       	call   f01011fe <boot_map_region>
	check_kern_pgdir();
f01023b0:	e8 09 f0 ff ff       	call   f01013be <check_kern_pgdir>
	lcr3(PADDR(kern_pgdir));
f01023b5:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01023bb:	83 c4 10             	add    $0x10,%esp
f01023be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023c3:	0f 86 6a 09 00 00    	jbe    f0102d33 <mem_init+0x16cb>
	return (physaddr_t)kva - KERNBASE;
f01023c9:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01023ce:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01023d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01023d6:	e8 02 e8 ff ff       	call   f0100bdd <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01023db:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01023de:	83 e0 f3             	and    $0xfffffff3,%eax
f01023e1:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01023e6:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01023e9:	83 ec 0c             	sub    $0xc,%esp
f01023ec:	6a 00                	push   $0x0
f01023ee:	e8 1b ec ff ff       	call   f010100e <page_alloc>
f01023f3:	89 c6                	mov    %eax,%esi
f01023f5:	83 c4 10             	add    $0x10,%esp
f01023f8:	85 c0                	test   %eax,%eax
f01023fa:	0f 84 4c 09 00 00    	je     f0102d4c <mem_init+0x16e4>
	assert((pp1 = page_alloc(0)));
f0102400:	83 ec 0c             	sub    $0xc,%esp
f0102403:	6a 00                	push   $0x0
f0102405:	e8 04 ec ff ff       	call   f010100e <page_alloc>
f010240a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010240d:	83 c4 10             	add    $0x10,%esp
f0102410:	85 c0                	test   %eax,%eax
f0102412:	0f 84 53 09 00 00    	je     f0102d6b <mem_init+0x1703>
	assert((pp2 = page_alloc(0)));
f0102418:	83 ec 0c             	sub    $0xc,%esp
f010241b:	6a 00                	push   $0x0
f010241d:	e8 ec eb ff ff       	call   f010100e <page_alloc>
f0102422:	89 c7                	mov    %eax,%edi
f0102424:	83 c4 10             	add    $0x10,%esp
f0102427:	85 c0                	test   %eax,%eax
f0102429:	0f 84 5b 09 00 00    	je     f0102d8a <mem_init+0x1722>
	page_free(pp0);
f010242f:	83 ec 0c             	sub    $0xc,%esp
f0102432:	56                   	push   %esi
f0102433:	e8 5f ec ff ff       	call   f0101097 <page_free>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0102438:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010243b:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0102441:	c1 f8 03             	sar    $0x3,%eax
f0102444:	89 c2                	mov    %eax,%edx
f0102446:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102449:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010244e:	83 c4 10             	add    $0x10,%esp
f0102451:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0102457:	0f 83 4c 09 00 00    	jae    f0102da9 <mem_init+0x1741>
	memset(page2kva(pp1), 1, PGSIZE);
f010245d:	83 ec 04             	sub    $0x4,%esp
f0102460:	68 00 10 00 00       	push   $0x1000
f0102465:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102467:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010246d:	52                   	push   %edx
f010246e:	e8 34 17 00 00       	call   f0103ba7 <memset>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0102473:	89 f8                	mov    %edi,%eax
f0102475:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f010247b:	c1 f8 03             	sar    $0x3,%eax
f010247e:	89 c2                	mov    %eax,%edx
f0102480:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102483:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102488:	83 c4 10             	add    $0x10,%esp
f010248b:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0102491:	0f 83 28 09 00 00    	jae    f0102dbf <mem_init+0x1757>
	memset(page2kva(pp2), 2, PGSIZE);
f0102497:	83 ec 04             	sub    $0x4,%esp
f010249a:	68 00 10 00 00       	push   $0x1000
f010249f:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01024a1:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01024a7:	52                   	push   %edx
f01024a8:	e8 fa 16 00 00       	call   f0103ba7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01024ad:	6a 02                	push   $0x2
f01024af:	68 00 10 00 00       	push   $0x1000
f01024b4:	ff 75 d4             	push   -0x2c(%ebp)
f01024b7:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f01024bd:	e8 79 ee ff ff       	call   f010133b <page_insert>
	assert(pp1->pp_ref == 1);
f01024c2:	83 c4 20             	add    $0x20,%esp
f01024c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024c8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01024cd:	0f 85 02 09 00 00    	jne    f0102dd5 <mem_init+0x176d>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01024d3:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01024da:	01 01 01 
f01024dd:	0f 85 11 09 00 00    	jne    f0102df4 <mem_init+0x178c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01024e3:	6a 02                	push   $0x2
f01024e5:	68 00 10 00 00       	push   $0x1000
f01024ea:	57                   	push   %edi
f01024eb:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f01024f1:	e8 45 ee ff ff       	call   f010133b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01024f6:	83 c4 10             	add    $0x10,%esp
f01024f9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102500:	02 02 02 
f0102503:	0f 85 0a 09 00 00    	jne    f0102e13 <mem_init+0x17ab>
	assert(pp2->pp_ref == 1);
f0102509:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010250e:	0f 85 1e 09 00 00    	jne    f0102e32 <mem_init+0x17ca>
	assert(pp1->pp_ref == 0);
f0102514:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102517:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010251c:	0f 85 2f 09 00 00    	jne    f0102e51 <mem_init+0x17e9>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102522:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102529:	03 03 03 
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f010252c:	89 f8                	mov    %edi,%eax
f010252e:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0102534:	c1 f8 03             	sar    $0x3,%eax
f0102537:	89 c2                	mov    %eax,%edx
f0102539:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010253c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102541:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0102547:	0f 83 23 09 00 00    	jae    f0102e70 <mem_init+0x1808>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010254d:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102554:	03 03 03 
f0102557:	0f 85 29 09 00 00    	jne    f0102e86 <mem_init+0x181e>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010255d:	83 ec 08             	sub    $0x8,%esp
f0102560:	68 00 10 00 00       	push   $0x1000
f0102565:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f010256b:	e8 89 ed ff ff       	call   f01012f9 <page_remove>
	assert(pp2->pp_ref == 0);
f0102570:	83 c4 10             	add    $0x10,%esp
f0102573:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102578:	0f 85 27 09 00 00    	jne    f0102ea5 <mem_init+0x183d>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010257e:	8b 8b b0 1f 00 00    	mov    0x1fb0(%ebx),%ecx
f0102584:	8b 11                	mov    (%ecx),%edx
f0102586:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f010258c:	89 f0                	mov    %esi,%eax
f010258e:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0102594:	c1 f8 03             	sar    $0x3,%eax
f0102597:	c1 e0 0c             	shl    $0xc,%eax
f010259a:	39 c2                	cmp    %eax,%edx
f010259c:	0f 85 22 09 00 00    	jne    f0102ec4 <mem_init+0x185c>
	kern_pgdir[0] = 0;
f01025a2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01025a8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025ad:	0f 85 30 09 00 00    	jne    f0102ee3 <mem_init+0x187b>
	pp0->pp_ref = 0;
f01025b3:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01025b9:	83 ec 0c             	sub    $0xc,%esp
f01025bc:	56                   	push   %esi
f01025bd:	e8 d5 ea ff ff       	call   f0101097 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01025c2:	8d 83 f4 d9 fe ff    	lea    -0x1260c(%ebx),%eax
f01025c8:	89 04 24             	mov    %eax,(%esp)
f01025cb:	e8 c5 09 00 00       	call   f0102f95 <cprintf>
}
f01025d0:	83 c4 10             	add    $0x10,%esp
f01025d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01025d6:	5b                   	pop    %ebx
f01025d7:	5e                   	pop    %esi
f01025d8:	5f                   	pop    %edi
f01025d9:	5d                   	pop    %ebp
f01025da:	c3                   	ret    
	assert(nfree == 0);
f01025db:	8d 83 55 dc fe ff    	lea    -0x123ab(%ebx),%eax
f01025e1:	50                   	push   %eax
f01025e2:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01025e8:	50                   	push   %eax
f01025e9:	68 f1 02 00 00       	push   $0x2f1
f01025ee:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01025f4:	50                   	push   %eax
f01025f5:	e8 32 db ff ff       	call   f010012c <_panic>
	assert((pp0 = page_alloc(0)));
f01025fa:	8d 83 63 db fe ff    	lea    -0x1249d(%ebx),%eax
f0102600:	50                   	push   %eax
f0102601:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102607:	50                   	push   %eax
f0102608:	68 4b 03 00 00       	push   $0x34b
f010260d:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102613:	50                   	push   %eax
f0102614:	e8 13 db ff ff       	call   f010012c <_panic>
	assert((pp1 = page_alloc(0)));
f0102619:	8d 83 79 db fe ff    	lea    -0x12487(%ebx),%eax
f010261f:	50                   	push   %eax
f0102620:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102626:	50                   	push   %eax
f0102627:	68 4c 03 00 00       	push   $0x34c
f010262c:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102632:	50                   	push   %eax
f0102633:	e8 f4 da ff ff       	call   f010012c <_panic>
	assert((pp2 = page_alloc(0)));
f0102638:	8d 83 8f db fe ff    	lea    -0x12471(%ebx),%eax
f010263e:	50                   	push   %eax
f010263f:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102645:	50                   	push   %eax
f0102646:	68 4d 03 00 00       	push   $0x34d
f010264b:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102651:	50                   	push   %eax
f0102652:	e8 d5 da ff ff       	call   f010012c <_panic>
	assert(pp1 && pp1 != pp0);
f0102657:	8d 83 a5 db fe ff    	lea    -0x1245b(%ebx),%eax
f010265d:	50                   	push   %eax
f010265e:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102664:	50                   	push   %eax
f0102665:	68 50 03 00 00       	push   $0x350
f010266a:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102670:	50                   	push   %eax
f0102671:	e8 b6 da ff ff       	call   f010012c <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102676:	8d 83 28 d5 fe ff    	lea    -0x12ad8(%ebx),%eax
f010267c:	50                   	push   %eax
f010267d:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102683:	50                   	push   %eax
f0102684:	68 51 03 00 00       	push   $0x351
f0102689:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f010268f:	50                   	push   %eax
f0102690:	e8 97 da ff ff       	call   f010012c <_panic>
	assert(!page_alloc(0));
f0102695:	8d 83 0e dc fe ff    	lea    -0x123f2(%ebx),%eax
f010269b:	50                   	push   %eax
f010269c:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01026a2:	50                   	push   %eax
f01026a3:	68 58 03 00 00       	push   $0x358
f01026a8:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01026ae:	50                   	push   %eax
f01026af:	e8 78 da ff ff       	call   f010012c <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01026b4:	8d 83 68 d5 fe ff    	lea    -0x12a98(%ebx),%eax
f01026ba:	50                   	push   %eax
f01026bb:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01026c1:	50                   	push   %eax
f01026c2:	68 5b 03 00 00       	push   $0x35b
f01026c7:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01026cd:	50                   	push   %eax
f01026ce:	e8 59 da ff ff       	call   f010012c <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01026d3:	8d 83 a0 d5 fe ff    	lea    -0x12a60(%ebx),%eax
f01026d9:	50                   	push   %eax
f01026da:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01026e0:	50                   	push   %eax
f01026e1:	68 5e 03 00 00       	push   $0x35e
f01026e6:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01026ec:	50                   	push   %eax
f01026ed:	e8 3a da ff ff       	call   f010012c <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01026f2:	8d 83 d0 d5 fe ff    	lea    -0x12a30(%ebx),%eax
f01026f8:	50                   	push   %eax
f01026f9:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01026ff:	50                   	push   %eax
f0102700:	68 62 03 00 00       	push   $0x362
f0102705:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f010270b:	50                   	push   %eax
f010270c:	e8 1b da ff ff       	call   f010012c <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102711:	8d 83 00 d6 fe ff    	lea    -0x12a00(%ebx),%eax
f0102717:	50                   	push   %eax
f0102718:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f010271e:	50                   	push   %eax
f010271f:	68 63 03 00 00       	push   $0x363
f0102724:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f010272a:	50                   	push   %eax
f010272b:	e8 fc d9 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102730:	8d 83 28 d6 fe ff    	lea    -0x129d8(%ebx),%eax
f0102736:	50                   	push   %eax
f0102737:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f010273d:	50                   	push   %eax
f010273e:	68 64 03 00 00       	push   $0x364
f0102743:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102749:	50                   	push   %eax
f010274a:	e8 dd d9 ff ff       	call   f010012c <_panic>
	assert(pp1->pp_ref == 1);
f010274f:	8d 83 60 dc fe ff    	lea    -0x123a0(%ebx),%eax
f0102755:	50                   	push   %eax
f0102756:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f010275c:	50                   	push   %eax
f010275d:	68 65 03 00 00       	push   $0x365
f0102762:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102768:	50                   	push   %eax
f0102769:	e8 be d9 ff ff       	call   f010012c <_panic>
	assert(pp0->pp_ref == 1);
f010276e:	8d 83 71 dc fe ff    	lea    -0x1238f(%ebx),%eax
f0102774:	50                   	push   %eax
f0102775:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f010277b:	50                   	push   %eax
f010277c:	68 66 03 00 00       	push   $0x366
f0102781:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102787:	50                   	push   %eax
f0102788:	e8 9f d9 ff ff       	call   f010012c <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010278d:	8d 83 58 d6 fe ff    	lea    -0x129a8(%ebx),%eax
f0102793:	50                   	push   %eax
f0102794:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f010279a:	50                   	push   %eax
f010279b:	68 69 03 00 00       	push   $0x369
f01027a0:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01027a6:	50                   	push   %eax
f01027a7:	e8 80 d9 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01027ac:	8d 83 94 d6 fe ff    	lea    -0x1296c(%ebx),%eax
f01027b2:	50                   	push   %eax
f01027b3:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01027b9:	50                   	push   %eax
f01027ba:	68 6a 03 00 00       	push   $0x36a
f01027bf:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01027c5:	50                   	push   %eax
f01027c6:	e8 61 d9 ff ff       	call   f010012c <_panic>
	assert(pp2->pp_ref == 1);
f01027cb:	8d 83 82 dc fe ff    	lea    -0x1237e(%ebx),%eax
f01027d1:	50                   	push   %eax
f01027d2:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01027d8:	50                   	push   %eax
f01027d9:	68 6b 03 00 00       	push   $0x36b
f01027de:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01027e4:	50                   	push   %eax
f01027e5:	e8 42 d9 ff ff       	call   f010012c <_panic>
	assert(!page_alloc(0));
f01027ea:	8d 83 0e dc fe ff    	lea    -0x123f2(%ebx),%eax
f01027f0:	50                   	push   %eax
f01027f1:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01027f7:	50                   	push   %eax
f01027f8:	68 6e 03 00 00       	push   $0x36e
f01027fd:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102803:	50                   	push   %eax
f0102804:	e8 23 d9 ff ff       	call   f010012c <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102809:	8d 83 58 d6 fe ff    	lea    -0x129a8(%ebx),%eax
f010280f:	50                   	push   %eax
f0102810:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102816:	50                   	push   %eax
f0102817:	68 71 03 00 00       	push   $0x371
f010281c:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102822:	50                   	push   %eax
f0102823:	e8 04 d9 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102828:	8d 83 94 d6 fe ff    	lea    -0x1296c(%ebx),%eax
f010282e:	50                   	push   %eax
f010282f:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102835:	50                   	push   %eax
f0102836:	68 72 03 00 00       	push   $0x372
f010283b:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102841:	50                   	push   %eax
f0102842:	e8 e5 d8 ff ff       	call   f010012c <_panic>
	assert(pp2->pp_ref == 1);
f0102847:	8d 83 82 dc fe ff    	lea    -0x1237e(%ebx),%eax
f010284d:	50                   	push   %eax
f010284e:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102854:	50                   	push   %eax
f0102855:	68 73 03 00 00       	push   $0x373
f010285a:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102860:	50                   	push   %eax
f0102861:	e8 c6 d8 ff ff       	call   f010012c <_panic>
	assert(!page_alloc(0));
f0102866:	8d 83 0e dc fe ff    	lea    -0x123f2(%ebx),%eax
f010286c:	50                   	push   %eax
f010286d:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102873:	50                   	push   %eax
f0102874:	68 77 03 00 00       	push   $0x377
f0102879:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f010287f:	50                   	push   %eax
f0102880:	e8 a7 d8 ff ff       	call   f010012c <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102885:	56                   	push   %esi
f0102886:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f010288c:	50                   	push   %eax
f010288d:	68 7a 03 00 00       	push   $0x37a
f0102892:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102898:	50                   	push   %eax
f0102899:	e8 8e d8 ff ff       	call   f010012c <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010289e:	8d 83 c4 d6 fe ff    	lea    -0x1293c(%ebx),%eax
f01028a4:	50                   	push   %eax
f01028a5:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01028ab:	50                   	push   %eax
f01028ac:	68 7b 03 00 00       	push   $0x37b
f01028b1:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01028b7:	50                   	push   %eax
f01028b8:	e8 6f d8 ff ff       	call   f010012c <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01028bd:	8d 83 04 d7 fe ff    	lea    -0x128fc(%ebx),%eax
f01028c3:	50                   	push   %eax
f01028c4:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01028ca:	50                   	push   %eax
f01028cb:	68 7e 03 00 00       	push   $0x37e
f01028d0:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01028d6:	50                   	push   %eax
f01028d7:	e8 50 d8 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01028dc:	8d 83 94 d6 fe ff    	lea    -0x1296c(%ebx),%eax
f01028e2:	50                   	push   %eax
f01028e3:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01028e9:	50                   	push   %eax
f01028ea:	68 7f 03 00 00       	push   $0x37f
f01028ef:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01028f5:	50                   	push   %eax
f01028f6:	e8 31 d8 ff ff       	call   f010012c <_panic>
	assert(pp2->pp_ref == 1);
f01028fb:	8d 83 82 dc fe ff    	lea    -0x1237e(%ebx),%eax
f0102901:	50                   	push   %eax
f0102902:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102908:	50                   	push   %eax
f0102909:	68 80 03 00 00       	push   $0x380
f010290e:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102914:	50                   	push   %eax
f0102915:	e8 12 d8 ff ff       	call   f010012c <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010291a:	8d 83 44 d7 fe ff    	lea    -0x128bc(%ebx),%eax
f0102920:	50                   	push   %eax
f0102921:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102927:	50                   	push   %eax
f0102928:	68 81 03 00 00       	push   $0x381
f010292d:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102933:	50                   	push   %eax
f0102934:	e8 f3 d7 ff ff       	call   f010012c <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102939:	8d 83 93 dc fe ff    	lea    -0x1236d(%ebx),%eax
f010293f:	50                   	push   %eax
f0102940:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102946:	50                   	push   %eax
f0102947:	68 82 03 00 00       	push   $0x382
f010294c:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102952:	50                   	push   %eax
f0102953:	e8 d4 d7 ff ff       	call   f010012c <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102958:	8d 83 58 d6 fe ff    	lea    -0x129a8(%ebx),%eax
f010295e:	50                   	push   %eax
f010295f:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102965:	50                   	push   %eax
f0102966:	68 85 03 00 00       	push   $0x385
f010296b:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102971:	50                   	push   %eax
f0102972:	e8 b5 d7 ff ff       	call   f010012c <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102977:	8d 83 78 d7 fe ff    	lea    -0x12888(%ebx),%eax
f010297d:	50                   	push   %eax
f010297e:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102984:	50                   	push   %eax
f0102985:	68 86 03 00 00       	push   $0x386
f010298a:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102990:	50                   	push   %eax
f0102991:	e8 96 d7 ff ff       	call   f010012c <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102996:	8d 83 ac d7 fe ff    	lea    -0x12854(%ebx),%eax
f010299c:	50                   	push   %eax
f010299d:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01029a3:	50                   	push   %eax
f01029a4:	68 87 03 00 00       	push   $0x387
f01029a9:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01029af:	50                   	push   %eax
f01029b0:	e8 77 d7 ff ff       	call   f010012c <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01029b5:	8d 83 e4 d7 fe ff    	lea    -0x1281c(%ebx),%eax
f01029bb:	50                   	push   %eax
f01029bc:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01029c2:	50                   	push   %eax
f01029c3:	68 8a 03 00 00       	push   $0x38a
f01029c8:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01029ce:	50                   	push   %eax
f01029cf:	e8 58 d7 ff ff       	call   f010012c <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01029d4:	8d 83 1c d8 fe ff    	lea    -0x127e4(%ebx),%eax
f01029da:	50                   	push   %eax
f01029db:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f01029e1:	50                   	push   %eax
f01029e2:	68 8d 03 00 00       	push   $0x38d
f01029e7:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f01029ed:	50                   	push   %eax
f01029ee:	e8 39 d7 ff ff       	call   f010012c <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01029f3:	8d 83 ac d7 fe ff    	lea    -0x12854(%ebx),%eax
f01029f9:	50                   	push   %eax
f01029fa:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102a00:	50                   	push   %eax
f0102a01:	68 8e 03 00 00       	push   $0x38e
f0102a06:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102a0c:	50                   	push   %eax
f0102a0d:	e8 1a d7 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102a12:	8d 83 58 d8 fe ff    	lea    -0x127a8(%ebx),%eax
f0102a18:	50                   	push   %eax
f0102a19:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102a1f:	50                   	push   %eax
f0102a20:	68 91 03 00 00       	push   $0x391
f0102a25:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102a2b:	50                   	push   %eax
f0102a2c:	e8 fb d6 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a31:	8d 83 84 d8 fe ff    	lea    -0x1277c(%ebx),%eax
f0102a37:	50                   	push   %eax
f0102a38:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102a3e:	50                   	push   %eax
f0102a3f:	68 92 03 00 00       	push   $0x392
f0102a44:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102a4a:	50                   	push   %eax
f0102a4b:	e8 dc d6 ff ff       	call   f010012c <_panic>
	assert(pp1->pp_ref == 2);
f0102a50:	8d 83 a9 dc fe ff    	lea    -0x12357(%ebx),%eax
f0102a56:	50                   	push   %eax
f0102a57:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102a5d:	50                   	push   %eax
f0102a5e:	68 94 03 00 00       	push   $0x394
f0102a63:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102a69:	50                   	push   %eax
f0102a6a:	e8 bd d6 ff ff       	call   f010012c <_panic>
	assert(pp2->pp_ref == 0);
f0102a6f:	8d 83 ba dc fe ff    	lea    -0x12346(%ebx),%eax
f0102a75:	50                   	push   %eax
f0102a76:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102a7c:	50                   	push   %eax
f0102a7d:	68 95 03 00 00       	push   $0x395
f0102a82:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102a88:	50                   	push   %eax
f0102a89:	e8 9e d6 ff ff       	call   f010012c <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102a8e:	8d 83 b4 d8 fe ff    	lea    -0x1274c(%ebx),%eax
f0102a94:	50                   	push   %eax
f0102a95:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102a9b:	50                   	push   %eax
f0102a9c:	68 98 03 00 00       	push   $0x398
f0102aa1:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102aa7:	50                   	push   %eax
f0102aa8:	e8 7f d6 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102aad:	8d 83 d8 d8 fe ff    	lea    -0x12728(%ebx),%eax
f0102ab3:	50                   	push   %eax
f0102ab4:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102aba:	50                   	push   %eax
f0102abb:	68 9c 03 00 00       	push   $0x39c
f0102ac0:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102ac6:	50                   	push   %eax
f0102ac7:	e8 60 d6 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102acc:	8d 83 84 d8 fe ff    	lea    -0x1277c(%ebx),%eax
f0102ad2:	50                   	push   %eax
f0102ad3:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102ad9:	50                   	push   %eax
f0102ada:	68 9d 03 00 00       	push   $0x39d
f0102adf:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102ae5:	50                   	push   %eax
f0102ae6:	e8 41 d6 ff ff       	call   f010012c <_panic>
	assert(pp1->pp_ref == 1);
f0102aeb:	8d 83 60 dc fe ff    	lea    -0x123a0(%ebx),%eax
f0102af1:	50                   	push   %eax
f0102af2:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102af8:	50                   	push   %eax
f0102af9:	68 9e 03 00 00       	push   $0x39e
f0102afe:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102b04:	50                   	push   %eax
f0102b05:	e8 22 d6 ff ff       	call   f010012c <_panic>
	assert(pp2->pp_ref == 0);
f0102b0a:	8d 83 ba dc fe ff    	lea    -0x12346(%ebx),%eax
f0102b10:	50                   	push   %eax
f0102b11:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102b17:	50                   	push   %eax
f0102b18:	68 9f 03 00 00       	push   $0x39f
f0102b1d:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102b23:	50                   	push   %eax
f0102b24:	e8 03 d6 ff ff       	call   f010012c <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102b29:	8d 83 fc d8 fe ff    	lea    -0x12704(%ebx),%eax
f0102b2f:	50                   	push   %eax
f0102b30:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102b36:	50                   	push   %eax
f0102b37:	68 a2 03 00 00       	push   $0x3a2
f0102b3c:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102b42:	50                   	push   %eax
f0102b43:	e8 e4 d5 ff ff       	call   f010012c <_panic>
	assert(pp1->pp_ref);
f0102b48:	8d 83 cb dc fe ff    	lea    -0x12335(%ebx),%eax
f0102b4e:	50                   	push   %eax
f0102b4f:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102b55:	50                   	push   %eax
f0102b56:	68 a3 03 00 00       	push   $0x3a3
f0102b5b:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102b61:	50                   	push   %eax
f0102b62:	e8 c5 d5 ff ff       	call   f010012c <_panic>
	assert(pp1->pp_link == NULL);
f0102b67:	8d 83 d7 dc fe ff    	lea    -0x12329(%ebx),%eax
f0102b6d:	50                   	push   %eax
f0102b6e:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102b74:	50                   	push   %eax
f0102b75:	68 a4 03 00 00       	push   $0x3a4
f0102b7a:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102b80:	50                   	push   %eax
f0102b81:	e8 a6 d5 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b86:	8d 83 d8 d8 fe ff    	lea    -0x12728(%ebx),%eax
f0102b8c:	50                   	push   %eax
f0102b8d:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102b93:	50                   	push   %eax
f0102b94:	68 a8 03 00 00       	push   $0x3a8
f0102b99:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102b9f:	50                   	push   %eax
f0102ba0:	e8 87 d5 ff ff       	call   f010012c <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102ba5:	8d 83 34 d9 fe ff    	lea    -0x126cc(%ebx),%eax
f0102bab:	50                   	push   %eax
f0102bac:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102bb2:	50                   	push   %eax
f0102bb3:	68 a9 03 00 00       	push   $0x3a9
f0102bb8:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102bbe:	50                   	push   %eax
f0102bbf:	e8 68 d5 ff ff       	call   f010012c <_panic>
	assert(pp1->pp_ref == 0);
f0102bc4:	8d 83 ec dc fe ff    	lea    -0x12314(%ebx),%eax
f0102bca:	50                   	push   %eax
f0102bcb:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102bd1:	50                   	push   %eax
f0102bd2:	68 aa 03 00 00       	push   $0x3aa
f0102bd7:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102bdd:	50                   	push   %eax
f0102bde:	e8 49 d5 ff ff       	call   f010012c <_panic>
	assert(pp2->pp_ref == 0);
f0102be3:	8d 83 ba dc fe ff    	lea    -0x12346(%ebx),%eax
f0102be9:	50                   	push   %eax
f0102bea:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102bf0:	50                   	push   %eax
f0102bf1:	68 ab 03 00 00       	push   $0x3ab
f0102bf6:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102bfc:	50                   	push   %eax
f0102bfd:	e8 2a d5 ff ff       	call   f010012c <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102c02:	8d 83 5c d9 fe ff    	lea    -0x126a4(%ebx),%eax
f0102c08:	50                   	push   %eax
f0102c09:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102c0f:	50                   	push   %eax
f0102c10:	68 ae 03 00 00       	push   $0x3ae
f0102c15:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102c1b:	50                   	push   %eax
f0102c1c:	e8 0b d5 ff ff       	call   f010012c <_panic>
	assert(!page_alloc(0));
f0102c21:	8d 83 0e dc fe ff    	lea    -0x123f2(%ebx),%eax
f0102c27:	50                   	push   %eax
f0102c28:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102c2e:	50                   	push   %eax
f0102c2f:	68 b1 03 00 00       	push   $0x3b1
f0102c34:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102c3a:	50                   	push   %eax
f0102c3b:	e8 ec d4 ff ff       	call   f010012c <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c40:	8d 83 00 d6 fe ff    	lea    -0x12a00(%ebx),%eax
f0102c46:	50                   	push   %eax
f0102c47:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102c4d:	50                   	push   %eax
f0102c4e:	68 b4 03 00 00       	push   $0x3b4
f0102c53:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102c59:	50                   	push   %eax
f0102c5a:	e8 cd d4 ff ff       	call   f010012c <_panic>
	assert(pp0->pp_ref == 1);
f0102c5f:	8d 83 71 dc fe ff    	lea    -0x1238f(%ebx),%eax
f0102c65:	50                   	push   %eax
f0102c66:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102c6c:	50                   	push   %eax
f0102c6d:	68 b6 03 00 00       	push   $0x3b6
f0102c72:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102c78:	50                   	push   %eax
f0102c79:	e8 ae d4 ff ff       	call   f010012c <_panic>
f0102c7e:	52                   	push   %edx
f0102c7f:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0102c85:	50                   	push   %eax
f0102c86:	68 bd 03 00 00       	push   $0x3bd
f0102c8b:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102c91:	50                   	push   %eax
f0102c92:	e8 95 d4 ff ff       	call   f010012c <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c97:	8d 83 fd dc fe ff    	lea    -0x12303(%ebx),%eax
f0102c9d:	50                   	push   %eax
f0102c9e:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102ca4:	50                   	push   %eax
f0102ca5:	68 be 03 00 00       	push   $0x3be
f0102caa:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102cb0:	50                   	push   %eax
f0102cb1:	e8 76 d4 ff ff       	call   f010012c <_panic>
f0102cb6:	52                   	push   %edx
f0102cb7:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0102cbd:	50                   	push   %eax
f0102cbe:	6a 55                	push   $0x55
f0102cc0:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f0102cc6:	50                   	push   %eax
f0102cc7:	e8 60 d4 ff ff       	call   f010012c <_panic>
f0102ccc:	52                   	push   %edx
f0102ccd:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0102cd3:	50                   	push   %eax
f0102cd4:	6a 55                	push   $0x55
f0102cd6:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f0102cdc:	50                   	push   %eax
f0102cdd:	e8 4a d4 ff ff       	call   f010012c <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102ce2:	8d 83 15 dd fe ff    	lea    -0x122eb(%ebx),%eax
f0102ce8:	50                   	push   %eax
f0102ce9:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102cef:	50                   	push   %eax
f0102cf0:	68 c8 03 00 00       	push   $0x3c8
f0102cf5:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102cfb:	50                   	push   %eax
f0102cfc:	e8 2b d4 ff ff       	call   f010012c <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d01:	50                   	push   %eax
f0102d02:	8d 83 d4 d3 fe ff    	lea    -0x12c2c(%ebx),%eax
f0102d08:	50                   	push   %eax
f0102d09:	68 be 00 00 00       	push   $0xbe
f0102d0e:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102d14:	50                   	push   %eax
f0102d15:	e8 12 d4 ff ff       	call   f010012c <_panic>
f0102d1a:	50                   	push   %eax
f0102d1b:	8d 83 d4 d3 fe ff    	lea    -0x12c2c(%ebx),%eax
f0102d21:	50                   	push   %eax
f0102d22:	68 ca 00 00 00       	push   $0xca
f0102d27:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102d2d:	50                   	push   %eax
f0102d2e:	e8 f9 d3 ff ff       	call   f010012c <_panic>
f0102d33:	50                   	push   %eax
f0102d34:	8d 83 d4 d3 fe ff    	lea    -0x12c2c(%ebx),%eax
f0102d3a:	50                   	push   %eax
f0102d3b:	68 de 00 00 00       	push   $0xde
f0102d40:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102d46:	50                   	push   %eax
f0102d47:	e8 e0 d3 ff ff       	call   f010012c <_panic>
	assert((pp0 = page_alloc(0)));
f0102d4c:	8d 83 63 db fe ff    	lea    -0x1249d(%ebx),%eax
f0102d52:	50                   	push   %eax
f0102d53:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102d59:	50                   	push   %eax
f0102d5a:	68 e3 03 00 00       	push   $0x3e3
f0102d5f:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102d65:	50                   	push   %eax
f0102d66:	e8 c1 d3 ff ff       	call   f010012c <_panic>
	assert((pp1 = page_alloc(0)));
f0102d6b:	8d 83 79 db fe ff    	lea    -0x12487(%ebx),%eax
f0102d71:	50                   	push   %eax
f0102d72:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102d78:	50                   	push   %eax
f0102d79:	68 e4 03 00 00       	push   $0x3e4
f0102d7e:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102d84:	50                   	push   %eax
f0102d85:	e8 a2 d3 ff ff       	call   f010012c <_panic>
	assert((pp2 = page_alloc(0)));
f0102d8a:	8d 83 8f db fe ff    	lea    -0x12471(%ebx),%eax
f0102d90:	50                   	push   %eax
f0102d91:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102d97:	50                   	push   %eax
f0102d98:	68 e5 03 00 00       	push   $0x3e5
f0102d9d:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102da3:	50                   	push   %eax
f0102da4:	e8 83 d3 ff ff       	call   f010012c <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102da9:	52                   	push   %edx
f0102daa:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0102db0:	50                   	push   %eax
f0102db1:	6a 55                	push   $0x55
f0102db3:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f0102db9:	50                   	push   %eax
f0102dba:	e8 6d d3 ff ff       	call   f010012c <_panic>
f0102dbf:	52                   	push   %edx
f0102dc0:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0102dc6:	50                   	push   %eax
f0102dc7:	6a 55                	push   $0x55
f0102dc9:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f0102dcf:	50                   	push   %eax
f0102dd0:	e8 57 d3 ff ff       	call   f010012c <_panic>
	assert(pp1->pp_ref == 1);
f0102dd5:	8d 83 60 dc fe ff    	lea    -0x123a0(%ebx),%eax
f0102ddb:	50                   	push   %eax
f0102ddc:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102de2:	50                   	push   %eax
f0102de3:	68 ea 03 00 00       	push   $0x3ea
f0102de8:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102dee:	50                   	push   %eax
f0102def:	e8 38 d3 ff ff       	call   f010012c <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102df4:	8d 83 80 d9 fe ff    	lea    -0x12680(%ebx),%eax
f0102dfa:	50                   	push   %eax
f0102dfb:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102e01:	50                   	push   %eax
f0102e02:	68 eb 03 00 00       	push   $0x3eb
f0102e07:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102e0d:	50                   	push   %eax
f0102e0e:	e8 19 d3 ff ff       	call   f010012c <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e13:	8d 83 a4 d9 fe ff    	lea    -0x1265c(%ebx),%eax
f0102e19:	50                   	push   %eax
f0102e1a:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102e20:	50                   	push   %eax
f0102e21:	68 ed 03 00 00       	push   $0x3ed
f0102e26:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102e2c:	50                   	push   %eax
f0102e2d:	e8 fa d2 ff ff       	call   f010012c <_panic>
	assert(pp2->pp_ref == 1);
f0102e32:	8d 83 82 dc fe ff    	lea    -0x1237e(%ebx),%eax
f0102e38:	50                   	push   %eax
f0102e39:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102e3f:	50                   	push   %eax
f0102e40:	68 ee 03 00 00       	push   $0x3ee
f0102e45:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102e4b:	50                   	push   %eax
f0102e4c:	e8 db d2 ff ff       	call   f010012c <_panic>
	assert(pp1->pp_ref == 0);
f0102e51:	8d 83 ec dc fe ff    	lea    -0x12314(%ebx),%eax
f0102e57:	50                   	push   %eax
f0102e58:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102e5e:	50                   	push   %eax
f0102e5f:	68 ef 03 00 00       	push   $0x3ef
f0102e64:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102e6a:	50                   	push   %eax
f0102e6b:	e8 bc d2 ff ff       	call   f010012c <_panic>
f0102e70:	52                   	push   %edx
f0102e71:	8d 83 a8 d2 fe ff    	lea    -0x12d58(%ebx),%eax
f0102e77:	50                   	push   %eax
f0102e78:	6a 55                	push   $0x55
f0102e7a:	8d 83 29 da fe ff    	lea    -0x125d7(%ebx),%eax
f0102e80:	50                   	push   %eax
f0102e81:	e8 a6 d2 ff ff       	call   f010012c <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e86:	8d 83 c8 d9 fe ff    	lea    -0x12638(%ebx),%eax
f0102e8c:	50                   	push   %eax
f0102e8d:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102e93:	50                   	push   %eax
f0102e94:	68 f1 03 00 00       	push   $0x3f1
f0102e99:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102e9f:	50                   	push   %eax
f0102ea0:	e8 87 d2 ff ff       	call   f010012c <_panic>
	assert(pp2->pp_ref == 0);
f0102ea5:	8d 83 ba dc fe ff    	lea    -0x12346(%ebx),%eax
f0102eab:	50                   	push   %eax
f0102eac:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102eb2:	50                   	push   %eax
f0102eb3:	68 f3 03 00 00       	push   $0x3f3
f0102eb8:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102ebe:	50                   	push   %eax
f0102ebf:	e8 68 d2 ff ff       	call   f010012c <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ec4:	8d 83 00 d6 fe ff    	lea    -0x12a00(%ebx),%eax
f0102eca:	50                   	push   %eax
f0102ecb:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102ed1:	50                   	push   %eax
f0102ed2:	68 f6 03 00 00       	push   $0x3f6
f0102ed7:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102edd:	50                   	push   %eax
f0102ede:	e8 49 d2 ff ff       	call   f010012c <_panic>
	assert(pp0->pp_ref == 1);
f0102ee3:	8d 83 71 dc fe ff    	lea    -0x1238f(%ebx),%eax
f0102ee9:	50                   	push   %eax
f0102eea:	8d 83 43 da fe ff    	lea    -0x125bd(%ebx),%eax
f0102ef0:	50                   	push   %eax
f0102ef1:	68 f8 03 00 00       	push   $0x3f8
f0102ef6:	8d 83 1d da fe ff    	lea    -0x125e3(%ebx),%eax
f0102efc:	50                   	push   %eax
f0102efd:	e8 2a d2 ff ff       	call   f010012c <_panic>

f0102f02 <__x86.get_pc_thunk.dx>:
f0102f02:	8b 14 24             	mov    (%esp),%edx
f0102f05:	c3                   	ret    

f0102f06 <__x86.get_pc_thunk.cx>:
f0102f06:	8b 0c 24             	mov    (%esp),%ecx
f0102f09:	c3                   	ret    

f0102f0a <__x86.get_pc_thunk.di>:
f0102f0a:	8b 3c 24             	mov    (%esp),%edi
f0102f0d:	c3                   	ret    

f0102f0e <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102f0e:	55                   	push   %ebp
f0102f0f:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f0102f11:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f14:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f19:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f1a:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f1f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f20:	0f b6 c0             	movzbl %al,%eax
}
f0102f23:	5d                   	pop    %ebp
f0102f24:	c3                   	ret    

f0102f25 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f25:	55                   	push   %ebp
f0102f26:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f0102f28:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f2b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f30:	ee                   	out    %al,(%dx)
f0102f31:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f34:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f39:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f3a:	5d                   	pop    %ebp
f0102f3b:	c3                   	ret    

f0102f3c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f3c:	55                   	push   %ebp
f0102f3d:	89 e5                	mov    %esp,%ebp
f0102f3f:	53                   	push   %ebx
f0102f40:	83 ec 10             	sub    $0x10,%esp
f0102f43:	e8 9a d2 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0102f48:	81 c3 c4 43 01 00    	add    $0x143c4,%ebx
	cputchar(ch);
f0102f4e:	ff 75 08             	push   0x8(%ebp)
f0102f51:	e8 f7 d7 ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0102f56:	83 c4 10             	add    $0x10,%esp
f0102f59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f5c:	c9                   	leave  
f0102f5d:	c3                   	ret    

f0102f5e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f5e:	55                   	push   %ebp
f0102f5f:	89 e5                	mov    %esp,%ebp
f0102f61:	53                   	push   %ebx
f0102f62:	83 ec 14             	sub    $0x14,%esp
f0102f65:	e8 78 d2 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0102f6a:	81 c3 a2 43 01 00    	add    $0x143a2,%ebx
	int cnt = 0;
f0102f70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f77:	ff 75 0c             	push   0xc(%ebp)
f0102f7a:	ff 75 08             	push   0x8(%ebp)
f0102f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f80:	50                   	push   %eax
f0102f81:	8d 83 30 bc fe ff    	lea    -0x143d0(%ebx),%eax
f0102f87:	50                   	push   %eax
f0102f88:	e8 6d 04 00 00       	call   f01033fa <vprintfmt>
	return cnt;
}
f0102f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f93:	c9                   	leave  
f0102f94:	c3                   	ret    

f0102f95 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f95:	55                   	push   %ebp
f0102f96:	89 e5                	mov    %esp,%ebp
f0102f98:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f9b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f9e:	50                   	push   %eax
f0102f9f:	ff 75 08             	push   0x8(%ebp)
f0102fa2:	e8 b7 ff ff ff       	call   f0102f5e <vcprintf>
	va_end(ap);

	return cnt;
}
f0102fa7:	c9                   	leave  
f0102fa8:	c3                   	ret    

f0102fa9 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102fa9:	55                   	push   %ebp
f0102faa:	89 e5                	mov    %esp,%ebp
f0102fac:	57                   	push   %edi
f0102fad:	56                   	push   %esi
f0102fae:	53                   	push   %ebx
f0102faf:	83 ec 14             	sub    $0x14,%esp
f0102fb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102fb5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102fb8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102fbb:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102fbe:	8b 1a                	mov    (%edx),%ebx
f0102fc0:	8b 01                	mov    (%ecx),%eax
f0102fc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102fc5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102fcc:	eb 2f                	jmp    f0102ffd <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102fce:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0102fd1:	39 c3                	cmp    %eax,%ebx
f0102fd3:	7f 4e                	jg     f0103023 <stab_binsearch+0x7a>
f0102fd5:	0f b6 0a             	movzbl (%edx),%ecx
f0102fd8:	83 ea 0c             	sub    $0xc,%edx
f0102fdb:	39 f1                	cmp    %esi,%ecx
f0102fdd:	75 ef                	jne    f0102fce <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102fdf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102fe2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102fe5:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102fe9:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102fec:	73 3a                	jae    f0103028 <stab_binsearch+0x7f>
			*region_left = m;
f0102fee:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102ff1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102ff3:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0102ff6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102ffd:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103000:	7f 53                	jg     f0103055 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0103002:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103005:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0103008:	89 d0                	mov    %edx,%eax
f010300a:	c1 e8 1f             	shr    $0x1f,%eax
f010300d:	01 d0                	add    %edx,%eax
f010300f:	89 c7                	mov    %eax,%edi
f0103011:	d1 ff                	sar    %edi
f0103013:	83 e0 fe             	and    $0xfffffffe,%eax
f0103016:	01 f8                	add    %edi,%eax
f0103018:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010301b:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f010301f:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103021:	eb ae                	jmp    f0102fd1 <stab_binsearch+0x28>
			l = true_m + 1;
f0103023:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103026:	eb d5                	jmp    f0102ffd <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0103028:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010302b:	76 14                	jbe    f0103041 <stab_binsearch+0x98>
			*region_right = m - 1;
f010302d:	83 e8 01             	sub    $0x1,%eax
f0103030:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103033:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103036:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103038:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010303f:	eb bc                	jmp    f0102ffd <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103041:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103044:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103046:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010304a:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010304c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103053:	eb a8                	jmp    f0102ffd <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103055:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103059:	75 15                	jne    f0103070 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010305b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010305e:	8b 00                	mov    (%eax),%eax
f0103060:	83 e8 01             	sub    $0x1,%eax
f0103063:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103066:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103068:	83 c4 14             	add    $0x14,%esp
f010306b:	5b                   	pop    %ebx
f010306c:	5e                   	pop    %esi
f010306d:	5f                   	pop    %edi
f010306e:	5d                   	pop    %ebp
f010306f:	c3                   	ret    
		for (l = *region_right;
f0103070:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103073:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103075:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103078:	8b 0f                	mov    (%edi),%ecx
f010307a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010307d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103080:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103084:	39 c1                	cmp    %eax,%ecx
f0103086:	7d 0f                	jge    f0103097 <stab_binsearch+0xee>
f0103088:	0f b6 1a             	movzbl (%edx),%ebx
f010308b:	83 ea 0c             	sub    $0xc,%edx
f010308e:	39 f3                	cmp    %esi,%ebx
f0103090:	74 05                	je     f0103097 <stab_binsearch+0xee>
		     l--)
f0103092:	83 e8 01             	sub    $0x1,%eax
f0103095:	eb ed                	jmp    f0103084 <stab_binsearch+0xdb>
		*region_left = l;
f0103097:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010309a:	89 07                	mov    %eax,(%edi)
}
f010309c:	eb ca                	jmp    f0103068 <stab_binsearch+0xbf>

f010309e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010309e:	55                   	push   %ebp
f010309f:	89 e5                	mov    %esp,%ebp
f01030a1:	57                   	push   %edi
f01030a2:	56                   	push   %esi
f01030a3:	53                   	push   %ebx
f01030a4:	83 ec 3c             	sub    $0x3c,%esp
f01030a7:	e8 36 d1 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f01030ac:	81 c3 60 42 01 00    	add    $0x14260,%ebx
f01030b2:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01030b5:	8d 83 45 dd fe ff    	lea    -0x122bb(%ebx),%eax
f01030bb:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f01030bd:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01030c4:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f01030c7:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01030ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01030d1:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f01030d4:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01030db:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01030e0:	0f 86 3a 01 00 00    	jbe    f0103220 <debuginfo_eip+0x182>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01030e6:	c7 c0 45 bc 10 f0    	mov    $0xf010bc45,%eax
f01030ec:	39 83 f8 ff ff ff    	cmp    %eax,-0x8(%ebx)
f01030f2:	0f 86 e8 01 00 00    	jbe    f01032e0 <debuginfo_eip+0x242>
f01030f8:	c7 c0 69 db 10 f0    	mov    $0xf010db69,%eax
f01030fe:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103102:	0f 85 df 01 00 00    	jne    f01032e7 <debuginfo_eip+0x249>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103108:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010310f:	c7 c0 84 52 10 f0    	mov    $0xf0105284,%eax
f0103115:	c7 c2 44 bc 10 f0    	mov    $0xf010bc44,%edx
f010311b:	29 c2                	sub    %eax,%edx
f010311d:	c1 fa 02             	sar    $0x2,%edx
f0103120:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103126:	83 ea 01             	sub    $0x1,%edx
f0103129:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010312c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010312f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103132:	83 ec 08             	sub    $0x8,%esp
f0103135:	ff 75 08             	push   0x8(%ebp)
f0103138:	6a 64                	push   $0x64
f010313a:	e8 6a fe ff ff       	call   f0102fa9 <stab_binsearch>
	if (lfile == 0)
f010313f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103142:	83 c4 10             	add    $0x10,%esp
f0103145:	85 ff                	test   %edi,%edi
f0103147:	0f 84 a1 01 00 00    	je     f01032ee <debuginfo_eip+0x250>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010314d:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f0103150:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103153:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103156:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103159:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010315c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010315f:	83 ec 08             	sub    $0x8,%esp
f0103162:	ff 75 08             	push   0x8(%ebp)
f0103165:	6a 24                	push   $0x24
f0103167:	c7 c0 84 52 10 f0    	mov    $0xf0105284,%eax
f010316d:	e8 37 fe ff ff       	call   f0102fa9 <stab_binsearch>

	if (lfun <= rfun) {
f0103172:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103175:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f0103178:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010317b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010317e:	83 c4 10             	add    $0x10,%esp
f0103181:	89 f8                	mov    %edi,%eax
f0103183:	39 d1                	cmp    %edx,%ecx
f0103185:	7f 39                	jg     f01031c0 <debuginfo_eip+0x122>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103187:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f010318a:	c7 c2 84 52 10 f0    	mov    $0xf0105284,%edx
f0103190:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0103193:	8b 11                	mov    (%ecx),%edx
f0103195:	c7 c0 69 db 10 f0    	mov    $0xf010db69,%eax
f010319b:	81 e8 45 bc 10 f0    	sub    $0xf010bc45,%eax
f01031a1:	39 c2                	cmp    %eax,%edx
f01031a3:	73 09                	jae    f01031ae <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01031a5:	81 c2 45 bc 10 f0    	add    $0xf010bc45,%edx
f01031ab:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01031ae:	8b 41 08             	mov    0x8(%ecx),%eax
f01031b1:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f01031b4:	29 45 08             	sub    %eax,0x8(%ebp)
f01031b7:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01031ba:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01031bd:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f01031c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01031c3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01031c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01031c9:	83 ec 08             	sub    $0x8,%esp
f01031cc:	6a 3a                	push   $0x3a
f01031ce:	ff 76 08             	push   0x8(%esi)
f01031d1:	e8 b5 09 00 00       	call   f0103b8b <strfind>
f01031d6:	2b 46 08             	sub    0x8(%esi),%eax
f01031d9:	89 46 0c             	mov    %eax,0xc(%esi)
	//	which one.
	// Your code here.

	

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); // ebp as adress
f01031dc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01031df:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01031e2:	83 c4 08             	add    $0x8,%esp
f01031e5:	ff 75 08             	push   0x8(%ebp)
f01031e8:	6a 44                	push   $0x44
f01031ea:	c7 c0 84 52 10 f0    	mov    $0xf0105284,%eax
f01031f0:	e8 b4 fd ff ff       	call   f0102fa9 <stab_binsearch>
	if (lline <= rline)
f01031f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031f8:	83 c4 10             	add    $0x10,%esp
f01031fb:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01031fe:	7f 38                	jg     f0103238 <debuginfo_eip+0x19a>
	{

		info->eip_line=stabs[lline].n_desc ;
f0103200:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103203:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103206:	c7 c0 84 52 10 f0    	mov    $0xf0105284,%eax
f010320c:	0f b7 54 88 06       	movzwl 0x6(%eax,%ecx,4),%edx
f0103211:	89 56 04             	mov    %edx,0x4(%esi)
f0103214:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0103218:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010321b:	89 75 0c             	mov    %esi,0xc(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010321e:	eb 3a                	jmp    f010325a <debuginfo_eip+0x1bc>
  	        panic("User address");
f0103220:	83 ec 04             	sub    $0x4,%esp
f0103223:	8d 83 4f dd fe ff    	lea    -0x122b1(%ebx),%eax
f0103229:	50                   	push   %eax
f010322a:	6a 7f                	push   $0x7f
f010322c:	8d 83 5c dd fe ff    	lea    -0x122a4(%ebx),%eax
f0103232:	50                   	push   %eax
f0103233:	e8 f4 ce ff ff       	call   f010012c <_panic>
		cprintf("line number is not found");
f0103238:	83 ec 0c             	sub    $0xc,%esp
f010323b:	8d 83 6a dd fe ff    	lea    -0x12296(%ebx),%eax
f0103241:	50                   	push   %eax
f0103242:	e8 4e fd ff ff       	call   f0102f95 <cprintf>
		return -1 ;
f0103247:	83 c4 10             	add    $0x10,%esp
f010324a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010324f:	e9 a6 00 00 00       	jmp    f01032fa <debuginfo_eip+0x25c>
f0103254:	83 ea 01             	sub    $0x1,%edx
f0103257:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010325a:	39 d7                	cmp    %edx,%edi
f010325c:	7f 3c                	jg     f010329a <debuginfo_eip+0x1fc>
	       && stabs[lline].n_type != N_SOL
f010325e:	0f b6 08             	movzbl (%eax),%ecx
f0103261:	80 f9 84             	cmp    $0x84,%cl
f0103264:	74 0b                	je     f0103271 <debuginfo_eip+0x1d3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103266:	80 f9 64             	cmp    $0x64,%cl
f0103269:	75 e9                	jne    f0103254 <debuginfo_eip+0x1b6>
f010326b:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f010326f:	74 e3                	je     f0103254 <debuginfo_eip+0x1b6>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103271:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103274:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103277:	c7 c0 84 52 10 f0    	mov    $0xf0105284,%eax
f010327d:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0103280:	c7 c0 69 db 10 f0    	mov    $0xf010db69,%eax
f0103286:	81 e8 45 bc 10 f0    	sub    $0xf010bc45,%eax
f010328c:	39 c2                	cmp    %eax,%edx
f010328e:	73 0d                	jae    f010329d <debuginfo_eip+0x1ff>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103290:	81 c2 45 bc 10 f0    	add    $0xf010bc45,%edx
f0103296:	89 16                	mov    %edx,(%esi)
f0103298:	eb 03                	jmp    f010329d <debuginfo_eip+0x1ff>
f010329a:	8b 75 0c             	mov    0xc(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010329d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01032a2:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01032a5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01032a8:	39 cf                	cmp    %ecx,%edi
f01032aa:	7d 4e                	jge    f01032fa <debuginfo_eip+0x25c>
		for (lline = lfun + 1;
f01032ac:	83 c7 01             	add    $0x1,%edi
f01032af:	89 f8                	mov    %edi,%eax
f01032b1:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f01032b4:	c7 c2 84 52 10 f0    	mov    $0xf0105284,%edx
f01032ba:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f01032be:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01032c1:	eb 04                	jmp    f01032c7 <debuginfo_eip+0x229>
			info->eip_fn_narg++;
f01032c3:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01032c7:	39 c3                	cmp    %eax,%ebx
f01032c9:	7e 2a                	jle    f01032f5 <debuginfo_eip+0x257>
f01032cb:	0f b6 0a             	movzbl (%edx),%ecx
f01032ce:	83 c0 01             	add    $0x1,%eax
f01032d1:	83 c2 0c             	add    $0xc,%edx
f01032d4:	80 f9 a0             	cmp    $0xa0,%cl
f01032d7:	74 ea                	je     f01032c3 <debuginfo_eip+0x225>
	return 0;
f01032d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01032de:	eb 1a                	jmp    f01032fa <debuginfo_eip+0x25c>
		return -1;
f01032e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01032e5:	eb 13                	jmp    f01032fa <debuginfo_eip+0x25c>
f01032e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01032ec:	eb 0c                	jmp    f01032fa <debuginfo_eip+0x25c>
		return -1;
f01032ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01032f3:	eb 05                	jmp    f01032fa <debuginfo_eip+0x25c>
	return 0;
f01032f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032fd:	5b                   	pop    %ebx
f01032fe:	5e                   	pop    %esi
f01032ff:	5f                   	pop    %edi
f0103300:	5d                   	pop    %ebp
f0103301:	c3                   	ret    

f0103302 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103302:	55                   	push   %ebp
f0103303:	89 e5                	mov    %esp,%ebp
f0103305:	57                   	push   %edi
f0103306:	56                   	push   %esi
f0103307:	53                   	push   %ebx
f0103308:	83 ec 2c             	sub    $0x2c,%esp
f010330b:	e8 f6 fb ff ff       	call   f0102f06 <__x86.get_pc_thunk.cx>
f0103310:	81 c1 fc 3f 01 00    	add    $0x13ffc,%ecx
f0103316:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103319:	89 c7                	mov    %eax,%edi
f010331b:	89 d6                	mov    %edx,%esi
f010331d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103320:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103323:	89 d1                	mov    %edx,%ecx
f0103325:	89 c2                	mov    %eax,%edx
f0103327:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010332a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010332d:	8b 45 10             	mov    0x10(%ebp),%eax
f0103330:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103333:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103336:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010333d:	39 c2                	cmp    %eax,%edx
f010333f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0103342:	72 41                	jb     f0103385 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103344:	83 ec 0c             	sub    $0xc,%esp
f0103347:	ff 75 18             	push   0x18(%ebp)
f010334a:	83 eb 01             	sub    $0x1,%ebx
f010334d:	53                   	push   %ebx
f010334e:	50                   	push   %eax
f010334f:	83 ec 08             	sub    $0x8,%esp
f0103352:	ff 75 e4             	push   -0x1c(%ebp)
f0103355:	ff 75 e0             	push   -0x20(%ebp)
f0103358:	ff 75 d4             	push   -0x2c(%ebp)
f010335b:	ff 75 d0             	push   -0x30(%ebp)
f010335e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103361:	e8 3a 0a 00 00       	call   f0103da0 <__udivdi3>
f0103366:	83 c4 18             	add    $0x18,%esp
f0103369:	52                   	push   %edx
f010336a:	50                   	push   %eax
f010336b:	89 f2                	mov    %esi,%edx
f010336d:	89 f8                	mov    %edi,%eax
f010336f:	e8 8e ff ff ff       	call   f0103302 <printnum>
f0103374:	83 c4 20             	add    $0x20,%esp
f0103377:	eb 13                	jmp    f010338c <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103379:	83 ec 08             	sub    $0x8,%esp
f010337c:	56                   	push   %esi
f010337d:	ff 75 18             	push   0x18(%ebp)
f0103380:	ff d7                	call   *%edi
f0103382:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103385:	83 eb 01             	sub    $0x1,%ebx
f0103388:	85 db                	test   %ebx,%ebx
f010338a:	7f ed                	jg     f0103379 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010338c:	83 ec 08             	sub    $0x8,%esp
f010338f:	56                   	push   %esi
f0103390:	83 ec 04             	sub    $0x4,%esp
f0103393:	ff 75 e4             	push   -0x1c(%ebp)
f0103396:	ff 75 e0             	push   -0x20(%ebp)
f0103399:	ff 75 d4             	push   -0x2c(%ebp)
f010339c:	ff 75 d0             	push   -0x30(%ebp)
f010339f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01033a2:	e8 19 0b 00 00       	call   f0103ec0 <__umoddi3>
f01033a7:	83 c4 14             	add    $0x14,%esp
f01033aa:	0f be 84 03 83 dd fe 	movsbl -0x1227d(%ebx,%eax,1),%eax
f01033b1:	ff 
f01033b2:	50                   	push   %eax
f01033b3:	ff d7                	call   *%edi
}
f01033b5:	83 c4 10             	add    $0x10,%esp
f01033b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033bb:	5b                   	pop    %ebx
f01033bc:	5e                   	pop    %esi
f01033bd:	5f                   	pop    %edi
f01033be:	5d                   	pop    %ebp
f01033bf:	c3                   	ret    

f01033c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01033c0:	55                   	push   %ebp
f01033c1:	89 e5                	mov    %esp,%ebp
f01033c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01033c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01033ca:	8b 10                	mov    (%eax),%edx
f01033cc:	3b 50 04             	cmp    0x4(%eax),%edx
f01033cf:	73 0a                	jae    f01033db <sprintputch+0x1b>
		*b->buf++ = ch;
f01033d1:	8d 4a 01             	lea    0x1(%edx),%ecx
f01033d4:	89 08                	mov    %ecx,(%eax)
f01033d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01033d9:	88 02                	mov    %al,(%edx)
}
f01033db:	5d                   	pop    %ebp
f01033dc:	c3                   	ret    

f01033dd <printfmt>:
{
f01033dd:	55                   	push   %ebp
f01033de:	89 e5                	mov    %esp,%ebp
f01033e0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01033e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01033e6:	50                   	push   %eax
f01033e7:	ff 75 10             	push   0x10(%ebp)
f01033ea:	ff 75 0c             	push   0xc(%ebp)
f01033ed:	ff 75 08             	push   0x8(%ebp)
f01033f0:	e8 05 00 00 00       	call   f01033fa <vprintfmt>
}
f01033f5:	83 c4 10             	add    $0x10,%esp
f01033f8:	c9                   	leave  
f01033f9:	c3                   	ret    

f01033fa <vprintfmt>:
{
f01033fa:	55                   	push   %ebp
f01033fb:	89 e5                	mov    %esp,%ebp
f01033fd:	57                   	push   %edi
f01033fe:	56                   	push   %esi
f01033ff:	53                   	push   %ebx
f0103400:	83 ec 3c             	sub    $0x3c,%esp
f0103403:	e8 6c d3 ff ff       	call   f0100774 <__x86.get_pc_thunk.ax>
f0103408:	05 04 3f 01 00       	add    $0x13f04,%eax
f010340d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103410:	8b 75 08             	mov    0x8(%ebp),%esi
f0103413:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103416:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103419:	8d 80 38 1d 00 00    	lea    0x1d38(%eax),%eax
f010341f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103422:	eb 0a                	jmp    f010342e <vprintfmt+0x34>
			putch(ch, putdat);
f0103424:	83 ec 08             	sub    $0x8,%esp
f0103427:	57                   	push   %edi
f0103428:	50                   	push   %eax
f0103429:	ff d6                	call   *%esi
f010342b:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010342e:	83 c3 01             	add    $0x1,%ebx
f0103431:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103435:	83 f8 25             	cmp    $0x25,%eax
f0103438:	74 0c                	je     f0103446 <vprintfmt+0x4c>
			if (ch == '\0')
f010343a:	85 c0                	test   %eax,%eax
f010343c:	75 e6                	jne    f0103424 <vprintfmt+0x2a>
}
f010343e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103441:	5b                   	pop    %ebx
f0103442:	5e                   	pop    %esi
f0103443:	5f                   	pop    %edi
f0103444:	5d                   	pop    %ebp
f0103445:	c3                   	ret    
		padc = ' ';
f0103446:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f010344a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0103451:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0103458:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f010345f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103464:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103467:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010346a:	8d 43 01             	lea    0x1(%ebx),%eax
f010346d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103470:	0f b6 13             	movzbl (%ebx),%edx
f0103473:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103476:	3c 55                	cmp    $0x55,%al
f0103478:	0f 87 fd 03 00 00    	ja     f010387b <.L20>
f010347e:	0f b6 c0             	movzbl %al,%eax
f0103481:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103484:	89 ce                	mov    %ecx,%esi
f0103486:	03 b4 81 10 de fe ff 	add    -0x121f0(%ecx,%eax,4),%esi
f010348d:	ff e6                	jmp    *%esi

f010348f <.L68>:
f010348f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0103492:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0103496:	eb d2                	jmp    f010346a <vprintfmt+0x70>

f0103498 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0103498:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010349b:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f010349f:	eb c9                	jmp    f010346a <vprintfmt+0x70>

f01034a1 <.L31>:
f01034a1:	0f b6 d2             	movzbl %dl,%edx
f01034a4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01034a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01034ac:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01034af:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01034b2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01034b6:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01034b9:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01034bc:	83 f9 09             	cmp    $0x9,%ecx
f01034bf:	77 58                	ja     f0103519 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01034c1:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01034c4:	eb e9                	jmp    f01034af <.L31+0xe>

f01034c6 <.L34>:
			precision = va_arg(ap, int);
f01034c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01034c9:	8b 00                	mov    (%eax),%eax
f01034cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01034ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01034d1:	8d 40 04             	lea    0x4(%eax),%eax
f01034d4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01034d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01034da:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01034de:	79 8a                	jns    f010346a <vprintfmt+0x70>
				width = precision, precision = -1;
f01034e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01034e6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01034ed:	e9 78 ff ff ff       	jmp    f010346a <vprintfmt+0x70>

f01034f2 <.L33>:
f01034f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01034f5:	85 d2                	test   %edx,%edx
f01034f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01034fc:	0f 49 c2             	cmovns %edx,%eax
f01034ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103502:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0103505:	e9 60 ff ff ff       	jmp    f010346a <vprintfmt+0x70>

f010350a <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f010350a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010350d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0103514:	e9 51 ff ff ff       	jmp    f010346a <vprintfmt+0x70>
f0103519:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010351c:	89 75 08             	mov    %esi,0x8(%ebp)
f010351f:	eb b9                	jmp    f01034da <.L34+0x14>

f0103521 <.L27>:
			lflag++;
f0103521:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103525:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0103528:	e9 3d ff ff ff       	jmp    f010346a <vprintfmt+0x70>

f010352d <.L30>:
			putch(va_arg(ap, int), putdat);
f010352d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103530:	8b 45 14             	mov    0x14(%ebp),%eax
f0103533:	8d 58 04             	lea    0x4(%eax),%ebx
f0103536:	83 ec 08             	sub    $0x8,%esp
f0103539:	57                   	push   %edi
f010353a:	ff 30                	push   (%eax)
f010353c:	ff d6                	call   *%esi
			break;
f010353e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103541:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0103544:	e9 c8 02 00 00       	jmp    f0103811 <.L25+0x45>

f0103549 <.L28>:
			err = va_arg(ap, int);
f0103549:	8b 75 08             	mov    0x8(%ebp),%esi
f010354c:	8b 45 14             	mov    0x14(%ebp),%eax
f010354f:	8d 58 04             	lea    0x4(%eax),%ebx
f0103552:	8b 10                	mov    (%eax),%edx
f0103554:	89 d0                	mov    %edx,%eax
f0103556:	f7 d8                	neg    %eax
f0103558:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010355b:	83 f8 06             	cmp    $0x6,%eax
f010355e:	7f 27                	jg     f0103587 <.L28+0x3e>
f0103560:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103563:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0103566:	85 d2                	test   %edx,%edx
f0103568:	74 1d                	je     f0103587 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f010356a:	52                   	push   %edx
f010356b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010356e:	8d 80 55 da fe ff    	lea    -0x125ab(%eax),%eax
f0103574:	50                   	push   %eax
f0103575:	57                   	push   %edi
f0103576:	56                   	push   %esi
f0103577:	e8 61 fe ff ff       	call   f01033dd <printfmt>
f010357c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010357f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0103582:	e9 8a 02 00 00       	jmp    f0103811 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0103587:	50                   	push   %eax
f0103588:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010358b:	8d 80 9b dd fe ff    	lea    -0x12265(%eax),%eax
f0103591:	50                   	push   %eax
f0103592:	57                   	push   %edi
f0103593:	56                   	push   %esi
f0103594:	e8 44 fe ff ff       	call   f01033dd <printfmt>
f0103599:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010359c:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010359f:	e9 6d 02 00 00       	jmp    f0103811 <.L25+0x45>

f01035a4 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01035a4:	8b 75 08             	mov    0x8(%ebp),%esi
f01035a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01035aa:	83 c0 04             	add    $0x4,%eax
f01035ad:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01035b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01035b3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01035b5:	85 d2                	test   %edx,%edx
f01035b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035ba:	8d 80 94 dd fe ff    	lea    -0x1226c(%eax),%eax
f01035c0:	0f 45 c2             	cmovne %edx,%eax
f01035c3:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01035c6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01035ca:	7e 06                	jle    f01035d2 <.L24+0x2e>
f01035cc:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01035d0:	75 0d                	jne    f01035df <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01035d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01035d5:	89 c3                	mov    %eax,%ebx
f01035d7:	03 45 d4             	add    -0x2c(%ebp),%eax
f01035da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01035dd:	eb 58                	jmp    f0103637 <.L24+0x93>
f01035df:	83 ec 08             	sub    $0x8,%esp
f01035e2:	ff 75 d8             	push   -0x28(%ebp)
f01035e5:	ff 75 c8             	push   -0x38(%ebp)
f01035e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01035eb:	e8 44 04 00 00       	call   f0103a34 <strnlen>
f01035f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01035f3:	29 c2                	sub    %eax,%edx
f01035f5:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01035f8:	83 c4 10             	add    $0x10,%esp
f01035fb:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01035fd:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0103601:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0103604:	eb 0f                	jmp    f0103615 <.L24+0x71>
					putch(padc, putdat);
f0103606:	83 ec 08             	sub    $0x8,%esp
f0103609:	57                   	push   %edi
f010360a:	ff 75 d4             	push   -0x2c(%ebp)
f010360d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010360f:	83 eb 01             	sub    $0x1,%ebx
f0103612:	83 c4 10             	add    $0x10,%esp
f0103615:	85 db                	test   %ebx,%ebx
f0103617:	7f ed                	jg     f0103606 <.L24+0x62>
f0103619:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010361c:	85 d2                	test   %edx,%edx
f010361e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103623:	0f 49 c2             	cmovns %edx,%eax
f0103626:	29 c2                	sub    %eax,%edx
f0103628:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010362b:	eb a5                	jmp    f01035d2 <.L24+0x2e>
					putch(ch, putdat);
f010362d:	83 ec 08             	sub    $0x8,%esp
f0103630:	57                   	push   %edi
f0103631:	52                   	push   %edx
f0103632:	ff d6                	call   *%esi
f0103634:	83 c4 10             	add    $0x10,%esp
f0103637:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010363a:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010363c:	83 c3 01             	add    $0x1,%ebx
f010363f:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103643:	0f be d0             	movsbl %al,%edx
f0103646:	85 d2                	test   %edx,%edx
f0103648:	74 4b                	je     f0103695 <.L24+0xf1>
f010364a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010364e:	78 06                	js     f0103656 <.L24+0xb2>
f0103650:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0103654:	78 1e                	js     f0103674 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0103656:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010365a:	74 d1                	je     f010362d <.L24+0x89>
f010365c:	0f be c0             	movsbl %al,%eax
f010365f:	83 e8 20             	sub    $0x20,%eax
f0103662:	83 f8 5e             	cmp    $0x5e,%eax
f0103665:	76 c6                	jbe    f010362d <.L24+0x89>
					putch('?', putdat);
f0103667:	83 ec 08             	sub    $0x8,%esp
f010366a:	57                   	push   %edi
f010366b:	6a 3f                	push   $0x3f
f010366d:	ff d6                	call   *%esi
f010366f:	83 c4 10             	add    $0x10,%esp
f0103672:	eb c3                	jmp    f0103637 <.L24+0x93>
f0103674:	89 cb                	mov    %ecx,%ebx
f0103676:	eb 0e                	jmp    f0103686 <.L24+0xe2>
				putch(' ', putdat);
f0103678:	83 ec 08             	sub    $0x8,%esp
f010367b:	57                   	push   %edi
f010367c:	6a 20                	push   $0x20
f010367e:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0103680:	83 eb 01             	sub    $0x1,%ebx
f0103683:	83 c4 10             	add    $0x10,%esp
f0103686:	85 db                	test   %ebx,%ebx
f0103688:	7f ee                	jg     f0103678 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010368a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010368d:	89 45 14             	mov    %eax,0x14(%ebp)
f0103690:	e9 7c 01 00 00       	jmp    f0103811 <.L25+0x45>
f0103695:	89 cb                	mov    %ecx,%ebx
f0103697:	eb ed                	jmp    f0103686 <.L24+0xe2>

f0103699 <.L29>:
	if (lflag >= 2)
f0103699:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010369c:	8b 75 08             	mov    0x8(%ebp),%esi
f010369f:	83 f9 01             	cmp    $0x1,%ecx
f01036a2:	7f 1b                	jg     f01036bf <.L29+0x26>
	else if (lflag)
f01036a4:	85 c9                	test   %ecx,%ecx
f01036a6:	74 63                	je     f010370b <.L29+0x72>
		return va_arg(*ap, long);
f01036a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01036ab:	8b 00                	mov    (%eax),%eax
f01036ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01036b0:	99                   	cltd   
f01036b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01036b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01036b7:	8d 40 04             	lea    0x4(%eax),%eax
f01036ba:	89 45 14             	mov    %eax,0x14(%ebp)
f01036bd:	eb 17                	jmp    f01036d6 <.L29+0x3d>
		return va_arg(*ap, long long);
f01036bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01036c2:	8b 50 04             	mov    0x4(%eax),%edx
f01036c5:	8b 00                	mov    (%eax),%eax
f01036c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01036ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01036cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01036d0:	8d 40 08             	lea    0x8(%eax),%eax
f01036d3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01036d6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01036d9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01036dc:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f01036e1:	85 db                	test   %ebx,%ebx
f01036e3:	0f 89 0e 01 00 00    	jns    f01037f7 <.L25+0x2b>
				putch('-', putdat);
f01036e9:	83 ec 08             	sub    $0x8,%esp
f01036ec:	57                   	push   %edi
f01036ed:	6a 2d                	push   $0x2d
f01036ef:	ff d6                	call   *%esi
				num = -(long long) num;
f01036f1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01036f4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01036f7:	f7 d9                	neg    %ecx
f01036f9:	83 d3 00             	adc    $0x0,%ebx
f01036fc:	f7 db                	neg    %ebx
f01036fe:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103701:	ba 0a 00 00 00       	mov    $0xa,%edx
f0103706:	e9 ec 00 00 00       	jmp    f01037f7 <.L25+0x2b>
		return va_arg(*ap, int);
f010370b:	8b 45 14             	mov    0x14(%ebp),%eax
f010370e:	8b 00                	mov    (%eax),%eax
f0103710:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103713:	99                   	cltd   
f0103714:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103717:	8b 45 14             	mov    0x14(%ebp),%eax
f010371a:	8d 40 04             	lea    0x4(%eax),%eax
f010371d:	89 45 14             	mov    %eax,0x14(%ebp)
f0103720:	eb b4                	jmp    f01036d6 <.L29+0x3d>

f0103722 <.L23>:
	if (lflag >= 2)
f0103722:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103725:	8b 75 08             	mov    0x8(%ebp),%esi
f0103728:	83 f9 01             	cmp    $0x1,%ecx
f010372b:	7f 1e                	jg     f010374b <.L23+0x29>
	else if (lflag)
f010372d:	85 c9                	test   %ecx,%ecx
f010372f:	74 32                	je     f0103763 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0103731:	8b 45 14             	mov    0x14(%ebp),%eax
f0103734:	8b 08                	mov    (%eax),%ecx
f0103736:	bb 00 00 00 00       	mov    $0x0,%ebx
f010373b:	8d 40 04             	lea    0x4(%eax),%eax
f010373e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103741:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0103746:	e9 ac 00 00 00       	jmp    f01037f7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010374b:	8b 45 14             	mov    0x14(%ebp),%eax
f010374e:	8b 08                	mov    (%eax),%ecx
f0103750:	8b 58 04             	mov    0x4(%eax),%ebx
f0103753:	8d 40 08             	lea    0x8(%eax),%eax
f0103756:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103759:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f010375e:	e9 94 00 00 00       	jmp    f01037f7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0103763:	8b 45 14             	mov    0x14(%ebp),%eax
f0103766:	8b 08                	mov    (%eax),%ecx
f0103768:	bb 00 00 00 00       	mov    $0x0,%ebx
f010376d:	8d 40 04             	lea    0x4(%eax),%eax
f0103770:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103773:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0103778:	eb 7d                	jmp    f01037f7 <.L25+0x2b>

f010377a <.L26>:
	if (lflag >= 2)
f010377a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010377d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103780:	83 f9 01             	cmp    $0x1,%ecx
f0103783:	7f 1b                	jg     f01037a0 <.L26+0x26>
	else if (lflag)
f0103785:	85 c9                	test   %ecx,%ecx
f0103787:	74 2c                	je     f01037b5 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f0103789:	8b 45 14             	mov    0x14(%ebp),%eax
f010378c:	8b 08                	mov    (%eax),%ecx
f010378e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103793:	8d 40 04             	lea    0x4(%eax),%eax
f0103796:	89 45 14             	mov    %eax,0x14(%ebp)
            base=8;
f0103799:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f010379e:	eb 57                	jmp    f01037f7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01037a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01037a3:	8b 08                	mov    (%eax),%ecx
f01037a5:	8b 58 04             	mov    0x4(%eax),%ebx
f01037a8:	8d 40 08             	lea    0x8(%eax),%eax
f01037ab:	89 45 14             	mov    %eax,0x14(%ebp)
            base=8;
f01037ae:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f01037b3:	eb 42                	jmp    f01037f7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01037b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01037b8:	8b 08                	mov    (%eax),%ecx
f01037ba:	bb 00 00 00 00       	mov    $0x0,%ebx
f01037bf:	8d 40 04             	lea    0x4(%eax),%eax
f01037c2:	89 45 14             	mov    %eax,0x14(%ebp)
            base=8;
f01037c5:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f01037ca:	eb 2b                	jmp    f01037f7 <.L25+0x2b>

f01037cc <.L25>:
			putch('0', putdat);
f01037cc:	8b 75 08             	mov    0x8(%ebp),%esi
f01037cf:	83 ec 08             	sub    $0x8,%esp
f01037d2:	57                   	push   %edi
f01037d3:	6a 30                	push   $0x30
f01037d5:	ff d6                	call   *%esi
			putch('x', putdat);
f01037d7:	83 c4 08             	add    $0x8,%esp
f01037da:	57                   	push   %edi
f01037db:	6a 78                	push   $0x78
f01037dd:	ff d6                	call   *%esi
			num = (unsigned long long)
f01037df:	8b 45 14             	mov    0x14(%ebp),%eax
f01037e2:	8b 08                	mov    (%eax),%ecx
f01037e4:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f01037e9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01037ec:	8d 40 04             	lea    0x4(%eax),%eax
f01037ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01037f2:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f01037f7:	83 ec 0c             	sub    $0xc,%esp
f01037fa:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01037fe:	50                   	push   %eax
f01037ff:	ff 75 d4             	push   -0x2c(%ebp)
f0103802:	52                   	push   %edx
f0103803:	53                   	push   %ebx
f0103804:	51                   	push   %ecx
f0103805:	89 fa                	mov    %edi,%edx
f0103807:	89 f0                	mov    %esi,%eax
f0103809:	e8 f4 fa ff ff       	call   f0103302 <printnum>
			break;
f010380e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0103811:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103814:	e9 15 fc ff ff       	jmp    f010342e <vprintfmt+0x34>

f0103819 <.L21>:
	if (lflag >= 2)
f0103819:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010381c:	8b 75 08             	mov    0x8(%ebp),%esi
f010381f:	83 f9 01             	cmp    $0x1,%ecx
f0103822:	7f 1b                	jg     f010383f <.L21+0x26>
	else if (lflag)
f0103824:	85 c9                	test   %ecx,%ecx
f0103826:	74 2c                	je     f0103854 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0103828:	8b 45 14             	mov    0x14(%ebp),%eax
f010382b:	8b 08                	mov    (%eax),%ecx
f010382d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103832:	8d 40 04             	lea    0x4(%eax),%eax
f0103835:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103838:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f010383d:	eb b8                	jmp    f01037f7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010383f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103842:	8b 08                	mov    (%eax),%ecx
f0103844:	8b 58 04             	mov    0x4(%eax),%ebx
f0103847:	8d 40 08             	lea    0x8(%eax),%eax
f010384a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010384d:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0103852:	eb a3                	jmp    f01037f7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0103854:	8b 45 14             	mov    0x14(%ebp),%eax
f0103857:	8b 08                	mov    (%eax),%ecx
f0103859:	bb 00 00 00 00       	mov    $0x0,%ebx
f010385e:	8d 40 04             	lea    0x4(%eax),%eax
f0103861:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103864:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0103869:	eb 8c                	jmp    f01037f7 <.L25+0x2b>

f010386b <.L35>:
			putch(ch, putdat);
f010386b:	8b 75 08             	mov    0x8(%ebp),%esi
f010386e:	83 ec 08             	sub    $0x8,%esp
f0103871:	57                   	push   %edi
f0103872:	6a 25                	push   $0x25
f0103874:	ff d6                	call   *%esi
			break;
f0103876:	83 c4 10             	add    $0x10,%esp
f0103879:	eb 96                	jmp    f0103811 <.L25+0x45>

f010387b <.L20>:
			putch('%', putdat);
f010387b:	8b 75 08             	mov    0x8(%ebp),%esi
f010387e:	83 ec 08             	sub    $0x8,%esp
f0103881:	57                   	push   %edi
f0103882:	6a 25                	push   $0x25
f0103884:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103886:	83 c4 10             	add    $0x10,%esp
f0103889:	89 d8                	mov    %ebx,%eax
f010388b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010388f:	74 05                	je     f0103896 <.L20+0x1b>
f0103891:	83 e8 01             	sub    $0x1,%eax
f0103894:	eb f5                	jmp    f010388b <.L20+0x10>
f0103896:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103899:	e9 73 ff ff ff       	jmp    f0103811 <.L25+0x45>

f010389e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010389e:	55                   	push   %ebp
f010389f:	89 e5                	mov    %esp,%ebp
f01038a1:	53                   	push   %ebx
f01038a2:	83 ec 14             	sub    $0x14,%esp
f01038a5:	e8 38 c9 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f01038aa:	81 c3 62 3a 01 00    	add    $0x13a62,%ebx
f01038b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01038b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01038b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01038b9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01038bd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01038c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01038c7:	85 c0                	test   %eax,%eax
f01038c9:	74 2b                	je     f01038f6 <vsnprintf+0x58>
f01038cb:	85 d2                	test   %edx,%edx
f01038cd:	7e 27                	jle    f01038f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01038cf:	ff 75 14             	push   0x14(%ebp)
f01038d2:	ff 75 10             	push   0x10(%ebp)
f01038d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01038d8:	50                   	push   %eax
f01038d9:	8d 83 b4 c0 fe ff    	lea    -0x13f4c(%ebx),%eax
f01038df:	50                   	push   %eax
f01038e0:	e8 15 fb ff ff       	call   f01033fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01038e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01038e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01038eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038ee:	83 c4 10             	add    $0x10,%esp
}
f01038f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038f4:	c9                   	leave  
f01038f5:	c3                   	ret    
		return -E_INVAL;
f01038f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01038fb:	eb f4                	jmp    f01038f1 <vsnprintf+0x53>

f01038fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01038fd:	55                   	push   %ebp
f01038fe:	89 e5                	mov    %esp,%ebp
f0103900:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103903:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103906:	50                   	push   %eax
f0103907:	ff 75 10             	push   0x10(%ebp)
f010390a:	ff 75 0c             	push   0xc(%ebp)
f010390d:	ff 75 08             	push   0x8(%ebp)
f0103910:	e8 89 ff ff ff       	call   f010389e <vsnprintf>
	va_end(ap);

	return rc;
}
f0103915:	c9                   	leave  
f0103916:	c3                   	ret    

f0103917 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103917:	55                   	push   %ebp
f0103918:	89 e5                	mov    %esp,%ebp
f010391a:	57                   	push   %edi
f010391b:	56                   	push   %esi
f010391c:	53                   	push   %ebx
f010391d:	83 ec 1c             	sub    $0x1c,%esp
f0103920:	e8 bd c8 ff ff       	call   f01001e2 <__x86.get_pc_thunk.bx>
f0103925:	81 c3 e7 39 01 00    	add    $0x139e7,%ebx
f010392b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010392e:	85 c0                	test   %eax,%eax
f0103930:	74 13                	je     f0103945 <readline+0x2e>
		cprintf("%s", prompt);
f0103932:	83 ec 08             	sub    $0x8,%esp
f0103935:	50                   	push   %eax
f0103936:	8d 83 55 da fe ff    	lea    -0x125ab(%ebx),%eax
f010393c:	50                   	push   %eax
f010393d:	e8 53 f6 ff ff       	call   f0102f95 <cprintf>
f0103942:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103945:	83 ec 0c             	sub    $0xc,%esp
f0103948:	6a 00                	push   $0x0
f010394a:	e8 1f ce ff ff       	call   f010076e <iscons>
f010394f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103952:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103955:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f010395a:	8d 83 d4 1f 00 00    	lea    0x1fd4(%ebx),%eax
f0103960:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103963:	eb 45                	jmp    f01039aa <readline+0x93>
			cprintf("read error: %e\n", c);
f0103965:	83 ec 08             	sub    $0x8,%esp
f0103968:	50                   	push   %eax
f0103969:	8d 83 68 df fe ff    	lea    -0x12098(%ebx),%eax
f010396f:	50                   	push   %eax
f0103970:	e8 20 f6 ff ff       	call   f0102f95 <cprintf>
			return NULL;
f0103975:	83 c4 10             	add    $0x10,%esp
f0103978:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010397d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103980:	5b                   	pop    %ebx
f0103981:	5e                   	pop    %esi
f0103982:	5f                   	pop    %edi
f0103983:	5d                   	pop    %ebp
f0103984:	c3                   	ret    
			if (echoing)
f0103985:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103989:	75 05                	jne    f0103990 <readline+0x79>
			i--;
f010398b:	83 ef 01             	sub    $0x1,%edi
f010398e:	eb 1a                	jmp    f01039aa <readline+0x93>
				cputchar('\b');
f0103990:	83 ec 0c             	sub    $0xc,%esp
f0103993:	6a 08                	push   $0x8
f0103995:	e8 b3 cd ff ff       	call   f010074d <cputchar>
f010399a:	83 c4 10             	add    $0x10,%esp
f010399d:	eb ec                	jmp    f010398b <readline+0x74>
			buf[i++] = c;
f010399f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01039a2:	89 f0                	mov    %esi,%eax
f01039a4:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01039a7:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01039aa:	e8 ae cd ff ff       	call   f010075d <getchar>
f01039af:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01039b1:	85 c0                	test   %eax,%eax
f01039b3:	78 b0                	js     f0103965 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01039b5:	83 f8 08             	cmp    $0x8,%eax
f01039b8:	0f 94 c0             	sete   %al
f01039bb:	83 fe 7f             	cmp    $0x7f,%esi
f01039be:	0f 94 c2             	sete   %dl
f01039c1:	08 d0                	or     %dl,%al
f01039c3:	74 04                	je     f01039c9 <readline+0xb2>
f01039c5:	85 ff                	test   %edi,%edi
f01039c7:	7f bc                	jg     f0103985 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01039c9:	83 fe 1f             	cmp    $0x1f,%esi
f01039cc:	7e 1c                	jle    f01039ea <readline+0xd3>
f01039ce:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01039d4:	7f 14                	jg     f01039ea <readline+0xd3>
			if (echoing)
f01039d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01039da:	74 c3                	je     f010399f <readline+0x88>
				cputchar(c);
f01039dc:	83 ec 0c             	sub    $0xc,%esp
f01039df:	56                   	push   %esi
f01039e0:	e8 68 cd ff ff       	call   f010074d <cputchar>
f01039e5:	83 c4 10             	add    $0x10,%esp
f01039e8:	eb b5                	jmp    f010399f <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f01039ea:	83 fe 0a             	cmp    $0xa,%esi
f01039ed:	74 05                	je     f01039f4 <readline+0xdd>
f01039ef:	83 fe 0d             	cmp    $0xd,%esi
f01039f2:	75 b6                	jne    f01039aa <readline+0x93>
			if (echoing)
f01039f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01039f8:	75 13                	jne    f0103a0d <readline+0xf6>
			buf[i] = 0;
f01039fa:	c6 84 3b d4 1f 00 00 	movb   $0x0,0x1fd4(%ebx,%edi,1)
f0103a01:	00 
			return buf;
f0103a02:	8d 83 d4 1f 00 00    	lea    0x1fd4(%ebx),%eax
f0103a08:	e9 70 ff ff ff       	jmp    f010397d <readline+0x66>
				cputchar('\n');
f0103a0d:	83 ec 0c             	sub    $0xc,%esp
f0103a10:	6a 0a                	push   $0xa
f0103a12:	e8 36 cd ff ff       	call   f010074d <cputchar>
f0103a17:	83 c4 10             	add    $0x10,%esp
f0103a1a:	eb de                	jmp    f01039fa <readline+0xe3>

f0103a1c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103a1c:	55                   	push   %ebp
f0103a1d:	89 e5                	mov    %esp,%ebp
f0103a1f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103a22:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a27:	eb 03                	jmp    f0103a2c <strlen+0x10>
		n++;
f0103a29:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103a2c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103a30:	75 f7                	jne    f0103a29 <strlen+0xd>
	return n;
}
f0103a32:	5d                   	pop    %ebp
f0103a33:	c3                   	ret    

f0103a34 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103a34:	55                   	push   %ebp
f0103a35:	89 e5                	mov    %esp,%ebp
f0103a37:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103a3d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a42:	eb 03                	jmp    f0103a47 <strnlen+0x13>
		n++;
f0103a44:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103a47:	39 d0                	cmp    %edx,%eax
f0103a49:	74 08                	je     f0103a53 <strnlen+0x1f>
f0103a4b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103a4f:	75 f3                	jne    f0103a44 <strnlen+0x10>
f0103a51:	89 c2                	mov    %eax,%edx
	return n;
}
f0103a53:	89 d0                	mov    %edx,%eax
f0103a55:	5d                   	pop    %ebp
f0103a56:	c3                   	ret    

f0103a57 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103a57:	55                   	push   %ebp
f0103a58:	89 e5                	mov    %esp,%ebp
f0103a5a:	53                   	push   %ebx
f0103a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103a5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103a61:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a66:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0103a6a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0103a6d:	83 c0 01             	add    $0x1,%eax
f0103a70:	84 d2                	test   %dl,%dl
f0103a72:	75 f2                	jne    f0103a66 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103a74:	89 c8                	mov    %ecx,%eax
f0103a76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a79:	c9                   	leave  
f0103a7a:	c3                   	ret    

f0103a7b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103a7b:	55                   	push   %ebp
f0103a7c:	89 e5                	mov    %esp,%ebp
f0103a7e:	53                   	push   %ebx
f0103a7f:	83 ec 10             	sub    $0x10,%esp
f0103a82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103a85:	53                   	push   %ebx
f0103a86:	e8 91 ff ff ff       	call   f0103a1c <strlen>
f0103a8b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103a8e:	ff 75 0c             	push   0xc(%ebp)
f0103a91:	01 d8                	add    %ebx,%eax
f0103a93:	50                   	push   %eax
f0103a94:	e8 be ff ff ff       	call   f0103a57 <strcpy>
	return dst;
}
f0103a99:	89 d8                	mov    %ebx,%eax
f0103a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a9e:	c9                   	leave  
f0103a9f:	c3                   	ret    

f0103aa0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103aa0:	55                   	push   %ebp
f0103aa1:	89 e5                	mov    %esp,%ebp
f0103aa3:	56                   	push   %esi
f0103aa4:	53                   	push   %ebx
f0103aa5:	8b 75 08             	mov    0x8(%ebp),%esi
f0103aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103aab:	89 f3                	mov    %esi,%ebx
f0103aad:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103ab0:	89 f0                	mov    %esi,%eax
f0103ab2:	eb 0f                	jmp    f0103ac3 <strncpy+0x23>
		*dst++ = *src;
f0103ab4:	83 c0 01             	add    $0x1,%eax
f0103ab7:	0f b6 0a             	movzbl (%edx),%ecx
f0103aba:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103abd:	80 f9 01             	cmp    $0x1,%cl
f0103ac0:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0103ac3:	39 d8                	cmp    %ebx,%eax
f0103ac5:	75 ed                	jne    f0103ab4 <strncpy+0x14>
	}
	return ret;
}
f0103ac7:	89 f0                	mov    %esi,%eax
f0103ac9:	5b                   	pop    %ebx
f0103aca:	5e                   	pop    %esi
f0103acb:	5d                   	pop    %ebp
f0103acc:	c3                   	ret    

f0103acd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103acd:	55                   	push   %ebp
f0103ace:	89 e5                	mov    %esp,%ebp
f0103ad0:	56                   	push   %esi
f0103ad1:	53                   	push   %ebx
f0103ad2:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103ad8:	8b 55 10             	mov    0x10(%ebp),%edx
f0103adb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103add:	85 d2                	test   %edx,%edx
f0103adf:	74 21                	je     f0103b02 <strlcpy+0x35>
f0103ae1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103ae5:	89 f2                	mov    %esi,%edx
f0103ae7:	eb 09                	jmp    f0103af2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103ae9:	83 c1 01             	add    $0x1,%ecx
f0103aec:	83 c2 01             	add    $0x1,%edx
f0103aef:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0103af2:	39 c2                	cmp    %eax,%edx
f0103af4:	74 09                	je     f0103aff <strlcpy+0x32>
f0103af6:	0f b6 19             	movzbl (%ecx),%ebx
f0103af9:	84 db                	test   %bl,%bl
f0103afb:	75 ec                	jne    f0103ae9 <strlcpy+0x1c>
f0103afd:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0103aff:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103b02:	29 f0                	sub    %esi,%eax
}
f0103b04:	5b                   	pop    %ebx
f0103b05:	5e                   	pop    %esi
f0103b06:	5d                   	pop    %ebp
f0103b07:	c3                   	ret    

f0103b08 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103b08:	55                   	push   %ebp
f0103b09:	89 e5                	mov    %esp,%ebp
f0103b0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103b11:	eb 06                	jmp    f0103b19 <strcmp+0x11>
		p++, q++;
f0103b13:	83 c1 01             	add    $0x1,%ecx
f0103b16:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103b19:	0f b6 01             	movzbl (%ecx),%eax
f0103b1c:	84 c0                	test   %al,%al
f0103b1e:	74 04                	je     f0103b24 <strcmp+0x1c>
f0103b20:	3a 02                	cmp    (%edx),%al
f0103b22:	74 ef                	je     f0103b13 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103b24:	0f b6 c0             	movzbl %al,%eax
f0103b27:	0f b6 12             	movzbl (%edx),%edx
f0103b2a:	29 d0                	sub    %edx,%eax
}
f0103b2c:	5d                   	pop    %ebp
f0103b2d:	c3                   	ret    

f0103b2e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103b2e:	55                   	push   %ebp
f0103b2f:	89 e5                	mov    %esp,%ebp
f0103b31:	53                   	push   %ebx
f0103b32:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b35:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b38:	89 c3                	mov    %eax,%ebx
f0103b3a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103b3d:	eb 06                	jmp    f0103b45 <strncmp+0x17>
		n--, p++, q++;
f0103b3f:	83 c0 01             	add    $0x1,%eax
f0103b42:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103b45:	39 d8                	cmp    %ebx,%eax
f0103b47:	74 18                	je     f0103b61 <strncmp+0x33>
f0103b49:	0f b6 08             	movzbl (%eax),%ecx
f0103b4c:	84 c9                	test   %cl,%cl
f0103b4e:	74 04                	je     f0103b54 <strncmp+0x26>
f0103b50:	3a 0a                	cmp    (%edx),%cl
f0103b52:	74 eb                	je     f0103b3f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103b54:	0f b6 00             	movzbl (%eax),%eax
f0103b57:	0f b6 12             	movzbl (%edx),%edx
f0103b5a:	29 d0                	sub    %edx,%eax
}
f0103b5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b5f:	c9                   	leave  
f0103b60:	c3                   	ret    
		return 0;
f0103b61:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b66:	eb f4                	jmp    f0103b5c <strncmp+0x2e>

f0103b68 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103b68:	55                   	push   %ebp
f0103b69:	89 e5                	mov    %esp,%ebp
f0103b6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b6e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103b72:	eb 03                	jmp    f0103b77 <strchr+0xf>
f0103b74:	83 c0 01             	add    $0x1,%eax
f0103b77:	0f b6 10             	movzbl (%eax),%edx
f0103b7a:	84 d2                	test   %dl,%dl
f0103b7c:	74 06                	je     f0103b84 <strchr+0x1c>
		if (*s == c)
f0103b7e:	38 ca                	cmp    %cl,%dl
f0103b80:	75 f2                	jne    f0103b74 <strchr+0xc>
f0103b82:	eb 05                	jmp    f0103b89 <strchr+0x21>
			return (char *) s;
	return 0;
f0103b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b89:	5d                   	pop    %ebp
f0103b8a:	c3                   	ret    

f0103b8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103b8b:	55                   	push   %ebp
f0103b8c:	89 e5                	mov    %esp,%ebp
f0103b8e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103b95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103b98:	38 ca                	cmp    %cl,%dl
f0103b9a:	74 09                	je     f0103ba5 <strfind+0x1a>
f0103b9c:	84 d2                	test   %dl,%dl
f0103b9e:	74 05                	je     f0103ba5 <strfind+0x1a>
	for (; *s; s++)
f0103ba0:	83 c0 01             	add    $0x1,%eax
f0103ba3:	eb f0                	jmp    f0103b95 <strfind+0xa>
			break;
	return (char *) s;
}
f0103ba5:	5d                   	pop    %ebp
f0103ba6:	c3                   	ret    

f0103ba7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103ba7:	55                   	push   %ebp
f0103ba8:	89 e5                	mov    %esp,%ebp
f0103baa:	57                   	push   %edi
f0103bab:	56                   	push   %esi
f0103bac:	53                   	push   %ebx
f0103bad:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103bb0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103bb3:	85 c9                	test   %ecx,%ecx
f0103bb5:	74 2f                	je     f0103be6 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103bb7:	89 f8                	mov    %edi,%eax
f0103bb9:	09 c8                	or     %ecx,%eax
f0103bbb:	a8 03                	test   $0x3,%al
f0103bbd:	75 21                	jne    f0103be0 <memset+0x39>
		c &= 0xFF;
f0103bbf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103bc3:	89 d0                	mov    %edx,%eax
f0103bc5:	c1 e0 08             	shl    $0x8,%eax
f0103bc8:	89 d3                	mov    %edx,%ebx
f0103bca:	c1 e3 18             	shl    $0x18,%ebx
f0103bcd:	89 d6                	mov    %edx,%esi
f0103bcf:	c1 e6 10             	shl    $0x10,%esi
f0103bd2:	09 f3                	or     %esi,%ebx
f0103bd4:	09 da                	or     %ebx,%edx
f0103bd6:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103bd8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103bdb:	fc                   	cld    
f0103bdc:	f3 ab                	rep stos %eax,%es:(%edi)
f0103bde:	eb 06                	jmp    f0103be6 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103be0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103be3:	fc                   	cld    
f0103be4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103be6:	89 f8                	mov    %edi,%eax
f0103be8:	5b                   	pop    %ebx
f0103be9:	5e                   	pop    %esi
f0103bea:	5f                   	pop    %edi
f0103beb:	5d                   	pop    %ebp
f0103bec:	c3                   	ret    

f0103bed <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103bed:	55                   	push   %ebp
f0103bee:	89 e5                	mov    %esp,%ebp
f0103bf0:	57                   	push   %edi
f0103bf1:	56                   	push   %esi
f0103bf2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bf5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103bf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103bfb:	39 c6                	cmp    %eax,%esi
f0103bfd:	73 32                	jae    f0103c31 <memmove+0x44>
f0103bff:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103c02:	39 c2                	cmp    %eax,%edx
f0103c04:	76 2b                	jbe    f0103c31 <memmove+0x44>
		s += n;
		d += n;
f0103c06:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103c09:	89 d6                	mov    %edx,%esi
f0103c0b:	09 fe                	or     %edi,%esi
f0103c0d:	09 ce                	or     %ecx,%esi
f0103c0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103c15:	75 0e                	jne    f0103c25 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103c17:	83 ef 04             	sub    $0x4,%edi
f0103c1a:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103c1d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103c20:	fd                   	std    
f0103c21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103c23:	eb 09                	jmp    f0103c2e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103c25:	83 ef 01             	sub    $0x1,%edi
f0103c28:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103c2b:	fd                   	std    
f0103c2c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103c2e:	fc                   	cld    
f0103c2f:	eb 1a                	jmp    f0103c4b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103c31:	89 f2                	mov    %esi,%edx
f0103c33:	09 c2                	or     %eax,%edx
f0103c35:	09 ca                	or     %ecx,%edx
f0103c37:	f6 c2 03             	test   $0x3,%dl
f0103c3a:	75 0a                	jne    f0103c46 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103c3c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103c3f:	89 c7                	mov    %eax,%edi
f0103c41:	fc                   	cld    
f0103c42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103c44:	eb 05                	jmp    f0103c4b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0103c46:	89 c7                	mov    %eax,%edi
f0103c48:	fc                   	cld    
f0103c49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103c4b:	5e                   	pop    %esi
f0103c4c:	5f                   	pop    %edi
f0103c4d:	5d                   	pop    %ebp
f0103c4e:	c3                   	ret    

f0103c4f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103c4f:	55                   	push   %ebp
f0103c50:	89 e5                	mov    %esp,%ebp
f0103c52:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103c55:	ff 75 10             	push   0x10(%ebp)
f0103c58:	ff 75 0c             	push   0xc(%ebp)
f0103c5b:	ff 75 08             	push   0x8(%ebp)
f0103c5e:	e8 8a ff ff ff       	call   f0103bed <memmove>
}
f0103c63:	c9                   	leave  
f0103c64:	c3                   	ret    

f0103c65 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103c65:	55                   	push   %ebp
f0103c66:	89 e5                	mov    %esp,%ebp
f0103c68:	56                   	push   %esi
f0103c69:	53                   	push   %ebx
f0103c6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c6d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c70:	89 c6                	mov    %eax,%esi
f0103c72:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103c75:	eb 06                	jmp    f0103c7d <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103c77:	83 c0 01             	add    $0x1,%eax
f0103c7a:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0103c7d:	39 f0                	cmp    %esi,%eax
f0103c7f:	74 14                	je     f0103c95 <memcmp+0x30>
		if (*s1 != *s2)
f0103c81:	0f b6 08             	movzbl (%eax),%ecx
f0103c84:	0f b6 1a             	movzbl (%edx),%ebx
f0103c87:	38 d9                	cmp    %bl,%cl
f0103c89:	74 ec                	je     f0103c77 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0103c8b:	0f b6 c1             	movzbl %cl,%eax
f0103c8e:	0f b6 db             	movzbl %bl,%ebx
f0103c91:	29 d8                	sub    %ebx,%eax
f0103c93:	eb 05                	jmp    f0103c9a <memcmp+0x35>
	}

	return 0;
f0103c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c9a:	5b                   	pop    %ebx
f0103c9b:	5e                   	pop    %esi
f0103c9c:	5d                   	pop    %ebp
f0103c9d:	c3                   	ret    

f0103c9e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103c9e:	55                   	push   %ebp
f0103c9f:	89 e5                	mov    %esp,%ebp
f0103ca1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103ca7:	89 c2                	mov    %eax,%edx
f0103ca9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103cac:	eb 03                	jmp    f0103cb1 <memfind+0x13>
f0103cae:	83 c0 01             	add    $0x1,%eax
f0103cb1:	39 d0                	cmp    %edx,%eax
f0103cb3:	73 04                	jae    f0103cb9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103cb5:	38 08                	cmp    %cl,(%eax)
f0103cb7:	75 f5                	jne    f0103cae <memfind+0x10>
			break;
	return (void *) s;
}
f0103cb9:	5d                   	pop    %ebp
f0103cba:	c3                   	ret    

f0103cbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103cbb:	55                   	push   %ebp
f0103cbc:	89 e5                	mov    %esp,%ebp
f0103cbe:	57                   	push   %edi
f0103cbf:	56                   	push   %esi
f0103cc0:	53                   	push   %ebx
f0103cc1:	8b 55 08             	mov    0x8(%ebp),%edx
f0103cc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103cc7:	eb 03                	jmp    f0103ccc <strtol+0x11>
		s++;
f0103cc9:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0103ccc:	0f b6 02             	movzbl (%edx),%eax
f0103ccf:	3c 20                	cmp    $0x20,%al
f0103cd1:	74 f6                	je     f0103cc9 <strtol+0xe>
f0103cd3:	3c 09                	cmp    $0x9,%al
f0103cd5:	74 f2                	je     f0103cc9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103cd7:	3c 2b                	cmp    $0x2b,%al
f0103cd9:	74 2a                	je     f0103d05 <strtol+0x4a>
	int neg = 0;
f0103cdb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103ce0:	3c 2d                	cmp    $0x2d,%al
f0103ce2:	74 2b                	je     f0103d0f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103ce4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103cea:	75 0f                	jne    f0103cfb <strtol+0x40>
f0103cec:	80 3a 30             	cmpb   $0x30,(%edx)
f0103cef:	74 28                	je     f0103d19 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103cf1:	85 db                	test   %ebx,%ebx
f0103cf3:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103cf8:	0f 44 d8             	cmove  %eax,%ebx
f0103cfb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d00:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103d03:	eb 46                	jmp    f0103d4b <strtol+0x90>
		s++;
f0103d05:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0103d08:	bf 00 00 00 00       	mov    $0x0,%edi
f0103d0d:	eb d5                	jmp    f0103ce4 <strtol+0x29>
		s++, neg = 1;
f0103d0f:	83 c2 01             	add    $0x1,%edx
f0103d12:	bf 01 00 00 00       	mov    $0x1,%edi
f0103d17:	eb cb                	jmp    f0103ce4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103d19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103d1d:	74 0e                	je     f0103d2d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0103d1f:	85 db                	test   %ebx,%ebx
f0103d21:	75 d8                	jne    f0103cfb <strtol+0x40>
		s++, base = 8;
f0103d23:	83 c2 01             	add    $0x1,%edx
f0103d26:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103d2b:	eb ce                	jmp    f0103cfb <strtol+0x40>
		s += 2, base = 16;
f0103d2d:	83 c2 02             	add    $0x2,%edx
f0103d30:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103d35:	eb c4                	jmp    f0103cfb <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0103d37:	0f be c0             	movsbl %al,%eax
f0103d3a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103d3d:	3b 45 10             	cmp    0x10(%ebp),%eax
f0103d40:	7d 3a                	jge    f0103d7c <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0103d42:	83 c2 01             	add    $0x1,%edx
f0103d45:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0103d49:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0103d4b:	0f b6 02             	movzbl (%edx),%eax
f0103d4e:	8d 70 d0             	lea    -0x30(%eax),%esi
f0103d51:	89 f3                	mov    %esi,%ebx
f0103d53:	80 fb 09             	cmp    $0x9,%bl
f0103d56:	76 df                	jbe    f0103d37 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0103d58:	8d 70 9f             	lea    -0x61(%eax),%esi
f0103d5b:	89 f3                	mov    %esi,%ebx
f0103d5d:	80 fb 19             	cmp    $0x19,%bl
f0103d60:	77 08                	ja     f0103d6a <strtol+0xaf>
			dig = *s - 'a' + 10;
f0103d62:	0f be c0             	movsbl %al,%eax
f0103d65:	83 e8 57             	sub    $0x57,%eax
f0103d68:	eb d3                	jmp    f0103d3d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0103d6a:	8d 70 bf             	lea    -0x41(%eax),%esi
f0103d6d:	89 f3                	mov    %esi,%ebx
f0103d6f:	80 fb 19             	cmp    $0x19,%bl
f0103d72:	77 08                	ja     f0103d7c <strtol+0xc1>
			dig = *s - 'A' + 10;
f0103d74:	0f be c0             	movsbl %al,%eax
f0103d77:	83 e8 37             	sub    $0x37,%eax
f0103d7a:	eb c1                	jmp    f0103d3d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103d7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103d80:	74 05                	je     f0103d87 <strtol+0xcc>
		*endptr = (char *) s;
f0103d82:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d85:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0103d87:	89 c8                	mov    %ecx,%eax
f0103d89:	f7 d8                	neg    %eax
f0103d8b:	85 ff                	test   %edi,%edi
f0103d8d:	0f 45 c8             	cmovne %eax,%ecx
}
f0103d90:	89 c8                	mov    %ecx,%eax
f0103d92:	5b                   	pop    %ebx
f0103d93:	5e                   	pop    %esi
f0103d94:	5f                   	pop    %edi
f0103d95:	5d                   	pop    %ebp
f0103d96:	c3                   	ret    
f0103d97:	66 90                	xchg   %ax,%ax
f0103d99:	66 90                	xchg   %ax,%ax
f0103d9b:	66 90                	xchg   %ax,%ax
f0103d9d:	66 90                	xchg   %ax,%ax
f0103d9f:	90                   	nop

f0103da0 <__udivdi3>:
f0103da0:	f3 0f 1e fb          	endbr32 
f0103da4:	55                   	push   %ebp
f0103da5:	57                   	push   %edi
f0103da6:	56                   	push   %esi
f0103da7:	53                   	push   %ebx
f0103da8:	83 ec 1c             	sub    $0x1c,%esp
f0103dab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0103daf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103db3:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103db7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103dbb:	85 c0                	test   %eax,%eax
f0103dbd:	75 19                	jne    f0103dd8 <__udivdi3+0x38>
f0103dbf:	39 f3                	cmp    %esi,%ebx
f0103dc1:	76 4d                	jbe    f0103e10 <__udivdi3+0x70>
f0103dc3:	31 ff                	xor    %edi,%edi
f0103dc5:	89 e8                	mov    %ebp,%eax
f0103dc7:	89 f2                	mov    %esi,%edx
f0103dc9:	f7 f3                	div    %ebx
f0103dcb:	89 fa                	mov    %edi,%edx
f0103dcd:	83 c4 1c             	add    $0x1c,%esp
f0103dd0:	5b                   	pop    %ebx
f0103dd1:	5e                   	pop    %esi
f0103dd2:	5f                   	pop    %edi
f0103dd3:	5d                   	pop    %ebp
f0103dd4:	c3                   	ret    
f0103dd5:	8d 76 00             	lea    0x0(%esi),%esi
f0103dd8:	39 f0                	cmp    %esi,%eax
f0103dda:	76 14                	jbe    f0103df0 <__udivdi3+0x50>
f0103ddc:	31 ff                	xor    %edi,%edi
f0103dde:	31 c0                	xor    %eax,%eax
f0103de0:	89 fa                	mov    %edi,%edx
f0103de2:	83 c4 1c             	add    $0x1c,%esp
f0103de5:	5b                   	pop    %ebx
f0103de6:	5e                   	pop    %esi
f0103de7:	5f                   	pop    %edi
f0103de8:	5d                   	pop    %ebp
f0103de9:	c3                   	ret    
f0103dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103df0:	0f bd f8             	bsr    %eax,%edi
f0103df3:	83 f7 1f             	xor    $0x1f,%edi
f0103df6:	75 48                	jne    f0103e40 <__udivdi3+0xa0>
f0103df8:	39 f0                	cmp    %esi,%eax
f0103dfa:	72 06                	jb     f0103e02 <__udivdi3+0x62>
f0103dfc:	31 c0                	xor    %eax,%eax
f0103dfe:	39 eb                	cmp    %ebp,%ebx
f0103e00:	77 de                	ja     f0103de0 <__udivdi3+0x40>
f0103e02:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e07:	eb d7                	jmp    f0103de0 <__udivdi3+0x40>
f0103e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103e10:	89 d9                	mov    %ebx,%ecx
f0103e12:	85 db                	test   %ebx,%ebx
f0103e14:	75 0b                	jne    f0103e21 <__udivdi3+0x81>
f0103e16:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e1b:	31 d2                	xor    %edx,%edx
f0103e1d:	f7 f3                	div    %ebx
f0103e1f:	89 c1                	mov    %eax,%ecx
f0103e21:	31 d2                	xor    %edx,%edx
f0103e23:	89 f0                	mov    %esi,%eax
f0103e25:	f7 f1                	div    %ecx
f0103e27:	89 c6                	mov    %eax,%esi
f0103e29:	89 e8                	mov    %ebp,%eax
f0103e2b:	89 f7                	mov    %esi,%edi
f0103e2d:	f7 f1                	div    %ecx
f0103e2f:	89 fa                	mov    %edi,%edx
f0103e31:	83 c4 1c             	add    $0x1c,%esp
f0103e34:	5b                   	pop    %ebx
f0103e35:	5e                   	pop    %esi
f0103e36:	5f                   	pop    %edi
f0103e37:	5d                   	pop    %ebp
f0103e38:	c3                   	ret    
f0103e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103e40:	89 f9                	mov    %edi,%ecx
f0103e42:	ba 20 00 00 00       	mov    $0x20,%edx
f0103e47:	29 fa                	sub    %edi,%edx
f0103e49:	d3 e0                	shl    %cl,%eax
f0103e4b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e4f:	89 d1                	mov    %edx,%ecx
f0103e51:	89 d8                	mov    %ebx,%eax
f0103e53:	d3 e8                	shr    %cl,%eax
f0103e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103e59:	09 c1                	or     %eax,%ecx
f0103e5b:	89 f0                	mov    %esi,%eax
f0103e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103e61:	89 f9                	mov    %edi,%ecx
f0103e63:	d3 e3                	shl    %cl,%ebx
f0103e65:	89 d1                	mov    %edx,%ecx
f0103e67:	d3 e8                	shr    %cl,%eax
f0103e69:	89 f9                	mov    %edi,%ecx
f0103e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103e6f:	89 eb                	mov    %ebp,%ebx
f0103e71:	d3 e6                	shl    %cl,%esi
f0103e73:	89 d1                	mov    %edx,%ecx
f0103e75:	d3 eb                	shr    %cl,%ebx
f0103e77:	09 f3                	or     %esi,%ebx
f0103e79:	89 c6                	mov    %eax,%esi
f0103e7b:	89 f2                	mov    %esi,%edx
f0103e7d:	89 d8                	mov    %ebx,%eax
f0103e7f:	f7 74 24 08          	divl   0x8(%esp)
f0103e83:	89 d6                	mov    %edx,%esi
f0103e85:	89 c3                	mov    %eax,%ebx
f0103e87:	f7 64 24 0c          	mull   0xc(%esp)
f0103e8b:	39 d6                	cmp    %edx,%esi
f0103e8d:	72 19                	jb     f0103ea8 <__udivdi3+0x108>
f0103e8f:	89 f9                	mov    %edi,%ecx
f0103e91:	d3 e5                	shl    %cl,%ebp
f0103e93:	39 c5                	cmp    %eax,%ebp
f0103e95:	73 04                	jae    f0103e9b <__udivdi3+0xfb>
f0103e97:	39 d6                	cmp    %edx,%esi
f0103e99:	74 0d                	je     f0103ea8 <__udivdi3+0x108>
f0103e9b:	89 d8                	mov    %ebx,%eax
f0103e9d:	31 ff                	xor    %edi,%edi
f0103e9f:	e9 3c ff ff ff       	jmp    f0103de0 <__udivdi3+0x40>
f0103ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103ea8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103eab:	31 ff                	xor    %edi,%edi
f0103ead:	e9 2e ff ff ff       	jmp    f0103de0 <__udivdi3+0x40>
f0103eb2:	66 90                	xchg   %ax,%ax
f0103eb4:	66 90                	xchg   %ax,%ax
f0103eb6:	66 90                	xchg   %ax,%ax
f0103eb8:	66 90                	xchg   %ax,%ax
f0103eba:	66 90                	xchg   %ax,%ax
f0103ebc:	66 90                	xchg   %ax,%ax
f0103ebe:	66 90                	xchg   %ax,%ax

f0103ec0 <__umoddi3>:
f0103ec0:	f3 0f 1e fb          	endbr32 
f0103ec4:	55                   	push   %ebp
f0103ec5:	57                   	push   %edi
f0103ec6:	56                   	push   %esi
f0103ec7:	53                   	push   %ebx
f0103ec8:	83 ec 1c             	sub    $0x1c,%esp
f0103ecb:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103ecf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103ed3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0103ed7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0103edb:	89 f0                	mov    %esi,%eax
f0103edd:	89 da                	mov    %ebx,%edx
f0103edf:	85 ff                	test   %edi,%edi
f0103ee1:	75 15                	jne    f0103ef8 <__umoddi3+0x38>
f0103ee3:	39 dd                	cmp    %ebx,%ebp
f0103ee5:	76 39                	jbe    f0103f20 <__umoddi3+0x60>
f0103ee7:	f7 f5                	div    %ebp
f0103ee9:	89 d0                	mov    %edx,%eax
f0103eeb:	31 d2                	xor    %edx,%edx
f0103eed:	83 c4 1c             	add    $0x1c,%esp
f0103ef0:	5b                   	pop    %ebx
f0103ef1:	5e                   	pop    %esi
f0103ef2:	5f                   	pop    %edi
f0103ef3:	5d                   	pop    %ebp
f0103ef4:	c3                   	ret    
f0103ef5:	8d 76 00             	lea    0x0(%esi),%esi
f0103ef8:	39 df                	cmp    %ebx,%edi
f0103efa:	77 f1                	ja     f0103eed <__umoddi3+0x2d>
f0103efc:	0f bd cf             	bsr    %edi,%ecx
f0103eff:	83 f1 1f             	xor    $0x1f,%ecx
f0103f02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103f06:	75 40                	jne    f0103f48 <__umoddi3+0x88>
f0103f08:	39 df                	cmp    %ebx,%edi
f0103f0a:	72 04                	jb     f0103f10 <__umoddi3+0x50>
f0103f0c:	39 f5                	cmp    %esi,%ebp
f0103f0e:	77 dd                	ja     f0103eed <__umoddi3+0x2d>
f0103f10:	89 da                	mov    %ebx,%edx
f0103f12:	89 f0                	mov    %esi,%eax
f0103f14:	29 e8                	sub    %ebp,%eax
f0103f16:	19 fa                	sbb    %edi,%edx
f0103f18:	eb d3                	jmp    f0103eed <__umoddi3+0x2d>
f0103f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f20:	89 e9                	mov    %ebp,%ecx
f0103f22:	85 ed                	test   %ebp,%ebp
f0103f24:	75 0b                	jne    f0103f31 <__umoddi3+0x71>
f0103f26:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f2b:	31 d2                	xor    %edx,%edx
f0103f2d:	f7 f5                	div    %ebp
f0103f2f:	89 c1                	mov    %eax,%ecx
f0103f31:	89 d8                	mov    %ebx,%eax
f0103f33:	31 d2                	xor    %edx,%edx
f0103f35:	f7 f1                	div    %ecx
f0103f37:	89 f0                	mov    %esi,%eax
f0103f39:	f7 f1                	div    %ecx
f0103f3b:	89 d0                	mov    %edx,%eax
f0103f3d:	31 d2                	xor    %edx,%edx
f0103f3f:	eb ac                	jmp    f0103eed <__umoddi3+0x2d>
f0103f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103f48:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103f4c:	ba 20 00 00 00       	mov    $0x20,%edx
f0103f51:	29 c2                	sub    %eax,%edx
f0103f53:	89 c1                	mov    %eax,%ecx
f0103f55:	89 e8                	mov    %ebp,%eax
f0103f57:	d3 e7                	shl    %cl,%edi
f0103f59:	89 d1                	mov    %edx,%ecx
f0103f5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103f5f:	d3 e8                	shr    %cl,%eax
f0103f61:	89 c1                	mov    %eax,%ecx
f0103f63:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103f67:	09 f9                	or     %edi,%ecx
f0103f69:	89 df                	mov    %ebx,%edi
f0103f6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103f6f:	89 c1                	mov    %eax,%ecx
f0103f71:	d3 e5                	shl    %cl,%ebp
f0103f73:	89 d1                	mov    %edx,%ecx
f0103f75:	d3 ef                	shr    %cl,%edi
f0103f77:	89 c1                	mov    %eax,%ecx
f0103f79:	89 f0                	mov    %esi,%eax
f0103f7b:	d3 e3                	shl    %cl,%ebx
f0103f7d:	89 d1                	mov    %edx,%ecx
f0103f7f:	89 fa                	mov    %edi,%edx
f0103f81:	d3 e8                	shr    %cl,%eax
f0103f83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f88:	09 d8                	or     %ebx,%eax
f0103f8a:	f7 74 24 08          	divl   0x8(%esp)
f0103f8e:	89 d3                	mov    %edx,%ebx
f0103f90:	d3 e6                	shl    %cl,%esi
f0103f92:	f7 e5                	mul    %ebp
f0103f94:	89 c7                	mov    %eax,%edi
f0103f96:	89 d1                	mov    %edx,%ecx
f0103f98:	39 d3                	cmp    %edx,%ebx
f0103f9a:	72 06                	jb     f0103fa2 <__umoddi3+0xe2>
f0103f9c:	75 0e                	jne    f0103fac <__umoddi3+0xec>
f0103f9e:	39 c6                	cmp    %eax,%esi
f0103fa0:	73 0a                	jae    f0103fac <__umoddi3+0xec>
f0103fa2:	29 e8                	sub    %ebp,%eax
f0103fa4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0103fa8:	89 d1                	mov    %edx,%ecx
f0103faa:	89 c7                	mov    %eax,%edi
f0103fac:	89 f5                	mov    %esi,%ebp
f0103fae:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103fb2:	29 fd                	sub    %edi,%ebp
f0103fb4:	19 cb                	sbb    %ecx,%ebx
f0103fb6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0103fbb:	89 d8                	mov    %ebx,%eax
f0103fbd:	d3 e0                	shl    %cl,%eax
f0103fbf:	89 f1                	mov    %esi,%ecx
f0103fc1:	d3 ed                	shr    %cl,%ebp
f0103fc3:	d3 eb                	shr    %cl,%ebx
f0103fc5:	09 e8                	or     %ebp,%eax
f0103fc7:	89 da                	mov    %ebx,%edx
f0103fc9:	83 c4 1c             	add    $0x1c,%esp
f0103fcc:	5b                   	pop    %ebx
f0103fcd:	5e                   	pop    %esi
f0103fce:	5f                   	pop    %edi
f0103fcf:	5d                   	pop    %ebp
f0103fd0:	c3                   	ret    
