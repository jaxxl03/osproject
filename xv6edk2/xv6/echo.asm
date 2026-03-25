
_echo:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	53                   	push   %ebx
  12:	51                   	push   %ecx
  13:	83 ec 10             	sub    $0x10,%esp
  16:	89 cb                	mov    %ecx,%ebx
  int i;

  for(i = 1; i < argc; i++)
  18:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  1f:	eb 3c                	jmp    5d <main+0x5d>
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  24:	83 c0 01             	add    $0x1,%eax
  27:	39 03                	cmp    %eax,(%ebx)
  29:	7e 07                	jle    32 <main+0x32>
  2b:	b9 27 08 00 00       	mov    $0x827,%ecx
  30:	eb 05                	jmp    37 <main+0x37>
  32:	b9 29 08 00 00       	mov    $0x829,%ecx
  37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  41:	8b 43 04             	mov    0x4(%ebx),%eax
  44:	01 d0                	add    %edx,%eax
  46:	8b 00                	mov    (%eax),%eax
  48:	51                   	push   %ecx
  49:	50                   	push   %eax
  4a:	68 2b 08 00 00       	push   $0x82b
  4f:	6a 01                	push   $0x1
  51:	e8 0a 04 00 00       	call   460 <printf>
  56:	83 c4 10             	add    $0x10,%esp
  for(i = 1; i < argc; i++)
  59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  60:	3b 03                	cmp    (%ebx),%eax
  62:	7c bd                	jl     21 <main+0x21>
  exit();
  64:	e8 7b 02 00 00       	call   2e4 <exit>

00000069 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  69:	55                   	push   %ebp
  6a:	89 e5                	mov    %esp,%ebp
  6c:	57                   	push   %edi
  6d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  71:	8b 55 10             	mov    0x10(%ebp),%edx
  74:	8b 45 0c             	mov    0xc(%ebp),%eax
  77:	89 cb                	mov    %ecx,%ebx
  79:	89 df                	mov    %ebx,%edi
  7b:	89 d1                	mov    %edx,%ecx
  7d:	fc                   	cld    
  7e:	f3 aa                	rep stos %al,%es:(%edi)
  80:	89 ca                	mov    %ecx,%edx
  82:	89 fb                	mov    %edi,%ebx
  84:	89 5d 08             	mov    %ebx,0x8(%ebp)
  87:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  8a:	90                   	nop
  8b:	5b                   	pop    %ebx
  8c:	5f                   	pop    %edi
  8d:	5d                   	pop    %ebp
  8e:	c3                   	ret    

0000008f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  8f:	f3 0f 1e fb          	endbr32 
  93:	55                   	push   %ebp
  94:	89 e5                	mov    %esp,%ebp
  96:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  99:	8b 45 08             	mov    0x8(%ebp),%eax
  9c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  9f:	90                   	nop
  a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  a3:	8d 42 01             	lea    0x1(%edx),%eax
  a6:	89 45 0c             	mov    %eax,0xc(%ebp)
  a9:	8b 45 08             	mov    0x8(%ebp),%eax
  ac:	8d 48 01             	lea    0x1(%eax),%ecx
  af:	89 4d 08             	mov    %ecx,0x8(%ebp)
  b2:	0f b6 12             	movzbl (%edx),%edx
  b5:	88 10                	mov    %dl,(%eax)
  b7:	0f b6 00             	movzbl (%eax),%eax
  ba:	84 c0                	test   %al,%al
  bc:	75 e2                	jne    a0 <strcpy+0x11>
    ;
  return os;
  be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c1:	c9                   	leave  
  c2:	c3                   	ret    

000000c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c3:	f3 0f 1e fb          	endbr32 
  c7:	55                   	push   %ebp
  c8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  ca:	eb 08                	jmp    d4 <strcmp+0x11>
    p++, q++;
  cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	0f b6 00             	movzbl (%eax),%eax
  da:	84 c0                	test   %al,%al
  dc:	74 10                	je     ee <strcmp+0x2b>
  de:	8b 45 08             	mov    0x8(%ebp),%eax
  e1:	0f b6 10             	movzbl (%eax),%edx
  e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  e7:	0f b6 00             	movzbl (%eax),%eax
  ea:	38 c2                	cmp    %al,%dl
  ec:	74 de                	je     cc <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  ee:	8b 45 08             	mov    0x8(%ebp),%eax
  f1:	0f b6 00             	movzbl (%eax),%eax
  f4:	0f b6 d0             	movzbl %al,%edx
  f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  fa:	0f b6 00             	movzbl (%eax),%eax
  fd:	0f b6 c0             	movzbl %al,%eax
 100:	29 c2                	sub    %eax,%edx
 102:	89 d0                	mov    %edx,%eax
}
 104:	5d                   	pop    %ebp
 105:	c3                   	ret    

00000106 <strlen>:

uint
strlen(char *s)
{
 106:	f3 0f 1e fb          	endbr32 
 10a:	55                   	push   %ebp
 10b:	89 e5                	mov    %esp,%ebp
 10d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 110:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 117:	eb 04                	jmp    11d <strlen+0x17>
 119:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 11d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	01 d0                	add    %edx,%eax
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	84 c0                	test   %al,%al
 12a:	75 ed                	jne    119 <strlen+0x13>
    ;
  return n;
 12c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12f:	c9                   	leave  
 130:	c3                   	ret    

00000131 <memset>:

void*
memset(void *dst, int c, uint n)
{
 131:	f3 0f 1e fb          	endbr32 
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 138:	8b 45 10             	mov    0x10(%ebp),%eax
 13b:	50                   	push   %eax
 13c:	ff 75 0c             	pushl  0xc(%ebp)
 13f:	ff 75 08             	pushl  0x8(%ebp)
 142:	e8 22 ff ff ff       	call   69 <stosb>
 147:	83 c4 0c             	add    $0xc,%esp
  return dst;
 14a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 14d:	c9                   	leave  
 14e:	c3                   	ret    

0000014f <strchr>:

char*
strchr(const char *s, char c)
{
 14f:	f3 0f 1e fb          	endbr32 
 153:	55                   	push   %ebp
 154:	89 e5                	mov    %esp,%ebp
 156:	83 ec 04             	sub    $0x4,%esp
 159:	8b 45 0c             	mov    0xc(%ebp),%eax
 15c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 15f:	eb 14                	jmp    175 <strchr+0x26>
    if(*s == c)
 161:	8b 45 08             	mov    0x8(%ebp),%eax
 164:	0f b6 00             	movzbl (%eax),%eax
 167:	38 45 fc             	cmp    %al,-0x4(%ebp)
 16a:	75 05                	jne    171 <strchr+0x22>
      return (char*)s;
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	eb 13                	jmp    184 <strchr+0x35>
  for(; *s; s++)
 171:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 175:	8b 45 08             	mov    0x8(%ebp),%eax
 178:	0f b6 00             	movzbl (%eax),%eax
 17b:	84 c0                	test   %al,%al
 17d:	75 e2                	jne    161 <strchr+0x12>
  return 0;
 17f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 184:	c9                   	leave  
 185:	c3                   	ret    

00000186 <gets>:

char*
gets(char *buf, int max)
{
 186:	f3 0f 1e fb          	endbr32 
 18a:	55                   	push   %ebp
 18b:	89 e5                	mov    %esp,%ebp
 18d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 190:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 197:	eb 42                	jmp    1db <gets+0x55>
    cc = read(0, &c, 1);
 199:	83 ec 04             	sub    $0x4,%esp
 19c:	6a 01                	push   $0x1
 19e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1a1:	50                   	push   %eax
 1a2:	6a 00                	push   $0x0
 1a4:	e8 53 01 00 00       	call   2fc <read>
 1a9:	83 c4 10             	add    $0x10,%esp
 1ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b3:	7e 33                	jle    1e8 <gets+0x62>
      break;
    buf[i++] = c;
 1b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b8:	8d 50 01             	lea    0x1(%eax),%edx
 1bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1be:	89 c2                	mov    %eax,%edx
 1c0:	8b 45 08             	mov    0x8(%ebp),%eax
 1c3:	01 c2                	add    %eax,%edx
 1c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c9:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1cb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1cf:	3c 0a                	cmp    $0xa,%al
 1d1:	74 16                	je     1e9 <gets+0x63>
 1d3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d7:	3c 0d                	cmp    $0xd,%al
 1d9:	74 0e                	je     1e9 <gets+0x63>
  for(i=0; i+1 < max; ){
 1db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1de:	83 c0 01             	add    $0x1,%eax
 1e1:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1e4:	7f b3                	jg     199 <gets+0x13>
 1e6:	eb 01                	jmp    1e9 <gets+0x63>
      break;
 1e8:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	01 d0                	add    %edx,%eax
 1f1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1f7:	c9                   	leave  
 1f8:	c3                   	ret    

000001f9 <stat>:

int
stat(char *n, struct stat *st)
{
 1f9:	f3 0f 1e fb          	endbr32 
 1fd:	55                   	push   %ebp
 1fe:	89 e5                	mov    %esp,%ebp
 200:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 203:	83 ec 08             	sub    $0x8,%esp
 206:	6a 00                	push   $0x0
 208:	ff 75 08             	pushl  0x8(%ebp)
 20b:	e8 14 01 00 00       	call   324 <open>
 210:	83 c4 10             	add    $0x10,%esp
 213:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 216:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 21a:	79 07                	jns    223 <stat+0x2a>
    return -1;
 21c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 221:	eb 25                	jmp    248 <stat+0x4f>
  r = fstat(fd, st);
 223:	83 ec 08             	sub    $0x8,%esp
 226:	ff 75 0c             	pushl  0xc(%ebp)
 229:	ff 75 f4             	pushl  -0xc(%ebp)
 22c:	e8 0b 01 00 00       	call   33c <fstat>
 231:	83 c4 10             	add    $0x10,%esp
 234:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 237:	83 ec 0c             	sub    $0xc,%esp
 23a:	ff 75 f4             	pushl  -0xc(%ebp)
 23d:	e8 ca 00 00 00       	call   30c <close>
 242:	83 c4 10             	add    $0x10,%esp
  return r;
 245:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 248:	c9                   	leave  
 249:	c3                   	ret    

0000024a <atoi>:

int
atoi(const char *s)
{
 24a:	f3 0f 1e fb          	endbr32 
 24e:	55                   	push   %ebp
 24f:	89 e5                	mov    %esp,%ebp
 251:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 254:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 25b:	eb 25                	jmp    282 <atoi+0x38>
    n = n*10 + *s++ - '0';
 25d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 260:	89 d0                	mov    %edx,%eax
 262:	c1 e0 02             	shl    $0x2,%eax
 265:	01 d0                	add    %edx,%eax
 267:	01 c0                	add    %eax,%eax
 269:	89 c1                	mov    %eax,%ecx
 26b:	8b 45 08             	mov    0x8(%ebp),%eax
 26e:	8d 50 01             	lea    0x1(%eax),%edx
 271:	89 55 08             	mov    %edx,0x8(%ebp)
 274:	0f b6 00             	movzbl (%eax),%eax
 277:	0f be c0             	movsbl %al,%eax
 27a:	01 c8                	add    %ecx,%eax
 27c:	83 e8 30             	sub    $0x30,%eax
 27f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	0f b6 00             	movzbl (%eax),%eax
 288:	3c 2f                	cmp    $0x2f,%al
 28a:	7e 0a                	jle    296 <atoi+0x4c>
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	0f b6 00             	movzbl (%eax),%eax
 292:	3c 39                	cmp    $0x39,%al
 294:	7e c7                	jle    25d <atoi+0x13>
  return n;
 296:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 299:	c9                   	leave  
 29a:	c3                   	ret    

0000029b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 29b:	f3 0f 1e fb          	endbr32 
 29f:	55                   	push   %ebp
 2a0:	89 e5                	mov    %esp,%ebp
 2a2:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ae:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b1:	eb 17                	jmp    2ca <memmove+0x2f>
    *dst++ = *src++;
 2b3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2b6:	8d 42 01             	lea    0x1(%edx),%eax
 2b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2bf:	8d 48 01             	lea    0x1(%eax),%ecx
 2c2:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2c5:	0f b6 12             	movzbl (%edx),%edx
 2c8:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2ca:	8b 45 10             	mov    0x10(%ebp),%eax
 2cd:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d0:	89 55 10             	mov    %edx,0x10(%ebp)
 2d3:	85 c0                	test   %eax,%eax
 2d5:	7f dc                	jg     2b3 <memmove+0x18>
  return vdst;
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2da:	c9                   	leave  
 2db:	c3                   	ret    

000002dc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2dc:	b8 01 00 00 00       	mov    $0x1,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <exit>:
SYSCALL(exit)
 2e4:	b8 02 00 00 00       	mov    $0x2,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <wait>:
SYSCALL(wait)
 2ec:	b8 03 00 00 00       	mov    $0x3,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <pipe>:
SYSCALL(pipe)
 2f4:	b8 04 00 00 00       	mov    $0x4,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <read>:
SYSCALL(read)
 2fc:	b8 05 00 00 00       	mov    $0x5,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <write>:
SYSCALL(write)
 304:	b8 10 00 00 00       	mov    $0x10,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <close>:
SYSCALL(close)
 30c:	b8 15 00 00 00       	mov    $0x15,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <kill>:
SYSCALL(kill)
 314:	b8 06 00 00 00       	mov    $0x6,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <exec>:
SYSCALL(exec)
 31c:	b8 07 00 00 00       	mov    $0x7,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <open>:
SYSCALL(open)
 324:	b8 0f 00 00 00       	mov    $0xf,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <mknod>:
SYSCALL(mknod)
 32c:	b8 11 00 00 00       	mov    $0x11,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <unlink>:
SYSCALL(unlink)
 334:	b8 12 00 00 00       	mov    $0x12,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <fstat>:
SYSCALL(fstat)
 33c:	b8 08 00 00 00       	mov    $0x8,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <link>:
SYSCALL(link)
 344:	b8 13 00 00 00       	mov    $0x13,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <mkdir>:
SYSCALL(mkdir)
 34c:	b8 14 00 00 00       	mov    $0x14,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <chdir>:
SYSCALL(chdir)
 354:	b8 09 00 00 00       	mov    $0x9,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <dup>:
SYSCALL(dup)
 35c:	b8 0a 00 00 00       	mov    $0xa,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <getpid>:
SYSCALL(getpid)
 364:	b8 0b 00 00 00       	mov    $0xb,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <sbrk>:
SYSCALL(sbrk)
 36c:	b8 0c 00 00 00       	mov    $0xc,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <sleep>:
SYSCALL(sleep)
 374:	b8 0d 00 00 00       	mov    $0xd,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <uptime>:
SYSCALL(uptime)
 37c:	b8 0e 00 00 00       	mov    $0xe,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 384:	f3 0f 1e fb          	endbr32 
 388:	55                   	push   %ebp
 389:	89 e5                	mov    %esp,%ebp
 38b:	83 ec 18             	sub    $0x18,%esp
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 394:	83 ec 04             	sub    $0x4,%esp
 397:	6a 01                	push   $0x1
 399:	8d 45 f4             	lea    -0xc(%ebp),%eax
 39c:	50                   	push   %eax
 39d:	ff 75 08             	pushl  0x8(%ebp)
 3a0:	e8 5f ff ff ff       	call   304 <write>
 3a5:	83 c4 10             	add    $0x10,%esp
}
 3a8:	90                   	nop
 3a9:	c9                   	leave  
 3aa:	c3                   	ret    

000003ab <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ab:	f3 0f 1e fb          	endbr32 
 3af:	55                   	push   %ebp
 3b0:	89 e5                	mov    %esp,%ebp
 3b2:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3bc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3c0:	74 17                	je     3d9 <printint+0x2e>
 3c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3c6:	79 11                	jns    3d9 <printint+0x2e>
    neg = 1;
 3c8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d2:	f7 d8                	neg    %eax
 3d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d7:	eb 06                	jmp    3df <printint+0x34>
  } else {
    x = xx;
 3d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ec:	ba 00 00 00 00       	mov    $0x0,%edx
 3f1:	f7 f1                	div    %ecx
 3f3:	89 d1                	mov    %edx,%ecx
 3f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3f8:	8d 50 01             	lea    0x1(%eax),%edx
 3fb:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3fe:	0f b6 91 80 0a 00 00 	movzbl 0xa80(%ecx),%edx
 405:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 409:	8b 4d 10             	mov    0x10(%ebp),%ecx
 40c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 40f:	ba 00 00 00 00       	mov    $0x0,%edx
 414:	f7 f1                	div    %ecx
 416:	89 45 ec             	mov    %eax,-0x14(%ebp)
 419:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 41d:	75 c7                	jne    3e6 <printint+0x3b>
  if(neg)
 41f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 423:	74 2d                	je     452 <printint+0xa7>
    buf[i++] = '-';
 425:	8b 45 f4             	mov    -0xc(%ebp),%eax
 428:	8d 50 01             	lea    0x1(%eax),%edx
 42b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 42e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 433:	eb 1d                	jmp    452 <printint+0xa7>
    putc(fd, buf[i]);
 435:	8d 55 dc             	lea    -0x24(%ebp),%edx
 438:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43b:	01 d0                	add    %edx,%eax
 43d:	0f b6 00             	movzbl (%eax),%eax
 440:	0f be c0             	movsbl %al,%eax
 443:	83 ec 08             	sub    $0x8,%esp
 446:	50                   	push   %eax
 447:	ff 75 08             	pushl  0x8(%ebp)
 44a:	e8 35 ff ff ff       	call   384 <putc>
 44f:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 452:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 456:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 45a:	79 d9                	jns    435 <printint+0x8a>
}
 45c:	90                   	nop
 45d:	90                   	nop
 45e:	c9                   	leave  
 45f:	c3                   	ret    

00000460 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 460:	f3 0f 1e fb          	endbr32 
 464:	55                   	push   %ebp
 465:	89 e5                	mov    %esp,%ebp
 467:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 46a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 471:	8d 45 0c             	lea    0xc(%ebp),%eax
 474:	83 c0 04             	add    $0x4,%eax
 477:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 47a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 481:	e9 59 01 00 00       	jmp    5df <printf+0x17f>
    c = fmt[i] & 0xff;
 486:	8b 55 0c             	mov    0xc(%ebp),%edx
 489:	8b 45 f0             	mov    -0x10(%ebp),%eax
 48c:	01 d0                	add    %edx,%eax
 48e:	0f b6 00             	movzbl (%eax),%eax
 491:	0f be c0             	movsbl %al,%eax
 494:	25 ff 00 00 00       	and    $0xff,%eax
 499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 49c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a0:	75 2c                	jne    4ce <printf+0x6e>
      if(c == '%'){
 4a2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4a6:	75 0c                	jne    4b4 <printf+0x54>
        state = '%';
 4a8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4af:	e9 27 01 00 00       	jmp    5db <printf+0x17b>
      } else {
        putc(fd, c);
 4b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4b7:	0f be c0             	movsbl %al,%eax
 4ba:	83 ec 08             	sub    $0x8,%esp
 4bd:	50                   	push   %eax
 4be:	ff 75 08             	pushl  0x8(%ebp)
 4c1:	e8 be fe ff ff       	call   384 <putc>
 4c6:	83 c4 10             	add    $0x10,%esp
 4c9:	e9 0d 01 00 00       	jmp    5db <printf+0x17b>
      }
    } else if(state == '%'){
 4ce:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4d2:	0f 85 03 01 00 00    	jne    5db <printf+0x17b>
      if(c == 'd'){
 4d8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4dc:	75 1e                	jne    4fc <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e1:	8b 00                	mov    (%eax),%eax
 4e3:	6a 01                	push   $0x1
 4e5:	6a 0a                	push   $0xa
 4e7:	50                   	push   %eax
 4e8:	ff 75 08             	pushl  0x8(%ebp)
 4eb:	e8 bb fe ff ff       	call   3ab <printint>
 4f0:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f7:	e9 d8 00 00 00       	jmp    5d4 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 4fc:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 500:	74 06                	je     508 <printf+0xa8>
 502:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 506:	75 1e                	jne    526 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 508:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50b:	8b 00                	mov    (%eax),%eax
 50d:	6a 00                	push   $0x0
 50f:	6a 10                	push   $0x10
 511:	50                   	push   %eax
 512:	ff 75 08             	pushl  0x8(%ebp)
 515:	e8 91 fe ff ff       	call   3ab <printint>
 51a:	83 c4 10             	add    $0x10,%esp
        ap++;
 51d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 521:	e9 ae 00 00 00       	jmp    5d4 <printf+0x174>
      } else if(c == 's'){
 526:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 52a:	75 43                	jne    56f <printf+0x10f>
        s = (char*)*ap;
 52c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 52f:	8b 00                	mov    (%eax),%eax
 531:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 534:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 538:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53c:	75 25                	jne    563 <printf+0x103>
          s = "(null)";
 53e:	c7 45 f4 30 08 00 00 	movl   $0x830,-0xc(%ebp)
        while(*s != 0){
 545:	eb 1c                	jmp    563 <printf+0x103>
          putc(fd, *s);
 547:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54a:	0f b6 00             	movzbl (%eax),%eax
 54d:	0f be c0             	movsbl %al,%eax
 550:	83 ec 08             	sub    $0x8,%esp
 553:	50                   	push   %eax
 554:	ff 75 08             	pushl  0x8(%ebp)
 557:	e8 28 fe ff ff       	call   384 <putc>
 55c:	83 c4 10             	add    $0x10,%esp
          s++;
 55f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 563:	8b 45 f4             	mov    -0xc(%ebp),%eax
 566:	0f b6 00             	movzbl (%eax),%eax
 569:	84 c0                	test   %al,%al
 56b:	75 da                	jne    547 <printf+0xe7>
 56d:	eb 65                	jmp    5d4 <printf+0x174>
        }
      } else if(c == 'c'){
 56f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 573:	75 1d                	jne    592 <printf+0x132>
        putc(fd, *ap);
 575:	8b 45 e8             	mov    -0x18(%ebp),%eax
 578:	8b 00                	mov    (%eax),%eax
 57a:	0f be c0             	movsbl %al,%eax
 57d:	83 ec 08             	sub    $0x8,%esp
 580:	50                   	push   %eax
 581:	ff 75 08             	pushl  0x8(%ebp)
 584:	e8 fb fd ff ff       	call   384 <putc>
 589:	83 c4 10             	add    $0x10,%esp
        ap++;
 58c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 590:	eb 42                	jmp    5d4 <printf+0x174>
      } else if(c == '%'){
 592:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 596:	75 17                	jne    5af <printf+0x14f>
        putc(fd, c);
 598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59b:	0f be c0             	movsbl %al,%eax
 59e:	83 ec 08             	sub    $0x8,%esp
 5a1:	50                   	push   %eax
 5a2:	ff 75 08             	pushl  0x8(%ebp)
 5a5:	e8 da fd ff ff       	call   384 <putc>
 5aa:	83 c4 10             	add    $0x10,%esp
 5ad:	eb 25                	jmp    5d4 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5af:	83 ec 08             	sub    $0x8,%esp
 5b2:	6a 25                	push   $0x25
 5b4:	ff 75 08             	pushl  0x8(%ebp)
 5b7:	e8 c8 fd ff ff       	call   384 <putc>
 5bc:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c2:	0f be c0             	movsbl %al,%eax
 5c5:	83 ec 08             	sub    $0x8,%esp
 5c8:	50                   	push   %eax
 5c9:	ff 75 08             	pushl  0x8(%ebp)
 5cc:	e8 b3 fd ff ff       	call   384 <putc>
 5d1:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5db:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5df:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e5:	01 d0                	add    %edx,%eax
 5e7:	0f b6 00             	movzbl (%eax),%eax
 5ea:	84 c0                	test   %al,%al
 5ec:	0f 85 94 fe ff ff    	jne    486 <printf+0x26>
    }
  }
}
 5f2:	90                   	nop
 5f3:	90                   	nop
 5f4:	c9                   	leave  
 5f5:	c3                   	ret    

000005f6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f6:	f3 0f 1e fb          	endbr32 
 5fa:	55                   	push   %ebp
 5fb:	89 e5                	mov    %esp,%ebp
 5fd:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 600:	8b 45 08             	mov    0x8(%ebp),%eax
 603:	83 e8 08             	sub    $0x8,%eax
 606:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 609:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 60e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 611:	eb 24                	jmp    637 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 613:	8b 45 fc             	mov    -0x4(%ebp),%eax
 616:	8b 00                	mov    (%eax),%eax
 618:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 61b:	72 12                	jb     62f <free+0x39>
 61d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 620:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 623:	77 24                	ja     649 <free+0x53>
 625:	8b 45 fc             	mov    -0x4(%ebp),%eax
 628:	8b 00                	mov    (%eax),%eax
 62a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 62d:	72 1a                	jb     649 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 62f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 632:	8b 00                	mov    (%eax),%eax
 634:	89 45 fc             	mov    %eax,-0x4(%ebp)
 637:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63d:	76 d4                	jbe    613 <free+0x1d>
 63f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 642:	8b 00                	mov    (%eax),%eax
 644:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 647:	73 ca                	jae    613 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 649:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64c:	8b 40 04             	mov    0x4(%eax),%eax
 64f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 656:	8b 45 f8             	mov    -0x8(%ebp),%eax
 659:	01 c2                	add    %eax,%edx
 65b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65e:	8b 00                	mov    (%eax),%eax
 660:	39 c2                	cmp    %eax,%edx
 662:	75 24                	jne    688 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 664:	8b 45 f8             	mov    -0x8(%ebp),%eax
 667:	8b 50 04             	mov    0x4(%eax),%edx
 66a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66d:	8b 00                	mov    (%eax),%eax
 66f:	8b 40 04             	mov    0x4(%eax),%eax
 672:	01 c2                	add    %eax,%edx
 674:	8b 45 f8             	mov    -0x8(%ebp),%eax
 677:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 67a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67d:	8b 00                	mov    (%eax),%eax
 67f:	8b 10                	mov    (%eax),%edx
 681:	8b 45 f8             	mov    -0x8(%ebp),%eax
 684:	89 10                	mov    %edx,(%eax)
 686:	eb 0a                	jmp    692 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 688:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68b:	8b 10                	mov    (%eax),%edx
 68d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 690:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 692:	8b 45 fc             	mov    -0x4(%ebp),%eax
 695:	8b 40 04             	mov    0x4(%eax),%eax
 698:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 69f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a2:	01 d0                	add    %edx,%eax
 6a4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6a7:	75 20                	jne    6c9 <free+0xd3>
    p->s.size += bp->s.size;
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 50 04             	mov    0x4(%eax),%edx
 6af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b2:	8b 40 04             	mov    0x4(%eax),%eax
 6b5:	01 c2                	add    %eax,%edx
 6b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ba:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c0:	8b 10                	mov    (%eax),%edx
 6c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c5:	89 10                	mov    %edx,(%eax)
 6c7:	eb 08                	jmp    6d1 <free+0xdb>
  } else
    p->s.ptr = bp;
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6cf:	89 10                	mov    %edx,(%eax)
  freep = p;
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	a3 9c 0a 00 00       	mov    %eax,0xa9c
}
 6d9:	90                   	nop
 6da:	c9                   	leave  
 6db:	c3                   	ret    

000006dc <morecore>:

static Header*
morecore(uint nu)
{
 6dc:	f3 0f 1e fb          	endbr32 
 6e0:	55                   	push   %ebp
 6e1:	89 e5                	mov    %esp,%ebp
 6e3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6e6:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6ed:	77 07                	ja     6f6 <morecore+0x1a>
    nu = 4096;
 6ef:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6f6:	8b 45 08             	mov    0x8(%ebp),%eax
 6f9:	c1 e0 03             	shl    $0x3,%eax
 6fc:	83 ec 0c             	sub    $0xc,%esp
 6ff:	50                   	push   %eax
 700:	e8 67 fc ff ff       	call   36c <sbrk>
 705:	83 c4 10             	add    $0x10,%esp
 708:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 70b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 70f:	75 07                	jne    718 <morecore+0x3c>
    return 0;
 711:	b8 00 00 00 00       	mov    $0x0,%eax
 716:	eb 26                	jmp    73e <morecore+0x62>
  hp = (Header*)p;
 718:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 71e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 721:	8b 55 08             	mov    0x8(%ebp),%edx
 724:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 727:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72a:	83 c0 08             	add    $0x8,%eax
 72d:	83 ec 0c             	sub    $0xc,%esp
 730:	50                   	push   %eax
 731:	e8 c0 fe ff ff       	call   5f6 <free>
 736:	83 c4 10             	add    $0x10,%esp
  return freep;
 739:	a1 9c 0a 00 00       	mov    0xa9c,%eax
}
 73e:	c9                   	leave  
 73f:	c3                   	ret    

00000740 <malloc>:

void*
malloc(uint nbytes)
{
 740:	f3 0f 1e fb          	endbr32 
 744:	55                   	push   %ebp
 745:	89 e5                	mov    %esp,%ebp
 747:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 74a:	8b 45 08             	mov    0x8(%ebp),%eax
 74d:	83 c0 07             	add    $0x7,%eax
 750:	c1 e8 03             	shr    $0x3,%eax
 753:	83 c0 01             	add    $0x1,%eax
 756:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 759:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 75e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 761:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 765:	75 23                	jne    78a <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 767:	c7 45 f0 94 0a 00 00 	movl   $0xa94,-0x10(%ebp)
 76e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 771:	a3 9c 0a 00 00       	mov    %eax,0xa9c
 776:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 77b:	a3 94 0a 00 00       	mov    %eax,0xa94
    base.s.size = 0;
 780:	c7 05 98 0a 00 00 00 	movl   $0x0,0xa98
 787:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78d:	8b 00                	mov    (%eax),%eax
 78f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	8b 40 04             	mov    0x4(%eax),%eax
 798:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 79b:	77 4d                	ja     7ea <malloc+0xaa>
      if(p->s.size == nunits)
 79d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a0:	8b 40 04             	mov    0x4(%eax),%eax
 7a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7a6:	75 0c                	jne    7b4 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ab:	8b 10                	mov    (%eax),%edx
 7ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b0:	89 10                	mov    %edx,(%eax)
 7b2:	eb 26                	jmp    7da <malloc+0x9a>
      else {
        p->s.size -= nunits;
 7b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b7:	8b 40 04             	mov    0x4(%eax),%eax
 7ba:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7bd:	89 c2                	mov    %eax,%edx
 7bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c8:	8b 40 04             	mov    0x4(%eax),%eax
 7cb:	c1 e0 03             	shl    $0x3,%eax
 7ce:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7d7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7da:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dd:	a3 9c 0a 00 00       	mov    %eax,0xa9c
      return (void*)(p + 1);
 7e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e5:	83 c0 08             	add    $0x8,%eax
 7e8:	eb 3b                	jmp    825 <malloc+0xe5>
    }
    if(p == freep)
 7ea:	a1 9c 0a 00 00       	mov    0xa9c,%eax
 7ef:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7f2:	75 1e                	jne    812 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 7f4:	83 ec 0c             	sub    $0xc,%esp
 7f7:	ff 75 ec             	pushl  -0x14(%ebp)
 7fa:	e8 dd fe ff ff       	call   6dc <morecore>
 7ff:	83 c4 10             	add    $0x10,%esp
 802:	89 45 f4             	mov    %eax,-0xc(%ebp)
 805:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 809:	75 07                	jne    812 <malloc+0xd2>
        return 0;
 80b:	b8 00 00 00 00       	mov    $0x0,%eax
 810:	eb 13                	jmp    825 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 812:	8b 45 f4             	mov    -0xc(%ebp),%eax
 815:	89 45 f0             	mov    %eax,-0x10(%ebp)
 818:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81b:	8b 00                	mov    (%eax),%eax
 81d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 820:	e9 6d ff ff ff       	jmp    792 <malloc+0x52>
  }
}
 825:	c9                   	leave  
 826:	c3                   	ret    
