
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 00 13 80 00       	push   $0x801300
  80003f:	e8 5e 01 00 00       	call   8001a2 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 d5 0d 00 00       	call   800e1e <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 78 13 80 00       	push   $0x801378
  800058:	e8 45 01 00 00       	call   8001a2 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 28 13 80 00       	push   $0x801328
  80006c:	e8 31 01 00 00       	call   8001a2 <cprintf>
	sys_yield();
  800071:	e8 e3 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800076:	e8 de 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80007b:	e8 d9 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800080:	e8 d4 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800085:	e8 cf 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80008a:	e8 ca 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  80008f:	e8 c5 0a 00 00       	call   800b59 <sys_yield>
	sys_yield();
  800094:	e8 c0 0a 00 00       	call   800b59 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 50 13 80 00 	movl   $0x801350,(%esp)
  8000a0:	e8 fd 00 00 00       	call   8001a2 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 4c 0a 00 00       	call   800af9 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid;
	envid = sys_getenvid();
  8000c0:	e8 75 0a 00 00       	call   800b3a <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 f1 09 00 00       	call   800af9 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	74 09                	je     800135 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80012c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800130:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800133:	c9                   	leave  
  800134:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 76 09 00 00       	call   800abc <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	eb db                	jmp    80012c <putch+0x1f>

00800151 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	ff 75 0c             	push   0xc(%ebp)
  800171:	ff 75 08             	push   0x8(%ebp)
  800174:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	68 0d 01 80 00       	push   $0x80010d
  800180:	e8 14 01 00 00       	call   800299 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800185:	83 c4 08             	add    $0x8,%esp
  800188:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80018e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	e8 22 09 00 00       	call   800abc <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ab:	50                   	push   %eax
  8001ac:	ff 75 08             	push   0x8(%ebp)
  8001af:	e8 9d ff ff ff       	call   800151 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	89 c7                	mov    %eax,%edi
  8001c1:	89 d6                	mov    %edx,%esi
  8001c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c9:	89 d1                	mov    %edx,%ecx
  8001cb:	89 c2                	mov    %eax,%edx
  8001cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e3:	39 c2                	cmp    %eax,%edx
  8001e5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e8:	72 3e                	jb     800228 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	ff 75 18             	push   0x18(%ebp)
  8001f0:	83 eb 01             	sub    $0x1,%ebx
  8001f3:	53                   	push   %ebx
  8001f4:	50                   	push   %eax
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	ff 75 e4             	push   -0x1c(%ebp)
  8001fb:	ff 75 e0             	push   -0x20(%ebp)
  8001fe:	ff 75 dc             	push   -0x24(%ebp)
  800201:	ff 75 d8             	push   -0x28(%ebp)
  800204:	e8 b7 0e 00 00       	call   8010c0 <__udivdi3>
  800209:	83 c4 18             	add    $0x18,%esp
  80020c:	52                   	push   %edx
  80020d:	50                   	push   %eax
  80020e:	89 f2                	mov    %esi,%edx
  800210:	89 f8                	mov    %edi,%eax
  800212:	e8 9f ff ff ff       	call   8001b6 <printnum>
  800217:	83 c4 20             	add    $0x20,%esp
  80021a:	eb 13                	jmp    80022f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	56                   	push   %esi
  800220:	ff 75 18             	push   0x18(%ebp)
  800223:	ff d7                	call   *%edi
  800225:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800228:	83 eb 01             	sub    $0x1,%ebx
  80022b:	85 db                	test   %ebx,%ebx
  80022d:	7f ed                	jg     80021c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	83 ec 04             	sub    $0x4,%esp
  800236:	ff 75 e4             	push   -0x1c(%ebp)
  800239:	ff 75 e0             	push   -0x20(%ebp)
  80023c:	ff 75 dc             	push   -0x24(%ebp)
  80023f:	ff 75 d8             	push   -0x28(%ebp)
  800242:	e8 99 0f 00 00       	call   8011e0 <__umoddi3>
  800247:	83 c4 14             	add    $0x14,%esp
  80024a:	0f be 80 a0 13 80 00 	movsbl 0x8013a0(%eax),%eax
  800251:	50                   	push   %eax
  800252:	ff d7                	call   *%edi
}
  800254:	83 c4 10             	add    $0x10,%esp
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800265:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	3b 50 04             	cmp    0x4(%eax),%edx
  80026e:	73 0a                	jae    80027a <sprintputch+0x1b>
		*b->buf++ = ch;
  800270:	8d 4a 01             	lea    0x1(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	88 02                	mov    %al,(%edx)
}
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <printfmt>:
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800282:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800285:	50                   	push   %eax
  800286:	ff 75 10             	push   0x10(%ebp)
  800289:	ff 75 0c             	push   0xc(%ebp)
  80028c:	ff 75 08             	push   0x8(%ebp)
  80028f:	e8 05 00 00 00       	call   800299 <vprintfmt>
}
  800294:	83 c4 10             	add    $0x10,%esp
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <vprintfmt>:
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 3c             	sub    $0x3c,%esp
  8002a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ab:	eb 0a                	jmp    8002b7 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	53                   	push   %ebx
  8002b1:	50                   	push   %eax
  8002b2:	ff d6                	call   *%esi
  8002b4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b7:	83 c7 01             	add    $0x1,%edi
  8002ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002be:	83 f8 25             	cmp    $0x25,%eax
  8002c1:	74 0c                	je     8002cf <vprintfmt+0x36>
			if (ch == '\0')
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	75 e6                	jne    8002ad <vprintfmt+0x14>
}
  8002c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    
		padc = ' ';
  8002cf:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002d3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002da:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002ed:	8d 47 01             	lea    0x1(%edi),%eax
  8002f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f3:	0f b6 17             	movzbl (%edi),%edx
  8002f6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f9:	3c 55                	cmp    $0x55,%al
  8002fb:	0f 87 bb 03 00 00    	ja     8006bc <vprintfmt+0x423>
  800301:	0f b6 c0             	movzbl %al,%eax
  800304:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80030e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800312:	eb d9                	jmp    8002ed <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80031b:	eb d0                	jmp    8002ed <vprintfmt+0x54>
  80031d:	0f b6 d2             	movzbl %dl,%edx
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800323:	b8 00 00 00 00       	mov    $0x0,%eax
  800328:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80032b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800332:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800335:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800338:	83 f9 09             	cmp    $0x9,%ecx
  80033b:	77 55                	ja     800392 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80033d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800340:	eb e9                	jmp    80032b <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800342:	8b 45 14             	mov    0x14(%ebp),%eax
  800345:	8b 00                	mov    (%eax),%eax
  800347:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8d 40 04             	lea    0x4(%eax),%eax
  800350:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800356:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035a:	79 91                	jns    8002ed <vprintfmt+0x54>
				width = precision, precision = -1;
  80035c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80035f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800362:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800369:	eb 82                	jmp    8002ed <vprintfmt+0x54>
  80036b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80036e:	85 d2                	test   %edx,%edx
  800370:	b8 00 00 00 00       	mov    $0x0,%eax
  800375:	0f 49 c2             	cmovns %edx,%eax
  800378:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037e:	e9 6a ff ff ff       	jmp    8002ed <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800386:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80038d:	e9 5b ff ff ff       	jmp    8002ed <vprintfmt+0x54>
  800392:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800395:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800398:	eb bc                	jmp    800356 <vprintfmt+0xbd>
			lflag++;
  80039a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a0:	e9 48 ff ff ff       	jmp    8002ed <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 78 04             	lea    0x4(%eax),%edi
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	53                   	push   %ebx
  8003af:	ff 30                	push   (%eax)
  8003b1:	ff d6                	call   *%esi
			break;
  8003b3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b9:	e9 9d 02 00 00       	jmp    80065b <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 78 04             	lea    0x4(%eax),%edi
  8003c4:	8b 10                	mov    (%eax),%edx
  8003c6:	89 d0                	mov    %edx,%eax
  8003c8:	f7 d8                	neg    %eax
  8003ca:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cd:	83 f8 08             	cmp    $0x8,%eax
  8003d0:	7f 23                	jg     8003f5 <vprintfmt+0x15c>
  8003d2:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  8003d9:	85 d2                	test   %edx,%edx
  8003db:	74 18                	je     8003f5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003dd:	52                   	push   %edx
  8003de:	68 c1 13 80 00       	push   $0x8013c1
  8003e3:	53                   	push   %ebx
  8003e4:	56                   	push   %esi
  8003e5:	e8 92 fe ff ff       	call   80027c <printfmt>
  8003ea:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ed:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f0:	e9 66 02 00 00       	jmp    80065b <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8003f5:	50                   	push   %eax
  8003f6:	68 b8 13 80 00       	push   $0x8013b8
  8003fb:	53                   	push   %ebx
  8003fc:	56                   	push   %esi
  8003fd:	e8 7a fe ff ff       	call   80027c <printfmt>
  800402:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800405:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800408:	e9 4e 02 00 00       	jmp    80065b <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	83 c0 04             	add    $0x4,%eax
  800413:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80041b:	85 d2                	test   %edx,%edx
  80041d:	b8 b1 13 80 00       	mov    $0x8013b1,%eax
  800422:	0f 45 c2             	cmovne %edx,%eax
  800425:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800428:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042c:	7e 06                	jle    800434 <vprintfmt+0x19b>
  80042e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800432:	75 0d                	jne    800441 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800434:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800437:	89 c7                	mov    %eax,%edi
  800439:	03 45 e0             	add    -0x20(%ebp),%eax
  80043c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043f:	eb 55                	jmp    800496 <vprintfmt+0x1fd>
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	ff 75 d8             	push   -0x28(%ebp)
  800447:	ff 75 cc             	push   -0x34(%ebp)
  80044a:	e8 0a 03 00 00       	call   800759 <strnlen>
  80044f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800452:	29 c1                	sub    %eax,%ecx
  800454:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80045c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	eb 0f                	jmp    800474 <vprintfmt+0x1db>
					putch(padc, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	53                   	push   %ebx
  800469:	ff 75 e0             	push   -0x20(%ebp)
  80046c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	83 ef 01             	sub    $0x1,%edi
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	85 ff                	test   %edi,%edi
  800476:	7f ed                	jg     800465 <vprintfmt+0x1cc>
  800478:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80047b:	85 d2                	test   %edx,%edx
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	0f 49 c2             	cmovns %edx,%eax
  800485:	29 c2                	sub    %eax,%edx
  800487:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048a:	eb a8                	jmp    800434 <vprintfmt+0x19b>
					putch(ch, putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	53                   	push   %ebx
  800490:	52                   	push   %edx
  800491:	ff d6                	call   *%esi
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800499:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049b:	83 c7 01             	add    $0x1,%edi
  80049e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a2:	0f be d0             	movsbl %al,%edx
  8004a5:	85 d2                	test   %edx,%edx
  8004a7:	74 4b                	je     8004f4 <vprintfmt+0x25b>
  8004a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ad:	78 06                	js     8004b5 <vprintfmt+0x21c>
  8004af:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004b3:	78 1e                	js     8004d3 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b9:	74 d1                	je     80048c <vprintfmt+0x1f3>
  8004bb:	0f be c0             	movsbl %al,%eax
  8004be:	83 e8 20             	sub    $0x20,%eax
  8004c1:	83 f8 5e             	cmp    $0x5e,%eax
  8004c4:	76 c6                	jbe    80048c <vprintfmt+0x1f3>
					putch('?', putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	53                   	push   %ebx
  8004ca:	6a 3f                	push   $0x3f
  8004cc:	ff d6                	call   *%esi
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	eb c3                	jmp    800496 <vprintfmt+0x1fd>
  8004d3:	89 cf                	mov    %ecx,%edi
  8004d5:	eb 0e                	jmp    8004e5 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	53                   	push   %ebx
  8004db:	6a 20                	push   $0x20
  8004dd:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004df:	83 ef 01             	sub    $0x1,%edi
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	7f ee                	jg     8004d7 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ef:	e9 67 01 00 00       	jmp    80065b <vprintfmt+0x3c2>
  8004f4:	89 cf                	mov    %ecx,%edi
  8004f6:	eb ed                	jmp    8004e5 <vprintfmt+0x24c>
	if (lflag >= 2)
  8004f8:	83 f9 01             	cmp    $0x1,%ecx
  8004fb:	7f 1b                	jg     800518 <vprintfmt+0x27f>
	else if (lflag)
  8004fd:	85 c9                	test   %ecx,%ecx
  8004ff:	74 63                	je     800564 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8b 00                	mov    (%eax),%eax
  800506:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800509:	99                   	cltd   
  80050a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 40 04             	lea    0x4(%eax),%eax
  800513:	89 45 14             	mov    %eax,0x14(%ebp)
  800516:	eb 17                	jmp    80052f <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8b 50 04             	mov    0x4(%eax),%edx
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800523:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 40 08             	lea    0x8(%eax),%eax
  80052c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80052f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800532:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800535:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80053a:	85 c9                	test   %ecx,%ecx
  80053c:	0f 89 ff 00 00 00    	jns    800641 <vprintfmt+0x3a8>
				putch('-', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 2d                	push   $0x2d
  800548:	ff d6                	call   *%esi
				num = -(long long) num;
  80054a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800550:	f7 da                	neg    %edx
  800552:	83 d1 00             	adc    $0x0,%ecx
  800555:	f7 d9                	neg    %ecx
  800557:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055a:	bf 0a 00 00 00       	mov    $0xa,%edi
  80055f:	e9 dd 00 00 00       	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	99                   	cltd   
  80056d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
  800579:	eb b4                	jmp    80052f <vprintfmt+0x296>
	if (lflag >= 2)
  80057b:	83 f9 01             	cmp    $0x1,%ecx
  80057e:	7f 1e                	jg     80059e <vprintfmt+0x305>
	else if (lflag)
  800580:	85 c9                	test   %ecx,%ecx
  800582:	74 32                	je     8005b6 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 10                	mov    (%eax),%edx
  800589:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058e:	8d 40 04             	lea    0x4(%eax),%eax
  800591:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800594:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800599:	e9 a3 00 00 00       	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 10                	mov    (%eax),%edx
  8005a3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a6:	8d 40 08             	lea    0x8(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ac:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005b1:	e9 8b 00 00 00       	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c0:	8d 40 04             	lea    0x4(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005cb:	eb 74                	jmp    800641 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005cd:	83 f9 01             	cmp    $0x1,%ecx
  8005d0:	7f 1b                	jg     8005ed <vprintfmt+0x354>
	else if (lflag)
  8005d2:	85 c9                	test   %ecx,%ecx
  8005d4:	74 2c                	je     800602 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005e6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005eb:	eb 54                	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f5:	8d 40 08             	lea    0x8(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005fb:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800600:	eb 3f                	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 10                	mov    (%eax),%edx
  800607:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060c:	8d 40 04             	lea    0x4(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800612:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800617:	eb 28                	jmp    800641 <vprintfmt+0x3a8>
			putch('0', putdat);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 30                	push   $0x30
  80061f:	ff d6                	call   *%esi
			putch('x', putdat);
  800621:	83 c4 08             	add    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 78                	push   $0x78
  800627:	ff d6                	call   *%esi
			num = (unsigned long long)
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800633:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800636:	8d 40 04             	lea    0x4(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063c:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800648:	50                   	push   %eax
  800649:	ff 75 e0             	push   -0x20(%ebp)
  80064c:	57                   	push   %edi
  80064d:	51                   	push   %ecx
  80064e:	52                   	push   %edx
  80064f:	89 da                	mov    %ebx,%edx
  800651:	89 f0                	mov    %esi,%eax
  800653:	e8 5e fb ff ff       	call   8001b6 <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80065e:	e9 54 fc ff ff       	jmp    8002b7 <vprintfmt+0x1e>
	if (lflag >= 2)
  800663:	83 f9 01             	cmp    $0x1,%ecx
  800666:	7f 1b                	jg     800683 <vprintfmt+0x3ea>
	else if (lflag)
  800668:	85 c9                	test   %ecx,%ecx
  80066a:	74 2c                	je     800698 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800681:	eb be                	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	8b 48 04             	mov    0x4(%eax),%ecx
  80068b:	8d 40 08             	lea    0x8(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800691:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800696:	eb a9                	jmp    800641 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a2:	8d 40 04             	lea    0x4(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006ad:	eb 92                	jmp    800641 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 25                	push   $0x25
  8006b5:	ff d6                	call   *%esi
			break;
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 9f                	jmp    80065b <vprintfmt+0x3c2>
			putch('%', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 25                	push   $0x25
  8006c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	89 f8                	mov    %edi,%eax
  8006c9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006cd:	74 05                	je     8006d4 <vprintfmt+0x43b>
  8006cf:	83 e8 01             	sub    $0x1,%eax
  8006d2:	eb f5                	jmp    8006c9 <vprintfmt+0x430>
  8006d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d7:	eb 82                	jmp    80065b <vprintfmt+0x3c2>

008006d9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 18             	sub    $0x18,%esp
  8006df:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ec:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 26                	je     800720 <vsnprintf+0x47>
  8006fa:	85 d2                	test   %edx,%edx
  8006fc:	7e 22                	jle    800720 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fe:	ff 75 14             	push   0x14(%ebp)
  800701:	ff 75 10             	push   0x10(%ebp)
  800704:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800707:	50                   	push   %eax
  800708:	68 5f 02 80 00       	push   $0x80025f
  80070d:	e8 87 fb ff ff       	call   800299 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800712:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800715:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071b:	83 c4 10             	add    $0x10,%esp
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    
		return -E_INVAL;
  800720:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800725:	eb f7                	jmp    80071e <vsnprintf+0x45>

00800727 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800730:	50                   	push   %eax
  800731:	ff 75 10             	push   0x10(%ebp)
  800734:	ff 75 0c             	push   0xc(%ebp)
  800737:	ff 75 08             	push   0x8(%ebp)
  80073a:	e8 9a ff ff ff       	call   8006d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 03                	jmp    800751 <strlen+0x10>
		n++;
  80074e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800751:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800755:	75 f7                	jne    80074e <strlen+0xd>
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
  800767:	eb 03                	jmp    80076c <strnlen+0x13>
		n++;
  800769:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076c:	39 d0                	cmp    %edx,%eax
  80076e:	74 08                	je     800778 <strnlen+0x1f>
  800770:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800774:	75 f3                	jne    800769 <strnlen+0x10>
  800776:	89 c2                	mov    %eax,%edx
	return n;
}
  800778:	89 d0                	mov    %edx,%eax
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	53                   	push   %ebx
  800780:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80078f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800792:	83 c0 01             	add    $0x1,%eax
  800795:	84 d2                	test   %dl,%dl
  800797:	75 f2                	jne    80078b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800799:	89 c8                	mov    %ecx,%eax
  80079b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 10             	sub    $0x10,%esp
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	53                   	push   %ebx
  8007ab:	e8 91 ff ff ff       	call   800741 <strlen>
  8007b0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b3:	ff 75 0c             	push   0xc(%ebp)
  8007b6:	01 d8                	add    %ebx,%eax
  8007b8:	50                   	push   %eax
  8007b9:	e8 be ff ff ff       	call   80077c <strcpy>
	return dst;
}
  8007be:	89 d8                	mov    %ebx,%eax
  8007c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d0:	89 f3                	mov    %esi,%ebx
  8007d2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	89 f0                	mov    %esi,%eax
  8007d7:	eb 0f                	jmp    8007e8 <strncpy+0x23>
		*dst++ = *src;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	0f b6 0a             	movzbl (%edx),%ecx
  8007df:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e2:	80 f9 01             	cmp    $0x1,%cl
  8007e5:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007e8:	39 d8                	cmp    %ebx,%eax
  8007ea:	75 ed                	jne    8007d9 <strncpy+0x14>
	}
	return ret;
}
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fd:	8b 55 10             	mov    0x10(%ebp),%edx
  800800:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800802:	85 d2                	test   %edx,%edx
  800804:	74 21                	je     800827 <strlcpy+0x35>
  800806:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080a:	89 f2                	mov    %esi,%edx
  80080c:	eb 09                	jmp    800817 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	83 c2 01             	add    $0x1,%edx
  800814:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800817:	39 c2                	cmp    %eax,%edx
  800819:	74 09                	je     800824 <strlcpy+0x32>
  80081b:	0f b6 19             	movzbl (%ecx),%ebx
  80081e:	84 db                	test   %bl,%bl
  800820:	75 ec                	jne    80080e <strlcpy+0x1c>
  800822:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800824:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800827:	29 f0                	sub    %esi,%eax
}
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800836:	eb 06                	jmp    80083e <strcmp+0x11>
		p++, q++;
  800838:	83 c1 01             	add    $0x1,%ecx
  80083b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80083e:	0f b6 01             	movzbl (%ecx),%eax
  800841:	84 c0                	test   %al,%al
  800843:	74 04                	je     800849 <strcmp+0x1c>
  800845:	3a 02                	cmp    (%edx),%al
  800847:	74 ef                	je     800838 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	0f b6 12             	movzbl (%edx),%edx
  80084f:	29 d0                	sub    %edx,%eax
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 c3                	mov    %eax,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800862:	eb 06                	jmp    80086a <strncmp+0x17>
		n--, p++, q++;
  800864:	83 c0 01             	add    $0x1,%eax
  800867:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80086a:	39 d8                	cmp    %ebx,%eax
  80086c:	74 18                	je     800886 <strncmp+0x33>
  80086e:	0f b6 08             	movzbl (%eax),%ecx
  800871:	84 c9                	test   %cl,%cl
  800873:	74 04                	je     800879 <strncmp+0x26>
  800875:	3a 0a                	cmp    (%edx),%cl
  800877:	74 eb                	je     800864 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800879:	0f b6 00             	movzbl (%eax),%eax
  80087c:	0f b6 12             	movzbl (%edx),%edx
  80087f:	29 d0                	sub    %edx,%eax
}
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    
		return 0;
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	eb f4                	jmp    800881 <strncmp+0x2e>

0080088d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800897:	eb 03                	jmp    80089c <strchr+0xf>
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	0f b6 10             	movzbl (%eax),%edx
  80089f:	84 d2                	test   %dl,%dl
  8008a1:	74 06                	je     8008a9 <strchr+0x1c>
		if (*s == c)
  8008a3:	38 ca                	cmp    %cl,%dl
  8008a5:	75 f2                	jne    800899 <strchr+0xc>
  8008a7:	eb 05                	jmp    8008ae <strchr+0x21>
			return (char *) s;
	return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	74 09                	je     8008ca <strfind+0x1a>
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	74 05                	je     8008ca <strfind+0x1a>
	for (; *s; s++)
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	eb f0                	jmp    8008ba <strfind+0xa>
			break;
	return (char *) s;
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	57                   	push   %edi
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d8:	85 c9                	test   %ecx,%ecx
  8008da:	74 2f                	je     80090b <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dc:	89 f8                	mov    %edi,%eax
  8008de:	09 c8                	or     %ecx,%eax
  8008e0:	a8 03                	test   $0x3,%al
  8008e2:	75 21                	jne    800905 <memset+0x39>
		c &= 0xFF;
  8008e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e8:	89 d0                	mov    %edx,%eax
  8008ea:	c1 e0 08             	shl    $0x8,%eax
  8008ed:	89 d3                	mov    %edx,%ebx
  8008ef:	c1 e3 18             	shl    $0x18,%ebx
  8008f2:	89 d6                	mov    %edx,%esi
  8008f4:	c1 e6 10             	shl    $0x10,%esi
  8008f7:	09 f3                	or     %esi,%ebx
  8008f9:	09 da                	or     %ebx,%edx
  8008fb:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800900:	fc                   	cld    
  800901:	f3 ab                	rep stos %eax,%es:(%edi)
  800903:	eb 06                	jmp    80090b <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	fc                   	cld    
  800909:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090b:	89 f8                	mov    %edi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800920:	39 c6                	cmp    %eax,%esi
  800922:	73 32                	jae    800956 <memmove+0x44>
  800924:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800927:	39 c2                	cmp    %eax,%edx
  800929:	76 2b                	jbe    800956 <memmove+0x44>
		s += n;
		d += n;
  80092b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	89 d6                	mov    %edx,%esi
  800930:	09 fe                	or     %edi,%esi
  800932:	09 ce                	or     %ecx,%esi
  800934:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093a:	75 0e                	jne    80094a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093c:	83 ef 04             	sub    $0x4,%edi
  80093f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800942:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800945:	fd                   	std    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 09                	jmp    800953 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 1a                	jmp    800970 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	89 f2                	mov    %esi,%edx
  800958:	09 c2                	or     %eax,%edx
  80095a:	09 ca                	or     %ecx,%edx
  80095c:	f6 c2 03             	test   $0x3,%dl
  80095f:	75 0a                	jne    80096b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800961:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800969:	eb 05                	jmp    800970 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80096b:	89 c7                	mov    %eax,%edi
  80096d:	fc                   	cld    
  80096e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80097a:	ff 75 10             	push   0x10(%ebp)
  80097d:	ff 75 0c             	push   0xc(%ebp)
  800980:	ff 75 08             	push   0x8(%ebp)
  800983:	e8 8a ff ff ff       	call   800912 <memmove>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	89 c6                	mov    %eax,%esi
  800997:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099a:	eb 06                	jmp    8009a2 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80099c:	83 c0 01             	add    $0x1,%eax
  80099f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009a2:	39 f0                	cmp    %esi,%eax
  8009a4:	74 14                	je     8009ba <memcmp+0x30>
		if (*s1 != *s2)
  8009a6:	0f b6 08             	movzbl (%eax),%ecx
  8009a9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ac:	38 d9                	cmp    %bl,%cl
  8009ae:	74 ec                	je     80099c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009b0:	0f b6 c1             	movzbl %cl,%eax
  8009b3:	0f b6 db             	movzbl %bl,%ebx
  8009b6:	29 d8                	sub    %ebx,%eax
  8009b8:	eb 05                	jmp    8009bf <memcmp+0x35>
	}

	return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009cc:	89 c2                	mov    %eax,%edx
  8009ce:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d1:	eb 03                	jmp    8009d6 <memfind+0x13>
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	39 d0                	cmp    %edx,%eax
  8009d8:	73 04                	jae    8009de <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009da:	38 08                	cmp    %cl,(%eax)
  8009dc:	75 f5                	jne    8009d3 <memfind+0x10>
			break;
	return (void *) s;
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ec:	eb 03                	jmp    8009f1 <strtol+0x11>
		s++;
  8009ee:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009f1:	0f b6 02             	movzbl (%edx),%eax
  8009f4:	3c 20                	cmp    $0x20,%al
  8009f6:	74 f6                	je     8009ee <strtol+0xe>
  8009f8:	3c 09                	cmp    $0x9,%al
  8009fa:	74 f2                	je     8009ee <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009fc:	3c 2b                	cmp    $0x2b,%al
  8009fe:	74 2a                	je     800a2a <strtol+0x4a>
	int neg = 0;
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a05:	3c 2d                	cmp    $0x2d,%al
  800a07:	74 2b                	je     800a34 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a09:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0f:	75 0f                	jne    800a20 <strtol+0x40>
  800a11:	80 3a 30             	cmpb   $0x30,(%edx)
  800a14:	74 28                	je     800a3e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a16:	85 db                	test   %ebx,%ebx
  800a18:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a1d:	0f 44 d8             	cmove  %eax,%ebx
  800a20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a25:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a28:	eb 46                	jmp    800a70 <strtol+0x90>
		s++;
  800a2a:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a32:	eb d5                	jmp    800a09 <strtol+0x29>
		s++, neg = 1;
  800a34:	83 c2 01             	add    $0x1,%edx
  800a37:	bf 01 00 00 00       	mov    $0x1,%edi
  800a3c:	eb cb                	jmp    800a09 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a42:	74 0e                	je     800a52 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	75 d8                	jne    800a20 <strtol+0x40>
		s++, base = 8;
  800a48:	83 c2 01             	add    $0x1,%edx
  800a4b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a50:	eb ce                	jmp    800a20 <strtol+0x40>
		s += 2, base = 16;
  800a52:	83 c2 02             	add    $0x2,%edx
  800a55:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5a:	eb c4                	jmp    800a20 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a5c:	0f be c0             	movsbl %al,%eax
  800a5f:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a62:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a65:	7d 3a                	jge    800aa1 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a67:	83 c2 01             	add    $0x1,%edx
  800a6a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a6e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a70:	0f b6 02             	movzbl (%edx),%eax
  800a73:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 09             	cmp    $0x9,%bl
  800a7b:	76 df                	jbe    800a5c <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a7d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 08                	ja     800a8f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a87:	0f be c0             	movsbl %al,%eax
  800a8a:	83 e8 57             	sub    $0x57,%eax
  800a8d:	eb d3                	jmp    800a62 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a8f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 19             	cmp    $0x19,%bl
  800a97:	77 08                	ja     800aa1 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800a99:	0f be c0             	movsbl %al,%eax
  800a9c:	83 e8 37             	sub    $0x37,%eax
  800a9f:	eb c1                	jmp    800a62 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa5:	74 05                	je     800aac <strtol+0xcc>
		*endptr = (char *) s;
  800aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaa:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800aac:	89 c8                	mov    %ecx,%eax
  800aae:	f7 d8                	neg    %eax
  800ab0:	85 ff                	test   %edi,%edi
  800ab2:	0f 45 c8             	cmovne %eax,%ecx
}
  800ab5:	89 c8                	mov    %ecx,%eax
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acd:	89 c3                	mov    %eax,%ebx
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	89 c6                	mov    %eax,%esi
  800ad3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_cgetc>:

int
sys_cgetc(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b07:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0f:	89 cb                	mov    %ecx,%ebx
  800b11:	89 cf                	mov    %ecx,%edi
  800b13:	89 ce                	mov    %ecx,%esi
  800b15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	7f 08                	jg     800b23 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	50                   	push   %eax
  800b27:	6a 03                	push   $0x3
  800b29:	68 e4 15 80 00       	push   $0x8015e4
  800b2e:	6a 23                	push   $0x23
  800b30:	68 01 16 80 00       	push   $0x801601
  800b35:	e8 a1 04 00 00       	call   800fdb <_panic>

00800b3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4a:	89 d1                	mov    %edx,%ecx
  800b4c:	89 d3                	mov    %edx,%ebx
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_yield>:

void
sys_yield(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b69:	89 d1                	mov    %edx,%ecx
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	89 d7                	mov    %edx,%edi
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b81:	be 00 00 00 00       	mov    $0x0,%esi
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b94:	89 f7                	mov    %esi,%edi
  800b96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	7f 08                	jg     800ba4 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 04                	push   $0x4
  800baa:	68 e4 15 80 00       	push   $0x8015e4
  800baf:	6a 23                	push   $0x23
  800bb1:	68 01 16 80 00       	push   $0x801601
  800bb6:	e8 20 04 00 00       	call   800fdb <_panic>

00800bbb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7f 08                	jg     800be6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 05                	push   $0x5
  800bec:	68 e4 15 80 00       	push   $0x8015e4
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 01 16 80 00       	push   $0x801601
  800bf8:	e8 de 03 00 00       	call   800fdb <_panic>

00800bfd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	b8 06 00 00 00       	mov    $0x6,%eax
  800c16:	89 df                	mov    %ebx,%edi
  800c18:	89 de                	mov    %ebx,%esi
  800c1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7f 08                	jg     800c28 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 06                	push   $0x6
  800c2e:	68 e4 15 80 00       	push   $0x8015e4
  800c33:	6a 23                	push   $0x23
  800c35:	68 01 16 80 00       	push   $0x801601
  800c3a:	e8 9c 03 00 00       	call   800fdb <_panic>

00800c3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	b8 08 00 00 00       	mov    $0x8,%eax
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7f 08                	jg     800c6a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 08                	push   $0x8
  800c70:	68 e4 15 80 00       	push   $0x8015e4
  800c75:	6a 23                	push   $0x23
  800c77:	68 01 16 80 00       	push   $0x801601
  800c7c:	e8 5a 03 00 00       	call   800fdb <_panic>

00800c81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7f 08                	jg     800cac <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 09                	push   $0x9
  800cb2:	68 e4 15 80 00       	push   $0x8015e4
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 01 16 80 00       	push   $0x801601
  800cbe:	e8 18 03 00 00       	call   800fdb <_panic>

00800cc3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd4:	be 00 00 00 00       	mov    $0x0,%esi
  800cd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfc:	89 cb                	mov    %ecx,%ebx
  800cfe:	89 cf                	mov    %ecx,%edi
  800d00:	89 ce                	mov    %ecx,%esi
  800d02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7f 08                	jg     800d10 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 0c                	push   $0xc
  800d16:	68 e4 15 80 00       	push   $0x8015e4
  800d1b:	6a 23                	push   $0x23
  800d1d:	68 01 16 80 00       	push   $0x801601
  800d22:	e8 b4 02 00 00       	call   800fdb <_panic>

00800d27 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 04             	sub    $0x4,%esp
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d31:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(utf->utf_err & FEC_WR) || (uvpt[PGNUM(addr)] & perm) != perm) 
  800d33:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d37:	0f 84 81 00 00 00    	je     800dbe <pgfault+0x97>
  800d3d:	89 d8                	mov    %ebx,%eax
  800d3f:	c1 e8 0c             	shr    $0xc,%eax
  800d42:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d49:	25 05 08 00 00       	and    $0x805,%eax
  800d4e:	3d 05 08 00 00       	cmp    $0x805,%eax
  800d53:	75 69                	jne    800dbe <pgfault+0x97>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800d55:	83 ec 04             	sub    $0x4,%esp
  800d58:	6a 07                	push   $0x7
  800d5a:	68 00 f0 7f 00       	push   $0x7ff000
  800d5f:	6a 00                	push   $0x0
  800d61:	e8 12 fe ff ff       	call   800b78 <sys_page_alloc>
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	78 73                	js     800de0 <pgfault+0xb9>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800d6d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800d73:	83 ec 04             	sub    $0x4,%esp
  800d76:	68 00 10 00 00       	push   $0x1000
  800d7b:	53                   	push   %ebx
  800d7c:	68 00 f0 7f 00       	push   $0x7ff000
  800d81:	e8 ee fb ff ff       	call   800974 <memcpy>

	if ((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W | PTE_P | PTE_U)) < 0) 
  800d86:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800d8d:	53                   	push   %ebx
  800d8e:	6a 00                	push   $0x0
  800d90:	68 00 f0 7f 00       	push   $0x7ff000
  800d95:	6a 00                	push   $0x0
  800d97:	e8 1f fe ff ff       	call   800bbb <sys_page_map>
  800d9c:	83 c4 20             	add    $0x20,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	78 57                	js     800dfa <pgfault+0xd3>
	{
		panic("sys_page_map: %e", r);
	}

	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800da3:	83 ec 08             	sub    $0x8,%esp
  800da6:	68 00 f0 7f 00       	push   $0x7ff000
  800dab:	6a 00                	push   $0x0
  800dad:	e8 4b fe ff ff       	call   800bfd <sys_page_unmap>
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	85 c0                	test   %eax,%eax
  800db7:	78 53                	js     800e0c <pgfault+0xe5>
		panic("sys_page_unmap: %e", r);

}
  800db9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dbc:	c9                   	leave  
  800dbd:	c3                   	ret    
		panic("pgfault pte: %08x, addr: %08x", uvpt[PGNUM(addr)], addr);
  800dbe:	89 d8                	mov    %ebx,%eax
  800dc0:	c1 e8 0c             	shr    $0xc,%eax
  800dc3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	53                   	push   %ebx
  800dce:	50                   	push   %eax
  800dcf:	68 0f 16 80 00       	push   $0x80160f
  800dd4:	6a 1f                	push   $0x1f
  800dd6:	68 2d 16 80 00       	push   $0x80162d
  800ddb:	e8 fb 01 00 00       	call   800fdb <_panic>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	50                   	push   %eax
  800de4:	68 00 f0 7f 00       	push   $0x7ff000
  800de9:	68 9c 16 80 00       	push   $0x80169c
  800dee:	6a 2a                	push   $0x2a
  800df0:	68 2d 16 80 00       	push   $0x80162d
  800df5:	e8 e1 01 00 00       	call   800fdb <_panic>
		panic("sys_page_map: %e", r);
  800dfa:	50                   	push   %eax
  800dfb:	68 38 16 80 00       	push   $0x801638
  800e00:	6a 30                	push   $0x30
  800e02:	68 2d 16 80 00       	push   $0x80162d
  800e07:	e8 cf 01 00 00       	call   800fdb <_panic>
		panic("sys_page_unmap: %e", r);
  800e0c:	50                   	push   %eax
  800e0d:	68 49 16 80 00       	push   $0x801649
  800e12:	6a 34                	push   $0x34
  800e14:	68 2d 16 80 00       	push   $0x80162d
  800e19:	e8 bd 01 00 00       	call   800fdb <_panic>

00800e1e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 18             	sub    $0x18,%esp
	envid_t envid;
	pte_t pte;
	uint8_t *va;
	extern unsigned char end[];

	set_pgfault_handler(pgfault);
  800e27:	68 27 0d 80 00       	push   $0x800d27
  800e2c:	e8 f0 01 00 00       	call   801021 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e31:	b8 07 00 00 00       	mov    $0x7,%eax
  800e36:	cd 30                	int    $0x30
  800e38:	89 c6                	mov    %eax,%esi
	envid = sys_exofork(); // create child envirement
	if (envid < 0)
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	78 24                	js     800e65 <fork+0x47>
	{
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (va = 0; va < (uint8_t *)USTACKTOP; va += PGSIZE)
  800e41:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) 
  800e46:	0f 85 19 01 00 00    	jne    800f65 <fork+0x147>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e4c:	e8 e9 fc ff ff       	call   800b3a <sys_getenvid>
  800e51:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e56:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e59:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e5e:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e63:	eb 66                	jmp    800ecb <fork+0xad>
		panic("sys_exofork: %e", envid); //new envirement not created
  800e65:	50                   	push   %eax
  800e66:	68 5c 16 80 00       	push   $0x80165c
  800e6b:	6a 78                	push   $0x78
  800e6d:	68 2d 16 80 00       	push   $0x80162d
  800e72:	e8 64 01 00 00       	call   800fdb <_panic>
		panic("sys_page_map: %e", r);
  800e77:	50                   	push   %eax
  800e78:	68 38 16 80 00       	push   $0x801638
  800e7d:	6a 56                	push   $0x56
  800e7f:	68 2d 16 80 00       	push   $0x80162d
  800e84:	e8 52 01 00 00       	call   800fdb <_panic>
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P))
			duppage(envid, PGNUM(va));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  800e89:	83 ec 04             	sub    $0x4,%esp
  800e8c:	6a 07                	push   $0x7
  800e8e:	68 00 f0 bf ee       	push   $0xeebff000
  800e93:	56                   	push   %esi
  800e94:	e8 df fc ff ff       	call   800b78 <sys_page_alloc>
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	78 35                	js     800ed5 <fork+0xb7>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);

	if ((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800ea0:	a1 04 20 80 00       	mov    0x802004,%eax
  800ea5:	8b 40 64             	mov    0x64(%eax),%eax
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	50                   	push   %eax
  800eac:	56                   	push   %esi
  800ead:	e8 cf fd ff ff       	call   800c81 <sys_env_set_pgfault_upcall>
  800eb2:	83 c4 10             	add    $0x10,%esp
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	78 39                	js     800ef2 <fork+0xd4>
		panic("sys_env_set_pgfault_upcall: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	6a 02                	push   $0x2
  800ebe:	56                   	push   %esi
  800ebf:	e8 7b fd ff ff       	call   800c3f <sys_env_set_status>
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	78 3c                	js     800f07 <fork+0xe9>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800ecb:	89 f0                	mov    %esi,%eax
  800ecd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    
		panic("allocating at %x in pgfault: %e", PFTEMP, r);
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	50                   	push   %eax
  800ed9:	68 00 f0 7f 00       	push   $0x7ff000
  800ede:	68 9c 16 80 00       	push   $0x80169c
  800ee3:	68 84 00 00 00       	push   $0x84
  800ee8:	68 2d 16 80 00       	push   $0x80162d
  800eed:	e8 e9 00 00 00       	call   800fdb <_panic>
		panic("sys_env_set_pgfault_upcall: %e", r);
  800ef2:	50                   	push   %eax
  800ef3:	68 bc 16 80 00       	push   $0x8016bc
  800ef8:	68 87 00 00 00       	push   $0x87
  800efd:	68 2d 16 80 00       	push   $0x80162d
  800f02:	e8 d4 00 00 00       	call   800fdb <_panic>
		panic("sys_env_set_status: %e", r);
  800f07:	50                   	push   %eax
  800f08:	68 6c 16 80 00       	push   $0x80166c
  800f0d:	68 8a 00 00 00       	push   $0x8a
  800f12:	68 2d 16 80 00       	push   $0x80162d
  800f17:	e8 bf 00 00 00       	call   800fdb <_panic>
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f1c:	83 ec 0c             	sub    $0xc,%esp
  800f1f:	68 05 08 00 00       	push   $0x805
  800f24:	57                   	push   %edi
  800f25:	56                   	push   %esi
  800f26:	57                   	push   %edi
  800f27:	6a 00                	push   $0x0
  800f29:	e8 8d fc ff ff       	call   800bbb <sys_page_map>
  800f2e:	83 c4 20             	add    $0x20,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	78 7a                	js     800faf <fork+0x191>
	if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  800f35:	83 ec 0c             	sub    $0xc,%esp
  800f38:	68 05 08 00 00       	push   $0x805
  800f3d:	57                   	push   %edi
  800f3e:	6a 00                	push   $0x0
  800f40:	57                   	push   %edi
  800f41:	6a 00                	push   $0x0
  800f43:	e8 73 fc ff ff       	call   800bbb <sys_page_map>
  800f48:	83 c4 20             	add    $0x20,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	0f 88 24 ff ff ff    	js     800e77 <fork+0x59>
	for (va = 0; va < (uint8_t *)USTACKTOP; va += PGSIZE)
  800f53:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f59:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f5f:	0f 84 24 ff ff ff    	je     800e89 <fork+0x6b>
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P))
  800f65:	89 d8                	mov    %ebx,%eax
  800f67:	c1 e8 16             	shr    $0x16,%eax
  800f6a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f71:	a8 01                	test   $0x1,%al
  800f73:	74 de                	je     800f53 <fork+0x135>
  800f75:	89 d8                	mov    %ebx,%eax
  800f77:	c1 e8 0c             	shr    $0xc,%eax
  800f7a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f81:	f6 c2 01             	test   $0x1,%dl
  800f84:	74 cd                	je     800f53 <fork+0x135>
	void *addr = (void *)(pn * PGSIZE);
  800f86:	89 c7                	mov    %eax,%edi
  800f88:	c1 e7 0c             	shl    $0xc,%edi
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800f8b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f92:	a9 02 08 00 00       	test   $0x802,%eax
  800f97:	75 83                	jne    800f1c <fork+0xfe>
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	6a 05                	push   $0x5
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	57                   	push   %edi
  800fa1:	6a 00                	push   $0x0
  800fa3:	e8 13 fc ff ff       	call   800bbb <sys_page_map>
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	79 a4                	jns    800f53 <fork+0x135>
		panic("sys_page_map: %e", r);
  800faf:	50                   	push   %eax
  800fb0:	68 38 16 80 00       	push   $0x801638
  800fb5:	6a 50                	push   $0x50
  800fb7:	68 2d 16 80 00       	push   $0x80162d
  800fbc:	e8 1a 00 00 00       	call   800fdb <_panic>

00800fc1 <sfork>:

// Challenge!
int
sfork(void)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fc7:	68 83 16 80 00       	push   $0x801683
  800fcc:	68 93 00 00 00       	push   $0x93
  800fd1:	68 2d 16 80 00       	push   $0x80162d
  800fd6:	e8 00 00 00 00       	call   800fdb <_panic>

00800fdb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fe0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fe3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fe9:	e8 4c fb ff ff       	call   800b3a <sys_getenvid>
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	ff 75 0c             	push   0xc(%ebp)
  800ff4:	ff 75 08             	push   0x8(%ebp)
  800ff7:	56                   	push   %esi
  800ff8:	50                   	push   %eax
  800ff9:	68 dc 16 80 00       	push   $0x8016dc
  800ffe:	e8 9f f1 ff ff       	call   8001a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801003:	83 c4 18             	add    $0x18,%esp
  801006:	53                   	push   %ebx
  801007:	ff 75 10             	push   0x10(%ebp)
  80100a:	e8 42 f1 ff ff       	call   800151 <vcprintf>
	cprintf("\n");
  80100f:	c7 04 24 94 13 80 00 	movl   $0x801394,(%esp)
  801016:	e8 87 f1 ff ff       	call   8001a2 <cprintf>
  80101b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80101e:	cc                   	int3   
  80101f:	eb fd                	jmp    80101e <_panic+0x43>

00801021 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801027:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80102e:	74 0a                	je     80103a <set_pgfault_handler+0x19>
		if (r < 0)
			cprintf("sys_env_set_pgfault_upcall: %d\n", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
  801033:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  80103a:	a1 04 20 80 00       	mov    0x802004,%eax
  80103f:	8b 40 48             	mov    0x48(%eax),%eax
  801042:	83 ec 04             	sub    $0x4,%esp
  801045:	6a 07                	push   $0x7
  801047:	68 00 f0 bf ee       	push   $0xeebff000
  80104c:	50                   	push   %eax
  80104d:	e8 26 fb ff ff       	call   800b78 <sys_page_alloc>
		if (r < 0)
  801052:	83 c4 10             	add    $0x10,%esp
  801055:	85 c0                	test   %eax,%eax
  801057:	78 29                	js     801082 <set_pgfault_handler+0x61>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801059:	83 ec 08             	sub    $0x8,%esp
  80105c:	68 95 10 80 00       	push   $0x801095
  801061:	6a 00                	push   $0x0
  801063:	e8 19 fc ff ff       	call   800c81 <sys_env_set_pgfault_upcall>
		if (r < 0)
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	79 c1                	jns    801030 <set_pgfault_handler+0xf>
			cprintf("sys_env_set_pgfault_upcall: %d\n", r);
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	50                   	push   %eax
  801073:	68 14 17 80 00       	push   $0x801714
  801078:	e8 25 f1 ff ff       	call   8001a2 <cprintf>
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	eb ae                	jmp    801030 <set_pgfault_handler+0xf>
			cprintf("sys_page_alloc: %d\n", r);
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	50                   	push   %eax
  801086:	68 ff 16 80 00       	push   $0x8016ff
  80108b:	e8 12 f1 ff ff       	call   8001a2 <cprintf>
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	eb c4                	jmp    801059 <set_pgfault_handler+0x38>

00801095 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801095:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801096:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80109b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80109d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx
  8010a0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 0x30(%esp), %ecx
  8010a4:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	subl $0x4, %ecx
  8010a8:	83 e9 04             	sub    $0x4,%ecx
	movl %ebx, (%ecx)
  8010ab:	89 19                	mov    %ebx,(%ecx)
	movl %ecx, 0x30(%esp)
  8010ad:	89 4c 24 30          	mov    %ecx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8010b1:	83 c4 08             	add    $0x8,%esp
	popal
  8010b4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 
  8010b5:	83 c4 04             	add    $0x4,%esp
	popfl
  8010b8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8010b9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8010ba:	c3                   	ret    
  8010bb:	66 90                	xchg   %ax,%ax
  8010bd:	66 90                	xchg   %ax,%ax
  8010bf:	90                   	nop

008010c0 <__udivdi3>:
  8010c0:	f3 0f 1e fb          	endbr32 
  8010c4:	55                   	push   %ebp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 1c             	sub    $0x1c,%esp
  8010cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8010cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8010d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8010d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	75 19                	jne    8010f8 <__udivdi3+0x38>
  8010df:	39 f3                	cmp    %esi,%ebx
  8010e1:	76 4d                	jbe    801130 <__udivdi3+0x70>
  8010e3:	31 ff                	xor    %edi,%edi
  8010e5:	89 e8                	mov    %ebp,%eax
  8010e7:	89 f2                	mov    %esi,%edx
  8010e9:	f7 f3                	div    %ebx
  8010eb:	89 fa                	mov    %edi,%edx
  8010ed:	83 c4 1c             	add    $0x1c,%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    
  8010f5:	8d 76 00             	lea    0x0(%esi),%esi
  8010f8:	39 f0                	cmp    %esi,%eax
  8010fa:	76 14                	jbe    801110 <__udivdi3+0x50>
  8010fc:	31 ff                	xor    %edi,%edi
  8010fe:	31 c0                	xor    %eax,%eax
  801100:	89 fa                	mov    %edi,%edx
  801102:	83 c4 1c             	add    $0x1c,%esp
  801105:	5b                   	pop    %ebx
  801106:	5e                   	pop    %esi
  801107:	5f                   	pop    %edi
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    
  80110a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801110:	0f bd f8             	bsr    %eax,%edi
  801113:	83 f7 1f             	xor    $0x1f,%edi
  801116:	75 48                	jne    801160 <__udivdi3+0xa0>
  801118:	39 f0                	cmp    %esi,%eax
  80111a:	72 06                	jb     801122 <__udivdi3+0x62>
  80111c:	31 c0                	xor    %eax,%eax
  80111e:	39 eb                	cmp    %ebp,%ebx
  801120:	77 de                	ja     801100 <__udivdi3+0x40>
  801122:	b8 01 00 00 00       	mov    $0x1,%eax
  801127:	eb d7                	jmp    801100 <__udivdi3+0x40>
  801129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801130:	89 d9                	mov    %ebx,%ecx
  801132:	85 db                	test   %ebx,%ebx
  801134:	75 0b                	jne    801141 <__udivdi3+0x81>
  801136:	b8 01 00 00 00       	mov    $0x1,%eax
  80113b:	31 d2                	xor    %edx,%edx
  80113d:	f7 f3                	div    %ebx
  80113f:	89 c1                	mov    %eax,%ecx
  801141:	31 d2                	xor    %edx,%edx
  801143:	89 f0                	mov    %esi,%eax
  801145:	f7 f1                	div    %ecx
  801147:	89 c6                	mov    %eax,%esi
  801149:	89 e8                	mov    %ebp,%eax
  80114b:	89 f7                	mov    %esi,%edi
  80114d:	f7 f1                	div    %ecx
  80114f:	89 fa                	mov    %edi,%edx
  801151:	83 c4 1c             	add    $0x1c,%esp
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    
  801159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801160:	89 f9                	mov    %edi,%ecx
  801162:	ba 20 00 00 00       	mov    $0x20,%edx
  801167:	29 fa                	sub    %edi,%edx
  801169:	d3 e0                	shl    %cl,%eax
  80116b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80116f:	89 d1                	mov    %edx,%ecx
  801171:	89 d8                	mov    %ebx,%eax
  801173:	d3 e8                	shr    %cl,%eax
  801175:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801179:	09 c1                	or     %eax,%ecx
  80117b:	89 f0                	mov    %esi,%eax
  80117d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801181:	89 f9                	mov    %edi,%ecx
  801183:	d3 e3                	shl    %cl,%ebx
  801185:	89 d1                	mov    %edx,%ecx
  801187:	d3 e8                	shr    %cl,%eax
  801189:	89 f9                	mov    %edi,%ecx
  80118b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80118f:	89 eb                	mov    %ebp,%ebx
  801191:	d3 e6                	shl    %cl,%esi
  801193:	89 d1                	mov    %edx,%ecx
  801195:	d3 eb                	shr    %cl,%ebx
  801197:	09 f3                	or     %esi,%ebx
  801199:	89 c6                	mov    %eax,%esi
  80119b:	89 f2                	mov    %esi,%edx
  80119d:	89 d8                	mov    %ebx,%eax
  80119f:	f7 74 24 08          	divl   0x8(%esp)
  8011a3:	89 d6                	mov    %edx,%esi
  8011a5:	89 c3                	mov    %eax,%ebx
  8011a7:	f7 64 24 0c          	mull   0xc(%esp)
  8011ab:	39 d6                	cmp    %edx,%esi
  8011ad:	72 19                	jb     8011c8 <__udivdi3+0x108>
  8011af:	89 f9                	mov    %edi,%ecx
  8011b1:	d3 e5                	shl    %cl,%ebp
  8011b3:	39 c5                	cmp    %eax,%ebp
  8011b5:	73 04                	jae    8011bb <__udivdi3+0xfb>
  8011b7:	39 d6                	cmp    %edx,%esi
  8011b9:	74 0d                	je     8011c8 <__udivdi3+0x108>
  8011bb:	89 d8                	mov    %ebx,%eax
  8011bd:	31 ff                	xor    %edi,%edi
  8011bf:	e9 3c ff ff ff       	jmp    801100 <__udivdi3+0x40>
  8011c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8011cb:	31 ff                	xor    %edi,%edi
  8011cd:	e9 2e ff ff ff       	jmp    801100 <__udivdi3+0x40>
  8011d2:	66 90                	xchg   %ax,%ax
  8011d4:	66 90                	xchg   %ax,%ax
  8011d6:	66 90                	xchg   %ax,%ax
  8011d8:	66 90                	xchg   %ax,%ax
  8011da:	66 90                	xchg   %ax,%ax
  8011dc:	66 90                	xchg   %ax,%ax
  8011de:	66 90                	xchg   %ax,%ax

008011e0 <__umoddi3>:
  8011e0:	f3 0f 1e fb          	endbr32 
  8011e4:	55                   	push   %ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 1c             	sub    $0x1c,%esp
  8011eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8011ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8011f3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8011f7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8011fb:	89 f0                	mov    %esi,%eax
  8011fd:	89 da                	mov    %ebx,%edx
  8011ff:	85 ff                	test   %edi,%edi
  801201:	75 15                	jne    801218 <__umoddi3+0x38>
  801203:	39 dd                	cmp    %ebx,%ebp
  801205:	76 39                	jbe    801240 <__umoddi3+0x60>
  801207:	f7 f5                	div    %ebp
  801209:	89 d0                	mov    %edx,%eax
  80120b:	31 d2                	xor    %edx,%edx
  80120d:	83 c4 1c             	add    $0x1c,%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    
  801215:	8d 76 00             	lea    0x0(%esi),%esi
  801218:	39 df                	cmp    %ebx,%edi
  80121a:	77 f1                	ja     80120d <__umoddi3+0x2d>
  80121c:	0f bd cf             	bsr    %edi,%ecx
  80121f:	83 f1 1f             	xor    $0x1f,%ecx
  801222:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801226:	75 40                	jne    801268 <__umoddi3+0x88>
  801228:	39 df                	cmp    %ebx,%edi
  80122a:	72 04                	jb     801230 <__umoddi3+0x50>
  80122c:	39 f5                	cmp    %esi,%ebp
  80122e:	77 dd                	ja     80120d <__umoddi3+0x2d>
  801230:	89 da                	mov    %ebx,%edx
  801232:	89 f0                	mov    %esi,%eax
  801234:	29 e8                	sub    %ebp,%eax
  801236:	19 fa                	sbb    %edi,%edx
  801238:	eb d3                	jmp    80120d <__umoddi3+0x2d>
  80123a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801240:	89 e9                	mov    %ebp,%ecx
  801242:	85 ed                	test   %ebp,%ebp
  801244:	75 0b                	jne    801251 <__umoddi3+0x71>
  801246:	b8 01 00 00 00       	mov    $0x1,%eax
  80124b:	31 d2                	xor    %edx,%edx
  80124d:	f7 f5                	div    %ebp
  80124f:	89 c1                	mov    %eax,%ecx
  801251:	89 d8                	mov    %ebx,%eax
  801253:	31 d2                	xor    %edx,%edx
  801255:	f7 f1                	div    %ecx
  801257:	89 f0                	mov    %esi,%eax
  801259:	f7 f1                	div    %ecx
  80125b:	89 d0                	mov    %edx,%eax
  80125d:	31 d2                	xor    %edx,%edx
  80125f:	eb ac                	jmp    80120d <__umoddi3+0x2d>
  801261:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801268:	8b 44 24 04          	mov    0x4(%esp),%eax
  80126c:	ba 20 00 00 00       	mov    $0x20,%edx
  801271:	29 c2                	sub    %eax,%edx
  801273:	89 c1                	mov    %eax,%ecx
  801275:	89 e8                	mov    %ebp,%eax
  801277:	d3 e7                	shl    %cl,%edi
  801279:	89 d1                	mov    %edx,%ecx
  80127b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80127f:	d3 e8                	shr    %cl,%eax
  801281:	89 c1                	mov    %eax,%ecx
  801283:	8b 44 24 04          	mov    0x4(%esp),%eax
  801287:	09 f9                	or     %edi,%ecx
  801289:	89 df                	mov    %ebx,%edi
  80128b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80128f:	89 c1                	mov    %eax,%ecx
  801291:	d3 e5                	shl    %cl,%ebp
  801293:	89 d1                	mov    %edx,%ecx
  801295:	d3 ef                	shr    %cl,%edi
  801297:	89 c1                	mov    %eax,%ecx
  801299:	89 f0                	mov    %esi,%eax
  80129b:	d3 e3                	shl    %cl,%ebx
  80129d:	89 d1                	mov    %edx,%ecx
  80129f:	89 fa                	mov    %edi,%edx
  8012a1:	d3 e8                	shr    %cl,%eax
  8012a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a8:	09 d8                	or     %ebx,%eax
  8012aa:	f7 74 24 08          	divl   0x8(%esp)
  8012ae:	89 d3                	mov    %edx,%ebx
  8012b0:	d3 e6                	shl    %cl,%esi
  8012b2:	f7 e5                	mul    %ebp
  8012b4:	89 c7                	mov    %eax,%edi
  8012b6:	89 d1                	mov    %edx,%ecx
  8012b8:	39 d3                	cmp    %edx,%ebx
  8012ba:	72 06                	jb     8012c2 <__umoddi3+0xe2>
  8012bc:	75 0e                	jne    8012cc <__umoddi3+0xec>
  8012be:	39 c6                	cmp    %eax,%esi
  8012c0:	73 0a                	jae    8012cc <__umoddi3+0xec>
  8012c2:	29 e8                	sub    %ebp,%eax
  8012c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8012c8:	89 d1                	mov    %edx,%ecx
  8012ca:	89 c7                	mov    %eax,%edi
  8012cc:	89 f5                	mov    %esi,%ebp
  8012ce:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012d2:	29 fd                	sub    %edi,%ebp
  8012d4:	19 cb                	sbb    %ecx,%ebx
  8012d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8012db:	89 d8                	mov    %ebx,%eax
  8012dd:	d3 e0                	shl    %cl,%eax
  8012df:	89 f1                	mov    %esi,%ecx
  8012e1:	d3 ed                	shr    %cl,%ebp
  8012e3:	d3 eb                	shr    %cl,%ebx
  8012e5:	09 e8                	or     %ebp,%eax
  8012e7:	89 da                	mov    %ebx,%edx
  8012e9:	83 c4 1c             	add    $0x1c,%esp
  8012ec:	5b                   	pop    %ebx
  8012ed:	5e                   	pop    %esi
  8012ee:	5f                   	pop    %edi
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    
