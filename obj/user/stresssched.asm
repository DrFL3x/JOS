
obj/user/stresssched:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 71 0b 00 00       	call   800bae <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 49 0e 00 00       	call   800e92 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 73 0b 00 00       	call   800bcd <sys_yield>
		return;
  80005a:	eb 69                	jmp    8000c5 <umain+0x92>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005c:	89 f0                	mov    %esi,%eax
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	eb 02                	jmp    80006f <umain+0x3c>
		asm volatile("pause");
  80006d:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006f:	8b 50 54             	mov    0x54(%eax),%edx
  800072:	85 d2                	test   %edx,%edx
  800074:	75 f7                	jne    80006d <umain+0x3a>
  800076:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007b:	e8 4d 0b 00 00       	call   800bcd <sys_yield>
  800080:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800085:	a1 04 20 80 00       	mov    0x802004,%eax
  80008a:	83 c0 01             	add    $0x1,%eax
  80008d:	a3 04 20 80 00       	mov    %eax,0x802004
		for (j = 0; j < 10000; j++)
  800092:	83 ea 01             	sub    $0x1,%edx
  800095:	75 ee                	jne    800085 <umain+0x52>
	for (i = 0; i < 10; i++) {
  800097:	83 eb 01             	sub    $0x1,%ebx
  80009a:	75 df                	jne    80007b <umain+0x48>
	}

	if (counter != 10*10000)
  80009c:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a1:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000a6:	75 24                	jne    8000cc <umain+0x99>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000a8:	a1 08 20 80 00       	mov    0x802008,%eax
  8000ad:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b0:	8b 40 48             	mov    0x48(%eax),%eax
  8000b3:	83 ec 04             	sub    $0x4,%esp
  8000b6:	52                   	push   %edx
  8000b7:	50                   	push   %eax
  8000b8:	68 7b 13 80 00       	push   $0x80137b
  8000bd:	e8 54 01 00 00       	call   800216 <cprintf>
  8000c2:	83 c4 10             	add    $0x10,%esp

}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000cc:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d1:	50                   	push   %eax
  8000d2:	68 40 13 80 00       	push   $0x801340
  8000d7:	6a 21                	push   $0x21
  8000d9:	68 68 13 80 00       	push   $0x801368
  8000de:	e8 58 00 00 00       	call   80013b <_panic>

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid;
	envid = sys_getenvid();
  8000ee:	e8 bb 0a 00 00       	call   800bae <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x2d>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 19 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012f:	6a 00                	push   $0x0
  800131:	e8 37 0a 00 00       	call   800b6d <sys_env_destroy>
}
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800140:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800143:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800149:	e8 60 0a 00 00       	call   800bae <sys_getenvid>
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	ff 75 0c             	push   0xc(%ebp)
  800154:	ff 75 08             	push   0x8(%ebp)
  800157:	56                   	push   %esi
  800158:	50                   	push   %eax
  800159:	68 a4 13 80 00       	push   $0x8013a4
  80015e:	e8 b3 00 00 00       	call   800216 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800163:	83 c4 18             	add    $0x18,%esp
  800166:	53                   	push   %ebx
  800167:	ff 75 10             	push   0x10(%ebp)
  80016a:	e8 56 00 00 00       	call   8001c5 <vcprintf>
	cprintf("\n");
  80016f:	c7 04 24 0d 17 80 00 	movl   $0x80170d,(%esp)
  800176:	e8 9b 00 00 00       	call   800216 <cprintf>
  80017b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017e:	cc                   	int3   
  80017f:	eb fd                	jmp    80017e <_panic+0x43>

00800181 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	53                   	push   %ebx
  800185:	83 ec 04             	sub    $0x4,%esp
  800188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018b:	8b 13                	mov    (%ebx),%edx
  80018d:	8d 42 01             	lea    0x1(%edx),%eax
  800190:	89 03                	mov    %eax,(%ebx)
  800192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800195:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800199:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019e:	74 09                	je     8001a9 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	68 ff 00 00 00       	push   $0xff
  8001b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b4:	50                   	push   %eax
  8001b5:	e8 76 09 00 00       	call   800b30 <sys_cputs>
		b->idx = 0;
  8001ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	eb db                	jmp    8001a0 <putch+0x1f>

008001c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d5:	00 00 00 
	b.cnt = 0;
  8001d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e2:	ff 75 0c             	push   0xc(%ebp)
  8001e5:	ff 75 08             	push   0x8(%ebp)
  8001e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ee:	50                   	push   %eax
  8001ef:	68 81 01 80 00       	push   $0x800181
  8001f4:	e8 14 01 00 00       	call   80030d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f9:	83 c4 08             	add    $0x8,%esp
  8001fc:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800202:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	e8 22 09 00 00       	call   800b30 <sys_cputs>

	return b.cnt;
}
  80020e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800214:	c9                   	leave  
  800215:	c3                   	ret    

00800216 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021f:	50                   	push   %eax
  800220:	ff 75 08             	push   0x8(%ebp)
  800223:	e8 9d ff ff ff       	call   8001c5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 1c             	sub    $0x1c,%esp
  800233:	89 c7                	mov    %eax,%edi
  800235:	89 d6                	mov    %edx,%esi
  800237:	8b 45 08             	mov    0x8(%ebp),%eax
  80023a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023d:	89 d1                	mov    %edx,%ecx
  80023f:	89 c2                	mov    %eax,%edx
  800241:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800244:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800247:	8b 45 10             	mov    0x10(%ebp),%eax
  80024a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800250:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800257:	39 c2                	cmp    %eax,%edx
  800259:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80025c:	72 3e                	jb     80029c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	ff 75 18             	push   0x18(%ebp)
  800264:	83 eb 01             	sub    $0x1,%ebx
  800267:	53                   	push   %ebx
  800268:	50                   	push   %eax
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	push   -0x1c(%ebp)
  80026f:	ff 75 e0             	push   -0x20(%ebp)
  800272:	ff 75 dc             	push   -0x24(%ebp)
  800275:	ff 75 d8             	push   -0x28(%ebp)
  800278:	e8 73 0e 00 00       	call   8010f0 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9f ff ff ff       	call   80022a <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 13                	jmp    8002a3 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	push   0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80029c:	83 eb 01             	sub    $0x1,%ebx
  80029f:	85 db                	test   %ebx,%ebx
  8002a1:	7f ed                	jg     800290 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	83 ec 04             	sub    $0x4,%esp
  8002aa:	ff 75 e4             	push   -0x1c(%ebp)
  8002ad:	ff 75 e0             	push   -0x20(%ebp)
  8002b0:	ff 75 dc             	push   -0x24(%ebp)
  8002b3:	ff 75 d8             	push   -0x28(%ebp)
  8002b6:	e8 55 0f 00 00       	call   801210 <__umoddi3>
  8002bb:	83 c4 14             	add    $0x14,%esp
  8002be:	0f be 80 c7 13 80 00 	movsbl 0x8013c7(%eax),%eax
  8002c5:	50                   	push   %eax
  8002c6:	ff d7                	call   *%edi
}
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e2:	73 0a                	jae    8002ee <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ec:	88 02                	mov    %al,(%edx)
}
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <printfmt>:
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f9:	50                   	push   %eax
  8002fa:	ff 75 10             	push   0x10(%ebp)
  8002fd:	ff 75 0c             	push   0xc(%ebp)
  800300:	ff 75 08             	push   0x8(%ebp)
  800303:	e8 05 00 00 00       	call   80030d <vprintfmt>
}
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <vprintfmt>:
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 3c             	sub    $0x3c,%esp
  800316:	8b 75 08             	mov    0x8(%ebp),%esi
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031f:	eb 0a                	jmp    80032b <vprintfmt+0x1e>
			putch(ch, putdat);
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	53                   	push   %ebx
  800325:	50                   	push   %eax
  800326:	ff d6                	call   *%esi
  800328:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032b:	83 c7 01             	add    $0x1,%edi
  80032e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800332:	83 f8 25             	cmp    $0x25,%eax
  800335:	74 0c                	je     800343 <vprintfmt+0x36>
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	75 e6                	jne    800321 <vprintfmt+0x14>
}
  80033b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033e:	5b                   	pop    %ebx
  80033f:	5e                   	pop    %esi
  800340:	5f                   	pop    %edi
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    
		padc = ' ';
  800343:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800347:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80034e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800355:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80035c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8d 47 01             	lea    0x1(%edi),%eax
  800364:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800367:	0f b6 17             	movzbl (%edi),%edx
  80036a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80036d:	3c 55                	cmp    $0x55,%al
  80036f:	0f 87 bb 03 00 00    	ja     800730 <vprintfmt+0x423>
  800375:	0f b6 c0             	movzbl %al,%eax
  800378:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800382:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800386:	eb d9                	jmp    800361 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80038f:	eb d0                	jmp    800361 <vprintfmt+0x54>
  800391:	0f b6 d2             	movzbl %dl,%edx
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800397:	b8 00 00 00 00       	mov    $0x0,%eax
  80039c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80039f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ac:	83 f9 09             	cmp    $0x9,%ecx
  8003af:	77 55                	ja     800406 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b4:	eb e9                	jmp    80039f <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 40 04             	lea    0x4(%eax),%eax
  8003c4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	79 91                	jns    800361 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003dd:	eb 82                	jmp    800361 <vprintfmt+0x54>
  8003df:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e2:	85 d2                	test   %edx,%edx
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e9:	0f 49 c2             	cmovns %edx,%eax
  8003ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f2:	e9 6a ff ff ff       	jmp    800361 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003fa:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800401:	e9 5b ff ff ff       	jmp    800361 <vprintfmt+0x54>
  800406:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800409:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040c:	eb bc                	jmp    8003ca <vprintfmt+0xbd>
			lflag++;
  80040e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800414:	e9 48 ff ff ff       	jmp    800361 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 78 04             	lea    0x4(%eax),%edi
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	53                   	push   %ebx
  800423:	ff 30                	push   (%eax)
  800425:	ff d6                	call   *%esi
			break;
  800427:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80042a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80042d:	e9 9d 02 00 00       	jmp    8006cf <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 78 04             	lea    0x4(%eax),%edi
  800438:	8b 10                	mov    (%eax),%edx
  80043a:	89 d0                	mov    %edx,%eax
  80043c:	f7 d8                	neg    %eax
  80043e:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800441:	83 f8 08             	cmp    $0x8,%eax
  800444:	7f 23                	jg     800469 <vprintfmt+0x15c>
  800446:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  80044d:	85 d2                	test   %edx,%edx
  80044f:	74 18                	je     800469 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800451:	52                   	push   %edx
  800452:	68 e8 13 80 00       	push   $0x8013e8
  800457:	53                   	push   %ebx
  800458:	56                   	push   %esi
  800459:	e8 92 fe ff ff       	call   8002f0 <printfmt>
  80045e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800461:	89 7d 14             	mov    %edi,0x14(%ebp)
  800464:	e9 66 02 00 00       	jmp    8006cf <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800469:	50                   	push   %eax
  80046a:	68 df 13 80 00       	push   $0x8013df
  80046f:	53                   	push   %ebx
  800470:	56                   	push   %esi
  800471:	e8 7a fe ff ff       	call   8002f0 <printfmt>
  800476:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800479:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047c:	e9 4e 02 00 00       	jmp    8006cf <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	83 c0 04             	add    $0x4,%eax
  800487:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80048f:	85 d2                	test   %edx,%edx
  800491:	b8 d8 13 80 00       	mov    $0x8013d8,%eax
  800496:	0f 45 c2             	cmovne %edx,%eax
  800499:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80049c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a0:	7e 06                	jle    8004a8 <vprintfmt+0x19b>
  8004a2:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004a6:	75 0d                	jne    8004b5 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ab:	89 c7                	mov    %eax,%edi
  8004ad:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b3:	eb 55                	jmp    80050a <vprintfmt+0x1fd>
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 d8             	push   -0x28(%ebp)
  8004bb:	ff 75 cc             	push   -0x34(%ebp)
  8004be:	e8 0a 03 00 00       	call   8007cd <strnlen>
  8004c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c6:	29 c1                	sub    %eax,%ecx
  8004c8:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004d0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	eb 0f                	jmp    8004e8 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	53                   	push   %ebx
  8004dd:	ff 75 e0             	push   -0x20(%ebp)
  8004e0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e2:	83 ef 01             	sub    $0x1,%edi
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	85 ff                	test   %edi,%edi
  8004ea:	7f ed                	jg     8004d9 <vprintfmt+0x1cc>
  8004ec:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f6:	0f 49 c2             	cmovns %edx,%eax
  8004f9:	29 c2                	sub    %eax,%edx
  8004fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004fe:	eb a8                	jmp    8004a8 <vprintfmt+0x19b>
					putch(ch, putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	53                   	push   %ebx
  800504:	52                   	push   %edx
  800505:	ff d6                	call   *%esi
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050f:	83 c7 01             	add    $0x1,%edi
  800512:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800516:	0f be d0             	movsbl %al,%edx
  800519:	85 d2                	test   %edx,%edx
  80051b:	74 4b                	je     800568 <vprintfmt+0x25b>
  80051d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800521:	78 06                	js     800529 <vprintfmt+0x21c>
  800523:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800527:	78 1e                	js     800547 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052d:	74 d1                	je     800500 <vprintfmt+0x1f3>
  80052f:	0f be c0             	movsbl %al,%eax
  800532:	83 e8 20             	sub    $0x20,%eax
  800535:	83 f8 5e             	cmp    $0x5e,%eax
  800538:	76 c6                	jbe    800500 <vprintfmt+0x1f3>
					putch('?', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	53                   	push   %ebx
  80053e:	6a 3f                	push   $0x3f
  800540:	ff d6                	call   *%esi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb c3                	jmp    80050a <vprintfmt+0x1fd>
  800547:	89 cf                	mov    %ecx,%edi
  800549:	eb 0e                	jmp    800559 <vprintfmt+0x24c>
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 ff                	test   %edi,%edi
  80055b:	7f ee                	jg     80054b <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80055d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800560:	89 45 14             	mov    %eax,0x14(%ebp)
  800563:	e9 67 01 00 00       	jmp    8006cf <vprintfmt+0x3c2>
  800568:	89 cf                	mov    %ecx,%edi
  80056a:	eb ed                	jmp    800559 <vprintfmt+0x24c>
	if (lflag >= 2)
  80056c:	83 f9 01             	cmp    $0x1,%ecx
  80056f:	7f 1b                	jg     80058c <vprintfmt+0x27f>
	else if (lflag)
  800571:	85 c9                	test   %ecx,%ecx
  800573:	74 63                	je     8005d8 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057d:	99                   	cltd   
  80057e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	eb 17                	jmp    8005a3 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 50 04             	mov    0x4(%eax),%edx
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 40 08             	lea    0x8(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005a9:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005ae:	85 c9                	test   %ecx,%ecx
  8005b0:	0f 89 ff 00 00 00    	jns    8006b5 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	6a 2d                	push   $0x2d
  8005bc:	ff d6                	call   *%esi
				num = -(long long) num;
  8005be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c4:	f7 da                	neg    %edx
  8005c6:	83 d1 00             	adc    $0x0,%ecx
  8005c9:	f7 d9                	neg    %ecx
  8005cb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ce:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005d3:	e9 dd 00 00 00       	jmp    8006b5 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e0:	99                   	cltd   
  8005e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ed:	eb b4                	jmp    8005a3 <vprintfmt+0x296>
	if (lflag >= 2)
  8005ef:	83 f9 01             	cmp    $0x1,%ecx
  8005f2:	7f 1e                	jg     800612 <vprintfmt+0x305>
	else if (lflag)
  8005f4:	85 c9                	test   %ecx,%ecx
  8005f6:	74 32                	je     80062a <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800608:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80060d:	e9 a3 00 00 00       	jmp    8006b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 10                	mov    (%eax),%edx
  800617:	8b 48 04             	mov    0x4(%eax),%ecx
  80061a:	8d 40 08             	lea    0x8(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800620:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800625:	e9 8b 00 00 00       	jmp    8006b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 10                	mov    (%eax),%edx
  80062f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80063f:	eb 74                	jmp    8006b5 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800641:	83 f9 01             	cmp    $0x1,%ecx
  800644:	7f 1b                	jg     800661 <vprintfmt+0x354>
	else if (lflag)
  800646:	85 c9                	test   %ecx,%ecx
  800648:	74 2c                	je     800676 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80065a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80065f:	eb 54                	jmp    8006b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8b 10                	mov    (%eax),%edx
  800666:	8b 48 04             	mov    0x4(%eax),%ecx
  800669:	8d 40 08             	lea    0x8(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80066f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800674:	eb 3f                	jmp    8006b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8b 10                	mov    (%eax),%edx
  80067b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800686:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80068b:	eb 28                	jmp    8006b5 <vprintfmt+0x3a8>
			putch('0', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 30                	push   $0x30
  800693:	ff d6                	call   *%esi
			putch('x', putdat);
  800695:	83 c4 08             	add    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 78                	push   $0x78
  80069b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006aa:	8d 40 04             	lea    0x4(%eax),%eax
  8006ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b0:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006b5:	83 ec 0c             	sub    $0xc,%esp
  8006b8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	ff 75 e0             	push   -0x20(%ebp)
  8006c0:	57                   	push   %edi
  8006c1:	51                   	push   %ecx
  8006c2:	52                   	push   %edx
  8006c3:	89 da                	mov    %ebx,%edx
  8006c5:	89 f0                	mov    %esi,%eax
  8006c7:	e8 5e fb ff ff       	call   80022a <printnum>
			break;
  8006cc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d2:	e9 54 fc ff ff       	jmp    80032b <vprintfmt+0x1e>
	if (lflag >= 2)
  8006d7:	83 f9 01             	cmp    $0x1,%ecx
  8006da:	7f 1b                	jg     8006f7 <vprintfmt+0x3ea>
	else if (lflag)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 2c                	je     80070c <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006f5:	eb be                	jmp    8006b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8b 10                	mov    (%eax),%edx
  8006fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ff:	8d 40 08             	lea    0x8(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800705:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80070a:	eb a9                	jmp    8006b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	b9 00 00 00 00       	mov    $0x0,%ecx
  800716:	8d 40 04             	lea    0x4(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800721:	eb 92                	jmp    8006b5 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	53                   	push   %ebx
  800727:	6a 25                	push   $0x25
  800729:	ff d6                	call   *%esi
			break;
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	eb 9f                	jmp    8006cf <vprintfmt+0x3c2>
			putch('%', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	53                   	push   %ebx
  800734:	6a 25                	push   $0x25
  800736:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	89 f8                	mov    %edi,%eax
  80073d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800741:	74 05                	je     800748 <vprintfmt+0x43b>
  800743:	83 e8 01             	sub    $0x1,%eax
  800746:	eb f5                	jmp    80073d <vprintfmt+0x430>
  800748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074b:	eb 82                	jmp    8006cf <vprintfmt+0x3c2>

0080074d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	83 ec 18             	sub    $0x18,%esp
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800759:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800760:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800763:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076a:	85 c0                	test   %eax,%eax
  80076c:	74 26                	je     800794 <vsnprintf+0x47>
  80076e:	85 d2                	test   %edx,%edx
  800770:	7e 22                	jle    800794 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800772:	ff 75 14             	push   0x14(%ebp)
  800775:	ff 75 10             	push   0x10(%ebp)
  800778:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077b:	50                   	push   %eax
  80077c:	68 d3 02 80 00       	push   $0x8002d3
  800781:	e8 87 fb ff ff       	call   80030d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800786:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800789:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078f:	83 c4 10             	add    $0x10,%esp
}
  800792:	c9                   	leave  
  800793:	c3                   	ret    
		return -E_INVAL;
  800794:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800799:	eb f7                	jmp    800792 <vsnprintf+0x45>

0080079b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a4:	50                   	push   %eax
  8007a5:	ff 75 10             	push   0x10(%ebp)
  8007a8:	ff 75 0c             	push   0xc(%ebp)
  8007ab:	ff 75 08             	push   0x8(%ebp)
  8007ae:	e8 9a ff ff ff       	call   80074d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	eb 03                	jmp    8007c5 <strlen+0x10>
		n++;
  8007c2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c9:	75 f7                	jne    8007c2 <strlen+0xd>
	return n;
}
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	eb 03                	jmp    8007e0 <strnlen+0x13>
		n++;
  8007dd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e0:	39 d0                	cmp    %edx,%eax
  8007e2:	74 08                	je     8007ec <strnlen+0x1f>
  8007e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e8:	75 f3                	jne    8007dd <strnlen+0x10>
  8007ea:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ec:	89 d0                	mov    %edx,%eax
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ff:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800803:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800806:	83 c0 01             	add    $0x1,%eax
  800809:	84 d2                	test   %dl,%dl
  80080b:	75 f2                	jne    8007ff <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80080d:	89 c8                	mov    %ecx,%eax
  80080f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	83 ec 10             	sub    $0x10,%esp
  80081b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081e:	53                   	push   %ebx
  80081f:	e8 91 ff ff ff       	call   8007b5 <strlen>
  800824:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800827:	ff 75 0c             	push   0xc(%ebp)
  80082a:	01 d8                	add    %ebx,%eax
  80082c:	50                   	push   %eax
  80082d:	e8 be ff ff ff       	call   8007f0 <strcpy>
	return dst;
}
  800832:	89 d8                	mov    %ebx,%eax
  800834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 75 08             	mov    0x8(%ebp),%esi
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
  800844:	89 f3                	mov    %esi,%ebx
  800846:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800849:	89 f0                	mov    %esi,%eax
  80084b:	eb 0f                	jmp    80085c <strncpy+0x23>
		*dst++ = *src;
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	0f b6 0a             	movzbl (%edx),%ecx
  800853:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800856:	80 f9 01             	cmp    $0x1,%cl
  800859:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80085c:	39 d8                	cmp    %ebx,%eax
  80085e:	75 ed                	jne    80084d <strncpy+0x14>
	}
	return ret;
}
  800860:	89 f0                	mov    %esi,%eax
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800871:	8b 55 10             	mov    0x10(%ebp),%edx
  800874:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800876:	85 d2                	test   %edx,%edx
  800878:	74 21                	je     80089b <strlcpy+0x35>
  80087a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087e:	89 f2                	mov    %esi,%edx
  800880:	eb 09                	jmp    80088b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800882:	83 c1 01             	add    $0x1,%ecx
  800885:	83 c2 01             	add    $0x1,%edx
  800888:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80088b:	39 c2                	cmp    %eax,%edx
  80088d:	74 09                	je     800898 <strlcpy+0x32>
  80088f:	0f b6 19             	movzbl (%ecx),%ebx
  800892:	84 db                	test   %bl,%bl
  800894:	75 ec                	jne    800882 <strlcpy+0x1c>
  800896:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800898:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089b:	29 f0                	sub    %esi,%eax
}
  80089d:	5b                   	pop    %ebx
  80089e:	5e                   	pop    %esi
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008aa:	eb 06                	jmp    8008b2 <strcmp+0x11>
		p++, q++;
  8008ac:	83 c1 01             	add    $0x1,%ecx
  8008af:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008b2:	0f b6 01             	movzbl (%ecx),%eax
  8008b5:	84 c0                	test   %al,%al
  8008b7:	74 04                	je     8008bd <strcmp+0x1c>
  8008b9:	3a 02                	cmp    (%edx),%al
  8008bb:	74 ef                	je     8008ac <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bd:	0f b6 c0             	movzbl %al,%eax
  8008c0:	0f b6 12             	movzbl (%edx),%edx
  8008c3:	29 d0                	sub    %edx,%eax
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d1:	89 c3                	mov    %eax,%ebx
  8008d3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d6:	eb 06                	jmp    8008de <strncmp+0x17>
		n--, p++, q++;
  8008d8:	83 c0 01             	add    $0x1,%eax
  8008db:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008de:	39 d8                	cmp    %ebx,%eax
  8008e0:	74 18                	je     8008fa <strncmp+0x33>
  8008e2:	0f b6 08             	movzbl (%eax),%ecx
  8008e5:	84 c9                	test   %cl,%cl
  8008e7:	74 04                	je     8008ed <strncmp+0x26>
  8008e9:	3a 0a                	cmp    (%edx),%cl
  8008eb:	74 eb                	je     8008d8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ed:	0f b6 00             	movzbl (%eax),%eax
  8008f0:	0f b6 12             	movzbl (%edx),%edx
  8008f3:	29 d0                	sub    %edx,%eax
}
  8008f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    
		return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ff:	eb f4                	jmp    8008f5 <strncmp+0x2e>

00800901 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090b:	eb 03                	jmp    800910 <strchr+0xf>
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
  800913:	84 d2                	test   %dl,%dl
  800915:	74 06                	je     80091d <strchr+0x1c>
		if (*s == c)
  800917:	38 ca                	cmp    %cl,%dl
  800919:	75 f2                	jne    80090d <strchr+0xc>
  80091b:	eb 05                	jmp    800922 <strchr+0x21>
			return (char *) s;
	return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 09                	je     80093e <strfind+0x1a>
  800935:	84 d2                	test   %dl,%dl
  800937:	74 05                	je     80093e <strfind+0x1a>
	for (; *s; s++)
  800939:	83 c0 01             	add    $0x1,%eax
  80093c:	eb f0                	jmp    80092e <strfind+0xa>
			break;
	return (char *) s;
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	57                   	push   %edi
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	8b 7d 08             	mov    0x8(%ebp),%edi
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094c:	85 c9                	test   %ecx,%ecx
  80094e:	74 2f                	je     80097f <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800950:	89 f8                	mov    %edi,%eax
  800952:	09 c8                	or     %ecx,%eax
  800954:	a8 03                	test   $0x3,%al
  800956:	75 21                	jne    800979 <memset+0x39>
		c &= 0xFF;
  800958:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095c:	89 d0                	mov    %edx,%eax
  80095e:	c1 e0 08             	shl    $0x8,%eax
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 18             	shl    $0x18,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 10             	shl    $0x10,%esi
  80096b:	09 f3                	or     %esi,%ebx
  80096d:	09 da                	or     %ebx,%edx
  80096f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800971:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800974:	fc                   	cld    
  800975:	f3 ab                	rep stos %eax,%es:(%edi)
  800977:	eb 06                	jmp    80097f <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097c:	fc                   	cld    
  80097d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097f:	89 f8                	mov    %edi,%eax
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	57                   	push   %edi
  80098a:	56                   	push   %esi
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800991:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800994:	39 c6                	cmp    %eax,%esi
  800996:	73 32                	jae    8009ca <memmove+0x44>
  800998:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099b:	39 c2                	cmp    %eax,%edx
  80099d:	76 2b                	jbe    8009ca <memmove+0x44>
		s += n;
		d += n;
  80099f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a2:	89 d6                	mov    %edx,%esi
  8009a4:	09 fe                	or     %edi,%esi
  8009a6:	09 ce                	or     %ecx,%esi
  8009a8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ae:	75 0e                	jne    8009be <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b0:	83 ef 04             	sub    $0x4,%edi
  8009b3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009b9:	fd                   	std    
  8009ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bc:	eb 09                	jmp    8009c7 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009be:	83 ef 01             	sub    $0x1,%edi
  8009c1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c4:	fd                   	std    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c7:	fc                   	cld    
  8009c8:	eb 1a                	jmp    8009e4 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	89 f2                	mov    %esi,%edx
  8009cc:	09 c2                	or     %eax,%edx
  8009ce:	09 ca                	or     %ecx,%edx
  8009d0:	f6 c2 03             	test   $0x3,%dl
  8009d3:	75 0a                	jne    8009df <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009d8:	89 c7                	mov    %eax,%edi
  8009da:	fc                   	cld    
  8009db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dd:	eb 05                	jmp    8009e4 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009df:	89 c7                	mov    %eax,%edi
  8009e1:	fc                   	cld    
  8009e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e4:	5e                   	pop    %esi
  8009e5:	5f                   	pop    %edi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ee:	ff 75 10             	push   0x10(%ebp)
  8009f1:	ff 75 0c             	push   0xc(%ebp)
  8009f4:	ff 75 08             	push   0x8(%ebp)
  8009f7:	e8 8a ff ff ff       	call   800986 <memmove>
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a09:	89 c6                	mov    %eax,%esi
  800a0b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	eb 06                	jmp    800a16 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a10:	83 c0 01             	add    $0x1,%eax
  800a13:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a16:	39 f0                	cmp    %esi,%eax
  800a18:	74 14                	je     800a2e <memcmp+0x30>
		if (*s1 != *s2)
  800a1a:	0f b6 08             	movzbl (%eax),%ecx
  800a1d:	0f b6 1a             	movzbl (%edx),%ebx
  800a20:	38 d9                	cmp    %bl,%cl
  800a22:	74 ec                	je     800a10 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a24:	0f b6 c1             	movzbl %cl,%eax
  800a27:	0f b6 db             	movzbl %bl,%ebx
  800a2a:	29 d8                	sub    %ebx,%eax
  800a2c:	eb 05                	jmp    800a33 <memcmp+0x35>
	}

	return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a33:	5b                   	pop    %ebx
  800a34:	5e                   	pop    %esi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a45:	eb 03                	jmp    800a4a <memfind+0x13>
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	39 d0                	cmp    %edx,%eax
  800a4c:	73 04                	jae    800a52 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4e:	38 08                	cmp    %cl,(%eax)
  800a50:	75 f5                	jne    800a47 <memfind+0x10>
			break;
	return (void *) s;
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a60:	eb 03                	jmp    800a65 <strtol+0x11>
		s++;
  800a62:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a65:	0f b6 02             	movzbl (%edx),%eax
  800a68:	3c 20                	cmp    $0x20,%al
  800a6a:	74 f6                	je     800a62 <strtol+0xe>
  800a6c:	3c 09                	cmp    $0x9,%al
  800a6e:	74 f2                	je     800a62 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a70:	3c 2b                	cmp    $0x2b,%al
  800a72:	74 2a                	je     800a9e <strtol+0x4a>
	int neg = 0;
  800a74:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a79:	3c 2d                	cmp    $0x2d,%al
  800a7b:	74 2b                	je     800aa8 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a83:	75 0f                	jne    800a94 <strtol+0x40>
  800a85:	80 3a 30             	cmpb   $0x30,(%edx)
  800a88:	74 28                	je     800ab2 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a91:	0f 44 d8             	cmove  %eax,%ebx
  800a94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a99:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9c:	eb 46                	jmp    800ae4 <strtol+0x90>
		s++;
  800a9e:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800aa1:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa6:	eb d5                	jmp    800a7d <strtol+0x29>
		s++, neg = 1;
  800aa8:	83 c2 01             	add    $0x1,%edx
  800aab:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab0:	eb cb                	jmp    800a7d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab2:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab6:	74 0e                	je     800ac6 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	75 d8                	jne    800a94 <strtol+0x40>
		s++, base = 8;
  800abc:	83 c2 01             	add    $0x1,%edx
  800abf:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac4:	eb ce                	jmp    800a94 <strtol+0x40>
		s += 2, base = 16;
  800ac6:	83 c2 02             	add    $0x2,%edx
  800ac9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ace:	eb c4                	jmp    800a94 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad0:	0f be c0             	movsbl %al,%eax
  800ad3:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad6:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ad9:	7d 3a                	jge    800b15 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800adb:	83 c2 01             	add    $0x1,%edx
  800ade:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ae2:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ae4:	0f b6 02             	movzbl (%edx),%eax
  800ae7:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 09             	cmp    $0x9,%bl
  800aef:	76 df                	jbe    800ad0 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800af1:	8d 70 9f             	lea    -0x61(%eax),%esi
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	80 fb 19             	cmp    $0x19,%bl
  800af9:	77 08                	ja     800b03 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800afb:	0f be c0             	movsbl %al,%eax
  800afe:	83 e8 57             	sub    $0x57,%eax
  800b01:	eb d3                	jmp    800ad6 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b03:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 08                	ja     800b15 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b0d:	0f be c0             	movsbl %al,%eax
  800b10:	83 e8 37             	sub    $0x37,%eax
  800b13:	eb c1                	jmp    800ad6 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b19:	74 05                	je     800b20 <strtol+0xcc>
		*endptr = (char *) s;
  800b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b20:	89 c8                	mov    %ecx,%eax
  800b22:	f7 d8                	neg    %eax
  800b24:	85 ff                	test   %edi,%edi
  800b26:	0f 45 c8             	cmovne %eax,%ecx
}
  800b29:	89 c8                	mov    %ecx,%eax
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	89 c7                	mov    %eax,%edi
  800b45:	89 c6                	mov    %eax,%esi
  800b47:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b83:	89 cb                	mov    %ecx,%ebx
  800b85:	89 cf                	mov    %ecx,%edi
  800b87:	89 ce                	mov    %ecx,%esi
  800b89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7f 08                	jg     800b97 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	6a 03                	push   $0x3
  800b9d:	68 04 16 80 00       	push   $0x801604
  800ba2:	6a 23                	push   $0x23
  800ba4:	68 21 16 80 00       	push   $0x801621
  800ba9:	e8 8d f5 ff ff       	call   80013b <_panic>

00800bae <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_yield>:

void
sys_yield(void)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bdd:	89 d1                	mov    %edx,%ecx
  800bdf:	89 d3                	mov    %edx,%ebx
  800be1:	89 d7                	mov    %edx,%edi
  800be3:	89 d6                	mov    %edx,%esi
  800be5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf5:	be 00 00 00 00       	mov    $0x0,%esi
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	b8 04 00 00 00       	mov    $0x4,%eax
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	89 f7                	mov    %esi,%edi
  800c0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7f 08                	jg     800c18 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	50                   	push   %eax
  800c1c:	6a 04                	push   $0x4
  800c1e:	68 04 16 80 00       	push   $0x801604
  800c23:	6a 23                	push   $0x23
  800c25:	68 21 16 80 00       	push   $0x801621
  800c2a:	e8 0c f5 ff ff       	call   80013b <_panic>

00800c2f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c49:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	7f 08                	jg     800c5a <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	50                   	push   %eax
  800c5e:	6a 05                	push   $0x5
  800c60:	68 04 16 80 00       	push   $0x801604
  800c65:	6a 23                	push   $0x23
  800c67:	68 21 16 80 00       	push   $0x801621
  800c6c:	e8 ca f4 ff ff       	call   80013b <_panic>

00800c71 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8a:	89 df                	mov    %ebx,%edi
  800c8c:	89 de                	mov    %ebx,%esi
  800c8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c90:	85 c0                	test   %eax,%eax
  800c92:	7f 08                	jg     800c9c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 06                	push   $0x6
  800ca2:	68 04 16 80 00       	push   $0x801604
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 21 16 80 00       	push   $0x801621
  800cae:	e8 88 f4 ff ff       	call   80013b <_panic>

00800cb3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccc:	89 df                	mov    %ebx,%edi
  800cce:	89 de                	mov    %ebx,%esi
  800cd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	7f 08                	jg     800cde <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 08                	push   $0x8
  800ce4:	68 04 16 80 00       	push   $0x801604
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 21 16 80 00       	push   $0x801621
  800cf0:	e8 46 f4 ff ff       	call   80013b <_panic>

00800cf5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	b8 09 00 00 00       	mov    $0x9,%eax
  800d0e:	89 df                	mov    %ebx,%edi
  800d10:	89 de                	mov    %ebx,%esi
  800d12:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7f 08                	jg     800d20 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 09                	push   $0x9
  800d26:	68 04 16 80 00       	push   $0x801604
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 21 16 80 00       	push   $0x801621
  800d32:	e8 04 f4 ff ff       	call   80013b <_panic>

00800d37 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d48:	be 00 00 00 00       	mov    $0x0,%esi
  800d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d53:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d70:	89 cb                	mov    %ecx,%ebx
  800d72:	89 cf                	mov    %ecx,%edi
  800d74:	89 ce                	mov    %ecx,%esi
  800d76:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7f 08                	jg     800d84 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	50                   	push   %eax
  800d88:	6a 0c                	push   $0xc
  800d8a:	68 04 16 80 00       	push   $0x801604
  800d8f:	6a 23                	push   $0x23
  800d91:	68 21 16 80 00       	push   $0x801621
  800d96:	e8 a0 f3 ff ff       	call   80013b <_panic>

00800d9b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800da5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(utf->utf_err & FEC_WR) || (uvpt[PGNUM(addr)] & perm) != perm) 
  800da7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dab:	0f 84 81 00 00 00    	je     800e32 <pgfault+0x97>
  800db1:	89 d8                	mov    %ebx,%eax
  800db3:	c1 e8 0c             	shr    $0xc,%eax
  800db6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dbd:	25 05 08 00 00       	and    $0x805,%eax
  800dc2:	3d 05 08 00 00       	cmp    $0x805,%eax
  800dc7:	75 69                	jne    800e32 <pgfault+0x97>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800dc9:	83 ec 04             	sub    $0x4,%esp
  800dcc:	6a 07                	push   $0x7
  800dce:	68 00 f0 7f 00       	push   $0x7ff000
  800dd3:	6a 00                	push   $0x0
  800dd5:	e8 12 fe ff ff       	call   800bec <sys_page_alloc>
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	78 73                	js     800e54 <pgfault+0xb9>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800de1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	68 00 10 00 00       	push   $0x1000
  800def:	53                   	push   %ebx
  800df0:	68 00 f0 7f 00       	push   $0x7ff000
  800df5:	e8 ee fb ff ff       	call   8009e8 <memcpy>

	if ((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W | PTE_P | PTE_U)) < 0) 
  800dfa:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e01:	53                   	push   %ebx
  800e02:	6a 00                	push   $0x0
  800e04:	68 00 f0 7f 00       	push   $0x7ff000
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 1f fe ff ff       	call   800c2f <sys_page_map>
  800e10:	83 c4 20             	add    $0x20,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	78 57                	js     800e6e <pgfault+0xd3>
	{
		panic("sys_page_map: %e", r);
	}

	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e17:	83 ec 08             	sub    $0x8,%esp
  800e1a:	68 00 f0 7f 00       	push   $0x7ff000
  800e1f:	6a 00                	push   $0x0
  800e21:	e8 4b fe ff ff       	call   800c71 <sys_page_unmap>
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	78 53                	js     800e80 <pgfault+0xe5>
		panic("sys_page_unmap: %e", r);

}
  800e2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    
		panic("pgfault pte: %08x, addr: %08x", uvpt[PGNUM(addr)], addr);
  800e32:	89 d8                	mov    %ebx,%eax
  800e34:	c1 e8 0c             	shr    $0xc,%eax
  800e37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e3e:	83 ec 0c             	sub    $0xc,%esp
  800e41:	53                   	push   %ebx
  800e42:	50                   	push   %eax
  800e43:	68 2f 16 80 00       	push   $0x80162f
  800e48:	6a 1f                	push   $0x1f
  800e4a:	68 4d 16 80 00       	push   $0x80164d
  800e4f:	e8 e7 f2 ff ff       	call   80013b <_panic>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);
  800e54:	83 ec 0c             	sub    $0xc,%esp
  800e57:	50                   	push   %eax
  800e58:	68 00 f0 7f 00       	push   $0x7ff000
  800e5d:	68 bc 16 80 00       	push   $0x8016bc
  800e62:	6a 2a                	push   $0x2a
  800e64:	68 4d 16 80 00       	push   $0x80164d
  800e69:	e8 cd f2 ff ff       	call   80013b <_panic>
		panic("sys_page_map: %e", r);
  800e6e:	50                   	push   %eax
  800e6f:	68 58 16 80 00       	push   $0x801658
  800e74:	6a 30                	push   $0x30
  800e76:	68 4d 16 80 00       	push   $0x80164d
  800e7b:	e8 bb f2 ff ff       	call   80013b <_panic>
		panic("sys_page_unmap: %e", r);
  800e80:	50                   	push   %eax
  800e81:	68 69 16 80 00       	push   $0x801669
  800e86:	6a 34                	push   $0x34
  800e88:	68 4d 16 80 00       	push   $0x80164d
  800e8d:	e8 a9 f2 ff ff       	call   80013b <_panic>

00800e92 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 18             	sub    $0x18,%esp
	envid_t envid;
	pte_t pte;
	uint8_t *va;
	extern unsigned char end[];

	set_pgfault_handler(pgfault);
  800e9b:	68 9b 0d 80 00       	push   $0x800d9b
  800ea0:	e8 aa 01 00 00       	call   80104f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ea5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eaa:	cd 30                	int    $0x30
  800eac:	89 c6                	mov    %eax,%esi
	envid = sys_exofork(); // create child envirement
	if (envid < 0)
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	78 24                	js     800ed9 <fork+0x47>
	{
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (va = 0; va < (uint8_t *)USTACKTOP; va += PGSIZE)
  800eb5:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) 
  800eba:	0f 85 19 01 00 00    	jne    800fd9 <fork+0x147>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec0:	e8 e9 fc ff ff       	call   800bae <sys_getenvid>
  800ec5:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ecd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ed2:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800ed7:	eb 66                	jmp    800f3f <fork+0xad>
		panic("sys_exofork: %e", envid); //new envirement not created
  800ed9:	50                   	push   %eax
  800eda:	68 7c 16 80 00       	push   $0x80167c
  800edf:	6a 78                	push   $0x78
  800ee1:	68 4d 16 80 00       	push   $0x80164d
  800ee6:	e8 50 f2 ff ff       	call   80013b <_panic>
		panic("sys_page_map: %e", r);
  800eeb:	50                   	push   %eax
  800eec:	68 58 16 80 00       	push   $0x801658
  800ef1:	6a 56                	push   $0x56
  800ef3:	68 4d 16 80 00       	push   $0x80164d
  800ef8:	e8 3e f2 ff ff       	call   80013b <_panic>
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P))
			duppage(envid, PGNUM(va));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  800efd:	83 ec 04             	sub    $0x4,%esp
  800f00:	6a 07                	push   $0x7
  800f02:	68 00 f0 bf ee       	push   $0xeebff000
  800f07:	56                   	push   %esi
  800f08:	e8 df fc ff ff       	call   800bec <sys_page_alloc>
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	78 35                	js     800f49 <fork+0xb7>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);

	if ((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800f14:	a1 08 20 80 00       	mov    0x802008,%eax
  800f19:	8b 40 64             	mov    0x64(%eax),%eax
  800f1c:	83 ec 08             	sub    $0x8,%esp
  800f1f:	50                   	push   %eax
  800f20:	56                   	push   %esi
  800f21:	e8 cf fd ff ff       	call   800cf5 <sys_env_set_pgfault_upcall>
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	78 39                	js     800f66 <fork+0xd4>
		panic("sys_env_set_pgfault_upcall: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800f2d:	83 ec 08             	sub    $0x8,%esp
  800f30:	6a 02                	push   $0x2
  800f32:	56                   	push   %esi
  800f33:	e8 7b fd ff ff       	call   800cb3 <sys_env_set_status>
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 3c                	js     800f7b <fork+0xe9>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800f3f:	89 f0                	mov    %esi,%eax
  800f41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
		panic("allocating at %x in pgfault: %e", PFTEMP, r);
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	50                   	push   %eax
  800f4d:	68 00 f0 7f 00       	push   $0x7ff000
  800f52:	68 bc 16 80 00       	push   $0x8016bc
  800f57:	68 84 00 00 00       	push   $0x84
  800f5c:	68 4d 16 80 00       	push   $0x80164d
  800f61:	e8 d5 f1 ff ff       	call   80013b <_panic>
		panic("sys_env_set_pgfault_upcall: %e", r);
  800f66:	50                   	push   %eax
  800f67:	68 dc 16 80 00       	push   $0x8016dc
  800f6c:	68 87 00 00 00       	push   $0x87
  800f71:	68 4d 16 80 00       	push   $0x80164d
  800f76:	e8 c0 f1 ff ff       	call   80013b <_panic>
		panic("sys_env_set_status: %e", r);
  800f7b:	50                   	push   %eax
  800f7c:	68 8c 16 80 00       	push   $0x80168c
  800f81:	68 8a 00 00 00       	push   $0x8a
  800f86:	68 4d 16 80 00       	push   $0x80164d
  800f8b:	e8 ab f1 ff ff       	call   80013b <_panic>
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f90:	83 ec 0c             	sub    $0xc,%esp
  800f93:	68 05 08 00 00       	push   $0x805
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	57                   	push   %edi
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 8d fc ff ff       	call   800c2f <sys_page_map>
  800fa2:	83 c4 20             	add    $0x20,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 7a                	js     801023 <fork+0x191>
	if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	68 05 08 00 00       	push   $0x805
  800fb1:	57                   	push   %edi
  800fb2:	6a 00                	push   $0x0
  800fb4:	57                   	push   %edi
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 73 fc ff ff       	call   800c2f <sys_page_map>
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	0f 88 24 ff ff ff    	js     800eeb <fork+0x59>
	for (va = 0; va < (uint8_t *)USTACKTOP; va += PGSIZE)
  800fc7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fcd:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fd3:	0f 84 24 ff ff ff    	je     800efd <fork+0x6b>
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P))
  800fd9:	89 d8                	mov    %ebx,%eax
  800fdb:	c1 e8 16             	shr    $0x16,%eax
  800fde:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe5:	a8 01                	test   $0x1,%al
  800fe7:	74 de                	je     800fc7 <fork+0x135>
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	c1 e8 0c             	shr    $0xc,%eax
  800fee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff5:	f6 c2 01             	test   $0x1,%dl
  800ff8:	74 cd                	je     800fc7 <fork+0x135>
	void *addr = (void *)(pn * PGSIZE);
  800ffa:	89 c7                	mov    %eax,%edi
  800ffc:	c1 e7 0c             	shl    $0xc,%edi
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800fff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801006:	a9 02 08 00 00       	test   $0x802,%eax
  80100b:	75 83                	jne    800f90 <fork+0xfe>
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	6a 05                	push   $0x5
  801012:	57                   	push   %edi
  801013:	56                   	push   %esi
  801014:	57                   	push   %edi
  801015:	6a 00                	push   $0x0
  801017:	e8 13 fc ff ff       	call   800c2f <sys_page_map>
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	79 a4                	jns    800fc7 <fork+0x135>
		panic("sys_page_map: %e", r);
  801023:	50                   	push   %eax
  801024:	68 58 16 80 00       	push   $0x801658
  801029:	6a 50                	push   $0x50
  80102b:	68 4d 16 80 00       	push   $0x80164d
  801030:	e8 06 f1 ff ff       	call   80013b <_panic>

00801035 <sfork>:

// Challenge!
int
sfork(void)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80103b:	68 a3 16 80 00       	push   $0x8016a3
  801040:	68 93 00 00 00       	push   $0x93
  801045:	68 4d 16 80 00       	push   $0x80164d
  80104a:	e8 ec f0 ff ff       	call   80013b <_panic>

0080104f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801055:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80105c:	74 0a                	je     801068 <set_pgfault_handler+0x19>
		if (r < 0)
			cprintf("sys_env_set_pgfault_upcall: %d\n", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80105e:	8b 45 08             	mov    0x8(%ebp),%eax
  801061:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801066:	c9                   	leave  
  801067:	c3                   	ret    
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  801068:	a1 08 20 80 00       	mov    0x802008,%eax
  80106d:	8b 40 48             	mov    0x48(%eax),%eax
  801070:	83 ec 04             	sub    $0x4,%esp
  801073:	6a 07                	push   $0x7
  801075:	68 00 f0 bf ee       	push   $0xeebff000
  80107a:	50                   	push   %eax
  80107b:	e8 6c fb ff ff       	call   800bec <sys_page_alloc>
		if (r < 0)
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	78 29                	js     8010b0 <set_pgfault_handler+0x61>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	68 c3 10 80 00       	push   $0x8010c3
  80108f:	6a 00                	push   $0x0
  801091:	e8 5f fc ff ff       	call   800cf5 <sys_env_set_pgfault_upcall>
		if (r < 0)
  801096:	83 c4 10             	add    $0x10,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	79 c1                	jns    80105e <set_pgfault_handler+0xf>
			cprintf("sys_env_set_pgfault_upcall: %d\n", r);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	50                   	push   %eax
  8010a1:	68 10 17 80 00       	push   $0x801710
  8010a6:	e8 6b f1 ff ff       	call   800216 <cprintf>
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	eb ae                	jmp    80105e <set_pgfault_handler+0xf>
			cprintf("sys_page_alloc: %d\n", r);
  8010b0:	83 ec 08             	sub    $0x8,%esp
  8010b3:	50                   	push   %eax
  8010b4:	68 fb 16 80 00       	push   $0x8016fb
  8010b9:	e8 58 f1 ff ff       	call   800216 <cprintf>
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	eb c4                	jmp    801087 <set_pgfault_handler+0x38>

008010c3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010c3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010c4:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8010c9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010cb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx
  8010ce:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 0x30(%esp), %ecx
  8010d2:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	subl $0x4, %ecx
  8010d6:	83 e9 04             	sub    $0x4,%ecx
	movl %ebx, (%ecx)
  8010d9:	89 19                	mov    %ebx,(%ecx)
	movl %ecx, 0x30(%esp)
  8010db:	89 4c 24 30          	mov    %ecx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8010df:	83 c4 08             	add    $0x8,%esp
	popal
  8010e2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 
  8010e3:	83 c4 04             	add    $0x4,%esp
	popfl
  8010e6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8010e7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8010e8:	c3                   	ret    
  8010e9:	66 90                	xchg   %ax,%ax
  8010eb:	66 90                	xchg   %ax,%ax
  8010ed:	66 90                	xchg   %ax,%ax
  8010ef:	90                   	nop

008010f0 <__udivdi3>:
  8010f0:	f3 0f 1e fb          	endbr32 
  8010f4:	55                   	push   %ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 1c             	sub    $0x1c,%esp
  8010fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8010ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801103:	8b 74 24 34          	mov    0x34(%esp),%esi
  801107:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80110b:	85 c0                	test   %eax,%eax
  80110d:	75 19                	jne    801128 <__udivdi3+0x38>
  80110f:	39 f3                	cmp    %esi,%ebx
  801111:	76 4d                	jbe    801160 <__udivdi3+0x70>
  801113:	31 ff                	xor    %edi,%edi
  801115:	89 e8                	mov    %ebp,%eax
  801117:	89 f2                	mov    %esi,%edx
  801119:	f7 f3                	div    %ebx
  80111b:	89 fa                	mov    %edi,%edx
  80111d:	83 c4 1c             	add    $0x1c,%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5f                   	pop    %edi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    
  801125:	8d 76 00             	lea    0x0(%esi),%esi
  801128:	39 f0                	cmp    %esi,%eax
  80112a:	76 14                	jbe    801140 <__udivdi3+0x50>
  80112c:	31 ff                	xor    %edi,%edi
  80112e:	31 c0                	xor    %eax,%eax
  801130:	89 fa                	mov    %edi,%edx
  801132:	83 c4 1c             	add    $0x1c,%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    
  80113a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801140:	0f bd f8             	bsr    %eax,%edi
  801143:	83 f7 1f             	xor    $0x1f,%edi
  801146:	75 48                	jne    801190 <__udivdi3+0xa0>
  801148:	39 f0                	cmp    %esi,%eax
  80114a:	72 06                	jb     801152 <__udivdi3+0x62>
  80114c:	31 c0                	xor    %eax,%eax
  80114e:	39 eb                	cmp    %ebp,%ebx
  801150:	77 de                	ja     801130 <__udivdi3+0x40>
  801152:	b8 01 00 00 00       	mov    $0x1,%eax
  801157:	eb d7                	jmp    801130 <__udivdi3+0x40>
  801159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801160:	89 d9                	mov    %ebx,%ecx
  801162:	85 db                	test   %ebx,%ebx
  801164:	75 0b                	jne    801171 <__udivdi3+0x81>
  801166:	b8 01 00 00 00       	mov    $0x1,%eax
  80116b:	31 d2                	xor    %edx,%edx
  80116d:	f7 f3                	div    %ebx
  80116f:	89 c1                	mov    %eax,%ecx
  801171:	31 d2                	xor    %edx,%edx
  801173:	89 f0                	mov    %esi,%eax
  801175:	f7 f1                	div    %ecx
  801177:	89 c6                	mov    %eax,%esi
  801179:	89 e8                	mov    %ebp,%eax
  80117b:	89 f7                	mov    %esi,%edi
  80117d:	f7 f1                	div    %ecx
  80117f:	89 fa                	mov    %edi,%edx
  801181:	83 c4 1c             	add    $0x1c,%esp
  801184:	5b                   	pop    %ebx
  801185:	5e                   	pop    %esi
  801186:	5f                   	pop    %edi
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    
  801189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801190:	89 f9                	mov    %edi,%ecx
  801192:	ba 20 00 00 00       	mov    $0x20,%edx
  801197:	29 fa                	sub    %edi,%edx
  801199:	d3 e0                	shl    %cl,%eax
  80119b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119f:	89 d1                	mov    %edx,%ecx
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	d3 e8                	shr    %cl,%eax
  8011a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011a9:	09 c1                	or     %eax,%ecx
  8011ab:	89 f0                	mov    %esi,%eax
  8011ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011b1:	89 f9                	mov    %edi,%ecx
  8011b3:	d3 e3                	shl    %cl,%ebx
  8011b5:	89 d1                	mov    %edx,%ecx
  8011b7:	d3 e8                	shr    %cl,%eax
  8011b9:	89 f9                	mov    %edi,%ecx
  8011bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011bf:	89 eb                	mov    %ebp,%ebx
  8011c1:	d3 e6                	shl    %cl,%esi
  8011c3:	89 d1                	mov    %edx,%ecx
  8011c5:	d3 eb                	shr    %cl,%ebx
  8011c7:	09 f3                	or     %esi,%ebx
  8011c9:	89 c6                	mov    %eax,%esi
  8011cb:	89 f2                	mov    %esi,%edx
  8011cd:	89 d8                	mov    %ebx,%eax
  8011cf:	f7 74 24 08          	divl   0x8(%esp)
  8011d3:	89 d6                	mov    %edx,%esi
  8011d5:	89 c3                	mov    %eax,%ebx
  8011d7:	f7 64 24 0c          	mull   0xc(%esp)
  8011db:	39 d6                	cmp    %edx,%esi
  8011dd:	72 19                	jb     8011f8 <__udivdi3+0x108>
  8011df:	89 f9                	mov    %edi,%ecx
  8011e1:	d3 e5                	shl    %cl,%ebp
  8011e3:	39 c5                	cmp    %eax,%ebp
  8011e5:	73 04                	jae    8011eb <__udivdi3+0xfb>
  8011e7:	39 d6                	cmp    %edx,%esi
  8011e9:	74 0d                	je     8011f8 <__udivdi3+0x108>
  8011eb:	89 d8                	mov    %ebx,%eax
  8011ed:	31 ff                	xor    %edi,%edi
  8011ef:	e9 3c ff ff ff       	jmp    801130 <__udivdi3+0x40>
  8011f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8011fb:	31 ff                	xor    %edi,%edi
  8011fd:	e9 2e ff ff ff       	jmp    801130 <__udivdi3+0x40>
  801202:	66 90                	xchg   %ax,%ax
  801204:	66 90                	xchg   %ax,%ax
  801206:	66 90                	xchg   %ax,%ax
  801208:	66 90                	xchg   %ax,%ax
  80120a:	66 90                	xchg   %ax,%ax
  80120c:	66 90                	xchg   %ax,%ax
  80120e:	66 90                	xchg   %ax,%ax

00801210 <__umoddi3>:
  801210:	f3 0f 1e fb          	endbr32 
  801214:	55                   	push   %ebp
  801215:	57                   	push   %edi
  801216:	56                   	push   %esi
  801217:	53                   	push   %ebx
  801218:	83 ec 1c             	sub    $0x1c,%esp
  80121b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80121f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801223:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801227:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80122b:	89 f0                	mov    %esi,%eax
  80122d:	89 da                	mov    %ebx,%edx
  80122f:	85 ff                	test   %edi,%edi
  801231:	75 15                	jne    801248 <__umoddi3+0x38>
  801233:	39 dd                	cmp    %ebx,%ebp
  801235:	76 39                	jbe    801270 <__umoddi3+0x60>
  801237:	f7 f5                	div    %ebp
  801239:	89 d0                	mov    %edx,%eax
  80123b:	31 d2                	xor    %edx,%edx
  80123d:	83 c4 1c             	add    $0x1c,%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    
  801245:	8d 76 00             	lea    0x0(%esi),%esi
  801248:	39 df                	cmp    %ebx,%edi
  80124a:	77 f1                	ja     80123d <__umoddi3+0x2d>
  80124c:	0f bd cf             	bsr    %edi,%ecx
  80124f:	83 f1 1f             	xor    $0x1f,%ecx
  801252:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801256:	75 40                	jne    801298 <__umoddi3+0x88>
  801258:	39 df                	cmp    %ebx,%edi
  80125a:	72 04                	jb     801260 <__umoddi3+0x50>
  80125c:	39 f5                	cmp    %esi,%ebp
  80125e:	77 dd                	ja     80123d <__umoddi3+0x2d>
  801260:	89 da                	mov    %ebx,%edx
  801262:	89 f0                	mov    %esi,%eax
  801264:	29 e8                	sub    %ebp,%eax
  801266:	19 fa                	sbb    %edi,%edx
  801268:	eb d3                	jmp    80123d <__umoddi3+0x2d>
  80126a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801270:	89 e9                	mov    %ebp,%ecx
  801272:	85 ed                	test   %ebp,%ebp
  801274:	75 0b                	jne    801281 <__umoddi3+0x71>
  801276:	b8 01 00 00 00       	mov    $0x1,%eax
  80127b:	31 d2                	xor    %edx,%edx
  80127d:	f7 f5                	div    %ebp
  80127f:	89 c1                	mov    %eax,%ecx
  801281:	89 d8                	mov    %ebx,%eax
  801283:	31 d2                	xor    %edx,%edx
  801285:	f7 f1                	div    %ecx
  801287:	89 f0                	mov    %esi,%eax
  801289:	f7 f1                	div    %ecx
  80128b:	89 d0                	mov    %edx,%eax
  80128d:	31 d2                	xor    %edx,%edx
  80128f:	eb ac                	jmp    80123d <__umoddi3+0x2d>
  801291:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801298:	8b 44 24 04          	mov    0x4(%esp),%eax
  80129c:	ba 20 00 00 00       	mov    $0x20,%edx
  8012a1:	29 c2                	sub    %eax,%edx
  8012a3:	89 c1                	mov    %eax,%ecx
  8012a5:	89 e8                	mov    %ebp,%eax
  8012a7:	d3 e7                	shl    %cl,%edi
  8012a9:	89 d1                	mov    %edx,%ecx
  8012ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012af:	d3 e8                	shr    %cl,%eax
  8012b1:	89 c1                	mov    %eax,%ecx
  8012b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012b7:	09 f9                	or     %edi,%ecx
  8012b9:	89 df                	mov    %ebx,%edi
  8012bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012bf:	89 c1                	mov    %eax,%ecx
  8012c1:	d3 e5                	shl    %cl,%ebp
  8012c3:	89 d1                	mov    %edx,%ecx
  8012c5:	d3 ef                	shr    %cl,%edi
  8012c7:	89 c1                	mov    %eax,%ecx
  8012c9:	89 f0                	mov    %esi,%eax
  8012cb:	d3 e3                	shl    %cl,%ebx
  8012cd:	89 d1                	mov    %edx,%ecx
  8012cf:	89 fa                	mov    %edi,%edx
  8012d1:	d3 e8                	shr    %cl,%eax
  8012d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012d8:	09 d8                	or     %ebx,%eax
  8012da:	f7 74 24 08          	divl   0x8(%esp)
  8012de:	89 d3                	mov    %edx,%ebx
  8012e0:	d3 e6                	shl    %cl,%esi
  8012e2:	f7 e5                	mul    %ebp
  8012e4:	89 c7                	mov    %eax,%edi
  8012e6:	89 d1                	mov    %edx,%ecx
  8012e8:	39 d3                	cmp    %edx,%ebx
  8012ea:	72 06                	jb     8012f2 <__umoddi3+0xe2>
  8012ec:	75 0e                	jne    8012fc <__umoddi3+0xec>
  8012ee:	39 c6                	cmp    %eax,%esi
  8012f0:	73 0a                	jae    8012fc <__umoddi3+0xec>
  8012f2:	29 e8                	sub    %ebp,%eax
  8012f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8012f8:	89 d1                	mov    %edx,%ecx
  8012fa:	89 c7                	mov    %eax,%edi
  8012fc:	89 f5                	mov    %esi,%ebp
  8012fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  801302:	29 fd                	sub    %edi,%ebp
  801304:	19 cb                	sbb    %ecx,%ebx
  801306:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80130b:	89 d8                	mov    %ebx,%eax
  80130d:	d3 e0                	shl    %cl,%eax
  80130f:	89 f1                	mov    %esi,%ecx
  801311:	d3 ed                	shr    %cl,%ebp
  801313:	d3 eb                	shr    %cl,%ebx
  801315:	09 e8                	or     %ebp,%eax
  801317:	89 da                	mov    %ebx,%edx
  801319:	83 c4 1c             	add    $0x1c,%esp
  80131c:	5b                   	pop    %ebx
  80131d:	5e                   	pop    %esi
  80131e:	5f                   	pop    %edi
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    
