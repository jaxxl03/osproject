
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 60 e3 18 80       	mov    $0x8018e360,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba ae 34 10 80       	mov    $0x801034ae,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	f3 0f 1e fb          	endbr32 
8010006a:	55                   	push   %ebp
8010006b:	89 e5                	mov    %esp,%ebp
8010006d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
80100070:	83 ec 08             	sub    $0x8,%esp
80100073:	68 40 a3 10 80       	push   $0x8010a340
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 1d 48 00 00       	call   8010489f <initlock>
80100082:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100085:	c7 05 ac 2a 19 80 5c 	movl   $0x80192a5c,0x80192aac
8010008c:	2a 19 80 
  bcache.head.next = &bcache.head;
8010008f:	c7 05 b0 2a 19 80 5c 	movl   $0x80192a5c,0x80192ab0
80100096:	2a 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100099:	c7 45 f4 94 e3 18 80 	movl   $0x8018e394,-0xc(%ebp)
801000a0:	eb 47                	jmp    801000e9 <binit+0x83>
    b->next = bcache.head.next;
801000a2:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b1:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000bb:	83 c0 0c             	add    $0xc,%eax
801000be:	83 ec 08             	sub    $0x8,%esp
801000c1:	68 47 a3 10 80       	push   $0x8010a347
801000c6:	50                   	push   %eax
801000c7:	e8 66 46 00 00       	call   80104732 <initsleeplock>
801000cc:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cf:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
801000d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d7:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000dd:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000e2:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e9:	b8 5c 2a 19 80       	mov    $0x80192a5c,%eax
801000ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000f1:	72 af                	jb     801000a2 <binit+0x3c>
  }
}
801000f3:	90                   	nop
801000f4:	90                   	nop
801000f5:	c9                   	leave  
801000f6:	c3                   	ret    

801000f7 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f7:	f3 0f 1e fb          	endbr32 
801000fb:	55                   	push   %ebp
801000fc:	89 e5                	mov    %esp,%ebp
801000fe:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
80100101:	83 ec 0c             	sub    $0xc,%esp
80100104:	68 60 e3 18 80       	push   $0x8018e360
80100109:	e8 b7 47 00 00       	call   801048c5 <acquire>
8010010e:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100111:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100116:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100119:	eb 58                	jmp    80100173 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
8010011b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011e:	8b 40 04             	mov    0x4(%eax),%eax
80100121:	39 45 08             	cmp    %eax,0x8(%ebp)
80100124:	75 44                	jne    8010016a <bget+0x73>
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 08             	mov    0x8(%eax),%eax
8010012c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010012f:	75 39                	jne    8010016a <bget+0x73>
      b->refcnt++;
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 4c             	mov    0x4c(%eax),%eax
80100137:	8d 50 01             	lea    0x1(%eax),%edx
8010013a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013d:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100140:	83 ec 0c             	sub    $0xc,%esp
80100143:	68 60 e3 18 80       	push   $0x8018e360
80100148:	e8 ea 47 00 00       	call   80104937 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 13 46 00 00       	call   80104772 <acquiresleep>
8010015f:	83 c4 10             	add    $0x10,%esp
      return b;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	e9 9d 00 00 00       	jmp    80100207 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 40 54             	mov    0x54(%eax),%eax
80100170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100173:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
8010017a:	75 9f                	jne    8010011b <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010017c:	a1 ac 2a 19 80       	mov    0x80192aac,%eax
80100181:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100184:	eb 6b                	jmp    801001f1 <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 4c             	mov    0x4c(%eax),%eax
8010018c:	85 c0                	test   %eax,%eax
8010018e:	75 58                	jne    801001e8 <bget+0xf1>
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	8b 00                	mov    (%eax),%eax
80100195:	83 e0 04             	and    $0x4,%eax
80100198:	85 c0                	test   %eax,%eax
8010019a:	75 4c                	jne    801001e8 <bget+0xf1>
      b->dev = dev;
8010019c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019f:	8b 55 08             	mov    0x8(%ebp),%edx
801001a2:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
801001a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801001ab:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ba:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001c1:	83 ec 0c             	sub    $0xc,%esp
801001c4:	68 60 e3 18 80       	push   $0x8018e360
801001c9:	e8 69 47 00 00       	call   80104937 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 92 45 00 00       	call   80104772 <acquiresleep>
801001e0:	83 c4 10             	add    $0x10,%esp
      return b;
801001e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e6:	eb 1f                	jmp    80100207 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 40 50             	mov    0x50(%eax),%eax
801001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001f1:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
801001f8:	75 8c                	jne    80100186 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001fa:	83 ec 0c             	sub    $0xc,%esp
801001fd:	68 4e a3 10 80       	push   $0x8010a34e
80100202:	e8 be 03 00 00       	call   801005c5 <panic>
}
80100207:	c9                   	leave  
80100208:	c3                   	ret    

80100209 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100209:	f3 0f 1e fb          	endbr32 
8010020d:	55                   	push   %ebp
8010020e:	89 e5                	mov    %esp,%ebp
80100210:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100213:	83 ec 08             	sub    $0x8,%esp
80100216:	ff 75 0c             	pushl  0xc(%ebp)
80100219:	ff 75 08             	pushl  0x8(%ebp)
8010021c:	e8 d6 fe ff ff       	call   801000f7 <bget>
80100221:	83 c4 10             	add    $0x10,%esp
80100224:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
80100227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010022a:	8b 00                	mov    (%eax),%eax
8010022c:	83 e0 02             	and    $0x2,%eax
8010022f:	85 c0                	test   %eax,%eax
80100231:	75 0e                	jne    80100241 <bread+0x38>
    iderw(b);
80100233:	83 ec 0c             	sub    $0xc,%esp
80100236:	ff 75 f4             	pushl  -0xc(%ebp)
80100239:	e8 01 a0 00 00       	call   8010a23f <iderw>
8010023e:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100241:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100244:	c9                   	leave  
80100245:	c3                   	ret    

80100246 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100246:	f3 0f 1e fb          	endbr32 
8010024a:	55                   	push   %ebp
8010024b:	89 e5                	mov    %esp,%ebp
8010024d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	50                   	push   %eax
8010025a:	e8 cd 45 00 00       	call   8010482c <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 5f a3 10 80       	push   $0x8010a35f
8010026e:	e8 52 03 00 00       	call   801005c5 <panic>
  b->flags |= B_DIRTY;
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	8b 00                	mov    (%eax),%eax
80100278:	83 c8 04             	or     $0x4,%eax
8010027b:	89 c2                	mov    %eax,%edx
8010027d:	8b 45 08             	mov    0x8(%ebp),%eax
80100280:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100282:	83 ec 0c             	sub    $0xc,%esp
80100285:	ff 75 08             	pushl  0x8(%ebp)
80100288:	e8 b2 9f 00 00       	call   8010a23f <iderw>
8010028d:	83 c4 10             	add    $0x10,%esp
}
80100290:	90                   	nop
80100291:	c9                   	leave  
80100292:	c3                   	ret    

80100293 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100293:	f3 0f 1e fb          	endbr32 
80100297:	55                   	push   %ebp
80100298:	89 e5                	mov    %esp,%ebp
8010029a:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	83 c0 0c             	add    $0xc,%eax
801002a3:	83 ec 0c             	sub    $0xc,%esp
801002a6:	50                   	push   %eax
801002a7:	e8 80 45 00 00       	call   8010482c <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 66 a3 10 80       	push   $0x8010a366
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 0b 45 00 00       	call   801047da <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 e6 45 00 00       	call   801048c5 <acquire>
801002df:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002e2:	8b 45 08             	mov    0x8(%ebp),%eax
801002e5:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801002eb:	8b 45 08             	mov    0x8(%ebp),%eax
801002ee:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002f1:	8b 45 08             	mov    0x8(%ebp),%eax
801002f4:	8b 40 4c             	mov    0x4c(%eax),%eax
801002f7:	85 c0                	test   %eax,%eax
801002f9:	75 47                	jne    80100342 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002fb:	8b 45 08             	mov    0x8(%ebp),%eax
801002fe:	8b 40 54             	mov    0x54(%eax),%eax
80100301:	8b 55 08             	mov    0x8(%ebp),%edx
80100304:	8b 52 50             	mov    0x50(%edx),%edx
80100307:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	8b 40 50             	mov    0x50(%eax),%eax
80100310:	8b 55 08             	mov    0x8(%ebp),%edx
80100313:	8b 52 54             	mov    0x54(%edx),%edx
80100316:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100319:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
8010031f:	8b 45 08             	mov    0x8(%ebp),%eax
80100322:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    bcache.head.next->prev = b;
8010032f:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100334:	8b 55 08             	mov    0x8(%ebp),%edx
80100337:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  }
  
  release(&bcache.lock);
80100342:	83 ec 0c             	sub    $0xc,%esp
80100345:	68 60 e3 18 80       	push   $0x8018e360
8010034a:	e8 e8 45 00 00       	call   80104937 <release>
8010034f:	83 c4 10             	add    $0x10,%esp
}
80100352:	90                   	nop
80100353:	c9                   	leave  
80100354:	c3                   	ret    

80100355 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100355:	55                   	push   %ebp
80100356:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100358:	fa                   	cli    
}
80100359:	90                   	nop
8010035a:	5d                   	pop    %ebp
8010035b:	c3                   	ret    

8010035c <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
8010035c:	f3 0f 1e fb          	endbr32 
80100360:	55                   	push   %ebp
80100361:	89 e5                	mov    %esp,%ebp
80100363:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100366:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010036a:	74 1c                	je     80100388 <printint+0x2c>
8010036c:	8b 45 08             	mov    0x8(%ebp),%eax
8010036f:	c1 e8 1f             	shr    $0x1f,%eax
80100372:	0f b6 c0             	movzbl %al,%eax
80100375:	89 45 10             	mov    %eax,0x10(%ebp)
80100378:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010037c:	74 0a                	je     80100388 <printint+0x2c>
    x = -xx;
8010037e:	8b 45 08             	mov    0x8(%ebp),%eax
80100381:	f7 d8                	neg    %eax
80100383:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100386:	eb 06                	jmp    8010038e <printint+0x32>
  else
    x = xx;
80100388:	8b 45 08             	mov    0x8(%ebp),%eax
8010038b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010038e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100395:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010039b:	ba 00 00 00 00       	mov    $0x0,%edx
801003a0:	f7 f1                	div    %ecx
801003a2:	89 d1                	mov    %edx,%ecx
801003a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a7:	8d 50 01             	lea    0x1(%eax),%edx
801003aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003ad:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
801003b4:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003be:	ba 00 00 00 00       	mov    $0x0,%edx
801003c3:	f7 f1                	div    %ecx
801003c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003cc:	75 c7                	jne    80100395 <printint+0x39>

  if(sign)
801003ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003d2:	74 2a                	je     801003fe <printint+0xa2>
    buf[i++] = '-';
801003d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d7:	8d 50 01             	lea    0x1(%eax),%edx
801003da:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003dd:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003e2:	eb 1a                	jmp    801003fe <printint+0xa2>
    consputc(buf[i]);
801003e4:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003ea:	01 d0                	add    %edx,%eax
801003ec:	0f b6 00             	movzbl (%eax),%eax
801003ef:	0f be c0             	movsbl %al,%eax
801003f2:	83 ec 0c             	sub    $0xc,%esp
801003f5:	50                   	push   %eax
801003f6:	e8 9a 03 00 00       	call   80100795 <consputc>
801003fb:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003fe:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100402:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100406:	79 dc                	jns    801003e4 <printint+0x88>
}
80100408:	90                   	nop
80100409:	90                   	nop
8010040a:	c9                   	leave  
8010040b:	c3                   	ret    

8010040c <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
8010040c:	f3 0f 1e fb          	endbr32 
80100410:	55                   	push   %ebp
80100411:	89 e5                	mov    %esp,%ebp
80100413:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100416:	a1 54 d0 18 80       	mov    0x8018d054,%eax
8010041b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010041e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100422:	74 10                	je     80100434 <cprintf+0x28>
    acquire(&cons.lock);
80100424:	83 ec 0c             	sub    $0xc,%esp
80100427:	68 20 d0 18 80       	push   $0x8018d020
8010042c:	e8 94 44 00 00       	call   801048c5 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 6d a3 10 80       	push   $0x8010a36d
80100443:	e8 7d 01 00 00       	call   801005c5 <panic>


  argp = (uint*)(void*)(&fmt + 1);
80100448:	8d 45 0c             	lea    0xc(%ebp),%eax
8010044b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010044e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100455:	e9 2f 01 00 00       	jmp    80100589 <cprintf+0x17d>
    if(c != '%'){
8010045a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010045e:	74 13                	je     80100473 <cprintf+0x67>
      consputc(c);
80100460:	83 ec 0c             	sub    $0xc,%esp
80100463:	ff 75 e4             	pushl  -0x1c(%ebp)
80100466:	e8 2a 03 00 00       	call   80100795 <consputc>
8010046b:	83 c4 10             	add    $0x10,%esp
      continue;
8010046e:	e9 12 01 00 00       	jmp    80100585 <cprintf+0x179>
    }
    c = fmt[++i] & 0xff;
80100473:	8b 55 08             	mov    0x8(%ebp),%edx
80100476:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010047a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010047d:	01 d0                	add    %edx,%eax
8010047f:	0f b6 00             	movzbl (%eax),%eax
80100482:	0f be c0             	movsbl %al,%eax
80100485:	25 ff 00 00 00       	and    $0xff,%eax
8010048a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010048d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100491:	0f 84 14 01 00 00    	je     801005ab <cprintf+0x19f>
      break;
    switch(c){
80100497:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010049b:	74 5e                	je     801004fb <cprintf+0xef>
8010049d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004a1:	0f 8f c2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004a7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004ab:	74 6b                	je     80100518 <cprintf+0x10c>
801004ad:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004b1:	0f 8f b2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004b7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004bb:	74 3e                	je     801004fb <cprintf+0xef>
801004bd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004c1:	0f 8f a2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004cb:	0f 84 89 00 00 00    	je     8010055a <cprintf+0x14e>
801004d1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004d5:	0f 85 8e 00 00 00    	jne    80100569 <cprintf+0x15d>
    case 'd':
      printint(*argp++, 10, 1);
801004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004de:	8d 50 04             	lea    0x4(%eax),%edx
801004e1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e4:	8b 00                	mov    (%eax),%eax
801004e6:	83 ec 04             	sub    $0x4,%esp
801004e9:	6a 01                	push   $0x1
801004eb:	6a 0a                	push   $0xa
801004ed:	50                   	push   %eax
801004ee:	e8 69 fe ff ff       	call   8010035c <printint>
801004f3:	83 c4 10             	add    $0x10,%esp
      break;
801004f6:	e9 8a 00 00 00       	jmp    80100585 <cprintf+0x179>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fe:	8d 50 04             	lea    0x4(%eax),%edx
80100501:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100504:	8b 00                	mov    (%eax),%eax
80100506:	83 ec 04             	sub    $0x4,%esp
80100509:	6a 00                	push   $0x0
8010050b:	6a 10                	push   $0x10
8010050d:	50                   	push   %eax
8010050e:	e8 49 fe ff ff       	call   8010035c <printint>
80100513:	83 c4 10             	add    $0x10,%esp
      break;
80100516:	eb 6d                	jmp    80100585 <cprintf+0x179>
    case 's':
      if((s = (char*)*argp++) == 0)
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100526:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010052a:	75 22                	jne    8010054e <cprintf+0x142>
        s = "(null)";
8010052c:	c7 45 ec 76 a3 10 80 	movl   $0x8010a376,-0x14(%ebp)
      for(; *s; s++)
80100533:	eb 19                	jmp    8010054e <cprintf+0x142>
        consputc(*s);
80100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100538:	0f b6 00             	movzbl (%eax),%eax
8010053b:	0f be c0             	movsbl %al,%eax
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	50                   	push   %eax
80100542:	e8 4e 02 00 00       	call   80100795 <consputc>
80100547:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010054a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010054e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100551:	0f b6 00             	movzbl (%eax),%eax
80100554:	84 c0                	test   %al,%al
80100556:	75 dd                	jne    80100535 <cprintf+0x129>
      break;
80100558:	eb 2b                	jmp    80100585 <cprintf+0x179>
    case '%':
      consputc('%');
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	6a 25                	push   $0x25
8010055f:	e8 31 02 00 00       	call   80100795 <consputc>
80100564:	83 c4 10             	add    $0x10,%esp
      break;
80100567:	eb 1c                	jmp    80100585 <cprintf+0x179>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100569:	83 ec 0c             	sub    $0xc,%esp
8010056c:	6a 25                	push   $0x25
8010056e:	e8 22 02 00 00       	call   80100795 <consputc>
80100573:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100576:	83 ec 0c             	sub    $0xc,%esp
80100579:	ff 75 e4             	pushl  -0x1c(%ebp)
8010057c:	e8 14 02 00 00       	call   80100795 <consputc>
80100581:	83 c4 10             	add    $0x10,%esp
      break;
80100584:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100585:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100589:	8b 55 08             	mov    0x8(%ebp),%edx
8010058c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010058f:	01 d0                	add    %edx,%eax
80100591:	0f b6 00             	movzbl (%eax),%eax
80100594:	0f be c0             	movsbl %al,%eax
80100597:	25 ff 00 00 00       	and    $0xff,%eax
8010059c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010059f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005a3:	0f 85 b1 fe ff ff    	jne    8010045a <cprintf+0x4e>
801005a9:	eb 01                	jmp    801005ac <cprintf+0x1a0>
      break;
801005ab:	90                   	nop
    }
  }

  if(locking)
801005ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005b0:	74 10                	je     801005c2 <cprintf+0x1b6>
    release(&cons.lock);
801005b2:	83 ec 0c             	sub    $0xc,%esp
801005b5:	68 20 d0 18 80       	push   $0x8018d020
801005ba:	e8 78 43 00 00       	call   80104937 <release>
801005bf:	83 c4 10             	add    $0x10,%esp
}
801005c2:	90                   	nop
801005c3:	c9                   	leave  
801005c4:	c3                   	ret    

801005c5 <panic>:

void
panic(char *s)
{
801005c5:	f3 0f 1e fb          	endbr32 
801005c9:	55                   	push   %ebp
801005ca:	89 e5                	mov    %esp,%ebp
801005cc:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005cf:	e8 81 fd ff ff       	call   80100355 <cli>
  cons.locking = 0;
801005d4:	c7 05 54 d0 18 80 00 	movl   $0x0,0x8018d054
801005db:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005de:	e8 1c 26 00 00       	call   80102bff <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 7d a3 10 80       	push   $0x8010a37d
801005ec:	e8 1b fe ff ff       	call   8010040c <cprintf>
801005f1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005f4:	8b 45 08             	mov    0x8(%ebp),%eax
801005f7:	83 ec 0c             	sub    $0xc,%esp
801005fa:	50                   	push   %eax
801005fb:	e8 0c fe ff ff       	call   8010040c <cprintf>
80100600:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100603:	83 ec 0c             	sub    $0xc,%esp
80100606:	68 91 a3 10 80       	push   $0x8010a391
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 6a 43 00 00       	call   8010498d <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 93 a3 10 80       	push   $0x8010a393
8010063f:	e8 c8 fd ff ff       	call   8010040c <cprintf>
80100644:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100647:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010064b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010064f:	7e de                	jle    8010062f <panic+0x6a>
  panicked = 1; // freeze other CPU
80100651:	c7 05 00 d0 18 80 01 	movl   $0x1,0x8018d000
80100658:	00 00 00 
  for(;;)
8010065b:	eb fe                	jmp    8010065b <panic+0x96>

8010065d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010065d:	f3 0f 1e fb          	endbr32 
80100661:	55                   	push   %ebp
80100662:	89 e5                	mov    %esp,%ebp
80100664:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100667:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010066b:	75 64                	jne    801006d1 <graphic_putc+0x74>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010066d:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100673:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100678:	89 c8                	mov    %ecx,%eax
8010067a:	f7 ea                	imul   %edx
8010067c:	c1 fa 04             	sar    $0x4,%edx
8010067f:	89 c8                	mov    %ecx,%eax
80100681:	c1 f8 1f             	sar    $0x1f,%eax
80100684:	29 c2                	sub    %eax,%edx
80100686:	89 d0                	mov    %edx,%eax
80100688:	6b c0 35             	imul   $0x35,%eax,%eax
8010068b:	29 c1                	sub    %eax,%ecx
8010068d:	89 c8                	mov    %ecx,%eax
8010068f:	ba 35 00 00 00       	mov    $0x35,%edx
80100694:	29 c2                	sub    %eax,%edx
80100696:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010069b:	01 d0                	add    %edx,%eax
8010069d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006a2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006a7:	3d 23 04 00 00       	cmp    $0x423,%eax
801006ac:	0f 8e e0 00 00 00    	jle    80100792 <graphic_putc+0x135>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006b2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006b7:	83 e8 35             	sub    $0x35,%eax
801006ba:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006bf:	83 ec 0c             	sub    $0xc,%esp
801006c2:	6a 1e                	push   $0x1e
801006c4:	e8 0a 7a 00 00       	call   801080d3 <graphic_scroll_up>
801006c9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006cc:	e9 c1 00 00 00       	jmp    80100792 <graphic_putc+0x135>
  }else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 1f                	jne    801006f9 <graphic_putc+0x9c>
    if(console_pos>0) --console_pos;
801006da:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006df:	85 c0                	test   %eax,%eax
801006e1:	0f 8e ab 00 00 00    	jle    80100792 <graphic_putc+0x135>
801006e7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ec:	83 e8 01             	sub    $0x1,%eax
801006ef:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006f4:	e9 99 00 00 00       	jmp    80100792 <graphic_putc+0x135>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006f9:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006fe:	3d 23 04 00 00       	cmp    $0x423,%eax
80100703:	7e 1a                	jle    8010071f <graphic_putc+0xc2>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
80100705:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010070a:	83 e8 35             	sub    $0x35,%eax
8010070d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
80100712:	83 ec 0c             	sub    $0xc,%esp
80100715:	6a 1e                	push   $0x1e
80100717:	e8 b7 79 00 00       	call   801080d3 <graphic_scroll_up>
8010071c:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
8010071f:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100725:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010072a:	89 c8                	mov    %ecx,%eax
8010072c:	f7 ea                	imul   %edx
8010072e:	c1 fa 04             	sar    $0x4,%edx
80100731:	89 c8                	mov    %ecx,%eax
80100733:	c1 f8 1f             	sar    $0x1f,%eax
80100736:	29 c2                	sub    %eax,%edx
80100738:	89 d0                	mov    %edx,%eax
8010073a:	6b c0 35             	imul   $0x35,%eax,%eax
8010073d:	29 c1                	sub    %eax,%ecx
8010073f:	89 c8                	mov    %ecx,%eax
80100741:	89 c2                	mov    %eax,%edx
80100743:	c1 e2 04             	shl    $0x4,%edx
80100746:	29 c2                	sub    %eax,%edx
80100748:	89 d0                	mov    %edx,%eax
8010074a:	83 c0 02             	add    $0x2,%eax
8010074d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
80100750:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100756:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010075b:	89 c8                	mov    %ecx,%eax
8010075d:	f7 ea                	imul   %edx
8010075f:	c1 fa 04             	sar    $0x4,%edx
80100762:	89 c8                	mov    %ecx,%eax
80100764:	c1 f8 1f             	sar    $0x1f,%eax
80100767:	29 c2                	sub    %eax,%edx
80100769:	89 d0                	mov    %edx,%eax
8010076b:	6b c0 1e             	imul   $0x1e,%eax,%eax
8010076e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
80100771:	83 ec 04             	sub    $0x4,%esp
80100774:	ff 75 08             	pushl  0x8(%ebp)
80100777:	ff 75 f0             	pushl  -0x10(%ebp)
8010077a:	ff 75 f4             	pushl  -0xc(%ebp)
8010077d:	e8 c5 79 00 00       	call   80108147 <font_render>
80100782:	83 c4 10             	add    $0x10,%esp
    console_pos++;
80100785:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010078a:	83 c0 01             	add    $0x1,%eax
8010078d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
80100792:	90                   	nop
80100793:	c9                   	leave  
80100794:	c3                   	ret    

80100795 <consputc>:


void
consputc(int c)
{
80100795:	f3 0f 1e fb          	endbr32 
80100799:	55                   	push   %ebp
8010079a:	89 e5                	mov    %esp,%ebp
8010079c:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010079f:	a1 00 d0 18 80       	mov    0x8018d000,%eax
801007a4:	85 c0                	test   %eax,%eax
801007a6:	74 07                	je     801007af <consputc+0x1a>
    cli();
801007a8:	e8 a8 fb ff ff       	call   80100355 <cli>
    for(;;)
801007ad:	eb fe                	jmp    801007ad <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
801007af:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007b6:	75 29                	jne    801007e1 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b8:	83 ec 0c             	sub    $0xc,%esp
801007bb:	6a 08                	push   $0x8
801007bd:	e8 25 5d 00 00       	call   801064e7 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 18 5d 00 00       	call   801064e7 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 0b 5d 00 00       	call   801064e7 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 fb 5c 00 00       	call   801064e7 <uartputc>
801007ec:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007ef:	83 ec 0c             	sub    $0xc,%esp
801007f2:	ff 75 08             	pushl  0x8(%ebp)
801007f5:	e8 63 fe ff ff       	call   8010065d <graphic_putc>
801007fa:	83 c4 10             	add    $0x10,%esp
}
801007fd:	90                   	nop
801007fe:	c9                   	leave  
801007ff:	c3                   	ret    

80100800 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100800:	f3 0f 1e fb          	endbr32 
80100804:	55                   	push   %ebp
80100805:	89 e5                	mov    %esp,%ebp
80100807:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
8010080a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100811:	83 ec 0c             	sub    $0xc,%esp
80100814:	68 20 d0 18 80       	push   $0x8018d020
80100819:	e8 a7 40 00 00       	call   801048c5 <acquire>
8010081e:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100821:	e9 52 01 00 00       	jmp    80100978 <consoleintr+0x178>
    switch(c){
80100826:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010082a:	0f 84 81 00 00 00    	je     801008b1 <consoleintr+0xb1>
80100830:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100834:	0f 8f ac 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010083a:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010083e:	74 43                	je     80100883 <consoleintr+0x83>
80100840:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100844:	0f 8f 9c 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010084a:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
8010084e:	74 61                	je     801008b1 <consoleintr+0xb1>
80100850:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100854:	0f 85 8c 00 00 00    	jne    801008e6 <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010085a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100861:	e9 12 01 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100866:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010086b:	83 e8 01             	sub    $0x1,%eax
8010086e:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
80100873:	83 ec 0c             	sub    $0xc,%esp
80100876:	68 00 01 00 00       	push   $0x100
8010087b:	e8 15 ff ff ff       	call   80100795 <consputc>
80100880:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100883:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
80100889:	a1 44 2d 19 80       	mov    0x80192d44,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 e2 00 00 00    	je     80100978 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100896:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
      while(input.e != input.w &&
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 ba                	jne    80100866 <consoleintr+0x66>
      }
      break;
801008ac:	e9 c7 00 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008b7:	a1 44 2d 19 80       	mov    0x80192d44,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 b4 00 00 00    	je     80100978 <consoleintr+0x178>
        input.e--;
801008c4:	a1 48 2d 19 80       	mov    0x80192d48,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
801008d1:	83 ec 0c             	sub    $0xc,%esp
801008d4:	68 00 01 00 00       	push   $0x100
801008d9:	e8 b7 fe ff ff       	call   80100795 <consputc>
801008de:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008e1:	e9 92 00 00 00       	jmp    80100978 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008ea:	0f 84 87 00 00 00    	je     80100977 <consoleintr+0x177>
801008f0:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008f6:	a1 40 2d 19 80       	mov    0x80192d40,%eax
801008fb:	29 c2                	sub    %eax,%edx
801008fd:	89 d0                	mov    %edx,%eax
801008ff:	83 f8 7f             	cmp    $0x7f,%eax
80100902:	77 73                	ja     80100977 <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
80100904:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100908:	74 05                	je     8010090f <consoleintr+0x10f>
8010090a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010090d:	eb 05                	jmp    80100914 <consoleintr+0x114>
8010090f:	b8 0a 00 00 00       	mov    $0xa,%eax
80100914:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100917:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010091c:	8d 50 01             	lea    0x1(%eax),%edx
8010091f:	89 15 48 2d 19 80    	mov    %edx,0x80192d48
80100925:	83 e0 7f             	and    $0x7f,%eax
80100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010092b:	88 90 c0 2c 19 80    	mov    %dl,-0x7fe6d340(%eax)
        consputc(c);
80100931:	83 ec 0c             	sub    $0xc,%esp
80100934:	ff 75 f0             	pushl  -0x10(%ebp)
80100937:	e8 59 fe ff ff       	call   80100795 <consputc>
8010093c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010093f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100943:	74 18                	je     8010095d <consoleintr+0x15d>
80100945:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100949:	74 12                	je     8010095d <consoleintr+0x15d>
8010094b:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100950:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100956:	83 ea 80             	sub    $0xffffff80,%edx
80100959:	39 d0                	cmp    %edx,%eax
8010095b:	75 1a                	jne    80100977 <consoleintr+0x177>
          input.w = input.e;
8010095d:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100962:	a3 44 2d 19 80       	mov    %eax,0x80192d44
          wakeup(&input.r);
80100967:	83 ec 0c             	sub    $0xc,%esp
8010096a:	68 40 2d 19 80       	push   $0x80192d40
8010096f:	e8 fd 3b 00 00       	call   80104571 <wakeup>
80100974:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100977:	90                   	nop
  while((c = getc()) >= 0){
80100978:	8b 45 08             	mov    0x8(%ebp),%eax
8010097b:	ff d0                	call   *%eax
8010097d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100984:	0f 89 9c fe ff ff    	jns    80100826 <consoleintr+0x26>
    }
  }
  release(&cons.lock);
8010098a:	83 ec 0c             	sub    $0xc,%esp
8010098d:	68 20 d0 18 80       	push   $0x8018d020
80100992:	e8 a0 3f 00 00       	call   80104937 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 8f 3c 00 00       	call   80104634 <procdump>
  }
}
801009a5:	90                   	nop
801009a6:	c9                   	leave  
801009a7:	c3                   	ret    

801009a8 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009a8:	f3 0f 1e fb          	endbr32 
801009ac:	55                   	push   %ebp
801009ad:	89 e5                	mov    %esp,%ebp
801009af:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009b2:	83 ec 0c             	sub    $0xc,%esp
801009b5:	ff 75 08             	pushl  0x8(%ebp)
801009b8:	e8 d6 11 00 00       	call   80101b93 <iunlock>
801009bd:	83 c4 10             	add    $0x10,%esp
  target = n;
801009c0:	8b 45 10             	mov    0x10(%ebp),%eax
801009c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	68 20 d0 18 80       	push   $0x8018d020
801009ce:	e8 f2 3e 00 00       	call   801048c5 <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 c9 31 00 00       	call   80103ba9 <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 d0 18 80       	push   $0x8018d020
801009ef:	e8 43 3f 00 00       	call   80104937 <release>
801009f4:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	pushl  0x8(%ebp)
801009fd:	e8 7a 10 00 00       	call   80101a7c <ilock>
80100a02:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a0a:	e9 ab 00 00 00       	jmp    80100aba <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a0f:	83 ec 08             	sub    $0x8,%esp
80100a12:	68 20 d0 18 80       	push   $0x8018d020
80100a17:	68 40 2d 19 80       	push   $0x80192d40
80100a1c:	e8 61 3a 00 00       	call   80104482 <sleep>
80100a21:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a24:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100a2a:	a1 44 2d 19 80       	mov    0x80192d44,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 a8                	je     801009db <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a33:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a38:	8d 50 01             	lea    0x1(%eax),%edx
80100a3b:	89 15 40 2d 19 80    	mov    %edx,0x80192d40
80100a41:	83 e0 7f             	and    $0x7f,%eax
80100a44:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a51:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a55:	75 17                	jne    80100a6e <consoleread+0xc6>
      if(n < target){
80100a57:	8b 45 10             	mov    0x10(%ebp),%eax
80100a5a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a5d:	76 2f                	jbe    80100a8e <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a5f:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a64:	83 e8 01             	sub    $0x1,%eax
80100a67:	a3 40 2d 19 80       	mov    %eax,0x80192d40
      }
      break;
80100a6c:	eb 20                	jmp    80100a8e <consoleread+0xe6>
    }
    *dst++ = c;
80100a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a71:	8d 50 01             	lea    0x1(%eax),%edx
80100a74:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a7a:	88 10                	mov    %dl,(%eax)
    --n;
80100a7c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a80:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a84:	74 0b                	je     80100a91 <consoleread+0xe9>
  while(n > 0){
80100a86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a8a:	7f 98                	jg     80100a24 <consoleread+0x7c>
80100a8c:	eb 04                	jmp    80100a92 <consoleread+0xea>
      break;
80100a8e:	90                   	nop
80100a8f:	eb 01                	jmp    80100a92 <consoleread+0xea>
      break;
80100a91:	90                   	nop
  }
  release(&cons.lock);
80100a92:	83 ec 0c             	sub    $0xc,%esp
80100a95:	68 20 d0 18 80       	push   $0x8018d020
80100a9a:	e8 98 3e 00 00       	call   80104937 <release>
80100a9f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aa2:	83 ec 0c             	sub    $0xc,%esp
80100aa5:	ff 75 08             	pushl  0x8(%ebp)
80100aa8:	e8 cf 0f 00 00       	call   80101a7c <ilock>
80100aad:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ab0:	8b 45 10             	mov    0x10(%ebp),%eax
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	29 c2                	sub    %eax,%edx
80100ab8:	89 d0                	mov    %edx,%eax
}
80100aba:	c9                   	leave  
80100abb:	c3                   	ret    

80100abc <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100abc:	f3 0f 1e fb          	endbr32 
80100ac0:	55                   	push   %ebp
80100ac1:	89 e5                	mov    %esp,%ebp
80100ac3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	ff 75 08             	pushl  0x8(%ebp)
80100acc:	e8 c2 10 00 00       	call   80101b93 <iunlock>
80100ad1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ad4:	83 ec 0c             	sub    $0xc,%esp
80100ad7:	68 20 d0 18 80       	push   $0x8018d020
80100adc:	e8 e4 3d 00 00       	call   801048c5 <acquire>
80100ae1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ae4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100aeb:	eb 21                	jmp    80100b0e <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100aed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af3:	01 d0                	add    %edx,%eax
80100af5:	0f b6 00             	movzbl (%eax),%eax
80100af8:	0f be c0             	movsbl %al,%eax
80100afb:	0f b6 c0             	movzbl %al,%eax
80100afe:	83 ec 0c             	sub    $0xc,%esp
80100b01:	50                   	push   %eax
80100b02:	e8 8e fc ff ff       	call   80100795 <consputc>
80100b07:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b11:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b14:	7c d7                	jl     80100aed <consolewrite+0x31>
  release(&cons.lock);
80100b16:	83 ec 0c             	sub    $0xc,%esp
80100b19:	68 20 d0 18 80       	push   $0x8018d020
80100b1e:	e8 14 3e 00 00       	call   80104937 <release>
80100b23:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	ff 75 08             	pushl  0x8(%ebp)
80100b2c:	e8 4b 0f 00 00       	call   80101a7c <ilock>
80100b31:	83 c4 10             	add    $0x10,%esp

  return n;
80100b34:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b37:	c9                   	leave  
80100b38:	c3                   	ret    

80100b39 <consoleinit>:

void
consoleinit(void)
{
80100b39:	f3 0f 1e fb          	endbr32 
80100b3d:	55                   	push   %ebp
80100b3e:	89 e5                	mov    %esp,%ebp
80100b40:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b43:	c7 05 00 d0 18 80 00 	movl   $0x0,0x8018d000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 97 a3 10 80       	push   $0x8010a397
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 40 3d 00 00       	call   8010489f <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 9f a3 10 80 	movl   $0x8010a39f,-0xc(%ebp)
80100b7d:	eb 19                	jmp    80100b98 <consoleinit+0x5f>
    graphic_putc(*p);
80100b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b82:	0f b6 00             	movzbl (%eax),%eax
80100b85:	0f be c0             	movsbl %al,%eax
80100b88:	83 ec 0c             	sub    $0xc,%esp
80100b8b:	50                   	push   %eax
80100b8c:	e8 cc fa ff ff       	call   8010065d <graphic_putc>
80100b91:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b9b:	0f b6 00             	movzbl (%eax),%eax
80100b9e:	84 c0                	test   %al,%al
80100ba0:	75 dd                	jne    80100b7f <consoleinit+0x46>
  
  cons.locking = 1;
80100ba2:	c7 05 54 d0 18 80 01 	movl   $0x1,0x8018d054
80100ba9:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bac:	83 ec 08             	sub    $0x8,%esp
80100baf:	6a 00                	push   $0x0
80100bb1:	6a 01                	push   $0x1
80100bb3:	e8 54 1b 00 00       	call   8010270c <ioapicenable>
80100bb8:	83 c4 10             	add    $0x10,%esp
}
80100bbb:	90                   	nop
80100bbc:	c9                   	leave  
80100bbd:	c3                   	ret    

80100bbe <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bbe:	f3 0f 1e fb          	endbr32 
80100bc2:	55                   	push   %ebp
80100bc3:	89 e5                	mov    %esp,%ebp
80100bc5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bcb:	e8 d9 2f 00 00       	call   80103ba9 <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd3:	e8 99 25 00 00       	call   80103171 <begin_op>

  if((ip = namei(path)) == 0){
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	pushl  0x8(%ebp)
80100bde:	e8 04 1a 00 00       	call   801025e7 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
    end_op();
80100bef:	e8 0d 26 00 00       	call   80103201 <end_op>
    cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 b5 a3 10 80       	push   $0x8010a3b5
80100bfc:	e8 0b f8 ff ff       	call   8010040c <cprintf>
80100c01:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c09:	e9 f1 03 00 00       	jmp    80100fff <exec+0x441>
  }
  ilock(ip);
80100c0e:	83 ec 0c             	sub    $0xc,%esp
80100c11:	ff 75 d8             	pushl  -0x28(%ebp)
80100c14:	e8 63 0e 00 00       	call   80101a7c <ilock>
80100c19:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c1c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c2d:	50                   	push   %eax
80100c2e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c31:	e8 4e 13 00 00       	call   80101f84 <readi>
80100c36:	83 c4 10             	add    $0x10,%esp
80100c39:	83 f8 34             	cmp    $0x34,%eax
80100c3c:	0f 85 66 03 00 00    	jne    80100fa8 <exec+0x3ea>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c42:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c48:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4d:	0f 85 58 03 00 00    	jne    80100fab <exec+0x3ed>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c53:	e8 a3 68 00 00       	call   801074fb <setupkvm>
80100c58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c5f:	0f 84 49 03 00 00    	je     80100fae <exec+0x3f0>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c65:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c6c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c73:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c79:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7c:	e9 de 00 00 00       	jmp    80100d5f <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c84:	6a 20                	push   $0x20
80100c86:	50                   	push   %eax
80100c87:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c8d:	50                   	push   %eax
80100c8e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c91:	e8 ee 12 00 00       	call   80101f84 <readi>
80100c96:	83 c4 10             	add    $0x10,%esp
80100c99:	83 f8 20             	cmp    $0x20,%eax
80100c9c:	0f 85 0f 03 00 00    	jne    80100fb1 <exec+0x3f3>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ca2:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ca8:	83 f8 01             	cmp    $0x1,%eax
80100cab:	0f 85 a0 00 00 00    	jne    80100d51 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100cb1:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb7:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cbd:	39 c2                	cmp    %eax,%edx
80100cbf:	0f 82 ef 02 00 00    	jb     80100fb4 <exec+0x3f6>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cc5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd1:	01 c2                	add    %eax,%edx
80100cd3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd9:	39 c2                	cmp    %eax,%edx
80100cdb:	0f 82 d6 02 00 00    	jb     80100fb7 <exec+0x3f9>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ced:	01 d0                	add    %edx,%eax
80100cef:	83 ec 04             	sub    $0x4,%esp
80100cf2:	50                   	push   %eax
80100cf3:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf9:	e8 0f 6c 00 00       	call   8010790d <allocuvm>
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d08:	0f 84 ac 02 00 00    	je     80100fba <exec+0x3fc>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d0e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d14:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d19:	85 c0                	test   %eax,%eax
80100d1b:	0f 85 9c 02 00 00    	jne    80100fbd <exec+0x3ff>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d21:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d27:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2d:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d33:	83 ec 0c             	sub    $0xc,%esp
80100d36:	52                   	push   %edx
80100d37:	50                   	push   %eax
80100d38:	ff 75 d8             	pushl  -0x28(%ebp)
80100d3b:	51                   	push   %ecx
80100d3c:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d3f:	e8 f8 6a 00 00       	call   8010783c <loaduvm>
80100d44:	83 c4 20             	add    $0x20,%esp
80100d47:	85 c0                	test   %eax,%eax
80100d49:	0f 88 71 02 00 00    	js     80100fc0 <exec+0x402>
80100d4f:	eb 01                	jmp    80100d52 <exec+0x194>
      continue;
80100d51:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d52:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d59:	83 c0 20             	add    $0x20,%eax
80100d5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d5f:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d66:	0f b7 c0             	movzwl %ax,%eax
80100d69:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d6c:	0f 8c 0f ff ff ff    	jl     80100c81 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100d72:	83 ec 0c             	sub    $0xc,%esp
80100d75:	ff 75 d8             	pushl  -0x28(%ebp)
80100d78:	e8 3c 0f 00 00       	call   80101cb9 <iunlockput>
80100d7d:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d80:	e8 7c 24 00 00       	call   80103201 <end_op>
  ip = 0;
80100d85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8f:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9f:	05 00 20 00 00       	add    $0x2000,%eax
80100da4:	83 ec 04             	sub    $0x4,%esp
80100da7:	50                   	push   %eax
80100da8:	ff 75 e0             	pushl  -0x20(%ebp)
80100dab:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dae:	e8 5a 6b 00 00       	call   8010790d <allocuvm>
80100db3:	83 c4 10             	add    $0x10,%esp
80100db6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100db9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dbd:	0f 84 00 02 00 00    	je     80100fc3 <exec+0x405>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcb:	83 ec 08             	sub    $0x8,%esp
80100dce:	50                   	push   %eax
80100dcf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dd2:	e8 a4 6d 00 00       	call   80107b7b <clearpteu>
80100dd7:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ddd:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de7:	e9 96 00 00 00       	jmp    80100e82 <exec+0x2c4>
    if(argc >= MAXARG)
80100dec:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df0:	0f 87 d0 01 00 00    	ja     80100fc6 <exec+0x408>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e03:	01 d0                	add    %edx,%eax
80100e05:	8b 00                	mov    (%eax),%eax
80100e07:	83 ec 0c             	sub    $0xc,%esp
80100e0a:	50                   	push   %eax
80100e0b:	e8 ad 3f 00 00       	call   80104dbd <strlen>
80100e10:	83 c4 10             	add    $0x10,%esp
80100e13:	89 c2                	mov    %eax,%edx
80100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e18:	29 d0                	sub    %edx,%eax
80100e1a:	83 e8 01             	sub    $0x1,%eax
80100e1d:	83 e0 fc             	and    $0xfffffffc,%eax
80100e20:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e30:	01 d0                	add    %edx,%eax
80100e32:	8b 00                	mov    (%eax),%eax
80100e34:	83 ec 0c             	sub    $0xc,%esp
80100e37:	50                   	push   %eax
80100e38:	e8 80 3f 00 00       	call   80104dbd <strlen>
80100e3d:	83 c4 10             	add    $0x10,%esp
80100e40:	83 c0 01             	add    $0x1,%eax
80100e43:	89 c1                	mov    %eax,%ecx
80100e45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e52:	01 d0                	add    %edx,%eax
80100e54:	8b 00                	mov    (%eax),%eax
80100e56:	51                   	push   %ecx
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 c3 6e 00 00       	call   80107d26 <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 5b 01 00 00    	js     80100fc9 <exec+0x40b>
      goto bad;
    ustack[3+argc] = sp;
80100e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e71:	8d 50 03             	lea    0x3(%eax),%edx
80100e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e77:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e7e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e8f:	01 d0                	add    %edx,%eax
80100e91:	8b 00                	mov    (%eax),%eax
80100e93:	85 c0                	test   %eax,%eax
80100e95:	0f 85 51 ff ff ff    	jne    80100dec <exec+0x22e>
  }
  ustack[3+argc] = 0;
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	83 c0 03             	add    $0x3,%eax
80100ea1:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ea8:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eac:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eb3:	ff ff ff 
  ustack[1] = argc;
80100eb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb9:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ebf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec2:	83 c0 01             	add    $0x1,%eax
80100ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ecf:	29 d0                	sub    %edx,%eax
80100ed1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eda:	83 c0 04             	add    $0x4,%eax
80100edd:	c1 e0 02             	shl    $0x2,%eax
80100ee0:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee6:	83 c0 04             	add    $0x4,%eax
80100ee9:	c1 e0 02             	shl    $0x2,%eax
80100eec:	50                   	push   %eax
80100eed:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ef3:	50                   	push   %eax
80100ef4:	ff 75 dc             	pushl  -0x24(%ebp)
80100ef7:	ff 75 d4             	pushl  -0x2c(%ebp)
80100efa:	e8 27 6e 00 00       	call   80107d26 <copyout>
80100eff:	83 c4 10             	add    $0x10,%esp
80100f02:	85 c0                	test   %eax,%eax
80100f04:	0f 88 c2 00 00 00    	js     80100fcc <exec+0x40e>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f16:	eb 17                	jmp    80100f2f <exec+0x371>
    if(*s == '/')
80100f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1b:	0f b6 00             	movzbl (%eax),%eax
80100f1e:	3c 2f                	cmp    $0x2f,%al
80100f20:	75 09                	jne    80100f2b <exec+0x36d>
      last = s+1;
80100f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f25:	83 c0 01             	add    $0x1,%eax
80100f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f32:	0f b6 00             	movzbl (%eax),%eax
80100f35:	84 c0                	test   %al,%al
80100f37:	75 df                	jne    80100f18 <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f39:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3c:	83 c0 6c             	add    $0x6c,%eax
80100f3f:	83 ec 04             	sub    $0x4,%esp
80100f42:	6a 10                	push   $0x10
80100f44:	ff 75 f0             	pushl  -0x10(%ebp)
80100f47:	50                   	push   %eax
80100f48:	e8 22 3e 00 00       	call   80104d6f <safestrcpy>
80100f4d:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f50:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f53:	8b 40 04             	mov    0x4(%eax),%eax
80100f56:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f59:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f5f:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f62:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f65:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f68:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6d:	8b 40 18             	mov    0x18(%eax),%eax
80100f70:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f76:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f79:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7c:	8b 40 18             	mov    0x18(%eax),%eax
80100f7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f82:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f85:	83 ec 0c             	sub    $0xc,%esp
80100f88:	ff 75 d0             	pushl  -0x30(%ebp)
80100f8b:	e8 95 66 00 00       	call   80107625 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 40 6b 00 00       	call   80107ade <freevm>
80100f9e:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80100fa6:	eb 57                	jmp    80100fff <exec+0x441>
    goto bad;
80100fa8:	90                   	nop
80100fa9:	eb 22                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fab:	90                   	nop
80100fac:	eb 1f                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fae:	90                   	nop
80100faf:	eb 1c                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb1:	90                   	nop
80100fb2:	eb 19                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb4:	90                   	nop
80100fb5:	eb 16                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb7:	90                   	nop
80100fb8:	eb 13                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fba:	90                   	nop
80100fbb:	eb 10                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fbd:	90                   	nop
80100fbe:	eb 0d                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc0:	90                   	nop
80100fc1:	eb 0a                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fc3:	90                   	nop
80100fc4:	eb 07                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc6:	90                   	nop
80100fc7:	eb 04                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc9:	90                   	nop
80100fca:	eb 01                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fcc:	90                   	nop

 bad:
  if(pgdir)
80100fcd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fd1:	74 0e                	je     80100fe1 <exec+0x423>
    freevm(pgdir);
80100fd3:	83 ec 0c             	sub    $0xc,%esp
80100fd6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fd9:	e8 00 6b 00 00       	call   80107ade <freevm>
80100fde:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fe1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fe5:	74 13                	je     80100ffa <exec+0x43c>
    iunlockput(ip);
80100fe7:	83 ec 0c             	sub    $0xc,%esp
80100fea:	ff 75 d8             	pushl  -0x28(%ebp)
80100fed:	e8 c7 0c 00 00       	call   80101cb9 <iunlockput>
80100ff2:	83 c4 10             	add    $0x10,%esp
    end_op();
80100ff5:	e8 07 22 00 00       	call   80103201 <end_op>
  }
  return -1;
80100ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fff:	c9                   	leave  
80101000:	c3                   	ret    

80101001 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101001:	f3 0f 1e fb          	endbr32 
80101005:	55                   	push   %ebp
80101006:	89 e5                	mov    %esp,%ebp
80101008:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010100b:	83 ec 08             	sub    $0x8,%esp
8010100e:	68 c1 a3 10 80       	push   $0x8010a3c1
80101013:	68 60 2d 19 80       	push   $0x80192d60
80101018:	e8 82 38 00 00       	call   8010489f <initlock>
8010101d:	83 c4 10             	add    $0x10,%esp
}
80101020:	90                   	nop
80101021:	c9                   	leave  
80101022:	c3                   	ret    

80101023 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101023:	f3 0f 1e fb          	endbr32 
80101027:	55                   	push   %ebp
80101028:	89 e5                	mov    %esp,%ebp
8010102a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	68 60 2d 19 80       	push   $0x80192d60
80101035:	e8 8b 38 00 00       	call   801048c5 <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
80101044:	eb 2d                	jmp    80101073 <filealloc+0x50>
    if(f->ref == 0){
80101046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101049:	8b 40 04             	mov    0x4(%eax),%eax
8010104c:	85 c0                	test   %eax,%eax
8010104e:	75 1f                	jne    8010106f <filealloc+0x4c>
      f->ref = 1;
80101050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101053:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 60 2d 19 80       	push   $0x80192d60
80101062:	e8 d0 38 00 00       	call   80104937 <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 60 2d 19 80       	push   $0x80192d60
80101085:	e8 ad 38 00 00       	call   80104937 <release>
8010108a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010108d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101092:	c9                   	leave  
80101093:	c3                   	ret    

80101094 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101094:	f3 0f 1e fb          	endbr32 
80101098:	55                   	push   %ebp
80101099:	89 e5                	mov    %esp,%ebp
8010109b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010109e:	83 ec 0c             	sub    $0xc,%esp
801010a1:	68 60 2d 19 80       	push   $0x80192d60
801010a6:	e8 1a 38 00 00       	call   801048c5 <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 c8 a3 10 80       	push   $0x8010a3c8
801010c0:	e8 00 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 04             	mov    0x4(%eax),%eax
801010cb:	8d 50 01             	lea    0x1(%eax),%edx
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 60 2d 19 80       	push   $0x80192d60
801010dc:	e8 56 38 00 00       	call   80104937 <release>
801010e1:	83 c4 10             	add    $0x10,%esp
  return f;
801010e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010e7:	c9                   	leave  
801010e8:	c3                   	ret    

801010e9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010e9:	f3 0f 1e fb          	endbr32 
801010ed:	55                   	push   %ebp
801010ee:	89 e5                	mov    %esp,%ebp
801010f0:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010f3:	83 ec 0c             	sub    $0xc,%esp
801010f6:	68 60 2d 19 80       	push   $0x80192d60
801010fb:	e8 c5 37 00 00       	call   801048c5 <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 d0 a3 10 80       	push   $0x8010a3d0
80101115:	e8 ab f4 ff ff       	call   801005c5 <panic>
  if(--f->ref > 0){
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 04             	mov    0x4(%eax),%eax
80101120:	8d 50 ff             	lea    -0x1(%eax),%edx
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	89 50 04             	mov    %edx,0x4(%eax)
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 40 04             	mov    0x4(%eax),%eax
8010112f:	85 c0                	test   %eax,%eax
80101131:	7e 15                	jle    80101148 <fileclose+0x5f>
    release(&ftable.lock);
80101133:	83 ec 0c             	sub    $0xc,%esp
80101136:	68 60 2d 19 80       	push   $0x80192d60
8010113b:	e8 f7 37 00 00       	call   80104937 <release>
80101140:	83 c4 10             	add    $0x10,%esp
80101143:	e9 8b 00 00 00       	jmp    801011d3 <fileclose+0xea>
    return;
  }
  ff = *f;
80101148:	8b 45 08             	mov    0x8(%ebp),%eax
8010114b:	8b 10                	mov    (%eax),%edx
8010114d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101150:	8b 50 04             	mov    0x4(%eax),%edx
80101153:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101156:	8b 50 08             	mov    0x8(%eax),%edx
80101159:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010115c:	8b 50 0c             	mov    0xc(%eax),%edx
8010115f:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101162:	8b 50 10             	mov    0x10(%eax),%edx
80101165:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101168:	8b 40 14             	mov    0x14(%eax),%eax
8010116b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010116e:	8b 45 08             	mov    0x8(%ebp),%eax
80101171:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	68 60 2d 19 80       	push   $0x80192d60
80101189:	e8 a9 37 00 00       	call   80104937 <release>
8010118e:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101191:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101194:	83 f8 01             	cmp    $0x1,%eax
80101197:	75 19                	jne    801011b2 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101199:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010119d:	0f be d0             	movsbl %al,%edx
801011a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011a3:	83 ec 08             	sub    $0x8,%esp
801011a6:	52                   	push   %edx
801011a7:	50                   	push   %eax
801011a8:	e8 73 26 00 00       	call   80103820 <pipeclose>
801011ad:	83 c4 10             	add    $0x10,%esp
801011b0:	eb 21                	jmp    801011d3 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011b5:	83 f8 02             	cmp    $0x2,%eax
801011b8:	75 19                	jne    801011d3 <fileclose+0xea>
    begin_op();
801011ba:	e8 b2 1f 00 00       	call   80103171 <begin_op>
    iput(ff.ip);
801011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011c2:	83 ec 0c             	sub    $0xc,%esp
801011c5:	50                   	push   %eax
801011c6:	e8 1a 0a 00 00       	call   80101be5 <iput>
801011cb:	83 c4 10             	add    $0x10,%esp
    end_op();
801011ce:	e8 2e 20 00 00       	call   80103201 <end_op>
  }
}
801011d3:	c9                   	leave  
801011d4:	c3                   	ret    

801011d5 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011d5:	f3 0f 1e fb          	endbr32 
801011d9:	55                   	push   %ebp
801011da:	89 e5                	mov    %esp,%ebp
801011dc:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011df:	8b 45 08             	mov    0x8(%ebp),%eax
801011e2:	8b 00                	mov    (%eax),%eax
801011e4:	83 f8 02             	cmp    $0x2,%eax
801011e7:	75 40                	jne    80101229 <filestat+0x54>
    ilock(f->ip);
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 40 10             	mov    0x10(%eax),%eax
801011ef:	83 ec 0c             	sub    $0xc,%esp
801011f2:	50                   	push   %eax
801011f3:	e8 84 08 00 00       	call   80101a7c <ilock>
801011f8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011fb:	8b 45 08             	mov    0x8(%ebp),%eax
801011fe:	8b 40 10             	mov    0x10(%eax),%eax
80101201:	83 ec 08             	sub    $0x8,%esp
80101204:	ff 75 0c             	pushl  0xc(%ebp)
80101207:	50                   	push   %eax
80101208:	e8 2d 0d 00 00       	call   80101f3a <stati>
8010120d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101210:	8b 45 08             	mov    0x8(%ebp),%eax
80101213:	8b 40 10             	mov    0x10(%eax),%eax
80101216:	83 ec 0c             	sub    $0xc,%esp
80101219:	50                   	push   %eax
8010121a:	e8 74 09 00 00       	call   80101b93 <iunlock>
8010121f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101222:	b8 00 00 00 00       	mov    $0x0,%eax
80101227:	eb 05                	jmp    8010122e <filestat+0x59>
  }
  return -1;
80101229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010122e:	c9                   	leave  
8010122f:	c3                   	ret    

80101230 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101230:	f3 0f 1e fb          	endbr32 
80101234:	55                   	push   %ebp
80101235:	89 e5                	mov    %esp,%ebp
80101237:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010123a:	8b 45 08             	mov    0x8(%ebp),%eax
8010123d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101241:	84 c0                	test   %al,%al
80101243:	75 0a                	jne    8010124f <fileread+0x1f>
    return -1;
80101245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010124a:	e9 9b 00 00 00       	jmp    801012ea <fileread+0xba>
  if(f->type == FD_PIPE)
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	8b 00                	mov    (%eax),%eax
80101254:	83 f8 01             	cmp    $0x1,%eax
80101257:	75 1a                	jne    80101273 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101259:	8b 45 08             	mov    0x8(%ebp),%eax
8010125c:	8b 40 0c             	mov    0xc(%eax),%eax
8010125f:	83 ec 04             	sub    $0x4,%esp
80101262:	ff 75 10             	pushl  0x10(%ebp)
80101265:	ff 75 0c             	pushl  0xc(%ebp)
80101268:	50                   	push   %eax
80101269:	e8 67 27 00 00       	call   801039d5 <piperead>
8010126e:	83 c4 10             	add    $0x10,%esp
80101271:	eb 77                	jmp    801012ea <fileread+0xba>
  if(f->type == FD_INODE){
80101273:	8b 45 08             	mov    0x8(%ebp),%eax
80101276:	8b 00                	mov    (%eax),%eax
80101278:	83 f8 02             	cmp    $0x2,%eax
8010127b:	75 60                	jne    801012dd <fileread+0xad>
    ilock(f->ip);
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 40 10             	mov    0x10(%eax),%eax
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	50                   	push   %eax
80101287:	e8 f0 07 00 00       	call   80101a7c <ilock>
8010128c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010128f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 50 14             	mov    0x14(%eax),%edx
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	8b 40 10             	mov    0x10(%eax),%eax
8010129e:	51                   	push   %ecx
8010129f:	52                   	push   %edx
801012a0:	ff 75 0c             	pushl  0xc(%ebp)
801012a3:	50                   	push   %eax
801012a4:	e8 db 0c 00 00       	call   80101f84 <readi>
801012a9:	83 c4 10             	add    $0x10,%esp
801012ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012b3:	7e 11                	jle    801012c6 <fileread+0x96>
      f->off += r;
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 50 14             	mov    0x14(%eax),%edx
801012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012be:	01 c2                	add    %eax,%edx
801012c0:	8b 45 08             	mov    0x8(%ebp),%eax
801012c3:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	8b 40 10             	mov    0x10(%eax),%eax
801012cc:	83 ec 0c             	sub    $0xc,%esp
801012cf:	50                   	push   %eax
801012d0:	e8 be 08 00 00       	call   80101b93 <iunlock>
801012d5:	83 c4 10             	add    $0x10,%esp
    return r;
801012d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012db:	eb 0d                	jmp    801012ea <fileread+0xba>
  }
  panic("fileread");
801012dd:	83 ec 0c             	sub    $0xc,%esp
801012e0:	68 da a3 10 80       	push   $0x8010a3da
801012e5:	e8 db f2 ff ff       	call   801005c5 <panic>
}
801012ea:	c9                   	leave  
801012eb:	c3                   	ret    

801012ec <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012ec:	f3 0f 1e fb          	endbr32 
801012f0:	55                   	push   %ebp
801012f1:	89 e5                	mov    %esp,%ebp
801012f3:	53                   	push   %ebx
801012f4:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012fe:	84 c0                	test   %al,%al
80101300:	75 0a                	jne    8010130c <filewrite+0x20>
    return -1;
80101302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101307:	e9 1b 01 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010130c:	8b 45 08             	mov    0x8(%ebp),%eax
8010130f:	8b 00                	mov    (%eax),%eax
80101311:	83 f8 01             	cmp    $0x1,%eax
80101314:	75 1d                	jne    80101333 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	8b 40 0c             	mov    0xc(%eax),%eax
8010131c:	83 ec 04             	sub    $0x4,%esp
8010131f:	ff 75 10             	pushl  0x10(%ebp)
80101322:	ff 75 0c             	pushl  0xc(%ebp)
80101325:	50                   	push   %eax
80101326:	e8 a4 25 00 00       	call   801038cf <pipewrite>
8010132b:	83 c4 10             	add    $0x10,%esp
8010132e:	e9 f4 00 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	8b 00                	mov    (%eax),%eax
80101338:	83 f8 02             	cmp    $0x2,%eax
8010133b:	0f 85 d9 00 00 00    	jne    8010141a <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101341:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010134f:	e9 a3 00 00 00       	jmp    801013f7 <filewrite+0x10b>
      int n1 = n - i;
80101354:	8b 45 10             	mov    0x10(%ebp),%eax
80101357:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010135a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101360:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101363:	7e 06                	jle    8010136b <filewrite+0x7f>
        n1 = max;
80101365:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101368:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010136b:	e8 01 1e 00 00       	call   80103171 <begin_op>
      ilock(f->ip);
80101370:	8b 45 08             	mov    0x8(%ebp),%eax
80101373:	8b 40 10             	mov    0x10(%eax),%eax
80101376:	83 ec 0c             	sub    $0xc,%esp
80101379:	50                   	push   %eax
8010137a:	e8 fd 06 00 00       	call   80101a7c <ilock>
8010137f:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101382:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8b 50 14             	mov    0x14(%eax),%edx
8010138b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010138e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101391:	01 c3                	add    %eax,%ebx
80101393:	8b 45 08             	mov    0x8(%ebp),%eax
80101396:	8b 40 10             	mov    0x10(%eax),%eax
80101399:	51                   	push   %ecx
8010139a:	52                   	push   %edx
8010139b:	53                   	push   %ebx
8010139c:	50                   	push   %eax
8010139d:	e8 3b 0d 00 00       	call   801020dd <writei>
801013a2:	83 c4 10             	add    $0x10,%esp
801013a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013ac:	7e 11                	jle    801013bf <filewrite+0xd3>
        f->off += r;
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	8b 50 14             	mov    0x14(%eax),%edx
801013b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013b7:	01 c2                	add    %eax,%edx
801013b9:	8b 45 08             	mov    0x8(%ebp),%eax
801013bc:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	8b 40 10             	mov    0x10(%eax),%eax
801013c5:	83 ec 0c             	sub    $0xc,%esp
801013c8:	50                   	push   %eax
801013c9:	e8 c5 07 00 00       	call   80101b93 <iunlock>
801013ce:	83 c4 10             	add    $0x10,%esp
      end_op();
801013d1:	e8 2b 1e 00 00       	call   80103201 <end_op>

      if(r < 0)
801013d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013da:	78 29                	js     80101405 <filewrite+0x119>
        break;
      if(r != n1)
801013dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013df:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013e2:	74 0d                	je     801013f1 <filewrite+0x105>
        panic("short filewrite");
801013e4:	83 ec 0c             	sub    $0xc,%esp
801013e7:	68 e3 a3 10 80       	push   $0x8010a3e3
801013ec:	e8 d4 f1 ff ff       	call   801005c5 <panic>
      i += r;
801013f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f4:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013fa:	3b 45 10             	cmp    0x10(%ebp),%eax
801013fd:	0f 8c 51 ff ff ff    	jl     80101354 <filewrite+0x68>
80101403:	eb 01                	jmp    80101406 <filewrite+0x11a>
        break;
80101405:	90                   	nop
    }
    return i == n ? n : -1;
80101406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101409:	3b 45 10             	cmp    0x10(%ebp),%eax
8010140c:	75 05                	jne    80101413 <filewrite+0x127>
8010140e:	8b 45 10             	mov    0x10(%ebp),%eax
80101411:	eb 14                	jmp    80101427 <filewrite+0x13b>
80101413:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101418:	eb 0d                	jmp    80101427 <filewrite+0x13b>
  }
  panic("filewrite");
8010141a:	83 ec 0c             	sub    $0xc,%esp
8010141d:	68 f3 a3 10 80       	push   $0x8010a3f3
80101422:	e8 9e f1 ff ff       	call   801005c5 <panic>
}
80101427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010142a:	c9                   	leave  
8010142b:	c3                   	ret    

8010142c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010142c:	f3 0f 1e fb          	endbr32 
80101430:	55                   	push   %ebp
80101431:	89 e5                	mov    %esp,%ebp
80101433:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101436:	8b 45 08             	mov    0x8(%ebp),%eax
80101439:	83 ec 08             	sub    $0x8,%esp
8010143c:	6a 01                	push   $0x1
8010143e:	50                   	push   %eax
8010143f:	e8 c5 ed ff ff       	call   80100209 <bread>
80101444:	83 c4 10             	add    $0x10,%esp
80101447:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144d:	83 c0 5c             	add    $0x5c,%eax
80101450:	83 ec 04             	sub    $0x4,%esp
80101453:	6a 1c                	push   $0x1c
80101455:	50                   	push   %eax
80101456:	ff 75 0c             	pushl  0xc(%ebp)
80101459:	e8 bd 37 00 00       	call   80104c1b <memmove>
8010145e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101461:	83 ec 0c             	sub    $0xc,%esp
80101464:	ff 75 f4             	pushl  -0xc(%ebp)
80101467:	e8 27 ee ff ff       	call   80100293 <brelse>
8010146c:	83 c4 10             	add    $0x10,%esp
}
8010146f:	90                   	nop
80101470:	c9                   	leave  
80101471:	c3                   	ret    

80101472 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101472:	f3 0f 1e fb          	endbr32 
80101476:	55                   	push   %ebp
80101477:	89 e5                	mov    %esp,%ebp
80101479:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010147c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010147f:	8b 45 08             	mov    0x8(%ebp),%eax
80101482:	83 ec 08             	sub    $0x8,%esp
80101485:	52                   	push   %edx
80101486:	50                   	push   %eax
80101487:	e8 7d ed ff ff       	call   80100209 <bread>
8010148c:	83 c4 10             	add    $0x10,%esp
8010148f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101495:	83 c0 5c             	add    $0x5c,%eax
80101498:	83 ec 04             	sub    $0x4,%esp
8010149b:	68 00 02 00 00       	push   $0x200
801014a0:	6a 00                	push   $0x0
801014a2:	50                   	push   %eax
801014a3:	e8 ac 36 00 00       	call   80104b54 <memset>
801014a8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ab:	83 ec 0c             	sub    $0xc,%esp
801014ae:	ff 75 f4             	pushl  -0xc(%ebp)
801014b1:	e8 04 1f 00 00       	call   801033ba <log_write>
801014b6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014b9:	83 ec 0c             	sub    $0xc,%esp
801014bc:	ff 75 f4             	pushl  -0xc(%ebp)
801014bf:	e8 cf ed ff ff       	call   80100293 <brelse>
801014c4:	83 c4 10             	add    $0x10,%esp
}
801014c7:	90                   	nop
801014c8:	c9                   	leave  
801014c9:	c3                   	ret    

801014ca <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014ca:	f3 0f 1e fb          	endbr32 
801014ce:	55                   	push   %ebp
801014cf:	89 e5                	mov    %esp,%ebp
801014d1:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014e2:	e9 13 01 00 00       	jmp    801015fa <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ea:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014f0:	85 c0                	test   %eax,%eax
801014f2:	0f 48 c2             	cmovs  %edx,%eax
801014f5:	c1 f8 0c             	sar    $0xc,%eax
801014f8:	89 c2                	mov    %eax,%edx
801014fa:	a1 78 37 19 80       	mov    0x80193778,%eax
801014ff:	01 d0                	add    %edx,%eax
80101501:	83 ec 08             	sub    $0x8,%esp
80101504:	50                   	push   %eax
80101505:	ff 75 08             	pushl  0x8(%ebp)
80101508:	e8 fc ec ff ff       	call   80100209 <bread>
8010150d:	83 c4 10             	add    $0x10,%esp
80101510:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101513:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010151a:	e9 a6 00 00 00       	jmp    801015c5 <balloc+0xfb>
      m = 1 << (bi % 8);
8010151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101522:	99                   	cltd   
80101523:	c1 ea 1d             	shr    $0x1d,%edx
80101526:	01 d0                	add    %edx,%eax
80101528:	83 e0 07             	and    $0x7,%eax
8010152b:	29 d0                	sub    %edx,%eax
8010152d:	ba 01 00 00 00       	mov    $0x1,%edx
80101532:	89 c1                	mov    %eax,%ecx
80101534:	d3 e2                	shl    %cl,%edx
80101536:	89 d0                	mov    %edx,%eax
80101538:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153e:	8d 50 07             	lea    0x7(%eax),%edx
80101541:	85 c0                	test   %eax,%eax
80101543:	0f 48 c2             	cmovs  %edx,%eax
80101546:	c1 f8 03             	sar    $0x3,%eax
80101549:	89 c2                	mov    %eax,%edx
8010154b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010154e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101553:	0f b6 c0             	movzbl %al,%eax
80101556:	23 45 e8             	and    -0x18(%ebp),%eax
80101559:	85 c0                	test   %eax,%eax
8010155b:	75 64                	jne    801015c1 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101560:	8d 50 07             	lea    0x7(%eax),%edx
80101563:	85 c0                	test   %eax,%eax
80101565:	0f 48 c2             	cmovs  %edx,%eax
80101568:	c1 f8 03             	sar    $0x3,%eax
8010156b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010156e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101573:	89 d1                	mov    %edx,%ecx
80101575:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101578:	09 ca                	or     %ecx,%edx
8010157a:	89 d1                	mov    %edx,%ecx
8010157c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010157f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101583:	83 ec 0c             	sub    $0xc,%esp
80101586:	ff 75 ec             	pushl  -0x14(%ebp)
80101589:	e8 2c 1e 00 00       	call   801033ba <log_write>
8010158e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101591:	83 ec 0c             	sub    $0xc,%esp
80101594:	ff 75 ec             	pushl  -0x14(%ebp)
80101597:	e8 f7 ec ff ff       	call   80100293 <brelse>
8010159c:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010159f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a5:	01 c2                	add    %eax,%edx
801015a7:	8b 45 08             	mov    0x8(%ebp),%eax
801015aa:	83 ec 08             	sub    $0x8,%esp
801015ad:	52                   	push   %edx
801015ae:	50                   	push   %eax
801015af:	e8 be fe ff ff       	call   80101472 <bzero>
801015b4:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015bd:	01 d0                	add    %edx,%eax
801015bf:	eb 57                	jmp    80101618 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015c5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015cc:	7f 17                	jg     801015e5 <balloc+0x11b>
801015ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d4:	01 d0                	add    %edx,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	a1 60 37 19 80       	mov    0x80193760,%eax
801015dd:	39 c2                	cmp    %eax,%edx
801015df:	0f 82 3a ff ff ff    	jb     8010151f <balloc+0x55>
      }
    }
    brelse(bp);
801015e5:	83 ec 0c             	sub    $0xc,%esp
801015e8:	ff 75 ec             	pushl  -0x14(%ebp)
801015eb:	e8 a3 ec ff ff       	call   80100293 <brelse>
801015f0:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015fa:	8b 15 60 37 19 80    	mov    0x80193760,%edx
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	39 c2                	cmp    %eax,%edx
80101605:	0f 87 dc fe ff ff    	ja     801014e7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010160b:	83 ec 0c             	sub    $0xc,%esp
8010160e:	68 00 a4 10 80       	push   $0x8010a400
80101613:	e8 ad ef ff ff       	call   801005c5 <panic>
}
80101618:	c9                   	leave  
80101619:	c3                   	ret    

8010161a <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010161a:	f3 0f 1e fb          	endbr32 
8010161e:	55                   	push   %ebp
8010161f:	89 e5                	mov    %esp,%ebp
80101621:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101624:	83 ec 08             	sub    $0x8,%esp
80101627:	68 60 37 19 80       	push   $0x80193760
8010162c:	ff 75 08             	pushl  0x8(%ebp)
8010162f:	e8 f8 fd ff ff       	call   8010142c <readsb>
80101634:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163a:	c1 e8 0c             	shr    $0xc,%eax
8010163d:	89 c2                	mov    %eax,%edx
8010163f:	a1 78 37 19 80       	mov    0x80193778,%eax
80101644:	01 c2                	add    %eax,%edx
80101646:	8b 45 08             	mov    0x8(%ebp),%eax
80101649:	83 ec 08             	sub    $0x8,%esp
8010164c:	52                   	push   %edx
8010164d:	50                   	push   %eax
8010164e:	e8 b6 eb ff ff       	call   80100209 <bread>
80101653:	83 c4 10             	add    $0x10,%esp
80101656:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101659:	8b 45 0c             	mov    0xc(%ebp),%eax
8010165c:	25 ff 0f 00 00       	and    $0xfff,%eax
80101661:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101667:	99                   	cltd   
80101668:	c1 ea 1d             	shr    $0x1d,%edx
8010166b:	01 d0                	add    %edx,%eax
8010166d:	83 e0 07             	and    $0x7,%eax
80101670:	29 d0                	sub    %edx,%eax
80101672:	ba 01 00 00 00       	mov    $0x1,%edx
80101677:	89 c1                	mov    %eax,%ecx
80101679:	d3 e2                	shl    %cl,%edx
8010167b:	89 d0                	mov    %edx,%eax
8010167d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101683:	8d 50 07             	lea    0x7(%eax),%edx
80101686:	85 c0                	test   %eax,%eax
80101688:	0f 48 c2             	cmovs  %edx,%eax
8010168b:	c1 f8 03             	sar    $0x3,%eax
8010168e:	89 c2                	mov    %eax,%edx
80101690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101693:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101698:	0f b6 c0             	movzbl %al,%eax
8010169b:	23 45 ec             	and    -0x14(%ebp),%eax
8010169e:	85 c0                	test   %eax,%eax
801016a0:	75 0d                	jne    801016af <bfree+0x95>
    panic("freeing free block");
801016a2:	83 ec 0c             	sub    $0xc,%esp
801016a5:	68 16 a4 10 80       	push   $0x8010a416
801016aa:	e8 16 ef ff ff       	call   801005c5 <panic>
  bp->data[bi/8] &= ~m;
801016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b2:	8d 50 07             	lea    0x7(%eax),%edx
801016b5:	85 c0                	test   %eax,%eax
801016b7:	0f 48 c2             	cmovs  %edx,%eax
801016ba:	c1 f8 03             	sar    $0x3,%eax
801016bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c0:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016c5:	89 d1                	mov    %edx,%ecx
801016c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016ca:	f7 d2                	not    %edx
801016cc:	21 ca                	and    %ecx,%edx
801016ce:	89 d1                	mov    %edx,%ecx
801016d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016d3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016d7:	83 ec 0c             	sub    $0xc,%esp
801016da:	ff 75 f4             	pushl  -0xc(%ebp)
801016dd:	e8 d8 1c 00 00       	call   801033ba <log_write>
801016e2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016e5:	83 ec 0c             	sub    $0xc,%esp
801016e8:	ff 75 f4             	pushl  -0xc(%ebp)
801016eb:	e8 a3 eb ff ff       	call   80100293 <brelse>
801016f0:	83 c4 10             	add    $0x10,%esp
}
801016f3:	90                   	nop
801016f4:	c9                   	leave  
801016f5:	c3                   	ret    

801016f6 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016f6:	f3 0f 1e fb          	endbr32 
801016fa:	55                   	push   %ebp
801016fb:	89 e5                	mov    %esp,%ebp
801016fd:	57                   	push   %edi
801016fe:	56                   	push   %esi
801016ff:	53                   	push   %ebx
80101700:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010170a:	83 ec 08             	sub    $0x8,%esp
8010170d:	68 29 a4 10 80       	push   $0x8010a429
80101712:	68 80 37 19 80       	push   $0x80193780
80101717:	e8 83 31 00 00       	call   8010489f <initlock>
8010171c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010171f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101726:	eb 2d                	jmp    80101755 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101728:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010172b:	89 d0                	mov    %edx,%eax
8010172d:	c1 e0 03             	shl    $0x3,%eax
80101730:	01 d0                	add    %edx,%eax
80101732:	c1 e0 04             	shl    $0x4,%eax
80101735:	83 c0 30             	add    $0x30,%eax
80101738:	05 80 37 19 80       	add    $0x80193780,%eax
8010173d:	83 c0 10             	add    $0x10,%eax
80101740:	83 ec 08             	sub    $0x8,%esp
80101743:	68 30 a4 10 80       	push   $0x8010a430
80101748:	50                   	push   %eax
80101749:	e8 e4 2f 00 00       	call   80104732 <initsleeplock>
8010174e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101751:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101755:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101759:	7e cd                	jle    80101728 <iinit+0x32>
  }

  readsb(dev, &sb);
8010175b:	83 ec 08             	sub    $0x8,%esp
8010175e:	68 60 37 19 80       	push   $0x80193760
80101763:	ff 75 08             	pushl  0x8(%ebp)
80101766:	e8 c1 fc ff ff       	call   8010142c <readsb>
8010176b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010176e:	a1 78 37 19 80       	mov    0x80193778,%eax
80101773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101776:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
8010177c:	8b 35 70 37 19 80    	mov    0x80193770,%esi
80101782:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
80101788:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
8010178e:	8b 15 64 37 19 80    	mov    0x80193764,%edx
80101794:	a1 60 37 19 80       	mov    0x80193760,%eax
80101799:	ff 75 d4             	pushl  -0x2c(%ebp)
8010179c:	57                   	push   %edi
8010179d:	56                   	push   %esi
8010179e:	53                   	push   %ebx
8010179f:	51                   	push   %ecx
801017a0:	52                   	push   %edx
801017a1:	50                   	push   %eax
801017a2:	68 38 a4 10 80       	push   $0x8010a438
801017a7:	e8 60 ec ff ff       	call   8010040c <cprintf>
801017ac:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017af:	90                   	nop
801017b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017b3:	5b                   	pop    %ebx
801017b4:	5e                   	pop    %esi
801017b5:	5f                   	pop    %edi
801017b6:	5d                   	pop    %ebp
801017b7:	c3                   	ret    

801017b8 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017b8:	f3 0f 1e fb          	endbr32 
801017bc:	55                   	push   %ebp
801017bd:	89 e5                	mov    %esp,%ebp
801017bf:	83 ec 28             	sub    $0x28,%esp
801017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801017c5:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017c9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017d0:	e9 9e 00 00 00       	jmp    80101873 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	c1 e8 03             	shr    $0x3,%eax
801017db:	89 c2                	mov    %eax,%edx
801017dd:	a1 74 37 19 80       	mov    0x80193774,%eax
801017e2:	01 d0                	add    %edx,%eax
801017e4:	83 ec 08             	sub    $0x8,%esp
801017e7:	50                   	push   %eax
801017e8:	ff 75 08             	pushl  0x8(%ebp)
801017eb:	e8 19 ea ff ff       	call   80100209 <bread>
801017f0:	83 c4 10             	add    $0x10,%esp
801017f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	8d 50 5c             	lea    0x5c(%eax),%edx
801017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ff:	83 e0 07             	and    $0x7,%eax
80101802:	c1 e0 06             	shl    $0x6,%eax
80101805:	01 d0                	add    %edx,%eax
80101807:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010180a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010180d:	0f b7 00             	movzwl (%eax),%eax
80101810:	66 85 c0             	test   %ax,%ax
80101813:	75 4c                	jne    80101861 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101815:	83 ec 04             	sub    $0x4,%esp
80101818:	6a 40                	push   $0x40
8010181a:	6a 00                	push   $0x0
8010181c:	ff 75 ec             	pushl  -0x14(%ebp)
8010181f:	e8 30 33 00 00       	call   80104b54 <memset>
80101824:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101827:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010182a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010182e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101831:	83 ec 0c             	sub    $0xc,%esp
80101834:	ff 75 f0             	pushl  -0x10(%ebp)
80101837:	e8 7e 1b 00 00       	call   801033ba <log_write>
8010183c:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010183f:	83 ec 0c             	sub    $0xc,%esp
80101842:	ff 75 f0             	pushl  -0x10(%ebp)
80101845:	e8 49 ea ff ff       	call   80100293 <brelse>
8010184a:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	83 ec 08             	sub    $0x8,%esp
80101853:	50                   	push   %eax
80101854:	ff 75 08             	pushl  0x8(%ebp)
80101857:	e8 fc 00 00 00       	call   80101958 <iget>
8010185c:	83 c4 10             	add    $0x10,%esp
8010185f:	eb 30                	jmp    80101891 <ialloc+0xd9>
    }
    brelse(bp);
80101861:	83 ec 0c             	sub    $0xc,%esp
80101864:	ff 75 f0             	pushl  -0x10(%ebp)
80101867:	e8 27 ea ff ff       	call   80100293 <brelse>
8010186c:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010186f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101873:	8b 15 68 37 19 80    	mov    0x80193768,%edx
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	39 c2                	cmp    %eax,%edx
8010187e:	0f 87 51 ff ff ff    	ja     801017d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 8b a4 10 80       	push   $0x8010a48b
8010188c:	e8 34 ed ff ff       	call   801005c5 <panic>
}
80101891:	c9                   	leave  
80101892:	c3                   	ret    

80101893 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101893:	f3 0f 1e fb          	endbr32 
80101897:	55                   	push   %ebp
80101898:	89 e5                	mov    %esp,%ebp
8010189a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010189d:	8b 45 08             	mov    0x8(%ebp),%eax
801018a0:	8b 40 04             	mov    0x4(%eax),%eax
801018a3:	c1 e8 03             	shr    $0x3,%eax
801018a6:	89 c2                	mov    %eax,%edx
801018a8:	a1 74 37 19 80       	mov    0x80193774,%eax
801018ad:	01 c2                	add    %eax,%edx
801018af:	8b 45 08             	mov    0x8(%ebp),%eax
801018b2:	8b 00                	mov    (%eax),%eax
801018b4:	83 ec 08             	sub    $0x8,%esp
801018b7:	52                   	push   %edx
801018b8:	50                   	push   %eax
801018b9:	e8 4b e9 ff ff       	call   80100209 <bread>
801018be:	83 c4 10             	add    $0x10,%esp
801018c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ca:	8b 45 08             	mov    0x8(%ebp),%eax
801018cd:	8b 40 04             	mov    0x4(%eax),%eax
801018d0:	83 e0 07             	and    $0x7,%eax
801018d3:	c1 e0 06             	shl    $0x6,%eax
801018d6:	01 d0                	add    %edx,%eax
801018d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018db:	8b 45 08             	mov    0x8(%ebp),%eax
801018de:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f2:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018f6:	8b 45 08             	mov    0x8(%ebp),%eax
801018f9:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101900:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101912:	8b 45 08             	mov    0x8(%ebp),%eax
80101915:	8b 50 58             	mov    0x58(%eax),%edx
80101918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	8d 50 5c             	lea    0x5c(%eax),%edx
80101924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101927:	83 c0 0c             	add    $0xc,%eax
8010192a:	83 ec 04             	sub    $0x4,%esp
8010192d:	6a 34                	push   $0x34
8010192f:	52                   	push   %edx
80101930:	50                   	push   %eax
80101931:	e8 e5 32 00 00       	call   80104c1b <memmove>
80101936:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	ff 75 f4             	pushl  -0xc(%ebp)
8010193f:	e8 76 1a 00 00       	call   801033ba <log_write>
80101944:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101947:	83 ec 0c             	sub    $0xc,%esp
8010194a:	ff 75 f4             	pushl  -0xc(%ebp)
8010194d:	e8 41 e9 ff ff       	call   80100293 <brelse>
80101952:	83 c4 10             	add    $0x10,%esp
}
80101955:	90                   	nop
80101956:	c9                   	leave  
80101957:	c3                   	ret    

80101958 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101958:	f3 0f 1e fb          	endbr32 
8010195c:	55                   	push   %ebp
8010195d:	89 e5                	mov    %esp,%ebp
8010195f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101962:	83 ec 0c             	sub    $0xc,%esp
80101965:	68 80 37 19 80       	push   $0x80193780
8010196a:	e8 56 2f 00 00       	call   801048c5 <acquire>
8010196f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101972:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101979:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
80101980:	eb 60                	jmp    801019e2 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101985:	8b 40 08             	mov    0x8(%eax),%eax
80101988:	85 c0                	test   %eax,%eax
8010198a:	7e 39                	jle    801019c5 <iget+0x6d>
8010198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198f:	8b 00                	mov    (%eax),%eax
80101991:	39 45 08             	cmp    %eax,0x8(%ebp)
80101994:	75 2f                	jne    801019c5 <iget+0x6d>
80101996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101999:	8b 40 04             	mov    0x4(%eax),%eax
8010199c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010199f:	75 24                	jne    801019c5 <iget+0x6d>
      ip->ref++;
801019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a4:	8b 40 08             	mov    0x8(%eax),%eax
801019a7:	8d 50 01             	lea    0x1(%eax),%edx
801019aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ad:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019b0:	83 ec 0c             	sub    $0xc,%esp
801019b3:	68 80 37 19 80       	push   $0x80193780
801019b8:	e8 7a 2f 00 00       	call   80104937 <release>
801019bd:	83 c4 10             	add    $0x10,%esp
      return ip;
801019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c3:	eb 77                	jmp    80101a3c <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019c9:	75 10                	jne    801019db <iget+0x83>
801019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ce:	8b 40 08             	mov    0x8(%eax),%eax
801019d1:	85 c0                	test   %eax,%eax
801019d3:	75 06                	jne    801019db <iget+0x83>
      empty = ip;
801019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019db:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019e2:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
801019e9:	72 97                	jb     80101982 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ef:	75 0d                	jne    801019fe <iget+0xa6>
    panic("iget: no inodes");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 9d a4 10 80       	push   $0x8010a49d
801019f9:	e8 c7 eb ff ff       	call   801005c5 <panic>

  ip = empty;
801019fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a07:	8b 55 08             	mov    0x8(%ebp),%edx
80101a0a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a12:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a22:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a29:	83 ec 0c             	sub    $0xc,%esp
80101a2c:	68 80 37 19 80       	push   $0x80193780
80101a31:	e8 01 2f 00 00       	call   80104937 <release>
80101a36:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a3c:	c9                   	leave  
80101a3d:	c3                   	ret    

80101a3e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a3e:	f3 0f 1e fb          	endbr32 
80101a42:	55                   	push   %ebp
80101a43:	89 e5                	mov    %esp,%ebp
80101a45:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a48:	83 ec 0c             	sub    $0xc,%esp
80101a4b:	68 80 37 19 80       	push   $0x80193780
80101a50:	e8 70 2e 00 00       	call   801048c5 <acquire>
80101a55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	8d 50 01             	lea    0x1(%eax),%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 80 37 19 80       	push   $0x80193780
80101a6f:	e8 c3 2e 00 00       	call   80104937 <release>
80101a74:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a7a:	c9                   	leave  
80101a7b:	c3                   	ret    

80101a7c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a7c:	f3 0f 1e fb          	endbr32 
80101a80:	55                   	push   %ebp
80101a81:	89 e5                	mov    %esp,%ebp
80101a83:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a8a:	74 0a                	je     80101a96 <ilock+0x1a>
80101a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8f:	8b 40 08             	mov    0x8(%eax),%eax
80101a92:	85 c0                	test   %eax,%eax
80101a94:	7f 0d                	jg     80101aa3 <ilock+0x27>
    panic("ilock");
80101a96:	83 ec 0c             	sub    $0xc,%esp
80101a99:	68 ad a4 10 80       	push   $0x8010a4ad
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 c0 2c 00 00       	call   80104772 <acquiresleep>
80101ab2:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101abb:	85 c0                	test   %eax,%eax
80101abd:	0f 85 cd 00 00 00    	jne    80101b90 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	8b 40 04             	mov    0x4(%eax),%eax
80101ac9:	c1 e8 03             	shr    $0x3,%eax
80101acc:	89 c2                	mov    %eax,%edx
80101ace:	a1 74 37 19 80       	mov    0x80193774,%eax
80101ad3:	01 c2                	add    %eax,%edx
80101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad8:	8b 00                	mov    (%eax),%eax
80101ada:	83 ec 08             	sub    $0x8,%esp
80101add:	52                   	push   %edx
80101ade:	50                   	push   %eax
80101adf:	e8 25 e7 ff ff       	call   80100209 <bread>
80101ae4:	83 c4 10             	add    $0x10,%esp
80101ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aed:	8d 50 5c             	lea    0x5c(%eax),%edx
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	8b 40 04             	mov    0x4(%eax),%eax
80101af6:	83 e0 07             	and    $0x7,%eax
80101af9:	c1 e0 06             	shl    $0x6,%eax
80101afc:	01 d0                	add    %edx,%eax
80101afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b04:	0f b7 10             	movzwl (%eax),%edx
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b11:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b31:	8b 45 08             	mov    0x8(%ebp),%eax
80101b34:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3b:	8b 50 08             	mov    0x8(%eax),%edx
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b47:	8d 50 0c             	lea    0xc(%eax),%edx
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	83 c0 5c             	add    $0x5c,%eax
80101b50:	83 ec 04             	sub    $0x4,%esp
80101b53:	6a 34                	push   $0x34
80101b55:	52                   	push   %edx
80101b56:	50                   	push   %eax
80101b57:	e8 bf 30 00 00       	call   80104c1b <memmove>
80101b5c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	ff 75 f4             	pushl  -0xc(%ebp)
80101b65:	e8 29 e7 ff ff       	call   80100293 <brelse>
80101b6a:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b7e:	66 85 c0             	test   %ax,%ax
80101b81:	75 0d                	jne    80101b90 <ilock+0x114>
      panic("ilock: no type");
80101b83:	83 ec 0c             	sub    $0xc,%esp
80101b86:	68 b3 a4 10 80       	push   $0x8010a4b3
80101b8b:	e8 35 ea ff ff       	call   801005c5 <panic>
  }
}
80101b90:	90                   	nop
80101b91:	c9                   	leave  
80101b92:	c3                   	ret    

80101b93 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b93:	f3 0f 1e fb          	endbr32 
80101b97:	55                   	push   %ebp
80101b98:	89 e5                	mov    %esp,%ebp
80101b9a:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ba1:	74 20                	je     80101bc3 <iunlock+0x30>
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	83 c0 0c             	add    $0xc,%eax
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	50                   	push   %eax
80101bad:	e8 7a 2c 00 00       	call   8010482c <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 c2 a4 10 80       	push   $0x8010a4c2
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 fb 2b 00 00       	call   801047da <releasesleep>
80101bdf:	83 c4 10             	add    $0x10,%esp
}
80101be2:	90                   	nop
80101be3:	c9                   	leave  
80101be4:	c3                   	ret    

80101be5 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101be5:	f3 0f 1e fb          	endbr32 
80101be9:	55                   	push   %ebp
80101bea:	89 e5                	mov    %esp,%ebp
80101bec:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	83 c0 0c             	add    $0xc,%eax
80101bf5:	83 ec 0c             	sub    $0xc,%esp
80101bf8:	50                   	push   %eax
80101bf9:	e8 74 2b 00 00       	call   80104772 <acquiresleep>
80101bfe:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c07:	85 c0                	test   %eax,%eax
80101c09:	74 6a                	je     80101c75 <iput+0x90>
80101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c12:	66 85 c0             	test   %ax,%ax
80101c15:	75 5e                	jne    80101c75 <iput+0x90>
    acquire(&icache.lock);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 80 37 19 80       	push   $0x80193780
80101c1f:	e8 a1 2c 00 00       	call   801048c5 <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 80 37 19 80       	push   $0x80193780
80101c38:	e8 fa 2c 00 00       	call   80104937 <release>
80101c3d:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c40:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c44:	75 2f                	jne    80101c75 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c46:	83 ec 0c             	sub    $0xc,%esp
80101c49:	ff 75 08             	pushl  0x8(%ebp)
80101c4c:	e8 b5 01 00 00       	call   80101e06 <itrunc>
80101c51:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	pushl  0x8(%ebp)
80101c63:	e8 2b fc ff ff       	call   80101893 <iupdate>
80101c68:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	83 c0 0c             	add    $0xc,%eax
80101c7b:	83 ec 0c             	sub    $0xc,%esp
80101c7e:	50                   	push   %eax
80101c7f:	e8 56 2b 00 00       	call   801047da <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 80 37 19 80       	push   $0x80193780
80101c8f:	e8 31 2c 00 00       	call   801048c5 <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	68 80 37 19 80       	push   $0x80193780
80101cae:	e8 84 2c 00 00       	call   80104937 <release>
80101cb3:	83 c4 10             	add    $0x10,%esp
}
80101cb6:	90                   	nop
80101cb7:	c9                   	leave  
80101cb8:	c3                   	ret    

80101cb9 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cb9:	f3 0f 1e fb          	endbr32 
80101cbd:	55                   	push   %ebp
80101cbe:	89 e5                	mov    %esp,%ebp
80101cc0:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cc3:	83 ec 0c             	sub    $0xc,%esp
80101cc6:	ff 75 08             	pushl  0x8(%ebp)
80101cc9:	e8 c5 fe ff ff       	call   80101b93 <iunlock>
80101cce:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cd1:	83 ec 0c             	sub    $0xc,%esp
80101cd4:	ff 75 08             	pushl  0x8(%ebp)
80101cd7:	e8 09 ff ff ff       	call   80101be5 <iput>
80101cdc:	83 c4 10             	add    $0x10,%esp
}
80101cdf:	90                   	nop
80101ce0:	c9                   	leave  
80101ce1:	c3                   	ret    

80101ce2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ce2:	f3 0f 1e fb          	endbr32 
80101ce6:	55                   	push   %ebp
80101ce7:	89 e5                	mov    %esp,%ebp
80101ce9:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cec:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cf0:	77 42                	ja     80101d34 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cf8:	83 c2 14             	add    $0x14,%edx
80101cfb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 24                	jne    80101d2c <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 b4 f7 ff ff       	call   801014ca <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d22:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d28:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2f:	e9 d0 00 00 00       	jmp    80101e04 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d34:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d38:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d3c:	0f 87 b5 00 00 00    	ja     80101df7 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d52:	75 20                	jne    80101d74 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	8b 00                	mov    (%eax),%eax
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	50                   	push   %eax
80101d5d:	e8 68 f7 ff ff       	call   801014ca <balloc>
80101d62:	83 c4 10             	add    $0x10,%esp
80101d65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	8b 00                	mov    (%eax),%eax
80101d79:	83 ec 08             	sub    $0x8,%esp
80101d7c:	ff 75 f4             	pushl  -0xc(%ebp)
80101d7f:	50                   	push   %eax
80101d80:	e8 84 e4 ff ff       	call   80100209 <bread>
80101d85:	83 c4 10             	add    $0x10,%esp
80101d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8e:	83 c0 5c             	add    $0x5c,%eax
80101d91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101da1:	01 d0                	add    %edx,%eax
80101da3:	8b 00                	mov    (%eax),%eax
80101da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dac:	75 36                	jne    80101de4 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101dae:	8b 45 08             	mov    0x8(%ebp),%eax
80101db1:	8b 00                	mov    (%eax),%eax
80101db3:	83 ec 0c             	sub    $0xc,%esp
80101db6:	50                   	push   %eax
80101db7:	e8 0e f7 ff ff       	call   801014ca <balloc>
80101dbc:	83 c4 10             	add    $0x10,%esp
80101dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dcf:	01 c2                	add    %eax,%edx
80101dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd4:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	ff 75 f0             	pushl  -0x10(%ebp)
80101ddc:	e8 d9 15 00 00       	call   801033ba <log_write>
80101de1:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101de4:	83 ec 0c             	sub    $0xc,%esp
80101de7:	ff 75 f0             	pushl  -0x10(%ebp)
80101dea:	e8 a4 e4 ff ff       	call   80100293 <brelse>
80101def:	83 c4 10             	add    $0x10,%esp
    return addr;
80101df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df5:	eb 0d                	jmp    80101e04 <bmap+0x122>
  }

  panic("bmap: out of range");
80101df7:	83 ec 0c             	sub    $0xc,%esp
80101dfa:	68 ca a4 10 80       	push   $0x8010a4ca
80101dff:	e8 c1 e7 ff ff       	call   801005c5 <panic>
}
80101e04:	c9                   	leave  
80101e05:	c3                   	ret    

80101e06 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e06:	f3 0f 1e fb          	endbr32 
80101e0a:	55                   	push   %ebp
80101e0b:	89 e5                	mov    %esp,%ebp
80101e0d:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e17:	eb 45                	jmp    80101e5e <itrunc+0x58>
    if(ip->addrs[i]){
80101e19:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e1f:	83 c2 14             	add    $0x14,%edx
80101e22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e26:	85 c0                	test   %eax,%eax
80101e28:	74 30                	je     80101e5a <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e30:	83 c2 14             	add    $0x14,%edx
80101e33:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e37:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3a:	8b 12                	mov    (%edx),%edx
80101e3c:	83 ec 08             	sub    $0x8,%esp
80101e3f:	50                   	push   %eax
80101e40:	52                   	push   %edx
80101e41:	e8 d4 f7 ff ff       	call   8010161a <bfree>
80101e46:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e49:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e4f:	83 c2 14             	add    $0x14,%edx
80101e52:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e59:	00 
  for(i = 0; i < NDIRECT; i++){
80101e5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e5e:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e62:	7e b5                	jle    80101e19 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e6d:	85 c0                	test   %eax,%eax
80101e6f:	0f 84 aa 00 00 00    	je     80101f1f <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	8b 00                	mov    (%eax),%eax
80101e83:	83 ec 08             	sub    $0x8,%esp
80101e86:	52                   	push   %edx
80101e87:	50                   	push   %eax
80101e88:	e8 7c e3 ff ff       	call   80100209 <bread>
80101e8d:	83 c4 10             	add    $0x10,%esp
80101e90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e96:	83 c0 5c             	add    $0x5c,%eax
80101e99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ea3:	eb 3c                	jmp    80101ee1 <itrunc+0xdb>
      if(a[j])
80101ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eb2:	01 d0                	add    %edx,%eax
80101eb4:	8b 00                	mov    (%eax),%eax
80101eb6:	85 c0                	test   %eax,%eax
80101eb8:	74 23                	je     80101edd <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec7:	01 d0                	add    %edx,%eax
80101ec9:	8b 00                	mov    (%eax),%eax
80101ecb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ece:	8b 12                	mov    (%edx),%edx
80101ed0:	83 ec 08             	sub    $0x8,%esp
80101ed3:	50                   	push   %eax
80101ed4:	52                   	push   %edx
80101ed5:	e8 40 f7 ff ff       	call   8010161a <bfree>
80101eda:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101edd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee4:	83 f8 7f             	cmp    $0x7f,%eax
80101ee7:	76 bc                	jbe    80101ea5 <itrunc+0x9f>
    }
    brelse(bp);
80101ee9:	83 ec 0c             	sub    $0xc,%esp
80101eec:	ff 75 ec             	pushl  -0x14(%ebp)
80101eef:	e8 9f e3 ff ff       	call   80100293 <brelse>
80101ef4:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f00:	8b 55 08             	mov    0x8(%ebp),%edx
80101f03:	8b 12                	mov    (%edx),%edx
80101f05:	83 ec 08             	sub    $0x8,%esp
80101f08:	50                   	push   %eax
80101f09:	52                   	push   %edx
80101f0a:	e8 0b f7 ff ff       	call   8010161a <bfree>
80101f0f:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f12:	8b 45 08             	mov    0x8(%ebp),%eax
80101f15:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f1c:	00 00 00 
  }

  ip->size = 0;
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f29:	83 ec 0c             	sub    $0xc,%esp
80101f2c:	ff 75 08             	pushl  0x8(%ebp)
80101f2f:	e8 5f f9 ff ff       	call   80101893 <iupdate>
80101f34:	83 c4 10             	add    $0x10,%esp
}
80101f37:	90                   	nop
80101f38:	c9                   	leave  
80101f39:	c3                   	ret    

80101f3a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f3a:	f3 0f 1e fb          	endbr32 
80101f3e:	55                   	push   %ebp
80101f3f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	8b 00                	mov    (%eax),%eax
80101f46:	89 c2                	mov    %eax,%edx
80101f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f4b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	8b 50 04             	mov    0x4(%eax),%edx
80101f54:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f57:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f61:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f64:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f67:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f71:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 50 58             	mov    0x58(%eax),%edx
80101f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f7e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f81:	90                   	nop
80101f82:	5d                   	pop    %ebp
80101f83:	c3                   	ret    

80101f84 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f84:	f3 0f 1e fb          	endbr32 
80101f88:	55                   	push   %ebp
80101f89:	89 e5                	mov    %esp,%ebp
80101f8b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f91:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f95:	66 83 f8 03          	cmp    $0x3,%ax
80101f99:	75 5c                	jne    80101ff7 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fa2:	66 85 c0             	test   %ax,%ax
80101fa5:	78 20                	js     80101fc7 <readi+0x43>
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fae:	66 83 f8 09          	cmp    $0x9,%ax
80101fb2:	7f 13                	jg     80101fc7 <readi+0x43>
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fbb:	98                   	cwtl   
80101fbc:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	75 0a                	jne    80101fd1 <readi+0x4d>
      return -1;
80101fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fcc:	e9 0a 01 00 00       	jmp    801020db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd8:	98                   	cwtl   
80101fd9:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fe0:	8b 55 14             	mov    0x14(%ebp),%edx
80101fe3:	83 ec 04             	sub    $0x4,%esp
80101fe6:	52                   	push   %edx
80101fe7:	ff 75 0c             	pushl  0xc(%ebp)
80101fea:	ff 75 08             	pushl  0x8(%ebp)
80101fed:	ff d0                	call   *%eax
80101fef:	83 c4 10             	add    $0x10,%esp
80101ff2:	e9 e4 00 00 00       	jmp    801020db <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffa:	8b 40 58             	mov    0x58(%eax),%eax
80101ffd:	39 45 10             	cmp    %eax,0x10(%ebp)
80102000:	77 0d                	ja     8010200f <readi+0x8b>
80102002:	8b 55 10             	mov    0x10(%ebp),%edx
80102005:	8b 45 14             	mov    0x14(%ebp),%eax
80102008:	01 d0                	add    %edx,%eax
8010200a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010200d:	76 0a                	jbe    80102019 <readi+0x95>
    return -1;
8010200f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102014:	e9 c2 00 00 00       	jmp    801020db <readi+0x157>
  if(off + n > ip->size)
80102019:	8b 55 10             	mov    0x10(%ebp),%edx
8010201c:	8b 45 14             	mov    0x14(%ebp),%eax
8010201f:	01 c2                	add    %eax,%edx
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	8b 40 58             	mov    0x58(%eax),%eax
80102027:	39 c2                	cmp    %eax,%edx
80102029:	76 0c                	jbe    80102037 <readi+0xb3>
    n = ip->size - off;
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	8b 40 58             	mov    0x58(%eax),%eax
80102031:	2b 45 10             	sub    0x10(%ebp),%eax
80102034:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102037:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010203e:	e9 89 00 00 00       	jmp    801020cc <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102043:	8b 45 10             	mov    0x10(%ebp),%eax
80102046:	c1 e8 09             	shr    $0x9,%eax
80102049:	83 ec 08             	sub    $0x8,%esp
8010204c:	50                   	push   %eax
8010204d:	ff 75 08             	pushl  0x8(%ebp)
80102050:	e8 8d fc ff ff       	call   80101ce2 <bmap>
80102055:	83 c4 10             	add    $0x10,%esp
80102058:	8b 55 08             	mov    0x8(%ebp),%edx
8010205b:	8b 12                	mov    (%edx),%edx
8010205d:	83 ec 08             	sub    $0x8,%esp
80102060:	50                   	push   %eax
80102061:	52                   	push   %edx
80102062:	e8 a2 e1 ff ff       	call   80100209 <bread>
80102067:	83 c4 10             	add    $0x10,%esp
8010206a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010206d:	8b 45 10             	mov    0x10(%ebp),%eax
80102070:	25 ff 01 00 00       	and    $0x1ff,%eax
80102075:	ba 00 02 00 00       	mov    $0x200,%edx
8010207a:	29 c2                	sub    %eax,%edx
8010207c:	8b 45 14             	mov    0x14(%ebp),%eax
8010207f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102082:	39 c2                	cmp    %eax,%edx
80102084:	0f 46 c2             	cmovbe %edx,%eax
80102087:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010208a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102090:	8b 45 10             	mov    0x10(%ebp),%eax
80102093:	25 ff 01 00 00       	and    $0x1ff,%eax
80102098:	01 d0                	add    %edx,%eax
8010209a:	83 ec 04             	sub    $0x4,%esp
8010209d:	ff 75 ec             	pushl  -0x14(%ebp)
801020a0:	50                   	push   %eax
801020a1:	ff 75 0c             	pushl  0xc(%ebp)
801020a4:	e8 72 2b 00 00       	call   80104c1b <memmove>
801020a9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020ac:	83 ec 0c             	sub    $0xc,%esp
801020af:	ff 75 f0             	pushl  -0x10(%ebp)
801020b2:	e8 dc e1 ff ff       	call   80100293 <brelse>
801020b7:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020bd:	01 45 f4             	add    %eax,-0xc(%ebp)
801020c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c3:	01 45 10             	add    %eax,0x10(%ebp)
801020c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c9:	01 45 0c             	add    %eax,0xc(%ebp)
801020cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020cf:	3b 45 14             	cmp    0x14(%ebp),%eax
801020d2:	0f 82 6b ff ff ff    	jb     80102043 <readi+0xbf>
  }
  return n;
801020d8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020db:	c9                   	leave  
801020dc:	c3                   	ret    

801020dd <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020dd:	f3 0f 1e fb          	endbr32 
801020e1:	55                   	push   %ebp
801020e2:	89 e5                	mov    %esp,%ebp
801020e4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020e7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ea:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020ee:	66 83 f8 03          	cmp    $0x3,%ax
801020f2:	75 5c                	jne    80102150 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020f4:	8b 45 08             	mov    0x8(%ebp),%eax
801020f7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020fb:	66 85 c0             	test   %ax,%ax
801020fe:	78 20                	js     80102120 <writei+0x43>
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102107:	66 83 f8 09          	cmp    $0x9,%ax
8010210b:	7f 13                	jg     80102120 <writei+0x43>
8010210d:	8b 45 08             	mov    0x8(%ebp),%eax
80102110:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102114:	98                   	cwtl   
80102115:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x4d>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3b 01 00 00       	jmp    80102265 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102131:	98                   	cwtl   
80102132:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102139:	8b 55 14             	mov    0x14(%ebp),%edx
8010213c:	83 ec 04             	sub    $0x4,%esp
8010213f:	52                   	push   %edx
80102140:	ff 75 0c             	pushl  0xc(%ebp)
80102143:	ff 75 08             	pushl  0x8(%ebp)
80102146:	ff d0                	call   *%eax
80102148:	83 c4 10             	add    $0x10,%esp
8010214b:	e9 15 01 00 00       	jmp    80102265 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 40 58             	mov    0x58(%eax),%eax
80102156:	39 45 10             	cmp    %eax,0x10(%ebp)
80102159:	77 0d                	ja     80102168 <writei+0x8b>
8010215b:	8b 55 10             	mov    0x10(%ebp),%edx
8010215e:	8b 45 14             	mov    0x14(%ebp),%eax
80102161:	01 d0                	add    %edx,%eax
80102163:	39 45 10             	cmp    %eax,0x10(%ebp)
80102166:	76 0a                	jbe    80102172 <writei+0x95>
    return -1;
80102168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216d:	e9 f3 00 00 00       	jmp    80102265 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102172:	8b 55 10             	mov    0x10(%ebp),%edx
80102175:	8b 45 14             	mov    0x14(%ebp),%eax
80102178:	01 d0                	add    %edx,%eax
8010217a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010217f:	76 0a                	jbe    8010218b <writei+0xae>
    return -1;
80102181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102186:	e9 da 00 00 00       	jmp    80102265 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010218b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102192:	e9 97 00 00 00       	jmp    8010222e <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102197:	8b 45 10             	mov    0x10(%ebp),%eax
8010219a:	c1 e8 09             	shr    $0x9,%eax
8010219d:	83 ec 08             	sub    $0x8,%esp
801021a0:	50                   	push   %eax
801021a1:	ff 75 08             	pushl  0x8(%ebp)
801021a4:	e8 39 fb ff ff       	call   80101ce2 <bmap>
801021a9:	83 c4 10             	add    $0x10,%esp
801021ac:	8b 55 08             	mov    0x8(%ebp),%edx
801021af:	8b 12                	mov    (%edx),%edx
801021b1:	83 ec 08             	sub    $0x8,%esp
801021b4:	50                   	push   %eax
801021b5:	52                   	push   %edx
801021b6:	e8 4e e0 ff ff       	call   80100209 <bread>
801021bb:	83 c4 10             	add    $0x10,%esp
801021be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021c1:	8b 45 10             	mov    0x10(%ebp),%eax
801021c4:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c9:	ba 00 02 00 00       	mov    $0x200,%edx
801021ce:	29 c2                	sub    %eax,%edx
801021d0:	8b 45 14             	mov    0x14(%ebp),%eax
801021d3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021d6:	39 c2                	cmp    %eax,%edx
801021d8:	0f 46 c2             	cmovbe %edx,%eax
801021db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e1:	8d 50 5c             	lea    0x5c(%eax),%edx
801021e4:	8b 45 10             	mov    0x10(%ebp),%eax
801021e7:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ec:	01 d0                	add    %edx,%eax
801021ee:	83 ec 04             	sub    $0x4,%esp
801021f1:	ff 75 ec             	pushl  -0x14(%ebp)
801021f4:	ff 75 0c             	pushl  0xc(%ebp)
801021f7:	50                   	push   %eax
801021f8:	e8 1e 2a 00 00       	call   80104c1b <memmove>
801021fd:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 f0             	pushl  -0x10(%ebp)
80102206:	e8 af 11 00 00       	call   801033ba <log_write>
8010220b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	ff 75 f0             	pushl  -0x10(%ebp)
80102214:	e8 7a e0 ff ff       	call   80100293 <brelse>
80102219:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010221c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010221f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102225:	01 45 10             	add    %eax,0x10(%ebp)
80102228:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010222b:	01 45 0c             	add    %eax,0xc(%ebp)
8010222e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102231:	3b 45 14             	cmp    0x14(%ebp),%eax
80102234:	0f 82 5d ff ff ff    	jb     80102197 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010223a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010223e:	74 22                	je     80102262 <writei+0x185>
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	8b 40 58             	mov    0x58(%eax),%eax
80102246:	39 45 10             	cmp    %eax,0x10(%ebp)
80102249:	76 17                	jbe    80102262 <writei+0x185>
    ip->size = off;
8010224b:	8b 45 08             	mov    0x8(%ebp),%eax
8010224e:	8b 55 10             	mov    0x10(%ebp),%edx
80102251:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102254:	83 ec 0c             	sub    $0xc,%esp
80102257:	ff 75 08             	pushl  0x8(%ebp)
8010225a:	e8 34 f6 ff ff       	call   80101893 <iupdate>
8010225f:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102262:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102265:	c9                   	leave  
80102266:	c3                   	ret    

80102267 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102267:	f3 0f 1e fb          	endbr32 
8010226b:	55                   	push   %ebp
8010226c:	89 e5                	mov    %esp,%ebp
8010226e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102271:	83 ec 04             	sub    $0x4,%esp
80102274:	6a 0e                	push   $0xe
80102276:	ff 75 0c             	pushl  0xc(%ebp)
80102279:	ff 75 08             	pushl  0x8(%ebp)
8010227c:	e8 38 2a 00 00       	call   80104cb9 <strncmp>
80102281:	83 c4 10             	add    $0x10,%esp
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102286:	f3 0f 1e fb          	endbr32 
8010228a:	55                   	push   %ebp
8010228b:	89 e5                	mov    %esp,%ebp
8010228d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102290:	8b 45 08             	mov    0x8(%ebp),%eax
80102293:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102297:	66 83 f8 01          	cmp    $0x1,%ax
8010229b:	74 0d                	je     801022aa <dirlookup+0x24>
    panic("dirlookup not DIR");
8010229d:	83 ec 0c             	sub    $0xc,%esp
801022a0:	68 dd a4 10 80       	push   $0x8010a4dd
801022a5:	e8 1b e3 ff ff       	call   801005c5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b1:	eb 7b                	jmp    8010232e <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b3:	6a 10                	push   $0x10
801022b5:	ff 75 f4             	pushl  -0xc(%ebp)
801022b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bb:	50                   	push   %eax
801022bc:	ff 75 08             	pushl  0x8(%ebp)
801022bf:	e8 c0 fc ff ff       	call   80101f84 <readi>
801022c4:	83 c4 10             	add    $0x10,%esp
801022c7:	83 f8 10             	cmp    $0x10,%eax
801022ca:	74 0d                	je     801022d9 <dirlookup+0x53>
      panic("dirlookup read");
801022cc:	83 ec 0c             	sub    $0xc,%esp
801022cf:	68 ef a4 10 80       	push   $0x8010a4ef
801022d4:	e8 ec e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801022d9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022dd:	66 85 c0             	test   %ax,%ax
801022e0:	74 47                	je     80102329 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801022e2:	83 ec 08             	sub    $0x8,%esp
801022e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e8:	83 c0 02             	add    $0x2,%eax
801022eb:	50                   	push   %eax
801022ec:	ff 75 0c             	pushl  0xc(%ebp)
801022ef:	e8 73 ff ff ff       	call   80102267 <namecmp>
801022f4:	83 c4 10             	add    $0x10,%esp
801022f7:	85 c0                	test   %eax,%eax
801022f9:	75 2f                	jne    8010232a <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801022fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022ff:	74 08                	je     80102309 <dirlookup+0x83>
        *poff = off;
80102301:	8b 45 10             	mov    0x10(%ebp),%eax
80102304:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102307:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102309:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010230d:	0f b7 c0             	movzwl %ax,%eax
80102310:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	8b 00                	mov    (%eax),%eax
80102318:	83 ec 08             	sub    $0x8,%esp
8010231b:	ff 75 f0             	pushl  -0x10(%ebp)
8010231e:	50                   	push   %eax
8010231f:	e8 34 f6 ff ff       	call   80101958 <iget>
80102324:	83 c4 10             	add    $0x10,%esp
80102327:	eb 19                	jmp    80102342 <dirlookup+0xbc>
      continue;
80102329:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010232a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010232e:	8b 45 08             	mov    0x8(%ebp),%eax
80102331:	8b 40 58             	mov    0x58(%eax),%eax
80102334:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102337:	0f 82 76 ff ff ff    	jb     801022b3 <dirlookup+0x2d>
    }
  }

  return 0;
8010233d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102342:	c9                   	leave  
80102343:	c3                   	ret    

80102344 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102344:	f3 0f 1e fb          	endbr32 
80102348:	55                   	push   %ebp
80102349:	89 e5                	mov    %esp,%ebp
8010234b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010234e:	83 ec 04             	sub    $0x4,%esp
80102351:	6a 00                	push   $0x0
80102353:	ff 75 0c             	pushl  0xc(%ebp)
80102356:	ff 75 08             	pushl  0x8(%ebp)
80102359:	e8 28 ff ff ff       	call   80102286 <dirlookup>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102364:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102368:	74 18                	je     80102382 <dirlink+0x3e>
    iput(ip);
8010236a:	83 ec 0c             	sub    $0xc,%esp
8010236d:	ff 75 f0             	pushl  -0x10(%ebp)
80102370:	e8 70 f8 ff ff       	call   80101be5 <iput>
80102375:	83 c4 10             	add    $0x10,%esp
    return -1;
80102378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010237d:	e9 9c 00 00 00       	jmp    8010241e <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102389:	eb 39                	jmp    801023c4 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010238b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238e:	6a 10                	push   $0x10
80102390:	50                   	push   %eax
80102391:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102394:	50                   	push   %eax
80102395:	ff 75 08             	pushl  0x8(%ebp)
80102398:	e8 e7 fb ff ff       	call   80101f84 <readi>
8010239d:	83 c4 10             	add    $0x10,%esp
801023a0:	83 f8 10             	cmp    $0x10,%eax
801023a3:	74 0d                	je     801023b2 <dirlink+0x6e>
      panic("dirlink read");
801023a5:	83 ec 0c             	sub    $0xc,%esp
801023a8:	68 fe a4 10 80       	push   $0x8010a4fe
801023ad:	e8 13 e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801023b2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023b6:	66 85 c0             	test   %ax,%ax
801023b9:	74 18                	je     801023d3 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023be:	83 c0 10             	add    $0x10,%eax
801023c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023c4:	8b 45 08             	mov    0x8(%ebp),%eax
801023c7:	8b 50 58             	mov    0x58(%eax),%edx
801023ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cd:	39 c2                	cmp    %eax,%edx
801023cf:	77 ba                	ja     8010238b <dirlink+0x47>
801023d1:	eb 01                	jmp    801023d4 <dirlink+0x90>
      break;
801023d3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	6a 0e                	push   $0xe
801023d9:	ff 75 0c             	pushl  0xc(%ebp)
801023dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023df:	83 c0 02             	add    $0x2,%eax
801023e2:	50                   	push   %eax
801023e3:	e8 2b 29 00 00       	call   80104d13 <strncpy>
801023e8:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023eb:	8b 45 10             	mov    0x10(%ebp),%eax
801023ee:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f5:	6a 10                	push   $0x10
801023f7:	50                   	push   %eax
801023f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023fb:	50                   	push   %eax
801023fc:	ff 75 08             	pushl  0x8(%ebp)
801023ff:	e8 d9 fc ff ff       	call   801020dd <writei>
80102404:	83 c4 10             	add    $0x10,%esp
80102407:	83 f8 10             	cmp    $0x10,%eax
8010240a:	74 0d                	je     80102419 <dirlink+0xd5>
    panic("dirlink");
8010240c:	83 ec 0c             	sub    $0xc,%esp
8010240f:	68 0b a5 10 80       	push   $0x8010a50b
80102414:	e8 ac e1 ff ff       	call   801005c5 <panic>

  return 0;
80102419:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010241e:	c9                   	leave  
8010241f:	c3                   	ret    

80102420 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102420:	f3 0f 1e fb          	endbr32 
80102424:	55                   	push   %ebp
80102425:	89 e5                	mov    %esp,%ebp
80102427:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010242a:	eb 04                	jmp    80102430 <skipelem+0x10>
    path++;
8010242c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102430:	8b 45 08             	mov    0x8(%ebp),%eax
80102433:	0f b6 00             	movzbl (%eax),%eax
80102436:	3c 2f                	cmp    $0x2f,%al
80102438:	74 f2                	je     8010242c <skipelem+0xc>
  if(*path == 0)
8010243a:	8b 45 08             	mov    0x8(%ebp),%eax
8010243d:	0f b6 00             	movzbl (%eax),%eax
80102440:	84 c0                	test   %al,%al
80102442:	75 07                	jne    8010244b <skipelem+0x2b>
    return 0;
80102444:	b8 00 00 00 00       	mov    $0x0,%eax
80102449:	eb 77                	jmp    801024c2 <skipelem+0xa2>
  s = path;
8010244b:	8b 45 08             	mov    0x8(%ebp),%eax
8010244e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102451:	eb 04                	jmp    80102457 <skipelem+0x37>
    path++;
80102453:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102457:	8b 45 08             	mov    0x8(%ebp),%eax
8010245a:	0f b6 00             	movzbl (%eax),%eax
8010245d:	3c 2f                	cmp    $0x2f,%al
8010245f:	74 0a                	je     8010246b <skipelem+0x4b>
80102461:	8b 45 08             	mov    0x8(%ebp),%eax
80102464:	0f b6 00             	movzbl (%eax),%eax
80102467:	84 c0                	test   %al,%al
80102469:	75 e8                	jne    80102453 <skipelem+0x33>
  len = path - s;
8010246b:	8b 45 08             	mov    0x8(%ebp),%eax
8010246e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102471:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102474:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102478:	7e 15                	jle    8010248f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010247a:	83 ec 04             	sub    $0x4,%esp
8010247d:	6a 0e                	push   $0xe
8010247f:	ff 75 f4             	pushl  -0xc(%ebp)
80102482:	ff 75 0c             	pushl  0xc(%ebp)
80102485:	e8 91 27 00 00       	call   80104c1b <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 7a 27 00 00       	call   80104c1b <memmove>
801024a1:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024aa:	01 d0                	add    %edx,%eax
801024ac:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024af:	eb 04                	jmp    801024b5 <skipelem+0x95>
    path++;
801024b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024b5:	8b 45 08             	mov    0x8(%ebp),%eax
801024b8:	0f b6 00             	movzbl (%eax),%eax
801024bb:	3c 2f                	cmp    $0x2f,%al
801024bd:	74 f2                	je     801024b1 <skipelem+0x91>
  return path;
801024bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024c2:	c9                   	leave  
801024c3:	c3                   	ret    

801024c4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024c4:	f3 0f 1e fb          	endbr32 
801024c8:	55                   	push   %ebp
801024c9:	89 e5                	mov    %esp,%ebp
801024cb:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	0f b6 00             	movzbl (%eax),%eax
801024d4:	3c 2f                	cmp    $0x2f,%al
801024d6:	75 17                	jne    801024ef <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024d8:	83 ec 08             	sub    $0x8,%esp
801024db:	6a 01                	push   $0x1
801024dd:	6a 01                	push   $0x1
801024df:	e8 74 f4 ff ff       	call   80101958 <iget>
801024e4:	83 c4 10             	add    $0x10,%esp
801024e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024ea:	e9 ba 00 00 00       	jmp    801025a9 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801024ef:	e8 b5 16 00 00       	call   80103ba9 <myproc>
801024f4:	8b 40 68             	mov    0x68(%eax),%eax
801024f7:	83 ec 0c             	sub    $0xc,%esp
801024fa:	50                   	push   %eax
801024fb:	e8 3e f5 ff ff       	call   80101a3e <idup>
80102500:	83 c4 10             	add    $0x10,%esp
80102503:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102506:	e9 9e 00 00 00       	jmp    801025a9 <namex+0xe5>
    ilock(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	pushl  -0xc(%ebp)
80102511:	e8 66 f5 ff ff       	call   80101a7c <ilock>
80102516:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102520:	66 83 f8 01          	cmp    $0x1,%ax
80102524:	74 18                	je     8010253e <namex+0x7a>
      iunlockput(ip);
80102526:	83 ec 0c             	sub    $0xc,%esp
80102529:	ff 75 f4             	pushl  -0xc(%ebp)
8010252c:	e8 88 f7 ff ff       	call   80101cb9 <iunlockput>
80102531:	83 c4 10             	add    $0x10,%esp
      return 0;
80102534:	b8 00 00 00 00       	mov    $0x0,%eax
80102539:	e9 a7 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010253e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102542:	74 20                	je     80102564 <namex+0xa0>
80102544:	8b 45 08             	mov    0x8(%ebp),%eax
80102547:	0f b6 00             	movzbl (%eax),%eax
8010254a:	84 c0                	test   %al,%al
8010254c:	75 16                	jne    80102564 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010254e:	83 ec 0c             	sub    $0xc,%esp
80102551:	ff 75 f4             	pushl  -0xc(%ebp)
80102554:	e8 3a f6 ff ff       	call   80101b93 <iunlock>
80102559:	83 c4 10             	add    $0x10,%esp
      return ip;
8010255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010255f:	e9 81 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102564:	83 ec 04             	sub    $0x4,%esp
80102567:	6a 00                	push   $0x0
80102569:	ff 75 10             	pushl  0x10(%ebp)
8010256c:	ff 75 f4             	pushl  -0xc(%ebp)
8010256f:	e8 12 fd ff ff       	call   80102286 <dirlookup>
80102574:	83 c4 10             	add    $0x10,%esp
80102577:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010257a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010257e:	75 15                	jne    80102595 <namex+0xd1>
      iunlockput(ip);
80102580:	83 ec 0c             	sub    $0xc,%esp
80102583:	ff 75 f4             	pushl  -0xc(%ebp)
80102586:	e8 2e f7 ff ff       	call   80101cb9 <iunlockput>
8010258b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010258e:	b8 00 00 00 00       	mov    $0x0,%eax
80102593:	eb 50                	jmp    801025e5 <namex+0x121>
    }
    iunlockput(ip);
80102595:	83 ec 0c             	sub    $0xc,%esp
80102598:	ff 75 f4             	pushl  -0xc(%ebp)
8010259b:	e8 19 f7 ff ff       	call   80101cb9 <iunlockput>
801025a0:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025a9:	83 ec 08             	sub    $0x8,%esp
801025ac:	ff 75 10             	pushl  0x10(%ebp)
801025af:	ff 75 08             	pushl  0x8(%ebp)
801025b2:	e8 69 fe ff ff       	call   80102420 <skipelem>
801025b7:	83 c4 10             	add    $0x10,%esp
801025ba:	89 45 08             	mov    %eax,0x8(%ebp)
801025bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c1:	0f 85 44 ff ff ff    	jne    8010250b <namex+0x47>
  }
  if(nameiparent){
801025c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025cb:	74 15                	je     801025e2 <namex+0x11e>
    iput(ip);
801025cd:	83 ec 0c             	sub    $0xc,%esp
801025d0:	ff 75 f4             	pushl  -0xc(%ebp)
801025d3:	e8 0d f6 ff ff       	call   80101be5 <iput>
801025d8:	83 c4 10             	add    $0x10,%esp
    return 0;
801025db:	b8 00 00 00 00       	mov    $0x0,%eax
801025e0:	eb 03                	jmp    801025e5 <namex+0x121>
  }
  return ip;
801025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025e5:	c9                   	leave  
801025e6:	c3                   	ret    

801025e7 <namei>:

struct inode*
namei(char *path)
{
801025e7:	f3 0f 1e fb          	endbr32 
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025f1:	83 ec 04             	sub    $0x4,%esp
801025f4:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025f7:	50                   	push   %eax
801025f8:	6a 00                	push   $0x0
801025fa:	ff 75 08             	pushl  0x8(%ebp)
801025fd:	e8 c2 fe ff ff       	call   801024c4 <namex>
80102602:	83 c4 10             	add    $0x10,%esp
}
80102605:	c9                   	leave  
80102606:	c3                   	ret    

80102607 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102607:	f3 0f 1e fb          	endbr32 
8010260b:	55                   	push   %ebp
8010260c:	89 e5                	mov    %esp,%ebp
8010260e:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102611:	83 ec 04             	sub    $0x4,%esp
80102614:	ff 75 0c             	pushl  0xc(%ebp)
80102617:	6a 01                	push   $0x1
80102619:	ff 75 08             	pushl  0x8(%ebp)
8010261c:	e8 a3 fe ff ff       	call   801024c4 <namex>
80102621:	83 c4 10             	add    $0x10,%esp
}
80102624:	c9                   	leave  
80102625:	c3                   	ret    

80102626 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102626:	f3 0f 1e fb          	endbr32 
8010262a:	55                   	push   %ebp
8010262b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010262d:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102632:	8b 55 08             	mov    0x8(%ebp),%edx
80102635:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102637:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010263c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010263f:	5d                   	pop    %ebp
80102640:	c3                   	ret    

80102641 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102641:	f3 0f 1e fb          	endbr32 
80102645:	55                   	push   %ebp
80102646:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102648:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010264d:	8b 55 08             	mov    0x8(%ebp),%edx
80102650:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102652:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102657:	8b 55 0c             	mov    0xc(%ebp),%edx
8010265a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010265d:	90                   	nop
8010265e:	5d                   	pop    %ebp
8010265f:	c3                   	ret    

80102660 <ioapicinit>:

void
ioapicinit(void)
{
80102660:	f3 0f 1e fb          	endbr32 
80102664:	55                   	push   %ebp
80102665:	89 e5                	mov    %esp,%ebp
80102667:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010266a:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
80102671:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102674:	6a 01                	push   $0x1
80102676:	e8 ab ff ff ff       	call   80102626 <ioapicread>
8010267b:	83 c4 04             	add    $0x4,%esp
8010267e:	c1 e8 10             	shr    $0x10,%eax
80102681:	25 ff 00 00 00       	and    $0xff,%eax
80102686:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102689:	6a 00                	push   $0x0
8010268b:	e8 96 ff ff ff       	call   80102626 <ioapicread>
80102690:	83 c4 04             	add    $0x4,%esp
80102693:	c1 e8 18             	shr    $0x18,%eax
80102696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102699:	0f b6 05 a0 7c 19 80 	movzbl 0x80197ca0,%eax
801026a0:	0f b6 c0             	movzbl %al,%eax
801026a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026a6:	74 10                	je     801026b8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 14 a5 10 80       	push   $0x8010a514
801026b0:	e8 57 dd ff ff       	call   8010040c <cprintf>
801026b5:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801026b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026bf:	eb 3f                	jmp    80102700 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c4:	83 c0 20             	add    $0x20,%eax
801026c7:	0d 00 00 01 00       	or     $0x10000,%eax
801026cc:	89 c2                	mov    %eax,%edx
801026ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d1:	83 c0 08             	add    $0x8,%eax
801026d4:	01 c0                	add    %eax,%eax
801026d6:	83 ec 08             	sub    $0x8,%esp
801026d9:	52                   	push   %edx
801026da:	50                   	push   %eax
801026db:	e8 61 ff ff ff       	call   80102641 <ioapicwrite>
801026e0:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801026e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e6:	83 c0 08             	add    $0x8,%eax
801026e9:	01 c0                	add    %eax,%eax
801026eb:	83 c0 01             	add    $0x1,%eax
801026ee:	83 ec 08             	sub    $0x8,%esp
801026f1:	6a 00                	push   $0x0
801026f3:	50                   	push   %eax
801026f4:	e8 48 ff ff ff       	call   80102641 <ioapicwrite>
801026f9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
801026fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102703:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102706:	7e b9                	jle    801026c1 <ioapicinit+0x61>
  }
}
80102708:	90                   	nop
80102709:	90                   	nop
8010270a:	c9                   	leave  
8010270b:	c3                   	ret    

8010270c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010270c:	f3 0f 1e fb          	endbr32 
80102710:	55                   	push   %ebp
80102711:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102713:	8b 45 08             	mov    0x8(%ebp),%eax
80102716:	83 c0 20             	add    $0x20,%eax
80102719:	89 c2                	mov    %eax,%edx
8010271b:	8b 45 08             	mov    0x8(%ebp),%eax
8010271e:	83 c0 08             	add    $0x8,%eax
80102721:	01 c0                	add    %eax,%eax
80102723:	52                   	push   %edx
80102724:	50                   	push   %eax
80102725:	e8 17 ff ff ff       	call   80102641 <ioapicwrite>
8010272a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010272d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102730:	c1 e0 18             	shl    $0x18,%eax
80102733:	89 c2                	mov    %eax,%edx
80102735:	8b 45 08             	mov    0x8(%ebp),%eax
80102738:	83 c0 08             	add    $0x8,%eax
8010273b:	01 c0                	add    %eax,%eax
8010273d:	83 c0 01             	add    $0x1,%eax
80102740:	52                   	push   %edx
80102741:	50                   	push   %eax
80102742:	e8 fa fe ff ff       	call   80102641 <ioapicwrite>
80102747:	83 c4 08             	add    $0x8,%esp
}
8010274a:	90                   	nop
8010274b:	c9                   	leave  
8010274c:	c3                   	ret    

8010274d <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010274d:	f3 0f 1e fb          	endbr32 
80102751:	55                   	push   %ebp
80102752:	89 e5                	mov    %esp,%ebp
80102754:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	68 46 a5 10 80       	push   $0x8010a546
8010275f:	68 e0 53 19 80       	push   $0x801953e0
80102764:	e8 36 21 00 00       	call   8010489f <initlock>
80102769:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010276c:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
80102773:	00 00 00 
  freerange(vstart, vend);
80102776:	83 ec 08             	sub    $0x8,%esp
80102779:	ff 75 0c             	pushl  0xc(%ebp)
8010277c:	ff 75 08             	pushl  0x8(%ebp)
8010277f:	e8 2e 00 00 00       	call   801027b2 <freerange>
80102784:	83 c4 10             	add    $0x10,%esp
}
80102787:	90                   	nop
80102788:	c9                   	leave  
80102789:	c3                   	ret    

8010278a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010278a:	f3 0f 1e fb          	endbr32 
8010278e:	55                   	push   %ebp
8010278f:	89 e5                	mov    %esp,%ebp
80102791:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102794:	83 ec 08             	sub    $0x8,%esp
80102797:	ff 75 0c             	pushl  0xc(%ebp)
8010279a:	ff 75 08             	pushl  0x8(%ebp)
8010279d:	e8 10 00 00 00       	call   801027b2 <freerange>
801027a2:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801027a5:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
801027ac:	00 00 00 
}
801027af:	90                   	nop
801027b0:	c9                   	leave  
801027b1:	c3                   	ret    

801027b2 <freerange>:

void
freerange(void *vstart, void *vend)
{
801027b2:	f3 0f 1e fb          	endbr32 
801027b6:	55                   	push   %ebp
801027b7:	89 e5                	mov    %esp,%ebp
801027b9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801027bc:	8b 45 08             	mov    0x8(%ebp),%eax
801027bf:	05 ff 0f 00 00       	add    $0xfff,%eax
801027c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801027c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027cc:	eb 15                	jmp    801027e3 <freerange+0x31>
    kfree(p);
801027ce:	83 ec 0c             	sub    $0xc,%esp
801027d1:	ff 75 f4             	pushl  -0xc(%ebp)
801027d4:	e8 1b 00 00 00       	call   801027f4 <kfree>
801027d9:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801027e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e6:	05 00 10 00 00       	add    $0x1000,%eax
801027eb:	39 45 0c             	cmp    %eax,0xc(%ebp)
801027ee:	73 de                	jae    801027ce <freerange+0x1c>
}
801027f0:	90                   	nop
801027f1:	90                   	nop
801027f2:	c9                   	leave  
801027f3:	c3                   	ret    

801027f4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801027f4:	f3 0f 1e fb          	endbr32 
801027f8:	55                   	push   %ebp
801027f9:	89 e5                	mov    %esp,%ebp
801027fb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801027fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102801:	25 ff 0f 00 00       	and    $0xfff,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 18                	jne    80102822 <kfree+0x2e>
8010280a:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
80102811:	72 0f                	jb     80102822 <kfree+0x2e>
80102813:	8b 45 08             	mov    0x8(%ebp),%eax
80102816:	05 00 00 00 80       	add    $0x80000000,%eax
8010281b:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102820:	76 0d                	jbe    8010282f <kfree+0x3b>
    panic("kfree");
80102822:	83 ec 0c             	sub    $0xc,%esp
80102825:	68 4b a5 10 80       	push   $0x8010a54b
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	pushl  0x8(%ebp)
8010283c:	e8 13 23 00 00       	call   80104b54 <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 14 54 19 80       	mov    0x80195414,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 e0 53 19 80       	push   $0x801953e0
80102855:	e8 6b 20 00 00       	call   801048c5 <acquire>
8010285a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102863:	8b 15 18 54 19 80    	mov    0x80195418,%edx
80102869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010286e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102871:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
80102876:	a1 14 54 19 80       	mov    0x80195414,%eax
8010287b:	85 c0                	test   %eax,%eax
8010287d:	74 10                	je     8010288f <kfree+0x9b>
    release(&kmem.lock);
8010287f:	83 ec 0c             	sub    $0xc,%esp
80102882:	68 e0 53 19 80       	push   $0x801953e0
80102887:	e8 ab 20 00 00       	call   80104937 <release>
8010288c:	83 c4 10             	add    $0x10,%esp
}
8010288f:	90                   	nop
80102890:	c9                   	leave  
80102891:	c3                   	ret    

80102892 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102892:	f3 0f 1e fb          	endbr32 
80102896:	55                   	push   %ebp
80102897:	89 e5                	mov    %esp,%ebp
80102899:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010289c:	a1 14 54 19 80       	mov    0x80195414,%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	74 10                	je     801028b5 <kalloc+0x23>
    acquire(&kmem.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 e0 53 19 80       	push   $0x801953e0
801028ad:	e8 13 20 00 00       	call   801048c5 <acquire>
801028b2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028b5:	a1 18 54 19 80       	mov    0x80195418,%eax
801028ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028c1:	74 0a                	je     801028cd <kalloc+0x3b>
    kmem.freelist = r->next;
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	8b 00                	mov    (%eax),%eax
801028c8:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028cd:	a1 14 54 19 80       	mov    0x80195414,%eax
801028d2:	85 c0                	test   %eax,%eax
801028d4:	74 10                	je     801028e6 <kalloc+0x54>
    release(&kmem.lock);
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	68 e0 53 19 80       	push   $0x801953e0
801028de:	e8 54 20 00 00       	call   80104937 <release>
801028e3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801028e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801028e9:	c9                   	leave  
801028ea:	c3                   	ret    

801028eb <inb>:
{
801028eb:	55                   	push   %ebp
801028ec:	89 e5                	mov    %esp,%ebp
801028ee:	83 ec 14             	sub    $0x14,%esp
801028f1:	8b 45 08             	mov    0x8(%ebp),%eax
801028f4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028f8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801028fc:	89 c2                	mov    %eax,%edx
801028fe:	ec                   	in     (%dx),%al
801028ff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102902:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102906:	c9                   	leave  
80102907:	c3                   	ret    

80102908 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102908:	f3 0f 1e fb          	endbr32 
8010290c:	55                   	push   %ebp
8010290d:	89 e5                	mov    %esp,%ebp
8010290f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102912:	6a 64                	push   $0x64
80102914:	e8 d2 ff ff ff       	call   801028eb <inb>
80102919:	83 c4 04             	add    $0x4,%esp
8010291c:	0f b6 c0             	movzbl %al,%eax
8010291f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102925:	83 e0 01             	and    $0x1,%eax
80102928:	85 c0                	test   %eax,%eax
8010292a:	75 0a                	jne    80102936 <kbdgetc+0x2e>
    return -1;
8010292c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102931:	e9 23 01 00 00       	jmp    80102a59 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102936:	6a 60                	push   $0x60
80102938:	e8 ae ff ff ff       	call   801028eb <inb>
8010293d:	83 c4 04             	add    $0x4,%esp
80102940:	0f b6 c0             	movzbl %al,%eax
80102943:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102946:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010294d:	75 17                	jne    80102966 <kbdgetc+0x5e>
    shift |= E0ESC;
8010294f:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102954:	83 c8 40             	or     $0x40,%eax
80102957:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
8010295c:	b8 00 00 00 00       	mov    $0x0,%eax
80102961:	e9 f3 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(data & 0x80){
80102966:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102969:	25 80 00 00 00       	and    $0x80,%eax
8010296e:	85 c0                	test   %eax,%eax
80102970:	74 45                	je     801029b7 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102972:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102977:	83 e0 40             	and    $0x40,%eax
8010297a:	85 c0                	test   %eax,%eax
8010297c:	75 08                	jne    80102986 <kbdgetc+0x7e>
8010297e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102981:	83 e0 7f             	and    $0x7f,%eax
80102984:	eb 03                	jmp    80102989 <kbdgetc+0x81>
80102986:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102989:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010298c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010298f:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102994:	0f b6 00             	movzbl (%eax),%eax
80102997:	83 c8 40             	or     $0x40,%eax
8010299a:	0f b6 c0             	movzbl %al,%eax
8010299d:	f7 d0                	not    %eax
8010299f:	89 c2                	mov    %eax,%edx
801029a1:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029a6:	21 d0                	and    %edx,%eax
801029a8:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029ad:	b8 00 00 00 00       	mov    $0x0,%eax
801029b2:	e9 a2 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(shift & E0ESC){
801029b7:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029bc:	83 e0 40             	and    $0x40,%eax
801029bf:	85 c0                	test   %eax,%eax
801029c1:	74 14                	je     801029d7 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029c3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801029ca:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029cf:	83 e0 bf             	and    $0xffffffbf,%eax
801029d2:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
801029d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029da:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029df:	0f b6 00             	movzbl (%eax),%eax
801029e2:	0f b6 d0             	movzbl %al,%edx
801029e5:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029ea:	09 d0                	or     %edx,%eax
801029ec:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
801029f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029f4:	05 20 d1 10 80       	add    $0x8010d120,%eax
801029f9:	0f b6 00             	movzbl (%eax),%eax
801029fc:	0f b6 d0             	movzbl %al,%edx
801029ff:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a04:	31 d0                	xor    %edx,%eax
80102a06:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a0b:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a10:	83 e0 03             	and    $0x3,%eax
80102a13:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a1d:	01 d0                	add    %edx,%eax
80102a1f:	0f b6 00             	movzbl (%eax),%eax
80102a22:	0f b6 c0             	movzbl %al,%eax
80102a25:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a28:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a2d:	83 e0 08             	and    $0x8,%eax
80102a30:	85 c0                	test   %eax,%eax
80102a32:	74 22                	je     80102a56 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a34:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a38:	76 0c                	jbe    80102a46 <kbdgetc+0x13e>
80102a3a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a3e:	77 06                	ja     80102a46 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a40:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102a44:	eb 10                	jmp    80102a56 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102a46:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102a4a:	76 0a                	jbe    80102a56 <kbdgetc+0x14e>
80102a4c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102a50:	77 04                	ja     80102a56 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102a52:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102a56:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102a59:	c9                   	leave  
80102a5a:	c3                   	ret    

80102a5b <kbdintr>:

void
kbdintr(void)
{
80102a5b:	f3 0f 1e fb          	endbr32 
80102a5f:	55                   	push   %ebp
80102a60:	89 e5                	mov    %esp,%ebp
80102a62:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	68 08 29 10 80       	push   $0x80102908
80102a6d:	e8 8e dd ff ff       	call   80100800 <consoleintr>
80102a72:	83 c4 10             	add    $0x10,%esp
}
80102a75:	90                   	nop
80102a76:	c9                   	leave  
80102a77:	c3                   	ret    

80102a78 <inb>:
{
80102a78:	55                   	push   %ebp
80102a79:	89 e5                	mov    %esp,%ebp
80102a7b:	83 ec 14             	sub    $0x14,%esp
80102a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a81:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a85:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102a89:	89 c2                	mov    %eax,%edx
80102a8b:	ec                   	in     (%dx),%al
80102a8c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102a8f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102a93:	c9                   	leave  
80102a94:	c3                   	ret    

80102a95 <outb>:
{
80102a95:	55                   	push   %ebp
80102a96:	89 e5                	mov    %esp,%ebp
80102a98:	83 ec 08             	sub    $0x8,%esp
80102a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102aa1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102aa5:	89 d0                	mov    %edx,%eax
80102aa7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aaa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102aae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ab2:	ee                   	out    %al,(%dx)
}
80102ab3:	90                   	nop
80102ab4:	c9                   	leave  
80102ab5:	c3                   	ret    

80102ab6 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ab6:	f3 0f 1e fb          	endbr32 
80102aba:	55                   	push   %ebp
80102abb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102abd:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac5:	c1 e2 02             	shl    $0x2,%edx
80102ac8:	01 c2                	add    %eax,%edx
80102aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80102acd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102acf:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ad4:	83 c0 20             	add    $0x20,%eax
80102ad7:	8b 00                	mov    (%eax),%eax
}
80102ad9:	90                   	nop
80102ada:	5d                   	pop    %ebp
80102adb:	c3                   	ret    

80102adc <lapicinit>:

void
lapicinit(void)
{
80102adc:	f3 0f 1e fb          	endbr32 
80102ae0:	55                   	push   %ebp
80102ae1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ae3:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ae8:	85 c0                	test   %eax,%eax
80102aea:	0f 84 0c 01 00 00    	je     80102bfc <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102af0:	68 3f 01 00 00       	push   $0x13f
80102af5:	6a 3c                	push   $0x3c
80102af7:	e8 ba ff ff ff       	call   80102ab6 <lapicw>
80102afc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102aff:	6a 0b                	push   $0xb
80102b01:	68 f8 00 00 00       	push   $0xf8
80102b06:	e8 ab ff ff ff       	call   80102ab6 <lapicw>
80102b0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b0e:	68 20 00 02 00       	push   $0x20020
80102b13:	68 c8 00 00 00       	push   $0xc8
80102b18:	e8 99 ff ff ff       	call   80102ab6 <lapicw>
80102b1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b20:	68 80 96 98 00       	push   $0x989680
80102b25:	68 e0 00 00 00       	push   $0xe0
80102b2a:	e8 87 ff ff ff       	call   80102ab6 <lapicw>
80102b2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b32:	68 00 00 01 00       	push   $0x10000
80102b37:	68 d4 00 00 00       	push   $0xd4
80102b3c:	e8 75 ff ff ff       	call   80102ab6 <lapicw>
80102b41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102b44:	68 00 00 01 00       	push   $0x10000
80102b49:	68 d8 00 00 00       	push   $0xd8
80102b4e:	e8 63 ff ff ff       	call   80102ab6 <lapicw>
80102b53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b56:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b5b:	83 c0 30             	add    $0x30,%eax
80102b5e:	8b 00                	mov    (%eax),%eax
80102b60:	c1 e8 10             	shr    $0x10,%eax
80102b63:	25 fc 00 00 00       	and    $0xfc,%eax
80102b68:	85 c0                	test   %eax,%eax
80102b6a:	74 12                	je     80102b7e <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102b6c:	68 00 00 01 00       	push   $0x10000
80102b71:	68 d0 00 00 00       	push   $0xd0
80102b76:	e8 3b ff ff ff       	call   80102ab6 <lapicw>
80102b7b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102b7e:	6a 33                	push   $0x33
80102b80:	68 dc 00 00 00       	push   $0xdc
80102b85:	e8 2c ff ff ff       	call   80102ab6 <lapicw>
80102b8a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102b8d:	6a 00                	push   $0x0
80102b8f:	68 a0 00 00 00       	push   $0xa0
80102b94:	e8 1d ff ff ff       	call   80102ab6 <lapicw>
80102b99:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102b9c:	6a 00                	push   $0x0
80102b9e:	68 a0 00 00 00       	push   $0xa0
80102ba3:	e8 0e ff ff ff       	call   80102ab6 <lapicw>
80102ba8:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102bab:	6a 00                	push   $0x0
80102bad:	6a 2c                	push   $0x2c
80102baf:	e8 02 ff ff ff       	call   80102ab6 <lapicw>
80102bb4:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102bb7:	6a 00                	push   $0x0
80102bb9:	68 c4 00 00 00       	push   $0xc4
80102bbe:	e8 f3 fe ff ff       	call   80102ab6 <lapicw>
80102bc3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102bc6:	68 00 85 08 00       	push   $0x88500
80102bcb:	68 c0 00 00 00       	push   $0xc0
80102bd0:	e8 e1 fe ff ff       	call   80102ab6 <lapicw>
80102bd5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102bd8:	90                   	nop
80102bd9:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bde:	05 00 03 00 00       	add    $0x300,%eax
80102be3:	8b 00                	mov    (%eax),%eax
80102be5:	25 00 10 00 00       	and    $0x1000,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	75 eb                	jne    80102bd9 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102bee:	6a 00                	push   $0x0
80102bf0:	6a 20                	push   $0x20
80102bf2:	e8 bf fe ff ff       	call   80102ab6 <lapicw>
80102bf7:	83 c4 08             	add    $0x8,%esp
80102bfa:	eb 01                	jmp    80102bfd <lapicinit+0x121>
    return;
80102bfc:	90                   	nop
}
80102bfd:	c9                   	leave  
80102bfe:	c3                   	ret    

80102bff <lapicid>:

int
lapicid(void)
{
80102bff:	f3 0f 1e fb          	endbr32 
80102c03:	55                   	push   %ebp
80102c04:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c06:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c0b:	85 c0                	test   %eax,%eax
80102c0d:	75 07                	jne    80102c16 <lapicid+0x17>
    return 0;
80102c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c14:	eb 0d                	jmp    80102c23 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c16:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c1b:	83 c0 20             	add    $0x20,%eax
80102c1e:	8b 00                	mov    (%eax),%eax
80102c20:	c1 e8 18             	shr    $0x18,%eax
}
80102c23:	5d                   	pop    %ebp
80102c24:	c3                   	ret    

80102c25 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c25:	f3 0f 1e fb          	endbr32 
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c2c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	74 0c                	je     80102c41 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c35:	6a 00                	push   $0x0
80102c37:	6a 2c                	push   $0x2c
80102c39:	e8 78 fe ff ff       	call   80102ab6 <lapicw>
80102c3e:	83 c4 08             	add    $0x8,%esp
}
80102c41:	90                   	nop
80102c42:	c9                   	leave  
80102c43:	c3                   	ret    

80102c44 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c44:	f3 0f 1e fb          	endbr32 
80102c48:	55                   	push   %ebp
80102c49:	89 e5                	mov    %esp,%ebp
}
80102c4b:	90                   	nop
80102c4c:	5d                   	pop    %ebp
80102c4d:	c3                   	ret    

80102c4e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c4e:	f3 0f 1e fb          	endbr32 
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
80102c55:	83 ec 14             	sub    $0x14,%esp
80102c58:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102c5e:	6a 0f                	push   $0xf
80102c60:	6a 70                	push   $0x70
80102c62:	e8 2e fe ff ff       	call   80102a95 <outb>
80102c67:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102c6a:	6a 0a                	push   $0xa
80102c6c:	6a 71                	push   $0x71
80102c6e:	e8 22 fe ff ff       	call   80102a95 <outb>
80102c73:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102c76:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102c7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c80:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102c85:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c88:	c1 e8 04             	shr    $0x4,%eax
80102c8b:	89 c2                	mov    %eax,%edx
80102c8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c90:	83 c0 02             	add    $0x2,%eax
80102c93:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102c96:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102c9a:	c1 e0 18             	shl    $0x18,%eax
80102c9d:	50                   	push   %eax
80102c9e:	68 c4 00 00 00       	push   $0xc4
80102ca3:	e8 0e fe ff ff       	call   80102ab6 <lapicw>
80102ca8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102cab:	68 00 c5 00 00       	push   $0xc500
80102cb0:	68 c0 00 00 00       	push   $0xc0
80102cb5:	e8 fc fd ff ff       	call   80102ab6 <lapicw>
80102cba:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102cbd:	68 c8 00 00 00       	push   $0xc8
80102cc2:	e8 7d ff ff ff       	call   80102c44 <microdelay>
80102cc7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102cca:	68 00 85 00 00       	push   $0x8500
80102ccf:	68 c0 00 00 00       	push   $0xc0
80102cd4:	e8 dd fd ff ff       	call   80102ab6 <lapicw>
80102cd9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102cdc:	6a 64                	push   $0x64
80102cde:	e8 61 ff ff ff       	call   80102c44 <microdelay>
80102ce3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ce6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102ced:	eb 3d                	jmp    80102d2c <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102cef:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102cf3:	c1 e0 18             	shl    $0x18,%eax
80102cf6:	50                   	push   %eax
80102cf7:	68 c4 00 00 00       	push   $0xc4
80102cfc:	e8 b5 fd ff ff       	call   80102ab6 <lapicw>
80102d01:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d07:	c1 e8 0c             	shr    $0xc,%eax
80102d0a:	80 cc 06             	or     $0x6,%ah
80102d0d:	50                   	push   %eax
80102d0e:	68 c0 00 00 00       	push   $0xc0
80102d13:	e8 9e fd ff ff       	call   80102ab6 <lapicw>
80102d18:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d1b:	68 c8 00 00 00       	push   $0xc8
80102d20:	e8 1f ff ff ff       	call   80102c44 <microdelay>
80102d25:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d2c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d30:	7e bd                	jle    80102cef <lapicstartap+0xa1>
  }
}
80102d32:	90                   	nop
80102d33:	90                   	nop
80102d34:	c9                   	leave  
80102d35:	c3                   	ret    

80102d36 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d36:	f3 0f 1e fb          	endbr32 
80102d3a:	55                   	push   %ebp
80102d3b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d40:	0f b6 c0             	movzbl %al,%eax
80102d43:	50                   	push   %eax
80102d44:	6a 70                	push   $0x70
80102d46:	e8 4a fd ff ff       	call   80102a95 <outb>
80102d4b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d4e:	68 c8 00 00 00       	push   $0xc8
80102d53:	e8 ec fe ff ff       	call   80102c44 <microdelay>
80102d58:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102d5b:	6a 71                	push   $0x71
80102d5d:	e8 16 fd ff ff       	call   80102a78 <inb>
80102d62:	83 c4 04             	add    $0x4,%esp
80102d65:	0f b6 c0             	movzbl %al,%eax
}
80102d68:	c9                   	leave  
80102d69:	c3                   	ret    

80102d6a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102d6a:	f3 0f 1e fb          	endbr32 
80102d6e:	55                   	push   %ebp
80102d6f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102d71:	6a 00                	push   $0x0
80102d73:	e8 be ff ff ff       	call   80102d36 <cmos_read>
80102d78:	83 c4 04             	add    $0x4,%esp
80102d7b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d7e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102d80:	6a 02                	push   $0x2
80102d82:	e8 af ff ff ff       	call   80102d36 <cmos_read>
80102d87:	83 c4 04             	add    $0x4,%esp
80102d8a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102d90:	6a 04                	push   $0x4
80102d92:	e8 9f ff ff ff       	call   80102d36 <cmos_read>
80102d97:	83 c4 04             	add    $0x4,%esp
80102d9a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102da0:	6a 07                	push   $0x7
80102da2:	e8 8f ff ff ff       	call   80102d36 <cmos_read>
80102da7:	83 c4 04             	add    $0x4,%esp
80102daa:	8b 55 08             	mov    0x8(%ebp),%edx
80102dad:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102db0:	6a 08                	push   $0x8
80102db2:	e8 7f ff ff ff       	call   80102d36 <cmos_read>
80102db7:	83 c4 04             	add    $0x4,%esp
80102dba:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbd:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102dc0:	6a 09                	push   $0x9
80102dc2:	e8 6f ff ff ff       	call   80102d36 <cmos_read>
80102dc7:	83 c4 04             	add    $0x4,%esp
80102dca:	8b 55 08             	mov    0x8(%ebp),%edx
80102dcd:	89 42 14             	mov    %eax,0x14(%edx)
}
80102dd0:	90                   	nop
80102dd1:	c9                   	leave  
80102dd2:	c3                   	ret    

80102dd3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102dd3:	f3 0f 1e fb          	endbr32 
80102dd7:	55                   	push   %ebp
80102dd8:	89 e5                	mov    %esp,%ebp
80102dda:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102ddd:	6a 0b                	push   $0xb
80102ddf:	e8 52 ff ff ff       	call   80102d36 <cmos_read>
80102de4:	83 c4 04             	add    $0x4,%esp
80102de7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ded:	83 e0 04             	and    $0x4,%eax
80102df0:	85 c0                	test   %eax,%eax
80102df2:	0f 94 c0             	sete   %al
80102df5:	0f b6 c0             	movzbl %al,%eax
80102df8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102dfb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102dfe:	50                   	push   %eax
80102dff:	e8 66 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e04:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e07:	6a 0a                	push   $0xa
80102e09:	e8 28 ff ff ff       	call   80102d36 <cmos_read>
80102e0e:	83 c4 04             	add    $0x4,%esp
80102e11:	25 80 00 00 00       	and    $0x80,%eax
80102e16:	85 c0                	test   %eax,%eax
80102e18:	75 27                	jne    80102e41 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e1a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e1d:	50                   	push   %eax
80102e1e:	e8 47 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e23:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e26:	83 ec 04             	sub    $0x4,%esp
80102e29:	6a 18                	push   $0x18
80102e2b:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e2e:	50                   	push   %eax
80102e2f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e32:	50                   	push   %eax
80102e33:	e8 87 1d 00 00       	call   80104bbf <memcmp>
80102e38:	83 c4 10             	add    $0x10,%esp
80102e3b:	85 c0                	test   %eax,%eax
80102e3d:	74 05                	je     80102e44 <cmostime+0x71>
80102e3f:	eb ba                	jmp    80102dfb <cmostime+0x28>
        continue;
80102e41:	90                   	nop
    fill_rtcdate(&t1);
80102e42:	eb b7                	jmp    80102dfb <cmostime+0x28>
      break;
80102e44:	90                   	nop
  }

  // convert
  if(bcd) {
80102e45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102e49:	0f 84 b4 00 00 00    	je     80102f03 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102e4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e52:	c1 e8 04             	shr    $0x4,%eax
80102e55:	89 c2                	mov    %eax,%edx
80102e57:	89 d0                	mov    %edx,%eax
80102e59:	c1 e0 02             	shl    $0x2,%eax
80102e5c:	01 d0                	add    %edx,%eax
80102e5e:	01 c0                	add    %eax,%eax
80102e60:	89 c2                	mov    %eax,%edx
80102e62:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e65:	83 e0 0f             	and    $0xf,%eax
80102e68:	01 d0                	add    %edx,%eax
80102e6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102e6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e70:	c1 e8 04             	shr    $0x4,%eax
80102e73:	89 c2                	mov    %eax,%edx
80102e75:	89 d0                	mov    %edx,%eax
80102e77:	c1 e0 02             	shl    $0x2,%eax
80102e7a:	01 d0                	add    %edx,%eax
80102e7c:	01 c0                	add    %eax,%eax
80102e7e:	89 c2                	mov    %eax,%edx
80102e80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e83:	83 e0 0f             	and    $0xf,%eax
80102e86:	01 d0                	add    %edx,%eax
80102e88:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102e8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102e8e:	c1 e8 04             	shr    $0x4,%eax
80102e91:	89 c2                	mov    %eax,%edx
80102e93:	89 d0                	mov    %edx,%eax
80102e95:	c1 e0 02             	shl    $0x2,%eax
80102e98:	01 d0                	add    %edx,%eax
80102e9a:	01 c0                	add    %eax,%eax
80102e9c:	89 c2                	mov    %eax,%edx
80102e9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ea1:	83 e0 0f             	and    $0xf,%eax
80102ea4:	01 d0                	add    %edx,%eax
80102ea6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102eac:	c1 e8 04             	shr    $0x4,%eax
80102eaf:	89 c2                	mov    %eax,%edx
80102eb1:	89 d0                	mov    %edx,%eax
80102eb3:	c1 e0 02             	shl    $0x2,%eax
80102eb6:	01 d0                	add    %edx,%eax
80102eb8:	01 c0                	add    %eax,%eax
80102eba:	89 c2                	mov    %eax,%edx
80102ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ebf:	83 e0 0f             	and    $0xf,%eax
80102ec2:	01 d0                	add    %edx,%eax
80102ec4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102eca:	c1 e8 04             	shr    $0x4,%eax
80102ecd:	89 c2                	mov    %eax,%edx
80102ecf:	89 d0                	mov    %edx,%eax
80102ed1:	c1 e0 02             	shl    $0x2,%eax
80102ed4:	01 d0                	add    %edx,%eax
80102ed6:	01 c0                	add    %eax,%eax
80102ed8:	89 c2                	mov    %eax,%edx
80102eda:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102edd:	83 e0 0f             	and    $0xf,%eax
80102ee0:	01 d0                	add    %edx,%eax
80102ee2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ee8:	c1 e8 04             	shr    $0x4,%eax
80102eeb:	89 c2                	mov    %eax,%edx
80102eed:	89 d0                	mov    %edx,%eax
80102eef:	c1 e0 02             	shl    $0x2,%eax
80102ef2:	01 d0                	add    %edx,%eax
80102ef4:	01 c0                	add    %eax,%eax
80102ef6:	89 c2                	mov    %eax,%edx
80102ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102efb:	83 e0 0f             	and    $0xf,%eax
80102efe:	01 d0                	add    %edx,%eax
80102f00:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f03:	8b 45 08             	mov    0x8(%ebp),%eax
80102f06:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f09:	89 10                	mov    %edx,(%eax)
80102f0b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f0e:	89 50 04             	mov    %edx,0x4(%eax)
80102f11:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f14:	89 50 08             	mov    %edx,0x8(%eax)
80102f17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f1a:	89 50 0c             	mov    %edx,0xc(%eax)
80102f1d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f20:	89 50 10             	mov    %edx,0x10(%eax)
80102f23:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f26:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f29:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2c:	8b 40 14             	mov    0x14(%eax),%eax
80102f2f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f35:	8b 45 08             	mov    0x8(%ebp),%eax
80102f38:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f3b:	90                   	nop
80102f3c:	c9                   	leave  
80102f3d:	c3                   	ret    

80102f3e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f3e:	f3 0f 1e fb          	endbr32 
80102f42:	55                   	push   %ebp
80102f43:	89 e5                	mov    %esp,%ebp
80102f45:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102f48:	83 ec 08             	sub    $0x8,%esp
80102f4b:	68 51 a5 10 80       	push   $0x8010a551
80102f50:	68 20 54 19 80       	push   $0x80195420
80102f55:	e8 45 19 00 00       	call   8010489f <initlock>
80102f5a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102f5d:	83 ec 08             	sub    $0x8,%esp
80102f60:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102f63:	50                   	push   %eax
80102f64:	ff 75 08             	pushl  0x8(%ebp)
80102f67:	e8 c0 e4 ff ff       	call   8010142c <readsb>
80102f6c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f72:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102f77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f7a:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f82:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102f87:	e8 bf 01 00 00       	call   8010314b <recover_from_log>
}
80102f8c:	90                   	nop
80102f8d:	c9                   	leave  
80102f8e:	c3                   	ret    

80102f8f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102f8f:	f3 0f 1e fb          	endbr32 
80102f93:	55                   	push   %ebp
80102f94:	89 e5                	mov    %esp,%ebp
80102f96:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102f99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fa0:	e9 95 00 00 00       	jmp    8010303a <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102fa5:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80102fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fae:	01 d0                	add    %edx,%eax
80102fb0:	83 c0 01             	add    $0x1,%eax
80102fb3:	89 c2                	mov    %eax,%edx
80102fb5:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fba:	83 ec 08             	sub    $0x8,%esp
80102fbd:	52                   	push   %edx
80102fbe:	50                   	push   %eax
80102fbf:	e8 45 d2 ff ff       	call   80100209 <bread>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fcd:	83 c0 10             	add    $0x10,%eax
80102fd0:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80102fd7:	89 c2                	mov    %eax,%edx
80102fd9:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fde:	83 ec 08             	sub    $0x8,%esp
80102fe1:	52                   	push   %edx
80102fe2:	50                   	push   %eax
80102fe3:	e8 21 d2 ff ff       	call   80100209 <bread>
80102fe8:	83 c4 10             	add    $0x10,%esp
80102feb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ff1:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ff7:	83 c0 5c             	add    $0x5c,%eax
80102ffa:	83 ec 04             	sub    $0x4,%esp
80102ffd:	68 00 02 00 00       	push   $0x200
80103002:	52                   	push   %edx
80103003:	50                   	push   %eax
80103004:	e8 12 1c 00 00       	call   80104c1b <memmove>
80103009:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010300c:	83 ec 0c             	sub    $0xc,%esp
8010300f:	ff 75 ec             	pushl  -0x14(%ebp)
80103012:	e8 2f d2 ff ff       	call   80100246 <bwrite>
80103017:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010301a:	83 ec 0c             	sub    $0xc,%esp
8010301d:	ff 75 f0             	pushl  -0x10(%ebp)
80103020:	e8 6e d2 ff ff       	call   80100293 <brelse>
80103025:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103028:	83 ec 0c             	sub    $0xc,%esp
8010302b:	ff 75 ec             	pushl  -0x14(%ebp)
8010302e:	e8 60 d2 ff ff       	call   80100293 <brelse>
80103033:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103036:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010303a:	a1 68 54 19 80       	mov    0x80195468,%eax
8010303f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103042:	0f 8c 5d ff ff ff    	jl     80102fa5 <install_trans+0x16>
  }
}
80103048:	90                   	nop
80103049:	90                   	nop
8010304a:	c9                   	leave  
8010304b:	c3                   	ret    

8010304c <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010304c:	f3 0f 1e fb          	endbr32 
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103056:	a1 54 54 19 80       	mov    0x80195454,%eax
8010305b:	89 c2                	mov    %eax,%edx
8010305d:	a1 64 54 19 80       	mov    0x80195464,%eax
80103062:	83 ec 08             	sub    $0x8,%esp
80103065:	52                   	push   %edx
80103066:	50                   	push   %eax
80103067:	e8 9d d1 ff ff       	call   80100209 <bread>
8010306c:	83 c4 10             	add    $0x10,%esp
8010306f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103075:	83 c0 5c             	add    $0x5c,%eax
80103078:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010307b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010307e:	8b 00                	mov    (%eax),%eax
80103080:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
80103085:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010308c:	eb 1b                	jmp    801030a9 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010308e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103094:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010309b:	83 c2 10             	add    $0x10,%edx
8010309e:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030a9:	a1 68 54 19 80       	mov    0x80195468,%eax
801030ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030b1:	7c db                	jl     8010308e <read_head+0x42>
  }
  brelse(buf);
801030b3:	83 ec 0c             	sub    $0xc,%esp
801030b6:	ff 75 f0             	pushl  -0x10(%ebp)
801030b9:	e8 d5 d1 ff ff       	call   80100293 <brelse>
801030be:	83 c4 10             	add    $0x10,%esp
}
801030c1:	90                   	nop
801030c2:	c9                   	leave  
801030c3:	c3                   	ret    

801030c4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801030c4:	f3 0f 1e fb          	endbr32 
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030ce:	a1 54 54 19 80       	mov    0x80195454,%eax
801030d3:	89 c2                	mov    %eax,%edx
801030d5:	a1 64 54 19 80       	mov    0x80195464,%eax
801030da:	83 ec 08             	sub    $0x8,%esp
801030dd:	52                   	push   %edx
801030de:	50                   	push   %eax
801030df:	e8 25 d1 ff ff       	call   80100209 <bread>
801030e4:	83 c4 10             	add    $0x10,%esp
801030e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801030ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030ed:	83 c0 5c             	add    $0x5c,%eax
801030f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801030f3:	8b 15 68 54 19 80    	mov    0x80195468,%edx
801030f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030fc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801030fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103105:	eb 1b                	jmp    80103122 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310a:	83 c0 10             	add    $0x10,%eax
8010310d:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103114:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010311a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010311e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103122:	a1 68 54 19 80       	mov    0x80195468,%eax
80103127:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010312a:	7c db                	jl     80103107 <write_head+0x43>
  }
  bwrite(buf);
8010312c:	83 ec 0c             	sub    $0xc,%esp
8010312f:	ff 75 f0             	pushl  -0x10(%ebp)
80103132:	e8 0f d1 ff ff       	call   80100246 <bwrite>
80103137:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010313a:	83 ec 0c             	sub    $0xc,%esp
8010313d:	ff 75 f0             	pushl  -0x10(%ebp)
80103140:	e8 4e d1 ff ff       	call   80100293 <brelse>
80103145:	83 c4 10             	add    $0x10,%esp
}
80103148:	90                   	nop
80103149:	c9                   	leave  
8010314a:	c3                   	ret    

8010314b <recover_from_log>:

static void
recover_from_log(void)
{
8010314b:	f3 0f 1e fb          	endbr32 
8010314f:	55                   	push   %ebp
80103150:	89 e5                	mov    %esp,%ebp
80103152:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103155:	e8 f2 fe ff ff       	call   8010304c <read_head>
  install_trans(); // if committed, copy from log to disk
8010315a:	e8 30 fe ff ff       	call   80102f8f <install_trans>
  log.lh.n = 0;
8010315f:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
80103166:	00 00 00 
  write_head(); // clear the log
80103169:	e8 56 ff ff ff       	call   801030c4 <write_head>
}
8010316e:	90                   	nop
8010316f:	c9                   	leave  
80103170:	c3                   	ret    

80103171 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103171:	f3 0f 1e fb          	endbr32 
80103175:	55                   	push   %ebp
80103176:	89 e5                	mov    %esp,%ebp
80103178:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 54 19 80       	push   $0x80195420
80103183:	e8 3d 17 00 00       	call   801048c5 <acquire>
80103188:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010318b:	a1 60 54 19 80       	mov    0x80195460,%eax
80103190:	85 c0                	test   %eax,%eax
80103192:	74 17                	je     801031ab <begin_op+0x3a>
      sleep(&log, &log.lock);
80103194:	83 ec 08             	sub    $0x8,%esp
80103197:	68 20 54 19 80       	push   $0x80195420
8010319c:	68 20 54 19 80       	push   $0x80195420
801031a1:	e8 dc 12 00 00       	call   80104482 <sleep>
801031a6:	83 c4 10             	add    $0x10,%esp
801031a9:	eb e0                	jmp    8010318b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801031ab:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
801031b1:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031b6:	8d 50 01             	lea    0x1(%eax),%edx
801031b9:	89 d0                	mov    %edx,%eax
801031bb:	c1 e0 02             	shl    $0x2,%eax
801031be:	01 d0                	add    %edx,%eax
801031c0:	01 c0                	add    %eax,%eax
801031c2:	01 c8                	add    %ecx,%eax
801031c4:	83 f8 1e             	cmp    $0x1e,%eax
801031c7:	7e 17                	jle    801031e0 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801031c9:	83 ec 08             	sub    $0x8,%esp
801031cc:	68 20 54 19 80       	push   $0x80195420
801031d1:	68 20 54 19 80       	push   $0x80195420
801031d6:	e8 a7 12 00 00       	call   80104482 <sleep>
801031db:	83 c4 10             	add    $0x10,%esp
801031de:	eb ab                	jmp    8010318b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801031e0:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031e5:	83 c0 01             	add    $0x1,%eax
801031e8:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
801031ed:	83 ec 0c             	sub    $0xc,%esp
801031f0:	68 20 54 19 80       	push   $0x80195420
801031f5:	e8 3d 17 00 00       	call   80104937 <release>
801031fa:	83 c4 10             	add    $0x10,%esp
      break;
801031fd:	90                   	nop
    }
  }
}
801031fe:	90                   	nop
801031ff:	c9                   	leave  
80103200:	c3                   	ret    

80103201 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103201:	f3 0f 1e fb          	endbr32 
80103205:	55                   	push   %ebp
80103206:	89 e5                	mov    %esp,%ebp
80103208:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010320b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103212:	83 ec 0c             	sub    $0xc,%esp
80103215:	68 20 54 19 80       	push   $0x80195420
8010321a:	e8 a6 16 00 00       	call   801048c5 <acquire>
8010321f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103222:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103227:	83 e8 01             	sub    $0x1,%eax
8010322a:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010322f:	a1 60 54 19 80       	mov    0x80195460,%eax
80103234:	85 c0                	test   %eax,%eax
80103236:	74 0d                	je     80103245 <end_op+0x44>
    panic("log.committing");
80103238:	83 ec 0c             	sub    $0xc,%esp
8010323b:	68 55 a5 10 80       	push   $0x8010a555
80103240:	e8 80 d3 ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
80103245:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010324a:	85 c0                	test   %eax,%eax
8010324c:	75 13                	jne    80103261 <end_op+0x60>
    do_commit = 1;
8010324e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103255:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
8010325c:	00 00 00 
8010325f:	eb 10                	jmp    80103271 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103261:	83 ec 0c             	sub    $0xc,%esp
80103264:	68 20 54 19 80       	push   $0x80195420
80103269:	e8 03 13 00 00       	call   80104571 <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 20 54 19 80       	push   $0x80195420
80103279:	e8 b9 16 00 00       	call   80104937 <release>
8010327e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103281:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103285:	74 3f                	je     801032c6 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103287:	e8 fa 00 00 00       	call   80103386 <commit>
    acquire(&log.lock);
8010328c:	83 ec 0c             	sub    $0xc,%esp
8010328f:	68 20 54 19 80       	push   $0x80195420
80103294:	e8 2c 16 00 00       	call   801048c5 <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 20 54 19 80       	push   $0x80195420
801032ae:	e8 be 12 00 00       	call   80104571 <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 20 54 19 80       	push   $0x80195420
801032be:	e8 74 16 00 00       	call   80104937 <release>
801032c3:	83 c4 10             	add    $0x10,%esp
  }
}
801032c6:	90                   	nop
801032c7:	c9                   	leave  
801032c8:	c3                   	ret    

801032c9 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801032c9:	f3 0f 1e fb          	endbr32 
801032cd:	55                   	push   %ebp
801032ce:	89 e5                	mov    %esp,%ebp
801032d0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032da:	e9 95 00 00 00       	jmp    80103374 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801032df:	8b 15 54 54 19 80    	mov    0x80195454,%edx
801032e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e8:	01 d0                	add    %edx,%eax
801032ea:	83 c0 01             	add    $0x1,%eax
801032ed:	89 c2                	mov    %eax,%edx
801032ef:	a1 64 54 19 80       	mov    0x80195464,%eax
801032f4:	83 ec 08             	sub    $0x8,%esp
801032f7:	52                   	push   %edx
801032f8:	50                   	push   %eax
801032f9:	e8 0b cf ff ff       	call   80100209 <bread>
801032fe:	83 c4 10             	add    $0x10,%esp
80103301:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103307:	83 c0 10             	add    $0x10,%eax
8010330a:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	a1 64 54 19 80       	mov    0x80195464,%eax
80103318:	83 ec 08             	sub    $0x8,%esp
8010331b:	52                   	push   %edx
8010331c:	50                   	push   %eax
8010331d:	e8 e7 ce ff ff       	call   80100209 <bread>
80103322:	83 c4 10             	add    $0x10,%esp
80103325:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103328:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010332b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010332e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103331:	83 c0 5c             	add    $0x5c,%eax
80103334:	83 ec 04             	sub    $0x4,%esp
80103337:	68 00 02 00 00       	push   $0x200
8010333c:	52                   	push   %edx
8010333d:	50                   	push   %eax
8010333e:	e8 d8 18 00 00       	call   80104c1b <memmove>
80103343:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103346:	83 ec 0c             	sub    $0xc,%esp
80103349:	ff 75 f0             	pushl  -0x10(%ebp)
8010334c:	e8 f5 ce ff ff       	call   80100246 <bwrite>
80103351:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103354:	83 ec 0c             	sub    $0xc,%esp
80103357:	ff 75 ec             	pushl  -0x14(%ebp)
8010335a:	e8 34 cf ff ff       	call   80100293 <brelse>
8010335f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103362:	83 ec 0c             	sub    $0xc,%esp
80103365:	ff 75 f0             	pushl  -0x10(%ebp)
80103368:	e8 26 cf ff ff       	call   80100293 <brelse>
8010336d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103370:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103374:	a1 68 54 19 80       	mov    0x80195468,%eax
80103379:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010337c:	0f 8c 5d ff ff ff    	jl     801032df <write_log+0x16>
  }
}
80103382:	90                   	nop
80103383:	90                   	nop
80103384:	c9                   	leave  
80103385:	c3                   	ret    

80103386 <commit>:

static void
commit()
{
80103386:	f3 0f 1e fb          	endbr32 
8010338a:	55                   	push   %ebp
8010338b:	89 e5                	mov    %esp,%ebp
8010338d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103390:	a1 68 54 19 80       	mov    0x80195468,%eax
80103395:	85 c0                	test   %eax,%eax
80103397:	7e 1e                	jle    801033b7 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103399:	e8 2b ff ff ff       	call   801032c9 <write_log>
    write_head();    // Write header to disk -- the real commit
8010339e:	e8 21 fd ff ff       	call   801030c4 <write_head>
    install_trans(); // Now install writes to home locations
801033a3:	e8 e7 fb ff ff       	call   80102f8f <install_trans>
    log.lh.n = 0;
801033a8:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801033af:	00 00 00 
    write_head();    // Erase the transaction from the log
801033b2:	e8 0d fd ff ff       	call   801030c4 <write_head>
  }
}
801033b7:	90                   	nop
801033b8:	c9                   	leave  
801033b9:	c3                   	ret    

801033ba <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801033ba:	f3 0f 1e fb          	endbr32 
801033be:	55                   	push   %ebp
801033bf:	89 e5                	mov    %esp,%ebp
801033c1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801033c4:	a1 68 54 19 80       	mov    0x80195468,%eax
801033c9:	83 f8 1d             	cmp    $0x1d,%eax
801033cc:	7f 12                	jg     801033e0 <log_write+0x26>
801033ce:	a1 68 54 19 80       	mov    0x80195468,%eax
801033d3:	8b 15 58 54 19 80    	mov    0x80195458,%edx
801033d9:	83 ea 01             	sub    $0x1,%edx
801033dc:	39 d0                	cmp    %edx,%eax
801033de:	7c 0d                	jl     801033ed <log_write+0x33>
    panic("too big a transaction");
801033e0:	83 ec 0c             	sub    $0xc,%esp
801033e3:	68 64 a5 10 80       	push   $0x8010a564
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 7a a5 10 80       	push   $0x8010a57a
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 20 54 19 80       	push   $0x80195420
8010340b:	e8 b5 14 00 00       	call   801048c5 <acquire>
80103410:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103413:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010341a:	eb 1d                	jmp    80103439 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010341c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341f:	83 c0 10             	add    $0x10,%eax
80103422:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103429:	89 c2                	mov    %eax,%edx
8010342b:	8b 45 08             	mov    0x8(%ebp),%eax
8010342e:	8b 40 08             	mov    0x8(%eax),%eax
80103431:	39 c2                	cmp    %eax,%edx
80103433:	74 10                	je     80103445 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103435:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103439:	a1 68 54 19 80       	mov    0x80195468,%eax
8010343e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103441:	7c d9                	jl     8010341c <log_write+0x62>
80103443:	eb 01                	jmp    80103446 <log_write+0x8c>
      break;
80103445:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103446:	8b 45 08             	mov    0x8(%ebp),%eax
80103449:	8b 40 08             	mov    0x8(%eax),%eax
8010344c:	89 c2                	mov    %eax,%edx
8010344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103451:	83 c0 10             	add    $0x10,%eax
80103454:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
8010345b:	a1 68 54 19 80       	mov    0x80195468,%eax
80103460:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103463:	75 0d                	jne    80103472 <log_write+0xb8>
    log.lh.n++;
80103465:	a1 68 54 19 80       	mov    0x80195468,%eax
8010346a:	83 c0 01             	add    $0x1,%eax
8010346d:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
80103472:	8b 45 08             	mov    0x8(%ebp),%eax
80103475:	8b 00                	mov    (%eax),%eax
80103477:	83 c8 04             	or     $0x4,%eax
8010347a:	89 c2                	mov    %eax,%edx
8010347c:	8b 45 08             	mov    0x8(%ebp),%eax
8010347f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	68 20 54 19 80       	push   $0x80195420
80103489:	e8 a9 14 00 00       	call   80104937 <release>
8010348e:	83 c4 10             	add    $0x10,%esp
}
80103491:	90                   	nop
80103492:	c9                   	leave  
80103493:	c3                   	ret    

80103494 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103494:	55                   	push   %ebp
80103495:	89 e5                	mov    %esp,%ebp
80103497:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010349a:	8b 55 08             	mov    0x8(%ebp),%edx
8010349d:	8b 45 0c             	mov    0xc(%ebp),%eax
801034a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801034a3:	f0 87 02             	lock xchg %eax,(%edx)
801034a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801034a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801034ac:	c9                   	leave  
801034ad:	c3                   	ret    

801034ae <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801034ae:	f3 0f 1e fb          	endbr32 
801034b2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801034b6:	83 e4 f0             	and    $0xfffffff0,%esp
801034b9:	ff 71 fc             	pushl  -0x4(%ecx)
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	51                   	push   %ecx
801034c0:	83 ec 04             	sub    $0x4,%esp
  graphic_init(); // 화면 출력을 위한 그래픽 시스템
801034c3:	e8 47 4b 00 00       	call   8010800f <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator 커널이 사용할 수 있는 물리 메모리의 첫 4MB를 할당할 준비를 합니다.
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 80 19 80       	push   $0x80198000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table // 가상 메모리 주소를 물리 메모리 주소로 변환할 **커널 페이지 테이블(지도)**을 만듭니다.
801034dd:	e8 0a 41 00 00       	call   801075ec <kvmalloc>
  mpinit_uefi(); // 다중 코어(멀티프로세서) 환경을 UEFI 방식에 맞게 파악합니다. CPU가 몇 개인지 확인하는 작업이죠.
801034e2:	e8 e1 48 00 00       	call   80107dc8 <mpinit_uefi>
  lapicinit();     // interrupt controller 키보드나 마우스 등 외부에서 들어오는 신호(인터럽트)를 CPU가 받을 수 있도록 컨트롤러를 켭니다.
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors 메모리 보호 구역(세그먼트)을 설정하고, 오류나 시스템 콜이 발생했을 때 어디로 가야 할지(트랩 벡터)를 설정합니다.
801034ec:	e8 82 3b 00 00       	call   80107073 <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller 키보드나 마우스 등 외부에서 들어오는 신호(인터럽트)를 CPU가 받을 수 있도록 컨트롤러를 켭니다.
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware 화면에 글자를 찍고(콘솔), 시리얼 통신을 할 준비를 합니다.
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port 화면에 글자를 찍고(콘솔), 시리얼 통신을 할 준비를 합니다.
80103500:	e8 f7 2e 00 00       	call   801063fc <uartinit>
  pinit();         // process table 프로세스 장부(프로세스 테이블)를 초기화합니다.
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors 메모리 보호 구역(세그먼트)을 설정하고, 오류나 시스템 콜이 발생했을 때 어디로 가야 할지(트랩 벡터)를 설정합니다.
8010350a:	e8 b1 2a 00 00       	call   80105fc0 <tvinit>
  binit();         // buffer cache 하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table 하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk  하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
80103519:	e8 f6 6c 00 00       	call   8010a214 <ideinit>
  startothers();   // start other processors 잠들어 있는 나머지 CPU들을 깨웁니다. (자세한 건 아래 2번에서 설명할게요)
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers() 처음 4MB 이후의 나머지 모든 물리 메모리를 운영체제가 사용할 수 있도록 마저 할당합니다.
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init(); // 추가된 네트워크 및 하드웨어 장치를 스캔합니다 
80103538:	e8 45 4d 00 00       	call   80108282 <pci_init>
  arp_scan(); // 추가된 네트워크 및 하드웨어 장치를 스캔합니다.
8010353d:	e8 be 5a 00 00       	call   80109000 <arp_scan>
  //i8254_recv();
  userinit();      // first user process 드디어 대망의 첫 번째 유저 프로그램(보통 init 프로세스)을 메모리에 만듭니다.
80103542:	e8 9b 07 00 00       	call   80103ce2 <userinit>

  mpmain();        // finish this processor's setup 준비를 마치고 스케줄러를 가동하여 프로세스들을 실행하기 시작합니다.
80103547:	e8 1e 00 00 00       	call   8010356a <mpmain>

8010354c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void) // 서브 CPU들의 출근 완료 보고
{
8010354c:	f3 0f 1e fb          	endbr32 
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103556:	e8 ad 40 00 00       	call   80107608 <switchkvm>
  seginit();
8010355b:	e8 13 3b 00 00       	call   80107073 <seginit>
  lapicinit();
80103560:	e8 77 f5 ff ff       	call   80102adc <lapicinit>
  mpmain();
80103565:	e8 00 00 00 00       	call   8010356a <mpmain>

8010356a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void) //서브 CPU들의 출근 완료 보고
{
8010356a:	f3 0f 1e fb          	endbr32 
8010356e:	55                   	push   %ebp
8010356f:	89 e5                	mov    %esp,%ebp
80103571:	53                   	push   %ebx
80103572:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103575:	e8 94 05 00 00       	call   80103b0e <cpuid>
8010357a:	89 c3                	mov    %eax,%ebx
8010357c:	e8 8d 05 00 00       	call   80103b0e <cpuid>
80103581:	83 ec 04             	sub    $0x4,%esp
80103584:	53                   	push   %ebx
80103585:	50                   	push   %eax
80103586:	68 95 a5 10 80       	push   $0x8010a595
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 a2 2b 00 00       	call   8010613a <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 cc 0c 00 00       	call   80104281 <scheduler>

801035b5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801035b5:	f3 0f 1e fb          	endbr32 
801035b9:	55                   	push   %ebp
801035ba:	89 e5                	mov    %esp,%ebp
801035bc:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801035bf:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801035c6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801035cb:	83 ec 04             	sub    $0x4,%esp
801035ce:	50                   	push   %eax
801035cf:	68 18 f5 10 80       	push   $0x8010f518
801035d4:	ff 75 f0             	pushl  -0x10(%ebp)
801035d7:	e8 3f 16 00 00       	call   80104c1b <memmove>
801035dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035df:	c7 45 f4 c0 7c 19 80 	movl   $0x80197cc0,-0xc(%ebp)
801035e6:	eb 79                	jmp    80103661 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
801035e8:	e8 40 05 00 00       	call   80103b2d <mycpu>
801035ed:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035f0:	74 67                	je     80103659 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801035f2:	e8 9b f2 ff ff       	call   80102892 <kalloc>
801035f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035fd:	83 e8 04             	sub    $0x4,%eax
80103600:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103603:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103609:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010360b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010360e:	83 e8 08             	sub    $0x8,%eax
80103611:	c7 00 4c 35 10 80    	movl   $0x8010354c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103617:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010361c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103625:	83 e8 0c             	sub    $0xc,%eax
80103628:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
8010362a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010362d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103636:	0f b6 00             	movzbl (%eax),%eax
80103639:	0f b6 c0             	movzbl %al,%eax
8010363c:	83 ec 08             	sub    $0x8,%esp
8010363f:	52                   	push   %edx
80103640:	50                   	push   %eax
80103641:	e8 08 f6 ff ff       	call   80102c4e <lapicstartap>
80103646:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103649:	90                   	nop
8010364a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010364d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103653:	85 c0                	test   %eax,%eax
80103655:	74 f3                	je     8010364a <startothers+0x95>
80103657:	eb 01                	jmp    8010365a <startothers+0xa5>
      continue;
80103659:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
8010365a:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103661:	a1 80 7f 19 80       	mov    0x80197f80,%eax
80103666:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010366c:	05 c0 7c 19 80       	add    $0x80197cc0,%eax
80103671:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103674:	0f 82 6e ff ff ff    	jb     801035e8 <startothers+0x33>
      ;
  }
}
8010367a:	90                   	nop
8010367b:	90                   	nop
8010367c:	c9                   	leave  
8010367d:	c3                   	ret    

8010367e <outb>:
{
8010367e:	55                   	push   %ebp
8010367f:	89 e5                	mov    %esp,%ebp
80103681:	83 ec 08             	sub    $0x8,%esp
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 55 0c             	mov    0xc(%ebp),%edx
8010368a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010368e:	89 d0                	mov    %edx,%eax
80103690:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103693:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103697:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010369b:	ee                   	out    %al,(%dx)
}
8010369c:	90                   	nop
8010369d:	c9                   	leave  
8010369e:	c3                   	ret    

8010369f <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010369f:	f3 0f 1e fb          	endbr32 
801036a3:	55                   	push   %ebp
801036a4:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801036a6:	68 ff 00 00 00       	push   $0xff
801036ab:	6a 21                	push   $0x21
801036ad:	e8 cc ff ff ff       	call   8010367e <outb>
801036b2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801036b5:	68 ff 00 00 00       	push   $0xff
801036ba:	68 a1 00 00 00       	push   $0xa1
801036bf:	e8 ba ff ff ff       	call   8010367e <outb>
801036c4:	83 c4 08             	add    $0x8,%esp
}
801036c7:	90                   	nop
801036c8:	c9                   	leave  
801036c9:	c3                   	ret    

801036ca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801036ca:	f3 0f 1e fb          	endbr32 
801036ce:	55                   	push   %ebp
801036cf:	89 e5                	mov    %esp,%ebp
801036d1:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801036d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801036db:	8b 45 0c             	mov    0xc(%ebp),%eax
801036de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801036e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801036e7:	8b 10                	mov    (%eax),%edx
801036e9:	8b 45 08             	mov    0x8(%ebp),%eax
801036ec:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801036ee:	e8 30 d9 ff ff       	call   80101023 <filealloc>
801036f3:	8b 55 08             	mov    0x8(%ebp),%edx
801036f6:	89 02                	mov    %eax,(%edx)
801036f8:	8b 45 08             	mov    0x8(%ebp),%eax
801036fb:	8b 00                	mov    (%eax),%eax
801036fd:	85 c0                	test   %eax,%eax
801036ff:	0f 84 c8 00 00 00    	je     801037cd <pipealloc+0x103>
80103705:	e8 19 d9 ff ff       	call   80101023 <filealloc>
8010370a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010370d:	89 02                	mov    %eax,(%edx)
8010370f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103712:	8b 00                	mov    (%eax),%eax
80103714:	85 c0                	test   %eax,%eax
80103716:	0f 84 b1 00 00 00    	je     801037cd <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010371c:	e8 71 f1 ff ff       	call   80102892 <kalloc>
80103721:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103724:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103728:	0f 84 a2 00 00 00    	je     801037d0 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010372e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103731:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103738:	00 00 00 
  p->writeopen = 1;
8010373b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010373e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103745:	00 00 00 
  p->nwrite = 0;
80103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103752:	00 00 00 
  p->nread = 0;
80103755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103758:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010375f:	00 00 00 
  initlock(&p->lock, "pipe");
80103762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103765:	83 ec 08             	sub    $0x8,%esp
80103768:	68 a9 a5 10 80       	push   $0x8010a5a9
8010376d:	50                   	push   %eax
8010376e:	e8 2c 11 00 00       	call   8010489f <initlock>
80103773:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103776:	8b 45 08             	mov    0x8(%ebp),%eax
80103779:	8b 00                	mov    (%eax),%eax
8010377b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103781:	8b 45 08             	mov    0x8(%ebp),%eax
80103784:	8b 00                	mov    (%eax),%eax
80103786:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010378a:	8b 45 08             	mov    0x8(%ebp),%eax
8010378d:	8b 00                	mov    (%eax),%eax
8010378f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103793:	8b 45 08             	mov    0x8(%ebp),%eax
80103796:	8b 00                	mov    (%eax),%eax
80103798:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010379b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010379e:	8b 45 0c             	mov    0xc(%ebp),%eax
801037a1:	8b 00                	mov    (%eax),%eax
801037a3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801037a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801037ac:	8b 00                	mov    (%eax),%eax
801037ae:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801037b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b5:	8b 00                	mov    (%eax),%eax
801037b7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801037bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801037be:	8b 00                	mov    (%eax),%eax
801037c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037c3:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801037c6:	b8 00 00 00 00       	mov    $0x0,%eax
801037cb:	eb 51                	jmp    8010381e <pipealloc+0x154>
    goto bad;
801037cd:	90                   	nop
801037ce:	eb 01                	jmp    801037d1 <pipealloc+0x107>
    goto bad;
801037d0:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801037d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037d5:	74 0e                	je     801037e5 <pipealloc+0x11b>
    kfree((char*)p);
801037d7:	83 ec 0c             	sub    $0xc,%esp
801037da:	ff 75 f4             	pushl  -0xc(%ebp)
801037dd:	e8 12 f0 ff ff       	call   801027f4 <kfree>
801037e2:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801037e5:	8b 45 08             	mov    0x8(%ebp),%eax
801037e8:	8b 00                	mov    (%eax),%eax
801037ea:	85 c0                	test   %eax,%eax
801037ec:	74 11                	je     801037ff <pipealloc+0x135>
    fileclose(*f0);
801037ee:	8b 45 08             	mov    0x8(%ebp),%eax
801037f1:	8b 00                	mov    (%eax),%eax
801037f3:	83 ec 0c             	sub    $0xc,%esp
801037f6:	50                   	push   %eax
801037f7:	e8 ed d8 ff ff       	call   801010e9 <fileclose>
801037fc:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801037ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103802:	8b 00                	mov    (%eax),%eax
80103804:	85 c0                	test   %eax,%eax
80103806:	74 11                	je     80103819 <pipealloc+0x14f>
    fileclose(*f1);
80103808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380b:	8b 00                	mov    (%eax),%eax
8010380d:	83 ec 0c             	sub    $0xc,%esp
80103810:	50                   	push   %eax
80103811:	e8 d3 d8 ff ff       	call   801010e9 <fileclose>
80103816:	83 c4 10             	add    $0x10,%esp
  return -1;
80103819:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010381e:	c9                   	leave  
8010381f:	c3                   	ret    

80103820 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103820:	f3 0f 1e fb          	endbr32 
80103824:	55                   	push   %ebp
80103825:	89 e5                	mov    %esp,%ebp
80103827:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010382a:	8b 45 08             	mov    0x8(%ebp),%eax
8010382d:	83 ec 0c             	sub    $0xc,%esp
80103830:	50                   	push   %eax
80103831:	e8 8f 10 00 00       	call   801048c5 <acquire>
80103836:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103839:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010383d:	74 23                	je     80103862 <pipeclose+0x42>
    p->writeopen = 0;
8010383f:	8b 45 08             	mov    0x8(%ebp),%eax
80103842:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103849:	00 00 00 
    wakeup(&p->nread);
8010384c:	8b 45 08             	mov    0x8(%ebp),%eax
8010384f:	05 34 02 00 00       	add    $0x234,%eax
80103854:	83 ec 0c             	sub    $0xc,%esp
80103857:	50                   	push   %eax
80103858:	e8 14 0d 00 00       	call   80104571 <wakeup>
8010385d:	83 c4 10             	add    $0x10,%esp
80103860:	eb 21                	jmp    80103883 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103862:	8b 45 08             	mov    0x8(%ebp),%eax
80103865:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010386c:	00 00 00 
    wakeup(&p->nwrite);
8010386f:	8b 45 08             	mov    0x8(%ebp),%eax
80103872:	05 38 02 00 00       	add    $0x238,%eax
80103877:	83 ec 0c             	sub    $0xc,%esp
8010387a:	50                   	push   %eax
8010387b:	e8 f1 0c 00 00       	call   80104571 <wakeup>
80103880:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103883:	8b 45 08             	mov    0x8(%ebp),%eax
80103886:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010388c:	85 c0                	test   %eax,%eax
8010388e:	75 2c                	jne    801038bc <pipeclose+0x9c>
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103899:	85 c0                	test   %eax,%eax
8010389b:	75 1f                	jne    801038bc <pipeclose+0x9c>
    release(&p->lock);
8010389d:	8b 45 08             	mov    0x8(%ebp),%eax
801038a0:	83 ec 0c             	sub    $0xc,%esp
801038a3:	50                   	push   %eax
801038a4:	e8 8e 10 00 00       	call   80104937 <release>
801038a9:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801038ac:	83 ec 0c             	sub    $0xc,%esp
801038af:	ff 75 08             	pushl  0x8(%ebp)
801038b2:	e8 3d ef ff ff       	call   801027f4 <kfree>
801038b7:	83 c4 10             	add    $0x10,%esp
801038ba:	eb 10                	jmp    801038cc <pipeclose+0xac>
  } else
    release(&p->lock);
801038bc:	8b 45 08             	mov    0x8(%ebp),%eax
801038bf:	83 ec 0c             	sub    $0xc,%esp
801038c2:	50                   	push   %eax
801038c3:	e8 6f 10 00 00       	call   80104937 <release>
801038c8:	83 c4 10             	add    $0x10,%esp
}
801038cb:	90                   	nop
801038cc:	90                   	nop
801038cd:	c9                   	leave  
801038ce:	c3                   	ret    

801038cf <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801038cf:	f3 0f 1e fb          	endbr32 
801038d3:	55                   	push   %ebp
801038d4:	89 e5                	mov    %esp,%ebp
801038d6:	53                   	push   %ebx
801038d7:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801038da:	8b 45 08             	mov    0x8(%ebp),%eax
801038dd:	83 ec 0c             	sub    $0xc,%esp
801038e0:	50                   	push   %eax
801038e1:	e8 df 0f 00 00       	call   801048c5 <acquire>
801038e6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801038e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038f0:	e9 ad 00 00 00       	jmp    801039a2 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801038f5:	8b 45 08             	mov    0x8(%ebp),%eax
801038f8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038fe:	85 c0                	test   %eax,%eax
80103900:	74 0c                	je     8010390e <pipewrite+0x3f>
80103902:	e8 a2 02 00 00       	call   80103ba9 <myproc>
80103907:	8b 40 24             	mov    0x24(%eax),%eax
8010390a:	85 c0                	test   %eax,%eax
8010390c:	74 19                	je     80103927 <pipewrite+0x58>
        release(&p->lock);
8010390e:	8b 45 08             	mov    0x8(%ebp),%eax
80103911:	83 ec 0c             	sub    $0xc,%esp
80103914:	50                   	push   %eax
80103915:	e8 1d 10 00 00       	call   80104937 <release>
8010391a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010391d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103922:	e9 a9 00 00 00       	jmp    801039d0 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	05 34 02 00 00       	add    $0x234,%eax
8010392f:	83 ec 0c             	sub    $0xc,%esp
80103932:	50                   	push   %eax
80103933:	e8 39 0c 00 00       	call   80104571 <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 31 0b 00 00       	call   80104482 <sleep>
80103951:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010395d:	8b 45 08             	mov    0x8(%ebp),%eax
80103960:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103966:	05 00 02 00 00       	add    $0x200,%eax
8010396b:	39 c2                	cmp    %eax,%edx
8010396d:	74 86                	je     801038f5 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010396f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103972:	8b 45 0c             	mov    0xc(%ebp),%eax
80103975:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103978:	8b 45 08             	mov    0x8(%ebp),%eax
8010397b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103981:	8d 48 01             	lea    0x1(%eax),%ecx
80103984:	8b 55 08             	mov    0x8(%ebp),%edx
80103987:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010398d:	25 ff 01 00 00       	and    $0x1ff,%eax
80103992:	89 c1                	mov    %eax,%ecx
80103994:	0f b6 13             	movzbl (%ebx),%edx
80103997:	8b 45 08             	mov    0x8(%ebp),%eax
8010399a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010399e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801039a8:	7c aa                	jl     80103954 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801039aa:	8b 45 08             	mov    0x8(%ebp),%eax
801039ad:	05 34 02 00 00       	add    $0x234,%eax
801039b2:	83 ec 0c             	sub    $0xc,%esp
801039b5:	50                   	push   %eax
801039b6:	e8 b6 0b 00 00       	call   80104571 <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 6d 0f 00 00       	call   80104937 <release>
801039ca:	83 c4 10             	add    $0x10,%esp
  return n;
801039cd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801039d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039d3:	c9                   	leave  
801039d4:	c3                   	ret    

801039d5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801039d5:	f3 0f 1e fb          	endbr32 
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801039df:	8b 45 08             	mov    0x8(%ebp),%eax
801039e2:	83 ec 0c             	sub    $0xc,%esp
801039e5:	50                   	push   %eax
801039e6:	e8 da 0e 00 00       	call   801048c5 <acquire>
801039eb:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039ee:	eb 3e                	jmp    80103a2e <piperead+0x59>
    if(myproc()->killed){
801039f0:	e8 b4 01 00 00       	call   80103ba9 <myproc>
801039f5:	8b 40 24             	mov    0x24(%eax),%eax
801039f8:	85 c0                	test   %eax,%eax
801039fa:	74 19                	je     80103a15 <piperead+0x40>
      release(&p->lock);
801039fc:	8b 45 08             	mov    0x8(%ebp),%eax
801039ff:	83 ec 0c             	sub    $0xc,%esp
80103a02:	50                   	push   %eax
80103a03:	e8 2f 0f 00 00       	call   80104937 <release>
80103a08:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a10:	e9 be 00 00 00       	jmp    80103ad3 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a15:	8b 45 08             	mov    0x8(%ebp),%eax
80103a18:	8b 55 08             	mov    0x8(%ebp),%edx
80103a1b:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a21:	83 ec 08             	sub    $0x8,%esp
80103a24:	50                   	push   %eax
80103a25:	52                   	push   %edx
80103a26:	e8 57 0a 00 00       	call   80104482 <sleep>
80103a2b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a31:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a37:	8b 45 08             	mov    0x8(%ebp),%eax
80103a3a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a40:	39 c2                	cmp    %eax,%edx
80103a42:	75 0d                	jne    80103a51 <piperead+0x7c>
80103a44:	8b 45 08             	mov    0x8(%ebp),%eax
80103a47:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103a4d:	85 c0                	test   %eax,%eax
80103a4f:	75 9f                	jne    801039f0 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a58:	eb 48                	jmp    80103aa2 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a63:	8b 45 08             	mov    0x8(%ebp),%eax
80103a66:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a6c:	39 c2                	cmp    %eax,%edx
80103a6e:	74 3c                	je     80103aac <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a70:	8b 45 08             	mov    0x8(%ebp),%eax
80103a73:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103a79:	8d 48 01             	lea    0x1(%eax),%ecx
80103a7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a7f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103a85:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a8a:	89 c1                	mov    %eax,%ecx
80103a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a92:	01 c2                	add    %eax,%edx
80103a94:	8b 45 08             	mov    0x8(%ebp),%eax
80103a97:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103a9c:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa5:	3b 45 10             	cmp    0x10(%ebp),%eax
80103aa8:	7c b0                	jl     80103a5a <piperead+0x85>
80103aaa:	eb 01                	jmp    80103aad <piperead+0xd8>
      break;
80103aac:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103aad:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab0:	05 38 02 00 00       	add    $0x238,%eax
80103ab5:	83 ec 0c             	sub    $0xc,%esp
80103ab8:	50                   	push   %eax
80103ab9:	e8 b3 0a 00 00       	call   80104571 <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 6a 0e 00 00       	call   80104937 <release>
80103acd:	83 c4 10             	add    $0x10,%esp
  return i;
80103ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ad3:	c9                   	leave  
80103ad4:	c3                   	ret    

80103ad5 <readeflags>:
{
80103ad5:	55                   	push   %ebp
80103ad6:	89 e5                	mov    %esp,%ebp
80103ad8:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103adb:	9c                   	pushf  
80103adc:	58                   	pop    %eax
80103add:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103ae3:	c9                   	leave  
80103ae4:	c3                   	ret    

80103ae5 <sti>:
{
80103ae5:	55                   	push   %ebp
80103ae6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103ae8:	fb                   	sti    
}
80103ae9:	90                   	nop
80103aea:	5d                   	pop    %ebp
80103aeb:	c3                   	ret    

80103aec <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103aec:	f3 0f 1e fb          	endbr32 
80103af0:	55                   	push   %ebp
80103af1:	89 e5                	mov    %esp,%ebp
80103af3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	68 b0 a5 10 80       	push   $0x8010a5b0
80103afe:	68 00 55 19 80       	push   $0x80195500
80103b03:	e8 97 0d 00 00       	call   8010489f <initlock>
80103b08:	83 c4 10             	add    $0x10,%esp
}
80103b0b:	90                   	nop
80103b0c:	c9                   	leave  
80103b0d:	c3                   	ret    

80103b0e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b0e:	f3 0f 1e fb          	endbr32 
80103b12:	55                   	push   %ebp
80103b13:	89 e5                	mov    %esp,%ebp
80103b15:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b18:	e8 10 00 00 00       	call   80103b2d <mycpu>
80103b1d:	2d c0 7c 19 80       	sub    $0x80197cc0,%eax
80103b22:	c1 f8 04             	sar    $0x4,%eax
80103b25:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b2b:	c9                   	leave  
80103b2c:	c3                   	ret    

80103b2d <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b2d:	f3 0f 1e fb          	endbr32 
80103b31:	55                   	push   %ebp
80103b32:	89 e5                	mov    %esp,%ebp
80103b34:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b37:	e8 99 ff ff ff       	call   80103ad5 <readeflags>
80103b3c:	25 00 02 00 00       	and    $0x200,%eax
80103b41:	85 c0                	test   %eax,%eax
80103b43:	74 0d                	je     80103b52 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103b45:	83 ec 0c             	sub    $0xc,%esp
80103b48:	68 b8 a5 10 80       	push   $0x8010a5b8
80103b4d:	e8 73 ca ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
80103b52:	e8 a8 f0 ff ff       	call   80102bff <lapicid>
80103b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103b5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b61:	eb 2d                	jmp    80103b90 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b66:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b6c:	05 c0 7c 19 80       	add    $0x80197cc0,%eax
80103b71:	0f b6 00             	movzbl (%eax),%eax
80103b74:	0f b6 c0             	movzbl %al,%eax
80103b77:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b7a:	75 10                	jne    80103b8c <mycpu+0x5f>
      return &cpus[i];
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b85:	05 c0 7c 19 80       	add    $0x80197cc0,%eax
80103b8a:	eb 1b                	jmp    80103ba7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b90:	a1 80 7f 19 80       	mov    0x80197f80,%eax
80103b95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b98:	7c c9                	jl     80103b63 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b9a:	83 ec 0c             	sub    $0xc,%esp
80103b9d:	68 de a5 10 80       	push   $0x8010a5de
80103ba2:	e8 1e ca ff ff       	call   801005c5 <panic>
}
80103ba7:	c9                   	leave  
80103ba8:	c3                   	ret    

80103ba9 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103ba9:	f3 0f 1e fb          	endbr32 
80103bad:	55                   	push   %ebp
80103bae:	89 e5                	mov    %esp,%ebp
80103bb0:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103bb3:	e8 89 0e 00 00       	call   80104a41 <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 c1 0e 00 00       	call   80104a92 <popcli>
  return p;
80103bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bd4:	c9                   	leave  
80103bd5:	c3                   	ret    

80103bd6 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103bd6:	f3 0f 1e fb          	endbr32 
80103bda:	55                   	push   %ebp
80103bdb:	89 e5                	mov    %esp,%ebp
80103bdd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103be0:	83 ec 0c             	sub    $0xc,%esp
80103be3:	68 00 55 19 80       	push   $0x80195500
80103be8:	e8 d8 0c 00 00       	call   801048c5 <acquire>
80103bed:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103bf0:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103bf7:	eb 0e                	jmp    80103c07 <allocproc+0x31>
    if(p->state == UNUSED){
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 0c             	mov    0xc(%eax),%eax
80103bff:	85 c0                	test   %eax,%eax
80103c01:	74 27                	je     80103c2a <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c03:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103c07:	81 7d f4 34 74 19 80 	cmpl   $0x80197434,-0xc(%ebp)
80103c0e:	72 e9                	jb     80103bf9 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c10:	83 ec 0c             	sub    $0xc,%esp
80103c13:	68 00 55 19 80       	push   $0x80195500
80103c18:	e8 1a 0d 00 00       	call   80104937 <release>
80103c1d:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c20:	b8 00 00 00 00       	mov    $0x0,%eax
80103c25:	e9 b6 00 00 00       	jmp    80103ce0 <allocproc+0x10a>
      goto found;
80103c2a:	90                   	nop
80103c2b:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80103c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c32:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c39:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c3e:	8d 50 01             	lea    0x1(%eax),%edx
80103c41:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103c47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c4a:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103c4d:	83 ec 0c             	sub    $0xc,%esp
80103c50:	68 00 55 19 80       	push   $0x80195500
80103c55:	e8 dd 0c 00 00       	call   80104937 <release>
80103c5a:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103c5d:	e8 30 ec ff ff       	call   80102892 <kalloc>
80103c62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c65:	89 42 08             	mov    %eax,0x8(%edx)
80103c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6b:	8b 40 08             	mov    0x8(%eax),%eax
80103c6e:	85 c0                	test   %eax,%eax
80103c70:	75 11                	jne    80103c83 <allocproc+0xad>
    p->state = UNUSED;
80103c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c75:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103c7c:	b8 00 00 00 00       	mov    $0x0,%eax
80103c81:	eb 5d                	jmp    80103ce0 <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
80103c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c86:	8b 40 08             	mov    0x8(%eax),%eax
80103c89:	05 00 10 00 00       	add    $0x1000,%eax
80103c8e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103c91:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103c9b:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103c9e:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103ca2:	ba 7a 5f 10 80       	mov    $0x80105f7a,%edx
80103ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103caa:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103cac:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cb6:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbc:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cbf:	83 ec 04             	sub    $0x4,%esp
80103cc2:	6a 14                	push   $0x14
80103cc4:	6a 00                	push   $0x0
80103cc6:	50                   	push   %eax
80103cc7:	e8 88 0e 00 00       	call   80104b54 <memset>
80103ccc:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd2:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cd5:	ba 38 44 10 80       	mov    $0x80104438,%edx
80103cda:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ce0:	c9                   	leave  
80103ce1:	c3                   	ret    

80103ce2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103ce2:	f3 0f 1e fb          	endbr32 
80103ce6:	55                   	push   %ebp
80103ce7:	89 e5                	mov    %esp,%ebp
80103ce9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103cec:	e8 e5 fe ff ff       	call   80103bd6 <allocproc>
80103cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf7:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103cfc:	e8 fa 37 00 00       	call   801074fb <setupkvm>
80103d01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d04:	89 42 04             	mov    %eax,0x4(%edx)
80103d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0a:	8b 40 04             	mov    0x4(%eax),%eax
80103d0d:	85 c0                	test   %eax,%eax
80103d0f:	75 0d                	jne    80103d1e <userinit+0x3c>
    panic("userinit: out of memory?");
80103d11:	83 ec 0c             	sub    $0xc,%esp
80103d14:	68 ee a5 10 80       	push   $0x8010a5ee
80103d19:	e8 a7 c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d1e:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d26:	8b 40 04             	mov    0x4(%eax),%eax
80103d29:	83 ec 04             	sub    $0x4,%esp
80103d2c:	52                   	push   %edx
80103d2d:	68 ec f4 10 80       	push   $0x8010f4ec
80103d32:	50                   	push   %eax
80103d33:	e8 90 3a 00 00       	call   801077c8 <inituvm>
80103d38:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d47:	8b 40 18             	mov    0x18(%eax),%eax
80103d4a:	83 ec 04             	sub    $0x4,%esp
80103d4d:	6a 4c                	push   $0x4c
80103d4f:	6a 00                	push   $0x0
80103d51:	50                   	push   %eax
80103d52:	e8 fd 0d 00 00       	call   80104b54 <memset>
80103d57:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5d:	8b 40 18             	mov    0x18(%eax),%eax
80103d60:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d69:	8b 40 18             	mov    0x18(%eax),%eax
80103d6c:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d75:	8b 50 18             	mov    0x18(%eax),%edx
80103d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7b:	8b 40 18             	mov    0x18(%eax),%eax
80103d7e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d82:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d89:	8b 50 18             	mov    0x18(%eax),%edx
80103d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8f:	8b 40 18             	mov    0x18(%eax),%eax
80103d92:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d96:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9d:	8b 40 18             	mov    0x18(%eax),%eax
80103da0:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103daa:	8b 40 18             	mov    0x18(%eax),%eax
80103dad:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db7:	8b 40 18             	mov    0x18(%eax),%eax
80103dba:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc4:	83 c0 6c             	add    $0x6c,%eax
80103dc7:	83 ec 04             	sub    $0x4,%esp
80103dca:	6a 10                	push   $0x10
80103dcc:	68 07 a6 10 80       	push   $0x8010a607
80103dd1:	50                   	push   %eax
80103dd2:	e8 98 0f 00 00       	call   80104d6f <safestrcpy>
80103dd7:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103dda:	83 ec 0c             	sub    $0xc,%esp
80103ddd:	68 10 a6 10 80       	push   $0x8010a610
80103de2:	e8 00 e8 ff ff       	call   801025e7 <namei>
80103de7:	83 c4 10             	add    $0x10,%esp
80103dea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ded:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103df0:	83 ec 0c             	sub    $0xc,%esp
80103df3:	68 00 55 19 80       	push   $0x80195500
80103df8:	e8 c8 0a 00 00       	call   801048c5 <acquire>
80103dfd:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e03:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e0a:	83 ec 0c             	sub    $0xc,%esp
80103e0d:	68 00 55 19 80       	push   $0x80195500
80103e12:	e8 20 0b 00 00       	call   80104937 <release>
80103e17:	83 c4 10             	add    $0x10,%esp
}
80103e1a:	90                   	nop
80103e1b:	c9                   	leave  
80103e1c:	c3                   	ret    

80103e1d <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e1d:	f3 0f 1e fb          	endbr32 
80103e21:	55                   	push   %ebp
80103e22:	89 e5                	mov    %esp,%ebp
80103e24:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e27:	e8 7d fd ff ff       	call   80103ba9 <myproc>
80103e2c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e32:	8b 00                	mov    (%eax),%eax
80103e34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103e37:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e3b:	7e 2e                	jle    80103e6b <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e3d:	8b 55 08             	mov    0x8(%ebp),%edx
80103e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e43:	01 c2                	add    %eax,%edx
80103e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e48:	8b 40 04             	mov    0x4(%eax),%eax
80103e4b:	83 ec 04             	sub    $0x4,%esp
80103e4e:	52                   	push   %edx
80103e4f:	ff 75 f4             	pushl  -0xc(%ebp)
80103e52:	50                   	push   %eax
80103e53:	e8 b5 3a 00 00       	call   8010790d <allocuvm>
80103e58:	83 c4 10             	add    $0x10,%esp
80103e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e62:	75 3b                	jne    80103e9f <growproc+0x82>
      return -1;
80103e64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e69:	eb 4f                	jmp    80103eba <growproc+0x9d>
  } else if(n < 0){
80103e6b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e6f:	79 2e                	jns    80103e9f <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e71:	8b 55 08             	mov    0x8(%ebp),%edx
80103e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e77:	01 c2                	add    %eax,%edx
80103e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e7c:	8b 40 04             	mov    0x4(%eax),%eax
80103e7f:	83 ec 04             	sub    $0x4,%esp
80103e82:	52                   	push   %edx
80103e83:	ff 75 f4             	pushl  -0xc(%ebp)
80103e86:	50                   	push   %eax
80103e87:	e8 8a 3b 00 00       	call   80107a16 <deallocuvm>
80103e8c:	83 c4 10             	add    $0x10,%esp
80103e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e96:	75 07                	jne    80103e9f <growproc+0x82>
      return -1;
80103e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e9d:	eb 1b                	jmp    80103eba <growproc+0x9d>
  }
  curproc->sz = sz;
80103e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ea2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ea5:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103ea7:	83 ec 0c             	sub    $0xc,%esp
80103eaa:	ff 75 f0             	pushl  -0x10(%ebp)
80103ead:	e8 73 37 00 00       	call   80107625 <switchuvm>
80103eb2:	83 c4 10             	add    $0x10,%esp
  return 0;
80103eb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103eba:	c9                   	leave  
80103ebb:	c3                   	ret    

80103ebc <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103ebc:	f3 0f 1e fb          	endbr32 
80103ec0:	55                   	push   %ebp
80103ec1:	89 e5                	mov    %esp,%ebp
80103ec3:	57                   	push   %edi
80103ec4:	56                   	push   %esi
80103ec5:	53                   	push   %ebx
80103ec6:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103ec9:	e8 db fc ff ff       	call   80103ba9 <myproc>
80103ece:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103ed1:	e8 00 fd ff ff       	call   80103bd6 <allocproc>
80103ed6:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103ed9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103edd:	75 0a                	jne    80103ee9 <fork+0x2d>
    return -1;
80103edf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ee4:	e9 48 01 00 00       	jmp    80104031 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103ee9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eec:	8b 10                	mov    (%eax),%edx
80103eee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ef1:	8b 40 04             	mov    0x4(%eax),%eax
80103ef4:	83 ec 08             	sub    $0x8,%esp
80103ef7:	52                   	push   %edx
80103ef8:	50                   	push   %eax
80103ef9:	e8 c2 3c 00 00       	call   80107bc0 <copyuvm>
80103efe:	83 c4 10             	add    $0x10,%esp
80103f01:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f04:	89 42 04             	mov    %eax,0x4(%edx)
80103f07:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f0a:	8b 40 04             	mov    0x4(%eax),%eax
80103f0d:	85 c0                	test   %eax,%eax
80103f0f:	75 30                	jne    80103f41 <fork+0x85>
    kfree(np->kstack);
80103f11:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f14:	8b 40 08             	mov    0x8(%eax),%eax
80103f17:	83 ec 0c             	sub    $0xc,%esp
80103f1a:	50                   	push   %eax
80103f1b:	e8 d4 e8 ff ff       	call   801027f4 <kfree>
80103f20:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103f23:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103f2d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f30:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3c:	e9 f0 00 00 00       	jmp    80104031 <fork+0x175>
  }
  np->sz = curproc->sz;
80103f41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f44:	8b 10                	mov    (%eax),%edx
80103f46:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f49:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103f4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103f51:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103f54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f57:	8b 48 18             	mov    0x18(%eax),%ecx
80103f5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f5d:	8b 40 18             	mov    0x18(%eax),%eax
80103f60:	89 c2                	mov    %eax,%edx
80103f62:	89 cb                	mov    %ecx,%ebx
80103f64:	b8 13 00 00 00       	mov    $0x13,%eax
80103f69:	89 d7                	mov    %edx,%edi
80103f6b:	89 de                	mov    %ebx,%esi
80103f6d:	89 c1                	mov    %eax,%ecx
80103f6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103f71:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f74:	8b 40 18             	mov    0x18(%eax),%eax
80103f77:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103f7e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103f85:	eb 3b                	jmp    80103fc2 <fork+0x106>
    if(curproc->ofile[i])
80103f87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f8d:	83 c2 08             	add    $0x8,%edx
80103f90:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f94:	85 c0                	test   %eax,%eax
80103f96:	74 26                	je     80103fbe <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103f98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f9e:	83 c2 08             	add    $0x8,%edx
80103fa1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fa5:	83 ec 0c             	sub    $0xc,%esp
80103fa8:	50                   	push   %eax
80103fa9:	e8 e6 d0 ff ff       	call   80101094 <filedup>
80103fae:	83 c4 10             	add    $0x10,%esp
80103fb1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fb4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103fb7:	83 c1 08             	add    $0x8,%ecx
80103fba:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103fbe:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103fc2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103fc6:	7e bf                	jle    80103f87 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80103fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fcb:	8b 40 68             	mov    0x68(%eax),%eax
80103fce:	83 ec 0c             	sub    $0xc,%esp
80103fd1:	50                   	push   %eax
80103fd2:	e8 67 da ff ff       	call   80101a3e <idup>
80103fd7:	83 c4 10             	add    $0x10,%esp
80103fda:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fdd:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103fe0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fe3:	8d 50 6c             	lea    0x6c(%eax),%edx
80103fe6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fe9:	83 c0 6c             	add    $0x6c,%eax
80103fec:	83 ec 04             	sub    $0x4,%esp
80103fef:	6a 10                	push   $0x10
80103ff1:	52                   	push   %edx
80103ff2:	50                   	push   %eax
80103ff3:	e8 77 0d 00 00       	call   80104d6f <safestrcpy>
80103ff8:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ffb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ffe:	8b 40 10             	mov    0x10(%eax),%eax
80104001:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104004:	83 ec 0c             	sub    $0xc,%esp
80104007:	68 00 55 19 80       	push   $0x80195500
8010400c:	e8 b4 08 00 00       	call   801048c5 <acquire>
80104011:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104014:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104017:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010401e:	83 ec 0c             	sub    $0xc,%esp
80104021:	68 00 55 19 80       	push   $0x80195500
80104026:	e8 0c 09 00 00       	call   80104937 <release>
8010402b:	83 c4 10             	add    $0x10,%esp

  return pid;
8010402e:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104031:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104034:	5b                   	pop    %ebx
80104035:	5e                   	pop    %esi
80104036:	5f                   	pop    %edi
80104037:	5d                   	pop    %ebp
80104038:	c3                   	ret    

80104039 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104039:	f3 0f 1e fb          	endbr32 
8010403d:	55                   	push   %ebp
8010403e:	89 e5                	mov    %esp,%ebp
80104040:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104043:	e8 61 fb ff ff       	call   80103ba9 <myproc>
80104048:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010404b:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104050:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104053:	75 0d                	jne    80104062 <exit+0x29>
    panic("init exiting");
80104055:	83 ec 0c             	sub    $0xc,%esp
80104058:	68 12 a6 10 80       	push   $0x8010a612
8010405d:	e8 63 c5 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104062:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104069:	eb 3f                	jmp    801040aa <exit+0x71>
    if(curproc->ofile[fd]){
8010406b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010406e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104071:	83 c2 08             	add    $0x8,%edx
80104074:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104078:	85 c0                	test   %eax,%eax
8010407a:	74 2a                	je     801040a6 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
8010407c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010407f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104082:	83 c2 08             	add    $0x8,%edx
80104085:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104089:	83 ec 0c             	sub    $0xc,%esp
8010408c:	50                   	push   %eax
8010408d:	e8 57 d0 ff ff       	call   801010e9 <fileclose>
80104092:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104095:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104098:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010409b:	83 c2 08             	add    $0x8,%edx
8010409e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801040a5:	00 
  for(fd = 0; fd < NOFILE; fd++){
801040a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801040aa:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801040ae:	7e bb                	jle    8010406b <exit+0x32>
    }
  }

  begin_op();
801040b0:	e8 bc f0 ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801040b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b8:	8b 40 68             	mov    0x68(%eax),%eax
801040bb:	83 ec 0c             	sub    $0xc,%esp
801040be:	50                   	push   %eax
801040bf:	e8 21 db ff ff       	call   80101be5 <iput>
801040c4:	83 c4 10             	add    $0x10,%esp
  end_op();
801040c7:	e8 35 f1 ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
801040cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040cf:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801040d6:	83 ec 0c             	sub    $0xc,%esp
801040d9:	68 00 55 19 80       	push   $0x80195500
801040de:	e8 e2 07 00 00       	call   801048c5 <acquire>
801040e3:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801040e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040e9:	8b 40 14             	mov    0x14(%eax),%eax
801040ec:	83 ec 0c             	sub    $0xc,%esp
801040ef:	50                   	push   %eax
801040f0:	e8 38 04 00 00       	call   8010452d <wakeup1>
801040f5:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040f8:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801040ff:	eb 37                	jmp    80104138 <exit+0xff>
    if(p->parent == curproc){
80104101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104104:	8b 40 14             	mov    0x14(%eax),%eax
80104107:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010410a:	75 28                	jne    80104134 <exit+0xfb>
      p->parent = initproc;
8010410c:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104115:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411b:	8b 40 0c             	mov    0xc(%eax),%eax
8010411e:	83 f8 05             	cmp    $0x5,%eax
80104121:	75 11                	jne    80104134 <exit+0xfb>
        wakeup1(initproc);
80104123:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104128:	83 ec 0c             	sub    $0xc,%esp
8010412b:	50                   	push   %eax
8010412c:	e8 fc 03 00 00       	call   8010452d <wakeup1>
80104131:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104134:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104138:	81 7d f4 34 74 19 80 	cmpl   $0x80197434,-0xc(%ebp)
8010413f:	72 c0                	jb     80104101 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104141:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104144:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010414b:	e8 ed 01 00 00       	call   8010433d <sched>
  panic("zombie exit");
80104150:	83 ec 0c             	sub    $0xc,%esp
80104153:	68 1f a6 10 80       	push   $0x8010a61f
80104158:	e8 68 c4 ff ff       	call   801005c5 <panic>

8010415d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010415d:	f3 0f 1e fb          	endbr32 
80104161:	55                   	push   %ebp
80104162:	89 e5                	mov    %esp,%ebp
80104164:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104167:	e8 3d fa ff ff       	call   80103ba9 <myproc>
8010416c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010416f:	83 ec 0c             	sub    $0xc,%esp
80104172:	68 00 55 19 80       	push   $0x80195500
80104177:	e8 49 07 00 00       	call   801048c5 <acquire>
8010417c:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010417f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104186:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010418d:	e9 a1 00 00 00       	jmp    80104233 <wait+0xd6>
      if(p->parent != curproc)
80104192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104195:	8b 40 14             	mov    0x14(%eax),%eax
80104198:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010419b:	0f 85 8d 00 00 00    	jne    8010422e <wait+0xd1>
        continue;
      havekids = 1;
801041a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801041a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ab:	8b 40 0c             	mov    0xc(%eax),%eax
801041ae:	83 f8 05             	cmp    $0x5,%eax
801041b1:	75 7c                	jne    8010422f <wait+0xd2>
        // Found one.
        pid = p->pid;
801041b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b6:	8b 40 10             	mov    0x10(%eax),%eax
801041b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801041bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bf:	8b 40 08             	mov    0x8(%eax),%eax
801041c2:	83 ec 0c             	sub    $0xc,%esp
801041c5:	50                   	push   %eax
801041c6:	e8 29 e6 ff ff       	call   801027f4 <kfree>
801041cb:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801041ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801041d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041db:	8b 40 04             	mov    0x4(%eax),%eax
801041de:	83 ec 0c             	sub    $0xc,%esp
801041e1:	50                   	push   %eax
801041e2:	e8 f7 38 00 00       	call   80107ade <freevm>
801041e7:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801041ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ed:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801041f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104201:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104208:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010420f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104212:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104219:	83 ec 0c             	sub    $0xc,%esp
8010421c:	68 00 55 19 80       	push   $0x80195500
80104221:	e8 11 07 00 00       	call   80104937 <release>
80104226:	83 c4 10             	add    $0x10,%esp
        return pid;
80104229:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010422c:	eb 51                	jmp    8010427f <wait+0x122>
        continue;
8010422e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010422f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104233:	81 7d f4 34 74 19 80 	cmpl   $0x80197434,-0xc(%ebp)
8010423a:	0f 82 52 ff ff ff    	jb     80104192 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104240:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104244:	74 0a                	je     80104250 <wait+0xf3>
80104246:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104249:	8b 40 24             	mov    0x24(%eax),%eax
8010424c:	85 c0                	test   %eax,%eax
8010424e:	74 17                	je     80104267 <wait+0x10a>
      release(&ptable.lock);
80104250:	83 ec 0c             	sub    $0xc,%esp
80104253:	68 00 55 19 80       	push   $0x80195500
80104258:	e8 da 06 00 00       	call   80104937 <release>
8010425d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104265:	eb 18                	jmp    8010427f <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104267:	83 ec 08             	sub    $0x8,%esp
8010426a:	68 00 55 19 80       	push   $0x80195500
8010426f:	ff 75 ec             	pushl  -0x14(%ebp)
80104272:	e8 0b 02 00 00       	call   80104482 <sleep>
80104277:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010427a:	e9 00 ff ff ff       	jmp    8010417f <wait+0x22>
  }
}
8010427f:	c9                   	leave  
80104280:	c3                   	ret    

80104281 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104281:	f3 0f 1e fb          	endbr32 
80104285:	55                   	push   %ebp
80104286:	89 e5                	mov    %esp,%ebp
80104288:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010428b:	e8 9d f8 ff ff       	call   80103b2d <mycpu>
80104290:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104293:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104296:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010429d:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801042a0:	e8 40 f8 ff ff       	call   80103ae5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801042a5:	83 ec 0c             	sub    $0xc,%esp
801042a8:	68 00 55 19 80       	push   $0x80195500
801042ad:	e8 13 06 00 00       	call   801048c5 <acquire>
801042b2:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042b5:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801042bc:	eb 61                	jmp    8010431f <scheduler+0x9e>
      if(p->state != RUNNABLE)
801042be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c1:	8b 40 0c             	mov    0xc(%eax),%eax
801042c4:	83 f8 03             	cmp    $0x3,%eax
801042c7:	75 51                	jne    8010431a <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801042c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042cf:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801042d5:	83 ec 0c             	sub    $0xc,%esp
801042d8:	ff 75 f4             	pushl  -0xc(%ebp)
801042db:	e8 45 33 00 00       	call   80107625 <switchuvm>
801042e0:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801042e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e6:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801042ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f0:	8b 40 1c             	mov    0x1c(%eax),%eax
801042f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801042f6:	83 c2 04             	add    $0x4,%edx
801042f9:	83 ec 08             	sub    $0x8,%esp
801042fc:	50                   	push   %eax
801042fd:	52                   	push   %edx
801042fe:	e8 e5 0a 00 00       	call   80104de8 <swtch>
80104303:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104306:	e8 fd 32 00 00       	call   80107608 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010430b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010430e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104315:	00 00 00 
80104318:	eb 01                	jmp    8010431b <scheduler+0x9a>
        continue;
8010431a:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010431b:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010431f:	81 7d f4 34 74 19 80 	cmpl   $0x80197434,-0xc(%ebp)
80104326:	72 96                	jb     801042be <scheduler+0x3d>
    }
    release(&ptable.lock);
80104328:	83 ec 0c             	sub    $0xc,%esp
8010432b:	68 00 55 19 80       	push   $0x80195500
80104330:	e8 02 06 00 00       	call   80104937 <release>
80104335:	83 c4 10             	add    $0x10,%esp
    sti();
80104338:	e9 63 ff ff ff       	jmp    801042a0 <scheduler+0x1f>

8010433d <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010433d:	f3 0f 1e fb          	endbr32 
80104341:	55                   	push   %ebp
80104342:	89 e5                	mov    %esp,%ebp
80104344:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104347:	e8 5d f8 ff ff       	call   80103ba9 <myproc>
8010434c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
8010434f:	83 ec 0c             	sub    $0xc,%esp
80104352:	68 00 55 19 80       	push   $0x80195500
80104357:	e8 b0 06 00 00       	call   80104a0c <holding>
8010435c:	83 c4 10             	add    $0x10,%esp
8010435f:	85 c0                	test   %eax,%eax
80104361:	75 0d                	jne    80104370 <sched+0x33>
    panic("sched ptable.lock");
80104363:	83 ec 0c             	sub    $0xc,%esp
80104366:	68 2b a6 10 80       	push   $0x8010a62b
8010436b:	e8 55 c2 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104370:	e8 b8 f7 ff ff       	call   80103b2d <mycpu>
80104375:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010437b:	83 f8 01             	cmp    $0x1,%eax
8010437e:	74 0d                	je     8010438d <sched+0x50>
    panic("sched locks");
80104380:	83 ec 0c             	sub    $0xc,%esp
80104383:	68 3d a6 10 80       	push   $0x8010a63d
80104388:	e8 38 c2 ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
8010438d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104390:	8b 40 0c             	mov    0xc(%eax),%eax
80104393:	83 f8 04             	cmp    $0x4,%eax
80104396:	75 0d                	jne    801043a5 <sched+0x68>
    panic("sched running");
80104398:	83 ec 0c             	sub    $0xc,%esp
8010439b:	68 49 a6 10 80       	push   $0x8010a649
801043a0:	e8 20 c2 ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
801043a5:	e8 2b f7 ff ff       	call   80103ad5 <readeflags>
801043aa:	25 00 02 00 00       	and    $0x200,%eax
801043af:	85 c0                	test   %eax,%eax
801043b1:	74 0d                	je     801043c0 <sched+0x83>
    panic("sched interruptible");
801043b3:	83 ec 0c             	sub    $0xc,%esp
801043b6:	68 57 a6 10 80       	push   $0x8010a657
801043bb:	e8 05 c2 ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
801043c0:	e8 68 f7 ff ff       	call   80103b2d <mycpu>
801043c5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801043cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801043ce:	e8 5a f7 ff ff       	call   80103b2d <mycpu>
801043d3:	8b 40 04             	mov    0x4(%eax),%eax
801043d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043d9:	83 c2 1c             	add    $0x1c,%edx
801043dc:	83 ec 08             	sub    $0x8,%esp
801043df:	50                   	push   %eax
801043e0:	52                   	push   %edx
801043e1:	e8 02 0a 00 00       	call   80104de8 <swtch>
801043e6:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801043e9:	e8 3f f7 ff ff       	call   80103b2d <mycpu>
801043ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043f1:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801043f7:	90                   	nop
801043f8:	c9                   	leave  
801043f9:	c3                   	ret    

801043fa <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801043fa:	f3 0f 1e fb          	endbr32 
801043fe:	55                   	push   %ebp
801043ff:	89 e5                	mov    %esp,%ebp
80104401:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104404:	83 ec 0c             	sub    $0xc,%esp
80104407:	68 00 55 19 80       	push   $0x80195500
8010440c:	e8 b4 04 00 00       	call   801048c5 <acquire>
80104411:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104414:	e8 90 f7 ff ff       	call   80103ba9 <myproc>
80104419:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104420:	e8 18 ff ff ff       	call   8010433d <sched>
  release(&ptable.lock);
80104425:	83 ec 0c             	sub    $0xc,%esp
80104428:	68 00 55 19 80       	push   $0x80195500
8010442d:	e8 05 05 00 00       	call   80104937 <release>
80104432:	83 c4 10             	add    $0x10,%esp
}
80104435:	90                   	nop
80104436:	c9                   	leave  
80104437:	c3                   	ret    

80104438 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104438:	f3 0f 1e fb          	endbr32 
8010443c:	55                   	push   %ebp
8010443d:	89 e5                	mov    %esp,%ebp
8010443f:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104442:	83 ec 0c             	sub    $0xc,%esp
80104445:	68 00 55 19 80       	push   $0x80195500
8010444a:	e8 e8 04 00 00       	call   80104937 <release>
8010444f:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104452:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104457:	85 c0                	test   %eax,%eax
80104459:	74 24                	je     8010447f <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010445b:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104462:	00 00 00 
    iinit(ROOTDEV);
80104465:	83 ec 0c             	sub    $0xc,%esp
80104468:	6a 01                	push   $0x1
8010446a:	e8 87 d2 ff ff       	call   801016f6 <iinit>
8010446f:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104472:	83 ec 0c             	sub    $0xc,%esp
80104475:	6a 01                	push   $0x1
80104477:	e8 c2 ea ff ff       	call   80102f3e <initlog>
8010447c:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010447f:	90                   	nop
80104480:	c9                   	leave  
80104481:	c3                   	ret    

80104482 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104482:	f3 0f 1e fb          	endbr32 
80104486:	55                   	push   %ebp
80104487:	89 e5                	mov    %esp,%ebp
80104489:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010448c:	e8 18 f7 ff ff       	call   80103ba9 <myproc>
80104491:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104494:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104498:	75 0d                	jne    801044a7 <sleep+0x25>
    panic("sleep");
8010449a:	83 ec 0c             	sub    $0xc,%esp
8010449d:	68 6b a6 10 80       	push   $0x8010a66b
801044a2:	e8 1e c1 ff ff       	call   801005c5 <panic>

  if(lk == 0)
801044a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801044ab:	75 0d                	jne    801044ba <sleep+0x38>
    panic("sleep without lk");
801044ad:	83 ec 0c             	sub    $0xc,%esp
801044b0:	68 71 a6 10 80       	push   $0x8010a671
801044b5:	e8 0b c1 ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801044ba:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801044c1:	74 1e                	je     801044e1 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
801044c3:	83 ec 0c             	sub    $0xc,%esp
801044c6:	68 00 55 19 80       	push   $0x80195500
801044cb:	e8 f5 03 00 00       	call   801048c5 <acquire>
801044d0:	83 c4 10             	add    $0x10,%esp
    release(lk);
801044d3:	83 ec 0c             	sub    $0xc,%esp
801044d6:	ff 75 0c             	pushl  0xc(%ebp)
801044d9:	e8 59 04 00 00       	call   80104937 <release>
801044de:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801044e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e4:	8b 55 08             	mov    0x8(%ebp),%edx
801044e7:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801044ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ed:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801044f4:	e8 44 fe ff ff       	call   8010433d <sched>

  // Tidy up.
  p->chan = 0;
801044f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fc:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104503:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
8010450a:	74 1e                	je     8010452a <sleep+0xa8>
    release(&ptable.lock);
8010450c:	83 ec 0c             	sub    $0xc,%esp
8010450f:	68 00 55 19 80       	push   $0x80195500
80104514:	e8 1e 04 00 00       	call   80104937 <release>
80104519:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010451c:	83 ec 0c             	sub    $0xc,%esp
8010451f:	ff 75 0c             	pushl  0xc(%ebp)
80104522:	e8 9e 03 00 00       	call   801048c5 <acquire>
80104527:	83 c4 10             	add    $0x10,%esp
  }
}
8010452a:	90                   	nop
8010452b:	c9                   	leave  
8010452c:	c3                   	ret    

8010452d <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010452d:	f3 0f 1e fb          	endbr32 
80104531:	55                   	push   %ebp
80104532:	89 e5                	mov    %esp,%ebp
80104534:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104537:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
8010453e:	eb 24                	jmp    80104564 <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104540:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104543:	8b 40 0c             	mov    0xc(%eax),%eax
80104546:	83 f8 02             	cmp    $0x2,%eax
80104549:	75 15                	jne    80104560 <wakeup1+0x33>
8010454b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010454e:	8b 40 20             	mov    0x20(%eax),%eax
80104551:	39 45 08             	cmp    %eax,0x8(%ebp)
80104554:	75 0a                	jne    80104560 <wakeup1+0x33>
      p->state = RUNNABLE;
80104556:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104559:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104560:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104564:	81 7d fc 34 74 19 80 	cmpl   $0x80197434,-0x4(%ebp)
8010456b:	72 d3                	jb     80104540 <wakeup1+0x13>
}
8010456d:	90                   	nop
8010456e:	90                   	nop
8010456f:	c9                   	leave  
80104570:	c3                   	ret    

80104571 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104571:	f3 0f 1e fb          	endbr32 
80104575:	55                   	push   %ebp
80104576:	89 e5                	mov    %esp,%ebp
80104578:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010457b:	83 ec 0c             	sub    $0xc,%esp
8010457e:	68 00 55 19 80       	push   $0x80195500
80104583:	e8 3d 03 00 00       	call   801048c5 <acquire>
80104588:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010458b:	83 ec 0c             	sub    $0xc,%esp
8010458e:	ff 75 08             	pushl  0x8(%ebp)
80104591:	e8 97 ff ff ff       	call   8010452d <wakeup1>
80104596:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104599:	83 ec 0c             	sub    $0xc,%esp
8010459c:	68 00 55 19 80       	push   $0x80195500
801045a1:	e8 91 03 00 00       	call   80104937 <release>
801045a6:	83 c4 10             	add    $0x10,%esp
}
801045a9:	90                   	nop
801045aa:	c9                   	leave  
801045ab:	c3                   	ret    

801045ac <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801045ac:	f3 0f 1e fb          	endbr32 
801045b0:	55                   	push   %ebp
801045b1:	89 e5                	mov    %esp,%ebp
801045b3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801045b6:	83 ec 0c             	sub    $0xc,%esp
801045b9:	68 00 55 19 80       	push   $0x80195500
801045be:	e8 02 03 00 00       	call   801048c5 <acquire>
801045c3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045c6:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801045cd:	eb 45                	jmp    80104614 <kill+0x68>
    if(p->pid == pid){
801045cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d2:	8b 40 10             	mov    0x10(%eax),%eax
801045d5:	39 45 08             	cmp    %eax,0x8(%ebp)
801045d8:	75 36                	jne    80104610 <kill+0x64>
      p->killed = 1;
801045da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dd:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801045e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e7:	8b 40 0c             	mov    0xc(%eax),%eax
801045ea:	83 f8 02             	cmp    $0x2,%eax
801045ed:	75 0a                	jne    801045f9 <kill+0x4d>
        p->state = RUNNABLE;
801045ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801045f9:	83 ec 0c             	sub    $0xc,%esp
801045fc:	68 00 55 19 80       	push   $0x80195500
80104601:	e8 31 03 00 00       	call   80104937 <release>
80104606:	83 c4 10             	add    $0x10,%esp
      return 0;
80104609:	b8 00 00 00 00       	mov    $0x0,%eax
8010460e:	eb 22                	jmp    80104632 <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104610:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104614:	81 7d f4 34 74 19 80 	cmpl   $0x80197434,-0xc(%ebp)
8010461b:	72 b2                	jb     801045cf <kill+0x23>
    }
  }
  release(&ptable.lock);
8010461d:	83 ec 0c             	sub    $0xc,%esp
80104620:	68 00 55 19 80       	push   $0x80195500
80104625:	e8 0d 03 00 00       	call   80104937 <release>
8010462a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010462d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104632:	c9                   	leave  
80104633:	c3                   	ret    

80104634 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104634:	f3 0f 1e fb          	endbr32 
80104638:	55                   	push   %ebp
80104639:	89 e5                	mov    %esp,%ebp
8010463b:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010463e:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
80104645:	e9 d7 00 00 00       	jmp    80104721 <procdump+0xed>
    if(p->state == UNUSED)
8010464a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010464d:	8b 40 0c             	mov    0xc(%eax),%eax
80104650:	85 c0                	test   %eax,%eax
80104652:	0f 84 c4 00 00 00    	je     8010471c <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104658:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010465b:	8b 40 0c             	mov    0xc(%eax),%eax
8010465e:	83 f8 05             	cmp    $0x5,%eax
80104661:	77 23                	ja     80104686 <procdump+0x52>
80104663:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104666:	8b 40 0c             	mov    0xc(%eax),%eax
80104669:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104670:	85 c0                	test   %eax,%eax
80104672:	74 12                	je     80104686 <procdump+0x52>
      state = states[p->state];
80104674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104677:	8b 40 0c             	mov    0xc(%eax),%eax
8010467a:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104681:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104684:	eb 07                	jmp    8010468d <procdump+0x59>
    else
      state = "???";
80104686:	c7 45 ec 82 a6 10 80 	movl   $0x8010a682,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010468d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104690:	8d 50 6c             	lea    0x6c(%eax),%edx
80104693:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104696:	8b 40 10             	mov    0x10(%eax),%eax
80104699:	52                   	push   %edx
8010469a:	ff 75 ec             	pushl  -0x14(%ebp)
8010469d:	50                   	push   %eax
8010469e:	68 86 a6 10 80       	push   $0x8010a686
801046a3:	e8 64 bd ff ff       	call   8010040c <cprintf>
801046a8:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801046ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046ae:	8b 40 0c             	mov    0xc(%eax),%eax
801046b1:	83 f8 02             	cmp    $0x2,%eax
801046b4:	75 54                	jne    8010470a <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801046b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b9:	8b 40 1c             	mov    0x1c(%eax),%eax
801046bc:	8b 40 0c             	mov    0xc(%eax),%eax
801046bf:	83 c0 08             	add    $0x8,%eax
801046c2:	89 c2                	mov    %eax,%edx
801046c4:	83 ec 08             	sub    $0x8,%esp
801046c7:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046ca:	50                   	push   %eax
801046cb:	52                   	push   %edx
801046cc:	e8 bc 02 00 00       	call   8010498d <getcallerpcs>
801046d1:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801046db:	eb 1c                	jmp    801046f9 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801046e4:	83 ec 08             	sub    $0x8,%esp
801046e7:	50                   	push   %eax
801046e8:	68 8f a6 10 80       	push   $0x8010a68f
801046ed:	e8 1a bd ff ff       	call   8010040c <cprintf>
801046f2:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801046f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046f9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801046fd:	7f 0b                	jg     8010470a <procdump+0xd6>
801046ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104702:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104706:	85 c0                	test   %eax,%eax
80104708:	75 d3                	jne    801046dd <procdump+0xa9>
    }
    cprintf("\n");
8010470a:	83 ec 0c             	sub    $0xc,%esp
8010470d:	68 93 a6 10 80       	push   $0x8010a693
80104712:	e8 f5 bc ff ff       	call   8010040c <cprintf>
80104717:	83 c4 10             	add    $0x10,%esp
8010471a:	eb 01                	jmp    8010471d <procdump+0xe9>
      continue;
8010471c:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010471d:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104721:	81 7d f0 34 74 19 80 	cmpl   $0x80197434,-0x10(%ebp)
80104728:	0f 82 1c ff ff ff    	jb     8010464a <procdump+0x16>
  }
}
8010472e:	90                   	nop
8010472f:	90                   	nop
80104730:	c9                   	leave  
80104731:	c3                   	ret    

80104732 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104732:	f3 0f 1e fb          	endbr32 
80104736:	55                   	push   %ebp
80104737:	89 e5                	mov    %esp,%ebp
80104739:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010473c:	8b 45 08             	mov    0x8(%ebp),%eax
8010473f:	83 c0 04             	add    $0x4,%eax
80104742:	83 ec 08             	sub    $0x8,%esp
80104745:	68 bf a6 10 80       	push   $0x8010a6bf
8010474a:	50                   	push   %eax
8010474b:	e8 4f 01 00 00       	call   8010489f <initlock>
80104750:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104753:	8b 45 08             	mov    0x8(%ebp),%eax
80104756:	8b 55 0c             	mov    0xc(%ebp),%edx
80104759:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010475c:	8b 45 08             	mov    0x8(%ebp),%eax
8010475f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104765:	8b 45 08             	mov    0x8(%ebp),%eax
80104768:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010476f:	90                   	nop
80104770:	c9                   	leave  
80104771:	c3                   	ret    

80104772 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104772:	f3 0f 1e fb          	endbr32 
80104776:	55                   	push   %ebp
80104777:	89 e5                	mov    %esp,%ebp
80104779:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010477c:	8b 45 08             	mov    0x8(%ebp),%eax
8010477f:	83 c0 04             	add    $0x4,%eax
80104782:	83 ec 0c             	sub    $0xc,%esp
80104785:	50                   	push   %eax
80104786:	e8 3a 01 00 00       	call   801048c5 <acquire>
8010478b:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
8010478e:	eb 15                	jmp    801047a5 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104790:	8b 45 08             	mov    0x8(%ebp),%eax
80104793:	83 c0 04             	add    $0x4,%eax
80104796:	83 ec 08             	sub    $0x8,%esp
80104799:	50                   	push   %eax
8010479a:	ff 75 08             	pushl  0x8(%ebp)
8010479d:	e8 e0 fc ff ff       	call   80104482 <sleep>
801047a2:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801047a5:	8b 45 08             	mov    0x8(%ebp),%eax
801047a8:	8b 00                	mov    (%eax),%eax
801047aa:	85 c0                	test   %eax,%eax
801047ac:	75 e2                	jne    80104790 <acquiresleep+0x1e>
  }
  lk->locked = 1;
801047ae:	8b 45 08             	mov    0x8(%ebp),%eax
801047b1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801047b7:	e8 ed f3 ff ff       	call   80103ba9 <myproc>
801047bc:	8b 50 10             	mov    0x10(%eax),%edx
801047bf:	8b 45 08             	mov    0x8(%ebp),%eax
801047c2:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801047c5:	8b 45 08             	mov    0x8(%ebp),%eax
801047c8:	83 c0 04             	add    $0x4,%eax
801047cb:	83 ec 0c             	sub    $0xc,%esp
801047ce:	50                   	push   %eax
801047cf:	e8 63 01 00 00       	call   80104937 <release>
801047d4:	83 c4 10             	add    $0x10,%esp
}
801047d7:	90                   	nop
801047d8:	c9                   	leave  
801047d9:	c3                   	ret    

801047da <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801047da:	f3 0f 1e fb          	endbr32 
801047de:	55                   	push   %ebp
801047df:	89 e5                	mov    %esp,%ebp
801047e1:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801047e4:	8b 45 08             	mov    0x8(%ebp),%eax
801047e7:	83 c0 04             	add    $0x4,%eax
801047ea:	83 ec 0c             	sub    $0xc,%esp
801047ed:	50                   	push   %eax
801047ee:	e8 d2 00 00 00       	call   801048c5 <acquire>
801047f3:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801047f6:	8b 45 08             	mov    0x8(%ebp),%eax
801047f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801047ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104802:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104809:	83 ec 0c             	sub    $0xc,%esp
8010480c:	ff 75 08             	pushl  0x8(%ebp)
8010480f:	e8 5d fd ff ff       	call   80104571 <wakeup>
80104814:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104817:	8b 45 08             	mov    0x8(%ebp),%eax
8010481a:	83 c0 04             	add    $0x4,%eax
8010481d:	83 ec 0c             	sub    $0xc,%esp
80104820:	50                   	push   %eax
80104821:	e8 11 01 00 00       	call   80104937 <release>
80104826:	83 c4 10             	add    $0x10,%esp
}
80104829:	90                   	nop
8010482a:	c9                   	leave  
8010482b:	c3                   	ret    

8010482c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010482c:	f3 0f 1e fb          	endbr32 
80104830:	55                   	push   %ebp
80104831:	89 e5                	mov    %esp,%ebp
80104833:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104836:	8b 45 08             	mov    0x8(%ebp),%eax
80104839:	83 c0 04             	add    $0x4,%eax
8010483c:	83 ec 0c             	sub    $0xc,%esp
8010483f:	50                   	push   %eax
80104840:	e8 80 00 00 00       	call   801048c5 <acquire>
80104845:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104848:	8b 45 08             	mov    0x8(%ebp),%eax
8010484b:	8b 00                	mov    (%eax),%eax
8010484d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104850:	8b 45 08             	mov    0x8(%ebp),%eax
80104853:	83 c0 04             	add    $0x4,%eax
80104856:	83 ec 0c             	sub    $0xc,%esp
80104859:	50                   	push   %eax
8010485a:	e8 d8 00 00 00       	call   80104937 <release>
8010485f:	83 c4 10             	add    $0x10,%esp
  return r;
80104862:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104865:	c9                   	leave  
80104866:	c3                   	ret    

80104867 <readeflags>:
{
80104867:	55                   	push   %ebp
80104868:	89 e5                	mov    %esp,%ebp
8010486a:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010486d:	9c                   	pushf  
8010486e:	58                   	pop    %eax
8010486f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104872:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104875:	c9                   	leave  
80104876:	c3                   	ret    

80104877 <cli>:
{
80104877:	55                   	push   %ebp
80104878:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010487a:	fa                   	cli    
}
8010487b:	90                   	nop
8010487c:	5d                   	pop    %ebp
8010487d:	c3                   	ret    

8010487e <sti>:
{
8010487e:	55                   	push   %ebp
8010487f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104881:	fb                   	sti    
}
80104882:	90                   	nop
80104883:	5d                   	pop    %ebp
80104884:	c3                   	ret    

80104885 <xchg>:
{
80104885:	55                   	push   %ebp
80104886:	89 e5                	mov    %esp,%ebp
80104888:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010488b:	8b 55 08             	mov    0x8(%ebp),%edx
8010488e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104891:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104894:	f0 87 02             	lock xchg %eax,(%edx)
80104897:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010489a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010489d:	c9                   	leave  
8010489e:	c3                   	ret    

8010489f <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010489f:	f3 0f 1e fb          	endbr32 
801048a3:	55                   	push   %ebp
801048a4:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801048a6:	8b 45 08             	mov    0x8(%ebp),%eax
801048a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801048ac:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801048af:	8b 45 08             	mov    0x8(%ebp),%eax
801048b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801048b8:	8b 45 08             	mov    0x8(%ebp),%eax
801048bb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801048c2:	90                   	nop
801048c3:	5d                   	pop    %ebp
801048c4:	c3                   	ret    

801048c5 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801048c5:	f3 0f 1e fb          	endbr32 
801048c9:	55                   	push   %ebp
801048ca:	89 e5                	mov    %esp,%ebp
801048cc:	53                   	push   %ebx
801048cd:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801048d0:	e8 6c 01 00 00       	call   80104a41 <pushcli>
  if(holding(lk)){
801048d5:	8b 45 08             	mov    0x8(%ebp),%eax
801048d8:	83 ec 0c             	sub    $0xc,%esp
801048db:	50                   	push   %eax
801048dc:	e8 2b 01 00 00       	call   80104a0c <holding>
801048e1:	83 c4 10             	add    $0x10,%esp
801048e4:	85 c0                	test   %eax,%eax
801048e6:	74 0d                	je     801048f5 <acquire+0x30>
    panic("acquire");
801048e8:	83 ec 0c             	sub    $0xc,%esp
801048eb:	68 ca a6 10 80       	push   $0x8010a6ca
801048f0:	e8 d0 bc ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801048f5:	90                   	nop
801048f6:	8b 45 08             	mov    0x8(%ebp),%eax
801048f9:	83 ec 08             	sub    $0x8,%esp
801048fc:	6a 01                	push   $0x1
801048fe:	50                   	push   %eax
801048ff:	e8 81 ff ff ff       	call   80104885 <xchg>
80104904:	83 c4 10             	add    $0x10,%esp
80104907:	85 c0                	test   %eax,%eax
80104909:	75 eb                	jne    801048f6 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010490b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104910:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104913:	e8 15 f2 ff ff       	call   80103b2d <mycpu>
80104918:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010491b:	8b 45 08             	mov    0x8(%ebp),%eax
8010491e:	83 c0 0c             	add    $0xc,%eax
80104921:	83 ec 08             	sub    $0x8,%esp
80104924:	50                   	push   %eax
80104925:	8d 45 08             	lea    0x8(%ebp),%eax
80104928:	50                   	push   %eax
80104929:	e8 5f 00 00 00       	call   8010498d <getcallerpcs>
8010492e:	83 c4 10             	add    $0x10,%esp
}
80104931:	90                   	nop
80104932:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104935:	c9                   	leave  
80104936:	c3                   	ret    

80104937 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104937:	f3 0f 1e fb          	endbr32 
8010493b:	55                   	push   %ebp
8010493c:	89 e5                	mov    %esp,%ebp
8010493e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104941:	83 ec 0c             	sub    $0xc,%esp
80104944:	ff 75 08             	pushl  0x8(%ebp)
80104947:	e8 c0 00 00 00       	call   80104a0c <holding>
8010494c:	83 c4 10             	add    $0x10,%esp
8010494f:	85 c0                	test   %eax,%eax
80104951:	75 0d                	jne    80104960 <release+0x29>
    panic("release");
80104953:	83 ec 0c             	sub    $0xc,%esp
80104956:	68 d2 a6 10 80       	push   $0x8010a6d2
8010495b:	e8 65 bc ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104960:	8b 45 08             	mov    0x8(%ebp),%eax
80104963:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010496a:	8b 45 08             	mov    0x8(%ebp),%eax
8010496d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104974:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104979:	8b 45 08             	mov    0x8(%ebp),%eax
8010497c:	8b 55 08             	mov    0x8(%ebp),%edx
8010497f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104985:	e8 08 01 00 00       	call   80104a92 <popcli>
}
8010498a:	90                   	nop
8010498b:	c9                   	leave  
8010498c:	c3                   	ret    

8010498d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010498d:	f3 0f 1e fb          	endbr32 
80104991:	55                   	push   %ebp
80104992:	89 e5                	mov    %esp,%ebp
80104994:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104997:	8b 45 08             	mov    0x8(%ebp),%eax
8010499a:	83 e8 08             	sub    $0x8,%eax
8010499d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801049a0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801049a7:	eb 38                	jmp    801049e1 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801049a9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801049ad:	74 53                	je     80104a02 <getcallerpcs+0x75>
801049af:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801049b6:	76 4a                	jbe    80104a02 <getcallerpcs+0x75>
801049b8:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801049bc:	74 44                	je     80104a02 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801049be:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801049cb:	01 c2                	add    %eax,%edx
801049cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049d0:	8b 40 04             	mov    0x4(%eax),%eax
801049d3:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801049d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801049d8:	8b 00                	mov    (%eax),%eax
801049da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801049dd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801049e1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801049e5:	7e c2                	jle    801049a9 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801049e7:	eb 19                	jmp    80104a02 <getcallerpcs+0x75>
    pcs[i] = 0;
801049e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801049ec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801049f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801049f6:	01 d0                	add    %edx,%eax
801049f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801049fe:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104a02:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104a06:	7e e1                	jle    801049e9 <getcallerpcs+0x5c>
}
80104a08:	90                   	nop
80104a09:	90                   	nop
80104a0a:	c9                   	leave  
80104a0b:	c3                   	ret    

80104a0c <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104a0c:	f3 0f 1e fb          	endbr32 
80104a10:	55                   	push   %ebp
80104a11:	89 e5                	mov    %esp,%ebp
80104a13:	53                   	push   %ebx
80104a14:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104a17:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1a:	8b 00                	mov    (%eax),%eax
80104a1c:	85 c0                	test   %eax,%eax
80104a1e:	74 16                	je     80104a36 <holding+0x2a>
80104a20:	8b 45 08             	mov    0x8(%ebp),%eax
80104a23:	8b 58 08             	mov    0x8(%eax),%ebx
80104a26:	e8 02 f1 ff ff       	call   80103b2d <mycpu>
80104a2b:	39 c3                	cmp    %eax,%ebx
80104a2d:	75 07                	jne    80104a36 <holding+0x2a>
80104a2f:	b8 01 00 00 00       	mov    $0x1,%eax
80104a34:	eb 05                	jmp    80104a3b <holding+0x2f>
80104a36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a3b:	83 c4 04             	add    $0x4,%esp
80104a3e:	5b                   	pop    %ebx
80104a3f:	5d                   	pop    %ebp
80104a40:	c3                   	ret    

80104a41 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104a41:	f3 0f 1e fb          	endbr32 
80104a45:	55                   	push   %ebp
80104a46:	89 e5                	mov    %esp,%ebp
80104a48:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104a4b:	e8 17 fe ff ff       	call   80104867 <readeflags>
80104a50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104a53:	e8 1f fe ff ff       	call   80104877 <cli>
  if(mycpu()->ncli == 0)
80104a58:	e8 d0 f0 ff ff       	call   80103b2d <mycpu>
80104a5d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a63:	85 c0                	test   %eax,%eax
80104a65:	75 14                	jne    80104a7b <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104a67:	e8 c1 f0 ff ff       	call   80103b2d <mycpu>
80104a6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a6f:	81 e2 00 02 00 00    	and    $0x200,%edx
80104a75:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104a7b:	e8 ad f0 ff ff       	call   80103b2d <mycpu>
80104a80:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a86:	83 c2 01             	add    $0x1,%edx
80104a89:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104a8f:	90                   	nop
80104a90:	c9                   	leave  
80104a91:	c3                   	ret    

80104a92 <popcli>:

void
popcli(void)
{
80104a92:	f3 0f 1e fb          	endbr32 
80104a96:	55                   	push   %ebp
80104a97:	89 e5                	mov    %esp,%ebp
80104a99:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104a9c:	e8 c6 fd ff ff       	call   80104867 <readeflags>
80104aa1:	25 00 02 00 00       	and    $0x200,%eax
80104aa6:	85 c0                	test   %eax,%eax
80104aa8:	74 0d                	je     80104ab7 <popcli+0x25>
    panic("popcli - interruptible");
80104aaa:	83 ec 0c             	sub    $0xc,%esp
80104aad:	68 da a6 10 80       	push   $0x8010a6da
80104ab2:	e8 0e bb ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104ab7:	e8 71 f0 ff ff       	call   80103b2d <mycpu>
80104abc:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ac2:	83 ea 01             	sub    $0x1,%edx
80104ac5:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104acb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ad1:	85 c0                	test   %eax,%eax
80104ad3:	79 0d                	jns    80104ae2 <popcli+0x50>
    panic("popcli");
80104ad5:	83 ec 0c             	sub    $0xc,%esp
80104ad8:	68 f1 a6 10 80       	push   $0x8010a6f1
80104add:	e8 e3 ba ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104ae2:	e8 46 f0 ff ff       	call   80103b2d <mycpu>
80104ae7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104aed:	85 c0                	test   %eax,%eax
80104aef:	75 14                	jne    80104b05 <popcli+0x73>
80104af1:	e8 37 f0 ff ff       	call   80103b2d <mycpu>
80104af6:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104afc:	85 c0                	test   %eax,%eax
80104afe:	74 05                	je     80104b05 <popcli+0x73>
    sti();
80104b00:	e8 79 fd ff ff       	call   8010487e <sti>
}
80104b05:	90                   	nop
80104b06:	c9                   	leave  
80104b07:	c3                   	ret    

80104b08 <stosb>:
{
80104b08:	55                   	push   %ebp
80104b09:	89 e5                	mov    %esp,%ebp
80104b0b:	57                   	push   %edi
80104b0c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b10:	8b 55 10             	mov    0x10(%ebp),%edx
80104b13:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b16:	89 cb                	mov    %ecx,%ebx
80104b18:	89 df                	mov    %ebx,%edi
80104b1a:	89 d1                	mov    %edx,%ecx
80104b1c:	fc                   	cld    
80104b1d:	f3 aa                	rep stos %al,%es:(%edi)
80104b1f:	89 ca                	mov    %ecx,%edx
80104b21:	89 fb                	mov    %edi,%ebx
80104b23:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b26:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b29:	90                   	nop
80104b2a:	5b                   	pop    %ebx
80104b2b:	5f                   	pop    %edi
80104b2c:	5d                   	pop    %ebp
80104b2d:	c3                   	ret    

80104b2e <stosl>:
{
80104b2e:	55                   	push   %ebp
80104b2f:	89 e5                	mov    %esp,%ebp
80104b31:	57                   	push   %edi
80104b32:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b36:	8b 55 10             	mov    0x10(%ebp),%edx
80104b39:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b3c:	89 cb                	mov    %ecx,%ebx
80104b3e:	89 df                	mov    %ebx,%edi
80104b40:	89 d1                	mov    %edx,%ecx
80104b42:	fc                   	cld    
80104b43:	f3 ab                	rep stos %eax,%es:(%edi)
80104b45:	89 ca                	mov    %ecx,%edx
80104b47:	89 fb                	mov    %edi,%ebx
80104b49:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104b4c:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104b4f:	90                   	nop
80104b50:	5b                   	pop    %ebx
80104b51:	5f                   	pop    %edi
80104b52:	5d                   	pop    %ebp
80104b53:	c3                   	ret    

80104b54 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104b54:	f3 0f 1e fb          	endbr32 
80104b58:	55                   	push   %ebp
80104b59:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5e:	83 e0 03             	and    $0x3,%eax
80104b61:	85 c0                	test   %eax,%eax
80104b63:	75 43                	jne    80104ba8 <memset+0x54>
80104b65:	8b 45 10             	mov    0x10(%ebp),%eax
80104b68:	83 e0 03             	and    $0x3,%eax
80104b6b:	85 c0                	test   %eax,%eax
80104b6d:	75 39                	jne    80104ba8 <memset+0x54>
    c &= 0xFF;
80104b6f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104b76:	8b 45 10             	mov    0x10(%ebp),%eax
80104b79:	c1 e8 02             	shr    $0x2,%eax
80104b7c:	89 c1                	mov    %eax,%ecx
80104b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b81:	c1 e0 18             	shl    $0x18,%eax
80104b84:	89 c2                	mov    %eax,%edx
80104b86:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b89:	c1 e0 10             	shl    $0x10,%eax
80104b8c:	09 c2                	or     %eax,%edx
80104b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b91:	c1 e0 08             	shl    $0x8,%eax
80104b94:	09 d0                	or     %edx,%eax
80104b96:	0b 45 0c             	or     0xc(%ebp),%eax
80104b99:	51                   	push   %ecx
80104b9a:	50                   	push   %eax
80104b9b:	ff 75 08             	pushl  0x8(%ebp)
80104b9e:	e8 8b ff ff ff       	call   80104b2e <stosl>
80104ba3:	83 c4 0c             	add    $0xc,%esp
80104ba6:	eb 12                	jmp    80104bba <memset+0x66>
  } else
    stosb(dst, c, n);
80104ba8:	8b 45 10             	mov    0x10(%ebp),%eax
80104bab:	50                   	push   %eax
80104bac:	ff 75 0c             	pushl  0xc(%ebp)
80104baf:	ff 75 08             	pushl  0x8(%ebp)
80104bb2:	e8 51 ff ff ff       	call   80104b08 <stosb>
80104bb7:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104bba:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104bbd:	c9                   	leave  
80104bbe:	c3                   	ret    

80104bbf <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104bbf:	f3 0f 1e fb          	endbr32 
80104bc3:	55                   	push   %ebp
80104bc4:	89 e5                	mov    %esp,%ebp
80104bc6:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bcc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104bd5:	eb 30                	jmp    80104c07 <memcmp+0x48>
    if(*s1 != *s2)
80104bd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bda:	0f b6 10             	movzbl (%eax),%edx
80104bdd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104be0:	0f b6 00             	movzbl (%eax),%eax
80104be3:	38 c2                	cmp    %al,%dl
80104be5:	74 18                	je     80104bff <memcmp+0x40>
      return *s1 - *s2;
80104be7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bea:	0f b6 00             	movzbl (%eax),%eax
80104bed:	0f b6 d0             	movzbl %al,%edx
80104bf0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104bf3:	0f b6 00             	movzbl (%eax),%eax
80104bf6:	0f b6 c0             	movzbl %al,%eax
80104bf9:	29 c2                	sub    %eax,%edx
80104bfb:	89 d0                	mov    %edx,%eax
80104bfd:	eb 1a                	jmp    80104c19 <memcmp+0x5a>
    s1++, s2++;
80104bff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104c03:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104c07:	8b 45 10             	mov    0x10(%ebp),%eax
80104c0a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c0d:	89 55 10             	mov    %edx,0x10(%ebp)
80104c10:	85 c0                	test   %eax,%eax
80104c12:	75 c3                	jne    80104bd7 <memcmp+0x18>
  }

  return 0;
80104c14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c19:	c9                   	leave  
80104c1a:	c3                   	ret    

80104c1b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104c1b:	f3 0f 1e fb          	endbr32 
80104c1f:	55                   	push   %ebp
80104c20:	89 e5                	mov    %esp,%ebp
80104c22:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c28:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c34:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104c37:	73 54                	jae    80104c8d <memmove+0x72>
80104c39:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c3c:	8b 45 10             	mov    0x10(%ebp),%eax
80104c3f:	01 d0                	add    %edx,%eax
80104c41:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104c44:	73 47                	jae    80104c8d <memmove+0x72>
    s += n;
80104c46:	8b 45 10             	mov    0x10(%ebp),%eax
80104c49:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104c4c:	8b 45 10             	mov    0x10(%ebp),%eax
80104c4f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104c52:	eb 13                	jmp    80104c67 <memmove+0x4c>
      *--d = *--s;
80104c54:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104c58:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104c5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c5f:	0f b6 10             	movzbl (%eax),%edx
80104c62:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c65:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c67:	8b 45 10             	mov    0x10(%ebp),%eax
80104c6a:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c6d:	89 55 10             	mov    %edx,0x10(%ebp)
80104c70:	85 c0                	test   %eax,%eax
80104c72:	75 e0                	jne    80104c54 <memmove+0x39>
  if(s < d && s + n > d){
80104c74:	eb 24                	jmp    80104c9a <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104c76:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104c79:	8d 42 01             	lea    0x1(%edx),%eax
80104c7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104c7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c82:	8d 48 01             	lea    0x1(%eax),%ecx
80104c85:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104c88:	0f b6 12             	movzbl (%edx),%edx
80104c8b:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104c8d:	8b 45 10             	mov    0x10(%ebp),%eax
80104c90:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c93:	89 55 10             	mov    %edx,0x10(%ebp)
80104c96:	85 c0                	test   %eax,%eax
80104c98:	75 dc                	jne    80104c76 <memmove+0x5b>

  return dst;
80104c9a:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104c9d:	c9                   	leave  
80104c9e:	c3                   	ret    

80104c9f <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104c9f:	f3 0f 1e fb          	endbr32 
80104ca3:	55                   	push   %ebp
80104ca4:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ca6:	ff 75 10             	pushl  0x10(%ebp)
80104ca9:	ff 75 0c             	pushl  0xc(%ebp)
80104cac:	ff 75 08             	pushl  0x8(%ebp)
80104caf:	e8 67 ff ff ff       	call   80104c1b <memmove>
80104cb4:	83 c4 0c             	add    $0xc,%esp
}
80104cb7:	c9                   	leave  
80104cb8:	c3                   	ret    

80104cb9 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104cb9:	f3 0f 1e fb          	endbr32 
80104cbd:	55                   	push   %ebp
80104cbe:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104cc0:	eb 0c                	jmp    80104cce <strncmp+0x15>
    n--, p++, q++;
80104cc2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104cc6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104cca:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104cce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cd2:	74 1a                	je     80104cee <strncmp+0x35>
80104cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd7:	0f b6 00             	movzbl (%eax),%eax
80104cda:	84 c0                	test   %al,%al
80104cdc:	74 10                	je     80104cee <strncmp+0x35>
80104cde:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce1:	0f b6 10             	movzbl (%eax),%edx
80104ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ce7:	0f b6 00             	movzbl (%eax),%eax
80104cea:	38 c2                	cmp    %al,%dl
80104cec:	74 d4                	je     80104cc2 <strncmp+0x9>
  if(n == 0)
80104cee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104cf2:	75 07                	jne    80104cfb <strncmp+0x42>
    return 0;
80104cf4:	b8 00 00 00 00       	mov    $0x0,%eax
80104cf9:	eb 16                	jmp    80104d11 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104cfb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cfe:	0f b6 00             	movzbl (%eax),%eax
80104d01:	0f b6 d0             	movzbl %al,%edx
80104d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d07:	0f b6 00             	movzbl (%eax),%eax
80104d0a:	0f b6 c0             	movzbl %al,%eax
80104d0d:	29 c2                	sub    %eax,%edx
80104d0f:	89 d0                	mov    %edx,%eax
}
80104d11:	5d                   	pop    %ebp
80104d12:	c3                   	ret    

80104d13 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104d13:	f3 0f 1e fb          	endbr32 
80104d17:	55                   	push   %ebp
80104d18:	89 e5                	mov    %esp,%ebp
80104d1a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d1d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d20:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104d23:	90                   	nop
80104d24:	8b 45 10             	mov    0x10(%ebp),%eax
80104d27:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d2a:	89 55 10             	mov    %edx,0x10(%ebp)
80104d2d:	85 c0                	test   %eax,%eax
80104d2f:	7e 2c                	jle    80104d5d <strncpy+0x4a>
80104d31:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d34:	8d 42 01             	lea    0x1(%edx),%eax
80104d37:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3d:	8d 48 01             	lea    0x1(%eax),%ecx
80104d40:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104d43:	0f b6 12             	movzbl (%edx),%edx
80104d46:	88 10                	mov    %dl,(%eax)
80104d48:	0f b6 00             	movzbl (%eax),%eax
80104d4b:	84 c0                	test   %al,%al
80104d4d:	75 d5                	jne    80104d24 <strncpy+0x11>
    ;
  while(n-- > 0)
80104d4f:	eb 0c                	jmp    80104d5d <strncpy+0x4a>
    *s++ = 0;
80104d51:	8b 45 08             	mov    0x8(%ebp),%eax
80104d54:	8d 50 01             	lea    0x1(%eax),%edx
80104d57:	89 55 08             	mov    %edx,0x8(%ebp)
80104d5a:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104d5d:	8b 45 10             	mov    0x10(%ebp),%eax
80104d60:	8d 50 ff             	lea    -0x1(%eax),%edx
80104d63:	89 55 10             	mov    %edx,0x10(%ebp)
80104d66:	85 c0                	test   %eax,%eax
80104d68:	7f e7                	jg     80104d51 <strncpy+0x3e>
  return os;
80104d6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d6d:	c9                   	leave  
80104d6e:	c3                   	ret    

80104d6f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104d6f:	f3 0f 1e fb          	endbr32 
80104d73:	55                   	push   %ebp
80104d74:	89 e5                	mov    %esp,%ebp
80104d76:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104d79:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104d7f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d83:	7f 05                	jg     80104d8a <safestrcpy+0x1b>
    return os;
80104d85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d88:	eb 31                	jmp    80104dbb <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104d8a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104d8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d92:	7e 1e                	jle    80104db2 <safestrcpy+0x43>
80104d94:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d97:	8d 42 01             	lea    0x1(%edx),%eax
80104d9a:	89 45 0c             	mov    %eax,0xc(%ebp)
80104d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104da0:	8d 48 01             	lea    0x1(%eax),%ecx
80104da3:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104da6:	0f b6 12             	movzbl (%edx),%edx
80104da9:	88 10                	mov    %dl,(%eax)
80104dab:	0f b6 00             	movzbl (%eax),%eax
80104dae:	84 c0                	test   %al,%al
80104db0:	75 d8                	jne    80104d8a <safestrcpy+0x1b>
    ;
  *s = 0;
80104db2:	8b 45 08             	mov    0x8(%ebp),%eax
80104db5:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104db8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104dbb:	c9                   	leave  
80104dbc:	c3                   	ret    

80104dbd <strlen>:

int
strlen(const char *s)
{
80104dbd:	f3 0f 1e fb          	endbr32 
80104dc1:	55                   	push   %ebp
80104dc2:	89 e5                	mov    %esp,%ebp
80104dc4:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104dc7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104dce:	eb 04                	jmp    80104dd4 <strlen+0x17>
80104dd0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104dd4:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104dda:	01 d0                	add    %edx,%eax
80104ddc:	0f b6 00             	movzbl (%eax),%eax
80104ddf:	84 c0                	test   %al,%al
80104de1:	75 ed                	jne    80104dd0 <strlen+0x13>
    ;
  return n;
80104de3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104de6:	c9                   	leave  
80104de7:	c3                   	ret    

80104de8 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104de8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104dec:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104df0:	55                   	push   %ebp
  pushl %ebx
80104df1:	53                   	push   %ebx
  pushl %esi
80104df2:	56                   	push   %esi
  pushl %edi
80104df3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104df4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104df6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104df8:	5f                   	pop    %edi
  popl %esi
80104df9:	5e                   	pop    %esi
  popl %ebx
80104dfa:	5b                   	pop    %ebx
  popl %ebp
80104dfb:	5d                   	pop    %ebp
  ret
80104dfc:	c3                   	ret    

80104dfd <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104dfd:	f3 0f 1e fb          	endbr32 
80104e01:	55                   	push   %ebp
80104e02:	89 e5                	mov    %esp,%ebp
80104e04:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104e07:	e8 9d ed ff ff       	call   80103ba9 <myproc>
80104e0c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e12:	8b 00                	mov    (%eax),%eax
80104e14:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e17:	73 0f                	jae    80104e28 <fetchint+0x2b>
80104e19:	8b 45 08             	mov    0x8(%ebp),%eax
80104e1c:	8d 50 04             	lea    0x4(%eax),%edx
80104e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e22:	8b 00                	mov    (%eax),%eax
80104e24:	39 c2                	cmp    %eax,%edx
80104e26:	76 07                	jbe    80104e2f <fetchint+0x32>
    return -1;
80104e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e2d:	eb 0f                	jmp    80104e3e <fetchint+0x41>
  *ip = *(int*)(addr);
80104e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e32:	8b 10                	mov    (%eax),%edx
80104e34:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e37:	89 10                	mov    %edx,(%eax)
  return 0;
80104e39:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e3e:	c9                   	leave  
80104e3f:	c3                   	ret    

80104e40 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104e40:	f3 0f 1e fb          	endbr32 
80104e44:	55                   	push   %ebp
80104e45:	89 e5                	mov    %esp,%ebp
80104e47:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104e4a:	e8 5a ed ff ff       	call   80103ba9 <myproc>
80104e4f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e55:	8b 00                	mov    (%eax),%eax
80104e57:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e5a:	72 07                	jb     80104e63 <fetchstr+0x23>
    return -1;
80104e5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e61:	eb 43                	jmp    80104ea6 <fetchstr+0x66>
  *pp = (char*)addr;
80104e63:	8b 55 08             	mov    0x8(%ebp),%edx
80104e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e69:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e6e:	8b 00                	mov    (%eax),%eax
80104e70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104e73:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e76:	8b 00                	mov    (%eax),%eax
80104e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e7b:	eb 1c                	jmp    80104e99 <fetchstr+0x59>
    if(*s == 0)
80104e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e80:	0f b6 00             	movzbl (%eax),%eax
80104e83:	84 c0                	test   %al,%al
80104e85:	75 0e                	jne    80104e95 <fetchstr+0x55>
      return s - *pp;
80104e87:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8a:	8b 00                	mov    (%eax),%eax
80104e8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e8f:	29 c2                	sub    %eax,%edx
80104e91:	89 d0                	mov    %edx,%eax
80104e93:	eb 11                	jmp    80104ea6 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80104e95:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104e9f:	72 dc                	jb     80104e7d <fetchstr+0x3d>
  }
  return -1;
80104ea1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ea6:	c9                   	leave  
80104ea7:	c3                   	ret    

80104ea8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104ea8:	f3 0f 1e fb          	endbr32 
80104eac:	55                   	push   %ebp
80104ead:	89 e5                	mov    %esp,%ebp
80104eaf:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104eb2:	e8 f2 ec ff ff       	call   80103ba9 <myproc>
80104eb7:	8b 40 18             	mov    0x18(%eax),%eax
80104eba:	8b 40 44             	mov    0x44(%eax),%eax
80104ebd:	8b 55 08             	mov    0x8(%ebp),%edx
80104ec0:	c1 e2 02             	shl    $0x2,%edx
80104ec3:	01 d0                	add    %edx,%eax
80104ec5:	83 c0 04             	add    $0x4,%eax
80104ec8:	83 ec 08             	sub    $0x8,%esp
80104ecb:	ff 75 0c             	pushl  0xc(%ebp)
80104ece:	50                   	push   %eax
80104ecf:	e8 29 ff ff ff       	call   80104dfd <fetchint>
80104ed4:	83 c4 10             	add    $0x10,%esp
}
80104ed7:	c9                   	leave  
80104ed8:	c3                   	ret    

80104ed9 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104ed9:	f3 0f 1e fb          	endbr32 
80104edd:	55                   	push   %ebp
80104ede:	89 e5                	mov    %esp,%ebp
80104ee0:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104ee3:	e8 c1 ec ff ff       	call   80103ba9 <myproc>
80104ee8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104eeb:	83 ec 08             	sub    $0x8,%esp
80104eee:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ef1:	50                   	push   %eax
80104ef2:	ff 75 08             	pushl  0x8(%ebp)
80104ef5:	e8 ae ff ff ff       	call   80104ea8 <argint>
80104efa:	83 c4 10             	add    $0x10,%esp
80104efd:	85 c0                	test   %eax,%eax
80104eff:	79 07                	jns    80104f08 <argptr+0x2f>
    return -1;
80104f01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f06:	eb 3b                	jmp    80104f43 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104f08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f0c:	78 1f                	js     80104f2d <argptr+0x54>
80104f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f11:	8b 00                	mov    (%eax),%eax
80104f13:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f16:	39 d0                	cmp    %edx,%eax
80104f18:	76 13                	jbe    80104f2d <argptr+0x54>
80104f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f1d:	89 c2                	mov    %eax,%edx
80104f1f:	8b 45 10             	mov    0x10(%ebp),%eax
80104f22:	01 c2                	add    %eax,%edx
80104f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f27:	8b 00                	mov    (%eax),%eax
80104f29:	39 c2                	cmp    %eax,%edx
80104f2b:	76 07                	jbe    80104f34 <argptr+0x5b>
    return -1;
80104f2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f32:	eb 0f                	jmp    80104f43 <argptr+0x6a>
  *pp = (char*)i;
80104f34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f37:	89 c2                	mov    %eax,%edx
80104f39:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f3c:	89 10                	mov    %edx,(%eax)
  return 0;
80104f3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f43:	c9                   	leave  
80104f44:	c3                   	ret    

80104f45 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104f45:	f3 0f 1e fb          	endbr32 
80104f49:	55                   	push   %ebp
80104f4a:	89 e5                	mov    %esp,%ebp
80104f4c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104f4f:	83 ec 08             	sub    $0x8,%esp
80104f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f55:	50                   	push   %eax
80104f56:	ff 75 08             	pushl  0x8(%ebp)
80104f59:	e8 4a ff ff ff       	call   80104ea8 <argint>
80104f5e:	83 c4 10             	add    $0x10,%esp
80104f61:	85 c0                	test   %eax,%eax
80104f63:	79 07                	jns    80104f6c <argstr+0x27>
    return -1;
80104f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f6a:	eb 12                	jmp    80104f7e <argstr+0x39>
  return fetchstr(addr, pp);
80104f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6f:	83 ec 08             	sub    $0x8,%esp
80104f72:	ff 75 0c             	pushl  0xc(%ebp)
80104f75:	50                   	push   %eax
80104f76:	e8 c5 fe ff ff       	call   80104e40 <fetchstr>
80104f7b:	83 c4 10             	add    $0x10,%esp
}
80104f7e:	c9                   	leave  
80104f7f:	c3                   	ret    

80104f80 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80104f80:	f3 0f 1e fb          	endbr32 
80104f84:	55                   	push   %ebp
80104f85:	89 e5                	mov    %esp,%ebp
80104f87:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104f8a:	e8 1a ec ff ff       	call   80103ba9 <myproc>
80104f8f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f95:	8b 40 18             	mov    0x18(%eax),%eax
80104f98:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104f9e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104fa2:	7e 2f                	jle    80104fd3 <syscall+0x53>
80104fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa7:	83 f8 15             	cmp    $0x15,%eax
80104faa:	77 27                	ja     80104fd3 <syscall+0x53>
80104fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104faf:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104fb6:	85 c0                	test   %eax,%eax
80104fb8:	74 19                	je     80104fd3 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80104fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fbd:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104fc4:	ff d0                	call   *%eax
80104fc6:	89 c2                	mov    %eax,%edx
80104fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcb:	8b 40 18             	mov    0x18(%eax),%eax
80104fce:	89 50 1c             	mov    %edx,0x1c(%eax)
80104fd1:	eb 2c                	jmp    80104fff <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd6:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdc:	8b 40 10             	mov    0x10(%eax),%eax
80104fdf:	ff 75 f0             	pushl  -0x10(%ebp)
80104fe2:	52                   	push   %edx
80104fe3:	50                   	push   %eax
80104fe4:	68 f8 a6 10 80       	push   $0x8010a6f8
80104fe9:	e8 1e b4 ff ff       	call   8010040c <cprintf>
80104fee:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff4:	8b 40 18             	mov    0x18(%eax),%eax
80104ff7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104ffe:	90                   	nop
80104fff:	90                   	nop
80105000:	c9                   	leave  
80105001:	c3                   	ret    

80105002 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105002:	f3 0f 1e fb          	endbr32 
80105006:	55                   	push   %ebp
80105007:	89 e5                	mov    %esp,%ebp
80105009:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010500c:	83 ec 08             	sub    $0x8,%esp
8010500f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105012:	50                   	push   %eax
80105013:	ff 75 08             	pushl  0x8(%ebp)
80105016:	e8 8d fe ff ff       	call   80104ea8 <argint>
8010501b:	83 c4 10             	add    $0x10,%esp
8010501e:	85 c0                	test   %eax,%eax
80105020:	79 07                	jns    80105029 <argfd+0x27>
    return -1;
80105022:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105027:	eb 4f                	jmp    80105078 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010502c:	85 c0                	test   %eax,%eax
8010502e:	78 20                	js     80105050 <argfd+0x4e>
80105030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105033:	83 f8 0f             	cmp    $0xf,%eax
80105036:	7f 18                	jg     80105050 <argfd+0x4e>
80105038:	e8 6c eb ff ff       	call   80103ba9 <myproc>
8010503d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105040:	83 c2 08             	add    $0x8,%edx
80105043:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105047:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010504a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010504e:	75 07                	jne    80105057 <argfd+0x55>
    return -1;
80105050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105055:	eb 21                	jmp    80105078 <argfd+0x76>
  if(pfd)
80105057:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010505b:	74 08                	je     80105065 <argfd+0x63>
    *pfd = fd;
8010505d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105060:	8b 45 0c             	mov    0xc(%ebp),%eax
80105063:	89 10                	mov    %edx,(%eax)
  if(pf)
80105065:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105069:	74 08                	je     80105073 <argfd+0x71>
    *pf = f;
8010506b:	8b 45 10             	mov    0x10(%ebp),%eax
8010506e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105071:	89 10                	mov    %edx,(%eax)
  return 0;
80105073:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105078:	c9                   	leave  
80105079:	c3                   	ret    

8010507a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010507a:	f3 0f 1e fb          	endbr32 
8010507e:	55                   	push   %ebp
8010507f:	89 e5                	mov    %esp,%ebp
80105081:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105084:	e8 20 eb ff ff       	call   80103ba9 <myproc>
80105089:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010508c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105093:	eb 2a                	jmp    801050bf <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105095:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010509b:	83 c2 08             	add    $0x8,%edx
8010509e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050a2:	85 c0                	test   %eax,%eax
801050a4:	75 15                	jne    801050bb <fdalloc+0x41>
      curproc->ofile[fd] = f;
801050a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050ac:	8d 4a 08             	lea    0x8(%edx),%ecx
801050af:	8b 55 08             	mov    0x8(%ebp),%edx
801050b2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801050b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b9:	eb 0f                	jmp    801050ca <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801050bb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050bf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801050c3:	7e d0                	jle    80105095 <fdalloc+0x1b>
    }
  }
  return -1;
801050c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050ca:	c9                   	leave  
801050cb:	c3                   	ret    

801050cc <sys_dup>:

int
sys_dup(void)
{
801050cc:	f3 0f 1e fb          	endbr32 
801050d0:	55                   	push   %ebp
801050d1:	89 e5                	mov    %esp,%ebp
801050d3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801050d6:	83 ec 04             	sub    $0x4,%esp
801050d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050dc:	50                   	push   %eax
801050dd:	6a 00                	push   $0x0
801050df:	6a 00                	push   $0x0
801050e1:	e8 1c ff ff ff       	call   80105002 <argfd>
801050e6:	83 c4 10             	add    $0x10,%esp
801050e9:	85 c0                	test   %eax,%eax
801050eb:	79 07                	jns    801050f4 <sys_dup+0x28>
    return -1;
801050ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050f2:	eb 31                	jmp    80105125 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801050f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f7:	83 ec 0c             	sub    $0xc,%esp
801050fa:	50                   	push   %eax
801050fb:	e8 7a ff ff ff       	call   8010507a <fdalloc>
80105100:	83 c4 10             	add    $0x10,%esp
80105103:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105106:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010510a:	79 07                	jns    80105113 <sys_dup+0x47>
    return -1;
8010510c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105111:	eb 12                	jmp    80105125 <sys_dup+0x59>
  filedup(f);
80105113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105116:	83 ec 0c             	sub    $0xc,%esp
80105119:	50                   	push   %eax
8010511a:	e8 75 bf ff ff       	call   80101094 <filedup>
8010511f:	83 c4 10             	add    $0x10,%esp
  return fd;
80105122:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105125:	c9                   	leave  
80105126:	c3                   	ret    

80105127 <sys_read>:

int
sys_read(void)
{
80105127:	f3 0f 1e fb          	endbr32 
8010512b:	55                   	push   %ebp
8010512c:	89 e5                	mov    %esp,%ebp
8010512e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105131:	83 ec 04             	sub    $0x4,%esp
80105134:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105137:	50                   	push   %eax
80105138:	6a 00                	push   $0x0
8010513a:	6a 00                	push   $0x0
8010513c:	e8 c1 fe ff ff       	call   80105002 <argfd>
80105141:	83 c4 10             	add    $0x10,%esp
80105144:	85 c0                	test   %eax,%eax
80105146:	78 2e                	js     80105176 <sys_read+0x4f>
80105148:	83 ec 08             	sub    $0x8,%esp
8010514b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010514e:	50                   	push   %eax
8010514f:	6a 02                	push   $0x2
80105151:	e8 52 fd ff ff       	call   80104ea8 <argint>
80105156:	83 c4 10             	add    $0x10,%esp
80105159:	85 c0                	test   %eax,%eax
8010515b:	78 19                	js     80105176 <sys_read+0x4f>
8010515d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105160:	83 ec 04             	sub    $0x4,%esp
80105163:	50                   	push   %eax
80105164:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105167:	50                   	push   %eax
80105168:	6a 01                	push   $0x1
8010516a:	e8 6a fd ff ff       	call   80104ed9 <argptr>
8010516f:	83 c4 10             	add    $0x10,%esp
80105172:	85 c0                	test   %eax,%eax
80105174:	79 07                	jns    8010517d <sys_read+0x56>
    return -1;
80105176:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517b:	eb 17                	jmp    80105194 <sys_read+0x6d>
  return fileread(f, p, n);
8010517d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105180:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105186:	83 ec 04             	sub    $0x4,%esp
80105189:	51                   	push   %ecx
8010518a:	52                   	push   %edx
8010518b:	50                   	push   %eax
8010518c:	e8 9f c0 ff ff       	call   80101230 <fileread>
80105191:	83 c4 10             	add    $0x10,%esp
}
80105194:	c9                   	leave  
80105195:	c3                   	ret    

80105196 <sys_write>:

int
sys_write(void)
{
80105196:	f3 0f 1e fb          	endbr32 
8010519a:	55                   	push   %ebp
8010519b:	89 e5                	mov    %esp,%ebp
8010519d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801051a0:	83 ec 04             	sub    $0x4,%esp
801051a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051a6:	50                   	push   %eax
801051a7:	6a 00                	push   $0x0
801051a9:	6a 00                	push   $0x0
801051ab:	e8 52 fe ff ff       	call   80105002 <argfd>
801051b0:	83 c4 10             	add    $0x10,%esp
801051b3:	85 c0                	test   %eax,%eax
801051b5:	78 2e                	js     801051e5 <sys_write+0x4f>
801051b7:	83 ec 08             	sub    $0x8,%esp
801051ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051bd:	50                   	push   %eax
801051be:	6a 02                	push   $0x2
801051c0:	e8 e3 fc ff ff       	call   80104ea8 <argint>
801051c5:	83 c4 10             	add    $0x10,%esp
801051c8:	85 c0                	test   %eax,%eax
801051ca:	78 19                	js     801051e5 <sys_write+0x4f>
801051cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051cf:	83 ec 04             	sub    $0x4,%esp
801051d2:	50                   	push   %eax
801051d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801051d6:	50                   	push   %eax
801051d7:	6a 01                	push   $0x1
801051d9:	e8 fb fc ff ff       	call   80104ed9 <argptr>
801051de:	83 c4 10             	add    $0x10,%esp
801051e1:	85 c0                	test   %eax,%eax
801051e3:	79 07                	jns    801051ec <sys_write+0x56>
    return -1;
801051e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ea:	eb 17                	jmp    80105203 <sys_write+0x6d>
  return filewrite(f, p, n);
801051ec:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801051ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f5:	83 ec 04             	sub    $0x4,%esp
801051f8:	51                   	push   %ecx
801051f9:	52                   	push   %edx
801051fa:	50                   	push   %eax
801051fb:	e8 ec c0 ff ff       	call   801012ec <filewrite>
80105200:	83 c4 10             	add    $0x10,%esp
}
80105203:	c9                   	leave  
80105204:	c3                   	ret    

80105205 <sys_close>:

int
sys_close(void)
{
80105205:	f3 0f 1e fb          	endbr32 
80105209:	55                   	push   %ebp
8010520a:	89 e5                	mov    %esp,%ebp
8010520c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010520f:	83 ec 04             	sub    $0x4,%esp
80105212:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105215:	50                   	push   %eax
80105216:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105219:	50                   	push   %eax
8010521a:	6a 00                	push   $0x0
8010521c:	e8 e1 fd ff ff       	call   80105002 <argfd>
80105221:	83 c4 10             	add    $0x10,%esp
80105224:	85 c0                	test   %eax,%eax
80105226:	79 07                	jns    8010522f <sys_close+0x2a>
    return -1;
80105228:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010522d:	eb 27                	jmp    80105256 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
8010522f:	e8 75 e9 ff ff       	call   80103ba9 <myproc>
80105234:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105237:	83 c2 08             	add    $0x8,%edx
8010523a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105241:	00 
  fileclose(f);
80105242:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105245:	83 ec 0c             	sub    $0xc,%esp
80105248:	50                   	push   %eax
80105249:	e8 9b be ff ff       	call   801010e9 <fileclose>
8010524e:	83 c4 10             	add    $0x10,%esp
  return 0;
80105251:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105256:	c9                   	leave  
80105257:	c3                   	ret    

80105258 <sys_fstat>:

int
sys_fstat(void)
{
80105258:	f3 0f 1e fb          	endbr32 
8010525c:	55                   	push   %ebp
8010525d:	89 e5                	mov    %esp,%ebp
8010525f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105262:	83 ec 04             	sub    $0x4,%esp
80105265:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105268:	50                   	push   %eax
80105269:	6a 00                	push   $0x0
8010526b:	6a 00                	push   $0x0
8010526d:	e8 90 fd ff ff       	call   80105002 <argfd>
80105272:	83 c4 10             	add    $0x10,%esp
80105275:	85 c0                	test   %eax,%eax
80105277:	78 17                	js     80105290 <sys_fstat+0x38>
80105279:	83 ec 04             	sub    $0x4,%esp
8010527c:	6a 14                	push   $0x14
8010527e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105281:	50                   	push   %eax
80105282:	6a 01                	push   $0x1
80105284:	e8 50 fc ff ff       	call   80104ed9 <argptr>
80105289:	83 c4 10             	add    $0x10,%esp
8010528c:	85 c0                	test   %eax,%eax
8010528e:	79 07                	jns    80105297 <sys_fstat+0x3f>
    return -1;
80105290:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105295:	eb 13                	jmp    801052aa <sys_fstat+0x52>
  return filestat(f, st);
80105297:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010529a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529d:	83 ec 08             	sub    $0x8,%esp
801052a0:	52                   	push   %edx
801052a1:	50                   	push   %eax
801052a2:	e8 2e bf ff ff       	call   801011d5 <filestat>
801052a7:	83 c4 10             	add    $0x10,%esp
}
801052aa:	c9                   	leave  
801052ab:	c3                   	ret    

801052ac <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801052ac:	f3 0f 1e fb          	endbr32 
801052b0:	55                   	push   %ebp
801052b1:	89 e5                	mov    %esp,%ebp
801052b3:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801052b6:	83 ec 08             	sub    $0x8,%esp
801052b9:	8d 45 d8             	lea    -0x28(%ebp),%eax
801052bc:	50                   	push   %eax
801052bd:	6a 00                	push   $0x0
801052bf:	e8 81 fc ff ff       	call   80104f45 <argstr>
801052c4:	83 c4 10             	add    $0x10,%esp
801052c7:	85 c0                	test   %eax,%eax
801052c9:	78 15                	js     801052e0 <sys_link+0x34>
801052cb:	83 ec 08             	sub    $0x8,%esp
801052ce:	8d 45 dc             	lea    -0x24(%ebp),%eax
801052d1:	50                   	push   %eax
801052d2:	6a 01                	push   $0x1
801052d4:	e8 6c fc ff ff       	call   80104f45 <argstr>
801052d9:	83 c4 10             	add    $0x10,%esp
801052dc:	85 c0                	test   %eax,%eax
801052de:	79 0a                	jns    801052ea <sys_link+0x3e>
    return -1;
801052e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e5:	e9 68 01 00 00       	jmp    80105452 <sys_link+0x1a6>

  begin_op();
801052ea:	e8 82 de ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
801052ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
801052f2:	83 ec 0c             	sub    $0xc,%esp
801052f5:	50                   	push   %eax
801052f6:	e8 ec d2 ff ff       	call   801025e7 <namei>
801052fb:	83 c4 10             	add    $0x10,%esp
801052fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105301:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105305:	75 0f                	jne    80105316 <sys_link+0x6a>
    end_op();
80105307:	e8 f5 de ff ff       	call   80103201 <end_op>
    return -1;
8010530c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105311:	e9 3c 01 00 00       	jmp    80105452 <sys_link+0x1a6>
  }

  ilock(ip);
80105316:	83 ec 0c             	sub    $0xc,%esp
80105319:	ff 75 f4             	pushl  -0xc(%ebp)
8010531c:	e8 5b c7 ff ff       	call   80101a7c <ilock>
80105321:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105324:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105327:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010532b:	66 83 f8 01          	cmp    $0x1,%ax
8010532f:	75 1d                	jne    8010534e <sys_link+0xa2>
    iunlockput(ip);
80105331:	83 ec 0c             	sub    $0xc,%esp
80105334:	ff 75 f4             	pushl  -0xc(%ebp)
80105337:	e8 7d c9 ff ff       	call   80101cb9 <iunlockput>
8010533c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010533f:	e8 bd de ff ff       	call   80103201 <end_op>
    return -1;
80105344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105349:	e9 04 01 00 00       	jmp    80105452 <sys_link+0x1a6>
  }

  ip->nlink++;
8010534e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105351:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105355:	83 c0 01             	add    $0x1,%eax
80105358:	89 c2                	mov    %eax,%edx
8010535a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010535d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105361:	83 ec 0c             	sub    $0xc,%esp
80105364:	ff 75 f4             	pushl  -0xc(%ebp)
80105367:	e8 27 c5 ff ff       	call   80101893 <iupdate>
8010536c:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010536f:	83 ec 0c             	sub    $0xc,%esp
80105372:	ff 75 f4             	pushl  -0xc(%ebp)
80105375:	e8 19 c8 ff ff       	call   80101b93 <iunlock>
8010537a:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010537d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105380:	83 ec 08             	sub    $0x8,%esp
80105383:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105386:	52                   	push   %edx
80105387:	50                   	push   %eax
80105388:	e8 7a d2 ff ff       	call   80102607 <nameiparent>
8010538d:	83 c4 10             	add    $0x10,%esp
80105390:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105393:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105397:	74 71                	je     8010540a <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105399:	83 ec 0c             	sub    $0xc,%esp
8010539c:	ff 75 f0             	pushl  -0x10(%ebp)
8010539f:	e8 d8 c6 ff ff       	call   80101a7c <ilock>
801053a4:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801053a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053aa:	8b 10                	mov    (%eax),%edx
801053ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053af:	8b 00                	mov    (%eax),%eax
801053b1:	39 c2                	cmp    %eax,%edx
801053b3:	75 1d                	jne    801053d2 <sys_link+0x126>
801053b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053b8:	8b 40 04             	mov    0x4(%eax),%eax
801053bb:	83 ec 04             	sub    $0x4,%esp
801053be:	50                   	push   %eax
801053bf:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801053c2:	50                   	push   %eax
801053c3:	ff 75 f0             	pushl  -0x10(%ebp)
801053c6:	e8 79 cf ff ff       	call   80102344 <dirlink>
801053cb:	83 c4 10             	add    $0x10,%esp
801053ce:	85 c0                	test   %eax,%eax
801053d0:	79 10                	jns    801053e2 <sys_link+0x136>
    iunlockput(dp);
801053d2:	83 ec 0c             	sub    $0xc,%esp
801053d5:	ff 75 f0             	pushl  -0x10(%ebp)
801053d8:	e8 dc c8 ff ff       	call   80101cb9 <iunlockput>
801053dd:	83 c4 10             	add    $0x10,%esp
    goto bad;
801053e0:	eb 29                	jmp    8010540b <sys_link+0x15f>
  }
  iunlockput(dp);
801053e2:	83 ec 0c             	sub    $0xc,%esp
801053e5:	ff 75 f0             	pushl  -0x10(%ebp)
801053e8:	e8 cc c8 ff ff       	call   80101cb9 <iunlockput>
801053ed:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801053f0:	83 ec 0c             	sub    $0xc,%esp
801053f3:	ff 75 f4             	pushl  -0xc(%ebp)
801053f6:	e8 ea c7 ff ff       	call   80101be5 <iput>
801053fb:	83 c4 10             	add    $0x10,%esp

  end_op();
801053fe:	e8 fe dd ff ff       	call   80103201 <end_op>

  return 0;
80105403:	b8 00 00 00 00       	mov    $0x0,%eax
80105408:	eb 48                	jmp    80105452 <sys_link+0x1a6>
    goto bad;
8010540a:	90                   	nop

bad:
  ilock(ip);
8010540b:	83 ec 0c             	sub    $0xc,%esp
8010540e:	ff 75 f4             	pushl  -0xc(%ebp)
80105411:	e8 66 c6 ff ff       	call   80101a7c <ilock>
80105416:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105420:	83 e8 01             	sub    $0x1,%eax
80105423:	89 c2                	mov    %eax,%edx
80105425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105428:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010542c:	83 ec 0c             	sub    $0xc,%esp
8010542f:	ff 75 f4             	pushl  -0xc(%ebp)
80105432:	e8 5c c4 ff ff       	call   80101893 <iupdate>
80105437:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010543a:	83 ec 0c             	sub    $0xc,%esp
8010543d:	ff 75 f4             	pushl  -0xc(%ebp)
80105440:	e8 74 c8 ff ff       	call   80101cb9 <iunlockput>
80105445:	83 c4 10             	add    $0x10,%esp
  end_op();
80105448:	e8 b4 dd ff ff       	call   80103201 <end_op>
  return -1;
8010544d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105452:	c9                   	leave  
80105453:	c3                   	ret    

80105454 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105454:	f3 0f 1e fb          	endbr32 
80105458:	55                   	push   %ebp
80105459:	89 e5                	mov    %esp,%ebp
8010545b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010545e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105465:	eb 40                	jmp    801054a7 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010546a:	6a 10                	push   $0x10
8010546c:	50                   	push   %eax
8010546d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105470:	50                   	push   %eax
80105471:	ff 75 08             	pushl  0x8(%ebp)
80105474:	e8 0b cb ff ff       	call   80101f84 <readi>
80105479:	83 c4 10             	add    $0x10,%esp
8010547c:	83 f8 10             	cmp    $0x10,%eax
8010547f:	74 0d                	je     8010548e <isdirempty+0x3a>
      panic("isdirempty: readi");
80105481:	83 ec 0c             	sub    $0xc,%esp
80105484:	68 14 a7 10 80       	push   $0x8010a714
80105489:	e8 37 b1 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
8010548e:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105492:	66 85 c0             	test   %ax,%ax
80105495:	74 07                	je     8010549e <isdirempty+0x4a>
      return 0;
80105497:	b8 00 00 00 00       	mov    $0x0,%eax
8010549c:	eb 1b                	jmp    801054b9 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010549e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054a1:	83 c0 10             	add    $0x10,%eax
801054a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054a7:	8b 45 08             	mov    0x8(%ebp),%eax
801054aa:	8b 50 58             	mov    0x58(%eax),%edx
801054ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b0:	39 c2                	cmp    %eax,%edx
801054b2:	77 b3                	ja     80105467 <isdirempty+0x13>
  }
  return 1;
801054b4:	b8 01 00 00 00       	mov    $0x1,%eax
}
801054b9:	c9                   	leave  
801054ba:	c3                   	ret    

801054bb <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801054bb:	f3 0f 1e fb          	endbr32 
801054bf:	55                   	push   %ebp
801054c0:	89 e5                	mov    %esp,%ebp
801054c2:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801054c5:	83 ec 08             	sub    $0x8,%esp
801054c8:	8d 45 cc             	lea    -0x34(%ebp),%eax
801054cb:	50                   	push   %eax
801054cc:	6a 00                	push   $0x0
801054ce:	e8 72 fa ff ff       	call   80104f45 <argstr>
801054d3:	83 c4 10             	add    $0x10,%esp
801054d6:	85 c0                	test   %eax,%eax
801054d8:	79 0a                	jns    801054e4 <sys_unlink+0x29>
    return -1;
801054da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054df:	e9 bf 01 00 00       	jmp    801056a3 <sys_unlink+0x1e8>

  begin_op();
801054e4:	e8 88 dc ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801054e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801054ec:	83 ec 08             	sub    $0x8,%esp
801054ef:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801054f2:	52                   	push   %edx
801054f3:	50                   	push   %eax
801054f4:	e8 0e d1 ff ff       	call   80102607 <nameiparent>
801054f9:	83 c4 10             	add    $0x10,%esp
801054fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105503:	75 0f                	jne    80105514 <sys_unlink+0x59>
    end_op();
80105505:	e8 f7 dc ff ff       	call   80103201 <end_op>
    return -1;
8010550a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010550f:	e9 8f 01 00 00       	jmp    801056a3 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105514:	83 ec 0c             	sub    $0xc,%esp
80105517:	ff 75 f4             	pushl  -0xc(%ebp)
8010551a:	e8 5d c5 ff ff       	call   80101a7c <ilock>
8010551f:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105522:	83 ec 08             	sub    $0x8,%esp
80105525:	68 26 a7 10 80       	push   $0x8010a726
8010552a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010552d:	50                   	push   %eax
8010552e:	e8 34 cd ff ff       	call   80102267 <namecmp>
80105533:	83 c4 10             	add    $0x10,%esp
80105536:	85 c0                	test   %eax,%eax
80105538:	0f 84 49 01 00 00    	je     80105687 <sys_unlink+0x1cc>
8010553e:	83 ec 08             	sub    $0x8,%esp
80105541:	68 28 a7 10 80       	push   $0x8010a728
80105546:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105549:	50                   	push   %eax
8010554a:	e8 18 cd ff ff       	call   80102267 <namecmp>
8010554f:	83 c4 10             	add    $0x10,%esp
80105552:	85 c0                	test   %eax,%eax
80105554:	0f 84 2d 01 00 00    	je     80105687 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010555a:	83 ec 04             	sub    $0x4,%esp
8010555d:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105560:	50                   	push   %eax
80105561:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105564:	50                   	push   %eax
80105565:	ff 75 f4             	pushl  -0xc(%ebp)
80105568:	e8 19 cd ff ff       	call   80102286 <dirlookup>
8010556d:	83 c4 10             	add    $0x10,%esp
80105570:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105573:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105577:	0f 84 0d 01 00 00    	je     8010568a <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
8010557d:	83 ec 0c             	sub    $0xc,%esp
80105580:	ff 75 f0             	pushl  -0x10(%ebp)
80105583:	e8 f4 c4 ff ff       	call   80101a7c <ilock>
80105588:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010558b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010558e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105592:	66 85 c0             	test   %ax,%ax
80105595:	7f 0d                	jg     801055a4 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105597:	83 ec 0c             	sub    $0xc,%esp
8010559a:	68 2b a7 10 80       	push   $0x8010a72b
8010559f:	e8 21 b0 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801055a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055ab:	66 83 f8 01          	cmp    $0x1,%ax
801055af:	75 25                	jne    801055d6 <sys_unlink+0x11b>
801055b1:	83 ec 0c             	sub    $0xc,%esp
801055b4:	ff 75 f0             	pushl  -0x10(%ebp)
801055b7:	e8 98 fe ff ff       	call   80105454 <isdirempty>
801055bc:	83 c4 10             	add    $0x10,%esp
801055bf:	85 c0                	test   %eax,%eax
801055c1:	75 13                	jne    801055d6 <sys_unlink+0x11b>
    iunlockput(ip);
801055c3:	83 ec 0c             	sub    $0xc,%esp
801055c6:	ff 75 f0             	pushl  -0x10(%ebp)
801055c9:	e8 eb c6 ff ff       	call   80101cb9 <iunlockput>
801055ce:	83 c4 10             	add    $0x10,%esp
    goto bad;
801055d1:	e9 b5 00 00 00       	jmp    8010568b <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
801055d6:	83 ec 04             	sub    $0x4,%esp
801055d9:	6a 10                	push   $0x10
801055db:	6a 00                	push   $0x0
801055dd:	8d 45 e0             	lea    -0x20(%ebp),%eax
801055e0:	50                   	push   %eax
801055e1:	e8 6e f5 ff ff       	call   80104b54 <memset>
801055e6:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801055e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
801055ec:	6a 10                	push   $0x10
801055ee:	50                   	push   %eax
801055ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
801055f2:	50                   	push   %eax
801055f3:	ff 75 f4             	pushl  -0xc(%ebp)
801055f6:	e8 e2 ca ff ff       	call   801020dd <writei>
801055fb:	83 c4 10             	add    $0x10,%esp
801055fe:	83 f8 10             	cmp    $0x10,%eax
80105601:	74 0d                	je     80105610 <sys_unlink+0x155>
    panic("unlink: writei");
80105603:	83 ec 0c             	sub    $0xc,%esp
80105606:	68 3d a7 10 80       	push   $0x8010a73d
8010560b:	e8 b5 af ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105613:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105617:	66 83 f8 01          	cmp    $0x1,%ax
8010561b:	75 21                	jne    8010563e <sys_unlink+0x183>
    dp->nlink--;
8010561d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105620:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105624:	83 e8 01             	sub    $0x1,%eax
80105627:	89 c2                	mov    %eax,%edx
80105629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562c:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105630:	83 ec 0c             	sub    $0xc,%esp
80105633:	ff 75 f4             	pushl  -0xc(%ebp)
80105636:	e8 58 c2 ff ff       	call   80101893 <iupdate>
8010563b:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010563e:	83 ec 0c             	sub    $0xc,%esp
80105641:	ff 75 f4             	pushl  -0xc(%ebp)
80105644:	e8 70 c6 ff ff       	call   80101cb9 <iunlockput>
80105649:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010564c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105653:	83 e8 01             	sub    $0x1,%eax
80105656:	89 c2                	mov    %eax,%edx
80105658:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010565b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010565f:	83 ec 0c             	sub    $0xc,%esp
80105662:	ff 75 f0             	pushl  -0x10(%ebp)
80105665:	e8 29 c2 ff ff       	call   80101893 <iupdate>
8010566a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010566d:	83 ec 0c             	sub    $0xc,%esp
80105670:	ff 75 f0             	pushl  -0x10(%ebp)
80105673:	e8 41 c6 ff ff       	call   80101cb9 <iunlockput>
80105678:	83 c4 10             	add    $0x10,%esp

  end_op();
8010567b:	e8 81 db ff ff       	call   80103201 <end_op>

  return 0;
80105680:	b8 00 00 00 00       	mov    $0x0,%eax
80105685:	eb 1c                	jmp    801056a3 <sys_unlink+0x1e8>
    goto bad;
80105687:	90                   	nop
80105688:	eb 01                	jmp    8010568b <sys_unlink+0x1d0>
    goto bad;
8010568a:	90                   	nop

bad:
  iunlockput(dp);
8010568b:	83 ec 0c             	sub    $0xc,%esp
8010568e:	ff 75 f4             	pushl  -0xc(%ebp)
80105691:	e8 23 c6 ff ff       	call   80101cb9 <iunlockput>
80105696:	83 c4 10             	add    $0x10,%esp
  end_op();
80105699:	e8 63 db ff ff       	call   80103201 <end_op>
  return -1;
8010569e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056a3:	c9                   	leave  
801056a4:	c3                   	ret    

801056a5 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801056a5:	f3 0f 1e fb          	endbr32 
801056a9:	55                   	push   %ebp
801056aa:	89 e5                	mov    %esp,%ebp
801056ac:	83 ec 38             	sub    $0x38,%esp
801056af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801056b2:	8b 55 10             	mov    0x10(%ebp),%edx
801056b5:	8b 45 14             	mov    0x14(%ebp),%eax
801056b8:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801056bc:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801056c0:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801056c4:	83 ec 08             	sub    $0x8,%esp
801056c7:	8d 45 de             	lea    -0x22(%ebp),%eax
801056ca:	50                   	push   %eax
801056cb:	ff 75 08             	pushl  0x8(%ebp)
801056ce:	e8 34 cf ff ff       	call   80102607 <nameiparent>
801056d3:	83 c4 10             	add    $0x10,%esp
801056d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056dd:	75 0a                	jne    801056e9 <create+0x44>
    return 0;
801056df:	b8 00 00 00 00       	mov    $0x0,%eax
801056e4:	e9 90 01 00 00       	jmp    80105879 <create+0x1d4>
  ilock(dp);
801056e9:	83 ec 0c             	sub    $0xc,%esp
801056ec:	ff 75 f4             	pushl  -0xc(%ebp)
801056ef:	e8 88 c3 ff ff       	call   80101a7c <ilock>
801056f4:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801056f7:	83 ec 04             	sub    $0x4,%esp
801056fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056fd:	50                   	push   %eax
801056fe:	8d 45 de             	lea    -0x22(%ebp),%eax
80105701:	50                   	push   %eax
80105702:	ff 75 f4             	pushl  -0xc(%ebp)
80105705:	e8 7c cb ff ff       	call   80102286 <dirlookup>
8010570a:	83 c4 10             	add    $0x10,%esp
8010570d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105710:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105714:	74 50                	je     80105766 <create+0xc1>
    iunlockput(dp);
80105716:	83 ec 0c             	sub    $0xc,%esp
80105719:	ff 75 f4             	pushl  -0xc(%ebp)
8010571c:	e8 98 c5 ff ff       	call   80101cb9 <iunlockput>
80105721:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105724:	83 ec 0c             	sub    $0xc,%esp
80105727:	ff 75 f0             	pushl  -0x10(%ebp)
8010572a:	e8 4d c3 ff ff       	call   80101a7c <ilock>
8010572f:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105732:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105737:	75 15                	jne    8010574e <create+0xa9>
80105739:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010573c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105740:	66 83 f8 02          	cmp    $0x2,%ax
80105744:	75 08                	jne    8010574e <create+0xa9>
      return ip;
80105746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105749:	e9 2b 01 00 00       	jmp    80105879 <create+0x1d4>
    iunlockput(ip);
8010574e:	83 ec 0c             	sub    $0xc,%esp
80105751:	ff 75 f0             	pushl  -0x10(%ebp)
80105754:	e8 60 c5 ff ff       	call   80101cb9 <iunlockput>
80105759:	83 c4 10             	add    $0x10,%esp
    return 0;
8010575c:	b8 00 00 00 00       	mov    $0x0,%eax
80105761:	e9 13 01 00 00       	jmp    80105879 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105766:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010576a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576d:	8b 00                	mov    (%eax),%eax
8010576f:	83 ec 08             	sub    $0x8,%esp
80105772:	52                   	push   %edx
80105773:	50                   	push   %eax
80105774:	e8 3f c0 ff ff       	call   801017b8 <ialloc>
80105779:	83 c4 10             	add    $0x10,%esp
8010577c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010577f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105783:	75 0d                	jne    80105792 <create+0xed>
    panic("create: ialloc");
80105785:	83 ec 0c             	sub    $0xc,%esp
80105788:	68 4c a7 10 80       	push   $0x8010a74c
8010578d:	e8 33 ae ff ff       	call   801005c5 <panic>

  ilock(ip);
80105792:	83 ec 0c             	sub    $0xc,%esp
80105795:	ff 75 f0             	pushl  -0x10(%ebp)
80105798:	e8 df c2 ff ff       	call   80101a7c <ilock>
8010579d:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801057a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a3:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801057a7:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801057ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ae:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801057b2:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801057b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b9:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801057bf:	83 ec 0c             	sub    $0xc,%esp
801057c2:	ff 75 f0             	pushl  -0x10(%ebp)
801057c5:	e8 c9 c0 ff ff       	call   80101893 <iupdate>
801057ca:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801057cd:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801057d2:	75 6a                	jne    8010583e <create+0x199>
    dp->nlink++;  // for ".."
801057d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057db:	83 c0 01             	add    $0x1,%eax
801057de:	89 c2                	mov    %eax,%edx
801057e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e3:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801057e7:	83 ec 0c             	sub    $0xc,%esp
801057ea:	ff 75 f4             	pushl  -0xc(%ebp)
801057ed:	e8 a1 c0 ff ff       	call   80101893 <iupdate>
801057f2:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801057f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f8:	8b 40 04             	mov    0x4(%eax),%eax
801057fb:	83 ec 04             	sub    $0x4,%esp
801057fe:	50                   	push   %eax
801057ff:	68 26 a7 10 80       	push   $0x8010a726
80105804:	ff 75 f0             	pushl  -0x10(%ebp)
80105807:	e8 38 cb ff ff       	call   80102344 <dirlink>
8010580c:	83 c4 10             	add    $0x10,%esp
8010580f:	85 c0                	test   %eax,%eax
80105811:	78 1e                	js     80105831 <create+0x18c>
80105813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105816:	8b 40 04             	mov    0x4(%eax),%eax
80105819:	83 ec 04             	sub    $0x4,%esp
8010581c:	50                   	push   %eax
8010581d:	68 28 a7 10 80       	push   $0x8010a728
80105822:	ff 75 f0             	pushl  -0x10(%ebp)
80105825:	e8 1a cb ff ff       	call   80102344 <dirlink>
8010582a:	83 c4 10             	add    $0x10,%esp
8010582d:	85 c0                	test   %eax,%eax
8010582f:	79 0d                	jns    8010583e <create+0x199>
      panic("create dots");
80105831:	83 ec 0c             	sub    $0xc,%esp
80105834:	68 5b a7 10 80       	push   $0x8010a75b
80105839:	e8 87 ad ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010583e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105841:	8b 40 04             	mov    0x4(%eax),%eax
80105844:	83 ec 04             	sub    $0x4,%esp
80105847:	50                   	push   %eax
80105848:	8d 45 de             	lea    -0x22(%ebp),%eax
8010584b:	50                   	push   %eax
8010584c:	ff 75 f4             	pushl  -0xc(%ebp)
8010584f:	e8 f0 ca ff ff       	call   80102344 <dirlink>
80105854:	83 c4 10             	add    $0x10,%esp
80105857:	85 c0                	test   %eax,%eax
80105859:	79 0d                	jns    80105868 <create+0x1c3>
    panic("create: dirlink");
8010585b:	83 ec 0c             	sub    $0xc,%esp
8010585e:	68 67 a7 10 80       	push   $0x8010a767
80105863:	e8 5d ad ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105868:	83 ec 0c             	sub    $0xc,%esp
8010586b:	ff 75 f4             	pushl  -0xc(%ebp)
8010586e:	e8 46 c4 ff ff       	call   80101cb9 <iunlockput>
80105873:	83 c4 10             	add    $0x10,%esp

  return ip;
80105876:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105879:	c9                   	leave  
8010587a:	c3                   	ret    

8010587b <sys_open>:

int
sys_open(void)
{
8010587b:	f3 0f 1e fb          	endbr32 
8010587f:	55                   	push   %ebp
80105880:	89 e5                	mov    %esp,%ebp
80105882:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105885:	83 ec 08             	sub    $0x8,%esp
80105888:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010588b:	50                   	push   %eax
8010588c:	6a 00                	push   $0x0
8010588e:	e8 b2 f6 ff ff       	call   80104f45 <argstr>
80105893:	83 c4 10             	add    $0x10,%esp
80105896:	85 c0                	test   %eax,%eax
80105898:	78 15                	js     801058af <sys_open+0x34>
8010589a:	83 ec 08             	sub    $0x8,%esp
8010589d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058a0:	50                   	push   %eax
801058a1:	6a 01                	push   $0x1
801058a3:	e8 00 f6 ff ff       	call   80104ea8 <argint>
801058a8:	83 c4 10             	add    $0x10,%esp
801058ab:	85 c0                	test   %eax,%eax
801058ad:	79 0a                	jns    801058b9 <sys_open+0x3e>
    return -1;
801058af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b4:	e9 61 01 00 00       	jmp    80105a1a <sys_open+0x19f>

  begin_op();
801058b9:	e8 b3 d8 ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
801058be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801058c1:	25 00 02 00 00       	and    $0x200,%eax
801058c6:	85 c0                	test   %eax,%eax
801058c8:	74 2a                	je     801058f4 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801058ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058cd:	6a 00                	push   $0x0
801058cf:	6a 00                	push   $0x0
801058d1:	6a 02                	push   $0x2
801058d3:	50                   	push   %eax
801058d4:	e8 cc fd ff ff       	call   801056a5 <create>
801058d9:	83 c4 10             	add    $0x10,%esp
801058dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801058df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058e3:	75 75                	jne    8010595a <sys_open+0xdf>
      end_op();
801058e5:	e8 17 d9 ff ff       	call   80103201 <end_op>
      return -1;
801058ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ef:	e9 26 01 00 00       	jmp    80105a1a <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801058f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058f7:	83 ec 0c             	sub    $0xc,%esp
801058fa:	50                   	push   %eax
801058fb:	e8 e7 cc ff ff       	call   801025e7 <namei>
80105900:	83 c4 10             	add    $0x10,%esp
80105903:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105906:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010590a:	75 0f                	jne    8010591b <sys_open+0xa0>
      end_op();
8010590c:	e8 f0 d8 ff ff       	call   80103201 <end_op>
      return -1;
80105911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105916:	e9 ff 00 00 00       	jmp    80105a1a <sys_open+0x19f>
    }
    ilock(ip);
8010591b:	83 ec 0c             	sub    $0xc,%esp
8010591e:	ff 75 f4             	pushl  -0xc(%ebp)
80105921:	e8 56 c1 ff ff       	call   80101a7c <ilock>
80105926:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105930:	66 83 f8 01          	cmp    $0x1,%ax
80105934:	75 24                	jne    8010595a <sys_open+0xdf>
80105936:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105939:	85 c0                	test   %eax,%eax
8010593b:	74 1d                	je     8010595a <sys_open+0xdf>
      iunlockput(ip);
8010593d:	83 ec 0c             	sub    $0xc,%esp
80105940:	ff 75 f4             	pushl  -0xc(%ebp)
80105943:	e8 71 c3 ff ff       	call   80101cb9 <iunlockput>
80105948:	83 c4 10             	add    $0x10,%esp
      end_op();
8010594b:	e8 b1 d8 ff ff       	call   80103201 <end_op>
      return -1;
80105950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105955:	e9 c0 00 00 00       	jmp    80105a1a <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010595a:	e8 c4 b6 ff ff       	call   80101023 <filealloc>
8010595f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105962:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105966:	74 17                	je     8010597f <sys_open+0x104>
80105968:	83 ec 0c             	sub    $0xc,%esp
8010596b:	ff 75 f0             	pushl  -0x10(%ebp)
8010596e:	e8 07 f7 ff ff       	call   8010507a <fdalloc>
80105973:	83 c4 10             	add    $0x10,%esp
80105976:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105979:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010597d:	79 2e                	jns    801059ad <sys_open+0x132>
    if(f)
8010597f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105983:	74 0e                	je     80105993 <sys_open+0x118>
      fileclose(f);
80105985:	83 ec 0c             	sub    $0xc,%esp
80105988:	ff 75 f0             	pushl  -0x10(%ebp)
8010598b:	e8 59 b7 ff ff       	call   801010e9 <fileclose>
80105990:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105993:	83 ec 0c             	sub    $0xc,%esp
80105996:	ff 75 f4             	pushl  -0xc(%ebp)
80105999:	e8 1b c3 ff ff       	call   80101cb9 <iunlockput>
8010599e:	83 c4 10             	add    $0x10,%esp
    end_op();
801059a1:	e8 5b d8 ff ff       	call   80103201 <end_op>
    return -1;
801059a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ab:	eb 6d                	jmp    80105a1a <sys_open+0x19f>
  }
  iunlock(ip);
801059ad:	83 ec 0c             	sub    $0xc,%esp
801059b0:	ff 75 f4             	pushl  -0xc(%ebp)
801059b3:	e8 db c1 ff ff       	call   80101b93 <iunlock>
801059b8:	83 c4 10             	add    $0x10,%esp
  end_op();
801059bb:	e8 41 d8 ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
801059c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059c3:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801059c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059cf:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801059d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801059dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059df:	83 e0 01             	and    $0x1,%eax
801059e2:	85 c0                	test   %eax,%eax
801059e4:	0f 94 c0             	sete   %al
801059e7:	89 c2                	mov    %eax,%edx
801059e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ec:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801059ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059f2:	83 e0 01             	and    $0x1,%eax
801059f5:	85 c0                	test   %eax,%eax
801059f7:	75 0a                	jne    80105a03 <sys_open+0x188>
801059f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801059fc:	83 e0 02             	and    $0x2,%eax
801059ff:	85 c0                	test   %eax,%eax
80105a01:	74 07                	je     80105a0a <sys_open+0x18f>
80105a03:	b8 01 00 00 00       	mov    $0x1,%eax
80105a08:	eb 05                	jmp    80105a0f <sys_open+0x194>
80105a0a:	b8 00 00 00 00       	mov    $0x0,%eax
80105a0f:	89 c2                	mov    %eax,%edx
80105a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a14:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105a1a:	c9                   	leave  
80105a1b:	c3                   	ret    

80105a1c <sys_mkdir>:

int
sys_mkdir(void)
{
80105a1c:	f3 0f 1e fb          	endbr32 
80105a20:	55                   	push   %ebp
80105a21:	89 e5                	mov    %esp,%ebp
80105a23:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105a26:	e8 46 d7 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105a2b:	83 ec 08             	sub    $0x8,%esp
80105a2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a31:	50                   	push   %eax
80105a32:	6a 00                	push   $0x0
80105a34:	e8 0c f5 ff ff       	call   80104f45 <argstr>
80105a39:	83 c4 10             	add    $0x10,%esp
80105a3c:	85 c0                	test   %eax,%eax
80105a3e:	78 1b                	js     80105a5b <sys_mkdir+0x3f>
80105a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a43:	6a 00                	push   $0x0
80105a45:	6a 00                	push   $0x0
80105a47:	6a 01                	push   $0x1
80105a49:	50                   	push   %eax
80105a4a:	e8 56 fc ff ff       	call   801056a5 <create>
80105a4f:	83 c4 10             	add    $0x10,%esp
80105a52:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a59:	75 0c                	jne    80105a67 <sys_mkdir+0x4b>
    end_op();
80105a5b:	e8 a1 d7 ff ff       	call   80103201 <end_op>
    return -1;
80105a60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a65:	eb 18                	jmp    80105a7f <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105a67:	83 ec 0c             	sub    $0xc,%esp
80105a6a:	ff 75 f4             	pushl  -0xc(%ebp)
80105a6d:	e8 47 c2 ff ff       	call   80101cb9 <iunlockput>
80105a72:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a75:	e8 87 d7 ff ff       	call   80103201 <end_op>
  return 0;
80105a7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a7f:	c9                   	leave  
80105a80:	c3                   	ret    

80105a81 <sys_mknod>:

int
sys_mknod(void)
{
80105a81:	f3 0f 1e fb          	endbr32 
80105a85:	55                   	push   %ebp
80105a86:	89 e5                	mov    %esp,%ebp
80105a88:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105a8b:	e8 e1 d6 ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105a90:	83 ec 08             	sub    $0x8,%esp
80105a93:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a96:	50                   	push   %eax
80105a97:	6a 00                	push   $0x0
80105a99:	e8 a7 f4 ff ff       	call   80104f45 <argstr>
80105a9e:	83 c4 10             	add    $0x10,%esp
80105aa1:	85 c0                	test   %eax,%eax
80105aa3:	78 4f                	js     80105af4 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105aa5:	83 ec 08             	sub    $0x8,%esp
80105aa8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aab:	50                   	push   %eax
80105aac:	6a 01                	push   $0x1
80105aae:	e8 f5 f3 ff ff       	call   80104ea8 <argint>
80105ab3:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105ab6:	85 c0                	test   %eax,%eax
80105ab8:	78 3a                	js     80105af4 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105aba:	83 ec 08             	sub    $0x8,%esp
80105abd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ac0:	50                   	push   %eax
80105ac1:	6a 02                	push   $0x2
80105ac3:	e8 e0 f3 ff ff       	call   80104ea8 <argint>
80105ac8:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105acb:	85 c0                	test   %eax,%eax
80105acd:	78 25                	js     80105af4 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105acf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ad2:	0f bf c8             	movswl %ax,%ecx
80105ad5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ad8:	0f bf d0             	movswl %ax,%edx
80105adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ade:	51                   	push   %ecx
80105adf:	52                   	push   %edx
80105ae0:	6a 03                	push   $0x3
80105ae2:	50                   	push   %eax
80105ae3:	e8 bd fb ff ff       	call   801056a5 <create>
80105ae8:	83 c4 10             	add    $0x10,%esp
80105aeb:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105aee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af2:	75 0c                	jne    80105b00 <sys_mknod+0x7f>
    end_op();
80105af4:	e8 08 d7 ff ff       	call   80103201 <end_op>
    return -1;
80105af9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105afe:	eb 18                	jmp    80105b18 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105b00:	83 ec 0c             	sub    $0xc,%esp
80105b03:	ff 75 f4             	pushl  -0xc(%ebp)
80105b06:	e8 ae c1 ff ff       	call   80101cb9 <iunlockput>
80105b0b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b0e:	e8 ee d6 ff ff       	call   80103201 <end_op>
  return 0;
80105b13:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b18:	c9                   	leave  
80105b19:	c3                   	ret    

80105b1a <sys_chdir>:

int
sys_chdir(void)
{
80105b1a:	f3 0f 1e fb          	endbr32 
80105b1e:	55                   	push   %ebp
80105b1f:	89 e5                	mov    %esp,%ebp
80105b21:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105b24:	e8 80 e0 ff ff       	call   80103ba9 <myproc>
80105b29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105b2c:	e8 40 d6 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105b31:	83 ec 08             	sub    $0x8,%esp
80105b34:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b37:	50                   	push   %eax
80105b38:	6a 00                	push   $0x0
80105b3a:	e8 06 f4 ff ff       	call   80104f45 <argstr>
80105b3f:	83 c4 10             	add    $0x10,%esp
80105b42:	85 c0                	test   %eax,%eax
80105b44:	78 18                	js     80105b5e <sys_chdir+0x44>
80105b46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b49:	83 ec 0c             	sub    $0xc,%esp
80105b4c:	50                   	push   %eax
80105b4d:	e8 95 ca ff ff       	call   801025e7 <namei>
80105b52:	83 c4 10             	add    $0x10,%esp
80105b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b5c:	75 0c                	jne    80105b6a <sys_chdir+0x50>
    end_op();
80105b5e:	e8 9e d6 ff ff       	call   80103201 <end_op>
    return -1;
80105b63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b68:	eb 68                	jmp    80105bd2 <sys_chdir+0xb8>
  }
  ilock(ip);
80105b6a:	83 ec 0c             	sub    $0xc,%esp
80105b6d:	ff 75 f0             	pushl  -0x10(%ebp)
80105b70:	e8 07 bf ff ff       	call   80101a7c <ilock>
80105b75:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b7f:	66 83 f8 01          	cmp    $0x1,%ax
80105b83:	74 1a                	je     80105b9f <sys_chdir+0x85>
    iunlockput(ip);
80105b85:	83 ec 0c             	sub    $0xc,%esp
80105b88:	ff 75 f0             	pushl  -0x10(%ebp)
80105b8b:	e8 29 c1 ff ff       	call   80101cb9 <iunlockput>
80105b90:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b93:	e8 69 d6 ff ff       	call   80103201 <end_op>
    return -1;
80105b98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9d:	eb 33                	jmp    80105bd2 <sys_chdir+0xb8>
  }
  iunlock(ip);
80105b9f:	83 ec 0c             	sub    $0xc,%esp
80105ba2:	ff 75 f0             	pushl  -0x10(%ebp)
80105ba5:	e8 e9 bf ff ff       	call   80101b93 <iunlock>
80105baa:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb0:	8b 40 68             	mov    0x68(%eax),%eax
80105bb3:	83 ec 0c             	sub    $0xc,%esp
80105bb6:	50                   	push   %eax
80105bb7:	e8 29 c0 ff ff       	call   80101be5 <iput>
80105bbc:	83 c4 10             	add    $0x10,%esp
  end_op();
80105bbf:	e8 3d d6 ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
80105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105bca:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bd2:	c9                   	leave  
80105bd3:	c3                   	ret    

80105bd4 <sys_exec>:

int
sys_exec(void)
{
80105bd4:	f3 0f 1e fb          	endbr32 
80105bd8:	55                   	push   %ebp
80105bd9:	89 e5                	mov    %esp,%ebp
80105bdb:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105be1:	83 ec 08             	sub    $0x8,%esp
80105be4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be7:	50                   	push   %eax
80105be8:	6a 00                	push   $0x0
80105bea:	e8 56 f3 ff ff       	call   80104f45 <argstr>
80105bef:	83 c4 10             	add    $0x10,%esp
80105bf2:	85 c0                	test   %eax,%eax
80105bf4:	78 18                	js     80105c0e <sys_exec+0x3a>
80105bf6:	83 ec 08             	sub    $0x8,%esp
80105bf9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105bff:	50                   	push   %eax
80105c00:	6a 01                	push   $0x1
80105c02:	e8 a1 f2 ff ff       	call   80104ea8 <argint>
80105c07:	83 c4 10             	add    $0x10,%esp
80105c0a:	85 c0                	test   %eax,%eax
80105c0c:	79 0a                	jns    80105c18 <sys_exec+0x44>
    return -1;
80105c0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c13:	e9 c6 00 00 00       	jmp    80105cde <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105c18:	83 ec 04             	sub    $0x4,%esp
80105c1b:	68 80 00 00 00       	push   $0x80
80105c20:	6a 00                	push   $0x0
80105c22:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105c28:	50                   	push   %eax
80105c29:	e8 26 ef ff ff       	call   80104b54 <memset>
80105c2e:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105c31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3b:	83 f8 1f             	cmp    $0x1f,%eax
80105c3e:	76 0a                	jbe    80105c4a <sys_exec+0x76>
      return -1;
80105c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c45:	e9 94 00 00 00       	jmp    80105cde <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4d:	c1 e0 02             	shl    $0x2,%eax
80105c50:	89 c2                	mov    %eax,%edx
80105c52:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105c58:	01 c2                	add    %eax,%edx
80105c5a:	83 ec 08             	sub    $0x8,%esp
80105c5d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105c63:	50                   	push   %eax
80105c64:	52                   	push   %edx
80105c65:	e8 93 f1 ff ff       	call   80104dfd <fetchint>
80105c6a:	83 c4 10             	add    $0x10,%esp
80105c6d:	85 c0                	test   %eax,%eax
80105c6f:	79 07                	jns    80105c78 <sys_exec+0xa4>
      return -1;
80105c71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c76:	eb 66                	jmp    80105cde <sys_exec+0x10a>
    if(uarg == 0){
80105c78:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105c7e:	85 c0                	test   %eax,%eax
80105c80:	75 27                	jne    80105ca9 <sys_exec+0xd5>
      argv[i] = 0;
80105c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c85:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105c8c:	00 00 00 00 
      break;
80105c90:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c94:	83 ec 08             	sub    $0x8,%esp
80105c97:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105c9d:	52                   	push   %edx
80105c9e:	50                   	push   %eax
80105c9f:	e8 1a af ff ff       	call   80100bbe <exec>
80105ca4:	83 c4 10             	add    $0x10,%esp
80105ca7:	eb 35                	jmp    80105cde <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105ca9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105caf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cb2:	c1 e2 02             	shl    $0x2,%edx
80105cb5:	01 c2                	add    %eax,%edx
80105cb7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105cbd:	83 ec 08             	sub    $0x8,%esp
80105cc0:	52                   	push   %edx
80105cc1:	50                   	push   %eax
80105cc2:	e8 79 f1 ff ff       	call   80104e40 <fetchstr>
80105cc7:	83 c4 10             	add    $0x10,%esp
80105cca:	85 c0                	test   %eax,%eax
80105ccc:	79 07                	jns    80105cd5 <sys_exec+0x101>
      return -1;
80105cce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd3:	eb 09                	jmp    80105cde <sys_exec+0x10a>
  for(i=0;; i++){
80105cd5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105cd9:	e9 5a ff ff ff       	jmp    80105c38 <sys_exec+0x64>
}
80105cde:	c9                   	leave  
80105cdf:	c3                   	ret    

80105ce0 <sys_pipe>:

int
sys_pipe(void)
{
80105ce0:	f3 0f 1e fb          	endbr32 
80105ce4:	55                   	push   %ebp
80105ce5:	89 e5                	mov    %esp,%ebp
80105ce7:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105cea:	83 ec 04             	sub    $0x4,%esp
80105ced:	6a 08                	push   $0x8
80105cef:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cf2:	50                   	push   %eax
80105cf3:	6a 00                	push   $0x0
80105cf5:	e8 df f1 ff ff       	call   80104ed9 <argptr>
80105cfa:	83 c4 10             	add    $0x10,%esp
80105cfd:	85 c0                	test   %eax,%eax
80105cff:	79 0a                	jns    80105d0b <sys_pipe+0x2b>
    return -1;
80105d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d06:	e9 ae 00 00 00       	jmp    80105db9 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105d0b:	83 ec 08             	sub    $0x8,%esp
80105d0e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d11:	50                   	push   %eax
80105d12:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d15:	50                   	push   %eax
80105d16:	e8 af d9 ff ff       	call   801036ca <pipealloc>
80105d1b:	83 c4 10             	add    $0x10,%esp
80105d1e:	85 c0                	test   %eax,%eax
80105d20:	79 0a                	jns    80105d2c <sys_pipe+0x4c>
    return -1;
80105d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d27:	e9 8d 00 00 00       	jmp    80105db9 <sys_pipe+0xd9>
  fd0 = -1;
80105d2c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105d33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d36:	83 ec 0c             	sub    $0xc,%esp
80105d39:	50                   	push   %eax
80105d3a:	e8 3b f3 ff ff       	call   8010507a <fdalloc>
80105d3f:	83 c4 10             	add    $0x10,%esp
80105d42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d49:	78 18                	js     80105d63 <sys_pipe+0x83>
80105d4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d4e:	83 ec 0c             	sub    $0xc,%esp
80105d51:	50                   	push   %eax
80105d52:	e8 23 f3 ff ff       	call   8010507a <fdalloc>
80105d57:	83 c4 10             	add    $0x10,%esp
80105d5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d61:	79 3e                	jns    80105da1 <sys_pipe+0xc1>
    if(fd0 >= 0)
80105d63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d67:	78 13                	js     80105d7c <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105d69:	e8 3b de ff ff       	call   80103ba9 <myproc>
80105d6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d71:	83 c2 08             	add    $0x8,%edx
80105d74:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d7b:	00 
    fileclose(rf);
80105d7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d7f:	83 ec 0c             	sub    $0xc,%esp
80105d82:	50                   	push   %eax
80105d83:	e8 61 b3 ff ff       	call   801010e9 <fileclose>
80105d88:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105d8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d8e:	83 ec 0c             	sub    $0xc,%esp
80105d91:	50                   	push   %eax
80105d92:	e8 52 b3 ff ff       	call   801010e9 <fileclose>
80105d97:	83 c4 10             	add    $0x10,%esp
    return -1;
80105d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d9f:	eb 18                	jmp    80105db9 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80105da1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105da4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105da7:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105da9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105dac:	8d 50 04             	lea    0x4(%eax),%edx
80105daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105db2:	89 02                	mov    %eax,(%edx)
  return 0;
80105db4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105db9:	c9                   	leave  
80105dba:	c3                   	ret    

80105dbb <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105dbb:	f3 0f 1e fb          	endbr32 
80105dbf:	55                   	push   %ebp
80105dc0:	89 e5                	mov    %esp,%ebp
80105dc2:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105dc5:	e8 f2 e0 ff ff       	call   80103ebc <fork>
}
80105dca:	c9                   	leave  
80105dcb:	c3                   	ret    

80105dcc <sys_exit>:

int
sys_exit(void)
{
80105dcc:	f3 0f 1e fb          	endbr32 
80105dd0:	55                   	push   %ebp
80105dd1:	89 e5                	mov    %esp,%ebp
80105dd3:	83 ec 08             	sub    $0x8,%esp
  exit();
80105dd6:	e8 5e e2 ff ff       	call   80104039 <exit>
  return 0;  // not reached
80105ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105de0:	c9                   	leave  
80105de1:	c3                   	ret    

80105de2 <sys_wait>:

int
sys_wait(void)
{
80105de2:	f3 0f 1e fb          	endbr32 
80105de6:	55                   	push   %ebp
80105de7:	89 e5                	mov    %esp,%ebp
80105de9:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105dec:	e8 6c e3 ff ff       	call   8010415d <wait>
}
80105df1:	c9                   	leave  
80105df2:	c3                   	ret    

80105df3 <sys_kill>:

int
sys_kill(void)
{
80105df3:	f3 0f 1e fb          	endbr32 
80105df7:	55                   	push   %ebp
80105df8:	89 e5                	mov    %esp,%ebp
80105dfa:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105dfd:	83 ec 08             	sub    $0x8,%esp
80105e00:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e03:	50                   	push   %eax
80105e04:	6a 00                	push   $0x0
80105e06:	e8 9d f0 ff ff       	call   80104ea8 <argint>
80105e0b:	83 c4 10             	add    $0x10,%esp
80105e0e:	85 c0                	test   %eax,%eax
80105e10:	79 07                	jns    80105e19 <sys_kill+0x26>
    return -1;
80105e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e17:	eb 0f                	jmp    80105e28 <sys_kill+0x35>
  return kill(pid);
80105e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1c:	83 ec 0c             	sub    $0xc,%esp
80105e1f:	50                   	push   %eax
80105e20:	e8 87 e7 ff ff       	call   801045ac <kill>
80105e25:	83 c4 10             	add    $0x10,%esp
}
80105e28:	c9                   	leave  
80105e29:	c3                   	ret    

80105e2a <sys_getpid>:

int
sys_getpid(void)
{
80105e2a:	f3 0f 1e fb          	endbr32 
80105e2e:	55                   	push   %ebp
80105e2f:	89 e5                	mov    %esp,%ebp
80105e31:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105e34:	e8 70 dd ff ff       	call   80103ba9 <myproc>
80105e39:	8b 40 10             	mov    0x10(%eax),%eax
}
80105e3c:	c9                   	leave  
80105e3d:	c3                   	ret    

80105e3e <sys_sbrk>:

int
sys_sbrk(void)
{
80105e3e:	f3 0f 1e fb          	endbr32 
80105e42:	55                   	push   %ebp
80105e43:	89 e5                	mov    %esp,%ebp
80105e45:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105e48:	83 ec 08             	sub    $0x8,%esp
80105e4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e4e:	50                   	push   %eax
80105e4f:	6a 00                	push   $0x0
80105e51:	e8 52 f0 ff ff       	call   80104ea8 <argint>
80105e56:	83 c4 10             	add    $0x10,%esp
80105e59:	85 c0                	test   %eax,%eax
80105e5b:	79 07                	jns    80105e64 <sys_sbrk+0x26>
    return -1;
80105e5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e62:	eb 27                	jmp    80105e8b <sys_sbrk+0x4d>
  addr = myproc()->sz;
80105e64:	e8 40 dd ff ff       	call   80103ba9 <myproc>
80105e69:	8b 00                	mov    (%eax),%eax
80105e6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105e6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e71:	83 ec 0c             	sub    $0xc,%esp
80105e74:	50                   	push   %eax
80105e75:	e8 a3 df ff ff       	call   80103e1d <growproc>
80105e7a:	83 c4 10             	add    $0x10,%esp
80105e7d:	85 c0                	test   %eax,%eax
80105e7f:	79 07                	jns    80105e88 <sys_sbrk+0x4a>
    return -1;
80105e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e86:	eb 03                	jmp    80105e8b <sys_sbrk+0x4d>
  return addr;
80105e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e8b:	c9                   	leave  
80105e8c:	c3                   	ret    

80105e8d <sys_sleep>:

int
sys_sleep(void)
{
80105e8d:	f3 0f 1e fb          	endbr32 
80105e91:	55                   	push   %ebp
80105e92:	89 e5                	mov    %esp,%ebp
80105e94:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105e97:	83 ec 08             	sub    $0x8,%esp
80105e9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e9d:	50                   	push   %eax
80105e9e:	6a 00                	push   $0x0
80105ea0:	e8 03 f0 ff ff       	call   80104ea8 <argint>
80105ea5:	83 c4 10             	add    $0x10,%esp
80105ea8:	85 c0                	test   %eax,%eax
80105eaa:	79 07                	jns    80105eb3 <sys_sleep+0x26>
    return -1;
80105eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb1:	eb 76                	jmp    80105f29 <sys_sleep+0x9c>
  acquire(&tickslock);
80105eb3:	83 ec 0c             	sub    $0xc,%esp
80105eb6:	68 40 74 19 80       	push   $0x80197440
80105ebb:	e8 05 ea ff ff       	call   801048c5 <acquire>
80105ec0:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105ec3:	a1 80 7c 19 80       	mov    0x80197c80,%eax
80105ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105ecb:	eb 38                	jmp    80105f05 <sys_sleep+0x78>
    if(myproc()->killed){
80105ecd:	e8 d7 dc ff ff       	call   80103ba9 <myproc>
80105ed2:	8b 40 24             	mov    0x24(%eax),%eax
80105ed5:	85 c0                	test   %eax,%eax
80105ed7:	74 17                	je     80105ef0 <sys_sleep+0x63>
      release(&tickslock);
80105ed9:	83 ec 0c             	sub    $0xc,%esp
80105edc:	68 40 74 19 80       	push   $0x80197440
80105ee1:	e8 51 ea ff ff       	call   80104937 <release>
80105ee6:	83 c4 10             	add    $0x10,%esp
      return -1;
80105ee9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eee:	eb 39                	jmp    80105f29 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80105ef0:	83 ec 08             	sub    $0x8,%esp
80105ef3:	68 40 74 19 80       	push   $0x80197440
80105ef8:	68 80 7c 19 80       	push   $0x80197c80
80105efd:	e8 80 e5 ff ff       	call   80104482 <sleep>
80105f02:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105f05:	a1 80 7c 19 80       	mov    0x80197c80,%eax
80105f0a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105f0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f10:	39 d0                	cmp    %edx,%eax
80105f12:	72 b9                	jb     80105ecd <sys_sleep+0x40>
  }
  release(&tickslock);
80105f14:	83 ec 0c             	sub    $0xc,%esp
80105f17:	68 40 74 19 80       	push   $0x80197440
80105f1c:	e8 16 ea ff ff       	call   80104937 <release>
80105f21:	83 c4 10             	add    $0x10,%esp
  return 0;
80105f24:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f29:	c9                   	leave  
80105f2a:	c3                   	ret    

80105f2b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105f2b:	f3 0f 1e fb          	endbr32 
80105f2f:	55                   	push   %ebp
80105f30:	89 e5                	mov    %esp,%ebp
80105f32:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105f35:	83 ec 0c             	sub    $0xc,%esp
80105f38:	68 40 74 19 80       	push   $0x80197440
80105f3d:	e8 83 e9 ff ff       	call   801048c5 <acquire>
80105f42:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105f45:	a1 80 7c 19 80       	mov    0x80197c80,%eax
80105f4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105f4d:	83 ec 0c             	sub    $0xc,%esp
80105f50:	68 40 74 19 80       	push   $0x80197440
80105f55:	e8 dd e9 ff ff       	call   80104937 <release>
80105f5a:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f60:	c9                   	leave  
80105f61:	c3                   	ret    

80105f62 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105f62:	1e                   	push   %ds
  pushl %es
80105f63:	06                   	push   %es
  pushl %fs
80105f64:	0f a0                	push   %fs
  pushl %gs
80105f66:	0f a8                	push   %gs
  pushal
80105f68:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105f69:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105f6d:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105f6f:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105f71:	54                   	push   %esp
  call trap
80105f72:	e8 df 01 00 00       	call   80106156 <trap>
  addl $4, %esp
80105f77:	83 c4 04             	add    $0x4,%esp

80105f7a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105f7a:	61                   	popa   
  popl %gs
80105f7b:	0f a9                	pop    %gs
  popl %fs
80105f7d:	0f a1                	pop    %fs
  popl %es
80105f7f:	07                   	pop    %es
  popl %ds
80105f80:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105f81:	83 c4 08             	add    $0x8,%esp
  iret
80105f84:	cf                   	iret   

80105f85 <lidt>:
{
80105f85:	55                   	push   %ebp
80105f86:	89 e5                	mov    %esp,%ebp
80105f88:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f8e:	83 e8 01             	sub    $0x1,%eax
80105f91:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105f95:	8b 45 08             	mov    0x8(%ebp),%eax
80105f98:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105f9c:	8b 45 08             	mov    0x8(%ebp),%eax
80105f9f:	c1 e8 10             	shr    $0x10,%eax
80105fa2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105fa6:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105fa9:	0f 01 18             	lidtl  (%eax)
}
80105fac:	90                   	nop
80105fad:	c9                   	leave  
80105fae:	c3                   	ret    

80105faf <rcr2>:

static inline uint
rcr2(void)
{
80105faf:	55                   	push   %ebp
80105fb0:	89 e5                	mov    %esp,%ebp
80105fb2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105fb5:	0f 20 d0             	mov    %cr2,%eax
80105fb8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105fbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105fbe:	c9                   	leave  
80105fbf:	c3                   	ret    

80105fc0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105fc0:	f3 0f 1e fb          	endbr32 
80105fc4:	55                   	push   %ebp
80105fc5:	89 e5                	mov    %esp,%ebp
80105fc7:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105fca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105fd1:	e9 c3 00 00 00       	jmp    80106099 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd9:	8b 04 85 78 f0 10 80 	mov    -0x7fef0f88(,%eax,4),%eax
80105fe0:	89 c2                	mov    %eax,%edx
80105fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe5:	66 89 14 c5 80 74 19 	mov    %dx,-0x7fe68b80(,%eax,8)
80105fec:	80 
80105fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff0:	66 c7 04 c5 82 74 19 	movw   $0x8,-0x7fe68b7e(,%eax,8)
80105ff7:	80 08 00 
80105ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffd:	0f b6 14 c5 84 74 19 	movzbl -0x7fe68b7c(,%eax,8),%edx
80106004:	80 
80106005:	83 e2 e0             	and    $0xffffffe0,%edx
80106008:	88 14 c5 84 74 19 80 	mov    %dl,-0x7fe68b7c(,%eax,8)
8010600f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106012:	0f b6 14 c5 84 74 19 	movzbl -0x7fe68b7c(,%eax,8),%edx
80106019:	80 
8010601a:	83 e2 1f             	and    $0x1f,%edx
8010601d:	88 14 c5 84 74 19 80 	mov    %dl,-0x7fe68b7c(,%eax,8)
80106024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106027:	0f b6 14 c5 85 74 19 	movzbl -0x7fe68b7b(,%eax,8),%edx
8010602e:	80 
8010602f:	83 e2 f0             	and    $0xfffffff0,%edx
80106032:	83 ca 0e             	or     $0xe,%edx
80106035:	88 14 c5 85 74 19 80 	mov    %dl,-0x7fe68b7b(,%eax,8)
8010603c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603f:	0f b6 14 c5 85 74 19 	movzbl -0x7fe68b7b(,%eax,8),%edx
80106046:	80 
80106047:	83 e2 ef             	and    $0xffffffef,%edx
8010604a:	88 14 c5 85 74 19 80 	mov    %dl,-0x7fe68b7b(,%eax,8)
80106051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106054:	0f b6 14 c5 85 74 19 	movzbl -0x7fe68b7b(,%eax,8),%edx
8010605b:	80 
8010605c:	83 e2 9f             	and    $0xffffff9f,%edx
8010605f:	88 14 c5 85 74 19 80 	mov    %dl,-0x7fe68b7b(,%eax,8)
80106066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106069:	0f b6 14 c5 85 74 19 	movzbl -0x7fe68b7b(,%eax,8),%edx
80106070:	80 
80106071:	83 ca 80             	or     $0xffffff80,%edx
80106074:	88 14 c5 85 74 19 80 	mov    %dl,-0x7fe68b7b(,%eax,8)
8010607b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607e:	8b 04 85 78 f0 10 80 	mov    -0x7fef0f88(,%eax,4),%eax
80106085:	c1 e8 10             	shr    $0x10,%eax
80106088:	89 c2                	mov    %eax,%edx
8010608a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608d:	66 89 14 c5 86 74 19 	mov    %dx,-0x7fe68b7a(,%eax,8)
80106094:	80 
  for(i = 0; i < 256; i++)
80106095:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106099:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801060a0:	0f 8e 30 ff ff ff    	jle    80105fd6 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801060a6:	a1 78 f1 10 80       	mov    0x8010f178,%eax
801060ab:	66 a3 80 76 19 80    	mov    %ax,0x80197680
801060b1:	66 c7 05 82 76 19 80 	movw   $0x8,0x80197682
801060b8:	08 00 
801060ba:	0f b6 05 84 76 19 80 	movzbl 0x80197684,%eax
801060c1:	83 e0 e0             	and    $0xffffffe0,%eax
801060c4:	a2 84 76 19 80       	mov    %al,0x80197684
801060c9:	0f b6 05 84 76 19 80 	movzbl 0x80197684,%eax
801060d0:	83 e0 1f             	and    $0x1f,%eax
801060d3:	a2 84 76 19 80       	mov    %al,0x80197684
801060d8:	0f b6 05 85 76 19 80 	movzbl 0x80197685,%eax
801060df:	83 c8 0f             	or     $0xf,%eax
801060e2:	a2 85 76 19 80       	mov    %al,0x80197685
801060e7:	0f b6 05 85 76 19 80 	movzbl 0x80197685,%eax
801060ee:	83 e0 ef             	and    $0xffffffef,%eax
801060f1:	a2 85 76 19 80       	mov    %al,0x80197685
801060f6:	0f b6 05 85 76 19 80 	movzbl 0x80197685,%eax
801060fd:	83 c8 60             	or     $0x60,%eax
80106100:	a2 85 76 19 80       	mov    %al,0x80197685
80106105:	0f b6 05 85 76 19 80 	movzbl 0x80197685,%eax
8010610c:	83 c8 80             	or     $0xffffff80,%eax
8010610f:	a2 85 76 19 80       	mov    %al,0x80197685
80106114:	a1 78 f1 10 80       	mov    0x8010f178,%eax
80106119:	c1 e8 10             	shr    $0x10,%eax
8010611c:	66 a3 86 76 19 80    	mov    %ax,0x80197686

  initlock(&tickslock, "time");
80106122:	83 ec 08             	sub    $0x8,%esp
80106125:	68 78 a7 10 80       	push   $0x8010a778
8010612a:	68 40 74 19 80       	push   $0x80197440
8010612f:	e8 6b e7 ff ff       	call   8010489f <initlock>
80106134:	83 c4 10             	add    $0x10,%esp
}
80106137:	90                   	nop
80106138:	c9                   	leave  
80106139:	c3                   	ret    

8010613a <idtinit>:

void
idtinit(void)
{
8010613a:	f3 0f 1e fb          	endbr32 
8010613e:	55                   	push   %ebp
8010613f:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106141:	68 00 08 00 00       	push   $0x800
80106146:	68 80 74 19 80       	push   $0x80197480
8010614b:	e8 35 fe ff ff       	call   80105f85 <lidt>
80106150:	83 c4 08             	add    $0x8,%esp
}
80106153:	90                   	nop
80106154:	c9                   	leave  
80106155:	c3                   	ret    

80106156 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106156:	f3 0f 1e fb          	endbr32 
8010615a:	55                   	push   %ebp
8010615b:	89 e5                	mov    %esp,%ebp
8010615d:	57                   	push   %edi
8010615e:	56                   	push   %esi
8010615f:	53                   	push   %ebx
80106160:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106163:	8b 45 08             	mov    0x8(%ebp),%eax
80106166:	8b 40 30             	mov    0x30(%eax),%eax
80106169:	83 f8 40             	cmp    $0x40,%eax
8010616c:	75 3b                	jne    801061a9 <trap+0x53>
    if(myproc()->killed)
8010616e:	e8 36 da ff ff       	call   80103ba9 <myproc>
80106173:	8b 40 24             	mov    0x24(%eax),%eax
80106176:	85 c0                	test   %eax,%eax
80106178:	74 05                	je     8010617f <trap+0x29>
      exit();
8010617a:	e8 ba de ff ff       	call   80104039 <exit>
    myproc()->tf = tf;
8010617f:	e8 25 da ff ff       	call   80103ba9 <myproc>
80106184:	8b 55 08             	mov    0x8(%ebp),%edx
80106187:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010618a:	e8 f1 ed ff ff       	call   80104f80 <syscall>
    if(myproc()->killed)
8010618f:	e8 15 da ff ff       	call   80103ba9 <myproc>
80106194:	8b 40 24             	mov    0x24(%eax),%eax
80106197:	85 c0                	test   %eax,%eax
80106199:	0f 84 16 02 00 00    	je     801063b5 <trap+0x25f>
      exit();
8010619f:	e8 95 de ff ff       	call   80104039 <exit>
    return;
801061a4:	e9 0c 02 00 00       	jmp    801063b5 <trap+0x25f>
  }

  switch(tf->trapno){
801061a9:	8b 45 08             	mov    0x8(%ebp),%eax
801061ac:	8b 40 30             	mov    0x30(%eax),%eax
801061af:	83 e8 20             	sub    $0x20,%eax
801061b2:	83 f8 1f             	cmp    $0x1f,%eax
801061b5:	0f 87 c5 00 00 00    	ja     80106280 <trap+0x12a>
801061bb:	8b 04 85 20 a8 10 80 	mov    -0x7fef57e0(,%eax,4),%eax
801061c2:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801061c5:	e8 44 d9 ff ff       	call   80103b0e <cpuid>
801061ca:	85 c0                	test   %eax,%eax
801061cc:	75 3d                	jne    8010620b <trap+0xb5>
      acquire(&tickslock);
801061ce:	83 ec 0c             	sub    $0xc,%esp
801061d1:	68 40 74 19 80       	push   $0x80197440
801061d6:	e8 ea e6 ff ff       	call   801048c5 <acquire>
801061db:	83 c4 10             	add    $0x10,%esp
      ticks++;
801061de:	a1 80 7c 19 80       	mov    0x80197c80,%eax
801061e3:	83 c0 01             	add    $0x1,%eax
801061e6:	a3 80 7c 19 80       	mov    %eax,0x80197c80
      wakeup(&ticks);
801061eb:	83 ec 0c             	sub    $0xc,%esp
801061ee:	68 80 7c 19 80       	push   $0x80197c80
801061f3:	e8 79 e3 ff ff       	call   80104571 <wakeup>
801061f8:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801061fb:	83 ec 0c             	sub    $0xc,%esp
801061fe:	68 40 74 19 80       	push   $0x80197440
80106203:	e8 2f e7 ff ff       	call   80104937 <release>
80106208:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010620b:	e8 15 ca ff ff       	call   80102c25 <lapiceoi>
    break;
80106210:	e9 20 01 00 00       	jmp    80106335 <trap+0x1df>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106215:	e8 1b 40 00 00       	call   8010a235 <ideintr>
    lapiceoi();
8010621a:	e8 06 ca ff ff       	call   80102c25 <lapiceoi>
    break;
8010621f:	e9 11 01 00 00       	jmp    80106335 <trap+0x1df>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106224:	e8 32 c8 ff ff       	call   80102a5b <kbdintr>
    lapiceoi();
80106229:	e8 f7 c9 ff ff       	call   80102c25 <lapiceoi>
    break;
8010622e:	e9 02 01 00 00       	jmp    80106335 <trap+0x1df>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106233:	e8 5f 03 00 00       	call   80106597 <uartintr>
    lapiceoi();
80106238:	e8 e8 c9 ff ff       	call   80102c25 <lapiceoi>
    break;
8010623d:	e9 f3 00 00 00       	jmp    80106335 <trap+0x1df>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106242:	e8 2d 2c 00 00       	call   80108e74 <i8254_intr>
    lapiceoi();
80106247:	e8 d9 c9 ff ff       	call   80102c25 <lapiceoi>
    break;
8010624c:	e9 e4 00 00 00       	jmp    80106335 <trap+0x1df>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106251:	8b 45 08             	mov    0x8(%ebp),%eax
80106254:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106257:	8b 45 08             	mov    0x8(%ebp),%eax
8010625a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010625e:	0f b7 d8             	movzwl %ax,%ebx
80106261:	e8 a8 d8 ff ff       	call   80103b0e <cpuid>
80106266:	56                   	push   %esi
80106267:	53                   	push   %ebx
80106268:	50                   	push   %eax
80106269:	68 80 a7 10 80       	push   $0x8010a780
8010626e:	e8 99 a1 ff ff       	call   8010040c <cprintf>
80106273:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106276:	e8 aa c9 ff ff       	call   80102c25 <lapiceoi>
    break;
8010627b:	e9 b5 00 00 00       	jmp    80106335 <trap+0x1df>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106280:	e8 24 d9 ff ff       	call   80103ba9 <myproc>
80106285:	85 c0                	test   %eax,%eax
80106287:	74 11                	je     8010629a <trap+0x144>
80106289:	8b 45 08             	mov    0x8(%ebp),%eax
8010628c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106290:	0f b7 c0             	movzwl %ax,%eax
80106293:	83 e0 03             	and    $0x3,%eax
80106296:	85 c0                	test   %eax,%eax
80106298:	75 39                	jne    801062d3 <trap+0x17d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010629a:	e8 10 fd ff ff       	call   80105faf <rcr2>
8010629f:	89 c3                	mov    %eax,%ebx
801062a1:	8b 45 08             	mov    0x8(%ebp),%eax
801062a4:	8b 70 38             	mov    0x38(%eax),%esi
801062a7:	e8 62 d8 ff ff       	call   80103b0e <cpuid>
801062ac:	8b 55 08             	mov    0x8(%ebp),%edx
801062af:	8b 52 30             	mov    0x30(%edx),%edx
801062b2:	83 ec 0c             	sub    $0xc,%esp
801062b5:	53                   	push   %ebx
801062b6:	56                   	push   %esi
801062b7:	50                   	push   %eax
801062b8:	52                   	push   %edx
801062b9:	68 a4 a7 10 80       	push   $0x8010a7a4
801062be:	e8 49 a1 ff ff       	call   8010040c <cprintf>
801062c3:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801062c6:	83 ec 0c             	sub    $0xc,%esp
801062c9:	68 d6 a7 10 80       	push   $0x8010a7d6
801062ce:	e8 f2 a2 ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801062d3:	e8 d7 fc ff ff       	call   80105faf <rcr2>
801062d8:	89 c6                	mov    %eax,%esi
801062da:	8b 45 08             	mov    0x8(%ebp),%eax
801062dd:	8b 40 38             	mov    0x38(%eax),%eax
801062e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801062e3:	e8 26 d8 ff ff       	call   80103b0e <cpuid>
801062e8:	89 c3                	mov    %eax,%ebx
801062ea:	8b 45 08             	mov    0x8(%ebp),%eax
801062ed:	8b 48 34             	mov    0x34(%eax),%ecx
801062f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801062f3:	8b 45 08             	mov    0x8(%ebp),%eax
801062f6:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801062f9:	e8 ab d8 ff ff       	call   80103ba9 <myproc>
801062fe:	8d 50 6c             	lea    0x6c(%eax),%edx
80106301:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106304:	e8 a0 d8 ff ff       	call   80103ba9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106309:	8b 40 10             	mov    0x10(%eax),%eax
8010630c:	56                   	push   %esi
8010630d:	ff 75 e4             	pushl  -0x1c(%ebp)
80106310:	53                   	push   %ebx
80106311:	ff 75 e0             	pushl  -0x20(%ebp)
80106314:	57                   	push   %edi
80106315:	ff 75 dc             	pushl  -0x24(%ebp)
80106318:	50                   	push   %eax
80106319:	68 dc a7 10 80       	push   $0x8010a7dc
8010631e:	e8 e9 a0 ff ff       	call   8010040c <cprintf>
80106323:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106326:	e8 7e d8 ff ff       	call   80103ba9 <myproc>
8010632b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106332:	eb 01                	jmp    80106335 <trap+0x1df>
    break;
80106334:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106335:	e8 6f d8 ff ff       	call   80103ba9 <myproc>
8010633a:	85 c0                	test   %eax,%eax
8010633c:	74 23                	je     80106361 <trap+0x20b>
8010633e:	e8 66 d8 ff ff       	call   80103ba9 <myproc>
80106343:	8b 40 24             	mov    0x24(%eax),%eax
80106346:	85 c0                	test   %eax,%eax
80106348:	74 17                	je     80106361 <trap+0x20b>
8010634a:	8b 45 08             	mov    0x8(%ebp),%eax
8010634d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106351:	0f b7 c0             	movzwl %ax,%eax
80106354:	83 e0 03             	and    $0x3,%eax
80106357:	83 f8 03             	cmp    $0x3,%eax
8010635a:	75 05                	jne    80106361 <trap+0x20b>
    exit();
8010635c:	e8 d8 dc ff ff       	call   80104039 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106361:	e8 43 d8 ff ff       	call   80103ba9 <myproc>
80106366:	85 c0                	test   %eax,%eax
80106368:	74 1d                	je     80106387 <trap+0x231>
8010636a:	e8 3a d8 ff ff       	call   80103ba9 <myproc>
8010636f:	8b 40 0c             	mov    0xc(%eax),%eax
80106372:	83 f8 04             	cmp    $0x4,%eax
80106375:	75 10                	jne    80106387 <trap+0x231>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106377:	8b 45 08             	mov    0x8(%ebp),%eax
8010637a:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
8010637d:	83 f8 20             	cmp    $0x20,%eax
80106380:	75 05                	jne    80106387 <trap+0x231>
    yield();
80106382:	e8 73 e0 ff ff       	call   801043fa <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106387:	e8 1d d8 ff ff       	call   80103ba9 <myproc>
8010638c:	85 c0                	test   %eax,%eax
8010638e:	74 26                	je     801063b6 <trap+0x260>
80106390:	e8 14 d8 ff ff       	call   80103ba9 <myproc>
80106395:	8b 40 24             	mov    0x24(%eax),%eax
80106398:	85 c0                	test   %eax,%eax
8010639a:	74 1a                	je     801063b6 <trap+0x260>
8010639c:	8b 45 08             	mov    0x8(%ebp),%eax
8010639f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801063a3:	0f b7 c0             	movzwl %ax,%eax
801063a6:	83 e0 03             	and    $0x3,%eax
801063a9:	83 f8 03             	cmp    $0x3,%eax
801063ac:	75 08                	jne    801063b6 <trap+0x260>
    exit();
801063ae:	e8 86 dc ff ff       	call   80104039 <exit>
801063b3:	eb 01                	jmp    801063b6 <trap+0x260>
    return;
801063b5:	90                   	nop
}
801063b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063b9:	5b                   	pop    %ebx
801063ba:	5e                   	pop    %esi
801063bb:	5f                   	pop    %edi
801063bc:	5d                   	pop    %ebp
801063bd:	c3                   	ret    

801063be <inb>:
{
801063be:	55                   	push   %ebp
801063bf:	89 e5                	mov    %esp,%ebp
801063c1:	83 ec 14             	sub    $0x14,%esp
801063c4:	8b 45 08             	mov    0x8(%ebp),%eax
801063c7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801063cb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801063cf:	89 c2                	mov    %eax,%edx
801063d1:	ec                   	in     (%dx),%al
801063d2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801063d5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801063d9:	c9                   	leave  
801063da:	c3                   	ret    

801063db <outb>:
{
801063db:	55                   	push   %ebp
801063dc:	89 e5                	mov    %esp,%ebp
801063de:	83 ec 08             	sub    $0x8,%esp
801063e1:	8b 45 08             	mov    0x8(%ebp),%eax
801063e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801063e7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801063eb:	89 d0                	mov    %edx,%eax
801063ed:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801063f0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801063f4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801063f8:	ee                   	out    %al,(%dx)
}
801063f9:	90                   	nop
801063fa:	c9                   	leave  
801063fb:	c3                   	ret    

801063fc <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801063fc:	f3 0f 1e fb          	endbr32 
80106400:	55                   	push   %ebp
80106401:	89 e5                	mov    %esp,%ebp
80106403:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106406:	6a 00                	push   $0x0
80106408:	68 fa 03 00 00       	push   $0x3fa
8010640d:	e8 c9 ff ff ff       	call   801063db <outb>
80106412:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106415:	68 80 00 00 00       	push   $0x80
8010641a:	68 fb 03 00 00       	push   $0x3fb
8010641f:	e8 b7 ff ff ff       	call   801063db <outb>
80106424:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106427:	6a 0c                	push   $0xc
80106429:	68 f8 03 00 00       	push   $0x3f8
8010642e:	e8 a8 ff ff ff       	call   801063db <outb>
80106433:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106436:	6a 00                	push   $0x0
80106438:	68 f9 03 00 00       	push   $0x3f9
8010643d:	e8 99 ff ff ff       	call   801063db <outb>
80106442:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106445:	6a 03                	push   $0x3
80106447:	68 fb 03 00 00       	push   $0x3fb
8010644c:	e8 8a ff ff ff       	call   801063db <outb>
80106451:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106454:	6a 00                	push   $0x0
80106456:	68 fc 03 00 00       	push   $0x3fc
8010645b:	e8 7b ff ff ff       	call   801063db <outb>
80106460:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106463:	6a 01                	push   $0x1
80106465:	68 f9 03 00 00       	push   $0x3f9
8010646a:	e8 6c ff ff ff       	call   801063db <outb>
8010646f:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106472:	68 fd 03 00 00       	push   $0x3fd
80106477:	e8 42 ff ff ff       	call   801063be <inb>
8010647c:	83 c4 04             	add    $0x4,%esp
8010647f:	3c ff                	cmp    $0xff,%al
80106481:	74 61                	je     801064e4 <uartinit+0xe8>
    return;
  uart = 1;
80106483:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
8010648a:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010648d:	68 fa 03 00 00       	push   $0x3fa
80106492:	e8 27 ff ff ff       	call   801063be <inb>
80106497:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010649a:	68 f8 03 00 00       	push   $0x3f8
8010649f:	e8 1a ff ff ff       	call   801063be <inb>
801064a4:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801064a7:	83 ec 08             	sub    $0x8,%esp
801064aa:	6a 00                	push   $0x0
801064ac:	6a 04                	push   $0x4
801064ae:	e8 59 c2 ff ff       	call   8010270c <ioapicenable>
801064b3:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801064b6:	c7 45 f4 a0 a8 10 80 	movl   $0x8010a8a0,-0xc(%ebp)
801064bd:	eb 19                	jmp    801064d8 <uartinit+0xdc>
    uartputc(*p);
801064bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c2:	0f b6 00             	movzbl (%eax),%eax
801064c5:	0f be c0             	movsbl %al,%eax
801064c8:	83 ec 0c             	sub    $0xc,%esp
801064cb:	50                   	push   %eax
801064cc:	e8 16 00 00 00       	call   801064e7 <uartputc>
801064d1:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801064d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801064d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064db:	0f b6 00             	movzbl (%eax),%eax
801064de:	84 c0                	test   %al,%al
801064e0:	75 dd                	jne    801064bf <uartinit+0xc3>
801064e2:	eb 01                	jmp    801064e5 <uartinit+0xe9>
    return;
801064e4:	90                   	nop
}
801064e5:	c9                   	leave  
801064e6:	c3                   	ret    

801064e7 <uartputc>:

void
uartputc(int c)
{
801064e7:	f3 0f 1e fb          	endbr32 
801064eb:	55                   	push   %ebp
801064ec:	89 e5                	mov    %esp,%ebp
801064ee:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801064f1:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801064f6:	85 c0                	test   %eax,%eax
801064f8:	74 53                	je     8010654d <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801064fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106501:	eb 11                	jmp    80106514 <uartputc+0x2d>
    microdelay(10);
80106503:	83 ec 0c             	sub    $0xc,%esp
80106506:	6a 0a                	push   $0xa
80106508:	e8 37 c7 ff ff       	call   80102c44 <microdelay>
8010650d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106510:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106514:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106518:	7f 1a                	jg     80106534 <uartputc+0x4d>
8010651a:	83 ec 0c             	sub    $0xc,%esp
8010651d:	68 fd 03 00 00       	push   $0x3fd
80106522:	e8 97 fe ff ff       	call   801063be <inb>
80106527:	83 c4 10             	add    $0x10,%esp
8010652a:	0f b6 c0             	movzbl %al,%eax
8010652d:	83 e0 20             	and    $0x20,%eax
80106530:	85 c0                	test   %eax,%eax
80106532:	74 cf                	je     80106503 <uartputc+0x1c>
  outb(COM1+0, c);
80106534:	8b 45 08             	mov    0x8(%ebp),%eax
80106537:	0f b6 c0             	movzbl %al,%eax
8010653a:	83 ec 08             	sub    $0x8,%esp
8010653d:	50                   	push   %eax
8010653e:	68 f8 03 00 00       	push   $0x3f8
80106543:	e8 93 fe ff ff       	call   801063db <outb>
80106548:	83 c4 10             	add    $0x10,%esp
8010654b:	eb 01                	jmp    8010654e <uartputc+0x67>
    return;
8010654d:	90                   	nop
}
8010654e:	c9                   	leave  
8010654f:	c3                   	ret    

80106550 <uartgetc>:

static int
uartgetc(void)
{
80106550:	f3 0f 1e fb          	endbr32 
80106554:	55                   	push   %ebp
80106555:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106557:	a1 60 d0 18 80       	mov    0x8018d060,%eax
8010655c:	85 c0                	test   %eax,%eax
8010655e:	75 07                	jne    80106567 <uartgetc+0x17>
    return -1;
80106560:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106565:	eb 2e                	jmp    80106595 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106567:	68 fd 03 00 00       	push   $0x3fd
8010656c:	e8 4d fe ff ff       	call   801063be <inb>
80106571:	83 c4 04             	add    $0x4,%esp
80106574:	0f b6 c0             	movzbl %al,%eax
80106577:	83 e0 01             	and    $0x1,%eax
8010657a:	85 c0                	test   %eax,%eax
8010657c:	75 07                	jne    80106585 <uartgetc+0x35>
    return -1;
8010657e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106583:	eb 10                	jmp    80106595 <uartgetc+0x45>
  return inb(COM1+0);
80106585:	68 f8 03 00 00       	push   $0x3f8
8010658a:	e8 2f fe ff ff       	call   801063be <inb>
8010658f:	83 c4 04             	add    $0x4,%esp
80106592:	0f b6 c0             	movzbl %al,%eax
}
80106595:	c9                   	leave  
80106596:	c3                   	ret    

80106597 <uartintr>:

void
uartintr(void)
{
80106597:	f3 0f 1e fb          	endbr32 
8010659b:	55                   	push   %ebp
8010659c:	89 e5                	mov    %esp,%ebp
8010659e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801065a1:	83 ec 0c             	sub    $0xc,%esp
801065a4:	68 50 65 10 80       	push   $0x80106550
801065a9:	e8 52 a2 ff ff       	call   80100800 <consoleintr>
801065ae:	83 c4 10             	add    $0x10,%esp
}
801065b1:	90                   	nop
801065b2:	c9                   	leave  
801065b3:	c3                   	ret    

801065b4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801065b4:	6a 00                	push   $0x0
  pushl $0
801065b6:	6a 00                	push   $0x0
  jmp alltraps
801065b8:	e9 a5 f9 ff ff       	jmp    80105f62 <alltraps>

801065bd <vector1>:
.globl vector1
vector1:
  pushl $0
801065bd:	6a 00                	push   $0x0
  pushl $1
801065bf:	6a 01                	push   $0x1
  jmp alltraps
801065c1:	e9 9c f9 ff ff       	jmp    80105f62 <alltraps>

801065c6 <vector2>:
.globl vector2
vector2:
  pushl $0
801065c6:	6a 00                	push   $0x0
  pushl $2
801065c8:	6a 02                	push   $0x2
  jmp alltraps
801065ca:	e9 93 f9 ff ff       	jmp    80105f62 <alltraps>

801065cf <vector3>:
.globl vector3
vector3:
  pushl $0
801065cf:	6a 00                	push   $0x0
  pushl $3
801065d1:	6a 03                	push   $0x3
  jmp alltraps
801065d3:	e9 8a f9 ff ff       	jmp    80105f62 <alltraps>

801065d8 <vector4>:
.globl vector4
vector4:
  pushl $0
801065d8:	6a 00                	push   $0x0
  pushl $4
801065da:	6a 04                	push   $0x4
  jmp alltraps
801065dc:	e9 81 f9 ff ff       	jmp    80105f62 <alltraps>

801065e1 <vector5>:
.globl vector5
vector5:
  pushl $0
801065e1:	6a 00                	push   $0x0
  pushl $5
801065e3:	6a 05                	push   $0x5
  jmp alltraps
801065e5:	e9 78 f9 ff ff       	jmp    80105f62 <alltraps>

801065ea <vector6>:
.globl vector6
vector6:
  pushl $0
801065ea:	6a 00                	push   $0x0
  pushl $6
801065ec:	6a 06                	push   $0x6
  jmp alltraps
801065ee:	e9 6f f9 ff ff       	jmp    80105f62 <alltraps>

801065f3 <vector7>:
.globl vector7
vector7:
  pushl $0
801065f3:	6a 00                	push   $0x0
  pushl $7
801065f5:	6a 07                	push   $0x7
  jmp alltraps
801065f7:	e9 66 f9 ff ff       	jmp    80105f62 <alltraps>

801065fc <vector8>:
.globl vector8
vector8:
  pushl $8
801065fc:	6a 08                	push   $0x8
  jmp alltraps
801065fe:	e9 5f f9 ff ff       	jmp    80105f62 <alltraps>

80106603 <vector9>:
.globl vector9
vector9:
  pushl $0
80106603:	6a 00                	push   $0x0
  pushl $9
80106605:	6a 09                	push   $0x9
  jmp alltraps
80106607:	e9 56 f9 ff ff       	jmp    80105f62 <alltraps>

8010660c <vector10>:
.globl vector10
vector10:
  pushl $10
8010660c:	6a 0a                	push   $0xa
  jmp alltraps
8010660e:	e9 4f f9 ff ff       	jmp    80105f62 <alltraps>

80106613 <vector11>:
.globl vector11
vector11:
  pushl $11
80106613:	6a 0b                	push   $0xb
  jmp alltraps
80106615:	e9 48 f9 ff ff       	jmp    80105f62 <alltraps>

8010661a <vector12>:
.globl vector12
vector12:
  pushl $12
8010661a:	6a 0c                	push   $0xc
  jmp alltraps
8010661c:	e9 41 f9 ff ff       	jmp    80105f62 <alltraps>

80106621 <vector13>:
.globl vector13
vector13:
  pushl $13
80106621:	6a 0d                	push   $0xd
  jmp alltraps
80106623:	e9 3a f9 ff ff       	jmp    80105f62 <alltraps>

80106628 <vector14>:
.globl vector14
vector14:
  pushl $14
80106628:	6a 0e                	push   $0xe
  jmp alltraps
8010662a:	e9 33 f9 ff ff       	jmp    80105f62 <alltraps>

8010662f <vector15>:
.globl vector15
vector15:
  pushl $0
8010662f:	6a 00                	push   $0x0
  pushl $15
80106631:	6a 0f                	push   $0xf
  jmp alltraps
80106633:	e9 2a f9 ff ff       	jmp    80105f62 <alltraps>

80106638 <vector16>:
.globl vector16
vector16:
  pushl $0
80106638:	6a 00                	push   $0x0
  pushl $16
8010663a:	6a 10                	push   $0x10
  jmp alltraps
8010663c:	e9 21 f9 ff ff       	jmp    80105f62 <alltraps>

80106641 <vector17>:
.globl vector17
vector17:
  pushl $17
80106641:	6a 11                	push   $0x11
  jmp alltraps
80106643:	e9 1a f9 ff ff       	jmp    80105f62 <alltraps>

80106648 <vector18>:
.globl vector18
vector18:
  pushl $0
80106648:	6a 00                	push   $0x0
  pushl $18
8010664a:	6a 12                	push   $0x12
  jmp alltraps
8010664c:	e9 11 f9 ff ff       	jmp    80105f62 <alltraps>

80106651 <vector19>:
.globl vector19
vector19:
  pushl $0
80106651:	6a 00                	push   $0x0
  pushl $19
80106653:	6a 13                	push   $0x13
  jmp alltraps
80106655:	e9 08 f9 ff ff       	jmp    80105f62 <alltraps>

8010665a <vector20>:
.globl vector20
vector20:
  pushl $0
8010665a:	6a 00                	push   $0x0
  pushl $20
8010665c:	6a 14                	push   $0x14
  jmp alltraps
8010665e:	e9 ff f8 ff ff       	jmp    80105f62 <alltraps>

80106663 <vector21>:
.globl vector21
vector21:
  pushl $0
80106663:	6a 00                	push   $0x0
  pushl $21
80106665:	6a 15                	push   $0x15
  jmp alltraps
80106667:	e9 f6 f8 ff ff       	jmp    80105f62 <alltraps>

8010666c <vector22>:
.globl vector22
vector22:
  pushl $0
8010666c:	6a 00                	push   $0x0
  pushl $22
8010666e:	6a 16                	push   $0x16
  jmp alltraps
80106670:	e9 ed f8 ff ff       	jmp    80105f62 <alltraps>

80106675 <vector23>:
.globl vector23
vector23:
  pushl $0
80106675:	6a 00                	push   $0x0
  pushl $23
80106677:	6a 17                	push   $0x17
  jmp alltraps
80106679:	e9 e4 f8 ff ff       	jmp    80105f62 <alltraps>

8010667e <vector24>:
.globl vector24
vector24:
  pushl $0
8010667e:	6a 00                	push   $0x0
  pushl $24
80106680:	6a 18                	push   $0x18
  jmp alltraps
80106682:	e9 db f8 ff ff       	jmp    80105f62 <alltraps>

80106687 <vector25>:
.globl vector25
vector25:
  pushl $0
80106687:	6a 00                	push   $0x0
  pushl $25
80106689:	6a 19                	push   $0x19
  jmp alltraps
8010668b:	e9 d2 f8 ff ff       	jmp    80105f62 <alltraps>

80106690 <vector26>:
.globl vector26
vector26:
  pushl $0
80106690:	6a 00                	push   $0x0
  pushl $26
80106692:	6a 1a                	push   $0x1a
  jmp alltraps
80106694:	e9 c9 f8 ff ff       	jmp    80105f62 <alltraps>

80106699 <vector27>:
.globl vector27
vector27:
  pushl $0
80106699:	6a 00                	push   $0x0
  pushl $27
8010669b:	6a 1b                	push   $0x1b
  jmp alltraps
8010669d:	e9 c0 f8 ff ff       	jmp    80105f62 <alltraps>

801066a2 <vector28>:
.globl vector28
vector28:
  pushl $0
801066a2:	6a 00                	push   $0x0
  pushl $28
801066a4:	6a 1c                	push   $0x1c
  jmp alltraps
801066a6:	e9 b7 f8 ff ff       	jmp    80105f62 <alltraps>

801066ab <vector29>:
.globl vector29
vector29:
  pushl $0
801066ab:	6a 00                	push   $0x0
  pushl $29
801066ad:	6a 1d                	push   $0x1d
  jmp alltraps
801066af:	e9 ae f8 ff ff       	jmp    80105f62 <alltraps>

801066b4 <vector30>:
.globl vector30
vector30:
  pushl $0
801066b4:	6a 00                	push   $0x0
  pushl $30
801066b6:	6a 1e                	push   $0x1e
  jmp alltraps
801066b8:	e9 a5 f8 ff ff       	jmp    80105f62 <alltraps>

801066bd <vector31>:
.globl vector31
vector31:
  pushl $0
801066bd:	6a 00                	push   $0x0
  pushl $31
801066bf:	6a 1f                	push   $0x1f
  jmp alltraps
801066c1:	e9 9c f8 ff ff       	jmp    80105f62 <alltraps>

801066c6 <vector32>:
.globl vector32
vector32:
  pushl $0
801066c6:	6a 00                	push   $0x0
  pushl $32
801066c8:	6a 20                	push   $0x20
  jmp alltraps
801066ca:	e9 93 f8 ff ff       	jmp    80105f62 <alltraps>

801066cf <vector33>:
.globl vector33
vector33:
  pushl $0
801066cf:	6a 00                	push   $0x0
  pushl $33
801066d1:	6a 21                	push   $0x21
  jmp alltraps
801066d3:	e9 8a f8 ff ff       	jmp    80105f62 <alltraps>

801066d8 <vector34>:
.globl vector34
vector34:
  pushl $0
801066d8:	6a 00                	push   $0x0
  pushl $34
801066da:	6a 22                	push   $0x22
  jmp alltraps
801066dc:	e9 81 f8 ff ff       	jmp    80105f62 <alltraps>

801066e1 <vector35>:
.globl vector35
vector35:
  pushl $0
801066e1:	6a 00                	push   $0x0
  pushl $35
801066e3:	6a 23                	push   $0x23
  jmp alltraps
801066e5:	e9 78 f8 ff ff       	jmp    80105f62 <alltraps>

801066ea <vector36>:
.globl vector36
vector36:
  pushl $0
801066ea:	6a 00                	push   $0x0
  pushl $36
801066ec:	6a 24                	push   $0x24
  jmp alltraps
801066ee:	e9 6f f8 ff ff       	jmp    80105f62 <alltraps>

801066f3 <vector37>:
.globl vector37
vector37:
  pushl $0
801066f3:	6a 00                	push   $0x0
  pushl $37
801066f5:	6a 25                	push   $0x25
  jmp alltraps
801066f7:	e9 66 f8 ff ff       	jmp    80105f62 <alltraps>

801066fc <vector38>:
.globl vector38
vector38:
  pushl $0
801066fc:	6a 00                	push   $0x0
  pushl $38
801066fe:	6a 26                	push   $0x26
  jmp alltraps
80106700:	e9 5d f8 ff ff       	jmp    80105f62 <alltraps>

80106705 <vector39>:
.globl vector39
vector39:
  pushl $0
80106705:	6a 00                	push   $0x0
  pushl $39
80106707:	6a 27                	push   $0x27
  jmp alltraps
80106709:	e9 54 f8 ff ff       	jmp    80105f62 <alltraps>

8010670e <vector40>:
.globl vector40
vector40:
  pushl $0
8010670e:	6a 00                	push   $0x0
  pushl $40
80106710:	6a 28                	push   $0x28
  jmp alltraps
80106712:	e9 4b f8 ff ff       	jmp    80105f62 <alltraps>

80106717 <vector41>:
.globl vector41
vector41:
  pushl $0
80106717:	6a 00                	push   $0x0
  pushl $41
80106719:	6a 29                	push   $0x29
  jmp alltraps
8010671b:	e9 42 f8 ff ff       	jmp    80105f62 <alltraps>

80106720 <vector42>:
.globl vector42
vector42:
  pushl $0
80106720:	6a 00                	push   $0x0
  pushl $42
80106722:	6a 2a                	push   $0x2a
  jmp alltraps
80106724:	e9 39 f8 ff ff       	jmp    80105f62 <alltraps>

80106729 <vector43>:
.globl vector43
vector43:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $43
8010672b:	6a 2b                	push   $0x2b
  jmp alltraps
8010672d:	e9 30 f8 ff ff       	jmp    80105f62 <alltraps>

80106732 <vector44>:
.globl vector44
vector44:
  pushl $0
80106732:	6a 00                	push   $0x0
  pushl $44
80106734:	6a 2c                	push   $0x2c
  jmp alltraps
80106736:	e9 27 f8 ff ff       	jmp    80105f62 <alltraps>

8010673b <vector45>:
.globl vector45
vector45:
  pushl $0
8010673b:	6a 00                	push   $0x0
  pushl $45
8010673d:	6a 2d                	push   $0x2d
  jmp alltraps
8010673f:	e9 1e f8 ff ff       	jmp    80105f62 <alltraps>

80106744 <vector46>:
.globl vector46
vector46:
  pushl $0
80106744:	6a 00                	push   $0x0
  pushl $46
80106746:	6a 2e                	push   $0x2e
  jmp alltraps
80106748:	e9 15 f8 ff ff       	jmp    80105f62 <alltraps>

8010674d <vector47>:
.globl vector47
vector47:
  pushl $0
8010674d:	6a 00                	push   $0x0
  pushl $47
8010674f:	6a 2f                	push   $0x2f
  jmp alltraps
80106751:	e9 0c f8 ff ff       	jmp    80105f62 <alltraps>

80106756 <vector48>:
.globl vector48
vector48:
  pushl $0
80106756:	6a 00                	push   $0x0
  pushl $48
80106758:	6a 30                	push   $0x30
  jmp alltraps
8010675a:	e9 03 f8 ff ff       	jmp    80105f62 <alltraps>

8010675f <vector49>:
.globl vector49
vector49:
  pushl $0
8010675f:	6a 00                	push   $0x0
  pushl $49
80106761:	6a 31                	push   $0x31
  jmp alltraps
80106763:	e9 fa f7 ff ff       	jmp    80105f62 <alltraps>

80106768 <vector50>:
.globl vector50
vector50:
  pushl $0
80106768:	6a 00                	push   $0x0
  pushl $50
8010676a:	6a 32                	push   $0x32
  jmp alltraps
8010676c:	e9 f1 f7 ff ff       	jmp    80105f62 <alltraps>

80106771 <vector51>:
.globl vector51
vector51:
  pushl $0
80106771:	6a 00                	push   $0x0
  pushl $51
80106773:	6a 33                	push   $0x33
  jmp alltraps
80106775:	e9 e8 f7 ff ff       	jmp    80105f62 <alltraps>

8010677a <vector52>:
.globl vector52
vector52:
  pushl $0
8010677a:	6a 00                	push   $0x0
  pushl $52
8010677c:	6a 34                	push   $0x34
  jmp alltraps
8010677e:	e9 df f7 ff ff       	jmp    80105f62 <alltraps>

80106783 <vector53>:
.globl vector53
vector53:
  pushl $0
80106783:	6a 00                	push   $0x0
  pushl $53
80106785:	6a 35                	push   $0x35
  jmp alltraps
80106787:	e9 d6 f7 ff ff       	jmp    80105f62 <alltraps>

8010678c <vector54>:
.globl vector54
vector54:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $54
8010678e:	6a 36                	push   $0x36
  jmp alltraps
80106790:	e9 cd f7 ff ff       	jmp    80105f62 <alltraps>

80106795 <vector55>:
.globl vector55
vector55:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $55
80106797:	6a 37                	push   $0x37
  jmp alltraps
80106799:	e9 c4 f7 ff ff       	jmp    80105f62 <alltraps>

8010679e <vector56>:
.globl vector56
vector56:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $56
801067a0:	6a 38                	push   $0x38
  jmp alltraps
801067a2:	e9 bb f7 ff ff       	jmp    80105f62 <alltraps>

801067a7 <vector57>:
.globl vector57
vector57:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $57
801067a9:	6a 39                	push   $0x39
  jmp alltraps
801067ab:	e9 b2 f7 ff ff       	jmp    80105f62 <alltraps>

801067b0 <vector58>:
.globl vector58
vector58:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $58
801067b2:	6a 3a                	push   $0x3a
  jmp alltraps
801067b4:	e9 a9 f7 ff ff       	jmp    80105f62 <alltraps>

801067b9 <vector59>:
.globl vector59
vector59:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $59
801067bb:	6a 3b                	push   $0x3b
  jmp alltraps
801067bd:	e9 a0 f7 ff ff       	jmp    80105f62 <alltraps>

801067c2 <vector60>:
.globl vector60
vector60:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $60
801067c4:	6a 3c                	push   $0x3c
  jmp alltraps
801067c6:	e9 97 f7 ff ff       	jmp    80105f62 <alltraps>

801067cb <vector61>:
.globl vector61
vector61:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $61
801067cd:	6a 3d                	push   $0x3d
  jmp alltraps
801067cf:	e9 8e f7 ff ff       	jmp    80105f62 <alltraps>

801067d4 <vector62>:
.globl vector62
vector62:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $62
801067d6:	6a 3e                	push   $0x3e
  jmp alltraps
801067d8:	e9 85 f7 ff ff       	jmp    80105f62 <alltraps>

801067dd <vector63>:
.globl vector63
vector63:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $63
801067df:	6a 3f                	push   $0x3f
  jmp alltraps
801067e1:	e9 7c f7 ff ff       	jmp    80105f62 <alltraps>

801067e6 <vector64>:
.globl vector64
vector64:
  pushl $0
801067e6:	6a 00                	push   $0x0
  pushl $64
801067e8:	6a 40                	push   $0x40
  jmp alltraps
801067ea:	e9 73 f7 ff ff       	jmp    80105f62 <alltraps>

801067ef <vector65>:
.globl vector65
vector65:
  pushl $0
801067ef:	6a 00                	push   $0x0
  pushl $65
801067f1:	6a 41                	push   $0x41
  jmp alltraps
801067f3:	e9 6a f7 ff ff       	jmp    80105f62 <alltraps>

801067f8 <vector66>:
.globl vector66
vector66:
  pushl $0
801067f8:	6a 00                	push   $0x0
  pushl $66
801067fa:	6a 42                	push   $0x42
  jmp alltraps
801067fc:	e9 61 f7 ff ff       	jmp    80105f62 <alltraps>

80106801 <vector67>:
.globl vector67
vector67:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $67
80106803:	6a 43                	push   $0x43
  jmp alltraps
80106805:	e9 58 f7 ff ff       	jmp    80105f62 <alltraps>

8010680a <vector68>:
.globl vector68
vector68:
  pushl $0
8010680a:	6a 00                	push   $0x0
  pushl $68
8010680c:	6a 44                	push   $0x44
  jmp alltraps
8010680e:	e9 4f f7 ff ff       	jmp    80105f62 <alltraps>

80106813 <vector69>:
.globl vector69
vector69:
  pushl $0
80106813:	6a 00                	push   $0x0
  pushl $69
80106815:	6a 45                	push   $0x45
  jmp alltraps
80106817:	e9 46 f7 ff ff       	jmp    80105f62 <alltraps>

8010681c <vector70>:
.globl vector70
vector70:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $70
8010681e:	6a 46                	push   $0x46
  jmp alltraps
80106820:	e9 3d f7 ff ff       	jmp    80105f62 <alltraps>

80106825 <vector71>:
.globl vector71
vector71:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $71
80106827:	6a 47                	push   $0x47
  jmp alltraps
80106829:	e9 34 f7 ff ff       	jmp    80105f62 <alltraps>

8010682e <vector72>:
.globl vector72
vector72:
  pushl $0
8010682e:	6a 00                	push   $0x0
  pushl $72
80106830:	6a 48                	push   $0x48
  jmp alltraps
80106832:	e9 2b f7 ff ff       	jmp    80105f62 <alltraps>

80106837 <vector73>:
.globl vector73
vector73:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $73
80106839:	6a 49                	push   $0x49
  jmp alltraps
8010683b:	e9 22 f7 ff ff       	jmp    80105f62 <alltraps>

80106840 <vector74>:
.globl vector74
vector74:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $74
80106842:	6a 4a                	push   $0x4a
  jmp alltraps
80106844:	e9 19 f7 ff ff       	jmp    80105f62 <alltraps>

80106849 <vector75>:
.globl vector75
vector75:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $75
8010684b:	6a 4b                	push   $0x4b
  jmp alltraps
8010684d:	e9 10 f7 ff ff       	jmp    80105f62 <alltraps>

80106852 <vector76>:
.globl vector76
vector76:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $76
80106854:	6a 4c                	push   $0x4c
  jmp alltraps
80106856:	e9 07 f7 ff ff       	jmp    80105f62 <alltraps>

8010685b <vector77>:
.globl vector77
vector77:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $77
8010685d:	6a 4d                	push   $0x4d
  jmp alltraps
8010685f:	e9 fe f6 ff ff       	jmp    80105f62 <alltraps>

80106864 <vector78>:
.globl vector78
vector78:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $78
80106866:	6a 4e                	push   $0x4e
  jmp alltraps
80106868:	e9 f5 f6 ff ff       	jmp    80105f62 <alltraps>

8010686d <vector79>:
.globl vector79
vector79:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $79
8010686f:	6a 4f                	push   $0x4f
  jmp alltraps
80106871:	e9 ec f6 ff ff       	jmp    80105f62 <alltraps>

80106876 <vector80>:
.globl vector80
vector80:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $80
80106878:	6a 50                	push   $0x50
  jmp alltraps
8010687a:	e9 e3 f6 ff ff       	jmp    80105f62 <alltraps>

8010687f <vector81>:
.globl vector81
vector81:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $81
80106881:	6a 51                	push   $0x51
  jmp alltraps
80106883:	e9 da f6 ff ff       	jmp    80105f62 <alltraps>

80106888 <vector82>:
.globl vector82
vector82:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $82
8010688a:	6a 52                	push   $0x52
  jmp alltraps
8010688c:	e9 d1 f6 ff ff       	jmp    80105f62 <alltraps>

80106891 <vector83>:
.globl vector83
vector83:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $83
80106893:	6a 53                	push   $0x53
  jmp alltraps
80106895:	e9 c8 f6 ff ff       	jmp    80105f62 <alltraps>

8010689a <vector84>:
.globl vector84
vector84:
  pushl $0
8010689a:	6a 00                	push   $0x0
  pushl $84
8010689c:	6a 54                	push   $0x54
  jmp alltraps
8010689e:	e9 bf f6 ff ff       	jmp    80105f62 <alltraps>

801068a3 <vector85>:
.globl vector85
vector85:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $85
801068a5:	6a 55                	push   $0x55
  jmp alltraps
801068a7:	e9 b6 f6 ff ff       	jmp    80105f62 <alltraps>

801068ac <vector86>:
.globl vector86
vector86:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $86
801068ae:	6a 56                	push   $0x56
  jmp alltraps
801068b0:	e9 ad f6 ff ff       	jmp    80105f62 <alltraps>

801068b5 <vector87>:
.globl vector87
vector87:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $87
801068b7:	6a 57                	push   $0x57
  jmp alltraps
801068b9:	e9 a4 f6 ff ff       	jmp    80105f62 <alltraps>

801068be <vector88>:
.globl vector88
vector88:
  pushl $0
801068be:	6a 00                	push   $0x0
  pushl $88
801068c0:	6a 58                	push   $0x58
  jmp alltraps
801068c2:	e9 9b f6 ff ff       	jmp    80105f62 <alltraps>

801068c7 <vector89>:
.globl vector89
vector89:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $89
801068c9:	6a 59                	push   $0x59
  jmp alltraps
801068cb:	e9 92 f6 ff ff       	jmp    80105f62 <alltraps>

801068d0 <vector90>:
.globl vector90
vector90:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $90
801068d2:	6a 5a                	push   $0x5a
  jmp alltraps
801068d4:	e9 89 f6 ff ff       	jmp    80105f62 <alltraps>

801068d9 <vector91>:
.globl vector91
vector91:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $91
801068db:	6a 5b                	push   $0x5b
  jmp alltraps
801068dd:	e9 80 f6 ff ff       	jmp    80105f62 <alltraps>

801068e2 <vector92>:
.globl vector92
vector92:
  pushl $0
801068e2:	6a 00                	push   $0x0
  pushl $92
801068e4:	6a 5c                	push   $0x5c
  jmp alltraps
801068e6:	e9 77 f6 ff ff       	jmp    80105f62 <alltraps>

801068eb <vector93>:
.globl vector93
vector93:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $93
801068ed:	6a 5d                	push   $0x5d
  jmp alltraps
801068ef:	e9 6e f6 ff ff       	jmp    80105f62 <alltraps>

801068f4 <vector94>:
.globl vector94
vector94:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $94
801068f6:	6a 5e                	push   $0x5e
  jmp alltraps
801068f8:	e9 65 f6 ff ff       	jmp    80105f62 <alltraps>

801068fd <vector95>:
.globl vector95
vector95:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $95
801068ff:	6a 5f                	push   $0x5f
  jmp alltraps
80106901:	e9 5c f6 ff ff       	jmp    80105f62 <alltraps>

80106906 <vector96>:
.globl vector96
vector96:
  pushl $0
80106906:	6a 00                	push   $0x0
  pushl $96
80106908:	6a 60                	push   $0x60
  jmp alltraps
8010690a:	e9 53 f6 ff ff       	jmp    80105f62 <alltraps>

8010690f <vector97>:
.globl vector97
vector97:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $97
80106911:	6a 61                	push   $0x61
  jmp alltraps
80106913:	e9 4a f6 ff ff       	jmp    80105f62 <alltraps>

80106918 <vector98>:
.globl vector98
vector98:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $98
8010691a:	6a 62                	push   $0x62
  jmp alltraps
8010691c:	e9 41 f6 ff ff       	jmp    80105f62 <alltraps>

80106921 <vector99>:
.globl vector99
vector99:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $99
80106923:	6a 63                	push   $0x63
  jmp alltraps
80106925:	e9 38 f6 ff ff       	jmp    80105f62 <alltraps>

8010692a <vector100>:
.globl vector100
vector100:
  pushl $0
8010692a:	6a 00                	push   $0x0
  pushl $100
8010692c:	6a 64                	push   $0x64
  jmp alltraps
8010692e:	e9 2f f6 ff ff       	jmp    80105f62 <alltraps>

80106933 <vector101>:
.globl vector101
vector101:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $101
80106935:	6a 65                	push   $0x65
  jmp alltraps
80106937:	e9 26 f6 ff ff       	jmp    80105f62 <alltraps>

8010693c <vector102>:
.globl vector102
vector102:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $102
8010693e:	6a 66                	push   $0x66
  jmp alltraps
80106940:	e9 1d f6 ff ff       	jmp    80105f62 <alltraps>

80106945 <vector103>:
.globl vector103
vector103:
  pushl $0
80106945:	6a 00                	push   $0x0
  pushl $103
80106947:	6a 67                	push   $0x67
  jmp alltraps
80106949:	e9 14 f6 ff ff       	jmp    80105f62 <alltraps>

8010694e <vector104>:
.globl vector104
vector104:
  pushl $0
8010694e:	6a 00                	push   $0x0
  pushl $104
80106950:	6a 68                	push   $0x68
  jmp alltraps
80106952:	e9 0b f6 ff ff       	jmp    80105f62 <alltraps>

80106957 <vector105>:
.globl vector105
vector105:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $105
80106959:	6a 69                	push   $0x69
  jmp alltraps
8010695b:	e9 02 f6 ff ff       	jmp    80105f62 <alltraps>

80106960 <vector106>:
.globl vector106
vector106:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $106
80106962:	6a 6a                	push   $0x6a
  jmp alltraps
80106964:	e9 f9 f5 ff ff       	jmp    80105f62 <alltraps>

80106969 <vector107>:
.globl vector107
vector107:
  pushl $0
80106969:	6a 00                	push   $0x0
  pushl $107
8010696b:	6a 6b                	push   $0x6b
  jmp alltraps
8010696d:	e9 f0 f5 ff ff       	jmp    80105f62 <alltraps>

80106972 <vector108>:
.globl vector108
vector108:
  pushl $0
80106972:	6a 00                	push   $0x0
  pushl $108
80106974:	6a 6c                	push   $0x6c
  jmp alltraps
80106976:	e9 e7 f5 ff ff       	jmp    80105f62 <alltraps>

8010697b <vector109>:
.globl vector109
vector109:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $109
8010697d:	6a 6d                	push   $0x6d
  jmp alltraps
8010697f:	e9 de f5 ff ff       	jmp    80105f62 <alltraps>

80106984 <vector110>:
.globl vector110
vector110:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $110
80106986:	6a 6e                	push   $0x6e
  jmp alltraps
80106988:	e9 d5 f5 ff ff       	jmp    80105f62 <alltraps>

8010698d <vector111>:
.globl vector111
vector111:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $111
8010698f:	6a 6f                	push   $0x6f
  jmp alltraps
80106991:	e9 cc f5 ff ff       	jmp    80105f62 <alltraps>

80106996 <vector112>:
.globl vector112
vector112:
  pushl $0
80106996:	6a 00                	push   $0x0
  pushl $112
80106998:	6a 70                	push   $0x70
  jmp alltraps
8010699a:	e9 c3 f5 ff ff       	jmp    80105f62 <alltraps>

8010699f <vector113>:
.globl vector113
vector113:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $113
801069a1:	6a 71                	push   $0x71
  jmp alltraps
801069a3:	e9 ba f5 ff ff       	jmp    80105f62 <alltraps>

801069a8 <vector114>:
.globl vector114
vector114:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $114
801069aa:	6a 72                	push   $0x72
  jmp alltraps
801069ac:	e9 b1 f5 ff ff       	jmp    80105f62 <alltraps>

801069b1 <vector115>:
.globl vector115
vector115:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $115
801069b3:	6a 73                	push   $0x73
  jmp alltraps
801069b5:	e9 a8 f5 ff ff       	jmp    80105f62 <alltraps>

801069ba <vector116>:
.globl vector116
vector116:
  pushl $0
801069ba:	6a 00                	push   $0x0
  pushl $116
801069bc:	6a 74                	push   $0x74
  jmp alltraps
801069be:	e9 9f f5 ff ff       	jmp    80105f62 <alltraps>

801069c3 <vector117>:
.globl vector117
vector117:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $117
801069c5:	6a 75                	push   $0x75
  jmp alltraps
801069c7:	e9 96 f5 ff ff       	jmp    80105f62 <alltraps>

801069cc <vector118>:
.globl vector118
vector118:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $118
801069ce:	6a 76                	push   $0x76
  jmp alltraps
801069d0:	e9 8d f5 ff ff       	jmp    80105f62 <alltraps>

801069d5 <vector119>:
.globl vector119
vector119:
  pushl $0
801069d5:	6a 00                	push   $0x0
  pushl $119
801069d7:	6a 77                	push   $0x77
  jmp alltraps
801069d9:	e9 84 f5 ff ff       	jmp    80105f62 <alltraps>

801069de <vector120>:
.globl vector120
vector120:
  pushl $0
801069de:	6a 00                	push   $0x0
  pushl $120
801069e0:	6a 78                	push   $0x78
  jmp alltraps
801069e2:	e9 7b f5 ff ff       	jmp    80105f62 <alltraps>

801069e7 <vector121>:
.globl vector121
vector121:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $121
801069e9:	6a 79                	push   $0x79
  jmp alltraps
801069eb:	e9 72 f5 ff ff       	jmp    80105f62 <alltraps>

801069f0 <vector122>:
.globl vector122
vector122:
  pushl $0
801069f0:	6a 00                	push   $0x0
  pushl $122
801069f2:	6a 7a                	push   $0x7a
  jmp alltraps
801069f4:	e9 69 f5 ff ff       	jmp    80105f62 <alltraps>

801069f9 <vector123>:
.globl vector123
vector123:
  pushl $0
801069f9:	6a 00                	push   $0x0
  pushl $123
801069fb:	6a 7b                	push   $0x7b
  jmp alltraps
801069fd:	e9 60 f5 ff ff       	jmp    80105f62 <alltraps>

80106a02 <vector124>:
.globl vector124
vector124:
  pushl $0
80106a02:	6a 00                	push   $0x0
  pushl $124
80106a04:	6a 7c                	push   $0x7c
  jmp alltraps
80106a06:	e9 57 f5 ff ff       	jmp    80105f62 <alltraps>

80106a0b <vector125>:
.globl vector125
vector125:
  pushl $0
80106a0b:	6a 00                	push   $0x0
  pushl $125
80106a0d:	6a 7d                	push   $0x7d
  jmp alltraps
80106a0f:	e9 4e f5 ff ff       	jmp    80105f62 <alltraps>

80106a14 <vector126>:
.globl vector126
vector126:
  pushl $0
80106a14:	6a 00                	push   $0x0
  pushl $126
80106a16:	6a 7e                	push   $0x7e
  jmp alltraps
80106a18:	e9 45 f5 ff ff       	jmp    80105f62 <alltraps>

80106a1d <vector127>:
.globl vector127
vector127:
  pushl $0
80106a1d:	6a 00                	push   $0x0
  pushl $127
80106a1f:	6a 7f                	push   $0x7f
  jmp alltraps
80106a21:	e9 3c f5 ff ff       	jmp    80105f62 <alltraps>

80106a26 <vector128>:
.globl vector128
vector128:
  pushl $0
80106a26:	6a 00                	push   $0x0
  pushl $128
80106a28:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106a2d:	e9 30 f5 ff ff       	jmp    80105f62 <alltraps>

80106a32 <vector129>:
.globl vector129
vector129:
  pushl $0
80106a32:	6a 00                	push   $0x0
  pushl $129
80106a34:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106a39:	e9 24 f5 ff ff       	jmp    80105f62 <alltraps>

80106a3e <vector130>:
.globl vector130
vector130:
  pushl $0
80106a3e:	6a 00                	push   $0x0
  pushl $130
80106a40:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106a45:	e9 18 f5 ff ff       	jmp    80105f62 <alltraps>

80106a4a <vector131>:
.globl vector131
vector131:
  pushl $0
80106a4a:	6a 00                	push   $0x0
  pushl $131
80106a4c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106a51:	e9 0c f5 ff ff       	jmp    80105f62 <alltraps>

80106a56 <vector132>:
.globl vector132
vector132:
  pushl $0
80106a56:	6a 00                	push   $0x0
  pushl $132
80106a58:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106a5d:	e9 00 f5 ff ff       	jmp    80105f62 <alltraps>

80106a62 <vector133>:
.globl vector133
vector133:
  pushl $0
80106a62:	6a 00                	push   $0x0
  pushl $133
80106a64:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106a69:	e9 f4 f4 ff ff       	jmp    80105f62 <alltraps>

80106a6e <vector134>:
.globl vector134
vector134:
  pushl $0
80106a6e:	6a 00                	push   $0x0
  pushl $134
80106a70:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106a75:	e9 e8 f4 ff ff       	jmp    80105f62 <alltraps>

80106a7a <vector135>:
.globl vector135
vector135:
  pushl $0
80106a7a:	6a 00                	push   $0x0
  pushl $135
80106a7c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106a81:	e9 dc f4 ff ff       	jmp    80105f62 <alltraps>

80106a86 <vector136>:
.globl vector136
vector136:
  pushl $0
80106a86:	6a 00                	push   $0x0
  pushl $136
80106a88:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106a8d:	e9 d0 f4 ff ff       	jmp    80105f62 <alltraps>

80106a92 <vector137>:
.globl vector137
vector137:
  pushl $0
80106a92:	6a 00                	push   $0x0
  pushl $137
80106a94:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106a99:	e9 c4 f4 ff ff       	jmp    80105f62 <alltraps>

80106a9e <vector138>:
.globl vector138
vector138:
  pushl $0
80106a9e:	6a 00                	push   $0x0
  pushl $138
80106aa0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106aa5:	e9 b8 f4 ff ff       	jmp    80105f62 <alltraps>

80106aaa <vector139>:
.globl vector139
vector139:
  pushl $0
80106aaa:	6a 00                	push   $0x0
  pushl $139
80106aac:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ab1:	e9 ac f4 ff ff       	jmp    80105f62 <alltraps>

80106ab6 <vector140>:
.globl vector140
vector140:
  pushl $0
80106ab6:	6a 00                	push   $0x0
  pushl $140
80106ab8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106abd:	e9 a0 f4 ff ff       	jmp    80105f62 <alltraps>

80106ac2 <vector141>:
.globl vector141
vector141:
  pushl $0
80106ac2:	6a 00                	push   $0x0
  pushl $141
80106ac4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106ac9:	e9 94 f4 ff ff       	jmp    80105f62 <alltraps>

80106ace <vector142>:
.globl vector142
vector142:
  pushl $0
80106ace:	6a 00                	push   $0x0
  pushl $142
80106ad0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106ad5:	e9 88 f4 ff ff       	jmp    80105f62 <alltraps>

80106ada <vector143>:
.globl vector143
vector143:
  pushl $0
80106ada:	6a 00                	push   $0x0
  pushl $143
80106adc:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106ae1:	e9 7c f4 ff ff       	jmp    80105f62 <alltraps>

80106ae6 <vector144>:
.globl vector144
vector144:
  pushl $0
80106ae6:	6a 00                	push   $0x0
  pushl $144
80106ae8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106aed:	e9 70 f4 ff ff       	jmp    80105f62 <alltraps>

80106af2 <vector145>:
.globl vector145
vector145:
  pushl $0
80106af2:	6a 00                	push   $0x0
  pushl $145
80106af4:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106af9:	e9 64 f4 ff ff       	jmp    80105f62 <alltraps>

80106afe <vector146>:
.globl vector146
vector146:
  pushl $0
80106afe:	6a 00                	push   $0x0
  pushl $146
80106b00:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106b05:	e9 58 f4 ff ff       	jmp    80105f62 <alltraps>

80106b0a <vector147>:
.globl vector147
vector147:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $147
80106b0c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106b11:	e9 4c f4 ff ff       	jmp    80105f62 <alltraps>

80106b16 <vector148>:
.globl vector148
vector148:
  pushl $0
80106b16:	6a 00                	push   $0x0
  pushl $148
80106b18:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106b1d:	e9 40 f4 ff ff       	jmp    80105f62 <alltraps>

80106b22 <vector149>:
.globl vector149
vector149:
  pushl $0
80106b22:	6a 00                	push   $0x0
  pushl $149
80106b24:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106b29:	e9 34 f4 ff ff       	jmp    80105f62 <alltraps>

80106b2e <vector150>:
.globl vector150
vector150:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $150
80106b30:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106b35:	e9 28 f4 ff ff       	jmp    80105f62 <alltraps>

80106b3a <vector151>:
.globl vector151
vector151:
  pushl $0
80106b3a:	6a 00                	push   $0x0
  pushl $151
80106b3c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106b41:	e9 1c f4 ff ff       	jmp    80105f62 <alltraps>

80106b46 <vector152>:
.globl vector152
vector152:
  pushl $0
80106b46:	6a 00                	push   $0x0
  pushl $152
80106b48:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106b4d:	e9 10 f4 ff ff       	jmp    80105f62 <alltraps>

80106b52 <vector153>:
.globl vector153
vector153:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $153
80106b54:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106b59:	e9 04 f4 ff ff       	jmp    80105f62 <alltraps>

80106b5e <vector154>:
.globl vector154
vector154:
  pushl $0
80106b5e:	6a 00                	push   $0x0
  pushl $154
80106b60:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106b65:	e9 f8 f3 ff ff       	jmp    80105f62 <alltraps>

80106b6a <vector155>:
.globl vector155
vector155:
  pushl $0
80106b6a:	6a 00                	push   $0x0
  pushl $155
80106b6c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106b71:	e9 ec f3 ff ff       	jmp    80105f62 <alltraps>

80106b76 <vector156>:
.globl vector156
vector156:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $156
80106b78:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106b7d:	e9 e0 f3 ff ff       	jmp    80105f62 <alltraps>

80106b82 <vector157>:
.globl vector157
vector157:
  pushl $0
80106b82:	6a 00                	push   $0x0
  pushl $157
80106b84:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106b89:	e9 d4 f3 ff ff       	jmp    80105f62 <alltraps>

80106b8e <vector158>:
.globl vector158
vector158:
  pushl $0
80106b8e:	6a 00                	push   $0x0
  pushl $158
80106b90:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106b95:	e9 c8 f3 ff ff       	jmp    80105f62 <alltraps>

80106b9a <vector159>:
.globl vector159
vector159:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $159
80106b9c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106ba1:	e9 bc f3 ff ff       	jmp    80105f62 <alltraps>

80106ba6 <vector160>:
.globl vector160
vector160:
  pushl $0
80106ba6:	6a 00                	push   $0x0
  pushl $160
80106ba8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106bad:	e9 b0 f3 ff ff       	jmp    80105f62 <alltraps>

80106bb2 <vector161>:
.globl vector161
vector161:
  pushl $0
80106bb2:	6a 00                	push   $0x0
  pushl $161
80106bb4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106bb9:	e9 a4 f3 ff ff       	jmp    80105f62 <alltraps>

80106bbe <vector162>:
.globl vector162
vector162:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $162
80106bc0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106bc5:	e9 98 f3 ff ff       	jmp    80105f62 <alltraps>

80106bca <vector163>:
.globl vector163
vector163:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $163
80106bcc:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106bd1:	e9 8c f3 ff ff       	jmp    80105f62 <alltraps>

80106bd6 <vector164>:
.globl vector164
vector164:
  pushl $0
80106bd6:	6a 00                	push   $0x0
  pushl $164
80106bd8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106bdd:	e9 80 f3 ff ff       	jmp    80105f62 <alltraps>

80106be2 <vector165>:
.globl vector165
vector165:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $165
80106be4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106be9:	e9 74 f3 ff ff       	jmp    80105f62 <alltraps>

80106bee <vector166>:
.globl vector166
vector166:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $166
80106bf0:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106bf5:	e9 68 f3 ff ff       	jmp    80105f62 <alltraps>

80106bfa <vector167>:
.globl vector167
vector167:
  pushl $0
80106bfa:	6a 00                	push   $0x0
  pushl $167
80106bfc:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106c01:	e9 5c f3 ff ff       	jmp    80105f62 <alltraps>

80106c06 <vector168>:
.globl vector168
vector168:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $168
80106c08:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106c0d:	e9 50 f3 ff ff       	jmp    80105f62 <alltraps>

80106c12 <vector169>:
.globl vector169
vector169:
  pushl $0
80106c12:	6a 00                	push   $0x0
  pushl $169
80106c14:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106c19:	e9 44 f3 ff ff       	jmp    80105f62 <alltraps>

80106c1e <vector170>:
.globl vector170
vector170:
  pushl $0
80106c1e:	6a 00                	push   $0x0
  pushl $170
80106c20:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106c25:	e9 38 f3 ff ff       	jmp    80105f62 <alltraps>

80106c2a <vector171>:
.globl vector171
vector171:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $171
80106c2c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106c31:	e9 2c f3 ff ff       	jmp    80105f62 <alltraps>

80106c36 <vector172>:
.globl vector172
vector172:
  pushl $0
80106c36:	6a 00                	push   $0x0
  pushl $172
80106c38:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106c3d:	e9 20 f3 ff ff       	jmp    80105f62 <alltraps>

80106c42 <vector173>:
.globl vector173
vector173:
  pushl $0
80106c42:	6a 00                	push   $0x0
  pushl $173
80106c44:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106c49:	e9 14 f3 ff ff       	jmp    80105f62 <alltraps>

80106c4e <vector174>:
.globl vector174
vector174:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $174
80106c50:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106c55:	e9 08 f3 ff ff       	jmp    80105f62 <alltraps>

80106c5a <vector175>:
.globl vector175
vector175:
  pushl $0
80106c5a:	6a 00                	push   $0x0
  pushl $175
80106c5c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106c61:	e9 fc f2 ff ff       	jmp    80105f62 <alltraps>

80106c66 <vector176>:
.globl vector176
vector176:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $176
80106c68:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106c6d:	e9 f0 f2 ff ff       	jmp    80105f62 <alltraps>

80106c72 <vector177>:
.globl vector177
vector177:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $177
80106c74:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106c79:	e9 e4 f2 ff ff       	jmp    80105f62 <alltraps>

80106c7e <vector178>:
.globl vector178
vector178:
  pushl $0
80106c7e:	6a 00                	push   $0x0
  pushl $178
80106c80:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106c85:	e9 d8 f2 ff ff       	jmp    80105f62 <alltraps>

80106c8a <vector179>:
.globl vector179
vector179:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $179
80106c8c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106c91:	e9 cc f2 ff ff       	jmp    80105f62 <alltraps>

80106c96 <vector180>:
.globl vector180
vector180:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $180
80106c98:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106c9d:	e9 c0 f2 ff ff       	jmp    80105f62 <alltraps>

80106ca2 <vector181>:
.globl vector181
vector181:
  pushl $0
80106ca2:	6a 00                	push   $0x0
  pushl $181
80106ca4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106ca9:	e9 b4 f2 ff ff       	jmp    80105f62 <alltraps>

80106cae <vector182>:
.globl vector182
vector182:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $182
80106cb0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106cb5:	e9 a8 f2 ff ff       	jmp    80105f62 <alltraps>

80106cba <vector183>:
.globl vector183
vector183:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $183
80106cbc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106cc1:	e9 9c f2 ff ff       	jmp    80105f62 <alltraps>

80106cc6 <vector184>:
.globl vector184
vector184:
  pushl $0
80106cc6:	6a 00                	push   $0x0
  pushl $184
80106cc8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106ccd:	e9 90 f2 ff ff       	jmp    80105f62 <alltraps>

80106cd2 <vector185>:
.globl vector185
vector185:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $185
80106cd4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106cd9:	e9 84 f2 ff ff       	jmp    80105f62 <alltraps>

80106cde <vector186>:
.globl vector186
vector186:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $186
80106ce0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106ce5:	e9 78 f2 ff ff       	jmp    80105f62 <alltraps>

80106cea <vector187>:
.globl vector187
vector187:
  pushl $0
80106cea:	6a 00                	push   $0x0
  pushl $187
80106cec:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106cf1:	e9 6c f2 ff ff       	jmp    80105f62 <alltraps>

80106cf6 <vector188>:
.globl vector188
vector188:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $188
80106cf8:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106cfd:	e9 60 f2 ff ff       	jmp    80105f62 <alltraps>

80106d02 <vector189>:
.globl vector189
vector189:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $189
80106d04:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106d09:	e9 54 f2 ff ff       	jmp    80105f62 <alltraps>

80106d0e <vector190>:
.globl vector190
vector190:
  pushl $0
80106d0e:	6a 00                	push   $0x0
  pushl $190
80106d10:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106d15:	e9 48 f2 ff ff       	jmp    80105f62 <alltraps>

80106d1a <vector191>:
.globl vector191
vector191:
  pushl $0
80106d1a:	6a 00                	push   $0x0
  pushl $191
80106d1c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106d21:	e9 3c f2 ff ff       	jmp    80105f62 <alltraps>

80106d26 <vector192>:
.globl vector192
vector192:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $192
80106d28:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106d2d:	e9 30 f2 ff ff       	jmp    80105f62 <alltraps>

80106d32 <vector193>:
.globl vector193
vector193:
  pushl $0
80106d32:	6a 00                	push   $0x0
  pushl $193
80106d34:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106d39:	e9 24 f2 ff ff       	jmp    80105f62 <alltraps>

80106d3e <vector194>:
.globl vector194
vector194:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $194
80106d40:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106d45:	e9 18 f2 ff ff       	jmp    80105f62 <alltraps>

80106d4a <vector195>:
.globl vector195
vector195:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $195
80106d4c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106d51:	e9 0c f2 ff ff       	jmp    80105f62 <alltraps>

80106d56 <vector196>:
.globl vector196
vector196:
  pushl $0
80106d56:	6a 00                	push   $0x0
  pushl $196
80106d58:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106d5d:	e9 00 f2 ff ff       	jmp    80105f62 <alltraps>

80106d62 <vector197>:
.globl vector197
vector197:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $197
80106d64:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106d69:	e9 f4 f1 ff ff       	jmp    80105f62 <alltraps>

80106d6e <vector198>:
.globl vector198
vector198:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $198
80106d70:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106d75:	e9 e8 f1 ff ff       	jmp    80105f62 <alltraps>

80106d7a <vector199>:
.globl vector199
vector199:
  pushl $0
80106d7a:	6a 00                	push   $0x0
  pushl $199
80106d7c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106d81:	e9 dc f1 ff ff       	jmp    80105f62 <alltraps>

80106d86 <vector200>:
.globl vector200
vector200:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $200
80106d88:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106d8d:	e9 d0 f1 ff ff       	jmp    80105f62 <alltraps>

80106d92 <vector201>:
.globl vector201
vector201:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $201
80106d94:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106d99:	e9 c4 f1 ff ff       	jmp    80105f62 <alltraps>

80106d9e <vector202>:
.globl vector202
vector202:
  pushl $0
80106d9e:	6a 00                	push   $0x0
  pushl $202
80106da0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106da5:	e9 b8 f1 ff ff       	jmp    80105f62 <alltraps>

80106daa <vector203>:
.globl vector203
vector203:
  pushl $0
80106daa:	6a 00                	push   $0x0
  pushl $203
80106dac:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106db1:	e9 ac f1 ff ff       	jmp    80105f62 <alltraps>

80106db6 <vector204>:
.globl vector204
vector204:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $204
80106db8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106dbd:	e9 a0 f1 ff ff       	jmp    80105f62 <alltraps>

80106dc2 <vector205>:
.globl vector205
vector205:
  pushl $0
80106dc2:	6a 00                	push   $0x0
  pushl $205
80106dc4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106dc9:	e9 94 f1 ff ff       	jmp    80105f62 <alltraps>

80106dce <vector206>:
.globl vector206
vector206:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $206
80106dd0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106dd5:	e9 88 f1 ff ff       	jmp    80105f62 <alltraps>

80106dda <vector207>:
.globl vector207
vector207:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $207
80106ddc:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106de1:	e9 7c f1 ff ff       	jmp    80105f62 <alltraps>

80106de6 <vector208>:
.globl vector208
vector208:
  pushl $0
80106de6:	6a 00                	push   $0x0
  pushl $208
80106de8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106ded:	e9 70 f1 ff ff       	jmp    80105f62 <alltraps>

80106df2 <vector209>:
.globl vector209
vector209:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $209
80106df4:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106df9:	e9 64 f1 ff ff       	jmp    80105f62 <alltraps>

80106dfe <vector210>:
.globl vector210
vector210:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $210
80106e00:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106e05:	e9 58 f1 ff ff       	jmp    80105f62 <alltraps>

80106e0a <vector211>:
.globl vector211
vector211:
  pushl $0
80106e0a:	6a 00                	push   $0x0
  pushl $211
80106e0c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106e11:	e9 4c f1 ff ff       	jmp    80105f62 <alltraps>

80106e16 <vector212>:
.globl vector212
vector212:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $212
80106e18:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106e1d:	e9 40 f1 ff ff       	jmp    80105f62 <alltraps>

80106e22 <vector213>:
.globl vector213
vector213:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $213
80106e24:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106e29:	e9 34 f1 ff ff       	jmp    80105f62 <alltraps>

80106e2e <vector214>:
.globl vector214
vector214:
  pushl $0
80106e2e:	6a 00                	push   $0x0
  pushl $214
80106e30:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106e35:	e9 28 f1 ff ff       	jmp    80105f62 <alltraps>

80106e3a <vector215>:
.globl vector215
vector215:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $215
80106e3c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106e41:	e9 1c f1 ff ff       	jmp    80105f62 <alltraps>

80106e46 <vector216>:
.globl vector216
vector216:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $216
80106e48:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106e4d:	e9 10 f1 ff ff       	jmp    80105f62 <alltraps>

80106e52 <vector217>:
.globl vector217
vector217:
  pushl $0
80106e52:	6a 00                	push   $0x0
  pushl $217
80106e54:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106e59:	e9 04 f1 ff ff       	jmp    80105f62 <alltraps>

80106e5e <vector218>:
.globl vector218
vector218:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $218
80106e60:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106e65:	e9 f8 f0 ff ff       	jmp    80105f62 <alltraps>

80106e6a <vector219>:
.globl vector219
vector219:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $219
80106e6c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106e71:	e9 ec f0 ff ff       	jmp    80105f62 <alltraps>

80106e76 <vector220>:
.globl vector220
vector220:
  pushl $0
80106e76:	6a 00                	push   $0x0
  pushl $220
80106e78:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106e7d:	e9 e0 f0 ff ff       	jmp    80105f62 <alltraps>

80106e82 <vector221>:
.globl vector221
vector221:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $221
80106e84:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106e89:	e9 d4 f0 ff ff       	jmp    80105f62 <alltraps>

80106e8e <vector222>:
.globl vector222
vector222:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $222
80106e90:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106e95:	e9 c8 f0 ff ff       	jmp    80105f62 <alltraps>

80106e9a <vector223>:
.globl vector223
vector223:
  pushl $0
80106e9a:	6a 00                	push   $0x0
  pushl $223
80106e9c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106ea1:	e9 bc f0 ff ff       	jmp    80105f62 <alltraps>

80106ea6 <vector224>:
.globl vector224
vector224:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $224
80106ea8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106ead:	e9 b0 f0 ff ff       	jmp    80105f62 <alltraps>

80106eb2 <vector225>:
.globl vector225
vector225:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $225
80106eb4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106eb9:	e9 a4 f0 ff ff       	jmp    80105f62 <alltraps>

80106ebe <vector226>:
.globl vector226
vector226:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $226
80106ec0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106ec5:	e9 98 f0 ff ff       	jmp    80105f62 <alltraps>

80106eca <vector227>:
.globl vector227
vector227:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $227
80106ecc:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106ed1:	e9 8c f0 ff ff       	jmp    80105f62 <alltraps>

80106ed6 <vector228>:
.globl vector228
vector228:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $228
80106ed8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106edd:	e9 80 f0 ff ff       	jmp    80105f62 <alltraps>

80106ee2 <vector229>:
.globl vector229
vector229:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $229
80106ee4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106ee9:	e9 74 f0 ff ff       	jmp    80105f62 <alltraps>

80106eee <vector230>:
.globl vector230
vector230:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $230
80106ef0:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106ef5:	e9 68 f0 ff ff       	jmp    80105f62 <alltraps>

80106efa <vector231>:
.globl vector231
vector231:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $231
80106efc:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106f01:	e9 5c f0 ff ff       	jmp    80105f62 <alltraps>

80106f06 <vector232>:
.globl vector232
vector232:
  pushl $0
80106f06:	6a 00                	push   $0x0
  pushl $232
80106f08:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106f0d:	e9 50 f0 ff ff       	jmp    80105f62 <alltraps>

80106f12 <vector233>:
.globl vector233
vector233:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $233
80106f14:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106f19:	e9 44 f0 ff ff       	jmp    80105f62 <alltraps>

80106f1e <vector234>:
.globl vector234
vector234:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $234
80106f20:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106f25:	e9 38 f0 ff ff       	jmp    80105f62 <alltraps>

80106f2a <vector235>:
.globl vector235
vector235:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $235
80106f2c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106f31:	e9 2c f0 ff ff       	jmp    80105f62 <alltraps>

80106f36 <vector236>:
.globl vector236
vector236:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $236
80106f38:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106f3d:	e9 20 f0 ff ff       	jmp    80105f62 <alltraps>

80106f42 <vector237>:
.globl vector237
vector237:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $237
80106f44:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106f49:	e9 14 f0 ff ff       	jmp    80105f62 <alltraps>

80106f4e <vector238>:
.globl vector238
vector238:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $238
80106f50:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106f55:	e9 08 f0 ff ff       	jmp    80105f62 <alltraps>

80106f5a <vector239>:
.globl vector239
vector239:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $239
80106f5c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106f61:	e9 fc ef ff ff       	jmp    80105f62 <alltraps>

80106f66 <vector240>:
.globl vector240
vector240:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $240
80106f68:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106f6d:	e9 f0 ef ff ff       	jmp    80105f62 <alltraps>

80106f72 <vector241>:
.globl vector241
vector241:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $241
80106f74:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106f79:	e9 e4 ef ff ff       	jmp    80105f62 <alltraps>

80106f7e <vector242>:
.globl vector242
vector242:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $242
80106f80:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106f85:	e9 d8 ef ff ff       	jmp    80105f62 <alltraps>

80106f8a <vector243>:
.globl vector243
vector243:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $243
80106f8c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106f91:	e9 cc ef ff ff       	jmp    80105f62 <alltraps>

80106f96 <vector244>:
.globl vector244
vector244:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $244
80106f98:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106f9d:	e9 c0 ef ff ff       	jmp    80105f62 <alltraps>

80106fa2 <vector245>:
.globl vector245
vector245:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $245
80106fa4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106fa9:	e9 b4 ef ff ff       	jmp    80105f62 <alltraps>

80106fae <vector246>:
.globl vector246
vector246:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $246
80106fb0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106fb5:	e9 a8 ef ff ff       	jmp    80105f62 <alltraps>

80106fba <vector247>:
.globl vector247
vector247:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $247
80106fbc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106fc1:	e9 9c ef ff ff       	jmp    80105f62 <alltraps>

80106fc6 <vector248>:
.globl vector248
vector248:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $248
80106fc8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106fcd:	e9 90 ef ff ff       	jmp    80105f62 <alltraps>

80106fd2 <vector249>:
.globl vector249
vector249:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $249
80106fd4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106fd9:	e9 84 ef ff ff       	jmp    80105f62 <alltraps>

80106fde <vector250>:
.globl vector250
vector250:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $250
80106fe0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106fe5:	e9 78 ef ff ff       	jmp    80105f62 <alltraps>

80106fea <vector251>:
.globl vector251
vector251:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $251
80106fec:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106ff1:	e9 6c ef ff ff       	jmp    80105f62 <alltraps>

80106ff6 <vector252>:
.globl vector252
vector252:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $252
80106ff8:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106ffd:	e9 60 ef ff ff       	jmp    80105f62 <alltraps>

80107002 <vector253>:
.globl vector253
vector253:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $253
80107004:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107009:	e9 54 ef ff ff       	jmp    80105f62 <alltraps>

8010700e <vector254>:
.globl vector254
vector254:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $254
80107010:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107015:	e9 48 ef ff ff       	jmp    80105f62 <alltraps>

8010701a <vector255>:
.globl vector255
vector255:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $255
8010701c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107021:	e9 3c ef ff ff       	jmp    80105f62 <alltraps>

80107026 <lgdt>:
{
80107026:	55                   	push   %ebp
80107027:	89 e5                	mov    %esp,%ebp
80107029:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010702c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010702f:	83 e8 01             	sub    $0x1,%eax
80107032:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107036:	8b 45 08             	mov    0x8(%ebp),%eax
80107039:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010703d:	8b 45 08             	mov    0x8(%ebp),%eax
80107040:	c1 e8 10             	shr    $0x10,%eax
80107043:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107047:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010704a:	0f 01 10             	lgdtl  (%eax)
}
8010704d:	90                   	nop
8010704e:	c9                   	leave  
8010704f:	c3                   	ret    

80107050 <ltr>:
{
80107050:	55                   	push   %ebp
80107051:	89 e5                	mov    %esp,%ebp
80107053:	83 ec 04             	sub    $0x4,%esp
80107056:	8b 45 08             	mov    0x8(%ebp),%eax
80107059:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010705d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107061:	0f 00 d8             	ltr    %ax
}
80107064:	90                   	nop
80107065:	c9                   	leave  
80107066:	c3                   	ret    

80107067 <lcr3>:

static inline void
lcr3(uint val)
{
80107067:	55                   	push   %ebp
80107068:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010706a:	8b 45 08             	mov    0x8(%ebp),%eax
8010706d:	0f 22 d8             	mov    %eax,%cr3
}
80107070:	90                   	nop
80107071:	5d                   	pop    %ebp
80107072:	c3                   	ret    

80107073 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107073:	f3 0f 1e fb          	endbr32 
80107077:	55                   	push   %ebp
80107078:	89 e5                	mov    %esp,%ebp
8010707a:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010707d:	e8 8c ca ff ff       	call   80103b0e <cpuid>
80107082:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107088:	05 c0 7c 19 80       	add    $0x80197cc0,%eax
8010708d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107093:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709c:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801070a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a5:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801070a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ac:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070b0:	83 e2 f0             	and    $0xfffffff0,%edx
801070b3:	83 ca 0a             	or     $0xa,%edx
801070b6:	88 50 7d             	mov    %dl,0x7d(%eax)
801070b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070bc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070c0:	83 ca 10             	or     $0x10,%edx
801070c3:	88 50 7d             	mov    %dl,0x7d(%eax)
801070c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070cd:	83 e2 9f             	and    $0xffffff9f,%edx
801070d0:	88 50 7d             	mov    %dl,0x7d(%eax)
801070d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801070da:	83 ca 80             	or     $0xffffff80,%edx
801070dd:	88 50 7d             	mov    %dl,0x7d(%eax)
801070e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801070e7:	83 ca 0f             	or     $0xf,%edx
801070ea:	88 50 7e             	mov    %dl,0x7e(%eax)
801070ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801070f4:	83 e2 ef             	and    $0xffffffef,%edx
801070f7:	88 50 7e             	mov    %dl,0x7e(%eax)
801070fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070fd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107101:	83 e2 df             	and    $0xffffffdf,%edx
80107104:	88 50 7e             	mov    %dl,0x7e(%eax)
80107107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010710e:	83 ca 40             	or     $0x40,%edx
80107111:	88 50 7e             	mov    %dl,0x7e(%eax)
80107114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107117:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010711b:	83 ca 80             	or     $0xffffff80,%edx
8010711e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107124:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107132:	ff ff 
80107134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107137:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010713e:	00 00 
80107140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107143:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010714a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010714d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107154:	83 e2 f0             	and    $0xfffffff0,%edx
80107157:	83 ca 02             	or     $0x2,%edx
8010715a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107163:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010716a:	83 ca 10             	or     $0x10,%edx
8010716d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107176:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010717d:	83 e2 9f             	and    $0xffffff9f,%edx
80107180:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107189:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107190:	83 ca 80             	or     $0xffffff80,%edx
80107193:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071a3:	83 ca 0f             	or     $0xf,%edx
801071a6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071af:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071b6:	83 e2 ef             	and    $0xffffffef,%edx
801071b9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071c9:	83 e2 df             	and    $0xffffffdf,%edx
801071cc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071dc:	83 ca 40             	or     $0x40,%edx
801071df:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801071ef:	83 ca 80             	or     $0xffffff80,%edx
801071f2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801071f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fb:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107205:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010720c:	ff ff 
8010720e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107211:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107218:	00 00 
8010721a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010721d:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107224:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107227:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010722e:	83 e2 f0             	and    $0xfffffff0,%edx
80107231:	83 ca 0a             	or     $0xa,%edx
80107234:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010723a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107244:	83 ca 10             	or     $0x10,%edx
80107247:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010724d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107250:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107257:	83 ca 60             	or     $0x60,%edx
8010725a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107263:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010726a:	83 ca 80             	or     $0xffffff80,%edx
8010726d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107276:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010727d:	83 ca 0f             	or     $0xf,%edx
80107280:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107289:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107290:	83 e2 ef             	and    $0xffffffef,%edx
80107293:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072a3:	83 e2 df             	and    $0xffffffdf,%edx
801072a6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072af:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072b6:	83 ca 40             	or     $0x40,%edx
801072b9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801072c9:	83 ca 80             	or     $0xffffff80,%edx
801072cc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801072d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d5:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801072dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072df:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801072e6:	ff ff 
801072e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072eb:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801072f2:	00 00 
801072f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f7:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801072fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107301:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107308:	83 e2 f0             	and    $0xfffffff0,%edx
8010730b:	83 ca 02             	or     $0x2,%edx
8010730e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107317:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010731e:	83 ca 10             	or     $0x10,%edx
80107321:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010732a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107331:	83 ca 60             	or     $0x60,%edx
80107334:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010733a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010733d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107344:	83 ca 80             	or     $0xffffff80,%edx
80107347:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010734d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107350:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107357:	83 ca 0f             	or     $0xf,%edx
8010735a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107363:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010736a:	83 e2 ef             	and    $0xffffffef,%edx
8010736d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107376:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010737d:	83 e2 df             	and    $0xffffffdf,%edx
80107380:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107389:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107390:	83 ca 40             	or     $0x40,%edx
80107393:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801073a3:	83 ca 80             	or     $0xffffff80,%edx
801073a6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801073ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073af:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801073b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b9:	83 c0 70             	add    $0x70,%eax
801073bc:	83 ec 08             	sub    $0x8,%esp
801073bf:	6a 30                	push   $0x30
801073c1:	50                   	push   %eax
801073c2:	e8 5f fc ff ff       	call   80107026 <lgdt>
801073c7:	83 c4 10             	add    $0x10,%esp
}
801073ca:	90                   	nop
801073cb:	c9                   	leave  
801073cc:	c3                   	ret    

801073cd <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801073cd:	f3 0f 1e fb          	endbr32 
801073d1:	55                   	push   %ebp
801073d2:	89 e5                	mov    %esp,%ebp
801073d4:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801073d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801073da:	c1 e8 16             	shr    $0x16,%eax
801073dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801073e4:	8b 45 08             	mov    0x8(%ebp),%eax
801073e7:	01 d0                	add    %edx,%eax
801073e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801073ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073ef:	8b 00                	mov    (%eax),%eax
801073f1:	83 e0 01             	and    $0x1,%eax
801073f4:	85 c0                	test   %eax,%eax
801073f6:	74 14                	je     8010740c <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801073f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073fb:	8b 00                	mov    (%eax),%eax
801073fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107402:	05 00 00 00 80       	add    $0x80000000,%eax
80107407:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010740a:	eb 42                	jmp    8010744e <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010740c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107410:	74 0e                	je     80107420 <walkpgdir+0x53>
80107412:	e8 7b b4 ff ff       	call   80102892 <kalloc>
80107417:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010741a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010741e:	75 07                	jne    80107427 <walkpgdir+0x5a>
      return 0;
80107420:	b8 00 00 00 00       	mov    $0x0,%eax
80107425:	eb 3e                	jmp    80107465 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107427:	83 ec 04             	sub    $0x4,%esp
8010742a:	68 00 10 00 00       	push   $0x1000
8010742f:	6a 00                	push   $0x0
80107431:	ff 75 f4             	pushl  -0xc(%ebp)
80107434:	e8 1b d7 ff ff       	call   80104b54 <memset>
80107439:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010743c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743f:	05 00 00 00 80       	add    $0x80000000,%eax
80107444:	83 c8 07             	or     $0x7,%eax
80107447:	89 c2                	mov    %eax,%edx
80107449:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010744c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010744e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107451:	c1 e8 0c             	shr    $0xc,%eax
80107454:	25 ff 03 00 00       	and    $0x3ff,%eax
80107459:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107463:	01 d0                	add    %edx,%eax
}
80107465:	c9                   	leave  
80107466:	c3                   	ret    

80107467 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107467:	f3 0f 1e fb          	endbr32 
8010746b:	55                   	push   %ebp
8010746c:	89 e5                	mov    %esp,%ebp
8010746e:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107471:	8b 45 0c             	mov    0xc(%ebp),%eax
80107474:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107479:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010747c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010747f:	8b 45 10             	mov    0x10(%ebp),%eax
80107482:	01 d0                	add    %edx,%eax
80107484:	83 e8 01             	sub    $0x1,%eax
80107487:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010748c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010748f:	83 ec 04             	sub    $0x4,%esp
80107492:	6a 01                	push   $0x1
80107494:	ff 75 f4             	pushl  -0xc(%ebp)
80107497:	ff 75 08             	pushl  0x8(%ebp)
8010749a:	e8 2e ff ff ff       	call   801073cd <walkpgdir>
8010749f:	83 c4 10             	add    $0x10,%esp
801074a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801074a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801074a9:	75 07                	jne    801074b2 <mappages+0x4b>
      return -1;
801074ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074b0:	eb 47                	jmp    801074f9 <mappages+0x92>
    if(*pte & PTE_P)
801074b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801074b5:	8b 00                	mov    (%eax),%eax
801074b7:	83 e0 01             	and    $0x1,%eax
801074ba:	85 c0                	test   %eax,%eax
801074bc:	74 0d                	je     801074cb <mappages+0x64>
      panic("remap");
801074be:	83 ec 0c             	sub    $0xc,%esp
801074c1:	68 a8 a8 10 80       	push   $0x8010a8a8
801074c6:	e8 fa 90 ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
801074cb:	8b 45 18             	mov    0x18(%ebp),%eax
801074ce:	0b 45 14             	or     0x14(%ebp),%eax
801074d1:	83 c8 01             	or     $0x1,%eax
801074d4:	89 c2                	mov    %eax,%edx
801074d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801074d9:	89 10                	mov    %edx,(%eax)
    if(a == last)
801074db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074de:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801074e1:	74 10                	je     801074f3 <mappages+0x8c>
      break;
    a += PGSIZE;
801074e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801074ea:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801074f1:	eb 9c                	jmp    8010748f <mappages+0x28>
      break;
801074f3:	90                   	nop
  }
  return 0;
801074f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801074f9:	c9                   	leave  
801074fa:	c3                   	ret    

801074fb <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801074fb:	f3 0f 1e fb          	endbr32 
801074ff:	55                   	push   %ebp
80107500:	89 e5                	mov    %esp,%ebp
80107502:	53                   	push   %ebx
80107503:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107506:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010750d:	a1 8c 7f 19 80       	mov    0x80197f8c,%eax
80107512:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107517:	29 c2                	sub    %eax,%edx
80107519:	89 d0                	mov    %edx,%eax
8010751b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010751e:	a1 84 7f 19 80       	mov    0x80197f84,%eax
80107523:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107526:	8b 15 84 7f 19 80    	mov    0x80197f84,%edx
8010752c:	a1 8c 7f 19 80       	mov    0x80197f8c,%eax
80107531:	01 d0                	add    %edx,%eax
80107533:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107536:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010753d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107540:	83 c0 30             	add    $0x30,%eax
80107543:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107546:	89 10                	mov    %edx,(%eax)
80107548:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010754b:	89 50 04             	mov    %edx,0x4(%eax)
8010754e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107551:	89 50 08             	mov    %edx,0x8(%eax)
80107554:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107557:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010755a:	e8 33 b3 ff ff       	call   80102892 <kalloc>
8010755f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107562:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107566:	75 07                	jne    8010756f <setupkvm+0x74>
    return 0;
80107568:	b8 00 00 00 00       	mov    $0x0,%eax
8010756d:	eb 78                	jmp    801075e7 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
8010756f:	83 ec 04             	sub    $0x4,%esp
80107572:	68 00 10 00 00       	push   $0x1000
80107577:	6a 00                	push   $0x0
80107579:	ff 75 f0             	pushl  -0x10(%ebp)
8010757c:	e8 d3 d5 ff ff       	call   80104b54 <memset>
80107581:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107584:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
8010758b:	eb 4e                	jmp    801075db <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010758d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107590:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107596:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759c:	8b 58 08             	mov    0x8(%eax),%ebx
8010759f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a2:	8b 40 04             	mov    0x4(%eax),%eax
801075a5:	29 c3                	sub    %eax,%ebx
801075a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075aa:	8b 00                	mov    (%eax),%eax
801075ac:	83 ec 0c             	sub    $0xc,%esp
801075af:	51                   	push   %ecx
801075b0:	52                   	push   %edx
801075b1:	53                   	push   %ebx
801075b2:	50                   	push   %eax
801075b3:	ff 75 f0             	pushl  -0x10(%ebp)
801075b6:	e8 ac fe ff ff       	call   80107467 <mappages>
801075bb:	83 c4 20             	add    $0x20,%esp
801075be:	85 c0                	test   %eax,%eax
801075c0:	79 15                	jns    801075d7 <setupkvm+0xdc>
      freevm(pgdir);
801075c2:	83 ec 0c             	sub    $0xc,%esp
801075c5:	ff 75 f0             	pushl  -0x10(%ebp)
801075c8:	e8 11 05 00 00       	call   80107ade <freevm>
801075cd:	83 c4 10             	add    $0x10,%esp
      return 0;
801075d0:	b8 00 00 00 00       	mov    $0x0,%eax
801075d5:	eb 10                	jmp    801075e7 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801075d7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801075db:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801075e2:	72 a9                	jb     8010758d <setupkvm+0x92>
    }
  return pgdir;
801075e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801075e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801075ea:	c9                   	leave  
801075eb:	c3                   	ret    

801075ec <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801075ec:	f3 0f 1e fb          	endbr32 
801075f0:	55                   	push   %ebp
801075f1:	89 e5                	mov    %esp,%ebp
801075f3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801075f6:	e8 00 ff ff ff       	call   801074fb <setupkvm>
801075fb:	a3 84 7c 19 80       	mov    %eax,0x80197c84
  switchkvm();
80107600:	e8 03 00 00 00       	call   80107608 <switchkvm>
}
80107605:	90                   	nop
80107606:	c9                   	leave  
80107607:	c3                   	ret    

80107608 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107608:	f3 0f 1e fb          	endbr32 
8010760c:	55                   	push   %ebp
8010760d:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010760f:	a1 84 7c 19 80       	mov    0x80197c84,%eax
80107614:	05 00 00 00 80       	add    $0x80000000,%eax
80107619:	50                   	push   %eax
8010761a:	e8 48 fa ff ff       	call   80107067 <lcr3>
8010761f:	83 c4 04             	add    $0x4,%esp
}
80107622:	90                   	nop
80107623:	c9                   	leave  
80107624:	c3                   	ret    

80107625 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107625:	f3 0f 1e fb          	endbr32 
80107629:	55                   	push   %ebp
8010762a:	89 e5                	mov    %esp,%ebp
8010762c:	56                   	push   %esi
8010762d:	53                   	push   %ebx
8010762e:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107631:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107635:	75 0d                	jne    80107644 <switchuvm+0x1f>
    panic("switchuvm: no process");
80107637:	83 ec 0c             	sub    $0xc,%esp
8010763a:	68 ae a8 10 80       	push   $0x8010a8ae
8010763f:	e8 81 8f ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
80107644:	8b 45 08             	mov    0x8(%ebp),%eax
80107647:	8b 40 08             	mov    0x8(%eax),%eax
8010764a:	85 c0                	test   %eax,%eax
8010764c:	75 0d                	jne    8010765b <switchuvm+0x36>
    panic("switchuvm: no kstack");
8010764e:	83 ec 0c             	sub    $0xc,%esp
80107651:	68 c4 a8 10 80       	push   $0x8010a8c4
80107656:	e8 6a 8f ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
8010765b:	8b 45 08             	mov    0x8(%ebp),%eax
8010765e:	8b 40 04             	mov    0x4(%eax),%eax
80107661:	85 c0                	test   %eax,%eax
80107663:	75 0d                	jne    80107672 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107665:	83 ec 0c             	sub    $0xc,%esp
80107668:	68 d9 a8 10 80       	push   $0x8010a8d9
8010766d:	e8 53 8f ff ff       	call   801005c5 <panic>

  pushcli();
80107672:	e8 ca d3 ff ff       	call   80104a41 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107677:	e8 b1 c4 ff ff       	call   80103b2d <mycpu>
8010767c:	89 c3                	mov    %eax,%ebx
8010767e:	e8 aa c4 ff ff       	call   80103b2d <mycpu>
80107683:	83 c0 08             	add    $0x8,%eax
80107686:	89 c6                	mov    %eax,%esi
80107688:	e8 a0 c4 ff ff       	call   80103b2d <mycpu>
8010768d:	83 c0 08             	add    $0x8,%eax
80107690:	c1 e8 10             	shr    $0x10,%eax
80107693:	88 45 f7             	mov    %al,-0x9(%ebp)
80107696:	e8 92 c4 ff ff       	call   80103b2d <mycpu>
8010769b:	83 c0 08             	add    $0x8,%eax
8010769e:	c1 e8 18             	shr    $0x18,%eax
801076a1:	89 c2                	mov    %eax,%edx
801076a3:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801076aa:	67 00 
801076ac:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801076b3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801076b7:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801076bd:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076c4:	83 e0 f0             	and    $0xfffffff0,%eax
801076c7:	83 c8 09             	or     $0x9,%eax
801076ca:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076d0:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076d7:	83 c8 10             	or     $0x10,%eax
801076da:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076e0:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076e7:	83 e0 9f             	and    $0xffffff9f,%eax
801076ea:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801076f0:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801076f7:	83 c8 80             	or     $0xffffff80,%eax
801076fa:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107700:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107707:	83 e0 f0             	and    $0xfffffff0,%eax
8010770a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107710:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107717:	83 e0 ef             	and    $0xffffffef,%eax
8010771a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107720:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107727:	83 e0 df             	and    $0xffffffdf,%eax
8010772a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107730:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107737:	83 c8 40             	or     $0x40,%eax
8010773a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107740:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107747:	83 e0 7f             	and    $0x7f,%eax
8010774a:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107750:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107756:	e8 d2 c3 ff ff       	call   80103b2d <mycpu>
8010775b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107762:	83 e2 ef             	and    $0xffffffef,%edx
80107765:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010776b:	e8 bd c3 ff ff       	call   80103b2d <mycpu>
80107770:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107776:	8b 45 08             	mov    0x8(%ebp),%eax
80107779:	8b 40 08             	mov    0x8(%eax),%eax
8010777c:	89 c3                	mov    %eax,%ebx
8010777e:	e8 aa c3 ff ff       	call   80103b2d <mycpu>
80107783:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107789:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010778c:	e8 9c c3 ff ff       	call   80103b2d <mycpu>
80107791:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107797:	83 ec 0c             	sub    $0xc,%esp
8010779a:	6a 28                	push   $0x28
8010779c:	e8 af f8 ff ff       	call   80107050 <ltr>
801077a1:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801077a4:	8b 45 08             	mov    0x8(%ebp),%eax
801077a7:	8b 40 04             	mov    0x4(%eax),%eax
801077aa:	05 00 00 00 80       	add    $0x80000000,%eax
801077af:	83 ec 0c             	sub    $0xc,%esp
801077b2:	50                   	push   %eax
801077b3:	e8 af f8 ff ff       	call   80107067 <lcr3>
801077b8:	83 c4 10             	add    $0x10,%esp
  popcli();
801077bb:	e8 d2 d2 ff ff       	call   80104a92 <popcli>
}
801077c0:	90                   	nop
801077c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801077c4:	5b                   	pop    %ebx
801077c5:	5e                   	pop    %esi
801077c6:	5d                   	pop    %ebp
801077c7:	c3                   	ret    

801077c8 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801077c8:	f3 0f 1e fb          	endbr32 
801077cc:	55                   	push   %ebp
801077cd:	89 e5                	mov    %esp,%ebp
801077cf:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801077d2:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801077d9:	76 0d                	jbe    801077e8 <inituvm+0x20>
    panic("inituvm: more than a page");
801077db:	83 ec 0c             	sub    $0xc,%esp
801077de:	68 ed a8 10 80       	push   $0x8010a8ed
801077e3:	e8 dd 8d ff ff       	call   801005c5 <panic>
  mem = kalloc();
801077e8:	e8 a5 b0 ff ff       	call   80102892 <kalloc>
801077ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801077f0:	83 ec 04             	sub    $0x4,%esp
801077f3:	68 00 10 00 00       	push   $0x1000
801077f8:	6a 00                	push   $0x0
801077fa:	ff 75 f4             	pushl  -0xc(%ebp)
801077fd:	e8 52 d3 ff ff       	call   80104b54 <memset>
80107802:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107808:	05 00 00 00 80       	add    $0x80000000,%eax
8010780d:	83 ec 0c             	sub    $0xc,%esp
80107810:	6a 06                	push   $0x6
80107812:	50                   	push   %eax
80107813:	68 00 10 00 00       	push   $0x1000
80107818:	6a 00                	push   $0x0
8010781a:	ff 75 08             	pushl  0x8(%ebp)
8010781d:	e8 45 fc ff ff       	call   80107467 <mappages>
80107822:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107825:	83 ec 04             	sub    $0x4,%esp
80107828:	ff 75 10             	pushl  0x10(%ebp)
8010782b:	ff 75 0c             	pushl  0xc(%ebp)
8010782e:	ff 75 f4             	pushl  -0xc(%ebp)
80107831:	e8 e5 d3 ff ff       	call   80104c1b <memmove>
80107836:	83 c4 10             	add    $0x10,%esp
}
80107839:	90                   	nop
8010783a:	c9                   	leave  
8010783b:	c3                   	ret    

8010783c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010783c:	f3 0f 1e fb          	endbr32 
80107840:	55                   	push   %ebp
80107841:	89 e5                	mov    %esp,%ebp
80107843:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107846:	8b 45 0c             	mov    0xc(%ebp),%eax
80107849:	25 ff 0f 00 00       	and    $0xfff,%eax
8010784e:	85 c0                	test   %eax,%eax
80107850:	74 0d                	je     8010785f <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107852:	83 ec 0c             	sub    $0xc,%esp
80107855:	68 08 a9 10 80       	push   $0x8010a908
8010785a:	e8 66 8d ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010785f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107866:	e9 8f 00 00 00       	jmp    801078fa <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010786b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010786e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107871:	01 d0                	add    %edx,%eax
80107873:	83 ec 04             	sub    $0x4,%esp
80107876:	6a 00                	push   $0x0
80107878:	50                   	push   %eax
80107879:	ff 75 08             	pushl  0x8(%ebp)
8010787c:	e8 4c fb ff ff       	call   801073cd <walkpgdir>
80107881:	83 c4 10             	add    $0x10,%esp
80107884:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107887:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010788b:	75 0d                	jne    8010789a <loaduvm+0x5e>
      panic("loaduvm: address should exist");
8010788d:	83 ec 0c             	sub    $0xc,%esp
80107890:	68 2b a9 10 80       	push   $0x8010a92b
80107895:	e8 2b 8d ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
8010789a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010789d:	8b 00                	mov    (%eax),%eax
8010789f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801078a7:	8b 45 18             	mov    0x18(%ebp),%eax
801078aa:	2b 45 f4             	sub    -0xc(%ebp),%eax
801078ad:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801078b2:	77 0b                	ja     801078bf <loaduvm+0x83>
      n = sz - i;
801078b4:	8b 45 18             	mov    0x18(%ebp),%eax
801078b7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801078ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801078bd:	eb 07                	jmp    801078c6 <loaduvm+0x8a>
    else
      n = PGSIZE;
801078bf:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801078c6:	8b 55 14             	mov    0x14(%ebp),%edx
801078c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cc:	01 d0                	add    %edx,%eax
801078ce:	8b 55 e8             	mov    -0x18(%ebp),%edx
801078d1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801078d7:	ff 75 f0             	pushl  -0x10(%ebp)
801078da:	50                   	push   %eax
801078db:	52                   	push   %edx
801078dc:	ff 75 10             	pushl  0x10(%ebp)
801078df:	e8 a0 a6 ff ff       	call   80101f84 <readi>
801078e4:	83 c4 10             	add    $0x10,%esp
801078e7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801078ea:	74 07                	je     801078f3 <loaduvm+0xb7>
      return -1;
801078ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078f1:	eb 18                	jmp    8010790b <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
801078f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fd:	3b 45 18             	cmp    0x18(%ebp),%eax
80107900:	0f 82 65 ff ff ff    	jb     8010786b <loaduvm+0x2f>
  }
  return 0;
80107906:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010790b:	c9                   	leave  
8010790c:	c3                   	ret    

8010790d <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010790d:	f3 0f 1e fb          	endbr32 
80107911:	55                   	push   %ebp
80107912:	89 e5                	mov    %esp,%ebp
80107914:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107917:	8b 45 10             	mov    0x10(%ebp),%eax
8010791a:	85 c0                	test   %eax,%eax
8010791c:	79 0a                	jns    80107928 <allocuvm+0x1b>
    return 0;
8010791e:	b8 00 00 00 00       	mov    $0x0,%eax
80107923:	e9 ec 00 00 00       	jmp    80107a14 <allocuvm+0x107>
  if(newsz < oldsz)
80107928:	8b 45 10             	mov    0x10(%ebp),%eax
8010792b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010792e:	73 08                	jae    80107938 <allocuvm+0x2b>
    return oldsz;
80107930:	8b 45 0c             	mov    0xc(%ebp),%eax
80107933:	e9 dc 00 00 00       	jmp    80107a14 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107938:	8b 45 0c             	mov    0xc(%ebp),%eax
8010793b:	05 ff 0f 00 00       	add    $0xfff,%eax
80107940:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107945:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107948:	e9 b8 00 00 00       	jmp    80107a05 <allocuvm+0xf8>
    mem = kalloc();
8010794d:	e8 40 af ff ff       	call   80102892 <kalloc>
80107952:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107955:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107959:	75 2e                	jne    80107989 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
8010795b:	83 ec 0c             	sub    $0xc,%esp
8010795e:	68 49 a9 10 80       	push   $0x8010a949
80107963:	e8 a4 8a ff ff       	call   8010040c <cprintf>
80107968:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010796b:	83 ec 04             	sub    $0x4,%esp
8010796e:	ff 75 0c             	pushl  0xc(%ebp)
80107971:	ff 75 10             	pushl  0x10(%ebp)
80107974:	ff 75 08             	pushl  0x8(%ebp)
80107977:	e8 9a 00 00 00       	call   80107a16 <deallocuvm>
8010797c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010797f:	b8 00 00 00 00       	mov    $0x0,%eax
80107984:	e9 8b 00 00 00       	jmp    80107a14 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107989:	83 ec 04             	sub    $0x4,%esp
8010798c:	68 00 10 00 00       	push   $0x1000
80107991:	6a 00                	push   $0x0
80107993:	ff 75 f0             	pushl  -0x10(%ebp)
80107996:	e8 b9 d1 ff ff       	call   80104b54 <memset>
8010799b:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010799e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079a1:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801079a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079aa:	83 ec 0c             	sub    $0xc,%esp
801079ad:	6a 06                	push   $0x6
801079af:	52                   	push   %edx
801079b0:	68 00 10 00 00       	push   $0x1000
801079b5:	50                   	push   %eax
801079b6:	ff 75 08             	pushl  0x8(%ebp)
801079b9:	e8 a9 fa ff ff       	call   80107467 <mappages>
801079be:	83 c4 20             	add    $0x20,%esp
801079c1:	85 c0                	test   %eax,%eax
801079c3:	79 39                	jns    801079fe <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
801079c5:	83 ec 0c             	sub    $0xc,%esp
801079c8:	68 61 a9 10 80       	push   $0x8010a961
801079cd:	e8 3a 8a ff ff       	call   8010040c <cprintf>
801079d2:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801079d5:	83 ec 04             	sub    $0x4,%esp
801079d8:	ff 75 0c             	pushl  0xc(%ebp)
801079db:	ff 75 10             	pushl  0x10(%ebp)
801079de:	ff 75 08             	pushl  0x8(%ebp)
801079e1:	e8 30 00 00 00       	call   80107a16 <deallocuvm>
801079e6:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801079e9:	83 ec 0c             	sub    $0xc,%esp
801079ec:	ff 75 f0             	pushl  -0x10(%ebp)
801079ef:	e8 00 ae ff ff       	call   801027f4 <kfree>
801079f4:	83 c4 10             	add    $0x10,%esp
      return 0;
801079f7:	b8 00 00 00 00       	mov    $0x0,%eax
801079fc:	eb 16                	jmp    80107a14 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
801079fe:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a08:	3b 45 10             	cmp    0x10(%ebp),%eax
80107a0b:	0f 82 3c ff ff ff    	jb     8010794d <allocuvm+0x40>
    }
  }
  return newsz;
80107a11:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107a14:	c9                   	leave  
80107a15:	c3                   	ret    

80107a16 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107a16:	f3 0f 1e fb          	endbr32 
80107a1a:	55                   	push   %ebp
80107a1b:	89 e5                	mov    %esp,%ebp
80107a1d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107a20:	8b 45 10             	mov    0x10(%ebp),%eax
80107a23:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a26:	72 08                	jb     80107a30 <deallocuvm+0x1a>
    return oldsz;
80107a28:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a2b:	e9 ac 00 00 00       	jmp    80107adc <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107a30:	8b 45 10             	mov    0x10(%ebp),%eax
80107a33:	05 ff 0f 00 00       	add    $0xfff,%eax
80107a38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107a40:	e9 88 00 00 00       	jmp    80107acd <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a48:	83 ec 04             	sub    $0x4,%esp
80107a4b:	6a 00                	push   $0x0
80107a4d:	50                   	push   %eax
80107a4e:	ff 75 08             	pushl  0x8(%ebp)
80107a51:	e8 77 f9 ff ff       	call   801073cd <walkpgdir>
80107a56:	83 c4 10             	add    $0x10,%esp
80107a59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107a5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a60:	75 16                	jne    80107a78 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a65:	c1 e8 16             	shr    $0x16,%eax
80107a68:	83 c0 01             	add    $0x1,%eax
80107a6b:	c1 e0 16             	shl    $0x16,%eax
80107a6e:	2d 00 10 00 00       	sub    $0x1000,%eax
80107a73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107a76:	eb 4e                	jmp    80107ac6 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a7b:	8b 00                	mov    (%eax),%eax
80107a7d:	83 e0 01             	and    $0x1,%eax
80107a80:	85 c0                	test   %eax,%eax
80107a82:	74 42                	je     80107ac6 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a87:	8b 00                	mov    (%eax),%eax
80107a89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107a91:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a95:	75 0d                	jne    80107aa4 <deallocuvm+0x8e>
        panic("kfree");
80107a97:	83 ec 0c             	sub    $0xc,%esp
80107a9a:	68 7d a9 10 80       	push   $0x8010a97d
80107a9f:	e8 21 8b ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80107aa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107aa7:	05 00 00 00 80       	add    $0x80000000,%eax
80107aac:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107aaf:	83 ec 0c             	sub    $0xc,%esp
80107ab2:	ff 75 e8             	pushl  -0x18(%ebp)
80107ab5:	e8 3a ad ff ff       	call   801027f4 <kfree>
80107aba:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ac0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107ac6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ad3:	0f 82 6c ff ff ff    	jb     80107a45 <deallocuvm+0x2f>
    }
  }
  return newsz;
80107ad9:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107adc:	c9                   	leave  
80107add:	c3                   	ret    

80107ade <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107ade:	f3 0f 1e fb          	endbr32 
80107ae2:	55                   	push   %ebp
80107ae3:	89 e5                	mov    %esp,%ebp
80107ae5:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107ae8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107aec:	75 0d                	jne    80107afb <freevm+0x1d>
    panic("freevm: no pgdir");
80107aee:	83 ec 0c             	sub    $0xc,%esp
80107af1:	68 83 a9 10 80       	push   $0x8010a983
80107af6:	e8 ca 8a ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107afb:	83 ec 04             	sub    $0x4,%esp
80107afe:	6a 00                	push   $0x0
80107b00:	68 00 00 00 80       	push   $0x80000000
80107b05:	ff 75 08             	pushl  0x8(%ebp)
80107b08:	e8 09 ff ff ff       	call   80107a16 <deallocuvm>
80107b0d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107b10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b17:	eb 48                	jmp    80107b61 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b23:	8b 45 08             	mov    0x8(%ebp),%eax
80107b26:	01 d0                	add    %edx,%eax
80107b28:	8b 00                	mov    (%eax),%eax
80107b2a:	83 e0 01             	and    $0x1,%eax
80107b2d:	85 c0                	test   %eax,%eax
80107b2f:	74 2c                	je     80107b5d <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80107b3e:	01 d0                	add    %edx,%eax
80107b40:	8b 00                	mov    (%eax),%eax
80107b42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b47:	05 00 00 00 80       	add    $0x80000000,%eax
80107b4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107b4f:	83 ec 0c             	sub    $0xc,%esp
80107b52:	ff 75 f0             	pushl  -0x10(%ebp)
80107b55:	e8 9a ac ff ff       	call   801027f4 <kfree>
80107b5a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107b5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b61:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107b68:	76 af                	jbe    80107b19 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107b6a:	83 ec 0c             	sub    $0xc,%esp
80107b6d:	ff 75 08             	pushl  0x8(%ebp)
80107b70:	e8 7f ac ff ff       	call   801027f4 <kfree>
80107b75:	83 c4 10             	add    $0x10,%esp
}
80107b78:	90                   	nop
80107b79:	c9                   	leave  
80107b7a:	c3                   	ret    

80107b7b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107b7b:	f3 0f 1e fb          	endbr32 
80107b7f:	55                   	push   %ebp
80107b80:	89 e5                	mov    %esp,%ebp
80107b82:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107b85:	83 ec 04             	sub    $0x4,%esp
80107b88:	6a 00                	push   $0x0
80107b8a:	ff 75 0c             	pushl  0xc(%ebp)
80107b8d:	ff 75 08             	pushl  0x8(%ebp)
80107b90:	e8 38 f8 ff ff       	call   801073cd <walkpgdir>
80107b95:	83 c4 10             	add    $0x10,%esp
80107b98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107b9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b9f:	75 0d                	jne    80107bae <clearpteu+0x33>
    panic("clearpteu");
80107ba1:	83 ec 0c             	sub    $0xc,%esp
80107ba4:	68 94 a9 10 80       	push   $0x8010a994
80107ba9:	e8 17 8a ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80107bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb1:	8b 00                	mov    (%eax),%eax
80107bb3:	83 e0 fb             	and    $0xfffffffb,%eax
80107bb6:	89 c2                	mov    %eax,%edx
80107bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbb:	89 10                	mov    %edx,(%eax)
}
80107bbd:	90                   	nop
80107bbe:	c9                   	leave  
80107bbf:	c3                   	ret    

80107bc0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107bc0:	f3 0f 1e fb          	endbr32 
80107bc4:	55                   	push   %ebp
80107bc5:	89 e5                	mov    %esp,%ebp
80107bc7:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107bca:	e8 2c f9 ff ff       	call   801074fb <setupkvm>
80107bcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bd2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107bd6:	75 0a                	jne    80107be2 <copyuvm+0x22>
    return 0;
80107bd8:	b8 00 00 00 00       	mov    $0x0,%eax
80107bdd:	e9 eb 00 00 00       	jmp    80107ccd <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80107be2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107be9:	e9 b7 00 00 00       	jmp    80107ca5 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf1:	83 ec 04             	sub    $0x4,%esp
80107bf4:	6a 00                	push   $0x0
80107bf6:	50                   	push   %eax
80107bf7:	ff 75 08             	pushl  0x8(%ebp)
80107bfa:	e8 ce f7 ff ff       	call   801073cd <walkpgdir>
80107bff:	83 c4 10             	add    $0x10,%esp
80107c02:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c05:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c09:	75 0d                	jne    80107c18 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80107c0b:	83 ec 0c             	sub    $0xc,%esp
80107c0e:	68 9e a9 10 80       	push   $0x8010a99e
80107c13:	e8 ad 89 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80107c18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c1b:	8b 00                	mov    (%eax),%eax
80107c1d:	83 e0 01             	and    $0x1,%eax
80107c20:	85 c0                	test   %eax,%eax
80107c22:	75 0d                	jne    80107c31 <copyuvm+0x71>
      panic("copyuvm: page not present");
80107c24:	83 ec 0c             	sub    $0xc,%esp
80107c27:	68 b8 a9 10 80       	push   $0x8010a9b8
80107c2c:	e8 94 89 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107c31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c34:	8b 00                	mov    (%eax),%eax
80107c36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107c3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c41:	8b 00                	mov    (%eax),%eax
80107c43:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107c4b:	e8 42 ac ff ff       	call   80102892 <kalloc>
80107c50:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107c53:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107c57:	74 5d                	je     80107cb6 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107c59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c5c:	05 00 00 00 80       	add    $0x80000000,%eax
80107c61:	83 ec 04             	sub    $0x4,%esp
80107c64:	68 00 10 00 00       	push   $0x1000
80107c69:	50                   	push   %eax
80107c6a:	ff 75 e0             	pushl  -0x20(%ebp)
80107c6d:	e8 a9 cf ff ff       	call   80104c1b <memmove>
80107c72:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107c75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107c78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c7b:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c84:	83 ec 0c             	sub    $0xc,%esp
80107c87:	52                   	push   %edx
80107c88:	51                   	push   %ecx
80107c89:	68 00 10 00 00       	push   $0x1000
80107c8e:	50                   	push   %eax
80107c8f:	ff 75 f0             	pushl  -0x10(%ebp)
80107c92:	e8 d0 f7 ff ff       	call   80107467 <mappages>
80107c97:	83 c4 20             	add    $0x20,%esp
80107c9a:	85 c0                	test   %eax,%eax
80107c9c:	78 1b                	js     80107cb9 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80107c9e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107cab:	0f 82 3d ff ff ff    	jb     80107bee <copyuvm+0x2e>
      goto bad;
  }
  return d;
80107cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cb4:	eb 17                	jmp    80107ccd <copyuvm+0x10d>
      goto bad;
80107cb6:	90                   	nop
80107cb7:	eb 01                	jmp    80107cba <copyuvm+0xfa>
      goto bad;
80107cb9:	90                   	nop

bad:
  freevm(d);
80107cba:	83 ec 0c             	sub    $0xc,%esp
80107cbd:	ff 75 f0             	pushl  -0x10(%ebp)
80107cc0:	e8 19 fe ff ff       	call   80107ade <freevm>
80107cc5:	83 c4 10             	add    $0x10,%esp
  return 0;
80107cc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ccd:	c9                   	leave  
80107cce:	c3                   	ret    

80107ccf <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107ccf:	f3 0f 1e fb          	endbr32 
80107cd3:	55                   	push   %ebp
80107cd4:	89 e5                	mov    %esp,%ebp
80107cd6:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107cd9:	83 ec 04             	sub    $0x4,%esp
80107cdc:	6a 00                	push   $0x0
80107cde:	ff 75 0c             	pushl  0xc(%ebp)
80107ce1:	ff 75 08             	pushl  0x8(%ebp)
80107ce4:	e8 e4 f6 ff ff       	call   801073cd <walkpgdir>
80107ce9:	83 c4 10             	add    $0x10,%esp
80107cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf2:	8b 00                	mov    (%eax),%eax
80107cf4:	83 e0 01             	and    $0x1,%eax
80107cf7:	85 c0                	test   %eax,%eax
80107cf9:	75 07                	jne    80107d02 <uva2ka+0x33>
    return 0;
80107cfb:	b8 00 00 00 00       	mov    $0x0,%eax
80107d00:	eb 22                	jmp    80107d24 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80107d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d05:	8b 00                	mov    (%eax),%eax
80107d07:	83 e0 04             	and    $0x4,%eax
80107d0a:	85 c0                	test   %eax,%eax
80107d0c:	75 07                	jne    80107d15 <uva2ka+0x46>
    return 0;
80107d0e:	b8 00 00 00 00       	mov    $0x0,%eax
80107d13:	eb 0f                	jmp    80107d24 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80107d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d18:	8b 00                	mov    (%eax),%eax
80107d1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d1f:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107d24:	c9                   	leave  
80107d25:	c3                   	ret    

80107d26 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107d26:	f3 0f 1e fb          	endbr32 
80107d2a:	55                   	push   %ebp
80107d2b:	89 e5                	mov    %esp,%ebp
80107d2d:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107d30:	8b 45 10             	mov    0x10(%ebp),%eax
80107d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107d36:	eb 7f                	jmp    80107db7 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80107d38:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d40:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107d43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d46:	83 ec 08             	sub    $0x8,%esp
80107d49:	50                   	push   %eax
80107d4a:	ff 75 08             	pushl  0x8(%ebp)
80107d4d:	e8 7d ff ff ff       	call   80107ccf <uva2ka>
80107d52:	83 c4 10             	add    $0x10,%esp
80107d55:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107d58:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107d5c:	75 07                	jne    80107d65 <copyout+0x3f>
      return -1;
80107d5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d63:	eb 61                	jmp    80107dc6 <copyout+0xa0>
    n = PGSIZE - (va - va0);
80107d65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d68:	2b 45 0c             	sub    0xc(%ebp),%eax
80107d6b:	05 00 10 00 00       	add    $0x1000,%eax
80107d70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d76:	3b 45 14             	cmp    0x14(%ebp),%eax
80107d79:	76 06                	jbe    80107d81 <copyout+0x5b>
      n = len;
80107d7b:	8b 45 14             	mov    0x14(%ebp),%eax
80107d7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d84:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107d87:	89 c2                	mov    %eax,%edx
80107d89:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d8c:	01 d0                	add    %edx,%eax
80107d8e:	83 ec 04             	sub    $0x4,%esp
80107d91:	ff 75 f0             	pushl  -0x10(%ebp)
80107d94:	ff 75 f4             	pushl  -0xc(%ebp)
80107d97:	50                   	push   %eax
80107d98:	e8 7e ce ff ff       	call   80104c1b <memmove>
80107d9d:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107da3:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107da9:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107daf:	05 00 10 00 00       	add    $0x1000,%eax
80107db4:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107db7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107dbb:	0f 85 77 ff ff ff    	jne    80107d38 <copyout+0x12>
  }
  return 0;
80107dc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107dc6:	c9                   	leave  
80107dc7:	c3                   	ret    

80107dc8 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107dc8:	f3 0f 1e fb          	endbr32 
80107dcc:	55                   	push   %ebp
80107dcd:	89 e5                	mov    %esp,%ebp
80107dcf:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107dd2:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107dd9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107ddc:	8b 40 08             	mov    0x8(%eax),%eax
80107ddf:	05 00 00 00 80       	add    $0x80000000,%eax
80107de4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107de7:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df1:	8b 40 24             	mov    0x24(%eax),%eax
80107df4:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80107df9:	c7 05 80 7f 19 80 00 	movl   $0x0,0x80197f80
80107e00:	00 00 00 

  while(i<madt->len){
80107e03:	90                   	nop
80107e04:	e9 be 00 00 00       	jmp    80107ec7 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80107e09:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e0f:	01 d0                	add    %edx,%eax
80107e11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e17:	0f b6 00             	movzbl (%eax),%eax
80107e1a:	0f b6 c0             	movzbl %al,%eax
80107e1d:	83 f8 05             	cmp    $0x5,%eax
80107e20:	0f 87 a1 00 00 00    	ja     80107ec7 <mpinit_uefi+0xff>
80107e26:	8b 04 85 d4 a9 10 80 	mov    -0x7fef562c(,%eax,4),%eax
80107e2d:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e33:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107e36:	a1 80 7f 19 80       	mov    0x80197f80,%eax
80107e3b:	83 f8 03             	cmp    $0x3,%eax
80107e3e:	7f 28                	jg     80107e68 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107e40:	8b 15 80 7f 19 80    	mov    0x80197f80,%edx
80107e46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107e49:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107e4d:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107e53:	81 c2 c0 7c 19 80    	add    $0x80197cc0,%edx
80107e59:	88 02                	mov    %al,(%edx)
          ncpu++;
80107e5b:	a1 80 7f 19 80       	mov    0x80197f80,%eax
80107e60:	83 c0 01             	add    $0x1,%eax
80107e63:	a3 80 7f 19 80       	mov    %eax,0x80197f80
        }
        i += lapic_entry->record_len;
80107e68:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107e6b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107e6f:	0f b6 c0             	movzbl %al,%eax
80107e72:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107e75:	eb 50                	jmp    80107ec7 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107e80:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107e84:	a2 a0 7c 19 80       	mov    %al,0x80197ca0
        i += ioapic->record_len;
80107e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107e8c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107e90:	0f b6 c0             	movzbl %al,%eax
80107e93:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107e96:	eb 2f                	jmp    80107ec7 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107e98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e9b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107e9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107ea1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ea5:	0f b6 c0             	movzbl %al,%eax
80107ea8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107eab:	eb 1a                	jmp    80107ec7 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107eb6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107eba:	0f b6 c0             	movzbl %al,%eax
80107ebd:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ec0:	eb 05                	jmp    80107ec7 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
80107ec2:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107ec6:	90                   	nop
  while(i<madt->len){
80107ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eca:	8b 40 04             	mov    0x4(%eax),%eax
80107ecd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107ed0:	0f 82 33 ff ff ff    	jb     80107e09 <mpinit_uefi+0x41>
    }
  }

}
80107ed6:	90                   	nop
80107ed7:	90                   	nop
80107ed8:	c9                   	leave  
80107ed9:	c3                   	ret    

80107eda <inb>:
{
80107eda:	55                   	push   %ebp
80107edb:	89 e5                	mov    %esp,%ebp
80107edd:	83 ec 14             	sub    $0x14,%esp
80107ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80107ee3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107ee7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107eeb:	89 c2                	mov    %eax,%edx
80107eed:	ec                   	in     (%dx),%al
80107eee:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107ef1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107ef5:	c9                   	leave  
80107ef6:	c3                   	ret    

80107ef7 <outb>:
{
80107ef7:	55                   	push   %ebp
80107ef8:	89 e5                	mov    %esp,%ebp
80107efa:	83 ec 08             	sub    $0x8,%esp
80107efd:	8b 45 08             	mov    0x8(%ebp),%eax
80107f00:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f03:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107f07:	89 d0                	mov    %edx,%eax
80107f09:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107f0c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107f10:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107f14:	ee                   	out    %al,(%dx)
}
80107f15:	90                   	nop
80107f16:	c9                   	leave  
80107f17:	c3                   	ret    

80107f18 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107f18:	f3 0f 1e fb          	endbr32 
80107f1c:	55                   	push   %ebp
80107f1d:	89 e5                	mov    %esp,%ebp
80107f1f:	83 ec 28             	sub    $0x28,%esp
80107f22:	8b 45 08             	mov    0x8(%ebp),%eax
80107f25:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107f28:	6a 00                	push   $0x0
80107f2a:	68 fa 03 00 00       	push   $0x3fa
80107f2f:	e8 c3 ff ff ff       	call   80107ef7 <outb>
80107f34:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107f37:	68 80 00 00 00       	push   $0x80
80107f3c:	68 fb 03 00 00       	push   $0x3fb
80107f41:	e8 b1 ff ff ff       	call   80107ef7 <outb>
80107f46:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107f49:	6a 0c                	push   $0xc
80107f4b:	68 f8 03 00 00       	push   $0x3f8
80107f50:	e8 a2 ff ff ff       	call   80107ef7 <outb>
80107f55:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107f58:	6a 00                	push   $0x0
80107f5a:	68 f9 03 00 00       	push   $0x3f9
80107f5f:	e8 93 ff ff ff       	call   80107ef7 <outb>
80107f64:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107f67:	6a 03                	push   $0x3
80107f69:	68 fb 03 00 00       	push   $0x3fb
80107f6e:	e8 84 ff ff ff       	call   80107ef7 <outb>
80107f73:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107f76:	6a 00                	push   $0x0
80107f78:	68 fc 03 00 00       	push   $0x3fc
80107f7d:	e8 75 ff ff ff       	call   80107ef7 <outb>
80107f82:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107f85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f8c:	eb 11                	jmp    80107f9f <uart_debug+0x87>
80107f8e:	83 ec 0c             	sub    $0xc,%esp
80107f91:	6a 0a                	push   $0xa
80107f93:	e8 ac ac ff ff       	call   80102c44 <microdelay>
80107f98:	83 c4 10             	add    $0x10,%esp
80107f9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f9f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107fa3:	7f 1a                	jg     80107fbf <uart_debug+0xa7>
80107fa5:	83 ec 0c             	sub    $0xc,%esp
80107fa8:	68 fd 03 00 00       	push   $0x3fd
80107fad:	e8 28 ff ff ff       	call   80107eda <inb>
80107fb2:	83 c4 10             	add    $0x10,%esp
80107fb5:	0f b6 c0             	movzbl %al,%eax
80107fb8:	83 e0 20             	and    $0x20,%eax
80107fbb:	85 c0                	test   %eax,%eax
80107fbd:	74 cf                	je     80107f8e <uart_debug+0x76>
  outb(COM1+0, p);
80107fbf:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107fc3:	0f b6 c0             	movzbl %al,%eax
80107fc6:	83 ec 08             	sub    $0x8,%esp
80107fc9:	50                   	push   %eax
80107fca:	68 f8 03 00 00       	push   $0x3f8
80107fcf:	e8 23 ff ff ff       	call   80107ef7 <outb>
80107fd4:	83 c4 10             	add    $0x10,%esp
}
80107fd7:	90                   	nop
80107fd8:	c9                   	leave  
80107fd9:	c3                   	ret    

80107fda <uart_debugs>:

void uart_debugs(char *p){
80107fda:	f3 0f 1e fb          	endbr32 
80107fde:	55                   	push   %ebp
80107fdf:	89 e5                	mov    %esp,%ebp
80107fe1:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107fe4:	eb 1b                	jmp    80108001 <uart_debugs+0x27>
    uart_debug(*p++);
80107fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80107fe9:	8d 50 01             	lea    0x1(%eax),%edx
80107fec:	89 55 08             	mov    %edx,0x8(%ebp)
80107fef:	0f b6 00             	movzbl (%eax),%eax
80107ff2:	0f be c0             	movsbl %al,%eax
80107ff5:	83 ec 0c             	sub    $0xc,%esp
80107ff8:	50                   	push   %eax
80107ff9:	e8 1a ff ff ff       	call   80107f18 <uart_debug>
80107ffe:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108001:	8b 45 08             	mov    0x8(%ebp),%eax
80108004:	0f b6 00             	movzbl (%eax),%eax
80108007:	84 c0                	test   %al,%al
80108009:	75 db                	jne    80107fe6 <uart_debugs+0xc>
  }
}
8010800b:	90                   	nop
8010800c:	90                   	nop
8010800d:	c9                   	leave  
8010800e:	c3                   	ret    

8010800f <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
8010800f:	f3 0f 1e fb          	endbr32 
80108013:	55                   	push   %ebp
80108014:	89 e5                	mov    %esp,%ebp
80108016:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108019:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108020:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108023:	8b 50 14             	mov    0x14(%eax),%edx
80108026:	8b 40 10             	mov    0x10(%eax),%eax
80108029:	a3 84 7f 19 80       	mov    %eax,0x80197f84
  gpu.vram_size = boot_param->graphic_config.frame_size;
8010802e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108031:	8b 50 1c             	mov    0x1c(%eax),%edx
80108034:	8b 40 18             	mov    0x18(%eax),%eax
80108037:	a3 8c 7f 19 80       	mov    %eax,0x80197f8c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010803c:	a1 8c 7f 19 80       	mov    0x80197f8c,%eax
80108041:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108046:	29 c2                	sub    %eax,%edx
80108048:	89 d0                	mov    %edx,%eax
8010804a:	a3 88 7f 19 80       	mov    %eax,0x80197f88
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010804f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108052:	8b 50 24             	mov    0x24(%eax),%edx
80108055:	8b 40 20             	mov    0x20(%eax),%eax
80108058:	a3 90 7f 19 80       	mov    %eax,0x80197f90
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010805d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108060:	8b 50 2c             	mov    0x2c(%eax),%edx
80108063:	8b 40 28             	mov    0x28(%eax),%eax
80108066:	a3 94 7f 19 80       	mov    %eax,0x80197f94
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010806b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010806e:	8b 50 34             	mov    0x34(%eax),%edx
80108071:	8b 40 30             	mov    0x30(%eax),%eax
80108074:	a3 98 7f 19 80       	mov    %eax,0x80197f98
}
80108079:	90                   	nop
8010807a:	c9                   	leave  
8010807b:	c3                   	ret    

8010807c <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010807c:	f3 0f 1e fb          	endbr32 
80108080:	55                   	push   %ebp
80108081:	89 e5                	mov    %esp,%ebp
80108083:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108086:	8b 15 98 7f 19 80    	mov    0x80197f98,%edx
8010808c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010808f:	0f af d0             	imul   %eax,%edx
80108092:	8b 45 08             	mov    0x8(%ebp),%eax
80108095:	01 d0                	add    %edx,%eax
80108097:	c1 e0 02             	shl    $0x2,%eax
8010809a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
8010809d:	8b 15 88 7f 19 80    	mov    0x80197f88,%edx
801080a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080a6:	01 d0                	add    %edx,%eax
801080a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801080ab:	8b 45 10             	mov    0x10(%ebp),%eax
801080ae:	0f b6 10             	movzbl (%eax),%edx
801080b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080b4:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801080b6:	8b 45 10             	mov    0x10(%ebp),%eax
801080b9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801080bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080c0:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801080c3:	8b 45 10             	mov    0x10(%ebp),%eax
801080c6:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801080ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080cd:	88 50 02             	mov    %dl,0x2(%eax)
}
801080d0:	90                   	nop
801080d1:	c9                   	leave  
801080d2:	c3                   	ret    

801080d3 <graphic_scroll_up>:

void graphic_scroll_up(int height){
801080d3:	f3 0f 1e fb          	endbr32 
801080d7:	55                   	push   %ebp
801080d8:	89 e5                	mov    %esp,%ebp
801080da:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801080dd:	8b 15 98 7f 19 80    	mov    0x80197f98,%edx
801080e3:	8b 45 08             	mov    0x8(%ebp),%eax
801080e6:	0f af c2             	imul   %edx,%eax
801080e9:	c1 e0 02             	shl    $0x2,%eax
801080ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801080ef:	8b 15 8c 7f 19 80    	mov    0x80197f8c,%edx
801080f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f8:	29 c2                	sub    %eax,%edx
801080fa:	89 d0                	mov    %edx,%eax
801080fc:	8b 0d 88 7f 19 80    	mov    0x80197f88,%ecx
80108102:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108105:	01 ca                	add    %ecx,%edx
80108107:	89 d1                	mov    %edx,%ecx
80108109:	8b 15 88 7f 19 80    	mov    0x80197f88,%edx
8010810f:	83 ec 04             	sub    $0x4,%esp
80108112:	50                   	push   %eax
80108113:	51                   	push   %ecx
80108114:	52                   	push   %edx
80108115:	e8 01 cb ff ff       	call   80104c1b <memmove>
8010811a:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
8010811d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108120:	8b 0d 88 7f 19 80    	mov    0x80197f88,%ecx
80108126:	8b 15 8c 7f 19 80    	mov    0x80197f8c,%edx
8010812c:	01 d1                	add    %edx,%ecx
8010812e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108131:	29 d1                	sub    %edx,%ecx
80108133:	89 ca                	mov    %ecx,%edx
80108135:	83 ec 04             	sub    $0x4,%esp
80108138:	50                   	push   %eax
80108139:	6a 00                	push   $0x0
8010813b:	52                   	push   %edx
8010813c:	e8 13 ca ff ff       	call   80104b54 <memset>
80108141:	83 c4 10             	add    $0x10,%esp
}
80108144:	90                   	nop
80108145:	c9                   	leave  
80108146:	c3                   	ret    

80108147 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108147:	f3 0f 1e fb          	endbr32 
8010814b:	55                   	push   %ebp
8010814c:	89 e5                	mov    %esp,%ebp
8010814e:	53                   	push   %ebx
8010814f:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108152:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108159:	e9 b1 00 00 00       	jmp    8010820f <font_render+0xc8>
    for(int j=14;j>-1;j--){
8010815e:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108165:	e9 97 00 00 00       	jmp    80108201 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
8010816a:	8b 45 10             	mov    0x10(%ebp),%eax
8010816d:	83 e8 20             	sub    $0x20,%eax
80108170:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108176:	01 d0                	add    %edx,%eax
80108178:	0f b7 84 00 00 aa 10 	movzwl -0x7fef5600(%eax,%eax,1),%eax
8010817f:	80 
80108180:	0f b7 d0             	movzwl %ax,%edx
80108183:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108186:	bb 01 00 00 00       	mov    $0x1,%ebx
8010818b:	89 c1                	mov    %eax,%ecx
8010818d:	d3 e3                	shl    %cl,%ebx
8010818f:	89 d8                	mov    %ebx,%eax
80108191:	21 d0                	and    %edx,%eax
80108193:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108196:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108199:	ba 01 00 00 00       	mov    $0x1,%edx
8010819e:	89 c1                	mov    %eax,%ecx
801081a0:	d3 e2                	shl    %cl,%edx
801081a2:	89 d0                	mov    %edx,%eax
801081a4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801081a7:	75 2b                	jne    801081d4 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801081a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801081ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081af:	01 c2                	add    %eax,%edx
801081b1:	b8 0e 00 00 00       	mov    $0xe,%eax
801081b6:	2b 45 f0             	sub    -0x10(%ebp),%eax
801081b9:	89 c1                	mov    %eax,%ecx
801081bb:	8b 45 08             	mov    0x8(%ebp),%eax
801081be:	01 c8                	add    %ecx,%eax
801081c0:	83 ec 04             	sub    $0x4,%esp
801081c3:	68 e0 f4 10 80       	push   $0x8010f4e0
801081c8:	52                   	push   %edx
801081c9:	50                   	push   %eax
801081ca:	e8 ad fe ff ff       	call   8010807c <graphic_draw_pixel>
801081cf:	83 c4 10             	add    $0x10,%esp
801081d2:	eb 29                	jmp    801081fd <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801081d4:	8b 55 0c             	mov    0xc(%ebp),%edx
801081d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081da:	01 c2                	add    %eax,%edx
801081dc:	b8 0e 00 00 00       	mov    $0xe,%eax
801081e1:	2b 45 f0             	sub    -0x10(%ebp),%eax
801081e4:	89 c1                	mov    %eax,%ecx
801081e6:	8b 45 08             	mov    0x8(%ebp),%eax
801081e9:	01 c8                	add    %ecx,%eax
801081eb:	83 ec 04             	sub    $0x4,%esp
801081ee:	68 64 d0 18 80       	push   $0x8018d064
801081f3:	52                   	push   %edx
801081f4:	50                   	push   %eax
801081f5:	e8 82 fe ff ff       	call   8010807c <graphic_draw_pixel>
801081fa:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801081fd:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108201:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108205:	0f 89 5f ff ff ff    	jns    8010816a <font_render+0x23>
  for(int i=0;i<30;i++){
8010820b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010820f:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108213:	0f 8e 45 ff ff ff    	jle    8010815e <font_render+0x17>
      }
    }
  }
}
80108219:	90                   	nop
8010821a:	90                   	nop
8010821b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010821e:	c9                   	leave  
8010821f:	c3                   	ret    

80108220 <font_render_string>:

void font_render_string(char *string,int row){
80108220:	f3 0f 1e fb          	endbr32 
80108224:	55                   	push   %ebp
80108225:	89 e5                	mov    %esp,%ebp
80108227:	53                   	push   %ebx
80108228:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
8010822b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108232:	eb 33                	jmp    80108267 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108234:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108237:	8b 45 08             	mov    0x8(%ebp),%eax
8010823a:	01 d0                	add    %edx,%eax
8010823c:	0f b6 00             	movzbl (%eax),%eax
8010823f:	0f be d8             	movsbl %al,%ebx
80108242:	8b 45 0c             	mov    0xc(%ebp),%eax
80108245:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108248:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010824b:	89 d0                	mov    %edx,%eax
8010824d:	c1 e0 04             	shl    $0x4,%eax
80108250:	29 d0                	sub    %edx,%eax
80108252:	83 c0 02             	add    $0x2,%eax
80108255:	83 ec 04             	sub    $0x4,%esp
80108258:	53                   	push   %ebx
80108259:	51                   	push   %ecx
8010825a:	50                   	push   %eax
8010825b:	e8 e7 fe ff ff       	call   80108147 <font_render>
80108260:	83 c4 10             	add    $0x10,%esp
    i++;
80108263:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108267:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010826a:	8b 45 08             	mov    0x8(%ebp),%eax
8010826d:	01 d0                	add    %edx,%eax
8010826f:	0f b6 00             	movzbl (%eax),%eax
80108272:	84 c0                	test   %al,%al
80108274:	74 06                	je     8010827c <font_render_string+0x5c>
80108276:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
8010827a:	7e b8                	jle    80108234 <font_render_string+0x14>
  }
}
8010827c:	90                   	nop
8010827d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108280:	c9                   	leave  
80108281:	c3                   	ret    

80108282 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108282:	f3 0f 1e fb          	endbr32 
80108286:	55                   	push   %ebp
80108287:	89 e5                	mov    %esp,%ebp
80108289:	53                   	push   %ebx
8010828a:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
8010828d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108294:	eb 6b                	jmp    80108301 <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108296:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010829d:	eb 58                	jmp    801082f7 <pci_init+0x75>
      for(int k=0;k<8;k++){
8010829f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801082a6:	eb 45                	jmp    801082ed <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801082a8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801082ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b1:	83 ec 0c             	sub    $0xc,%esp
801082b4:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801082b7:	53                   	push   %ebx
801082b8:	6a 00                	push   $0x0
801082ba:	51                   	push   %ecx
801082bb:	52                   	push   %edx
801082bc:	50                   	push   %eax
801082bd:	e8 c0 00 00 00       	call   80108382 <pci_access_config>
801082c2:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801082c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082c8:	0f b7 c0             	movzwl %ax,%eax
801082cb:	3d ff ff 00 00       	cmp    $0xffff,%eax
801082d0:	74 17                	je     801082e9 <pci_init+0x67>
        pci_init_device(i,j,k);
801082d2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801082d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082db:	83 ec 04             	sub    $0x4,%esp
801082de:	51                   	push   %ecx
801082df:	52                   	push   %edx
801082e0:	50                   	push   %eax
801082e1:	e8 4f 01 00 00       	call   80108435 <pci_init_device>
801082e6:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801082e9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801082ed:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801082f1:	7e b5                	jle    801082a8 <pci_init+0x26>
    for(int j=0;j<32;j++){
801082f3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801082f7:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801082fb:	7e a2                	jle    8010829f <pci_init+0x1d>
  for(int i=0;i<256;i++){
801082fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108301:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108308:	7e 8c                	jle    80108296 <pci_init+0x14>
      }
      }
    }
  }
}
8010830a:	90                   	nop
8010830b:	90                   	nop
8010830c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010830f:	c9                   	leave  
80108310:	c3                   	ret    

80108311 <pci_write_config>:

void pci_write_config(uint config){
80108311:	f3 0f 1e fb          	endbr32 
80108315:	55                   	push   %ebp
80108316:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108318:	8b 45 08             	mov    0x8(%ebp),%eax
8010831b:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108320:	89 c0                	mov    %eax,%eax
80108322:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108323:	90                   	nop
80108324:	5d                   	pop    %ebp
80108325:	c3                   	ret    

80108326 <pci_write_data>:

void pci_write_data(uint config){
80108326:	f3 0f 1e fb          	endbr32 
8010832a:	55                   	push   %ebp
8010832b:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
8010832d:	8b 45 08             	mov    0x8(%ebp),%eax
80108330:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108335:	89 c0                	mov    %eax,%eax
80108337:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108338:	90                   	nop
80108339:	5d                   	pop    %ebp
8010833a:	c3                   	ret    

8010833b <pci_read_config>:
uint pci_read_config(){
8010833b:	f3 0f 1e fb          	endbr32 
8010833f:	55                   	push   %ebp
80108340:	89 e5                	mov    %esp,%ebp
80108342:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108345:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010834a:	ed                   	in     (%dx),%eax
8010834b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
8010834e:	83 ec 0c             	sub    $0xc,%esp
80108351:	68 c8 00 00 00       	push   $0xc8
80108356:	e8 e9 a8 ff ff       	call   80102c44 <microdelay>
8010835b:	83 c4 10             	add    $0x10,%esp
  return data;
8010835e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108361:	c9                   	leave  
80108362:	c3                   	ret    

80108363 <pci_test>:


void pci_test(){
80108363:	f3 0f 1e fb          	endbr32 
80108367:	55                   	push   %ebp
80108368:	89 e5                	mov    %esp,%ebp
8010836a:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
8010836d:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108374:	ff 75 fc             	pushl  -0x4(%ebp)
80108377:	e8 95 ff ff ff       	call   80108311 <pci_write_config>
8010837c:	83 c4 04             	add    $0x4,%esp
}
8010837f:	90                   	nop
80108380:	c9                   	leave  
80108381:	c3                   	ret    

80108382 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108382:	f3 0f 1e fb          	endbr32 
80108386:	55                   	push   %ebp
80108387:	89 e5                	mov    %esp,%ebp
80108389:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010838c:	8b 45 08             	mov    0x8(%ebp),%eax
8010838f:	c1 e0 10             	shl    $0x10,%eax
80108392:	25 00 00 ff 00       	and    $0xff0000,%eax
80108397:	89 c2                	mov    %eax,%edx
80108399:	8b 45 0c             	mov    0xc(%ebp),%eax
8010839c:	c1 e0 0b             	shl    $0xb,%eax
8010839f:	0f b7 c0             	movzwl %ax,%eax
801083a2:	09 c2                	or     %eax,%edx
801083a4:	8b 45 10             	mov    0x10(%ebp),%eax
801083a7:	c1 e0 08             	shl    $0x8,%eax
801083aa:	25 00 07 00 00       	and    $0x700,%eax
801083af:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801083b1:	8b 45 14             	mov    0x14(%ebp),%eax
801083b4:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083b9:	09 d0                	or     %edx,%eax
801083bb:	0d 00 00 00 80       	or     $0x80000000,%eax
801083c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801083c3:	ff 75 f4             	pushl  -0xc(%ebp)
801083c6:	e8 46 ff ff ff       	call   80108311 <pci_write_config>
801083cb:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801083ce:	e8 68 ff ff ff       	call   8010833b <pci_read_config>
801083d3:	8b 55 18             	mov    0x18(%ebp),%edx
801083d6:	89 02                	mov    %eax,(%edx)
}
801083d8:	90                   	nop
801083d9:	c9                   	leave  
801083da:	c3                   	ret    

801083db <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801083db:	f3 0f 1e fb          	endbr32 
801083df:	55                   	push   %ebp
801083e0:	89 e5                	mov    %esp,%ebp
801083e2:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801083e5:	8b 45 08             	mov    0x8(%ebp),%eax
801083e8:	c1 e0 10             	shl    $0x10,%eax
801083eb:	25 00 00 ff 00       	and    $0xff0000,%eax
801083f0:	89 c2                	mov    %eax,%edx
801083f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f5:	c1 e0 0b             	shl    $0xb,%eax
801083f8:	0f b7 c0             	movzwl %ax,%eax
801083fb:	09 c2                	or     %eax,%edx
801083fd:	8b 45 10             	mov    0x10(%ebp),%eax
80108400:	c1 e0 08             	shl    $0x8,%eax
80108403:	25 00 07 00 00       	and    $0x700,%eax
80108408:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010840a:	8b 45 14             	mov    0x14(%ebp),%eax
8010840d:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108412:	09 d0                	or     %edx,%eax
80108414:	0d 00 00 00 80       	or     $0x80000000,%eax
80108419:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010841c:	ff 75 fc             	pushl  -0x4(%ebp)
8010841f:	e8 ed fe ff ff       	call   80108311 <pci_write_config>
80108424:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108427:	ff 75 18             	pushl  0x18(%ebp)
8010842a:	e8 f7 fe ff ff       	call   80108326 <pci_write_data>
8010842f:	83 c4 04             	add    $0x4,%esp
}
80108432:	90                   	nop
80108433:	c9                   	leave  
80108434:	c3                   	ret    

80108435 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108435:	f3 0f 1e fb          	endbr32 
80108439:	55                   	push   %ebp
8010843a:	89 e5                	mov    %esp,%ebp
8010843c:	53                   	push   %ebx
8010843d:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108440:	8b 45 08             	mov    0x8(%ebp),%eax
80108443:	a2 9c 7f 19 80       	mov    %al,0x80197f9c
  dev.device_num = device_num;
80108448:	8b 45 0c             	mov    0xc(%ebp),%eax
8010844b:	a2 9d 7f 19 80       	mov    %al,0x80197f9d
  dev.function_num = function_num;
80108450:	8b 45 10             	mov    0x10(%ebp),%eax
80108453:	a2 9e 7f 19 80       	mov    %al,0x80197f9e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108458:	ff 75 10             	pushl  0x10(%ebp)
8010845b:	ff 75 0c             	pushl  0xc(%ebp)
8010845e:	ff 75 08             	pushl  0x8(%ebp)
80108461:	68 44 c0 10 80       	push   $0x8010c044
80108466:	e8 a1 7f ff ff       	call   8010040c <cprintf>
8010846b:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
8010846e:	83 ec 0c             	sub    $0xc,%esp
80108471:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108474:	50                   	push   %eax
80108475:	6a 00                	push   $0x0
80108477:	ff 75 10             	pushl  0x10(%ebp)
8010847a:	ff 75 0c             	pushl  0xc(%ebp)
8010847d:	ff 75 08             	pushl  0x8(%ebp)
80108480:	e8 fd fe ff ff       	call   80108382 <pci_access_config>
80108485:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108488:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010848b:	c1 e8 10             	shr    $0x10,%eax
8010848e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108491:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108494:	25 ff ff 00 00       	and    $0xffff,%eax
80108499:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
8010849c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849f:	a3 a0 7f 19 80       	mov    %eax,0x80197fa0
  dev.vendor_id = vendor_id;
801084a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084a7:	a3 a4 7f 19 80       	mov    %eax,0x80197fa4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801084ac:	83 ec 04             	sub    $0x4,%esp
801084af:	ff 75 f0             	pushl  -0x10(%ebp)
801084b2:	ff 75 f4             	pushl  -0xc(%ebp)
801084b5:	68 78 c0 10 80       	push   $0x8010c078
801084ba:	e8 4d 7f ff ff       	call   8010040c <cprintf>
801084bf:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801084c2:	83 ec 0c             	sub    $0xc,%esp
801084c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801084c8:	50                   	push   %eax
801084c9:	6a 08                	push   $0x8
801084cb:	ff 75 10             	pushl  0x10(%ebp)
801084ce:	ff 75 0c             	pushl  0xc(%ebp)
801084d1:	ff 75 08             	pushl  0x8(%ebp)
801084d4:	e8 a9 fe ff ff       	call   80108382 <pci_access_config>
801084d9:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801084dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084df:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801084e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084e5:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801084e8:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801084eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ee:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801084f1:	0f b6 c0             	movzbl %al,%eax
801084f4:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801084f7:	c1 eb 18             	shr    $0x18,%ebx
801084fa:	83 ec 0c             	sub    $0xc,%esp
801084fd:	51                   	push   %ecx
801084fe:	52                   	push   %edx
801084ff:	50                   	push   %eax
80108500:	53                   	push   %ebx
80108501:	68 9c c0 10 80       	push   $0x8010c09c
80108506:	e8 01 7f ff ff       	call   8010040c <cprintf>
8010850b:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010850e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108511:	c1 e8 18             	shr    $0x18,%eax
80108514:	a2 a8 7f 19 80       	mov    %al,0x80197fa8
  dev.sub_class = (data>>16)&0xFF;
80108519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010851c:	c1 e8 10             	shr    $0x10,%eax
8010851f:	a2 a9 7f 19 80       	mov    %al,0x80197fa9
  dev.interface = (data>>8)&0xFF;
80108524:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108527:	c1 e8 08             	shr    $0x8,%eax
8010852a:	a2 aa 7f 19 80       	mov    %al,0x80197faa
  dev.revision_id = data&0xFF;
8010852f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108532:	a2 ab 7f 19 80       	mov    %al,0x80197fab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108537:	83 ec 0c             	sub    $0xc,%esp
8010853a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010853d:	50                   	push   %eax
8010853e:	6a 10                	push   $0x10
80108540:	ff 75 10             	pushl  0x10(%ebp)
80108543:	ff 75 0c             	pushl  0xc(%ebp)
80108546:	ff 75 08             	pushl  0x8(%ebp)
80108549:	e8 34 fe ff ff       	call   80108382 <pci_access_config>
8010854e:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108551:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108554:	a3 ac 7f 19 80       	mov    %eax,0x80197fac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108559:	83 ec 0c             	sub    $0xc,%esp
8010855c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010855f:	50                   	push   %eax
80108560:	6a 14                	push   $0x14
80108562:	ff 75 10             	pushl  0x10(%ebp)
80108565:	ff 75 0c             	pushl  0xc(%ebp)
80108568:	ff 75 08             	pushl  0x8(%ebp)
8010856b:	e8 12 fe ff ff       	call   80108382 <pci_access_config>
80108570:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108573:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108576:	a3 b0 7f 19 80       	mov    %eax,0x80197fb0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
8010857b:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108582:	75 5a                	jne    801085de <pci_init_device+0x1a9>
80108584:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
8010858b:	75 51                	jne    801085de <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
8010858d:	83 ec 0c             	sub    $0xc,%esp
80108590:	68 e1 c0 10 80       	push   $0x8010c0e1
80108595:	e8 72 7e ff ff       	call   8010040c <cprintf>
8010859a:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010859d:	83 ec 0c             	sub    $0xc,%esp
801085a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801085a3:	50                   	push   %eax
801085a4:	68 f0 00 00 00       	push   $0xf0
801085a9:	ff 75 10             	pushl  0x10(%ebp)
801085ac:	ff 75 0c             	pushl  0xc(%ebp)
801085af:	ff 75 08             	pushl  0x8(%ebp)
801085b2:	e8 cb fd ff ff       	call   80108382 <pci_access_config>
801085b7:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801085ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085bd:	83 ec 08             	sub    $0x8,%esp
801085c0:	50                   	push   %eax
801085c1:	68 fb c0 10 80       	push   $0x8010c0fb
801085c6:	e8 41 7e ff ff       	call   8010040c <cprintf>
801085cb:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801085ce:	83 ec 0c             	sub    $0xc,%esp
801085d1:	68 9c 7f 19 80       	push   $0x80197f9c
801085d6:	e8 09 00 00 00       	call   801085e4 <i8254_init>
801085db:	83 c4 10             	add    $0x10,%esp
  }
}
801085de:	90                   	nop
801085df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085e2:	c9                   	leave  
801085e3:	c3                   	ret    

801085e4 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801085e4:	f3 0f 1e fb          	endbr32 
801085e8:	55                   	push   %ebp
801085e9:	89 e5                	mov    %esp,%ebp
801085eb:	53                   	push   %ebx
801085ec:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801085ef:	8b 45 08             	mov    0x8(%ebp),%eax
801085f2:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801085f6:	0f b6 c8             	movzbl %al,%ecx
801085f9:	8b 45 08             	mov    0x8(%ebp),%eax
801085fc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108600:	0f b6 d0             	movzbl %al,%edx
80108603:	8b 45 08             	mov    0x8(%ebp),%eax
80108606:	0f b6 00             	movzbl (%eax),%eax
80108609:	0f b6 c0             	movzbl %al,%eax
8010860c:	83 ec 0c             	sub    $0xc,%esp
8010860f:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108612:	53                   	push   %ebx
80108613:	6a 04                	push   $0x4
80108615:	51                   	push   %ecx
80108616:	52                   	push   %edx
80108617:	50                   	push   %eax
80108618:	e8 65 fd ff ff       	call   80108382 <pci_access_config>
8010861d:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108620:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108623:	83 c8 04             	or     $0x4,%eax
80108626:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108629:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010862c:	8b 45 08             	mov    0x8(%ebp),%eax
8010862f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108633:	0f b6 c8             	movzbl %al,%ecx
80108636:	8b 45 08             	mov    0x8(%ebp),%eax
80108639:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010863d:	0f b6 d0             	movzbl %al,%edx
80108640:	8b 45 08             	mov    0x8(%ebp),%eax
80108643:	0f b6 00             	movzbl (%eax),%eax
80108646:	0f b6 c0             	movzbl %al,%eax
80108649:	83 ec 0c             	sub    $0xc,%esp
8010864c:	53                   	push   %ebx
8010864d:	6a 04                	push   $0x4
8010864f:	51                   	push   %ecx
80108650:	52                   	push   %edx
80108651:	50                   	push   %eax
80108652:	e8 84 fd ff ff       	call   801083db <pci_write_config_register>
80108657:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
8010865a:	8b 45 08             	mov    0x8(%ebp),%eax
8010865d:	8b 40 10             	mov    0x10(%eax),%eax
80108660:	05 00 00 00 40       	add    $0x40000000,%eax
80108665:	a3 b4 7f 19 80       	mov    %eax,0x80197fb4
  uint *ctrl = (uint *)base_addr;
8010866a:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
8010866f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108672:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108677:	05 d8 00 00 00       	add    $0xd8,%eax
8010867c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010867f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108682:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868b:	8b 00                	mov    (%eax),%eax
8010868d:	0d 00 00 00 04       	or     $0x4000000,%eax
80108692:	89 c2                	mov    %eax,%edx
80108694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108697:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010869c:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801086a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a5:	8b 00                	mov    (%eax),%eax
801086a7:	83 c8 40             	or     $0x40,%eax
801086aa:	89 c2                	mov    %eax,%edx
801086ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086af:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801086b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b4:	8b 10                	mov    (%eax),%edx
801086b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b9:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801086bb:	83 ec 0c             	sub    $0xc,%esp
801086be:	68 10 c1 10 80       	push   $0x8010c110
801086c3:	e8 44 7d ff ff       	call   8010040c <cprintf>
801086c8:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801086cb:	e8 c2 a1 ff ff       	call   80102892 <kalloc>
801086d0:	a3 b8 7f 19 80       	mov    %eax,0x80197fb8
  *intr_addr = 0;
801086d5:	a1 b8 7f 19 80       	mov    0x80197fb8,%eax
801086da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801086e0:	a1 b8 7f 19 80       	mov    0x80197fb8,%eax
801086e5:	83 ec 08             	sub    $0x8,%esp
801086e8:	50                   	push   %eax
801086e9:	68 32 c1 10 80       	push   $0x8010c132
801086ee:	e8 19 7d ff ff       	call   8010040c <cprintf>
801086f3:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801086f6:	e8 50 00 00 00       	call   8010874b <i8254_init_recv>
  i8254_init_send();
801086fb:	e8 6d 03 00 00       	call   80108a6d <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108700:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108707:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010870a:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108711:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108714:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010871b:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010871e:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108725:	0f b6 c0             	movzbl %al,%eax
80108728:	83 ec 0c             	sub    $0xc,%esp
8010872b:	53                   	push   %ebx
8010872c:	51                   	push   %ecx
8010872d:	52                   	push   %edx
8010872e:	50                   	push   %eax
8010872f:	68 40 c1 10 80       	push   $0x8010c140
80108734:	e8 d3 7c ff ff       	call   8010040c <cprintf>
80108739:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010873c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010873f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108745:	90                   	nop
80108746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108749:	c9                   	leave  
8010874a:	c3                   	ret    

8010874b <i8254_init_recv>:

void i8254_init_recv(){
8010874b:	f3 0f 1e fb          	endbr32 
8010874f:	55                   	push   %ebp
80108750:	89 e5                	mov    %esp,%ebp
80108752:	57                   	push   %edi
80108753:	56                   	push   %esi
80108754:	53                   	push   %ebx
80108755:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108758:	83 ec 0c             	sub    $0xc,%esp
8010875b:	6a 00                	push   $0x0
8010875d:	e8 ec 04 00 00       	call   80108c4e <i8254_read_eeprom>
80108762:	83 c4 10             	add    $0x10,%esp
80108765:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108768:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010876b:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108770:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108773:	c1 e8 08             	shr    $0x8,%eax
80108776:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
8010877b:	83 ec 0c             	sub    $0xc,%esp
8010877e:	6a 01                	push   $0x1
80108780:	e8 c9 04 00 00       	call   80108c4e <i8254_read_eeprom>
80108785:	83 c4 10             	add    $0x10,%esp
80108788:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
8010878b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010878e:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108793:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108796:	c1 e8 08             	shr    $0x8,%eax
80108799:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
8010879e:	83 ec 0c             	sub    $0xc,%esp
801087a1:	6a 02                	push   $0x2
801087a3:	e8 a6 04 00 00       	call   80108c4e <i8254_read_eeprom>
801087a8:	83 c4 10             	add    $0x10,%esp
801087ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801087ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
801087b1:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
801087b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801087b9:	c1 e8 08             	shr    $0x8,%eax
801087bc:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
801087c1:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087c8:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
801087cb:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087d2:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
801087d5:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087dc:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
801087df:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087e6:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801087e9:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087f0:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801087f3:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801087fa:	0f b6 c0             	movzbl %al,%eax
801087fd:	83 ec 04             	sub    $0x4,%esp
80108800:	57                   	push   %edi
80108801:	56                   	push   %esi
80108802:	53                   	push   %ebx
80108803:	51                   	push   %ecx
80108804:	52                   	push   %edx
80108805:	50                   	push   %eax
80108806:	68 58 c1 10 80       	push   $0x8010c158
8010880b:	e8 fc 7b ff ff       	call   8010040c <cprintf>
80108810:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108813:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108818:	05 00 54 00 00       	add    $0x5400,%eax
8010881d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108820:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108825:	05 04 54 00 00       	add    $0x5404,%eax
8010882a:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
8010882d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108830:	c1 e0 10             	shl    $0x10,%eax
80108833:	0b 45 d8             	or     -0x28(%ebp),%eax
80108836:	89 c2                	mov    %eax,%edx
80108838:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010883b:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
8010883d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108840:	0d 00 00 00 80       	or     $0x80000000,%eax
80108845:	89 c2                	mov    %eax,%edx
80108847:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010884a:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
8010884c:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108851:	05 00 52 00 00       	add    $0x5200,%eax
80108856:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108859:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108860:	eb 19                	jmp    8010887b <i8254_init_recv+0x130>
    mta[i] = 0;
80108862:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108865:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010886c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010886f:	01 d0                	add    %edx,%eax
80108871:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108877:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010887b:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
8010887f:	7e e1                	jle    80108862 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108881:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108886:	05 d0 00 00 00       	add    $0xd0,%eax
8010888b:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010888e:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108891:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108897:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
8010889c:	05 c8 00 00 00       	add    $0xc8,%eax
801088a1:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801088a4:	8b 45 bc             	mov    -0x44(%ebp),%eax
801088a7:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801088ad:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
801088b2:	05 28 28 00 00       	add    $0x2828,%eax
801088b7:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801088ba:	8b 45 b8             	mov    -0x48(%ebp),%eax
801088bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
801088c3:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
801088c8:	05 00 01 00 00       	add    $0x100,%eax
801088cd:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
801088d0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088d3:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
801088d9:	e8 b4 9f ff ff       	call   80102892 <kalloc>
801088de:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801088e1:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
801088e6:	05 00 28 00 00       	add    $0x2800,%eax
801088eb:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801088ee:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
801088f3:	05 04 28 00 00       	add    $0x2804,%eax
801088f8:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801088fb:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108900:	05 08 28 00 00       	add    $0x2808,%eax
80108905:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108908:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
8010890d:	05 10 28 00 00       	add    $0x2810,%eax
80108912:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108915:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
8010891a:	05 18 28 00 00       	add    $0x2818,%eax
8010891f:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108922:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108925:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010892b:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010892e:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108930:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108933:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108939:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010893c:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108942:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108945:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
8010894b:	8b 45 9c             	mov    -0x64(%ebp),%eax
8010894e:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108954:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108957:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010895a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108961:	eb 73                	jmp    801089d6 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108963:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108966:	c1 e0 04             	shl    $0x4,%eax
80108969:	89 c2                	mov    %eax,%edx
8010896b:	8b 45 98             	mov    -0x68(%ebp),%eax
8010896e:	01 d0                	add    %edx,%eax
80108970:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108977:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010897a:	c1 e0 04             	shl    $0x4,%eax
8010897d:	89 c2                	mov    %eax,%edx
8010897f:	8b 45 98             	mov    -0x68(%ebp),%eax
80108982:	01 d0                	add    %edx,%eax
80108984:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
8010898a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010898d:	c1 e0 04             	shl    $0x4,%eax
80108990:	89 c2                	mov    %eax,%edx
80108992:	8b 45 98             	mov    -0x68(%ebp),%eax
80108995:	01 d0                	add    %edx,%eax
80108997:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
8010899d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089a0:	c1 e0 04             	shl    $0x4,%eax
801089a3:	89 c2                	mov    %eax,%edx
801089a5:	8b 45 98             	mov    -0x68(%ebp),%eax
801089a8:	01 d0                	add    %edx,%eax
801089aa:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801089ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089b1:	c1 e0 04             	shl    $0x4,%eax
801089b4:	89 c2                	mov    %eax,%edx
801089b6:	8b 45 98             	mov    -0x68(%ebp),%eax
801089b9:	01 d0                	add    %edx,%eax
801089bb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
801089bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089c2:	c1 e0 04             	shl    $0x4,%eax
801089c5:	89 c2                	mov    %eax,%edx
801089c7:	8b 45 98             	mov    -0x68(%ebp),%eax
801089ca:	01 d0                	add    %edx,%eax
801089cc:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801089d2:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
801089d6:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
801089dd:	7e 84                	jle    80108963 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801089df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801089e6:	eb 57                	jmp    80108a3f <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
801089e8:	e8 a5 9e ff ff       	call   80102892 <kalloc>
801089ed:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801089f0:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801089f4:	75 12                	jne    80108a08 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
801089f6:	83 ec 0c             	sub    $0xc,%esp
801089f9:	68 78 c1 10 80       	push   $0x8010c178
801089fe:	e8 09 7a ff ff       	call   8010040c <cprintf>
80108a03:	83 c4 10             	add    $0x10,%esp
      break;
80108a06:	eb 3d                	jmp    80108a45 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108a08:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a0b:	c1 e0 04             	shl    $0x4,%eax
80108a0e:	89 c2                	mov    %eax,%edx
80108a10:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a13:	01 d0                	add    %edx,%eax
80108a15:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108a18:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a1e:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a20:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108a23:	83 c0 01             	add    $0x1,%eax
80108a26:	c1 e0 04             	shl    $0x4,%eax
80108a29:	89 c2                	mov    %eax,%edx
80108a2b:	8b 45 98             	mov    -0x68(%ebp),%eax
80108a2e:	01 d0                	add    %edx,%eax
80108a30:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108a33:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a39:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108a3b:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108a3f:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108a43:	7e a3                	jle    801089e8 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108a45:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a48:	8b 00                	mov    (%eax),%eax
80108a4a:	83 c8 02             	or     $0x2,%eax
80108a4d:	89 c2                	mov    %eax,%edx
80108a4f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108a52:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108a54:	83 ec 0c             	sub    $0xc,%esp
80108a57:	68 98 c1 10 80       	push   $0x8010c198
80108a5c:	e8 ab 79 ff ff       	call   8010040c <cprintf>
80108a61:	83 c4 10             	add    $0x10,%esp
}
80108a64:	90                   	nop
80108a65:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108a68:	5b                   	pop    %ebx
80108a69:	5e                   	pop    %esi
80108a6a:	5f                   	pop    %edi
80108a6b:	5d                   	pop    %ebp
80108a6c:	c3                   	ret    

80108a6d <i8254_init_send>:

void i8254_init_send(){
80108a6d:	f3 0f 1e fb          	endbr32 
80108a71:	55                   	push   %ebp
80108a72:	89 e5                	mov    %esp,%ebp
80108a74:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108a77:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108a7c:	05 28 38 00 00       	add    $0x3828,%eax
80108a81:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a87:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108a8d:	e8 00 9e ff ff       	call   80102892 <kalloc>
80108a92:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108a95:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108a9a:	05 00 38 00 00       	add    $0x3800,%eax
80108a9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108aa2:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108aa7:	05 04 38 00 00       	add    $0x3804,%eax
80108aac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108aaf:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108ab4:	05 08 38 00 00       	add    $0x3808,%eax
80108ab9:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108abc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108abf:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108ac5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ac8:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108aca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108acd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108ad3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ad6:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108adc:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108ae1:	05 10 38 00 00       	add    $0x3810,%eax
80108ae6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108ae9:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108aee:	05 18 38 00 00       	add    $0x3818,%eax
80108af3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108af6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108af9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108aff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b02:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108b08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b0b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108b0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b15:	e9 82 00 00 00       	jmp    80108b9c <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1d:	c1 e0 04             	shl    $0x4,%eax
80108b20:	89 c2                	mov    %eax,%edx
80108b22:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b25:	01 d0                	add    %edx,%eax
80108b27:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b31:	c1 e0 04             	shl    $0x4,%eax
80108b34:	89 c2                	mov    %eax,%edx
80108b36:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b39:	01 d0                	add    %edx,%eax
80108b3b:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b44:	c1 e0 04             	shl    $0x4,%eax
80108b47:	89 c2                	mov    %eax,%edx
80108b49:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b4c:	01 d0                	add    %edx,%eax
80108b4e:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b55:	c1 e0 04             	shl    $0x4,%eax
80108b58:	89 c2                	mov    %eax,%edx
80108b5a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b5d:	01 d0                	add    %edx,%eax
80108b5f:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b66:	c1 e0 04             	shl    $0x4,%eax
80108b69:	89 c2                	mov    %eax,%edx
80108b6b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b6e:	01 d0                	add    %edx,%eax
80108b70:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b77:	c1 e0 04             	shl    $0x4,%eax
80108b7a:	89 c2                	mov    %eax,%edx
80108b7c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b7f:	01 d0                	add    %edx,%eax
80108b81:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b88:	c1 e0 04             	shl    $0x4,%eax
80108b8b:	89 c2                	mov    %eax,%edx
80108b8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b90:	01 d0                	add    %edx,%eax
80108b92:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108b98:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108b9c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108ba3:	0f 8e 71 ff ff ff    	jle    80108b1a <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108ba9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108bb0:	eb 57                	jmp    80108c09 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108bb2:	e8 db 9c ff ff       	call   80102892 <kalloc>
80108bb7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108bba:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108bbe:	75 12                	jne    80108bd2 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108bc0:	83 ec 0c             	sub    $0xc,%esp
80108bc3:	68 78 c1 10 80       	push   $0x8010c178
80108bc8:	e8 3f 78 ff ff       	call   8010040c <cprintf>
80108bcd:	83 c4 10             	add    $0x10,%esp
      break;
80108bd0:	eb 3d                	jmp    80108c0f <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bd5:	c1 e0 04             	shl    $0x4,%eax
80108bd8:	89 c2                	mov    %eax,%edx
80108bda:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bdd:	01 d0                	add    %edx,%eax
80108bdf:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108be2:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108be8:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bed:	83 c0 01             	add    $0x1,%eax
80108bf0:	c1 e0 04             	shl    $0x4,%eax
80108bf3:	89 c2                	mov    %eax,%edx
80108bf5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108bf8:	01 d0                	add    %edx,%eax
80108bfa:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108bfd:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108c03:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108c05:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108c09:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108c0d:	7e a3                	jle    80108bb2 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108c0f:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108c14:	05 00 04 00 00       	add    $0x400,%eax
80108c19:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108c1c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c1f:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108c25:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108c2a:	05 10 04 00 00       	add    $0x410,%eax
80108c2f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108c32:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108c35:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108c3b:	83 ec 0c             	sub    $0xc,%esp
80108c3e:	68 b8 c1 10 80       	push   $0x8010c1b8
80108c43:	e8 c4 77 ff ff       	call   8010040c <cprintf>
80108c48:	83 c4 10             	add    $0x10,%esp

}
80108c4b:	90                   	nop
80108c4c:	c9                   	leave  
80108c4d:	c3                   	ret    

80108c4e <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108c4e:	f3 0f 1e fb          	endbr32 
80108c52:	55                   	push   %ebp
80108c53:	89 e5                	mov    %esp,%ebp
80108c55:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108c58:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108c5d:	83 c0 14             	add    $0x14,%eax
80108c60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108c63:	8b 45 08             	mov    0x8(%ebp),%eax
80108c66:	c1 e0 08             	shl    $0x8,%eax
80108c69:	0f b7 c0             	movzwl %ax,%eax
80108c6c:	83 c8 01             	or     $0x1,%eax
80108c6f:	89 c2                	mov    %eax,%edx
80108c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c74:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108c76:	83 ec 0c             	sub    $0xc,%esp
80108c79:	68 d8 c1 10 80       	push   $0x8010c1d8
80108c7e:	e8 89 77 ff ff       	call   8010040c <cprintf>
80108c83:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c89:	8b 00                	mov    (%eax),%eax
80108c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108c8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c91:	83 e0 10             	and    $0x10,%eax
80108c94:	85 c0                	test   %eax,%eax
80108c96:	75 02                	jne    80108c9a <i8254_read_eeprom+0x4c>
  while(1){
80108c98:	eb dc                	jmp    80108c76 <i8254_read_eeprom+0x28>
      break;
80108c9a:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9e:	8b 00                	mov    (%eax),%eax
80108ca0:	c1 e8 10             	shr    $0x10,%eax
}
80108ca3:	c9                   	leave  
80108ca4:	c3                   	ret    

80108ca5 <i8254_recv>:
void i8254_recv(){
80108ca5:	f3 0f 1e fb          	endbr32 
80108ca9:	55                   	push   %ebp
80108caa:	89 e5                	mov    %esp,%ebp
80108cac:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108caf:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108cb4:	05 10 28 00 00       	add    $0x2810,%eax
80108cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108cbc:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108cc1:	05 18 28 00 00       	add    $0x2818,%eax
80108cc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108cc9:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108cce:	05 00 28 00 00       	add    $0x2800,%eax
80108cd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108cd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cd9:	8b 00                	mov    (%eax),%eax
80108cdb:	05 00 00 00 80       	add    $0x80000000,%eax
80108ce0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce6:	8b 10                	mov    (%eax),%edx
80108ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ceb:	8b 00                	mov    (%eax),%eax
80108ced:	29 c2                	sub    %eax,%edx
80108cef:	89 d0                	mov    %edx,%eax
80108cf1:	25 ff 00 00 00       	and    $0xff,%eax
80108cf6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108cf9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108cfd:	7e 37                	jle    80108d36 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d02:	8b 00                	mov    (%eax),%eax
80108d04:	c1 e0 04             	shl    $0x4,%eax
80108d07:	89 c2                	mov    %eax,%edx
80108d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d0c:	01 d0                	add    %edx,%eax
80108d0e:	8b 00                	mov    (%eax),%eax
80108d10:	05 00 00 00 80       	add    $0x80000000,%eax
80108d15:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d1b:	8b 00                	mov    (%eax),%eax
80108d1d:	83 c0 01             	add    $0x1,%eax
80108d20:	0f b6 d0             	movzbl %al,%edx
80108d23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d26:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108d28:	83 ec 0c             	sub    $0xc,%esp
80108d2b:	ff 75 e0             	pushl  -0x20(%ebp)
80108d2e:	e8 47 09 00 00       	call   8010967a <eth_proc>
80108d33:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d39:	8b 10                	mov    (%eax),%edx
80108d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d3e:	8b 00                	mov    (%eax),%eax
80108d40:	39 c2                	cmp    %eax,%edx
80108d42:	75 9f                	jne    80108ce3 <i8254_recv+0x3e>
      (*rdt)--;
80108d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d47:	8b 00                	mov    (%eax),%eax
80108d49:	8d 50 ff             	lea    -0x1(%eax),%edx
80108d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d4f:	89 10                	mov    %edx,(%eax)
  while(1){
80108d51:	eb 90                	jmp    80108ce3 <i8254_recv+0x3e>

80108d53 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108d53:	f3 0f 1e fb          	endbr32 
80108d57:	55                   	push   %ebp
80108d58:	89 e5                	mov    %esp,%ebp
80108d5a:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d5d:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108d62:	05 10 38 00 00       	add    $0x3810,%eax
80108d67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d6a:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108d6f:	05 18 38 00 00       	add    $0x3818,%eax
80108d74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108d77:	a1 b4 7f 19 80       	mov    0x80197fb4,%eax
80108d7c:	05 00 38 00 00       	add    $0x3800,%eax
80108d81:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108d84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d87:	8b 00                	mov    (%eax),%eax
80108d89:	05 00 00 00 80       	add    $0x80000000,%eax
80108d8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d94:	8b 10                	mov    (%eax),%edx
80108d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d99:	8b 00                	mov    (%eax),%eax
80108d9b:	29 c2                	sub    %eax,%edx
80108d9d:	89 d0                	mov    %edx,%eax
80108d9f:	0f b6 c0             	movzbl %al,%eax
80108da2:	ba 00 01 00 00       	mov    $0x100,%edx
80108da7:	29 c2                	sub    %eax,%edx
80108da9:	89 d0                	mov    %edx,%eax
80108dab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108db1:	8b 00                	mov    (%eax),%eax
80108db3:	25 ff 00 00 00       	and    $0xff,%eax
80108db8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108dbb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108dbf:	0f 8e a8 00 00 00    	jle    80108e6d <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80108dc8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108dcb:	89 d1                	mov    %edx,%ecx
80108dcd:	c1 e1 04             	shl    $0x4,%ecx
80108dd0:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108dd3:	01 ca                	add    %ecx,%edx
80108dd5:	8b 12                	mov    (%edx),%edx
80108dd7:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108ddd:	83 ec 04             	sub    $0x4,%esp
80108de0:	ff 75 0c             	pushl  0xc(%ebp)
80108de3:	50                   	push   %eax
80108de4:	52                   	push   %edx
80108de5:	e8 31 be ff ff       	call   80104c1b <memmove>
80108dea:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108ded:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108df0:	c1 e0 04             	shl    $0x4,%eax
80108df3:	89 c2                	mov    %eax,%edx
80108df5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108df8:	01 d0                	add    %edx,%eax
80108dfa:	8b 55 0c             	mov    0xc(%ebp),%edx
80108dfd:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108e01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e04:	c1 e0 04             	shl    $0x4,%eax
80108e07:	89 c2                	mov    %eax,%edx
80108e09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e0c:	01 d0                	add    %edx,%eax
80108e0e:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108e12:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e15:	c1 e0 04             	shl    $0x4,%eax
80108e18:	89 c2                	mov    %eax,%edx
80108e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e1d:	01 d0                	add    %edx,%eax
80108e1f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108e23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e26:	c1 e0 04             	shl    $0x4,%eax
80108e29:	89 c2                	mov    %eax,%edx
80108e2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e2e:	01 d0                	add    %edx,%eax
80108e30:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108e34:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e37:	c1 e0 04             	shl    $0x4,%eax
80108e3a:	89 c2                	mov    %eax,%edx
80108e3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e3f:	01 d0                	add    %edx,%eax
80108e41:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e4a:	c1 e0 04             	shl    $0x4,%eax
80108e4d:	89 c2                	mov    %eax,%edx
80108e4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e52:	01 d0                	add    %edx,%eax
80108e54:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e5b:	8b 00                	mov    (%eax),%eax
80108e5d:	83 c0 01             	add    $0x1,%eax
80108e60:	0f b6 d0             	movzbl %al,%edx
80108e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e66:	89 10                	mov    %edx,(%eax)
    return len;
80108e68:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e6b:	eb 05                	jmp    80108e72 <i8254_send+0x11f>
  }else{
    return -1;
80108e6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108e72:	c9                   	leave  
80108e73:	c3                   	ret    

80108e74 <i8254_intr>:

void i8254_intr(){
80108e74:	f3 0f 1e fb          	endbr32 
80108e78:	55                   	push   %ebp
80108e79:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108e7b:	a1 b8 7f 19 80       	mov    0x80197fb8,%eax
80108e80:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108e86:	90                   	nop
80108e87:	5d                   	pop    %ebp
80108e88:	c3                   	ret    

80108e89 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108e89:	f3 0f 1e fb          	endbr32 
80108e8d:	55                   	push   %ebp
80108e8e:	89 e5                	mov    %esp,%ebp
80108e90:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108e93:	8b 45 08             	mov    0x8(%ebp),%eax
80108e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9c:	0f b7 00             	movzwl (%eax),%eax
80108e9f:	66 3d 00 01          	cmp    $0x100,%ax
80108ea3:	74 0a                	je     80108eaf <arp_proc+0x26>
80108ea5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108eaa:	e9 4f 01 00 00       	jmp    80108ffe <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb2:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108eb6:	66 83 f8 08          	cmp    $0x8,%ax
80108eba:	74 0a                	je     80108ec6 <arp_proc+0x3d>
80108ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ec1:	e9 38 01 00 00       	jmp    80108ffe <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80108ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ec9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108ecd:	3c 06                	cmp    $0x6,%al
80108ecf:	74 0a                	je     80108edb <arp_proc+0x52>
80108ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ed6:	e9 23 01 00 00       	jmp    80108ffe <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80108edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ede:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108ee2:	3c 04                	cmp    $0x4,%al
80108ee4:	74 0a                	je     80108ef0 <arp_proc+0x67>
80108ee6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108eeb:	e9 0e 01 00 00       	jmp    80108ffe <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef3:	83 c0 18             	add    $0x18,%eax
80108ef6:	83 ec 04             	sub    $0x4,%esp
80108ef9:	6a 04                	push   $0x4
80108efb:	50                   	push   %eax
80108efc:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f01:	e8 b9 bc ff ff       	call   80104bbf <memcmp>
80108f06:	83 c4 10             	add    $0x10,%esp
80108f09:	85 c0                	test   %eax,%eax
80108f0b:	74 27                	je     80108f34 <arp_proc+0xab>
80108f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f10:	83 c0 0e             	add    $0xe,%eax
80108f13:	83 ec 04             	sub    $0x4,%esp
80108f16:	6a 04                	push   $0x4
80108f18:	50                   	push   %eax
80108f19:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f1e:	e8 9c bc ff ff       	call   80104bbf <memcmp>
80108f23:	83 c4 10             	add    $0x10,%esp
80108f26:	85 c0                	test   %eax,%eax
80108f28:	74 0a                	je     80108f34 <arp_proc+0xab>
80108f2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f2f:	e9 ca 00 00 00       	jmp    80108ffe <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f37:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108f3b:	66 3d 00 01          	cmp    $0x100,%ax
80108f3f:	75 69                	jne    80108faa <arp_proc+0x121>
80108f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f44:	83 c0 18             	add    $0x18,%eax
80108f47:	83 ec 04             	sub    $0x4,%esp
80108f4a:	6a 04                	push   $0x4
80108f4c:	50                   	push   %eax
80108f4d:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f52:	e8 68 bc ff ff       	call   80104bbf <memcmp>
80108f57:	83 c4 10             	add    $0x10,%esp
80108f5a:	85 c0                	test   %eax,%eax
80108f5c:	75 4c                	jne    80108faa <arp_proc+0x121>
    uint send = (uint)kalloc();
80108f5e:	e8 2f 99 ff ff       	call   80102892 <kalloc>
80108f63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108f66:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108f6d:	83 ec 04             	sub    $0x4,%esp
80108f70:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108f73:	50                   	push   %eax
80108f74:	ff 75 f0             	pushl  -0x10(%ebp)
80108f77:	ff 75 f4             	pushl  -0xc(%ebp)
80108f7a:	e8 33 04 00 00       	call   801093b2 <arp_reply_pkt_create>
80108f7f:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108f82:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f85:	83 ec 08             	sub    $0x8,%esp
80108f88:	50                   	push   %eax
80108f89:	ff 75 f0             	pushl  -0x10(%ebp)
80108f8c:	e8 c2 fd ff ff       	call   80108d53 <i8254_send>
80108f91:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f97:	83 ec 0c             	sub    $0xc,%esp
80108f9a:	50                   	push   %eax
80108f9b:	e8 54 98 ff ff       	call   801027f4 <kfree>
80108fa0:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108fa3:	b8 02 00 00 00       	mov    $0x2,%eax
80108fa8:	eb 54                	jmp    80108ffe <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fad:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108fb1:	66 3d 00 02          	cmp    $0x200,%ax
80108fb5:	75 42                	jne    80108ff9 <arp_proc+0x170>
80108fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fba:	83 c0 18             	add    $0x18,%eax
80108fbd:	83 ec 04             	sub    $0x4,%esp
80108fc0:	6a 04                	push   $0x4
80108fc2:	50                   	push   %eax
80108fc3:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fc8:	e8 f2 bb ff ff       	call   80104bbf <memcmp>
80108fcd:	83 c4 10             	add    $0x10,%esp
80108fd0:	85 c0                	test   %eax,%eax
80108fd2:	75 25                	jne    80108ff9 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80108fd4:	83 ec 0c             	sub    $0xc,%esp
80108fd7:	68 dc c1 10 80       	push   $0x8010c1dc
80108fdc:	e8 2b 74 ff ff       	call   8010040c <cprintf>
80108fe1:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108fe4:	83 ec 0c             	sub    $0xc,%esp
80108fe7:	ff 75 f4             	pushl  -0xc(%ebp)
80108fea:	e8 b7 01 00 00       	call   801091a6 <arp_table_update>
80108fef:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108ff2:	b8 01 00 00 00       	mov    $0x1,%eax
80108ff7:	eb 05                	jmp    80108ffe <arp_proc+0x175>
  }else{
    return -1;
80108ff9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108ffe:	c9                   	leave  
80108fff:	c3                   	ret    

80109000 <arp_scan>:

void arp_scan(){
80109000:	f3 0f 1e fb          	endbr32 
80109004:	55                   	push   %ebp
80109005:	89 e5                	mov    %esp,%ebp
80109007:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010900a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109011:	eb 6f                	jmp    80109082 <arp_scan+0x82>
    uint send = (uint)kalloc();
80109013:	e8 7a 98 ff ff       	call   80102892 <kalloc>
80109018:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010901b:	83 ec 04             	sub    $0x4,%esp
8010901e:	ff 75 f4             	pushl  -0xc(%ebp)
80109021:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109024:	50                   	push   %eax
80109025:	ff 75 ec             	pushl  -0x14(%ebp)
80109028:	e8 62 00 00 00       	call   8010908f <arp_broadcast>
8010902d:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109030:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109033:	83 ec 08             	sub    $0x8,%esp
80109036:	50                   	push   %eax
80109037:	ff 75 ec             	pushl  -0x14(%ebp)
8010903a:	e8 14 fd ff ff       	call   80108d53 <i8254_send>
8010903f:	83 c4 10             	add    $0x10,%esp
80109042:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109045:	eb 22                	jmp    80109069 <arp_scan+0x69>
      microdelay(1);
80109047:	83 ec 0c             	sub    $0xc,%esp
8010904a:	6a 01                	push   $0x1
8010904c:	e8 f3 9b ff ff       	call   80102c44 <microdelay>
80109051:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109054:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109057:	83 ec 08             	sub    $0x8,%esp
8010905a:	50                   	push   %eax
8010905b:	ff 75 ec             	pushl  -0x14(%ebp)
8010905e:	e8 f0 fc ff ff       	call   80108d53 <i8254_send>
80109063:	83 c4 10             	add    $0x10,%esp
80109066:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109069:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010906d:	74 d8                	je     80109047 <arp_scan+0x47>
    }
    kfree((char *)send);
8010906f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109072:	83 ec 0c             	sub    $0xc,%esp
80109075:	50                   	push   %eax
80109076:	e8 79 97 ff ff       	call   801027f4 <kfree>
8010907b:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010907e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109082:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109089:	7e 88                	jle    80109013 <arp_scan+0x13>
  }
}
8010908b:	90                   	nop
8010908c:	90                   	nop
8010908d:	c9                   	leave  
8010908e:	c3                   	ret    

8010908f <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010908f:	f3 0f 1e fb          	endbr32 
80109093:	55                   	push   %ebp
80109094:	89 e5                	mov    %esp,%ebp
80109096:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109099:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010909d:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801090a1:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801090a5:	8b 45 10             	mov    0x10(%ebp),%eax
801090a8:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801090ab:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801090b2:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801090b8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801090bf:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801090c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801090c8:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801090ce:	8b 45 08             	mov    0x8(%ebp),%eax
801090d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801090d4:	8b 45 08             	mov    0x8(%ebp),%eax
801090d7:	83 c0 0e             	add    $0xe,%eax
801090da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801090dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e0:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801090e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e7:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801090eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ee:	83 ec 04             	sub    $0x4,%esp
801090f1:	6a 06                	push   $0x6
801090f3:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801090f6:	52                   	push   %edx
801090f7:	50                   	push   %eax
801090f8:	e8 1e bb ff ff       	call   80104c1b <memmove>
801090fd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109103:	83 c0 06             	add    $0x6,%eax
80109106:	83 ec 04             	sub    $0x4,%esp
80109109:	6a 06                	push   $0x6
8010910b:	68 68 d0 18 80       	push   $0x8018d068
80109110:	50                   	push   %eax
80109111:	e8 05 bb ff ff       	call   80104c1b <memmove>
80109116:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010911c:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109121:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109124:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010912a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010912d:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109134:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109138:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010913b:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109141:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109144:	8d 50 12             	lea    0x12(%eax),%edx
80109147:	83 ec 04             	sub    $0x4,%esp
8010914a:	6a 06                	push   $0x6
8010914c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010914f:	50                   	push   %eax
80109150:	52                   	push   %edx
80109151:	e8 c5 ba ff ff       	call   80104c1b <memmove>
80109156:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109159:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010915c:	8d 50 18             	lea    0x18(%eax),%edx
8010915f:	83 ec 04             	sub    $0x4,%esp
80109162:	6a 04                	push   $0x4
80109164:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109167:	50                   	push   %eax
80109168:	52                   	push   %edx
80109169:	e8 ad ba ff ff       	call   80104c1b <memmove>
8010916e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109171:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109174:	83 c0 08             	add    $0x8,%eax
80109177:	83 ec 04             	sub    $0x4,%esp
8010917a:	6a 06                	push   $0x6
8010917c:	68 68 d0 18 80       	push   $0x8018d068
80109181:	50                   	push   %eax
80109182:	e8 94 ba ff ff       	call   80104c1b <memmove>
80109187:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010918a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010918d:	83 c0 0e             	add    $0xe,%eax
80109190:	83 ec 04             	sub    $0x4,%esp
80109193:	6a 04                	push   $0x4
80109195:	68 e4 f4 10 80       	push   $0x8010f4e4
8010919a:	50                   	push   %eax
8010919b:	e8 7b ba ff ff       	call   80104c1b <memmove>
801091a0:	83 c4 10             	add    $0x10,%esp
}
801091a3:	90                   	nop
801091a4:	c9                   	leave  
801091a5:	c3                   	ret    

801091a6 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801091a6:	f3 0f 1e fb          	endbr32 
801091aa:	55                   	push   %ebp
801091ab:	89 e5                	mov    %esp,%ebp
801091ad:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801091b0:	8b 45 08             	mov    0x8(%ebp),%eax
801091b3:	83 c0 0e             	add    $0xe,%eax
801091b6:	83 ec 0c             	sub    $0xc,%esp
801091b9:	50                   	push   %eax
801091ba:	e8 bc 00 00 00       	call   8010927b <arp_table_search>
801091bf:	83 c4 10             	add    $0x10,%esp
801091c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801091c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801091c9:	78 2d                	js     801091f8 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801091cb:	8b 45 08             	mov    0x8(%ebp),%eax
801091ce:	8d 48 08             	lea    0x8(%eax),%ecx
801091d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091d4:	89 d0                	mov    %edx,%eax
801091d6:	c1 e0 02             	shl    $0x2,%eax
801091d9:	01 d0                	add    %edx,%eax
801091db:	01 c0                	add    %eax,%eax
801091dd:	01 d0                	add    %edx,%eax
801091df:	05 80 d0 18 80       	add    $0x8018d080,%eax
801091e4:	83 c0 04             	add    $0x4,%eax
801091e7:	83 ec 04             	sub    $0x4,%esp
801091ea:	6a 06                	push   $0x6
801091ec:	51                   	push   %ecx
801091ed:	50                   	push   %eax
801091ee:	e8 28 ba ff ff       	call   80104c1b <memmove>
801091f3:	83 c4 10             	add    $0x10,%esp
801091f6:	eb 70                	jmp    80109268 <arp_table_update+0xc2>
  }else{
    index += 1;
801091f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801091fc:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801091ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109202:	8d 48 08             	lea    0x8(%eax),%ecx
80109205:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109208:	89 d0                	mov    %edx,%eax
8010920a:	c1 e0 02             	shl    $0x2,%eax
8010920d:	01 d0                	add    %edx,%eax
8010920f:	01 c0                	add    %eax,%eax
80109211:	01 d0                	add    %edx,%eax
80109213:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109218:	83 c0 04             	add    $0x4,%eax
8010921b:	83 ec 04             	sub    $0x4,%esp
8010921e:	6a 06                	push   $0x6
80109220:	51                   	push   %ecx
80109221:	50                   	push   %eax
80109222:	e8 f4 b9 ff ff       	call   80104c1b <memmove>
80109227:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
8010922a:	8b 45 08             	mov    0x8(%ebp),%eax
8010922d:	8d 48 0e             	lea    0xe(%eax),%ecx
80109230:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109233:	89 d0                	mov    %edx,%eax
80109235:	c1 e0 02             	shl    $0x2,%eax
80109238:	01 d0                	add    %edx,%eax
8010923a:	01 c0                	add    %eax,%eax
8010923c:	01 d0                	add    %edx,%eax
8010923e:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109243:	83 ec 04             	sub    $0x4,%esp
80109246:	6a 04                	push   $0x4
80109248:	51                   	push   %ecx
80109249:	50                   	push   %eax
8010924a:	e8 cc b9 ff ff       	call   80104c1b <memmove>
8010924f:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109252:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109255:	89 d0                	mov    %edx,%eax
80109257:	c1 e0 02             	shl    $0x2,%eax
8010925a:	01 d0                	add    %edx,%eax
8010925c:	01 c0                	add    %eax,%eax
8010925e:	01 d0                	add    %edx,%eax
80109260:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109265:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109268:	83 ec 0c             	sub    $0xc,%esp
8010926b:	68 80 d0 18 80       	push   $0x8018d080
80109270:	e8 87 00 00 00       	call   801092fc <print_arp_table>
80109275:	83 c4 10             	add    $0x10,%esp
}
80109278:	90                   	nop
80109279:	c9                   	leave  
8010927a:	c3                   	ret    

8010927b <arp_table_search>:

int arp_table_search(uchar *ip){
8010927b:	f3 0f 1e fb          	endbr32 
8010927f:	55                   	push   %ebp
80109280:	89 e5                	mov    %esp,%ebp
80109282:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109285:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010928c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109293:	eb 59                	jmp    801092ee <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109295:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109298:	89 d0                	mov    %edx,%eax
8010929a:	c1 e0 02             	shl    $0x2,%eax
8010929d:	01 d0                	add    %edx,%eax
8010929f:	01 c0                	add    %eax,%eax
801092a1:	01 d0                	add    %edx,%eax
801092a3:	05 80 d0 18 80       	add    $0x8018d080,%eax
801092a8:	83 ec 04             	sub    $0x4,%esp
801092ab:	6a 04                	push   $0x4
801092ad:	ff 75 08             	pushl  0x8(%ebp)
801092b0:	50                   	push   %eax
801092b1:	e8 09 b9 ff ff       	call   80104bbf <memcmp>
801092b6:	83 c4 10             	add    $0x10,%esp
801092b9:	85 c0                	test   %eax,%eax
801092bb:	75 05                	jne    801092c2 <arp_table_search+0x47>
      return i;
801092bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092c0:	eb 38                	jmp    801092fa <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
801092c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801092c5:	89 d0                	mov    %edx,%eax
801092c7:	c1 e0 02             	shl    $0x2,%eax
801092ca:	01 d0                	add    %edx,%eax
801092cc:	01 c0                	add    %eax,%eax
801092ce:	01 d0                	add    %edx,%eax
801092d0:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801092d5:	0f b6 00             	movzbl (%eax),%eax
801092d8:	84 c0                	test   %al,%al
801092da:	75 0e                	jne    801092ea <arp_table_search+0x6f>
801092dc:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801092e0:	75 08                	jne    801092ea <arp_table_search+0x6f>
      empty = -i;
801092e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e5:	f7 d8                	neg    %eax
801092e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801092ea:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801092ee:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801092f2:	7e a1                	jle    80109295 <arp_table_search+0x1a>
    }
  }
  return empty-1;
801092f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f7:	83 e8 01             	sub    $0x1,%eax
}
801092fa:	c9                   	leave  
801092fb:	c3                   	ret    

801092fc <print_arp_table>:

void print_arp_table(){
801092fc:	f3 0f 1e fb          	endbr32 
80109300:	55                   	push   %ebp
80109301:	89 e5                	mov    %esp,%ebp
80109303:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109306:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010930d:	e9 92 00 00 00       	jmp    801093a4 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109312:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109315:	89 d0                	mov    %edx,%eax
80109317:	c1 e0 02             	shl    $0x2,%eax
8010931a:	01 d0                	add    %edx,%eax
8010931c:	01 c0                	add    %eax,%eax
8010931e:	01 d0                	add    %edx,%eax
80109320:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109325:	0f b6 00             	movzbl (%eax),%eax
80109328:	84 c0                	test   %al,%al
8010932a:	74 74                	je     801093a0 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
8010932c:	83 ec 08             	sub    $0x8,%esp
8010932f:	ff 75 f4             	pushl  -0xc(%ebp)
80109332:	68 ef c1 10 80       	push   $0x8010c1ef
80109337:	e8 d0 70 ff ff       	call   8010040c <cprintf>
8010933c:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010933f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109342:	89 d0                	mov    %edx,%eax
80109344:	c1 e0 02             	shl    $0x2,%eax
80109347:	01 d0                	add    %edx,%eax
80109349:	01 c0                	add    %eax,%eax
8010934b:	01 d0                	add    %edx,%eax
8010934d:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109352:	83 ec 0c             	sub    $0xc,%esp
80109355:	50                   	push   %eax
80109356:	e8 5c 02 00 00       	call   801095b7 <print_ipv4>
8010935b:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010935e:	83 ec 0c             	sub    $0xc,%esp
80109361:	68 fe c1 10 80       	push   $0x8010c1fe
80109366:	e8 a1 70 ff ff       	call   8010040c <cprintf>
8010936b:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
8010936e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109371:	89 d0                	mov    %edx,%eax
80109373:	c1 e0 02             	shl    $0x2,%eax
80109376:	01 d0                	add    %edx,%eax
80109378:	01 c0                	add    %eax,%eax
8010937a:	01 d0                	add    %edx,%eax
8010937c:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109381:	83 c0 04             	add    $0x4,%eax
80109384:	83 ec 0c             	sub    $0xc,%esp
80109387:	50                   	push   %eax
80109388:	e8 7c 02 00 00       	call   80109609 <print_mac>
8010938d:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109390:	83 ec 0c             	sub    $0xc,%esp
80109393:	68 00 c2 10 80       	push   $0x8010c200
80109398:	e8 6f 70 ff ff       	call   8010040c <cprintf>
8010939d:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801093a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801093a4:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801093a8:	0f 8e 64 ff ff ff    	jle    80109312 <print_arp_table+0x16>
    }
  }
}
801093ae:	90                   	nop
801093af:	90                   	nop
801093b0:	c9                   	leave  
801093b1:	c3                   	ret    

801093b2 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801093b2:	f3 0f 1e fb          	endbr32 
801093b6:	55                   	push   %ebp
801093b7:	89 e5                	mov    %esp,%ebp
801093b9:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801093bc:	8b 45 10             	mov    0x10(%ebp),%eax
801093bf:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801093c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801093c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801093cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801093ce:	83 c0 0e             	add    $0xe,%eax
801093d1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801093d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801093db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093de:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801093e2:	8b 45 08             	mov    0x8(%ebp),%eax
801093e5:	8d 50 08             	lea    0x8(%eax),%edx
801093e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093eb:	83 ec 04             	sub    $0x4,%esp
801093ee:	6a 06                	push   $0x6
801093f0:	52                   	push   %edx
801093f1:	50                   	push   %eax
801093f2:	e8 24 b8 ff ff       	call   80104c1b <memmove>
801093f7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801093fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093fd:	83 c0 06             	add    $0x6,%eax
80109400:	83 ec 04             	sub    $0x4,%esp
80109403:	6a 06                	push   $0x6
80109405:	68 68 d0 18 80       	push   $0x8018d068
8010940a:	50                   	push   %eax
8010940b:	e8 0b b8 ff ff       	call   80104c1b <memmove>
80109410:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109413:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109416:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010941b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010941e:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109424:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109427:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010942b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010942e:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109432:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109435:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010943b:	8b 45 08             	mov    0x8(%ebp),%eax
8010943e:	8d 50 08             	lea    0x8(%eax),%edx
80109441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109444:	83 c0 12             	add    $0x12,%eax
80109447:	83 ec 04             	sub    $0x4,%esp
8010944a:	6a 06                	push   $0x6
8010944c:	52                   	push   %edx
8010944d:	50                   	push   %eax
8010944e:	e8 c8 b7 ff ff       	call   80104c1b <memmove>
80109453:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109456:	8b 45 08             	mov    0x8(%ebp),%eax
80109459:	8d 50 0e             	lea    0xe(%eax),%edx
8010945c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010945f:	83 c0 18             	add    $0x18,%eax
80109462:	83 ec 04             	sub    $0x4,%esp
80109465:	6a 04                	push   $0x4
80109467:	52                   	push   %edx
80109468:	50                   	push   %eax
80109469:	e8 ad b7 ff ff       	call   80104c1b <memmove>
8010946e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109474:	83 c0 08             	add    $0x8,%eax
80109477:	83 ec 04             	sub    $0x4,%esp
8010947a:	6a 06                	push   $0x6
8010947c:	68 68 d0 18 80       	push   $0x8018d068
80109481:	50                   	push   %eax
80109482:	e8 94 b7 ff ff       	call   80104c1b <memmove>
80109487:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
8010948a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010948d:	83 c0 0e             	add    $0xe,%eax
80109490:	83 ec 04             	sub    $0x4,%esp
80109493:	6a 04                	push   $0x4
80109495:	68 e4 f4 10 80       	push   $0x8010f4e4
8010949a:	50                   	push   %eax
8010949b:	e8 7b b7 ff ff       	call   80104c1b <memmove>
801094a0:	83 c4 10             	add    $0x10,%esp
}
801094a3:	90                   	nop
801094a4:	c9                   	leave  
801094a5:	c3                   	ret    

801094a6 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801094a6:	f3 0f 1e fb          	endbr32 
801094aa:	55                   	push   %ebp
801094ab:	89 e5                	mov    %esp,%ebp
801094ad:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801094b0:	83 ec 0c             	sub    $0xc,%esp
801094b3:	68 02 c2 10 80       	push   $0x8010c202
801094b8:	e8 4f 6f ff ff       	call   8010040c <cprintf>
801094bd:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801094c0:	8b 45 08             	mov    0x8(%ebp),%eax
801094c3:	83 c0 0e             	add    $0xe,%eax
801094c6:	83 ec 0c             	sub    $0xc,%esp
801094c9:	50                   	push   %eax
801094ca:	e8 e8 00 00 00       	call   801095b7 <print_ipv4>
801094cf:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094d2:	83 ec 0c             	sub    $0xc,%esp
801094d5:	68 00 c2 10 80       	push   $0x8010c200
801094da:	e8 2d 6f ff ff       	call   8010040c <cprintf>
801094df:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801094e2:	8b 45 08             	mov    0x8(%ebp),%eax
801094e5:	83 c0 08             	add    $0x8,%eax
801094e8:	83 ec 0c             	sub    $0xc,%esp
801094eb:	50                   	push   %eax
801094ec:	e8 18 01 00 00       	call   80109609 <print_mac>
801094f1:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801094f4:	83 ec 0c             	sub    $0xc,%esp
801094f7:	68 00 c2 10 80       	push   $0x8010c200
801094fc:	e8 0b 6f ff ff       	call   8010040c <cprintf>
80109501:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109504:	83 ec 0c             	sub    $0xc,%esp
80109507:	68 19 c2 10 80       	push   $0x8010c219
8010950c:	e8 fb 6e ff ff       	call   8010040c <cprintf>
80109511:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109514:	8b 45 08             	mov    0x8(%ebp),%eax
80109517:	83 c0 18             	add    $0x18,%eax
8010951a:	83 ec 0c             	sub    $0xc,%esp
8010951d:	50                   	push   %eax
8010951e:	e8 94 00 00 00       	call   801095b7 <print_ipv4>
80109523:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109526:	83 ec 0c             	sub    $0xc,%esp
80109529:	68 00 c2 10 80       	push   $0x8010c200
8010952e:	e8 d9 6e ff ff       	call   8010040c <cprintf>
80109533:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109536:	8b 45 08             	mov    0x8(%ebp),%eax
80109539:	83 c0 12             	add    $0x12,%eax
8010953c:	83 ec 0c             	sub    $0xc,%esp
8010953f:	50                   	push   %eax
80109540:	e8 c4 00 00 00       	call   80109609 <print_mac>
80109545:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109548:	83 ec 0c             	sub    $0xc,%esp
8010954b:	68 00 c2 10 80       	push   $0x8010c200
80109550:	e8 b7 6e ff ff       	call   8010040c <cprintf>
80109555:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109558:	83 ec 0c             	sub    $0xc,%esp
8010955b:	68 30 c2 10 80       	push   $0x8010c230
80109560:	e8 a7 6e ff ff       	call   8010040c <cprintf>
80109565:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109568:	8b 45 08             	mov    0x8(%ebp),%eax
8010956b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010956f:	66 3d 00 01          	cmp    $0x100,%ax
80109573:	75 12                	jne    80109587 <print_arp_info+0xe1>
80109575:	83 ec 0c             	sub    $0xc,%esp
80109578:	68 3c c2 10 80       	push   $0x8010c23c
8010957d:	e8 8a 6e ff ff       	call   8010040c <cprintf>
80109582:	83 c4 10             	add    $0x10,%esp
80109585:	eb 1d                	jmp    801095a4 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109587:	8b 45 08             	mov    0x8(%ebp),%eax
8010958a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010958e:	66 3d 00 02          	cmp    $0x200,%ax
80109592:	75 10                	jne    801095a4 <print_arp_info+0xfe>
    cprintf("Reply\n");
80109594:	83 ec 0c             	sub    $0xc,%esp
80109597:	68 45 c2 10 80       	push   $0x8010c245
8010959c:	e8 6b 6e ff ff       	call   8010040c <cprintf>
801095a1:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801095a4:	83 ec 0c             	sub    $0xc,%esp
801095a7:	68 00 c2 10 80       	push   $0x8010c200
801095ac:	e8 5b 6e ff ff       	call   8010040c <cprintf>
801095b1:	83 c4 10             	add    $0x10,%esp
}
801095b4:	90                   	nop
801095b5:	c9                   	leave  
801095b6:	c3                   	ret    

801095b7 <print_ipv4>:

void print_ipv4(uchar *ip){
801095b7:	f3 0f 1e fb          	endbr32 
801095bb:	55                   	push   %ebp
801095bc:	89 e5                	mov    %esp,%ebp
801095be:	53                   	push   %ebx
801095bf:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801095c2:	8b 45 08             	mov    0x8(%ebp),%eax
801095c5:	83 c0 03             	add    $0x3,%eax
801095c8:	0f b6 00             	movzbl (%eax),%eax
801095cb:	0f b6 d8             	movzbl %al,%ebx
801095ce:	8b 45 08             	mov    0x8(%ebp),%eax
801095d1:	83 c0 02             	add    $0x2,%eax
801095d4:	0f b6 00             	movzbl (%eax),%eax
801095d7:	0f b6 c8             	movzbl %al,%ecx
801095da:	8b 45 08             	mov    0x8(%ebp),%eax
801095dd:	83 c0 01             	add    $0x1,%eax
801095e0:	0f b6 00             	movzbl (%eax),%eax
801095e3:	0f b6 d0             	movzbl %al,%edx
801095e6:	8b 45 08             	mov    0x8(%ebp),%eax
801095e9:	0f b6 00             	movzbl (%eax),%eax
801095ec:	0f b6 c0             	movzbl %al,%eax
801095ef:	83 ec 0c             	sub    $0xc,%esp
801095f2:	53                   	push   %ebx
801095f3:	51                   	push   %ecx
801095f4:	52                   	push   %edx
801095f5:	50                   	push   %eax
801095f6:	68 4c c2 10 80       	push   $0x8010c24c
801095fb:	e8 0c 6e ff ff       	call   8010040c <cprintf>
80109600:	83 c4 20             	add    $0x20,%esp
}
80109603:	90                   	nop
80109604:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109607:	c9                   	leave  
80109608:	c3                   	ret    

80109609 <print_mac>:

void print_mac(uchar *mac){
80109609:	f3 0f 1e fb          	endbr32 
8010960d:	55                   	push   %ebp
8010960e:	89 e5                	mov    %esp,%ebp
80109610:	57                   	push   %edi
80109611:	56                   	push   %esi
80109612:	53                   	push   %ebx
80109613:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109616:	8b 45 08             	mov    0x8(%ebp),%eax
80109619:	83 c0 05             	add    $0x5,%eax
8010961c:	0f b6 00             	movzbl (%eax),%eax
8010961f:	0f b6 f8             	movzbl %al,%edi
80109622:	8b 45 08             	mov    0x8(%ebp),%eax
80109625:	83 c0 04             	add    $0x4,%eax
80109628:	0f b6 00             	movzbl (%eax),%eax
8010962b:	0f b6 f0             	movzbl %al,%esi
8010962e:	8b 45 08             	mov    0x8(%ebp),%eax
80109631:	83 c0 03             	add    $0x3,%eax
80109634:	0f b6 00             	movzbl (%eax),%eax
80109637:	0f b6 d8             	movzbl %al,%ebx
8010963a:	8b 45 08             	mov    0x8(%ebp),%eax
8010963d:	83 c0 02             	add    $0x2,%eax
80109640:	0f b6 00             	movzbl (%eax),%eax
80109643:	0f b6 c8             	movzbl %al,%ecx
80109646:	8b 45 08             	mov    0x8(%ebp),%eax
80109649:	83 c0 01             	add    $0x1,%eax
8010964c:	0f b6 00             	movzbl (%eax),%eax
8010964f:	0f b6 d0             	movzbl %al,%edx
80109652:	8b 45 08             	mov    0x8(%ebp),%eax
80109655:	0f b6 00             	movzbl (%eax),%eax
80109658:	0f b6 c0             	movzbl %al,%eax
8010965b:	83 ec 04             	sub    $0x4,%esp
8010965e:	57                   	push   %edi
8010965f:	56                   	push   %esi
80109660:	53                   	push   %ebx
80109661:	51                   	push   %ecx
80109662:	52                   	push   %edx
80109663:	50                   	push   %eax
80109664:	68 64 c2 10 80       	push   $0x8010c264
80109669:	e8 9e 6d ff ff       	call   8010040c <cprintf>
8010966e:	83 c4 20             	add    $0x20,%esp
}
80109671:	90                   	nop
80109672:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109675:	5b                   	pop    %ebx
80109676:	5e                   	pop    %esi
80109677:	5f                   	pop    %edi
80109678:	5d                   	pop    %ebp
80109679:	c3                   	ret    

8010967a <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010967a:	f3 0f 1e fb          	endbr32 
8010967e:	55                   	push   %ebp
8010967f:	89 e5                	mov    %esp,%ebp
80109681:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109684:	8b 45 08             	mov    0x8(%ebp),%eax
80109687:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010968a:	8b 45 08             	mov    0x8(%ebp),%eax
8010968d:	83 c0 0e             	add    $0xe,%eax
80109690:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109696:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010969a:	3c 08                	cmp    $0x8,%al
8010969c:	75 1b                	jne    801096b9 <eth_proc+0x3f>
8010969e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096a1:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801096a5:	3c 06                	cmp    $0x6,%al
801096a7:	75 10                	jne    801096b9 <eth_proc+0x3f>
    arp_proc(pkt_addr);
801096a9:	83 ec 0c             	sub    $0xc,%esp
801096ac:	ff 75 f0             	pushl  -0x10(%ebp)
801096af:	e8 d5 f7 ff ff       	call   80108e89 <arp_proc>
801096b4:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801096b7:	eb 24                	jmp    801096dd <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801096b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096bc:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801096c0:	3c 08                	cmp    $0x8,%al
801096c2:	75 19                	jne    801096dd <eth_proc+0x63>
801096c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c7:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801096cb:	84 c0                	test   %al,%al
801096cd:	75 0e                	jne    801096dd <eth_proc+0x63>
    ipv4_proc(buffer_addr);
801096cf:	83 ec 0c             	sub    $0xc,%esp
801096d2:	ff 75 08             	pushl  0x8(%ebp)
801096d5:	e8 b3 00 00 00       	call   8010978d <ipv4_proc>
801096da:	83 c4 10             	add    $0x10,%esp
}
801096dd:	90                   	nop
801096de:	c9                   	leave  
801096df:	c3                   	ret    

801096e0 <N2H_ushort>:

ushort N2H_ushort(ushort value){
801096e0:	f3 0f 1e fb          	endbr32 
801096e4:	55                   	push   %ebp
801096e5:	89 e5                	mov    %esp,%ebp
801096e7:	83 ec 04             	sub    $0x4,%esp
801096ea:	8b 45 08             	mov    0x8(%ebp),%eax
801096ed:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801096f1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096f5:	c1 e0 08             	shl    $0x8,%eax
801096f8:	89 c2                	mov    %eax,%edx
801096fa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801096fe:	66 c1 e8 08          	shr    $0x8,%ax
80109702:	01 d0                	add    %edx,%eax
}
80109704:	c9                   	leave  
80109705:	c3                   	ret    

80109706 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109706:	f3 0f 1e fb          	endbr32 
8010970a:	55                   	push   %ebp
8010970b:	89 e5                	mov    %esp,%ebp
8010970d:	83 ec 04             	sub    $0x4,%esp
80109710:	8b 45 08             	mov    0x8(%ebp),%eax
80109713:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109717:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010971b:	c1 e0 08             	shl    $0x8,%eax
8010971e:	89 c2                	mov    %eax,%edx
80109720:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109724:	66 c1 e8 08          	shr    $0x8,%ax
80109728:	01 d0                	add    %edx,%eax
}
8010972a:	c9                   	leave  
8010972b:	c3                   	ret    

8010972c <H2N_uint>:

uint H2N_uint(uint value){
8010972c:	f3 0f 1e fb          	endbr32 
80109730:	55                   	push   %ebp
80109731:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109733:	8b 45 08             	mov    0x8(%ebp),%eax
80109736:	c1 e0 18             	shl    $0x18,%eax
80109739:	25 00 00 00 0f       	and    $0xf000000,%eax
8010973e:	89 c2                	mov    %eax,%edx
80109740:	8b 45 08             	mov    0x8(%ebp),%eax
80109743:	c1 e0 08             	shl    $0x8,%eax
80109746:	25 00 f0 00 00       	and    $0xf000,%eax
8010974b:	09 c2                	or     %eax,%edx
8010974d:	8b 45 08             	mov    0x8(%ebp),%eax
80109750:	c1 e8 08             	shr    $0x8,%eax
80109753:	83 e0 0f             	and    $0xf,%eax
80109756:	01 d0                	add    %edx,%eax
}
80109758:	5d                   	pop    %ebp
80109759:	c3                   	ret    

8010975a <N2H_uint>:

uint N2H_uint(uint value){
8010975a:	f3 0f 1e fb          	endbr32 
8010975e:	55                   	push   %ebp
8010975f:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109761:	8b 45 08             	mov    0x8(%ebp),%eax
80109764:	c1 e0 18             	shl    $0x18,%eax
80109767:	89 c2                	mov    %eax,%edx
80109769:	8b 45 08             	mov    0x8(%ebp),%eax
8010976c:	c1 e0 08             	shl    $0x8,%eax
8010976f:	25 00 00 ff 00       	and    $0xff0000,%eax
80109774:	01 c2                	add    %eax,%edx
80109776:	8b 45 08             	mov    0x8(%ebp),%eax
80109779:	c1 e8 08             	shr    $0x8,%eax
8010977c:	25 00 ff 00 00       	and    $0xff00,%eax
80109781:	01 c2                	add    %eax,%edx
80109783:	8b 45 08             	mov    0x8(%ebp),%eax
80109786:	c1 e8 18             	shr    $0x18,%eax
80109789:	01 d0                	add    %edx,%eax
}
8010978b:	5d                   	pop    %ebp
8010978c:	c3                   	ret    

8010978d <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010978d:	f3 0f 1e fb          	endbr32 
80109791:	55                   	push   %ebp
80109792:	89 e5                	mov    %esp,%ebp
80109794:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109797:	8b 45 08             	mov    0x8(%ebp),%eax
8010979a:	83 c0 0e             	add    $0xe,%eax
8010979d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801097a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801097a7:	0f b7 d0             	movzwl %ax,%edx
801097aa:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801097af:	39 c2                	cmp    %eax,%edx
801097b1:	74 60                	je     80109813 <ipv4_proc+0x86>
801097b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b6:	83 c0 0c             	add    $0xc,%eax
801097b9:	83 ec 04             	sub    $0x4,%esp
801097bc:	6a 04                	push   $0x4
801097be:	50                   	push   %eax
801097bf:	68 e4 f4 10 80       	push   $0x8010f4e4
801097c4:	e8 f6 b3 ff ff       	call   80104bbf <memcmp>
801097c9:	83 c4 10             	add    $0x10,%esp
801097cc:	85 c0                	test   %eax,%eax
801097ce:	74 43                	je     80109813 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
801097d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097d3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801097d7:	0f b7 c0             	movzwl %ax,%eax
801097da:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801097df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e2:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801097e6:	3c 01                	cmp    $0x1,%al
801097e8:	75 10                	jne    801097fa <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
801097ea:	83 ec 0c             	sub    $0xc,%esp
801097ed:	ff 75 08             	pushl  0x8(%ebp)
801097f0:	e8 a7 00 00 00       	call   8010989c <icmp_proc>
801097f5:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801097f8:	eb 19                	jmp    80109813 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801097fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097fd:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109801:	3c 06                	cmp    $0x6,%al
80109803:	75 0e                	jne    80109813 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109805:	83 ec 0c             	sub    $0xc,%esp
80109808:	ff 75 08             	pushl  0x8(%ebp)
8010980b:	e8 c7 03 00 00       	call   80109bd7 <tcp_proc>
80109810:	83 c4 10             	add    $0x10,%esp
}
80109813:	90                   	nop
80109814:	c9                   	leave  
80109815:	c3                   	ret    

80109816 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109816:	f3 0f 1e fb          	endbr32 
8010981a:	55                   	push   %ebp
8010981b:	89 e5                	mov    %esp,%ebp
8010981d:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109820:	8b 45 08             	mov    0x8(%ebp),%eax
80109823:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109829:	0f b6 00             	movzbl (%eax),%eax
8010982c:	83 e0 0f             	and    $0xf,%eax
8010982f:	01 c0                	add    %eax,%eax
80109831:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109834:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010983b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109842:	eb 48                	jmp    8010988c <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109844:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109847:	01 c0                	add    %eax,%eax
80109849:	89 c2                	mov    %eax,%edx
8010984b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010984e:	01 d0                	add    %edx,%eax
80109850:	0f b6 00             	movzbl (%eax),%eax
80109853:	0f b6 c0             	movzbl %al,%eax
80109856:	c1 e0 08             	shl    $0x8,%eax
80109859:	89 c2                	mov    %eax,%edx
8010985b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010985e:	01 c0                	add    %eax,%eax
80109860:	8d 48 01             	lea    0x1(%eax),%ecx
80109863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109866:	01 c8                	add    %ecx,%eax
80109868:	0f b6 00             	movzbl (%eax),%eax
8010986b:	0f b6 c0             	movzbl %al,%eax
8010986e:	01 d0                	add    %edx,%eax
80109870:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109873:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010987a:	76 0c                	jbe    80109888 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
8010987c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010987f:	0f b7 c0             	movzwl %ax,%eax
80109882:	83 c0 01             	add    $0x1,%eax
80109885:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109888:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010988c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109890:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109893:	7c af                	jl     80109844 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109895:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109898:	f7 d0                	not    %eax
}
8010989a:	c9                   	leave  
8010989b:	c3                   	ret    

8010989c <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010989c:	f3 0f 1e fb          	endbr32 
801098a0:	55                   	push   %ebp
801098a1:	89 e5                	mov    %esp,%ebp
801098a3:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801098a6:	8b 45 08             	mov    0x8(%ebp),%eax
801098a9:	83 c0 0e             	add    $0xe,%eax
801098ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801098af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b2:	0f b6 00             	movzbl (%eax),%eax
801098b5:	0f b6 c0             	movzbl %al,%eax
801098b8:	83 e0 0f             	and    $0xf,%eax
801098bb:	c1 e0 02             	shl    $0x2,%eax
801098be:	89 c2                	mov    %eax,%edx
801098c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098c3:	01 d0                	add    %edx,%eax
801098c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801098c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098cb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801098cf:	84 c0                	test   %al,%al
801098d1:	75 4f                	jne    80109922 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801098d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d6:	0f b6 00             	movzbl (%eax),%eax
801098d9:	3c 08                	cmp    $0x8,%al
801098db:	75 45                	jne    80109922 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
801098dd:	e8 b0 8f ff ff       	call   80102892 <kalloc>
801098e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801098e5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801098ec:	83 ec 04             	sub    $0x4,%esp
801098ef:	8d 45 e8             	lea    -0x18(%ebp),%eax
801098f2:	50                   	push   %eax
801098f3:	ff 75 ec             	pushl  -0x14(%ebp)
801098f6:	ff 75 08             	pushl  0x8(%ebp)
801098f9:	e8 7c 00 00 00       	call   8010997a <icmp_reply_pkt_create>
801098fe:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109901:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109904:	83 ec 08             	sub    $0x8,%esp
80109907:	50                   	push   %eax
80109908:	ff 75 ec             	pushl  -0x14(%ebp)
8010990b:	e8 43 f4 ff ff       	call   80108d53 <i8254_send>
80109910:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109913:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109916:	83 ec 0c             	sub    $0xc,%esp
80109919:	50                   	push   %eax
8010991a:	e8 d5 8e ff ff       	call   801027f4 <kfree>
8010991f:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109922:	90                   	nop
80109923:	c9                   	leave  
80109924:	c3                   	ret    

80109925 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109925:	f3 0f 1e fb          	endbr32 
80109929:	55                   	push   %ebp
8010992a:	89 e5                	mov    %esp,%ebp
8010992c:	53                   	push   %ebx
8010992d:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109930:	8b 45 08             	mov    0x8(%ebp),%eax
80109933:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109937:	0f b7 c0             	movzwl %ax,%eax
8010993a:	83 ec 0c             	sub    $0xc,%esp
8010993d:	50                   	push   %eax
8010993e:	e8 9d fd ff ff       	call   801096e0 <N2H_ushort>
80109943:	83 c4 10             	add    $0x10,%esp
80109946:	0f b7 d8             	movzwl %ax,%ebx
80109949:	8b 45 08             	mov    0x8(%ebp),%eax
8010994c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109950:	0f b7 c0             	movzwl %ax,%eax
80109953:	83 ec 0c             	sub    $0xc,%esp
80109956:	50                   	push   %eax
80109957:	e8 84 fd ff ff       	call   801096e0 <N2H_ushort>
8010995c:	83 c4 10             	add    $0x10,%esp
8010995f:	0f b7 c0             	movzwl %ax,%eax
80109962:	83 ec 04             	sub    $0x4,%esp
80109965:	53                   	push   %ebx
80109966:	50                   	push   %eax
80109967:	68 83 c2 10 80       	push   $0x8010c283
8010996c:	e8 9b 6a ff ff       	call   8010040c <cprintf>
80109971:	83 c4 10             	add    $0x10,%esp
}
80109974:	90                   	nop
80109975:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109978:	c9                   	leave  
80109979:	c3                   	ret    

8010997a <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010997a:	f3 0f 1e fb          	endbr32 
8010997e:	55                   	push   %ebp
8010997f:	89 e5                	mov    %esp,%ebp
80109981:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109984:	8b 45 08             	mov    0x8(%ebp),%eax
80109987:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010998a:	8b 45 08             	mov    0x8(%ebp),%eax
8010998d:	83 c0 0e             	add    $0xe,%eax
80109990:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109993:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109996:	0f b6 00             	movzbl (%eax),%eax
80109999:	0f b6 c0             	movzbl %al,%eax
8010999c:	83 e0 0f             	and    $0xf,%eax
8010999f:	c1 e0 02             	shl    $0x2,%eax
801099a2:	89 c2                	mov    %eax,%edx
801099a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099a7:	01 d0                	add    %edx,%eax
801099a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
801099ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801099af:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801099b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801099b5:	83 c0 0e             	add    $0xe,%eax
801099b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801099bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801099be:	83 c0 14             	add    $0x14,%eax
801099c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801099c4:	8b 45 10             	mov    0x10(%ebp),%eax
801099c7:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801099cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d0:	8d 50 06             	lea    0x6(%eax),%edx
801099d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099d6:	83 ec 04             	sub    $0x4,%esp
801099d9:	6a 06                	push   $0x6
801099db:	52                   	push   %edx
801099dc:	50                   	push   %eax
801099dd:	e8 39 b2 ff ff       	call   80104c1b <memmove>
801099e2:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801099e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099e8:	83 c0 06             	add    $0x6,%eax
801099eb:	83 ec 04             	sub    $0x4,%esp
801099ee:	6a 06                	push   $0x6
801099f0:	68 68 d0 18 80       	push   $0x8018d068
801099f5:	50                   	push   %eax
801099f6:	e8 20 b2 ff ff       	call   80104c1b <memmove>
801099fb:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801099fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a01:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109a05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a08:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109a0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a0f:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109a12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a15:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109a19:	83 ec 0c             	sub    $0xc,%esp
80109a1c:	6a 54                	push   $0x54
80109a1e:	e8 e3 fc ff ff       	call   80109706 <H2N_ushort>
80109a23:	83 c4 10             	add    $0x10,%esp
80109a26:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109a29:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109a2d:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a37:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109a3b:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109a42:	83 c0 01             	add    $0x1,%eax
80109a45:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109a4b:	83 ec 0c             	sub    $0xc,%esp
80109a4e:	68 00 40 00 00       	push   $0x4000
80109a53:	e8 ae fc ff ff       	call   80109706 <H2N_ushort>
80109a58:	83 c4 10             	add    $0x10,%esp
80109a5b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109a5e:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109a62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a65:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109a69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a6c:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109a70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a73:	83 c0 0c             	add    $0xc,%eax
80109a76:	83 ec 04             	sub    $0x4,%esp
80109a79:	6a 04                	push   $0x4
80109a7b:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a80:	50                   	push   %eax
80109a81:	e8 95 b1 ff ff       	call   80104c1b <memmove>
80109a86:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a8c:	8d 50 0c             	lea    0xc(%eax),%edx
80109a8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109a92:	83 c0 10             	add    $0x10,%eax
80109a95:	83 ec 04             	sub    $0x4,%esp
80109a98:	6a 04                	push   $0x4
80109a9a:	52                   	push   %edx
80109a9b:	50                   	push   %eax
80109a9c:	e8 7a b1 ff ff       	call   80104c1b <memmove>
80109aa1:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109aa4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109aa7:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109aad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ab0:	83 ec 0c             	sub    $0xc,%esp
80109ab3:	50                   	push   %eax
80109ab4:	e8 5d fd ff ff       	call   80109816 <ipv4_chksum>
80109ab9:	83 c4 10             	add    $0x10,%esp
80109abc:	0f b7 c0             	movzwl %ax,%eax
80109abf:	83 ec 0c             	sub    $0xc,%esp
80109ac2:	50                   	push   %eax
80109ac3:	e8 3e fc ff ff       	call   80109706 <H2N_ushort>
80109ac8:	83 c4 10             	add    $0x10,%esp
80109acb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ace:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109ad2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ad5:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109ad8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109adb:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109adf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ae2:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109ae6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ae9:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109af0:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109af4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109af7:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109afb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109afe:	8d 50 08             	lea    0x8(%eax),%edx
80109b01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b04:	83 c0 08             	add    $0x8,%eax
80109b07:	83 ec 04             	sub    $0x4,%esp
80109b0a:	6a 08                	push   $0x8
80109b0c:	52                   	push   %edx
80109b0d:	50                   	push   %eax
80109b0e:	e8 08 b1 ff ff       	call   80104c1b <memmove>
80109b13:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b19:	8d 50 10             	lea    0x10(%eax),%edx
80109b1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b1f:	83 c0 10             	add    $0x10,%eax
80109b22:	83 ec 04             	sub    $0x4,%esp
80109b25:	6a 30                	push   $0x30
80109b27:	52                   	push   %edx
80109b28:	50                   	push   %eax
80109b29:	e8 ed b0 ff ff       	call   80104c1b <memmove>
80109b2e:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109b31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b34:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109b3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109b3d:	83 ec 0c             	sub    $0xc,%esp
80109b40:	50                   	push   %eax
80109b41:	e8 1c 00 00 00       	call   80109b62 <icmp_chksum>
80109b46:	83 c4 10             	add    $0x10,%esp
80109b49:	0f b7 c0             	movzwl %ax,%eax
80109b4c:	83 ec 0c             	sub    $0xc,%esp
80109b4f:	50                   	push   %eax
80109b50:	e8 b1 fb ff ff       	call   80109706 <H2N_ushort>
80109b55:	83 c4 10             	add    $0x10,%esp
80109b58:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109b5b:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109b5f:	90                   	nop
80109b60:	c9                   	leave  
80109b61:	c3                   	ret    

80109b62 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109b62:	f3 0f 1e fb          	endbr32 
80109b66:	55                   	push   %ebp
80109b67:	89 e5                	mov    %esp,%ebp
80109b69:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109b72:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109b79:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109b80:	eb 48                	jmp    80109bca <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b82:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b85:	01 c0                	add    %eax,%eax
80109b87:	89 c2                	mov    %eax,%edx
80109b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b8c:	01 d0                	add    %edx,%eax
80109b8e:	0f b6 00             	movzbl (%eax),%eax
80109b91:	0f b6 c0             	movzbl %al,%eax
80109b94:	c1 e0 08             	shl    $0x8,%eax
80109b97:	89 c2                	mov    %eax,%edx
80109b99:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b9c:	01 c0                	add    %eax,%eax
80109b9e:	8d 48 01             	lea    0x1(%eax),%ecx
80109ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ba4:	01 c8                	add    %ecx,%eax
80109ba6:	0f b6 00             	movzbl (%eax),%eax
80109ba9:	0f b6 c0             	movzbl %al,%eax
80109bac:	01 d0                	add    %edx,%eax
80109bae:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109bb1:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109bb8:	76 0c                	jbe    80109bc6 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109bba:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109bbd:	0f b7 c0             	movzwl %ax,%eax
80109bc0:	83 c0 01             	add    $0x1,%eax
80109bc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109bc6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109bca:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109bce:	7e b2                	jle    80109b82 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109bd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109bd3:	f7 d0                	not    %eax
}
80109bd5:	c9                   	leave  
80109bd6:	c3                   	ret    

80109bd7 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109bd7:	f3 0f 1e fb          	endbr32 
80109bdb:	55                   	push   %ebp
80109bdc:	89 e5                	mov    %esp,%ebp
80109bde:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109be1:	8b 45 08             	mov    0x8(%ebp),%eax
80109be4:	83 c0 0e             	add    $0xe,%eax
80109be7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bed:	0f b6 00             	movzbl (%eax),%eax
80109bf0:	0f b6 c0             	movzbl %al,%eax
80109bf3:	83 e0 0f             	and    $0xf,%eax
80109bf6:	c1 e0 02             	shl    $0x2,%eax
80109bf9:	89 c2                	mov    %eax,%edx
80109bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bfe:	01 d0                	add    %edx,%eax
80109c00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c06:	83 c0 14             	add    $0x14,%eax
80109c09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109c0c:	e8 81 8c ff ff       	call   80102892 <kalloc>
80109c11:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109c14:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c1e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c22:	0f b6 c0             	movzbl %al,%eax
80109c25:	83 e0 02             	and    $0x2,%eax
80109c28:	85 c0                	test   %eax,%eax
80109c2a:	74 3d                	je     80109c69 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109c2c:	83 ec 0c             	sub    $0xc,%esp
80109c2f:	6a 00                	push   $0x0
80109c31:	6a 12                	push   $0x12
80109c33:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109c36:	50                   	push   %eax
80109c37:	ff 75 e8             	pushl  -0x18(%ebp)
80109c3a:	ff 75 08             	pushl  0x8(%ebp)
80109c3d:	e8 a2 01 00 00       	call   80109de4 <tcp_pkt_create>
80109c42:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109c45:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109c48:	83 ec 08             	sub    $0x8,%esp
80109c4b:	50                   	push   %eax
80109c4c:	ff 75 e8             	pushl  -0x18(%ebp)
80109c4f:	e8 ff f0 ff ff       	call   80108d53 <i8254_send>
80109c54:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109c57:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109c5c:	83 c0 01             	add    $0x1,%eax
80109c5f:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109c64:	e9 69 01 00 00       	jmp    80109dd2 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c6c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c70:	3c 18                	cmp    $0x18,%al
80109c72:	0f 85 10 01 00 00    	jne    80109d88 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109c78:	83 ec 04             	sub    $0x4,%esp
80109c7b:	6a 03                	push   $0x3
80109c7d:	68 9e c2 10 80       	push   $0x8010c29e
80109c82:	ff 75 ec             	pushl  -0x14(%ebp)
80109c85:	e8 35 af ff ff       	call   80104bbf <memcmp>
80109c8a:	83 c4 10             	add    $0x10,%esp
80109c8d:	85 c0                	test   %eax,%eax
80109c8f:	74 74                	je     80109d05 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109c91:	83 ec 0c             	sub    $0xc,%esp
80109c94:	68 a2 c2 10 80       	push   $0x8010c2a2
80109c99:	e8 6e 67 ff ff       	call   8010040c <cprintf>
80109c9e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109ca1:	83 ec 0c             	sub    $0xc,%esp
80109ca4:	6a 00                	push   $0x0
80109ca6:	6a 10                	push   $0x10
80109ca8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109cab:	50                   	push   %eax
80109cac:	ff 75 e8             	pushl  -0x18(%ebp)
80109caf:	ff 75 08             	pushl  0x8(%ebp)
80109cb2:	e8 2d 01 00 00       	call   80109de4 <tcp_pkt_create>
80109cb7:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109cba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109cbd:	83 ec 08             	sub    $0x8,%esp
80109cc0:	50                   	push   %eax
80109cc1:	ff 75 e8             	pushl  -0x18(%ebp)
80109cc4:	e8 8a f0 ff ff       	call   80108d53 <i8254_send>
80109cc9:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109ccc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ccf:	83 c0 36             	add    $0x36,%eax
80109cd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109cd5:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109cd8:	50                   	push   %eax
80109cd9:	ff 75 e0             	pushl  -0x20(%ebp)
80109cdc:	6a 00                	push   $0x0
80109cde:	6a 00                	push   $0x0
80109ce0:	e8 66 04 00 00       	call   8010a14b <http_proc>
80109ce5:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ce8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ceb:	83 ec 0c             	sub    $0xc,%esp
80109cee:	50                   	push   %eax
80109cef:	6a 18                	push   $0x18
80109cf1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109cf4:	50                   	push   %eax
80109cf5:	ff 75 e8             	pushl  -0x18(%ebp)
80109cf8:	ff 75 08             	pushl  0x8(%ebp)
80109cfb:	e8 e4 00 00 00       	call   80109de4 <tcp_pkt_create>
80109d00:	83 c4 20             	add    $0x20,%esp
80109d03:	eb 62                	jmp    80109d67 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109d05:	83 ec 0c             	sub    $0xc,%esp
80109d08:	6a 00                	push   $0x0
80109d0a:	6a 10                	push   $0x10
80109d0c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d0f:	50                   	push   %eax
80109d10:	ff 75 e8             	pushl  -0x18(%ebp)
80109d13:	ff 75 08             	pushl  0x8(%ebp)
80109d16:	e8 c9 00 00 00       	call   80109de4 <tcp_pkt_create>
80109d1b:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109d1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d21:	83 ec 08             	sub    $0x8,%esp
80109d24:	50                   	push   %eax
80109d25:	ff 75 e8             	pushl  -0x18(%ebp)
80109d28:	e8 26 f0 ff ff       	call   80108d53 <i8254_send>
80109d2d:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109d30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d33:	83 c0 36             	add    $0x36,%eax
80109d36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109d39:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d3c:	50                   	push   %eax
80109d3d:	ff 75 e4             	pushl  -0x1c(%ebp)
80109d40:	6a 00                	push   $0x0
80109d42:	6a 00                	push   $0x0
80109d44:	e8 02 04 00 00       	call   8010a14b <http_proc>
80109d49:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109d4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109d4f:	83 ec 0c             	sub    $0xc,%esp
80109d52:	50                   	push   %eax
80109d53:	6a 18                	push   $0x18
80109d55:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109d58:	50                   	push   %eax
80109d59:	ff 75 e8             	pushl  -0x18(%ebp)
80109d5c:	ff 75 08             	pushl  0x8(%ebp)
80109d5f:	e8 80 00 00 00       	call   80109de4 <tcp_pkt_create>
80109d64:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109d67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109d6a:	83 ec 08             	sub    $0x8,%esp
80109d6d:	50                   	push   %eax
80109d6e:	ff 75 e8             	pushl  -0x18(%ebp)
80109d71:	e8 dd ef ff ff       	call   80108d53 <i8254_send>
80109d76:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109d79:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109d7e:	83 c0 01             	add    $0x1,%eax
80109d81:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109d86:	eb 4a                	jmp    80109dd2 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109d88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d8b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d8f:	3c 10                	cmp    $0x10,%al
80109d91:	75 3f                	jne    80109dd2 <tcp_proc+0x1fb>
    if(fin_flag == 1){
80109d93:	a1 48 d3 18 80       	mov    0x8018d348,%eax
80109d98:	83 f8 01             	cmp    $0x1,%eax
80109d9b:	75 35                	jne    80109dd2 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109d9d:	83 ec 0c             	sub    $0xc,%esp
80109da0:	6a 00                	push   $0x0
80109da2:	6a 01                	push   $0x1
80109da4:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109da7:	50                   	push   %eax
80109da8:	ff 75 e8             	pushl  -0x18(%ebp)
80109dab:	ff 75 08             	pushl  0x8(%ebp)
80109dae:	e8 31 00 00 00       	call   80109de4 <tcp_pkt_create>
80109db3:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109db6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109db9:	83 ec 08             	sub    $0x8,%esp
80109dbc:	50                   	push   %eax
80109dbd:	ff 75 e8             	pushl  -0x18(%ebp)
80109dc0:	e8 8e ef ff ff       	call   80108d53 <i8254_send>
80109dc5:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109dc8:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
80109dcf:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109dd2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dd5:	83 ec 0c             	sub    $0xc,%esp
80109dd8:	50                   	push   %eax
80109dd9:	e8 16 8a ff ff       	call   801027f4 <kfree>
80109dde:	83 c4 10             	add    $0x10,%esp
}
80109de1:	90                   	nop
80109de2:	c9                   	leave  
80109de3:	c3                   	ret    

80109de4 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109de4:	f3 0f 1e fb          	endbr32 
80109de8:	55                   	push   %ebp
80109de9:	89 e5                	mov    %esp,%ebp
80109deb:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109dee:	8b 45 08             	mov    0x8(%ebp),%eax
80109df1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109df4:	8b 45 08             	mov    0x8(%ebp),%eax
80109df7:	83 c0 0e             	add    $0xe,%eax
80109dfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e00:	0f b6 00             	movzbl (%eax),%eax
80109e03:	0f b6 c0             	movzbl %al,%eax
80109e06:	83 e0 0f             	and    $0xf,%eax
80109e09:	c1 e0 02             	shl    $0x2,%eax
80109e0c:	89 c2                	mov    %eax,%edx
80109e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e11:	01 d0                	add    %edx,%eax
80109e13:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109e16:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e19:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e1f:	83 c0 0e             	add    $0xe,%eax
80109e22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109e25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e28:	83 c0 14             	add    $0x14,%eax
80109e2b:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109e2e:	8b 45 18             	mov    0x18(%ebp),%eax
80109e31:	8d 50 36             	lea    0x36(%eax),%edx
80109e34:	8b 45 10             	mov    0x10(%ebp),%eax
80109e37:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e3c:	8d 50 06             	lea    0x6(%eax),%edx
80109e3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e42:	83 ec 04             	sub    $0x4,%esp
80109e45:	6a 06                	push   $0x6
80109e47:	52                   	push   %edx
80109e48:	50                   	push   %eax
80109e49:	e8 cd ad ff ff       	call   80104c1b <memmove>
80109e4e:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109e51:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e54:	83 c0 06             	add    $0x6,%eax
80109e57:	83 ec 04             	sub    $0x4,%esp
80109e5a:	6a 06                	push   $0x6
80109e5c:	68 68 d0 18 80       	push   $0x8018d068
80109e61:	50                   	push   %eax
80109e62:	e8 b4 ad ff ff       	call   80104c1b <memmove>
80109e67:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109e6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e6d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109e71:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e74:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e7b:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e81:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109e85:	8b 45 18             	mov    0x18(%ebp),%eax
80109e88:	83 c0 28             	add    $0x28,%eax
80109e8b:	0f b7 c0             	movzwl %ax,%eax
80109e8e:	83 ec 0c             	sub    $0xc,%esp
80109e91:	50                   	push   %eax
80109e92:	e8 6f f8 ff ff       	call   80109706 <H2N_ushort>
80109e97:	83 c4 10             	add    $0x10,%esp
80109e9a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e9d:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109ea1:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109ea8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109eab:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109eaf:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109eb6:	83 c0 01             	add    $0x1,%eax
80109eb9:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
80109ebf:	83 ec 0c             	sub    $0xc,%esp
80109ec2:	6a 00                	push   $0x0
80109ec4:	e8 3d f8 ff ff       	call   80109706 <H2N_ushort>
80109ec9:	83 c4 10             	add    $0x10,%esp
80109ecc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ecf:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109ed3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ed6:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109eda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109edd:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109ee1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ee4:	83 c0 0c             	add    $0xc,%eax
80109ee7:	83 ec 04             	sub    $0x4,%esp
80109eea:	6a 04                	push   $0x4
80109eec:	68 e4 f4 10 80       	push   $0x8010f4e4
80109ef1:	50                   	push   %eax
80109ef2:	e8 24 ad ff ff       	call   80104c1b <memmove>
80109ef7:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109efd:	8d 50 0c             	lea    0xc(%eax),%edx
80109f00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f03:	83 c0 10             	add    $0x10,%eax
80109f06:	83 ec 04             	sub    $0x4,%esp
80109f09:	6a 04                	push   $0x4
80109f0b:	52                   	push   %edx
80109f0c:	50                   	push   %eax
80109f0d:	e8 09 ad ff ff       	call   80104c1b <memmove>
80109f12:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f18:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109f1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f21:	83 ec 0c             	sub    $0xc,%esp
80109f24:	50                   	push   %eax
80109f25:	e8 ec f8 ff ff       	call   80109816 <ipv4_chksum>
80109f2a:	83 c4 10             	add    $0x10,%esp
80109f2d:	0f b7 c0             	movzwl %ax,%eax
80109f30:	83 ec 0c             	sub    $0xc,%esp
80109f33:	50                   	push   %eax
80109f34:	e8 cd f7 ff ff       	call   80109706 <H2N_ushort>
80109f39:	83 c4 10             	add    $0x10,%esp
80109f3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f3f:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f46:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109f4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f4d:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f53:	0f b7 10             	movzwl (%eax),%edx
80109f56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f59:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109f5d:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109f62:	83 ec 0c             	sub    $0xc,%esp
80109f65:	50                   	push   %eax
80109f66:	e8 c1 f7 ff ff       	call   8010972c <H2N_uint>
80109f6b:	83 c4 10             	add    $0x10,%esp
80109f6e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f71:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109f74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f77:	8b 40 04             	mov    0x4(%eax),%eax
80109f7a:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109f80:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f83:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109f86:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f89:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109f8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f90:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109f94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f97:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109f9b:	8b 45 14             	mov    0x14(%ebp),%eax
80109f9e:	89 c2                	mov    %eax,%edx
80109fa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fa3:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109fa6:	83 ec 0c             	sub    $0xc,%esp
80109fa9:	68 90 38 00 00       	push   $0x3890
80109fae:	e8 53 f7 ff ff       	call   80109706 <H2N_ushort>
80109fb3:	83 c4 10             	add    $0x10,%esp
80109fb6:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109fb9:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109fbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fc0:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109fc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fc9:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109fcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fd2:	83 ec 0c             	sub    $0xc,%esp
80109fd5:	50                   	push   %eax
80109fd6:	e8 1f 00 00 00       	call   80109ffa <tcp_chksum>
80109fdb:	83 c4 10             	add    $0x10,%esp
80109fde:	83 c0 08             	add    $0x8,%eax
80109fe1:	0f b7 c0             	movzwl %ax,%eax
80109fe4:	83 ec 0c             	sub    $0xc,%esp
80109fe7:	50                   	push   %eax
80109fe8:	e8 19 f7 ff ff       	call   80109706 <H2N_ushort>
80109fed:	83 c4 10             	add    $0x10,%esp
80109ff0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ff3:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109ff7:	90                   	nop
80109ff8:	c9                   	leave  
80109ff9:	c3                   	ret    

80109ffa <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109ffa:	f3 0f 1e fb          	endbr32 
80109ffe:	55                   	push   %ebp
80109fff:	89 e5                	mov    %esp,%ebp
8010a001:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a004:	8b 45 08             	mov    0x8(%ebp),%eax
8010a007:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a00a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a00d:	83 c0 14             	add    $0x14,%eax
8010a010:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a013:	83 ec 04             	sub    $0x4,%esp
8010a016:	6a 04                	push   $0x4
8010a018:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a01d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a020:	50                   	push   %eax
8010a021:	e8 f5 ab ff ff       	call   80104c1b <memmove>
8010a026:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a029:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a02c:	83 c0 0c             	add    $0xc,%eax
8010a02f:	83 ec 04             	sub    $0x4,%esp
8010a032:	6a 04                	push   $0x4
8010a034:	50                   	push   %eax
8010a035:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a038:	83 c0 04             	add    $0x4,%eax
8010a03b:	50                   	push   %eax
8010a03c:	e8 da ab ff ff       	call   80104c1b <memmove>
8010a041:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a044:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a048:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a04c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a04f:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a053:	0f b7 c0             	movzwl %ax,%eax
8010a056:	83 ec 0c             	sub    $0xc,%esp
8010a059:	50                   	push   %eax
8010a05a:	e8 81 f6 ff ff       	call   801096e0 <N2H_ushort>
8010a05f:	83 c4 10             	add    $0x10,%esp
8010a062:	83 e8 14             	sub    $0x14,%eax
8010a065:	0f b7 c0             	movzwl %ax,%eax
8010a068:	83 ec 0c             	sub    $0xc,%esp
8010a06b:	50                   	push   %eax
8010a06c:	e8 95 f6 ff ff       	call   80109706 <H2N_ushort>
8010a071:	83 c4 10             	add    $0x10,%esp
8010a074:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a078:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a07f:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a082:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a085:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a08c:	eb 33                	jmp    8010a0c1 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a08e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a091:	01 c0                	add    %eax,%eax
8010a093:	89 c2                	mov    %eax,%edx
8010a095:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a098:	01 d0                	add    %edx,%eax
8010a09a:	0f b6 00             	movzbl (%eax),%eax
8010a09d:	0f b6 c0             	movzbl %al,%eax
8010a0a0:	c1 e0 08             	shl    $0x8,%eax
8010a0a3:	89 c2                	mov    %eax,%edx
8010a0a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0a8:	01 c0                	add    %eax,%eax
8010a0aa:	8d 48 01             	lea    0x1(%eax),%ecx
8010a0ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0b0:	01 c8                	add    %ecx,%eax
8010a0b2:	0f b6 00             	movzbl (%eax),%eax
8010a0b5:	0f b6 c0             	movzbl %al,%eax
8010a0b8:	01 d0                	add    %edx,%eax
8010a0ba:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a0bd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a0c1:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a0c5:	7e c7                	jle    8010a08e <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a0c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a0cd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a0d4:	eb 33                	jmp    8010a109 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a0d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0d9:	01 c0                	add    %eax,%eax
8010a0db:	89 c2                	mov    %eax,%edx
8010a0dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0e0:	01 d0                	add    %edx,%eax
8010a0e2:	0f b6 00             	movzbl (%eax),%eax
8010a0e5:	0f b6 c0             	movzbl %al,%eax
8010a0e8:	c1 e0 08             	shl    $0x8,%eax
8010a0eb:	89 c2                	mov    %eax,%edx
8010a0ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0f0:	01 c0                	add    %eax,%eax
8010a0f2:	8d 48 01             	lea    0x1(%eax),%ecx
8010a0f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0f8:	01 c8                	add    %ecx,%eax
8010a0fa:	0f b6 00             	movzbl (%eax),%eax
8010a0fd:	0f b6 c0             	movzbl %al,%eax
8010a100:	01 d0                	add    %edx,%eax
8010a102:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a105:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a109:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a10d:	0f b7 c0             	movzwl %ax,%eax
8010a110:	83 ec 0c             	sub    $0xc,%esp
8010a113:	50                   	push   %eax
8010a114:	e8 c7 f5 ff ff       	call   801096e0 <N2H_ushort>
8010a119:	83 c4 10             	add    $0x10,%esp
8010a11c:	66 d1 e8             	shr    %ax
8010a11f:	0f b7 c0             	movzwl %ax,%eax
8010a122:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a125:	7c af                	jl     8010a0d6 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a12a:	c1 e8 10             	shr    $0x10,%eax
8010a12d:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a130:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a133:	f7 d0                	not    %eax
}
8010a135:	c9                   	leave  
8010a136:	c3                   	ret    

8010a137 <tcp_fin>:

void tcp_fin(){
8010a137:	f3 0f 1e fb          	endbr32 
8010a13b:	55                   	push   %ebp
8010a13c:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a13e:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a145:	00 00 00 
}
8010a148:	90                   	nop
8010a149:	5d                   	pop    %ebp
8010a14a:	c3                   	ret    

8010a14b <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a14b:	f3 0f 1e fb          	endbr32 
8010a14f:	55                   	push   %ebp
8010a150:	89 e5                	mov    %esp,%ebp
8010a152:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a155:	8b 45 10             	mov    0x10(%ebp),%eax
8010a158:	83 ec 04             	sub    $0x4,%esp
8010a15b:	6a 00                	push   $0x0
8010a15d:	68 ab c2 10 80       	push   $0x8010c2ab
8010a162:	50                   	push   %eax
8010a163:	e8 65 00 00 00       	call   8010a1cd <http_strcpy>
8010a168:	83 c4 10             	add    $0x10,%esp
8010a16b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a16e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a171:	83 ec 04             	sub    $0x4,%esp
8010a174:	ff 75 f4             	pushl  -0xc(%ebp)
8010a177:	68 be c2 10 80       	push   $0x8010c2be
8010a17c:	50                   	push   %eax
8010a17d:	e8 4b 00 00 00       	call   8010a1cd <http_strcpy>
8010a182:	83 c4 10             	add    $0x10,%esp
8010a185:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a188:	8b 45 10             	mov    0x10(%ebp),%eax
8010a18b:	83 ec 04             	sub    $0x4,%esp
8010a18e:	ff 75 f4             	pushl  -0xc(%ebp)
8010a191:	68 d9 c2 10 80       	push   $0x8010c2d9
8010a196:	50                   	push   %eax
8010a197:	e8 31 00 00 00       	call   8010a1cd <http_strcpy>
8010a19c:	83 c4 10             	add    $0x10,%esp
8010a19f:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a1a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1a5:	83 e0 01             	and    $0x1,%eax
8010a1a8:	85 c0                	test   %eax,%eax
8010a1aa:	74 11                	je     8010a1bd <http_proc+0x72>
    char *payload = (char *)send;
8010a1ac:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a1b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a1b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1b8:	01 d0                	add    %edx,%eax
8010a1ba:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a1bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a1c0:	8b 45 14             	mov    0x14(%ebp),%eax
8010a1c3:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a1c5:	e8 6d ff ff ff       	call   8010a137 <tcp_fin>
}
8010a1ca:	90                   	nop
8010a1cb:	c9                   	leave  
8010a1cc:	c3                   	ret    

8010a1cd <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a1cd:	f3 0f 1e fb          	endbr32 
8010a1d1:	55                   	push   %ebp
8010a1d2:	89 e5                	mov    %esp,%ebp
8010a1d4:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a1d7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a1de:	eb 20                	jmp    8010a200 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a1e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a1e3:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1e6:	01 d0                	add    %edx,%eax
8010a1e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a1eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a1ee:	01 ca                	add    %ecx,%edx
8010a1f0:	89 d1                	mov    %edx,%ecx
8010a1f2:	8b 55 08             	mov    0x8(%ebp),%edx
8010a1f5:	01 ca                	add    %ecx,%edx
8010a1f7:	0f b6 00             	movzbl (%eax),%eax
8010a1fa:	88 02                	mov    %al,(%edx)
    i++;
8010a1fc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a200:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a203:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a206:	01 d0                	add    %edx,%eax
8010a208:	0f b6 00             	movzbl (%eax),%eax
8010a20b:	84 c0                	test   %al,%al
8010a20d:	75 d1                	jne    8010a1e0 <http_strcpy+0x13>
  }
  return i;
8010a20f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a212:	c9                   	leave  
8010a213:	c3                   	ret    

8010a214 <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a214:	f3 0f 1e fb          	endbr32 
8010a218:	55                   	push   %ebp
8010a219:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a21b:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a222:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a225:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a22a:	c1 e8 09             	shr    $0x9,%eax
8010a22d:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a232:	90                   	nop
8010a233:	5d                   	pop    %ebp
8010a234:	c3                   	ret    

8010a235 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a235:	f3 0f 1e fb          	endbr32 
8010a239:	55                   	push   %ebp
8010a23a:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a23c:	90                   	nop
8010a23d:	5d                   	pop    %ebp
8010a23e:	c3                   	ret    

8010a23f <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a23f:	f3 0f 1e fb          	endbr32 
8010a243:	55                   	push   %ebp
8010a244:	89 e5                	mov    %esp,%ebp
8010a246:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a249:	8b 45 08             	mov    0x8(%ebp),%eax
8010a24c:	83 c0 0c             	add    $0xc,%eax
8010a24f:	83 ec 0c             	sub    $0xc,%esp
8010a252:	50                   	push   %eax
8010a253:	e8 d4 a5 ff ff       	call   8010482c <holdingsleep>
8010a258:	83 c4 10             	add    $0x10,%esp
8010a25b:	85 c0                	test   %eax,%eax
8010a25d:	75 0d                	jne    8010a26c <iderw+0x2d>
    panic("iderw: buf not locked");
8010a25f:	83 ec 0c             	sub    $0xc,%esp
8010a262:	68 ea c2 10 80       	push   $0x8010c2ea
8010a267:	e8 59 63 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a26c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a26f:	8b 00                	mov    (%eax),%eax
8010a271:	83 e0 06             	and    $0x6,%eax
8010a274:	83 f8 02             	cmp    $0x2,%eax
8010a277:	75 0d                	jne    8010a286 <iderw+0x47>
    panic("iderw: nothing to do");
8010a279:	83 ec 0c             	sub    $0xc,%esp
8010a27c:	68 00 c3 10 80       	push   $0x8010c300
8010a281:	e8 3f 63 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a286:	8b 45 08             	mov    0x8(%ebp),%eax
8010a289:	8b 40 04             	mov    0x4(%eax),%eax
8010a28c:	83 f8 01             	cmp    $0x1,%eax
8010a28f:	74 0d                	je     8010a29e <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a291:	83 ec 0c             	sub    $0xc,%esp
8010a294:	68 15 c3 10 80       	push   $0x8010c315
8010a299:	e8 27 63 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a29e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2a1:	8b 40 08             	mov    0x8(%eax),%eax
8010a2a4:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a2aa:	39 d0                	cmp    %edx,%eax
8010a2ac:	72 0d                	jb     8010a2bb <iderw+0x7c>
    panic("iderw: block out of range");
8010a2ae:	83 ec 0c             	sub    $0xc,%esp
8010a2b1:	68 33 c3 10 80       	push   $0x8010c333
8010a2b6:	e8 0a 63 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a2bb:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a2c1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2c4:	8b 40 08             	mov    0x8(%eax),%eax
8010a2c7:	c1 e0 09             	shl    $0x9,%eax
8010a2ca:	01 d0                	add    %edx,%eax
8010a2cc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a2cf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2d2:	8b 00                	mov    (%eax),%eax
8010a2d4:	83 e0 04             	and    $0x4,%eax
8010a2d7:	85 c0                	test   %eax,%eax
8010a2d9:	74 2b                	je     8010a306 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a2db:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2de:	8b 00                	mov    (%eax),%eax
8010a2e0:	83 e0 fb             	and    $0xfffffffb,%eax
8010a2e3:	89 c2                	mov    %eax,%edx
8010a2e5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2e8:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a2ea:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ed:	83 c0 5c             	add    $0x5c,%eax
8010a2f0:	83 ec 04             	sub    $0x4,%esp
8010a2f3:	68 00 02 00 00       	push   $0x200
8010a2f8:	50                   	push   %eax
8010a2f9:	ff 75 f4             	pushl  -0xc(%ebp)
8010a2fc:	e8 1a a9 ff ff       	call   80104c1b <memmove>
8010a301:	83 c4 10             	add    $0x10,%esp
8010a304:	eb 1a                	jmp    8010a320 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a306:	8b 45 08             	mov    0x8(%ebp),%eax
8010a309:	83 c0 5c             	add    $0x5c,%eax
8010a30c:	83 ec 04             	sub    $0x4,%esp
8010a30f:	68 00 02 00 00       	push   $0x200
8010a314:	ff 75 f4             	pushl  -0xc(%ebp)
8010a317:	50                   	push   %eax
8010a318:	e8 fe a8 ff ff       	call   80104c1b <memmove>
8010a31d:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a320:	8b 45 08             	mov    0x8(%ebp),%eax
8010a323:	8b 00                	mov    (%eax),%eax
8010a325:	83 c8 02             	or     $0x2,%eax
8010a328:	89 c2                	mov    %eax,%edx
8010a32a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a32d:	89 10                	mov    %edx,(%eax)
}
8010a32f:	90                   	nop
8010a330:	c9                   	leave  
8010a331:	c3                   	ret    
