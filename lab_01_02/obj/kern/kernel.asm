
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
#include <kern/kclock.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 8c 01 00 00       	call   f01001d6 <__x86.get_pc_thunk.bx>
f010004a:	81 c3 c2 72 01 00    	add    $0x172c2,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 b4 ce fe ff    	lea    -0x1314c(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 00 31 00 00       	call   f0103163 <cprintf>
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
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 d0 ce fe ff    	lea    -0x13130(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 da 30 00 00       	call   f0103163 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 07 08 00 00       	call   f01008a8 <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 24 01 00 00       	call   f01001d6 <__x86.get_pc_thunk.bx>
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
f01000ca:	e8 ad 3c 00 00       	call   f0103d7c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 58 05 00 00       	call   f010062c <cons_init>
    //cprintf("x=%d y=%d", 3);
    cprintf("x=%d y=%d z=%d", 3, 4);
f01000d4:	83 c4 0c             	add    $0xc,%esp
f01000d7:	6a 04                	push   $0x4
f01000d9:	6a 03                	push   $0x3
f01000db:	8d 83 eb ce fe ff    	lea    -0x13115(%ebx),%eax
f01000e1:	50                   	push   %eax
f01000e2:	e8 7c 30 00 00       	call   f0103163 <cprintf>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000e7:	83 c4 08             	add    $0x8,%esp
f01000ea:	68 ac 1a 00 00       	push   $0x1aac
f01000ef:	8d 83 fa ce fe ff    	lea    -0x13106(%ebx),%eax
f01000f5:	50                   	push   %eax
f01000f6:	e8 68 30 00 00       	call   f0103163 <cprintf>
    cprintf("\033[31;1;4mThe World is black and white! \033[0m\n");
f01000fb:	8d 83 48 cf fe ff    	lea    -0x130b8(%ebx),%eax
f0100101:	89 04 24             	mov    %eax,(%esp)
f0100104:	e8 5a 30 00 00       	call   f0103163 <cprintf>
	// Test the stack backtrace function (lab 1 only)

	//test_backtrace(5);
	mem_init();
f0100109:	e8 f8 12 00 00       	call   f0101406 <mem_init>
f010010e:	83 c4 10             	add    $0x10,%esp

	

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100111:	83 ec 0c             	sub    $0xc,%esp
f0100114:	6a 00                	push   $0x0
f0100116:	e8 25 08 00 00       	call   f0100940 <monitor>
f010011b:	83 c4 10             	add    $0x10,%esp
f010011e:	eb f1                	jmp    f0100111 <i386_init+0x6b>

f0100120 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100120:	55                   	push   %ebp
f0100121:	89 e5                	mov    %esp,%ebp
f0100123:	56                   	push   %esi
f0100124:	53                   	push   %ebx
f0100125:	e8 ac 00 00 00       	call   f01001d6 <__x86.get_pc_thunk.bx>
f010012a:	81 c3 e2 71 01 00    	add    $0x171e2,%ebx
	va_list ap;

	if (panicstr)
f0100130:	83 bb 54 1d 00 00 00 	cmpl   $0x0,0x1d54(%ebx)
f0100137:	74 0f                	je     f0100148 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100139:	83 ec 0c             	sub    $0xc,%esp
f010013c:	6a 00                	push   $0x0
f010013e:	e8 fd 07 00 00       	call   f0100940 <monitor>
f0100143:	83 c4 10             	add    $0x10,%esp
f0100146:	eb f1                	jmp    f0100139 <_panic+0x19>
	panicstr = fmt;
f0100148:	8b 45 10             	mov    0x10(%ebp),%eax
f010014b:	89 83 54 1d 00 00    	mov    %eax,0x1d54(%ebx)
	asm volatile("cli; cld");
f0100151:	fa                   	cli    
f0100152:	fc                   	cld    
	va_start(ap, fmt);
f0100153:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100156:	83 ec 04             	sub    $0x4,%esp
f0100159:	ff 75 0c             	push   0xc(%ebp)
f010015c:	ff 75 08             	push   0x8(%ebp)
f010015f:	8d 83 15 cf fe ff    	lea    -0x130eb(%ebx),%eax
f0100165:	50                   	push   %eax
f0100166:	e8 f8 2f 00 00       	call   f0103163 <cprintf>
	vcprintf(fmt, ap);
f010016b:	83 c4 08             	add    $0x8,%esp
f010016e:	56                   	push   %esi
f010016f:	ff 75 10             	push   0x10(%ebp)
f0100172:	e8 b5 2f 00 00       	call   f010312c <vcprintf>
	cprintf("\n");
f0100177:	8d 83 b6 de fe ff    	lea    -0x1214a(%ebx),%eax
f010017d:	89 04 24             	mov    %eax,(%esp)
f0100180:	e8 de 2f 00 00       	call   f0103163 <cprintf>
f0100185:	83 c4 10             	add    $0x10,%esp
f0100188:	eb af                	jmp    f0100139 <_panic+0x19>

f010018a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010018a:	55                   	push   %ebp
f010018b:	89 e5                	mov    %esp,%ebp
f010018d:	56                   	push   %esi
f010018e:	53                   	push   %ebx
f010018f:	e8 42 00 00 00       	call   f01001d6 <__x86.get_pc_thunk.bx>
f0100194:	81 c3 78 71 01 00    	add    $0x17178,%ebx
	va_list ap;

	va_start(ap, fmt);
f010019a:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010019d:	83 ec 04             	sub    $0x4,%esp
f01001a0:	ff 75 0c             	push   0xc(%ebp)
f01001a3:	ff 75 08             	push   0x8(%ebp)
f01001a6:	8d 83 2d cf fe ff    	lea    -0x130d3(%ebx),%eax
f01001ac:	50                   	push   %eax
f01001ad:	e8 b1 2f 00 00       	call   f0103163 <cprintf>
	vcprintf(fmt, ap);
f01001b2:	83 c4 08             	add    $0x8,%esp
f01001b5:	56                   	push   %esi
f01001b6:	ff 75 10             	push   0x10(%ebp)
f01001b9:	e8 6e 2f 00 00       	call   f010312c <vcprintf>
	cprintf("\n");
f01001be:	8d 83 b6 de fe ff    	lea    -0x1214a(%ebx),%eax
f01001c4:	89 04 24             	mov    %eax,(%esp)
f01001c7:	e8 97 2f 00 00       	call   f0103163 <cprintf>
	va_end(ap);
}
f01001cc:	83 c4 10             	add    $0x10,%esp
f01001cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001d2:	5b                   	pop    %ebx
f01001d3:	5e                   	pop    %esi
f01001d4:	5d                   	pop    %ebp
f01001d5:	c3                   	ret    

f01001d6 <__x86.get_pc_thunk.bx>:
f01001d6:	8b 1c 24             	mov    (%esp),%ebx
f01001d9:	c3                   	ret    

f01001da <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001da:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001df:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001e0:	a8 01                	test   $0x1,%al
f01001e2:	74 0a                	je     f01001ee <serial_proc_data+0x14>
f01001e4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e9:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ea:	0f b6 c0             	movzbl %al,%eax
f01001ed:	c3                   	ret    
		return -1;
f01001ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001f3:	c3                   	ret    

f01001f4 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001f4:	55                   	push   %ebp
f01001f5:	89 e5                	mov    %esp,%ebp
f01001f7:	57                   	push   %edi
f01001f8:	56                   	push   %esi
f01001f9:	53                   	push   %ebx
f01001fa:	83 ec 1c             	sub    $0x1c,%esp
f01001fd:	e8 6a 05 00 00       	call   f010076c <__x86.get_pc_thunk.si>
f0100202:	81 c6 0a 71 01 00    	add    $0x1710a,%esi
f0100208:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f010020a:	8d 1d 94 1d 00 00    	lea    0x1d94,%ebx
f0100210:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0100213:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100216:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100219:	eb 25                	jmp    f0100240 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f010021b:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100222:	8d 51 01             	lea    0x1(%ecx),%edx
f0100225:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100228:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f010022b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100231:	b8 00 00 00 00       	mov    $0x0,%eax
f0100236:	0f 44 d0             	cmove  %eax,%edx
f0100239:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100240:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100243:	ff d0                	call   *%eax
f0100245:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100248:	74 06                	je     f0100250 <cons_intr+0x5c>
		if (c == 0)
f010024a:	85 c0                	test   %eax,%eax
f010024c:	75 cd                	jne    f010021b <cons_intr+0x27>
f010024e:	eb f0                	jmp    f0100240 <cons_intr+0x4c>
	}
}
f0100250:	83 c4 1c             	add    $0x1c,%esp
f0100253:	5b                   	pop    %ebx
f0100254:	5e                   	pop    %esi
f0100255:	5f                   	pop    %edi
f0100256:	5d                   	pop    %ebp
f0100257:	c3                   	ret    

f0100258 <kbd_proc_data>:
{
f0100258:	55                   	push   %ebp
f0100259:	89 e5                	mov    %esp,%ebp
f010025b:	56                   	push   %esi
f010025c:	53                   	push   %ebx
f010025d:	e8 74 ff ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f0100262:	81 c3 aa 70 01 00    	add    $0x170aa,%ebx
f0100268:	ba 64 00 00 00       	mov    $0x64,%edx
f010026d:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010026e:	a8 01                	test   $0x1,%al
f0100270:	0f 84 f7 00 00 00    	je     f010036d <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100276:	a8 20                	test   $0x20,%al
f0100278:	0f 85 f6 00 00 00    	jne    f0100374 <kbd_proc_data+0x11c>
f010027e:	ba 60 00 00 00       	mov    $0x60,%edx
f0100283:	ec                   	in     (%dx),%al
f0100284:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100286:	3c e0                	cmp    $0xe0,%al
f0100288:	74 64                	je     f01002ee <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f010028a:	84 c0                	test   %al,%al
f010028c:	78 75                	js     f0100303 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010028e:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f0100294:	f6 c1 40             	test   $0x40,%cl
f0100297:	74 0e                	je     f01002a7 <kbd_proc_data+0x4f>
		data |= 0x80;
f0100299:	83 c8 80             	or     $0xffffff80,%eax
f010029c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010029e:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002a1:	89 8b 74 1d 00 00    	mov    %ecx,0x1d74(%ebx)
	shift |= shiftcode[data];
f01002a7:	0f b6 d2             	movzbl %dl,%edx
f01002aa:	0f b6 84 13 b4 d0 fe 	movzbl -0x12f4c(%ebx,%edx,1),%eax
f01002b1:	ff 
f01002b2:	0b 83 74 1d 00 00    	or     0x1d74(%ebx),%eax
	shift ^= togglecode[data];
f01002b8:	0f b6 8c 13 b4 cf fe 	movzbl -0x1304c(%ebx,%edx,1),%ecx
f01002bf:	ff 
f01002c0:	31 c8                	xor    %ecx,%eax
f01002c2:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002c8:	89 c1                	mov    %eax,%ecx
f01002ca:	83 e1 03             	and    $0x3,%ecx
f01002cd:	8b 8c 8b f4 1c 00 00 	mov    0x1cf4(%ebx,%ecx,4),%ecx
f01002d4:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002d8:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002db:	a8 08                	test   $0x8,%al
f01002dd:	74 61                	je     f0100340 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002df:	89 f2                	mov    %esi,%edx
f01002e1:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002e4:	83 f9 19             	cmp    $0x19,%ecx
f01002e7:	77 4b                	ja     f0100334 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002e9:	83 ee 20             	sub    $0x20,%esi
f01002ec:	eb 0c                	jmp    f01002fa <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002ee:	83 8b 74 1d 00 00 40 	orl    $0x40,0x1d74(%ebx)
		return 0;
f01002f5:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002fa:	89 f0                	mov    %esi,%eax
f01002fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002ff:	5b                   	pop    %ebx
f0100300:	5e                   	pop    %esi
f0100301:	5d                   	pop    %ebp
f0100302:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100303:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f0100309:	83 e0 7f             	and    $0x7f,%eax
f010030c:	f6 c1 40             	test   $0x40,%cl
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 84 13 b4 d0 fe 	movzbl -0x12f4c(%ebx,%edx,1),%eax
f010031c:	ff 
f010031d:	83 c8 40             	or     $0x40,%eax
f0100320:	0f b6 c0             	movzbl %al,%eax
f0100323:	f7 d0                	not    %eax
f0100325:	21 c8                	and    %ecx,%eax
f0100327:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
		return 0;
f010032d:	be 00 00 00 00       	mov    $0x0,%esi
f0100332:	eb c6                	jmp    f01002fa <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f0100334:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100337:	8d 4e 20             	lea    0x20(%esi),%ecx
f010033a:	83 fa 1a             	cmp    $0x1a,%edx
f010033d:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100340:	f7 d0                	not    %eax
f0100342:	a8 06                	test   $0x6,%al
f0100344:	75 b4                	jne    f01002fa <kbd_proc_data+0xa2>
f0100346:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010034c:	75 ac                	jne    f01002fa <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f010034e:	83 ec 0c             	sub    $0xc,%esp
f0100351:	8d 83 75 cf fe ff    	lea    -0x1308b(%ebx),%eax
f0100357:	50                   	push   %eax
f0100358:	e8 06 2e 00 00       	call   f0103163 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f010035d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100362:	ba 92 00 00 00       	mov    $0x92,%edx
f0100367:	ee                   	out    %al,(%dx)
}
f0100368:	83 c4 10             	add    $0x10,%esp
f010036b:	eb 8d                	jmp    f01002fa <kbd_proc_data+0xa2>
		return -1;
f010036d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100372:	eb 86                	jmp    f01002fa <kbd_proc_data+0xa2>
		return -1;
f0100374:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100379:	e9 7c ff ff ff       	jmp    f01002fa <kbd_proc_data+0xa2>

f010037e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010037e:	55                   	push   %ebp
f010037f:	89 e5                	mov    %esp,%ebp
f0100381:	57                   	push   %edi
f0100382:	56                   	push   %esi
f0100383:	53                   	push   %ebx
f0100384:	83 ec 1c             	sub    $0x1c,%esp
f0100387:	e8 4a fe ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f010038c:	81 c3 80 6f 01 00    	add    $0x16f80,%ebx
f0100392:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100395:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010039a:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010039f:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003a4:	89 fa                	mov    %edi,%edx
f01003a6:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003a7:	a8 20                	test   $0x20,%al
f01003a9:	75 13                	jne    f01003be <cons_putc+0x40>
f01003ab:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003b1:	7f 0b                	jg     f01003be <cons_putc+0x40>
f01003b3:	89 ca                	mov    %ecx,%edx
f01003b5:	ec                   	in     (%dx),%al
f01003b6:	ec                   	in     (%dx),%al
f01003b7:	ec                   	in     (%dx),%al
f01003b8:	ec                   	in     (%dx),%al
	     i++)
f01003b9:	83 c6 01             	add    $0x1,%esi
f01003bc:	eb e6                	jmp    f01003a4 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003be:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003c2:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f01003c5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003ca:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003cb:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d0:	bf 79 03 00 00       	mov    $0x379,%edi
f01003d5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003da:	89 fa                	mov    %edi,%edx
f01003dc:	ec                   	in     (%dx),%al
f01003dd:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003e3:	7f 0f                	jg     f01003f4 <cons_putc+0x76>
f01003e5:	84 c0                	test   %al,%al
f01003e7:	78 0b                	js     f01003f4 <cons_putc+0x76>
f01003e9:	89 ca                	mov    %ecx,%edx
f01003eb:	ec                   	in     (%dx),%al
f01003ec:	ec                   	in     (%dx),%al
f01003ed:	ec                   	in     (%dx),%al
f01003ee:	ec                   	in     (%dx),%al
f01003ef:	83 c6 01             	add    $0x1,%esi
f01003f2:	eb e6                	jmp    f01003da <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f01003f4:	ba 78 03 00 00       	mov    $0x378,%edx
f01003f9:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003fd:	ee                   	out    %al,(%dx)
f01003fe:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100403:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100408:	ee                   	out    %al,(%dx)
f0100409:	b8 08 00 00 00       	mov    $0x8,%eax
f010040e:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100412:	89 f8                	mov    %edi,%eax
f0100414:	80 cc 07             	or     $0x7,%ah
f0100417:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010041d:	0f 45 c7             	cmovne %edi,%eax
f0100420:	89 c7                	mov    %eax,%edi
f0100422:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100425:	0f b6 c0             	movzbl %al,%eax
f0100428:	89 f9                	mov    %edi,%ecx
f010042a:	80 f9 0a             	cmp    $0xa,%cl
f010042d:	0f 84 e4 00 00 00    	je     f0100517 <cons_putc+0x199>
f0100433:	83 f8 0a             	cmp    $0xa,%eax
f0100436:	7f 46                	jg     f010047e <cons_putc+0x100>
f0100438:	83 f8 08             	cmp    $0x8,%eax
f010043b:	0f 84 a8 00 00 00    	je     f01004e9 <cons_putc+0x16b>
f0100441:	83 f8 09             	cmp    $0x9,%eax
f0100444:	0f 85 da 00 00 00    	jne    f0100524 <cons_putc+0x1a6>
		cons_putc(' ');
f010044a:	b8 20 00 00 00       	mov    $0x20,%eax
f010044f:	e8 2a ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100454:	b8 20 00 00 00       	mov    $0x20,%eax
f0100459:	e8 20 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f010045e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100463:	e8 16 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100468:	b8 20 00 00 00       	mov    $0x20,%eax
f010046d:	e8 0c ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100472:	b8 20 00 00 00       	mov    $0x20,%eax
f0100477:	e8 02 ff ff ff       	call   f010037e <cons_putc>
		break;
f010047c:	eb 26                	jmp    f01004a4 <cons_putc+0x126>
	switch (c & 0xff) {
f010047e:	83 f8 0d             	cmp    $0xd,%eax
f0100481:	0f 85 9d 00 00 00    	jne    f0100524 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100487:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f010048e:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100494:	c1 e8 16             	shr    $0x16,%eax
f0100497:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010049a:	c1 e0 04             	shl    $0x4,%eax
f010049d:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01004a4:	66 81 bb 9c 1f 00 00 	cmpw   $0x7cf,0x1f9c(%ebx)
f01004ab:	cf 07 
f01004ad:	0f 87 98 00 00 00    	ja     f010054b <cons_putc+0x1cd>
	outb(addr_6845, 14);
f01004b3:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f01004b9:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004be:	89 ca                	mov    %ecx,%edx
f01004c0:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004c1:	0f b7 9b 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%ebx
f01004c8:	8d 71 01             	lea    0x1(%ecx),%esi
f01004cb:	89 d8                	mov    %ebx,%eax
f01004cd:	66 c1 e8 08          	shr    $0x8,%ax
f01004d1:	89 f2                	mov    %esi,%edx
f01004d3:	ee                   	out    %al,(%dx)
f01004d4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004d9:	89 ca                	mov    %ecx,%edx
f01004db:	ee                   	out    %al,(%dx)
f01004dc:	89 d8                	mov    %ebx,%eax
f01004de:	89 f2                	mov    %esi,%edx
f01004e0:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004e4:	5b                   	pop    %ebx
f01004e5:	5e                   	pop    %esi
f01004e6:	5f                   	pop    %edi
f01004e7:	5d                   	pop    %ebp
f01004e8:	c3                   	ret    
		if (crt_pos > 0) {
f01004e9:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f01004f0:	66 85 c0             	test   %ax,%ax
f01004f3:	74 be                	je     f01004b3 <cons_putc+0x135>
			crt_pos--;
f01004f5:	83 e8 01             	sub    $0x1,%eax
f01004f8:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ff:	0f b7 c0             	movzwl %ax,%eax
f0100502:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100506:	b2 00                	mov    $0x0,%dl
f0100508:	83 ca 20             	or     $0x20,%edx
f010050b:	8b 8b a0 1f 00 00    	mov    0x1fa0(%ebx),%ecx
f0100511:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100515:	eb 8d                	jmp    f01004a4 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f0100517:	66 83 83 9c 1f 00 00 	addw   $0x50,0x1f9c(%ebx)
f010051e:	50 
f010051f:	e9 63 ff ff ff       	jmp    f0100487 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100524:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f010052b:	8d 50 01             	lea    0x1(%eax),%edx
f010052e:	66 89 93 9c 1f 00 00 	mov    %dx,0x1f9c(%ebx)
f0100535:	0f b7 c0             	movzwl %ax,%eax
f0100538:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f010053e:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100542:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100546:	e9 59 ff ff ff       	jmp    f01004a4 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054b:	8b 83 a0 1f 00 00    	mov    0x1fa0(%ebx),%eax
f0100551:	83 ec 04             	sub    $0x4,%esp
f0100554:	68 00 0f 00 00       	push   $0xf00
f0100559:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010055f:	52                   	push   %edx
f0100560:	50                   	push   %eax
f0100561:	e8 5c 38 00 00       	call   f0103dc2 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100566:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f010056c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100572:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100578:	83 c4 10             	add    $0x10,%esp
f010057b:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100580:	83 c0 02             	add    $0x2,%eax
f0100583:	39 d0                	cmp    %edx,%eax
f0100585:	75 f4                	jne    f010057b <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100587:	66 83 ab 9c 1f 00 00 	subw   $0x50,0x1f9c(%ebx)
f010058e:	50 
f010058f:	e9 1f ff ff ff       	jmp    f01004b3 <cons_putc+0x135>

f0100594 <serial_intr>:
{
f0100594:	e8 cf 01 00 00       	call   f0100768 <__x86.get_pc_thunk.ax>
f0100599:	05 73 6d 01 00       	add    $0x16d73,%eax
	if (serial_exists)
f010059e:	80 b8 a8 1f 00 00 00 	cmpb   $0x0,0x1fa8(%eax)
f01005a5:	75 01                	jne    f01005a8 <serial_intr+0x14>
f01005a7:	c3                   	ret    
{
f01005a8:	55                   	push   %ebp
f01005a9:	89 e5                	mov    %esp,%ebp
f01005ab:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005ae:	8d 80 ce 8e fe ff    	lea    -0x17132(%eax),%eax
f01005b4:	e8 3b fc ff ff       	call   f01001f4 <cons_intr>
}
f01005b9:	c9                   	leave  
f01005ba:	c3                   	ret    

f01005bb <kbd_intr>:
{
f01005bb:	55                   	push   %ebp
f01005bc:	89 e5                	mov    %esp,%ebp
f01005be:	83 ec 08             	sub    $0x8,%esp
f01005c1:	e8 a2 01 00 00       	call   f0100768 <__x86.get_pc_thunk.ax>
f01005c6:	05 46 6d 01 00       	add    $0x16d46,%eax
	cons_intr(kbd_proc_data);
f01005cb:	8d 80 4c 8f fe ff    	lea    -0x170b4(%eax),%eax
f01005d1:	e8 1e fc ff ff       	call   f01001f4 <cons_intr>
}
f01005d6:	c9                   	leave  
f01005d7:	c3                   	ret    

f01005d8 <cons_getc>:
{
f01005d8:	55                   	push   %ebp
f01005d9:	89 e5                	mov    %esp,%ebp
f01005db:	53                   	push   %ebx
f01005dc:	83 ec 04             	sub    $0x4,%esp
f01005df:	e8 f2 fb ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f01005e4:	81 c3 28 6d 01 00    	add    $0x16d28,%ebx
	serial_intr();
f01005ea:	e8 a5 ff ff ff       	call   f0100594 <serial_intr>
	kbd_intr();
f01005ef:	e8 c7 ff ff ff       	call   f01005bb <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005f4:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
	return 0;
f01005fa:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005ff:	3b 83 98 1f 00 00    	cmp    0x1f98(%ebx),%eax
f0100605:	74 1e                	je     f0100625 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f0100607:	8d 48 01             	lea    0x1(%eax),%ecx
f010060a:	0f b6 94 03 94 1d 00 	movzbl 0x1d94(%ebx,%eax,1),%edx
f0100611:	00 
			cons.rpos = 0;
f0100612:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100617:	b8 00 00 00 00       	mov    $0x0,%eax
f010061c:	0f 45 c1             	cmovne %ecx,%eax
f010061f:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
}
f0100625:	89 d0                	mov    %edx,%eax
f0100627:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010062a:	c9                   	leave  
f010062b:	c3                   	ret    

f010062c <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010062c:	55                   	push   %ebp
f010062d:	89 e5                	mov    %esp,%ebp
f010062f:	57                   	push   %edi
f0100630:	56                   	push   %esi
f0100631:	53                   	push   %ebx
f0100632:	83 ec 1c             	sub    $0x1c,%esp
f0100635:	e8 9c fb ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f010063a:	81 c3 d2 6c 01 00    	add    $0x16cd2,%ebx
	was = *cp;
f0100640:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100647:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010064e:	5a a5 
	if (*cp != 0xA55A) {
f0100650:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100657:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010065c:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100661:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100665:	0f 84 ac 00 00 00    	je     f0100717 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f010066b:	89 8b a4 1f 00 00    	mov    %ecx,0x1fa4(%ebx)
f0100671:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100676:	89 ca                	mov    %ecx,%edx
f0100678:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100679:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067c:	89 f2                	mov    %esi,%edx
f010067e:	ec                   	in     (%dx),%al
f010067f:	0f b6 c0             	movzbl %al,%eax
f0100682:	c1 e0 08             	shl    $0x8,%eax
f0100685:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f0100688:	b8 0f 00 00 00       	mov    $0xf,%eax
f010068d:	89 ca                	mov    %ecx,%edx
f010068f:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100690:	89 f2                	mov    %esi,%edx
f0100692:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100693:	89 bb a0 1f 00 00    	mov    %edi,0x1fa0(%ebx)
	pos |= inb(addr_6845 + 1);
f0100699:	0f b6 c0             	movzbl %al,%eax
f010069c:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f010069f:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f01006a6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006ab:	89 c8                	mov    %ecx,%eax
f01006ad:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006b2:	ee                   	out    %al,(%dx)
f01006b3:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006b8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006bd:	89 fa                	mov    %edi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006c5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ca:	ee                   	out    %al,(%dx)
f01006cb:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006d0:	89 c8                	mov    %ecx,%eax
f01006d2:	89 f2                	mov    %esi,%edx
f01006d4:	ee                   	out    %al,(%dx)
f01006d5:	b8 03 00 00 00       	mov    $0x3,%eax
f01006da:	89 fa                	mov    %edi,%edx
f01006dc:	ee                   	out    %al,(%dx)
f01006dd:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006e2:	89 c8                	mov    %ecx,%eax
f01006e4:	ee                   	out    %al,(%dx)
f01006e5:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ea:	89 f2                	mov    %esi,%edx
f01006ec:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ed:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006f2:	ec                   	in     (%dx),%al
f01006f3:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006f5:	3c ff                	cmp    $0xff,%al
f01006f7:	0f 95 83 a8 1f 00 00 	setne  0x1fa8(%ebx)
f01006fe:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100703:	ec                   	in     (%dx),%al
f0100704:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100709:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010070a:	80 f9 ff             	cmp    $0xff,%cl
f010070d:	74 1e                	je     f010072d <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f010070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100712:	5b                   	pop    %ebx
f0100713:	5e                   	pop    %esi
f0100714:	5f                   	pop    %edi
f0100715:	5d                   	pop    %ebp
f0100716:	c3                   	ret    
		*cp = was;
f0100717:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f010071e:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100723:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f0100728:	e9 3e ff ff ff       	jmp    f010066b <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f010072d:	83 ec 0c             	sub    $0xc,%esp
f0100730:	8d 83 81 cf fe ff    	lea    -0x1307f(%ebx),%eax
f0100736:	50                   	push   %eax
f0100737:	e8 27 2a 00 00       	call   f0103163 <cprintf>
f010073c:	83 c4 10             	add    $0x10,%esp
}
f010073f:	eb ce                	jmp    f010070f <cons_init+0xe3>

f0100741 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100741:	55                   	push   %ebp
f0100742:	89 e5                	mov    %esp,%ebp
f0100744:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100747:	8b 45 08             	mov    0x8(%ebp),%eax
f010074a:	e8 2f fc ff ff       	call   f010037e <cons_putc>
}
f010074f:	c9                   	leave  
f0100750:	c3                   	ret    

f0100751 <getchar>:

int
getchar(void)
{
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100757:	e8 7c fe ff ff       	call   f01005d8 <cons_getc>
f010075c:	85 c0                	test   %eax,%eax
f010075e:	74 f7                	je     f0100757 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100760:	c9                   	leave  
f0100761:	c3                   	ret    

f0100762 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100762:	b8 01 00 00 00       	mov    $0x1,%eax
f0100767:	c3                   	ret    

f0100768 <__x86.get_pc_thunk.ax>:
f0100768:	8b 04 24             	mov    (%esp),%eax
f010076b:	c3                   	ret    

f010076c <__x86.get_pc_thunk.si>:
f010076c:	8b 34 24             	mov    (%esp),%esi
f010076f:	c3                   	ret    

f0100770 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100770:	55                   	push   %ebp
f0100771:	89 e5                	mov    %esp,%ebp
f0100773:	56                   	push   %esi
f0100774:	53                   	push   %ebx
f0100775:	e8 5c fa ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f010077a:	81 c3 92 6b 01 00    	add    $0x16b92,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100780:	83 ec 04             	sub    $0x4,%esp
f0100783:	8d 83 b4 d1 fe ff    	lea    -0x12e4c(%ebx),%eax
f0100789:	50                   	push   %eax
f010078a:	8d 83 d2 d1 fe ff    	lea    -0x12e2e(%ebx),%eax
f0100790:	50                   	push   %eax
f0100791:	8d b3 d7 d1 fe ff    	lea    -0x12e29(%ebx),%esi
f0100797:	56                   	push   %esi
f0100798:	e8 c6 29 00 00       	call   f0103163 <cprintf>
f010079d:	83 c4 0c             	add    $0xc,%esp
f01007a0:	8d 83 70 d2 fe ff    	lea    -0x12d90(%ebx),%eax
f01007a6:	50                   	push   %eax
f01007a7:	8d 83 e0 d1 fe ff    	lea    -0x12e20(%ebx),%eax
f01007ad:	50                   	push   %eax
f01007ae:	56                   	push   %esi
f01007af:	e8 af 29 00 00       	call   f0103163 <cprintf>
f01007b4:	83 c4 0c             	add    $0xc,%esp
f01007b7:	8d 83 98 d2 fe ff    	lea    -0x12d68(%ebx),%eax
f01007bd:	50                   	push   %eax
f01007be:	8d 83 e9 d1 fe ff    	lea    -0x12e17(%ebx),%eax
f01007c4:	50                   	push   %eax
f01007c5:	56                   	push   %esi
f01007c6:	e8 98 29 00 00       	call   f0103163 <cprintf>
	return 0;
}
f01007cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007d3:	5b                   	pop    %ebx
f01007d4:	5e                   	pop    %esi
f01007d5:	5d                   	pop    %ebp
f01007d6:	c3                   	ret    

f01007d7 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007d7:	55                   	push   %ebp
f01007d8:	89 e5                	mov    %esp,%ebp
f01007da:	57                   	push   %edi
f01007db:	56                   	push   %esi
f01007dc:	53                   	push   %ebx
f01007dd:	83 ec 18             	sub    $0x18,%esp
f01007e0:	e8 f1 f9 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f01007e5:	81 c3 27 6b 01 00    	add    $0x16b27,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007eb:	8d 83 f3 d1 fe ff    	lea    -0x12e0d(%ebx),%eax
f01007f1:	50                   	push   %eax
f01007f2:	e8 6c 29 00 00       	call   f0103163 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007f7:	83 c4 08             	add    $0x8,%esp
f01007fa:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f0100800:	8d 83 c8 d2 fe ff    	lea    -0x12d38(%ebx),%eax
f0100806:	50                   	push   %eax
f0100807:	e8 57 29 00 00       	call   f0103163 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010080c:	83 c4 0c             	add    $0xc,%esp
f010080f:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100815:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f010081b:	50                   	push   %eax
f010081c:	57                   	push   %edi
f010081d:	8d 83 f0 d2 fe ff    	lea    -0x12d10(%ebx),%eax
f0100823:	50                   	push   %eax
f0100824:	e8 3a 29 00 00       	call   f0103163 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100829:	83 c4 0c             	add    $0xc,%esp
f010082c:	c7 c0 a1 41 10 f0    	mov    $0xf01041a1,%eax
f0100832:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100838:	52                   	push   %edx
f0100839:	50                   	push   %eax
f010083a:	8d 83 14 d3 fe ff    	lea    -0x12cec(%ebx),%eax
f0100840:	50                   	push   %eax
f0100841:	e8 1d 29 00 00       	call   f0103163 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100846:	83 c4 0c             	add    $0xc,%esp
f0100849:	c7 c0 60 90 11 f0    	mov    $0xf0119060,%eax
f010084f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100855:	52                   	push   %edx
f0100856:	50                   	push   %eax
f0100857:	8d 83 38 d3 fe ff    	lea    -0x12cc8(%ebx),%eax
f010085d:	50                   	push   %eax
f010085e:	e8 00 29 00 00       	call   f0103163 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	c7 c6 e0 96 11 f0    	mov    $0xf01196e0,%esi
f010086c:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100872:	50                   	push   %eax
f0100873:	56                   	push   %esi
f0100874:	8d 83 5c d3 fe ff    	lea    -0x12ca4(%ebx),%eax
f010087a:	50                   	push   %eax
f010087b:	e8 e3 28 00 00       	call   f0103163 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100880:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100883:	29 fe                	sub    %edi,%esi
f0100885:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088b:	c1 fe 0a             	sar    $0xa,%esi
f010088e:	56                   	push   %esi
f010088f:	8d 83 80 d3 fe ff    	lea    -0x12c80(%ebx),%eax
f0100895:	50                   	push   %eax
f0100896:	e8 c8 28 00 00       	call   f0103163 <cprintf>
	return 0;
}
f010089b:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008a3:	5b                   	pop    %ebx
f01008a4:	5e                   	pop    %esi
f01008a5:	5f                   	pop    %edi
f01008a6:	5d                   	pop    %ebp
f01008a7:	c3                   	ret    

f01008a8 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a8:	55                   	push   %ebp
f01008a9:	89 e5                	mov    %esp,%ebp
f01008ab:	57                   	push   %edi
f01008ac:	56                   	push   %esi
f01008ad:	53                   	push   %ebx
f01008ae:	83 ec 48             	sub    $0x48,%esp
f01008b1:	e8 20 f9 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f01008b6:	81 c3 56 6a 01 00    	add    $0x16a56,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008bc:	89 ee                	mov    %ebp,%esi
    // wrong read function, now 2/5 works

    ebp_ptr=(uint32_t*)read_ebp();  // typecast adress into int
    

    cprintf("Backtracing STACK ");
f01008be:	8d 83 0c d2 fe ff    	lea    -0x12df4(%ebx),%eax
f01008c4:	50                   	push   %eax
f01008c5:	e8 99 28 00 00       	call   f0103163 <cprintf>

	// while noq 0x0 not NULL

    while( ebp_ptr != 0x0)
f01008ca:	83 c4 10             	add    $0x10,%esp
    {
    // fixed eip, now not naively changining in printf 
    eip=*(ebp_ptr+1);
    cprintf("\n ebp %08x eip %08x args %08x %08x %08x %08x %08x  ", ebp_ptr, eip, *(ebp_ptr+2), // 8 digit hexx
f01008cd:	8d 83 ac d3 fe ff    	lea    -0x12c54(%ebx),%eax
f01008d3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
     *(ebp_ptr+2), *(ebp_ptr+3), *(ebp_ptr+4), *(ebp_ptr+5), *(ebp_ptr+6));
	
	debuginfo_eip((uintptr_t)eip, &info); 
	
	
	cprintf("\n %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name,
f01008d6:	8d 83 1f d2 fe ff    	lea    -0x12de1(%ebx),%eax
f01008dc:	89 45 c0             	mov    %eax,-0x40(%ebp)
    while( ebp_ptr != 0x0)
f01008df:	eb 4e                	jmp    f010092f <mon_backtrace+0x87>
    eip=*(ebp_ptr+1);
f01008e1:	8b 7e 04             	mov    0x4(%esi),%edi
    cprintf("\n ebp %08x eip %08x args %08x %08x %08x %08x %08x  ", ebp_ptr, eip, *(ebp_ptr+2), // 8 digit hexx
f01008e4:	8b 46 08             	mov    0x8(%esi),%eax
f01008e7:	83 ec 0c             	sub    $0xc,%esp
f01008ea:	ff 76 18             	push   0x18(%esi)
f01008ed:	ff 76 14             	push   0x14(%esi)
f01008f0:	ff 76 10             	push   0x10(%esi)
f01008f3:	ff 76 0c             	push   0xc(%esi)
f01008f6:	50                   	push   %eax
f01008f7:	50                   	push   %eax
f01008f8:	57                   	push   %edi
f01008f9:	56                   	push   %esi
f01008fa:	ff 75 c4             	push   -0x3c(%ebp)
f01008fd:	e8 61 28 00 00       	call   f0103163 <cprintf>
	debuginfo_eip((uintptr_t)eip, &info); 
f0100902:	83 c4 28             	add    $0x28,%esp
f0100905:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100908:	50                   	push   %eax
f0100909:	57                   	push   %edi
f010090a:	e8 5d 29 00 00       	call   f010326c <debuginfo_eip>
	cprintf("\n %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name,
f010090f:	83 c4 08             	add    $0x8,%esp
f0100912:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100915:	57                   	push   %edi
f0100916:	ff 75 d8             	push   -0x28(%ebp)
f0100919:	ff 75 dc             	push   -0x24(%ebp)
f010091c:	ff 75 d4             	push   -0x2c(%ebp)
f010091f:	ff 75 d0             	push   -0x30(%ebp)
f0100922:	ff 75 c0             	push   -0x40(%ebp)
f0100925:	e8 39 28 00 00       	call   f0103163 <cprintf>
	 eip - info.eip_fn_addr);
		
	ebp_ptr = (uint32_t*)*ebp_ptr;
f010092a:	8b 36                	mov    (%esi),%esi
f010092c:	83 c4 20             	add    $0x20,%esp
    while( ebp_ptr != 0x0)
f010092f:	85 f6                	test   %esi,%esi
f0100931:	75 ae                	jne    f01008e1 <mon_backtrace+0x39>


        
	return 0;

}
f0100933:	b8 00 00 00 00       	mov    $0x0,%eax
f0100938:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010093b:	5b                   	pop    %ebx
f010093c:	5e                   	pop    %esi
f010093d:	5f                   	pop    %edi
f010093e:	5d                   	pop    %ebp
f010093f:	c3                   	ret    

f0100940 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100940:	55                   	push   %ebp
f0100941:	89 e5                	mov    %esp,%ebp
f0100943:	57                   	push   %edi
f0100944:	56                   	push   %esi
f0100945:	53                   	push   %ebx
f0100946:	83 ec 68             	sub    $0x68,%esp
f0100949:	e8 88 f8 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f010094e:	81 c3 be 69 01 00    	add    $0x169be,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100954:	8d 83 e0 d3 fe ff    	lea    -0x12c20(%ebx),%eax
f010095a:	50                   	push   %eax
f010095b:	e8 03 28 00 00       	call   f0103163 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100960:	8d 83 04 d4 fe ff    	lea    -0x12bfc(%ebx),%eax
f0100966:	89 04 24             	mov    %eax,(%esp)
f0100969:	e8 f5 27 00 00       	call   f0103163 <cprintf>
f010096e:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100971:	8d bb 35 d2 fe ff    	lea    -0x12dcb(%ebx),%edi
f0100977:	eb 4a                	jmp    f01009c3 <monitor+0x83>
f0100979:	83 ec 08             	sub    $0x8,%esp
f010097c:	0f be c0             	movsbl %al,%eax
f010097f:	50                   	push   %eax
f0100980:	57                   	push   %edi
f0100981:	e8 b7 33 00 00       	call   f0103d3d <strchr>
f0100986:	83 c4 10             	add    $0x10,%esp
f0100989:	85 c0                	test   %eax,%eax
f010098b:	74 08                	je     f0100995 <monitor+0x55>
			*buf++ = 0;
f010098d:	c6 06 00             	movb   $0x0,(%esi)
f0100990:	8d 76 01             	lea    0x1(%esi),%esi
f0100993:	eb 76                	jmp    f0100a0b <monitor+0xcb>
		if (*buf == 0)
f0100995:	80 3e 00             	cmpb   $0x0,(%esi)
f0100998:	74 7c                	je     f0100a16 <monitor+0xd6>
		if (argc == MAXARGS-1) {
f010099a:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010099e:	74 0f                	je     f01009af <monitor+0x6f>
		argv[argc++] = buf;
f01009a0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009a3:	8d 48 01             	lea    0x1(%eax),%ecx
f01009a6:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009a9:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009ad:	eb 41                	jmp    f01009f0 <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009af:	83 ec 08             	sub    $0x8,%esp
f01009b2:	6a 10                	push   $0x10
f01009b4:	8d 83 3a d2 fe ff    	lea    -0x12dc6(%ebx),%eax
f01009ba:	50                   	push   %eax
f01009bb:	e8 a3 27 00 00       	call   f0103163 <cprintf>
			return 0;
f01009c0:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009c3:	8d 83 31 d2 fe ff    	lea    -0x12dcf(%ebx),%eax
f01009c9:	89 c6                	mov    %eax,%esi
f01009cb:	83 ec 0c             	sub    $0xc,%esp
f01009ce:	56                   	push   %esi
f01009cf:	e8 18 31 00 00       	call   f0103aec <readline>
		if (buf != NULL)
f01009d4:	83 c4 10             	add    $0x10,%esp
f01009d7:	85 c0                	test   %eax,%eax
f01009d9:	74 f0                	je     f01009cb <monitor+0x8b>
	argv[argc] = 0;
f01009db:	89 c6                	mov    %eax,%esi
f01009dd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009e4:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009eb:	eb 1e                	jmp    f0100a0b <monitor+0xcb>
			buf++;
f01009ed:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009f0:	0f b6 06             	movzbl (%esi),%eax
f01009f3:	84 c0                	test   %al,%al
f01009f5:	74 14                	je     f0100a0b <monitor+0xcb>
f01009f7:	83 ec 08             	sub    $0x8,%esp
f01009fa:	0f be c0             	movsbl %al,%eax
f01009fd:	50                   	push   %eax
f01009fe:	57                   	push   %edi
f01009ff:	e8 39 33 00 00       	call   f0103d3d <strchr>
f0100a04:	83 c4 10             	add    $0x10,%esp
f0100a07:	85 c0                	test   %eax,%eax
f0100a09:	74 e2                	je     f01009ed <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a0b:	0f b6 06             	movzbl (%esi),%eax
f0100a0e:	84 c0                	test   %al,%al
f0100a10:	0f 85 63 ff ff ff    	jne    f0100979 <monitor+0x39>
	argv[argc] = 0;
f0100a16:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a19:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a20:	00 
	if (argc == 0)
f0100a21:	85 c0                	test   %eax,%eax
f0100a23:	74 9e                	je     f01009c3 <monitor+0x83>
f0100a25:	8d b3 14 1d 00 00    	lea    0x1d14(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a2b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a30:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a33:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a35:	83 ec 08             	sub    $0x8,%esp
f0100a38:	ff 36                	push   (%esi)
f0100a3a:	ff 75 a8             	push   -0x58(%ebp)
f0100a3d:	e8 9b 32 00 00       	call   f0103cdd <strcmp>
f0100a42:	83 c4 10             	add    $0x10,%esp
f0100a45:	85 c0                	test   %eax,%eax
f0100a47:	74 28                	je     f0100a71 <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a49:	83 c7 01             	add    $0x1,%edi
f0100a4c:	83 c6 0c             	add    $0xc,%esi
f0100a4f:	83 ff 03             	cmp    $0x3,%edi
f0100a52:	75 e1                	jne    f0100a35 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a54:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a57:	83 ec 08             	sub    $0x8,%esp
f0100a5a:	ff 75 a8             	push   -0x58(%ebp)
f0100a5d:	8d 83 57 d2 fe ff    	lea    -0x12da9(%ebx),%eax
f0100a63:	50                   	push   %eax
f0100a64:	e8 fa 26 00 00       	call   f0103163 <cprintf>
	return 0;
f0100a69:	83 c4 10             	add    $0x10,%esp
f0100a6c:	e9 52 ff ff ff       	jmp    f01009c3 <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a71:	89 f8                	mov    %edi,%eax
f0100a73:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a76:	83 ec 04             	sub    $0x4,%esp
f0100a79:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a7c:	ff 75 08             	push   0x8(%ebp)
f0100a7f:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a82:	52                   	push   %edx
f0100a83:	ff 75 a4             	push   -0x5c(%ebp)
f0100a86:	ff 94 83 1c 1d 00 00 	call   *0x1d1c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a8d:	83 c4 10             	add    $0x10,%esp
f0100a90:	85 c0                	test   %eax,%eax
f0100a92:	0f 89 2b ff ff ff    	jns    f01009c3 <monitor+0x83>
				break;
	}
}
f0100a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a9b:	5b                   	pop    %ebx
f0100a9c:	5e                   	pop    %esi
f0100a9d:	5f                   	pop    %edi
f0100a9e:	5d                   	pop    %ebp
f0100a9f:	c3                   	ret    

f0100aa0 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100aa0:	55                   	push   %ebp
f0100aa1:	89 e5                	mov    %esp,%ebp
f0100aa3:	57                   	push   %edi
f0100aa4:	56                   	push   %esi
f0100aa5:	53                   	push   %ebx
f0100aa6:	83 ec 18             	sub    $0x18,%esp
f0100aa9:	e8 28 f7 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f0100aae:	81 c3 5e 68 01 00    	add    $0x1685e,%ebx
f0100ab4:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ab6:	50                   	push   %eax
f0100ab7:	e8 20 26 00 00       	call   f01030dc <mc146818_read>
f0100abc:	89 c7                	mov    %eax,%edi
f0100abe:	83 c6 01             	add    $0x1,%esi
f0100ac1:	89 34 24             	mov    %esi,(%esp)
f0100ac4:	e8 13 26 00 00       	call   f01030dc <mc146818_read>
f0100ac9:	c1 e0 08             	shl    $0x8,%eax
f0100acc:	09 f8                	or     %edi,%eax
}
f0100ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ad1:	5b                   	pop    %ebx
f0100ad2:	5e                   	pop    %esi
f0100ad3:	5f                   	pop    %edi
f0100ad4:	5d                   	pop    %ebp
f0100ad5:	c3                   	ret    

f0100ad6 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ad6:	55                   	push   %ebp
f0100ad7:	89 e5                	mov    %esp,%ebp
f0100ad9:	53                   	push   %ebx
f0100ada:	83 ec 04             	sub    $0x4,%esp
f0100add:	e8 ee 25 00 00       	call   f01030d0 <__x86.get_pc_thunk.dx>
f0100ae2:	81 c2 2a 68 01 00    	add    $0x1682a,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ae8:	83 ba b8 1f 00 00 00 	cmpl   $0x0,0x1fb8(%edx)
f0100aef:	74 38                	je     f0100b29 <boot_alloc+0x53>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	result = nextfree;
f0100af1:	8b 8a b8 1f 00 00    	mov    0x1fb8(%edx),%ecx
	nextfree += ROUNDUP(n, PGSIZE);
f0100af7:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100afc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b01:	01 c8                	add    %ecx,%eax
f0100b03:	89 82 b8 1f 00 00    	mov    %eax,0x1fb8(%edx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100b09:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100b0e:	76 33                	jbe    f0100b43 <boot_alloc+0x6d>

	if (PADDR(nextfree) >= npages * PGSIZE)  // if size of nextfree is bigger than all mapped pyhisical memory
f0100b10:	8b 9a b4 1f 00 00    	mov    0x1fb4(%edx),%ebx
f0100b16:	c1 e3 0c             	shl    $0xc,%ebx
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0100b19:	05 00 00 00 10       	add    $0x10000000,%eax
f0100b1e:	39 c3                	cmp    %eax,%ebx
f0100b20:	76 39                	jbe    f0100b5b <boot_alloc+0x85>
		panic("boot_alloc: out of memeory");
	

	return (void *)result;
}
f0100b22:	89 c8                	mov    %ecx,%eax
f0100b24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b27:	c9                   	leave  
f0100b28:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b29:	c7 c1 e0 96 11 f0    	mov    $0xf01196e0,%ecx
f0100b2f:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100b35:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100b3b:	89 8a b8 1f 00 00    	mov    %ecx,0x1fb8(%edx)
f0100b41:	eb ae                	jmp    f0100af1 <boot_alloc+0x1b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b43:	50                   	push   %eax
f0100b44:	8d 82 2c d4 fe ff    	lea    -0x12bd4(%edx),%eax
f0100b4a:	50                   	push   %eax
f0100b4b:	6a 6c                	push   $0x6c
f0100b4d:	8d 82 a1 db fe ff    	lea    -0x1245f(%edx),%eax
f0100b53:	50                   	push   %eax
f0100b54:	89 d3                	mov    %edx,%ebx
f0100b56:	e8 c5 f5 ff ff       	call   f0100120 <_panic>
		panic("boot_alloc: out of memeory");
f0100b5b:	83 ec 04             	sub    $0x4,%esp
f0100b5e:	8d 82 ad db fe ff    	lea    -0x12453(%edx),%eax
f0100b64:	50                   	push   %eax
f0100b65:	6a 6d                	push   $0x6d
f0100b67:	8d 82 a1 db fe ff    	lea    -0x1245f(%edx),%eax
f0100b6d:	50                   	push   %eax
f0100b6e:	89 d3                	mov    %edx,%ebx
f0100b70:	e8 ab f5 ff ff       	call   f0100120 <_panic>

f0100b75 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b75:	55                   	push   %ebp
f0100b76:	89 e5                	mov    %esp,%ebp
f0100b78:	53                   	push   %ebx
f0100b79:	83 ec 04             	sub    $0x4,%esp
f0100b7c:	e8 53 25 00 00       	call   f01030d4 <__x86.get_pc_thunk.cx>
f0100b81:	81 c1 8b 67 01 00    	add    $0x1678b,%ecx
f0100b87:	89 c3                	mov    %eax,%ebx
f0100b89:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b8b:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100b8e:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f0100b91:	f6 c2 01             	test   $0x1,%dl
f0100b94:	74 54                	je     f0100bea <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b96:	89 d3                	mov    %edx,%ebx
f0100b98:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b9e:	c1 ea 0c             	shr    $0xc,%edx
f0100ba1:	3b 91 b4 1f 00 00    	cmp    0x1fb4(%ecx),%edx
f0100ba7:	73 26                	jae    f0100bcf <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100ba9:	c1 e8 0c             	shr    $0xc,%eax
f0100bac:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100bb1:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bb8:	89 d0                	mov    %edx,%eax
f0100bba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bbf:	f6 c2 01             	test   $0x1,%dl
f0100bc2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bc7:	0f 44 c2             	cmove  %edx,%eax
}
f0100bca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bcd:	c9                   	leave  
f0100bce:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bcf:	53                   	push   %ebx
f0100bd0:	8d 81 50 d4 fe ff    	lea    -0x12bb0(%ecx),%eax
f0100bd6:	50                   	push   %eax
f0100bd7:	68 55 03 00 00       	push   $0x355
f0100bdc:	8d 81 a1 db fe ff    	lea    -0x1245f(%ecx),%eax
f0100be2:	50                   	push   %eax
f0100be3:	89 cb                	mov    %ecx,%ebx
f0100be5:	e8 36 f5 ff ff       	call   f0100120 <_panic>
		return ~0;
f0100bea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bef:	eb d9                	jmp    f0100bca <check_va2pa+0x55>

f0100bf1 <check_page_free_list>:
{
f0100bf1:	55                   	push   %ebp
f0100bf2:	89 e5                	mov    %esp,%ebp
f0100bf4:	57                   	push   %edi
f0100bf5:	56                   	push   %esi
f0100bf6:	53                   	push   %ebx
f0100bf7:	83 ec 2c             	sub    $0x2c,%esp
f0100bfa:	e8 d9 24 00 00       	call   f01030d8 <__x86.get_pc_thunk.di>
f0100bff:	81 c7 0d 67 01 00    	add    $0x1670d,%edi
f0100c05:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c08:	84 c0                	test   %al,%al
f0100c0a:	0f 85 dc 02 00 00    	jne    f0100eec <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100c10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c13:	83 b8 bc 1f 00 00 00 	cmpl   $0x0,0x1fbc(%eax)
f0100c1a:	74 0a                	je     f0100c26 <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c1c:	bf 00 04 00 00       	mov    $0x400,%edi
f0100c21:	e9 29 03 00 00       	jmp    f0100f4f <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100c26:	83 ec 04             	sub    $0x4,%esp
f0100c29:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c2c:	8d 83 74 d4 fe ff    	lea    -0x12b8c(%ebx),%eax
f0100c32:	50                   	push   %eax
f0100c33:	68 96 02 00 00       	push   $0x296
f0100c38:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100c3e:	50                   	push   %eax
f0100c3f:	e8 dc f4 ff ff       	call   f0100120 <_panic>
f0100c44:	50                   	push   %eax
f0100c45:	89 cb                	mov    %ecx,%ebx
f0100c47:	8d 81 50 d4 fe ff    	lea    -0x12bb0(%ecx),%eax
f0100c4d:	50                   	push   %eax
f0100c4e:	6a 55                	push   $0x55
f0100c50:	8d 81 c8 db fe ff    	lea    -0x12438(%ecx),%eax
f0100c56:	50                   	push   %eax
f0100c57:	e8 c4 f4 ff ff       	call   f0100120 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c5c:	8b 36                	mov    (%esi),%esi
f0100c5e:	85 f6                	test   %esi,%esi
f0100c60:	74 47                	je     f0100ca9 <check_page_free_list+0xb8>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0100c62:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100c65:	89 f0                	mov    %esi,%eax
f0100c67:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0100c6d:	c1 f8 03             	sar    $0x3,%eax
f0100c70:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c73:	89 c2                	mov    %eax,%edx
f0100c75:	c1 ea 16             	shr    $0x16,%edx
f0100c78:	39 fa                	cmp    %edi,%edx
f0100c7a:	73 e0                	jae    f0100c5c <check_page_free_list+0x6b>
	if (PGNUM(pa) >= npages)
f0100c7c:	89 c2                	mov    %eax,%edx
f0100c7e:	c1 ea 0c             	shr    $0xc,%edx
f0100c81:	3b 91 b4 1f 00 00    	cmp    0x1fb4(%ecx),%edx
f0100c87:	73 bb                	jae    f0100c44 <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100c89:	83 ec 04             	sub    $0x4,%esp
f0100c8c:	68 80 00 00 00       	push   $0x80
f0100c91:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c9b:	50                   	push   %eax
f0100c9c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c9f:	e8 d8 30 00 00       	call   f0103d7c <memset>
f0100ca4:	83 c4 10             	add    $0x10,%esp
f0100ca7:	eb b3                	jmp    f0100c5c <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100ca9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cae:	e8 23 fe ff ff       	call   f0100ad6 <boot_alloc>
f0100cb3:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cb6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cb9:	8b 90 bc 1f 00 00    	mov    0x1fbc(%eax),%edx
		assert(pp >= pages);
f0100cbf:	8b 88 ac 1f 00 00    	mov    0x1fac(%eax),%ecx
		assert(pp < pages + npages);
f0100cc5:	8b 80 b4 1f 00 00    	mov    0x1fb4(%eax),%eax
f0100ccb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100cce:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cd1:	bf 00 00 00 00       	mov    $0x0,%edi
f0100cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cdb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cde:	e9 07 01 00 00       	jmp    f0100dea <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0100ce3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ce6:	8d 83 d6 db fe ff    	lea    -0x1242a(%ebx),%eax
f0100cec:	50                   	push   %eax
f0100ced:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100cf3:	50                   	push   %eax
f0100cf4:	68 b0 02 00 00       	push   $0x2b0
f0100cf9:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100cff:	50                   	push   %eax
f0100d00:	e8 1b f4 ff ff       	call   f0100120 <_panic>
		assert(pp < pages + npages);
f0100d05:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d08:	8d 83 f7 db fe ff    	lea    -0x12409(%ebx),%eax
f0100d0e:	50                   	push   %eax
f0100d0f:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100d15:	50                   	push   %eax
f0100d16:	68 b1 02 00 00       	push   $0x2b1
f0100d1b:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100d21:	50                   	push   %eax
f0100d22:	e8 f9 f3 ff ff       	call   f0100120 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d27:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d2a:	8d 83 98 d4 fe ff    	lea    -0x12b68(%ebx),%eax
f0100d30:	50                   	push   %eax
f0100d31:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100d37:	50                   	push   %eax
f0100d38:	68 b2 02 00 00       	push   $0x2b2
f0100d3d:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100d43:	50                   	push   %eax
f0100d44:	e8 d7 f3 ff ff       	call   f0100120 <_panic>
		assert(page2pa(pp) != 0);
f0100d49:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d4c:	8d 83 0b dc fe ff    	lea    -0x123f5(%ebx),%eax
f0100d52:	50                   	push   %eax
f0100d53:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100d59:	50                   	push   %eax
f0100d5a:	68 b5 02 00 00       	push   $0x2b5
f0100d5f:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100d65:	50                   	push   %eax
f0100d66:	e8 b5 f3 ff ff       	call   f0100120 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d6b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d6e:	8d 83 1c dc fe ff    	lea    -0x123e4(%ebx),%eax
f0100d74:	50                   	push   %eax
f0100d75:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100d7b:	50                   	push   %eax
f0100d7c:	68 b6 02 00 00       	push   $0x2b6
f0100d81:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100d87:	50                   	push   %eax
f0100d88:	e8 93 f3 ff ff       	call   f0100120 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d8d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d90:	8d 83 cc d4 fe ff    	lea    -0x12b34(%ebx),%eax
f0100d96:	50                   	push   %eax
f0100d97:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100d9d:	50                   	push   %eax
f0100d9e:	68 b7 02 00 00       	push   $0x2b7
f0100da3:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100da9:	50                   	push   %eax
f0100daa:	e8 71 f3 ff ff       	call   f0100120 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100daf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100db2:	8d 83 35 dc fe ff    	lea    -0x123cb(%ebx),%eax
f0100db8:	50                   	push   %eax
f0100db9:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100dbf:	50                   	push   %eax
f0100dc0:	68 b8 02 00 00       	push   $0x2b8
f0100dc5:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100dcb:	50                   	push   %eax
f0100dcc:	e8 4f f3 ff ff       	call   f0100120 <_panic>
	if (PGNUM(pa) >= npages)
f0100dd1:	89 c3                	mov    %eax,%ebx
f0100dd3:	c1 eb 0c             	shr    $0xc,%ebx
f0100dd6:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100dd9:	76 6d                	jbe    f0100e48 <check_page_free_list+0x257>
	return (void *)(pa + KERNBASE);
f0100ddb:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100de0:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100de3:	77 7c                	ja     f0100e61 <check_page_free_list+0x270>
			++nfree_extmem;
f0100de5:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100de8:	8b 12                	mov    (%edx),%edx
f0100dea:	85 d2                	test   %edx,%edx
f0100dec:	0f 84 91 00 00 00    	je     f0100e83 <check_page_free_list+0x292>
		assert(pp >= pages);
f0100df2:	39 d1                	cmp    %edx,%ecx
f0100df4:	0f 87 e9 fe ff ff    	ja     f0100ce3 <check_page_free_list+0xf2>
		assert(pp < pages + npages);
f0100dfa:	39 d6                	cmp    %edx,%esi
f0100dfc:	0f 86 03 ff ff ff    	jbe    f0100d05 <check_page_free_list+0x114>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e02:	89 d0                	mov    %edx,%eax
f0100e04:	29 c8                	sub    %ecx,%eax
f0100e06:	a8 07                	test   $0x7,%al
f0100e08:	0f 85 19 ff ff ff    	jne    f0100d27 <check_page_free_list+0x136>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0100e0e:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100e11:	c1 e0 0c             	shl    $0xc,%eax
f0100e14:	0f 84 2f ff ff ff    	je     f0100d49 <check_page_free_list+0x158>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e1a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e1f:	0f 84 46 ff ff ff    	je     f0100d6b <check_page_free_list+0x17a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e25:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e2a:	0f 84 5d ff ff ff    	je     f0100d8d <check_page_free_list+0x19c>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e30:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e35:	0f 84 74 ff ff ff    	je     f0100daf <check_page_free_list+0x1be>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e3b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e40:	77 8f                	ja     f0100dd1 <check_page_free_list+0x1e0>
			++nfree_basemem;
f0100e42:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100e46:	eb a0                	jmp    f0100de8 <check_page_free_list+0x1f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e48:	50                   	push   %eax
f0100e49:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e4c:	8d 83 50 d4 fe ff    	lea    -0x12bb0(%ebx),%eax
f0100e52:	50                   	push   %eax
f0100e53:	6a 55                	push   $0x55
f0100e55:	8d 83 c8 db fe ff    	lea    -0x12438(%ebx),%eax
f0100e5b:	50                   	push   %eax
f0100e5c:	e8 bf f2 ff ff       	call   f0100120 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e64:	8d 83 f0 d4 fe ff    	lea    -0x12b10(%ebx),%eax
f0100e6a:	50                   	push   %eax
f0100e6b:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100e71:	50                   	push   %eax
f0100e72:	68 b9 02 00 00       	push   $0x2b9
f0100e77:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100e7d:	50                   	push   %eax
f0100e7e:	e8 9d f2 ff ff       	call   f0100120 <_panic>
	assert(nfree_basemem > 0);
f0100e83:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e86:	85 db                	test   %ebx,%ebx
f0100e88:	7e 1e                	jle    f0100ea8 <check_page_free_list+0x2b7>
	assert(nfree_extmem > 0);
f0100e8a:	85 ff                	test   %edi,%edi
f0100e8c:	7e 3c                	jle    f0100eca <check_page_free_list+0x2d9>
	cprintf("check_page_free_list() succeeded!\n");
f0100e8e:	83 ec 0c             	sub    $0xc,%esp
f0100e91:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e94:	8d 83 38 d5 fe ff    	lea    -0x12ac8(%ebx),%eax
f0100e9a:	50                   	push   %eax
f0100e9b:	e8 c3 22 00 00       	call   f0103163 <cprintf>
}
f0100ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ea3:	5b                   	pop    %ebx
f0100ea4:	5e                   	pop    %esi
f0100ea5:	5f                   	pop    %edi
f0100ea6:	5d                   	pop    %ebp
f0100ea7:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100ea8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100eab:	8d 83 4f dc fe ff    	lea    -0x123b1(%ebx),%eax
f0100eb1:	50                   	push   %eax
f0100eb2:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100eb8:	50                   	push   %eax
f0100eb9:	68 c1 02 00 00       	push   $0x2c1
f0100ebe:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100ec4:	50                   	push   %eax
f0100ec5:	e8 56 f2 ff ff       	call   f0100120 <_panic>
	assert(nfree_extmem > 0);
f0100eca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ecd:	8d 83 61 dc fe ff    	lea    -0x1239f(%ebx),%eax
f0100ed3:	50                   	push   %eax
f0100ed4:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0100eda:	50                   	push   %eax
f0100edb:	68 c2 02 00 00       	push   $0x2c2
f0100ee0:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0100ee6:	50                   	push   %eax
f0100ee7:	e8 34 f2 ff ff       	call   f0100120 <_panic>
	if (!page_free_list)
f0100eec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100eef:	8b 80 bc 1f 00 00    	mov    0x1fbc(%eax),%eax
f0100ef5:	85 c0                	test   %eax,%eax
f0100ef7:	0f 84 29 fd ff ff    	je     f0100c26 <check_page_free_list+0x35>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100efd:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f00:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f03:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f06:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0100f09:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f0c:	89 c2                	mov    %eax,%edx
f0100f0e:	2b 97 ac 1f 00 00    	sub    0x1fac(%edi),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f14:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f1a:	0f 95 c2             	setne  %dl
f0100f1d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f20:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f24:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f26:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f2a:	8b 00                	mov    (%eax),%eax
f0100f2c:	85 c0                	test   %eax,%eax
f0100f2e:	75 d9                	jne    f0100f09 <check_page_free_list+0x318>
		*tp[1] = 0;
f0100f30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f39:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f3f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f41:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f44:	89 87 bc 1f 00 00    	mov    %eax,0x1fbc(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f4a:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f52:	8b b0 bc 1f 00 00    	mov    0x1fbc(%eax),%esi
f0100f58:	e9 01 fd ff ff       	jmp    f0100c5e <check_page_free_list+0x6d>

f0100f5d <page_init>:
{
f0100f5d:	55                   	push   %ebp
f0100f5e:	89 e5                	mov    %esp,%ebp
f0100f60:	57                   	push   %edi
f0100f61:	56                   	push   %esi
f0100f62:	53                   	push   %ebx
f0100f63:	83 ec 1c             	sub    $0x1c,%esp
f0100f66:	e8 6b f2 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f0100f6b:	81 c3 a1 63 01 00    	add    $0x163a1,%ebx
	page_free_list = NULL;
f0100f71:	c7 83 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%ebx)
f0100f78:	00 00 00 
	int nextfree = ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f0100f7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f80:	e8 51 fb ff ff       	call   f0100ad6 <boot_alloc>
f0100f85:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f8a:	c1 e8 0c             	shr    $0xc,%eax
f0100f8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pages[0].pp_ref = 1;
f0100f90:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
f0100f96:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		for(i=1; i < npages_basemem ; i++)
f0100f9c:	8b bb c0 1f 00 00    	mov    0x1fc0(%ebx),%edi
f0100fa2:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fa7:	be 00 00 00 00       	mov    $0x0,%esi
f0100fac:	b8 01 00 00 00       	mov    $0x1,%eax
f0100fb1:	eb 27                	jmp    f0100fda <page_init+0x7d>
f0100fb3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100fba:	89 d1                	mov    %edx,%ecx
f0100fbc:	03 8b ac 1f 00 00    	add    0x1fac(%ebx),%ecx
f0100fc2:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;
f0100fc8:	89 31                	mov    %esi,(%ecx)
			page_free_list = &pages[i];
f0100fca:	89 d6                	mov    %edx,%esi
f0100fcc:	03 b3 ac 1f 00 00    	add    0x1fac(%ebx),%esi
		for(i=1; i < npages_basemem ; i++)
f0100fd2:	83 c0 01             	add    $0x1,%eax
f0100fd5:	ba 01 00 00 00       	mov    $0x1,%edx
f0100fda:	39 c7                	cmp    %eax,%edi
f0100fdc:	77 d5                	ja     f0100fb3 <page_init+0x56>
f0100fde:	84 d2                	test   %dl,%dl
f0100fe0:	74 06                	je     f0100fe8 <page_init+0x8b>
f0100fe2:	89 b3 bc 1f 00 00    	mov    %esi,0x1fbc(%ebx)
			pages[i].pp_ref = 1;
f0100fe8:	8b 8b ac 1f 00 00    	mov    0x1fac(%ebx),%ecx
		for(i = npages_basemem ;  i < (EXTPHYSMEM-IOPHYSMEM)/PGSIZE + nextfree + npages_basemem ; i++)
f0100fee:	89 f8                	mov    %edi,%eax
f0100ff0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ff3:	8d 54 3a 60          	lea    0x60(%edx,%edi,1),%edx
f0100ff7:	eb 0a                	jmp    f0101003 <page_init+0xa6>
			pages[i].pp_ref = 1;
f0100ff9:	66 c7 44 c1 04 01 00 	movw   $0x1,0x4(%ecx,%eax,8)
		for(i = npages_basemem ;  i < (EXTPHYSMEM-IOPHYSMEM)/PGSIZE + nextfree + npages_basemem ; i++)
f0101000:	83 c0 01             	add    $0x1,%eax
f0101003:	39 c2                	cmp    %eax,%edx
f0101005:	77 f2                	ja     f0100ff9 <page_init+0x9c>
f0101007:	8b b3 bc 1f 00 00    	mov    0x1fbc(%ebx),%esi
f010100d:	ba 00 00 00 00       	mov    $0x0,%edx
		for(; i < npages ; i++)	 
f0101012:	bf 01 00 00 00       	mov    $0x1,%edi
f0101017:	eb 24                	jmp    f010103d <page_init+0xe0>
f0101019:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0101020:	89 d1                	mov    %edx,%ecx
f0101022:	03 8b ac 1f 00 00    	add    0x1fac(%ebx),%ecx
f0101028:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list; // next page free on page free list
f010102e:	89 31                	mov    %esi,(%ecx)
	 		page_free_list = &pages[i];	        //set free list on i-th page
f0101030:	89 d6                	mov    %edx,%esi
f0101032:	03 b3 ac 1f 00 00    	add    0x1fac(%ebx),%esi
		for(; i < npages ; i++)	 
f0101038:	83 c0 01             	add    $0x1,%eax
f010103b:	89 fa                	mov    %edi,%edx
f010103d:	39 83 b4 1f 00 00    	cmp    %eax,0x1fb4(%ebx)
f0101043:	77 d4                	ja     f0101019 <page_init+0xbc>
f0101045:	84 d2                	test   %dl,%dl
f0101047:	74 06                	je     f010104f <page_init+0xf2>
f0101049:	89 b3 bc 1f 00 00    	mov    %esi,0x1fbc(%ebx)
}
f010104f:	83 c4 1c             	add    $0x1c,%esp
f0101052:	5b                   	pop    %ebx
f0101053:	5e                   	pop    %esi
f0101054:	5f                   	pop    %edi
f0101055:	5d                   	pop    %ebp
f0101056:	c3                   	ret    

f0101057 <page_alloc>:
{
f0101057:	55                   	push   %ebp
f0101058:	89 e5                	mov    %esp,%ebp
f010105a:	56                   	push   %esi
f010105b:	53                   	push   %ebx
f010105c:	e8 75 f1 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f0101061:	81 c3 ab 62 01 00    	add    $0x162ab,%ebx
	if(page_free_list!=NULL)
f0101067:	8b b3 bc 1f 00 00    	mov    0x1fbc(%ebx),%esi
f010106d:	85 f6                	test   %esi,%esi
f010106f:	74 14                	je     f0101085 <page_alloc+0x2e>
	page_free_list=page_free_list->pp_link; // switch free page to next free page in memoroy 
f0101071:	8b 06                	mov    (%esi),%eax
f0101073:	89 83 bc 1f 00 00    	mov    %eax,0x1fbc(%ebx)
	new_page->pp_link=NULL;
f0101079:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(alloc_flags & ALLOC_ZERO)
f010107f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101083:	75 09                	jne    f010108e <page_alloc+0x37>
}
f0101085:	89 f0                	mov    %esi,%eax
f0101087:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010108a:	5b                   	pop    %ebx
f010108b:	5e                   	pop    %esi
f010108c:	5d                   	pop    %ebp
f010108d:	c3                   	ret    
f010108e:	89 f0                	mov    %esi,%eax
f0101090:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101096:	c1 f8 03             	sar    $0x3,%eax
f0101099:	89 c2                	mov    %eax,%edx
f010109b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010109e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01010a3:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f01010a9:	73 1b                	jae    f01010c6 <page_alloc+0x6f>
		memset(page2kva(new_page),0,PGSIZE);
f01010ab:	83 ec 04             	sub    $0x4,%esp
f01010ae:	68 00 10 00 00       	push   $0x1000
f01010b3:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010b5:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01010bb:	52                   	push   %edx
f01010bc:	e8 bb 2c 00 00       	call   f0103d7c <memset>
f01010c1:	83 c4 10             	add    $0x10,%esp
return new_page;
f01010c4:	eb bf                	jmp    f0101085 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010c6:	52                   	push   %edx
f01010c7:	8d 83 50 d4 fe ff    	lea    -0x12bb0(%ebx),%eax
f01010cd:	50                   	push   %eax
f01010ce:	6a 55                	push   $0x55
f01010d0:	8d 83 c8 db fe ff    	lea    -0x12438(%ebx),%eax
f01010d6:	50                   	push   %eax
f01010d7:	e8 44 f0 ff ff       	call   f0100120 <_panic>

f01010dc <page_free>:
{
f01010dc:	55                   	push   %ebp
f01010dd:	89 e5                	mov    %esp,%ebp
f01010df:	53                   	push   %ebx
f01010e0:	83 ec 04             	sub    $0x4,%esp
f01010e3:	e8 ee f0 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f01010e8:	81 c3 24 62 01 00    	add    $0x16224,%ebx
f01010ee:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp);
f01010f1:	85 c0                	test   %eax,%eax
f01010f3:	74 1f                	je     f0101114 <page_free+0x38>
	assert(pp->pp_ref == 0);
f01010f5:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010fa:	75 37                	jne    f0101133 <page_free+0x57>
	assert(pp->pp_link == NULL);
f01010fc:	83 38 00             	cmpl   $0x0,(%eax)
f01010ff:	75 51                	jne    f0101152 <page_free+0x76>
	pp->pp_link = page_free_list;
f0101101:	8b 8b bc 1f 00 00    	mov    0x1fbc(%ebx),%ecx
f0101107:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f0101109:	89 83 bc 1f 00 00    	mov    %eax,0x1fbc(%ebx)
}
f010110f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101112:	c9                   	leave  
f0101113:	c3                   	ret    
	assert(pp);
f0101114:	8d 83 bb dd fe ff    	lea    -0x12245(%ebx),%eax
f010111a:	50                   	push   %eax
f010111b:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0101121:	50                   	push   %eax
f0101122:	68 9c 01 00 00       	push   $0x19c
f0101127:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010112d:	50                   	push   %eax
f010112e:	e8 ed ef ff ff       	call   f0100120 <_panic>
	assert(pp->pp_ref == 0);
f0101133:	8d 83 72 dc fe ff    	lea    -0x1238e(%ebx),%eax
f0101139:	50                   	push   %eax
f010113a:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0101140:	50                   	push   %eax
f0101141:	68 9d 01 00 00       	push   $0x19d
f0101146:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010114c:	50                   	push   %eax
f010114d:	e8 ce ef ff ff       	call   f0100120 <_panic>
	assert(pp->pp_link == NULL);
f0101152:	8d 83 82 dc fe ff    	lea    -0x1237e(%ebx),%eax
f0101158:	50                   	push   %eax
f0101159:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010115f:	50                   	push   %eax
f0101160:	68 9e 01 00 00       	push   $0x19e
f0101165:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010116b:	50                   	push   %eax
f010116c:	e8 af ef ff ff       	call   f0100120 <_panic>

f0101171 <page_decref>:
{
f0101171:	55                   	push   %ebp
f0101172:	89 e5                	mov    %esp,%ebp
f0101174:	83 ec 08             	sub    $0x8,%esp
f0101177:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010117a:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010117e:	83 e8 01             	sub    $0x1,%eax
f0101181:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101185:	66 85 c0             	test   %ax,%ax
f0101188:	74 02                	je     f010118c <page_decref+0x1b>
}
f010118a:	c9                   	leave  
f010118b:	c3                   	ret    
		page_free(pp);
f010118c:	83 ec 0c             	sub    $0xc,%esp
f010118f:	52                   	push   %edx
f0101190:	e8 47 ff ff ff       	call   f01010dc <page_free>
f0101195:	83 c4 10             	add    $0x10,%esp
}
f0101198:	eb f0                	jmp    f010118a <page_decref+0x19>

f010119a <pgdir_walk>:
{
f010119a:	55                   	push   %ebp
f010119b:	89 e5                	mov    %esp,%ebp
f010119d:	57                   	push   %edi
f010119e:	56                   	push   %esi
f010119f:	53                   	push   %ebx
f01011a0:	83 ec 0c             	sub    $0xc,%esp
f01011a3:	e8 30 1f 00 00       	call   f01030d8 <__x86.get_pc_thunk.di>
f01011a8:	81 c7 64 61 01 00    	add    $0x16164,%edi
f01011ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01011b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	assert(pgdir!=NULL); // panic if pgdir is NULL pointer
f01011b4:	85 c0                	test   %eax,%eax
f01011b6:	74 6b                	je     f0101223 <pgdir_walk+0x89>
	pointer_table_page_index=&pgdir[PDX(va)]; // point at page directory index adress
f01011b8:	89 da                	mov    %ebx,%edx
f01011ba:	c1 ea 16             	shr    $0x16,%edx
f01011bd:	8d 34 90             	lea    (%eax,%edx,4),%esi
	if( !(*pointer_table_page_index & PTE_P) )   // see if PTE_P (present ) and pte index exist
f01011c0:	f6 06 01             	testb  $0x1,(%esi)
f01011c3:	75 31                	jne    f01011f6 <pgdir_walk+0x5c>
		if(!create)
f01011c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011c9:	0f 84 90 00 00 00    	je     f010125f <pgdir_walk+0xc5>
	new_page=page_alloc(ALLOC_ZERO);    // return physical page adress
f01011cf:	83 ec 0c             	sub    $0xc,%esp
f01011d2:	6a 01                	push   $0x1
f01011d4:	e8 7e fe ff ff       	call   f0101057 <page_alloc>
	if(new_page==NULL) // alloc not succesful 
f01011d9:	83 c4 10             	add    $0x10,%esp
f01011dc:	85 c0                	test   %eax,%eax
f01011de:	74 3b                	je     f010121b <pgdir_walk+0x81>
	new_page->pp_ref++;  // add reference to new physicial page
f01011e0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f01011e5:	2b 87 ac 1f 00 00    	sub    0x1fac(%edi),%eax
f01011eb:	c1 f8 03             	sar    $0x3,%eax
f01011ee:	c1 e0 0c             	shl    $0xc,%eax
	*pointer_table_page_index=(page2pa(new_page) | PTE_P | PTE_U | PTE_W ); // page2pa returns va of page // prezent, read, user flags		
f01011f1:	83 c8 07             	or     $0x7,%eax
f01011f4:	89 06                	mov    %eax,(%esi)
	page_table=KADDR(PTE_ADDR(*pointer_table_page_index));  // virutal adress of adress in page directory entry
f01011f6:	8b 06                	mov    (%esi),%eax
f01011f8:	89 c2                	mov    %eax,%edx
f01011fa:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101200:	c1 e8 0c             	shr    $0xc,%eax
f0101203:	3b 87 b4 1f 00 00    	cmp    0x1fb4(%edi),%eax
f0101209:	73 39                	jae    f0101244 <pgdir_walk+0xaa>
	return &page_table[PTX(va)] ; // return index of page table
f010120b:	c1 eb 0a             	shr    $0xa,%ebx
f010120e:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101214:	8d 84 1a 00 00 00 f0 	lea    -0x10000000(%edx,%ebx,1),%eax
}
f010121b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010121e:	5b                   	pop    %ebx
f010121f:	5e                   	pop    %esi
f0101220:	5f                   	pop    %edi
f0101221:	5d                   	pop    %ebp
f0101222:	c3                   	ret    
	assert(pgdir!=NULL); // panic if pgdir is NULL pointer
f0101223:	8d 87 96 dc fe ff    	lea    -0x1236a(%edi),%eax
f0101229:	50                   	push   %eax
f010122a:	8d 87 e2 db fe ff    	lea    -0x1241e(%edi),%eax
f0101230:	50                   	push   %eax
f0101231:	68 cd 01 00 00       	push   $0x1cd
f0101236:	8d 87 a1 db fe ff    	lea    -0x1245f(%edi),%eax
f010123c:	50                   	push   %eax
f010123d:	89 fb                	mov    %edi,%ebx
f010123f:	e8 dc ee ff ff       	call   f0100120 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101244:	52                   	push   %edx
f0101245:	8d 87 50 d4 fe ff    	lea    -0x12bb0(%edi),%eax
f010124b:	50                   	push   %eax
f010124c:	68 e5 01 00 00       	push   $0x1e5
f0101251:	8d 87 a1 db fe ff    	lea    -0x1245f(%edi),%eax
f0101257:	50                   	push   %eax
f0101258:	89 fb                	mov    %edi,%ebx
f010125a:	e8 c1 ee ff ff       	call   f0100120 <_panic>
		return NULL;
f010125f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101264:	eb b5                	jmp    f010121b <pgdir_walk+0x81>

f0101266 <boot_map_region>:
{
f0101266:	55                   	push   %ebp
f0101267:	89 e5                	mov    %esp,%ebp
f0101269:	57                   	push   %edi
f010126a:	56                   	push   %esi
f010126b:	53                   	push   %ebx
f010126c:	83 ec 1c             	sub    $0x1c,%esp
f010126f:	e8 64 1e 00 00       	call   f01030d8 <__x86.get_pc_thunk.di>
f0101274:	81 c7 98 60 01 00    	add    $0x16098,%edi
f010127a:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010127d:	89 c7                	mov    %eax,%edi
f010127f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101282:	89 ce                	mov    %ecx,%esi
	for(i=0; i< size ; i+=PGSIZE)
f0101284:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101289:	39 f3                	cmp    %esi,%ebx
f010128b:	73 51                	jae    f01012de <boot_map_region+0x78>
		page_table_entry = pgdir_walk(pgdir, (void*)(va+i), 1);
f010128d:	83 ec 04             	sub    $0x4,%esp
f0101290:	6a 01                	push   $0x1
f0101292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101295:	01 d8                	add    %ebx,%eax
f0101297:	50                   	push   %eax
f0101298:	57                   	push   %edi
f0101299:	e8 fc fe ff ff       	call   f010119a <pgdir_walk>
f010129e:	89 c2                	mov    %eax,%edx
		assert(page_table_entry != NULL);     // panic if zero
f01012a0:	83 c4 10             	add    $0x10,%esp
f01012a3:	85 c0                	test   %eax,%eax
f01012a5:	74 15                	je     f01012bc <boot_map_region+0x56>
		*page_table_entry=((pa+i)|PTE_P|perm);
f01012a7:	89 d8                	mov    %ebx,%eax
f01012a9:	03 45 08             	add    0x8(%ebp),%eax
f01012ac:	0b 45 0c             	or     0xc(%ebp),%eax
f01012af:	83 c8 01             	or     $0x1,%eax
f01012b2:	89 02                	mov    %eax,(%edx)
	for(i=0; i< size ; i+=PGSIZE)
f01012b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01012ba:	eb cd                	jmp    f0101289 <boot_map_region+0x23>
		assert(page_table_entry != NULL);     // panic if zero
f01012bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01012bf:	8d 83 a2 dc fe ff    	lea    -0x1235e(%ebx),%eax
f01012c5:	50                   	push   %eax
f01012c6:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01012cc:	50                   	push   %eax
f01012cd:	68 04 02 00 00       	push   $0x204
f01012d2:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01012d8:	50                   	push   %eax
f01012d9:	e8 42 ee ff ff       	call   f0100120 <_panic>
}
f01012de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012e1:	5b                   	pop    %ebx
f01012e2:	5e                   	pop    %esi
f01012e3:	5f                   	pop    %edi
f01012e4:	5d                   	pop    %ebp
f01012e5:	c3                   	ret    

f01012e6 <page_lookup>:
{
f01012e6:	55                   	push   %ebp
f01012e7:	89 e5                	mov    %esp,%ebp
f01012e9:	56                   	push   %esi
f01012ea:	53                   	push   %ebx
f01012eb:	e8 7c f4 ff ff       	call   f010076c <__x86.get_pc_thunk.si>
f01012f0:	81 c6 1c 60 01 00    	add    $0x1601c,%esi
f01012f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	entry_of_page_table=pgdir_walk(pgdir,va,0);
f01012f9:	83 ec 04             	sub    $0x4,%esp
f01012fc:	6a 00                	push   $0x0
f01012fe:	ff 75 0c             	push   0xc(%ebp)
f0101301:	ff 75 08             	push   0x8(%ebp)
f0101304:	e8 91 fe ff ff       	call   f010119a <pgdir_walk>
	if(pte_store)
f0101309:	83 c4 10             	add    $0x10,%esp
f010130c:	85 db                	test   %ebx,%ebx
f010130e:	74 02                	je     f0101312 <page_lookup+0x2c>
		*pte_store=entry_of_page_table;
f0101310:	89 03                	mov    %eax,(%ebx)
	if(entry_of_page_table && (*entry_of_page_table & PTE_P))
f0101312:	85 c0                	test   %eax,%eax
f0101314:	74 0c                	je     f0101322 <page_lookup+0x3c>
f0101316:	8b 10                	mov    (%eax),%edx
	return NULL;
f0101318:	b8 00 00 00 00       	mov    $0x0,%eax
	if(entry_of_page_table && (*entry_of_page_table & PTE_P))
f010131d:	f6 c2 01             	test   $0x1,%dl
f0101320:	75 07                	jne    f0101329 <page_lookup+0x43>
}
f0101322:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101325:	5b                   	pop    %ebx
f0101326:	5e                   	pop    %esi
f0101327:	5d                   	pop    %ebp
f0101328:	c3                   	ret    
f0101329:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010132c:	39 96 b4 1f 00 00    	cmp    %edx,0x1fb4(%esi)
f0101332:	76 0b                	jbe    f010133f <page_lookup+0x59>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101334:	8b 86 ac 1f 00 00    	mov    0x1fac(%esi),%eax
f010133a:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return pa2page( PTE_ADDR(*entry_of_page_table) ); // zero last 12 f MSB t LSB & retrun pg number of VA
f010133d:	eb e3                	jmp    f0101322 <page_lookup+0x3c>
		panic("pa2page called with invalid pa");
f010133f:	83 ec 04             	sub    $0x4,%esp
f0101342:	8d 86 5c d5 fe ff    	lea    -0x12aa4(%esi),%eax
f0101348:	50                   	push   %eax
f0101349:	6a 4e                	push   $0x4e
f010134b:	8d 86 c8 db fe ff    	lea    -0x12438(%esi),%eax
f0101351:	50                   	push   %eax
f0101352:	89 f3                	mov    %esi,%ebx
f0101354:	e8 c7 ed ff ff       	call   f0100120 <_panic>

f0101359 <page_remove>:
{
f0101359:	55                   	push   %ebp
f010135a:	89 e5                	mov    %esp,%ebp
f010135c:	53                   	push   %ebx
f010135d:	83 ec 18             	sub    $0x18,%esp
f0101360:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	page = page_lookup(pgdir, va, &entry_of_page_table);
f0101363:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101366:	50                   	push   %eax
f0101367:	53                   	push   %ebx
f0101368:	ff 75 08             	push   0x8(%ebp)
f010136b:	e8 76 ff ff ff       	call   f01012e6 <page_lookup>
	if (page == NULL)
f0101370:	83 c4 10             	add    $0x10,%esp
f0101373:	85 c0                	test   %eax,%eax
f0101375:	74 18                	je     f010138f <page_remove+0x36>
	*entry_of_page_table = 0;
f0101377:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010137a:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(page);
f0101380:	83 ec 0c             	sub    $0xc,%esp
f0101383:	50                   	push   %eax
f0101384:	e8 e8 fd ff ff       	call   f0101171 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101389:	0f 01 3b             	invlpg (%ebx)
f010138c:	83 c4 10             	add    $0x10,%esp
}
f010138f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101392:	c9                   	leave  
f0101393:	c3                   	ret    

f0101394 <page_insert>:
{
f0101394:	55                   	push   %ebp
f0101395:	89 e5                	mov    %esp,%ebp
f0101397:	57                   	push   %edi
f0101398:	56                   	push   %esi
f0101399:	53                   	push   %ebx
f010139a:	83 ec 10             	sub    $0x10,%esp
f010139d:	e8 36 1d 00 00       	call   f01030d8 <__x86.get_pc_thunk.di>
f01013a2:	81 c7 6a 5f 01 00    	add    $0x15f6a,%edi
f01013a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pyhsical_page_entry = pgdir_walk(pgdir,va,1); // return me adress of page entry of new page
f01013ab:	6a 01                	push   $0x1
f01013ad:	ff 75 10             	push   0x10(%ebp)
f01013b0:	ff 75 08             	push   0x8(%ebp)
f01013b3:	e8 e2 fd ff ff       	call   f010119a <pgdir_walk>
	if(pyhsical_page_entry==NULL)
f01013b8:	83 c4 10             	add    $0x10,%esp
f01013bb:	85 c0                	test   %eax,%eax
f01013bd:	74 40                	je     f01013ff <page_insert+0x6b>
f01013bf:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01013c1:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if(PTE_P & *pyhsical_page_entry) // remove if exists
f01013c6:	f6 00 01             	testb  $0x1,(%eax)
f01013c9:	75 21                	jne    f01013ec <page_insert+0x58>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f01013cb:	2b 9f ac 1f 00 00    	sub    0x1fac(%edi),%ebx
f01013d1:	c1 fb 03             	sar    $0x3,%ebx
f01013d4:	c1 e3 0c             	shl    $0xc,%ebx
	*pyhsical_page_entry=(page2pa(pp) | perm | PTE_P); // set permissions of page table entry
f01013d7:	0b 5d 14             	or     0x14(%ebp),%ebx
f01013da:	83 cb 01             	or     $0x1,%ebx
f01013dd:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01013df:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013e7:	5b                   	pop    %ebx
f01013e8:	5e                   	pop    %esi
f01013e9:	5f                   	pop    %edi
f01013ea:	5d                   	pop    %ebp
f01013eb:	c3                   	ret    
	page_remove(pgdir,va);	
f01013ec:	83 ec 08             	sub    $0x8,%esp
f01013ef:	ff 75 10             	push   0x10(%ebp)
f01013f2:	ff 75 08             	push   0x8(%ebp)
f01013f5:	e8 5f ff ff ff       	call   f0101359 <page_remove>
f01013fa:	83 c4 10             	add    $0x10,%esp
f01013fd:	eb cc                	jmp    f01013cb <page_insert+0x37>
		return -E_NO_MEM;
f01013ff:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101404:	eb de                	jmp    f01013e4 <page_insert+0x50>

f0101406 <mem_init>:
{
f0101406:	55                   	push   %ebp
f0101407:	89 e5                	mov    %esp,%ebp
f0101409:	57                   	push   %edi
f010140a:	56                   	push   %esi
f010140b:	53                   	push   %ebx
f010140c:	83 ec 3c             	sub    $0x3c,%esp
f010140f:	e8 54 f3 ff ff       	call   f0100768 <__x86.get_pc_thunk.ax>
f0101414:	05 f8 5e 01 00       	add    $0x15ef8,%eax
f0101419:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f010141c:	b8 15 00 00 00       	mov    $0x15,%eax
f0101421:	e8 7a f6 ff ff       	call   f0100aa0 <nvram_read>
f0101426:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101428:	b8 17 00 00 00       	mov    $0x17,%eax
f010142d:	e8 6e f6 ff ff       	call   f0100aa0 <nvram_read>
f0101432:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101434:	b8 34 00 00 00       	mov    $0x34,%eax
f0101439:	e8 62 f6 ff ff       	call   f0100aa0 <nvram_read>
	if (ext16mem)
f010143e:	c1 e0 06             	shl    $0x6,%eax
f0101441:	0f 84 cb 00 00 00    	je     f0101512 <mem_init+0x10c>
		totalmem = 16 * 1024 + ext16mem;
f0101447:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f010144c:	89 c2                	mov    %eax,%edx
f010144e:	c1 ea 02             	shr    $0x2,%edx
f0101451:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101454:	89 91 b4 1f 00 00    	mov    %edx,0x1fb4(%ecx)
	npages_basemem = basemem / (PGSIZE / 1024);
f010145a:	89 da                	mov    %ebx,%edx
f010145c:	c1 ea 02             	shr    $0x2,%edx
f010145f:	89 91 c0 1f 00 00    	mov    %edx,0x1fc0(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101465:	89 c2                	mov    %eax,%edx
f0101467:	29 da                	sub    %ebx,%edx
f0101469:	52                   	push   %edx
f010146a:	53                   	push   %ebx
f010146b:	50                   	push   %eax
f010146c:	8d 81 7c d5 fe ff    	lea    -0x12a84(%ecx),%eax
f0101472:	50                   	push   %eax
f0101473:	89 cb                	mov    %ecx,%ebx
f0101475:	e8 e9 1c 00 00       	call   f0103163 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010147a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010147f:	e8 52 f6 ff ff       	call   f0100ad6 <boot_alloc>
f0101484:	89 83 b0 1f 00 00    	mov    %eax,0x1fb0(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f010148a:	83 c4 0c             	add    $0xc,%esp
f010148d:	68 00 10 00 00       	push   $0x1000
f0101492:	6a 00                	push   $0x0
f0101494:	50                   	push   %eax
f0101495:	e8 e2 28 00 00       	call   f0103d7c <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P ;
f010149a:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01014a0:	83 c4 10             	add    $0x10,%esp
f01014a3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014a8:	76 78                	jbe    f0101522 <mem_init+0x11c>
	return (physaddr_t)kva - KERNBASE;
f01014aa:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014b0:	83 ca 05             	or     $0x5,%edx
f01014b3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01014b9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01014bc:	8b 87 b4 1f 00 00    	mov    0x1fb4(%edi),%eax
f01014c2:	c1 e0 03             	shl    $0x3,%eax
f01014c5:	e8 0c f6 ff ff       	call   f0100ad6 <boot_alloc>
f01014ca:	89 87 ac 1f 00 00    	mov    %eax,0x1fac(%edi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01014d0:	83 ec 04             	sub    $0x4,%esp
f01014d3:	8b 97 b4 1f 00 00    	mov    0x1fb4(%edi),%edx
f01014d9:	c1 e2 03             	shl    $0x3,%edx
f01014dc:	52                   	push   %edx
f01014dd:	6a 00                	push   $0x0
f01014df:	50                   	push   %eax
f01014e0:	89 fb                	mov    %edi,%ebx
f01014e2:	e8 95 28 00 00       	call   f0103d7c <memset>
	page_init();
f01014e7:	e8 71 fa ff ff       	call   f0100f5d <page_init>
	check_page_free_list(1);
f01014ec:	b8 01 00 00 00       	mov    $0x1,%eax
f01014f1:	e8 fb f6 ff ff       	call   f0100bf1 <check_page_free_list>
	if (!pages)
f01014f6:	83 c4 10             	add    $0x10,%esp
f01014f9:	83 bf ac 1f 00 00 00 	cmpl   $0x0,0x1fac(%edi)
f0101500:	74 3c                	je     f010153e <mem_init+0x138>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101502:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101505:	8b 80 bc 1f 00 00    	mov    0x1fbc(%eax),%eax
f010150b:	be 00 00 00 00       	mov    $0x0,%esi
f0101510:	eb 4f                	jmp    f0101561 <mem_init+0x15b>
		totalmem = 1 * 1024 + extmem;
f0101512:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101518:	85 f6                	test   %esi,%esi
f010151a:	0f 44 c3             	cmove  %ebx,%eax
f010151d:	e9 2a ff ff ff       	jmp    f010144c <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101522:	50                   	push   %eax
f0101523:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101526:	8d 83 2c d4 fe ff    	lea    -0x12bd4(%ebx),%eax
f010152c:	50                   	push   %eax
f010152d:	68 91 00 00 00       	push   $0x91
f0101532:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0101538:	50                   	push   %eax
f0101539:	e8 e2 eb ff ff       	call   f0100120 <_panic>
		panic("'pages' is a null pointer!");
f010153e:	83 ec 04             	sub    $0x4,%esp
f0101541:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101544:	8d 83 bb dc fe ff    	lea    -0x12345(%ebx),%eax
f010154a:	50                   	push   %eax
f010154b:	68 d5 02 00 00       	push   $0x2d5
f0101550:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0101556:	50                   	push   %eax
f0101557:	e8 c4 eb ff ff       	call   f0100120 <_panic>
		++nfree;
f010155c:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010155f:	8b 00                	mov    (%eax),%eax
f0101561:	85 c0                	test   %eax,%eax
f0101563:	75 f7                	jne    f010155c <mem_init+0x156>
	assert((pp0 = page_alloc(0)));
f0101565:	83 ec 0c             	sub    $0xc,%esp
f0101568:	6a 00                	push   $0x0
f010156a:	e8 e8 fa ff ff       	call   f0101057 <page_alloc>
f010156f:	89 c3                	mov    %eax,%ebx
f0101571:	83 c4 10             	add    $0x10,%esp
f0101574:	85 c0                	test   %eax,%eax
f0101576:	0f 84 3a 02 00 00    	je     f01017b6 <mem_init+0x3b0>
	assert((pp1 = page_alloc(0)));
f010157c:	83 ec 0c             	sub    $0xc,%esp
f010157f:	6a 00                	push   $0x0
f0101581:	e8 d1 fa ff ff       	call   f0101057 <page_alloc>
f0101586:	89 c7                	mov    %eax,%edi
f0101588:	83 c4 10             	add    $0x10,%esp
f010158b:	85 c0                	test   %eax,%eax
f010158d:	0f 84 45 02 00 00    	je     f01017d8 <mem_init+0x3d2>
	assert((pp2 = page_alloc(0)));
f0101593:	83 ec 0c             	sub    $0xc,%esp
f0101596:	6a 00                	push   $0x0
f0101598:	e8 ba fa ff ff       	call   f0101057 <page_alloc>
f010159d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01015a0:	83 c4 10             	add    $0x10,%esp
f01015a3:	85 c0                	test   %eax,%eax
f01015a5:	0f 84 4f 02 00 00    	je     f01017fa <mem_init+0x3f4>
	assert(pp1 && pp1 != pp0);
f01015ab:	39 fb                	cmp    %edi,%ebx
f01015ad:	0f 84 69 02 00 00    	je     f010181c <mem_init+0x416>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015b6:	39 c7                	cmp    %eax,%edi
f01015b8:	0f 84 80 02 00 00    	je     f010183e <mem_init+0x438>
f01015be:	39 c3                	cmp    %eax,%ebx
f01015c0:	0f 84 78 02 00 00    	je     f010183e <mem_init+0x438>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f01015c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015c9:	8b 88 ac 1f 00 00    	mov    0x1fac(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015cf:	8b 90 b4 1f 00 00    	mov    0x1fb4(%eax),%edx
f01015d5:	c1 e2 0c             	shl    $0xc,%edx
f01015d8:	89 d8                	mov    %ebx,%eax
f01015da:	29 c8                	sub    %ecx,%eax
f01015dc:	c1 f8 03             	sar    $0x3,%eax
f01015df:	c1 e0 0c             	shl    $0xc,%eax
f01015e2:	39 d0                	cmp    %edx,%eax
f01015e4:	0f 83 76 02 00 00    	jae    f0101860 <mem_init+0x45a>
f01015ea:	89 f8                	mov    %edi,%eax
f01015ec:	29 c8                	sub    %ecx,%eax
f01015ee:	c1 f8 03             	sar    $0x3,%eax
f01015f1:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01015f4:	39 c2                	cmp    %eax,%edx
f01015f6:	0f 86 86 02 00 00    	jbe    f0101882 <mem_init+0x47c>
f01015fc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015ff:	29 c8                	sub    %ecx,%eax
f0101601:	c1 f8 03             	sar    $0x3,%eax
f0101604:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101607:	39 c2                	cmp    %eax,%edx
f0101609:	0f 86 95 02 00 00    	jbe    f01018a4 <mem_init+0x49e>
	fl = page_free_list;
f010160f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101612:	8b 88 bc 1f 00 00    	mov    0x1fbc(%eax),%ecx
f0101618:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f010161b:	c7 80 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%eax)
f0101622:	00 00 00 
	assert(!page_alloc(0));
f0101625:	83 ec 0c             	sub    $0xc,%esp
f0101628:	6a 00                	push   $0x0
f010162a:	e8 28 fa ff ff       	call   f0101057 <page_alloc>
f010162f:	83 c4 10             	add    $0x10,%esp
f0101632:	85 c0                	test   %eax,%eax
f0101634:	0f 85 8c 02 00 00    	jne    f01018c6 <mem_init+0x4c0>
	page_free(pp0);
f010163a:	83 ec 0c             	sub    $0xc,%esp
f010163d:	53                   	push   %ebx
f010163e:	e8 99 fa ff ff       	call   f01010dc <page_free>
	page_free(pp1);
f0101643:	89 3c 24             	mov    %edi,(%esp)
f0101646:	e8 91 fa ff ff       	call   f01010dc <page_free>
	page_free(pp2);
f010164b:	83 c4 04             	add    $0x4,%esp
f010164e:	ff 75 d0             	push   -0x30(%ebp)
f0101651:	e8 86 fa ff ff       	call   f01010dc <page_free>
	assert((pp0 = page_alloc(0)));
f0101656:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010165d:	e8 f5 f9 ff ff       	call   f0101057 <page_alloc>
f0101662:	89 c7                	mov    %eax,%edi
f0101664:	83 c4 10             	add    $0x10,%esp
f0101667:	85 c0                	test   %eax,%eax
f0101669:	0f 84 79 02 00 00    	je     f01018e8 <mem_init+0x4e2>
	assert((pp1 = page_alloc(0)));
f010166f:	83 ec 0c             	sub    $0xc,%esp
f0101672:	6a 00                	push   $0x0
f0101674:	e8 de f9 ff ff       	call   f0101057 <page_alloc>
f0101679:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010167c:	83 c4 10             	add    $0x10,%esp
f010167f:	85 c0                	test   %eax,%eax
f0101681:	0f 84 83 02 00 00    	je     f010190a <mem_init+0x504>
	assert((pp2 = page_alloc(0)));
f0101687:	83 ec 0c             	sub    $0xc,%esp
f010168a:	6a 00                	push   $0x0
f010168c:	e8 c6 f9 ff ff       	call   f0101057 <page_alloc>
f0101691:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101694:	83 c4 10             	add    $0x10,%esp
f0101697:	85 c0                	test   %eax,%eax
f0101699:	0f 84 8d 02 00 00    	je     f010192c <mem_init+0x526>
	assert(pp1 && pp1 != pp0);
f010169f:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f01016a2:	0f 84 a6 02 00 00    	je     f010194e <mem_init+0x548>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016a8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01016ab:	39 c7                	cmp    %eax,%edi
f01016ad:	0f 84 bd 02 00 00    	je     f0101970 <mem_init+0x56a>
f01016b3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01016b6:	0f 84 b4 02 00 00    	je     f0101970 <mem_init+0x56a>
	assert(!page_alloc(0));
f01016bc:	83 ec 0c             	sub    $0xc,%esp
f01016bf:	6a 00                	push   $0x0
f01016c1:	e8 91 f9 ff ff       	call   f0101057 <page_alloc>
f01016c6:	83 c4 10             	add    $0x10,%esp
f01016c9:	85 c0                	test   %eax,%eax
f01016cb:	0f 85 c1 02 00 00    	jne    f0101992 <mem_init+0x58c>
f01016d1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01016d4:	89 f8                	mov    %edi,%eax
f01016d6:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f01016dc:	c1 f8 03             	sar    $0x3,%eax
f01016df:	89 c2                	mov    %eax,%edx
f01016e1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016e4:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01016e9:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f01016ef:	0f 83 bf 02 00 00    	jae    f01019b4 <mem_init+0x5ae>
	memset(page2kva(pp0), 1, PGSIZE);
f01016f5:	83 ec 04             	sub    $0x4,%esp
f01016f8:	68 00 10 00 00       	push   $0x1000
f01016fd:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01016ff:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101705:	52                   	push   %edx
f0101706:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101709:	e8 6e 26 00 00       	call   f0103d7c <memset>
	page_free(pp0);
f010170e:	89 3c 24             	mov    %edi,(%esp)
f0101711:	e8 c6 f9 ff ff       	call   f01010dc <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101716:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010171d:	e8 35 f9 ff ff       	call   f0101057 <page_alloc>
f0101722:	83 c4 10             	add    $0x10,%esp
f0101725:	85 c0                	test   %eax,%eax
f0101727:	0f 84 9f 02 00 00    	je     f01019cc <mem_init+0x5c6>
	assert(pp && pp0 == pp);
f010172d:	39 c7                	cmp    %eax,%edi
f010172f:	0f 85 b9 02 00 00    	jne    f01019ee <mem_init+0x5e8>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0101735:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101738:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f010173e:	c1 f8 03             	sar    $0x3,%eax
f0101741:	89 c2                	mov    %eax,%edx
f0101743:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101746:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010174b:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0101751:	0f 83 b9 02 00 00    	jae    f0101a10 <mem_init+0x60a>
	return (void *)(pa + KERNBASE);
f0101757:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010175d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101763:	80 38 00             	cmpb   $0x0,(%eax)
f0101766:	0f 85 bc 02 00 00    	jne    f0101a28 <mem_init+0x622>
	for (i = 0; i < PGSIZE; i++)
f010176c:	83 c0 01             	add    $0x1,%eax
f010176f:	39 c2                	cmp    %eax,%edx
f0101771:	75 f0                	jne    f0101763 <mem_init+0x35d>
	page_free_list = fl;
f0101773:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101776:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101779:	89 8b bc 1f 00 00    	mov    %ecx,0x1fbc(%ebx)
	page_free(pp0);
f010177f:	83 ec 0c             	sub    $0xc,%esp
f0101782:	57                   	push   %edi
f0101783:	e8 54 f9 ff ff       	call   f01010dc <page_free>
	page_free(pp1);
f0101788:	83 c4 04             	add    $0x4,%esp
f010178b:	ff 75 d0             	push   -0x30(%ebp)
f010178e:	e8 49 f9 ff ff       	call   f01010dc <page_free>
	page_free(pp2);
f0101793:	83 c4 04             	add    $0x4,%esp
f0101796:	ff 75 cc             	push   -0x34(%ebp)
f0101799:	e8 3e f9 ff ff       	call   f01010dc <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010179e:	8b 83 bc 1f 00 00    	mov    0x1fbc(%ebx),%eax
f01017a4:	83 c4 10             	add    $0x10,%esp
f01017a7:	85 c0                	test   %eax,%eax
f01017a9:	0f 84 9b 02 00 00    	je     f0101a4a <mem_init+0x644>
		--nfree;
f01017af:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017b2:	8b 00                	mov    (%eax),%eax
f01017b4:	eb f1                	jmp    f01017a7 <mem_init+0x3a1>
	assert((pp0 = page_alloc(0)));
f01017b6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017b9:	8d 83 d6 dc fe ff    	lea    -0x1232a(%ebx),%eax
f01017bf:	50                   	push   %eax
f01017c0:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01017c6:	50                   	push   %eax
f01017c7:	68 dd 02 00 00       	push   $0x2dd
f01017cc:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01017d2:	50                   	push   %eax
f01017d3:	e8 48 e9 ff ff       	call   f0100120 <_panic>
	assert((pp1 = page_alloc(0)));
f01017d8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017db:	8d 83 ec dc fe ff    	lea    -0x12314(%ebx),%eax
f01017e1:	50                   	push   %eax
f01017e2:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01017e8:	50                   	push   %eax
f01017e9:	68 de 02 00 00       	push   $0x2de
f01017ee:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01017f4:	50                   	push   %eax
f01017f5:	e8 26 e9 ff ff       	call   f0100120 <_panic>
	assert((pp2 = page_alloc(0)));
f01017fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017fd:	8d 83 02 dd fe ff    	lea    -0x122fe(%ebx),%eax
f0101803:	50                   	push   %eax
f0101804:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010180a:	50                   	push   %eax
f010180b:	68 df 02 00 00       	push   $0x2df
f0101810:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0101816:	50                   	push   %eax
f0101817:	e8 04 e9 ff ff       	call   f0100120 <_panic>
	assert(pp1 && pp1 != pp0);
f010181c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010181f:	8d 83 18 dd fe ff    	lea    -0x122e8(%ebx),%eax
f0101825:	50                   	push   %eax
f0101826:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010182c:	50                   	push   %eax
f010182d:	68 e2 02 00 00       	push   $0x2e2
f0101832:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0101838:	50                   	push   %eax
f0101839:	e8 e2 e8 ff ff       	call   f0100120 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010183e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101841:	8d 83 b8 d5 fe ff    	lea    -0x12a48(%ebx),%eax
f0101847:	50                   	push   %eax
f0101848:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010184e:	50                   	push   %eax
f010184f:	68 e3 02 00 00       	push   $0x2e3
f0101854:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010185a:	50                   	push   %eax
f010185b:	e8 c0 e8 ff ff       	call   f0100120 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101860:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101863:	8d 83 2a dd fe ff    	lea    -0x122d6(%ebx),%eax
f0101869:	50                   	push   %eax
f010186a:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0101870:	50                   	push   %eax
f0101871:	68 e4 02 00 00       	push   $0x2e4
f0101876:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010187c:	50                   	push   %eax
f010187d:	e8 9e e8 ff ff       	call   f0100120 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101882:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101885:	8d 83 47 dd fe ff    	lea    -0x122b9(%ebx),%eax
f010188b:	50                   	push   %eax
f010188c:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0101892:	50                   	push   %eax
f0101893:	68 e5 02 00 00       	push   $0x2e5
f0101898:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010189e:	50                   	push   %eax
f010189f:	e8 7c e8 ff ff       	call   f0100120 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01018a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018a7:	8d 83 64 dd fe ff    	lea    -0x1229c(%ebx),%eax
f01018ad:	50                   	push   %eax
f01018ae:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01018b4:	50                   	push   %eax
f01018b5:	68 e6 02 00 00       	push   $0x2e6
f01018ba:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01018c0:	50                   	push   %eax
f01018c1:	e8 5a e8 ff ff       	call   f0100120 <_panic>
	assert(!page_alloc(0));
f01018c6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018c9:	8d 83 81 dd fe ff    	lea    -0x1227f(%ebx),%eax
f01018cf:	50                   	push   %eax
f01018d0:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01018d6:	50                   	push   %eax
f01018d7:	68 ed 02 00 00       	push   $0x2ed
f01018dc:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01018e2:	50                   	push   %eax
f01018e3:	e8 38 e8 ff ff       	call   f0100120 <_panic>
	assert((pp0 = page_alloc(0)));
f01018e8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018eb:	8d 83 d6 dc fe ff    	lea    -0x1232a(%ebx),%eax
f01018f1:	50                   	push   %eax
f01018f2:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01018f8:	50                   	push   %eax
f01018f9:	68 f4 02 00 00       	push   $0x2f4
f01018fe:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0101904:	50                   	push   %eax
f0101905:	e8 16 e8 ff ff       	call   f0100120 <_panic>
	assert((pp1 = page_alloc(0)));
f010190a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010190d:	8d 83 ec dc fe ff    	lea    -0x12314(%ebx),%eax
f0101913:	50                   	push   %eax
f0101914:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010191a:	50                   	push   %eax
f010191b:	68 f5 02 00 00       	push   $0x2f5
f0101920:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0101926:	50                   	push   %eax
f0101927:	e8 f4 e7 ff ff       	call   f0100120 <_panic>
	assert((pp2 = page_alloc(0)));
f010192c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010192f:	8d 83 02 dd fe ff    	lea    -0x122fe(%ebx),%eax
f0101935:	50                   	push   %eax
f0101936:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010193c:	50                   	push   %eax
f010193d:	68 f6 02 00 00       	push   $0x2f6
f0101942:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0101948:	50                   	push   %eax
f0101949:	e8 d2 e7 ff ff       	call   f0100120 <_panic>
	assert(pp1 && pp1 != pp0);
f010194e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101951:	8d 83 18 dd fe ff    	lea    -0x122e8(%ebx),%eax
f0101957:	50                   	push   %eax
f0101958:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010195e:	50                   	push   %eax
f010195f:	68 f8 02 00 00       	push   $0x2f8
f0101964:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010196a:	50                   	push   %eax
f010196b:	e8 b0 e7 ff ff       	call   f0100120 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101970:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101973:	8d 83 b8 d5 fe ff    	lea    -0x12a48(%ebx),%eax
f0101979:	50                   	push   %eax
f010197a:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0101980:	50                   	push   %eax
f0101981:	68 f9 02 00 00       	push   $0x2f9
f0101986:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010198c:	50                   	push   %eax
f010198d:	e8 8e e7 ff ff       	call   f0100120 <_panic>
	assert(!page_alloc(0));
f0101992:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101995:	8d 83 81 dd fe ff    	lea    -0x1227f(%ebx),%eax
f010199b:	50                   	push   %eax
f010199c:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01019a2:	50                   	push   %eax
f01019a3:	68 fa 02 00 00       	push   $0x2fa
f01019a8:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01019ae:	50                   	push   %eax
f01019af:	e8 6c e7 ff ff       	call   f0100120 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019b4:	52                   	push   %edx
f01019b5:	89 cb                	mov    %ecx,%ebx
f01019b7:	8d 81 50 d4 fe ff    	lea    -0x12bb0(%ecx),%eax
f01019bd:	50                   	push   %eax
f01019be:	6a 55                	push   $0x55
f01019c0:	8d 81 c8 db fe ff    	lea    -0x12438(%ecx),%eax
f01019c6:	50                   	push   %eax
f01019c7:	e8 54 e7 ff ff       	call   f0100120 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019cf:	8d 83 90 dd fe ff    	lea    -0x12270(%ebx),%eax
f01019d5:	50                   	push   %eax
f01019d6:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01019dc:	50                   	push   %eax
f01019dd:	68 ff 02 00 00       	push   $0x2ff
f01019e2:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01019e8:	50                   	push   %eax
f01019e9:	e8 32 e7 ff ff       	call   f0100120 <_panic>
	assert(pp && pp0 == pp);
f01019ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019f1:	8d 83 ae dd fe ff    	lea    -0x12252(%ebx),%eax
f01019f7:	50                   	push   %eax
f01019f8:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01019fe:	50                   	push   %eax
f01019ff:	68 00 03 00 00       	push   $0x300
f0101a04:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0101a0a:	50                   	push   %eax
f0101a0b:	e8 10 e7 ff ff       	call   f0100120 <_panic>
f0101a10:	52                   	push   %edx
f0101a11:	89 cb                	mov    %ecx,%ebx
f0101a13:	8d 81 50 d4 fe ff    	lea    -0x12bb0(%ecx),%eax
f0101a19:	50                   	push   %eax
f0101a1a:	6a 55                	push   $0x55
f0101a1c:	8d 81 c8 db fe ff    	lea    -0x12438(%ecx),%eax
f0101a22:	50                   	push   %eax
f0101a23:	e8 f8 e6 ff ff       	call   f0100120 <_panic>
		assert(c[i] == 0);
f0101a28:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a2b:	8d 83 be dd fe ff    	lea    -0x12242(%ebx),%eax
f0101a31:	50                   	push   %eax
f0101a32:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0101a38:	50                   	push   %eax
f0101a39:	68 03 03 00 00       	push   $0x303
f0101a3e:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0101a44:	50                   	push   %eax
f0101a45:	e8 d6 e6 ff ff       	call   f0100120 <_panic>
	assert(nfree == 0);
f0101a4a:	85 f6                	test   %esi,%esi
f0101a4c:	0f 85 2b 08 00 00    	jne    f010227d <mem_init+0xe77>
	cprintf("check_page_alloc() succeeded!\n");
f0101a52:	83 ec 0c             	sub    $0xc,%esp
f0101a55:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a58:	8d 83 d8 d5 fe ff    	lea    -0x12a28(%ebx),%eax
f0101a5e:	50                   	push   %eax
f0101a5f:	e8 ff 16 00 00       	call   f0103163 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a6b:	e8 e7 f5 ff ff       	call   f0101057 <page_alloc>
f0101a70:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a73:	83 c4 10             	add    $0x10,%esp
f0101a76:	85 c0                	test   %eax,%eax
f0101a78:	0f 84 21 08 00 00    	je     f010229f <mem_init+0xe99>
	assert((pp1 = page_alloc(0)));
f0101a7e:	83 ec 0c             	sub    $0xc,%esp
f0101a81:	6a 00                	push   $0x0
f0101a83:	e8 cf f5 ff ff       	call   f0101057 <page_alloc>
f0101a88:	89 c7                	mov    %eax,%edi
f0101a8a:	83 c4 10             	add    $0x10,%esp
f0101a8d:	85 c0                	test   %eax,%eax
f0101a8f:	0f 84 2c 08 00 00    	je     f01022c1 <mem_init+0xebb>
	assert((pp2 = page_alloc(0)));
f0101a95:	83 ec 0c             	sub    $0xc,%esp
f0101a98:	6a 00                	push   $0x0
f0101a9a:	e8 b8 f5 ff ff       	call   f0101057 <page_alloc>
f0101a9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101aa2:	83 c4 10             	add    $0x10,%esp
f0101aa5:	85 c0                	test   %eax,%eax
f0101aa7:	0f 84 36 08 00 00    	je     f01022e3 <mem_init+0xedd>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101aad:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101ab0:	0f 84 4f 08 00 00    	je     f0102305 <mem_init+0xeff>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ab6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ab9:	39 c7                	cmp    %eax,%edi
f0101abb:	0f 84 66 08 00 00    	je     f0102327 <mem_init+0xf21>
f0101ac1:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ac4:	0f 84 5d 08 00 00    	je     f0102327 <mem_init+0xf21>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101acd:	8b 88 bc 1f 00 00    	mov    0x1fbc(%eax),%ecx
f0101ad3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101ad6:	c7 80 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%eax)
f0101add:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ae0:	83 ec 0c             	sub    $0xc,%esp
f0101ae3:	6a 00                	push   $0x0
f0101ae5:	e8 6d f5 ff ff       	call   f0101057 <page_alloc>
f0101aea:	83 c4 10             	add    $0x10,%esp
f0101aed:	85 c0                	test   %eax,%eax
f0101aef:	0f 85 54 08 00 00    	jne    f0102349 <mem_init+0xf43>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101af5:	83 ec 04             	sub    $0x4,%esp
f0101af8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101afb:	50                   	push   %eax
f0101afc:	6a 00                	push   $0x0
f0101afe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b01:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101b07:	e8 da f7 ff ff       	call   f01012e6 <page_lookup>
f0101b0c:	83 c4 10             	add    $0x10,%esp
f0101b0f:	85 c0                	test   %eax,%eax
f0101b11:	0f 85 54 08 00 00    	jne    f010236b <mem_init+0xf65>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b17:	6a 02                	push   $0x2
f0101b19:	6a 00                	push   $0x0
f0101b1b:	57                   	push   %edi
f0101b1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b1f:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101b25:	e8 6a f8 ff ff       	call   f0101394 <page_insert>
f0101b2a:	83 c4 10             	add    $0x10,%esp
f0101b2d:	85 c0                	test   %eax,%eax
f0101b2f:	0f 89 58 08 00 00    	jns    f010238d <mem_init+0xf87>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b35:	83 ec 0c             	sub    $0xc,%esp
f0101b38:	ff 75 cc             	push   -0x34(%ebp)
f0101b3b:	e8 9c f5 ff ff       	call   f01010dc <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b40:	6a 02                	push   $0x2
f0101b42:	6a 00                	push   $0x0
f0101b44:	57                   	push   %edi
f0101b45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b48:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101b4e:	e8 41 f8 ff ff       	call   f0101394 <page_insert>
f0101b53:	83 c4 20             	add    $0x20,%esp
f0101b56:	85 c0                	test   %eax,%eax
f0101b58:	0f 85 51 08 00 00    	jne    f01023af <mem_init+0xfa9>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b61:	8b 98 b0 1f 00 00    	mov    0x1fb0(%eax),%ebx
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0101b67:	8b b0 ac 1f 00 00    	mov    0x1fac(%eax),%esi
f0101b6d:	8b 13                	mov    (%ebx),%edx
f0101b6f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b75:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101b78:	29 f0                	sub    %esi,%eax
f0101b7a:	c1 f8 03             	sar    $0x3,%eax
f0101b7d:	c1 e0 0c             	shl    $0xc,%eax
f0101b80:	39 c2                	cmp    %eax,%edx
f0101b82:	0f 85 49 08 00 00    	jne    f01023d1 <mem_init+0xfcb>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b88:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b8d:	89 d8                	mov    %ebx,%eax
f0101b8f:	e8 e1 ef ff ff       	call   f0100b75 <check_va2pa>
f0101b94:	89 c2                	mov    %eax,%edx
f0101b96:	89 f8                	mov    %edi,%eax
f0101b98:	29 f0                	sub    %esi,%eax
f0101b9a:	c1 f8 03             	sar    $0x3,%eax
f0101b9d:	c1 e0 0c             	shl    $0xc,%eax
f0101ba0:	39 c2                	cmp    %eax,%edx
f0101ba2:	0f 85 4b 08 00 00    	jne    f01023f3 <mem_init+0xfed>
	assert(pp1->pp_ref == 1);
f0101ba8:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101bad:	0f 85 62 08 00 00    	jne    f0102415 <mem_init+0x100f>
	assert(pp0->pp_ref == 1);
f0101bb3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101bb6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bbb:	0f 85 76 08 00 00    	jne    f0102437 <mem_init+0x1031>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bc1:	6a 02                	push   $0x2
f0101bc3:	68 00 10 00 00       	push   $0x1000
f0101bc8:	ff 75 d0             	push   -0x30(%ebp)
f0101bcb:	53                   	push   %ebx
f0101bcc:	e8 c3 f7 ff ff       	call   f0101394 <page_insert>
f0101bd1:	83 c4 10             	add    $0x10,%esp
f0101bd4:	85 c0                	test   %eax,%eax
f0101bd6:	0f 85 7d 08 00 00    	jne    f0102459 <mem_init+0x1053>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bdc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101be1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101be4:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101bea:	e8 86 ef ff ff       	call   f0100b75 <check_va2pa>
f0101bef:	89 c2                	mov    %eax,%edx
f0101bf1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bf4:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101bfa:	c1 f8 03             	sar    $0x3,%eax
f0101bfd:	c1 e0 0c             	shl    $0xc,%eax
f0101c00:	39 c2                	cmp    %eax,%edx
f0101c02:	0f 85 73 08 00 00    	jne    f010247b <mem_init+0x1075>
	assert(pp2->pp_ref == 1);
f0101c08:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c0b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c10:	0f 85 87 08 00 00    	jne    f010249d <mem_init+0x1097>

	// should be no free memory
	assert(!page_alloc(0));
f0101c16:	83 ec 0c             	sub    $0xc,%esp
f0101c19:	6a 00                	push   $0x0
f0101c1b:	e8 37 f4 ff ff       	call   f0101057 <page_alloc>
f0101c20:	83 c4 10             	add    $0x10,%esp
f0101c23:	85 c0                	test   %eax,%eax
f0101c25:	0f 85 94 08 00 00    	jne    f01024bf <mem_init+0x10b9>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c2b:	6a 02                	push   $0x2
f0101c2d:	68 00 10 00 00       	push   $0x1000
f0101c32:	ff 75 d0             	push   -0x30(%ebp)
f0101c35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c38:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101c3e:	e8 51 f7 ff ff       	call   f0101394 <page_insert>
f0101c43:	83 c4 10             	add    $0x10,%esp
f0101c46:	85 c0                	test   %eax,%eax
f0101c48:	0f 85 93 08 00 00    	jne    f01024e1 <mem_init+0x10db>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c4e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c53:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c56:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101c5c:	e8 14 ef ff ff       	call   f0100b75 <check_va2pa>
f0101c61:	89 c2                	mov    %eax,%edx
f0101c63:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c66:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101c6c:	c1 f8 03             	sar    $0x3,%eax
f0101c6f:	c1 e0 0c             	shl    $0xc,%eax
f0101c72:	39 c2                	cmp    %eax,%edx
f0101c74:	0f 85 89 08 00 00    	jne    f0102503 <mem_init+0x10fd>
	assert(pp2->pp_ref == 1);
f0101c7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c7d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c82:	0f 85 9d 08 00 00    	jne    f0102525 <mem_init+0x111f>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c88:	83 ec 0c             	sub    $0xc,%esp
f0101c8b:	6a 00                	push   $0x0
f0101c8d:	e8 c5 f3 ff ff       	call   f0101057 <page_alloc>
f0101c92:	83 c4 10             	add    $0x10,%esp
f0101c95:	85 c0                	test   %eax,%eax
f0101c97:	0f 85 aa 08 00 00    	jne    f0102547 <mem_init+0x1141>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c9d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ca0:	8b 91 b0 1f 00 00    	mov    0x1fb0(%ecx),%edx
f0101ca6:	8b 02                	mov    (%edx),%eax
f0101ca8:	89 c3                	mov    %eax,%ebx
f0101caa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101cb0:	c1 e8 0c             	shr    $0xc,%eax
f0101cb3:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0101cb9:	0f 83 aa 08 00 00    	jae    f0102569 <mem_init+0x1163>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101cbf:	83 ec 04             	sub    $0x4,%esp
f0101cc2:	6a 00                	push   $0x0
f0101cc4:	68 00 10 00 00       	push   $0x1000
f0101cc9:	52                   	push   %edx
f0101cca:	e8 cb f4 ff ff       	call   f010119a <pgdir_walk>
f0101ccf:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101cd5:	83 c4 10             	add    $0x10,%esp
f0101cd8:	39 d8                	cmp    %ebx,%eax
f0101cda:	0f 85 a4 08 00 00    	jne    f0102584 <mem_init+0x117e>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ce0:	6a 06                	push   $0x6
f0101ce2:	68 00 10 00 00       	push   $0x1000
f0101ce7:	ff 75 d0             	push   -0x30(%ebp)
f0101cea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ced:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101cf3:	e8 9c f6 ff ff       	call   f0101394 <page_insert>
f0101cf8:	83 c4 10             	add    $0x10,%esp
f0101cfb:	85 c0                	test   %eax,%eax
f0101cfd:	0f 85 a3 08 00 00    	jne    f01025a6 <mem_init+0x11a0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d03:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101d06:	8b 9e b0 1f 00 00    	mov    0x1fb0(%esi),%ebx
f0101d0c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d11:	89 d8                	mov    %ebx,%eax
f0101d13:	e8 5d ee ff ff       	call   f0100b75 <check_va2pa>
f0101d18:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0101d1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d1d:	2b 86 ac 1f 00 00    	sub    0x1fac(%esi),%eax
f0101d23:	c1 f8 03             	sar    $0x3,%eax
f0101d26:	c1 e0 0c             	shl    $0xc,%eax
f0101d29:	39 c2                	cmp    %eax,%edx
f0101d2b:	0f 85 97 08 00 00    	jne    f01025c8 <mem_init+0x11c2>
	assert(pp2->pp_ref == 1);
f0101d31:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d34:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d39:	0f 85 ab 08 00 00    	jne    f01025ea <mem_init+0x11e4>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d3f:	83 ec 04             	sub    $0x4,%esp
f0101d42:	6a 00                	push   $0x0
f0101d44:	68 00 10 00 00       	push   $0x1000
f0101d49:	53                   	push   %ebx
f0101d4a:	e8 4b f4 ff ff       	call   f010119a <pgdir_walk>
f0101d4f:	83 c4 10             	add    $0x10,%esp
f0101d52:	f6 00 04             	testb  $0x4,(%eax)
f0101d55:	0f 84 b1 08 00 00    	je     f010260c <mem_init+0x1206>
	assert(kern_pgdir[0] & PTE_U);
f0101d5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d5e:	8b 80 b0 1f 00 00    	mov    0x1fb0(%eax),%eax
f0101d64:	f6 00 04             	testb  $0x4,(%eax)
f0101d67:	0f 84 c1 08 00 00    	je     f010262e <mem_init+0x1228>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d6d:	6a 02                	push   $0x2
f0101d6f:	68 00 10 00 00       	push   $0x1000
f0101d74:	ff 75 d0             	push   -0x30(%ebp)
f0101d77:	50                   	push   %eax
f0101d78:	e8 17 f6 ff ff       	call   f0101394 <page_insert>
f0101d7d:	83 c4 10             	add    $0x10,%esp
f0101d80:	85 c0                	test   %eax,%eax
f0101d82:	0f 85 c8 08 00 00    	jne    f0102650 <mem_init+0x124a>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d88:	83 ec 04             	sub    $0x4,%esp
f0101d8b:	6a 00                	push   $0x0
f0101d8d:	68 00 10 00 00       	push   $0x1000
f0101d92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d95:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101d9b:	e8 fa f3 ff ff       	call   f010119a <pgdir_walk>
f0101da0:	83 c4 10             	add    $0x10,%esp
f0101da3:	f6 00 02             	testb  $0x2,(%eax)
f0101da6:	0f 84 c6 08 00 00    	je     f0102672 <mem_init+0x126c>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dac:	83 ec 04             	sub    $0x4,%esp
f0101daf:	6a 00                	push   $0x0
f0101db1:	68 00 10 00 00       	push   $0x1000
f0101db6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101db9:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101dbf:	e8 d6 f3 ff ff       	call   f010119a <pgdir_walk>
f0101dc4:	83 c4 10             	add    $0x10,%esp
f0101dc7:	f6 00 04             	testb  $0x4,(%eax)
f0101dca:	0f 85 c4 08 00 00    	jne    f0102694 <mem_init+0x128e>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101dd0:	6a 02                	push   $0x2
f0101dd2:	68 00 00 40 00       	push   $0x400000
f0101dd7:	ff 75 cc             	push   -0x34(%ebp)
f0101dda:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ddd:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101de3:	e8 ac f5 ff ff       	call   f0101394 <page_insert>
f0101de8:	83 c4 10             	add    $0x10,%esp
f0101deb:	85 c0                	test   %eax,%eax
f0101ded:	0f 89 c3 08 00 00    	jns    f01026b6 <mem_init+0x12b0>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101df3:	6a 02                	push   $0x2
f0101df5:	68 00 10 00 00       	push   $0x1000
f0101dfa:	57                   	push   %edi
f0101dfb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dfe:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101e04:	e8 8b f5 ff ff       	call   f0101394 <page_insert>
f0101e09:	83 c4 10             	add    $0x10,%esp
f0101e0c:	85 c0                	test   %eax,%eax
f0101e0e:	0f 85 c4 08 00 00    	jne    f01026d8 <mem_init+0x12d2>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e14:	83 ec 04             	sub    $0x4,%esp
f0101e17:	6a 00                	push   $0x0
f0101e19:	68 00 10 00 00       	push   $0x1000
f0101e1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e21:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101e27:	e8 6e f3 ff ff       	call   f010119a <pgdir_walk>
f0101e2c:	83 c4 10             	add    $0x10,%esp
f0101e2f:	f6 00 04             	testb  $0x4,(%eax)
f0101e32:	0f 85 c2 08 00 00    	jne    f01026fa <mem_init+0x12f4>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e38:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e3b:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
f0101e41:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e46:	89 f0                	mov    %esi,%eax
f0101e48:	e8 28 ed ff ff       	call   f0100b75 <check_va2pa>
f0101e4d:	89 d9                	mov    %ebx,%ecx
f0101e4f:	89 fb                	mov    %edi,%ebx
f0101e51:	2b 99 ac 1f 00 00    	sub    0x1fac(%ecx),%ebx
f0101e57:	c1 fb 03             	sar    $0x3,%ebx
f0101e5a:	c1 e3 0c             	shl    $0xc,%ebx
f0101e5d:	39 d8                	cmp    %ebx,%eax
f0101e5f:	0f 85 b7 08 00 00    	jne    f010271c <mem_init+0x1316>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e65:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e6a:	89 f0                	mov    %esi,%eax
f0101e6c:	e8 04 ed ff ff       	call   f0100b75 <check_va2pa>
f0101e71:	39 c3                	cmp    %eax,%ebx
f0101e73:	0f 85 c5 08 00 00    	jne    f010273e <mem_init+0x1338>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e79:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101e7e:	0f 85 dc 08 00 00    	jne    f0102760 <mem_init+0x135a>
	assert(pp2->pp_ref == 0);
f0101e84:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e87:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e8c:	0f 85 f0 08 00 00    	jne    f0102782 <mem_init+0x137c>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e92:	83 ec 0c             	sub    $0xc,%esp
f0101e95:	6a 00                	push   $0x0
f0101e97:	e8 bb f1 ff ff       	call   f0101057 <page_alloc>
f0101e9c:	83 c4 10             	add    $0x10,%esp
f0101e9f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ea2:	0f 85 fc 08 00 00    	jne    f01027a4 <mem_init+0x139e>
f0101ea8:	85 c0                	test   %eax,%eax
f0101eaa:	0f 84 f4 08 00 00    	je     f01027a4 <mem_init+0x139e>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101eb0:	83 ec 08             	sub    $0x8,%esp
f0101eb3:	6a 00                	push   $0x0
f0101eb5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101eb8:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101ebe:	e8 96 f4 ff ff       	call   f0101359 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ec3:	8b 9b b0 1f 00 00    	mov    0x1fb0(%ebx),%ebx
f0101ec9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ece:	89 d8                	mov    %ebx,%eax
f0101ed0:	e8 a0 ec ff ff       	call   f0100b75 <check_va2pa>
f0101ed5:	83 c4 10             	add    $0x10,%esp
f0101ed8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101edb:	0f 85 e5 08 00 00    	jne    f01027c6 <mem_init+0x13c0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ee1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ee6:	89 d8                	mov    %ebx,%eax
f0101ee8:	e8 88 ec ff ff       	call   f0100b75 <check_va2pa>
f0101eed:	89 c2                	mov    %eax,%edx
f0101eef:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ef2:	89 f8                	mov    %edi,%eax
f0101ef4:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0101efa:	c1 f8 03             	sar    $0x3,%eax
f0101efd:	c1 e0 0c             	shl    $0xc,%eax
f0101f00:	39 c2                	cmp    %eax,%edx
f0101f02:	0f 85 e0 08 00 00    	jne    f01027e8 <mem_init+0x13e2>
	assert(pp1->pp_ref == 1);
f0101f08:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f0d:	0f 85 f6 08 00 00    	jne    f0102809 <mem_init+0x1403>
	assert(pp2->pp_ref == 0);
f0101f13:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f16:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101f1b:	0f 85 0a 09 00 00    	jne    f010282b <mem_init+0x1425>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f21:	6a 00                	push   $0x0
f0101f23:	68 00 10 00 00       	push   $0x1000
f0101f28:	57                   	push   %edi
f0101f29:	53                   	push   %ebx
f0101f2a:	e8 65 f4 ff ff       	call   f0101394 <page_insert>
f0101f2f:	83 c4 10             	add    $0x10,%esp
f0101f32:	85 c0                	test   %eax,%eax
f0101f34:	0f 85 13 09 00 00    	jne    f010284d <mem_init+0x1447>
	assert(pp1->pp_ref);
f0101f3a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f3f:	0f 84 2a 09 00 00    	je     f010286f <mem_init+0x1469>
	assert(pp1->pp_link == NULL);
f0101f45:	83 3f 00             	cmpl   $0x0,(%edi)
f0101f48:	0f 85 43 09 00 00    	jne    f0102891 <mem_init+0x148b>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f4e:	83 ec 08             	sub    $0x8,%esp
f0101f51:	68 00 10 00 00       	push   $0x1000
f0101f56:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f59:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101f5f:	e8 f5 f3 ff ff       	call   f0101359 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f64:	8b 9b b0 1f 00 00    	mov    0x1fb0(%ebx),%ebx
f0101f6a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f6f:	89 d8                	mov    %ebx,%eax
f0101f71:	e8 ff eb ff ff       	call   f0100b75 <check_va2pa>
f0101f76:	83 c4 10             	add    $0x10,%esp
f0101f79:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f7c:	0f 85 31 09 00 00    	jne    f01028b3 <mem_init+0x14ad>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f82:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f87:	89 d8                	mov    %ebx,%eax
f0101f89:	e8 e7 eb ff ff       	call   f0100b75 <check_va2pa>
f0101f8e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f91:	0f 85 3e 09 00 00    	jne    f01028d5 <mem_init+0x14cf>
	assert(pp1->pp_ref == 0);
f0101f97:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f9c:	0f 85 55 09 00 00    	jne    f01028f7 <mem_init+0x14f1>
	assert(pp2->pp_ref == 0);
f0101fa2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101fa5:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101faa:	0f 85 69 09 00 00    	jne    f0102919 <mem_init+0x1513>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101fb0:	83 ec 0c             	sub    $0xc,%esp
f0101fb3:	6a 00                	push   $0x0
f0101fb5:	e8 9d f0 ff ff       	call   f0101057 <page_alloc>
f0101fba:	83 c4 10             	add    $0x10,%esp
f0101fbd:	85 c0                	test   %eax,%eax
f0101fbf:	0f 84 76 09 00 00    	je     f010293b <mem_init+0x1535>
f0101fc5:	39 c7                	cmp    %eax,%edi
f0101fc7:	0f 85 6e 09 00 00    	jne    f010293b <mem_init+0x1535>

	// should be no free memory
	assert(!page_alloc(0));
f0101fcd:	83 ec 0c             	sub    $0xc,%esp
f0101fd0:	6a 00                	push   $0x0
f0101fd2:	e8 80 f0 ff ff       	call   f0101057 <page_alloc>
f0101fd7:	83 c4 10             	add    $0x10,%esp
f0101fda:	85 c0                	test   %eax,%eax
f0101fdc:	0f 85 7b 09 00 00    	jne    f010295d <mem_init+0x1557>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fe2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fe5:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f0101feb:	8b 11                	mov    (%ecx),%edx
f0101fed:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ff3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101ff6:	2b 98 ac 1f 00 00    	sub    0x1fac(%eax),%ebx
f0101ffc:	89 d8                	mov    %ebx,%eax
f0101ffe:	c1 f8 03             	sar    $0x3,%eax
f0102001:	c1 e0 0c             	shl    $0xc,%eax
f0102004:	39 c2                	cmp    %eax,%edx
f0102006:	0f 85 73 09 00 00    	jne    f010297f <mem_init+0x1579>
	kern_pgdir[0] = 0;
f010200c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102012:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102015:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010201a:	0f 85 81 09 00 00    	jne    f01029a1 <mem_init+0x159b>
	pp0->pp_ref = 0;
f0102020:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102023:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102029:	83 ec 0c             	sub    $0xc,%esp
f010202c:	50                   	push   %eax
f010202d:	e8 aa f0 ff ff       	call   f01010dc <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102032:	83 c4 0c             	add    $0xc,%esp
f0102035:	6a 01                	push   $0x1
f0102037:	68 00 10 40 00       	push   $0x401000
f010203c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010203f:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0102045:	e8 50 f1 ff ff       	call   f010119a <pgdir_walk>
f010204a:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010204c:	89 d9                	mov    %ebx,%ecx
f010204e:	8b 9b b0 1f 00 00    	mov    0x1fb0(%ebx),%ebx
f0102054:	8b 43 04             	mov    0x4(%ebx),%eax
f0102057:	89 c2                	mov    %eax,%edx
f0102059:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010205f:	8b 89 b4 1f 00 00    	mov    0x1fb4(%ecx),%ecx
f0102065:	c1 e8 0c             	shr    $0xc,%eax
f0102068:	83 c4 10             	add    $0x10,%esp
f010206b:	39 c8                	cmp    %ecx,%eax
f010206d:	0f 83 50 09 00 00    	jae    f01029c3 <mem_init+0x15bd>
	assert(ptep == ptep1 + PTX(va));
f0102073:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102079:	39 d6                	cmp    %edx,%esi
f010207b:	0f 85 5e 09 00 00    	jne    f01029df <mem_init+0x15d9>
	kern_pgdir[PDX(va)] = 0;
f0102081:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0102088:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010208b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0102091:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102094:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f010209a:	c1 f8 03             	sar    $0x3,%eax
f010209d:	89 c2                	mov    %eax,%edx
f010209f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01020a2:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01020a7:	39 c1                	cmp    %eax,%ecx
f01020a9:	0f 86 52 09 00 00    	jbe    f0102a01 <mem_init+0x15fb>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020af:	83 ec 04             	sub    $0x4,%esp
f01020b2:	68 00 10 00 00       	push   $0x1000
f01020b7:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020bc:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01020c2:	52                   	push   %edx
f01020c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020c6:	e8 b1 1c 00 00       	call   f0103d7c <memset>
	page_free(pp0);
f01020cb:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01020ce:	89 34 24             	mov    %esi,(%esp)
f01020d1:	e8 06 f0 ff ff       	call   f01010dc <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020d6:	83 c4 0c             	add    $0xc,%esp
f01020d9:	6a 01                	push   $0x1
f01020db:	6a 00                	push   $0x0
f01020dd:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f01020e3:	e8 b2 f0 ff ff       	call   f010119a <pgdir_walk>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f01020e8:	89 f0                	mov    %esi,%eax
f01020ea:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f01020f0:	c1 f8 03             	sar    $0x3,%eax
f01020f3:	89 c2                	mov    %eax,%edx
f01020f5:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01020f8:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01020fd:	83 c4 10             	add    $0x10,%esp
f0102100:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0102106:	0f 83 0b 09 00 00    	jae    f0102a17 <mem_init+0x1611>
	return (void *)(pa + KERNBASE);
f010210c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102112:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102118:	8b 30                	mov    (%eax),%esi
f010211a:	83 e6 01             	and    $0x1,%esi
f010211d:	0f 85 0d 09 00 00    	jne    f0102a30 <mem_init+0x162a>
	for(i=0; i<NPTENTRIES; i++)
f0102123:	83 c0 04             	add    $0x4,%eax
f0102126:	39 d0                	cmp    %edx,%eax
f0102128:	75 ee                	jne    f0102118 <mem_init+0xd12>
	kern_pgdir[0] = 0;
f010212a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010212d:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0102133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102139:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010213c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102142:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102145:	89 93 bc 1f 00 00    	mov    %edx,0x1fbc(%ebx)

	// free the pages we took
	page_free(pp0);
f010214b:	83 ec 0c             	sub    $0xc,%esp
f010214e:	50                   	push   %eax
f010214f:	e8 88 ef ff ff       	call   f01010dc <page_free>
	page_free(pp1);
f0102154:	89 3c 24             	mov    %edi,(%esp)
f0102157:	e8 80 ef ff ff       	call   f01010dc <page_free>
	page_free(pp2);
f010215c:	83 c4 04             	add    $0x4,%esp
f010215f:	ff 75 d0             	push   -0x30(%ebp)
f0102162:	e8 75 ef ff ff       	call   f01010dc <page_free>

	cprintf("check_page() succeeded!\n");
f0102167:	8d 83 9f de fe ff    	lea    -0x12161(%ebx),%eax
f010216d:	89 04 24             	mov    %eax,(%esp)
f0102170:	e8 ee 0f 00 00       	call   f0103163 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P );
f0102175:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010217b:	83 c4 10             	add    $0x10,%esp
f010217e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102183:	0f 86 c9 08 00 00    	jbe    f0102a52 <mem_init+0x164c>
f0102189:	83 ec 08             	sub    $0x8,%esp
f010218c:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010218e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102193:	50                   	push   %eax
f0102194:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102199:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010219e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021a1:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f01021a7:	e8 ba f0 ff ff       	call   f0101266 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01021ac:	c7 c0 00 e0 10 f0    	mov    $0xf010e000,%eax
f01021b2:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01021b5:	83 c4 10             	add    $0x10,%esp
f01021b8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021bd:	0f 86 ab 08 00 00    	jbe    f0102a6e <mem_init+0x1668>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01021c3:	83 ec 08             	sub    $0x8,%esp
f01021c6:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f01021c8:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01021cb:	05 00 00 00 10       	add    $0x10000000,%eax
f01021d0:	50                   	push   %eax
f01021d1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021d6:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021db:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021de:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f01021e4:	e8 7d f0 ff ff       	call   f0101266 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE , 0, PTE_W);
f01021e9:	83 c4 08             	add    $0x8,%esp
f01021ec:	6a 02                	push   $0x2
f01021ee:	6a 00                	push   $0x0
f01021f0:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01021f5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021fa:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f0102200:	e8 61 f0 ff ff       	call   f0101266 <boot_map_region>
	pgdir = kern_pgdir;
f0102205:	89 f9                	mov    %edi,%ecx
f0102207:	8b bf b0 1f 00 00    	mov    0x1fb0(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010220d:	8b 81 b4 1f 00 00    	mov    0x1fb4(%ecx),%eax
f0102213:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102216:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010221d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102222:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102224:	8b 81 ac 1f 00 00    	mov    0x1fac(%ecx),%eax
f010222a:	89 45 bc             	mov    %eax,-0x44(%ebp)
f010222d:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0102233:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102236:	83 c4 10             	add    $0x10,%esp
f0102239:	89 f3                	mov    %esi,%ebx
f010223b:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010223e:	89 c7                	mov    %eax,%edi
f0102240:	89 75 c0             	mov    %esi,-0x40(%ebp)
f0102243:	89 d6                	mov    %edx,%esi
f0102245:	39 de                	cmp    %ebx,%esi
f0102247:	0f 86 82 08 00 00    	jbe    f0102acf <mem_init+0x16c9>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010224d:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102253:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102256:	e8 1a e9 ff ff       	call   f0100b75 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010225b:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102261:	0f 86 28 08 00 00    	jbe    f0102a8f <mem_init+0x1689>
f0102267:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010226a:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f010226d:	39 d0                	cmp    %edx,%eax
f010226f:	0f 85 38 08 00 00    	jne    f0102aad <mem_init+0x16a7>
	for (i = 0; i < n; i += PGSIZE)
f0102275:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010227b:	eb c8                	jmp    f0102245 <mem_init+0xe3f>
	assert(nfree == 0);
f010227d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102280:	8d 83 c8 dd fe ff    	lea    -0x12238(%ebx),%eax
f0102286:	50                   	push   %eax
f0102287:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010228d:	50                   	push   %eax
f010228e:	68 10 03 00 00       	push   $0x310
f0102293:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102299:	50                   	push   %eax
f010229a:	e8 81 de ff ff       	call   f0100120 <_panic>
	assert((pp0 = page_alloc(0)));
f010229f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022a2:	8d 83 d6 dc fe ff    	lea    -0x1232a(%ebx),%eax
f01022a8:	50                   	push   %eax
f01022a9:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01022af:	50                   	push   %eax
f01022b0:	68 69 03 00 00       	push   $0x369
f01022b5:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01022bb:	50                   	push   %eax
f01022bc:	e8 5f de ff ff       	call   f0100120 <_panic>
	assert((pp1 = page_alloc(0)));
f01022c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022c4:	8d 83 ec dc fe ff    	lea    -0x12314(%ebx),%eax
f01022ca:	50                   	push   %eax
f01022cb:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01022d1:	50                   	push   %eax
f01022d2:	68 6a 03 00 00       	push   $0x36a
f01022d7:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01022dd:	50                   	push   %eax
f01022de:	e8 3d de ff ff       	call   f0100120 <_panic>
	assert((pp2 = page_alloc(0)));
f01022e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022e6:	8d 83 02 dd fe ff    	lea    -0x122fe(%ebx),%eax
f01022ec:	50                   	push   %eax
f01022ed:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01022f3:	50                   	push   %eax
f01022f4:	68 6b 03 00 00       	push   $0x36b
f01022f9:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01022ff:	50                   	push   %eax
f0102300:	e8 1b de ff ff       	call   f0100120 <_panic>
	assert(pp1 && pp1 != pp0);
f0102305:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102308:	8d 83 18 dd fe ff    	lea    -0x122e8(%ebx),%eax
f010230e:	50                   	push   %eax
f010230f:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102315:	50                   	push   %eax
f0102316:	68 6e 03 00 00       	push   $0x36e
f010231b:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102321:	50                   	push   %eax
f0102322:	e8 f9 dd ff ff       	call   f0100120 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102327:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010232a:	8d 83 b8 d5 fe ff    	lea    -0x12a48(%ebx),%eax
f0102330:	50                   	push   %eax
f0102331:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102337:	50                   	push   %eax
f0102338:	68 6f 03 00 00       	push   $0x36f
f010233d:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102343:	50                   	push   %eax
f0102344:	e8 d7 dd ff ff       	call   f0100120 <_panic>
	assert(!page_alloc(0));
f0102349:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010234c:	8d 83 81 dd fe ff    	lea    -0x1227f(%ebx),%eax
f0102352:	50                   	push   %eax
f0102353:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102359:	50                   	push   %eax
f010235a:	68 76 03 00 00       	push   $0x376
f010235f:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102365:	50                   	push   %eax
f0102366:	e8 b5 dd ff ff       	call   f0100120 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010236b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010236e:	8d 83 f8 d5 fe ff    	lea    -0x12a08(%ebx),%eax
f0102374:	50                   	push   %eax
f0102375:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010237b:	50                   	push   %eax
f010237c:	68 79 03 00 00       	push   $0x379
f0102381:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102387:	50                   	push   %eax
f0102388:	e8 93 dd ff ff       	call   f0100120 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010238d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102390:	8d 83 30 d6 fe ff    	lea    -0x129d0(%ebx),%eax
f0102396:	50                   	push   %eax
f0102397:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010239d:	50                   	push   %eax
f010239e:	68 7c 03 00 00       	push   $0x37c
f01023a3:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01023a9:	50                   	push   %eax
f01023aa:	e8 71 dd ff ff       	call   f0100120 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023b2:	8d 83 60 d6 fe ff    	lea    -0x129a0(%ebx),%eax
f01023b8:	50                   	push   %eax
f01023b9:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01023bf:	50                   	push   %eax
f01023c0:	68 80 03 00 00       	push   $0x380
f01023c5:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01023cb:	50                   	push   %eax
f01023cc:	e8 4f dd ff ff       	call   f0100120 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023d4:	8d 83 90 d6 fe ff    	lea    -0x12970(%ebx),%eax
f01023da:	50                   	push   %eax
f01023db:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01023e1:	50                   	push   %eax
f01023e2:	68 81 03 00 00       	push   $0x381
f01023e7:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01023ed:	50                   	push   %eax
f01023ee:	e8 2d dd ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023f3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023f6:	8d 83 b8 d6 fe ff    	lea    -0x12948(%ebx),%eax
f01023fc:	50                   	push   %eax
f01023fd:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102403:	50                   	push   %eax
f0102404:	68 82 03 00 00       	push   $0x382
f0102409:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010240f:	50                   	push   %eax
f0102410:	e8 0b dd ff ff       	call   f0100120 <_panic>
	assert(pp1->pp_ref == 1);
f0102415:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102418:	8d 83 d3 dd fe ff    	lea    -0x1222d(%ebx),%eax
f010241e:	50                   	push   %eax
f010241f:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102425:	50                   	push   %eax
f0102426:	68 83 03 00 00       	push   $0x383
f010242b:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102431:	50                   	push   %eax
f0102432:	e8 e9 dc ff ff       	call   f0100120 <_panic>
	assert(pp0->pp_ref == 1);
f0102437:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010243a:	8d 83 e4 dd fe ff    	lea    -0x1221c(%ebx),%eax
f0102440:	50                   	push   %eax
f0102441:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102447:	50                   	push   %eax
f0102448:	68 84 03 00 00       	push   $0x384
f010244d:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102453:	50                   	push   %eax
f0102454:	e8 c7 dc ff ff       	call   f0100120 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102459:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010245c:	8d 83 e8 d6 fe ff    	lea    -0x12918(%ebx),%eax
f0102462:	50                   	push   %eax
f0102463:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102469:	50                   	push   %eax
f010246a:	68 87 03 00 00       	push   $0x387
f010246f:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102475:	50                   	push   %eax
f0102476:	e8 a5 dc ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010247b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010247e:	8d 83 24 d7 fe ff    	lea    -0x128dc(%ebx),%eax
f0102484:	50                   	push   %eax
f0102485:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010248b:	50                   	push   %eax
f010248c:	68 88 03 00 00       	push   $0x388
f0102491:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102497:	50                   	push   %eax
f0102498:	e8 83 dc ff ff       	call   f0100120 <_panic>
	assert(pp2->pp_ref == 1);
f010249d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024a0:	8d 83 f5 dd fe ff    	lea    -0x1220b(%ebx),%eax
f01024a6:	50                   	push   %eax
f01024a7:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01024ad:	50                   	push   %eax
f01024ae:	68 89 03 00 00       	push   $0x389
f01024b3:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01024b9:	50                   	push   %eax
f01024ba:	e8 61 dc ff ff       	call   f0100120 <_panic>
	assert(!page_alloc(0));
f01024bf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024c2:	8d 83 81 dd fe ff    	lea    -0x1227f(%ebx),%eax
f01024c8:	50                   	push   %eax
f01024c9:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01024cf:	50                   	push   %eax
f01024d0:	68 8c 03 00 00       	push   $0x38c
f01024d5:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01024db:	50                   	push   %eax
f01024dc:	e8 3f dc ff ff       	call   f0100120 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024e4:	8d 83 e8 d6 fe ff    	lea    -0x12918(%ebx),%eax
f01024ea:	50                   	push   %eax
f01024eb:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01024f1:	50                   	push   %eax
f01024f2:	68 8f 03 00 00       	push   $0x38f
f01024f7:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01024fd:	50                   	push   %eax
f01024fe:	e8 1d dc ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102503:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102506:	8d 83 24 d7 fe ff    	lea    -0x128dc(%ebx),%eax
f010250c:	50                   	push   %eax
f010250d:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102513:	50                   	push   %eax
f0102514:	68 90 03 00 00       	push   $0x390
f0102519:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010251f:	50                   	push   %eax
f0102520:	e8 fb db ff ff       	call   f0100120 <_panic>
	assert(pp2->pp_ref == 1);
f0102525:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102528:	8d 83 f5 dd fe ff    	lea    -0x1220b(%ebx),%eax
f010252e:	50                   	push   %eax
f010252f:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102535:	50                   	push   %eax
f0102536:	68 91 03 00 00       	push   $0x391
f010253b:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102541:	50                   	push   %eax
f0102542:	e8 d9 db ff ff       	call   f0100120 <_panic>
	assert(!page_alloc(0));
f0102547:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010254a:	8d 83 81 dd fe ff    	lea    -0x1227f(%ebx),%eax
f0102550:	50                   	push   %eax
f0102551:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102557:	50                   	push   %eax
f0102558:	68 95 03 00 00       	push   $0x395
f010255d:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102563:	50                   	push   %eax
f0102564:	e8 b7 db ff ff       	call   f0100120 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102569:	53                   	push   %ebx
f010256a:	89 cb                	mov    %ecx,%ebx
f010256c:	8d 81 50 d4 fe ff    	lea    -0x12bb0(%ecx),%eax
f0102572:	50                   	push   %eax
f0102573:	68 98 03 00 00       	push   $0x398
f0102578:	8d 81 a1 db fe ff    	lea    -0x1245f(%ecx),%eax
f010257e:	50                   	push   %eax
f010257f:	e8 9c db ff ff       	call   f0100120 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102584:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102587:	8d 83 54 d7 fe ff    	lea    -0x128ac(%ebx),%eax
f010258d:	50                   	push   %eax
f010258e:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102594:	50                   	push   %eax
f0102595:	68 99 03 00 00       	push   $0x399
f010259a:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01025a0:	50                   	push   %eax
f01025a1:	e8 7a db ff ff       	call   f0100120 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01025a6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a9:	8d 83 94 d7 fe ff    	lea    -0x1286c(%ebx),%eax
f01025af:	50                   	push   %eax
f01025b0:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01025b6:	50                   	push   %eax
f01025b7:	68 9c 03 00 00       	push   $0x39c
f01025bc:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01025c2:	50                   	push   %eax
f01025c3:	e8 58 db ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025c8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025cb:	8d 83 24 d7 fe ff    	lea    -0x128dc(%ebx),%eax
f01025d1:	50                   	push   %eax
f01025d2:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01025d8:	50                   	push   %eax
f01025d9:	68 9d 03 00 00       	push   $0x39d
f01025de:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01025e4:	50                   	push   %eax
f01025e5:	e8 36 db ff ff       	call   f0100120 <_panic>
	assert(pp2->pp_ref == 1);
f01025ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ed:	8d 83 f5 dd fe ff    	lea    -0x1220b(%ebx),%eax
f01025f3:	50                   	push   %eax
f01025f4:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01025fa:	50                   	push   %eax
f01025fb:	68 9e 03 00 00       	push   $0x39e
f0102600:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102606:	50                   	push   %eax
f0102607:	e8 14 db ff ff       	call   f0100120 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010260c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010260f:	8d 83 d4 d7 fe ff    	lea    -0x1282c(%ebx),%eax
f0102615:	50                   	push   %eax
f0102616:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010261c:	50                   	push   %eax
f010261d:	68 9f 03 00 00       	push   $0x39f
f0102622:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102628:	50                   	push   %eax
f0102629:	e8 f2 da ff ff       	call   f0100120 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010262e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102631:	8d 83 06 de fe ff    	lea    -0x121fa(%ebx),%eax
f0102637:	50                   	push   %eax
f0102638:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010263e:	50                   	push   %eax
f010263f:	68 a0 03 00 00       	push   $0x3a0
f0102644:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010264a:	50                   	push   %eax
f010264b:	e8 d0 da ff ff       	call   f0100120 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102650:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102653:	8d 83 e8 d6 fe ff    	lea    -0x12918(%ebx),%eax
f0102659:	50                   	push   %eax
f010265a:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102660:	50                   	push   %eax
f0102661:	68 a3 03 00 00       	push   $0x3a3
f0102666:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010266c:	50                   	push   %eax
f010266d:	e8 ae da ff ff       	call   f0100120 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102672:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102675:	8d 83 08 d8 fe ff    	lea    -0x127f8(%ebx),%eax
f010267b:	50                   	push   %eax
f010267c:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102682:	50                   	push   %eax
f0102683:	68 a4 03 00 00       	push   $0x3a4
f0102688:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010268e:	50                   	push   %eax
f010268f:	e8 8c da ff ff       	call   f0100120 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102694:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102697:	8d 83 3c d8 fe ff    	lea    -0x127c4(%ebx),%eax
f010269d:	50                   	push   %eax
f010269e:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01026a4:	50                   	push   %eax
f01026a5:	68 a5 03 00 00       	push   $0x3a5
f01026aa:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01026b0:	50                   	push   %eax
f01026b1:	e8 6a da ff ff       	call   f0100120 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01026b6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026b9:	8d 83 74 d8 fe ff    	lea    -0x1278c(%ebx),%eax
f01026bf:	50                   	push   %eax
f01026c0:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01026c6:	50                   	push   %eax
f01026c7:	68 a8 03 00 00       	push   $0x3a8
f01026cc:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01026d2:	50                   	push   %eax
f01026d3:	e8 48 da ff ff       	call   f0100120 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01026d8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026db:	8d 83 ac d8 fe ff    	lea    -0x12754(%ebx),%eax
f01026e1:	50                   	push   %eax
f01026e2:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01026e8:	50                   	push   %eax
f01026e9:	68 ab 03 00 00       	push   $0x3ab
f01026ee:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01026f4:	50                   	push   %eax
f01026f5:	e8 26 da ff ff       	call   f0100120 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026fd:	8d 83 3c d8 fe ff    	lea    -0x127c4(%ebx),%eax
f0102703:	50                   	push   %eax
f0102704:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010270a:	50                   	push   %eax
f010270b:	68 ac 03 00 00       	push   $0x3ac
f0102710:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102716:	50                   	push   %eax
f0102717:	e8 04 da ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010271c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010271f:	8d 83 e8 d8 fe ff    	lea    -0x12718(%ebx),%eax
f0102725:	50                   	push   %eax
f0102726:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010272c:	50                   	push   %eax
f010272d:	68 af 03 00 00       	push   $0x3af
f0102732:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102738:	50                   	push   %eax
f0102739:	e8 e2 d9 ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010273e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102741:	8d 83 14 d9 fe ff    	lea    -0x126ec(%ebx),%eax
f0102747:	50                   	push   %eax
f0102748:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010274e:	50                   	push   %eax
f010274f:	68 b0 03 00 00       	push   $0x3b0
f0102754:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010275a:	50                   	push   %eax
f010275b:	e8 c0 d9 ff ff       	call   f0100120 <_panic>
	assert(pp1->pp_ref == 2);
f0102760:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102763:	8d 83 1c de fe ff    	lea    -0x121e4(%ebx),%eax
f0102769:	50                   	push   %eax
f010276a:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102770:	50                   	push   %eax
f0102771:	68 b2 03 00 00       	push   $0x3b2
f0102776:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010277c:	50                   	push   %eax
f010277d:	e8 9e d9 ff ff       	call   f0100120 <_panic>
	assert(pp2->pp_ref == 0);
f0102782:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102785:	8d 83 2d de fe ff    	lea    -0x121d3(%ebx),%eax
f010278b:	50                   	push   %eax
f010278c:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102792:	50                   	push   %eax
f0102793:	68 b3 03 00 00       	push   $0x3b3
f0102798:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010279e:	50                   	push   %eax
f010279f:	e8 7c d9 ff ff       	call   f0100120 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01027a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027a7:	8d 83 44 d9 fe ff    	lea    -0x126bc(%ebx),%eax
f01027ad:	50                   	push   %eax
f01027ae:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01027b4:	50                   	push   %eax
f01027b5:	68 b6 03 00 00       	push   $0x3b6
f01027ba:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01027c0:	50                   	push   %eax
f01027c1:	e8 5a d9 ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027c6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c9:	8d 83 68 d9 fe ff    	lea    -0x12698(%ebx),%eax
f01027cf:	50                   	push   %eax
f01027d0:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01027d6:	50                   	push   %eax
f01027d7:	68 ba 03 00 00       	push   $0x3ba
f01027dc:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01027e2:	50                   	push   %eax
f01027e3:	e8 38 d9 ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027e8:	89 cb                	mov    %ecx,%ebx
f01027ea:	8d 81 14 d9 fe ff    	lea    -0x126ec(%ecx),%eax
f01027f0:	50                   	push   %eax
f01027f1:	8d 81 e2 db fe ff    	lea    -0x1241e(%ecx),%eax
f01027f7:	50                   	push   %eax
f01027f8:	68 bb 03 00 00       	push   $0x3bb
f01027fd:	8d 81 a1 db fe ff    	lea    -0x1245f(%ecx),%eax
f0102803:	50                   	push   %eax
f0102804:	e8 17 d9 ff ff       	call   f0100120 <_panic>
	assert(pp1->pp_ref == 1);
f0102809:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010280c:	8d 83 d3 dd fe ff    	lea    -0x1222d(%ebx),%eax
f0102812:	50                   	push   %eax
f0102813:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102819:	50                   	push   %eax
f010281a:	68 bc 03 00 00       	push   $0x3bc
f010281f:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102825:	50                   	push   %eax
f0102826:	e8 f5 d8 ff ff       	call   f0100120 <_panic>
	assert(pp2->pp_ref == 0);
f010282b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010282e:	8d 83 2d de fe ff    	lea    -0x121d3(%ebx),%eax
f0102834:	50                   	push   %eax
f0102835:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010283b:	50                   	push   %eax
f010283c:	68 bd 03 00 00       	push   $0x3bd
f0102841:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102847:	50                   	push   %eax
f0102848:	e8 d3 d8 ff ff       	call   f0100120 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010284d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102850:	8d 83 8c d9 fe ff    	lea    -0x12674(%ebx),%eax
f0102856:	50                   	push   %eax
f0102857:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010285d:	50                   	push   %eax
f010285e:	68 c0 03 00 00       	push   $0x3c0
f0102863:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102869:	50                   	push   %eax
f010286a:	e8 b1 d8 ff ff       	call   f0100120 <_panic>
	assert(pp1->pp_ref);
f010286f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102872:	8d 83 3e de fe ff    	lea    -0x121c2(%ebx),%eax
f0102878:	50                   	push   %eax
f0102879:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010287f:	50                   	push   %eax
f0102880:	68 c1 03 00 00       	push   $0x3c1
f0102885:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010288b:	50                   	push   %eax
f010288c:	e8 8f d8 ff ff       	call   f0100120 <_panic>
	assert(pp1->pp_link == NULL);
f0102891:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102894:	8d 83 4a de fe ff    	lea    -0x121b6(%ebx),%eax
f010289a:	50                   	push   %eax
f010289b:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01028a1:	50                   	push   %eax
f01028a2:	68 c2 03 00 00       	push   $0x3c2
f01028a7:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01028ad:	50                   	push   %eax
f01028ae:	e8 6d d8 ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01028b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028b6:	8d 83 68 d9 fe ff    	lea    -0x12698(%ebx),%eax
f01028bc:	50                   	push   %eax
f01028bd:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01028c3:	50                   	push   %eax
f01028c4:	68 c6 03 00 00       	push   $0x3c6
f01028c9:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01028cf:	50                   	push   %eax
f01028d0:	e8 4b d8 ff ff       	call   f0100120 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01028d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028d8:	8d 83 c4 d9 fe ff    	lea    -0x1263c(%ebx),%eax
f01028de:	50                   	push   %eax
f01028df:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01028e5:	50                   	push   %eax
f01028e6:	68 c7 03 00 00       	push   $0x3c7
f01028eb:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01028f1:	50                   	push   %eax
f01028f2:	e8 29 d8 ff ff       	call   f0100120 <_panic>
	assert(pp1->pp_ref == 0);
f01028f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028fa:	8d 83 5f de fe ff    	lea    -0x121a1(%ebx),%eax
f0102900:	50                   	push   %eax
f0102901:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102907:	50                   	push   %eax
f0102908:	68 c8 03 00 00       	push   $0x3c8
f010290d:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102913:	50                   	push   %eax
f0102914:	e8 07 d8 ff ff       	call   f0100120 <_panic>
	assert(pp2->pp_ref == 0);
f0102919:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010291c:	8d 83 2d de fe ff    	lea    -0x121d3(%ebx),%eax
f0102922:	50                   	push   %eax
f0102923:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102929:	50                   	push   %eax
f010292a:	68 c9 03 00 00       	push   $0x3c9
f010292f:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102935:	50                   	push   %eax
f0102936:	e8 e5 d7 ff ff       	call   f0100120 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010293b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010293e:	8d 83 ec d9 fe ff    	lea    -0x12614(%ebx),%eax
f0102944:	50                   	push   %eax
f0102945:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010294b:	50                   	push   %eax
f010294c:	68 cc 03 00 00       	push   $0x3cc
f0102951:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102957:	50                   	push   %eax
f0102958:	e8 c3 d7 ff ff       	call   f0100120 <_panic>
	assert(!page_alloc(0));
f010295d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102960:	8d 83 81 dd fe ff    	lea    -0x1227f(%ebx),%eax
f0102966:	50                   	push   %eax
f0102967:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010296d:	50                   	push   %eax
f010296e:	68 cf 03 00 00       	push   $0x3cf
f0102973:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102979:	50                   	push   %eax
f010297a:	e8 a1 d7 ff ff       	call   f0100120 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010297f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102982:	8d 83 90 d6 fe ff    	lea    -0x12970(%ebx),%eax
f0102988:	50                   	push   %eax
f0102989:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010298f:	50                   	push   %eax
f0102990:	68 d2 03 00 00       	push   $0x3d2
f0102995:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010299b:	50                   	push   %eax
f010299c:	e8 7f d7 ff ff       	call   f0100120 <_panic>
	assert(pp0->pp_ref == 1);
f01029a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029a4:	8d 83 e4 dd fe ff    	lea    -0x1221c(%ebx),%eax
f01029aa:	50                   	push   %eax
f01029ab:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01029b1:	50                   	push   %eax
f01029b2:	68 d4 03 00 00       	push   $0x3d4
f01029b7:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01029bd:	50                   	push   %eax
f01029be:	e8 5d d7 ff ff       	call   f0100120 <_panic>
f01029c3:	52                   	push   %edx
f01029c4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029c7:	8d 83 50 d4 fe ff    	lea    -0x12bb0(%ebx),%eax
f01029cd:	50                   	push   %eax
f01029ce:	68 db 03 00 00       	push   $0x3db
f01029d3:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01029d9:	50                   	push   %eax
f01029da:	e8 41 d7 ff ff       	call   f0100120 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01029df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029e2:	8d 83 70 de fe ff    	lea    -0x12190(%ebx),%eax
f01029e8:	50                   	push   %eax
f01029e9:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01029ef:	50                   	push   %eax
f01029f0:	68 dc 03 00 00       	push   $0x3dc
f01029f5:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01029fb:	50                   	push   %eax
f01029fc:	e8 1f d7 ff ff       	call   f0100120 <_panic>
f0102a01:	52                   	push   %edx
f0102a02:	8d 83 50 d4 fe ff    	lea    -0x12bb0(%ebx),%eax
f0102a08:	50                   	push   %eax
f0102a09:	6a 55                	push   $0x55
f0102a0b:	8d 83 c8 db fe ff    	lea    -0x12438(%ebx),%eax
f0102a11:	50                   	push   %eax
f0102a12:	e8 09 d7 ff ff       	call   f0100120 <_panic>
f0102a17:	52                   	push   %edx
f0102a18:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a1b:	8d 83 50 d4 fe ff    	lea    -0x12bb0(%ebx),%eax
f0102a21:	50                   	push   %eax
f0102a22:	6a 55                	push   $0x55
f0102a24:	8d 83 c8 db fe ff    	lea    -0x12438(%ebx),%eax
f0102a2a:	50                   	push   %eax
f0102a2b:	e8 f0 d6 ff ff       	call   f0100120 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102a30:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a33:	8d 83 88 de fe ff    	lea    -0x12178(%ebx),%eax
f0102a39:	50                   	push   %eax
f0102a3a:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102a40:	50                   	push   %eax
f0102a41:	68 e6 03 00 00       	push   $0x3e6
f0102a46:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102a4c:	50                   	push   %eax
f0102a4d:	e8 ce d6 ff ff       	call   f0100120 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a52:	50                   	push   %eax
f0102a53:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a56:	8d 83 2c d4 fe ff    	lea    -0x12bd4(%ebx),%eax
f0102a5c:	50                   	push   %eax
f0102a5d:	68 b6 00 00 00       	push   $0xb6
f0102a62:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102a68:	50                   	push   %eax
f0102a69:	e8 b2 d6 ff ff       	call   f0100120 <_panic>
f0102a6e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a71:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0102a77:	8d 83 2c d4 fe ff    	lea    -0x12bd4(%ebx),%eax
f0102a7d:	50                   	push   %eax
f0102a7e:	68 c4 00 00 00       	push   $0xc4
f0102a83:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102a89:	50                   	push   %eax
f0102a8a:	e8 91 d6 ff ff       	call   f0100120 <_panic>
f0102a8f:	ff 75 bc             	push   -0x44(%ebp)
f0102a92:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a95:	8d 83 2c d4 fe ff    	lea    -0x12bd4(%ebx),%eax
f0102a9b:	50                   	push   %eax
f0102a9c:	68 28 03 00 00       	push   $0x328
f0102aa1:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102aa7:	50                   	push   %eax
f0102aa8:	e8 73 d6 ff ff       	call   f0100120 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102aad:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab0:	8d 83 10 da fe ff    	lea    -0x125f0(%ebx),%eax
f0102ab6:	50                   	push   %eax
f0102ab7:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102abd:	50                   	push   %eax
f0102abe:	68 28 03 00 00       	push   $0x328
f0102ac3:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102ac9:	50                   	push   %eax
f0102aca:	e8 51 d6 ff ff       	call   f0100120 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102acf:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102ad2:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102ad5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102ad8:	c1 e0 0c             	shl    $0xc,%eax
f0102adb:	89 f3                	mov    %esi,%ebx
f0102add:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102ae0:	89 c6                	mov    %eax,%esi
f0102ae2:	39 f3                	cmp    %esi,%ebx
f0102ae4:	73 3b                	jae    f0102b21 <mem_init+0x171b>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102ae6:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102aec:	89 f8                	mov    %edi,%eax
f0102aee:	e8 82 e0 ff ff       	call   f0100b75 <check_va2pa>
f0102af3:	39 c3                	cmp    %eax,%ebx
f0102af5:	75 08                	jne    f0102aff <mem_init+0x16f9>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102af7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102afd:	eb e3                	jmp    f0102ae2 <mem_init+0x16dc>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102aff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b02:	8d 83 44 da fe ff    	lea    -0x125bc(%ebx),%eax
f0102b08:	50                   	push   %eax
f0102b09:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102b0f:	50                   	push   %eax
f0102b10:	68 2d 03 00 00       	push   $0x32d
f0102b15:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102b1b:	50                   	push   %eax
f0102b1c:	e8 ff d5 ff ff       	call   f0100120 <_panic>
f0102b21:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b26:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102b29:	05 00 80 00 20       	add    $0x20008000,%eax
f0102b2e:	89 c6                	mov    %eax,%esi
f0102b30:	89 da                	mov    %ebx,%edx
f0102b32:	89 f8                	mov    %edi,%eax
f0102b34:	e8 3c e0 ff ff       	call   f0100b75 <check_va2pa>
f0102b39:	89 c2                	mov    %eax,%edx
f0102b3b:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102b3e:	39 c2                	cmp    %eax,%edx
f0102b40:	75 44                	jne    f0102b86 <mem_init+0x1780>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b42:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b48:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102b4e:	75 e0                	jne    f0102b30 <mem_init+0x172a>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102b50:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102b53:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102b58:	89 f8                	mov    %edi,%eax
f0102b5a:	e8 16 e0 ff ff       	call   f0100b75 <check_va2pa>
f0102b5f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b62:	74 71                	je     f0102bd5 <mem_init+0x17cf>
f0102b64:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b67:	8d 83 b4 da fe ff    	lea    -0x1254c(%ebx),%eax
f0102b6d:	50                   	push   %eax
f0102b6e:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102b74:	50                   	push   %eax
f0102b75:	68 32 03 00 00       	push   $0x332
f0102b7a:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102b80:	50                   	push   %eax
f0102b81:	e8 9a d5 ff ff       	call   f0100120 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b86:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b89:	8d 83 6c da fe ff    	lea    -0x12594(%ebx),%eax
f0102b8f:	50                   	push   %eax
f0102b90:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102b96:	50                   	push   %eax
f0102b97:	68 31 03 00 00       	push   $0x331
f0102b9c:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102ba2:	50                   	push   %eax
f0102ba3:	e8 78 d5 ff ff       	call   f0100120 <_panic>
		switch (i) {
f0102ba8:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102bae:	75 25                	jne    f0102bd5 <mem_init+0x17cf>
			assert(pgdir[i] & PTE_P);
f0102bb0:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102bb4:	74 4f                	je     f0102c05 <mem_init+0x17ff>
	for (i = 0; i < NPDENTRIES; i++) {
f0102bb6:	83 c6 01             	add    $0x1,%esi
f0102bb9:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102bbf:	0f 87 b1 00 00 00    	ja     f0102c76 <mem_init+0x1870>
		switch (i) {
f0102bc5:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102bcb:	77 db                	ja     f0102ba8 <mem_init+0x17a2>
f0102bcd:	81 fe bb 03 00 00    	cmp    $0x3bb,%esi
f0102bd3:	77 db                	ja     f0102bb0 <mem_init+0x17aa>
			if (i >= PDX(KERNBASE)) {
f0102bd5:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102bdb:	77 4a                	ja     f0102c27 <mem_init+0x1821>
				assert(pgdir[i] == 0);
f0102bdd:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102be1:	74 d3                	je     f0102bb6 <mem_init+0x17b0>
f0102be3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102be6:	8d 83 da de fe ff    	lea    -0x12126(%ebx),%eax
f0102bec:	50                   	push   %eax
f0102bed:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102bf3:	50                   	push   %eax
f0102bf4:	68 41 03 00 00       	push   $0x341
f0102bf9:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102bff:	50                   	push   %eax
f0102c00:	e8 1b d5 ff ff       	call   f0100120 <_panic>
			assert(pgdir[i] & PTE_P);
f0102c05:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c08:	8d 83 b8 de fe ff    	lea    -0x12148(%ebx),%eax
f0102c0e:	50                   	push   %eax
f0102c0f:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102c15:	50                   	push   %eax
f0102c16:	68 3a 03 00 00       	push   $0x33a
f0102c1b:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102c21:	50                   	push   %eax
f0102c22:	e8 f9 d4 ff ff       	call   f0100120 <_panic>
				assert(pgdir[i] & PTE_P);
f0102c27:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102c2a:	a8 01                	test   $0x1,%al
f0102c2c:	74 26                	je     f0102c54 <mem_init+0x184e>
				assert(pgdir[i] & PTE_W);
f0102c2e:	a8 02                	test   $0x2,%al
f0102c30:	75 84                	jne    f0102bb6 <mem_init+0x17b0>
f0102c32:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c35:	8d 83 c9 de fe ff    	lea    -0x12137(%ebx),%eax
f0102c3b:	50                   	push   %eax
f0102c3c:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102c42:	50                   	push   %eax
f0102c43:	68 3f 03 00 00       	push   $0x33f
f0102c48:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102c4e:	50                   	push   %eax
f0102c4f:	e8 cc d4 ff ff       	call   f0100120 <_panic>
				assert(pgdir[i] & PTE_P);
f0102c54:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c57:	8d 83 b8 de fe ff    	lea    -0x12148(%ebx),%eax
f0102c5d:	50                   	push   %eax
f0102c5e:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102c64:	50                   	push   %eax
f0102c65:	68 3e 03 00 00       	push   $0x33e
f0102c6a:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102c70:	50                   	push   %eax
f0102c71:	e8 aa d4 ff ff       	call   f0100120 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c76:	83 ec 0c             	sub    $0xc,%esp
f0102c79:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c7c:	8d 83 e4 da fe ff    	lea    -0x1251c(%ebx),%eax
f0102c82:	50                   	push   %eax
f0102c83:	e8 db 04 00 00       	call   f0103163 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102c88:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102c8e:	83 c4 10             	add    $0x10,%esp
f0102c91:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c96:	0f 86 2c 02 00 00    	jbe    f0102ec8 <mem_init+0x1ac2>
	return (physaddr_t)kva - KERNBASE;
f0102c9c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102ca1:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102ca4:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ca9:	e8 43 df ff ff       	call   f0100bf1 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102cae:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102cb1:	83 e0 f3             	and    $0xfffffff3,%eax
f0102cb4:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102cb9:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102cbc:	83 ec 0c             	sub    $0xc,%esp
f0102cbf:	6a 00                	push   $0x0
f0102cc1:	e8 91 e3 ff ff       	call   f0101057 <page_alloc>
f0102cc6:	89 c6                	mov    %eax,%esi
f0102cc8:	83 c4 10             	add    $0x10,%esp
f0102ccb:	85 c0                	test   %eax,%eax
f0102ccd:	0f 84 11 02 00 00    	je     f0102ee4 <mem_init+0x1ade>
	assert((pp1 = page_alloc(0)));
f0102cd3:	83 ec 0c             	sub    $0xc,%esp
f0102cd6:	6a 00                	push   $0x0
f0102cd8:	e8 7a e3 ff ff       	call   f0101057 <page_alloc>
f0102cdd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102ce0:	83 c4 10             	add    $0x10,%esp
f0102ce3:	85 c0                	test   %eax,%eax
f0102ce5:	0f 84 1b 02 00 00    	je     f0102f06 <mem_init+0x1b00>
	assert((pp2 = page_alloc(0)));
f0102ceb:	83 ec 0c             	sub    $0xc,%esp
f0102cee:	6a 00                	push   $0x0
f0102cf0:	e8 62 e3 ff ff       	call   f0101057 <page_alloc>
f0102cf5:	89 c7                	mov    %eax,%edi
f0102cf7:	83 c4 10             	add    $0x10,%esp
f0102cfa:	85 c0                	test   %eax,%eax
f0102cfc:	0f 84 26 02 00 00    	je     f0102f28 <mem_init+0x1b22>
	page_free(pp0);
f0102d02:	83 ec 0c             	sub    $0xc,%esp
f0102d05:	56                   	push   %esi
f0102d06:	e8 d1 e3 ff ff       	call   f01010dc <page_free>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0102d0b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102d0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d11:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0102d17:	c1 f8 03             	sar    $0x3,%eax
f0102d1a:	89 c2                	mov    %eax,%edx
f0102d1c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d1f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d24:	83 c4 10             	add    $0x10,%esp
f0102d27:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0102d2d:	0f 83 17 02 00 00    	jae    f0102f4a <mem_init+0x1b44>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d33:	83 ec 04             	sub    $0x4,%esp
f0102d36:	68 00 10 00 00       	push   $0x1000
f0102d3b:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102d3d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d43:	52                   	push   %edx
f0102d44:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d47:	e8 30 10 00 00       	call   f0103d7c <memset>
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0102d4c:	89 f8                	mov    %edi,%eax
f0102d4e:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0102d54:	c1 f8 03             	sar    $0x3,%eax
f0102d57:	89 c2                	mov    %eax,%edx
f0102d59:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d5c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d61:	83 c4 10             	add    $0x10,%esp
f0102d64:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0102d6a:	0f 83 f2 01 00 00    	jae    f0102f62 <mem_init+0x1b5c>
	memset(page2kva(pp2), 2, PGSIZE);
f0102d70:	83 ec 04             	sub    $0x4,%esp
f0102d73:	68 00 10 00 00       	push   $0x1000
f0102d78:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102d7a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102d80:	52                   	push   %edx
f0102d81:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d84:	e8 f3 0f 00 00       	call   f0103d7c <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102d89:	6a 02                	push   $0x2
f0102d8b:	68 00 10 00 00       	push   $0x1000
f0102d90:	ff 75 d0             	push   -0x30(%ebp)
f0102d93:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0102d99:	e8 f6 e5 ff ff       	call   f0101394 <page_insert>
	assert(pp1->pp_ref == 1);
f0102d9e:	83 c4 20             	add    $0x20,%esp
f0102da1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102da4:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102da9:	0f 85 cc 01 00 00    	jne    f0102f7b <mem_init+0x1b75>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102daf:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102db6:	01 01 01 
f0102db9:	0f 85 de 01 00 00    	jne    f0102f9d <mem_init+0x1b97>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102dbf:	6a 02                	push   $0x2
f0102dc1:	68 00 10 00 00       	push   $0x1000
f0102dc6:	57                   	push   %edi
f0102dc7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dca:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0102dd0:	e8 bf e5 ff ff       	call   f0101394 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102dd5:	83 c4 10             	add    $0x10,%esp
f0102dd8:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ddf:	02 02 02 
f0102de2:	0f 85 d7 01 00 00    	jne    f0102fbf <mem_init+0x1bb9>
	assert(pp2->pp_ref == 1);
f0102de8:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ded:	0f 85 ee 01 00 00    	jne    f0102fe1 <mem_init+0x1bdb>
	assert(pp1->pp_ref == 0);
f0102df3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102df6:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102dfb:	0f 85 02 02 00 00    	jne    f0103003 <mem_init+0x1bfd>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e01:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e08:	03 03 03 
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0102e0b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102e0e:	89 f8                	mov    %edi,%eax
f0102e10:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0102e16:	c1 f8 03             	sar    $0x3,%eax
f0102e19:	89 c2                	mov    %eax,%edx
f0102e1b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102e1e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102e23:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0102e29:	0f 83 f6 01 00 00    	jae    f0103025 <mem_init+0x1c1f>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e2f:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102e36:	03 03 03 
f0102e39:	0f 85 fe 01 00 00    	jne    f010303d <mem_init+0x1c37>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102e3f:	83 ec 08             	sub    $0x8,%esp
f0102e42:	68 00 10 00 00       	push   $0x1000
f0102e47:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e4a:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0102e50:	e8 04 e5 ff ff       	call   f0101359 <page_remove>
	assert(pp2->pp_ref == 0);
f0102e55:	83 c4 10             	add    $0x10,%esp
f0102e58:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e5d:	0f 85 fc 01 00 00    	jne    f010305f <mem_init+0x1c59>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e63:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e66:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f0102e6c:	8b 11                	mov    (%ecx),%edx
f0102e6e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;   // substracting pointer blocks size [ sizeof(struct PageInfo) ]  , distance between them in type
f0102e74:	89 f7                	mov    %esi,%edi
f0102e76:	2b b8 ac 1f 00 00    	sub    0x1fac(%eax),%edi
f0102e7c:	89 f8                	mov    %edi,%eax
f0102e7e:	c1 f8 03             	sar    $0x3,%eax
f0102e81:	c1 e0 0c             	shl    $0xc,%eax
f0102e84:	39 c2                	cmp    %eax,%edx
f0102e86:	0f 85 f5 01 00 00    	jne    f0103081 <mem_init+0x1c7b>
	kern_pgdir[0] = 0;
f0102e8c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e92:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e97:	0f 85 06 02 00 00    	jne    f01030a3 <mem_init+0x1c9d>
	pp0->pp_ref = 0;
f0102e9d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102ea3:	83 ec 0c             	sub    $0xc,%esp
f0102ea6:	56                   	push   %esi
f0102ea7:	e8 30 e2 ff ff       	call   f01010dc <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102eac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eaf:	8d 83 78 db fe ff    	lea    -0x12488(%ebx),%eax
f0102eb5:	89 04 24             	mov    %eax,(%esp)
f0102eb8:	e8 a6 02 00 00       	call   f0103163 <cprintf>
}
f0102ebd:	83 c4 10             	add    $0x10,%esp
f0102ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ec3:	5b                   	pop    %ebx
f0102ec4:	5e                   	pop    %esi
f0102ec5:	5f                   	pop    %edi
f0102ec6:	5d                   	pop    %ebp
f0102ec7:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ec8:	50                   	push   %eax
f0102ec9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ecc:	8d 83 2c d4 fe ff    	lea    -0x12bd4(%ebx),%eax
f0102ed2:	50                   	push   %eax
f0102ed3:	68 da 00 00 00       	push   $0xda
f0102ed8:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102ede:	50                   	push   %eax
f0102edf:	e8 3c d2 ff ff       	call   f0100120 <_panic>
	assert((pp0 = page_alloc(0)));
f0102ee4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ee7:	8d 83 d6 dc fe ff    	lea    -0x1232a(%ebx),%eax
f0102eed:	50                   	push   %eax
f0102eee:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102ef4:	50                   	push   %eax
f0102ef5:	68 01 04 00 00       	push   $0x401
f0102efa:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102f00:	50                   	push   %eax
f0102f01:	e8 1a d2 ff ff       	call   f0100120 <_panic>
	assert((pp1 = page_alloc(0)));
f0102f06:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f09:	8d 83 ec dc fe ff    	lea    -0x12314(%ebx),%eax
f0102f0f:	50                   	push   %eax
f0102f10:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102f16:	50                   	push   %eax
f0102f17:	68 02 04 00 00       	push   $0x402
f0102f1c:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102f22:	50                   	push   %eax
f0102f23:	e8 f8 d1 ff ff       	call   f0100120 <_panic>
	assert((pp2 = page_alloc(0)));
f0102f28:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f2b:	8d 83 02 dd fe ff    	lea    -0x122fe(%ebx),%eax
f0102f31:	50                   	push   %eax
f0102f32:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102f38:	50                   	push   %eax
f0102f39:	68 03 04 00 00       	push   $0x403
f0102f3e:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102f44:	50                   	push   %eax
f0102f45:	e8 d6 d1 ff ff       	call   f0100120 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f4a:	52                   	push   %edx
f0102f4b:	89 cb                	mov    %ecx,%ebx
f0102f4d:	8d 81 50 d4 fe ff    	lea    -0x12bb0(%ecx),%eax
f0102f53:	50                   	push   %eax
f0102f54:	6a 55                	push   $0x55
f0102f56:	8d 81 c8 db fe ff    	lea    -0x12438(%ecx),%eax
f0102f5c:	50                   	push   %eax
f0102f5d:	e8 be d1 ff ff       	call   f0100120 <_panic>
f0102f62:	52                   	push   %edx
f0102f63:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f66:	8d 83 50 d4 fe ff    	lea    -0x12bb0(%ebx),%eax
f0102f6c:	50                   	push   %eax
f0102f6d:	6a 55                	push   $0x55
f0102f6f:	8d 83 c8 db fe ff    	lea    -0x12438(%ebx),%eax
f0102f75:	50                   	push   %eax
f0102f76:	e8 a5 d1 ff ff       	call   f0100120 <_panic>
	assert(pp1->pp_ref == 1);
f0102f7b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f7e:	8d 83 d3 dd fe ff    	lea    -0x1222d(%ebx),%eax
f0102f84:	50                   	push   %eax
f0102f85:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102f8b:	50                   	push   %eax
f0102f8c:	68 08 04 00 00       	push   $0x408
f0102f91:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102f97:	50                   	push   %eax
f0102f98:	e8 83 d1 ff ff       	call   f0100120 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f9d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fa0:	8d 83 04 db fe ff    	lea    -0x124fc(%ebx),%eax
f0102fa6:	50                   	push   %eax
f0102fa7:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102fad:	50                   	push   %eax
f0102fae:	68 09 04 00 00       	push   $0x409
f0102fb3:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102fb9:	50                   	push   %eax
f0102fba:	e8 61 d1 ff ff       	call   f0100120 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102fbf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fc2:	8d 83 28 db fe ff    	lea    -0x124d8(%ebx),%eax
f0102fc8:	50                   	push   %eax
f0102fc9:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102fcf:	50                   	push   %eax
f0102fd0:	68 0b 04 00 00       	push   $0x40b
f0102fd5:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102fdb:	50                   	push   %eax
f0102fdc:	e8 3f d1 ff ff       	call   f0100120 <_panic>
	assert(pp2->pp_ref == 1);
f0102fe1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fe4:	8d 83 f5 dd fe ff    	lea    -0x1220b(%ebx),%eax
f0102fea:	50                   	push   %eax
f0102feb:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0102ff1:	50                   	push   %eax
f0102ff2:	68 0c 04 00 00       	push   $0x40c
f0102ff7:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0102ffd:	50                   	push   %eax
f0102ffe:	e8 1d d1 ff ff       	call   f0100120 <_panic>
	assert(pp1->pp_ref == 0);
f0103003:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103006:	8d 83 5f de fe ff    	lea    -0x121a1(%ebx),%eax
f010300c:	50                   	push   %eax
f010300d:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0103013:	50                   	push   %eax
f0103014:	68 0d 04 00 00       	push   $0x40d
f0103019:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010301f:	50                   	push   %eax
f0103020:	e8 fb d0 ff ff       	call   f0100120 <_panic>
f0103025:	52                   	push   %edx
f0103026:	89 cb                	mov    %ecx,%ebx
f0103028:	8d 81 50 d4 fe ff    	lea    -0x12bb0(%ecx),%eax
f010302e:	50                   	push   %eax
f010302f:	6a 55                	push   $0x55
f0103031:	8d 81 c8 db fe ff    	lea    -0x12438(%ecx),%eax
f0103037:	50                   	push   %eax
f0103038:	e8 e3 d0 ff ff       	call   f0100120 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010303d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103040:	8d 83 4c db fe ff    	lea    -0x124b4(%ebx),%eax
f0103046:	50                   	push   %eax
f0103047:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010304d:	50                   	push   %eax
f010304e:	68 0f 04 00 00       	push   $0x40f
f0103053:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f0103059:	50                   	push   %eax
f010305a:	e8 c1 d0 ff ff       	call   f0100120 <_panic>
	assert(pp2->pp_ref == 0);
f010305f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103062:	8d 83 2d de fe ff    	lea    -0x121d3(%ebx),%eax
f0103068:	50                   	push   %eax
f0103069:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f010306f:	50                   	push   %eax
f0103070:	68 11 04 00 00       	push   $0x411
f0103075:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010307b:	50                   	push   %eax
f010307c:	e8 9f d0 ff ff       	call   f0100120 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103081:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103084:	8d 83 90 d6 fe ff    	lea    -0x12970(%ebx),%eax
f010308a:	50                   	push   %eax
f010308b:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0103091:	50                   	push   %eax
f0103092:	68 14 04 00 00       	push   $0x414
f0103097:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f010309d:	50                   	push   %eax
f010309e:	e8 7d d0 ff ff       	call   f0100120 <_panic>
	assert(pp0->pp_ref == 1);
f01030a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030a6:	8d 83 e4 dd fe ff    	lea    -0x1221c(%ebx),%eax
f01030ac:	50                   	push   %eax
f01030ad:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f01030b3:	50                   	push   %eax
f01030b4:	68 16 04 00 00       	push   $0x416
f01030b9:	8d 83 a1 db fe ff    	lea    -0x1245f(%ebx),%eax
f01030bf:	50                   	push   %eax
f01030c0:	e8 5b d0 ff ff       	call   f0100120 <_panic>

f01030c5 <tlb_invalidate>:
{
f01030c5:	55                   	push   %ebp
f01030c6:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01030c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030cb:	0f 01 38             	invlpg (%eax)
}
f01030ce:	5d                   	pop    %ebp
f01030cf:	c3                   	ret    

f01030d0 <__x86.get_pc_thunk.dx>:
f01030d0:	8b 14 24             	mov    (%esp),%edx
f01030d3:	c3                   	ret    

f01030d4 <__x86.get_pc_thunk.cx>:
f01030d4:	8b 0c 24             	mov    (%esp),%ecx
f01030d7:	c3                   	ret    

f01030d8 <__x86.get_pc_thunk.di>:
f01030d8:	8b 3c 24             	mov    (%esp),%edi
f01030db:	c3                   	ret    

f01030dc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01030dc:	55                   	push   %ebp
f01030dd:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f01030df:	8b 45 08             	mov    0x8(%ebp),%eax
f01030e2:	ba 70 00 00 00       	mov    $0x70,%edx
f01030e7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01030e8:	ba 71 00 00 00       	mov    $0x71,%edx
f01030ed:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01030ee:	0f b6 c0             	movzbl %al,%eax
}
f01030f1:	5d                   	pop    %ebp
f01030f2:	c3                   	ret    

f01030f3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01030f3:	55                   	push   %ebp
f01030f4:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port)); // $ sign for iemmediate value of adress // % sign for register values
f01030f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01030f9:	ba 70 00 00 00       	mov    $0x70,%edx
f01030fe:	ee                   	out    %al,(%dx)
f01030ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103102:	ba 71 00 00 00       	mov    $0x71,%edx
f0103107:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103108:	5d                   	pop    %ebp
f0103109:	c3                   	ret    

f010310a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010310a:	55                   	push   %ebp
f010310b:	89 e5                	mov    %esp,%ebp
f010310d:	53                   	push   %ebx
f010310e:	83 ec 10             	sub    $0x10,%esp
f0103111:	e8 c0 d0 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f0103116:	81 c3 f6 41 01 00    	add    $0x141f6,%ebx
	cputchar(ch);
f010311c:	ff 75 08             	push   0x8(%ebp)
f010311f:	e8 1d d6 ff ff       	call   f0100741 <cputchar>
	*cnt++;
}
f0103124:	83 c4 10             	add    $0x10,%esp
f0103127:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010312a:	c9                   	leave  
f010312b:	c3                   	ret    

f010312c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010312c:	55                   	push   %ebp
f010312d:	89 e5                	mov    %esp,%ebp
f010312f:	53                   	push   %ebx
f0103130:	83 ec 14             	sub    $0x14,%esp
f0103133:	e8 9e d0 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f0103138:	81 c3 d4 41 01 00    	add    $0x141d4,%ebx
	int cnt = 0;
f010313e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103145:	ff 75 0c             	push   0xc(%ebp)
f0103148:	ff 75 08             	push   0x8(%ebp)
f010314b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010314e:	50                   	push   %eax
f010314f:	8d 83 fe bd fe ff    	lea    -0x14202(%ebx),%eax
f0103155:	50                   	push   %eax
f0103156:	e8 74 04 00 00       	call   f01035cf <vprintfmt>
	return cnt;
}
f010315b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010315e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103161:	c9                   	leave  
f0103162:	c3                   	ret    

f0103163 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103163:	55                   	push   %ebp
f0103164:	89 e5                	mov    %esp,%ebp
f0103166:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103169:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010316c:	50                   	push   %eax
f010316d:	ff 75 08             	push   0x8(%ebp)
f0103170:	e8 b7 ff ff ff       	call   f010312c <vcprintf>
	va_end(ap);

	return cnt;
}
f0103175:	c9                   	leave  
f0103176:	c3                   	ret    

f0103177 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103177:	55                   	push   %ebp
f0103178:	89 e5                	mov    %esp,%ebp
f010317a:	57                   	push   %edi
f010317b:	56                   	push   %esi
f010317c:	53                   	push   %ebx
f010317d:	83 ec 14             	sub    $0x14,%esp
f0103180:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103183:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103189:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010318c:	8b 1a                	mov    (%edx),%ebx
f010318e:	8b 01                	mov    (%ecx),%eax
f0103190:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103193:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010319a:	eb 2f                	jmp    f01031cb <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010319c:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010319f:	39 c3                	cmp    %eax,%ebx
f01031a1:	7f 4e                	jg     f01031f1 <stab_binsearch+0x7a>
f01031a3:	0f b6 0a             	movzbl (%edx),%ecx
f01031a6:	83 ea 0c             	sub    $0xc,%edx
f01031a9:	39 f1                	cmp    %esi,%ecx
f01031ab:	75 ef                	jne    f010319c <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01031ad:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01031b0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01031b3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01031b7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01031ba:	73 3a                	jae    f01031f6 <stab_binsearch+0x7f>
			*region_left = m;
f01031bc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01031bf:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01031c1:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01031c4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01031cb:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01031ce:	7f 53                	jg     f0103223 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01031d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01031d3:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01031d6:	89 d0                	mov    %edx,%eax
f01031d8:	c1 e8 1f             	shr    $0x1f,%eax
f01031db:	01 d0                	add    %edx,%eax
f01031dd:	89 c7                	mov    %eax,%edi
f01031df:	d1 ff                	sar    %edi
f01031e1:	83 e0 fe             	and    $0xfffffffe,%eax
f01031e4:	01 f8                	add    %edi,%eax
f01031e6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01031e9:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01031ed:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f01031ef:	eb ae                	jmp    f010319f <stab_binsearch+0x28>
			l = true_m + 1;
f01031f1:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01031f4:	eb d5                	jmp    f01031cb <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01031f6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01031f9:	76 14                	jbe    f010320f <stab_binsearch+0x98>
			*region_right = m - 1;
f01031fb:	83 e8 01             	sub    $0x1,%eax
f01031fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103201:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103204:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103206:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010320d:	eb bc                	jmp    f01031cb <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010320f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103212:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103214:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103218:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010321a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103221:	eb a8                	jmp    f01031cb <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103223:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103227:	75 15                	jne    f010323e <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0103229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010322c:	8b 00                	mov    (%eax),%eax
f010322e:	83 e8 01             	sub    $0x1,%eax
f0103231:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103234:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103236:	83 c4 14             	add    $0x14,%esp
f0103239:	5b                   	pop    %ebx
f010323a:	5e                   	pop    %esi
f010323b:	5f                   	pop    %edi
f010323c:	5d                   	pop    %ebp
f010323d:	c3                   	ret    
		for (l = *region_right;
f010323e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103241:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103243:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103246:	8b 0f                	mov    (%edi),%ecx
f0103248:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010324b:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010324e:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103252:	39 c1                	cmp    %eax,%ecx
f0103254:	7d 0f                	jge    f0103265 <stab_binsearch+0xee>
f0103256:	0f b6 1a             	movzbl (%edx),%ebx
f0103259:	83 ea 0c             	sub    $0xc,%edx
f010325c:	39 f3                	cmp    %esi,%ebx
f010325e:	74 05                	je     f0103265 <stab_binsearch+0xee>
		     l--)
f0103260:	83 e8 01             	sub    $0x1,%eax
f0103263:	eb ed                	jmp    f0103252 <stab_binsearch+0xdb>
		*region_left = l;
f0103265:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103268:	89 07                	mov    %eax,(%edi)
}
f010326a:	eb ca                	jmp    f0103236 <stab_binsearch+0xbf>

f010326c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010326c:	55                   	push   %ebp
f010326d:	89 e5                	mov    %esp,%ebp
f010326f:	57                   	push   %edi
f0103270:	56                   	push   %esi
f0103271:	53                   	push   %ebx
f0103272:	83 ec 3c             	sub    $0x3c,%esp
f0103275:	e8 5c cf ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f010327a:	81 c3 92 40 01 00    	add    $0x14092,%ebx
f0103280:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103283:	8d 83 e8 de fe ff    	lea    -0x12118(%ebx),%eax
f0103289:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f010328b:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103292:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103295:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010329c:	8b 45 08             	mov    0x8(%ebp),%eax
f010329f:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f01032a2:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01032a9:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01032ae:	0f 86 3a 01 00 00    	jbe    f01033ee <debuginfo_eip+0x182>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01032b4:	c7 c0 79 bd 10 f0    	mov    $0xf010bd79,%eax
f01032ba:	39 83 f8 ff ff ff    	cmp    %eax,-0x8(%ebx)
f01032c0:	0f 86 ef 01 00 00    	jbe    f01034b5 <debuginfo_eip+0x249>
f01032c6:	c7 c0 7c dc 10 f0    	mov    $0xf010dc7c,%eax
f01032cc:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01032d0:	0f 85 e6 01 00 00    	jne    f01034bc <debuginfo_eip+0x250>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01032d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01032dd:	c7 c0 24 54 10 f0    	mov    $0xf0105424,%eax
f01032e3:	c7 c2 78 bd 10 f0    	mov    $0xf010bd78,%edx
f01032e9:	29 c2                	sub    %eax,%edx
f01032eb:	c1 fa 02             	sar    $0x2,%edx
f01032ee:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01032f4:	83 ea 01             	sub    $0x1,%edx
f01032f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01032fa:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01032fd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103300:	83 ec 08             	sub    $0x8,%esp
f0103303:	ff 75 08             	push   0x8(%ebp)
f0103306:	6a 64                	push   $0x64
f0103308:	e8 6a fe ff ff       	call   f0103177 <stab_binsearch>
	if (lfile == 0)
f010330d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103310:	83 c4 10             	add    $0x10,%esp
f0103313:	85 ff                	test   %edi,%edi
f0103315:	0f 84 a8 01 00 00    	je     f01034c3 <debuginfo_eip+0x257>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010331b:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f010331e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103321:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103324:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103327:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010332a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010332d:	83 ec 08             	sub    $0x8,%esp
f0103330:	ff 75 08             	push   0x8(%ebp)
f0103333:	6a 24                	push   $0x24
f0103335:	c7 c0 24 54 10 f0    	mov    $0xf0105424,%eax
f010333b:	e8 37 fe ff ff       	call   f0103177 <stab_binsearch>

	if (lfun <= rfun) {
f0103340:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103343:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f0103346:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103349:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010334c:	83 c4 10             	add    $0x10,%esp
f010334f:	89 f8                	mov    %edi,%eax
f0103351:	39 d1                	cmp    %edx,%ecx
f0103353:	7f 39                	jg     f010338e <debuginfo_eip+0x122>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103355:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0103358:	c7 c2 24 54 10 f0    	mov    $0xf0105424,%edx
f010335e:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0103361:	8b 11                	mov    (%ecx),%edx
f0103363:	c7 c0 7c dc 10 f0    	mov    $0xf010dc7c,%eax
f0103369:	81 e8 79 bd 10 f0    	sub    $0xf010bd79,%eax
f010336f:	39 c2                	cmp    %eax,%edx
f0103371:	73 09                	jae    f010337c <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103373:	81 c2 79 bd 10 f0    	add    $0xf010bd79,%edx
f0103379:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010337c:	8b 41 08             	mov    0x8(%ecx),%eax
f010337f:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f0103382:	29 45 08             	sub    %eax,0x8(%ebp)
f0103385:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103388:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010338b:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f010338e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103391:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103394:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103397:	83 ec 08             	sub    $0x8,%esp
f010339a:	6a 3a                	push   $0x3a
f010339c:	ff 76 08             	push   0x8(%esi)
f010339f:	e8 bc 09 00 00       	call   f0103d60 <strfind>
f01033a4:	2b 46 08             	sub    0x8(%esi),%eax
f01033a7:	89 46 0c             	mov    %eax,0xc(%esi)
	//	which one.
	// Your code here.

	

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); // ebp as adress
f01033aa:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01033ad:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01033b0:	83 c4 08             	add    $0x8,%esp
f01033b3:	ff 75 08             	push   0x8(%ebp)
f01033b6:	6a 44                	push   $0x44
f01033b8:	c7 c0 24 54 10 f0    	mov    $0xf0105424,%eax
f01033be:	e8 b4 fd ff ff       	call   f0103177 <stab_binsearch>
	if (lline <= rline)
f01033c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033c6:	83 c4 10             	add    $0x10,%esp
f01033c9:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01033cc:	7f 38                	jg     f0103406 <debuginfo_eip+0x19a>
	{

		info->eip_line=stabs[lline].n_desc ;
f01033ce:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01033d1:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01033d4:	c7 c0 24 54 10 f0    	mov    $0xf0105424,%eax
f01033da:	0f b7 54 88 06       	movzwl 0x6(%eax,%ecx,4),%edx
f01033df:	89 56 04             	mov    %edx,0x4(%esi)
f01033e2:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f01033e6:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01033e9:	89 75 0c             	mov    %esi,0xc(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01033ec:	eb 41                	jmp    f010342f <debuginfo_eip+0x1c3>
  	        panic("User address");
f01033ee:	83 ec 04             	sub    $0x4,%esp
f01033f1:	8d 83 f2 de fe ff    	lea    -0x1210e(%ebx),%eax
f01033f7:	50                   	push   %eax
f01033f8:	6a 7f                	push   $0x7f
f01033fa:	8d 83 ff de fe ff    	lea    -0x12101(%ebx),%eax
f0103400:	50                   	push   %eax
f0103401:	e8 1a cd ff ff       	call   f0100120 <_panic>
		cprintf("line number is not found");
f0103406:	83 ec 0c             	sub    $0xc,%esp
f0103409:	8d 83 0d df fe ff    	lea    -0x120f3(%ebx),%eax
f010340f:	50                   	push   %eax
f0103410:	e8 4e fd ff ff       	call   f0103163 <cprintf>
		return info->eip_line = -1 ;
f0103415:	c7 46 04 ff ff ff ff 	movl   $0xffffffff,0x4(%esi)
f010341c:	83 c4 10             	add    $0x10,%esp
f010341f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103424:	e9 a6 00 00 00       	jmp    f01034cf <debuginfo_eip+0x263>
f0103429:	83 ea 01             	sub    $0x1,%edx
f010342c:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010342f:	39 d7                	cmp    %edx,%edi
f0103431:	7f 3c                	jg     f010346f <debuginfo_eip+0x203>
	       && stabs[lline].n_type != N_SOL
f0103433:	0f b6 08             	movzbl (%eax),%ecx
f0103436:	80 f9 84             	cmp    $0x84,%cl
f0103439:	74 0b                	je     f0103446 <debuginfo_eip+0x1da>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010343b:	80 f9 64             	cmp    $0x64,%cl
f010343e:	75 e9                	jne    f0103429 <debuginfo_eip+0x1bd>
f0103440:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0103444:	74 e3                	je     f0103429 <debuginfo_eip+0x1bd>
		lline--;
	
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103446:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103449:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010344c:	c7 c0 24 54 10 f0    	mov    $0xf0105424,%eax
f0103452:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0103455:	c7 c0 7c dc 10 f0    	mov    $0xf010dc7c,%eax
f010345b:	81 e8 79 bd 10 f0    	sub    $0xf010bd79,%eax
f0103461:	39 c2                	cmp    %eax,%edx
f0103463:	73 0d                	jae    f0103472 <debuginfo_eip+0x206>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103465:	81 c2 79 bd 10 f0    	add    $0xf010bd79,%edx
f010346b:	89 16                	mov    %edx,(%esi)
f010346d:	eb 03                	jmp    f0103472 <debuginfo_eip+0x206>
f010346f:	8b 75 0c             	mov    0xc(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103472:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103477:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010347a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010347d:	39 cf                	cmp    %ecx,%edi
f010347f:	7d 4e                	jge    f01034cf <debuginfo_eip+0x263>
		for (lline = lfun + 1;
f0103481:	83 c7 01             	add    $0x1,%edi
f0103484:	89 f8                	mov    %edi,%eax
f0103486:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f0103489:	c7 c2 24 54 10 f0    	mov    $0xf0105424,%edx
f010348f:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0103493:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0103496:	eb 04                	jmp    f010349c <debuginfo_eip+0x230>
			info->eip_fn_narg++;
f0103498:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010349c:	39 c3                	cmp    %eax,%ebx
f010349e:	7e 2a                	jle    f01034ca <debuginfo_eip+0x25e>
f01034a0:	0f b6 0a             	movzbl (%edx),%ecx
f01034a3:	83 c0 01             	add    $0x1,%eax
f01034a6:	83 c2 0c             	add    $0xc,%edx
f01034a9:	80 f9 a0             	cmp    $0xa0,%cl
f01034ac:	74 ea                	je     f0103498 <debuginfo_eip+0x22c>
	return 0;
f01034ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01034b3:	eb 1a                	jmp    f01034cf <debuginfo_eip+0x263>
		return -1;
f01034b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01034ba:	eb 13                	jmp    f01034cf <debuginfo_eip+0x263>
f01034bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01034c1:	eb 0c                	jmp    f01034cf <debuginfo_eip+0x263>
		return -1;
f01034c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01034c8:	eb 05                	jmp    f01034cf <debuginfo_eip+0x263>
	return 0;
f01034ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034d2:	5b                   	pop    %ebx
f01034d3:	5e                   	pop    %esi
f01034d4:	5f                   	pop    %edi
f01034d5:	5d                   	pop    %ebp
f01034d6:	c3                   	ret    

f01034d7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01034d7:	55                   	push   %ebp
f01034d8:	89 e5                	mov    %esp,%ebp
f01034da:	57                   	push   %edi
f01034db:	56                   	push   %esi
f01034dc:	53                   	push   %ebx
f01034dd:	83 ec 2c             	sub    $0x2c,%esp
f01034e0:	e8 ef fb ff ff       	call   f01030d4 <__x86.get_pc_thunk.cx>
f01034e5:	81 c1 27 3e 01 00    	add    $0x13e27,%ecx
f01034eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01034ee:	89 c7                	mov    %eax,%edi
f01034f0:	89 d6                	mov    %edx,%esi
f01034f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01034f5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034f8:	89 d1                	mov    %edx,%ecx
f01034fa:	89 c2                	mov    %eax,%edx
f01034fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01034ff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103502:	8b 45 10             	mov    0x10(%ebp),%eax
f0103505:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103508:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010350b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103512:	39 c2                	cmp    %eax,%edx
f0103514:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0103517:	72 41                	jb     f010355a <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103519:	83 ec 0c             	sub    $0xc,%esp
f010351c:	ff 75 18             	push   0x18(%ebp)
f010351f:	83 eb 01             	sub    $0x1,%ebx
f0103522:	53                   	push   %ebx
f0103523:	50                   	push   %eax
f0103524:	83 ec 08             	sub    $0x8,%esp
f0103527:	ff 75 e4             	push   -0x1c(%ebp)
f010352a:	ff 75 e0             	push   -0x20(%ebp)
f010352d:	ff 75 d4             	push   -0x2c(%ebp)
f0103530:	ff 75 d0             	push   -0x30(%ebp)
f0103533:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103536:	e8 35 0a 00 00       	call   f0103f70 <__udivdi3>
f010353b:	83 c4 18             	add    $0x18,%esp
f010353e:	52                   	push   %edx
f010353f:	50                   	push   %eax
f0103540:	89 f2                	mov    %esi,%edx
f0103542:	89 f8                	mov    %edi,%eax
f0103544:	e8 8e ff ff ff       	call   f01034d7 <printnum>
f0103549:	83 c4 20             	add    $0x20,%esp
f010354c:	eb 13                	jmp    f0103561 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010354e:	83 ec 08             	sub    $0x8,%esp
f0103551:	56                   	push   %esi
f0103552:	ff 75 18             	push   0x18(%ebp)
f0103555:	ff d7                	call   *%edi
f0103557:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010355a:	83 eb 01             	sub    $0x1,%ebx
f010355d:	85 db                	test   %ebx,%ebx
f010355f:	7f ed                	jg     f010354e <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103561:	83 ec 08             	sub    $0x8,%esp
f0103564:	56                   	push   %esi
f0103565:	83 ec 04             	sub    $0x4,%esp
f0103568:	ff 75 e4             	push   -0x1c(%ebp)
f010356b:	ff 75 e0             	push   -0x20(%ebp)
f010356e:	ff 75 d4             	push   -0x2c(%ebp)
f0103571:	ff 75 d0             	push   -0x30(%ebp)
f0103574:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103577:	e8 14 0b 00 00       	call   f0104090 <__umoddi3>
f010357c:	83 c4 14             	add    $0x14,%esp
f010357f:	0f be 84 03 26 df fe 	movsbl -0x120da(%ebx,%eax,1),%eax
f0103586:	ff 
f0103587:	50                   	push   %eax
f0103588:	ff d7                	call   *%edi
}
f010358a:	83 c4 10             	add    $0x10,%esp
f010358d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103590:	5b                   	pop    %ebx
f0103591:	5e                   	pop    %esi
f0103592:	5f                   	pop    %edi
f0103593:	5d                   	pop    %ebp
f0103594:	c3                   	ret    

f0103595 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103595:	55                   	push   %ebp
f0103596:	89 e5                	mov    %esp,%ebp
f0103598:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010359b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010359f:	8b 10                	mov    (%eax),%edx
f01035a1:	3b 50 04             	cmp    0x4(%eax),%edx
f01035a4:	73 0a                	jae    f01035b0 <sprintputch+0x1b>
		*b->buf++ = ch;
f01035a6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01035a9:	89 08                	mov    %ecx,(%eax)
f01035ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01035ae:	88 02                	mov    %al,(%edx)
}
f01035b0:	5d                   	pop    %ebp
f01035b1:	c3                   	ret    

f01035b2 <printfmt>:
{
f01035b2:	55                   	push   %ebp
f01035b3:	89 e5                	mov    %esp,%ebp
f01035b5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01035b8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01035bb:	50                   	push   %eax
f01035bc:	ff 75 10             	push   0x10(%ebp)
f01035bf:	ff 75 0c             	push   0xc(%ebp)
f01035c2:	ff 75 08             	push   0x8(%ebp)
f01035c5:	e8 05 00 00 00       	call   f01035cf <vprintfmt>
}
f01035ca:	83 c4 10             	add    $0x10,%esp
f01035cd:	c9                   	leave  
f01035ce:	c3                   	ret    

f01035cf <vprintfmt>:
{
f01035cf:	55                   	push   %ebp
f01035d0:	89 e5                	mov    %esp,%ebp
f01035d2:	57                   	push   %edi
f01035d3:	56                   	push   %esi
f01035d4:	53                   	push   %ebx
f01035d5:	83 ec 3c             	sub    $0x3c,%esp
f01035d8:	e8 8b d1 ff ff       	call   f0100768 <__x86.get_pc_thunk.ax>
f01035dd:	05 2f 3d 01 00       	add    $0x13d2f,%eax
f01035e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01035e5:	8b 75 08             	mov    0x8(%ebp),%esi
f01035e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01035eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01035ee:	8d 80 38 1d 00 00    	lea    0x1d38(%eax),%eax
f01035f4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01035f7:	eb 0a                	jmp    f0103603 <vprintfmt+0x34>
			putch(ch, putdat);
f01035f9:	83 ec 08             	sub    $0x8,%esp
f01035fc:	57                   	push   %edi
f01035fd:	50                   	push   %eax
f01035fe:	ff d6                	call   *%esi
f0103600:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103603:	83 c3 01             	add    $0x1,%ebx
f0103606:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010360a:	83 f8 25             	cmp    $0x25,%eax
f010360d:	74 0c                	je     f010361b <vprintfmt+0x4c>
			if (ch == '\0')
f010360f:	85 c0                	test   %eax,%eax
f0103611:	75 e6                	jne    f01035f9 <vprintfmt+0x2a>
}
f0103613:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103616:	5b                   	pop    %ebx
f0103617:	5e                   	pop    %esi
f0103618:	5f                   	pop    %edi
f0103619:	5d                   	pop    %ebp
f010361a:	c3                   	ret    
		padc = ' ';
f010361b:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f010361f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0103626:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010362d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0103634:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103639:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010363c:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010363f:	8d 43 01             	lea    0x1(%ebx),%eax
f0103642:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103645:	0f b6 13             	movzbl (%ebx),%edx
f0103648:	8d 42 dd             	lea    -0x23(%edx),%eax
f010364b:	3c 55                	cmp    $0x55,%al
f010364d:	0f 87 fd 03 00 00    	ja     f0103a50 <.L20>
f0103653:	0f b6 c0             	movzbl %al,%eax
f0103656:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103659:	89 ce                	mov    %ecx,%esi
f010365b:	03 b4 81 b0 df fe ff 	add    -0x12050(%ecx,%eax,4),%esi
f0103662:	ff e6                	jmp    *%esi

f0103664 <.L68>:
f0103664:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0103667:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f010366b:	eb d2                	jmp    f010363f <vprintfmt+0x70>

f010366d <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f010366d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103670:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0103674:	eb c9                	jmp    f010363f <vprintfmt+0x70>

f0103676 <.L31>:
f0103676:	0f b6 d2             	movzbl %dl,%edx
f0103679:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f010367c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103681:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0103684:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103687:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010368b:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f010368e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103691:	83 f9 09             	cmp    $0x9,%ecx
f0103694:	77 58                	ja     f01036ee <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0103696:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0103699:	eb e9                	jmp    f0103684 <.L31+0xe>

f010369b <.L34>:
			precision = va_arg(ap, int);
f010369b:	8b 45 14             	mov    0x14(%ebp),%eax
f010369e:	8b 00                	mov    (%eax),%eax
f01036a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01036a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01036a6:	8d 40 04             	lea    0x4(%eax),%eax
f01036a9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01036ac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01036af:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01036b3:	79 8a                	jns    f010363f <vprintfmt+0x70>
				width = precision, precision = -1;
f01036b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01036b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01036bb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01036c2:	e9 78 ff ff ff       	jmp    f010363f <vprintfmt+0x70>

f01036c7 <.L33>:
f01036c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01036ca:	85 d2                	test   %edx,%edx
f01036cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01036d1:	0f 49 c2             	cmovns %edx,%eax
f01036d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01036d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01036da:	e9 60 ff ff ff       	jmp    f010363f <vprintfmt+0x70>

f01036df <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01036df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01036e2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f01036e9:	e9 51 ff ff ff       	jmp    f010363f <vprintfmt+0x70>
f01036ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01036f1:	89 75 08             	mov    %esi,0x8(%ebp)
f01036f4:	eb b9                	jmp    f01036af <.L34+0x14>

f01036f6 <.L27>:
			lflag++;
f01036f6:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01036fa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01036fd:	e9 3d ff ff ff       	jmp    f010363f <vprintfmt+0x70>

f0103702 <.L30>:
			putch(va_arg(ap, int), putdat);
f0103702:	8b 75 08             	mov    0x8(%ebp),%esi
f0103705:	8b 45 14             	mov    0x14(%ebp),%eax
f0103708:	8d 58 04             	lea    0x4(%eax),%ebx
f010370b:	83 ec 08             	sub    $0x8,%esp
f010370e:	57                   	push   %edi
f010370f:	ff 30                	push   (%eax)
f0103711:	ff d6                	call   *%esi
			break;
f0103713:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103716:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0103719:	e9 c8 02 00 00       	jmp    f01039e6 <.L25+0x45>

f010371e <.L28>:
			err = va_arg(ap, int);
f010371e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103721:	8b 45 14             	mov    0x14(%ebp),%eax
f0103724:	8d 58 04             	lea    0x4(%eax),%ebx
f0103727:	8b 10                	mov    (%eax),%edx
f0103729:	89 d0                	mov    %edx,%eax
f010372b:	f7 d8                	neg    %eax
f010372d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103730:	83 f8 06             	cmp    $0x6,%eax
f0103733:	7f 27                	jg     f010375c <.L28+0x3e>
f0103735:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103738:	8b 14 82             	mov    (%edx,%eax,4),%edx
f010373b:	85 d2                	test   %edx,%edx
f010373d:	74 1d                	je     f010375c <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f010373f:	52                   	push   %edx
f0103740:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103743:	8d 80 f4 db fe ff    	lea    -0x1240c(%eax),%eax
f0103749:	50                   	push   %eax
f010374a:	57                   	push   %edi
f010374b:	56                   	push   %esi
f010374c:	e8 61 fe ff ff       	call   f01035b2 <printfmt>
f0103751:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103754:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0103757:	e9 8a 02 00 00       	jmp    f01039e6 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010375c:	50                   	push   %eax
f010375d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103760:	8d 80 3e df fe ff    	lea    -0x120c2(%eax),%eax
f0103766:	50                   	push   %eax
f0103767:	57                   	push   %edi
f0103768:	56                   	push   %esi
f0103769:	e8 44 fe ff ff       	call   f01035b2 <printfmt>
f010376e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103771:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103774:	e9 6d 02 00 00       	jmp    f01039e6 <.L25+0x45>

f0103779 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0103779:	8b 75 08             	mov    0x8(%ebp),%esi
f010377c:	8b 45 14             	mov    0x14(%ebp),%eax
f010377f:	83 c0 04             	add    $0x4,%eax
f0103782:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103785:	8b 45 14             	mov    0x14(%ebp),%eax
f0103788:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010378a:	85 d2                	test   %edx,%edx
f010378c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010378f:	8d 80 37 df fe ff    	lea    -0x120c9(%eax),%eax
f0103795:	0f 45 c2             	cmovne %edx,%eax
f0103798:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f010379b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010379f:	7e 06                	jle    f01037a7 <.L24+0x2e>
f01037a1:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01037a5:	75 0d                	jne    f01037b4 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01037a7:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01037aa:	89 c3                	mov    %eax,%ebx
f01037ac:	03 45 d4             	add    -0x2c(%ebp),%eax
f01037af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01037b2:	eb 58                	jmp    f010380c <.L24+0x93>
f01037b4:	83 ec 08             	sub    $0x8,%esp
f01037b7:	ff 75 d8             	push   -0x28(%ebp)
f01037ba:	ff 75 c8             	push   -0x38(%ebp)
f01037bd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01037c0:	e8 44 04 00 00       	call   f0103c09 <strnlen>
f01037c5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01037c8:	29 c2                	sub    %eax,%edx
f01037ca:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01037cd:	83 c4 10             	add    $0x10,%esp
f01037d0:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01037d2:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01037d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01037d9:	eb 0f                	jmp    f01037ea <.L24+0x71>
					putch(padc, putdat);
f01037db:	83 ec 08             	sub    $0x8,%esp
f01037de:	57                   	push   %edi
f01037df:	ff 75 d4             	push   -0x2c(%ebp)
f01037e2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01037e4:	83 eb 01             	sub    $0x1,%ebx
f01037e7:	83 c4 10             	add    $0x10,%esp
f01037ea:	85 db                	test   %ebx,%ebx
f01037ec:	7f ed                	jg     f01037db <.L24+0x62>
f01037ee:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01037f1:	85 d2                	test   %edx,%edx
f01037f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01037f8:	0f 49 c2             	cmovns %edx,%eax
f01037fb:	29 c2                	sub    %eax,%edx
f01037fd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103800:	eb a5                	jmp    f01037a7 <.L24+0x2e>
					putch(ch, putdat);
f0103802:	83 ec 08             	sub    $0x8,%esp
f0103805:	57                   	push   %edi
f0103806:	52                   	push   %edx
f0103807:	ff d6                	call   *%esi
f0103809:	83 c4 10             	add    $0x10,%esp
f010380c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010380f:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103811:	83 c3 01             	add    $0x1,%ebx
f0103814:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103818:	0f be d0             	movsbl %al,%edx
f010381b:	85 d2                	test   %edx,%edx
f010381d:	74 4b                	je     f010386a <.L24+0xf1>
f010381f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103823:	78 06                	js     f010382b <.L24+0xb2>
f0103825:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0103829:	78 1e                	js     f0103849 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f010382b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010382f:	74 d1                	je     f0103802 <.L24+0x89>
f0103831:	0f be c0             	movsbl %al,%eax
f0103834:	83 e8 20             	sub    $0x20,%eax
f0103837:	83 f8 5e             	cmp    $0x5e,%eax
f010383a:	76 c6                	jbe    f0103802 <.L24+0x89>
					putch('?', putdat);
f010383c:	83 ec 08             	sub    $0x8,%esp
f010383f:	57                   	push   %edi
f0103840:	6a 3f                	push   $0x3f
f0103842:	ff d6                	call   *%esi
f0103844:	83 c4 10             	add    $0x10,%esp
f0103847:	eb c3                	jmp    f010380c <.L24+0x93>
f0103849:	89 cb                	mov    %ecx,%ebx
f010384b:	eb 0e                	jmp    f010385b <.L24+0xe2>
				putch(' ', putdat);
f010384d:	83 ec 08             	sub    $0x8,%esp
f0103850:	57                   	push   %edi
f0103851:	6a 20                	push   $0x20
f0103853:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0103855:	83 eb 01             	sub    $0x1,%ebx
f0103858:	83 c4 10             	add    $0x10,%esp
f010385b:	85 db                	test   %ebx,%ebx
f010385d:	7f ee                	jg     f010384d <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010385f:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103862:	89 45 14             	mov    %eax,0x14(%ebp)
f0103865:	e9 7c 01 00 00       	jmp    f01039e6 <.L25+0x45>
f010386a:	89 cb                	mov    %ecx,%ebx
f010386c:	eb ed                	jmp    f010385b <.L24+0xe2>

f010386e <.L29>:
	if (lflag >= 2)
f010386e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103871:	8b 75 08             	mov    0x8(%ebp),%esi
f0103874:	83 f9 01             	cmp    $0x1,%ecx
f0103877:	7f 1b                	jg     f0103894 <.L29+0x26>
	else if (lflag)
f0103879:	85 c9                	test   %ecx,%ecx
f010387b:	74 63                	je     f01038e0 <.L29+0x72>
		return va_arg(*ap, long);
f010387d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103880:	8b 00                	mov    (%eax),%eax
f0103882:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103885:	99                   	cltd   
f0103886:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103889:	8b 45 14             	mov    0x14(%ebp),%eax
f010388c:	8d 40 04             	lea    0x4(%eax),%eax
f010388f:	89 45 14             	mov    %eax,0x14(%ebp)
f0103892:	eb 17                	jmp    f01038ab <.L29+0x3d>
		return va_arg(*ap, long long);
f0103894:	8b 45 14             	mov    0x14(%ebp),%eax
f0103897:	8b 50 04             	mov    0x4(%eax),%edx
f010389a:	8b 00                	mov    (%eax),%eax
f010389c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010389f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01038a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01038a5:	8d 40 08             	lea    0x8(%eax),%eax
f01038a8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01038ab:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01038ae:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01038b1:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f01038b6:	85 db                	test   %ebx,%ebx
f01038b8:	0f 89 0e 01 00 00    	jns    f01039cc <.L25+0x2b>
				putch('-', putdat);
f01038be:	83 ec 08             	sub    $0x8,%esp
f01038c1:	57                   	push   %edi
f01038c2:	6a 2d                	push   $0x2d
f01038c4:	ff d6                	call   *%esi
				num = -(long long) num;
f01038c6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01038c9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01038cc:	f7 d9                	neg    %ecx
f01038ce:	83 d3 00             	adc    $0x0,%ebx
f01038d1:	f7 db                	neg    %ebx
f01038d3:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01038d6:	ba 0a 00 00 00       	mov    $0xa,%edx
f01038db:	e9 ec 00 00 00       	jmp    f01039cc <.L25+0x2b>
		return va_arg(*ap, int);
f01038e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01038e3:	8b 00                	mov    (%eax),%eax
f01038e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01038e8:	99                   	cltd   
f01038e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01038ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01038ef:	8d 40 04             	lea    0x4(%eax),%eax
f01038f2:	89 45 14             	mov    %eax,0x14(%ebp)
f01038f5:	eb b4                	jmp    f01038ab <.L29+0x3d>

f01038f7 <.L23>:
	if (lflag >= 2)
f01038f7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01038fa:	8b 75 08             	mov    0x8(%ebp),%esi
f01038fd:	83 f9 01             	cmp    $0x1,%ecx
f0103900:	7f 1e                	jg     f0103920 <.L23+0x29>
	else if (lflag)
f0103902:	85 c9                	test   %ecx,%ecx
f0103904:	74 32                	je     f0103938 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0103906:	8b 45 14             	mov    0x14(%ebp),%eax
f0103909:	8b 08                	mov    (%eax),%ecx
f010390b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103910:	8d 40 04             	lea    0x4(%eax),%eax
f0103913:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103916:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f010391b:	e9 ac 00 00 00       	jmp    f01039cc <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0103920:	8b 45 14             	mov    0x14(%ebp),%eax
f0103923:	8b 08                	mov    (%eax),%ecx
f0103925:	8b 58 04             	mov    0x4(%eax),%ebx
f0103928:	8d 40 08             	lea    0x8(%eax),%eax
f010392b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010392e:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0103933:	e9 94 00 00 00       	jmp    f01039cc <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0103938:	8b 45 14             	mov    0x14(%ebp),%eax
f010393b:	8b 08                	mov    (%eax),%ecx
f010393d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103942:	8d 40 04             	lea    0x4(%eax),%eax
f0103945:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103948:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f010394d:	eb 7d                	jmp    f01039cc <.L25+0x2b>

f010394f <.L26>:
	if (lflag >= 2)
f010394f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103952:	8b 75 08             	mov    0x8(%ebp),%esi
f0103955:	83 f9 01             	cmp    $0x1,%ecx
f0103958:	7f 1b                	jg     f0103975 <.L26+0x26>
	else if (lflag)
f010395a:	85 c9                	test   %ecx,%ecx
f010395c:	74 2c                	je     f010398a <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f010395e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103961:	8b 08                	mov    (%eax),%ecx
f0103963:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103968:	8d 40 04             	lea    0x4(%eax),%eax
f010396b:	89 45 14             	mov    %eax,0x14(%ebp)
            base=8;
f010396e:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f0103973:	eb 57                	jmp    f01039cc <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0103975:	8b 45 14             	mov    0x14(%ebp),%eax
f0103978:	8b 08                	mov    (%eax),%ecx
f010397a:	8b 58 04             	mov    0x4(%eax),%ebx
f010397d:	8d 40 08             	lea    0x8(%eax),%eax
f0103980:	89 45 14             	mov    %eax,0x14(%ebp)
            base=8;
f0103983:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f0103988:	eb 42                	jmp    f01039cc <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010398a:	8b 45 14             	mov    0x14(%ebp),%eax
f010398d:	8b 08                	mov    (%eax),%ecx
f010398f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103994:	8d 40 04             	lea    0x4(%eax),%eax
f0103997:	89 45 14             	mov    %eax,0x14(%ebp)
            base=8;
f010399a:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f010399f:	eb 2b                	jmp    f01039cc <.L25+0x2b>

f01039a1 <.L25>:
			putch('0', putdat);
f01039a1:	8b 75 08             	mov    0x8(%ebp),%esi
f01039a4:	83 ec 08             	sub    $0x8,%esp
f01039a7:	57                   	push   %edi
f01039a8:	6a 30                	push   $0x30
f01039aa:	ff d6                	call   *%esi
			putch('x', putdat);
f01039ac:	83 c4 08             	add    $0x8,%esp
f01039af:	57                   	push   %edi
f01039b0:	6a 78                	push   $0x78
f01039b2:	ff d6                	call   *%esi
			num = (unsigned long long)
f01039b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01039b7:	8b 08                	mov    (%eax),%ecx
f01039b9:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f01039be:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01039c1:	8d 40 04             	lea    0x4(%eax),%eax
f01039c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01039c7:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f01039cc:	83 ec 0c             	sub    $0xc,%esp
f01039cf:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01039d3:	50                   	push   %eax
f01039d4:	ff 75 d4             	push   -0x2c(%ebp)
f01039d7:	52                   	push   %edx
f01039d8:	53                   	push   %ebx
f01039d9:	51                   	push   %ecx
f01039da:	89 fa                	mov    %edi,%edx
f01039dc:	89 f0                	mov    %esi,%eax
f01039de:	e8 f4 fa ff ff       	call   f01034d7 <printnum>
			break;
f01039e3:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01039e6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01039e9:	e9 15 fc ff ff       	jmp    f0103603 <vprintfmt+0x34>

f01039ee <.L21>:
	if (lflag >= 2)
f01039ee:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01039f1:	8b 75 08             	mov    0x8(%ebp),%esi
f01039f4:	83 f9 01             	cmp    $0x1,%ecx
f01039f7:	7f 1b                	jg     f0103a14 <.L21+0x26>
	else if (lflag)
f01039f9:	85 c9                	test   %ecx,%ecx
f01039fb:	74 2c                	je     f0103a29 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f01039fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a00:	8b 08                	mov    (%eax),%ecx
f0103a02:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103a07:	8d 40 04             	lea    0x4(%eax),%eax
f0103a0a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103a0d:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f0103a12:	eb b8                	jmp    f01039cc <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0103a14:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a17:	8b 08                	mov    (%eax),%ecx
f0103a19:	8b 58 04             	mov    0x4(%eax),%ebx
f0103a1c:	8d 40 08             	lea    0x8(%eax),%eax
f0103a1f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103a22:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0103a27:	eb a3                	jmp    f01039cc <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0103a29:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a2c:	8b 08                	mov    (%eax),%ecx
f0103a2e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103a33:	8d 40 04             	lea    0x4(%eax),%eax
f0103a36:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103a39:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0103a3e:	eb 8c                	jmp    f01039cc <.L25+0x2b>

f0103a40 <.L35>:
			putch(ch, putdat);
f0103a40:	8b 75 08             	mov    0x8(%ebp),%esi
f0103a43:	83 ec 08             	sub    $0x8,%esp
f0103a46:	57                   	push   %edi
f0103a47:	6a 25                	push   $0x25
f0103a49:	ff d6                	call   *%esi
			break;
f0103a4b:	83 c4 10             	add    $0x10,%esp
f0103a4e:	eb 96                	jmp    f01039e6 <.L25+0x45>

f0103a50 <.L20>:
			putch('%', putdat);
f0103a50:	8b 75 08             	mov    0x8(%ebp),%esi
f0103a53:	83 ec 08             	sub    $0x8,%esp
f0103a56:	57                   	push   %edi
f0103a57:	6a 25                	push   $0x25
f0103a59:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103a5b:	83 c4 10             	add    $0x10,%esp
f0103a5e:	89 d8                	mov    %ebx,%eax
f0103a60:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103a64:	74 05                	je     f0103a6b <.L20+0x1b>
f0103a66:	83 e8 01             	sub    $0x1,%eax
f0103a69:	eb f5                	jmp    f0103a60 <.L20+0x10>
f0103a6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a6e:	e9 73 ff ff ff       	jmp    f01039e6 <.L25+0x45>

f0103a73 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103a73:	55                   	push   %ebp
f0103a74:	89 e5                	mov    %esp,%ebp
f0103a76:	53                   	push   %ebx
f0103a77:	83 ec 14             	sub    $0x14,%esp
f0103a7a:	e8 57 c7 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f0103a7f:	81 c3 8d 38 01 00    	add    $0x1388d,%ebx
f0103a85:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a88:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103a8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103a8e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103a92:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103a95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103a9c:	85 c0                	test   %eax,%eax
f0103a9e:	74 2b                	je     f0103acb <vsnprintf+0x58>
f0103aa0:	85 d2                	test   %edx,%edx
f0103aa2:	7e 27                	jle    f0103acb <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103aa4:	ff 75 14             	push   0x14(%ebp)
f0103aa7:	ff 75 10             	push   0x10(%ebp)
f0103aaa:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103aad:	50                   	push   %eax
f0103aae:	8d 83 89 c2 fe ff    	lea    -0x13d77(%ebx),%eax
f0103ab4:	50                   	push   %eax
f0103ab5:	e8 15 fb ff ff       	call   f01035cf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103aba:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103abd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ac3:	83 c4 10             	add    $0x10,%esp
}
f0103ac6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ac9:	c9                   	leave  
f0103aca:	c3                   	ret    
		return -E_INVAL;
f0103acb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103ad0:	eb f4                	jmp    f0103ac6 <vsnprintf+0x53>

f0103ad2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103ad2:	55                   	push   %ebp
f0103ad3:	89 e5                	mov    %esp,%ebp
f0103ad5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103ad8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103adb:	50                   	push   %eax
f0103adc:	ff 75 10             	push   0x10(%ebp)
f0103adf:	ff 75 0c             	push   0xc(%ebp)
f0103ae2:	ff 75 08             	push   0x8(%ebp)
f0103ae5:	e8 89 ff ff ff       	call   f0103a73 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103aea:	c9                   	leave  
f0103aeb:	c3                   	ret    

f0103aec <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103aec:	55                   	push   %ebp
f0103aed:	89 e5                	mov    %esp,%ebp
f0103aef:	57                   	push   %edi
f0103af0:	56                   	push   %esi
f0103af1:	53                   	push   %ebx
f0103af2:	83 ec 1c             	sub    $0x1c,%esp
f0103af5:	e8 dc c6 ff ff       	call   f01001d6 <__x86.get_pc_thunk.bx>
f0103afa:	81 c3 12 38 01 00    	add    $0x13812,%ebx
f0103b00:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103b03:	85 c0                	test   %eax,%eax
f0103b05:	74 13                	je     f0103b1a <readline+0x2e>
		cprintf("%s", prompt);
f0103b07:	83 ec 08             	sub    $0x8,%esp
f0103b0a:	50                   	push   %eax
f0103b0b:	8d 83 f4 db fe ff    	lea    -0x1240c(%ebx),%eax
f0103b11:	50                   	push   %eax
f0103b12:	e8 4c f6 ff ff       	call   f0103163 <cprintf>
f0103b17:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103b1a:	83 ec 0c             	sub    $0xc,%esp
f0103b1d:	6a 00                	push   $0x0
f0103b1f:	e8 3e cc ff ff       	call   f0100762 <iscons>
f0103b24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103b27:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103b2a:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0103b2f:	8d 83 d4 1f 00 00    	lea    0x1fd4(%ebx),%eax
f0103b35:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103b38:	eb 45                	jmp    f0103b7f <readline+0x93>
			cprintf("read error: %e\n", c);
f0103b3a:	83 ec 08             	sub    $0x8,%esp
f0103b3d:	50                   	push   %eax
f0103b3e:	8d 83 08 e1 fe ff    	lea    -0x11ef8(%ebx),%eax
f0103b44:	50                   	push   %eax
f0103b45:	e8 19 f6 ff ff       	call   f0103163 <cprintf>
			return NULL;
f0103b4a:	83 c4 10             	add    $0x10,%esp
f0103b4d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b55:	5b                   	pop    %ebx
f0103b56:	5e                   	pop    %esi
f0103b57:	5f                   	pop    %edi
f0103b58:	5d                   	pop    %ebp
f0103b59:	c3                   	ret    
			if (echoing)
f0103b5a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b5e:	75 05                	jne    f0103b65 <readline+0x79>
			i--;
f0103b60:	83 ef 01             	sub    $0x1,%edi
f0103b63:	eb 1a                	jmp    f0103b7f <readline+0x93>
				cputchar('\b');
f0103b65:	83 ec 0c             	sub    $0xc,%esp
f0103b68:	6a 08                	push   $0x8
f0103b6a:	e8 d2 cb ff ff       	call   f0100741 <cputchar>
f0103b6f:	83 c4 10             	add    $0x10,%esp
f0103b72:	eb ec                	jmp    f0103b60 <readline+0x74>
			buf[i++] = c;
f0103b74:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103b77:	89 f0                	mov    %esi,%eax
f0103b79:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0103b7c:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103b7f:	e8 cd cb ff ff       	call   f0100751 <getchar>
f0103b84:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103b86:	85 c0                	test   %eax,%eax
f0103b88:	78 b0                	js     f0103b3a <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103b8a:	83 f8 08             	cmp    $0x8,%eax
f0103b8d:	0f 94 c0             	sete   %al
f0103b90:	83 fe 7f             	cmp    $0x7f,%esi
f0103b93:	0f 94 c2             	sete   %dl
f0103b96:	08 d0                	or     %dl,%al
f0103b98:	74 04                	je     f0103b9e <readline+0xb2>
f0103b9a:	85 ff                	test   %edi,%edi
f0103b9c:	7f bc                	jg     f0103b5a <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103b9e:	83 fe 1f             	cmp    $0x1f,%esi
f0103ba1:	7e 1c                	jle    f0103bbf <readline+0xd3>
f0103ba3:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103ba9:	7f 14                	jg     f0103bbf <readline+0xd3>
			if (echoing)
f0103bab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103baf:	74 c3                	je     f0103b74 <readline+0x88>
				cputchar(c);
f0103bb1:	83 ec 0c             	sub    $0xc,%esp
f0103bb4:	56                   	push   %esi
f0103bb5:	e8 87 cb ff ff       	call   f0100741 <cputchar>
f0103bba:	83 c4 10             	add    $0x10,%esp
f0103bbd:	eb b5                	jmp    f0103b74 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0103bbf:	83 fe 0a             	cmp    $0xa,%esi
f0103bc2:	74 05                	je     f0103bc9 <readline+0xdd>
f0103bc4:	83 fe 0d             	cmp    $0xd,%esi
f0103bc7:	75 b6                	jne    f0103b7f <readline+0x93>
			if (echoing)
f0103bc9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103bcd:	75 13                	jne    f0103be2 <readline+0xf6>
			buf[i] = 0;
f0103bcf:	c6 84 3b d4 1f 00 00 	movb   $0x0,0x1fd4(%ebx,%edi,1)
f0103bd6:	00 
			return buf;
f0103bd7:	8d 83 d4 1f 00 00    	lea    0x1fd4(%ebx),%eax
f0103bdd:	e9 70 ff ff ff       	jmp    f0103b52 <readline+0x66>
				cputchar('\n');
f0103be2:	83 ec 0c             	sub    $0xc,%esp
f0103be5:	6a 0a                	push   $0xa
f0103be7:	e8 55 cb ff ff       	call   f0100741 <cputchar>
f0103bec:	83 c4 10             	add    $0x10,%esp
f0103bef:	eb de                	jmp    f0103bcf <readline+0xe3>

f0103bf1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103bf1:	55                   	push   %ebp
f0103bf2:	89 e5                	mov    %esp,%ebp
f0103bf4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103bf7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bfc:	eb 03                	jmp    f0103c01 <strlen+0x10>
		n++;
f0103bfe:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103c01:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103c05:	75 f7                	jne    f0103bfe <strlen+0xd>
	return n;
}
f0103c07:	5d                   	pop    %ebp
f0103c08:	c3                   	ret    

f0103c09 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103c09:	55                   	push   %ebp
f0103c0a:	89 e5                	mov    %esp,%ebp
f0103c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c12:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c17:	eb 03                	jmp    f0103c1c <strnlen+0x13>
		n++;
f0103c19:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c1c:	39 d0                	cmp    %edx,%eax
f0103c1e:	74 08                	je     f0103c28 <strnlen+0x1f>
f0103c20:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103c24:	75 f3                	jne    f0103c19 <strnlen+0x10>
f0103c26:	89 c2                	mov    %eax,%edx
	return n;
}
f0103c28:	89 d0                	mov    %edx,%eax
f0103c2a:	5d                   	pop    %ebp
f0103c2b:	c3                   	ret    

f0103c2c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103c2c:	55                   	push   %ebp
f0103c2d:	89 e5                	mov    %esp,%ebp
f0103c2f:	53                   	push   %ebx
f0103c30:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103c36:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c3b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0103c3f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0103c42:	83 c0 01             	add    $0x1,%eax
f0103c45:	84 d2                	test   %dl,%dl
f0103c47:	75 f2                	jne    f0103c3b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103c49:	89 c8                	mov    %ecx,%eax
f0103c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c4e:	c9                   	leave  
f0103c4f:	c3                   	ret    

f0103c50 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103c50:	55                   	push   %ebp
f0103c51:	89 e5                	mov    %esp,%ebp
f0103c53:	53                   	push   %ebx
f0103c54:	83 ec 10             	sub    $0x10,%esp
f0103c57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103c5a:	53                   	push   %ebx
f0103c5b:	e8 91 ff ff ff       	call   f0103bf1 <strlen>
f0103c60:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103c63:	ff 75 0c             	push   0xc(%ebp)
f0103c66:	01 d8                	add    %ebx,%eax
f0103c68:	50                   	push   %eax
f0103c69:	e8 be ff ff ff       	call   f0103c2c <strcpy>
	return dst;
}
f0103c6e:	89 d8                	mov    %ebx,%eax
f0103c70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c73:	c9                   	leave  
f0103c74:	c3                   	ret    

f0103c75 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103c75:	55                   	push   %ebp
f0103c76:	89 e5                	mov    %esp,%ebp
f0103c78:	56                   	push   %esi
f0103c79:	53                   	push   %ebx
f0103c7a:	8b 75 08             	mov    0x8(%ebp),%esi
f0103c7d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c80:	89 f3                	mov    %esi,%ebx
f0103c82:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103c85:	89 f0                	mov    %esi,%eax
f0103c87:	eb 0f                	jmp    f0103c98 <strncpy+0x23>
		*dst++ = *src;
f0103c89:	83 c0 01             	add    $0x1,%eax
f0103c8c:	0f b6 0a             	movzbl (%edx),%ecx
f0103c8f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103c92:	80 f9 01             	cmp    $0x1,%cl
f0103c95:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0103c98:	39 d8                	cmp    %ebx,%eax
f0103c9a:	75 ed                	jne    f0103c89 <strncpy+0x14>
	}
	return ret;
}
f0103c9c:	89 f0                	mov    %esi,%eax
f0103c9e:	5b                   	pop    %ebx
f0103c9f:	5e                   	pop    %esi
f0103ca0:	5d                   	pop    %ebp
f0103ca1:	c3                   	ret    

f0103ca2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103ca2:	55                   	push   %ebp
f0103ca3:	89 e5                	mov    %esp,%ebp
f0103ca5:	56                   	push   %esi
f0103ca6:	53                   	push   %ebx
f0103ca7:	8b 75 08             	mov    0x8(%ebp),%esi
f0103caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103cad:	8b 55 10             	mov    0x10(%ebp),%edx
f0103cb0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103cb2:	85 d2                	test   %edx,%edx
f0103cb4:	74 21                	je     f0103cd7 <strlcpy+0x35>
f0103cb6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103cba:	89 f2                	mov    %esi,%edx
f0103cbc:	eb 09                	jmp    f0103cc7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103cbe:	83 c1 01             	add    $0x1,%ecx
f0103cc1:	83 c2 01             	add    $0x1,%edx
f0103cc4:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0103cc7:	39 c2                	cmp    %eax,%edx
f0103cc9:	74 09                	je     f0103cd4 <strlcpy+0x32>
f0103ccb:	0f b6 19             	movzbl (%ecx),%ebx
f0103cce:	84 db                	test   %bl,%bl
f0103cd0:	75 ec                	jne    f0103cbe <strlcpy+0x1c>
f0103cd2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0103cd4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103cd7:	29 f0                	sub    %esi,%eax
}
f0103cd9:	5b                   	pop    %ebx
f0103cda:	5e                   	pop    %esi
f0103cdb:	5d                   	pop    %ebp
f0103cdc:	c3                   	ret    

f0103cdd <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103cdd:	55                   	push   %ebp
f0103cde:	89 e5                	mov    %esp,%ebp
f0103ce0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103ce3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103ce6:	eb 06                	jmp    f0103cee <strcmp+0x11>
		p++, q++;
f0103ce8:	83 c1 01             	add    $0x1,%ecx
f0103ceb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103cee:	0f b6 01             	movzbl (%ecx),%eax
f0103cf1:	84 c0                	test   %al,%al
f0103cf3:	74 04                	je     f0103cf9 <strcmp+0x1c>
f0103cf5:	3a 02                	cmp    (%edx),%al
f0103cf7:	74 ef                	je     f0103ce8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103cf9:	0f b6 c0             	movzbl %al,%eax
f0103cfc:	0f b6 12             	movzbl (%edx),%edx
f0103cff:	29 d0                	sub    %edx,%eax
}
f0103d01:	5d                   	pop    %ebp
f0103d02:	c3                   	ret    

f0103d03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103d03:	55                   	push   %ebp
f0103d04:	89 e5                	mov    %esp,%ebp
f0103d06:	53                   	push   %ebx
f0103d07:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d0a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d0d:	89 c3                	mov    %eax,%ebx
f0103d0f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103d12:	eb 06                	jmp    f0103d1a <strncmp+0x17>
		n--, p++, q++;
f0103d14:	83 c0 01             	add    $0x1,%eax
f0103d17:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103d1a:	39 d8                	cmp    %ebx,%eax
f0103d1c:	74 18                	je     f0103d36 <strncmp+0x33>
f0103d1e:	0f b6 08             	movzbl (%eax),%ecx
f0103d21:	84 c9                	test   %cl,%cl
f0103d23:	74 04                	je     f0103d29 <strncmp+0x26>
f0103d25:	3a 0a                	cmp    (%edx),%cl
f0103d27:	74 eb                	je     f0103d14 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103d29:	0f b6 00             	movzbl (%eax),%eax
f0103d2c:	0f b6 12             	movzbl (%edx),%edx
f0103d2f:	29 d0                	sub    %edx,%eax
}
f0103d31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d34:	c9                   	leave  
f0103d35:	c3                   	ret    
		return 0;
f0103d36:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d3b:	eb f4                	jmp    f0103d31 <strncmp+0x2e>

f0103d3d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103d3d:	55                   	push   %ebp
f0103d3e:	89 e5                	mov    %esp,%ebp
f0103d40:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d43:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d47:	eb 03                	jmp    f0103d4c <strchr+0xf>
f0103d49:	83 c0 01             	add    $0x1,%eax
f0103d4c:	0f b6 10             	movzbl (%eax),%edx
f0103d4f:	84 d2                	test   %dl,%dl
f0103d51:	74 06                	je     f0103d59 <strchr+0x1c>
		if (*s == c)
f0103d53:	38 ca                	cmp    %cl,%dl
f0103d55:	75 f2                	jne    f0103d49 <strchr+0xc>
f0103d57:	eb 05                	jmp    f0103d5e <strchr+0x21>
			return (char *) s;
	return 0;
f0103d59:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d5e:	5d                   	pop    %ebp
f0103d5f:	c3                   	ret    

f0103d60 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103d60:	55                   	push   %ebp
f0103d61:	89 e5                	mov    %esp,%ebp
f0103d63:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d66:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d6a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103d6d:	38 ca                	cmp    %cl,%dl
f0103d6f:	74 09                	je     f0103d7a <strfind+0x1a>
f0103d71:	84 d2                	test   %dl,%dl
f0103d73:	74 05                	je     f0103d7a <strfind+0x1a>
	for (; *s; s++)
f0103d75:	83 c0 01             	add    $0x1,%eax
f0103d78:	eb f0                	jmp    f0103d6a <strfind+0xa>
			break;
	return (char *) s;
}
f0103d7a:	5d                   	pop    %ebp
f0103d7b:	c3                   	ret    

f0103d7c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103d7c:	55                   	push   %ebp
f0103d7d:	89 e5                	mov    %esp,%ebp
f0103d7f:	57                   	push   %edi
f0103d80:	56                   	push   %esi
f0103d81:	53                   	push   %ebx
f0103d82:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103d85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103d88:	85 c9                	test   %ecx,%ecx
f0103d8a:	74 2f                	je     f0103dbb <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103d8c:	89 f8                	mov    %edi,%eax
f0103d8e:	09 c8                	or     %ecx,%eax
f0103d90:	a8 03                	test   $0x3,%al
f0103d92:	75 21                	jne    f0103db5 <memset+0x39>
		c &= 0xFF;
f0103d94:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103d98:	89 d0                	mov    %edx,%eax
f0103d9a:	c1 e0 08             	shl    $0x8,%eax
f0103d9d:	89 d3                	mov    %edx,%ebx
f0103d9f:	c1 e3 18             	shl    $0x18,%ebx
f0103da2:	89 d6                	mov    %edx,%esi
f0103da4:	c1 e6 10             	shl    $0x10,%esi
f0103da7:	09 f3                	or     %esi,%ebx
f0103da9:	09 da                	or     %ebx,%edx
f0103dab:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103dad:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103db0:	fc                   	cld    
f0103db1:	f3 ab                	rep stos %eax,%es:(%edi)
f0103db3:	eb 06                	jmp    f0103dbb <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103db5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103db8:	fc                   	cld    
f0103db9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103dbb:	89 f8                	mov    %edi,%eax
f0103dbd:	5b                   	pop    %ebx
f0103dbe:	5e                   	pop    %esi
f0103dbf:	5f                   	pop    %edi
f0103dc0:	5d                   	pop    %ebp
f0103dc1:	c3                   	ret    

f0103dc2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103dc2:	55                   	push   %ebp
f0103dc3:	89 e5                	mov    %esp,%ebp
f0103dc5:	57                   	push   %edi
f0103dc6:	56                   	push   %esi
f0103dc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dca:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103dcd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103dd0:	39 c6                	cmp    %eax,%esi
f0103dd2:	73 32                	jae    f0103e06 <memmove+0x44>
f0103dd4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103dd7:	39 c2                	cmp    %eax,%edx
f0103dd9:	76 2b                	jbe    f0103e06 <memmove+0x44>
		s += n;
		d += n;
f0103ddb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103dde:	89 d6                	mov    %edx,%esi
f0103de0:	09 fe                	or     %edi,%esi
f0103de2:	09 ce                	or     %ecx,%esi
f0103de4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103dea:	75 0e                	jne    f0103dfa <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103dec:	83 ef 04             	sub    $0x4,%edi
f0103def:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103df2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103df5:	fd                   	std    
f0103df6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103df8:	eb 09                	jmp    f0103e03 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103dfa:	83 ef 01             	sub    $0x1,%edi
f0103dfd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103e00:	fd                   	std    
f0103e01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103e03:	fc                   	cld    
f0103e04:	eb 1a                	jmp    f0103e20 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e06:	89 f2                	mov    %esi,%edx
f0103e08:	09 c2                	or     %eax,%edx
f0103e0a:	09 ca                	or     %ecx,%edx
f0103e0c:	f6 c2 03             	test   $0x3,%dl
f0103e0f:	75 0a                	jne    f0103e1b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103e11:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103e14:	89 c7                	mov    %eax,%edi
f0103e16:	fc                   	cld    
f0103e17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103e19:	eb 05                	jmp    f0103e20 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0103e1b:	89 c7                	mov    %eax,%edi
f0103e1d:	fc                   	cld    
f0103e1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103e20:	5e                   	pop    %esi
f0103e21:	5f                   	pop    %edi
f0103e22:	5d                   	pop    %ebp
f0103e23:	c3                   	ret    

f0103e24 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103e24:	55                   	push   %ebp
f0103e25:	89 e5                	mov    %esp,%ebp
f0103e27:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103e2a:	ff 75 10             	push   0x10(%ebp)
f0103e2d:	ff 75 0c             	push   0xc(%ebp)
f0103e30:	ff 75 08             	push   0x8(%ebp)
f0103e33:	e8 8a ff ff ff       	call   f0103dc2 <memmove>
}
f0103e38:	c9                   	leave  
f0103e39:	c3                   	ret    

f0103e3a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103e3a:	55                   	push   %ebp
f0103e3b:	89 e5                	mov    %esp,%ebp
f0103e3d:	56                   	push   %esi
f0103e3e:	53                   	push   %ebx
f0103e3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e42:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e45:	89 c6                	mov    %eax,%esi
f0103e47:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103e4a:	eb 06                	jmp    f0103e52 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103e4c:	83 c0 01             	add    $0x1,%eax
f0103e4f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0103e52:	39 f0                	cmp    %esi,%eax
f0103e54:	74 14                	je     f0103e6a <memcmp+0x30>
		if (*s1 != *s2)
f0103e56:	0f b6 08             	movzbl (%eax),%ecx
f0103e59:	0f b6 1a             	movzbl (%edx),%ebx
f0103e5c:	38 d9                	cmp    %bl,%cl
f0103e5e:	74 ec                	je     f0103e4c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0103e60:	0f b6 c1             	movzbl %cl,%eax
f0103e63:	0f b6 db             	movzbl %bl,%ebx
f0103e66:	29 d8                	sub    %ebx,%eax
f0103e68:	eb 05                	jmp    f0103e6f <memcmp+0x35>
	}

	return 0;
f0103e6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103e6f:	5b                   	pop    %ebx
f0103e70:	5e                   	pop    %esi
f0103e71:	5d                   	pop    %ebp
f0103e72:	c3                   	ret    

f0103e73 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103e73:	55                   	push   %ebp
f0103e74:	89 e5                	mov    %esp,%ebp
f0103e76:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103e7c:	89 c2                	mov    %eax,%edx
f0103e7e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103e81:	eb 03                	jmp    f0103e86 <memfind+0x13>
f0103e83:	83 c0 01             	add    $0x1,%eax
f0103e86:	39 d0                	cmp    %edx,%eax
f0103e88:	73 04                	jae    f0103e8e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103e8a:	38 08                	cmp    %cl,(%eax)
f0103e8c:	75 f5                	jne    f0103e83 <memfind+0x10>
			break;
	return (void *) s;
}
f0103e8e:	5d                   	pop    %ebp
f0103e8f:	c3                   	ret    

f0103e90 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103e90:	55                   	push   %ebp
f0103e91:	89 e5                	mov    %esp,%ebp
f0103e93:	57                   	push   %edi
f0103e94:	56                   	push   %esi
f0103e95:	53                   	push   %ebx
f0103e96:	8b 55 08             	mov    0x8(%ebp),%edx
f0103e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103e9c:	eb 03                	jmp    f0103ea1 <strtol+0x11>
		s++;
f0103e9e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0103ea1:	0f b6 02             	movzbl (%edx),%eax
f0103ea4:	3c 20                	cmp    $0x20,%al
f0103ea6:	74 f6                	je     f0103e9e <strtol+0xe>
f0103ea8:	3c 09                	cmp    $0x9,%al
f0103eaa:	74 f2                	je     f0103e9e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103eac:	3c 2b                	cmp    $0x2b,%al
f0103eae:	74 2a                	je     f0103eda <strtol+0x4a>
	int neg = 0;
f0103eb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103eb5:	3c 2d                	cmp    $0x2d,%al
f0103eb7:	74 2b                	je     f0103ee4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103eb9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103ebf:	75 0f                	jne    f0103ed0 <strtol+0x40>
f0103ec1:	80 3a 30             	cmpb   $0x30,(%edx)
f0103ec4:	74 28                	je     f0103eee <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103ec6:	85 db                	test   %ebx,%ebx
f0103ec8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ecd:	0f 44 d8             	cmove  %eax,%ebx
f0103ed0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103ed5:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103ed8:	eb 46                	jmp    f0103f20 <strtol+0x90>
		s++;
f0103eda:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0103edd:	bf 00 00 00 00       	mov    $0x0,%edi
f0103ee2:	eb d5                	jmp    f0103eb9 <strtol+0x29>
		s++, neg = 1;
f0103ee4:	83 c2 01             	add    $0x1,%edx
f0103ee7:	bf 01 00 00 00       	mov    $0x1,%edi
f0103eec:	eb cb                	jmp    f0103eb9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103eee:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103ef2:	74 0e                	je     f0103f02 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0103ef4:	85 db                	test   %ebx,%ebx
f0103ef6:	75 d8                	jne    f0103ed0 <strtol+0x40>
		s++, base = 8;
f0103ef8:	83 c2 01             	add    $0x1,%edx
f0103efb:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103f00:	eb ce                	jmp    f0103ed0 <strtol+0x40>
		s += 2, base = 16;
f0103f02:	83 c2 02             	add    $0x2,%edx
f0103f05:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103f0a:	eb c4                	jmp    f0103ed0 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0103f0c:	0f be c0             	movsbl %al,%eax
f0103f0f:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103f12:	3b 45 10             	cmp    0x10(%ebp),%eax
f0103f15:	7d 3a                	jge    f0103f51 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0103f17:	83 c2 01             	add    $0x1,%edx
f0103f1a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0103f1e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0103f20:	0f b6 02             	movzbl (%edx),%eax
f0103f23:	8d 70 d0             	lea    -0x30(%eax),%esi
f0103f26:	89 f3                	mov    %esi,%ebx
f0103f28:	80 fb 09             	cmp    $0x9,%bl
f0103f2b:	76 df                	jbe    f0103f0c <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0103f2d:	8d 70 9f             	lea    -0x61(%eax),%esi
f0103f30:	89 f3                	mov    %esi,%ebx
f0103f32:	80 fb 19             	cmp    $0x19,%bl
f0103f35:	77 08                	ja     f0103f3f <strtol+0xaf>
			dig = *s - 'a' + 10;
f0103f37:	0f be c0             	movsbl %al,%eax
f0103f3a:	83 e8 57             	sub    $0x57,%eax
f0103f3d:	eb d3                	jmp    f0103f12 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0103f3f:	8d 70 bf             	lea    -0x41(%eax),%esi
f0103f42:	89 f3                	mov    %esi,%ebx
f0103f44:	80 fb 19             	cmp    $0x19,%bl
f0103f47:	77 08                	ja     f0103f51 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0103f49:	0f be c0             	movsbl %al,%eax
f0103f4c:	83 e8 37             	sub    $0x37,%eax
f0103f4f:	eb c1                	jmp    f0103f12 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103f51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103f55:	74 05                	je     f0103f5c <strtol+0xcc>
		*endptr = (char *) s;
f0103f57:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f5a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0103f5c:	89 c8                	mov    %ecx,%eax
f0103f5e:	f7 d8                	neg    %eax
f0103f60:	85 ff                	test   %edi,%edi
f0103f62:	0f 45 c8             	cmovne %eax,%ecx
}
f0103f65:	89 c8                	mov    %ecx,%eax
f0103f67:	5b                   	pop    %ebx
f0103f68:	5e                   	pop    %esi
f0103f69:	5f                   	pop    %edi
f0103f6a:	5d                   	pop    %ebp
f0103f6b:	c3                   	ret    
f0103f6c:	66 90                	xchg   %ax,%ax
f0103f6e:	66 90                	xchg   %ax,%ax

f0103f70 <__udivdi3>:
f0103f70:	f3 0f 1e fb          	endbr32 
f0103f74:	55                   	push   %ebp
f0103f75:	57                   	push   %edi
f0103f76:	56                   	push   %esi
f0103f77:	53                   	push   %ebx
f0103f78:	83 ec 1c             	sub    $0x1c,%esp
f0103f7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0103f7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103f83:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103f87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103f8b:	85 c0                	test   %eax,%eax
f0103f8d:	75 19                	jne    f0103fa8 <__udivdi3+0x38>
f0103f8f:	39 f3                	cmp    %esi,%ebx
f0103f91:	76 4d                	jbe    f0103fe0 <__udivdi3+0x70>
f0103f93:	31 ff                	xor    %edi,%edi
f0103f95:	89 e8                	mov    %ebp,%eax
f0103f97:	89 f2                	mov    %esi,%edx
f0103f99:	f7 f3                	div    %ebx
f0103f9b:	89 fa                	mov    %edi,%edx
f0103f9d:	83 c4 1c             	add    $0x1c,%esp
f0103fa0:	5b                   	pop    %ebx
f0103fa1:	5e                   	pop    %esi
f0103fa2:	5f                   	pop    %edi
f0103fa3:	5d                   	pop    %ebp
f0103fa4:	c3                   	ret    
f0103fa5:	8d 76 00             	lea    0x0(%esi),%esi
f0103fa8:	39 f0                	cmp    %esi,%eax
f0103faa:	76 14                	jbe    f0103fc0 <__udivdi3+0x50>
f0103fac:	31 ff                	xor    %edi,%edi
f0103fae:	31 c0                	xor    %eax,%eax
f0103fb0:	89 fa                	mov    %edi,%edx
f0103fb2:	83 c4 1c             	add    $0x1c,%esp
f0103fb5:	5b                   	pop    %ebx
f0103fb6:	5e                   	pop    %esi
f0103fb7:	5f                   	pop    %edi
f0103fb8:	5d                   	pop    %ebp
f0103fb9:	c3                   	ret    
f0103fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103fc0:	0f bd f8             	bsr    %eax,%edi
f0103fc3:	83 f7 1f             	xor    $0x1f,%edi
f0103fc6:	75 48                	jne    f0104010 <__udivdi3+0xa0>
f0103fc8:	39 f0                	cmp    %esi,%eax
f0103fca:	72 06                	jb     f0103fd2 <__udivdi3+0x62>
f0103fcc:	31 c0                	xor    %eax,%eax
f0103fce:	39 eb                	cmp    %ebp,%ebx
f0103fd0:	77 de                	ja     f0103fb0 <__udivdi3+0x40>
f0103fd2:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fd7:	eb d7                	jmp    f0103fb0 <__udivdi3+0x40>
f0103fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103fe0:	89 d9                	mov    %ebx,%ecx
f0103fe2:	85 db                	test   %ebx,%ebx
f0103fe4:	75 0b                	jne    f0103ff1 <__udivdi3+0x81>
f0103fe6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103feb:	31 d2                	xor    %edx,%edx
f0103fed:	f7 f3                	div    %ebx
f0103fef:	89 c1                	mov    %eax,%ecx
f0103ff1:	31 d2                	xor    %edx,%edx
f0103ff3:	89 f0                	mov    %esi,%eax
f0103ff5:	f7 f1                	div    %ecx
f0103ff7:	89 c6                	mov    %eax,%esi
f0103ff9:	89 e8                	mov    %ebp,%eax
f0103ffb:	89 f7                	mov    %esi,%edi
f0103ffd:	f7 f1                	div    %ecx
f0103fff:	89 fa                	mov    %edi,%edx
f0104001:	83 c4 1c             	add    $0x1c,%esp
f0104004:	5b                   	pop    %ebx
f0104005:	5e                   	pop    %esi
f0104006:	5f                   	pop    %edi
f0104007:	5d                   	pop    %ebp
f0104008:	c3                   	ret    
f0104009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104010:	89 f9                	mov    %edi,%ecx
f0104012:	ba 20 00 00 00       	mov    $0x20,%edx
f0104017:	29 fa                	sub    %edi,%edx
f0104019:	d3 e0                	shl    %cl,%eax
f010401b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010401f:	89 d1                	mov    %edx,%ecx
f0104021:	89 d8                	mov    %ebx,%eax
f0104023:	d3 e8                	shr    %cl,%eax
f0104025:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104029:	09 c1                	or     %eax,%ecx
f010402b:	89 f0                	mov    %esi,%eax
f010402d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104031:	89 f9                	mov    %edi,%ecx
f0104033:	d3 e3                	shl    %cl,%ebx
f0104035:	89 d1                	mov    %edx,%ecx
f0104037:	d3 e8                	shr    %cl,%eax
f0104039:	89 f9                	mov    %edi,%ecx
f010403b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010403f:	89 eb                	mov    %ebp,%ebx
f0104041:	d3 e6                	shl    %cl,%esi
f0104043:	89 d1                	mov    %edx,%ecx
f0104045:	d3 eb                	shr    %cl,%ebx
f0104047:	09 f3                	or     %esi,%ebx
f0104049:	89 c6                	mov    %eax,%esi
f010404b:	89 f2                	mov    %esi,%edx
f010404d:	89 d8                	mov    %ebx,%eax
f010404f:	f7 74 24 08          	divl   0x8(%esp)
f0104053:	89 d6                	mov    %edx,%esi
f0104055:	89 c3                	mov    %eax,%ebx
f0104057:	f7 64 24 0c          	mull   0xc(%esp)
f010405b:	39 d6                	cmp    %edx,%esi
f010405d:	72 19                	jb     f0104078 <__udivdi3+0x108>
f010405f:	89 f9                	mov    %edi,%ecx
f0104061:	d3 e5                	shl    %cl,%ebp
f0104063:	39 c5                	cmp    %eax,%ebp
f0104065:	73 04                	jae    f010406b <__udivdi3+0xfb>
f0104067:	39 d6                	cmp    %edx,%esi
f0104069:	74 0d                	je     f0104078 <__udivdi3+0x108>
f010406b:	89 d8                	mov    %ebx,%eax
f010406d:	31 ff                	xor    %edi,%edi
f010406f:	e9 3c ff ff ff       	jmp    f0103fb0 <__udivdi3+0x40>
f0104074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104078:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010407b:	31 ff                	xor    %edi,%edi
f010407d:	e9 2e ff ff ff       	jmp    f0103fb0 <__udivdi3+0x40>
f0104082:	66 90                	xchg   %ax,%ax
f0104084:	66 90                	xchg   %ax,%ax
f0104086:	66 90                	xchg   %ax,%ax
f0104088:	66 90                	xchg   %ax,%ax
f010408a:	66 90                	xchg   %ax,%ax
f010408c:	66 90                	xchg   %ax,%ax
f010408e:	66 90                	xchg   %ax,%ax

f0104090 <__umoddi3>:
f0104090:	f3 0f 1e fb          	endbr32 
f0104094:	55                   	push   %ebp
f0104095:	57                   	push   %edi
f0104096:	56                   	push   %esi
f0104097:	53                   	push   %ebx
f0104098:	83 ec 1c             	sub    $0x1c,%esp
f010409b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010409f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01040a3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f01040a7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f01040ab:	89 f0                	mov    %esi,%eax
f01040ad:	89 da                	mov    %ebx,%edx
f01040af:	85 ff                	test   %edi,%edi
f01040b1:	75 15                	jne    f01040c8 <__umoddi3+0x38>
f01040b3:	39 dd                	cmp    %ebx,%ebp
f01040b5:	76 39                	jbe    f01040f0 <__umoddi3+0x60>
f01040b7:	f7 f5                	div    %ebp
f01040b9:	89 d0                	mov    %edx,%eax
f01040bb:	31 d2                	xor    %edx,%edx
f01040bd:	83 c4 1c             	add    $0x1c,%esp
f01040c0:	5b                   	pop    %ebx
f01040c1:	5e                   	pop    %esi
f01040c2:	5f                   	pop    %edi
f01040c3:	5d                   	pop    %ebp
f01040c4:	c3                   	ret    
f01040c5:	8d 76 00             	lea    0x0(%esi),%esi
f01040c8:	39 df                	cmp    %ebx,%edi
f01040ca:	77 f1                	ja     f01040bd <__umoddi3+0x2d>
f01040cc:	0f bd cf             	bsr    %edi,%ecx
f01040cf:	83 f1 1f             	xor    $0x1f,%ecx
f01040d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01040d6:	75 40                	jne    f0104118 <__umoddi3+0x88>
f01040d8:	39 df                	cmp    %ebx,%edi
f01040da:	72 04                	jb     f01040e0 <__umoddi3+0x50>
f01040dc:	39 f5                	cmp    %esi,%ebp
f01040de:	77 dd                	ja     f01040bd <__umoddi3+0x2d>
f01040e0:	89 da                	mov    %ebx,%edx
f01040e2:	89 f0                	mov    %esi,%eax
f01040e4:	29 e8                	sub    %ebp,%eax
f01040e6:	19 fa                	sbb    %edi,%edx
f01040e8:	eb d3                	jmp    f01040bd <__umoddi3+0x2d>
f01040ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01040f0:	89 e9                	mov    %ebp,%ecx
f01040f2:	85 ed                	test   %ebp,%ebp
f01040f4:	75 0b                	jne    f0104101 <__umoddi3+0x71>
f01040f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01040fb:	31 d2                	xor    %edx,%edx
f01040fd:	f7 f5                	div    %ebp
f01040ff:	89 c1                	mov    %eax,%ecx
f0104101:	89 d8                	mov    %ebx,%eax
f0104103:	31 d2                	xor    %edx,%edx
f0104105:	f7 f1                	div    %ecx
f0104107:	89 f0                	mov    %esi,%eax
f0104109:	f7 f1                	div    %ecx
f010410b:	89 d0                	mov    %edx,%eax
f010410d:	31 d2                	xor    %edx,%edx
f010410f:	eb ac                	jmp    f01040bd <__umoddi3+0x2d>
f0104111:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104118:	8b 44 24 04          	mov    0x4(%esp),%eax
f010411c:	ba 20 00 00 00       	mov    $0x20,%edx
f0104121:	29 c2                	sub    %eax,%edx
f0104123:	89 c1                	mov    %eax,%ecx
f0104125:	89 e8                	mov    %ebp,%eax
f0104127:	d3 e7                	shl    %cl,%edi
f0104129:	89 d1                	mov    %edx,%ecx
f010412b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010412f:	d3 e8                	shr    %cl,%eax
f0104131:	89 c1                	mov    %eax,%ecx
f0104133:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104137:	09 f9                	or     %edi,%ecx
f0104139:	89 df                	mov    %ebx,%edi
f010413b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010413f:	89 c1                	mov    %eax,%ecx
f0104141:	d3 e5                	shl    %cl,%ebp
f0104143:	89 d1                	mov    %edx,%ecx
f0104145:	d3 ef                	shr    %cl,%edi
f0104147:	89 c1                	mov    %eax,%ecx
f0104149:	89 f0                	mov    %esi,%eax
f010414b:	d3 e3                	shl    %cl,%ebx
f010414d:	89 d1                	mov    %edx,%ecx
f010414f:	89 fa                	mov    %edi,%edx
f0104151:	d3 e8                	shr    %cl,%eax
f0104153:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104158:	09 d8                	or     %ebx,%eax
f010415a:	f7 74 24 08          	divl   0x8(%esp)
f010415e:	89 d3                	mov    %edx,%ebx
f0104160:	d3 e6                	shl    %cl,%esi
f0104162:	f7 e5                	mul    %ebp
f0104164:	89 c7                	mov    %eax,%edi
f0104166:	89 d1                	mov    %edx,%ecx
f0104168:	39 d3                	cmp    %edx,%ebx
f010416a:	72 06                	jb     f0104172 <__umoddi3+0xe2>
f010416c:	75 0e                	jne    f010417c <__umoddi3+0xec>
f010416e:	39 c6                	cmp    %eax,%esi
f0104170:	73 0a                	jae    f010417c <__umoddi3+0xec>
f0104172:	29 e8                	sub    %ebp,%eax
f0104174:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0104178:	89 d1                	mov    %edx,%ecx
f010417a:	89 c7                	mov    %eax,%edi
f010417c:	89 f5                	mov    %esi,%ebp
f010417e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104182:	29 fd                	sub    %edi,%ebp
f0104184:	19 cb                	sbb    %ecx,%ebx
f0104186:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f010418b:	89 d8                	mov    %ebx,%eax
f010418d:	d3 e0                	shl    %cl,%eax
f010418f:	89 f1                	mov    %esi,%ecx
f0104191:	d3 ed                	shr    %cl,%ebp
f0104193:	d3 eb                	shr    %cl,%ebx
f0104195:	09 e8                	or     %ebp,%eax
f0104197:	89 da                	mov    %ebx,%edx
f0104199:	83 c4 1c             	add    $0x1c,%esp
f010419c:	5b                   	pop    %ebx
f010419d:	5e                   	pop    %esi
f010419e:	5f                   	pop    %edi
f010419f:	5d                   	pop    %ebp
f01041a0:	c3                   	ret    
