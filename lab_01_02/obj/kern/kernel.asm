
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
f0100015:	b8 00 00 18 00       	mov    $0x180000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 29 01 00 00       	call   f0100175 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 e0 f8 07 00    	add    $0x7f8e0,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 20 20 18 f0    	mov    $0xf0182020,%eax
f0100058:	c7 c2 00 11 18 f0    	mov    $0xf0181100,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 61 4f 00 00       	call   f0104fca <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 5d 05 00 00       	call   f01005cb <cons_init>

	//cprintf("6828 decimal is %o octal!\n", 6828);

	//cprintf("x=%d y=%d z=%d", 3, 4);

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 d4 5a f8 ff    	lea    -0x7a52c(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 9f 3a 00 00       	call   f0103b21 <cprintf>
    cprintf("\033[31;1;4mThe World is black and white! \033[0m\n");
f0100082:	8d 83 24 5b f8 ff    	lea    -0x7a4dc(%ebx),%eax
f0100088:	89 04 24             	mov    %eax,(%esp)
f010008b:	e8 91 3a 00 00       	call   f0103b21 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100090:	e8 10 13 00 00       	call   f01013a5 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100095:	e8 e3 33 00 00       	call   f010347d <env_init>
	trap_init();
f010009a:	e8 35 3b 00 00       	call   f0103bd4 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010009f:	83 c4 08             	add    $0x8,%esp
f01000a2:	6a 00                	push   $0x0
f01000a4:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f01000aa:	e8 cf 35 00 00       	call   f010367e <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000af:	83 c4 04             	add    $0x4,%esp
f01000b2:	c7 c0 78 13 18 f0    	mov    $0xf0181378,%eax
f01000b8:	ff 30                	push   (%eax)
f01000ba:	e8 5f 39 00 00       	call   f0103a1e <env_run>

f01000bf <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000bf:	55                   	push   %ebp
f01000c0:	89 e5                	mov    %esp,%ebp
f01000c2:	56                   	push   %esi
f01000c3:	53                   	push   %ebx
f01000c4:	e8 ac 00 00 00       	call   f0100175 <__x86.get_pc_thunk.bx>
f01000c9:	81 c3 63 f8 07 00    	add    $0x7f863,%ebx
	va_list ap;

	if (panicstr)
f01000cf:	83 bb d4 17 00 00 00 	cmpl   $0x0,0x17d4(%ebx)
f01000d6:	74 0f                	je     f01000e7 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d8:	83 ec 0c             	sub    $0xc,%esp
f01000db:	6a 00                	push   $0x0
f01000dd:	e8 fd 07 00 00       	call   f01008df <monitor>
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	eb f1                	jmp    f01000d8 <_panic+0x19>
	panicstr = fmt;
f01000e7:	8b 45 10             	mov    0x10(%ebp),%eax
f01000ea:	89 83 d4 17 00 00    	mov    %eax,0x17d4(%ebx)
	asm volatile("cli; cld");
f01000f0:	fa                   	cli    
f01000f1:	fc                   	cld    
	va_start(ap, fmt);
f01000f2:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000f5:	83 ec 04             	sub    $0x4,%esp
f01000f8:	ff 75 0c             	push   0xc(%ebp)
f01000fb:	ff 75 08             	push   0x8(%ebp)
f01000fe:	8d 83 ef 5a f8 ff    	lea    -0x7a511(%ebx),%eax
f0100104:	50                   	push   %eax
f0100105:	e8 17 3a 00 00       	call   f0103b21 <cprintf>
	vcprintf(fmt, ap);
f010010a:	83 c4 08             	add    $0x8,%esp
f010010d:	56                   	push   %esi
f010010e:	ff 75 10             	push   0x10(%ebp)
f0100111:	e8 d4 39 00 00       	call   f0103aea <vcprintf>
	cprintf("\n");
f0100116:	8d 83 02 6b f8 ff    	lea    -0x794fe(%ebx),%eax
f010011c:	89 04 24             	mov    %eax,(%esp)
f010011f:	e8 fd 39 00 00       	call   f0103b21 <cprintf>
f0100124:	83 c4 10             	add    $0x10,%esp
f0100127:	eb af                	jmp    f01000d8 <_panic+0x19>

f0100129 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100129:	55                   	push   %ebp
f010012a:	89 e5                	mov    %esp,%ebp
f010012c:	56                   	push   %esi
f010012d:	53                   	push   %ebx
f010012e:	e8 42 00 00 00       	call   f0100175 <__x86.get_pc_thunk.bx>
f0100133:	81 c3 f9 f7 07 00    	add    $0x7f7f9,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100139:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010013c:	83 ec 04             	sub    $0x4,%esp
f010013f:	ff 75 0c             	push   0xc(%ebp)
f0100142:	ff 75 08             	push   0x8(%ebp)
f0100145:	8d 83 07 5b f8 ff    	lea    -0x7a4f9(%ebx),%eax
f010014b:	50                   	push   %eax
f010014c:	e8 d0 39 00 00       	call   f0103b21 <cprintf>
	vcprintf(fmt, ap);
f0100151:	83 c4 08             	add    $0x8,%esp
f0100154:	56                   	push   %esi
f0100155:	ff 75 10             	push   0x10(%ebp)
f0100158:	e8 8d 39 00 00       	call   f0103aea <vcprintf>
	cprintf("\n");
f010015d:	8d 83 02 6b f8 ff    	lea    -0x794fe(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 b6 39 00 00       	call   f0103b21 <cprintf>
	va_end(ap);
}
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100171:	5b                   	pop    %ebx
f0100172:	5e                   	pop    %esi
f0100173:	5d                   	pop    %ebp
f0100174:	c3                   	ret    

f0100175 <__x86.get_pc_thunk.bx>:
f0100175:	8b 1c 24             	mov    (%esp),%ebx
f0100178:	c3                   	ret    

f0100179 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100179:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017e:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010017f:	a8 01                	test   $0x1,%al
f0100181:	74 0a                	je     f010018d <serial_proc_data+0x14>
f0100183:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100188:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100189:	0f b6 c0             	movzbl %al,%eax
f010018c:	c3                   	ret    
		return -1;
f010018d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100192:	c3                   	ret    

f0100193 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100193:	55                   	push   %ebp
f0100194:	89 e5                	mov    %esp,%ebp
f0100196:	57                   	push   %edi
f0100197:	56                   	push   %esi
f0100198:	53                   	push   %ebx
f0100199:	83 ec 1c             	sub    $0x1c,%esp
f010019c:	e8 6a 05 00 00       	call   f010070b <__x86.get_pc_thunk.si>
f01001a1:	81 c6 8b f7 07 00    	add    $0x7f78b,%esi
f01001a7:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001a9:	8d 1d 14 18 00 00    	lea    0x1814,%ebx
f01001af:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001b5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001b8:	eb 25                	jmp    f01001df <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f01001ba:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01001c1:	8d 51 01             	lea    0x1(%ecx),%edx
f01001c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001c7:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001ca:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01001d5:	0f 44 d0             	cmove  %eax,%edx
f01001d8:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f01001df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01001e2:	ff d0                	call   *%eax
f01001e4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e7:	74 06                	je     f01001ef <cons_intr+0x5c>
		if (c == 0)
f01001e9:	85 c0                	test   %eax,%eax
f01001eb:	75 cd                	jne    f01001ba <cons_intr+0x27>
f01001ed:	eb f0                	jmp    f01001df <cons_intr+0x4c>
	}
}
f01001ef:	83 c4 1c             	add    $0x1c,%esp
f01001f2:	5b                   	pop    %ebx
f01001f3:	5e                   	pop    %esi
f01001f4:	5f                   	pop    %edi
f01001f5:	5d                   	pop    %ebp
f01001f6:	c3                   	ret    

f01001f7 <kbd_proc_data>:
{
f01001f7:	55                   	push   %ebp
f01001f8:	89 e5                	mov    %esp,%ebp
f01001fa:	56                   	push   %esi
f01001fb:	53                   	push   %ebx
f01001fc:	e8 74 ff ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0100201:	81 c3 2b f7 07 00    	add    $0x7f72b,%ebx
f0100207:	ba 64 00 00 00       	mov    $0x64,%edx
f010020c:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010020d:	a8 01                	test   $0x1,%al
f010020f:	0f 84 f7 00 00 00    	je     f010030c <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100215:	a8 20                	test   $0x20,%al
f0100217:	0f 85 f6 00 00 00    	jne    f0100313 <kbd_proc_data+0x11c>
f010021d:	ba 60 00 00 00       	mov    $0x60,%edx
f0100222:	ec                   	in     (%dx),%al
f0100223:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100225:	3c e0                	cmp    $0xe0,%al
f0100227:	74 64                	je     f010028d <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100229:	84 c0                	test   %al,%al
f010022b:	78 75                	js     f01002a2 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010022d:	8b 8b f4 17 00 00    	mov    0x17f4(%ebx),%ecx
f0100233:	f6 c1 40             	test   $0x40,%cl
f0100236:	74 0e                	je     f0100246 <kbd_proc_data+0x4f>
		data |= 0x80;
f0100238:	83 c8 80             	or     $0xffffff80,%eax
f010023b:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010023d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100240:	89 8b f4 17 00 00    	mov    %ecx,0x17f4(%ebx)
	shift |= shiftcode[data];
f0100246:	0f b6 d2             	movzbl %dl,%edx
f0100249:	0f b6 84 13 94 5c f8 	movzbl -0x7a36c(%ebx,%edx,1),%eax
f0100250:	ff 
f0100251:	0b 83 f4 17 00 00    	or     0x17f4(%ebx),%eax
	shift ^= togglecode[data];
f0100257:	0f b6 8c 13 94 5b f8 	movzbl -0x7a46c(%ebx,%edx,1),%ecx
f010025e:	ff 
f010025f:	31 c8                	xor    %ecx,%eax
f0100261:	89 83 f4 17 00 00    	mov    %eax,0x17f4(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100267:	89 c1                	mov    %eax,%ecx
f0100269:	83 e1 03             	and    $0x3,%ecx
f010026c:	8b 8c 8b f4 16 00 00 	mov    0x16f4(%ebx,%ecx,4),%ecx
f0100273:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100277:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f010027a:	a8 08                	test   $0x8,%al
f010027c:	74 61                	je     f01002df <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f010027e:	89 f2                	mov    %esi,%edx
f0100280:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100283:	83 f9 19             	cmp    $0x19,%ecx
f0100286:	77 4b                	ja     f01002d3 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f0100288:	83 ee 20             	sub    $0x20,%esi
f010028b:	eb 0c                	jmp    f0100299 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f010028d:	83 8b f4 17 00 00 40 	orl    $0x40,0x17f4(%ebx)
		return 0;
f0100294:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100299:	89 f0                	mov    %esi,%eax
f010029b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010029e:	5b                   	pop    %ebx
f010029f:	5e                   	pop    %esi
f01002a0:	5d                   	pop    %ebp
f01002a1:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002a2:	8b 8b f4 17 00 00    	mov    0x17f4(%ebx),%ecx
f01002a8:	83 e0 7f             	and    $0x7f,%eax
f01002ab:	f6 c1 40             	test   $0x40,%cl
f01002ae:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002b1:	0f b6 d2             	movzbl %dl,%edx
f01002b4:	0f b6 84 13 94 5c f8 	movzbl -0x7a36c(%ebx,%edx,1),%eax
f01002bb:	ff 
f01002bc:	83 c8 40             	or     $0x40,%eax
f01002bf:	0f b6 c0             	movzbl %al,%eax
f01002c2:	f7 d0                	not    %eax
f01002c4:	21 c8                	and    %ecx,%eax
f01002c6:	89 83 f4 17 00 00    	mov    %eax,0x17f4(%ebx)
		return 0;
f01002cc:	be 00 00 00 00       	mov    $0x0,%esi
f01002d1:	eb c6                	jmp    f0100299 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f01002d3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002d6:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002d9:	83 fa 1a             	cmp    $0x1a,%edx
f01002dc:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002df:	f7 d0                	not    %eax
f01002e1:	a8 06                	test   $0x6,%al
f01002e3:	75 b4                	jne    f0100299 <kbd_proc_data+0xa2>
f01002e5:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002eb:	75 ac                	jne    f0100299 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f01002ed:	83 ec 0c             	sub    $0xc,%esp
f01002f0:	8d 83 51 5b f8 ff    	lea    -0x7a4af(%ebx),%eax
f01002f6:	50                   	push   %eax
f01002f7:	e8 25 38 00 00       	call   f0103b21 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002fc:	b8 03 00 00 00       	mov    $0x3,%eax
f0100301:	ba 92 00 00 00       	mov    $0x92,%edx
f0100306:	ee                   	out    %al,(%dx)
}
f0100307:	83 c4 10             	add    $0x10,%esp
f010030a:	eb 8d                	jmp    f0100299 <kbd_proc_data+0xa2>
		return -1;
f010030c:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100311:	eb 86                	jmp    f0100299 <kbd_proc_data+0xa2>
		return -1;
f0100313:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100318:	e9 7c ff ff ff       	jmp    f0100299 <kbd_proc_data+0xa2>

f010031d <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010031d:	55                   	push   %ebp
f010031e:	89 e5                	mov    %esp,%ebp
f0100320:	57                   	push   %edi
f0100321:	56                   	push   %esi
f0100322:	53                   	push   %ebx
f0100323:	83 ec 1c             	sub    $0x1c,%esp
f0100326:	e8 4a fe ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f010032b:	81 c3 01 f6 07 00    	add    $0x7f601,%ebx
f0100331:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100334:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100339:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010033e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100343:	89 fa                	mov    %edi,%edx
f0100345:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100346:	a8 20                	test   $0x20,%al
f0100348:	75 13                	jne    f010035d <cons_putc+0x40>
f010034a:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100350:	7f 0b                	jg     f010035d <cons_putc+0x40>
f0100352:	89 ca                	mov    %ecx,%edx
f0100354:	ec                   	in     (%dx),%al
f0100355:	ec                   	in     (%dx),%al
f0100356:	ec                   	in     (%dx),%al
f0100357:	ec                   	in     (%dx),%al
	     i++)
f0100358:	83 c6 01             	add    $0x1,%esi
f010035b:	eb e6                	jmp    f0100343 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f010035d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100361:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100364:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100369:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010036a:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010036f:	bf 79 03 00 00       	mov    $0x379,%edi
f0100374:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100379:	89 fa                	mov    %edi,%edx
f010037b:	ec                   	in     (%dx),%al
f010037c:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100382:	7f 0f                	jg     f0100393 <cons_putc+0x76>
f0100384:	84 c0                	test   %al,%al
f0100386:	78 0b                	js     f0100393 <cons_putc+0x76>
f0100388:	89 ca                	mov    %ecx,%edx
f010038a:	ec                   	in     (%dx),%al
f010038b:	ec                   	in     (%dx),%al
f010038c:	ec                   	in     (%dx),%al
f010038d:	ec                   	in     (%dx),%al
f010038e:	83 c6 01             	add    $0x1,%esi
f0100391:	eb e6                	jmp    f0100379 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100393:	ba 78 03 00 00       	mov    $0x378,%edx
f0100398:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010039c:	ee                   	out    %al,(%dx)
f010039d:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003a2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003a7:	ee                   	out    %al,(%dx)
f01003a8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ad:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003b1:	89 f8                	mov    %edi,%eax
f01003b3:	80 cc 07             	or     $0x7,%ah
f01003b6:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003bc:	0f 45 c7             	cmovne %edi,%eax
f01003bf:	89 c7                	mov    %eax,%edi
f01003c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003c4:	0f b6 c0             	movzbl %al,%eax
f01003c7:	89 f9                	mov    %edi,%ecx
f01003c9:	80 f9 0a             	cmp    $0xa,%cl
f01003cc:	0f 84 e4 00 00 00    	je     f01004b6 <cons_putc+0x199>
f01003d2:	83 f8 0a             	cmp    $0xa,%eax
f01003d5:	7f 46                	jg     f010041d <cons_putc+0x100>
f01003d7:	83 f8 08             	cmp    $0x8,%eax
f01003da:	0f 84 a8 00 00 00    	je     f0100488 <cons_putc+0x16b>
f01003e0:	83 f8 09             	cmp    $0x9,%eax
f01003e3:	0f 85 da 00 00 00    	jne    f01004c3 <cons_putc+0x1a6>
		cons_putc(' ');
f01003e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ee:	e8 2a ff ff ff       	call   f010031d <cons_putc>
		cons_putc(' ');
f01003f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f8:	e8 20 ff ff ff       	call   f010031d <cons_putc>
		cons_putc(' ');
f01003fd:	b8 20 00 00 00       	mov    $0x20,%eax
f0100402:	e8 16 ff ff ff       	call   f010031d <cons_putc>
		cons_putc(' ');
f0100407:	b8 20 00 00 00       	mov    $0x20,%eax
f010040c:	e8 0c ff ff ff       	call   f010031d <cons_putc>
		cons_putc(' ');
f0100411:	b8 20 00 00 00       	mov    $0x20,%eax
f0100416:	e8 02 ff ff ff       	call   f010031d <cons_putc>
		break;
f010041b:	eb 26                	jmp    f0100443 <cons_putc+0x126>
	switch (c & 0xff) {
f010041d:	83 f8 0d             	cmp    $0xd,%eax
f0100420:	0f 85 9d 00 00 00    	jne    f01004c3 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100426:	0f b7 83 1c 1a 00 00 	movzwl 0x1a1c(%ebx),%eax
f010042d:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100433:	c1 e8 16             	shr    $0x16,%eax
f0100436:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100439:	c1 e0 04             	shl    $0x4,%eax
f010043c:	66 89 83 1c 1a 00 00 	mov    %ax,0x1a1c(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100443:	66 81 bb 1c 1a 00 00 	cmpw   $0x7cf,0x1a1c(%ebx)
f010044a:	cf 07 
f010044c:	0f 87 98 00 00 00    	ja     f01004ea <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100452:	8b 8b 24 1a 00 00    	mov    0x1a24(%ebx),%ecx
f0100458:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045d:	89 ca                	mov    %ecx,%edx
f010045f:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100460:	0f b7 9b 1c 1a 00 00 	movzwl 0x1a1c(%ebx),%ebx
f0100467:	8d 71 01             	lea    0x1(%ecx),%esi
f010046a:	89 d8                	mov    %ebx,%eax
f010046c:	66 c1 e8 08          	shr    $0x8,%ax
f0100470:	89 f2                	mov    %esi,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100478:	89 ca                	mov    %ecx,%edx
f010047a:	ee                   	out    %al,(%dx)
f010047b:	89 d8                	mov    %ebx,%eax
f010047d:	89 f2                	mov    %esi,%edx
f010047f:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100480:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100483:	5b                   	pop    %ebx
f0100484:	5e                   	pop    %esi
f0100485:	5f                   	pop    %edi
f0100486:	5d                   	pop    %ebp
f0100487:	c3                   	ret    
		if (crt_pos > 0) {
f0100488:	0f b7 83 1c 1a 00 00 	movzwl 0x1a1c(%ebx),%eax
f010048f:	66 85 c0             	test   %ax,%ax
f0100492:	74 be                	je     f0100452 <cons_putc+0x135>
			crt_pos--;
f0100494:	83 e8 01             	sub    $0x1,%eax
f0100497:	66 89 83 1c 1a 00 00 	mov    %ax,0x1a1c(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010049e:	0f b7 c0             	movzwl %ax,%eax
f01004a1:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004a5:	b2 00                	mov    $0x0,%dl
f01004a7:	83 ca 20             	or     $0x20,%edx
f01004aa:	8b 8b 20 1a 00 00    	mov    0x1a20(%ebx),%ecx
f01004b0:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004b4:	eb 8d                	jmp    f0100443 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004b6:	66 83 83 1c 1a 00 00 	addw   $0x50,0x1a1c(%ebx)
f01004bd:	50 
f01004be:	e9 63 ff ff ff       	jmp    f0100426 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004c3:	0f b7 83 1c 1a 00 00 	movzwl 0x1a1c(%ebx),%eax
f01004ca:	8d 50 01             	lea    0x1(%eax),%edx
f01004cd:	66 89 93 1c 1a 00 00 	mov    %dx,0x1a1c(%ebx)
f01004d4:	0f b7 c0             	movzwl %ax,%eax
f01004d7:	8b 93 20 1a 00 00    	mov    0x1a20(%ebx),%edx
f01004dd:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004e1:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f01004e5:	e9 59 ff ff ff       	jmp    f0100443 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004ea:	8b 83 20 1a 00 00    	mov    0x1a20(%ebx),%eax
f01004f0:	83 ec 04             	sub    $0x4,%esp
f01004f3:	68 00 0f 00 00       	push   $0xf00
f01004f8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004fe:	52                   	push   %edx
f01004ff:	50                   	push   %eax
f0100500:	e8 0b 4b 00 00       	call   f0105010 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100505:	8b 93 20 1a 00 00    	mov    0x1a20(%ebx),%edx
f010050b:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100511:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100517:	83 c4 10             	add    $0x10,%esp
f010051a:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010051f:	83 c0 02             	add    $0x2,%eax
f0100522:	39 d0                	cmp    %edx,%eax
f0100524:	75 f4                	jne    f010051a <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100526:	66 83 ab 1c 1a 00 00 	subw   $0x50,0x1a1c(%ebx)
f010052d:	50 
f010052e:	e9 1f ff ff ff       	jmp    f0100452 <cons_putc+0x135>

f0100533 <serial_intr>:
{
f0100533:	e8 cf 01 00 00       	call   f0100707 <__x86.get_pc_thunk.ax>
f0100538:	05 f4 f3 07 00       	add    $0x7f3f4,%eax
	if (serial_exists)
f010053d:	80 b8 28 1a 00 00 00 	cmpb   $0x0,0x1a28(%eax)
f0100544:	75 01                	jne    f0100547 <serial_intr+0x14>
f0100546:	c3                   	ret    
{
f0100547:	55                   	push   %ebp
f0100548:	89 e5                	mov    %esp,%ebp
f010054a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010054d:	8d 80 4d 08 f8 ff    	lea    -0x7f7b3(%eax),%eax
f0100553:	e8 3b fc ff ff       	call   f0100193 <cons_intr>
}
f0100558:	c9                   	leave  
f0100559:	c3                   	ret    

f010055a <kbd_intr>:
{
f010055a:	55                   	push   %ebp
f010055b:	89 e5                	mov    %esp,%ebp
f010055d:	83 ec 08             	sub    $0x8,%esp
f0100560:	e8 a2 01 00 00       	call   f0100707 <__x86.get_pc_thunk.ax>
f0100565:	05 c7 f3 07 00       	add    $0x7f3c7,%eax
	cons_intr(kbd_proc_data);
f010056a:	8d 80 cb 08 f8 ff    	lea    -0x7f735(%eax),%eax
f0100570:	e8 1e fc ff ff       	call   f0100193 <cons_intr>
}
f0100575:	c9                   	leave  
f0100576:	c3                   	ret    

f0100577 <cons_getc>:
{
f0100577:	55                   	push   %ebp
f0100578:	89 e5                	mov    %esp,%ebp
f010057a:	53                   	push   %ebx
f010057b:	83 ec 04             	sub    $0x4,%esp
f010057e:	e8 f2 fb ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0100583:	81 c3 a9 f3 07 00    	add    $0x7f3a9,%ebx
	serial_intr();
f0100589:	e8 a5 ff ff ff       	call   f0100533 <serial_intr>
	kbd_intr();
f010058e:	e8 c7 ff ff ff       	call   f010055a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100593:	8b 83 14 1a 00 00    	mov    0x1a14(%ebx),%eax
	return 0;
f0100599:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010059e:	3b 83 18 1a 00 00    	cmp    0x1a18(%ebx),%eax
f01005a4:	74 1e                	je     f01005c4 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005a6:	8d 48 01             	lea    0x1(%eax),%ecx
f01005a9:	0f b6 94 03 14 18 00 	movzbl 0x1814(%ebx,%eax,1),%edx
f01005b0:	00 
			cons.rpos = 0;
f01005b1:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01005bb:	0f 45 c1             	cmovne %ecx,%eax
f01005be:	89 83 14 1a 00 00    	mov    %eax,0x1a14(%ebx)
}
f01005c4:	89 d0                	mov    %edx,%eax
f01005c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01005c9:	c9                   	leave  
f01005ca:	c3                   	ret    

f01005cb <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005cb:	55                   	push   %ebp
f01005cc:	89 e5                	mov    %esp,%ebp
f01005ce:	57                   	push   %edi
f01005cf:	56                   	push   %esi
f01005d0:	53                   	push   %ebx
f01005d1:	83 ec 1c             	sub    $0x1c,%esp
f01005d4:	e8 9c fb ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f01005d9:	81 c3 53 f3 07 00    	add    $0x7f353,%ebx
	was = *cp;
f01005df:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005e6:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005ed:	5a a5 
	if (*cp != 0xA55A) {
f01005ef:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005f6:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005fb:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100600:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100604:	0f 84 ac 00 00 00    	je     f01006b6 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f010060a:	89 8b 24 1a 00 00    	mov    %ecx,0x1a24(%ebx)
f0100610:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100615:	89 ca                	mov    %ecx,%edx
f0100617:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100618:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010061b:	89 f2                	mov    %esi,%edx
f010061d:	ec                   	in     (%dx),%al
f010061e:	0f b6 c0             	movzbl %al,%eax
f0100621:	c1 e0 08             	shl    $0x8,%eax
f0100624:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100627:	b8 0f 00 00 00       	mov    $0xf,%eax
f010062c:	89 ca                	mov    %ecx,%edx
f010062e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010062f:	89 f2                	mov    %esi,%edx
f0100631:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100632:	89 bb 20 1a 00 00    	mov    %edi,0x1a20(%ebx)
	pos |= inb(addr_6845 + 1);
f0100638:	0f b6 c0             	movzbl %al,%eax
f010063b:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f010063e:	66 89 83 1c 1a 00 00 	mov    %ax,0x1a1c(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100645:	b9 00 00 00 00       	mov    $0x0,%ecx
f010064a:	89 c8                	mov    %ecx,%eax
f010064c:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100651:	ee                   	out    %al,(%dx)
f0100652:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100657:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010065c:	89 fa                	mov    %edi,%edx
f010065e:	ee                   	out    %al,(%dx)
f010065f:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100664:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100669:	ee                   	out    %al,(%dx)
f010066a:	be f9 03 00 00       	mov    $0x3f9,%esi
f010066f:	89 c8                	mov    %ecx,%eax
f0100671:	89 f2                	mov    %esi,%edx
f0100673:	ee                   	out    %al,(%dx)
f0100674:	b8 03 00 00 00       	mov    $0x3,%eax
f0100679:	89 fa                	mov    %edi,%edx
f010067b:	ee                   	out    %al,(%dx)
f010067c:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100681:	89 c8                	mov    %ecx,%eax
f0100683:	ee                   	out    %al,(%dx)
f0100684:	b8 01 00 00 00       	mov    $0x1,%eax
f0100689:	89 f2                	mov    %esi,%edx
f010068b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100691:	ec                   	in     (%dx),%al
f0100692:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100694:	3c ff                	cmp    $0xff,%al
f0100696:	0f 95 83 28 1a 00 00 	setne  0x1a28(%ebx)
f010069d:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006a2:	ec                   	in     (%dx),%al
f01006a3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006a8:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006a9:	80 f9 ff             	cmp    $0xff,%cl
f01006ac:	74 1e                	je     f01006cc <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006b1:	5b                   	pop    %ebx
f01006b2:	5e                   	pop    %esi
f01006b3:	5f                   	pop    %edi
f01006b4:	5d                   	pop    %ebp
f01006b5:	c3                   	ret    
		*cp = was;
f01006b6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01006bd:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006c2:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f01006c7:	e9 3e ff ff ff       	jmp    f010060a <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f01006cc:	83 ec 0c             	sub    $0xc,%esp
f01006cf:	8d 83 5d 5b f8 ff    	lea    -0x7a4a3(%ebx),%eax
f01006d5:	50                   	push   %eax
f01006d6:	e8 46 34 00 00       	call   f0103b21 <cprintf>
f01006db:	83 c4 10             	add    $0x10,%esp
}
f01006de:	eb ce                	jmp    f01006ae <cons_init+0xe3>

f01006e0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006e0:	55                   	push   %ebp
f01006e1:	89 e5                	mov    %esp,%ebp
f01006e3:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01006e9:	e8 2f fc ff ff       	call   f010031d <cons_putc>
}
f01006ee:	c9                   	leave  
f01006ef:	c3                   	ret    

f01006f0 <getchar>:

int
getchar(void)
{
f01006f0:	55                   	push   %ebp
f01006f1:	89 e5                	mov    %esp,%ebp
f01006f3:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006f6:	e8 7c fe ff ff       	call   f0100577 <cons_getc>
f01006fb:	85 c0                	test   %eax,%eax
f01006fd:	74 f7                	je     f01006f6 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006ff:	c9                   	leave  
f0100700:	c3                   	ret    

f0100701 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100701:	b8 01 00 00 00       	mov    $0x1,%eax
f0100706:	c3                   	ret    

f0100707 <__x86.get_pc_thunk.ax>:
f0100707:	8b 04 24             	mov    (%esp),%eax
f010070a:	c3                   	ret    

f010070b <__x86.get_pc_thunk.si>:
f010070b:	8b 34 24             	mov    (%esp),%esi
f010070e:	c3                   	ret    

f010070f <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010070f:	55                   	push   %ebp
f0100710:	89 e5                	mov    %esp,%ebp
f0100712:	56                   	push   %esi
f0100713:	53                   	push   %ebx
f0100714:	e8 5c fa ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0100719:	81 c3 13 f2 07 00    	add    $0x7f213,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010071f:	83 ec 04             	sub    $0x4,%esp
f0100722:	8d 83 94 5d f8 ff    	lea    -0x7a26c(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	8d 83 b2 5d f8 ff    	lea    -0x7a24e(%ebx),%eax
f010072f:	50                   	push   %eax
f0100730:	8d b3 b7 5d f8 ff    	lea    -0x7a249(%ebx),%esi
f0100736:	56                   	push   %esi
f0100737:	e8 e5 33 00 00       	call   f0103b21 <cprintf>
f010073c:	83 c4 0c             	add    $0xc,%esp
f010073f:	8d 83 50 5e f8 ff    	lea    -0x7a1b0(%ebx),%eax
f0100745:	50                   	push   %eax
f0100746:	8d 83 c0 5d f8 ff    	lea    -0x7a240(%ebx),%eax
f010074c:	50                   	push   %eax
f010074d:	56                   	push   %esi
f010074e:	e8 ce 33 00 00       	call   f0103b21 <cprintf>
f0100753:	83 c4 0c             	add    $0xc,%esp
f0100756:	8d 83 78 5e f8 ff    	lea    -0x7a188(%ebx),%eax
f010075c:	50                   	push   %eax
f010075d:	8d 83 c9 5d f8 ff    	lea    -0x7a237(%ebx),%eax
f0100763:	50                   	push   %eax
f0100764:	56                   	push   %esi
f0100765:	e8 b7 33 00 00       	call   f0103b21 <cprintf>
	return 0;
}
f010076a:	b8 00 00 00 00       	mov    $0x0,%eax
f010076f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100772:	5b                   	pop    %ebx
f0100773:	5e                   	pop    %esi
f0100774:	5d                   	pop    %ebp
f0100775:	c3                   	ret    

f0100776 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100776:	55                   	push   %ebp
f0100777:	89 e5                	mov    %esp,%ebp
f0100779:	57                   	push   %edi
f010077a:	56                   	push   %esi
f010077b:	53                   	push   %ebx
f010077c:	83 ec 18             	sub    $0x18,%esp
f010077f:	e8 f1 f9 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0100784:	81 c3 a8 f1 07 00    	add    $0x7f1a8,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010078a:	8d 83 d3 5d f8 ff    	lea    -0x7a22d(%ebx),%eax
f0100790:	50                   	push   %eax
f0100791:	e8 8b 33 00 00       	call   f0103b21 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100796:	83 c4 08             	add    $0x8,%esp
f0100799:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f010079f:	8d 83 a8 5e f8 ff    	lea    -0x7a158(%ebx),%eax
f01007a5:	50                   	push   %eax
f01007a6:	e8 76 33 00 00       	call   f0103b21 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007ab:	83 c4 0c             	add    $0xc,%esp
f01007ae:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007b4:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007ba:	50                   	push   %eax
f01007bb:	57                   	push   %edi
f01007bc:	8d 83 d0 5e f8 ff    	lea    -0x7a130(%ebx),%eax
f01007c2:	50                   	push   %eax
f01007c3:	e8 59 33 00 00       	call   f0103b21 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007c8:	83 c4 0c             	add    $0xc,%esp
f01007cb:	c7 c0 f1 53 10 f0    	mov    $0xf01053f1,%eax
f01007d1:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007d7:	52                   	push   %edx
f01007d8:	50                   	push   %eax
f01007d9:	8d 83 f4 5e f8 ff    	lea    -0x7a10c(%ebx),%eax
f01007df:	50                   	push   %eax
f01007e0:	e8 3c 33 00 00       	call   f0103b21 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007e5:	83 c4 0c             	add    $0xc,%esp
f01007e8:	c7 c0 00 11 18 f0    	mov    $0xf0181100,%eax
f01007ee:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007f4:	52                   	push   %edx
f01007f5:	50                   	push   %eax
f01007f6:	8d 83 18 5f f8 ff    	lea    -0x7a0e8(%ebx),%eax
f01007fc:	50                   	push   %eax
f01007fd:	e8 1f 33 00 00       	call   f0103b21 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100802:	83 c4 0c             	add    $0xc,%esp
f0100805:	c7 c6 20 20 18 f0    	mov    $0xf0182020,%esi
f010080b:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100811:	50                   	push   %eax
f0100812:	56                   	push   %esi
f0100813:	8d 83 3c 5f f8 ff    	lea    -0x7a0c4(%ebx),%eax
f0100819:	50                   	push   %eax
f010081a:	e8 02 33 00 00       	call   f0103b21 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010081f:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100822:	29 fe                	sub    %edi,%esi
f0100824:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010082a:	c1 fe 0a             	sar    $0xa,%esi
f010082d:	56                   	push   %esi
f010082e:	8d 83 60 5f f8 ff    	lea    -0x7a0a0(%ebx),%eax
f0100834:	50                   	push   %eax
f0100835:	e8 e7 32 00 00       	call   f0103b21 <cprintf>
	return 0;
}
f010083a:	b8 00 00 00 00       	mov    $0x0,%eax
f010083f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100842:	5b                   	pop    %ebx
f0100843:	5e                   	pop    %esi
f0100844:	5f                   	pop    %edi
f0100845:	5d                   	pop    %ebp
f0100846:	c3                   	ret    

f0100847 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100847:	55                   	push   %ebp
f0100848:	89 e5                	mov    %esp,%ebp
f010084a:	57                   	push   %edi
f010084b:	56                   	push   %esi
f010084c:	53                   	push   %ebx
f010084d:	83 ec 48             	sub    $0x48,%esp
f0100850:	e8 20 f9 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0100855:	81 c3 d7 f0 07 00    	add    $0x7f0d7,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010085b:	89 ee                	mov    %ebp,%esi
    // wrong read function, now 2/5 works

    ebp_ptr=(uint32_t*)read_ebp();  // typecast adress into int
    

    cprintf("Backtracing STACK ");
f010085d:	8d 83 ec 5d f8 ff    	lea    -0x7a214(%ebx),%eax
f0100863:	50                   	push   %eax
f0100864:	e8 b8 32 00 00       	call   f0103b21 <cprintf>

	// while noq 0x0 not NULL

    while( ebp_ptr != NULL)
f0100869:	83 c4 10             	add    $0x10,%esp
    {
    // fixed eip, now not naively changining in printf 
    eip=*(ebp_ptr+1);
    cprintf("\n ebp %08x eip %08x args %08x %08x %08x %08x %08x  ", ebp_ptr, eip, *(ebp_ptr+2), // 8 digit hexx
f010086c:	8d 83 8c 5f f8 ff    	lea    -0x7a074(%ebx),%eax
f0100872:	89 45 c4             	mov    %eax,-0x3c(%ebp)
     *(ebp_ptr+2), *(ebp_ptr+3), *(ebp_ptr+4), *(ebp_ptr+5), *(ebp_ptr+6));
	
	debuginfo_eip((uintptr_t)eip, &info); 
	
	
	cprintf("\n %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name,
f0100875:	8d 83 ff 5d f8 ff    	lea    -0x7a201(%ebx),%eax
f010087b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    while( ebp_ptr != NULL)
f010087e:	eb 4e                	jmp    f01008ce <mon_backtrace+0x87>
    eip=*(ebp_ptr+1);
f0100880:	8b 7e 04             	mov    0x4(%esi),%edi
    cprintf("\n ebp %08x eip %08x args %08x %08x %08x %08x %08x  ", ebp_ptr, eip, *(ebp_ptr+2), // 8 digit hexx
f0100883:	8b 46 08             	mov    0x8(%esi),%eax
f0100886:	83 ec 0c             	sub    $0xc,%esp
f0100889:	ff 76 18             	push   0x18(%esi)
f010088c:	ff 76 14             	push   0x14(%esi)
f010088f:	ff 76 10             	push   0x10(%esi)
f0100892:	ff 76 0c             	push   0xc(%esi)
f0100895:	50                   	push   %eax
f0100896:	50                   	push   %eax
f0100897:	57                   	push   %edi
f0100898:	56                   	push   %esi
f0100899:	ff 75 c4             	push   -0x3c(%ebp)
f010089c:	e8 80 32 00 00       	call   f0103b21 <cprintf>
	debuginfo_eip((uintptr_t)eip, &info); 
f01008a1:	83 c4 28             	add    $0x28,%esp
f01008a4:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008a7:	50                   	push   %eax
f01008a8:	57                   	push   %edi
f01008a9:	e8 ab 3b 00 00       	call   f0104459 <debuginfo_eip>
	cprintf("\n %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name,
f01008ae:	83 c4 08             	add    $0x8,%esp
f01008b1:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01008b4:	57                   	push   %edi
f01008b5:	ff 75 d8             	push   -0x28(%ebp)
f01008b8:	ff 75 dc             	push   -0x24(%ebp)
f01008bb:	ff 75 d4             	push   -0x2c(%ebp)
f01008be:	ff 75 d0             	push   -0x30(%ebp)
f01008c1:	ff 75 c0             	push   -0x40(%ebp)
f01008c4:	e8 58 32 00 00       	call   f0103b21 <cprintf>
	 eip - info.eip_fn_addr);
		
	ebp_ptr = (uint32_t*)*ebp_ptr;
f01008c9:	8b 36                	mov    (%esi),%esi
f01008cb:	83 c4 20             	add    $0x20,%esp
    while( ebp_ptr != NULL)
f01008ce:	85 f6                	test   %esi,%esi
f01008d0:	75 ae                	jne    f0100880 <mon_backtrace+0x39>


        
	return 0;

}
f01008d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008da:	5b                   	pop    %ebx
f01008db:	5e                   	pop    %esi
f01008dc:	5f                   	pop    %edi
f01008dd:	5d                   	pop    %ebp
f01008de:	c3                   	ret    

f01008df <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008df:	55                   	push   %ebp
f01008e0:	89 e5                	mov    %esp,%ebp
f01008e2:	57                   	push   %edi
f01008e3:	56                   	push   %esi
f01008e4:	53                   	push   %ebx
f01008e5:	83 ec 68             	sub    $0x68,%esp
f01008e8:	e8 88 f8 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f01008ed:	81 c3 3f f0 07 00    	add    $0x7f03f,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008f3:	8d 83 c0 5f f8 ff    	lea    -0x7a040(%ebx),%eax
f01008f9:	50                   	push   %eax
f01008fa:	e8 22 32 00 00       	call   f0103b21 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008ff:	8d 83 e4 5f f8 ff    	lea    -0x7a01c(%ebx),%eax
f0100905:	89 04 24             	mov    %eax,(%esp)
f0100908:	e8 14 32 00 00       	call   f0103b21 <cprintf>
f010090d:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100910:	8d bb 15 5e f8 ff    	lea    -0x7a1eb(%ebx),%edi
f0100916:	eb 4a                	jmp    f0100962 <monitor+0x83>
f0100918:	83 ec 08             	sub    $0x8,%esp
f010091b:	0f be c0             	movsbl %al,%eax
f010091e:	50                   	push   %eax
f010091f:	57                   	push   %edi
f0100920:	e8 66 46 00 00       	call   f0104f8b <strchr>
f0100925:	83 c4 10             	add    $0x10,%esp
f0100928:	85 c0                	test   %eax,%eax
f010092a:	74 08                	je     f0100934 <monitor+0x55>
			*buf++ = 0;
f010092c:	c6 06 00             	movb   $0x0,(%esi)
f010092f:	8d 76 01             	lea    0x1(%esi),%esi
f0100932:	eb 76                	jmp    f01009aa <monitor+0xcb>
		if (*buf == 0)
f0100934:	80 3e 00             	cmpb   $0x0,(%esi)
f0100937:	74 7c                	je     f01009b5 <monitor+0xd6>
		if (argc == MAXARGS-1) {
f0100939:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010093d:	74 0f                	je     f010094e <monitor+0x6f>
		argv[argc++] = buf;
f010093f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100942:	8d 48 01             	lea    0x1(%eax),%ecx
f0100945:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100948:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f010094c:	eb 41                	jmp    f010098f <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010094e:	83 ec 08             	sub    $0x8,%esp
f0100951:	6a 10                	push   $0x10
f0100953:	8d 83 1a 5e f8 ff    	lea    -0x7a1e6(%ebx),%eax
f0100959:	50                   	push   %eax
f010095a:	e8 c2 31 00 00       	call   f0103b21 <cprintf>
			return 0;
f010095f:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100962:	8d 83 11 5e f8 ff    	lea    -0x7a1ef(%ebx),%eax
f0100968:	89 c6                	mov    %eax,%esi
f010096a:	83 ec 0c             	sub    $0xc,%esp
f010096d:	56                   	push   %esi
f010096e:	e8 c7 43 00 00       	call   f0104d3a <readline>
		if (buf != NULL)
f0100973:	83 c4 10             	add    $0x10,%esp
f0100976:	85 c0                	test   %eax,%eax
f0100978:	74 f0                	je     f010096a <monitor+0x8b>
	argv[argc] = 0;
f010097a:	89 c6                	mov    %eax,%esi
f010097c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100983:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f010098a:	eb 1e                	jmp    f01009aa <monitor+0xcb>
			buf++;
f010098c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010098f:	0f b6 06             	movzbl (%esi),%eax
f0100992:	84 c0                	test   %al,%al
f0100994:	74 14                	je     f01009aa <monitor+0xcb>
f0100996:	83 ec 08             	sub    $0x8,%esp
f0100999:	0f be c0             	movsbl %al,%eax
f010099c:	50                   	push   %eax
f010099d:	57                   	push   %edi
f010099e:	e8 e8 45 00 00       	call   f0104f8b <strchr>
f01009a3:	83 c4 10             	add    $0x10,%esp
f01009a6:	85 c0                	test   %eax,%eax
f01009a8:	74 e2                	je     f010098c <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f01009aa:	0f b6 06             	movzbl (%esi),%eax
f01009ad:	84 c0                	test   %al,%al
f01009af:	0f 85 63 ff ff ff    	jne    f0100918 <monitor+0x39>
	argv[argc] = 0;
f01009b5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009b8:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f01009bf:	00 
	if (argc == 0)
f01009c0:	85 c0                	test   %eax,%eax
f01009c2:	74 9e                	je     f0100962 <monitor+0x83>
f01009c4:	8d b3 14 17 00 00    	lea    0x1714(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01009cf:	89 7d a0             	mov    %edi,-0x60(%ebp)
f01009d2:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f01009d4:	83 ec 08             	sub    $0x8,%esp
f01009d7:	ff 36                	push   (%esi)
f01009d9:	ff 75 a8             	push   -0x58(%ebp)
f01009dc:	e8 4a 45 00 00       	call   f0104f2b <strcmp>
f01009e1:	83 c4 10             	add    $0x10,%esp
f01009e4:	85 c0                	test   %eax,%eax
f01009e6:	74 28                	je     f0100a10 <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009e8:	83 c7 01             	add    $0x1,%edi
f01009eb:	83 c6 0c             	add    $0xc,%esi
f01009ee:	83 ff 03             	cmp    $0x3,%edi
f01009f1:	75 e1                	jne    f01009d4 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009f3:	8b 7d a0             	mov    -0x60(%ebp),%edi
f01009f6:	83 ec 08             	sub    $0x8,%esp
f01009f9:	ff 75 a8             	push   -0x58(%ebp)
f01009fc:	8d 83 37 5e f8 ff    	lea    -0x7a1c9(%ebx),%eax
f0100a02:	50                   	push   %eax
f0100a03:	e8 19 31 00 00       	call   f0103b21 <cprintf>
	return 0;
f0100a08:	83 c4 10             	add    $0x10,%esp
f0100a0b:	e9 52 ff ff ff       	jmp    f0100962 <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a10:	89 f8                	mov    %edi,%eax
f0100a12:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a15:	83 ec 04             	sub    $0x4,%esp
f0100a18:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a1b:	ff 75 08             	push   0x8(%ebp)
f0100a1e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a21:	52                   	push   %edx
f0100a22:	ff 75 a4             	push   -0x5c(%ebp)
f0100a25:	ff 94 83 1c 17 00 00 	call   *0x171c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a2c:	83 c4 10             	add    $0x10,%esp
f0100a2f:	85 c0                	test   %eax,%eax
f0100a31:	0f 89 2b ff ff ff    	jns    f0100962 <monitor+0x83>
				break;
	}
}
f0100a37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a3a:	5b                   	pop    %ebx
f0100a3b:	5e                   	pop    %esi
f0100a3c:	5f                   	pop    %edi
f0100a3d:	5d                   	pop    %ebp
f0100a3e:	c3                   	ret    

f0100a3f <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a3f:	55                   	push   %ebp
f0100a40:	89 e5                	mov    %esp,%ebp
f0100a42:	57                   	push   %edi
f0100a43:	56                   	push   %esi
f0100a44:	53                   	push   %ebx
f0100a45:	83 ec 18             	sub    $0x18,%esp
f0100a48:	e8 28 f7 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0100a4d:	81 c3 df ee 07 00    	add    $0x7eedf,%ebx
f0100a53:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a55:	50                   	push   %eax
f0100a56:	e8 3f 30 00 00       	call   f0103a9a <mc146818_read>
f0100a5b:	89 c7                	mov    %eax,%edi
f0100a5d:	83 c6 01             	add    $0x1,%esi
f0100a60:	89 34 24             	mov    %esi,(%esp)
f0100a63:	e8 32 30 00 00       	call   f0103a9a <mc146818_read>
f0100a68:	c1 e0 08             	shl    $0x8,%eax
f0100a6b:	09 f8                	or     %edi,%eax
}
f0100a6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a70:	5b                   	pop    %ebx
f0100a71:	5e                   	pop    %esi
f0100a72:	5f                   	pop    %edi
f0100a73:	5d                   	pop    %ebp
f0100a74:	c3                   	ret    

f0100a75 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a75:	55                   	push   %ebp
f0100a76:	89 e5                	mov    %esp,%ebp
f0100a78:	53                   	push   %ebx
f0100a79:	83 ec 04             	sub    $0x4,%esp
f0100a7c:	e8 8d 28 00 00       	call   f010330e <__x86.get_pc_thunk.dx>
f0100a81:	81 c2 ab ee 07 00    	add    $0x7eeab,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a87:	83 ba 38 1a 00 00 00 	cmpl   $0x0,0x1a38(%edx)
f0100a8e:	74 38                	je     f0100ac8 <boot_alloc+0x53>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	result = nextfree;
f0100a90:	8b 8a 38 1a 00 00    	mov    0x1a38(%edx),%ecx
	nextfree += ROUNDUP(n, PGSIZE);
f0100a96:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100a9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aa0:	01 c8                	add    %ecx,%eax
f0100aa2:	89 82 38 1a 00 00    	mov    %eax,0x1a38(%edx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100aa8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100aad:	76 33                	jbe    f0100ae2 <boot_alloc+0x6d>

	if (PADDR(nextfree) >= npages * PGSIZE)  // if size of nextfree is bigger than all mapped pyhisical memory
f0100aaf:	8b 9a 34 1a 00 00    	mov    0x1a34(%edx),%ebx
f0100ab5:	c1 e3 0c             	shl    $0xc,%ebx
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0100ab8:	05 00 00 00 10       	add    $0x10000000,%eax
f0100abd:	39 c3                	cmp    %eax,%ebx
f0100abf:	76 39                	jbe    f0100afa <boot_alloc+0x85>
		panic("boot_alloc: out of memeory");
	

	return (void *)result;
}
f0100ac1:	89 c8                	mov    %ecx,%eax
f0100ac3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ac6:	c9                   	leave  
f0100ac7:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ac8:	c7 c1 20 20 18 f0    	mov    $0xf0182020,%ecx
f0100ace:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100ad4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100ada:	89 8a 38 1a 00 00    	mov    %ecx,0x1a38(%edx)
f0100ae0:	eb ae                	jmp    f0100a90 <boot_alloc+0x1b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ae2:	50                   	push   %eax
f0100ae3:	8d 82 0c 60 f8 ff    	lea    -0x79ff4(%edx),%eax
f0100ae9:	50                   	push   %eax
f0100aea:	6a 71                	push   $0x71
f0100aec:	8d 82 ed 67 f8 ff    	lea    -0x79813(%edx),%eax
f0100af2:	50                   	push   %eax
f0100af3:	89 d3                	mov    %edx,%ebx
f0100af5:	e8 c5 f5 ff ff       	call   f01000bf <_panic>
		panic("boot_alloc: out of memeory");
f0100afa:	83 ec 04             	sub    $0x4,%esp
f0100afd:	8d 82 f9 67 f8 ff    	lea    -0x79807(%edx),%eax
f0100b03:	50                   	push   %eax
f0100b04:	6a 72                	push   $0x72
f0100b06:	8d 82 ed 67 f8 ff    	lea    -0x79813(%edx),%eax
f0100b0c:	50                   	push   %eax
f0100b0d:	89 d3                	mov    %edx,%ebx
f0100b0f:	e8 ab f5 ff ff       	call   f01000bf <_panic>

f0100b14 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b14:	55                   	push   %ebp
f0100b15:	89 e5                	mov    %esp,%ebp
f0100b17:	53                   	push   %ebx
f0100b18:	83 ec 04             	sub    $0x4,%esp
f0100b1b:	e8 f2 27 00 00       	call   f0103312 <__x86.get_pc_thunk.cx>
f0100b20:	81 c1 0c ee 07 00    	add    $0x7ee0c,%ecx
f0100b26:	89 c3                	mov    %eax,%ebx
f0100b28:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b2a:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100b2d:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f0100b30:	f6 c2 01             	test   $0x1,%dl
f0100b33:	74 54                	je     f0100b89 <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b35:	89 d3                	mov    %edx,%ebx
f0100b37:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b3d:	c1 ea 0c             	shr    $0xc,%edx
f0100b40:	3b 91 34 1a 00 00    	cmp    0x1a34(%ecx),%edx
f0100b46:	73 26                	jae    f0100b6e <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100b48:	c1 e8 0c             	shr    $0xc,%eax
f0100b4b:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100b50:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b57:	89 d0                	mov    %edx,%eax
f0100b59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b5e:	f6 c2 01             	test   $0x1,%dl
f0100b61:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b66:	0f 44 c2             	cmove  %edx,%eax
}
f0100b69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b6c:	c9                   	leave  
f0100b6d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b6e:	53                   	push   %ebx
f0100b6f:	8d 81 30 60 f8 ff    	lea    -0x79fd0(%ecx),%eax
f0100b75:	50                   	push   %eax
f0100b76:	68 8b 03 00 00       	push   $0x38b
f0100b7b:	8d 81 ed 67 f8 ff    	lea    -0x79813(%ecx),%eax
f0100b81:	50                   	push   %eax
f0100b82:	89 cb                	mov    %ecx,%ebx
f0100b84:	e8 36 f5 ff ff       	call   f01000bf <_panic>
		return ~0;
f0100b89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b8e:	eb d9                	jmp    f0100b69 <check_va2pa+0x55>

f0100b90 <check_page_free_list>:
{
f0100b90:	55                   	push   %ebp
f0100b91:	89 e5                	mov    %esp,%ebp
f0100b93:	57                   	push   %edi
f0100b94:	56                   	push   %esi
f0100b95:	53                   	push   %ebx
f0100b96:	83 ec 2c             	sub    $0x2c,%esp
f0100b99:	e8 78 27 00 00       	call   f0103316 <__x86.get_pc_thunk.di>
f0100b9e:	81 c7 8e ed 07 00    	add    $0x7ed8e,%edi
f0100ba4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba7:	84 c0                	test   %al,%al
f0100ba9:	0f 85 dc 02 00 00    	jne    f0100e8b <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100baf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100bb2:	83 b8 40 1a 00 00 00 	cmpl   $0x0,0x1a40(%eax)
f0100bb9:	74 0a                	je     f0100bc5 <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bbb:	bf 00 04 00 00       	mov    $0x400,%edi
f0100bc0:	e9 29 03 00 00       	jmp    f0100eee <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100bc5:	83 ec 04             	sub    $0x4,%esp
f0100bc8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bcb:	8d 83 54 60 f8 ff    	lea    -0x79fac(%ebx),%eax
f0100bd1:	50                   	push   %eax
f0100bd2:	68 c7 02 00 00       	push   $0x2c7
f0100bd7:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100bdd:	50                   	push   %eax
f0100bde:	e8 dc f4 ff ff       	call   f01000bf <_panic>
f0100be3:	50                   	push   %eax
f0100be4:	89 cb                	mov    %ecx,%ebx
f0100be6:	8d 81 30 60 f8 ff    	lea    -0x79fd0(%ecx),%eax
f0100bec:	50                   	push   %eax
f0100bed:	6a 56                	push   $0x56
f0100bef:	8d 81 14 68 f8 ff    	lea    -0x797ec(%ecx),%eax
f0100bf5:	50                   	push   %eax
f0100bf6:	e8 c4 f4 ff ff       	call   f01000bf <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bfb:	8b 36                	mov    (%esi),%esi
f0100bfd:	85 f6                	test   %esi,%esi
f0100bff:	74 47                	je     f0100c48 <check_page_free_list+0xb8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c01:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100c04:	89 f0                	mov    %esi,%eax
f0100c06:	2b 81 2c 1a 00 00    	sub    0x1a2c(%ecx),%eax
f0100c0c:	c1 f8 03             	sar    $0x3,%eax
f0100c0f:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c12:	89 c2                	mov    %eax,%edx
f0100c14:	c1 ea 16             	shr    $0x16,%edx
f0100c17:	39 fa                	cmp    %edi,%edx
f0100c19:	73 e0                	jae    f0100bfb <check_page_free_list+0x6b>
	if (PGNUM(pa) >= npages)
f0100c1b:	89 c2                	mov    %eax,%edx
f0100c1d:	c1 ea 0c             	shr    $0xc,%edx
f0100c20:	3b 91 34 1a 00 00    	cmp    0x1a34(%ecx),%edx
f0100c26:	73 bb                	jae    f0100be3 <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100c28:	83 ec 04             	sub    $0x4,%esp
f0100c2b:	68 80 00 00 00       	push   $0x80
f0100c30:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c35:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c3a:	50                   	push   %eax
f0100c3b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c3e:	e8 87 43 00 00       	call   f0104fca <memset>
f0100c43:	83 c4 10             	add    $0x10,%esp
f0100c46:	eb b3                	jmp    f0100bfb <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100c48:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c4d:	e8 23 fe ff ff       	call   f0100a75 <boot_alloc>
f0100c52:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c55:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c58:	8b 90 40 1a 00 00    	mov    0x1a40(%eax),%edx
		assert(pp >= pages);
f0100c5e:	8b 88 2c 1a 00 00    	mov    0x1a2c(%eax),%ecx
		assert(pp < pages + npages);
f0100c64:	8b 80 34 1a 00 00    	mov    0x1a34(%eax),%eax
f0100c6a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c6d:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c70:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c75:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c7a:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c7d:	e9 07 01 00 00       	jmp    f0100d89 <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0100c82:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c85:	8d 83 22 68 f8 ff    	lea    -0x797de(%ebx),%eax
f0100c8b:	50                   	push   %eax
f0100c8c:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100c92:	50                   	push   %eax
f0100c93:	68 e1 02 00 00       	push   $0x2e1
f0100c98:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100c9e:	50                   	push   %eax
f0100c9f:	e8 1b f4 ff ff       	call   f01000bf <_panic>
		assert(pp < pages + npages);
f0100ca4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ca7:	8d 83 43 68 f8 ff    	lea    -0x797bd(%ebx),%eax
f0100cad:	50                   	push   %eax
f0100cae:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100cb4:	50                   	push   %eax
f0100cb5:	68 e2 02 00 00       	push   $0x2e2
f0100cba:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100cc0:	50                   	push   %eax
f0100cc1:	e8 f9 f3 ff ff       	call   f01000bf <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cc6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cc9:	8d 83 78 60 f8 ff    	lea    -0x79f88(%ebx),%eax
f0100ccf:	50                   	push   %eax
f0100cd0:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100cd6:	50                   	push   %eax
f0100cd7:	68 e3 02 00 00       	push   $0x2e3
f0100cdc:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100ce2:	50                   	push   %eax
f0100ce3:	e8 d7 f3 ff ff       	call   f01000bf <_panic>
		assert(page2pa(pp) != 0);
f0100ce8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ceb:	8d 83 57 68 f8 ff    	lea    -0x797a9(%ebx),%eax
f0100cf1:	50                   	push   %eax
f0100cf2:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100cf8:	50                   	push   %eax
f0100cf9:	68 e6 02 00 00       	push   $0x2e6
f0100cfe:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100d04:	50                   	push   %eax
f0100d05:	e8 b5 f3 ff ff       	call   f01000bf <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d0d:	8d 83 68 68 f8 ff    	lea    -0x79798(%ebx),%eax
f0100d13:	50                   	push   %eax
f0100d14:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100d1a:	50                   	push   %eax
f0100d1b:	68 e7 02 00 00       	push   $0x2e7
f0100d20:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100d26:	50                   	push   %eax
f0100d27:	e8 93 f3 ff ff       	call   f01000bf <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d2c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d2f:	8d 83 ac 60 f8 ff    	lea    -0x79f54(%ebx),%eax
f0100d35:	50                   	push   %eax
f0100d36:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100d3c:	50                   	push   %eax
f0100d3d:	68 e8 02 00 00       	push   $0x2e8
f0100d42:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100d48:	50                   	push   %eax
f0100d49:	e8 71 f3 ff ff       	call   f01000bf <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d4e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d51:	8d 83 81 68 f8 ff    	lea    -0x7977f(%ebx),%eax
f0100d57:	50                   	push   %eax
f0100d58:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100d5e:	50                   	push   %eax
f0100d5f:	68 e9 02 00 00       	push   $0x2e9
f0100d64:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100d6a:	50                   	push   %eax
f0100d6b:	e8 4f f3 ff ff       	call   f01000bf <_panic>
	if (PGNUM(pa) >= npages)
f0100d70:	89 c3                	mov    %eax,%ebx
f0100d72:	c1 eb 0c             	shr    $0xc,%ebx
f0100d75:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100d78:	76 6d                	jbe    f0100de7 <check_page_free_list+0x257>
	return (void *)(pa + KERNBASE);
f0100d7a:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d7f:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100d82:	77 7c                	ja     f0100e00 <check_page_free_list+0x270>
			++nfree_extmem;
f0100d84:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d87:	8b 12                	mov    (%edx),%edx
f0100d89:	85 d2                	test   %edx,%edx
f0100d8b:	0f 84 91 00 00 00    	je     f0100e22 <check_page_free_list+0x292>
		assert(pp >= pages);
f0100d91:	39 d1                	cmp    %edx,%ecx
f0100d93:	0f 87 e9 fe ff ff    	ja     f0100c82 <check_page_free_list+0xf2>
		assert(pp < pages + npages);
f0100d99:	39 d6                	cmp    %edx,%esi
f0100d9b:	0f 86 03 ff ff ff    	jbe    f0100ca4 <check_page_free_list+0x114>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100da1:	89 d0                	mov    %edx,%eax
f0100da3:	29 c8                	sub    %ecx,%eax
f0100da5:	a8 07                	test   $0x7,%al
f0100da7:	0f 85 19 ff ff ff    	jne    f0100cc6 <check_page_free_list+0x136>
	return (pp - pages) << PGSHIFT;
f0100dad:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100db0:	c1 e0 0c             	shl    $0xc,%eax
f0100db3:	0f 84 2f ff ff ff    	je     f0100ce8 <check_page_free_list+0x158>
		assert(page2pa(pp) != IOPHYSMEM);
f0100db9:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dbe:	0f 84 46 ff ff ff    	je     f0100d0a <check_page_free_list+0x17a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100dc4:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100dc9:	0f 84 5d ff ff ff    	je     f0100d2c <check_page_free_list+0x19c>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dcf:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dd4:	0f 84 74 ff ff ff    	je     f0100d4e <check_page_free_list+0x1be>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dda:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ddf:	77 8f                	ja     f0100d70 <check_page_free_list+0x1e0>
			++nfree_basemem;
f0100de1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100de5:	eb a0                	jmp    f0100d87 <check_page_free_list+0x1f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100de7:	50                   	push   %eax
f0100de8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100deb:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f0100df1:	50                   	push   %eax
f0100df2:	6a 56                	push   $0x56
f0100df4:	8d 83 14 68 f8 ff    	lea    -0x797ec(%ebx),%eax
f0100dfa:	50                   	push   %eax
f0100dfb:	e8 bf f2 ff ff       	call   f01000bf <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e00:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e03:	8d 83 d0 60 f8 ff    	lea    -0x79f30(%ebx),%eax
f0100e09:	50                   	push   %eax
f0100e0a:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100e10:	50                   	push   %eax
f0100e11:	68 ea 02 00 00       	push   $0x2ea
f0100e16:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100e1c:	50                   	push   %eax
f0100e1d:	e8 9d f2 ff ff       	call   f01000bf <_panic>
	assert(nfree_basemem > 0);
f0100e22:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e25:	85 db                	test   %ebx,%ebx
f0100e27:	7e 1e                	jle    f0100e47 <check_page_free_list+0x2b7>
	assert(nfree_extmem > 0);
f0100e29:	85 ff                	test   %edi,%edi
f0100e2b:	7e 3c                	jle    f0100e69 <check_page_free_list+0x2d9>
	cprintf("check_page_free_list() succeeded!\n");
f0100e2d:	83 ec 0c             	sub    $0xc,%esp
f0100e30:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e33:	8d 83 18 61 f8 ff    	lea    -0x79ee8(%ebx),%eax
f0100e39:	50                   	push   %eax
f0100e3a:	e8 e2 2c 00 00       	call   f0103b21 <cprintf>
}
f0100e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e42:	5b                   	pop    %ebx
f0100e43:	5e                   	pop    %esi
f0100e44:	5f                   	pop    %edi
f0100e45:	5d                   	pop    %ebp
f0100e46:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e47:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e4a:	8d 83 9b 68 f8 ff    	lea    -0x79765(%ebx),%eax
f0100e50:	50                   	push   %eax
f0100e51:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100e57:	50                   	push   %eax
f0100e58:	68 f2 02 00 00       	push   $0x2f2
f0100e5d:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100e63:	50                   	push   %eax
f0100e64:	e8 56 f2 ff ff       	call   f01000bf <_panic>
	assert(nfree_extmem > 0);
f0100e69:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e6c:	8d 83 ad 68 f8 ff    	lea    -0x79753(%ebx),%eax
f0100e72:	50                   	push   %eax
f0100e73:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0100e79:	50                   	push   %eax
f0100e7a:	68 f3 02 00 00       	push   $0x2f3
f0100e7f:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0100e85:	50                   	push   %eax
f0100e86:	e8 34 f2 ff ff       	call   f01000bf <_panic>
	if (!page_free_list)
f0100e8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e8e:	8b 80 40 1a 00 00    	mov    0x1a40(%eax),%eax
f0100e94:	85 c0                	test   %eax,%eax
f0100e96:	0f 84 29 fd ff ff    	je     f0100bc5 <check_page_free_list+0x35>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e9c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e9f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ea2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ea5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100ea8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100eab:	89 c2                	mov    %eax,%edx
f0100ead:	2b 97 2c 1a 00 00    	sub    0x1a2c(%edi),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100eb3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100eb9:	0f 95 c2             	setne  %dl
f0100ebc:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ebf:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ec3:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ec5:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ec9:	8b 00                	mov    (%eax),%eax
f0100ecb:	85 c0                	test   %eax,%eax
f0100ecd:	75 d9                	jne    f0100ea8 <check_page_free_list+0x318>
		*tp[1] = 0;
f0100ecf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ed2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ed8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ede:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ee0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ee3:	89 87 40 1a 00 00    	mov    %eax,0x1a40(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ee9:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100eee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ef1:	8b b0 40 1a 00 00    	mov    0x1a40(%eax),%esi
f0100ef7:	e9 01 fd ff ff       	jmp    f0100bfd <check_page_free_list+0x6d>

f0100efc <page_init>:
{
f0100efc:	55                   	push   %ebp
f0100efd:	89 e5                	mov    %esp,%ebp
f0100eff:	57                   	push   %edi
f0100f00:	56                   	push   %esi
f0100f01:	53                   	push   %ebx
f0100f02:	83 ec 1c             	sub    $0x1c,%esp
f0100f05:	e8 6b f2 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0100f0a:	81 c3 22 ea 07 00    	add    $0x7ea22,%ebx
	page_free_list = NULL;
f0100f10:	c7 83 40 1a 00 00 00 	movl   $0x0,0x1a40(%ebx)
f0100f17:	00 00 00 
	int nextfree = ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f0100f1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f1f:	e8 51 fb ff ff       	call   f0100a75 <boot_alloc>
f0100f24:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f29:	c1 e8 0c             	shr    $0xc,%eax
f0100f2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pages[0].pp_ref = 1;
f0100f2f:	8b 83 2c 1a 00 00    	mov    0x1a2c(%ebx),%eax
f0100f35:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		for(i=1; i < npages_basemem ; i++)
f0100f3b:	8b bb 44 1a 00 00    	mov    0x1a44(%ebx),%edi
f0100f41:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f46:	be 00 00 00 00       	mov    $0x0,%esi
f0100f4b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f50:	eb 27                	jmp    f0100f79 <page_init+0x7d>
f0100f52:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100f59:	89 d1                	mov    %edx,%ecx
f0100f5b:	03 8b 2c 1a 00 00    	add    0x1a2c(%ebx),%ecx
f0100f61:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;
f0100f67:	89 31                	mov    %esi,(%ecx)
			page_free_list = &pages[i];
f0100f69:	89 d6                	mov    %edx,%esi
f0100f6b:	03 b3 2c 1a 00 00    	add    0x1a2c(%ebx),%esi
		for(i=1; i < npages_basemem ; i++)
f0100f71:	83 c0 01             	add    $0x1,%eax
f0100f74:	ba 01 00 00 00       	mov    $0x1,%edx
f0100f79:	39 c7                	cmp    %eax,%edi
f0100f7b:	77 d5                	ja     f0100f52 <page_init+0x56>
f0100f7d:	84 d2                	test   %dl,%dl
f0100f7f:	74 06                	je     f0100f87 <page_init+0x8b>
f0100f81:	89 b3 40 1a 00 00    	mov    %esi,0x1a40(%ebx)
			pages[i].pp_ref = 1;
f0100f87:	8b 8b 2c 1a 00 00    	mov    0x1a2c(%ebx),%ecx
		for(i = npages_basemem ;  i < (EXTPHYSMEM-IOPHYSMEM)/PGSIZE + nextfree + npages_basemem ; i++)
f0100f8d:	89 f8                	mov    %edi,%eax
f0100f8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f92:	8d 54 3a 60          	lea    0x60(%edx,%edi,1),%edx
f0100f96:	eb 0a                	jmp    f0100fa2 <page_init+0xa6>
			pages[i].pp_ref = 1;
f0100f98:	66 c7 44 c1 04 01 00 	movw   $0x1,0x4(%ecx,%eax,8)
		for(i = npages_basemem ;  i < (EXTPHYSMEM-IOPHYSMEM)/PGSIZE + nextfree + npages_basemem ; i++)
f0100f9f:	83 c0 01             	add    $0x1,%eax
f0100fa2:	39 c2                	cmp    %eax,%edx
f0100fa4:	77 f2                	ja     f0100f98 <page_init+0x9c>
f0100fa6:	8b b3 40 1a 00 00    	mov    0x1a40(%ebx),%esi
f0100fac:	ba 00 00 00 00       	mov    $0x0,%edx
		for(; i < npages ; i++)	 
f0100fb1:	bf 01 00 00 00       	mov    $0x1,%edi
f0100fb6:	eb 24                	jmp    f0100fdc <page_init+0xe0>
f0100fb8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100fbf:	89 d1                	mov    %edx,%ecx
f0100fc1:	03 8b 2c 1a 00 00    	add    0x1a2c(%ebx),%ecx
f0100fc7:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list; // next page free on page free list
f0100fcd:	89 31                	mov    %esi,(%ecx)
	 		page_free_list = &pages[i];	        //set free list on i-th page
f0100fcf:	89 d6                	mov    %edx,%esi
f0100fd1:	03 b3 2c 1a 00 00    	add    0x1a2c(%ebx),%esi
		for(; i < npages ; i++)	 
f0100fd7:	83 c0 01             	add    $0x1,%eax
f0100fda:	89 fa                	mov    %edi,%edx
f0100fdc:	39 83 34 1a 00 00    	cmp    %eax,0x1a34(%ebx)
f0100fe2:	77 d4                	ja     f0100fb8 <page_init+0xbc>
f0100fe4:	84 d2                	test   %dl,%dl
f0100fe6:	74 06                	je     f0100fee <page_init+0xf2>
f0100fe8:	89 b3 40 1a 00 00    	mov    %esi,0x1a40(%ebx)
}
f0100fee:	83 c4 1c             	add    $0x1c,%esp
f0100ff1:	5b                   	pop    %ebx
f0100ff2:	5e                   	pop    %esi
f0100ff3:	5f                   	pop    %edi
f0100ff4:	5d                   	pop    %ebp
f0100ff5:	c3                   	ret    

f0100ff6 <page_alloc>:
{
f0100ff6:	55                   	push   %ebp
f0100ff7:	89 e5                	mov    %esp,%ebp
f0100ff9:	56                   	push   %esi
f0100ffa:	53                   	push   %ebx
f0100ffb:	e8 75 f1 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0101000:	81 c3 2c e9 07 00    	add    $0x7e92c,%ebx
	if(page_free_list!=NULL)
f0101006:	8b b3 40 1a 00 00    	mov    0x1a40(%ebx),%esi
f010100c:	85 f6                	test   %esi,%esi
f010100e:	74 14                	je     f0101024 <page_alloc+0x2e>
	page_free_list=page_free_list->pp_link; // switch free page to next free page in memoroy 
f0101010:	8b 06                	mov    (%esi),%eax
f0101012:	89 83 40 1a 00 00    	mov    %eax,0x1a40(%ebx)
	new_page->pp_link=NULL;
f0101018:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(alloc_flags & ALLOC_ZERO)
f010101e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101022:	75 09                	jne    f010102d <page_alloc+0x37>
}
f0101024:	89 f0                	mov    %esi,%eax
f0101026:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101029:	5b                   	pop    %ebx
f010102a:	5e                   	pop    %esi
f010102b:	5d                   	pop    %ebp
f010102c:	c3                   	ret    
f010102d:	89 f0                	mov    %esi,%eax
f010102f:	2b 83 2c 1a 00 00    	sub    0x1a2c(%ebx),%eax
f0101035:	c1 f8 03             	sar    $0x3,%eax
f0101038:	89 c2                	mov    %eax,%edx
f010103a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010103d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101042:	3b 83 34 1a 00 00    	cmp    0x1a34(%ebx),%eax
f0101048:	73 1b                	jae    f0101065 <page_alloc+0x6f>
		memset(page2kva(new_page),0,PGSIZE);	// fill entire pyhsical page with zeros 
f010104a:	83 ec 04             	sub    $0x4,%esp
f010104d:	68 00 10 00 00       	push   $0x1000
f0101052:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101054:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010105a:	52                   	push   %edx
f010105b:	e8 6a 3f 00 00       	call   f0104fca <memset>
f0101060:	83 c4 10             	add    $0x10,%esp
return new_page;
f0101063:	eb bf                	jmp    f0101024 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101065:	52                   	push   %edx
f0101066:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f010106c:	50                   	push   %eax
f010106d:	6a 56                	push   $0x56
f010106f:	8d 83 14 68 f8 ff    	lea    -0x797ec(%ebx),%eax
f0101075:	50                   	push   %eax
f0101076:	e8 44 f0 ff ff       	call   f01000bf <_panic>

f010107b <page_free>:
{
f010107b:	55                   	push   %ebp
f010107c:	89 e5                	mov    %esp,%ebp
f010107e:	53                   	push   %ebx
f010107f:	83 ec 04             	sub    $0x4,%esp
f0101082:	e8 ee f0 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0101087:	81 c3 a5 e8 07 00    	add    $0x7e8a5,%ebx
f010108d:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp);
f0101090:	85 c0                	test   %eax,%eax
f0101092:	74 1f                	je     f01010b3 <page_free+0x38>
	assert(pp->pp_ref == 0);
f0101094:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101099:	75 37                	jne    f01010d2 <page_free+0x57>
	assert(pp->pp_link == NULL);
f010109b:	83 38 00             	cmpl   $0x0,(%eax)
f010109e:	75 51                	jne    f01010f1 <page_free+0x76>
	pp->pp_link = page_free_list;
f01010a0:	8b 8b 40 1a 00 00    	mov    0x1a40(%ebx),%ecx
f01010a6:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01010a8:	89 83 40 1a 00 00    	mov    %eax,0x1a40(%ebx)
}
f01010ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010b1:	c9                   	leave  
f01010b2:	c3                   	ret    
	assert(pp);
f01010b3:	8d 83 07 6a f8 ff    	lea    -0x795f9(%ebx),%eax
f01010b9:	50                   	push   %eax
f01010ba:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01010c0:	50                   	push   %eax
f01010c1:	68 83 01 00 00       	push   $0x183
f01010c6:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01010cc:	50                   	push   %eax
f01010cd:	e8 ed ef ff ff       	call   f01000bf <_panic>
	assert(pp->pp_ref == 0);
f01010d2:	8d 83 be 68 f8 ff    	lea    -0x79742(%ebx),%eax
f01010d8:	50                   	push   %eax
f01010d9:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01010df:	50                   	push   %eax
f01010e0:	68 84 01 00 00       	push   $0x184
f01010e5:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01010eb:	50                   	push   %eax
f01010ec:	e8 ce ef ff ff       	call   f01000bf <_panic>
	assert(pp->pp_link == NULL);
f01010f1:	8d 83 ce 68 f8 ff    	lea    -0x79732(%ebx),%eax
f01010f7:	50                   	push   %eax
f01010f8:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01010fe:	50                   	push   %eax
f01010ff:	68 85 01 00 00       	push   $0x185
f0101104:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010110a:	50                   	push   %eax
f010110b:	e8 af ef ff ff       	call   f01000bf <_panic>

f0101110 <page_decref>:
{
f0101110:	55                   	push   %ebp
f0101111:	89 e5                	mov    %esp,%ebp
f0101113:	83 ec 08             	sub    $0x8,%esp
f0101116:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101119:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010111d:	83 e8 01             	sub    $0x1,%eax
f0101120:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101124:	66 85 c0             	test   %ax,%ax
f0101127:	74 02                	je     f010112b <page_decref+0x1b>
}
f0101129:	c9                   	leave  
f010112a:	c3                   	ret    
		page_free(pp);
f010112b:	83 ec 0c             	sub    $0xc,%esp
f010112e:	52                   	push   %edx
f010112f:	e8 47 ff ff ff       	call   f010107b <page_free>
f0101134:	83 c4 10             	add    $0x10,%esp
}
f0101137:	eb f0                	jmp    f0101129 <page_decref+0x19>

f0101139 <pgdir_walk>:
{
f0101139:	55                   	push   %ebp
f010113a:	89 e5                	mov    %esp,%ebp
f010113c:	57                   	push   %edi
f010113d:	56                   	push   %esi
f010113e:	53                   	push   %ebx
f010113f:	83 ec 0c             	sub    $0xc,%esp
f0101142:	e8 cf 21 00 00       	call   f0103316 <__x86.get_pc_thunk.di>
f0101147:	81 c7 e5 e7 07 00    	add    $0x7e7e5,%edi
f010114d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101150:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	assert(pgdir!=NULL); // panic if pgdir is NULL pointer
f0101153:	85 c0                	test   %eax,%eax
f0101155:	74 6b                	je     f01011c2 <pgdir_walk+0x89>
	pointer_table_page_index=&pgdir[PDX(va)]; // point at page directory index adress
f0101157:	89 da                	mov    %ebx,%edx
f0101159:	c1 ea 16             	shr    $0x16,%edx
f010115c:	8d 34 90             	lea    (%eax,%edx,4),%esi
	if(!(*pointer_table_page_index & PTE_P) )   // see if PTE_P (present ) and pte index exist
f010115f:	f6 06 01             	testb  $0x1,(%esi)
f0101162:	75 31                	jne    f0101195 <pgdir_walk+0x5c>
		if(!create)
f0101164:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101168:	0f 84 90 00 00 00    	je     f01011fe <pgdir_walk+0xc5>
	new_page=page_alloc(ALLOC_ZERO);    // return physical page adress
f010116e:	83 ec 0c             	sub    $0xc,%esp
f0101171:	6a 01                	push   $0x1
f0101173:	e8 7e fe ff ff       	call   f0100ff6 <page_alloc>
	if(new_page==NULL) // alloc not succesful 
f0101178:	83 c4 10             	add    $0x10,%esp
f010117b:	85 c0                	test   %eax,%eax
f010117d:	74 3b                	je     f01011ba <pgdir_walk+0x81>
	new_page->pp_ref++;  // add reference to new physicial page
f010117f:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101184:	2b 87 2c 1a 00 00    	sub    0x1a2c(%edi),%eax
f010118a:	c1 f8 03             	sar    $0x3,%eax
f010118d:	c1 e0 0c             	shl    $0xc,%eax
	*pointer_table_page_index=(page2pa(new_page) | PTE_P | PTE_U | PTE_W ); // page2pa returns va of page // prezent, read, user flags		
f0101190:	83 c8 07             	or     $0x7,%eax
f0101193:	89 06                	mov    %eax,(%esi)
	page_table=KADDR(PTE_ADDR(*pointer_table_page_index));  // virutal adress of adress in page directory entry
f0101195:	8b 06                	mov    (%esi),%eax
f0101197:	89 c2                	mov    %eax,%edx
f0101199:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010119f:	c1 e8 0c             	shr    $0xc,%eax
f01011a2:	3b 87 34 1a 00 00    	cmp    0x1a34(%edi),%eax
f01011a8:	73 39                	jae    f01011e3 <pgdir_walk+0xaa>
	return &page_table[PTX(va)] ; // return index of page table
f01011aa:	c1 eb 0a             	shr    $0xa,%ebx
f01011ad:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01011b3:	8d 84 1a 00 00 00 f0 	lea    -0x10000000(%edx,%ebx,1),%eax
}
f01011ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011bd:	5b                   	pop    %ebx
f01011be:	5e                   	pop    %esi
f01011bf:	5f                   	pop    %edi
f01011c0:	5d                   	pop    %ebp
f01011c1:	c3                   	ret    
	assert(pgdir!=NULL); // panic if pgdir is NULL pointer
f01011c2:	8d 87 e2 68 f8 ff    	lea    -0x7971e(%edi),%eax
f01011c8:	50                   	push   %eax
f01011c9:	8d 87 2e 68 f8 ff    	lea    -0x797d2(%edi),%eax
f01011cf:	50                   	push   %eax
f01011d0:	68 b4 01 00 00       	push   $0x1b4
f01011d5:	8d 87 ed 67 f8 ff    	lea    -0x79813(%edi),%eax
f01011db:	50                   	push   %eax
f01011dc:	89 fb                	mov    %edi,%ebx
f01011de:	e8 dc ee ff ff       	call   f01000bf <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011e3:	52                   	push   %edx
f01011e4:	8d 87 30 60 f8 ff    	lea    -0x79fd0(%edi),%eax
f01011ea:	50                   	push   %eax
f01011eb:	68 cc 01 00 00       	push   $0x1cc
f01011f0:	8d 87 ed 67 f8 ff    	lea    -0x79813(%edi),%eax
f01011f6:	50                   	push   %eax
f01011f7:	89 fb                	mov    %edi,%ebx
f01011f9:	e8 c1 ee ff ff       	call   f01000bf <_panic>
		return NULL;
f01011fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0101203:	eb b5                	jmp    f01011ba <pgdir_walk+0x81>

f0101205 <boot_map_region>:
{
f0101205:	55                   	push   %ebp
f0101206:	89 e5                	mov    %esp,%ebp
f0101208:	57                   	push   %edi
f0101209:	56                   	push   %esi
f010120a:	53                   	push   %ebx
f010120b:	83 ec 1c             	sub    $0x1c,%esp
f010120e:	e8 03 21 00 00       	call   f0103316 <__x86.get_pc_thunk.di>
f0101213:	81 c7 19 e7 07 00    	add    $0x7e719,%edi
f0101219:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010121c:	89 c7                	mov    %eax,%edi
f010121e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101221:	89 ce                	mov    %ecx,%esi
	for(i=0; i< size ; i+=PGSIZE)
f0101223:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101228:	39 f3                	cmp    %esi,%ebx
f010122a:	73 51                	jae    f010127d <boot_map_region+0x78>
		page_table_entry = pgdir_walk(pgdir, (void*)(va+i), 1); // return me virtual adress of new page_table entry for page
f010122c:	83 ec 04             	sub    $0x4,%esp
f010122f:	6a 01                	push   $0x1
f0101231:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101234:	01 d8                	add    %ebx,%eax
f0101236:	50                   	push   %eax
f0101237:	57                   	push   %edi
f0101238:	e8 fc fe ff ff       	call   f0101139 <pgdir_walk>
f010123d:	89 c2                	mov    %eax,%edx
		assert(page_table_entry != NULL);     // panic if zero
f010123f:	83 c4 10             	add    $0x10,%esp
f0101242:	85 c0                	test   %eax,%eax
f0101244:	74 15                	je     f010125b <boot_map_region+0x56>
		*page_table_entry=((pa+i)|PTE_P|perm);
f0101246:	89 d8                	mov    %ebx,%eax
f0101248:	03 45 08             	add    0x8(%ebp),%eax
f010124b:	0b 45 0c             	or     0xc(%ebp),%eax
f010124e:	83 c8 01             	or     $0x1,%eax
f0101251:	89 02                	mov    %eax,(%edx)
	for(i=0; i< size ; i+=PGSIZE)
f0101253:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101259:	eb cd                	jmp    f0101228 <boot_map_region+0x23>
		assert(page_table_entry != NULL);     // panic if zero
f010125b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010125e:	8d 83 ee 68 f8 ff    	lea    -0x79712(%ebx),%eax
f0101264:	50                   	push   %eax
f0101265:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010126b:	50                   	push   %eax
f010126c:	68 eb 01 00 00       	push   $0x1eb
f0101271:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101277:	50                   	push   %eax
f0101278:	e8 42 ee ff ff       	call   f01000bf <_panic>
}
f010127d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101280:	5b                   	pop    %ebx
f0101281:	5e                   	pop    %esi
f0101282:	5f                   	pop    %edi
f0101283:	5d                   	pop    %ebp
f0101284:	c3                   	ret    

f0101285 <page_lookup>:
{
f0101285:	55                   	push   %ebp
f0101286:	89 e5                	mov    %esp,%ebp
f0101288:	56                   	push   %esi
f0101289:	53                   	push   %ebx
f010128a:	e8 7c f4 ff ff       	call   f010070b <__x86.get_pc_thunk.si>
f010128f:	81 c6 9d e6 07 00    	add    $0x7e69d,%esi
f0101295:	8b 5d 10             	mov    0x10(%ebp),%ebx
	entry_of_page_table=pgdir_walk(pgdir,va,0);
f0101298:	83 ec 04             	sub    $0x4,%esp
f010129b:	6a 00                	push   $0x0
f010129d:	ff 75 0c             	push   0xc(%ebp)
f01012a0:	ff 75 08             	push   0x8(%ebp)
f01012a3:	e8 91 fe ff ff       	call   f0101139 <pgdir_walk>
	if(pte_store)
f01012a8:	83 c4 10             	add    $0x10,%esp
f01012ab:	85 db                	test   %ebx,%ebx
f01012ad:	74 02                	je     f01012b1 <page_lookup+0x2c>
		*pte_store=entry_of_page_table;
f01012af:	89 03                	mov    %eax,(%ebx)
	if(entry_of_page_table && (*entry_of_page_table & PTE_P))
f01012b1:	85 c0                	test   %eax,%eax
f01012b3:	74 0c                	je     f01012c1 <page_lookup+0x3c>
f01012b5:	8b 10                	mov    (%eax),%edx
	return NULL;
f01012b7:	b8 00 00 00 00       	mov    $0x0,%eax
	if(entry_of_page_table && (*entry_of_page_table & PTE_P))
f01012bc:	f6 c2 01             	test   $0x1,%dl
f01012bf:	75 07                	jne    f01012c8 <page_lookup+0x43>
}
f01012c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012c4:	5b                   	pop    %ebx
f01012c5:	5e                   	pop    %esi
f01012c6:	5d                   	pop    %ebp
f01012c7:	c3                   	ret    
f01012c8:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012cb:	39 96 34 1a 00 00    	cmp    %edx,0x1a34(%esi)
f01012d1:	76 0b                	jbe    f01012de <page_lookup+0x59>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012d3:	8b 86 2c 1a 00 00    	mov    0x1a2c(%esi),%eax
f01012d9:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return pa2page( PTE_ADDR(*entry_of_page_table) ); // zero last 12 f MSB t LSB & retrun pg number of VA
f01012dc:	eb e3                	jmp    f01012c1 <page_lookup+0x3c>
		panic("pa2page called with invalid pa");
f01012de:	83 ec 04             	sub    $0x4,%esp
f01012e1:	8d 86 3c 61 f8 ff    	lea    -0x79ec4(%esi),%eax
f01012e7:	50                   	push   %eax
f01012e8:	6a 4f                	push   $0x4f
f01012ea:	8d 86 14 68 f8 ff    	lea    -0x797ec(%esi),%eax
f01012f0:	50                   	push   %eax
f01012f1:	89 f3                	mov    %esi,%ebx
f01012f3:	e8 c7 ed ff ff       	call   f01000bf <_panic>

f01012f8 <page_remove>:
{
f01012f8:	55                   	push   %ebp
f01012f9:	89 e5                	mov    %esp,%ebp
f01012fb:	53                   	push   %ebx
f01012fc:	83 ec 18             	sub    $0x18,%esp
f01012ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	page = page_lookup(pgdir, va, &entry_of_page_table);
f0101302:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101305:	50                   	push   %eax
f0101306:	53                   	push   %ebx
f0101307:	ff 75 08             	push   0x8(%ebp)
f010130a:	e8 76 ff ff ff       	call   f0101285 <page_lookup>
	if (page == NULL)
f010130f:	83 c4 10             	add    $0x10,%esp
f0101312:	85 c0                	test   %eax,%eax
f0101314:	74 18                	je     f010132e <page_remove+0x36>
	*entry_of_page_table = 0;
f0101316:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101319:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(page);
f010131f:	83 ec 0c             	sub    $0xc,%esp
f0101322:	50                   	push   %eax
f0101323:	e8 e8 fd ff ff       	call   f0101110 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101328:	0f 01 3b             	invlpg (%ebx)
f010132b:	83 c4 10             	add    $0x10,%esp
}
f010132e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101331:	c9                   	leave  
f0101332:	c3                   	ret    

f0101333 <page_insert>:
{
f0101333:	55                   	push   %ebp
f0101334:	89 e5                	mov    %esp,%ebp
f0101336:	57                   	push   %edi
f0101337:	56                   	push   %esi
f0101338:	53                   	push   %ebx
f0101339:	83 ec 10             	sub    $0x10,%esp
f010133c:	e8 d5 1f 00 00       	call   f0103316 <__x86.get_pc_thunk.di>
f0101341:	81 c7 eb e5 07 00    	add    $0x7e5eb,%edi
f0101347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pyhsical_page_entry = pgdir_walk(pgdir,va,1); // return me adress of page entry of new page, create page
f010134a:	6a 01                	push   $0x1
f010134c:	ff 75 10             	push   0x10(%ebp)
f010134f:	ff 75 08             	push   0x8(%ebp)
f0101352:	e8 e2 fd ff ff       	call   f0101139 <pgdir_walk>
	if(pyhsical_page_entry==NULL)
f0101357:	83 c4 10             	add    $0x10,%esp
f010135a:	85 c0                	test   %eax,%eax
f010135c:	74 40                	je     f010139e <page_insert+0x6b>
f010135e:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101360:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if(PTE_P & *pyhsical_page_entry) // remove if exists
f0101365:	f6 00 01             	testb  $0x1,(%eax)
f0101368:	75 21                	jne    f010138b <page_insert+0x58>
	return (pp - pages) << PGSHIFT;
f010136a:	2b 9f 2c 1a 00 00    	sub    0x1a2c(%edi),%ebx
f0101370:	c1 fb 03             	sar    $0x3,%ebx
f0101373:	c1 e3 0c             	shl    $0xc,%ebx
	*pyhsical_page_entry=(page2pa(pp) | perm | PTE_P); // set permissions of page table entry
f0101376:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101379:	83 cb 01             	or     $0x1,%ebx
f010137c:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010137e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101383:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101386:	5b                   	pop    %ebx
f0101387:	5e                   	pop    %esi
f0101388:	5f                   	pop    %edi
f0101389:	5d                   	pop    %ebp
f010138a:	c3                   	ret    
		page_remove(pgdir,va);	
f010138b:	83 ec 08             	sub    $0x8,%esp
f010138e:	ff 75 10             	push   0x10(%ebp)
f0101391:	ff 75 08             	push   0x8(%ebp)
f0101394:	e8 5f ff ff ff       	call   f01012f8 <page_remove>
f0101399:	83 c4 10             	add    $0x10,%esp
f010139c:	eb cc                	jmp    f010136a <page_insert+0x37>
		return -E_NO_MEM;
f010139e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01013a3:	eb de                	jmp    f0101383 <page_insert+0x50>

f01013a5 <mem_init>:
{
f01013a5:	55                   	push   %ebp
f01013a6:	89 e5                	mov    %esp,%ebp
f01013a8:	57                   	push   %edi
f01013a9:	56                   	push   %esi
f01013aa:	53                   	push   %ebx
f01013ab:	83 ec 3c             	sub    $0x3c,%esp
f01013ae:	e8 54 f3 ff ff       	call   f0100707 <__x86.get_pc_thunk.ax>
f01013b3:	05 79 e5 07 00       	add    $0x7e579,%eax
f01013b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f01013bb:	b8 15 00 00 00       	mov    $0x15,%eax
f01013c0:	e8 7a f6 ff ff       	call   f0100a3f <nvram_read>
f01013c5:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01013c7:	b8 17 00 00 00       	mov    $0x17,%eax
f01013cc:	e8 6e f6 ff ff       	call   f0100a3f <nvram_read>
f01013d1:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013d3:	b8 34 00 00 00       	mov    $0x34,%eax
f01013d8:	e8 62 f6 ff ff       	call   f0100a3f <nvram_read>
	if (ext16mem)
f01013dd:	c1 e0 06             	shl    $0x6,%eax
f01013e0:	0f 84 e3 00 00 00    	je     f01014c9 <mem_init+0x124>
		totalmem = 16 * 1024 + ext16mem;
f01013e6:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013eb:	89 c2                	mov    %eax,%edx
f01013ed:	c1 ea 02             	shr    $0x2,%edx
f01013f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01013f3:	89 91 34 1a 00 00    	mov    %edx,0x1a34(%ecx)
	npages_basemem = basemem / (PGSIZE / 1024);
f01013f9:	89 da                	mov    %ebx,%edx
f01013fb:	c1 ea 02             	shr    $0x2,%edx
f01013fe:	89 91 44 1a 00 00    	mov    %edx,0x1a44(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101404:	89 c2                	mov    %eax,%edx
f0101406:	29 da                	sub    %ebx,%edx
f0101408:	52                   	push   %edx
f0101409:	53                   	push   %ebx
f010140a:	50                   	push   %eax
f010140b:	8d 81 5c 61 f8 ff    	lea    -0x79ea4(%ecx),%eax
f0101411:	50                   	push   %eax
f0101412:	89 cb                	mov    %ecx,%ebx
f0101414:	e8 08 27 00 00       	call   f0103b21 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101419:	b8 00 10 00 00       	mov    $0x1000,%eax
f010141e:	e8 52 f6 ff ff       	call   f0100a75 <boot_alloc>
f0101423:	89 83 30 1a 00 00    	mov    %eax,0x1a30(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f0101429:	83 c4 0c             	add    $0xc,%esp
f010142c:	68 00 10 00 00       	push   $0x1000
f0101431:	6a 00                	push   $0x0
f0101433:	50                   	push   %eax
f0101434:	e8 91 3b 00 00       	call   f0104fca <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P ;
f0101439:	8b 83 30 1a 00 00    	mov    0x1a30(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010143f:	83 c4 10             	add    $0x10,%esp
f0101442:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101447:	0f 86 8c 00 00 00    	jbe    f01014d9 <mem_init+0x134>
	return (physaddr_t)kva - KERNBASE;
f010144d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101453:	83 ca 05             	or     $0x5,%edx
f0101456:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010145c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010145f:	8b 87 34 1a 00 00    	mov    0x1a34(%edi),%eax
f0101465:	c1 e0 03             	shl    $0x3,%eax
f0101468:	e8 08 f6 ff ff       	call   f0100a75 <boot_alloc>
f010146d:	89 87 2c 1a 00 00    	mov    %eax,0x1a2c(%edi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101473:	83 ec 04             	sub    $0x4,%esp
f0101476:	8b 97 34 1a 00 00    	mov    0x1a34(%edi),%edx
f010147c:	c1 e2 03             	shl    $0x3,%edx
f010147f:	52                   	push   %edx
f0101480:	6a 00                	push   $0x0
f0101482:	50                   	push   %eax
f0101483:	89 fb                	mov    %edi,%ebx
f0101485:	e8 40 3b 00 00       	call   f0104fca <memset>
	envs=(struct Env *)boot_alloc(NENV*sizeof(struct Env));
f010148a:	b8 00 80 01 00       	mov    $0x18000,%eax
f010148f:	e8 e1 f5 ff ff       	call   f0100a75 <boot_alloc>
f0101494:	89 c2                	mov    %eax,%edx
f0101496:	c7 c0 78 13 18 f0    	mov    $0xf0181378,%eax
f010149c:	89 10                	mov    %edx,(%eax)
	page_init();
f010149e:	e8 59 fa ff ff       	call   f0100efc <page_init>
	check_page_free_list(1);
f01014a3:	b8 01 00 00 00       	mov    $0x1,%eax
f01014a8:	e8 e3 f6 ff ff       	call   f0100b90 <check_page_free_list>
	if (!pages)
f01014ad:	83 c4 10             	add    $0x10,%esp
f01014b0:	83 bf 2c 1a 00 00 00 	cmpl   $0x0,0x1a2c(%edi)
f01014b7:	74 3c                	je     f01014f5 <mem_init+0x150>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014bc:	8b 80 40 1a 00 00    	mov    0x1a40(%eax),%eax
f01014c2:	be 00 00 00 00       	mov    $0x0,%esi
f01014c7:	eb 4f                	jmp    f0101518 <mem_init+0x173>
		totalmem = 1 * 1024 + extmem;
f01014c9:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014cf:	85 f6                	test   %esi,%esi
f01014d1:	0f 44 c3             	cmove  %ebx,%eax
f01014d4:	e9 12 ff ff ff       	jmp    f01013eb <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014d9:	50                   	push   %eax
f01014da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01014dd:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f01014e3:	50                   	push   %eax
f01014e4:	68 95 00 00 00       	push   $0x95
f01014e9:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01014ef:	50                   	push   %eax
f01014f0:	e8 ca eb ff ff       	call   f01000bf <_panic>
		panic("'pages' is a null pointer!");
f01014f5:	83 ec 04             	sub    $0x4,%esp
f01014f8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01014fb:	8d 83 07 69 f8 ff    	lea    -0x796f9(%ebx),%eax
f0101501:	50                   	push   %eax
f0101502:	68 06 03 00 00       	push   $0x306
f0101507:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010150d:	50                   	push   %eax
f010150e:	e8 ac eb ff ff       	call   f01000bf <_panic>
		++nfree;
f0101513:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101516:	8b 00                	mov    (%eax),%eax
f0101518:	85 c0                	test   %eax,%eax
f010151a:	75 f7                	jne    f0101513 <mem_init+0x16e>
	assert((pp0 = page_alloc(0)));
f010151c:	83 ec 0c             	sub    $0xc,%esp
f010151f:	6a 00                	push   $0x0
f0101521:	e8 d0 fa ff ff       	call   f0100ff6 <page_alloc>
f0101526:	89 c3                	mov    %eax,%ebx
f0101528:	83 c4 10             	add    $0x10,%esp
f010152b:	85 c0                	test   %eax,%eax
f010152d:	0f 84 3a 02 00 00    	je     f010176d <mem_init+0x3c8>
	assert((pp1 = page_alloc(0)));
f0101533:	83 ec 0c             	sub    $0xc,%esp
f0101536:	6a 00                	push   $0x0
f0101538:	e8 b9 fa ff ff       	call   f0100ff6 <page_alloc>
f010153d:	89 c7                	mov    %eax,%edi
f010153f:	83 c4 10             	add    $0x10,%esp
f0101542:	85 c0                	test   %eax,%eax
f0101544:	0f 84 45 02 00 00    	je     f010178f <mem_init+0x3ea>
	assert((pp2 = page_alloc(0)));
f010154a:	83 ec 0c             	sub    $0xc,%esp
f010154d:	6a 00                	push   $0x0
f010154f:	e8 a2 fa ff ff       	call   f0100ff6 <page_alloc>
f0101554:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101557:	83 c4 10             	add    $0x10,%esp
f010155a:	85 c0                	test   %eax,%eax
f010155c:	0f 84 4f 02 00 00    	je     f01017b1 <mem_init+0x40c>
	assert(pp1 && pp1 != pp0);
f0101562:	39 fb                	cmp    %edi,%ebx
f0101564:	0f 84 69 02 00 00    	je     f01017d3 <mem_init+0x42e>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010156a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010156d:	39 c7                	cmp    %eax,%edi
f010156f:	0f 84 80 02 00 00    	je     f01017f5 <mem_init+0x450>
f0101575:	39 c3                	cmp    %eax,%ebx
f0101577:	0f 84 78 02 00 00    	je     f01017f5 <mem_init+0x450>
	return (pp - pages) << PGSHIFT;
f010157d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101580:	8b 88 2c 1a 00 00    	mov    0x1a2c(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101586:	8b 90 34 1a 00 00    	mov    0x1a34(%eax),%edx
f010158c:	c1 e2 0c             	shl    $0xc,%edx
f010158f:	89 d8                	mov    %ebx,%eax
f0101591:	29 c8                	sub    %ecx,%eax
f0101593:	c1 f8 03             	sar    $0x3,%eax
f0101596:	c1 e0 0c             	shl    $0xc,%eax
f0101599:	39 d0                	cmp    %edx,%eax
f010159b:	0f 83 76 02 00 00    	jae    f0101817 <mem_init+0x472>
f01015a1:	89 f8                	mov    %edi,%eax
f01015a3:	29 c8                	sub    %ecx,%eax
f01015a5:	c1 f8 03             	sar    $0x3,%eax
f01015a8:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01015ab:	39 c2                	cmp    %eax,%edx
f01015ad:	0f 86 86 02 00 00    	jbe    f0101839 <mem_init+0x494>
f01015b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015b6:	29 c8                	sub    %ecx,%eax
f01015b8:	c1 f8 03             	sar    $0x3,%eax
f01015bb:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01015be:	39 c2                	cmp    %eax,%edx
f01015c0:	0f 86 95 02 00 00    	jbe    f010185b <mem_init+0x4b6>
	fl = page_free_list;
f01015c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015c9:	8b 88 40 1a 00 00    	mov    0x1a40(%eax),%ecx
f01015cf:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01015d2:	c7 80 40 1a 00 00 00 	movl   $0x0,0x1a40(%eax)
f01015d9:	00 00 00 
	assert(!page_alloc(0));
f01015dc:	83 ec 0c             	sub    $0xc,%esp
f01015df:	6a 00                	push   $0x0
f01015e1:	e8 10 fa ff ff       	call   f0100ff6 <page_alloc>
f01015e6:	83 c4 10             	add    $0x10,%esp
f01015e9:	85 c0                	test   %eax,%eax
f01015eb:	0f 85 8c 02 00 00    	jne    f010187d <mem_init+0x4d8>
	page_free(pp0);
f01015f1:	83 ec 0c             	sub    $0xc,%esp
f01015f4:	53                   	push   %ebx
f01015f5:	e8 81 fa ff ff       	call   f010107b <page_free>
	page_free(pp1);
f01015fa:	89 3c 24             	mov    %edi,(%esp)
f01015fd:	e8 79 fa ff ff       	call   f010107b <page_free>
	page_free(pp2);
f0101602:	83 c4 04             	add    $0x4,%esp
f0101605:	ff 75 d0             	push   -0x30(%ebp)
f0101608:	e8 6e fa ff ff       	call   f010107b <page_free>
	assert((pp0 = page_alloc(0)));
f010160d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101614:	e8 dd f9 ff ff       	call   f0100ff6 <page_alloc>
f0101619:	89 c7                	mov    %eax,%edi
f010161b:	83 c4 10             	add    $0x10,%esp
f010161e:	85 c0                	test   %eax,%eax
f0101620:	0f 84 79 02 00 00    	je     f010189f <mem_init+0x4fa>
	assert((pp1 = page_alloc(0)));
f0101626:	83 ec 0c             	sub    $0xc,%esp
f0101629:	6a 00                	push   $0x0
f010162b:	e8 c6 f9 ff ff       	call   f0100ff6 <page_alloc>
f0101630:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101633:	83 c4 10             	add    $0x10,%esp
f0101636:	85 c0                	test   %eax,%eax
f0101638:	0f 84 83 02 00 00    	je     f01018c1 <mem_init+0x51c>
	assert((pp2 = page_alloc(0)));
f010163e:	83 ec 0c             	sub    $0xc,%esp
f0101641:	6a 00                	push   $0x0
f0101643:	e8 ae f9 ff ff       	call   f0100ff6 <page_alloc>
f0101648:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010164b:	83 c4 10             	add    $0x10,%esp
f010164e:	85 c0                	test   %eax,%eax
f0101650:	0f 84 8d 02 00 00    	je     f01018e3 <mem_init+0x53e>
	assert(pp1 && pp1 != pp0);
f0101656:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101659:	0f 84 a6 02 00 00    	je     f0101905 <mem_init+0x560>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010165f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101662:	39 c7                	cmp    %eax,%edi
f0101664:	0f 84 bd 02 00 00    	je     f0101927 <mem_init+0x582>
f010166a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010166d:	0f 84 b4 02 00 00    	je     f0101927 <mem_init+0x582>
	assert(!page_alloc(0));
f0101673:	83 ec 0c             	sub    $0xc,%esp
f0101676:	6a 00                	push   $0x0
f0101678:	e8 79 f9 ff ff       	call   f0100ff6 <page_alloc>
f010167d:	83 c4 10             	add    $0x10,%esp
f0101680:	85 c0                	test   %eax,%eax
f0101682:	0f 85 c1 02 00 00    	jne    f0101949 <mem_init+0x5a4>
f0101688:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010168b:	89 f8                	mov    %edi,%eax
f010168d:	2b 81 2c 1a 00 00    	sub    0x1a2c(%ecx),%eax
f0101693:	c1 f8 03             	sar    $0x3,%eax
f0101696:	89 c2                	mov    %eax,%edx
f0101698:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010169b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01016a0:	3b 81 34 1a 00 00    	cmp    0x1a34(%ecx),%eax
f01016a6:	0f 83 bf 02 00 00    	jae    f010196b <mem_init+0x5c6>
	memset(page2kva(pp0), 1, PGSIZE);
f01016ac:	83 ec 04             	sub    $0x4,%esp
f01016af:	68 00 10 00 00       	push   $0x1000
f01016b4:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01016b6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01016bc:	52                   	push   %edx
f01016bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016c0:	e8 05 39 00 00       	call   f0104fca <memset>
	page_free(pp0);
f01016c5:	89 3c 24             	mov    %edi,(%esp)
f01016c8:	e8 ae f9 ff ff       	call   f010107b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016d4:	e8 1d f9 ff ff       	call   f0100ff6 <page_alloc>
f01016d9:	83 c4 10             	add    $0x10,%esp
f01016dc:	85 c0                	test   %eax,%eax
f01016de:	0f 84 9f 02 00 00    	je     f0101983 <mem_init+0x5de>
	assert(pp && pp0 == pp);
f01016e4:	39 c7                	cmp    %eax,%edi
f01016e6:	0f 85 b9 02 00 00    	jne    f01019a5 <mem_init+0x600>
	return (pp - pages) << PGSHIFT;
f01016ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01016ef:	2b 81 2c 1a 00 00    	sub    0x1a2c(%ecx),%eax
f01016f5:	c1 f8 03             	sar    $0x3,%eax
f01016f8:	89 c2                	mov    %eax,%edx
f01016fa:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016fd:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101702:	3b 81 34 1a 00 00    	cmp    0x1a34(%ecx),%eax
f0101708:	0f 83 b9 02 00 00    	jae    f01019c7 <mem_init+0x622>
	return (void *)(pa + KERNBASE);
f010170e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101714:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010171a:	80 38 00             	cmpb   $0x0,(%eax)
f010171d:	0f 85 bc 02 00 00    	jne    f01019df <mem_init+0x63a>
	for (i = 0; i < PGSIZE; i++)
f0101723:	83 c0 01             	add    $0x1,%eax
f0101726:	39 d0                	cmp    %edx,%eax
f0101728:	75 f0                	jne    f010171a <mem_init+0x375>
	page_free_list = fl;
f010172a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010172d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101730:	89 8b 40 1a 00 00    	mov    %ecx,0x1a40(%ebx)
	page_free(pp0);
f0101736:	83 ec 0c             	sub    $0xc,%esp
f0101739:	57                   	push   %edi
f010173a:	e8 3c f9 ff ff       	call   f010107b <page_free>
	page_free(pp1);
f010173f:	83 c4 04             	add    $0x4,%esp
f0101742:	ff 75 d0             	push   -0x30(%ebp)
f0101745:	e8 31 f9 ff ff       	call   f010107b <page_free>
	page_free(pp2);
f010174a:	83 c4 04             	add    $0x4,%esp
f010174d:	ff 75 cc             	push   -0x34(%ebp)
f0101750:	e8 26 f9 ff ff       	call   f010107b <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101755:	8b 83 40 1a 00 00    	mov    0x1a40(%ebx),%eax
f010175b:	83 c4 10             	add    $0x10,%esp
f010175e:	85 c0                	test   %eax,%eax
f0101760:	0f 84 9b 02 00 00    	je     f0101a01 <mem_init+0x65c>
		--nfree;
f0101766:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101769:	8b 00                	mov    (%eax),%eax
f010176b:	eb f1                	jmp    f010175e <mem_init+0x3b9>
	assert((pp0 = page_alloc(0)));
f010176d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101770:	8d 83 22 69 f8 ff    	lea    -0x796de(%ebx),%eax
f0101776:	50                   	push   %eax
f0101777:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010177d:	50                   	push   %eax
f010177e:	68 0e 03 00 00       	push   $0x30e
f0101783:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101789:	50                   	push   %eax
f010178a:	e8 30 e9 ff ff       	call   f01000bf <_panic>
	assert((pp1 = page_alloc(0)));
f010178f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101792:	8d 83 38 69 f8 ff    	lea    -0x796c8(%ebx),%eax
f0101798:	50                   	push   %eax
f0101799:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010179f:	50                   	push   %eax
f01017a0:	68 0f 03 00 00       	push   $0x30f
f01017a5:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01017ab:	50                   	push   %eax
f01017ac:	e8 0e e9 ff ff       	call   f01000bf <_panic>
	assert((pp2 = page_alloc(0)));
f01017b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017b4:	8d 83 4e 69 f8 ff    	lea    -0x796b2(%ebx),%eax
f01017ba:	50                   	push   %eax
f01017bb:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01017c1:	50                   	push   %eax
f01017c2:	68 10 03 00 00       	push   $0x310
f01017c7:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01017cd:	50                   	push   %eax
f01017ce:	e8 ec e8 ff ff       	call   f01000bf <_panic>
	assert(pp1 && pp1 != pp0);
f01017d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017d6:	8d 83 64 69 f8 ff    	lea    -0x7969c(%ebx),%eax
f01017dc:	50                   	push   %eax
f01017dd:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01017e3:	50                   	push   %eax
f01017e4:	68 13 03 00 00       	push   $0x313
f01017e9:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01017ef:	50                   	push   %eax
f01017f0:	e8 ca e8 ff ff       	call   f01000bf <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017f8:	8d 83 98 61 f8 ff    	lea    -0x79e68(%ebx),%eax
f01017fe:	50                   	push   %eax
f01017ff:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0101805:	50                   	push   %eax
f0101806:	68 14 03 00 00       	push   $0x314
f010180b:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101811:	50                   	push   %eax
f0101812:	e8 a8 e8 ff ff       	call   f01000bf <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101817:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010181a:	8d 83 76 69 f8 ff    	lea    -0x7968a(%ebx),%eax
f0101820:	50                   	push   %eax
f0101821:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0101827:	50                   	push   %eax
f0101828:	68 15 03 00 00       	push   $0x315
f010182d:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101833:	50                   	push   %eax
f0101834:	e8 86 e8 ff ff       	call   f01000bf <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101839:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010183c:	8d 83 93 69 f8 ff    	lea    -0x7966d(%ebx),%eax
f0101842:	50                   	push   %eax
f0101843:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0101849:	50                   	push   %eax
f010184a:	68 16 03 00 00       	push   $0x316
f010184f:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101855:	50                   	push   %eax
f0101856:	e8 64 e8 ff ff       	call   f01000bf <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010185b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010185e:	8d 83 b0 69 f8 ff    	lea    -0x79650(%ebx),%eax
f0101864:	50                   	push   %eax
f0101865:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010186b:	50                   	push   %eax
f010186c:	68 17 03 00 00       	push   $0x317
f0101871:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101877:	50                   	push   %eax
f0101878:	e8 42 e8 ff ff       	call   f01000bf <_panic>
	assert(!page_alloc(0));
f010187d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101880:	8d 83 cd 69 f8 ff    	lea    -0x79633(%ebx),%eax
f0101886:	50                   	push   %eax
f0101887:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010188d:	50                   	push   %eax
f010188e:	68 1e 03 00 00       	push   $0x31e
f0101893:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101899:	50                   	push   %eax
f010189a:	e8 20 e8 ff ff       	call   f01000bf <_panic>
	assert((pp0 = page_alloc(0)));
f010189f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018a2:	8d 83 22 69 f8 ff    	lea    -0x796de(%ebx),%eax
f01018a8:	50                   	push   %eax
f01018a9:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01018af:	50                   	push   %eax
f01018b0:	68 25 03 00 00       	push   $0x325
f01018b5:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01018bb:	50                   	push   %eax
f01018bc:	e8 fe e7 ff ff       	call   f01000bf <_panic>
	assert((pp1 = page_alloc(0)));
f01018c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018c4:	8d 83 38 69 f8 ff    	lea    -0x796c8(%ebx),%eax
f01018ca:	50                   	push   %eax
f01018cb:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01018d1:	50                   	push   %eax
f01018d2:	68 26 03 00 00       	push   $0x326
f01018d7:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01018dd:	50                   	push   %eax
f01018de:	e8 dc e7 ff ff       	call   f01000bf <_panic>
	assert((pp2 = page_alloc(0)));
f01018e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018e6:	8d 83 4e 69 f8 ff    	lea    -0x796b2(%ebx),%eax
f01018ec:	50                   	push   %eax
f01018ed:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01018f3:	50                   	push   %eax
f01018f4:	68 27 03 00 00       	push   $0x327
f01018f9:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01018ff:	50                   	push   %eax
f0101900:	e8 ba e7 ff ff       	call   f01000bf <_panic>
	assert(pp1 && pp1 != pp0);
f0101905:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101908:	8d 83 64 69 f8 ff    	lea    -0x7969c(%ebx),%eax
f010190e:	50                   	push   %eax
f010190f:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0101915:	50                   	push   %eax
f0101916:	68 29 03 00 00       	push   $0x329
f010191b:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101921:	50                   	push   %eax
f0101922:	e8 98 e7 ff ff       	call   f01000bf <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101927:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010192a:	8d 83 98 61 f8 ff    	lea    -0x79e68(%ebx),%eax
f0101930:	50                   	push   %eax
f0101931:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0101937:	50                   	push   %eax
f0101938:	68 2a 03 00 00       	push   $0x32a
f010193d:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101943:	50                   	push   %eax
f0101944:	e8 76 e7 ff ff       	call   f01000bf <_panic>
	assert(!page_alloc(0));
f0101949:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010194c:	8d 83 cd 69 f8 ff    	lea    -0x79633(%ebx),%eax
f0101952:	50                   	push   %eax
f0101953:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0101959:	50                   	push   %eax
f010195a:	68 2b 03 00 00       	push   $0x32b
f010195f:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0101965:	50                   	push   %eax
f0101966:	e8 54 e7 ff ff       	call   f01000bf <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010196b:	52                   	push   %edx
f010196c:	89 cb                	mov    %ecx,%ebx
f010196e:	8d 81 30 60 f8 ff    	lea    -0x79fd0(%ecx),%eax
f0101974:	50                   	push   %eax
f0101975:	6a 56                	push   $0x56
f0101977:	8d 81 14 68 f8 ff    	lea    -0x797ec(%ecx),%eax
f010197d:	50                   	push   %eax
f010197e:	e8 3c e7 ff ff       	call   f01000bf <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101983:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101986:	8d 83 dc 69 f8 ff    	lea    -0x79624(%ebx),%eax
f010198c:	50                   	push   %eax
f010198d:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0101993:	50                   	push   %eax
f0101994:	68 30 03 00 00       	push   $0x330
f0101999:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010199f:	50                   	push   %eax
f01019a0:	e8 1a e7 ff ff       	call   f01000bf <_panic>
	assert(pp && pp0 == pp);
f01019a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019a8:	8d 83 fa 69 f8 ff    	lea    -0x79606(%ebx),%eax
f01019ae:	50                   	push   %eax
f01019af:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01019b5:	50                   	push   %eax
f01019b6:	68 31 03 00 00       	push   $0x331
f01019bb:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01019c1:	50                   	push   %eax
f01019c2:	e8 f8 e6 ff ff       	call   f01000bf <_panic>
f01019c7:	52                   	push   %edx
f01019c8:	89 cb                	mov    %ecx,%ebx
f01019ca:	8d 81 30 60 f8 ff    	lea    -0x79fd0(%ecx),%eax
f01019d0:	50                   	push   %eax
f01019d1:	6a 56                	push   $0x56
f01019d3:	8d 81 14 68 f8 ff    	lea    -0x797ec(%ecx),%eax
f01019d9:	50                   	push   %eax
f01019da:	e8 e0 e6 ff ff       	call   f01000bf <_panic>
		assert(c[i] == 0);
f01019df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019e2:	8d 83 0a 6a f8 ff    	lea    -0x795f6(%ebx),%eax
f01019e8:	50                   	push   %eax
f01019e9:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01019ef:	50                   	push   %eax
f01019f0:	68 34 03 00 00       	push   $0x334
f01019f5:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01019fb:	50                   	push   %eax
f01019fc:	e8 be e6 ff ff       	call   f01000bf <_panic>
	assert(nfree == 0);
f0101a01:	85 f6                	test   %esi,%esi
f0101a03:	0f 85 d1 08 00 00    	jne    f01022da <mem_init+0xf35>
	cprintf("check_page_alloc() succeeded!\n");
f0101a09:	83 ec 0c             	sub    $0xc,%esp
f0101a0c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a0f:	8d 83 b8 61 f8 ff    	lea    -0x79e48(%ebx),%eax
f0101a15:	50                   	push   %eax
f0101a16:	e8 06 21 00 00       	call   f0103b21 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a22:	e8 cf f5 ff ff       	call   f0100ff6 <page_alloc>
f0101a27:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a2a:	83 c4 10             	add    $0x10,%esp
f0101a2d:	85 c0                	test   %eax,%eax
f0101a2f:	0f 84 c7 08 00 00    	je     f01022fc <mem_init+0xf57>
	assert((pp1 = page_alloc(0)));
f0101a35:	83 ec 0c             	sub    $0xc,%esp
f0101a38:	6a 00                	push   $0x0
f0101a3a:	e8 b7 f5 ff ff       	call   f0100ff6 <page_alloc>
f0101a3f:	89 c7                	mov    %eax,%edi
f0101a41:	83 c4 10             	add    $0x10,%esp
f0101a44:	85 c0                	test   %eax,%eax
f0101a46:	0f 84 d2 08 00 00    	je     f010231e <mem_init+0xf79>
	assert((pp2 = page_alloc(0)));
f0101a4c:	83 ec 0c             	sub    $0xc,%esp
f0101a4f:	6a 00                	push   $0x0
f0101a51:	e8 a0 f5 ff ff       	call   f0100ff6 <page_alloc>
f0101a56:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a59:	83 c4 10             	add    $0x10,%esp
f0101a5c:	85 c0                	test   %eax,%eax
f0101a5e:	0f 84 dc 08 00 00    	je     f0102340 <mem_init+0xf9b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a64:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101a67:	0f 84 f5 08 00 00    	je     f0102362 <mem_init+0xfbd>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a6d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a70:	39 c7                	cmp    %eax,%edi
f0101a72:	0f 84 0c 09 00 00    	je     f0102384 <mem_init+0xfdf>
f0101a78:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101a7b:	0f 84 03 09 00 00    	je     f0102384 <mem_init+0xfdf>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a84:	8b 88 40 1a 00 00    	mov    0x1a40(%eax),%ecx
f0101a8a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101a8d:	c7 80 40 1a 00 00 00 	movl   $0x0,0x1a40(%eax)
f0101a94:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a97:	83 ec 0c             	sub    $0xc,%esp
f0101a9a:	6a 00                	push   $0x0
f0101a9c:	e8 55 f5 ff ff       	call   f0100ff6 <page_alloc>
f0101aa1:	83 c4 10             	add    $0x10,%esp
f0101aa4:	85 c0                	test   %eax,%eax
f0101aa6:	0f 85 fa 08 00 00    	jne    f01023a6 <mem_init+0x1001>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101aac:	83 ec 04             	sub    $0x4,%esp
f0101aaf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ab2:	50                   	push   %eax
f0101ab3:	6a 00                	push   $0x0
f0101ab5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ab8:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101abe:	e8 c2 f7 ff ff       	call   f0101285 <page_lookup>
f0101ac3:	83 c4 10             	add    $0x10,%esp
f0101ac6:	85 c0                	test   %eax,%eax
f0101ac8:	0f 85 fa 08 00 00    	jne    f01023c8 <mem_init+0x1023>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ace:	6a 02                	push   $0x2
f0101ad0:	6a 00                	push   $0x0
f0101ad2:	57                   	push   %edi
f0101ad3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ad6:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101adc:	e8 52 f8 ff ff       	call   f0101333 <page_insert>
f0101ae1:	83 c4 10             	add    $0x10,%esp
f0101ae4:	85 c0                	test   %eax,%eax
f0101ae6:	0f 89 fe 08 00 00    	jns    f01023ea <mem_init+0x1045>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101aec:	83 ec 0c             	sub    $0xc,%esp
f0101aef:	ff 75 cc             	push   -0x34(%ebp)
f0101af2:	e8 84 f5 ff ff       	call   f010107b <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101af7:	6a 02                	push   $0x2
f0101af9:	6a 00                	push   $0x0
f0101afb:	57                   	push   %edi
f0101afc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aff:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101b05:	e8 29 f8 ff ff       	call   f0101333 <page_insert>
f0101b0a:	83 c4 20             	add    $0x20,%esp
f0101b0d:	85 c0                	test   %eax,%eax
f0101b0f:	0f 85 f7 08 00 00    	jne    f010240c <mem_init+0x1067>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b18:	8b 98 30 1a 00 00    	mov    0x1a30(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101b1e:	8b b0 2c 1a 00 00    	mov    0x1a2c(%eax),%esi
f0101b24:	8b 13                	mov    (%ebx),%edx
f0101b26:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b2c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101b2f:	29 f0                	sub    %esi,%eax
f0101b31:	c1 f8 03             	sar    $0x3,%eax
f0101b34:	c1 e0 0c             	shl    $0xc,%eax
f0101b37:	39 c2                	cmp    %eax,%edx
f0101b39:	0f 85 ef 08 00 00    	jne    f010242e <mem_init+0x1089>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b3f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b44:	89 d8                	mov    %ebx,%eax
f0101b46:	e8 c9 ef ff ff       	call   f0100b14 <check_va2pa>
f0101b4b:	89 c2                	mov    %eax,%edx
f0101b4d:	89 f8                	mov    %edi,%eax
f0101b4f:	29 f0                	sub    %esi,%eax
f0101b51:	c1 f8 03             	sar    $0x3,%eax
f0101b54:	c1 e0 0c             	shl    $0xc,%eax
f0101b57:	39 c2                	cmp    %eax,%edx
f0101b59:	0f 85 f1 08 00 00    	jne    f0102450 <mem_init+0x10ab>
	assert(pp1->pp_ref == 1);
f0101b5f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b64:	0f 85 08 09 00 00    	jne    f0102472 <mem_init+0x10cd>
	assert(pp0->pp_ref == 1);
f0101b6a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101b6d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b72:	0f 85 1c 09 00 00    	jne    f0102494 <mem_init+0x10ef>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b78:	6a 02                	push   $0x2
f0101b7a:	68 00 10 00 00       	push   $0x1000
f0101b7f:	ff 75 d0             	push   -0x30(%ebp)
f0101b82:	53                   	push   %ebx
f0101b83:	e8 ab f7 ff ff       	call   f0101333 <page_insert>
f0101b88:	83 c4 10             	add    $0x10,%esp
f0101b8b:	85 c0                	test   %eax,%eax
f0101b8d:	0f 85 23 09 00 00    	jne    f01024b6 <mem_init+0x1111>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b93:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b98:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b9b:	8b 83 30 1a 00 00    	mov    0x1a30(%ebx),%eax
f0101ba1:	e8 6e ef ff ff       	call   f0100b14 <check_va2pa>
f0101ba6:	89 c2                	mov    %eax,%edx
f0101ba8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bab:	2b 83 2c 1a 00 00    	sub    0x1a2c(%ebx),%eax
f0101bb1:	c1 f8 03             	sar    $0x3,%eax
f0101bb4:	c1 e0 0c             	shl    $0xc,%eax
f0101bb7:	39 c2                	cmp    %eax,%edx
f0101bb9:	0f 85 19 09 00 00    	jne    f01024d8 <mem_init+0x1133>
	assert(pp2->pp_ref == 1);
f0101bbf:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bc2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bc7:	0f 85 2d 09 00 00    	jne    f01024fa <mem_init+0x1155>

	// should be no free memory
	assert(!page_alloc(0));
f0101bcd:	83 ec 0c             	sub    $0xc,%esp
f0101bd0:	6a 00                	push   $0x0
f0101bd2:	e8 1f f4 ff ff       	call   f0100ff6 <page_alloc>
f0101bd7:	83 c4 10             	add    $0x10,%esp
f0101bda:	85 c0                	test   %eax,%eax
f0101bdc:	0f 85 3a 09 00 00    	jne    f010251c <mem_init+0x1177>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101be2:	6a 02                	push   $0x2
f0101be4:	68 00 10 00 00       	push   $0x1000
f0101be9:	ff 75 d0             	push   -0x30(%ebp)
f0101bec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bef:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101bf5:	e8 39 f7 ff ff       	call   f0101333 <page_insert>
f0101bfa:	83 c4 10             	add    $0x10,%esp
f0101bfd:	85 c0                	test   %eax,%eax
f0101bff:	0f 85 39 09 00 00    	jne    f010253e <mem_init+0x1199>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c0d:	8b 83 30 1a 00 00    	mov    0x1a30(%ebx),%eax
f0101c13:	e8 fc ee ff ff       	call   f0100b14 <check_va2pa>
f0101c18:	89 c2                	mov    %eax,%edx
f0101c1a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c1d:	2b 83 2c 1a 00 00    	sub    0x1a2c(%ebx),%eax
f0101c23:	c1 f8 03             	sar    $0x3,%eax
f0101c26:	c1 e0 0c             	shl    $0xc,%eax
f0101c29:	39 c2                	cmp    %eax,%edx
f0101c2b:	0f 85 2f 09 00 00    	jne    f0102560 <mem_init+0x11bb>
	assert(pp2->pp_ref == 1);
f0101c31:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c34:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c39:	0f 85 43 09 00 00    	jne    f0102582 <mem_init+0x11dd>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c3f:	83 ec 0c             	sub    $0xc,%esp
f0101c42:	6a 00                	push   $0x0
f0101c44:	e8 ad f3 ff ff       	call   f0100ff6 <page_alloc>
f0101c49:	83 c4 10             	add    $0x10,%esp
f0101c4c:	85 c0                	test   %eax,%eax
f0101c4e:	0f 85 50 09 00 00    	jne    f01025a4 <mem_init+0x11ff>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c54:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c57:	8b 91 30 1a 00 00    	mov    0x1a30(%ecx),%edx
f0101c5d:	8b 02                	mov    (%edx),%eax
f0101c5f:	89 c3                	mov    %eax,%ebx
f0101c61:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101c67:	c1 e8 0c             	shr    $0xc,%eax
f0101c6a:	3b 81 34 1a 00 00    	cmp    0x1a34(%ecx),%eax
f0101c70:	0f 83 50 09 00 00    	jae    f01025c6 <mem_init+0x1221>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c76:	83 ec 04             	sub    $0x4,%esp
f0101c79:	6a 00                	push   $0x0
f0101c7b:	68 00 10 00 00       	push   $0x1000
f0101c80:	52                   	push   %edx
f0101c81:	e8 b3 f4 ff ff       	call   f0101139 <pgdir_walk>
f0101c86:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101c8c:	83 c4 10             	add    $0x10,%esp
f0101c8f:	39 d8                	cmp    %ebx,%eax
f0101c91:	0f 85 4a 09 00 00    	jne    f01025e1 <mem_init+0x123c>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c97:	6a 06                	push   $0x6
f0101c99:	68 00 10 00 00       	push   $0x1000
f0101c9e:	ff 75 d0             	push   -0x30(%ebp)
f0101ca1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ca4:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101caa:	e8 84 f6 ff ff       	call   f0101333 <page_insert>
f0101caf:	83 c4 10             	add    $0x10,%esp
f0101cb2:	85 c0                	test   %eax,%eax
f0101cb4:	0f 85 49 09 00 00    	jne    f0102603 <mem_init+0x125e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cba:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101cbd:	8b 9e 30 1a 00 00    	mov    0x1a30(%esi),%ebx
f0101cc3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc8:	89 d8                	mov    %ebx,%eax
f0101cca:	e8 45 ee ff ff       	call   f0100b14 <check_va2pa>
f0101ccf:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101cd1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cd4:	2b 86 2c 1a 00 00    	sub    0x1a2c(%esi),%eax
f0101cda:	c1 f8 03             	sar    $0x3,%eax
f0101cdd:	c1 e0 0c             	shl    $0xc,%eax
f0101ce0:	39 c2                	cmp    %eax,%edx
f0101ce2:	0f 85 3d 09 00 00    	jne    f0102625 <mem_init+0x1280>
	assert(pp2->pp_ref == 1);
f0101ce8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ceb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cf0:	0f 85 51 09 00 00    	jne    f0102647 <mem_init+0x12a2>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101cf6:	83 ec 04             	sub    $0x4,%esp
f0101cf9:	6a 00                	push   $0x0
f0101cfb:	68 00 10 00 00       	push   $0x1000
f0101d00:	53                   	push   %ebx
f0101d01:	e8 33 f4 ff ff       	call   f0101139 <pgdir_walk>
f0101d06:	83 c4 10             	add    $0x10,%esp
f0101d09:	f6 00 04             	testb  $0x4,(%eax)
f0101d0c:	0f 84 57 09 00 00    	je     f0102669 <mem_init+0x12c4>
	assert(kern_pgdir[0] & PTE_U);
f0101d12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d15:	8b 80 30 1a 00 00    	mov    0x1a30(%eax),%eax
f0101d1b:	f6 00 04             	testb  $0x4,(%eax)
f0101d1e:	0f 84 67 09 00 00    	je     f010268b <mem_init+0x12e6>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d24:	6a 02                	push   $0x2
f0101d26:	68 00 10 00 00       	push   $0x1000
f0101d2b:	ff 75 d0             	push   -0x30(%ebp)
f0101d2e:	50                   	push   %eax
f0101d2f:	e8 ff f5 ff ff       	call   f0101333 <page_insert>
f0101d34:	83 c4 10             	add    $0x10,%esp
f0101d37:	85 c0                	test   %eax,%eax
f0101d39:	0f 85 6e 09 00 00    	jne    f01026ad <mem_init+0x1308>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d3f:	83 ec 04             	sub    $0x4,%esp
f0101d42:	6a 00                	push   $0x0
f0101d44:	68 00 10 00 00       	push   $0x1000
f0101d49:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d4c:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101d52:	e8 e2 f3 ff ff       	call   f0101139 <pgdir_walk>
f0101d57:	83 c4 10             	add    $0x10,%esp
f0101d5a:	f6 00 02             	testb  $0x2,(%eax)
f0101d5d:	0f 84 6c 09 00 00    	je     f01026cf <mem_init+0x132a>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d63:	83 ec 04             	sub    $0x4,%esp
f0101d66:	6a 00                	push   $0x0
f0101d68:	68 00 10 00 00       	push   $0x1000
f0101d6d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d70:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101d76:	e8 be f3 ff ff       	call   f0101139 <pgdir_walk>
f0101d7b:	83 c4 10             	add    $0x10,%esp
f0101d7e:	f6 00 04             	testb  $0x4,(%eax)
f0101d81:	0f 85 6a 09 00 00    	jne    f01026f1 <mem_init+0x134c>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d87:	6a 02                	push   $0x2
f0101d89:	68 00 00 40 00       	push   $0x400000
f0101d8e:	ff 75 cc             	push   -0x34(%ebp)
f0101d91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d94:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101d9a:	e8 94 f5 ff ff       	call   f0101333 <page_insert>
f0101d9f:	83 c4 10             	add    $0x10,%esp
f0101da2:	85 c0                	test   %eax,%eax
f0101da4:	0f 89 69 09 00 00    	jns    f0102713 <mem_init+0x136e>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101daa:	6a 02                	push   $0x2
f0101dac:	68 00 10 00 00       	push   $0x1000
f0101db1:	57                   	push   %edi
f0101db2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101db5:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101dbb:	e8 73 f5 ff ff       	call   f0101333 <page_insert>
f0101dc0:	83 c4 10             	add    $0x10,%esp
f0101dc3:	85 c0                	test   %eax,%eax
f0101dc5:	0f 85 6a 09 00 00    	jne    f0102735 <mem_init+0x1390>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dcb:	83 ec 04             	sub    $0x4,%esp
f0101dce:	6a 00                	push   $0x0
f0101dd0:	68 00 10 00 00       	push   $0x1000
f0101dd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dd8:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0101dde:	e8 56 f3 ff ff       	call   f0101139 <pgdir_walk>
f0101de3:	83 c4 10             	add    $0x10,%esp
f0101de6:	f6 00 04             	testb  $0x4,(%eax)
f0101de9:	0f 85 68 09 00 00    	jne    f0102757 <mem_init+0x13b2>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101def:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101df2:	8b b3 30 1a 00 00    	mov    0x1a30(%ebx),%esi
f0101df8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dfd:	89 f0                	mov    %esi,%eax
f0101dff:	e8 10 ed ff ff       	call   f0100b14 <check_va2pa>
f0101e04:	89 d9                	mov    %ebx,%ecx
f0101e06:	89 fb                	mov    %edi,%ebx
f0101e08:	2b 99 2c 1a 00 00    	sub    0x1a2c(%ecx),%ebx
f0101e0e:	c1 fb 03             	sar    $0x3,%ebx
f0101e11:	c1 e3 0c             	shl    $0xc,%ebx
f0101e14:	39 d8                	cmp    %ebx,%eax
f0101e16:	0f 85 5d 09 00 00    	jne    f0102779 <mem_init+0x13d4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e1c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e21:	89 f0                	mov    %esi,%eax
f0101e23:	e8 ec ec ff ff       	call   f0100b14 <check_va2pa>
f0101e28:	39 c3                	cmp    %eax,%ebx
f0101e2a:	0f 85 6b 09 00 00    	jne    f010279b <mem_init+0x13f6>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e30:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101e35:	0f 85 82 09 00 00    	jne    f01027bd <mem_init+0x1418>
	assert(pp2->pp_ref == 0);
f0101e3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e3e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e43:	0f 85 96 09 00 00    	jne    f01027df <mem_init+0x143a>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e49:	83 ec 0c             	sub    $0xc,%esp
f0101e4c:	6a 00                	push   $0x0
f0101e4e:	e8 a3 f1 ff ff       	call   f0100ff6 <page_alloc>
f0101e53:	83 c4 10             	add    $0x10,%esp
f0101e56:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101e59:	0f 85 a2 09 00 00    	jne    f0102801 <mem_init+0x145c>
f0101e5f:	85 c0                	test   %eax,%eax
f0101e61:	0f 84 9a 09 00 00    	je     f0102801 <mem_init+0x145c>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e67:	83 ec 08             	sub    $0x8,%esp
f0101e6a:	6a 00                	push   $0x0
f0101e6c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e6f:	ff b3 30 1a 00 00    	push   0x1a30(%ebx)
f0101e75:	e8 7e f4 ff ff       	call   f01012f8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e7a:	8b 9b 30 1a 00 00    	mov    0x1a30(%ebx),%ebx
f0101e80:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e85:	89 d8                	mov    %ebx,%eax
f0101e87:	e8 88 ec ff ff       	call   f0100b14 <check_va2pa>
f0101e8c:	83 c4 10             	add    $0x10,%esp
f0101e8f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e92:	0f 85 8b 09 00 00    	jne    f0102823 <mem_init+0x147e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e98:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e9d:	89 d8                	mov    %ebx,%eax
f0101e9f:	e8 70 ec ff ff       	call   f0100b14 <check_va2pa>
f0101ea4:	89 c2                	mov    %eax,%edx
f0101ea6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ea9:	89 f8                	mov    %edi,%eax
f0101eab:	2b 81 2c 1a 00 00    	sub    0x1a2c(%ecx),%eax
f0101eb1:	c1 f8 03             	sar    $0x3,%eax
f0101eb4:	c1 e0 0c             	shl    $0xc,%eax
f0101eb7:	39 c2                	cmp    %eax,%edx
f0101eb9:	0f 85 86 09 00 00    	jne    f0102845 <mem_init+0x14a0>
	assert(pp1->pp_ref == 1);
f0101ebf:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ec4:	0f 85 9c 09 00 00    	jne    f0102866 <mem_init+0x14c1>
	assert(pp2->pp_ref == 0);
f0101eca:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ecd:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ed2:	0f 85 b0 09 00 00    	jne    f0102888 <mem_init+0x14e3>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101ed8:	6a 00                	push   $0x0
f0101eda:	68 00 10 00 00       	push   $0x1000
f0101edf:	57                   	push   %edi
f0101ee0:	53                   	push   %ebx
f0101ee1:	e8 4d f4 ff ff       	call   f0101333 <page_insert>
f0101ee6:	83 c4 10             	add    $0x10,%esp
f0101ee9:	85 c0                	test   %eax,%eax
f0101eeb:	0f 85 b9 09 00 00    	jne    f01028aa <mem_init+0x1505>
	assert(pp1->pp_ref);
f0101ef1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ef6:	0f 84 d0 09 00 00    	je     f01028cc <mem_init+0x1527>
	assert(pp1->pp_link == NULL);
f0101efc:	83 3f 00             	cmpl   $0x0,(%edi)
f0101eff:	0f 85 e9 09 00 00    	jne    f01028ee <mem_init+0x1549>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f05:	83 ec 08             	sub    $0x8,%esp
f0101f08:	68 00 10 00 00       	push   $0x1000
f0101f0d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f10:	ff b3 30 1a 00 00    	push   0x1a30(%ebx)
f0101f16:	e8 dd f3 ff ff       	call   f01012f8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f1b:	8b 9b 30 1a 00 00    	mov    0x1a30(%ebx),%ebx
f0101f21:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f26:	89 d8                	mov    %ebx,%eax
f0101f28:	e8 e7 eb ff ff       	call   f0100b14 <check_va2pa>
f0101f2d:	83 c4 10             	add    $0x10,%esp
f0101f30:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f33:	0f 85 d7 09 00 00    	jne    f0102910 <mem_init+0x156b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f39:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f3e:	89 d8                	mov    %ebx,%eax
f0101f40:	e8 cf eb ff ff       	call   f0100b14 <check_va2pa>
f0101f45:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f48:	0f 85 e4 09 00 00    	jne    f0102932 <mem_init+0x158d>
	assert(pp1->pp_ref == 0);
f0101f4e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f53:	0f 85 fb 09 00 00    	jne    f0102954 <mem_init+0x15af>
	assert(pp2->pp_ref == 0);
f0101f59:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f5c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101f61:	0f 85 0f 0a 00 00    	jne    f0102976 <mem_init+0x15d1>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f67:	83 ec 0c             	sub    $0xc,%esp
f0101f6a:	6a 00                	push   $0x0
f0101f6c:	e8 85 f0 ff ff       	call   f0100ff6 <page_alloc>
f0101f71:	83 c4 10             	add    $0x10,%esp
f0101f74:	85 c0                	test   %eax,%eax
f0101f76:	0f 84 1c 0a 00 00    	je     f0102998 <mem_init+0x15f3>
f0101f7c:	39 c7                	cmp    %eax,%edi
f0101f7e:	0f 85 14 0a 00 00    	jne    f0102998 <mem_init+0x15f3>

	// should be no free memory
	assert(!page_alloc(0));
f0101f84:	83 ec 0c             	sub    $0xc,%esp
f0101f87:	6a 00                	push   $0x0
f0101f89:	e8 68 f0 ff ff       	call   f0100ff6 <page_alloc>
f0101f8e:	83 c4 10             	add    $0x10,%esp
f0101f91:	85 c0                	test   %eax,%eax
f0101f93:	0f 85 21 0a 00 00    	jne    f01029ba <mem_init+0x1615>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f9c:	8b 88 30 1a 00 00    	mov    0x1a30(%eax),%ecx
f0101fa2:	8b 11                	mov    (%ecx),%edx
f0101fa4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101faa:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101fad:	2b 98 2c 1a 00 00    	sub    0x1a2c(%eax),%ebx
f0101fb3:	89 d8                	mov    %ebx,%eax
f0101fb5:	c1 f8 03             	sar    $0x3,%eax
f0101fb8:	c1 e0 0c             	shl    $0xc,%eax
f0101fbb:	39 c2                	cmp    %eax,%edx
f0101fbd:	0f 85 19 0a 00 00    	jne    f01029dc <mem_init+0x1637>
	kern_pgdir[0] = 0;
f0101fc3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101fc9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101fcc:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fd1:	0f 85 27 0a 00 00    	jne    f01029fe <mem_init+0x1659>
	pp0->pp_ref = 0;
f0101fd7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101fda:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101fe0:	83 ec 0c             	sub    $0xc,%esp
f0101fe3:	50                   	push   %eax
f0101fe4:	e8 92 f0 ff ff       	call   f010107b <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101fe9:	83 c4 0c             	add    $0xc,%esp
f0101fec:	6a 01                	push   $0x1
f0101fee:	68 00 10 40 00       	push   $0x401000
f0101ff3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ff6:	ff b3 30 1a 00 00    	push   0x1a30(%ebx)
f0101ffc:	e8 38 f1 ff ff       	call   f0101139 <pgdir_walk>
f0102001:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102003:	89 d9                	mov    %ebx,%ecx
f0102005:	8b 9b 30 1a 00 00    	mov    0x1a30(%ebx),%ebx
f010200b:	8b 43 04             	mov    0x4(%ebx),%eax
f010200e:	89 c2                	mov    %eax,%edx
f0102010:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102016:	8b 89 34 1a 00 00    	mov    0x1a34(%ecx),%ecx
f010201c:	c1 e8 0c             	shr    $0xc,%eax
f010201f:	83 c4 10             	add    $0x10,%esp
f0102022:	39 c8                	cmp    %ecx,%eax
f0102024:	0f 83 f6 09 00 00    	jae    f0102a20 <mem_init+0x167b>
	assert(ptep == ptep1 + PTX(va));
f010202a:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102030:	39 d6                	cmp    %edx,%esi
f0102032:	0f 85 04 0a 00 00    	jne    f0102a3c <mem_init+0x1697>
	kern_pgdir[PDX(va)] = 0;
f0102038:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f010203f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102042:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102048:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010204b:	2b 83 2c 1a 00 00    	sub    0x1a2c(%ebx),%eax
f0102051:	c1 f8 03             	sar    $0x3,%eax
f0102054:	89 c2                	mov    %eax,%edx
f0102056:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102059:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010205e:	39 c1                	cmp    %eax,%ecx
f0102060:	0f 86 f8 09 00 00    	jbe    f0102a5e <mem_init+0x16b9>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102066:	83 ec 04             	sub    $0x4,%esp
f0102069:	68 00 10 00 00       	push   $0x1000
f010206e:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102073:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102079:	52                   	push   %edx
f010207a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010207d:	e8 48 2f 00 00       	call   f0104fca <memset>
	page_free(pp0);
f0102082:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102085:	89 34 24             	mov    %esi,(%esp)
f0102088:	e8 ee ef ff ff       	call   f010107b <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010208d:	83 c4 0c             	add    $0xc,%esp
f0102090:	6a 01                	push   $0x1
f0102092:	6a 00                	push   $0x0
f0102094:	ff b3 30 1a 00 00    	push   0x1a30(%ebx)
f010209a:	e8 9a f0 ff ff       	call   f0101139 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f010209f:	89 f0                	mov    %esi,%eax
f01020a1:	2b 83 2c 1a 00 00    	sub    0x1a2c(%ebx),%eax
f01020a7:	c1 f8 03             	sar    $0x3,%eax
f01020aa:	89 c2                	mov    %eax,%edx
f01020ac:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01020af:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01020b4:	83 c4 10             	add    $0x10,%esp
f01020b7:	3b 83 34 1a 00 00    	cmp    0x1a34(%ebx),%eax
f01020bd:	0f 83 b1 09 00 00    	jae    f0102a74 <mem_init+0x16cf>
	return (void *)(pa + KERNBASE);
f01020c3:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01020c9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01020cf:	8b 30                	mov    (%eax),%esi
f01020d1:	83 e6 01             	and    $0x1,%esi
f01020d4:	0f 85 b3 09 00 00    	jne    f0102a8d <mem_init+0x16e8>
	for(i=0; i<NPTENTRIES; i++)
f01020da:	83 c0 04             	add    $0x4,%eax
f01020dd:	39 c2                	cmp    %eax,%edx
f01020df:	75 ee                	jne    f01020cf <mem_init+0xd2a>
	kern_pgdir[0] = 0;
f01020e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020e4:	8b 83 30 1a 00 00    	mov    0x1a30(%ebx),%eax
f01020ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01020f0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01020f3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01020f9:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01020fc:	89 93 40 1a 00 00    	mov    %edx,0x1a40(%ebx)

	// free the pages we took
	page_free(pp0);
f0102102:	83 ec 0c             	sub    $0xc,%esp
f0102105:	50                   	push   %eax
f0102106:	e8 70 ef ff ff       	call   f010107b <page_free>
	page_free(pp1);
f010210b:	89 3c 24             	mov    %edi,(%esp)
f010210e:	e8 68 ef ff ff       	call   f010107b <page_free>
	page_free(pp2);
f0102113:	83 c4 04             	add    $0x4,%esp
f0102116:	ff 75 d0             	push   -0x30(%ebp)
f0102119:	e8 5d ef ff ff       	call   f010107b <page_free>

	cprintf("check_page() succeeded!\n");
f010211e:	8d 83 eb 6a f8 ff    	lea    -0x79515(%ebx),%eax
f0102124:	89 04 24             	mov    %eax,(%esp)
f0102127:	e8 f5 19 00 00       	call   f0103b21 <cprintf>
	boot_map_region(kern_pgdir, UPAGES,ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_U | PTE_P );
f010212c:	8b 83 2c 1a 00 00    	mov    0x1a2c(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102132:	83 c4 10             	add    $0x10,%esp
f0102135:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010213a:	0f 86 6f 09 00 00    	jbe    f0102aaf <mem_init+0x170a>
f0102140:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102143:	8b 97 34 1a 00 00    	mov    0x1a34(%edi),%edx
f0102149:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102150:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102156:	83 ec 08             	sub    $0x8,%esp
f0102159:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010215b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102160:	50                   	push   %eax
f0102161:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102166:	8b 87 30 1a 00 00    	mov    0x1a30(%edi),%eax
f010216c:	e8 94 f0 ff ff       	call   f0101205 <boot_map_region>
	page_insert(kern_pgdir, pages, (void*) pages, PTE_W);
f0102171:	8b 87 2c 1a 00 00    	mov    0x1a2c(%edi),%eax
f0102177:	6a 02                	push   $0x2
f0102179:	50                   	push   %eax
f010217a:	50                   	push   %eax
f010217b:	ff b7 30 1a 00 00    	push   0x1a30(%edi)
f0102181:	e8 ad f1 ff ff       	call   f0101333 <page_insert>
	boot_map_region(kern_pgdir, UENVS, ROUNDUP( NENV*sizeof (struct Env),PGSIZE ), PADDR(envs), PTE_U | PTE_P); // map UENVS to envs
f0102186:	c7 c0 78 13 18 f0    	mov    $0xf0181378,%eax
f010218c:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010218e:	83 c4 20             	add    $0x20,%esp
f0102191:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102196:	0f 86 2f 09 00 00    	jbe    f0102acb <mem_init+0x1726>
f010219c:	83 ec 08             	sub    $0x8,%esp
f010219f:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021a1:	05 00 00 00 10       	add    $0x10000000,%eax
f01021a6:	50                   	push   %eax
f01021a7:	b9 00 80 01 00       	mov    $0x18000,%ecx
f01021ac:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01021b1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021b4:	8b 87 30 1a 00 00    	mov    0x1a30(%edi),%eax
f01021ba:	e8 46 f0 ff ff       	call   f0101205 <boot_map_region>
	page_insert(kern_pgdir, pa2page( PADDR(envs) ), (void*)envs, PTE_W);
f01021bf:	c7 c0 78 13 18 f0    	mov    $0xf0181378,%eax
f01021c5:	8b 10                	mov    (%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f01021c7:	83 c4 10             	add    $0x10,%esp
f01021ca:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01021d0:	0f 86 11 09 00 00    	jbe    f0102ae7 <mem_init+0x1742>
	return (physaddr_t)kva - KERNBASE;
f01021d6:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
	if (PGNUM(pa) >= npages)
f01021dc:	c1 e8 0c             	shr    $0xc,%eax
f01021df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01021e2:	3b 81 34 1a 00 00    	cmp    0x1a34(%ecx),%eax
f01021e8:	0f 83 15 09 00 00    	jae    f0102b03 <mem_init+0x175e>
f01021ee:	6a 02                	push   $0x2
f01021f0:	52                   	push   %edx
	return &pages[PGNUM(pa)];
f01021f1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021f4:	8b 97 2c 1a 00 00    	mov    0x1a2c(%edi),%edx
f01021fa:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01021fd:	50                   	push   %eax
f01021fe:	ff b7 30 1a 00 00    	push   0x1a30(%edi)
f0102204:	e8 2a f1 ff ff       	call   f0101333 <page_insert>
	if ((uint32_t)kva < KERNBASE)
f0102209:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f010220f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102212:	83 c4 10             	add    $0x10,%esp
f0102215:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010221a:	0f 86 fd 08 00 00    	jbe    f0102b1d <mem_init+0x1778>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102220:	83 ec 08             	sub    $0x8,%esp
f0102223:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102225:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102228:	05 00 00 00 10       	add    $0x10000000,%eax
f010222d:	50                   	push   %eax
f010222e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102233:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102238:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010223b:	8b 87 30 1a 00 00    	mov    0x1a30(%edi),%eax
f0102241:	e8 bf ef ff ff       	call   f0101205 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE +1 , 0, PTE_W);
f0102246:	83 c4 08             	add    $0x8,%esp
f0102249:	6a 02                	push   $0x2
f010224b:	6a 00                	push   $0x0
f010224d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102252:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102257:	8b 87 30 1a 00 00    	mov    0x1a30(%edi),%eax
f010225d:	e8 a3 ef ff ff       	call   f0101205 <boot_map_region>
	pgdir = kern_pgdir;
f0102262:	89 f9                	mov    %edi,%ecx
f0102264:	8b bf 30 1a 00 00    	mov    0x1a30(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010226a:	8b 81 34 1a 00 00    	mov    0x1a34(%ecx),%eax
f0102270:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102273:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010227a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010227f:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102281:	8b 81 2c 1a 00 00    	mov    0x1a2c(%ecx),%eax
f0102287:	89 45 bc             	mov    %eax,-0x44(%ebp)
f010228a:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0102290:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102293:	83 c4 10             	add    $0x10,%esp
f0102296:	89 f3                	mov    %esi,%ebx
f0102298:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010229b:	89 c7                	mov    %eax,%edi
f010229d:	89 75 c0             	mov    %esi,-0x40(%ebp)
f01022a0:	89 d6                	mov    %edx,%esi
f01022a2:	39 de                	cmp    %ebx,%esi
f01022a4:	0f 86 d4 08 00 00    	jbe    f0102b7e <mem_init+0x17d9>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022aa:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01022b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01022b3:	e8 5c e8 ff ff       	call   f0100b14 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01022b8:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01022be:	0f 86 7a 08 00 00    	jbe    f0102b3e <mem_init+0x1799>
f01022c4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01022c7:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01022ca:	39 c2                	cmp    %eax,%edx
f01022cc:	0f 85 8a 08 00 00    	jne    f0102b5c <mem_init+0x17b7>
	for (i = 0; i < n; i += PGSIZE)
f01022d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022d8:	eb c8                	jmp    f01022a2 <mem_init+0xefd>
	assert(nfree == 0);
f01022da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022dd:	8d 83 14 6a f8 ff    	lea    -0x795ec(%ebx),%eax
f01022e3:	50                   	push   %eax
f01022e4:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01022ea:	50                   	push   %eax
f01022eb:	68 41 03 00 00       	push   $0x341
f01022f0:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01022f6:	50                   	push   %eax
f01022f7:	e8 c3 dd ff ff       	call   f01000bf <_panic>
	assert((pp0 = page_alloc(0)));
f01022fc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022ff:	8d 83 22 69 f8 ff    	lea    -0x796de(%ebx),%eax
f0102305:	50                   	push   %eax
f0102306:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010230c:	50                   	push   %eax
f010230d:	68 9f 03 00 00       	push   $0x39f
f0102312:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102318:	50                   	push   %eax
f0102319:	e8 a1 dd ff ff       	call   f01000bf <_panic>
	assert((pp1 = page_alloc(0)));
f010231e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102321:	8d 83 38 69 f8 ff    	lea    -0x796c8(%ebx),%eax
f0102327:	50                   	push   %eax
f0102328:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010232e:	50                   	push   %eax
f010232f:	68 a0 03 00 00       	push   $0x3a0
f0102334:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010233a:	50                   	push   %eax
f010233b:	e8 7f dd ff ff       	call   f01000bf <_panic>
	assert((pp2 = page_alloc(0)));
f0102340:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102343:	8d 83 4e 69 f8 ff    	lea    -0x796b2(%ebx),%eax
f0102349:	50                   	push   %eax
f010234a:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102350:	50                   	push   %eax
f0102351:	68 a1 03 00 00       	push   $0x3a1
f0102356:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010235c:	50                   	push   %eax
f010235d:	e8 5d dd ff ff       	call   f01000bf <_panic>
	assert(pp1 && pp1 != pp0);
f0102362:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102365:	8d 83 64 69 f8 ff    	lea    -0x7969c(%ebx),%eax
f010236b:	50                   	push   %eax
f010236c:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102372:	50                   	push   %eax
f0102373:	68 a4 03 00 00       	push   $0x3a4
f0102378:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010237e:	50                   	push   %eax
f010237f:	e8 3b dd ff ff       	call   f01000bf <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102384:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102387:	8d 83 98 61 f8 ff    	lea    -0x79e68(%ebx),%eax
f010238d:	50                   	push   %eax
f010238e:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102394:	50                   	push   %eax
f0102395:	68 a5 03 00 00       	push   $0x3a5
f010239a:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01023a0:	50                   	push   %eax
f01023a1:	e8 19 dd ff ff       	call   f01000bf <_panic>
	assert(!page_alloc(0));
f01023a6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023a9:	8d 83 cd 69 f8 ff    	lea    -0x79633(%ebx),%eax
f01023af:	50                   	push   %eax
f01023b0:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01023b6:	50                   	push   %eax
f01023b7:	68 ac 03 00 00       	push   $0x3ac
f01023bc:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01023c2:	50                   	push   %eax
f01023c3:	e8 f7 dc ff ff       	call   f01000bf <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01023c8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023cb:	8d 83 d8 61 f8 ff    	lea    -0x79e28(%ebx),%eax
f01023d1:	50                   	push   %eax
f01023d2:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01023d8:	50                   	push   %eax
f01023d9:	68 af 03 00 00       	push   $0x3af
f01023de:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01023e4:	50                   	push   %eax
f01023e5:	e8 d5 dc ff ff       	call   f01000bf <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01023ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ed:	8d 83 10 62 f8 ff    	lea    -0x79df0(%ebx),%eax
f01023f3:	50                   	push   %eax
f01023f4:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01023fa:	50                   	push   %eax
f01023fb:	68 b2 03 00 00       	push   $0x3b2
f0102400:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102406:	50                   	push   %eax
f0102407:	e8 b3 dc ff ff       	call   f01000bf <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010240c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010240f:	8d 83 40 62 f8 ff    	lea    -0x79dc0(%ebx),%eax
f0102415:	50                   	push   %eax
f0102416:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010241c:	50                   	push   %eax
f010241d:	68 b6 03 00 00       	push   $0x3b6
f0102422:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102428:	50                   	push   %eax
f0102429:	e8 91 dc ff ff       	call   f01000bf <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010242e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102431:	8d 83 70 62 f8 ff    	lea    -0x79d90(%ebx),%eax
f0102437:	50                   	push   %eax
f0102438:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010243e:	50                   	push   %eax
f010243f:	68 b7 03 00 00       	push   $0x3b7
f0102444:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010244a:	50                   	push   %eax
f010244b:	e8 6f dc ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102450:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102453:	8d 83 98 62 f8 ff    	lea    -0x79d68(%ebx),%eax
f0102459:	50                   	push   %eax
f010245a:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102460:	50                   	push   %eax
f0102461:	68 b8 03 00 00       	push   $0x3b8
f0102466:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010246c:	50                   	push   %eax
f010246d:	e8 4d dc ff ff       	call   f01000bf <_panic>
	assert(pp1->pp_ref == 1);
f0102472:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102475:	8d 83 1f 6a f8 ff    	lea    -0x795e1(%ebx),%eax
f010247b:	50                   	push   %eax
f010247c:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102482:	50                   	push   %eax
f0102483:	68 b9 03 00 00       	push   $0x3b9
f0102488:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010248e:	50                   	push   %eax
f010248f:	e8 2b dc ff ff       	call   f01000bf <_panic>
	assert(pp0->pp_ref == 1);
f0102494:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102497:	8d 83 30 6a f8 ff    	lea    -0x795d0(%ebx),%eax
f010249d:	50                   	push   %eax
f010249e:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01024a4:	50                   	push   %eax
f01024a5:	68 ba 03 00 00       	push   $0x3ba
f01024aa:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01024b0:	50                   	push   %eax
f01024b1:	e8 09 dc ff ff       	call   f01000bf <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024b6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024b9:	8d 83 c8 62 f8 ff    	lea    -0x79d38(%ebx),%eax
f01024bf:	50                   	push   %eax
f01024c0:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01024c6:	50                   	push   %eax
f01024c7:	68 bd 03 00 00       	push   $0x3bd
f01024cc:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01024d2:	50                   	push   %eax
f01024d3:	e8 e7 db ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024d8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024db:	8d 83 04 63 f8 ff    	lea    -0x79cfc(%ebx),%eax
f01024e1:	50                   	push   %eax
f01024e2:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01024e8:	50                   	push   %eax
f01024e9:	68 be 03 00 00       	push   $0x3be
f01024ee:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01024f4:	50                   	push   %eax
f01024f5:	e8 c5 db ff ff       	call   f01000bf <_panic>
	assert(pp2->pp_ref == 1);
f01024fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024fd:	8d 83 41 6a f8 ff    	lea    -0x795bf(%ebx),%eax
f0102503:	50                   	push   %eax
f0102504:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010250a:	50                   	push   %eax
f010250b:	68 bf 03 00 00       	push   $0x3bf
f0102510:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102516:	50                   	push   %eax
f0102517:	e8 a3 db ff ff       	call   f01000bf <_panic>
	assert(!page_alloc(0));
f010251c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010251f:	8d 83 cd 69 f8 ff    	lea    -0x79633(%ebx),%eax
f0102525:	50                   	push   %eax
f0102526:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010252c:	50                   	push   %eax
f010252d:	68 c2 03 00 00       	push   $0x3c2
f0102532:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102538:	50                   	push   %eax
f0102539:	e8 81 db ff ff       	call   f01000bf <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010253e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102541:	8d 83 c8 62 f8 ff    	lea    -0x79d38(%ebx),%eax
f0102547:	50                   	push   %eax
f0102548:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010254e:	50                   	push   %eax
f010254f:	68 c5 03 00 00       	push   $0x3c5
f0102554:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010255a:	50                   	push   %eax
f010255b:	e8 5f db ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102560:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102563:	8d 83 04 63 f8 ff    	lea    -0x79cfc(%ebx),%eax
f0102569:	50                   	push   %eax
f010256a:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102570:	50                   	push   %eax
f0102571:	68 c6 03 00 00       	push   $0x3c6
f0102576:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010257c:	50                   	push   %eax
f010257d:	e8 3d db ff ff       	call   f01000bf <_panic>
	assert(pp2->pp_ref == 1);
f0102582:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102585:	8d 83 41 6a f8 ff    	lea    -0x795bf(%ebx),%eax
f010258b:	50                   	push   %eax
f010258c:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102592:	50                   	push   %eax
f0102593:	68 c7 03 00 00       	push   $0x3c7
f0102598:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010259e:	50                   	push   %eax
f010259f:	e8 1b db ff ff       	call   f01000bf <_panic>
	assert(!page_alloc(0));
f01025a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a7:	8d 83 cd 69 f8 ff    	lea    -0x79633(%ebx),%eax
f01025ad:	50                   	push   %eax
f01025ae:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01025b4:	50                   	push   %eax
f01025b5:	68 cb 03 00 00       	push   $0x3cb
f01025ba:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01025c0:	50                   	push   %eax
f01025c1:	e8 f9 da ff ff       	call   f01000bf <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025c6:	53                   	push   %ebx
f01025c7:	89 cb                	mov    %ecx,%ebx
f01025c9:	8d 81 30 60 f8 ff    	lea    -0x79fd0(%ecx),%eax
f01025cf:	50                   	push   %eax
f01025d0:	68 ce 03 00 00       	push   $0x3ce
f01025d5:	8d 81 ed 67 f8 ff    	lea    -0x79813(%ecx),%eax
f01025db:	50                   	push   %eax
f01025dc:	e8 de da ff ff       	call   f01000bf <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01025e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025e4:	8d 83 34 63 f8 ff    	lea    -0x79ccc(%ebx),%eax
f01025ea:	50                   	push   %eax
f01025eb:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01025f1:	50                   	push   %eax
f01025f2:	68 cf 03 00 00       	push   $0x3cf
f01025f7:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01025fd:	50                   	push   %eax
f01025fe:	e8 bc da ff ff       	call   f01000bf <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102603:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102606:	8d 83 74 63 f8 ff    	lea    -0x79c8c(%ebx),%eax
f010260c:	50                   	push   %eax
f010260d:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102613:	50                   	push   %eax
f0102614:	68 d2 03 00 00       	push   $0x3d2
f0102619:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010261f:	50                   	push   %eax
f0102620:	e8 9a da ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102625:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102628:	8d 83 04 63 f8 ff    	lea    -0x79cfc(%ebx),%eax
f010262e:	50                   	push   %eax
f010262f:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102635:	50                   	push   %eax
f0102636:	68 d3 03 00 00       	push   $0x3d3
f010263b:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102641:	50                   	push   %eax
f0102642:	e8 78 da ff ff       	call   f01000bf <_panic>
	assert(pp2->pp_ref == 1);
f0102647:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010264a:	8d 83 41 6a f8 ff    	lea    -0x795bf(%ebx),%eax
f0102650:	50                   	push   %eax
f0102651:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102657:	50                   	push   %eax
f0102658:	68 d4 03 00 00       	push   $0x3d4
f010265d:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102663:	50                   	push   %eax
f0102664:	e8 56 da ff ff       	call   f01000bf <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102669:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010266c:	8d 83 b4 63 f8 ff    	lea    -0x79c4c(%ebx),%eax
f0102672:	50                   	push   %eax
f0102673:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102679:	50                   	push   %eax
f010267a:	68 d5 03 00 00       	push   $0x3d5
f010267f:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102685:	50                   	push   %eax
f0102686:	e8 34 da ff ff       	call   f01000bf <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010268b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010268e:	8d 83 52 6a f8 ff    	lea    -0x795ae(%ebx),%eax
f0102694:	50                   	push   %eax
f0102695:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010269b:	50                   	push   %eax
f010269c:	68 d6 03 00 00       	push   $0x3d6
f01026a1:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01026a7:	50                   	push   %eax
f01026a8:	e8 12 da ff ff       	call   f01000bf <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01026ad:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026b0:	8d 83 c8 62 f8 ff    	lea    -0x79d38(%ebx),%eax
f01026b6:	50                   	push   %eax
f01026b7:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01026bd:	50                   	push   %eax
f01026be:	68 d9 03 00 00       	push   $0x3d9
f01026c3:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01026c9:	50                   	push   %eax
f01026ca:	e8 f0 d9 ff ff       	call   f01000bf <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01026cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026d2:	8d 83 e8 63 f8 ff    	lea    -0x79c18(%ebx),%eax
f01026d8:	50                   	push   %eax
f01026d9:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01026df:	50                   	push   %eax
f01026e0:	68 da 03 00 00       	push   $0x3da
f01026e5:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01026eb:	50                   	push   %eax
f01026ec:	e8 ce d9 ff ff       	call   f01000bf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026f4:	8d 83 1c 64 f8 ff    	lea    -0x79be4(%ebx),%eax
f01026fa:	50                   	push   %eax
f01026fb:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102701:	50                   	push   %eax
f0102702:	68 db 03 00 00       	push   $0x3db
f0102707:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010270d:	50                   	push   %eax
f010270e:	e8 ac d9 ff ff       	call   f01000bf <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102713:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102716:	8d 83 54 64 f8 ff    	lea    -0x79bac(%ebx),%eax
f010271c:	50                   	push   %eax
f010271d:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102723:	50                   	push   %eax
f0102724:	68 de 03 00 00       	push   $0x3de
f0102729:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010272f:	50                   	push   %eax
f0102730:	e8 8a d9 ff ff       	call   f01000bf <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102735:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102738:	8d 83 8c 64 f8 ff    	lea    -0x79b74(%ebx),%eax
f010273e:	50                   	push   %eax
f010273f:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102745:	50                   	push   %eax
f0102746:	68 e1 03 00 00       	push   $0x3e1
f010274b:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102751:	50                   	push   %eax
f0102752:	e8 68 d9 ff ff       	call   f01000bf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102757:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010275a:	8d 83 1c 64 f8 ff    	lea    -0x79be4(%ebx),%eax
f0102760:	50                   	push   %eax
f0102761:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102767:	50                   	push   %eax
f0102768:	68 e2 03 00 00       	push   $0x3e2
f010276d:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102773:	50                   	push   %eax
f0102774:	e8 46 d9 ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102779:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010277c:	8d 83 c8 64 f8 ff    	lea    -0x79b38(%ebx),%eax
f0102782:	50                   	push   %eax
f0102783:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102789:	50                   	push   %eax
f010278a:	68 e5 03 00 00       	push   $0x3e5
f010278f:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102795:	50                   	push   %eax
f0102796:	e8 24 d9 ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010279b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010279e:	8d 83 f4 64 f8 ff    	lea    -0x79b0c(%ebx),%eax
f01027a4:	50                   	push   %eax
f01027a5:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01027ab:	50                   	push   %eax
f01027ac:	68 e6 03 00 00       	push   $0x3e6
f01027b1:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01027b7:	50                   	push   %eax
f01027b8:	e8 02 d9 ff ff       	call   f01000bf <_panic>
	assert(pp1->pp_ref == 2);
f01027bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c0:	8d 83 68 6a f8 ff    	lea    -0x79598(%ebx),%eax
f01027c6:	50                   	push   %eax
f01027c7:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01027cd:	50                   	push   %eax
f01027ce:	68 e8 03 00 00       	push   $0x3e8
f01027d3:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01027d9:	50                   	push   %eax
f01027da:	e8 e0 d8 ff ff       	call   f01000bf <_panic>
	assert(pp2->pp_ref == 0);
f01027df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e2:	8d 83 79 6a f8 ff    	lea    -0x79587(%ebx),%eax
f01027e8:	50                   	push   %eax
f01027e9:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01027ef:	50                   	push   %eax
f01027f0:	68 e9 03 00 00       	push   $0x3e9
f01027f5:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01027fb:	50                   	push   %eax
f01027fc:	e8 be d8 ff ff       	call   f01000bf <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102801:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102804:	8d 83 24 65 f8 ff    	lea    -0x79adc(%ebx),%eax
f010280a:	50                   	push   %eax
f010280b:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102811:	50                   	push   %eax
f0102812:	68 ec 03 00 00       	push   $0x3ec
f0102817:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010281d:	50                   	push   %eax
f010281e:	e8 9c d8 ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102823:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102826:	8d 83 48 65 f8 ff    	lea    -0x79ab8(%ebx),%eax
f010282c:	50                   	push   %eax
f010282d:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102833:	50                   	push   %eax
f0102834:	68 f0 03 00 00       	push   $0x3f0
f0102839:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010283f:	50                   	push   %eax
f0102840:	e8 7a d8 ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102845:	89 cb                	mov    %ecx,%ebx
f0102847:	8d 81 f4 64 f8 ff    	lea    -0x79b0c(%ecx),%eax
f010284d:	50                   	push   %eax
f010284e:	8d 81 2e 68 f8 ff    	lea    -0x797d2(%ecx),%eax
f0102854:	50                   	push   %eax
f0102855:	68 f1 03 00 00       	push   $0x3f1
f010285a:	8d 81 ed 67 f8 ff    	lea    -0x79813(%ecx),%eax
f0102860:	50                   	push   %eax
f0102861:	e8 59 d8 ff ff       	call   f01000bf <_panic>
	assert(pp1->pp_ref == 1);
f0102866:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102869:	8d 83 1f 6a f8 ff    	lea    -0x795e1(%ebx),%eax
f010286f:	50                   	push   %eax
f0102870:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102876:	50                   	push   %eax
f0102877:	68 f2 03 00 00       	push   $0x3f2
f010287c:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102882:	50                   	push   %eax
f0102883:	e8 37 d8 ff ff       	call   f01000bf <_panic>
	assert(pp2->pp_ref == 0);
f0102888:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010288b:	8d 83 79 6a f8 ff    	lea    -0x79587(%ebx),%eax
f0102891:	50                   	push   %eax
f0102892:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102898:	50                   	push   %eax
f0102899:	68 f3 03 00 00       	push   $0x3f3
f010289e:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01028a4:	50                   	push   %eax
f01028a5:	e8 15 d8 ff ff       	call   f01000bf <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01028aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028ad:	8d 83 6c 65 f8 ff    	lea    -0x79a94(%ebx),%eax
f01028b3:	50                   	push   %eax
f01028b4:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01028ba:	50                   	push   %eax
f01028bb:	68 f6 03 00 00       	push   $0x3f6
f01028c0:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01028c6:	50                   	push   %eax
f01028c7:	e8 f3 d7 ff ff       	call   f01000bf <_panic>
	assert(pp1->pp_ref);
f01028cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028cf:	8d 83 8a 6a f8 ff    	lea    -0x79576(%ebx),%eax
f01028d5:	50                   	push   %eax
f01028d6:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01028dc:	50                   	push   %eax
f01028dd:	68 f7 03 00 00       	push   $0x3f7
f01028e2:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01028e8:	50                   	push   %eax
f01028e9:	e8 d1 d7 ff ff       	call   f01000bf <_panic>
	assert(pp1->pp_link == NULL);
f01028ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028f1:	8d 83 96 6a f8 ff    	lea    -0x7956a(%ebx),%eax
f01028f7:	50                   	push   %eax
f01028f8:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01028fe:	50                   	push   %eax
f01028ff:	68 f8 03 00 00       	push   $0x3f8
f0102904:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010290a:	50                   	push   %eax
f010290b:	e8 af d7 ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102910:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102913:	8d 83 48 65 f8 ff    	lea    -0x79ab8(%ebx),%eax
f0102919:	50                   	push   %eax
f010291a:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102920:	50                   	push   %eax
f0102921:	68 fc 03 00 00       	push   $0x3fc
f0102926:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010292c:	50                   	push   %eax
f010292d:	e8 8d d7 ff ff       	call   f01000bf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102932:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102935:	8d 83 a4 65 f8 ff    	lea    -0x79a5c(%ebx),%eax
f010293b:	50                   	push   %eax
f010293c:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102942:	50                   	push   %eax
f0102943:	68 fd 03 00 00       	push   $0x3fd
f0102948:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010294e:	50                   	push   %eax
f010294f:	e8 6b d7 ff ff       	call   f01000bf <_panic>
	assert(pp1->pp_ref == 0);
f0102954:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102957:	8d 83 ab 6a f8 ff    	lea    -0x79555(%ebx),%eax
f010295d:	50                   	push   %eax
f010295e:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102964:	50                   	push   %eax
f0102965:	68 fe 03 00 00       	push   $0x3fe
f010296a:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102970:	50                   	push   %eax
f0102971:	e8 49 d7 ff ff       	call   f01000bf <_panic>
	assert(pp2->pp_ref == 0);
f0102976:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102979:	8d 83 79 6a f8 ff    	lea    -0x79587(%ebx),%eax
f010297f:	50                   	push   %eax
f0102980:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102986:	50                   	push   %eax
f0102987:	68 ff 03 00 00       	push   $0x3ff
f010298c:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102992:	50                   	push   %eax
f0102993:	e8 27 d7 ff ff       	call   f01000bf <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102998:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010299b:	8d 83 cc 65 f8 ff    	lea    -0x79a34(%ebx),%eax
f01029a1:	50                   	push   %eax
f01029a2:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01029a8:	50                   	push   %eax
f01029a9:	68 02 04 00 00       	push   $0x402
f01029ae:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01029b4:	50                   	push   %eax
f01029b5:	e8 05 d7 ff ff       	call   f01000bf <_panic>
	assert(!page_alloc(0));
f01029ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029bd:	8d 83 cd 69 f8 ff    	lea    -0x79633(%ebx),%eax
f01029c3:	50                   	push   %eax
f01029c4:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01029ca:	50                   	push   %eax
f01029cb:	68 05 04 00 00       	push   $0x405
f01029d0:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01029d6:	50                   	push   %eax
f01029d7:	e8 e3 d6 ff ff       	call   f01000bf <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01029dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029df:	8d 83 70 62 f8 ff    	lea    -0x79d90(%ebx),%eax
f01029e5:	50                   	push   %eax
f01029e6:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01029ec:	50                   	push   %eax
f01029ed:	68 08 04 00 00       	push   $0x408
f01029f2:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01029f8:	50                   	push   %eax
f01029f9:	e8 c1 d6 ff ff       	call   f01000bf <_panic>
	assert(pp0->pp_ref == 1);
f01029fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a01:	8d 83 30 6a f8 ff    	lea    -0x795d0(%ebx),%eax
f0102a07:	50                   	push   %eax
f0102a08:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102a0e:	50                   	push   %eax
f0102a0f:	68 0a 04 00 00       	push   $0x40a
f0102a14:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102a1a:	50                   	push   %eax
f0102a1b:	e8 9f d6 ff ff       	call   f01000bf <_panic>
f0102a20:	52                   	push   %edx
f0102a21:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a24:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f0102a2a:	50                   	push   %eax
f0102a2b:	68 11 04 00 00       	push   $0x411
f0102a30:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102a36:	50                   	push   %eax
f0102a37:	e8 83 d6 ff ff       	call   f01000bf <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102a3c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a3f:	8d 83 bc 6a f8 ff    	lea    -0x79544(%ebx),%eax
f0102a45:	50                   	push   %eax
f0102a46:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102a4c:	50                   	push   %eax
f0102a4d:	68 12 04 00 00       	push   $0x412
f0102a52:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102a58:	50                   	push   %eax
f0102a59:	e8 61 d6 ff ff       	call   f01000bf <_panic>
f0102a5e:	52                   	push   %edx
f0102a5f:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f0102a65:	50                   	push   %eax
f0102a66:	6a 56                	push   $0x56
f0102a68:	8d 83 14 68 f8 ff    	lea    -0x797ec(%ebx),%eax
f0102a6e:	50                   	push   %eax
f0102a6f:	e8 4b d6 ff ff       	call   f01000bf <_panic>
f0102a74:	52                   	push   %edx
f0102a75:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a78:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f0102a7e:	50                   	push   %eax
f0102a7f:	6a 56                	push   $0x56
f0102a81:	8d 83 14 68 f8 ff    	lea    -0x797ec(%ebx),%eax
f0102a87:	50                   	push   %eax
f0102a88:	e8 32 d6 ff ff       	call   f01000bf <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102a8d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a90:	8d 83 d4 6a f8 ff    	lea    -0x7952c(%ebx),%eax
f0102a96:	50                   	push   %eax
f0102a97:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102a9d:	50                   	push   %eax
f0102a9e:	68 1c 04 00 00       	push   $0x41c
f0102aa3:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102aa9:	50                   	push   %eax
f0102aaa:	e8 10 d6 ff ff       	call   f01000bf <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aaf:	50                   	push   %eax
f0102ab0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab3:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f0102ab9:	50                   	push   %eax
f0102aba:	68 c2 00 00 00       	push   $0xc2
f0102abf:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102ac5:	50                   	push   %eax
f0102ac6:	e8 f4 d5 ff ff       	call   f01000bf <_panic>
f0102acb:	50                   	push   %eax
f0102acc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102acf:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f0102ad5:	50                   	push   %eax
f0102ad6:	68 ce 00 00 00       	push   $0xce
f0102adb:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102ae1:	50                   	push   %eax
f0102ae2:	e8 d8 d5 ff ff       	call   f01000bf <_panic>
f0102ae7:	52                   	push   %edx
f0102ae8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102aeb:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f0102af1:	50                   	push   %eax
f0102af2:	68 cf 00 00 00       	push   $0xcf
f0102af7:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102afd:	50                   	push   %eax
f0102afe:	e8 bc d5 ff ff       	call   f01000bf <_panic>
		panic("pa2page called with invalid pa");
f0102b03:	83 ec 04             	sub    $0x4,%esp
f0102b06:	89 cb                	mov    %ecx,%ebx
f0102b08:	8d 81 3c 61 f8 ff    	lea    -0x79ec4(%ecx),%eax
f0102b0e:	50                   	push   %eax
f0102b0f:	6a 4f                	push   $0x4f
f0102b11:	8d 81 14 68 f8 ff    	lea    -0x797ec(%ecx),%eax
f0102b17:	50                   	push   %eax
f0102b18:	e8 a2 d5 ff ff       	call   f01000bf <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b1d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b20:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0102b26:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f0102b2c:	50                   	push   %eax
f0102b2d:	68 dc 00 00 00       	push   $0xdc
f0102b32:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102b38:	50                   	push   %eax
f0102b39:	e8 81 d5 ff ff       	call   f01000bf <_panic>
f0102b3e:	ff 75 bc             	push   -0x44(%ebp)
f0102b41:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b44:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f0102b4a:	50                   	push   %eax
f0102b4b:	68 59 03 00 00       	push   $0x359
f0102b50:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102b56:	50                   	push   %eax
f0102b57:	e8 63 d5 ff ff       	call   f01000bf <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b5c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b5f:	8d 83 f0 65 f8 ff    	lea    -0x79a10(%ebx),%eax
f0102b65:	50                   	push   %eax
f0102b66:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102b6c:	50                   	push   %eax
f0102b6d:	68 59 03 00 00       	push   $0x359
f0102b72:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102b78:	50                   	push   %eax
f0102b79:	e8 41 d5 ff ff       	call   f01000bf <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102b7e:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102b81:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102b84:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b87:	c7 c0 78 13 18 f0    	mov    $0xf0181378,%eax
f0102b8d:	8b 00                	mov    (%eax),%eax
f0102b8f:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102b92:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102b97:	8d 88 00 00 40 21    	lea    0x21400000(%eax),%ecx
f0102b9d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102ba0:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102ba3:	89 c6                	mov    %eax,%esi
f0102ba5:	89 da                	mov    %ebx,%edx
f0102ba7:	89 f8                	mov    %edi,%eax
f0102ba9:	e8 66 df ff ff       	call   f0100b14 <check_va2pa>
f0102bae:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102bb4:	76 45                	jbe    f0102bfb <mem_init+0x1856>
f0102bb6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102bb9:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102bbc:	39 c2                	cmp    %eax,%edx
f0102bbe:	75 59                	jne    f0102c19 <mem_init+0x1874>
	for (i = 0; i < n; i += PGSIZE)
f0102bc0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102bc6:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f0102bcc:	75 d7                	jne    f0102ba5 <mem_init+0x1800>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102bce:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102bd1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102bd4:	c1 e0 0c             	shl    $0xc,%eax
f0102bd7:	89 f3                	mov    %esi,%ebx
f0102bd9:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102bdc:	89 c6                	mov    %eax,%esi
f0102bde:	39 f3                	cmp    %esi,%ebx
f0102be0:	73 7b                	jae    f0102c5d <mem_init+0x18b8>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102be2:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102be8:	89 f8                	mov    %edi,%eax
f0102bea:	e8 25 df ff ff       	call   f0100b14 <check_va2pa>
f0102bef:	39 c3                	cmp    %eax,%ebx
f0102bf1:	75 48                	jne    f0102c3b <mem_init+0x1896>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102bf3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102bf9:	eb e3                	jmp    f0102bde <mem_init+0x1839>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bfb:	ff 75 c0             	push   -0x40(%ebp)
f0102bfe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c01:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f0102c07:	50                   	push   %eax
f0102c08:	68 5e 03 00 00       	push   $0x35e
f0102c0d:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102c13:	50                   	push   %eax
f0102c14:	e8 a6 d4 ff ff       	call   f01000bf <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102c19:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c1c:	8d 83 24 66 f8 ff    	lea    -0x799dc(%ebx),%eax
f0102c22:	50                   	push   %eax
f0102c23:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102c29:	50                   	push   %eax
f0102c2a:	68 5e 03 00 00       	push   $0x35e
f0102c2f:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102c35:	50                   	push   %eax
f0102c36:	e8 84 d4 ff ff       	call   f01000bf <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c3b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c3e:	8d 83 58 66 f8 ff    	lea    -0x799a8(%ebx),%eax
f0102c44:	50                   	push   %eax
f0102c45:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102c4b:	50                   	push   %eax
f0102c4c:	68 62 03 00 00       	push   $0x362
f0102c51:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102c57:	50                   	push   %eax
f0102c58:	e8 62 d4 ff ff       	call   f01000bf <_panic>
f0102c5d:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c62:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102c65:	05 00 80 00 20       	add    $0x20008000,%eax
f0102c6a:	89 c6                	mov    %eax,%esi
f0102c6c:	89 da                	mov    %ebx,%edx
f0102c6e:	89 f8                	mov    %edi,%eax
f0102c70:	e8 9f de ff ff       	call   f0100b14 <check_va2pa>
f0102c75:	89 c2                	mov    %eax,%edx
f0102c77:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102c7a:	39 c2                	cmp    %eax,%edx
f0102c7c:	75 44                	jne    f0102cc2 <mem_init+0x191d>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102c7e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c84:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102c8a:	75 e0                	jne    f0102c6c <mem_init+0x18c7>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c8c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102c8f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102c94:	89 f8                	mov    %edi,%eax
f0102c96:	e8 79 de ff ff       	call   f0100b14 <check_va2pa>
f0102c9b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c9e:	74 71                	je     f0102d11 <mem_init+0x196c>
f0102ca0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ca3:	8d 83 c8 66 f8 ff    	lea    -0x79938(%ebx),%eax
f0102ca9:	50                   	push   %eax
f0102caa:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102cb0:	50                   	push   %eax
f0102cb1:	68 67 03 00 00       	push   $0x367
f0102cb6:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102cbc:	50                   	push   %eax
f0102cbd:	e8 fd d3 ff ff       	call   f01000bf <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102cc2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cc5:	8d 83 80 66 f8 ff    	lea    -0x79980(%ebx),%eax
f0102ccb:	50                   	push   %eax
f0102ccc:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102cd2:	50                   	push   %eax
f0102cd3:	68 66 03 00 00       	push   $0x366
f0102cd8:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102cde:	50                   	push   %eax
f0102cdf:	e8 db d3 ff ff       	call   f01000bf <_panic>
		switch (i) {
f0102ce4:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102cea:	75 25                	jne    f0102d11 <mem_init+0x196c>
			assert(pgdir[i] & PTE_P);
f0102cec:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102cf0:	74 4f                	je     f0102d41 <mem_init+0x199c>
	for (i = 0; i < NPDENTRIES; i++) {
f0102cf2:	83 c6 01             	add    $0x1,%esi
f0102cf5:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102cfb:	0f 87 b1 00 00 00    	ja     f0102db2 <mem_init+0x1a0d>
		switch (i) {
f0102d01:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102d07:	77 db                	ja     f0102ce4 <mem_init+0x193f>
f0102d09:	81 fe ba 03 00 00    	cmp    $0x3ba,%esi
f0102d0f:	77 db                	ja     f0102cec <mem_init+0x1947>
			if (i >= PDX(KERNBASE)) {
f0102d11:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102d17:	77 4a                	ja     f0102d63 <mem_init+0x19be>
				assert(pgdir[i] == 0);
f0102d19:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102d1d:	74 d3                	je     f0102cf2 <mem_init+0x194d>
f0102d1f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d22:	8d 83 26 6b f8 ff    	lea    -0x794da(%ebx),%eax
f0102d28:	50                   	push   %eax
f0102d29:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102d2f:	50                   	push   %eax
f0102d30:	68 77 03 00 00       	push   $0x377
f0102d35:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102d3b:	50                   	push   %eax
f0102d3c:	e8 7e d3 ff ff       	call   f01000bf <_panic>
			assert(pgdir[i] & PTE_P);
f0102d41:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d44:	8d 83 04 6b f8 ff    	lea    -0x794fc(%ebx),%eax
f0102d4a:	50                   	push   %eax
f0102d4b:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102d51:	50                   	push   %eax
f0102d52:	68 70 03 00 00       	push   $0x370
f0102d57:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102d5d:	50                   	push   %eax
f0102d5e:	e8 5c d3 ff ff       	call   f01000bf <_panic>
				assert(pgdir[i] & PTE_P);
f0102d63:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102d66:	a8 01                	test   $0x1,%al
f0102d68:	74 26                	je     f0102d90 <mem_init+0x19eb>
				assert(pgdir[i] & PTE_W);
f0102d6a:	a8 02                	test   $0x2,%al
f0102d6c:	75 84                	jne    f0102cf2 <mem_init+0x194d>
f0102d6e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d71:	8d 83 15 6b f8 ff    	lea    -0x794eb(%ebx),%eax
f0102d77:	50                   	push   %eax
f0102d78:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102d7e:	50                   	push   %eax
f0102d7f:	68 75 03 00 00       	push   $0x375
f0102d84:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102d8a:	50                   	push   %eax
f0102d8b:	e8 2f d3 ff ff       	call   f01000bf <_panic>
				assert(pgdir[i] & PTE_P);
f0102d90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d93:	8d 83 04 6b f8 ff    	lea    -0x794fc(%ebx),%eax
f0102d99:	50                   	push   %eax
f0102d9a:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102da0:	50                   	push   %eax
f0102da1:	68 74 03 00 00       	push   $0x374
f0102da6:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0102dac:	50                   	push   %eax
f0102dad:	e8 0d d3 ff ff       	call   f01000bf <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102db2:	83 ec 0c             	sub    $0xc,%esp
f0102db5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102db8:	8d 83 f8 66 f8 ff    	lea    -0x79908(%ebx),%eax
f0102dbe:	50                   	push   %eax
f0102dbf:	e8 5d 0d 00 00       	call   f0103b21 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102dc4:	8b 83 30 1a 00 00    	mov    0x1a30(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102dca:	83 c4 10             	add    $0x10,%esp
f0102dcd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dd2:	0f 86 2c 02 00 00    	jbe    f0103004 <mem_init+0x1c5f>
	return (physaddr_t)kva - KERNBASE;
f0102dd8:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102ddd:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102de0:	b8 00 00 00 00       	mov    $0x0,%eax
f0102de5:	e8 a6 dd ff ff       	call   f0100b90 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102dea:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102ded:	83 e0 f3             	and    $0xfffffff3,%eax
f0102df0:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102df5:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102df8:	83 ec 0c             	sub    $0xc,%esp
f0102dfb:	6a 00                	push   $0x0
f0102dfd:	e8 f4 e1 ff ff       	call   f0100ff6 <page_alloc>
f0102e02:	89 c6                	mov    %eax,%esi
f0102e04:	83 c4 10             	add    $0x10,%esp
f0102e07:	85 c0                	test   %eax,%eax
f0102e09:	0f 84 11 02 00 00    	je     f0103020 <mem_init+0x1c7b>
	assert((pp1 = page_alloc(0)));
f0102e0f:	83 ec 0c             	sub    $0xc,%esp
f0102e12:	6a 00                	push   $0x0
f0102e14:	e8 dd e1 ff ff       	call   f0100ff6 <page_alloc>
f0102e19:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e1c:	83 c4 10             	add    $0x10,%esp
f0102e1f:	85 c0                	test   %eax,%eax
f0102e21:	0f 84 1b 02 00 00    	je     f0103042 <mem_init+0x1c9d>
	assert((pp2 = page_alloc(0)));
f0102e27:	83 ec 0c             	sub    $0xc,%esp
f0102e2a:	6a 00                	push   $0x0
f0102e2c:	e8 c5 e1 ff ff       	call   f0100ff6 <page_alloc>
f0102e31:	89 c7                	mov    %eax,%edi
f0102e33:	83 c4 10             	add    $0x10,%esp
f0102e36:	85 c0                	test   %eax,%eax
f0102e38:	0f 84 26 02 00 00    	je     f0103064 <mem_init+0x1cbf>
	page_free(pp0);
f0102e3e:	83 ec 0c             	sub    $0xc,%esp
f0102e41:	56                   	push   %esi
f0102e42:	e8 34 e2 ff ff       	call   f010107b <page_free>
	return (pp - pages) << PGSHIFT;
f0102e47:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102e4a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102e4d:	2b 81 2c 1a 00 00    	sub    0x1a2c(%ecx),%eax
f0102e53:	c1 f8 03             	sar    $0x3,%eax
f0102e56:	89 c2                	mov    %eax,%edx
f0102e58:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102e5b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102e60:	83 c4 10             	add    $0x10,%esp
f0102e63:	3b 81 34 1a 00 00    	cmp    0x1a34(%ecx),%eax
f0102e69:	0f 83 17 02 00 00    	jae    f0103086 <mem_init+0x1ce1>
	memset(page2kva(pp1), 1, PGSIZE);
f0102e6f:	83 ec 04             	sub    $0x4,%esp
f0102e72:	68 00 10 00 00       	push   $0x1000
f0102e77:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102e79:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102e7f:	52                   	push   %edx
f0102e80:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e83:	e8 42 21 00 00       	call   f0104fca <memset>
	return (pp - pages) << PGSHIFT;
f0102e88:	89 f8                	mov    %edi,%eax
f0102e8a:	2b 83 2c 1a 00 00    	sub    0x1a2c(%ebx),%eax
f0102e90:	c1 f8 03             	sar    $0x3,%eax
f0102e93:	89 c2                	mov    %eax,%edx
f0102e95:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102e98:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102e9d:	83 c4 10             	add    $0x10,%esp
f0102ea0:	3b 83 34 1a 00 00    	cmp    0x1a34(%ebx),%eax
f0102ea6:	0f 83 f2 01 00 00    	jae    f010309e <mem_init+0x1cf9>
	memset(page2kva(pp2), 2, PGSIZE);
f0102eac:	83 ec 04             	sub    $0x4,%esp
f0102eaf:	68 00 10 00 00       	push   $0x1000
f0102eb4:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102eb6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102ebc:	52                   	push   %edx
f0102ebd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ec0:	e8 05 21 00 00       	call   f0104fca <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ec5:	6a 02                	push   $0x2
f0102ec7:	68 00 10 00 00       	push   $0x1000
f0102ecc:	ff 75 d0             	push   -0x30(%ebp)
f0102ecf:	ff b3 30 1a 00 00    	push   0x1a30(%ebx)
f0102ed5:	e8 59 e4 ff ff       	call   f0101333 <page_insert>
	assert(pp1->pp_ref == 1);
f0102eda:	83 c4 20             	add    $0x20,%esp
f0102edd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102ee0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102ee5:	0f 85 cc 01 00 00    	jne    f01030b7 <mem_init+0x1d12>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102eeb:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ef2:	01 01 01 
f0102ef5:	0f 85 de 01 00 00    	jne    f01030d9 <mem_init+0x1d34>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102efb:	6a 02                	push   $0x2
f0102efd:	68 00 10 00 00       	push   $0x1000
f0102f02:	57                   	push   %edi
f0102f03:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f06:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0102f0c:	e8 22 e4 ff ff       	call   f0101333 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f11:	83 c4 10             	add    $0x10,%esp
f0102f14:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102f1b:	02 02 02 
f0102f1e:	0f 85 d7 01 00 00    	jne    f01030fb <mem_init+0x1d56>
	assert(pp2->pp_ref == 1);
f0102f24:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102f29:	0f 85 ee 01 00 00    	jne    f010311d <mem_init+0x1d78>
	assert(pp1->pp_ref == 0);
f0102f2f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102f32:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102f37:	0f 85 02 02 00 00    	jne    f010313f <mem_init+0x1d9a>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102f3d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102f44:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102f47:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102f4a:	89 f8                	mov    %edi,%eax
f0102f4c:	2b 81 2c 1a 00 00    	sub    0x1a2c(%ecx),%eax
f0102f52:	c1 f8 03             	sar    $0x3,%eax
f0102f55:	89 c2                	mov    %eax,%edx
f0102f57:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102f5a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102f5f:	3b 81 34 1a 00 00    	cmp    0x1a34(%ecx),%eax
f0102f65:	0f 83 f6 01 00 00    	jae    f0103161 <mem_init+0x1dbc>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f6b:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102f72:	03 03 03 
f0102f75:	0f 85 fe 01 00 00    	jne    f0103179 <mem_init+0x1dd4>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102f7b:	83 ec 08             	sub    $0x8,%esp
f0102f7e:	68 00 10 00 00       	push   $0x1000
f0102f83:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f86:	ff b0 30 1a 00 00    	push   0x1a30(%eax)
f0102f8c:	e8 67 e3 ff ff       	call   f01012f8 <page_remove>
	assert(pp2->pp_ref == 0);
f0102f91:	83 c4 10             	add    $0x10,%esp
f0102f94:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102f99:	0f 85 fc 01 00 00    	jne    f010319b <mem_init+0x1df6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fa2:	8b 88 30 1a 00 00    	mov    0x1a30(%eax),%ecx
f0102fa8:	8b 11                	mov    (%ecx),%edx
f0102faa:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102fb0:	89 f7                	mov    %esi,%edi
f0102fb2:	2b b8 2c 1a 00 00    	sub    0x1a2c(%eax),%edi
f0102fb8:	89 f8                	mov    %edi,%eax
f0102fba:	c1 f8 03             	sar    $0x3,%eax
f0102fbd:	c1 e0 0c             	shl    $0xc,%eax
f0102fc0:	39 c2                	cmp    %eax,%edx
f0102fc2:	0f 85 f5 01 00 00    	jne    f01031bd <mem_init+0x1e18>
	kern_pgdir[0] = 0;
f0102fc8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102fce:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102fd3:	0f 85 06 02 00 00    	jne    f01031df <mem_init+0x1e3a>
	pp0->pp_ref = 0;
f0102fd9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102fdf:	83 ec 0c             	sub    $0xc,%esp
f0102fe2:	56                   	push   %esi
f0102fe3:	e8 93 e0 ff ff       	call   f010107b <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102fe8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102feb:	8d 83 8c 67 f8 ff    	lea    -0x79874(%ebx),%eax
f0102ff1:	89 04 24             	mov    %eax,(%esp)
f0102ff4:	e8 28 0b 00 00       	call   f0103b21 <cprintf>
}
f0102ff9:	83 c4 10             	add    $0x10,%esp
f0102ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fff:	5b                   	pop    %ebx
f0103000:	5e                   	pop    %esi
f0103001:	5f                   	pop    %edi
f0103002:	5d                   	pop    %ebp
f0103003:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103004:	50                   	push   %eax
f0103005:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103008:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f010300e:	50                   	push   %eax
f010300f:	68 f2 00 00 00       	push   $0xf2
f0103014:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010301a:	50                   	push   %eax
f010301b:	e8 9f d0 ff ff       	call   f01000bf <_panic>
	assert((pp0 = page_alloc(0)));
f0103020:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103023:	8d 83 22 69 f8 ff    	lea    -0x796de(%ebx),%eax
f0103029:	50                   	push   %eax
f010302a:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0103030:	50                   	push   %eax
f0103031:	68 37 04 00 00       	push   $0x437
f0103036:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010303c:	50                   	push   %eax
f010303d:	e8 7d d0 ff ff       	call   f01000bf <_panic>
	assert((pp1 = page_alloc(0)));
f0103042:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103045:	8d 83 38 69 f8 ff    	lea    -0x796c8(%ebx),%eax
f010304b:	50                   	push   %eax
f010304c:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0103052:	50                   	push   %eax
f0103053:	68 38 04 00 00       	push   $0x438
f0103058:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010305e:	50                   	push   %eax
f010305f:	e8 5b d0 ff ff       	call   f01000bf <_panic>
	assert((pp2 = page_alloc(0)));
f0103064:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103067:	8d 83 4e 69 f8 ff    	lea    -0x796b2(%ebx),%eax
f010306d:	50                   	push   %eax
f010306e:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0103074:	50                   	push   %eax
f0103075:	68 39 04 00 00       	push   $0x439
f010307a:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0103080:	50                   	push   %eax
f0103081:	e8 39 d0 ff ff       	call   f01000bf <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103086:	52                   	push   %edx
f0103087:	89 cb                	mov    %ecx,%ebx
f0103089:	8d 81 30 60 f8 ff    	lea    -0x79fd0(%ecx),%eax
f010308f:	50                   	push   %eax
f0103090:	6a 56                	push   $0x56
f0103092:	8d 81 14 68 f8 ff    	lea    -0x797ec(%ecx),%eax
f0103098:	50                   	push   %eax
f0103099:	e8 21 d0 ff ff       	call   f01000bf <_panic>
f010309e:	52                   	push   %edx
f010309f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030a2:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f01030a8:	50                   	push   %eax
f01030a9:	6a 56                	push   $0x56
f01030ab:	8d 83 14 68 f8 ff    	lea    -0x797ec(%ebx),%eax
f01030b1:	50                   	push   %eax
f01030b2:	e8 08 d0 ff ff       	call   f01000bf <_panic>
	assert(pp1->pp_ref == 1);
f01030b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ba:	8d 83 1f 6a f8 ff    	lea    -0x795e1(%ebx),%eax
f01030c0:	50                   	push   %eax
f01030c1:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01030c7:	50                   	push   %eax
f01030c8:	68 3e 04 00 00       	push   $0x43e
f01030cd:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01030d3:	50                   	push   %eax
f01030d4:	e8 e6 cf ff ff       	call   f01000bf <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01030d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030dc:	8d 83 18 67 f8 ff    	lea    -0x798e8(%ebx),%eax
f01030e2:	50                   	push   %eax
f01030e3:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01030e9:	50                   	push   %eax
f01030ea:	68 3f 04 00 00       	push   $0x43f
f01030ef:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01030f5:	50                   	push   %eax
f01030f6:	e8 c4 cf ff ff       	call   f01000bf <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01030fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030fe:	8d 83 3c 67 f8 ff    	lea    -0x798c4(%ebx),%eax
f0103104:	50                   	push   %eax
f0103105:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010310b:	50                   	push   %eax
f010310c:	68 41 04 00 00       	push   $0x441
f0103111:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0103117:	50                   	push   %eax
f0103118:	e8 a2 cf ff ff       	call   f01000bf <_panic>
	assert(pp2->pp_ref == 1);
f010311d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103120:	8d 83 41 6a f8 ff    	lea    -0x795bf(%ebx),%eax
f0103126:	50                   	push   %eax
f0103127:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010312d:	50                   	push   %eax
f010312e:	68 42 04 00 00       	push   $0x442
f0103133:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0103139:	50                   	push   %eax
f010313a:	e8 80 cf ff ff       	call   f01000bf <_panic>
	assert(pp1->pp_ref == 0);
f010313f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103142:	8d 83 ab 6a f8 ff    	lea    -0x79555(%ebx),%eax
f0103148:	50                   	push   %eax
f0103149:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010314f:	50                   	push   %eax
f0103150:	68 43 04 00 00       	push   $0x443
f0103155:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f010315b:	50                   	push   %eax
f010315c:	e8 5e cf ff ff       	call   f01000bf <_panic>
f0103161:	52                   	push   %edx
f0103162:	89 cb                	mov    %ecx,%ebx
f0103164:	8d 81 30 60 f8 ff    	lea    -0x79fd0(%ecx),%eax
f010316a:	50                   	push   %eax
f010316b:	6a 56                	push   $0x56
f010316d:	8d 81 14 68 f8 ff    	lea    -0x797ec(%ecx),%eax
f0103173:	50                   	push   %eax
f0103174:	e8 46 cf ff ff       	call   f01000bf <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103179:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010317c:	8d 83 60 67 f8 ff    	lea    -0x798a0(%ebx),%eax
f0103182:	50                   	push   %eax
f0103183:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0103189:	50                   	push   %eax
f010318a:	68 45 04 00 00       	push   $0x445
f010318f:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f0103195:	50                   	push   %eax
f0103196:	e8 24 cf ff ff       	call   f01000bf <_panic>
	assert(pp2->pp_ref == 0);
f010319b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010319e:	8d 83 79 6a f8 ff    	lea    -0x79587(%ebx),%eax
f01031a4:	50                   	push   %eax
f01031a5:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01031ab:	50                   	push   %eax
f01031ac:	68 47 04 00 00       	push   $0x447
f01031b1:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01031b7:	50                   	push   %eax
f01031b8:	e8 02 cf ff ff       	call   f01000bf <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031c0:	8d 83 70 62 f8 ff    	lea    -0x79d90(%ebx),%eax
f01031c6:	50                   	push   %eax
f01031c7:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01031cd:	50                   	push   %eax
f01031ce:	68 4a 04 00 00       	push   $0x44a
f01031d3:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01031d9:	50                   	push   %eax
f01031da:	e8 e0 ce ff ff       	call   f01000bf <_panic>
	assert(pp0->pp_ref == 1);
f01031df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031e2:	8d 83 30 6a f8 ff    	lea    -0x795d0(%ebx),%eax
f01031e8:	50                   	push   %eax
f01031e9:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01031ef:	50                   	push   %eax
f01031f0:	68 4c 04 00 00       	push   $0x44c
f01031f5:	8d 83 ed 67 f8 ff    	lea    -0x79813(%ebx),%eax
f01031fb:	50                   	push   %eax
f01031fc:	e8 be ce ff ff       	call   f01000bf <_panic>

f0103201 <tlb_invalidate>:
{
f0103201:	55                   	push   %ebp
f0103202:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0103204:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103207:	0f 01 38             	invlpg (%eax)
}
f010320a:	5d                   	pop    %ebp
f010320b:	c3                   	ret    

f010320c <user_mem_check>:
{
f010320c:	55                   	push   %ebp
f010320d:	89 e5                	mov    %esp,%ebp
f010320f:	57                   	push   %edi
f0103210:	56                   	push   %esi
f0103211:	53                   	push   %ebx
f0103212:	83 ec 2c             	sub    $0x2c,%esp
f0103215:	e8 ed d4 ff ff       	call   f0100707 <__x86.get_pc_thunk.ax>
f010321a:	05 12 c7 07 00       	add    $0x7c712,%eax
f010321f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	sa = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f0103222:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103225:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	ea = (uintptr_t)ROUNDUP((uintptr_t)va + len, PGSIZE);
f010322b:	8b 45 10             	mov    0x10(%ebp),%eax
f010322e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103231:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0103238:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010323d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	perm |= PTE_P;
f0103240:	8b 75 14             	mov    0x14(%ebp),%esi
f0103243:	83 ce 01             	or     $0x1,%esi
		pp = page_lookup(env->env_pgdir, (void *)sa, &pte);
f0103246:	8d 7d e4             	lea    -0x1c(%ebp),%edi
	for (; sa < ea; sa += PGSIZE) \
f0103249:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010324c:	73 60                	jae    f01032ae <user_mem_check+0xa2>
		pp = page_lookup(env->env_pgdir, (void *)sa, &pte);
f010324e:	83 ec 04             	sub    $0x4,%esp
f0103251:	57                   	push   %edi
f0103252:	53                   	push   %ebx
f0103253:	8b 45 08             	mov    0x8(%ebp),%eax
f0103256:	ff 70 5c             	push   0x5c(%eax)
f0103259:	e8 27 e0 ff ff       	call   f0101285 <page_lookup>
		if (sa < ULIM && pp && (*pte & perm) == perm) 
f010325e:	83 c4 10             	add    $0x10,%esp
f0103261:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103267:	77 0f                	ja     f0103278 <user_mem_check+0x6c>
f0103269:	85 c0                	test   %eax,%eax
f010326b:	74 0b                	je     f0103278 <user_mem_check+0x6c>
f010326d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103270:	89 f2                	mov    %esi,%edx
f0103272:	23 10                	and    (%eax),%edx
f0103274:	39 d6                	cmp    %edx,%esi
f0103276:	74 1e                	je     f0103296 <user_mem_check+0x8a>
		if (sa <= (uintptr_t)va) 
f0103278:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010327b:	77 21                	ja     f010329e <user_mem_check+0x92>
			user_mem_check_addr = (uintptr_t)va;
f010327d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103283:	89 88 3c 1a 00 00    	mov    %ecx,0x1a3c(%eax)
		return -E_FAULT;
f0103289:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f010328e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103291:	5b                   	pop    %ebx
f0103292:	5e                   	pop    %esi
f0103293:	5f                   	pop    %edi
f0103294:	5d                   	pop    %ebp
f0103295:	c3                   	ret    
	for (; sa < ea; sa += PGSIZE) \
f0103296:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010329c:	eb ab                	jmp    f0103249 <user_mem_check+0x3d>
			user_mem_check_addr = sa;
f010329e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01032a1:	89 98 3c 1a 00 00    	mov    %ebx,0x1a3c(%eax)
		return -E_FAULT;
f01032a7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01032ac:	eb e0                	jmp    f010328e <user_mem_check+0x82>
	return 0;
f01032ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01032b3:	eb d9                	jmp    f010328e <user_mem_check+0x82>

f01032b5 <user_mem_assert>:
{
f01032b5:	55                   	push   %ebp
f01032b6:	89 e5                	mov    %esp,%ebp
f01032b8:	56                   	push   %esi
f01032b9:	53                   	push   %ebx
f01032ba:	e8 b6 ce ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f01032bf:	81 c3 6d c6 07 00    	add    $0x7c66d,%ebx
f01032c5:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U | PTE_P) < 0) {
f01032c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01032cb:	83 c8 05             	or     $0x5,%eax
f01032ce:	50                   	push   %eax
f01032cf:	ff 75 10             	push   0x10(%ebp)
f01032d2:	ff 75 0c             	push   0xc(%ebp)
f01032d5:	56                   	push   %esi
f01032d6:	e8 31 ff ff ff       	call   f010320c <user_mem_check>
f01032db:	83 c4 10             	add    $0x10,%esp
f01032de:	85 c0                	test   %eax,%eax
f01032e0:	78 07                	js     f01032e9 <user_mem_assert+0x34>
}
f01032e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01032e5:	5b                   	pop    %ebx
f01032e6:	5e                   	pop    %esi
f01032e7:	5d                   	pop    %ebp
f01032e8:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01032e9:	83 ec 04             	sub    $0x4,%esp
f01032ec:	ff b3 3c 1a 00 00    	push   0x1a3c(%ebx)
f01032f2:	ff 76 48             	push   0x48(%esi)
f01032f5:	8d 83 b8 67 f8 ff    	lea    -0x79848(%ebx),%eax
f01032fb:	50                   	push   %eax
f01032fc:	e8 20 08 00 00       	call   f0103b21 <cprintf>
		env_destroy(env);	// may not return
f0103301:	89 34 24             	mov    %esi,(%esp)
f0103304:	e8 a7 06 00 00       	call   f01039b0 <env_destroy>
f0103309:	83 c4 10             	add    $0x10,%esp
}
f010330c:	eb d4                	jmp    f01032e2 <user_mem_assert+0x2d>

f010330e <__x86.get_pc_thunk.dx>:
f010330e:	8b 14 24             	mov    (%esp),%edx
f0103311:	c3                   	ret    

f0103312 <__x86.get_pc_thunk.cx>:
f0103312:	8b 0c 24             	mov    (%esp),%ecx
f0103315:	c3                   	ret    

f0103316 <__x86.get_pc_thunk.di>:
f0103316:	8b 3c 24             	mov    (%esp),%edi
f0103319:	c3                   	ret    

f010331a <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010331a:	55                   	push   %ebp
f010331b:	89 e5                	mov    %esp,%ebp
f010331d:	57                   	push   %edi
f010331e:	56                   	push   %esi
f010331f:	53                   	push   %ebx
f0103320:	83 ec 1c             	sub    $0x1c,%esp
f0103323:	e8 4d ce ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103328:	81 c3 04 c6 07 00    	add    $0x7c604,%ebx
	//   (Watch out for corner-cases!)
	uintptr_t sa, ea;
	int result;
	struct PageInfo* p;

	if (len > 0) {
f010332e:	85 c9                	test   %ecx,%ecx
f0103330:	74 7f                	je     f01033b1 <region_alloc+0x97>
f0103332:	89 c7                	mov    %eax,%edi
		sa = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f0103334:	89 d6                	mov    %edx,%esi
f0103336:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		ea = (uintptr_t)ROUNDUP((uintptr_t)va + len, PGSIZE);
f010333c:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103343:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103348:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		for (; sa < ea; sa += PGSIZE) {
f010334b:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010334e:	73 61                	jae    f01033b1 <region_alloc+0x97>
			if (!(p = page_alloc(ALLOC_ZERO))) {
f0103350:	83 ec 0c             	sub    $0xc,%esp
f0103353:	6a 01                	push   $0x1
f0103355:	e8 9c dc ff ff       	call   f0100ff6 <page_alloc>
f010335a:	83 c4 10             	add    $0x10,%esp
f010335d:	85 c0                	test   %eax,%eax
f010335f:	74 1b                	je     f010337c <region_alloc+0x62>
				result = -E_NO_MEM;
				panic("page_alloc: %e", result);
			}
			result = page_insert(e->env_pgdir, p, (void *)sa, PTE_P | PTE_U | PTE_W);
f0103361:	6a 07                	push   $0x7
f0103363:	56                   	push   %esi
f0103364:	50                   	push   %eax
f0103365:	ff 77 5c             	push   0x5c(%edi)
f0103368:	e8 c6 df ff ff       	call   f0101333 <page_insert>
			if (result != 0) {
f010336d:	83 c4 10             	add    $0x10,%esp
f0103370:	85 c0                	test   %eax,%eax
f0103372:	75 22                	jne    f0103396 <region_alloc+0x7c>
		for (; sa < ea; sa += PGSIZE) {
f0103374:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010337a:	eb cf                	jmp    f010334b <region_alloc+0x31>
				panic("page_alloc: %e", result);
f010337c:	6a fc                	push   $0xfffffffc
f010337e:	8d 83 34 6b f8 ff    	lea    -0x794cc(%ebx),%eax
f0103384:	50                   	push   %eax
f0103385:	68 28 01 00 00       	push   $0x128
f010338a:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f0103390:	50                   	push   %eax
f0103391:	e8 29 cd ff ff       	call   f01000bf <_panic>
				panic("page_insert : no memory");
f0103396:	83 ec 04             	sub    $0x4,%esp
f0103399:	8d 83 4e 6b f8 ff    	lea    -0x794b2(%ebx),%eax
f010339f:	50                   	push   %eax
f01033a0:	68 2c 01 00 00       	push   $0x12c
f01033a5:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f01033ab:	50                   	push   %eax
f01033ac:	e8 0e cd ff ff       	call   f01000bf <_panic>
			}
		}
	}
}
f01033b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033b4:	5b                   	pop    %ebx
f01033b5:	5e                   	pop    %esi
f01033b6:	5f                   	pop    %edi
f01033b7:	5d                   	pop    %ebp
f01033b8:	c3                   	ret    

f01033b9 <envid2env>:
{
f01033b9:	55                   	push   %ebp
f01033ba:	89 e5                	mov    %esp,%ebp
f01033bc:	53                   	push   %ebx
f01033bd:	e8 50 ff ff ff       	call   f0103312 <__x86.get_pc_thunk.cx>
f01033c2:	81 c1 6a c5 07 00    	add    $0x7c56a,%ecx
f01033c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01033cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f01033ce:	85 c0                	test   %eax,%eax
f01033d0:	74 4c                	je     f010341e <envid2env+0x65>
	e = &envs[ENVX(envid)];
f01033d2:	89 c2                	mov    %eax,%edx
f01033d4:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01033da:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01033dd:	c1 e2 05             	shl    $0x5,%edx
f01033e0:	03 91 4c 1a 00 00    	add    0x1a4c(%ecx),%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01033e6:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01033ea:	74 42                	je     f010342e <envid2env+0x75>
f01033ec:	39 42 48             	cmp    %eax,0x48(%edx)
f01033ef:	75 49                	jne    f010343a <envid2env+0x81>
	return 0;
f01033f1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01033f6:	84 db                	test   %bl,%bl
f01033f8:	74 2a                	je     f0103424 <envid2env+0x6b>
f01033fa:	8b 89 48 1a 00 00    	mov    0x1a48(%ecx),%ecx
f0103400:	39 d1                	cmp    %edx,%ecx
f0103402:	74 20                	je     f0103424 <envid2env+0x6b>
f0103404:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103407:	3b 41 48             	cmp    0x48(%ecx),%eax
f010340a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010340f:	0f 45 d3             	cmovne %ebx,%edx
f0103412:	0f 94 c0             	sete   %al
f0103415:	0f b6 c0             	movzbl %al,%eax
f0103418:	8d 44 00 fe          	lea    -0x2(%eax,%eax,1),%eax
f010341c:	eb 06                	jmp    f0103424 <envid2env+0x6b>
		*env_store = curenv;
f010341e:	8b 91 48 1a 00 00    	mov    0x1a48(%ecx),%edx
f0103424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103427:	89 11                	mov    %edx,(%ecx)
}
f0103429:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010342c:	c9                   	leave  
f010342d:	c3                   	ret    
f010342e:	ba 00 00 00 00       	mov    $0x0,%edx
		return -E_BAD_ENV;
f0103433:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103438:	eb ea                	jmp    f0103424 <envid2env+0x6b>
f010343a:	ba 00 00 00 00       	mov    $0x0,%edx
f010343f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103444:	eb de                	jmp    f0103424 <envid2env+0x6b>

f0103446 <env_init_percpu>:
{
f0103446:	e8 bc d2 ff ff       	call   f0100707 <__x86.get_pc_thunk.ax>
f010344b:	05 e1 c4 07 00       	add    $0x7c4e1,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103450:	8d 80 d4 16 00 00    	lea    0x16d4(%eax),%eax
f0103456:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103459:	b8 23 00 00 00       	mov    $0x23,%eax
f010345e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103460:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103462:	b8 10 00 00 00       	mov    $0x10,%eax
f0103467:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103469:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010346b:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010346d:	ea 74 34 10 f0 08 00 	ljmp   $0x8,$0xf0103474
	asm volatile("lldt %0" : : "r" (sel));
f0103474:	b8 00 00 00 00       	mov    $0x0,%eax
f0103479:	0f 00 d0             	lldt   %ax
}
f010347c:	c3                   	ret    

f010347d <env_init>:
{
f010347d:	55                   	push   %ebp
f010347e:	89 e5                	mov    %esp,%ebp
f0103480:	56                   	push   %esi
f0103481:	53                   	push   %ebx
f0103482:	e8 84 d2 ff ff       	call   f010070b <__x86.get_pc_thunk.si>
f0103487:	81 c6 a5 c4 07 00    	add    $0x7c4a5,%esi
		e = &envs[i];
f010348d:	8b 9e 4c 1a 00 00    	mov    0x1a4c(%esi),%ebx
f0103493:	8b 96 50 1a 00 00    	mov    0x1a50(%esi),%edx
f0103499:	8d 83 a0 7f 01 00    	lea    0x17fa0(%ebx),%eax
f010349f:	89 d1                	mov    %edx,%ecx
f01034a1:	89 c2                	mov    %eax,%edx
		e->env_id = 0;
f01034a3:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		e->env_status = ENV_FREE;
f01034aa:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		e->env_link = env_free_list;
f01034b1:	89 48 44             	mov    %ecx,0x44(%eax)
	for(i = NENV - 1 ; i >= 0; i--) {
f01034b4:	83 e8 60             	sub    $0x60,%eax
f01034b7:	39 da                	cmp    %ebx,%edx
f01034b9:	75 e4                	jne    f010349f <env_init+0x22>
f01034bb:	89 9e 50 1a 00 00    	mov    %ebx,0x1a50(%esi)
	env_init_percpu();
f01034c1:	e8 80 ff ff ff       	call   f0103446 <env_init_percpu>
}
f01034c6:	5b                   	pop    %ebx
f01034c7:	5e                   	pop    %esi
f01034c8:	5d                   	pop    %ebp
f01034c9:	c3                   	ret    

f01034ca <env_alloc>:
{
f01034ca:	55                   	push   %ebp
f01034cb:	89 e5                	mov    %esp,%ebp
f01034cd:	57                   	push   %edi
f01034ce:	56                   	push   %esi
f01034cf:	53                   	push   %ebx
f01034d0:	83 ec 0c             	sub    $0xc,%esp
f01034d3:	e8 9d cc ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f01034d8:	81 c3 54 c4 07 00    	add    $0x7c454,%ebx
	if (!(e = env_free_list))
f01034de:	8b b3 50 1a 00 00    	mov    0x1a50(%ebx),%esi
f01034e4:	85 f6                	test   %esi,%esi
f01034e6:	0f 84 84 01 00 00    	je     f0103670 <env_alloc+0x1a6>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01034ec:	83 ec 0c             	sub    $0xc,%esp
f01034ef:	6a 01                	push   $0x1
f01034f1:	e8 00 db ff ff       	call   f0100ff6 <page_alloc>
f01034f6:	89 c7                	mov    %eax,%edi
f01034f8:	83 c4 10             	add    $0x10,%esp
f01034fb:	85 c0                	test   %eax,%eax
f01034fd:	0f 84 74 01 00 00    	je     f0103677 <env_alloc+0x1ad>
	return (pp - pages) << PGSHIFT;
f0103503:	c7 c0 58 13 18 f0    	mov    $0xf0181358,%eax
f0103509:	89 f9                	mov    %edi,%ecx
f010350b:	2b 08                	sub    (%eax),%ecx
f010350d:	89 c8                	mov    %ecx,%eax
f010350f:	c1 f8 03             	sar    $0x3,%eax
f0103512:	89 c2                	mov    %eax,%edx
f0103514:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103517:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010351c:	c7 c1 60 13 18 f0    	mov    $0xf0181360,%ecx
f0103522:	3b 01                	cmp    (%ecx),%eax
f0103524:	0f 83 17 01 00 00    	jae    f0103641 <env_alloc+0x177>
	return (void *)(pa + KERNBASE);
f010352a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = page2kva(p);
f0103530:	89 46 5c             	mov    %eax,0x5c(%esi)
	memset(e->env_pgdir, 0, PGSIZE);
f0103533:	83 ec 04             	sub    $0x4,%esp
f0103536:	68 00 10 00 00       	push   $0x1000
f010353b:	6a 00                	push   $0x0
f010353d:	50                   	push   %eax
f010353e:	e8 87 1a 00 00       	call   f0104fca <memset>
	p->pp_ref++;
f0103543:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
f0103548:	83 c4 10             	add    $0x10,%esp
f010354b:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[i] = kern_pgdir[i];
f0103550:	c7 c7 5c 13 18 f0    	mov    $0xf018135c,%edi
f0103556:	8b 17                	mov    (%edi),%edx
f0103558:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010355b:	8b 56 5c             	mov    0x5c(%esi),%edx
f010355e:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
f0103561:	83 c0 04             	add    $0x4,%eax
f0103564:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103569:	75 eb                	jne    f0103556 <env_alloc+0x8c>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010356b:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f010356e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103573:	0f 86 de 00 00 00    	jbe    f0103657 <env_alloc+0x18d>
	return (physaddr_t)kva - KERNBASE;
f0103579:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010357f:	83 ca 05             	or     $0x5,%edx
f0103582:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103588:	8b 46 48             	mov    0x48(%esi),%eax
f010358b:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f0103590:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103595:	ba 00 10 00 00       	mov    $0x1000,%edx
f010359a:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010359d:	89 f2                	mov    %esi,%edx
f010359f:	2b 93 4c 1a 00 00    	sub    0x1a4c(%ebx),%edx
f01035a5:	c1 fa 05             	sar    $0x5,%edx
f01035a8:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01035ae:	09 d0                	or     %edx,%eax
f01035b0:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f01035b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035b6:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f01035b9:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f01035c0:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f01035c7:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01035ce:	83 ec 04             	sub    $0x4,%esp
f01035d1:	6a 44                	push   $0x44
f01035d3:	6a 00                	push   $0x0
f01035d5:	56                   	push   %esi
f01035d6:	e8 ef 19 00 00       	call   f0104fca <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01035db:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01035e1:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01035e7:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01035ed:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01035f4:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f01035fa:	8b 46 44             	mov    0x44(%esi),%eax
f01035fd:	89 83 50 1a 00 00    	mov    %eax,0x1a50(%ebx)
	*newenv_store = e;
f0103603:	8b 45 08             	mov    0x8(%ebp),%eax
f0103606:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103608:	8b 4e 48             	mov    0x48(%esi),%ecx
f010360b:	8b 83 48 1a 00 00    	mov    0x1a48(%ebx),%eax
f0103611:	83 c4 10             	add    $0x10,%esp
f0103614:	ba 00 00 00 00       	mov    $0x0,%edx
f0103619:	85 c0                	test   %eax,%eax
f010361b:	74 03                	je     f0103620 <env_alloc+0x156>
f010361d:	8b 50 48             	mov    0x48(%eax),%edx
f0103620:	83 ec 04             	sub    $0x4,%esp
f0103623:	51                   	push   %ecx
f0103624:	52                   	push   %edx
f0103625:	8d 83 66 6b f8 ff    	lea    -0x7949a(%ebx),%eax
f010362b:	50                   	push   %eax
f010362c:	e8 f0 04 00 00       	call   f0103b21 <cprintf>
	return 0;
f0103631:	83 c4 10             	add    $0x10,%esp
f0103634:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103639:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010363c:	5b                   	pop    %ebx
f010363d:	5e                   	pop    %esi
f010363e:	5f                   	pop    %edi
f010363f:	5d                   	pop    %ebp
f0103640:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103641:	52                   	push   %edx
f0103642:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f0103648:	50                   	push   %eax
f0103649:	6a 56                	push   $0x56
f010364b:	8d 83 14 68 f8 ff    	lea    -0x797ec(%ebx),%eax
f0103651:	50                   	push   %eax
f0103652:	e8 68 ca ff ff       	call   f01000bf <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103657:	50                   	push   %eax
f0103658:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f010365e:	50                   	push   %eax
f010365f:	68 c8 00 00 00       	push   $0xc8
f0103664:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f010366a:	50                   	push   %eax
f010366b:	e8 4f ca ff ff       	call   f01000bf <_panic>
		return -E_NO_FREE_ENV;
f0103670:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103675:	eb c2                	jmp    f0103639 <env_alloc+0x16f>
		return -E_NO_MEM;
f0103677:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010367c:	eb bb                	jmp    f0103639 <env_alloc+0x16f>

f010367e <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010367e:	55                   	push   %ebp
f010367f:	89 e5                	mov    %esp,%ebp
f0103681:	57                   	push   %edi
f0103682:	56                   	push   %esi
f0103683:	53                   	push   %ebx
f0103684:	83 ec 34             	sub    $0x34,%esp
f0103687:	e8 e9 ca ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f010368c:	81 c3 a0 c2 07 00    	add    $0x7c2a0,%ebx
	// LAB 3: Your code here.
	struct Env *newenv;
	int r;
	if ((r = env_alloc(&newenv, 0)) < 0)
f0103692:	6a 00                	push   $0x0
f0103694:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103697:	50                   	push   %eax
f0103698:	e8 2d fe ff ff       	call   f01034ca <env_alloc>
f010369d:	83 c4 10             	add    $0x10,%esp
f01036a0:	85 c0                	test   %eax,%eax
f01036a2:	78 2b                	js     f01036cf <env_create+0x51>
		panic("env_alloc: %e", r);

	load_icode(newenv, binary);
f01036a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01036a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f01036aa:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01036ad:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036b2:	76 34                	jbe    f01036e8 <env_create+0x6a>
	return (physaddr_t)kva - KERNBASE;
f01036b4:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01036b9:	0f 22 d8             	mov    %eax,%cr3
	ph = (struct Proghdr *) (binary + elfhdr ->e_phoff);
f01036bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01036bf:	89 c6                	mov    %eax,%esi
f01036c1:	03 70 1c             	add    0x1c(%eax),%esi
	eph = ph + elfhdr->e_phnum;
f01036c4:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01036c8:	c1 e7 05             	shl    $0x5,%edi
f01036cb:	01 f7                	add    %esi,%edi
	for (; ph < eph; ph++) {
f01036cd:	eb 6f                	jmp    f010373e <env_create+0xc0>
		panic("env_alloc: %e", r);
f01036cf:	50                   	push   %eax
f01036d0:	8d 83 7b 6b f8 ff    	lea    -0x79485(%ebx),%eax
f01036d6:	50                   	push   %eax
f01036d7:	68 94 01 00 00       	push   $0x194
f01036dc:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f01036e2:	50                   	push   %eax
f01036e3:	e8 d7 c9 ff ff       	call   f01000bf <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036e8:	50                   	push   %eax
f01036e9:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f01036ef:	50                   	push   %eax
f01036f0:	68 6b 01 00 00       	push   $0x16b
f01036f5:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f01036fb:	50                   	push   %eax
f01036fc:	e8 be c9 ff ff       	call   f01000bf <_panic>
			region_alloc(e, (void *)(ph->p_va), ph->p_memsz); // allocate page for process
f0103701:	8b 56 08             	mov    0x8(%esi),%edx
f0103704:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103707:	e8 0e fc ff ff       	call   f010331a <region_alloc>
			memcpy((void *)(ph->p_va), (void *)(binary + ph->p_offset), ph->p_filesz); // copy binary to p_va, with size filesz
f010370c:	83 ec 04             	sub    $0x4,%esp
f010370f:	ff 76 10             	push   0x10(%esi)
f0103712:	8b 45 08             	mov    0x8(%ebp),%eax
f0103715:	03 46 04             	add    0x4(%esi),%eax
f0103718:	50                   	push   %eax
f0103719:	ff 76 08             	push   0x8(%esi)
f010371c:	e8 51 19 00 00       	call   f0105072 <memcpy>
			memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz); // rest of if put to zero
f0103721:	8b 46 10             	mov    0x10(%esi),%eax
f0103724:	83 c4 0c             	add    $0xc,%esp
f0103727:	8b 56 14             	mov    0x14(%esi),%edx
f010372a:	29 c2                	sub    %eax,%edx
f010372c:	52                   	push   %edx
f010372d:	6a 00                	push   $0x0
f010372f:	03 46 08             	add    0x8(%esi),%eax
f0103732:	50                   	push   %eax
f0103733:	e8 92 18 00 00       	call   f0104fca <memset>
f0103738:	83 c4 10             	add    $0x10,%esp
	for (; ph < eph; ph++) {
f010373b:	83 c6 20             	add    $0x20,%esi
f010373e:	39 f7                	cmp    %esi,%edi
f0103740:	76 2c                	jbe    f010376e <env_create+0xf0>
		if (ph->p_type == ELF_PROG_LOAD) 
f0103742:	83 3e 01             	cmpl   $0x1,(%esi)
f0103745:	75 f4                	jne    f010373b <env_create+0xbd>
			assert(ph->p_filesz <= ph->p_memsz); // if f_size > m_size
f0103747:	8b 4e 14             	mov    0x14(%esi),%ecx
f010374a:	39 4e 10             	cmp    %ecx,0x10(%esi)
f010374d:	76 b2                	jbe    f0103701 <env_create+0x83>
f010374f:	8d 83 89 6b f8 ff    	lea    -0x79477(%ebx),%eax
f0103755:	50                   	push   %eax
f0103756:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010375c:	50                   	push   %eax
f010375d:	68 75 01 00 00       	push   $0x175
f0103762:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f0103768:	50                   	push   %eax
f0103769:	e8 51 c9 ff ff       	call   f01000bf <_panic>
	e->env_tf.tf_eip = elfhdr->e_entry;
f010376e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103771:	8b 40 18             	mov    0x18(%eax),%eax
f0103774:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103777:	89 43 30             	mov    %eax,0x30(%ebx)
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010377a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010377f:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103784:	89 d8                	mov    %ebx,%eax
f0103786:	e8 8f fb ff ff       	call   f010331a <region_alloc>

	newenv->env_type = type;
f010378b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010378e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103791:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103794:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103797:	5b                   	pop    %ebx
f0103798:	5e                   	pop    %esi
f0103799:	5f                   	pop    %edi
f010379a:	5d                   	pop    %ebp
f010379b:	c3                   	ret    

f010379c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010379c:	55                   	push   %ebp
f010379d:	89 e5                	mov    %esp,%ebp
f010379f:	57                   	push   %edi
f01037a0:	56                   	push   %esi
f01037a1:	53                   	push   %ebx
f01037a2:	83 ec 2c             	sub    $0x2c,%esp
f01037a5:	e8 cb c9 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f01037aa:	81 c3 82 c1 07 00    	add    $0x7c182,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01037b0:	8b 93 48 1a 00 00    	mov    0x1a48(%ebx),%edx
f01037b6:	3b 55 08             	cmp    0x8(%ebp),%edx
f01037b9:	74 47                	je     f0103802 <env_free+0x66>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01037be:	8b 48 48             	mov    0x48(%eax),%ecx
f01037c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01037c6:	85 d2                	test   %edx,%edx
f01037c8:	74 03                	je     f01037cd <env_free+0x31>
f01037ca:	8b 42 48             	mov    0x48(%edx),%eax
f01037cd:	83 ec 04             	sub    $0x4,%esp
f01037d0:	51                   	push   %ecx
f01037d1:	50                   	push   %eax
f01037d2:	8d 83 a5 6b f8 ff    	lea    -0x7945b(%ebx),%eax
f01037d8:	50                   	push   %eax
f01037d9:	e8 43 03 00 00       	call   f0103b21 <cprintf>
f01037de:	83 c4 10             	add    $0x10,%esp
f01037e1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f01037e8:	c7 c0 60 13 18 f0    	mov    $0xf0181360,%eax
f01037ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f01037f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return &pages[PGNUM(pa)];
f01037f4:	c7 c0 58 13 18 f0    	mov    $0xf0181358,%eax
f01037fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01037fd:	e9 bf 00 00 00       	jmp    f01038c1 <env_free+0x125>
		lcr3(PADDR(kern_pgdir));
f0103802:	c7 c0 5c 13 18 f0    	mov    $0xf018135c,%eax
f0103808:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010380a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010380f:	76 10                	jbe    f0103821 <env_free+0x85>
	return (physaddr_t)kva - KERNBASE;
f0103811:	05 00 00 00 10       	add    $0x10000000,%eax
f0103816:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103819:	8b 45 08             	mov    0x8(%ebp),%eax
f010381c:	8b 48 48             	mov    0x48(%eax),%ecx
f010381f:	eb a9                	jmp    f01037ca <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103821:	50                   	push   %eax
f0103822:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f0103828:	50                   	push   %eax
f0103829:	68 a9 01 00 00       	push   $0x1a9
f010382e:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f0103834:	50                   	push   %eax
f0103835:	e8 85 c8 ff ff       	call   f01000bf <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010383a:	57                   	push   %edi
f010383b:	8d 83 30 60 f8 ff    	lea    -0x79fd0(%ebx),%eax
f0103841:	50                   	push   %eax
f0103842:	68 b8 01 00 00       	push   $0x1b8
f0103847:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f010384d:	50                   	push   %eax
f010384e:	e8 6c c8 ff ff       	call   f01000bf <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103853:	83 c7 04             	add    $0x4,%edi
f0103856:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010385c:	81 fe 00 00 40 00    	cmp    $0x400000,%esi
f0103862:	74 1e                	je     f0103882 <env_free+0xe6>
			if (pt[pteno] & PTE_P)
f0103864:	f6 07 01             	testb  $0x1,(%edi)
f0103867:	74 ea                	je     f0103853 <env_free+0xb7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103869:	83 ec 08             	sub    $0x8,%esp
f010386c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010386f:	09 f0                	or     %esi,%eax
f0103871:	50                   	push   %eax
f0103872:	8b 45 08             	mov    0x8(%ebp),%eax
f0103875:	ff 70 5c             	push   0x5c(%eax)
f0103878:	e8 7b da ff ff       	call   f01012f8 <page_remove>
f010387d:	83 c4 10             	add    $0x10,%esp
f0103880:	eb d1                	jmp    f0103853 <env_free+0xb7>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103882:	8b 45 08             	mov    0x8(%ebp),%eax
f0103885:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103888:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010388b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103892:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103895:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103898:	3b 10                	cmp    (%eax),%edx
f010389a:	73 67                	jae    f0103903 <env_free+0x167>
		page_decref(pa2page(pa));
f010389c:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010389f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01038a2:	8b 00                	mov    (%eax),%eax
f01038a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038a7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01038aa:	50                   	push   %eax
f01038ab:	e8 60 d8 ff ff       	call   f0101110 <page_decref>
f01038b0:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038b3:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01038b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038ba:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01038bf:	74 5a                	je     f010391b <env_free+0x17f>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01038c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01038c4:	8b 40 5c             	mov    0x5c(%eax),%eax
f01038c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01038ca:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01038cd:	a8 01                	test   $0x1,%al
f01038cf:	74 e2                	je     f01038b3 <env_free+0x117>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01038d1:	89 c7                	mov    %eax,%edi
f01038d3:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f01038d9:	c1 e8 0c             	shr    $0xc,%eax
f01038dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01038df:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01038e2:	3b 02                	cmp    (%edx),%eax
f01038e4:	0f 83 50 ff ff ff    	jae    f010383a <env_free+0x9e>
	return (void *)(pa + KERNBASE);
f01038ea:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f01038f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038f3:	c1 e0 14             	shl    $0x14,%eax
f01038f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01038f9:	be 00 00 00 00       	mov    $0x0,%esi
f01038fe:	e9 61 ff ff ff       	jmp    f0103864 <env_free+0xc8>
		panic("pa2page called with invalid pa");
f0103903:	83 ec 04             	sub    $0x4,%esp
f0103906:	8d 83 3c 61 f8 ff    	lea    -0x79ec4(%ebx),%eax
f010390c:	50                   	push   %eax
f010390d:	6a 4f                	push   $0x4f
f010390f:	8d 83 14 68 f8 ff    	lea    -0x797ec(%ebx),%eax
f0103915:	50                   	push   %eax
f0103916:	e8 a4 c7 ff ff       	call   f01000bf <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010391b:	8b 45 08             	mov    0x8(%ebp),%eax
f010391e:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103921:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103926:	76 57                	jbe    f010397f <env_free+0x1e3>
	e->env_pgdir = 0;
f0103928:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010392b:	c7 41 5c 00 00 00 00 	movl   $0x0,0x5c(%ecx)
	return (physaddr_t)kva - KERNBASE;
f0103932:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103937:	c1 e8 0c             	shr    $0xc,%eax
f010393a:	c7 c2 60 13 18 f0    	mov    $0xf0181360,%edx
f0103940:	3b 02                	cmp    (%edx),%eax
f0103942:	73 54                	jae    f0103998 <env_free+0x1fc>
	page_decref(pa2page(pa));
f0103944:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103947:	c7 c2 58 13 18 f0    	mov    $0xf0181358,%edx
f010394d:	8b 12                	mov    (%edx),%edx
f010394f:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103952:	50                   	push   %eax
f0103953:	e8 b8 d7 ff ff       	call   f0101110 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103958:	8b 45 08             	mov    0x8(%ebp),%eax
f010395b:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103962:	8b 83 50 1a 00 00    	mov    0x1a50(%ebx),%eax
f0103968:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010396b:	89 41 44             	mov    %eax,0x44(%ecx)
	env_free_list = e;
f010396e:	89 8b 50 1a 00 00    	mov    %ecx,0x1a50(%ebx)
}
f0103974:	83 c4 10             	add    $0x10,%esp
f0103977:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010397a:	5b                   	pop    %ebx
f010397b:	5e                   	pop    %esi
f010397c:	5f                   	pop    %edi
f010397d:	5d                   	pop    %ebp
f010397e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010397f:	50                   	push   %eax
f0103980:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f0103986:	50                   	push   %eax
f0103987:	68 c6 01 00 00       	push   $0x1c6
f010398c:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f0103992:	50                   	push   %eax
f0103993:	e8 27 c7 ff ff       	call   f01000bf <_panic>
		panic("pa2page called with invalid pa");
f0103998:	83 ec 04             	sub    $0x4,%esp
f010399b:	8d 83 3c 61 f8 ff    	lea    -0x79ec4(%ebx),%eax
f01039a1:	50                   	push   %eax
f01039a2:	6a 4f                	push   $0x4f
f01039a4:	8d 83 14 68 f8 ff    	lea    -0x797ec(%ebx),%eax
f01039aa:	50                   	push   %eax
f01039ab:	e8 0f c7 ff ff       	call   f01000bf <_panic>

f01039b0 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01039b0:	55                   	push   %ebp
f01039b1:	89 e5                	mov    %esp,%ebp
f01039b3:	53                   	push   %ebx
f01039b4:	83 ec 10             	sub    $0x10,%esp
f01039b7:	e8 b9 c7 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f01039bc:	81 c3 70 bf 07 00    	add    $0x7bf70,%ebx
	env_free(e);
f01039c2:	ff 75 08             	push   0x8(%ebp)
f01039c5:	e8 d2 fd ff ff       	call   f010379c <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01039ca:	8d 83 c8 6b f8 ff    	lea    -0x79438(%ebx),%eax
f01039d0:	89 04 24             	mov    %eax,(%esp)
f01039d3:	e8 49 01 00 00       	call   f0103b21 <cprintf>
f01039d8:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01039db:	83 ec 0c             	sub    $0xc,%esp
f01039de:	6a 00                	push   $0x0
f01039e0:	e8 fa ce ff ff       	call   f01008df <monitor>
f01039e5:	83 c4 10             	add    $0x10,%esp
f01039e8:	eb f1                	jmp    f01039db <env_destroy+0x2b>

f01039ea <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01039ea:	55                   	push   %ebp
f01039eb:	89 e5                	mov    %esp,%ebp
f01039ed:	53                   	push   %ebx
f01039ee:	83 ec 08             	sub    $0x8,%esp
f01039f1:	e8 7f c7 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f01039f6:	81 c3 36 bf 07 00    	add    $0x7bf36,%ebx
	asm volatile(
f01039fc:	8b 65 08             	mov    0x8(%ebp),%esp
f01039ff:	61                   	popa   
f0103a00:	07                   	pop    %es
f0103a01:	1f                   	pop    %ds
f0103a02:	83 c4 08             	add    $0x8,%esp
f0103a05:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103a06:	8d 83 bb 6b f8 ff    	lea    -0x79445(%ebx),%eax
f0103a0c:	50                   	push   %eax
f0103a0d:	68 ef 01 00 00       	push   $0x1ef
f0103a12:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f0103a18:	50                   	push   %eax
f0103a19:	e8 a1 c6 ff ff       	call   f01000bf <_panic>

f0103a1e <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103a1e:	55                   	push   %ebp
f0103a1f:	89 e5                	mov    %esp,%ebp
f0103a21:	53                   	push   %ebx
f0103a22:	83 ec 04             	sub    $0x4,%esp
f0103a25:	e8 4b c7 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103a2a:	81 c3 02 bf 07 00    	add    $0x7bf02,%ebx
f0103a30:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (e != curenv) {
f0103a33:	8b 8b 48 1a 00 00    	mov    0x1a48(%ebx),%ecx
f0103a39:	39 c1                	cmp    %eax,%ecx
f0103a3b:	74 2d                	je     f0103a6a <env_run+0x4c>
		if (curenv && curenv->env_status == ENV_RUNNING) {
f0103a3d:	85 c9                	test   %ecx,%ecx
f0103a3f:	74 06                	je     f0103a47 <env_run+0x29>
f0103a41:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f0103a45:	74 31                	je     f0103a78 <env_run+0x5a>
			curenv->env_status = ENV_RUNNABLE;
		}
		curenv = e;
f0103a47:	89 83 48 1a 00 00    	mov    %eax,0x1a48(%ebx)
		curenv->env_status = ENV_RUNNING;
f0103a4d:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs ++;
f0103a54:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0103a58:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103a5b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a60:	76 1f                	jbe    f0103a81 <env_run+0x63>
	return (physaddr_t)kva - KERNBASE;
f0103a62:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a67:	0f 22 d8             	mov    %eax,%cr3
	}

	env_pop_tf(&(curenv->env_tf));
f0103a6a:	83 ec 0c             	sub    $0xc,%esp
f0103a6d:	ff b3 48 1a 00 00    	push   0x1a48(%ebx)
f0103a73:	e8 72 ff ff ff       	call   f01039ea <env_pop_tf>
			curenv->env_status = ENV_RUNNABLE;
f0103a78:	c7 41 54 02 00 00 00 	movl   $0x2,0x54(%ecx)
f0103a7f:	eb c6                	jmp    f0103a47 <env_run+0x29>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a81:	50                   	push   %eax
f0103a82:	8d 83 0c 60 f8 ff    	lea    -0x79ff4(%ebx),%eax
f0103a88:	50                   	push   %eax
f0103a89:	68 14 02 00 00       	push   $0x214
f0103a8e:	8d 83 43 6b f8 ff    	lea    -0x794bd(%ebx),%eax
f0103a94:	50                   	push   %eax
f0103a95:	e8 25 c6 ff ff       	call   f01000bf <_panic>

f0103a9a <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103a9a:	55                   	push   %ebp
f0103a9b:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103a9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103aa0:	ba 70 00 00 00       	mov    $0x70,%edx
f0103aa5:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103aa6:	ba 71 00 00 00       	mov    $0x71,%edx
f0103aab:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103aac:	0f b6 c0             	movzbl %al,%eax
}
f0103aaf:	5d                   	pop    %ebp
f0103ab0:	c3                   	ret    

f0103ab1 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103ab1:	55                   	push   %ebp
f0103ab2:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103ab4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ab7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103abc:	ee                   	out    %al,(%dx)
f0103abd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ac0:	ba 71 00 00 00       	mov    $0x71,%edx
f0103ac5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103ac6:	5d                   	pop    %ebp
f0103ac7:	c3                   	ret    

f0103ac8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103ac8:	55                   	push   %ebp
f0103ac9:	89 e5                	mov    %esp,%ebp
f0103acb:	53                   	push   %ebx
f0103acc:	83 ec 10             	sub    $0x10,%esp
f0103acf:	e8 a1 c6 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103ad4:	81 c3 58 be 07 00    	add    $0x7be58,%ebx
	cputchar(ch);
f0103ada:	ff 75 08             	push   0x8(%ebp)
f0103add:	e8 fe cb ff ff       	call   f01006e0 <cputchar>
	*cnt++;
}
f0103ae2:	83 c4 10             	add    $0x10,%esp
f0103ae5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ae8:	c9                   	leave  
f0103ae9:	c3                   	ret    

f0103aea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103aea:	55                   	push   %ebp
f0103aeb:	89 e5                	mov    %esp,%ebp
f0103aed:	53                   	push   %ebx
f0103aee:	83 ec 14             	sub    $0x14,%esp
f0103af1:	e8 7f c6 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103af6:	81 c3 36 be 07 00    	add    $0x7be36,%ebx
	int cnt = 0;
f0103afc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103b03:	ff 75 0c             	push   0xc(%ebp)
f0103b06:	ff 75 08             	push   0x8(%ebp)
f0103b09:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b0c:	50                   	push   %eax
f0103b0d:	8d 83 9c 41 f8 ff    	lea    -0x7be64(%ebx),%eax
f0103b13:	50                   	push   %eax
f0103b14:	e8 04 0d 00 00       	call   f010481d <vprintfmt>
	return cnt;
}
f0103b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b1f:	c9                   	leave  
f0103b20:	c3                   	ret    

f0103b21 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b21:	55                   	push   %ebp
f0103b22:	89 e5                	mov    %esp,%ebp
f0103b24:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b27:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b2a:	50                   	push   %eax
f0103b2b:	ff 75 08             	push   0x8(%ebp)
f0103b2e:	e8 b7 ff ff ff       	call   f0103aea <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b33:	c9                   	leave  
f0103b34:	c3                   	ret    

f0103b35 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b35:	55                   	push   %ebp
f0103b36:	89 e5                	mov    %esp,%ebp
f0103b38:	57                   	push   %edi
f0103b39:	56                   	push   %esi
f0103b3a:	53                   	push   %ebx
f0103b3b:	83 ec 04             	sub    $0x4,%esp
f0103b3e:	e8 32 c6 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103b43:	81 c3 e9 bd 07 00    	add    $0x7bde9,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103b49:	c7 83 78 22 00 00 00 	movl   $0xf0000000,0x2278(%ebx)
f0103b50:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103b53:	66 c7 83 7c 22 00 00 	movw   $0x10,0x227c(%ebx)
f0103b5a:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103b5c:	66 c7 83 da 22 00 00 	movw   $0x68,0x22da(%ebx)
f0103b63:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103b65:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103b6b:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103b71:	8d b3 74 22 00 00    	lea    0x2274(%ebx),%esi
f0103b77:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103b7b:	89 f2                	mov    %esi,%edx
f0103b7d:	c1 ea 10             	shr    $0x10,%edx
f0103b80:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103b83:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103b87:	83 e2 f0             	and    $0xfffffff0,%edx
f0103b8a:	83 ca 09             	or     $0x9,%edx
f0103b8d:	83 e2 9f             	and    $0xffffff9f,%edx
f0103b90:	83 ca 80             	or     $0xffffff80,%edx
f0103b93:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103b96:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103b99:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103b9d:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103ba0:	83 c9 40             	or     $0x40,%ecx
f0103ba3:	83 e1 7f             	and    $0x7f,%ecx
f0103ba6:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103ba9:	c1 ee 18             	shr    $0x18,%esi
f0103bac:	89 f1                	mov    %esi,%ecx
f0103bae:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103bb1:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103bb5:	83 e2 ef             	and    $0xffffffef,%edx
f0103bb8:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103bbb:	b8 28 00 00 00       	mov    $0x28,%eax
f0103bc0:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103bc3:	8d 83 dc 16 00 00    	lea    0x16dc(%ebx),%eax
f0103bc9:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103bcc:	83 c4 04             	add    $0x4,%esp
f0103bcf:	5b                   	pop    %ebx
f0103bd0:	5e                   	pop    %esi
f0103bd1:	5f                   	pop    %edi
f0103bd2:	5d                   	pop    %ebp
f0103bd3:	c3                   	ret    

f0103bd4 <trap_init>:
{
f0103bd4:	55                   	push   %ebp
f0103bd5:	89 e5                	mov    %esp,%ebp
f0103bd7:	57                   	push   %edi
f0103bd8:	56                   	push   %esi
f0103bd9:	53                   	push   %ebx
f0103bda:	e8 96 c5 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103bdf:	81 c3 4d bd 07 00    	add    $0x7bd4d,%ebx
	for (i = 0; i < 48; i++) {
f0103be5:	b8 00 00 00 00       	mov    $0x0,%eax
		SETGATE(idt[i], 1, GD_KT, traphandlertbl[i], 0);
f0103bea:	c7 c7 30 c3 11 f0    	mov    $0xf011c330,%edi
f0103bf0:	8d 35 54 1a 00 00    	lea    0x1a54,%esi
f0103bf6:	8b 0c 87             	mov    (%edi,%eax,4),%ecx
f0103bf9:	66 89 8c c3 54 1a 00 	mov    %cx,0x1a54(%ebx,%eax,8)
f0103c00:	00 
f0103c01:	8d 14 c3             	lea    (%ebx,%eax,8),%edx
f0103c04:	01 f2                	add    %esi,%edx
f0103c06:	66 c7 42 02 08 00    	movw   $0x8,0x2(%edx)
f0103c0c:	c6 84 c3 58 1a 00 00 	movb   $0x0,0x1a58(%ebx,%eax,8)
f0103c13:	00 
f0103c14:	c6 84 c3 59 1a 00 00 	movb   $0x8f,0x1a59(%ebx,%eax,8)
f0103c1b:	8f 
f0103c1c:	c1 e9 10             	shr    $0x10,%ecx
f0103c1f:	66 89 4a 06          	mov    %cx,0x6(%edx)
	for (i = 0; i < 48; i++) {
f0103c23:	83 c0 01             	add    $0x1,%eax
f0103c26:	83 f8 30             	cmp    $0x30,%eax
f0103c29:	75 cb                	jne    f0103bf6 <trap_init+0x22>
	SETGATE(idt[3], 1, GD_KT, traphandlertbl[3], 3);
f0103c2b:	c7 c2 30 c3 11 f0    	mov    $0xf011c330,%edx
f0103c31:	8b 42 0c             	mov    0xc(%edx),%eax
f0103c34:	66 89 83 6c 1a 00 00 	mov    %ax,0x1a6c(%ebx)
f0103c3b:	66 c7 83 6e 1a 00 00 	movw   $0x8,0x1a6e(%ebx)
f0103c42:	08 00 
f0103c44:	c6 83 70 1a 00 00 00 	movb   $0x0,0x1a70(%ebx)
f0103c4b:	c6 83 71 1a 00 00 ef 	movb   $0xef,0x1a71(%ebx)
f0103c52:	c1 e8 10             	shr    $0x10,%eax
f0103c55:	66 89 83 72 1a 00 00 	mov    %ax,0x1a72(%ebx)
	SETGATE(idt[48], 1, GD_KT, traphandlertbl[48], 3);
f0103c5c:	8b 82 c0 00 00 00    	mov    0xc0(%edx),%eax
f0103c62:	66 89 83 d4 1b 00 00 	mov    %ax,0x1bd4(%ebx)
f0103c69:	66 c7 83 d6 1b 00 00 	movw   $0x8,0x1bd6(%ebx)
f0103c70:	08 00 
f0103c72:	c6 83 d8 1b 00 00 00 	movb   $0x0,0x1bd8(%ebx)
f0103c79:	c6 83 d9 1b 00 00 ef 	movb   $0xef,0x1bd9(%ebx)
f0103c80:	c1 e8 10             	shr    $0x10,%eax
f0103c83:	66 89 83 da 1b 00 00 	mov    %ax,0x1bda(%ebx)
	trap_init_percpu();
f0103c8a:	e8 a6 fe ff ff       	call   f0103b35 <trap_init_percpu>
}
f0103c8f:	5b                   	pop    %ebx
f0103c90:	5e                   	pop    %esi
f0103c91:	5f                   	pop    %edi
f0103c92:	5d                   	pop    %ebp
f0103c93:	c3                   	ret    

f0103c94 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c94:	55                   	push   %ebp
f0103c95:	89 e5                	mov    %esp,%ebp
f0103c97:	56                   	push   %esi
f0103c98:	53                   	push   %ebx
f0103c99:	e8 d7 c4 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103c9e:	81 c3 8e bc 07 00    	add    $0x7bc8e,%ebx
f0103ca4:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ca7:	83 ec 08             	sub    $0x8,%esp
f0103caa:	ff 36                	push   (%esi)
f0103cac:	8d 83 fe 6b f8 ff    	lea    -0x79402(%ebx),%eax
f0103cb2:	50                   	push   %eax
f0103cb3:	e8 69 fe ff ff       	call   f0103b21 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103cb8:	83 c4 08             	add    $0x8,%esp
f0103cbb:	ff 76 04             	push   0x4(%esi)
f0103cbe:	8d 83 0d 6c f8 ff    	lea    -0x793f3(%ebx),%eax
f0103cc4:	50                   	push   %eax
f0103cc5:	e8 57 fe ff ff       	call   f0103b21 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103cca:	83 c4 08             	add    $0x8,%esp
f0103ccd:	ff 76 08             	push   0x8(%esi)
f0103cd0:	8d 83 1c 6c f8 ff    	lea    -0x793e4(%ebx),%eax
f0103cd6:	50                   	push   %eax
f0103cd7:	e8 45 fe ff ff       	call   f0103b21 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cdc:	83 c4 08             	add    $0x8,%esp
f0103cdf:	ff 76 0c             	push   0xc(%esi)
f0103ce2:	8d 83 2b 6c f8 ff    	lea    -0x793d5(%ebx),%eax
f0103ce8:	50                   	push   %eax
f0103ce9:	e8 33 fe ff ff       	call   f0103b21 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103cee:	83 c4 08             	add    $0x8,%esp
f0103cf1:	ff 76 10             	push   0x10(%esi)
f0103cf4:	8d 83 3a 6c f8 ff    	lea    -0x793c6(%ebx),%eax
f0103cfa:	50                   	push   %eax
f0103cfb:	e8 21 fe ff ff       	call   f0103b21 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d00:	83 c4 08             	add    $0x8,%esp
f0103d03:	ff 76 14             	push   0x14(%esi)
f0103d06:	8d 83 49 6c f8 ff    	lea    -0x793b7(%ebx),%eax
f0103d0c:	50                   	push   %eax
f0103d0d:	e8 0f fe ff ff       	call   f0103b21 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d12:	83 c4 08             	add    $0x8,%esp
f0103d15:	ff 76 18             	push   0x18(%esi)
f0103d18:	8d 83 58 6c f8 ff    	lea    -0x793a8(%ebx),%eax
f0103d1e:	50                   	push   %eax
f0103d1f:	e8 fd fd ff ff       	call   f0103b21 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d24:	83 c4 08             	add    $0x8,%esp
f0103d27:	ff 76 1c             	push   0x1c(%esi)
f0103d2a:	8d 83 67 6c f8 ff    	lea    -0x79399(%ebx),%eax
f0103d30:	50                   	push   %eax
f0103d31:	e8 eb fd ff ff       	call   f0103b21 <cprintf>
}
f0103d36:	83 c4 10             	add    $0x10,%esp
f0103d39:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103d3c:	5b                   	pop    %ebx
f0103d3d:	5e                   	pop    %esi
f0103d3e:	5d                   	pop    %ebp
f0103d3f:	c3                   	ret    

f0103d40 <print_trapframe>:
{
f0103d40:	55                   	push   %ebp
f0103d41:	89 e5                	mov    %esp,%ebp
f0103d43:	57                   	push   %edi
f0103d44:	56                   	push   %esi
f0103d45:	53                   	push   %ebx
f0103d46:	83 ec 14             	sub    $0x14,%esp
f0103d49:	e8 27 c4 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103d4e:	81 c3 de bb 07 00    	add    $0x7bbde,%ebx
f0103d54:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103d57:	56                   	push   %esi
f0103d58:	8d 83 b2 6d f8 ff    	lea    -0x7924e(%ebx),%eax
f0103d5e:	50                   	push   %eax
f0103d5f:	e8 bd fd ff ff       	call   f0103b21 <cprintf>
	print_regs(&tf->tf_regs);
f0103d64:	89 34 24             	mov    %esi,(%esp)
f0103d67:	e8 28 ff ff ff       	call   f0103c94 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d6c:	83 c4 08             	add    $0x8,%esp
f0103d6f:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103d73:	50                   	push   %eax
f0103d74:	8d 83 b8 6c f8 ff    	lea    -0x79348(%ebx),%eax
f0103d7a:	50                   	push   %eax
f0103d7b:	e8 a1 fd ff ff       	call   f0103b21 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d80:	83 c4 08             	add    $0x8,%esp
f0103d83:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103d87:	50                   	push   %eax
f0103d88:	8d 83 cb 6c f8 ff    	lea    -0x79335(%ebx),%eax
f0103d8e:	50                   	push   %eax
f0103d8f:	e8 8d fd ff ff       	call   f0103b21 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));	
f0103d94:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0103d97:	83 c4 10             	add    $0x10,%esp
f0103d9a:	83 fa 13             	cmp    $0x13,%edx
f0103d9d:	0f 86 e2 00 00 00    	jbe    f0103e85 <print_trapframe+0x145>
		return "System call";
f0103da3:	83 fa 30             	cmp    $0x30,%edx
f0103da6:	8d 83 76 6c f8 ff    	lea    -0x7938a(%ebx),%eax
f0103dac:	8d 8b 85 6c f8 ff    	lea    -0x7937b(%ebx),%ecx
f0103db2:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));	
f0103db5:	83 ec 04             	sub    $0x4,%esp
f0103db8:	50                   	push   %eax
f0103db9:	52                   	push   %edx
f0103dba:	8d 83 de 6c f8 ff    	lea    -0x79322(%ebx),%eax
f0103dc0:	50                   	push   %eax
f0103dc1:	e8 5b fd ff ff       	call   f0103b21 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103dc6:	83 c4 10             	add    $0x10,%esp
f0103dc9:	39 b3 54 22 00 00    	cmp    %esi,0x2254(%ebx)
f0103dcf:	0f 84 bc 00 00 00    	je     f0103e91 <print_trapframe+0x151>
	cprintf("  err  0x%08x", tf->tf_err);
f0103dd5:	83 ec 08             	sub    $0x8,%esp
f0103dd8:	ff 76 2c             	push   0x2c(%esi)
f0103ddb:	8d 83 ff 6c f8 ff    	lea    -0x79301(%ebx),%eax
f0103de1:	50                   	push   %eax
f0103de2:	e8 3a fd ff ff       	call   f0103b21 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103de7:	83 c4 10             	add    $0x10,%esp
f0103dea:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103dee:	0f 85 c2 00 00 00    	jne    f0103eb6 <print_trapframe+0x176>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103df4:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0103df7:	a8 01                	test   $0x1,%al
f0103df9:	8d 8b 91 6c f8 ff    	lea    -0x7936f(%ebx),%ecx
f0103dff:	8d 93 9c 6c f8 ff    	lea    -0x79364(%ebx),%edx
f0103e05:	0f 44 ca             	cmove  %edx,%ecx
f0103e08:	a8 02                	test   $0x2,%al
f0103e0a:	8d 93 a8 6c f8 ff    	lea    -0x79358(%ebx),%edx
f0103e10:	8d bb ae 6c f8 ff    	lea    -0x79352(%ebx),%edi
f0103e16:	0f 44 d7             	cmove  %edi,%edx
f0103e19:	a8 04                	test   $0x4,%al
f0103e1b:	8d 83 b3 6c f8 ff    	lea    -0x7934d(%ebx),%eax
f0103e21:	8d bb dd 6d f8 ff    	lea    -0x79223(%ebx),%edi
f0103e27:	0f 44 c7             	cmove  %edi,%eax
f0103e2a:	51                   	push   %ecx
f0103e2b:	52                   	push   %edx
f0103e2c:	50                   	push   %eax
f0103e2d:	8d 83 0d 6d f8 ff    	lea    -0x792f3(%ebx),%eax
f0103e33:	50                   	push   %eax
f0103e34:	e8 e8 fc ff ff       	call   f0103b21 <cprintf>
f0103e39:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e3c:	83 ec 08             	sub    $0x8,%esp
f0103e3f:	ff 76 30             	push   0x30(%esi)
f0103e42:	8d 83 1c 6d f8 ff    	lea    -0x792e4(%ebx),%eax
f0103e48:	50                   	push   %eax
f0103e49:	e8 d3 fc ff ff       	call   f0103b21 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e4e:	83 c4 08             	add    $0x8,%esp
f0103e51:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103e55:	50                   	push   %eax
f0103e56:	8d 83 2b 6d f8 ff    	lea    -0x792d5(%ebx),%eax
f0103e5c:	50                   	push   %eax
f0103e5d:	e8 bf fc ff ff       	call   f0103b21 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e62:	83 c4 08             	add    $0x8,%esp
f0103e65:	ff 76 38             	push   0x38(%esi)
f0103e68:	8d 83 3e 6d f8 ff    	lea    -0x792c2(%ebx),%eax
f0103e6e:	50                   	push   %eax
f0103e6f:	e8 ad fc ff ff       	call   f0103b21 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103e74:	83 c4 10             	add    $0x10,%esp
f0103e77:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103e7b:	75 50                	jne    f0103ecd <print_trapframe+0x18d>
}
f0103e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e80:	5b                   	pop    %ebx
f0103e81:	5e                   	pop    %esi
f0103e82:	5f                   	pop    %edi
f0103e83:	5d                   	pop    %ebp
f0103e84:	c3                   	ret    
		return excnames[trapno];
f0103e85:	8b 84 93 54 17 00 00 	mov    0x1754(%ebx,%edx,4),%eax
f0103e8c:	e9 24 ff ff ff       	jmp    f0103db5 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e91:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103e95:	0f 85 3a ff ff ff    	jne    f0103dd5 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103e9b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103e9e:	83 ec 08             	sub    $0x8,%esp
f0103ea1:	50                   	push   %eax
f0103ea2:	8d 83 f0 6c f8 ff    	lea    -0x79310(%ebx),%eax
f0103ea8:	50                   	push   %eax
f0103ea9:	e8 73 fc ff ff       	call   f0103b21 <cprintf>
f0103eae:	83 c4 10             	add    $0x10,%esp
f0103eb1:	e9 1f ff ff ff       	jmp    f0103dd5 <print_trapframe+0x95>
		cprintf("\n");
f0103eb6:	83 ec 0c             	sub    $0xc,%esp
f0103eb9:	8d 83 02 6b f8 ff    	lea    -0x794fe(%ebx),%eax
f0103ebf:	50                   	push   %eax
f0103ec0:	e8 5c fc ff ff       	call   f0103b21 <cprintf>
f0103ec5:	83 c4 10             	add    $0x10,%esp
f0103ec8:	e9 6f ff ff ff       	jmp    f0103e3c <print_trapframe+0xfc>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103ecd:	83 ec 08             	sub    $0x8,%esp
f0103ed0:	ff 76 3c             	push   0x3c(%esi)
f0103ed3:	8d 83 4d 6d f8 ff    	lea    -0x792b3(%ebx),%eax
f0103ed9:	50                   	push   %eax
f0103eda:	e8 42 fc ff ff       	call   f0103b21 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103edf:	83 c4 08             	add    $0x8,%esp
f0103ee2:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0103ee6:	50                   	push   %eax
f0103ee7:	8d 83 5c 6d f8 ff    	lea    -0x792a4(%ebx),%eax
f0103eed:	50                   	push   %eax
f0103eee:	e8 2e fc ff ff       	call   f0103b21 <cprintf>
f0103ef3:	83 c4 10             	add    $0x10,%esp
}
f0103ef6:	eb 85                	jmp    f0103e7d <print_trapframe+0x13d>

f0103ef8 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ef8:	55                   	push   %ebp
f0103ef9:	89 e5                	mov    %esp,%ebp
f0103efb:	57                   	push   %edi
f0103efc:	56                   	push   %esi
f0103efd:	53                   	push   %ebx
f0103efe:	83 ec 0c             	sub    $0xc,%esp
f0103f01:	e8 6f c2 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103f06:	81 c3 26 ba 07 00    	add    $0x7ba26,%ebx
f0103f0c:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f0f:	0f 20 d0             	mov    %cr2,%eax
	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// check if code segment of trapframe is in Kernel Text Segment

	if (tf->tf_cs == GD_KT) {
f0103f12:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103f17:	74 38                	je     f0103f51 <page_fault_handler+0x59>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103f19:	ff 76 30             	push   0x30(%esi)
f0103f1c:	50                   	push   %eax
f0103f1d:	c7 c7 74 13 18 f0    	mov    $0xf0181374,%edi
f0103f23:	8b 07                	mov    (%edi),%eax
f0103f25:	ff 70 48             	push   0x48(%eax)
f0103f28:	8d 83 28 6f f8 ff    	lea    -0x790d8(%ebx),%eax
f0103f2e:	50                   	push   %eax
f0103f2f:	e8 ed fb ff ff       	call   f0103b21 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103f34:	89 34 24             	mov    %esi,(%esp)
f0103f37:	e8 04 fe ff ff       	call   f0103d40 <print_trapframe>
	env_destroy(curenv);
f0103f3c:	83 c4 04             	add    $0x4,%esp
f0103f3f:	ff 37                	push   (%edi)
f0103f41:	e8 6a fa ff ff       	call   f01039b0 <env_destroy>
}
f0103f46:	83 c4 10             	add    $0x10,%esp
f0103f49:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f4c:	5b                   	pop    %ebx
f0103f4d:	5e                   	pop    %esi
f0103f4e:	5f                   	pop    %edi
f0103f4f:	5d                   	pop    %ebp
f0103f50:	c3                   	ret    
		panic("page fault in kernel");
f0103f51:	83 ec 04             	sub    $0x4,%esp
f0103f54:	8d 83 6f 6d f8 ff    	lea    -0x79291(%ebx),%eax
f0103f5a:	50                   	push   %eax
f0103f5b:	68 ee 00 00 00       	push   $0xee
f0103f60:	8d 83 84 6d f8 ff    	lea    -0x7927c(%ebx),%eax
f0103f66:	50                   	push   %eax
f0103f67:	e8 53 c1 ff ff       	call   f01000bf <_panic>

f0103f6c <trap>:
{
f0103f6c:	55                   	push   %ebp
f0103f6d:	89 e5                	mov    %esp,%ebp
f0103f6f:	57                   	push   %edi
f0103f70:	56                   	push   %esi
f0103f71:	53                   	push   %ebx
f0103f72:	83 ec 0c             	sub    $0xc,%esp
f0103f75:	e8 fb c1 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0103f7a:	81 c3 b2 b9 07 00    	add    $0x7b9b2,%ebx
f0103f80:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0103f83:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103f84:	9c                   	pushf  
f0103f85:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0103f86:	f6 c4 02             	test   $0x2,%ah
f0103f89:	74 1f                	je     f0103faa <trap+0x3e>
f0103f8b:	8d 83 90 6d f8 ff    	lea    -0x79270(%ebx),%eax
f0103f91:	50                   	push   %eax
f0103f92:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0103f98:	50                   	push   %eax
f0103f99:	68 c3 00 00 00       	push   $0xc3
f0103f9e:	8d 83 84 6d f8 ff    	lea    -0x7927c(%ebx),%eax
f0103fa4:	50                   	push   %eax
f0103fa5:	e8 15 c1 ff ff       	call   f01000bf <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f0103faa:	83 ec 08             	sub    $0x8,%esp
f0103fad:	56                   	push   %esi
f0103fae:	8d 83 a9 6d f8 ff    	lea    -0x79257(%ebx),%eax
f0103fb4:	50                   	push   %eax
f0103fb5:	e8 67 fb ff ff       	call   f0103b21 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f0103fba:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103fbe:	83 e0 03             	and    $0x3,%eax
f0103fc1:	83 c4 10             	add    $0x10,%esp
f0103fc4:	66 83 f8 03          	cmp    $0x3,%ax
f0103fc8:	75 1d                	jne    f0103fe7 <trap+0x7b>
		assert(curenv);
f0103fca:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f0103fd0:	8b 00                	mov    (%eax),%eax
f0103fd2:	85 c0                	test   %eax,%eax
f0103fd4:	74 5d                	je     f0104033 <trap+0xc7>
		curenv->env_tf = *tf;
f0103fd6:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103fdb:	89 c7                	mov    %eax,%edi
f0103fdd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0103fdf:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f0103fe5:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f0103fe7:	89 b3 54 22 00 00    	mov    %esi,0x2254(%ebx)
	switch (tf->tf_trapno) {
f0103fed:	8b 46 28             	mov    0x28(%esi),%eax
f0103ff0:	83 f8 0e             	cmp    $0xe,%eax
f0103ff3:	74 5d                	je     f0104052 <trap+0xe6>
f0103ff5:	83 f8 30             	cmp    $0x30,%eax
f0103ff8:	0f 84 9f 00 00 00    	je     f010409d <trap+0x131>
f0103ffe:	83 f8 03             	cmp    $0x3,%eax
f0104001:	0f 84 88 00 00 00    	je     f010408f <trap+0x123>
	print_trapframe(tf);
f0104007:	83 ec 0c             	sub    $0xc,%esp
f010400a:	56                   	push   %esi
f010400b:	e8 30 fd ff ff       	call   f0103d40 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104010:	83 c4 10             	add    $0x10,%esp
f0104013:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104018:	0f 84 a0 00 00 00    	je     f01040be <trap+0x152>
		env_destroy(curenv);
f010401e:	83 ec 0c             	sub    $0xc,%esp
f0104021:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f0104027:	ff 30                	push   (%eax)
f0104029:	e8 82 f9 ff ff       	call   f01039b0 <env_destroy>
		return;
f010402e:	83 c4 10             	add    $0x10,%esp
f0104031:	eb 2b                	jmp    f010405e <trap+0xf2>
		assert(curenv);
f0104033:	8d 83 c4 6d f8 ff    	lea    -0x7923c(%ebx),%eax
f0104039:	50                   	push   %eax
f010403a:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0104040:	50                   	push   %eax
f0104041:	68 c9 00 00 00       	push   $0xc9
f0104046:	8d 83 84 6d f8 ff    	lea    -0x7927c(%ebx),%eax
f010404c:	50                   	push   %eax
f010404d:	e8 6d c0 ff ff       	call   f01000bf <_panic>
		page_fault_handler(tf);
f0104052:	83 ec 0c             	sub    $0xc,%esp
f0104055:	56                   	push   %esi
f0104056:	e8 9d fe ff ff       	call   f0103ef8 <page_fault_handler>
		return;
f010405b:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010405e:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f0104064:	8b 00                	mov    (%eax),%eax
f0104066:	85 c0                	test   %eax,%eax
f0104068:	74 06                	je     f0104070 <trap+0x104>
f010406a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010406e:	74 69                	je     f01040d9 <trap+0x16d>
f0104070:	8d 83 4c 6f f8 ff    	lea    -0x790b4(%ebx),%eax
f0104076:	50                   	push   %eax
f0104077:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f010407d:	50                   	push   %eax
f010407e:	68 db 00 00 00       	push   $0xdb
f0104083:	8d 83 84 6d f8 ff    	lea    -0x7927c(%ebx),%eax
f0104089:	50                   	push   %eax
f010408a:	e8 30 c0 ff ff       	call   f01000bf <_panic>
		monitor(tf);
f010408f:	83 ec 0c             	sub    $0xc,%esp
f0104092:	56                   	push   %esi
f0104093:	e8 47 c8 ff ff       	call   f01008df <monitor>
		return;
f0104098:	83 c4 10             	add    $0x10,%esp
f010409b:	eb c1                	jmp    f010405e <trap+0xf2>
		tf->tf_regs.reg_eax = syscall
f010409d:	83 ec 08             	sub    $0x8,%esp
f01040a0:	ff 76 04             	push   0x4(%esi)
f01040a3:	ff 36                	push   (%esi)
f01040a5:	ff 76 10             	push   0x10(%esi)
f01040a8:	ff 76 18             	push   0x18(%esi)
f01040ab:	ff 76 14             	push   0x14(%esi)
f01040ae:	ff 76 1c             	push   0x1c(%esi)
f01040b1:	e8 c5 01 00 00       	call   f010427b <syscall>
f01040b6:	89 46 1c             	mov    %eax,0x1c(%esi)
		return;
f01040b9:	83 c4 20             	add    $0x20,%esp
f01040bc:	eb a0                	jmp    f010405e <trap+0xf2>
		panic("unhandled trap in kernel");
f01040be:	83 ec 04             	sub    $0x4,%esp
f01040c1:	8d 83 cb 6d f8 ff    	lea    -0x79235(%ebx),%eax
f01040c7:	50                   	push   %eax
f01040c8:	68 b2 00 00 00       	push   $0xb2
f01040cd:	8d 83 84 6d f8 ff    	lea    -0x7927c(%ebx),%eax
f01040d3:	50                   	push   %eax
f01040d4:	e8 e6 bf ff ff       	call   f01000bf <_panic>
	env_run(curenv);
f01040d9:	83 ec 0c             	sub    $0xc,%esp
f01040dc:	50                   	push   %eax
f01040dd:	e8 3c f9 ff ff       	call   f0103a1e <env_run>

f01040e2 <traphandler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(traphandler0, 0)
f01040e2:	6a 00                	push   $0x0
f01040e4:	6a 00                	push   $0x0
f01040e6:	e9 7b 01 00 00       	jmp    f0104266 <_alltraps>
f01040eb:	90                   	nop

f01040ec <traphandler1>:
TRAPHANDLER_NOEC(traphandler1, 1)
f01040ec:	6a 00                	push   $0x0
f01040ee:	6a 01                	push   $0x1
f01040f0:	e9 71 01 00 00       	jmp    f0104266 <_alltraps>
f01040f5:	90                   	nop

f01040f6 <traphandler2>:
TRAPHANDLER_NOEC(traphandler2, 2)
f01040f6:	6a 00                	push   $0x0
f01040f8:	6a 02                	push   $0x2
f01040fa:	e9 67 01 00 00       	jmp    f0104266 <_alltraps>
f01040ff:	90                   	nop

f0104100 <traphandler3>:
TRAPHANDLER_NOEC(traphandler3, 3)
f0104100:	6a 00                	push   $0x0
f0104102:	6a 03                	push   $0x3
f0104104:	e9 5d 01 00 00       	jmp    f0104266 <_alltraps>
f0104109:	90                   	nop

f010410a <traphandler4>:
TRAPHANDLER_NOEC(traphandler4, 4)
f010410a:	6a 00                	push   $0x0
f010410c:	6a 04                	push   $0x4
f010410e:	e9 53 01 00 00       	jmp    f0104266 <_alltraps>
f0104113:	90                   	nop

f0104114 <traphandler5>:
TRAPHANDLER_NOEC(traphandler5, 5)
f0104114:	6a 00                	push   $0x0
f0104116:	6a 05                	push   $0x5
f0104118:	e9 49 01 00 00       	jmp    f0104266 <_alltraps>
f010411d:	90                   	nop

f010411e <traphandler6>:
TRAPHANDLER_NOEC(traphandler6, 6)
f010411e:	6a 00                	push   $0x0
f0104120:	6a 06                	push   $0x6
f0104122:	e9 3f 01 00 00       	jmp    f0104266 <_alltraps>
f0104127:	90                   	nop

f0104128 <traphandler7>:
TRAPHANDLER_NOEC(traphandler7, 7)
f0104128:	6a 00                	push   $0x0
f010412a:	6a 07                	push   $0x7
f010412c:	e9 35 01 00 00       	jmp    f0104266 <_alltraps>
f0104131:	90                   	nop

f0104132 <traphandler8>:
TRAPHANDLER(traphandler8, 8)
f0104132:	6a 08                	push   $0x8
f0104134:	e9 2d 01 00 00       	jmp    f0104266 <_alltraps>
f0104139:	90                   	nop

f010413a <traphandler9>:
TRAPHANDLER_NOEC(traphandler9, 9) /* reserved */
f010413a:	6a 00                	push   $0x0
f010413c:	6a 09                	push   $0x9
f010413e:	e9 23 01 00 00       	jmp    f0104266 <_alltraps>
f0104143:	90                   	nop

f0104144 <traphandler10>:
TRAPHANDLER(traphandler10, 10)
f0104144:	6a 0a                	push   $0xa
f0104146:	e9 1b 01 00 00       	jmp    f0104266 <_alltraps>
f010414b:	90                   	nop

f010414c <traphandler11>:
TRAPHANDLER(traphandler11, 11)
f010414c:	6a 0b                	push   $0xb
f010414e:	e9 13 01 00 00       	jmp    f0104266 <_alltraps>
f0104153:	90                   	nop

f0104154 <traphandler12>:
TRAPHANDLER(traphandler12, 12)
f0104154:	6a 0c                	push   $0xc
f0104156:	e9 0b 01 00 00       	jmp    f0104266 <_alltraps>
f010415b:	90                   	nop

f010415c <traphandler13>:
TRAPHANDLER(traphandler13, 13)
f010415c:	6a 0d                	push   $0xd
f010415e:	e9 03 01 00 00       	jmp    f0104266 <_alltraps>
f0104163:	90                   	nop

f0104164 <traphandler14>:
TRAPHANDLER(traphandler14, 14)
f0104164:	6a 0e                	push   $0xe
f0104166:	e9 fb 00 00 00       	jmp    f0104266 <_alltraps>
f010416b:	90                   	nop

f010416c <traphandler15>:
TRAPHANDLER_NOEC(traphandler15, 15) /* reserved */
f010416c:	6a 00                	push   $0x0
f010416e:	6a 0f                	push   $0xf
f0104170:	e9 f1 00 00 00       	jmp    f0104266 <_alltraps>
f0104175:	90                   	nop

f0104176 <traphandler16>:
TRAPHANDLER_NOEC(traphandler16, 16)
f0104176:	6a 00                	push   $0x0
f0104178:	6a 10                	push   $0x10
f010417a:	e9 e7 00 00 00       	jmp    f0104266 <_alltraps>
f010417f:	90                   	nop

f0104180 <traphandler17>:
TRAPHANDLER(traphandler17, 17)
f0104180:	6a 11                	push   $0x11
f0104182:	e9 df 00 00 00       	jmp    f0104266 <_alltraps>
f0104187:	90                   	nop

f0104188 <traphandler18>:
TRAPHANDLER_NOEC(traphandler18, 18)
f0104188:	6a 00                	push   $0x0
f010418a:	6a 12                	push   $0x12
f010418c:	e9 d5 00 00 00       	jmp    f0104266 <_alltraps>
f0104191:	90                   	nop

f0104192 <traphandler19>:
TRAPHANDLER_NOEC(traphandler19, 19)
f0104192:	6a 00                	push   $0x0
f0104194:	6a 13                	push   $0x13
f0104196:	e9 cb 00 00 00       	jmp    f0104266 <_alltraps>
f010419b:	90                   	nop

f010419c <traphandler20>:
TRAPHANDLER_NOEC(traphandler20, 20)
f010419c:	6a 00                	push   $0x0
f010419e:	6a 14                	push   $0x14
f01041a0:	e9 c1 00 00 00       	jmp    f0104266 <_alltraps>
f01041a5:	90                   	nop

f01041a6 <traphandler21>:
TRAPHANDLER_NOEC(traphandler21, 21)
f01041a6:	6a 00                	push   $0x0
f01041a8:	6a 15                	push   $0x15
f01041aa:	e9 b7 00 00 00       	jmp    f0104266 <_alltraps>
f01041af:	90                   	nop

f01041b0 <traphandler22>:
TRAPHANDLER_NOEC(traphandler22, 22)
f01041b0:	6a 00                	push   $0x0
f01041b2:	6a 16                	push   $0x16
f01041b4:	e9 ad 00 00 00       	jmp    f0104266 <_alltraps>
f01041b9:	90                   	nop

f01041ba <traphandler23>:
TRAPHANDLER_NOEC(traphandler23, 23)
f01041ba:	6a 00                	push   $0x0
f01041bc:	6a 17                	push   $0x17
f01041be:	e9 a3 00 00 00       	jmp    f0104266 <_alltraps>
f01041c3:	90                   	nop

f01041c4 <traphandler24>:
TRAPHANDLER_NOEC(traphandler24, 24)
f01041c4:	6a 00                	push   $0x0
f01041c6:	6a 18                	push   $0x18
f01041c8:	e9 99 00 00 00       	jmp    f0104266 <_alltraps>
f01041cd:	90                   	nop

f01041ce <traphandler25>:
TRAPHANDLER_NOEC(traphandler25, 25)
f01041ce:	6a 00                	push   $0x0
f01041d0:	6a 19                	push   $0x19
f01041d2:	e9 8f 00 00 00       	jmp    f0104266 <_alltraps>
f01041d7:	90                   	nop

f01041d8 <traphandler26>:
TRAPHANDLER_NOEC(traphandler26, 26)
f01041d8:	6a 00                	push   $0x0
f01041da:	6a 1a                	push   $0x1a
f01041dc:	e9 85 00 00 00       	jmp    f0104266 <_alltraps>
f01041e1:	90                   	nop

f01041e2 <traphandler27>:
TRAPHANDLER_NOEC(traphandler27, 27)
f01041e2:	6a 00                	push   $0x0
f01041e4:	6a 1b                	push   $0x1b
f01041e6:	eb 7e                	jmp    f0104266 <_alltraps>

f01041e8 <traphandler28>:
TRAPHANDLER_NOEC(traphandler28, 28)
f01041e8:	6a 00                	push   $0x0
f01041ea:	6a 1c                	push   $0x1c
f01041ec:	eb 78                	jmp    f0104266 <_alltraps>

f01041ee <traphandler29>:
TRAPHANDLER_NOEC(traphandler29, 29)
f01041ee:	6a 00                	push   $0x0
f01041f0:	6a 1d                	push   $0x1d
f01041f2:	eb 72                	jmp    f0104266 <_alltraps>

f01041f4 <traphandler30>:
TRAPHANDLER_NOEC(traphandler30, 30)
f01041f4:	6a 00                	push   $0x0
f01041f6:	6a 1e                	push   $0x1e
f01041f8:	eb 6c                	jmp    f0104266 <_alltraps>

f01041fa <traphandler31>:
TRAPHANDLER_NOEC(traphandler31, 31)
f01041fa:	6a 00                	push   $0x0
f01041fc:	6a 1f                	push   $0x1f
f01041fe:	eb 66                	jmp    f0104266 <_alltraps>

f0104200 <traphandler32>:
TRAPHANDLER_NOEC(traphandler32, 32)
f0104200:	6a 00                	push   $0x0
f0104202:	6a 20                	push   $0x20
f0104204:	eb 60                	jmp    f0104266 <_alltraps>

f0104206 <traphandler33>:
TRAPHANDLER_NOEC(traphandler33, 33)
f0104206:	6a 00                	push   $0x0
f0104208:	6a 21                	push   $0x21
f010420a:	eb 5a                	jmp    f0104266 <_alltraps>

f010420c <traphandler34>:
TRAPHANDLER_NOEC(traphandler34, 34)
f010420c:	6a 00                	push   $0x0
f010420e:	6a 22                	push   $0x22
f0104210:	eb 54                	jmp    f0104266 <_alltraps>

f0104212 <traphandler35>:
TRAPHANDLER_NOEC(traphandler35, 35)
f0104212:	6a 00                	push   $0x0
f0104214:	6a 23                	push   $0x23
f0104216:	eb 4e                	jmp    f0104266 <_alltraps>

f0104218 <traphandler36>:
TRAPHANDLER_NOEC(traphandler36, 36)
f0104218:	6a 00                	push   $0x0
f010421a:	6a 24                	push   $0x24
f010421c:	eb 48                	jmp    f0104266 <_alltraps>

f010421e <traphandler37>:
TRAPHANDLER_NOEC(traphandler37, 37)
f010421e:	6a 00                	push   $0x0
f0104220:	6a 25                	push   $0x25
f0104222:	eb 42                	jmp    f0104266 <_alltraps>

f0104224 <traphandler38>:
TRAPHANDLER_NOEC(traphandler38, 38)
f0104224:	6a 00                	push   $0x0
f0104226:	6a 26                	push   $0x26
f0104228:	eb 3c                	jmp    f0104266 <_alltraps>

f010422a <traphandler39>:
TRAPHANDLER_NOEC(traphandler39, 39)
f010422a:	6a 00                	push   $0x0
f010422c:	6a 27                	push   $0x27
f010422e:	eb 36                	jmp    f0104266 <_alltraps>

f0104230 <traphandler40>:
TRAPHANDLER_NOEC(traphandler40, 40)
f0104230:	6a 00                	push   $0x0
f0104232:	6a 28                	push   $0x28
f0104234:	eb 30                	jmp    f0104266 <_alltraps>

f0104236 <traphandler41>:
TRAPHANDLER_NOEC(traphandler41, 41)
f0104236:	6a 00                	push   $0x0
f0104238:	6a 29                	push   $0x29
f010423a:	eb 2a                	jmp    f0104266 <_alltraps>

f010423c <traphandler42>:
TRAPHANDLER_NOEC(traphandler42, 42)
f010423c:	6a 00                	push   $0x0
f010423e:	6a 2a                	push   $0x2a
f0104240:	eb 24                	jmp    f0104266 <_alltraps>

f0104242 <traphandler43>:
TRAPHANDLER_NOEC(traphandler43, 43)
f0104242:	6a 00                	push   $0x0
f0104244:	6a 2b                	push   $0x2b
f0104246:	eb 1e                	jmp    f0104266 <_alltraps>

f0104248 <traphandler44>:
TRAPHANDLER_NOEC(traphandler44, 44)
f0104248:	6a 00                	push   $0x0
f010424a:	6a 2c                	push   $0x2c
f010424c:	eb 18                	jmp    f0104266 <_alltraps>

f010424e <traphandler45>:
TRAPHANDLER_NOEC(traphandler45, 45)
f010424e:	6a 00                	push   $0x0
f0104250:	6a 2d                	push   $0x2d
f0104252:	eb 12                	jmp    f0104266 <_alltraps>

f0104254 <traphandler46>:
TRAPHANDLER_NOEC(traphandler46, 46)
f0104254:	6a 00                	push   $0x0
f0104256:	6a 2e                	push   $0x2e
f0104258:	eb 0c                	jmp    f0104266 <_alltraps>

f010425a <traphandler47>:
TRAPHANDLER_NOEC(traphandler47, 47)
f010425a:	6a 00                	push   $0x0
f010425c:	6a 2f                	push   $0x2f
f010425e:	eb 06                	jmp    f0104266 <_alltraps>

f0104260 <traphandler48>:
TRAPHANDLER_NOEC(traphandler48, 48)
f0104260:	6a 00                	push   $0x0
f0104262:	6a 30                	push   $0x30
f0104264:	eb 00                	jmp    f0104266 <_alltraps>

f0104266 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 * pushal ---> push edi, exi,..., eax
 */
.text
_alltraps:
	pushl %es
f0104266:	06                   	push   %es
	pushl %ds
f0104267:	1e                   	push   %ds

	pushal 
f0104268:	60                   	pusha  

	movw $GD_KD,%ax 
f0104269:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax,%ds
f010426d:	8e d8                	mov    %eax,%ds
	movw %ax,%es
f010426f:	8e c0                	mov    %eax,%es

	pushl %esp
f0104271:	54                   	push   %esp

	call trap
f0104272:	e8 f5 fc ff ff       	call   f0103f6c <trap>

	popl %esp
f0104277:	5c                   	pop    %esp

	popal
f0104278:	61                   	popa   

	popl %ds
f0104279:	1f                   	pop    %ds
	popl %es
f010427a:	07                   	pop    %es

f010427b <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010427b:	55                   	push   %ebp
f010427c:	89 e5                	mov    %esp,%ebp
f010427e:	53                   	push   %ebx
f010427f:	83 ec 14             	sub    $0x14,%esp
f0104282:	e8 ee be ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0104287:	81 c3 a5 b6 07 00    	add    $0x7b6a5,%ebx
f010428d:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104290:	83 f8 02             	cmp    $0x2,%eax
f0104293:	0f 84 a7 00 00 00    	je     f0104340 <syscall+0xc5>
f0104299:	83 f8 02             	cmp    $0x2,%eax
f010429c:	77 0b                	ja     f01042a9 <syscall+0x2e>
f010429e:	85 c0                	test   %eax,%eax
f01042a0:	74 6a                	je     f010430c <syscall+0x91>
	return cons_getc();
f01042a2:	e8 d0 c2 ff ff       	call   f0100577 <cons_getc>
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f01042a7:	eb 5e                	jmp    f0104307 <syscall+0x8c>
	switch (syscallno) {
f01042a9:	83 f8 03             	cmp    $0x3,%eax
f01042ac:	75 54                	jne    f0104302 <syscall+0x87>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01042ae:	83 ec 04             	sub    $0x4,%esp
f01042b1:	6a 01                	push   $0x1
f01042b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01042b6:	50                   	push   %eax
f01042b7:	ff 75 0c             	push   0xc(%ebp)
f01042ba:	e8 fa f0 ff ff       	call   f01033b9 <envid2env>
f01042bf:	83 c4 10             	add    $0x10,%esp
f01042c2:	85 c0                	test   %eax,%eax
f01042c4:	78 41                	js     f0104307 <syscall+0x8c>
	if (e == curenv)
f01042c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01042c9:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f01042cf:	8b 00                	mov    (%eax),%eax
f01042d1:	39 c2                	cmp    %eax,%edx
f01042d3:	74 78                	je     f010434d <syscall+0xd2>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01042d5:	83 ec 04             	sub    $0x4,%esp
f01042d8:	ff 72 48             	push   0x48(%edx)
f01042db:	ff 70 48             	push   0x48(%eax)
f01042de:	8d 83 98 6f f8 ff    	lea    -0x79068(%ebx),%eax
f01042e4:	50                   	push   %eax
f01042e5:	e8 37 f8 ff ff       	call   f0103b21 <cprintf>
f01042ea:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01042ed:	83 ec 0c             	sub    $0xc,%esp
f01042f0:	ff 75 f4             	push   -0xc(%ebp)
f01042f3:	e8 b8 f6 ff ff       	call   f01039b0 <env_destroy>
	return 0;
f01042f8:	83 c4 10             	add    $0x10,%esp
f01042fb:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
f0104300:	eb 05                	jmp    f0104307 <syscall+0x8c>
	switch (syscallno) {
f0104302:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	default:
		return -E_INVAL;
	}
}
f0104307:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010430a:	c9                   	leave  
f010430b:	c3                   	ret    
	user_mem_assert(curenv, s, len, PTE_U | PTE_P);
f010430c:	6a 05                	push   $0x5
f010430e:	ff 75 10             	push   0x10(%ebp)
f0104311:	ff 75 0c             	push   0xc(%ebp)
f0104314:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f010431a:	ff 30                	push   (%eax)
f010431c:	e8 94 ef ff ff       	call   f01032b5 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104321:	83 c4 0c             	add    $0xc,%esp
f0104324:	ff 75 0c             	push   0xc(%ebp)
f0104327:	ff 75 10             	push   0x10(%ebp)
f010432a:	8d 83 78 6f f8 ff    	lea    -0x79088(%ebx),%eax
f0104330:	50                   	push   %eax
f0104331:	e8 eb f7 ff ff       	call   f0103b21 <cprintf>
}
f0104336:	83 c4 10             	add    $0x10,%esp
		return 0;
f0104339:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010433e:	eb c7                	jmp    f0104307 <syscall+0x8c>
	return curenv->env_id;
f0104340:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f0104346:	8b 00                	mov    (%eax),%eax
f0104348:	8b 40 48             	mov    0x48(%eax),%eax
		return sys_getenvid();
f010434b:	eb ba                	jmp    f0104307 <syscall+0x8c>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010434d:	83 ec 08             	sub    $0x8,%esp
f0104350:	ff 70 48             	push   0x48(%eax)
f0104353:	8d 83 7d 6f f8 ff    	lea    -0x79083(%ebx),%eax
f0104359:	50                   	push   %eax
f010435a:	e8 c2 f7 ff ff       	call   f0103b21 <cprintf>
f010435f:	83 c4 10             	add    $0x10,%esp
f0104362:	eb 89                	jmp    f01042ed <syscall+0x72>

f0104364 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104364:	55                   	push   %ebp
f0104365:	89 e5                	mov    %esp,%ebp
f0104367:	57                   	push   %edi
f0104368:	56                   	push   %esi
f0104369:	53                   	push   %ebx
f010436a:	83 ec 14             	sub    $0x14,%esp
f010436d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104370:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104373:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104376:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104379:	8b 1a                	mov    (%edx),%ebx
f010437b:	8b 01                	mov    (%ecx),%eax
f010437d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104380:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104387:	eb 2f                	jmp    f01043b8 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104389:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010438c:	39 c3                	cmp    %eax,%ebx
f010438e:	7f 4e                	jg     f01043de <stab_binsearch+0x7a>
f0104390:	0f b6 0a             	movzbl (%edx),%ecx
f0104393:	83 ea 0c             	sub    $0xc,%edx
f0104396:	39 f1                	cmp    %esi,%ecx
f0104398:	75 ef                	jne    f0104389 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010439a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010439d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01043a0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01043a4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01043a7:	73 3a                	jae    f01043e3 <stab_binsearch+0x7f>
			*region_left = m;
f01043a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01043ac:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01043ae:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01043b1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01043b8:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01043bb:	7f 53                	jg     f0104410 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01043bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01043c0:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01043c3:	89 d0                	mov    %edx,%eax
f01043c5:	c1 e8 1f             	shr    $0x1f,%eax
f01043c8:	01 d0                	add    %edx,%eax
f01043ca:	89 c7                	mov    %eax,%edi
f01043cc:	d1 ff                	sar    %edi
f01043ce:	83 e0 fe             	and    $0xfffffffe,%eax
f01043d1:	01 f8                	add    %edi,%eax
f01043d3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01043d6:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01043da:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f01043dc:	eb ae                	jmp    f010438c <stab_binsearch+0x28>
			l = true_m + 1;
f01043de:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01043e1:	eb d5                	jmp    f01043b8 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01043e3:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01043e6:	76 14                	jbe    f01043fc <stab_binsearch+0x98>
			*region_right = m - 1;
f01043e8:	83 e8 01             	sub    $0x1,%eax
f01043eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01043ee:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01043f1:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f01043f3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01043fa:	eb bc                	jmp    f01043b8 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01043fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01043ff:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104401:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104405:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104407:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010440e:	eb a8                	jmp    f01043b8 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104410:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104414:	75 15                	jne    f010442b <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104416:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104419:	8b 00                	mov    (%eax),%eax
f010441b:	83 e8 01             	sub    $0x1,%eax
f010441e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104421:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104423:	83 c4 14             	add    $0x14,%esp
f0104426:	5b                   	pop    %ebx
f0104427:	5e                   	pop    %esi
f0104428:	5f                   	pop    %edi
f0104429:	5d                   	pop    %ebp
f010442a:	c3                   	ret    
		for (l = *region_right;
f010442b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010442e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104433:	8b 0f                	mov    (%edi),%ecx
f0104435:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104438:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010443b:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010443f:	39 c1                	cmp    %eax,%ecx
f0104441:	7d 0f                	jge    f0104452 <stab_binsearch+0xee>
f0104443:	0f b6 1a             	movzbl (%edx),%ebx
f0104446:	83 ea 0c             	sub    $0xc,%edx
f0104449:	39 f3                	cmp    %esi,%ebx
f010444b:	74 05                	je     f0104452 <stab_binsearch+0xee>
		     l--)
f010444d:	83 e8 01             	sub    $0x1,%eax
f0104450:	eb ed                	jmp    f010443f <stab_binsearch+0xdb>
		*region_left = l;
f0104452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104455:	89 07                	mov    %eax,(%edi)
}
f0104457:	eb ca                	jmp    f0104423 <stab_binsearch+0xbf>

f0104459 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104459:	55                   	push   %ebp
f010445a:	89 e5                	mov    %esp,%ebp
f010445c:	57                   	push   %edi
f010445d:	56                   	push   %esi
f010445e:	53                   	push   %ebx
f010445f:	83 ec 4c             	sub    $0x4c,%esp
f0104462:	e8 0e bd ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0104467:	81 c3 c5 b4 07 00    	add    $0x7b4c5,%ebx
f010446d:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104470:	8d 83 b0 6f f8 ff    	lea    -0x79050(%ebx),%eax
f0104476:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0104478:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010447f:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104482:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104489:	8b 45 08             	mov    0x8(%ebp),%eax
f010448c:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f010448f:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104496:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010449b:	0f 86 3a 01 00 00    	jbe    f01045db <debuginfo_eip+0x182>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01044a1:	c7 c0 6b 2e 11 f0    	mov    $0xf0112e6b,%eax
f01044a7:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01044aa:	c7 c0 09 f2 10 f0    	mov    $0xf010f209,%eax
f01044b0:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = __STAB_END__;
f01044b3:	c7 c7 08 f2 10 f0    	mov    $0xf010f208,%edi
		stabs = __STAB_BEGIN__;
f01044b9:	c7 c0 d8 6a 10 f0    	mov    $0xf0106ad8,%eax
f01044bf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01044c2:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01044c5:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01044c8:	0f 83 35 02 00 00    	jae    f0104703 <debuginfo_eip+0x2aa>
f01044ce:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01044d2:	0f 85 32 02 00 00    	jne    f010470a <debuginfo_eip+0x2b1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01044d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01044df:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01044e2:	c1 ff 02             	sar    $0x2,%edi
f01044e5:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01044eb:	83 e8 01             	sub    $0x1,%eax
f01044ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01044f1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01044f4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01044f7:	83 ec 08             	sub    $0x8,%esp
f01044fa:	ff 75 08             	push   0x8(%ebp)
f01044fd:	6a 64                	push   $0x64
f01044ff:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104502:	e8 5d fe ff ff       	call   f0104364 <stab_binsearch>
	if (lfile == 0)
f0104507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010450a:	83 c4 10             	add    $0x10,%esp
f010450d:	85 ff                	test   %edi,%edi
f010450f:	0f 84 fc 01 00 00    	je     f0104711 <debuginfo_eip+0x2b8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104515:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f0104518:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010451b:	89 55 b8             	mov    %edx,-0x48(%ebp)
f010451e:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104521:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104524:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104527:	83 ec 08             	sub    $0x8,%esp
f010452a:	ff 75 08             	push   0x8(%ebp)
f010452d:	6a 24                	push   $0x24
f010452f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104532:	e8 2d fe ff ff       	call   f0104364 <stab_binsearch>

	if (lfun <= rfun) {
f0104537:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010453a:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f010453d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104540:	89 45 b0             	mov    %eax,-0x50(%ebp)
f0104543:	83 c4 10             	add    $0x10,%esp
f0104546:	39 c2                	cmp    %eax,%edx
f0104548:	0f 8f 28 01 00 00    	jg     f0104676 <debuginfo_eip+0x21d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010454e:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104551:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104554:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104557:	8b 02                	mov    (%edx),%eax
f0104559:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010455c:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f010455f:	39 c8                	cmp    %ecx,%eax
f0104561:	73 06                	jae    f0104569 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104563:	03 45 bc             	add    -0x44(%ebp),%eax
f0104566:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104569:	8b 42 08             	mov    0x8(%edx),%eax
		addr -= info->eip_fn_addr;
f010456c:	29 45 08             	sub    %eax,0x8(%ebp)
f010456f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104572:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0104575:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104578:	89 46 10             	mov    %eax,0x10(%esi)
		// Search within the function definition for the line number.
		lline = lfun;
f010457b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f010457e:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104581:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104584:	83 ec 08             	sub    $0x8,%esp
f0104587:	6a 3a                	push   $0x3a
f0104589:	ff 76 08             	push   0x8(%esi)
f010458c:	e8 1d 0a 00 00       	call   f0104fae <strfind>
f0104591:	2b 46 08             	sub    0x8(%esi),%eax
f0104594:	89 46 0c             	mov    %eax,0xc(%esi)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104597:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010459a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010459d:	83 c4 08             	add    $0x8,%esp
f01045a0:	ff 75 08             	push   0x8(%ebp)
f01045a3:	6a 44                	push   $0x44
f01045a5:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01045a8:	89 d8                	mov    %ebx,%eax
f01045aa:	e8 b5 fd ff ff       	call   f0104364 <stab_binsearch>
	if (lline <= rline) {
f01045af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01045b2:	83 c4 10             	add    $0x10,%esp
		// stabs[lline] points to the line number
		info->eip_line = stabs[lline].n_desc;
	} else {
		// Couldn't find line number stab! return -1
		info->eip_line = -1;
f01045b5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	if (lline <= rline) {
f01045ba:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01045bd:	7f 08                	jg     f01045c7 <debuginfo_eip+0x16e>
		info->eip_line = stabs[lline].n_desc;
f01045bf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01045c2:	0f b7 54 93 06       	movzwl 0x6(%ebx,%edx,4),%edx
f01045c7:	89 56 04             	mov    %edx,0x4(%esi)
f01045ca:	89 c2                	mov    %eax,%edx
f01045cc:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01045cf:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01045d2:	8d 44 83 04          	lea    0x4(%ebx,%eax,4),%eax
f01045d6:	e9 ab 00 00 00       	jmp    f0104686 <debuginfo_eip+0x22d>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_P | PTE_U)) {
f01045db:	6a 05                	push   $0x5
f01045dd:	6a 10                	push   $0x10
f01045df:	68 00 00 20 00       	push   $0x200000
f01045e4:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f01045ea:	ff 30                	push   (%eax)
f01045ec:	e8 1b ec ff ff       	call   f010320c <user_mem_check>
f01045f1:	83 c4 10             	add    $0x10,%esp
f01045f4:	85 c0                	test   %eax,%eax
f01045f6:	0f 85 f9 00 00 00    	jne    f01046f5 <debuginfo_eip+0x29c>
		stabs = usd->stabs;
f01045fc:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104602:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104605:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f010460b:	a1 08 00 20 00       	mov    0x200008,%eax
f0104610:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0104613:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104618:	89 45 c0             	mov    %eax,-0x40(%ebp)
		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_P | PTE_U)) {
f010461b:	6a 05                	push   $0x5
f010461d:	89 fa                	mov    %edi,%edx
f010461f:	29 ca                	sub    %ecx,%edx
f0104621:	89 d0                	mov    %edx,%eax
f0104623:	c1 f8 02             	sar    $0x2,%eax
f0104626:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010462c:	50                   	push   %eax
f010462d:	51                   	push   %ecx
f010462e:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f0104634:	ff 30                	push   (%eax)
f0104636:	e8 d1 eb ff ff       	call   f010320c <user_mem_check>
f010463b:	83 c4 10             	add    $0x10,%esp
f010463e:	85 c0                	test   %eax,%eax
f0104640:	0f 85 b6 00 00 00    	jne    f01046fc <debuginfo_eip+0x2a3>
		if (user_mem_check(curenv, usd, stabstr_end - stabstr, PTE_P | PTE_U)) {
f0104646:	6a 05                	push   $0x5
f0104648:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010464b:	2b 45 bc             	sub    -0x44(%ebp),%eax
f010464e:	50                   	push   %eax
f010464f:	68 00 00 20 00       	push   $0x200000
f0104654:	c7 c0 74 13 18 f0    	mov    $0xf0181374,%eax
f010465a:	ff 30                	push   (%eax)
f010465c:	e8 ab eb ff ff       	call   f010320c <user_mem_check>
f0104661:	83 c4 10             	add    $0x10,%esp
f0104664:	85 c0                	test   %eax,%eax
f0104666:	0f 84 56 fe ff ff    	je     f01044c2 <debuginfo_eip+0x69>
			return -1;
f010466c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104671:	e9 a7 00 00 00       	jmp    f010471d <debuginfo_eip+0x2c4>
f0104676:	8b 45 08             	mov    0x8(%ebp),%eax
f0104679:	89 fa                	mov    %edi,%edx
f010467b:	e9 f8 fe ff ff       	jmp    f0104578 <debuginfo_eip+0x11f>
f0104680:	83 ea 01             	sub    $0x1,%edx
f0104683:	83 e8 0c             	sub    $0xc,%eax
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104686:	39 d7                	cmp    %edx,%edi
f0104688:	7f 2e                	jg     f01046b8 <debuginfo_eip+0x25f>
	       && stabs[lline].n_type != N_SOL
f010468a:	0f b6 08             	movzbl (%eax),%ecx
f010468d:	80 f9 84             	cmp    $0x84,%cl
f0104690:	74 0b                	je     f010469d <debuginfo_eip+0x244>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104692:	80 f9 64             	cmp    $0x64,%cl
f0104695:	75 e9                	jne    f0104680 <debuginfo_eip+0x227>
f0104697:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f010469b:	74 e3                	je     f0104680 <debuginfo_eip+0x227>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010469d:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01046a0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01046a3:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01046a6:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01046a9:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01046ac:	29 f8                	sub    %edi,%eax
f01046ae:	39 c2                	cmp    %eax,%edx
f01046b0:	73 06                	jae    f01046b8 <debuginfo_eip+0x25f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01046b2:	89 f8                	mov    %edi,%eax
f01046b4:	01 d0                	add    %edx,%eax
f01046b6:	89 06                	mov    %eax,(%esi)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01046b8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01046bd:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01046c0:	8b 5d b0             	mov    -0x50(%ebp),%ebx
f01046c3:	39 df                	cmp    %ebx,%edi
f01046c5:	7d 56                	jge    f010471d <debuginfo_eip+0x2c4>
		for (lline = lfun + 1;
f01046c7:	83 c7 01             	add    $0x1,%edi
f01046ca:	89 f8                	mov    %edi,%eax
f01046cc:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f01046cf:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01046d2:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01046d6:	eb 04                	jmp    f01046dc <debuginfo_eip+0x283>
			info->eip_fn_narg++;
f01046d8:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01046dc:	39 c3                	cmp    %eax,%ebx
f01046de:	7e 38                	jle    f0104718 <debuginfo_eip+0x2bf>
f01046e0:	0f b6 0a             	movzbl (%edx),%ecx
f01046e3:	83 c0 01             	add    $0x1,%eax
f01046e6:	83 c2 0c             	add    $0xc,%edx
f01046e9:	80 f9 a0             	cmp    $0xa0,%cl
f01046ec:	74 ea                	je     f01046d8 <debuginfo_eip+0x27f>
	return 0;
f01046ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01046f3:	eb 28                	jmp    f010471d <debuginfo_eip+0x2c4>
			return -1;
f01046f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01046fa:	eb 21                	jmp    f010471d <debuginfo_eip+0x2c4>
			return -1;
f01046fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104701:	eb 1a                	jmp    f010471d <debuginfo_eip+0x2c4>
		return -1;
f0104703:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104708:	eb 13                	jmp    f010471d <debuginfo_eip+0x2c4>
f010470a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010470f:	eb 0c                	jmp    f010471d <debuginfo_eip+0x2c4>
		return -1;
f0104711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104716:	eb 05                	jmp    f010471d <debuginfo_eip+0x2c4>
	return 0;
f0104718:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010471d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104720:	5b                   	pop    %ebx
f0104721:	5e                   	pop    %esi
f0104722:	5f                   	pop    %edi
f0104723:	5d                   	pop    %ebp
f0104724:	c3                   	ret    

f0104725 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104725:	55                   	push   %ebp
f0104726:	89 e5                	mov    %esp,%ebp
f0104728:	57                   	push   %edi
f0104729:	56                   	push   %esi
f010472a:	53                   	push   %ebx
f010472b:	83 ec 2c             	sub    $0x2c,%esp
f010472e:	e8 df eb ff ff       	call   f0103312 <__x86.get_pc_thunk.cx>
f0104733:	81 c1 f9 b1 07 00    	add    $0x7b1f9,%ecx
f0104739:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010473c:	89 c7                	mov    %eax,%edi
f010473e:	89 d6                	mov    %edx,%esi
f0104740:	8b 45 08             	mov    0x8(%ebp),%eax
f0104743:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104746:	89 d1                	mov    %edx,%ecx
f0104748:	89 c2                	mov    %eax,%edx
f010474a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010474d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104750:	8b 45 10             	mov    0x10(%ebp),%eax
f0104753:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104756:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104759:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104760:	39 c2                	cmp    %eax,%edx
f0104762:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0104765:	72 41                	jb     f01047a8 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104767:	83 ec 0c             	sub    $0xc,%esp
f010476a:	ff 75 18             	push   0x18(%ebp)
f010476d:	83 eb 01             	sub    $0x1,%ebx
f0104770:	53                   	push   %ebx
f0104771:	50                   	push   %eax
f0104772:	83 ec 08             	sub    $0x8,%esp
f0104775:	ff 75 e4             	push   -0x1c(%ebp)
f0104778:	ff 75 e0             	push   -0x20(%ebp)
f010477b:	ff 75 d4             	push   -0x2c(%ebp)
f010477e:	ff 75 d0             	push   -0x30(%ebp)
f0104781:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104784:	e8 37 0a 00 00       	call   f01051c0 <__udivdi3>
f0104789:	83 c4 18             	add    $0x18,%esp
f010478c:	52                   	push   %edx
f010478d:	50                   	push   %eax
f010478e:	89 f2                	mov    %esi,%edx
f0104790:	89 f8                	mov    %edi,%eax
f0104792:	e8 8e ff ff ff       	call   f0104725 <printnum>
f0104797:	83 c4 20             	add    $0x20,%esp
f010479a:	eb 13                	jmp    f01047af <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010479c:	83 ec 08             	sub    $0x8,%esp
f010479f:	56                   	push   %esi
f01047a0:	ff 75 18             	push   0x18(%ebp)
f01047a3:	ff d7                	call   *%edi
f01047a5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01047a8:	83 eb 01             	sub    $0x1,%ebx
f01047ab:	85 db                	test   %ebx,%ebx
f01047ad:	7f ed                	jg     f010479c <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01047af:	83 ec 08             	sub    $0x8,%esp
f01047b2:	56                   	push   %esi
f01047b3:	83 ec 04             	sub    $0x4,%esp
f01047b6:	ff 75 e4             	push   -0x1c(%ebp)
f01047b9:	ff 75 e0             	push   -0x20(%ebp)
f01047bc:	ff 75 d4             	push   -0x2c(%ebp)
f01047bf:	ff 75 d0             	push   -0x30(%ebp)
f01047c2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01047c5:	e8 16 0b 00 00       	call   f01052e0 <__umoddi3>
f01047ca:	83 c4 14             	add    $0x14,%esp
f01047cd:	0f be 84 03 ba 6f f8 	movsbl -0x79046(%ebx,%eax,1),%eax
f01047d4:	ff 
f01047d5:	50                   	push   %eax
f01047d6:	ff d7                	call   *%edi
}
f01047d8:	83 c4 10             	add    $0x10,%esp
f01047db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01047de:	5b                   	pop    %ebx
f01047df:	5e                   	pop    %esi
f01047e0:	5f                   	pop    %edi
f01047e1:	5d                   	pop    %ebp
f01047e2:	c3                   	ret    

f01047e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01047e3:	55                   	push   %ebp
f01047e4:	89 e5                	mov    %esp,%ebp
f01047e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01047e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01047ed:	8b 10                	mov    (%eax),%edx
f01047ef:	3b 50 04             	cmp    0x4(%eax),%edx
f01047f2:	73 0a                	jae    f01047fe <sprintputch+0x1b>
		*b->buf++ = ch;
f01047f4:	8d 4a 01             	lea    0x1(%edx),%ecx
f01047f7:	89 08                	mov    %ecx,(%eax)
f01047f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01047fc:	88 02                	mov    %al,(%edx)
}
f01047fe:	5d                   	pop    %ebp
f01047ff:	c3                   	ret    

f0104800 <printfmt>:
{
f0104800:	55                   	push   %ebp
f0104801:	89 e5                	mov    %esp,%ebp
f0104803:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104806:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104809:	50                   	push   %eax
f010480a:	ff 75 10             	push   0x10(%ebp)
f010480d:	ff 75 0c             	push   0xc(%ebp)
f0104810:	ff 75 08             	push   0x8(%ebp)
f0104813:	e8 05 00 00 00       	call   f010481d <vprintfmt>
}
f0104818:	83 c4 10             	add    $0x10,%esp
f010481b:	c9                   	leave  
f010481c:	c3                   	ret    

f010481d <vprintfmt>:
{
f010481d:	55                   	push   %ebp
f010481e:	89 e5                	mov    %esp,%ebp
f0104820:	57                   	push   %edi
f0104821:	56                   	push   %esi
f0104822:	53                   	push   %ebx
f0104823:	83 ec 3c             	sub    $0x3c,%esp
f0104826:	e8 dc be ff ff       	call   f0100707 <__x86.get_pc_thunk.ax>
f010482b:	05 01 b1 07 00       	add    $0x7b101,%eax
f0104830:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104833:	8b 75 08             	mov    0x8(%ebp),%esi
f0104836:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104839:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010483c:	8d 80 a4 17 00 00    	lea    0x17a4(%eax),%eax
f0104842:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104845:	eb 0a                	jmp    f0104851 <vprintfmt+0x34>
			putch(ch, putdat);
f0104847:	83 ec 08             	sub    $0x8,%esp
f010484a:	57                   	push   %edi
f010484b:	50                   	push   %eax
f010484c:	ff d6                	call   *%esi
f010484e:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104851:	83 c3 01             	add    $0x1,%ebx
f0104854:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0104858:	83 f8 25             	cmp    $0x25,%eax
f010485b:	74 0c                	je     f0104869 <vprintfmt+0x4c>
			if (ch == '\0')
f010485d:	85 c0                	test   %eax,%eax
f010485f:	75 e6                	jne    f0104847 <vprintfmt+0x2a>
}
f0104861:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104864:	5b                   	pop    %ebx
f0104865:	5e                   	pop    %esi
f0104866:	5f                   	pop    %edi
f0104867:	5d                   	pop    %ebp
f0104868:	c3                   	ret    
		padc = ' ';
f0104869:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f010486d:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0104874:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010487b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0104882:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104887:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010488a:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010488d:	8d 43 01             	lea    0x1(%ebx),%eax
f0104890:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104893:	0f b6 13             	movzbl (%ebx),%edx
f0104896:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104899:	3c 55                	cmp    $0x55,%al
f010489b:	0f 87 fd 03 00 00    	ja     f0104c9e <.L20>
f01048a1:	0f b6 c0             	movzbl %al,%eax
f01048a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01048a7:	89 ce                	mov    %ecx,%esi
f01048a9:	03 b4 81 44 70 f8 ff 	add    -0x78fbc(%ecx,%eax,4),%esi
f01048b0:	ff e6                	jmp    *%esi

f01048b2 <.L68>:
f01048b2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01048b5:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01048b9:	eb d2                	jmp    f010488d <vprintfmt+0x70>

f01048bb <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01048bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01048be:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01048c2:	eb c9                	jmp    f010488d <vprintfmt+0x70>

f01048c4 <.L31>:
f01048c4:	0f b6 d2             	movzbl %dl,%edx
f01048c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01048ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01048cf:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01048d2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01048d5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01048d9:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01048dc:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01048df:	83 f9 09             	cmp    $0x9,%ecx
f01048e2:	77 58                	ja     f010493c <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01048e4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01048e7:	eb e9                	jmp    f01048d2 <.L31+0xe>

f01048e9 <.L34>:
			precision = va_arg(ap, int);
f01048e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01048ec:	8b 00                	mov    (%eax),%eax
f01048ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01048f4:	8d 40 04             	lea    0x4(%eax),%eax
f01048f7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01048fa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01048fd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104901:	79 8a                	jns    f010488d <vprintfmt+0x70>
				width = precision, precision = -1;
f0104903:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104906:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104909:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104910:	e9 78 ff ff ff       	jmp    f010488d <vprintfmt+0x70>

f0104915 <.L33>:
f0104915:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104918:	85 d2                	test   %edx,%edx
f010491a:	b8 00 00 00 00       	mov    $0x0,%eax
f010491f:	0f 49 c2             	cmovns %edx,%eax
f0104922:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104925:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0104928:	e9 60 ff ff ff       	jmp    f010488d <vprintfmt+0x70>

f010492d <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f010492d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0104930:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0104937:	e9 51 ff ff ff       	jmp    f010488d <vprintfmt+0x70>
f010493c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010493f:	89 75 08             	mov    %esi,0x8(%ebp)
f0104942:	eb b9                	jmp    f01048fd <.L34+0x14>

f0104944 <.L27>:
			lflag++;
f0104944:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104948:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010494b:	e9 3d ff ff ff       	jmp    f010488d <vprintfmt+0x70>

f0104950 <.L30>:
			putch(va_arg(ap, int), putdat);
f0104950:	8b 75 08             	mov    0x8(%ebp),%esi
f0104953:	8b 45 14             	mov    0x14(%ebp),%eax
f0104956:	8d 58 04             	lea    0x4(%eax),%ebx
f0104959:	83 ec 08             	sub    $0x8,%esp
f010495c:	57                   	push   %edi
f010495d:	ff 30                	push   (%eax)
f010495f:	ff d6                	call   *%esi
			break;
f0104961:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104964:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0104967:	e9 c8 02 00 00       	jmp    f0104c34 <.L25+0x45>

f010496c <.L28>:
			err = va_arg(ap, int);
f010496c:	8b 75 08             	mov    0x8(%ebp),%esi
f010496f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104972:	8d 58 04             	lea    0x4(%eax),%ebx
f0104975:	8b 10                	mov    (%eax),%edx
f0104977:	89 d0                	mov    %edx,%eax
f0104979:	f7 d8                	neg    %eax
f010497b:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010497e:	83 f8 06             	cmp    $0x6,%eax
f0104981:	7f 27                	jg     f01049aa <.L28+0x3e>
f0104983:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104986:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0104989:	85 d2                	test   %edx,%edx
f010498b:	74 1d                	je     f01049aa <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f010498d:	52                   	push   %edx
f010498e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104991:	8d 80 40 68 f8 ff    	lea    -0x797c0(%eax),%eax
f0104997:	50                   	push   %eax
f0104998:	57                   	push   %edi
f0104999:	56                   	push   %esi
f010499a:	e8 61 fe ff ff       	call   f0104800 <printfmt>
f010499f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01049a2:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01049a5:	e9 8a 02 00 00       	jmp    f0104c34 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f01049aa:	50                   	push   %eax
f01049ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049ae:	8d 80 d2 6f f8 ff    	lea    -0x7902e(%eax),%eax
f01049b4:	50                   	push   %eax
f01049b5:	57                   	push   %edi
f01049b6:	56                   	push   %esi
f01049b7:	e8 44 fe ff ff       	call   f0104800 <printfmt>
f01049bc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01049bf:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01049c2:	e9 6d 02 00 00       	jmp    f0104c34 <.L25+0x45>

f01049c7 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01049c7:	8b 75 08             	mov    0x8(%ebp),%esi
f01049ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01049cd:	83 c0 04             	add    $0x4,%eax
f01049d0:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01049d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01049d6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01049d8:	85 d2                	test   %edx,%edx
f01049da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049dd:	8d 80 cb 6f f8 ff    	lea    -0x79035(%eax),%eax
f01049e3:	0f 45 c2             	cmovne %edx,%eax
f01049e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01049e9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01049ed:	7e 06                	jle    f01049f5 <.L24+0x2e>
f01049ef:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01049f3:	75 0d                	jne    f0104a02 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01049f5:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01049f8:	89 c3                	mov    %eax,%ebx
f01049fa:	03 45 d4             	add    -0x2c(%ebp),%eax
f01049fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104a00:	eb 58                	jmp    f0104a5a <.L24+0x93>
f0104a02:	83 ec 08             	sub    $0x8,%esp
f0104a05:	ff 75 d8             	push   -0x28(%ebp)
f0104a08:	ff 75 c8             	push   -0x38(%ebp)
f0104a0b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104a0e:	e8 44 04 00 00       	call   f0104e57 <strnlen>
f0104a13:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104a16:	29 c2                	sub    %eax,%edx
f0104a18:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0104a1b:	83 c4 10             	add    $0x10,%esp
f0104a1e:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0104a20:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104a24:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104a27:	eb 0f                	jmp    f0104a38 <.L24+0x71>
					putch(padc, putdat);
f0104a29:	83 ec 08             	sub    $0x8,%esp
f0104a2c:	57                   	push   %edi
f0104a2d:	ff 75 d4             	push   -0x2c(%ebp)
f0104a30:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104a32:	83 eb 01             	sub    $0x1,%ebx
f0104a35:	83 c4 10             	add    $0x10,%esp
f0104a38:	85 db                	test   %ebx,%ebx
f0104a3a:	7f ed                	jg     f0104a29 <.L24+0x62>
f0104a3c:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104a3f:	85 d2                	test   %edx,%edx
f0104a41:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a46:	0f 49 c2             	cmovns %edx,%eax
f0104a49:	29 c2                	sub    %eax,%edx
f0104a4b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104a4e:	eb a5                	jmp    f01049f5 <.L24+0x2e>
					putch(ch, putdat);
f0104a50:	83 ec 08             	sub    $0x8,%esp
f0104a53:	57                   	push   %edi
f0104a54:	52                   	push   %edx
f0104a55:	ff d6                	call   *%esi
f0104a57:	83 c4 10             	add    $0x10,%esp
f0104a5a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104a5d:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104a5f:	83 c3 01             	add    $0x1,%ebx
f0104a62:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0104a66:	0f be d0             	movsbl %al,%edx
f0104a69:	85 d2                	test   %edx,%edx
f0104a6b:	74 4b                	je     f0104ab8 <.L24+0xf1>
f0104a6d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104a71:	78 06                	js     f0104a79 <.L24+0xb2>
f0104a73:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0104a77:	78 1e                	js     f0104a97 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0104a79:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104a7d:	74 d1                	je     f0104a50 <.L24+0x89>
f0104a7f:	0f be c0             	movsbl %al,%eax
f0104a82:	83 e8 20             	sub    $0x20,%eax
f0104a85:	83 f8 5e             	cmp    $0x5e,%eax
f0104a88:	76 c6                	jbe    f0104a50 <.L24+0x89>
					putch('?', putdat);
f0104a8a:	83 ec 08             	sub    $0x8,%esp
f0104a8d:	57                   	push   %edi
f0104a8e:	6a 3f                	push   $0x3f
f0104a90:	ff d6                	call   *%esi
f0104a92:	83 c4 10             	add    $0x10,%esp
f0104a95:	eb c3                	jmp    f0104a5a <.L24+0x93>
f0104a97:	89 cb                	mov    %ecx,%ebx
f0104a99:	eb 0e                	jmp    f0104aa9 <.L24+0xe2>
				putch(' ', putdat);
f0104a9b:	83 ec 08             	sub    $0x8,%esp
f0104a9e:	57                   	push   %edi
f0104a9f:	6a 20                	push   $0x20
f0104aa1:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104aa3:	83 eb 01             	sub    $0x1,%ebx
f0104aa6:	83 c4 10             	add    $0x10,%esp
f0104aa9:	85 db                	test   %ebx,%ebx
f0104aab:	7f ee                	jg     f0104a9b <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0104aad:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104ab0:	89 45 14             	mov    %eax,0x14(%ebp)
f0104ab3:	e9 7c 01 00 00       	jmp    f0104c34 <.L25+0x45>
f0104ab8:	89 cb                	mov    %ecx,%ebx
f0104aba:	eb ed                	jmp    f0104aa9 <.L24+0xe2>

f0104abc <.L29>:
	if (lflag >= 2)
f0104abc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104abf:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ac2:	83 f9 01             	cmp    $0x1,%ecx
f0104ac5:	7f 1b                	jg     f0104ae2 <.L29+0x26>
	else if (lflag)
f0104ac7:	85 c9                	test   %ecx,%ecx
f0104ac9:	74 63                	je     f0104b2e <.L29+0x72>
		return va_arg(*ap, long);
f0104acb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ace:	8b 00                	mov    (%eax),%eax
f0104ad0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ad3:	99                   	cltd   
f0104ad4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104ad7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ada:	8d 40 04             	lea    0x4(%eax),%eax
f0104add:	89 45 14             	mov    %eax,0x14(%ebp)
f0104ae0:	eb 17                	jmp    f0104af9 <.L29+0x3d>
		return va_arg(*ap, long long);
f0104ae2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ae5:	8b 50 04             	mov    0x4(%eax),%edx
f0104ae8:	8b 00                	mov    (%eax),%eax
f0104aea:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104aed:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104af0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104af3:	8d 40 08             	lea    0x8(%eax),%eax
f0104af6:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104af9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104afc:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f0104aff:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f0104b04:	85 db                	test   %ebx,%ebx
f0104b06:	0f 89 0e 01 00 00    	jns    f0104c1a <.L25+0x2b>
				putch('-', putdat);
f0104b0c:	83 ec 08             	sub    $0x8,%esp
f0104b0f:	57                   	push   %edi
f0104b10:	6a 2d                	push   $0x2d
f0104b12:	ff d6                	call   *%esi
				num = -(long long) num;
f0104b14:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104b17:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104b1a:	f7 d9                	neg    %ecx
f0104b1c:	83 d3 00             	adc    $0x0,%ebx
f0104b1f:	f7 db                	neg    %ebx
f0104b21:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104b24:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104b29:	e9 ec 00 00 00       	jmp    f0104c1a <.L25+0x2b>
		return va_arg(*ap, int);
f0104b2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b31:	8b 00                	mov    (%eax),%eax
f0104b33:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104b36:	99                   	cltd   
f0104b37:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104b3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b3d:	8d 40 04             	lea    0x4(%eax),%eax
f0104b40:	89 45 14             	mov    %eax,0x14(%ebp)
f0104b43:	eb b4                	jmp    f0104af9 <.L29+0x3d>

f0104b45 <.L23>:
	if (lflag >= 2)
f0104b45:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104b48:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b4b:	83 f9 01             	cmp    $0x1,%ecx
f0104b4e:	7f 1e                	jg     f0104b6e <.L23+0x29>
	else if (lflag)
f0104b50:	85 c9                	test   %ecx,%ecx
f0104b52:	74 32                	je     f0104b86 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0104b54:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b57:	8b 08                	mov    (%eax),%ecx
f0104b59:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b5e:	8d 40 04             	lea    0x4(%eax),%eax
f0104b61:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104b64:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0104b69:	e9 ac 00 00 00       	jmp    f0104c1a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104b6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b71:	8b 08                	mov    (%eax),%ecx
f0104b73:	8b 58 04             	mov    0x4(%eax),%ebx
f0104b76:	8d 40 08             	lea    0x8(%eax),%eax
f0104b79:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104b7c:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0104b81:	e9 94 00 00 00       	jmp    f0104c1a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104b86:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b89:	8b 08                	mov    (%eax),%ecx
f0104b8b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b90:	8d 40 04             	lea    0x4(%eax),%eax
f0104b93:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104b96:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0104b9b:	eb 7d                	jmp    f0104c1a <.L25+0x2b>

f0104b9d <.L26>:
	if (lflag >= 2)
f0104b9d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104ba0:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ba3:	83 f9 01             	cmp    $0x1,%ecx
f0104ba6:	7f 1b                	jg     f0104bc3 <.L26+0x26>
	else if (lflag)
f0104ba8:	85 c9                	test   %ecx,%ecx
f0104baa:	74 2c                	je     f0104bd8 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f0104bac:	8b 45 14             	mov    0x14(%ebp),%eax
f0104baf:	8b 08                	mov    (%eax),%ecx
f0104bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104bb6:	8d 40 04             	lea    0x4(%eax),%eax
f0104bb9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104bbc:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f0104bc1:	eb 57                	jmp    f0104c1a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104bc3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bc6:	8b 08                	mov    (%eax),%ecx
f0104bc8:	8b 58 04             	mov    0x4(%eax),%ebx
f0104bcb:	8d 40 08             	lea    0x8(%eax),%eax
f0104bce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104bd1:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f0104bd6:	eb 42                	jmp    f0104c1a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104bd8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bdb:	8b 08                	mov    (%eax),%ecx
f0104bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104be2:	8d 40 04             	lea    0x4(%eax),%eax
f0104be5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104be8:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f0104bed:	eb 2b                	jmp    f0104c1a <.L25+0x2b>

f0104bef <.L25>:
			putch('0', putdat);
f0104bef:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bf2:	83 ec 08             	sub    $0x8,%esp
f0104bf5:	57                   	push   %edi
f0104bf6:	6a 30                	push   $0x30
f0104bf8:	ff d6                	call   *%esi
			putch('x', putdat);
f0104bfa:	83 c4 08             	add    $0x8,%esp
f0104bfd:	57                   	push   %edi
f0104bfe:	6a 78                	push   $0x78
f0104c00:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104c02:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c05:	8b 08                	mov    (%eax),%ecx
f0104c07:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0104c0c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104c0f:	8d 40 04             	lea    0x4(%eax),%eax
f0104c12:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104c15:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0104c1a:	83 ec 0c             	sub    $0xc,%esp
f0104c1d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104c21:	50                   	push   %eax
f0104c22:	ff 75 d4             	push   -0x2c(%ebp)
f0104c25:	52                   	push   %edx
f0104c26:	53                   	push   %ebx
f0104c27:	51                   	push   %ecx
f0104c28:	89 fa                	mov    %edi,%edx
f0104c2a:	89 f0                	mov    %esi,%eax
f0104c2c:	e8 f4 fa ff ff       	call   f0104725 <printnum>
			break;
f0104c31:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104c34:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104c37:	e9 15 fc ff ff       	jmp    f0104851 <vprintfmt+0x34>

f0104c3c <.L21>:
	if (lflag >= 2)
f0104c3c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104c3f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c42:	83 f9 01             	cmp    $0x1,%ecx
f0104c45:	7f 1b                	jg     f0104c62 <.L21+0x26>
	else if (lflag)
f0104c47:	85 c9                	test   %ecx,%ecx
f0104c49:	74 2c                	je     f0104c77 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0104c4b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c4e:	8b 08                	mov    (%eax),%ecx
f0104c50:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c55:	8d 40 04             	lea    0x4(%eax),%eax
f0104c58:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104c5b:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f0104c60:	eb b8                	jmp    f0104c1a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104c62:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c65:	8b 08                	mov    (%eax),%ecx
f0104c67:	8b 58 04             	mov    0x4(%eax),%ebx
f0104c6a:	8d 40 08             	lea    0x8(%eax),%eax
f0104c6d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104c70:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0104c75:	eb a3                	jmp    f0104c1a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104c77:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c7a:	8b 08                	mov    (%eax),%ecx
f0104c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c81:	8d 40 04             	lea    0x4(%eax),%eax
f0104c84:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104c87:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0104c8c:	eb 8c                	jmp    f0104c1a <.L25+0x2b>

f0104c8e <.L35>:
			putch(ch, putdat);
f0104c8e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c91:	83 ec 08             	sub    $0x8,%esp
f0104c94:	57                   	push   %edi
f0104c95:	6a 25                	push   $0x25
f0104c97:	ff d6                	call   *%esi
			break;
f0104c99:	83 c4 10             	add    $0x10,%esp
f0104c9c:	eb 96                	jmp    f0104c34 <.L25+0x45>

f0104c9e <.L20>:
			putch('%', putdat);
f0104c9e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ca1:	83 ec 08             	sub    $0x8,%esp
f0104ca4:	57                   	push   %edi
f0104ca5:	6a 25                	push   $0x25
f0104ca7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104ca9:	83 c4 10             	add    $0x10,%esp
f0104cac:	89 d8                	mov    %ebx,%eax
f0104cae:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104cb2:	74 05                	je     f0104cb9 <.L20+0x1b>
f0104cb4:	83 e8 01             	sub    $0x1,%eax
f0104cb7:	eb f5                	jmp    f0104cae <.L20+0x10>
f0104cb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104cbc:	e9 73 ff ff ff       	jmp    f0104c34 <.L25+0x45>

f0104cc1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104cc1:	55                   	push   %ebp
f0104cc2:	89 e5                	mov    %esp,%ebp
f0104cc4:	53                   	push   %ebx
f0104cc5:	83 ec 14             	sub    $0x14,%esp
f0104cc8:	e8 a8 b4 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0104ccd:	81 c3 5f ac 07 00    	add    $0x7ac5f,%ebx
f0104cd3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cd6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104cd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104cdc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104ce0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104ce3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104cea:	85 c0                	test   %eax,%eax
f0104cec:	74 2b                	je     f0104d19 <vsnprintf+0x58>
f0104cee:	85 d2                	test   %edx,%edx
f0104cf0:	7e 27                	jle    f0104d19 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104cf2:	ff 75 14             	push   0x14(%ebp)
f0104cf5:	ff 75 10             	push   0x10(%ebp)
f0104cf8:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104cfb:	50                   	push   %eax
f0104cfc:	8d 83 b7 4e f8 ff    	lea    -0x7b149(%ebx),%eax
f0104d02:	50                   	push   %eax
f0104d03:	e8 15 fb ff ff       	call   f010481d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104d08:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104d0b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d11:	83 c4 10             	add    $0x10,%esp
}
f0104d14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104d17:	c9                   	leave  
f0104d18:	c3                   	ret    
		return -E_INVAL;
f0104d19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d1e:	eb f4                	jmp    f0104d14 <vsnprintf+0x53>

f0104d20 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104d20:	55                   	push   %ebp
f0104d21:	89 e5                	mov    %esp,%ebp
f0104d23:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104d26:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104d29:	50                   	push   %eax
f0104d2a:	ff 75 10             	push   0x10(%ebp)
f0104d2d:	ff 75 0c             	push   0xc(%ebp)
f0104d30:	ff 75 08             	push   0x8(%ebp)
f0104d33:	e8 89 ff ff ff       	call   f0104cc1 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104d38:	c9                   	leave  
f0104d39:	c3                   	ret    

f0104d3a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104d3a:	55                   	push   %ebp
f0104d3b:	89 e5                	mov    %esp,%ebp
f0104d3d:	57                   	push   %edi
f0104d3e:	56                   	push   %esi
f0104d3f:	53                   	push   %ebx
f0104d40:	83 ec 1c             	sub    $0x1c,%esp
f0104d43:	e8 2d b4 ff ff       	call   f0100175 <__x86.get_pc_thunk.bx>
f0104d48:	81 c3 e4 ab 07 00    	add    $0x7abe4,%ebx
f0104d4e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104d51:	85 c0                	test   %eax,%eax
f0104d53:	74 13                	je     f0104d68 <readline+0x2e>
		cprintf("%s", prompt);
f0104d55:	83 ec 08             	sub    $0x8,%esp
f0104d58:	50                   	push   %eax
f0104d59:	8d 83 40 68 f8 ff    	lea    -0x797c0(%ebx),%eax
f0104d5f:	50                   	push   %eax
f0104d60:	e8 bc ed ff ff       	call   f0103b21 <cprintf>
f0104d65:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104d68:	83 ec 0c             	sub    $0xc,%esp
f0104d6b:	6a 00                	push   $0x0
f0104d6d:	e8 8f b9 ff ff       	call   f0100701 <iscons>
f0104d72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d75:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104d78:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0104d7d:	8d 83 f4 22 00 00    	lea    0x22f4(%ebx),%eax
f0104d83:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104d86:	eb 45                	jmp    f0104dcd <readline+0x93>
			cprintf("read error: %e\n", c);
f0104d88:	83 ec 08             	sub    $0x8,%esp
f0104d8b:	50                   	push   %eax
f0104d8c:	8d 83 9c 71 f8 ff    	lea    -0x78e64(%ebx),%eax
f0104d92:	50                   	push   %eax
f0104d93:	e8 89 ed ff ff       	call   f0103b21 <cprintf>
			return NULL;
f0104d98:	83 c4 10             	add    $0x10,%esp
f0104d9b:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104da3:	5b                   	pop    %ebx
f0104da4:	5e                   	pop    %esi
f0104da5:	5f                   	pop    %edi
f0104da6:	5d                   	pop    %ebp
f0104da7:	c3                   	ret    
			if (echoing)
f0104da8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104dac:	75 05                	jne    f0104db3 <readline+0x79>
			i--;
f0104dae:	83 ef 01             	sub    $0x1,%edi
f0104db1:	eb 1a                	jmp    f0104dcd <readline+0x93>
				cputchar('\b');
f0104db3:	83 ec 0c             	sub    $0xc,%esp
f0104db6:	6a 08                	push   $0x8
f0104db8:	e8 23 b9 ff ff       	call   f01006e0 <cputchar>
f0104dbd:	83 c4 10             	add    $0x10,%esp
f0104dc0:	eb ec                	jmp    f0104dae <readline+0x74>
			buf[i++] = c;
f0104dc2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104dc5:	89 f0                	mov    %esi,%eax
f0104dc7:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0104dca:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104dcd:	e8 1e b9 ff ff       	call   f01006f0 <getchar>
f0104dd2:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104dd4:	85 c0                	test   %eax,%eax
f0104dd6:	78 b0                	js     f0104d88 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104dd8:	83 f8 08             	cmp    $0x8,%eax
f0104ddb:	0f 94 c0             	sete   %al
f0104dde:	83 fe 7f             	cmp    $0x7f,%esi
f0104de1:	0f 94 c2             	sete   %dl
f0104de4:	08 d0                	or     %dl,%al
f0104de6:	74 04                	je     f0104dec <readline+0xb2>
f0104de8:	85 ff                	test   %edi,%edi
f0104dea:	7f bc                	jg     f0104da8 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104dec:	83 fe 1f             	cmp    $0x1f,%esi
f0104def:	7e 1c                	jle    f0104e0d <readline+0xd3>
f0104df1:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104df7:	7f 14                	jg     f0104e0d <readline+0xd3>
			if (echoing)
f0104df9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104dfd:	74 c3                	je     f0104dc2 <readline+0x88>
				cputchar(c);
f0104dff:	83 ec 0c             	sub    $0xc,%esp
f0104e02:	56                   	push   %esi
f0104e03:	e8 d8 b8 ff ff       	call   f01006e0 <cputchar>
f0104e08:	83 c4 10             	add    $0x10,%esp
f0104e0b:	eb b5                	jmp    f0104dc2 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0104e0d:	83 fe 0a             	cmp    $0xa,%esi
f0104e10:	74 05                	je     f0104e17 <readline+0xdd>
f0104e12:	83 fe 0d             	cmp    $0xd,%esi
f0104e15:	75 b6                	jne    f0104dcd <readline+0x93>
			if (echoing)
f0104e17:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104e1b:	75 13                	jne    f0104e30 <readline+0xf6>
			buf[i] = 0;
f0104e1d:	c6 84 3b f4 22 00 00 	movb   $0x0,0x22f4(%ebx,%edi,1)
f0104e24:	00 
			return buf;
f0104e25:	8d 83 f4 22 00 00    	lea    0x22f4(%ebx),%eax
f0104e2b:	e9 70 ff ff ff       	jmp    f0104da0 <readline+0x66>
				cputchar('\n');
f0104e30:	83 ec 0c             	sub    $0xc,%esp
f0104e33:	6a 0a                	push   $0xa
f0104e35:	e8 a6 b8 ff ff       	call   f01006e0 <cputchar>
f0104e3a:	83 c4 10             	add    $0x10,%esp
f0104e3d:	eb de                	jmp    f0104e1d <readline+0xe3>

f0104e3f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104e3f:	55                   	push   %ebp
f0104e40:	89 e5                	mov    %esp,%ebp
f0104e42:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104e45:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e4a:	eb 03                	jmp    f0104e4f <strlen+0x10>
		n++;
f0104e4c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104e4f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104e53:	75 f7                	jne    f0104e4c <strlen+0xd>
	return n;
}
f0104e55:	5d                   	pop    %ebp
f0104e56:	c3                   	ret    

f0104e57 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104e57:	55                   	push   %ebp
f0104e58:	89 e5                	mov    %esp,%ebp
f0104e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104e5d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104e60:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e65:	eb 03                	jmp    f0104e6a <strnlen+0x13>
		n++;
f0104e67:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104e6a:	39 d0                	cmp    %edx,%eax
f0104e6c:	74 08                	je     f0104e76 <strnlen+0x1f>
f0104e6e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104e72:	75 f3                	jne    f0104e67 <strnlen+0x10>
f0104e74:	89 c2                	mov    %eax,%edx
	return n;
}
f0104e76:	89 d0                	mov    %edx,%eax
f0104e78:	5d                   	pop    %ebp
f0104e79:	c3                   	ret    

f0104e7a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104e7a:	55                   	push   %ebp
f0104e7b:	89 e5                	mov    %esp,%ebp
f0104e7d:	53                   	push   %ebx
f0104e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104e81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104e84:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e89:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0104e8d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0104e90:	83 c0 01             	add    $0x1,%eax
f0104e93:	84 d2                	test   %dl,%dl
f0104e95:	75 f2                	jne    f0104e89 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104e97:	89 c8                	mov    %ecx,%eax
f0104e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104e9c:	c9                   	leave  
f0104e9d:	c3                   	ret    

f0104e9e <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104e9e:	55                   	push   %ebp
f0104e9f:	89 e5                	mov    %esp,%ebp
f0104ea1:	53                   	push   %ebx
f0104ea2:	83 ec 10             	sub    $0x10,%esp
f0104ea5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104ea8:	53                   	push   %ebx
f0104ea9:	e8 91 ff ff ff       	call   f0104e3f <strlen>
f0104eae:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104eb1:	ff 75 0c             	push   0xc(%ebp)
f0104eb4:	01 d8                	add    %ebx,%eax
f0104eb6:	50                   	push   %eax
f0104eb7:	e8 be ff ff ff       	call   f0104e7a <strcpy>
	return dst;
}
f0104ebc:	89 d8                	mov    %ebx,%eax
f0104ebe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104ec1:	c9                   	leave  
f0104ec2:	c3                   	ret    

f0104ec3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104ec3:	55                   	push   %ebp
f0104ec4:	89 e5                	mov    %esp,%ebp
f0104ec6:	56                   	push   %esi
f0104ec7:	53                   	push   %ebx
f0104ec8:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ece:	89 f3                	mov    %esi,%ebx
f0104ed0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104ed3:	89 f0                	mov    %esi,%eax
f0104ed5:	eb 0f                	jmp    f0104ee6 <strncpy+0x23>
		*dst++ = *src;
f0104ed7:	83 c0 01             	add    $0x1,%eax
f0104eda:	0f b6 0a             	movzbl (%edx),%ecx
f0104edd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104ee0:	80 f9 01             	cmp    $0x1,%cl
f0104ee3:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0104ee6:	39 d8                	cmp    %ebx,%eax
f0104ee8:	75 ed                	jne    f0104ed7 <strncpy+0x14>
	}
	return ret;
}
f0104eea:	89 f0                	mov    %esi,%eax
f0104eec:	5b                   	pop    %ebx
f0104eed:	5e                   	pop    %esi
f0104eee:	5d                   	pop    %ebp
f0104eef:	c3                   	ret    

f0104ef0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104ef0:	55                   	push   %ebp
f0104ef1:	89 e5                	mov    %esp,%ebp
f0104ef3:	56                   	push   %esi
f0104ef4:	53                   	push   %ebx
f0104ef5:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104efb:	8b 55 10             	mov    0x10(%ebp),%edx
f0104efe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104f00:	85 d2                	test   %edx,%edx
f0104f02:	74 21                	je     f0104f25 <strlcpy+0x35>
f0104f04:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104f08:	89 f2                	mov    %esi,%edx
f0104f0a:	eb 09                	jmp    f0104f15 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104f0c:	83 c1 01             	add    $0x1,%ecx
f0104f0f:	83 c2 01             	add    $0x1,%edx
f0104f12:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0104f15:	39 c2                	cmp    %eax,%edx
f0104f17:	74 09                	je     f0104f22 <strlcpy+0x32>
f0104f19:	0f b6 19             	movzbl (%ecx),%ebx
f0104f1c:	84 db                	test   %bl,%bl
f0104f1e:	75 ec                	jne    f0104f0c <strlcpy+0x1c>
f0104f20:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104f22:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104f25:	29 f0                	sub    %esi,%eax
}
f0104f27:	5b                   	pop    %ebx
f0104f28:	5e                   	pop    %esi
f0104f29:	5d                   	pop    %ebp
f0104f2a:	c3                   	ret    

f0104f2b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104f2b:	55                   	push   %ebp
f0104f2c:	89 e5                	mov    %esp,%ebp
f0104f2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f31:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104f34:	eb 06                	jmp    f0104f3c <strcmp+0x11>
		p++, q++;
f0104f36:	83 c1 01             	add    $0x1,%ecx
f0104f39:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104f3c:	0f b6 01             	movzbl (%ecx),%eax
f0104f3f:	84 c0                	test   %al,%al
f0104f41:	74 04                	je     f0104f47 <strcmp+0x1c>
f0104f43:	3a 02                	cmp    (%edx),%al
f0104f45:	74 ef                	je     f0104f36 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104f47:	0f b6 c0             	movzbl %al,%eax
f0104f4a:	0f b6 12             	movzbl (%edx),%edx
f0104f4d:	29 d0                	sub    %edx,%eax
}
f0104f4f:	5d                   	pop    %ebp
f0104f50:	c3                   	ret    

f0104f51 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104f51:	55                   	push   %ebp
f0104f52:	89 e5                	mov    %esp,%ebp
f0104f54:	53                   	push   %ebx
f0104f55:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f58:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f5b:	89 c3                	mov    %eax,%ebx
f0104f5d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104f60:	eb 06                	jmp    f0104f68 <strncmp+0x17>
		n--, p++, q++;
f0104f62:	83 c0 01             	add    $0x1,%eax
f0104f65:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104f68:	39 d8                	cmp    %ebx,%eax
f0104f6a:	74 18                	je     f0104f84 <strncmp+0x33>
f0104f6c:	0f b6 08             	movzbl (%eax),%ecx
f0104f6f:	84 c9                	test   %cl,%cl
f0104f71:	74 04                	je     f0104f77 <strncmp+0x26>
f0104f73:	3a 0a                	cmp    (%edx),%cl
f0104f75:	74 eb                	je     f0104f62 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104f77:	0f b6 00             	movzbl (%eax),%eax
f0104f7a:	0f b6 12             	movzbl (%edx),%edx
f0104f7d:	29 d0                	sub    %edx,%eax
}
f0104f7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104f82:	c9                   	leave  
f0104f83:	c3                   	ret    
		return 0;
f0104f84:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f89:	eb f4                	jmp    f0104f7f <strncmp+0x2e>

f0104f8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104f8b:	55                   	push   %ebp
f0104f8c:	89 e5                	mov    %esp,%ebp
f0104f8e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104f95:	eb 03                	jmp    f0104f9a <strchr+0xf>
f0104f97:	83 c0 01             	add    $0x1,%eax
f0104f9a:	0f b6 10             	movzbl (%eax),%edx
f0104f9d:	84 d2                	test   %dl,%dl
f0104f9f:	74 06                	je     f0104fa7 <strchr+0x1c>
		if (*s == c)
f0104fa1:	38 ca                	cmp    %cl,%dl
f0104fa3:	75 f2                	jne    f0104f97 <strchr+0xc>
f0104fa5:	eb 05                	jmp    f0104fac <strchr+0x21>
			return (char *) s;
	return 0;
f0104fa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104fac:	5d                   	pop    %ebp
f0104fad:	c3                   	ret    

f0104fae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104fae:	55                   	push   %ebp
f0104faf:	89 e5                	mov    %esp,%ebp
f0104fb1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fb4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104fb8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104fbb:	38 ca                	cmp    %cl,%dl
f0104fbd:	74 09                	je     f0104fc8 <strfind+0x1a>
f0104fbf:	84 d2                	test   %dl,%dl
f0104fc1:	74 05                	je     f0104fc8 <strfind+0x1a>
	for (; *s; s++)
f0104fc3:	83 c0 01             	add    $0x1,%eax
f0104fc6:	eb f0                	jmp    f0104fb8 <strfind+0xa>
			break;
	return (char *) s;
}
f0104fc8:	5d                   	pop    %ebp
f0104fc9:	c3                   	ret    

f0104fca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104fca:	55                   	push   %ebp
f0104fcb:	89 e5                	mov    %esp,%ebp
f0104fcd:	57                   	push   %edi
f0104fce:	56                   	push   %esi
f0104fcf:	53                   	push   %ebx
f0104fd0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104fd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104fd6:	85 c9                	test   %ecx,%ecx
f0104fd8:	74 2f                	je     f0105009 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104fda:	89 f8                	mov    %edi,%eax
f0104fdc:	09 c8                	or     %ecx,%eax
f0104fde:	a8 03                	test   $0x3,%al
f0104fe0:	75 21                	jne    f0105003 <memset+0x39>
		c &= 0xFF;
f0104fe2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104fe6:	89 d0                	mov    %edx,%eax
f0104fe8:	c1 e0 08             	shl    $0x8,%eax
f0104feb:	89 d3                	mov    %edx,%ebx
f0104fed:	c1 e3 18             	shl    $0x18,%ebx
f0104ff0:	89 d6                	mov    %edx,%esi
f0104ff2:	c1 e6 10             	shl    $0x10,%esi
f0104ff5:	09 f3                	or     %esi,%ebx
f0104ff7:	09 da                	or     %ebx,%edx
f0104ff9:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104ffb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104ffe:	fc                   	cld    
f0104fff:	f3 ab                	rep stos %eax,%es:(%edi)
f0105001:	eb 06                	jmp    f0105009 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105003:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105006:	fc                   	cld    
f0105007:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105009:	89 f8                	mov    %edi,%eax
f010500b:	5b                   	pop    %ebx
f010500c:	5e                   	pop    %esi
f010500d:	5f                   	pop    %edi
f010500e:	5d                   	pop    %ebp
f010500f:	c3                   	ret    

f0105010 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105010:	55                   	push   %ebp
f0105011:	89 e5                	mov    %esp,%ebp
f0105013:	57                   	push   %edi
f0105014:	56                   	push   %esi
f0105015:	8b 45 08             	mov    0x8(%ebp),%eax
f0105018:	8b 75 0c             	mov    0xc(%ebp),%esi
f010501b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010501e:	39 c6                	cmp    %eax,%esi
f0105020:	73 32                	jae    f0105054 <memmove+0x44>
f0105022:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105025:	39 c2                	cmp    %eax,%edx
f0105027:	76 2b                	jbe    f0105054 <memmove+0x44>
		s += n;
		d += n;
f0105029:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010502c:	89 d6                	mov    %edx,%esi
f010502e:	09 fe                	or     %edi,%esi
f0105030:	09 ce                	or     %ecx,%esi
f0105032:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105038:	75 0e                	jne    f0105048 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010503a:	83 ef 04             	sub    $0x4,%edi
f010503d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105040:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105043:	fd                   	std    
f0105044:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105046:	eb 09                	jmp    f0105051 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105048:	83 ef 01             	sub    $0x1,%edi
f010504b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010504e:	fd                   	std    
f010504f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105051:	fc                   	cld    
f0105052:	eb 1a                	jmp    f010506e <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105054:	89 f2                	mov    %esi,%edx
f0105056:	09 c2                	or     %eax,%edx
f0105058:	09 ca                	or     %ecx,%edx
f010505a:	f6 c2 03             	test   $0x3,%dl
f010505d:	75 0a                	jne    f0105069 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010505f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105062:	89 c7                	mov    %eax,%edi
f0105064:	fc                   	cld    
f0105065:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105067:	eb 05                	jmp    f010506e <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0105069:	89 c7                	mov    %eax,%edi
f010506b:	fc                   	cld    
f010506c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010506e:	5e                   	pop    %esi
f010506f:	5f                   	pop    %edi
f0105070:	5d                   	pop    %ebp
f0105071:	c3                   	ret    

f0105072 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105072:	55                   	push   %ebp
f0105073:	89 e5                	mov    %esp,%ebp
f0105075:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105078:	ff 75 10             	push   0x10(%ebp)
f010507b:	ff 75 0c             	push   0xc(%ebp)
f010507e:	ff 75 08             	push   0x8(%ebp)
f0105081:	e8 8a ff ff ff       	call   f0105010 <memmove>
}
f0105086:	c9                   	leave  
f0105087:	c3                   	ret    

f0105088 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105088:	55                   	push   %ebp
f0105089:	89 e5                	mov    %esp,%ebp
f010508b:	56                   	push   %esi
f010508c:	53                   	push   %ebx
f010508d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105090:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105093:	89 c6                	mov    %eax,%esi
f0105095:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105098:	eb 06                	jmp    f01050a0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010509a:	83 c0 01             	add    $0x1,%eax
f010509d:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01050a0:	39 f0                	cmp    %esi,%eax
f01050a2:	74 14                	je     f01050b8 <memcmp+0x30>
		if (*s1 != *s2)
f01050a4:	0f b6 08             	movzbl (%eax),%ecx
f01050a7:	0f b6 1a             	movzbl (%edx),%ebx
f01050aa:	38 d9                	cmp    %bl,%cl
f01050ac:	74 ec                	je     f010509a <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01050ae:	0f b6 c1             	movzbl %cl,%eax
f01050b1:	0f b6 db             	movzbl %bl,%ebx
f01050b4:	29 d8                	sub    %ebx,%eax
f01050b6:	eb 05                	jmp    f01050bd <memcmp+0x35>
	}

	return 0;
f01050b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01050bd:	5b                   	pop    %ebx
f01050be:	5e                   	pop    %esi
f01050bf:	5d                   	pop    %ebp
f01050c0:	c3                   	ret    

f01050c1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01050c1:	55                   	push   %ebp
f01050c2:	89 e5                	mov    %esp,%ebp
f01050c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01050c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01050ca:	89 c2                	mov    %eax,%edx
f01050cc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01050cf:	eb 03                	jmp    f01050d4 <memfind+0x13>
f01050d1:	83 c0 01             	add    $0x1,%eax
f01050d4:	39 d0                	cmp    %edx,%eax
f01050d6:	73 04                	jae    f01050dc <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01050d8:	38 08                	cmp    %cl,(%eax)
f01050da:	75 f5                	jne    f01050d1 <memfind+0x10>
			break;
	return (void *) s;
}
f01050dc:	5d                   	pop    %ebp
f01050dd:	c3                   	ret    

f01050de <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01050de:	55                   	push   %ebp
f01050df:	89 e5                	mov    %esp,%ebp
f01050e1:	57                   	push   %edi
f01050e2:	56                   	push   %esi
f01050e3:	53                   	push   %ebx
f01050e4:	8b 55 08             	mov    0x8(%ebp),%edx
f01050e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01050ea:	eb 03                	jmp    f01050ef <strtol+0x11>
		s++;
f01050ec:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f01050ef:	0f b6 02             	movzbl (%edx),%eax
f01050f2:	3c 20                	cmp    $0x20,%al
f01050f4:	74 f6                	je     f01050ec <strtol+0xe>
f01050f6:	3c 09                	cmp    $0x9,%al
f01050f8:	74 f2                	je     f01050ec <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01050fa:	3c 2b                	cmp    $0x2b,%al
f01050fc:	74 2a                	je     f0105128 <strtol+0x4a>
	int neg = 0;
f01050fe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105103:	3c 2d                	cmp    $0x2d,%al
f0105105:	74 2b                	je     f0105132 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105107:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010510d:	75 0f                	jne    f010511e <strtol+0x40>
f010510f:	80 3a 30             	cmpb   $0x30,(%edx)
f0105112:	74 28                	je     f010513c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105114:	85 db                	test   %ebx,%ebx
f0105116:	b8 0a 00 00 00       	mov    $0xa,%eax
f010511b:	0f 44 d8             	cmove  %eax,%ebx
f010511e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105123:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105126:	eb 46                	jmp    f010516e <strtol+0x90>
		s++;
f0105128:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f010512b:	bf 00 00 00 00       	mov    $0x0,%edi
f0105130:	eb d5                	jmp    f0105107 <strtol+0x29>
		s++, neg = 1;
f0105132:	83 c2 01             	add    $0x1,%edx
f0105135:	bf 01 00 00 00       	mov    $0x1,%edi
f010513a:	eb cb                	jmp    f0105107 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010513c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105140:	74 0e                	je     f0105150 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0105142:	85 db                	test   %ebx,%ebx
f0105144:	75 d8                	jne    f010511e <strtol+0x40>
		s++, base = 8;
f0105146:	83 c2 01             	add    $0x1,%edx
f0105149:	bb 08 00 00 00       	mov    $0x8,%ebx
f010514e:	eb ce                	jmp    f010511e <strtol+0x40>
		s += 2, base = 16;
f0105150:	83 c2 02             	add    $0x2,%edx
f0105153:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105158:	eb c4                	jmp    f010511e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f010515a:	0f be c0             	movsbl %al,%eax
f010515d:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105160:	3b 45 10             	cmp    0x10(%ebp),%eax
f0105163:	7d 3a                	jge    f010519f <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105165:	83 c2 01             	add    $0x1,%edx
f0105168:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f010516c:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f010516e:	0f b6 02             	movzbl (%edx),%eax
f0105171:	8d 70 d0             	lea    -0x30(%eax),%esi
f0105174:	89 f3                	mov    %esi,%ebx
f0105176:	80 fb 09             	cmp    $0x9,%bl
f0105179:	76 df                	jbe    f010515a <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f010517b:	8d 70 9f             	lea    -0x61(%eax),%esi
f010517e:	89 f3                	mov    %esi,%ebx
f0105180:	80 fb 19             	cmp    $0x19,%bl
f0105183:	77 08                	ja     f010518d <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105185:	0f be c0             	movsbl %al,%eax
f0105188:	83 e8 57             	sub    $0x57,%eax
f010518b:	eb d3                	jmp    f0105160 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f010518d:	8d 70 bf             	lea    -0x41(%eax),%esi
f0105190:	89 f3                	mov    %esi,%ebx
f0105192:	80 fb 19             	cmp    $0x19,%bl
f0105195:	77 08                	ja     f010519f <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105197:	0f be c0             	movsbl %al,%eax
f010519a:	83 e8 37             	sub    $0x37,%eax
f010519d:	eb c1                	jmp    f0105160 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f010519f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01051a3:	74 05                	je     f01051aa <strtol+0xcc>
		*endptr = (char *) s;
f01051a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051a8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01051aa:	89 c8                	mov    %ecx,%eax
f01051ac:	f7 d8                	neg    %eax
f01051ae:	85 ff                	test   %edi,%edi
f01051b0:	0f 45 c8             	cmovne %eax,%ecx
}
f01051b3:	89 c8                	mov    %ecx,%eax
f01051b5:	5b                   	pop    %ebx
f01051b6:	5e                   	pop    %esi
f01051b7:	5f                   	pop    %edi
f01051b8:	5d                   	pop    %ebp
f01051b9:	c3                   	ret    
f01051ba:	66 90                	xchg   %ax,%ax
f01051bc:	66 90                	xchg   %ax,%ax
f01051be:	66 90                	xchg   %ax,%ax

f01051c0 <__udivdi3>:
f01051c0:	f3 0f 1e fb          	endbr32 
f01051c4:	55                   	push   %ebp
f01051c5:	57                   	push   %edi
f01051c6:	56                   	push   %esi
f01051c7:	53                   	push   %ebx
f01051c8:	83 ec 1c             	sub    $0x1c,%esp
f01051cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01051cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01051d3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01051d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01051db:	85 c0                	test   %eax,%eax
f01051dd:	75 19                	jne    f01051f8 <__udivdi3+0x38>
f01051df:	39 f3                	cmp    %esi,%ebx
f01051e1:	76 4d                	jbe    f0105230 <__udivdi3+0x70>
f01051e3:	31 ff                	xor    %edi,%edi
f01051e5:	89 e8                	mov    %ebp,%eax
f01051e7:	89 f2                	mov    %esi,%edx
f01051e9:	f7 f3                	div    %ebx
f01051eb:	89 fa                	mov    %edi,%edx
f01051ed:	83 c4 1c             	add    $0x1c,%esp
f01051f0:	5b                   	pop    %ebx
f01051f1:	5e                   	pop    %esi
f01051f2:	5f                   	pop    %edi
f01051f3:	5d                   	pop    %ebp
f01051f4:	c3                   	ret    
f01051f5:	8d 76 00             	lea    0x0(%esi),%esi
f01051f8:	39 f0                	cmp    %esi,%eax
f01051fa:	76 14                	jbe    f0105210 <__udivdi3+0x50>
f01051fc:	31 ff                	xor    %edi,%edi
f01051fe:	31 c0                	xor    %eax,%eax
f0105200:	89 fa                	mov    %edi,%edx
f0105202:	83 c4 1c             	add    $0x1c,%esp
f0105205:	5b                   	pop    %ebx
f0105206:	5e                   	pop    %esi
f0105207:	5f                   	pop    %edi
f0105208:	5d                   	pop    %ebp
f0105209:	c3                   	ret    
f010520a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105210:	0f bd f8             	bsr    %eax,%edi
f0105213:	83 f7 1f             	xor    $0x1f,%edi
f0105216:	75 48                	jne    f0105260 <__udivdi3+0xa0>
f0105218:	39 f0                	cmp    %esi,%eax
f010521a:	72 06                	jb     f0105222 <__udivdi3+0x62>
f010521c:	31 c0                	xor    %eax,%eax
f010521e:	39 eb                	cmp    %ebp,%ebx
f0105220:	77 de                	ja     f0105200 <__udivdi3+0x40>
f0105222:	b8 01 00 00 00       	mov    $0x1,%eax
f0105227:	eb d7                	jmp    f0105200 <__udivdi3+0x40>
f0105229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105230:	89 d9                	mov    %ebx,%ecx
f0105232:	85 db                	test   %ebx,%ebx
f0105234:	75 0b                	jne    f0105241 <__udivdi3+0x81>
f0105236:	b8 01 00 00 00       	mov    $0x1,%eax
f010523b:	31 d2                	xor    %edx,%edx
f010523d:	f7 f3                	div    %ebx
f010523f:	89 c1                	mov    %eax,%ecx
f0105241:	31 d2                	xor    %edx,%edx
f0105243:	89 f0                	mov    %esi,%eax
f0105245:	f7 f1                	div    %ecx
f0105247:	89 c6                	mov    %eax,%esi
f0105249:	89 e8                	mov    %ebp,%eax
f010524b:	89 f7                	mov    %esi,%edi
f010524d:	f7 f1                	div    %ecx
f010524f:	89 fa                	mov    %edi,%edx
f0105251:	83 c4 1c             	add    $0x1c,%esp
f0105254:	5b                   	pop    %ebx
f0105255:	5e                   	pop    %esi
f0105256:	5f                   	pop    %edi
f0105257:	5d                   	pop    %ebp
f0105258:	c3                   	ret    
f0105259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105260:	89 f9                	mov    %edi,%ecx
f0105262:	ba 20 00 00 00       	mov    $0x20,%edx
f0105267:	29 fa                	sub    %edi,%edx
f0105269:	d3 e0                	shl    %cl,%eax
f010526b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010526f:	89 d1                	mov    %edx,%ecx
f0105271:	89 d8                	mov    %ebx,%eax
f0105273:	d3 e8                	shr    %cl,%eax
f0105275:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105279:	09 c1                	or     %eax,%ecx
f010527b:	89 f0                	mov    %esi,%eax
f010527d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105281:	89 f9                	mov    %edi,%ecx
f0105283:	d3 e3                	shl    %cl,%ebx
f0105285:	89 d1                	mov    %edx,%ecx
f0105287:	d3 e8                	shr    %cl,%eax
f0105289:	89 f9                	mov    %edi,%ecx
f010528b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010528f:	89 eb                	mov    %ebp,%ebx
f0105291:	d3 e6                	shl    %cl,%esi
f0105293:	89 d1                	mov    %edx,%ecx
f0105295:	d3 eb                	shr    %cl,%ebx
f0105297:	09 f3                	or     %esi,%ebx
f0105299:	89 c6                	mov    %eax,%esi
f010529b:	89 f2                	mov    %esi,%edx
f010529d:	89 d8                	mov    %ebx,%eax
f010529f:	f7 74 24 08          	divl   0x8(%esp)
f01052a3:	89 d6                	mov    %edx,%esi
f01052a5:	89 c3                	mov    %eax,%ebx
f01052a7:	f7 64 24 0c          	mull   0xc(%esp)
f01052ab:	39 d6                	cmp    %edx,%esi
f01052ad:	72 19                	jb     f01052c8 <__udivdi3+0x108>
f01052af:	89 f9                	mov    %edi,%ecx
f01052b1:	d3 e5                	shl    %cl,%ebp
f01052b3:	39 c5                	cmp    %eax,%ebp
f01052b5:	73 04                	jae    f01052bb <__udivdi3+0xfb>
f01052b7:	39 d6                	cmp    %edx,%esi
f01052b9:	74 0d                	je     f01052c8 <__udivdi3+0x108>
f01052bb:	89 d8                	mov    %ebx,%eax
f01052bd:	31 ff                	xor    %edi,%edi
f01052bf:	e9 3c ff ff ff       	jmp    f0105200 <__udivdi3+0x40>
f01052c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01052c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01052cb:	31 ff                	xor    %edi,%edi
f01052cd:	e9 2e ff ff ff       	jmp    f0105200 <__udivdi3+0x40>
f01052d2:	66 90                	xchg   %ax,%ax
f01052d4:	66 90                	xchg   %ax,%ax
f01052d6:	66 90                	xchg   %ax,%ax
f01052d8:	66 90                	xchg   %ax,%ax
f01052da:	66 90                	xchg   %ax,%ax
f01052dc:	66 90                	xchg   %ax,%ax
f01052de:	66 90                	xchg   %ax,%ax

f01052e0 <__umoddi3>:
f01052e0:	f3 0f 1e fb          	endbr32 
f01052e4:	55                   	push   %ebp
f01052e5:	57                   	push   %edi
f01052e6:	56                   	push   %esi
f01052e7:	53                   	push   %ebx
f01052e8:	83 ec 1c             	sub    $0x1c,%esp
f01052eb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01052ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01052f3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f01052f7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f01052fb:	89 f0                	mov    %esi,%eax
f01052fd:	89 da                	mov    %ebx,%edx
f01052ff:	85 ff                	test   %edi,%edi
f0105301:	75 15                	jne    f0105318 <__umoddi3+0x38>
f0105303:	39 dd                	cmp    %ebx,%ebp
f0105305:	76 39                	jbe    f0105340 <__umoddi3+0x60>
f0105307:	f7 f5                	div    %ebp
f0105309:	89 d0                	mov    %edx,%eax
f010530b:	31 d2                	xor    %edx,%edx
f010530d:	83 c4 1c             	add    $0x1c,%esp
f0105310:	5b                   	pop    %ebx
f0105311:	5e                   	pop    %esi
f0105312:	5f                   	pop    %edi
f0105313:	5d                   	pop    %ebp
f0105314:	c3                   	ret    
f0105315:	8d 76 00             	lea    0x0(%esi),%esi
f0105318:	39 df                	cmp    %ebx,%edi
f010531a:	77 f1                	ja     f010530d <__umoddi3+0x2d>
f010531c:	0f bd cf             	bsr    %edi,%ecx
f010531f:	83 f1 1f             	xor    $0x1f,%ecx
f0105322:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105326:	75 40                	jne    f0105368 <__umoddi3+0x88>
f0105328:	39 df                	cmp    %ebx,%edi
f010532a:	72 04                	jb     f0105330 <__umoddi3+0x50>
f010532c:	39 f5                	cmp    %esi,%ebp
f010532e:	77 dd                	ja     f010530d <__umoddi3+0x2d>
f0105330:	89 da                	mov    %ebx,%edx
f0105332:	89 f0                	mov    %esi,%eax
f0105334:	29 e8                	sub    %ebp,%eax
f0105336:	19 fa                	sbb    %edi,%edx
f0105338:	eb d3                	jmp    f010530d <__umoddi3+0x2d>
f010533a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105340:	89 e9                	mov    %ebp,%ecx
f0105342:	85 ed                	test   %ebp,%ebp
f0105344:	75 0b                	jne    f0105351 <__umoddi3+0x71>
f0105346:	b8 01 00 00 00       	mov    $0x1,%eax
f010534b:	31 d2                	xor    %edx,%edx
f010534d:	f7 f5                	div    %ebp
f010534f:	89 c1                	mov    %eax,%ecx
f0105351:	89 d8                	mov    %ebx,%eax
f0105353:	31 d2                	xor    %edx,%edx
f0105355:	f7 f1                	div    %ecx
f0105357:	89 f0                	mov    %esi,%eax
f0105359:	f7 f1                	div    %ecx
f010535b:	89 d0                	mov    %edx,%eax
f010535d:	31 d2                	xor    %edx,%edx
f010535f:	eb ac                	jmp    f010530d <__umoddi3+0x2d>
f0105361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105368:	8b 44 24 04          	mov    0x4(%esp),%eax
f010536c:	ba 20 00 00 00       	mov    $0x20,%edx
f0105371:	29 c2                	sub    %eax,%edx
f0105373:	89 c1                	mov    %eax,%ecx
f0105375:	89 e8                	mov    %ebp,%eax
f0105377:	d3 e7                	shl    %cl,%edi
f0105379:	89 d1                	mov    %edx,%ecx
f010537b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010537f:	d3 e8                	shr    %cl,%eax
f0105381:	89 c1                	mov    %eax,%ecx
f0105383:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105387:	09 f9                	or     %edi,%ecx
f0105389:	89 df                	mov    %ebx,%edi
f010538b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010538f:	89 c1                	mov    %eax,%ecx
f0105391:	d3 e5                	shl    %cl,%ebp
f0105393:	89 d1                	mov    %edx,%ecx
f0105395:	d3 ef                	shr    %cl,%edi
f0105397:	89 c1                	mov    %eax,%ecx
f0105399:	89 f0                	mov    %esi,%eax
f010539b:	d3 e3                	shl    %cl,%ebx
f010539d:	89 d1                	mov    %edx,%ecx
f010539f:	89 fa                	mov    %edi,%edx
f01053a1:	d3 e8                	shr    %cl,%eax
f01053a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01053a8:	09 d8                	or     %ebx,%eax
f01053aa:	f7 74 24 08          	divl   0x8(%esp)
f01053ae:	89 d3                	mov    %edx,%ebx
f01053b0:	d3 e6                	shl    %cl,%esi
f01053b2:	f7 e5                	mul    %ebp
f01053b4:	89 c7                	mov    %eax,%edi
f01053b6:	89 d1                	mov    %edx,%ecx
f01053b8:	39 d3                	cmp    %edx,%ebx
f01053ba:	72 06                	jb     f01053c2 <__umoddi3+0xe2>
f01053bc:	75 0e                	jne    f01053cc <__umoddi3+0xec>
f01053be:	39 c6                	cmp    %eax,%esi
f01053c0:	73 0a                	jae    f01053cc <__umoddi3+0xec>
f01053c2:	29 e8                	sub    %ebp,%eax
f01053c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01053c8:	89 d1                	mov    %edx,%ecx
f01053ca:	89 c7                	mov    %eax,%edi
f01053cc:	89 f5                	mov    %esi,%ebp
f01053ce:	8b 74 24 04          	mov    0x4(%esp),%esi
f01053d2:	29 fd                	sub    %edi,%ebp
f01053d4:	19 cb                	sbb    %ecx,%ebx
f01053d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01053db:	89 d8                	mov    %ebx,%eax
f01053dd:	d3 e0                	shl    %cl,%eax
f01053df:	89 f1                	mov    %esi,%ecx
f01053e1:	d3 ed                	shr    %cl,%ebp
f01053e3:	d3 eb                	shr    %cl,%ebx
f01053e5:	09 e8                	or     %ebp,%eax
f01053e7:	89 da                	mov    %ebx,%edx
f01053e9:	83 c4 1c             	add    $0x1c,%esp
f01053ec:	5b                   	pop    %ebx
f01053ed:	5e                   	pop    %esi
f01053ee:	5f                   	pop    %edi
f01053ef:	5d                   	pop    %ebp
f01053f0:	c3                   	ret    
