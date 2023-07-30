
obj/user/forktree:     file format elf32-i386


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

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 26 0b 00 00       	call   800b68 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 40 13 80 00       	push   $0x801340
  80004c:	e8 7f 01 00 00       	call   8001d0 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 ec 06 00 00       	call   80076f <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 51 13 80 00       	push   $0x801351
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 a9 06 00 00       	call   800755 <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 98 0d 00 00       	call   800e4c <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 60 00 00 00       	call   800129 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 50 13 80 00       	push   $0x801350
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

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
  8000ee:	e8 75 0a 00 00       	call   800b68 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 20 80 00       	mov    %eax,0x802004

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
  800115:	e8 b4 ff ff ff       	call   8000ce <umain>

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
  800131:	e8 f1 09 00 00       	call   800b27 <sys_env_destroy>
}
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	53                   	push   %ebx
  80013f:	83 ec 04             	sub    $0x4,%esp
  800142:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800145:	8b 13                	mov    (%ebx),%edx
  800147:	8d 42 01             	lea    0x1(%edx),%eax
  80014a:	89 03                	mov    %eax,(%ebx)
  80014c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800153:	3d ff 00 00 00       	cmp    $0xff,%eax
  800158:	74 09                	je     800163 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800163:	83 ec 08             	sub    $0x8,%esp
  800166:	68 ff 00 00 00       	push   $0xff
  80016b:	8d 43 08             	lea    0x8(%ebx),%eax
  80016e:	50                   	push   %eax
  80016f:	e8 76 09 00 00       	call   800aea <sys_cputs>
		b->idx = 0;
  800174:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	eb db                	jmp    80015a <putch+0x1f>

0080017f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800188:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018f:	00 00 00 
	b.cnt = 0;
  800192:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800199:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019c:	ff 75 0c             	push   0xc(%ebp)
  80019f:	ff 75 08             	push   0x8(%ebp)
  8001a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	68 3b 01 80 00       	push   $0x80013b
  8001ae:	e8 14 01 00 00       	call   8002c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b3:	83 c4 08             	add    $0x8,%esp
  8001b6:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c2:	50                   	push   %eax
  8001c3:	e8 22 09 00 00       	call   800aea <sys_cputs>

	return b.cnt;
}
  8001c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d9:	50                   	push   %eax
  8001da:	ff 75 08             	push   0x8(%ebp)
  8001dd:	e8 9d ff ff ff       	call   80017f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 1c             	sub    $0x1c,%esp
  8001ed:	89 c7                	mov    %eax,%edi
  8001ef:	89 d6                	mov    %edx,%esi
  8001f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f7:	89 d1                	mov    %edx,%ecx
  8001f9:	89 c2                	mov    %eax,%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800201:	8b 45 10             	mov    0x10(%ebp),%eax
  800204:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800207:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800211:	39 c2                	cmp    %eax,%edx
  800213:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800216:	72 3e                	jb     800256 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	push   0x18(%ebp)
  80021e:	83 eb 01             	sub    $0x1,%ebx
  800221:	53                   	push   %ebx
  800222:	50                   	push   %eax
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	ff 75 e4             	push   -0x1c(%ebp)
  800229:	ff 75 e0             	push   -0x20(%ebp)
  80022c:	ff 75 dc             	push   -0x24(%ebp)
  80022f:	ff 75 d8             	push   -0x28(%ebp)
  800232:	e8 b9 0e 00 00       	call   8010f0 <__udivdi3>
  800237:	83 c4 18             	add    $0x18,%esp
  80023a:	52                   	push   %edx
  80023b:	50                   	push   %eax
  80023c:	89 f2                	mov    %esi,%edx
  80023e:	89 f8                	mov    %edi,%eax
  800240:	e8 9f ff ff ff       	call   8001e4 <printnum>
  800245:	83 c4 20             	add    $0x20,%esp
  800248:	eb 13                	jmp    80025d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	56                   	push   %esi
  80024e:	ff 75 18             	push   0x18(%ebp)
  800251:	ff d7                	call   *%edi
  800253:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800256:	83 eb 01             	sub    $0x1,%ebx
  800259:	85 db                	test   %ebx,%ebx
  80025b:	7f ed                	jg     80024a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025d:	83 ec 08             	sub    $0x8,%esp
  800260:	56                   	push   %esi
  800261:	83 ec 04             	sub    $0x4,%esp
  800264:	ff 75 e4             	push   -0x1c(%ebp)
  800267:	ff 75 e0             	push   -0x20(%ebp)
  80026a:	ff 75 dc             	push   -0x24(%ebp)
  80026d:	ff 75 d8             	push   -0x28(%ebp)
  800270:	e8 9b 0f 00 00       	call   801210 <__umoddi3>
  800275:	83 c4 14             	add    $0x14,%esp
  800278:	0f be 80 60 13 80 00 	movsbl 0x801360(%eax),%eax
  80027f:	50                   	push   %eax
  800280:	ff d7                	call   *%edi
}
  800282:	83 c4 10             	add    $0x10,%esp
  800285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800288:	5b                   	pop    %ebx
  800289:	5e                   	pop    %esi
  80028a:	5f                   	pop    %edi
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800293:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800297:	8b 10                	mov    (%eax),%edx
  800299:	3b 50 04             	cmp    0x4(%eax),%edx
  80029c:	73 0a                	jae    8002a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	88 02                	mov    %al,(%edx)
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <printfmt>:
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b3:	50                   	push   %eax
  8002b4:	ff 75 10             	push   0x10(%ebp)
  8002b7:	ff 75 0c             	push   0xc(%ebp)
  8002ba:	ff 75 08             	push   0x8(%ebp)
  8002bd:	e8 05 00 00 00       	call   8002c7 <vprintfmt>
}
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	c9                   	leave  
  8002c6:	c3                   	ret    

008002c7 <vprintfmt>:
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	57                   	push   %edi
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	83 ec 3c             	sub    $0x3c,%esp
  8002d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d9:	eb 0a                	jmp    8002e5 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002db:	83 ec 08             	sub    $0x8,%esp
  8002de:	53                   	push   %ebx
  8002df:	50                   	push   %eax
  8002e0:	ff d6                	call   *%esi
  8002e2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e5:	83 c7 01             	add    $0x1,%edi
  8002e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ec:	83 f8 25             	cmp    $0x25,%eax
  8002ef:	74 0c                	je     8002fd <vprintfmt+0x36>
			if (ch == '\0')
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	75 e6                	jne    8002db <vprintfmt+0x14>
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    
		padc = ' ';
  8002fd:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800301:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800308:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800316:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80031b:	8d 47 01             	lea    0x1(%edi),%eax
  80031e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800321:	0f b6 17             	movzbl (%edi),%edx
  800324:	8d 42 dd             	lea    -0x23(%edx),%eax
  800327:	3c 55                	cmp    $0x55,%al
  800329:	0f 87 bb 03 00 00    	ja     8006ea <vprintfmt+0x423>
  80032f:	0f b6 c0             	movzbl %al,%eax
  800332:	ff 24 85 20 14 80 00 	jmp    *0x801420(,%eax,4)
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80033c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800340:	eb d9                	jmp    80031b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800345:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800349:	eb d0                	jmp    80031b <vprintfmt+0x54>
  80034b:	0f b6 d2             	movzbl %dl,%edx
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800351:	b8 00 00 00 00       	mov    $0x0,%eax
  800356:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800359:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800360:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800363:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800366:	83 f9 09             	cmp    $0x9,%ecx
  800369:	77 55                	ja     8003c0 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80036b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80036e:	eb e9                	jmp    800359 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8b 00                	mov    (%eax),%eax
  800375:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 40 04             	lea    0x4(%eax),%eax
  80037e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800384:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800388:	79 91                	jns    80031b <vprintfmt+0x54>
				width = precision, precision = -1;
  80038a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80038d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800390:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800397:	eb 82                	jmp    80031b <vprintfmt+0x54>
  800399:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80039c:	85 d2                	test   %edx,%edx
  80039e:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a3:	0f 49 c2             	cmovns %edx,%eax
  8003a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ac:	e9 6a ff ff ff       	jmp    80031b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003b4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003bb:	e9 5b ff ff ff       	jmp    80031b <vprintfmt+0x54>
  8003c0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c6:	eb bc                	jmp    800384 <vprintfmt+0xbd>
			lflag++;
  8003c8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ce:	e9 48 ff ff ff       	jmp    80031b <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 78 04             	lea    0x4(%eax),%edi
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	53                   	push   %ebx
  8003dd:	ff 30                	push   (%eax)
  8003df:	ff d6                	call   *%esi
			break;
  8003e1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003e7:	e9 9d 02 00 00       	jmp    800689 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 78 04             	lea    0x4(%eax),%edi
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	89 d0                	mov    %edx,%eax
  8003f6:	f7 d8                	neg    %eax
  8003f8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fb:	83 f8 08             	cmp    $0x8,%eax
  8003fe:	7f 23                	jg     800423 <vprintfmt+0x15c>
  800400:	8b 14 85 80 15 80 00 	mov    0x801580(,%eax,4),%edx
  800407:	85 d2                	test   %edx,%edx
  800409:	74 18                	je     800423 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80040b:	52                   	push   %edx
  80040c:	68 81 13 80 00       	push   $0x801381
  800411:	53                   	push   %ebx
  800412:	56                   	push   %esi
  800413:	e8 92 fe ff ff       	call   8002aa <printfmt>
  800418:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80041e:	e9 66 02 00 00       	jmp    800689 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800423:	50                   	push   %eax
  800424:	68 78 13 80 00       	push   $0x801378
  800429:	53                   	push   %ebx
  80042a:	56                   	push   %esi
  80042b:	e8 7a fe ff ff       	call   8002aa <printfmt>
  800430:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800433:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800436:	e9 4e 02 00 00       	jmp    800689 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	83 c0 04             	add    $0x4,%eax
  800441:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800449:	85 d2                	test   %edx,%edx
  80044b:	b8 71 13 80 00       	mov    $0x801371,%eax
  800450:	0f 45 c2             	cmovne %edx,%eax
  800453:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800456:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045a:	7e 06                	jle    800462 <vprintfmt+0x19b>
  80045c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800460:	75 0d                	jne    80046f <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800462:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800465:	89 c7                	mov    %eax,%edi
  800467:	03 45 e0             	add    -0x20(%ebp),%eax
  80046a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046d:	eb 55                	jmp    8004c4 <vprintfmt+0x1fd>
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	ff 75 d8             	push   -0x28(%ebp)
  800475:	ff 75 cc             	push   -0x34(%ebp)
  800478:	e8 0a 03 00 00       	call   800787 <strnlen>
  80047d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80048a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80048e:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800491:	eb 0f                	jmp    8004a2 <vprintfmt+0x1db>
					putch(padc, putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	53                   	push   %ebx
  800497:	ff 75 e0             	push   -0x20(%ebp)
  80049a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80049c:	83 ef 01             	sub    $0x1,%edi
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	7f ed                	jg     800493 <vprintfmt+0x1cc>
  8004a6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	0f 49 c2             	cmovns %edx,%eax
  8004b3:	29 c2                	sub    %eax,%edx
  8004b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004b8:	eb a8                	jmp    800462 <vprintfmt+0x19b>
					putch(ch, putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	52                   	push   %edx
  8004bf:	ff d6                	call   *%esi
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c9:	83 c7 01             	add    $0x1,%edi
  8004cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d0:	0f be d0             	movsbl %al,%edx
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	74 4b                	je     800522 <vprintfmt+0x25b>
  8004d7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004db:	78 06                	js     8004e3 <vprintfmt+0x21c>
  8004dd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004e1:	78 1e                	js     800501 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e7:	74 d1                	je     8004ba <vprintfmt+0x1f3>
  8004e9:	0f be c0             	movsbl %al,%eax
  8004ec:	83 e8 20             	sub    $0x20,%eax
  8004ef:	83 f8 5e             	cmp    $0x5e,%eax
  8004f2:	76 c6                	jbe    8004ba <vprintfmt+0x1f3>
					putch('?', putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	53                   	push   %ebx
  8004f8:	6a 3f                	push   $0x3f
  8004fa:	ff d6                	call   *%esi
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	eb c3                	jmp    8004c4 <vprintfmt+0x1fd>
  800501:	89 cf                	mov    %ecx,%edi
  800503:	eb 0e                	jmp    800513 <vprintfmt+0x24c>
				putch(' ', putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	53                   	push   %ebx
  800509:	6a 20                	push   $0x20
  80050b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80050d:	83 ef 01             	sub    $0x1,%edi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	85 ff                	test   %edi,%edi
  800515:	7f ee                	jg     800505 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80051a:	89 45 14             	mov    %eax,0x14(%ebp)
  80051d:	e9 67 01 00 00       	jmp    800689 <vprintfmt+0x3c2>
  800522:	89 cf                	mov    %ecx,%edi
  800524:	eb ed                	jmp    800513 <vprintfmt+0x24c>
	if (lflag >= 2)
  800526:	83 f9 01             	cmp    $0x1,%ecx
  800529:	7f 1b                	jg     800546 <vprintfmt+0x27f>
	else if (lflag)
  80052b:	85 c9                	test   %ecx,%ecx
  80052d:	74 63                	je     800592 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	99                   	cltd   
  800538:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 40 04             	lea    0x4(%eax),%eax
  800541:	89 45 14             	mov    %eax,0x14(%ebp)
  800544:	eb 17                	jmp    80055d <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 50 04             	mov    0x4(%eax),%edx
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 40 08             	lea    0x8(%eax),%eax
  80055a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80055d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800560:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800563:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800568:	85 c9                	test   %ecx,%ecx
  80056a:	0f 89 ff 00 00 00    	jns    80066f <vprintfmt+0x3a8>
				putch('-', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	53                   	push   %ebx
  800574:	6a 2d                	push   $0x2d
  800576:	ff d6                	call   *%esi
				num = -(long long) num;
  800578:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80057e:	f7 da                	neg    %edx
  800580:	83 d1 00             	adc    $0x0,%ecx
  800583:	f7 d9                	neg    %ecx
  800585:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800588:	bf 0a 00 00 00       	mov    $0xa,%edi
  80058d:	e9 dd 00 00 00       	jmp    80066f <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059a:	99                   	cltd   
  80059b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 40 04             	lea    0x4(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a7:	eb b4                	jmp    80055d <vprintfmt+0x296>
	if (lflag >= 2)
  8005a9:	83 f9 01             	cmp    $0x1,%ecx
  8005ac:	7f 1e                	jg     8005cc <vprintfmt+0x305>
	else if (lflag)
  8005ae:	85 c9                	test   %ecx,%ecx
  8005b0:	74 32                	je     8005e4 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bc:	8d 40 04             	lea    0x4(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005c7:	e9 a3 00 00 00       	jmp    80066f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8b 10                	mov    (%eax),%edx
  8005d1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d4:	8d 40 08             	lea    0x8(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005da:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005df:	e9 8b 00 00 00       	jmp    80066f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f4:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8005f9:	eb 74                	jmp    80066f <vprintfmt+0x3a8>
	if (lflag >= 2)
  8005fb:	83 f9 01             	cmp    $0x1,%ecx
  8005fe:	7f 1b                	jg     80061b <vprintfmt+0x354>
	else if (lflag)
  800600:	85 c9                	test   %ecx,%ecx
  800602:	74 2c                	je     800630 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060e:	8d 40 04             	lea    0x4(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800614:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800619:	eb 54                	jmp    80066f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	8b 48 04             	mov    0x4(%eax),%ecx
  800623:	8d 40 08             	lea    0x8(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800629:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80062e:	eb 3f                	jmp    80066f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063a:	8d 40 04             	lea    0x4(%eax),%eax
  80063d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800640:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800645:	eb 28                	jmp    80066f <vprintfmt+0x3a8>
			putch('0', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 30                	push   $0x30
  80064d:	ff d6                	call   *%esi
			putch('x', putdat);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 78                	push   $0x78
  800655:	ff d6                	call   *%esi
			num = (unsigned long long)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800661:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066a:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80066f:	83 ec 0c             	sub    $0xc,%esp
  800672:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800676:	50                   	push   %eax
  800677:	ff 75 e0             	push   -0x20(%ebp)
  80067a:	57                   	push   %edi
  80067b:	51                   	push   %ecx
  80067c:	52                   	push   %edx
  80067d:	89 da                	mov    %ebx,%edx
  80067f:	89 f0                	mov    %esi,%eax
  800681:	e8 5e fb ff ff       	call   8001e4 <printnum>
			break;
  800686:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068c:	e9 54 fc ff ff       	jmp    8002e5 <vprintfmt+0x1e>
	if (lflag >= 2)
  800691:	83 f9 01             	cmp    $0x1,%ecx
  800694:	7f 1b                	jg     8006b1 <vprintfmt+0x3ea>
	else if (lflag)
  800696:	85 c9                	test   %ecx,%ecx
  800698:	74 2c                	je     8006c6 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a4:	8d 40 04             	lea    0x4(%eax),%eax
  8006a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006aa:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006af:	eb be                	jmp    80066f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b9:	8d 40 08             	lea    0x8(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bf:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006c4:	eb a9                	jmp    80066f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 10                	mov    (%eax),%edx
  8006cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006db:	eb 92                	jmp    80066f <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	6a 25                	push   $0x25
  8006e3:	ff d6                	call   *%esi
			break;
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 9f                	jmp    800689 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 25                	push   $0x25
  8006f0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	89 f8                	mov    %edi,%eax
  8006f7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006fb:	74 05                	je     800702 <vprintfmt+0x43b>
  8006fd:	83 e8 01             	sub    $0x1,%eax
  800700:	eb f5                	jmp    8006f7 <vprintfmt+0x430>
  800702:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800705:	eb 82                	jmp    800689 <vprintfmt+0x3c2>

00800707 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 18             	sub    $0x18,%esp
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800716:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800724:	85 c0                	test   %eax,%eax
  800726:	74 26                	je     80074e <vsnprintf+0x47>
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e 22                	jle    80074e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072c:	ff 75 14             	push   0x14(%ebp)
  80072f:	ff 75 10             	push   0x10(%ebp)
  800732:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	68 8d 02 80 00       	push   $0x80028d
  80073b:	e8 87 fb ff ff       	call   8002c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800740:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800743:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	83 c4 10             	add    $0x10,%esp
}
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    
		return -E_INVAL;
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800753:	eb f7                	jmp    80074c <vsnprintf+0x45>

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	50                   	push   %eax
  80075f:	ff 75 10             	push   0x10(%ebp)
  800762:	ff 75 0c             	push   0xc(%ebp)
  800765:	ff 75 08             	push   0x8(%ebp)
  800768:	e8 9a ff ff ff       	call   800707 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	eb 03                	jmp    80077f <strlen+0x10>
		n++;
  80077c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80077f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800783:	75 f7                	jne    80077c <strlen+0xd>
	return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	eb 03                	jmp    80079a <strnlen+0x13>
		n++;
  800797:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079a:	39 d0                	cmp    %edx,%eax
  80079c:	74 08                	je     8007a6 <strnlen+0x1f>
  80079e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a2:	75 f3                	jne    800797 <strnlen+0x10>
  8007a4:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a6:	89 d0                	mov    %edx,%eax
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	53                   	push   %ebx
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007bd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c0:	83 c0 01             	add    $0x1,%eax
  8007c3:	84 d2                	test   %dl,%dl
  8007c5:	75 f2                	jne    8007b9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c7:	89 c8                	mov    %ecx,%eax
  8007c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	83 ec 10             	sub    $0x10,%esp
  8007d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d8:	53                   	push   %ebx
  8007d9:	e8 91 ff ff ff       	call   80076f <strlen>
  8007de:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e1:	ff 75 0c             	push   0xc(%ebp)
  8007e4:	01 d8                	add    %ebx,%eax
  8007e6:	50                   	push   %eax
  8007e7:	e8 be ff ff ff       	call   8007aa <strcpy>
	return dst;
}
  8007ec:	89 d8                	mov    %ebx,%eax
  8007ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fe:	89 f3                	mov    %esi,%ebx
  800800:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800803:	89 f0                	mov    %esi,%eax
  800805:	eb 0f                	jmp    800816 <strncpy+0x23>
		*dst++ = *src;
  800807:	83 c0 01             	add    $0x1,%eax
  80080a:	0f b6 0a             	movzbl (%edx),%ecx
  80080d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800810:	80 f9 01             	cmp    $0x1,%cl
  800813:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800816:	39 d8                	cmp    %ebx,%eax
  800818:	75 ed                	jne    800807 <strncpy+0x14>
	}
	return ret;
}
  80081a:	89 f0                	mov    %esi,%eax
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	56                   	push   %esi
  800824:	53                   	push   %ebx
  800825:	8b 75 08             	mov    0x8(%ebp),%esi
  800828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082b:	8b 55 10             	mov    0x10(%ebp),%edx
  80082e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800830:	85 d2                	test   %edx,%edx
  800832:	74 21                	je     800855 <strlcpy+0x35>
  800834:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800838:	89 f2                	mov    %esi,%edx
  80083a:	eb 09                	jmp    800845 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083c:	83 c1 01             	add    $0x1,%ecx
  80083f:	83 c2 01             	add    $0x1,%edx
  800842:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800845:	39 c2                	cmp    %eax,%edx
  800847:	74 09                	je     800852 <strlcpy+0x32>
  800849:	0f b6 19             	movzbl (%ecx),%ebx
  80084c:	84 db                	test   %bl,%bl
  80084e:	75 ec                	jne    80083c <strlcpy+0x1c>
  800850:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800852:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800855:	29 f0                	sub    %esi,%eax
}
  800857:	5b                   	pop    %ebx
  800858:	5e                   	pop    %esi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	eb 06                	jmp    80086c <strcmp+0x11>
		p++, q++;
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80086c:	0f b6 01             	movzbl (%ecx),%eax
  80086f:	84 c0                	test   %al,%al
  800871:	74 04                	je     800877 <strcmp+0x1c>
  800873:	3a 02                	cmp    (%edx),%al
  800875:	74 ef                	je     800866 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	0f b6 12             	movzbl (%edx),%edx
  80087d:	29 d0                	sub    %edx,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088b:	89 c3                	mov    %eax,%ebx
  80088d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800890:	eb 06                	jmp    800898 <strncmp+0x17>
		n--, p++, q++;
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800898:	39 d8                	cmp    %ebx,%eax
  80089a:	74 18                	je     8008b4 <strncmp+0x33>
  80089c:	0f b6 08             	movzbl (%eax),%ecx
  80089f:	84 c9                	test   %cl,%cl
  8008a1:	74 04                	je     8008a7 <strncmp+0x26>
  8008a3:	3a 0a                	cmp    (%edx),%cl
  8008a5:	74 eb                	je     800892 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 00             	movzbl (%eax),%eax
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
}
  8008af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    
		return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b9:	eb f4                	jmp    8008af <strncmp+0x2e>

008008bb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c5:	eb 03                	jmp    8008ca <strchr+0xf>
  8008c7:	83 c0 01             	add    $0x1,%eax
  8008ca:	0f b6 10             	movzbl (%eax),%edx
  8008cd:	84 d2                	test   %dl,%dl
  8008cf:	74 06                	je     8008d7 <strchr+0x1c>
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	75 f2                	jne    8008c7 <strchr+0xc>
  8008d5:	eb 05                	jmp    8008dc <strchr+0x21>
			return (char *) s;
	return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008eb:	38 ca                	cmp    %cl,%dl
  8008ed:	74 09                	je     8008f8 <strfind+0x1a>
  8008ef:	84 d2                	test   %dl,%dl
  8008f1:	74 05                	je     8008f8 <strfind+0x1a>
	for (; *s; s++)
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	eb f0                	jmp    8008e8 <strfind+0xa>
			break;
	return (char *) s;
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 7d 08             	mov    0x8(%ebp),%edi
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800906:	85 c9                	test   %ecx,%ecx
  800908:	74 2f                	je     800939 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090a:	89 f8                	mov    %edi,%eax
  80090c:	09 c8                	or     %ecx,%eax
  80090e:	a8 03                	test   $0x3,%al
  800910:	75 21                	jne    800933 <memset+0x39>
		c &= 0xFF;
  800912:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800916:	89 d0                	mov    %edx,%eax
  800918:	c1 e0 08             	shl    $0x8,%eax
  80091b:	89 d3                	mov    %edx,%ebx
  80091d:	c1 e3 18             	shl    $0x18,%ebx
  800920:	89 d6                	mov    %edx,%esi
  800922:	c1 e6 10             	shl    $0x10,%esi
  800925:	09 f3                	or     %esi,%ebx
  800927:	09 da                	or     %ebx,%edx
  800929:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80092e:	fc                   	cld    
  80092f:	f3 ab                	rep stos %eax,%es:(%edi)
  800931:	eb 06                	jmp    800939 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	fc                   	cld    
  800937:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800939:	89 f8                	mov    %edi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5f                   	pop    %edi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	57                   	push   %edi
  800944:	56                   	push   %esi
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094e:	39 c6                	cmp    %eax,%esi
  800950:	73 32                	jae    800984 <memmove+0x44>
  800952:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800955:	39 c2                	cmp    %eax,%edx
  800957:	76 2b                	jbe    800984 <memmove+0x44>
		s += n;
		d += n;
  800959:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095c:	89 d6                	mov    %edx,%esi
  80095e:	09 fe                	or     %edi,%esi
  800960:	09 ce                	or     %ecx,%esi
  800962:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800968:	75 0e                	jne    800978 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80096a:	83 ef 04             	sub    $0x4,%edi
  80096d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800970:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800973:	fd                   	std    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 09                	jmp    800981 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800978:	83 ef 01             	sub    $0x1,%edi
  80097b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80097e:	fd                   	std    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800981:	fc                   	cld    
  800982:	eb 1a                	jmp    80099e <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 f2                	mov    %esi,%edx
  800986:	09 c2                	or     %eax,%edx
  800988:	09 ca                	or     %ecx,%edx
  80098a:	f6 c2 03             	test   $0x3,%dl
  80098d:	75 0a                	jne    800999 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80098f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800992:	89 c7                	mov    %eax,%edi
  800994:	fc                   	cld    
  800995:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800997:	eb 05                	jmp    80099e <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800999:	89 c7                	mov    %eax,%edi
  80099b:	fc                   	cld    
  80099c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099e:	5e                   	pop    %esi
  80099f:	5f                   	pop    %edi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a8:	ff 75 10             	push   0x10(%ebp)
  8009ab:	ff 75 0c             	push   0xc(%ebp)
  8009ae:	ff 75 08             	push   0x8(%ebp)
  8009b1:	e8 8a ff ff ff       	call   800940 <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	89 c6                	mov    %eax,%esi
  8009c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	eb 06                	jmp    8009d0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009d0:	39 f0                	cmp    %esi,%eax
  8009d2:	74 14                	je     8009e8 <memcmp+0x30>
		if (*s1 != *s2)
  8009d4:	0f b6 08             	movzbl (%eax),%ecx
  8009d7:	0f b6 1a             	movzbl (%edx),%ebx
  8009da:	38 d9                	cmp    %bl,%cl
  8009dc:	74 ec                	je     8009ca <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009de:	0f b6 c1             	movzbl %cl,%eax
  8009e1:	0f b6 db             	movzbl %bl,%ebx
  8009e4:	29 d8                	sub    %ebx,%eax
  8009e6:	eb 05                	jmp    8009ed <memcmp+0x35>
	}

	return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ff:	eb 03                	jmp    800a04 <memfind+0x13>
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	39 d0                	cmp    %edx,%eax
  800a06:	73 04                	jae    800a0c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a08:	38 08                	cmp    %cl,(%eax)
  800a0a:	75 f5                	jne    800a01 <memfind+0x10>
			break;
	return (void *) s;
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	57                   	push   %edi
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 55 08             	mov    0x8(%ebp),%edx
  800a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1a:	eb 03                	jmp    800a1f <strtol+0x11>
		s++;
  800a1c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a1f:	0f b6 02             	movzbl (%edx),%eax
  800a22:	3c 20                	cmp    $0x20,%al
  800a24:	74 f6                	je     800a1c <strtol+0xe>
  800a26:	3c 09                	cmp    $0x9,%al
  800a28:	74 f2                	je     800a1c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a2a:	3c 2b                	cmp    $0x2b,%al
  800a2c:	74 2a                	je     800a58 <strtol+0x4a>
	int neg = 0;
  800a2e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a33:	3c 2d                	cmp    $0x2d,%al
  800a35:	74 2b                	je     800a62 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a37:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3d:	75 0f                	jne    800a4e <strtol+0x40>
  800a3f:	80 3a 30             	cmpb   $0x30,(%edx)
  800a42:	74 28                	je     800a6c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a4b:	0f 44 d8             	cmove  %eax,%ebx
  800a4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a53:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a56:	eb 46                	jmp    800a9e <strtol+0x90>
		s++;
  800a58:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a60:	eb d5                	jmp    800a37 <strtol+0x29>
		s++, neg = 1;
  800a62:	83 c2 01             	add    $0x1,%edx
  800a65:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6a:	eb cb                	jmp    800a37 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a70:	74 0e                	je     800a80 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a72:	85 db                	test   %ebx,%ebx
  800a74:	75 d8                	jne    800a4e <strtol+0x40>
		s++, base = 8;
  800a76:	83 c2 01             	add    $0x1,%edx
  800a79:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a7e:	eb ce                	jmp    800a4e <strtol+0x40>
		s += 2, base = 16;
  800a80:	83 c2 02             	add    $0x2,%edx
  800a83:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a88:	eb c4                	jmp    800a4e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a8a:	0f be c0             	movsbl %al,%eax
  800a8d:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a90:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a93:	7d 3a                	jge    800acf <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a95:	83 c2 01             	add    $0x1,%edx
  800a98:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800a9c:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800a9e:	0f b6 02             	movzbl (%edx),%eax
  800aa1:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aa4:	89 f3                	mov    %esi,%ebx
  800aa6:	80 fb 09             	cmp    $0x9,%bl
  800aa9:	76 df                	jbe    800a8a <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800aab:	8d 70 9f             	lea    -0x61(%eax),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 08                	ja     800abd <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ab5:	0f be c0             	movsbl %al,%eax
  800ab8:	83 e8 57             	sub    $0x57,%eax
  800abb:	eb d3                	jmp    800a90 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800abd:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 19             	cmp    $0x19,%bl
  800ac5:	77 08                	ja     800acf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ac7:	0f be c0             	movsbl %al,%eax
  800aca:	83 e8 37             	sub    $0x37,%eax
  800acd:	eb c1                	jmp    800a90 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800acf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad3:	74 05                	je     800ada <strtol+0xcc>
		*endptr = (char *) s;
  800ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ada:	89 c8                	mov    %ecx,%eax
  800adc:	f7 d8                	neg    %eax
  800ade:	85 ff                	test   %edi,%edi
  800ae0:	0f 45 c8             	cmovne %eax,%ecx
}
  800ae3:	89 c8                	mov    %ecx,%eax
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
  800af5:	8b 55 08             	mov    0x8(%ebp),%edx
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	89 c6                	mov    %eax,%esi
  800b01:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b13:	b8 01 00 00 00       	mov    $0x1,%eax
  800b18:	89 d1                	mov    %edx,%ecx
  800b1a:	89 d3                	mov    %edx,%ebx
  800b1c:	89 d7                	mov    %edx,%edi
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3d:	89 cb                	mov    %ecx,%ebx
  800b3f:	89 cf                	mov    %ecx,%edi
  800b41:	89 ce                	mov    %ecx,%esi
  800b43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7f 08                	jg     800b51 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 a4 15 80 00       	push   $0x8015a4
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 c1 15 80 00       	push   $0x8015c1
  800b63:	e8 a1 04 00 00       	call   801009 <_panic>

00800b68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 02 00 00 00       	mov    $0x2,%eax
  800b78:	89 d1                	mov    %edx,%ecx
  800b7a:	89 d3                	mov    %edx,%ebx
  800b7c:	89 d7                	mov    %edx,%edi
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_yield>:

void
sys_yield(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b97:	89 d1                	mov    %edx,%ecx
  800b99:	89 d3                	mov    %edx,%ebx
  800b9b:	89 d7                	mov    %edx,%edi
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800baf:	be 00 00 00 00       	mov    $0x0,%esi
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc2:	89 f7                	mov    %esi,%edi
  800bc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7f 08                	jg     800bd2 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 a4 15 80 00       	push   $0x8015a4
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 c1 15 80 00       	push   $0x8015c1
  800be4:	e8 20 04 00 00       	call   801009 <_panic>

00800be9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c03:	8b 75 18             	mov    0x18(%ebp),%esi
  800c06:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7f 08                	jg     800c14 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 a4 15 80 00       	push   $0x8015a4
  800c1f:	6a 23                	push   $0x23
  800c21:	68 c1 15 80 00       	push   $0x8015c1
  800c26:	e8 de 03 00 00       	call   801009 <_panic>

00800c2b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7f 08                	jg     800c56 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 a4 15 80 00       	push   $0x8015a4
  800c61:	6a 23                	push   $0x23
  800c63:	68 c1 15 80 00       	push   $0x8015c1
  800c68:	e8 9c 03 00 00       	call   801009 <_panic>

00800c6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	b8 08 00 00 00       	mov    $0x8,%eax
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7f 08                	jg     800c98 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 a4 15 80 00       	push   $0x8015a4
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 c1 15 80 00       	push   $0x8015c1
  800caa:	e8 5a 03 00 00       	call   801009 <_panic>

00800caf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7f 08                	jg     800cda <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 a4 15 80 00       	push   $0x8015a4
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 c1 15 80 00       	push   $0x8015c1
  800cec:	e8 18 03 00 00       	call   801009 <_panic>

00800cf1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2a:	89 cb                	mov    %ecx,%ebx
  800d2c:	89 cf                	mov    %ecx,%edi
  800d2e:	89 ce                	mov    %ecx,%esi
  800d30:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7f 08                	jg     800d3e <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 0c                	push   $0xc
  800d44:	68 a4 15 80 00       	push   $0x8015a4
  800d49:	6a 23                	push   $0x23
  800d4b:	68 c1 15 80 00       	push   $0x8015c1
  800d50:	e8 b4 02 00 00       	call   801009 <_panic>

00800d55 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	53                   	push   %ebx
  800d59:	83 ec 04             	sub    $0x4,%esp
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d5f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(utf->utf_err & FEC_WR) || (uvpt[PGNUM(addr)] & perm) != perm) 
  800d61:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d65:	0f 84 81 00 00 00    	je     800dec <pgfault+0x97>
  800d6b:	89 d8                	mov    %ebx,%eax
  800d6d:	c1 e8 0c             	shr    $0xc,%eax
  800d70:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d77:	25 05 08 00 00       	and    $0x805,%eax
  800d7c:	3d 05 08 00 00       	cmp    $0x805,%eax
  800d81:	75 69                	jne    800dec <pgfault+0x97>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	6a 07                	push   $0x7
  800d88:	68 00 f0 7f 00       	push   $0x7ff000
  800d8d:	6a 00                	push   $0x0
  800d8f:	e8 12 fe ff ff       	call   800ba6 <sys_page_alloc>
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	78 73                	js     800e0e <pgfault+0xb9>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800d9b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800da1:	83 ec 04             	sub    $0x4,%esp
  800da4:	68 00 10 00 00       	push   $0x1000
  800da9:	53                   	push   %ebx
  800daa:	68 00 f0 7f 00       	push   $0x7ff000
  800daf:	e8 ee fb ff ff       	call   8009a2 <memcpy>

	if ((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_W | PTE_P | PTE_U)) < 0) 
  800db4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dbb:	53                   	push   %ebx
  800dbc:	6a 00                	push   $0x0
  800dbe:	68 00 f0 7f 00       	push   $0x7ff000
  800dc3:	6a 00                	push   $0x0
  800dc5:	e8 1f fe ff ff       	call   800be9 <sys_page_map>
  800dca:	83 c4 20             	add    $0x20,%esp
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	78 57                	js     800e28 <pgfault+0xd3>
	{
		panic("sys_page_map: %e", r);
	}

	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800dd1:	83 ec 08             	sub    $0x8,%esp
  800dd4:	68 00 f0 7f 00       	push   $0x7ff000
  800dd9:	6a 00                	push   $0x0
  800ddb:	e8 4b fe ff ff       	call   800c2b <sys_page_unmap>
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	78 53                	js     800e3a <pgfault+0xe5>
		panic("sys_page_unmap: %e", r);

}
  800de7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dea:	c9                   	leave  
  800deb:	c3                   	ret    
		panic("pgfault pte: %08x, addr: %08x", uvpt[PGNUM(addr)], addr);
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	c1 e8 0c             	shr    $0xc,%eax
  800df1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	53                   	push   %ebx
  800dfc:	50                   	push   %eax
  800dfd:	68 cf 15 80 00       	push   $0x8015cf
  800e02:	6a 1f                	push   $0x1f
  800e04:	68 ed 15 80 00       	push   $0x8015ed
  800e09:	e8 fb 01 00 00       	call   801009 <_panic>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	50                   	push   %eax
  800e12:	68 00 f0 7f 00       	push   $0x7ff000
  800e17:	68 5c 16 80 00       	push   $0x80165c
  800e1c:	6a 2a                	push   $0x2a
  800e1e:	68 ed 15 80 00       	push   $0x8015ed
  800e23:	e8 e1 01 00 00       	call   801009 <_panic>
		panic("sys_page_map: %e", r);
  800e28:	50                   	push   %eax
  800e29:	68 f8 15 80 00       	push   $0x8015f8
  800e2e:	6a 30                	push   $0x30
  800e30:	68 ed 15 80 00       	push   $0x8015ed
  800e35:	e8 cf 01 00 00       	call   801009 <_panic>
		panic("sys_page_unmap: %e", r);
  800e3a:	50                   	push   %eax
  800e3b:	68 09 16 80 00       	push   $0x801609
  800e40:	6a 34                	push   $0x34
  800e42:	68 ed 15 80 00       	push   $0x8015ed
  800e47:	e8 bd 01 00 00       	call   801009 <_panic>

00800e4c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 18             	sub    $0x18,%esp
	envid_t envid;
	pte_t pte;
	uint8_t *va;
	extern unsigned char end[];

	set_pgfault_handler(pgfault);
  800e55:	68 55 0d 80 00       	push   $0x800d55
  800e5a:	e8 f0 01 00 00       	call   80104f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e5f:	b8 07 00 00 00       	mov    $0x7,%eax
  800e64:	cd 30                	int    $0x30
  800e66:	89 c6                	mov    %eax,%esi
	envid = sys_exofork(); // create child envirement
	if (envid < 0)
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	78 24                	js     800e93 <fork+0x47>
	{
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (va = 0; va < (uint8_t *)USTACKTOP; va += PGSIZE)
  800e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) 
  800e74:	0f 85 19 01 00 00    	jne    800f93 <fork+0x147>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e7a:	e8 e9 fc ff ff       	call   800b68 <sys_getenvid>
  800e7f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e84:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e87:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e8c:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e91:	eb 66                	jmp    800ef9 <fork+0xad>
		panic("sys_exofork: %e", envid); //new envirement not created
  800e93:	50                   	push   %eax
  800e94:	68 1c 16 80 00       	push   $0x80161c
  800e99:	6a 78                	push   $0x78
  800e9b:	68 ed 15 80 00       	push   $0x8015ed
  800ea0:	e8 64 01 00 00       	call   801009 <_panic>
		panic("sys_page_map: %e", r);
  800ea5:	50                   	push   %eax
  800ea6:	68 f8 15 80 00       	push   $0x8015f8
  800eab:	6a 56                	push   $0x56
  800ead:	68 ed 15 80 00       	push   $0x8015ed
  800eb2:	e8 52 01 00 00       	call   801009 <_panic>
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P))
			duppage(envid, PGNUM(va));

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  800eb7:	83 ec 04             	sub    $0x4,%esp
  800eba:	6a 07                	push   $0x7
  800ebc:	68 00 f0 bf ee       	push   $0xeebff000
  800ec1:	56                   	push   %esi
  800ec2:	e8 df fc ff ff       	call   800ba6 <sys_page_alloc>
  800ec7:	83 c4 10             	add    $0x10,%esp
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	78 35                	js     800f03 <fork+0xb7>
		panic("allocating at %x in pgfault: %e", PFTEMP, r);

	if ((r = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800ece:	a1 04 20 80 00       	mov    0x802004,%eax
  800ed3:	8b 40 64             	mov    0x64(%eax),%eax
  800ed6:	83 ec 08             	sub    $0x8,%esp
  800ed9:	50                   	push   %eax
  800eda:	56                   	push   %esi
  800edb:	e8 cf fd ff ff       	call   800caf <sys_env_set_pgfault_upcall>
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	78 39                	js     800f20 <fork+0xd4>
		panic("sys_env_set_pgfault_upcall: %e", r);

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800ee7:	83 ec 08             	sub    $0x8,%esp
  800eea:	6a 02                	push   $0x2
  800eec:	56                   	push   %esi
  800eed:	e8 7b fd ff ff       	call   800c6d <sys_env_set_status>
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	78 3c                	js     800f35 <fork+0xe9>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    
		panic("allocating at %x in pgfault: %e", PFTEMP, r);
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	50                   	push   %eax
  800f07:	68 00 f0 7f 00       	push   $0x7ff000
  800f0c:	68 5c 16 80 00       	push   $0x80165c
  800f11:	68 84 00 00 00       	push   $0x84
  800f16:	68 ed 15 80 00       	push   $0x8015ed
  800f1b:	e8 e9 00 00 00       	call   801009 <_panic>
		panic("sys_env_set_pgfault_upcall: %e", r);
  800f20:	50                   	push   %eax
  800f21:	68 7c 16 80 00       	push   $0x80167c
  800f26:	68 87 00 00 00       	push   $0x87
  800f2b:	68 ed 15 80 00       	push   $0x8015ed
  800f30:	e8 d4 00 00 00       	call   801009 <_panic>
		panic("sys_env_set_status: %e", r);
  800f35:	50                   	push   %eax
  800f36:	68 2c 16 80 00       	push   $0x80162c
  800f3b:	68 8a 00 00 00       	push   $0x8a
  800f40:	68 ed 15 80 00       	push   $0x8015ed
  800f45:	e8 bf 00 00 00       	call   801009 <_panic>
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	68 05 08 00 00       	push   $0x805
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	57                   	push   %edi
  800f55:	6a 00                	push   $0x0
  800f57:	e8 8d fc ff ff       	call   800be9 <sys_page_map>
  800f5c:	83 c4 20             	add    $0x20,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	78 7a                	js     800fdd <fork+0x191>
	if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	68 05 08 00 00       	push   $0x805
  800f6b:	57                   	push   %edi
  800f6c:	6a 00                	push   $0x0
  800f6e:	57                   	push   %edi
  800f6f:	6a 00                	push   $0x0
  800f71:	e8 73 fc ff ff       	call   800be9 <sys_page_map>
  800f76:	83 c4 20             	add    $0x20,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	0f 88 24 ff ff ff    	js     800ea5 <fork+0x59>
	for (va = 0; va < (uint8_t *)USTACKTOP; va += PGSIZE)
  800f81:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f87:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f8d:	0f 84 24 ff ff ff    	je     800eb7 <fork+0x6b>
		if ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P))
  800f93:	89 d8                	mov    %ebx,%eax
  800f95:	c1 e8 16             	shr    $0x16,%eax
  800f98:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9f:	a8 01                	test   $0x1,%al
  800fa1:	74 de                	je     800f81 <fork+0x135>
  800fa3:	89 d8                	mov    %ebx,%eax
  800fa5:	c1 e8 0c             	shr    $0xc,%eax
  800fa8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800faf:	f6 c2 01             	test   $0x1,%dl
  800fb2:	74 cd                	je     800f81 <fork+0x135>
	void *addr = (void *)(pn * PGSIZE);
  800fb4:	89 c7                	mov    %eax,%edi
  800fb6:	c1 e7 0c             	shl    $0xc,%edi
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800fb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc0:	a9 02 08 00 00       	test   $0x802,%eax
  800fc5:	75 83                	jne    800f4a <fork+0xfe>
	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	6a 05                	push   $0x5
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	57                   	push   %edi
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 13 fc ff ff       	call   800be9 <sys_page_map>
  800fd6:	83 c4 20             	add    $0x20,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	79 a4                	jns    800f81 <fork+0x135>
		panic("sys_page_map: %e", r);
  800fdd:	50                   	push   %eax
  800fde:	68 f8 15 80 00       	push   $0x8015f8
  800fe3:	6a 50                	push   $0x50
  800fe5:	68 ed 15 80 00       	push   $0x8015ed
  800fea:	e8 1a 00 00 00       	call   801009 <_panic>

00800fef <sfork>:

// Challenge!
int
sfork(void)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800ff5:	68 43 16 80 00       	push   $0x801643
  800ffa:	68 93 00 00 00       	push   $0x93
  800fff:	68 ed 15 80 00       	push   $0x8015ed
  801004:	e8 00 00 00 00       	call   801009 <_panic>

00801009 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80100e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801011:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801017:	e8 4c fb ff ff       	call   800b68 <sys_getenvid>
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	ff 75 0c             	push   0xc(%ebp)
  801022:	ff 75 08             	push   0x8(%ebp)
  801025:	56                   	push   %esi
  801026:	50                   	push   %eax
  801027:	68 9c 16 80 00       	push   $0x80169c
  80102c:	e8 9f f1 ff ff       	call   8001d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801031:	83 c4 18             	add    $0x18,%esp
  801034:	53                   	push   %ebx
  801035:	ff 75 10             	push   0x10(%ebp)
  801038:	e8 42 f1 ff ff       	call   80017f <vcprintf>
	cprintf("\n");
  80103d:	c7 04 24 4f 13 80 00 	movl   $0x80134f,(%esp)
  801044:	e8 87 f1 ff ff       	call   8001d0 <cprintf>
  801049:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80104c:	cc                   	int3   
  80104d:	eb fd                	jmp    80104c <_panic+0x43>

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
  801055:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80105c:	74 0a                	je     801068 <set_pgfault_handler+0x19>
		if (r < 0)
			cprintf("sys_env_set_pgfault_upcall: %d\n", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80105e:	8b 45 08             	mov    0x8(%ebp),%eax
  801061:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801066:	c9                   	leave  
  801067:	c3                   	ret    
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  801068:	a1 04 20 80 00       	mov    0x802004,%eax
  80106d:	8b 40 48             	mov    0x48(%eax),%eax
  801070:	83 ec 04             	sub    $0x4,%esp
  801073:	6a 07                	push   $0x7
  801075:	68 00 f0 bf ee       	push   $0xeebff000
  80107a:	50                   	push   %eax
  80107b:	e8 26 fb ff ff       	call   800ba6 <sys_page_alloc>
		if (r < 0)
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	78 29                	js     8010b0 <set_pgfault_handler+0x61>
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	68 c3 10 80 00       	push   $0x8010c3
  80108f:	6a 00                	push   $0x0
  801091:	e8 19 fc ff ff       	call   800caf <sys_env_set_pgfault_upcall>
		if (r < 0)
  801096:	83 c4 10             	add    $0x10,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	79 c1                	jns    80105e <set_pgfault_handler+0xf>
			cprintf("sys_env_set_pgfault_upcall: %d\n", r);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	50                   	push   %eax
  8010a1:	68 d4 16 80 00       	push   $0x8016d4
  8010a6:	e8 25 f1 ff ff       	call   8001d0 <cprintf>
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	eb ae                	jmp    80105e <set_pgfault_handler+0xf>
			cprintf("sys_page_alloc: %d\n", r);
  8010b0:	83 ec 08             	sub    $0x8,%esp
  8010b3:	50                   	push   %eax
  8010b4:	68 bf 16 80 00       	push   $0x8016bf
  8010b9:	e8 12 f1 ff ff       	call   8001d0 <cprintf>
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
  8010c4:	a1 08 20 80 00       	mov    0x802008,%eax
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
