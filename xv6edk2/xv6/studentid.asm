
_studentid:     file format elf32-i386


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
  12:	83 ec 14             	sub    $0x14,%esp
    int id = 2026;
  15:	c7 45 f4 ea 07 00 00 	movl   $0x7ea,-0xc(%ebp)
    printf(1, "My ID is %d\n", id);
  1c:	83 ec 04             	sub    $0x4,%esp
  1f:	ff 75 f4             	pushl  -0xc(%ebp)
  22:	68 04 08 00 00       	push   $0x804
  27:	6a 01                	push   $0x1
  29:	e8 0f 04 00 00       	call   43d <printf>
  2e:	83 c4 10             	add    $0x10,%esp
    exit();
  31:	e8 7b 02 00 00       	call   2b1 <exit>

00000036 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  36:	55                   	push   %ebp
  37:	89 e5                	mov    %esp,%ebp
  39:	57                   	push   %edi
  3a:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  3e:	8b 55 10             	mov    0x10(%ebp),%edx
  41:	8b 45 0c             	mov    0xc(%ebp),%eax
  44:	89 cb                	mov    %ecx,%ebx
  46:	89 df                	mov    %ebx,%edi
  48:	89 d1                	mov    %edx,%ecx
  4a:	fc                   	cld    
  4b:	f3 aa                	rep stos %al,%es:(%edi)
  4d:	89 ca                	mov    %ecx,%edx
  4f:	89 fb                	mov    %edi,%ebx
  51:	89 5d 08             	mov    %ebx,0x8(%ebp)
  54:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  57:	90                   	nop
  58:	5b                   	pop    %ebx
  59:	5f                   	pop    %edi
  5a:	5d                   	pop    %ebp
  5b:	c3                   	ret    

0000005c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  5c:	f3 0f 1e fb          	endbr32 
  60:	55                   	push   %ebp
  61:	89 e5                	mov    %esp,%ebp
  63:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  66:	8b 45 08             	mov    0x8(%ebp),%eax
  69:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  6c:	90                   	nop
  6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  70:	8d 42 01             	lea    0x1(%edx),%eax
  73:	89 45 0c             	mov    %eax,0xc(%ebp)
  76:	8b 45 08             	mov    0x8(%ebp),%eax
  79:	8d 48 01             	lea    0x1(%eax),%ecx
  7c:	89 4d 08             	mov    %ecx,0x8(%ebp)
  7f:	0f b6 12             	movzbl (%edx),%edx
  82:	88 10                	mov    %dl,(%eax)
  84:	0f b6 00             	movzbl (%eax),%eax
  87:	84 c0                	test   %al,%al
  89:	75 e2                	jne    6d <strcpy+0x11>
    ;
  return os;
  8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8e:	c9                   	leave  
  8f:	c3                   	ret    

00000090 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  90:	f3 0f 1e fb          	endbr32 
  94:	55                   	push   %ebp
  95:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  97:	eb 08                	jmp    a1 <strcmp+0x11>
    p++, q++;
  99:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  9d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  a1:	8b 45 08             	mov    0x8(%ebp),%eax
  a4:	0f b6 00             	movzbl (%eax),%eax
  a7:	84 c0                	test   %al,%al
  a9:	74 10                	je     bb <strcmp+0x2b>
  ab:	8b 45 08             	mov    0x8(%ebp),%eax
  ae:	0f b6 10             	movzbl (%eax),%edx
  b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  b4:	0f b6 00             	movzbl (%eax),%eax
  b7:	38 c2                	cmp    %al,%dl
  b9:	74 de                	je     99 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  bb:	8b 45 08             	mov    0x8(%ebp),%eax
  be:	0f b6 00             	movzbl (%eax),%eax
  c1:	0f b6 d0             	movzbl %al,%edx
  c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  c7:	0f b6 00             	movzbl (%eax),%eax
  ca:	0f b6 c0             	movzbl %al,%eax
  cd:	29 c2                	sub    %eax,%edx
  cf:	89 d0                	mov    %edx,%eax
}
  d1:	5d                   	pop    %ebp
  d2:	c3                   	ret    

000000d3 <strlen>:

uint
strlen(char *s)
{
  d3:	f3 0f 1e fb          	endbr32 
  d7:	55                   	push   %ebp
  d8:	89 e5                	mov    %esp,%ebp
  da:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  e4:	eb 04                	jmp    ea <strlen+0x17>
  e6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
  ed:	8b 45 08             	mov    0x8(%ebp),%eax
  f0:	01 d0                	add    %edx,%eax
  f2:	0f b6 00             	movzbl (%eax),%eax
  f5:	84 c0                	test   %al,%al
  f7:	75 ed                	jne    e6 <strlen+0x13>
    ;
  return n;
  f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  fc:	c9                   	leave  
  fd:	c3                   	ret    

000000fe <memset>:

void*
memset(void *dst, int c, uint n)
{
  fe:	f3 0f 1e fb          	endbr32 
 102:	55                   	push   %ebp
 103:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 105:	8b 45 10             	mov    0x10(%ebp),%eax
 108:	50                   	push   %eax
 109:	ff 75 0c             	pushl  0xc(%ebp)
 10c:	ff 75 08             	pushl  0x8(%ebp)
 10f:	e8 22 ff ff ff       	call   36 <stosb>
 114:	83 c4 0c             	add    $0xc,%esp
  return dst;
 117:	8b 45 08             	mov    0x8(%ebp),%eax
}
 11a:	c9                   	leave  
 11b:	c3                   	ret    

0000011c <strchr>:

char*
strchr(const char *s, char c)
{
 11c:	f3 0f 1e fb          	endbr32 
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	83 ec 04             	sub    $0x4,%esp
 126:	8b 45 0c             	mov    0xc(%ebp),%eax
 129:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 12c:	eb 14                	jmp    142 <strchr+0x26>
    if(*s == c)
 12e:	8b 45 08             	mov    0x8(%ebp),%eax
 131:	0f b6 00             	movzbl (%eax),%eax
 134:	38 45 fc             	cmp    %al,-0x4(%ebp)
 137:	75 05                	jne    13e <strchr+0x22>
      return (char*)s;
 139:	8b 45 08             	mov    0x8(%ebp),%eax
 13c:	eb 13                	jmp    151 <strchr+0x35>
  for(; *s; s++)
 13e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 142:	8b 45 08             	mov    0x8(%ebp),%eax
 145:	0f b6 00             	movzbl (%eax),%eax
 148:	84 c0                	test   %al,%al
 14a:	75 e2                	jne    12e <strchr+0x12>
  return 0;
 14c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 151:	c9                   	leave  
 152:	c3                   	ret    

00000153 <gets>:

char*
gets(char *buf, int max)
{
 153:	f3 0f 1e fb          	endbr32 
 157:	55                   	push   %ebp
 158:	89 e5                	mov    %esp,%ebp
 15a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 164:	eb 42                	jmp    1a8 <gets+0x55>
    cc = read(0, &c, 1);
 166:	83 ec 04             	sub    $0x4,%esp
 169:	6a 01                	push   $0x1
 16b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 16e:	50                   	push   %eax
 16f:	6a 00                	push   $0x0
 171:	e8 53 01 00 00       	call   2c9 <read>
 176:	83 c4 10             	add    $0x10,%esp
 179:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 17c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 180:	7e 33                	jle    1b5 <gets+0x62>
      break;
    buf[i++] = c;
 182:	8b 45 f4             	mov    -0xc(%ebp),%eax
 185:	8d 50 01             	lea    0x1(%eax),%edx
 188:	89 55 f4             	mov    %edx,-0xc(%ebp)
 18b:	89 c2                	mov    %eax,%edx
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
 190:	01 c2                	add    %eax,%edx
 192:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 196:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 198:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 19c:	3c 0a                	cmp    $0xa,%al
 19e:	74 16                	je     1b6 <gets+0x63>
 1a0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a4:	3c 0d                	cmp    $0xd,%al
 1a6:	74 0e                	je     1b6 <gets+0x63>
  for(i=0; i+1 < max; ){
 1a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ab:	83 c0 01             	add    $0x1,%eax
 1ae:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1b1:	7f b3                	jg     166 <gets+0x13>
 1b3:	eb 01                	jmp    1b6 <gets+0x63>
      break;
 1b5:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1b9:	8b 45 08             	mov    0x8(%ebp),%eax
 1bc:	01 d0                	add    %edx,%eax
 1be:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c4:	c9                   	leave  
 1c5:	c3                   	ret    

000001c6 <stat>:

int
stat(char *n, struct stat *st)
{
 1c6:	f3 0f 1e fb          	endbr32 
 1ca:	55                   	push   %ebp
 1cb:	89 e5                	mov    %esp,%ebp
 1cd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d0:	83 ec 08             	sub    $0x8,%esp
 1d3:	6a 00                	push   $0x0
 1d5:	ff 75 08             	pushl  0x8(%ebp)
 1d8:	e8 14 01 00 00       	call   2f1 <open>
 1dd:	83 c4 10             	add    $0x10,%esp
 1e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1e7:	79 07                	jns    1f0 <stat+0x2a>
    return -1;
 1e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1ee:	eb 25                	jmp    215 <stat+0x4f>
  r = fstat(fd, st);
 1f0:	83 ec 08             	sub    $0x8,%esp
 1f3:	ff 75 0c             	pushl  0xc(%ebp)
 1f6:	ff 75 f4             	pushl  -0xc(%ebp)
 1f9:	e8 0b 01 00 00       	call   309 <fstat>
 1fe:	83 c4 10             	add    $0x10,%esp
 201:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 204:	83 ec 0c             	sub    $0xc,%esp
 207:	ff 75 f4             	pushl  -0xc(%ebp)
 20a:	e8 ca 00 00 00       	call   2d9 <close>
 20f:	83 c4 10             	add    $0x10,%esp
  return r;
 212:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 215:	c9                   	leave  
 216:	c3                   	ret    

00000217 <atoi>:

int
atoi(const char *s)
{
 217:	f3 0f 1e fb          	endbr32 
 21b:	55                   	push   %ebp
 21c:	89 e5                	mov    %esp,%ebp
 21e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 221:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 228:	eb 25                	jmp    24f <atoi+0x38>
    n = n*10 + *s++ - '0';
 22a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 22d:	89 d0                	mov    %edx,%eax
 22f:	c1 e0 02             	shl    $0x2,%eax
 232:	01 d0                	add    %edx,%eax
 234:	01 c0                	add    %eax,%eax
 236:	89 c1                	mov    %eax,%ecx
 238:	8b 45 08             	mov    0x8(%ebp),%eax
 23b:	8d 50 01             	lea    0x1(%eax),%edx
 23e:	89 55 08             	mov    %edx,0x8(%ebp)
 241:	0f b6 00             	movzbl (%eax),%eax
 244:	0f be c0             	movsbl %al,%eax
 247:	01 c8                	add    %ecx,%eax
 249:	83 e8 30             	sub    $0x30,%eax
 24c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 24f:	8b 45 08             	mov    0x8(%ebp),%eax
 252:	0f b6 00             	movzbl (%eax),%eax
 255:	3c 2f                	cmp    $0x2f,%al
 257:	7e 0a                	jle    263 <atoi+0x4c>
 259:	8b 45 08             	mov    0x8(%ebp),%eax
 25c:	0f b6 00             	movzbl (%eax),%eax
 25f:	3c 39                	cmp    $0x39,%al
 261:	7e c7                	jle    22a <atoi+0x13>
  return n;
 263:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 266:	c9                   	leave  
 267:	c3                   	ret    

00000268 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 268:	f3 0f 1e fb          	endbr32 
 26c:	55                   	push   %ebp
 26d:	89 e5                	mov    %esp,%ebp
 26f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 278:	8b 45 0c             	mov    0xc(%ebp),%eax
 27b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 27e:	eb 17                	jmp    297 <memmove+0x2f>
    *dst++ = *src++;
 280:	8b 55 f8             	mov    -0x8(%ebp),%edx
 283:	8d 42 01             	lea    0x1(%edx),%eax
 286:	89 45 f8             	mov    %eax,-0x8(%ebp)
 289:	8b 45 fc             	mov    -0x4(%ebp),%eax
 28c:	8d 48 01             	lea    0x1(%eax),%ecx
 28f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 292:	0f b6 12             	movzbl (%edx),%edx
 295:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 297:	8b 45 10             	mov    0x10(%ebp),%eax
 29a:	8d 50 ff             	lea    -0x1(%eax),%edx
 29d:	89 55 10             	mov    %edx,0x10(%ebp)
 2a0:	85 c0                	test   %eax,%eax
 2a2:	7f dc                	jg     280 <memmove+0x18>
  return vdst;
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a7:	c9                   	leave  
 2a8:	c3                   	ret    

000002a9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2a9:	b8 01 00 00 00       	mov    $0x1,%eax
 2ae:	cd 40                	int    $0x40
 2b0:	c3                   	ret    

000002b1 <exit>:
SYSCALL(exit)
 2b1:	b8 02 00 00 00       	mov    $0x2,%eax
 2b6:	cd 40                	int    $0x40
 2b8:	c3                   	ret    

000002b9 <wait>:
SYSCALL(wait)
 2b9:	b8 03 00 00 00       	mov    $0x3,%eax
 2be:	cd 40                	int    $0x40
 2c0:	c3                   	ret    

000002c1 <pipe>:
SYSCALL(pipe)
 2c1:	b8 04 00 00 00       	mov    $0x4,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret    

000002c9 <read>:
SYSCALL(read)
 2c9:	b8 05 00 00 00       	mov    $0x5,%eax
 2ce:	cd 40                	int    $0x40
 2d0:	c3                   	ret    

000002d1 <write>:
SYSCALL(write)
 2d1:	b8 10 00 00 00       	mov    $0x10,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret    

000002d9 <close>:
SYSCALL(close)
 2d9:	b8 15 00 00 00       	mov    $0x15,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <kill>:
SYSCALL(kill)
 2e1:	b8 06 00 00 00       	mov    $0x6,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <exec>:
SYSCALL(exec)
 2e9:	b8 07 00 00 00       	mov    $0x7,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <open>:
SYSCALL(open)
 2f1:	b8 0f 00 00 00       	mov    $0xf,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <mknod>:
SYSCALL(mknod)
 2f9:	b8 11 00 00 00       	mov    $0x11,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <unlink>:
SYSCALL(unlink)
 301:	b8 12 00 00 00       	mov    $0x12,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <fstat>:
SYSCALL(fstat)
 309:	b8 08 00 00 00       	mov    $0x8,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <link>:
SYSCALL(link)
 311:	b8 13 00 00 00       	mov    $0x13,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <mkdir>:
SYSCALL(mkdir)
 319:	b8 14 00 00 00       	mov    $0x14,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <chdir>:
SYSCALL(chdir)
 321:	b8 09 00 00 00       	mov    $0x9,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <dup>:
SYSCALL(dup)
 329:	b8 0a 00 00 00       	mov    $0xa,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <getpid>:
SYSCALL(getpid)
 331:	b8 0b 00 00 00       	mov    $0xb,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <sbrk>:
SYSCALL(sbrk)
 339:	b8 0c 00 00 00       	mov    $0xc,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <sleep>:
SYSCALL(sleep)
 341:	b8 0d 00 00 00       	mov    $0xd,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <uptime>:
SYSCALL(uptime)
 349:	b8 0e 00 00 00       	mov    $0xe,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <wait2>:
SYSCALL(wait2)
 351:	b8 17 00 00 00       	mov    $0x17,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <exit2>:
SYSCALL(exit2)
 359:	b8 16 00 00 00       	mov    $0x16,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 361:	f3 0f 1e fb          	endbr32 
 365:	55                   	push   %ebp
 366:	89 e5                	mov    %esp,%ebp
 368:	83 ec 18             	sub    $0x18,%esp
 36b:	8b 45 0c             	mov    0xc(%ebp),%eax
 36e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 371:	83 ec 04             	sub    $0x4,%esp
 374:	6a 01                	push   $0x1
 376:	8d 45 f4             	lea    -0xc(%ebp),%eax
 379:	50                   	push   %eax
 37a:	ff 75 08             	pushl  0x8(%ebp)
 37d:	e8 4f ff ff ff       	call   2d1 <write>
 382:	83 c4 10             	add    $0x10,%esp
}
 385:	90                   	nop
 386:	c9                   	leave  
 387:	c3                   	ret    

00000388 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 388:	f3 0f 1e fb          	endbr32 
 38c:	55                   	push   %ebp
 38d:	89 e5                	mov    %esp,%ebp
 38f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 392:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 399:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 39d:	74 17                	je     3b6 <printint+0x2e>
 39f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3a3:	79 11                	jns    3b6 <printint+0x2e>
    neg = 1;
 3a5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 3af:	f7 d8                	neg    %eax
 3b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b4:	eb 06                	jmp    3bc <printint+0x34>
  } else {
    x = xx;
 3b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3c9:	ba 00 00 00 00       	mov    $0x0,%edx
 3ce:	f7 f1                	div    %ecx
 3d0:	89 d1                	mov    %edx,%ecx
 3d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d5:	8d 50 01             	lea    0x1(%eax),%edx
 3d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3db:	0f b6 91 5c 0a 00 00 	movzbl 0xa5c(%ecx),%edx
 3e2:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ec:	ba 00 00 00 00       	mov    $0x0,%edx
 3f1:	f7 f1                	div    %ecx
 3f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3f6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3fa:	75 c7                	jne    3c3 <printint+0x3b>
  if(neg)
 3fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 400:	74 2d                	je     42f <printint+0xa7>
    buf[i++] = '-';
 402:	8b 45 f4             	mov    -0xc(%ebp),%eax
 405:	8d 50 01             	lea    0x1(%eax),%edx
 408:	89 55 f4             	mov    %edx,-0xc(%ebp)
 40b:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 410:	eb 1d                	jmp    42f <printint+0xa7>
    putc(fd, buf[i]);
 412:	8d 55 dc             	lea    -0x24(%ebp),%edx
 415:	8b 45 f4             	mov    -0xc(%ebp),%eax
 418:	01 d0                	add    %edx,%eax
 41a:	0f b6 00             	movzbl (%eax),%eax
 41d:	0f be c0             	movsbl %al,%eax
 420:	83 ec 08             	sub    $0x8,%esp
 423:	50                   	push   %eax
 424:	ff 75 08             	pushl  0x8(%ebp)
 427:	e8 35 ff ff ff       	call   361 <putc>
 42c:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 42f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 433:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 437:	79 d9                	jns    412 <printint+0x8a>
}
 439:	90                   	nop
 43a:	90                   	nop
 43b:	c9                   	leave  
 43c:	c3                   	ret    

0000043d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 43d:	f3 0f 1e fb          	endbr32 
 441:	55                   	push   %ebp
 442:	89 e5                	mov    %esp,%ebp
 444:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 447:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 44e:	8d 45 0c             	lea    0xc(%ebp),%eax
 451:	83 c0 04             	add    $0x4,%eax
 454:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 457:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 45e:	e9 59 01 00 00       	jmp    5bc <printf+0x17f>
    c = fmt[i] & 0xff;
 463:	8b 55 0c             	mov    0xc(%ebp),%edx
 466:	8b 45 f0             	mov    -0x10(%ebp),%eax
 469:	01 d0                	add    %edx,%eax
 46b:	0f b6 00             	movzbl (%eax),%eax
 46e:	0f be c0             	movsbl %al,%eax
 471:	25 ff 00 00 00       	and    $0xff,%eax
 476:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 479:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 47d:	75 2c                	jne    4ab <printf+0x6e>
      if(c == '%'){
 47f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 483:	75 0c                	jne    491 <printf+0x54>
        state = '%';
 485:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 48c:	e9 27 01 00 00       	jmp    5b8 <printf+0x17b>
      } else {
        putc(fd, c);
 491:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 494:	0f be c0             	movsbl %al,%eax
 497:	83 ec 08             	sub    $0x8,%esp
 49a:	50                   	push   %eax
 49b:	ff 75 08             	pushl  0x8(%ebp)
 49e:	e8 be fe ff ff       	call   361 <putc>
 4a3:	83 c4 10             	add    $0x10,%esp
 4a6:	e9 0d 01 00 00       	jmp    5b8 <printf+0x17b>
      }
    } else if(state == '%'){
 4ab:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4af:	0f 85 03 01 00 00    	jne    5b8 <printf+0x17b>
      if(c == 'd'){
 4b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4b9:	75 1e                	jne    4d9 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4be:	8b 00                	mov    (%eax),%eax
 4c0:	6a 01                	push   $0x1
 4c2:	6a 0a                	push   $0xa
 4c4:	50                   	push   %eax
 4c5:	ff 75 08             	pushl  0x8(%ebp)
 4c8:	e8 bb fe ff ff       	call   388 <printint>
 4cd:	83 c4 10             	add    $0x10,%esp
        ap++;
 4d0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d4:	e9 d8 00 00 00       	jmp    5b1 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 4d9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4dd:	74 06                	je     4e5 <printf+0xa8>
 4df:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4e3:	75 1e                	jne    503 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 4e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e8:	8b 00                	mov    (%eax),%eax
 4ea:	6a 00                	push   $0x0
 4ec:	6a 10                	push   $0x10
 4ee:	50                   	push   %eax
 4ef:	ff 75 08             	pushl  0x8(%ebp)
 4f2:	e8 91 fe ff ff       	call   388 <printint>
 4f7:	83 c4 10             	add    $0x10,%esp
        ap++;
 4fa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4fe:	e9 ae 00 00 00       	jmp    5b1 <printf+0x174>
      } else if(c == 's'){
 503:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 507:	75 43                	jne    54c <printf+0x10f>
        s = (char*)*ap;
 509:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50c:	8b 00                	mov    (%eax),%eax
 50e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 511:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 515:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 519:	75 25                	jne    540 <printf+0x103>
          s = "(null)";
 51b:	c7 45 f4 11 08 00 00 	movl   $0x811,-0xc(%ebp)
        while(*s != 0){
 522:	eb 1c                	jmp    540 <printf+0x103>
          putc(fd, *s);
 524:	8b 45 f4             	mov    -0xc(%ebp),%eax
 527:	0f b6 00             	movzbl (%eax),%eax
 52a:	0f be c0             	movsbl %al,%eax
 52d:	83 ec 08             	sub    $0x8,%esp
 530:	50                   	push   %eax
 531:	ff 75 08             	pushl  0x8(%ebp)
 534:	e8 28 fe ff ff       	call   361 <putc>
 539:	83 c4 10             	add    $0x10,%esp
          s++;
 53c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 540:	8b 45 f4             	mov    -0xc(%ebp),%eax
 543:	0f b6 00             	movzbl (%eax),%eax
 546:	84 c0                	test   %al,%al
 548:	75 da                	jne    524 <printf+0xe7>
 54a:	eb 65                	jmp    5b1 <printf+0x174>
        }
      } else if(c == 'c'){
 54c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 550:	75 1d                	jne    56f <printf+0x132>
        putc(fd, *ap);
 552:	8b 45 e8             	mov    -0x18(%ebp),%eax
 555:	8b 00                	mov    (%eax),%eax
 557:	0f be c0             	movsbl %al,%eax
 55a:	83 ec 08             	sub    $0x8,%esp
 55d:	50                   	push   %eax
 55e:	ff 75 08             	pushl  0x8(%ebp)
 561:	e8 fb fd ff ff       	call   361 <putc>
 566:	83 c4 10             	add    $0x10,%esp
        ap++;
 569:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56d:	eb 42                	jmp    5b1 <printf+0x174>
      } else if(c == '%'){
 56f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 573:	75 17                	jne    58c <printf+0x14f>
        putc(fd, c);
 575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 578:	0f be c0             	movsbl %al,%eax
 57b:	83 ec 08             	sub    $0x8,%esp
 57e:	50                   	push   %eax
 57f:	ff 75 08             	pushl  0x8(%ebp)
 582:	e8 da fd ff ff       	call   361 <putc>
 587:	83 c4 10             	add    $0x10,%esp
 58a:	eb 25                	jmp    5b1 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 58c:	83 ec 08             	sub    $0x8,%esp
 58f:	6a 25                	push   $0x25
 591:	ff 75 08             	pushl  0x8(%ebp)
 594:	e8 c8 fd ff ff       	call   361 <putc>
 599:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 59c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59f:	0f be c0             	movsbl %al,%eax
 5a2:	83 ec 08             	sub    $0x8,%esp
 5a5:	50                   	push   %eax
 5a6:	ff 75 08             	pushl  0x8(%ebp)
 5a9:	e8 b3 fd ff ff       	call   361 <putc>
 5ae:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5b1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5b8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5bc:	8b 55 0c             	mov    0xc(%ebp),%edx
 5bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5c2:	01 d0                	add    %edx,%eax
 5c4:	0f b6 00             	movzbl (%eax),%eax
 5c7:	84 c0                	test   %al,%al
 5c9:	0f 85 94 fe ff ff    	jne    463 <printf+0x26>
    }
  }
}
 5cf:	90                   	nop
 5d0:	90                   	nop
 5d1:	c9                   	leave  
 5d2:	c3                   	ret    

000005d3 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5d3:	f3 0f 1e fb          	endbr32 
 5d7:	55                   	push   %ebp
 5d8:	89 e5                	mov    %esp,%ebp
 5da:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5dd:	8b 45 08             	mov    0x8(%ebp),%eax
 5e0:	83 e8 08             	sub    $0x8,%eax
 5e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e6:	a1 78 0a 00 00       	mov    0xa78,%eax
 5eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5ee:	eb 24                	jmp    614 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f3:	8b 00                	mov    (%eax),%eax
 5f5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5f8:	72 12                	jb     60c <free+0x39>
 5fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 600:	77 24                	ja     626 <free+0x53>
 602:	8b 45 fc             	mov    -0x4(%ebp),%eax
 605:	8b 00                	mov    (%eax),%eax
 607:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 60a:	72 1a                	jb     626 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60f:	8b 00                	mov    (%eax),%eax
 611:	89 45 fc             	mov    %eax,-0x4(%ebp)
 614:	8b 45 f8             	mov    -0x8(%ebp),%eax
 617:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61a:	76 d4                	jbe    5f0 <free+0x1d>
 61c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61f:	8b 00                	mov    (%eax),%eax
 621:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 624:	73 ca                	jae    5f0 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 626:	8b 45 f8             	mov    -0x8(%ebp),%eax
 629:	8b 40 04             	mov    0x4(%eax),%eax
 62c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 633:	8b 45 f8             	mov    -0x8(%ebp),%eax
 636:	01 c2                	add    %eax,%edx
 638:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63b:	8b 00                	mov    (%eax),%eax
 63d:	39 c2                	cmp    %eax,%edx
 63f:	75 24                	jne    665 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 641:	8b 45 f8             	mov    -0x8(%ebp),%eax
 644:	8b 50 04             	mov    0x4(%eax),%edx
 647:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64a:	8b 00                	mov    (%eax),%eax
 64c:	8b 40 04             	mov    0x4(%eax),%eax
 64f:	01 c2                	add    %eax,%edx
 651:	8b 45 f8             	mov    -0x8(%ebp),%eax
 654:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 657:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65a:	8b 00                	mov    (%eax),%eax
 65c:	8b 10                	mov    (%eax),%edx
 65e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 661:	89 10                	mov    %edx,(%eax)
 663:	eb 0a                	jmp    66f <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 665:	8b 45 fc             	mov    -0x4(%ebp),%eax
 668:	8b 10                	mov    (%eax),%edx
 66a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 66f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 672:	8b 40 04             	mov    0x4(%eax),%eax
 675:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 67c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67f:	01 d0                	add    %edx,%eax
 681:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 684:	75 20                	jne    6a6 <free+0xd3>
    p->s.size += bp->s.size;
 686:	8b 45 fc             	mov    -0x4(%ebp),%eax
 689:	8b 50 04             	mov    0x4(%eax),%edx
 68c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68f:	8b 40 04             	mov    0x4(%eax),%eax
 692:	01 c2                	add    %eax,%edx
 694:	8b 45 fc             	mov    -0x4(%ebp),%eax
 697:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 69a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69d:	8b 10                	mov    (%eax),%edx
 69f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a2:	89 10                	mov    %edx,(%eax)
 6a4:	eb 08                	jmp    6ae <free+0xdb>
  } else
    p->s.ptr = bp;
 6a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ac:	89 10                	mov    %edx,(%eax)
  freep = p;
 6ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b1:	a3 78 0a 00 00       	mov    %eax,0xa78
}
 6b6:	90                   	nop
 6b7:	c9                   	leave  
 6b8:	c3                   	ret    

000006b9 <morecore>:

static Header*
morecore(uint nu)
{
 6b9:	f3 0f 1e fb          	endbr32 
 6bd:	55                   	push   %ebp
 6be:	89 e5                	mov    %esp,%ebp
 6c0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6c3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6ca:	77 07                	ja     6d3 <morecore+0x1a>
    nu = 4096;
 6cc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6d3:	8b 45 08             	mov    0x8(%ebp),%eax
 6d6:	c1 e0 03             	shl    $0x3,%eax
 6d9:	83 ec 0c             	sub    $0xc,%esp
 6dc:	50                   	push   %eax
 6dd:	e8 57 fc ff ff       	call   339 <sbrk>
 6e2:	83 c4 10             	add    $0x10,%esp
 6e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6e8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ec:	75 07                	jne    6f5 <morecore+0x3c>
    return 0;
 6ee:	b8 00 00 00 00       	mov    $0x0,%eax
 6f3:	eb 26                	jmp    71b <morecore+0x62>
  hp = (Header*)p;
 6f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fe:	8b 55 08             	mov    0x8(%ebp),%edx
 701:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 704:	8b 45 f0             	mov    -0x10(%ebp),%eax
 707:	83 c0 08             	add    $0x8,%eax
 70a:	83 ec 0c             	sub    $0xc,%esp
 70d:	50                   	push   %eax
 70e:	e8 c0 fe ff ff       	call   5d3 <free>
 713:	83 c4 10             	add    $0x10,%esp
  return freep;
 716:	a1 78 0a 00 00       	mov    0xa78,%eax
}
 71b:	c9                   	leave  
 71c:	c3                   	ret    

0000071d <malloc>:

void*
malloc(uint nbytes)
{
 71d:	f3 0f 1e fb          	endbr32 
 721:	55                   	push   %ebp
 722:	89 e5                	mov    %esp,%ebp
 724:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 727:	8b 45 08             	mov    0x8(%ebp),%eax
 72a:	83 c0 07             	add    $0x7,%eax
 72d:	c1 e8 03             	shr    $0x3,%eax
 730:	83 c0 01             	add    $0x1,%eax
 733:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 736:	a1 78 0a 00 00       	mov    0xa78,%eax
 73b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 73e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 742:	75 23                	jne    767 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 744:	c7 45 f0 70 0a 00 00 	movl   $0xa70,-0x10(%ebp)
 74b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74e:	a3 78 0a 00 00       	mov    %eax,0xa78
 753:	a1 78 0a 00 00       	mov    0xa78,%eax
 758:	a3 70 0a 00 00       	mov    %eax,0xa70
    base.s.size = 0;
 75d:	c7 05 74 0a 00 00 00 	movl   $0x0,0xa74
 764:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 767:	8b 45 f0             	mov    -0x10(%ebp),%eax
 76a:	8b 00                	mov    (%eax),%eax
 76c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 76f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 772:	8b 40 04             	mov    0x4(%eax),%eax
 775:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 778:	77 4d                	ja     7c7 <malloc+0xaa>
      if(p->s.size == nunits)
 77a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77d:	8b 40 04             	mov    0x4(%eax),%eax
 780:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 783:	75 0c                	jne    791 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 785:	8b 45 f4             	mov    -0xc(%ebp),%eax
 788:	8b 10                	mov    (%eax),%edx
 78a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78d:	89 10                	mov    %edx,(%eax)
 78f:	eb 26                	jmp    7b7 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 791:	8b 45 f4             	mov    -0xc(%ebp),%eax
 794:	8b 40 04             	mov    0x4(%eax),%eax
 797:	2b 45 ec             	sub    -0x14(%ebp),%eax
 79a:	89 c2                	mov    %eax,%edx
 79c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a5:	8b 40 04             	mov    0x4(%eax),%eax
 7a8:	c1 e0 03             	shl    $0x3,%eax
 7ab:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7b4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ba:	a3 78 0a 00 00       	mov    %eax,0xa78
      return (void*)(p + 1);
 7bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c2:	83 c0 08             	add    $0x8,%eax
 7c5:	eb 3b                	jmp    802 <malloc+0xe5>
    }
    if(p == freep)
 7c7:	a1 78 0a 00 00       	mov    0xa78,%eax
 7cc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7cf:	75 1e                	jne    7ef <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 7d1:	83 ec 0c             	sub    $0xc,%esp
 7d4:	ff 75 ec             	pushl  -0x14(%ebp)
 7d7:	e8 dd fe ff ff       	call   6b9 <morecore>
 7dc:	83 c4 10             	add    $0x10,%esp
 7df:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e6:	75 07                	jne    7ef <malloc+0xd2>
        return 0;
 7e8:	b8 00 00 00 00       	mov    $0x0,%eax
 7ed:	eb 13                	jmp    802 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7fd:	e9 6d ff ff ff       	jmp    76f <malloc+0x52>
  }
}
 802:	c9                   	leave  
 803:	c3                   	ret    
