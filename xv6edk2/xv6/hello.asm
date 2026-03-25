
_hello:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int main(int argc, char *argv[]) {
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 04             	sub    $0x4,%esp
	printf(1, "Hello world!\n");
  15:	83 ec 08             	sub    $0x8,%esp
  18:	68 fa 07 00 00       	push   $0x7fa
  1d:	6a 01                	push   $0x1
  1f:	e8 0f 04 00 00       	call   433 <printf>
  24:	83 c4 10             	add    $0x10,%esp
	exit();
  27:	e8 7b 02 00 00       	call   2a7 <exit>

0000002c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  2c:	55                   	push   %ebp
  2d:	89 e5                	mov    %esp,%ebp
  2f:	57                   	push   %edi
  30:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  34:	8b 55 10             	mov    0x10(%ebp),%edx
  37:	8b 45 0c             	mov    0xc(%ebp),%eax
  3a:	89 cb                	mov    %ecx,%ebx
  3c:	89 df                	mov    %ebx,%edi
  3e:	89 d1                	mov    %edx,%ecx
  40:	fc                   	cld    
  41:	f3 aa                	rep stos %al,%es:(%edi)
  43:	89 ca                	mov    %ecx,%edx
  45:	89 fb                	mov    %edi,%ebx
  47:	89 5d 08             	mov    %ebx,0x8(%ebp)
  4a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  4d:	90                   	nop
  4e:	5b                   	pop    %ebx
  4f:	5f                   	pop    %edi
  50:	5d                   	pop    %ebp
  51:	c3                   	ret    

00000052 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  52:	f3 0f 1e fb          	endbr32 
  56:	55                   	push   %ebp
  57:	89 e5                	mov    %esp,%ebp
  59:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  5c:	8b 45 08             	mov    0x8(%ebp),%eax
  5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  62:	90                   	nop
  63:	8b 55 0c             	mov    0xc(%ebp),%edx
  66:	8d 42 01             	lea    0x1(%edx),%eax
  69:	89 45 0c             	mov    %eax,0xc(%ebp)
  6c:	8b 45 08             	mov    0x8(%ebp),%eax
  6f:	8d 48 01             	lea    0x1(%eax),%ecx
  72:	89 4d 08             	mov    %ecx,0x8(%ebp)
  75:	0f b6 12             	movzbl (%edx),%edx
  78:	88 10                	mov    %dl,(%eax)
  7a:	0f b6 00             	movzbl (%eax),%eax
  7d:	84 c0                	test   %al,%al
  7f:	75 e2                	jne    63 <strcpy+0x11>
    ;
  return os;
  81:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  84:	c9                   	leave  
  85:	c3                   	ret    

00000086 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  86:	f3 0f 1e fb          	endbr32 
  8a:	55                   	push   %ebp
  8b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  8d:	eb 08                	jmp    97 <strcmp+0x11>
    p++, q++;
  8f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  93:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  97:	8b 45 08             	mov    0x8(%ebp),%eax
  9a:	0f b6 00             	movzbl (%eax),%eax
  9d:	84 c0                	test   %al,%al
  9f:	74 10                	je     b1 <strcmp+0x2b>
  a1:	8b 45 08             	mov    0x8(%ebp),%eax
  a4:	0f b6 10             	movzbl (%eax),%edx
  a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  aa:	0f b6 00             	movzbl (%eax),%eax
  ad:	38 c2                	cmp    %al,%dl
  af:	74 de                	je     8f <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  b1:	8b 45 08             	mov    0x8(%ebp),%eax
  b4:	0f b6 00             	movzbl (%eax),%eax
  b7:	0f b6 d0             	movzbl %al,%edx
  ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  bd:	0f b6 00             	movzbl (%eax),%eax
  c0:	0f b6 c0             	movzbl %al,%eax
  c3:	29 c2                	sub    %eax,%edx
  c5:	89 d0                	mov    %edx,%eax
}
  c7:	5d                   	pop    %ebp
  c8:	c3                   	ret    

000000c9 <strlen>:

uint
strlen(char *s)
{
  c9:	f3 0f 1e fb          	endbr32 
  cd:	55                   	push   %ebp
  ce:	89 e5                	mov    %esp,%ebp
  d0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  d3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  da:	eb 04                	jmp    e0 <strlen+0x17>
  dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	01 d0                	add    %edx,%eax
  e8:	0f b6 00             	movzbl (%eax),%eax
  eb:	84 c0                	test   %al,%al
  ed:	75 ed                	jne    dc <strlen+0x13>
    ;
  return n;
  ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f2:	c9                   	leave  
  f3:	c3                   	ret    

000000f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f4:	f3 0f 1e fb          	endbr32 
  f8:	55                   	push   %ebp
  f9:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
  fb:	8b 45 10             	mov    0x10(%ebp),%eax
  fe:	50                   	push   %eax
  ff:	ff 75 0c             	pushl  0xc(%ebp)
 102:	ff 75 08             	pushl  0x8(%ebp)
 105:	e8 22 ff ff ff       	call   2c <stosb>
 10a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 10d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <strchr>:

char*
strchr(const char *s, char c)
{
 112:	f3 0f 1e fb          	endbr32 
 116:	55                   	push   %ebp
 117:	89 e5                	mov    %esp,%ebp
 119:	83 ec 04             	sub    $0x4,%esp
 11c:	8b 45 0c             	mov    0xc(%ebp),%eax
 11f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 122:	eb 14                	jmp    138 <strchr+0x26>
    if(*s == c)
 124:	8b 45 08             	mov    0x8(%ebp),%eax
 127:	0f b6 00             	movzbl (%eax),%eax
 12a:	38 45 fc             	cmp    %al,-0x4(%ebp)
 12d:	75 05                	jne    134 <strchr+0x22>
      return (char*)s;
 12f:	8b 45 08             	mov    0x8(%ebp),%eax
 132:	eb 13                	jmp    147 <strchr+0x35>
  for(; *s; s++)
 134:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 138:	8b 45 08             	mov    0x8(%ebp),%eax
 13b:	0f b6 00             	movzbl (%eax),%eax
 13e:	84 c0                	test   %al,%al
 140:	75 e2                	jne    124 <strchr+0x12>
  return 0;
 142:	b8 00 00 00 00       	mov    $0x0,%eax
}
 147:	c9                   	leave  
 148:	c3                   	ret    

00000149 <gets>:

char*
gets(char *buf, int max)
{
 149:	f3 0f 1e fb          	endbr32 
 14d:	55                   	push   %ebp
 14e:	89 e5                	mov    %esp,%ebp
 150:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 153:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 15a:	eb 42                	jmp    19e <gets+0x55>
    cc = read(0, &c, 1);
 15c:	83 ec 04             	sub    $0x4,%esp
 15f:	6a 01                	push   $0x1
 161:	8d 45 ef             	lea    -0x11(%ebp),%eax
 164:	50                   	push   %eax
 165:	6a 00                	push   $0x0
 167:	e8 53 01 00 00       	call   2bf <read>
 16c:	83 c4 10             	add    $0x10,%esp
 16f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 172:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 176:	7e 33                	jle    1ab <gets+0x62>
      break;
    buf[i++] = c;
 178:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17b:	8d 50 01             	lea    0x1(%eax),%edx
 17e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 181:	89 c2                	mov    %eax,%edx
 183:	8b 45 08             	mov    0x8(%ebp),%eax
 186:	01 c2                	add    %eax,%edx
 188:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 18c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 18e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 192:	3c 0a                	cmp    $0xa,%al
 194:	74 16                	je     1ac <gets+0x63>
 196:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 19a:	3c 0d                	cmp    $0xd,%al
 19c:	74 0e                	je     1ac <gets+0x63>
  for(i=0; i+1 < max; ){
 19e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a1:	83 c0 01             	add    $0x1,%eax
 1a4:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1a7:	7f b3                	jg     15c <gets+0x13>
 1a9:	eb 01                	jmp    1ac <gets+0x63>
      break;
 1ab:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1af:	8b 45 08             	mov    0x8(%ebp),%eax
 1b2:	01 d0                	add    %edx,%eax
 1b4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ba:	c9                   	leave  
 1bb:	c3                   	ret    

000001bc <stat>:

int
stat(char *n, struct stat *st)
{
 1bc:	f3 0f 1e fb          	endbr32 
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c6:	83 ec 08             	sub    $0x8,%esp
 1c9:	6a 00                	push   $0x0
 1cb:	ff 75 08             	pushl  0x8(%ebp)
 1ce:	e8 14 01 00 00       	call   2e7 <open>
 1d3:	83 c4 10             	add    $0x10,%esp
 1d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1dd:	79 07                	jns    1e6 <stat+0x2a>
    return -1;
 1df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1e4:	eb 25                	jmp    20b <stat+0x4f>
  r = fstat(fd, st);
 1e6:	83 ec 08             	sub    $0x8,%esp
 1e9:	ff 75 0c             	pushl  0xc(%ebp)
 1ec:	ff 75 f4             	pushl  -0xc(%ebp)
 1ef:	e8 0b 01 00 00       	call   2ff <fstat>
 1f4:	83 c4 10             	add    $0x10,%esp
 1f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1fa:	83 ec 0c             	sub    $0xc,%esp
 1fd:	ff 75 f4             	pushl  -0xc(%ebp)
 200:	e8 ca 00 00 00       	call   2cf <close>
 205:	83 c4 10             	add    $0x10,%esp
  return r;
 208:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 20b:	c9                   	leave  
 20c:	c3                   	ret    

0000020d <atoi>:

int
atoi(const char *s)
{
 20d:	f3 0f 1e fb          	endbr32 
 211:	55                   	push   %ebp
 212:	89 e5                	mov    %esp,%ebp
 214:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 217:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 21e:	eb 25                	jmp    245 <atoi+0x38>
    n = n*10 + *s++ - '0';
 220:	8b 55 fc             	mov    -0x4(%ebp),%edx
 223:	89 d0                	mov    %edx,%eax
 225:	c1 e0 02             	shl    $0x2,%eax
 228:	01 d0                	add    %edx,%eax
 22a:	01 c0                	add    %eax,%eax
 22c:	89 c1                	mov    %eax,%ecx
 22e:	8b 45 08             	mov    0x8(%ebp),%eax
 231:	8d 50 01             	lea    0x1(%eax),%edx
 234:	89 55 08             	mov    %edx,0x8(%ebp)
 237:	0f b6 00             	movzbl (%eax),%eax
 23a:	0f be c0             	movsbl %al,%eax
 23d:	01 c8                	add    %ecx,%eax
 23f:	83 e8 30             	sub    $0x30,%eax
 242:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 245:	8b 45 08             	mov    0x8(%ebp),%eax
 248:	0f b6 00             	movzbl (%eax),%eax
 24b:	3c 2f                	cmp    $0x2f,%al
 24d:	7e 0a                	jle    259 <atoi+0x4c>
 24f:	8b 45 08             	mov    0x8(%ebp),%eax
 252:	0f b6 00             	movzbl (%eax),%eax
 255:	3c 39                	cmp    $0x39,%al
 257:	7e c7                	jle    220 <atoi+0x13>
  return n;
 259:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 25c:	c9                   	leave  
 25d:	c3                   	ret    

0000025e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 25e:	f3 0f 1e fb          	endbr32 
 262:	55                   	push   %ebp
 263:	89 e5                	mov    %esp,%ebp
 265:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 26e:	8b 45 0c             	mov    0xc(%ebp),%eax
 271:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 274:	eb 17                	jmp    28d <memmove+0x2f>
    *dst++ = *src++;
 276:	8b 55 f8             	mov    -0x8(%ebp),%edx
 279:	8d 42 01             	lea    0x1(%edx),%eax
 27c:	89 45 f8             	mov    %eax,-0x8(%ebp)
 27f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 282:	8d 48 01             	lea    0x1(%eax),%ecx
 285:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 288:	0f b6 12             	movzbl (%edx),%edx
 28b:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 28d:	8b 45 10             	mov    0x10(%ebp),%eax
 290:	8d 50 ff             	lea    -0x1(%eax),%edx
 293:	89 55 10             	mov    %edx,0x10(%ebp)
 296:	85 c0                	test   %eax,%eax
 298:	7f dc                	jg     276 <memmove+0x18>
  return vdst;
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 29d:	c9                   	leave  
 29e:	c3                   	ret    

0000029f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 29f:	b8 01 00 00 00       	mov    $0x1,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <exit>:
SYSCALL(exit)
 2a7:	b8 02 00 00 00       	mov    $0x2,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <wait>:
SYSCALL(wait)
 2af:	b8 03 00 00 00       	mov    $0x3,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    

000002b7 <pipe>:
SYSCALL(pipe)
 2b7:	b8 04 00 00 00       	mov    $0x4,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <read>:
SYSCALL(read)
 2bf:	b8 05 00 00 00       	mov    $0x5,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret    

000002c7 <write>:
SYSCALL(write)
 2c7:	b8 10 00 00 00       	mov    $0x10,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <close>:
SYSCALL(close)
 2cf:	b8 15 00 00 00       	mov    $0x15,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <kill>:
SYSCALL(kill)
 2d7:	b8 06 00 00 00       	mov    $0x6,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <exec>:
SYSCALL(exec)
 2df:	b8 07 00 00 00       	mov    $0x7,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <open>:
SYSCALL(open)
 2e7:	b8 0f 00 00 00       	mov    $0xf,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <mknod>:
SYSCALL(mknod)
 2ef:	b8 11 00 00 00       	mov    $0x11,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <unlink>:
SYSCALL(unlink)
 2f7:	b8 12 00 00 00       	mov    $0x12,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <fstat>:
SYSCALL(fstat)
 2ff:	b8 08 00 00 00       	mov    $0x8,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <link>:
SYSCALL(link)
 307:	b8 13 00 00 00       	mov    $0x13,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <mkdir>:
SYSCALL(mkdir)
 30f:	b8 14 00 00 00       	mov    $0x14,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <chdir>:
SYSCALL(chdir)
 317:	b8 09 00 00 00       	mov    $0x9,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <dup>:
SYSCALL(dup)
 31f:	b8 0a 00 00 00       	mov    $0xa,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <getpid>:
SYSCALL(getpid)
 327:	b8 0b 00 00 00       	mov    $0xb,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <sbrk>:
SYSCALL(sbrk)
 32f:	b8 0c 00 00 00       	mov    $0xc,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <sleep>:
SYSCALL(sleep)
 337:	b8 0d 00 00 00       	mov    $0xd,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	ret    

0000033f <uptime>:
SYSCALL(uptime)
 33f:	b8 0e 00 00 00       	mov    $0xe,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <wait2>:
SYSCALL(wait2)
 347:	b8 17 00 00 00       	mov    $0x17,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <exit2>:
SYSCALL(exit2)
 34f:	b8 16 00 00 00       	mov    $0x16,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 357:	f3 0f 1e fb          	endbr32 
 35b:	55                   	push   %ebp
 35c:	89 e5                	mov    %esp,%ebp
 35e:	83 ec 18             	sub    $0x18,%esp
 361:	8b 45 0c             	mov    0xc(%ebp),%eax
 364:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 367:	83 ec 04             	sub    $0x4,%esp
 36a:	6a 01                	push   $0x1
 36c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 36f:	50                   	push   %eax
 370:	ff 75 08             	pushl  0x8(%ebp)
 373:	e8 4f ff ff ff       	call   2c7 <write>
 378:	83 c4 10             	add    $0x10,%esp
}
 37b:	90                   	nop
 37c:	c9                   	leave  
 37d:	c3                   	ret    

0000037e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 37e:	f3 0f 1e fb          	endbr32 
 382:	55                   	push   %ebp
 383:	89 e5                	mov    %esp,%ebp
 385:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 388:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 38f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 393:	74 17                	je     3ac <printint+0x2e>
 395:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 399:	79 11                	jns    3ac <printint+0x2e>
    neg = 1;
 39b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a5:	f7 d8                	neg    %eax
 3a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3aa:	eb 06                	jmp    3b2 <printint+0x34>
  } else {
    x = xx;
 3ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 3af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3bf:	ba 00 00 00 00       	mov    $0x0,%edx
 3c4:	f7 f1                	div    %ecx
 3c6:	89 d1                	mov    %edx,%ecx
 3c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3cb:	8d 50 01             	lea    0x1(%eax),%edx
 3ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3d1:	0f b6 91 54 0a 00 00 	movzbl 0xa54(%ecx),%edx
 3d8:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3df:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e2:	ba 00 00 00 00       	mov    $0x0,%edx
 3e7:	f7 f1                	div    %ecx
 3e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3f0:	75 c7                	jne    3b9 <printint+0x3b>
  if(neg)
 3f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f6:	74 2d                	je     425 <printint+0xa7>
    buf[i++] = '-';
 3f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fb:	8d 50 01             	lea    0x1(%eax),%edx
 3fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
 401:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 406:	eb 1d                	jmp    425 <printint+0xa7>
    putc(fd, buf[i]);
 408:	8d 55 dc             	lea    -0x24(%ebp),%edx
 40b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40e:	01 d0                	add    %edx,%eax
 410:	0f b6 00             	movzbl (%eax),%eax
 413:	0f be c0             	movsbl %al,%eax
 416:	83 ec 08             	sub    $0x8,%esp
 419:	50                   	push   %eax
 41a:	ff 75 08             	pushl  0x8(%ebp)
 41d:	e8 35 ff ff ff       	call   357 <putc>
 422:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 425:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 429:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 42d:	79 d9                	jns    408 <printint+0x8a>
}
 42f:	90                   	nop
 430:	90                   	nop
 431:	c9                   	leave  
 432:	c3                   	ret    

00000433 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 433:	f3 0f 1e fb          	endbr32 
 437:	55                   	push   %ebp
 438:	89 e5                	mov    %esp,%ebp
 43a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 43d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 444:	8d 45 0c             	lea    0xc(%ebp),%eax
 447:	83 c0 04             	add    $0x4,%eax
 44a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 44d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 454:	e9 59 01 00 00       	jmp    5b2 <printf+0x17f>
    c = fmt[i] & 0xff;
 459:	8b 55 0c             	mov    0xc(%ebp),%edx
 45c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 45f:	01 d0                	add    %edx,%eax
 461:	0f b6 00             	movzbl (%eax),%eax
 464:	0f be c0             	movsbl %al,%eax
 467:	25 ff 00 00 00       	and    $0xff,%eax
 46c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 46f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 473:	75 2c                	jne    4a1 <printf+0x6e>
      if(c == '%'){
 475:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 479:	75 0c                	jne    487 <printf+0x54>
        state = '%';
 47b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 482:	e9 27 01 00 00       	jmp    5ae <printf+0x17b>
      } else {
        putc(fd, c);
 487:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 48a:	0f be c0             	movsbl %al,%eax
 48d:	83 ec 08             	sub    $0x8,%esp
 490:	50                   	push   %eax
 491:	ff 75 08             	pushl  0x8(%ebp)
 494:	e8 be fe ff ff       	call   357 <putc>
 499:	83 c4 10             	add    $0x10,%esp
 49c:	e9 0d 01 00 00       	jmp    5ae <printf+0x17b>
      }
    } else if(state == '%'){
 4a1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4a5:	0f 85 03 01 00 00    	jne    5ae <printf+0x17b>
      if(c == 'd'){
 4ab:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4af:	75 1e                	jne    4cf <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4b4:	8b 00                	mov    (%eax),%eax
 4b6:	6a 01                	push   $0x1
 4b8:	6a 0a                	push   $0xa
 4ba:	50                   	push   %eax
 4bb:	ff 75 08             	pushl  0x8(%ebp)
 4be:	e8 bb fe ff ff       	call   37e <printint>
 4c3:	83 c4 10             	add    $0x10,%esp
        ap++;
 4c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ca:	e9 d8 00 00 00       	jmp    5a7 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 4cf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4d3:	74 06                	je     4db <printf+0xa8>
 4d5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4d9:	75 1e                	jne    4f9 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 4db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4de:	8b 00                	mov    (%eax),%eax
 4e0:	6a 00                	push   $0x0
 4e2:	6a 10                	push   $0x10
 4e4:	50                   	push   %eax
 4e5:	ff 75 08             	pushl  0x8(%ebp)
 4e8:	e8 91 fe ff ff       	call   37e <printint>
 4ed:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f4:	e9 ae 00 00 00       	jmp    5a7 <printf+0x174>
      } else if(c == 's'){
 4f9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4fd:	75 43                	jne    542 <printf+0x10f>
        s = (char*)*ap;
 4ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
 502:	8b 00                	mov    (%eax),%eax
 504:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 507:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 50b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 50f:	75 25                	jne    536 <printf+0x103>
          s = "(null)";
 511:	c7 45 f4 08 08 00 00 	movl   $0x808,-0xc(%ebp)
        while(*s != 0){
 518:	eb 1c                	jmp    536 <printf+0x103>
          putc(fd, *s);
 51a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51d:	0f b6 00             	movzbl (%eax),%eax
 520:	0f be c0             	movsbl %al,%eax
 523:	83 ec 08             	sub    $0x8,%esp
 526:	50                   	push   %eax
 527:	ff 75 08             	pushl  0x8(%ebp)
 52a:	e8 28 fe ff ff       	call   357 <putc>
 52f:	83 c4 10             	add    $0x10,%esp
          s++;
 532:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 536:	8b 45 f4             	mov    -0xc(%ebp),%eax
 539:	0f b6 00             	movzbl (%eax),%eax
 53c:	84 c0                	test   %al,%al
 53e:	75 da                	jne    51a <printf+0xe7>
 540:	eb 65                	jmp    5a7 <printf+0x174>
        }
      } else if(c == 'c'){
 542:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 546:	75 1d                	jne    565 <printf+0x132>
        putc(fd, *ap);
 548:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54b:	8b 00                	mov    (%eax),%eax
 54d:	0f be c0             	movsbl %al,%eax
 550:	83 ec 08             	sub    $0x8,%esp
 553:	50                   	push   %eax
 554:	ff 75 08             	pushl  0x8(%ebp)
 557:	e8 fb fd ff ff       	call   357 <putc>
 55c:	83 c4 10             	add    $0x10,%esp
        ap++;
 55f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 563:	eb 42                	jmp    5a7 <printf+0x174>
      } else if(c == '%'){
 565:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 569:	75 17                	jne    582 <printf+0x14f>
        putc(fd, c);
 56b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 56e:	0f be c0             	movsbl %al,%eax
 571:	83 ec 08             	sub    $0x8,%esp
 574:	50                   	push   %eax
 575:	ff 75 08             	pushl  0x8(%ebp)
 578:	e8 da fd ff ff       	call   357 <putc>
 57d:	83 c4 10             	add    $0x10,%esp
 580:	eb 25                	jmp    5a7 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 582:	83 ec 08             	sub    $0x8,%esp
 585:	6a 25                	push   $0x25
 587:	ff 75 08             	pushl  0x8(%ebp)
 58a:	e8 c8 fd ff ff       	call   357 <putc>
 58f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 592:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 595:	0f be c0             	movsbl %al,%eax
 598:	83 ec 08             	sub    $0x8,%esp
 59b:	50                   	push   %eax
 59c:	ff 75 08             	pushl  0x8(%ebp)
 59f:	e8 b3 fd ff ff       	call   357 <putc>
 5a4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5a7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5b2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5b8:	01 d0                	add    %edx,%eax
 5ba:	0f b6 00             	movzbl (%eax),%eax
 5bd:	84 c0                	test   %al,%al
 5bf:	0f 85 94 fe ff ff    	jne    459 <printf+0x26>
    }
  }
}
 5c5:	90                   	nop
 5c6:	90                   	nop
 5c7:	c9                   	leave  
 5c8:	c3                   	ret    

000005c9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5c9:	f3 0f 1e fb          	endbr32 
 5cd:	55                   	push   %ebp
 5ce:	89 e5                	mov    %esp,%ebp
 5d0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
 5d6:	83 e8 08             	sub    $0x8,%eax
 5d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5dc:	a1 70 0a 00 00       	mov    0xa70,%eax
 5e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5e4:	eb 24                	jmp    60a <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e9:	8b 00                	mov    (%eax),%eax
 5eb:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5ee:	72 12                	jb     602 <free+0x39>
 5f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5f6:	77 24                	ja     61c <free+0x53>
 5f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fb:	8b 00                	mov    (%eax),%eax
 5fd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 600:	72 1a                	jb     61c <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 602:	8b 45 fc             	mov    -0x4(%ebp),%eax
 605:	8b 00                	mov    (%eax),%eax
 607:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 610:	76 d4                	jbe    5e6 <free+0x1d>
 612:	8b 45 fc             	mov    -0x4(%ebp),%eax
 615:	8b 00                	mov    (%eax),%eax
 617:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 61a:	73 ca                	jae    5e6 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 61c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61f:	8b 40 04             	mov    0x4(%eax),%eax
 622:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 629:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62c:	01 c2                	add    %eax,%edx
 62e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 631:	8b 00                	mov    (%eax),%eax
 633:	39 c2                	cmp    %eax,%edx
 635:	75 24                	jne    65b <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 637:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63a:	8b 50 04             	mov    0x4(%eax),%edx
 63d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 640:	8b 00                	mov    (%eax),%eax
 642:	8b 40 04             	mov    0x4(%eax),%eax
 645:	01 c2                	add    %eax,%edx
 647:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 64d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 650:	8b 00                	mov    (%eax),%eax
 652:	8b 10                	mov    (%eax),%edx
 654:	8b 45 f8             	mov    -0x8(%ebp),%eax
 657:	89 10                	mov    %edx,(%eax)
 659:	eb 0a                	jmp    665 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 65b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65e:	8b 10                	mov    (%eax),%edx
 660:	8b 45 f8             	mov    -0x8(%ebp),%eax
 663:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 665:	8b 45 fc             	mov    -0x4(%ebp),%eax
 668:	8b 40 04             	mov    0x4(%eax),%eax
 66b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 672:	8b 45 fc             	mov    -0x4(%ebp),%eax
 675:	01 d0                	add    %edx,%eax
 677:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 67a:	75 20                	jne    69c <free+0xd3>
    p->s.size += bp->s.size;
 67c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67f:	8b 50 04             	mov    0x4(%eax),%edx
 682:	8b 45 f8             	mov    -0x8(%ebp),%eax
 685:	8b 40 04             	mov    0x4(%eax),%eax
 688:	01 c2                	add    %eax,%edx
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 690:	8b 45 f8             	mov    -0x8(%ebp),%eax
 693:	8b 10                	mov    (%eax),%edx
 695:	8b 45 fc             	mov    -0x4(%ebp),%eax
 698:	89 10                	mov    %edx,(%eax)
 69a:	eb 08                	jmp    6a4 <free+0xdb>
  } else
    p->s.ptr = bp;
 69c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6a2:	89 10                	mov    %edx,(%eax)
  freep = p;
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a7:	a3 70 0a 00 00       	mov    %eax,0xa70
}
 6ac:	90                   	nop
 6ad:	c9                   	leave  
 6ae:	c3                   	ret    

000006af <morecore>:

static Header*
morecore(uint nu)
{
 6af:	f3 0f 1e fb          	endbr32 
 6b3:	55                   	push   %ebp
 6b4:	89 e5                	mov    %esp,%ebp
 6b6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6b9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6c0:	77 07                	ja     6c9 <morecore+0x1a>
    nu = 4096;
 6c2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6c9:	8b 45 08             	mov    0x8(%ebp),%eax
 6cc:	c1 e0 03             	shl    $0x3,%eax
 6cf:	83 ec 0c             	sub    $0xc,%esp
 6d2:	50                   	push   %eax
 6d3:	e8 57 fc ff ff       	call   32f <sbrk>
 6d8:	83 c4 10             	add    $0x10,%esp
 6db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6de:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6e2:	75 07                	jne    6eb <morecore+0x3c>
    return 0;
 6e4:	b8 00 00 00 00       	mov    $0x0,%eax
 6e9:	eb 26                	jmp    711 <morecore+0x62>
  hp = (Header*)p;
 6eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f4:	8b 55 08             	mov    0x8(%ebp),%edx
 6f7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fd:	83 c0 08             	add    $0x8,%eax
 700:	83 ec 0c             	sub    $0xc,%esp
 703:	50                   	push   %eax
 704:	e8 c0 fe ff ff       	call   5c9 <free>
 709:	83 c4 10             	add    $0x10,%esp
  return freep;
 70c:	a1 70 0a 00 00       	mov    0xa70,%eax
}
 711:	c9                   	leave  
 712:	c3                   	ret    

00000713 <malloc>:

void*
malloc(uint nbytes)
{
 713:	f3 0f 1e fb          	endbr32 
 717:	55                   	push   %ebp
 718:	89 e5                	mov    %esp,%ebp
 71a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 71d:	8b 45 08             	mov    0x8(%ebp),%eax
 720:	83 c0 07             	add    $0x7,%eax
 723:	c1 e8 03             	shr    $0x3,%eax
 726:	83 c0 01             	add    $0x1,%eax
 729:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 72c:	a1 70 0a 00 00       	mov    0xa70,%eax
 731:	89 45 f0             	mov    %eax,-0x10(%ebp)
 734:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 738:	75 23                	jne    75d <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 73a:	c7 45 f0 68 0a 00 00 	movl   $0xa68,-0x10(%ebp)
 741:	8b 45 f0             	mov    -0x10(%ebp),%eax
 744:	a3 70 0a 00 00       	mov    %eax,0xa70
 749:	a1 70 0a 00 00       	mov    0xa70,%eax
 74e:	a3 68 0a 00 00       	mov    %eax,0xa68
    base.s.size = 0;
 753:	c7 05 6c 0a 00 00 00 	movl   $0x0,0xa6c
 75a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 75d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 760:	8b 00                	mov    (%eax),%eax
 762:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 765:	8b 45 f4             	mov    -0xc(%ebp),%eax
 768:	8b 40 04             	mov    0x4(%eax),%eax
 76b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 76e:	77 4d                	ja     7bd <malloc+0xaa>
      if(p->s.size == nunits)
 770:	8b 45 f4             	mov    -0xc(%ebp),%eax
 773:	8b 40 04             	mov    0x4(%eax),%eax
 776:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 779:	75 0c                	jne    787 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 77b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77e:	8b 10                	mov    (%eax),%edx
 780:	8b 45 f0             	mov    -0x10(%ebp),%eax
 783:	89 10                	mov    %edx,(%eax)
 785:	eb 26                	jmp    7ad <malloc+0x9a>
      else {
        p->s.size -= nunits;
 787:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78a:	8b 40 04             	mov    0x4(%eax),%eax
 78d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 790:	89 c2                	mov    %eax,%edx
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	8b 40 04             	mov    0x4(%eax),%eax
 79e:	c1 e0 03             	shl    $0x3,%eax
 7a1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7aa:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b0:	a3 70 0a 00 00       	mov    %eax,0xa70
      return (void*)(p + 1);
 7b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b8:	83 c0 08             	add    $0x8,%eax
 7bb:	eb 3b                	jmp    7f8 <malloc+0xe5>
    }
    if(p == freep)
 7bd:	a1 70 0a 00 00       	mov    0xa70,%eax
 7c2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7c5:	75 1e                	jne    7e5 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 7c7:	83 ec 0c             	sub    $0xc,%esp
 7ca:	ff 75 ec             	pushl  -0x14(%ebp)
 7cd:	e8 dd fe ff ff       	call   6af <morecore>
 7d2:	83 c4 10             	add    $0x10,%esp
 7d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7dc:	75 07                	jne    7e5 <malloc+0xd2>
        return 0;
 7de:	b8 00 00 00 00       	mov    $0x0,%eax
 7e3:	eb 13                	jmp    7f8 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ee:	8b 00                	mov    (%eax),%eax
 7f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7f3:	e9 6d ff ff ff       	jmp    765 <malloc+0x52>
  }
}
 7f8:	c9                   	leave  
 7f9:	c3                   	ret    
