
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
80100073:	68 20 a6 10 80       	push   $0x8010a620
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 83 4a 00 00       	call   80104b05 <initlock>
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
801000c1:	68 27 a6 10 80       	push   $0x8010a627
801000c6:	50                   	push   %eax
801000c7:	e8 cc 48 00 00       	call   80104998 <initsleeplock>
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
80100109:	e8 1d 4a 00 00       	call   80104b2b <acquire>
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
80100148:	e8 50 4a 00 00       	call   80104b9d <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 79 48 00 00       	call   801049d8 <acquiresleep>
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
801001c9:	e8 cf 49 00 00       	call   80104b9d <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 f8 47 00 00       	call   801049d8 <acquiresleep>
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
801001fd:	68 2e a6 10 80       	push   $0x8010a62e
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
80100239:	e8 dc a2 00 00       	call   8010a51a <iderw>
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
8010025a:	e8 33 48 00 00       	call   80104a92 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 3f a6 10 80       	push   $0x8010a63f
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
80100288:	e8 8d a2 00 00       	call   8010a51a <iderw>
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
801002a7:	e8 e6 47 00 00       	call   80104a92 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 46 a6 10 80       	push   $0x8010a646
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 71 47 00 00       	call   80104a40 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 4c 48 00 00       	call   80104b2b <acquire>
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
8010034a:	e8 4e 48 00 00       	call   80104b9d <release>
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
8010042c:	e8 fa 46 00 00       	call   80104b2b <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 4d a6 10 80       	push   $0x8010a64d
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
8010052c:	c7 45 ec 56 a6 10 80 	movl   $0x8010a656,-0x14(%ebp)
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
801005ba:	e8 de 45 00 00       	call   80104b9d <release>
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
801005e7:	68 5d a6 10 80       	push   $0x8010a65d
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
80100606:	68 71 a6 10 80       	push   $0x8010a671
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 d0 45 00 00       	call   80104bf3 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 73 a6 10 80       	push   $0x8010a673
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
801006c4:	e8 e5 7c 00 00       	call   801083ae <graphic_scroll_up>
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
80100717:	e8 92 7c 00 00       	call   801083ae <graphic_scroll_up>
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
8010077d:	e8 a0 7c 00 00       	call   80108422 <font_render>
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
801007bd:	e8 00 60 00 00       	call   801067c2 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 f3 5f 00 00       	call   801067c2 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 e6 5f 00 00       	call   801067c2 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 d6 5f 00 00       	call   801067c2 <uartputc>
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
80100819:	e8 0d 43 00 00       	call   80104b2b <acquire>
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
8010096f:	e8 63 3e 00 00       	call   801047d7 <wakeup>
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
80100992:	e8 06 42 00 00       	call   80104b9d <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 f5 3e 00 00       	call   8010489a <procdump>
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
801009ce:	e8 58 41 00 00       	call   80104b2b <acquire>
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
801009ef:	e8 a9 41 00 00       	call   80104b9d <release>
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
80100a1c:	e8 c7 3c 00 00       	call   801046e8 <sleep>
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
80100a9a:	e8 fe 40 00 00       	call   80104b9d <release>
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
80100adc:	e8 4a 40 00 00       	call   80104b2b <acquire>
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
80100b1e:	e8 7a 40 00 00       	call   80104b9d <release>
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
80100b50:	68 77 a6 10 80       	push   $0x8010a677
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 a6 3f 00 00       	call   80104b05 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 7f a6 10 80 	movl   $0x8010a67f,-0xc(%ebp)
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
80100bf7:	68 95 a6 10 80       	push   $0x8010a695
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
80100c53:	e8 7e 6b 00 00       	call   801077d6 <setupkvm>
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
80100cf9:	e8 ea 6e 00 00       	call   80107be8 <allocuvm>
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
80100d3f:	e8 d3 6d 00 00       	call   80107b17 <loaduvm>
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
80100dae:	e8 35 6e 00 00       	call   80107be8 <allocuvm>
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
80100dd2:	e8 7f 70 00 00       	call   80107e56 <clearpteu>
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
80100e0b:	e8 13 42 00 00       	call   80105023 <strlen>
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
80100e38:	e8 e6 41 00 00       	call   80105023 <strlen>
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
80100e5e:	e8 9e 71 00 00       	call   80108001 <copyout>
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
80100efa:	e8 02 71 00 00       	call   80108001 <copyout>
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
80100f48:	e8 88 40 00 00       	call   80104fd5 <safestrcpy>
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
80100f8b:	e8 70 69 00 00       	call   80107900 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 1b 6e 00 00       	call   80107db9 <freevm>
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
80100fd9:	e8 db 6d 00 00       	call   80107db9 <freevm>
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
8010100e:	68 a1 a6 10 80       	push   $0x8010a6a1
80101013:	68 60 2d 19 80       	push   $0x80192d60
80101018:	e8 e8 3a 00 00       	call   80104b05 <initlock>
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
80101035:	e8 f1 3a 00 00       	call   80104b2b <acquire>
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
80101062:	e8 36 3b 00 00       	call   80104b9d <release>
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
80101085:	e8 13 3b 00 00       	call   80104b9d <release>
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
801010a6:	e8 80 3a 00 00       	call   80104b2b <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 a8 a6 10 80       	push   $0x8010a6a8
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
801010dc:	e8 bc 3a 00 00       	call   80104b9d <release>
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
801010fb:	e8 2b 3a 00 00       	call   80104b2b <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 b0 a6 10 80       	push   $0x8010a6b0
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
8010113b:	e8 5d 3a 00 00       	call   80104b9d <release>
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
80101189:	e8 0f 3a 00 00       	call   80104b9d <release>
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
801012e0:	68 ba a6 10 80       	push   $0x8010a6ba
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
801013e7:	68 c3 a6 10 80       	push   $0x8010a6c3
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
8010141d:	68 d3 a6 10 80       	push   $0x8010a6d3
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
80101459:	e8 23 3a 00 00       	call   80104e81 <memmove>
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
801014a3:	e8 12 39 00 00       	call   80104dba <memset>
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
8010160e:	68 e0 a6 10 80       	push   $0x8010a6e0
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
801016a5:	68 f6 a6 10 80       	push   $0x8010a6f6
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
8010170d:	68 09 a7 10 80       	push   $0x8010a709
80101712:	68 80 37 19 80       	push   $0x80193780
80101717:	e8 e9 33 00 00       	call   80104b05 <initlock>
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
80101743:	68 10 a7 10 80       	push   $0x8010a710
80101748:	50                   	push   %eax
80101749:	e8 4a 32 00 00       	call   80104998 <initsleeplock>
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
801017a2:	68 18 a7 10 80       	push   $0x8010a718
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
8010181f:	e8 96 35 00 00       	call   80104dba <memset>
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
80101887:	68 6b a7 10 80       	push   $0x8010a76b
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
80101931:	e8 4b 35 00 00       	call   80104e81 <memmove>
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
8010196a:	e8 bc 31 00 00       	call   80104b2b <acquire>
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
801019b8:	e8 e0 31 00 00       	call   80104b9d <release>
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
801019f4:	68 7d a7 10 80       	push   $0x8010a77d
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
80101a31:	e8 67 31 00 00       	call   80104b9d <release>
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
80101a50:	e8 d6 30 00 00       	call   80104b2b <acquire>
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
80101a6f:	e8 29 31 00 00       	call   80104b9d <release>
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
80101a99:	68 8d a7 10 80       	push   $0x8010a78d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 26 2f 00 00       	call   801049d8 <acquiresleep>
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
80101b57:	e8 25 33 00 00       	call   80104e81 <memmove>
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
80101b86:	68 93 a7 10 80       	push   $0x8010a793
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
80101bad:	e8 e0 2e 00 00       	call   80104a92 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 a2 a7 10 80       	push   $0x8010a7a2
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 61 2e 00 00       	call   80104a40 <releasesleep>
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
80101bf9:	e8 da 2d 00 00       	call   801049d8 <acquiresleep>
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
80101c1f:	e8 07 2f 00 00       	call   80104b2b <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 80 37 19 80       	push   $0x80193780
80101c38:	e8 60 2f 00 00       	call   80104b9d <release>
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
80101c7f:	e8 bc 2d 00 00       	call   80104a40 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 80 37 19 80       	push   $0x80193780
80101c8f:	e8 97 2e 00 00       	call   80104b2b <acquire>
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
80101cae:	e8 ea 2e 00 00       	call   80104b9d <release>
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
80101dfa:	68 aa a7 10 80       	push   $0x8010a7aa
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
801020a4:	e8 d8 2d 00 00       	call   80104e81 <memmove>
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
801021f8:	e8 84 2c 00 00       	call   80104e81 <memmove>
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
8010227c:	e8 9e 2c 00 00       	call   80104f1f <strncmp>
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
801022a0:	68 bd a7 10 80       	push   $0x8010a7bd
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
801022cf:	68 cf a7 10 80       	push   $0x8010a7cf
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
801023a8:	68 de a7 10 80       	push   $0x8010a7de
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
801023e3:	e8 91 2b 00 00       	call   80104f79 <strncpy>
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
8010240f:	68 eb a7 10 80       	push   $0x8010a7eb
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
80102485:	e8 f7 29 00 00       	call   80104e81 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 e0 29 00 00       	call   80104e81 <memmove>
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
80102699:	0f b6 05 a0 7d 19 80 	movzbl 0x80197da0,%eax
801026a0:	0f b6 c0             	movzbl %al,%eax
801026a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026a6:	74 10                	je     801026b8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 f4 a7 10 80       	push   $0x8010a7f4
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
8010275a:	68 26 a8 10 80       	push   $0x8010a826
8010275f:	68 e0 53 19 80       	push   $0x801953e0
80102764:	e8 9c 23 00 00       	call   80104b05 <initlock>
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
8010280a:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102811:	72 0f                	jb     80102822 <kfree+0x2e>
80102813:	8b 45 08             	mov    0x8(%ebp),%eax
80102816:	05 00 00 00 80       	add    $0x80000000,%eax
8010281b:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102820:	76 0d                	jbe    8010282f <kfree+0x3b>
    panic("kfree");
80102822:	83 ec 0c             	sub    $0xc,%esp
80102825:	68 2b a8 10 80       	push   $0x8010a82b
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	pushl  0x8(%ebp)
8010283c:	e8 79 25 00 00       	call   80104dba <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 14 54 19 80       	mov    0x80195414,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 e0 53 19 80       	push   $0x801953e0
80102855:	e8 d1 22 00 00       	call   80104b2b <acquire>
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
80102887:	e8 11 23 00 00       	call   80104b9d <release>
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
801028ad:	e8 79 22 00 00       	call   80104b2b <acquire>
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
801028de:	e8 ba 22 00 00       	call   80104b9d <release>
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
80102e33:	e8 ed 1f 00 00       	call   80104e25 <memcmp>
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
80102f4b:	68 31 a8 10 80       	push   $0x8010a831
80102f50:	68 20 54 19 80       	push   $0x80195420
80102f55:	e8 ab 1b 00 00       	call   80104b05 <initlock>
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
80103004:	e8 78 1e 00 00       	call   80104e81 <memmove>
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
80103183:	e8 a3 19 00 00       	call   80104b2b <acquire>
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
801031a1:	e8 42 15 00 00       	call   801046e8 <sleep>
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
801031d6:	e8 0d 15 00 00       	call   801046e8 <sleep>
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
801031f5:	e8 a3 19 00 00       	call   80104b9d <release>
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
8010321a:	e8 0c 19 00 00       	call   80104b2b <acquire>
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
8010323b:	68 35 a8 10 80       	push   $0x8010a835
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
80103269:	e8 69 15 00 00       	call   801047d7 <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 20 54 19 80       	push   $0x80195420
80103279:	e8 1f 19 00 00       	call   80104b9d <release>
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
80103294:	e8 92 18 00 00       	call   80104b2b <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 20 54 19 80       	push   $0x80195420
801032ae:	e8 24 15 00 00       	call   801047d7 <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 20 54 19 80       	push   $0x80195420
801032be:	e8 da 18 00 00       	call   80104b9d <release>
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
8010333e:	e8 3e 1b 00 00       	call   80104e81 <memmove>
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
801033e3:	68 44 a8 10 80       	push   $0x8010a844
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 5a a8 10 80       	push   $0x8010a85a
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 20 54 19 80       	push   $0x80195420
8010340b:	e8 1b 17 00 00       	call   80104b2b <acquire>
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
80103489:	e8 0f 17 00 00       	call   80104b9d <release>
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
801034c3:	e8 22 4e 00 00       	call   801082ea <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator 커널이 사용할 수 있는 물리 메모리의 첫 4MB를 할당할 준비를 합니다.
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 90 19 80       	push   $0x80199000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table // 가상 메모리 주소를 물리 메모리 주소로 변환할 **커널 페이지 테이블(지도)**을 만듭니다.
801034dd:	e8 e5 43 00 00       	call   801078c7 <kvmalloc>
  mpinit_uefi(); // 다중 코어(멀티프로세서) 환경을 UEFI 방식에 맞게 파악합니다. CPU가 몇 개인지 확인하는 작업이죠.
801034e2:	e8 bc 4b 00 00       	call   801080a3 <mpinit_uefi>
  lapicinit();     // interrupt controller 키보드나 마우스 등 외부에서 들어오는 신호(인터럽트)를 CPU가 받을 수 있도록 컨트롤러를 켭니다.
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors 메모리 보호 구역(세그먼트)을 설정하고, 오류나 시스템 콜이 발생했을 때 어디로 가야 할지(트랩 벡터)를 설정합니다.
801034ec:	e8 5d 3e 00 00       	call   8010734e <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller 키보드나 마우스 등 외부에서 들어오는 신호(인터럽트)를 CPU가 받을 수 있도록 컨트롤러를 켭니다.
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware 화면에 글자를 찍고(콘솔), 시리얼 통신을 할 준비를 합니다.
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port 화면에 글자를 찍고(콘솔), 시리얼 통신을 할 준비를 합니다.
80103500:	e8 d2 31 00 00       	call   801066d7 <uartinit>
  pinit();         // process table 프로세스 장부(프로세스 테이블)를 초기화합니다.
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors 메모리 보호 구역(세그먼트)을 설정하고, 오류나 시스템 콜이 발생했을 때 어디로 가야 할지(트랩 벡터)를 설정합니다.
8010350a:	e8 8c 2d 00 00       	call   8010629b <tvinit>
  binit();         // buffer cache 하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table 하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk  하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
80103519:	e8 d1 6f 00 00       	call   8010a4ef <ideinit>
  startothers();   // start other processors 잠들어 있는 나머지 CPU들을 깨웁니다. (자세한 건 아래 2번에서 설명할게요)
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers() 처음 4MB 이후의 나머지 모든 물리 메모리를 운영체제가 사용할 수 있도록 마저 할당합니다.
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init(); // 추가된 네트워크 및 하드웨어 장치를 스캔합니다 
80103538:	e8 20 50 00 00       	call   8010855d <pci_init>
  arp_scan(); // 추가된 네트워크 및 하드웨어 장치를 스캔합니다.
8010353d:	e8 99 5d 00 00       	call   801092db <arp_scan>
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
80103556:	e8 88 43 00 00       	call   801078e3 <switchkvm>
  seginit();
8010355b:	e8 ee 3d 00 00       	call   8010734e <seginit>
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
80103586:	68 75 a8 10 80       	push   $0x8010a875
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 7d 2e 00 00       	call   80106415 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 32 0f 00 00       	call   801044e7 <scheduler>

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
801035d7:	e8 a5 18 00 00       	call   80104e81 <memmove>
801035dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035df:	c7 45 f4 c0 7d 19 80 	movl   $0x80197dc0,-0xc(%ebp)
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
80103661:	a1 80 80 19 80       	mov    0x80198080,%eax
80103666:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010366c:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
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
80103768:	68 89 a8 10 80       	push   $0x8010a889
8010376d:	50                   	push   %eax
8010376e:	e8 92 13 00 00       	call   80104b05 <initlock>
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
80103831:	e8 f5 12 00 00       	call   80104b2b <acquire>
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
80103858:	e8 7a 0f 00 00       	call   801047d7 <wakeup>
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
8010387b:	e8 57 0f 00 00       	call   801047d7 <wakeup>
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
801038a4:	e8 f4 12 00 00       	call   80104b9d <release>
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
801038c3:	e8 d5 12 00 00       	call   80104b9d <release>
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
801038e1:	e8 45 12 00 00       	call   80104b2b <acquire>
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
80103915:	e8 83 12 00 00       	call   80104b9d <release>
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
80103933:	e8 9f 0e 00 00       	call   801047d7 <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 97 0d 00 00       	call   801046e8 <sleep>
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
801039b6:	e8 1c 0e 00 00       	call   801047d7 <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 d3 11 00 00       	call   80104b9d <release>
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
801039e6:	e8 40 11 00 00       	call   80104b2b <acquire>
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
80103a03:	e8 95 11 00 00       	call   80104b9d <release>
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
80103a26:	e8 bd 0c 00 00       	call   801046e8 <sleep>
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
80103ab9:	e8 19 0d 00 00       	call   801047d7 <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 d0 10 00 00       	call   80104b9d <release>
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
80103af9:	68 90 a8 10 80       	push   $0x8010a890
80103afe:	68 00 55 19 80       	push   $0x80195500
80103b03:	e8 fd 0f 00 00       	call   80104b05 <initlock>
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
80103b1d:	2d c0 7d 19 80       	sub    $0x80197dc0,%eax
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
80103b48:	68 98 a8 10 80       	push   $0x8010a898
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
80103b6c:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103b71:	0f b6 00             	movzbl (%eax),%eax
80103b74:	0f b6 c0             	movzbl %al,%eax
80103b77:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b7a:	75 10                	jne    80103b8c <mycpu+0x5f>
      return &cpus[i];
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b85:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80103b8a:	eb 1b                	jmp    80103ba7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b90:	a1 80 80 19 80       	mov    0x80198080,%eax
80103b95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b98:	7c c9                	jl     80103b63 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b9a:	83 ec 0c             	sub    $0xc,%esp
80103b9d:	68 be a8 10 80       	push   $0x8010a8be
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
80103bb3:	e8 ef 10 00 00       	call   80104ca7 <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 27 11 00 00       	call   80104cf8 <popcli>
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
80103be8:	e8 3e 0f 00 00       	call   80104b2b <acquire>
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
80103c03:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103c07:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80103c0e:	72 e9                	jb     80103bf9 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c10:	83 ec 0c             	sub    $0xc,%esp
80103c13:	68 00 55 19 80       	push   $0x80195500
80103c18:	e8 80 0f 00 00       	call   80104b9d <release>
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
80103c55:	e8 43 0f 00 00       	call   80104b9d <release>
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
80103ca2:	ba 55 62 10 80       	mov    $0x80106255,%edx
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
80103cc7:	e8 ee 10 00 00       	call   80104dba <memset>
80103ccc:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd2:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cd5:	ba 9e 46 10 80       	mov    $0x8010469e,%edx
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
80103cfc:	e8 d5 3a 00 00       	call   801077d6 <setupkvm>
80103d01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d04:	89 42 04             	mov    %eax,0x4(%edx)
80103d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0a:	8b 40 04             	mov    0x4(%eax),%eax
80103d0d:	85 c0                	test   %eax,%eax
80103d0f:	75 0d                	jne    80103d1e <userinit+0x3c>
    panic("userinit: out of memory?");
80103d11:	83 ec 0c             	sub    $0xc,%esp
80103d14:	68 ce a8 10 80       	push   $0x8010a8ce
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
80103d33:	e8 6b 3d 00 00       	call   80107aa3 <inituvm>
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
80103d52:	e8 63 10 00 00       	call   80104dba <memset>
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
80103dcc:	68 e7 a8 10 80       	push   $0x8010a8e7
80103dd1:	50                   	push   %eax
80103dd2:	e8 fe 11 00 00       	call   80104fd5 <safestrcpy>
80103dd7:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103dda:	83 ec 0c             	sub    $0xc,%esp
80103ddd:	68 f0 a8 10 80       	push   $0x8010a8f0
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
80103df8:	e8 2e 0d 00 00       	call   80104b2b <acquire>
80103dfd:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e03:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e0a:	83 ec 0c             	sub    $0xc,%esp
80103e0d:	68 00 55 19 80       	push   $0x80195500
80103e12:	e8 86 0d 00 00       	call   80104b9d <release>
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
80103e53:	e8 90 3d 00 00       	call   80107be8 <allocuvm>
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
80103e87:	e8 65 3e 00 00       	call   80107cf1 <deallocuvm>
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
80103ead:	e8 4e 3a 00 00       	call   80107900 <switchuvm>
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
80103ef9:	e8 9d 3f 00 00       	call   80107e9b <copyuvm>
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
80103ff3:	e8 dd 0f 00 00       	call   80104fd5 <safestrcpy>
80103ff8:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ffb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ffe:	8b 40 10             	mov    0x10(%eax),%eax
80104001:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104004:	83 ec 0c             	sub    $0xc,%esp
80104007:	68 00 55 19 80       	push   $0x80195500
8010400c:	e8 1a 0b 00 00       	call   80104b2b <acquire>
80104011:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104014:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104017:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010401e:	83 ec 0c             	sub    $0xc,%esp
80104021:	68 00 55 19 80       	push   $0x80195500
80104026:	e8 72 0b 00 00       	call   80104b9d <release>
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
80104058:	68 f2 a8 10 80       	push   $0x8010a8f2
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
801040de:	e8 48 0a 00 00       	call   80104b2b <acquire>
801040e3:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801040e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040e9:	8b 40 14             	mov    0x14(%eax),%eax
801040ec:	83 ec 0c             	sub    $0xc,%esp
801040ef:	50                   	push   %eax
801040f0:	e8 9e 06 00 00       	call   80104793 <wakeup1>
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
8010412c:	e8 62 06 00 00       	call   80104793 <wakeup1>
80104131:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104134:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104138:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010413f:	72 c0                	jb     80104101 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104141:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104144:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010414b:	e8 53 04 00 00       	call   801045a3 <sched>
  panic("zombie exit");
80104150:	83 ec 0c             	sub    $0xc,%esp
80104153:	68 ff a8 10 80       	push   $0x8010a8ff
80104158:	e8 68 c4 ff ff       	call   801005c5 <panic>

8010415d <exit2>:
}

void
exit2(int status)
{
8010415d:	f3 0f 1e fb          	endbr32 
80104161:	55                   	push   %ebp
80104162:	89 e5                	mov    %esp,%ebp
80104164:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104167:	e8 3d fa ff ff       	call   80103ba9 <myproc>
8010416c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010416f:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104174:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104177:	75 0d                	jne    80104186 <exit2+0x29>
    panic("init exiting");
80104179:	83 ec 0c             	sub    $0xc,%esp
8010417c:	68 f2 a8 10 80       	push   $0x8010a8f2
80104181:	e8 3f c4 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104186:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010418d:	eb 3f                	jmp    801041ce <exit2+0x71>
    if(curproc->ofile[fd]){
8010418f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104192:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104195:	83 c2 08             	add    $0x8,%edx
80104198:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010419c:	85 c0                	test   %eax,%eax
8010419e:	74 2a                	je     801041ca <exit2+0x6d>
      fileclose(curproc->ofile[fd]);
801041a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041a6:	83 c2 08             	add    $0x8,%edx
801041a9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041ad:	83 ec 0c             	sub    $0xc,%esp
801041b0:	50                   	push   %eax
801041b1:	e8 33 cf ff ff       	call   801010e9 <fileclose>
801041b6:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801041b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041bf:	83 c2 08             	add    $0x8,%edx
801041c2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801041c9:	00 
  for(fd = 0; fd < NOFILE; fd++){
801041ca:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801041ce:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801041d2:	7e bb                	jle    8010418f <exit2+0x32>
    }
  }

  begin_op();
801041d4:	e8 98 ef ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801041d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041dc:	8b 40 68             	mov    0x68(%eax),%eax
801041df:	83 ec 0c             	sub    $0xc,%esp
801041e2:	50                   	push   %eax
801041e3:	e8 fd d9 ff ff       	call   80101be5 <iput>
801041e8:	83 c4 10             	add    $0x10,%esp
  end_op();
801041eb:	e8 11 f0 ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
801041f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041f3:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801041fa:	83 ec 0c             	sub    $0xc,%esp
801041fd:	68 00 55 19 80       	push   $0x80195500
80104202:	e8 24 09 00 00       	call   80104b2b <acquire>
80104207:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010420a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010420d:	8b 40 14             	mov    0x14(%eax),%eax
80104210:	83 ec 0c             	sub    $0xc,%esp
80104213:	50                   	push   %eax
80104214:	e8 7a 05 00 00       	call   80104793 <wakeup1>
80104219:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010421c:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104223:	eb 37                	jmp    8010425c <exit2+0xff>
    if(p->parent == curproc){
80104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104228:	8b 40 14             	mov    0x14(%eax),%eax
8010422b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010422e:	75 28                	jne    80104258 <exit2+0xfb>
      p->parent = initproc;
80104230:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104239:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010423c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423f:	8b 40 0c             	mov    0xc(%eax),%eax
80104242:	83 f8 05             	cmp    $0x5,%eax
80104245:	75 11                	jne    80104258 <exit2+0xfb>
        wakeup1(initproc);
80104247:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
8010424c:	83 ec 0c             	sub    $0xc,%esp
8010424f:	50                   	push   %eax
80104250:	e8 3e 05 00 00       	call   80104793 <wakeup1>
80104255:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104258:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010425c:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104263:	72 c0                	jb     80104225 <exit2+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->xstate = status;
80104265:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104268:	8b 55 08             	mov    0x8(%ebp),%edx
8010426b:	89 50 7c             	mov    %edx,0x7c(%eax)
  curproc->state = ZOMBIE;
8010426e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104271:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)

  sched();
80104278:	e8 26 03 00 00       	call   801045a3 <sched>
  panic("zombie exit");
8010427d:	83 ec 0c             	sub    $0xc,%esp
80104280:	68 ff a8 10 80       	push   $0x8010a8ff
80104285:	e8 3b c3 ff ff       	call   801005c5 <panic>

8010428a <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010428a:	f3 0f 1e fb          	endbr32 
8010428e:	55                   	push   %ebp
8010428f:	89 e5                	mov    %esp,%ebp
80104291:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104294:	e8 10 f9 ff ff       	call   80103ba9 <myproc>
80104299:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
8010429c:	83 ec 0c             	sub    $0xc,%esp
8010429f:	68 00 55 19 80       	push   $0x80195500
801042a4:	e8 82 08 00 00       	call   80104b2b <acquire>
801042a9:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801042ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042b3:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801042ba:	e9 a1 00 00 00       	jmp    80104360 <wait+0xd6>
      if(p->parent != curproc)
801042bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042c2:	8b 40 14             	mov    0x14(%eax),%eax
801042c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801042c8:	0f 85 8d 00 00 00    	jne    8010435b <wait+0xd1>
        continue;
      havekids = 1;
801042ce:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801042d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d8:	8b 40 0c             	mov    0xc(%eax),%eax
801042db:	83 f8 05             	cmp    $0x5,%eax
801042de:	75 7c                	jne    8010435c <wait+0xd2>
        // Found one.
        pid = p->pid;
801042e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e3:	8b 40 10             	mov    0x10(%eax),%eax
801042e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801042e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ec:	8b 40 08             	mov    0x8(%eax),%eax
801042ef:	83 ec 0c             	sub    $0xc,%esp
801042f2:	50                   	push   %eax
801042f3:	e8 fc e4 ff ff       	call   801027f4 <kfree>
801042f8:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801042fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104308:	8b 40 04             	mov    0x4(%eax),%eax
8010430b:	83 ec 0c             	sub    $0xc,%esp
8010430e:	50                   	push   %eax
8010430f:	e8 a5 3a 00 00       	call   80107db9 <freevm>
80104314:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104324:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010432b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104335:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010433c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104346:	83 ec 0c             	sub    $0xc,%esp
80104349:	68 00 55 19 80       	push   $0x80195500
8010434e:	e8 4a 08 00 00       	call   80104b9d <release>
80104353:	83 c4 10             	add    $0x10,%esp
        return pid;
80104356:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104359:	eb 51                	jmp    801043ac <wait+0x122>
        continue;
8010435b:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010435c:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104360:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104367:	0f 82 52 ff ff ff    	jb     801042bf <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010436d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104371:	74 0a                	je     8010437d <wait+0xf3>
80104373:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104376:	8b 40 24             	mov    0x24(%eax),%eax
80104379:	85 c0                	test   %eax,%eax
8010437b:	74 17                	je     80104394 <wait+0x10a>
      release(&ptable.lock);
8010437d:	83 ec 0c             	sub    $0xc,%esp
80104380:	68 00 55 19 80       	push   $0x80195500
80104385:	e8 13 08 00 00       	call   80104b9d <release>
8010438a:	83 c4 10             	add    $0x10,%esp
      return -1;
8010438d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104392:	eb 18                	jmp    801043ac <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104394:	83 ec 08             	sub    $0x8,%esp
80104397:	68 00 55 19 80       	push   $0x80195500
8010439c:	ff 75 ec             	pushl  -0x14(%ebp)
8010439f:	e8 44 03 00 00       	call   801046e8 <sleep>
801043a4:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801043a7:	e9 00 ff ff ff       	jmp    801042ac <wait+0x22>
  }
}
801043ac:	c9                   	leave  
801043ad:	c3                   	ret    

801043ae <wait2>:

int
wait2(int *status)
{
801043ae:	f3 0f 1e fb          	endbr32 
801043b2:	55                   	push   %ebp
801043b3:	89 e5                	mov    %esp,%ebp
801043b5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801043b8:	e8 ec f7 ff ff       	call   80103ba9 <myproc>
801043bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801043c0:	83 ec 0c             	sub    $0xc,%esp
801043c3:	68 00 55 19 80       	push   $0x80195500
801043c8:	e8 5e 07 00 00       	call   80104b2b <acquire>
801043cd:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801043d0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043d7:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801043de:	e9 b6 00 00 00       	jmp    80104499 <wait2+0xeb>
      if(p->parent != curproc)
801043e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e6:	8b 40 14             	mov    0x14(%eax),%eax
801043e9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801043ec:	0f 85 a2 00 00 00    	jne    80104494 <wait2+0xe6>
        continue;
      havekids = 1;
801043f2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801043f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fc:	8b 40 0c             	mov    0xc(%eax),%eax
801043ff:	83 f8 05             	cmp    $0x5,%eax
80104402:	0f 85 8d 00 00 00    	jne    80104495 <wait2+0xe7>
        // Found one.
        pid = p->pid;
80104408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440b:	8b 40 10             	mov    0x10(%eax),%eax
8010440e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104414:	8b 40 08             	mov    0x8(%eax),%eax
80104417:	83 ec 0c             	sub    $0xc,%esp
8010441a:	50                   	push   %eax
8010441b:	e8 d4 e3 ff ff       	call   801027f4 <kfree>
80104420:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104426:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010442d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104430:	8b 40 04             	mov    0x4(%eax),%eax
80104433:	83 ec 0c             	sub    $0xc,%esp
80104436:	50                   	push   %eax
80104437:	e8 7d 39 00 00       	call   80107db9 <freevm>
8010443c:	83 c4 10             	add    $0x10,%esp

        if(status != 0)
8010443f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104443:	74 0b                	je     80104450 <wait2+0xa2>
          *status = p->xstate;
80104445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104448:	8b 50 7c             	mov    0x7c(%eax),%edx
8010444b:	8b 45 08             	mov    0x8(%ebp),%eax
8010444e:	89 10                	mov    %edx,(%eax)
        
        p->pid = 0;
80104450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104453:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010445a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104467:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104478:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010447f:	83 ec 0c             	sub    $0xc,%esp
80104482:	68 00 55 19 80       	push   $0x80195500
80104487:	e8 11 07 00 00       	call   80104b9d <release>
8010448c:	83 c4 10             	add    $0x10,%esp
        return pid;
8010448f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104492:	eb 51                	jmp    801044e5 <wait2+0x137>
        continue;
80104494:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104495:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104499:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
801044a0:	0f 82 3d ff ff ff    	jb     801043e3 <wait2+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801044a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801044aa:	74 0a                	je     801044b6 <wait2+0x108>
801044ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044af:	8b 40 24             	mov    0x24(%eax),%eax
801044b2:	85 c0                	test   %eax,%eax
801044b4:	74 17                	je     801044cd <wait2+0x11f>
      release(&ptable.lock);
801044b6:	83 ec 0c             	sub    $0xc,%esp
801044b9:	68 00 55 19 80       	push   $0x80195500
801044be:	e8 da 06 00 00       	call   80104b9d <release>
801044c3:	83 c4 10             	add    $0x10,%esp
      return -1;
801044c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044cb:	eb 18                	jmp    801044e5 <wait2+0x137>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801044cd:	83 ec 08             	sub    $0x8,%esp
801044d0:	68 00 55 19 80       	push   $0x80195500
801044d5:	ff 75 ec             	pushl  -0x14(%ebp)
801044d8:	e8 0b 02 00 00       	call   801046e8 <sleep>
801044dd:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801044e0:	e9 eb fe ff ff       	jmp    801043d0 <wait2+0x22>
  }
}
801044e5:	c9                   	leave  
801044e6:	c3                   	ret    

801044e7 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801044e7:	f3 0f 1e fb          	endbr32 
801044eb:	55                   	push   %ebp
801044ec:	89 e5                	mov    %esp,%ebp
801044ee:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801044f1:	e8 37 f6 ff ff       	call   80103b2d <mycpu>
801044f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801044f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044fc:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104503:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104506:	e8 da f5 ff ff       	call   80103ae5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010450b:	83 ec 0c             	sub    $0xc,%esp
8010450e:	68 00 55 19 80       	push   $0x80195500
80104513:	e8 13 06 00 00       	call   80104b2b <acquire>
80104518:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010451b:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104522:	eb 61                	jmp    80104585 <scheduler+0x9e>
      if(p->state != RUNNABLE)
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 40 0c             	mov    0xc(%eax),%eax
8010452a:	83 f8 03             	cmp    $0x3,%eax
8010452d:	75 51                	jne    80104580 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010452f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104532:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104535:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010453b:	83 ec 0c             	sub    $0xc,%esp
8010453e:	ff 75 f4             	pushl  -0xc(%ebp)
80104541:	e8 ba 33 00 00       	call   80107900 <switchuvm>
80104546:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104556:	8b 40 1c             	mov    0x1c(%eax),%eax
80104559:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010455c:	83 c2 04             	add    $0x4,%edx
8010455f:	83 ec 08             	sub    $0x8,%esp
80104562:	50                   	push   %eax
80104563:	52                   	push   %edx
80104564:	e8 e5 0a 00 00       	call   8010504e <swtch>
80104569:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010456c:	e8 72 33 00 00       	call   801078e3 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104574:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010457b:	00 00 00 
8010457e:	eb 01                	jmp    80104581 <scheduler+0x9a>
        continue;
80104580:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104581:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104585:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
8010458c:	72 96                	jb     80104524 <scheduler+0x3d>
    }
    release(&ptable.lock);
8010458e:	83 ec 0c             	sub    $0xc,%esp
80104591:	68 00 55 19 80       	push   $0x80195500
80104596:	e8 02 06 00 00       	call   80104b9d <release>
8010459b:	83 c4 10             	add    $0x10,%esp
    sti();
8010459e:	e9 63 ff ff ff       	jmp    80104506 <scheduler+0x1f>

801045a3 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801045a3:	f3 0f 1e fb          	endbr32 
801045a7:	55                   	push   %ebp
801045a8:	89 e5                	mov    %esp,%ebp
801045aa:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801045ad:	e8 f7 f5 ff ff       	call   80103ba9 <myproc>
801045b2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801045b5:	83 ec 0c             	sub    $0xc,%esp
801045b8:	68 00 55 19 80       	push   $0x80195500
801045bd:	e8 b0 06 00 00       	call   80104c72 <holding>
801045c2:	83 c4 10             	add    $0x10,%esp
801045c5:	85 c0                	test   %eax,%eax
801045c7:	75 0d                	jne    801045d6 <sched+0x33>
    panic("sched ptable.lock");
801045c9:	83 ec 0c             	sub    $0xc,%esp
801045cc:	68 0b a9 10 80       	push   $0x8010a90b
801045d1:	e8 ef bf ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
801045d6:	e8 52 f5 ff ff       	call   80103b2d <mycpu>
801045db:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801045e1:	83 f8 01             	cmp    $0x1,%eax
801045e4:	74 0d                	je     801045f3 <sched+0x50>
    panic("sched locks");
801045e6:	83 ec 0c             	sub    $0xc,%esp
801045e9:	68 1d a9 10 80       	push   $0x8010a91d
801045ee:	e8 d2 bf ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
801045f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f6:	8b 40 0c             	mov    0xc(%eax),%eax
801045f9:	83 f8 04             	cmp    $0x4,%eax
801045fc:	75 0d                	jne    8010460b <sched+0x68>
    panic("sched running");
801045fe:	83 ec 0c             	sub    $0xc,%esp
80104601:	68 29 a9 10 80       	push   $0x8010a929
80104606:	e8 ba bf ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
8010460b:	e8 c5 f4 ff ff       	call   80103ad5 <readeflags>
80104610:	25 00 02 00 00       	and    $0x200,%eax
80104615:	85 c0                	test   %eax,%eax
80104617:	74 0d                	je     80104626 <sched+0x83>
    panic("sched interruptible");
80104619:	83 ec 0c             	sub    $0xc,%esp
8010461c:	68 37 a9 10 80       	push   $0x8010a937
80104621:	e8 9f bf ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
80104626:	e8 02 f5 ff ff       	call   80103b2d <mycpu>
8010462b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104631:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104634:	e8 f4 f4 ff ff       	call   80103b2d <mycpu>
80104639:	8b 40 04             	mov    0x4(%eax),%eax
8010463c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010463f:	83 c2 1c             	add    $0x1c,%edx
80104642:	83 ec 08             	sub    $0x8,%esp
80104645:	50                   	push   %eax
80104646:	52                   	push   %edx
80104647:	e8 02 0a 00 00       	call   8010504e <swtch>
8010464c:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010464f:	e8 d9 f4 ff ff       	call   80103b2d <mycpu>
80104654:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104657:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
8010465d:	90                   	nop
8010465e:	c9                   	leave  
8010465f:	c3                   	ret    

80104660 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104660:	f3 0f 1e fb          	endbr32 
80104664:	55                   	push   %ebp
80104665:	89 e5                	mov    %esp,%ebp
80104667:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010466a:	83 ec 0c             	sub    $0xc,%esp
8010466d:	68 00 55 19 80       	push   $0x80195500
80104672:	e8 b4 04 00 00       	call   80104b2b <acquire>
80104677:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010467a:	e8 2a f5 ff ff       	call   80103ba9 <myproc>
8010467f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104686:	e8 18 ff ff ff       	call   801045a3 <sched>
  release(&ptable.lock);
8010468b:	83 ec 0c             	sub    $0xc,%esp
8010468e:	68 00 55 19 80       	push   $0x80195500
80104693:	e8 05 05 00 00       	call   80104b9d <release>
80104698:	83 c4 10             	add    $0x10,%esp
}
8010469b:	90                   	nop
8010469c:	c9                   	leave  
8010469d:	c3                   	ret    

8010469e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010469e:	f3 0f 1e fb          	endbr32 
801046a2:	55                   	push   %ebp
801046a3:	89 e5                	mov    %esp,%ebp
801046a5:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801046a8:	83 ec 0c             	sub    $0xc,%esp
801046ab:	68 00 55 19 80       	push   $0x80195500
801046b0:	e8 e8 04 00 00       	call   80104b9d <release>
801046b5:	83 c4 10             	add    $0x10,%esp

  if (first) {
801046b8:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801046bd:	85 c0                	test   %eax,%eax
801046bf:	74 24                	je     801046e5 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801046c1:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801046c8:	00 00 00 
    iinit(ROOTDEV);
801046cb:	83 ec 0c             	sub    $0xc,%esp
801046ce:	6a 01                	push   $0x1
801046d0:	e8 21 d0 ff ff       	call   801016f6 <iinit>
801046d5:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801046d8:	83 ec 0c             	sub    $0xc,%esp
801046db:	6a 01                	push   $0x1
801046dd:	e8 5c e8 ff ff       	call   80102f3e <initlog>
801046e2:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801046e5:	90                   	nop
801046e6:	c9                   	leave  
801046e7:	c3                   	ret    

801046e8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801046e8:	f3 0f 1e fb          	endbr32 
801046ec:	55                   	push   %ebp
801046ed:	89 e5                	mov    %esp,%ebp
801046ef:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801046f2:	e8 b2 f4 ff ff       	call   80103ba9 <myproc>
801046f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801046fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046fe:	75 0d                	jne    8010470d <sleep+0x25>
    panic("sleep");
80104700:	83 ec 0c             	sub    $0xc,%esp
80104703:	68 4b a9 10 80       	push   $0x8010a94b
80104708:	e8 b8 be ff ff       	call   801005c5 <panic>

  if(lk == 0)
8010470d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104711:	75 0d                	jne    80104720 <sleep+0x38>
    panic("sleep without lk");
80104713:	83 ec 0c             	sub    $0xc,%esp
80104716:	68 51 a9 10 80       	push   $0x8010a951
8010471b:	e8 a5 be ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104720:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104727:	74 1e                	je     80104747 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104729:	83 ec 0c             	sub    $0xc,%esp
8010472c:	68 00 55 19 80       	push   $0x80195500
80104731:	e8 f5 03 00 00       	call   80104b2b <acquire>
80104736:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104739:	83 ec 0c             	sub    $0xc,%esp
8010473c:	ff 75 0c             	pushl  0xc(%ebp)
8010473f:	e8 59 04 00 00       	call   80104b9d <release>
80104744:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474a:	8b 55 08             	mov    0x8(%ebp),%edx
8010474d:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104753:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010475a:	e8 44 fe ff ff       	call   801045a3 <sched>

  // Tidy up.
  p->chan = 0;
8010475f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104762:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104769:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104770:	74 1e                	je     80104790 <sleep+0xa8>
    release(&ptable.lock);
80104772:	83 ec 0c             	sub    $0xc,%esp
80104775:	68 00 55 19 80       	push   $0x80195500
8010477a:	e8 1e 04 00 00       	call   80104b9d <release>
8010477f:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104782:	83 ec 0c             	sub    $0xc,%esp
80104785:	ff 75 0c             	pushl  0xc(%ebp)
80104788:	e8 9e 03 00 00       	call   80104b2b <acquire>
8010478d:	83 c4 10             	add    $0x10,%esp
  }
}
80104790:	90                   	nop
80104791:	c9                   	leave  
80104792:	c3                   	ret    

80104793 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104793:	f3 0f 1e fb          	endbr32 
80104797:	55                   	push   %ebp
80104798:	89 e5                	mov    %esp,%ebp
8010479a:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010479d:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
801047a4:	eb 24                	jmp    801047ca <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
801047a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801047a9:	8b 40 0c             	mov    0xc(%eax),%eax
801047ac:	83 f8 02             	cmp    $0x2,%eax
801047af:	75 15                	jne    801047c6 <wakeup1+0x33>
801047b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801047b4:	8b 40 20             	mov    0x20(%eax),%eax
801047b7:	39 45 08             	cmp    %eax,0x8(%ebp)
801047ba:	75 0a                	jne    801047c6 <wakeup1+0x33>
      p->state = RUNNABLE;
801047bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801047bf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047c6:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801047ca:	81 7d fc 34 75 19 80 	cmpl   $0x80197534,-0x4(%ebp)
801047d1:	72 d3                	jb     801047a6 <wakeup1+0x13>
}
801047d3:	90                   	nop
801047d4:	90                   	nop
801047d5:	c9                   	leave  
801047d6:	c3                   	ret    

801047d7 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801047d7:	f3 0f 1e fb          	endbr32 
801047db:	55                   	push   %ebp
801047dc:	89 e5                	mov    %esp,%ebp
801047de:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801047e1:	83 ec 0c             	sub    $0xc,%esp
801047e4:	68 00 55 19 80       	push   $0x80195500
801047e9:	e8 3d 03 00 00       	call   80104b2b <acquire>
801047ee:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801047f1:	83 ec 0c             	sub    $0xc,%esp
801047f4:	ff 75 08             	pushl  0x8(%ebp)
801047f7:	e8 97 ff ff ff       	call   80104793 <wakeup1>
801047fc:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801047ff:	83 ec 0c             	sub    $0xc,%esp
80104802:	68 00 55 19 80       	push   $0x80195500
80104807:	e8 91 03 00 00       	call   80104b9d <release>
8010480c:	83 c4 10             	add    $0x10,%esp
}
8010480f:	90                   	nop
80104810:	c9                   	leave  
80104811:	c3                   	ret    

80104812 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104812:	f3 0f 1e fb          	endbr32 
80104816:	55                   	push   %ebp
80104817:	89 e5                	mov    %esp,%ebp
80104819:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010481c:	83 ec 0c             	sub    $0xc,%esp
8010481f:	68 00 55 19 80       	push   $0x80195500
80104824:	e8 02 03 00 00       	call   80104b2b <acquire>
80104829:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010482c:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104833:	eb 45                	jmp    8010487a <kill+0x68>
    if(p->pid == pid){
80104835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104838:	8b 40 10             	mov    0x10(%eax),%eax
8010483b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010483e:	75 36                	jne    80104876 <kill+0x64>
      p->killed = 1;
80104840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104843:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010484a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484d:	8b 40 0c             	mov    0xc(%eax),%eax
80104850:	83 f8 02             	cmp    $0x2,%eax
80104853:	75 0a                	jne    8010485f <kill+0x4d>
        p->state = RUNNABLE;
80104855:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104858:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010485f:	83 ec 0c             	sub    $0xc,%esp
80104862:	68 00 55 19 80       	push   $0x80195500
80104867:	e8 31 03 00 00       	call   80104b9d <release>
8010486c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010486f:	b8 00 00 00 00       	mov    $0x0,%eax
80104874:	eb 22                	jmp    80104898 <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104876:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010487a:	81 7d f4 34 75 19 80 	cmpl   $0x80197534,-0xc(%ebp)
80104881:	72 b2                	jb     80104835 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104883:	83 ec 0c             	sub    $0xc,%esp
80104886:	68 00 55 19 80       	push   $0x80195500
8010488b:	e8 0d 03 00 00       	call   80104b9d <release>
80104890:	83 c4 10             	add    $0x10,%esp
  return -1;
80104893:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104898:	c9                   	leave  
80104899:	c3                   	ret    

8010489a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010489a:	f3 0f 1e fb          	endbr32 
8010489e:	55                   	push   %ebp
8010489f:	89 e5                	mov    %esp,%ebp
801048a1:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a4:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
801048ab:	e9 d7 00 00 00       	jmp    80104987 <procdump+0xed>
    if(p->state == UNUSED)
801048b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048b3:	8b 40 0c             	mov    0xc(%eax),%eax
801048b6:	85 c0                	test   %eax,%eax
801048b8:	0f 84 c4 00 00 00    	je     80104982 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801048be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048c1:	8b 40 0c             	mov    0xc(%eax),%eax
801048c4:	83 f8 05             	cmp    $0x5,%eax
801048c7:	77 23                	ja     801048ec <procdump+0x52>
801048c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048cc:	8b 40 0c             	mov    0xc(%eax),%eax
801048cf:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801048d6:	85 c0                	test   %eax,%eax
801048d8:	74 12                	je     801048ec <procdump+0x52>
      state = states[p->state];
801048da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048dd:	8b 40 0c             	mov    0xc(%eax),%eax
801048e0:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801048e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801048ea:	eb 07                	jmp    801048f3 <procdump+0x59>
    else
      state = "???";
801048ec:	c7 45 ec 62 a9 10 80 	movl   $0x8010a962,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801048f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048f6:	8d 50 6c             	lea    0x6c(%eax),%edx
801048f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048fc:	8b 40 10             	mov    0x10(%eax),%eax
801048ff:	52                   	push   %edx
80104900:	ff 75 ec             	pushl  -0x14(%ebp)
80104903:	50                   	push   %eax
80104904:	68 66 a9 10 80       	push   $0x8010a966
80104909:	e8 fe ba ff ff       	call   8010040c <cprintf>
8010490e:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104911:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104914:	8b 40 0c             	mov    0xc(%eax),%eax
80104917:	83 f8 02             	cmp    $0x2,%eax
8010491a:	75 54                	jne    80104970 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010491c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010491f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104922:	8b 40 0c             	mov    0xc(%eax),%eax
80104925:	83 c0 08             	add    $0x8,%eax
80104928:	89 c2                	mov    %eax,%edx
8010492a:	83 ec 08             	sub    $0x8,%esp
8010492d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104930:	50                   	push   %eax
80104931:	52                   	push   %edx
80104932:	e8 bc 02 00 00       	call   80104bf3 <getcallerpcs>
80104937:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010493a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104941:	eb 1c                	jmp    8010495f <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104946:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010494a:	83 ec 08             	sub    $0x8,%esp
8010494d:	50                   	push   %eax
8010494e:	68 6f a9 10 80       	push   $0x8010a96f
80104953:	e8 b4 ba ff ff       	call   8010040c <cprintf>
80104958:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010495b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010495f:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104963:	7f 0b                	jg     80104970 <procdump+0xd6>
80104965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104968:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010496c:	85 c0                	test   %eax,%eax
8010496e:	75 d3                	jne    80104943 <procdump+0xa9>
    }
    cprintf("\n");
80104970:	83 ec 0c             	sub    $0xc,%esp
80104973:	68 73 a9 10 80       	push   $0x8010a973
80104978:	e8 8f ba ff ff       	call   8010040c <cprintf>
8010497d:	83 c4 10             	add    $0x10,%esp
80104980:	eb 01                	jmp    80104983 <procdump+0xe9>
      continue;
80104982:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104983:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104987:	81 7d f0 34 75 19 80 	cmpl   $0x80197534,-0x10(%ebp)
8010498e:	0f 82 1c ff ff ff    	jb     801048b0 <procdump+0x16>
  }
}
80104994:	90                   	nop
80104995:	90                   	nop
80104996:	c9                   	leave  
80104997:	c3                   	ret    

80104998 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104998:	f3 0f 1e fb          	endbr32 
8010499c:	55                   	push   %ebp
8010499d:	89 e5                	mov    %esp,%ebp
8010499f:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801049a2:	8b 45 08             	mov    0x8(%ebp),%eax
801049a5:	83 c0 04             	add    $0x4,%eax
801049a8:	83 ec 08             	sub    $0x8,%esp
801049ab:	68 9f a9 10 80       	push   $0x8010a99f
801049b0:	50                   	push   %eax
801049b1:	e8 4f 01 00 00       	call   80104b05 <initlock>
801049b6:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801049b9:	8b 45 08             	mov    0x8(%ebp),%eax
801049bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801049bf:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801049c2:	8b 45 08             	mov    0x8(%ebp),%eax
801049c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801049cb:	8b 45 08             	mov    0x8(%ebp),%eax
801049ce:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801049d5:	90                   	nop
801049d6:	c9                   	leave  
801049d7:	c3                   	ret    

801049d8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801049d8:	f3 0f 1e fb          	endbr32 
801049dc:	55                   	push   %ebp
801049dd:	89 e5                	mov    %esp,%ebp
801049df:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801049e2:	8b 45 08             	mov    0x8(%ebp),%eax
801049e5:	83 c0 04             	add    $0x4,%eax
801049e8:	83 ec 0c             	sub    $0xc,%esp
801049eb:	50                   	push   %eax
801049ec:	e8 3a 01 00 00       	call   80104b2b <acquire>
801049f1:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801049f4:	eb 15                	jmp    80104a0b <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801049f6:	8b 45 08             	mov    0x8(%ebp),%eax
801049f9:	83 c0 04             	add    $0x4,%eax
801049fc:	83 ec 08             	sub    $0x8,%esp
801049ff:	50                   	push   %eax
80104a00:	ff 75 08             	pushl  0x8(%ebp)
80104a03:	e8 e0 fc ff ff       	call   801046e8 <sleep>
80104a08:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0e:	8b 00                	mov    (%eax),%eax
80104a10:	85 c0                	test   %eax,%eax
80104a12:	75 e2                	jne    801049f6 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104a14:	8b 45 08             	mov    0x8(%ebp),%eax
80104a17:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104a1d:	e8 87 f1 ff ff       	call   80103ba9 <myproc>
80104a22:	8b 50 10             	mov    0x10(%eax),%edx
80104a25:	8b 45 08             	mov    0x8(%ebp),%eax
80104a28:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2e:	83 c0 04             	add    $0x4,%eax
80104a31:	83 ec 0c             	sub    $0xc,%esp
80104a34:	50                   	push   %eax
80104a35:	e8 63 01 00 00       	call   80104b9d <release>
80104a3a:	83 c4 10             	add    $0x10,%esp
}
80104a3d:	90                   	nop
80104a3e:	c9                   	leave  
80104a3f:	c3                   	ret    

80104a40 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104a40:	f3 0f 1e fb          	endbr32 
80104a44:	55                   	push   %ebp
80104a45:	89 e5                	mov    %esp,%ebp
80104a47:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4d:	83 c0 04             	add    $0x4,%eax
80104a50:	83 ec 0c             	sub    $0xc,%esp
80104a53:	50                   	push   %eax
80104a54:	e8 d2 00 00 00       	call   80104b2b <acquire>
80104a59:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a65:	8b 45 08             	mov    0x8(%ebp),%eax
80104a68:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104a6f:	83 ec 0c             	sub    $0xc,%esp
80104a72:	ff 75 08             	pushl  0x8(%ebp)
80104a75:	e8 5d fd ff ff       	call   801047d7 <wakeup>
80104a7a:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104a80:	83 c0 04             	add    $0x4,%eax
80104a83:	83 ec 0c             	sub    $0xc,%esp
80104a86:	50                   	push   %eax
80104a87:	e8 11 01 00 00       	call   80104b9d <release>
80104a8c:	83 c4 10             	add    $0x10,%esp
}
80104a8f:	90                   	nop
80104a90:	c9                   	leave  
80104a91:	c3                   	ret    

80104a92 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104a92:	f3 0f 1e fb          	endbr32 
80104a96:	55                   	push   %ebp
80104a97:	89 e5                	mov    %esp,%ebp
80104a99:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a9f:	83 c0 04             	add    $0x4,%eax
80104aa2:	83 ec 0c             	sub    $0xc,%esp
80104aa5:	50                   	push   %eax
80104aa6:	e8 80 00 00 00       	call   80104b2b <acquire>
80104aab:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104aae:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab1:	8b 00                	mov    (%eax),%eax
80104ab3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab9:	83 c0 04             	add    $0x4,%eax
80104abc:	83 ec 0c             	sub    $0xc,%esp
80104abf:	50                   	push   %eax
80104ac0:	e8 d8 00 00 00       	call   80104b9d <release>
80104ac5:	83 c4 10             	add    $0x10,%esp
  return r;
80104ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104acb:	c9                   	leave  
80104acc:	c3                   	ret    

80104acd <readeflags>:
{
80104acd:	55                   	push   %ebp
80104ace:	89 e5                	mov    %esp,%ebp
80104ad0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ad3:	9c                   	pushf  
80104ad4:	58                   	pop    %eax
80104ad5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ad8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104adb:	c9                   	leave  
80104adc:	c3                   	ret    

80104add <cli>:
{
80104add:	55                   	push   %ebp
80104ade:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ae0:	fa                   	cli    
}
80104ae1:	90                   	nop
80104ae2:	5d                   	pop    %ebp
80104ae3:	c3                   	ret    

80104ae4 <sti>:
{
80104ae4:	55                   	push   %ebp
80104ae5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ae7:	fb                   	sti    
}
80104ae8:	90                   	nop
80104ae9:	5d                   	pop    %ebp
80104aea:	c3                   	ret    

80104aeb <xchg>:
{
80104aeb:	55                   	push   %ebp
80104aec:	89 e5                	mov    %esp,%ebp
80104aee:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104af1:	8b 55 08             	mov    0x8(%ebp),%edx
80104af4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af7:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104afa:	f0 87 02             	lock xchg %eax,(%edx)
80104afd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104b00:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b03:	c9                   	leave  
80104b04:	c3                   	ret    

80104b05 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b05:	f3 0f 1e fb          	endbr32 
80104b09:	55                   	push   %ebp
80104b0a:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b12:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b15:	8b 45 08             	mov    0x8(%ebp),%eax
80104b18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b21:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b28:	90                   	nop
80104b29:	5d                   	pop    %ebp
80104b2a:	c3                   	ret    

80104b2b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b2b:	f3 0f 1e fb          	endbr32 
80104b2f:	55                   	push   %ebp
80104b30:	89 e5                	mov    %esp,%ebp
80104b32:	53                   	push   %ebx
80104b33:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b36:	e8 6c 01 00 00       	call   80104ca7 <pushcli>
  if(holding(lk)){
80104b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104b3e:	83 ec 0c             	sub    $0xc,%esp
80104b41:	50                   	push   %eax
80104b42:	e8 2b 01 00 00       	call   80104c72 <holding>
80104b47:	83 c4 10             	add    $0x10,%esp
80104b4a:	85 c0                	test   %eax,%eax
80104b4c:	74 0d                	je     80104b5b <acquire+0x30>
    panic("acquire");
80104b4e:	83 ec 0c             	sub    $0xc,%esp
80104b51:	68 aa a9 10 80       	push   $0x8010a9aa
80104b56:	e8 6a ba ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104b5b:	90                   	nop
80104b5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5f:	83 ec 08             	sub    $0x8,%esp
80104b62:	6a 01                	push   $0x1
80104b64:	50                   	push   %eax
80104b65:	e8 81 ff ff ff       	call   80104aeb <xchg>
80104b6a:	83 c4 10             	add    $0x10,%esp
80104b6d:	85 c0                	test   %eax,%eax
80104b6f:	75 eb                	jne    80104b5c <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104b71:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104b76:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104b79:	e8 af ef ff ff       	call   80103b2d <mycpu>
80104b7e:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104b81:	8b 45 08             	mov    0x8(%ebp),%eax
80104b84:	83 c0 0c             	add    $0xc,%eax
80104b87:	83 ec 08             	sub    $0x8,%esp
80104b8a:	50                   	push   %eax
80104b8b:	8d 45 08             	lea    0x8(%ebp),%eax
80104b8e:	50                   	push   %eax
80104b8f:	e8 5f 00 00 00       	call   80104bf3 <getcallerpcs>
80104b94:	83 c4 10             	add    $0x10,%esp
}
80104b97:	90                   	nop
80104b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b9b:	c9                   	leave  
80104b9c:	c3                   	ret    

80104b9d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b9d:	f3 0f 1e fb          	endbr32 
80104ba1:	55                   	push   %ebp
80104ba2:	89 e5                	mov    %esp,%ebp
80104ba4:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104ba7:	83 ec 0c             	sub    $0xc,%esp
80104baa:	ff 75 08             	pushl  0x8(%ebp)
80104bad:	e8 c0 00 00 00       	call   80104c72 <holding>
80104bb2:	83 c4 10             	add    $0x10,%esp
80104bb5:	85 c0                	test   %eax,%eax
80104bb7:	75 0d                	jne    80104bc6 <release+0x29>
    panic("release");
80104bb9:	83 ec 0c             	sub    $0xc,%esp
80104bbc:	68 b2 a9 10 80       	push   $0x8010a9b2
80104bc1:	e8 ff b9 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104bda:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104be2:	8b 55 08             	mov    0x8(%ebp),%edx
80104be5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104beb:	e8 08 01 00 00       	call   80104cf8 <popcli>
}
80104bf0:	90                   	nop
80104bf1:	c9                   	leave  
80104bf2:	c3                   	ret    

80104bf3 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104bf3:	f3 0f 1e fb          	endbr32 
80104bf7:	55                   	push   %ebp
80104bf8:	89 e5                	mov    %esp,%ebp
80104bfa:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80104c00:	83 e8 08             	sub    $0x8,%eax
80104c03:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c06:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c0d:	eb 38                	jmp    80104c47 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c0f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c13:	74 53                	je     80104c68 <getcallerpcs+0x75>
80104c15:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c1c:	76 4a                	jbe    80104c68 <getcallerpcs+0x75>
80104c1e:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c22:	74 44                	je     80104c68 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c24:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c31:	01 c2                	add    %eax,%edx
80104c33:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c36:	8b 40 04             	mov    0x4(%eax),%eax
80104c39:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c3e:	8b 00                	mov    (%eax),%eax
80104c40:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c43:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c47:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c4b:	7e c2                	jle    80104c0f <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104c4d:	eb 19                	jmp    80104c68 <getcallerpcs+0x75>
    pcs[i] = 0;
80104c4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c59:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c5c:	01 d0                	add    %edx,%eax
80104c5e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104c64:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104c68:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c6c:	7e e1                	jle    80104c4f <getcallerpcs+0x5c>
}
80104c6e:	90                   	nop
80104c6f:	90                   	nop
80104c70:	c9                   	leave  
80104c71:	c3                   	ret    

80104c72 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c72:	f3 0f 1e fb          	endbr32 
80104c76:	55                   	push   %ebp
80104c77:	89 e5                	mov    %esp,%ebp
80104c79:	53                   	push   %ebx
80104c7a:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c80:	8b 00                	mov    (%eax),%eax
80104c82:	85 c0                	test   %eax,%eax
80104c84:	74 16                	je     80104c9c <holding+0x2a>
80104c86:	8b 45 08             	mov    0x8(%ebp),%eax
80104c89:	8b 58 08             	mov    0x8(%eax),%ebx
80104c8c:	e8 9c ee ff ff       	call   80103b2d <mycpu>
80104c91:	39 c3                	cmp    %eax,%ebx
80104c93:	75 07                	jne    80104c9c <holding+0x2a>
80104c95:	b8 01 00 00 00       	mov    $0x1,%eax
80104c9a:	eb 05                	jmp    80104ca1 <holding+0x2f>
80104c9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ca1:	83 c4 04             	add    $0x4,%esp
80104ca4:	5b                   	pop    %ebx
80104ca5:	5d                   	pop    %ebp
80104ca6:	c3                   	ret    

80104ca7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104ca7:	f3 0f 1e fb          	endbr32 
80104cab:	55                   	push   %ebp
80104cac:	89 e5                	mov    %esp,%ebp
80104cae:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104cb1:	e8 17 fe ff ff       	call   80104acd <readeflags>
80104cb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104cb9:	e8 1f fe ff ff       	call   80104add <cli>
  if(mycpu()->ncli == 0)
80104cbe:	e8 6a ee ff ff       	call   80103b2d <mycpu>
80104cc3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cc9:	85 c0                	test   %eax,%eax
80104ccb:	75 14                	jne    80104ce1 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104ccd:	e8 5b ee ff ff       	call   80103b2d <mycpu>
80104cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cd5:	81 e2 00 02 00 00    	and    $0x200,%edx
80104cdb:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104ce1:	e8 47 ee ff ff       	call   80103b2d <mycpu>
80104ce6:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104cec:	83 c2 01             	add    $0x1,%edx
80104cef:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104cf5:	90                   	nop
80104cf6:	c9                   	leave  
80104cf7:	c3                   	ret    

80104cf8 <popcli>:

void
popcli(void)
{
80104cf8:	f3 0f 1e fb          	endbr32 
80104cfc:	55                   	push   %ebp
80104cfd:	89 e5                	mov    %esp,%ebp
80104cff:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104d02:	e8 c6 fd ff ff       	call   80104acd <readeflags>
80104d07:	25 00 02 00 00       	and    $0x200,%eax
80104d0c:	85 c0                	test   %eax,%eax
80104d0e:	74 0d                	je     80104d1d <popcli+0x25>
    panic("popcli - interruptible");
80104d10:	83 ec 0c             	sub    $0xc,%esp
80104d13:	68 ba a9 10 80       	push   $0x8010a9ba
80104d18:	e8 a8 b8 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104d1d:	e8 0b ee ff ff       	call   80103b2d <mycpu>
80104d22:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d28:	83 ea 01             	sub    $0x1,%edx
80104d2b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104d31:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d37:	85 c0                	test   %eax,%eax
80104d39:	79 0d                	jns    80104d48 <popcli+0x50>
    panic("popcli");
80104d3b:	83 ec 0c             	sub    $0xc,%esp
80104d3e:	68 d1 a9 10 80       	push   $0x8010a9d1
80104d43:	e8 7d b8 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104d48:	e8 e0 ed ff ff       	call   80103b2d <mycpu>
80104d4d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d53:	85 c0                	test   %eax,%eax
80104d55:	75 14                	jne    80104d6b <popcli+0x73>
80104d57:	e8 d1 ed ff ff       	call   80103b2d <mycpu>
80104d5c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d62:	85 c0                	test   %eax,%eax
80104d64:	74 05                	je     80104d6b <popcli+0x73>
    sti();
80104d66:	e8 79 fd ff ff       	call   80104ae4 <sti>
}
80104d6b:	90                   	nop
80104d6c:	c9                   	leave  
80104d6d:	c3                   	ret    

80104d6e <stosb>:
{
80104d6e:	55                   	push   %ebp
80104d6f:	89 e5                	mov    %esp,%ebp
80104d71:	57                   	push   %edi
80104d72:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d76:	8b 55 10             	mov    0x10(%ebp),%edx
80104d79:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d7c:	89 cb                	mov    %ecx,%ebx
80104d7e:	89 df                	mov    %ebx,%edi
80104d80:	89 d1                	mov    %edx,%ecx
80104d82:	fc                   	cld    
80104d83:	f3 aa                	rep stos %al,%es:(%edi)
80104d85:	89 ca                	mov    %ecx,%edx
80104d87:	89 fb                	mov    %edi,%ebx
80104d89:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d8c:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104d8f:	90                   	nop
80104d90:	5b                   	pop    %ebx
80104d91:	5f                   	pop    %edi
80104d92:	5d                   	pop    %ebp
80104d93:	c3                   	ret    

80104d94 <stosl>:
{
80104d94:	55                   	push   %ebp
80104d95:	89 e5                	mov    %esp,%ebp
80104d97:	57                   	push   %edi
80104d98:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d99:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d9c:	8b 55 10             	mov    0x10(%ebp),%edx
80104d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104da2:	89 cb                	mov    %ecx,%ebx
80104da4:	89 df                	mov    %ebx,%edi
80104da6:	89 d1                	mov    %edx,%ecx
80104da8:	fc                   	cld    
80104da9:	f3 ab                	rep stos %eax,%es:(%edi)
80104dab:	89 ca                	mov    %ecx,%edx
80104dad:	89 fb                	mov    %edi,%ebx
80104daf:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104db2:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104db5:	90                   	nop
80104db6:	5b                   	pop    %ebx
80104db7:	5f                   	pop    %edi
80104db8:	5d                   	pop    %ebp
80104db9:	c3                   	ret    

80104dba <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104dba:	f3 0f 1e fb          	endbr32 
80104dbe:	55                   	push   %ebp
80104dbf:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc4:	83 e0 03             	and    $0x3,%eax
80104dc7:	85 c0                	test   %eax,%eax
80104dc9:	75 43                	jne    80104e0e <memset+0x54>
80104dcb:	8b 45 10             	mov    0x10(%ebp),%eax
80104dce:	83 e0 03             	and    $0x3,%eax
80104dd1:	85 c0                	test   %eax,%eax
80104dd3:	75 39                	jne    80104e0e <memset+0x54>
    c &= 0xFF;
80104dd5:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104ddc:	8b 45 10             	mov    0x10(%ebp),%eax
80104ddf:	c1 e8 02             	shr    $0x2,%eax
80104de2:	89 c1                	mov    %eax,%ecx
80104de4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de7:	c1 e0 18             	shl    $0x18,%eax
80104dea:	89 c2                	mov    %eax,%edx
80104dec:	8b 45 0c             	mov    0xc(%ebp),%eax
80104def:	c1 e0 10             	shl    $0x10,%eax
80104df2:	09 c2                	or     %eax,%edx
80104df4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104df7:	c1 e0 08             	shl    $0x8,%eax
80104dfa:	09 d0                	or     %edx,%eax
80104dfc:	0b 45 0c             	or     0xc(%ebp),%eax
80104dff:	51                   	push   %ecx
80104e00:	50                   	push   %eax
80104e01:	ff 75 08             	pushl  0x8(%ebp)
80104e04:	e8 8b ff ff ff       	call   80104d94 <stosl>
80104e09:	83 c4 0c             	add    $0xc,%esp
80104e0c:	eb 12                	jmp    80104e20 <memset+0x66>
  } else
    stosb(dst, c, n);
80104e0e:	8b 45 10             	mov    0x10(%ebp),%eax
80104e11:	50                   	push   %eax
80104e12:	ff 75 0c             	pushl  0xc(%ebp)
80104e15:	ff 75 08             	pushl  0x8(%ebp)
80104e18:	e8 51 ff ff ff       	call   80104d6e <stosb>
80104e1d:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104e20:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e23:	c9                   	leave  
80104e24:	c3                   	ret    

80104e25 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e25:	f3 0f 1e fb          	endbr32 
80104e29:	55                   	push   %ebp
80104e2a:	89 e5                	mov    %esp,%ebp
80104e2c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e32:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e35:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e38:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e3b:	eb 30                	jmp    80104e6d <memcmp+0x48>
    if(*s1 != *s2)
80104e3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e40:	0f b6 10             	movzbl (%eax),%edx
80104e43:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e46:	0f b6 00             	movzbl (%eax),%eax
80104e49:	38 c2                	cmp    %al,%dl
80104e4b:	74 18                	je     80104e65 <memcmp+0x40>
      return *s1 - *s2;
80104e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e50:	0f b6 00             	movzbl (%eax),%eax
80104e53:	0f b6 d0             	movzbl %al,%edx
80104e56:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e59:	0f b6 00             	movzbl (%eax),%eax
80104e5c:	0f b6 c0             	movzbl %al,%eax
80104e5f:	29 c2                	sub    %eax,%edx
80104e61:	89 d0                	mov    %edx,%eax
80104e63:	eb 1a                	jmp    80104e7f <memcmp+0x5a>
    s1++, s2++;
80104e65:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e69:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104e6d:	8b 45 10             	mov    0x10(%ebp),%eax
80104e70:	8d 50 ff             	lea    -0x1(%eax),%edx
80104e73:	89 55 10             	mov    %edx,0x10(%ebp)
80104e76:	85 c0                	test   %eax,%eax
80104e78:	75 c3                	jne    80104e3d <memcmp+0x18>
  }

  return 0;
80104e7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e7f:	c9                   	leave  
80104e80:	c3                   	ret    

80104e81 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e81:	f3 0f 1e fb          	endbr32 
80104e85:	55                   	push   %ebp
80104e86:	89 e5                	mov    %esp,%ebp
80104e88:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e91:	8b 45 08             	mov    0x8(%ebp),%eax
80104e94:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e9a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e9d:	73 54                	jae    80104ef3 <memmove+0x72>
80104e9f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ea2:	8b 45 10             	mov    0x10(%ebp),%eax
80104ea5:	01 d0                	add    %edx,%eax
80104ea7:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104eaa:	73 47                	jae    80104ef3 <memmove+0x72>
    s += n;
80104eac:	8b 45 10             	mov    0x10(%ebp),%eax
80104eaf:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104eb2:	8b 45 10             	mov    0x10(%ebp),%eax
80104eb5:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104eb8:	eb 13                	jmp    80104ecd <memmove+0x4c>
      *--d = *--s;
80104eba:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104ebe:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104ec2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ec5:	0f b6 10             	movzbl (%eax),%edx
80104ec8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ecb:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ecd:	8b 45 10             	mov    0x10(%ebp),%eax
80104ed0:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ed3:	89 55 10             	mov    %edx,0x10(%ebp)
80104ed6:	85 c0                	test   %eax,%eax
80104ed8:	75 e0                	jne    80104eba <memmove+0x39>
  if(s < d && s + n > d){
80104eda:	eb 24                	jmp    80104f00 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104edc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104edf:	8d 42 01             	lea    0x1(%edx),%eax
80104ee2:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104ee5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ee8:	8d 48 01             	lea    0x1(%eax),%ecx
80104eeb:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104eee:	0f b6 12             	movzbl (%edx),%edx
80104ef1:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ef3:	8b 45 10             	mov    0x10(%ebp),%eax
80104ef6:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ef9:	89 55 10             	mov    %edx,0x10(%ebp)
80104efc:	85 c0                	test   %eax,%eax
80104efe:	75 dc                	jne    80104edc <memmove+0x5b>

  return dst;
80104f00:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f03:	c9                   	leave  
80104f04:	c3                   	ret    

80104f05 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f05:	f3 0f 1e fb          	endbr32 
80104f09:	55                   	push   %ebp
80104f0a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f0c:	ff 75 10             	pushl  0x10(%ebp)
80104f0f:	ff 75 0c             	pushl  0xc(%ebp)
80104f12:	ff 75 08             	pushl  0x8(%ebp)
80104f15:	e8 67 ff ff ff       	call   80104e81 <memmove>
80104f1a:	83 c4 0c             	add    $0xc,%esp
}
80104f1d:	c9                   	leave  
80104f1e:	c3                   	ret    

80104f1f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f1f:	f3 0f 1e fb          	endbr32 
80104f23:	55                   	push   %ebp
80104f24:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104f26:	eb 0c                	jmp    80104f34 <strncmp+0x15>
    n--, p++, q++;
80104f28:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f2c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f30:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104f34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f38:	74 1a                	je     80104f54 <strncmp+0x35>
80104f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3d:	0f b6 00             	movzbl (%eax),%eax
80104f40:	84 c0                	test   %al,%al
80104f42:	74 10                	je     80104f54 <strncmp+0x35>
80104f44:	8b 45 08             	mov    0x8(%ebp),%eax
80104f47:	0f b6 10             	movzbl (%eax),%edx
80104f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f4d:	0f b6 00             	movzbl (%eax),%eax
80104f50:	38 c2                	cmp    %al,%dl
80104f52:	74 d4                	je     80104f28 <strncmp+0x9>
  if(n == 0)
80104f54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f58:	75 07                	jne    80104f61 <strncmp+0x42>
    return 0;
80104f5a:	b8 00 00 00 00       	mov    $0x0,%eax
80104f5f:	eb 16                	jmp    80104f77 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104f61:	8b 45 08             	mov    0x8(%ebp),%eax
80104f64:	0f b6 00             	movzbl (%eax),%eax
80104f67:	0f b6 d0             	movzbl %al,%edx
80104f6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f6d:	0f b6 00             	movzbl (%eax),%eax
80104f70:	0f b6 c0             	movzbl %al,%eax
80104f73:	29 c2                	sub    %eax,%edx
80104f75:	89 d0                	mov    %edx,%eax
}
80104f77:	5d                   	pop    %ebp
80104f78:	c3                   	ret    

80104f79 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f79:	f3 0f 1e fb          	endbr32 
80104f7d:	55                   	push   %ebp
80104f7e:	89 e5                	mov    %esp,%ebp
80104f80:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104f83:	8b 45 08             	mov    0x8(%ebp),%eax
80104f86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f89:	90                   	nop
80104f8a:	8b 45 10             	mov    0x10(%ebp),%eax
80104f8d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f90:	89 55 10             	mov    %edx,0x10(%ebp)
80104f93:	85 c0                	test   %eax,%eax
80104f95:	7e 2c                	jle    80104fc3 <strncpy+0x4a>
80104f97:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f9a:	8d 42 01             	lea    0x1(%edx),%eax
80104f9d:	89 45 0c             	mov    %eax,0xc(%ebp)
80104fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa3:	8d 48 01             	lea    0x1(%eax),%ecx
80104fa6:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104fa9:	0f b6 12             	movzbl (%edx),%edx
80104fac:	88 10                	mov    %dl,(%eax)
80104fae:	0f b6 00             	movzbl (%eax),%eax
80104fb1:	84 c0                	test   %al,%al
80104fb3:	75 d5                	jne    80104f8a <strncpy+0x11>
    ;
  while(n-- > 0)
80104fb5:	eb 0c                	jmp    80104fc3 <strncpy+0x4a>
    *s++ = 0;
80104fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80104fba:	8d 50 01             	lea    0x1(%eax),%edx
80104fbd:	89 55 08             	mov    %edx,0x8(%ebp)
80104fc0:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80104fc6:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fc9:	89 55 10             	mov    %edx,0x10(%ebp)
80104fcc:	85 c0                	test   %eax,%eax
80104fce:	7f e7                	jg     80104fb7 <strncpy+0x3e>
  return os;
80104fd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fd3:	c9                   	leave  
80104fd4:	c3                   	ret    

80104fd5 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104fd5:	f3 0f 1e fb          	endbr32 
80104fd9:	55                   	push   %ebp
80104fda:	89 e5                	mov    %esp,%ebp
80104fdc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104fdf:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104fe5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fe9:	7f 05                	jg     80104ff0 <safestrcpy+0x1b>
    return os;
80104feb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fee:	eb 31                	jmp    80105021 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80104ff0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ff4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ff8:	7e 1e                	jle    80105018 <safestrcpy+0x43>
80104ffa:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ffd:	8d 42 01             	lea    0x1(%edx),%eax
80105000:	89 45 0c             	mov    %eax,0xc(%ebp)
80105003:	8b 45 08             	mov    0x8(%ebp),%eax
80105006:	8d 48 01             	lea    0x1(%eax),%ecx
80105009:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010500c:	0f b6 12             	movzbl (%edx),%edx
8010500f:	88 10                	mov    %dl,(%eax)
80105011:	0f b6 00             	movzbl (%eax),%eax
80105014:	84 c0                	test   %al,%al
80105016:	75 d8                	jne    80104ff0 <safestrcpy+0x1b>
    ;
  *s = 0;
80105018:	8b 45 08             	mov    0x8(%ebp),%eax
8010501b:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010501e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105021:	c9                   	leave  
80105022:	c3                   	ret    

80105023 <strlen>:

int
strlen(const char *s)
{
80105023:	f3 0f 1e fb          	endbr32 
80105027:	55                   	push   %ebp
80105028:	89 e5                	mov    %esp,%ebp
8010502a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010502d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105034:	eb 04                	jmp    8010503a <strlen+0x17>
80105036:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010503a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010503d:	8b 45 08             	mov    0x8(%ebp),%eax
80105040:	01 d0                	add    %edx,%eax
80105042:	0f b6 00             	movzbl (%eax),%eax
80105045:	84 c0                	test   %al,%al
80105047:	75 ed                	jne    80105036 <strlen+0x13>
    ;
  return n;
80105049:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010504c:	c9                   	leave  
8010504d:	c3                   	ret    

8010504e <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010504e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105052:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105056:	55                   	push   %ebp
  pushl %ebx
80105057:	53                   	push   %ebx
  pushl %esi
80105058:	56                   	push   %esi
  pushl %edi
80105059:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010505a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010505c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010505e:	5f                   	pop    %edi
  popl %esi
8010505f:	5e                   	pop    %esi
  popl %ebx
80105060:	5b                   	pop    %ebx
  popl %ebp
80105061:	5d                   	pop    %ebp
  ret
80105062:	c3                   	ret    

80105063 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105063:	f3 0f 1e fb          	endbr32 
80105067:	55                   	push   %ebp
80105068:	89 e5                	mov    %esp,%ebp
8010506a:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010506d:	e8 37 eb ff ff       	call   80103ba9 <myproc>
80105072:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105078:	8b 00                	mov    (%eax),%eax
8010507a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010507d:	73 0f                	jae    8010508e <fetchint+0x2b>
8010507f:	8b 45 08             	mov    0x8(%ebp),%eax
80105082:	8d 50 04             	lea    0x4(%eax),%edx
80105085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105088:	8b 00                	mov    (%eax),%eax
8010508a:	39 c2                	cmp    %eax,%edx
8010508c:	76 07                	jbe    80105095 <fetchint+0x32>
    return -1;
8010508e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105093:	eb 0f                	jmp    801050a4 <fetchint+0x41>
  *ip = *(int*)(addr);
80105095:	8b 45 08             	mov    0x8(%ebp),%eax
80105098:	8b 10                	mov    (%eax),%edx
8010509a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010509d:	89 10                	mov    %edx,(%eax)
  return 0;
8010509f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801050a4:	c9                   	leave  
801050a5:	c3                   	ret    

801050a6 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801050a6:	f3 0f 1e fb          	endbr32 
801050aa:	55                   	push   %ebp
801050ab:	89 e5                	mov    %esp,%ebp
801050ad:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801050b0:	e8 f4 ea ff ff       	call   80103ba9 <myproc>
801050b5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801050b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050bb:	8b 00                	mov    (%eax),%eax
801050bd:	39 45 08             	cmp    %eax,0x8(%ebp)
801050c0:	72 07                	jb     801050c9 <fetchstr+0x23>
    return -1;
801050c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c7:	eb 43                	jmp    8010510c <fetchstr+0x66>
  *pp = (char*)addr;
801050c9:	8b 55 08             	mov    0x8(%ebp),%edx
801050cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801050cf:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801050d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d4:	8b 00                	mov    (%eax),%eax
801050d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801050d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801050dc:	8b 00                	mov    (%eax),%eax
801050de:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050e1:	eb 1c                	jmp    801050ff <fetchstr+0x59>
    if(*s == 0)
801050e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e6:	0f b6 00             	movzbl (%eax),%eax
801050e9:	84 c0                	test   %al,%al
801050eb:	75 0e                	jne    801050fb <fetchstr+0x55>
      return s - *pp;
801050ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801050f0:	8b 00                	mov    (%eax),%eax
801050f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050f5:	29 c2                	sub    %eax,%edx
801050f7:	89 d0                	mov    %edx,%eax
801050f9:	eb 11                	jmp    8010510c <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801050fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105102:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105105:	72 dc                	jb     801050e3 <fetchstr+0x3d>
  }
  return -1;
80105107:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010510c:	c9                   	leave  
8010510d:	c3                   	ret    

8010510e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010510e:	f3 0f 1e fb          	endbr32 
80105112:	55                   	push   %ebp
80105113:	89 e5                	mov    %esp,%ebp
80105115:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105118:	e8 8c ea ff ff       	call   80103ba9 <myproc>
8010511d:	8b 40 18             	mov    0x18(%eax),%eax
80105120:	8b 40 44             	mov    0x44(%eax),%eax
80105123:	8b 55 08             	mov    0x8(%ebp),%edx
80105126:	c1 e2 02             	shl    $0x2,%edx
80105129:	01 d0                	add    %edx,%eax
8010512b:	83 c0 04             	add    $0x4,%eax
8010512e:	83 ec 08             	sub    $0x8,%esp
80105131:	ff 75 0c             	pushl  0xc(%ebp)
80105134:	50                   	push   %eax
80105135:	e8 29 ff ff ff       	call   80105063 <fetchint>
8010513a:	83 c4 10             	add    $0x10,%esp
}
8010513d:	c9                   	leave  
8010513e:	c3                   	ret    

8010513f <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010513f:	f3 0f 1e fb          	endbr32 
80105143:	55                   	push   %ebp
80105144:	89 e5                	mov    %esp,%ebp
80105146:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105149:	e8 5b ea ff ff       	call   80103ba9 <myproc>
8010514e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105151:	83 ec 08             	sub    $0x8,%esp
80105154:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105157:	50                   	push   %eax
80105158:	ff 75 08             	pushl  0x8(%ebp)
8010515b:	e8 ae ff ff ff       	call   8010510e <argint>
80105160:	83 c4 10             	add    $0x10,%esp
80105163:	85 c0                	test   %eax,%eax
80105165:	79 07                	jns    8010516e <argptr+0x2f>
    return -1;
80105167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010516c:	eb 3b                	jmp    801051a9 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010516e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105172:	78 1f                	js     80105193 <argptr+0x54>
80105174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105177:	8b 00                	mov    (%eax),%eax
80105179:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010517c:	39 d0                	cmp    %edx,%eax
8010517e:	76 13                	jbe    80105193 <argptr+0x54>
80105180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105183:	89 c2                	mov    %eax,%edx
80105185:	8b 45 10             	mov    0x10(%ebp),%eax
80105188:	01 c2                	add    %eax,%edx
8010518a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518d:	8b 00                	mov    (%eax),%eax
8010518f:	39 c2                	cmp    %eax,%edx
80105191:	76 07                	jbe    8010519a <argptr+0x5b>
    return -1;
80105193:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105198:	eb 0f                	jmp    801051a9 <argptr+0x6a>
  *pp = (char*)i;
8010519a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010519d:	89 c2                	mov    %eax,%edx
8010519f:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a2:	89 10                	mov    %edx,(%eax)
  return 0;
801051a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051a9:	c9                   	leave  
801051aa:	c3                   	ret    

801051ab <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801051ab:	f3 0f 1e fb          	endbr32 
801051af:	55                   	push   %ebp
801051b0:	89 e5                	mov    %esp,%ebp
801051b2:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801051b5:	83 ec 08             	sub    $0x8,%esp
801051b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051bb:	50                   	push   %eax
801051bc:	ff 75 08             	pushl  0x8(%ebp)
801051bf:	e8 4a ff ff ff       	call   8010510e <argint>
801051c4:	83 c4 10             	add    $0x10,%esp
801051c7:	85 c0                	test   %eax,%eax
801051c9:	79 07                	jns    801051d2 <argstr+0x27>
    return -1;
801051cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051d0:	eb 12                	jmp    801051e4 <argstr+0x39>
  return fetchstr(addr, pp);
801051d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d5:	83 ec 08             	sub    $0x8,%esp
801051d8:	ff 75 0c             	pushl  0xc(%ebp)
801051db:	50                   	push   %eax
801051dc:	e8 c5 fe ff ff       	call   801050a6 <fetchstr>
801051e1:	83 c4 10             	add    $0x10,%esp
}
801051e4:	c9                   	leave  
801051e5:	c3                   	ret    

801051e6 <syscall>:
[SYS_exit2]   sys_exit2,
};

void
syscall(void)
{
801051e6:	f3 0f 1e fb          	endbr32 
801051ea:	55                   	push   %ebp
801051eb:	89 e5                	mov    %esp,%ebp
801051ed:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801051f0:	e8 b4 e9 ff ff       	call   80103ba9 <myproc>
801051f5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801051f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fb:	8b 40 18             	mov    0x18(%eax),%eax
801051fe:	8b 40 1c             	mov    0x1c(%eax),%eax
80105201:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105204:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105208:	7e 2f                	jle    80105239 <syscall+0x53>
8010520a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010520d:	83 f8 17             	cmp    $0x17,%eax
80105210:	77 27                	ja     80105239 <syscall+0x53>
80105212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105215:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010521c:	85 c0                	test   %eax,%eax
8010521e:	74 19                	je     80105239 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105220:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105223:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010522a:	ff d0                	call   *%eax
8010522c:	89 c2                	mov    %eax,%edx
8010522e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105231:	8b 40 18             	mov    0x18(%eax),%eax
80105234:	89 50 1c             	mov    %edx,0x1c(%eax)
80105237:	eb 2c                	jmp    80105265 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010523c:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010523f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105242:	8b 40 10             	mov    0x10(%eax),%eax
80105245:	ff 75 f0             	pushl  -0x10(%ebp)
80105248:	52                   	push   %edx
80105249:	50                   	push   %eax
8010524a:	68 d8 a9 10 80       	push   $0x8010a9d8
8010524f:	e8 b8 b1 ff ff       	call   8010040c <cprintf>
80105254:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105257:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525a:	8b 40 18             	mov    0x18(%eax),%eax
8010525d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105264:	90                   	nop
80105265:	90                   	nop
80105266:	c9                   	leave  
80105267:	c3                   	ret    

80105268 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105268:	f3 0f 1e fb          	endbr32 
8010526c:	55                   	push   %ebp
8010526d:	89 e5                	mov    %esp,%ebp
8010526f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105272:	83 ec 08             	sub    $0x8,%esp
80105275:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105278:	50                   	push   %eax
80105279:	ff 75 08             	pushl  0x8(%ebp)
8010527c:	e8 8d fe ff ff       	call   8010510e <argint>
80105281:	83 c4 10             	add    $0x10,%esp
80105284:	85 c0                	test   %eax,%eax
80105286:	79 07                	jns    8010528f <argfd+0x27>
    return -1;
80105288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010528d:	eb 4f                	jmp    801052de <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010528f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105292:	85 c0                	test   %eax,%eax
80105294:	78 20                	js     801052b6 <argfd+0x4e>
80105296:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105299:	83 f8 0f             	cmp    $0xf,%eax
8010529c:	7f 18                	jg     801052b6 <argfd+0x4e>
8010529e:	e8 06 e9 ff ff       	call   80103ba9 <myproc>
801052a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052a6:	83 c2 08             	add    $0x8,%edx
801052a9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052b4:	75 07                	jne    801052bd <argfd+0x55>
    return -1;
801052b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052bb:	eb 21                	jmp    801052de <argfd+0x76>
  if(pfd)
801052bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052c1:	74 08                	je     801052cb <argfd+0x63>
    *pfd = fd;
801052c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c9:	89 10                	mov    %edx,(%eax)
  if(pf)
801052cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052cf:	74 08                	je     801052d9 <argfd+0x71>
    *pf = f;
801052d1:	8b 45 10             	mov    0x10(%ebp),%eax
801052d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052d7:	89 10                	mov    %edx,(%eax)
  return 0;
801052d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052de:	c9                   	leave  
801052df:	c3                   	ret    

801052e0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801052e0:	f3 0f 1e fb          	endbr32 
801052e4:	55                   	push   %ebp
801052e5:	89 e5                	mov    %esp,%ebp
801052e7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801052ea:	e8 ba e8 ff ff       	call   80103ba9 <myproc>
801052ef:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801052f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052f9:	eb 2a                	jmp    80105325 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
801052fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105301:	83 c2 08             	add    $0x8,%edx
80105304:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105308:	85 c0                	test   %eax,%eax
8010530a:	75 15                	jne    80105321 <fdalloc+0x41>
      curproc->ofile[fd] = f;
8010530c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010530f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105312:	8d 4a 08             	lea    0x8(%edx),%ecx
80105315:	8b 55 08             	mov    0x8(%ebp),%edx
80105318:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010531c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010531f:	eb 0f                	jmp    80105330 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105321:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105325:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105329:	7e d0                	jle    801052fb <fdalloc+0x1b>
    }
  }
  return -1;
8010532b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105330:	c9                   	leave  
80105331:	c3                   	ret    

80105332 <sys_dup>:

int
sys_dup(void)
{
80105332:	f3 0f 1e fb          	endbr32 
80105336:	55                   	push   %ebp
80105337:	89 e5                	mov    %esp,%ebp
80105339:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010533c:	83 ec 04             	sub    $0x4,%esp
8010533f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105342:	50                   	push   %eax
80105343:	6a 00                	push   $0x0
80105345:	6a 00                	push   $0x0
80105347:	e8 1c ff ff ff       	call   80105268 <argfd>
8010534c:	83 c4 10             	add    $0x10,%esp
8010534f:	85 c0                	test   %eax,%eax
80105351:	79 07                	jns    8010535a <sys_dup+0x28>
    return -1;
80105353:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105358:	eb 31                	jmp    8010538b <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
8010535a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535d:	83 ec 0c             	sub    $0xc,%esp
80105360:	50                   	push   %eax
80105361:	e8 7a ff ff ff       	call   801052e0 <fdalloc>
80105366:	83 c4 10             	add    $0x10,%esp
80105369:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010536c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105370:	79 07                	jns    80105379 <sys_dup+0x47>
    return -1;
80105372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105377:	eb 12                	jmp    8010538b <sys_dup+0x59>
  filedup(f);
80105379:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010537c:	83 ec 0c             	sub    $0xc,%esp
8010537f:	50                   	push   %eax
80105380:	e8 0f bd ff ff       	call   80101094 <filedup>
80105385:	83 c4 10             	add    $0x10,%esp
  return fd;
80105388:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010538b:	c9                   	leave  
8010538c:	c3                   	ret    

8010538d <sys_read>:

int
sys_read(void)
{
8010538d:	f3 0f 1e fb          	endbr32 
80105391:	55                   	push   %ebp
80105392:	89 e5                	mov    %esp,%ebp
80105394:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105397:	83 ec 04             	sub    $0x4,%esp
8010539a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010539d:	50                   	push   %eax
8010539e:	6a 00                	push   $0x0
801053a0:	6a 00                	push   $0x0
801053a2:	e8 c1 fe ff ff       	call   80105268 <argfd>
801053a7:	83 c4 10             	add    $0x10,%esp
801053aa:	85 c0                	test   %eax,%eax
801053ac:	78 2e                	js     801053dc <sys_read+0x4f>
801053ae:	83 ec 08             	sub    $0x8,%esp
801053b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053b4:	50                   	push   %eax
801053b5:	6a 02                	push   $0x2
801053b7:	e8 52 fd ff ff       	call   8010510e <argint>
801053bc:	83 c4 10             	add    $0x10,%esp
801053bf:	85 c0                	test   %eax,%eax
801053c1:	78 19                	js     801053dc <sys_read+0x4f>
801053c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c6:	83 ec 04             	sub    $0x4,%esp
801053c9:	50                   	push   %eax
801053ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053cd:	50                   	push   %eax
801053ce:	6a 01                	push   $0x1
801053d0:	e8 6a fd ff ff       	call   8010513f <argptr>
801053d5:	83 c4 10             	add    $0x10,%esp
801053d8:	85 c0                	test   %eax,%eax
801053da:	79 07                	jns    801053e3 <sys_read+0x56>
    return -1;
801053dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e1:	eb 17                	jmp    801053fa <sys_read+0x6d>
  return fileread(f, p, n);
801053e3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ec:	83 ec 04             	sub    $0x4,%esp
801053ef:	51                   	push   %ecx
801053f0:	52                   	push   %edx
801053f1:	50                   	push   %eax
801053f2:	e8 39 be ff ff       	call   80101230 <fileread>
801053f7:	83 c4 10             	add    $0x10,%esp
}
801053fa:	c9                   	leave  
801053fb:	c3                   	ret    

801053fc <sys_write>:

int
sys_write(void)
{
801053fc:	f3 0f 1e fb          	endbr32 
80105400:	55                   	push   %ebp
80105401:	89 e5                	mov    %esp,%ebp
80105403:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105406:	83 ec 04             	sub    $0x4,%esp
80105409:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010540c:	50                   	push   %eax
8010540d:	6a 00                	push   $0x0
8010540f:	6a 00                	push   $0x0
80105411:	e8 52 fe ff ff       	call   80105268 <argfd>
80105416:	83 c4 10             	add    $0x10,%esp
80105419:	85 c0                	test   %eax,%eax
8010541b:	78 2e                	js     8010544b <sys_write+0x4f>
8010541d:	83 ec 08             	sub    $0x8,%esp
80105420:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105423:	50                   	push   %eax
80105424:	6a 02                	push   $0x2
80105426:	e8 e3 fc ff ff       	call   8010510e <argint>
8010542b:	83 c4 10             	add    $0x10,%esp
8010542e:	85 c0                	test   %eax,%eax
80105430:	78 19                	js     8010544b <sys_write+0x4f>
80105432:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105435:	83 ec 04             	sub    $0x4,%esp
80105438:	50                   	push   %eax
80105439:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010543c:	50                   	push   %eax
8010543d:	6a 01                	push   $0x1
8010543f:	e8 fb fc ff ff       	call   8010513f <argptr>
80105444:	83 c4 10             	add    $0x10,%esp
80105447:	85 c0                	test   %eax,%eax
80105449:	79 07                	jns    80105452 <sys_write+0x56>
    return -1;
8010544b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105450:	eb 17                	jmp    80105469 <sys_write+0x6d>
  return filewrite(f, p, n);
80105452:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105455:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010545b:	83 ec 04             	sub    $0x4,%esp
8010545e:	51                   	push   %ecx
8010545f:	52                   	push   %edx
80105460:	50                   	push   %eax
80105461:	e8 86 be ff ff       	call   801012ec <filewrite>
80105466:	83 c4 10             	add    $0x10,%esp
}
80105469:	c9                   	leave  
8010546a:	c3                   	ret    

8010546b <sys_close>:

int
sys_close(void)
{
8010546b:	f3 0f 1e fb          	endbr32 
8010546f:	55                   	push   %ebp
80105470:	89 e5                	mov    %esp,%ebp
80105472:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105475:	83 ec 04             	sub    $0x4,%esp
80105478:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010547b:	50                   	push   %eax
8010547c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010547f:	50                   	push   %eax
80105480:	6a 00                	push   $0x0
80105482:	e8 e1 fd ff ff       	call   80105268 <argfd>
80105487:	83 c4 10             	add    $0x10,%esp
8010548a:	85 c0                	test   %eax,%eax
8010548c:	79 07                	jns    80105495 <sys_close+0x2a>
    return -1;
8010548e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105493:	eb 27                	jmp    801054bc <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105495:	e8 0f e7 ff ff       	call   80103ba9 <myproc>
8010549a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010549d:	83 c2 08             	add    $0x8,%edx
801054a0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054a7:	00 
  fileclose(f);
801054a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ab:	83 ec 0c             	sub    $0xc,%esp
801054ae:	50                   	push   %eax
801054af:	e8 35 bc ff ff       	call   801010e9 <fileclose>
801054b4:	83 c4 10             	add    $0x10,%esp
  return 0;
801054b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054bc:	c9                   	leave  
801054bd:	c3                   	ret    

801054be <sys_fstat>:

int
sys_fstat(void)
{
801054be:	f3 0f 1e fb          	endbr32 
801054c2:	55                   	push   %ebp
801054c3:	89 e5                	mov    %esp,%ebp
801054c5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054c8:	83 ec 04             	sub    $0x4,%esp
801054cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054ce:	50                   	push   %eax
801054cf:	6a 00                	push   $0x0
801054d1:	6a 00                	push   $0x0
801054d3:	e8 90 fd ff ff       	call   80105268 <argfd>
801054d8:	83 c4 10             	add    $0x10,%esp
801054db:	85 c0                	test   %eax,%eax
801054dd:	78 17                	js     801054f6 <sys_fstat+0x38>
801054df:	83 ec 04             	sub    $0x4,%esp
801054e2:	6a 14                	push   $0x14
801054e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054e7:	50                   	push   %eax
801054e8:	6a 01                	push   $0x1
801054ea:	e8 50 fc ff ff       	call   8010513f <argptr>
801054ef:	83 c4 10             	add    $0x10,%esp
801054f2:	85 c0                	test   %eax,%eax
801054f4:	79 07                	jns    801054fd <sys_fstat+0x3f>
    return -1;
801054f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054fb:	eb 13                	jmp    80105510 <sys_fstat+0x52>
  return filestat(f, st);
801054fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105503:	83 ec 08             	sub    $0x8,%esp
80105506:	52                   	push   %edx
80105507:	50                   	push   %eax
80105508:	e8 c8 bc ff ff       	call   801011d5 <filestat>
8010550d:	83 c4 10             	add    $0x10,%esp
}
80105510:	c9                   	leave  
80105511:	c3                   	ret    

80105512 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105512:	f3 0f 1e fb          	endbr32 
80105516:	55                   	push   %ebp
80105517:	89 e5                	mov    %esp,%ebp
80105519:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010551c:	83 ec 08             	sub    $0x8,%esp
8010551f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105522:	50                   	push   %eax
80105523:	6a 00                	push   $0x0
80105525:	e8 81 fc ff ff       	call   801051ab <argstr>
8010552a:	83 c4 10             	add    $0x10,%esp
8010552d:	85 c0                	test   %eax,%eax
8010552f:	78 15                	js     80105546 <sys_link+0x34>
80105531:	83 ec 08             	sub    $0x8,%esp
80105534:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105537:	50                   	push   %eax
80105538:	6a 01                	push   $0x1
8010553a:	e8 6c fc ff ff       	call   801051ab <argstr>
8010553f:	83 c4 10             	add    $0x10,%esp
80105542:	85 c0                	test   %eax,%eax
80105544:	79 0a                	jns    80105550 <sys_link+0x3e>
    return -1;
80105546:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554b:	e9 68 01 00 00       	jmp    801056b8 <sys_link+0x1a6>

  begin_op();
80105550:	e8 1c dc ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
80105555:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105558:	83 ec 0c             	sub    $0xc,%esp
8010555b:	50                   	push   %eax
8010555c:	e8 86 d0 ff ff       	call   801025e7 <namei>
80105561:	83 c4 10             	add    $0x10,%esp
80105564:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105567:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010556b:	75 0f                	jne    8010557c <sys_link+0x6a>
    end_op();
8010556d:	e8 8f dc ff ff       	call   80103201 <end_op>
    return -1;
80105572:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105577:	e9 3c 01 00 00       	jmp    801056b8 <sys_link+0x1a6>
  }

  ilock(ip);
8010557c:	83 ec 0c             	sub    $0xc,%esp
8010557f:	ff 75 f4             	pushl  -0xc(%ebp)
80105582:	e8 f5 c4 ff ff       	call   80101a7c <ilock>
80105587:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010558a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010558d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105591:	66 83 f8 01          	cmp    $0x1,%ax
80105595:	75 1d                	jne    801055b4 <sys_link+0xa2>
    iunlockput(ip);
80105597:	83 ec 0c             	sub    $0xc,%esp
8010559a:	ff 75 f4             	pushl  -0xc(%ebp)
8010559d:	e8 17 c7 ff ff       	call   80101cb9 <iunlockput>
801055a2:	83 c4 10             	add    $0x10,%esp
    end_op();
801055a5:	e8 57 dc ff ff       	call   80103201 <end_op>
    return -1;
801055aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055af:	e9 04 01 00 00       	jmp    801056b8 <sys_link+0x1a6>
  }

  ip->nlink++;
801055b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055bb:	83 c0 01             	add    $0x1,%eax
801055be:	89 c2                	mov    %eax,%edx
801055c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c3:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801055c7:	83 ec 0c             	sub    $0xc,%esp
801055ca:	ff 75 f4             	pushl  -0xc(%ebp)
801055cd:	e8 c1 c2 ff ff       	call   80101893 <iupdate>
801055d2:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801055d5:	83 ec 0c             	sub    $0xc,%esp
801055d8:	ff 75 f4             	pushl  -0xc(%ebp)
801055db:	e8 b3 c5 ff ff       	call   80101b93 <iunlock>
801055e0:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801055e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055e6:	83 ec 08             	sub    $0x8,%esp
801055e9:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055ec:	52                   	push   %edx
801055ed:	50                   	push   %eax
801055ee:	e8 14 d0 ff ff       	call   80102607 <nameiparent>
801055f3:	83 c4 10             	add    $0x10,%esp
801055f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055fd:	74 71                	je     80105670 <sys_link+0x15e>
    goto bad;
  ilock(dp);
801055ff:	83 ec 0c             	sub    $0xc,%esp
80105602:	ff 75 f0             	pushl  -0x10(%ebp)
80105605:	e8 72 c4 ff ff       	call   80101a7c <ilock>
8010560a:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010560d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105610:	8b 10                	mov    (%eax),%edx
80105612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105615:	8b 00                	mov    (%eax),%eax
80105617:	39 c2                	cmp    %eax,%edx
80105619:	75 1d                	jne    80105638 <sys_link+0x126>
8010561b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010561e:	8b 40 04             	mov    0x4(%eax),%eax
80105621:	83 ec 04             	sub    $0x4,%esp
80105624:	50                   	push   %eax
80105625:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105628:	50                   	push   %eax
80105629:	ff 75 f0             	pushl  -0x10(%ebp)
8010562c:	e8 13 cd ff ff       	call   80102344 <dirlink>
80105631:	83 c4 10             	add    $0x10,%esp
80105634:	85 c0                	test   %eax,%eax
80105636:	79 10                	jns    80105648 <sys_link+0x136>
    iunlockput(dp);
80105638:	83 ec 0c             	sub    $0xc,%esp
8010563b:	ff 75 f0             	pushl  -0x10(%ebp)
8010563e:	e8 76 c6 ff ff       	call   80101cb9 <iunlockput>
80105643:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105646:	eb 29                	jmp    80105671 <sys_link+0x15f>
  }
  iunlockput(dp);
80105648:	83 ec 0c             	sub    $0xc,%esp
8010564b:	ff 75 f0             	pushl  -0x10(%ebp)
8010564e:	e8 66 c6 ff ff       	call   80101cb9 <iunlockput>
80105653:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105656:	83 ec 0c             	sub    $0xc,%esp
80105659:	ff 75 f4             	pushl  -0xc(%ebp)
8010565c:	e8 84 c5 ff ff       	call   80101be5 <iput>
80105661:	83 c4 10             	add    $0x10,%esp

  end_op();
80105664:	e8 98 db ff ff       	call   80103201 <end_op>

  return 0;
80105669:	b8 00 00 00 00       	mov    $0x0,%eax
8010566e:	eb 48                	jmp    801056b8 <sys_link+0x1a6>
    goto bad;
80105670:	90                   	nop

bad:
  ilock(ip);
80105671:	83 ec 0c             	sub    $0xc,%esp
80105674:	ff 75 f4             	pushl  -0xc(%ebp)
80105677:	e8 00 c4 ff ff       	call   80101a7c <ilock>
8010567c:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010567f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105682:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105686:	83 e8 01             	sub    $0x1,%eax
80105689:	89 c2                	mov    %eax,%edx
8010568b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105692:	83 ec 0c             	sub    $0xc,%esp
80105695:	ff 75 f4             	pushl  -0xc(%ebp)
80105698:	e8 f6 c1 ff ff       	call   80101893 <iupdate>
8010569d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801056a0:	83 ec 0c             	sub    $0xc,%esp
801056a3:	ff 75 f4             	pushl  -0xc(%ebp)
801056a6:	e8 0e c6 ff ff       	call   80101cb9 <iunlockput>
801056ab:	83 c4 10             	add    $0x10,%esp
  end_op();
801056ae:	e8 4e db ff ff       	call   80103201 <end_op>
  return -1;
801056b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056b8:	c9                   	leave  
801056b9:	c3                   	ret    

801056ba <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801056ba:	f3 0f 1e fb          	endbr32 
801056be:	55                   	push   %ebp
801056bf:	89 e5                	mov    %esp,%ebp
801056c1:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056c4:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801056cb:	eb 40                	jmp    8010570d <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d0:	6a 10                	push   $0x10
801056d2:	50                   	push   %eax
801056d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801056d6:	50                   	push   %eax
801056d7:	ff 75 08             	pushl  0x8(%ebp)
801056da:	e8 a5 c8 ff ff       	call   80101f84 <readi>
801056df:	83 c4 10             	add    $0x10,%esp
801056e2:	83 f8 10             	cmp    $0x10,%eax
801056e5:	74 0d                	je     801056f4 <isdirempty+0x3a>
      panic("isdirempty: readi");
801056e7:	83 ec 0c             	sub    $0xc,%esp
801056ea:	68 f4 a9 10 80       	push   $0x8010a9f4
801056ef:	e8 d1 ae ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
801056f4:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801056f8:	66 85 c0             	test   %ax,%ax
801056fb:	74 07                	je     80105704 <isdirempty+0x4a>
      return 0;
801056fd:	b8 00 00 00 00       	mov    $0x0,%eax
80105702:	eb 1b                	jmp    8010571f <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105707:	83 c0 10             	add    $0x10,%eax
8010570a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010570d:	8b 45 08             	mov    0x8(%ebp),%eax
80105710:	8b 50 58             	mov    0x58(%eax),%edx
80105713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105716:	39 c2                	cmp    %eax,%edx
80105718:	77 b3                	ja     801056cd <isdirempty+0x13>
  }
  return 1;
8010571a:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010571f:	c9                   	leave  
80105720:	c3                   	ret    

80105721 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105721:	f3 0f 1e fb          	endbr32 
80105725:	55                   	push   %ebp
80105726:	89 e5                	mov    %esp,%ebp
80105728:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010572b:	83 ec 08             	sub    $0x8,%esp
8010572e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105731:	50                   	push   %eax
80105732:	6a 00                	push   $0x0
80105734:	e8 72 fa ff ff       	call   801051ab <argstr>
80105739:	83 c4 10             	add    $0x10,%esp
8010573c:	85 c0                	test   %eax,%eax
8010573e:	79 0a                	jns    8010574a <sys_unlink+0x29>
    return -1;
80105740:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105745:	e9 bf 01 00 00       	jmp    80105909 <sys_unlink+0x1e8>

  begin_op();
8010574a:	e8 22 da ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010574f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105752:	83 ec 08             	sub    $0x8,%esp
80105755:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105758:	52                   	push   %edx
80105759:	50                   	push   %eax
8010575a:	e8 a8 ce ff ff       	call   80102607 <nameiparent>
8010575f:	83 c4 10             	add    $0x10,%esp
80105762:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105765:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105769:	75 0f                	jne    8010577a <sys_unlink+0x59>
    end_op();
8010576b:	e8 91 da ff ff       	call   80103201 <end_op>
    return -1;
80105770:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105775:	e9 8f 01 00 00       	jmp    80105909 <sys_unlink+0x1e8>
  }

  ilock(dp);
8010577a:	83 ec 0c             	sub    $0xc,%esp
8010577d:	ff 75 f4             	pushl  -0xc(%ebp)
80105780:	e8 f7 c2 ff ff       	call   80101a7c <ilock>
80105785:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105788:	83 ec 08             	sub    $0x8,%esp
8010578b:	68 06 aa 10 80       	push   $0x8010aa06
80105790:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105793:	50                   	push   %eax
80105794:	e8 ce ca ff ff       	call   80102267 <namecmp>
80105799:	83 c4 10             	add    $0x10,%esp
8010579c:	85 c0                	test   %eax,%eax
8010579e:	0f 84 49 01 00 00    	je     801058ed <sys_unlink+0x1cc>
801057a4:	83 ec 08             	sub    $0x8,%esp
801057a7:	68 08 aa 10 80       	push   $0x8010aa08
801057ac:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057af:	50                   	push   %eax
801057b0:	e8 b2 ca ff ff       	call   80102267 <namecmp>
801057b5:	83 c4 10             	add    $0x10,%esp
801057b8:	85 c0                	test   %eax,%eax
801057ba:	0f 84 2d 01 00 00    	je     801058ed <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801057c0:	83 ec 04             	sub    $0x4,%esp
801057c3:	8d 45 c8             	lea    -0x38(%ebp),%eax
801057c6:	50                   	push   %eax
801057c7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057ca:	50                   	push   %eax
801057cb:	ff 75 f4             	pushl  -0xc(%ebp)
801057ce:	e8 b3 ca ff ff       	call   80102286 <dirlookup>
801057d3:	83 c4 10             	add    $0x10,%esp
801057d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057dd:	0f 84 0d 01 00 00    	je     801058f0 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
801057e3:	83 ec 0c             	sub    $0xc,%esp
801057e6:	ff 75 f0             	pushl  -0x10(%ebp)
801057e9:	e8 8e c2 ff ff       	call   80101a7c <ilock>
801057ee:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801057f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057f8:	66 85 c0             	test   %ax,%ax
801057fb:	7f 0d                	jg     8010580a <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
801057fd:	83 ec 0c             	sub    $0xc,%esp
80105800:	68 0b aa 10 80       	push   $0x8010aa0b
80105805:	e8 bb ad ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010580a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105811:	66 83 f8 01          	cmp    $0x1,%ax
80105815:	75 25                	jne    8010583c <sys_unlink+0x11b>
80105817:	83 ec 0c             	sub    $0xc,%esp
8010581a:	ff 75 f0             	pushl  -0x10(%ebp)
8010581d:	e8 98 fe ff ff       	call   801056ba <isdirempty>
80105822:	83 c4 10             	add    $0x10,%esp
80105825:	85 c0                	test   %eax,%eax
80105827:	75 13                	jne    8010583c <sys_unlink+0x11b>
    iunlockput(ip);
80105829:	83 ec 0c             	sub    $0xc,%esp
8010582c:	ff 75 f0             	pushl  -0x10(%ebp)
8010582f:	e8 85 c4 ff ff       	call   80101cb9 <iunlockput>
80105834:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105837:	e9 b5 00 00 00       	jmp    801058f1 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
8010583c:	83 ec 04             	sub    $0x4,%esp
8010583f:	6a 10                	push   $0x10
80105841:	6a 00                	push   $0x0
80105843:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105846:	50                   	push   %eax
80105847:	e8 6e f5 ff ff       	call   80104dba <memset>
8010584c:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010584f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105852:	6a 10                	push   $0x10
80105854:	50                   	push   %eax
80105855:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105858:	50                   	push   %eax
80105859:	ff 75 f4             	pushl  -0xc(%ebp)
8010585c:	e8 7c c8 ff ff       	call   801020dd <writei>
80105861:	83 c4 10             	add    $0x10,%esp
80105864:	83 f8 10             	cmp    $0x10,%eax
80105867:	74 0d                	je     80105876 <sys_unlink+0x155>
    panic("unlink: writei");
80105869:	83 ec 0c             	sub    $0xc,%esp
8010586c:	68 1d aa 10 80       	push   $0x8010aa1d
80105871:	e8 4f ad ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105876:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105879:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010587d:	66 83 f8 01          	cmp    $0x1,%ax
80105881:	75 21                	jne    801058a4 <sys_unlink+0x183>
    dp->nlink--;
80105883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105886:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010588a:	83 e8 01             	sub    $0x1,%eax
8010588d:	89 c2                	mov    %eax,%edx
8010588f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105892:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105896:	83 ec 0c             	sub    $0xc,%esp
80105899:	ff 75 f4             	pushl  -0xc(%ebp)
8010589c:	e8 f2 bf ff ff       	call   80101893 <iupdate>
801058a1:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801058a4:	83 ec 0c             	sub    $0xc,%esp
801058a7:	ff 75 f4             	pushl  -0xc(%ebp)
801058aa:	e8 0a c4 ff ff       	call   80101cb9 <iunlockput>
801058af:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801058b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058b9:	83 e8 01             	sub    $0x1,%eax
801058bc:	89 c2                	mov    %eax,%edx
801058be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c1:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801058c5:	83 ec 0c             	sub    $0xc,%esp
801058c8:	ff 75 f0             	pushl  -0x10(%ebp)
801058cb:	e8 c3 bf ff ff       	call   80101893 <iupdate>
801058d0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801058d3:	83 ec 0c             	sub    $0xc,%esp
801058d6:	ff 75 f0             	pushl  -0x10(%ebp)
801058d9:	e8 db c3 ff ff       	call   80101cb9 <iunlockput>
801058de:	83 c4 10             	add    $0x10,%esp

  end_op();
801058e1:	e8 1b d9 ff ff       	call   80103201 <end_op>

  return 0;
801058e6:	b8 00 00 00 00       	mov    $0x0,%eax
801058eb:	eb 1c                	jmp    80105909 <sys_unlink+0x1e8>
    goto bad;
801058ed:	90                   	nop
801058ee:	eb 01                	jmp    801058f1 <sys_unlink+0x1d0>
    goto bad;
801058f0:	90                   	nop

bad:
  iunlockput(dp);
801058f1:	83 ec 0c             	sub    $0xc,%esp
801058f4:	ff 75 f4             	pushl  -0xc(%ebp)
801058f7:	e8 bd c3 ff ff       	call   80101cb9 <iunlockput>
801058fc:	83 c4 10             	add    $0x10,%esp
  end_op();
801058ff:	e8 fd d8 ff ff       	call   80103201 <end_op>
  return -1;
80105904:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105909:	c9                   	leave  
8010590a:	c3                   	ret    

8010590b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010590b:	f3 0f 1e fb          	endbr32 
8010590f:	55                   	push   %ebp
80105910:	89 e5                	mov    %esp,%ebp
80105912:	83 ec 38             	sub    $0x38,%esp
80105915:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105918:	8b 55 10             	mov    0x10(%ebp),%edx
8010591b:	8b 45 14             	mov    0x14(%ebp),%eax
8010591e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105922:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105926:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010592a:	83 ec 08             	sub    $0x8,%esp
8010592d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105930:	50                   	push   %eax
80105931:	ff 75 08             	pushl  0x8(%ebp)
80105934:	e8 ce cc ff ff       	call   80102607 <nameiparent>
80105939:	83 c4 10             	add    $0x10,%esp
8010593c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010593f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105943:	75 0a                	jne    8010594f <create+0x44>
    return 0;
80105945:	b8 00 00 00 00       	mov    $0x0,%eax
8010594a:	e9 90 01 00 00       	jmp    80105adf <create+0x1d4>
  ilock(dp);
8010594f:	83 ec 0c             	sub    $0xc,%esp
80105952:	ff 75 f4             	pushl  -0xc(%ebp)
80105955:	e8 22 c1 ff ff       	call   80101a7c <ilock>
8010595a:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010595d:	83 ec 04             	sub    $0x4,%esp
80105960:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105963:	50                   	push   %eax
80105964:	8d 45 de             	lea    -0x22(%ebp),%eax
80105967:	50                   	push   %eax
80105968:	ff 75 f4             	pushl  -0xc(%ebp)
8010596b:	e8 16 c9 ff ff       	call   80102286 <dirlookup>
80105970:	83 c4 10             	add    $0x10,%esp
80105973:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105976:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010597a:	74 50                	je     801059cc <create+0xc1>
    iunlockput(dp);
8010597c:	83 ec 0c             	sub    $0xc,%esp
8010597f:	ff 75 f4             	pushl  -0xc(%ebp)
80105982:	e8 32 c3 ff ff       	call   80101cb9 <iunlockput>
80105987:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010598a:	83 ec 0c             	sub    $0xc,%esp
8010598d:	ff 75 f0             	pushl  -0x10(%ebp)
80105990:	e8 e7 c0 ff ff       	call   80101a7c <ilock>
80105995:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105998:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010599d:	75 15                	jne    801059b4 <create+0xa9>
8010599f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059a6:	66 83 f8 02          	cmp    $0x2,%ax
801059aa:	75 08                	jne    801059b4 <create+0xa9>
      return ip;
801059ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059af:	e9 2b 01 00 00       	jmp    80105adf <create+0x1d4>
    iunlockput(ip);
801059b4:	83 ec 0c             	sub    $0xc,%esp
801059b7:	ff 75 f0             	pushl  -0x10(%ebp)
801059ba:	e8 fa c2 ff ff       	call   80101cb9 <iunlockput>
801059bf:	83 c4 10             	add    $0x10,%esp
    return 0;
801059c2:	b8 00 00 00 00       	mov    $0x0,%eax
801059c7:	e9 13 01 00 00       	jmp    80105adf <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801059cc:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801059d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d3:	8b 00                	mov    (%eax),%eax
801059d5:	83 ec 08             	sub    $0x8,%esp
801059d8:	52                   	push   %edx
801059d9:	50                   	push   %eax
801059da:	e8 d9 bd ff ff       	call   801017b8 <ialloc>
801059df:	83 c4 10             	add    $0x10,%esp
801059e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059e9:	75 0d                	jne    801059f8 <create+0xed>
    panic("create: ialloc");
801059eb:	83 ec 0c             	sub    $0xc,%esp
801059ee:	68 2c aa 10 80       	push   $0x8010aa2c
801059f3:	e8 cd ab ff ff       	call   801005c5 <panic>

  ilock(ip);
801059f8:	83 ec 0c             	sub    $0xc,%esp
801059fb:	ff 75 f0             	pushl  -0x10(%ebp)
801059fe:	e8 79 c0 ff ff       	call   80101a7c <ilock>
80105a03:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a09:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a0d:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a14:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a18:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a1f:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a25:	83 ec 0c             	sub    $0xc,%esp
80105a28:	ff 75 f0             	pushl  -0x10(%ebp)
80105a2b:	e8 63 be ff ff       	call   80101893 <iupdate>
80105a30:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a33:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a38:	75 6a                	jne    80105aa4 <create+0x199>
    dp->nlink++;  // for ".."
80105a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a41:	83 c0 01             	add    $0x1,%eax
80105a44:	89 c2                	mov    %eax,%edx
80105a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a49:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a4d:	83 ec 0c             	sub    $0xc,%esp
80105a50:	ff 75 f4             	pushl  -0xc(%ebp)
80105a53:	e8 3b be ff ff       	call   80101893 <iupdate>
80105a58:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5e:	8b 40 04             	mov    0x4(%eax),%eax
80105a61:	83 ec 04             	sub    $0x4,%esp
80105a64:	50                   	push   %eax
80105a65:	68 06 aa 10 80       	push   $0x8010aa06
80105a6a:	ff 75 f0             	pushl  -0x10(%ebp)
80105a6d:	e8 d2 c8 ff ff       	call   80102344 <dirlink>
80105a72:	83 c4 10             	add    $0x10,%esp
80105a75:	85 c0                	test   %eax,%eax
80105a77:	78 1e                	js     80105a97 <create+0x18c>
80105a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7c:	8b 40 04             	mov    0x4(%eax),%eax
80105a7f:	83 ec 04             	sub    $0x4,%esp
80105a82:	50                   	push   %eax
80105a83:	68 08 aa 10 80       	push   $0x8010aa08
80105a88:	ff 75 f0             	pushl  -0x10(%ebp)
80105a8b:	e8 b4 c8 ff ff       	call   80102344 <dirlink>
80105a90:	83 c4 10             	add    $0x10,%esp
80105a93:	85 c0                	test   %eax,%eax
80105a95:	79 0d                	jns    80105aa4 <create+0x199>
      panic("create dots");
80105a97:	83 ec 0c             	sub    $0xc,%esp
80105a9a:	68 3b aa 10 80       	push   $0x8010aa3b
80105a9f:	e8 21 ab ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa7:	8b 40 04             	mov    0x4(%eax),%eax
80105aaa:	83 ec 04             	sub    $0x4,%esp
80105aad:	50                   	push   %eax
80105aae:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ab1:	50                   	push   %eax
80105ab2:	ff 75 f4             	pushl  -0xc(%ebp)
80105ab5:	e8 8a c8 ff ff       	call   80102344 <dirlink>
80105aba:	83 c4 10             	add    $0x10,%esp
80105abd:	85 c0                	test   %eax,%eax
80105abf:	79 0d                	jns    80105ace <create+0x1c3>
    panic("create: dirlink");
80105ac1:	83 ec 0c             	sub    $0xc,%esp
80105ac4:	68 47 aa 10 80       	push   $0x8010aa47
80105ac9:	e8 f7 aa ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105ace:	83 ec 0c             	sub    $0xc,%esp
80105ad1:	ff 75 f4             	pushl  -0xc(%ebp)
80105ad4:	e8 e0 c1 ff ff       	call   80101cb9 <iunlockput>
80105ad9:	83 c4 10             	add    $0x10,%esp

  return ip;
80105adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105adf:	c9                   	leave  
80105ae0:	c3                   	ret    

80105ae1 <sys_open>:

int
sys_open(void)
{
80105ae1:	f3 0f 1e fb          	endbr32 
80105ae5:	55                   	push   %ebp
80105ae6:	89 e5                	mov    %esp,%ebp
80105ae8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105aeb:	83 ec 08             	sub    $0x8,%esp
80105aee:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105af1:	50                   	push   %eax
80105af2:	6a 00                	push   $0x0
80105af4:	e8 b2 f6 ff ff       	call   801051ab <argstr>
80105af9:	83 c4 10             	add    $0x10,%esp
80105afc:	85 c0                	test   %eax,%eax
80105afe:	78 15                	js     80105b15 <sys_open+0x34>
80105b00:	83 ec 08             	sub    $0x8,%esp
80105b03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b06:	50                   	push   %eax
80105b07:	6a 01                	push   $0x1
80105b09:	e8 00 f6 ff ff       	call   8010510e <argint>
80105b0e:	83 c4 10             	add    $0x10,%esp
80105b11:	85 c0                	test   %eax,%eax
80105b13:	79 0a                	jns    80105b1f <sys_open+0x3e>
    return -1;
80105b15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1a:	e9 61 01 00 00       	jmp    80105c80 <sys_open+0x19f>

  begin_op();
80105b1f:	e8 4d d6 ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
80105b24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b27:	25 00 02 00 00       	and    $0x200,%eax
80105b2c:	85 c0                	test   %eax,%eax
80105b2e:	74 2a                	je     80105b5a <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105b30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b33:	6a 00                	push   $0x0
80105b35:	6a 00                	push   $0x0
80105b37:	6a 02                	push   $0x2
80105b39:	50                   	push   %eax
80105b3a:	e8 cc fd ff ff       	call   8010590b <create>
80105b3f:	83 c4 10             	add    $0x10,%esp
80105b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b49:	75 75                	jne    80105bc0 <sys_open+0xdf>
      end_op();
80105b4b:	e8 b1 d6 ff ff       	call   80103201 <end_op>
      return -1;
80105b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b55:	e9 26 01 00 00       	jmp    80105c80 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b5d:	83 ec 0c             	sub    $0xc,%esp
80105b60:	50                   	push   %eax
80105b61:	e8 81 ca ff ff       	call   801025e7 <namei>
80105b66:	83 c4 10             	add    $0x10,%esp
80105b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b70:	75 0f                	jne    80105b81 <sys_open+0xa0>
      end_op();
80105b72:	e8 8a d6 ff ff       	call   80103201 <end_op>
      return -1;
80105b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7c:	e9 ff 00 00 00       	jmp    80105c80 <sys_open+0x19f>
    }
    ilock(ip);
80105b81:	83 ec 0c             	sub    $0xc,%esp
80105b84:	ff 75 f4             	pushl  -0xc(%ebp)
80105b87:	e8 f0 be ff ff       	call   80101a7c <ilock>
80105b8c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b92:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b96:	66 83 f8 01          	cmp    $0x1,%ax
80105b9a:	75 24                	jne    80105bc0 <sys_open+0xdf>
80105b9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b9f:	85 c0                	test   %eax,%eax
80105ba1:	74 1d                	je     80105bc0 <sys_open+0xdf>
      iunlockput(ip);
80105ba3:	83 ec 0c             	sub    $0xc,%esp
80105ba6:	ff 75 f4             	pushl  -0xc(%ebp)
80105ba9:	e8 0b c1 ff ff       	call   80101cb9 <iunlockput>
80105bae:	83 c4 10             	add    $0x10,%esp
      end_op();
80105bb1:	e8 4b d6 ff ff       	call   80103201 <end_op>
      return -1;
80105bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bbb:	e9 c0 00 00 00       	jmp    80105c80 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105bc0:	e8 5e b4 ff ff       	call   80101023 <filealloc>
80105bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bc8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bcc:	74 17                	je     80105be5 <sys_open+0x104>
80105bce:	83 ec 0c             	sub    $0xc,%esp
80105bd1:	ff 75 f0             	pushl  -0x10(%ebp)
80105bd4:	e8 07 f7 ff ff       	call   801052e0 <fdalloc>
80105bd9:	83 c4 10             	add    $0x10,%esp
80105bdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105bdf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105be3:	79 2e                	jns    80105c13 <sys_open+0x132>
    if(f)
80105be5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105be9:	74 0e                	je     80105bf9 <sys_open+0x118>
      fileclose(f);
80105beb:	83 ec 0c             	sub    $0xc,%esp
80105bee:	ff 75 f0             	pushl  -0x10(%ebp)
80105bf1:	e8 f3 b4 ff ff       	call   801010e9 <fileclose>
80105bf6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105bf9:	83 ec 0c             	sub    $0xc,%esp
80105bfc:	ff 75 f4             	pushl  -0xc(%ebp)
80105bff:	e8 b5 c0 ff ff       	call   80101cb9 <iunlockput>
80105c04:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c07:	e8 f5 d5 ff ff       	call   80103201 <end_op>
    return -1;
80105c0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c11:	eb 6d                	jmp    80105c80 <sys_open+0x19f>
  }
  iunlock(ip);
80105c13:	83 ec 0c             	sub    $0xc,%esp
80105c16:	ff 75 f4             	pushl  -0xc(%ebp)
80105c19:	e8 75 bf ff ff       	call   80101b93 <iunlock>
80105c1e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c21:	e8 db d5 ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
80105c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c29:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c35:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c45:	83 e0 01             	and    $0x1,%eax
80105c48:	85 c0                	test   %eax,%eax
80105c4a:	0f 94 c0             	sete   %al
80105c4d:	89 c2                	mov    %eax,%edx
80105c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c52:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105c55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c58:	83 e0 01             	and    $0x1,%eax
80105c5b:	85 c0                	test   %eax,%eax
80105c5d:	75 0a                	jne    80105c69 <sys_open+0x188>
80105c5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c62:	83 e0 02             	and    $0x2,%eax
80105c65:	85 c0                	test   %eax,%eax
80105c67:	74 07                	je     80105c70 <sys_open+0x18f>
80105c69:	b8 01 00 00 00       	mov    $0x1,%eax
80105c6e:	eb 05                	jmp    80105c75 <sys_open+0x194>
80105c70:	b8 00 00 00 00       	mov    $0x0,%eax
80105c75:	89 c2                	mov    %eax,%edx
80105c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c80:	c9                   	leave  
80105c81:	c3                   	ret    

80105c82 <sys_mkdir>:

int
sys_mkdir(void)
{
80105c82:	f3 0f 1e fb          	endbr32 
80105c86:	55                   	push   %ebp
80105c87:	89 e5                	mov    %esp,%ebp
80105c89:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105c8c:	e8 e0 d4 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c91:	83 ec 08             	sub    $0x8,%esp
80105c94:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c97:	50                   	push   %eax
80105c98:	6a 00                	push   $0x0
80105c9a:	e8 0c f5 ff ff       	call   801051ab <argstr>
80105c9f:	83 c4 10             	add    $0x10,%esp
80105ca2:	85 c0                	test   %eax,%eax
80105ca4:	78 1b                	js     80105cc1 <sys_mkdir+0x3f>
80105ca6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca9:	6a 00                	push   $0x0
80105cab:	6a 00                	push   $0x0
80105cad:	6a 01                	push   $0x1
80105caf:	50                   	push   %eax
80105cb0:	e8 56 fc ff ff       	call   8010590b <create>
80105cb5:	83 c4 10             	add    $0x10,%esp
80105cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cbf:	75 0c                	jne    80105ccd <sys_mkdir+0x4b>
    end_op();
80105cc1:	e8 3b d5 ff ff       	call   80103201 <end_op>
    return -1;
80105cc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccb:	eb 18                	jmp    80105ce5 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105ccd:	83 ec 0c             	sub    $0xc,%esp
80105cd0:	ff 75 f4             	pushl  -0xc(%ebp)
80105cd3:	e8 e1 bf ff ff       	call   80101cb9 <iunlockput>
80105cd8:	83 c4 10             	add    $0x10,%esp
  end_op();
80105cdb:	e8 21 d5 ff ff       	call   80103201 <end_op>
  return 0;
80105ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ce5:	c9                   	leave  
80105ce6:	c3                   	ret    

80105ce7 <sys_mknod>:

int
sys_mknod(void)
{
80105ce7:	f3 0f 1e fb          	endbr32 
80105ceb:	55                   	push   %ebp
80105cec:	89 e5                	mov    %esp,%ebp
80105cee:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105cf1:	e8 7b d4 ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105cf6:	83 ec 08             	sub    $0x8,%esp
80105cf9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cfc:	50                   	push   %eax
80105cfd:	6a 00                	push   $0x0
80105cff:	e8 a7 f4 ff ff       	call   801051ab <argstr>
80105d04:	83 c4 10             	add    $0x10,%esp
80105d07:	85 c0                	test   %eax,%eax
80105d09:	78 4f                	js     80105d5a <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105d0b:	83 ec 08             	sub    $0x8,%esp
80105d0e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d11:	50                   	push   %eax
80105d12:	6a 01                	push   $0x1
80105d14:	e8 f5 f3 ff ff       	call   8010510e <argint>
80105d19:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d1c:	85 c0                	test   %eax,%eax
80105d1e:	78 3a                	js     80105d5a <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105d20:	83 ec 08             	sub    $0x8,%esp
80105d23:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d26:	50                   	push   %eax
80105d27:	6a 02                	push   $0x2
80105d29:	e8 e0 f3 ff ff       	call   8010510e <argint>
80105d2e:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d31:	85 c0                	test   %eax,%eax
80105d33:	78 25                	js     80105d5a <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d35:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d38:	0f bf c8             	movswl %ax,%ecx
80105d3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d3e:	0f bf d0             	movswl %ax,%edx
80105d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d44:	51                   	push   %ecx
80105d45:	52                   	push   %edx
80105d46:	6a 03                	push   $0x3
80105d48:	50                   	push   %eax
80105d49:	e8 bd fb ff ff       	call   8010590b <create>
80105d4e:	83 c4 10             	add    $0x10,%esp
80105d51:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105d54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d58:	75 0c                	jne    80105d66 <sys_mknod+0x7f>
    end_op();
80105d5a:	e8 a2 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105d5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d64:	eb 18                	jmp    80105d7e <sys_mknod+0x97>
  }
  iunlockput(ip);
80105d66:	83 ec 0c             	sub    $0xc,%esp
80105d69:	ff 75 f4             	pushl  -0xc(%ebp)
80105d6c:	e8 48 bf ff ff       	call   80101cb9 <iunlockput>
80105d71:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d74:	e8 88 d4 ff ff       	call   80103201 <end_op>
  return 0;
80105d79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d7e:	c9                   	leave  
80105d7f:	c3                   	ret    

80105d80 <sys_chdir>:

int
sys_chdir(void)
{
80105d80:	f3 0f 1e fb          	endbr32 
80105d84:	55                   	push   %ebp
80105d85:	89 e5                	mov    %esp,%ebp
80105d87:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105d8a:	e8 1a de ff ff       	call   80103ba9 <myproc>
80105d8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105d92:	e8 da d3 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105d97:	83 ec 08             	sub    $0x8,%esp
80105d9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d9d:	50                   	push   %eax
80105d9e:	6a 00                	push   $0x0
80105da0:	e8 06 f4 ff ff       	call   801051ab <argstr>
80105da5:	83 c4 10             	add    $0x10,%esp
80105da8:	85 c0                	test   %eax,%eax
80105daa:	78 18                	js     80105dc4 <sys_chdir+0x44>
80105dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105daf:	83 ec 0c             	sub    $0xc,%esp
80105db2:	50                   	push   %eax
80105db3:	e8 2f c8 ff ff       	call   801025e7 <namei>
80105db8:	83 c4 10             	add    $0x10,%esp
80105dbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dbe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dc2:	75 0c                	jne    80105dd0 <sys_chdir+0x50>
    end_op();
80105dc4:	e8 38 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dce:	eb 68                	jmp    80105e38 <sys_chdir+0xb8>
  }
  ilock(ip);
80105dd0:	83 ec 0c             	sub    $0xc,%esp
80105dd3:	ff 75 f0             	pushl  -0x10(%ebp)
80105dd6:	e8 a1 bc ff ff       	call   80101a7c <ilock>
80105ddb:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105de5:	66 83 f8 01          	cmp    $0x1,%ax
80105de9:	74 1a                	je     80105e05 <sys_chdir+0x85>
    iunlockput(ip);
80105deb:	83 ec 0c             	sub    $0xc,%esp
80105dee:	ff 75 f0             	pushl  -0x10(%ebp)
80105df1:	e8 c3 be ff ff       	call   80101cb9 <iunlockput>
80105df6:	83 c4 10             	add    $0x10,%esp
    end_op();
80105df9:	e8 03 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105dfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e03:	eb 33                	jmp    80105e38 <sys_chdir+0xb8>
  }
  iunlock(ip);
80105e05:	83 ec 0c             	sub    $0xc,%esp
80105e08:	ff 75 f0             	pushl  -0x10(%ebp)
80105e0b:	e8 83 bd ff ff       	call   80101b93 <iunlock>
80105e10:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e16:	8b 40 68             	mov    0x68(%eax),%eax
80105e19:	83 ec 0c             	sub    $0xc,%esp
80105e1c:	50                   	push   %eax
80105e1d:	e8 c3 bd ff ff       	call   80101be5 <iput>
80105e22:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e25:	e8 d7 d3 ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
80105e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e30:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e38:	c9                   	leave  
80105e39:	c3                   	ret    

80105e3a <sys_exec>:

int
sys_exec(void)
{
80105e3a:	f3 0f 1e fb          	endbr32 
80105e3e:	55                   	push   %ebp
80105e3f:	89 e5                	mov    %esp,%ebp
80105e41:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e47:	83 ec 08             	sub    $0x8,%esp
80105e4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e4d:	50                   	push   %eax
80105e4e:	6a 00                	push   $0x0
80105e50:	e8 56 f3 ff ff       	call   801051ab <argstr>
80105e55:	83 c4 10             	add    $0x10,%esp
80105e58:	85 c0                	test   %eax,%eax
80105e5a:	78 18                	js     80105e74 <sys_exec+0x3a>
80105e5c:	83 ec 08             	sub    $0x8,%esp
80105e5f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105e65:	50                   	push   %eax
80105e66:	6a 01                	push   $0x1
80105e68:	e8 a1 f2 ff ff       	call   8010510e <argint>
80105e6d:	83 c4 10             	add    $0x10,%esp
80105e70:	85 c0                	test   %eax,%eax
80105e72:	79 0a                	jns    80105e7e <sys_exec+0x44>
    return -1;
80105e74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e79:	e9 c6 00 00 00       	jmp    80105f44 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105e7e:	83 ec 04             	sub    $0x4,%esp
80105e81:	68 80 00 00 00       	push   $0x80
80105e86:	6a 00                	push   $0x0
80105e88:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e8e:	50                   	push   %eax
80105e8f:	e8 26 ef ff ff       	call   80104dba <memset>
80105e94:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105e97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea1:	83 f8 1f             	cmp    $0x1f,%eax
80105ea4:	76 0a                	jbe    80105eb0 <sys_exec+0x76>
      return -1;
80105ea6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eab:	e9 94 00 00 00       	jmp    80105f44 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb3:	c1 e0 02             	shl    $0x2,%eax
80105eb6:	89 c2                	mov    %eax,%edx
80105eb8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105ebe:	01 c2                	add    %eax,%edx
80105ec0:	83 ec 08             	sub    $0x8,%esp
80105ec3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105ec9:	50                   	push   %eax
80105eca:	52                   	push   %edx
80105ecb:	e8 93 f1 ff ff       	call   80105063 <fetchint>
80105ed0:	83 c4 10             	add    $0x10,%esp
80105ed3:	85 c0                	test   %eax,%eax
80105ed5:	79 07                	jns    80105ede <sys_exec+0xa4>
      return -1;
80105ed7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105edc:	eb 66                	jmp    80105f44 <sys_exec+0x10a>
    if(uarg == 0){
80105ede:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105ee4:	85 c0                	test   %eax,%eax
80105ee6:	75 27                	jne    80105f0f <sys_exec+0xd5>
      argv[i] = 0;
80105ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eeb:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105ef2:	00 00 00 00 
      break;
80105ef6:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efa:	83 ec 08             	sub    $0x8,%esp
80105efd:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f03:	52                   	push   %edx
80105f04:	50                   	push   %eax
80105f05:	e8 b4 ac ff ff       	call   80100bbe <exec>
80105f0a:	83 c4 10             	add    $0x10,%esp
80105f0d:	eb 35                	jmp    80105f44 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105f0f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105f15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f18:	c1 e2 02             	shl    $0x2,%edx
80105f1b:	01 c2                	add    %eax,%edx
80105f1d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f23:	83 ec 08             	sub    $0x8,%esp
80105f26:	52                   	push   %edx
80105f27:	50                   	push   %eax
80105f28:	e8 79 f1 ff ff       	call   801050a6 <fetchstr>
80105f2d:	83 c4 10             	add    $0x10,%esp
80105f30:	85 c0                	test   %eax,%eax
80105f32:	79 07                	jns    80105f3b <sys_exec+0x101>
      return -1;
80105f34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f39:	eb 09                	jmp    80105f44 <sys_exec+0x10a>
  for(i=0;; i++){
80105f3b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f3f:	e9 5a ff ff ff       	jmp    80105e9e <sys_exec+0x64>
}
80105f44:	c9                   	leave  
80105f45:	c3                   	ret    

80105f46 <sys_pipe>:

int
sys_pipe(void)
{
80105f46:	f3 0f 1e fb          	endbr32 
80105f4a:	55                   	push   %ebp
80105f4b:	89 e5                	mov    %esp,%ebp
80105f4d:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f50:	83 ec 04             	sub    $0x4,%esp
80105f53:	6a 08                	push   $0x8
80105f55:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f58:	50                   	push   %eax
80105f59:	6a 00                	push   $0x0
80105f5b:	e8 df f1 ff ff       	call   8010513f <argptr>
80105f60:	83 c4 10             	add    $0x10,%esp
80105f63:	85 c0                	test   %eax,%eax
80105f65:	79 0a                	jns    80105f71 <sys_pipe+0x2b>
    return -1;
80105f67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f6c:	e9 ae 00 00 00       	jmp    8010601f <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105f71:	83 ec 08             	sub    $0x8,%esp
80105f74:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f77:	50                   	push   %eax
80105f78:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f7b:	50                   	push   %eax
80105f7c:	e8 49 d7 ff ff       	call   801036ca <pipealloc>
80105f81:	83 c4 10             	add    $0x10,%esp
80105f84:	85 c0                	test   %eax,%eax
80105f86:	79 0a                	jns    80105f92 <sys_pipe+0x4c>
    return -1;
80105f88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f8d:	e9 8d 00 00 00       	jmp    8010601f <sys_pipe+0xd9>
  fd0 = -1;
80105f92:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f9c:	83 ec 0c             	sub    $0xc,%esp
80105f9f:	50                   	push   %eax
80105fa0:	e8 3b f3 ff ff       	call   801052e0 <fdalloc>
80105fa5:	83 c4 10             	add    $0x10,%esp
80105fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105faf:	78 18                	js     80105fc9 <sys_pipe+0x83>
80105fb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fb4:	83 ec 0c             	sub    $0xc,%esp
80105fb7:	50                   	push   %eax
80105fb8:	e8 23 f3 ff ff       	call   801052e0 <fdalloc>
80105fbd:	83 c4 10             	add    $0x10,%esp
80105fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fc7:	79 3e                	jns    80106007 <sys_pipe+0xc1>
    if(fd0 >= 0)
80105fc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fcd:	78 13                	js     80105fe2 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80105fcf:	e8 d5 db ff ff       	call   80103ba9 <myproc>
80105fd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fd7:	83 c2 08             	add    $0x8,%edx
80105fda:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105fe1:	00 
    fileclose(rf);
80105fe2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fe5:	83 ec 0c             	sub    $0xc,%esp
80105fe8:	50                   	push   %eax
80105fe9:	e8 fb b0 ff ff       	call   801010e9 <fileclose>
80105fee:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105ff1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ff4:	83 ec 0c             	sub    $0xc,%esp
80105ff7:	50                   	push   %eax
80105ff8:	e8 ec b0 ff ff       	call   801010e9 <fileclose>
80105ffd:	83 c4 10             	add    $0x10,%esp
    return -1;
80106000:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106005:	eb 18                	jmp    8010601f <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106007:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010600a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010600d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010600f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106012:	8d 50 04             	lea    0x4(%eax),%edx
80106015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106018:	89 02                	mov    %eax,(%edx)
  return 0;
8010601a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010601f:	c9                   	leave  
80106020:	c3                   	ret    

80106021 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106021:	f3 0f 1e fb          	endbr32 
80106025:	55                   	push   %ebp
80106026:	89 e5                	mov    %esp,%ebp
80106028:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010602b:	e8 8c de ff ff       	call   80103ebc <fork>
}
80106030:	c9                   	leave  
80106031:	c3                   	ret    

80106032 <sys_exit>:

int
sys_exit(void)
{
80106032:	f3 0f 1e fb          	endbr32 
80106036:	55                   	push   %ebp
80106037:	89 e5                	mov    %esp,%ebp
80106039:	83 ec 08             	sub    $0x8,%esp
  exit();
8010603c:	e8 f8 df ff ff       	call   80104039 <exit>
  return 0;  // not reached
80106041:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106046:	c9                   	leave  
80106047:	c3                   	ret    

80106048 <sys_wait>:

int
sys_wait(void)
{
80106048:	f3 0f 1e fb          	endbr32 
8010604c:	55                   	push   %ebp
8010604d:	89 e5                	mov    %esp,%ebp
8010604f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106052:	e8 33 e2 ff ff       	call   8010428a <wait>
}
80106057:	c9                   	leave  
80106058:	c3                   	ret    

80106059 <sys_kill>:

int
sys_kill(void)
{
80106059:	f3 0f 1e fb          	endbr32 
8010605d:	55                   	push   %ebp
8010605e:	89 e5                	mov    %esp,%ebp
80106060:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106063:	83 ec 08             	sub    $0x8,%esp
80106066:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106069:	50                   	push   %eax
8010606a:	6a 00                	push   $0x0
8010606c:	e8 9d f0 ff ff       	call   8010510e <argint>
80106071:	83 c4 10             	add    $0x10,%esp
80106074:	85 c0                	test   %eax,%eax
80106076:	79 07                	jns    8010607f <sys_kill+0x26>
    return -1;
80106078:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010607d:	eb 0f                	jmp    8010608e <sys_kill+0x35>
  return kill(pid);
8010607f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106082:	83 ec 0c             	sub    $0xc,%esp
80106085:	50                   	push   %eax
80106086:	e8 87 e7 ff ff       	call   80104812 <kill>
8010608b:	83 c4 10             	add    $0x10,%esp
}
8010608e:	c9                   	leave  
8010608f:	c3                   	ret    

80106090 <sys_getpid>:

int
sys_getpid(void)
{
80106090:	f3 0f 1e fb          	endbr32 
80106094:	55                   	push   %ebp
80106095:	89 e5                	mov    %esp,%ebp
80106097:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010609a:	e8 0a db ff ff       	call   80103ba9 <myproc>
8010609f:	8b 40 10             	mov    0x10(%eax),%eax
}
801060a2:	c9                   	leave  
801060a3:	c3                   	ret    

801060a4 <sys_sbrk>:

int
sys_sbrk(void)
{
801060a4:	f3 0f 1e fb          	endbr32 
801060a8:	55                   	push   %ebp
801060a9:	89 e5                	mov    %esp,%ebp
801060ab:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801060ae:	83 ec 08             	sub    $0x8,%esp
801060b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060b4:	50                   	push   %eax
801060b5:	6a 00                	push   $0x0
801060b7:	e8 52 f0 ff ff       	call   8010510e <argint>
801060bc:	83 c4 10             	add    $0x10,%esp
801060bf:	85 c0                	test   %eax,%eax
801060c1:	79 07                	jns    801060ca <sys_sbrk+0x26>
    return -1;
801060c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c8:	eb 27                	jmp    801060f1 <sys_sbrk+0x4d>
  addr = myproc()->sz;
801060ca:	e8 da da ff ff       	call   80103ba9 <myproc>
801060cf:	8b 00                	mov    (%eax),%eax
801060d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801060d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d7:	83 ec 0c             	sub    $0xc,%esp
801060da:	50                   	push   %eax
801060db:	e8 3d dd ff ff       	call   80103e1d <growproc>
801060e0:	83 c4 10             	add    $0x10,%esp
801060e3:	85 c0                	test   %eax,%eax
801060e5:	79 07                	jns    801060ee <sys_sbrk+0x4a>
    return -1;
801060e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ec:	eb 03                	jmp    801060f1 <sys_sbrk+0x4d>
  return addr;
801060ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801060f1:	c9                   	leave  
801060f2:	c3                   	ret    

801060f3 <sys_sleep>:

int
sys_sleep(void)
{
801060f3:	f3 0f 1e fb          	endbr32 
801060f7:	55                   	push   %ebp
801060f8:	89 e5                	mov    %esp,%ebp
801060fa:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801060fd:	83 ec 08             	sub    $0x8,%esp
80106100:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106103:	50                   	push   %eax
80106104:	6a 00                	push   $0x0
80106106:	e8 03 f0 ff ff       	call   8010510e <argint>
8010610b:	83 c4 10             	add    $0x10,%esp
8010610e:	85 c0                	test   %eax,%eax
80106110:	79 07                	jns    80106119 <sys_sleep+0x26>
    return -1;
80106112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106117:	eb 76                	jmp    8010618f <sys_sleep+0x9c>
  acquire(&tickslock);
80106119:	83 ec 0c             	sub    $0xc,%esp
8010611c:	68 40 75 19 80       	push   $0x80197540
80106121:	e8 05 ea ff ff       	call   80104b2b <acquire>
80106126:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106129:	a1 80 7d 19 80       	mov    0x80197d80,%eax
8010612e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106131:	eb 38                	jmp    8010616b <sys_sleep+0x78>
    if(myproc()->killed){
80106133:	e8 71 da ff ff       	call   80103ba9 <myproc>
80106138:	8b 40 24             	mov    0x24(%eax),%eax
8010613b:	85 c0                	test   %eax,%eax
8010613d:	74 17                	je     80106156 <sys_sleep+0x63>
      release(&tickslock);
8010613f:	83 ec 0c             	sub    $0xc,%esp
80106142:	68 40 75 19 80       	push   $0x80197540
80106147:	e8 51 ea ff ff       	call   80104b9d <release>
8010614c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010614f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106154:	eb 39                	jmp    8010618f <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106156:	83 ec 08             	sub    $0x8,%esp
80106159:	68 40 75 19 80       	push   $0x80197540
8010615e:	68 80 7d 19 80       	push   $0x80197d80
80106163:	e8 80 e5 ff ff       	call   801046e8 <sleep>
80106168:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010616b:	a1 80 7d 19 80       	mov    0x80197d80,%eax
80106170:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106173:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106176:	39 d0                	cmp    %edx,%eax
80106178:	72 b9                	jb     80106133 <sys_sleep+0x40>
  }
  release(&tickslock);
8010617a:	83 ec 0c             	sub    $0xc,%esp
8010617d:	68 40 75 19 80       	push   $0x80197540
80106182:	e8 16 ea ff ff       	call   80104b9d <release>
80106187:	83 c4 10             	add    $0x10,%esp
  return 0;
8010618a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010618f:	c9                   	leave  
80106190:	c3                   	ret    

80106191 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106191:	f3 0f 1e fb          	endbr32 
80106195:	55                   	push   %ebp
80106196:	89 e5                	mov    %esp,%ebp
80106198:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010619b:	83 ec 0c             	sub    $0xc,%esp
8010619e:	68 40 75 19 80       	push   $0x80197540
801061a3:	e8 83 e9 ff ff       	call   80104b2b <acquire>
801061a8:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061ab:	a1 80 7d 19 80       	mov    0x80197d80,%eax
801061b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061b3:	83 ec 0c             	sub    $0xc,%esp
801061b6:	68 40 75 19 80       	push   $0x80197540
801061bb:	e8 dd e9 ff ff       	call   80104b9d <release>
801061c0:	83 c4 10             	add    $0x10,%esp
  return xticks;
801061c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061c6:	c9                   	leave  
801061c7:	c3                   	ret    

801061c8 <sys_exit2>:

int
sys_exit2(void)
{
801061c8:	f3 0f 1e fb          	endbr32 
801061cc:	55                   	push   %ebp
801061cd:	89 e5                	mov    %esp,%ebp
801061cf:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
801061d2:	83 ec 08             	sub    $0x8,%esp
801061d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061d8:	50                   	push   %eax
801061d9:	6a 00                	push   $0x0
801061db:	e8 2e ef ff ff       	call   8010510e <argint>
801061e0:	83 c4 10             	add    $0x10,%esp
801061e3:	85 c0                	test   %eax,%eax
801061e5:	79 07                	jns    801061ee <sys_exit2+0x26>
    return -1;
801061e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ec:	eb 14                	jmp    80106202 <sys_exit2+0x3a>
  exit2(status);
801061ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f1:	83 ec 0c             	sub    $0xc,%esp
801061f4:	50                   	push   %eax
801061f5:	e8 63 df ff ff       	call   8010415d <exit2>
801061fa:	83 c4 10             	add    $0x10,%esp
  return 0;
801061fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106202:	c9                   	leave  
80106203:	c3                   	ret    

80106204 <sys_wait2>:

int
sys_wait2(void)
{
80106204:	f3 0f 1e fb          	endbr32 
80106208:	55                   	push   %ebp
80106209:	89 e5                	mov    %esp,%ebp
8010620b:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void*)&status, sizeof(*status)) < 0)
8010620e:	83 ec 04             	sub    $0x4,%esp
80106211:	6a 04                	push   $0x4
80106213:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106216:	50                   	push   %eax
80106217:	6a 00                	push   $0x0
80106219:	e8 21 ef ff ff       	call   8010513f <argptr>
8010621e:	83 c4 10             	add    $0x10,%esp
80106221:	85 c0                	test   %eax,%eax
80106223:	79 07                	jns    8010622c <sys_wait2+0x28>
    return -1;
80106225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622a:	eb 0f                	jmp    8010623b <sys_wait2+0x37>
  return wait2(status);
8010622c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622f:	83 ec 0c             	sub    $0xc,%esp
80106232:	50                   	push   %eax
80106233:	e8 76 e1 ff ff       	call   801043ae <wait2>
80106238:	83 c4 10             	add    $0x10,%esp
}
8010623b:	c9                   	leave  
8010623c:	c3                   	ret    

8010623d <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010623d:	1e                   	push   %ds
  pushl %es
8010623e:	06                   	push   %es
  pushl %fs
8010623f:	0f a0                	push   %fs
  pushl %gs
80106241:	0f a8                	push   %gs
  pushal
80106243:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106244:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106248:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010624a:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010624c:	54                   	push   %esp
  call trap
8010624d:	e8 df 01 00 00       	call   80106431 <trap>
  addl $4, %esp
80106252:	83 c4 04             	add    $0x4,%esp

80106255 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106255:	61                   	popa   
  popl %gs
80106256:	0f a9                	pop    %gs
  popl %fs
80106258:	0f a1                	pop    %fs
  popl %es
8010625a:	07                   	pop    %es
  popl %ds
8010625b:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010625c:	83 c4 08             	add    $0x8,%esp
  iret
8010625f:	cf                   	iret   

80106260 <lidt>:
{
80106260:	55                   	push   %ebp
80106261:	89 e5                	mov    %esp,%ebp
80106263:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106266:	8b 45 0c             	mov    0xc(%ebp),%eax
80106269:	83 e8 01             	sub    $0x1,%eax
8010626c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106270:	8b 45 08             	mov    0x8(%ebp),%eax
80106273:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106277:	8b 45 08             	mov    0x8(%ebp),%eax
8010627a:	c1 e8 10             	shr    $0x10,%eax
8010627d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106281:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106284:	0f 01 18             	lidtl  (%eax)
}
80106287:	90                   	nop
80106288:	c9                   	leave  
80106289:	c3                   	ret    

8010628a <rcr2>:

static inline uint
rcr2(void)
{
8010628a:	55                   	push   %ebp
8010628b:	89 e5                	mov    %esp,%ebp
8010628d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106290:	0f 20 d0             	mov    %cr2,%eax
80106293:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106296:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106299:	c9                   	leave  
8010629a:	c3                   	ret    

8010629b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010629b:	f3 0f 1e fb          	endbr32 
8010629f:	55                   	push   %ebp
801062a0:	89 e5                	mov    %esp,%ebp
801062a2:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801062a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801062ac:	e9 c3 00 00 00       	jmp    80106374 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801062b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b4:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801062bb:	89 c2                	mov    %eax,%edx
801062bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c0:	66 89 14 c5 80 75 19 	mov    %dx,-0x7fe68a80(,%eax,8)
801062c7:	80 
801062c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cb:	66 c7 04 c5 82 75 19 	movw   $0x8,-0x7fe68a7e(,%eax,8)
801062d2:	80 08 00 
801062d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d8:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
801062df:	80 
801062e0:	83 e2 e0             	and    $0xffffffe0,%edx
801062e3:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
801062ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ed:	0f b6 14 c5 84 75 19 	movzbl -0x7fe68a7c(,%eax,8),%edx
801062f4:	80 
801062f5:	83 e2 1f             	and    $0x1f,%edx
801062f8:	88 14 c5 84 75 19 80 	mov    %dl,-0x7fe68a7c(,%eax,8)
801062ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106302:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106309:	80 
8010630a:	83 e2 f0             	and    $0xfffffff0,%edx
8010630d:	83 ca 0e             	or     $0xe,%edx
80106310:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631a:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106321:	80 
80106322:	83 e2 ef             	and    $0xffffffef,%edx
80106325:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
8010632c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632f:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
80106336:	80 
80106337:	83 e2 9f             	and    $0xffffff9f,%edx
8010633a:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106344:	0f b6 14 c5 85 75 19 	movzbl -0x7fe68a7b(,%eax,8),%edx
8010634b:	80 
8010634c:	83 ca 80             	or     $0xffffff80,%edx
8010634f:	88 14 c5 85 75 19 80 	mov    %dl,-0x7fe68a7b(,%eax,8)
80106356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106359:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106360:	c1 e8 10             	shr    $0x10,%eax
80106363:	89 c2                	mov    %eax,%edx
80106365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106368:	66 89 14 c5 86 75 19 	mov    %dx,-0x7fe68a7a(,%eax,8)
8010636f:	80 
  for(i = 0; i < 256; i++)
80106370:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106374:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010637b:	0f 8e 30 ff ff ff    	jle    801062b1 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106381:	a1 80 f1 10 80       	mov    0x8010f180,%eax
80106386:	66 a3 80 77 19 80    	mov    %ax,0x80197780
8010638c:	66 c7 05 82 77 19 80 	movw   $0x8,0x80197782
80106393:	08 00 
80106395:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
8010639c:	83 e0 e0             	and    $0xffffffe0,%eax
8010639f:	a2 84 77 19 80       	mov    %al,0x80197784
801063a4:	0f b6 05 84 77 19 80 	movzbl 0x80197784,%eax
801063ab:	83 e0 1f             	and    $0x1f,%eax
801063ae:	a2 84 77 19 80       	mov    %al,0x80197784
801063b3:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
801063ba:	83 c8 0f             	or     $0xf,%eax
801063bd:	a2 85 77 19 80       	mov    %al,0x80197785
801063c2:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
801063c9:	83 e0 ef             	and    $0xffffffef,%eax
801063cc:	a2 85 77 19 80       	mov    %al,0x80197785
801063d1:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
801063d8:	83 c8 60             	or     $0x60,%eax
801063db:	a2 85 77 19 80       	mov    %al,0x80197785
801063e0:	0f b6 05 85 77 19 80 	movzbl 0x80197785,%eax
801063e7:	83 c8 80             	or     $0xffffff80,%eax
801063ea:	a2 85 77 19 80       	mov    %al,0x80197785
801063ef:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801063f4:	c1 e8 10             	shr    $0x10,%eax
801063f7:	66 a3 86 77 19 80    	mov    %ax,0x80197786

  initlock(&tickslock, "time");
801063fd:	83 ec 08             	sub    $0x8,%esp
80106400:	68 58 aa 10 80       	push   $0x8010aa58
80106405:	68 40 75 19 80       	push   $0x80197540
8010640a:	e8 f6 e6 ff ff       	call   80104b05 <initlock>
8010640f:	83 c4 10             	add    $0x10,%esp
}
80106412:	90                   	nop
80106413:	c9                   	leave  
80106414:	c3                   	ret    

80106415 <idtinit>:

void
idtinit(void)
{
80106415:	f3 0f 1e fb          	endbr32 
80106419:	55                   	push   %ebp
8010641a:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010641c:	68 00 08 00 00       	push   $0x800
80106421:	68 80 75 19 80       	push   $0x80197580
80106426:	e8 35 fe ff ff       	call   80106260 <lidt>
8010642b:	83 c4 08             	add    $0x8,%esp
}
8010642e:	90                   	nop
8010642f:	c9                   	leave  
80106430:	c3                   	ret    

80106431 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106431:	f3 0f 1e fb          	endbr32 
80106435:	55                   	push   %ebp
80106436:	89 e5                	mov    %esp,%ebp
80106438:	57                   	push   %edi
80106439:	56                   	push   %esi
8010643a:	53                   	push   %ebx
8010643b:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010643e:	8b 45 08             	mov    0x8(%ebp),%eax
80106441:	8b 40 30             	mov    0x30(%eax),%eax
80106444:	83 f8 40             	cmp    $0x40,%eax
80106447:	75 3b                	jne    80106484 <trap+0x53>
    if(myproc()->killed)
80106449:	e8 5b d7 ff ff       	call   80103ba9 <myproc>
8010644e:	8b 40 24             	mov    0x24(%eax),%eax
80106451:	85 c0                	test   %eax,%eax
80106453:	74 05                	je     8010645a <trap+0x29>
      exit();
80106455:	e8 df db ff ff       	call   80104039 <exit>
    myproc()->tf = tf;
8010645a:	e8 4a d7 ff ff       	call   80103ba9 <myproc>
8010645f:	8b 55 08             	mov    0x8(%ebp),%edx
80106462:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106465:	e8 7c ed ff ff       	call   801051e6 <syscall>
    if(myproc()->killed)
8010646a:	e8 3a d7 ff ff       	call   80103ba9 <myproc>
8010646f:	8b 40 24             	mov    0x24(%eax),%eax
80106472:	85 c0                	test   %eax,%eax
80106474:	0f 84 16 02 00 00    	je     80106690 <trap+0x25f>
      exit();
8010647a:	e8 ba db ff ff       	call   80104039 <exit>
    return;
8010647f:	e9 0c 02 00 00       	jmp    80106690 <trap+0x25f>
  }

  switch(tf->trapno){
80106484:	8b 45 08             	mov    0x8(%ebp),%eax
80106487:	8b 40 30             	mov    0x30(%eax),%eax
8010648a:	83 e8 20             	sub    $0x20,%eax
8010648d:	83 f8 1f             	cmp    $0x1f,%eax
80106490:	0f 87 c5 00 00 00    	ja     8010655b <trap+0x12a>
80106496:	8b 04 85 00 ab 10 80 	mov    -0x7fef5500(,%eax,4),%eax
8010649d:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801064a0:	e8 69 d6 ff ff       	call   80103b0e <cpuid>
801064a5:	85 c0                	test   %eax,%eax
801064a7:	75 3d                	jne    801064e6 <trap+0xb5>
      acquire(&tickslock);
801064a9:	83 ec 0c             	sub    $0xc,%esp
801064ac:	68 40 75 19 80       	push   $0x80197540
801064b1:	e8 75 e6 ff ff       	call   80104b2b <acquire>
801064b6:	83 c4 10             	add    $0x10,%esp
      ticks++;
801064b9:	a1 80 7d 19 80       	mov    0x80197d80,%eax
801064be:	83 c0 01             	add    $0x1,%eax
801064c1:	a3 80 7d 19 80       	mov    %eax,0x80197d80
      wakeup(&ticks);
801064c6:	83 ec 0c             	sub    $0xc,%esp
801064c9:	68 80 7d 19 80       	push   $0x80197d80
801064ce:	e8 04 e3 ff ff       	call   801047d7 <wakeup>
801064d3:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801064d6:	83 ec 0c             	sub    $0xc,%esp
801064d9:	68 40 75 19 80       	push   $0x80197540
801064de:	e8 ba e6 ff ff       	call   80104b9d <release>
801064e3:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801064e6:	e8 3a c7 ff ff       	call   80102c25 <lapiceoi>
    break;
801064eb:	e9 20 01 00 00       	jmp    80106610 <trap+0x1df>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801064f0:	e8 1b 40 00 00       	call   8010a510 <ideintr>
    lapiceoi();
801064f5:	e8 2b c7 ff ff       	call   80102c25 <lapiceoi>
    break;
801064fa:	e9 11 01 00 00       	jmp    80106610 <trap+0x1df>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801064ff:	e8 57 c5 ff ff       	call   80102a5b <kbdintr>
    lapiceoi();
80106504:	e8 1c c7 ff ff       	call   80102c25 <lapiceoi>
    break;
80106509:	e9 02 01 00 00       	jmp    80106610 <trap+0x1df>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010650e:	e8 5f 03 00 00       	call   80106872 <uartintr>
    lapiceoi();
80106513:	e8 0d c7 ff ff       	call   80102c25 <lapiceoi>
    break;
80106518:	e9 f3 00 00 00       	jmp    80106610 <trap+0x1df>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010651d:	e8 2d 2c 00 00       	call   8010914f <i8254_intr>
    lapiceoi();
80106522:	e8 fe c6 ff ff       	call   80102c25 <lapiceoi>
    break;
80106527:	e9 e4 00 00 00       	jmp    80106610 <trap+0x1df>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010652c:	8b 45 08             	mov    0x8(%ebp),%eax
8010652f:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106532:	8b 45 08             	mov    0x8(%ebp),%eax
80106535:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106539:	0f b7 d8             	movzwl %ax,%ebx
8010653c:	e8 cd d5 ff ff       	call   80103b0e <cpuid>
80106541:	56                   	push   %esi
80106542:	53                   	push   %ebx
80106543:	50                   	push   %eax
80106544:	68 60 aa 10 80       	push   $0x8010aa60
80106549:	e8 be 9e ff ff       	call   8010040c <cprintf>
8010654e:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106551:	e8 cf c6 ff ff       	call   80102c25 <lapiceoi>
    break;
80106556:	e9 b5 00 00 00       	jmp    80106610 <trap+0x1df>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010655b:	e8 49 d6 ff ff       	call   80103ba9 <myproc>
80106560:	85 c0                	test   %eax,%eax
80106562:	74 11                	je     80106575 <trap+0x144>
80106564:	8b 45 08             	mov    0x8(%ebp),%eax
80106567:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010656b:	0f b7 c0             	movzwl %ax,%eax
8010656e:	83 e0 03             	and    $0x3,%eax
80106571:	85 c0                	test   %eax,%eax
80106573:	75 39                	jne    801065ae <trap+0x17d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106575:	e8 10 fd ff ff       	call   8010628a <rcr2>
8010657a:	89 c3                	mov    %eax,%ebx
8010657c:	8b 45 08             	mov    0x8(%ebp),%eax
8010657f:	8b 70 38             	mov    0x38(%eax),%esi
80106582:	e8 87 d5 ff ff       	call   80103b0e <cpuid>
80106587:	8b 55 08             	mov    0x8(%ebp),%edx
8010658a:	8b 52 30             	mov    0x30(%edx),%edx
8010658d:	83 ec 0c             	sub    $0xc,%esp
80106590:	53                   	push   %ebx
80106591:	56                   	push   %esi
80106592:	50                   	push   %eax
80106593:	52                   	push   %edx
80106594:	68 84 aa 10 80       	push   $0x8010aa84
80106599:	e8 6e 9e ff ff       	call   8010040c <cprintf>
8010659e:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801065a1:	83 ec 0c             	sub    $0xc,%esp
801065a4:	68 b6 aa 10 80       	push   $0x8010aab6
801065a9:	e8 17 a0 ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065ae:	e8 d7 fc ff ff       	call   8010628a <rcr2>
801065b3:	89 c6                	mov    %eax,%esi
801065b5:	8b 45 08             	mov    0x8(%ebp),%eax
801065b8:	8b 40 38             	mov    0x38(%eax),%eax
801065bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801065be:	e8 4b d5 ff ff       	call   80103b0e <cpuid>
801065c3:	89 c3                	mov    %eax,%ebx
801065c5:	8b 45 08             	mov    0x8(%ebp),%eax
801065c8:	8b 48 34             	mov    0x34(%eax),%ecx
801065cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801065ce:	8b 45 08             	mov    0x8(%ebp),%eax
801065d1:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801065d4:	e8 d0 d5 ff ff       	call   80103ba9 <myproc>
801065d9:	8d 50 6c             	lea    0x6c(%eax),%edx
801065dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
801065df:	e8 c5 d5 ff ff       	call   80103ba9 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801065e4:	8b 40 10             	mov    0x10(%eax),%eax
801065e7:	56                   	push   %esi
801065e8:	ff 75 e4             	pushl  -0x1c(%ebp)
801065eb:	53                   	push   %ebx
801065ec:	ff 75 e0             	pushl  -0x20(%ebp)
801065ef:	57                   	push   %edi
801065f0:	ff 75 dc             	pushl  -0x24(%ebp)
801065f3:	50                   	push   %eax
801065f4:	68 bc aa 10 80       	push   $0x8010aabc
801065f9:	e8 0e 9e ff ff       	call   8010040c <cprintf>
801065fe:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106601:	e8 a3 d5 ff ff       	call   80103ba9 <myproc>
80106606:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010660d:	eb 01                	jmp    80106610 <trap+0x1df>
    break;
8010660f:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106610:	e8 94 d5 ff ff       	call   80103ba9 <myproc>
80106615:	85 c0                	test   %eax,%eax
80106617:	74 23                	je     8010663c <trap+0x20b>
80106619:	e8 8b d5 ff ff       	call   80103ba9 <myproc>
8010661e:	8b 40 24             	mov    0x24(%eax),%eax
80106621:	85 c0                	test   %eax,%eax
80106623:	74 17                	je     8010663c <trap+0x20b>
80106625:	8b 45 08             	mov    0x8(%ebp),%eax
80106628:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010662c:	0f b7 c0             	movzwl %ax,%eax
8010662f:	83 e0 03             	and    $0x3,%eax
80106632:	83 f8 03             	cmp    $0x3,%eax
80106635:	75 05                	jne    8010663c <trap+0x20b>
    exit();
80106637:	e8 fd d9 ff ff       	call   80104039 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010663c:	e8 68 d5 ff ff       	call   80103ba9 <myproc>
80106641:	85 c0                	test   %eax,%eax
80106643:	74 1d                	je     80106662 <trap+0x231>
80106645:	e8 5f d5 ff ff       	call   80103ba9 <myproc>
8010664a:	8b 40 0c             	mov    0xc(%eax),%eax
8010664d:	83 f8 04             	cmp    $0x4,%eax
80106650:	75 10                	jne    80106662 <trap+0x231>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106652:	8b 45 08             	mov    0x8(%ebp),%eax
80106655:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106658:	83 f8 20             	cmp    $0x20,%eax
8010665b:	75 05                	jne    80106662 <trap+0x231>
    yield();
8010665d:	e8 fe df ff ff       	call   80104660 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106662:	e8 42 d5 ff ff       	call   80103ba9 <myproc>
80106667:	85 c0                	test   %eax,%eax
80106669:	74 26                	je     80106691 <trap+0x260>
8010666b:	e8 39 d5 ff ff       	call   80103ba9 <myproc>
80106670:	8b 40 24             	mov    0x24(%eax),%eax
80106673:	85 c0                	test   %eax,%eax
80106675:	74 1a                	je     80106691 <trap+0x260>
80106677:	8b 45 08             	mov    0x8(%ebp),%eax
8010667a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010667e:	0f b7 c0             	movzwl %ax,%eax
80106681:	83 e0 03             	and    $0x3,%eax
80106684:	83 f8 03             	cmp    $0x3,%eax
80106687:	75 08                	jne    80106691 <trap+0x260>
    exit();
80106689:	e8 ab d9 ff ff       	call   80104039 <exit>
8010668e:	eb 01                	jmp    80106691 <trap+0x260>
    return;
80106690:	90                   	nop
}
80106691:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106694:	5b                   	pop    %ebx
80106695:	5e                   	pop    %esi
80106696:	5f                   	pop    %edi
80106697:	5d                   	pop    %ebp
80106698:	c3                   	ret    

80106699 <inb>:
{
80106699:	55                   	push   %ebp
8010669a:	89 e5                	mov    %esp,%ebp
8010669c:	83 ec 14             	sub    $0x14,%esp
8010669f:	8b 45 08             	mov    0x8(%ebp),%eax
801066a2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066a6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801066aa:	89 c2                	mov    %eax,%edx
801066ac:	ec                   	in     (%dx),%al
801066ad:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801066b0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801066b4:	c9                   	leave  
801066b5:	c3                   	ret    

801066b6 <outb>:
{
801066b6:	55                   	push   %ebp
801066b7:	89 e5                	mov    %esp,%ebp
801066b9:	83 ec 08             	sub    $0x8,%esp
801066bc:	8b 45 08             	mov    0x8(%ebp),%eax
801066bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801066c2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801066c6:	89 d0                	mov    %edx,%eax
801066c8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066cb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066cf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066d3:	ee                   	out    %al,(%dx)
}
801066d4:	90                   	nop
801066d5:	c9                   	leave  
801066d6:	c3                   	ret    

801066d7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801066d7:	f3 0f 1e fb          	endbr32 
801066db:	55                   	push   %ebp
801066dc:	89 e5                	mov    %esp,%ebp
801066de:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801066e1:	6a 00                	push   $0x0
801066e3:	68 fa 03 00 00       	push   $0x3fa
801066e8:	e8 c9 ff ff ff       	call   801066b6 <outb>
801066ed:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801066f0:	68 80 00 00 00       	push   $0x80
801066f5:	68 fb 03 00 00       	push   $0x3fb
801066fa:	e8 b7 ff ff ff       	call   801066b6 <outb>
801066ff:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106702:	6a 0c                	push   $0xc
80106704:	68 f8 03 00 00       	push   $0x3f8
80106709:	e8 a8 ff ff ff       	call   801066b6 <outb>
8010670e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106711:	6a 00                	push   $0x0
80106713:	68 f9 03 00 00       	push   $0x3f9
80106718:	e8 99 ff ff ff       	call   801066b6 <outb>
8010671d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106720:	6a 03                	push   $0x3
80106722:	68 fb 03 00 00       	push   $0x3fb
80106727:	e8 8a ff ff ff       	call   801066b6 <outb>
8010672c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010672f:	6a 00                	push   $0x0
80106731:	68 fc 03 00 00       	push   $0x3fc
80106736:	e8 7b ff ff ff       	call   801066b6 <outb>
8010673b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010673e:	6a 01                	push   $0x1
80106740:	68 f9 03 00 00       	push   $0x3f9
80106745:	e8 6c ff ff ff       	call   801066b6 <outb>
8010674a:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010674d:	68 fd 03 00 00       	push   $0x3fd
80106752:	e8 42 ff ff ff       	call   80106699 <inb>
80106757:	83 c4 04             	add    $0x4,%esp
8010675a:	3c ff                	cmp    $0xff,%al
8010675c:	74 61                	je     801067bf <uartinit+0xe8>
    return;
  uart = 1;
8010675e:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106765:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106768:	68 fa 03 00 00       	push   $0x3fa
8010676d:	e8 27 ff ff ff       	call   80106699 <inb>
80106772:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106775:	68 f8 03 00 00       	push   $0x3f8
8010677a:	e8 1a ff ff ff       	call   80106699 <inb>
8010677f:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106782:	83 ec 08             	sub    $0x8,%esp
80106785:	6a 00                	push   $0x0
80106787:	6a 04                	push   $0x4
80106789:	e8 7e bf ff ff       	call   8010270c <ioapicenable>
8010678e:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106791:	c7 45 f4 80 ab 10 80 	movl   $0x8010ab80,-0xc(%ebp)
80106798:	eb 19                	jmp    801067b3 <uartinit+0xdc>
    uartputc(*p);
8010679a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679d:	0f b6 00             	movzbl (%eax),%eax
801067a0:	0f be c0             	movsbl %al,%eax
801067a3:	83 ec 0c             	sub    $0xc,%esp
801067a6:	50                   	push   %eax
801067a7:	e8 16 00 00 00       	call   801067c2 <uartputc>
801067ac:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801067af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b6:	0f b6 00             	movzbl (%eax),%eax
801067b9:	84 c0                	test   %al,%al
801067bb:	75 dd                	jne    8010679a <uartinit+0xc3>
801067bd:	eb 01                	jmp    801067c0 <uartinit+0xe9>
    return;
801067bf:	90                   	nop
}
801067c0:	c9                   	leave  
801067c1:	c3                   	ret    

801067c2 <uartputc>:

void
uartputc(int c)
{
801067c2:	f3 0f 1e fb          	endbr32 
801067c6:	55                   	push   %ebp
801067c7:	89 e5                	mov    %esp,%ebp
801067c9:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801067cc:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801067d1:	85 c0                	test   %eax,%eax
801067d3:	74 53                	je     80106828 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067dc:	eb 11                	jmp    801067ef <uartputc+0x2d>
    microdelay(10);
801067de:	83 ec 0c             	sub    $0xc,%esp
801067e1:	6a 0a                	push   $0xa
801067e3:	e8 5c c4 ff ff       	call   80102c44 <microdelay>
801067e8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801067eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801067ef:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801067f3:	7f 1a                	jg     8010680f <uartputc+0x4d>
801067f5:	83 ec 0c             	sub    $0xc,%esp
801067f8:	68 fd 03 00 00       	push   $0x3fd
801067fd:	e8 97 fe ff ff       	call   80106699 <inb>
80106802:	83 c4 10             	add    $0x10,%esp
80106805:	0f b6 c0             	movzbl %al,%eax
80106808:	83 e0 20             	and    $0x20,%eax
8010680b:	85 c0                	test   %eax,%eax
8010680d:	74 cf                	je     801067de <uartputc+0x1c>
  outb(COM1+0, c);
8010680f:	8b 45 08             	mov    0x8(%ebp),%eax
80106812:	0f b6 c0             	movzbl %al,%eax
80106815:	83 ec 08             	sub    $0x8,%esp
80106818:	50                   	push   %eax
80106819:	68 f8 03 00 00       	push   $0x3f8
8010681e:	e8 93 fe ff ff       	call   801066b6 <outb>
80106823:	83 c4 10             	add    $0x10,%esp
80106826:	eb 01                	jmp    80106829 <uartputc+0x67>
    return;
80106828:	90                   	nop
}
80106829:	c9                   	leave  
8010682a:	c3                   	ret    

8010682b <uartgetc>:

static int
uartgetc(void)
{
8010682b:	f3 0f 1e fb          	endbr32 
8010682f:	55                   	push   %ebp
80106830:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106832:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106837:	85 c0                	test   %eax,%eax
80106839:	75 07                	jne    80106842 <uartgetc+0x17>
    return -1;
8010683b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106840:	eb 2e                	jmp    80106870 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106842:	68 fd 03 00 00       	push   $0x3fd
80106847:	e8 4d fe ff ff       	call   80106699 <inb>
8010684c:	83 c4 04             	add    $0x4,%esp
8010684f:	0f b6 c0             	movzbl %al,%eax
80106852:	83 e0 01             	and    $0x1,%eax
80106855:	85 c0                	test   %eax,%eax
80106857:	75 07                	jne    80106860 <uartgetc+0x35>
    return -1;
80106859:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685e:	eb 10                	jmp    80106870 <uartgetc+0x45>
  return inb(COM1+0);
80106860:	68 f8 03 00 00       	push   $0x3f8
80106865:	e8 2f fe ff ff       	call   80106699 <inb>
8010686a:	83 c4 04             	add    $0x4,%esp
8010686d:	0f b6 c0             	movzbl %al,%eax
}
80106870:	c9                   	leave  
80106871:	c3                   	ret    

80106872 <uartintr>:

void
uartintr(void)
{
80106872:	f3 0f 1e fb          	endbr32 
80106876:	55                   	push   %ebp
80106877:	89 e5                	mov    %esp,%ebp
80106879:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010687c:	83 ec 0c             	sub    $0xc,%esp
8010687f:	68 2b 68 10 80       	push   $0x8010682b
80106884:	e8 77 9f ff ff       	call   80100800 <consoleintr>
80106889:	83 c4 10             	add    $0x10,%esp
}
8010688c:	90                   	nop
8010688d:	c9                   	leave  
8010688e:	c3                   	ret    

8010688f <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010688f:	6a 00                	push   $0x0
  pushl $0
80106891:	6a 00                	push   $0x0
  jmp alltraps
80106893:	e9 a5 f9 ff ff       	jmp    8010623d <alltraps>

80106898 <vector1>:
.globl vector1
vector1:
  pushl $0
80106898:	6a 00                	push   $0x0
  pushl $1
8010689a:	6a 01                	push   $0x1
  jmp alltraps
8010689c:	e9 9c f9 ff ff       	jmp    8010623d <alltraps>

801068a1 <vector2>:
.globl vector2
vector2:
  pushl $0
801068a1:	6a 00                	push   $0x0
  pushl $2
801068a3:	6a 02                	push   $0x2
  jmp alltraps
801068a5:	e9 93 f9 ff ff       	jmp    8010623d <alltraps>

801068aa <vector3>:
.globl vector3
vector3:
  pushl $0
801068aa:	6a 00                	push   $0x0
  pushl $3
801068ac:	6a 03                	push   $0x3
  jmp alltraps
801068ae:	e9 8a f9 ff ff       	jmp    8010623d <alltraps>

801068b3 <vector4>:
.globl vector4
vector4:
  pushl $0
801068b3:	6a 00                	push   $0x0
  pushl $4
801068b5:	6a 04                	push   $0x4
  jmp alltraps
801068b7:	e9 81 f9 ff ff       	jmp    8010623d <alltraps>

801068bc <vector5>:
.globl vector5
vector5:
  pushl $0
801068bc:	6a 00                	push   $0x0
  pushl $5
801068be:	6a 05                	push   $0x5
  jmp alltraps
801068c0:	e9 78 f9 ff ff       	jmp    8010623d <alltraps>

801068c5 <vector6>:
.globl vector6
vector6:
  pushl $0
801068c5:	6a 00                	push   $0x0
  pushl $6
801068c7:	6a 06                	push   $0x6
  jmp alltraps
801068c9:	e9 6f f9 ff ff       	jmp    8010623d <alltraps>

801068ce <vector7>:
.globl vector7
vector7:
  pushl $0
801068ce:	6a 00                	push   $0x0
  pushl $7
801068d0:	6a 07                	push   $0x7
  jmp alltraps
801068d2:	e9 66 f9 ff ff       	jmp    8010623d <alltraps>

801068d7 <vector8>:
.globl vector8
vector8:
  pushl $8
801068d7:	6a 08                	push   $0x8
  jmp alltraps
801068d9:	e9 5f f9 ff ff       	jmp    8010623d <alltraps>

801068de <vector9>:
.globl vector9
vector9:
  pushl $0
801068de:	6a 00                	push   $0x0
  pushl $9
801068e0:	6a 09                	push   $0x9
  jmp alltraps
801068e2:	e9 56 f9 ff ff       	jmp    8010623d <alltraps>

801068e7 <vector10>:
.globl vector10
vector10:
  pushl $10
801068e7:	6a 0a                	push   $0xa
  jmp alltraps
801068e9:	e9 4f f9 ff ff       	jmp    8010623d <alltraps>

801068ee <vector11>:
.globl vector11
vector11:
  pushl $11
801068ee:	6a 0b                	push   $0xb
  jmp alltraps
801068f0:	e9 48 f9 ff ff       	jmp    8010623d <alltraps>

801068f5 <vector12>:
.globl vector12
vector12:
  pushl $12
801068f5:	6a 0c                	push   $0xc
  jmp alltraps
801068f7:	e9 41 f9 ff ff       	jmp    8010623d <alltraps>

801068fc <vector13>:
.globl vector13
vector13:
  pushl $13
801068fc:	6a 0d                	push   $0xd
  jmp alltraps
801068fe:	e9 3a f9 ff ff       	jmp    8010623d <alltraps>

80106903 <vector14>:
.globl vector14
vector14:
  pushl $14
80106903:	6a 0e                	push   $0xe
  jmp alltraps
80106905:	e9 33 f9 ff ff       	jmp    8010623d <alltraps>

8010690a <vector15>:
.globl vector15
vector15:
  pushl $0
8010690a:	6a 00                	push   $0x0
  pushl $15
8010690c:	6a 0f                	push   $0xf
  jmp alltraps
8010690e:	e9 2a f9 ff ff       	jmp    8010623d <alltraps>

80106913 <vector16>:
.globl vector16
vector16:
  pushl $0
80106913:	6a 00                	push   $0x0
  pushl $16
80106915:	6a 10                	push   $0x10
  jmp alltraps
80106917:	e9 21 f9 ff ff       	jmp    8010623d <alltraps>

8010691c <vector17>:
.globl vector17
vector17:
  pushl $17
8010691c:	6a 11                	push   $0x11
  jmp alltraps
8010691e:	e9 1a f9 ff ff       	jmp    8010623d <alltraps>

80106923 <vector18>:
.globl vector18
vector18:
  pushl $0
80106923:	6a 00                	push   $0x0
  pushl $18
80106925:	6a 12                	push   $0x12
  jmp alltraps
80106927:	e9 11 f9 ff ff       	jmp    8010623d <alltraps>

8010692c <vector19>:
.globl vector19
vector19:
  pushl $0
8010692c:	6a 00                	push   $0x0
  pushl $19
8010692e:	6a 13                	push   $0x13
  jmp alltraps
80106930:	e9 08 f9 ff ff       	jmp    8010623d <alltraps>

80106935 <vector20>:
.globl vector20
vector20:
  pushl $0
80106935:	6a 00                	push   $0x0
  pushl $20
80106937:	6a 14                	push   $0x14
  jmp alltraps
80106939:	e9 ff f8 ff ff       	jmp    8010623d <alltraps>

8010693e <vector21>:
.globl vector21
vector21:
  pushl $0
8010693e:	6a 00                	push   $0x0
  pushl $21
80106940:	6a 15                	push   $0x15
  jmp alltraps
80106942:	e9 f6 f8 ff ff       	jmp    8010623d <alltraps>

80106947 <vector22>:
.globl vector22
vector22:
  pushl $0
80106947:	6a 00                	push   $0x0
  pushl $22
80106949:	6a 16                	push   $0x16
  jmp alltraps
8010694b:	e9 ed f8 ff ff       	jmp    8010623d <alltraps>

80106950 <vector23>:
.globl vector23
vector23:
  pushl $0
80106950:	6a 00                	push   $0x0
  pushl $23
80106952:	6a 17                	push   $0x17
  jmp alltraps
80106954:	e9 e4 f8 ff ff       	jmp    8010623d <alltraps>

80106959 <vector24>:
.globl vector24
vector24:
  pushl $0
80106959:	6a 00                	push   $0x0
  pushl $24
8010695b:	6a 18                	push   $0x18
  jmp alltraps
8010695d:	e9 db f8 ff ff       	jmp    8010623d <alltraps>

80106962 <vector25>:
.globl vector25
vector25:
  pushl $0
80106962:	6a 00                	push   $0x0
  pushl $25
80106964:	6a 19                	push   $0x19
  jmp alltraps
80106966:	e9 d2 f8 ff ff       	jmp    8010623d <alltraps>

8010696b <vector26>:
.globl vector26
vector26:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $26
8010696d:	6a 1a                	push   $0x1a
  jmp alltraps
8010696f:	e9 c9 f8 ff ff       	jmp    8010623d <alltraps>

80106974 <vector27>:
.globl vector27
vector27:
  pushl $0
80106974:	6a 00                	push   $0x0
  pushl $27
80106976:	6a 1b                	push   $0x1b
  jmp alltraps
80106978:	e9 c0 f8 ff ff       	jmp    8010623d <alltraps>

8010697d <vector28>:
.globl vector28
vector28:
  pushl $0
8010697d:	6a 00                	push   $0x0
  pushl $28
8010697f:	6a 1c                	push   $0x1c
  jmp alltraps
80106981:	e9 b7 f8 ff ff       	jmp    8010623d <alltraps>

80106986 <vector29>:
.globl vector29
vector29:
  pushl $0
80106986:	6a 00                	push   $0x0
  pushl $29
80106988:	6a 1d                	push   $0x1d
  jmp alltraps
8010698a:	e9 ae f8 ff ff       	jmp    8010623d <alltraps>

8010698f <vector30>:
.globl vector30
vector30:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $30
80106991:	6a 1e                	push   $0x1e
  jmp alltraps
80106993:	e9 a5 f8 ff ff       	jmp    8010623d <alltraps>

80106998 <vector31>:
.globl vector31
vector31:
  pushl $0
80106998:	6a 00                	push   $0x0
  pushl $31
8010699a:	6a 1f                	push   $0x1f
  jmp alltraps
8010699c:	e9 9c f8 ff ff       	jmp    8010623d <alltraps>

801069a1 <vector32>:
.globl vector32
vector32:
  pushl $0
801069a1:	6a 00                	push   $0x0
  pushl $32
801069a3:	6a 20                	push   $0x20
  jmp alltraps
801069a5:	e9 93 f8 ff ff       	jmp    8010623d <alltraps>

801069aa <vector33>:
.globl vector33
vector33:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $33
801069ac:	6a 21                	push   $0x21
  jmp alltraps
801069ae:	e9 8a f8 ff ff       	jmp    8010623d <alltraps>

801069b3 <vector34>:
.globl vector34
vector34:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $34
801069b5:	6a 22                	push   $0x22
  jmp alltraps
801069b7:	e9 81 f8 ff ff       	jmp    8010623d <alltraps>

801069bc <vector35>:
.globl vector35
vector35:
  pushl $0
801069bc:	6a 00                	push   $0x0
  pushl $35
801069be:	6a 23                	push   $0x23
  jmp alltraps
801069c0:	e9 78 f8 ff ff       	jmp    8010623d <alltraps>

801069c5 <vector36>:
.globl vector36
vector36:
  pushl $0
801069c5:	6a 00                	push   $0x0
  pushl $36
801069c7:	6a 24                	push   $0x24
  jmp alltraps
801069c9:	e9 6f f8 ff ff       	jmp    8010623d <alltraps>

801069ce <vector37>:
.globl vector37
vector37:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $37
801069d0:	6a 25                	push   $0x25
  jmp alltraps
801069d2:	e9 66 f8 ff ff       	jmp    8010623d <alltraps>

801069d7 <vector38>:
.globl vector38
vector38:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $38
801069d9:	6a 26                	push   $0x26
  jmp alltraps
801069db:	e9 5d f8 ff ff       	jmp    8010623d <alltraps>

801069e0 <vector39>:
.globl vector39
vector39:
  pushl $0
801069e0:	6a 00                	push   $0x0
  pushl $39
801069e2:	6a 27                	push   $0x27
  jmp alltraps
801069e4:	e9 54 f8 ff ff       	jmp    8010623d <alltraps>

801069e9 <vector40>:
.globl vector40
vector40:
  pushl $0
801069e9:	6a 00                	push   $0x0
  pushl $40
801069eb:	6a 28                	push   $0x28
  jmp alltraps
801069ed:	e9 4b f8 ff ff       	jmp    8010623d <alltraps>

801069f2 <vector41>:
.globl vector41
vector41:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $41
801069f4:	6a 29                	push   $0x29
  jmp alltraps
801069f6:	e9 42 f8 ff ff       	jmp    8010623d <alltraps>

801069fb <vector42>:
.globl vector42
vector42:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $42
801069fd:	6a 2a                	push   $0x2a
  jmp alltraps
801069ff:	e9 39 f8 ff ff       	jmp    8010623d <alltraps>

80106a04 <vector43>:
.globl vector43
vector43:
  pushl $0
80106a04:	6a 00                	push   $0x0
  pushl $43
80106a06:	6a 2b                	push   $0x2b
  jmp alltraps
80106a08:	e9 30 f8 ff ff       	jmp    8010623d <alltraps>

80106a0d <vector44>:
.globl vector44
vector44:
  pushl $0
80106a0d:	6a 00                	push   $0x0
  pushl $44
80106a0f:	6a 2c                	push   $0x2c
  jmp alltraps
80106a11:	e9 27 f8 ff ff       	jmp    8010623d <alltraps>

80106a16 <vector45>:
.globl vector45
vector45:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $45
80106a18:	6a 2d                	push   $0x2d
  jmp alltraps
80106a1a:	e9 1e f8 ff ff       	jmp    8010623d <alltraps>

80106a1f <vector46>:
.globl vector46
vector46:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $46
80106a21:	6a 2e                	push   $0x2e
  jmp alltraps
80106a23:	e9 15 f8 ff ff       	jmp    8010623d <alltraps>

80106a28 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a28:	6a 00                	push   $0x0
  pushl $47
80106a2a:	6a 2f                	push   $0x2f
  jmp alltraps
80106a2c:	e9 0c f8 ff ff       	jmp    8010623d <alltraps>

80106a31 <vector48>:
.globl vector48
vector48:
  pushl $0
80106a31:	6a 00                	push   $0x0
  pushl $48
80106a33:	6a 30                	push   $0x30
  jmp alltraps
80106a35:	e9 03 f8 ff ff       	jmp    8010623d <alltraps>

80106a3a <vector49>:
.globl vector49
vector49:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $49
80106a3c:	6a 31                	push   $0x31
  jmp alltraps
80106a3e:	e9 fa f7 ff ff       	jmp    8010623d <alltraps>

80106a43 <vector50>:
.globl vector50
vector50:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $50
80106a45:	6a 32                	push   $0x32
  jmp alltraps
80106a47:	e9 f1 f7 ff ff       	jmp    8010623d <alltraps>

80106a4c <vector51>:
.globl vector51
vector51:
  pushl $0
80106a4c:	6a 00                	push   $0x0
  pushl $51
80106a4e:	6a 33                	push   $0x33
  jmp alltraps
80106a50:	e9 e8 f7 ff ff       	jmp    8010623d <alltraps>

80106a55 <vector52>:
.globl vector52
vector52:
  pushl $0
80106a55:	6a 00                	push   $0x0
  pushl $52
80106a57:	6a 34                	push   $0x34
  jmp alltraps
80106a59:	e9 df f7 ff ff       	jmp    8010623d <alltraps>

80106a5e <vector53>:
.globl vector53
vector53:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $53
80106a60:	6a 35                	push   $0x35
  jmp alltraps
80106a62:	e9 d6 f7 ff ff       	jmp    8010623d <alltraps>

80106a67 <vector54>:
.globl vector54
vector54:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $54
80106a69:	6a 36                	push   $0x36
  jmp alltraps
80106a6b:	e9 cd f7 ff ff       	jmp    8010623d <alltraps>

80106a70 <vector55>:
.globl vector55
vector55:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $55
80106a72:	6a 37                	push   $0x37
  jmp alltraps
80106a74:	e9 c4 f7 ff ff       	jmp    8010623d <alltraps>

80106a79 <vector56>:
.globl vector56
vector56:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $56
80106a7b:	6a 38                	push   $0x38
  jmp alltraps
80106a7d:	e9 bb f7 ff ff       	jmp    8010623d <alltraps>

80106a82 <vector57>:
.globl vector57
vector57:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $57
80106a84:	6a 39                	push   $0x39
  jmp alltraps
80106a86:	e9 b2 f7 ff ff       	jmp    8010623d <alltraps>

80106a8b <vector58>:
.globl vector58
vector58:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $58
80106a8d:	6a 3a                	push   $0x3a
  jmp alltraps
80106a8f:	e9 a9 f7 ff ff       	jmp    8010623d <alltraps>

80106a94 <vector59>:
.globl vector59
vector59:
  pushl $0
80106a94:	6a 00                	push   $0x0
  pushl $59
80106a96:	6a 3b                	push   $0x3b
  jmp alltraps
80106a98:	e9 a0 f7 ff ff       	jmp    8010623d <alltraps>

80106a9d <vector60>:
.globl vector60
vector60:
  pushl $0
80106a9d:	6a 00                	push   $0x0
  pushl $60
80106a9f:	6a 3c                	push   $0x3c
  jmp alltraps
80106aa1:	e9 97 f7 ff ff       	jmp    8010623d <alltraps>

80106aa6 <vector61>:
.globl vector61
vector61:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $61
80106aa8:	6a 3d                	push   $0x3d
  jmp alltraps
80106aaa:	e9 8e f7 ff ff       	jmp    8010623d <alltraps>

80106aaf <vector62>:
.globl vector62
vector62:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $62
80106ab1:	6a 3e                	push   $0x3e
  jmp alltraps
80106ab3:	e9 85 f7 ff ff       	jmp    8010623d <alltraps>

80106ab8 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ab8:	6a 00                	push   $0x0
  pushl $63
80106aba:	6a 3f                	push   $0x3f
  jmp alltraps
80106abc:	e9 7c f7 ff ff       	jmp    8010623d <alltraps>

80106ac1 <vector64>:
.globl vector64
vector64:
  pushl $0
80106ac1:	6a 00                	push   $0x0
  pushl $64
80106ac3:	6a 40                	push   $0x40
  jmp alltraps
80106ac5:	e9 73 f7 ff ff       	jmp    8010623d <alltraps>

80106aca <vector65>:
.globl vector65
vector65:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $65
80106acc:	6a 41                	push   $0x41
  jmp alltraps
80106ace:	e9 6a f7 ff ff       	jmp    8010623d <alltraps>

80106ad3 <vector66>:
.globl vector66
vector66:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $66
80106ad5:	6a 42                	push   $0x42
  jmp alltraps
80106ad7:	e9 61 f7 ff ff       	jmp    8010623d <alltraps>

80106adc <vector67>:
.globl vector67
vector67:
  pushl $0
80106adc:	6a 00                	push   $0x0
  pushl $67
80106ade:	6a 43                	push   $0x43
  jmp alltraps
80106ae0:	e9 58 f7 ff ff       	jmp    8010623d <alltraps>

80106ae5 <vector68>:
.globl vector68
vector68:
  pushl $0
80106ae5:	6a 00                	push   $0x0
  pushl $68
80106ae7:	6a 44                	push   $0x44
  jmp alltraps
80106ae9:	e9 4f f7 ff ff       	jmp    8010623d <alltraps>

80106aee <vector69>:
.globl vector69
vector69:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $69
80106af0:	6a 45                	push   $0x45
  jmp alltraps
80106af2:	e9 46 f7 ff ff       	jmp    8010623d <alltraps>

80106af7 <vector70>:
.globl vector70
vector70:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $70
80106af9:	6a 46                	push   $0x46
  jmp alltraps
80106afb:	e9 3d f7 ff ff       	jmp    8010623d <alltraps>

80106b00 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b00:	6a 00                	push   $0x0
  pushl $71
80106b02:	6a 47                	push   $0x47
  jmp alltraps
80106b04:	e9 34 f7 ff ff       	jmp    8010623d <alltraps>

80106b09 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b09:	6a 00                	push   $0x0
  pushl $72
80106b0b:	6a 48                	push   $0x48
  jmp alltraps
80106b0d:	e9 2b f7 ff ff       	jmp    8010623d <alltraps>

80106b12 <vector73>:
.globl vector73
vector73:
  pushl $0
80106b12:	6a 00                	push   $0x0
  pushl $73
80106b14:	6a 49                	push   $0x49
  jmp alltraps
80106b16:	e9 22 f7 ff ff       	jmp    8010623d <alltraps>

80106b1b <vector74>:
.globl vector74
vector74:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $74
80106b1d:	6a 4a                	push   $0x4a
  jmp alltraps
80106b1f:	e9 19 f7 ff ff       	jmp    8010623d <alltraps>

80106b24 <vector75>:
.globl vector75
vector75:
  pushl $0
80106b24:	6a 00                	push   $0x0
  pushl $75
80106b26:	6a 4b                	push   $0x4b
  jmp alltraps
80106b28:	e9 10 f7 ff ff       	jmp    8010623d <alltraps>

80106b2d <vector76>:
.globl vector76
vector76:
  pushl $0
80106b2d:	6a 00                	push   $0x0
  pushl $76
80106b2f:	6a 4c                	push   $0x4c
  jmp alltraps
80106b31:	e9 07 f7 ff ff       	jmp    8010623d <alltraps>

80106b36 <vector77>:
.globl vector77
vector77:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $77
80106b38:	6a 4d                	push   $0x4d
  jmp alltraps
80106b3a:	e9 fe f6 ff ff       	jmp    8010623d <alltraps>

80106b3f <vector78>:
.globl vector78
vector78:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $78
80106b41:	6a 4e                	push   $0x4e
  jmp alltraps
80106b43:	e9 f5 f6 ff ff       	jmp    8010623d <alltraps>

80106b48 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b48:	6a 00                	push   $0x0
  pushl $79
80106b4a:	6a 4f                	push   $0x4f
  jmp alltraps
80106b4c:	e9 ec f6 ff ff       	jmp    8010623d <alltraps>

80106b51 <vector80>:
.globl vector80
vector80:
  pushl $0
80106b51:	6a 00                	push   $0x0
  pushl $80
80106b53:	6a 50                	push   $0x50
  jmp alltraps
80106b55:	e9 e3 f6 ff ff       	jmp    8010623d <alltraps>

80106b5a <vector81>:
.globl vector81
vector81:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $81
80106b5c:	6a 51                	push   $0x51
  jmp alltraps
80106b5e:	e9 da f6 ff ff       	jmp    8010623d <alltraps>

80106b63 <vector82>:
.globl vector82
vector82:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $82
80106b65:	6a 52                	push   $0x52
  jmp alltraps
80106b67:	e9 d1 f6 ff ff       	jmp    8010623d <alltraps>

80106b6c <vector83>:
.globl vector83
vector83:
  pushl $0
80106b6c:	6a 00                	push   $0x0
  pushl $83
80106b6e:	6a 53                	push   $0x53
  jmp alltraps
80106b70:	e9 c8 f6 ff ff       	jmp    8010623d <alltraps>

80106b75 <vector84>:
.globl vector84
vector84:
  pushl $0
80106b75:	6a 00                	push   $0x0
  pushl $84
80106b77:	6a 54                	push   $0x54
  jmp alltraps
80106b79:	e9 bf f6 ff ff       	jmp    8010623d <alltraps>

80106b7e <vector85>:
.globl vector85
vector85:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $85
80106b80:	6a 55                	push   $0x55
  jmp alltraps
80106b82:	e9 b6 f6 ff ff       	jmp    8010623d <alltraps>

80106b87 <vector86>:
.globl vector86
vector86:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $86
80106b89:	6a 56                	push   $0x56
  jmp alltraps
80106b8b:	e9 ad f6 ff ff       	jmp    8010623d <alltraps>

80106b90 <vector87>:
.globl vector87
vector87:
  pushl $0
80106b90:	6a 00                	push   $0x0
  pushl $87
80106b92:	6a 57                	push   $0x57
  jmp alltraps
80106b94:	e9 a4 f6 ff ff       	jmp    8010623d <alltraps>

80106b99 <vector88>:
.globl vector88
vector88:
  pushl $0
80106b99:	6a 00                	push   $0x0
  pushl $88
80106b9b:	6a 58                	push   $0x58
  jmp alltraps
80106b9d:	e9 9b f6 ff ff       	jmp    8010623d <alltraps>

80106ba2 <vector89>:
.globl vector89
vector89:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $89
80106ba4:	6a 59                	push   $0x59
  jmp alltraps
80106ba6:	e9 92 f6 ff ff       	jmp    8010623d <alltraps>

80106bab <vector90>:
.globl vector90
vector90:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $90
80106bad:	6a 5a                	push   $0x5a
  jmp alltraps
80106baf:	e9 89 f6 ff ff       	jmp    8010623d <alltraps>

80106bb4 <vector91>:
.globl vector91
vector91:
  pushl $0
80106bb4:	6a 00                	push   $0x0
  pushl $91
80106bb6:	6a 5b                	push   $0x5b
  jmp alltraps
80106bb8:	e9 80 f6 ff ff       	jmp    8010623d <alltraps>

80106bbd <vector92>:
.globl vector92
vector92:
  pushl $0
80106bbd:	6a 00                	push   $0x0
  pushl $92
80106bbf:	6a 5c                	push   $0x5c
  jmp alltraps
80106bc1:	e9 77 f6 ff ff       	jmp    8010623d <alltraps>

80106bc6 <vector93>:
.globl vector93
vector93:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $93
80106bc8:	6a 5d                	push   $0x5d
  jmp alltraps
80106bca:	e9 6e f6 ff ff       	jmp    8010623d <alltraps>

80106bcf <vector94>:
.globl vector94
vector94:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $94
80106bd1:	6a 5e                	push   $0x5e
  jmp alltraps
80106bd3:	e9 65 f6 ff ff       	jmp    8010623d <alltraps>

80106bd8 <vector95>:
.globl vector95
vector95:
  pushl $0
80106bd8:	6a 00                	push   $0x0
  pushl $95
80106bda:	6a 5f                	push   $0x5f
  jmp alltraps
80106bdc:	e9 5c f6 ff ff       	jmp    8010623d <alltraps>

80106be1 <vector96>:
.globl vector96
vector96:
  pushl $0
80106be1:	6a 00                	push   $0x0
  pushl $96
80106be3:	6a 60                	push   $0x60
  jmp alltraps
80106be5:	e9 53 f6 ff ff       	jmp    8010623d <alltraps>

80106bea <vector97>:
.globl vector97
vector97:
  pushl $0
80106bea:	6a 00                	push   $0x0
  pushl $97
80106bec:	6a 61                	push   $0x61
  jmp alltraps
80106bee:	e9 4a f6 ff ff       	jmp    8010623d <alltraps>

80106bf3 <vector98>:
.globl vector98
vector98:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $98
80106bf5:	6a 62                	push   $0x62
  jmp alltraps
80106bf7:	e9 41 f6 ff ff       	jmp    8010623d <alltraps>

80106bfc <vector99>:
.globl vector99
vector99:
  pushl $0
80106bfc:	6a 00                	push   $0x0
  pushl $99
80106bfe:	6a 63                	push   $0x63
  jmp alltraps
80106c00:	e9 38 f6 ff ff       	jmp    8010623d <alltraps>

80106c05 <vector100>:
.globl vector100
vector100:
  pushl $0
80106c05:	6a 00                	push   $0x0
  pushl $100
80106c07:	6a 64                	push   $0x64
  jmp alltraps
80106c09:	e9 2f f6 ff ff       	jmp    8010623d <alltraps>

80106c0e <vector101>:
.globl vector101
vector101:
  pushl $0
80106c0e:	6a 00                	push   $0x0
  pushl $101
80106c10:	6a 65                	push   $0x65
  jmp alltraps
80106c12:	e9 26 f6 ff ff       	jmp    8010623d <alltraps>

80106c17 <vector102>:
.globl vector102
vector102:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $102
80106c19:	6a 66                	push   $0x66
  jmp alltraps
80106c1b:	e9 1d f6 ff ff       	jmp    8010623d <alltraps>

80106c20 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c20:	6a 00                	push   $0x0
  pushl $103
80106c22:	6a 67                	push   $0x67
  jmp alltraps
80106c24:	e9 14 f6 ff ff       	jmp    8010623d <alltraps>

80106c29 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c29:	6a 00                	push   $0x0
  pushl $104
80106c2b:	6a 68                	push   $0x68
  jmp alltraps
80106c2d:	e9 0b f6 ff ff       	jmp    8010623d <alltraps>

80106c32 <vector105>:
.globl vector105
vector105:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $105
80106c34:	6a 69                	push   $0x69
  jmp alltraps
80106c36:	e9 02 f6 ff ff       	jmp    8010623d <alltraps>

80106c3b <vector106>:
.globl vector106
vector106:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $106
80106c3d:	6a 6a                	push   $0x6a
  jmp alltraps
80106c3f:	e9 f9 f5 ff ff       	jmp    8010623d <alltraps>

80106c44 <vector107>:
.globl vector107
vector107:
  pushl $0
80106c44:	6a 00                	push   $0x0
  pushl $107
80106c46:	6a 6b                	push   $0x6b
  jmp alltraps
80106c48:	e9 f0 f5 ff ff       	jmp    8010623d <alltraps>

80106c4d <vector108>:
.globl vector108
vector108:
  pushl $0
80106c4d:	6a 00                	push   $0x0
  pushl $108
80106c4f:	6a 6c                	push   $0x6c
  jmp alltraps
80106c51:	e9 e7 f5 ff ff       	jmp    8010623d <alltraps>

80106c56 <vector109>:
.globl vector109
vector109:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $109
80106c58:	6a 6d                	push   $0x6d
  jmp alltraps
80106c5a:	e9 de f5 ff ff       	jmp    8010623d <alltraps>

80106c5f <vector110>:
.globl vector110
vector110:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $110
80106c61:	6a 6e                	push   $0x6e
  jmp alltraps
80106c63:	e9 d5 f5 ff ff       	jmp    8010623d <alltraps>

80106c68 <vector111>:
.globl vector111
vector111:
  pushl $0
80106c68:	6a 00                	push   $0x0
  pushl $111
80106c6a:	6a 6f                	push   $0x6f
  jmp alltraps
80106c6c:	e9 cc f5 ff ff       	jmp    8010623d <alltraps>

80106c71 <vector112>:
.globl vector112
vector112:
  pushl $0
80106c71:	6a 00                	push   $0x0
  pushl $112
80106c73:	6a 70                	push   $0x70
  jmp alltraps
80106c75:	e9 c3 f5 ff ff       	jmp    8010623d <alltraps>

80106c7a <vector113>:
.globl vector113
vector113:
  pushl $0
80106c7a:	6a 00                	push   $0x0
  pushl $113
80106c7c:	6a 71                	push   $0x71
  jmp alltraps
80106c7e:	e9 ba f5 ff ff       	jmp    8010623d <alltraps>

80106c83 <vector114>:
.globl vector114
vector114:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $114
80106c85:	6a 72                	push   $0x72
  jmp alltraps
80106c87:	e9 b1 f5 ff ff       	jmp    8010623d <alltraps>

80106c8c <vector115>:
.globl vector115
vector115:
  pushl $0
80106c8c:	6a 00                	push   $0x0
  pushl $115
80106c8e:	6a 73                	push   $0x73
  jmp alltraps
80106c90:	e9 a8 f5 ff ff       	jmp    8010623d <alltraps>

80106c95 <vector116>:
.globl vector116
vector116:
  pushl $0
80106c95:	6a 00                	push   $0x0
  pushl $116
80106c97:	6a 74                	push   $0x74
  jmp alltraps
80106c99:	e9 9f f5 ff ff       	jmp    8010623d <alltraps>

80106c9e <vector117>:
.globl vector117
vector117:
  pushl $0
80106c9e:	6a 00                	push   $0x0
  pushl $117
80106ca0:	6a 75                	push   $0x75
  jmp alltraps
80106ca2:	e9 96 f5 ff ff       	jmp    8010623d <alltraps>

80106ca7 <vector118>:
.globl vector118
vector118:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $118
80106ca9:	6a 76                	push   $0x76
  jmp alltraps
80106cab:	e9 8d f5 ff ff       	jmp    8010623d <alltraps>

80106cb0 <vector119>:
.globl vector119
vector119:
  pushl $0
80106cb0:	6a 00                	push   $0x0
  pushl $119
80106cb2:	6a 77                	push   $0x77
  jmp alltraps
80106cb4:	e9 84 f5 ff ff       	jmp    8010623d <alltraps>

80106cb9 <vector120>:
.globl vector120
vector120:
  pushl $0
80106cb9:	6a 00                	push   $0x0
  pushl $120
80106cbb:	6a 78                	push   $0x78
  jmp alltraps
80106cbd:	e9 7b f5 ff ff       	jmp    8010623d <alltraps>

80106cc2 <vector121>:
.globl vector121
vector121:
  pushl $0
80106cc2:	6a 00                	push   $0x0
  pushl $121
80106cc4:	6a 79                	push   $0x79
  jmp alltraps
80106cc6:	e9 72 f5 ff ff       	jmp    8010623d <alltraps>

80106ccb <vector122>:
.globl vector122
vector122:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $122
80106ccd:	6a 7a                	push   $0x7a
  jmp alltraps
80106ccf:	e9 69 f5 ff ff       	jmp    8010623d <alltraps>

80106cd4 <vector123>:
.globl vector123
vector123:
  pushl $0
80106cd4:	6a 00                	push   $0x0
  pushl $123
80106cd6:	6a 7b                	push   $0x7b
  jmp alltraps
80106cd8:	e9 60 f5 ff ff       	jmp    8010623d <alltraps>

80106cdd <vector124>:
.globl vector124
vector124:
  pushl $0
80106cdd:	6a 00                	push   $0x0
  pushl $124
80106cdf:	6a 7c                	push   $0x7c
  jmp alltraps
80106ce1:	e9 57 f5 ff ff       	jmp    8010623d <alltraps>

80106ce6 <vector125>:
.globl vector125
vector125:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $125
80106ce8:	6a 7d                	push   $0x7d
  jmp alltraps
80106cea:	e9 4e f5 ff ff       	jmp    8010623d <alltraps>

80106cef <vector126>:
.globl vector126
vector126:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $126
80106cf1:	6a 7e                	push   $0x7e
  jmp alltraps
80106cf3:	e9 45 f5 ff ff       	jmp    8010623d <alltraps>

80106cf8 <vector127>:
.globl vector127
vector127:
  pushl $0
80106cf8:	6a 00                	push   $0x0
  pushl $127
80106cfa:	6a 7f                	push   $0x7f
  jmp alltraps
80106cfc:	e9 3c f5 ff ff       	jmp    8010623d <alltraps>

80106d01 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d01:	6a 00                	push   $0x0
  pushl $128
80106d03:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d08:	e9 30 f5 ff ff       	jmp    8010623d <alltraps>

80106d0d <vector129>:
.globl vector129
vector129:
  pushl $0
80106d0d:	6a 00                	push   $0x0
  pushl $129
80106d0f:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d14:	e9 24 f5 ff ff       	jmp    8010623d <alltraps>

80106d19 <vector130>:
.globl vector130
vector130:
  pushl $0
80106d19:	6a 00                	push   $0x0
  pushl $130
80106d1b:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d20:	e9 18 f5 ff ff       	jmp    8010623d <alltraps>

80106d25 <vector131>:
.globl vector131
vector131:
  pushl $0
80106d25:	6a 00                	push   $0x0
  pushl $131
80106d27:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d2c:	e9 0c f5 ff ff       	jmp    8010623d <alltraps>

80106d31 <vector132>:
.globl vector132
vector132:
  pushl $0
80106d31:	6a 00                	push   $0x0
  pushl $132
80106d33:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d38:	e9 00 f5 ff ff       	jmp    8010623d <alltraps>

80106d3d <vector133>:
.globl vector133
vector133:
  pushl $0
80106d3d:	6a 00                	push   $0x0
  pushl $133
80106d3f:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d44:	e9 f4 f4 ff ff       	jmp    8010623d <alltraps>

80106d49 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d49:	6a 00                	push   $0x0
  pushl $134
80106d4b:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d50:	e9 e8 f4 ff ff       	jmp    8010623d <alltraps>

80106d55 <vector135>:
.globl vector135
vector135:
  pushl $0
80106d55:	6a 00                	push   $0x0
  pushl $135
80106d57:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106d5c:	e9 dc f4 ff ff       	jmp    8010623d <alltraps>

80106d61 <vector136>:
.globl vector136
vector136:
  pushl $0
80106d61:	6a 00                	push   $0x0
  pushl $136
80106d63:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106d68:	e9 d0 f4 ff ff       	jmp    8010623d <alltraps>

80106d6d <vector137>:
.globl vector137
vector137:
  pushl $0
80106d6d:	6a 00                	push   $0x0
  pushl $137
80106d6f:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106d74:	e9 c4 f4 ff ff       	jmp    8010623d <alltraps>

80106d79 <vector138>:
.globl vector138
vector138:
  pushl $0
80106d79:	6a 00                	push   $0x0
  pushl $138
80106d7b:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106d80:	e9 b8 f4 ff ff       	jmp    8010623d <alltraps>

80106d85 <vector139>:
.globl vector139
vector139:
  pushl $0
80106d85:	6a 00                	push   $0x0
  pushl $139
80106d87:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106d8c:	e9 ac f4 ff ff       	jmp    8010623d <alltraps>

80106d91 <vector140>:
.globl vector140
vector140:
  pushl $0
80106d91:	6a 00                	push   $0x0
  pushl $140
80106d93:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106d98:	e9 a0 f4 ff ff       	jmp    8010623d <alltraps>

80106d9d <vector141>:
.globl vector141
vector141:
  pushl $0
80106d9d:	6a 00                	push   $0x0
  pushl $141
80106d9f:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106da4:	e9 94 f4 ff ff       	jmp    8010623d <alltraps>

80106da9 <vector142>:
.globl vector142
vector142:
  pushl $0
80106da9:	6a 00                	push   $0x0
  pushl $142
80106dab:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106db0:	e9 88 f4 ff ff       	jmp    8010623d <alltraps>

80106db5 <vector143>:
.globl vector143
vector143:
  pushl $0
80106db5:	6a 00                	push   $0x0
  pushl $143
80106db7:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106dbc:	e9 7c f4 ff ff       	jmp    8010623d <alltraps>

80106dc1 <vector144>:
.globl vector144
vector144:
  pushl $0
80106dc1:	6a 00                	push   $0x0
  pushl $144
80106dc3:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106dc8:	e9 70 f4 ff ff       	jmp    8010623d <alltraps>

80106dcd <vector145>:
.globl vector145
vector145:
  pushl $0
80106dcd:	6a 00                	push   $0x0
  pushl $145
80106dcf:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106dd4:	e9 64 f4 ff ff       	jmp    8010623d <alltraps>

80106dd9 <vector146>:
.globl vector146
vector146:
  pushl $0
80106dd9:	6a 00                	push   $0x0
  pushl $146
80106ddb:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106de0:	e9 58 f4 ff ff       	jmp    8010623d <alltraps>

80106de5 <vector147>:
.globl vector147
vector147:
  pushl $0
80106de5:	6a 00                	push   $0x0
  pushl $147
80106de7:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106dec:	e9 4c f4 ff ff       	jmp    8010623d <alltraps>

80106df1 <vector148>:
.globl vector148
vector148:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $148
80106df3:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106df8:	e9 40 f4 ff ff       	jmp    8010623d <alltraps>

80106dfd <vector149>:
.globl vector149
vector149:
  pushl $0
80106dfd:	6a 00                	push   $0x0
  pushl $149
80106dff:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e04:	e9 34 f4 ff ff       	jmp    8010623d <alltraps>

80106e09 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $150
80106e0b:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e10:	e9 28 f4 ff ff       	jmp    8010623d <alltraps>

80106e15 <vector151>:
.globl vector151
vector151:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $151
80106e17:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e1c:	e9 1c f4 ff ff       	jmp    8010623d <alltraps>

80106e21 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e21:	6a 00                	push   $0x0
  pushl $152
80106e23:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e28:	e9 10 f4 ff ff       	jmp    8010623d <alltraps>

80106e2d <vector153>:
.globl vector153
vector153:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $153
80106e2f:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e34:	e9 04 f4 ff ff       	jmp    8010623d <alltraps>

80106e39 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e39:	6a 00                	push   $0x0
  pushl $154
80106e3b:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e40:	e9 f8 f3 ff ff       	jmp    8010623d <alltraps>

80106e45 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e45:	6a 00                	push   $0x0
  pushl $155
80106e47:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e4c:	e9 ec f3 ff ff       	jmp    8010623d <alltraps>

80106e51 <vector156>:
.globl vector156
vector156:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $156
80106e53:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106e58:	e9 e0 f3 ff ff       	jmp    8010623d <alltraps>

80106e5d <vector157>:
.globl vector157
vector157:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $157
80106e5f:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106e64:	e9 d4 f3 ff ff       	jmp    8010623d <alltraps>

80106e69 <vector158>:
.globl vector158
vector158:
  pushl $0
80106e69:	6a 00                	push   $0x0
  pushl $158
80106e6b:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106e70:	e9 c8 f3 ff ff       	jmp    8010623d <alltraps>

80106e75 <vector159>:
.globl vector159
vector159:
  pushl $0
80106e75:	6a 00                	push   $0x0
  pushl $159
80106e77:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106e7c:	e9 bc f3 ff ff       	jmp    8010623d <alltraps>

80106e81 <vector160>:
.globl vector160
vector160:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $160
80106e83:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106e88:	e9 b0 f3 ff ff       	jmp    8010623d <alltraps>

80106e8d <vector161>:
.globl vector161
vector161:
  pushl $0
80106e8d:	6a 00                	push   $0x0
  pushl $161
80106e8f:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106e94:	e9 a4 f3 ff ff       	jmp    8010623d <alltraps>

80106e99 <vector162>:
.globl vector162
vector162:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $162
80106e9b:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ea0:	e9 98 f3 ff ff       	jmp    8010623d <alltraps>

80106ea5 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $163
80106ea7:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106eac:	e9 8c f3 ff ff       	jmp    8010623d <alltraps>

80106eb1 <vector164>:
.globl vector164
vector164:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $164
80106eb3:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106eb8:	e9 80 f3 ff ff       	jmp    8010623d <alltraps>

80106ebd <vector165>:
.globl vector165
vector165:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $165
80106ebf:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106ec4:	e9 74 f3 ff ff       	jmp    8010623d <alltraps>

80106ec9 <vector166>:
.globl vector166
vector166:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $166
80106ecb:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106ed0:	e9 68 f3 ff ff       	jmp    8010623d <alltraps>

80106ed5 <vector167>:
.globl vector167
vector167:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $167
80106ed7:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106edc:	e9 5c f3 ff ff       	jmp    8010623d <alltraps>

80106ee1 <vector168>:
.globl vector168
vector168:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $168
80106ee3:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106ee8:	e9 50 f3 ff ff       	jmp    8010623d <alltraps>

80106eed <vector169>:
.globl vector169
vector169:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $169
80106eef:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106ef4:	e9 44 f3 ff ff       	jmp    8010623d <alltraps>

80106ef9 <vector170>:
.globl vector170
vector170:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $170
80106efb:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f00:	e9 38 f3 ff ff       	jmp    8010623d <alltraps>

80106f05 <vector171>:
.globl vector171
vector171:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $171
80106f07:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f0c:	e9 2c f3 ff ff       	jmp    8010623d <alltraps>

80106f11 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $172
80106f13:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f18:	e9 20 f3 ff ff       	jmp    8010623d <alltraps>

80106f1d <vector173>:
.globl vector173
vector173:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $173
80106f1f:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f24:	e9 14 f3 ff ff       	jmp    8010623d <alltraps>

80106f29 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $174
80106f2b:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f30:	e9 08 f3 ff ff       	jmp    8010623d <alltraps>

80106f35 <vector175>:
.globl vector175
vector175:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $175
80106f37:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f3c:	e9 fc f2 ff ff       	jmp    8010623d <alltraps>

80106f41 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $176
80106f43:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f48:	e9 f0 f2 ff ff       	jmp    8010623d <alltraps>

80106f4d <vector177>:
.globl vector177
vector177:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $177
80106f4f:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f54:	e9 e4 f2 ff ff       	jmp    8010623d <alltraps>

80106f59 <vector178>:
.globl vector178
vector178:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $178
80106f5b:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106f60:	e9 d8 f2 ff ff       	jmp    8010623d <alltraps>

80106f65 <vector179>:
.globl vector179
vector179:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $179
80106f67:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106f6c:	e9 cc f2 ff ff       	jmp    8010623d <alltraps>

80106f71 <vector180>:
.globl vector180
vector180:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $180
80106f73:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106f78:	e9 c0 f2 ff ff       	jmp    8010623d <alltraps>

80106f7d <vector181>:
.globl vector181
vector181:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $181
80106f7f:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106f84:	e9 b4 f2 ff ff       	jmp    8010623d <alltraps>

80106f89 <vector182>:
.globl vector182
vector182:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $182
80106f8b:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106f90:	e9 a8 f2 ff ff       	jmp    8010623d <alltraps>

80106f95 <vector183>:
.globl vector183
vector183:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $183
80106f97:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106f9c:	e9 9c f2 ff ff       	jmp    8010623d <alltraps>

80106fa1 <vector184>:
.globl vector184
vector184:
  pushl $0
80106fa1:	6a 00                	push   $0x0
  pushl $184
80106fa3:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106fa8:	e9 90 f2 ff ff       	jmp    8010623d <alltraps>

80106fad <vector185>:
.globl vector185
vector185:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $185
80106faf:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106fb4:	e9 84 f2 ff ff       	jmp    8010623d <alltraps>

80106fb9 <vector186>:
.globl vector186
vector186:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $186
80106fbb:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106fc0:	e9 78 f2 ff ff       	jmp    8010623d <alltraps>

80106fc5 <vector187>:
.globl vector187
vector187:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $187
80106fc7:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106fcc:	e9 6c f2 ff ff       	jmp    8010623d <alltraps>

80106fd1 <vector188>:
.globl vector188
vector188:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $188
80106fd3:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106fd8:	e9 60 f2 ff ff       	jmp    8010623d <alltraps>

80106fdd <vector189>:
.globl vector189
vector189:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $189
80106fdf:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106fe4:	e9 54 f2 ff ff       	jmp    8010623d <alltraps>

80106fe9 <vector190>:
.globl vector190
vector190:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $190
80106feb:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106ff0:	e9 48 f2 ff ff       	jmp    8010623d <alltraps>

80106ff5 <vector191>:
.globl vector191
vector191:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $191
80106ff7:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106ffc:	e9 3c f2 ff ff       	jmp    8010623d <alltraps>

80107001 <vector192>:
.globl vector192
vector192:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $192
80107003:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107008:	e9 30 f2 ff ff       	jmp    8010623d <alltraps>

8010700d <vector193>:
.globl vector193
vector193:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $193
8010700f:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107014:	e9 24 f2 ff ff       	jmp    8010623d <alltraps>

80107019 <vector194>:
.globl vector194
vector194:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $194
8010701b:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107020:	e9 18 f2 ff ff       	jmp    8010623d <alltraps>

80107025 <vector195>:
.globl vector195
vector195:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $195
80107027:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010702c:	e9 0c f2 ff ff       	jmp    8010623d <alltraps>

80107031 <vector196>:
.globl vector196
vector196:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $196
80107033:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107038:	e9 00 f2 ff ff       	jmp    8010623d <alltraps>

8010703d <vector197>:
.globl vector197
vector197:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $197
8010703f:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107044:	e9 f4 f1 ff ff       	jmp    8010623d <alltraps>

80107049 <vector198>:
.globl vector198
vector198:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $198
8010704b:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107050:	e9 e8 f1 ff ff       	jmp    8010623d <alltraps>

80107055 <vector199>:
.globl vector199
vector199:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $199
80107057:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010705c:	e9 dc f1 ff ff       	jmp    8010623d <alltraps>

80107061 <vector200>:
.globl vector200
vector200:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $200
80107063:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107068:	e9 d0 f1 ff ff       	jmp    8010623d <alltraps>

8010706d <vector201>:
.globl vector201
vector201:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $201
8010706f:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107074:	e9 c4 f1 ff ff       	jmp    8010623d <alltraps>

80107079 <vector202>:
.globl vector202
vector202:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $202
8010707b:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107080:	e9 b8 f1 ff ff       	jmp    8010623d <alltraps>

80107085 <vector203>:
.globl vector203
vector203:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $203
80107087:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010708c:	e9 ac f1 ff ff       	jmp    8010623d <alltraps>

80107091 <vector204>:
.globl vector204
vector204:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $204
80107093:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107098:	e9 a0 f1 ff ff       	jmp    8010623d <alltraps>

8010709d <vector205>:
.globl vector205
vector205:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $205
8010709f:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070a4:	e9 94 f1 ff ff       	jmp    8010623d <alltraps>

801070a9 <vector206>:
.globl vector206
vector206:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $206
801070ab:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070b0:	e9 88 f1 ff ff       	jmp    8010623d <alltraps>

801070b5 <vector207>:
.globl vector207
vector207:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $207
801070b7:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801070bc:	e9 7c f1 ff ff       	jmp    8010623d <alltraps>

801070c1 <vector208>:
.globl vector208
vector208:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $208
801070c3:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801070c8:	e9 70 f1 ff ff       	jmp    8010623d <alltraps>

801070cd <vector209>:
.globl vector209
vector209:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $209
801070cf:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801070d4:	e9 64 f1 ff ff       	jmp    8010623d <alltraps>

801070d9 <vector210>:
.globl vector210
vector210:
  pushl $0
801070d9:	6a 00                	push   $0x0
  pushl $210
801070db:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801070e0:	e9 58 f1 ff ff       	jmp    8010623d <alltraps>

801070e5 <vector211>:
.globl vector211
vector211:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $211
801070e7:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801070ec:	e9 4c f1 ff ff       	jmp    8010623d <alltraps>

801070f1 <vector212>:
.globl vector212
vector212:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $212
801070f3:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801070f8:	e9 40 f1 ff ff       	jmp    8010623d <alltraps>

801070fd <vector213>:
.globl vector213
vector213:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $213
801070ff:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107104:	e9 34 f1 ff ff       	jmp    8010623d <alltraps>

80107109 <vector214>:
.globl vector214
vector214:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $214
8010710b:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107110:	e9 28 f1 ff ff       	jmp    8010623d <alltraps>

80107115 <vector215>:
.globl vector215
vector215:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $215
80107117:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010711c:	e9 1c f1 ff ff       	jmp    8010623d <alltraps>

80107121 <vector216>:
.globl vector216
vector216:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $216
80107123:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107128:	e9 10 f1 ff ff       	jmp    8010623d <alltraps>

8010712d <vector217>:
.globl vector217
vector217:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $217
8010712f:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107134:	e9 04 f1 ff ff       	jmp    8010623d <alltraps>

80107139 <vector218>:
.globl vector218
vector218:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $218
8010713b:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107140:	e9 f8 f0 ff ff       	jmp    8010623d <alltraps>

80107145 <vector219>:
.globl vector219
vector219:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $219
80107147:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010714c:	e9 ec f0 ff ff       	jmp    8010623d <alltraps>

80107151 <vector220>:
.globl vector220
vector220:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $220
80107153:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107158:	e9 e0 f0 ff ff       	jmp    8010623d <alltraps>

8010715d <vector221>:
.globl vector221
vector221:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $221
8010715f:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107164:	e9 d4 f0 ff ff       	jmp    8010623d <alltraps>

80107169 <vector222>:
.globl vector222
vector222:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $222
8010716b:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107170:	e9 c8 f0 ff ff       	jmp    8010623d <alltraps>

80107175 <vector223>:
.globl vector223
vector223:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $223
80107177:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010717c:	e9 bc f0 ff ff       	jmp    8010623d <alltraps>

80107181 <vector224>:
.globl vector224
vector224:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $224
80107183:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107188:	e9 b0 f0 ff ff       	jmp    8010623d <alltraps>

8010718d <vector225>:
.globl vector225
vector225:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $225
8010718f:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107194:	e9 a4 f0 ff ff       	jmp    8010623d <alltraps>

80107199 <vector226>:
.globl vector226
vector226:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $226
8010719b:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801071a0:	e9 98 f0 ff ff       	jmp    8010623d <alltraps>

801071a5 <vector227>:
.globl vector227
vector227:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $227
801071a7:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071ac:	e9 8c f0 ff ff       	jmp    8010623d <alltraps>

801071b1 <vector228>:
.globl vector228
vector228:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $228
801071b3:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801071b8:	e9 80 f0 ff ff       	jmp    8010623d <alltraps>

801071bd <vector229>:
.globl vector229
vector229:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $229
801071bf:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801071c4:	e9 74 f0 ff ff       	jmp    8010623d <alltraps>

801071c9 <vector230>:
.globl vector230
vector230:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $230
801071cb:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801071d0:	e9 68 f0 ff ff       	jmp    8010623d <alltraps>

801071d5 <vector231>:
.globl vector231
vector231:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $231
801071d7:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801071dc:	e9 5c f0 ff ff       	jmp    8010623d <alltraps>

801071e1 <vector232>:
.globl vector232
vector232:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $232
801071e3:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801071e8:	e9 50 f0 ff ff       	jmp    8010623d <alltraps>

801071ed <vector233>:
.globl vector233
vector233:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $233
801071ef:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801071f4:	e9 44 f0 ff ff       	jmp    8010623d <alltraps>

801071f9 <vector234>:
.globl vector234
vector234:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $234
801071fb:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107200:	e9 38 f0 ff ff       	jmp    8010623d <alltraps>

80107205 <vector235>:
.globl vector235
vector235:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $235
80107207:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010720c:	e9 2c f0 ff ff       	jmp    8010623d <alltraps>

80107211 <vector236>:
.globl vector236
vector236:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $236
80107213:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107218:	e9 20 f0 ff ff       	jmp    8010623d <alltraps>

8010721d <vector237>:
.globl vector237
vector237:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $237
8010721f:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107224:	e9 14 f0 ff ff       	jmp    8010623d <alltraps>

80107229 <vector238>:
.globl vector238
vector238:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $238
8010722b:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107230:	e9 08 f0 ff ff       	jmp    8010623d <alltraps>

80107235 <vector239>:
.globl vector239
vector239:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $239
80107237:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010723c:	e9 fc ef ff ff       	jmp    8010623d <alltraps>

80107241 <vector240>:
.globl vector240
vector240:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $240
80107243:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107248:	e9 f0 ef ff ff       	jmp    8010623d <alltraps>

8010724d <vector241>:
.globl vector241
vector241:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $241
8010724f:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107254:	e9 e4 ef ff ff       	jmp    8010623d <alltraps>

80107259 <vector242>:
.globl vector242
vector242:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $242
8010725b:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107260:	e9 d8 ef ff ff       	jmp    8010623d <alltraps>

80107265 <vector243>:
.globl vector243
vector243:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $243
80107267:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010726c:	e9 cc ef ff ff       	jmp    8010623d <alltraps>

80107271 <vector244>:
.globl vector244
vector244:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $244
80107273:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107278:	e9 c0 ef ff ff       	jmp    8010623d <alltraps>

8010727d <vector245>:
.globl vector245
vector245:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $245
8010727f:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107284:	e9 b4 ef ff ff       	jmp    8010623d <alltraps>

80107289 <vector246>:
.globl vector246
vector246:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $246
8010728b:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107290:	e9 a8 ef ff ff       	jmp    8010623d <alltraps>

80107295 <vector247>:
.globl vector247
vector247:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $247
80107297:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010729c:	e9 9c ef ff ff       	jmp    8010623d <alltraps>

801072a1 <vector248>:
.globl vector248
vector248:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $248
801072a3:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072a8:	e9 90 ef ff ff       	jmp    8010623d <alltraps>

801072ad <vector249>:
.globl vector249
vector249:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $249
801072af:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072b4:	e9 84 ef ff ff       	jmp    8010623d <alltraps>

801072b9 <vector250>:
.globl vector250
vector250:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $250
801072bb:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801072c0:	e9 78 ef ff ff       	jmp    8010623d <alltraps>

801072c5 <vector251>:
.globl vector251
vector251:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $251
801072c7:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801072cc:	e9 6c ef ff ff       	jmp    8010623d <alltraps>

801072d1 <vector252>:
.globl vector252
vector252:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $252
801072d3:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801072d8:	e9 60 ef ff ff       	jmp    8010623d <alltraps>

801072dd <vector253>:
.globl vector253
vector253:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $253
801072df:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801072e4:	e9 54 ef ff ff       	jmp    8010623d <alltraps>

801072e9 <vector254>:
.globl vector254
vector254:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $254
801072eb:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801072f0:	e9 48 ef ff ff       	jmp    8010623d <alltraps>

801072f5 <vector255>:
.globl vector255
vector255:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $255
801072f7:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801072fc:	e9 3c ef ff ff       	jmp    8010623d <alltraps>

80107301 <lgdt>:
{
80107301:	55                   	push   %ebp
80107302:	89 e5                	mov    %esp,%ebp
80107304:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107307:	8b 45 0c             	mov    0xc(%ebp),%eax
8010730a:	83 e8 01             	sub    $0x1,%eax
8010730d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107311:	8b 45 08             	mov    0x8(%ebp),%eax
80107314:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107318:	8b 45 08             	mov    0x8(%ebp),%eax
8010731b:	c1 e8 10             	shr    $0x10,%eax
8010731e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107322:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107325:	0f 01 10             	lgdtl  (%eax)
}
80107328:	90                   	nop
80107329:	c9                   	leave  
8010732a:	c3                   	ret    

8010732b <ltr>:
{
8010732b:	55                   	push   %ebp
8010732c:	89 e5                	mov    %esp,%ebp
8010732e:	83 ec 04             	sub    $0x4,%esp
80107331:	8b 45 08             	mov    0x8(%ebp),%eax
80107334:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107338:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010733c:	0f 00 d8             	ltr    %ax
}
8010733f:	90                   	nop
80107340:	c9                   	leave  
80107341:	c3                   	ret    

80107342 <lcr3>:

static inline void
lcr3(uint val)
{
80107342:	55                   	push   %ebp
80107343:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107345:	8b 45 08             	mov    0x8(%ebp),%eax
80107348:	0f 22 d8             	mov    %eax,%cr3
}
8010734b:	90                   	nop
8010734c:	5d                   	pop    %ebp
8010734d:	c3                   	ret    

8010734e <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010734e:	f3 0f 1e fb          	endbr32 
80107352:	55                   	push   %ebp
80107353:	89 e5                	mov    %esp,%ebp
80107355:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107358:	e8 b1 c7 ff ff       	call   80103b0e <cpuid>
8010735d:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107363:	05 c0 7d 19 80       	add    $0x80197dc0,%eax
80107368:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010736b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010736e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107377:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010737d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107380:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107387:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010738b:	83 e2 f0             	and    $0xfffffff0,%edx
8010738e:	83 ca 0a             	or     $0xa,%edx
80107391:	88 50 7d             	mov    %dl,0x7d(%eax)
80107394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107397:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010739b:	83 ca 10             	or     $0x10,%edx
8010739e:	88 50 7d             	mov    %dl,0x7d(%eax)
801073a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073a8:	83 e2 9f             	and    $0xffffff9f,%edx
801073ab:	88 50 7d             	mov    %dl,0x7d(%eax)
801073ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073b5:	83 ca 80             	or     $0xffffff80,%edx
801073b8:	88 50 7d             	mov    %dl,0x7d(%eax)
801073bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073be:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073c2:	83 ca 0f             	or     $0xf,%edx
801073c5:	88 50 7e             	mov    %dl,0x7e(%eax)
801073c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073cf:	83 e2 ef             	and    $0xffffffef,%edx
801073d2:	88 50 7e             	mov    %dl,0x7e(%eax)
801073d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073dc:	83 e2 df             	and    $0xffffffdf,%edx
801073df:	88 50 7e             	mov    %dl,0x7e(%eax)
801073e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073e9:	83 ca 40             	or     $0x40,%edx
801073ec:	88 50 7e             	mov    %dl,0x7e(%eax)
801073ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801073f6:	83 ca 80             	or     $0xffffff80,%edx
801073f9:	88 50 7e             	mov    %dl,0x7e(%eax)
801073fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ff:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107406:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010740d:	ff ff 
8010740f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107412:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107419:	00 00 
8010741b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107428:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010742f:	83 e2 f0             	and    $0xfffffff0,%edx
80107432:	83 ca 02             	or     $0x2,%edx
80107435:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010743b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107445:	83 ca 10             	or     $0x10,%edx
80107448:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010744e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107451:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107458:	83 e2 9f             	and    $0xffffff9f,%edx
8010745b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107464:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010746b:	83 ca 80             	or     $0xffffff80,%edx
8010746e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107477:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010747e:	83 ca 0f             	or     $0xf,%edx
80107481:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107491:	83 e2 ef             	and    $0xffffffef,%edx
80107494:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010749a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074a4:	83 e2 df             	and    $0xffffffdf,%edx
801074a7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074b7:	83 ca 40             	or     $0x40,%edx
801074ba:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074ca:	83 ca 80             	or     $0xffffff80,%edx
801074cd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801074dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e0:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801074e7:	ff ff 
801074e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ec:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801074f3:	00 00 
801074f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f8:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801074ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107502:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107509:	83 e2 f0             	and    $0xfffffff0,%edx
8010750c:	83 ca 0a             	or     $0xa,%edx
8010750f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107518:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010751f:	83 ca 10             	or     $0x10,%edx
80107522:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107528:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107532:	83 ca 60             	or     $0x60,%edx
80107535:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010753b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107545:	83 ca 80             	or     $0xffffff80,%edx
80107548:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010754e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107551:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107558:	83 ca 0f             	or     $0xf,%edx
8010755b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107564:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010756b:	83 e2 ef             	and    $0xffffffef,%edx
8010756e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107577:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010757e:	83 e2 df             	and    $0xffffffdf,%edx
80107581:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107591:	83 ca 40             	or     $0x40,%edx
80107594:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010759a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075a4:	83 ca 80             	or     $0xffffff80,%edx
801075a7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b0:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801075b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ba:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801075c1:	ff ff 
801075c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c6:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801075cd:	00 00 
801075cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d2:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801075d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075dc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075e3:	83 e2 f0             	and    $0xfffffff0,%edx
801075e6:	83 ca 02             	or     $0x2,%edx
801075e9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801075f9:	83 ca 10             	or     $0x10,%edx
801075fc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107605:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010760c:	83 ca 60             	or     $0x60,%edx
8010760f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107618:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010761f:	83 ca 80             	or     $0xffffff80,%edx
80107622:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107632:	83 ca 0f             	or     $0xf,%edx
80107635:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010763b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107645:	83 e2 ef             	and    $0xffffffef,%edx
80107648:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010764e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107651:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107658:	83 e2 df             	and    $0xffffffdf,%edx
8010765b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107664:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010766b:	83 ca 40             	or     $0x40,%edx
8010766e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107677:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010767e:	83 ca 80             	or     $0xffffff80,%edx
80107681:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768a:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107694:	83 c0 70             	add    $0x70,%eax
80107697:	83 ec 08             	sub    $0x8,%esp
8010769a:	6a 30                	push   $0x30
8010769c:	50                   	push   %eax
8010769d:	e8 5f fc ff ff       	call   80107301 <lgdt>
801076a2:	83 c4 10             	add    $0x10,%esp
}
801076a5:	90                   	nop
801076a6:	c9                   	leave  
801076a7:	c3                   	ret    

801076a8 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801076a8:	f3 0f 1e fb          	endbr32 
801076ac:	55                   	push   %ebp
801076ad:	89 e5                	mov    %esp,%ebp
801076af:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801076b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801076b5:	c1 e8 16             	shr    $0x16,%eax
801076b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076bf:	8b 45 08             	mov    0x8(%ebp),%eax
801076c2:	01 d0                	add    %edx,%eax
801076c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801076c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076ca:	8b 00                	mov    (%eax),%eax
801076cc:	83 e0 01             	and    $0x1,%eax
801076cf:	85 c0                	test   %eax,%eax
801076d1:	74 14                	je     801076e7 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801076d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076d6:	8b 00                	mov    (%eax),%eax
801076d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076dd:	05 00 00 00 80       	add    $0x80000000,%eax
801076e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076e5:	eb 42                	jmp    80107729 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801076e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801076eb:	74 0e                	je     801076fb <walkpgdir+0x53>
801076ed:	e8 a0 b1 ff ff       	call   80102892 <kalloc>
801076f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801076f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801076f9:	75 07                	jne    80107702 <walkpgdir+0x5a>
      return 0;
801076fb:	b8 00 00 00 00       	mov    $0x0,%eax
80107700:	eb 3e                	jmp    80107740 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107702:	83 ec 04             	sub    $0x4,%esp
80107705:	68 00 10 00 00       	push   $0x1000
8010770a:	6a 00                	push   $0x0
8010770c:	ff 75 f4             	pushl  -0xc(%ebp)
8010770f:	e8 a6 d6 ff ff       	call   80104dba <memset>
80107714:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771a:	05 00 00 00 80       	add    $0x80000000,%eax
8010771f:	83 c8 07             	or     $0x7,%eax
80107722:	89 c2                	mov    %eax,%edx
80107724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107727:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107729:	8b 45 0c             	mov    0xc(%ebp),%eax
8010772c:	c1 e8 0c             	shr    $0xc,%eax
8010772f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107734:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010773b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773e:	01 d0                	add    %edx,%eax
}
80107740:	c9                   	leave  
80107741:	c3                   	ret    

80107742 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107742:	f3 0f 1e fb          	endbr32 
80107746:	55                   	push   %ebp
80107747:	89 e5                	mov    %esp,%ebp
80107749:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010774c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010774f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107754:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107757:	8b 55 0c             	mov    0xc(%ebp),%edx
8010775a:	8b 45 10             	mov    0x10(%ebp),%eax
8010775d:	01 d0                	add    %edx,%eax
8010775f:	83 e8 01             	sub    $0x1,%eax
80107762:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107767:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010776a:	83 ec 04             	sub    $0x4,%esp
8010776d:	6a 01                	push   $0x1
8010776f:	ff 75 f4             	pushl  -0xc(%ebp)
80107772:	ff 75 08             	pushl  0x8(%ebp)
80107775:	e8 2e ff ff ff       	call   801076a8 <walkpgdir>
8010777a:	83 c4 10             	add    $0x10,%esp
8010777d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107780:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107784:	75 07                	jne    8010778d <mappages+0x4b>
      return -1;
80107786:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010778b:	eb 47                	jmp    801077d4 <mappages+0x92>
    if(*pte & PTE_P)
8010778d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107790:	8b 00                	mov    (%eax),%eax
80107792:	83 e0 01             	and    $0x1,%eax
80107795:	85 c0                	test   %eax,%eax
80107797:	74 0d                	je     801077a6 <mappages+0x64>
      panic("remap");
80107799:	83 ec 0c             	sub    $0xc,%esp
8010779c:	68 88 ab 10 80       	push   $0x8010ab88
801077a1:	e8 1f 8e ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
801077a6:	8b 45 18             	mov    0x18(%ebp),%eax
801077a9:	0b 45 14             	or     0x14(%ebp),%eax
801077ac:	83 c8 01             	or     $0x1,%eax
801077af:	89 c2                	mov    %eax,%edx
801077b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077b4:	89 10                	mov    %edx,(%eax)
    if(a == last)
801077b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801077bc:	74 10                	je     801077ce <mappages+0x8c>
      break;
    a += PGSIZE;
801077be:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801077c5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077cc:	eb 9c                	jmp    8010776a <mappages+0x28>
      break;
801077ce:	90                   	nop
  }
  return 0;
801077cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077d4:	c9                   	leave  
801077d5:	c3                   	ret    

801077d6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801077d6:	f3 0f 1e fb          	endbr32 
801077da:	55                   	push   %ebp
801077db:	89 e5                	mov    %esp,%ebp
801077dd:	53                   	push   %ebx
801077de:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801077e1:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801077e8:	a1 8c 80 19 80       	mov    0x8019808c,%eax
801077ed:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801077f2:	29 c2                	sub    %eax,%edx
801077f4:	89 d0                	mov    %edx,%eax
801077f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801077f9:	a1 84 80 19 80       	mov    0x80198084,%eax
801077fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107801:	8b 15 84 80 19 80    	mov    0x80198084,%edx
80107807:	a1 8c 80 19 80       	mov    0x8019808c,%eax
8010780c:	01 d0                	add    %edx,%eax
8010780e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107811:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781b:	83 c0 30             	add    $0x30,%eax
8010781e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107821:	89 10                	mov    %edx,(%eax)
80107823:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107826:	89 50 04             	mov    %edx,0x4(%eax)
80107829:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010782c:	89 50 08             	mov    %edx,0x8(%eax)
8010782f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107832:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107835:	e8 58 b0 ff ff       	call   80102892 <kalloc>
8010783a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010783d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107841:	75 07                	jne    8010784a <setupkvm+0x74>
    return 0;
80107843:	b8 00 00 00 00       	mov    $0x0,%eax
80107848:	eb 78                	jmp    801078c2 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
8010784a:	83 ec 04             	sub    $0x4,%esp
8010784d:	68 00 10 00 00       	push   $0x1000
80107852:	6a 00                	push   $0x0
80107854:	ff 75 f0             	pushl  -0x10(%ebp)
80107857:	e8 5e d5 ff ff       	call   80104dba <memset>
8010785c:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010785f:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107866:	eb 4e                	jmp    801078b6 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010786e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107871:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107877:	8b 58 08             	mov    0x8(%eax),%ebx
8010787a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787d:	8b 40 04             	mov    0x4(%eax),%eax
80107880:	29 c3                	sub    %eax,%ebx
80107882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107885:	8b 00                	mov    (%eax),%eax
80107887:	83 ec 0c             	sub    $0xc,%esp
8010788a:	51                   	push   %ecx
8010788b:	52                   	push   %edx
8010788c:	53                   	push   %ebx
8010788d:	50                   	push   %eax
8010788e:	ff 75 f0             	pushl  -0x10(%ebp)
80107891:	e8 ac fe ff ff       	call   80107742 <mappages>
80107896:	83 c4 20             	add    $0x20,%esp
80107899:	85 c0                	test   %eax,%eax
8010789b:	79 15                	jns    801078b2 <setupkvm+0xdc>
      freevm(pgdir);
8010789d:	83 ec 0c             	sub    $0xc,%esp
801078a0:	ff 75 f0             	pushl  -0x10(%ebp)
801078a3:	e8 11 05 00 00       	call   80107db9 <freevm>
801078a8:	83 c4 10             	add    $0x10,%esp
      return 0;
801078ab:	b8 00 00 00 00       	mov    $0x0,%eax
801078b0:	eb 10                	jmp    801078c2 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078b2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801078b6:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801078bd:	72 a9                	jb     80107868 <setupkvm+0x92>
    }
  return pgdir;
801078bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801078c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801078c5:	c9                   	leave  
801078c6:	c3                   	ret    

801078c7 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801078c7:	f3 0f 1e fb          	endbr32 
801078cb:	55                   	push   %ebp
801078cc:	89 e5                	mov    %esp,%ebp
801078ce:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801078d1:	e8 00 ff ff ff       	call   801077d6 <setupkvm>
801078d6:	a3 84 7d 19 80       	mov    %eax,0x80197d84
  switchkvm();
801078db:	e8 03 00 00 00       	call   801078e3 <switchkvm>
}
801078e0:	90                   	nop
801078e1:	c9                   	leave  
801078e2:	c3                   	ret    

801078e3 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801078e3:	f3 0f 1e fb          	endbr32 
801078e7:	55                   	push   %ebp
801078e8:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078ea:	a1 84 7d 19 80       	mov    0x80197d84,%eax
801078ef:	05 00 00 00 80       	add    $0x80000000,%eax
801078f4:	50                   	push   %eax
801078f5:	e8 48 fa ff ff       	call   80107342 <lcr3>
801078fa:	83 c4 04             	add    $0x4,%esp
}
801078fd:	90                   	nop
801078fe:	c9                   	leave  
801078ff:	c3                   	ret    

80107900 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107900:	f3 0f 1e fb          	endbr32 
80107904:	55                   	push   %ebp
80107905:	89 e5                	mov    %esp,%ebp
80107907:	56                   	push   %esi
80107908:	53                   	push   %ebx
80107909:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010790c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107910:	75 0d                	jne    8010791f <switchuvm+0x1f>
    panic("switchuvm: no process");
80107912:	83 ec 0c             	sub    $0xc,%esp
80107915:	68 8e ab 10 80       	push   $0x8010ab8e
8010791a:	e8 a6 8c ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
8010791f:	8b 45 08             	mov    0x8(%ebp),%eax
80107922:	8b 40 08             	mov    0x8(%eax),%eax
80107925:	85 c0                	test   %eax,%eax
80107927:	75 0d                	jne    80107936 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107929:	83 ec 0c             	sub    $0xc,%esp
8010792c:	68 a4 ab 10 80       	push   $0x8010aba4
80107931:	e8 8f 8c ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
80107936:	8b 45 08             	mov    0x8(%ebp),%eax
80107939:	8b 40 04             	mov    0x4(%eax),%eax
8010793c:	85 c0                	test   %eax,%eax
8010793e:	75 0d                	jne    8010794d <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107940:	83 ec 0c             	sub    $0xc,%esp
80107943:	68 b9 ab 10 80       	push   $0x8010abb9
80107948:	e8 78 8c ff ff       	call   801005c5 <panic>

  pushcli();
8010794d:	e8 55 d3 ff ff       	call   80104ca7 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107952:	e8 d6 c1 ff ff       	call   80103b2d <mycpu>
80107957:	89 c3                	mov    %eax,%ebx
80107959:	e8 cf c1 ff ff       	call   80103b2d <mycpu>
8010795e:	83 c0 08             	add    $0x8,%eax
80107961:	89 c6                	mov    %eax,%esi
80107963:	e8 c5 c1 ff ff       	call   80103b2d <mycpu>
80107968:	83 c0 08             	add    $0x8,%eax
8010796b:	c1 e8 10             	shr    $0x10,%eax
8010796e:	88 45 f7             	mov    %al,-0x9(%ebp)
80107971:	e8 b7 c1 ff ff       	call   80103b2d <mycpu>
80107976:	83 c0 08             	add    $0x8,%eax
80107979:	c1 e8 18             	shr    $0x18,%eax
8010797c:	89 c2                	mov    %eax,%edx
8010797e:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107985:	67 00 
80107987:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010798e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107992:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107998:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010799f:	83 e0 f0             	and    $0xfffffff0,%eax
801079a2:	83 c8 09             	or     $0x9,%eax
801079a5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079ab:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079b2:	83 c8 10             	or     $0x10,%eax
801079b5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079bb:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079c2:	83 e0 9f             	and    $0xffffff9f,%eax
801079c5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079cb:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079d2:	83 c8 80             	or     $0xffffff80,%eax
801079d5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079db:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079e2:	83 e0 f0             	and    $0xfffffff0,%eax
801079e5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079eb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801079f2:	83 e0 ef             	and    $0xffffffef,%eax
801079f5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801079fb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a02:	83 e0 df             	and    $0xffffffdf,%eax
80107a05:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a0b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a12:	83 c8 40             	or     $0x40,%eax
80107a15:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a1b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a22:	83 e0 7f             	and    $0x7f,%eax
80107a25:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a2b:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a31:	e8 f7 c0 ff ff       	call   80103b2d <mycpu>
80107a36:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a3d:	83 e2 ef             	and    $0xffffffef,%edx
80107a40:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a46:	e8 e2 c0 ff ff       	call   80103b2d <mycpu>
80107a4b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a51:	8b 45 08             	mov    0x8(%ebp),%eax
80107a54:	8b 40 08             	mov    0x8(%eax),%eax
80107a57:	89 c3                	mov    %eax,%ebx
80107a59:	e8 cf c0 ff ff       	call   80103b2d <mycpu>
80107a5e:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a64:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a67:	e8 c1 c0 ff ff       	call   80103b2d <mycpu>
80107a6c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a72:	83 ec 0c             	sub    $0xc,%esp
80107a75:	6a 28                	push   $0x28
80107a77:	e8 af f8 ff ff       	call   8010732b <ltr>
80107a7c:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a82:	8b 40 04             	mov    0x4(%eax),%eax
80107a85:	05 00 00 00 80       	add    $0x80000000,%eax
80107a8a:	83 ec 0c             	sub    $0xc,%esp
80107a8d:	50                   	push   %eax
80107a8e:	e8 af f8 ff ff       	call   80107342 <lcr3>
80107a93:	83 c4 10             	add    $0x10,%esp
  popcli();
80107a96:	e8 5d d2 ff ff       	call   80104cf8 <popcli>
}
80107a9b:	90                   	nop
80107a9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107a9f:	5b                   	pop    %ebx
80107aa0:	5e                   	pop    %esi
80107aa1:	5d                   	pop    %ebp
80107aa2:	c3                   	ret    

80107aa3 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107aa3:	f3 0f 1e fb          	endbr32 
80107aa7:	55                   	push   %ebp
80107aa8:	89 e5                	mov    %esp,%ebp
80107aaa:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107aad:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107ab4:	76 0d                	jbe    80107ac3 <inituvm+0x20>
    panic("inituvm: more than a page");
80107ab6:	83 ec 0c             	sub    $0xc,%esp
80107ab9:	68 cd ab 10 80       	push   $0x8010abcd
80107abe:	e8 02 8b ff ff       	call   801005c5 <panic>
  mem = kalloc();
80107ac3:	e8 ca ad ff ff       	call   80102892 <kalloc>
80107ac8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107acb:	83 ec 04             	sub    $0x4,%esp
80107ace:	68 00 10 00 00       	push   $0x1000
80107ad3:	6a 00                	push   $0x0
80107ad5:	ff 75 f4             	pushl  -0xc(%ebp)
80107ad8:	e8 dd d2 ff ff       	call   80104dba <memset>
80107add:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae3:	05 00 00 00 80       	add    $0x80000000,%eax
80107ae8:	83 ec 0c             	sub    $0xc,%esp
80107aeb:	6a 06                	push   $0x6
80107aed:	50                   	push   %eax
80107aee:	68 00 10 00 00       	push   $0x1000
80107af3:	6a 00                	push   $0x0
80107af5:	ff 75 08             	pushl  0x8(%ebp)
80107af8:	e8 45 fc ff ff       	call   80107742 <mappages>
80107afd:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107b00:	83 ec 04             	sub    $0x4,%esp
80107b03:	ff 75 10             	pushl  0x10(%ebp)
80107b06:	ff 75 0c             	pushl  0xc(%ebp)
80107b09:	ff 75 f4             	pushl  -0xc(%ebp)
80107b0c:	e8 70 d3 ff ff       	call   80104e81 <memmove>
80107b11:	83 c4 10             	add    $0x10,%esp
}
80107b14:	90                   	nop
80107b15:	c9                   	leave  
80107b16:	c3                   	ret    

80107b17 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b17:	f3 0f 1e fb          	endbr32 
80107b1b:	55                   	push   %ebp
80107b1c:	89 e5                	mov    %esp,%ebp
80107b1e:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b21:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b24:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b29:	85 c0                	test   %eax,%eax
80107b2b:	74 0d                	je     80107b3a <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107b2d:	83 ec 0c             	sub    $0xc,%esp
80107b30:	68 e8 ab 10 80       	push   $0x8010abe8
80107b35:	e8 8b 8a ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b41:	e9 8f 00 00 00       	jmp    80107bd5 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b46:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	01 d0                	add    %edx,%eax
80107b4e:	83 ec 04             	sub    $0x4,%esp
80107b51:	6a 00                	push   $0x0
80107b53:	50                   	push   %eax
80107b54:	ff 75 08             	pushl  0x8(%ebp)
80107b57:	e8 4c fb ff ff       	call   801076a8 <walkpgdir>
80107b5c:	83 c4 10             	add    $0x10,%esp
80107b5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b62:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b66:	75 0d                	jne    80107b75 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107b68:	83 ec 0c             	sub    $0xc,%esp
80107b6b:	68 0b ac 10 80       	push   $0x8010ac0b
80107b70:	e8 50 8a ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107b75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b78:	8b 00                	mov    (%eax),%eax
80107b7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b7f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107b82:	8b 45 18             	mov    0x18(%ebp),%eax
80107b85:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b88:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107b8d:	77 0b                	ja     80107b9a <loaduvm+0x83>
      n = sz - i;
80107b8f:	8b 45 18             	mov    0x18(%ebp),%eax
80107b92:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107b95:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b98:	eb 07                	jmp    80107ba1 <loaduvm+0x8a>
    else
      n = PGSIZE;
80107b9a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107ba1:	8b 55 14             	mov    0x14(%ebp),%edx
80107ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba7:	01 d0                	add    %edx,%eax
80107ba9:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107bac:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107bb2:	ff 75 f0             	pushl  -0x10(%ebp)
80107bb5:	50                   	push   %eax
80107bb6:	52                   	push   %edx
80107bb7:	ff 75 10             	pushl  0x10(%ebp)
80107bba:	e8 c5 a3 ff ff       	call   80101f84 <readi>
80107bbf:	83 c4 10             	add    $0x10,%esp
80107bc2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107bc5:	74 07                	je     80107bce <loaduvm+0xb7>
      return -1;
80107bc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bcc:	eb 18                	jmp    80107be6 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107bce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd8:	3b 45 18             	cmp    0x18(%ebp),%eax
80107bdb:	0f 82 65 ff ff ff    	jb     80107b46 <loaduvm+0x2f>
  }
  return 0;
80107be1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107be6:	c9                   	leave  
80107be7:	c3                   	ret    

80107be8 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107be8:	f3 0f 1e fb          	endbr32 
80107bec:	55                   	push   %ebp
80107bed:	89 e5                	mov    %esp,%ebp
80107bef:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107bf2:	8b 45 10             	mov    0x10(%ebp),%eax
80107bf5:	85 c0                	test   %eax,%eax
80107bf7:	79 0a                	jns    80107c03 <allocuvm+0x1b>
    return 0;
80107bf9:	b8 00 00 00 00       	mov    $0x0,%eax
80107bfe:	e9 ec 00 00 00       	jmp    80107cef <allocuvm+0x107>
  if(newsz < oldsz)
80107c03:	8b 45 10             	mov    0x10(%ebp),%eax
80107c06:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c09:	73 08                	jae    80107c13 <allocuvm+0x2b>
    return oldsz;
80107c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c0e:	e9 dc 00 00 00       	jmp    80107cef <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107c13:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c16:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c20:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c23:	e9 b8 00 00 00       	jmp    80107ce0 <allocuvm+0xf8>
    mem = kalloc();
80107c28:	e8 65 ac ff ff       	call   80102892 <kalloc>
80107c2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c30:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c34:	75 2e                	jne    80107c64 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107c36:	83 ec 0c             	sub    $0xc,%esp
80107c39:	68 29 ac 10 80       	push   $0x8010ac29
80107c3e:	e8 c9 87 ff ff       	call   8010040c <cprintf>
80107c43:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c46:	83 ec 04             	sub    $0x4,%esp
80107c49:	ff 75 0c             	pushl  0xc(%ebp)
80107c4c:	ff 75 10             	pushl  0x10(%ebp)
80107c4f:	ff 75 08             	pushl  0x8(%ebp)
80107c52:	e8 9a 00 00 00       	call   80107cf1 <deallocuvm>
80107c57:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c5a:	b8 00 00 00 00       	mov    $0x0,%eax
80107c5f:	e9 8b 00 00 00       	jmp    80107cef <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107c64:	83 ec 04             	sub    $0x4,%esp
80107c67:	68 00 10 00 00       	push   $0x1000
80107c6c:	6a 00                	push   $0x0
80107c6e:	ff 75 f0             	pushl  -0x10(%ebp)
80107c71:	e8 44 d1 ff ff       	call   80104dba <memset>
80107c76:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c7c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c85:	83 ec 0c             	sub    $0xc,%esp
80107c88:	6a 06                	push   $0x6
80107c8a:	52                   	push   %edx
80107c8b:	68 00 10 00 00       	push   $0x1000
80107c90:	50                   	push   %eax
80107c91:	ff 75 08             	pushl  0x8(%ebp)
80107c94:	e8 a9 fa ff ff       	call   80107742 <mappages>
80107c99:	83 c4 20             	add    $0x20,%esp
80107c9c:	85 c0                	test   %eax,%eax
80107c9e:	79 39                	jns    80107cd9 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107ca0:	83 ec 0c             	sub    $0xc,%esp
80107ca3:	68 41 ac 10 80       	push   $0x8010ac41
80107ca8:	e8 5f 87 ff ff       	call   8010040c <cprintf>
80107cad:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107cb0:	83 ec 04             	sub    $0x4,%esp
80107cb3:	ff 75 0c             	pushl  0xc(%ebp)
80107cb6:	ff 75 10             	pushl  0x10(%ebp)
80107cb9:	ff 75 08             	pushl  0x8(%ebp)
80107cbc:	e8 30 00 00 00       	call   80107cf1 <deallocuvm>
80107cc1:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107cc4:	83 ec 0c             	sub    $0xc,%esp
80107cc7:	ff 75 f0             	pushl  -0x10(%ebp)
80107cca:	e8 25 ab ff ff       	call   801027f4 <kfree>
80107ccf:	83 c4 10             	add    $0x10,%esp
      return 0;
80107cd2:	b8 00 00 00 00       	mov    $0x0,%eax
80107cd7:	eb 16                	jmp    80107cef <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107cd9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce3:	3b 45 10             	cmp    0x10(%ebp),%eax
80107ce6:	0f 82 3c ff ff ff    	jb     80107c28 <allocuvm+0x40>
    }
  }
  return newsz;
80107cec:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107cef:	c9                   	leave  
80107cf0:	c3                   	ret    

80107cf1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107cf1:	f3 0f 1e fb          	endbr32 
80107cf5:	55                   	push   %ebp
80107cf6:	89 e5                	mov    %esp,%ebp
80107cf8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107cfb:	8b 45 10             	mov    0x10(%ebp),%eax
80107cfe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d01:	72 08                	jb     80107d0b <deallocuvm+0x1a>
    return oldsz;
80107d03:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d06:	e9 ac 00 00 00       	jmp    80107db7 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107d0b:	8b 45 10             	mov    0x10(%ebp),%eax
80107d0e:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d1b:	e9 88 00 00 00       	jmp    80107da8 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d23:	83 ec 04             	sub    $0x4,%esp
80107d26:	6a 00                	push   $0x0
80107d28:	50                   	push   %eax
80107d29:	ff 75 08             	pushl  0x8(%ebp)
80107d2c:	e8 77 f9 ff ff       	call   801076a8 <walkpgdir>
80107d31:	83 c4 10             	add    $0x10,%esp
80107d34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d3b:	75 16                	jne    80107d53 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d40:	c1 e8 16             	shr    $0x16,%eax
80107d43:	83 c0 01             	add    $0x1,%eax
80107d46:	c1 e0 16             	shl    $0x16,%eax
80107d49:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d51:	eb 4e                	jmp    80107da1 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d56:	8b 00                	mov    (%eax),%eax
80107d58:	83 e0 01             	and    $0x1,%eax
80107d5b:	85 c0                	test   %eax,%eax
80107d5d:	74 42                	je     80107da1 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d62:	8b 00                	mov    (%eax),%eax
80107d64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d69:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d70:	75 0d                	jne    80107d7f <deallocuvm+0x8e>
        panic("kfree");
80107d72:	83 ec 0c             	sub    $0xc,%esp
80107d75:	68 5d ac 10 80       	push   $0x8010ac5d
80107d7a:	e8 46 88 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80107d7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d82:	05 00 00 00 80       	add    $0x80000000,%eax
80107d87:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107d8a:	83 ec 0c             	sub    $0xc,%esp
80107d8d:	ff 75 e8             	pushl  -0x18(%ebp)
80107d90:	e8 5f aa ff ff       	call   801027f4 <kfree>
80107d95:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d9b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107da1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dab:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107dae:	0f 82 6c ff ff ff    	jb     80107d20 <deallocuvm+0x2f>
    }
  }
  return newsz;
80107db4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107db7:	c9                   	leave  
80107db8:	c3                   	ret    

80107db9 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107db9:	f3 0f 1e fb          	endbr32 
80107dbd:	55                   	push   %ebp
80107dbe:	89 e5                	mov    %esp,%ebp
80107dc0:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107dc3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107dc7:	75 0d                	jne    80107dd6 <freevm+0x1d>
    panic("freevm: no pgdir");
80107dc9:	83 ec 0c             	sub    $0xc,%esp
80107dcc:	68 63 ac 10 80       	push   $0x8010ac63
80107dd1:	e8 ef 87 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107dd6:	83 ec 04             	sub    $0x4,%esp
80107dd9:	6a 00                	push   $0x0
80107ddb:	68 00 00 00 80       	push   $0x80000000
80107de0:	ff 75 08             	pushl  0x8(%ebp)
80107de3:	e8 09 ff ff ff       	call   80107cf1 <deallocuvm>
80107de8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107deb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107df2:	eb 48                	jmp    80107e3c <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80107e01:	01 d0                	add    %edx,%eax
80107e03:	8b 00                	mov    (%eax),%eax
80107e05:	83 e0 01             	and    $0x1,%eax
80107e08:	85 c0                	test   %eax,%eax
80107e0a:	74 2c                	je     80107e38 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e16:	8b 45 08             	mov    0x8(%ebp),%eax
80107e19:	01 d0                	add    %edx,%eax
80107e1b:	8b 00                	mov    (%eax),%eax
80107e1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e22:	05 00 00 00 80       	add    $0x80000000,%eax
80107e27:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e2a:	83 ec 0c             	sub    $0xc,%esp
80107e2d:	ff 75 f0             	pushl  -0x10(%ebp)
80107e30:	e8 bf a9 ff ff       	call   801027f4 <kfree>
80107e35:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e38:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e3c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e43:	76 af                	jbe    80107df4 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107e45:	83 ec 0c             	sub    $0xc,%esp
80107e48:	ff 75 08             	pushl  0x8(%ebp)
80107e4b:	e8 a4 a9 ff ff       	call   801027f4 <kfree>
80107e50:	83 c4 10             	add    $0x10,%esp
}
80107e53:	90                   	nop
80107e54:	c9                   	leave  
80107e55:	c3                   	ret    

80107e56 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e56:	f3 0f 1e fb          	endbr32 
80107e5a:	55                   	push   %ebp
80107e5b:	89 e5                	mov    %esp,%ebp
80107e5d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e60:	83 ec 04             	sub    $0x4,%esp
80107e63:	6a 00                	push   $0x0
80107e65:	ff 75 0c             	pushl  0xc(%ebp)
80107e68:	ff 75 08             	pushl  0x8(%ebp)
80107e6b:	e8 38 f8 ff ff       	call   801076a8 <walkpgdir>
80107e70:	83 c4 10             	add    $0x10,%esp
80107e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e7a:	75 0d                	jne    80107e89 <clearpteu+0x33>
    panic("clearpteu");
80107e7c:	83 ec 0c             	sub    $0xc,%esp
80107e7f:	68 74 ac 10 80       	push   $0x8010ac74
80107e84:	e8 3c 87 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80107e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8c:	8b 00                	mov    (%eax),%eax
80107e8e:	83 e0 fb             	and    $0xfffffffb,%eax
80107e91:	89 c2                	mov    %eax,%edx
80107e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e96:	89 10                	mov    %edx,(%eax)
}
80107e98:	90                   	nop
80107e99:	c9                   	leave  
80107e9a:	c3                   	ret    

80107e9b <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e9b:	f3 0f 1e fb          	endbr32 
80107e9f:	55                   	push   %ebp
80107ea0:	89 e5                	mov    %esp,%ebp
80107ea2:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107ea5:	e8 2c f9 ff ff       	call   801077d6 <setupkvm>
80107eaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ead:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107eb1:	75 0a                	jne    80107ebd <copyuvm+0x22>
    return 0;
80107eb3:	b8 00 00 00 00       	mov    $0x0,%eax
80107eb8:	e9 eb 00 00 00       	jmp    80107fa8 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80107ebd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ec4:	e9 b7 00 00 00       	jmp    80107f80 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecc:	83 ec 04             	sub    $0x4,%esp
80107ecf:	6a 00                	push   $0x0
80107ed1:	50                   	push   %eax
80107ed2:	ff 75 08             	pushl  0x8(%ebp)
80107ed5:	e8 ce f7 ff ff       	call   801076a8 <walkpgdir>
80107eda:	83 c4 10             	add    $0x10,%esp
80107edd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ee0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ee4:	75 0d                	jne    80107ef3 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80107ee6:	83 ec 0c             	sub    $0xc,%esp
80107ee9:	68 7e ac 10 80       	push   $0x8010ac7e
80107eee:	e8 d2 86 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80107ef3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ef6:	8b 00                	mov    (%eax),%eax
80107ef8:	83 e0 01             	and    $0x1,%eax
80107efb:	85 c0                	test   %eax,%eax
80107efd:	75 0d                	jne    80107f0c <copyuvm+0x71>
      panic("copyuvm: page not present");
80107eff:	83 ec 0c             	sub    $0xc,%esp
80107f02:	68 98 ac 10 80       	push   $0x8010ac98
80107f07:	e8 b9 86 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107f0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f0f:	8b 00                	mov    (%eax),%eax
80107f11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f16:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107f19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f1c:	8b 00                	mov    (%eax),%eax
80107f1e:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107f26:	e8 67 a9 ff ff       	call   80102892 <kalloc>
80107f2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f2e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f32:	74 5d                	je     80107f91 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f37:	05 00 00 00 80       	add    $0x80000000,%eax
80107f3c:	83 ec 04             	sub    $0x4,%esp
80107f3f:	68 00 10 00 00       	push   $0x1000
80107f44:	50                   	push   %eax
80107f45:	ff 75 e0             	pushl  -0x20(%ebp)
80107f48:	e8 34 cf ff ff       	call   80104e81 <memmove>
80107f4d:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107f50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f56:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5f:	83 ec 0c             	sub    $0xc,%esp
80107f62:	52                   	push   %edx
80107f63:	51                   	push   %ecx
80107f64:	68 00 10 00 00       	push   $0x1000
80107f69:	50                   	push   %eax
80107f6a:	ff 75 f0             	pushl  -0x10(%ebp)
80107f6d:	e8 d0 f7 ff ff       	call   80107742 <mappages>
80107f72:	83 c4 20             	add    $0x20,%esp
80107f75:	85 c0                	test   %eax,%eax
80107f77:	78 1b                	js     80107f94 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80107f79:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f83:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f86:	0f 82 3d ff ff ff    	jb     80107ec9 <copyuvm+0x2e>
      goto bad;
  }
  return d;
80107f8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f8f:	eb 17                	jmp    80107fa8 <copyuvm+0x10d>
      goto bad;
80107f91:	90                   	nop
80107f92:	eb 01                	jmp    80107f95 <copyuvm+0xfa>
      goto bad;
80107f94:	90                   	nop

bad:
  freevm(d);
80107f95:	83 ec 0c             	sub    $0xc,%esp
80107f98:	ff 75 f0             	pushl  -0x10(%ebp)
80107f9b:	e8 19 fe ff ff       	call   80107db9 <freevm>
80107fa0:	83 c4 10             	add    $0x10,%esp
  return 0;
80107fa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fa8:	c9                   	leave  
80107fa9:	c3                   	ret    

80107faa <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107faa:	f3 0f 1e fb          	endbr32 
80107fae:	55                   	push   %ebp
80107faf:	89 e5                	mov    %esp,%ebp
80107fb1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fb4:	83 ec 04             	sub    $0x4,%esp
80107fb7:	6a 00                	push   $0x0
80107fb9:	ff 75 0c             	pushl  0xc(%ebp)
80107fbc:	ff 75 08             	pushl  0x8(%ebp)
80107fbf:	e8 e4 f6 ff ff       	call   801076a8 <walkpgdir>
80107fc4:	83 c4 10             	add    $0x10,%esp
80107fc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcd:	8b 00                	mov    (%eax),%eax
80107fcf:	83 e0 01             	and    $0x1,%eax
80107fd2:	85 c0                	test   %eax,%eax
80107fd4:	75 07                	jne    80107fdd <uva2ka+0x33>
    return 0;
80107fd6:	b8 00 00 00 00       	mov    $0x0,%eax
80107fdb:	eb 22                	jmp    80107fff <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80107fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe0:	8b 00                	mov    (%eax),%eax
80107fe2:	83 e0 04             	and    $0x4,%eax
80107fe5:	85 c0                	test   %eax,%eax
80107fe7:	75 07                	jne    80107ff0 <uva2ka+0x46>
    return 0;
80107fe9:	b8 00 00 00 00       	mov    $0x0,%eax
80107fee:	eb 0f                	jmp    80107fff <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80107ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff3:	8b 00                	mov    (%eax),%eax
80107ff5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ffa:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107fff:	c9                   	leave  
80108000:	c3                   	ret    

80108001 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108001:	f3 0f 1e fb          	endbr32 
80108005:	55                   	push   %ebp
80108006:	89 e5                	mov    %esp,%ebp
80108008:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010800b:	8b 45 10             	mov    0x10(%ebp),%eax
8010800e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108011:	eb 7f                	jmp    80108092 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108013:	8b 45 0c             	mov    0xc(%ebp),%eax
80108016:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010801b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010801e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108021:	83 ec 08             	sub    $0x8,%esp
80108024:	50                   	push   %eax
80108025:	ff 75 08             	pushl  0x8(%ebp)
80108028:	e8 7d ff ff ff       	call   80107faa <uva2ka>
8010802d:	83 c4 10             	add    $0x10,%esp
80108030:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108033:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108037:	75 07                	jne    80108040 <copyout+0x3f>
      return -1;
80108039:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010803e:	eb 61                	jmp    801080a1 <copyout+0xa0>
    n = PGSIZE - (va - va0);
80108040:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108043:	2b 45 0c             	sub    0xc(%ebp),%eax
80108046:	05 00 10 00 00       	add    $0x1000,%eax
8010804b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010804e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108051:	3b 45 14             	cmp    0x14(%ebp),%eax
80108054:	76 06                	jbe    8010805c <copyout+0x5b>
      n = len;
80108056:	8b 45 14             	mov    0x14(%ebp),%eax
80108059:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010805c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010805f:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108062:	89 c2                	mov    %eax,%edx
80108064:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108067:	01 d0                	add    %edx,%eax
80108069:	83 ec 04             	sub    $0x4,%esp
8010806c:	ff 75 f0             	pushl  -0x10(%ebp)
8010806f:	ff 75 f4             	pushl  -0xc(%ebp)
80108072:	50                   	push   %eax
80108073:	e8 09 ce ff ff       	call   80104e81 <memmove>
80108078:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010807b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010807e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108081:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108084:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108087:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010808a:	05 00 10 00 00       	add    $0x1000,%eax
8010808f:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108092:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108096:	0f 85 77 ff ff ff    	jne    80108013 <copyout+0x12>
  }
  return 0;
8010809c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080a1:	c9                   	leave  
801080a2:	c3                   	ret    

801080a3 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801080a3:	f3 0f 1e fb          	endbr32 
801080a7:	55                   	push   %ebp
801080a8:	89 e5                	mov    %esp,%ebp
801080aa:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801080ad:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801080b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080b7:	8b 40 08             	mov    0x8(%eax),%eax
801080ba:	05 00 00 00 80       	add    $0x80000000,%eax
801080bf:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801080c2:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801080c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cc:	8b 40 24             	mov    0x24(%eax),%eax
801080cf:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
801080d4:	c7 05 80 80 19 80 00 	movl   $0x0,0x80198080
801080db:	00 00 00 

  while(i<madt->len){
801080de:	90                   	nop
801080df:	e9 be 00 00 00       	jmp    801081a2 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
801080e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080ea:	01 d0                	add    %edx,%eax
801080ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801080ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080f2:	0f b6 00             	movzbl (%eax),%eax
801080f5:	0f b6 c0             	movzbl %al,%eax
801080f8:	83 f8 05             	cmp    $0x5,%eax
801080fb:	0f 87 a1 00 00 00    	ja     801081a2 <mpinit_uefi+0xff>
80108101:	8b 04 85 b4 ac 10 80 	mov    -0x7fef534c(,%eax,4),%eax
80108108:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010810b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010810e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108111:	a1 80 80 19 80       	mov    0x80198080,%eax
80108116:	83 f8 03             	cmp    $0x3,%eax
80108119:	7f 28                	jg     80108143 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010811b:	8b 15 80 80 19 80    	mov    0x80198080,%edx
80108121:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108124:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108128:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010812e:	81 c2 c0 7d 19 80    	add    $0x80197dc0,%edx
80108134:	88 02                	mov    %al,(%edx)
          ncpu++;
80108136:	a1 80 80 19 80       	mov    0x80198080,%eax
8010813b:	83 c0 01             	add    $0x1,%eax
8010813e:	a3 80 80 19 80       	mov    %eax,0x80198080
        }
        i += lapic_entry->record_len;
80108143:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108146:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010814a:	0f b6 c0             	movzbl %al,%eax
8010814d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108150:	eb 50                	jmp    801081a2 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108155:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108158:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010815b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010815f:	a2 a0 7d 19 80       	mov    %al,0x80197da0
        i += ioapic->record_len;
80108164:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108167:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010816b:	0f b6 c0             	movzbl %al,%eax
8010816e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108171:	eb 2f                	jmp    801081a2 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108173:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108176:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108179:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010817c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108180:	0f b6 c0             	movzbl %al,%eax
80108183:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108186:	eb 1a                	jmp    801081a2 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108188:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010818b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010818e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108191:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108195:	0f b6 c0             	movzbl %al,%eax
80108198:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010819b:	eb 05                	jmp    801081a2 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
8010819d:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801081a1:	90                   	nop
  while(i<madt->len){
801081a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a5:	8b 40 04             	mov    0x4(%eax),%eax
801081a8:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801081ab:	0f 82 33 ff ff ff    	jb     801080e4 <mpinit_uefi+0x41>
    }
  }

}
801081b1:	90                   	nop
801081b2:	90                   	nop
801081b3:	c9                   	leave  
801081b4:	c3                   	ret    

801081b5 <inb>:
{
801081b5:	55                   	push   %ebp
801081b6:	89 e5                	mov    %esp,%ebp
801081b8:	83 ec 14             	sub    $0x14,%esp
801081bb:	8b 45 08             	mov    0x8(%ebp),%eax
801081be:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801081c2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801081c6:	89 c2                	mov    %eax,%edx
801081c8:	ec                   	in     (%dx),%al
801081c9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801081cc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801081d0:	c9                   	leave  
801081d1:	c3                   	ret    

801081d2 <outb>:
{
801081d2:	55                   	push   %ebp
801081d3:	89 e5                	mov    %esp,%ebp
801081d5:	83 ec 08             	sub    $0x8,%esp
801081d8:	8b 45 08             	mov    0x8(%ebp),%eax
801081db:	8b 55 0c             	mov    0xc(%ebp),%edx
801081de:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801081e2:	89 d0                	mov    %edx,%eax
801081e4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801081e7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801081eb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801081ef:	ee                   	out    %al,(%dx)
}
801081f0:	90                   	nop
801081f1:	c9                   	leave  
801081f2:	c3                   	ret    

801081f3 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801081f3:	f3 0f 1e fb          	endbr32 
801081f7:	55                   	push   %ebp
801081f8:	89 e5                	mov    %esp,%ebp
801081fa:	83 ec 28             	sub    $0x28,%esp
801081fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108200:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108203:	6a 00                	push   $0x0
80108205:	68 fa 03 00 00       	push   $0x3fa
8010820a:	e8 c3 ff ff ff       	call   801081d2 <outb>
8010820f:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108212:	68 80 00 00 00       	push   $0x80
80108217:	68 fb 03 00 00       	push   $0x3fb
8010821c:	e8 b1 ff ff ff       	call   801081d2 <outb>
80108221:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108224:	6a 0c                	push   $0xc
80108226:	68 f8 03 00 00       	push   $0x3f8
8010822b:	e8 a2 ff ff ff       	call   801081d2 <outb>
80108230:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108233:	6a 00                	push   $0x0
80108235:	68 f9 03 00 00       	push   $0x3f9
8010823a:	e8 93 ff ff ff       	call   801081d2 <outb>
8010823f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108242:	6a 03                	push   $0x3
80108244:	68 fb 03 00 00       	push   $0x3fb
80108249:	e8 84 ff ff ff       	call   801081d2 <outb>
8010824e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108251:	6a 00                	push   $0x0
80108253:	68 fc 03 00 00       	push   $0x3fc
80108258:	e8 75 ff ff ff       	call   801081d2 <outb>
8010825d:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108260:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108267:	eb 11                	jmp    8010827a <uart_debug+0x87>
80108269:	83 ec 0c             	sub    $0xc,%esp
8010826c:	6a 0a                	push   $0xa
8010826e:	e8 d1 a9 ff ff       	call   80102c44 <microdelay>
80108273:	83 c4 10             	add    $0x10,%esp
80108276:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010827a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010827e:	7f 1a                	jg     8010829a <uart_debug+0xa7>
80108280:	83 ec 0c             	sub    $0xc,%esp
80108283:	68 fd 03 00 00       	push   $0x3fd
80108288:	e8 28 ff ff ff       	call   801081b5 <inb>
8010828d:	83 c4 10             	add    $0x10,%esp
80108290:	0f b6 c0             	movzbl %al,%eax
80108293:	83 e0 20             	and    $0x20,%eax
80108296:	85 c0                	test   %eax,%eax
80108298:	74 cf                	je     80108269 <uart_debug+0x76>
  outb(COM1+0, p);
8010829a:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010829e:	0f b6 c0             	movzbl %al,%eax
801082a1:	83 ec 08             	sub    $0x8,%esp
801082a4:	50                   	push   %eax
801082a5:	68 f8 03 00 00       	push   $0x3f8
801082aa:	e8 23 ff ff ff       	call   801081d2 <outb>
801082af:	83 c4 10             	add    $0x10,%esp
}
801082b2:	90                   	nop
801082b3:	c9                   	leave  
801082b4:	c3                   	ret    

801082b5 <uart_debugs>:

void uart_debugs(char *p){
801082b5:	f3 0f 1e fb          	endbr32 
801082b9:	55                   	push   %ebp
801082ba:	89 e5                	mov    %esp,%ebp
801082bc:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801082bf:	eb 1b                	jmp    801082dc <uart_debugs+0x27>
    uart_debug(*p++);
801082c1:	8b 45 08             	mov    0x8(%ebp),%eax
801082c4:	8d 50 01             	lea    0x1(%eax),%edx
801082c7:	89 55 08             	mov    %edx,0x8(%ebp)
801082ca:	0f b6 00             	movzbl (%eax),%eax
801082cd:	0f be c0             	movsbl %al,%eax
801082d0:	83 ec 0c             	sub    $0xc,%esp
801082d3:	50                   	push   %eax
801082d4:	e8 1a ff ff ff       	call   801081f3 <uart_debug>
801082d9:	83 c4 10             	add    $0x10,%esp
  while(*p){
801082dc:	8b 45 08             	mov    0x8(%ebp),%eax
801082df:	0f b6 00             	movzbl (%eax),%eax
801082e2:	84 c0                	test   %al,%al
801082e4:	75 db                	jne    801082c1 <uart_debugs+0xc>
  }
}
801082e6:	90                   	nop
801082e7:	90                   	nop
801082e8:	c9                   	leave  
801082e9:	c3                   	ret    

801082ea <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801082ea:	f3 0f 1e fb          	endbr32 
801082ee:	55                   	push   %ebp
801082ef:	89 e5                	mov    %esp,%ebp
801082f1:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801082f4:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801082fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082fe:	8b 50 14             	mov    0x14(%eax),%edx
80108301:	8b 40 10             	mov    0x10(%eax),%eax
80108304:	a3 84 80 19 80       	mov    %eax,0x80198084
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108309:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010830c:	8b 50 1c             	mov    0x1c(%eax),%edx
8010830f:	8b 40 18             	mov    0x18(%eax),%eax
80108312:	a3 8c 80 19 80       	mov    %eax,0x8019808c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108317:	a1 8c 80 19 80       	mov    0x8019808c,%eax
8010831c:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108321:	29 c2                	sub    %eax,%edx
80108323:	89 d0                	mov    %edx,%eax
80108325:	a3 88 80 19 80       	mov    %eax,0x80198088
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010832a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010832d:	8b 50 24             	mov    0x24(%eax),%edx
80108330:	8b 40 20             	mov    0x20(%eax),%eax
80108333:	a3 90 80 19 80       	mov    %eax,0x80198090
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108338:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010833b:	8b 50 2c             	mov    0x2c(%eax),%edx
8010833e:	8b 40 28             	mov    0x28(%eax),%eax
80108341:	a3 94 80 19 80       	mov    %eax,0x80198094
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108346:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108349:	8b 50 34             	mov    0x34(%eax),%edx
8010834c:	8b 40 30             	mov    0x30(%eax),%eax
8010834f:	a3 98 80 19 80       	mov    %eax,0x80198098
}
80108354:	90                   	nop
80108355:	c9                   	leave  
80108356:	c3                   	ret    

80108357 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108357:	f3 0f 1e fb          	endbr32 
8010835b:	55                   	push   %ebp
8010835c:	89 e5                	mov    %esp,%ebp
8010835e:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108361:	8b 15 98 80 19 80    	mov    0x80198098,%edx
80108367:	8b 45 0c             	mov    0xc(%ebp),%eax
8010836a:	0f af d0             	imul   %eax,%edx
8010836d:	8b 45 08             	mov    0x8(%ebp),%eax
80108370:	01 d0                	add    %edx,%eax
80108372:	c1 e0 02             	shl    $0x2,%eax
80108375:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108378:	8b 15 88 80 19 80    	mov    0x80198088,%edx
8010837e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108381:	01 d0                	add    %edx,%eax
80108383:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108386:	8b 45 10             	mov    0x10(%ebp),%eax
80108389:	0f b6 10             	movzbl (%eax),%edx
8010838c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010838f:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108391:	8b 45 10             	mov    0x10(%ebp),%eax
80108394:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108398:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010839b:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010839e:	8b 45 10             	mov    0x10(%ebp),%eax
801083a1:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801083a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801083a8:	88 50 02             	mov    %dl,0x2(%eax)
}
801083ab:	90                   	nop
801083ac:	c9                   	leave  
801083ad:	c3                   	ret    

801083ae <graphic_scroll_up>:

void graphic_scroll_up(int height){
801083ae:	f3 0f 1e fb          	endbr32 
801083b2:	55                   	push   %ebp
801083b3:	89 e5                	mov    %esp,%ebp
801083b5:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801083b8:	8b 15 98 80 19 80    	mov    0x80198098,%edx
801083be:	8b 45 08             	mov    0x8(%ebp),%eax
801083c1:	0f af c2             	imul   %edx,%eax
801083c4:	c1 e0 02             	shl    $0x2,%eax
801083c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801083ca:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
801083d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d3:	29 c2                	sub    %eax,%edx
801083d5:	89 d0                	mov    %edx,%eax
801083d7:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
801083dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083e0:	01 ca                	add    %ecx,%edx
801083e2:	89 d1                	mov    %edx,%ecx
801083e4:	8b 15 88 80 19 80    	mov    0x80198088,%edx
801083ea:	83 ec 04             	sub    $0x4,%esp
801083ed:	50                   	push   %eax
801083ee:	51                   	push   %ecx
801083ef:	52                   	push   %edx
801083f0:	e8 8c ca ff ff       	call   80104e81 <memmove>
801083f5:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801083f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fb:	8b 0d 88 80 19 80    	mov    0x80198088,%ecx
80108401:	8b 15 8c 80 19 80    	mov    0x8019808c,%edx
80108407:	01 d1                	add    %edx,%ecx
80108409:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010840c:	29 d1                	sub    %edx,%ecx
8010840e:	89 ca                	mov    %ecx,%edx
80108410:	83 ec 04             	sub    $0x4,%esp
80108413:	50                   	push   %eax
80108414:	6a 00                	push   $0x0
80108416:	52                   	push   %edx
80108417:	e8 9e c9 ff ff       	call   80104dba <memset>
8010841c:	83 c4 10             	add    $0x10,%esp
}
8010841f:	90                   	nop
80108420:	c9                   	leave  
80108421:	c3                   	ret    

80108422 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108422:	f3 0f 1e fb          	endbr32 
80108426:	55                   	push   %ebp
80108427:	89 e5                	mov    %esp,%ebp
80108429:	53                   	push   %ebx
8010842a:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010842d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108434:	e9 b1 00 00 00       	jmp    801084ea <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108439:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108440:	e9 97 00 00 00       	jmp    801084dc <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108445:	8b 45 10             	mov    0x10(%ebp),%eax
80108448:	83 e8 20             	sub    $0x20,%eax
8010844b:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010844e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108451:	01 d0                	add    %edx,%eax
80108453:	0f b7 84 00 e0 ac 10 	movzwl -0x7fef5320(%eax,%eax,1),%eax
8010845a:	80 
8010845b:	0f b7 d0             	movzwl %ax,%edx
8010845e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108461:	bb 01 00 00 00       	mov    $0x1,%ebx
80108466:	89 c1                	mov    %eax,%ecx
80108468:	d3 e3                	shl    %cl,%ebx
8010846a:	89 d8                	mov    %ebx,%eax
8010846c:	21 d0                	and    %edx,%eax
8010846e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108474:	ba 01 00 00 00       	mov    $0x1,%edx
80108479:	89 c1                	mov    %eax,%ecx
8010847b:	d3 e2                	shl    %cl,%edx
8010847d:	89 d0                	mov    %edx,%eax
8010847f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108482:	75 2b                	jne    801084af <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108484:	8b 55 0c             	mov    0xc(%ebp),%edx
80108487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848a:	01 c2                	add    %eax,%edx
8010848c:	b8 0e 00 00 00       	mov    $0xe,%eax
80108491:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108494:	89 c1                	mov    %eax,%ecx
80108496:	8b 45 08             	mov    0x8(%ebp),%eax
80108499:	01 c8                	add    %ecx,%eax
8010849b:	83 ec 04             	sub    $0x4,%esp
8010849e:	68 e0 f4 10 80       	push   $0x8010f4e0
801084a3:	52                   	push   %edx
801084a4:	50                   	push   %eax
801084a5:	e8 ad fe ff ff       	call   80108357 <graphic_draw_pixel>
801084aa:	83 c4 10             	add    $0x10,%esp
801084ad:	eb 29                	jmp    801084d8 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801084af:	8b 55 0c             	mov    0xc(%ebp),%edx
801084b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b5:	01 c2                	add    %eax,%edx
801084b7:	b8 0e 00 00 00       	mov    $0xe,%eax
801084bc:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084bf:	89 c1                	mov    %eax,%ecx
801084c1:	8b 45 08             	mov    0x8(%ebp),%eax
801084c4:	01 c8                	add    %ecx,%eax
801084c6:	83 ec 04             	sub    $0x4,%esp
801084c9:	68 64 d0 18 80       	push   $0x8018d064
801084ce:	52                   	push   %edx
801084cf:	50                   	push   %eax
801084d0:	e8 82 fe ff ff       	call   80108357 <graphic_draw_pixel>
801084d5:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801084d8:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801084dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084e0:	0f 89 5f ff ff ff    	jns    80108445 <font_render+0x23>
  for(int i=0;i<30;i++){
801084e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084ea:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801084ee:	0f 8e 45 ff ff ff    	jle    80108439 <font_render+0x17>
      }
    }
  }
}
801084f4:	90                   	nop
801084f5:	90                   	nop
801084f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084f9:	c9                   	leave  
801084fa:	c3                   	ret    

801084fb <font_render_string>:

void font_render_string(char *string,int row){
801084fb:	f3 0f 1e fb          	endbr32 
801084ff:	55                   	push   %ebp
80108500:	89 e5                	mov    %esp,%ebp
80108502:	53                   	push   %ebx
80108503:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108506:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010850d:	eb 33                	jmp    80108542 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010850f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108512:	8b 45 08             	mov    0x8(%ebp),%eax
80108515:	01 d0                	add    %edx,%eax
80108517:	0f b6 00             	movzbl (%eax),%eax
8010851a:	0f be d8             	movsbl %al,%ebx
8010851d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108520:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108523:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108526:	89 d0                	mov    %edx,%eax
80108528:	c1 e0 04             	shl    $0x4,%eax
8010852b:	29 d0                	sub    %edx,%eax
8010852d:	83 c0 02             	add    $0x2,%eax
80108530:	83 ec 04             	sub    $0x4,%esp
80108533:	53                   	push   %ebx
80108534:	51                   	push   %ecx
80108535:	50                   	push   %eax
80108536:	e8 e7 fe ff ff       	call   80108422 <font_render>
8010853b:	83 c4 10             	add    $0x10,%esp
    i++;
8010853e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108542:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108545:	8b 45 08             	mov    0x8(%ebp),%eax
80108548:	01 d0                	add    %edx,%eax
8010854a:	0f b6 00             	movzbl (%eax),%eax
8010854d:	84 c0                	test   %al,%al
8010854f:	74 06                	je     80108557 <font_render_string+0x5c>
80108551:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108555:	7e b8                	jle    8010850f <font_render_string+0x14>
  }
}
80108557:	90                   	nop
80108558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010855b:	c9                   	leave  
8010855c:	c3                   	ret    

8010855d <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010855d:	f3 0f 1e fb          	endbr32 
80108561:	55                   	push   %ebp
80108562:	89 e5                	mov    %esp,%ebp
80108564:	53                   	push   %ebx
80108565:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108568:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010856f:	eb 6b                	jmp    801085dc <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108571:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108578:	eb 58                	jmp    801085d2 <pci_init+0x75>
      for(int k=0;k<8;k++){
8010857a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108581:	eb 45                	jmp    801085c8 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108583:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108586:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858c:	83 ec 0c             	sub    $0xc,%esp
8010858f:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108592:	53                   	push   %ebx
80108593:	6a 00                	push   $0x0
80108595:	51                   	push   %ecx
80108596:	52                   	push   %edx
80108597:	50                   	push   %eax
80108598:	e8 c0 00 00 00       	call   8010865d <pci_access_config>
8010859d:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801085a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085a3:	0f b7 c0             	movzwl %ax,%eax
801085a6:	3d ff ff 00 00       	cmp    $0xffff,%eax
801085ab:	74 17                	je     801085c4 <pci_init+0x67>
        pci_init_device(i,j,k);
801085ad:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801085b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801085b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b6:	83 ec 04             	sub    $0x4,%esp
801085b9:	51                   	push   %ecx
801085ba:	52                   	push   %edx
801085bb:	50                   	push   %eax
801085bc:	e8 4f 01 00 00       	call   80108710 <pci_init_device>
801085c1:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801085c4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801085c8:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801085cc:	7e b5                	jle    80108583 <pci_init+0x26>
    for(int j=0;j<32;j++){
801085ce:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801085d2:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801085d6:	7e a2                	jle    8010857a <pci_init+0x1d>
  for(int i=0;i<256;i++){
801085d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085dc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801085e3:	7e 8c                	jle    80108571 <pci_init+0x14>
      }
      }
    }
  }
}
801085e5:	90                   	nop
801085e6:	90                   	nop
801085e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085ea:	c9                   	leave  
801085eb:	c3                   	ret    

801085ec <pci_write_config>:

void pci_write_config(uint config){
801085ec:	f3 0f 1e fb          	endbr32 
801085f0:	55                   	push   %ebp
801085f1:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801085f3:	8b 45 08             	mov    0x8(%ebp),%eax
801085f6:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801085fb:	89 c0                	mov    %eax,%eax
801085fd:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801085fe:	90                   	nop
801085ff:	5d                   	pop    %ebp
80108600:	c3                   	ret    

80108601 <pci_write_data>:

void pci_write_data(uint config){
80108601:	f3 0f 1e fb          	endbr32 
80108605:	55                   	push   %ebp
80108606:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108608:	8b 45 08             	mov    0x8(%ebp),%eax
8010860b:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108610:	89 c0                	mov    %eax,%eax
80108612:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108613:	90                   	nop
80108614:	5d                   	pop    %ebp
80108615:	c3                   	ret    

80108616 <pci_read_config>:
uint pci_read_config(){
80108616:	f3 0f 1e fb          	endbr32 
8010861a:	55                   	push   %ebp
8010861b:	89 e5                	mov    %esp,%ebp
8010861d:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108620:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108625:	ed                   	in     (%dx),%eax
80108626:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108629:	83 ec 0c             	sub    $0xc,%esp
8010862c:	68 c8 00 00 00       	push   $0xc8
80108631:	e8 0e a6 ff ff       	call   80102c44 <microdelay>
80108636:	83 c4 10             	add    $0x10,%esp
  return data;
80108639:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010863c:	c9                   	leave  
8010863d:	c3                   	ret    

8010863e <pci_test>:


void pci_test(){
8010863e:	f3 0f 1e fb          	endbr32 
80108642:	55                   	push   %ebp
80108643:	89 e5                	mov    %esp,%ebp
80108645:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108648:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010864f:	ff 75 fc             	pushl  -0x4(%ebp)
80108652:	e8 95 ff ff ff       	call   801085ec <pci_write_config>
80108657:	83 c4 04             	add    $0x4,%esp
}
8010865a:	90                   	nop
8010865b:	c9                   	leave  
8010865c:	c3                   	ret    

8010865d <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010865d:	f3 0f 1e fb          	endbr32 
80108661:	55                   	push   %ebp
80108662:	89 e5                	mov    %esp,%ebp
80108664:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108667:	8b 45 08             	mov    0x8(%ebp),%eax
8010866a:	c1 e0 10             	shl    $0x10,%eax
8010866d:	25 00 00 ff 00       	and    $0xff0000,%eax
80108672:	89 c2                	mov    %eax,%edx
80108674:	8b 45 0c             	mov    0xc(%ebp),%eax
80108677:	c1 e0 0b             	shl    $0xb,%eax
8010867a:	0f b7 c0             	movzwl %ax,%eax
8010867d:	09 c2                	or     %eax,%edx
8010867f:	8b 45 10             	mov    0x10(%ebp),%eax
80108682:	c1 e0 08             	shl    $0x8,%eax
80108685:	25 00 07 00 00       	and    $0x700,%eax
8010868a:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010868c:	8b 45 14             	mov    0x14(%ebp),%eax
8010868f:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108694:	09 d0                	or     %edx,%eax
80108696:	0d 00 00 00 80       	or     $0x80000000,%eax
8010869b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010869e:	ff 75 f4             	pushl  -0xc(%ebp)
801086a1:	e8 46 ff ff ff       	call   801085ec <pci_write_config>
801086a6:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801086a9:	e8 68 ff ff ff       	call   80108616 <pci_read_config>
801086ae:	8b 55 18             	mov    0x18(%ebp),%edx
801086b1:	89 02                	mov    %eax,(%edx)
}
801086b3:	90                   	nop
801086b4:	c9                   	leave  
801086b5:	c3                   	ret    

801086b6 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801086b6:	f3 0f 1e fb          	endbr32 
801086ba:	55                   	push   %ebp
801086bb:	89 e5                	mov    %esp,%ebp
801086bd:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086c0:	8b 45 08             	mov    0x8(%ebp),%eax
801086c3:	c1 e0 10             	shl    $0x10,%eax
801086c6:	25 00 00 ff 00       	and    $0xff0000,%eax
801086cb:	89 c2                	mov    %eax,%edx
801086cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801086d0:	c1 e0 0b             	shl    $0xb,%eax
801086d3:	0f b7 c0             	movzwl %ax,%eax
801086d6:	09 c2                	or     %eax,%edx
801086d8:	8b 45 10             	mov    0x10(%ebp),%eax
801086db:	c1 e0 08             	shl    $0x8,%eax
801086de:	25 00 07 00 00       	and    $0x700,%eax
801086e3:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801086e5:	8b 45 14             	mov    0x14(%ebp),%eax
801086e8:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086ed:	09 d0                	or     %edx,%eax
801086ef:	0d 00 00 00 80       	or     $0x80000000,%eax
801086f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801086f7:	ff 75 fc             	pushl  -0x4(%ebp)
801086fa:	e8 ed fe ff ff       	call   801085ec <pci_write_config>
801086ff:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108702:	ff 75 18             	pushl  0x18(%ebp)
80108705:	e8 f7 fe ff ff       	call   80108601 <pci_write_data>
8010870a:	83 c4 04             	add    $0x4,%esp
}
8010870d:	90                   	nop
8010870e:	c9                   	leave  
8010870f:	c3                   	ret    

80108710 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108710:	f3 0f 1e fb          	endbr32 
80108714:	55                   	push   %ebp
80108715:	89 e5                	mov    %esp,%ebp
80108717:	53                   	push   %ebx
80108718:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
8010871b:	8b 45 08             	mov    0x8(%ebp),%eax
8010871e:	a2 9c 80 19 80       	mov    %al,0x8019809c
  dev.device_num = device_num;
80108723:	8b 45 0c             	mov    0xc(%ebp),%eax
80108726:	a2 9d 80 19 80       	mov    %al,0x8019809d
  dev.function_num = function_num;
8010872b:	8b 45 10             	mov    0x10(%ebp),%eax
8010872e:	a2 9e 80 19 80       	mov    %al,0x8019809e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108733:	ff 75 10             	pushl  0x10(%ebp)
80108736:	ff 75 0c             	pushl  0xc(%ebp)
80108739:	ff 75 08             	pushl  0x8(%ebp)
8010873c:	68 24 c3 10 80       	push   $0x8010c324
80108741:	e8 c6 7c ff ff       	call   8010040c <cprintf>
80108746:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108749:	83 ec 0c             	sub    $0xc,%esp
8010874c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010874f:	50                   	push   %eax
80108750:	6a 00                	push   $0x0
80108752:	ff 75 10             	pushl  0x10(%ebp)
80108755:	ff 75 0c             	pushl  0xc(%ebp)
80108758:	ff 75 08             	pushl  0x8(%ebp)
8010875b:	e8 fd fe ff ff       	call   8010865d <pci_access_config>
80108760:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108763:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108766:	c1 e8 10             	shr    $0x10,%eax
80108769:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010876c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010876f:	25 ff ff 00 00       	and    $0xffff,%eax
80108774:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877a:	a3 a0 80 19 80       	mov    %eax,0x801980a0
  dev.vendor_id = vendor_id;
8010877f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108782:	a3 a4 80 19 80       	mov    %eax,0x801980a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108787:	83 ec 04             	sub    $0x4,%esp
8010878a:	ff 75 f0             	pushl  -0x10(%ebp)
8010878d:	ff 75 f4             	pushl  -0xc(%ebp)
80108790:	68 58 c3 10 80       	push   $0x8010c358
80108795:	e8 72 7c ff ff       	call   8010040c <cprintf>
8010879a:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010879d:	83 ec 0c             	sub    $0xc,%esp
801087a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087a3:	50                   	push   %eax
801087a4:	6a 08                	push   $0x8
801087a6:	ff 75 10             	pushl  0x10(%ebp)
801087a9:	ff 75 0c             	pushl  0xc(%ebp)
801087ac:	ff 75 08             	pushl  0x8(%ebp)
801087af:	e8 a9 fe ff ff       	call   8010865d <pci_access_config>
801087b4:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ba:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c0:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087c3:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801087c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c9:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801087cc:	0f b6 c0             	movzbl %al,%eax
801087cf:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801087d2:	c1 eb 18             	shr    $0x18,%ebx
801087d5:	83 ec 0c             	sub    $0xc,%esp
801087d8:	51                   	push   %ecx
801087d9:	52                   	push   %edx
801087da:	50                   	push   %eax
801087db:	53                   	push   %ebx
801087dc:	68 7c c3 10 80       	push   $0x8010c37c
801087e1:	e8 26 7c ff ff       	call   8010040c <cprintf>
801087e6:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801087e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ec:	c1 e8 18             	shr    $0x18,%eax
801087ef:	a2 a8 80 19 80       	mov    %al,0x801980a8
  dev.sub_class = (data>>16)&0xFF;
801087f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f7:	c1 e8 10             	shr    $0x10,%eax
801087fa:	a2 a9 80 19 80       	mov    %al,0x801980a9
  dev.interface = (data>>8)&0xFF;
801087ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108802:	c1 e8 08             	shr    $0x8,%eax
80108805:	a2 aa 80 19 80       	mov    %al,0x801980aa
  dev.revision_id = data&0xFF;
8010880a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010880d:	a2 ab 80 19 80       	mov    %al,0x801980ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108812:	83 ec 0c             	sub    $0xc,%esp
80108815:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108818:	50                   	push   %eax
80108819:	6a 10                	push   $0x10
8010881b:	ff 75 10             	pushl  0x10(%ebp)
8010881e:	ff 75 0c             	pushl  0xc(%ebp)
80108821:	ff 75 08             	pushl  0x8(%ebp)
80108824:	e8 34 fe ff ff       	call   8010865d <pci_access_config>
80108829:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010882c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010882f:	a3 ac 80 19 80       	mov    %eax,0x801980ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108834:	83 ec 0c             	sub    $0xc,%esp
80108837:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010883a:	50                   	push   %eax
8010883b:	6a 14                	push   $0x14
8010883d:	ff 75 10             	pushl  0x10(%ebp)
80108840:	ff 75 0c             	pushl  0xc(%ebp)
80108843:	ff 75 08             	pushl  0x8(%ebp)
80108846:	e8 12 fe ff ff       	call   8010865d <pci_access_config>
8010884b:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010884e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108851:	a3 b0 80 19 80       	mov    %eax,0x801980b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108856:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010885d:	75 5a                	jne    801088b9 <pci_init_device+0x1a9>
8010885f:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108866:	75 51                	jne    801088b9 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108868:	83 ec 0c             	sub    $0xc,%esp
8010886b:	68 c1 c3 10 80       	push   $0x8010c3c1
80108870:	e8 97 7b ff ff       	call   8010040c <cprintf>
80108875:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108878:	83 ec 0c             	sub    $0xc,%esp
8010887b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010887e:	50                   	push   %eax
8010887f:	68 f0 00 00 00       	push   $0xf0
80108884:	ff 75 10             	pushl  0x10(%ebp)
80108887:	ff 75 0c             	pushl  0xc(%ebp)
8010888a:	ff 75 08             	pushl  0x8(%ebp)
8010888d:	e8 cb fd ff ff       	call   8010865d <pci_access_config>
80108892:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108895:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108898:	83 ec 08             	sub    $0x8,%esp
8010889b:	50                   	push   %eax
8010889c:	68 db c3 10 80       	push   $0x8010c3db
801088a1:	e8 66 7b ff ff       	call   8010040c <cprintf>
801088a6:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
801088a9:	83 ec 0c             	sub    $0xc,%esp
801088ac:	68 9c 80 19 80       	push   $0x8019809c
801088b1:	e8 09 00 00 00       	call   801088bf <i8254_init>
801088b6:	83 c4 10             	add    $0x10,%esp
  }
}
801088b9:	90                   	nop
801088ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088bd:	c9                   	leave  
801088be:	c3                   	ret    

801088bf <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801088bf:	f3 0f 1e fb          	endbr32 
801088c3:	55                   	push   %ebp
801088c4:	89 e5                	mov    %esp,%ebp
801088c6:	53                   	push   %ebx
801088c7:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801088ca:	8b 45 08             	mov    0x8(%ebp),%eax
801088cd:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801088d1:	0f b6 c8             	movzbl %al,%ecx
801088d4:	8b 45 08             	mov    0x8(%ebp),%eax
801088d7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801088db:	0f b6 d0             	movzbl %al,%edx
801088de:	8b 45 08             	mov    0x8(%ebp),%eax
801088e1:	0f b6 00             	movzbl (%eax),%eax
801088e4:	0f b6 c0             	movzbl %al,%eax
801088e7:	83 ec 0c             	sub    $0xc,%esp
801088ea:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801088ed:	53                   	push   %ebx
801088ee:	6a 04                	push   $0x4
801088f0:	51                   	push   %ecx
801088f1:	52                   	push   %edx
801088f2:	50                   	push   %eax
801088f3:	e8 65 fd ff ff       	call   8010865d <pci_access_config>
801088f8:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801088fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088fe:	83 c8 04             	or     $0x4,%eax
80108901:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108904:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108907:	8b 45 08             	mov    0x8(%ebp),%eax
8010890a:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010890e:	0f b6 c8             	movzbl %al,%ecx
80108911:	8b 45 08             	mov    0x8(%ebp),%eax
80108914:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108918:	0f b6 d0             	movzbl %al,%edx
8010891b:	8b 45 08             	mov    0x8(%ebp),%eax
8010891e:	0f b6 00             	movzbl (%eax),%eax
80108921:	0f b6 c0             	movzbl %al,%eax
80108924:	83 ec 0c             	sub    $0xc,%esp
80108927:	53                   	push   %ebx
80108928:	6a 04                	push   $0x4
8010892a:	51                   	push   %ecx
8010892b:	52                   	push   %edx
8010892c:	50                   	push   %eax
8010892d:	e8 84 fd ff ff       	call   801086b6 <pci_write_config_register>
80108932:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108935:	8b 45 08             	mov    0x8(%ebp),%eax
80108938:	8b 40 10             	mov    0x10(%eax),%eax
8010893b:	05 00 00 00 40       	add    $0x40000000,%eax
80108940:	a3 b4 80 19 80       	mov    %eax,0x801980b4
  uint *ctrl = (uint *)base_addr;
80108945:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010894a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
8010894d:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108952:	05 d8 00 00 00       	add    $0xd8,%eax
80108957:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010895a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010895d:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108966:	8b 00                	mov    (%eax),%eax
80108968:	0d 00 00 00 04       	or     $0x4000000,%eax
8010896d:	89 c2                	mov    %eax,%edx
8010896f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108972:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108974:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108977:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010897d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108980:	8b 00                	mov    (%eax),%eax
80108982:	83 c8 40             	or     $0x40,%eax
80108985:	89 c2                	mov    %eax,%edx
80108987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898a:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010898c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898f:	8b 10                	mov    (%eax),%edx
80108991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108994:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108996:	83 ec 0c             	sub    $0xc,%esp
80108999:	68 f0 c3 10 80       	push   $0x8010c3f0
8010899e:	e8 69 7a ff ff       	call   8010040c <cprintf>
801089a3:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
801089a6:	e8 e7 9e ff ff       	call   80102892 <kalloc>
801089ab:	a3 b8 80 19 80       	mov    %eax,0x801980b8
  *intr_addr = 0;
801089b0:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801089b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
801089bb:	a1 b8 80 19 80       	mov    0x801980b8,%eax
801089c0:	83 ec 08             	sub    $0x8,%esp
801089c3:	50                   	push   %eax
801089c4:	68 12 c4 10 80       	push   $0x8010c412
801089c9:	e8 3e 7a ff ff       	call   8010040c <cprintf>
801089ce:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801089d1:	e8 50 00 00 00       	call   80108a26 <i8254_init_recv>
  i8254_init_send();
801089d6:	e8 6d 03 00 00       	call   80108d48 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801089db:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089e2:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801089e5:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089ec:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801089ef:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089f6:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801089f9:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108a00:	0f b6 c0             	movzbl %al,%eax
80108a03:	83 ec 0c             	sub    $0xc,%esp
80108a06:	53                   	push   %ebx
80108a07:	51                   	push   %ecx
80108a08:	52                   	push   %edx
80108a09:	50                   	push   %eax
80108a0a:	68 20 c4 10 80       	push   $0x8010c420
80108a0f:	e8 f8 79 ff ff       	call   8010040c <cprintf>
80108a14:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108a20:	90                   	nop
80108a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a24:	c9                   	leave  
80108a25:	c3                   	ret    

80108a26 <i8254_init_recv>:

void i8254_init_recv(){
80108a26:	f3 0f 1e fb          	endbr32 
80108a2a:	55                   	push   %ebp
80108a2b:	89 e5                	mov    %esp,%ebp
80108a2d:	57                   	push   %edi
80108a2e:	56                   	push   %esi
80108a2f:	53                   	push   %ebx
80108a30:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108a33:	83 ec 0c             	sub    $0xc,%esp
80108a36:	6a 00                	push   $0x0
80108a38:	e8 ec 04 00 00       	call   80108f29 <i8254_read_eeprom>
80108a3d:	83 c4 10             	add    $0x10,%esp
80108a40:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108a43:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a46:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108a4b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a4e:	c1 e8 08             	shr    $0x8,%eax
80108a51:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108a56:	83 ec 0c             	sub    $0xc,%esp
80108a59:	6a 01                	push   $0x1
80108a5b:	e8 c9 04 00 00       	call   80108f29 <i8254_read_eeprom>
80108a60:	83 c4 10             	add    $0x10,%esp
80108a63:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108a66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a69:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108a6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a71:	c1 e8 08             	shr    $0x8,%eax
80108a74:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108a79:	83 ec 0c             	sub    $0xc,%esp
80108a7c:	6a 02                	push   $0x2
80108a7e:	e8 a6 04 00 00       	call   80108f29 <i8254_read_eeprom>
80108a83:	83 c4 10             	add    $0x10,%esp
80108a86:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108a89:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a8c:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108a91:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a94:	c1 e8 08             	shr    $0x8,%eax
80108a97:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108a9c:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108aa3:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108aa6:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108aad:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108ab0:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ab7:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108aba:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ac1:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108ac4:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108acb:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108ace:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ad5:	0f b6 c0             	movzbl %al,%eax
80108ad8:	83 ec 04             	sub    $0x4,%esp
80108adb:	57                   	push   %edi
80108adc:	56                   	push   %esi
80108add:	53                   	push   %ebx
80108ade:	51                   	push   %ecx
80108adf:	52                   	push   %edx
80108ae0:	50                   	push   %eax
80108ae1:	68 38 c4 10 80       	push   $0x8010c438
80108ae6:	e8 21 79 ff ff       	call   8010040c <cprintf>
80108aeb:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108aee:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108af3:	05 00 54 00 00       	add    $0x5400,%eax
80108af8:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108afb:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b00:	05 04 54 00 00       	add    $0x5404,%eax
80108b05:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108b08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b0b:	c1 e0 10             	shl    $0x10,%eax
80108b0e:	0b 45 d8             	or     -0x28(%ebp),%eax
80108b11:	89 c2                	mov    %eax,%edx
80108b13:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108b16:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108b18:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b1b:	0d 00 00 00 80       	or     $0x80000000,%eax
80108b20:	89 c2                	mov    %eax,%edx
80108b22:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108b25:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108b27:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b2c:	05 00 52 00 00       	add    $0x5200,%eax
80108b31:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108b34:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108b3b:	eb 19                	jmp    80108b56 <i8254_init_recv+0x130>
    mta[i] = 0;
80108b3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108b40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b47:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108b4a:	01 d0                	add    %edx,%eax
80108b4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108b52:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108b56:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108b5a:	7e e1                	jle    80108b3d <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108b5c:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b61:	05 d0 00 00 00       	add    $0xd0,%eax
80108b66:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b69:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108b6c:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108b72:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b77:	05 c8 00 00 00       	add    $0xc8,%eax
80108b7c:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b7f:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108b82:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108b88:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108b8d:	05 28 28 00 00       	add    $0x2828,%eax
80108b92:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108b95:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108b98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108b9e:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108ba3:	05 00 01 00 00       	add    $0x100,%eax
80108ba8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108bab:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108bae:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108bb4:	e8 d9 9c ff ff       	call   80102892 <kalloc>
80108bb9:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108bbc:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bc1:	05 00 28 00 00       	add    $0x2800,%eax
80108bc6:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108bc9:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bce:	05 04 28 00 00       	add    $0x2804,%eax
80108bd3:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108bd6:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bdb:	05 08 28 00 00       	add    $0x2808,%eax
80108be0:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108be3:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108be8:	05 10 28 00 00       	add    $0x2810,%eax
80108bed:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108bf0:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108bf5:	05 18 28 00 00       	add    $0x2818,%eax
80108bfa:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108bfd:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c00:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c06:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108c09:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108c0b:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108c0e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108c14:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108c17:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108c1d:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108c20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108c26:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108c29:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108c2f:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108c32:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c35:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108c3c:	eb 73                	jmp    80108cb1 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108c3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c41:	c1 e0 04             	shl    $0x4,%eax
80108c44:	89 c2                	mov    %eax,%edx
80108c46:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c49:	01 d0                	add    %edx,%eax
80108c4b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108c52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c55:	c1 e0 04             	shl    $0x4,%eax
80108c58:	89 c2                	mov    %eax,%edx
80108c5a:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c5d:	01 d0                	add    %edx,%eax
80108c5f:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108c65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c68:	c1 e0 04             	shl    $0x4,%eax
80108c6b:	89 c2                	mov    %eax,%edx
80108c6d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c70:	01 d0                	add    %edx,%eax
80108c72:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108c78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c7b:	c1 e0 04             	shl    $0x4,%eax
80108c7e:	89 c2                	mov    %eax,%edx
80108c80:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c83:	01 d0                	add    %edx,%eax
80108c85:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108c89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c8c:	c1 e0 04             	shl    $0x4,%eax
80108c8f:	89 c2                	mov    %eax,%edx
80108c91:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c94:	01 d0                	add    %edx,%eax
80108c96:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108c9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c9d:	c1 e0 04             	shl    $0x4,%eax
80108ca0:	89 c2                	mov    %eax,%edx
80108ca2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ca5:	01 d0                	add    %edx,%eax
80108ca7:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108cad:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108cb1:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108cb8:	7e 84                	jle    80108c3e <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108cba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108cc1:	eb 57                	jmp    80108d1a <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108cc3:	e8 ca 9b ff ff       	call   80102892 <kalloc>
80108cc8:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108ccb:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108ccf:	75 12                	jne    80108ce3 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108cd1:	83 ec 0c             	sub    $0xc,%esp
80108cd4:	68 58 c4 10 80       	push   $0x8010c458
80108cd9:	e8 2e 77 ff ff       	call   8010040c <cprintf>
80108cde:	83 c4 10             	add    $0x10,%esp
      break;
80108ce1:	eb 3d                	jmp    80108d20 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108ce3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ce6:	c1 e0 04             	shl    $0x4,%eax
80108ce9:	89 c2                	mov    %eax,%edx
80108ceb:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cee:	01 d0                	add    %edx,%eax
80108cf0:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108cf3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108cf9:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108cfb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cfe:	83 c0 01             	add    $0x1,%eax
80108d01:	c1 e0 04             	shl    $0x4,%eax
80108d04:	89 c2                	mov    %eax,%edx
80108d06:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d09:	01 d0                	add    %edx,%eax
80108d0b:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108d0e:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108d14:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108d16:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108d1a:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108d1e:	7e a3                	jle    80108cc3 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108d20:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d23:	8b 00                	mov    (%eax),%eax
80108d25:	83 c8 02             	or     $0x2,%eax
80108d28:	89 c2                	mov    %eax,%edx
80108d2a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d2d:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108d2f:	83 ec 0c             	sub    $0xc,%esp
80108d32:	68 78 c4 10 80       	push   $0x8010c478
80108d37:	e8 d0 76 ff ff       	call   8010040c <cprintf>
80108d3c:	83 c4 10             	add    $0x10,%esp
}
80108d3f:	90                   	nop
80108d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108d43:	5b                   	pop    %ebx
80108d44:	5e                   	pop    %esi
80108d45:	5f                   	pop    %edi
80108d46:	5d                   	pop    %ebp
80108d47:	c3                   	ret    

80108d48 <i8254_init_send>:

void i8254_init_send(){
80108d48:	f3 0f 1e fb          	endbr32 
80108d4c:	55                   	push   %ebp
80108d4d:	89 e5                	mov    %esp,%ebp
80108d4f:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108d52:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d57:	05 28 38 00 00       	add    $0x3828,%eax
80108d5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108d5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d62:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108d68:	e8 25 9b ff ff       	call   80102892 <kalloc>
80108d6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108d70:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d75:	05 00 38 00 00       	add    $0x3800,%eax
80108d7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108d7d:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d82:	05 04 38 00 00       	add    $0x3804,%eax
80108d87:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108d8a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108d8f:	05 08 38 00 00       	add    $0x3808,%eax
80108d94:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108d97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d9a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108da0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108da3:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108da8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108dae:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108db1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108db7:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dbc:	05 10 38 00 00       	add    $0x3810,%eax
80108dc1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108dc4:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108dc9:	05 18 38 00 00       	add    $0x3818,%eax
80108dce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108dd1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108dd4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108dda:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ddd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108de3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108de6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108de9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108df0:	e9 82 00 00 00       	jmp    80108e77 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df8:	c1 e0 04             	shl    $0x4,%eax
80108dfb:	89 c2                	mov    %eax,%edx
80108dfd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e00:	01 d0                	add    %edx,%eax
80108e02:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e0c:	c1 e0 04             	shl    $0x4,%eax
80108e0f:	89 c2                	mov    %eax,%edx
80108e11:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e14:	01 d0                	add    %edx,%eax
80108e16:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1f:	c1 e0 04             	shl    $0x4,%eax
80108e22:	89 c2                	mov    %eax,%edx
80108e24:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e27:	01 d0                	add    %edx,%eax
80108e29:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e30:	c1 e0 04             	shl    $0x4,%eax
80108e33:	89 c2                	mov    %eax,%edx
80108e35:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e38:	01 d0                	add    %edx,%eax
80108e3a:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e41:	c1 e0 04             	shl    $0x4,%eax
80108e44:	89 c2                	mov    %eax,%edx
80108e46:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e49:	01 d0                	add    %edx,%eax
80108e4b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e52:	c1 e0 04             	shl    $0x4,%eax
80108e55:	89 c2                	mov    %eax,%edx
80108e57:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e5a:	01 d0                	add    %edx,%eax
80108e5c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e63:	c1 e0 04             	shl    $0x4,%eax
80108e66:	89 c2                	mov    %eax,%edx
80108e68:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e6b:	01 d0                	add    %edx,%eax
80108e6d:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e73:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e77:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e7e:	0f 8e 71 ff ff ff    	jle    80108df5 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e84:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e8b:	eb 57                	jmp    80108ee4 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108e8d:	e8 00 9a ff ff       	call   80102892 <kalloc>
80108e92:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108e95:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108e99:	75 12                	jne    80108ead <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108e9b:	83 ec 0c             	sub    $0xc,%esp
80108e9e:	68 58 c4 10 80       	push   $0x8010c458
80108ea3:	e8 64 75 ff ff       	call   8010040c <cprintf>
80108ea8:	83 c4 10             	add    $0x10,%esp
      break;
80108eab:	eb 3d                	jmp    80108eea <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb0:	c1 e0 04             	shl    $0x4,%eax
80108eb3:	89 c2                	mov    %eax,%edx
80108eb5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eb8:	01 d0                	add    %edx,%eax
80108eba:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108ebd:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108ec3:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec8:	83 c0 01             	add    $0x1,%eax
80108ecb:	c1 e0 04             	shl    $0x4,%eax
80108ece:	89 c2                	mov    %eax,%edx
80108ed0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ed3:	01 d0                	add    %edx,%eax
80108ed5:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108ed8:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108ede:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108ee0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108ee4:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108ee8:	7e a3                	jle    80108e8d <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108eea:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108eef:	05 00 04 00 00       	add    $0x400,%eax
80108ef4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108ef7:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108efa:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108f00:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f05:	05 10 04 00 00       	add    $0x410,%eax
80108f0a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108f0d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108f10:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108f16:	83 ec 0c             	sub    $0xc,%esp
80108f19:	68 98 c4 10 80       	push   $0x8010c498
80108f1e:	e8 e9 74 ff ff       	call   8010040c <cprintf>
80108f23:	83 c4 10             	add    $0x10,%esp

}
80108f26:	90                   	nop
80108f27:	c9                   	leave  
80108f28:	c3                   	ret    

80108f29 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108f29:	f3 0f 1e fb          	endbr32 
80108f2d:	55                   	push   %ebp
80108f2e:	89 e5                	mov    %esp,%ebp
80108f30:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108f33:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f38:	83 c0 14             	add    $0x14,%eax
80108f3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80108f41:	c1 e0 08             	shl    $0x8,%eax
80108f44:	0f b7 c0             	movzwl %ax,%eax
80108f47:	83 c8 01             	or     $0x1,%eax
80108f4a:	89 c2                	mov    %eax,%edx
80108f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f4f:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108f51:	83 ec 0c             	sub    $0xc,%esp
80108f54:	68 b8 c4 10 80       	push   $0x8010c4b8
80108f59:	e8 ae 74 ff ff       	call   8010040c <cprintf>
80108f5e:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f64:	8b 00                	mov    (%eax),%eax
80108f66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f6c:	83 e0 10             	and    $0x10,%eax
80108f6f:	85 c0                	test   %eax,%eax
80108f71:	75 02                	jne    80108f75 <i8254_read_eeprom+0x4c>
  while(1){
80108f73:	eb dc                	jmp    80108f51 <i8254_read_eeprom+0x28>
      break;
80108f75:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f79:	8b 00                	mov    (%eax),%eax
80108f7b:	c1 e8 10             	shr    $0x10,%eax
}
80108f7e:	c9                   	leave  
80108f7f:	c3                   	ret    

80108f80 <i8254_recv>:
void i8254_recv(){
80108f80:	f3 0f 1e fb          	endbr32 
80108f84:	55                   	push   %ebp
80108f85:	89 e5                	mov    %esp,%ebp
80108f87:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f8a:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f8f:	05 10 28 00 00       	add    $0x2810,%eax
80108f94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f97:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108f9c:	05 18 28 00 00       	add    $0x2818,%eax
80108fa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108fa4:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80108fa9:	05 00 28 00 00       	add    $0x2800,%eax
80108fae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108fb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fb4:	8b 00                	mov    (%eax),%eax
80108fb6:	05 00 00 00 80       	add    $0x80000000,%eax
80108fbb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc1:	8b 10                	mov    (%eax),%edx
80108fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc6:	8b 00                	mov    (%eax),%eax
80108fc8:	29 c2                	sub    %eax,%edx
80108fca:	89 d0                	mov    %edx,%eax
80108fcc:	25 ff 00 00 00       	and    $0xff,%eax
80108fd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108fd4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108fd8:	7e 37                	jle    80109011 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fdd:	8b 00                	mov    (%eax),%eax
80108fdf:	c1 e0 04             	shl    $0x4,%eax
80108fe2:	89 c2                	mov    %eax,%edx
80108fe4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fe7:	01 d0                	add    %edx,%eax
80108fe9:	8b 00                	mov    (%eax),%eax
80108feb:	05 00 00 00 80       	add    $0x80000000,%eax
80108ff0:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ff6:	8b 00                	mov    (%eax),%eax
80108ff8:	83 c0 01             	add    $0x1,%eax
80108ffb:	0f b6 d0             	movzbl %al,%edx
80108ffe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109001:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109003:	83 ec 0c             	sub    $0xc,%esp
80109006:	ff 75 e0             	pushl  -0x20(%ebp)
80109009:	e8 47 09 00 00       	call   80109955 <eth_proc>
8010900e:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109011:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109014:	8b 10                	mov    (%eax),%edx
80109016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109019:	8b 00                	mov    (%eax),%eax
8010901b:	39 c2                	cmp    %eax,%edx
8010901d:	75 9f                	jne    80108fbe <i8254_recv+0x3e>
      (*rdt)--;
8010901f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109022:	8b 00                	mov    (%eax),%eax
80109024:	8d 50 ff             	lea    -0x1(%eax),%edx
80109027:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010902a:	89 10                	mov    %edx,(%eax)
  while(1){
8010902c:	eb 90                	jmp    80108fbe <i8254_recv+0x3e>

8010902e <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010902e:	f3 0f 1e fb          	endbr32 
80109032:	55                   	push   %ebp
80109033:	89 e5                	mov    %esp,%ebp
80109035:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109038:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010903d:	05 10 38 00 00       	add    $0x3810,%eax
80109042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109045:	a1 b4 80 19 80       	mov    0x801980b4,%eax
8010904a:	05 18 38 00 00       	add    $0x3818,%eax
8010904f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109052:	a1 b4 80 19 80       	mov    0x801980b4,%eax
80109057:	05 00 38 00 00       	add    $0x3800,%eax
8010905c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010905f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109062:	8b 00                	mov    (%eax),%eax
80109064:	05 00 00 00 80       	add    $0x80000000,%eax
80109069:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
8010906c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010906f:	8b 10                	mov    (%eax),%edx
80109071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109074:	8b 00                	mov    (%eax),%eax
80109076:	29 c2                	sub    %eax,%edx
80109078:	89 d0                	mov    %edx,%eax
8010907a:	0f b6 c0             	movzbl %al,%eax
8010907d:	ba 00 01 00 00       	mov    $0x100,%edx
80109082:	29 c2                	sub    %eax,%edx
80109084:	89 d0                	mov    %edx,%eax
80109086:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109089:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010908c:	8b 00                	mov    (%eax),%eax
8010908e:	25 ff 00 00 00       	and    $0xff,%eax
80109093:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109096:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010909a:	0f 8e a8 00 00 00    	jle    80109148 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801090a0:	8b 45 08             	mov    0x8(%ebp),%eax
801090a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801090a6:	89 d1                	mov    %edx,%ecx
801090a8:	c1 e1 04             	shl    $0x4,%ecx
801090ab:	8b 55 e8             	mov    -0x18(%ebp),%edx
801090ae:	01 ca                	add    %ecx,%edx
801090b0:	8b 12                	mov    (%edx),%edx
801090b2:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090b8:	83 ec 04             	sub    $0x4,%esp
801090bb:	ff 75 0c             	pushl  0xc(%ebp)
801090be:	50                   	push   %eax
801090bf:	52                   	push   %edx
801090c0:	e8 bc bd ff ff       	call   80104e81 <memmove>
801090c5:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801090c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090cb:	c1 e0 04             	shl    $0x4,%eax
801090ce:	89 c2                	mov    %eax,%edx
801090d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090d3:	01 d0                	add    %edx,%eax
801090d5:	8b 55 0c             	mov    0xc(%ebp),%edx
801090d8:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801090dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090df:	c1 e0 04             	shl    $0x4,%eax
801090e2:	89 c2                	mov    %eax,%edx
801090e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090e7:	01 d0                	add    %edx,%eax
801090e9:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801090ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090f0:	c1 e0 04             	shl    $0x4,%eax
801090f3:	89 c2                	mov    %eax,%edx
801090f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090f8:	01 d0                	add    %edx,%eax
801090fa:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801090fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109101:	c1 e0 04             	shl    $0x4,%eax
80109104:	89 c2                	mov    %eax,%edx
80109106:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109109:	01 d0                	add    %edx,%eax
8010910b:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010910f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109112:	c1 e0 04             	shl    $0x4,%eax
80109115:	89 c2                	mov    %eax,%edx
80109117:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010911a:	01 d0                	add    %edx,%eax
8010911c:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109122:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109125:	c1 e0 04             	shl    $0x4,%eax
80109128:	89 c2                	mov    %eax,%edx
8010912a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010912d:	01 d0                	add    %edx,%eax
8010912f:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109133:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109136:	8b 00                	mov    (%eax),%eax
80109138:	83 c0 01             	add    $0x1,%eax
8010913b:	0f b6 d0             	movzbl %al,%edx
8010913e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109141:	89 10                	mov    %edx,(%eax)
    return len;
80109143:	8b 45 0c             	mov    0xc(%ebp),%eax
80109146:	eb 05                	jmp    8010914d <i8254_send+0x11f>
  }else{
    return -1;
80109148:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010914d:	c9                   	leave  
8010914e:	c3                   	ret    

8010914f <i8254_intr>:

void i8254_intr(){
8010914f:	f3 0f 1e fb          	endbr32 
80109153:	55                   	push   %ebp
80109154:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109156:	a1 b8 80 19 80       	mov    0x801980b8,%eax
8010915b:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109161:	90                   	nop
80109162:	5d                   	pop    %ebp
80109163:	c3                   	ret    

80109164 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109164:	f3 0f 1e fb          	endbr32 
80109168:	55                   	push   %ebp
80109169:	89 e5                	mov    %esp,%ebp
8010916b:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010916e:	8b 45 08             	mov    0x8(%ebp),%eax
80109171:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109177:	0f b7 00             	movzwl (%eax),%eax
8010917a:	66 3d 00 01          	cmp    $0x100,%ax
8010917e:	74 0a                	je     8010918a <arp_proc+0x26>
80109180:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109185:	e9 4f 01 00 00       	jmp    801092d9 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
8010918a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918d:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109191:	66 83 f8 08          	cmp    $0x8,%ax
80109195:	74 0a                	je     801091a1 <arp_proc+0x3d>
80109197:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010919c:	e9 38 01 00 00       	jmp    801092d9 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
801091a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801091a8:	3c 06                	cmp    $0x6,%al
801091aa:	74 0a                	je     801091b6 <arp_proc+0x52>
801091ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091b1:	e9 23 01 00 00       	jmp    801092d9 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
801091b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b9:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801091bd:	3c 04                	cmp    $0x4,%al
801091bf:	74 0a                	je     801091cb <arp_proc+0x67>
801091c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091c6:	e9 0e 01 00 00       	jmp    801092d9 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801091cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ce:	83 c0 18             	add    $0x18,%eax
801091d1:	83 ec 04             	sub    $0x4,%esp
801091d4:	6a 04                	push   $0x4
801091d6:	50                   	push   %eax
801091d7:	68 e4 f4 10 80       	push   $0x8010f4e4
801091dc:	e8 44 bc ff ff       	call   80104e25 <memcmp>
801091e1:	83 c4 10             	add    $0x10,%esp
801091e4:	85 c0                	test   %eax,%eax
801091e6:	74 27                	je     8010920f <arp_proc+0xab>
801091e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091eb:	83 c0 0e             	add    $0xe,%eax
801091ee:	83 ec 04             	sub    $0x4,%esp
801091f1:	6a 04                	push   $0x4
801091f3:	50                   	push   %eax
801091f4:	68 e4 f4 10 80       	push   $0x8010f4e4
801091f9:	e8 27 bc ff ff       	call   80104e25 <memcmp>
801091fe:	83 c4 10             	add    $0x10,%esp
80109201:	85 c0                	test   %eax,%eax
80109203:	74 0a                	je     8010920f <arp_proc+0xab>
80109205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010920a:	e9 ca 00 00 00       	jmp    801092d9 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010920f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109212:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109216:	66 3d 00 01          	cmp    $0x100,%ax
8010921a:	75 69                	jne    80109285 <arp_proc+0x121>
8010921c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010921f:	83 c0 18             	add    $0x18,%eax
80109222:	83 ec 04             	sub    $0x4,%esp
80109225:	6a 04                	push   $0x4
80109227:	50                   	push   %eax
80109228:	68 e4 f4 10 80       	push   $0x8010f4e4
8010922d:	e8 f3 bb ff ff       	call   80104e25 <memcmp>
80109232:	83 c4 10             	add    $0x10,%esp
80109235:	85 c0                	test   %eax,%eax
80109237:	75 4c                	jne    80109285 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109239:	e8 54 96 ff ff       	call   80102892 <kalloc>
8010923e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109241:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109248:	83 ec 04             	sub    $0x4,%esp
8010924b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010924e:	50                   	push   %eax
8010924f:	ff 75 f0             	pushl  -0x10(%ebp)
80109252:	ff 75 f4             	pushl  -0xc(%ebp)
80109255:	e8 33 04 00 00       	call   8010968d <arp_reply_pkt_create>
8010925a:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010925d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109260:	83 ec 08             	sub    $0x8,%esp
80109263:	50                   	push   %eax
80109264:	ff 75 f0             	pushl  -0x10(%ebp)
80109267:	e8 c2 fd ff ff       	call   8010902e <i8254_send>
8010926c:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010926f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109272:	83 ec 0c             	sub    $0xc,%esp
80109275:	50                   	push   %eax
80109276:	e8 79 95 ff ff       	call   801027f4 <kfree>
8010927b:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010927e:	b8 02 00 00 00       	mov    $0x2,%eax
80109283:	eb 54                	jmp    801092d9 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109288:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010928c:	66 3d 00 02          	cmp    $0x200,%ax
80109290:	75 42                	jne    801092d4 <arp_proc+0x170>
80109292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109295:	83 c0 18             	add    $0x18,%eax
80109298:	83 ec 04             	sub    $0x4,%esp
8010929b:	6a 04                	push   $0x4
8010929d:	50                   	push   %eax
8010929e:	68 e4 f4 10 80       	push   $0x8010f4e4
801092a3:	e8 7d bb ff ff       	call   80104e25 <memcmp>
801092a8:	83 c4 10             	add    $0x10,%esp
801092ab:	85 c0                	test   %eax,%eax
801092ad:	75 25                	jne    801092d4 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
801092af:	83 ec 0c             	sub    $0xc,%esp
801092b2:	68 bc c4 10 80       	push   $0x8010c4bc
801092b7:	e8 50 71 ff ff       	call   8010040c <cprintf>
801092bc:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801092bf:	83 ec 0c             	sub    $0xc,%esp
801092c2:	ff 75 f4             	pushl  -0xc(%ebp)
801092c5:	e8 b7 01 00 00       	call   80109481 <arp_table_update>
801092ca:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801092cd:	b8 01 00 00 00       	mov    $0x1,%eax
801092d2:	eb 05                	jmp    801092d9 <arp_proc+0x175>
  }else{
    return -1;
801092d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801092d9:	c9                   	leave  
801092da:	c3                   	ret    

801092db <arp_scan>:

void arp_scan(){
801092db:	f3 0f 1e fb          	endbr32 
801092df:	55                   	push   %ebp
801092e0:	89 e5                	mov    %esp,%ebp
801092e2:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801092e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801092ec:	eb 6f                	jmp    8010935d <arp_scan+0x82>
    uint send = (uint)kalloc();
801092ee:	e8 9f 95 ff ff       	call   80102892 <kalloc>
801092f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801092f6:	83 ec 04             	sub    $0x4,%esp
801092f9:	ff 75 f4             	pushl  -0xc(%ebp)
801092fc:	8d 45 e8             	lea    -0x18(%ebp),%eax
801092ff:	50                   	push   %eax
80109300:	ff 75 ec             	pushl  -0x14(%ebp)
80109303:	e8 62 00 00 00       	call   8010936a <arp_broadcast>
80109308:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
8010930b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010930e:	83 ec 08             	sub    $0x8,%esp
80109311:	50                   	push   %eax
80109312:	ff 75 ec             	pushl  -0x14(%ebp)
80109315:	e8 14 fd ff ff       	call   8010902e <i8254_send>
8010931a:	83 c4 10             	add    $0x10,%esp
8010931d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109320:	eb 22                	jmp    80109344 <arp_scan+0x69>
      microdelay(1);
80109322:	83 ec 0c             	sub    $0xc,%esp
80109325:	6a 01                	push   $0x1
80109327:	e8 18 99 ff ff       	call   80102c44 <microdelay>
8010932c:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010932f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109332:	83 ec 08             	sub    $0x8,%esp
80109335:	50                   	push   %eax
80109336:	ff 75 ec             	pushl  -0x14(%ebp)
80109339:	e8 f0 fc ff ff       	call   8010902e <i8254_send>
8010933e:	83 c4 10             	add    $0x10,%esp
80109341:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109344:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109348:	74 d8                	je     80109322 <arp_scan+0x47>
    }
    kfree((char *)send);
8010934a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010934d:	83 ec 0c             	sub    $0xc,%esp
80109350:	50                   	push   %eax
80109351:	e8 9e 94 ff ff       	call   801027f4 <kfree>
80109356:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109359:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010935d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109364:	7e 88                	jle    801092ee <arp_scan+0x13>
  }
}
80109366:	90                   	nop
80109367:	90                   	nop
80109368:	c9                   	leave  
80109369:	c3                   	ret    

8010936a <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010936a:	f3 0f 1e fb          	endbr32 
8010936e:	55                   	push   %ebp
8010936f:	89 e5                	mov    %esp,%ebp
80109371:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109374:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109378:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
8010937c:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109380:	8b 45 10             	mov    0x10(%ebp),%eax
80109383:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109386:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
8010938d:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109393:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010939a:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801093a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801093a3:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801093a9:	8b 45 08             	mov    0x8(%ebp),%eax
801093ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801093af:	8b 45 08             	mov    0x8(%ebp),%eax
801093b2:	83 c0 0e             	add    $0xe,%eax
801093b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801093b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093bb:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801093bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c2:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801093c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c9:	83 ec 04             	sub    $0x4,%esp
801093cc:	6a 06                	push   $0x6
801093ce:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801093d1:	52                   	push   %edx
801093d2:	50                   	push   %eax
801093d3:	e8 a9 ba ff ff       	call   80104e81 <memmove>
801093d8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801093db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093de:	83 c0 06             	add    $0x6,%eax
801093e1:	83 ec 04             	sub    $0x4,%esp
801093e4:	6a 06                	push   $0x6
801093e6:	68 68 d0 18 80       	push   $0x8018d068
801093eb:	50                   	push   %eax
801093ec:	e8 90 ba ff ff       	call   80104e81 <memmove>
801093f1:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801093f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093f7:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801093fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ff:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109405:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109408:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010940c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010940f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109413:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109416:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010941c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010941f:	8d 50 12             	lea    0x12(%eax),%edx
80109422:	83 ec 04             	sub    $0x4,%esp
80109425:	6a 06                	push   $0x6
80109427:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010942a:	50                   	push   %eax
8010942b:	52                   	push   %edx
8010942c:	e8 50 ba ff ff       	call   80104e81 <memmove>
80109431:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109437:	8d 50 18             	lea    0x18(%eax),%edx
8010943a:	83 ec 04             	sub    $0x4,%esp
8010943d:	6a 04                	push   $0x4
8010943f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109442:	50                   	push   %eax
80109443:	52                   	push   %edx
80109444:	e8 38 ba ff ff       	call   80104e81 <memmove>
80109449:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010944c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010944f:	83 c0 08             	add    $0x8,%eax
80109452:	83 ec 04             	sub    $0x4,%esp
80109455:	6a 06                	push   $0x6
80109457:	68 68 d0 18 80       	push   $0x8018d068
8010945c:	50                   	push   %eax
8010945d:	e8 1f ba ff ff       	call   80104e81 <memmove>
80109462:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109465:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109468:	83 c0 0e             	add    $0xe,%eax
8010946b:	83 ec 04             	sub    $0x4,%esp
8010946e:	6a 04                	push   $0x4
80109470:	68 e4 f4 10 80       	push   $0x8010f4e4
80109475:	50                   	push   %eax
80109476:	e8 06 ba ff ff       	call   80104e81 <memmove>
8010947b:	83 c4 10             	add    $0x10,%esp
}
8010947e:	90                   	nop
8010947f:	c9                   	leave  
80109480:	c3                   	ret    

80109481 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109481:	f3 0f 1e fb          	endbr32 
80109485:	55                   	push   %ebp
80109486:	89 e5                	mov    %esp,%ebp
80109488:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010948b:	8b 45 08             	mov    0x8(%ebp),%eax
8010948e:	83 c0 0e             	add    $0xe,%eax
80109491:	83 ec 0c             	sub    $0xc,%esp
80109494:	50                   	push   %eax
80109495:	e8 bc 00 00 00       	call   80109556 <arp_table_search>
8010949a:	83 c4 10             	add    $0x10,%esp
8010949d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801094a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801094a4:	78 2d                	js     801094d3 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801094a6:	8b 45 08             	mov    0x8(%ebp),%eax
801094a9:	8d 48 08             	lea    0x8(%eax),%ecx
801094ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094af:	89 d0                	mov    %edx,%eax
801094b1:	c1 e0 02             	shl    $0x2,%eax
801094b4:	01 d0                	add    %edx,%eax
801094b6:	01 c0                	add    %eax,%eax
801094b8:	01 d0                	add    %edx,%eax
801094ba:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094bf:	83 c0 04             	add    $0x4,%eax
801094c2:	83 ec 04             	sub    $0x4,%esp
801094c5:	6a 06                	push   $0x6
801094c7:	51                   	push   %ecx
801094c8:	50                   	push   %eax
801094c9:	e8 b3 b9 ff ff       	call   80104e81 <memmove>
801094ce:	83 c4 10             	add    $0x10,%esp
801094d1:	eb 70                	jmp    80109543 <arp_table_update+0xc2>
  }else{
    index += 1;
801094d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801094d7:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801094da:	8b 45 08             	mov    0x8(%ebp),%eax
801094dd:	8d 48 08             	lea    0x8(%eax),%ecx
801094e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094e3:	89 d0                	mov    %edx,%eax
801094e5:	c1 e0 02             	shl    $0x2,%eax
801094e8:	01 d0                	add    %edx,%eax
801094ea:	01 c0                	add    %eax,%eax
801094ec:	01 d0                	add    %edx,%eax
801094ee:	05 80 d0 18 80       	add    $0x8018d080,%eax
801094f3:	83 c0 04             	add    $0x4,%eax
801094f6:	83 ec 04             	sub    $0x4,%esp
801094f9:	6a 06                	push   $0x6
801094fb:	51                   	push   %ecx
801094fc:	50                   	push   %eax
801094fd:	e8 7f b9 ff ff       	call   80104e81 <memmove>
80109502:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109505:	8b 45 08             	mov    0x8(%ebp),%eax
80109508:	8d 48 0e             	lea    0xe(%eax),%ecx
8010950b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010950e:	89 d0                	mov    %edx,%eax
80109510:	c1 e0 02             	shl    $0x2,%eax
80109513:	01 d0                	add    %edx,%eax
80109515:	01 c0                	add    %eax,%eax
80109517:	01 d0                	add    %edx,%eax
80109519:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010951e:	83 ec 04             	sub    $0x4,%esp
80109521:	6a 04                	push   $0x4
80109523:	51                   	push   %ecx
80109524:	50                   	push   %eax
80109525:	e8 57 b9 ff ff       	call   80104e81 <memmove>
8010952a:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010952d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109530:	89 d0                	mov    %edx,%eax
80109532:	c1 e0 02             	shl    $0x2,%eax
80109535:	01 d0                	add    %edx,%eax
80109537:	01 c0                	add    %eax,%eax
80109539:	01 d0                	add    %edx,%eax
8010953b:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109540:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109543:	83 ec 0c             	sub    $0xc,%esp
80109546:	68 80 d0 18 80       	push   $0x8018d080
8010954b:	e8 87 00 00 00       	call   801095d7 <print_arp_table>
80109550:	83 c4 10             	add    $0x10,%esp
}
80109553:	90                   	nop
80109554:	c9                   	leave  
80109555:	c3                   	ret    

80109556 <arp_table_search>:

int arp_table_search(uchar *ip){
80109556:	f3 0f 1e fb          	endbr32 
8010955a:	55                   	push   %ebp
8010955b:	89 e5                	mov    %esp,%ebp
8010955d:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109560:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109567:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010956e:	eb 59                	jmp    801095c9 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109570:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109573:	89 d0                	mov    %edx,%eax
80109575:	c1 e0 02             	shl    $0x2,%eax
80109578:	01 d0                	add    %edx,%eax
8010957a:	01 c0                	add    %eax,%eax
8010957c:	01 d0                	add    %edx,%eax
8010957e:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109583:	83 ec 04             	sub    $0x4,%esp
80109586:	6a 04                	push   $0x4
80109588:	ff 75 08             	pushl  0x8(%ebp)
8010958b:	50                   	push   %eax
8010958c:	e8 94 b8 ff ff       	call   80104e25 <memcmp>
80109591:	83 c4 10             	add    $0x10,%esp
80109594:	85 c0                	test   %eax,%eax
80109596:	75 05                	jne    8010959d <arp_table_search+0x47>
      return i;
80109598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010959b:	eb 38                	jmp    801095d5 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010959d:	8b 55 f0             	mov    -0x10(%ebp),%edx
801095a0:	89 d0                	mov    %edx,%eax
801095a2:	c1 e0 02             	shl    $0x2,%eax
801095a5:	01 d0                	add    %edx,%eax
801095a7:	01 c0                	add    %eax,%eax
801095a9:	01 d0                	add    %edx,%eax
801095ab:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801095b0:	0f b6 00             	movzbl (%eax),%eax
801095b3:	84 c0                	test   %al,%al
801095b5:	75 0e                	jne    801095c5 <arp_table_search+0x6f>
801095b7:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801095bb:	75 08                	jne    801095c5 <arp_table_search+0x6f>
      empty = -i;
801095bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c0:	f7 d8                	neg    %eax
801095c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801095c5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801095c9:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801095cd:	7e a1                	jle    80109570 <arp_table_search+0x1a>
    }
  }
  return empty-1;
801095cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d2:	83 e8 01             	sub    $0x1,%eax
}
801095d5:	c9                   	leave  
801095d6:	c3                   	ret    

801095d7 <print_arp_table>:

void print_arp_table(){
801095d7:	f3 0f 1e fb          	endbr32 
801095db:	55                   	push   %ebp
801095dc:	89 e5                	mov    %esp,%ebp
801095de:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801095e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801095e8:	e9 92 00 00 00       	jmp    8010967f <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
801095ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095f0:	89 d0                	mov    %edx,%eax
801095f2:	c1 e0 02             	shl    $0x2,%eax
801095f5:	01 d0                	add    %edx,%eax
801095f7:	01 c0                	add    %eax,%eax
801095f9:	01 d0                	add    %edx,%eax
801095fb:	05 8a d0 18 80       	add    $0x8018d08a,%eax
80109600:	0f b6 00             	movzbl (%eax),%eax
80109603:	84 c0                	test   %al,%al
80109605:	74 74                	je     8010967b <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109607:	83 ec 08             	sub    $0x8,%esp
8010960a:	ff 75 f4             	pushl  -0xc(%ebp)
8010960d:	68 cf c4 10 80       	push   $0x8010c4cf
80109612:	e8 f5 6d ff ff       	call   8010040c <cprintf>
80109617:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
8010961a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010961d:	89 d0                	mov    %edx,%eax
8010961f:	c1 e0 02             	shl    $0x2,%eax
80109622:	01 d0                	add    %edx,%eax
80109624:	01 c0                	add    %eax,%eax
80109626:	01 d0                	add    %edx,%eax
80109628:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010962d:	83 ec 0c             	sub    $0xc,%esp
80109630:	50                   	push   %eax
80109631:	e8 5c 02 00 00       	call   80109892 <print_ipv4>
80109636:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109639:	83 ec 0c             	sub    $0xc,%esp
8010963c:	68 de c4 10 80       	push   $0x8010c4de
80109641:	e8 c6 6d ff ff       	call   8010040c <cprintf>
80109646:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109649:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010964c:	89 d0                	mov    %edx,%eax
8010964e:	c1 e0 02             	shl    $0x2,%eax
80109651:	01 d0                	add    %edx,%eax
80109653:	01 c0                	add    %eax,%eax
80109655:	01 d0                	add    %edx,%eax
80109657:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010965c:	83 c0 04             	add    $0x4,%eax
8010965f:	83 ec 0c             	sub    $0xc,%esp
80109662:	50                   	push   %eax
80109663:	e8 7c 02 00 00       	call   801098e4 <print_mac>
80109668:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
8010966b:	83 ec 0c             	sub    $0xc,%esp
8010966e:	68 e0 c4 10 80       	push   $0x8010c4e0
80109673:	e8 94 6d ff ff       	call   8010040c <cprintf>
80109678:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010967b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010967f:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109683:	0f 8e 64 ff ff ff    	jle    801095ed <print_arp_table+0x16>
    }
  }
}
80109689:	90                   	nop
8010968a:	90                   	nop
8010968b:	c9                   	leave  
8010968c:	c3                   	ret    

8010968d <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
8010968d:	f3 0f 1e fb          	endbr32 
80109691:	55                   	push   %ebp
80109692:	89 e5                	mov    %esp,%ebp
80109694:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109697:	8b 45 10             	mov    0x10(%ebp),%eax
8010969a:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801096a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801096a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801096a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801096a9:	83 c0 0e             	add    $0xe,%eax
801096ac:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801096af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b2:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801096b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b9:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801096bd:	8b 45 08             	mov    0x8(%ebp),%eax
801096c0:	8d 50 08             	lea    0x8(%eax),%edx
801096c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c6:	83 ec 04             	sub    $0x4,%esp
801096c9:	6a 06                	push   $0x6
801096cb:	52                   	push   %edx
801096cc:	50                   	push   %eax
801096cd:	e8 af b7 ff ff       	call   80104e81 <memmove>
801096d2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801096d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096d8:	83 c0 06             	add    $0x6,%eax
801096db:	83 ec 04             	sub    $0x4,%esp
801096de:	6a 06                	push   $0x6
801096e0:	68 68 d0 18 80       	push   $0x8018d068
801096e5:	50                   	push   %eax
801096e6:	e8 96 b7 ff ff       	call   80104e81 <memmove>
801096eb:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801096ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096f1:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801096f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096f9:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801096ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109702:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109706:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109709:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010970d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109710:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109716:	8b 45 08             	mov    0x8(%ebp),%eax
80109719:	8d 50 08             	lea    0x8(%eax),%edx
8010971c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010971f:	83 c0 12             	add    $0x12,%eax
80109722:	83 ec 04             	sub    $0x4,%esp
80109725:	6a 06                	push   $0x6
80109727:	52                   	push   %edx
80109728:	50                   	push   %eax
80109729:	e8 53 b7 ff ff       	call   80104e81 <memmove>
8010972e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109731:	8b 45 08             	mov    0x8(%ebp),%eax
80109734:	8d 50 0e             	lea    0xe(%eax),%edx
80109737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010973a:	83 c0 18             	add    $0x18,%eax
8010973d:	83 ec 04             	sub    $0x4,%esp
80109740:	6a 04                	push   $0x4
80109742:	52                   	push   %edx
80109743:	50                   	push   %eax
80109744:	e8 38 b7 ff ff       	call   80104e81 <memmove>
80109749:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
8010974c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010974f:	83 c0 08             	add    $0x8,%eax
80109752:	83 ec 04             	sub    $0x4,%esp
80109755:	6a 06                	push   $0x6
80109757:	68 68 d0 18 80       	push   $0x8018d068
8010975c:	50                   	push   %eax
8010975d:	e8 1f b7 ff ff       	call   80104e81 <memmove>
80109762:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109768:	83 c0 0e             	add    $0xe,%eax
8010976b:	83 ec 04             	sub    $0x4,%esp
8010976e:	6a 04                	push   $0x4
80109770:	68 e4 f4 10 80       	push   $0x8010f4e4
80109775:	50                   	push   %eax
80109776:	e8 06 b7 ff ff       	call   80104e81 <memmove>
8010977b:	83 c4 10             	add    $0x10,%esp
}
8010977e:	90                   	nop
8010977f:	c9                   	leave  
80109780:	c3                   	ret    

80109781 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109781:	f3 0f 1e fb          	endbr32 
80109785:	55                   	push   %ebp
80109786:	89 e5                	mov    %esp,%ebp
80109788:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010978b:	83 ec 0c             	sub    $0xc,%esp
8010978e:	68 e2 c4 10 80       	push   $0x8010c4e2
80109793:	e8 74 6c ff ff       	call   8010040c <cprintf>
80109798:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010979b:	8b 45 08             	mov    0x8(%ebp),%eax
8010979e:	83 c0 0e             	add    $0xe,%eax
801097a1:	83 ec 0c             	sub    $0xc,%esp
801097a4:	50                   	push   %eax
801097a5:	e8 e8 00 00 00       	call   80109892 <print_ipv4>
801097aa:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097ad:	83 ec 0c             	sub    $0xc,%esp
801097b0:	68 e0 c4 10 80       	push   $0x8010c4e0
801097b5:	e8 52 6c ff ff       	call   8010040c <cprintf>
801097ba:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801097bd:	8b 45 08             	mov    0x8(%ebp),%eax
801097c0:	83 c0 08             	add    $0x8,%eax
801097c3:	83 ec 0c             	sub    $0xc,%esp
801097c6:	50                   	push   %eax
801097c7:	e8 18 01 00 00       	call   801098e4 <print_mac>
801097cc:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097cf:	83 ec 0c             	sub    $0xc,%esp
801097d2:	68 e0 c4 10 80       	push   $0x8010c4e0
801097d7:	e8 30 6c ff ff       	call   8010040c <cprintf>
801097dc:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801097df:	83 ec 0c             	sub    $0xc,%esp
801097e2:	68 f9 c4 10 80       	push   $0x8010c4f9
801097e7:	e8 20 6c ff ff       	call   8010040c <cprintf>
801097ec:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801097ef:	8b 45 08             	mov    0x8(%ebp),%eax
801097f2:	83 c0 18             	add    $0x18,%eax
801097f5:	83 ec 0c             	sub    $0xc,%esp
801097f8:	50                   	push   %eax
801097f9:	e8 94 00 00 00       	call   80109892 <print_ipv4>
801097fe:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109801:	83 ec 0c             	sub    $0xc,%esp
80109804:	68 e0 c4 10 80       	push   $0x8010c4e0
80109809:	e8 fe 6b ff ff       	call   8010040c <cprintf>
8010980e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109811:	8b 45 08             	mov    0x8(%ebp),%eax
80109814:	83 c0 12             	add    $0x12,%eax
80109817:	83 ec 0c             	sub    $0xc,%esp
8010981a:	50                   	push   %eax
8010981b:	e8 c4 00 00 00       	call   801098e4 <print_mac>
80109820:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109823:	83 ec 0c             	sub    $0xc,%esp
80109826:	68 e0 c4 10 80       	push   $0x8010c4e0
8010982b:	e8 dc 6b ff ff       	call   8010040c <cprintf>
80109830:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109833:	83 ec 0c             	sub    $0xc,%esp
80109836:	68 10 c5 10 80       	push   $0x8010c510
8010983b:	e8 cc 6b ff ff       	call   8010040c <cprintf>
80109840:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109843:	8b 45 08             	mov    0x8(%ebp),%eax
80109846:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010984a:	66 3d 00 01          	cmp    $0x100,%ax
8010984e:	75 12                	jne    80109862 <print_arp_info+0xe1>
80109850:	83 ec 0c             	sub    $0xc,%esp
80109853:	68 1c c5 10 80       	push   $0x8010c51c
80109858:	e8 af 6b ff ff       	call   8010040c <cprintf>
8010985d:	83 c4 10             	add    $0x10,%esp
80109860:	eb 1d                	jmp    8010987f <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109862:	8b 45 08             	mov    0x8(%ebp),%eax
80109865:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109869:	66 3d 00 02          	cmp    $0x200,%ax
8010986d:	75 10                	jne    8010987f <print_arp_info+0xfe>
    cprintf("Reply\n");
8010986f:	83 ec 0c             	sub    $0xc,%esp
80109872:	68 25 c5 10 80       	push   $0x8010c525
80109877:	e8 90 6b ff ff       	call   8010040c <cprintf>
8010987c:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010987f:	83 ec 0c             	sub    $0xc,%esp
80109882:	68 e0 c4 10 80       	push   $0x8010c4e0
80109887:	e8 80 6b ff ff       	call   8010040c <cprintf>
8010988c:	83 c4 10             	add    $0x10,%esp
}
8010988f:	90                   	nop
80109890:	c9                   	leave  
80109891:	c3                   	ret    

80109892 <print_ipv4>:

void print_ipv4(uchar *ip){
80109892:	f3 0f 1e fb          	endbr32 
80109896:	55                   	push   %ebp
80109897:	89 e5                	mov    %esp,%ebp
80109899:	53                   	push   %ebx
8010989a:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010989d:	8b 45 08             	mov    0x8(%ebp),%eax
801098a0:	83 c0 03             	add    $0x3,%eax
801098a3:	0f b6 00             	movzbl (%eax),%eax
801098a6:	0f b6 d8             	movzbl %al,%ebx
801098a9:	8b 45 08             	mov    0x8(%ebp),%eax
801098ac:	83 c0 02             	add    $0x2,%eax
801098af:	0f b6 00             	movzbl (%eax),%eax
801098b2:	0f b6 c8             	movzbl %al,%ecx
801098b5:	8b 45 08             	mov    0x8(%ebp),%eax
801098b8:	83 c0 01             	add    $0x1,%eax
801098bb:	0f b6 00             	movzbl (%eax),%eax
801098be:	0f b6 d0             	movzbl %al,%edx
801098c1:	8b 45 08             	mov    0x8(%ebp),%eax
801098c4:	0f b6 00             	movzbl (%eax),%eax
801098c7:	0f b6 c0             	movzbl %al,%eax
801098ca:	83 ec 0c             	sub    $0xc,%esp
801098cd:	53                   	push   %ebx
801098ce:	51                   	push   %ecx
801098cf:	52                   	push   %edx
801098d0:	50                   	push   %eax
801098d1:	68 2c c5 10 80       	push   $0x8010c52c
801098d6:	e8 31 6b ff ff       	call   8010040c <cprintf>
801098db:	83 c4 20             	add    $0x20,%esp
}
801098de:	90                   	nop
801098df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801098e2:	c9                   	leave  
801098e3:	c3                   	ret    

801098e4 <print_mac>:

void print_mac(uchar *mac){
801098e4:	f3 0f 1e fb          	endbr32 
801098e8:	55                   	push   %ebp
801098e9:	89 e5                	mov    %esp,%ebp
801098eb:	57                   	push   %edi
801098ec:	56                   	push   %esi
801098ed:	53                   	push   %ebx
801098ee:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801098f1:	8b 45 08             	mov    0x8(%ebp),%eax
801098f4:	83 c0 05             	add    $0x5,%eax
801098f7:	0f b6 00             	movzbl (%eax),%eax
801098fa:	0f b6 f8             	movzbl %al,%edi
801098fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109900:	83 c0 04             	add    $0x4,%eax
80109903:	0f b6 00             	movzbl (%eax),%eax
80109906:	0f b6 f0             	movzbl %al,%esi
80109909:	8b 45 08             	mov    0x8(%ebp),%eax
8010990c:	83 c0 03             	add    $0x3,%eax
8010990f:	0f b6 00             	movzbl (%eax),%eax
80109912:	0f b6 d8             	movzbl %al,%ebx
80109915:	8b 45 08             	mov    0x8(%ebp),%eax
80109918:	83 c0 02             	add    $0x2,%eax
8010991b:	0f b6 00             	movzbl (%eax),%eax
8010991e:	0f b6 c8             	movzbl %al,%ecx
80109921:	8b 45 08             	mov    0x8(%ebp),%eax
80109924:	83 c0 01             	add    $0x1,%eax
80109927:	0f b6 00             	movzbl (%eax),%eax
8010992a:	0f b6 d0             	movzbl %al,%edx
8010992d:	8b 45 08             	mov    0x8(%ebp),%eax
80109930:	0f b6 00             	movzbl (%eax),%eax
80109933:	0f b6 c0             	movzbl %al,%eax
80109936:	83 ec 04             	sub    $0x4,%esp
80109939:	57                   	push   %edi
8010993a:	56                   	push   %esi
8010993b:	53                   	push   %ebx
8010993c:	51                   	push   %ecx
8010993d:	52                   	push   %edx
8010993e:	50                   	push   %eax
8010993f:	68 44 c5 10 80       	push   $0x8010c544
80109944:	e8 c3 6a ff ff       	call   8010040c <cprintf>
80109949:	83 c4 20             	add    $0x20,%esp
}
8010994c:	90                   	nop
8010994d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109950:	5b                   	pop    %ebx
80109951:	5e                   	pop    %esi
80109952:	5f                   	pop    %edi
80109953:	5d                   	pop    %ebp
80109954:	c3                   	ret    

80109955 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109955:	f3 0f 1e fb          	endbr32 
80109959:	55                   	push   %ebp
8010995a:	89 e5                	mov    %esp,%ebp
8010995c:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010995f:	8b 45 08             	mov    0x8(%ebp),%eax
80109962:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109965:	8b 45 08             	mov    0x8(%ebp),%eax
80109968:	83 c0 0e             	add    $0xe,%eax
8010996b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010996e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109971:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109975:	3c 08                	cmp    $0x8,%al
80109977:	75 1b                	jne    80109994 <eth_proc+0x3f>
80109979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010997c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109980:	3c 06                	cmp    $0x6,%al
80109982:	75 10                	jne    80109994 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109984:	83 ec 0c             	sub    $0xc,%esp
80109987:	ff 75 f0             	pushl  -0x10(%ebp)
8010998a:	e8 d5 f7 ff ff       	call   80109164 <arp_proc>
8010998f:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109992:	eb 24                	jmp    801099b8 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109997:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010999b:	3c 08                	cmp    $0x8,%al
8010999d:	75 19                	jne    801099b8 <eth_proc+0x63>
8010999f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801099a6:	84 c0                	test   %al,%al
801099a8:	75 0e                	jne    801099b8 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
801099aa:	83 ec 0c             	sub    $0xc,%esp
801099ad:	ff 75 08             	pushl  0x8(%ebp)
801099b0:	e8 b3 00 00 00       	call   80109a68 <ipv4_proc>
801099b5:	83 c4 10             	add    $0x10,%esp
}
801099b8:	90                   	nop
801099b9:	c9                   	leave  
801099ba:	c3                   	ret    

801099bb <N2H_ushort>:

ushort N2H_ushort(ushort value){
801099bb:	f3 0f 1e fb          	endbr32 
801099bf:	55                   	push   %ebp
801099c0:	89 e5                	mov    %esp,%ebp
801099c2:	83 ec 04             	sub    $0x4,%esp
801099c5:	8b 45 08             	mov    0x8(%ebp),%eax
801099c8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801099cc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099d0:	c1 e0 08             	shl    $0x8,%eax
801099d3:	89 c2                	mov    %eax,%edx
801099d5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099d9:	66 c1 e8 08          	shr    $0x8,%ax
801099dd:	01 d0                	add    %edx,%eax
}
801099df:	c9                   	leave  
801099e0:	c3                   	ret    

801099e1 <H2N_ushort>:

ushort H2N_ushort(ushort value){
801099e1:	f3 0f 1e fb          	endbr32 
801099e5:	55                   	push   %ebp
801099e6:	89 e5                	mov    %esp,%ebp
801099e8:	83 ec 04             	sub    $0x4,%esp
801099eb:	8b 45 08             	mov    0x8(%ebp),%eax
801099ee:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
801099f2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099f6:	c1 e0 08             	shl    $0x8,%eax
801099f9:	89 c2                	mov    %eax,%edx
801099fb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801099ff:	66 c1 e8 08          	shr    $0x8,%ax
80109a03:	01 d0                	add    %edx,%eax
}
80109a05:	c9                   	leave  
80109a06:	c3                   	ret    

80109a07 <H2N_uint>:

uint H2N_uint(uint value){
80109a07:	f3 0f 1e fb          	endbr32 
80109a0b:	55                   	push   %ebp
80109a0c:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80109a11:	c1 e0 18             	shl    $0x18,%eax
80109a14:	25 00 00 00 0f       	and    $0xf000000,%eax
80109a19:	89 c2                	mov    %eax,%edx
80109a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80109a1e:	c1 e0 08             	shl    $0x8,%eax
80109a21:	25 00 f0 00 00       	and    $0xf000,%eax
80109a26:	09 c2                	or     %eax,%edx
80109a28:	8b 45 08             	mov    0x8(%ebp),%eax
80109a2b:	c1 e8 08             	shr    $0x8,%eax
80109a2e:	83 e0 0f             	and    $0xf,%eax
80109a31:	01 d0                	add    %edx,%eax
}
80109a33:	5d                   	pop    %ebp
80109a34:	c3                   	ret    

80109a35 <N2H_uint>:

uint N2H_uint(uint value){
80109a35:	f3 0f 1e fb          	endbr32 
80109a39:	55                   	push   %ebp
80109a3a:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a3f:	c1 e0 18             	shl    $0x18,%eax
80109a42:	89 c2                	mov    %eax,%edx
80109a44:	8b 45 08             	mov    0x8(%ebp),%eax
80109a47:	c1 e0 08             	shl    $0x8,%eax
80109a4a:	25 00 00 ff 00       	and    $0xff0000,%eax
80109a4f:	01 c2                	add    %eax,%edx
80109a51:	8b 45 08             	mov    0x8(%ebp),%eax
80109a54:	c1 e8 08             	shr    $0x8,%eax
80109a57:	25 00 ff 00 00       	and    $0xff00,%eax
80109a5c:	01 c2                	add    %eax,%edx
80109a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109a61:	c1 e8 18             	shr    $0x18,%eax
80109a64:	01 d0                	add    %edx,%eax
}
80109a66:	5d                   	pop    %ebp
80109a67:	c3                   	ret    

80109a68 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109a68:	f3 0f 1e fb          	endbr32 
80109a6c:	55                   	push   %ebp
80109a6d:	89 e5                	mov    %esp,%ebp
80109a6f:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109a72:	8b 45 08             	mov    0x8(%ebp),%eax
80109a75:	83 c0 0e             	add    $0xe,%eax
80109a78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a7e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109a82:	0f b7 d0             	movzwl %ax,%edx
80109a85:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109a8a:	39 c2                	cmp    %eax,%edx
80109a8c:	74 60                	je     80109aee <ipv4_proc+0x86>
80109a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a91:	83 c0 0c             	add    $0xc,%eax
80109a94:	83 ec 04             	sub    $0x4,%esp
80109a97:	6a 04                	push   $0x4
80109a99:	50                   	push   %eax
80109a9a:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a9f:	e8 81 b3 ff ff       	call   80104e25 <memcmp>
80109aa4:	83 c4 10             	add    $0x10,%esp
80109aa7:	85 c0                	test   %eax,%eax
80109aa9:	74 43                	je     80109aee <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aae:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ab2:	0f b7 c0             	movzwl %ax,%eax
80109ab5:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109abd:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109ac1:	3c 01                	cmp    $0x1,%al
80109ac3:	75 10                	jne    80109ad5 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109ac5:	83 ec 0c             	sub    $0xc,%esp
80109ac8:	ff 75 08             	pushl  0x8(%ebp)
80109acb:	e8 a7 00 00 00       	call   80109b77 <icmp_proc>
80109ad0:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109ad3:	eb 19                	jmp    80109aee <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ad8:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109adc:	3c 06                	cmp    $0x6,%al
80109ade:	75 0e                	jne    80109aee <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109ae0:	83 ec 0c             	sub    $0xc,%esp
80109ae3:	ff 75 08             	pushl  0x8(%ebp)
80109ae6:	e8 c7 03 00 00       	call   80109eb2 <tcp_proc>
80109aeb:	83 c4 10             	add    $0x10,%esp
}
80109aee:	90                   	nop
80109aef:	c9                   	leave  
80109af0:	c3                   	ret    

80109af1 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109af1:	f3 0f 1e fb          	endbr32 
80109af5:	55                   	push   %ebp
80109af6:	89 e5                	mov    %esp,%ebp
80109af8:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109afb:	8b 45 08             	mov    0x8(%ebp),%eax
80109afe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b04:	0f b6 00             	movzbl (%eax),%eax
80109b07:	83 e0 0f             	and    $0xf,%eax
80109b0a:	01 c0                	add    %eax,%eax
80109b0c:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109b0f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b16:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109b1d:	eb 48                	jmp    80109b67 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109b1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b22:	01 c0                	add    %eax,%eax
80109b24:	89 c2                	mov    %eax,%edx
80109b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b29:	01 d0                	add    %edx,%eax
80109b2b:	0f b6 00             	movzbl (%eax),%eax
80109b2e:	0f b6 c0             	movzbl %al,%eax
80109b31:	c1 e0 08             	shl    $0x8,%eax
80109b34:	89 c2                	mov    %eax,%edx
80109b36:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109b39:	01 c0                	add    %eax,%eax
80109b3b:	8d 48 01             	lea    0x1(%eax),%ecx
80109b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b41:	01 c8                	add    %ecx,%eax
80109b43:	0f b6 00             	movzbl (%eax),%eax
80109b46:	0f b6 c0             	movzbl %al,%eax
80109b49:	01 d0                	add    %edx,%eax
80109b4b:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109b4e:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109b55:	76 0c                	jbe    80109b63 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109b57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b5a:	0f b7 c0             	movzwl %ax,%eax
80109b5d:	83 c0 01             	add    $0x1,%eax
80109b60:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109b63:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109b67:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109b6b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109b6e:	7c af                	jl     80109b1f <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109b70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109b73:	f7 d0                	not    %eax
}
80109b75:	c9                   	leave  
80109b76:	c3                   	ret    

80109b77 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109b77:	f3 0f 1e fb          	endbr32 
80109b7b:	55                   	push   %ebp
80109b7c:	89 e5                	mov    %esp,%ebp
80109b7e:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109b81:	8b 45 08             	mov    0x8(%ebp),%eax
80109b84:	83 c0 0e             	add    $0xe,%eax
80109b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b8d:	0f b6 00             	movzbl (%eax),%eax
80109b90:	0f b6 c0             	movzbl %al,%eax
80109b93:	83 e0 0f             	and    $0xf,%eax
80109b96:	c1 e0 02             	shl    $0x2,%eax
80109b99:	89 c2                	mov    %eax,%edx
80109b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b9e:	01 d0                	add    %edx,%eax
80109ba0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ba6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109baa:	84 c0                	test   %al,%al
80109bac:	75 4f                	jne    80109bfd <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bb1:	0f b6 00             	movzbl (%eax),%eax
80109bb4:	3c 08                	cmp    $0x8,%al
80109bb6:	75 45                	jne    80109bfd <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109bb8:	e8 d5 8c ff ff       	call   80102892 <kalloc>
80109bbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109bc0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109bc7:	83 ec 04             	sub    $0x4,%esp
80109bca:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109bcd:	50                   	push   %eax
80109bce:	ff 75 ec             	pushl  -0x14(%ebp)
80109bd1:	ff 75 08             	pushl  0x8(%ebp)
80109bd4:	e8 7c 00 00 00       	call   80109c55 <icmp_reply_pkt_create>
80109bd9:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109bdc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bdf:	83 ec 08             	sub    $0x8,%esp
80109be2:	50                   	push   %eax
80109be3:	ff 75 ec             	pushl  -0x14(%ebp)
80109be6:	e8 43 f4 ff ff       	call   8010902e <i8254_send>
80109beb:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bf1:	83 ec 0c             	sub    $0xc,%esp
80109bf4:	50                   	push   %eax
80109bf5:	e8 fa 8b ff ff       	call   801027f4 <kfree>
80109bfa:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109bfd:	90                   	nop
80109bfe:	c9                   	leave  
80109bff:	c3                   	ret    

80109c00 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109c00:	f3 0f 1e fb          	endbr32 
80109c04:	55                   	push   %ebp
80109c05:	89 e5                	mov    %esp,%ebp
80109c07:	53                   	push   %ebx
80109c08:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c0e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c12:	0f b7 c0             	movzwl %ax,%eax
80109c15:	83 ec 0c             	sub    $0xc,%esp
80109c18:	50                   	push   %eax
80109c19:	e8 9d fd ff ff       	call   801099bb <N2H_ushort>
80109c1e:	83 c4 10             	add    $0x10,%esp
80109c21:	0f b7 d8             	movzwl %ax,%ebx
80109c24:	8b 45 08             	mov    0x8(%ebp),%eax
80109c27:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c2b:	0f b7 c0             	movzwl %ax,%eax
80109c2e:	83 ec 0c             	sub    $0xc,%esp
80109c31:	50                   	push   %eax
80109c32:	e8 84 fd ff ff       	call   801099bb <N2H_ushort>
80109c37:	83 c4 10             	add    $0x10,%esp
80109c3a:	0f b7 c0             	movzwl %ax,%eax
80109c3d:	83 ec 04             	sub    $0x4,%esp
80109c40:	53                   	push   %ebx
80109c41:	50                   	push   %eax
80109c42:	68 63 c5 10 80       	push   $0x8010c563
80109c47:	e8 c0 67 ff ff       	call   8010040c <cprintf>
80109c4c:	83 c4 10             	add    $0x10,%esp
}
80109c4f:	90                   	nop
80109c50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c53:	c9                   	leave  
80109c54:	c3                   	ret    

80109c55 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109c55:	f3 0f 1e fb          	endbr32 
80109c59:	55                   	push   %ebp
80109c5a:	89 e5                	mov    %esp,%ebp
80109c5c:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109c65:	8b 45 08             	mov    0x8(%ebp),%eax
80109c68:	83 c0 0e             	add    $0xe,%eax
80109c6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c71:	0f b6 00             	movzbl (%eax),%eax
80109c74:	0f b6 c0             	movzbl %al,%eax
80109c77:	83 e0 0f             	and    $0xf,%eax
80109c7a:	c1 e0 02             	shl    $0x2,%eax
80109c7d:	89 c2                	mov    %eax,%edx
80109c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c82:	01 d0                	add    %edx,%eax
80109c84:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109c87:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c90:	83 c0 0e             	add    $0xe,%eax
80109c93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109c96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c99:	83 c0 14             	add    $0x14,%eax
80109c9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109c9f:	8b 45 10             	mov    0x10(%ebp),%eax
80109ca2:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cab:	8d 50 06             	lea    0x6(%eax),%edx
80109cae:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cb1:	83 ec 04             	sub    $0x4,%esp
80109cb4:	6a 06                	push   $0x6
80109cb6:	52                   	push   %edx
80109cb7:	50                   	push   %eax
80109cb8:	e8 c4 b1 ff ff       	call   80104e81 <memmove>
80109cbd:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109cc0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cc3:	83 c0 06             	add    $0x6,%eax
80109cc6:	83 ec 04             	sub    $0x4,%esp
80109cc9:	6a 06                	push   $0x6
80109ccb:	68 68 d0 18 80       	push   $0x8018d068
80109cd0:	50                   	push   %eax
80109cd1:	e8 ab b1 ff ff       	call   80104e81 <memmove>
80109cd6:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109cd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cdc:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109ce0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ce3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109ce7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cea:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109ced:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cf0:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109cf4:	83 ec 0c             	sub    $0xc,%esp
80109cf7:	6a 54                	push   $0x54
80109cf9:	e8 e3 fc ff ff       	call   801099e1 <H2N_ushort>
80109cfe:	83 c4 10             	add    $0x10,%esp
80109d01:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d04:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109d08:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109d0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d12:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109d16:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109d1d:	83 c0 01             	add    $0x1,%eax
80109d20:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109d26:	83 ec 0c             	sub    $0xc,%esp
80109d29:	68 00 40 00 00       	push   $0x4000
80109d2e:	e8 ae fc ff ff       	call   801099e1 <H2N_ushort>
80109d33:	83 c4 10             	add    $0x10,%esp
80109d36:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d39:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109d3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d40:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109d44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d47:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109d4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d4e:	83 c0 0c             	add    $0xc,%eax
80109d51:	83 ec 04             	sub    $0x4,%esp
80109d54:	6a 04                	push   $0x4
80109d56:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d5b:	50                   	push   %eax
80109d5c:	e8 20 b1 ff ff       	call   80104e81 <memmove>
80109d61:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d67:	8d 50 0c             	lea    0xc(%eax),%edx
80109d6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d6d:	83 c0 10             	add    $0x10,%eax
80109d70:	83 ec 04             	sub    $0x4,%esp
80109d73:	6a 04                	push   $0x4
80109d75:	52                   	push   %edx
80109d76:	50                   	push   %eax
80109d77:	e8 05 b1 ff ff       	call   80104e81 <memmove>
80109d7c:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109d7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d82:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109d88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d8b:	83 ec 0c             	sub    $0xc,%esp
80109d8e:	50                   	push   %eax
80109d8f:	e8 5d fd ff ff       	call   80109af1 <ipv4_chksum>
80109d94:	83 c4 10             	add    $0x10,%esp
80109d97:	0f b7 c0             	movzwl %ax,%eax
80109d9a:	83 ec 0c             	sub    $0xc,%esp
80109d9d:	50                   	push   %eax
80109d9e:	e8 3e fc ff ff       	call   801099e1 <H2N_ushort>
80109da3:	83 c4 10             	add    $0x10,%esp
80109da6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109da9:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109dad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109db0:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109db6:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dbd:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109dc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dc4:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109dc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dcb:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109dcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dd2:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109dd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dd9:	8d 50 08             	lea    0x8(%eax),%edx
80109ddc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ddf:	83 c0 08             	add    $0x8,%eax
80109de2:	83 ec 04             	sub    $0x4,%esp
80109de5:	6a 08                	push   $0x8
80109de7:	52                   	push   %edx
80109de8:	50                   	push   %eax
80109de9:	e8 93 b0 ff ff       	call   80104e81 <memmove>
80109dee:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109df4:	8d 50 10             	lea    0x10(%eax),%edx
80109df7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dfa:	83 c0 10             	add    $0x10,%eax
80109dfd:	83 ec 04             	sub    $0x4,%esp
80109e00:	6a 30                	push   $0x30
80109e02:	52                   	push   %edx
80109e03:	50                   	push   %eax
80109e04:	e8 78 b0 ff ff       	call   80104e81 <memmove>
80109e09:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109e0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e0f:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109e15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e18:	83 ec 0c             	sub    $0xc,%esp
80109e1b:	50                   	push   %eax
80109e1c:	e8 1c 00 00 00       	call   80109e3d <icmp_chksum>
80109e21:	83 c4 10             	add    $0x10,%esp
80109e24:	0f b7 c0             	movzwl %ax,%eax
80109e27:	83 ec 0c             	sub    $0xc,%esp
80109e2a:	50                   	push   %eax
80109e2b:	e8 b1 fb ff ff       	call   801099e1 <H2N_ushort>
80109e30:	83 c4 10             	add    $0x10,%esp
80109e33:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109e36:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109e3a:	90                   	nop
80109e3b:	c9                   	leave  
80109e3c:	c3                   	ret    

80109e3d <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109e3d:	f3 0f 1e fb          	endbr32 
80109e41:	55                   	push   %ebp
80109e42:	89 e5                	mov    %esp,%ebp
80109e44:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109e47:	8b 45 08             	mov    0x8(%ebp),%eax
80109e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109e4d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109e54:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e5b:	eb 48                	jmp    80109ea5 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e5d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e60:	01 c0                	add    %eax,%eax
80109e62:	89 c2                	mov    %eax,%edx
80109e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e67:	01 d0                	add    %edx,%eax
80109e69:	0f b6 00             	movzbl (%eax),%eax
80109e6c:	0f b6 c0             	movzbl %al,%eax
80109e6f:	c1 e0 08             	shl    $0x8,%eax
80109e72:	89 c2                	mov    %eax,%edx
80109e74:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e77:	01 c0                	add    %eax,%eax
80109e79:	8d 48 01             	lea    0x1(%eax),%ecx
80109e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e7f:	01 c8                	add    %ecx,%eax
80109e81:	0f b6 00             	movzbl (%eax),%eax
80109e84:	0f b6 c0             	movzbl %al,%eax
80109e87:	01 d0                	add    %edx,%eax
80109e89:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109e8c:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109e93:	76 0c                	jbe    80109ea1 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109e95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e98:	0f b7 c0             	movzwl %ax,%eax
80109e9b:	83 c0 01             	add    $0x1,%eax
80109e9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109ea1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ea5:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109ea9:	7e b2                	jle    80109e5d <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109eab:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109eae:	f7 d0                	not    %eax
}
80109eb0:	c9                   	leave  
80109eb1:	c3                   	ret    

80109eb2 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109eb2:	f3 0f 1e fb          	endbr32 
80109eb6:	55                   	push   %ebp
80109eb7:	89 e5                	mov    %esp,%ebp
80109eb9:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80109ebf:	83 c0 0e             	add    $0xe,%eax
80109ec2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ec8:	0f b6 00             	movzbl (%eax),%eax
80109ecb:	0f b6 c0             	movzbl %al,%eax
80109ece:	83 e0 0f             	and    $0xf,%eax
80109ed1:	c1 e0 02             	shl    $0x2,%eax
80109ed4:	89 c2                	mov    %eax,%edx
80109ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ed9:	01 d0                	add    %edx,%eax
80109edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ee1:	83 c0 14             	add    $0x14,%eax
80109ee4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109ee7:	e8 a6 89 ff ff       	call   80102892 <kalloc>
80109eec:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109eef:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ef9:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109efd:	0f b6 c0             	movzbl %al,%eax
80109f00:	83 e0 02             	and    $0x2,%eax
80109f03:	85 c0                	test   %eax,%eax
80109f05:	74 3d                	je     80109f44 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109f07:	83 ec 0c             	sub    $0xc,%esp
80109f0a:	6a 00                	push   $0x0
80109f0c:	6a 12                	push   $0x12
80109f0e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f11:	50                   	push   %eax
80109f12:	ff 75 e8             	pushl  -0x18(%ebp)
80109f15:	ff 75 08             	pushl  0x8(%ebp)
80109f18:	e8 a2 01 00 00       	call   8010a0bf <tcp_pkt_create>
80109f1d:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109f20:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f23:	83 ec 08             	sub    $0x8,%esp
80109f26:	50                   	push   %eax
80109f27:	ff 75 e8             	pushl  -0x18(%ebp)
80109f2a:	e8 ff f0 ff ff       	call   8010902e <i8254_send>
80109f2f:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f32:	a1 44 d3 18 80       	mov    0x8018d344,%eax
80109f37:	83 c0 01             	add    $0x1,%eax
80109f3a:	a3 44 d3 18 80       	mov    %eax,0x8018d344
80109f3f:	e9 69 01 00 00       	jmp    8010a0ad <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f47:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f4b:	3c 18                	cmp    $0x18,%al
80109f4d:	0f 85 10 01 00 00    	jne    8010a063 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
80109f53:	83 ec 04             	sub    $0x4,%esp
80109f56:	6a 03                	push   $0x3
80109f58:	68 7e c5 10 80       	push   $0x8010c57e
80109f5d:	ff 75 ec             	pushl  -0x14(%ebp)
80109f60:	e8 c0 ae ff ff       	call   80104e25 <memcmp>
80109f65:	83 c4 10             	add    $0x10,%esp
80109f68:	85 c0                	test   %eax,%eax
80109f6a:	74 74                	je     80109fe0 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
80109f6c:	83 ec 0c             	sub    $0xc,%esp
80109f6f:	68 82 c5 10 80       	push   $0x8010c582
80109f74:	e8 93 64 ff ff       	call   8010040c <cprintf>
80109f79:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109f7c:	83 ec 0c             	sub    $0xc,%esp
80109f7f:	6a 00                	push   $0x0
80109f81:	6a 10                	push   $0x10
80109f83:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f86:	50                   	push   %eax
80109f87:	ff 75 e8             	pushl  -0x18(%ebp)
80109f8a:	ff 75 08             	pushl  0x8(%ebp)
80109f8d:	e8 2d 01 00 00       	call   8010a0bf <tcp_pkt_create>
80109f92:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109f95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f98:	83 ec 08             	sub    $0x8,%esp
80109f9b:	50                   	push   %eax
80109f9c:	ff 75 e8             	pushl  -0x18(%ebp)
80109f9f:	e8 8a f0 ff ff       	call   8010902e <i8254_send>
80109fa4:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109fa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109faa:	83 c0 36             	add    $0x36,%eax
80109fad:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109fb0:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109fb3:	50                   	push   %eax
80109fb4:	ff 75 e0             	pushl  -0x20(%ebp)
80109fb7:	6a 00                	push   $0x0
80109fb9:	6a 00                	push   $0x0
80109fbb:	e8 66 04 00 00       	call   8010a426 <http_proc>
80109fc0:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109fc3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109fc6:	83 ec 0c             	sub    $0xc,%esp
80109fc9:	50                   	push   %eax
80109fca:	6a 18                	push   $0x18
80109fcc:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fcf:	50                   	push   %eax
80109fd0:	ff 75 e8             	pushl  -0x18(%ebp)
80109fd3:	ff 75 08             	pushl  0x8(%ebp)
80109fd6:	e8 e4 00 00 00       	call   8010a0bf <tcp_pkt_create>
80109fdb:	83 c4 20             	add    $0x20,%esp
80109fde:	eb 62                	jmp    8010a042 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109fe0:	83 ec 0c             	sub    $0xc,%esp
80109fe3:	6a 00                	push   $0x0
80109fe5:	6a 10                	push   $0x10
80109fe7:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fea:	50                   	push   %eax
80109feb:	ff 75 e8             	pushl  -0x18(%ebp)
80109fee:	ff 75 08             	pushl  0x8(%ebp)
80109ff1:	e8 c9 00 00 00       	call   8010a0bf <tcp_pkt_create>
80109ff6:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109ff9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ffc:	83 ec 08             	sub    $0x8,%esp
80109fff:	50                   	push   %eax
8010a000:	ff 75 e8             	pushl  -0x18(%ebp)
8010a003:	e8 26 f0 ff ff       	call   8010902e <i8254_send>
8010a008:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a00b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a00e:	83 c0 36             	add    $0x36,%eax
8010a011:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a014:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a017:	50                   	push   %eax
8010a018:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a01b:	6a 00                	push   $0x0
8010a01d:	6a 00                	push   $0x0
8010a01f:	e8 02 04 00 00       	call   8010a426 <http_proc>
8010a024:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a027:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a02a:	83 ec 0c             	sub    $0xc,%esp
8010a02d:	50                   	push   %eax
8010a02e:	6a 18                	push   $0x18
8010a030:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a033:	50                   	push   %eax
8010a034:	ff 75 e8             	pushl  -0x18(%ebp)
8010a037:	ff 75 08             	pushl  0x8(%ebp)
8010a03a:	e8 80 00 00 00       	call   8010a0bf <tcp_pkt_create>
8010a03f:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a042:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a045:	83 ec 08             	sub    $0x8,%esp
8010a048:	50                   	push   %eax
8010a049:	ff 75 e8             	pushl  -0x18(%ebp)
8010a04c:	e8 dd ef ff ff       	call   8010902e <i8254_send>
8010a051:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a054:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a059:	83 c0 01             	add    $0x1,%eax
8010a05c:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a061:	eb 4a                	jmp    8010a0ad <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a063:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a066:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a06a:	3c 10                	cmp    $0x10,%al
8010a06c:	75 3f                	jne    8010a0ad <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a06e:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a073:	83 f8 01             	cmp    $0x1,%eax
8010a076:	75 35                	jne    8010a0ad <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a078:	83 ec 0c             	sub    $0xc,%esp
8010a07b:	6a 00                	push   $0x0
8010a07d:	6a 01                	push   $0x1
8010a07f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a082:	50                   	push   %eax
8010a083:	ff 75 e8             	pushl  -0x18(%ebp)
8010a086:	ff 75 08             	pushl  0x8(%ebp)
8010a089:	e8 31 00 00 00       	call   8010a0bf <tcp_pkt_create>
8010a08e:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a091:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a094:	83 ec 08             	sub    $0x8,%esp
8010a097:	50                   	push   %eax
8010a098:	ff 75 e8             	pushl  -0x18(%ebp)
8010a09b:	e8 8e ef ff ff       	call   8010902e <i8254_send>
8010a0a0:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a0a3:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a0aa:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a0ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0b0:	83 ec 0c             	sub    $0xc,%esp
8010a0b3:	50                   	push   %eax
8010a0b4:	e8 3b 87 ff ff       	call   801027f4 <kfree>
8010a0b9:	83 c4 10             	add    $0x10,%esp
}
8010a0bc:	90                   	nop
8010a0bd:	c9                   	leave  
8010a0be:	c3                   	ret    

8010a0bf <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a0bf:	f3 0f 1e fb          	endbr32 
8010a0c3:	55                   	push   %ebp
8010a0c4:	89 e5                	mov    %esp,%ebp
8010a0c6:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a0c9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a0cf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d2:	83 c0 0e             	add    $0xe,%eax
8010a0d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a0d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0db:	0f b6 00             	movzbl (%eax),%eax
8010a0de:	0f b6 c0             	movzbl %al,%eax
8010a0e1:	83 e0 0f             	and    $0xf,%eax
8010a0e4:	c1 e0 02             	shl    $0x2,%eax
8010a0e7:	89 c2                	mov    %eax,%edx
8010a0e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0ec:	01 d0                	add    %edx,%eax
8010a0ee:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a0f1:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a0f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a0f7:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a0fa:	83 c0 0e             	add    $0xe,%eax
8010a0fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a103:	83 c0 14             	add    $0x14,%eax
8010a106:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a109:	8b 45 18             	mov    0x18(%ebp),%eax
8010a10c:	8d 50 36             	lea    0x36(%eax),%edx
8010a10f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a112:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a114:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a117:	8d 50 06             	lea    0x6(%eax),%edx
8010a11a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a11d:	83 ec 04             	sub    $0x4,%esp
8010a120:	6a 06                	push   $0x6
8010a122:	52                   	push   %edx
8010a123:	50                   	push   %eax
8010a124:	e8 58 ad ff ff       	call   80104e81 <memmove>
8010a129:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a12c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a12f:	83 c0 06             	add    $0x6,%eax
8010a132:	83 ec 04             	sub    $0x4,%esp
8010a135:	6a 06                	push   $0x6
8010a137:	68 68 d0 18 80       	push   $0x8018d068
8010a13c:	50                   	push   %eax
8010a13d:	e8 3f ad ff ff       	call   80104e81 <memmove>
8010a142:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a145:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a148:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a14c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a14f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a156:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a159:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a15c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a160:	8b 45 18             	mov    0x18(%ebp),%eax
8010a163:	83 c0 28             	add    $0x28,%eax
8010a166:	0f b7 c0             	movzwl %ax,%eax
8010a169:	83 ec 0c             	sub    $0xc,%esp
8010a16c:	50                   	push   %eax
8010a16d:	e8 6f f8 ff ff       	call   801099e1 <H2N_ushort>
8010a172:	83 c4 10             	add    $0x10,%esp
8010a175:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a178:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a17c:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a183:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a186:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a18a:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a191:	83 c0 01             	add    $0x1,%eax
8010a194:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a19a:	83 ec 0c             	sub    $0xc,%esp
8010a19d:	6a 00                	push   $0x0
8010a19f:	e8 3d f8 ff ff       	call   801099e1 <H2N_ushort>
8010a1a4:	83 c4 10             	add    $0x10,%esp
8010a1a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a1aa:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a1ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1b1:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a1b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1b8:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a1bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1bf:	83 c0 0c             	add    $0xc,%eax
8010a1c2:	83 ec 04             	sub    $0x4,%esp
8010a1c5:	6a 04                	push   $0x4
8010a1c7:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a1cc:	50                   	push   %eax
8010a1cd:	e8 af ac ff ff       	call   80104e81 <memmove>
8010a1d2:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a1d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1d8:	8d 50 0c             	lea    0xc(%eax),%edx
8010a1db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1de:	83 c0 10             	add    $0x10,%eax
8010a1e1:	83 ec 04             	sub    $0x4,%esp
8010a1e4:	6a 04                	push   $0x4
8010a1e6:	52                   	push   %edx
8010a1e7:	50                   	push   %eax
8010a1e8:	e8 94 ac ff ff       	call   80104e81 <memmove>
8010a1ed:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a1f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1f3:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a1f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1fc:	83 ec 0c             	sub    $0xc,%esp
8010a1ff:	50                   	push   %eax
8010a200:	e8 ec f8 ff ff       	call   80109af1 <ipv4_chksum>
8010a205:	83 c4 10             	add    $0x10,%esp
8010a208:	0f b7 c0             	movzwl %ax,%eax
8010a20b:	83 ec 0c             	sub    $0xc,%esp
8010a20e:	50                   	push   %eax
8010a20f:	e8 cd f7 ff ff       	call   801099e1 <H2N_ushort>
8010a214:	83 c4 10             	add    $0x10,%esp
8010a217:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a21a:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a21e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a221:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a225:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a228:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a22b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a22e:	0f b7 10             	movzwl (%eax),%edx
8010a231:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a234:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a238:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a23d:	83 ec 0c             	sub    $0xc,%esp
8010a240:	50                   	push   %eax
8010a241:	e8 c1 f7 ff ff       	call   80109a07 <H2N_uint>
8010a246:	83 c4 10             	add    $0x10,%esp
8010a249:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a24c:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a24f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a252:	8b 40 04             	mov    0x4(%eax),%eax
8010a255:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a25b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a25e:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a261:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a264:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a268:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a26b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a26f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a272:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a276:	8b 45 14             	mov    0x14(%ebp),%eax
8010a279:	89 c2                	mov    %eax,%edx
8010a27b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a27e:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a281:	83 ec 0c             	sub    $0xc,%esp
8010a284:	68 90 38 00 00       	push   $0x3890
8010a289:	e8 53 f7 ff ff       	call   801099e1 <H2N_ushort>
8010a28e:	83 c4 10             	add    $0x10,%esp
8010a291:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a294:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a298:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a29b:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a2a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2a4:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a2aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ad:	83 ec 0c             	sub    $0xc,%esp
8010a2b0:	50                   	push   %eax
8010a2b1:	e8 1f 00 00 00       	call   8010a2d5 <tcp_chksum>
8010a2b6:	83 c4 10             	add    $0x10,%esp
8010a2b9:	83 c0 08             	add    $0x8,%eax
8010a2bc:	0f b7 c0             	movzwl %ax,%eax
8010a2bf:	83 ec 0c             	sub    $0xc,%esp
8010a2c2:	50                   	push   %eax
8010a2c3:	e8 19 f7 ff ff       	call   801099e1 <H2N_ushort>
8010a2c8:	83 c4 10             	add    $0x10,%esp
8010a2cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a2ce:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a2d2:	90                   	nop
8010a2d3:	c9                   	leave  
8010a2d4:	c3                   	ret    

8010a2d5 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a2d5:	f3 0f 1e fb          	endbr32 
8010a2d9:	55                   	push   %ebp
8010a2da:	89 e5                	mov    %esp,%ebp
8010a2dc:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a2df:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a2e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2e8:	83 c0 14             	add    $0x14,%eax
8010a2eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a2ee:	83 ec 04             	sub    $0x4,%esp
8010a2f1:	6a 04                	push   $0x4
8010a2f3:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a2f8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a2fb:	50                   	push   %eax
8010a2fc:	e8 80 ab ff ff       	call   80104e81 <memmove>
8010a301:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a304:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a307:	83 c0 0c             	add    $0xc,%eax
8010a30a:	83 ec 04             	sub    $0x4,%esp
8010a30d:	6a 04                	push   $0x4
8010a30f:	50                   	push   %eax
8010a310:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a313:	83 c0 04             	add    $0x4,%eax
8010a316:	50                   	push   %eax
8010a317:	e8 65 ab ff ff       	call   80104e81 <memmove>
8010a31c:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a31f:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a323:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a327:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a32a:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a32e:	0f b7 c0             	movzwl %ax,%eax
8010a331:	83 ec 0c             	sub    $0xc,%esp
8010a334:	50                   	push   %eax
8010a335:	e8 81 f6 ff ff       	call   801099bb <N2H_ushort>
8010a33a:	83 c4 10             	add    $0x10,%esp
8010a33d:	83 e8 14             	sub    $0x14,%eax
8010a340:	0f b7 c0             	movzwl %ax,%eax
8010a343:	83 ec 0c             	sub    $0xc,%esp
8010a346:	50                   	push   %eax
8010a347:	e8 95 f6 ff ff       	call   801099e1 <H2N_ushort>
8010a34c:	83 c4 10             	add    $0x10,%esp
8010a34f:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a35a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a35d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a360:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a367:	eb 33                	jmp    8010a39c <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a369:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a36c:	01 c0                	add    %eax,%eax
8010a36e:	89 c2                	mov    %eax,%edx
8010a370:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a373:	01 d0                	add    %edx,%eax
8010a375:	0f b6 00             	movzbl (%eax),%eax
8010a378:	0f b6 c0             	movzbl %al,%eax
8010a37b:	c1 e0 08             	shl    $0x8,%eax
8010a37e:	89 c2                	mov    %eax,%edx
8010a380:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a383:	01 c0                	add    %eax,%eax
8010a385:	8d 48 01             	lea    0x1(%eax),%ecx
8010a388:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a38b:	01 c8                	add    %ecx,%eax
8010a38d:	0f b6 00             	movzbl (%eax),%eax
8010a390:	0f b6 c0             	movzbl %al,%eax
8010a393:	01 d0                	add    %edx,%eax
8010a395:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a398:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a39c:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a3a0:	7e c7                	jle    8010a369 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a3a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a3a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a3af:	eb 33                	jmp    8010a3e4 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a3b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3b4:	01 c0                	add    %eax,%eax
8010a3b6:	89 c2                	mov    %eax,%edx
8010a3b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3bb:	01 d0                	add    %edx,%eax
8010a3bd:	0f b6 00             	movzbl (%eax),%eax
8010a3c0:	0f b6 c0             	movzbl %al,%eax
8010a3c3:	c1 e0 08             	shl    $0x8,%eax
8010a3c6:	89 c2                	mov    %eax,%edx
8010a3c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3cb:	01 c0                	add    %eax,%eax
8010a3cd:	8d 48 01             	lea    0x1(%eax),%ecx
8010a3d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3d3:	01 c8                	add    %ecx,%eax
8010a3d5:	0f b6 00             	movzbl (%eax),%eax
8010a3d8:	0f b6 c0             	movzbl %al,%eax
8010a3db:	01 d0                	add    %edx,%eax
8010a3dd:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a3e0:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a3e4:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a3e8:	0f b7 c0             	movzwl %ax,%eax
8010a3eb:	83 ec 0c             	sub    $0xc,%esp
8010a3ee:	50                   	push   %eax
8010a3ef:	e8 c7 f5 ff ff       	call   801099bb <N2H_ushort>
8010a3f4:	83 c4 10             	add    $0x10,%esp
8010a3f7:	66 d1 e8             	shr    %ax
8010a3fa:	0f b7 c0             	movzwl %ax,%eax
8010a3fd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a400:	7c af                	jl     8010a3b1 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a402:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a405:	c1 e8 10             	shr    $0x10,%eax
8010a408:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a40b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a40e:	f7 d0                	not    %eax
}
8010a410:	c9                   	leave  
8010a411:	c3                   	ret    

8010a412 <tcp_fin>:

void tcp_fin(){
8010a412:	f3 0f 1e fb          	endbr32 
8010a416:	55                   	push   %ebp
8010a417:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a419:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a420:	00 00 00 
}
8010a423:	90                   	nop
8010a424:	5d                   	pop    %ebp
8010a425:	c3                   	ret    

8010a426 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a426:	f3 0f 1e fb          	endbr32 
8010a42a:	55                   	push   %ebp
8010a42b:	89 e5                	mov    %esp,%ebp
8010a42d:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a430:	8b 45 10             	mov    0x10(%ebp),%eax
8010a433:	83 ec 04             	sub    $0x4,%esp
8010a436:	6a 00                	push   $0x0
8010a438:	68 8b c5 10 80       	push   $0x8010c58b
8010a43d:	50                   	push   %eax
8010a43e:	e8 65 00 00 00       	call   8010a4a8 <http_strcpy>
8010a443:	83 c4 10             	add    $0x10,%esp
8010a446:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a449:	8b 45 10             	mov    0x10(%ebp),%eax
8010a44c:	83 ec 04             	sub    $0x4,%esp
8010a44f:	ff 75 f4             	pushl  -0xc(%ebp)
8010a452:	68 9e c5 10 80       	push   $0x8010c59e
8010a457:	50                   	push   %eax
8010a458:	e8 4b 00 00 00       	call   8010a4a8 <http_strcpy>
8010a45d:	83 c4 10             	add    $0x10,%esp
8010a460:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a463:	8b 45 10             	mov    0x10(%ebp),%eax
8010a466:	83 ec 04             	sub    $0x4,%esp
8010a469:	ff 75 f4             	pushl  -0xc(%ebp)
8010a46c:	68 b9 c5 10 80       	push   $0x8010c5b9
8010a471:	50                   	push   %eax
8010a472:	e8 31 00 00 00       	call   8010a4a8 <http_strcpy>
8010a477:	83 c4 10             	add    $0x10,%esp
8010a47a:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a47d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a480:	83 e0 01             	and    $0x1,%eax
8010a483:	85 c0                	test   %eax,%eax
8010a485:	74 11                	je     8010a498 <http_proc+0x72>
    char *payload = (char *)send;
8010a487:	8b 45 10             	mov    0x10(%ebp),%eax
8010a48a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a48d:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a490:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a493:	01 d0                	add    %edx,%eax
8010a495:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a498:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a49b:	8b 45 14             	mov    0x14(%ebp),%eax
8010a49e:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a4a0:	e8 6d ff ff ff       	call   8010a412 <tcp_fin>
}
8010a4a5:	90                   	nop
8010a4a6:	c9                   	leave  
8010a4a7:	c3                   	ret    

8010a4a8 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a4a8:	f3 0f 1e fb          	endbr32 
8010a4ac:	55                   	push   %ebp
8010a4ad:	89 e5                	mov    %esp,%ebp
8010a4af:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a4b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a4b9:	eb 20                	jmp    8010a4db <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a4bb:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4be:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4c1:	01 d0                	add    %edx,%eax
8010a4c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a4c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4c9:	01 ca                	add    %ecx,%edx
8010a4cb:	89 d1                	mov    %edx,%ecx
8010a4cd:	8b 55 08             	mov    0x8(%ebp),%edx
8010a4d0:	01 ca                	add    %ecx,%edx
8010a4d2:	0f b6 00             	movzbl (%eax),%eax
8010a4d5:	88 02                	mov    %al,(%edx)
    i++;
8010a4d7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a4db:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a4de:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4e1:	01 d0                	add    %edx,%eax
8010a4e3:	0f b6 00             	movzbl (%eax),%eax
8010a4e6:	84 c0                	test   %al,%al
8010a4e8:	75 d1                	jne    8010a4bb <http_strcpy+0x13>
  }
  return i;
8010a4ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a4ed:	c9                   	leave  
8010a4ee:	c3                   	ret    

8010a4ef <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a4ef:	f3 0f 1e fb          	endbr32 
8010a4f3:	55                   	push   %ebp
8010a4f4:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a4f6:	c7 05 50 d3 18 80 a2 	movl   $0x8010f5a2,0x8018d350
8010a4fd:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a500:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a505:	c1 e8 09             	shr    $0x9,%eax
8010a508:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a50d:	90                   	nop
8010a50e:	5d                   	pop    %ebp
8010a50f:	c3                   	ret    

8010a510 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a510:	f3 0f 1e fb          	endbr32 
8010a514:	55                   	push   %ebp
8010a515:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a517:	90                   	nop
8010a518:	5d                   	pop    %ebp
8010a519:	c3                   	ret    

8010a51a <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a51a:	f3 0f 1e fb          	endbr32 
8010a51e:	55                   	push   %ebp
8010a51f:	89 e5                	mov    %esp,%ebp
8010a521:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a524:	8b 45 08             	mov    0x8(%ebp),%eax
8010a527:	83 c0 0c             	add    $0xc,%eax
8010a52a:	83 ec 0c             	sub    $0xc,%esp
8010a52d:	50                   	push   %eax
8010a52e:	e8 5f a5 ff ff       	call   80104a92 <holdingsleep>
8010a533:	83 c4 10             	add    $0x10,%esp
8010a536:	85 c0                	test   %eax,%eax
8010a538:	75 0d                	jne    8010a547 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a53a:	83 ec 0c             	sub    $0xc,%esp
8010a53d:	68 ca c5 10 80       	push   $0x8010c5ca
8010a542:	e8 7e 60 ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a547:	8b 45 08             	mov    0x8(%ebp),%eax
8010a54a:	8b 00                	mov    (%eax),%eax
8010a54c:	83 e0 06             	and    $0x6,%eax
8010a54f:	83 f8 02             	cmp    $0x2,%eax
8010a552:	75 0d                	jne    8010a561 <iderw+0x47>
    panic("iderw: nothing to do");
8010a554:	83 ec 0c             	sub    $0xc,%esp
8010a557:	68 e0 c5 10 80       	push   $0x8010c5e0
8010a55c:	e8 64 60 ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a561:	8b 45 08             	mov    0x8(%ebp),%eax
8010a564:	8b 40 04             	mov    0x4(%eax),%eax
8010a567:	83 f8 01             	cmp    $0x1,%eax
8010a56a:	74 0d                	je     8010a579 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a56c:	83 ec 0c             	sub    $0xc,%esp
8010a56f:	68 f5 c5 10 80       	push   $0x8010c5f5
8010a574:	e8 4c 60 ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a579:	8b 45 08             	mov    0x8(%ebp),%eax
8010a57c:	8b 40 08             	mov    0x8(%eax),%eax
8010a57f:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a585:	39 d0                	cmp    %edx,%eax
8010a587:	72 0d                	jb     8010a596 <iderw+0x7c>
    panic("iderw: block out of range");
8010a589:	83 ec 0c             	sub    $0xc,%esp
8010a58c:	68 13 c6 10 80       	push   $0x8010c613
8010a591:	e8 2f 60 ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a596:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a59c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a59f:	8b 40 08             	mov    0x8(%eax),%eax
8010a5a2:	c1 e0 09             	shl    $0x9,%eax
8010a5a5:	01 d0                	add    %edx,%eax
8010a5a7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a5aa:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5ad:	8b 00                	mov    (%eax),%eax
8010a5af:	83 e0 04             	and    $0x4,%eax
8010a5b2:	85 c0                	test   %eax,%eax
8010a5b4:	74 2b                	je     8010a5e1 <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a5b6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5b9:	8b 00                	mov    (%eax),%eax
8010a5bb:	83 e0 fb             	and    $0xfffffffb,%eax
8010a5be:	89 c2                	mov    %eax,%edx
8010a5c0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5c3:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a5c5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5c8:	83 c0 5c             	add    $0x5c,%eax
8010a5cb:	83 ec 04             	sub    $0x4,%esp
8010a5ce:	68 00 02 00 00       	push   $0x200
8010a5d3:	50                   	push   %eax
8010a5d4:	ff 75 f4             	pushl  -0xc(%ebp)
8010a5d7:	e8 a5 a8 ff ff       	call   80104e81 <memmove>
8010a5dc:	83 c4 10             	add    $0x10,%esp
8010a5df:	eb 1a                	jmp    8010a5fb <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a5e1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5e4:	83 c0 5c             	add    $0x5c,%eax
8010a5e7:	83 ec 04             	sub    $0x4,%esp
8010a5ea:	68 00 02 00 00       	push   $0x200
8010a5ef:	ff 75 f4             	pushl  -0xc(%ebp)
8010a5f2:	50                   	push   %eax
8010a5f3:	e8 89 a8 ff ff       	call   80104e81 <memmove>
8010a5f8:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a5fb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5fe:	8b 00                	mov    (%eax),%eax
8010a600:	83 c8 02             	or     $0x2,%eax
8010a603:	89 c2                	mov    %eax,%edx
8010a605:	8b 45 08             	mov    0x8(%ebp),%eax
8010a608:	89 10                	mov    %edx,(%eax)
}
8010a60a:	90                   	nop
8010a60b:	c9                   	leave  
8010a60c:	c3                   	ret    
