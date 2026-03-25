
_ln:     file format elf32-i386


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
  13:	89 cb                	mov    %ecx,%ebx
  if(argc != 3){
  15:	83 3b 03             	cmpl   $0x3,(%ebx)
  18:	74 17                	je     31 <main+0x31>
    printf(2, "Usage: ln old new\n");
  1a:	83 ec 08             	sub    $0x8,%esp
  1d:	68 36 08 00 00       	push   $0x836
  22:	6a 02                	push   $0x2
  24:	e8 46 04 00 00       	call   46f <printf>
  29:	83 c4 10             	add    $0x10,%esp
    exit();
  2c:	e8 c2 02 00 00       	call   2f3 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  31:	8b 43 04             	mov    0x4(%ebx),%eax
  34:	83 c0 08             	add    $0x8,%eax
  37:	8b 10                	mov    (%eax),%edx
  39:	8b 43 04             	mov    0x4(%ebx),%eax
  3c:	83 c0 04             	add    $0x4,%eax
  3f:	8b 00                	mov    (%eax),%eax
  41:	83 ec 08             	sub    $0x8,%esp
  44:	52                   	push   %edx
  45:	50                   	push   %eax
  46:	e8 08 03 00 00       	call   353 <link>
  4b:	83 c4 10             	add    $0x10,%esp
  4e:	85 c0                	test   %eax,%eax
  50:	79 21                	jns    73 <main+0x73>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  52:	8b 43 04             	mov    0x4(%ebx),%eax
  55:	83 c0 08             	add    $0x8,%eax
  58:	8b 10                	mov    (%eax),%edx
  5a:	8b 43 04             	mov    0x4(%ebx),%eax
  5d:	83 c0 04             	add    $0x4,%eax
  60:	8b 00                	mov    (%eax),%eax
  62:	52                   	push   %edx
  63:	50                   	push   %eax
  64:	68 49 08 00 00       	push   $0x849
  69:	6a 02                	push   $0x2
  6b:	e8 ff 03 00 00       	call   46f <printf>
  70:	83 c4 10             	add    $0x10,%esp
  exit();
  73:	e8 7b 02 00 00       	call   2f3 <exit>

00000078 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  78:	55                   	push   %ebp
  79:	89 e5                	mov    %esp,%ebp
  7b:	57                   	push   %edi
  7c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80:	8b 55 10             	mov    0x10(%ebp),%edx
  83:	8b 45 0c             	mov    0xc(%ebp),%eax
  86:	89 cb                	mov    %ecx,%ebx
  88:	89 df                	mov    %ebx,%edi
  8a:	89 d1                	mov    %edx,%ecx
  8c:	fc                   	cld    
  8d:	f3 aa                	rep stos %al,%es:(%edi)
  8f:	89 ca                	mov    %ecx,%edx
  91:	89 fb                	mov    %edi,%ebx
  93:	89 5d 08             	mov    %ebx,0x8(%ebp)
  96:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  99:	90                   	nop
  9a:	5b                   	pop    %ebx
  9b:	5f                   	pop    %edi
  9c:	5d                   	pop    %ebp
  9d:	c3                   	ret    

0000009e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  9e:	f3 0f 1e fb          	endbr32 
  a2:	55                   	push   %ebp
  a3:	89 e5                	mov    %esp,%ebp
  a5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a8:	8b 45 08             	mov    0x8(%ebp),%eax
  ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ae:	90                   	nop
  af:	8b 55 0c             	mov    0xc(%ebp),%edx
  b2:	8d 42 01             	lea    0x1(%edx),%eax
  b5:	89 45 0c             	mov    %eax,0xc(%ebp)
  b8:	8b 45 08             	mov    0x8(%ebp),%eax
  bb:	8d 48 01             	lea    0x1(%eax),%ecx
  be:	89 4d 08             	mov    %ecx,0x8(%ebp)
  c1:	0f b6 12             	movzbl (%edx),%edx
  c4:	88 10                	mov    %dl,(%eax)
  c6:	0f b6 00             	movzbl (%eax),%eax
  c9:	84 c0                	test   %al,%al
  cb:	75 e2                	jne    af <strcpy+0x11>
    ;
  return os;
  cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d0:	c9                   	leave  
  d1:	c3                   	ret    

000000d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d2:	f3 0f 1e fb          	endbr32 
  d6:	55                   	push   %ebp
  d7:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  d9:	eb 08                	jmp    e3 <strcmp+0x11>
    p++, q++;
  db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  df:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	0f b6 00             	movzbl (%eax),%eax
  e9:	84 c0                	test   %al,%al
  eb:	74 10                	je     fd <strcmp+0x2b>
  ed:	8b 45 08             	mov    0x8(%ebp),%eax
  f0:	0f b6 10             	movzbl (%eax),%edx
  f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  f6:	0f b6 00             	movzbl (%eax),%eax
  f9:	38 c2                	cmp    %al,%dl
  fb:	74 de                	je     db <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  fd:	8b 45 08             	mov    0x8(%ebp),%eax
 100:	0f b6 00             	movzbl (%eax),%eax
 103:	0f b6 d0             	movzbl %al,%edx
 106:	8b 45 0c             	mov    0xc(%ebp),%eax
 109:	0f b6 00             	movzbl (%eax),%eax
 10c:	0f b6 c0             	movzbl %al,%eax
 10f:	29 c2                	sub    %eax,%edx
 111:	89 d0                	mov    %edx,%eax
}
 113:	5d                   	pop    %ebp
 114:	c3                   	ret    

00000115 <strlen>:

uint
strlen(char *s)
{
 115:	f3 0f 1e fb          	endbr32 
 119:	55                   	push   %ebp
 11a:	89 e5                	mov    %esp,%ebp
 11c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 11f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 126:	eb 04                	jmp    12c <strlen+0x17>
 128:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 12c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 12f:	8b 45 08             	mov    0x8(%ebp),%eax
 132:	01 d0                	add    %edx,%eax
 134:	0f b6 00             	movzbl (%eax),%eax
 137:	84 c0                	test   %al,%al
 139:	75 ed                	jne    128 <strlen+0x13>
    ;
  return n;
 13b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13e:	c9                   	leave  
 13f:	c3                   	ret    

00000140 <memset>:

void*
memset(void *dst, int c, uint n)
{
 140:	f3 0f 1e fb          	endbr32 
 144:	55                   	push   %ebp
 145:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 147:	8b 45 10             	mov    0x10(%ebp),%eax
 14a:	50                   	push   %eax
 14b:	ff 75 0c             	pushl  0xc(%ebp)
 14e:	ff 75 08             	pushl  0x8(%ebp)
 151:	e8 22 ff ff ff       	call   78 <stosb>
 156:	83 c4 0c             	add    $0xc,%esp
  return dst;
 159:	8b 45 08             	mov    0x8(%ebp),%eax
}
 15c:	c9                   	leave  
 15d:	c3                   	ret    

0000015e <strchr>:

char*
strchr(const char *s, char c)
{
 15e:	f3 0f 1e fb          	endbr32 
 162:	55                   	push   %ebp
 163:	89 e5                	mov    %esp,%ebp
 165:	83 ec 04             	sub    $0x4,%esp
 168:	8b 45 0c             	mov    0xc(%ebp),%eax
 16b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 16e:	eb 14                	jmp    184 <strchr+0x26>
    if(*s == c)
 170:	8b 45 08             	mov    0x8(%ebp),%eax
 173:	0f b6 00             	movzbl (%eax),%eax
 176:	38 45 fc             	cmp    %al,-0x4(%ebp)
 179:	75 05                	jne    180 <strchr+0x22>
      return (char*)s;
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	eb 13                	jmp    193 <strchr+0x35>
  for(; *s; s++)
 180:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	0f b6 00             	movzbl (%eax),%eax
 18a:	84 c0                	test   %al,%al
 18c:	75 e2                	jne    170 <strchr+0x12>
  return 0;
 18e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 193:	c9                   	leave  
 194:	c3                   	ret    

00000195 <gets>:

char*
gets(char *buf, int max)
{
 195:	f3 0f 1e fb          	endbr32 
 199:	55                   	push   %ebp
 19a:	89 e5                	mov    %esp,%ebp
 19c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a6:	eb 42                	jmp    1ea <gets+0x55>
    cc = read(0, &c, 1);
 1a8:	83 ec 04             	sub    $0x4,%esp
 1ab:	6a 01                	push   $0x1
 1ad:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b0:	50                   	push   %eax
 1b1:	6a 00                	push   $0x0
 1b3:	e8 53 01 00 00       	call   30b <read>
 1b8:	83 c4 10             	add    $0x10,%esp
 1bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c2:	7e 33                	jle    1f7 <gets+0x62>
      break;
    buf[i++] = c;
 1c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c7:	8d 50 01             	lea    0x1(%eax),%edx
 1ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1cd:	89 c2                	mov    %eax,%edx
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	01 c2                	add    %eax,%edx
 1d4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1da:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1de:	3c 0a                	cmp    $0xa,%al
 1e0:	74 16                	je     1f8 <gets+0x63>
 1e2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e6:	3c 0d                	cmp    $0xd,%al
 1e8:	74 0e                	je     1f8 <gets+0x63>
  for(i=0; i+1 < max; ){
 1ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ed:	83 c0 01             	add    $0x1,%eax
 1f0:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1f3:	7f b3                	jg     1a8 <gets+0x13>
 1f5:	eb 01                	jmp    1f8 <gets+0x63>
      break;
 1f7:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	01 d0                	add    %edx,%eax
 200:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 203:	8b 45 08             	mov    0x8(%ebp),%eax
}
 206:	c9                   	leave  
 207:	c3                   	ret    

00000208 <stat>:

int
stat(char *n, struct stat *st)
{
 208:	f3 0f 1e fb          	endbr32 
 20c:	55                   	push   %ebp
 20d:	89 e5                	mov    %esp,%ebp
 20f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 212:	83 ec 08             	sub    $0x8,%esp
 215:	6a 00                	push   $0x0
 217:	ff 75 08             	pushl  0x8(%ebp)
 21a:	e8 14 01 00 00       	call   333 <open>
 21f:	83 c4 10             	add    $0x10,%esp
 222:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 225:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 229:	79 07                	jns    232 <stat+0x2a>
    return -1;
 22b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 230:	eb 25                	jmp    257 <stat+0x4f>
  r = fstat(fd, st);
 232:	83 ec 08             	sub    $0x8,%esp
 235:	ff 75 0c             	pushl  0xc(%ebp)
 238:	ff 75 f4             	pushl  -0xc(%ebp)
 23b:	e8 0b 01 00 00       	call   34b <fstat>
 240:	83 c4 10             	add    $0x10,%esp
 243:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 246:	83 ec 0c             	sub    $0xc,%esp
 249:	ff 75 f4             	pushl  -0xc(%ebp)
 24c:	e8 ca 00 00 00       	call   31b <close>
 251:	83 c4 10             	add    $0x10,%esp
  return r;
 254:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 257:	c9                   	leave  
 258:	c3                   	ret    

00000259 <atoi>:

int
atoi(const char *s)
{
 259:	f3 0f 1e fb          	endbr32 
 25d:	55                   	push   %ebp
 25e:	89 e5                	mov    %esp,%ebp
 260:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 263:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26a:	eb 25                	jmp    291 <atoi+0x38>
    n = n*10 + *s++ - '0';
 26c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 26f:	89 d0                	mov    %edx,%eax
 271:	c1 e0 02             	shl    $0x2,%eax
 274:	01 d0                	add    %edx,%eax
 276:	01 c0                	add    %eax,%eax
 278:	89 c1                	mov    %eax,%ecx
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	8d 50 01             	lea    0x1(%eax),%edx
 280:	89 55 08             	mov    %edx,0x8(%ebp)
 283:	0f b6 00             	movzbl (%eax),%eax
 286:	0f be c0             	movsbl %al,%eax
 289:	01 c8                	add    %ecx,%eax
 28b:	83 e8 30             	sub    $0x30,%eax
 28e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	0f b6 00             	movzbl (%eax),%eax
 297:	3c 2f                	cmp    $0x2f,%al
 299:	7e 0a                	jle    2a5 <atoi+0x4c>
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	0f b6 00             	movzbl (%eax),%eax
 2a1:	3c 39                	cmp    $0x39,%al
 2a3:	7e c7                	jle    26c <atoi+0x13>
  return n;
 2a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a8:	c9                   	leave  
 2a9:	c3                   	ret    

000002aa <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2aa:	f3 0f 1e fb          	endbr32 
 2ae:	55                   	push   %ebp
 2af:	89 e5                	mov    %esp,%ebp
 2b1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c0:	eb 17                	jmp    2d9 <memmove+0x2f>
    *dst++ = *src++;
 2c2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2c5:	8d 42 01             	lea    0x1(%edx),%eax
 2c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ce:	8d 48 01             	lea    0x1(%eax),%ecx
 2d1:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2d4:	0f b6 12             	movzbl (%edx),%edx
 2d7:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2d9:	8b 45 10             	mov    0x10(%ebp),%eax
 2dc:	8d 50 ff             	lea    -0x1(%eax),%edx
 2df:	89 55 10             	mov    %edx,0x10(%ebp)
 2e2:	85 c0                	test   %eax,%eax
 2e4:	7f dc                	jg     2c2 <memmove+0x18>
  return vdst;
 2e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e9:	c9                   	leave  
 2ea:	c3                   	ret    

000002eb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2eb:	b8 01 00 00 00       	mov    $0x1,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <exit>:
SYSCALL(exit)
 2f3:	b8 02 00 00 00       	mov    $0x2,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <wait>:
SYSCALL(wait)
 2fb:	b8 03 00 00 00       	mov    $0x3,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <pipe>:
SYSCALL(pipe)
 303:	b8 04 00 00 00       	mov    $0x4,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <read>:
SYSCALL(read)
 30b:	b8 05 00 00 00       	mov    $0x5,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <write>:
SYSCALL(write)
 313:	b8 10 00 00 00       	mov    $0x10,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <close>:
SYSCALL(close)
 31b:	b8 15 00 00 00       	mov    $0x15,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <kill>:
SYSCALL(kill)
 323:	b8 06 00 00 00       	mov    $0x6,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <exec>:
SYSCALL(exec)
 32b:	b8 07 00 00 00       	mov    $0x7,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <open>:
SYSCALL(open)
 333:	b8 0f 00 00 00       	mov    $0xf,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <mknod>:
SYSCALL(mknod)
 33b:	b8 11 00 00 00       	mov    $0x11,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <unlink>:
SYSCALL(unlink)
 343:	b8 12 00 00 00       	mov    $0x12,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <fstat>:
SYSCALL(fstat)
 34b:	b8 08 00 00 00       	mov    $0x8,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <link>:
SYSCALL(link)
 353:	b8 13 00 00 00       	mov    $0x13,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <mkdir>:
SYSCALL(mkdir)
 35b:	b8 14 00 00 00       	mov    $0x14,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <chdir>:
SYSCALL(chdir)
 363:	b8 09 00 00 00       	mov    $0x9,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <dup>:
SYSCALL(dup)
 36b:	b8 0a 00 00 00       	mov    $0xa,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <getpid>:
SYSCALL(getpid)
 373:	b8 0b 00 00 00       	mov    $0xb,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <sbrk>:
SYSCALL(sbrk)
 37b:	b8 0c 00 00 00       	mov    $0xc,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <sleep>:
SYSCALL(sleep)
 383:	b8 0d 00 00 00       	mov    $0xd,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <uptime>:
SYSCALL(uptime)
 38b:	b8 0e 00 00 00       	mov    $0xe,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 393:	f3 0f 1e fb          	endbr32 
 397:	55                   	push   %ebp
 398:	89 e5                	mov    %esp,%ebp
 39a:	83 ec 18             	sub    $0x18,%esp
 39d:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3a3:	83 ec 04             	sub    $0x4,%esp
 3a6:	6a 01                	push   $0x1
 3a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3ab:	50                   	push   %eax
 3ac:	ff 75 08             	pushl  0x8(%ebp)
 3af:	e8 5f ff ff ff       	call   313 <write>
 3b4:	83 c4 10             	add    $0x10,%esp
}
 3b7:	90                   	nop
 3b8:	c9                   	leave  
 3b9:	c3                   	ret    

000003ba <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ba:	f3 0f 1e fb          	endbr32 
 3be:	55                   	push   %ebp
 3bf:	89 e5                	mov    %esp,%ebp
 3c1:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3cb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3cf:	74 17                	je     3e8 <printint+0x2e>
 3d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3d5:	79 11                	jns    3e8 <printint+0x2e>
    neg = 1;
 3d7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3de:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e1:	f7 d8                	neg    %eax
 3e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e6:	eb 06                	jmp    3ee <printint+0x34>
  } else {
    x = xx;
 3e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3fb:	ba 00 00 00 00       	mov    $0x0,%edx
 400:	f7 f1                	div    %ecx
 402:	89 d1                	mov    %edx,%ecx
 404:	8b 45 f4             	mov    -0xc(%ebp),%eax
 407:	8d 50 01             	lea    0x1(%eax),%edx
 40a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 40d:	0f b6 91 ac 0a 00 00 	movzbl 0xaac(%ecx),%edx
 414:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 418:	8b 4d 10             	mov    0x10(%ebp),%ecx
 41b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41e:	ba 00 00 00 00       	mov    $0x0,%edx
 423:	f7 f1                	div    %ecx
 425:	89 45 ec             	mov    %eax,-0x14(%ebp)
 428:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 42c:	75 c7                	jne    3f5 <printint+0x3b>
  if(neg)
 42e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 432:	74 2d                	je     461 <printint+0xa7>
    buf[i++] = '-';
 434:	8b 45 f4             	mov    -0xc(%ebp),%eax
 437:	8d 50 01             	lea    0x1(%eax),%edx
 43a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 43d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 442:	eb 1d                	jmp    461 <printint+0xa7>
    putc(fd, buf[i]);
 444:	8d 55 dc             	lea    -0x24(%ebp),%edx
 447:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44a:	01 d0                	add    %edx,%eax
 44c:	0f b6 00             	movzbl (%eax),%eax
 44f:	0f be c0             	movsbl %al,%eax
 452:	83 ec 08             	sub    $0x8,%esp
 455:	50                   	push   %eax
 456:	ff 75 08             	pushl  0x8(%ebp)
 459:	e8 35 ff ff ff       	call   393 <putc>
 45e:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 461:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 465:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 469:	79 d9                	jns    444 <printint+0x8a>
}
 46b:	90                   	nop
 46c:	90                   	nop
 46d:	c9                   	leave  
 46e:	c3                   	ret    

0000046f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 46f:	f3 0f 1e fb          	endbr32 
 473:	55                   	push   %ebp
 474:	89 e5                	mov    %esp,%ebp
 476:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 479:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 480:	8d 45 0c             	lea    0xc(%ebp),%eax
 483:	83 c0 04             	add    $0x4,%eax
 486:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 489:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 490:	e9 59 01 00 00       	jmp    5ee <printf+0x17f>
    c = fmt[i] & 0xff;
 495:	8b 55 0c             	mov    0xc(%ebp),%edx
 498:	8b 45 f0             	mov    -0x10(%ebp),%eax
 49b:	01 d0                	add    %edx,%eax
 49d:	0f b6 00             	movzbl (%eax),%eax
 4a0:	0f be c0             	movsbl %al,%eax
 4a3:	25 ff 00 00 00       	and    $0xff,%eax
 4a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4af:	75 2c                	jne    4dd <printf+0x6e>
      if(c == '%'){
 4b1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4b5:	75 0c                	jne    4c3 <printf+0x54>
        state = '%';
 4b7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4be:	e9 27 01 00 00       	jmp    5ea <printf+0x17b>
      } else {
        putc(fd, c);
 4c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c6:	0f be c0             	movsbl %al,%eax
 4c9:	83 ec 08             	sub    $0x8,%esp
 4cc:	50                   	push   %eax
 4cd:	ff 75 08             	pushl  0x8(%ebp)
 4d0:	e8 be fe ff ff       	call   393 <putc>
 4d5:	83 c4 10             	add    $0x10,%esp
 4d8:	e9 0d 01 00 00       	jmp    5ea <printf+0x17b>
      }
    } else if(state == '%'){
 4dd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4e1:	0f 85 03 01 00 00    	jne    5ea <printf+0x17b>
      if(c == 'd'){
 4e7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4eb:	75 1e                	jne    50b <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f0:	8b 00                	mov    (%eax),%eax
 4f2:	6a 01                	push   $0x1
 4f4:	6a 0a                	push   $0xa
 4f6:	50                   	push   %eax
 4f7:	ff 75 08             	pushl  0x8(%ebp)
 4fa:	e8 bb fe ff ff       	call   3ba <printint>
 4ff:	83 c4 10             	add    $0x10,%esp
        ap++;
 502:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 506:	e9 d8 00 00 00       	jmp    5e3 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 50b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 50f:	74 06                	je     517 <printf+0xa8>
 511:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 515:	75 1e                	jne    535 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 517:	8b 45 e8             	mov    -0x18(%ebp),%eax
 51a:	8b 00                	mov    (%eax),%eax
 51c:	6a 00                	push   $0x0
 51e:	6a 10                	push   $0x10
 520:	50                   	push   %eax
 521:	ff 75 08             	pushl  0x8(%ebp)
 524:	e8 91 fe ff ff       	call   3ba <printint>
 529:	83 c4 10             	add    $0x10,%esp
        ap++;
 52c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 530:	e9 ae 00 00 00       	jmp    5e3 <printf+0x174>
      } else if(c == 's'){
 535:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 539:	75 43                	jne    57e <printf+0x10f>
        s = (char*)*ap;
 53b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53e:	8b 00                	mov    (%eax),%eax
 540:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 543:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 547:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 54b:	75 25                	jne    572 <printf+0x103>
          s = "(null)";
 54d:	c7 45 f4 5d 08 00 00 	movl   $0x85d,-0xc(%ebp)
        while(*s != 0){
 554:	eb 1c                	jmp    572 <printf+0x103>
          putc(fd, *s);
 556:	8b 45 f4             	mov    -0xc(%ebp),%eax
 559:	0f b6 00             	movzbl (%eax),%eax
 55c:	0f be c0             	movsbl %al,%eax
 55f:	83 ec 08             	sub    $0x8,%esp
 562:	50                   	push   %eax
 563:	ff 75 08             	pushl  0x8(%ebp)
 566:	e8 28 fe ff ff       	call   393 <putc>
 56b:	83 c4 10             	add    $0x10,%esp
          s++;
 56e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 572:	8b 45 f4             	mov    -0xc(%ebp),%eax
 575:	0f b6 00             	movzbl (%eax),%eax
 578:	84 c0                	test   %al,%al
 57a:	75 da                	jne    556 <printf+0xe7>
 57c:	eb 65                	jmp    5e3 <printf+0x174>
        }
      } else if(c == 'c'){
 57e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 582:	75 1d                	jne    5a1 <printf+0x132>
        putc(fd, *ap);
 584:	8b 45 e8             	mov    -0x18(%ebp),%eax
 587:	8b 00                	mov    (%eax),%eax
 589:	0f be c0             	movsbl %al,%eax
 58c:	83 ec 08             	sub    $0x8,%esp
 58f:	50                   	push   %eax
 590:	ff 75 08             	pushl  0x8(%ebp)
 593:	e8 fb fd ff ff       	call   393 <putc>
 598:	83 c4 10             	add    $0x10,%esp
        ap++;
 59b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 59f:	eb 42                	jmp    5e3 <printf+0x174>
      } else if(c == '%'){
 5a1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5a5:	75 17                	jne    5be <printf+0x14f>
        putc(fd, c);
 5a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5aa:	0f be c0             	movsbl %al,%eax
 5ad:	83 ec 08             	sub    $0x8,%esp
 5b0:	50                   	push   %eax
 5b1:	ff 75 08             	pushl  0x8(%ebp)
 5b4:	e8 da fd ff ff       	call   393 <putc>
 5b9:	83 c4 10             	add    $0x10,%esp
 5bc:	eb 25                	jmp    5e3 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5be:	83 ec 08             	sub    $0x8,%esp
 5c1:	6a 25                	push   $0x25
 5c3:	ff 75 08             	pushl  0x8(%ebp)
 5c6:	e8 c8 fd ff ff       	call   393 <putc>
 5cb:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d1:	0f be c0             	movsbl %al,%eax
 5d4:	83 ec 08             	sub    $0x8,%esp
 5d7:	50                   	push   %eax
 5d8:	ff 75 08             	pushl  0x8(%ebp)
 5db:	e8 b3 fd ff ff       	call   393 <putc>
 5e0:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5ea:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ee:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f4:	01 d0                	add    %edx,%eax
 5f6:	0f b6 00             	movzbl (%eax),%eax
 5f9:	84 c0                	test   %al,%al
 5fb:	0f 85 94 fe ff ff    	jne    495 <printf+0x26>
    }
  }
}
 601:	90                   	nop
 602:	90                   	nop
 603:	c9                   	leave  
 604:	c3                   	ret    

00000605 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 605:	f3 0f 1e fb          	endbr32 
 609:	55                   	push   %ebp
 60a:	89 e5                	mov    %esp,%ebp
 60c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 60f:	8b 45 08             	mov    0x8(%ebp),%eax
 612:	83 e8 08             	sub    $0x8,%eax
 615:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 618:	a1 c8 0a 00 00       	mov    0xac8,%eax
 61d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 620:	eb 24                	jmp    646 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 622:	8b 45 fc             	mov    -0x4(%ebp),%eax
 625:	8b 00                	mov    (%eax),%eax
 627:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 62a:	72 12                	jb     63e <free+0x39>
 62c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 632:	77 24                	ja     658 <free+0x53>
 634:	8b 45 fc             	mov    -0x4(%ebp),%eax
 637:	8b 00                	mov    (%eax),%eax
 639:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 63c:	72 1a                	jb     658 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 63e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 641:	8b 00                	mov    (%eax),%eax
 643:	89 45 fc             	mov    %eax,-0x4(%ebp)
 646:	8b 45 f8             	mov    -0x8(%ebp),%eax
 649:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 64c:	76 d4                	jbe    622 <free+0x1d>
 64e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 651:	8b 00                	mov    (%eax),%eax
 653:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 656:	73 ca                	jae    622 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 658:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65b:	8b 40 04             	mov    0x4(%eax),%eax
 65e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 665:	8b 45 f8             	mov    -0x8(%ebp),%eax
 668:	01 c2                	add    %eax,%edx
 66a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66d:	8b 00                	mov    (%eax),%eax
 66f:	39 c2                	cmp    %eax,%edx
 671:	75 24                	jne    697 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 673:	8b 45 f8             	mov    -0x8(%ebp),%eax
 676:	8b 50 04             	mov    0x4(%eax),%edx
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67c:	8b 00                	mov    (%eax),%eax
 67e:	8b 40 04             	mov    0x4(%eax),%eax
 681:	01 c2                	add    %eax,%edx
 683:	8b 45 f8             	mov    -0x8(%ebp),%eax
 686:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 689:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68c:	8b 00                	mov    (%eax),%eax
 68e:	8b 10                	mov    (%eax),%edx
 690:	8b 45 f8             	mov    -0x8(%ebp),%eax
 693:	89 10                	mov    %edx,(%eax)
 695:	eb 0a                	jmp    6a1 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	8b 10                	mov    (%eax),%edx
 69c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 40 04             	mov    0x4(%eax),%eax
 6a7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b1:	01 d0                	add    %edx,%eax
 6b3:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6b6:	75 20                	jne    6d8 <free+0xd3>
    p->s.size += bp->s.size;
 6b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bb:	8b 50 04             	mov    0x4(%eax),%edx
 6be:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c1:	8b 40 04             	mov    0x4(%eax),%eax
 6c4:	01 c2                	add    %eax,%edx
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cf:	8b 10                	mov    (%eax),%edx
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	89 10                	mov    %edx,(%eax)
 6d6:	eb 08                	jmp    6e0 <free+0xdb>
  } else
    p->s.ptr = bp;
 6d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6db:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6de:	89 10                	mov    %edx,(%eax)
  freep = p;
 6e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e3:	a3 c8 0a 00 00       	mov    %eax,0xac8
}
 6e8:	90                   	nop
 6e9:	c9                   	leave  
 6ea:	c3                   	ret    

000006eb <morecore>:

static Header*
morecore(uint nu)
{
 6eb:	f3 0f 1e fb          	endbr32 
 6ef:	55                   	push   %ebp
 6f0:	89 e5                	mov    %esp,%ebp
 6f2:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6f5:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6fc:	77 07                	ja     705 <morecore+0x1a>
    nu = 4096;
 6fe:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 705:	8b 45 08             	mov    0x8(%ebp),%eax
 708:	c1 e0 03             	shl    $0x3,%eax
 70b:	83 ec 0c             	sub    $0xc,%esp
 70e:	50                   	push   %eax
 70f:	e8 67 fc ff ff       	call   37b <sbrk>
 714:	83 c4 10             	add    $0x10,%esp
 717:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 71a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 71e:	75 07                	jne    727 <morecore+0x3c>
    return 0;
 720:	b8 00 00 00 00       	mov    $0x0,%eax
 725:	eb 26                	jmp    74d <morecore+0x62>
  hp = (Header*)p;
 727:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 72d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 730:	8b 55 08             	mov    0x8(%ebp),%edx
 733:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 736:	8b 45 f0             	mov    -0x10(%ebp),%eax
 739:	83 c0 08             	add    $0x8,%eax
 73c:	83 ec 0c             	sub    $0xc,%esp
 73f:	50                   	push   %eax
 740:	e8 c0 fe ff ff       	call   605 <free>
 745:	83 c4 10             	add    $0x10,%esp
  return freep;
 748:	a1 c8 0a 00 00       	mov    0xac8,%eax
}
 74d:	c9                   	leave  
 74e:	c3                   	ret    

0000074f <malloc>:

void*
malloc(uint nbytes)
{
 74f:	f3 0f 1e fb          	endbr32 
 753:	55                   	push   %ebp
 754:	89 e5                	mov    %esp,%ebp
 756:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 759:	8b 45 08             	mov    0x8(%ebp),%eax
 75c:	83 c0 07             	add    $0x7,%eax
 75f:	c1 e8 03             	shr    $0x3,%eax
 762:	83 c0 01             	add    $0x1,%eax
 765:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 768:	a1 c8 0a 00 00       	mov    0xac8,%eax
 76d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 770:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 774:	75 23                	jne    799 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 776:	c7 45 f0 c0 0a 00 00 	movl   $0xac0,-0x10(%ebp)
 77d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 780:	a3 c8 0a 00 00       	mov    %eax,0xac8
 785:	a1 c8 0a 00 00       	mov    0xac8,%eax
 78a:	a3 c0 0a 00 00       	mov    %eax,0xac0
    base.s.size = 0;
 78f:	c7 05 c4 0a 00 00 00 	movl   $0x0,0xac4
 796:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 799:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79c:	8b 00                	mov    (%eax),%eax
 79e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a4:	8b 40 04             	mov    0x4(%eax),%eax
 7a7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7aa:	77 4d                	ja     7f9 <malloc+0xaa>
      if(p->s.size == nunits)
 7ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7af:	8b 40 04             	mov    0x4(%eax),%eax
 7b2:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7b5:	75 0c                	jne    7c3 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 7b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ba:	8b 10                	mov    (%eax),%edx
 7bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bf:	89 10                	mov    %edx,(%eax)
 7c1:	eb 26                	jmp    7e9 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c6:	8b 40 04             	mov    0x4(%eax),%eax
 7c9:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7cc:	89 c2                	mov    %eax,%edx
 7ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d7:	8b 40 04             	mov    0x4(%eax),%eax
 7da:	c1 e0 03             	shl    $0x3,%eax
 7dd:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7e6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ec:	a3 c8 0a 00 00       	mov    %eax,0xac8
      return (void*)(p + 1);
 7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f4:	83 c0 08             	add    $0x8,%eax
 7f7:	eb 3b                	jmp    834 <malloc+0xe5>
    }
    if(p == freep)
 7f9:	a1 c8 0a 00 00       	mov    0xac8,%eax
 7fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 801:	75 1e                	jne    821 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 803:	83 ec 0c             	sub    $0xc,%esp
 806:	ff 75 ec             	pushl  -0x14(%ebp)
 809:	e8 dd fe ff ff       	call   6eb <morecore>
 80e:	83 c4 10             	add    $0x10,%esp
 811:	89 45 f4             	mov    %eax,-0xc(%ebp)
 814:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 818:	75 07                	jne    821 <malloc+0xd2>
        return 0;
 81a:	b8 00 00 00 00       	mov    $0x0,%eax
 81f:	eb 13                	jmp    834 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 821:	8b 45 f4             	mov    -0xc(%ebp),%eax
 824:	89 45 f0             	mov    %eax,-0x10(%ebp)
 827:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82a:	8b 00                	mov    (%eax),%eax
 82c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 82f:	e9 6d ff ff ff       	jmp    7a1 <malloc+0x52>
  }
}
 834:	c9                   	leave  
 835:	c3                   	ret    
