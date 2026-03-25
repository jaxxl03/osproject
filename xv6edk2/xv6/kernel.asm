
kernel:     file format elf32-i386


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
8010005a:	bc 90 13 11 80       	mov    $0x80111390,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba a6 39 10 80       	mov    $0x801039a6,%edx
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
80100073:	68 20 a7 10 80       	push   $0x8010a720
80100078:	68 a0 13 11 80       	push   $0x801113a0
8010007d:	e8 15 4d 00 00       	call   80104d97 <initlock>
80100082:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100085:	c7 05 ec 5a 11 80 9c 	movl   $0x80115a9c,0x80115aec
8010008c:	5a 11 80 
  bcache.head.next = &bcache.head;
8010008f:	c7 05 f0 5a 11 80 9c 	movl   $0x80115a9c,0x80115af0
80100096:	5a 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100099:	c7 45 f4 d4 13 11 80 	movl   $0x801113d4,-0xc(%ebp)
801000a0:	eb 47                	jmp    801000e9 <binit+0x83>
    b->next = bcache.head.next;
801000a2:	8b 15 f0 5a 11 80    	mov    0x80115af0,%edx
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b1:	c7 40 50 9c 5a 11 80 	movl   $0x80115a9c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000bb:	83 c0 0c             	add    $0xc,%eax
801000be:	83 ec 08             	sub    $0x8,%esp
801000c1:	68 27 a7 10 80       	push   $0x8010a727
801000c6:	50                   	push   %eax
801000c7:	e8 5e 4b 00 00       	call   80104c2a <initsleeplock>
801000cc:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cf:	a1 f0 5a 11 80       	mov    0x80115af0,%eax
801000d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d7:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000dd:	a3 f0 5a 11 80       	mov    %eax,0x80115af0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000e2:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e9:	b8 9c 5a 11 80       	mov    $0x80115a9c,%eax
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
80100104:	68 a0 13 11 80       	push   $0x801113a0
80100109:	e8 af 4c 00 00       	call   80104dbd <acquire>
8010010e:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100111:	a1 f0 5a 11 80       	mov    0x80115af0,%eax
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
80100143:	68 a0 13 11 80       	push   $0x801113a0
80100148:	e8 e2 4c 00 00       	call   80104e2f <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 0b 4b 00 00       	call   80104c6a <acquiresleep>
8010015f:	83 c4 10             	add    $0x10,%esp
      return b;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	e9 9d 00 00 00       	jmp    80100207 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 40 54             	mov    0x54(%eax),%eax
80100170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100173:	81 7d f4 9c 5a 11 80 	cmpl   $0x80115a9c,-0xc(%ebp)
8010017a:	75 9f                	jne    8010011b <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010017c:	a1 ec 5a 11 80       	mov    0x80115aec,%eax
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
801001c4:	68 a0 13 11 80       	push   $0x801113a0
801001c9:	e8 61 4c 00 00       	call   80104e2f <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 8a 4a 00 00       	call   80104c6a <acquiresleep>
801001e0:	83 c4 10             	add    $0x10,%esp
      return b;
801001e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e6:	eb 1f                	jmp    80100207 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 40 50             	mov    0x50(%eax),%eax
801001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001f1:	81 7d f4 9c 5a 11 80 	cmpl   $0x80115a9c,-0xc(%ebp)
801001f8:	75 8c                	jne    80100186 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001fa:	83 ec 0c             	sub    $0xc,%esp
801001fd:	68 2e a7 10 80       	push   $0x8010a72e
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
80100239:	e8 cf 27 00 00       	call   80102a0d <iderw>
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
8010025a:	e8 c5 4a 00 00       	call   80104d24 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 3f a7 10 80       	push   $0x8010a73f
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
80100288:	e8 80 27 00 00       	call   80102a0d <iderw>
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
801002a7:	e8 78 4a 00 00       	call   80104d24 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 46 a7 10 80       	push   $0x8010a746
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 03 4a 00 00       	call   80104cd2 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 a0 13 11 80       	push   $0x801113a0
801002da:	e8 de 4a 00 00       	call   80104dbd <acquire>
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
80100319:	8b 15 f0 5a 11 80    	mov    0x80115af0,%edx
8010031f:	8b 45 08             	mov    0x8(%ebp),%eax
80100322:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c7 40 50 9c 5a 11 80 	movl   $0x80115a9c,0x50(%eax)
    bcache.head.next->prev = b;
8010032f:	a1 f0 5a 11 80       	mov    0x80115af0,%eax
80100334:	8b 55 08             	mov    0x8(%ebp),%edx
80100337:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	a3 f0 5a 11 80       	mov    %eax,0x80115af0
  }
  
  release(&bcache.lock);
80100342:	83 ec 0c             	sub    $0xc,%esp
80100345:	68 a0 13 11 80       	push   $0x801113a0
8010034a:	e8 e0 4a 00 00       	call   80104e2f <release>
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
80100416:	a1 54 00 11 80       	mov    0x80110054,%eax
8010041b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010041e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100422:	74 10                	je     80100434 <cprintf+0x28>
    acquire(&cons.lock);
80100424:	83 ec 0c             	sub    $0xc,%esp
80100427:	68 20 00 11 80       	push   $0x80110020
8010042c:	e8 8c 49 00 00       	call   80104dbd <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 4d a7 10 80       	push   $0x8010a74d
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
8010052c:	c7 45 ec 56 a7 10 80 	movl   $0x8010a756,-0x14(%ebp)
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
801005b5:	68 20 00 11 80       	push   $0x80110020
801005ba:	e8 70 48 00 00       	call   80104e2f <release>
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
801005d4:	c7 05 54 00 11 80 00 	movl   $0x0,0x80110054
801005db:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005de:	e8 14 2b 00 00       	call   801030f7 <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 5d a7 10 80       	push   $0x8010a75d
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
80100606:	68 71 a7 10 80       	push   $0x8010a771
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 62 48 00 00       	call   80104e85 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 73 a7 10 80       	push   $0x8010a773
8010063f:	e8 c8 fd ff ff       	call   8010040c <cprintf>
80100644:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100647:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010064b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010064f:	7e de                	jle    8010062f <panic+0x6a>
  panicked = 1; // freeze other CPU
80100651:	c7 05 00 00 11 80 01 	movl   $0x1,0x80110000
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
801006c4:	e8 02 7f 00 00       	call   801085cb <graphic_scroll_up>
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
80100717:	e8 af 7e 00 00       	call   801085cb <graphic_scroll_up>
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
8010077d:	e8 bd 7e 00 00       	call   8010863f <font_render>
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
8010079f:	a1 00 00 11 80       	mov    0x80110000,%eax
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
801007bd:	e8 1d 62 00 00       	call   801069df <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 10 62 00 00       	call   801069df <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 03 62 00 00       	call   801069df <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 f3 61 00 00       	call   801069df <uartputc>
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
80100814:	68 20 00 11 80       	push   $0x80110020
80100819:	e8 9f 45 00 00       	call   80104dbd <acquire>
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
80100866:	a1 88 5d 11 80       	mov    0x80115d88,%eax
8010086b:	83 e8 01             	sub    $0x1,%eax
8010086e:	a3 88 5d 11 80       	mov    %eax,0x80115d88
        consputc(BACKSPACE);
80100873:	83 ec 0c             	sub    $0xc,%esp
80100876:	68 00 01 00 00       	push   $0x100
8010087b:	e8 15 ff ff ff       	call   80100795 <consputc>
80100880:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100883:	8b 15 88 5d 11 80    	mov    0x80115d88,%edx
80100889:	a1 84 5d 11 80       	mov    0x80115d84,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 e2 00 00 00    	je     80100978 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100896:	a1 88 5d 11 80       	mov    0x80115d88,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 00 5d 11 80 	movzbl -0x7feea300(%eax),%eax
      while(input.e != input.w &&
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 ba                	jne    80100866 <consoleintr+0x66>
      }
      break;
801008ac:	e9 c7 00 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 88 5d 11 80    	mov    0x80115d88,%edx
801008b7:	a1 84 5d 11 80       	mov    0x80115d84,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 b4 00 00 00    	je     80100978 <consoleintr+0x178>
        input.e--;
801008c4:	a1 88 5d 11 80       	mov    0x80115d88,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 88 5d 11 80       	mov    %eax,0x80115d88
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
801008f0:	8b 15 88 5d 11 80    	mov    0x80115d88,%edx
801008f6:	a1 80 5d 11 80       	mov    0x80115d80,%eax
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
80100917:	a1 88 5d 11 80       	mov    0x80115d88,%eax
8010091c:	8d 50 01             	lea    0x1(%eax),%edx
8010091f:	89 15 88 5d 11 80    	mov    %edx,0x80115d88
80100925:	83 e0 7f             	and    $0x7f,%eax
80100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010092b:	88 90 00 5d 11 80    	mov    %dl,-0x7feea300(%eax)
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
8010094b:	a1 88 5d 11 80       	mov    0x80115d88,%eax
80100950:	8b 15 80 5d 11 80    	mov    0x80115d80,%edx
80100956:	83 ea 80             	sub    $0xffffff80,%edx
80100959:	39 d0                	cmp    %edx,%eax
8010095b:	75 1a                	jne    80100977 <consoleintr+0x177>
          input.w = input.e;
8010095d:	a1 88 5d 11 80       	mov    0x80115d88,%eax
80100962:	a3 84 5d 11 80       	mov    %eax,0x80115d84
          wakeup(&input.r);
80100967:	83 ec 0c             	sub    $0xc,%esp
8010096a:	68 80 5d 11 80       	push   $0x80115d80
8010096f:	e8 f5 40 00 00       	call   80104a69 <wakeup>
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
8010098d:	68 20 00 11 80       	push   $0x80110020
80100992:	e8 98 44 00 00       	call   80104e2f <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 87 41 00 00       	call   80104b2c <procdump>
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
801009c9:	68 20 00 11 80       	push   $0x80110020
801009ce:	e8 ea 43 00 00       	call   80104dbd <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 c1 36 00 00       	call   801040a1 <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 00 11 80       	push   $0x80110020
801009ef:	e8 3b 44 00 00       	call   80104e2f <release>
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
80100a12:	68 20 00 11 80       	push   $0x80110020
80100a17:	68 80 5d 11 80       	push   $0x80115d80
80100a1c:	e8 59 3f 00 00       	call   8010497a <sleep>
80100a21:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a24:	8b 15 80 5d 11 80    	mov    0x80115d80,%edx
80100a2a:	a1 84 5d 11 80       	mov    0x80115d84,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 a8                	je     801009db <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a33:	a1 80 5d 11 80       	mov    0x80115d80,%eax
80100a38:	8d 50 01             	lea    0x1(%eax),%edx
80100a3b:	89 15 80 5d 11 80    	mov    %edx,0x80115d80
80100a41:	83 e0 7f             	and    $0x7f,%eax
80100a44:	0f b6 80 00 5d 11 80 	movzbl -0x7feea300(%eax),%eax
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
80100a5f:	a1 80 5d 11 80       	mov    0x80115d80,%eax
80100a64:	83 e8 01             	sub    $0x1,%eax
80100a67:	a3 80 5d 11 80       	mov    %eax,0x80115d80
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
80100a95:	68 20 00 11 80       	push   $0x80110020
80100a9a:	e8 90 43 00 00       	call   80104e2f <release>
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
80100ad7:	68 20 00 11 80       	push   $0x80110020
80100adc:	e8 dc 42 00 00       	call   80104dbd <acquire>
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
80100b19:	68 20 00 11 80       	push   $0x80110020
80100b1e:	e8 0c 43 00 00       	call   80104e2f <release>
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
80100b43:	c7 05 00 00 11 80 00 	movl   $0x0,0x80110000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 77 a7 10 80       	push   $0x8010a777
80100b55:	68 20 00 11 80       	push   $0x80110020
80100b5a:	e8 38 42 00 00       	call   80104d97 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 4c 67 11 80 bc 	movl   $0x80100abc,0x8011674c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 48 67 11 80 a8 	movl   $0x801009a8,0x80116748
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 7f a7 10 80 	movl   $0x8010a77f,-0xc(%ebp)
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
80100ba2:	c7 05 54 00 11 80 01 	movl   $0x1,0x80110054
80100ba9:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bac:	83 ec 08             	sub    $0x8,%esp
80100baf:	6a 00                	push   $0x0
80100bb1:	6a 01                	push   $0x1
80100bb3:	e8 4c 20 00 00       	call   80102c04 <ioapicenable>
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
80100bcb:	e8 d1 34 00 00       	call   801040a1 <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd3:	e8 91 2a 00 00       	call   80103669 <begin_op>

  if((ip = namei(path)) == 0){
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	pushl  0x8(%ebp)
80100bde:	e8 04 1a 00 00       	call   801025e7 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
    end_op();
80100bef:	e8 05 2b 00 00       	call   801036f9 <end_op>
    cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 95 a7 10 80       	push   $0x8010a795
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
80100c53:	e8 9b 6d 00 00       	call   801079f3 <setupkvm>
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
80100cf9:	e8 07 71 00 00       	call   80107e05 <allocuvm>
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
80100d3f:	e8 f0 6f 00 00       	call   80107d34 <loaduvm>
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
80100d80:	e8 74 29 00 00       	call   801036f9 <end_op>
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
80100dae:	e8 52 70 00 00       	call   80107e05 <allocuvm>
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
80100dd2:	e8 9c 72 00 00       	call   80108073 <clearpteu>
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
80100e0b:	e8 a5 44 00 00       	call   801052b5 <strlen>
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
80100e38:	e8 78 44 00 00       	call   801052b5 <strlen>
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
80100e5e:	e8 bb 73 00 00       	call   8010821e <copyout>
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
80100efa:	e8 1f 73 00 00       	call   8010821e <copyout>
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
80100f48:	e8 1a 43 00 00       	call   80105267 <safestrcpy>
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
80100f8b:	e8 8d 6b 00 00       	call   80107b1d <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 38 70 00 00       	call   80107fd6 <freevm>
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
80100fd9:	e8 f8 6f 00 00       	call   80107fd6 <freevm>
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
80100ff5:	e8 ff 26 00 00       	call   801036f9 <end_op>
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
8010100e:	68 a1 a7 10 80       	push   $0x8010a7a1
80101013:	68 a0 5d 11 80       	push   $0x80115da0
80101018:	e8 7a 3d 00 00       	call   80104d97 <initlock>
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
80101030:	68 a0 5d 11 80       	push   $0x80115da0
80101035:	e8 83 3d 00 00       	call   80104dbd <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 d4 5d 11 80 	movl   $0x80115dd4,-0xc(%ebp)
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
8010105d:	68 a0 5d 11 80       	push   $0x80115da0
80101062:	e8 c8 3d 00 00       	call   80104e2f <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 34 67 11 80       	mov    $0x80116734,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 a0 5d 11 80       	push   $0x80115da0
80101085:	e8 a5 3d 00 00       	call   80104e2f <release>
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
801010a1:	68 a0 5d 11 80       	push   $0x80115da0
801010a6:	e8 12 3d 00 00       	call   80104dbd <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 a8 a7 10 80       	push   $0x8010a7a8
801010c0:	e8 00 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 04             	mov    0x4(%eax),%eax
801010cb:	8d 50 01             	lea    0x1(%eax),%edx
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 a0 5d 11 80       	push   $0x80115da0
801010dc:	e8 4e 3d 00 00       	call   80104e2f <release>
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
801010f6:	68 a0 5d 11 80       	push   $0x80115da0
801010fb:	e8 bd 3c 00 00       	call   80104dbd <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 b0 a7 10 80       	push   $0x8010a7b0
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
80101136:	68 a0 5d 11 80       	push   $0x80115da0
8010113b:	e8 ef 3c 00 00       	call   80104e2f <release>
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
80101184:	68 a0 5d 11 80       	push   $0x80115da0
80101189:	e8 a1 3c 00 00       	call   80104e2f <release>
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
801011a8:	e8 6b 2b 00 00       	call   80103d18 <pipeclose>
801011ad:	83 c4 10             	add    $0x10,%esp
801011b0:	eb 21                	jmp    801011d3 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011b5:	83 f8 02             	cmp    $0x2,%eax
801011b8:	75 19                	jne    801011d3 <fileclose+0xea>
    begin_op();
801011ba:	e8 aa 24 00 00       	call   80103669 <begin_op>
    iput(ff.ip);
801011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011c2:	83 ec 0c             	sub    $0xc,%esp
801011c5:	50                   	push   %eax
801011c6:	e8 1a 0a 00 00       	call   80101be5 <iput>
801011cb:	83 c4 10             	add    $0x10,%esp
    end_op();
801011ce:	e8 26 25 00 00       	call   801036f9 <end_op>
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
80101269:	e8 5f 2c 00 00       	call   80103ecd <piperead>
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
801012e0:	68 ba a7 10 80       	push   $0x8010a7ba
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
80101326:	e8 9c 2a 00 00       	call   80103dc7 <pipewrite>
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
8010136b:	e8 f9 22 00 00       	call   80103669 <begin_op>
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
801013d1:	e8 23 23 00 00       	call   801036f9 <end_op>

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
801013e7:	68 c3 a7 10 80       	push   $0x8010a7c3
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
8010141d:	68 d3 a7 10 80       	push   $0x8010a7d3
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
80101459:	e8 b5 3c 00 00       	call   80105113 <memmove>
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
801014a3:	e8 a4 3b 00 00       	call   8010504c <memset>
801014a8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ab:	83 ec 0c             	sub    $0xc,%esp
801014ae:	ff 75 f4             	pushl  -0xc(%ebp)
801014b1:	e8 fc 23 00 00       	call   801038b2 <log_write>
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
801014fa:	a1 b8 67 11 80       	mov    0x801167b8,%eax
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
80101589:	e8 24 23 00 00       	call   801038b2 <log_write>
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
801015d8:	a1 a0 67 11 80       	mov    0x801167a0,%eax
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
801015fa:	8b 15 a0 67 11 80    	mov    0x801167a0,%edx
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	39 c2                	cmp    %eax,%edx
80101605:	0f 87 dc fe ff ff    	ja     801014e7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010160b:	83 ec 0c             	sub    $0xc,%esp
8010160e:	68 e0 a7 10 80       	push   $0x8010a7e0
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
80101627:	68 a0 67 11 80       	push   $0x801167a0
8010162c:	ff 75 08             	pushl  0x8(%ebp)
8010162f:	e8 f8 fd ff ff       	call   8010142c <readsb>
80101634:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163a:	c1 e8 0c             	shr    $0xc,%eax
8010163d:	89 c2                	mov    %eax,%edx
8010163f:	a1 b8 67 11 80       	mov    0x801167b8,%eax
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
801016a5:	68 f6 a7 10 80       	push   $0x8010a7f6
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
801016dd:	e8 d0 21 00 00       	call   801038b2 <log_write>
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
8010170d:	68 09 a8 10 80       	push   $0x8010a809
80101712:	68 c0 67 11 80       	push   $0x801167c0
80101717:	e8 7b 36 00 00       	call   80104d97 <initlock>
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
80101738:	05 c0 67 11 80       	add    $0x801167c0,%eax
8010173d:	83 c0 10             	add    $0x10,%eax
80101740:	83 ec 08             	sub    $0x8,%esp
80101743:	68 10 a8 10 80       	push   $0x8010a810
80101748:	50                   	push   %eax
80101749:	e8 dc 34 00 00       	call   80104c2a <initsleeplock>
8010174e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101751:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101755:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101759:	7e cd                	jle    80101728 <iinit+0x32>
  }

  readsb(dev, &sb);
8010175b:	83 ec 08             	sub    $0x8,%esp
8010175e:	68 a0 67 11 80       	push   $0x801167a0
80101763:	ff 75 08             	pushl  0x8(%ebp)
80101766:	e8 c1 fc ff ff       	call   8010142c <readsb>
8010176b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010176e:	a1 b8 67 11 80       	mov    0x801167b8,%eax
80101773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101776:	8b 3d b4 67 11 80    	mov    0x801167b4,%edi
8010177c:	8b 35 b0 67 11 80    	mov    0x801167b0,%esi
80101782:	8b 1d ac 67 11 80    	mov    0x801167ac,%ebx
80101788:	8b 0d a8 67 11 80    	mov    0x801167a8,%ecx
8010178e:	8b 15 a4 67 11 80    	mov    0x801167a4,%edx
80101794:	a1 a0 67 11 80       	mov    0x801167a0,%eax
80101799:	ff 75 d4             	pushl  -0x2c(%ebp)
8010179c:	57                   	push   %edi
8010179d:	56                   	push   %esi
8010179e:	53                   	push   %ebx
8010179f:	51                   	push   %ecx
801017a0:	52                   	push   %edx
801017a1:	50                   	push   %eax
801017a2:	68 18 a8 10 80       	push   $0x8010a818
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
801017dd:	a1 b4 67 11 80       	mov    0x801167b4,%eax
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
8010181f:	e8 28 38 00 00       	call   8010504c <memset>
80101824:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101827:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010182a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010182e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101831:	83 ec 0c             	sub    $0xc,%esp
80101834:	ff 75 f0             	pushl  -0x10(%ebp)
80101837:	e8 76 20 00 00       	call   801038b2 <log_write>
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
80101873:	8b 15 a8 67 11 80    	mov    0x801167a8,%edx
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	39 c2                	cmp    %eax,%edx
8010187e:	0f 87 51 ff ff ff    	ja     801017d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 6b a8 10 80       	push   $0x8010a86b
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
801018a8:	a1 b4 67 11 80       	mov    0x801167b4,%eax
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
80101931:	e8 dd 37 00 00       	call   80105113 <memmove>
80101936:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	ff 75 f4             	pushl  -0xc(%ebp)
8010193f:	e8 6e 1f 00 00       	call   801038b2 <log_write>
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
80101965:	68 c0 67 11 80       	push   $0x801167c0
8010196a:	e8 4e 34 00 00       	call   80104dbd <acquire>
8010196f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101972:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101979:	c7 45 f4 f4 67 11 80 	movl   $0x801167f4,-0xc(%ebp)
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
801019b3:	68 c0 67 11 80       	push   $0x801167c0
801019b8:	e8 72 34 00 00       	call   80104e2f <release>
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
801019e2:	81 7d f4 14 84 11 80 	cmpl   $0x80118414,-0xc(%ebp)
801019e9:	72 97                	jb     80101982 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ef:	75 0d                	jne    801019fe <iget+0xa6>
    panic("iget: no inodes");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 7d a8 10 80       	push   $0x8010a87d
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
80101a2c:	68 c0 67 11 80       	push   $0x801167c0
80101a31:	e8 f9 33 00 00       	call   80104e2f <release>
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
80101a4b:	68 c0 67 11 80       	push   $0x801167c0
80101a50:	e8 68 33 00 00       	call   80104dbd <acquire>
80101a55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	8d 50 01             	lea    0x1(%eax),%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 c0 67 11 80       	push   $0x801167c0
80101a6f:	e8 bb 33 00 00       	call   80104e2f <release>
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
80101a99:	68 8d a8 10 80       	push   $0x8010a88d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 b8 31 00 00       	call   80104c6a <acquiresleep>
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
80101ace:	a1 b4 67 11 80       	mov    0x801167b4,%eax
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
80101b57:	e8 b7 35 00 00       	call   80105113 <memmove>
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
80101b86:	68 93 a8 10 80       	push   $0x8010a893
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
80101bad:	e8 72 31 00 00       	call   80104d24 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 a2 a8 10 80       	push   $0x8010a8a2
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 f3 30 00 00       	call   80104cd2 <releasesleep>
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
80101bf9:	e8 6c 30 00 00       	call   80104c6a <acquiresleep>
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
80101c1a:	68 c0 67 11 80       	push   $0x801167c0
80101c1f:	e8 99 31 00 00       	call   80104dbd <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 c0 67 11 80       	push   $0x801167c0
80101c38:	e8 f2 31 00 00       	call   80104e2f <release>
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
80101c7f:	e8 4e 30 00 00       	call   80104cd2 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 c0 67 11 80       	push   $0x801167c0
80101c8f:	e8 29 31 00 00       	call   80104dbd <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	68 c0 67 11 80       	push   $0x801167c0
80101cae:	e8 7c 31 00 00       	call   80104e2f <release>
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
80101ddc:	e8 d1 1a 00 00       	call   801038b2 <log_write>
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
80101dfa:	68 aa a8 10 80       	push   $0x8010a8aa
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
80101fbc:	8b 04 c5 40 67 11 80 	mov    -0x7fee98c0(,%eax,8),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	75 0a                	jne    80101fd1 <readi+0x4d>
      return -1;
80101fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fcc:	e9 0a 01 00 00       	jmp    801020db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd8:	98                   	cwtl   
80101fd9:	8b 04 c5 40 67 11 80 	mov    -0x7fee98c0(,%eax,8),%eax
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
801020a4:	e8 6a 30 00 00       	call   80105113 <memmove>
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
80102115:	8b 04 c5 44 67 11 80 	mov    -0x7fee98bc(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x4d>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3b 01 00 00       	jmp    80102265 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102131:	98                   	cwtl   
80102132:	8b 04 c5 44 67 11 80 	mov    -0x7fee98bc(,%eax,8),%eax
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
801021f8:	e8 16 2f 00 00       	call   80105113 <memmove>
801021fd:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 f0             	pushl  -0x10(%ebp)
80102206:	e8 a7 16 00 00       	call   801038b2 <log_write>
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
8010227c:	e8 30 2f 00 00       	call   801051b1 <strncmp>
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
801022a0:	68 bd a8 10 80       	push   $0x8010a8bd
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
801022cf:	68 cf a8 10 80       	push   $0x8010a8cf
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
801023a8:	68 de a8 10 80       	push   $0x8010a8de
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
801023e3:	e8 23 2e 00 00       	call   8010520b <strncpy>
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
8010240f:	68 eb a8 10 80       	push   $0x8010a8eb
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
80102485:	e8 89 2c 00 00       	call   80105113 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 72 2c 00 00       	call   80105113 <memmove>
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
801024ef:	e8 ad 1b 00 00       	call   801040a1 <myproc>
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

80102626 <inb>:
{
80102626:	55                   	push   %ebp
80102627:	89 e5                	mov    %esp,%ebp
80102629:	83 ec 14             	sub    $0x14,%esp
8010262c:	8b 45 08             	mov    0x8(%ebp),%eax
8010262f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102633:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	ec                   	in     (%dx),%al
8010263a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010263d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102641:	c9                   	leave  
80102642:	c3                   	ret    

80102643 <insl>:
{
80102643:	55                   	push   %ebp
80102644:	89 e5                	mov    %esp,%ebp
80102646:	57                   	push   %edi
80102647:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102648:	8b 55 08             	mov    0x8(%ebp),%edx
8010264b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010264e:	8b 45 10             	mov    0x10(%ebp),%eax
80102651:	89 cb                	mov    %ecx,%ebx
80102653:	89 df                	mov    %ebx,%edi
80102655:	89 c1                	mov    %eax,%ecx
80102657:	fc                   	cld    
80102658:	f3 6d                	rep insl (%dx),%es:(%edi)
8010265a:	89 c8                	mov    %ecx,%eax
8010265c:	89 fb                	mov    %edi,%ebx
8010265e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102661:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102664:	90                   	nop
80102665:	5b                   	pop    %ebx
80102666:	5f                   	pop    %edi
80102667:	5d                   	pop    %ebp
80102668:	c3                   	ret    

80102669 <outb>:
{
80102669:	55                   	push   %ebp
8010266a:	89 e5                	mov    %esp,%ebp
8010266c:	83 ec 08             	sub    $0x8,%esp
8010266f:	8b 45 08             	mov    0x8(%ebp),%eax
80102672:	8b 55 0c             	mov    0xc(%ebp),%edx
80102675:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102679:	89 d0                	mov    %edx,%eax
8010267b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010267e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102682:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102686:	ee                   	out    %al,(%dx)
}
80102687:	90                   	nop
80102688:	c9                   	leave  
80102689:	c3                   	ret    

8010268a <outsl>:
{
8010268a:	55                   	push   %ebp
8010268b:	89 e5                	mov    %esp,%ebp
8010268d:	56                   	push   %esi
8010268e:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010268f:	8b 55 08             	mov    0x8(%ebp),%edx
80102692:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102695:	8b 45 10             	mov    0x10(%ebp),%eax
80102698:	89 cb                	mov    %ecx,%ebx
8010269a:	89 de                	mov    %ebx,%esi
8010269c:	89 c1                	mov    %eax,%ecx
8010269e:	fc                   	cld    
8010269f:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801026a1:	89 c8                	mov    %ecx,%eax
801026a3:	89 f3                	mov    %esi,%ebx
801026a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026a8:	89 45 10             	mov    %eax,0x10(%ebp)
}
801026ab:	90                   	nop
801026ac:	5b                   	pop    %ebx
801026ad:	5e                   	pop    %esi
801026ae:	5d                   	pop    %ebp
801026af:	c3                   	ret    

801026b0 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026b0:	f3 0f 1e fb          	endbr32 
801026b4:	55                   	push   %ebp
801026b5:	89 e5                	mov    %esp,%ebp
801026b7:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026ba:	90                   	nop
801026bb:	68 f7 01 00 00       	push   $0x1f7
801026c0:	e8 61 ff ff ff       	call   80102626 <inb>
801026c5:	83 c4 04             	add    $0x4,%esp
801026c8:	0f b6 c0             	movzbl %al,%eax
801026cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026d1:	25 c0 00 00 00       	and    $0xc0,%eax
801026d6:	83 f8 40             	cmp    $0x40,%eax
801026d9:	75 e0                	jne    801026bb <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026df:	74 11                	je     801026f2 <idewait+0x42>
801026e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026e4:	83 e0 21             	and    $0x21,%eax
801026e7:	85 c0                	test   %eax,%eax
801026e9:	74 07                	je     801026f2 <idewait+0x42>
    return -1;
801026eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026f0:	eb 05                	jmp    801026f7 <idewait+0x47>
  return 0;
801026f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026f7:	c9                   	leave  
801026f8:	c3                   	ret    

801026f9 <ideinit>:

void
ideinit(void)
{
801026f9:	f3 0f 1e fb          	endbr32 
801026fd:	55                   	push   %ebp
801026fe:	89 e5                	mov    %esp,%ebp
80102700:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102703:	83 ec 08             	sub    $0x8,%esp
80102706:	68 f3 a8 10 80       	push   $0x8010a8f3
8010270b:	68 60 00 11 80       	push   $0x80110060
80102710:	e8 82 26 00 00       	call   80104d97 <initlock>
80102715:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102718:	a1 c0 af 11 80       	mov    0x8011afc0,%eax
8010271d:	83 e8 01             	sub    $0x1,%eax
80102720:	83 ec 08             	sub    $0x8,%esp
80102723:	50                   	push   %eax
80102724:	6a 0e                	push   $0xe
80102726:	e8 d9 04 00 00       	call   80102c04 <ioapicenable>
8010272b:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010272e:	83 ec 0c             	sub    $0xc,%esp
80102731:	6a 00                	push   $0x0
80102733:	e8 78 ff ff ff       	call   801026b0 <idewait>
80102738:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010273b:	83 ec 08             	sub    $0x8,%esp
8010273e:	68 f0 00 00 00       	push   $0xf0
80102743:	68 f6 01 00 00       	push   $0x1f6
80102748:	e8 1c ff ff ff       	call   80102669 <outb>
8010274d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102757:	eb 24                	jmp    8010277d <ideinit+0x84>
    if(inb(0x1f7) != 0){
80102759:	83 ec 0c             	sub    $0xc,%esp
8010275c:	68 f7 01 00 00       	push   $0x1f7
80102761:	e8 c0 fe ff ff       	call   80102626 <inb>
80102766:	83 c4 10             	add    $0x10,%esp
80102769:	84 c0                	test   %al,%al
8010276b:	74 0c                	je     80102779 <ideinit+0x80>
      havedisk1 = 1;
8010276d:	c7 05 98 00 11 80 01 	movl   $0x1,0x80110098
80102774:	00 00 00 
      break;
80102777:	eb 0d                	jmp    80102786 <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102779:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010277d:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102784:	7e d3                	jle    80102759 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102786:	83 ec 08             	sub    $0x8,%esp
80102789:	68 e0 00 00 00       	push   $0xe0
8010278e:	68 f6 01 00 00       	push   $0x1f6
80102793:	e8 d1 fe ff ff       	call   80102669 <outb>
80102798:	83 c4 10             	add    $0x10,%esp
}
8010279b:	90                   	nop
8010279c:	c9                   	leave  
8010279d:	c3                   	ret    

8010279e <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010279e:	f3 0f 1e fb          	endbr32 
801027a2:	55                   	push   %ebp
801027a3:	89 e5                	mov    %esp,%ebp
801027a5:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801027a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027ac:	75 0d                	jne    801027bb <idestart+0x1d>
    panic("idestart");
801027ae:	83 ec 0c             	sub    $0xc,%esp
801027b1:	68 f7 a8 10 80       	push   $0x8010a8f7
801027b6:	e8 0a de ff ff       	call   801005c5 <panic>
  if(b->blockno >= FSSIZE)
801027bb:	8b 45 08             	mov    0x8(%ebp),%eax
801027be:	8b 40 08             	mov    0x8(%eax),%eax
801027c1:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027c6:	76 0d                	jbe    801027d5 <idestart+0x37>
    panic("incorrect blockno");
801027c8:	83 ec 0c             	sub    $0xc,%esp
801027cb:	68 00 a9 10 80       	push   $0x8010a900
801027d0:	e8 f0 dd ff ff       	call   801005c5 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027d5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027dc:	8b 45 08             	mov    0x8(%ebp),%eax
801027df:	8b 50 08             	mov    0x8(%eax),%edx
801027e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e5:	0f af c2             	imul   %edx,%eax
801027e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027eb:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027ef:	75 07                	jne    801027f8 <idestart+0x5a>
801027f1:	b8 20 00 00 00       	mov    $0x20,%eax
801027f6:	eb 05                	jmp    801027fd <idestart+0x5f>
801027f8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102800:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102804:	75 07                	jne    8010280d <idestart+0x6f>
80102806:	b8 30 00 00 00       	mov    $0x30,%eax
8010280b:	eb 05                	jmp    80102812 <idestart+0x74>
8010280d:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102812:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102815:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102819:	7e 0d                	jle    80102828 <idestart+0x8a>
8010281b:	83 ec 0c             	sub    $0xc,%esp
8010281e:	68 f7 a8 10 80       	push   $0x8010a8f7
80102823:	e8 9d dd ff ff       	call   801005c5 <panic>

  idewait(0);
80102828:	83 ec 0c             	sub    $0xc,%esp
8010282b:	6a 00                	push   $0x0
8010282d:	e8 7e fe ff ff       	call   801026b0 <idewait>
80102832:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102835:	83 ec 08             	sub    $0x8,%esp
80102838:	6a 00                	push   $0x0
8010283a:	68 f6 03 00 00       	push   $0x3f6
8010283f:	e8 25 fe ff ff       	call   80102669 <outb>
80102844:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010284a:	0f b6 c0             	movzbl %al,%eax
8010284d:	83 ec 08             	sub    $0x8,%esp
80102850:	50                   	push   %eax
80102851:	68 f2 01 00 00       	push   $0x1f2
80102856:	e8 0e fe ff ff       	call   80102669 <outb>
8010285b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010285e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102861:	0f b6 c0             	movzbl %al,%eax
80102864:	83 ec 08             	sub    $0x8,%esp
80102867:	50                   	push   %eax
80102868:	68 f3 01 00 00       	push   $0x1f3
8010286d:	e8 f7 fd ff ff       	call   80102669 <outb>
80102872:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102878:	c1 f8 08             	sar    $0x8,%eax
8010287b:	0f b6 c0             	movzbl %al,%eax
8010287e:	83 ec 08             	sub    $0x8,%esp
80102881:	50                   	push   %eax
80102882:	68 f4 01 00 00       	push   $0x1f4
80102887:	e8 dd fd ff ff       	call   80102669 <outb>
8010288c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010288f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102892:	c1 f8 10             	sar    $0x10,%eax
80102895:	0f b6 c0             	movzbl %al,%eax
80102898:	83 ec 08             	sub    $0x8,%esp
8010289b:	50                   	push   %eax
8010289c:	68 f5 01 00 00       	push   $0x1f5
801028a1:	e8 c3 fd ff ff       	call   80102669 <outb>
801028a6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801028a9:	8b 45 08             	mov    0x8(%ebp),%eax
801028ac:	8b 40 04             	mov    0x4(%eax),%eax
801028af:	c1 e0 04             	shl    $0x4,%eax
801028b2:	83 e0 10             	and    $0x10,%eax
801028b5:	89 c2                	mov    %eax,%edx
801028b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ba:	c1 f8 18             	sar    $0x18,%eax
801028bd:	83 e0 0f             	and    $0xf,%eax
801028c0:	09 d0                	or     %edx,%eax
801028c2:	83 c8 e0             	or     $0xffffffe0,%eax
801028c5:	0f b6 c0             	movzbl %al,%eax
801028c8:	83 ec 08             	sub    $0x8,%esp
801028cb:	50                   	push   %eax
801028cc:	68 f6 01 00 00       	push   $0x1f6
801028d1:	e8 93 fd ff ff       	call   80102669 <outb>
801028d6:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801028d9:	8b 45 08             	mov    0x8(%ebp),%eax
801028dc:	8b 00                	mov    (%eax),%eax
801028de:	83 e0 04             	and    $0x4,%eax
801028e1:	85 c0                	test   %eax,%eax
801028e3:	74 35                	je     8010291a <idestart+0x17c>
    outb(0x1f7, write_cmd);
801028e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028e8:	0f b6 c0             	movzbl %al,%eax
801028eb:	83 ec 08             	sub    $0x8,%esp
801028ee:	50                   	push   %eax
801028ef:	68 f7 01 00 00       	push   $0x1f7
801028f4:	e8 70 fd ff ff       	call   80102669 <outb>
801028f9:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028fc:	8b 45 08             	mov    0x8(%ebp),%eax
801028ff:	83 c0 5c             	add    $0x5c,%eax
80102902:	83 ec 04             	sub    $0x4,%esp
80102905:	68 80 00 00 00       	push   $0x80
8010290a:	50                   	push   %eax
8010290b:	68 f0 01 00 00       	push   $0x1f0
80102910:	e8 75 fd ff ff       	call   8010268a <outsl>
80102915:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102918:	eb 17                	jmp    80102931 <idestart+0x193>
    outb(0x1f7, read_cmd);
8010291a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010291d:	0f b6 c0             	movzbl %al,%eax
80102920:	83 ec 08             	sub    $0x8,%esp
80102923:	50                   	push   %eax
80102924:	68 f7 01 00 00       	push   $0x1f7
80102929:	e8 3b fd ff ff       	call   80102669 <outb>
8010292e:	83 c4 10             	add    $0x10,%esp
}
80102931:	90                   	nop
80102932:	c9                   	leave  
80102933:	c3                   	ret    

80102934 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102934:	f3 0f 1e fb          	endbr32 
80102938:	55                   	push   %ebp
80102939:	89 e5                	mov    %esp,%ebp
8010293b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 60 00 11 80       	push   $0x80110060
80102946:	e8 72 24 00 00       	call   80104dbd <acquire>
8010294b:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010294e:	a1 94 00 11 80       	mov    0x80110094,%eax
80102953:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102956:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010295a:	75 15                	jne    80102971 <ideintr+0x3d>
    release(&idelock);
8010295c:	83 ec 0c             	sub    $0xc,%esp
8010295f:	68 60 00 11 80       	push   $0x80110060
80102964:	e8 c6 24 00 00       	call   80104e2f <release>
80102969:	83 c4 10             	add    $0x10,%esp
    return;
8010296c:	e9 9a 00 00 00       	jmp    80102a0b <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102974:	8b 40 58             	mov    0x58(%eax),%eax
80102977:	a3 94 00 11 80       	mov    %eax,0x80110094

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010297c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010297f:	8b 00                	mov    (%eax),%eax
80102981:	83 e0 04             	and    $0x4,%eax
80102984:	85 c0                	test   %eax,%eax
80102986:	75 2d                	jne    801029b5 <ideintr+0x81>
80102988:	83 ec 0c             	sub    $0xc,%esp
8010298b:	6a 01                	push   $0x1
8010298d:	e8 1e fd ff ff       	call   801026b0 <idewait>
80102992:	83 c4 10             	add    $0x10,%esp
80102995:	85 c0                	test   %eax,%eax
80102997:	78 1c                	js     801029b5 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299c:	83 c0 5c             	add    $0x5c,%eax
8010299f:	83 ec 04             	sub    $0x4,%esp
801029a2:	68 80 00 00 00       	push   $0x80
801029a7:	50                   	push   %eax
801029a8:	68 f0 01 00 00       	push   $0x1f0
801029ad:	e8 91 fc ff ff       	call   80102643 <insl>
801029b2:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801029b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b8:	8b 00                	mov    (%eax),%eax
801029ba:	83 c8 02             	or     $0x2,%eax
801029bd:	89 c2                	mov    %eax,%edx
801029bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c2:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c7:	8b 00                	mov    (%eax),%eax
801029c9:	83 e0 fb             	and    $0xfffffffb,%eax
801029cc:	89 c2                	mov    %eax,%edx
801029ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029d3:	83 ec 0c             	sub    $0xc,%esp
801029d6:	ff 75 f4             	pushl  -0xc(%ebp)
801029d9:	e8 8b 20 00 00       	call   80104a69 <wakeup>
801029de:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801029e1:	a1 94 00 11 80       	mov    0x80110094,%eax
801029e6:	85 c0                	test   %eax,%eax
801029e8:	74 11                	je     801029fb <ideintr+0xc7>
    idestart(idequeue);
801029ea:	a1 94 00 11 80       	mov    0x80110094,%eax
801029ef:	83 ec 0c             	sub    $0xc,%esp
801029f2:	50                   	push   %eax
801029f3:	e8 a6 fd ff ff       	call   8010279e <idestart>
801029f8:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029fb:	83 ec 0c             	sub    $0xc,%esp
801029fe:	68 60 00 11 80       	push   $0x80110060
80102a03:	e8 27 24 00 00       	call   80104e2f <release>
80102a08:	83 c4 10             	add    $0x10,%esp
}
80102a0b:	c9                   	leave  
80102a0c:	c3                   	ret    

80102a0d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a0d:	f3 0f 1e fb          	endbr32 
80102a11:	55                   	push   %ebp
80102a12:	89 e5                	mov    %esp,%ebp
80102a14:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102a17:	8b 15 98 00 11 80    	mov    0x80110098,%edx
80102a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a20:	8b 40 04             	mov    0x4(%eax),%eax
80102a23:	83 ec 04             	sub    $0x4,%esp
80102a26:	52                   	push   %edx
80102a27:	50                   	push   %eax
80102a28:	68 12 a9 10 80       	push   $0x8010a912
80102a2d:	e8 da d9 ff ff       	call   8010040c <cprintf>
80102a32:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
80102a35:	8b 45 08             	mov    0x8(%ebp),%eax
80102a38:	83 c0 0c             	add    $0xc,%eax
80102a3b:	83 ec 0c             	sub    $0xc,%esp
80102a3e:	50                   	push   %eax
80102a3f:	e8 e0 22 00 00       	call   80104d24 <holdingsleep>
80102a44:	83 c4 10             	add    $0x10,%esp
80102a47:	85 c0                	test   %eax,%eax
80102a49:	75 0d                	jne    80102a58 <iderw+0x4b>
    panic("iderw: buf not locked");
80102a4b:	83 ec 0c             	sub    $0xc,%esp
80102a4e:	68 2c a9 10 80       	push   $0x8010a92c
80102a53:	e8 6d db ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a58:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5b:	8b 00                	mov    (%eax),%eax
80102a5d:	83 e0 06             	and    $0x6,%eax
80102a60:	83 f8 02             	cmp    $0x2,%eax
80102a63:	75 0d                	jne    80102a72 <iderw+0x65>
    panic("iderw: nothing to do");
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	68 42 a9 10 80       	push   $0x8010a942
80102a6d:	e8 53 db ff ff       	call   801005c5 <panic>
  if(b->dev != 0 && !havedisk1)
80102a72:	8b 45 08             	mov    0x8(%ebp),%eax
80102a75:	8b 40 04             	mov    0x4(%eax),%eax
80102a78:	85 c0                	test   %eax,%eax
80102a7a:	74 16                	je     80102a92 <iderw+0x85>
80102a7c:	a1 98 00 11 80       	mov    0x80110098,%eax
80102a81:	85 c0                	test   %eax,%eax
80102a83:	75 0d                	jne    80102a92 <iderw+0x85>
    panic("iderw: ide disk 1 not present");
80102a85:	83 ec 0c             	sub    $0xc,%esp
80102a88:	68 57 a9 10 80       	push   $0x8010a957
80102a8d:	e8 33 db ff ff       	call   801005c5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a92:	83 ec 0c             	sub    $0xc,%esp
80102a95:	68 60 00 11 80       	push   $0x80110060
80102a9a:	e8 1e 23 00 00       	call   80104dbd <acquire>
80102a9f:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa5:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102aac:	c7 45 f4 94 00 11 80 	movl   $0x80110094,-0xc(%ebp)
80102ab3:	eb 0b                	jmp    80102ac0 <iderw+0xb3>
80102ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab8:	8b 00                	mov    (%eax),%eax
80102aba:	83 c0 58             	add    $0x58,%eax
80102abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac3:	8b 00                	mov    (%eax),%eax
80102ac5:	85 c0                	test   %eax,%eax
80102ac7:	75 ec                	jne    80102ab5 <iderw+0xa8>
    ;
  *pp = b;
80102ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acc:	8b 55 08             	mov    0x8(%ebp),%edx
80102acf:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102ad1:	a1 94 00 11 80       	mov    0x80110094,%eax
80102ad6:	39 45 08             	cmp    %eax,0x8(%ebp)
80102ad9:	75 23                	jne    80102afe <iderw+0xf1>
    idestart(b);
80102adb:	83 ec 0c             	sub    $0xc,%esp
80102ade:	ff 75 08             	pushl  0x8(%ebp)
80102ae1:	e8 b8 fc ff ff       	call   8010279e <idestart>
80102ae6:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ae9:	eb 13                	jmp    80102afe <iderw+0xf1>
    sleep(b, &idelock);
80102aeb:	83 ec 08             	sub    $0x8,%esp
80102aee:	68 60 00 11 80       	push   $0x80110060
80102af3:	ff 75 08             	pushl  0x8(%ebp)
80102af6:	e8 7f 1e 00 00       	call   8010497a <sleep>
80102afb:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102afe:	8b 45 08             	mov    0x8(%ebp),%eax
80102b01:	8b 00                	mov    (%eax),%eax
80102b03:	83 e0 06             	and    $0x6,%eax
80102b06:	83 f8 02             	cmp    $0x2,%eax
80102b09:	75 e0                	jne    80102aeb <iderw+0xde>
  }


  release(&idelock);
80102b0b:	83 ec 0c             	sub    $0xc,%esp
80102b0e:	68 60 00 11 80       	push   $0x80110060
80102b13:	e8 17 23 00 00       	call   80104e2f <release>
80102b18:	83 c4 10             	add    $0x10,%esp
}
80102b1b:	90                   	nop
80102b1c:	c9                   	leave  
80102b1d:	c3                   	ret    

80102b1e <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b1e:	f3 0f 1e fb          	endbr32 
80102b22:	55                   	push   %ebp
80102b23:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b25:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b2a:	8b 55 08             	mov    0x8(%ebp),%edx
80102b2d:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b2f:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b34:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b37:	5d                   	pop    %ebp
80102b38:	c3                   	ret    

80102b39 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b39:	f3 0f 1e fb          	endbr32 
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b40:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b45:	8b 55 08             	mov    0x8(%ebp),%edx
80102b48:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b4a:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b52:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b55:	90                   	nop
80102b56:	5d                   	pop    %ebp
80102b57:	c3                   	ret    

80102b58 <ioapicinit>:

void
ioapicinit(void)
{
80102b58:	f3 0f 1e fb          	endbr32 
80102b5c:	55                   	push   %ebp
80102b5d:	89 e5                	mov    %esp,%ebp
80102b5f:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b62:	c7 05 14 84 11 80 00 	movl   $0xfec00000,0x80118414
80102b69:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b6c:	6a 01                	push   $0x1
80102b6e:	e8 ab ff ff ff       	call   80102b1e <ioapicread>
80102b73:	83 c4 04             	add    $0x4,%esp
80102b76:	c1 e8 10             	shr    $0x10,%eax
80102b79:	25 ff 00 00 00       	and    $0xff,%eax
80102b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b81:	6a 00                	push   $0x0
80102b83:	e8 96 ff ff ff       	call   80102b1e <ioapicread>
80102b88:	83 c4 04             	add    $0x4,%esp
80102b8b:	c1 e8 18             	shr    $0x18,%eax
80102b8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b91:	0f b6 05 e0 ac 11 80 	movzbl 0x8011ace0,%eax
80102b98:	0f b6 c0             	movzbl %al,%eax
80102b9b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102b9e:	74 10                	je     80102bb0 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ba0:	83 ec 0c             	sub    $0xc,%esp
80102ba3:	68 78 a9 10 80       	push   $0x8010a978
80102ba8:	e8 5f d8 ff ff       	call   8010040c <cprintf>
80102bad:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102bb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102bb7:	eb 3f                	jmp    80102bf8 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbc:	83 c0 20             	add    $0x20,%eax
80102bbf:	0d 00 00 01 00       	or     $0x10000,%eax
80102bc4:	89 c2                	mov    %eax,%edx
80102bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc9:	83 c0 08             	add    $0x8,%eax
80102bcc:	01 c0                	add    %eax,%eax
80102bce:	83 ec 08             	sub    $0x8,%esp
80102bd1:	52                   	push   %edx
80102bd2:	50                   	push   %eax
80102bd3:	e8 61 ff ff ff       	call   80102b39 <ioapicwrite>
80102bd8:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bde:	83 c0 08             	add    $0x8,%eax
80102be1:	01 c0                	add    %eax,%eax
80102be3:	83 c0 01             	add    $0x1,%eax
80102be6:	83 ec 08             	sub    $0x8,%esp
80102be9:	6a 00                	push   $0x0
80102beb:	50                   	push   %eax
80102bec:	e8 48 ff ff ff       	call   80102b39 <ioapicwrite>
80102bf1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102bf4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bfb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102bfe:	7e b9                	jle    80102bb9 <ioapicinit+0x61>
  }
}
80102c00:	90                   	nop
80102c01:	90                   	nop
80102c02:	c9                   	leave  
80102c03:	c3                   	ret    

80102c04 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c04:	f3 0f 1e fb          	endbr32 
80102c08:	55                   	push   %ebp
80102c09:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0e:	83 c0 20             	add    $0x20,%eax
80102c11:	89 c2                	mov    %eax,%edx
80102c13:	8b 45 08             	mov    0x8(%ebp),%eax
80102c16:	83 c0 08             	add    $0x8,%eax
80102c19:	01 c0                	add    %eax,%eax
80102c1b:	52                   	push   %edx
80102c1c:	50                   	push   %eax
80102c1d:	e8 17 ff ff ff       	call   80102b39 <ioapicwrite>
80102c22:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c28:	c1 e0 18             	shl    $0x18,%eax
80102c2b:	89 c2                	mov    %eax,%edx
80102c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c30:	83 c0 08             	add    $0x8,%eax
80102c33:	01 c0                	add    %eax,%eax
80102c35:	83 c0 01             	add    $0x1,%eax
80102c38:	52                   	push   %edx
80102c39:	50                   	push   %eax
80102c3a:	e8 fa fe ff ff       	call   80102b39 <ioapicwrite>
80102c3f:	83 c4 08             	add    $0x8,%esp
}
80102c42:	90                   	nop
80102c43:	c9                   	leave  
80102c44:	c3                   	ret    

80102c45 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c45:	f3 0f 1e fb          	endbr32 
80102c49:	55                   	push   %ebp
80102c4a:	89 e5                	mov    %esp,%ebp
80102c4c:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102c4f:	83 ec 08             	sub    $0x8,%esp
80102c52:	68 aa a9 10 80       	push   $0x8010a9aa
80102c57:	68 20 84 11 80       	push   $0x80118420
80102c5c:	e8 36 21 00 00       	call   80104d97 <initlock>
80102c61:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102c64:	c7 05 54 84 11 80 00 	movl   $0x0,0x80118454
80102c6b:	00 00 00 
  freerange(vstart, vend);
80102c6e:	83 ec 08             	sub    $0x8,%esp
80102c71:	ff 75 0c             	pushl  0xc(%ebp)
80102c74:	ff 75 08             	pushl  0x8(%ebp)
80102c77:	e8 2e 00 00 00       	call   80102caa <freerange>
80102c7c:	83 c4 10             	add    $0x10,%esp
}
80102c7f:	90                   	nop
80102c80:	c9                   	leave  
80102c81:	c3                   	ret    

80102c82 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c82:	f3 0f 1e fb          	endbr32 
80102c86:	55                   	push   %ebp
80102c87:	89 e5                	mov    %esp,%ebp
80102c89:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c8c:	83 ec 08             	sub    $0x8,%esp
80102c8f:	ff 75 0c             	pushl  0xc(%ebp)
80102c92:	ff 75 08             	pushl  0x8(%ebp)
80102c95:	e8 10 00 00 00       	call   80102caa <freerange>
80102c9a:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c9d:	c7 05 54 84 11 80 01 	movl   $0x1,0x80118454
80102ca4:	00 00 00 
}
80102ca7:	90                   	nop
80102ca8:	c9                   	leave  
80102ca9:	c3                   	ret    

80102caa <freerange>:

void
freerange(void *vstart, void *vend)
{
80102caa:	f3 0f 1e fb          	endbr32 
80102cae:	55                   	push   %ebp
80102caf:	89 e5                	mov    %esp,%ebp
80102cb1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102cbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cc4:	eb 15                	jmp    80102cdb <freerange+0x31>
    kfree(p);
80102cc6:	83 ec 0c             	sub    $0xc,%esp
80102cc9:	ff 75 f4             	pushl  -0xc(%ebp)
80102ccc:	e8 1b 00 00 00       	call   80102cec <kfree>
80102cd1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cd4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cde:	05 00 10 00 00       	add    $0x1000,%eax
80102ce3:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102ce6:	73 de                	jae    80102cc6 <freerange+0x1c>
}
80102ce8:	90                   	nop
80102ce9:	90                   	nop
80102cea:	c9                   	leave  
80102ceb:	c3                   	ret    

80102cec <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cec:	f3 0f 1e fb          	endbr32 
80102cf0:	55                   	push   %ebp
80102cf1:	89 e5                	mov    %esp,%ebp
80102cf3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf9:	25 ff 0f 00 00       	and    $0xfff,%eax
80102cfe:	85 c0                	test   %eax,%eax
80102d00:	75 18                	jne    80102d1a <kfree+0x2e>
80102d02:	81 7d 08 00 b0 11 80 	cmpl   $0x8011b000,0x8(%ebp)
80102d09:	72 0f                	jb     80102d1a <kfree+0x2e>
80102d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d0e:	05 00 00 00 80       	add    $0x80000000,%eax
80102d13:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102d18:	76 0d                	jbe    80102d27 <kfree+0x3b>
    panic("kfree");
80102d1a:	83 ec 0c             	sub    $0xc,%esp
80102d1d:	68 af a9 10 80       	push   $0x8010a9af
80102d22:	e8 9e d8 ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d27:	83 ec 04             	sub    $0x4,%esp
80102d2a:	68 00 10 00 00       	push   $0x1000
80102d2f:	6a 01                	push   $0x1
80102d31:	ff 75 08             	pushl  0x8(%ebp)
80102d34:	e8 13 23 00 00       	call   8010504c <memset>
80102d39:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102d3c:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d41:	85 c0                	test   %eax,%eax
80102d43:	74 10                	je     80102d55 <kfree+0x69>
    acquire(&kmem.lock);
80102d45:	83 ec 0c             	sub    $0xc,%esp
80102d48:	68 20 84 11 80       	push   $0x80118420
80102d4d:	e8 6b 20 00 00       	call   80104dbd <acquire>
80102d52:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102d55:	8b 45 08             	mov    0x8(%ebp),%eax
80102d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102d5b:	8b 15 58 84 11 80    	mov    0x80118458,%edx
80102d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d64:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d69:	a3 58 84 11 80       	mov    %eax,0x80118458
  if(kmem.use_lock)
80102d6e:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d73:	85 c0                	test   %eax,%eax
80102d75:	74 10                	je     80102d87 <kfree+0x9b>
    release(&kmem.lock);
80102d77:	83 ec 0c             	sub    $0xc,%esp
80102d7a:	68 20 84 11 80       	push   $0x80118420
80102d7f:	e8 ab 20 00 00       	call   80104e2f <release>
80102d84:	83 c4 10             	add    $0x10,%esp
}
80102d87:	90                   	nop
80102d88:	c9                   	leave  
80102d89:	c3                   	ret    

80102d8a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d8a:	f3 0f 1e fb          	endbr32 
80102d8e:	55                   	push   %ebp
80102d8f:	89 e5                	mov    %esp,%ebp
80102d91:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d94:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d99:	85 c0                	test   %eax,%eax
80102d9b:	74 10                	je     80102dad <kalloc+0x23>
    acquire(&kmem.lock);
80102d9d:	83 ec 0c             	sub    $0xc,%esp
80102da0:	68 20 84 11 80       	push   $0x80118420
80102da5:	e8 13 20 00 00       	call   80104dbd <acquire>
80102daa:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102dad:	a1 58 84 11 80       	mov    0x80118458,%eax
80102db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102db5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102db9:	74 0a                	je     80102dc5 <kalloc+0x3b>
    kmem.freelist = r->next;
80102dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dbe:	8b 00                	mov    (%eax),%eax
80102dc0:	a3 58 84 11 80       	mov    %eax,0x80118458
  if(kmem.use_lock)
80102dc5:	a1 54 84 11 80       	mov    0x80118454,%eax
80102dca:	85 c0                	test   %eax,%eax
80102dcc:	74 10                	je     80102dde <kalloc+0x54>
    release(&kmem.lock);
80102dce:	83 ec 0c             	sub    $0xc,%esp
80102dd1:	68 20 84 11 80       	push   $0x80118420
80102dd6:	e8 54 20 00 00       	call   80104e2f <release>
80102ddb:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102de1:	c9                   	leave  
80102de2:	c3                   	ret    

80102de3 <inb>:
{
80102de3:	55                   	push   %ebp
80102de4:	89 e5                	mov    %esp,%ebp
80102de6:	83 ec 14             	sub    $0x14,%esp
80102de9:	8b 45 08             	mov    0x8(%ebp),%eax
80102dec:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102df0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102df4:	89 c2                	mov    %eax,%edx
80102df6:	ec                   	in     (%dx),%al
80102df7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dfa:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102dfe:	c9                   	leave  
80102dff:	c3                   	ret    

80102e00 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e00:	f3 0f 1e fb          	endbr32 
80102e04:	55                   	push   %ebp
80102e05:	89 e5                	mov    %esp,%ebp
80102e07:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e0a:	6a 64                	push   $0x64
80102e0c:	e8 d2 ff ff ff       	call   80102de3 <inb>
80102e11:	83 c4 04             	add    $0x4,%esp
80102e14:	0f b6 c0             	movzbl %al,%eax
80102e17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e1d:	83 e0 01             	and    $0x1,%eax
80102e20:	85 c0                	test   %eax,%eax
80102e22:	75 0a                	jne    80102e2e <kbdgetc+0x2e>
    return -1;
80102e24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e29:	e9 23 01 00 00       	jmp    80102f51 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102e2e:	6a 60                	push   $0x60
80102e30:	e8 ae ff ff ff       	call   80102de3 <inb>
80102e35:	83 c4 04             	add    $0x4,%esp
80102e38:	0f b6 c0             	movzbl %al,%eax
80102e3b:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e3e:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e45:	75 17                	jne    80102e5e <kbdgetc+0x5e>
    shift |= E0ESC;
80102e47:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e4c:	83 c8 40             	or     $0x40,%eax
80102e4f:	a3 9c 00 11 80       	mov    %eax,0x8011009c
    return 0;
80102e54:	b8 00 00 00 00       	mov    $0x0,%eax
80102e59:	e9 f3 00 00 00       	jmp    80102f51 <kbdgetc+0x151>
  } else if(data & 0x80){
80102e5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e61:	25 80 00 00 00       	and    $0x80,%eax
80102e66:	85 c0                	test   %eax,%eax
80102e68:	74 45                	je     80102eaf <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e6a:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e6f:	83 e0 40             	and    $0x40,%eax
80102e72:	85 c0                	test   %eax,%eax
80102e74:	75 08                	jne    80102e7e <kbdgetc+0x7e>
80102e76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e79:	83 e0 7f             	and    $0x7f,%eax
80102e7c:	eb 03                	jmp    80102e81 <kbdgetc+0x81>
80102e7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e81:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e87:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102e8c:	0f b6 00             	movzbl (%eax),%eax
80102e8f:	83 c8 40             	or     $0x40,%eax
80102e92:	0f b6 c0             	movzbl %al,%eax
80102e95:	f7 d0                	not    %eax
80102e97:	89 c2                	mov    %eax,%edx
80102e99:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e9e:	21 d0                	and    %edx,%eax
80102ea0:	a3 9c 00 11 80       	mov    %eax,0x8011009c
    return 0;
80102ea5:	b8 00 00 00 00       	mov    $0x0,%eax
80102eaa:	e9 a2 00 00 00       	jmp    80102f51 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102eaf:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102eb4:	83 e0 40             	and    $0x40,%eax
80102eb7:	85 c0                	test   %eax,%eax
80102eb9:	74 14                	je     80102ecf <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ebb:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102ec2:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102ec7:	83 e0 bf             	and    $0xffffffbf,%eax
80102eca:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  }

  shift |= shiftcode[data];
80102ecf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed2:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102ed7:	0f b6 00             	movzbl (%eax),%eax
80102eda:	0f b6 d0             	movzbl %al,%edx
80102edd:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102ee2:	09 d0                	or     %edx,%eax
80102ee4:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  shift ^= togglecode[data];
80102ee9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eec:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102ef1:	0f b6 00             	movzbl (%eax),%eax
80102ef4:	0f b6 d0             	movzbl %al,%edx
80102ef7:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102efc:	31 d0                	xor    %edx,%eax
80102efe:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f03:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102f08:	83 e0 03             	and    $0x3,%eax
80102f0b:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102f12:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f15:	01 d0                	add    %edx,%eax
80102f17:	0f b6 00             	movzbl (%eax),%eax
80102f1a:	0f b6 c0             	movzbl %al,%eax
80102f1d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f20:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102f25:	83 e0 08             	and    $0x8,%eax
80102f28:	85 c0                	test   %eax,%eax
80102f2a:	74 22                	je     80102f4e <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102f2c:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f30:	76 0c                	jbe    80102f3e <kbdgetc+0x13e>
80102f32:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f36:	77 06                	ja     80102f3e <kbdgetc+0x13e>
      c += 'A' - 'a';
80102f38:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f3c:	eb 10                	jmp    80102f4e <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102f3e:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f42:	76 0a                	jbe    80102f4e <kbdgetc+0x14e>
80102f44:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f48:	77 04                	ja     80102f4e <kbdgetc+0x14e>
      c += 'a' - 'A';
80102f4a:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f51:	c9                   	leave  
80102f52:	c3                   	ret    

80102f53 <kbdintr>:

void
kbdintr(void)
{
80102f53:	f3 0f 1e fb          	endbr32 
80102f57:	55                   	push   %ebp
80102f58:	89 e5                	mov    %esp,%ebp
80102f5a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102f5d:	83 ec 0c             	sub    $0xc,%esp
80102f60:	68 00 2e 10 80       	push   $0x80102e00
80102f65:	e8 96 d8 ff ff       	call   80100800 <consoleintr>
80102f6a:	83 c4 10             	add    $0x10,%esp
}
80102f6d:	90                   	nop
80102f6e:	c9                   	leave  
80102f6f:	c3                   	ret    

80102f70 <inb>:
{
80102f70:	55                   	push   %ebp
80102f71:	89 e5                	mov    %esp,%ebp
80102f73:	83 ec 14             	sub    $0x14,%esp
80102f76:	8b 45 08             	mov    0x8(%ebp),%eax
80102f79:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f7d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f81:	89 c2                	mov    %eax,%edx
80102f83:	ec                   	in     (%dx),%al
80102f84:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f87:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f8b:	c9                   	leave  
80102f8c:	c3                   	ret    

80102f8d <outb>:
{
80102f8d:	55                   	push   %ebp
80102f8e:	89 e5                	mov    %esp,%ebp
80102f90:	83 ec 08             	sub    $0x8,%esp
80102f93:	8b 45 08             	mov    0x8(%ebp),%eax
80102f96:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f99:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102f9d:	89 d0                	mov    %edx,%eax
80102f9f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fa2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102fa6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102faa:	ee                   	out    %al,(%dx)
}
80102fab:	90                   	nop
80102fac:	c9                   	leave  
80102fad:	c3                   	ret    

80102fae <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102fae:	f3 0f 1e fb          	endbr32 
80102fb2:	55                   	push   %ebp
80102fb3:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fb5:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fba:	8b 55 08             	mov    0x8(%ebp),%edx
80102fbd:	c1 e2 02             	shl    $0x2,%edx
80102fc0:	01 c2                	add    %eax,%edx
80102fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc5:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fc7:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fcc:	83 c0 20             	add    $0x20,%eax
80102fcf:	8b 00                	mov    (%eax),%eax
}
80102fd1:	90                   	nop
80102fd2:	5d                   	pop    %ebp
80102fd3:	c3                   	ret    

80102fd4 <lapicinit>:

void
lapicinit(void)
{
80102fd4:	f3 0f 1e fb          	endbr32 
80102fd8:	55                   	push   %ebp
80102fd9:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102fdb:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fe0:	85 c0                	test   %eax,%eax
80102fe2:	0f 84 0c 01 00 00    	je     801030f4 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102fe8:	68 3f 01 00 00       	push   $0x13f
80102fed:	6a 3c                	push   $0x3c
80102fef:	e8 ba ff ff ff       	call   80102fae <lapicw>
80102ff4:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ff7:	6a 0b                	push   $0xb
80102ff9:	68 f8 00 00 00       	push   $0xf8
80102ffe:	e8 ab ff ff ff       	call   80102fae <lapicw>
80103003:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103006:	68 20 00 02 00       	push   $0x20020
8010300b:	68 c8 00 00 00       	push   $0xc8
80103010:	e8 99 ff ff ff       	call   80102fae <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80103018:	68 80 96 98 00       	push   $0x989680
8010301d:	68 e0 00 00 00       	push   $0xe0
80103022:	e8 87 ff ff ff       	call   80102fae <lapicw>
80103027:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010302a:	68 00 00 01 00       	push   $0x10000
8010302f:	68 d4 00 00 00       	push   $0xd4
80103034:	e8 75 ff ff ff       	call   80102fae <lapicw>
80103039:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010303c:	68 00 00 01 00       	push   $0x10000
80103041:	68 d8 00 00 00       	push   $0xd8
80103046:	e8 63 ff ff ff       	call   80102fae <lapicw>
8010304b:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010304e:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103053:	83 c0 30             	add    $0x30,%eax
80103056:	8b 00                	mov    (%eax),%eax
80103058:	c1 e8 10             	shr    $0x10,%eax
8010305b:	25 fc 00 00 00       	and    $0xfc,%eax
80103060:	85 c0                	test   %eax,%eax
80103062:	74 12                	je     80103076 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80103064:	68 00 00 01 00       	push   $0x10000
80103069:	68 d0 00 00 00       	push   $0xd0
8010306e:	e8 3b ff ff ff       	call   80102fae <lapicw>
80103073:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103076:	6a 33                	push   $0x33
80103078:	68 dc 00 00 00       	push   $0xdc
8010307d:	e8 2c ff ff ff       	call   80102fae <lapicw>
80103082:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103085:	6a 00                	push   $0x0
80103087:	68 a0 00 00 00       	push   $0xa0
8010308c:	e8 1d ff ff ff       	call   80102fae <lapicw>
80103091:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103094:	6a 00                	push   $0x0
80103096:	68 a0 00 00 00       	push   $0xa0
8010309b:	e8 0e ff ff ff       	call   80102fae <lapicw>
801030a0:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801030a3:	6a 00                	push   $0x0
801030a5:	6a 2c                	push   $0x2c
801030a7:	e8 02 ff ff ff       	call   80102fae <lapicw>
801030ac:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801030af:	6a 00                	push   $0x0
801030b1:	68 c4 00 00 00       	push   $0xc4
801030b6:	e8 f3 fe ff ff       	call   80102fae <lapicw>
801030bb:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030be:	68 00 85 08 00       	push   $0x88500
801030c3:	68 c0 00 00 00       	push   $0xc0
801030c8:	e8 e1 fe ff ff       	call   80102fae <lapicw>
801030cd:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801030d0:	90                   	nop
801030d1:	a1 5c 84 11 80       	mov    0x8011845c,%eax
801030d6:	05 00 03 00 00       	add    $0x300,%eax
801030db:	8b 00                	mov    (%eax),%eax
801030dd:	25 00 10 00 00       	and    $0x1000,%eax
801030e2:	85 c0                	test   %eax,%eax
801030e4:	75 eb                	jne    801030d1 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030e6:	6a 00                	push   $0x0
801030e8:	6a 20                	push   $0x20
801030ea:	e8 bf fe ff ff       	call   80102fae <lapicw>
801030ef:	83 c4 08             	add    $0x8,%esp
801030f2:	eb 01                	jmp    801030f5 <lapicinit+0x121>
    return;
801030f4:	90                   	nop
}
801030f5:	c9                   	leave  
801030f6:	c3                   	ret    

801030f7 <lapicid>:

int
lapicid(void)
{
801030f7:	f3 0f 1e fb          	endbr32 
801030fb:	55                   	push   %ebp
801030fc:	89 e5                	mov    %esp,%ebp

  if (!lapic){
801030fe:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103103:	85 c0                	test   %eax,%eax
80103105:	75 07                	jne    8010310e <lapicid+0x17>
    return 0;
80103107:	b8 00 00 00 00       	mov    $0x0,%eax
8010310c:	eb 0d                	jmp    8010311b <lapicid+0x24>
  }
  return lapic[ID] >> 24;
8010310e:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103113:	83 c0 20             	add    $0x20,%eax
80103116:	8b 00                	mov    (%eax),%eax
80103118:	c1 e8 18             	shr    $0x18,%eax
}
8010311b:	5d                   	pop    %ebp
8010311c:	c3                   	ret    

8010311d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010311d:	f3 0f 1e fb          	endbr32 
80103121:	55                   	push   %ebp
80103122:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103124:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103129:	85 c0                	test   %eax,%eax
8010312b:	74 0c                	je     80103139 <lapiceoi+0x1c>
    lapicw(EOI, 0);
8010312d:	6a 00                	push   $0x0
8010312f:	6a 2c                	push   $0x2c
80103131:	e8 78 fe ff ff       	call   80102fae <lapicw>
80103136:	83 c4 08             	add    $0x8,%esp
}
80103139:	90                   	nop
8010313a:	c9                   	leave  
8010313b:	c3                   	ret    

8010313c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010313c:	f3 0f 1e fb          	endbr32 
80103140:	55                   	push   %ebp
80103141:	89 e5                	mov    %esp,%ebp
}
80103143:	90                   	nop
80103144:	5d                   	pop    %ebp
80103145:	c3                   	ret    

80103146 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103146:	f3 0f 1e fb          	endbr32 
8010314a:	55                   	push   %ebp
8010314b:	89 e5                	mov    %esp,%ebp
8010314d:	83 ec 14             	sub    $0x14,%esp
80103150:	8b 45 08             	mov    0x8(%ebp),%eax
80103153:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103156:	6a 0f                	push   $0xf
80103158:	6a 70                	push   $0x70
8010315a:	e8 2e fe ff ff       	call   80102f8d <outb>
8010315f:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103162:	6a 0a                	push   $0xa
80103164:	6a 71                	push   $0x71
80103166:	e8 22 fe ff ff       	call   80102f8d <outb>
8010316b:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010316e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103175:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103178:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010317d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103180:	c1 e8 04             	shr    $0x4,%eax
80103183:	89 c2                	mov    %eax,%edx
80103185:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103188:	83 c0 02             	add    $0x2,%eax
8010318b:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010318e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103192:	c1 e0 18             	shl    $0x18,%eax
80103195:	50                   	push   %eax
80103196:	68 c4 00 00 00       	push   $0xc4
8010319b:	e8 0e fe ff ff       	call   80102fae <lapicw>
801031a0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801031a3:	68 00 c5 00 00       	push   $0xc500
801031a8:	68 c0 00 00 00       	push   $0xc0
801031ad:	e8 fc fd ff ff       	call   80102fae <lapicw>
801031b2:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031b5:	68 c8 00 00 00       	push   $0xc8
801031ba:	e8 7d ff ff ff       	call   8010313c <microdelay>
801031bf:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801031c2:	68 00 85 00 00       	push   $0x8500
801031c7:	68 c0 00 00 00       	push   $0xc0
801031cc:	e8 dd fd ff ff       	call   80102fae <lapicw>
801031d1:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031d4:	6a 64                	push   $0x64
801031d6:	e8 61 ff ff ff       	call   8010313c <microdelay>
801031db:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031e5:	eb 3d                	jmp    80103224 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801031e7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031eb:	c1 e0 18             	shl    $0x18,%eax
801031ee:	50                   	push   %eax
801031ef:	68 c4 00 00 00       	push   $0xc4
801031f4:	e8 b5 fd ff ff       	call   80102fae <lapicw>
801031f9:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801031fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801031ff:	c1 e8 0c             	shr    $0xc,%eax
80103202:	80 cc 06             	or     $0x6,%ah
80103205:	50                   	push   %eax
80103206:	68 c0 00 00 00       	push   $0xc0
8010320b:	e8 9e fd ff ff       	call   80102fae <lapicw>
80103210:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103213:	68 c8 00 00 00       	push   $0xc8
80103218:	e8 1f ff ff ff       	call   8010313c <microdelay>
8010321d:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103220:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103224:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103228:	7e bd                	jle    801031e7 <lapicstartap+0xa1>
  }
}
8010322a:	90                   	nop
8010322b:	90                   	nop
8010322c:	c9                   	leave  
8010322d:	c3                   	ret    

8010322e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010322e:	f3 0f 1e fb          	endbr32 
80103232:	55                   	push   %ebp
80103233:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103235:	8b 45 08             	mov    0x8(%ebp),%eax
80103238:	0f b6 c0             	movzbl %al,%eax
8010323b:	50                   	push   %eax
8010323c:	6a 70                	push   $0x70
8010323e:	e8 4a fd ff ff       	call   80102f8d <outb>
80103243:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103246:	68 c8 00 00 00       	push   $0xc8
8010324b:	e8 ec fe ff ff       	call   8010313c <microdelay>
80103250:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103253:	6a 71                	push   $0x71
80103255:	e8 16 fd ff ff       	call   80102f70 <inb>
8010325a:	83 c4 04             	add    $0x4,%esp
8010325d:	0f b6 c0             	movzbl %al,%eax
}
80103260:	c9                   	leave  
80103261:	c3                   	ret    

80103262 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103262:	f3 0f 1e fb          	endbr32 
80103266:	55                   	push   %ebp
80103267:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103269:	6a 00                	push   $0x0
8010326b:	e8 be ff ff ff       	call   8010322e <cmos_read>
80103270:	83 c4 04             	add    $0x4,%esp
80103273:	8b 55 08             	mov    0x8(%ebp),%edx
80103276:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103278:	6a 02                	push   $0x2
8010327a:	e8 af ff ff ff       	call   8010322e <cmos_read>
8010327f:	83 c4 04             	add    $0x4,%esp
80103282:	8b 55 08             	mov    0x8(%ebp),%edx
80103285:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103288:	6a 04                	push   $0x4
8010328a:	e8 9f ff ff ff       	call   8010322e <cmos_read>
8010328f:	83 c4 04             	add    $0x4,%esp
80103292:	8b 55 08             	mov    0x8(%ebp),%edx
80103295:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103298:	6a 07                	push   $0x7
8010329a:	e8 8f ff ff ff       	call   8010322e <cmos_read>
8010329f:	83 c4 04             	add    $0x4,%esp
801032a2:	8b 55 08             	mov    0x8(%ebp),%edx
801032a5:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801032a8:	6a 08                	push   $0x8
801032aa:	e8 7f ff ff ff       	call   8010322e <cmos_read>
801032af:	83 c4 04             	add    $0x4,%esp
801032b2:	8b 55 08             	mov    0x8(%ebp),%edx
801032b5:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801032b8:	6a 09                	push   $0x9
801032ba:	e8 6f ff ff ff       	call   8010322e <cmos_read>
801032bf:	83 c4 04             	add    $0x4,%esp
801032c2:	8b 55 08             	mov    0x8(%ebp),%edx
801032c5:	89 42 14             	mov    %eax,0x14(%edx)
}
801032c8:	90                   	nop
801032c9:	c9                   	leave  
801032ca:	c3                   	ret    

801032cb <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801032cb:	f3 0f 1e fb          	endbr32 
801032cf:	55                   	push   %ebp
801032d0:	89 e5                	mov    %esp,%ebp
801032d2:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032d5:	6a 0b                	push   $0xb
801032d7:	e8 52 ff ff ff       	call   8010322e <cmos_read>
801032dc:	83 c4 04             	add    $0x4,%esp
801032df:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801032e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e5:	83 e0 04             	and    $0x4,%eax
801032e8:	85 c0                	test   %eax,%eax
801032ea:	0f 94 c0             	sete   %al
801032ed:	0f b6 c0             	movzbl %al,%eax
801032f0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801032f3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032f6:	50                   	push   %eax
801032f7:	e8 66 ff ff ff       	call   80103262 <fill_rtcdate>
801032fc:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801032ff:	6a 0a                	push   $0xa
80103301:	e8 28 ff ff ff       	call   8010322e <cmos_read>
80103306:	83 c4 04             	add    $0x4,%esp
80103309:	25 80 00 00 00       	and    $0x80,%eax
8010330e:	85 c0                	test   %eax,%eax
80103310:	75 27                	jne    80103339 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80103312:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103315:	50                   	push   %eax
80103316:	e8 47 ff ff ff       	call   80103262 <fill_rtcdate>
8010331b:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010331e:	83 ec 04             	sub    $0x4,%esp
80103321:	6a 18                	push   $0x18
80103323:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103326:	50                   	push   %eax
80103327:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010332a:	50                   	push   %eax
8010332b:	e8 87 1d 00 00       	call   801050b7 <memcmp>
80103330:	83 c4 10             	add    $0x10,%esp
80103333:	85 c0                	test   %eax,%eax
80103335:	74 05                	je     8010333c <cmostime+0x71>
80103337:	eb ba                	jmp    801032f3 <cmostime+0x28>
        continue;
80103339:	90                   	nop
    fill_rtcdate(&t1);
8010333a:	eb b7                	jmp    801032f3 <cmostime+0x28>
      break;
8010333c:	90                   	nop
  }

  // convert
  if(bcd) {
8010333d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103341:	0f 84 b4 00 00 00    	je     801033fb <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103347:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010334a:	c1 e8 04             	shr    $0x4,%eax
8010334d:	89 c2                	mov    %eax,%edx
8010334f:	89 d0                	mov    %edx,%eax
80103351:	c1 e0 02             	shl    $0x2,%eax
80103354:	01 d0                	add    %edx,%eax
80103356:	01 c0                	add    %eax,%eax
80103358:	89 c2                	mov    %eax,%edx
8010335a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010335d:	83 e0 0f             	and    $0xf,%eax
80103360:	01 d0                	add    %edx,%eax
80103362:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103365:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103368:	c1 e8 04             	shr    $0x4,%eax
8010336b:	89 c2                	mov    %eax,%edx
8010336d:	89 d0                	mov    %edx,%eax
8010336f:	c1 e0 02             	shl    $0x2,%eax
80103372:	01 d0                	add    %edx,%eax
80103374:	01 c0                	add    %eax,%eax
80103376:	89 c2                	mov    %eax,%edx
80103378:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010337b:	83 e0 0f             	and    $0xf,%eax
8010337e:	01 d0                	add    %edx,%eax
80103380:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103383:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103386:	c1 e8 04             	shr    $0x4,%eax
80103389:	89 c2                	mov    %eax,%edx
8010338b:	89 d0                	mov    %edx,%eax
8010338d:	c1 e0 02             	shl    $0x2,%eax
80103390:	01 d0                	add    %edx,%eax
80103392:	01 c0                	add    %eax,%eax
80103394:	89 c2                	mov    %eax,%edx
80103396:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103399:	83 e0 0f             	and    $0xf,%eax
8010339c:	01 d0                	add    %edx,%eax
8010339e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801033a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033a4:	c1 e8 04             	shr    $0x4,%eax
801033a7:	89 c2                	mov    %eax,%edx
801033a9:	89 d0                	mov    %edx,%eax
801033ab:	c1 e0 02             	shl    $0x2,%eax
801033ae:	01 d0                	add    %edx,%eax
801033b0:	01 c0                	add    %eax,%eax
801033b2:	89 c2                	mov    %eax,%edx
801033b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033b7:	83 e0 0f             	and    $0xf,%eax
801033ba:	01 d0                	add    %edx,%eax
801033bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801033bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033c2:	c1 e8 04             	shr    $0x4,%eax
801033c5:	89 c2                	mov    %eax,%edx
801033c7:	89 d0                	mov    %edx,%eax
801033c9:	c1 e0 02             	shl    $0x2,%eax
801033cc:	01 d0                	add    %edx,%eax
801033ce:	01 c0                	add    %eax,%eax
801033d0:	89 c2                	mov    %eax,%edx
801033d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033d5:	83 e0 0f             	and    $0xf,%eax
801033d8:	01 d0                	add    %edx,%eax
801033da:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801033dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e0:	c1 e8 04             	shr    $0x4,%eax
801033e3:	89 c2                	mov    %eax,%edx
801033e5:	89 d0                	mov    %edx,%eax
801033e7:	c1 e0 02             	shl    $0x2,%eax
801033ea:	01 d0                	add    %edx,%eax
801033ec:	01 c0                	add    %eax,%eax
801033ee:	89 c2                	mov    %eax,%edx
801033f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f3:	83 e0 0f             	and    $0xf,%eax
801033f6:	01 d0                	add    %edx,%eax
801033f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801033fb:	8b 45 08             	mov    0x8(%ebp),%eax
801033fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103401:	89 10                	mov    %edx,(%eax)
80103403:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103406:	89 50 04             	mov    %edx,0x4(%eax)
80103409:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010340c:	89 50 08             	mov    %edx,0x8(%eax)
8010340f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103412:	89 50 0c             	mov    %edx,0xc(%eax)
80103415:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103418:	89 50 10             	mov    %edx,0x10(%eax)
8010341b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010341e:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103421:	8b 45 08             	mov    0x8(%ebp),%eax
80103424:	8b 40 14             	mov    0x14(%eax),%eax
80103427:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010342d:	8b 45 08             	mov    0x8(%ebp),%eax
80103430:	89 50 14             	mov    %edx,0x14(%eax)
}
80103433:	90                   	nop
80103434:	c9                   	leave  
80103435:	c3                   	ret    

80103436 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103436:	f3 0f 1e fb          	endbr32 
8010343a:	55                   	push   %ebp
8010343b:	89 e5                	mov    %esp,%ebp
8010343d:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103440:	83 ec 08             	sub    $0x8,%esp
80103443:	68 b5 a9 10 80       	push   $0x8010a9b5
80103448:	68 60 84 11 80       	push   $0x80118460
8010344d:	e8 45 19 00 00       	call   80104d97 <initlock>
80103452:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103455:	83 ec 08             	sub    $0x8,%esp
80103458:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010345b:	50                   	push   %eax
8010345c:	ff 75 08             	pushl  0x8(%ebp)
8010345f:	e8 c8 df ff ff       	call   8010142c <readsb>
80103464:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346a:	a3 94 84 11 80       	mov    %eax,0x80118494
  log.size = sb.nlog;
8010346f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103472:	a3 98 84 11 80       	mov    %eax,0x80118498
  log.dev = dev;
80103477:	8b 45 08             	mov    0x8(%ebp),%eax
8010347a:	a3 a4 84 11 80       	mov    %eax,0x801184a4
  recover_from_log();
8010347f:	e8 bf 01 00 00       	call   80103643 <recover_from_log>
}
80103484:	90                   	nop
80103485:	c9                   	leave  
80103486:	c3                   	ret    

80103487 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103487:	f3 0f 1e fb          	endbr32 
8010348b:	55                   	push   %ebp
8010348c:	89 e5                	mov    %esp,%ebp
8010348e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103498:	e9 95 00 00 00       	jmp    80103532 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010349d:	8b 15 94 84 11 80    	mov    0x80118494,%edx
801034a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034a6:	01 d0                	add    %edx,%eax
801034a8:	83 c0 01             	add    $0x1,%eax
801034ab:	89 c2                	mov    %eax,%edx
801034ad:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801034b2:	83 ec 08             	sub    $0x8,%esp
801034b5:	52                   	push   %edx
801034b6:	50                   	push   %eax
801034b7:	e8 4d cd ff ff       	call   80100209 <bread>
801034bc:	83 c4 10             	add    $0x10,%esp
801034bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034c5:	83 c0 10             	add    $0x10,%eax
801034c8:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
801034cf:	89 c2                	mov    %eax,%edx
801034d1:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801034d6:	83 ec 08             	sub    $0x8,%esp
801034d9:	52                   	push   %edx
801034da:	50                   	push   %eax
801034db:	e8 29 cd ff ff       	call   80100209 <bread>
801034e0:	83 c4 10             	add    $0x10,%esp
801034e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034e9:	8d 50 5c             	lea    0x5c(%eax),%edx
801034ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ef:	83 c0 5c             	add    $0x5c,%eax
801034f2:	83 ec 04             	sub    $0x4,%esp
801034f5:	68 00 02 00 00       	push   $0x200
801034fa:	52                   	push   %edx
801034fb:	50                   	push   %eax
801034fc:	e8 12 1c 00 00       	call   80105113 <memmove>
80103501:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103504:	83 ec 0c             	sub    $0xc,%esp
80103507:	ff 75 ec             	pushl  -0x14(%ebp)
8010350a:	e8 37 cd ff ff       	call   80100246 <bwrite>
8010350f:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103512:	83 ec 0c             	sub    $0xc,%esp
80103515:	ff 75 f0             	pushl  -0x10(%ebp)
80103518:	e8 76 cd ff ff       	call   80100293 <brelse>
8010351d:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103520:	83 ec 0c             	sub    $0xc,%esp
80103523:	ff 75 ec             	pushl  -0x14(%ebp)
80103526:	e8 68 cd ff ff       	call   80100293 <brelse>
8010352b:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010352e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103532:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103537:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010353a:	0f 8c 5d ff ff ff    	jl     8010349d <install_trans+0x16>
  }
}
80103540:	90                   	nop
80103541:	90                   	nop
80103542:	c9                   	leave  
80103543:	c3                   	ret    

80103544 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103544:	f3 0f 1e fb          	endbr32 
80103548:	55                   	push   %ebp
80103549:	89 e5                	mov    %esp,%ebp
8010354b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010354e:	a1 94 84 11 80       	mov    0x80118494,%eax
80103553:	89 c2                	mov    %eax,%edx
80103555:	a1 a4 84 11 80       	mov    0x801184a4,%eax
8010355a:	83 ec 08             	sub    $0x8,%esp
8010355d:	52                   	push   %edx
8010355e:	50                   	push   %eax
8010355f:	e8 a5 cc ff ff       	call   80100209 <bread>
80103564:	83 c4 10             	add    $0x10,%esp
80103567:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010356a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356d:	83 c0 5c             	add    $0x5c,%eax
80103570:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103573:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103576:	8b 00                	mov    (%eax),%eax
80103578:	a3 a8 84 11 80       	mov    %eax,0x801184a8
  for (i = 0; i < log.lh.n; i++) {
8010357d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103584:	eb 1b                	jmp    801035a1 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103589:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010358c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103590:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103593:	83 c2 10             	add    $0x10,%edx
80103596:	89 04 95 6c 84 11 80 	mov    %eax,-0x7fee7b94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010359d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035a1:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801035a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035a9:	7c db                	jl     80103586 <read_head+0x42>
  }
  brelse(buf);
801035ab:	83 ec 0c             	sub    $0xc,%esp
801035ae:	ff 75 f0             	pushl  -0x10(%ebp)
801035b1:	e8 dd cc ff ff       	call   80100293 <brelse>
801035b6:	83 c4 10             	add    $0x10,%esp
}
801035b9:	90                   	nop
801035ba:	c9                   	leave  
801035bb:	c3                   	ret    

801035bc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801035bc:	f3 0f 1e fb          	endbr32 
801035c0:	55                   	push   %ebp
801035c1:	89 e5                	mov    %esp,%ebp
801035c3:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035c6:	a1 94 84 11 80       	mov    0x80118494,%eax
801035cb:	89 c2                	mov    %eax,%edx
801035cd:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801035d2:	83 ec 08             	sub    $0x8,%esp
801035d5:	52                   	push   %edx
801035d6:	50                   	push   %eax
801035d7:	e8 2d cc ff ff       	call   80100209 <bread>
801035dc:	83 c4 10             	add    $0x10,%esp
801035df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801035e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035e5:	83 c0 5c             	add    $0x5c,%eax
801035e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801035eb:	8b 15 a8 84 11 80    	mov    0x801184a8,%edx
801035f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035f4:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801035f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035fd:	eb 1b                	jmp    8010361a <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801035ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103602:	83 c0 10             	add    $0x10,%eax
80103605:	8b 0c 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%ecx
8010360c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010360f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103612:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103616:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010361a:	a1 a8 84 11 80       	mov    0x801184a8,%eax
8010361f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103622:	7c db                	jl     801035ff <write_head+0x43>
  }
  bwrite(buf);
80103624:	83 ec 0c             	sub    $0xc,%esp
80103627:	ff 75 f0             	pushl  -0x10(%ebp)
8010362a:	e8 17 cc ff ff       	call   80100246 <bwrite>
8010362f:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103632:	83 ec 0c             	sub    $0xc,%esp
80103635:	ff 75 f0             	pushl  -0x10(%ebp)
80103638:	e8 56 cc ff ff       	call   80100293 <brelse>
8010363d:	83 c4 10             	add    $0x10,%esp
}
80103640:	90                   	nop
80103641:	c9                   	leave  
80103642:	c3                   	ret    

80103643 <recover_from_log>:

static void
recover_from_log(void)
{
80103643:	f3 0f 1e fb          	endbr32 
80103647:	55                   	push   %ebp
80103648:	89 e5                	mov    %esp,%ebp
8010364a:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010364d:	e8 f2 fe ff ff       	call   80103544 <read_head>
  install_trans(); // if committed, copy from log to disk
80103652:	e8 30 fe ff ff       	call   80103487 <install_trans>
  log.lh.n = 0;
80103657:	c7 05 a8 84 11 80 00 	movl   $0x0,0x801184a8
8010365e:	00 00 00 
  write_head(); // clear the log
80103661:	e8 56 ff ff ff       	call   801035bc <write_head>
}
80103666:	90                   	nop
80103667:	c9                   	leave  
80103668:	c3                   	ret    

80103669 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103669:	f3 0f 1e fb          	endbr32 
8010366d:	55                   	push   %ebp
8010366e:	89 e5                	mov    %esp,%ebp
80103670:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103673:	83 ec 0c             	sub    $0xc,%esp
80103676:	68 60 84 11 80       	push   $0x80118460
8010367b:	e8 3d 17 00 00       	call   80104dbd <acquire>
80103680:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103683:	a1 a0 84 11 80       	mov    0x801184a0,%eax
80103688:	85 c0                	test   %eax,%eax
8010368a:	74 17                	je     801036a3 <begin_op+0x3a>
      sleep(&log, &log.lock);
8010368c:	83 ec 08             	sub    $0x8,%esp
8010368f:	68 60 84 11 80       	push   $0x80118460
80103694:	68 60 84 11 80       	push   $0x80118460
80103699:	e8 dc 12 00 00       	call   8010497a <sleep>
8010369e:	83 c4 10             	add    $0x10,%esp
801036a1:	eb e0                	jmp    80103683 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801036a3:	8b 0d a8 84 11 80    	mov    0x801184a8,%ecx
801036a9:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801036ae:	8d 50 01             	lea    0x1(%eax),%edx
801036b1:	89 d0                	mov    %edx,%eax
801036b3:	c1 e0 02             	shl    $0x2,%eax
801036b6:	01 d0                	add    %edx,%eax
801036b8:	01 c0                	add    %eax,%eax
801036ba:	01 c8                	add    %ecx,%eax
801036bc:	83 f8 1e             	cmp    $0x1e,%eax
801036bf:	7e 17                	jle    801036d8 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801036c1:	83 ec 08             	sub    $0x8,%esp
801036c4:	68 60 84 11 80       	push   $0x80118460
801036c9:	68 60 84 11 80       	push   $0x80118460
801036ce:	e8 a7 12 00 00       	call   8010497a <sleep>
801036d3:	83 c4 10             	add    $0x10,%esp
801036d6:	eb ab                	jmp    80103683 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801036d8:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801036dd:	83 c0 01             	add    $0x1,%eax
801036e0:	a3 9c 84 11 80       	mov    %eax,0x8011849c
      release(&log.lock);
801036e5:	83 ec 0c             	sub    $0xc,%esp
801036e8:	68 60 84 11 80       	push   $0x80118460
801036ed:	e8 3d 17 00 00       	call   80104e2f <release>
801036f2:	83 c4 10             	add    $0x10,%esp
      break;
801036f5:	90                   	nop
    }
  }
}
801036f6:	90                   	nop
801036f7:	c9                   	leave  
801036f8:	c3                   	ret    

801036f9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801036f9:	f3 0f 1e fb          	endbr32 
801036fd:	55                   	push   %ebp
801036fe:	89 e5                	mov    %esp,%ebp
80103700:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010370a:	83 ec 0c             	sub    $0xc,%esp
8010370d:	68 60 84 11 80       	push   $0x80118460
80103712:	e8 a6 16 00 00       	call   80104dbd <acquire>
80103717:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010371a:	a1 9c 84 11 80       	mov    0x8011849c,%eax
8010371f:	83 e8 01             	sub    $0x1,%eax
80103722:	a3 9c 84 11 80       	mov    %eax,0x8011849c
  if(log.committing)
80103727:	a1 a0 84 11 80       	mov    0x801184a0,%eax
8010372c:	85 c0                	test   %eax,%eax
8010372e:	74 0d                	je     8010373d <end_op+0x44>
    panic("log.committing");
80103730:	83 ec 0c             	sub    $0xc,%esp
80103733:	68 b9 a9 10 80       	push   $0x8010a9b9
80103738:	e8 88 ce ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
8010373d:	a1 9c 84 11 80       	mov    0x8011849c,%eax
80103742:	85 c0                	test   %eax,%eax
80103744:	75 13                	jne    80103759 <end_op+0x60>
    do_commit = 1;
80103746:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010374d:	c7 05 a0 84 11 80 01 	movl   $0x1,0x801184a0
80103754:	00 00 00 
80103757:	eb 10                	jmp    80103769 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103759:	83 ec 0c             	sub    $0xc,%esp
8010375c:	68 60 84 11 80       	push   $0x80118460
80103761:	e8 03 13 00 00       	call   80104a69 <wakeup>
80103766:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103769:	83 ec 0c             	sub    $0xc,%esp
8010376c:	68 60 84 11 80       	push   $0x80118460
80103771:	e8 b9 16 00 00       	call   80104e2f <release>
80103776:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103779:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010377d:	74 3f                	je     801037be <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010377f:	e8 fa 00 00 00       	call   8010387e <commit>
    acquire(&log.lock);
80103784:	83 ec 0c             	sub    $0xc,%esp
80103787:	68 60 84 11 80       	push   $0x80118460
8010378c:	e8 2c 16 00 00       	call   80104dbd <acquire>
80103791:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103794:	c7 05 a0 84 11 80 00 	movl   $0x0,0x801184a0
8010379b:	00 00 00 
    wakeup(&log);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 84 11 80       	push   $0x80118460
801037a6:	e8 be 12 00 00       	call   80104a69 <wakeup>
801037ab:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801037ae:	83 ec 0c             	sub    $0xc,%esp
801037b1:	68 60 84 11 80       	push   $0x80118460
801037b6:	e8 74 16 00 00       	call   80104e2f <release>
801037bb:	83 c4 10             	add    $0x10,%esp
  }
}
801037be:	90                   	nop
801037bf:	c9                   	leave  
801037c0:	c3                   	ret    

801037c1 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801037c1:	f3 0f 1e fb          	endbr32 
801037c5:	55                   	push   %ebp
801037c6:	89 e5                	mov    %esp,%ebp
801037c8:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037d2:	e9 95 00 00 00       	jmp    8010386c <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801037d7:	8b 15 94 84 11 80    	mov    0x80118494,%edx
801037dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e0:	01 d0                	add    %edx,%eax
801037e2:	83 c0 01             	add    $0x1,%eax
801037e5:	89 c2                	mov    %eax,%edx
801037e7:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801037ec:	83 ec 08             	sub    $0x8,%esp
801037ef:	52                   	push   %edx
801037f0:	50                   	push   %eax
801037f1:	e8 13 ca ff ff       	call   80100209 <bread>
801037f6:	83 c4 10             	add    $0x10,%esp
801037f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801037fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ff:	83 c0 10             	add    $0x10,%eax
80103802:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
80103809:	89 c2                	mov    %eax,%edx
8010380b:	a1 a4 84 11 80       	mov    0x801184a4,%eax
80103810:	83 ec 08             	sub    $0x8,%esp
80103813:	52                   	push   %edx
80103814:	50                   	push   %eax
80103815:	e8 ef c9 ff ff       	call   80100209 <bread>
8010381a:	83 c4 10             	add    $0x10,%esp
8010381d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103820:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103823:	8d 50 5c             	lea    0x5c(%eax),%edx
80103826:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103829:	83 c0 5c             	add    $0x5c,%eax
8010382c:	83 ec 04             	sub    $0x4,%esp
8010382f:	68 00 02 00 00       	push   $0x200
80103834:	52                   	push   %edx
80103835:	50                   	push   %eax
80103836:	e8 d8 18 00 00       	call   80105113 <memmove>
8010383b:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010383e:	83 ec 0c             	sub    $0xc,%esp
80103841:	ff 75 f0             	pushl  -0x10(%ebp)
80103844:	e8 fd c9 ff ff       	call   80100246 <bwrite>
80103849:	83 c4 10             	add    $0x10,%esp
    brelse(from);
8010384c:	83 ec 0c             	sub    $0xc,%esp
8010384f:	ff 75 ec             	pushl  -0x14(%ebp)
80103852:	e8 3c ca ff ff       	call   80100293 <brelse>
80103857:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010385a:	83 ec 0c             	sub    $0xc,%esp
8010385d:	ff 75 f0             	pushl  -0x10(%ebp)
80103860:	e8 2e ca ff ff       	call   80100293 <brelse>
80103865:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103868:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010386c:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103871:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103874:	0f 8c 5d ff ff ff    	jl     801037d7 <write_log+0x16>
  }
}
8010387a:	90                   	nop
8010387b:	90                   	nop
8010387c:	c9                   	leave  
8010387d:	c3                   	ret    

8010387e <commit>:

static void
commit()
{
8010387e:	f3 0f 1e fb          	endbr32 
80103882:	55                   	push   %ebp
80103883:	89 e5                	mov    %esp,%ebp
80103885:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103888:	a1 a8 84 11 80       	mov    0x801184a8,%eax
8010388d:	85 c0                	test   %eax,%eax
8010388f:	7e 1e                	jle    801038af <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103891:	e8 2b ff ff ff       	call   801037c1 <write_log>
    write_head();    // Write header to disk -- the real commit
80103896:	e8 21 fd ff ff       	call   801035bc <write_head>
    install_trans(); // Now install writes to home locations
8010389b:	e8 e7 fb ff ff       	call   80103487 <install_trans>
    log.lh.n = 0;
801038a0:	c7 05 a8 84 11 80 00 	movl   $0x0,0x801184a8
801038a7:	00 00 00 
    write_head();    // Erase the transaction from the log
801038aa:	e8 0d fd ff ff       	call   801035bc <write_head>
  }
}
801038af:	90                   	nop
801038b0:	c9                   	leave  
801038b1:	c3                   	ret    

801038b2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801038b2:	f3 0f 1e fb          	endbr32 
801038b6:	55                   	push   %ebp
801038b7:	89 e5                	mov    %esp,%ebp
801038b9:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801038bc:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801038c1:	83 f8 1d             	cmp    $0x1d,%eax
801038c4:	7f 12                	jg     801038d8 <log_write+0x26>
801038c6:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801038cb:	8b 15 98 84 11 80    	mov    0x80118498,%edx
801038d1:	83 ea 01             	sub    $0x1,%edx
801038d4:	39 d0                	cmp    %edx,%eax
801038d6:	7c 0d                	jl     801038e5 <log_write+0x33>
    panic("too big a transaction");
801038d8:	83 ec 0c             	sub    $0xc,%esp
801038db:	68 c8 a9 10 80       	push   $0x8010a9c8
801038e0:	e8 e0 cc ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801038e5:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801038ea:	85 c0                	test   %eax,%eax
801038ec:	7f 0d                	jg     801038fb <log_write+0x49>
    panic("log_write outside of trans");
801038ee:	83 ec 0c             	sub    $0xc,%esp
801038f1:	68 de a9 10 80       	push   $0x8010a9de
801038f6:	e8 ca cc ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
801038fb:	83 ec 0c             	sub    $0xc,%esp
801038fe:	68 60 84 11 80       	push   $0x80118460
80103903:	e8 b5 14 00 00       	call   80104dbd <acquire>
80103908:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010390b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103912:	eb 1d                	jmp    80103931 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103917:	83 c0 10             	add    $0x10,%eax
8010391a:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
80103921:	89 c2                	mov    %eax,%edx
80103923:	8b 45 08             	mov    0x8(%ebp),%eax
80103926:	8b 40 08             	mov    0x8(%eax),%eax
80103929:	39 c2                	cmp    %eax,%edx
8010392b:	74 10                	je     8010393d <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
8010392d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103931:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103936:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103939:	7c d9                	jl     80103914 <log_write+0x62>
8010393b:	eb 01                	jmp    8010393e <log_write+0x8c>
      break;
8010393d:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010393e:	8b 45 08             	mov    0x8(%ebp),%eax
80103941:	8b 40 08             	mov    0x8(%eax),%eax
80103944:	89 c2                	mov    %eax,%edx
80103946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103949:	83 c0 10             	add    $0x10,%eax
8010394c:	89 14 85 6c 84 11 80 	mov    %edx,-0x7fee7b94(,%eax,4)
  if (i == log.lh.n)
80103953:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103958:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010395b:	75 0d                	jne    8010396a <log_write+0xb8>
    log.lh.n++;
8010395d:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103962:	83 c0 01             	add    $0x1,%eax
80103965:	a3 a8 84 11 80       	mov    %eax,0x801184a8
  b->flags |= B_DIRTY; // prevent eviction
8010396a:	8b 45 08             	mov    0x8(%ebp),%eax
8010396d:	8b 00                	mov    (%eax),%eax
8010396f:	83 c8 04             	or     $0x4,%eax
80103972:	89 c2                	mov    %eax,%edx
80103974:	8b 45 08             	mov    0x8(%ebp),%eax
80103977:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103979:	83 ec 0c             	sub    $0xc,%esp
8010397c:	68 60 84 11 80       	push   $0x80118460
80103981:	e8 a9 14 00 00       	call   80104e2f <release>
80103986:	83 c4 10             	add    $0x10,%esp
}
80103989:	90                   	nop
8010398a:	c9                   	leave  
8010398b:	c3                   	ret    

8010398c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010398c:	55                   	push   %ebp
8010398d:	89 e5                	mov    %esp,%ebp
8010398f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103992:	8b 55 08             	mov    0x8(%ebp),%edx
80103995:	8b 45 0c             	mov    0xc(%ebp),%eax
80103998:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010399b:	f0 87 02             	lock xchg %eax,(%edx)
8010399e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801039a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801039a4:	c9                   	leave  
801039a5:	c3                   	ret    

801039a6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801039a6:	f3 0f 1e fb          	endbr32 
801039aa:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801039ae:	83 e4 f0             	and    $0xfffffff0,%esp
801039b1:	ff 71 fc             	pushl  -0x4(%ecx)
801039b4:	55                   	push   %ebp
801039b5:	89 e5                	mov    %esp,%ebp
801039b7:	51                   	push   %ecx
801039b8:	83 ec 04             	sub    $0x4,%esp
  graphic_init(); // 화면 출력을 위한 그래픽 시스템
801039bb:	e8 47 4b 00 00       	call   80108507 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator 커널이 사용할 수 있는 물리 메모리의 첫 4MB를 할당할 준비를 합니다.
801039c0:	83 ec 08             	sub    $0x8,%esp
801039c3:	68 00 00 40 80       	push   $0x80400000
801039c8:	68 00 b0 11 80       	push   $0x8011b000
801039cd:	e8 73 f2 ff ff       	call   80102c45 <kinit1>
801039d2:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table // 가상 메모리 주소를 물리 메모리 주소로 변환할 **커널 페이지 테이블(지도)**을 만듭니다.
801039d5:	e8 0a 41 00 00       	call   80107ae4 <kvmalloc>
  mpinit_uefi(); // 다중 코어(멀티프로세서) 환경을 UEFI 방식에 맞게 파악합니다. CPU가 몇 개인지 확인하는 작업이죠.
801039da:	e8 e1 48 00 00       	call   801082c0 <mpinit_uefi>
  lapicinit();     // interrupt controller 키보드나 마우스 등 외부에서 들어오는 신호(인터럽트)를 CPU가 받을 수 있도록 컨트롤러를 켭니다.
801039df:	e8 f0 f5 ff ff       	call   80102fd4 <lapicinit>
  seginit();       // segment descriptors 메모리 보호 구역(세그먼트)을 설정하고, 오류나 시스템 콜이 발생했을 때 어디로 가야 할지(트랩 벡터)를 설정합니다.
801039e4:	e8 82 3b 00 00       	call   8010756b <seginit>
  picinit();    // disable pic
801039e9:	e8 a9 01 00 00       	call   80103b97 <picinit>
  ioapicinit();    // another interrupt controller 키보드나 마우스 등 외부에서 들어오는 신호(인터럽트)를 CPU가 받을 수 있도록 컨트롤러를 켭니다.
801039ee:	e8 65 f1 ff ff       	call   80102b58 <ioapicinit>
  consoleinit();   // console hardware 화면에 글자를 찍고(콘솔), 시리얼 통신을 할 준비를 합니다.
801039f3:	e8 41 d1 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port 화면에 글자를 찍고(콘솔), 시리얼 통신을 할 준비를 합니다.
801039f8:	e8 f7 2e 00 00       	call   801068f4 <uartinit>
  pinit();         // process table 프로세스 장부(프로세스 테이블)를 초기화합니다.
801039fd:	e8 e2 05 00 00       	call   80103fe4 <pinit>
  tvinit();        // trap vectors 메모리 보호 구역(세그먼트)을 설정하고, 오류나 시스템 콜이 발생했을 때 어디로 가야 할지(트랩 벡터)를 설정합니다.
80103a02:	e8 b1 2a 00 00       	call   801064b8 <tvinit>
  binit();         // buffer cache 하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
80103a07:	e8 5a c6 ff ff       	call   80100066 <binit>
  fileinit();      // file table 하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
80103a0c:	e8 f0 d5 ff ff       	call   80101001 <fileinit>
  ideinit();       // disk  하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
80103a11:	e8 e3 ec ff ff       	call   801026f9 <ideinit>
  startothers();   // start other processors 잠들어 있는 나머지 CPU들을 깨웁니다. (자세한 건 아래 2번에서 설명할게요)
80103a16:	e8 92 00 00 00       	call   80103aad <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers() 처음 4MB 이후의 나머지 모든 물리 메모리를 운영체제가 사용할 수 있도록 마저 할당합니다.
80103a1b:	83 ec 08             	sub    $0x8,%esp
80103a1e:	68 00 00 00 a0       	push   $0xa0000000
80103a23:	68 00 00 40 80       	push   $0x80400000
80103a28:	e8 55 f2 ff ff       	call   80102c82 <kinit2>
80103a2d:	83 c4 10             	add    $0x10,%esp
  pci_init(); // 추가된 네트워크 및 하드웨어 장치를 스캔합니다 
80103a30:	e8 45 4d 00 00       	call   8010877a <pci_init>
  arp_scan(); // 추가된 네트워크 및 하드웨어 장치를 스캔합니다.
80103a35:	e8 be 5a 00 00       	call   801094f8 <arp_scan>
  //i8254_recv();
  userinit();      // first user process 드디어 대망의 첫 번째 유저 프로그램(보통 init 프로세스)을 메모리에 만듭니다.
80103a3a:	e8 9b 07 00 00       	call   801041da <userinit>

  mpmain();        // finish this processor's setup 준비를 마치고 스케줄러를 가동하여 프로세스들을 실행하기 시작합니다.
80103a3f:	e8 1e 00 00 00       	call   80103a62 <mpmain>

80103a44 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void) // 서브 CPU들의 출근 완료 보고
{
80103a44:	f3 0f 1e fb          	endbr32 
80103a48:	55                   	push   %ebp
80103a49:	89 e5                	mov    %esp,%ebp
80103a4b:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103a4e:	e8 ad 40 00 00       	call   80107b00 <switchkvm>
  seginit();
80103a53:	e8 13 3b 00 00       	call   8010756b <seginit>
  lapicinit();
80103a58:	e8 77 f5 ff ff       	call   80102fd4 <lapicinit>
  mpmain();
80103a5d:	e8 00 00 00 00       	call   80103a62 <mpmain>

80103a62 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void) //서브 CPU들의 출근 완료 보고
{
80103a62:	f3 0f 1e fb          	endbr32 
80103a66:	55                   	push   %ebp
80103a67:	89 e5                	mov    %esp,%ebp
80103a69:	53                   	push   %ebx
80103a6a:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103a6d:	e8 94 05 00 00       	call   80104006 <cpuid>
80103a72:	89 c3                	mov    %eax,%ebx
80103a74:	e8 8d 05 00 00       	call   80104006 <cpuid>
80103a79:	83 ec 04             	sub    $0x4,%esp
80103a7c:	53                   	push   %ebx
80103a7d:	50                   	push   %eax
80103a7e:	68 f9 a9 10 80       	push   $0x8010a9f9
80103a83:	e8 84 c9 ff ff       	call   8010040c <cprintf>
80103a88:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a8b:	e8 a2 2b 00 00       	call   80106632 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103a90:	e8 90 05 00 00       	call   80104025 <mycpu>
80103a95:	05 a0 00 00 00       	add    $0xa0,%eax
80103a9a:	83 ec 08             	sub    $0x8,%esp
80103a9d:	6a 01                	push   $0x1
80103a9f:	50                   	push   %eax
80103aa0:	e8 e7 fe ff ff       	call   8010398c <xchg>
80103aa5:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103aa8:	e8 cc 0c 00 00       	call   80104779 <scheduler>

80103aad <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103aad:	f3 0f 1e fb          	endbr32 
80103ab1:	55                   	push   %ebp
80103ab2:	89 e5                	mov    %esp,%ebp
80103ab4:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103ab7:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103abe:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103ac3:	83 ec 04             	sub    $0x4,%esp
80103ac6:	50                   	push   %eax
80103ac7:	68 18 f5 10 80       	push   $0x8010f518
80103acc:	ff 75 f0             	pushl  -0x10(%ebp)
80103acf:	e8 3f 16 00 00       	call   80105113 <memmove>
80103ad4:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103ad7:	c7 45 f4 00 ad 11 80 	movl   $0x8011ad00,-0xc(%ebp)
80103ade:	eb 79                	jmp    80103b59 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
80103ae0:	e8 40 05 00 00       	call   80104025 <mycpu>
80103ae5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ae8:	74 67                	je     80103b51 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103aea:	e8 9b f2 ff ff       	call   80102d8a <kalloc>
80103aef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af5:	83 e8 04             	sub    $0x4,%eax
80103af8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103afb:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b01:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b06:	83 e8 08             	sub    $0x8,%eax
80103b09:	c7 00 44 3a 10 80    	movl   $0x80103a44,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b0f:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
80103b14:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b1d:	83 e8 0c             	sub    $0xc,%eax
80103b20:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b25:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2e:	0f b6 00             	movzbl (%eax),%eax
80103b31:	0f b6 c0             	movzbl %al,%eax
80103b34:	83 ec 08             	sub    $0x8,%esp
80103b37:	52                   	push   %edx
80103b38:	50                   	push   %eax
80103b39:	e8 08 f6 ff ff       	call   80103146 <lapicstartap>
80103b3e:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b41:	90                   	nop
80103b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b45:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103b4b:	85 c0                	test   %eax,%eax
80103b4d:	74 f3                	je     80103b42 <startothers+0x95>
80103b4f:	eb 01                	jmp    80103b52 <startothers+0xa5>
      continue;
80103b51:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103b52:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103b59:	a1 c0 af 11 80       	mov    0x8011afc0,%eax
80103b5e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b64:	05 00 ad 11 80       	add    $0x8011ad00,%eax
80103b69:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b6c:	0f 82 6e ff ff ff    	jb     80103ae0 <startothers+0x33>
      ;
  }
}
80103b72:	90                   	nop
80103b73:	90                   	nop
80103b74:	c9                   	leave  
80103b75:	c3                   	ret    

80103b76 <outb>:
{
80103b76:	55                   	push   %ebp
80103b77:	89 e5                	mov    %esp,%ebp
80103b79:	83 ec 08             	sub    $0x8,%esp
80103b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b82:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103b86:	89 d0                	mov    %edx,%eax
80103b88:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b8b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b8f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b93:	ee                   	out    %al,(%dx)
}
80103b94:	90                   	nop
80103b95:	c9                   	leave  
80103b96:	c3                   	ret    

80103b97 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103b97:	f3 0f 1e fb          	endbr32 
80103b9b:	55                   	push   %ebp
80103b9c:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103b9e:	68 ff 00 00 00       	push   $0xff
80103ba3:	6a 21                	push   $0x21
80103ba5:	e8 cc ff ff ff       	call   80103b76 <outb>
80103baa:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103bad:	68 ff 00 00 00       	push   $0xff
80103bb2:	68 a1 00 00 00       	push   $0xa1
80103bb7:	e8 ba ff ff ff       	call   80103b76 <outb>
80103bbc:	83 c4 08             	add    $0x8,%esp
}
80103bbf:	90                   	nop
80103bc0:	c9                   	leave  
80103bc1:	c3                   	ret    

80103bc2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103bc2:	f3 0f 1e fb          	endbr32 
80103bc6:	55                   	push   %ebp
80103bc7:	89 e5                	mov    %esp,%ebp
80103bc9:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103bcc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bd6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bdf:	8b 10                	mov    (%eax),%edx
80103be1:	8b 45 08             	mov    0x8(%ebp),%eax
80103be4:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103be6:	e8 38 d4 ff ff       	call   80101023 <filealloc>
80103beb:	8b 55 08             	mov    0x8(%ebp),%edx
80103bee:	89 02                	mov    %eax,(%edx)
80103bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf3:	8b 00                	mov    (%eax),%eax
80103bf5:	85 c0                	test   %eax,%eax
80103bf7:	0f 84 c8 00 00 00    	je     80103cc5 <pipealloc+0x103>
80103bfd:	e8 21 d4 ff ff       	call   80101023 <filealloc>
80103c02:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c05:	89 02                	mov    %eax,(%edx)
80103c07:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c0a:	8b 00                	mov    (%eax),%eax
80103c0c:	85 c0                	test   %eax,%eax
80103c0e:	0f 84 b1 00 00 00    	je     80103cc5 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c14:	e8 71 f1 ff ff       	call   80102d8a <kalloc>
80103c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c20:	0f 84 a2 00 00 00    	je     80103cc8 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80103c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c29:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c30:	00 00 00 
  p->writeopen = 1;
80103c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c36:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c3d:	00 00 00 
  p->nwrite = 0;
80103c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c43:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103c4a:	00 00 00 
  p->nread = 0;
80103c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c50:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103c57:	00 00 00 
  initlock(&p->lock, "pipe");
80103c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5d:	83 ec 08             	sub    $0x8,%esp
80103c60:	68 0d aa 10 80       	push   $0x8010aa0d
80103c65:	50                   	push   %eax
80103c66:	e8 2c 11 00 00       	call   80104d97 <initlock>
80103c6b:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c71:	8b 00                	mov    (%eax),%eax
80103c73:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103c79:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7c:	8b 00                	mov    (%eax),%eax
80103c7e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103c82:	8b 45 08             	mov    0x8(%ebp),%eax
80103c85:	8b 00                	mov    (%eax),%eax
80103c87:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8e:	8b 00                	mov    (%eax),%eax
80103c90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c93:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103c96:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c99:	8b 00                	mov    (%eax),%eax
80103c9b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ca4:	8b 00                	mov    (%eax),%eax
80103ca6:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103caa:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cad:	8b 00                	mov    (%eax),%eax
80103caf:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cb6:	8b 00                	mov    (%eax),%eax
80103cb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cbb:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103cbe:	b8 00 00 00 00       	mov    $0x0,%eax
80103cc3:	eb 51                	jmp    80103d16 <pipealloc+0x154>
    goto bad;
80103cc5:	90                   	nop
80103cc6:	eb 01                	jmp    80103cc9 <pipealloc+0x107>
    goto bad;
80103cc8:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103cc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ccd:	74 0e                	je     80103cdd <pipealloc+0x11b>
    kfree((char*)p);
80103ccf:	83 ec 0c             	sub    $0xc,%esp
80103cd2:	ff 75 f4             	pushl  -0xc(%ebp)
80103cd5:	e8 12 f0 ff ff       	call   80102cec <kfree>
80103cda:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce0:	8b 00                	mov    (%eax),%eax
80103ce2:	85 c0                	test   %eax,%eax
80103ce4:	74 11                	je     80103cf7 <pipealloc+0x135>
    fileclose(*f0);
80103ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce9:	8b 00                	mov    (%eax),%eax
80103ceb:	83 ec 0c             	sub    $0xc,%esp
80103cee:	50                   	push   %eax
80103cef:	e8 f5 d3 ff ff       	call   801010e9 <fileclose>
80103cf4:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cfa:	8b 00                	mov    (%eax),%eax
80103cfc:	85 c0                	test   %eax,%eax
80103cfe:	74 11                	je     80103d11 <pipealloc+0x14f>
    fileclose(*f1);
80103d00:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d03:	8b 00                	mov    (%eax),%eax
80103d05:	83 ec 0c             	sub    $0xc,%esp
80103d08:	50                   	push   %eax
80103d09:	e8 db d3 ff ff       	call   801010e9 <fileclose>
80103d0e:	83 c4 10             	add    $0x10,%esp
  return -1;
80103d11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d16:	c9                   	leave  
80103d17:	c3                   	ret    

80103d18 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d18:	f3 0f 1e fb          	endbr32 
80103d1c:	55                   	push   %ebp
80103d1d:	89 e5                	mov    %esp,%ebp
80103d1f:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103d22:	8b 45 08             	mov    0x8(%ebp),%eax
80103d25:	83 ec 0c             	sub    $0xc,%esp
80103d28:	50                   	push   %eax
80103d29:	e8 8f 10 00 00       	call   80104dbd <acquire>
80103d2e:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103d31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d35:	74 23                	je     80103d5a <pipeclose+0x42>
    p->writeopen = 0;
80103d37:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3a:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d41:	00 00 00 
    wakeup(&p->nread);
80103d44:	8b 45 08             	mov    0x8(%ebp),%eax
80103d47:	05 34 02 00 00       	add    $0x234,%eax
80103d4c:	83 ec 0c             	sub    $0xc,%esp
80103d4f:	50                   	push   %eax
80103d50:	e8 14 0d 00 00       	call   80104a69 <wakeup>
80103d55:	83 c4 10             	add    $0x10,%esp
80103d58:	eb 21                	jmp    80103d7b <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5d:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103d64:	00 00 00 
    wakeup(&p->nwrite);
80103d67:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6a:	05 38 02 00 00       	add    $0x238,%eax
80103d6f:	83 ec 0c             	sub    $0xc,%esp
80103d72:	50                   	push   %eax
80103d73:	e8 f1 0c 00 00       	call   80104a69 <wakeup>
80103d78:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d7e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103d84:	85 c0                	test   %eax,%eax
80103d86:	75 2c                	jne    80103db4 <pipeclose+0x9c>
80103d88:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103d91:	85 c0                	test   %eax,%eax
80103d93:	75 1f                	jne    80103db4 <pipeclose+0x9c>
    release(&p->lock);
80103d95:	8b 45 08             	mov    0x8(%ebp),%eax
80103d98:	83 ec 0c             	sub    $0xc,%esp
80103d9b:	50                   	push   %eax
80103d9c:	e8 8e 10 00 00       	call   80104e2f <release>
80103da1:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103da4:	83 ec 0c             	sub    $0xc,%esp
80103da7:	ff 75 08             	pushl  0x8(%ebp)
80103daa:	e8 3d ef ff ff       	call   80102cec <kfree>
80103daf:	83 c4 10             	add    $0x10,%esp
80103db2:	eb 10                	jmp    80103dc4 <pipeclose+0xac>
  } else
    release(&p->lock);
80103db4:	8b 45 08             	mov    0x8(%ebp),%eax
80103db7:	83 ec 0c             	sub    $0xc,%esp
80103dba:	50                   	push   %eax
80103dbb:	e8 6f 10 00 00       	call   80104e2f <release>
80103dc0:	83 c4 10             	add    $0x10,%esp
}
80103dc3:	90                   	nop
80103dc4:	90                   	nop
80103dc5:	c9                   	leave  
80103dc6:	c3                   	ret    

80103dc7 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103dc7:	f3 0f 1e fb          	endbr32 
80103dcb:	55                   	push   %ebp
80103dcc:	89 e5                	mov    %esp,%ebp
80103dce:	53                   	push   %ebx
80103dcf:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd5:	83 ec 0c             	sub    $0xc,%esp
80103dd8:	50                   	push   %eax
80103dd9:	e8 df 0f 00 00       	call   80104dbd <acquire>
80103dde:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103de1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103de8:	e9 ad 00 00 00       	jmp    80103e9a <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103ded:	8b 45 08             	mov    0x8(%ebp),%eax
80103df0:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103df6:	85 c0                	test   %eax,%eax
80103df8:	74 0c                	je     80103e06 <pipewrite+0x3f>
80103dfa:	e8 a2 02 00 00       	call   801040a1 <myproc>
80103dff:	8b 40 24             	mov    0x24(%eax),%eax
80103e02:	85 c0                	test   %eax,%eax
80103e04:	74 19                	je     80103e1f <pipewrite+0x58>
        release(&p->lock);
80103e06:	8b 45 08             	mov    0x8(%ebp),%eax
80103e09:	83 ec 0c             	sub    $0xc,%esp
80103e0c:	50                   	push   %eax
80103e0d:	e8 1d 10 00 00       	call   80104e2f <release>
80103e12:	83 c4 10             	add    $0x10,%esp
        return -1;
80103e15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e1a:	e9 a9 00 00 00       	jmp    80103ec8 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e22:	05 34 02 00 00       	add    $0x234,%eax
80103e27:	83 ec 0c             	sub    $0xc,%esp
80103e2a:	50                   	push   %eax
80103e2b:	e8 39 0c 00 00       	call   80104a69 <wakeup>
80103e30:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e33:	8b 45 08             	mov    0x8(%ebp),%eax
80103e36:	8b 55 08             	mov    0x8(%ebp),%edx
80103e39:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e3f:	83 ec 08             	sub    $0x8,%esp
80103e42:	50                   	push   %eax
80103e43:	52                   	push   %edx
80103e44:	e8 31 0b 00 00       	call   8010497a <sleep>
80103e49:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4f:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e55:	8b 45 08             	mov    0x8(%ebp),%eax
80103e58:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e5e:	05 00 02 00 00       	add    $0x200,%eax
80103e63:	39 c2                	cmp    %eax,%edx
80103e65:	74 86                	je     80103ded <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103e67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e6d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103e70:	8b 45 08             	mov    0x8(%ebp),%eax
80103e73:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103e79:	8d 48 01             	lea    0x1(%eax),%ecx
80103e7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103e7f:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103e85:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e8a:	89 c1                	mov    %eax,%ecx
80103e8c:	0f b6 13             	movzbl (%ebx),%edx
80103e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e92:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103e96:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e9d:	3b 45 10             	cmp    0x10(%ebp),%eax
80103ea0:	7c aa                	jl     80103e4c <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea5:	05 34 02 00 00       	add    $0x234,%eax
80103eaa:	83 ec 0c             	sub    $0xc,%esp
80103ead:	50                   	push   %eax
80103eae:	e8 b6 0b 00 00       	call   80104a69 <wakeup>
80103eb3:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb9:	83 ec 0c             	sub    $0xc,%esp
80103ebc:	50                   	push   %eax
80103ebd:	e8 6d 0f 00 00       	call   80104e2f <release>
80103ec2:	83 c4 10             	add    $0x10,%esp
  return n;
80103ec5:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103ec8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ecb:	c9                   	leave  
80103ecc:	c3                   	ret    

80103ecd <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103ecd:	f3 0f 1e fb          	endbr32 
80103ed1:	55                   	push   %ebp
80103ed2:	89 e5                	mov    %esp,%ebp
80103ed4:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80103eda:	83 ec 0c             	sub    $0xc,%esp
80103edd:	50                   	push   %eax
80103ede:	e8 da 0e 00 00       	call   80104dbd <acquire>
80103ee3:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103ee6:	eb 3e                	jmp    80103f26 <piperead+0x59>
    if(myproc()->killed){
80103ee8:	e8 b4 01 00 00       	call   801040a1 <myproc>
80103eed:	8b 40 24             	mov    0x24(%eax),%eax
80103ef0:	85 c0                	test   %eax,%eax
80103ef2:	74 19                	je     80103f0d <piperead+0x40>
      release(&p->lock);
80103ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef7:	83 ec 0c             	sub    $0xc,%esp
80103efa:	50                   	push   %eax
80103efb:	e8 2f 0f 00 00       	call   80104e2f <release>
80103f00:	83 c4 10             	add    $0x10,%esp
      return -1;
80103f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f08:	e9 be 00 00 00       	jmp    80103fcb <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f10:	8b 55 08             	mov    0x8(%ebp),%edx
80103f13:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f19:	83 ec 08             	sub    $0x8,%esp
80103f1c:	50                   	push   %eax
80103f1d:	52                   	push   %edx
80103f1e:	e8 57 0a 00 00       	call   8010497a <sleep>
80103f23:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f26:	8b 45 08             	mov    0x8(%ebp),%eax
80103f29:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f38:	39 c2                	cmp    %eax,%edx
80103f3a:	75 0d                	jne    80103f49 <piperead+0x7c>
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f45:	85 c0                	test   %eax,%eax
80103f47:	75 9f                	jne    80103ee8 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f50:	eb 48                	jmp    80103f9a <piperead+0xcd>
    if(p->nread == p->nwrite)
80103f52:	8b 45 08             	mov    0x8(%ebp),%eax
80103f55:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f64:	39 c2                	cmp    %eax,%edx
80103f66:	74 3c                	je     80103fa4 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f68:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6b:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f71:	8d 48 01             	lea    0x1(%eax),%ecx
80103f74:	8b 55 08             	mov    0x8(%ebp),%edx
80103f77:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103f7d:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f82:	89 c1                	mov    %eax,%ecx
80103f84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f87:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f8a:	01 c2                	add    %eax,%edx
80103f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8f:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103f94:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f96:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9d:	3b 45 10             	cmp    0x10(%ebp),%eax
80103fa0:	7c b0                	jl     80103f52 <piperead+0x85>
80103fa2:	eb 01                	jmp    80103fa5 <piperead+0xd8>
      break;
80103fa4:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa8:	05 38 02 00 00       	add    $0x238,%eax
80103fad:	83 ec 0c             	sub    $0xc,%esp
80103fb0:	50                   	push   %eax
80103fb1:	e8 b3 0a 00 00       	call   80104a69 <wakeup>
80103fb6:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbc:	83 ec 0c             	sub    $0xc,%esp
80103fbf:	50                   	push   %eax
80103fc0:	e8 6a 0e 00 00       	call   80104e2f <release>
80103fc5:	83 c4 10             	add    $0x10,%esp
  return i;
80103fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103fcb:	c9                   	leave  
80103fcc:	c3                   	ret    

80103fcd <readeflags>:
{
80103fcd:	55                   	push   %ebp
80103fce:	89 e5                	mov    %esp,%ebp
80103fd0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fd3:	9c                   	pushf  
80103fd4:	58                   	pop    %eax
80103fd5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103fd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103fdb:	c9                   	leave  
80103fdc:	c3                   	ret    

80103fdd <sti>:
{
80103fdd:	55                   	push   %ebp
80103fde:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103fe0:	fb                   	sti    
}
80103fe1:	90                   	nop
80103fe2:	5d                   	pop    %ebp
80103fe3:	c3                   	ret    

80103fe4 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103fe4:	f3 0f 1e fb          	endbr32 
80103fe8:	55                   	push   %ebp
80103fe9:	89 e5                	mov    %esp,%ebp
80103feb:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103fee:	83 ec 08             	sub    $0x8,%esp
80103ff1:	68 14 aa 10 80       	push   $0x8010aa14
80103ff6:	68 40 85 11 80       	push   $0x80118540
80103ffb:	e8 97 0d 00 00       	call   80104d97 <initlock>
80104000:	83 c4 10             	add    $0x10,%esp
}
80104003:	90                   	nop
80104004:	c9                   	leave  
80104005:	c3                   	ret    

80104006 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104006:	f3 0f 1e fb          	endbr32 
8010400a:	55                   	push   %ebp
8010400b:	89 e5                	mov    %esp,%ebp
8010400d:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104010:	e8 10 00 00 00       	call   80104025 <mycpu>
80104015:	2d 00 ad 11 80       	sub    $0x8011ad00,%eax
8010401a:	c1 f8 04             	sar    $0x4,%eax
8010401d:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104023:	c9                   	leave  
80104024:	c3                   	ret    

80104025 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104025:	f3 0f 1e fb          	endbr32 
80104029:	55                   	push   %ebp
8010402a:	89 e5                	mov    %esp,%ebp
8010402c:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
8010402f:	e8 99 ff ff ff       	call   80103fcd <readeflags>
80104034:	25 00 02 00 00       	and    $0x200,%eax
80104039:	85 c0                	test   %eax,%eax
8010403b:	74 0d                	je     8010404a <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
8010403d:	83 ec 0c             	sub    $0xc,%esp
80104040:	68 1c aa 10 80       	push   $0x8010aa1c
80104045:	e8 7b c5 ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
8010404a:	e8 a8 f0 ff ff       	call   801030f7 <lapicid>
8010404f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104052:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104059:	eb 2d                	jmp    80104088 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104064:	05 00 ad 11 80       	add    $0x8011ad00,%eax
80104069:	0f b6 00             	movzbl (%eax),%eax
8010406c:	0f b6 c0             	movzbl %al,%eax
8010406f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104072:	75 10                	jne    80104084 <mycpu+0x5f>
      return &cpus[i];
80104074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104077:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010407d:	05 00 ad 11 80       	add    $0x8011ad00,%eax
80104082:	eb 1b                	jmp    8010409f <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104084:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104088:	a1 c0 af 11 80       	mov    0x8011afc0,%eax
8010408d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104090:	7c c9                	jl     8010405b <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80104092:	83 ec 0c             	sub    $0xc,%esp
80104095:	68 42 aa 10 80       	push   $0x8010aa42
8010409a:	e8 26 c5 ff ff       	call   801005c5 <panic>
}
8010409f:	c9                   	leave  
801040a0:	c3                   	ret    

801040a1 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801040a1:	f3 0f 1e fb          	endbr32 
801040a5:	55                   	push   %ebp
801040a6:	89 e5                	mov    %esp,%ebp
801040a8:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801040ab:	e8 89 0e 00 00       	call   80104f39 <pushcli>
  c = mycpu();
801040b0:	e8 70 ff ff ff       	call   80104025 <mycpu>
801040b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801040b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bb:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801040c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801040c4:	e8 c1 0e 00 00       	call   80104f8a <popcli>
  return p;
801040c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801040cc:	c9                   	leave  
801040cd:	c3                   	ret    

801040ce <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801040ce:	f3 0f 1e fb          	endbr32 
801040d2:	55                   	push   %ebp
801040d3:	89 e5                	mov    %esp,%ebp
801040d5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801040d8:	83 ec 0c             	sub    $0xc,%esp
801040db:	68 40 85 11 80       	push   $0x80118540
801040e0:	e8 d8 0c 00 00       	call   80104dbd <acquire>
801040e5:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040e8:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801040ef:	eb 0e                	jmp    801040ff <allocproc+0x31>
    if(p->state == UNUSED){
801040f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f4:	8b 40 0c             	mov    0xc(%eax),%eax
801040f7:	85 c0                	test   %eax,%eax
801040f9:	74 27                	je     80104122 <allocproc+0x54>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040fb:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801040ff:	81 7d f4 74 a4 11 80 	cmpl   $0x8011a474,-0xc(%ebp)
80104106:	72 e9                	jb     801040f1 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80104108:	83 ec 0c             	sub    $0xc,%esp
8010410b:	68 40 85 11 80       	push   $0x80118540
80104110:	e8 1a 0d 00 00       	call   80104e2f <release>
80104115:	83 c4 10             	add    $0x10,%esp
  return 0;
80104118:	b8 00 00 00 00       	mov    $0x0,%eax
8010411d:	e9 b6 00 00 00       	jmp    801041d8 <allocproc+0x10a>
      goto found;
80104122:	90                   	nop
80104123:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412a:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104131:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80104136:	8d 50 01             	lea    0x1(%eax),%edx
80104139:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
8010413f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104142:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80104145:	83 ec 0c             	sub    $0xc,%esp
80104148:	68 40 85 11 80       	push   $0x80118540
8010414d:	e8 dd 0c 00 00       	call   80104e2f <release>
80104152:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104155:	e8 30 ec ff ff       	call   80102d8a <kalloc>
8010415a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010415d:	89 42 08             	mov    %eax,0x8(%edx)
80104160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104163:	8b 40 08             	mov    0x8(%eax),%eax
80104166:	85 c0                	test   %eax,%eax
80104168:	75 11                	jne    8010417b <allocproc+0xad>
    p->state = UNUSED;
8010416a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104174:	b8 00 00 00 00       	mov    $0x0,%eax
80104179:	eb 5d                	jmp    801041d8 <allocproc+0x10a>
  }
  sp = p->kstack + KSTACKSIZE;
8010417b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417e:	8b 40 08             	mov    0x8(%eax),%eax
80104181:	05 00 10 00 00       	add    $0x1000,%eax
80104186:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104189:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010418d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104190:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104193:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104196:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010419a:	ba 72 64 10 80       	mov    $0x80106472,%edx
8010419f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041a2:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801041a4:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801041a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041ae:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801041b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b4:	8b 40 1c             	mov    0x1c(%eax),%eax
801041b7:	83 ec 04             	sub    $0x4,%esp
801041ba:	6a 14                	push   $0x14
801041bc:	6a 00                	push   $0x0
801041be:	50                   	push   %eax
801041bf:	e8 88 0e 00 00       	call   8010504c <memset>
801041c4:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801041c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ca:	8b 40 1c             	mov    0x1c(%eax),%eax
801041cd:	ba 30 49 10 80       	mov    $0x80104930,%edx
801041d2:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801041d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041d8:	c9                   	leave  
801041d9:	c3                   	ret    

801041da <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801041da:	f3 0f 1e fb          	endbr32 
801041de:	55                   	push   %ebp
801041df:	89 e5                	mov    %esp,%ebp
801041e1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801041e4:	e8 e5 fe ff ff       	call   801040ce <allocproc>
801041e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801041ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ef:	a3 a0 00 11 80       	mov    %eax,0x801100a0
  if((p->pgdir = setupkvm()) == 0){
801041f4:	e8 fa 37 00 00       	call   801079f3 <setupkvm>
801041f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fc:	89 42 04             	mov    %eax,0x4(%edx)
801041ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104202:	8b 40 04             	mov    0x4(%eax),%eax
80104205:	85 c0                	test   %eax,%eax
80104207:	75 0d                	jne    80104216 <userinit+0x3c>
    panic("userinit: out of memory?");
80104209:	83 ec 0c             	sub    $0xc,%esp
8010420c:	68 52 aa 10 80       	push   $0x8010aa52
80104211:	e8 af c3 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104216:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010421b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421e:	8b 40 04             	mov    0x4(%eax),%eax
80104221:	83 ec 04             	sub    $0x4,%esp
80104224:	52                   	push   %edx
80104225:	68 ec f4 10 80       	push   $0x8010f4ec
8010422a:	50                   	push   %eax
8010422b:	e8 90 3a 00 00       	call   80107cc0 <inituvm>
80104230:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104236:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010423c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423f:	8b 40 18             	mov    0x18(%eax),%eax
80104242:	83 ec 04             	sub    $0x4,%esp
80104245:	6a 4c                	push   $0x4c
80104247:	6a 00                	push   $0x0
80104249:	50                   	push   %eax
8010424a:	e8 fd 0d 00 00       	call   8010504c <memset>
8010424f:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104255:	8b 40 18             	mov    0x18(%eax),%eax
80104258:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010425e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104261:	8b 40 18             	mov    0x18(%eax),%eax
80104264:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010426a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426d:	8b 50 18             	mov    0x18(%eax),%edx
80104270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104273:	8b 40 18             	mov    0x18(%eax),%eax
80104276:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010427a:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010427e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104281:	8b 50 18             	mov    0x18(%eax),%edx
80104284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104287:	8b 40 18             	mov    0x18(%eax),%eax
8010428a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010428e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104295:	8b 40 18             	mov    0x18(%eax),%eax
80104298:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010429f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a2:	8b 40 18             	mov    0x18(%eax),%eax
801042a5:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801042ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042af:	8b 40 18             	mov    0x18(%eax),%eax
801042b2:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801042b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042bc:	83 c0 6c             	add    $0x6c,%eax
801042bf:	83 ec 04             	sub    $0x4,%esp
801042c2:	6a 10                	push   $0x10
801042c4:	68 6b aa 10 80       	push   $0x8010aa6b
801042c9:	50                   	push   %eax
801042ca:	e8 98 0f 00 00       	call   80105267 <safestrcpy>
801042cf:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801042d2:	83 ec 0c             	sub    $0xc,%esp
801042d5:	68 74 aa 10 80       	push   $0x8010aa74
801042da:	e8 08 e3 ff ff       	call   801025e7 <namei>
801042df:	83 c4 10             	add    $0x10,%esp
801042e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042e5:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801042e8:	83 ec 0c             	sub    $0xc,%esp
801042eb:	68 40 85 11 80       	push   $0x80118540
801042f0:	e8 c8 0a 00 00       	call   80104dbd <acquire>
801042f5:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801042f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104302:	83 ec 0c             	sub    $0xc,%esp
80104305:	68 40 85 11 80       	push   $0x80118540
8010430a:	e8 20 0b 00 00       	call   80104e2f <release>
8010430f:	83 c4 10             	add    $0x10,%esp
}
80104312:	90                   	nop
80104313:	c9                   	leave  
80104314:	c3                   	ret    

80104315 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104315:	f3 0f 1e fb          	endbr32 
80104319:	55                   	push   %ebp
8010431a:	89 e5                	mov    %esp,%ebp
8010431c:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010431f:	e8 7d fd ff ff       	call   801040a1 <myproc>
80104324:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104327:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010432a:	8b 00                	mov    (%eax),%eax
8010432c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010432f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104333:	7e 2e                	jle    80104363 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104335:	8b 55 08             	mov    0x8(%ebp),%edx
80104338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433b:	01 c2                	add    %eax,%edx
8010433d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104340:	8b 40 04             	mov    0x4(%eax),%eax
80104343:	83 ec 04             	sub    $0x4,%esp
80104346:	52                   	push   %edx
80104347:	ff 75 f4             	pushl  -0xc(%ebp)
8010434a:	50                   	push   %eax
8010434b:	e8 b5 3a 00 00       	call   80107e05 <allocuvm>
80104350:	83 c4 10             	add    $0x10,%esp
80104353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104356:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010435a:	75 3b                	jne    80104397 <growproc+0x82>
      return -1;
8010435c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104361:	eb 4f                	jmp    801043b2 <growproc+0x9d>
  } else if(n < 0){
80104363:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104367:	79 2e                	jns    80104397 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104369:	8b 55 08             	mov    0x8(%ebp),%edx
8010436c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436f:	01 c2                	add    %eax,%edx
80104371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104374:	8b 40 04             	mov    0x4(%eax),%eax
80104377:	83 ec 04             	sub    $0x4,%esp
8010437a:	52                   	push   %edx
8010437b:	ff 75 f4             	pushl  -0xc(%ebp)
8010437e:	50                   	push   %eax
8010437f:	e8 8a 3b 00 00       	call   80107f0e <deallocuvm>
80104384:	83 c4 10             	add    $0x10,%esp
80104387:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010438a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010438e:	75 07                	jne    80104397 <growproc+0x82>
      return -1;
80104390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104395:	eb 1b                	jmp    801043b2 <growproc+0x9d>
  }
  curproc->sz = sz;
80104397:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010439a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439d:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010439f:	83 ec 0c             	sub    $0xc,%esp
801043a2:	ff 75 f0             	pushl  -0x10(%ebp)
801043a5:	e8 73 37 00 00       	call   80107b1d <switchuvm>
801043aa:	83 c4 10             	add    $0x10,%esp
  return 0;
801043ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043b2:	c9                   	leave  
801043b3:	c3                   	ret    

801043b4 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801043b4:	f3 0f 1e fb          	endbr32 
801043b8:	55                   	push   %ebp
801043b9:	89 e5                	mov    %esp,%ebp
801043bb:	57                   	push   %edi
801043bc:	56                   	push   %esi
801043bd:	53                   	push   %ebx
801043be:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801043c1:	e8 db fc ff ff       	call   801040a1 <myproc>
801043c6:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801043c9:	e8 00 fd ff ff       	call   801040ce <allocproc>
801043ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
801043d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801043d5:	75 0a                	jne    801043e1 <fork+0x2d>
    return -1;
801043d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043dc:	e9 48 01 00 00       	jmp    80104529 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801043e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043e4:	8b 10                	mov    (%eax),%edx
801043e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043e9:	8b 40 04             	mov    0x4(%eax),%eax
801043ec:	83 ec 08             	sub    $0x8,%esp
801043ef:	52                   	push   %edx
801043f0:	50                   	push   %eax
801043f1:	e8 c2 3c 00 00       	call   801080b8 <copyuvm>
801043f6:	83 c4 10             	add    $0x10,%esp
801043f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801043fc:	89 42 04             	mov    %eax,0x4(%edx)
801043ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104402:	8b 40 04             	mov    0x4(%eax),%eax
80104405:	85 c0                	test   %eax,%eax
80104407:	75 30                	jne    80104439 <fork+0x85>
    kfree(np->kstack);
80104409:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010440c:	8b 40 08             	mov    0x8(%eax),%eax
8010440f:	83 ec 0c             	sub    $0xc,%esp
80104412:	50                   	push   %eax
80104413:	e8 d4 e8 ff ff       	call   80102cec <kfree>
80104418:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010441b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010441e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104425:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104428:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010442f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104434:	e9 f0 00 00 00       	jmp    80104529 <fork+0x175>
  }
  np->sz = curproc->sz;
80104439:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010443c:	8b 10                	mov    (%eax),%edx
8010443e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104441:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104443:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104446:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104449:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010444c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010444f:	8b 48 18             	mov    0x18(%eax),%ecx
80104452:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104455:	8b 40 18             	mov    0x18(%eax),%eax
80104458:	89 c2                	mov    %eax,%edx
8010445a:	89 cb                	mov    %ecx,%ebx
8010445c:	b8 13 00 00 00       	mov    $0x13,%eax
80104461:	89 d7                	mov    %edx,%edi
80104463:	89 de                	mov    %ebx,%esi
80104465:	89 c1                	mov    %eax,%ecx
80104467:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104469:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010446c:	8b 40 18             	mov    0x18(%eax),%eax
8010446f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104476:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010447d:	eb 3b                	jmp    801044ba <fork+0x106>
    if(curproc->ofile[i])
8010447f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104482:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104485:	83 c2 08             	add    $0x8,%edx
80104488:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010448c:	85 c0                	test   %eax,%eax
8010448e:	74 26                	je     801044b6 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104490:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104493:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104496:	83 c2 08             	add    $0x8,%edx
80104499:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010449d:	83 ec 0c             	sub    $0xc,%esp
801044a0:	50                   	push   %eax
801044a1:	e8 ee cb ff ff       	call   80101094 <filedup>
801044a6:	83 c4 10             	add    $0x10,%esp
801044a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044ac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801044af:	83 c1 08             	add    $0x8,%ecx
801044b2:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801044b6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801044ba:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801044be:	7e bf                	jle    8010447f <fork+0xcb>
  np->cwd = idup(curproc->cwd);
801044c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044c3:	8b 40 68             	mov    0x68(%eax),%eax
801044c6:	83 ec 0c             	sub    $0xc,%esp
801044c9:	50                   	push   %eax
801044ca:	e8 6f d5 ff ff       	call   80101a3e <idup>
801044cf:	83 c4 10             	add    $0x10,%esp
801044d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044d5:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801044d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044db:	8d 50 6c             	lea    0x6c(%eax),%edx
801044de:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044e1:	83 c0 6c             	add    $0x6c,%eax
801044e4:	83 ec 04             	sub    $0x4,%esp
801044e7:	6a 10                	push   $0x10
801044e9:	52                   	push   %edx
801044ea:	50                   	push   %eax
801044eb:	e8 77 0d 00 00       	call   80105267 <safestrcpy>
801044f0:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801044f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044f6:	8b 40 10             	mov    0x10(%eax),%eax
801044f9:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801044fc:	83 ec 0c             	sub    $0xc,%esp
801044ff:	68 40 85 11 80       	push   $0x80118540
80104504:	e8 b4 08 00 00       	call   80104dbd <acquire>
80104509:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010450c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010450f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104516:	83 ec 0c             	sub    $0xc,%esp
80104519:	68 40 85 11 80       	push   $0x80118540
8010451e:	e8 0c 09 00 00       	call   80104e2f <release>
80104523:	83 c4 10             	add    $0x10,%esp

  return pid;
80104526:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104529:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010452c:	5b                   	pop    %ebx
8010452d:	5e                   	pop    %esi
8010452e:	5f                   	pop    %edi
8010452f:	5d                   	pop    %ebp
80104530:	c3                   	ret    

80104531 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104531:	f3 0f 1e fb          	endbr32 
80104535:	55                   	push   %ebp
80104536:	89 e5                	mov    %esp,%ebp
80104538:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010453b:	e8 61 fb ff ff       	call   801040a1 <myproc>
80104540:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104543:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104548:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010454b:	75 0d                	jne    8010455a <exit+0x29>
    panic("init exiting");
8010454d:	83 ec 0c             	sub    $0xc,%esp
80104550:	68 76 aa 10 80       	push   $0x8010aa76
80104555:	e8 6b c0 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010455a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104561:	eb 3f                	jmp    801045a2 <exit+0x71>
    if(curproc->ofile[fd]){
80104563:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104566:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104569:	83 c2 08             	add    $0x8,%edx
8010456c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104570:	85 c0                	test   %eax,%eax
80104572:	74 2a                	je     8010459e <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104574:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104577:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010457a:	83 c2 08             	add    $0x8,%edx
8010457d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104581:	83 ec 0c             	sub    $0xc,%esp
80104584:	50                   	push   %eax
80104585:	e8 5f cb ff ff       	call   801010e9 <fileclose>
8010458a:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010458d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104590:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104593:	83 c2 08             	add    $0x8,%edx
80104596:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010459d:	00 
  for(fd = 0; fd < NOFILE; fd++){
8010459e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801045a2:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801045a6:	7e bb                	jle    80104563 <exit+0x32>
    }
  }

  begin_op();
801045a8:	e8 bc f0 ff ff       	call   80103669 <begin_op>
  iput(curproc->cwd);
801045ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045b0:	8b 40 68             	mov    0x68(%eax),%eax
801045b3:	83 ec 0c             	sub    $0xc,%esp
801045b6:	50                   	push   %eax
801045b7:	e8 29 d6 ff ff       	call   80101be5 <iput>
801045bc:	83 c4 10             	add    $0x10,%esp
  end_op();
801045bf:	e8 35 f1 ff ff       	call   801036f9 <end_op>
  curproc->cwd = 0;
801045c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045c7:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801045ce:	83 ec 0c             	sub    $0xc,%esp
801045d1:	68 40 85 11 80       	push   $0x80118540
801045d6:	e8 e2 07 00 00       	call   80104dbd <acquire>
801045db:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801045de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045e1:	8b 40 14             	mov    0x14(%eax),%eax
801045e4:	83 ec 0c             	sub    $0xc,%esp
801045e7:	50                   	push   %eax
801045e8:	e8 38 04 00 00       	call   80104a25 <wakeup1>
801045ed:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045f0:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801045f7:	eb 37                	jmp    80104630 <exit+0xff>
    if(p->parent == curproc){
801045f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fc:	8b 40 14             	mov    0x14(%eax),%eax
801045ff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104602:	75 28                	jne    8010462c <exit+0xfb>
      p->parent = initproc;
80104604:	8b 15 a0 00 11 80    	mov    0x801100a0,%edx
8010460a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460d:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	8b 40 0c             	mov    0xc(%eax),%eax
80104616:	83 f8 05             	cmp    $0x5,%eax
80104619:	75 11                	jne    8010462c <exit+0xfb>
        wakeup1(initproc);
8010461b:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104620:	83 ec 0c             	sub    $0xc,%esp
80104623:	50                   	push   %eax
80104624:	e8 fc 03 00 00       	call   80104a25 <wakeup1>
80104629:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010462c:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104630:	81 7d f4 74 a4 11 80 	cmpl   $0x8011a474,-0xc(%ebp)
80104637:	72 c0                	jb     801045f9 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104639:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010463c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104643:	e8 ed 01 00 00       	call   80104835 <sched>
  panic("zombie exit");
80104648:	83 ec 0c             	sub    $0xc,%esp
8010464b:	68 83 aa 10 80       	push   $0x8010aa83
80104650:	e8 70 bf ff ff       	call   801005c5 <panic>

80104655 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104655:	f3 0f 1e fb          	endbr32 
80104659:	55                   	push   %ebp
8010465a:	89 e5                	mov    %esp,%ebp
8010465c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010465f:	e8 3d fa ff ff       	call   801040a1 <myproc>
80104664:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104667:	83 ec 0c             	sub    $0xc,%esp
8010466a:	68 40 85 11 80       	push   $0x80118540
8010466f:	e8 49 07 00 00       	call   80104dbd <acquire>
80104674:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104677:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010467e:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104685:	e9 a1 00 00 00       	jmp    8010472b <wait+0xd6>
      if(p->parent != curproc)
8010468a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468d:	8b 40 14             	mov    0x14(%eax),%eax
80104690:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104693:	0f 85 8d 00 00 00    	jne    80104726 <wait+0xd1>
        continue;
      havekids = 1;
80104699:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801046a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a3:	8b 40 0c             	mov    0xc(%eax),%eax
801046a6:	83 f8 05             	cmp    $0x5,%eax
801046a9:	75 7c                	jne    80104727 <wait+0xd2>
        // Found one.
        pid = p->pid;
801046ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ae:	8b 40 10             	mov    0x10(%eax),%eax
801046b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b7:	8b 40 08             	mov    0x8(%eax),%eax
801046ba:	83 ec 0c             	sub    $0xc,%esp
801046bd:	50                   	push   %eax
801046be:	e8 29 e6 ff ff       	call   80102cec <kfree>
801046c3:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801046c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d3:	8b 40 04             	mov    0x4(%eax),%eax
801046d6:	83 ec 0c             	sub    $0xc,%esp
801046d9:	50                   	push   %eax
801046da:	e8 f7 38 00 00       	call   80107fd6 <freevm>
801046df:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
801046e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e5:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801046ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ef:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801046f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f9:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801046fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104700:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104711:	83 ec 0c             	sub    $0xc,%esp
80104714:	68 40 85 11 80       	push   $0x80118540
80104719:	e8 11 07 00 00       	call   80104e2f <release>
8010471e:	83 c4 10             	add    $0x10,%esp
        return pid;
80104721:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104724:	eb 51                	jmp    80104777 <wait+0x122>
        continue;
80104726:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104727:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010472b:	81 7d f4 74 a4 11 80 	cmpl   $0x8011a474,-0xc(%ebp)
80104732:	0f 82 52 ff ff ff    	jb     8010468a <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104738:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010473c:	74 0a                	je     80104748 <wait+0xf3>
8010473e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104741:	8b 40 24             	mov    0x24(%eax),%eax
80104744:	85 c0                	test   %eax,%eax
80104746:	74 17                	je     8010475f <wait+0x10a>
      release(&ptable.lock);
80104748:	83 ec 0c             	sub    $0xc,%esp
8010474b:	68 40 85 11 80       	push   $0x80118540
80104750:	e8 da 06 00 00       	call   80104e2f <release>
80104755:	83 c4 10             	add    $0x10,%esp
      return -1;
80104758:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010475d:	eb 18                	jmp    80104777 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010475f:	83 ec 08             	sub    $0x8,%esp
80104762:	68 40 85 11 80       	push   $0x80118540
80104767:	ff 75 ec             	pushl  -0x14(%ebp)
8010476a:	e8 0b 02 00 00       	call   8010497a <sleep>
8010476f:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104772:	e9 00 ff ff ff       	jmp    80104677 <wait+0x22>
  }
}
80104777:	c9                   	leave  
80104778:	c3                   	ret    

80104779 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104779:	f3 0f 1e fb          	endbr32 
8010477d:	55                   	push   %ebp
8010477e:	89 e5                	mov    %esp,%ebp
80104780:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104783:	e8 9d f8 ff ff       	call   80104025 <mycpu>
80104788:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
8010478b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010478e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104795:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104798:	e8 40 f8 ff ff       	call   80103fdd <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010479d:	83 ec 0c             	sub    $0xc,%esp
801047a0:	68 40 85 11 80       	push   $0x80118540
801047a5:	e8 13 06 00 00       	call   80104dbd <acquire>
801047aa:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ad:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801047b4:	eb 61                	jmp    80104817 <scheduler+0x9e>
      if(p->state != RUNNABLE)
801047b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047b9:	8b 40 0c             	mov    0xc(%eax),%eax
801047bc:	83 f8 03             	cmp    $0x3,%eax
801047bf:	75 51                	jne    80104812 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
801047c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047c7:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
801047cd:	83 ec 0c             	sub    $0xc,%esp
801047d0:	ff 75 f4             	pushl  -0xc(%ebp)
801047d3:	e8 45 33 00 00       	call   80107b1d <switchuvm>
801047d8:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801047db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047de:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801047e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e8:	8b 40 1c             	mov    0x1c(%eax),%eax
801047eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047ee:	83 c2 04             	add    $0x4,%edx
801047f1:	83 ec 08             	sub    $0x8,%esp
801047f4:	50                   	push   %eax
801047f5:	52                   	push   %edx
801047f6:	e8 e5 0a 00 00       	call   801052e0 <swtch>
801047fb:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801047fe:	e8 fd 32 00 00       	call   80107b00 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104803:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104806:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010480d:	00 00 00 
80104810:	eb 01                	jmp    80104813 <scheduler+0x9a>
        continue;
80104812:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104813:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104817:	81 7d f4 74 a4 11 80 	cmpl   $0x8011a474,-0xc(%ebp)
8010481e:	72 96                	jb     801047b6 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104820:	83 ec 0c             	sub    $0xc,%esp
80104823:	68 40 85 11 80       	push   $0x80118540
80104828:	e8 02 06 00 00       	call   80104e2f <release>
8010482d:	83 c4 10             	add    $0x10,%esp
    sti();
80104830:	e9 63 ff ff ff       	jmp    80104798 <scheduler+0x1f>

80104835 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104835:	f3 0f 1e fb          	endbr32 
80104839:	55                   	push   %ebp
8010483a:	89 e5                	mov    %esp,%ebp
8010483c:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
8010483f:	e8 5d f8 ff ff       	call   801040a1 <myproc>
80104844:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104847:	83 ec 0c             	sub    $0xc,%esp
8010484a:	68 40 85 11 80       	push   $0x80118540
8010484f:	e8 b0 06 00 00       	call   80104f04 <holding>
80104854:	83 c4 10             	add    $0x10,%esp
80104857:	85 c0                	test   %eax,%eax
80104859:	75 0d                	jne    80104868 <sched+0x33>
    panic("sched ptable.lock");
8010485b:	83 ec 0c             	sub    $0xc,%esp
8010485e:	68 8f aa 10 80       	push   $0x8010aa8f
80104863:	e8 5d bd ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104868:	e8 b8 f7 ff ff       	call   80104025 <mycpu>
8010486d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104873:	83 f8 01             	cmp    $0x1,%eax
80104876:	74 0d                	je     80104885 <sched+0x50>
    panic("sched locks");
80104878:	83 ec 0c             	sub    $0xc,%esp
8010487b:	68 a1 aa 10 80       	push   $0x8010aaa1
80104880:	e8 40 bd ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104888:	8b 40 0c             	mov    0xc(%eax),%eax
8010488b:	83 f8 04             	cmp    $0x4,%eax
8010488e:	75 0d                	jne    8010489d <sched+0x68>
    panic("sched running");
80104890:	83 ec 0c             	sub    $0xc,%esp
80104893:	68 ad aa 10 80       	push   $0x8010aaad
80104898:	e8 28 bd ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
8010489d:	e8 2b f7 ff ff       	call   80103fcd <readeflags>
801048a2:	25 00 02 00 00       	and    $0x200,%eax
801048a7:	85 c0                	test   %eax,%eax
801048a9:	74 0d                	je     801048b8 <sched+0x83>
    panic("sched interruptible");
801048ab:	83 ec 0c             	sub    $0xc,%esp
801048ae:	68 bb aa 10 80       	push   $0x8010aabb
801048b3:	e8 0d bd ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
801048b8:	e8 68 f7 ff ff       	call   80104025 <mycpu>
801048bd:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801048c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801048c6:	e8 5a f7 ff ff       	call   80104025 <mycpu>
801048cb:	8b 40 04             	mov    0x4(%eax),%eax
801048ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048d1:	83 c2 1c             	add    $0x1c,%edx
801048d4:	83 ec 08             	sub    $0x8,%esp
801048d7:	50                   	push   %eax
801048d8:	52                   	push   %edx
801048d9:	e8 02 0a 00 00       	call   801052e0 <swtch>
801048de:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801048e1:	e8 3f f7 ff ff       	call   80104025 <mycpu>
801048e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048e9:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801048ef:	90                   	nop
801048f0:	c9                   	leave  
801048f1:	c3                   	ret    

801048f2 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801048f2:	f3 0f 1e fb          	endbr32 
801048f6:	55                   	push   %ebp
801048f7:	89 e5                	mov    %esp,%ebp
801048f9:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801048fc:	83 ec 0c             	sub    $0xc,%esp
801048ff:	68 40 85 11 80       	push   $0x80118540
80104904:	e8 b4 04 00 00       	call   80104dbd <acquire>
80104909:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010490c:	e8 90 f7 ff ff       	call   801040a1 <myproc>
80104911:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104918:	e8 18 ff ff ff       	call   80104835 <sched>
  release(&ptable.lock);
8010491d:	83 ec 0c             	sub    $0xc,%esp
80104920:	68 40 85 11 80       	push   $0x80118540
80104925:	e8 05 05 00 00       	call   80104e2f <release>
8010492a:	83 c4 10             	add    $0x10,%esp
}
8010492d:	90                   	nop
8010492e:	c9                   	leave  
8010492f:	c3                   	ret    

80104930 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104930:	f3 0f 1e fb          	endbr32 
80104934:	55                   	push   %ebp
80104935:	89 e5                	mov    %esp,%ebp
80104937:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010493a:	83 ec 0c             	sub    $0xc,%esp
8010493d:	68 40 85 11 80       	push   $0x80118540
80104942:	e8 e8 04 00 00       	call   80104e2f <release>
80104947:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010494a:	a1 04 f0 10 80       	mov    0x8010f004,%eax
8010494f:	85 c0                	test   %eax,%eax
80104951:	74 24                	je     80104977 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104953:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010495a:	00 00 00 
    iinit(ROOTDEV);
8010495d:	83 ec 0c             	sub    $0xc,%esp
80104960:	6a 01                	push   $0x1
80104962:	e8 8f cd ff ff       	call   801016f6 <iinit>
80104967:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010496a:	83 ec 0c             	sub    $0xc,%esp
8010496d:	6a 01                	push   $0x1
8010496f:	e8 c2 ea ff ff       	call   80103436 <initlog>
80104974:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104977:	90                   	nop
80104978:	c9                   	leave  
80104979:	c3                   	ret    

8010497a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010497a:	f3 0f 1e fb          	endbr32 
8010497e:	55                   	push   %ebp
8010497f:	89 e5                	mov    %esp,%ebp
80104981:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104984:	e8 18 f7 ff ff       	call   801040a1 <myproc>
80104989:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010498c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104990:	75 0d                	jne    8010499f <sleep+0x25>
    panic("sleep");
80104992:	83 ec 0c             	sub    $0xc,%esp
80104995:	68 cf aa 10 80       	push   $0x8010aacf
8010499a:	e8 26 bc ff ff       	call   801005c5 <panic>

  if(lk == 0)
8010499f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801049a3:	75 0d                	jne    801049b2 <sleep+0x38>
    panic("sleep without lk");
801049a5:	83 ec 0c             	sub    $0xc,%esp
801049a8:	68 d5 aa 10 80       	push   $0x8010aad5
801049ad:	e8 13 bc ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801049b2:	81 7d 0c 40 85 11 80 	cmpl   $0x80118540,0xc(%ebp)
801049b9:	74 1e                	je     801049d9 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
801049bb:	83 ec 0c             	sub    $0xc,%esp
801049be:	68 40 85 11 80       	push   $0x80118540
801049c3:	e8 f5 03 00 00       	call   80104dbd <acquire>
801049c8:	83 c4 10             	add    $0x10,%esp
    release(lk);
801049cb:	83 ec 0c             	sub    $0xc,%esp
801049ce:	ff 75 0c             	pushl  0xc(%ebp)
801049d1:	e8 59 04 00 00       	call   80104e2f <release>
801049d6:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801049d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049dc:	8b 55 08             	mov    0x8(%ebp),%edx
801049df:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801049e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e5:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801049ec:	e8 44 fe ff ff       	call   80104835 <sched>

  // Tidy up.
  p->chan = 0;
801049f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f4:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801049fb:	81 7d 0c 40 85 11 80 	cmpl   $0x80118540,0xc(%ebp)
80104a02:	74 1e                	je     80104a22 <sleep+0xa8>
    release(&ptable.lock);
80104a04:	83 ec 0c             	sub    $0xc,%esp
80104a07:	68 40 85 11 80       	push   $0x80118540
80104a0c:	e8 1e 04 00 00       	call   80104e2f <release>
80104a11:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104a14:	83 ec 0c             	sub    $0xc,%esp
80104a17:	ff 75 0c             	pushl  0xc(%ebp)
80104a1a:	e8 9e 03 00 00       	call   80104dbd <acquire>
80104a1f:	83 c4 10             	add    $0x10,%esp
  }
}
80104a22:	90                   	nop
80104a23:	c9                   	leave  
80104a24:	c3                   	ret    

80104a25 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104a25:	f3 0f 1e fb          	endbr32 
80104a29:	55                   	push   %ebp
80104a2a:	89 e5                	mov    %esp,%ebp
80104a2c:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a2f:	c7 45 fc 74 85 11 80 	movl   $0x80118574,-0x4(%ebp)
80104a36:	eb 24                	jmp    80104a5c <wakeup1+0x37>
    if(p->state == SLEEPING && p->chan == chan)
80104a38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a3b:	8b 40 0c             	mov    0xc(%eax),%eax
80104a3e:	83 f8 02             	cmp    $0x2,%eax
80104a41:	75 15                	jne    80104a58 <wakeup1+0x33>
80104a43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a46:	8b 40 20             	mov    0x20(%eax),%eax
80104a49:	39 45 08             	cmp    %eax,0x8(%ebp)
80104a4c:	75 0a                	jne    80104a58 <wakeup1+0x33>
      p->state = RUNNABLE;
80104a4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a51:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a58:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104a5c:	81 7d fc 74 a4 11 80 	cmpl   $0x8011a474,-0x4(%ebp)
80104a63:	72 d3                	jb     80104a38 <wakeup1+0x13>
}
80104a65:	90                   	nop
80104a66:	90                   	nop
80104a67:	c9                   	leave  
80104a68:	c3                   	ret    

80104a69 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104a69:	f3 0f 1e fb          	endbr32 
80104a6d:	55                   	push   %ebp
80104a6e:	89 e5                	mov    %esp,%ebp
80104a70:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104a73:	83 ec 0c             	sub    $0xc,%esp
80104a76:	68 40 85 11 80       	push   $0x80118540
80104a7b:	e8 3d 03 00 00       	call   80104dbd <acquire>
80104a80:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104a83:	83 ec 0c             	sub    $0xc,%esp
80104a86:	ff 75 08             	pushl  0x8(%ebp)
80104a89:	e8 97 ff ff ff       	call   80104a25 <wakeup1>
80104a8e:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104a91:	83 ec 0c             	sub    $0xc,%esp
80104a94:	68 40 85 11 80       	push   $0x80118540
80104a99:	e8 91 03 00 00       	call   80104e2f <release>
80104a9e:	83 c4 10             	add    $0x10,%esp
}
80104aa1:	90                   	nop
80104aa2:	c9                   	leave  
80104aa3:	c3                   	ret    

80104aa4 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104aa4:	f3 0f 1e fb          	endbr32 
80104aa8:	55                   	push   %ebp
80104aa9:	89 e5                	mov    %esp,%ebp
80104aab:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104aae:	83 ec 0c             	sub    $0xc,%esp
80104ab1:	68 40 85 11 80       	push   $0x80118540
80104ab6:	e8 02 03 00 00       	call   80104dbd <acquire>
80104abb:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104abe:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104ac5:	eb 45                	jmp    80104b0c <kill+0x68>
    if(p->pid == pid){
80104ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aca:	8b 40 10             	mov    0x10(%eax),%eax
80104acd:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ad0:	75 36                	jne    80104b08 <kill+0x64>
      p->killed = 1;
80104ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adf:	8b 40 0c             	mov    0xc(%eax),%eax
80104ae2:	83 f8 02             	cmp    $0x2,%eax
80104ae5:	75 0a                	jne    80104af1 <kill+0x4d>
        p->state = RUNNABLE;
80104ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aea:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104af1:	83 ec 0c             	sub    $0xc,%esp
80104af4:	68 40 85 11 80       	push   $0x80118540
80104af9:	e8 31 03 00 00       	call   80104e2f <release>
80104afe:	83 c4 10             	add    $0x10,%esp
      return 0;
80104b01:	b8 00 00 00 00       	mov    $0x0,%eax
80104b06:	eb 22                	jmp    80104b2a <kill+0x86>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b08:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b0c:	81 7d f4 74 a4 11 80 	cmpl   $0x8011a474,-0xc(%ebp)
80104b13:	72 b2                	jb     80104ac7 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104b15:	83 ec 0c             	sub    $0xc,%esp
80104b18:	68 40 85 11 80       	push   $0x80118540
80104b1d:	e8 0d 03 00 00       	call   80104e2f <release>
80104b22:	83 c4 10             	add    $0x10,%esp
  return -1;
80104b25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b2a:	c9                   	leave  
80104b2b:	c3                   	ret    

80104b2c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b2c:	f3 0f 1e fb          	endbr32 
80104b30:	55                   	push   %ebp
80104b31:	89 e5                	mov    %esp,%ebp
80104b33:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b36:	c7 45 f0 74 85 11 80 	movl   $0x80118574,-0x10(%ebp)
80104b3d:	e9 d7 00 00 00       	jmp    80104c19 <procdump+0xed>
    if(p->state == UNUSED)
80104b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b45:	8b 40 0c             	mov    0xc(%eax),%eax
80104b48:	85 c0                	test   %eax,%eax
80104b4a:	0f 84 c4 00 00 00    	je     80104c14 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b53:	8b 40 0c             	mov    0xc(%eax),%eax
80104b56:	83 f8 05             	cmp    $0x5,%eax
80104b59:	77 23                	ja     80104b7e <procdump+0x52>
80104b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b5e:	8b 40 0c             	mov    0xc(%eax),%eax
80104b61:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104b68:	85 c0                	test   %eax,%eax
80104b6a:	74 12                	je     80104b7e <procdump+0x52>
      state = states[p->state];
80104b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b6f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b72:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104b79:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104b7c:	eb 07                	jmp    80104b85 <procdump+0x59>
    else
      state = "???";
80104b7e:	c7 45 ec e6 aa 10 80 	movl   $0x8010aae6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b88:	8d 50 6c             	lea    0x6c(%eax),%edx
80104b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b8e:	8b 40 10             	mov    0x10(%eax),%eax
80104b91:	52                   	push   %edx
80104b92:	ff 75 ec             	pushl  -0x14(%ebp)
80104b95:	50                   	push   %eax
80104b96:	68 ea aa 10 80       	push   $0x8010aaea
80104b9b:	e8 6c b8 ff ff       	call   8010040c <cprintf>
80104ba0:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ba6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba9:	83 f8 02             	cmp    $0x2,%eax
80104bac:	75 54                	jne    80104c02 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bb1:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bb4:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb7:	83 c0 08             	add    $0x8,%eax
80104bba:	89 c2                	mov    %eax,%edx
80104bbc:	83 ec 08             	sub    $0x8,%esp
80104bbf:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104bc2:	50                   	push   %eax
80104bc3:	52                   	push   %edx
80104bc4:	e8 bc 02 00 00       	call   80104e85 <getcallerpcs>
80104bc9:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104bcc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bd3:	eb 1c                	jmp    80104bf1 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bdc:	83 ec 08             	sub    $0x8,%esp
80104bdf:	50                   	push   %eax
80104be0:	68 f3 aa 10 80       	push   $0x8010aaf3
80104be5:	e8 22 b8 ff ff       	call   8010040c <cprintf>
80104bea:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104bed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104bf1:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104bf5:	7f 0b                	jg     80104c02 <procdump+0xd6>
80104bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfa:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bfe:	85 c0                	test   %eax,%eax
80104c00:	75 d3                	jne    80104bd5 <procdump+0xa9>
    }
    cprintf("\n");
80104c02:	83 ec 0c             	sub    $0xc,%esp
80104c05:	68 f7 aa 10 80       	push   $0x8010aaf7
80104c0a:	e8 fd b7 ff ff       	call   8010040c <cprintf>
80104c0f:	83 c4 10             	add    $0x10,%esp
80104c12:	eb 01                	jmp    80104c15 <procdump+0xe9>
      continue;
80104c14:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c15:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104c19:	81 7d f0 74 a4 11 80 	cmpl   $0x8011a474,-0x10(%ebp)
80104c20:	0f 82 1c ff ff ff    	jb     80104b42 <procdump+0x16>
  }
}
80104c26:	90                   	nop
80104c27:	90                   	nop
80104c28:	c9                   	leave  
80104c29:	c3                   	ret    

80104c2a <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104c2a:	f3 0f 1e fb          	endbr32 
80104c2e:	55                   	push   %ebp
80104c2f:	89 e5                	mov    %esp,%ebp
80104c31:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104c34:	8b 45 08             	mov    0x8(%ebp),%eax
80104c37:	83 c0 04             	add    $0x4,%eax
80104c3a:	83 ec 08             	sub    $0x8,%esp
80104c3d:	68 23 ab 10 80       	push   $0x8010ab23
80104c42:	50                   	push   %eax
80104c43:	e8 4f 01 00 00       	call   80104d97 <initlock>
80104c48:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c51:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104c54:	8b 45 08             	mov    0x8(%ebp),%eax
80104c57:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c60:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104c67:	90                   	nop
80104c68:	c9                   	leave  
80104c69:	c3                   	ret    

80104c6a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104c6a:	f3 0f 1e fb          	endbr32 
80104c6e:	55                   	push   %ebp
80104c6f:	89 e5                	mov    %esp,%ebp
80104c71:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104c74:	8b 45 08             	mov    0x8(%ebp),%eax
80104c77:	83 c0 04             	add    $0x4,%eax
80104c7a:	83 ec 0c             	sub    $0xc,%esp
80104c7d:	50                   	push   %eax
80104c7e:	e8 3a 01 00 00       	call   80104dbd <acquire>
80104c83:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104c86:	eb 15                	jmp    80104c9d <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104c88:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8b:	83 c0 04             	add    $0x4,%eax
80104c8e:	83 ec 08             	sub    $0x8,%esp
80104c91:	50                   	push   %eax
80104c92:	ff 75 08             	pushl  0x8(%ebp)
80104c95:	e8 e0 fc ff ff       	call   8010497a <sleep>
80104c9a:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca0:	8b 00                	mov    (%eax),%eax
80104ca2:	85 c0                	test   %eax,%eax
80104ca4:	75 e2                	jne    80104c88 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104caf:	e8 ed f3 ff ff       	call   801040a1 <myproc>
80104cb4:	8b 50 10             	mov    0x10(%eax),%edx
80104cb7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cba:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc0:	83 c0 04             	add    $0x4,%eax
80104cc3:	83 ec 0c             	sub    $0xc,%esp
80104cc6:	50                   	push   %eax
80104cc7:	e8 63 01 00 00       	call   80104e2f <release>
80104ccc:	83 c4 10             	add    $0x10,%esp
}
80104ccf:	90                   	nop
80104cd0:	c9                   	leave  
80104cd1:	c3                   	ret    

80104cd2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104cd2:	f3 0f 1e fb          	endbr32 
80104cd6:	55                   	push   %ebp
80104cd7:	89 e5                	mov    %esp,%ebp
80104cd9:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdf:	83 c0 04             	add    $0x4,%eax
80104ce2:	83 ec 0c             	sub    $0xc,%esp
80104ce5:	50                   	push   %eax
80104ce6:	e8 d2 00 00 00       	call   80104dbd <acquire>
80104ceb:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104cee:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cfa:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104d01:	83 ec 0c             	sub    $0xc,%esp
80104d04:	ff 75 08             	pushl  0x8(%ebp)
80104d07:	e8 5d fd ff ff       	call   80104a69 <wakeup>
80104d0c:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d12:	83 c0 04             	add    $0x4,%eax
80104d15:	83 ec 0c             	sub    $0xc,%esp
80104d18:	50                   	push   %eax
80104d19:	e8 11 01 00 00       	call   80104e2f <release>
80104d1e:	83 c4 10             	add    $0x10,%esp
}
80104d21:	90                   	nop
80104d22:	c9                   	leave  
80104d23:	c3                   	ret    

80104d24 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104d24:	f3 0f 1e fb          	endbr32 
80104d28:	55                   	push   %ebp
80104d29:	89 e5                	mov    %esp,%ebp
80104d2b:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d31:	83 c0 04             	add    $0x4,%eax
80104d34:	83 ec 0c             	sub    $0xc,%esp
80104d37:	50                   	push   %eax
80104d38:	e8 80 00 00 00       	call   80104dbd <acquire>
80104d3d:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104d40:	8b 45 08             	mov    0x8(%ebp),%eax
80104d43:	8b 00                	mov    (%eax),%eax
80104d45:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104d48:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4b:	83 c0 04             	add    $0x4,%eax
80104d4e:	83 ec 0c             	sub    $0xc,%esp
80104d51:	50                   	push   %eax
80104d52:	e8 d8 00 00 00       	call   80104e2f <release>
80104d57:	83 c4 10             	add    $0x10,%esp
  return r;
80104d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d5d:	c9                   	leave  
80104d5e:	c3                   	ret    

80104d5f <readeflags>:
{
80104d5f:	55                   	push   %ebp
80104d60:	89 e5                	mov    %esp,%ebp
80104d62:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d65:	9c                   	pushf  
80104d66:	58                   	pop    %eax
80104d67:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d6d:	c9                   	leave  
80104d6e:	c3                   	ret    

80104d6f <cli>:
{
80104d6f:	55                   	push   %ebp
80104d70:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104d72:	fa                   	cli    
}
80104d73:	90                   	nop
80104d74:	5d                   	pop    %ebp
80104d75:	c3                   	ret    

80104d76 <sti>:
{
80104d76:	55                   	push   %ebp
80104d77:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d79:	fb                   	sti    
}
80104d7a:	90                   	nop
80104d7b:	5d                   	pop    %ebp
80104d7c:	c3                   	ret    

80104d7d <xchg>:
{
80104d7d:	55                   	push   %ebp
80104d7e:	89 e5                	mov    %esp,%ebp
80104d80:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104d83:	8b 55 08             	mov    0x8(%ebp),%edx
80104d86:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d89:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d8c:	f0 87 02             	lock xchg %eax,(%edx)
80104d8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104d92:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d95:	c9                   	leave  
80104d96:	c3                   	ret    

80104d97 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104d97:	f3 0f 1e fb          	endbr32 
80104d9b:	55                   	push   %ebp
80104d9c:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104da1:	8b 55 0c             	mov    0xc(%ebp),%edx
80104da4:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104da7:	8b 45 08             	mov    0x8(%ebp),%eax
80104daa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104db0:	8b 45 08             	mov    0x8(%ebp),%eax
80104db3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104dba:	90                   	nop
80104dbb:	5d                   	pop    %ebp
80104dbc:	c3                   	ret    

80104dbd <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104dbd:	f3 0f 1e fb          	endbr32 
80104dc1:	55                   	push   %ebp
80104dc2:	89 e5                	mov    %esp,%ebp
80104dc4:	53                   	push   %ebx
80104dc5:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104dc8:	e8 6c 01 00 00       	call   80104f39 <pushcli>
  if(holding(lk)){
80104dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd0:	83 ec 0c             	sub    $0xc,%esp
80104dd3:	50                   	push   %eax
80104dd4:	e8 2b 01 00 00       	call   80104f04 <holding>
80104dd9:	83 c4 10             	add    $0x10,%esp
80104ddc:	85 c0                	test   %eax,%eax
80104dde:	74 0d                	je     80104ded <acquire+0x30>
    panic("acquire");
80104de0:	83 ec 0c             	sub    $0xc,%esp
80104de3:	68 2e ab 10 80       	push   $0x8010ab2e
80104de8:	e8 d8 b7 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104ded:	90                   	nop
80104dee:	8b 45 08             	mov    0x8(%ebp),%eax
80104df1:	83 ec 08             	sub    $0x8,%esp
80104df4:	6a 01                	push   $0x1
80104df6:	50                   	push   %eax
80104df7:	e8 81 ff ff ff       	call   80104d7d <xchg>
80104dfc:	83 c4 10             	add    $0x10,%esp
80104dff:	85 c0                	test   %eax,%eax
80104e01:	75 eb                	jne    80104dee <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104e03:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104e08:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104e0b:	e8 15 f2 ff ff       	call   80104025 <mycpu>
80104e10:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104e13:	8b 45 08             	mov    0x8(%ebp),%eax
80104e16:	83 c0 0c             	add    $0xc,%eax
80104e19:	83 ec 08             	sub    $0x8,%esp
80104e1c:	50                   	push   %eax
80104e1d:	8d 45 08             	lea    0x8(%ebp),%eax
80104e20:	50                   	push   %eax
80104e21:	e8 5f 00 00 00       	call   80104e85 <getcallerpcs>
80104e26:	83 c4 10             	add    $0x10,%esp
}
80104e29:	90                   	nop
80104e2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e2d:	c9                   	leave  
80104e2e:	c3                   	ret    

80104e2f <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104e2f:	f3 0f 1e fb          	endbr32 
80104e33:	55                   	push   %ebp
80104e34:	89 e5                	mov    %esp,%ebp
80104e36:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104e39:	83 ec 0c             	sub    $0xc,%esp
80104e3c:	ff 75 08             	pushl  0x8(%ebp)
80104e3f:	e8 c0 00 00 00       	call   80104f04 <holding>
80104e44:	83 c4 10             	add    $0x10,%esp
80104e47:	85 c0                	test   %eax,%eax
80104e49:	75 0d                	jne    80104e58 <release+0x29>
    panic("release");
80104e4b:	83 ec 0c             	sub    $0xc,%esp
80104e4e:	68 36 ab 10 80       	push   $0x8010ab36
80104e53:	e8 6d b7 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104e58:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104e62:	8b 45 08             	mov    0x8(%ebp),%eax
80104e65:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104e6c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104e71:	8b 45 08             	mov    0x8(%ebp),%eax
80104e74:	8b 55 08             	mov    0x8(%ebp),%edx
80104e77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104e7d:	e8 08 01 00 00       	call   80104f8a <popcli>
}
80104e82:	90                   	nop
80104e83:	c9                   	leave  
80104e84:	c3                   	ret    

80104e85 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104e85:	f3 0f 1e fb          	endbr32 
80104e89:	55                   	push   %ebp
80104e8a:	89 e5                	mov    %esp,%ebp
80104e8c:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104e92:	83 e8 08             	sub    $0x8,%eax
80104e95:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e98:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e9f:	eb 38                	jmp    80104ed9 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104ea1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104ea5:	74 53                	je     80104efa <getcallerpcs+0x75>
80104ea7:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104eae:	76 4a                	jbe    80104efa <getcallerpcs+0x75>
80104eb0:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104eb4:	74 44                	je     80104efa <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104eb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104eb9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ec3:	01 c2                	add    %eax,%edx
80104ec5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ec8:	8b 40 04             	mov    0x4(%eax),%eax
80104ecb:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104ecd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ed0:	8b 00                	mov    (%eax),%eax
80104ed2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104ed5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ed9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104edd:	7e c2                	jle    80104ea1 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104edf:	eb 19                	jmp    80104efa <getcallerpcs+0x75>
    pcs[i] = 0;
80104ee1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ee4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eee:	01 d0                	add    %edx,%eax
80104ef0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104ef6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104efa:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104efe:	7e e1                	jle    80104ee1 <getcallerpcs+0x5c>
}
80104f00:	90                   	nop
80104f01:	90                   	nop
80104f02:	c9                   	leave  
80104f03:	c3                   	ret    

80104f04 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104f04:	f3 0f 1e fb          	endbr32 
80104f08:	55                   	push   %ebp
80104f09:	89 e5                	mov    %esp,%ebp
80104f0b:	53                   	push   %ebx
80104f0c:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f12:	8b 00                	mov    (%eax),%eax
80104f14:	85 c0                	test   %eax,%eax
80104f16:	74 16                	je     80104f2e <holding+0x2a>
80104f18:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1b:	8b 58 08             	mov    0x8(%eax),%ebx
80104f1e:	e8 02 f1 ff ff       	call   80104025 <mycpu>
80104f23:	39 c3                	cmp    %eax,%ebx
80104f25:	75 07                	jne    80104f2e <holding+0x2a>
80104f27:	b8 01 00 00 00       	mov    $0x1,%eax
80104f2c:	eb 05                	jmp    80104f33 <holding+0x2f>
80104f2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f33:	83 c4 04             	add    $0x4,%esp
80104f36:	5b                   	pop    %ebx
80104f37:	5d                   	pop    %ebp
80104f38:	c3                   	ret    

80104f39 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104f39:	f3 0f 1e fb          	endbr32 
80104f3d:	55                   	push   %ebp
80104f3e:	89 e5                	mov    %esp,%ebp
80104f40:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104f43:	e8 17 fe ff ff       	call   80104d5f <readeflags>
80104f48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104f4b:	e8 1f fe ff ff       	call   80104d6f <cli>
  if(mycpu()->ncli == 0)
80104f50:	e8 d0 f0 ff ff       	call   80104025 <mycpu>
80104f55:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f5b:	85 c0                	test   %eax,%eax
80104f5d:	75 14                	jne    80104f73 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104f5f:	e8 c1 f0 ff ff       	call   80104025 <mycpu>
80104f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f67:	81 e2 00 02 00 00    	and    $0x200,%edx
80104f6d:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104f73:	e8 ad f0 ff ff       	call   80104025 <mycpu>
80104f78:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f7e:	83 c2 01             	add    $0x1,%edx
80104f81:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104f87:	90                   	nop
80104f88:	c9                   	leave  
80104f89:	c3                   	ret    

80104f8a <popcli>:

void
popcli(void)
{
80104f8a:	f3 0f 1e fb          	endbr32 
80104f8e:	55                   	push   %ebp
80104f8f:	89 e5                	mov    %esp,%ebp
80104f91:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104f94:	e8 c6 fd ff ff       	call   80104d5f <readeflags>
80104f99:	25 00 02 00 00       	and    $0x200,%eax
80104f9e:	85 c0                	test   %eax,%eax
80104fa0:	74 0d                	je     80104faf <popcli+0x25>
    panic("popcli - interruptible");
80104fa2:	83 ec 0c             	sub    $0xc,%esp
80104fa5:	68 3e ab 10 80       	push   $0x8010ab3e
80104faa:	e8 16 b6 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104faf:	e8 71 f0 ff ff       	call   80104025 <mycpu>
80104fb4:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104fba:	83 ea 01             	sub    $0x1,%edx
80104fbd:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104fc3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fc9:	85 c0                	test   %eax,%eax
80104fcb:	79 0d                	jns    80104fda <popcli+0x50>
    panic("popcli");
80104fcd:	83 ec 0c             	sub    $0xc,%esp
80104fd0:	68 55 ab 10 80       	push   $0x8010ab55
80104fd5:	e8 eb b5 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104fda:	e8 46 f0 ff ff       	call   80104025 <mycpu>
80104fdf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fe5:	85 c0                	test   %eax,%eax
80104fe7:	75 14                	jne    80104ffd <popcli+0x73>
80104fe9:	e8 37 f0 ff ff       	call   80104025 <mycpu>
80104fee:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104ff4:	85 c0                	test   %eax,%eax
80104ff6:	74 05                	je     80104ffd <popcli+0x73>
    sti();
80104ff8:	e8 79 fd ff ff       	call   80104d76 <sti>
}
80104ffd:	90                   	nop
80104ffe:	c9                   	leave  
80104fff:	c3                   	ret    

80105000 <stosb>:
{
80105000:	55                   	push   %ebp
80105001:	89 e5                	mov    %esp,%ebp
80105003:	57                   	push   %edi
80105004:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105005:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105008:	8b 55 10             	mov    0x10(%ebp),%edx
8010500b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010500e:	89 cb                	mov    %ecx,%ebx
80105010:	89 df                	mov    %ebx,%edi
80105012:	89 d1                	mov    %edx,%ecx
80105014:	fc                   	cld    
80105015:	f3 aa                	rep stos %al,%es:(%edi)
80105017:	89 ca                	mov    %ecx,%edx
80105019:	89 fb                	mov    %edi,%ebx
8010501b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010501e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105021:	90                   	nop
80105022:	5b                   	pop    %ebx
80105023:	5f                   	pop    %edi
80105024:	5d                   	pop    %ebp
80105025:	c3                   	ret    

80105026 <stosl>:
{
80105026:	55                   	push   %ebp
80105027:	89 e5                	mov    %esp,%ebp
80105029:	57                   	push   %edi
8010502a:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010502b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010502e:	8b 55 10             	mov    0x10(%ebp),%edx
80105031:	8b 45 0c             	mov    0xc(%ebp),%eax
80105034:	89 cb                	mov    %ecx,%ebx
80105036:	89 df                	mov    %ebx,%edi
80105038:	89 d1                	mov    %edx,%ecx
8010503a:	fc                   	cld    
8010503b:	f3 ab                	rep stos %eax,%es:(%edi)
8010503d:	89 ca                	mov    %ecx,%edx
8010503f:	89 fb                	mov    %edi,%ebx
80105041:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105044:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105047:	90                   	nop
80105048:	5b                   	pop    %ebx
80105049:	5f                   	pop    %edi
8010504a:	5d                   	pop    %ebp
8010504b:	c3                   	ret    

8010504c <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010504c:	f3 0f 1e fb          	endbr32 
80105050:	55                   	push   %ebp
80105051:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105053:	8b 45 08             	mov    0x8(%ebp),%eax
80105056:	83 e0 03             	and    $0x3,%eax
80105059:	85 c0                	test   %eax,%eax
8010505b:	75 43                	jne    801050a0 <memset+0x54>
8010505d:	8b 45 10             	mov    0x10(%ebp),%eax
80105060:	83 e0 03             	and    $0x3,%eax
80105063:	85 c0                	test   %eax,%eax
80105065:	75 39                	jne    801050a0 <memset+0x54>
    c &= 0xFF;
80105067:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010506e:	8b 45 10             	mov    0x10(%ebp),%eax
80105071:	c1 e8 02             	shr    $0x2,%eax
80105074:	89 c1                	mov    %eax,%ecx
80105076:	8b 45 0c             	mov    0xc(%ebp),%eax
80105079:	c1 e0 18             	shl    $0x18,%eax
8010507c:	89 c2                	mov    %eax,%edx
8010507e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105081:	c1 e0 10             	shl    $0x10,%eax
80105084:	09 c2                	or     %eax,%edx
80105086:	8b 45 0c             	mov    0xc(%ebp),%eax
80105089:	c1 e0 08             	shl    $0x8,%eax
8010508c:	09 d0                	or     %edx,%eax
8010508e:	0b 45 0c             	or     0xc(%ebp),%eax
80105091:	51                   	push   %ecx
80105092:	50                   	push   %eax
80105093:	ff 75 08             	pushl  0x8(%ebp)
80105096:	e8 8b ff ff ff       	call   80105026 <stosl>
8010509b:	83 c4 0c             	add    $0xc,%esp
8010509e:	eb 12                	jmp    801050b2 <memset+0x66>
  } else
    stosb(dst, c, n);
801050a0:	8b 45 10             	mov    0x10(%ebp),%eax
801050a3:	50                   	push   %eax
801050a4:	ff 75 0c             	pushl  0xc(%ebp)
801050a7:	ff 75 08             	pushl  0x8(%ebp)
801050aa:	e8 51 ff ff ff       	call   80105000 <stosb>
801050af:	83 c4 0c             	add    $0xc,%esp
  return dst;
801050b2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050b5:	c9                   	leave  
801050b6:	c3                   	ret    

801050b7 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801050b7:	f3 0f 1e fb          	endbr32 
801050bb:	55                   	push   %ebp
801050bc:	89 e5                	mov    %esp,%ebp
801050be:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801050c1:	8b 45 08             	mov    0x8(%ebp),%eax
801050c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801050c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ca:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801050cd:	eb 30                	jmp    801050ff <memcmp+0x48>
    if(*s1 != *s2)
801050cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050d2:	0f b6 10             	movzbl (%eax),%edx
801050d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050d8:	0f b6 00             	movzbl (%eax),%eax
801050db:	38 c2                	cmp    %al,%dl
801050dd:	74 18                	je     801050f7 <memcmp+0x40>
      return *s1 - *s2;
801050df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050e2:	0f b6 00             	movzbl (%eax),%eax
801050e5:	0f b6 d0             	movzbl %al,%edx
801050e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050eb:	0f b6 00             	movzbl (%eax),%eax
801050ee:	0f b6 c0             	movzbl %al,%eax
801050f1:	29 c2                	sub    %eax,%edx
801050f3:	89 d0                	mov    %edx,%eax
801050f5:	eb 1a                	jmp    80105111 <memcmp+0x5a>
    s1++, s2++;
801050f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050fb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801050ff:	8b 45 10             	mov    0x10(%ebp),%eax
80105102:	8d 50 ff             	lea    -0x1(%eax),%edx
80105105:	89 55 10             	mov    %edx,0x10(%ebp)
80105108:	85 c0                	test   %eax,%eax
8010510a:	75 c3                	jne    801050cf <memcmp+0x18>
  }

  return 0;
8010510c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105111:	c9                   	leave  
80105112:	c3                   	ret    

80105113 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105113:	f3 0f 1e fb          	endbr32 
80105117:	55                   	push   %ebp
80105118:	89 e5                	mov    %esp,%ebp
8010511a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010511d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105120:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105123:	8b 45 08             	mov    0x8(%ebp),%eax
80105126:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105129:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010512c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010512f:	73 54                	jae    80105185 <memmove+0x72>
80105131:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105134:	8b 45 10             	mov    0x10(%ebp),%eax
80105137:	01 d0                	add    %edx,%eax
80105139:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010513c:	73 47                	jae    80105185 <memmove+0x72>
    s += n;
8010513e:	8b 45 10             	mov    0x10(%ebp),%eax
80105141:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105144:	8b 45 10             	mov    0x10(%ebp),%eax
80105147:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010514a:	eb 13                	jmp    8010515f <memmove+0x4c>
      *--d = *--s;
8010514c:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105150:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105154:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105157:	0f b6 10             	movzbl (%eax),%edx
8010515a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010515d:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010515f:	8b 45 10             	mov    0x10(%ebp),%eax
80105162:	8d 50 ff             	lea    -0x1(%eax),%edx
80105165:	89 55 10             	mov    %edx,0x10(%ebp)
80105168:	85 c0                	test   %eax,%eax
8010516a:	75 e0                	jne    8010514c <memmove+0x39>
  if(s < d && s + n > d){
8010516c:	eb 24                	jmp    80105192 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
8010516e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105171:	8d 42 01             	lea    0x1(%edx),%eax
80105174:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105177:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010517a:	8d 48 01             	lea    0x1(%eax),%ecx
8010517d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105180:	0f b6 12             	movzbl (%edx),%edx
80105183:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105185:	8b 45 10             	mov    0x10(%ebp),%eax
80105188:	8d 50 ff             	lea    -0x1(%eax),%edx
8010518b:	89 55 10             	mov    %edx,0x10(%ebp)
8010518e:	85 c0                	test   %eax,%eax
80105190:	75 dc                	jne    8010516e <memmove+0x5b>

  return dst;
80105192:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105195:	c9                   	leave  
80105196:	c3                   	ret    

80105197 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105197:	f3 0f 1e fb          	endbr32 
8010519b:	55                   	push   %ebp
8010519c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010519e:	ff 75 10             	pushl  0x10(%ebp)
801051a1:	ff 75 0c             	pushl  0xc(%ebp)
801051a4:	ff 75 08             	pushl  0x8(%ebp)
801051a7:	e8 67 ff ff ff       	call   80105113 <memmove>
801051ac:	83 c4 0c             	add    $0xc,%esp
}
801051af:	c9                   	leave  
801051b0:	c3                   	ret    

801051b1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801051b1:	f3 0f 1e fb          	endbr32 
801051b5:	55                   	push   %ebp
801051b6:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801051b8:	eb 0c                	jmp    801051c6 <strncmp+0x15>
    n--, p++, q++;
801051ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051be:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801051c2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801051c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051ca:	74 1a                	je     801051e6 <strncmp+0x35>
801051cc:	8b 45 08             	mov    0x8(%ebp),%eax
801051cf:	0f b6 00             	movzbl (%eax),%eax
801051d2:	84 c0                	test   %al,%al
801051d4:	74 10                	je     801051e6 <strncmp+0x35>
801051d6:	8b 45 08             	mov    0x8(%ebp),%eax
801051d9:	0f b6 10             	movzbl (%eax),%edx
801051dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801051df:	0f b6 00             	movzbl (%eax),%eax
801051e2:	38 c2                	cmp    %al,%dl
801051e4:	74 d4                	je     801051ba <strncmp+0x9>
  if(n == 0)
801051e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051ea:	75 07                	jne    801051f3 <strncmp+0x42>
    return 0;
801051ec:	b8 00 00 00 00       	mov    $0x0,%eax
801051f1:	eb 16                	jmp    80105209 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801051f3:	8b 45 08             	mov    0x8(%ebp),%eax
801051f6:	0f b6 00             	movzbl (%eax),%eax
801051f9:	0f b6 d0             	movzbl %al,%edx
801051fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ff:	0f b6 00             	movzbl (%eax),%eax
80105202:	0f b6 c0             	movzbl %al,%eax
80105205:	29 c2                	sub    %eax,%edx
80105207:	89 d0                	mov    %edx,%eax
}
80105209:	5d                   	pop    %ebp
8010520a:	c3                   	ret    

8010520b <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010520b:	f3 0f 1e fb          	endbr32 
8010520f:	55                   	push   %ebp
80105210:	89 e5                	mov    %esp,%ebp
80105212:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105215:	8b 45 08             	mov    0x8(%ebp),%eax
80105218:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010521b:	90                   	nop
8010521c:	8b 45 10             	mov    0x10(%ebp),%eax
8010521f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105222:	89 55 10             	mov    %edx,0x10(%ebp)
80105225:	85 c0                	test   %eax,%eax
80105227:	7e 2c                	jle    80105255 <strncpy+0x4a>
80105229:	8b 55 0c             	mov    0xc(%ebp),%edx
8010522c:	8d 42 01             	lea    0x1(%edx),%eax
8010522f:	89 45 0c             	mov    %eax,0xc(%ebp)
80105232:	8b 45 08             	mov    0x8(%ebp),%eax
80105235:	8d 48 01             	lea    0x1(%eax),%ecx
80105238:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010523b:	0f b6 12             	movzbl (%edx),%edx
8010523e:	88 10                	mov    %dl,(%eax)
80105240:	0f b6 00             	movzbl (%eax),%eax
80105243:	84 c0                	test   %al,%al
80105245:	75 d5                	jne    8010521c <strncpy+0x11>
    ;
  while(n-- > 0)
80105247:	eb 0c                	jmp    80105255 <strncpy+0x4a>
    *s++ = 0;
80105249:	8b 45 08             	mov    0x8(%ebp),%eax
8010524c:	8d 50 01             	lea    0x1(%eax),%edx
8010524f:	89 55 08             	mov    %edx,0x8(%ebp)
80105252:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105255:	8b 45 10             	mov    0x10(%ebp),%eax
80105258:	8d 50 ff             	lea    -0x1(%eax),%edx
8010525b:	89 55 10             	mov    %edx,0x10(%ebp)
8010525e:	85 c0                	test   %eax,%eax
80105260:	7f e7                	jg     80105249 <strncpy+0x3e>
  return os;
80105262:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105265:	c9                   	leave  
80105266:	c3                   	ret    

80105267 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105267:	f3 0f 1e fb          	endbr32 
8010526b:	55                   	push   %ebp
8010526c:	89 e5                	mov    %esp,%ebp
8010526e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105271:	8b 45 08             	mov    0x8(%ebp),%eax
80105274:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105277:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010527b:	7f 05                	jg     80105282 <safestrcpy+0x1b>
    return os;
8010527d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105280:	eb 31                	jmp    801052b3 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105282:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105286:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010528a:	7e 1e                	jle    801052aa <safestrcpy+0x43>
8010528c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010528f:	8d 42 01             	lea    0x1(%edx),%eax
80105292:	89 45 0c             	mov    %eax,0xc(%ebp)
80105295:	8b 45 08             	mov    0x8(%ebp),%eax
80105298:	8d 48 01             	lea    0x1(%eax),%ecx
8010529b:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010529e:	0f b6 12             	movzbl (%edx),%edx
801052a1:	88 10                	mov    %dl,(%eax)
801052a3:	0f b6 00             	movzbl (%eax),%eax
801052a6:	84 c0                	test   %al,%al
801052a8:	75 d8                	jne    80105282 <safestrcpy+0x1b>
    ;
  *s = 0;
801052aa:	8b 45 08             	mov    0x8(%ebp),%eax
801052ad:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801052b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052b3:	c9                   	leave  
801052b4:	c3                   	ret    

801052b5 <strlen>:

int
strlen(const char *s)
{
801052b5:	f3 0f 1e fb          	endbr32 
801052b9:	55                   	push   %ebp
801052ba:	89 e5                	mov    %esp,%ebp
801052bc:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801052bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801052c6:	eb 04                	jmp    801052cc <strlen+0x17>
801052c8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052cc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052cf:	8b 45 08             	mov    0x8(%ebp),%eax
801052d2:	01 d0                	add    %edx,%eax
801052d4:	0f b6 00             	movzbl (%eax),%eax
801052d7:	84 c0                	test   %al,%al
801052d9:	75 ed                	jne    801052c8 <strlen+0x13>
    ;
  return n;
801052db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052de:	c9                   	leave  
801052df:	c3                   	ret    

801052e0 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801052e0:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801052e4:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801052e8:	55                   	push   %ebp
  pushl %ebx
801052e9:	53                   	push   %ebx
  pushl %esi
801052ea:	56                   	push   %esi
  pushl %edi
801052eb:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801052ec:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801052ee:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801052f0:	5f                   	pop    %edi
  popl %esi
801052f1:	5e                   	pop    %esi
  popl %ebx
801052f2:	5b                   	pop    %ebx
  popl %ebp
801052f3:	5d                   	pop    %ebp
  ret
801052f4:	c3                   	ret    

801052f5 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801052f5:	f3 0f 1e fb          	endbr32 
801052f9:	55                   	push   %ebp
801052fa:	89 e5                	mov    %esp,%ebp
801052fc:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801052ff:	e8 9d ed ff ff       	call   801040a1 <myproc>
80105304:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010530a:	8b 00                	mov    (%eax),%eax
8010530c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010530f:	73 0f                	jae    80105320 <fetchint+0x2b>
80105311:	8b 45 08             	mov    0x8(%ebp),%eax
80105314:	8d 50 04             	lea    0x4(%eax),%edx
80105317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010531a:	8b 00                	mov    (%eax),%eax
8010531c:	39 c2                	cmp    %eax,%edx
8010531e:	76 07                	jbe    80105327 <fetchint+0x32>
    return -1;
80105320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105325:	eb 0f                	jmp    80105336 <fetchint+0x41>
  *ip = *(int*)(addr);
80105327:	8b 45 08             	mov    0x8(%ebp),%eax
8010532a:	8b 10                	mov    (%eax),%edx
8010532c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532f:	89 10                	mov    %edx,(%eax)
  return 0;
80105331:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105336:	c9                   	leave  
80105337:	c3                   	ret    

80105338 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105338:	f3 0f 1e fb          	endbr32 
8010533c:	55                   	push   %ebp
8010533d:	89 e5                	mov    %esp,%ebp
8010533f:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105342:	e8 5a ed ff ff       	call   801040a1 <myproc>
80105347:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010534a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010534d:	8b 00                	mov    (%eax),%eax
8010534f:	39 45 08             	cmp    %eax,0x8(%ebp)
80105352:	72 07                	jb     8010535b <fetchstr+0x23>
    return -1;
80105354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105359:	eb 43                	jmp    8010539e <fetchstr+0x66>
  *pp = (char*)addr;
8010535b:	8b 55 08             	mov    0x8(%ebp),%edx
8010535e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105361:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105363:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105366:	8b 00                	mov    (%eax),%eax
80105368:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010536b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010536e:	8b 00                	mov    (%eax),%eax
80105370:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105373:	eb 1c                	jmp    80105391 <fetchstr+0x59>
    if(*s == 0)
80105375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105378:	0f b6 00             	movzbl (%eax),%eax
8010537b:	84 c0                	test   %al,%al
8010537d:	75 0e                	jne    8010538d <fetchstr+0x55>
      return s - *pp;
8010537f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105382:	8b 00                	mov    (%eax),%eax
80105384:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105387:	29 c2                	sub    %eax,%edx
80105389:	89 d0                	mov    %edx,%eax
8010538b:	eb 11                	jmp    8010539e <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
8010538d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105394:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105397:	72 dc                	jb     80105375 <fetchstr+0x3d>
  }
  return -1;
80105399:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010539e:	c9                   	leave  
8010539f:	c3                   	ret    

801053a0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801053a0:	f3 0f 1e fb          	endbr32 
801053a4:	55                   	push   %ebp
801053a5:	89 e5                	mov    %esp,%ebp
801053a7:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801053aa:	e8 f2 ec ff ff       	call   801040a1 <myproc>
801053af:	8b 40 18             	mov    0x18(%eax),%eax
801053b2:	8b 40 44             	mov    0x44(%eax),%eax
801053b5:	8b 55 08             	mov    0x8(%ebp),%edx
801053b8:	c1 e2 02             	shl    $0x2,%edx
801053bb:	01 d0                	add    %edx,%eax
801053bd:	83 c0 04             	add    $0x4,%eax
801053c0:	83 ec 08             	sub    $0x8,%esp
801053c3:	ff 75 0c             	pushl  0xc(%ebp)
801053c6:	50                   	push   %eax
801053c7:	e8 29 ff ff ff       	call   801052f5 <fetchint>
801053cc:	83 c4 10             	add    $0x10,%esp
}
801053cf:	c9                   	leave  
801053d0:	c3                   	ret    

801053d1 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801053d1:	f3 0f 1e fb          	endbr32 
801053d5:	55                   	push   %ebp
801053d6:	89 e5                	mov    %esp,%ebp
801053d8:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801053db:	e8 c1 ec ff ff       	call   801040a1 <myproc>
801053e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801053e3:	83 ec 08             	sub    $0x8,%esp
801053e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053e9:	50                   	push   %eax
801053ea:	ff 75 08             	pushl  0x8(%ebp)
801053ed:	e8 ae ff ff ff       	call   801053a0 <argint>
801053f2:	83 c4 10             	add    $0x10,%esp
801053f5:	85 c0                	test   %eax,%eax
801053f7:	79 07                	jns    80105400 <argptr+0x2f>
    return -1;
801053f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053fe:	eb 3b                	jmp    8010543b <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105400:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105404:	78 1f                	js     80105425 <argptr+0x54>
80105406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105409:	8b 00                	mov    (%eax),%eax
8010540b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010540e:	39 d0                	cmp    %edx,%eax
80105410:	76 13                	jbe    80105425 <argptr+0x54>
80105412:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105415:	89 c2                	mov    %eax,%edx
80105417:	8b 45 10             	mov    0x10(%ebp),%eax
8010541a:	01 c2                	add    %eax,%edx
8010541c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010541f:	8b 00                	mov    (%eax),%eax
80105421:	39 c2                	cmp    %eax,%edx
80105423:	76 07                	jbe    8010542c <argptr+0x5b>
    return -1;
80105425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010542a:	eb 0f                	jmp    8010543b <argptr+0x6a>
  *pp = (char*)i;
8010542c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542f:	89 c2                	mov    %eax,%edx
80105431:	8b 45 0c             	mov    0xc(%ebp),%eax
80105434:	89 10                	mov    %edx,(%eax)
  return 0;
80105436:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010543b:	c9                   	leave  
8010543c:	c3                   	ret    

8010543d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010543d:	f3 0f 1e fb          	endbr32 
80105441:	55                   	push   %ebp
80105442:	89 e5                	mov    %esp,%ebp
80105444:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105447:	83 ec 08             	sub    $0x8,%esp
8010544a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010544d:	50                   	push   %eax
8010544e:	ff 75 08             	pushl  0x8(%ebp)
80105451:	e8 4a ff ff ff       	call   801053a0 <argint>
80105456:	83 c4 10             	add    $0x10,%esp
80105459:	85 c0                	test   %eax,%eax
8010545b:	79 07                	jns    80105464 <argstr+0x27>
    return -1;
8010545d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105462:	eb 12                	jmp    80105476 <argstr+0x39>
  return fetchstr(addr, pp);
80105464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105467:	83 ec 08             	sub    $0x8,%esp
8010546a:	ff 75 0c             	pushl  0xc(%ebp)
8010546d:	50                   	push   %eax
8010546e:	e8 c5 fe ff ff       	call   80105338 <fetchstr>
80105473:	83 c4 10             	add    $0x10,%esp
}
80105476:	c9                   	leave  
80105477:	c3                   	ret    

80105478 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105478:	f3 0f 1e fb          	endbr32 
8010547c:	55                   	push   %ebp
8010547d:	89 e5                	mov    %esp,%ebp
8010547f:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105482:	e8 1a ec ff ff       	call   801040a1 <myproc>
80105487:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010548a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010548d:	8b 40 18             	mov    0x18(%eax),%eax
80105490:	8b 40 1c             	mov    0x1c(%eax),%eax
80105493:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105496:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010549a:	7e 2f                	jle    801054cb <syscall+0x53>
8010549c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010549f:	83 f8 15             	cmp    $0x15,%eax
801054a2:	77 27                	ja     801054cb <syscall+0x53>
801054a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054a7:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801054ae:	85 c0                	test   %eax,%eax
801054b0:	74 19                	je     801054cb <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801054b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b5:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801054bc:	ff d0                	call   *%eax
801054be:	89 c2                	mov    %eax,%edx
801054c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c3:	8b 40 18             	mov    0x18(%eax),%eax
801054c6:	89 50 1c             	mov    %edx,0x1c(%eax)
801054c9:	eb 2c                	jmp    801054f7 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801054cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ce:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801054d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d4:	8b 40 10             	mov    0x10(%eax),%eax
801054d7:	ff 75 f0             	pushl  -0x10(%ebp)
801054da:	52                   	push   %edx
801054db:	50                   	push   %eax
801054dc:	68 5c ab 10 80       	push   $0x8010ab5c
801054e1:	e8 26 af ff ff       	call   8010040c <cprintf>
801054e6:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801054e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054ec:	8b 40 18             	mov    0x18(%eax),%eax
801054ef:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801054f6:	90                   	nop
801054f7:	90                   	nop
801054f8:	c9                   	leave  
801054f9:	c3                   	ret    

801054fa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801054fa:	f3 0f 1e fb          	endbr32 
801054fe:	55                   	push   %ebp
801054ff:	89 e5                	mov    %esp,%ebp
80105501:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105504:	83 ec 08             	sub    $0x8,%esp
80105507:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010550a:	50                   	push   %eax
8010550b:	ff 75 08             	pushl  0x8(%ebp)
8010550e:	e8 8d fe ff ff       	call   801053a0 <argint>
80105513:	83 c4 10             	add    $0x10,%esp
80105516:	85 c0                	test   %eax,%eax
80105518:	79 07                	jns    80105521 <argfd+0x27>
    return -1;
8010551a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010551f:	eb 4f                	jmp    80105570 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105521:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105524:	85 c0                	test   %eax,%eax
80105526:	78 20                	js     80105548 <argfd+0x4e>
80105528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010552b:	83 f8 0f             	cmp    $0xf,%eax
8010552e:	7f 18                	jg     80105548 <argfd+0x4e>
80105530:	e8 6c eb ff ff       	call   801040a1 <myproc>
80105535:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105538:	83 c2 08             	add    $0x8,%edx
8010553b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010553f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105542:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105546:	75 07                	jne    8010554f <argfd+0x55>
    return -1;
80105548:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554d:	eb 21                	jmp    80105570 <argfd+0x76>
  if(pfd)
8010554f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105553:	74 08                	je     8010555d <argfd+0x63>
    *pfd = fd;
80105555:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105558:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555b:	89 10                	mov    %edx,(%eax)
  if(pf)
8010555d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105561:	74 08                	je     8010556b <argfd+0x71>
    *pf = f;
80105563:	8b 45 10             	mov    0x10(%ebp),%eax
80105566:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105569:	89 10                	mov    %edx,(%eax)
  return 0;
8010556b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105570:	c9                   	leave  
80105571:	c3                   	ret    

80105572 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105572:	f3 0f 1e fb          	endbr32 
80105576:	55                   	push   %ebp
80105577:	89 e5                	mov    %esp,%ebp
80105579:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010557c:	e8 20 eb ff ff       	call   801040a1 <myproc>
80105581:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105584:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010558b:	eb 2a                	jmp    801055b7 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
8010558d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105590:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105593:	83 c2 08             	add    $0x8,%edx
80105596:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010559a:	85 c0                	test   %eax,%eax
8010559c:	75 15                	jne    801055b3 <fdalloc+0x41>
      curproc->ofile[fd] = f;
8010559e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055a4:	8d 4a 08             	lea    0x8(%edx),%ecx
801055a7:	8b 55 08             	mov    0x8(%ebp),%edx
801055aa:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801055ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b1:	eb 0f                	jmp    801055c2 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801055b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801055b7:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801055bb:	7e d0                	jle    8010558d <fdalloc+0x1b>
    }
  }
  return -1;
801055bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055c2:	c9                   	leave  
801055c3:	c3                   	ret    

801055c4 <sys_dup>:

int
sys_dup(void)
{
801055c4:	f3 0f 1e fb          	endbr32 
801055c8:	55                   	push   %ebp
801055c9:	89 e5                	mov    %esp,%ebp
801055cb:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801055ce:	83 ec 04             	sub    $0x4,%esp
801055d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055d4:	50                   	push   %eax
801055d5:	6a 00                	push   $0x0
801055d7:	6a 00                	push   $0x0
801055d9:	e8 1c ff ff ff       	call   801054fa <argfd>
801055de:	83 c4 10             	add    $0x10,%esp
801055e1:	85 c0                	test   %eax,%eax
801055e3:	79 07                	jns    801055ec <sys_dup+0x28>
    return -1;
801055e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ea:	eb 31                	jmp    8010561d <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801055ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ef:	83 ec 0c             	sub    $0xc,%esp
801055f2:	50                   	push   %eax
801055f3:	e8 7a ff ff ff       	call   80105572 <fdalloc>
801055f8:	83 c4 10             	add    $0x10,%esp
801055fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105602:	79 07                	jns    8010560b <sys_dup+0x47>
    return -1;
80105604:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105609:	eb 12                	jmp    8010561d <sys_dup+0x59>
  filedup(f);
8010560b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010560e:	83 ec 0c             	sub    $0xc,%esp
80105611:	50                   	push   %eax
80105612:	e8 7d ba ff ff       	call   80101094 <filedup>
80105617:	83 c4 10             	add    $0x10,%esp
  return fd;
8010561a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010561d:	c9                   	leave  
8010561e:	c3                   	ret    

8010561f <sys_read>:

int
sys_read(void)
{
8010561f:	f3 0f 1e fb          	endbr32 
80105623:	55                   	push   %ebp
80105624:	89 e5                	mov    %esp,%ebp
80105626:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105629:	83 ec 04             	sub    $0x4,%esp
8010562c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010562f:	50                   	push   %eax
80105630:	6a 00                	push   $0x0
80105632:	6a 00                	push   $0x0
80105634:	e8 c1 fe ff ff       	call   801054fa <argfd>
80105639:	83 c4 10             	add    $0x10,%esp
8010563c:	85 c0                	test   %eax,%eax
8010563e:	78 2e                	js     8010566e <sys_read+0x4f>
80105640:	83 ec 08             	sub    $0x8,%esp
80105643:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105646:	50                   	push   %eax
80105647:	6a 02                	push   $0x2
80105649:	e8 52 fd ff ff       	call   801053a0 <argint>
8010564e:	83 c4 10             	add    $0x10,%esp
80105651:	85 c0                	test   %eax,%eax
80105653:	78 19                	js     8010566e <sys_read+0x4f>
80105655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105658:	83 ec 04             	sub    $0x4,%esp
8010565b:	50                   	push   %eax
8010565c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010565f:	50                   	push   %eax
80105660:	6a 01                	push   $0x1
80105662:	e8 6a fd ff ff       	call   801053d1 <argptr>
80105667:	83 c4 10             	add    $0x10,%esp
8010566a:	85 c0                	test   %eax,%eax
8010566c:	79 07                	jns    80105675 <sys_read+0x56>
    return -1;
8010566e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105673:	eb 17                	jmp    8010568c <sys_read+0x6d>
  return fileread(f, p, n);
80105675:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105678:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010567b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567e:	83 ec 04             	sub    $0x4,%esp
80105681:	51                   	push   %ecx
80105682:	52                   	push   %edx
80105683:	50                   	push   %eax
80105684:	e8 a7 bb ff ff       	call   80101230 <fileread>
80105689:	83 c4 10             	add    $0x10,%esp
}
8010568c:	c9                   	leave  
8010568d:	c3                   	ret    

8010568e <sys_write>:

int
sys_write(void)
{
8010568e:	f3 0f 1e fb          	endbr32 
80105692:	55                   	push   %ebp
80105693:	89 e5                	mov    %esp,%ebp
80105695:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105698:	83 ec 04             	sub    $0x4,%esp
8010569b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010569e:	50                   	push   %eax
8010569f:	6a 00                	push   $0x0
801056a1:	6a 00                	push   $0x0
801056a3:	e8 52 fe ff ff       	call   801054fa <argfd>
801056a8:	83 c4 10             	add    $0x10,%esp
801056ab:	85 c0                	test   %eax,%eax
801056ad:	78 2e                	js     801056dd <sys_write+0x4f>
801056af:	83 ec 08             	sub    $0x8,%esp
801056b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056b5:	50                   	push   %eax
801056b6:	6a 02                	push   $0x2
801056b8:	e8 e3 fc ff ff       	call   801053a0 <argint>
801056bd:	83 c4 10             	add    $0x10,%esp
801056c0:	85 c0                	test   %eax,%eax
801056c2:	78 19                	js     801056dd <sys_write+0x4f>
801056c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c7:	83 ec 04             	sub    $0x4,%esp
801056ca:	50                   	push   %eax
801056cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056ce:	50                   	push   %eax
801056cf:	6a 01                	push   $0x1
801056d1:	e8 fb fc ff ff       	call   801053d1 <argptr>
801056d6:	83 c4 10             	add    $0x10,%esp
801056d9:	85 c0                	test   %eax,%eax
801056db:	79 07                	jns    801056e4 <sys_write+0x56>
    return -1;
801056dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e2:	eb 17                	jmp    801056fb <sys_write+0x6d>
  return filewrite(f, p, n);
801056e4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801056e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801056ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ed:	83 ec 04             	sub    $0x4,%esp
801056f0:	51                   	push   %ecx
801056f1:	52                   	push   %edx
801056f2:	50                   	push   %eax
801056f3:	e8 f4 bb ff ff       	call   801012ec <filewrite>
801056f8:	83 c4 10             	add    $0x10,%esp
}
801056fb:	c9                   	leave  
801056fc:	c3                   	ret    

801056fd <sys_close>:

int
sys_close(void)
{
801056fd:	f3 0f 1e fb          	endbr32 
80105701:	55                   	push   %ebp
80105702:	89 e5                	mov    %esp,%ebp
80105704:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105707:	83 ec 04             	sub    $0x4,%esp
8010570a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010570d:	50                   	push   %eax
8010570e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105711:	50                   	push   %eax
80105712:	6a 00                	push   $0x0
80105714:	e8 e1 fd ff ff       	call   801054fa <argfd>
80105719:	83 c4 10             	add    $0x10,%esp
8010571c:	85 c0                	test   %eax,%eax
8010571e:	79 07                	jns    80105727 <sys_close+0x2a>
    return -1;
80105720:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105725:	eb 27                	jmp    8010574e <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105727:	e8 75 e9 ff ff       	call   801040a1 <myproc>
8010572c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010572f:	83 c2 08             	add    $0x8,%edx
80105732:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105739:	00 
  fileclose(f);
8010573a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010573d:	83 ec 0c             	sub    $0xc,%esp
80105740:	50                   	push   %eax
80105741:	e8 a3 b9 ff ff       	call   801010e9 <fileclose>
80105746:	83 c4 10             	add    $0x10,%esp
  return 0;
80105749:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010574e:	c9                   	leave  
8010574f:	c3                   	ret    

80105750 <sys_fstat>:

int
sys_fstat(void)
{
80105750:	f3 0f 1e fb          	endbr32 
80105754:	55                   	push   %ebp
80105755:	89 e5                	mov    %esp,%ebp
80105757:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010575a:	83 ec 04             	sub    $0x4,%esp
8010575d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105760:	50                   	push   %eax
80105761:	6a 00                	push   $0x0
80105763:	6a 00                	push   $0x0
80105765:	e8 90 fd ff ff       	call   801054fa <argfd>
8010576a:	83 c4 10             	add    $0x10,%esp
8010576d:	85 c0                	test   %eax,%eax
8010576f:	78 17                	js     80105788 <sys_fstat+0x38>
80105771:	83 ec 04             	sub    $0x4,%esp
80105774:	6a 14                	push   $0x14
80105776:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105779:	50                   	push   %eax
8010577a:	6a 01                	push   $0x1
8010577c:	e8 50 fc ff ff       	call   801053d1 <argptr>
80105781:	83 c4 10             	add    $0x10,%esp
80105784:	85 c0                	test   %eax,%eax
80105786:	79 07                	jns    8010578f <sys_fstat+0x3f>
    return -1;
80105788:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578d:	eb 13                	jmp    801057a2 <sys_fstat+0x52>
  return filestat(f, st);
8010578f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105795:	83 ec 08             	sub    $0x8,%esp
80105798:	52                   	push   %edx
80105799:	50                   	push   %eax
8010579a:	e8 36 ba ff ff       	call   801011d5 <filestat>
8010579f:	83 c4 10             	add    $0x10,%esp
}
801057a2:	c9                   	leave  
801057a3:	c3                   	ret    

801057a4 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801057a4:	f3 0f 1e fb          	endbr32 
801057a8:	55                   	push   %ebp
801057a9:	89 e5                	mov    %esp,%ebp
801057ab:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801057ae:	83 ec 08             	sub    $0x8,%esp
801057b1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801057b4:	50                   	push   %eax
801057b5:	6a 00                	push   $0x0
801057b7:	e8 81 fc ff ff       	call   8010543d <argstr>
801057bc:	83 c4 10             	add    $0x10,%esp
801057bf:	85 c0                	test   %eax,%eax
801057c1:	78 15                	js     801057d8 <sys_link+0x34>
801057c3:	83 ec 08             	sub    $0x8,%esp
801057c6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801057c9:	50                   	push   %eax
801057ca:	6a 01                	push   $0x1
801057cc:	e8 6c fc ff ff       	call   8010543d <argstr>
801057d1:	83 c4 10             	add    $0x10,%esp
801057d4:	85 c0                	test   %eax,%eax
801057d6:	79 0a                	jns    801057e2 <sys_link+0x3e>
    return -1;
801057d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057dd:	e9 68 01 00 00       	jmp    8010594a <sys_link+0x1a6>

  begin_op();
801057e2:	e8 82 de ff ff       	call   80103669 <begin_op>
  if((ip = namei(old)) == 0){
801057e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801057ea:	83 ec 0c             	sub    $0xc,%esp
801057ed:	50                   	push   %eax
801057ee:	e8 f4 cd ff ff       	call   801025e7 <namei>
801057f3:	83 c4 10             	add    $0x10,%esp
801057f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057fd:	75 0f                	jne    8010580e <sys_link+0x6a>
    end_op();
801057ff:	e8 f5 de ff ff       	call   801036f9 <end_op>
    return -1;
80105804:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105809:	e9 3c 01 00 00       	jmp    8010594a <sys_link+0x1a6>
  }

  ilock(ip);
8010580e:	83 ec 0c             	sub    $0xc,%esp
80105811:	ff 75 f4             	pushl  -0xc(%ebp)
80105814:	e8 63 c2 ff ff       	call   80101a7c <ilock>
80105819:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010581c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105823:	66 83 f8 01          	cmp    $0x1,%ax
80105827:	75 1d                	jne    80105846 <sys_link+0xa2>
    iunlockput(ip);
80105829:	83 ec 0c             	sub    $0xc,%esp
8010582c:	ff 75 f4             	pushl  -0xc(%ebp)
8010582f:	e8 85 c4 ff ff       	call   80101cb9 <iunlockput>
80105834:	83 c4 10             	add    $0x10,%esp
    end_op();
80105837:	e8 bd de ff ff       	call   801036f9 <end_op>
    return -1;
8010583c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105841:	e9 04 01 00 00       	jmp    8010594a <sys_link+0x1a6>
  }

  ip->nlink++;
80105846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105849:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010584d:	83 c0 01             	add    $0x1,%eax
80105850:	89 c2                	mov    %eax,%edx
80105852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105855:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105859:	83 ec 0c             	sub    $0xc,%esp
8010585c:	ff 75 f4             	pushl  -0xc(%ebp)
8010585f:	e8 2f c0 ff ff       	call   80101893 <iupdate>
80105864:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105867:	83 ec 0c             	sub    $0xc,%esp
8010586a:	ff 75 f4             	pushl  -0xc(%ebp)
8010586d:	e8 21 c3 ff ff       	call   80101b93 <iunlock>
80105872:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105875:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105878:	83 ec 08             	sub    $0x8,%esp
8010587b:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010587e:	52                   	push   %edx
8010587f:	50                   	push   %eax
80105880:	e8 82 cd ff ff       	call   80102607 <nameiparent>
80105885:	83 c4 10             	add    $0x10,%esp
80105888:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010588b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010588f:	74 71                	je     80105902 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105891:	83 ec 0c             	sub    $0xc,%esp
80105894:	ff 75 f0             	pushl  -0x10(%ebp)
80105897:	e8 e0 c1 ff ff       	call   80101a7c <ilock>
8010589c:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010589f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a2:	8b 10                	mov    (%eax),%edx
801058a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a7:	8b 00                	mov    (%eax),%eax
801058a9:	39 c2                	cmp    %eax,%edx
801058ab:	75 1d                	jne    801058ca <sys_link+0x126>
801058ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b0:	8b 40 04             	mov    0x4(%eax),%eax
801058b3:	83 ec 04             	sub    $0x4,%esp
801058b6:	50                   	push   %eax
801058b7:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801058ba:	50                   	push   %eax
801058bb:	ff 75 f0             	pushl  -0x10(%ebp)
801058be:	e8 81 ca ff ff       	call   80102344 <dirlink>
801058c3:	83 c4 10             	add    $0x10,%esp
801058c6:	85 c0                	test   %eax,%eax
801058c8:	79 10                	jns    801058da <sys_link+0x136>
    iunlockput(dp);
801058ca:	83 ec 0c             	sub    $0xc,%esp
801058cd:	ff 75 f0             	pushl  -0x10(%ebp)
801058d0:	e8 e4 c3 ff ff       	call   80101cb9 <iunlockput>
801058d5:	83 c4 10             	add    $0x10,%esp
    goto bad;
801058d8:	eb 29                	jmp    80105903 <sys_link+0x15f>
  }
  iunlockput(dp);
801058da:	83 ec 0c             	sub    $0xc,%esp
801058dd:	ff 75 f0             	pushl  -0x10(%ebp)
801058e0:	e8 d4 c3 ff ff       	call   80101cb9 <iunlockput>
801058e5:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801058e8:	83 ec 0c             	sub    $0xc,%esp
801058eb:	ff 75 f4             	pushl  -0xc(%ebp)
801058ee:	e8 f2 c2 ff ff       	call   80101be5 <iput>
801058f3:	83 c4 10             	add    $0x10,%esp

  end_op();
801058f6:	e8 fe dd ff ff       	call   801036f9 <end_op>

  return 0;
801058fb:	b8 00 00 00 00       	mov    $0x0,%eax
80105900:	eb 48                	jmp    8010594a <sys_link+0x1a6>
    goto bad;
80105902:	90                   	nop

bad:
  ilock(ip);
80105903:	83 ec 0c             	sub    $0xc,%esp
80105906:	ff 75 f4             	pushl  -0xc(%ebp)
80105909:	e8 6e c1 ff ff       	call   80101a7c <ilock>
8010590e:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105914:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105918:	83 e8 01             	sub    $0x1,%eax
8010591b:	89 c2                	mov    %eax,%edx
8010591d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105920:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105924:	83 ec 0c             	sub    $0xc,%esp
80105927:	ff 75 f4             	pushl  -0xc(%ebp)
8010592a:	e8 64 bf ff ff       	call   80101893 <iupdate>
8010592f:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105932:	83 ec 0c             	sub    $0xc,%esp
80105935:	ff 75 f4             	pushl  -0xc(%ebp)
80105938:	e8 7c c3 ff ff       	call   80101cb9 <iunlockput>
8010593d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105940:	e8 b4 dd ff ff       	call   801036f9 <end_op>
  return -1;
80105945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010594a:	c9                   	leave  
8010594b:	c3                   	ret    

8010594c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010594c:	f3 0f 1e fb          	endbr32 
80105950:	55                   	push   %ebp
80105951:	89 e5                	mov    %esp,%ebp
80105953:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105956:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010595d:	eb 40                	jmp    8010599f <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010595f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105962:	6a 10                	push   $0x10
80105964:	50                   	push   %eax
80105965:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105968:	50                   	push   %eax
80105969:	ff 75 08             	pushl  0x8(%ebp)
8010596c:	e8 13 c6 ff ff       	call   80101f84 <readi>
80105971:	83 c4 10             	add    $0x10,%esp
80105974:	83 f8 10             	cmp    $0x10,%eax
80105977:	74 0d                	je     80105986 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105979:	83 ec 0c             	sub    $0xc,%esp
8010597c:	68 78 ab 10 80       	push   $0x8010ab78
80105981:	e8 3f ac ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105986:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010598a:	66 85 c0             	test   %ax,%ax
8010598d:	74 07                	je     80105996 <isdirempty+0x4a>
      return 0;
8010598f:	b8 00 00 00 00       	mov    $0x0,%eax
80105994:	eb 1b                	jmp    801059b1 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105999:	83 c0 10             	add    $0x10,%eax
8010599c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010599f:	8b 45 08             	mov    0x8(%ebp),%eax
801059a2:	8b 50 58             	mov    0x58(%eax),%edx
801059a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a8:	39 c2                	cmp    %eax,%edx
801059aa:	77 b3                	ja     8010595f <isdirempty+0x13>
  }
  return 1;
801059ac:	b8 01 00 00 00       	mov    $0x1,%eax
}
801059b1:	c9                   	leave  
801059b2:	c3                   	ret    

801059b3 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801059b3:	f3 0f 1e fb          	endbr32 
801059b7:	55                   	push   %ebp
801059b8:	89 e5                	mov    %esp,%ebp
801059ba:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801059bd:	83 ec 08             	sub    $0x8,%esp
801059c0:	8d 45 cc             	lea    -0x34(%ebp),%eax
801059c3:	50                   	push   %eax
801059c4:	6a 00                	push   $0x0
801059c6:	e8 72 fa ff ff       	call   8010543d <argstr>
801059cb:	83 c4 10             	add    $0x10,%esp
801059ce:	85 c0                	test   %eax,%eax
801059d0:	79 0a                	jns    801059dc <sys_unlink+0x29>
    return -1;
801059d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d7:	e9 bf 01 00 00       	jmp    80105b9b <sys_unlink+0x1e8>

  begin_op();
801059dc:	e8 88 dc ff ff       	call   80103669 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801059e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801059e4:	83 ec 08             	sub    $0x8,%esp
801059e7:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801059ea:	52                   	push   %edx
801059eb:	50                   	push   %eax
801059ec:	e8 16 cc ff ff       	call   80102607 <nameiparent>
801059f1:	83 c4 10             	add    $0x10,%esp
801059f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059fb:	75 0f                	jne    80105a0c <sys_unlink+0x59>
    end_op();
801059fd:	e8 f7 dc ff ff       	call   801036f9 <end_op>
    return -1;
80105a02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a07:	e9 8f 01 00 00       	jmp    80105b9b <sys_unlink+0x1e8>
  }

  ilock(dp);
80105a0c:	83 ec 0c             	sub    $0xc,%esp
80105a0f:	ff 75 f4             	pushl  -0xc(%ebp)
80105a12:	e8 65 c0 ff ff       	call   80101a7c <ilock>
80105a17:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105a1a:	83 ec 08             	sub    $0x8,%esp
80105a1d:	68 8a ab 10 80       	push   $0x8010ab8a
80105a22:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a25:	50                   	push   %eax
80105a26:	e8 3c c8 ff ff       	call   80102267 <namecmp>
80105a2b:	83 c4 10             	add    $0x10,%esp
80105a2e:	85 c0                	test   %eax,%eax
80105a30:	0f 84 49 01 00 00    	je     80105b7f <sys_unlink+0x1cc>
80105a36:	83 ec 08             	sub    $0x8,%esp
80105a39:	68 8c ab 10 80       	push   $0x8010ab8c
80105a3e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a41:	50                   	push   %eax
80105a42:	e8 20 c8 ff ff       	call   80102267 <namecmp>
80105a47:	83 c4 10             	add    $0x10,%esp
80105a4a:	85 c0                	test   %eax,%eax
80105a4c:	0f 84 2d 01 00 00    	je     80105b7f <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105a52:	83 ec 04             	sub    $0x4,%esp
80105a55:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105a58:	50                   	push   %eax
80105a59:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a5c:	50                   	push   %eax
80105a5d:	ff 75 f4             	pushl  -0xc(%ebp)
80105a60:	e8 21 c8 ff ff       	call   80102286 <dirlookup>
80105a65:	83 c4 10             	add    $0x10,%esp
80105a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a6f:	0f 84 0d 01 00 00    	je     80105b82 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105a75:	83 ec 0c             	sub    $0xc,%esp
80105a78:	ff 75 f0             	pushl  -0x10(%ebp)
80105a7b:	e8 fc bf ff ff       	call   80101a7c <ilock>
80105a80:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a86:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a8a:	66 85 c0             	test   %ax,%ax
80105a8d:	7f 0d                	jg     80105a9c <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105a8f:	83 ec 0c             	sub    $0xc,%esp
80105a92:	68 8f ab 10 80       	push   $0x8010ab8f
80105a97:	e8 29 ab ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105aa3:	66 83 f8 01          	cmp    $0x1,%ax
80105aa7:	75 25                	jne    80105ace <sys_unlink+0x11b>
80105aa9:	83 ec 0c             	sub    $0xc,%esp
80105aac:	ff 75 f0             	pushl  -0x10(%ebp)
80105aaf:	e8 98 fe ff ff       	call   8010594c <isdirempty>
80105ab4:	83 c4 10             	add    $0x10,%esp
80105ab7:	85 c0                	test   %eax,%eax
80105ab9:	75 13                	jne    80105ace <sys_unlink+0x11b>
    iunlockput(ip);
80105abb:	83 ec 0c             	sub    $0xc,%esp
80105abe:	ff 75 f0             	pushl  -0x10(%ebp)
80105ac1:	e8 f3 c1 ff ff       	call   80101cb9 <iunlockput>
80105ac6:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ac9:	e9 b5 00 00 00       	jmp    80105b83 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105ace:	83 ec 04             	sub    $0x4,%esp
80105ad1:	6a 10                	push   $0x10
80105ad3:	6a 00                	push   $0x0
80105ad5:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ad8:	50                   	push   %eax
80105ad9:	e8 6e f5 ff ff       	call   8010504c <memset>
80105ade:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ae1:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ae4:	6a 10                	push   $0x10
80105ae6:	50                   	push   %eax
80105ae7:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105aea:	50                   	push   %eax
80105aeb:	ff 75 f4             	pushl  -0xc(%ebp)
80105aee:	e8 ea c5 ff ff       	call   801020dd <writei>
80105af3:	83 c4 10             	add    $0x10,%esp
80105af6:	83 f8 10             	cmp    $0x10,%eax
80105af9:	74 0d                	je     80105b08 <sys_unlink+0x155>
    panic("unlink: writei");
80105afb:	83 ec 0c             	sub    $0xc,%esp
80105afe:	68 a1 ab 10 80       	push   $0x8010aba1
80105b03:	e8 bd aa ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b0f:	66 83 f8 01          	cmp    $0x1,%ax
80105b13:	75 21                	jne    80105b36 <sys_unlink+0x183>
    dp->nlink--;
80105b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b18:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b1c:	83 e8 01             	sub    $0x1,%eax
80105b1f:	89 c2                	mov    %eax,%edx
80105b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b24:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105b28:	83 ec 0c             	sub    $0xc,%esp
80105b2b:	ff 75 f4             	pushl  -0xc(%ebp)
80105b2e:	e8 60 bd ff ff       	call   80101893 <iupdate>
80105b33:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105b36:	83 ec 0c             	sub    $0xc,%esp
80105b39:	ff 75 f4             	pushl  -0xc(%ebp)
80105b3c:	e8 78 c1 ff ff       	call   80101cb9 <iunlockput>
80105b41:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b47:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b4b:	83 e8 01             	sub    $0x1,%eax
80105b4e:	89 c2                	mov    %eax,%edx
80105b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b53:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b57:	83 ec 0c             	sub    $0xc,%esp
80105b5a:	ff 75 f0             	pushl  -0x10(%ebp)
80105b5d:	e8 31 bd ff ff       	call   80101893 <iupdate>
80105b62:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b65:	83 ec 0c             	sub    $0xc,%esp
80105b68:	ff 75 f0             	pushl  -0x10(%ebp)
80105b6b:	e8 49 c1 ff ff       	call   80101cb9 <iunlockput>
80105b70:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b73:	e8 81 db ff ff       	call   801036f9 <end_op>

  return 0;
80105b78:	b8 00 00 00 00       	mov    $0x0,%eax
80105b7d:	eb 1c                	jmp    80105b9b <sys_unlink+0x1e8>
    goto bad;
80105b7f:	90                   	nop
80105b80:	eb 01                	jmp    80105b83 <sys_unlink+0x1d0>
    goto bad;
80105b82:	90                   	nop

bad:
  iunlockput(dp);
80105b83:	83 ec 0c             	sub    $0xc,%esp
80105b86:	ff 75 f4             	pushl  -0xc(%ebp)
80105b89:	e8 2b c1 ff ff       	call   80101cb9 <iunlockput>
80105b8e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b91:	e8 63 db ff ff       	call   801036f9 <end_op>
  return -1;
80105b96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b9b:	c9                   	leave  
80105b9c:	c3                   	ret    

80105b9d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b9d:	f3 0f 1e fb          	endbr32 
80105ba1:	55                   	push   %ebp
80105ba2:	89 e5                	mov    %esp,%ebp
80105ba4:	83 ec 38             	sub    $0x38,%esp
80105ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105baa:	8b 55 10             	mov    0x10(%ebp),%edx
80105bad:	8b 45 14             	mov    0x14(%ebp),%eax
80105bb0:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105bb4:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105bb8:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105bbc:	83 ec 08             	sub    $0x8,%esp
80105bbf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105bc2:	50                   	push   %eax
80105bc3:	ff 75 08             	pushl  0x8(%ebp)
80105bc6:	e8 3c ca ff ff       	call   80102607 <nameiparent>
80105bcb:	83 c4 10             	add    $0x10,%esp
80105bce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bd5:	75 0a                	jne    80105be1 <create+0x44>
    return 0;
80105bd7:	b8 00 00 00 00       	mov    $0x0,%eax
80105bdc:	e9 90 01 00 00       	jmp    80105d71 <create+0x1d4>
  ilock(dp);
80105be1:	83 ec 0c             	sub    $0xc,%esp
80105be4:	ff 75 f4             	pushl  -0xc(%ebp)
80105be7:	e8 90 be ff ff       	call   80101a7c <ilock>
80105bec:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105bef:	83 ec 04             	sub    $0x4,%esp
80105bf2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bf5:	50                   	push   %eax
80105bf6:	8d 45 de             	lea    -0x22(%ebp),%eax
80105bf9:	50                   	push   %eax
80105bfa:	ff 75 f4             	pushl  -0xc(%ebp)
80105bfd:	e8 84 c6 ff ff       	call   80102286 <dirlookup>
80105c02:	83 c4 10             	add    $0x10,%esp
80105c05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c0c:	74 50                	je     80105c5e <create+0xc1>
    iunlockput(dp);
80105c0e:	83 ec 0c             	sub    $0xc,%esp
80105c11:	ff 75 f4             	pushl  -0xc(%ebp)
80105c14:	e8 a0 c0 ff ff       	call   80101cb9 <iunlockput>
80105c19:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105c1c:	83 ec 0c             	sub    $0xc,%esp
80105c1f:	ff 75 f0             	pushl  -0x10(%ebp)
80105c22:	e8 55 be ff ff       	call   80101a7c <ilock>
80105c27:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105c2a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105c2f:	75 15                	jne    80105c46 <create+0xa9>
80105c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c34:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c38:	66 83 f8 02          	cmp    $0x2,%ax
80105c3c:	75 08                	jne    80105c46 <create+0xa9>
      return ip;
80105c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c41:	e9 2b 01 00 00       	jmp    80105d71 <create+0x1d4>
    iunlockput(ip);
80105c46:	83 ec 0c             	sub    $0xc,%esp
80105c49:	ff 75 f0             	pushl  -0x10(%ebp)
80105c4c:	e8 68 c0 ff ff       	call   80101cb9 <iunlockput>
80105c51:	83 c4 10             	add    $0x10,%esp
    return 0;
80105c54:	b8 00 00 00 00       	mov    $0x0,%eax
80105c59:	e9 13 01 00 00       	jmp    80105d71 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105c5e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c65:	8b 00                	mov    (%eax),%eax
80105c67:	83 ec 08             	sub    $0x8,%esp
80105c6a:	52                   	push   %edx
80105c6b:	50                   	push   %eax
80105c6c:	e8 47 bb ff ff       	call   801017b8 <ialloc>
80105c71:	83 c4 10             	add    $0x10,%esp
80105c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c7b:	75 0d                	jne    80105c8a <create+0xed>
    panic("create: ialloc");
80105c7d:	83 ec 0c             	sub    $0xc,%esp
80105c80:	68 b0 ab 10 80       	push   $0x8010abb0
80105c85:	e8 3b a9 ff ff       	call   801005c5 <panic>

  ilock(ip);
80105c8a:	83 ec 0c             	sub    $0xc,%esp
80105c8d:	ff 75 f0             	pushl  -0x10(%ebp)
80105c90:	e8 e7 bd ff ff       	call   80101a7c <ilock>
80105c95:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105c9f:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105caa:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb1:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105cb7:	83 ec 0c             	sub    $0xc,%esp
80105cba:	ff 75 f0             	pushl  -0x10(%ebp)
80105cbd:	e8 d1 bb ff ff       	call   80101893 <iupdate>
80105cc2:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105cc5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105cca:	75 6a                	jne    80105d36 <create+0x199>
    dp->nlink++;  // for ".."
80105ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccf:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105cd3:	83 c0 01             	add    $0x1,%eax
80105cd6:	89 c2                	mov    %eax,%edx
80105cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cdb:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105cdf:	83 ec 0c             	sub    $0xc,%esp
80105ce2:	ff 75 f4             	pushl  -0xc(%ebp)
80105ce5:	e8 a9 bb ff ff       	call   80101893 <iupdate>
80105cea:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf0:	8b 40 04             	mov    0x4(%eax),%eax
80105cf3:	83 ec 04             	sub    $0x4,%esp
80105cf6:	50                   	push   %eax
80105cf7:	68 8a ab 10 80       	push   $0x8010ab8a
80105cfc:	ff 75 f0             	pushl  -0x10(%ebp)
80105cff:	e8 40 c6 ff ff       	call   80102344 <dirlink>
80105d04:	83 c4 10             	add    $0x10,%esp
80105d07:	85 c0                	test   %eax,%eax
80105d09:	78 1e                	js     80105d29 <create+0x18c>
80105d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0e:	8b 40 04             	mov    0x4(%eax),%eax
80105d11:	83 ec 04             	sub    $0x4,%esp
80105d14:	50                   	push   %eax
80105d15:	68 8c ab 10 80       	push   $0x8010ab8c
80105d1a:	ff 75 f0             	pushl  -0x10(%ebp)
80105d1d:	e8 22 c6 ff ff       	call   80102344 <dirlink>
80105d22:	83 c4 10             	add    $0x10,%esp
80105d25:	85 c0                	test   %eax,%eax
80105d27:	79 0d                	jns    80105d36 <create+0x199>
      panic("create dots");
80105d29:	83 ec 0c             	sub    $0xc,%esp
80105d2c:	68 bf ab 10 80       	push   $0x8010abbf
80105d31:	e8 8f a8 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d39:	8b 40 04             	mov    0x4(%eax),%eax
80105d3c:	83 ec 04             	sub    $0x4,%esp
80105d3f:	50                   	push   %eax
80105d40:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d43:	50                   	push   %eax
80105d44:	ff 75 f4             	pushl  -0xc(%ebp)
80105d47:	e8 f8 c5 ff ff       	call   80102344 <dirlink>
80105d4c:	83 c4 10             	add    $0x10,%esp
80105d4f:	85 c0                	test   %eax,%eax
80105d51:	79 0d                	jns    80105d60 <create+0x1c3>
    panic("create: dirlink");
80105d53:	83 ec 0c             	sub    $0xc,%esp
80105d56:	68 cb ab 10 80       	push   $0x8010abcb
80105d5b:	e8 65 a8 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105d60:	83 ec 0c             	sub    $0xc,%esp
80105d63:	ff 75 f4             	pushl  -0xc(%ebp)
80105d66:	e8 4e bf ff ff       	call   80101cb9 <iunlockput>
80105d6b:	83 c4 10             	add    $0x10,%esp

  return ip;
80105d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105d71:	c9                   	leave  
80105d72:	c3                   	ret    

80105d73 <sys_open>:

int
sys_open(void)
{
80105d73:	f3 0f 1e fb          	endbr32 
80105d77:	55                   	push   %ebp
80105d78:	89 e5                	mov    %esp,%ebp
80105d7a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105d7d:	83 ec 08             	sub    $0x8,%esp
80105d80:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d83:	50                   	push   %eax
80105d84:	6a 00                	push   $0x0
80105d86:	e8 b2 f6 ff ff       	call   8010543d <argstr>
80105d8b:	83 c4 10             	add    $0x10,%esp
80105d8e:	85 c0                	test   %eax,%eax
80105d90:	78 15                	js     80105da7 <sys_open+0x34>
80105d92:	83 ec 08             	sub    $0x8,%esp
80105d95:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d98:	50                   	push   %eax
80105d99:	6a 01                	push   $0x1
80105d9b:	e8 00 f6 ff ff       	call   801053a0 <argint>
80105da0:	83 c4 10             	add    $0x10,%esp
80105da3:	85 c0                	test   %eax,%eax
80105da5:	79 0a                	jns    80105db1 <sys_open+0x3e>
    return -1;
80105da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dac:	e9 61 01 00 00       	jmp    80105f12 <sys_open+0x19f>

  begin_op();
80105db1:	e8 b3 d8 ff ff       	call   80103669 <begin_op>

  if(omode & O_CREATE){
80105db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105db9:	25 00 02 00 00       	and    $0x200,%eax
80105dbe:	85 c0                	test   %eax,%eax
80105dc0:	74 2a                	je     80105dec <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105dc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105dc5:	6a 00                	push   $0x0
80105dc7:	6a 00                	push   $0x0
80105dc9:	6a 02                	push   $0x2
80105dcb:	50                   	push   %eax
80105dcc:	e8 cc fd ff ff       	call   80105b9d <create>
80105dd1:	83 c4 10             	add    $0x10,%esp
80105dd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105dd7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ddb:	75 75                	jne    80105e52 <sys_open+0xdf>
      end_op();
80105ddd:	e8 17 d9 ff ff       	call   801036f9 <end_op>
      return -1;
80105de2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de7:	e9 26 01 00 00       	jmp    80105f12 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105dec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105def:	83 ec 0c             	sub    $0xc,%esp
80105df2:	50                   	push   %eax
80105df3:	e8 ef c7 ff ff       	call   801025e7 <namei>
80105df8:	83 c4 10             	add    $0x10,%esp
80105dfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dfe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e02:	75 0f                	jne    80105e13 <sys_open+0xa0>
      end_op();
80105e04:	e8 f0 d8 ff ff       	call   801036f9 <end_op>
      return -1;
80105e09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e0e:	e9 ff 00 00 00       	jmp    80105f12 <sys_open+0x19f>
    }
    ilock(ip);
80105e13:	83 ec 0c             	sub    $0xc,%esp
80105e16:	ff 75 f4             	pushl  -0xc(%ebp)
80105e19:	e8 5e bc ff ff       	call   80101a7c <ilock>
80105e1e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e24:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e28:	66 83 f8 01          	cmp    $0x1,%ax
80105e2c:	75 24                	jne    80105e52 <sys_open+0xdf>
80105e2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e31:	85 c0                	test   %eax,%eax
80105e33:	74 1d                	je     80105e52 <sys_open+0xdf>
      iunlockput(ip);
80105e35:	83 ec 0c             	sub    $0xc,%esp
80105e38:	ff 75 f4             	pushl  -0xc(%ebp)
80105e3b:	e8 79 be ff ff       	call   80101cb9 <iunlockput>
80105e40:	83 c4 10             	add    $0x10,%esp
      end_op();
80105e43:	e8 b1 d8 ff ff       	call   801036f9 <end_op>
      return -1;
80105e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e4d:	e9 c0 00 00 00       	jmp    80105f12 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105e52:	e8 cc b1 ff ff       	call   80101023 <filealloc>
80105e57:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e5e:	74 17                	je     80105e77 <sys_open+0x104>
80105e60:	83 ec 0c             	sub    $0xc,%esp
80105e63:	ff 75 f0             	pushl  -0x10(%ebp)
80105e66:	e8 07 f7 ff ff       	call   80105572 <fdalloc>
80105e6b:	83 c4 10             	add    $0x10,%esp
80105e6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105e71:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105e75:	79 2e                	jns    80105ea5 <sys_open+0x132>
    if(f)
80105e77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e7b:	74 0e                	je     80105e8b <sys_open+0x118>
      fileclose(f);
80105e7d:	83 ec 0c             	sub    $0xc,%esp
80105e80:	ff 75 f0             	pushl  -0x10(%ebp)
80105e83:	e8 61 b2 ff ff       	call   801010e9 <fileclose>
80105e88:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105e8b:	83 ec 0c             	sub    $0xc,%esp
80105e8e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e91:	e8 23 be ff ff       	call   80101cb9 <iunlockput>
80105e96:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e99:	e8 5b d8 ff ff       	call   801036f9 <end_op>
    return -1;
80105e9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea3:	eb 6d                	jmp    80105f12 <sys_open+0x19f>
  }
  iunlock(ip);
80105ea5:	83 ec 0c             	sub    $0xc,%esp
80105ea8:	ff 75 f4             	pushl  -0xc(%ebp)
80105eab:	e8 e3 bc ff ff       	call   80101b93 <iunlock>
80105eb0:	83 c4 10             	add    $0x10,%esp
  end_op();
80105eb3:	e8 41 d8 ff ff       	call   801036f9 <end_op>

  f->type = FD_INODE;
80105eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ebb:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ec7:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ecd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105ed4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ed7:	83 e0 01             	and    $0x1,%eax
80105eda:	85 c0                	test   %eax,%eax
80105edc:	0f 94 c0             	sete   %al
80105edf:	89 c2                	mov    %eax,%edx
80105ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee4:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105ee7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105eea:	83 e0 01             	and    $0x1,%eax
80105eed:	85 c0                	test   %eax,%eax
80105eef:	75 0a                	jne    80105efb <sys_open+0x188>
80105ef1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ef4:	83 e0 02             	and    $0x2,%eax
80105ef7:	85 c0                	test   %eax,%eax
80105ef9:	74 07                	je     80105f02 <sys_open+0x18f>
80105efb:	b8 01 00 00 00       	mov    $0x1,%eax
80105f00:	eb 05                	jmp    80105f07 <sys_open+0x194>
80105f02:	b8 00 00 00 00       	mov    $0x0,%eax
80105f07:	89 c2                	mov    %eax,%edx
80105f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105f0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f12:	c9                   	leave  
80105f13:	c3                   	ret    

80105f14 <sys_mkdir>:

int
sys_mkdir(void)
{
80105f14:	f3 0f 1e fb          	endbr32 
80105f18:	55                   	push   %ebp
80105f19:	89 e5                	mov    %esp,%ebp
80105f1b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105f1e:	e8 46 d7 ff ff       	call   80103669 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105f23:	83 ec 08             	sub    $0x8,%esp
80105f26:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f29:	50                   	push   %eax
80105f2a:	6a 00                	push   $0x0
80105f2c:	e8 0c f5 ff ff       	call   8010543d <argstr>
80105f31:	83 c4 10             	add    $0x10,%esp
80105f34:	85 c0                	test   %eax,%eax
80105f36:	78 1b                	js     80105f53 <sys_mkdir+0x3f>
80105f38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f3b:	6a 00                	push   $0x0
80105f3d:	6a 00                	push   $0x0
80105f3f:	6a 01                	push   $0x1
80105f41:	50                   	push   %eax
80105f42:	e8 56 fc ff ff       	call   80105b9d <create>
80105f47:	83 c4 10             	add    $0x10,%esp
80105f4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f51:	75 0c                	jne    80105f5f <sys_mkdir+0x4b>
    end_op();
80105f53:	e8 a1 d7 ff ff       	call   801036f9 <end_op>
    return -1;
80105f58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f5d:	eb 18                	jmp    80105f77 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105f5f:	83 ec 0c             	sub    $0xc,%esp
80105f62:	ff 75 f4             	pushl  -0xc(%ebp)
80105f65:	e8 4f bd ff ff       	call   80101cb9 <iunlockput>
80105f6a:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f6d:	e8 87 d7 ff ff       	call   801036f9 <end_op>
  return 0;
80105f72:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f77:	c9                   	leave  
80105f78:	c3                   	ret    

80105f79 <sys_mknod>:

int
sys_mknod(void)
{
80105f79:	f3 0f 1e fb          	endbr32 
80105f7d:	55                   	push   %ebp
80105f7e:	89 e5                	mov    %esp,%ebp
80105f80:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105f83:	e8 e1 d6 ff ff       	call   80103669 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105f88:	83 ec 08             	sub    $0x8,%esp
80105f8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f8e:	50                   	push   %eax
80105f8f:	6a 00                	push   $0x0
80105f91:	e8 a7 f4 ff ff       	call   8010543d <argstr>
80105f96:	83 c4 10             	add    $0x10,%esp
80105f99:	85 c0                	test   %eax,%eax
80105f9b:	78 4f                	js     80105fec <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105f9d:	83 ec 08             	sub    $0x8,%esp
80105fa0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fa3:	50                   	push   %eax
80105fa4:	6a 01                	push   $0x1
80105fa6:	e8 f5 f3 ff ff       	call   801053a0 <argint>
80105fab:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105fae:	85 c0                	test   %eax,%eax
80105fb0:	78 3a                	js     80105fec <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105fb2:	83 ec 08             	sub    $0x8,%esp
80105fb5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fb8:	50                   	push   %eax
80105fb9:	6a 02                	push   $0x2
80105fbb:	e8 e0 f3 ff ff       	call   801053a0 <argint>
80105fc0:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105fc3:	85 c0                	test   %eax,%eax
80105fc5:	78 25                	js     80105fec <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105fc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fca:	0f bf c8             	movswl %ax,%ecx
80105fcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fd0:	0f bf d0             	movswl %ax,%edx
80105fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd6:	51                   	push   %ecx
80105fd7:	52                   	push   %edx
80105fd8:	6a 03                	push   $0x3
80105fda:	50                   	push   %eax
80105fdb:	e8 bd fb ff ff       	call   80105b9d <create>
80105fe0:	83 c4 10             	add    $0x10,%esp
80105fe3:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105fe6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fea:	75 0c                	jne    80105ff8 <sys_mknod+0x7f>
    end_op();
80105fec:	e8 08 d7 ff ff       	call   801036f9 <end_op>
    return -1;
80105ff1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff6:	eb 18                	jmp    80106010 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105ff8:	83 ec 0c             	sub    $0xc,%esp
80105ffb:	ff 75 f4             	pushl  -0xc(%ebp)
80105ffe:	e8 b6 bc ff ff       	call   80101cb9 <iunlockput>
80106003:	83 c4 10             	add    $0x10,%esp
  end_op();
80106006:	e8 ee d6 ff ff       	call   801036f9 <end_op>
  return 0;
8010600b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106010:	c9                   	leave  
80106011:	c3                   	ret    

80106012 <sys_chdir>:

int
sys_chdir(void)
{
80106012:	f3 0f 1e fb          	endbr32 
80106016:	55                   	push   %ebp
80106017:	89 e5                	mov    %esp,%ebp
80106019:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010601c:	e8 80 e0 ff ff       	call   801040a1 <myproc>
80106021:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106024:	e8 40 d6 ff ff       	call   80103669 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106029:	83 ec 08             	sub    $0x8,%esp
8010602c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010602f:	50                   	push   %eax
80106030:	6a 00                	push   $0x0
80106032:	e8 06 f4 ff ff       	call   8010543d <argstr>
80106037:	83 c4 10             	add    $0x10,%esp
8010603a:	85 c0                	test   %eax,%eax
8010603c:	78 18                	js     80106056 <sys_chdir+0x44>
8010603e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106041:	83 ec 0c             	sub    $0xc,%esp
80106044:	50                   	push   %eax
80106045:	e8 9d c5 ff ff       	call   801025e7 <namei>
8010604a:	83 c4 10             	add    $0x10,%esp
8010604d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106050:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106054:	75 0c                	jne    80106062 <sys_chdir+0x50>
    end_op();
80106056:	e8 9e d6 ff ff       	call   801036f9 <end_op>
    return -1;
8010605b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106060:	eb 68                	jmp    801060ca <sys_chdir+0xb8>
  }
  ilock(ip);
80106062:	83 ec 0c             	sub    $0xc,%esp
80106065:	ff 75 f0             	pushl  -0x10(%ebp)
80106068:	e8 0f ba ff ff       	call   80101a7c <ilock>
8010606d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106070:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106073:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106077:	66 83 f8 01          	cmp    $0x1,%ax
8010607b:	74 1a                	je     80106097 <sys_chdir+0x85>
    iunlockput(ip);
8010607d:	83 ec 0c             	sub    $0xc,%esp
80106080:	ff 75 f0             	pushl  -0x10(%ebp)
80106083:	e8 31 bc ff ff       	call   80101cb9 <iunlockput>
80106088:	83 c4 10             	add    $0x10,%esp
    end_op();
8010608b:	e8 69 d6 ff ff       	call   801036f9 <end_op>
    return -1;
80106090:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106095:	eb 33                	jmp    801060ca <sys_chdir+0xb8>
  }
  iunlock(ip);
80106097:	83 ec 0c             	sub    $0xc,%esp
8010609a:	ff 75 f0             	pushl  -0x10(%ebp)
8010609d:	e8 f1 ba ff ff       	call   80101b93 <iunlock>
801060a2:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801060a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a8:	8b 40 68             	mov    0x68(%eax),%eax
801060ab:	83 ec 0c             	sub    $0xc,%esp
801060ae:	50                   	push   %eax
801060af:	e8 31 bb ff ff       	call   80101be5 <iput>
801060b4:	83 c4 10             	add    $0x10,%esp
  end_op();
801060b7:	e8 3d d6 ff ff       	call   801036f9 <end_op>
  curproc->cwd = ip;
801060bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060c2:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801060c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060ca:	c9                   	leave  
801060cb:	c3                   	ret    

801060cc <sys_exec>:

int
sys_exec(void)
{
801060cc:	f3 0f 1e fb          	endbr32 
801060d0:	55                   	push   %ebp
801060d1:	89 e5                	mov    %esp,%ebp
801060d3:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801060d9:	83 ec 08             	sub    $0x8,%esp
801060dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060df:	50                   	push   %eax
801060e0:	6a 00                	push   $0x0
801060e2:	e8 56 f3 ff ff       	call   8010543d <argstr>
801060e7:	83 c4 10             	add    $0x10,%esp
801060ea:	85 c0                	test   %eax,%eax
801060ec:	78 18                	js     80106106 <sys_exec+0x3a>
801060ee:	83 ec 08             	sub    $0x8,%esp
801060f1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801060f7:	50                   	push   %eax
801060f8:	6a 01                	push   $0x1
801060fa:	e8 a1 f2 ff ff       	call   801053a0 <argint>
801060ff:	83 c4 10             	add    $0x10,%esp
80106102:	85 c0                	test   %eax,%eax
80106104:	79 0a                	jns    80106110 <sys_exec+0x44>
    return -1;
80106106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010610b:	e9 c6 00 00 00       	jmp    801061d6 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106110:	83 ec 04             	sub    $0x4,%esp
80106113:	68 80 00 00 00       	push   $0x80
80106118:	6a 00                	push   $0x0
8010611a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106120:	50                   	push   %eax
80106121:	e8 26 ef ff ff       	call   8010504c <memset>
80106126:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106129:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106133:	83 f8 1f             	cmp    $0x1f,%eax
80106136:	76 0a                	jbe    80106142 <sys_exec+0x76>
      return -1;
80106138:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010613d:	e9 94 00 00 00       	jmp    801061d6 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106145:	c1 e0 02             	shl    $0x2,%eax
80106148:	89 c2                	mov    %eax,%edx
8010614a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106150:	01 c2                	add    %eax,%edx
80106152:	83 ec 08             	sub    $0x8,%esp
80106155:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010615b:	50                   	push   %eax
8010615c:	52                   	push   %edx
8010615d:	e8 93 f1 ff ff       	call   801052f5 <fetchint>
80106162:	83 c4 10             	add    $0x10,%esp
80106165:	85 c0                	test   %eax,%eax
80106167:	79 07                	jns    80106170 <sys_exec+0xa4>
      return -1;
80106169:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010616e:	eb 66                	jmp    801061d6 <sys_exec+0x10a>
    if(uarg == 0){
80106170:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106176:	85 c0                	test   %eax,%eax
80106178:	75 27                	jne    801061a1 <sys_exec+0xd5>
      argv[i] = 0;
8010617a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010617d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106184:	00 00 00 00 
      break;
80106188:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106189:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010618c:	83 ec 08             	sub    $0x8,%esp
8010618f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106195:	52                   	push   %edx
80106196:	50                   	push   %eax
80106197:	e8 22 aa ff ff       	call   80100bbe <exec>
8010619c:	83 c4 10             	add    $0x10,%esp
8010619f:	eb 35                	jmp    801061d6 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801061a1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801061a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061aa:	c1 e2 02             	shl    $0x2,%edx
801061ad:	01 c2                	add    %eax,%edx
801061af:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801061b5:	83 ec 08             	sub    $0x8,%esp
801061b8:	52                   	push   %edx
801061b9:	50                   	push   %eax
801061ba:	e8 79 f1 ff ff       	call   80105338 <fetchstr>
801061bf:	83 c4 10             	add    $0x10,%esp
801061c2:	85 c0                	test   %eax,%eax
801061c4:	79 07                	jns    801061cd <sys_exec+0x101>
      return -1;
801061c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061cb:	eb 09                	jmp    801061d6 <sys_exec+0x10a>
  for(i=0;; i++){
801061cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801061d1:	e9 5a ff ff ff       	jmp    80106130 <sys_exec+0x64>
}
801061d6:	c9                   	leave  
801061d7:	c3                   	ret    

801061d8 <sys_pipe>:

int
sys_pipe(void)
{
801061d8:	f3 0f 1e fb          	endbr32 
801061dc:	55                   	push   %ebp
801061dd:	89 e5                	mov    %esp,%ebp
801061df:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801061e2:	83 ec 04             	sub    $0x4,%esp
801061e5:	6a 08                	push   $0x8
801061e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061ea:	50                   	push   %eax
801061eb:	6a 00                	push   $0x0
801061ed:	e8 df f1 ff ff       	call   801053d1 <argptr>
801061f2:	83 c4 10             	add    $0x10,%esp
801061f5:	85 c0                	test   %eax,%eax
801061f7:	79 0a                	jns    80106203 <sys_pipe+0x2b>
    return -1;
801061f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061fe:	e9 ae 00 00 00       	jmp    801062b1 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106203:	83 ec 08             	sub    $0x8,%esp
80106206:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106209:	50                   	push   %eax
8010620a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010620d:	50                   	push   %eax
8010620e:	e8 af d9 ff ff       	call   80103bc2 <pipealloc>
80106213:	83 c4 10             	add    $0x10,%esp
80106216:	85 c0                	test   %eax,%eax
80106218:	79 0a                	jns    80106224 <sys_pipe+0x4c>
    return -1;
8010621a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621f:	e9 8d 00 00 00       	jmp    801062b1 <sys_pipe+0xd9>
  fd0 = -1;
80106224:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010622b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010622e:	83 ec 0c             	sub    $0xc,%esp
80106231:	50                   	push   %eax
80106232:	e8 3b f3 ff ff       	call   80105572 <fdalloc>
80106237:	83 c4 10             	add    $0x10,%esp
8010623a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010623d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106241:	78 18                	js     8010625b <sys_pipe+0x83>
80106243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106246:	83 ec 0c             	sub    $0xc,%esp
80106249:	50                   	push   %eax
8010624a:	e8 23 f3 ff ff       	call   80105572 <fdalloc>
8010624f:	83 c4 10             	add    $0x10,%esp
80106252:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106255:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106259:	79 3e                	jns    80106299 <sys_pipe+0xc1>
    if(fd0 >= 0)
8010625b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010625f:	78 13                	js     80106274 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106261:	e8 3b de ff ff       	call   801040a1 <myproc>
80106266:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106269:	83 c2 08             	add    $0x8,%edx
8010626c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106273:	00 
    fileclose(rf);
80106274:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106277:	83 ec 0c             	sub    $0xc,%esp
8010627a:	50                   	push   %eax
8010627b:	e8 69 ae ff ff       	call   801010e9 <fileclose>
80106280:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106286:	83 ec 0c             	sub    $0xc,%esp
80106289:	50                   	push   %eax
8010628a:	e8 5a ae ff ff       	call   801010e9 <fileclose>
8010628f:	83 c4 10             	add    $0x10,%esp
    return -1;
80106292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106297:	eb 18                	jmp    801062b1 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106299:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010629c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010629f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801062a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062a4:	8d 50 04             	lea    0x4(%eax),%edx
801062a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062aa:	89 02                	mov    %eax,(%edx)
  return 0;
801062ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062b1:	c9                   	leave  
801062b2:	c3                   	ret    

801062b3 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801062b3:	f3 0f 1e fb          	endbr32 
801062b7:	55                   	push   %ebp
801062b8:	89 e5                	mov    %esp,%ebp
801062ba:	83 ec 08             	sub    $0x8,%esp
  return fork();
801062bd:	e8 f2 e0 ff ff       	call   801043b4 <fork>
}
801062c2:	c9                   	leave  
801062c3:	c3                   	ret    

801062c4 <sys_exit>:

int
sys_exit(void)
{
801062c4:	f3 0f 1e fb          	endbr32 
801062c8:	55                   	push   %ebp
801062c9:	89 e5                	mov    %esp,%ebp
801062cb:	83 ec 08             	sub    $0x8,%esp
  exit();
801062ce:	e8 5e e2 ff ff       	call   80104531 <exit>
  return 0;  // not reached
801062d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062d8:	c9                   	leave  
801062d9:	c3                   	ret    

801062da <sys_wait>:

int
sys_wait(void)
{
801062da:	f3 0f 1e fb          	endbr32 
801062de:	55                   	push   %ebp
801062df:	89 e5                	mov    %esp,%ebp
801062e1:	83 ec 08             	sub    $0x8,%esp
  return wait();
801062e4:	e8 6c e3 ff ff       	call   80104655 <wait>
}
801062e9:	c9                   	leave  
801062ea:	c3                   	ret    

801062eb <sys_kill>:

int
sys_kill(void)
{
801062eb:	f3 0f 1e fb          	endbr32 
801062ef:	55                   	push   %ebp
801062f0:	89 e5                	mov    %esp,%ebp
801062f2:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801062f5:	83 ec 08             	sub    $0x8,%esp
801062f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062fb:	50                   	push   %eax
801062fc:	6a 00                	push   $0x0
801062fe:	e8 9d f0 ff ff       	call   801053a0 <argint>
80106303:	83 c4 10             	add    $0x10,%esp
80106306:	85 c0                	test   %eax,%eax
80106308:	79 07                	jns    80106311 <sys_kill+0x26>
    return -1;
8010630a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630f:	eb 0f                	jmp    80106320 <sys_kill+0x35>
  return kill(pid);
80106311:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106314:	83 ec 0c             	sub    $0xc,%esp
80106317:	50                   	push   %eax
80106318:	e8 87 e7 ff ff       	call   80104aa4 <kill>
8010631d:	83 c4 10             	add    $0x10,%esp
}
80106320:	c9                   	leave  
80106321:	c3                   	ret    

80106322 <sys_getpid>:

int
sys_getpid(void)
{
80106322:	f3 0f 1e fb          	endbr32 
80106326:	55                   	push   %ebp
80106327:	89 e5                	mov    %esp,%ebp
80106329:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010632c:	e8 70 dd ff ff       	call   801040a1 <myproc>
80106331:	8b 40 10             	mov    0x10(%eax),%eax
}
80106334:	c9                   	leave  
80106335:	c3                   	ret    

80106336 <sys_sbrk>:

int
sys_sbrk(void)
{
80106336:	f3 0f 1e fb          	endbr32 
8010633a:	55                   	push   %ebp
8010633b:	89 e5                	mov    %esp,%ebp
8010633d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106340:	83 ec 08             	sub    $0x8,%esp
80106343:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106346:	50                   	push   %eax
80106347:	6a 00                	push   $0x0
80106349:	e8 52 f0 ff ff       	call   801053a0 <argint>
8010634e:	83 c4 10             	add    $0x10,%esp
80106351:	85 c0                	test   %eax,%eax
80106353:	79 07                	jns    8010635c <sys_sbrk+0x26>
    return -1;
80106355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635a:	eb 27                	jmp    80106383 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010635c:	e8 40 dd ff ff       	call   801040a1 <myproc>
80106361:	8b 00                	mov    (%eax),%eax
80106363:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106366:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106369:	83 ec 0c             	sub    $0xc,%esp
8010636c:	50                   	push   %eax
8010636d:	e8 a3 df ff ff       	call   80104315 <growproc>
80106372:	83 c4 10             	add    $0x10,%esp
80106375:	85 c0                	test   %eax,%eax
80106377:	79 07                	jns    80106380 <sys_sbrk+0x4a>
    return -1;
80106379:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637e:	eb 03                	jmp    80106383 <sys_sbrk+0x4d>
  return addr;
80106380:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106383:	c9                   	leave  
80106384:	c3                   	ret    

80106385 <sys_sleep>:

int
sys_sleep(void)
{
80106385:	f3 0f 1e fb          	endbr32 
80106389:	55                   	push   %ebp
8010638a:	89 e5                	mov    %esp,%ebp
8010638c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010638f:	83 ec 08             	sub    $0x8,%esp
80106392:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106395:	50                   	push   %eax
80106396:	6a 00                	push   $0x0
80106398:	e8 03 f0 ff ff       	call   801053a0 <argint>
8010639d:	83 c4 10             	add    $0x10,%esp
801063a0:	85 c0                	test   %eax,%eax
801063a2:	79 07                	jns    801063ab <sys_sleep+0x26>
    return -1;
801063a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a9:	eb 76                	jmp    80106421 <sys_sleep+0x9c>
  acquire(&tickslock);
801063ab:	83 ec 0c             	sub    $0xc,%esp
801063ae:	68 80 a4 11 80       	push   $0x8011a480
801063b3:	e8 05 ea ff ff       	call   80104dbd <acquire>
801063b8:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801063bb:	a1 c0 ac 11 80       	mov    0x8011acc0,%eax
801063c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801063c3:	eb 38                	jmp    801063fd <sys_sleep+0x78>
    if(myproc()->killed){
801063c5:	e8 d7 dc ff ff       	call   801040a1 <myproc>
801063ca:	8b 40 24             	mov    0x24(%eax),%eax
801063cd:	85 c0                	test   %eax,%eax
801063cf:	74 17                	je     801063e8 <sys_sleep+0x63>
      release(&tickslock);
801063d1:	83 ec 0c             	sub    $0xc,%esp
801063d4:	68 80 a4 11 80       	push   $0x8011a480
801063d9:	e8 51 ea ff ff       	call   80104e2f <release>
801063de:	83 c4 10             	add    $0x10,%esp
      return -1;
801063e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e6:	eb 39                	jmp    80106421 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801063e8:	83 ec 08             	sub    $0x8,%esp
801063eb:	68 80 a4 11 80       	push   $0x8011a480
801063f0:	68 c0 ac 11 80       	push   $0x8011acc0
801063f5:	e8 80 e5 ff ff       	call   8010497a <sleep>
801063fa:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801063fd:	a1 c0 ac 11 80       	mov    0x8011acc0,%eax
80106402:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106405:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106408:	39 d0                	cmp    %edx,%eax
8010640a:	72 b9                	jb     801063c5 <sys_sleep+0x40>
  }
  release(&tickslock);
8010640c:	83 ec 0c             	sub    $0xc,%esp
8010640f:	68 80 a4 11 80       	push   $0x8011a480
80106414:	e8 16 ea ff ff       	call   80104e2f <release>
80106419:	83 c4 10             	add    $0x10,%esp
  return 0;
8010641c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106421:	c9                   	leave  
80106422:	c3                   	ret    

80106423 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106423:	f3 0f 1e fb          	endbr32 
80106427:	55                   	push   %ebp
80106428:	89 e5                	mov    %esp,%ebp
8010642a:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010642d:	83 ec 0c             	sub    $0xc,%esp
80106430:	68 80 a4 11 80       	push   $0x8011a480
80106435:	e8 83 e9 ff ff       	call   80104dbd <acquire>
8010643a:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010643d:	a1 c0 ac 11 80       	mov    0x8011acc0,%eax
80106442:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106445:	83 ec 0c             	sub    $0xc,%esp
80106448:	68 80 a4 11 80       	push   $0x8011a480
8010644d:	e8 dd e9 ff ff       	call   80104e2f <release>
80106452:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106455:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106458:	c9                   	leave  
80106459:	c3                   	ret    

8010645a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010645a:	1e                   	push   %ds
  pushl %es
8010645b:	06                   	push   %es
  pushl %fs
8010645c:	0f a0                	push   %fs
  pushl %gs
8010645e:	0f a8                	push   %gs
  pushal
80106460:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106461:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106465:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106467:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106469:	54                   	push   %esp
  call trap
8010646a:	e8 df 01 00 00       	call   8010664e <trap>
  addl $4, %esp
8010646f:	83 c4 04             	add    $0x4,%esp

80106472 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106472:	61                   	popa   
  popl %gs
80106473:	0f a9                	pop    %gs
  popl %fs
80106475:	0f a1                	pop    %fs
  popl %es
80106477:	07                   	pop    %es
  popl %ds
80106478:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106479:	83 c4 08             	add    $0x8,%esp
  iret
8010647c:	cf                   	iret   

8010647d <lidt>:
{
8010647d:	55                   	push   %ebp
8010647e:	89 e5                	mov    %esp,%ebp
80106480:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106483:	8b 45 0c             	mov    0xc(%ebp),%eax
80106486:	83 e8 01             	sub    $0x1,%eax
80106489:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010648d:	8b 45 08             	mov    0x8(%ebp),%eax
80106490:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106494:	8b 45 08             	mov    0x8(%ebp),%eax
80106497:	c1 e8 10             	shr    $0x10,%eax
8010649a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010649e:	8d 45 fa             	lea    -0x6(%ebp),%eax
801064a1:	0f 01 18             	lidtl  (%eax)
}
801064a4:	90                   	nop
801064a5:	c9                   	leave  
801064a6:	c3                   	ret    

801064a7 <rcr2>:

static inline uint
rcr2(void)
{
801064a7:	55                   	push   %ebp
801064a8:	89 e5                	mov    %esp,%ebp
801064aa:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801064ad:	0f 20 d0             	mov    %cr2,%eax
801064b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801064b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801064b6:	c9                   	leave  
801064b7:	c3                   	ret    

801064b8 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801064b8:	f3 0f 1e fb          	endbr32 
801064bc:	55                   	push   %ebp
801064bd:	89 e5                	mov    %esp,%ebp
801064bf:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801064c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801064c9:	e9 c3 00 00 00       	jmp    80106591 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801064ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d1:	8b 04 85 78 f0 10 80 	mov    -0x7fef0f88(,%eax,4),%eax
801064d8:	89 c2                	mov    %eax,%edx
801064da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064dd:	66 89 14 c5 c0 a4 11 	mov    %dx,-0x7fee5b40(,%eax,8)
801064e4:	80 
801064e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e8:	66 c7 04 c5 c2 a4 11 	movw   $0x8,-0x7fee5b3e(,%eax,8)
801064ef:	80 08 00 
801064f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f5:	0f b6 14 c5 c4 a4 11 	movzbl -0x7fee5b3c(,%eax,8),%edx
801064fc:	80 
801064fd:	83 e2 e0             	and    $0xffffffe0,%edx
80106500:	88 14 c5 c4 a4 11 80 	mov    %dl,-0x7fee5b3c(,%eax,8)
80106507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650a:	0f b6 14 c5 c4 a4 11 	movzbl -0x7fee5b3c(,%eax,8),%edx
80106511:	80 
80106512:	83 e2 1f             	and    $0x1f,%edx
80106515:	88 14 c5 c4 a4 11 80 	mov    %dl,-0x7fee5b3c(,%eax,8)
8010651c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651f:	0f b6 14 c5 c5 a4 11 	movzbl -0x7fee5b3b(,%eax,8),%edx
80106526:	80 
80106527:	83 e2 f0             	and    $0xfffffff0,%edx
8010652a:	83 ca 0e             	or     $0xe,%edx
8010652d:	88 14 c5 c5 a4 11 80 	mov    %dl,-0x7fee5b3b(,%eax,8)
80106534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106537:	0f b6 14 c5 c5 a4 11 	movzbl -0x7fee5b3b(,%eax,8),%edx
8010653e:	80 
8010653f:	83 e2 ef             	and    $0xffffffef,%edx
80106542:	88 14 c5 c5 a4 11 80 	mov    %dl,-0x7fee5b3b(,%eax,8)
80106549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654c:	0f b6 14 c5 c5 a4 11 	movzbl -0x7fee5b3b(,%eax,8),%edx
80106553:	80 
80106554:	83 e2 9f             	and    $0xffffff9f,%edx
80106557:	88 14 c5 c5 a4 11 80 	mov    %dl,-0x7fee5b3b(,%eax,8)
8010655e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106561:	0f b6 14 c5 c5 a4 11 	movzbl -0x7fee5b3b(,%eax,8),%edx
80106568:	80 
80106569:	83 ca 80             	or     $0xffffff80,%edx
8010656c:	88 14 c5 c5 a4 11 80 	mov    %dl,-0x7fee5b3b(,%eax,8)
80106573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106576:	8b 04 85 78 f0 10 80 	mov    -0x7fef0f88(,%eax,4),%eax
8010657d:	c1 e8 10             	shr    $0x10,%eax
80106580:	89 c2                	mov    %eax,%edx
80106582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106585:	66 89 14 c5 c6 a4 11 	mov    %dx,-0x7fee5b3a(,%eax,8)
8010658c:	80 
  for(i = 0; i < 256; i++)
8010658d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106591:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106598:	0f 8e 30 ff ff ff    	jle    801064ce <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010659e:	a1 78 f1 10 80       	mov    0x8010f178,%eax
801065a3:	66 a3 c0 a6 11 80    	mov    %ax,0x8011a6c0
801065a9:	66 c7 05 c2 a6 11 80 	movw   $0x8,0x8011a6c2
801065b0:	08 00 
801065b2:	0f b6 05 c4 a6 11 80 	movzbl 0x8011a6c4,%eax
801065b9:	83 e0 e0             	and    $0xffffffe0,%eax
801065bc:	a2 c4 a6 11 80       	mov    %al,0x8011a6c4
801065c1:	0f b6 05 c4 a6 11 80 	movzbl 0x8011a6c4,%eax
801065c8:	83 e0 1f             	and    $0x1f,%eax
801065cb:	a2 c4 a6 11 80       	mov    %al,0x8011a6c4
801065d0:	0f b6 05 c5 a6 11 80 	movzbl 0x8011a6c5,%eax
801065d7:	83 c8 0f             	or     $0xf,%eax
801065da:	a2 c5 a6 11 80       	mov    %al,0x8011a6c5
801065df:	0f b6 05 c5 a6 11 80 	movzbl 0x8011a6c5,%eax
801065e6:	83 e0 ef             	and    $0xffffffef,%eax
801065e9:	a2 c5 a6 11 80       	mov    %al,0x8011a6c5
801065ee:	0f b6 05 c5 a6 11 80 	movzbl 0x8011a6c5,%eax
801065f5:	83 c8 60             	or     $0x60,%eax
801065f8:	a2 c5 a6 11 80       	mov    %al,0x8011a6c5
801065fd:	0f b6 05 c5 a6 11 80 	movzbl 0x8011a6c5,%eax
80106604:	83 c8 80             	or     $0xffffff80,%eax
80106607:	a2 c5 a6 11 80       	mov    %al,0x8011a6c5
8010660c:	a1 78 f1 10 80       	mov    0x8010f178,%eax
80106611:	c1 e8 10             	shr    $0x10,%eax
80106614:	66 a3 c6 a6 11 80    	mov    %ax,0x8011a6c6

  initlock(&tickslock, "time");
8010661a:	83 ec 08             	sub    $0x8,%esp
8010661d:	68 dc ab 10 80       	push   $0x8010abdc
80106622:	68 80 a4 11 80       	push   $0x8011a480
80106627:	e8 6b e7 ff ff       	call   80104d97 <initlock>
8010662c:	83 c4 10             	add    $0x10,%esp
}
8010662f:	90                   	nop
80106630:	c9                   	leave  
80106631:	c3                   	ret    

80106632 <idtinit>:

void
idtinit(void)
{
80106632:	f3 0f 1e fb          	endbr32 
80106636:	55                   	push   %ebp
80106637:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106639:	68 00 08 00 00       	push   $0x800
8010663e:	68 c0 a4 11 80       	push   $0x8011a4c0
80106643:	e8 35 fe ff ff       	call   8010647d <lidt>
80106648:	83 c4 08             	add    $0x8,%esp
}
8010664b:	90                   	nop
8010664c:	c9                   	leave  
8010664d:	c3                   	ret    

8010664e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010664e:	f3 0f 1e fb          	endbr32 
80106652:	55                   	push   %ebp
80106653:	89 e5                	mov    %esp,%ebp
80106655:	57                   	push   %edi
80106656:	56                   	push   %esi
80106657:	53                   	push   %ebx
80106658:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010665b:	8b 45 08             	mov    0x8(%ebp),%eax
8010665e:	8b 40 30             	mov    0x30(%eax),%eax
80106661:	83 f8 40             	cmp    $0x40,%eax
80106664:	75 3b                	jne    801066a1 <trap+0x53>
    if(myproc()->killed)
80106666:	e8 36 da ff ff       	call   801040a1 <myproc>
8010666b:	8b 40 24             	mov    0x24(%eax),%eax
8010666e:	85 c0                	test   %eax,%eax
80106670:	74 05                	je     80106677 <trap+0x29>
      exit();
80106672:	e8 ba de ff ff       	call   80104531 <exit>
    myproc()->tf = tf;
80106677:	e8 25 da ff ff       	call   801040a1 <myproc>
8010667c:	8b 55 08             	mov    0x8(%ebp),%edx
8010667f:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106682:	e8 f1 ed ff ff       	call   80105478 <syscall>
    if(myproc()->killed)
80106687:	e8 15 da ff ff       	call   801040a1 <myproc>
8010668c:	8b 40 24             	mov    0x24(%eax),%eax
8010668f:	85 c0                	test   %eax,%eax
80106691:	0f 84 16 02 00 00    	je     801068ad <trap+0x25f>
      exit();
80106697:	e8 95 de ff ff       	call   80104531 <exit>
    return;
8010669c:	e9 0c 02 00 00       	jmp    801068ad <trap+0x25f>
  }

  switch(tf->trapno){
801066a1:	8b 45 08             	mov    0x8(%ebp),%eax
801066a4:	8b 40 30             	mov    0x30(%eax),%eax
801066a7:	83 e8 20             	sub    $0x20,%eax
801066aa:	83 f8 1f             	cmp    $0x1f,%eax
801066ad:	0f 87 c5 00 00 00    	ja     80106778 <trap+0x12a>
801066b3:	8b 04 85 84 ac 10 80 	mov    -0x7fef537c(,%eax,4),%eax
801066ba:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801066bd:	e8 44 d9 ff ff       	call   80104006 <cpuid>
801066c2:	85 c0                	test   %eax,%eax
801066c4:	75 3d                	jne    80106703 <trap+0xb5>
      acquire(&tickslock);
801066c6:	83 ec 0c             	sub    $0xc,%esp
801066c9:	68 80 a4 11 80       	push   $0x8011a480
801066ce:	e8 ea e6 ff ff       	call   80104dbd <acquire>
801066d3:	83 c4 10             	add    $0x10,%esp
      ticks++;
801066d6:	a1 c0 ac 11 80       	mov    0x8011acc0,%eax
801066db:	83 c0 01             	add    $0x1,%eax
801066de:	a3 c0 ac 11 80       	mov    %eax,0x8011acc0
      wakeup(&ticks);
801066e3:	83 ec 0c             	sub    $0xc,%esp
801066e6:	68 c0 ac 11 80       	push   $0x8011acc0
801066eb:	e8 79 e3 ff ff       	call   80104a69 <wakeup>
801066f0:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801066f3:	83 ec 0c             	sub    $0xc,%esp
801066f6:	68 80 a4 11 80       	push   $0x8011a480
801066fb:	e8 2f e7 ff ff       	call   80104e2f <release>
80106700:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106703:	e8 15 ca ff ff       	call   8010311d <lapiceoi>
    break;
80106708:	e9 20 01 00 00       	jmp    8010682d <trap+0x1df>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010670d:	e8 22 c2 ff ff       	call   80102934 <ideintr>
    lapiceoi();
80106712:	e8 06 ca ff ff       	call   8010311d <lapiceoi>
    break;
80106717:	e9 11 01 00 00       	jmp    8010682d <trap+0x1df>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010671c:	e8 32 c8 ff ff       	call   80102f53 <kbdintr>
    lapiceoi();
80106721:	e8 f7 c9 ff ff       	call   8010311d <lapiceoi>
    break;
80106726:	e9 02 01 00 00       	jmp    8010682d <trap+0x1df>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010672b:	e8 5f 03 00 00       	call   80106a8f <uartintr>
    lapiceoi();
80106730:	e8 e8 c9 ff ff       	call   8010311d <lapiceoi>
    break;
80106735:	e9 f3 00 00 00       	jmp    8010682d <trap+0x1df>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010673a:	e8 2d 2c 00 00       	call   8010936c <i8254_intr>
    lapiceoi();
8010673f:	e8 d9 c9 ff ff       	call   8010311d <lapiceoi>
    break;
80106744:	e9 e4 00 00 00       	jmp    8010682d <trap+0x1df>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106749:	8b 45 08             	mov    0x8(%ebp),%eax
8010674c:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010674f:	8b 45 08             	mov    0x8(%ebp),%eax
80106752:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106756:	0f b7 d8             	movzwl %ax,%ebx
80106759:	e8 a8 d8 ff ff       	call   80104006 <cpuid>
8010675e:	56                   	push   %esi
8010675f:	53                   	push   %ebx
80106760:	50                   	push   %eax
80106761:	68 e4 ab 10 80       	push   $0x8010abe4
80106766:	e8 a1 9c ff ff       	call   8010040c <cprintf>
8010676b:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010676e:	e8 aa c9 ff ff       	call   8010311d <lapiceoi>
    break;
80106773:	e9 b5 00 00 00       	jmp    8010682d <trap+0x1df>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106778:	e8 24 d9 ff ff       	call   801040a1 <myproc>
8010677d:	85 c0                	test   %eax,%eax
8010677f:	74 11                	je     80106792 <trap+0x144>
80106781:	8b 45 08             	mov    0x8(%ebp),%eax
80106784:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106788:	0f b7 c0             	movzwl %ax,%eax
8010678b:	83 e0 03             	and    $0x3,%eax
8010678e:	85 c0                	test   %eax,%eax
80106790:	75 39                	jne    801067cb <trap+0x17d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106792:	e8 10 fd ff ff       	call   801064a7 <rcr2>
80106797:	89 c3                	mov    %eax,%ebx
80106799:	8b 45 08             	mov    0x8(%ebp),%eax
8010679c:	8b 70 38             	mov    0x38(%eax),%esi
8010679f:	e8 62 d8 ff ff       	call   80104006 <cpuid>
801067a4:	8b 55 08             	mov    0x8(%ebp),%edx
801067a7:	8b 52 30             	mov    0x30(%edx),%edx
801067aa:	83 ec 0c             	sub    $0xc,%esp
801067ad:	53                   	push   %ebx
801067ae:	56                   	push   %esi
801067af:	50                   	push   %eax
801067b0:	52                   	push   %edx
801067b1:	68 08 ac 10 80       	push   $0x8010ac08
801067b6:	e8 51 9c ff ff       	call   8010040c <cprintf>
801067bb:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801067be:	83 ec 0c             	sub    $0xc,%esp
801067c1:	68 3a ac 10 80       	push   $0x8010ac3a
801067c6:	e8 fa 9d ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067cb:	e8 d7 fc ff ff       	call   801064a7 <rcr2>
801067d0:	89 c6                	mov    %eax,%esi
801067d2:	8b 45 08             	mov    0x8(%ebp),%eax
801067d5:	8b 40 38             	mov    0x38(%eax),%eax
801067d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801067db:	e8 26 d8 ff ff       	call   80104006 <cpuid>
801067e0:	89 c3                	mov    %eax,%ebx
801067e2:	8b 45 08             	mov    0x8(%ebp),%eax
801067e5:	8b 48 34             	mov    0x34(%eax),%ecx
801067e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801067eb:	8b 45 08             	mov    0x8(%ebp),%eax
801067ee:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801067f1:	e8 ab d8 ff ff       	call   801040a1 <myproc>
801067f6:	8d 50 6c             	lea    0x6c(%eax),%edx
801067f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
801067fc:	e8 a0 d8 ff ff       	call   801040a1 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106801:	8b 40 10             	mov    0x10(%eax),%eax
80106804:	56                   	push   %esi
80106805:	ff 75 e4             	pushl  -0x1c(%ebp)
80106808:	53                   	push   %ebx
80106809:	ff 75 e0             	pushl  -0x20(%ebp)
8010680c:	57                   	push   %edi
8010680d:	ff 75 dc             	pushl  -0x24(%ebp)
80106810:	50                   	push   %eax
80106811:	68 40 ac 10 80       	push   $0x8010ac40
80106816:	e8 f1 9b ff ff       	call   8010040c <cprintf>
8010681b:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010681e:	e8 7e d8 ff ff       	call   801040a1 <myproc>
80106823:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010682a:	eb 01                	jmp    8010682d <trap+0x1df>
    break;
8010682c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010682d:	e8 6f d8 ff ff       	call   801040a1 <myproc>
80106832:	85 c0                	test   %eax,%eax
80106834:	74 23                	je     80106859 <trap+0x20b>
80106836:	e8 66 d8 ff ff       	call   801040a1 <myproc>
8010683b:	8b 40 24             	mov    0x24(%eax),%eax
8010683e:	85 c0                	test   %eax,%eax
80106840:	74 17                	je     80106859 <trap+0x20b>
80106842:	8b 45 08             	mov    0x8(%ebp),%eax
80106845:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106849:	0f b7 c0             	movzwl %ax,%eax
8010684c:	83 e0 03             	and    $0x3,%eax
8010684f:	83 f8 03             	cmp    $0x3,%eax
80106852:	75 05                	jne    80106859 <trap+0x20b>
    exit();
80106854:	e8 d8 dc ff ff       	call   80104531 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106859:	e8 43 d8 ff ff       	call   801040a1 <myproc>
8010685e:	85 c0                	test   %eax,%eax
80106860:	74 1d                	je     8010687f <trap+0x231>
80106862:	e8 3a d8 ff ff       	call   801040a1 <myproc>
80106867:	8b 40 0c             	mov    0xc(%eax),%eax
8010686a:	83 f8 04             	cmp    $0x4,%eax
8010686d:	75 10                	jne    8010687f <trap+0x231>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010686f:	8b 45 08             	mov    0x8(%ebp),%eax
80106872:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106875:	83 f8 20             	cmp    $0x20,%eax
80106878:	75 05                	jne    8010687f <trap+0x231>
    yield();
8010687a:	e8 73 e0 ff ff       	call   801048f2 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010687f:	e8 1d d8 ff ff       	call   801040a1 <myproc>
80106884:	85 c0                	test   %eax,%eax
80106886:	74 26                	je     801068ae <trap+0x260>
80106888:	e8 14 d8 ff ff       	call   801040a1 <myproc>
8010688d:	8b 40 24             	mov    0x24(%eax),%eax
80106890:	85 c0                	test   %eax,%eax
80106892:	74 1a                	je     801068ae <trap+0x260>
80106894:	8b 45 08             	mov    0x8(%ebp),%eax
80106897:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010689b:	0f b7 c0             	movzwl %ax,%eax
8010689e:	83 e0 03             	and    $0x3,%eax
801068a1:	83 f8 03             	cmp    $0x3,%eax
801068a4:	75 08                	jne    801068ae <trap+0x260>
    exit();
801068a6:	e8 86 dc ff ff       	call   80104531 <exit>
801068ab:	eb 01                	jmp    801068ae <trap+0x260>
    return;
801068ad:	90                   	nop
}
801068ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068b1:	5b                   	pop    %ebx
801068b2:	5e                   	pop    %esi
801068b3:	5f                   	pop    %edi
801068b4:	5d                   	pop    %ebp
801068b5:	c3                   	ret    

801068b6 <inb>:
{
801068b6:	55                   	push   %ebp
801068b7:	89 e5                	mov    %esp,%ebp
801068b9:	83 ec 14             	sub    $0x14,%esp
801068bc:	8b 45 08             	mov    0x8(%ebp),%eax
801068bf:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801068c3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801068c7:	89 c2                	mov    %eax,%edx
801068c9:	ec                   	in     (%dx),%al
801068ca:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801068cd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801068d1:	c9                   	leave  
801068d2:	c3                   	ret    

801068d3 <outb>:
{
801068d3:	55                   	push   %ebp
801068d4:	89 e5                	mov    %esp,%ebp
801068d6:	83 ec 08             	sub    $0x8,%esp
801068d9:	8b 45 08             	mov    0x8(%ebp),%eax
801068dc:	8b 55 0c             	mov    0xc(%ebp),%edx
801068df:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801068e3:	89 d0                	mov    %edx,%eax
801068e5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801068e8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801068ec:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801068f0:	ee                   	out    %al,(%dx)
}
801068f1:	90                   	nop
801068f2:	c9                   	leave  
801068f3:	c3                   	ret    

801068f4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801068f4:	f3 0f 1e fb          	endbr32 
801068f8:	55                   	push   %ebp
801068f9:	89 e5                	mov    %esp,%ebp
801068fb:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801068fe:	6a 00                	push   $0x0
80106900:	68 fa 03 00 00       	push   $0x3fa
80106905:	e8 c9 ff ff ff       	call   801068d3 <outb>
8010690a:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010690d:	68 80 00 00 00       	push   $0x80
80106912:	68 fb 03 00 00       	push   $0x3fb
80106917:	e8 b7 ff ff ff       	call   801068d3 <outb>
8010691c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010691f:	6a 0c                	push   $0xc
80106921:	68 f8 03 00 00       	push   $0x3f8
80106926:	e8 a8 ff ff ff       	call   801068d3 <outb>
8010692b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010692e:	6a 00                	push   $0x0
80106930:	68 f9 03 00 00       	push   $0x3f9
80106935:	e8 99 ff ff ff       	call   801068d3 <outb>
8010693a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010693d:	6a 03                	push   $0x3
8010693f:	68 fb 03 00 00       	push   $0x3fb
80106944:	e8 8a ff ff ff       	call   801068d3 <outb>
80106949:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010694c:	6a 00                	push   $0x0
8010694e:	68 fc 03 00 00       	push   $0x3fc
80106953:	e8 7b ff ff ff       	call   801068d3 <outb>
80106958:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010695b:	6a 01                	push   $0x1
8010695d:	68 f9 03 00 00       	push   $0x3f9
80106962:	e8 6c ff ff ff       	call   801068d3 <outb>
80106967:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010696a:	68 fd 03 00 00       	push   $0x3fd
8010696f:	e8 42 ff ff ff       	call   801068b6 <inb>
80106974:	83 c4 04             	add    $0x4,%esp
80106977:	3c ff                	cmp    $0xff,%al
80106979:	74 61                	je     801069dc <uartinit+0xe8>
    return;
  uart = 1;
8010697b:	c7 05 a4 00 11 80 01 	movl   $0x1,0x801100a4
80106982:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106985:	68 fa 03 00 00       	push   $0x3fa
8010698a:	e8 27 ff ff ff       	call   801068b6 <inb>
8010698f:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106992:	68 f8 03 00 00       	push   $0x3f8
80106997:	e8 1a ff ff ff       	call   801068b6 <inb>
8010699c:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010699f:	83 ec 08             	sub    $0x8,%esp
801069a2:	6a 00                	push   $0x0
801069a4:	6a 04                	push   $0x4
801069a6:	e8 59 c2 ff ff       	call   80102c04 <ioapicenable>
801069ab:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069ae:	c7 45 f4 04 ad 10 80 	movl   $0x8010ad04,-0xc(%ebp)
801069b5:	eb 19                	jmp    801069d0 <uartinit+0xdc>
    uartputc(*p);
801069b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ba:	0f b6 00             	movzbl (%eax),%eax
801069bd:	0f be c0             	movsbl %al,%eax
801069c0:	83 ec 0c             	sub    $0xc,%esp
801069c3:	50                   	push   %eax
801069c4:	e8 16 00 00 00       	call   801069df <uartputc>
801069c9:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801069cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d3:	0f b6 00             	movzbl (%eax),%eax
801069d6:	84 c0                	test   %al,%al
801069d8:	75 dd                	jne    801069b7 <uartinit+0xc3>
801069da:	eb 01                	jmp    801069dd <uartinit+0xe9>
    return;
801069dc:	90                   	nop
}
801069dd:	c9                   	leave  
801069de:	c3                   	ret    

801069df <uartputc>:

void
uartputc(int c)
{
801069df:	f3 0f 1e fb          	endbr32 
801069e3:	55                   	push   %ebp
801069e4:	89 e5                	mov    %esp,%ebp
801069e6:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801069e9:	a1 a4 00 11 80       	mov    0x801100a4,%eax
801069ee:	85 c0                	test   %eax,%eax
801069f0:	74 53                	je     80106a45 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801069f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801069f9:	eb 11                	jmp    80106a0c <uartputc+0x2d>
    microdelay(10);
801069fb:	83 ec 0c             	sub    $0xc,%esp
801069fe:	6a 0a                	push   $0xa
80106a00:	e8 37 c7 ff ff       	call   8010313c <microdelay>
80106a05:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a08:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a0c:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a10:	7f 1a                	jg     80106a2c <uartputc+0x4d>
80106a12:	83 ec 0c             	sub    $0xc,%esp
80106a15:	68 fd 03 00 00       	push   $0x3fd
80106a1a:	e8 97 fe ff ff       	call   801068b6 <inb>
80106a1f:	83 c4 10             	add    $0x10,%esp
80106a22:	0f b6 c0             	movzbl %al,%eax
80106a25:	83 e0 20             	and    $0x20,%eax
80106a28:	85 c0                	test   %eax,%eax
80106a2a:	74 cf                	je     801069fb <uartputc+0x1c>
  outb(COM1+0, c);
80106a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a2f:	0f b6 c0             	movzbl %al,%eax
80106a32:	83 ec 08             	sub    $0x8,%esp
80106a35:	50                   	push   %eax
80106a36:	68 f8 03 00 00       	push   $0x3f8
80106a3b:	e8 93 fe ff ff       	call   801068d3 <outb>
80106a40:	83 c4 10             	add    $0x10,%esp
80106a43:	eb 01                	jmp    80106a46 <uartputc+0x67>
    return;
80106a45:	90                   	nop
}
80106a46:	c9                   	leave  
80106a47:	c3                   	ret    

80106a48 <uartgetc>:

static int
uartgetc(void)
{
80106a48:	f3 0f 1e fb          	endbr32 
80106a4c:	55                   	push   %ebp
80106a4d:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106a4f:	a1 a4 00 11 80       	mov    0x801100a4,%eax
80106a54:	85 c0                	test   %eax,%eax
80106a56:	75 07                	jne    80106a5f <uartgetc+0x17>
    return -1;
80106a58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a5d:	eb 2e                	jmp    80106a8d <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106a5f:	68 fd 03 00 00       	push   $0x3fd
80106a64:	e8 4d fe ff ff       	call   801068b6 <inb>
80106a69:	83 c4 04             	add    $0x4,%esp
80106a6c:	0f b6 c0             	movzbl %al,%eax
80106a6f:	83 e0 01             	and    $0x1,%eax
80106a72:	85 c0                	test   %eax,%eax
80106a74:	75 07                	jne    80106a7d <uartgetc+0x35>
    return -1;
80106a76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a7b:	eb 10                	jmp    80106a8d <uartgetc+0x45>
  return inb(COM1+0);
80106a7d:	68 f8 03 00 00       	push   $0x3f8
80106a82:	e8 2f fe ff ff       	call   801068b6 <inb>
80106a87:	83 c4 04             	add    $0x4,%esp
80106a8a:	0f b6 c0             	movzbl %al,%eax
}
80106a8d:	c9                   	leave  
80106a8e:	c3                   	ret    

80106a8f <uartintr>:

void
uartintr(void)
{
80106a8f:	f3 0f 1e fb          	endbr32 
80106a93:	55                   	push   %ebp
80106a94:	89 e5                	mov    %esp,%ebp
80106a96:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106a99:	83 ec 0c             	sub    $0xc,%esp
80106a9c:	68 48 6a 10 80       	push   $0x80106a48
80106aa1:	e8 5a 9d ff ff       	call   80100800 <consoleintr>
80106aa6:	83 c4 10             	add    $0x10,%esp
}
80106aa9:	90                   	nop
80106aaa:	c9                   	leave  
80106aab:	c3                   	ret    

80106aac <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106aac:	6a 00                	push   $0x0
  pushl $0
80106aae:	6a 00                	push   $0x0
  jmp alltraps
80106ab0:	e9 a5 f9 ff ff       	jmp    8010645a <alltraps>

80106ab5 <vector1>:
.globl vector1
vector1:
  pushl $0
80106ab5:	6a 00                	push   $0x0
  pushl $1
80106ab7:	6a 01                	push   $0x1
  jmp alltraps
80106ab9:	e9 9c f9 ff ff       	jmp    8010645a <alltraps>

80106abe <vector2>:
.globl vector2
vector2:
  pushl $0
80106abe:	6a 00                	push   $0x0
  pushl $2
80106ac0:	6a 02                	push   $0x2
  jmp alltraps
80106ac2:	e9 93 f9 ff ff       	jmp    8010645a <alltraps>

80106ac7 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ac7:	6a 00                	push   $0x0
  pushl $3
80106ac9:	6a 03                	push   $0x3
  jmp alltraps
80106acb:	e9 8a f9 ff ff       	jmp    8010645a <alltraps>

80106ad0 <vector4>:
.globl vector4
vector4:
  pushl $0
80106ad0:	6a 00                	push   $0x0
  pushl $4
80106ad2:	6a 04                	push   $0x4
  jmp alltraps
80106ad4:	e9 81 f9 ff ff       	jmp    8010645a <alltraps>

80106ad9 <vector5>:
.globl vector5
vector5:
  pushl $0
80106ad9:	6a 00                	push   $0x0
  pushl $5
80106adb:	6a 05                	push   $0x5
  jmp alltraps
80106add:	e9 78 f9 ff ff       	jmp    8010645a <alltraps>

80106ae2 <vector6>:
.globl vector6
vector6:
  pushl $0
80106ae2:	6a 00                	push   $0x0
  pushl $6
80106ae4:	6a 06                	push   $0x6
  jmp alltraps
80106ae6:	e9 6f f9 ff ff       	jmp    8010645a <alltraps>

80106aeb <vector7>:
.globl vector7
vector7:
  pushl $0
80106aeb:	6a 00                	push   $0x0
  pushl $7
80106aed:	6a 07                	push   $0x7
  jmp alltraps
80106aef:	e9 66 f9 ff ff       	jmp    8010645a <alltraps>

80106af4 <vector8>:
.globl vector8
vector8:
  pushl $8
80106af4:	6a 08                	push   $0x8
  jmp alltraps
80106af6:	e9 5f f9 ff ff       	jmp    8010645a <alltraps>

80106afb <vector9>:
.globl vector9
vector9:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $9
80106afd:	6a 09                	push   $0x9
  jmp alltraps
80106aff:	e9 56 f9 ff ff       	jmp    8010645a <alltraps>

80106b04 <vector10>:
.globl vector10
vector10:
  pushl $10
80106b04:	6a 0a                	push   $0xa
  jmp alltraps
80106b06:	e9 4f f9 ff ff       	jmp    8010645a <alltraps>

80106b0b <vector11>:
.globl vector11
vector11:
  pushl $11
80106b0b:	6a 0b                	push   $0xb
  jmp alltraps
80106b0d:	e9 48 f9 ff ff       	jmp    8010645a <alltraps>

80106b12 <vector12>:
.globl vector12
vector12:
  pushl $12
80106b12:	6a 0c                	push   $0xc
  jmp alltraps
80106b14:	e9 41 f9 ff ff       	jmp    8010645a <alltraps>

80106b19 <vector13>:
.globl vector13
vector13:
  pushl $13
80106b19:	6a 0d                	push   $0xd
  jmp alltraps
80106b1b:	e9 3a f9 ff ff       	jmp    8010645a <alltraps>

80106b20 <vector14>:
.globl vector14
vector14:
  pushl $14
80106b20:	6a 0e                	push   $0xe
  jmp alltraps
80106b22:	e9 33 f9 ff ff       	jmp    8010645a <alltraps>

80106b27 <vector15>:
.globl vector15
vector15:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $15
80106b29:	6a 0f                	push   $0xf
  jmp alltraps
80106b2b:	e9 2a f9 ff ff       	jmp    8010645a <alltraps>

80106b30 <vector16>:
.globl vector16
vector16:
  pushl $0
80106b30:	6a 00                	push   $0x0
  pushl $16
80106b32:	6a 10                	push   $0x10
  jmp alltraps
80106b34:	e9 21 f9 ff ff       	jmp    8010645a <alltraps>

80106b39 <vector17>:
.globl vector17
vector17:
  pushl $17
80106b39:	6a 11                	push   $0x11
  jmp alltraps
80106b3b:	e9 1a f9 ff ff       	jmp    8010645a <alltraps>

80106b40 <vector18>:
.globl vector18
vector18:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $18
80106b42:	6a 12                	push   $0x12
  jmp alltraps
80106b44:	e9 11 f9 ff ff       	jmp    8010645a <alltraps>

80106b49 <vector19>:
.globl vector19
vector19:
  pushl $0
80106b49:	6a 00                	push   $0x0
  pushl $19
80106b4b:	6a 13                	push   $0x13
  jmp alltraps
80106b4d:	e9 08 f9 ff ff       	jmp    8010645a <alltraps>

80106b52 <vector20>:
.globl vector20
vector20:
  pushl $0
80106b52:	6a 00                	push   $0x0
  pushl $20
80106b54:	6a 14                	push   $0x14
  jmp alltraps
80106b56:	e9 ff f8 ff ff       	jmp    8010645a <alltraps>

80106b5b <vector21>:
.globl vector21
vector21:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $21
80106b5d:	6a 15                	push   $0x15
  jmp alltraps
80106b5f:	e9 f6 f8 ff ff       	jmp    8010645a <alltraps>

80106b64 <vector22>:
.globl vector22
vector22:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $22
80106b66:	6a 16                	push   $0x16
  jmp alltraps
80106b68:	e9 ed f8 ff ff       	jmp    8010645a <alltraps>

80106b6d <vector23>:
.globl vector23
vector23:
  pushl $0
80106b6d:	6a 00                	push   $0x0
  pushl $23
80106b6f:	6a 17                	push   $0x17
  jmp alltraps
80106b71:	e9 e4 f8 ff ff       	jmp    8010645a <alltraps>

80106b76 <vector24>:
.globl vector24
vector24:
  pushl $0
80106b76:	6a 00                	push   $0x0
  pushl $24
80106b78:	6a 18                	push   $0x18
  jmp alltraps
80106b7a:	e9 db f8 ff ff       	jmp    8010645a <alltraps>

80106b7f <vector25>:
.globl vector25
vector25:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $25
80106b81:	6a 19                	push   $0x19
  jmp alltraps
80106b83:	e9 d2 f8 ff ff       	jmp    8010645a <alltraps>

80106b88 <vector26>:
.globl vector26
vector26:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $26
80106b8a:	6a 1a                	push   $0x1a
  jmp alltraps
80106b8c:	e9 c9 f8 ff ff       	jmp    8010645a <alltraps>

80106b91 <vector27>:
.globl vector27
vector27:
  pushl $0
80106b91:	6a 00                	push   $0x0
  pushl $27
80106b93:	6a 1b                	push   $0x1b
  jmp alltraps
80106b95:	e9 c0 f8 ff ff       	jmp    8010645a <alltraps>

80106b9a <vector28>:
.globl vector28
vector28:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $28
80106b9c:	6a 1c                	push   $0x1c
  jmp alltraps
80106b9e:	e9 b7 f8 ff ff       	jmp    8010645a <alltraps>

80106ba3 <vector29>:
.globl vector29
vector29:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $29
80106ba5:	6a 1d                	push   $0x1d
  jmp alltraps
80106ba7:	e9 ae f8 ff ff       	jmp    8010645a <alltraps>

80106bac <vector30>:
.globl vector30
vector30:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $30
80106bae:	6a 1e                	push   $0x1e
  jmp alltraps
80106bb0:	e9 a5 f8 ff ff       	jmp    8010645a <alltraps>

80106bb5 <vector31>:
.globl vector31
vector31:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $31
80106bb7:	6a 1f                	push   $0x1f
  jmp alltraps
80106bb9:	e9 9c f8 ff ff       	jmp    8010645a <alltraps>

80106bbe <vector32>:
.globl vector32
vector32:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $32
80106bc0:	6a 20                	push   $0x20
  jmp alltraps
80106bc2:	e9 93 f8 ff ff       	jmp    8010645a <alltraps>

80106bc7 <vector33>:
.globl vector33
vector33:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $33
80106bc9:	6a 21                	push   $0x21
  jmp alltraps
80106bcb:	e9 8a f8 ff ff       	jmp    8010645a <alltraps>

80106bd0 <vector34>:
.globl vector34
vector34:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $34
80106bd2:	6a 22                	push   $0x22
  jmp alltraps
80106bd4:	e9 81 f8 ff ff       	jmp    8010645a <alltraps>

80106bd9 <vector35>:
.globl vector35
vector35:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $35
80106bdb:	6a 23                	push   $0x23
  jmp alltraps
80106bdd:	e9 78 f8 ff ff       	jmp    8010645a <alltraps>

80106be2 <vector36>:
.globl vector36
vector36:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $36
80106be4:	6a 24                	push   $0x24
  jmp alltraps
80106be6:	e9 6f f8 ff ff       	jmp    8010645a <alltraps>

80106beb <vector37>:
.globl vector37
vector37:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $37
80106bed:	6a 25                	push   $0x25
  jmp alltraps
80106bef:	e9 66 f8 ff ff       	jmp    8010645a <alltraps>

80106bf4 <vector38>:
.globl vector38
vector38:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $38
80106bf6:	6a 26                	push   $0x26
  jmp alltraps
80106bf8:	e9 5d f8 ff ff       	jmp    8010645a <alltraps>

80106bfd <vector39>:
.globl vector39
vector39:
  pushl $0
80106bfd:	6a 00                	push   $0x0
  pushl $39
80106bff:	6a 27                	push   $0x27
  jmp alltraps
80106c01:	e9 54 f8 ff ff       	jmp    8010645a <alltraps>

80106c06 <vector40>:
.globl vector40
vector40:
  pushl $0
80106c06:	6a 00                	push   $0x0
  pushl $40
80106c08:	6a 28                	push   $0x28
  jmp alltraps
80106c0a:	e9 4b f8 ff ff       	jmp    8010645a <alltraps>

80106c0f <vector41>:
.globl vector41
vector41:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $41
80106c11:	6a 29                	push   $0x29
  jmp alltraps
80106c13:	e9 42 f8 ff ff       	jmp    8010645a <alltraps>

80106c18 <vector42>:
.globl vector42
vector42:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $42
80106c1a:	6a 2a                	push   $0x2a
  jmp alltraps
80106c1c:	e9 39 f8 ff ff       	jmp    8010645a <alltraps>

80106c21 <vector43>:
.globl vector43
vector43:
  pushl $0
80106c21:	6a 00                	push   $0x0
  pushl $43
80106c23:	6a 2b                	push   $0x2b
  jmp alltraps
80106c25:	e9 30 f8 ff ff       	jmp    8010645a <alltraps>

80106c2a <vector44>:
.globl vector44
vector44:
  pushl $0
80106c2a:	6a 00                	push   $0x0
  pushl $44
80106c2c:	6a 2c                	push   $0x2c
  jmp alltraps
80106c2e:	e9 27 f8 ff ff       	jmp    8010645a <alltraps>

80106c33 <vector45>:
.globl vector45
vector45:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $45
80106c35:	6a 2d                	push   $0x2d
  jmp alltraps
80106c37:	e9 1e f8 ff ff       	jmp    8010645a <alltraps>

80106c3c <vector46>:
.globl vector46
vector46:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $46
80106c3e:	6a 2e                	push   $0x2e
  jmp alltraps
80106c40:	e9 15 f8 ff ff       	jmp    8010645a <alltraps>

80106c45 <vector47>:
.globl vector47
vector47:
  pushl $0
80106c45:	6a 00                	push   $0x0
  pushl $47
80106c47:	6a 2f                	push   $0x2f
  jmp alltraps
80106c49:	e9 0c f8 ff ff       	jmp    8010645a <alltraps>

80106c4e <vector48>:
.globl vector48
vector48:
  pushl $0
80106c4e:	6a 00                	push   $0x0
  pushl $48
80106c50:	6a 30                	push   $0x30
  jmp alltraps
80106c52:	e9 03 f8 ff ff       	jmp    8010645a <alltraps>

80106c57 <vector49>:
.globl vector49
vector49:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $49
80106c59:	6a 31                	push   $0x31
  jmp alltraps
80106c5b:	e9 fa f7 ff ff       	jmp    8010645a <alltraps>

80106c60 <vector50>:
.globl vector50
vector50:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $50
80106c62:	6a 32                	push   $0x32
  jmp alltraps
80106c64:	e9 f1 f7 ff ff       	jmp    8010645a <alltraps>

80106c69 <vector51>:
.globl vector51
vector51:
  pushl $0
80106c69:	6a 00                	push   $0x0
  pushl $51
80106c6b:	6a 33                	push   $0x33
  jmp alltraps
80106c6d:	e9 e8 f7 ff ff       	jmp    8010645a <alltraps>

80106c72 <vector52>:
.globl vector52
vector52:
  pushl $0
80106c72:	6a 00                	push   $0x0
  pushl $52
80106c74:	6a 34                	push   $0x34
  jmp alltraps
80106c76:	e9 df f7 ff ff       	jmp    8010645a <alltraps>

80106c7b <vector53>:
.globl vector53
vector53:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $53
80106c7d:	6a 35                	push   $0x35
  jmp alltraps
80106c7f:	e9 d6 f7 ff ff       	jmp    8010645a <alltraps>

80106c84 <vector54>:
.globl vector54
vector54:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $54
80106c86:	6a 36                	push   $0x36
  jmp alltraps
80106c88:	e9 cd f7 ff ff       	jmp    8010645a <alltraps>

80106c8d <vector55>:
.globl vector55
vector55:
  pushl $0
80106c8d:	6a 00                	push   $0x0
  pushl $55
80106c8f:	6a 37                	push   $0x37
  jmp alltraps
80106c91:	e9 c4 f7 ff ff       	jmp    8010645a <alltraps>

80106c96 <vector56>:
.globl vector56
vector56:
  pushl $0
80106c96:	6a 00                	push   $0x0
  pushl $56
80106c98:	6a 38                	push   $0x38
  jmp alltraps
80106c9a:	e9 bb f7 ff ff       	jmp    8010645a <alltraps>

80106c9f <vector57>:
.globl vector57
vector57:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $57
80106ca1:	6a 39                	push   $0x39
  jmp alltraps
80106ca3:	e9 b2 f7 ff ff       	jmp    8010645a <alltraps>

80106ca8 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $58
80106caa:	6a 3a                	push   $0x3a
  jmp alltraps
80106cac:	e9 a9 f7 ff ff       	jmp    8010645a <alltraps>

80106cb1 <vector59>:
.globl vector59
vector59:
  pushl $0
80106cb1:	6a 00                	push   $0x0
  pushl $59
80106cb3:	6a 3b                	push   $0x3b
  jmp alltraps
80106cb5:	e9 a0 f7 ff ff       	jmp    8010645a <alltraps>

80106cba <vector60>:
.globl vector60
vector60:
  pushl $0
80106cba:	6a 00                	push   $0x0
  pushl $60
80106cbc:	6a 3c                	push   $0x3c
  jmp alltraps
80106cbe:	e9 97 f7 ff ff       	jmp    8010645a <alltraps>

80106cc3 <vector61>:
.globl vector61
vector61:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $61
80106cc5:	6a 3d                	push   $0x3d
  jmp alltraps
80106cc7:	e9 8e f7 ff ff       	jmp    8010645a <alltraps>

80106ccc <vector62>:
.globl vector62
vector62:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $62
80106cce:	6a 3e                	push   $0x3e
  jmp alltraps
80106cd0:	e9 85 f7 ff ff       	jmp    8010645a <alltraps>

80106cd5 <vector63>:
.globl vector63
vector63:
  pushl $0
80106cd5:	6a 00                	push   $0x0
  pushl $63
80106cd7:	6a 3f                	push   $0x3f
  jmp alltraps
80106cd9:	e9 7c f7 ff ff       	jmp    8010645a <alltraps>

80106cde <vector64>:
.globl vector64
vector64:
  pushl $0
80106cde:	6a 00                	push   $0x0
  pushl $64
80106ce0:	6a 40                	push   $0x40
  jmp alltraps
80106ce2:	e9 73 f7 ff ff       	jmp    8010645a <alltraps>

80106ce7 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $65
80106ce9:	6a 41                	push   $0x41
  jmp alltraps
80106ceb:	e9 6a f7 ff ff       	jmp    8010645a <alltraps>

80106cf0 <vector66>:
.globl vector66
vector66:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $66
80106cf2:	6a 42                	push   $0x42
  jmp alltraps
80106cf4:	e9 61 f7 ff ff       	jmp    8010645a <alltraps>

80106cf9 <vector67>:
.globl vector67
vector67:
  pushl $0
80106cf9:	6a 00                	push   $0x0
  pushl $67
80106cfb:	6a 43                	push   $0x43
  jmp alltraps
80106cfd:	e9 58 f7 ff ff       	jmp    8010645a <alltraps>

80106d02 <vector68>:
.globl vector68
vector68:
  pushl $0
80106d02:	6a 00                	push   $0x0
  pushl $68
80106d04:	6a 44                	push   $0x44
  jmp alltraps
80106d06:	e9 4f f7 ff ff       	jmp    8010645a <alltraps>

80106d0b <vector69>:
.globl vector69
vector69:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $69
80106d0d:	6a 45                	push   $0x45
  jmp alltraps
80106d0f:	e9 46 f7 ff ff       	jmp    8010645a <alltraps>

80106d14 <vector70>:
.globl vector70
vector70:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $70
80106d16:	6a 46                	push   $0x46
  jmp alltraps
80106d18:	e9 3d f7 ff ff       	jmp    8010645a <alltraps>

80106d1d <vector71>:
.globl vector71
vector71:
  pushl $0
80106d1d:	6a 00                	push   $0x0
  pushl $71
80106d1f:	6a 47                	push   $0x47
  jmp alltraps
80106d21:	e9 34 f7 ff ff       	jmp    8010645a <alltraps>

80106d26 <vector72>:
.globl vector72
vector72:
  pushl $0
80106d26:	6a 00                	push   $0x0
  pushl $72
80106d28:	6a 48                	push   $0x48
  jmp alltraps
80106d2a:	e9 2b f7 ff ff       	jmp    8010645a <alltraps>

80106d2f <vector73>:
.globl vector73
vector73:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $73
80106d31:	6a 49                	push   $0x49
  jmp alltraps
80106d33:	e9 22 f7 ff ff       	jmp    8010645a <alltraps>

80106d38 <vector74>:
.globl vector74
vector74:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $74
80106d3a:	6a 4a                	push   $0x4a
  jmp alltraps
80106d3c:	e9 19 f7 ff ff       	jmp    8010645a <alltraps>

80106d41 <vector75>:
.globl vector75
vector75:
  pushl $0
80106d41:	6a 00                	push   $0x0
  pushl $75
80106d43:	6a 4b                	push   $0x4b
  jmp alltraps
80106d45:	e9 10 f7 ff ff       	jmp    8010645a <alltraps>

80106d4a <vector76>:
.globl vector76
vector76:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $76
80106d4c:	6a 4c                	push   $0x4c
  jmp alltraps
80106d4e:	e9 07 f7 ff ff       	jmp    8010645a <alltraps>

80106d53 <vector77>:
.globl vector77
vector77:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $77
80106d55:	6a 4d                	push   $0x4d
  jmp alltraps
80106d57:	e9 fe f6 ff ff       	jmp    8010645a <alltraps>

80106d5c <vector78>:
.globl vector78
vector78:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $78
80106d5e:	6a 4e                	push   $0x4e
  jmp alltraps
80106d60:	e9 f5 f6 ff ff       	jmp    8010645a <alltraps>

80106d65 <vector79>:
.globl vector79
vector79:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $79
80106d67:	6a 4f                	push   $0x4f
  jmp alltraps
80106d69:	e9 ec f6 ff ff       	jmp    8010645a <alltraps>

80106d6e <vector80>:
.globl vector80
vector80:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $80
80106d70:	6a 50                	push   $0x50
  jmp alltraps
80106d72:	e9 e3 f6 ff ff       	jmp    8010645a <alltraps>

80106d77 <vector81>:
.globl vector81
vector81:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $81
80106d79:	6a 51                	push   $0x51
  jmp alltraps
80106d7b:	e9 da f6 ff ff       	jmp    8010645a <alltraps>

80106d80 <vector82>:
.globl vector82
vector82:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $82
80106d82:	6a 52                	push   $0x52
  jmp alltraps
80106d84:	e9 d1 f6 ff ff       	jmp    8010645a <alltraps>

80106d89 <vector83>:
.globl vector83
vector83:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $83
80106d8b:	6a 53                	push   $0x53
  jmp alltraps
80106d8d:	e9 c8 f6 ff ff       	jmp    8010645a <alltraps>

80106d92 <vector84>:
.globl vector84
vector84:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $84
80106d94:	6a 54                	push   $0x54
  jmp alltraps
80106d96:	e9 bf f6 ff ff       	jmp    8010645a <alltraps>

80106d9b <vector85>:
.globl vector85
vector85:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $85
80106d9d:	6a 55                	push   $0x55
  jmp alltraps
80106d9f:	e9 b6 f6 ff ff       	jmp    8010645a <alltraps>

80106da4 <vector86>:
.globl vector86
vector86:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $86
80106da6:	6a 56                	push   $0x56
  jmp alltraps
80106da8:	e9 ad f6 ff ff       	jmp    8010645a <alltraps>

80106dad <vector87>:
.globl vector87
vector87:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $87
80106daf:	6a 57                	push   $0x57
  jmp alltraps
80106db1:	e9 a4 f6 ff ff       	jmp    8010645a <alltraps>

80106db6 <vector88>:
.globl vector88
vector88:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $88
80106db8:	6a 58                	push   $0x58
  jmp alltraps
80106dba:	e9 9b f6 ff ff       	jmp    8010645a <alltraps>

80106dbf <vector89>:
.globl vector89
vector89:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $89
80106dc1:	6a 59                	push   $0x59
  jmp alltraps
80106dc3:	e9 92 f6 ff ff       	jmp    8010645a <alltraps>

80106dc8 <vector90>:
.globl vector90
vector90:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $90
80106dca:	6a 5a                	push   $0x5a
  jmp alltraps
80106dcc:	e9 89 f6 ff ff       	jmp    8010645a <alltraps>

80106dd1 <vector91>:
.globl vector91
vector91:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $91
80106dd3:	6a 5b                	push   $0x5b
  jmp alltraps
80106dd5:	e9 80 f6 ff ff       	jmp    8010645a <alltraps>

80106dda <vector92>:
.globl vector92
vector92:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $92
80106ddc:	6a 5c                	push   $0x5c
  jmp alltraps
80106dde:	e9 77 f6 ff ff       	jmp    8010645a <alltraps>

80106de3 <vector93>:
.globl vector93
vector93:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $93
80106de5:	6a 5d                	push   $0x5d
  jmp alltraps
80106de7:	e9 6e f6 ff ff       	jmp    8010645a <alltraps>

80106dec <vector94>:
.globl vector94
vector94:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $94
80106dee:	6a 5e                	push   $0x5e
  jmp alltraps
80106df0:	e9 65 f6 ff ff       	jmp    8010645a <alltraps>

80106df5 <vector95>:
.globl vector95
vector95:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $95
80106df7:	6a 5f                	push   $0x5f
  jmp alltraps
80106df9:	e9 5c f6 ff ff       	jmp    8010645a <alltraps>

80106dfe <vector96>:
.globl vector96
vector96:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $96
80106e00:	6a 60                	push   $0x60
  jmp alltraps
80106e02:	e9 53 f6 ff ff       	jmp    8010645a <alltraps>

80106e07 <vector97>:
.globl vector97
vector97:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $97
80106e09:	6a 61                	push   $0x61
  jmp alltraps
80106e0b:	e9 4a f6 ff ff       	jmp    8010645a <alltraps>

80106e10 <vector98>:
.globl vector98
vector98:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $98
80106e12:	6a 62                	push   $0x62
  jmp alltraps
80106e14:	e9 41 f6 ff ff       	jmp    8010645a <alltraps>

80106e19 <vector99>:
.globl vector99
vector99:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $99
80106e1b:	6a 63                	push   $0x63
  jmp alltraps
80106e1d:	e9 38 f6 ff ff       	jmp    8010645a <alltraps>

80106e22 <vector100>:
.globl vector100
vector100:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $100
80106e24:	6a 64                	push   $0x64
  jmp alltraps
80106e26:	e9 2f f6 ff ff       	jmp    8010645a <alltraps>

80106e2b <vector101>:
.globl vector101
vector101:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $101
80106e2d:	6a 65                	push   $0x65
  jmp alltraps
80106e2f:	e9 26 f6 ff ff       	jmp    8010645a <alltraps>

80106e34 <vector102>:
.globl vector102
vector102:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $102
80106e36:	6a 66                	push   $0x66
  jmp alltraps
80106e38:	e9 1d f6 ff ff       	jmp    8010645a <alltraps>

80106e3d <vector103>:
.globl vector103
vector103:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $103
80106e3f:	6a 67                	push   $0x67
  jmp alltraps
80106e41:	e9 14 f6 ff ff       	jmp    8010645a <alltraps>

80106e46 <vector104>:
.globl vector104
vector104:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $104
80106e48:	6a 68                	push   $0x68
  jmp alltraps
80106e4a:	e9 0b f6 ff ff       	jmp    8010645a <alltraps>

80106e4f <vector105>:
.globl vector105
vector105:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $105
80106e51:	6a 69                	push   $0x69
  jmp alltraps
80106e53:	e9 02 f6 ff ff       	jmp    8010645a <alltraps>

80106e58 <vector106>:
.globl vector106
vector106:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $106
80106e5a:	6a 6a                	push   $0x6a
  jmp alltraps
80106e5c:	e9 f9 f5 ff ff       	jmp    8010645a <alltraps>

80106e61 <vector107>:
.globl vector107
vector107:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $107
80106e63:	6a 6b                	push   $0x6b
  jmp alltraps
80106e65:	e9 f0 f5 ff ff       	jmp    8010645a <alltraps>

80106e6a <vector108>:
.globl vector108
vector108:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $108
80106e6c:	6a 6c                	push   $0x6c
  jmp alltraps
80106e6e:	e9 e7 f5 ff ff       	jmp    8010645a <alltraps>

80106e73 <vector109>:
.globl vector109
vector109:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $109
80106e75:	6a 6d                	push   $0x6d
  jmp alltraps
80106e77:	e9 de f5 ff ff       	jmp    8010645a <alltraps>

80106e7c <vector110>:
.globl vector110
vector110:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $110
80106e7e:	6a 6e                	push   $0x6e
  jmp alltraps
80106e80:	e9 d5 f5 ff ff       	jmp    8010645a <alltraps>

80106e85 <vector111>:
.globl vector111
vector111:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $111
80106e87:	6a 6f                	push   $0x6f
  jmp alltraps
80106e89:	e9 cc f5 ff ff       	jmp    8010645a <alltraps>

80106e8e <vector112>:
.globl vector112
vector112:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $112
80106e90:	6a 70                	push   $0x70
  jmp alltraps
80106e92:	e9 c3 f5 ff ff       	jmp    8010645a <alltraps>

80106e97 <vector113>:
.globl vector113
vector113:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $113
80106e99:	6a 71                	push   $0x71
  jmp alltraps
80106e9b:	e9 ba f5 ff ff       	jmp    8010645a <alltraps>

80106ea0 <vector114>:
.globl vector114
vector114:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $114
80106ea2:	6a 72                	push   $0x72
  jmp alltraps
80106ea4:	e9 b1 f5 ff ff       	jmp    8010645a <alltraps>

80106ea9 <vector115>:
.globl vector115
vector115:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $115
80106eab:	6a 73                	push   $0x73
  jmp alltraps
80106ead:	e9 a8 f5 ff ff       	jmp    8010645a <alltraps>

80106eb2 <vector116>:
.globl vector116
vector116:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $116
80106eb4:	6a 74                	push   $0x74
  jmp alltraps
80106eb6:	e9 9f f5 ff ff       	jmp    8010645a <alltraps>

80106ebb <vector117>:
.globl vector117
vector117:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $117
80106ebd:	6a 75                	push   $0x75
  jmp alltraps
80106ebf:	e9 96 f5 ff ff       	jmp    8010645a <alltraps>

80106ec4 <vector118>:
.globl vector118
vector118:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $118
80106ec6:	6a 76                	push   $0x76
  jmp alltraps
80106ec8:	e9 8d f5 ff ff       	jmp    8010645a <alltraps>

80106ecd <vector119>:
.globl vector119
vector119:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $119
80106ecf:	6a 77                	push   $0x77
  jmp alltraps
80106ed1:	e9 84 f5 ff ff       	jmp    8010645a <alltraps>

80106ed6 <vector120>:
.globl vector120
vector120:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $120
80106ed8:	6a 78                	push   $0x78
  jmp alltraps
80106eda:	e9 7b f5 ff ff       	jmp    8010645a <alltraps>

80106edf <vector121>:
.globl vector121
vector121:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $121
80106ee1:	6a 79                	push   $0x79
  jmp alltraps
80106ee3:	e9 72 f5 ff ff       	jmp    8010645a <alltraps>

80106ee8 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $122
80106eea:	6a 7a                	push   $0x7a
  jmp alltraps
80106eec:	e9 69 f5 ff ff       	jmp    8010645a <alltraps>

80106ef1 <vector123>:
.globl vector123
vector123:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $123
80106ef3:	6a 7b                	push   $0x7b
  jmp alltraps
80106ef5:	e9 60 f5 ff ff       	jmp    8010645a <alltraps>

80106efa <vector124>:
.globl vector124
vector124:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $124
80106efc:	6a 7c                	push   $0x7c
  jmp alltraps
80106efe:	e9 57 f5 ff ff       	jmp    8010645a <alltraps>

80106f03 <vector125>:
.globl vector125
vector125:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $125
80106f05:	6a 7d                	push   $0x7d
  jmp alltraps
80106f07:	e9 4e f5 ff ff       	jmp    8010645a <alltraps>

80106f0c <vector126>:
.globl vector126
vector126:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $126
80106f0e:	6a 7e                	push   $0x7e
  jmp alltraps
80106f10:	e9 45 f5 ff ff       	jmp    8010645a <alltraps>

80106f15 <vector127>:
.globl vector127
vector127:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $127
80106f17:	6a 7f                	push   $0x7f
  jmp alltraps
80106f19:	e9 3c f5 ff ff       	jmp    8010645a <alltraps>

80106f1e <vector128>:
.globl vector128
vector128:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $128
80106f20:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f25:	e9 30 f5 ff ff       	jmp    8010645a <alltraps>

80106f2a <vector129>:
.globl vector129
vector129:
  pushl $0
80106f2a:	6a 00                	push   $0x0
  pushl $129
80106f2c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f31:	e9 24 f5 ff ff       	jmp    8010645a <alltraps>

80106f36 <vector130>:
.globl vector130
vector130:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $130
80106f38:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106f3d:	e9 18 f5 ff ff       	jmp    8010645a <alltraps>

80106f42 <vector131>:
.globl vector131
vector131:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $131
80106f44:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f49:	e9 0c f5 ff ff       	jmp    8010645a <alltraps>

80106f4e <vector132>:
.globl vector132
vector132:
  pushl $0
80106f4e:	6a 00                	push   $0x0
  pushl $132
80106f50:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106f55:	e9 00 f5 ff ff       	jmp    8010645a <alltraps>

80106f5a <vector133>:
.globl vector133
vector133:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $133
80106f5c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106f61:	e9 f4 f4 ff ff       	jmp    8010645a <alltraps>

80106f66 <vector134>:
.globl vector134
vector134:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $134
80106f68:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f6d:	e9 e8 f4 ff ff       	jmp    8010645a <alltraps>

80106f72 <vector135>:
.globl vector135
vector135:
  pushl $0
80106f72:	6a 00                	push   $0x0
  pushl $135
80106f74:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106f79:	e9 dc f4 ff ff       	jmp    8010645a <alltraps>

80106f7e <vector136>:
.globl vector136
vector136:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $136
80106f80:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106f85:	e9 d0 f4 ff ff       	jmp    8010645a <alltraps>

80106f8a <vector137>:
.globl vector137
vector137:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $137
80106f8c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106f91:	e9 c4 f4 ff ff       	jmp    8010645a <alltraps>

80106f96 <vector138>:
.globl vector138
vector138:
  pushl $0
80106f96:	6a 00                	push   $0x0
  pushl $138
80106f98:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106f9d:	e9 b8 f4 ff ff       	jmp    8010645a <alltraps>

80106fa2 <vector139>:
.globl vector139
vector139:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $139
80106fa4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106fa9:	e9 ac f4 ff ff       	jmp    8010645a <alltraps>

80106fae <vector140>:
.globl vector140
vector140:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $140
80106fb0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106fb5:	e9 a0 f4 ff ff       	jmp    8010645a <alltraps>

80106fba <vector141>:
.globl vector141
vector141:
  pushl $0
80106fba:	6a 00                	push   $0x0
  pushl $141
80106fbc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106fc1:	e9 94 f4 ff ff       	jmp    8010645a <alltraps>

80106fc6 <vector142>:
.globl vector142
vector142:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $142
80106fc8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106fcd:	e9 88 f4 ff ff       	jmp    8010645a <alltraps>

80106fd2 <vector143>:
.globl vector143
vector143:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $143
80106fd4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106fd9:	e9 7c f4 ff ff       	jmp    8010645a <alltraps>

80106fde <vector144>:
.globl vector144
vector144:
  pushl $0
80106fde:	6a 00                	push   $0x0
  pushl $144
80106fe0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106fe5:	e9 70 f4 ff ff       	jmp    8010645a <alltraps>

80106fea <vector145>:
.globl vector145
vector145:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $145
80106fec:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106ff1:	e9 64 f4 ff ff       	jmp    8010645a <alltraps>

80106ff6 <vector146>:
.globl vector146
vector146:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $146
80106ff8:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106ffd:	e9 58 f4 ff ff       	jmp    8010645a <alltraps>

80107002 <vector147>:
.globl vector147
vector147:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $147
80107004:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107009:	e9 4c f4 ff ff       	jmp    8010645a <alltraps>

8010700e <vector148>:
.globl vector148
vector148:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $148
80107010:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107015:	e9 40 f4 ff ff       	jmp    8010645a <alltraps>

8010701a <vector149>:
.globl vector149
vector149:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $149
8010701c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107021:	e9 34 f4 ff ff       	jmp    8010645a <alltraps>

80107026 <vector150>:
.globl vector150
vector150:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $150
80107028:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010702d:	e9 28 f4 ff ff       	jmp    8010645a <alltraps>

80107032 <vector151>:
.globl vector151
vector151:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $151
80107034:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107039:	e9 1c f4 ff ff       	jmp    8010645a <alltraps>

8010703e <vector152>:
.globl vector152
vector152:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $152
80107040:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107045:	e9 10 f4 ff ff       	jmp    8010645a <alltraps>

8010704a <vector153>:
.globl vector153
vector153:
  pushl $0
8010704a:	6a 00                	push   $0x0
  pushl $153
8010704c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107051:	e9 04 f4 ff ff       	jmp    8010645a <alltraps>

80107056 <vector154>:
.globl vector154
vector154:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $154
80107058:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010705d:	e9 f8 f3 ff ff       	jmp    8010645a <alltraps>

80107062 <vector155>:
.globl vector155
vector155:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $155
80107064:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107069:	e9 ec f3 ff ff       	jmp    8010645a <alltraps>

8010706e <vector156>:
.globl vector156
vector156:
  pushl $0
8010706e:	6a 00                	push   $0x0
  pushl $156
80107070:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107075:	e9 e0 f3 ff ff       	jmp    8010645a <alltraps>

8010707a <vector157>:
.globl vector157
vector157:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $157
8010707c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107081:	e9 d4 f3 ff ff       	jmp    8010645a <alltraps>

80107086 <vector158>:
.globl vector158
vector158:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $158
80107088:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010708d:	e9 c8 f3 ff ff       	jmp    8010645a <alltraps>

80107092 <vector159>:
.globl vector159
vector159:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $159
80107094:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107099:	e9 bc f3 ff ff       	jmp    8010645a <alltraps>

8010709e <vector160>:
.globl vector160
vector160:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $160
801070a0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801070a5:	e9 b0 f3 ff ff       	jmp    8010645a <alltraps>

801070aa <vector161>:
.globl vector161
vector161:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $161
801070ac:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801070b1:	e9 a4 f3 ff ff       	jmp    8010645a <alltraps>

801070b6 <vector162>:
.globl vector162
vector162:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $162
801070b8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801070bd:	e9 98 f3 ff ff       	jmp    8010645a <alltraps>

801070c2 <vector163>:
.globl vector163
vector163:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $163
801070c4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801070c9:	e9 8c f3 ff ff       	jmp    8010645a <alltraps>

801070ce <vector164>:
.globl vector164
vector164:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $164
801070d0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801070d5:	e9 80 f3 ff ff       	jmp    8010645a <alltraps>

801070da <vector165>:
.globl vector165
vector165:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $165
801070dc:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801070e1:	e9 74 f3 ff ff       	jmp    8010645a <alltraps>

801070e6 <vector166>:
.globl vector166
vector166:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $166
801070e8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801070ed:	e9 68 f3 ff ff       	jmp    8010645a <alltraps>

801070f2 <vector167>:
.globl vector167
vector167:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $167
801070f4:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801070f9:	e9 5c f3 ff ff       	jmp    8010645a <alltraps>

801070fe <vector168>:
.globl vector168
vector168:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $168
80107100:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107105:	e9 50 f3 ff ff       	jmp    8010645a <alltraps>

8010710a <vector169>:
.globl vector169
vector169:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $169
8010710c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107111:	e9 44 f3 ff ff       	jmp    8010645a <alltraps>

80107116 <vector170>:
.globl vector170
vector170:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $170
80107118:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010711d:	e9 38 f3 ff ff       	jmp    8010645a <alltraps>

80107122 <vector171>:
.globl vector171
vector171:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $171
80107124:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107129:	e9 2c f3 ff ff       	jmp    8010645a <alltraps>

8010712e <vector172>:
.globl vector172
vector172:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $172
80107130:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107135:	e9 20 f3 ff ff       	jmp    8010645a <alltraps>

8010713a <vector173>:
.globl vector173
vector173:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $173
8010713c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107141:	e9 14 f3 ff ff       	jmp    8010645a <alltraps>

80107146 <vector174>:
.globl vector174
vector174:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $174
80107148:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010714d:	e9 08 f3 ff ff       	jmp    8010645a <alltraps>

80107152 <vector175>:
.globl vector175
vector175:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $175
80107154:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107159:	e9 fc f2 ff ff       	jmp    8010645a <alltraps>

8010715e <vector176>:
.globl vector176
vector176:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $176
80107160:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107165:	e9 f0 f2 ff ff       	jmp    8010645a <alltraps>

8010716a <vector177>:
.globl vector177
vector177:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $177
8010716c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107171:	e9 e4 f2 ff ff       	jmp    8010645a <alltraps>

80107176 <vector178>:
.globl vector178
vector178:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $178
80107178:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010717d:	e9 d8 f2 ff ff       	jmp    8010645a <alltraps>

80107182 <vector179>:
.globl vector179
vector179:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $179
80107184:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107189:	e9 cc f2 ff ff       	jmp    8010645a <alltraps>

8010718e <vector180>:
.globl vector180
vector180:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $180
80107190:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107195:	e9 c0 f2 ff ff       	jmp    8010645a <alltraps>

8010719a <vector181>:
.globl vector181
vector181:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $181
8010719c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801071a1:	e9 b4 f2 ff ff       	jmp    8010645a <alltraps>

801071a6 <vector182>:
.globl vector182
vector182:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $182
801071a8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801071ad:	e9 a8 f2 ff ff       	jmp    8010645a <alltraps>

801071b2 <vector183>:
.globl vector183
vector183:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $183
801071b4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801071b9:	e9 9c f2 ff ff       	jmp    8010645a <alltraps>

801071be <vector184>:
.globl vector184
vector184:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $184
801071c0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801071c5:	e9 90 f2 ff ff       	jmp    8010645a <alltraps>

801071ca <vector185>:
.globl vector185
vector185:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $185
801071cc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801071d1:	e9 84 f2 ff ff       	jmp    8010645a <alltraps>

801071d6 <vector186>:
.globl vector186
vector186:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $186
801071d8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801071dd:	e9 78 f2 ff ff       	jmp    8010645a <alltraps>

801071e2 <vector187>:
.globl vector187
vector187:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $187
801071e4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801071e9:	e9 6c f2 ff ff       	jmp    8010645a <alltraps>

801071ee <vector188>:
.globl vector188
vector188:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $188
801071f0:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801071f5:	e9 60 f2 ff ff       	jmp    8010645a <alltraps>

801071fa <vector189>:
.globl vector189
vector189:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $189
801071fc:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107201:	e9 54 f2 ff ff       	jmp    8010645a <alltraps>

80107206 <vector190>:
.globl vector190
vector190:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $190
80107208:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010720d:	e9 48 f2 ff ff       	jmp    8010645a <alltraps>

80107212 <vector191>:
.globl vector191
vector191:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $191
80107214:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107219:	e9 3c f2 ff ff       	jmp    8010645a <alltraps>

8010721e <vector192>:
.globl vector192
vector192:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $192
80107220:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107225:	e9 30 f2 ff ff       	jmp    8010645a <alltraps>

8010722a <vector193>:
.globl vector193
vector193:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $193
8010722c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107231:	e9 24 f2 ff ff       	jmp    8010645a <alltraps>

80107236 <vector194>:
.globl vector194
vector194:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $194
80107238:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010723d:	e9 18 f2 ff ff       	jmp    8010645a <alltraps>

80107242 <vector195>:
.globl vector195
vector195:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $195
80107244:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107249:	e9 0c f2 ff ff       	jmp    8010645a <alltraps>

8010724e <vector196>:
.globl vector196
vector196:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $196
80107250:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107255:	e9 00 f2 ff ff       	jmp    8010645a <alltraps>

8010725a <vector197>:
.globl vector197
vector197:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $197
8010725c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107261:	e9 f4 f1 ff ff       	jmp    8010645a <alltraps>

80107266 <vector198>:
.globl vector198
vector198:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $198
80107268:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010726d:	e9 e8 f1 ff ff       	jmp    8010645a <alltraps>

80107272 <vector199>:
.globl vector199
vector199:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $199
80107274:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107279:	e9 dc f1 ff ff       	jmp    8010645a <alltraps>

8010727e <vector200>:
.globl vector200
vector200:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $200
80107280:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107285:	e9 d0 f1 ff ff       	jmp    8010645a <alltraps>

8010728a <vector201>:
.globl vector201
vector201:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $201
8010728c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107291:	e9 c4 f1 ff ff       	jmp    8010645a <alltraps>

80107296 <vector202>:
.globl vector202
vector202:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $202
80107298:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010729d:	e9 b8 f1 ff ff       	jmp    8010645a <alltraps>

801072a2 <vector203>:
.globl vector203
vector203:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $203
801072a4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801072a9:	e9 ac f1 ff ff       	jmp    8010645a <alltraps>

801072ae <vector204>:
.globl vector204
vector204:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $204
801072b0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801072b5:	e9 a0 f1 ff ff       	jmp    8010645a <alltraps>

801072ba <vector205>:
.globl vector205
vector205:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $205
801072bc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801072c1:	e9 94 f1 ff ff       	jmp    8010645a <alltraps>

801072c6 <vector206>:
.globl vector206
vector206:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $206
801072c8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801072cd:	e9 88 f1 ff ff       	jmp    8010645a <alltraps>

801072d2 <vector207>:
.globl vector207
vector207:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $207
801072d4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801072d9:	e9 7c f1 ff ff       	jmp    8010645a <alltraps>

801072de <vector208>:
.globl vector208
vector208:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $208
801072e0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801072e5:	e9 70 f1 ff ff       	jmp    8010645a <alltraps>

801072ea <vector209>:
.globl vector209
vector209:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $209
801072ec:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801072f1:	e9 64 f1 ff ff       	jmp    8010645a <alltraps>

801072f6 <vector210>:
.globl vector210
vector210:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $210
801072f8:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801072fd:	e9 58 f1 ff ff       	jmp    8010645a <alltraps>

80107302 <vector211>:
.globl vector211
vector211:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $211
80107304:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107309:	e9 4c f1 ff ff       	jmp    8010645a <alltraps>

8010730e <vector212>:
.globl vector212
vector212:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $212
80107310:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107315:	e9 40 f1 ff ff       	jmp    8010645a <alltraps>

8010731a <vector213>:
.globl vector213
vector213:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $213
8010731c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107321:	e9 34 f1 ff ff       	jmp    8010645a <alltraps>

80107326 <vector214>:
.globl vector214
vector214:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $214
80107328:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010732d:	e9 28 f1 ff ff       	jmp    8010645a <alltraps>

80107332 <vector215>:
.globl vector215
vector215:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $215
80107334:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107339:	e9 1c f1 ff ff       	jmp    8010645a <alltraps>

8010733e <vector216>:
.globl vector216
vector216:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $216
80107340:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107345:	e9 10 f1 ff ff       	jmp    8010645a <alltraps>

8010734a <vector217>:
.globl vector217
vector217:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $217
8010734c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107351:	e9 04 f1 ff ff       	jmp    8010645a <alltraps>

80107356 <vector218>:
.globl vector218
vector218:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $218
80107358:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010735d:	e9 f8 f0 ff ff       	jmp    8010645a <alltraps>

80107362 <vector219>:
.globl vector219
vector219:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $219
80107364:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107369:	e9 ec f0 ff ff       	jmp    8010645a <alltraps>

8010736e <vector220>:
.globl vector220
vector220:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $220
80107370:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107375:	e9 e0 f0 ff ff       	jmp    8010645a <alltraps>

8010737a <vector221>:
.globl vector221
vector221:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $221
8010737c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107381:	e9 d4 f0 ff ff       	jmp    8010645a <alltraps>

80107386 <vector222>:
.globl vector222
vector222:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $222
80107388:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010738d:	e9 c8 f0 ff ff       	jmp    8010645a <alltraps>

80107392 <vector223>:
.globl vector223
vector223:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $223
80107394:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107399:	e9 bc f0 ff ff       	jmp    8010645a <alltraps>

8010739e <vector224>:
.globl vector224
vector224:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $224
801073a0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801073a5:	e9 b0 f0 ff ff       	jmp    8010645a <alltraps>

801073aa <vector225>:
.globl vector225
vector225:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $225
801073ac:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801073b1:	e9 a4 f0 ff ff       	jmp    8010645a <alltraps>

801073b6 <vector226>:
.globl vector226
vector226:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $226
801073b8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801073bd:	e9 98 f0 ff ff       	jmp    8010645a <alltraps>

801073c2 <vector227>:
.globl vector227
vector227:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $227
801073c4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801073c9:	e9 8c f0 ff ff       	jmp    8010645a <alltraps>

801073ce <vector228>:
.globl vector228
vector228:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $228
801073d0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801073d5:	e9 80 f0 ff ff       	jmp    8010645a <alltraps>

801073da <vector229>:
.globl vector229
vector229:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $229
801073dc:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801073e1:	e9 74 f0 ff ff       	jmp    8010645a <alltraps>

801073e6 <vector230>:
.globl vector230
vector230:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $230
801073e8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801073ed:	e9 68 f0 ff ff       	jmp    8010645a <alltraps>

801073f2 <vector231>:
.globl vector231
vector231:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $231
801073f4:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801073f9:	e9 5c f0 ff ff       	jmp    8010645a <alltraps>

801073fe <vector232>:
.globl vector232
vector232:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $232
80107400:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107405:	e9 50 f0 ff ff       	jmp    8010645a <alltraps>

8010740a <vector233>:
.globl vector233
vector233:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $233
8010740c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107411:	e9 44 f0 ff ff       	jmp    8010645a <alltraps>

80107416 <vector234>:
.globl vector234
vector234:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $234
80107418:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010741d:	e9 38 f0 ff ff       	jmp    8010645a <alltraps>

80107422 <vector235>:
.globl vector235
vector235:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $235
80107424:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107429:	e9 2c f0 ff ff       	jmp    8010645a <alltraps>

8010742e <vector236>:
.globl vector236
vector236:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $236
80107430:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107435:	e9 20 f0 ff ff       	jmp    8010645a <alltraps>

8010743a <vector237>:
.globl vector237
vector237:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $237
8010743c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107441:	e9 14 f0 ff ff       	jmp    8010645a <alltraps>

80107446 <vector238>:
.globl vector238
vector238:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $238
80107448:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010744d:	e9 08 f0 ff ff       	jmp    8010645a <alltraps>

80107452 <vector239>:
.globl vector239
vector239:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $239
80107454:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107459:	e9 fc ef ff ff       	jmp    8010645a <alltraps>

8010745e <vector240>:
.globl vector240
vector240:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $240
80107460:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107465:	e9 f0 ef ff ff       	jmp    8010645a <alltraps>

8010746a <vector241>:
.globl vector241
vector241:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $241
8010746c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107471:	e9 e4 ef ff ff       	jmp    8010645a <alltraps>

80107476 <vector242>:
.globl vector242
vector242:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $242
80107478:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010747d:	e9 d8 ef ff ff       	jmp    8010645a <alltraps>

80107482 <vector243>:
.globl vector243
vector243:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $243
80107484:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107489:	e9 cc ef ff ff       	jmp    8010645a <alltraps>

8010748e <vector244>:
.globl vector244
vector244:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $244
80107490:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107495:	e9 c0 ef ff ff       	jmp    8010645a <alltraps>

8010749a <vector245>:
.globl vector245
vector245:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $245
8010749c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801074a1:	e9 b4 ef ff ff       	jmp    8010645a <alltraps>

801074a6 <vector246>:
.globl vector246
vector246:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $246
801074a8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801074ad:	e9 a8 ef ff ff       	jmp    8010645a <alltraps>

801074b2 <vector247>:
.globl vector247
vector247:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $247
801074b4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801074b9:	e9 9c ef ff ff       	jmp    8010645a <alltraps>

801074be <vector248>:
.globl vector248
vector248:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $248
801074c0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801074c5:	e9 90 ef ff ff       	jmp    8010645a <alltraps>

801074ca <vector249>:
.globl vector249
vector249:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $249
801074cc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801074d1:	e9 84 ef ff ff       	jmp    8010645a <alltraps>

801074d6 <vector250>:
.globl vector250
vector250:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $250
801074d8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801074dd:	e9 78 ef ff ff       	jmp    8010645a <alltraps>

801074e2 <vector251>:
.globl vector251
vector251:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $251
801074e4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801074e9:	e9 6c ef ff ff       	jmp    8010645a <alltraps>

801074ee <vector252>:
.globl vector252
vector252:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $252
801074f0:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801074f5:	e9 60 ef ff ff       	jmp    8010645a <alltraps>

801074fa <vector253>:
.globl vector253
vector253:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $253
801074fc:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107501:	e9 54 ef ff ff       	jmp    8010645a <alltraps>

80107506 <vector254>:
.globl vector254
vector254:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $254
80107508:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010750d:	e9 48 ef ff ff       	jmp    8010645a <alltraps>

80107512 <vector255>:
.globl vector255
vector255:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $255
80107514:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107519:	e9 3c ef ff ff       	jmp    8010645a <alltraps>

8010751e <lgdt>:
{
8010751e:	55                   	push   %ebp
8010751f:	89 e5                	mov    %esp,%ebp
80107521:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107524:	8b 45 0c             	mov    0xc(%ebp),%eax
80107527:	83 e8 01             	sub    $0x1,%eax
8010752a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010752e:	8b 45 08             	mov    0x8(%ebp),%eax
80107531:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107535:	8b 45 08             	mov    0x8(%ebp),%eax
80107538:	c1 e8 10             	shr    $0x10,%eax
8010753b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010753f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107542:	0f 01 10             	lgdtl  (%eax)
}
80107545:	90                   	nop
80107546:	c9                   	leave  
80107547:	c3                   	ret    

80107548 <ltr>:
{
80107548:	55                   	push   %ebp
80107549:	89 e5                	mov    %esp,%ebp
8010754b:	83 ec 04             	sub    $0x4,%esp
8010754e:	8b 45 08             	mov    0x8(%ebp),%eax
80107551:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107555:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107559:	0f 00 d8             	ltr    %ax
}
8010755c:	90                   	nop
8010755d:	c9                   	leave  
8010755e:	c3                   	ret    

8010755f <lcr3>:

static inline void
lcr3(uint val)
{
8010755f:	55                   	push   %ebp
80107560:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107562:	8b 45 08             	mov    0x8(%ebp),%eax
80107565:	0f 22 d8             	mov    %eax,%cr3
}
80107568:	90                   	nop
80107569:	5d                   	pop    %ebp
8010756a:	c3                   	ret    

8010756b <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010756b:	f3 0f 1e fb          	endbr32 
8010756f:	55                   	push   %ebp
80107570:	89 e5                	mov    %esp,%ebp
80107572:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107575:	e8 8c ca ff ff       	call   80104006 <cpuid>
8010757a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107580:	05 00 ad 11 80       	add    $0x8011ad00,%eax
80107585:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010758b:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107594:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010759a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759d:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801075a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075a8:	83 e2 f0             	and    $0xfffffff0,%edx
801075ab:	83 ca 0a             	or     $0xa,%edx
801075ae:	88 50 7d             	mov    %dl,0x7d(%eax)
801075b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b4:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075b8:	83 ca 10             	or     $0x10,%edx
801075bb:	88 50 7d             	mov    %dl,0x7d(%eax)
801075be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075c5:	83 e2 9f             	and    $0xffffff9f,%edx
801075c8:	88 50 7d             	mov    %dl,0x7d(%eax)
801075cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ce:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075d2:	83 ca 80             	or     $0xffffff80,%edx
801075d5:	88 50 7d             	mov    %dl,0x7d(%eax)
801075d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075db:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075df:	83 ca 0f             	or     $0xf,%edx
801075e2:	88 50 7e             	mov    %dl,0x7e(%eax)
801075e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075ec:	83 e2 ef             	and    $0xffffffef,%edx
801075ef:	88 50 7e             	mov    %dl,0x7e(%eax)
801075f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075f9:	83 e2 df             	and    $0xffffffdf,%edx
801075fc:	88 50 7e             	mov    %dl,0x7e(%eax)
801075ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107602:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107606:	83 ca 40             	or     $0x40,%edx
80107609:	88 50 7e             	mov    %dl,0x7e(%eax)
8010760c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107613:	83 ca 80             	or     $0xffffff80,%edx
80107616:	88 50 7e             	mov    %dl,0x7e(%eax)
80107619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761c:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107623:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010762a:	ff ff 
8010762c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762f:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107636:	00 00 
80107638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763b:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107645:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010764c:	83 e2 f0             	and    $0xfffffff0,%edx
8010764f:	83 ca 02             	or     $0x2,%edx
80107652:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107662:	83 ca 10             	or     $0x10,%edx
80107665:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010766b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107675:	83 e2 9f             	and    $0xffffff9f,%edx
80107678:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010767e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107681:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107688:	83 ca 80             	or     $0xffffff80,%edx
8010768b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107694:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010769b:	83 ca 0f             	or     $0xf,%edx
8010769e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076ae:	83 e2 ef             	and    $0xffffffef,%edx
801076b1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ba:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076c1:	83 e2 df             	and    $0xffffffdf,%edx
801076c4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cd:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076d4:	83 ca 40             	or     $0x40,%edx
801076d7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076e7:	83 ca 80             	or     $0xffffff80,%edx
801076ea:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f3:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801076fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fd:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107704:	ff ff 
80107706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107709:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107710:	00 00 
80107712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107715:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
8010771c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107726:	83 e2 f0             	and    $0xfffffff0,%edx
80107729:	83 ca 0a             	or     $0xa,%edx
8010772c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107735:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010773c:	83 ca 10             	or     $0x10,%edx
8010773f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107748:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010774f:	83 ca 60             	or     $0x60,%edx
80107752:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107762:	83 ca 80             	or     $0xffffff80,%edx
80107765:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010776b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107775:	83 ca 0f             	or     $0xf,%edx
80107778:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010777e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107781:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107788:	83 e2 ef             	and    $0xffffffef,%edx
8010778b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107794:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010779b:	83 e2 df             	and    $0xffffffdf,%edx
8010779e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077ae:	83 ca 40             	or     $0x40,%edx
801077b1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ba:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077c1:	83 ca 80             	or     $0xffffff80,%edx
801077c4:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cd:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801077d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d7:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801077de:	ff ff 
801077e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e3:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801077ea:	00 00 
801077ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ef:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801077f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107800:	83 e2 f0             	and    $0xfffffff0,%edx
80107803:	83 ca 02             	or     $0x2,%edx
80107806:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010780c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107816:	83 ca 10             	or     $0x10,%edx
80107819:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010781f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107822:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107829:	83 ca 60             	or     $0x60,%edx
8010782c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107835:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010783c:	83 ca 80             	or     $0xffffff80,%edx
8010783f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107848:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010784f:	83 ca 0f             	or     $0xf,%edx
80107852:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107862:	83 e2 ef             	and    $0xffffffef,%edx
80107865:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010786b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107875:	83 e2 df             	and    $0xffffffdf,%edx
80107878:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010787e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107881:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107888:	83 ca 40             	or     $0x40,%edx
8010788b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107891:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107894:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010789b:	83 ca 80             	or     $0xffffff80,%edx
8010789e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a7:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801078ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b1:	83 c0 70             	add    $0x70,%eax
801078b4:	83 ec 08             	sub    $0x8,%esp
801078b7:	6a 30                	push   $0x30
801078b9:	50                   	push   %eax
801078ba:	e8 5f fc ff ff       	call   8010751e <lgdt>
801078bf:	83 c4 10             	add    $0x10,%esp
}
801078c2:	90                   	nop
801078c3:	c9                   	leave  
801078c4:	c3                   	ret    

801078c5 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801078c5:	f3 0f 1e fb          	endbr32 
801078c9:	55                   	push   %ebp
801078ca:	89 e5                	mov    %esp,%ebp
801078cc:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801078cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801078d2:	c1 e8 16             	shr    $0x16,%eax
801078d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078dc:	8b 45 08             	mov    0x8(%ebp),%eax
801078df:	01 d0                	add    %edx,%eax
801078e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801078e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078e7:	8b 00                	mov    (%eax),%eax
801078e9:	83 e0 01             	and    $0x1,%eax
801078ec:	85 c0                	test   %eax,%eax
801078ee:	74 14                	je     80107904 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801078f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078f3:	8b 00                	mov    (%eax),%eax
801078f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078fa:	05 00 00 00 80       	add    $0x80000000,%eax
801078ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107902:	eb 42                	jmp    80107946 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107904:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107908:	74 0e                	je     80107918 <walkpgdir+0x53>
8010790a:	e8 7b b4 ff ff       	call   80102d8a <kalloc>
8010790f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107912:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107916:	75 07                	jne    8010791f <walkpgdir+0x5a>
      return 0;
80107918:	b8 00 00 00 00       	mov    $0x0,%eax
8010791d:	eb 3e                	jmp    8010795d <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010791f:	83 ec 04             	sub    $0x4,%esp
80107922:	68 00 10 00 00       	push   $0x1000
80107927:	6a 00                	push   $0x0
80107929:	ff 75 f4             	pushl  -0xc(%ebp)
8010792c:	e8 1b d7 ff ff       	call   8010504c <memset>
80107931:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107937:	05 00 00 00 80       	add    $0x80000000,%eax
8010793c:	83 c8 07             	or     $0x7,%eax
8010793f:	89 c2                	mov    %eax,%edx
80107941:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107944:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107946:	8b 45 0c             	mov    0xc(%ebp),%eax
80107949:	c1 e8 0c             	shr    $0xc,%eax
8010794c:	25 ff 03 00 00       	and    $0x3ff,%eax
80107951:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795b:	01 d0                	add    %edx,%eax
}
8010795d:	c9                   	leave  
8010795e:	c3                   	ret    

8010795f <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010795f:	f3 0f 1e fb          	endbr32 
80107963:	55                   	push   %ebp
80107964:	89 e5                	mov    %esp,%ebp
80107966:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107969:	8b 45 0c             	mov    0xc(%ebp),%eax
8010796c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107971:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107974:	8b 55 0c             	mov    0xc(%ebp),%edx
80107977:	8b 45 10             	mov    0x10(%ebp),%eax
8010797a:	01 d0                	add    %edx,%eax
8010797c:	83 e8 01             	sub    $0x1,%eax
8010797f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107984:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107987:	83 ec 04             	sub    $0x4,%esp
8010798a:	6a 01                	push   $0x1
8010798c:	ff 75 f4             	pushl  -0xc(%ebp)
8010798f:	ff 75 08             	pushl  0x8(%ebp)
80107992:	e8 2e ff ff ff       	call   801078c5 <walkpgdir>
80107997:	83 c4 10             	add    $0x10,%esp
8010799a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010799d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079a1:	75 07                	jne    801079aa <mappages+0x4b>
      return -1;
801079a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079a8:	eb 47                	jmp    801079f1 <mappages+0x92>
    if(*pte & PTE_P)
801079aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079ad:	8b 00                	mov    (%eax),%eax
801079af:	83 e0 01             	and    $0x1,%eax
801079b2:	85 c0                	test   %eax,%eax
801079b4:	74 0d                	je     801079c3 <mappages+0x64>
      panic("remap");
801079b6:	83 ec 0c             	sub    $0xc,%esp
801079b9:	68 0c ad 10 80       	push   $0x8010ad0c
801079be:	e8 02 8c ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
801079c3:	8b 45 18             	mov    0x18(%ebp),%eax
801079c6:	0b 45 14             	or     0x14(%ebp),%eax
801079c9:	83 c8 01             	or     $0x1,%eax
801079cc:	89 c2                	mov    %eax,%edx
801079ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079d1:	89 10                	mov    %edx,(%eax)
    if(a == last)
801079d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801079d9:	74 10                	je     801079eb <mappages+0x8c>
      break;
    a += PGSIZE;
801079db:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801079e2:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801079e9:	eb 9c                	jmp    80107987 <mappages+0x28>
      break;
801079eb:	90                   	nop
  }
  return 0;
801079ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801079f1:	c9                   	leave  
801079f2:	c3                   	ret    

801079f3 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801079f3:	f3 0f 1e fb          	endbr32 
801079f7:	55                   	push   %ebp
801079f8:	89 e5                	mov    %esp,%ebp
801079fa:	53                   	push   %ebx
801079fb:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801079fe:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107a05:	a1 cc af 11 80       	mov    0x8011afcc,%eax
80107a0a:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107a0f:	29 c2                	sub    %eax,%edx
80107a11:	89 d0                	mov    %edx,%eax
80107a13:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a16:	a1 c4 af 11 80       	mov    0x8011afc4,%eax
80107a1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a1e:	8b 15 c4 af 11 80    	mov    0x8011afc4,%edx
80107a24:	a1 cc af 11 80       	mov    0x8011afcc,%eax
80107a29:	01 d0                	add    %edx,%eax
80107a2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107a2e:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a38:	83 c0 30             	add    $0x30,%eax
80107a3b:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107a3e:	89 10                	mov    %edx,(%eax)
80107a40:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a43:	89 50 04             	mov    %edx,0x4(%eax)
80107a46:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a49:	89 50 08             	mov    %edx,0x8(%eax)
80107a4c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107a4f:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107a52:	e8 33 b3 ff ff       	call   80102d8a <kalloc>
80107a57:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a5e:	75 07                	jne    80107a67 <setupkvm+0x74>
    return 0;
80107a60:	b8 00 00 00 00       	mov    $0x0,%eax
80107a65:	eb 78                	jmp    80107adf <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80107a67:	83 ec 04             	sub    $0x4,%esp
80107a6a:	68 00 10 00 00       	push   $0x1000
80107a6f:	6a 00                	push   $0x0
80107a71:	ff 75 f0             	pushl  -0x10(%ebp)
80107a74:	e8 d3 d5 ff ff       	call   8010504c <memset>
80107a79:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a7c:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107a83:	eb 4e                	jmp    80107ad3 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8e:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	8b 58 08             	mov    0x8(%eax),%ebx
80107a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9a:	8b 40 04             	mov    0x4(%eax),%eax
80107a9d:	29 c3                	sub    %eax,%ebx
80107a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa2:	8b 00                	mov    (%eax),%eax
80107aa4:	83 ec 0c             	sub    $0xc,%esp
80107aa7:	51                   	push   %ecx
80107aa8:	52                   	push   %edx
80107aa9:	53                   	push   %ebx
80107aaa:	50                   	push   %eax
80107aab:	ff 75 f0             	pushl  -0x10(%ebp)
80107aae:	e8 ac fe ff ff       	call   8010795f <mappages>
80107ab3:	83 c4 20             	add    $0x20,%esp
80107ab6:	85 c0                	test   %eax,%eax
80107ab8:	79 15                	jns    80107acf <setupkvm+0xdc>
      freevm(pgdir);
80107aba:	83 ec 0c             	sub    $0xc,%esp
80107abd:	ff 75 f0             	pushl  -0x10(%ebp)
80107ac0:	e8 11 05 00 00       	call   80107fd6 <freevm>
80107ac5:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ac8:	b8 00 00 00 00       	mov    $0x0,%eax
80107acd:	eb 10                	jmp    80107adf <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107acf:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107ad3:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107ada:	72 a9                	jb     80107a85 <setupkvm+0x92>
    }
  return pgdir;
80107adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107adf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107ae2:	c9                   	leave  
80107ae3:	c3                   	ret    

80107ae4 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107ae4:	f3 0f 1e fb          	endbr32 
80107ae8:	55                   	push   %ebp
80107ae9:	89 e5                	mov    %esp,%ebp
80107aeb:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107aee:	e8 00 ff ff ff       	call   801079f3 <setupkvm>
80107af3:	a3 c4 ac 11 80       	mov    %eax,0x8011acc4
  switchkvm();
80107af8:	e8 03 00 00 00       	call   80107b00 <switchkvm>
}
80107afd:	90                   	nop
80107afe:	c9                   	leave  
80107aff:	c3                   	ret    

80107b00 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107b00:	f3 0f 1e fb          	endbr32 
80107b04:	55                   	push   %ebp
80107b05:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107b07:	a1 c4 ac 11 80       	mov    0x8011acc4,%eax
80107b0c:	05 00 00 00 80       	add    $0x80000000,%eax
80107b11:	50                   	push   %eax
80107b12:	e8 48 fa ff ff       	call   8010755f <lcr3>
80107b17:	83 c4 04             	add    $0x4,%esp
}
80107b1a:	90                   	nop
80107b1b:	c9                   	leave  
80107b1c:	c3                   	ret    

80107b1d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107b1d:	f3 0f 1e fb          	endbr32 
80107b21:	55                   	push   %ebp
80107b22:	89 e5                	mov    %esp,%ebp
80107b24:	56                   	push   %esi
80107b25:	53                   	push   %ebx
80107b26:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107b29:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b2d:	75 0d                	jne    80107b3c <switchuvm+0x1f>
    panic("switchuvm: no process");
80107b2f:	83 ec 0c             	sub    $0xc,%esp
80107b32:	68 12 ad 10 80       	push   $0x8010ad12
80107b37:	e8 89 8a ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
80107b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80107b3f:	8b 40 08             	mov    0x8(%eax),%eax
80107b42:	85 c0                	test   %eax,%eax
80107b44:	75 0d                	jne    80107b53 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107b46:	83 ec 0c             	sub    $0xc,%esp
80107b49:	68 28 ad 10 80       	push   $0x8010ad28
80107b4e:	e8 72 8a ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
80107b53:	8b 45 08             	mov    0x8(%ebp),%eax
80107b56:	8b 40 04             	mov    0x4(%eax),%eax
80107b59:	85 c0                	test   %eax,%eax
80107b5b:	75 0d                	jne    80107b6a <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107b5d:	83 ec 0c             	sub    $0xc,%esp
80107b60:	68 3d ad 10 80       	push   $0x8010ad3d
80107b65:	e8 5b 8a ff ff       	call   801005c5 <panic>

  pushcli();
80107b6a:	e8 ca d3 ff ff       	call   80104f39 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107b6f:	e8 b1 c4 ff ff       	call   80104025 <mycpu>
80107b74:	89 c3                	mov    %eax,%ebx
80107b76:	e8 aa c4 ff ff       	call   80104025 <mycpu>
80107b7b:	83 c0 08             	add    $0x8,%eax
80107b7e:	89 c6                	mov    %eax,%esi
80107b80:	e8 a0 c4 ff ff       	call   80104025 <mycpu>
80107b85:	83 c0 08             	add    $0x8,%eax
80107b88:	c1 e8 10             	shr    $0x10,%eax
80107b8b:	88 45 f7             	mov    %al,-0x9(%ebp)
80107b8e:	e8 92 c4 ff ff       	call   80104025 <mycpu>
80107b93:	83 c0 08             	add    $0x8,%eax
80107b96:	c1 e8 18             	shr    $0x18,%eax
80107b99:	89 c2                	mov    %eax,%edx
80107b9b:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107ba2:	67 00 
80107ba4:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107bab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107baf:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107bb5:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107bbc:	83 e0 f0             	and    $0xfffffff0,%eax
80107bbf:	83 c8 09             	or     $0x9,%eax
80107bc2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bc8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107bcf:	83 c8 10             	or     $0x10,%eax
80107bd2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bd8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107bdf:	83 e0 9f             	and    $0xffffff9f,%eax
80107be2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107be8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107bef:	83 c8 80             	or     $0xffffff80,%eax
80107bf2:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bf8:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107bff:	83 e0 f0             	and    $0xfffffff0,%eax
80107c02:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c08:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c0f:	83 e0 ef             	and    $0xffffffef,%eax
80107c12:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c18:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c1f:	83 e0 df             	and    $0xffffffdf,%eax
80107c22:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c28:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c2f:	83 c8 40             	or     $0x40,%eax
80107c32:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c38:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c3f:	83 e0 7f             	and    $0x7f,%eax
80107c42:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c48:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107c4e:	e8 d2 c3 ff ff       	call   80104025 <mycpu>
80107c53:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c5a:	83 e2 ef             	and    $0xffffffef,%edx
80107c5d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107c63:	e8 bd c3 ff ff       	call   80104025 <mycpu>
80107c68:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80107c71:	8b 40 08             	mov    0x8(%eax),%eax
80107c74:	89 c3                	mov    %eax,%ebx
80107c76:	e8 aa c3 ff ff       	call   80104025 <mycpu>
80107c7b:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107c81:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107c84:	e8 9c c3 ff ff       	call   80104025 <mycpu>
80107c89:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107c8f:	83 ec 0c             	sub    $0xc,%esp
80107c92:	6a 28                	push   $0x28
80107c94:	e8 af f8 ff ff       	call   80107548 <ltr>
80107c99:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80107c9f:	8b 40 04             	mov    0x4(%eax),%eax
80107ca2:	05 00 00 00 80       	add    $0x80000000,%eax
80107ca7:	83 ec 0c             	sub    $0xc,%esp
80107caa:	50                   	push   %eax
80107cab:	e8 af f8 ff ff       	call   8010755f <lcr3>
80107cb0:	83 c4 10             	add    $0x10,%esp
  popcli();
80107cb3:	e8 d2 d2 ff ff       	call   80104f8a <popcli>
}
80107cb8:	90                   	nop
80107cb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107cbc:	5b                   	pop    %ebx
80107cbd:	5e                   	pop    %esi
80107cbe:	5d                   	pop    %ebp
80107cbf:	c3                   	ret    

80107cc0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107cc0:	f3 0f 1e fb          	endbr32 
80107cc4:	55                   	push   %ebp
80107cc5:	89 e5                	mov    %esp,%ebp
80107cc7:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107cca:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107cd1:	76 0d                	jbe    80107ce0 <inituvm+0x20>
    panic("inituvm: more than a page");
80107cd3:	83 ec 0c             	sub    $0xc,%esp
80107cd6:	68 51 ad 10 80       	push   $0x8010ad51
80107cdb:	e8 e5 88 ff ff       	call   801005c5 <panic>
  mem = kalloc();
80107ce0:	e8 a5 b0 ff ff       	call   80102d8a <kalloc>
80107ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107ce8:	83 ec 04             	sub    $0x4,%esp
80107ceb:	68 00 10 00 00       	push   $0x1000
80107cf0:	6a 00                	push   $0x0
80107cf2:	ff 75 f4             	pushl  -0xc(%ebp)
80107cf5:	e8 52 d3 ff ff       	call   8010504c <memset>
80107cfa:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d00:	05 00 00 00 80       	add    $0x80000000,%eax
80107d05:	83 ec 0c             	sub    $0xc,%esp
80107d08:	6a 06                	push   $0x6
80107d0a:	50                   	push   %eax
80107d0b:	68 00 10 00 00       	push   $0x1000
80107d10:	6a 00                	push   $0x0
80107d12:	ff 75 08             	pushl  0x8(%ebp)
80107d15:	e8 45 fc ff ff       	call   8010795f <mappages>
80107d1a:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107d1d:	83 ec 04             	sub    $0x4,%esp
80107d20:	ff 75 10             	pushl  0x10(%ebp)
80107d23:	ff 75 0c             	pushl  0xc(%ebp)
80107d26:	ff 75 f4             	pushl  -0xc(%ebp)
80107d29:	e8 e5 d3 ff ff       	call   80105113 <memmove>
80107d2e:	83 c4 10             	add    $0x10,%esp
}
80107d31:	90                   	nop
80107d32:	c9                   	leave  
80107d33:	c3                   	ret    

80107d34 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107d34:	f3 0f 1e fb          	endbr32 
80107d38:	55                   	push   %ebp
80107d39:	89 e5                	mov    %esp,%ebp
80107d3b:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d41:	25 ff 0f 00 00       	and    $0xfff,%eax
80107d46:	85 c0                	test   %eax,%eax
80107d48:	74 0d                	je     80107d57 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107d4a:	83 ec 0c             	sub    $0xc,%esp
80107d4d:	68 6c ad 10 80       	push   $0x8010ad6c
80107d52:	e8 6e 88 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107d57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d5e:	e9 8f 00 00 00       	jmp    80107df2 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107d63:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d69:	01 d0                	add    %edx,%eax
80107d6b:	83 ec 04             	sub    $0x4,%esp
80107d6e:	6a 00                	push   $0x0
80107d70:	50                   	push   %eax
80107d71:	ff 75 08             	pushl  0x8(%ebp)
80107d74:	e8 4c fb ff ff       	call   801078c5 <walkpgdir>
80107d79:	83 c4 10             	add    $0x10,%esp
80107d7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d7f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d83:	75 0d                	jne    80107d92 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107d85:	83 ec 0c             	sub    $0xc,%esp
80107d88:	68 8f ad 10 80       	push   $0x8010ad8f
80107d8d:	e8 33 88 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107d92:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d95:	8b 00                	mov    (%eax),%eax
80107d97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d9c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107d9f:	8b 45 18             	mov    0x18(%ebp),%eax
80107da2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107da5:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107daa:	77 0b                	ja     80107db7 <loaduvm+0x83>
      n = sz - i;
80107dac:	8b 45 18             	mov    0x18(%ebp),%eax
80107daf:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107db2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107db5:	eb 07                	jmp    80107dbe <loaduvm+0x8a>
    else
      n = PGSIZE;
80107db7:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107dbe:	8b 55 14             	mov    0x14(%ebp),%edx
80107dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc4:	01 d0                	add    %edx,%eax
80107dc6:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107dc9:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107dcf:	ff 75 f0             	pushl  -0x10(%ebp)
80107dd2:	50                   	push   %eax
80107dd3:	52                   	push   %edx
80107dd4:	ff 75 10             	pushl  0x10(%ebp)
80107dd7:	e8 a8 a1 ff ff       	call   80101f84 <readi>
80107ddc:	83 c4 10             	add    $0x10,%esp
80107ddf:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107de2:	74 07                	je     80107deb <loaduvm+0xb7>
      return -1;
80107de4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107de9:	eb 18                	jmp    80107e03 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107deb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df5:	3b 45 18             	cmp    0x18(%ebp),%eax
80107df8:	0f 82 65 ff ff ff    	jb     80107d63 <loaduvm+0x2f>
  }
  return 0;
80107dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e03:	c9                   	leave  
80107e04:	c3                   	ret    

80107e05 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107e05:	f3 0f 1e fb          	endbr32 
80107e09:	55                   	push   %ebp
80107e0a:	89 e5                	mov    %esp,%ebp
80107e0c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107e0f:	8b 45 10             	mov    0x10(%ebp),%eax
80107e12:	85 c0                	test   %eax,%eax
80107e14:	79 0a                	jns    80107e20 <allocuvm+0x1b>
    return 0;
80107e16:	b8 00 00 00 00       	mov    $0x0,%eax
80107e1b:	e9 ec 00 00 00       	jmp    80107f0c <allocuvm+0x107>
  if(newsz < oldsz)
80107e20:	8b 45 10             	mov    0x10(%ebp),%eax
80107e23:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e26:	73 08                	jae    80107e30 <allocuvm+0x2b>
    return oldsz;
80107e28:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e2b:	e9 dc 00 00 00       	jmp    80107f0c <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107e30:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e33:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107e40:	e9 b8 00 00 00       	jmp    80107efd <allocuvm+0xf8>
    mem = kalloc();
80107e45:	e8 40 af ff ff       	call   80102d8a <kalloc>
80107e4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107e4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e51:	75 2e                	jne    80107e81 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107e53:	83 ec 0c             	sub    $0xc,%esp
80107e56:	68 ad ad 10 80       	push   $0x8010adad
80107e5b:	e8 ac 85 ff ff       	call   8010040c <cprintf>
80107e60:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e63:	83 ec 04             	sub    $0x4,%esp
80107e66:	ff 75 0c             	pushl  0xc(%ebp)
80107e69:	ff 75 10             	pushl  0x10(%ebp)
80107e6c:	ff 75 08             	pushl  0x8(%ebp)
80107e6f:	e8 9a 00 00 00       	call   80107f0e <deallocuvm>
80107e74:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e77:	b8 00 00 00 00       	mov    $0x0,%eax
80107e7c:	e9 8b 00 00 00       	jmp    80107f0c <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107e81:	83 ec 04             	sub    $0x4,%esp
80107e84:	68 00 10 00 00       	push   $0x1000
80107e89:	6a 00                	push   $0x0
80107e8b:	ff 75 f0             	pushl  -0x10(%ebp)
80107e8e:	e8 b9 d1 ff ff       	call   8010504c <memset>
80107e93:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e99:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea2:	83 ec 0c             	sub    $0xc,%esp
80107ea5:	6a 06                	push   $0x6
80107ea7:	52                   	push   %edx
80107ea8:	68 00 10 00 00       	push   $0x1000
80107ead:	50                   	push   %eax
80107eae:	ff 75 08             	pushl  0x8(%ebp)
80107eb1:	e8 a9 fa ff ff       	call   8010795f <mappages>
80107eb6:	83 c4 20             	add    $0x20,%esp
80107eb9:	85 c0                	test   %eax,%eax
80107ebb:	79 39                	jns    80107ef6 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107ebd:	83 ec 0c             	sub    $0xc,%esp
80107ec0:	68 c5 ad 10 80       	push   $0x8010adc5
80107ec5:	e8 42 85 ff ff       	call   8010040c <cprintf>
80107eca:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107ecd:	83 ec 04             	sub    $0x4,%esp
80107ed0:	ff 75 0c             	pushl  0xc(%ebp)
80107ed3:	ff 75 10             	pushl  0x10(%ebp)
80107ed6:	ff 75 08             	pushl  0x8(%ebp)
80107ed9:	e8 30 00 00 00       	call   80107f0e <deallocuvm>
80107ede:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107ee1:	83 ec 0c             	sub    $0xc,%esp
80107ee4:	ff 75 f0             	pushl  -0x10(%ebp)
80107ee7:	e8 00 ae ff ff       	call   80102cec <kfree>
80107eec:	83 c4 10             	add    $0x10,%esp
      return 0;
80107eef:	b8 00 00 00 00       	mov    $0x0,%eax
80107ef4:	eb 16                	jmp    80107f0c <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107ef6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f00:	3b 45 10             	cmp    0x10(%ebp),%eax
80107f03:	0f 82 3c ff ff ff    	jb     80107e45 <allocuvm+0x40>
    }
  }
  return newsz;
80107f09:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f0c:	c9                   	leave  
80107f0d:	c3                   	ret    

80107f0e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107f0e:	f3 0f 1e fb          	endbr32 
80107f12:	55                   	push   %ebp
80107f13:	89 e5                	mov    %esp,%ebp
80107f15:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107f18:	8b 45 10             	mov    0x10(%ebp),%eax
80107f1b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f1e:	72 08                	jb     80107f28 <deallocuvm+0x1a>
    return oldsz;
80107f20:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f23:	e9 ac 00 00 00       	jmp    80107fd4 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107f28:	8b 45 10             	mov    0x10(%ebp),%eax
80107f2b:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f30:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107f38:	e9 88 00 00 00       	jmp    80107fc5 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f40:	83 ec 04             	sub    $0x4,%esp
80107f43:	6a 00                	push   $0x0
80107f45:	50                   	push   %eax
80107f46:	ff 75 08             	pushl  0x8(%ebp)
80107f49:	e8 77 f9 ff ff       	call   801078c5 <walkpgdir>
80107f4e:	83 c4 10             	add    $0x10,%esp
80107f51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107f54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f58:	75 16                	jne    80107f70 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5d:	c1 e8 16             	shr    $0x16,%eax
80107f60:	83 c0 01             	add    $0x1,%eax
80107f63:	c1 e0 16             	shl    $0x16,%eax
80107f66:	2d 00 10 00 00       	sub    $0x1000,%eax
80107f6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f6e:	eb 4e                	jmp    80107fbe <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f73:	8b 00                	mov    (%eax),%eax
80107f75:	83 e0 01             	and    $0x1,%eax
80107f78:	85 c0                	test   %eax,%eax
80107f7a:	74 42                	je     80107fbe <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f7f:	8b 00                	mov    (%eax),%eax
80107f81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f86:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107f89:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f8d:	75 0d                	jne    80107f9c <deallocuvm+0x8e>
        panic("kfree");
80107f8f:	83 ec 0c             	sub    $0xc,%esp
80107f92:	68 e1 ad 10 80       	push   $0x8010ade1
80107f97:	e8 29 86 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80107f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f9f:	05 00 00 00 80       	add    $0x80000000,%eax
80107fa4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107fa7:	83 ec 0c             	sub    $0xc,%esp
80107faa:	ff 75 e8             	pushl  -0x18(%ebp)
80107fad:	e8 3a ad ff ff       	call   80102cec <kfree>
80107fb2:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107fbe:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fcb:	0f 82 6c ff ff ff    	jb     80107f3d <deallocuvm+0x2f>
    }
  }
  return newsz;
80107fd1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107fd4:	c9                   	leave  
80107fd5:	c3                   	ret    

80107fd6 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107fd6:	f3 0f 1e fb          	endbr32 
80107fda:	55                   	push   %ebp
80107fdb:	89 e5                	mov    %esp,%ebp
80107fdd:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107fe0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107fe4:	75 0d                	jne    80107ff3 <freevm+0x1d>
    panic("freevm: no pgdir");
80107fe6:	83 ec 0c             	sub    $0xc,%esp
80107fe9:	68 e7 ad 10 80       	push   $0x8010ade7
80107fee:	e8 d2 85 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107ff3:	83 ec 04             	sub    $0x4,%esp
80107ff6:	6a 00                	push   $0x0
80107ff8:	68 00 00 00 80       	push   $0x80000000
80107ffd:	ff 75 08             	pushl  0x8(%ebp)
80108000:	e8 09 ff ff ff       	call   80107f0e <deallocuvm>
80108005:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108008:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010800f:	eb 48                	jmp    80108059 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80108011:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108014:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010801b:	8b 45 08             	mov    0x8(%ebp),%eax
8010801e:	01 d0                	add    %edx,%eax
80108020:	8b 00                	mov    (%eax),%eax
80108022:	83 e0 01             	and    $0x1,%eax
80108025:	85 c0                	test   %eax,%eax
80108027:	74 2c                	je     80108055 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108029:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108033:	8b 45 08             	mov    0x8(%ebp),%eax
80108036:	01 d0                	add    %edx,%eax
80108038:	8b 00                	mov    (%eax),%eax
8010803a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010803f:	05 00 00 00 80       	add    $0x80000000,%eax
80108044:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108047:	83 ec 0c             	sub    $0xc,%esp
8010804a:	ff 75 f0             	pushl  -0x10(%ebp)
8010804d:	e8 9a ac ff ff       	call   80102cec <kfree>
80108052:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108055:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108059:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108060:	76 af                	jbe    80108011 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80108062:	83 ec 0c             	sub    $0xc,%esp
80108065:	ff 75 08             	pushl  0x8(%ebp)
80108068:	e8 7f ac ff ff       	call   80102cec <kfree>
8010806d:	83 c4 10             	add    $0x10,%esp
}
80108070:	90                   	nop
80108071:	c9                   	leave  
80108072:	c3                   	ret    

80108073 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108073:	f3 0f 1e fb          	endbr32 
80108077:	55                   	push   %ebp
80108078:	89 e5                	mov    %esp,%ebp
8010807a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010807d:	83 ec 04             	sub    $0x4,%esp
80108080:	6a 00                	push   $0x0
80108082:	ff 75 0c             	pushl  0xc(%ebp)
80108085:	ff 75 08             	pushl  0x8(%ebp)
80108088:	e8 38 f8 ff ff       	call   801078c5 <walkpgdir>
8010808d:	83 c4 10             	add    $0x10,%esp
80108090:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108093:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108097:	75 0d                	jne    801080a6 <clearpteu+0x33>
    panic("clearpteu");
80108099:	83 ec 0c             	sub    $0xc,%esp
8010809c:	68 f8 ad 10 80       	push   $0x8010adf8
801080a1:	e8 1f 85 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
801080a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a9:	8b 00                	mov    (%eax),%eax
801080ab:	83 e0 fb             	and    $0xfffffffb,%eax
801080ae:	89 c2                	mov    %eax,%edx
801080b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b3:	89 10                	mov    %edx,(%eax)
}
801080b5:	90                   	nop
801080b6:	c9                   	leave  
801080b7:	c3                   	ret    

801080b8 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801080b8:	f3 0f 1e fb          	endbr32 
801080bc:	55                   	push   %ebp
801080bd:	89 e5                	mov    %esp,%ebp
801080bf:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801080c2:	e8 2c f9 ff ff       	call   801079f3 <setupkvm>
801080c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080ce:	75 0a                	jne    801080da <copyuvm+0x22>
    return 0;
801080d0:	b8 00 00 00 00       	mov    $0x0,%eax
801080d5:	e9 eb 00 00 00       	jmp    801081c5 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
801080da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080e1:	e9 b7 00 00 00       	jmp    8010819d <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801080e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e9:	83 ec 04             	sub    $0x4,%esp
801080ec:	6a 00                	push   $0x0
801080ee:	50                   	push   %eax
801080ef:	ff 75 08             	pushl  0x8(%ebp)
801080f2:	e8 ce f7 ff ff       	call   801078c5 <walkpgdir>
801080f7:	83 c4 10             	add    $0x10,%esp
801080fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108101:	75 0d                	jne    80108110 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80108103:	83 ec 0c             	sub    $0xc,%esp
80108106:	68 02 ae 10 80       	push   $0x8010ae02
8010810b:	e8 b5 84 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80108110:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108113:	8b 00                	mov    (%eax),%eax
80108115:	83 e0 01             	and    $0x1,%eax
80108118:	85 c0                	test   %eax,%eax
8010811a:	75 0d                	jne    80108129 <copyuvm+0x71>
      panic("copyuvm: page not present");
8010811c:	83 ec 0c             	sub    $0xc,%esp
8010811f:	68 1c ae 10 80       	push   $0x8010ae1c
80108124:	e8 9c 84 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80108129:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010812c:	8b 00                	mov    (%eax),%eax
8010812e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108133:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108136:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108139:	8b 00                	mov    (%eax),%eax
8010813b:	25 ff 0f 00 00       	and    $0xfff,%eax
80108140:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108143:	e8 42 ac ff ff       	call   80102d8a <kalloc>
80108148:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010814b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010814f:	74 5d                	je     801081ae <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108151:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108154:	05 00 00 00 80       	add    $0x80000000,%eax
80108159:	83 ec 04             	sub    $0x4,%esp
8010815c:	68 00 10 00 00       	push   $0x1000
80108161:	50                   	push   %eax
80108162:	ff 75 e0             	pushl  -0x20(%ebp)
80108165:	e8 a9 cf ff ff       	call   80105113 <memmove>
8010816a:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010816d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108170:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108173:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817c:	83 ec 0c             	sub    $0xc,%esp
8010817f:	52                   	push   %edx
80108180:	51                   	push   %ecx
80108181:	68 00 10 00 00       	push   $0x1000
80108186:	50                   	push   %eax
80108187:	ff 75 f0             	pushl  -0x10(%ebp)
8010818a:	e8 d0 f7 ff ff       	call   8010795f <mappages>
8010818f:	83 c4 20             	add    $0x20,%esp
80108192:	85 c0                	test   %eax,%eax
80108194:	78 1b                	js     801081b1 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80108196:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010819d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081a3:	0f 82 3d ff ff ff    	jb     801080e6 <copyuvm+0x2e>
      goto bad;
  }
  return d;
801081a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081ac:	eb 17                	jmp    801081c5 <copyuvm+0x10d>
      goto bad;
801081ae:	90                   	nop
801081af:	eb 01                	jmp    801081b2 <copyuvm+0xfa>
      goto bad;
801081b1:	90                   	nop

bad:
  freevm(d);
801081b2:	83 ec 0c             	sub    $0xc,%esp
801081b5:	ff 75 f0             	pushl  -0x10(%ebp)
801081b8:	e8 19 fe ff ff       	call   80107fd6 <freevm>
801081bd:	83 c4 10             	add    $0x10,%esp
  return 0;
801081c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081c5:	c9                   	leave  
801081c6:	c3                   	ret    

801081c7 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801081c7:	f3 0f 1e fb          	endbr32 
801081cb:	55                   	push   %ebp
801081cc:	89 e5                	mov    %esp,%ebp
801081ce:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801081d1:	83 ec 04             	sub    $0x4,%esp
801081d4:	6a 00                	push   $0x0
801081d6:	ff 75 0c             	pushl  0xc(%ebp)
801081d9:	ff 75 08             	pushl  0x8(%ebp)
801081dc:	e8 e4 f6 ff ff       	call   801078c5 <walkpgdir>
801081e1:	83 c4 10             	add    $0x10,%esp
801081e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801081e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ea:	8b 00                	mov    (%eax),%eax
801081ec:	83 e0 01             	and    $0x1,%eax
801081ef:	85 c0                	test   %eax,%eax
801081f1:	75 07                	jne    801081fa <uva2ka+0x33>
    return 0;
801081f3:	b8 00 00 00 00       	mov    $0x0,%eax
801081f8:	eb 22                	jmp    8010821c <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
801081fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fd:	8b 00                	mov    (%eax),%eax
801081ff:	83 e0 04             	and    $0x4,%eax
80108202:	85 c0                	test   %eax,%eax
80108204:	75 07                	jne    8010820d <uva2ka+0x46>
    return 0;
80108206:	b8 00 00 00 00       	mov    $0x0,%eax
8010820b:	eb 0f                	jmp    8010821c <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
8010820d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108210:	8b 00                	mov    (%eax),%eax
80108212:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108217:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010821c:	c9                   	leave  
8010821d:	c3                   	ret    

8010821e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010821e:	f3 0f 1e fb          	endbr32 
80108222:	55                   	push   %ebp
80108223:	89 e5                	mov    %esp,%ebp
80108225:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108228:	8b 45 10             	mov    0x10(%ebp),%eax
8010822b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010822e:	eb 7f                	jmp    801082af <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108230:	8b 45 0c             	mov    0xc(%ebp),%eax
80108233:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108238:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010823b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010823e:	83 ec 08             	sub    $0x8,%esp
80108241:	50                   	push   %eax
80108242:	ff 75 08             	pushl  0x8(%ebp)
80108245:	e8 7d ff ff ff       	call   801081c7 <uva2ka>
8010824a:	83 c4 10             	add    $0x10,%esp
8010824d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108250:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108254:	75 07                	jne    8010825d <copyout+0x3f>
      return -1;
80108256:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010825b:	eb 61                	jmp    801082be <copyout+0xa0>
    n = PGSIZE - (va - va0);
8010825d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108260:	2b 45 0c             	sub    0xc(%ebp),%eax
80108263:	05 00 10 00 00       	add    $0x1000,%eax
80108268:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010826b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826e:	3b 45 14             	cmp    0x14(%ebp),%eax
80108271:	76 06                	jbe    80108279 <copyout+0x5b>
      n = len;
80108273:	8b 45 14             	mov    0x14(%ebp),%eax
80108276:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108279:	8b 45 0c             	mov    0xc(%ebp),%eax
8010827c:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010827f:	89 c2                	mov    %eax,%edx
80108281:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108284:	01 d0                	add    %edx,%eax
80108286:	83 ec 04             	sub    $0x4,%esp
80108289:	ff 75 f0             	pushl  -0x10(%ebp)
8010828c:	ff 75 f4             	pushl  -0xc(%ebp)
8010828f:	50                   	push   %eax
80108290:	e8 7e ce ff ff       	call   80105113 <memmove>
80108295:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108298:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010829b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010829e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082a1:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801082a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082a7:	05 00 10 00 00       	add    $0x1000,%eax
801082ac:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801082af:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801082b3:	0f 85 77 ff ff ff    	jne    80108230 <copyout+0x12>
  }
  return 0;
801082b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082be:	c9                   	leave  
801082bf:	c3                   	ret    

801082c0 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801082c0:	f3 0f 1e fb          	endbr32 
801082c4:	55                   	push   %ebp
801082c5:	89 e5                	mov    %esp,%ebp
801082c7:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801082ca:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801082d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801082d4:	8b 40 08             	mov    0x8(%eax),%eax
801082d7:	05 00 00 00 80       	add    $0x80000000,%eax
801082dc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801082df:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801082e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e9:	8b 40 24             	mov    0x24(%eax),%eax
801082ec:	a3 5c 84 11 80       	mov    %eax,0x8011845c
  ncpu = 0;
801082f1:	c7 05 c0 af 11 80 00 	movl   $0x0,0x8011afc0
801082f8:	00 00 00 

  while(i<madt->len){
801082fb:	90                   	nop
801082fc:	e9 be 00 00 00       	jmp    801083bf <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108301:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108304:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108307:	01 d0                	add    %edx,%eax
80108309:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010830c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010830f:	0f b6 00             	movzbl (%eax),%eax
80108312:	0f b6 c0             	movzbl %al,%eax
80108315:	83 f8 05             	cmp    $0x5,%eax
80108318:	0f 87 a1 00 00 00    	ja     801083bf <mpinit_uefi+0xff>
8010831e:	8b 04 85 38 ae 10 80 	mov    -0x7fef51c8(,%eax,4),%eax
80108325:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108328:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010832b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
8010832e:	a1 c0 af 11 80       	mov    0x8011afc0,%eax
80108333:	83 f8 03             	cmp    $0x3,%eax
80108336:	7f 28                	jg     80108360 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108338:	8b 15 c0 af 11 80    	mov    0x8011afc0,%edx
8010833e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108341:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108345:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010834b:	81 c2 00 ad 11 80    	add    $0x8011ad00,%edx
80108351:	88 02                	mov    %al,(%edx)
          ncpu++;
80108353:	a1 c0 af 11 80       	mov    0x8011afc0,%eax
80108358:	83 c0 01             	add    $0x1,%eax
8010835b:	a3 c0 af 11 80       	mov    %eax,0x8011afc0
        }
        i += lapic_entry->record_len;
80108360:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108363:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108367:	0f b6 c0             	movzbl %al,%eax
8010836a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010836d:	eb 50                	jmp    801083bf <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
8010836f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108372:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108375:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108378:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010837c:	a2 e0 ac 11 80       	mov    %al,0x8011ace0
        i += ioapic->record_len;
80108381:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108384:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108388:	0f b6 c0             	movzbl %al,%eax
8010838b:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010838e:	eb 2f                	jmp    801083bf <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108393:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108396:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108399:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010839d:	0f b6 c0             	movzbl %al,%eax
801083a0:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083a3:	eb 1a                	jmp    801083bf <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801083a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801083ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ae:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083b2:	0f b6 c0             	movzbl %al,%eax
801083b5:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801083b8:	eb 05                	jmp    801083bf <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
801083ba:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801083be:	90                   	nop
  while(i<madt->len){
801083bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c2:	8b 40 04             	mov    0x4(%eax),%eax
801083c5:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801083c8:	0f 82 33 ff ff ff    	jb     80108301 <mpinit_uefi+0x41>
    }
  }

}
801083ce:	90                   	nop
801083cf:	90                   	nop
801083d0:	c9                   	leave  
801083d1:	c3                   	ret    

801083d2 <inb>:
{
801083d2:	55                   	push   %ebp
801083d3:	89 e5                	mov    %esp,%ebp
801083d5:	83 ec 14             	sub    $0x14,%esp
801083d8:	8b 45 08             	mov    0x8(%ebp),%eax
801083db:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801083df:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801083e3:	89 c2                	mov    %eax,%edx
801083e5:	ec                   	in     (%dx),%al
801083e6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801083e9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801083ed:	c9                   	leave  
801083ee:	c3                   	ret    

801083ef <outb>:
{
801083ef:	55                   	push   %ebp
801083f0:	89 e5                	mov    %esp,%ebp
801083f2:	83 ec 08             	sub    $0x8,%esp
801083f5:	8b 45 08             	mov    0x8(%ebp),%eax
801083f8:	8b 55 0c             	mov    0xc(%ebp),%edx
801083fb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801083ff:	89 d0                	mov    %edx,%eax
80108401:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108404:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108408:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010840c:	ee                   	out    %al,(%dx)
}
8010840d:	90                   	nop
8010840e:	c9                   	leave  
8010840f:	c3                   	ret    

80108410 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108410:	f3 0f 1e fb          	endbr32 
80108414:	55                   	push   %ebp
80108415:	89 e5                	mov    %esp,%ebp
80108417:	83 ec 28             	sub    $0x28,%esp
8010841a:	8b 45 08             	mov    0x8(%ebp),%eax
8010841d:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108420:	6a 00                	push   $0x0
80108422:	68 fa 03 00 00       	push   $0x3fa
80108427:	e8 c3 ff ff ff       	call   801083ef <outb>
8010842c:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010842f:	68 80 00 00 00       	push   $0x80
80108434:	68 fb 03 00 00       	push   $0x3fb
80108439:	e8 b1 ff ff ff       	call   801083ef <outb>
8010843e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108441:	6a 0c                	push   $0xc
80108443:	68 f8 03 00 00       	push   $0x3f8
80108448:	e8 a2 ff ff ff       	call   801083ef <outb>
8010844d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108450:	6a 00                	push   $0x0
80108452:	68 f9 03 00 00       	push   $0x3f9
80108457:	e8 93 ff ff ff       	call   801083ef <outb>
8010845c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010845f:	6a 03                	push   $0x3
80108461:	68 fb 03 00 00       	push   $0x3fb
80108466:	e8 84 ff ff ff       	call   801083ef <outb>
8010846b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010846e:	6a 00                	push   $0x0
80108470:	68 fc 03 00 00       	push   $0x3fc
80108475:	e8 75 ff ff ff       	call   801083ef <outb>
8010847a:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010847d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108484:	eb 11                	jmp    80108497 <uart_debug+0x87>
80108486:	83 ec 0c             	sub    $0xc,%esp
80108489:	6a 0a                	push   $0xa
8010848b:	e8 ac ac ff ff       	call   8010313c <microdelay>
80108490:	83 c4 10             	add    $0x10,%esp
80108493:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108497:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010849b:	7f 1a                	jg     801084b7 <uart_debug+0xa7>
8010849d:	83 ec 0c             	sub    $0xc,%esp
801084a0:	68 fd 03 00 00       	push   $0x3fd
801084a5:	e8 28 ff ff ff       	call   801083d2 <inb>
801084aa:	83 c4 10             	add    $0x10,%esp
801084ad:	0f b6 c0             	movzbl %al,%eax
801084b0:	83 e0 20             	and    $0x20,%eax
801084b3:	85 c0                	test   %eax,%eax
801084b5:	74 cf                	je     80108486 <uart_debug+0x76>
  outb(COM1+0, p);
801084b7:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
801084bb:	0f b6 c0             	movzbl %al,%eax
801084be:	83 ec 08             	sub    $0x8,%esp
801084c1:	50                   	push   %eax
801084c2:	68 f8 03 00 00       	push   $0x3f8
801084c7:	e8 23 ff ff ff       	call   801083ef <outb>
801084cc:	83 c4 10             	add    $0x10,%esp
}
801084cf:	90                   	nop
801084d0:	c9                   	leave  
801084d1:	c3                   	ret    

801084d2 <uart_debugs>:

void uart_debugs(char *p){
801084d2:	f3 0f 1e fb          	endbr32 
801084d6:	55                   	push   %ebp
801084d7:	89 e5                	mov    %esp,%ebp
801084d9:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801084dc:	eb 1b                	jmp    801084f9 <uart_debugs+0x27>
    uart_debug(*p++);
801084de:	8b 45 08             	mov    0x8(%ebp),%eax
801084e1:	8d 50 01             	lea    0x1(%eax),%edx
801084e4:	89 55 08             	mov    %edx,0x8(%ebp)
801084e7:	0f b6 00             	movzbl (%eax),%eax
801084ea:	0f be c0             	movsbl %al,%eax
801084ed:	83 ec 0c             	sub    $0xc,%esp
801084f0:	50                   	push   %eax
801084f1:	e8 1a ff ff ff       	call   80108410 <uart_debug>
801084f6:	83 c4 10             	add    $0x10,%esp
  while(*p){
801084f9:	8b 45 08             	mov    0x8(%ebp),%eax
801084fc:	0f b6 00             	movzbl (%eax),%eax
801084ff:	84 c0                	test   %al,%al
80108501:	75 db                	jne    801084de <uart_debugs+0xc>
  }
}
80108503:	90                   	nop
80108504:	90                   	nop
80108505:	c9                   	leave  
80108506:	c3                   	ret    

80108507 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108507:	f3 0f 1e fb          	endbr32 
8010850b:	55                   	push   %ebp
8010850c:	89 e5                	mov    %esp,%ebp
8010850e:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108511:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108518:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010851b:	8b 50 14             	mov    0x14(%eax),%edx
8010851e:	8b 40 10             	mov    0x10(%eax),%eax
80108521:	a3 c4 af 11 80       	mov    %eax,0x8011afc4
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108526:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108529:	8b 50 1c             	mov    0x1c(%eax),%edx
8010852c:	8b 40 18             	mov    0x18(%eax),%eax
8010852f:	a3 cc af 11 80       	mov    %eax,0x8011afcc
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108534:	a1 cc af 11 80       	mov    0x8011afcc,%eax
80108539:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010853e:	29 c2                	sub    %eax,%edx
80108540:	89 d0                	mov    %edx,%eax
80108542:	a3 c8 af 11 80       	mov    %eax,0x8011afc8
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108547:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010854a:	8b 50 24             	mov    0x24(%eax),%edx
8010854d:	8b 40 20             	mov    0x20(%eax),%eax
80108550:	a3 d0 af 11 80       	mov    %eax,0x8011afd0
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108555:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108558:	8b 50 2c             	mov    0x2c(%eax),%edx
8010855b:	8b 40 28             	mov    0x28(%eax),%eax
8010855e:	a3 d4 af 11 80       	mov    %eax,0x8011afd4
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108563:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108566:	8b 50 34             	mov    0x34(%eax),%edx
80108569:	8b 40 30             	mov    0x30(%eax),%eax
8010856c:	a3 d8 af 11 80       	mov    %eax,0x8011afd8
}
80108571:	90                   	nop
80108572:	c9                   	leave  
80108573:	c3                   	ret    

80108574 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108574:	f3 0f 1e fb          	endbr32 
80108578:	55                   	push   %ebp
80108579:	89 e5                	mov    %esp,%ebp
8010857b:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010857e:	8b 15 d8 af 11 80    	mov    0x8011afd8,%edx
80108584:	8b 45 0c             	mov    0xc(%ebp),%eax
80108587:	0f af d0             	imul   %eax,%edx
8010858a:	8b 45 08             	mov    0x8(%ebp),%eax
8010858d:	01 d0                	add    %edx,%eax
8010858f:	c1 e0 02             	shl    $0x2,%eax
80108592:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108595:	8b 15 c8 af 11 80    	mov    0x8011afc8,%edx
8010859b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010859e:	01 d0                	add    %edx,%eax
801085a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801085a3:	8b 45 10             	mov    0x10(%ebp),%eax
801085a6:	0f b6 10             	movzbl (%eax),%edx
801085a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085ac:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801085ae:	8b 45 10             	mov    0x10(%ebp),%eax
801085b1:	0f b6 50 01          	movzbl 0x1(%eax),%edx
801085b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085b8:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
801085bb:	8b 45 10             	mov    0x10(%ebp),%eax
801085be:	0f b6 50 02          	movzbl 0x2(%eax),%edx
801085c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801085c5:	88 50 02             	mov    %dl,0x2(%eax)
}
801085c8:	90                   	nop
801085c9:	c9                   	leave  
801085ca:	c3                   	ret    

801085cb <graphic_scroll_up>:

void graphic_scroll_up(int height){
801085cb:	f3 0f 1e fb          	endbr32 
801085cf:	55                   	push   %ebp
801085d0:	89 e5                	mov    %esp,%ebp
801085d2:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801085d5:	8b 15 d8 af 11 80    	mov    0x8011afd8,%edx
801085db:	8b 45 08             	mov    0x8(%ebp),%eax
801085de:	0f af c2             	imul   %edx,%eax
801085e1:	c1 e0 02             	shl    $0x2,%eax
801085e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801085e7:	8b 15 cc af 11 80    	mov    0x8011afcc,%edx
801085ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f0:	29 c2                	sub    %eax,%edx
801085f2:	89 d0                	mov    %edx,%eax
801085f4:	8b 0d c8 af 11 80    	mov    0x8011afc8,%ecx
801085fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085fd:	01 ca                	add    %ecx,%edx
801085ff:	89 d1                	mov    %edx,%ecx
80108601:	8b 15 c8 af 11 80    	mov    0x8011afc8,%edx
80108607:	83 ec 04             	sub    $0x4,%esp
8010860a:	50                   	push   %eax
8010860b:	51                   	push   %ecx
8010860c:	52                   	push   %edx
8010860d:	e8 01 cb ff ff       	call   80105113 <memmove>
80108612:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108618:	8b 0d c8 af 11 80    	mov    0x8011afc8,%ecx
8010861e:	8b 15 cc af 11 80    	mov    0x8011afcc,%edx
80108624:	01 d1                	add    %edx,%ecx
80108626:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108629:	29 d1                	sub    %edx,%ecx
8010862b:	89 ca                	mov    %ecx,%edx
8010862d:	83 ec 04             	sub    $0x4,%esp
80108630:	50                   	push   %eax
80108631:	6a 00                	push   $0x0
80108633:	52                   	push   %edx
80108634:	e8 13 ca ff ff       	call   8010504c <memset>
80108639:	83 c4 10             	add    $0x10,%esp
}
8010863c:	90                   	nop
8010863d:	c9                   	leave  
8010863e:	c3                   	ret    

8010863f <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010863f:	f3 0f 1e fb          	endbr32 
80108643:	55                   	push   %ebp
80108644:	89 e5                	mov    %esp,%ebp
80108646:	53                   	push   %ebx
80108647:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010864a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108651:	e9 b1 00 00 00       	jmp    80108707 <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108656:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010865d:	e9 97 00 00 00       	jmp    801086f9 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108662:	8b 45 10             	mov    0x10(%ebp),%eax
80108665:	83 e8 20             	sub    $0x20,%eax
80108668:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010866b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866e:	01 d0                	add    %edx,%eax
80108670:	0f b7 84 00 60 ae 10 	movzwl -0x7fef51a0(%eax,%eax,1),%eax
80108677:	80 
80108678:	0f b7 d0             	movzwl %ax,%edx
8010867b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010867e:	bb 01 00 00 00       	mov    $0x1,%ebx
80108683:	89 c1                	mov    %eax,%ecx
80108685:	d3 e3                	shl    %cl,%ebx
80108687:	89 d8                	mov    %ebx,%eax
80108689:	21 d0                	and    %edx,%eax
8010868b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010868e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108691:	ba 01 00 00 00       	mov    $0x1,%edx
80108696:	89 c1                	mov    %eax,%ecx
80108698:	d3 e2                	shl    %cl,%edx
8010869a:	89 d0                	mov    %edx,%eax
8010869c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010869f:	75 2b                	jne    801086cc <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801086a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801086a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a7:	01 c2                	add    %eax,%edx
801086a9:	b8 0e 00 00 00       	mov    $0xe,%eax
801086ae:	2b 45 f0             	sub    -0x10(%ebp),%eax
801086b1:	89 c1                	mov    %eax,%ecx
801086b3:	8b 45 08             	mov    0x8(%ebp),%eax
801086b6:	01 c8                	add    %ecx,%eax
801086b8:	83 ec 04             	sub    $0x4,%esp
801086bb:	68 e0 f4 10 80       	push   $0x8010f4e0
801086c0:	52                   	push   %edx
801086c1:	50                   	push   %eax
801086c2:	e8 ad fe ff ff       	call   80108574 <graphic_draw_pixel>
801086c7:	83 c4 10             	add    $0x10,%esp
801086ca:	eb 29                	jmp    801086f5 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
801086cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801086cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d2:	01 c2                	add    %eax,%edx
801086d4:	b8 0e 00 00 00       	mov    $0xe,%eax
801086d9:	2b 45 f0             	sub    -0x10(%ebp),%eax
801086dc:	89 c1                	mov    %eax,%ecx
801086de:	8b 45 08             	mov    0x8(%ebp),%eax
801086e1:	01 c8                	add    %ecx,%eax
801086e3:	83 ec 04             	sub    $0x4,%esp
801086e6:	68 a8 00 11 80       	push   $0x801100a8
801086eb:	52                   	push   %edx
801086ec:	50                   	push   %eax
801086ed:	e8 82 fe ff ff       	call   80108574 <graphic_draw_pixel>
801086f2:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801086f5:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801086f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086fd:	0f 89 5f ff ff ff    	jns    80108662 <font_render+0x23>
  for(int i=0;i<30;i++){
80108703:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108707:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010870b:	0f 8e 45 ff ff ff    	jle    80108656 <font_render+0x17>
      }
    }
  }
}
80108711:	90                   	nop
80108712:	90                   	nop
80108713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108716:	c9                   	leave  
80108717:	c3                   	ret    

80108718 <font_render_string>:

void font_render_string(char *string,int row){
80108718:	f3 0f 1e fb          	endbr32 
8010871c:	55                   	push   %ebp
8010871d:	89 e5                	mov    %esp,%ebp
8010871f:	53                   	push   %ebx
80108720:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108723:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010872a:	eb 33                	jmp    8010875f <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010872c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010872f:	8b 45 08             	mov    0x8(%ebp),%eax
80108732:	01 d0                	add    %edx,%eax
80108734:	0f b6 00             	movzbl (%eax),%eax
80108737:	0f be d8             	movsbl %al,%ebx
8010873a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010873d:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108740:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108743:	89 d0                	mov    %edx,%eax
80108745:	c1 e0 04             	shl    $0x4,%eax
80108748:	29 d0                	sub    %edx,%eax
8010874a:	83 c0 02             	add    $0x2,%eax
8010874d:	83 ec 04             	sub    $0x4,%esp
80108750:	53                   	push   %ebx
80108751:	51                   	push   %ecx
80108752:	50                   	push   %eax
80108753:	e8 e7 fe ff ff       	call   8010863f <font_render>
80108758:	83 c4 10             	add    $0x10,%esp
    i++;
8010875b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010875f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108762:	8b 45 08             	mov    0x8(%ebp),%eax
80108765:	01 d0                	add    %edx,%eax
80108767:	0f b6 00             	movzbl (%eax),%eax
8010876a:	84 c0                	test   %al,%al
8010876c:	74 06                	je     80108774 <font_render_string+0x5c>
8010876e:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108772:	7e b8                	jle    8010872c <font_render_string+0x14>
  }
}
80108774:	90                   	nop
80108775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108778:	c9                   	leave  
80108779:	c3                   	ret    

8010877a <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010877a:	f3 0f 1e fb          	endbr32 
8010877e:	55                   	push   %ebp
8010877f:	89 e5                	mov    %esp,%ebp
80108781:	53                   	push   %ebx
80108782:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108785:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010878c:	eb 6b                	jmp    801087f9 <pci_init+0x7f>
    for(int j=0;j<32;j++){
8010878e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108795:	eb 58                	jmp    801087ef <pci_init+0x75>
      for(int k=0;k<8;k++){
80108797:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010879e:	eb 45                	jmp    801087e5 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801087a0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801087a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801087a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a9:	83 ec 0c             	sub    $0xc,%esp
801087ac:	8d 5d e8             	lea    -0x18(%ebp),%ebx
801087af:	53                   	push   %ebx
801087b0:	6a 00                	push   $0x0
801087b2:	51                   	push   %ecx
801087b3:	52                   	push   %edx
801087b4:	50                   	push   %eax
801087b5:	e8 c0 00 00 00       	call   8010887a <pci_access_config>
801087ba:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
801087bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801087c0:	0f b7 c0             	movzwl %ax,%eax
801087c3:	3d ff ff 00 00       	cmp    $0xffff,%eax
801087c8:	74 17                	je     801087e1 <pci_init+0x67>
        pci_init_device(i,j,k);
801087ca:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801087cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801087d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d3:	83 ec 04             	sub    $0x4,%esp
801087d6:	51                   	push   %ecx
801087d7:	52                   	push   %edx
801087d8:	50                   	push   %eax
801087d9:	e8 4f 01 00 00       	call   8010892d <pci_init_device>
801087de:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801087e1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801087e5:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801087e9:	7e b5                	jle    801087a0 <pci_init+0x26>
    for(int j=0;j<32;j++){
801087eb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801087ef:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801087f3:	7e a2                	jle    80108797 <pci_init+0x1d>
  for(int i=0;i<256;i++){
801087f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087f9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108800:	7e 8c                	jle    8010878e <pci_init+0x14>
      }
      }
    }
  }
}
80108802:	90                   	nop
80108803:	90                   	nop
80108804:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108807:	c9                   	leave  
80108808:	c3                   	ret    

80108809 <pci_write_config>:

void pci_write_config(uint config){
80108809:	f3 0f 1e fb          	endbr32 
8010880d:	55                   	push   %ebp
8010880e:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108810:	8b 45 08             	mov    0x8(%ebp),%eax
80108813:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108818:	89 c0                	mov    %eax,%eax
8010881a:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010881b:	90                   	nop
8010881c:	5d                   	pop    %ebp
8010881d:	c3                   	ret    

8010881e <pci_write_data>:

void pci_write_data(uint config){
8010881e:	f3 0f 1e fb          	endbr32 
80108822:	55                   	push   %ebp
80108823:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108825:	8b 45 08             	mov    0x8(%ebp),%eax
80108828:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010882d:	89 c0                	mov    %eax,%eax
8010882f:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108830:	90                   	nop
80108831:	5d                   	pop    %ebp
80108832:	c3                   	ret    

80108833 <pci_read_config>:
uint pci_read_config(){
80108833:	f3 0f 1e fb          	endbr32 
80108837:	55                   	push   %ebp
80108838:	89 e5                	mov    %esp,%ebp
8010883a:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010883d:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108842:	ed                   	in     (%dx),%eax
80108843:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108846:	83 ec 0c             	sub    $0xc,%esp
80108849:	68 c8 00 00 00       	push   $0xc8
8010884e:	e8 e9 a8 ff ff       	call   8010313c <microdelay>
80108853:	83 c4 10             	add    $0x10,%esp
  return data;
80108856:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108859:	c9                   	leave  
8010885a:	c3                   	ret    

8010885b <pci_test>:


void pci_test(){
8010885b:	f3 0f 1e fb          	endbr32 
8010885f:	55                   	push   %ebp
80108860:	89 e5                	mov    %esp,%ebp
80108862:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108865:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010886c:	ff 75 fc             	pushl  -0x4(%ebp)
8010886f:	e8 95 ff ff ff       	call   80108809 <pci_write_config>
80108874:	83 c4 04             	add    $0x4,%esp
}
80108877:	90                   	nop
80108878:	c9                   	leave  
80108879:	c3                   	ret    

8010887a <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010887a:	f3 0f 1e fb          	endbr32 
8010887e:	55                   	push   %ebp
8010887f:	89 e5                	mov    %esp,%ebp
80108881:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108884:	8b 45 08             	mov    0x8(%ebp),%eax
80108887:	c1 e0 10             	shl    $0x10,%eax
8010888a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010888f:	89 c2                	mov    %eax,%edx
80108891:	8b 45 0c             	mov    0xc(%ebp),%eax
80108894:	c1 e0 0b             	shl    $0xb,%eax
80108897:	0f b7 c0             	movzwl %ax,%eax
8010889a:	09 c2                	or     %eax,%edx
8010889c:	8b 45 10             	mov    0x10(%ebp),%eax
8010889f:	c1 e0 08             	shl    $0x8,%eax
801088a2:	25 00 07 00 00       	and    $0x700,%eax
801088a7:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801088a9:	8b 45 14             	mov    0x14(%ebp),%eax
801088ac:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801088b1:	09 d0                	or     %edx,%eax
801088b3:	0d 00 00 00 80       	or     $0x80000000,%eax
801088b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
801088bb:	ff 75 f4             	pushl  -0xc(%ebp)
801088be:	e8 46 ff ff ff       	call   80108809 <pci_write_config>
801088c3:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
801088c6:	e8 68 ff ff ff       	call   80108833 <pci_read_config>
801088cb:	8b 55 18             	mov    0x18(%ebp),%edx
801088ce:	89 02                	mov    %eax,(%edx)
}
801088d0:	90                   	nop
801088d1:	c9                   	leave  
801088d2:	c3                   	ret    

801088d3 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801088d3:	f3 0f 1e fb          	endbr32 
801088d7:	55                   	push   %ebp
801088d8:	89 e5                	mov    %esp,%ebp
801088da:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801088dd:	8b 45 08             	mov    0x8(%ebp),%eax
801088e0:	c1 e0 10             	shl    $0x10,%eax
801088e3:	25 00 00 ff 00       	and    $0xff0000,%eax
801088e8:	89 c2                	mov    %eax,%edx
801088ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801088ed:	c1 e0 0b             	shl    $0xb,%eax
801088f0:	0f b7 c0             	movzwl %ax,%eax
801088f3:	09 c2                	or     %eax,%edx
801088f5:	8b 45 10             	mov    0x10(%ebp),%eax
801088f8:	c1 e0 08             	shl    $0x8,%eax
801088fb:	25 00 07 00 00       	and    $0x700,%eax
80108900:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108902:	8b 45 14             	mov    0x14(%ebp),%eax
80108905:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010890a:	09 d0                	or     %edx,%eax
8010890c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108911:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108914:	ff 75 fc             	pushl  -0x4(%ebp)
80108917:	e8 ed fe ff ff       	call   80108809 <pci_write_config>
8010891c:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
8010891f:	ff 75 18             	pushl  0x18(%ebp)
80108922:	e8 f7 fe ff ff       	call   8010881e <pci_write_data>
80108927:	83 c4 04             	add    $0x4,%esp
}
8010892a:	90                   	nop
8010892b:	c9                   	leave  
8010892c:	c3                   	ret    

8010892d <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
8010892d:	f3 0f 1e fb          	endbr32 
80108931:	55                   	push   %ebp
80108932:	89 e5                	mov    %esp,%ebp
80108934:	53                   	push   %ebx
80108935:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108938:	8b 45 08             	mov    0x8(%ebp),%eax
8010893b:	a2 dc af 11 80       	mov    %al,0x8011afdc
  dev.device_num = device_num;
80108940:	8b 45 0c             	mov    0xc(%ebp),%eax
80108943:	a2 dd af 11 80       	mov    %al,0x8011afdd
  dev.function_num = function_num;
80108948:	8b 45 10             	mov    0x10(%ebp),%eax
8010894b:	a2 de af 11 80       	mov    %al,0x8011afde
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108950:	ff 75 10             	pushl  0x10(%ebp)
80108953:	ff 75 0c             	pushl  0xc(%ebp)
80108956:	ff 75 08             	pushl  0x8(%ebp)
80108959:	68 a4 c4 10 80       	push   $0x8010c4a4
8010895e:	e8 a9 7a ff ff       	call   8010040c <cprintf>
80108963:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108966:	83 ec 0c             	sub    $0xc,%esp
80108969:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010896c:	50                   	push   %eax
8010896d:	6a 00                	push   $0x0
8010896f:	ff 75 10             	pushl  0x10(%ebp)
80108972:	ff 75 0c             	pushl  0xc(%ebp)
80108975:	ff 75 08             	pushl  0x8(%ebp)
80108978:	e8 fd fe ff ff       	call   8010887a <pci_access_config>
8010897d:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108980:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108983:	c1 e8 10             	shr    $0x10,%eax
80108986:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108989:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010898c:	25 ff ff 00 00       	and    $0xffff,%eax
80108991:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108997:	a3 e0 af 11 80       	mov    %eax,0x8011afe0
  dev.vendor_id = vendor_id;
8010899c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010899f:	a3 e4 af 11 80       	mov    %eax,0x8011afe4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
801089a4:	83 ec 04             	sub    $0x4,%esp
801089a7:	ff 75 f0             	pushl  -0x10(%ebp)
801089aa:	ff 75 f4             	pushl  -0xc(%ebp)
801089ad:	68 d8 c4 10 80       	push   $0x8010c4d8
801089b2:	e8 55 7a ff ff       	call   8010040c <cprintf>
801089b7:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
801089ba:	83 ec 0c             	sub    $0xc,%esp
801089bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089c0:	50                   	push   %eax
801089c1:	6a 08                	push   $0x8
801089c3:	ff 75 10             	pushl  0x10(%ebp)
801089c6:	ff 75 0c             	pushl  0xc(%ebp)
801089c9:	ff 75 08             	pushl  0x8(%ebp)
801089cc:	e8 a9 fe ff ff       	call   8010887a <pci_access_config>
801089d1:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089d7:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801089da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089dd:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089e0:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801089e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089e6:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801089e9:	0f b6 c0             	movzbl %al,%eax
801089ec:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801089ef:	c1 eb 18             	shr    $0x18,%ebx
801089f2:	83 ec 0c             	sub    $0xc,%esp
801089f5:	51                   	push   %ecx
801089f6:	52                   	push   %edx
801089f7:	50                   	push   %eax
801089f8:	53                   	push   %ebx
801089f9:	68 fc c4 10 80       	push   $0x8010c4fc
801089fe:	e8 09 7a ff ff       	call   8010040c <cprintf>
80108a03:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108a06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a09:	c1 e8 18             	shr    $0x18,%eax
80108a0c:	a2 e8 af 11 80       	mov    %al,0x8011afe8
  dev.sub_class = (data>>16)&0xFF;
80108a11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a14:	c1 e8 10             	shr    $0x10,%eax
80108a17:	a2 e9 af 11 80       	mov    %al,0x8011afe9
  dev.interface = (data>>8)&0xFF;
80108a1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a1f:	c1 e8 08             	shr    $0x8,%eax
80108a22:	a2 ea af 11 80       	mov    %al,0x8011afea
  dev.revision_id = data&0xFF;
80108a27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a2a:	a2 eb af 11 80       	mov    %al,0x8011afeb
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108a2f:	83 ec 0c             	sub    $0xc,%esp
80108a32:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a35:	50                   	push   %eax
80108a36:	6a 10                	push   $0x10
80108a38:	ff 75 10             	pushl  0x10(%ebp)
80108a3b:	ff 75 0c             	pushl  0xc(%ebp)
80108a3e:	ff 75 08             	pushl  0x8(%ebp)
80108a41:	e8 34 fe ff ff       	call   8010887a <pci_access_config>
80108a46:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a4c:	a3 ec af 11 80       	mov    %eax,0x8011afec
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108a51:	83 ec 0c             	sub    $0xc,%esp
80108a54:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a57:	50                   	push   %eax
80108a58:	6a 14                	push   $0x14
80108a5a:	ff 75 10             	pushl  0x10(%ebp)
80108a5d:	ff 75 0c             	pushl  0xc(%ebp)
80108a60:	ff 75 08             	pushl  0x8(%ebp)
80108a63:	e8 12 fe ff ff       	call   8010887a <pci_access_config>
80108a68:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a6e:	a3 f0 af 11 80       	mov    %eax,0x8011aff0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108a73:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108a7a:	75 5a                	jne    80108ad6 <pci_init_device+0x1a9>
80108a7c:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108a83:	75 51                	jne    80108ad6 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108a85:	83 ec 0c             	sub    $0xc,%esp
80108a88:	68 41 c5 10 80       	push   $0x8010c541
80108a8d:	e8 7a 79 ff ff       	call   8010040c <cprintf>
80108a92:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108a95:	83 ec 0c             	sub    $0xc,%esp
80108a98:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a9b:	50                   	push   %eax
80108a9c:	68 f0 00 00 00       	push   $0xf0
80108aa1:	ff 75 10             	pushl  0x10(%ebp)
80108aa4:	ff 75 0c             	pushl  0xc(%ebp)
80108aa7:	ff 75 08             	pushl  0x8(%ebp)
80108aaa:	e8 cb fd ff ff       	call   8010887a <pci_access_config>
80108aaf:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108ab2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ab5:	83 ec 08             	sub    $0x8,%esp
80108ab8:	50                   	push   %eax
80108ab9:	68 5b c5 10 80       	push   $0x8010c55b
80108abe:	e8 49 79 ff ff       	call   8010040c <cprintf>
80108ac3:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108ac6:	83 ec 0c             	sub    $0xc,%esp
80108ac9:	68 dc af 11 80       	push   $0x8011afdc
80108ace:	e8 09 00 00 00       	call   80108adc <i8254_init>
80108ad3:	83 c4 10             	add    $0x10,%esp
  }
}
80108ad6:	90                   	nop
80108ad7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ada:	c9                   	leave  
80108adb:	c3                   	ret    

80108adc <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108adc:	f3 0f 1e fb          	endbr32 
80108ae0:	55                   	push   %ebp
80108ae1:	89 e5                	mov    %esp,%ebp
80108ae3:	53                   	push   %ebx
80108ae4:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108ae7:	8b 45 08             	mov    0x8(%ebp),%eax
80108aea:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108aee:	0f b6 c8             	movzbl %al,%ecx
80108af1:	8b 45 08             	mov    0x8(%ebp),%eax
80108af4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108af8:	0f b6 d0             	movzbl %al,%edx
80108afb:	8b 45 08             	mov    0x8(%ebp),%eax
80108afe:	0f b6 00             	movzbl (%eax),%eax
80108b01:	0f b6 c0             	movzbl %al,%eax
80108b04:	83 ec 0c             	sub    $0xc,%esp
80108b07:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108b0a:	53                   	push   %ebx
80108b0b:	6a 04                	push   $0x4
80108b0d:	51                   	push   %ecx
80108b0e:	52                   	push   %edx
80108b0f:	50                   	push   %eax
80108b10:	e8 65 fd ff ff       	call   8010887a <pci_access_config>
80108b15:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b1b:	83 c8 04             	or     $0x4,%eax
80108b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108b21:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108b24:	8b 45 08             	mov    0x8(%ebp),%eax
80108b27:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108b2b:	0f b6 c8             	movzbl %al,%ecx
80108b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80108b31:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b35:	0f b6 d0             	movzbl %al,%edx
80108b38:	8b 45 08             	mov    0x8(%ebp),%eax
80108b3b:	0f b6 00             	movzbl (%eax),%eax
80108b3e:	0f b6 c0             	movzbl %al,%eax
80108b41:	83 ec 0c             	sub    $0xc,%esp
80108b44:	53                   	push   %ebx
80108b45:	6a 04                	push   $0x4
80108b47:	51                   	push   %ecx
80108b48:	52                   	push   %edx
80108b49:	50                   	push   %eax
80108b4a:	e8 84 fd ff ff       	call   801088d3 <pci_write_config_register>
80108b4f:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108b52:	8b 45 08             	mov    0x8(%ebp),%eax
80108b55:	8b 40 10             	mov    0x10(%eax),%eax
80108b58:	05 00 00 00 40       	add    $0x40000000,%eax
80108b5d:	a3 f4 af 11 80       	mov    %eax,0x8011aff4
  uint *ctrl = (uint *)base_addr;
80108b62:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108b67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108b6a:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108b6f:	05 d8 00 00 00       	add    $0xd8,%eax
80108b74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b7a:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b83:	8b 00                	mov    (%eax),%eax
80108b85:	0d 00 00 00 04       	or     $0x4000000,%eax
80108b8a:	89 c2                	mov    %eax,%edx
80108b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8f:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b94:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9d:	8b 00                	mov    (%eax),%eax
80108b9f:	83 c8 40             	or     $0x40,%eax
80108ba2:	89 c2                	mov    %eax,%edx
80108ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba7:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bac:	8b 10                	mov    (%eax),%edx
80108bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb1:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108bb3:	83 ec 0c             	sub    $0xc,%esp
80108bb6:	68 70 c5 10 80       	push   $0x8010c570
80108bbb:	e8 4c 78 ff ff       	call   8010040c <cprintf>
80108bc0:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108bc3:	e8 c2 a1 ff ff       	call   80102d8a <kalloc>
80108bc8:	a3 f8 af 11 80       	mov    %eax,0x8011aff8
  *intr_addr = 0;
80108bcd:	a1 f8 af 11 80       	mov    0x8011aff8,%eax
80108bd2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108bd8:	a1 f8 af 11 80       	mov    0x8011aff8,%eax
80108bdd:	83 ec 08             	sub    $0x8,%esp
80108be0:	50                   	push   %eax
80108be1:	68 92 c5 10 80       	push   $0x8010c592
80108be6:	e8 21 78 ff ff       	call   8010040c <cprintf>
80108beb:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108bee:	e8 50 00 00 00       	call   80108c43 <i8254_init_recv>
  i8254_init_send();
80108bf3:	e8 6d 03 00 00       	call   80108f65 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108bf8:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108bff:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108c02:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108c09:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108c0c:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108c13:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108c16:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108c1d:	0f b6 c0             	movzbl %al,%eax
80108c20:	83 ec 0c             	sub    $0xc,%esp
80108c23:	53                   	push   %ebx
80108c24:	51                   	push   %ecx
80108c25:	52                   	push   %edx
80108c26:	50                   	push   %eax
80108c27:	68 a0 c5 10 80       	push   $0x8010c5a0
80108c2c:	e8 db 77 ff ff       	call   8010040c <cprintf>
80108c31:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108c3d:	90                   	nop
80108c3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c41:	c9                   	leave  
80108c42:	c3                   	ret    

80108c43 <i8254_init_recv>:

void i8254_init_recv(){
80108c43:	f3 0f 1e fb          	endbr32 
80108c47:	55                   	push   %ebp
80108c48:	89 e5                	mov    %esp,%ebp
80108c4a:	57                   	push   %edi
80108c4b:	56                   	push   %esi
80108c4c:	53                   	push   %ebx
80108c4d:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108c50:	83 ec 0c             	sub    $0xc,%esp
80108c53:	6a 00                	push   $0x0
80108c55:	e8 ec 04 00 00       	call   80109146 <i8254_read_eeprom>
80108c5a:	83 c4 10             	add    $0x10,%esp
80108c5d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108c60:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c63:	a2 ac 00 11 80       	mov    %al,0x801100ac
  mac_addr[1] = data_l>>8;
80108c68:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108c6b:	c1 e8 08             	shr    $0x8,%eax
80108c6e:	a2 ad 00 11 80       	mov    %al,0x801100ad
  uint data_m = i8254_read_eeprom(0x1);
80108c73:	83 ec 0c             	sub    $0xc,%esp
80108c76:	6a 01                	push   $0x1
80108c78:	e8 c9 04 00 00       	call   80109146 <i8254_read_eeprom>
80108c7d:	83 c4 10             	add    $0x10,%esp
80108c80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108c83:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c86:	a2 ae 00 11 80       	mov    %al,0x801100ae
  mac_addr[3] = data_m>>8;
80108c8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c8e:	c1 e8 08             	shr    $0x8,%eax
80108c91:	a2 af 00 11 80       	mov    %al,0x801100af
  uint data_h = i8254_read_eeprom(0x2);
80108c96:	83 ec 0c             	sub    $0xc,%esp
80108c99:	6a 02                	push   $0x2
80108c9b:	e8 a6 04 00 00       	call   80109146 <i8254_read_eeprom>
80108ca0:	83 c4 10             	add    $0x10,%esp
80108ca3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108ca6:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ca9:	a2 b0 00 11 80       	mov    %al,0x801100b0
  mac_addr[5] = data_h>>8;
80108cae:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cb1:	c1 e8 08             	shr    $0x8,%eax
80108cb4:	a2 b1 00 11 80       	mov    %al,0x801100b1
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108cb9:	0f b6 05 b1 00 11 80 	movzbl 0x801100b1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cc0:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108cc3:	0f b6 05 b0 00 11 80 	movzbl 0x801100b0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cca:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108ccd:	0f b6 05 af 00 11 80 	movzbl 0x801100af,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cd4:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108cd7:	0f b6 05 ae 00 11 80 	movzbl 0x801100ae,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cde:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108ce1:	0f b6 05 ad 00 11 80 	movzbl 0x801100ad,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ce8:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108ceb:	0f b6 05 ac 00 11 80 	movzbl 0x801100ac,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108cf2:	0f b6 c0             	movzbl %al,%eax
80108cf5:	83 ec 04             	sub    $0x4,%esp
80108cf8:	57                   	push   %edi
80108cf9:	56                   	push   %esi
80108cfa:	53                   	push   %ebx
80108cfb:	51                   	push   %ecx
80108cfc:	52                   	push   %edx
80108cfd:	50                   	push   %eax
80108cfe:	68 b8 c5 10 80       	push   $0x8010c5b8
80108d03:	e8 04 77 ff ff       	call   8010040c <cprintf>
80108d08:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108d0b:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108d10:	05 00 54 00 00       	add    $0x5400,%eax
80108d15:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108d18:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108d1d:	05 04 54 00 00       	add    $0x5404,%eax
80108d22:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108d25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d28:	c1 e0 10             	shl    $0x10,%eax
80108d2b:	0b 45 d8             	or     -0x28(%ebp),%eax
80108d2e:	89 c2                	mov    %eax,%edx
80108d30:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108d33:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108d35:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d38:	0d 00 00 00 80       	or     $0x80000000,%eax
80108d3d:	89 c2                	mov    %eax,%edx
80108d3f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108d42:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108d44:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108d49:	05 00 52 00 00       	add    $0x5200,%eax
80108d4e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108d51:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108d58:	eb 19                	jmp    80108d73 <i8254_init_recv+0x130>
    mta[i] = 0;
80108d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d64:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108d67:	01 d0                	add    %edx,%eax
80108d69:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108d6f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108d73:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108d77:	7e e1                	jle    80108d5a <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108d79:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108d7e:	05 d0 00 00 00       	add    $0xd0,%eax
80108d83:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d86:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108d89:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108d8f:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108d94:	05 c8 00 00 00       	add    $0xc8,%eax
80108d99:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d9c:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108d9f:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108da5:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108daa:	05 28 28 00 00       	add    $0x2828,%eax
80108daf:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108db2:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108db5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108dbb:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108dc0:	05 00 01 00 00       	add    $0x100,%eax
80108dc5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108dc8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108dcb:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108dd1:	e8 b4 9f ff ff       	call   80102d8a <kalloc>
80108dd6:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108dd9:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108dde:	05 00 28 00 00       	add    $0x2800,%eax
80108de3:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108de6:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108deb:	05 04 28 00 00       	add    $0x2804,%eax
80108df0:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108df3:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108df8:	05 08 28 00 00       	add    $0x2808,%eax
80108dfd:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108e00:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108e05:	05 10 28 00 00       	add    $0x2810,%eax
80108e0a:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108e0d:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108e12:	05 18 28 00 00       	add    $0x2818,%eax
80108e17:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108e1a:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108e1d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108e23:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108e26:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108e28:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108e2b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108e31:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108e34:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108e3a:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108e3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108e43:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108e46:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108e4c:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108e4f:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108e52:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108e59:	eb 73                	jmp    80108ece <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e5e:	c1 e0 04             	shl    $0x4,%eax
80108e61:	89 c2                	mov    %eax,%edx
80108e63:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e66:	01 d0                	add    %edx,%eax
80108e68:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108e6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e72:	c1 e0 04             	shl    $0x4,%eax
80108e75:	89 c2                	mov    %eax,%edx
80108e77:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e7a:	01 d0                	add    %edx,%eax
80108e7c:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108e82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e85:	c1 e0 04             	shl    $0x4,%eax
80108e88:	89 c2                	mov    %eax,%edx
80108e8a:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e8d:	01 d0                	add    %edx,%eax
80108e8f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108e95:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e98:	c1 e0 04             	shl    $0x4,%eax
80108e9b:	89 c2                	mov    %eax,%edx
80108e9d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ea0:	01 d0                	add    %edx,%eax
80108ea2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108ea6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ea9:	c1 e0 04             	shl    $0x4,%eax
80108eac:	89 c2                	mov    %eax,%edx
80108eae:	8b 45 98             	mov    -0x68(%ebp),%eax
80108eb1:	01 d0                	add    %edx,%eax
80108eb3:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108eb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108eba:	c1 e0 04             	shl    $0x4,%eax
80108ebd:	89 c2                	mov    %eax,%edx
80108ebf:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ec2:	01 d0                	add    %edx,%eax
80108ec4:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108eca:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108ece:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108ed5:	7e 84                	jle    80108e5b <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108ed7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108ede:	eb 57                	jmp    80108f37 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108ee0:	e8 a5 9e ff ff       	call   80102d8a <kalloc>
80108ee5:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108ee8:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108eec:	75 12                	jne    80108f00 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108eee:	83 ec 0c             	sub    $0xc,%esp
80108ef1:	68 d8 c5 10 80       	push   $0x8010c5d8
80108ef6:	e8 11 75 ff ff       	call   8010040c <cprintf>
80108efb:	83 c4 10             	add    $0x10,%esp
      break;
80108efe:	eb 3d                	jmp    80108f3d <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108f00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f03:	c1 e0 04             	shl    $0x4,%eax
80108f06:	89 c2                	mov    %eax,%edx
80108f08:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f0b:	01 d0                	add    %edx,%eax
80108f0d:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108f10:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108f16:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108f18:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f1b:	83 c0 01             	add    $0x1,%eax
80108f1e:	c1 e0 04             	shl    $0x4,%eax
80108f21:	89 c2                	mov    %eax,%edx
80108f23:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f26:	01 d0                	add    %edx,%eax
80108f28:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108f2b:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108f31:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108f33:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108f37:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108f3b:	7e a3                	jle    80108ee0 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108f3d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f40:	8b 00                	mov    (%eax),%eax
80108f42:	83 c8 02             	or     $0x2,%eax
80108f45:	89 c2                	mov    %eax,%edx
80108f47:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f4a:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108f4c:	83 ec 0c             	sub    $0xc,%esp
80108f4f:	68 f8 c5 10 80       	push   $0x8010c5f8
80108f54:	e8 b3 74 ff ff       	call   8010040c <cprintf>
80108f59:	83 c4 10             	add    $0x10,%esp
}
80108f5c:	90                   	nop
80108f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108f60:	5b                   	pop    %ebx
80108f61:	5e                   	pop    %esi
80108f62:	5f                   	pop    %edi
80108f63:	5d                   	pop    %ebp
80108f64:	c3                   	ret    

80108f65 <i8254_init_send>:

void i8254_init_send(){
80108f65:	f3 0f 1e fb          	endbr32 
80108f69:	55                   	push   %ebp
80108f6a:	89 e5                	mov    %esp,%ebp
80108f6c:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108f6f:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108f74:	05 28 38 00 00       	add    $0x3828,%eax
80108f79:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f7f:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108f85:	e8 00 9e ff ff       	call   80102d8a <kalloc>
80108f8a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108f8d:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108f92:	05 00 38 00 00       	add    $0x3800,%eax
80108f97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108f9a:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108f9f:	05 04 38 00 00       	add    $0x3804,%eax
80108fa4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108fa7:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108fac:	05 08 38 00 00       	add    $0x3808,%eax
80108fb1:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108fb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fb7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108fbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fc0:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108fc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108fcb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108fce:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108fd4:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108fd9:	05 10 38 00 00       	add    $0x3810,%eax
80108fde:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108fe1:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80108fe6:	05 18 38 00 00       	add    $0x3818,%eax
80108feb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108fee:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108ff1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108ff7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ffa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109000:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109003:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109006:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010900d:	e9 82 00 00 00       	jmp    80109094 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80109012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109015:	c1 e0 04             	shl    $0x4,%eax
80109018:	89 c2                	mov    %eax,%edx
8010901a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010901d:	01 d0                	add    %edx,%eax
8010901f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80109026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109029:	c1 e0 04             	shl    $0x4,%eax
8010902c:	89 c2                	mov    %eax,%edx
8010902e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109031:	01 d0                	add    %edx,%eax
80109033:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010903c:	c1 e0 04             	shl    $0x4,%eax
8010903f:	89 c2                	mov    %eax,%edx
80109041:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109044:	01 d0                	add    %edx,%eax
80109046:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
8010904a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010904d:	c1 e0 04             	shl    $0x4,%eax
80109050:	89 c2                	mov    %eax,%edx
80109052:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109055:	01 d0                	add    %edx,%eax
80109057:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
8010905b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010905e:	c1 e0 04             	shl    $0x4,%eax
80109061:	89 c2                	mov    %eax,%edx
80109063:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109066:	01 d0                	add    %edx,%eax
80109068:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
8010906c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010906f:	c1 e0 04             	shl    $0x4,%eax
80109072:	89 c2                	mov    %eax,%edx
80109074:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109077:	01 d0                	add    %edx,%eax
80109079:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
8010907d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109080:	c1 e0 04             	shl    $0x4,%eax
80109083:	89 c2                	mov    %eax,%edx
80109085:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109088:	01 d0                	add    %edx,%eax
8010908a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109090:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109094:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010909b:	0f 8e 71 ff ff ff    	jle    80109012 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801090a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801090a8:	eb 57                	jmp    80109101 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
801090aa:	e8 db 9c ff ff       	call   80102d8a <kalloc>
801090af:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801090b2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801090b6:	75 12                	jne    801090ca <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
801090b8:	83 ec 0c             	sub    $0xc,%esp
801090bb:	68 d8 c5 10 80       	push   $0x8010c5d8
801090c0:	e8 47 73 ff ff       	call   8010040c <cprintf>
801090c5:	83 c4 10             	add    $0x10,%esp
      break;
801090c8:	eb 3d                	jmp    80109107 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
801090ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090cd:	c1 e0 04             	shl    $0x4,%eax
801090d0:	89 c2                	mov    %eax,%edx
801090d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090d5:	01 d0                	add    %edx,%eax
801090d7:	8b 55 cc             	mov    -0x34(%ebp),%edx
801090da:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090e0:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801090e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e5:	83 c0 01             	add    $0x1,%eax
801090e8:	c1 e0 04             	shl    $0x4,%eax
801090eb:	89 c2                	mov    %eax,%edx
801090ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090f0:	01 d0                	add    %edx,%eax
801090f2:	8b 55 cc             	mov    -0x34(%ebp),%edx
801090f5:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801090fb:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801090fd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109101:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109105:	7e a3                	jle    801090aa <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109107:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
8010910c:	05 00 04 00 00       	add    $0x400,%eax
80109111:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109114:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109117:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010911d:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80109122:	05 10 04 00 00       	add    $0x410,%eax
80109127:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010912a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010912d:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109133:	83 ec 0c             	sub    $0xc,%esp
80109136:	68 18 c6 10 80       	push   $0x8010c618
8010913b:	e8 cc 72 ff ff       	call   8010040c <cprintf>
80109140:	83 c4 10             	add    $0x10,%esp

}
80109143:	90                   	nop
80109144:	c9                   	leave  
80109145:	c3                   	ret    

80109146 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109146:	f3 0f 1e fb          	endbr32 
8010914a:	55                   	push   %ebp
8010914b:	89 e5                	mov    %esp,%ebp
8010914d:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109150:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80109155:	83 c0 14             	add    $0x14,%eax
80109158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010915b:	8b 45 08             	mov    0x8(%ebp),%eax
8010915e:	c1 e0 08             	shl    $0x8,%eax
80109161:	0f b7 c0             	movzwl %ax,%eax
80109164:	83 c8 01             	or     $0x1,%eax
80109167:	89 c2                	mov    %eax,%edx
80109169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916c:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010916e:	83 ec 0c             	sub    $0xc,%esp
80109171:	68 38 c6 10 80       	push   $0x8010c638
80109176:	e8 91 72 ff ff       	call   8010040c <cprintf>
8010917b:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010917e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109181:	8b 00                	mov    (%eax),%eax
80109183:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109186:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109189:	83 e0 10             	and    $0x10,%eax
8010918c:	85 c0                	test   %eax,%eax
8010918e:	75 02                	jne    80109192 <i8254_read_eeprom+0x4c>
  while(1){
80109190:	eb dc                	jmp    8010916e <i8254_read_eeprom+0x28>
      break;
80109192:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109196:	8b 00                	mov    (%eax),%eax
80109198:	c1 e8 10             	shr    $0x10,%eax
}
8010919b:	c9                   	leave  
8010919c:	c3                   	ret    

8010919d <i8254_recv>:
void i8254_recv(){
8010919d:	f3 0f 1e fb          	endbr32 
801091a1:	55                   	push   %ebp
801091a2:	89 e5                	mov    %esp,%ebp
801091a4:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801091a7:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
801091ac:	05 10 28 00 00       	add    $0x2810,%eax
801091b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801091b4:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
801091b9:	05 18 28 00 00       	add    $0x2818,%eax
801091be:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
801091c1:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
801091c6:	05 00 28 00 00       	add    $0x2800,%eax
801091cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
801091ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091d1:	8b 00                	mov    (%eax),%eax
801091d3:	05 00 00 00 80       	add    $0x80000000,%eax
801091d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801091db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091de:	8b 10                	mov    (%eax),%edx
801091e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091e3:	8b 00                	mov    (%eax),%eax
801091e5:	29 c2                	sub    %eax,%edx
801091e7:	89 d0                	mov    %edx,%eax
801091e9:	25 ff 00 00 00       	and    $0xff,%eax
801091ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801091f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801091f5:	7e 37                	jle    8010922e <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801091f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091fa:	8b 00                	mov    (%eax),%eax
801091fc:	c1 e0 04             	shl    $0x4,%eax
801091ff:	89 c2                	mov    %eax,%edx
80109201:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109204:	01 d0                	add    %edx,%eax
80109206:	8b 00                	mov    (%eax),%eax
80109208:	05 00 00 00 80       	add    $0x80000000,%eax
8010920d:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109210:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109213:	8b 00                	mov    (%eax),%eax
80109215:	83 c0 01             	add    $0x1,%eax
80109218:	0f b6 d0             	movzbl %al,%edx
8010921b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010921e:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109220:	83 ec 0c             	sub    $0xc,%esp
80109223:	ff 75 e0             	pushl  -0x20(%ebp)
80109226:	e8 47 09 00 00       	call   80109b72 <eth_proc>
8010922b:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
8010922e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109231:	8b 10                	mov    (%eax),%edx
80109233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109236:	8b 00                	mov    (%eax),%eax
80109238:	39 c2                	cmp    %eax,%edx
8010923a:	75 9f                	jne    801091db <i8254_recv+0x3e>
      (*rdt)--;
8010923c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010923f:	8b 00                	mov    (%eax),%eax
80109241:	8d 50 ff             	lea    -0x1(%eax),%edx
80109244:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109247:	89 10                	mov    %edx,(%eax)
  while(1){
80109249:	eb 90                	jmp    801091db <i8254_recv+0x3e>

8010924b <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010924b:	f3 0f 1e fb          	endbr32 
8010924f:	55                   	push   %ebp
80109250:	89 e5                	mov    %esp,%ebp
80109252:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109255:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
8010925a:	05 10 38 00 00       	add    $0x3810,%eax
8010925f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109262:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80109267:	05 18 38 00 00       	add    $0x3818,%eax
8010926c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010926f:	a1 f4 af 11 80       	mov    0x8011aff4,%eax
80109274:	05 00 38 00 00       	add    $0x3800,%eax
80109279:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010927c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010927f:	8b 00                	mov    (%eax),%eax
80109281:	05 00 00 00 80       	add    $0x80000000,%eax
80109286:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109289:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010928c:	8b 10                	mov    (%eax),%edx
8010928e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109291:	8b 00                	mov    (%eax),%eax
80109293:	29 c2                	sub    %eax,%edx
80109295:	89 d0                	mov    %edx,%eax
80109297:	0f b6 c0             	movzbl %al,%eax
8010929a:	ba 00 01 00 00       	mov    $0x100,%edx
8010929f:	29 c2                	sub    %eax,%edx
801092a1:	89 d0                	mov    %edx,%eax
801092a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801092a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092a9:	8b 00                	mov    (%eax),%eax
801092ab:	25 ff 00 00 00       	and    $0xff,%eax
801092b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801092b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801092b7:	0f 8e a8 00 00 00    	jle    80109365 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
801092bd:	8b 45 08             	mov    0x8(%ebp),%eax
801092c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801092c3:	89 d1                	mov    %edx,%ecx
801092c5:	c1 e1 04             	shl    $0x4,%ecx
801092c8:	8b 55 e8             	mov    -0x18(%ebp),%edx
801092cb:	01 ca                	add    %ecx,%edx
801092cd:	8b 12                	mov    (%edx),%edx
801092cf:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801092d5:	83 ec 04             	sub    $0x4,%esp
801092d8:	ff 75 0c             	pushl  0xc(%ebp)
801092db:	50                   	push   %eax
801092dc:	52                   	push   %edx
801092dd:	e8 31 be ff ff       	call   80105113 <memmove>
801092e2:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801092e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092e8:	c1 e0 04             	shl    $0x4,%eax
801092eb:	89 c2                	mov    %eax,%edx
801092ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092f0:	01 d0                	add    %edx,%eax
801092f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801092f5:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801092f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092fc:	c1 e0 04             	shl    $0x4,%eax
801092ff:	89 c2                	mov    %eax,%edx
80109301:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109304:	01 d0                	add    %edx,%eax
80109306:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010930a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010930d:	c1 e0 04             	shl    $0x4,%eax
80109310:	89 c2                	mov    %eax,%edx
80109312:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109315:	01 d0                	add    %edx,%eax
80109317:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010931b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010931e:	c1 e0 04             	shl    $0x4,%eax
80109321:	89 c2                	mov    %eax,%edx
80109323:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109326:	01 d0                	add    %edx,%eax
80109328:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010932c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010932f:	c1 e0 04             	shl    $0x4,%eax
80109332:	89 c2                	mov    %eax,%edx
80109334:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109337:	01 d0                	add    %edx,%eax
80109339:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
8010933f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109342:	c1 e0 04             	shl    $0x4,%eax
80109345:	89 c2                	mov    %eax,%edx
80109347:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010934a:	01 d0                	add    %edx,%eax
8010934c:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109353:	8b 00                	mov    (%eax),%eax
80109355:	83 c0 01             	add    $0x1,%eax
80109358:	0f b6 d0             	movzbl %al,%edx
8010935b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010935e:	89 10                	mov    %edx,(%eax)
    return len;
80109360:	8b 45 0c             	mov    0xc(%ebp),%eax
80109363:	eb 05                	jmp    8010936a <i8254_send+0x11f>
  }else{
    return -1;
80109365:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010936a:	c9                   	leave  
8010936b:	c3                   	ret    

8010936c <i8254_intr>:

void i8254_intr(){
8010936c:	f3 0f 1e fb          	endbr32 
80109370:	55                   	push   %ebp
80109371:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109373:	a1 f8 af 11 80       	mov    0x8011aff8,%eax
80109378:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010937e:	90                   	nop
8010937f:	5d                   	pop    %ebp
80109380:	c3                   	ret    

80109381 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109381:	f3 0f 1e fb          	endbr32 
80109385:	55                   	push   %ebp
80109386:	89 e5                	mov    %esp,%ebp
80109388:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010938b:	8b 45 08             	mov    0x8(%ebp),%eax
8010938e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109394:	0f b7 00             	movzwl (%eax),%eax
80109397:	66 3d 00 01          	cmp    $0x100,%ax
8010939b:	74 0a                	je     801093a7 <arp_proc+0x26>
8010939d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093a2:	e9 4f 01 00 00       	jmp    801094f6 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801093a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093aa:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801093ae:	66 83 f8 08          	cmp    $0x8,%ax
801093b2:	74 0a                	je     801093be <arp_proc+0x3d>
801093b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093b9:	e9 38 01 00 00       	jmp    801094f6 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
801093be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c1:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801093c5:	3c 06                	cmp    $0x6,%al
801093c7:	74 0a                	je     801093d3 <arp_proc+0x52>
801093c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093ce:	e9 23 01 00 00       	jmp    801094f6 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
801093d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d6:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801093da:	3c 04                	cmp    $0x4,%al
801093dc:	74 0a                	je     801093e8 <arp_proc+0x67>
801093de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801093e3:	e9 0e 01 00 00       	jmp    801094f6 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801093e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093eb:	83 c0 18             	add    $0x18,%eax
801093ee:	83 ec 04             	sub    $0x4,%esp
801093f1:	6a 04                	push   $0x4
801093f3:	50                   	push   %eax
801093f4:	68 e4 f4 10 80       	push   $0x8010f4e4
801093f9:	e8 b9 bc ff ff       	call   801050b7 <memcmp>
801093fe:	83 c4 10             	add    $0x10,%esp
80109401:	85 c0                	test   %eax,%eax
80109403:	74 27                	je     8010942c <arp_proc+0xab>
80109405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109408:	83 c0 0e             	add    $0xe,%eax
8010940b:	83 ec 04             	sub    $0x4,%esp
8010940e:	6a 04                	push   $0x4
80109410:	50                   	push   %eax
80109411:	68 e4 f4 10 80       	push   $0x8010f4e4
80109416:	e8 9c bc ff ff       	call   801050b7 <memcmp>
8010941b:	83 c4 10             	add    $0x10,%esp
8010941e:	85 c0                	test   %eax,%eax
80109420:	74 0a                	je     8010942c <arp_proc+0xab>
80109422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109427:	e9 ca 00 00 00       	jmp    801094f6 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010942c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010942f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109433:	66 3d 00 01          	cmp    $0x100,%ax
80109437:	75 69                	jne    801094a2 <arp_proc+0x121>
80109439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010943c:	83 c0 18             	add    $0x18,%eax
8010943f:	83 ec 04             	sub    $0x4,%esp
80109442:	6a 04                	push   $0x4
80109444:	50                   	push   %eax
80109445:	68 e4 f4 10 80       	push   $0x8010f4e4
8010944a:	e8 68 bc ff ff       	call   801050b7 <memcmp>
8010944f:	83 c4 10             	add    $0x10,%esp
80109452:	85 c0                	test   %eax,%eax
80109454:	75 4c                	jne    801094a2 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109456:	e8 2f 99 ff ff       	call   80102d8a <kalloc>
8010945b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010945e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109465:	83 ec 04             	sub    $0x4,%esp
80109468:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010946b:	50                   	push   %eax
8010946c:	ff 75 f0             	pushl  -0x10(%ebp)
8010946f:	ff 75 f4             	pushl  -0xc(%ebp)
80109472:	e8 33 04 00 00       	call   801098aa <arp_reply_pkt_create>
80109477:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
8010947a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010947d:	83 ec 08             	sub    $0x8,%esp
80109480:	50                   	push   %eax
80109481:	ff 75 f0             	pushl  -0x10(%ebp)
80109484:	e8 c2 fd ff ff       	call   8010924b <i8254_send>
80109489:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010948c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010948f:	83 ec 0c             	sub    $0xc,%esp
80109492:	50                   	push   %eax
80109493:	e8 54 98 ff ff       	call   80102cec <kfree>
80109498:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010949b:	b8 02 00 00 00       	mov    $0x2,%eax
801094a0:	eb 54                	jmp    801094f6 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801094a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801094a9:	66 3d 00 02          	cmp    $0x200,%ax
801094ad:	75 42                	jne    801094f1 <arp_proc+0x170>
801094af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b2:	83 c0 18             	add    $0x18,%eax
801094b5:	83 ec 04             	sub    $0x4,%esp
801094b8:	6a 04                	push   $0x4
801094ba:	50                   	push   %eax
801094bb:	68 e4 f4 10 80       	push   $0x8010f4e4
801094c0:	e8 f2 bb ff ff       	call   801050b7 <memcmp>
801094c5:	83 c4 10             	add    $0x10,%esp
801094c8:	85 c0                	test   %eax,%eax
801094ca:	75 25                	jne    801094f1 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
801094cc:	83 ec 0c             	sub    $0xc,%esp
801094cf:	68 3c c6 10 80       	push   $0x8010c63c
801094d4:	e8 33 6f ff ff       	call   8010040c <cprintf>
801094d9:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801094dc:	83 ec 0c             	sub    $0xc,%esp
801094df:	ff 75 f4             	pushl  -0xc(%ebp)
801094e2:	e8 b7 01 00 00       	call   8010969e <arp_table_update>
801094e7:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801094ea:	b8 01 00 00 00       	mov    $0x1,%eax
801094ef:	eb 05                	jmp    801094f6 <arp_proc+0x175>
  }else{
    return -1;
801094f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801094f6:	c9                   	leave  
801094f7:	c3                   	ret    

801094f8 <arp_scan>:

void arp_scan(){
801094f8:	f3 0f 1e fb          	endbr32 
801094fc:	55                   	push   %ebp
801094fd:	89 e5                	mov    %esp,%ebp
801094ff:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109502:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109509:	eb 6f                	jmp    8010957a <arp_scan+0x82>
    uint send = (uint)kalloc();
8010950b:	e8 7a 98 ff ff       	call   80102d8a <kalloc>
80109510:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109513:	83 ec 04             	sub    $0x4,%esp
80109516:	ff 75 f4             	pushl  -0xc(%ebp)
80109519:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010951c:	50                   	push   %eax
8010951d:	ff 75 ec             	pushl  -0x14(%ebp)
80109520:	e8 62 00 00 00       	call   80109587 <arp_broadcast>
80109525:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109528:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010952b:	83 ec 08             	sub    $0x8,%esp
8010952e:	50                   	push   %eax
8010952f:	ff 75 ec             	pushl  -0x14(%ebp)
80109532:	e8 14 fd ff ff       	call   8010924b <i8254_send>
80109537:	83 c4 10             	add    $0x10,%esp
8010953a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010953d:	eb 22                	jmp    80109561 <arp_scan+0x69>
      microdelay(1);
8010953f:	83 ec 0c             	sub    $0xc,%esp
80109542:	6a 01                	push   $0x1
80109544:	e8 f3 9b ff ff       	call   8010313c <microdelay>
80109549:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010954c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010954f:	83 ec 08             	sub    $0x8,%esp
80109552:	50                   	push   %eax
80109553:	ff 75 ec             	pushl  -0x14(%ebp)
80109556:	e8 f0 fc ff ff       	call   8010924b <i8254_send>
8010955b:	83 c4 10             	add    $0x10,%esp
8010955e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109561:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109565:	74 d8                	je     8010953f <arp_scan+0x47>
    }
    kfree((char *)send);
80109567:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010956a:	83 ec 0c             	sub    $0xc,%esp
8010956d:	50                   	push   %eax
8010956e:	e8 79 97 ff ff       	call   80102cec <kfree>
80109573:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109576:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010957a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109581:	7e 88                	jle    8010950b <arp_scan+0x13>
  }
}
80109583:	90                   	nop
80109584:	90                   	nop
80109585:	c9                   	leave  
80109586:	c3                   	ret    

80109587 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109587:	f3 0f 1e fb          	endbr32 
8010958b:	55                   	push   %ebp
8010958c:	89 e5                	mov    %esp,%ebp
8010958e:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109591:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109595:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109599:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010959d:	8b 45 10             	mov    0x10(%ebp),%eax
801095a0:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801095a3:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801095aa:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
801095b0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801095b7:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801095bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801095c0:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801095c6:	8b 45 08             	mov    0x8(%ebp),%eax
801095c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801095cc:	8b 45 08             	mov    0x8(%ebp),%eax
801095cf:	83 c0 0e             	add    $0xe,%eax
801095d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801095d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801095dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095df:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801095e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e6:	83 ec 04             	sub    $0x4,%esp
801095e9:	6a 06                	push   $0x6
801095eb:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801095ee:	52                   	push   %edx
801095ef:	50                   	push   %eax
801095f0:	e8 1e bb ff ff       	call   80105113 <memmove>
801095f5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801095f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095fb:	83 c0 06             	add    $0x6,%eax
801095fe:	83 ec 04             	sub    $0x4,%esp
80109601:	6a 06                	push   $0x6
80109603:	68 ac 00 11 80       	push   $0x801100ac
80109608:	50                   	push   %eax
80109609:	e8 05 bb ff ff       	call   80105113 <memmove>
8010960e:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109614:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109619:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010961c:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109625:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010962c:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109630:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109633:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010963c:	8d 50 12             	lea    0x12(%eax),%edx
8010963f:	83 ec 04             	sub    $0x4,%esp
80109642:	6a 06                	push   $0x6
80109644:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109647:	50                   	push   %eax
80109648:	52                   	push   %edx
80109649:	e8 c5 ba ff ff       	call   80105113 <memmove>
8010964e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109651:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109654:	8d 50 18             	lea    0x18(%eax),%edx
80109657:	83 ec 04             	sub    $0x4,%esp
8010965a:	6a 04                	push   $0x4
8010965c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010965f:	50                   	push   %eax
80109660:	52                   	push   %edx
80109661:	e8 ad ba ff ff       	call   80105113 <memmove>
80109666:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109669:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010966c:	83 c0 08             	add    $0x8,%eax
8010966f:	83 ec 04             	sub    $0x4,%esp
80109672:	6a 06                	push   $0x6
80109674:	68 ac 00 11 80       	push   $0x801100ac
80109679:	50                   	push   %eax
8010967a:	e8 94 ba ff ff       	call   80105113 <memmove>
8010967f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109682:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109685:	83 c0 0e             	add    $0xe,%eax
80109688:	83 ec 04             	sub    $0x4,%esp
8010968b:	6a 04                	push   $0x4
8010968d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109692:	50                   	push   %eax
80109693:	e8 7b ba ff ff       	call   80105113 <memmove>
80109698:	83 c4 10             	add    $0x10,%esp
}
8010969b:	90                   	nop
8010969c:	c9                   	leave  
8010969d:	c3                   	ret    

8010969e <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010969e:	f3 0f 1e fb          	endbr32 
801096a2:	55                   	push   %ebp
801096a3:	89 e5                	mov    %esp,%ebp
801096a5:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801096a8:	8b 45 08             	mov    0x8(%ebp),%eax
801096ab:	83 c0 0e             	add    $0xe,%eax
801096ae:	83 ec 0c             	sub    $0xc,%esp
801096b1:	50                   	push   %eax
801096b2:	e8 bc 00 00 00       	call   80109773 <arp_table_search>
801096b7:	83 c4 10             	add    $0x10,%esp
801096ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
801096bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801096c1:	78 2d                	js     801096f0 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801096c3:	8b 45 08             	mov    0x8(%ebp),%eax
801096c6:	8d 48 08             	lea    0x8(%eax),%ecx
801096c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096cc:	89 d0                	mov    %edx,%eax
801096ce:	c1 e0 02             	shl    $0x2,%eax
801096d1:	01 d0                	add    %edx,%eax
801096d3:	01 c0                	add    %eax,%eax
801096d5:	01 d0                	add    %edx,%eax
801096d7:	05 c0 00 11 80       	add    $0x801100c0,%eax
801096dc:	83 c0 04             	add    $0x4,%eax
801096df:	83 ec 04             	sub    $0x4,%esp
801096e2:	6a 06                	push   $0x6
801096e4:	51                   	push   %ecx
801096e5:	50                   	push   %eax
801096e6:	e8 28 ba ff ff       	call   80105113 <memmove>
801096eb:	83 c4 10             	add    $0x10,%esp
801096ee:	eb 70                	jmp    80109760 <arp_table_update+0xc2>
  }else{
    index += 1;
801096f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801096f4:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801096f7:	8b 45 08             	mov    0x8(%ebp),%eax
801096fa:	8d 48 08             	lea    0x8(%eax),%ecx
801096fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109700:	89 d0                	mov    %edx,%eax
80109702:	c1 e0 02             	shl    $0x2,%eax
80109705:	01 d0                	add    %edx,%eax
80109707:	01 c0                	add    %eax,%eax
80109709:	01 d0                	add    %edx,%eax
8010970b:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109710:	83 c0 04             	add    $0x4,%eax
80109713:	83 ec 04             	sub    $0x4,%esp
80109716:	6a 06                	push   $0x6
80109718:	51                   	push   %ecx
80109719:	50                   	push   %eax
8010971a:	e8 f4 b9 ff ff       	call   80105113 <memmove>
8010971f:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109722:	8b 45 08             	mov    0x8(%ebp),%eax
80109725:	8d 48 0e             	lea    0xe(%eax),%ecx
80109728:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010972b:	89 d0                	mov    %edx,%eax
8010972d:	c1 e0 02             	shl    $0x2,%eax
80109730:	01 d0                	add    %edx,%eax
80109732:	01 c0                	add    %eax,%eax
80109734:	01 d0                	add    %edx,%eax
80109736:	05 c0 00 11 80       	add    $0x801100c0,%eax
8010973b:	83 ec 04             	sub    $0x4,%esp
8010973e:	6a 04                	push   $0x4
80109740:	51                   	push   %ecx
80109741:	50                   	push   %eax
80109742:	e8 cc b9 ff ff       	call   80105113 <memmove>
80109747:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010974a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010974d:	89 d0                	mov    %edx,%eax
8010974f:	c1 e0 02             	shl    $0x2,%eax
80109752:	01 d0                	add    %edx,%eax
80109754:	01 c0                	add    %eax,%eax
80109756:	01 d0                	add    %edx,%eax
80109758:	05 ca 00 11 80       	add    $0x801100ca,%eax
8010975d:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109760:	83 ec 0c             	sub    $0xc,%esp
80109763:	68 c0 00 11 80       	push   $0x801100c0
80109768:	e8 87 00 00 00       	call   801097f4 <print_arp_table>
8010976d:	83 c4 10             	add    $0x10,%esp
}
80109770:	90                   	nop
80109771:	c9                   	leave  
80109772:	c3                   	ret    

80109773 <arp_table_search>:

int arp_table_search(uchar *ip){
80109773:	f3 0f 1e fb          	endbr32 
80109777:	55                   	push   %ebp
80109778:	89 e5                	mov    %esp,%ebp
8010977a:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010977d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109784:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010978b:	eb 59                	jmp    801097e6 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010978d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109790:	89 d0                	mov    %edx,%eax
80109792:	c1 e0 02             	shl    $0x2,%eax
80109795:	01 d0                	add    %edx,%eax
80109797:	01 c0                	add    %eax,%eax
80109799:	01 d0                	add    %edx,%eax
8010979b:	05 c0 00 11 80       	add    $0x801100c0,%eax
801097a0:	83 ec 04             	sub    $0x4,%esp
801097a3:	6a 04                	push   $0x4
801097a5:	ff 75 08             	pushl  0x8(%ebp)
801097a8:	50                   	push   %eax
801097a9:	e8 09 b9 ff ff       	call   801050b7 <memcmp>
801097ae:	83 c4 10             	add    $0x10,%esp
801097b1:	85 c0                	test   %eax,%eax
801097b3:	75 05                	jne    801097ba <arp_table_search+0x47>
      return i;
801097b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097b8:	eb 38                	jmp    801097f2 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
801097ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
801097bd:	89 d0                	mov    %edx,%eax
801097bf:	c1 e0 02             	shl    $0x2,%eax
801097c2:	01 d0                	add    %edx,%eax
801097c4:	01 c0                	add    %eax,%eax
801097c6:	01 d0                	add    %edx,%eax
801097c8:	05 ca 00 11 80       	add    $0x801100ca,%eax
801097cd:	0f b6 00             	movzbl (%eax),%eax
801097d0:	84 c0                	test   %al,%al
801097d2:	75 0e                	jne    801097e2 <arp_table_search+0x6f>
801097d4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801097d8:	75 08                	jne    801097e2 <arp_table_search+0x6f>
      empty = -i;
801097da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097dd:	f7 d8                	neg    %eax
801097df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801097e2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801097e6:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801097ea:	7e a1                	jle    8010978d <arp_table_search+0x1a>
    }
  }
  return empty-1;
801097ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ef:	83 e8 01             	sub    $0x1,%eax
}
801097f2:	c9                   	leave  
801097f3:	c3                   	ret    

801097f4 <print_arp_table>:

void print_arp_table(){
801097f4:	f3 0f 1e fb          	endbr32 
801097f8:	55                   	push   %ebp
801097f9:	89 e5                	mov    %esp,%ebp
801097fb:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801097fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109805:	e9 92 00 00 00       	jmp    8010989c <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
8010980a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010980d:	89 d0                	mov    %edx,%eax
8010980f:	c1 e0 02             	shl    $0x2,%eax
80109812:	01 d0                	add    %edx,%eax
80109814:	01 c0                	add    %eax,%eax
80109816:	01 d0                	add    %edx,%eax
80109818:	05 ca 00 11 80       	add    $0x801100ca,%eax
8010981d:	0f b6 00             	movzbl (%eax),%eax
80109820:	84 c0                	test   %al,%al
80109822:	74 74                	je     80109898 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109824:	83 ec 08             	sub    $0x8,%esp
80109827:	ff 75 f4             	pushl  -0xc(%ebp)
8010982a:	68 4f c6 10 80       	push   $0x8010c64f
8010982f:	e8 d8 6b ff ff       	call   8010040c <cprintf>
80109834:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109837:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010983a:	89 d0                	mov    %edx,%eax
8010983c:	c1 e0 02             	shl    $0x2,%eax
8010983f:	01 d0                	add    %edx,%eax
80109841:	01 c0                	add    %eax,%eax
80109843:	01 d0                	add    %edx,%eax
80109845:	05 c0 00 11 80       	add    $0x801100c0,%eax
8010984a:	83 ec 0c             	sub    $0xc,%esp
8010984d:	50                   	push   %eax
8010984e:	e8 5c 02 00 00       	call   80109aaf <print_ipv4>
80109853:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109856:	83 ec 0c             	sub    $0xc,%esp
80109859:	68 5e c6 10 80       	push   $0x8010c65e
8010985e:	e8 a9 6b ff ff       	call   8010040c <cprintf>
80109863:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109866:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109869:	89 d0                	mov    %edx,%eax
8010986b:	c1 e0 02             	shl    $0x2,%eax
8010986e:	01 d0                	add    %edx,%eax
80109870:	01 c0                	add    %eax,%eax
80109872:	01 d0                	add    %edx,%eax
80109874:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109879:	83 c0 04             	add    $0x4,%eax
8010987c:	83 ec 0c             	sub    $0xc,%esp
8010987f:	50                   	push   %eax
80109880:	e8 7c 02 00 00       	call   80109b01 <print_mac>
80109885:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109888:	83 ec 0c             	sub    $0xc,%esp
8010988b:	68 60 c6 10 80       	push   $0x8010c660
80109890:	e8 77 6b ff ff       	call   8010040c <cprintf>
80109895:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109898:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010989c:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801098a0:	0f 8e 64 ff ff ff    	jle    8010980a <print_arp_table+0x16>
    }
  }
}
801098a6:	90                   	nop
801098a7:	90                   	nop
801098a8:	c9                   	leave  
801098a9:	c3                   	ret    

801098aa <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801098aa:	f3 0f 1e fb          	endbr32 
801098ae:	55                   	push   %ebp
801098af:	89 e5                	mov    %esp,%ebp
801098b1:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801098b4:	8b 45 10             	mov    0x10(%ebp),%eax
801098b7:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
801098bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801098c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
801098c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801098c6:	83 c0 0e             	add    $0xe,%eax
801098c9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
801098cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098cf:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801098d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d6:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801098da:	8b 45 08             	mov    0x8(%ebp),%eax
801098dd:	8d 50 08             	lea    0x8(%eax),%edx
801098e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098e3:	83 ec 04             	sub    $0x4,%esp
801098e6:	6a 06                	push   $0x6
801098e8:	52                   	push   %edx
801098e9:	50                   	push   %eax
801098ea:	e8 24 b8 ff ff       	call   80105113 <memmove>
801098ef:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801098f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098f5:	83 c0 06             	add    $0x6,%eax
801098f8:	83 ec 04             	sub    $0x4,%esp
801098fb:	6a 06                	push   $0x6
801098fd:	68 ac 00 11 80       	push   $0x801100ac
80109902:	50                   	push   %eax
80109903:	e8 0b b8 ff ff       	call   80105113 <memmove>
80109908:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010990b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010990e:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109913:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109916:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010991c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010991f:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109923:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109926:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010992a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010992d:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109933:	8b 45 08             	mov    0x8(%ebp),%eax
80109936:	8d 50 08             	lea    0x8(%eax),%edx
80109939:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010993c:	83 c0 12             	add    $0x12,%eax
8010993f:	83 ec 04             	sub    $0x4,%esp
80109942:	6a 06                	push   $0x6
80109944:	52                   	push   %edx
80109945:	50                   	push   %eax
80109946:	e8 c8 b7 ff ff       	call   80105113 <memmove>
8010994b:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010994e:	8b 45 08             	mov    0x8(%ebp),%eax
80109951:	8d 50 0e             	lea    0xe(%eax),%edx
80109954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109957:	83 c0 18             	add    $0x18,%eax
8010995a:	83 ec 04             	sub    $0x4,%esp
8010995d:	6a 04                	push   $0x4
8010995f:	52                   	push   %edx
80109960:	50                   	push   %eax
80109961:	e8 ad b7 ff ff       	call   80105113 <memmove>
80109966:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010996c:	83 c0 08             	add    $0x8,%eax
8010996f:	83 ec 04             	sub    $0x4,%esp
80109972:	6a 06                	push   $0x6
80109974:	68 ac 00 11 80       	push   $0x801100ac
80109979:	50                   	push   %eax
8010997a:	e8 94 b7 ff ff       	call   80105113 <memmove>
8010997f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109982:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109985:	83 c0 0e             	add    $0xe,%eax
80109988:	83 ec 04             	sub    $0x4,%esp
8010998b:	6a 04                	push   $0x4
8010998d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109992:	50                   	push   %eax
80109993:	e8 7b b7 ff ff       	call   80105113 <memmove>
80109998:	83 c4 10             	add    $0x10,%esp
}
8010999b:	90                   	nop
8010999c:	c9                   	leave  
8010999d:	c3                   	ret    

8010999e <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010999e:	f3 0f 1e fb          	endbr32 
801099a2:	55                   	push   %ebp
801099a3:	89 e5                	mov    %esp,%ebp
801099a5:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801099a8:	83 ec 0c             	sub    $0xc,%esp
801099ab:	68 62 c6 10 80       	push   $0x8010c662
801099b0:	e8 57 6a ff ff       	call   8010040c <cprintf>
801099b5:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801099b8:	8b 45 08             	mov    0x8(%ebp),%eax
801099bb:	83 c0 0e             	add    $0xe,%eax
801099be:	83 ec 0c             	sub    $0xc,%esp
801099c1:	50                   	push   %eax
801099c2:	e8 e8 00 00 00       	call   80109aaf <print_ipv4>
801099c7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801099ca:	83 ec 0c             	sub    $0xc,%esp
801099cd:	68 60 c6 10 80       	push   $0x8010c660
801099d2:	e8 35 6a ff ff       	call   8010040c <cprintf>
801099d7:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801099da:	8b 45 08             	mov    0x8(%ebp),%eax
801099dd:	83 c0 08             	add    $0x8,%eax
801099e0:	83 ec 0c             	sub    $0xc,%esp
801099e3:	50                   	push   %eax
801099e4:	e8 18 01 00 00       	call   80109b01 <print_mac>
801099e9:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801099ec:	83 ec 0c             	sub    $0xc,%esp
801099ef:	68 60 c6 10 80       	push   $0x8010c660
801099f4:	e8 13 6a ff ff       	call   8010040c <cprintf>
801099f9:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801099fc:	83 ec 0c             	sub    $0xc,%esp
801099ff:	68 79 c6 10 80       	push   $0x8010c679
80109a04:	e8 03 6a ff ff       	call   8010040c <cprintf>
80109a09:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0f:	83 c0 18             	add    $0x18,%eax
80109a12:	83 ec 0c             	sub    $0xc,%esp
80109a15:	50                   	push   %eax
80109a16:	e8 94 00 00 00       	call   80109aaf <print_ipv4>
80109a1b:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109a1e:	83 ec 0c             	sub    $0xc,%esp
80109a21:	68 60 c6 10 80       	push   $0x8010c660
80109a26:	e8 e1 69 ff ff       	call   8010040c <cprintf>
80109a2b:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80109a31:	83 c0 12             	add    $0x12,%eax
80109a34:	83 ec 0c             	sub    $0xc,%esp
80109a37:	50                   	push   %eax
80109a38:	e8 c4 00 00 00       	call   80109b01 <print_mac>
80109a3d:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109a40:	83 ec 0c             	sub    $0xc,%esp
80109a43:	68 60 c6 10 80       	push   $0x8010c660
80109a48:	e8 bf 69 ff ff       	call   8010040c <cprintf>
80109a4d:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109a50:	83 ec 0c             	sub    $0xc,%esp
80109a53:	68 90 c6 10 80       	push   $0x8010c690
80109a58:	e8 af 69 ff ff       	call   8010040c <cprintf>
80109a5d:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109a60:	8b 45 08             	mov    0x8(%ebp),%eax
80109a63:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a67:	66 3d 00 01          	cmp    $0x100,%ax
80109a6b:	75 12                	jne    80109a7f <print_arp_info+0xe1>
80109a6d:	83 ec 0c             	sub    $0xc,%esp
80109a70:	68 9c c6 10 80       	push   $0x8010c69c
80109a75:	e8 92 69 ff ff       	call   8010040c <cprintf>
80109a7a:	83 c4 10             	add    $0x10,%esp
80109a7d:	eb 1d                	jmp    80109a9c <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109a7f:	8b 45 08             	mov    0x8(%ebp),%eax
80109a82:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a86:	66 3d 00 02          	cmp    $0x200,%ax
80109a8a:	75 10                	jne    80109a9c <print_arp_info+0xfe>
    cprintf("Reply\n");
80109a8c:	83 ec 0c             	sub    $0xc,%esp
80109a8f:	68 a5 c6 10 80       	push   $0x8010c6a5
80109a94:	e8 73 69 ff ff       	call   8010040c <cprintf>
80109a99:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109a9c:	83 ec 0c             	sub    $0xc,%esp
80109a9f:	68 60 c6 10 80       	push   $0x8010c660
80109aa4:	e8 63 69 ff ff       	call   8010040c <cprintf>
80109aa9:	83 c4 10             	add    $0x10,%esp
}
80109aac:	90                   	nop
80109aad:	c9                   	leave  
80109aae:	c3                   	ret    

80109aaf <print_ipv4>:

void print_ipv4(uchar *ip){
80109aaf:	f3 0f 1e fb          	endbr32 
80109ab3:	55                   	push   %ebp
80109ab4:	89 e5                	mov    %esp,%ebp
80109ab6:	53                   	push   %ebx
80109ab7:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109aba:	8b 45 08             	mov    0x8(%ebp),%eax
80109abd:	83 c0 03             	add    $0x3,%eax
80109ac0:	0f b6 00             	movzbl (%eax),%eax
80109ac3:	0f b6 d8             	movzbl %al,%ebx
80109ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac9:	83 c0 02             	add    $0x2,%eax
80109acc:	0f b6 00             	movzbl (%eax),%eax
80109acf:	0f b6 c8             	movzbl %al,%ecx
80109ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad5:	83 c0 01             	add    $0x1,%eax
80109ad8:	0f b6 00             	movzbl (%eax),%eax
80109adb:	0f b6 d0             	movzbl %al,%edx
80109ade:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae1:	0f b6 00             	movzbl (%eax),%eax
80109ae4:	0f b6 c0             	movzbl %al,%eax
80109ae7:	83 ec 0c             	sub    $0xc,%esp
80109aea:	53                   	push   %ebx
80109aeb:	51                   	push   %ecx
80109aec:	52                   	push   %edx
80109aed:	50                   	push   %eax
80109aee:	68 ac c6 10 80       	push   $0x8010c6ac
80109af3:	e8 14 69 ff ff       	call   8010040c <cprintf>
80109af8:	83 c4 20             	add    $0x20,%esp
}
80109afb:	90                   	nop
80109afc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109aff:	c9                   	leave  
80109b00:	c3                   	ret    

80109b01 <print_mac>:

void print_mac(uchar *mac){
80109b01:	f3 0f 1e fb          	endbr32 
80109b05:	55                   	push   %ebp
80109b06:	89 e5                	mov    %esp,%ebp
80109b08:	57                   	push   %edi
80109b09:	56                   	push   %esi
80109b0a:	53                   	push   %ebx
80109b0b:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b11:	83 c0 05             	add    $0x5,%eax
80109b14:	0f b6 00             	movzbl (%eax),%eax
80109b17:	0f b6 f8             	movzbl %al,%edi
80109b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1d:	83 c0 04             	add    $0x4,%eax
80109b20:	0f b6 00             	movzbl (%eax),%eax
80109b23:	0f b6 f0             	movzbl %al,%esi
80109b26:	8b 45 08             	mov    0x8(%ebp),%eax
80109b29:	83 c0 03             	add    $0x3,%eax
80109b2c:	0f b6 00             	movzbl (%eax),%eax
80109b2f:	0f b6 d8             	movzbl %al,%ebx
80109b32:	8b 45 08             	mov    0x8(%ebp),%eax
80109b35:	83 c0 02             	add    $0x2,%eax
80109b38:	0f b6 00             	movzbl (%eax),%eax
80109b3b:	0f b6 c8             	movzbl %al,%ecx
80109b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b41:	83 c0 01             	add    $0x1,%eax
80109b44:	0f b6 00             	movzbl (%eax),%eax
80109b47:	0f b6 d0             	movzbl %al,%edx
80109b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4d:	0f b6 00             	movzbl (%eax),%eax
80109b50:	0f b6 c0             	movzbl %al,%eax
80109b53:	83 ec 04             	sub    $0x4,%esp
80109b56:	57                   	push   %edi
80109b57:	56                   	push   %esi
80109b58:	53                   	push   %ebx
80109b59:	51                   	push   %ecx
80109b5a:	52                   	push   %edx
80109b5b:	50                   	push   %eax
80109b5c:	68 c4 c6 10 80       	push   $0x8010c6c4
80109b61:	e8 a6 68 ff ff       	call   8010040c <cprintf>
80109b66:	83 c4 20             	add    $0x20,%esp
}
80109b69:	90                   	nop
80109b6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109b6d:	5b                   	pop    %ebx
80109b6e:	5e                   	pop    %esi
80109b6f:	5f                   	pop    %edi
80109b70:	5d                   	pop    %ebp
80109b71:	c3                   	ret    

80109b72 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109b72:	f3 0f 1e fb          	endbr32 
80109b76:	55                   	push   %ebp
80109b77:	89 e5                	mov    %esp,%ebp
80109b79:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80109b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109b82:	8b 45 08             	mov    0x8(%ebp),%eax
80109b85:	83 c0 0e             	add    $0xe,%eax
80109b88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b8e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109b92:	3c 08                	cmp    $0x8,%al
80109b94:	75 1b                	jne    80109bb1 <eth_proc+0x3f>
80109b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b99:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b9d:	3c 06                	cmp    $0x6,%al
80109b9f:	75 10                	jne    80109bb1 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109ba1:	83 ec 0c             	sub    $0xc,%esp
80109ba4:	ff 75 f0             	pushl  -0x10(%ebp)
80109ba7:	e8 d5 f7 ff ff       	call   80109381 <arp_proc>
80109bac:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109baf:	eb 24                	jmp    80109bd5 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bb4:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109bb8:	3c 08                	cmp    $0x8,%al
80109bba:	75 19                	jne    80109bd5 <eth_proc+0x63>
80109bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bbf:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109bc3:	84 c0                	test   %al,%al
80109bc5:	75 0e                	jne    80109bd5 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109bc7:	83 ec 0c             	sub    $0xc,%esp
80109bca:	ff 75 08             	pushl  0x8(%ebp)
80109bcd:	e8 b3 00 00 00       	call   80109c85 <ipv4_proc>
80109bd2:	83 c4 10             	add    $0x10,%esp
}
80109bd5:	90                   	nop
80109bd6:	c9                   	leave  
80109bd7:	c3                   	ret    

80109bd8 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109bd8:	f3 0f 1e fb          	endbr32 
80109bdc:	55                   	push   %ebp
80109bdd:	89 e5                	mov    %esp,%ebp
80109bdf:	83 ec 04             	sub    $0x4,%esp
80109be2:	8b 45 08             	mov    0x8(%ebp),%eax
80109be5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109be9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109bed:	c1 e0 08             	shl    $0x8,%eax
80109bf0:	89 c2                	mov    %eax,%edx
80109bf2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109bf6:	66 c1 e8 08          	shr    $0x8,%ax
80109bfa:	01 d0                	add    %edx,%eax
}
80109bfc:	c9                   	leave  
80109bfd:	c3                   	ret    

80109bfe <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109bfe:	f3 0f 1e fb          	endbr32 
80109c02:	55                   	push   %ebp
80109c03:	89 e5                	mov    %esp,%ebp
80109c05:	83 ec 04             	sub    $0x4,%esp
80109c08:	8b 45 08             	mov    0x8(%ebp),%eax
80109c0b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109c0f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109c13:	c1 e0 08             	shl    $0x8,%eax
80109c16:	89 c2                	mov    %eax,%edx
80109c18:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109c1c:	66 c1 e8 08          	shr    $0x8,%ax
80109c20:	01 d0                	add    %edx,%eax
}
80109c22:	c9                   	leave  
80109c23:	c3                   	ret    

80109c24 <H2N_uint>:

uint H2N_uint(uint value){
80109c24:	f3 0f 1e fb          	endbr32 
80109c28:	55                   	push   %ebp
80109c29:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c2e:	c1 e0 18             	shl    $0x18,%eax
80109c31:	25 00 00 00 0f       	and    $0xf000000,%eax
80109c36:	89 c2                	mov    %eax,%edx
80109c38:	8b 45 08             	mov    0x8(%ebp),%eax
80109c3b:	c1 e0 08             	shl    $0x8,%eax
80109c3e:	25 00 f0 00 00       	and    $0xf000,%eax
80109c43:	09 c2                	or     %eax,%edx
80109c45:	8b 45 08             	mov    0x8(%ebp),%eax
80109c48:	c1 e8 08             	shr    $0x8,%eax
80109c4b:	83 e0 0f             	and    $0xf,%eax
80109c4e:	01 d0                	add    %edx,%eax
}
80109c50:	5d                   	pop    %ebp
80109c51:	c3                   	ret    

80109c52 <N2H_uint>:

uint N2H_uint(uint value){
80109c52:	f3 0f 1e fb          	endbr32 
80109c56:	55                   	push   %ebp
80109c57:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109c59:	8b 45 08             	mov    0x8(%ebp),%eax
80109c5c:	c1 e0 18             	shl    $0x18,%eax
80109c5f:	89 c2                	mov    %eax,%edx
80109c61:	8b 45 08             	mov    0x8(%ebp),%eax
80109c64:	c1 e0 08             	shl    $0x8,%eax
80109c67:	25 00 00 ff 00       	and    $0xff0000,%eax
80109c6c:	01 c2                	add    %eax,%edx
80109c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80109c71:	c1 e8 08             	shr    $0x8,%eax
80109c74:	25 00 ff 00 00       	and    $0xff00,%eax
80109c79:	01 c2                	add    %eax,%edx
80109c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c7e:	c1 e8 18             	shr    $0x18,%eax
80109c81:	01 d0                	add    %edx,%eax
}
80109c83:	5d                   	pop    %ebp
80109c84:	c3                   	ret    

80109c85 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109c85:	f3 0f 1e fb          	endbr32 
80109c89:	55                   	push   %ebp
80109c8a:	89 e5                	mov    %esp,%ebp
80109c8c:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c92:	83 c0 0e             	add    $0xe,%eax
80109c95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c9b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109c9f:	0f b7 d0             	movzwl %ax,%edx
80109ca2:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109ca7:	39 c2                	cmp    %eax,%edx
80109ca9:	74 60                	je     80109d0b <ipv4_proc+0x86>
80109cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cae:	83 c0 0c             	add    $0xc,%eax
80109cb1:	83 ec 04             	sub    $0x4,%esp
80109cb4:	6a 04                	push   $0x4
80109cb6:	50                   	push   %eax
80109cb7:	68 e4 f4 10 80       	push   $0x8010f4e4
80109cbc:	e8 f6 b3 ff ff       	call   801050b7 <memcmp>
80109cc1:	83 c4 10             	add    $0x10,%esp
80109cc4:	85 c0                	test   %eax,%eax
80109cc6:	74 43                	je     80109d0b <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ccb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ccf:	0f b7 c0             	movzwl %ax,%eax
80109cd2:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cda:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109cde:	3c 01                	cmp    $0x1,%al
80109ce0:	75 10                	jne    80109cf2 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109ce2:	83 ec 0c             	sub    $0xc,%esp
80109ce5:	ff 75 08             	pushl  0x8(%ebp)
80109ce8:	e8 a7 00 00 00       	call   80109d94 <icmp_proc>
80109ced:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109cf0:	eb 19                	jmp    80109d0b <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cf5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109cf9:	3c 06                	cmp    $0x6,%al
80109cfb:	75 0e                	jne    80109d0b <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109cfd:	83 ec 0c             	sub    $0xc,%esp
80109d00:	ff 75 08             	pushl  0x8(%ebp)
80109d03:	e8 c7 03 00 00       	call   8010a0cf <tcp_proc>
80109d08:	83 c4 10             	add    $0x10,%esp
}
80109d0b:	90                   	nop
80109d0c:	c9                   	leave  
80109d0d:	c3                   	ret    

80109d0e <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109d0e:	f3 0f 1e fb          	endbr32 
80109d12:	55                   	push   %ebp
80109d13:	89 e5                	mov    %esp,%ebp
80109d15:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109d18:	8b 45 08             	mov    0x8(%ebp),%eax
80109d1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d21:	0f b6 00             	movzbl (%eax),%eax
80109d24:	83 e0 0f             	and    $0xf,%eax
80109d27:	01 c0                	add    %eax,%eax
80109d29:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109d2c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109d33:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109d3a:	eb 48                	jmp    80109d84 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d3f:	01 c0                	add    %eax,%eax
80109d41:	89 c2                	mov    %eax,%edx
80109d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d46:	01 d0                	add    %edx,%eax
80109d48:	0f b6 00             	movzbl (%eax),%eax
80109d4b:	0f b6 c0             	movzbl %al,%eax
80109d4e:	c1 e0 08             	shl    $0x8,%eax
80109d51:	89 c2                	mov    %eax,%edx
80109d53:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d56:	01 c0                	add    %eax,%eax
80109d58:	8d 48 01             	lea    0x1(%eax),%ecx
80109d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d5e:	01 c8                	add    %ecx,%eax
80109d60:	0f b6 00             	movzbl (%eax),%eax
80109d63:	0f b6 c0             	movzbl %al,%eax
80109d66:	01 d0                	add    %edx,%eax
80109d68:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109d6b:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109d72:	76 0c                	jbe    80109d80 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109d74:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d77:	0f b7 c0             	movzwl %ax,%eax
80109d7a:	83 c0 01             	add    $0x1,%eax
80109d7d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109d80:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109d84:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109d88:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109d8b:	7c af                	jl     80109d3c <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109d8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109d90:	f7 d0                	not    %eax
}
80109d92:	c9                   	leave  
80109d93:	c3                   	ret    

80109d94 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109d94:	f3 0f 1e fb          	endbr32 
80109d98:	55                   	push   %ebp
80109d99:	89 e5                	mov    %esp,%ebp
80109d9b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80109da1:	83 c0 0e             	add    $0xe,%eax
80109da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109daa:	0f b6 00             	movzbl (%eax),%eax
80109dad:	0f b6 c0             	movzbl %al,%eax
80109db0:	83 e0 0f             	and    $0xf,%eax
80109db3:	c1 e0 02             	shl    $0x2,%eax
80109db6:	89 c2                	mov    %eax,%edx
80109db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dbb:	01 d0                	add    %edx,%eax
80109dbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dc3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109dc7:	84 c0                	test   %al,%al
80109dc9:	75 4f                	jne    80109e1a <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dce:	0f b6 00             	movzbl (%eax),%eax
80109dd1:	3c 08                	cmp    $0x8,%al
80109dd3:	75 45                	jne    80109e1a <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109dd5:	e8 b0 8f ff ff       	call   80102d8a <kalloc>
80109dda:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109ddd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109de4:	83 ec 04             	sub    $0x4,%esp
80109de7:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109dea:	50                   	push   %eax
80109deb:	ff 75 ec             	pushl  -0x14(%ebp)
80109dee:	ff 75 08             	pushl  0x8(%ebp)
80109df1:	e8 7c 00 00 00       	call   80109e72 <icmp_reply_pkt_create>
80109df6:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dfc:	83 ec 08             	sub    $0x8,%esp
80109dff:	50                   	push   %eax
80109e00:	ff 75 ec             	pushl  -0x14(%ebp)
80109e03:	e8 43 f4 ff ff       	call   8010924b <i8254_send>
80109e08:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109e0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e0e:	83 ec 0c             	sub    $0xc,%esp
80109e11:	50                   	push   %eax
80109e12:	e8 d5 8e ff ff       	call   80102cec <kfree>
80109e17:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109e1a:	90                   	nop
80109e1b:	c9                   	leave  
80109e1c:	c3                   	ret    

80109e1d <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109e1d:	f3 0f 1e fb          	endbr32 
80109e21:	55                   	push   %ebp
80109e22:	89 e5                	mov    %esp,%ebp
80109e24:	53                   	push   %ebx
80109e25:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109e28:	8b 45 08             	mov    0x8(%ebp),%eax
80109e2b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e2f:	0f b7 c0             	movzwl %ax,%eax
80109e32:	83 ec 0c             	sub    $0xc,%esp
80109e35:	50                   	push   %eax
80109e36:	e8 9d fd ff ff       	call   80109bd8 <N2H_ushort>
80109e3b:	83 c4 10             	add    $0x10,%esp
80109e3e:	0f b7 d8             	movzwl %ax,%ebx
80109e41:	8b 45 08             	mov    0x8(%ebp),%eax
80109e44:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109e48:	0f b7 c0             	movzwl %ax,%eax
80109e4b:	83 ec 0c             	sub    $0xc,%esp
80109e4e:	50                   	push   %eax
80109e4f:	e8 84 fd ff ff       	call   80109bd8 <N2H_ushort>
80109e54:	83 c4 10             	add    $0x10,%esp
80109e57:	0f b7 c0             	movzwl %ax,%eax
80109e5a:	83 ec 04             	sub    $0x4,%esp
80109e5d:	53                   	push   %ebx
80109e5e:	50                   	push   %eax
80109e5f:	68 e3 c6 10 80       	push   $0x8010c6e3
80109e64:	e8 a3 65 ff ff       	call   8010040c <cprintf>
80109e69:	83 c4 10             	add    $0x10,%esp
}
80109e6c:	90                   	nop
80109e6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109e70:	c9                   	leave  
80109e71:	c3                   	ret    

80109e72 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109e72:	f3 0f 1e fb          	endbr32 
80109e76:	55                   	push   %ebp
80109e77:	89 e5                	mov    %esp,%ebp
80109e79:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80109e7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109e82:	8b 45 08             	mov    0x8(%ebp),%eax
80109e85:	83 c0 0e             	add    $0xe,%eax
80109e88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e8e:	0f b6 00             	movzbl (%eax),%eax
80109e91:	0f b6 c0             	movzbl %al,%eax
80109e94:	83 e0 0f             	and    $0xf,%eax
80109e97:	c1 e0 02             	shl    $0x2,%eax
80109e9a:	89 c2                	mov    %eax,%edx
80109e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e9f:	01 d0                	add    %edx,%eax
80109ea1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ea7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ead:	83 c0 0e             	add    $0xe,%eax
80109eb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109eb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109eb6:	83 c0 14             	add    $0x14,%eax
80109eb9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109ebc:	8b 45 10             	mov    0x10(%ebp),%eax
80109ebf:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ec8:	8d 50 06             	lea    0x6(%eax),%edx
80109ecb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ece:	83 ec 04             	sub    $0x4,%esp
80109ed1:	6a 06                	push   $0x6
80109ed3:	52                   	push   %edx
80109ed4:	50                   	push   %eax
80109ed5:	e8 39 b2 ff ff       	call   80105113 <memmove>
80109eda:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109edd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ee0:	83 c0 06             	add    $0x6,%eax
80109ee3:	83 ec 04             	sub    $0x4,%esp
80109ee6:	6a 06                	push   $0x6
80109ee8:	68 ac 00 11 80       	push   $0x801100ac
80109eed:	50                   	push   %eax
80109eee:	e8 20 b2 ff ff       	call   80105113 <memmove>
80109ef3:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109ef6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ef9:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109efd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f00:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109f04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f07:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109f0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f0d:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109f11:	83 ec 0c             	sub    $0xc,%esp
80109f14:	6a 54                	push   $0x54
80109f16:	e8 e3 fc ff ff       	call   80109bfe <H2N_ushort>
80109f1b:	83 c4 10             	add    $0x10,%esp
80109f1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f21:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109f25:	0f b7 15 80 03 11 80 	movzwl 0x80110380,%edx
80109f2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f2f:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109f33:	0f b7 05 80 03 11 80 	movzwl 0x80110380,%eax
80109f3a:	83 c0 01             	add    $0x1,%eax
80109f3d:	66 a3 80 03 11 80    	mov    %ax,0x80110380
  ipv4_send->fragment = H2N_ushort(0x4000);
80109f43:	83 ec 0c             	sub    $0xc,%esp
80109f46:	68 00 40 00 00       	push   $0x4000
80109f4b:	e8 ae fc ff ff       	call   80109bfe <H2N_ushort>
80109f50:	83 c4 10             	add    $0x10,%esp
80109f53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109f56:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109f5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f5d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109f61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f64:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109f68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f6b:	83 c0 0c             	add    $0xc,%eax
80109f6e:	83 ec 04             	sub    $0x4,%esp
80109f71:	6a 04                	push   $0x4
80109f73:	68 e4 f4 10 80       	push   $0x8010f4e4
80109f78:	50                   	push   %eax
80109f79:	e8 95 b1 ff ff       	call   80105113 <memmove>
80109f7e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f84:	8d 50 0c             	lea    0xc(%eax),%edx
80109f87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f8a:	83 c0 10             	add    $0x10,%eax
80109f8d:	83 ec 04             	sub    $0x4,%esp
80109f90:	6a 04                	push   $0x4
80109f92:	52                   	push   %edx
80109f93:	50                   	push   %eax
80109f94:	e8 7a b1 ff ff       	call   80105113 <memmove>
80109f99:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109f9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f9f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109fa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fa8:	83 ec 0c             	sub    $0xc,%esp
80109fab:	50                   	push   %eax
80109fac:	e8 5d fd ff ff       	call   80109d0e <ipv4_chksum>
80109fb1:	83 c4 10             	add    $0x10,%esp
80109fb4:	0f b7 c0             	movzwl %ax,%eax
80109fb7:	83 ec 0c             	sub    $0xc,%esp
80109fba:	50                   	push   %eax
80109fbb:	e8 3e fc ff ff       	call   80109bfe <H2N_ushort>
80109fc0:	83 c4 10             	add    $0x10,%esp
80109fc3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109fc6:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109fca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fcd:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109fd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fd3:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109fd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fda:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109fde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fe1:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fe8:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109fec:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109fef:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109ff3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ff6:	8d 50 08             	lea    0x8(%eax),%edx
80109ff9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ffc:	83 c0 08             	add    $0x8,%eax
80109fff:	83 ec 04             	sub    $0x4,%esp
8010a002:	6a 08                	push   $0x8
8010a004:	52                   	push   %edx
8010a005:	50                   	push   %eax
8010a006:	e8 08 b1 ff ff       	call   80105113 <memmove>
8010a00b:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a00e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a011:	8d 50 10             	lea    0x10(%eax),%edx
8010a014:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a017:	83 c0 10             	add    $0x10,%eax
8010a01a:	83 ec 04             	sub    $0x4,%esp
8010a01d:	6a 30                	push   $0x30
8010a01f:	52                   	push   %edx
8010a020:	50                   	push   %eax
8010a021:	e8 ed b0 ff ff       	call   80105113 <memmove>
8010a026:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a029:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a02c:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a032:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a035:	83 ec 0c             	sub    $0xc,%esp
8010a038:	50                   	push   %eax
8010a039:	e8 1c 00 00 00       	call   8010a05a <icmp_chksum>
8010a03e:	83 c4 10             	add    $0x10,%esp
8010a041:	0f b7 c0             	movzwl %ax,%eax
8010a044:	83 ec 0c             	sub    $0xc,%esp
8010a047:	50                   	push   %eax
8010a048:	e8 b1 fb ff ff       	call   80109bfe <H2N_ushort>
8010a04d:	83 c4 10             	add    $0x10,%esp
8010a050:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a053:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a057:	90                   	nop
8010a058:	c9                   	leave  
8010a059:	c3                   	ret    

8010a05a <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a05a:	f3 0f 1e fb          	endbr32 
8010a05e:	55                   	push   %ebp
8010a05f:	89 e5                	mov    %esp,%ebp
8010a061:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a064:	8b 45 08             	mov    0x8(%ebp),%eax
8010a067:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a06a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a071:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a078:	eb 48                	jmp    8010a0c2 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a07a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a07d:	01 c0                	add    %eax,%eax
8010a07f:	89 c2                	mov    %eax,%edx
8010a081:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a084:	01 d0                	add    %edx,%eax
8010a086:	0f b6 00             	movzbl (%eax),%eax
8010a089:	0f b6 c0             	movzbl %al,%eax
8010a08c:	c1 e0 08             	shl    $0x8,%eax
8010a08f:	89 c2                	mov    %eax,%edx
8010a091:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a094:	01 c0                	add    %eax,%eax
8010a096:	8d 48 01             	lea    0x1(%eax),%ecx
8010a099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a09c:	01 c8                	add    %ecx,%eax
8010a09e:	0f b6 00             	movzbl (%eax),%eax
8010a0a1:	0f b6 c0             	movzbl %al,%eax
8010a0a4:	01 d0                	add    %edx,%eax
8010a0a6:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a0a9:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a0b0:	76 0c                	jbe    8010a0be <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a0b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a0b5:	0f b7 c0             	movzwl %ax,%eax
8010a0b8:	83 c0 01             	add    $0x1,%eax
8010a0bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a0be:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a0c2:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a0c6:	7e b2                	jle    8010a07a <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a0c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a0cb:	f7 d0                	not    %eax
}
8010a0cd:	c9                   	leave  
8010a0ce:	c3                   	ret    

8010a0cf <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a0cf:	f3 0f 1e fb          	endbr32 
8010a0d3:	55                   	push   %ebp
8010a0d4:	89 e5                	mov    %esp,%ebp
8010a0d6:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a0d9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0dc:	83 c0 0e             	add    $0xe,%eax
8010a0df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a0e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0e5:	0f b6 00             	movzbl (%eax),%eax
8010a0e8:	0f b6 c0             	movzbl %al,%eax
8010a0eb:	83 e0 0f             	and    $0xf,%eax
8010a0ee:	c1 e0 02             	shl    $0x2,%eax
8010a0f1:	89 c2                	mov    %eax,%edx
8010a0f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0f6:	01 d0                	add    %edx,%eax
8010a0f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a0fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0fe:	83 c0 14             	add    $0x14,%eax
8010a101:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a104:	e8 81 8c ff ff       	call   80102d8a <kalloc>
8010a109:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a10c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a113:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a116:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a11a:	0f b6 c0             	movzbl %al,%eax
8010a11d:	83 e0 02             	and    $0x2,%eax
8010a120:	85 c0                	test   %eax,%eax
8010a122:	74 3d                	je     8010a161 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a124:	83 ec 0c             	sub    $0xc,%esp
8010a127:	6a 00                	push   $0x0
8010a129:	6a 12                	push   $0x12
8010a12b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a12e:	50                   	push   %eax
8010a12f:	ff 75 e8             	pushl  -0x18(%ebp)
8010a132:	ff 75 08             	pushl  0x8(%ebp)
8010a135:	e8 a2 01 00 00       	call   8010a2dc <tcp_pkt_create>
8010a13a:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a13d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a140:	83 ec 08             	sub    $0x8,%esp
8010a143:	50                   	push   %eax
8010a144:	ff 75 e8             	pushl  -0x18(%ebp)
8010a147:	e8 ff f0 ff ff       	call   8010924b <i8254_send>
8010a14c:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a14f:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a154:	83 c0 01             	add    $0x1,%eax
8010a157:	a3 84 03 11 80       	mov    %eax,0x80110384
8010a15c:	e9 69 01 00 00       	jmp    8010a2ca <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a161:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a164:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a168:	3c 18                	cmp    $0x18,%al
8010a16a:	0f 85 10 01 00 00    	jne    8010a280 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a170:	83 ec 04             	sub    $0x4,%esp
8010a173:	6a 03                	push   $0x3
8010a175:	68 fe c6 10 80       	push   $0x8010c6fe
8010a17a:	ff 75 ec             	pushl  -0x14(%ebp)
8010a17d:	e8 35 af ff ff       	call   801050b7 <memcmp>
8010a182:	83 c4 10             	add    $0x10,%esp
8010a185:	85 c0                	test   %eax,%eax
8010a187:	74 74                	je     8010a1fd <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a189:	83 ec 0c             	sub    $0xc,%esp
8010a18c:	68 02 c7 10 80       	push   $0x8010c702
8010a191:	e8 76 62 ff ff       	call   8010040c <cprintf>
8010a196:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a199:	83 ec 0c             	sub    $0xc,%esp
8010a19c:	6a 00                	push   $0x0
8010a19e:	6a 10                	push   $0x10
8010a1a0:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1a3:	50                   	push   %eax
8010a1a4:	ff 75 e8             	pushl  -0x18(%ebp)
8010a1a7:	ff 75 08             	pushl  0x8(%ebp)
8010a1aa:	e8 2d 01 00 00       	call   8010a2dc <tcp_pkt_create>
8010a1af:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a1b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1b5:	83 ec 08             	sub    $0x8,%esp
8010a1b8:	50                   	push   %eax
8010a1b9:	ff 75 e8             	pushl  -0x18(%ebp)
8010a1bc:	e8 8a f0 ff ff       	call   8010924b <i8254_send>
8010a1c1:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a1c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1c7:	83 c0 36             	add    $0x36,%eax
8010a1ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a1cd:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a1d0:	50                   	push   %eax
8010a1d1:	ff 75 e0             	pushl  -0x20(%ebp)
8010a1d4:	6a 00                	push   $0x0
8010a1d6:	6a 00                	push   $0x0
8010a1d8:	e8 66 04 00 00       	call   8010a643 <http_proc>
8010a1dd:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a1e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a1e3:	83 ec 0c             	sub    $0xc,%esp
8010a1e6:	50                   	push   %eax
8010a1e7:	6a 18                	push   $0x18
8010a1e9:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1ec:	50                   	push   %eax
8010a1ed:	ff 75 e8             	pushl  -0x18(%ebp)
8010a1f0:	ff 75 08             	pushl  0x8(%ebp)
8010a1f3:	e8 e4 00 00 00       	call   8010a2dc <tcp_pkt_create>
8010a1f8:	83 c4 20             	add    $0x20,%esp
8010a1fb:	eb 62                	jmp    8010a25f <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a1fd:	83 ec 0c             	sub    $0xc,%esp
8010a200:	6a 00                	push   $0x0
8010a202:	6a 10                	push   $0x10
8010a204:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a207:	50                   	push   %eax
8010a208:	ff 75 e8             	pushl  -0x18(%ebp)
8010a20b:	ff 75 08             	pushl  0x8(%ebp)
8010a20e:	e8 c9 00 00 00       	call   8010a2dc <tcp_pkt_create>
8010a213:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a216:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a219:	83 ec 08             	sub    $0x8,%esp
8010a21c:	50                   	push   %eax
8010a21d:	ff 75 e8             	pushl  -0x18(%ebp)
8010a220:	e8 26 f0 ff ff       	call   8010924b <i8254_send>
8010a225:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a228:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a22b:	83 c0 36             	add    $0x36,%eax
8010a22e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a231:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a234:	50                   	push   %eax
8010a235:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a238:	6a 00                	push   $0x0
8010a23a:	6a 00                	push   $0x0
8010a23c:	e8 02 04 00 00       	call   8010a643 <http_proc>
8010a241:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a244:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a247:	83 ec 0c             	sub    $0xc,%esp
8010a24a:	50                   	push   %eax
8010a24b:	6a 18                	push   $0x18
8010a24d:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a250:	50                   	push   %eax
8010a251:	ff 75 e8             	pushl  -0x18(%ebp)
8010a254:	ff 75 08             	pushl  0x8(%ebp)
8010a257:	e8 80 00 00 00       	call   8010a2dc <tcp_pkt_create>
8010a25c:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a25f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a262:	83 ec 08             	sub    $0x8,%esp
8010a265:	50                   	push   %eax
8010a266:	ff 75 e8             	pushl  -0x18(%ebp)
8010a269:	e8 dd ef ff ff       	call   8010924b <i8254_send>
8010a26e:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a271:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a276:	83 c0 01             	add    $0x1,%eax
8010a279:	a3 84 03 11 80       	mov    %eax,0x80110384
8010a27e:	eb 4a                	jmp    8010a2ca <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a280:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a283:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a287:	3c 10                	cmp    $0x10,%al
8010a289:	75 3f                	jne    8010a2ca <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a28b:	a1 88 03 11 80       	mov    0x80110388,%eax
8010a290:	83 f8 01             	cmp    $0x1,%eax
8010a293:	75 35                	jne    8010a2ca <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a295:	83 ec 0c             	sub    $0xc,%esp
8010a298:	6a 00                	push   $0x0
8010a29a:	6a 01                	push   $0x1
8010a29c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a29f:	50                   	push   %eax
8010a2a0:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2a3:	ff 75 08             	pushl  0x8(%ebp)
8010a2a6:	e8 31 00 00 00       	call   8010a2dc <tcp_pkt_create>
8010a2ab:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a2ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a2b1:	83 ec 08             	sub    $0x8,%esp
8010a2b4:	50                   	push   %eax
8010a2b5:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2b8:	e8 8e ef ff ff       	call   8010924b <i8254_send>
8010a2bd:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a2c0:	c7 05 88 03 11 80 00 	movl   $0x0,0x80110388
8010a2c7:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a2ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2cd:	83 ec 0c             	sub    $0xc,%esp
8010a2d0:	50                   	push   %eax
8010a2d1:	e8 16 8a ff ff       	call   80102cec <kfree>
8010a2d6:	83 c4 10             	add    $0x10,%esp
}
8010a2d9:	90                   	nop
8010a2da:	c9                   	leave  
8010a2db:	c3                   	ret    

8010a2dc <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a2dc:	f3 0f 1e fb          	endbr32 
8010a2e0:	55                   	push   %ebp
8010a2e1:	89 e5                	mov    %esp,%ebp
8010a2e3:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a2e6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a2ec:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ef:	83 c0 0e             	add    $0xe,%eax
8010a2f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a2f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2f8:	0f b6 00             	movzbl (%eax),%eax
8010a2fb:	0f b6 c0             	movzbl %al,%eax
8010a2fe:	83 e0 0f             	and    $0xf,%eax
8010a301:	c1 e0 02             	shl    $0x2,%eax
8010a304:	89 c2                	mov    %eax,%edx
8010a306:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a309:	01 d0                	add    %edx,%eax
8010a30b:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a30e:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a311:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a314:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a317:	83 c0 0e             	add    $0xe,%eax
8010a31a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a31d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a320:	83 c0 14             	add    $0x14,%eax
8010a323:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a326:	8b 45 18             	mov    0x18(%ebp),%eax
8010a329:	8d 50 36             	lea    0x36(%eax),%edx
8010a32c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a32f:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a331:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a334:	8d 50 06             	lea    0x6(%eax),%edx
8010a337:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a33a:	83 ec 04             	sub    $0x4,%esp
8010a33d:	6a 06                	push   $0x6
8010a33f:	52                   	push   %edx
8010a340:	50                   	push   %eax
8010a341:	e8 cd ad ff ff       	call   80105113 <memmove>
8010a346:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a349:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a34c:	83 c0 06             	add    $0x6,%eax
8010a34f:	83 ec 04             	sub    $0x4,%esp
8010a352:	6a 06                	push   $0x6
8010a354:	68 ac 00 11 80       	push   $0x801100ac
8010a359:	50                   	push   %eax
8010a35a:	e8 b4 ad ff ff       	call   80105113 <memmove>
8010a35f:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a362:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a365:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a369:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a36c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a373:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a376:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a379:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a37d:	8b 45 18             	mov    0x18(%ebp),%eax
8010a380:	83 c0 28             	add    $0x28,%eax
8010a383:	0f b7 c0             	movzwl %ax,%eax
8010a386:	83 ec 0c             	sub    $0xc,%esp
8010a389:	50                   	push   %eax
8010a38a:	e8 6f f8 ff ff       	call   80109bfe <H2N_ushort>
8010a38f:	83 c4 10             	add    $0x10,%esp
8010a392:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a395:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a399:	0f b7 15 80 03 11 80 	movzwl 0x80110380,%edx
8010a3a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3a3:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a3a7:	0f b7 05 80 03 11 80 	movzwl 0x80110380,%eax
8010a3ae:	83 c0 01             	add    $0x1,%eax
8010a3b1:	66 a3 80 03 11 80    	mov    %ax,0x80110380
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a3b7:	83 ec 0c             	sub    $0xc,%esp
8010a3ba:	6a 00                	push   $0x0
8010a3bc:	e8 3d f8 ff ff       	call   80109bfe <H2N_ushort>
8010a3c1:	83 c4 10             	add    $0x10,%esp
8010a3c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a3c7:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a3cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3ce:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a3d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3d5:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a3d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3dc:	83 c0 0c             	add    $0xc,%eax
8010a3df:	83 ec 04             	sub    $0x4,%esp
8010a3e2:	6a 04                	push   $0x4
8010a3e4:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a3e9:	50                   	push   %eax
8010a3ea:	e8 24 ad ff ff       	call   80105113 <memmove>
8010a3ef:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a3f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3f5:	8d 50 0c             	lea    0xc(%eax),%edx
8010a3f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3fb:	83 c0 10             	add    $0x10,%eax
8010a3fe:	83 ec 04             	sub    $0x4,%esp
8010a401:	6a 04                	push   $0x4
8010a403:	52                   	push   %edx
8010a404:	50                   	push   %eax
8010a405:	e8 09 ad ff ff       	call   80105113 <memmove>
8010a40a:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a40d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a410:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a416:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a419:	83 ec 0c             	sub    $0xc,%esp
8010a41c:	50                   	push   %eax
8010a41d:	e8 ec f8 ff ff       	call   80109d0e <ipv4_chksum>
8010a422:	83 c4 10             	add    $0x10,%esp
8010a425:	0f b7 c0             	movzwl %ax,%eax
8010a428:	83 ec 0c             	sub    $0xc,%esp
8010a42b:	50                   	push   %eax
8010a42c:	e8 cd f7 ff ff       	call   80109bfe <H2N_ushort>
8010a431:	83 c4 10             	add    $0x10,%esp
8010a434:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a437:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a43b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a43e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a442:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a445:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a448:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a44b:	0f b7 10             	movzwl (%eax),%edx
8010a44e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a451:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a455:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a45a:	83 ec 0c             	sub    $0xc,%esp
8010a45d:	50                   	push   %eax
8010a45e:	e8 c1 f7 ff ff       	call   80109c24 <H2N_uint>
8010a463:	83 c4 10             	add    $0x10,%esp
8010a466:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a469:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a46c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a46f:	8b 40 04             	mov    0x4(%eax),%eax
8010a472:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a478:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a47b:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a47e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a481:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a485:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a488:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a48c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a48f:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a493:	8b 45 14             	mov    0x14(%ebp),%eax
8010a496:	89 c2                	mov    %eax,%edx
8010a498:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a49b:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a49e:	83 ec 0c             	sub    $0xc,%esp
8010a4a1:	68 90 38 00 00       	push   $0x3890
8010a4a6:	e8 53 f7 ff ff       	call   80109bfe <H2N_ushort>
8010a4ab:	83 c4 10             	add    $0x10,%esp
8010a4ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a4b1:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a4b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4b8:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a4be:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4c1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a4c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4ca:	83 ec 0c             	sub    $0xc,%esp
8010a4cd:	50                   	push   %eax
8010a4ce:	e8 1f 00 00 00       	call   8010a4f2 <tcp_chksum>
8010a4d3:	83 c4 10             	add    $0x10,%esp
8010a4d6:	83 c0 08             	add    $0x8,%eax
8010a4d9:	0f b7 c0             	movzwl %ax,%eax
8010a4dc:	83 ec 0c             	sub    $0xc,%esp
8010a4df:	50                   	push   %eax
8010a4e0:	e8 19 f7 ff ff       	call   80109bfe <H2N_ushort>
8010a4e5:	83 c4 10             	add    $0x10,%esp
8010a4e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a4eb:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a4ef:	90                   	nop
8010a4f0:	c9                   	leave  
8010a4f1:	c3                   	ret    

8010a4f2 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a4f2:	f3 0f 1e fb          	endbr32 
8010a4f6:	55                   	push   %ebp
8010a4f7:	89 e5                	mov    %esp,%ebp
8010a4f9:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a4fc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a502:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a505:	83 c0 14             	add    $0x14,%eax
8010a508:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a50b:	83 ec 04             	sub    $0x4,%esp
8010a50e:	6a 04                	push   $0x4
8010a510:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a515:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a518:	50                   	push   %eax
8010a519:	e8 f5 ab ff ff       	call   80105113 <memmove>
8010a51e:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a521:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a524:	83 c0 0c             	add    $0xc,%eax
8010a527:	83 ec 04             	sub    $0x4,%esp
8010a52a:	6a 04                	push   $0x4
8010a52c:	50                   	push   %eax
8010a52d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a530:	83 c0 04             	add    $0x4,%eax
8010a533:	50                   	push   %eax
8010a534:	e8 da ab ff ff       	call   80105113 <memmove>
8010a539:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a53c:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a540:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a544:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a547:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a54b:	0f b7 c0             	movzwl %ax,%eax
8010a54e:	83 ec 0c             	sub    $0xc,%esp
8010a551:	50                   	push   %eax
8010a552:	e8 81 f6 ff ff       	call   80109bd8 <N2H_ushort>
8010a557:	83 c4 10             	add    $0x10,%esp
8010a55a:	83 e8 14             	sub    $0x14,%eax
8010a55d:	0f b7 c0             	movzwl %ax,%eax
8010a560:	83 ec 0c             	sub    $0xc,%esp
8010a563:	50                   	push   %eax
8010a564:	e8 95 f6 ff ff       	call   80109bfe <H2N_ushort>
8010a569:	83 c4 10             	add    $0x10,%esp
8010a56c:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a570:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a577:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a57a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a57d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a584:	eb 33                	jmp    8010a5b9 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a586:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a589:	01 c0                	add    %eax,%eax
8010a58b:	89 c2                	mov    %eax,%edx
8010a58d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a590:	01 d0                	add    %edx,%eax
8010a592:	0f b6 00             	movzbl (%eax),%eax
8010a595:	0f b6 c0             	movzbl %al,%eax
8010a598:	c1 e0 08             	shl    $0x8,%eax
8010a59b:	89 c2                	mov    %eax,%edx
8010a59d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5a0:	01 c0                	add    %eax,%eax
8010a5a2:	8d 48 01             	lea    0x1(%eax),%ecx
8010a5a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5a8:	01 c8                	add    %ecx,%eax
8010a5aa:	0f b6 00             	movzbl (%eax),%eax
8010a5ad:	0f b6 c0             	movzbl %al,%eax
8010a5b0:	01 d0                	add    %edx,%eax
8010a5b2:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a5b5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a5b9:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a5bd:	7e c7                	jle    8010a586 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a5bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a5c5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a5cc:	eb 33                	jmp    8010a601 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a5ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5d1:	01 c0                	add    %eax,%eax
8010a5d3:	89 c2                	mov    %eax,%edx
8010a5d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5d8:	01 d0                	add    %edx,%eax
8010a5da:	0f b6 00             	movzbl (%eax),%eax
8010a5dd:	0f b6 c0             	movzbl %al,%eax
8010a5e0:	c1 e0 08             	shl    $0x8,%eax
8010a5e3:	89 c2                	mov    %eax,%edx
8010a5e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5e8:	01 c0                	add    %eax,%eax
8010a5ea:	8d 48 01             	lea    0x1(%eax),%ecx
8010a5ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5f0:	01 c8                	add    %ecx,%eax
8010a5f2:	0f b6 00             	movzbl (%eax),%eax
8010a5f5:	0f b6 c0             	movzbl %al,%eax
8010a5f8:	01 d0                	add    %edx,%eax
8010a5fa:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a5fd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a601:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a605:	0f b7 c0             	movzwl %ax,%eax
8010a608:	83 ec 0c             	sub    $0xc,%esp
8010a60b:	50                   	push   %eax
8010a60c:	e8 c7 f5 ff ff       	call   80109bd8 <N2H_ushort>
8010a611:	83 c4 10             	add    $0x10,%esp
8010a614:	66 d1 e8             	shr    %ax
8010a617:	0f b7 c0             	movzwl %ax,%eax
8010a61a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a61d:	7c af                	jl     8010a5ce <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a61f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a622:	c1 e8 10             	shr    $0x10,%eax
8010a625:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a62b:	f7 d0                	not    %eax
}
8010a62d:	c9                   	leave  
8010a62e:	c3                   	ret    

8010a62f <tcp_fin>:

void tcp_fin(){
8010a62f:	f3 0f 1e fb          	endbr32 
8010a633:	55                   	push   %ebp
8010a634:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a636:	c7 05 88 03 11 80 01 	movl   $0x1,0x80110388
8010a63d:	00 00 00 
}
8010a640:	90                   	nop
8010a641:	5d                   	pop    %ebp
8010a642:	c3                   	ret    

8010a643 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a643:	f3 0f 1e fb          	endbr32 
8010a647:	55                   	push   %ebp
8010a648:	89 e5                	mov    %esp,%ebp
8010a64a:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a64d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a650:	83 ec 04             	sub    $0x4,%esp
8010a653:	6a 00                	push   $0x0
8010a655:	68 0b c7 10 80       	push   $0x8010c70b
8010a65a:	50                   	push   %eax
8010a65b:	e8 65 00 00 00       	call   8010a6c5 <http_strcpy>
8010a660:	83 c4 10             	add    $0x10,%esp
8010a663:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a666:	8b 45 10             	mov    0x10(%ebp),%eax
8010a669:	83 ec 04             	sub    $0x4,%esp
8010a66c:	ff 75 f4             	pushl  -0xc(%ebp)
8010a66f:	68 1e c7 10 80       	push   $0x8010c71e
8010a674:	50                   	push   %eax
8010a675:	e8 4b 00 00 00       	call   8010a6c5 <http_strcpy>
8010a67a:	83 c4 10             	add    $0x10,%esp
8010a67d:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a680:	8b 45 10             	mov    0x10(%ebp),%eax
8010a683:	83 ec 04             	sub    $0x4,%esp
8010a686:	ff 75 f4             	pushl  -0xc(%ebp)
8010a689:	68 39 c7 10 80       	push   $0x8010c739
8010a68e:	50                   	push   %eax
8010a68f:	e8 31 00 00 00       	call   8010a6c5 <http_strcpy>
8010a694:	83 c4 10             	add    $0x10,%esp
8010a697:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a69a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a69d:	83 e0 01             	and    $0x1,%eax
8010a6a0:	85 c0                	test   %eax,%eax
8010a6a2:	74 11                	je     8010a6b5 <http_proc+0x72>
    char *payload = (char *)send;
8010a6a4:	8b 45 10             	mov    0x10(%ebp),%eax
8010a6a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a6aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a6ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6b0:	01 d0                	add    %edx,%eax
8010a6b2:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a6b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a6b8:	8b 45 14             	mov    0x14(%ebp),%eax
8010a6bb:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a6bd:	e8 6d ff ff ff       	call   8010a62f <tcp_fin>
}
8010a6c2:	90                   	nop
8010a6c3:	c9                   	leave  
8010a6c4:	c3                   	ret    

8010a6c5 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a6c5:	f3 0f 1e fb          	endbr32 
8010a6c9:	55                   	push   %ebp
8010a6ca:	89 e5                	mov    %esp,%ebp
8010a6cc:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a6cf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a6d6:	eb 20                	jmp    8010a6f8 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a6d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a6db:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6de:	01 d0                	add    %edx,%eax
8010a6e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a6e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a6e6:	01 ca                	add    %ecx,%edx
8010a6e8:	89 d1                	mov    %edx,%ecx
8010a6ea:	8b 55 08             	mov    0x8(%ebp),%edx
8010a6ed:	01 ca                	add    %ecx,%edx
8010a6ef:	0f b6 00             	movzbl (%eax),%eax
8010a6f2:	88 02                	mov    %al,(%edx)
    i++;
8010a6f4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a6f8:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a6fb:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6fe:	01 d0                	add    %edx,%eax
8010a700:	0f b6 00             	movzbl (%eax),%eax
8010a703:	84 c0                	test   %al,%al
8010a705:	75 d1                	jne    8010a6d8 <http_strcpy+0x13>
  }
  return i;
8010a707:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a70a:	c9                   	leave  
8010a70b:	c3                   	ret    
