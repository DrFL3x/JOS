
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 e8 0d 00 00       	call   800e29 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 4f                	jne    800097 <umain+0x64>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004b:	83 ec 04             	sub    $0x4,%esp
  80004e:	6a 00                	push   $0x0
  800050:	6a 00                	push   $0x0
  800052:	56                   	push   %esi
  800053:	e8 8e 0f 00 00       	call   800fe6 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 e3 0a 00 00       	call   800b45 <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 16 14 80 00       	push   $0x801416
  80006a:	e8 3e 01 00 00       	call   8001ad <cprintf>
		if (i == 10)
  80006f:	83 c4 20             	add    $0x20,%esp
  800072:	83 fb 0a             	cmp    $0xa,%ebx
  800075:	74 18                	je     80008f <umain+0x5c>
			return;
		i++;
  800077:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	ff 75 e4             	push   -0x1c(%ebp)
  800082:	e8 c2 0f 00 00       	call   801049 <ipc_send>
		if (i == 10)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	83 fb 0a             	cmp    $0xa,%ebx
  80008d:	75 bc                	jne    80004b <umain+0x18>
			return;
	}

}
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
  800097:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800099:	e8 a7 0a 00 00       	call   800b45 <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 00 14 80 00       	push   $0x801400
  8000a8:	e8 00 01 00 00       	call   8001ad <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	push   -0x1c(%ebp)
  8000b6:	e8 8e 0f 00 00       	call   801049 <ipc_send>
  8000bb:	83 c4 20             	add    $0x20,%esp
  8000be:	eb 88                	jmp    800048 <umain+0x15>

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid;
	envid = sys_getenvid();
  8000cb:	e8 75 0a 00 00       	call   800b45 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dd:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e2:	85 db                	test   %ebx,%ebx
  8000e4:	7e 07                	jle    8000ed <libmain+0x2d>
		binaryname = argv[0];
  8000e6:	8b 06                	mov    (%esi),%eax
  8000e8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	e8 3c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f7:	e8 0a 00 00 00       	call   800106 <exit>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010c:	6a 00                	push   $0x0
  80010e:	e8 f1 09 00 00       	call   800b04 <sys_env_destroy>
}
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 04             	sub    $0x4,%esp
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800122:	8b 13                	mov    (%ebx),%edx
  800124:	8d 42 01             	lea    0x1(%edx),%eax
  800127:	89 03                	mov    %eax,(%ebx)
  800129:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800130:	3d ff 00 00 00       	cmp    $0xff,%eax
  800135:	74 09                	je     800140 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800137:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 76 09 00 00       	call   800ac7 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb db                	jmp    800137 <putch+0x1f>

0080015c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800165:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016c:	00 00 00 
	b.cnt = 0;
  80016f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800176:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800179:	ff 75 0c             	push   0xc(%ebp)
  80017c:	ff 75 08             	push   0x8(%ebp)
  80017f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800185:	50                   	push   %eax
  800186:	68 18 01 80 00       	push   $0x800118
  80018b:	e8 14 01 00 00       	call   8002a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800190:	83 c4 08             	add    $0x8,%esp
  800193:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800199:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 22 09 00 00       	call   800ac7 <sys_cputs>

	return b.cnt;
}
  8001a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b6:	50                   	push   %eax
  8001b7:	ff 75 08             	push   0x8(%ebp)
  8001ba:	e8 9d ff ff ff       	call   80015c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	56                   	push   %esi
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 1c             	sub    $0x1c,%esp
  8001ca:	89 c7                	mov    %eax,%edi
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d4:	89 d1                	mov    %edx,%ecx
  8001d6:	89 c2                	mov    %eax,%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001de:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ee:	39 c2                	cmp    %eax,%edx
  8001f0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001f3:	72 3e                	jb     800233 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	push   0x18(%ebp)
  8001fb:	83 eb 01             	sub    $0x1,%ebx
  8001fe:	53                   	push   %ebx
  8001ff:	50                   	push   %eax
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	ff 75 e4             	push   -0x1c(%ebp)
  800206:	ff 75 e0             	push   -0x20(%ebp)
  800209:	ff 75 dc             	push   -0x24(%ebp)
  80020c:	ff 75 d8             	push   -0x28(%ebp)
  80020f:	e8 ac 0f 00 00       	call   8011c0 <__udivdi3>
  800214:	83 c4 18             	add    $0x18,%esp
  800217:	52                   	push   %edx
  800218:	50                   	push   %eax
  800219:	89 f2                	mov    %esi,%edx
  80021b:	89 f8                	mov    %edi,%eax
  80021d:	e8 9f ff ff ff       	call   8001c1 <printnum>
  800222:	83 c4 20             	add    $0x20,%esp
  800225:	eb 13                	jmp    80023a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	ff 75 18             	push   0x18(%ebp)
  80022e:	ff d7                	call   *%edi
  800230:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800233:	83 eb 01             	sub    $0x1,%ebx
  800236:	85 db                	test   %ebx,%ebx
  800238:	7f ed                	jg     800227 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	56                   	push   %esi
  80023e:	83 ec 04             	sub    $0x4,%esp
  800241:	ff 75 e4             	push   -0x1c(%ebp)
  800244:	ff 75 e0             	push   -0x20(%ebp)
  800247:	ff 75 dc             	push   -0x24(%ebp)
  80024a:	ff 75 d8             	push   -0x28(%ebp)
  80024d:	e8 8e 10 00 00       	call   8012e0 <__umoddi3>
  800252:	83 c4 14             	add    $0x14,%esp
  800255:	0f be 80 33 14 80 00 	movsbl 0x801433(%eax),%eax
  80025c:	50                   	push   %eax
  80025d:	ff d7                	call   *%edi
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800270:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800274:	8b 10                	mov    (%eax),%edx
  800276:	3b 50 04             	cmp    0x4(%eax),%edx
  800279:	73 0a                	jae    800285 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	88 02                	mov    %al,(%edx)
}
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <printfmt>:
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80028d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800290:	50                   	push   %eax
  800291:	ff 75 10             	push   0x10(%ebp)
  800294:	ff 75 0c             	push   0xc(%ebp)
  800297:	ff 75 08             	push   0x8(%ebp)
  80029a:	e8 05 00 00 00       	call   8002a4 <vprintfmt>
}
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <vprintfmt>:
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 3c             	sub    $0x3c,%esp
  8002ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b6:	eb 0a                	jmp    8002c2 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	53                   	push   %ebx
  8002bc:	50                   	push   %eax
  8002bd:	ff d6                	call   *%esi
  8002bf:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c2:	83 c7 01             	add    $0x1,%edi
  8002c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002c9:	83 f8 25             	cmp    $0x25,%eax
  8002cc:	74 0c                	je     8002da <vprintfmt+0x36>
			if (ch == '\0')
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	75 e6                	jne    8002b8 <vprintfmt+0x14>
}
  8002d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    
		padc = ' ';
  8002da:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002e5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f8:	8d 47 01             	lea    0x1(%edi),%eax
  8002fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fe:	0f b6 17             	movzbl (%edi),%edx
  800301:	8d 42 dd             	lea    -0x23(%edx),%eax
  800304:	3c 55                	cmp    $0x55,%al
  800306:	0f 87 bb 03 00 00    	ja     8006c7 <vprintfmt+0x423>
  80030c:	0f b6 c0             	movzbl %al,%eax
  80030f:	ff 24 85 00 15 80 00 	jmp    *0x801500(,%eax,4)
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800319:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80031d:	eb d9                	jmp    8002f8 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800322:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800326:	eb d0                	jmp    8002f8 <vprintfmt+0x54>
  800328:	0f b6 d2             	movzbl %dl,%edx
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80032e:	b8 00 00 00 00       	mov    $0x0,%eax
  800333:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800336:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800339:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800340:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800343:	83 f9 09             	cmp    $0x9,%ecx
  800346:	77 55                	ja     80039d <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800348:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80034b:	eb e9                	jmp    800336 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80034d:	8b 45 14             	mov    0x14(%ebp),%eax
  800350:	8b 00                	mov    (%eax),%eax
  800352:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800355:	8b 45 14             	mov    0x14(%ebp),%eax
  800358:	8d 40 04             	lea    0x4(%eax),%eax
  80035b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800361:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800365:	79 91                	jns    8002f8 <vprintfmt+0x54>
				width = precision, precision = -1;
  800367:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800374:	eb 82                	jmp    8002f8 <vprintfmt+0x54>
  800376:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800379:	85 d2                	test   %edx,%edx
  80037b:	b8 00 00 00 00       	mov    $0x0,%eax
  800380:	0f 49 c2             	cmovns %edx,%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800389:	e9 6a ff ff ff       	jmp    8002f8 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800391:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800398:	e9 5b ff ff ff       	jmp    8002f8 <vprintfmt+0x54>
  80039d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a3:	eb bc                	jmp    800361 <vprintfmt+0xbd>
			lflag++;
  8003a5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ab:	e9 48 ff ff ff       	jmp    8002f8 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 78 04             	lea    0x4(%eax),%edi
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	53                   	push   %ebx
  8003ba:	ff 30                	push   (%eax)
  8003bc:	ff d6                	call   *%esi
			break;
  8003be:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c4:	e9 9d 02 00 00       	jmp    800666 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 78 04             	lea    0x4(%eax),%edi
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	89 d0                	mov    %edx,%eax
  8003d3:	f7 d8                	neg    %eax
  8003d5:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d8:	83 f8 08             	cmp    $0x8,%eax
  8003db:	7f 23                	jg     800400 <vprintfmt+0x15c>
  8003dd:	8b 14 85 60 16 80 00 	mov    0x801660(,%eax,4),%edx
  8003e4:	85 d2                	test   %edx,%edx
  8003e6:	74 18                	je     800400 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8003e8:	52                   	push   %edx
  8003e9:	68 54 14 80 00       	push   $0x801454
  8003ee:	53                   	push   %ebx
  8003ef:	56                   	push   %esi
  8003f0:	e8 92 fe ff ff       	call   800287 <printfmt>
  8003f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003fb:	e9 66 02 00 00       	jmp    800666 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800400:	50                   	push   %eax
  800401:	68 4b 14 80 00       	push   $0x80144b
  800406:	53                   	push   %ebx
  800407:	56                   	push   %esi
  800408:	e8 7a fe ff ff       	call   800287 <printfmt>
  80040d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800410:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800413:	e9 4e 02 00 00       	jmp    800666 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	83 c0 04             	add    $0x4,%eax
  80041e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800426:	85 d2                	test   %edx,%edx
  800428:	b8 44 14 80 00       	mov    $0x801444,%eax
  80042d:	0f 45 c2             	cmovne %edx,%eax
  800430:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800433:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800437:	7e 06                	jle    80043f <vprintfmt+0x19b>
  800439:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80043d:	75 0d                	jne    80044c <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800442:	89 c7                	mov    %eax,%edi
  800444:	03 45 e0             	add    -0x20(%ebp),%eax
  800447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044a:	eb 55                	jmp    8004a1 <vprintfmt+0x1fd>
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	ff 75 d8             	push   -0x28(%ebp)
  800452:	ff 75 cc             	push   -0x34(%ebp)
  800455:	e8 0a 03 00 00       	call   800764 <strnlen>
  80045a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045d:	29 c1                	sub    %eax,%ecx
  80045f:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800467:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80046b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	eb 0f                	jmp    80047f <vprintfmt+0x1db>
					putch(padc, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	ff 75 e0             	push   -0x20(%ebp)
  800477:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	83 ef 01             	sub    $0x1,%edi
  80047c:	83 c4 10             	add    $0x10,%esp
  80047f:	85 ff                	test   %edi,%edi
  800481:	7f ed                	jg     800470 <vprintfmt+0x1cc>
  800483:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	b8 00 00 00 00       	mov    $0x0,%eax
  80048d:	0f 49 c2             	cmovns %edx,%eax
  800490:	29 c2                	sub    %eax,%edx
  800492:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800495:	eb a8                	jmp    80043f <vprintfmt+0x19b>
					putch(ch, putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	53                   	push   %ebx
  80049b:	52                   	push   %edx
  80049c:	ff d6                	call   *%esi
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a6:	83 c7 01             	add    $0x1,%edi
  8004a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ad:	0f be d0             	movsbl %al,%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	74 4b                	je     8004ff <vprintfmt+0x25b>
  8004b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b8:	78 06                	js     8004c0 <vprintfmt+0x21c>
  8004ba:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004be:	78 1e                	js     8004de <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c4:	74 d1                	je     800497 <vprintfmt+0x1f3>
  8004c6:	0f be c0             	movsbl %al,%eax
  8004c9:	83 e8 20             	sub    $0x20,%eax
  8004cc:	83 f8 5e             	cmp    $0x5e,%eax
  8004cf:	76 c6                	jbe    800497 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	53                   	push   %ebx
  8004d5:	6a 3f                	push   $0x3f
  8004d7:	ff d6                	call   *%esi
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb c3                	jmp    8004a1 <vprintfmt+0x1fd>
  8004de:	89 cf                	mov    %ecx,%edi
  8004e0:	eb 0e                	jmp    8004f0 <vprintfmt+0x24c>
				putch(' ', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	6a 20                	push   $0x20
  8004e8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ea:	83 ef 01             	sub    $0x1,%edi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	7f ee                	jg     8004e2 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fa:	e9 67 01 00 00       	jmp    800666 <vprintfmt+0x3c2>
  8004ff:	89 cf                	mov    %ecx,%edi
  800501:	eb ed                	jmp    8004f0 <vprintfmt+0x24c>
	if (lflag >= 2)
  800503:	83 f9 01             	cmp    $0x1,%ecx
  800506:	7f 1b                	jg     800523 <vprintfmt+0x27f>
	else if (lflag)
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	74 63                	je     80056f <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800514:	99                   	cltd   
  800515:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 40 04             	lea    0x4(%eax),%eax
  80051e:	89 45 14             	mov    %eax,0x14(%ebp)
  800521:	eb 17                	jmp    80053a <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8b 50 04             	mov    0x4(%eax),%edx
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 40 08             	lea    0x8(%eax),%eax
  800537:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80053a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800540:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800545:	85 c9                	test   %ecx,%ecx
  800547:	0f 89 ff 00 00 00    	jns    80064c <vprintfmt+0x3a8>
				putch('-', putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	53                   	push   %ebx
  800551:	6a 2d                	push   $0x2d
  800553:	ff d6                	call   *%esi
				num = -(long long) num;
  800555:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800558:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055b:	f7 da                	neg    %edx
  80055d:	83 d1 00             	adc    $0x0,%ecx
  800560:	f7 d9                	neg    %ecx
  800562:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800565:	bf 0a 00 00 00       	mov    $0xa,%edi
  80056a:	e9 dd 00 00 00       	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800577:	99                   	cltd   
  800578:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 40 04             	lea    0x4(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
  800584:	eb b4                	jmp    80053a <vprintfmt+0x296>
	if (lflag >= 2)
  800586:	83 f9 01             	cmp    $0x1,%ecx
  800589:	7f 1e                	jg     8005a9 <vprintfmt+0x305>
	else if (lflag)
  80058b:	85 c9                	test   %ecx,%ecx
  80058d:	74 32                	je     8005c1 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 10                	mov    (%eax),%edx
  800594:	b9 00 00 00 00       	mov    $0x0,%ecx
  800599:	8d 40 04             	lea    0x4(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005a4:	e9 a3 00 00 00       	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b1:	8d 40 08             	lea    0x8(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005bc:	e9 8b 00 00 00       	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 10                	mov    (%eax),%edx
  8005c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005d6:	eb 74                	jmp    80064c <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005d8:	83 f9 01             	cmp    $0x1,%ecx
  8005db:	7f 1b                	jg     8005f8 <vprintfmt+0x354>
	else if (lflag)
  8005dd:	85 c9                	test   %ecx,%ecx
  8005df:	74 2c                	je     80060d <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005eb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005f1:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8005f6:	eb 54                	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800600:	8d 40 08             	lea    0x8(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800606:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80060b:	eb 3f                	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	b9 00 00 00 00       	mov    $0x0,%ecx
  800617:	8d 40 04             	lea    0x4(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80061d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800622:	eb 28                	jmp    80064c <vprintfmt+0x3a8>
			putch('0', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 30                	push   $0x30
  80062a:	ff d6                	call   *%esi
			putch('x', putdat);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 78                	push   $0x78
  800632:	ff d6                	call   *%esi
			num = (unsigned long long)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80063e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800641:	8d 40 04             	lea    0x4(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800647:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	ff 75 e0             	push   -0x20(%ebp)
  800657:	57                   	push   %edi
  800658:	51                   	push   %ecx
  800659:	52                   	push   %edx
  80065a:	89 da                	mov    %ebx,%edx
  80065c:	89 f0                	mov    %esi,%eax
  80065e:	e8 5e fb ff ff       	call   8001c1 <printnum>
			break;
  800663:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800669:	e9 54 fc ff ff       	jmp    8002c2 <vprintfmt+0x1e>
	if (lflag >= 2)
  80066e:	83 f9 01             	cmp    $0x1,%ecx
  800671:	7f 1b                	jg     80068e <vprintfmt+0x3ea>
	else if (lflag)
  800673:	85 c9                	test   %ecx,%ecx
  800675:	74 2c                	je     8006a3 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800681:	8d 40 04             	lea    0x4(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800687:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80068c:	eb be                	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 10                	mov    (%eax),%edx
  800693:	8b 48 04             	mov    0x4(%eax),%ecx
  800696:	8d 40 08             	lea    0x8(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006a1:	eb a9                	jmp    80064c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006b8:	eb 92                	jmp    80064c <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	53                   	push   %ebx
  8006be:	6a 25                	push   $0x25
  8006c0:	ff d6                	call   *%esi
			break;
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 9f                	jmp    800666 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	6a 25                	push   $0x25
  8006cd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	89 f8                	mov    %edi,%eax
  8006d4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006d8:	74 05                	je     8006df <vprintfmt+0x43b>
  8006da:	83 e8 01             	sub    $0x1,%eax
  8006dd:	eb f5                	jmp    8006d4 <vprintfmt+0x430>
  8006df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e2:	eb 82                	jmp    800666 <vprintfmt+0x3c2>

008006e4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 18             	sub    $0x18,%esp
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800701:	85 c0                	test   %eax,%eax
  800703:	74 26                	je     80072b <vsnprintf+0x47>
  800705:	85 d2                	test   %edx,%edx
  800707:	7e 22                	jle    80072b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800709:	ff 75 14             	push   0x14(%ebp)
  80070c:	ff 75 10             	push   0x10(%ebp)
  80070f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	68 6a 02 80 00       	push   $0x80026a
  800718:	e8 87 fb ff ff       	call   8002a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800720:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800726:	83 c4 10             	add    $0x10,%esp
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    
		return -E_INVAL;
  80072b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800730:	eb f7                	jmp    800729 <vsnprintf+0x45>

00800732 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	50                   	push   %eax
  80073c:	ff 75 10             	push   0x10(%ebp)
  80073f:	ff 75 0c             	push   0xc(%ebp)
  800742:	ff 75 08             	push   0x8(%ebp)
  800745:	e8 9a ff ff ff       	call   8006e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 03                	jmp    80075c <strlen+0x10>
		n++;
  800759:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80075c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800760:	75 f7                	jne    800759 <strlen+0xd>
	return n;
}
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	b8 00 00 00 00       	mov    $0x0,%eax
  800772:	eb 03                	jmp    800777 <strnlen+0x13>
		n++;
  800774:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	39 d0                	cmp    %edx,%eax
  800779:	74 08                	je     800783 <strnlen+0x1f>
  80077b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077f:	75 f3                	jne    800774 <strnlen+0x10>
  800781:	89 c2                	mov    %eax,%edx
	return n;
}
  800783:	89 d0                	mov    %edx,%eax
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80079a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80079d:	83 c0 01             	add    $0x1,%eax
  8007a0:	84 d2                	test   %dl,%dl
  8007a2:	75 f2                	jne    800796 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a4:	89 c8                	mov    %ecx,%eax
  8007a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	83 ec 10             	sub    $0x10,%esp
  8007b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b5:	53                   	push   %ebx
  8007b6:	e8 91 ff ff ff       	call   80074c <strlen>
  8007bb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007be:	ff 75 0c             	push   0xc(%ebp)
  8007c1:	01 d8                	add    %ebx,%eax
  8007c3:	50                   	push   %eax
  8007c4:	e8 be ff ff ff       	call   800787 <strcpy>
	return dst;
}
  8007c9:	89 d8                	mov    %ebx,%eax
  8007cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	56                   	push   %esi
  8007d4:	53                   	push   %ebx
  8007d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007db:	89 f3                	mov    %esi,%ebx
  8007dd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	eb 0f                	jmp    8007f3 <strncpy+0x23>
		*dst++ = *src;
  8007e4:	83 c0 01             	add    $0x1,%eax
  8007e7:	0f b6 0a             	movzbl (%edx),%ecx
  8007ea:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ed:	80 f9 01             	cmp    $0x1,%cl
  8007f0:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8007f3:	39 d8                	cmp    %ebx,%eax
  8007f5:	75 ed                	jne    8007e4 <strncpy+0x14>
	}
	return ret;
}
  8007f7:	89 f0                	mov    %esi,%eax
  8007f9:	5b                   	pop    %ebx
  8007fa:	5e                   	pop    %esi
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	8b 75 08             	mov    0x8(%ebp),%esi
  800805:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800808:	8b 55 10             	mov    0x10(%ebp),%edx
  80080b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080d:	85 d2                	test   %edx,%edx
  80080f:	74 21                	je     800832 <strlcpy+0x35>
  800811:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800815:	89 f2                	mov    %esi,%edx
  800817:	eb 09                	jmp    800822 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800819:	83 c1 01             	add    $0x1,%ecx
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800822:	39 c2                	cmp    %eax,%edx
  800824:	74 09                	je     80082f <strlcpy+0x32>
  800826:	0f b6 19             	movzbl (%ecx),%ebx
  800829:	84 db                	test   %bl,%bl
  80082b:	75 ec                	jne    800819 <strlcpy+0x1c>
  80082d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80082f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800832:	29 f0                	sub    %esi,%eax
}
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800841:	eb 06                	jmp    800849 <strcmp+0x11>
		p++, q++;
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	84 c0                	test   %al,%al
  80084e:	74 04                	je     800854 <strcmp+0x1c>
  800850:	3a 02                	cmp    (%edx),%al
  800852:	74 ef                	je     800843 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800854:	0f b6 c0             	movzbl %al,%eax
  800857:	0f b6 12             	movzbl (%edx),%edx
  80085a:	29 d0                	sub    %edx,%eax
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
  800868:	89 c3                	mov    %eax,%ebx
  80086a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086d:	eb 06                	jmp    800875 <strncmp+0x17>
		n--, p++, q++;
  80086f:	83 c0 01             	add    $0x1,%eax
  800872:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800875:	39 d8                	cmp    %ebx,%eax
  800877:	74 18                	je     800891 <strncmp+0x33>
  800879:	0f b6 08             	movzbl (%eax),%ecx
  80087c:	84 c9                	test   %cl,%cl
  80087e:	74 04                	je     800884 <strncmp+0x26>
  800880:	3a 0a                	cmp    (%edx),%cl
  800882:	74 eb                	je     80086f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800884:	0f b6 00             	movzbl (%eax),%eax
  800887:	0f b6 12             	movzbl (%edx),%edx
  80088a:	29 d0                	sub    %edx,%eax
}
  80088c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088f:	c9                   	leave  
  800890:	c3                   	ret    
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb f4                	jmp    80088c <strncmp+0x2e>

00800898 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a2:	eb 03                	jmp    8008a7 <strchr+0xf>
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	0f b6 10             	movzbl (%eax),%edx
  8008aa:	84 d2                	test   %dl,%dl
  8008ac:	74 06                	je     8008b4 <strchr+0x1c>
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	75 f2                	jne    8008a4 <strchr+0xc>
  8008b2:	eb 05                	jmp    8008b9 <strchr+0x21>
			return (char *) s;
	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c8:	38 ca                	cmp    %cl,%dl
  8008ca:	74 09                	je     8008d5 <strfind+0x1a>
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	74 05                	je     8008d5 <strfind+0x1a>
	for (; *s; s++)
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	eb f0                	jmp    8008c5 <strfind+0xa>
			break;
	return (char *) s;
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e3:	85 c9                	test   %ecx,%ecx
  8008e5:	74 2f                	je     800916 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e7:	89 f8                	mov    %edi,%eax
  8008e9:	09 c8                	or     %ecx,%eax
  8008eb:	a8 03                	test   $0x3,%al
  8008ed:	75 21                	jne    800910 <memset+0x39>
		c &= 0xFF;
  8008ef:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f3:	89 d0                	mov    %edx,%eax
  8008f5:	c1 e0 08             	shl    $0x8,%eax
  8008f8:	89 d3                	mov    %edx,%ebx
  8008fa:	c1 e3 18             	shl    $0x18,%ebx
  8008fd:	89 d6                	mov    %edx,%esi
  8008ff:	c1 e6 10             	shl    $0x10,%esi
  800902:	09 f3                	or     %esi,%ebx
  800904:	09 da                	or     %ebx,%edx
  800906:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800908:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80090b:	fc                   	cld    
  80090c:	f3 ab                	rep stos %eax,%es:(%edi)
  80090e:	eb 06                	jmp    800916 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800910:	8b 45 0c             	mov    0xc(%ebp),%eax
  800913:	fc                   	cld    
  800914:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800916:	89 f8                	mov    %edi,%eax
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 75 0c             	mov    0xc(%ebp),%esi
  800928:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092b:	39 c6                	cmp    %eax,%esi
  80092d:	73 32                	jae    800961 <memmove+0x44>
  80092f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800932:	39 c2                	cmp    %eax,%edx
  800934:	76 2b                	jbe    800961 <memmove+0x44>
		s += n;
		d += n;
  800936:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800939:	89 d6                	mov    %edx,%esi
  80093b:	09 fe                	or     %edi,%esi
  80093d:	09 ce                	or     %ecx,%esi
  80093f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800945:	75 0e                	jne    800955 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800947:	83 ef 04             	sub    $0x4,%edi
  80094a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800950:	fd                   	std    
  800951:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800953:	eb 09                	jmp    80095e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800955:	83 ef 01             	sub    $0x1,%edi
  800958:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80095b:	fd                   	std    
  80095c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095e:	fc                   	cld    
  80095f:	eb 1a                	jmp    80097b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	89 f2                	mov    %esi,%edx
  800963:	09 c2                	or     %eax,%edx
  800965:	09 ca                	or     %ecx,%edx
  800967:	f6 c2 03             	test   $0x3,%dl
  80096a:	75 0a                	jne    800976 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80096f:	89 c7                	mov    %eax,%edi
  800971:	fc                   	cld    
  800972:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800974:	eb 05                	jmp    80097b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097b:	5e                   	pop    %esi
  80097c:	5f                   	pop    %edi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800985:	ff 75 10             	push   0x10(%ebp)
  800988:	ff 75 0c             	push   0xc(%ebp)
  80098b:	ff 75 08             	push   0x8(%ebp)
  80098e:	e8 8a ff ff ff       	call   80091d <memmove>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	89 c6                	mov    %eax,%esi
  8009a2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a5:	eb 06                	jmp    8009ad <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009a7:	83 c0 01             	add    $0x1,%eax
  8009aa:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009ad:	39 f0                	cmp    %esi,%eax
  8009af:	74 14                	je     8009c5 <memcmp+0x30>
		if (*s1 != *s2)
  8009b1:	0f b6 08             	movzbl (%eax),%ecx
  8009b4:	0f b6 1a             	movzbl (%edx),%ebx
  8009b7:	38 d9                	cmp    %bl,%cl
  8009b9:	74 ec                	je     8009a7 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009bb:	0f b6 c1             	movzbl %cl,%eax
  8009be:	0f b6 db             	movzbl %bl,%ebx
  8009c1:	29 d8                	sub    %ebx,%eax
  8009c3:	eb 05                	jmp    8009ca <memcmp+0x35>
	}

	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d7:	89 c2                	mov    %eax,%edx
  8009d9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009dc:	eb 03                	jmp    8009e1 <memfind+0x13>
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	39 d0                	cmp    %edx,%eax
  8009e3:	73 04                	jae    8009e9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e5:	38 08                	cmp    %cl,(%eax)
  8009e7:	75 f5                	jne    8009de <memfind+0x10>
			break;
	return (void *) s;
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	57                   	push   %edi
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f7:	eb 03                	jmp    8009fc <strtol+0x11>
		s++;
  8009f9:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8009fc:	0f b6 02             	movzbl (%edx),%eax
  8009ff:	3c 20                	cmp    $0x20,%al
  800a01:	74 f6                	je     8009f9 <strtol+0xe>
  800a03:	3c 09                	cmp    $0x9,%al
  800a05:	74 f2                	je     8009f9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a07:	3c 2b                	cmp    $0x2b,%al
  800a09:	74 2a                	je     800a35 <strtol+0x4a>
	int neg = 0;
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a10:	3c 2d                	cmp    $0x2d,%al
  800a12:	74 2b                	je     800a3f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1a:	75 0f                	jne    800a2b <strtol+0x40>
  800a1c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a1f:	74 28                	je     800a49 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a21:	85 db                	test   %ebx,%ebx
  800a23:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a28:	0f 44 d8             	cmove  %eax,%ebx
  800a2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a30:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a33:	eb 46                	jmp    800a7b <strtol+0x90>
		s++;
  800a35:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3d:	eb d5                	jmp    800a14 <strtol+0x29>
		s++, neg = 1;
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	bf 01 00 00 00       	mov    $0x1,%edi
  800a47:	eb cb                	jmp    800a14 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4d:	74 0e                	je     800a5d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	75 d8                	jne    800a2b <strtol+0x40>
		s++, base = 8;
  800a53:	83 c2 01             	add    $0x1,%edx
  800a56:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a5b:	eb ce                	jmp    800a2b <strtol+0x40>
		s += 2, base = 16;
  800a5d:	83 c2 02             	add    $0x2,%edx
  800a60:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a65:	eb c4                	jmp    800a2b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a67:	0f be c0             	movsbl %al,%eax
  800a6a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a70:	7d 3a                	jge    800aac <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a72:	83 c2 01             	add    $0x1,%edx
  800a75:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a79:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a7b:	0f b6 02             	movzbl (%edx),%eax
  800a7e:	8d 70 d0             	lea    -0x30(%eax),%esi
  800a81:	89 f3                	mov    %esi,%ebx
  800a83:	80 fb 09             	cmp    $0x9,%bl
  800a86:	76 df                	jbe    800a67 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800a88:	8d 70 9f             	lea    -0x61(%eax),%esi
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 08                	ja     800a9a <strtol+0xaf>
			dig = *s - 'a' + 10;
  800a92:	0f be c0             	movsbl %al,%eax
  800a95:	83 e8 57             	sub    $0x57,%eax
  800a98:	eb d3                	jmp    800a6d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800a9a:	8d 70 bf             	lea    -0x41(%eax),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 08                	ja     800aac <strtol+0xc1>
			dig = *s - 'A' + 10;
  800aa4:	0f be c0             	movsbl %al,%eax
  800aa7:	83 e8 37             	sub    $0x37,%eax
  800aaa:	eb c1                	jmp    800a6d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab0:	74 05                	je     800ab7 <strtol+0xcc>
		*endptr = (char *) s;
  800ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ab7:	89 c8                	mov    %ecx,%eax
  800ab9:	f7 d8                	neg    %eax
  800abb:	85 ff                	test   %edi,%edi
  800abd:	0f 45 c8             	cmovne %eax,%ecx
}
  800ac0:	89 c8                	mov    %ecx,%eax
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	89 c6                	mov    %eax,%esi
  800ade:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 01 00 00 00       	mov    $0x1,%eax
  800af5:	89 d1                	mov    %edx,%ecx
  800af7:	89 d3                	mov    %edx,%ebx
  800af9:	89 d7                	mov    %edx,%edi
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1a:	89 cb                	mov    %ecx,%ebx
  800b1c:	89 cf                	mov    %ecx,%edi
  800b1e:	89 ce                	mov    %ecx,%esi
  800b20:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b22:	85 c0                	test   %eax,%eax
  800b24:	7f 08                	jg     800b2e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	50                   	push   %eax
  800b32:	6a 03                	push   $0x3
  800b34:	68 84 16 80 00       	push   $0x801684
  800b39:	6a 23                	push   $0x23
  800b3b:	68 a1 16 80 00       	push   $0x8016a1
  800b40:	e8 91 05 00 00       	call   8010d6 <_panic>

00800b45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 02 00 00 00       	mov    $0x2,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_yield>:

void
sys_yield(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b74:	89 d1                	mov    %edx,%ecx
  800b76:	89 d3                	mov    %edx,%ebx
  800b78:	89 d7                	mov    %edx,%edi
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b8c:	be 00 00 00 00       	mov    $0x0,%esi
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9f:	89 f7                	mov    %esi,%edi
  800ba1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7f 08                	jg     800baf <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 04                	push   $0x4
  800bb5:	68 84 16 80 00       	push   $0x801684
  800bba:	6a 23                	push   $0x23
  800bbc:	68 a1 16 80 00       	push   $0x8016a1
  800bc1:	e8 10 05 00 00       	call   8010d6 <_panic>

00800bc6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be0:	8b 75 18             	mov    0x18(%ebp),%esi
  800be3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7f 08                	jg     800bf1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 05                	push   $0x5
  800bf7:	68 84 16 80 00       	push   $0x801684
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 a1 16 80 00       	push   $0x8016a1
  800c03:	e8 ce 04 00 00       	call   8010d6 <_panic>

00800c08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7f 08                	jg     800c33 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 06                	push   $0x6
  800c39:	68 84 16 80 00       	push   $0x801684
  800c3e:	6a 23                	push   $0x23
  800c40:	68 a1 16 80 00       	push   $0x8016a1
  800c45:	e8 8c 04 00 00       	call   8010d6 <_panic>

00800c4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7f 08                	jg     800c75 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 08                	push   $0x8
  800c7b:	68 84 16 80 00       	push   $0x801684
  800c80:	6a 23                	push   $0x23
  800c82:	68 a1 16 80 00       	push   $0x8016a1
  800c87:	e8 4a 04 00 00       	call   8010d6 <_panic>

00800c8c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7f 08                	jg     800cb7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 09                	push   $0x9
  800cbd:	68 84 16 80 00       	push   $0x801684
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 a1 16 80 00       	push   $0x8016a1
  800cc9:	e8 08 04 00 00       	call   8010d6 <_panic>

00800cce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cdf:	be 00 00 00 00       	mov    $0x0,%esi
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cea:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d07:	89 cb                	mov    %ecx,%ebx
  800d09:	89 cf                	mov    %ecx,%edi
  800d0b:	89 ce                	mov    %ecx,%esi
  800d0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7f 08                	jg     800d1b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 0c                	push   $0xc
  800d21:	68 84 16 80 00       	push   $0x801684
  800d26:	6a 23                	push   $0x23
  800d28:	68 a1 16 80 00       	push   $0x8016a1
  800d2d:	e8 a4 03 00 00       	call   8010d6 <_panic>

00800d32 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	53                   	push   %ebx
  800d36:	83 ec 04             	sub    $0x4,%esp
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d3c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(utf->utf_err & FEC_WR) || (uvpt[PGNUM(addr)] & perm) != perm) 
  800d3e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d42:	0f 84 81 00 00 00    	je     800dc9 <pgfault+0x97>
  800d48:	89 d8                	mov    %ebx,%eax
  800d4a:	c1 e8 0c             	shr    $0xc,%eax
  800d4d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d54:	25 05 08 00 00       	and    $0x805,%eax
  800d59:	3d 05 08 00 00       	cmp    $0x805,%eax
  800d5e:	75 69                	jne    800dc9 <pgfault+0x97>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	6a 07                	push   $0x7
  800d65:	68 00 f0 7f 00       	push   $0x7ff000
  800d6a:	6a 00                	push   $0x0
  800d6c:	e8 12 fe ff ff       	call   800b83 <sys_page_alloc>
  800d71:	83 c4 10             	add    $0x10,%esp
  800d74:	85 c0                	test   %eax,%eax
  800d76:	78 73                	js     800deb <pgfault+0xb9>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800d78:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	68 00 10 00 00       	push   $0x1000
  800d86:	53                   	push   %ebx
  800d87:	68 00 f0 7f 00       	push   $0x7ff000
  800d8c:	e8 ee fb ff ff       	call   80097f <memcpy>

	if ((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W | PTE_P | PTE_U)) < 0) 
  800d91:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800d98:	53                   	push   %ebx
  800d99:	6a 00                	push   $0x0
  800d9b:	68 00 f0 7f 00       	push   $0x7ff000
  800da0:	6a 00                	push   $0x0
  800da2:	e8 1f fe ff ff       	call   800bc6 <sys_page_map>
  800da7:	83 c4 20             	add    $0x20,%esp
  800daa:	85 c0                	test   %eax,%eax
  800dac:	78 57                	js     800e05 <pgfault+0xd3>
	{
		panic("sys_page_map: %e", r);
	}

	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800dae:	83 ec 08             	sub    $0x8,%esp
  800db1:	68 00 f0 7f 00       	push   $0x7ff000
  800db6:	6a 00                	push   $0x0
  800db8:	e8 4b fe ff ff       	call   800c08 <sys_page_unmap>
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	78 53                	js     800e17 <pgfault+0xe5>
		panic("sys_page_unmap: %e", r);

}
  800dc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc7:	c9                   	leave  
  800dc8:	c3                   	ret    
		panic("pgfault pte: %08x, addr: %08x", uvpt[PGNUM(addr)], addr);
  800dc9:	89 d8                	mov    %ebx,%eax
  800dcb:	c1 e8 0c             	shr    $0xc,%eax
  800dce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	53                   	push   %ebx
  800dd9:	50                   	push   %eax
  800dda:	68 af 16 80 00       	push   $0x8016af
  800ddf:	6a 1f                	push   $0x1f
  800de1:	68 cd 16 80 00       	push   $0x8016cd
  800de6:	e8 eb 02 00 00       	call   8010d6 <_panic>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	68 00 f0 7f 00       	push   $0x7ff000
  800df4:	68 3c 17 80 00       	push   $0x80173c
  800df9:	6a 2a                	push   $0x2a
  800dfb:	68 cd 16 80 00       	push   $0x8016cd
  800e00:	e8 d1 02 00 00       	call   8010d6 <_panic>
		panic("sys_page_map: %e", r);
  800e05:	50                   	push   %eax
  800e06:	68 d8 16 80 00       	push   $0x8016d8
  800e0b:	6a 30                	push   $0x30
  800e0d:	68 cd 16 80 00       	push   $0x8016cd
  800e12:	e8 bf 02 00 00       	call   8010d6 <_panic>
		panic("sys_page_unmap: %e", r);
  800e17:	50                   	push   %eax
  800e18:	68 e9 16 80 00       	push   $0x8016e9
  800e1d:	6a 34                	push   $0x34
  800e1f:	68 cd 16 80 00       	push   $0x8016cd
  800e24:	e8 ad 02 00 00       	call   8010d6 <_panic>

00800e29 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 18             	sub    $0x18,%esp
	envid_t envid;
	pte_t pte;
	uint8_t *va;
	extern unsigned char end[];

	set_pgfault_handler(pgfault);
  800e32:	68 32 0d 80 00       	push   $0x800d32
  800e37:	e8 e0 02 00 00       	call   80111c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e3c:	b8 07 00 00 00       	mov    $0x7,%eax
  800e41:	cd 30                	int    $0x30
  800e43:	89 c6                	mov    %eax,%esi
	envid = sys_exofork(); // create child envirement
	if (envid < 0)
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	78 24                	js     800e70 <fork+0x47>
	{
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (va = 0; va < (uint8_t *)USTACKTOP; va += PGSIZE)
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) 
  800e51:	0f 85 19 01 00 00    	jne    800f70 <fork+0x147>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e57:	e8 e9 fc ff ff       	call   800b45 <sys_getenvid>
  800e5c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e61:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e64:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e69:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e6e:	eb 66                	jmp    800ed6 <fork+0xad>
		panic("sys_exofork: %e", envid); //new envirement not created
  800e70:	50                   	push   %eax
  800e71:	68 fc 16 80 00       	push   $0x8016fc
  800e76:	6a 78                	push   $0x78
  800e78:	68 cd 16 80 00       	push   $0x8016cd
  800e7d:	e8 54 02 00 00       	call   8010d6 <_panic>
		panic("sys_page_map: %e", r);
  800e82:	50                   	push   %eax
  800e83:	68 d8 16 80 00       	push   $0x8016d8
  800e88:	6a 56                	push   $0x56
  800e8a:	68 cd 16 80 00       	push   $0x8016cd
  800e8f:	e8 42 02 00 00       	call   8010d6 <_panic>
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P))
			duppage(envid, PGNUM(va));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	6a 07                	push   $0x7
  800e99:	68 00 f0 bf ee       	push   $0xeebff000
  800e9e:	56                   	push   %esi
  800e9f:	e8 df fc ff ff       	call   800b83 <sys_page_alloc>
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	78 35                	js     800ee0 <fork+0xb7>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);

	if ((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800eab:	a1 04 20 80 00       	mov    0x802004,%eax
  800eb0:	8b 40 64             	mov    0x64(%eax),%eax
  800eb3:	83 ec 08             	sub    $0x8,%esp
  800eb6:	50                   	push   %eax
  800eb7:	56                   	push   %esi
  800eb8:	e8 cf fd ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	78 39                	js     800efd <fork+0xd4>
		panic("sys_env_set_pgfault_upcall: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	6a 02                	push   $0x2
  800ec9:	56                   	push   %esi
  800eca:	e8 7b fd ff ff       	call   800c4a <sys_env_set_status>
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	78 3c                	js     800f12 <fork+0xe9>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800ed6:	89 f0                	mov    %esi,%eax
  800ed8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    
		panic("allocating at %x in pgfault: %e", PFTEMP, r);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	50                   	push   %eax
  800ee4:	68 00 f0 7f 00       	push   $0x7ff000
  800ee9:	68 3c 17 80 00       	push   $0x80173c
  800eee:	68 84 00 00 00       	push   $0x84
  800ef3:	68 cd 16 80 00       	push   $0x8016cd
  800ef8:	e8 d9 01 00 00       	call   8010d6 <_panic>
		panic("sys_env_set_pgfault_upcall: %e", r);
  800efd:	50                   	push   %eax
  800efe:	68 5c 17 80 00       	push   $0x80175c
  800f03:	68 87 00 00 00       	push   $0x87
  800f08:	68 cd 16 80 00       	push   $0x8016cd
  800f0d:	e8 c4 01 00 00       	call   8010d6 <_panic>
		panic("sys_env_set_status: %e", r);
  800f12:	50                   	push   %eax
  800f13:	68 0c 17 80 00       	push   $0x80170c
  800f18:	68 8a 00 00 00       	push   $0x8a
  800f1d:	68 cd 16 80 00       	push   $0x8016cd
  800f22:	e8 af 01 00 00       	call   8010d6 <_panic>
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	68 05 08 00 00       	push   $0x805
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	57                   	push   %edi
  800f32:	6a 00                	push   $0x0
  800f34:	e8 8d fc ff ff       	call   800bc6 <sys_page_map>
  800f39:	83 c4 20             	add    $0x20,%esp
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	78 7a                	js     800fba <fork+0x191>
	if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	68 05 08 00 00       	push   $0x805
  800f48:	57                   	push   %edi
  800f49:	6a 00                	push   $0x0
  800f4b:	57                   	push   %edi
  800f4c:	6a 00                	push   $0x0
  800f4e:	e8 73 fc ff ff       	call   800bc6 <sys_page_map>
  800f53:	83 c4 20             	add    $0x20,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	0f 88 24 ff ff ff    	js     800e82 <fork+0x59>
	for (va = 0; va < (uint8_t *)USTACKTOP; va += PGSIZE)
  800f5e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f64:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f6a:	0f 84 24 ff ff ff    	je     800e94 <fork+0x6b>
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P))
  800f70:	89 d8                	mov    %ebx,%eax
  800f72:	c1 e8 16             	shr    $0x16,%eax
  800f75:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f7c:	a8 01                	test   $0x1,%al
  800f7e:	74 de                	je     800f5e <fork+0x135>
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	c1 e8 0c             	shr    $0xc,%eax
  800f85:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8c:	f6 c2 01             	test   $0x1,%dl
  800f8f:	74 cd                	je     800f5e <fork+0x135>
	void *addr = (void *)(pn * PGSIZE);
  800f91:	89 c7                	mov    %eax,%edi
  800f93:	c1 e7 0c             	shl    $0xc,%edi
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800f96:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9d:	a9 02 08 00 00       	test   $0x802,%eax
  800fa2:	75 83                	jne    800f27 <fork+0xfe>
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	6a 05                	push   $0x5
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	57                   	push   %edi
  800fac:	6a 00                	push   $0x0
  800fae:	e8 13 fc ff ff       	call   800bc6 <sys_page_map>
  800fb3:	83 c4 20             	add    $0x20,%esp
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	79 a4                	jns    800f5e <fork+0x135>
		panic("sys_page_map: %e", r);
  800fba:	50                   	push   %eax
  800fbb:	68 d8 16 80 00       	push   $0x8016d8
  800fc0:	6a 50                	push   $0x50
  800fc2:	68 cd 16 80 00       	push   $0x8016cd
  800fc7:	e8 0a 01 00 00       	call   8010d6 <_panic>

00800fcc <sfork>:

// Challenge!
int
sfork(void)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fd2:	68 23 17 80 00       	push   $0x801723
  800fd7:	68 93 00 00 00       	push   $0x93
  800fdc:	68 cd 16 80 00       	push   $0x8016cd
  800fe1:	e8 f0 00 00 00       	call   8010d6 <_panic>

00800fe6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	56                   	push   %esi
  800fea:	53                   	push   %ebx
  800feb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	
	int r;

	r = sys_ipc_recv(pg ? pg : (void *)UTOP);
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800ffb:	0f 44 c2             	cmove  %edx,%eax
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	50                   	push   %eax
  801002:	e8 ea fc ff ff       	call   800cf1 <sys_ipc_recv>

	if (from_env_store) {
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	85 f6                	test   %esi,%esi
  80100c:	74 0b                	je     801019 <ipc_recv+0x33>
		*from_env_store = thisenv->env_ipc_from;
  80100e:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801014:	8b 52 74             	mov    0x74(%edx),%edx
  801017:	89 16                	mov    %edx,(%esi)
	}

	if (perm_store) {
  801019:	85 db                	test   %ebx,%ebx
  80101b:	74 0b                	je     801028 <ipc_recv+0x42>
		*perm_store = thisenv->env_ipc_perm;
  80101d:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801023:	8b 52 78             	mov    0x78(%edx),%edx
  801026:	89 13                	mov    %edx,(%ebx)
	}

	if (r < 0) 
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 0f                	js     80103b <ipc_recv+0x55>
		*from_env_store = 0;
		*perm_store = 0;
		return r;
	}

	return thisenv->env_ipc_value;
  80102c:	a1 04 20 80 00       	mov    0x802004,%eax
  801031:	8b 40 70             	mov    0x70(%eax),%eax
	
}
  801034:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801037:	5b                   	pop    %ebx
  801038:	5e                   	pop    %esi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    
		*from_env_store = 0;
  80103b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		*perm_store = 0;
  801041:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
  801047:	eb eb                	jmp    801034 <ipc_recv+0x4e>

00801049 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	57                   	push   %edi
  80104d:	56                   	push   %esi
  80104e:	53                   	push   %ebx
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	8b 7d 08             	mov    0x8(%ebp),%edi
  801055:	8b 75 0c             	mov    0xc(%ebp),%esi
  801058:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80105b:	85 db                	test   %ebx,%ebx
  80105d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801062:	0f 44 d8             	cmove  %eax,%ebx
	// LAB 4: Your code here.
	int r;
	for(;;) {
		r = sys_ipc_try_send(to_env, val, pg ? pg : (void *)UTOP, perm);
  801065:	ff 75 14             	push   0x14(%ebp)
  801068:	53                   	push   %ebx
  801069:	56                   	push   %esi
  80106a:	57                   	push   %edi
  80106b:	e8 5e fc ff ff       	call   800cce <sys_ipc_try_send>
		if (r == 0) {
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	74 1e                	je     801095 <ipc_send+0x4c>
			break;
		} else if (r != -E_IPC_NOT_RECV) {
  801077:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80107a:	75 07                	jne    801083 <ipc_send+0x3a>
			panic("ipc_send: %e", r);
		}
		sys_yield();
  80107c:	e8 e3 fa ff ff       	call   800b64 <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg ? pg : (void *)UTOP, perm);
  801081:	eb e2                	jmp    801065 <ipc_send+0x1c>
			panic("ipc_send: %e", r);
  801083:	50                   	push   %eax
  801084:	68 7b 17 80 00       	push   $0x80177b
  801089:	6a 45                	push   $0x45
  80108b:	68 88 17 80 00       	push   $0x801788
  801090:	e8 41 00 00 00       	call   8010d6 <_panic>
	}
}
  801095:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010a3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010a8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010ab:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010b1:	8b 52 50             	mov    0x50(%edx),%edx
  8010b4:	39 ca                	cmp    %ecx,%edx
  8010b6:	74 11                	je     8010c9 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8010b8:	83 c0 01             	add    $0x1,%eax
  8010bb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010c0:	75 e6                	jne    8010a8 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8010c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c7:	eb 0b                	jmp    8010d4 <ipc_find_env+0x37>
			return envs[i].env_id;
  8010c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010db:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010de:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010e4:	e8 5c fa ff ff       	call   800b45 <sys_getenvid>
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	ff 75 0c             	push   0xc(%ebp)
  8010ef:	ff 75 08             	push   0x8(%ebp)
  8010f2:	56                   	push   %esi
  8010f3:	50                   	push   %eax
  8010f4:	68 94 17 80 00       	push   $0x801794
  8010f9:	e8 af f0 ff ff       	call   8001ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010fe:	83 c4 18             	add    $0x18,%esp
  801101:	53                   	push   %ebx
  801102:	ff 75 10             	push   0x10(%ebp)
  801105:	e8 52 f0 ff ff       	call   80015c <vcprintf>
	cprintf("\n");
  80110a:	c7 04 24 c9 17 80 00 	movl   $0x8017c9,(%esp)
  801111:	e8 97 f0 ff ff       	call   8001ad <cprintf>
  801116:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801119:	cc                   	int3   
  80111a:	eb fd                	jmp    801119 <_panic+0x43>

0080111c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801122:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801129:	74 0a                	je     801135 <set_pgfault_handler+0x19>
		if (r < 0)
			cprintf("sys_env_set_pgfault_upcall: %d\n", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801133:	c9                   	leave  
  801134:	c3                   	ret    
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  801135:	a1 04 20 80 00       	mov    0x802004,%eax
  80113a:	8b 40 48             	mov    0x48(%eax),%eax
  80113d:	83 ec 04             	sub    $0x4,%esp
  801140:	6a 07                	push   $0x7
  801142:	68 00 f0 bf ee       	push   $0xeebff000
  801147:	50                   	push   %eax
  801148:	e8 36 fa ff ff       	call   800b83 <sys_page_alloc>
		if (r < 0)
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	85 c0                	test   %eax,%eax
  801152:	78 29                	js     80117d <set_pgfault_handler+0x61>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801154:	83 ec 08             	sub    $0x8,%esp
  801157:	68 90 11 80 00       	push   $0x801190
  80115c:	6a 00                	push   $0x0
  80115e:	e8 29 fb ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
		if (r < 0)
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	79 c1                	jns    80112b <set_pgfault_handler+0xf>
			cprintf("sys_env_set_pgfault_upcall: %d\n", r);
  80116a:	83 ec 08             	sub    $0x8,%esp
  80116d:	50                   	push   %eax
  80116e:	68 cc 17 80 00       	push   $0x8017cc
  801173:	e8 35 f0 ff ff       	call   8001ad <cprintf>
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	eb ae                	jmp    80112b <set_pgfault_handler+0xf>
			cprintf("sys_page_alloc: %d\n", r);
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	50                   	push   %eax
  801181:	68 b7 17 80 00       	push   $0x8017b7
  801186:	e8 22 f0 ff ff       	call   8001ad <cprintf>
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	eb c4                	jmp    801154 <set_pgfault_handler+0x38>

00801190 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801190:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801191:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801196:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801198:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx
  80119b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 0x30(%esp), %ecx
  80119f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	subl $0x4, %ecx
  8011a3:	83 e9 04             	sub    $0x4,%ecx
	movl %ebx, (%ecx)
  8011a6:	89 19                	mov    %ebx,(%ecx)
	movl %ecx, 0x30(%esp)
  8011a8:	89 4c 24 30          	mov    %ecx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8011ac:	83 c4 08             	add    $0x8,%esp
	popal
  8011af:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 
  8011b0:	83 c4 04             	add    $0x4,%esp
	popfl
  8011b3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8011b4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8011b5:	c3                   	ret    
  8011b6:	66 90                	xchg   %ax,%ax
  8011b8:	66 90                	xchg   %ax,%ax
  8011ba:	66 90                	xchg   %ax,%ax
  8011bc:	66 90                	xchg   %ax,%ax
  8011be:	66 90                	xchg   %ax,%ax

008011c0 <__udivdi3>:
  8011c0:	f3 0f 1e fb          	endbr32 
  8011c4:	55                   	push   %ebp
  8011c5:	57                   	push   %edi
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 1c             	sub    $0x1c,%esp
  8011cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8011d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	75 19                	jne    8011f8 <__udivdi3+0x38>
  8011df:	39 f3                	cmp    %esi,%ebx
  8011e1:	76 4d                	jbe    801230 <__udivdi3+0x70>
  8011e3:	31 ff                	xor    %edi,%edi
  8011e5:	89 e8                	mov    %ebp,%eax
  8011e7:	89 f2                	mov    %esi,%edx
  8011e9:	f7 f3                	div    %ebx
  8011eb:	89 fa                	mov    %edi,%edx
  8011ed:	83 c4 1c             	add    $0x1c,%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    
  8011f5:	8d 76 00             	lea    0x0(%esi),%esi
  8011f8:	39 f0                	cmp    %esi,%eax
  8011fa:	76 14                	jbe    801210 <__udivdi3+0x50>
  8011fc:	31 ff                	xor    %edi,%edi
  8011fe:	31 c0                	xor    %eax,%eax
  801200:	89 fa                	mov    %edi,%edx
  801202:	83 c4 1c             	add    $0x1c,%esp
  801205:	5b                   	pop    %ebx
  801206:	5e                   	pop    %esi
  801207:	5f                   	pop    %edi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    
  80120a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801210:	0f bd f8             	bsr    %eax,%edi
  801213:	83 f7 1f             	xor    $0x1f,%edi
  801216:	75 48                	jne    801260 <__udivdi3+0xa0>
  801218:	39 f0                	cmp    %esi,%eax
  80121a:	72 06                	jb     801222 <__udivdi3+0x62>
  80121c:	31 c0                	xor    %eax,%eax
  80121e:	39 eb                	cmp    %ebp,%ebx
  801220:	77 de                	ja     801200 <__udivdi3+0x40>
  801222:	b8 01 00 00 00       	mov    $0x1,%eax
  801227:	eb d7                	jmp    801200 <__udivdi3+0x40>
  801229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801230:	89 d9                	mov    %ebx,%ecx
  801232:	85 db                	test   %ebx,%ebx
  801234:	75 0b                	jne    801241 <__udivdi3+0x81>
  801236:	b8 01 00 00 00       	mov    $0x1,%eax
  80123b:	31 d2                	xor    %edx,%edx
  80123d:	f7 f3                	div    %ebx
  80123f:	89 c1                	mov    %eax,%ecx
  801241:	31 d2                	xor    %edx,%edx
  801243:	89 f0                	mov    %esi,%eax
  801245:	f7 f1                	div    %ecx
  801247:	89 c6                	mov    %eax,%esi
  801249:	89 e8                	mov    %ebp,%eax
  80124b:	89 f7                	mov    %esi,%edi
  80124d:	f7 f1                	div    %ecx
  80124f:	89 fa                	mov    %edi,%edx
  801251:	83 c4 1c             	add    $0x1c,%esp
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5f                   	pop    %edi
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    
  801259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801260:	89 f9                	mov    %edi,%ecx
  801262:	ba 20 00 00 00       	mov    $0x20,%edx
  801267:	29 fa                	sub    %edi,%edx
  801269:	d3 e0                	shl    %cl,%eax
  80126b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80126f:	89 d1                	mov    %edx,%ecx
  801271:	89 d8                	mov    %ebx,%eax
  801273:	d3 e8                	shr    %cl,%eax
  801275:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801279:	09 c1                	or     %eax,%ecx
  80127b:	89 f0                	mov    %esi,%eax
  80127d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801281:	89 f9                	mov    %edi,%ecx
  801283:	d3 e3                	shl    %cl,%ebx
  801285:	89 d1                	mov    %edx,%ecx
  801287:	d3 e8                	shr    %cl,%eax
  801289:	89 f9                	mov    %edi,%ecx
  80128b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80128f:	89 eb                	mov    %ebp,%ebx
  801291:	d3 e6                	shl    %cl,%esi
  801293:	89 d1                	mov    %edx,%ecx
  801295:	d3 eb                	shr    %cl,%ebx
  801297:	09 f3                	or     %esi,%ebx
  801299:	89 c6                	mov    %eax,%esi
  80129b:	89 f2                	mov    %esi,%edx
  80129d:	89 d8                	mov    %ebx,%eax
  80129f:	f7 74 24 08          	divl   0x8(%esp)
  8012a3:	89 d6                	mov    %edx,%esi
  8012a5:	89 c3                	mov    %eax,%ebx
  8012a7:	f7 64 24 0c          	mull   0xc(%esp)
  8012ab:	39 d6                	cmp    %edx,%esi
  8012ad:	72 19                	jb     8012c8 <__udivdi3+0x108>
  8012af:	89 f9                	mov    %edi,%ecx
  8012b1:	d3 e5                	shl    %cl,%ebp
  8012b3:	39 c5                	cmp    %eax,%ebp
  8012b5:	73 04                	jae    8012bb <__udivdi3+0xfb>
  8012b7:	39 d6                	cmp    %edx,%esi
  8012b9:	74 0d                	je     8012c8 <__udivdi3+0x108>
  8012bb:	89 d8                	mov    %ebx,%eax
  8012bd:	31 ff                	xor    %edi,%edi
  8012bf:	e9 3c ff ff ff       	jmp    801200 <__udivdi3+0x40>
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8012cb:	31 ff                	xor    %edi,%edi
  8012cd:	e9 2e ff ff ff       	jmp    801200 <__udivdi3+0x40>
  8012d2:	66 90                	xchg   %ax,%ax
  8012d4:	66 90                	xchg   %ax,%ax
  8012d6:	66 90                	xchg   %ax,%ax
  8012d8:	66 90                	xchg   %ax,%ax
  8012da:	66 90                	xchg   %ax,%ax
  8012dc:	66 90                	xchg   %ax,%ax
  8012de:	66 90                	xchg   %ax,%ax

008012e0 <__umoddi3>:
  8012e0:	f3 0f 1e fb          	endbr32 
  8012e4:	55                   	push   %ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 1c             	sub    $0x1c,%esp
  8012eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8012ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012f3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8012f7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8012fb:	89 f0                	mov    %esi,%eax
  8012fd:	89 da                	mov    %ebx,%edx
  8012ff:	85 ff                	test   %edi,%edi
  801301:	75 15                	jne    801318 <__umoddi3+0x38>
  801303:	39 dd                	cmp    %ebx,%ebp
  801305:	76 39                	jbe    801340 <__umoddi3+0x60>
  801307:	f7 f5                	div    %ebp
  801309:	89 d0                	mov    %edx,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	83 c4 1c             	add    $0x1c,%esp
  801310:	5b                   	pop    %ebx
  801311:	5e                   	pop    %esi
  801312:	5f                   	pop    %edi
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    
  801315:	8d 76 00             	lea    0x0(%esi),%esi
  801318:	39 df                	cmp    %ebx,%edi
  80131a:	77 f1                	ja     80130d <__umoddi3+0x2d>
  80131c:	0f bd cf             	bsr    %edi,%ecx
  80131f:	83 f1 1f             	xor    $0x1f,%ecx
  801322:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801326:	75 40                	jne    801368 <__umoddi3+0x88>
  801328:	39 df                	cmp    %ebx,%edi
  80132a:	72 04                	jb     801330 <__umoddi3+0x50>
  80132c:	39 f5                	cmp    %esi,%ebp
  80132e:	77 dd                	ja     80130d <__umoddi3+0x2d>
  801330:	89 da                	mov    %ebx,%edx
  801332:	89 f0                	mov    %esi,%eax
  801334:	29 e8                	sub    %ebp,%eax
  801336:	19 fa                	sbb    %edi,%edx
  801338:	eb d3                	jmp    80130d <__umoddi3+0x2d>
  80133a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801340:	89 e9                	mov    %ebp,%ecx
  801342:	85 ed                	test   %ebp,%ebp
  801344:	75 0b                	jne    801351 <__umoddi3+0x71>
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f5                	div    %ebp
  80134f:	89 c1                	mov    %eax,%ecx
  801351:	89 d8                	mov    %ebx,%eax
  801353:	31 d2                	xor    %edx,%edx
  801355:	f7 f1                	div    %ecx
  801357:	89 f0                	mov    %esi,%eax
  801359:	f7 f1                	div    %ecx
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	31 d2                	xor    %edx,%edx
  80135f:	eb ac                	jmp    80130d <__umoddi3+0x2d>
  801361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801368:	8b 44 24 04          	mov    0x4(%esp),%eax
  80136c:	ba 20 00 00 00       	mov    $0x20,%edx
  801371:	29 c2                	sub    %eax,%edx
  801373:	89 c1                	mov    %eax,%ecx
  801375:	89 e8                	mov    %ebp,%eax
  801377:	d3 e7                	shl    %cl,%edi
  801379:	89 d1                	mov    %edx,%ecx
  80137b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80137f:	d3 e8                	shr    %cl,%eax
  801381:	89 c1                	mov    %eax,%ecx
  801383:	8b 44 24 04          	mov    0x4(%esp),%eax
  801387:	09 f9                	or     %edi,%ecx
  801389:	89 df                	mov    %ebx,%edi
  80138b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138f:	89 c1                	mov    %eax,%ecx
  801391:	d3 e5                	shl    %cl,%ebp
  801393:	89 d1                	mov    %edx,%ecx
  801395:	d3 ef                	shr    %cl,%edi
  801397:	89 c1                	mov    %eax,%ecx
  801399:	89 f0                	mov    %esi,%eax
  80139b:	d3 e3                	shl    %cl,%ebx
  80139d:	89 d1                	mov    %edx,%ecx
  80139f:	89 fa                	mov    %edi,%edx
  8013a1:	d3 e8                	shr    %cl,%eax
  8013a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013a8:	09 d8                	or     %ebx,%eax
  8013aa:	f7 74 24 08          	divl   0x8(%esp)
  8013ae:	89 d3                	mov    %edx,%ebx
  8013b0:	d3 e6                	shl    %cl,%esi
  8013b2:	f7 e5                	mul    %ebp
  8013b4:	89 c7                	mov    %eax,%edi
  8013b6:	89 d1                	mov    %edx,%ecx
  8013b8:	39 d3                	cmp    %edx,%ebx
  8013ba:	72 06                	jb     8013c2 <__umoddi3+0xe2>
  8013bc:	75 0e                	jne    8013cc <__umoddi3+0xec>
  8013be:	39 c6                	cmp    %eax,%esi
  8013c0:	73 0a                	jae    8013cc <__umoddi3+0xec>
  8013c2:	29 e8                	sub    %ebp,%eax
  8013c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8013c8:	89 d1                	mov    %edx,%ecx
  8013ca:	89 c7                	mov    %eax,%edi
  8013cc:	89 f5                	mov    %esi,%ebp
  8013ce:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013d2:	29 fd                	sub    %edi,%ebp
  8013d4:	19 cb                	sbb    %ecx,%ebx
  8013d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8013db:	89 d8                	mov    %ebx,%eax
  8013dd:	d3 e0                	shl    %cl,%eax
  8013df:	89 f1                	mov    %esi,%ecx
  8013e1:	d3 ed                	shr    %cl,%ebp
  8013e3:	d3 eb                	shr    %cl,%ebx
  8013e5:	09 e8                	or     %ebp,%eax
  8013e7:	89 da                	mov    %ebx,%edx
  8013e9:	83 c4 1c             	add    $0x1c,%esp
  8013ec:	5b                   	pop    %ebx
  8013ed:	5e                   	pop    %esi
  8013ee:	5f                   	pop    %edi
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    
