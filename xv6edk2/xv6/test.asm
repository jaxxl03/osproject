
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 24             	sub    $0x24,%esp
    int pid, child_pid;
    char *message;
    int n, status, exit_code;

    pid = fork();
  15:	e8 5c 03 00 00       	call   376 <fork>
  1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    switch (pid)
  1d:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
  21:	74 08                	je     2b <main+0x2b>
  23:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  27:	74 21                	je     4a <main+0x4a>
  29:	eb 36                	jmp    61 <main+0x61>
    {
        case -1:
            printf(2, "fork failed\n");
  2b:	83 ec 08             	sub    $0x8,%esp
  2e:	68 d1 08 00 00       	push   $0x8d1
  33:	6a 02                	push   $0x2
  35:	e8 d0 04 00 00       	call   50a <printf>
  3a:	83 c4 10             	add    $0x10,%esp
            exit2(1);
  3d:	83 ec 0c             	sub    $0xc,%esp
  40:	6a 01                	push   $0x1
  42:	e8 df 03 00 00       	call   426 <exit2>
  47:	83 c4 10             	add    $0x10,%esp
        case 0: // 자식 프로세스
            message = "This is the child";
  4a:	c7 45 f4 de 08 00 00 	movl   $0x8de,-0xc(%ebp)
            n = 5;
  51:	c7 45 f0 05 00 00 00 	movl   $0x5,-0x10(%ebp)
            exit_code = 37; // 자식의 유언 번호
  58:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
            break;
  5f:	eb 16                	jmp    77 <main+0x77>
        default: // 부모 프로세스
            message = "This is the parent";
  61:	c7 45 f4 f0 08 00 00 	movl   $0x8f0,-0xc(%ebp)
            n = 3;
  68:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
            exit_code = 0;
  6f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
            break;
  76:	90                   	nop
    }

    // n번 반복하면서 메시지 출력
    for(; n > 0; n--) {
  77:	eb 26                	jmp    9f <main+0x9f>
        printf(1, "%s\n", message);
  79:	83 ec 04             	sub    $0x4,%esp
  7c:	ff 75 f4             	pushl  -0xc(%ebp)
  7f:	68 03 09 00 00       	push   $0x903
  84:	6a 01                	push   $0x1
  86:	e8 7f 04 00 00       	call   50a <printf>
  8b:	83 c4 10             	add    $0x10,%esp
        sleep(1);
  8e:	83 ec 0c             	sub    $0xc,%esp
  91:	6a 01                	push   $0x1
  93:	e8 76 03 00 00       	call   40e <sleep>
  98:	83 c4 10             	add    $0x10,%esp
    for(; n > 0; n--) {
  9b:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  a3:	7f d4                	jg     79 <main+0x79>
    }

    // 부모만 실행하는 구간 (자식이 죽을 때까지 기다림)
    if (pid != 0) {
  a5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  a9:	74 3d                	je     e8 <main+0xe8>
        child_pid = wait2(&status); 
  ab:	83 ec 0c             	sub    $0xc,%esp
  ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
  b1:	50                   	push   %eax
  b2:	e8 67 03 00 00       	call   41e <wait2>
  b7:	83 c4 10             	add    $0x10,%esp
  ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        printf(1, "Child has finished: PID = %d\n", child_pid);
  bd:	83 ec 04             	sub    $0x4,%esp
  c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  c3:	68 07 09 00 00       	push   $0x907
  c8:	6a 01                	push   $0x1
  ca:	e8 3b 04 00 00       	call   50a <printf>
  cf:	83 c4 10             	add    $0x10,%esp
        printf(1, "Child exited with code %d\n", status); 
  d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  d5:	83 ec 04             	sub    $0x4,%esp
  d8:	50                   	push   %eax
  d9:	68 25 09 00 00       	push   $0x925
  de:	6a 01                	push   $0x1
  e0:	e8 25 04 00 00       	call   50a <printf>
  e5:	83 c4 10             	add    $0x10,%esp
    }

    exit2(exit_code); 
  e8:	83 ec 0c             	sub    $0xc,%esp
  eb:	ff 75 ec             	pushl  -0x14(%ebp)
  ee:	e8 33 03 00 00       	call   426 <exit2>
  f3:	83 c4 10             	add    $0x10,%esp
  f6:	b8 00 00 00 00       	mov    $0x0,%eax
  fb:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  fe:	c9                   	leave  
  ff:	8d 61 fc             	lea    -0x4(%ecx),%esp
 102:	c3                   	ret    

00000103 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	57                   	push   %edi
 107:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 108:	8b 4d 08             	mov    0x8(%ebp),%ecx
 10b:	8b 55 10             	mov    0x10(%ebp),%edx
 10e:	8b 45 0c             	mov    0xc(%ebp),%eax
 111:	89 cb                	mov    %ecx,%ebx
 113:	89 df                	mov    %ebx,%edi
 115:	89 d1                	mov    %edx,%ecx
 117:	fc                   	cld    
 118:	f3 aa                	rep stos %al,%es:(%edi)
 11a:	89 ca                	mov    %ecx,%edx
 11c:	89 fb                	mov    %edi,%ebx
 11e:	89 5d 08             	mov    %ebx,0x8(%ebp)
 121:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 124:	90                   	nop
 125:	5b                   	pop    %ebx
 126:	5f                   	pop    %edi
 127:	5d                   	pop    %ebp
 128:	c3                   	ret    

00000129 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 129:	f3 0f 1e fb          	endbr32 
 12d:	55                   	push   %ebp
 12e:	89 e5                	mov    %esp,%ebp
 130:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 139:	90                   	nop
 13a:	8b 55 0c             	mov    0xc(%ebp),%edx
 13d:	8d 42 01             	lea    0x1(%edx),%eax
 140:	89 45 0c             	mov    %eax,0xc(%ebp)
 143:	8b 45 08             	mov    0x8(%ebp),%eax
 146:	8d 48 01             	lea    0x1(%eax),%ecx
 149:	89 4d 08             	mov    %ecx,0x8(%ebp)
 14c:	0f b6 12             	movzbl (%edx),%edx
 14f:	88 10                	mov    %dl,(%eax)
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	84 c0                	test   %al,%al
 156:	75 e2                	jne    13a <strcpy+0x11>
    ;
  return os;
 158:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 15b:	c9                   	leave  
 15c:	c3                   	ret    

0000015d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 15d:	f3 0f 1e fb          	endbr32 
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 164:	eb 08                	jmp    16e <strcmp+0x11>
    p++, q++;
 166:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	0f b6 00             	movzbl (%eax),%eax
 174:	84 c0                	test   %al,%al
 176:	74 10                	je     188 <strcmp+0x2b>
 178:	8b 45 08             	mov    0x8(%ebp),%eax
 17b:	0f b6 10             	movzbl (%eax),%edx
 17e:	8b 45 0c             	mov    0xc(%ebp),%eax
 181:	0f b6 00             	movzbl (%eax),%eax
 184:	38 c2                	cmp    %al,%dl
 186:	74 de                	je     166 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	0f b6 00             	movzbl (%eax),%eax
 18e:	0f b6 d0             	movzbl %al,%edx
 191:	8b 45 0c             	mov    0xc(%ebp),%eax
 194:	0f b6 00             	movzbl (%eax),%eax
 197:	0f b6 c0             	movzbl %al,%eax
 19a:	29 c2                	sub    %eax,%edx
 19c:	89 d0                	mov    %edx,%eax
}
 19e:	5d                   	pop    %ebp
 19f:	c3                   	ret    

000001a0 <strlen>:

uint
strlen(char *s)
{
 1a0:	f3 0f 1e fb          	endbr32 
 1a4:	55                   	push   %ebp
 1a5:	89 e5                	mov    %esp,%ebp
 1a7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b1:	eb 04                	jmp    1b7 <strlen+0x17>
 1b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	01 d0                	add    %edx,%eax
 1bf:	0f b6 00             	movzbl (%eax),%eax
 1c2:	84 c0                	test   %al,%al
 1c4:	75 ed                	jne    1b3 <strlen+0x13>
    ;
  return n;
 1c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c9:	c9                   	leave  
 1ca:	c3                   	ret    

000001cb <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cb:	f3 0f 1e fb          	endbr32 
 1cf:	55                   	push   %ebp
 1d0:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1d2:	8b 45 10             	mov    0x10(%ebp),%eax
 1d5:	50                   	push   %eax
 1d6:	ff 75 0c             	pushl  0xc(%ebp)
 1d9:	ff 75 08             	pushl  0x8(%ebp)
 1dc:	e8 22 ff ff ff       	call   103 <stosb>
 1e1:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e7:	c9                   	leave  
 1e8:	c3                   	ret    

000001e9 <strchr>:

char*
strchr(const char *s, char c)
{
 1e9:	f3 0f 1e fb          	endbr32 
 1ed:	55                   	push   %ebp
 1ee:	89 e5                	mov    %esp,%ebp
 1f0:	83 ec 04             	sub    $0x4,%esp
 1f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f6:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f9:	eb 14                	jmp    20f <strchr+0x26>
    if(*s == c)
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	0f b6 00             	movzbl (%eax),%eax
 201:	38 45 fc             	cmp    %al,-0x4(%ebp)
 204:	75 05                	jne    20b <strchr+0x22>
      return (char*)s;
 206:	8b 45 08             	mov    0x8(%ebp),%eax
 209:	eb 13                	jmp    21e <strchr+0x35>
  for(; *s; s++)
 20b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	0f b6 00             	movzbl (%eax),%eax
 215:	84 c0                	test   %al,%al
 217:	75 e2                	jne    1fb <strchr+0x12>
  return 0;
 219:	b8 00 00 00 00       	mov    $0x0,%eax
}
 21e:	c9                   	leave  
 21f:	c3                   	ret    

00000220 <gets>:

char*
gets(char *buf, int max)
{
 220:	f3 0f 1e fb          	endbr32 
 224:	55                   	push   %ebp
 225:	89 e5                	mov    %esp,%ebp
 227:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 231:	eb 42                	jmp    275 <gets+0x55>
    cc = read(0, &c, 1);
 233:	83 ec 04             	sub    $0x4,%esp
 236:	6a 01                	push   $0x1
 238:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23b:	50                   	push   %eax
 23c:	6a 00                	push   $0x0
 23e:	e8 53 01 00 00       	call   396 <read>
 243:	83 c4 10             	add    $0x10,%esp
 246:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 249:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 24d:	7e 33                	jle    282 <gets+0x62>
      break;
    buf[i++] = c;
 24f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 252:	8d 50 01             	lea    0x1(%eax),%edx
 255:	89 55 f4             	mov    %edx,-0xc(%ebp)
 258:	89 c2                	mov    %eax,%edx
 25a:	8b 45 08             	mov    0x8(%ebp),%eax
 25d:	01 c2                	add    %eax,%edx
 25f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 263:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 265:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 269:	3c 0a                	cmp    $0xa,%al
 26b:	74 16                	je     283 <gets+0x63>
 26d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 271:	3c 0d                	cmp    $0xd,%al
 273:	74 0e                	je     283 <gets+0x63>
  for(i=0; i+1 < max; ){
 275:	8b 45 f4             	mov    -0xc(%ebp),%eax
 278:	83 c0 01             	add    $0x1,%eax
 27b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 27e:	7f b3                	jg     233 <gets+0x13>
 280:	eb 01                	jmp    283 <gets+0x63>
      break;
 282:	90                   	nop
      break;
  }
  buf[i] = '\0';
 283:	8b 55 f4             	mov    -0xc(%ebp),%edx
 286:	8b 45 08             	mov    0x8(%ebp),%eax
 289:	01 d0                	add    %edx,%eax
 28b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 291:	c9                   	leave  
 292:	c3                   	ret    

00000293 <stat>:

int
stat(char *n, struct stat *st)
{
 293:	f3 0f 1e fb          	endbr32 
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29d:	83 ec 08             	sub    $0x8,%esp
 2a0:	6a 00                	push   $0x0
 2a2:	ff 75 08             	pushl  0x8(%ebp)
 2a5:	e8 14 01 00 00       	call   3be <open>
 2aa:	83 c4 10             	add    $0x10,%esp
 2ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b4:	79 07                	jns    2bd <stat+0x2a>
    return -1;
 2b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bb:	eb 25                	jmp    2e2 <stat+0x4f>
  r = fstat(fd, st);
 2bd:	83 ec 08             	sub    $0x8,%esp
 2c0:	ff 75 0c             	pushl  0xc(%ebp)
 2c3:	ff 75 f4             	pushl  -0xc(%ebp)
 2c6:	e8 0b 01 00 00       	call   3d6 <fstat>
 2cb:	83 c4 10             	add    $0x10,%esp
 2ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d1:	83 ec 0c             	sub    $0xc,%esp
 2d4:	ff 75 f4             	pushl  -0xc(%ebp)
 2d7:	e8 ca 00 00 00       	call   3a6 <close>
 2dc:	83 c4 10             	add    $0x10,%esp
  return r;
 2df:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e2:	c9                   	leave  
 2e3:	c3                   	ret    

000002e4 <atoi>:

int
atoi(const char *s)
{
 2e4:	f3 0f 1e fb          	endbr32 
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f5:	eb 25                	jmp    31c <atoi+0x38>
    n = n*10 + *s++ - '0';
 2f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2fa:	89 d0                	mov    %edx,%eax
 2fc:	c1 e0 02             	shl    $0x2,%eax
 2ff:	01 d0                	add    %edx,%eax
 301:	01 c0                	add    %eax,%eax
 303:	89 c1                	mov    %eax,%ecx
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	8d 50 01             	lea    0x1(%eax),%edx
 30b:	89 55 08             	mov    %edx,0x8(%ebp)
 30e:	0f b6 00             	movzbl (%eax),%eax
 311:	0f be c0             	movsbl %al,%eax
 314:	01 c8                	add    %ecx,%eax
 316:	83 e8 30             	sub    $0x30,%eax
 319:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	0f b6 00             	movzbl (%eax),%eax
 322:	3c 2f                	cmp    $0x2f,%al
 324:	7e 0a                	jle    330 <atoi+0x4c>
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	0f b6 00             	movzbl (%eax),%eax
 32c:	3c 39                	cmp    $0x39,%al
 32e:	7e c7                	jle    2f7 <atoi+0x13>
  return n;
 330:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 333:	c9                   	leave  
 334:	c3                   	ret    

00000335 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 335:	f3 0f 1e fb          	endbr32 
 339:	55                   	push   %ebp
 33a:	89 e5                	mov    %esp,%ebp
 33c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 33f:	8b 45 08             	mov    0x8(%ebp),%eax
 342:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 345:	8b 45 0c             	mov    0xc(%ebp),%eax
 348:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 34b:	eb 17                	jmp    364 <memmove+0x2f>
    *dst++ = *src++;
 34d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 350:	8d 42 01             	lea    0x1(%edx),%eax
 353:	89 45 f8             	mov    %eax,-0x8(%ebp)
 356:	8b 45 fc             	mov    -0x4(%ebp),%eax
 359:	8d 48 01             	lea    0x1(%eax),%ecx
 35c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 35f:	0f b6 12             	movzbl (%edx),%edx
 362:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 364:	8b 45 10             	mov    0x10(%ebp),%eax
 367:	8d 50 ff             	lea    -0x1(%eax),%edx
 36a:	89 55 10             	mov    %edx,0x10(%ebp)
 36d:	85 c0                	test   %eax,%eax
 36f:	7f dc                	jg     34d <memmove+0x18>
  return vdst;
 371:	8b 45 08             	mov    0x8(%ebp),%eax
}
 374:	c9                   	leave  
 375:	c3                   	ret    

00000376 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 376:	b8 01 00 00 00       	mov    $0x1,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <exit>:
SYSCALL(exit)
 37e:	b8 02 00 00 00       	mov    $0x2,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <wait>:
SYSCALL(wait)
 386:	b8 03 00 00 00       	mov    $0x3,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <pipe>:
SYSCALL(pipe)
 38e:	b8 04 00 00 00       	mov    $0x4,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret    

00000396 <read>:
SYSCALL(read)
 396:	b8 05 00 00 00       	mov    $0x5,%eax
 39b:	cd 40                	int    $0x40
 39d:	c3                   	ret    

0000039e <write>:
SYSCALL(write)
 39e:	b8 10 00 00 00       	mov    $0x10,%eax
 3a3:	cd 40                	int    $0x40
 3a5:	c3                   	ret    

000003a6 <close>:
SYSCALL(close)
 3a6:	b8 15 00 00 00       	mov    $0x15,%eax
 3ab:	cd 40                	int    $0x40
 3ad:	c3                   	ret    

000003ae <kill>:
SYSCALL(kill)
 3ae:	b8 06 00 00 00       	mov    $0x6,%eax
 3b3:	cd 40                	int    $0x40
 3b5:	c3                   	ret    

000003b6 <exec>:
SYSCALL(exec)
 3b6:	b8 07 00 00 00       	mov    $0x7,%eax
 3bb:	cd 40                	int    $0x40
 3bd:	c3                   	ret    

000003be <open>:
SYSCALL(open)
 3be:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c3:	cd 40                	int    $0x40
 3c5:	c3                   	ret    

000003c6 <mknod>:
SYSCALL(mknod)
 3c6:	b8 11 00 00 00       	mov    $0x11,%eax
 3cb:	cd 40                	int    $0x40
 3cd:	c3                   	ret    

000003ce <unlink>:
SYSCALL(unlink)
 3ce:	b8 12 00 00 00       	mov    $0x12,%eax
 3d3:	cd 40                	int    $0x40
 3d5:	c3                   	ret    

000003d6 <fstat>:
SYSCALL(fstat)
 3d6:	b8 08 00 00 00       	mov    $0x8,%eax
 3db:	cd 40                	int    $0x40
 3dd:	c3                   	ret    

000003de <link>:
SYSCALL(link)
 3de:	b8 13 00 00 00       	mov    $0x13,%eax
 3e3:	cd 40                	int    $0x40
 3e5:	c3                   	ret    

000003e6 <mkdir>:
SYSCALL(mkdir)
 3e6:	b8 14 00 00 00       	mov    $0x14,%eax
 3eb:	cd 40                	int    $0x40
 3ed:	c3                   	ret    

000003ee <chdir>:
SYSCALL(chdir)
 3ee:	b8 09 00 00 00       	mov    $0x9,%eax
 3f3:	cd 40                	int    $0x40
 3f5:	c3                   	ret    

000003f6 <dup>:
SYSCALL(dup)
 3f6:	b8 0a 00 00 00       	mov    $0xa,%eax
 3fb:	cd 40                	int    $0x40
 3fd:	c3                   	ret    

000003fe <getpid>:
SYSCALL(getpid)
 3fe:	b8 0b 00 00 00       	mov    $0xb,%eax
 403:	cd 40                	int    $0x40
 405:	c3                   	ret    

00000406 <sbrk>:
SYSCALL(sbrk)
 406:	b8 0c 00 00 00       	mov    $0xc,%eax
 40b:	cd 40                	int    $0x40
 40d:	c3                   	ret    

0000040e <sleep>:
SYSCALL(sleep)
 40e:	b8 0d 00 00 00       	mov    $0xd,%eax
 413:	cd 40                	int    $0x40
 415:	c3                   	ret    

00000416 <uptime>:
SYSCALL(uptime)
 416:	b8 0e 00 00 00       	mov    $0xe,%eax
 41b:	cd 40                	int    $0x40
 41d:	c3                   	ret    

0000041e <wait2>:
SYSCALL(wait2)
 41e:	b8 17 00 00 00       	mov    $0x17,%eax
 423:	cd 40                	int    $0x40
 425:	c3                   	ret    

00000426 <exit2>:
SYSCALL(exit2)
 426:	b8 16 00 00 00       	mov    $0x16,%eax
 42b:	cd 40                	int    $0x40
 42d:	c3                   	ret    

0000042e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 42e:	f3 0f 1e fb          	endbr32 
 432:	55                   	push   %ebp
 433:	89 e5                	mov    %esp,%ebp
 435:	83 ec 18             	sub    $0x18,%esp
 438:	8b 45 0c             	mov    0xc(%ebp),%eax
 43b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 43e:	83 ec 04             	sub    $0x4,%esp
 441:	6a 01                	push   $0x1
 443:	8d 45 f4             	lea    -0xc(%ebp),%eax
 446:	50                   	push   %eax
 447:	ff 75 08             	pushl  0x8(%ebp)
 44a:	e8 4f ff ff ff       	call   39e <write>
 44f:	83 c4 10             	add    $0x10,%esp
}
 452:	90                   	nop
 453:	c9                   	leave  
 454:	c3                   	ret    

00000455 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 455:	f3 0f 1e fb          	endbr32 
 459:	55                   	push   %ebp
 45a:	89 e5                	mov    %esp,%ebp
 45c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 45f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 466:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 46a:	74 17                	je     483 <printint+0x2e>
 46c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 470:	79 11                	jns    483 <printint+0x2e>
    neg = 1;
 472:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 479:	8b 45 0c             	mov    0xc(%ebp),%eax
 47c:	f7 d8                	neg    %eax
 47e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 481:	eb 06                	jmp    489 <printint+0x34>
  } else {
    x = xx;
 483:	8b 45 0c             	mov    0xc(%ebp),%eax
 486:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 489:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 490:	8b 4d 10             	mov    0x10(%ebp),%ecx
 493:	8b 45 ec             	mov    -0x14(%ebp),%eax
 496:	ba 00 00 00 00       	mov    $0x0,%edx
 49b:	f7 f1                	div    %ecx
 49d:	89 d1                	mov    %edx,%ecx
 49f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a2:	8d 50 01             	lea    0x1(%eax),%edx
 4a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4a8:	0f b6 91 94 0b 00 00 	movzbl 0xb94(%ecx),%edx
 4af:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b9:	ba 00 00 00 00       	mov    $0x0,%edx
 4be:	f7 f1                	div    %ecx
 4c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c7:	75 c7                	jne    490 <printint+0x3b>
  if(neg)
 4c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4cd:	74 2d                	je     4fc <printint+0xa7>
    buf[i++] = '-';
 4cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d2:	8d 50 01             	lea    0x1(%eax),%edx
 4d5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4d8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4dd:	eb 1d                	jmp    4fc <printint+0xa7>
    putc(fd, buf[i]);
 4df:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e5:	01 d0                	add    %edx,%eax
 4e7:	0f b6 00             	movzbl (%eax),%eax
 4ea:	0f be c0             	movsbl %al,%eax
 4ed:	83 ec 08             	sub    $0x8,%esp
 4f0:	50                   	push   %eax
 4f1:	ff 75 08             	pushl  0x8(%ebp)
 4f4:	e8 35 ff ff ff       	call   42e <putc>
 4f9:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4fc:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 500:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 504:	79 d9                	jns    4df <printint+0x8a>
}
 506:	90                   	nop
 507:	90                   	nop
 508:	c9                   	leave  
 509:	c3                   	ret    

0000050a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 50a:	f3 0f 1e fb          	endbr32 
 50e:	55                   	push   %ebp
 50f:	89 e5                	mov    %esp,%ebp
 511:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 514:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 51b:	8d 45 0c             	lea    0xc(%ebp),%eax
 51e:	83 c0 04             	add    $0x4,%eax
 521:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 524:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 52b:	e9 59 01 00 00       	jmp    689 <printf+0x17f>
    c = fmt[i] & 0xff;
 530:	8b 55 0c             	mov    0xc(%ebp),%edx
 533:	8b 45 f0             	mov    -0x10(%ebp),%eax
 536:	01 d0                	add    %edx,%eax
 538:	0f b6 00             	movzbl (%eax),%eax
 53b:	0f be c0             	movsbl %al,%eax
 53e:	25 ff 00 00 00       	and    $0xff,%eax
 543:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 546:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 54a:	75 2c                	jne    578 <printf+0x6e>
      if(c == '%'){
 54c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 550:	75 0c                	jne    55e <printf+0x54>
        state = '%';
 552:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 559:	e9 27 01 00 00       	jmp    685 <printf+0x17b>
      } else {
        putc(fd, c);
 55e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 561:	0f be c0             	movsbl %al,%eax
 564:	83 ec 08             	sub    $0x8,%esp
 567:	50                   	push   %eax
 568:	ff 75 08             	pushl  0x8(%ebp)
 56b:	e8 be fe ff ff       	call   42e <putc>
 570:	83 c4 10             	add    $0x10,%esp
 573:	e9 0d 01 00 00       	jmp    685 <printf+0x17b>
      }
    } else if(state == '%'){
 578:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 57c:	0f 85 03 01 00 00    	jne    685 <printf+0x17b>
      if(c == 'd'){
 582:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 586:	75 1e                	jne    5a6 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 588:	8b 45 e8             	mov    -0x18(%ebp),%eax
 58b:	8b 00                	mov    (%eax),%eax
 58d:	6a 01                	push   $0x1
 58f:	6a 0a                	push   $0xa
 591:	50                   	push   %eax
 592:	ff 75 08             	pushl  0x8(%ebp)
 595:	e8 bb fe ff ff       	call   455 <printint>
 59a:	83 c4 10             	add    $0x10,%esp
        ap++;
 59d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a1:	e9 d8 00 00 00       	jmp    67e <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 5a6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5aa:	74 06                	je     5b2 <printf+0xa8>
 5ac:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b0:	75 1e                	jne    5d0 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 5b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b5:	8b 00                	mov    (%eax),%eax
 5b7:	6a 00                	push   $0x0
 5b9:	6a 10                	push   $0x10
 5bb:	50                   	push   %eax
 5bc:	ff 75 08             	pushl  0x8(%ebp)
 5bf:	e8 91 fe ff ff       	call   455 <printint>
 5c4:	83 c4 10             	add    $0x10,%esp
        ap++;
 5c7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5cb:	e9 ae 00 00 00       	jmp    67e <printf+0x174>
      } else if(c == 's'){
 5d0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5d4:	75 43                	jne    619 <printf+0x10f>
        s = (char*)*ap;
 5d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d9:	8b 00                	mov    (%eax),%eax
 5db:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5e6:	75 25                	jne    60d <printf+0x103>
          s = "(null)";
 5e8:	c7 45 f4 40 09 00 00 	movl   $0x940,-0xc(%ebp)
        while(*s != 0){
 5ef:	eb 1c                	jmp    60d <printf+0x103>
          putc(fd, *s);
 5f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f4:	0f b6 00             	movzbl (%eax),%eax
 5f7:	0f be c0             	movsbl %al,%eax
 5fa:	83 ec 08             	sub    $0x8,%esp
 5fd:	50                   	push   %eax
 5fe:	ff 75 08             	pushl  0x8(%ebp)
 601:	e8 28 fe ff ff       	call   42e <putc>
 606:	83 c4 10             	add    $0x10,%esp
          s++;
 609:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 60d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 610:	0f b6 00             	movzbl (%eax),%eax
 613:	84 c0                	test   %al,%al
 615:	75 da                	jne    5f1 <printf+0xe7>
 617:	eb 65                	jmp    67e <printf+0x174>
        }
      } else if(c == 'c'){
 619:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 61d:	75 1d                	jne    63c <printf+0x132>
        putc(fd, *ap);
 61f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 622:	8b 00                	mov    (%eax),%eax
 624:	0f be c0             	movsbl %al,%eax
 627:	83 ec 08             	sub    $0x8,%esp
 62a:	50                   	push   %eax
 62b:	ff 75 08             	pushl  0x8(%ebp)
 62e:	e8 fb fd ff ff       	call   42e <putc>
 633:	83 c4 10             	add    $0x10,%esp
        ap++;
 636:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 63a:	eb 42                	jmp    67e <printf+0x174>
      } else if(c == '%'){
 63c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 640:	75 17                	jne    659 <printf+0x14f>
        putc(fd, c);
 642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 645:	0f be c0             	movsbl %al,%eax
 648:	83 ec 08             	sub    $0x8,%esp
 64b:	50                   	push   %eax
 64c:	ff 75 08             	pushl  0x8(%ebp)
 64f:	e8 da fd ff ff       	call   42e <putc>
 654:	83 c4 10             	add    $0x10,%esp
 657:	eb 25                	jmp    67e <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 659:	83 ec 08             	sub    $0x8,%esp
 65c:	6a 25                	push   $0x25
 65e:	ff 75 08             	pushl  0x8(%ebp)
 661:	e8 c8 fd ff ff       	call   42e <putc>
 666:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 669:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66c:	0f be c0             	movsbl %al,%eax
 66f:	83 ec 08             	sub    $0x8,%esp
 672:	50                   	push   %eax
 673:	ff 75 08             	pushl  0x8(%ebp)
 676:	e8 b3 fd ff ff       	call   42e <putc>
 67b:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 67e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 685:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 689:	8b 55 0c             	mov    0xc(%ebp),%edx
 68c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 68f:	01 d0                	add    %edx,%eax
 691:	0f b6 00             	movzbl (%eax),%eax
 694:	84 c0                	test   %al,%al
 696:	0f 85 94 fe ff ff    	jne    530 <printf+0x26>
    }
  }
}
 69c:	90                   	nop
 69d:	90                   	nop
 69e:	c9                   	leave  
 69f:	c3                   	ret    

000006a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a0:	f3 0f 1e fb          	endbr32 
 6a4:	55                   	push   %ebp
 6a5:	89 e5                	mov    %esp,%ebp
 6a7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6aa:	8b 45 08             	mov    0x8(%ebp),%eax
 6ad:	83 e8 08             	sub    $0x8,%eax
 6b0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b3:	a1 b0 0b 00 00       	mov    0xbb0,%eax
 6b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6bb:	eb 24                	jmp    6e1 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6c5:	72 12                	jb     6d9 <free+0x39>
 6c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ca:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6cd:	77 24                	ja     6f3 <free+0x53>
 6cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d2:	8b 00                	mov    (%eax),%eax
 6d4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6d7:	72 1a                	jb     6f3 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e7:	76 d4                	jbe    6bd <free+0x1d>
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8b 00                	mov    (%eax),%eax
 6ee:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6f1:	73 ca                	jae    6bd <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f6:	8b 40 04             	mov    0x4(%eax),%eax
 6f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 700:	8b 45 f8             	mov    -0x8(%ebp),%eax
 703:	01 c2                	add    %eax,%edx
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	8b 00                	mov    (%eax),%eax
 70a:	39 c2                	cmp    %eax,%edx
 70c:	75 24                	jne    732 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 70e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 711:	8b 50 04             	mov    0x4(%eax),%edx
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	8b 00                	mov    (%eax),%eax
 719:	8b 40 04             	mov    0x4(%eax),%eax
 71c:	01 c2                	add    %eax,%edx
 71e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 721:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	8b 10                	mov    (%eax),%edx
 72b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72e:	89 10                	mov    %edx,(%eax)
 730:	eb 0a                	jmp    73c <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 732:	8b 45 fc             	mov    -0x4(%ebp),%eax
 735:	8b 10                	mov    (%eax),%edx
 737:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 73c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73f:	8b 40 04             	mov    0x4(%eax),%eax
 742:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 749:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74c:	01 d0                	add    %edx,%eax
 74e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 751:	75 20                	jne    773 <free+0xd3>
    p->s.size += bp->s.size;
 753:	8b 45 fc             	mov    -0x4(%ebp),%eax
 756:	8b 50 04             	mov    0x4(%eax),%edx
 759:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75c:	8b 40 04             	mov    0x4(%eax),%eax
 75f:	01 c2                	add    %eax,%edx
 761:	8b 45 fc             	mov    -0x4(%ebp),%eax
 764:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 767:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76a:	8b 10                	mov    (%eax),%edx
 76c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76f:	89 10                	mov    %edx,(%eax)
 771:	eb 08                	jmp    77b <free+0xdb>
  } else
    p->s.ptr = bp;
 773:	8b 45 fc             	mov    -0x4(%ebp),%eax
 776:	8b 55 f8             	mov    -0x8(%ebp),%edx
 779:	89 10                	mov    %edx,(%eax)
  freep = p;
 77b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77e:	a3 b0 0b 00 00       	mov    %eax,0xbb0
}
 783:	90                   	nop
 784:	c9                   	leave  
 785:	c3                   	ret    

00000786 <morecore>:

static Header*
morecore(uint nu)
{
 786:	f3 0f 1e fb          	endbr32 
 78a:	55                   	push   %ebp
 78b:	89 e5                	mov    %esp,%ebp
 78d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 790:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 797:	77 07                	ja     7a0 <morecore+0x1a>
    nu = 4096;
 799:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7a0:	8b 45 08             	mov    0x8(%ebp),%eax
 7a3:	c1 e0 03             	shl    $0x3,%eax
 7a6:	83 ec 0c             	sub    $0xc,%esp
 7a9:	50                   	push   %eax
 7aa:	e8 57 fc ff ff       	call   406 <sbrk>
 7af:	83 c4 10             	add    $0x10,%esp
 7b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7b5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7b9:	75 07                	jne    7c2 <morecore+0x3c>
    return 0;
 7bb:	b8 00 00 00 00       	mov    $0x0,%eax
 7c0:	eb 26                	jmp    7e8 <morecore+0x62>
  hp = (Header*)p;
 7c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cb:	8b 55 08             	mov    0x8(%ebp),%edx
 7ce:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d4:	83 c0 08             	add    $0x8,%eax
 7d7:	83 ec 0c             	sub    $0xc,%esp
 7da:	50                   	push   %eax
 7db:	e8 c0 fe ff ff       	call   6a0 <free>
 7e0:	83 c4 10             	add    $0x10,%esp
  return freep;
 7e3:	a1 b0 0b 00 00       	mov    0xbb0,%eax
}
 7e8:	c9                   	leave  
 7e9:	c3                   	ret    

000007ea <malloc>:

void*
malloc(uint nbytes)
{
 7ea:	f3 0f 1e fb          	endbr32 
 7ee:	55                   	push   %ebp
 7ef:	89 e5                	mov    %esp,%ebp
 7f1:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f4:	8b 45 08             	mov    0x8(%ebp),%eax
 7f7:	83 c0 07             	add    $0x7,%eax
 7fa:	c1 e8 03             	shr    $0x3,%eax
 7fd:	83 c0 01             	add    $0x1,%eax
 800:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 803:	a1 b0 0b 00 00       	mov    0xbb0,%eax
 808:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 80f:	75 23                	jne    834 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 811:	c7 45 f0 a8 0b 00 00 	movl   $0xba8,-0x10(%ebp)
 818:	8b 45 f0             	mov    -0x10(%ebp),%eax
 81b:	a3 b0 0b 00 00       	mov    %eax,0xbb0
 820:	a1 b0 0b 00 00       	mov    0xbb0,%eax
 825:	a3 a8 0b 00 00       	mov    %eax,0xba8
    base.s.size = 0;
 82a:	c7 05 ac 0b 00 00 00 	movl   $0x0,0xbac
 831:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 834:	8b 45 f0             	mov    -0x10(%ebp),%eax
 837:	8b 00                	mov    (%eax),%eax
 839:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	8b 40 04             	mov    0x4(%eax),%eax
 842:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 845:	77 4d                	ja     894 <malloc+0xaa>
      if(p->s.size == nunits)
 847:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84a:	8b 40 04             	mov    0x4(%eax),%eax
 84d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 850:	75 0c                	jne    85e <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 852:	8b 45 f4             	mov    -0xc(%ebp),%eax
 855:	8b 10                	mov    (%eax),%edx
 857:	8b 45 f0             	mov    -0x10(%ebp),%eax
 85a:	89 10                	mov    %edx,(%eax)
 85c:	eb 26                	jmp    884 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 85e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 861:	8b 40 04             	mov    0x4(%eax),%eax
 864:	2b 45 ec             	sub    -0x14(%ebp),%eax
 867:	89 c2                	mov    %eax,%edx
 869:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 86f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 872:	8b 40 04             	mov    0x4(%eax),%eax
 875:	c1 e0 03             	shl    $0x3,%eax
 878:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 87b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 881:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 884:	8b 45 f0             	mov    -0x10(%ebp),%eax
 887:	a3 b0 0b 00 00       	mov    %eax,0xbb0
      return (void*)(p + 1);
 88c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88f:	83 c0 08             	add    $0x8,%eax
 892:	eb 3b                	jmp    8cf <malloc+0xe5>
    }
    if(p == freep)
 894:	a1 b0 0b 00 00       	mov    0xbb0,%eax
 899:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 89c:	75 1e                	jne    8bc <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 89e:	83 ec 0c             	sub    $0xc,%esp
 8a1:	ff 75 ec             	pushl  -0x14(%ebp)
 8a4:	e8 dd fe ff ff       	call   786 <morecore>
 8a9:	83 c4 10             	add    $0x10,%esp
 8ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8b3:	75 07                	jne    8bc <malloc+0xd2>
        return 0;
 8b5:	b8 00 00 00 00       	mov    $0x0,%eax
 8ba:	eb 13                	jmp    8cf <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c5:	8b 00                	mov    (%eax),%eax
 8c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8ca:	e9 6d ff ff ff       	jmp    83c <malloc+0x52>
  }
}
 8cf:	c9                   	leave  
 8d0:	c3                   	ret    
