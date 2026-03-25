
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
8010005a:	bc b0 b0 11 80       	mov    $0x8011b0b0,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 49 38 10 80       	mov    $0x80103849,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 00 a6 10 80       	push   $0x8010a600
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 94 4d 00 00       	call   80104e12 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 47 11 80 fc 	movl   $0x801146fc,0x8011474c
80100088:	46 11 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 47 11 80 fc 	movl   $0x801146fc,0x80114750
80100092:	46 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 00 11 80 	movl   $0x80110034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 47 11 80    	mov    0x80114750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 07 a6 10 80       	push   $0x8010a607
801000c2:	50                   	push   %eax
801000c3:	e8 ed 4b 00 00       	call   80104cb5 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 47 11 80       	mov    0x80114750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 47 11 80       	mov    %eax,0x80114750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 46 11 80       	mov    $0x801146fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave
801000f2:	c3                   	ret

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 00 11 80       	push   $0x80110000
80100101:	e8 2e 4d 00 00       	call   80104e34 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 47 11 80       	mov    0x80114750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 00 11 80       	push   $0x80110000
80100140:	e8 5d 4d 00 00       	call   80104ea2 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 9a 4b 00 00       	call   80104cf1 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 47 11 80       	mov    0x8011474c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 00 11 80       	push   $0x80110000
801001c1:	e8 dc 4c 00 00       	call   80104ea2 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 19 4b 00 00       	call   80104cf1 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 0e a6 10 80       	push   $0x8010a60e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave
80100200:	c3                   	ret

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 ff 26 00 00       	call   80102931 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave
80100239:	c3                   	ret

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 54 4b 00 00       	call   80104da3 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 1f a6 10 80       	push   $0x8010a61f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 b4 26 00 00       	call   80102931 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave
80100282:	c3                   	ret

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 0b 4b 00 00       	call   80104da3 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 26 a6 10 80       	push   $0x8010a626
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 9a 4a 00 00       	call   80104d55 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 69 4b 00 00       	call   80104e34 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 47 11 80    	mov    0x80114750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 47 11 80       	mov    0x80114750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 47 11 80       	mov    %eax,0x80114750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 00 11 80       	push   $0x80110000
80100336:	e8 67 4b 00 00       	call   80104ea2 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave
80100340:	c3                   	ret

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8b 03 00 00       	call   8010076e <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave
801003f3:	c3                   	ret

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 4a 11 80       	mov    0x80114a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 4a 11 80       	push   $0x80114a00
80100410:	e8 1f 4a 00 00       	call   80104e34 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 2d a6 10 80       	push   $0x8010a62d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 1f 03 00 00       	call   8010076e <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 36 a6 10 80 	movl   $0x8010a636,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 43 02 00 00       	call   8010076e <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 26 02 00 00       	call   8010076e <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 17 02 00 00       	call   8010076e <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 09 02 00 00       	call   8010076e <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 4a 11 80       	push   $0x80114a00
8010059e:	e8 ff 48 00 00       	call   80104ea2 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave
801005a8:	c3                   	ret

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 4a 11 80 00 	movl   $0x0,0x80114a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 1b 2a 00 00       	call   80102fde <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 3d a6 10 80       	push   $0x8010a63d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 51 a6 10 80       	push   $0x8010a651
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 f1 48 00 00       	call   80104ef4 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 53 a6 10 80       	push   $0x8010a653
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 49 11 80 01 	movl   $0x1,0x801149ec
80100638:	00 00 00 
  for(;;)
8010063b:	90                   	nop
8010063c:	eb fd                	jmp    8010063b <panic+0x92>

8010063e <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063e:	55                   	push   %ebp
8010063f:	89 e5                	mov    %esp,%ebp
80100641:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100644:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100648:	75 64                	jne    801006ae <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010064a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100650:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100655:	89 c8                	mov    %ecx,%eax
80100657:	f7 ea                	imul   %edx
80100659:	89 d0                	mov    %edx,%eax
8010065b:	c1 f8 04             	sar    $0x4,%eax
8010065e:	89 ca                	mov    %ecx,%edx
80100660:	c1 fa 1f             	sar    $0x1f,%edx
80100663:	29 d0                	sub    %edx,%eax
80100665:	6b d0 35             	imul   $0x35,%eax,%edx
80100668:	89 c8                	mov    %ecx,%eax
8010066a:	29 d0                	sub    %edx,%eax
8010066c:	ba 35 00 00 00       	mov    $0x35,%edx
80100671:	29 c2                	sub    %eax,%edx
80100673:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100678:	01 d0                	add    %edx,%eax
8010067a:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100684:	3d 23 04 00 00       	cmp    $0x423,%eax
80100689:	0f 8e dc 00 00 00    	jle    8010076b <graphic_putc+0x12d>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100694:	83 e8 35             	sub    $0x35,%eax
80100697:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069c:	83 ec 0c             	sub    $0xc,%esp
8010069f:	6a 1e                	push   $0x1e
801006a1:	e8 db 7e 00 00       	call   80108581 <graphic_scroll_up>
801006a6:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a9:	e9 bd 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
  }else if(c == BACKSPACE){
801006ae:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b5:	75 1f                	jne    801006d6 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bc:	85 c0                	test   %eax,%eax
801006be:	0f 8e a7 00 00 00    	jle    8010076b <graphic_putc+0x12d>
801006c4:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c9:	83 e8 01             	sub    $0x1,%eax
801006cc:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d1:	e9 95 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006db:	3d 23 04 00 00       	cmp    $0x423,%eax
801006e0:	7e 1a                	jle    801006fc <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e7:	83 e8 35             	sub    $0x35,%eax
801006ea:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ef:	83 ec 0c             	sub    $0xc,%esp
801006f2:	6a 1e                	push   $0x1e
801006f4:	e8 88 7e 00 00       	call   80108581 <graphic_scroll_up>
801006f9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fc:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100702:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	f7 ea                	imul   %edx
8010070b:	89 d0                	mov    %edx,%eax
8010070d:	c1 f8 04             	sar    $0x4,%eax
80100710:	89 ca                	mov    %ecx,%edx
80100712:	c1 fa 1f             	sar    $0x1f,%edx
80100715:	29 d0                	sub    %edx,%eax
80100717:	6b d0 35             	imul   $0x35,%eax,%edx
8010071a:	89 c8                	mov    %ecx,%eax
8010071c:	29 d0                	sub    %edx,%eax
8010071e:	89 c2                	mov    %eax,%edx
80100720:	c1 e2 04             	shl    $0x4,%edx
80100723:	29 c2                	sub    %eax,%edx
80100725:	8d 42 02             	lea    0x2(%edx),%eax
80100728:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072b:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100731:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100736:	89 c8                	mov    %ecx,%eax
80100738:	f7 ea                	imul   %edx
8010073a:	c1 fa 04             	sar    $0x4,%edx
8010073d:	89 c8                	mov    %ecx,%eax
8010073f:	c1 f8 1f             	sar    $0x1f,%eax
80100742:	29 c2                	sub    %eax,%edx
80100744:	6b c2 1e             	imul   $0x1e,%edx,%eax
80100747:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074a:	83 ec 04             	sub    $0x4,%esp
8010074d:	ff 75 08             	push   0x8(%ebp)
80100750:	ff 75 f0             	push   -0x10(%ebp)
80100753:	ff 75 f4             	push   -0xc(%ebp)
80100756:	e8 93 7e 00 00       	call   801085ee <font_render>
8010075b:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100763:	83 c0 01             	add    $0x1,%eax
80100766:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076b:	90                   	nop
8010076c:	c9                   	leave
8010076d:	c3                   	ret

8010076e <consputc>:


void
consputc(int c)
{
8010076e:	55                   	push   %ebp
8010076f:	89 e5                	mov    %esp,%ebp
80100771:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100774:	a1 ec 49 11 80       	mov    0x801149ec,%eax
80100779:	85 c0                	test   %eax,%eax
8010077b:	74 08                	je     80100785 <consputc+0x17>
    cli();
8010077d:	e8 bf fb ff ff       	call   80100341 <cli>
    for(;;)
80100782:	90                   	nop
80100783:	eb fd                	jmp    80100782 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 62 62 00 00       	call   801069fa <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 55 62 00 00       	call   801069fa <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 48 62 00 00       	call   801069fa <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 38 62 00 00       	call   801069fa <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6e fe ff ff       	call   8010063e <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave
801007d5:	c3                   	ret

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 4a 11 80       	push   $0x80114a00
801007eb:	e8 44 46 00 00       	call   80104e34 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 58 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 18 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1c ff ff ff       	call   8010076e <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
8010085b:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e1 00 00 00    	je     80100949 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c6 00 00 00       	jmp    80100949 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100889:	a1 e4 49 11 80       	mov    0x801149e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b6 00 00 00    	je     8010094c <consoleintr+0x176>
        input.e--;
80100896:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 be fe ff ff       	call   8010076e <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 94 00 00 00       	jmp    8010094c <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 8d 00 00 00    	je     8010094f <consoleintr+0x179>
801008c2:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
801008c8:	a1 e0 49 11 80       	mov    0x801149e0,%eax
801008cd:	29 c2                	sub    %eax,%edx
801008cf:	83 fa 7f             	cmp    $0x7f,%edx
801008d2:	77 7b                	ja     8010094f <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 49 11 80    	mov    %edx,0x801149e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 49 11 80    	mov    %dl,-0x7feeb6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 62 fe ff ff       	call   8010076e <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100921:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100926:	83 e8 80             	sub    $0xffffff80,%eax
80100929:	39 c2                	cmp    %eax,%edx
8010092b:	75 22                	jne    8010094f <consoleintr+0x179>
          input.w = input.e;
8010092d:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100932:	a3 e4 49 11 80       	mov    %eax,0x801149e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 49 11 80       	push   $0x801149e0
8010093f:	e8 5e 3f 00 00       	call   801048a2 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	eb 06                	jmp    8010094f <consoleintr+0x179>
      break;
80100949:	90                   	nop
8010094a:	eb 04                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094c:	90                   	nop
8010094d:	eb 01                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094f:	90                   	nop
  while((c = getc()) >= 0){
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	ff d0                	call   *%eax
80100955:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010095c:	0f 89 96 fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
80100962:	83 ec 0c             	sub    $0xc,%esp
80100965:	68 00 4a 11 80       	push   $0x80114a00
8010096a:	e8 33 45 00 00       	call   80104ea2 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 e0 3f 00 00       	call   8010495d <procdump>
  }
}
8010097d:	90                   	nop
8010097e:	c9                   	leave
8010097f:	c3                   	ret

80100980 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100980:	55                   	push   %ebp
80100981:	89 e5                	mov    %esp,%ebp
80100983:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100986:	83 ec 0c             	sub    $0xc,%esp
80100989:	ff 75 08             	push   0x8(%ebp)
8010098c:	e8 74 11 00 00       	call   80101b05 <iunlock>
80100991:	83 c4 10             	add    $0x10,%esp
  target = n;
80100994:	8b 45 10             	mov    0x10(%ebp),%eax
80100997:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
8010099a:	83 ec 0c             	sub    $0xc,%esp
8010099d:	68 00 4a 11 80       	push   $0x80114a00
801009a2:	e8 8d 44 00 00       	call   80104e34 <acquire>
801009a7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009aa:	e9 ab 00 00 00       	jmp    80100a5a <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009af:	e8 5e 35 00 00       	call   80103f12 <myproc>
801009b4:	8b 40 24             	mov    0x24(%eax),%eax
801009b7:	85 c0                	test   %eax,%eax
801009b9:	74 28                	je     801009e3 <consoleread+0x63>
        release(&cons.lock);
801009bb:	83 ec 0c             	sub    $0xc,%esp
801009be:	68 00 4a 11 80       	push   $0x80114a00
801009c3:	e8 da 44 00 00       	call   80104ea2 <release>
801009c8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	ff 75 08             	push   0x8(%ebp)
801009d1:	e8 1c 10 00 00       	call   801019f2 <ilock>
801009d6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009de:	e9 ab 00 00 00       	jmp    80100a8e <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
801009e3:	83 ec 08             	sub    $0x8,%esp
801009e6:	68 00 4a 11 80       	push   $0x80114a00
801009eb:	68 e0 49 11 80       	push   $0x801149e0
801009f0:	e8 c6 3d 00 00       	call   801047bb <sleep>
801009f5:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f8:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801009fe:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100a03:	39 c2                	cmp    %eax,%edx
80100a05:	74 a8                	je     801009af <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a07:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a0c:	8d 50 01             	lea    0x1(%eax),%edx
80100a0f:	89 15 e0 49 11 80    	mov    %edx,0x801149e0
80100a15:	83 e0 7f             	and    $0x7f,%eax
80100a18:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
80100a1f:	0f be c0             	movsbl %al,%eax
80100a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a25:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a29:	75 17                	jne    80100a42 <consoleread+0xc2>
      if(n < target){
80100a2b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a2e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a31:	73 2f                	jae    80100a62 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a33:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a38:	83 e8 01             	sub    $0x1,%eax
80100a3b:	a3 e0 49 11 80       	mov    %eax,0x801149e0
      }
      break;
80100a40:	eb 20                	jmp    80100a62 <consoleread+0xe2>
    }
    *dst++ = c;
80100a42:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a45:	8d 50 01             	lea    0x1(%eax),%edx
80100a48:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a4e:	88 10                	mov    %dl,(%eax)
    --n;
80100a50:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a54:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a58:	74 0b                	je     80100a65 <consoleread+0xe5>
  while(n > 0){
80100a5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a5e:	7f 98                	jg     801009f8 <consoleread+0x78>
80100a60:	eb 04                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a62:	90                   	nop
80100a63:	eb 01                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a65:	90                   	nop
  }
  release(&cons.lock);
80100a66:	83 ec 0c             	sub    $0xc,%esp
80100a69:	68 00 4a 11 80       	push   $0x80114a00
80100a6e:	e8 2f 44 00 00       	call   80104ea2 <release>
80100a73:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	push   0x8(%ebp)
80100a7c:	e8 71 0f 00 00       	call   801019f2 <ilock>
80100a81:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a84:	8b 45 10             	mov    0x10(%ebp),%eax
80100a87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a8a:	29 c2                	sub    %eax,%edx
80100a8c:	89 d0                	mov    %edx,%eax
}
80100a8e:	c9                   	leave
80100a8f:	c3                   	ret

80100a90 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a90:	55                   	push   %ebp
80100a91:	89 e5                	mov    %esp,%ebp
80100a93:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a96:	83 ec 0c             	sub    $0xc,%esp
80100a99:	ff 75 08             	push   0x8(%ebp)
80100a9c:	e8 64 10 00 00       	call   80101b05 <iunlock>
80100aa1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aa4:	83 ec 0c             	sub    $0xc,%esp
80100aa7:	68 00 4a 11 80       	push   $0x80114a00
80100aac:	e8 83 43 00 00       	call   80104e34 <acquire>
80100ab1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ab4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100abb:	eb 21                	jmp    80100ade <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ac3:	01 d0                	add    %edx,%eax
80100ac5:	0f b6 00             	movzbl (%eax),%eax
80100ac8:	0f be c0             	movsbl %al,%eax
80100acb:	0f b6 c0             	movzbl %al,%eax
80100ace:	83 ec 0c             	sub    $0xc,%esp
80100ad1:	50                   	push   %eax
80100ad2:	e8 97 fc ff ff       	call   8010076e <consputc>
80100ad7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ada:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ae1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ae4:	7c d7                	jl     80100abd <consolewrite+0x2d>
  release(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 00 4a 11 80       	push   $0x80114a00
80100aee:	e8 af 43 00 00       	call   80104ea2 <release>
80100af3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	ff 75 08             	push   0x8(%ebp)
80100afc:	e8 f1 0e 00 00       	call   801019f2 <ilock>
80100b01:	83 c4 10             	add    $0x10,%esp

  return n;
80100b04:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b07:	c9                   	leave
80100b08:	c3                   	ret

80100b09 <consoleinit>:

void
consoleinit(void)
{
80100b09:	55                   	push   %ebp
80100b0a:	89 e5                	mov    %esp,%ebp
80100b0c:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b0f:	c7 05 ec 49 11 80 00 	movl   $0x0,0x801149ec
80100b16:	00 00 00 
  initlock(&cons.lock, "console");
80100b19:	83 ec 08             	sub    $0x8,%esp
80100b1c:	68 57 a6 10 80       	push   $0x8010a657
80100b21:	68 00 4a 11 80       	push   $0x80114a00
80100b26:	e8 e7 42 00 00       	call   80104e12 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 4a 11 80 90 	movl   $0x80100a90,0x80114a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 4a 11 80 80 	movl   $0x80100980,0x80114a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 5f a6 10 80 	movl   $0x8010a65f,-0xc(%ebp)
80100b49:	eb 19                	jmp    80100b64 <consoleinit+0x5b>
    graphic_putc(*p);
80100b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b4e:	0f b6 00             	movzbl (%eax),%eax
80100b51:	0f be c0             	movsbl %al,%eax
80100b54:	83 ec 0c             	sub    $0xc,%esp
80100b57:	50                   	push   %eax
80100b58:	e8 e1 fa ff ff       	call   8010063e <graphic_putc>
80100b5d:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b67:	0f b6 00             	movzbl (%eax),%eax
80100b6a:	84 c0                	test   %al,%al
80100b6c:	75 dd                	jne    80100b4b <consoleinit+0x42>
  
  cons.locking = 1;
80100b6e:	c7 05 34 4a 11 80 01 	movl   $0x1,0x80114a34
80100b75:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b78:	83 ec 08             	sub    $0x8,%esp
80100b7b:	6a 00                	push   $0x0
80100b7d:	6a 01                	push   $0x1
80100b7f:	e8 94 1f 00 00       	call   80102b18 <ioapicenable>
80100b84:	83 c4 10             	add    $0x10,%esp
}
80100b87:	90                   	nop
80100b88:	c9                   	leave
80100b89:	c3                   	ret

80100b8a <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b8a:	55                   	push   %ebp
80100b8b:	89 e5                	mov    %esp,%ebp
80100b8d:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b93:	e8 7a 33 00 00       	call   80103f12 <myproc>
80100b98:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b9b:	e8 80 29 00 00       	call   80103520 <begin_op>

  if((ip = namei(path)) == 0){
80100ba0:	83 ec 0c             	sub    $0xc,%esp
80100ba3:	ff 75 08             	push   0x8(%ebp)
80100ba6:	e8 7a 19 00 00       	call   80102525 <namei>
80100bab:	83 c4 10             	add    $0x10,%esp
80100bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bb1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bb5:	75 1f                	jne    80100bd6 <exec+0x4c>
    end_op();
80100bb7:	e8 f0 29 00 00       	call   801035ac <end_op>
    cprintf("exec: fail\n");
80100bbc:	83 ec 0c             	sub    $0xc,%esp
80100bbf:	68 75 a6 10 80       	push   $0x8010a675
80100bc4:	e8 2b f8 ff ff       	call   801003f4 <cprintf>
80100bc9:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd1:	e9 f1 03 00 00       	jmp    80100fc7 <exec+0x43d>
  }
  ilock(ip);
80100bd6:	83 ec 0c             	sub    $0xc,%esp
80100bd9:	ff 75 d8             	push   -0x28(%ebp)
80100bdc:	e8 11 0e 00 00       	call   801019f2 <ilock>
80100be1:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100beb:	6a 34                	push   $0x34
80100bed:	6a 00                	push   $0x0
80100bef:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100bf5:	50                   	push   %eax
80100bf6:	ff 75 d8             	push   -0x28(%ebp)
80100bf9:	e8 e0 12 00 00       	call   80101ede <readi>
80100bfe:	83 c4 10             	add    $0x10,%esp
80100c01:	83 f8 34             	cmp    $0x34,%eax
80100c04:	0f 85 66 03 00 00    	jne    80100f70 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c0a:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c10:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c15:	0f 85 58 03 00 00    	jne    80100f73 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c1b:	e8 d6 6d 00 00       	call   801079f6 <setupkvm>
80100c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c27:	0f 84 49 03 00 00    	je     80100f76 <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c3b:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c41:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c44:	e9 de 00 00 00       	jmp    80100d27 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c4c:	6a 20                	push   $0x20
80100c4e:	50                   	push   %eax
80100c4f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c55:	50                   	push   %eax
80100c56:	ff 75 d8             	push   -0x28(%ebp)
80100c59:	e8 80 12 00 00       	call   80101ede <readi>
80100c5e:	83 c4 10             	add    $0x10,%esp
80100c61:	83 f8 20             	cmp    $0x20,%eax
80100c64:	0f 85 0f 03 00 00    	jne    80100f79 <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c6a:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c70:	83 f8 01             	cmp    $0x1,%eax
80100c73:	0f 85 a0 00 00 00    	jne    80100d19 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c79:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c7f:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c85:	39 c2                	cmp    %eax,%edx
80100c87:	0f 82 ef 02 00 00    	jb     80100f7c <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c8d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c93:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c99:	01 c2                	add    %eax,%edx
80100c9b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ca1:	39 c2                	cmp    %eax,%edx
80100ca3:	0f 82 d6 02 00 00    	jb     80100f7f <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ca9:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100caf:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cb5:	01 d0                	add    %edx,%eax
80100cb7:	83 ec 04             	sub    $0x4,%esp
80100cba:	50                   	push   %eax
80100cbb:	ff 75 e0             	push   -0x20(%ebp)
80100cbe:	ff 75 d4             	push   -0x2c(%ebp)
80100cc1:	e8 2a 71 00 00       	call   80107df0 <allocuvm>
80100cc6:	83 c4 10             	add    $0x10,%esp
80100cc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ccc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd0:	0f 84 ac 02 00 00    	je     80100f82 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100cd6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cdc:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ce1:	85 c0                	test   %eax,%eax
80100ce3:	0f 85 9c 02 00 00    	jne    80100f85 <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ce9:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cef:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cf5:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	52                   	push   %edx
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	push   -0x28(%ebp)
80100d03:	51                   	push   %ecx
80100d04:	ff 75 d4             	push   -0x2c(%ebp)
80100d07:	e8 17 70 00 00       	call   80107d23 <loaduvm>
80100d0c:	83 c4 20             	add    $0x20,%esp
80100d0f:	85 c0                	test   %eax,%eax
80100d11:	0f 88 71 02 00 00    	js     80100f88 <exec+0x3fe>
80100d17:	eb 01                	jmp    80100d1a <exec+0x190>
      continue;
80100d19:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d1a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d21:	83 c0 20             	add    $0x20,%eax
80100d24:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d27:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d2e:	0f b7 c0             	movzwl %ax,%eax
80100d31:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d34:	0f 8c 0f ff ff ff    	jl     80100c49 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d3a:	83 ec 0c             	sub    $0xc,%esp
80100d3d:	ff 75 d8             	push   -0x28(%ebp)
80100d40:	e8 de 0e 00 00       	call   80101c23 <iunlockput>
80100d45:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d48:	e8 5f 28 00 00       	call   801035ac <end_op>
  ip = 0;
80100d4d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d57:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d61:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d67:	05 00 20 00 00       	add    $0x2000,%eax
80100d6c:	83 ec 04             	sub    $0x4,%esp
80100d6f:	50                   	push   %eax
80100d70:	ff 75 e0             	push   -0x20(%ebp)
80100d73:	ff 75 d4             	push   -0x2c(%ebp)
80100d76:	e8 75 70 00 00       	call   80107df0 <allocuvm>
80100d7b:	83 c4 10             	add    $0x10,%esp
80100d7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d85:	0f 84 00 02 00 00    	je     80100f8b <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8e:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d93:	83 ec 08             	sub    $0x8,%esp
80100d96:	50                   	push   %eax
80100d97:	ff 75 d4             	push   -0x2c(%ebp)
80100d9a:	e8 b3 72 00 00       	call   80108052 <clearpteu>
80100d9f:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100da8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100daf:	e9 96 00 00 00       	jmp    80100e4a <exec+0x2c0>
    if(argc >= MAXARG)
80100db4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100db8:	0f 87 d0 01 00 00    	ja     80100f8e <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcb:	01 d0                	add    %edx,%eax
80100dcd:	8b 00                	mov    (%eax),%eax
80100dcf:	83 ec 0c             	sub    $0xc,%esp
80100dd2:	50                   	push   %eax
80100dd3:	e8 20 45 00 00       	call   801052f8 <strlen>
80100dd8:	83 c4 10             	add    $0x10,%esp
80100ddb:	89 c2                	mov    %eax,%edx
80100ddd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de0:	29 d0                	sub    %edx,%eax
80100de2:	83 e8 01             	sub    $0x1,%eax
80100de5:	83 e0 fc             	and    $0xfffffffc,%eax
80100de8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 d0                	add    %edx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	83 ec 0c             	sub    $0xc,%esp
80100dff:	50                   	push   %eax
80100e00:	e8 f3 44 00 00       	call   801052f8 <strlen>
80100e05:	83 c4 10             	add    $0x10,%esp
80100e08:	83 c0 01             	add    $0x1,%eax
80100e0b:	89 c1                	mov    %eax,%ecx
80100e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e1a:	01 d0                	add    %edx,%eax
80100e1c:	8b 00                	mov    (%eax),%eax
80100e1e:	51                   	push   %ecx
80100e1f:	50                   	push   %eax
80100e20:	ff 75 dc             	push   -0x24(%ebp)
80100e23:	ff 75 d4             	push   -0x2c(%ebp)
80100e26:	e8 c6 73 00 00       	call   801081f1 <copyout>
80100e2b:	83 c4 10             	add    $0x10,%esp
80100e2e:	85 c0                	test   %eax,%eax
80100e30:	0f 88 5b 01 00 00    	js     80100f91 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e39:	8d 50 03             	lea    0x3(%eax),%edx
80100e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e3f:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e46:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e54:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e57:	01 d0                	add    %edx,%eax
80100e59:	8b 00                	mov    (%eax),%eax
80100e5b:	85 c0                	test   %eax,%eax
80100e5d:	0f 85 51 ff ff ff    	jne    80100db4 <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e66:	83 c0 03             	add    $0x3,%eax
80100e69:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e70:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e74:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e7b:	ff ff ff 
  ustack[1] = argc;
80100e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e81:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8a:	83 c0 01             	add    $0x1,%eax
80100e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e94:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e97:	29 d0                	sub    %edx,%eax
80100e99:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea2:	83 c0 04             	add    $0x4,%eax
80100ea5:	c1 e0 02             	shl    $0x2,%eax
80100ea8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eae:	83 c0 04             	add    $0x4,%eax
80100eb1:	c1 e0 02             	shl    $0x2,%eax
80100eb4:	50                   	push   %eax
80100eb5:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ebb:	50                   	push   %eax
80100ebc:	ff 75 dc             	push   -0x24(%ebp)
80100ebf:	ff 75 d4             	push   -0x2c(%ebp)
80100ec2:	e8 2a 73 00 00       	call   801081f1 <copyout>
80100ec7:	83 c4 10             	add    $0x10,%esp
80100eca:	85 c0                	test   %eax,%eax
80100ecc:	0f 88 c2 00 00 00    	js     80100f94 <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ede:	eb 17                	jmp    80100ef7 <exec+0x36d>
    if(*s == '/')
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	0f b6 00             	movzbl (%eax),%eax
80100ee6:	3c 2f                	cmp    $0x2f,%al
80100ee8:	75 09                	jne    80100ef3 <exec+0x369>
      last = s+1;
80100eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eed:	83 c0 01             	add    $0x1,%eax
80100ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ef3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efa:	0f b6 00             	movzbl (%eax),%eax
80100efd:	84 c0                	test   %al,%al
80100eff:	75 df                	jne    80100ee0 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f04:	83 c0 6c             	add    $0x6c,%eax
80100f07:	83 ec 04             	sub    $0x4,%esp
80100f0a:	6a 10                	push   $0x10
80100f0c:	ff 75 f0             	push   -0x10(%ebp)
80100f0f:	50                   	push   %eax
80100f10:	e8 98 43 00 00       	call   801052ad <safestrcpy>
80100f15:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f18:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1b:	8b 40 04             	mov    0x4(%eax),%eax
80100f1e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f27:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f30:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f32:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f35:	8b 40 18             	mov    0x18(%eax),%eax
80100f38:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f3e:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f41:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f44:	8b 40 18             	mov    0x18(%eax),%eax
80100f47:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f4a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f4d:	83 ec 0c             	sub    $0xc,%esp
80100f50:	ff 75 d0             	push   -0x30(%ebp)
80100f53:	e8 bc 6b 00 00       	call   80107b14 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 53 70 00 00       	call   80107fb9 <freevm>
80100f66:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f69:	b8 00 00 00 00       	mov    $0x0,%eax
80100f6e:	eb 57                	jmp    80100fc7 <exec+0x43d>
    goto bad;
80100f70:	90                   	nop
80100f71:	eb 22                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f73:	90                   	nop
80100f74:	eb 1f                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f76:	90                   	nop
80100f77:	eb 1c                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 19                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 16                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 13                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 10                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f85:	90                   	nop
80100f86:	eb 0d                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 0a                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f8b:	90                   	nop
80100f8c:	eb 07                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f8e:	90                   	nop
80100f8f:	eb 04                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f91:	90                   	nop
80100f92:	eb 01                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f94:	90                   	nop

 bad:
  if(pgdir)
80100f95:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f99:	74 0e                	je     80100fa9 <exec+0x41f>
    freevm(pgdir);
80100f9b:	83 ec 0c             	sub    $0xc,%esp
80100f9e:	ff 75 d4             	push   -0x2c(%ebp)
80100fa1:	e8 13 70 00 00       	call   80107fb9 <freevm>
80100fa6:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fad:	74 13                	je     80100fc2 <exec+0x438>
    iunlockput(ip);
80100faf:	83 ec 0c             	sub    $0xc,%esp
80100fb2:	ff 75 d8             	push   -0x28(%ebp)
80100fb5:	e8 69 0c 00 00       	call   80101c23 <iunlockput>
80100fba:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fbd:	e8 ea 25 00 00       	call   801035ac <end_op>
  }
  return -1;
80100fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fc7:	c9                   	leave
80100fc8:	c3                   	ret

80100fc9 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc9:	55                   	push   %ebp
80100fca:	89 e5                	mov    %esp,%ebp
80100fcc:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fcf:	83 ec 08             	sub    $0x8,%esp
80100fd2:	68 81 a6 10 80       	push   $0x8010a681
80100fd7:	68 a0 4a 11 80       	push   $0x80114aa0
80100fdc:	e8 31 3e 00 00       	call   80104e12 <initlock>
80100fe1:	83 c4 10             	add    $0x10,%esp
}
80100fe4:	90                   	nop
80100fe5:	c9                   	leave
80100fe6:	c3                   	ret

80100fe7 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fe7:	55                   	push   %ebp
80100fe8:	89 e5                	mov    %esp,%ebp
80100fea:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fed:	83 ec 0c             	sub    $0xc,%esp
80100ff0:	68 a0 4a 11 80       	push   $0x80114aa0
80100ff5:	e8 3a 3e 00 00       	call   80104e34 <acquire>
80100ffa:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ffd:	c7 45 f4 d4 4a 11 80 	movl   $0x80114ad4,-0xc(%ebp)
80101004:	eb 2d                	jmp    80101033 <filealloc+0x4c>
    if(f->ref == 0){
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	8b 40 04             	mov    0x4(%eax),%eax
8010100c:	85 c0                	test   %eax,%eax
8010100e:	75 1f                	jne    8010102f <filealloc+0x48>
      f->ref = 1;
80101010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101013:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010101a:	83 ec 0c             	sub    $0xc,%esp
8010101d:	68 a0 4a 11 80       	push   $0x80114aa0
80101022:	e8 7b 3e 00 00       	call   80104ea2 <release>
80101027:	83 c4 10             	add    $0x10,%esp
      return f;
8010102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102d:	eb 23                	jmp    80101052 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101033:	b8 34 54 11 80       	mov    $0x80115434,%eax
80101038:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103b:	72 c9                	jb     80101006 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 a0 4a 11 80       	push   $0x80114aa0
80101045:	e8 58 3e 00 00       	call   80104ea2 <release>
8010104a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010104d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101052:	c9                   	leave
80101053:	c3                   	ret

80101054 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101054:	55                   	push   %ebp
80101055:	89 e5                	mov    %esp,%ebp
80101057:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 a0 4a 11 80       	push   $0x80114aa0
80101062:	e8 cd 3d 00 00       	call   80104e34 <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 88 a6 10 80       	push   $0x8010a688
8010107c:	e8 28 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	8b 40 04             	mov    0x4(%eax),%eax
80101087:	8d 50 01             	lea    0x1(%eax),%edx
8010108a:	8b 45 08             	mov    0x8(%ebp),%eax
8010108d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	68 a0 4a 11 80       	push   $0x80114aa0
80101098:	e8 05 3e 00 00       	call   80104ea2 <release>
8010109d:	83 c4 10             	add    $0x10,%esp
  return f;
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a3:	c9                   	leave
801010a4:	c3                   	ret

801010a5 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a5:	55                   	push   %ebp
801010a6:	89 e5                	mov    %esp,%ebp
801010a8:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ab:	83 ec 0c             	sub    $0xc,%esp
801010ae:	68 a0 4a 11 80       	push   $0x80114aa0
801010b3:	e8 7c 3d 00 00       	call   80104e34 <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 90 a6 10 80       	push   $0x8010a690
801010cd:	e8 d7 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	8b 40 04             	mov    0x4(%eax),%eax
801010d8:	8d 50 ff             	lea    -0x1(%eax),%edx
801010db:	8b 45 08             	mov    0x8(%ebp),%eax
801010de:	89 50 04             	mov    %edx,0x4(%eax)
801010e1:	8b 45 08             	mov    0x8(%ebp),%eax
801010e4:	8b 40 04             	mov    0x4(%eax),%eax
801010e7:	85 c0                	test   %eax,%eax
801010e9:	7e 15                	jle    80101100 <fileclose+0x5b>
    release(&ftable.lock);
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	68 a0 4a 11 80       	push   $0x80114aa0
801010f3:	e8 aa 3d 00 00       	call   80104ea2 <release>
801010f8:	83 c4 10             	add    $0x10,%esp
801010fb:	e9 8b 00 00 00       	jmp    8010118b <fileclose+0xe6>
    return;
  }
  ff = *f;
80101100:	8b 45 08             	mov    0x8(%ebp),%eax
80101103:	8b 10                	mov    (%eax),%edx
80101105:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101108:	8b 50 04             	mov    0x4(%eax),%edx
8010110b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010110e:	8b 50 08             	mov    0x8(%eax),%edx
80101111:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101114:	8b 50 0c             	mov    0xc(%eax),%edx
80101117:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010111a:	8b 50 10             	mov    0x10(%eax),%edx
8010111d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101120:	8b 40 14             	mov    0x14(%eax),%eax
80101123:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101130:	8b 45 08             	mov    0x8(%ebp),%eax
80101133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	68 a0 4a 11 80       	push   $0x80114aa0
80101141:	e8 5c 3d 00 00       	call   80104ea2 <release>
80101146:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101149:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114c:	83 f8 01             	cmp    $0x1,%eax
8010114f:	75 19                	jne    8010116a <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101151:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101155:	0f be d0             	movsbl %al,%edx
80101158:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010115b:	83 ec 08             	sub    $0x8,%esp
8010115e:	52                   	push   %edx
8010115f:	50                   	push   %eax
80101160:	e8 3c 2a 00 00       	call   80103ba1 <pipeclose>
80101165:	83 c4 10             	add    $0x10,%esp
80101168:	eb 21                	jmp    8010118b <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010116d:	83 f8 02             	cmp    $0x2,%eax
80101170:	75 19                	jne    8010118b <fileclose+0xe6>
    begin_op();
80101172:	e8 a9 23 00 00       	call   80103520 <begin_op>
    iput(ff.ip);
80101177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	50                   	push   %eax
8010117e:	e8 d0 09 00 00       	call   80101b53 <iput>
80101183:	83 c4 10             	add    $0x10,%esp
    end_op();
80101186:	e8 21 24 00 00       	call   801035ac <end_op>
  }
}
8010118b:	c9                   	leave
8010118c:	c3                   	ret

8010118d <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010118d:	55                   	push   %ebp
8010118e:	89 e5                	mov    %esp,%ebp
80101190:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 00                	mov    (%eax),%eax
80101198:	83 f8 02             	cmp    $0x2,%eax
8010119b:	75 40                	jne    801011dd <filestat+0x50>
    ilock(f->ip);
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	8b 40 10             	mov    0x10(%eax),%eax
801011a3:	83 ec 0c             	sub    $0xc,%esp
801011a6:	50                   	push   %eax
801011a7:	e8 46 08 00 00       	call   801019f2 <ilock>
801011ac:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011af:	8b 45 08             	mov    0x8(%ebp),%eax
801011b2:	8b 40 10             	mov    0x10(%eax),%eax
801011b5:	83 ec 08             	sub    $0x8,%esp
801011b8:	ff 75 0c             	push   0xc(%ebp)
801011bb:	50                   	push   %eax
801011bc:	e8 d7 0c 00 00       	call   80101e98 <stati>
801011c1:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011c4:	8b 45 08             	mov    0x8(%ebp),%eax
801011c7:	8b 40 10             	mov    0x10(%eax),%eax
801011ca:	83 ec 0c             	sub    $0xc,%esp
801011cd:	50                   	push   %eax
801011ce:	e8 32 09 00 00       	call   80101b05 <iunlock>
801011d3:	83 c4 10             	add    $0x10,%esp
    return 0;
801011d6:	b8 00 00 00 00       	mov    $0x0,%eax
801011db:	eb 05                	jmp    801011e2 <filestat+0x55>
  }
  return -1;
801011dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011e2:	c9                   	leave
801011e3:	c3                   	ret

801011e4 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011e4:	55                   	push   %ebp
801011e5:	89 e5                	mov    %esp,%ebp
801011e7:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011ea:	8b 45 08             	mov    0x8(%ebp),%eax
801011ed:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011f1:	84 c0                	test   %al,%al
801011f3:	75 0a                	jne    801011ff <fileread+0x1b>
    return -1;
801011f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011fa:	e9 9b 00 00 00       	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 00                	mov    (%eax),%eax
80101204:	83 f8 01             	cmp    $0x1,%eax
80101207:	75 1a                	jne    80101223 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 40 0c             	mov    0xc(%eax),%eax
8010120f:	83 ec 04             	sub    $0x4,%esp
80101212:	ff 75 10             	push   0x10(%ebp)
80101215:	ff 75 0c             	push   0xc(%ebp)
80101218:	50                   	push   %eax
80101219:	e8 30 2b 00 00       	call   80103d4e <piperead>
8010121e:	83 c4 10             	add    $0x10,%esp
80101221:	eb 77                	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_INODE){
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 00                	mov    (%eax),%eax
80101228:	83 f8 02             	cmp    $0x2,%eax
8010122b:	75 60                	jne    8010128d <fileread+0xa9>
    ilock(f->ip);
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	8b 40 10             	mov    0x10(%eax),%eax
80101233:	83 ec 0c             	sub    $0xc,%esp
80101236:	50                   	push   %eax
80101237:	e8 b6 07 00 00       	call   801019f2 <ilock>
8010123c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010123f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 50 14             	mov    0x14(%eax),%edx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 40 10             	mov    0x10(%eax),%eax
8010124e:	51                   	push   %ecx
8010124f:	52                   	push   %edx
80101250:	ff 75 0c             	push   0xc(%ebp)
80101253:	50                   	push   %eax
80101254:	e8 85 0c 00 00       	call   80101ede <readi>
80101259:	83 c4 10             	add    $0x10,%esp
8010125c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010125f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101263:	7e 11                	jle    80101276 <fileread+0x92>
      f->off += r;
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 50 14             	mov    0x14(%eax),%edx
8010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126e:	01 c2                	add    %eax,%edx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101276:	8b 45 08             	mov    0x8(%ebp),%eax
80101279:	8b 40 10             	mov    0x10(%eax),%eax
8010127c:	83 ec 0c             	sub    $0xc,%esp
8010127f:	50                   	push   %eax
80101280:	e8 80 08 00 00       	call   80101b05 <iunlock>
80101285:	83 c4 10             	add    $0x10,%esp
    return r;
80101288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128b:	eb 0d                	jmp    8010129a <fileread+0xb6>
  }
  panic("fileread");
8010128d:	83 ec 0c             	sub    $0xc,%esp
80101290:	68 9a a6 10 80       	push   $0x8010a69a
80101295:	e8 0f f3 ff ff       	call   801005a9 <panic>
}
8010129a:	c9                   	leave
8010129b:	c3                   	ret

8010129c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010129c:	55                   	push   %ebp
8010129d:	89 e5                	mov    %esp,%ebp
8010129f:	53                   	push   %ebx
801012a0:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012a3:	8b 45 08             	mov    0x8(%ebp),%eax
801012a6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012aa:	84 c0                	test   %al,%al
801012ac:	75 0a                	jne    801012b8 <filewrite+0x1c>
    return -1;
801012ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b3:	e9 1b 01 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 00                	mov    (%eax),%eax
801012bd:	83 f8 01             	cmp    $0x1,%eax
801012c0:	75 1d                	jne    801012df <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 40 0c             	mov    0xc(%eax),%eax
801012c8:	83 ec 04             	sub    $0x4,%esp
801012cb:	ff 75 10             	push   0x10(%ebp)
801012ce:	ff 75 0c             	push   0xc(%ebp)
801012d1:	50                   	push   %eax
801012d2:	e8 75 29 00 00       	call   80103c4c <pipewrite>
801012d7:	83 c4 10             	add    $0x10,%esp
801012da:	e9 f4 00 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_INODE){
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 00                	mov    (%eax),%eax
801012e4:	83 f8 02             	cmp    $0x2,%eax
801012e7:	0f 85 d9 00 00 00    	jne    801013c6 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012ed:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012fb:	e9 a3 00 00 00       	jmp    801013a3 <filewrite+0x107>
      int n1 = n - i;
80101300:	8b 45 10             	mov    0x10(%ebp),%eax
80101303:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101306:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010130c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010130f:	7e 06                	jle    80101317 <filewrite+0x7b>
        n1 = max;
80101311:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101314:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101317:	e8 04 22 00 00       	call   80103520 <begin_op>
      ilock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	83 ec 0c             	sub    $0xc,%esp
80101325:	50                   	push   %eax
80101326:	e8 c7 06 00 00       	call   801019f2 <ilock>
8010132b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010132e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 50 14             	mov    0x14(%eax),%edx
80101337:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	01 c3                	add    %eax,%ebx
8010133f:	8b 45 08             	mov    0x8(%ebp),%eax
80101342:	8b 40 10             	mov    0x10(%eax),%eax
80101345:	51                   	push   %ecx
80101346:	52                   	push   %edx
80101347:	53                   	push   %ebx
80101348:	50                   	push   %eax
80101349:	e8 e5 0c 00 00       	call   80102033 <writei>
8010134e:	83 c4 10             	add    $0x10,%esp
80101351:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101354:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101358:	7e 11                	jle    8010136b <filewrite+0xcf>
        f->off += r;
8010135a:	8b 45 08             	mov    0x8(%ebp),%eax
8010135d:	8b 50 14             	mov    0x14(%eax),%edx
80101360:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101363:	01 c2                	add    %eax,%edx
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010136b:	8b 45 08             	mov    0x8(%ebp),%eax
8010136e:	8b 40 10             	mov    0x10(%eax),%eax
80101371:	83 ec 0c             	sub    $0xc,%esp
80101374:	50                   	push   %eax
80101375:	e8 8b 07 00 00       	call   80101b05 <iunlock>
8010137a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010137d:	e8 2a 22 00 00       	call   801035ac <end_op>

      if(r < 0)
80101382:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101386:	78 29                	js     801013b1 <filewrite+0x115>
        break;
      if(r != n1)
80101388:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010138b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010138e:	74 0d                	je     8010139d <filewrite+0x101>
        panic("short filewrite");
80101390:	83 ec 0c             	sub    $0xc,%esp
80101393:	68 a3 a6 10 80       	push   $0x8010a6a3
80101398:	e8 0c f2 ff ff       	call   801005a9 <panic>
      i += r;
8010139d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a0:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a9:	0f 8c 51 ff ff ff    	jl     80101300 <filewrite+0x64>
801013af:	eb 01                	jmp    801013b2 <filewrite+0x116>
        break;
801013b1:	90                   	nop
    }
    return i == n ? n : -1;
801013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801013b8:	75 05                	jne    801013bf <filewrite+0x123>
801013ba:	8b 45 10             	mov    0x10(%ebp),%eax
801013bd:	eb 14                	jmp    801013d3 <filewrite+0x137>
801013bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c4:	eb 0d                	jmp    801013d3 <filewrite+0x137>
  }
  panic("filewrite");
801013c6:	83 ec 0c             	sub    $0xc,%esp
801013c9:	68 b3 a6 10 80       	push   $0x8010a6b3
801013ce:	e8 d6 f1 ff ff       	call   801005a9 <panic>
}
801013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013d6:	c9                   	leave
801013d7:	c3                   	ret

801013d8 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013d8:	55                   	push   %ebp
801013d9:	89 e5                	mov    %esp,%ebp
801013db:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	83 ec 08             	sub    $0x8,%esp
801013e4:	6a 01                	push   $0x1
801013e6:	50                   	push   %eax
801013e7:	e8 15 ee ff ff       	call   80100201 <bread>
801013ec:	83 c4 10             	add    $0x10,%esp
801013ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f5:	83 c0 5c             	add    $0x5c,%eax
801013f8:	83 ec 04             	sub    $0x4,%esp
801013fb:	6a 1c                	push   $0x1c
801013fd:	50                   	push   %eax
801013fe:	ff 75 0c             	push   0xc(%ebp)
80101401:	e8 63 3d 00 00       	call   80105169 <memmove>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	push   -0xc(%ebp)
8010140f:	e8 6f ee ff ff       	call   80100283 <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave
80101419:	c3                   	ret

8010141a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101420:	8b 55 0c             	mov    0xc(%ebp),%edx
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	83 ec 08             	sub    $0x8,%esp
80101429:	52                   	push   %edx
8010142a:	50                   	push   %eax
8010142b:	e8 d1 ed ff ff       	call   80100201 <bread>
80101430:	83 c4 10             	add    $0x10,%esp
80101433:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101439:	83 c0 5c             	add    $0x5c,%eax
8010143c:	83 ec 04             	sub    $0x4,%esp
8010143f:	68 00 02 00 00       	push   $0x200
80101444:	6a 00                	push   $0x0
80101446:	50                   	push   %eax
80101447:	e8 5e 3c 00 00       	call   801050aa <memset>
8010144c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010144f:	83 ec 0c             	sub    $0xc,%esp
80101452:	ff 75 f4             	push   -0xc(%ebp)
80101455:	e8 ff 22 00 00       	call   80103759 <log_write>
8010145a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010145d:	83 ec 0c             	sub    $0xc,%esp
80101460:	ff 75 f4             	push   -0xc(%ebp)
80101463:	e8 1b ee ff ff       	call   80100283 <brelse>
80101468:	83 c4 10             	add    $0x10,%esp
}
8010146b:	90                   	nop
8010146c:	c9                   	leave
8010146d:	c3                   	ret

8010146e <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010146e:	55                   	push   %ebp
8010146f:	89 e5                	mov    %esp,%ebp
80101471:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101474:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010147b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101482:	e9 0b 01 00 00       	jmp    80101592 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101490:	85 c0                	test   %eax,%eax
80101492:	0f 48 c2             	cmovs  %edx,%eax
80101495:	c1 f8 0c             	sar    $0xc,%eax
80101498:	89 c2                	mov    %eax,%edx
8010149a:	a1 58 54 11 80       	mov    0x80115458,%eax
8010149f:	01 d0                	add    %edx,%eax
801014a1:	83 ec 08             	sub    $0x8,%esp
801014a4:	50                   	push   %eax
801014a5:	ff 75 08             	push   0x8(%ebp)
801014a8:	e8 54 ed ff ff       	call   80100201 <bread>
801014ad:	83 c4 10             	add    $0x10,%esp
801014b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014ba:	e9 9e 00 00 00       	jmp    8010155d <balloc+0xef>
      m = 1 << (bi % 8);
801014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c2:	83 e0 07             	and    $0x7,%eax
801014c5:	ba 01 00 00 00       	mov    $0x1,%edx
801014ca:	89 c1                	mov    %eax,%ecx
801014cc:	d3 e2                	shl    %cl,%edx
801014ce:	89 d0                	mov    %edx,%eax
801014d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	8d 50 07             	lea    0x7(%eax),%edx
801014d9:	85 c0                	test   %eax,%eax
801014db:	0f 48 c2             	cmovs  %edx,%eax
801014de:	c1 f8 03             	sar    $0x3,%eax
801014e1:	89 c2                	mov    %eax,%edx
801014e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014e6:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014eb:	0f b6 c0             	movzbl %al,%eax
801014ee:	23 45 e8             	and    -0x18(%ebp),%eax
801014f1:	85 c0                	test   %eax,%eax
801014f3:	75 64                	jne    80101559 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f8:	8d 50 07             	lea    0x7(%eax),%edx
801014fb:	85 c0                	test   %eax,%eax
801014fd:	0f 48 c2             	cmovs  %edx,%eax
80101500:	c1 f8 03             	sar    $0x3,%eax
80101503:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101506:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010150b:	89 d1                	mov    %edx,%ecx
8010150d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101510:	09 ca                	or     %ecx,%edx
80101512:	89 d1                	mov    %edx,%ecx
80101514:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101517:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010151b:	83 ec 0c             	sub    $0xc,%esp
8010151e:	ff 75 ec             	push   -0x14(%ebp)
80101521:	e8 33 22 00 00       	call   80103759 <log_write>
80101526:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101529:	83 ec 0c             	sub    $0xc,%esp
8010152c:	ff 75 ec             	push   -0x14(%ebp)
8010152f:	e8 4f ed ff ff       	call   80100283 <brelse>
80101534:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	01 c2                	add    %eax,%edx
8010153f:	8b 45 08             	mov    0x8(%ebp),%eax
80101542:	83 ec 08             	sub    $0x8,%esp
80101545:	52                   	push   %edx
80101546:	50                   	push   %eax
80101547:	e8 ce fe ff ff       	call   8010141a <bzero>
8010154c:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010154f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	01 d0                	add    %edx,%eax
80101557:	eb 56                	jmp    801015af <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101559:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010155d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101564:	7f 17                	jg     8010157d <balloc+0x10f>
80101566:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156c:	01 d0                	add    %edx,%eax
8010156e:	89 c2                	mov    %eax,%edx
80101570:	a1 40 54 11 80       	mov    0x80115440,%eax
80101575:	39 c2                	cmp    %eax,%edx
80101577:	0f 82 42 ff ff ff    	jb     801014bf <balloc+0x51>
      }
    }
    brelse(bp);
8010157d:	83 ec 0c             	sub    $0xc,%esp
80101580:	ff 75 ec             	push   -0x14(%ebp)
80101583:	e8 fb ec ff ff       	call   80100283 <brelse>
80101588:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010158b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101592:	a1 40 54 11 80       	mov    0x80115440,%eax
80101597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159a:	39 c2                	cmp    %eax,%edx
8010159c:	0f 82 e5 fe ff ff    	jb     80101487 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a2:	83 ec 0c             	sub    $0xc,%esp
801015a5:	68 c0 a6 10 80       	push   $0x8010a6c0
801015aa:	e8 fa ef ff ff       	call   801005a9 <panic>
}
801015af:	c9                   	leave
801015b0:	c3                   	ret

801015b1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015b1:	55                   	push   %ebp
801015b2:	89 e5                	mov    %esp,%ebp
801015b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015b7:	83 ec 08             	sub    $0x8,%esp
801015ba:	68 40 54 11 80       	push   $0x80115440
801015bf:	ff 75 08             	push   0x8(%ebp)
801015c2:	e8 11 fe ff ff       	call   801013d8 <readsb>
801015c7:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cd:	c1 e8 0c             	shr    $0xc,%eax
801015d0:	89 c2                	mov    %eax,%edx
801015d2:	a1 58 54 11 80       	mov    0x80115458,%eax
801015d7:	01 c2                	add    %eax,%edx
801015d9:	8b 45 08             	mov    0x8(%ebp),%eax
801015dc:	83 ec 08             	sub    $0x8,%esp
801015df:	52                   	push   %edx
801015e0:	50                   	push   %eax
801015e1:	e8 1b ec ff ff       	call   80100201 <bread>
801015e6:	83 c4 10             	add    $0x10,%esp
801015e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ef:	25 ff 0f 00 00       	and    $0xfff,%eax
801015f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	83 e0 07             	and    $0x7,%eax
801015fd:	ba 01 00 00 00       	mov    $0x1,%edx
80101602:	89 c1                	mov    %eax,%ecx
80101604:	d3 e2                	shl    %cl,%edx
80101606:	89 d0                	mov    %edx,%eax
80101608:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160e:	8d 50 07             	lea    0x7(%eax),%edx
80101611:	85 c0                	test   %eax,%eax
80101613:	0f 48 c2             	cmovs  %edx,%eax
80101616:	c1 f8 03             	sar    $0x3,%eax
80101619:	89 c2                	mov    %eax,%edx
8010161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101623:	0f b6 c0             	movzbl %al,%eax
80101626:	23 45 ec             	and    -0x14(%ebp),%eax
80101629:	85 c0                	test   %eax,%eax
8010162b:	75 0d                	jne    8010163a <bfree+0x89>
    panic("freeing free block");
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	68 d6 a6 10 80       	push   $0x8010a6d6
80101635:	e8 6f ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
8010163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163d:	8d 50 07             	lea    0x7(%eax),%edx
80101640:	85 c0                	test   %eax,%eax
80101642:	0f 48 c2             	cmovs  %edx,%eax
80101645:	c1 f8 03             	sar    $0x3,%eax
80101648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010164b:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101655:	f7 d2                	not    %edx
80101657:	21 ca                	and    %ecx,%edx
80101659:	89 d1                	mov    %edx,%ecx
8010165b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101662:	83 ec 0c             	sub    $0xc,%esp
80101665:	ff 75 f4             	push   -0xc(%ebp)
80101668:	e8 ec 20 00 00       	call   80103759 <log_write>
8010166d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101670:	83 ec 0c             	sub    $0xc,%esp
80101673:	ff 75 f4             	push   -0xc(%ebp)
80101676:	e8 08 ec ff ff       	call   80100283 <brelse>
8010167b:	83 c4 10             	add    $0x10,%esp
}
8010167e:	90                   	nop
8010167f:	c9                   	leave
80101680:	c3                   	ret

80101681 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101681:	55                   	push   %ebp
80101682:	89 e5                	mov    %esp,%ebp
80101684:	57                   	push   %edi
80101685:	56                   	push   %esi
80101686:	53                   	push   %ebx
80101687:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010168a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101691:	83 ec 08             	sub    $0x8,%esp
80101694:	68 e9 a6 10 80       	push   $0x8010a6e9
80101699:	68 60 54 11 80       	push   $0x80115460
8010169e:	e8 6f 37 00 00       	call   80104e12 <initlock>
801016a3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016ad:	eb 2d                	jmp    801016dc <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016b2:	89 d0                	mov    %edx,%eax
801016b4:	c1 e0 03             	shl    $0x3,%eax
801016b7:	01 d0                	add    %edx,%eax
801016b9:	c1 e0 04             	shl    $0x4,%eax
801016bc:	83 c0 30             	add    $0x30,%eax
801016bf:	05 60 54 11 80       	add    $0x80115460,%eax
801016c4:	83 c0 10             	add    $0x10,%eax
801016c7:	83 ec 08             	sub    $0x8,%esp
801016ca:	68 f0 a6 10 80       	push   $0x8010a6f0
801016cf:	50                   	push   %eax
801016d0:	e8 e0 35 00 00       	call   80104cb5 <initsleeplock>
801016d5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016dc:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e0:	7e cd                	jle    801016af <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e2:	83 ec 08             	sub    $0x8,%esp
801016e5:	68 40 54 11 80       	push   $0x80115440
801016ea:	ff 75 08             	push   0x8(%ebp)
801016ed:	e8 e6 fc ff ff       	call   801013d8 <readsb>
801016f2:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016f5:	a1 58 54 11 80       	mov    0x80115458,%eax
801016fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016fd:	8b 3d 54 54 11 80    	mov    0x80115454,%edi
80101703:	8b 35 50 54 11 80    	mov    0x80115450,%esi
80101709:	8b 1d 4c 54 11 80    	mov    0x8011544c,%ebx
8010170f:	8b 0d 48 54 11 80    	mov    0x80115448,%ecx
80101715:	8b 15 44 54 11 80    	mov    0x80115444,%edx
8010171b:	a1 40 54 11 80       	mov    0x80115440,%eax
80101720:	ff 75 d4             	push   -0x2c(%ebp)
80101723:	57                   	push   %edi
80101724:	56                   	push   %esi
80101725:	53                   	push   %ebx
80101726:	51                   	push   %ecx
80101727:	52                   	push   %edx
80101728:	50                   	push   %eax
80101729:	68 f8 a6 10 80       	push   $0x8010a6f8
8010172e:	e8 c1 ec ff ff       	call   801003f4 <cprintf>
80101733:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101736:	90                   	nop
80101737:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010173a:	5b                   	pop    %ebx
8010173b:	5e                   	pop    %esi
8010173c:	5f                   	pop    %edi
8010173d:	5d                   	pop    %ebp
8010173e:	c3                   	ret

8010173f <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010173f:	55                   	push   %ebp
80101740:	89 e5                	mov    %esp,%ebp
80101742:	83 ec 28             	sub    $0x28,%esp
80101745:	8b 45 0c             	mov    0xc(%ebp),%eax
80101748:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010174c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101753:	e9 9e 00 00 00       	jmp    801017f6 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175b:	c1 e8 03             	shr    $0x3,%eax
8010175e:	89 c2                	mov    %eax,%edx
80101760:	a1 54 54 11 80       	mov    0x80115454,%eax
80101765:	01 d0                	add    %edx,%eax
80101767:	83 ec 08             	sub    $0x8,%esp
8010176a:	50                   	push   %eax
8010176b:	ff 75 08             	push   0x8(%ebp)
8010176e:	e8 8e ea ff ff       	call   80100201 <bread>
80101773:	83 c4 10             	add    $0x10,%esp
80101776:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101782:	83 e0 07             	and    $0x7,%eax
80101785:	c1 e0 06             	shl    $0x6,%eax
80101788:	01 d0                	add    %edx,%eax
8010178a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010178d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101790:	0f b7 00             	movzwl (%eax),%eax
80101793:	66 85 c0             	test   %ax,%ax
80101796:	75 4c                	jne    801017e4 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101798:	83 ec 04             	sub    $0x4,%esp
8010179b:	6a 40                	push   $0x40
8010179d:	6a 00                	push   $0x0
8010179f:	ff 75 ec             	push   -0x14(%ebp)
801017a2:	e8 03 39 00 00       	call   801050aa <memset>
801017a7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ad:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017b1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017b4:	83 ec 0c             	sub    $0xc,%esp
801017b7:	ff 75 f0             	push   -0x10(%ebp)
801017ba:	e8 9a 1f 00 00       	call   80103759 <log_write>
801017bf:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017c2:	83 ec 0c             	sub    $0xc,%esp
801017c5:	ff 75 f0             	push   -0x10(%ebp)
801017c8:	e8 b6 ea ff ff       	call   80100283 <brelse>
801017cd:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d3:	83 ec 08             	sub    $0x8,%esp
801017d6:	50                   	push   %eax
801017d7:	ff 75 08             	push   0x8(%ebp)
801017da:	e8 f7 00 00 00       	call   801018d6 <iget>
801017df:	83 c4 10             	add    $0x10,%esp
801017e2:	eb 2f                	jmp    80101813 <ialloc+0xd4>
    }
    brelse(bp);
801017e4:	83 ec 0c             	sub    $0xc,%esp
801017e7:	ff 75 f0             	push   -0x10(%ebp)
801017ea:	e8 94 ea ff ff       	call   80100283 <brelse>
801017ef:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017f6:	a1 48 54 11 80       	mov    0x80115448,%eax
801017fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017fe:	39 c2                	cmp    %eax,%edx
80101800:	0f 82 52 ff ff ff    	jb     80101758 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101806:	83 ec 0c             	sub    $0xc,%esp
80101809:	68 4b a7 10 80       	push   $0x8010a74b
8010180e:	e8 96 ed ff ff       	call   801005a9 <panic>
}
80101813:	c9                   	leave
80101814:	c3                   	ret

80101815 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101815:	55                   	push   %ebp
80101816:	89 e5                	mov    %esp,%ebp
80101818:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	8b 40 04             	mov    0x4(%eax),%eax
80101821:	c1 e8 03             	shr    $0x3,%eax
80101824:	89 c2                	mov    %eax,%edx
80101826:	a1 54 54 11 80       	mov    0x80115454,%eax
8010182b:	01 c2                	add    %eax,%edx
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 00                	mov    (%eax),%eax
80101832:	83 ec 08             	sub    $0x8,%esp
80101835:	52                   	push   %edx
80101836:	50                   	push   %eax
80101837:	e8 c5 e9 ff ff       	call   80100201 <bread>
8010183c:	83 c4 10             	add    $0x10,%esp
8010183f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	8d 50 5c             	lea    0x5c(%eax),%edx
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 04             	mov    0x4(%eax),%eax
8010184e:	83 e0 07             	and    $0x7,%eax
80101851:	c1 e0 06             	shl    $0x6,%eax
80101854:	01 d0                	add    %edx,%eax
80101856:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101863:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101866:	8b 45 08             	mov    0x8(%ebp),%eax
80101869:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101870:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101882:	8b 45 08             	mov    0x8(%ebp),%eax
80101885:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 50 58             	mov    0x58(%eax),%edx
80101896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101899:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010189c:	8b 45 08             	mov    0x8(%ebp),%eax
8010189f:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a5:	83 c0 0c             	add    $0xc,%eax
801018a8:	83 ec 04             	sub    $0x4,%esp
801018ab:	6a 34                	push   $0x34
801018ad:	52                   	push   %edx
801018ae:	50                   	push   %eax
801018af:	e8 b5 38 00 00       	call   80105169 <memmove>
801018b4:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b7:	83 ec 0c             	sub    $0xc,%esp
801018ba:	ff 75 f4             	push   -0xc(%ebp)
801018bd:	e8 97 1e 00 00       	call   80103759 <log_write>
801018c2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018c5:	83 ec 0c             	sub    $0xc,%esp
801018c8:	ff 75 f4             	push   -0xc(%ebp)
801018cb:	e8 b3 e9 ff ff       	call   80100283 <brelse>
801018d0:	83 c4 10             	add    $0x10,%esp
}
801018d3:	90                   	nop
801018d4:	c9                   	leave
801018d5:	c3                   	ret

801018d6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018d6:	55                   	push   %ebp
801018d7:	89 e5                	mov    %esp,%ebp
801018d9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018dc:	83 ec 0c             	sub    $0xc,%esp
801018df:	68 60 54 11 80       	push   $0x80115460
801018e4:	e8 4b 35 00 00       	call   80104e34 <acquire>
801018e9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f3:	c7 45 f4 94 54 11 80 	movl   $0x80115494,-0xc(%ebp)
801018fa:	eb 60                	jmp    8010195c <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ff:	8b 40 08             	mov    0x8(%eax),%eax
80101902:	85 c0                	test   %eax,%eax
80101904:	7e 39                	jle    8010193f <iget+0x69>
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8b 00                	mov    (%eax),%eax
8010190b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010190e:	75 2f                	jne    8010193f <iget+0x69>
80101910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101913:	8b 40 04             	mov    0x4(%eax),%eax
80101916:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101919:	75 24                	jne    8010193f <iget+0x69>
      ip->ref++;
8010191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191e:	8b 40 08             	mov    0x8(%eax),%eax
80101921:	8d 50 01             	lea    0x1(%eax),%edx
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010192a:	83 ec 0c             	sub    $0xc,%esp
8010192d:	68 60 54 11 80       	push   $0x80115460
80101932:	e8 6b 35 00 00       	call   80104ea2 <release>
80101937:	83 c4 10             	add    $0x10,%esp
      return ip;
8010193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193d:	eb 77                	jmp    801019b6 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010193f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101943:	75 10                	jne    80101955 <iget+0x7f>
80101945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101948:	8b 40 08             	mov    0x8(%eax),%eax
8010194b:	85 c0                	test   %eax,%eax
8010194d:	75 06                	jne    80101955 <iget+0x7f>
      empty = ip;
8010194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101955:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010195c:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
80101963:	72 97                	jb     801018fc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101965:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101969:	75 0d                	jne    80101978 <iget+0xa2>
    panic("iget: no inodes");
8010196b:	83 ec 0c             	sub    $0xc,%esp
8010196e:	68 5d a7 10 80       	push   $0x8010a75d
80101973:	e8 31 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 08             	mov    0x8(%ebp),%edx
80101984:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101989:	8b 55 0c             	mov    0xc(%ebp),%edx
8010198c:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101992:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199c:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019a3:	83 ec 0c             	sub    $0xc,%esp
801019a6:	68 60 54 11 80       	push   $0x80115460
801019ab:	e8 f2 34 00 00       	call   80104ea2 <release>
801019b0:	83 c4 10             	add    $0x10,%esp

  return ip;
801019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019b6:	c9                   	leave
801019b7:	c3                   	ret

801019b8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b8:	55                   	push   %ebp
801019b9:	89 e5                	mov    %esp,%ebp
801019bb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019be:	83 ec 0c             	sub    $0xc,%esp
801019c1:	68 60 54 11 80       	push   $0x80115460
801019c6:	e8 69 34 00 00       	call   80104e34 <acquire>
801019cb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 08             	mov    0x8(%eax),%eax
801019d4:	8d 50 01             	lea    0x1(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	68 60 54 11 80       	push   $0x80115460
801019e5:	e8 b8 34 00 00       	call   80104ea2 <release>
801019ea:	83 c4 10             	add    $0x10,%esp
  return ip;
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019f0:	c9                   	leave
801019f1:	c3                   	ret

801019f2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019f2:	55                   	push   %ebp
801019f3:	89 e5                	mov    %esp,%ebp
801019f5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019fc:	74 0a                	je     80101a08 <ilock+0x16>
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	8b 40 08             	mov    0x8(%eax),%eax
80101a04:	85 c0                	test   %eax,%eax
80101a06:	7f 0d                	jg     80101a15 <ilock+0x23>
    panic("ilock");
80101a08:	83 ec 0c             	sub    $0xc,%esp
80101a0b:	68 6d a7 10 80       	push   $0x8010a76d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 cd 32 00 00       	call   80104cf1 <acquiresleep>
80101a24:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a2d:	85 c0                	test   %eax,%eax
80101a2f:	0f 85 cd 00 00 00    	jne    80101b02 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	8b 40 04             	mov    0x4(%eax),%eax
80101a3b:	c1 e8 03             	shr    $0x3,%eax
80101a3e:	89 c2                	mov    %eax,%edx
80101a40:	a1 54 54 11 80       	mov    0x80115454,%eax
80101a45:	01 c2                	add    %eax,%edx
80101a47:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4a:	8b 00                	mov    (%eax),%eax
80101a4c:	83 ec 08             	sub    $0x8,%esp
80101a4f:	52                   	push   %edx
80101a50:	50                   	push   %eax
80101a51:	e8 ab e7 ff ff       	call   80100201 <bread>
80101a56:	83 c4 10             	add    $0x10,%esp
80101a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	8b 40 04             	mov    0x4(%eax),%eax
80101a68:	83 e0 07             	and    $0x7,%eax
80101a6b:	c1 e0 06             	shl    $0x6,%eax
80101a6e:	01 d0                	add    %edx,%eax
80101a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	0f b7 10             	movzwl (%eax),%edx
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a83:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a87:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8a:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a91:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aad:	8b 50 08             	mov    0x8(%eax),%edx
80101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab3:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab9:	8d 50 0c             	lea    0xc(%eax),%edx
80101abc:	8b 45 08             	mov    0x8(%ebp),%eax
80101abf:	83 c0 5c             	add    $0x5c,%eax
80101ac2:	83 ec 04             	sub    $0x4,%esp
80101ac5:	6a 34                	push   $0x34
80101ac7:	52                   	push   %edx
80101ac8:	50                   	push   %eax
80101ac9:	e8 9b 36 00 00       	call   80105169 <memmove>
80101ace:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ad1:	83 ec 0c             	sub    $0xc,%esp
80101ad4:	ff 75 f4             	push   -0xc(%ebp)
80101ad7:	e8 a7 e7 ff ff       	call   80100283 <brelse>
80101adc:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101af0:	66 85 c0             	test   %ax,%ax
80101af3:	75 0d                	jne    80101b02 <ilock+0x110>
      panic("ilock: no type");
80101af5:	83 ec 0c             	sub    $0xc,%esp
80101af8:	68 73 a7 10 80       	push   $0x8010a773
80101afd:	e8 a7 ea ff ff       	call   801005a9 <panic>
  }
}
80101b02:	90                   	nop
80101b03:	c9                   	leave
80101b04:	c3                   	ret

80101b05 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b05:	55                   	push   %ebp
80101b06:	89 e5                	mov    %esp,%ebp
80101b08:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b0f:	74 20                	je     80101b31 <iunlock+0x2c>
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	83 c0 0c             	add    $0xc,%eax
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	50                   	push   %eax
80101b1b:	e8 83 32 00 00       	call   80104da3 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 82 a7 10 80       	push   $0x8010a782
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 08 32 00 00       	call   80104d55 <releasesleep>
80101b4d:	83 c4 10             	add    $0x10,%esp
}
80101b50:	90                   	nop
80101b51:	c9                   	leave
80101b52:	c3                   	ret

80101b53 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b53:	55                   	push   %ebp
80101b54:	89 e5                	mov    %esp,%ebp
80101b56:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	83 c0 0c             	add    $0xc,%eax
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	50                   	push   %eax
80101b63:	e8 89 31 00 00       	call   80104cf1 <acquiresleep>
80101b68:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 6a                	je     80101bdf <iput+0x8c>
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b7c:	66 85 c0             	test   %ax,%ax
80101b7f:	75 5e                	jne    80101bdf <iput+0x8c>
    acquire(&icache.lock);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	68 60 54 11 80       	push   $0x80115460
80101b89:	e8 a6 32 00 00       	call   80104e34 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 54 11 80       	push   $0x80115460
80101ba2:	e8 fb 32 00 00       	call   80104ea2 <release>
80101ba7:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101baa:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bae:	75 2f                	jne    80101bdf <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	ff 75 08             	push   0x8(%ebp)
80101bb6:	e8 ad 01 00 00       	call   80101d68 <itrunc>
80101bbb:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bc7:	83 ec 0c             	sub    $0xc,%esp
80101bca:	ff 75 08             	push   0x8(%ebp)
80101bcd:	e8 43 fc ff ff       	call   80101815 <iupdate>
80101bd2:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101be2:	83 c0 0c             	add    $0xc,%eax
80101be5:	83 ec 0c             	sub    $0xc,%esp
80101be8:	50                   	push   %eax
80101be9:	e8 67 31 00 00       	call   80104d55 <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 54 11 80       	push   $0x80115460
80101bf9:	e8 36 32 00 00       	call   80104e34 <acquire>
80101bfe:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 08             	mov    0x8(%eax),%eax
80101c07:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	68 60 54 11 80       	push   $0x80115460
80101c18:	e8 85 32 00 00       	call   80104ea2 <release>
80101c1d:	83 c4 10             	add    $0x10,%esp
}
80101c20:	90                   	nop
80101c21:	c9                   	leave
80101c22:	c3                   	ret

80101c23 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c23:	55                   	push   %ebp
80101c24:	89 e5                	mov    %esp,%ebp
80101c26:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c29:	83 ec 0c             	sub    $0xc,%esp
80101c2c:	ff 75 08             	push   0x8(%ebp)
80101c2f:	e8 d1 fe ff ff       	call   80101b05 <iunlock>
80101c34:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c37:	83 ec 0c             	sub    $0xc,%esp
80101c3a:	ff 75 08             	push   0x8(%ebp)
80101c3d:	e8 11 ff ff ff       	call   80101b53 <iput>
80101c42:	83 c4 10             	add    $0x10,%esp
}
80101c45:	90                   	nop
80101c46:	c9                   	leave
80101c47:	c3                   	ret

80101c48 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c48:	55                   	push   %ebp
80101c49:	89 e5                	mov    %esp,%ebp
80101c4b:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c4e:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c52:	77 42                	ja     80101c96 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c5a:	83 c2 14             	add    $0x14,%edx
80101c5d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c68:	75 24                	jne    80101c8e <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6d:	8b 00                	mov    (%eax),%eax
80101c6f:	83 ec 0c             	sub    $0xc,%esp
80101c72:	50                   	push   %eax
80101c73:	e8 f6 f7 ff ff       	call   8010146e <balloc>
80101c78:	83 c4 10             	add    $0x10,%esp
80101c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c81:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c84:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c8a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c91:	e9 d0 00 00 00       	jmp    80101d66 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c96:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c9a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c9e:	0f 87 b5 00 00 00    	ja     80101d59 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb4:	75 20                	jne    80101cd6 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	83 ec 0c             	sub    $0xc,%esp
80101cbe:	50                   	push   %eax
80101cbf:	e8 aa f7 ff ff       	call   8010146e <balloc>
80101cc4:	83 c4 10             	add    $0x10,%esp
80101cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd0:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd9:	8b 00                	mov    (%eax),%eax
80101cdb:	83 ec 08             	sub    $0x8,%esp
80101cde:	ff 75 f4             	push   -0xc(%ebp)
80101ce1:	50                   	push   %eax
80101ce2:	e8 1a e5 ff ff       	call   80100201 <bread>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf0:	83 c0 5c             	add    $0x5c,%eax
80101cf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d03:	01 d0                	add    %edx,%eax
80101d05:	8b 00                	mov    (%eax),%eax
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d0e:	75 36                	jne    80101d46 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d10:	8b 45 08             	mov    0x8(%ebp),%eax
80101d13:	8b 00                	mov    (%eax),%eax
80101d15:	83 ec 0c             	sub    $0xc,%esp
80101d18:	50                   	push   %eax
80101d19:	e8 50 f7 ff ff       	call   8010146e <balloc>
80101d1e:	83 c4 10             	add    $0x10,%esp
80101d21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d31:	01 c2                	add    %eax,%edx
80101d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d36:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d38:	83 ec 0c             	sub    $0xc,%esp
80101d3b:	ff 75 f0             	push   -0x10(%ebp)
80101d3e:	e8 16 1a 00 00       	call   80103759 <log_write>
80101d43:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d46:	83 ec 0c             	sub    $0xc,%esp
80101d49:	ff 75 f0             	push   -0x10(%ebp)
80101d4c:	e8 32 e5 ff ff       	call   80100283 <brelse>
80101d51:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d57:	eb 0d                	jmp    80101d66 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	68 8a a7 10 80       	push   $0x8010a78a
80101d61:	e8 43 e8 ff ff       	call   801005a9 <panic>
}
80101d66:	c9                   	leave
80101d67:	c3                   	ret

80101d68 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d75:	eb 45                	jmp    80101dbc <itrunc+0x54>
    if(ip->addrs[i]){
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7d:	83 c2 14             	add    $0x14,%edx
80101d80:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d84:	85 c0                	test   %eax,%eax
80101d86:	74 30                	je     80101db8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8e:	83 c2 14             	add    $0x14,%edx
80101d91:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d95:	8b 55 08             	mov    0x8(%ebp),%edx
80101d98:	8b 12                	mov    (%edx),%edx
80101d9a:	83 ec 08             	sub    $0x8,%esp
80101d9d:	50                   	push   %eax
80101d9e:	52                   	push   %edx
80101d9f:	e8 0d f8 ff ff       	call   801015b1 <bfree>
80101da4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101da7:	8b 45 08             	mov    0x8(%ebp),%eax
80101daa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dad:	83 c2 14             	add    $0x14,%edx
80101db0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db7:	00 
  for(i = 0; i < NDIRECT; i++){
80101db8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dbc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc0:	7e b5                	jle    80101d77 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dcb:	85 c0                	test   %eax,%eax
80101dcd:	0f 84 aa 00 00 00    	je     80101e7d <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 16 e4 ff ff       	call   80100201 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 5c             	add    $0x5c,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd7>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 79 f7 ff ff       	call   801015b1 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x9b>
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	push   -0x14(%ebp)
80101e4d:	e8 31 e4 ff ff       	call   80100283 <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e5e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e61:	8b 12                	mov    (%edx),%edx
80101e63:	83 ec 08             	sub    $0x8,%esp
80101e66:	50                   	push   %eax
80101e67:	52                   	push   %edx
80101e68:	e8 44 f7 ff ff       	call   801015b1 <bfree>
80101e6d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e7a:	00 00 00 
  }

  ip->size = 0;
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e87:	83 ec 0c             	sub    $0xc,%esp
80101e8a:	ff 75 08             	push   0x8(%ebp)
80101e8d:	e8 83 f9 ff ff       	call   80101815 <iupdate>
80101e92:	83 c4 10             	add    $0x10,%esp
}
80101e95:	90                   	nop
80101e96:	c9                   	leave
80101e97:	c3                   	ret

80101e98 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e98:	55                   	push   %ebp
80101e99:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 00                	mov    (%eax),%eax
80101ea0:	89 c2                	mov    %eax,%edx
80101ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	8b 50 04             	mov    0x4(%eax),%edx
80101eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebe:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	8b 50 58             	mov    0x58(%eax),%edx
80101ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edb:	90                   	nop
80101edc:	5d                   	pop    %ebp
80101edd:	c3                   	ret

80101ede <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ede:	55                   	push   %ebp
80101edf:	89 e5                	mov    %esp,%ebp
80101ee1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101eeb:	66 83 f8 03          	cmp    $0x3,%ax
80101eef:	75 5c                	jne    80101f4d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef8:	66 85 c0             	test   %ax,%ax
80101efb:	78 20                	js     80101f1d <readi+0x3f>
80101efd:	8b 45 08             	mov    0x8(%ebp),%eax
80101f00:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f04:	66 83 f8 09          	cmp    $0x9,%ax
80101f08:	7f 13                	jg     80101f1d <readi+0x3f>
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f11:	98                   	cwtl
80101f12:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	75 0a                	jne    80101f27 <readi+0x49>
      return -1;
80101f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f22:	e9 0a 01 00 00       	jmp    80102031 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2e:	98                   	cwtl
80101f2f:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f36:	8b 55 14             	mov    0x14(%ebp),%edx
80101f39:	83 ec 04             	sub    $0x4,%esp
80101f3c:	52                   	push   %edx
80101f3d:	ff 75 0c             	push   0xc(%ebp)
80101f40:	ff 75 08             	push   0x8(%ebp)
80101f43:	ff d0                	call   *%eax
80101f45:	83 c4 10             	add    $0x10,%esp
80101f48:	e9 e4 00 00 00       	jmp    80102031 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	8b 40 58             	mov    0x58(%eax),%eax
80101f53:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f56:	72 0d                	jb     80101f65 <readi+0x87>
80101f58:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5e:	01 d0                	add    %edx,%eax
80101f60:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f63:	73 0a                	jae    80101f6f <readi+0x91>
    return -1;
80101f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6a:	e9 c2 00 00 00       	jmp    80102031 <readi+0x153>
  if(off + n > ip->size)
80101f6f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f72:	8b 45 14             	mov    0x14(%ebp),%eax
80101f75:	01 c2                	add    %eax,%edx
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	8b 40 58             	mov    0x58(%eax),%eax
80101f7d:	39 d0                	cmp    %edx,%eax
80101f7f:	73 0c                	jae    80101f8d <readi+0xaf>
    n = ip->size - off;
80101f81:	8b 45 08             	mov    0x8(%ebp),%eax
80101f84:	8b 40 58             	mov    0x58(%eax),%eax
80101f87:	2b 45 10             	sub    0x10(%ebp),%eax
80101f8a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f94:	e9 89 00 00 00       	jmp    80102022 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f99:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9c:	c1 e8 09             	shr    $0x9,%eax
80101f9f:	83 ec 08             	sub    $0x8,%esp
80101fa2:	50                   	push   %eax
80101fa3:	ff 75 08             	push   0x8(%ebp)
80101fa6:	e8 9d fc ff ff       	call   80101c48 <bmap>
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb1:	8b 12                	mov    (%edx),%edx
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	50                   	push   %eax
80101fb7:	52                   	push   %edx
80101fb8:	e8 44 e2 ff ff       	call   80100201 <bread>
80101fbd:	83 c4 10             	add    $0x10,%esp
80101fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcb:	ba 00 02 00 00       	mov    $0x200,%edx
80101fd0:	29 c2                	sub    %eax,%edx
80101fd2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd8:	39 c2                	cmp    %eax,%edx
80101fda:	0f 46 c2             	cmovbe %edx,%eax
80101fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fee:	01 d0                	add    %edx,%eax
80101ff0:	83 ec 04             	sub    $0x4,%esp
80101ff3:	ff 75 ec             	push   -0x14(%ebp)
80101ff6:	50                   	push   %eax
80101ff7:	ff 75 0c             	push   0xc(%ebp)
80101ffa:	e8 6a 31 00 00       	call   80105169 <memmove>
80101fff:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	ff 75 f0             	push   -0x10(%ebp)
80102008:	e8 76 e2 ff ff       	call   80100283 <brelse>
8010200d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102010:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102013:	01 45 f4             	add    %eax,-0xc(%ebp)
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	01 45 10             	add    %eax,0x10(%ebp)
8010201c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201f:	01 45 0c             	add    %eax,0xc(%ebp)
80102022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102025:	3b 45 14             	cmp    0x14(%ebp),%eax
80102028:	0f 82 6b ff ff ff    	jb     80101f99 <readi+0xbb>
  }
  return n;
8010202e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102031:	c9                   	leave
80102032:	c3                   	ret

80102033 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102040:	66 83 f8 03          	cmp    $0x3,%ax
80102044:	75 5c                	jne    801020a2 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204d:	66 85 c0             	test   %ax,%ax
80102050:	78 20                	js     80102072 <writei+0x3f>
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102059:	66 83 f8 09          	cmp    $0x9,%ax
8010205d:	7f 13                	jg     80102072 <writei+0x3f>
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
80102062:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102066:	98                   	cwtl
80102067:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 0a                	jne    8010207c <writei+0x49>
      return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 3b 01 00 00       	jmp    801021b7 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102083:	98                   	cwtl
80102084:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
8010208b:	8b 55 14             	mov    0x14(%ebp),%edx
8010208e:	83 ec 04             	sub    $0x4,%esp
80102091:	52                   	push   %edx
80102092:	ff 75 0c             	push   0xc(%ebp)
80102095:	ff 75 08             	push   0x8(%ebp)
80102098:	ff d0                	call   *%eax
8010209a:	83 c4 10             	add    $0x10,%esp
8010209d:	e9 15 01 00 00       	jmp    801021b7 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020a2:	8b 45 08             	mov    0x8(%ebp),%eax
801020a5:	8b 40 58             	mov    0x58(%eax),%eax
801020a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801020ab:	72 0d                	jb     801020ba <writei+0x87>
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	8b 45 14             	mov    0x14(%ebp),%eax
801020b3:	01 d0                	add    %edx,%eax
801020b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b8:	73 0a                	jae    801020c4 <writei+0x91>
    return -1;
801020ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bf:	e9 f3 00 00 00       	jmp    801021b7 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	8b 45 14             	mov    0x14(%ebp),%eax
801020ca:	01 d0                	add    %edx,%eax
801020cc:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020d1:	76 0a                	jbe    801020dd <writei+0xaa>
    return -1;
801020d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d8:	e9 da 00 00 00       	jmp    801021b7 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e4:	e9 97 00 00 00       	jmp    80102180 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e9:	8b 45 10             	mov    0x10(%ebp),%eax
801020ec:	c1 e8 09             	shr    $0x9,%eax
801020ef:	83 ec 08             	sub    $0x8,%esp
801020f2:	50                   	push   %eax
801020f3:	ff 75 08             	push   0x8(%ebp)
801020f6:	e8 4d fb ff ff       	call   80101c48 <bmap>
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102101:	8b 12                	mov    (%edx),%edx
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	52                   	push   %edx
80102108:	e8 f4 e0 ff ff       	call   80100201 <bread>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102113:	8b 45 10             	mov    0x10(%ebp),%eax
80102116:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211b:	ba 00 02 00 00       	mov    $0x200,%edx
80102120:	29 c2                	sub    %eax,%edx
80102122:	8b 45 14             	mov    0x14(%ebp),%eax
80102125:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102128:	39 c2                	cmp    %eax,%edx
8010212a:	0f 46 c2             	cmovbe %edx,%eax
8010212d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102133:	8d 50 5c             	lea    0x5c(%eax),%edx
80102136:	8b 45 10             	mov    0x10(%ebp),%eax
80102139:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213e:	01 d0                	add    %edx,%eax
80102140:	83 ec 04             	sub    $0x4,%esp
80102143:	ff 75 ec             	push   -0x14(%ebp)
80102146:	ff 75 0c             	push   0xc(%ebp)
80102149:	50                   	push   %eax
8010214a:	e8 1a 30 00 00       	call   80105169 <memmove>
8010214f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	ff 75 f0             	push   -0x10(%ebp)
80102158:	e8 fc 15 00 00       	call   80103759 <log_write>
8010215d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102160:	83 ec 0c             	sub    $0xc,%esp
80102163:	ff 75 f0             	push   -0x10(%ebp)
80102166:	e8 18 e1 ff ff       	call   80100283 <brelse>
8010216b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102171:	01 45 f4             	add    %eax,-0xc(%ebp)
80102174:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102177:	01 45 10             	add    %eax,0x10(%ebp)
8010217a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217d:	01 45 0c             	add    %eax,0xc(%ebp)
80102180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102183:	3b 45 14             	cmp    0x14(%ebp),%eax
80102186:	0f 82 5d ff ff ff    	jb     801020e9 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010218c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102190:	74 22                	je     801021b4 <writei+0x181>
80102192:	8b 45 08             	mov    0x8(%ebp),%eax
80102195:	8b 40 58             	mov    0x58(%eax),%eax
80102198:	3b 45 10             	cmp    0x10(%ebp),%eax
8010219b:	73 17                	jae    801021b4 <writei+0x181>
    ip->size = off;
8010219d:	8b 45 08             	mov    0x8(%ebp),%eax
801021a0:	8b 55 10             	mov    0x10(%ebp),%edx
801021a3:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021a6:	83 ec 0c             	sub    $0xc,%esp
801021a9:	ff 75 08             	push   0x8(%ebp)
801021ac:	e8 64 f6 ff ff       	call   80101815 <iupdate>
801021b1:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b7:	c9                   	leave
801021b8:	c3                   	ret

801021b9 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b9:	55                   	push   %ebp
801021ba:	89 e5                	mov    %esp,%ebp
801021bc:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bf:	83 ec 04             	sub    $0x4,%esp
801021c2:	6a 0e                	push   $0xe
801021c4:	ff 75 0c             	push   0xc(%ebp)
801021c7:	ff 75 08             	push   0x8(%ebp)
801021ca:	e8 30 30 00 00       	call   801051ff <strncmp>
801021cf:	83 c4 10             	add    $0x10,%esp
}
801021d2:	c9                   	leave
801021d3:	c3                   	ret

801021d4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d4:	55                   	push   %ebp
801021d5:	89 e5                	mov    %esp,%ebp
801021d7:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021e1:	66 83 f8 01          	cmp    $0x1,%ax
801021e5:	74 0d                	je     801021f4 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e7:	83 ec 0c             	sub    $0xc,%esp
801021ea:	68 9d a7 10 80       	push   $0x8010a79d
801021ef:	e8 b5 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021fb:	eb 7b                	jmp    80102278 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fd:	6a 10                	push   $0x10
801021ff:	ff 75 f4             	push   -0xc(%ebp)
80102202:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102205:	50                   	push   %eax
80102206:	ff 75 08             	push   0x8(%ebp)
80102209:	e8 d0 fc ff ff       	call   80101ede <readi>
8010220e:	83 c4 10             	add    $0x10,%esp
80102211:	83 f8 10             	cmp    $0x10,%eax
80102214:	74 0d                	je     80102223 <dirlookup+0x4f>
      panic("dirlookup read");
80102216:	83 ec 0c             	sub    $0xc,%esp
80102219:	68 af a7 10 80       	push   $0x8010a7af
8010221e:	e8 86 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102223:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102227:	66 85 c0             	test   %ax,%ax
8010222a:	74 47                	je     80102273 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222c:	83 ec 08             	sub    $0x8,%esp
8010222f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102232:	83 c0 02             	add    $0x2,%eax
80102235:	50                   	push   %eax
80102236:	ff 75 0c             	push   0xc(%ebp)
80102239:	e8 7b ff ff ff       	call   801021b9 <namecmp>
8010223e:	83 c4 10             	add    $0x10,%esp
80102241:	85 c0                	test   %eax,%eax
80102243:	75 2f                	jne    80102274 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102249:	74 08                	je     80102253 <dirlookup+0x7f>
        *poff = off;
8010224b:	8b 45 10             	mov    0x10(%ebp),%eax
8010224e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102251:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102253:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102257:	0f b7 c0             	movzwl %ax,%eax
8010225a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225d:	8b 45 08             	mov    0x8(%ebp),%eax
80102260:	8b 00                	mov    (%eax),%eax
80102262:	83 ec 08             	sub    $0x8,%esp
80102265:	ff 75 f0             	push   -0x10(%ebp)
80102268:	50                   	push   %eax
80102269:	e8 68 f6 ff ff       	call   801018d6 <iget>
8010226e:	83 c4 10             	add    $0x10,%esp
80102271:	eb 19                	jmp    8010228c <dirlookup+0xb8>
      continue;
80102273:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102274:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	8b 40 58             	mov    0x58(%eax),%eax
8010227e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102281:	0f 82 76 ff ff ff    	jb     801021fd <dirlookup+0x29>
    }
  }

  return 0;
80102287:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228c:	c9                   	leave
8010228d:	c3                   	ret

8010228e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228e:	55                   	push   %ebp
8010228f:	89 e5                	mov    %esp,%ebp
80102291:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102294:	83 ec 04             	sub    $0x4,%esp
80102297:	6a 00                	push   $0x0
80102299:	ff 75 0c             	push   0xc(%ebp)
8010229c:	ff 75 08             	push   0x8(%ebp)
8010229f:	e8 30 ff ff ff       	call   801021d4 <dirlookup>
801022a4:	83 c4 10             	add    $0x10,%esp
801022a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ae:	74 18                	je     801022c8 <dirlink+0x3a>
    iput(ip);
801022b0:	83 ec 0c             	sub    $0xc,%esp
801022b3:	ff 75 f0             	push   -0x10(%ebp)
801022b6:	e8 98 f8 ff ff       	call   80101b53 <iput>
801022bb:	83 c4 10             	add    $0x10,%esp
    return -1;
801022be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c3:	e9 9c 00 00 00       	jmp    80102364 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cf:	eb 39                	jmp    8010230a <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d4:	6a 10                	push   $0x10
801022d6:	50                   	push   %eax
801022d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022da:	50                   	push   %eax
801022db:	ff 75 08             	push   0x8(%ebp)
801022de:	e8 fb fb ff ff       	call   80101ede <readi>
801022e3:	83 c4 10             	add    $0x10,%esp
801022e6:	83 f8 10             	cmp    $0x10,%eax
801022e9:	74 0d                	je     801022f8 <dirlink+0x6a>
      panic("dirlink read");
801022eb:	83 ec 0c             	sub    $0xc,%esp
801022ee:	68 be a7 10 80       	push   $0x8010a7be
801022f3:	e8 b1 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fc:	66 85 c0             	test   %ax,%ax
801022ff:	74 18                	je     80102319 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102304:	83 c0 10             	add    $0x10,%eax
80102307:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010230a:	8b 45 08             	mov    0x8(%ebp),%eax
8010230d:	8b 40 58             	mov    0x58(%eax),%eax
80102310:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102313:	39 c2                	cmp    %eax,%edx
80102315:	72 ba                	jb     801022d1 <dirlink+0x43>
80102317:	eb 01                	jmp    8010231a <dirlink+0x8c>
      break;
80102319:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010231a:	83 ec 04             	sub    $0x4,%esp
8010231d:	6a 0e                	push   $0xe
8010231f:	ff 75 0c             	push   0xc(%ebp)
80102322:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102325:	83 c0 02             	add    $0x2,%eax
80102328:	50                   	push   %eax
80102329:	e8 27 2f 00 00       	call   80105255 <strncpy>
8010232e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	6a 10                	push   $0x10
8010233d:	50                   	push   %eax
8010233e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102341:	50                   	push   %eax
80102342:	ff 75 08             	push   0x8(%ebp)
80102345:	e8 e9 fc ff ff       	call   80102033 <writei>
8010234a:	83 c4 10             	add    $0x10,%esp
8010234d:	83 f8 10             	cmp    $0x10,%eax
80102350:	74 0d                	je     8010235f <dirlink+0xd1>
    panic("dirlink");
80102352:	83 ec 0c             	sub    $0xc,%esp
80102355:	68 cb a7 10 80       	push   $0x8010a7cb
8010235a:	e8 4a e2 ff ff       	call   801005a9 <panic>

  return 0;
8010235f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102364:	c9                   	leave
80102365:	c3                   	ret

80102366 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102366:	55                   	push   %ebp
80102367:	89 e5                	mov    %esp,%ebp
80102369:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236c:	eb 04                	jmp    80102372 <skipelem+0xc>
    path++;
8010236e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	0f b6 00             	movzbl (%eax),%eax
80102378:	3c 2f                	cmp    $0x2f,%al
8010237a:	74 f2                	je     8010236e <skipelem+0x8>
  if(*path == 0)
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	0f b6 00             	movzbl (%eax),%eax
80102382:	84 c0                	test   %al,%al
80102384:	75 07                	jne    8010238d <skipelem+0x27>
    return 0;
80102386:	b8 00 00 00 00       	mov    $0x0,%eax
8010238b:	eb 77                	jmp    80102404 <skipelem+0x9e>
  s = path;
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102393:	eb 04                	jmp    80102399 <skipelem+0x33>
    path++;
80102395:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	0f b6 00             	movzbl (%eax),%eax
8010239f:	3c 2f                	cmp    $0x2f,%al
801023a1:	74 0a                	je     801023ad <skipelem+0x47>
801023a3:	8b 45 08             	mov    0x8(%ebp),%eax
801023a6:	0f b6 00             	movzbl (%eax),%eax
801023a9:	84 c0                	test   %al,%al
801023ab:	75 e8                	jne    80102395 <skipelem+0x2f>
  len = path - s;
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ba:	7e 15                	jle    801023d1 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023bc:	83 ec 04             	sub    $0x4,%esp
801023bf:	6a 0e                	push   $0xe
801023c1:	ff 75 f4             	push   -0xc(%ebp)
801023c4:	ff 75 0c             	push   0xc(%ebp)
801023c7:	e8 9d 2d 00 00       	call   80105169 <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 86 2d 00 00       	call   80105169 <memmove>
801023e3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ec:	01 d0                	add    %edx,%eax
801023ee:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f1:	eb 04                	jmp    801023f7 <skipelem+0x91>
    path++;
801023f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b6 00             	movzbl (%eax),%eax
801023fd:	3c 2f                	cmp    $0x2f,%al
801023ff:	74 f2                	je     801023f3 <skipelem+0x8d>
  return path;
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102404:	c9                   	leave
80102405:	c3                   	ret

80102406 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	0f b6 00             	movzbl (%eax),%eax
80102412:	3c 2f                	cmp    $0x2f,%al
80102414:	75 17                	jne    8010242d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102416:	83 ec 08             	sub    $0x8,%esp
80102419:	6a 01                	push   $0x1
8010241b:	6a 01                	push   $0x1
8010241d:	e8 b4 f4 ff ff       	call   801018d6 <iget>
80102422:	83 c4 10             	add    $0x10,%esp
80102425:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102428:	e9 ba 00 00 00       	jmp    801024e7 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010242d:	e8 e0 1a 00 00       	call   80103f12 <myproc>
80102432:	8b 40 68             	mov    0x68(%eax),%eax
80102435:	83 ec 0c             	sub    $0xc,%esp
80102438:	50                   	push   %eax
80102439:	e8 7a f5 ff ff       	call   801019b8 <idup>
8010243e:	83 c4 10             	add    $0x10,%esp
80102441:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102444:	e9 9e 00 00 00       	jmp    801024e7 <namex+0xe1>
    ilock(ip);
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	ff 75 f4             	push   -0xc(%ebp)
8010244f:	e8 9e f5 ff ff       	call   801019f2 <ilock>
80102454:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010245e:	66 83 f8 01          	cmp    $0x1,%ax
80102462:	74 18                	je     8010247c <namex+0x76>
      iunlockput(ip);
80102464:	83 ec 0c             	sub    $0xc,%esp
80102467:	ff 75 f4             	push   -0xc(%ebp)
8010246a:	e8 b4 f7 ff ff       	call   80101c23 <iunlockput>
8010246f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102472:	b8 00 00 00 00       	mov    $0x0,%eax
80102477:	e9 a7 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010247c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102480:	74 20                	je     801024a2 <namex+0x9c>
80102482:	8b 45 08             	mov    0x8(%ebp),%eax
80102485:	0f b6 00             	movzbl (%eax),%eax
80102488:	84 c0                	test   %al,%al
8010248a:	75 16                	jne    801024a2 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010248c:	83 ec 0c             	sub    $0xc,%esp
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	e8 6e f6 ff ff       	call   80101b05 <iunlock>
80102497:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249d:	e9 81 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	6a 00                	push   $0x0
801024a7:	ff 75 10             	push   0x10(%ebp)
801024aa:	ff 75 f4             	push   -0xc(%ebp)
801024ad:	e8 22 fd ff ff       	call   801021d4 <dirlookup>
801024b2:	83 c4 10             	add    $0x10,%esp
801024b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bc:	75 15                	jne    801024d3 <namex+0xcd>
      iunlockput(ip);
801024be:	83 ec 0c             	sub    $0xc,%esp
801024c1:	ff 75 f4             	push   -0xc(%ebp)
801024c4:	e8 5a f7 ff ff       	call   80101c23 <iunlockput>
801024c9:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cc:	b8 00 00 00 00       	mov    $0x0,%eax
801024d1:	eb 50                	jmp    80102523 <namex+0x11d>
    }
    iunlockput(ip);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 f4             	push   -0xc(%ebp)
801024d9:	e8 45 f7 ff ff       	call   80101c23 <iunlockput>
801024de:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024e7:	83 ec 08             	sub    $0x8,%esp
801024ea:	ff 75 10             	push   0x10(%ebp)
801024ed:	ff 75 08             	push   0x8(%ebp)
801024f0:	e8 71 fe ff ff       	call   80102366 <skipelem>
801024f5:	83 c4 10             	add    $0x10,%esp
801024f8:	89 45 08             	mov    %eax,0x8(%ebp)
801024fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ff:	0f 85 44 ff ff ff    	jne    80102449 <namex+0x43>
  }
  if(nameiparent){
80102505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102509:	74 15                	je     80102520 <namex+0x11a>
    iput(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	push   -0xc(%ebp)
80102511:	e8 3d f6 ff ff       	call   80101b53 <iput>
80102516:	83 c4 10             	add    $0x10,%esp
    return 0;
80102519:	b8 00 00 00 00       	mov    $0x0,%eax
8010251e:	eb 03                	jmp    80102523 <namex+0x11d>
  }
  return ip;
80102520:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102523:	c9                   	leave
80102524:	c3                   	ret

80102525 <namei>:

struct inode*
namei(char *path)
{
80102525:	55                   	push   %ebp
80102526:	89 e5                	mov    %esp,%ebp
80102528:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252b:	83 ec 04             	sub    $0x4,%esp
8010252e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102531:	50                   	push   %eax
80102532:	6a 00                	push   $0x0
80102534:	ff 75 08             	push   0x8(%ebp)
80102537:	e8 ca fe ff ff       	call   80102406 <namex>
8010253c:	83 c4 10             	add    $0x10,%esp
}
8010253f:	c9                   	leave
80102540:	c3                   	ret

80102541 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102541:	55                   	push   %ebp
80102542:	89 e5                	mov    %esp,%ebp
80102544:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102547:	83 ec 04             	sub    $0x4,%esp
8010254a:	ff 75 0c             	push   0xc(%ebp)
8010254d:	6a 01                	push   $0x1
8010254f:	ff 75 08             	push   0x8(%ebp)
80102552:	e8 af fe ff ff       	call   80102406 <namex>
80102557:	83 c4 10             	add    $0x10,%esp
}
8010255a:	c9                   	leave
8010255b:	c3                   	ret

8010255c <inb>:
{
8010255c:	55                   	push   %ebp
8010255d:	89 e5                	mov    %esp,%ebp
8010255f:	83 ec 14             	sub    $0x14,%esp
80102562:	8b 45 08             	mov    0x8(%ebp),%eax
80102565:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102569:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010256d:	89 c2                	mov    %eax,%edx
8010256f:	ec                   	in     (%dx),%al
80102570:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102573:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102577:	c9                   	leave
80102578:	c3                   	ret

80102579 <insl>:
{
80102579:	55                   	push   %ebp
8010257a:	89 e5                	mov    %esp,%ebp
8010257c:	57                   	push   %edi
8010257d:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010257e:	8b 55 08             	mov    0x8(%ebp),%edx
80102581:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102584:	8b 45 10             	mov    0x10(%ebp),%eax
80102587:	89 cb                	mov    %ecx,%ebx
80102589:	89 df                	mov    %ebx,%edi
8010258b:	89 c1                	mov    %eax,%ecx
8010258d:	fc                   	cld
8010258e:	f3 6d                	rep insl (%dx),%es:(%edi)
80102590:	89 c8                	mov    %ecx,%eax
80102592:	89 fb                	mov    %edi,%ebx
80102594:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102597:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010259a:	90                   	nop
8010259b:	5b                   	pop    %ebx
8010259c:	5f                   	pop    %edi
8010259d:	5d                   	pop    %ebp
8010259e:	c3                   	ret

8010259f <outb>:
{
8010259f:	55                   	push   %ebp
801025a0:	89 e5                	mov    %esp,%ebp
801025a2:	83 ec 08             	sub    $0x8,%esp
801025a5:	8b 55 08             	mov    0x8(%ebp),%edx
801025a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801025ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025af:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025ba:	ee                   	out    %al,(%dx)
}
801025bb:	90                   	nop
801025bc:	c9                   	leave
801025bd:	c3                   	ret

801025be <outsl>:
{
801025be:	55                   	push   %ebp
801025bf:	89 e5                	mov    %esp,%ebp
801025c1:	56                   	push   %esi
801025c2:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025c3:	8b 55 08             	mov    0x8(%ebp),%edx
801025c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025c9:	8b 45 10             	mov    0x10(%ebp),%eax
801025cc:	89 cb                	mov    %ecx,%ebx
801025ce:	89 de                	mov    %ebx,%esi
801025d0:	89 c1                	mov    %eax,%ecx
801025d2:	fc                   	cld
801025d3:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025d5:	89 c8                	mov    %ecx,%eax
801025d7:	89 f3                	mov    %esi,%ebx
801025d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025dc:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025df:	90                   	nop
801025e0:	5b                   	pop    %ebx
801025e1:	5e                   	pop    %esi
801025e2:	5d                   	pop    %ebp
801025e3:	c3                   	ret

801025e4 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025e4:	55                   	push   %ebp
801025e5:	89 e5                	mov    %esp,%ebp
801025e7:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025ea:	90                   	nop
801025eb:	68 f7 01 00 00       	push   $0x1f7
801025f0:	e8 67 ff ff ff       	call   8010255c <inb>
801025f5:	83 c4 04             	add    $0x4,%esp
801025f8:	0f b6 c0             	movzbl %al,%eax
801025fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102601:	25 c0 00 00 00       	and    $0xc0,%eax
80102606:	83 f8 40             	cmp    $0x40,%eax
80102609:	75 e0                	jne    801025eb <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010260b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010260f:	74 11                	je     80102622 <idewait+0x3e>
80102611:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102614:	83 e0 21             	and    $0x21,%eax
80102617:	85 c0                	test   %eax,%eax
80102619:	74 07                	je     80102622 <idewait+0x3e>
    return -1;
8010261b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102620:	eb 05                	jmp    80102627 <idewait+0x43>
  return 0;
80102622:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102627:	c9                   	leave
80102628:	c3                   	ret

80102629 <ideinit>:

void
ideinit(void)
{
80102629:	55                   	push   %ebp
8010262a:	89 e5                	mov    %esp,%ebp
8010262c:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
8010262f:	83 ec 08             	sub    $0x8,%esp
80102632:	68 d3 a7 10 80       	push   $0x8010a7d3
80102637:	68 c0 70 11 80       	push   $0x801170c0
8010263c:	e8 d1 27 00 00       	call   80104e12 <initlock>
80102641:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102644:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80102649:	83 e8 01             	sub    $0x1,%eax
8010264c:	83 ec 08             	sub    $0x8,%esp
8010264f:	50                   	push   %eax
80102650:	6a 0e                	push   $0xe
80102652:	e8 c1 04 00 00       	call   80102b18 <ioapicenable>
80102657:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010265a:	83 ec 0c             	sub    $0xc,%esp
8010265d:	6a 00                	push   $0x0
8010265f:	e8 80 ff ff ff       	call   801025e4 <idewait>
80102664:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102667:	83 ec 08             	sub    $0x8,%esp
8010266a:	68 f0 00 00 00       	push   $0xf0
8010266f:	68 f6 01 00 00       	push   $0x1f6
80102674:	e8 26 ff ff ff       	call   8010259f <outb>
80102679:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010267c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102683:	eb 24                	jmp    801026a9 <ideinit+0x80>
    if(inb(0x1f7) != 0){
80102685:	83 ec 0c             	sub    $0xc,%esp
80102688:	68 f7 01 00 00       	push   $0x1f7
8010268d:	e8 ca fe ff ff       	call   8010255c <inb>
80102692:	83 c4 10             	add    $0x10,%esp
80102695:	84 c0                	test   %al,%al
80102697:	74 0c                	je     801026a5 <ideinit+0x7c>
      havedisk1 = 1;
80102699:	c7 05 f8 70 11 80 01 	movl   $0x1,0x801170f8
801026a0:	00 00 00 
      break;
801026a3:	eb 0d                	jmp    801026b2 <ideinit+0x89>
  for(i=0; i<1000; i++){
801026a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026a9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026b0:	7e d3                	jle    80102685 <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026b2:	83 ec 08             	sub    $0x8,%esp
801026b5:	68 e0 00 00 00       	push   $0xe0
801026ba:	68 f6 01 00 00       	push   $0x1f6
801026bf:	e8 db fe ff ff       	call   8010259f <outb>
801026c4:	83 c4 10             	add    $0x10,%esp
}
801026c7:	90                   	nop
801026c8:	c9                   	leave
801026c9:	c3                   	ret

801026ca <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026ca:	55                   	push   %ebp
801026cb:	89 e5                	mov    %esp,%ebp
801026cd:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026d4:	75 0d                	jne    801026e3 <idestart+0x19>
    panic("idestart");
801026d6:	83 ec 0c             	sub    $0xc,%esp
801026d9:	68 d7 a7 10 80       	push   $0x8010a7d7
801026de:	e8 c6 de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026e3:	8b 45 08             	mov    0x8(%ebp),%eax
801026e6:	8b 40 08             	mov    0x8(%eax),%eax
801026e9:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026ee:	76 0d                	jbe    801026fd <idestart+0x33>
    panic("incorrect blockno");
801026f0:	83 ec 0c             	sub    $0xc,%esp
801026f3:	68 e0 a7 10 80       	push   $0x8010a7e0
801026f8:	e8 ac de ff ff       	call   801005a9 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026fd:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102704:	8b 45 08             	mov    0x8(%ebp),%eax
80102707:	8b 50 08             	mov    0x8(%eax),%edx
8010270a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010270d:	0f af c2             	imul   %edx,%eax
80102710:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102713:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102717:	75 07                	jne    80102720 <idestart+0x56>
80102719:	b8 20 00 00 00       	mov    $0x20,%eax
8010271e:	eb 05                	jmp    80102725 <idestart+0x5b>
80102720:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102728:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010272c:	75 07                	jne    80102735 <idestart+0x6b>
8010272e:	b8 30 00 00 00       	mov    $0x30,%eax
80102733:	eb 05                	jmp    8010273a <idestart+0x70>
80102735:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010273a:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010273d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102741:	7e 0d                	jle    80102750 <idestart+0x86>
80102743:	83 ec 0c             	sub    $0xc,%esp
80102746:	68 d7 a7 10 80       	push   $0x8010a7d7
8010274b:	e8 59 de ff ff       	call   801005a9 <panic>

  idewait(0);
80102750:	83 ec 0c             	sub    $0xc,%esp
80102753:	6a 00                	push   $0x0
80102755:	e8 8a fe ff ff       	call   801025e4 <idewait>
8010275a:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
8010275d:	83 ec 08             	sub    $0x8,%esp
80102760:	6a 00                	push   $0x0
80102762:	68 f6 03 00 00       	push   $0x3f6
80102767:	e8 33 fe ff ff       	call   8010259f <outb>
8010276c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
8010276f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102772:	0f b6 c0             	movzbl %al,%eax
80102775:	83 ec 08             	sub    $0x8,%esp
80102778:	50                   	push   %eax
80102779:	68 f2 01 00 00       	push   $0x1f2
8010277e:	e8 1c fe ff ff       	call   8010259f <outb>
80102783:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102786:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102789:	0f b6 c0             	movzbl %al,%eax
8010278c:	83 ec 08             	sub    $0x8,%esp
8010278f:	50                   	push   %eax
80102790:	68 f3 01 00 00       	push   $0x1f3
80102795:	e8 05 fe ff ff       	call   8010259f <outb>
8010279a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010279d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a0:	c1 f8 08             	sar    $0x8,%eax
801027a3:	0f b6 c0             	movzbl %al,%eax
801027a6:	83 ec 08             	sub    $0x8,%esp
801027a9:	50                   	push   %eax
801027aa:	68 f4 01 00 00       	push   $0x1f4
801027af:	e8 eb fd ff ff       	call   8010259f <outb>
801027b4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ba:	c1 f8 10             	sar    $0x10,%eax
801027bd:	0f b6 c0             	movzbl %al,%eax
801027c0:	83 ec 08             	sub    $0x8,%esp
801027c3:	50                   	push   %eax
801027c4:	68 f5 01 00 00       	push   $0x1f5
801027c9:	e8 d1 fd ff ff       	call   8010259f <outb>
801027ce:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027d1:	8b 45 08             	mov    0x8(%ebp),%eax
801027d4:	8b 40 04             	mov    0x4(%eax),%eax
801027d7:	c1 e0 04             	shl    $0x4,%eax
801027da:	83 e0 10             	and    $0x10,%eax
801027dd:	89 c2                	mov    %eax,%edx
801027df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027e2:	c1 f8 18             	sar    $0x18,%eax
801027e5:	83 e0 0f             	and    $0xf,%eax
801027e8:	09 d0                	or     %edx,%eax
801027ea:	83 c8 e0             	or     $0xffffffe0,%eax
801027ed:	0f b6 c0             	movzbl %al,%eax
801027f0:	83 ec 08             	sub    $0x8,%esp
801027f3:	50                   	push   %eax
801027f4:	68 f6 01 00 00       	push   $0x1f6
801027f9:	e8 a1 fd ff ff       	call   8010259f <outb>
801027fe:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102801:	8b 45 08             	mov    0x8(%ebp),%eax
80102804:	8b 00                	mov    (%eax),%eax
80102806:	83 e0 04             	and    $0x4,%eax
80102809:	85 c0                	test   %eax,%eax
8010280b:	74 35                	je     80102842 <idestart+0x178>
    outb(0x1f7, write_cmd);
8010280d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102810:	0f b6 c0             	movzbl %al,%eax
80102813:	83 ec 08             	sub    $0x8,%esp
80102816:	50                   	push   %eax
80102817:	68 f7 01 00 00       	push   $0x1f7
8010281c:	e8 7e fd ff ff       	call   8010259f <outb>
80102821:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102824:	8b 45 08             	mov    0x8(%ebp),%eax
80102827:	83 c0 5c             	add    $0x5c,%eax
8010282a:	83 ec 04             	sub    $0x4,%esp
8010282d:	68 80 00 00 00       	push   $0x80
80102832:	50                   	push   %eax
80102833:	68 f0 01 00 00       	push   $0x1f0
80102838:	e8 81 fd ff ff       	call   801025be <outsl>
8010283d:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102840:	eb 17                	jmp    80102859 <idestart+0x18f>
    outb(0x1f7, read_cmd);
80102842:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102845:	0f b6 c0             	movzbl %al,%eax
80102848:	83 ec 08             	sub    $0x8,%esp
8010284b:	50                   	push   %eax
8010284c:	68 f7 01 00 00       	push   $0x1f7
80102851:	e8 49 fd ff ff       	call   8010259f <outb>
80102856:	83 c4 10             	add    $0x10,%esp
}
80102859:	90                   	nop
8010285a:	c9                   	leave
8010285b:	c3                   	ret

8010285c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010285c:	55                   	push   %ebp
8010285d:	89 e5                	mov    %esp,%ebp
8010285f:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102862:	83 ec 0c             	sub    $0xc,%esp
80102865:	68 c0 70 11 80       	push   $0x801170c0
8010286a:	e8 c5 25 00 00       	call   80104e34 <acquire>
8010286f:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102872:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102877:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010287a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010287e:	75 15                	jne    80102895 <ideintr+0x39>
    release(&idelock);
80102880:	83 ec 0c             	sub    $0xc,%esp
80102883:	68 c0 70 11 80       	push   $0x801170c0
80102888:	e8 15 26 00 00       	call   80104ea2 <release>
8010288d:	83 c4 10             	add    $0x10,%esp
    return;
80102890:	e9 9a 00 00 00       	jmp    8010292f <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102898:	8b 40 58             	mov    0x58(%eax),%eax
8010289b:	a3 f4 70 11 80       	mov    %eax,0x801170f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a3:	8b 00                	mov    (%eax),%eax
801028a5:	83 e0 04             	and    $0x4,%eax
801028a8:	85 c0                	test   %eax,%eax
801028aa:	75 2d                	jne    801028d9 <ideintr+0x7d>
801028ac:	83 ec 0c             	sub    $0xc,%esp
801028af:	6a 01                	push   $0x1
801028b1:	e8 2e fd ff ff       	call   801025e4 <idewait>
801028b6:	83 c4 10             	add    $0x10,%esp
801028b9:	85 c0                	test   %eax,%eax
801028bb:	78 1c                	js     801028d9 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c0:	83 c0 5c             	add    $0x5c,%eax
801028c3:	83 ec 04             	sub    $0x4,%esp
801028c6:	68 80 00 00 00       	push   $0x80
801028cb:	50                   	push   %eax
801028cc:	68 f0 01 00 00       	push   $0x1f0
801028d1:	e8 a3 fc ff ff       	call   80102579 <insl>
801028d6:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028dc:	8b 00                	mov    (%eax),%eax
801028de:	83 c8 02             	or     $0x2,%eax
801028e1:	89 c2                	mov    %eax,%edx
801028e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e6:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028eb:	8b 00                	mov    (%eax),%eax
801028ed:	83 e0 fb             	and    $0xfffffffb,%eax
801028f0:	89 c2                	mov    %eax,%edx
801028f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f5:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028f7:	83 ec 0c             	sub    $0xc,%esp
801028fa:	ff 75 f4             	push   -0xc(%ebp)
801028fd:	e8 a0 1f 00 00       	call   801048a2 <wakeup>
80102902:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102905:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010290a:	85 c0                	test   %eax,%eax
8010290c:	74 11                	je     8010291f <ideintr+0xc3>
    idestart(idequeue);
8010290e:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102913:	83 ec 0c             	sub    $0xc,%esp
80102916:	50                   	push   %eax
80102917:	e8 ae fd ff ff       	call   801026ca <idestart>
8010291c:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010291f:	83 ec 0c             	sub    $0xc,%esp
80102922:	68 c0 70 11 80       	push   $0x801170c0
80102927:	e8 76 25 00 00       	call   80104ea2 <release>
8010292c:	83 c4 10             	add    $0x10,%esp
}
8010292f:	c9                   	leave
80102930:	c3                   	ret

80102931 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102931:	55                   	push   %ebp
80102932:	89 e5                	mov    %esp,%ebp
80102934:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102937:	8b 15 f8 70 11 80    	mov    0x801170f8,%edx
8010293d:	8b 45 08             	mov    0x8(%ebp),%eax
80102940:	8b 40 04             	mov    0x4(%eax),%eax
80102943:	83 ec 04             	sub    $0x4,%esp
80102946:	52                   	push   %edx
80102947:	50                   	push   %eax
80102948:	68 f2 a7 10 80       	push   $0x8010a7f2
8010294d:	e8 a2 da ff ff       	call   801003f4 <cprintf>
80102952:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
80102955:	8b 45 08             	mov    0x8(%ebp),%eax
80102958:	83 c0 0c             	add    $0xc,%eax
8010295b:	83 ec 0c             	sub    $0xc,%esp
8010295e:	50                   	push   %eax
8010295f:	e8 3f 24 00 00       	call   80104da3 <holdingsleep>
80102964:	83 c4 10             	add    $0x10,%esp
80102967:	85 c0                	test   %eax,%eax
80102969:	75 0d                	jne    80102978 <iderw+0x47>
    panic("iderw: buf not locked");
8010296b:	83 ec 0c             	sub    $0xc,%esp
8010296e:	68 0c a8 10 80       	push   $0x8010a80c
80102973:	e8 31 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102978:	8b 45 08             	mov    0x8(%ebp),%eax
8010297b:	8b 00                	mov    (%eax),%eax
8010297d:	83 e0 06             	and    $0x6,%eax
80102980:	83 f8 02             	cmp    $0x2,%eax
80102983:	75 0d                	jne    80102992 <iderw+0x61>
    panic("iderw: nothing to do");
80102985:	83 ec 0c             	sub    $0xc,%esp
80102988:	68 22 a8 10 80       	push   $0x8010a822
8010298d:	e8 17 dc ff ff       	call   801005a9 <panic>
  if(b->dev != 0 && !havedisk1)
80102992:	8b 45 08             	mov    0x8(%ebp),%eax
80102995:	8b 40 04             	mov    0x4(%eax),%eax
80102998:	85 c0                	test   %eax,%eax
8010299a:	74 16                	je     801029b2 <iderw+0x81>
8010299c:	a1 f8 70 11 80       	mov    0x801170f8,%eax
801029a1:	85 c0                	test   %eax,%eax
801029a3:	75 0d                	jne    801029b2 <iderw+0x81>
    panic("iderw: ide disk 1 not present");
801029a5:	83 ec 0c             	sub    $0xc,%esp
801029a8:	68 37 a8 10 80       	push   $0x8010a837
801029ad:	e8 f7 db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029b2:	83 ec 0c             	sub    $0xc,%esp
801029b5:	68 c0 70 11 80       	push   $0x801170c0
801029ba:	e8 75 24 00 00       	call   80104e34 <acquire>
801029bf:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029c2:	8b 45 08             	mov    0x8(%ebp),%eax
801029c5:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029cc:	c7 45 f4 f4 70 11 80 	movl   $0x801170f4,-0xc(%ebp)
801029d3:	eb 0b                	jmp    801029e0 <iderw+0xaf>
801029d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d8:	8b 00                	mov    (%eax),%eax
801029da:	83 c0 58             	add    $0x58,%eax
801029dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e3:	8b 00                	mov    (%eax),%eax
801029e5:	85 c0                	test   %eax,%eax
801029e7:	75 ec                	jne    801029d5 <iderw+0xa4>
    ;
  *pp = b;
801029e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ec:	8b 55 08             	mov    0x8(%ebp),%edx
801029ef:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029f1:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801029f6:	39 45 08             	cmp    %eax,0x8(%ebp)
801029f9:	75 23                	jne    80102a1e <iderw+0xed>
    idestart(b);
801029fb:	83 ec 0c             	sub    $0xc,%esp
801029fe:	ff 75 08             	push   0x8(%ebp)
80102a01:	e8 c4 fc ff ff       	call   801026ca <idestart>
80102a06:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a09:	eb 13                	jmp    80102a1e <iderw+0xed>
    sleep(b, &idelock);
80102a0b:	83 ec 08             	sub    $0x8,%esp
80102a0e:	68 c0 70 11 80       	push   $0x801170c0
80102a13:	ff 75 08             	push   0x8(%ebp)
80102a16:	e8 a0 1d 00 00       	call   801047bb <sleep>
80102a1b:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a21:	8b 00                	mov    (%eax),%eax
80102a23:	83 e0 06             	and    $0x6,%eax
80102a26:	83 f8 02             	cmp    $0x2,%eax
80102a29:	75 e0                	jne    80102a0b <iderw+0xda>
  }


  release(&idelock);
80102a2b:	83 ec 0c             	sub    $0xc,%esp
80102a2e:	68 c0 70 11 80       	push   $0x801170c0
80102a33:	e8 6a 24 00 00       	call   80104ea2 <release>
80102a38:	83 c4 10             	add    $0x10,%esp
}
80102a3b:	90                   	nop
80102a3c:	c9                   	leave
80102a3d:	c3                   	ret

80102a3e <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a3e:	55                   	push   %ebp
80102a3f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a41:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a46:	8b 55 08             	mov    0x8(%ebp),%edx
80102a49:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a4b:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a50:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a53:	5d                   	pop    %ebp
80102a54:	c3                   	ret

80102a55 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a55:	55                   	push   %ebp
80102a56:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a58:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a5d:	8b 55 08             	mov    0x8(%ebp),%edx
80102a60:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a62:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a67:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a6a:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a6d:	90                   	nop
80102a6e:	5d                   	pop    %ebp
80102a6f:	c3                   	ret

80102a70 <ioapicinit>:

void
ioapicinit(void)
{
80102a70:	55                   	push   %ebp
80102a71:	89 e5                	mov    %esp,%ebp
80102a73:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a76:	c7 05 fc 70 11 80 00 	movl   $0xfec00000,0x801170fc
80102a7d:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a80:	6a 01                	push   $0x1
80102a82:	e8 b7 ff ff ff       	call   80102a3e <ioapicread>
80102a87:	83 c4 04             	add    $0x4,%esp
80102a8a:	c1 e8 10             	shr    $0x10,%eax
80102a8d:	25 ff 00 00 00       	and    $0xff,%eax
80102a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a95:	6a 00                	push   $0x0
80102a97:	e8 a2 ff ff ff       	call   80102a3e <ioapicread>
80102a9c:	83 c4 04             	add    $0x4,%esp
80102a9f:	c1 e8 18             	shr    $0x18,%eax
80102aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102aa5:	0f b6 05 84 9d 11 80 	movzbl 0x80119d84,%eax
80102aac:	0f b6 c0             	movzbl %al,%eax
80102aaf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102ab2:	74 10                	je     80102ac4 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ab4:	83 ec 0c             	sub    $0xc,%esp
80102ab7:	68 58 a8 10 80       	push   $0x8010a858
80102abc:	e8 33 d9 ff ff       	call   801003f4 <cprintf>
80102ac1:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102acb:	eb 3f                	jmp    80102b0c <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad0:	83 c0 20             	add    $0x20,%eax
80102ad3:	0d 00 00 01 00       	or     $0x10000,%eax
80102ad8:	89 c2                	mov    %eax,%edx
80102ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102add:	83 c0 08             	add    $0x8,%eax
80102ae0:	01 c0                	add    %eax,%eax
80102ae2:	83 ec 08             	sub    $0x8,%esp
80102ae5:	52                   	push   %edx
80102ae6:	50                   	push   %eax
80102ae7:	e8 69 ff ff ff       	call   80102a55 <ioapicwrite>
80102aec:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af2:	83 c0 08             	add    $0x8,%eax
80102af5:	01 c0                	add    %eax,%eax
80102af7:	83 c0 01             	add    $0x1,%eax
80102afa:	83 ec 08             	sub    $0x8,%esp
80102afd:	6a 00                	push   $0x0
80102aff:	50                   	push   %eax
80102b00:	e8 50 ff ff ff       	call   80102a55 <ioapicwrite>
80102b05:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b08:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b12:	7e b9                	jle    80102acd <ioapicinit+0x5d>
  }
}
80102b14:	90                   	nop
80102b15:	90                   	nop
80102b16:	c9                   	leave
80102b17:	c3                   	ret

80102b18 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b18:	55                   	push   %ebp
80102b19:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1e:	83 c0 20             	add    $0x20,%eax
80102b21:	89 c2                	mov    %eax,%edx
80102b23:	8b 45 08             	mov    0x8(%ebp),%eax
80102b26:	83 c0 08             	add    $0x8,%eax
80102b29:	01 c0                	add    %eax,%eax
80102b2b:	52                   	push   %edx
80102b2c:	50                   	push   %eax
80102b2d:	e8 23 ff ff ff       	call   80102a55 <ioapicwrite>
80102b32:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b38:	c1 e0 18             	shl    $0x18,%eax
80102b3b:	89 c2                	mov    %eax,%edx
80102b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b40:	83 c0 08             	add    $0x8,%eax
80102b43:	01 c0                	add    %eax,%eax
80102b45:	83 c0 01             	add    $0x1,%eax
80102b48:	52                   	push   %edx
80102b49:	50                   	push   %eax
80102b4a:	e8 06 ff ff ff       	call   80102a55 <ioapicwrite>
80102b4f:	83 c4 08             	add    $0x8,%esp
}
80102b52:	90                   	nop
80102b53:	c9                   	leave
80102b54:	c3                   	ret

80102b55 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b55:	55                   	push   %ebp
80102b56:	89 e5                	mov    %esp,%ebp
80102b58:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b5b:	83 ec 08             	sub    $0x8,%esp
80102b5e:	68 8a a8 10 80       	push   $0x8010a88a
80102b63:	68 00 71 11 80       	push   $0x80117100
80102b68:	e8 a5 22 00 00       	call   80104e12 <initlock>
80102b6d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b70:	c7 05 34 71 11 80 00 	movl   $0x0,0x80117134
80102b77:	00 00 00 
  freerange(vstart, vend);
80102b7a:	83 ec 08             	sub    $0x8,%esp
80102b7d:	ff 75 0c             	push   0xc(%ebp)
80102b80:	ff 75 08             	push   0x8(%ebp)
80102b83:	e8 2a 00 00 00       	call   80102bb2 <freerange>
80102b88:	83 c4 10             	add    $0x10,%esp
}
80102b8b:	90                   	nop
80102b8c:	c9                   	leave
80102b8d:	c3                   	ret

80102b8e <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b8e:	55                   	push   %ebp
80102b8f:	89 e5                	mov    %esp,%ebp
80102b91:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b94:	83 ec 08             	sub    $0x8,%esp
80102b97:	ff 75 0c             	push   0xc(%ebp)
80102b9a:	ff 75 08             	push   0x8(%ebp)
80102b9d:	e8 10 00 00 00       	call   80102bb2 <freerange>
80102ba2:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ba5:	c7 05 34 71 11 80 01 	movl   $0x1,0x80117134
80102bac:	00 00 00 
}
80102baf:	90                   	nop
80102bb0:	c9                   	leave
80102bb1:	c3                   	ret

80102bb2 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bb2:	55                   	push   %ebp
80102bb3:	89 e5                	mov    %esp,%ebp
80102bb5:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbb:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bc0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc8:	eb 15                	jmp    80102bdf <freerange+0x2d>
    kfree(p);
80102bca:	83 ec 0c             	sub    $0xc,%esp
80102bcd:	ff 75 f4             	push   -0xc(%ebp)
80102bd0:	e8 1b 00 00 00       	call   80102bf0 <kfree>
80102bd5:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be2:	05 00 10 00 00       	add    $0x1000,%eax
80102be7:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bea:	73 de                	jae    80102bca <freerange+0x18>
}
80102bec:	90                   	nop
80102bed:	90                   	nop
80102bee:	c9                   	leave
80102bef:	c3                   	ret

80102bf0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bf0:	55                   	push   %ebp
80102bf1:	89 e5                	mov    %esp,%ebp
80102bf3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf9:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bfe:	85 c0                	test   %eax,%eax
80102c00:	75 18                	jne    80102c1a <kfree+0x2a>
80102c02:	81 7d 08 00 c0 11 80 	cmpl   $0x8011c000,0x8(%ebp)
80102c09:	72 0f                	jb     80102c1a <kfree+0x2a>
80102c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0e:	05 00 00 00 80       	add    $0x80000000,%eax
80102c13:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102c18:	76 0d                	jbe    80102c27 <kfree+0x37>
    panic("kfree");
80102c1a:	83 ec 0c             	sub    $0xc,%esp
80102c1d:	68 8f a8 10 80       	push   $0x8010a88f
80102c22:	e8 82 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c27:	83 ec 04             	sub    $0x4,%esp
80102c2a:	68 00 10 00 00       	push   $0x1000
80102c2f:	6a 01                	push   $0x1
80102c31:	ff 75 08             	push   0x8(%ebp)
80102c34:	e8 71 24 00 00       	call   801050aa <memset>
80102c39:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c3c:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c41:	85 c0                	test   %eax,%eax
80102c43:	74 10                	je     80102c55 <kfree+0x65>
    acquire(&kmem.lock);
80102c45:	83 ec 0c             	sub    $0xc,%esp
80102c48:	68 00 71 11 80       	push   $0x80117100
80102c4d:	e8 e2 21 00 00       	call   80104e34 <acquire>
80102c52:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c55:	8b 45 08             	mov    0x8(%ebp),%eax
80102c58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c5b:	8b 15 38 71 11 80    	mov    0x80117138,%edx
80102c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c64:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c69:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102c6e:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c73:	85 c0                	test   %eax,%eax
80102c75:	74 10                	je     80102c87 <kfree+0x97>
    release(&kmem.lock);
80102c77:	83 ec 0c             	sub    $0xc,%esp
80102c7a:	68 00 71 11 80       	push   $0x80117100
80102c7f:	e8 1e 22 00 00       	call   80104ea2 <release>
80102c84:	83 c4 10             	add    $0x10,%esp
}
80102c87:	90                   	nop
80102c88:	c9                   	leave
80102c89:	c3                   	ret

80102c8a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c8a:	55                   	push   %ebp
80102c8b:	89 e5                	mov    %esp,%ebp
80102c8d:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c90:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c95:	85 c0                	test   %eax,%eax
80102c97:	74 10                	je     80102ca9 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c99:	83 ec 0c             	sub    $0xc,%esp
80102c9c:	68 00 71 11 80       	push   $0x80117100
80102ca1:	e8 8e 21 00 00       	call   80104e34 <acquire>
80102ca6:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca9:	a1 38 71 11 80       	mov    0x80117138,%eax
80102cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cb5:	74 0a                	je     80102cc1 <kalloc+0x37>
    kmem.freelist = r->next;
80102cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cba:	8b 00                	mov    (%eax),%eax
80102cbc:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102cc1:	a1 34 71 11 80       	mov    0x80117134,%eax
80102cc6:	85 c0                	test   %eax,%eax
80102cc8:	74 10                	je     80102cda <kalloc+0x50>
    release(&kmem.lock);
80102cca:	83 ec 0c             	sub    $0xc,%esp
80102ccd:	68 00 71 11 80       	push   $0x80117100
80102cd2:	e8 cb 21 00 00       	call   80104ea2 <release>
80102cd7:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cdd:	c9                   	leave
80102cde:	c3                   	ret

80102cdf <inb>:
{
80102cdf:	55                   	push   %ebp
80102ce0:	89 e5                	mov    %esp,%ebp
80102ce2:	83 ec 14             	sub    $0x14,%esp
80102ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cf0:	89 c2                	mov    %eax,%edx
80102cf2:	ec                   	in     (%dx),%al
80102cf3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cfa:	c9                   	leave
80102cfb:	c3                   	ret

80102cfc <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cfc:	55                   	push   %ebp
80102cfd:	89 e5                	mov    %esp,%ebp
80102cff:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d02:	6a 64                	push   $0x64
80102d04:	e8 d6 ff ff ff       	call   80102cdf <inb>
80102d09:	83 c4 04             	add    $0x4,%esp
80102d0c:	0f b6 c0             	movzbl %al,%eax
80102d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d15:	83 e0 01             	and    $0x1,%eax
80102d18:	85 c0                	test   %eax,%eax
80102d1a:	75 0a                	jne    80102d26 <kbdgetc+0x2a>
    return -1;
80102d1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d21:	e9 23 01 00 00       	jmp    80102e49 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d26:	6a 60                	push   $0x60
80102d28:	e8 b2 ff ff ff       	call   80102cdf <inb>
80102d2d:	83 c4 04             	add    $0x4,%esp
80102d30:	0f b6 c0             	movzbl %al,%eax
80102d33:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d36:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d3d:	75 17                	jne    80102d56 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d3f:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d44:	83 c8 40             	or     $0x40,%eax
80102d47:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d4c:	b8 00 00 00 00       	mov    $0x0,%eax
80102d51:	e9 f3 00 00 00       	jmp    80102e49 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d59:	25 80 00 00 00       	and    $0x80,%eax
80102d5e:	85 c0                	test   %eax,%eax
80102d60:	74 45                	je     80102da7 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d62:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d67:	83 e0 40             	and    $0x40,%eax
80102d6a:	85 c0                	test   %eax,%eax
80102d6c:	75 08                	jne    80102d76 <kbdgetc+0x7a>
80102d6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d71:	83 e0 7f             	and    $0x7f,%eax
80102d74:	eb 03                	jmp    80102d79 <kbdgetc+0x7d>
80102d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d79:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7f:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102d84:	0f b6 00             	movzbl (%eax),%eax
80102d87:	83 c8 40             	or     $0x40,%eax
80102d8a:	0f b6 c0             	movzbl %al,%eax
80102d8d:	f7 d0                	not    %eax
80102d8f:	89 c2                	mov    %eax,%edx
80102d91:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d96:	21 d0                	and    %edx,%eax
80102d98:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d9d:	b8 00 00 00 00       	mov    $0x0,%eax
80102da2:	e9 a2 00 00 00       	jmp    80102e49 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102da7:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dac:	83 e0 40             	and    $0x40,%eax
80102daf:	85 c0                	test   %eax,%eax
80102db1:	74 14                	je     80102dc7 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102db3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dba:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dbf:	83 e0 bf             	and    $0xffffffbf,%eax
80102dc2:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  }

  shift |= shiftcode[data];
80102dc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dca:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102dcf:	0f b6 00             	movzbl (%eax),%eax
80102dd2:	0f b6 d0             	movzbl %al,%edx
80102dd5:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dda:	09 d0                	or     %edx,%eax
80102ddc:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  shift ^= togglecode[data];
80102de1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de4:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102de9:	0f b6 00             	movzbl (%eax),%eax
80102dec:	0f b6 d0             	movzbl %al,%edx
80102def:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102df4:	31 d0                	xor    %edx,%eax
80102df6:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dfb:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e00:	83 e0 03             	and    $0x3,%eax
80102e03:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102e0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0d:	01 d0                	add    %edx,%eax
80102e0f:	0f b6 00             	movzbl (%eax),%eax
80102e12:	0f b6 c0             	movzbl %al,%eax
80102e15:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e18:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e1d:	83 e0 08             	and    $0x8,%eax
80102e20:	85 c0                	test   %eax,%eax
80102e22:	74 22                	je     80102e46 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e24:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e28:	76 0c                	jbe    80102e36 <kbdgetc+0x13a>
80102e2a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e2e:	77 06                	ja     80102e36 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e30:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e34:	eb 10                	jmp    80102e46 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e36:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e3a:	76 0a                	jbe    80102e46 <kbdgetc+0x14a>
80102e3c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e40:	77 04                	ja     80102e46 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e42:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e46:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e49:	c9                   	leave
80102e4a:	c3                   	ret

80102e4b <kbdintr>:

void
kbdintr(void)
{
80102e4b:	55                   	push   %ebp
80102e4c:	89 e5                	mov    %esp,%ebp
80102e4e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e51:	83 ec 0c             	sub    $0xc,%esp
80102e54:	68 fc 2c 10 80       	push   $0x80102cfc
80102e59:	e8 78 d9 ff ff       	call   801007d6 <consoleintr>
80102e5e:	83 c4 10             	add    $0x10,%esp
}
80102e61:	90                   	nop
80102e62:	c9                   	leave
80102e63:	c3                   	ret

80102e64 <inb>:
{
80102e64:	55                   	push   %ebp
80102e65:	89 e5                	mov    %esp,%ebp
80102e67:	83 ec 14             	sub    $0x14,%esp
80102e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e71:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e75:	89 c2                	mov    %eax,%edx
80102e77:	ec                   	in     (%dx),%al
80102e78:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e7b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e7f:	c9                   	leave
80102e80:	c3                   	ret

80102e81 <outb>:
{
80102e81:	55                   	push   %ebp
80102e82:	89 e5                	mov    %esp,%ebp
80102e84:	83 ec 08             	sub    $0x8,%esp
80102e87:	8b 55 08             	mov    0x8(%ebp),%edx
80102e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e8d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e91:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e94:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e98:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e9c:	ee                   	out    %al,(%dx)
}
80102e9d:	90                   	nop
80102e9e:	c9                   	leave
80102e9f:	c3                   	ret

80102ea0 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ea0:	55                   	push   %ebp
80102ea1:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ea3:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ea8:	8b 55 08             	mov    0x8(%ebp),%edx
80102eab:	c1 e2 02             	shl    $0x2,%edx
80102eae:	01 c2                	add    %eax,%edx
80102eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb3:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb5:	a1 40 71 11 80       	mov    0x80117140,%eax
80102eba:	83 c0 20             	add    $0x20,%eax
80102ebd:	8b 00                	mov    (%eax),%eax
}
80102ebf:	90                   	nop
80102ec0:	5d                   	pop    %ebp
80102ec1:	c3                   	ret

80102ec2 <lapicinit>:

void
lapicinit(void)
{
80102ec2:	55                   	push   %ebp
80102ec3:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ec5:	a1 40 71 11 80       	mov    0x80117140,%eax
80102eca:	85 c0                	test   %eax,%eax
80102ecc:	0f 84 09 01 00 00    	je     80102fdb <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ed2:	68 3f 01 00 00       	push   $0x13f
80102ed7:	6a 3c                	push   $0x3c
80102ed9:	e8 c2 ff ff ff       	call   80102ea0 <lapicw>
80102ede:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ee1:	6a 0b                	push   $0xb
80102ee3:	68 f8 00 00 00       	push   $0xf8
80102ee8:	e8 b3 ff ff ff       	call   80102ea0 <lapicw>
80102eed:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ef0:	68 20 00 02 00       	push   $0x20020
80102ef5:	68 c8 00 00 00       	push   $0xc8
80102efa:	e8 a1 ff ff ff       	call   80102ea0 <lapicw>
80102eff:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f02:	68 80 96 98 00       	push   $0x989680
80102f07:	68 e0 00 00 00       	push   $0xe0
80102f0c:	e8 8f ff ff ff       	call   80102ea0 <lapicw>
80102f11:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f14:	68 00 00 01 00       	push   $0x10000
80102f19:	68 d4 00 00 00       	push   $0xd4
80102f1e:	e8 7d ff ff ff       	call   80102ea0 <lapicw>
80102f23:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f26:	68 00 00 01 00       	push   $0x10000
80102f2b:	68 d8 00 00 00       	push   $0xd8
80102f30:	e8 6b ff ff ff       	call   80102ea0 <lapicw>
80102f35:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f38:	a1 40 71 11 80       	mov    0x80117140,%eax
80102f3d:	83 c0 30             	add    $0x30,%eax
80102f40:	8b 00                	mov    (%eax),%eax
80102f42:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102f47:	85 c0                	test   %eax,%eax
80102f49:	74 12                	je     80102f5d <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102f4b:	68 00 00 01 00       	push   $0x10000
80102f50:	68 d0 00 00 00       	push   $0xd0
80102f55:	e8 46 ff ff ff       	call   80102ea0 <lapicw>
80102f5a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f5d:	6a 33                	push   $0x33
80102f5f:	68 dc 00 00 00       	push   $0xdc
80102f64:	e8 37 ff ff ff       	call   80102ea0 <lapicw>
80102f69:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f6c:	6a 00                	push   $0x0
80102f6e:	68 a0 00 00 00       	push   $0xa0
80102f73:	e8 28 ff ff ff       	call   80102ea0 <lapicw>
80102f78:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7b:	6a 00                	push   $0x0
80102f7d:	68 a0 00 00 00       	push   $0xa0
80102f82:	e8 19 ff ff ff       	call   80102ea0 <lapicw>
80102f87:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f8a:	6a 00                	push   $0x0
80102f8c:	6a 2c                	push   $0x2c
80102f8e:	e8 0d ff ff ff       	call   80102ea0 <lapicw>
80102f93:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f96:	6a 00                	push   $0x0
80102f98:	68 c4 00 00 00       	push   $0xc4
80102f9d:	e8 fe fe ff ff       	call   80102ea0 <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa5:	68 00 85 08 00       	push   $0x88500
80102faa:	68 c0 00 00 00       	push   $0xc0
80102faf:	e8 ec fe ff ff       	call   80102ea0 <lapicw>
80102fb4:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb7:	90                   	nop
80102fb8:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fbd:	05 00 03 00 00       	add    $0x300,%eax
80102fc2:	8b 00                	mov    (%eax),%eax
80102fc4:	25 00 10 00 00       	and    $0x1000,%eax
80102fc9:	85 c0                	test   %eax,%eax
80102fcb:	75 eb                	jne    80102fb8 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fcd:	6a 00                	push   $0x0
80102fcf:	6a 20                	push   $0x20
80102fd1:	e8 ca fe ff ff       	call   80102ea0 <lapicw>
80102fd6:	83 c4 08             	add    $0x8,%esp
80102fd9:	eb 01                	jmp    80102fdc <lapicinit+0x11a>
    return;
80102fdb:	90                   	nop
}
80102fdc:	c9                   	leave
80102fdd:	c3                   	ret

80102fde <lapicid>:

int
lapicid(void)
{
80102fde:	55                   	push   %ebp
80102fdf:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102fe1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fe6:	85 c0                	test   %eax,%eax
80102fe8:	75 07                	jne    80102ff1 <lapicid+0x13>
    return 0;
80102fea:	b8 00 00 00 00       	mov    $0x0,%eax
80102fef:	eb 0d                	jmp    80102ffe <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102ff1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ff6:	83 c0 20             	add    $0x20,%eax
80102ff9:	8b 00                	mov    (%eax),%eax
80102ffb:	c1 e8 18             	shr    $0x18,%eax
}
80102ffe:	5d                   	pop    %ebp
80102fff:	c3                   	ret

80103000 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103003:	a1 40 71 11 80       	mov    0x80117140,%eax
80103008:	85 c0                	test   %eax,%eax
8010300a:	74 0c                	je     80103018 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010300c:	6a 00                	push   $0x0
8010300e:	6a 2c                	push   $0x2c
80103010:	e8 8b fe ff ff       	call   80102ea0 <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp
}
80103018:	90                   	nop
80103019:	c9                   	leave
8010301a:	c3                   	ret

8010301b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
}
8010301e:	90                   	nop
8010301f:	5d                   	pop    %ebp
80103020:	c3                   	ret

80103021 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103021:	55                   	push   %ebp
80103022:	89 e5                	mov    %esp,%ebp
80103024:	83 ec 14             	sub    $0x14,%esp
80103027:	8b 45 08             	mov    0x8(%ebp),%eax
8010302a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010302d:	6a 0f                	push   $0xf
8010302f:	6a 70                	push   $0x70
80103031:	e8 4b fe ff ff       	call   80102e81 <outb>
80103036:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103039:	6a 0a                	push   $0xa
8010303b:	6a 71                	push   $0x71
8010303d:	e8 3f fe ff ff       	call   80102e81 <outb>
80103042:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103045:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010304c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010304f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103054:	8b 45 0c             	mov    0xc(%ebp),%eax
80103057:	c1 e8 04             	shr    $0x4,%eax
8010305a:	89 c2                	mov    %eax,%edx
8010305c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010305f:	83 c0 02             	add    $0x2,%eax
80103062:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103065:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103069:	c1 e0 18             	shl    $0x18,%eax
8010306c:	50                   	push   %eax
8010306d:	68 c4 00 00 00       	push   $0xc4
80103072:	e8 29 fe ff ff       	call   80102ea0 <lapicw>
80103077:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010307a:	68 00 c5 00 00       	push   $0xc500
8010307f:	68 c0 00 00 00       	push   $0xc0
80103084:	e8 17 fe ff ff       	call   80102ea0 <lapicw>
80103089:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010308c:	68 c8 00 00 00       	push   $0xc8
80103091:	e8 85 ff ff ff       	call   8010301b <microdelay>
80103096:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103099:	68 00 85 00 00       	push   $0x8500
8010309e:	68 c0 00 00 00       	push   $0xc0
801030a3:	e8 f8 fd ff ff       	call   80102ea0 <lapicw>
801030a8:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ab:	6a 64                	push   $0x64
801030ad:	e8 69 ff ff ff       	call   8010301b <microdelay>
801030b2:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030bc:	eb 3d                	jmp    801030fb <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030be:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030c2:	c1 e0 18             	shl    $0x18,%eax
801030c5:	50                   	push   %eax
801030c6:	68 c4 00 00 00       	push   $0xc4
801030cb:	e8 d0 fd ff ff       	call   80102ea0 <lapicw>
801030d0:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801030d6:	c1 e8 0c             	shr    $0xc,%eax
801030d9:	80 cc 06             	or     $0x6,%ah
801030dc:	50                   	push   %eax
801030dd:	68 c0 00 00 00       	push   $0xc0
801030e2:	e8 b9 fd ff ff       	call   80102ea0 <lapicw>
801030e7:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030ea:	68 c8 00 00 00       	push   $0xc8
801030ef:	e8 27 ff ff ff       	call   8010301b <microdelay>
801030f4:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801030f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030fb:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030ff:	7e bd                	jle    801030be <lapicstartap+0x9d>
  }
}
80103101:	90                   	nop
80103102:	90                   	nop
80103103:	c9                   	leave
80103104:	c3                   	ret

80103105 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103108:	8b 45 08             	mov    0x8(%ebp),%eax
8010310b:	0f b6 c0             	movzbl %al,%eax
8010310e:	50                   	push   %eax
8010310f:	6a 70                	push   $0x70
80103111:	e8 6b fd ff ff       	call   80102e81 <outb>
80103116:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103119:	68 c8 00 00 00       	push   $0xc8
8010311e:	e8 f8 fe ff ff       	call   8010301b <microdelay>
80103123:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103126:	6a 71                	push   $0x71
80103128:	e8 37 fd ff ff       	call   80102e64 <inb>
8010312d:	83 c4 04             	add    $0x4,%esp
80103130:	0f b6 c0             	movzbl %al,%eax
}
80103133:	c9                   	leave
80103134:	c3                   	ret

80103135 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103138:	6a 00                	push   $0x0
8010313a:	e8 c6 ff ff ff       	call   80103105 <cmos_read>
8010313f:	83 c4 04             	add    $0x4,%esp
80103142:	8b 55 08             	mov    0x8(%ebp),%edx
80103145:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103147:	6a 02                	push   $0x2
80103149:	e8 b7 ff ff ff       	call   80103105 <cmos_read>
8010314e:	83 c4 04             	add    $0x4,%esp
80103151:	8b 55 08             	mov    0x8(%ebp),%edx
80103154:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103157:	6a 04                	push   $0x4
80103159:	e8 a7 ff ff ff       	call   80103105 <cmos_read>
8010315e:	83 c4 04             	add    $0x4,%esp
80103161:	8b 55 08             	mov    0x8(%ebp),%edx
80103164:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103167:	6a 07                	push   $0x7
80103169:	e8 97 ff ff ff       	call   80103105 <cmos_read>
8010316e:	83 c4 04             	add    $0x4,%esp
80103171:	8b 55 08             	mov    0x8(%ebp),%edx
80103174:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103177:	6a 08                	push   $0x8
80103179:	e8 87 ff ff ff       	call   80103105 <cmos_read>
8010317e:	83 c4 04             	add    $0x4,%esp
80103181:	8b 55 08             	mov    0x8(%ebp),%edx
80103184:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103187:	6a 09                	push   $0x9
80103189:	e8 77 ff ff ff       	call   80103105 <cmos_read>
8010318e:	83 c4 04             	add    $0x4,%esp
80103191:	8b 55 08             	mov    0x8(%ebp),%edx
80103194:	89 42 14             	mov    %eax,0x14(%edx)
}
80103197:	90                   	nop
80103198:	c9                   	leave
80103199:	c3                   	ret

8010319a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010319a:	55                   	push   %ebp
8010319b:	89 e5                	mov    %esp,%ebp
8010319d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031a0:	6a 0b                	push   $0xb
801031a2:	e8 5e ff ff ff       	call   80103105 <cmos_read>
801031a7:	83 c4 04             	add    $0x4,%esp
801031aa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b0:	83 e0 04             	and    $0x4,%eax
801031b3:	85 c0                	test   %eax,%eax
801031b5:	0f 94 c0             	sete   %al
801031b8:	0f b6 c0             	movzbl %al,%eax
801031bb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c1:	50                   	push   %eax
801031c2:	e8 6e ff ff ff       	call   80103135 <fill_rtcdate>
801031c7:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031ca:	6a 0a                	push   $0xa
801031cc:	e8 34 ff ff ff       	call   80103105 <cmos_read>
801031d1:	83 c4 04             	add    $0x4,%esp
801031d4:	25 80 00 00 00       	and    $0x80,%eax
801031d9:	85 c0                	test   %eax,%eax
801031db:	75 27                	jne    80103204 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031dd:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e0:	50                   	push   %eax
801031e1:	e8 4f ff ff ff       	call   80103135 <fill_rtcdate>
801031e6:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031e9:	83 ec 04             	sub    $0x4,%esp
801031ec:	6a 18                	push   $0x18
801031ee:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f1:	50                   	push   %eax
801031f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f5:	50                   	push   %eax
801031f6:	e8 16 1f 00 00       	call   80105111 <memcmp>
801031fb:	83 c4 10             	add    $0x10,%esp
801031fe:	85 c0                	test   %eax,%eax
80103200:	74 05                	je     80103207 <cmostime+0x6d>
80103202:	eb ba                	jmp    801031be <cmostime+0x24>
        continue;
80103204:	90                   	nop
    fill_rtcdate(&t1);
80103205:	eb b7                	jmp    801031be <cmostime+0x24>
      break;
80103207:	90                   	nop
  }

  // convert
  if(bcd) {
80103208:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010320c:	0f 84 b4 00 00 00    	je     801032c6 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103212:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103215:	c1 e8 04             	shr    $0x4,%eax
80103218:	89 c2                	mov    %eax,%edx
8010321a:	89 d0                	mov    %edx,%eax
8010321c:	c1 e0 02             	shl    $0x2,%eax
8010321f:	01 d0                	add    %edx,%eax
80103221:	01 c0                	add    %eax,%eax
80103223:	89 c2                	mov    %eax,%edx
80103225:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103228:	83 e0 0f             	and    $0xf,%eax
8010322b:	01 d0                	add    %edx,%eax
8010322d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103230:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103233:	c1 e8 04             	shr    $0x4,%eax
80103236:	89 c2                	mov    %eax,%edx
80103238:	89 d0                	mov    %edx,%eax
8010323a:	c1 e0 02             	shl    $0x2,%eax
8010323d:	01 d0                	add    %edx,%eax
8010323f:	01 c0                	add    %eax,%eax
80103241:	89 c2                	mov    %eax,%edx
80103243:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103246:	83 e0 0f             	and    $0xf,%eax
80103249:	01 d0                	add    %edx,%eax
8010324b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010324e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103251:	c1 e8 04             	shr    $0x4,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	89 d0                	mov    %edx,%eax
80103258:	c1 e0 02             	shl    $0x2,%eax
8010325b:	01 d0                	add    %edx,%eax
8010325d:	01 c0                	add    %eax,%eax
8010325f:	89 c2                	mov    %eax,%edx
80103261:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103264:	83 e0 0f             	and    $0xf,%eax
80103267:	01 d0                	add    %edx,%eax
80103269:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010326c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010326f:	c1 e8 04             	shr    $0x4,%eax
80103272:	89 c2                	mov    %eax,%edx
80103274:	89 d0                	mov    %edx,%eax
80103276:	c1 e0 02             	shl    $0x2,%eax
80103279:	01 d0                	add    %edx,%eax
8010327b:	01 c0                	add    %eax,%eax
8010327d:	89 c2                	mov    %eax,%edx
8010327f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103282:	83 e0 0f             	and    $0xf,%eax
80103285:	01 d0                	add    %edx,%eax
80103287:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010328a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010328d:	c1 e8 04             	shr    $0x4,%eax
80103290:	89 c2                	mov    %eax,%edx
80103292:	89 d0                	mov    %edx,%eax
80103294:	c1 e0 02             	shl    $0x2,%eax
80103297:	01 d0                	add    %edx,%eax
80103299:	01 c0                	add    %eax,%eax
8010329b:	89 c2                	mov    %eax,%edx
8010329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a0:	83 e0 0f             	and    $0xf,%eax
801032a3:	01 d0                	add    %edx,%eax
801032a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ab:	c1 e8 04             	shr    $0x4,%eax
801032ae:	89 c2                	mov    %eax,%edx
801032b0:	89 d0                	mov    %edx,%eax
801032b2:	c1 e0 02             	shl    $0x2,%eax
801032b5:	01 d0                	add    %edx,%eax
801032b7:	01 c0                	add    %eax,%eax
801032b9:	89 c2                	mov    %eax,%edx
801032bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032be:	83 e0 0f             	and    $0xf,%eax
801032c1:	01 d0                	add    %edx,%eax
801032c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032c6:	8b 45 08             	mov    0x8(%ebp),%eax
801032c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032cc:	89 10                	mov    %edx,(%eax)
801032ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032d1:	89 50 04             	mov    %edx,0x4(%eax)
801032d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032d7:	89 50 08             	mov    %edx,0x8(%eax)
801032da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032dd:	89 50 0c             	mov    %edx,0xc(%eax)
801032e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032e3:	89 50 10             	mov    %edx,0x10(%eax)
801032e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032e9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ec:	8b 45 08             	mov    0x8(%ebp),%eax
801032ef:	8b 40 14             	mov    0x14(%eax),%eax
801032f2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032f8:	8b 45 08             	mov    0x8(%ebp),%eax
801032fb:	89 50 14             	mov    %edx,0x14(%eax)
}
801032fe:	90                   	nop
801032ff:	c9                   	leave
80103300:	c3                   	ret

80103301 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103301:	55                   	push   %ebp
80103302:	89 e5                	mov    %esp,%ebp
80103304:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103307:	83 ec 08             	sub    $0x8,%esp
8010330a:	68 95 a8 10 80       	push   $0x8010a895
8010330f:	68 60 71 11 80       	push   $0x80117160
80103314:	e8 f9 1a 00 00       	call   80104e12 <initlock>
80103319:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010331c:	83 ec 08             	sub    $0x8,%esp
8010331f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103322:	50                   	push   %eax
80103323:	ff 75 08             	push   0x8(%ebp)
80103326:	e8 ad e0 ff ff       	call   801013d8 <readsb>
8010332b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010332e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103331:	a3 94 71 11 80       	mov    %eax,0x80117194
  log.size = sb.nlog;
80103336:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103339:	a3 98 71 11 80       	mov    %eax,0x80117198
  log.dev = dev;
8010333e:	8b 45 08             	mov    0x8(%ebp),%eax
80103341:	a3 a4 71 11 80       	mov    %eax,0x801171a4
  recover_from_log();
80103346:	e8 b3 01 00 00       	call   801034fe <recover_from_log>
}
8010334b:	90                   	nop
8010334c:	c9                   	leave
8010334d:	c3                   	ret

8010334e <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010334e:	55                   	push   %ebp
8010334f:	89 e5                	mov    %esp,%ebp
80103351:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103354:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010335b:	e9 95 00 00 00       	jmp    801033f5 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103360:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103369:	01 d0                	add    %edx,%eax
8010336b:	83 c0 01             	add    $0x1,%eax
8010336e:	89 c2                	mov    %eax,%edx
80103370:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103375:	83 ec 08             	sub    $0x8,%esp
80103378:	52                   	push   %edx
80103379:	50                   	push   %eax
8010337a:	e8 82 ce ff ff       	call   80100201 <bread>
8010337f:	83 c4 10             	add    $0x10,%esp
80103382:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103388:	83 c0 10             	add    $0x10,%eax
8010338b:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
80103392:	89 c2                	mov    %eax,%edx
80103394:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103399:	83 ec 08             	sub    $0x8,%esp
8010339c:	52                   	push   %edx
8010339d:	50                   	push   %eax
8010339e:	e8 5e ce ff ff       	call   80100201 <bread>
801033a3:	83 c4 10             	add    $0x10,%esp
801033a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ac:	8d 50 5c             	lea    0x5c(%eax),%edx
801033af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b2:	83 c0 5c             	add    $0x5c,%eax
801033b5:	83 ec 04             	sub    $0x4,%esp
801033b8:	68 00 02 00 00       	push   $0x200
801033bd:	52                   	push   %edx
801033be:	50                   	push   %eax
801033bf:	e8 a5 1d 00 00       	call   80105169 <memmove>
801033c4:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033c7:	83 ec 0c             	sub    $0xc,%esp
801033ca:	ff 75 ec             	push   -0x14(%ebp)
801033cd:	e8 68 ce ff ff       	call   8010023a <bwrite>
801033d2:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033d5:	83 ec 0c             	sub    $0xc,%esp
801033d8:	ff 75 f0             	push   -0x10(%ebp)
801033db:	e8 a3 ce ff ff       	call   80100283 <brelse>
801033e0:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033e3:	83 ec 0c             	sub    $0xc,%esp
801033e6:	ff 75 ec             	push   -0x14(%ebp)
801033e9:	e8 95 ce ff ff       	call   80100283 <brelse>
801033ee:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033f5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801033fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033fd:	0f 8c 5d ff ff ff    	jl     80103360 <install_trans+0x12>
  }
}
80103403:	90                   	nop
80103404:	90                   	nop
80103405:	c9                   	leave
80103406:	c3                   	ret

80103407 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103407:	55                   	push   %ebp
80103408:	89 e5                	mov    %esp,%ebp
8010340a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010340d:	a1 94 71 11 80       	mov    0x80117194,%eax
80103412:	89 c2                	mov    %eax,%edx
80103414:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103419:	83 ec 08             	sub    $0x8,%esp
8010341c:	52                   	push   %edx
8010341d:	50                   	push   %eax
8010341e:	e8 de cd ff ff       	call   80100201 <bread>
80103423:	83 c4 10             	add    $0x10,%esp
80103426:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342c:	83 c0 5c             	add    $0x5c,%eax
8010342f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103432:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103435:	8b 00                	mov    (%eax),%eax
80103437:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  for (i = 0; i < log.lh.n; i++) {
8010343c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103443:	eb 1b                	jmp    80103460 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103445:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010344b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010344f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103452:	83 c2 10             	add    $0x10,%edx
80103455:	89 04 95 6c 71 11 80 	mov    %eax,-0x7fee8e94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010345c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103460:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103465:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103468:	7c db                	jl     80103445 <read_head+0x3e>
  }
  brelse(buf);
8010346a:	83 ec 0c             	sub    $0xc,%esp
8010346d:	ff 75 f0             	push   -0x10(%ebp)
80103470:	e8 0e ce ff ff       	call   80100283 <brelse>
80103475:	83 c4 10             	add    $0x10,%esp
}
80103478:	90                   	nop
80103479:	c9                   	leave
8010347a:	c3                   	ret

8010347b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010347b:	55                   	push   %ebp
8010347c:	89 e5                	mov    %esp,%ebp
8010347e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103481:	a1 94 71 11 80       	mov    0x80117194,%eax
80103486:	89 c2                	mov    %eax,%edx
80103488:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010348d:	83 ec 08             	sub    $0x8,%esp
80103490:	52                   	push   %edx
80103491:	50                   	push   %eax
80103492:	e8 6a cd ff ff       	call   80100201 <bread>
80103497:	83 c4 10             	add    $0x10,%esp
8010349a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010349d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a0:	83 c0 5c             	add    $0x5c,%eax
801034a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034a6:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
801034ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034af:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034b8:	eb 1b                	jmp    801034d5 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034bd:	83 c0 10             	add    $0x10,%eax
801034c0:	8b 0c 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%ecx
801034c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034cd:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801034da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034dd:	7c db                	jl     801034ba <write_head+0x3f>
  }
  bwrite(buf);
801034df:	83 ec 0c             	sub    $0xc,%esp
801034e2:	ff 75 f0             	push   -0x10(%ebp)
801034e5:	e8 50 cd ff ff       	call   8010023a <bwrite>
801034ea:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ed:	83 ec 0c             	sub    $0xc,%esp
801034f0:	ff 75 f0             	push   -0x10(%ebp)
801034f3:	e8 8b cd ff ff       	call   80100283 <brelse>
801034f8:	83 c4 10             	add    $0x10,%esp
}
801034fb:	90                   	nop
801034fc:	c9                   	leave
801034fd:	c3                   	ret

801034fe <recover_from_log>:

static void
recover_from_log(void)
{
801034fe:	55                   	push   %ebp
801034ff:	89 e5                	mov    %esp,%ebp
80103501:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103504:	e8 fe fe ff ff       	call   80103407 <read_head>
  install_trans(); // if committed, copy from log to disk
80103509:	e8 40 fe ff ff       	call   8010334e <install_trans>
  log.lh.n = 0;
8010350e:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
80103515:	00 00 00 
  write_head(); // clear the log
80103518:	e8 5e ff ff ff       	call   8010347b <write_head>
}
8010351d:	90                   	nop
8010351e:	c9                   	leave
8010351f:	c3                   	ret

80103520 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103526:	83 ec 0c             	sub    $0xc,%esp
80103529:	68 60 71 11 80       	push   $0x80117160
8010352e:	e8 01 19 00 00       	call   80104e34 <acquire>
80103533:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103536:	a1 a0 71 11 80       	mov    0x801171a0,%eax
8010353b:	85 c0                	test   %eax,%eax
8010353d:	74 17                	je     80103556 <begin_op+0x36>
      sleep(&log, &log.lock);
8010353f:	83 ec 08             	sub    $0x8,%esp
80103542:	68 60 71 11 80       	push   $0x80117160
80103547:	68 60 71 11 80       	push   $0x80117160
8010354c:	e8 6a 12 00 00       	call   801047bb <sleep>
80103551:	83 c4 10             	add    $0x10,%esp
80103554:	eb e0                	jmp    80103536 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103556:	8b 0d a8 71 11 80    	mov    0x801171a8,%ecx
8010355c:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103561:	8d 50 01             	lea    0x1(%eax),%edx
80103564:	89 d0                	mov    %edx,%eax
80103566:	c1 e0 02             	shl    $0x2,%eax
80103569:	01 d0                	add    %edx,%eax
8010356b:	01 c0                	add    %eax,%eax
8010356d:	01 c8                	add    %ecx,%eax
8010356f:	83 f8 1e             	cmp    $0x1e,%eax
80103572:	7e 17                	jle    8010358b <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103574:	83 ec 08             	sub    $0x8,%esp
80103577:	68 60 71 11 80       	push   $0x80117160
8010357c:	68 60 71 11 80       	push   $0x80117160
80103581:	e8 35 12 00 00       	call   801047bb <sleep>
80103586:	83 c4 10             	add    $0x10,%esp
80103589:	eb ab                	jmp    80103536 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010358b:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103590:	83 c0 01             	add    $0x1,%eax
80103593:	a3 9c 71 11 80       	mov    %eax,0x8011719c
      release(&log.lock);
80103598:	83 ec 0c             	sub    $0xc,%esp
8010359b:	68 60 71 11 80       	push   $0x80117160
801035a0:	e8 fd 18 00 00       	call   80104ea2 <release>
801035a5:	83 c4 10             	add    $0x10,%esp
      break;
801035a8:	90                   	nop
    }
  }
}
801035a9:	90                   	nop
801035aa:	c9                   	leave
801035ab:	c3                   	ret

801035ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035ac:	55                   	push   %ebp
801035ad:	89 e5                	mov    %esp,%ebp
801035af:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035b9:	83 ec 0c             	sub    $0xc,%esp
801035bc:	68 60 71 11 80       	push   $0x80117160
801035c1:	e8 6e 18 00 00       	call   80104e34 <acquire>
801035c6:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035c9:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035ce:	83 e8 01             	sub    $0x1,%eax
801035d1:	a3 9c 71 11 80       	mov    %eax,0x8011719c
  if(log.committing)
801035d6:	a1 a0 71 11 80       	mov    0x801171a0,%eax
801035db:	85 c0                	test   %eax,%eax
801035dd:	74 0d                	je     801035ec <end_op+0x40>
    panic("log.committing");
801035df:	83 ec 0c             	sub    $0xc,%esp
801035e2:	68 99 a8 10 80       	push   $0x8010a899
801035e7:	e8 bd cf ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801035ec:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035f1:	85 c0                	test   %eax,%eax
801035f3:	75 13                	jne    80103608 <end_op+0x5c>
    do_commit = 1;
801035f5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035fc:	c7 05 a0 71 11 80 01 	movl   $0x1,0x801171a0
80103603:	00 00 00 
80103606:	eb 10                	jmp    80103618 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103608:	83 ec 0c             	sub    $0xc,%esp
8010360b:	68 60 71 11 80       	push   $0x80117160
80103610:	e8 8d 12 00 00       	call   801048a2 <wakeup>
80103615:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103618:	83 ec 0c             	sub    $0xc,%esp
8010361b:	68 60 71 11 80       	push   $0x80117160
80103620:	e8 7d 18 00 00       	call   80104ea2 <release>
80103625:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103628:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010362c:	74 3f                	je     8010366d <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010362e:	e8 f6 00 00 00       	call   80103729 <commit>
    acquire(&log.lock);
80103633:	83 ec 0c             	sub    $0xc,%esp
80103636:	68 60 71 11 80       	push   $0x80117160
8010363b:	e8 f4 17 00 00       	call   80104e34 <acquire>
80103640:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103643:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364a:	00 00 00 
    wakeup(&log);
8010364d:	83 ec 0c             	sub    $0xc,%esp
80103650:	68 60 71 11 80       	push   $0x80117160
80103655:	e8 48 12 00 00       	call   801048a2 <wakeup>
8010365a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	68 60 71 11 80       	push   $0x80117160
80103665:	e8 38 18 00 00       	call   80104ea2 <release>
8010366a:	83 c4 10             	add    $0x10,%esp
  }
}
8010366d:	90                   	nop
8010366e:	c9                   	leave
8010366f:	c3                   	ret

80103670 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103670:	55                   	push   %ebp
80103671:	89 e5                	mov    %esp,%ebp
80103673:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367d:	e9 95 00 00 00       	jmp    80103717 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103682:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368b:	01 d0                	add    %edx,%eax
8010368d:	83 c0 01             	add    $0x1,%eax
80103690:	89 c2                	mov    %eax,%edx
80103692:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103697:	83 ec 08             	sub    $0x8,%esp
8010369a:	52                   	push   %edx
8010369b:	50                   	push   %eax
8010369c:	e8 60 cb ff ff       	call   80100201 <bread>
801036a1:	83 c4 10             	add    $0x10,%esp
801036a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036aa:	83 c0 10             	add    $0x10,%eax
801036ad:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801036b4:	89 c2                	mov    %eax,%edx
801036b6:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036bb:	83 ec 08             	sub    $0x8,%esp
801036be:	52                   	push   %edx
801036bf:	50                   	push   %eax
801036c0:	e8 3c cb ff ff       	call   80100201 <bread>
801036c5:	83 c4 10             	add    $0x10,%esp
801036c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ce:	8d 50 5c             	lea    0x5c(%eax),%edx
801036d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d4:	83 c0 5c             	add    $0x5c,%eax
801036d7:	83 ec 04             	sub    $0x4,%esp
801036da:	68 00 02 00 00       	push   $0x200
801036df:	52                   	push   %edx
801036e0:	50                   	push   %eax
801036e1:	e8 83 1a 00 00       	call   80105169 <memmove>
801036e6:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036e9:	83 ec 0c             	sub    $0xc,%esp
801036ec:	ff 75 f0             	push   -0x10(%ebp)
801036ef:	e8 46 cb ff ff       	call   8010023a <bwrite>
801036f4:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801036f7:	83 ec 0c             	sub    $0xc,%esp
801036fa:	ff 75 ec             	push   -0x14(%ebp)
801036fd:	e8 81 cb ff ff       	call   80100283 <brelse>
80103702:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	ff 75 f0             	push   -0x10(%ebp)
8010370b:	e8 73 cb ff ff       	call   80100283 <brelse>
80103710:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103713:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103717:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010371c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010371f:	0f 8c 5d ff ff ff    	jl     80103682 <write_log+0x12>
  }
}
80103725:	90                   	nop
80103726:	90                   	nop
80103727:	c9                   	leave
80103728:	c3                   	ret

80103729 <commit>:

static void
commit()
{
80103729:	55                   	push   %ebp
8010372a:	89 e5                	mov    %esp,%ebp
8010372c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010372f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	7e 1e                	jle    80103756 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103738:	e8 33 ff ff ff       	call   80103670 <write_log>
    write_head();    // Write header to disk -- the real commit
8010373d:	e8 39 fd ff ff       	call   8010347b <write_head>
    install_trans(); // Now install writes to home locations
80103742:	e8 07 fc ff ff       	call   8010334e <install_trans>
    log.lh.n = 0;
80103747:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
8010374e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103751:	e8 25 fd ff ff       	call   8010347b <write_head>
  }
}
80103756:	90                   	nop
80103757:	c9                   	leave
80103758:	c3                   	ret

80103759 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103759:	55                   	push   %ebp
8010375a:	89 e5                	mov    %esp,%ebp
8010375c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010375f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103764:	83 f8 1d             	cmp    $0x1d,%eax
80103767:	7f 12                	jg     8010377b <log_write+0x22>
80103769:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
8010376f:	a1 98 71 11 80       	mov    0x80117198,%eax
80103774:	83 e8 01             	sub    $0x1,%eax
80103777:	39 c2                	cmp    %eax,%edx
80103779:	7c 0d                	jl     80103788 <log_write+0x2f>
    panic("too big a transaction");
8010377b:	83 ec 0c             	sub    $0xc,%esp
8010377e:	68 a8 a8 10 80       	push   $0x8010a8a8
80103783:	e8 21 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103788:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378d:	85 c0                	test   %eax,%eax
8010378f:	7f 0d                	jg     8010379e <log_write+0x45>
    panic("log_write outside of trans");
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 be a8 10 80       	push   $0x8010a8be
80103799:	e8 0b ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 71 11 80       	push   $0x80117160
801037a6:	e8 89 16 00 00       	call   80104e34 <acquire>
801037ab:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b5:	eb 1d                	jmp    801037d4 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ba:	83 c0 10             	add    $0x10,%eax
801037bd:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801037c4:	89 c2                	mov    %eax,%edx
801037c6:	8b 45 08             	mov    0x8(%ebp),%eax
801037c9:	8b 40 08             	mov    0x8(%eax),%eax
801037cc:	39 c2                	cmp    %eax,%edx
801037ce:	74 10                	je     801037e0 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d4:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037d9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037dc:	7c d9                	jl     801037b7 <log_write+0x5e>
801037de:	eb 01                	jmp    801037e1 <log_write+0x88>
      break;
801037e0:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037e1:	8b 45 08             	mov    0x8(%ebp),%eax
801037e4:	8b 40 08             	mov    0x8(%eax),%eax
801037e7:	89 c2                	mov    %eax,%edx
801037e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ec:	83 c0 10             	add    $0x10,%eax
801037ef:	89 14 85 6c 71 11 80 	mov    %edx,-0x7fee8e94(,%eax,4)
  if (i == log.lh.n)
801037f6:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037fe:	75 0d                	jne    8010380d <log_write+0xb4>
    log.lh.n++;
80103800:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103805:	83 c0 01             	add    $0x1,%eax
80103808:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  b->flags |= B_DIRTY; // prevent eviction
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 00                	mov    (%eax),%eax
80103812:	83 c8 04             	or     $0x4,%eax
80103815:	89 c2                	mov    %eax,%edx
80103817:	8b 45 08             	mov    0x8(%ebp),%eax
8010381a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010381c:	83 ec 0c             	sub    $0xc,%esp
8010381f:	68 60 71 11 80       	push   $0x80117160
80103824:	e8 79 16 00 00       	call   80104ea2 <release>
80103829:	83 c4 10             	add    $0x10,%esp
}
8010382c:	90                   	nop
8010382d:	c9                   	leave
8010382e:	c3                   	ret

8010382f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010382f:	55                   	push   %ebp
80103830:	89 e5                	mov    %esp,%ebp
80103832:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103835:	8b 55 08             	mov    0x8(%ebp),%edx
80103838:	8b 45 0c             	mov    0xc(%ebp),%eax
8010383b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010383e:	f0 87 02             	lock xchg %eax,(%edx)
80103841:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103844:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103847:	c9                   	leave
80103848:	c3                   	ret

80103849 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103849:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010384d:	83 e4 f0             	and    $0xfffffff0,%esp
80103850:	ff 71 fc             	push   -0x4(%ecx)
80103853:	55                   	push   %ebp
80103854:	89 e5                	mov    %esp,%ebp
80103856:	51                   	push   %ecx
80103857:	83 ec 04             	sub    $0x4,%esp
  graphic_init(); // 화면 출력을 위한 그래픽 시스템
8010385a:	e8 67 4c 00 00       	call   801084c6 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator 커널이 사용할 수 있는 물리 메모리의 첫 4MB를 할당할 준비를 합니다.
8010385f:	83 ec 08             	sub    $0x8,%esp
80103862:	68 00 00 40 80       	push   $0x80400000
80103867:	68 00 c0 11 80       	push   $0x8011c000
8010386c:	e8 e4 f2 ff ff       	call   80102b55 <kinit1>
80103871:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table // 가상 메모리 주소를 물리 메모리 주소로 변환할 **커널 페이지 테이블(지도)**을 만듭니다.
80103874:	e8 6a 42 00 00       	call   80107ae3 <kvmalloc>
  mpinit_uefi(); // 다중 코어(멀티프로세서) 환경을 UEFI 방식에 맞게 파악합니다. CPU가 몇 개인지 확인하는 작업이죠.
80103879:	e8 11 4a 00 00       	call   8010828f <mpinit_uefi>
  lapicinit();     // interrupt controller 키보드나 마우스 등 외부에서 들어오는 신호(인터럽트)를 CPU가 받을 수 있도록 컨트롤러를 켭니다.
8010387e:	e8 3f f6 ff ff       	call   80102ec2 <lapicinit>
  seginit();       // segment descriptors 메모리 보호 구역(세그먼트)을 설정하고, 오류나 시스템 콜이 발생했을 때 어디로 가야 할지(트랩 벡터)를 설정합니다.
80103883:	e8 f2 3c 00 00       	call   8010757a <seginit>
  picinit();    // disable pic
80103888:	e8 9b 01 00 00       	call   80103a28 <picinit>
  ioapicinit();    // another interrupt controller 키보드나 마우스 등 외부에서 들어오는 신호(인터럽트)를 CPU가 받을 수 있도록 컨트롤러를 켭니다.
8010388d:	e8 de f1 ff ff       	call   80102a70 <ioapicinit>
  consoleinit();   // console hardware 화면에 글자를 찍고(콘솔), 시리얼 통신을 할 준비를 합니다.
80103892:	e8 72 d2 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port 화면에 글자를 찍고(콘솔), 시리얼 통신을 할 준비를 합니다.
80103897:	e8 77 30 00 00       	call   80106913 <uartinit>
  pinit();         // process table 프로세스 장부(프로세스 테이블)를 초기화합니다.
8010389c:	e8 c0 05 00 00       	call   80103e61 <pinit>
  tvinit();        // trap vectors 메모리 보호 구역(세그먼트)을 설정하고, 오류나 시스템 콜이 발생했을 때 어디로 가야 할지(트랩 벡터)를 설정합니다.
801038a1:	e8 40 2c 00 00       	call   801064e6 <tvinit>
  binit();         // buffer cache 하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
801038a6:	e8 bb c7 ff ff       	call   80100066 <binit>
  fileinit();      // file table 하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
801038ab:	e8 19 d7 ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk  하드디스크(IDE)를 읽고 쓸 준비를 하고, 파일 시스템과 버퍼를 세팅합니다.
801038b0:	e8 74 ed ff ff       	call   80102629 <ideinit>
  startothers();   // start other processors 잠들어 있는 나머지 CPU들을 깨웁니다. (자세한 건 아래 2번에서 설명할게요)
801038b5:	e8 8a 00 00 00       	call   80103944 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers() 처음 4MB 이후의 나머지 모든 물리 메모리를 운영체제가 사용할 수 있도록 마저 할당합니다.
801038ba:	83 ec 08             	sub    $0x8,%esp
801038bd:	68 00 00 00 a0       	push   $0xa0000000
801038c2:	68 00 00 40 80       	push   $0x80400000
801038c7:	e8 c2 f2 ff ff       	call   80102b8e <kinit2>
801038cc:	83 c4 10             	add    $0x10,%esp
  pci_init(); // 추가된 네트워크 및 하드웨어 장치를 스캔합니다 
801038cf:	e8 4d 4e 00 00       	call   80108721 <pci_init>
  arp_scan(); // 추가된 네트워크 및 하드웨어 장치를 스캔합니다.
801038d4:	e8 82 5b 00 00       	call   8010945b <arp_scan>
  //i8254_recv();
  userinit();      // first user process 드디어 대망의 첫 번째 유저 프로그램(보통 init 프로세스)을 메모리에 만듭니다.
801038d9:	e8 61 07 00 00       	call   8010403f <userinit>

  mpmain();        // finish this processor's setup 준비를 마치고 스케줄러를 가동하여 프로세스들을 실행하기 시작합니다.
801038de:	e8 1a 00 00 00       	call   801038fd <mpmain>

801038e3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void) // 서브 CPU들의 출근 완료 보고
{
801038e3:	55                   	push   %ebp
801038e4:	89 e5                	mov    %esp,%ebp
801038e6:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038e9:	e8 0d 42 00 00       	call   80107afb <switchkvm>
  seginit();
801038ee:	e8 87 3c 00 00       	call   8010757a <seginit>
  lapicinit();
801038f3:	e8 ca f5 ff ff       	call   80102ec2 <lapicinit>
  mpmain();
801038f8:	e8 00 00 00 00       	call   801038fd <mpmain>

801038fd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void) //서브 CPU들의 출근 완료 보고
{
801038fd:	55                   	push   %ebp
801038fe:	89 e5                	mov    %esp,%ebp
80103900:	53                   	push   %ebx
80103901:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103904:	e8 76 05 00 00       	call   80103e7f <cpuid>
80103909:	89 c3                	mov    %eax,%ebx
8010390b:	e8 6f 05 00 00       	call   80103e7f <cpuid>
80103910:	83 ec 04             	sub    $0x4,%esp
80103913:	53                   	push   %ebx
80103914:	50                   	push   %eax
80103915:	68 d9 a8 10 80       	push   $0x8010a8d9
8010391a:	e8 d5 ca ff ff       	call   801003f4 <cprintf>
8010391f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103922:	e8 35 2d 00 00       	call   8010665c <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103927:	e8 6e 05 00 00       	call   80103e9a <mycpu>
8010392c:	05 a0 00 00 00       	add    $0xa0,%eax
80103931:	83 ec 08             	sub    $0x8,%esp
80103934:	6a 01                	push   $0x1
80103936:	50                   	push   %eax
80103937:	e8 f3 fe ff ff       	call   8010382f <xchg>
8010393c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010393f:	e8 86 0c 00 00       	call   801045ca <scheduler>

80103944 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103944:	55                   	push   %ebp
80103945:	89 e5                	mov    %esp,%ebp
80103947:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394a:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103951:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103956:	83 ec 04             	sub    $0x4,%esp
80103959:	50                   	push   %eax
8010395a:	68 18 f5 10 80       	push   $0x8010f518
8010395f:	ff 75 f0             	push   -0x10(%ebp)
80103962:	e8 02 18 00 00       	call   80105169 <memmove>
80103967:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396a:	c7 45 f4 c0 9a 11 80 	movl   $0x80119ac0,-0xc(%ebp)
80103971:	eb 79                	jmp    801039ec <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103973:	e8 22 05 00 00       	call   80103e9a <mycpu>
80103978:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397b:	74 67                	je     801039e4 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010397d:	e8 08 f3 ff ff       	call   80102c8a <kalloc>
80103982:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103988:	83 e8 04             	sub    $0x4,%eax
8010398b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010398e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103994:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103999:	83 e8 08             	sub    $0x8,%eax
8010399c:	c7 00 e3 38 10 80    	movl   $0x801038e3,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a2:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801039a7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b0:	83 e8 0c             	sub    $0xc,%eax
801039b3:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c1:	0f b6 00             	movzbl (%eax),%eax
801039c4:	0f b6 c0             	movzbl %al,%eax
801039c7:	83 ec 08             	sub    $0x8,%esp
801039ca:	52                   	push   %edx
801039cb:	50                   	push   %eax
801039cc:	e8 50 f6 ff ff       	call   80103021 <lapicstartap>
801039d1:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d4:	90                   	nop
801039d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039de:	85 c0                	test   %eax,%eax
801039e0:	74 f3                	je     801039d5 <startothers+0x91>
801039e2:	eb 01                	jmp    801039e5 <startothers+0xa1>
      continue;
801039e4:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039e5:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039ec:	a1 80 9d 11 80       	mov    0x80119d80,%eax
801039f1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f7:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
801039fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039ff:	0f 82 6e ff ff ff    	jb     80103973 <startothers+0x2f>
      ;
  }
}
80103a05:	90                   	nop
80103a06:	90                   	nop
80103a07:	c9                   	leave
80103a08:	c3                   	ret

80103a09 <outb>:
{
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	83 ec 08             	sub    $0x8,%esp
80103a0f:	8b 55 08             	mov    0x8(%ebp),%edx
80103a12:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a15:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a19:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a1c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a20:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a24:	ee                   	out    %al,(%dx)
}
80103a25:	90                   	nop
80103a26:	c9                   	leave
80103a27:	c3                   	ret

80103a28 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103a28:	55                   	push   %ebp
80103a29:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a2b:	68 ff 00 00 00       	push   $0xff
80103a30:	6a 21                	push   $0x21
80103a32:	e8 d2 ff ff ff       	call   80103a09 <outb>
80103a37:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103a3a:	68 ff 00 00 00       	push   $0xff
80103a3f:	68 a1 00 00 00       	push   $0xa1
80103a44:	e8 c0 ff ff ff       	call   80103a09 <outb>
80103a49:	83 c4 08             	add    $0x8,%esp
}
80103a4c:	90                   	nop
80103a4d:	c9                   	leave
80103a4e:	c3                   	ret

80103a4f <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103a4f:	55                   	push   %ebp
80103a50:	89 e5                	mov    %esp,%ebp
80103a52:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103a55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103a65:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a68:	8b 10                	mov    (%eax),%edx
80103a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6d:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103a6f:	e8 73 d5 ff ff       	call   80100fe7 <filealloc>
80103a74:	8b 55 08             	mov    0x8(%ebp),%edx
80103a77:	89 02                	mov    %eax,(%edx)
80103a79:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7c:	8b 00                	mov    (%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	0f 84 c8 00 00 00    	je     80103b4e <pipealloc+0xff>
80103a86:	e8 5c d5 ff ff       	call   80100fe7 <filealloc>
80103a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a8e:	89 02                	mov    %eax,(%edx)
80103a90:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a93:	8b 00                	mov    (%eax),%eax
80103a95:	85 c0                	test   %eax,%eax
80103a97:	0f 84 b1 00 00 00    	je     80103b4e <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103a9d:	e8 e8 f1 ff ff       	call   80102c8a <kalloc>
80103aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aa5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103aa9:	0f 84 a2 00 00 00    	je     80103b51 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab2:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ab9:	00 00 00 
  p->writeopen = 1;
80103abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abf:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ac6:	00 00 00 
  p->nwrite = 0;
80103ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acc:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ad3:	00 00 00 
  p->nread = 0;
80103ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ae0:	00 00 00 
  initlock(&p->lock, "pipe");
80103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae6:	83 ec 08             	sub    $0x8,%esp
80103ae9:	68 ed a8 10 80       	push   $0x8010a8ed
80103aee:	50                   	push   %eax
80103aef:	e8 1e 13 00 00       	call   80104e12 <initlock>
80103af4:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103af7:	8b 45 08             	mov    0x8(%ebp),%eax
80103afa:	8b 00                	mov    (%eax),%eax
80103afc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103b02:	8b 45 08             	mov    0x8(%ebp),%eax
80103b05:	8b 00                	mov    (%eax),%eax
80103b07:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0e:	8b 00                	mov    (%eax),%eax
80103b10:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103b14:	8b 45 08             	mov    0x8(%ebp),%eax
80103b17:	8b 00                	mov    (%eax),%eax
80103b19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b1c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b22:	8b 00                	mov    (%eax),%eax
80103b24:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b2d:	8b 00                	mov    (%eax),%eax
80103b2f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103b33:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b36:	8b 00                	mov    (%eax),%eax
80103b38:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b3f:	8b 00                	mov    (%eax),%eax
80103b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b44:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103b47:	b8 00 00 00 00       	mov    $0x0,%eax
80103b4c:	eb 51                	jmp    80103b9f <pipealloc+0x150>
    goto bad;
80103b4e:	90                   	nop
80103b4f:	eb 01                	jmp    80103b52 <pipealloc+0x103>
    goto bad;
80103b51:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103b52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b56:	74 0e                	je     80103b66 <pipealloc+0x117>
    kfree((char*)p);
80103b58:	83 ec 0c             	sub    $0xc,%esp
80103b5b:	ff 75 f4             	push   -0xc(%ebp)
80103b5e:	e8 8d f0 ff ff       	call   80102bf0 <kfree>
80103b63:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103b66:	8b 45 08             	mov    0x8(%ebp),%eax
80103b69:	8b 00                	mov    (%eax),%eax
80103b6b:	85 c0                	test   %eax,%eax
80103b6d:	74 11                	je     80103b80 <pipealloc+0x131>
    fileclose(*f0);
80103b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b72:	8b 00                	mov    (%eax),%eax
80103b74:	83 ec 0c             	sub    $0xc,%esp
80103b77:	50                   	push   %eax
80103b78:	e8 28 d5 ff ff       	call   801010a5 <fileclose>
80103b7d:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103b80:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b83:	8b 00                	mov    (%eax),%eax
80103b85:	85 c0                	test   %eax,%eax
80103b87:	74 11                	je     80103b9a <pipealloc+0x14b>
    fileclose(*f1);
80103b89:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b8c:	8b 00                	mov    (%eax),%eax
80103b8e:	83 ec 0c             	sub    $0xc,%esp
80103b91:	50                   	push   %eax
80103b92:	e8 0e d5 ff ff       	call   801010a5 <fileclose>
80103b97:	83 c4 10             	add    $0x10,%esp
  return -1;
80103b9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103b9f:	c9                   	leave
80103ba0:	c3                   	ret

80103ba1 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103ba1:	55                   	push   %ebp
80103ba2:	89 e5                	mov    %esp,%ebp
80103ba4:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80103baa:	83 ec 0c             	sub    $0xc,%esp
80103bad:	50                   	push   %eax
80103bae:	e8 81 12 00 00       	call   80104e34 <acquire>
80103bb3:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103bb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103bba:	74 23                	je     80103bdf <pipeclose+0x3e>
    p->writeopen = 0;
80103bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bbf:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103bc6:	00 00 00 
    wakeup(&p->nread);
80103bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcc:	05 34 02 00 00       	add    $0x234,%eax
80103bd1:	83 ec 0c             	sub    $0xc,%esp
80103bd4:	50                   	push   %eax
80103bd5:	e8 c8 0c 00 00       	call   801048a2 <wakeup>
80103bda:	83 c4 10             	add    $0x10,%esp
80103bdd:	eb 21                	jmp    80103c00 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80103be2:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103be9:	00 00 00 
    wakeup(&p->nwrite);
80103bec:	8b 45 08             	mov    0x8(%ebp),%eax
80103bef:	05 38 02 00 00       	add    $0x238,%eax
80103bf4:	83 ec 0c             	sub    $0xc,%esp
80103bf7:	50                   	push   %eax
80103bf8:	e8 a5 0c 00 00       	call   801048a2 <wakeup>
80103bfd:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103c00:	8b 45 08             	mov    0x8(%ebp),%eax
80103c03:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c09:	85 c0                	test   %eax,%eax
80103c0b:	75 2c                	jne    80103c39 <pipeclose+0x98>
80103c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c10:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103c16:	85 c0                	test   %eax,%eax
80103c18:	75 1f                	jne    80103c39 <pipeclose+0x98>
    release(&p->lock);
80103c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1d:	83 ec 0c             	sub    $0xc,%esp
80103c20:	50                   	push   %eax
80103c21:	e8 7c 12 00 00       	call   80104ea2 <release>
80103c26:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103c29:	83 ec 0c             	sub    $0xc,%esp
80103c2c:	ff 75 08             	push   0x8(%ebp)
80103c2f:	e8 bc ef ff ff       	call   80102bf0 <kfree>
80103c34:	83 c4 10             	add    $0x10,%esp
80103c37:	eb 10                	jmp    80103c49 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103c39:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3c:	83 ec 0c             	sub    $0xc,%esp
80103c3f:	50                   	push   %eax
80103c40:	e8 5d 12 00 00       	call   80104ea2 <release>
80103c45:	83 c4 10             	add    $0x10,%esp
}
80103c48:	90                   	nop
80103c49:	90                   	nop
80103c4a:	c9                   	leave
80103c4b:	c3                   	ret

80103c4c <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103c4c:	55                   	push   %ebp
80103c4d:	89 e5                	mov    %esp,%ebp
80103c4f:	53                   	push   %ebx
80103c50:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103c53:	8b 45 08             	mov    0x8(%ebp),%eax
80103c56:	83 ec 0c             	sub    $0xc,%esp
80103c59:	50                   	push   %eax
80103c5a:	e8 d5 11 00 00       	call   80104e34 <acquire>
80103c5f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103c62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c69:	e9 ad 00 00 00       	jmp    80103d1b <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c71:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c77:	85 c0                	test   %eax,%eax
80103c79:	74 0c                	je     80103c87 <pipewrite+0x3b>
80103c7b:	e8 92 02 00 00       	call   80103f12 <myproc>
80103c80:	8b 40 24             	mov    0x24(%eax),%eax
80103c83:	85 c0                	test   %eax,%eax
80103c85:	74 19                	je     80103ca0 <pipewrite+0x54>
        release(&p->lock);
80103c87:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8a:	83 ec 0c             	sub    $0xc,%esp
80103c8d:	50                   	push   %eax
80103c8e:	e8 0f 12 00 00       	call   80104ea2 <release>
80103c93:	83 c4 10             	add    $0x10,%esp
        return -1;
80103c96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c9b:	e9 a9 00 00 00       	jmp    80103d49 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80103ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca3:	05 34 02 00 00       	add    $0x234,%eax
80103ca8:	83 ec 0c             	sub    $0xc,%esp
80103cab:	50                   	push   %eax
80103cac:	e8 f1 0b 00 00       	call   801048a2 <wakeup>
80103cb1:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb7:	8b 55 08             	mov    0x8(%ebp),%edx
80103cba:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc0:	83 ec 08             	sub    $0x8,%esp
80103cc3:	50                   	push   %eax
80103cc4:	52                   	push   %edx
80103cc5:	e8 f1 0a 00 00       	call   801047bb <sleep>
80103cca:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103cdf:	05 00 02 00 00       	add    $0x200,%eax
80103ce4:	39 c2                	cmp    %eax,%edx
80103ce6:	74 86                	je     80103c6e <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ce8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cee:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf4:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103cfa:	8d 48 01             	lea    0x1(%eax),%ecx
80103cfd:	8b 55 08             	mov    0x8(%ebp),%edx
80103d00:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103d06:	25 ff 01 00 00       	and    $0x1ff,%eax
80103d0b:	89 c1                	mov    %eax,%ecx
80103d0d:	0f b6 13             	movzbl (%ebx),%edx
80103d10:	8b 45 08             	mov    0x8(%ebp),%eax
80103d13:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103d17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1e:	3b 45 10             	cmp    0x10(%ebp),%eax
80103d21:	7c aa                	jl     80103ccd <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103d23:	8b 45 08             	mov    0x8(%ebp),%eax
80103d26:	05 34 02 00 00       	add    $0x234,%eax
80103d2b:	83 ec 0c             	sub    $0xc,%esp
80103d2e:	50                   	push   %eax
80103d2f:	e8 6e 0b 00 00       	call   801048a2 <wakeup>
80103d34:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d37:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3a:	83 ec 0c             	sub    $0xc,%esp
80103d3d:	50                   	push   %eax
80103d3e:	e8 5f 11 00 00       	call   80104ea2 <release>
80103d43:	83 c4 10             	add    $0x10,%esp
  return n;
80103d46:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103d49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d4c:	c9                   	leave
80103d4d:	c3                   	ret

80103d4e <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103d4e:	55                   	push   %ebp
80103d4f:	89 e5                	mov    %esp,%ebp
80103d51:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103d54:	8b 45 08             	mov    0x8(%ebp),%eax
80103d57:	83 ec 0c             	sub    $0xc,%esp
80103d5a:	50                   	push   %eax
80103d5b:	e8 d4 10 00 00       	call   80104e34 <acquire>
80103d60:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d63:	eb 3e                	jmp    80103da3 <piperead+0x55>
    if(myproc()->killed){
80103d65:	e8 a8 01 00 00       	call   80103f12 <myproc>
80103d6a:	8b 40 24             	mov    0x24(%eax),%eax
80103d6d:	85 c0                	test   %eax,%eax
80103d6f:	74 19                	je     80103d8a <piperead+0x3c>
      release(&p->lock);
80103d71:	8b 45 08             	mov    0x8(%ebp),%eax
80103d74:	83 ec 0c             	sub    $0xc,%esp
80103d77:	50                   	push   %eax
80103d78:	e8 25 11 00 00       	call   80104ea2 <release>
80103d7d:	83 c4 10             	add    $0x10,%esp
      return -1;
80103d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d85:	e9 be 00 00 00       	jmp    80103e48 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80103d90:	81 c2 34 02 00 00    	add    $0x234,%edx
80103d96:	83 ec 08             	sub    $0x8,%esp
80103d99:	50                   	push   %eax
80103d9a:	52                   	push   %edx
80103d9b:	e8 1b 0a 00 00       	call   801047bb <sleep>
80103da0:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103da3:	8b 45 08             	mov    0x8(%ebp),%eax
80103da6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dac:	8b 45 08             	mov    0x8(%ebp),%eax
80103daf:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103db5:	39 c2                	cmp    %eax,%edx
80103db7:	75 0d                	jne    80103dc6 <piperead+0x78>
80103db9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dc2:	85 c0                	test   %eax,%eax
80103dc4:	75 9f                	jne    80103d65 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103dc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dcd:	eb 48                	jmp    80103e17 <piperead+0xc9>
    if(p->nread == p->nwrite)
80103dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103de1:	39 c2                	cmp    %eax,%edx
80103de3:	74 3c                	je     80103e21 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103de5:	8b 45 08             	mov    0x8(%ebp),%eax
80103de8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103dee:	8d 48 01             	lea    0x1(%eax),%ecx
80103df1:	8b 55 08             	mov    0x8(%ebp),%edx
80103df4:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103dfa:	25 ff 01 00 00       	and    $0x1ff,%eax
80103dff:	89 c1                	mov    %eax,%ecx
80103e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e04:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e07:	01 c2                	add    %eax,%edx
80103e09:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0c:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103e11:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103e13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1a:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e1d:	7c b0                	jl     80103dcf <piperead+0x81>
80103e1f:	eb 01                	jmp    80103e22 <piperead+0xd4>
      break;
80103e21:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103e22:	8b 45 08             	mov    0x8(%ebp),%eax
80103e25:	05 38 02 00 00       	add    $0x238,%eax
80103e2a:	83 ec 0c             	sub    $0xc,%esp
80103e2d:	50                   	push   %eax
80103e2e:	e8 6f 0a 00 00       	call   801048a2 <wakeup>
80103e33:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e36:	8b 45 08             	mov    0x8(%ebp),%eax
80103e39:	83 ec 0c             	sub    $0xc,%esp
80103e3c:	50                   	push   %eax
80103e3d:	e8 60 10 00 00       	call   80104ea2 <release>
80103e42:	83 c4 10             	add    $0x10,%esp
  return i;
80103e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103e48:	c9                   	leave
80103e49:	c3                   	ret

80103e4a <readeflags>:
{
80103e4a:	55                   	push   %ebp
80103e4b:	89 e5                	mov    %esp,%ebp
80103e4d:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e50:	9c                   	pushf
80103e51:	58                   	pop    %eax
80103e52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103e55:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103e58:	c9                   	leave
80103e59:	c3                   	ret

80103e5a <sti>:
{
80103e5a:	55                   	push   %ebp
80103e5b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103e5d:	fb                   	sti
}
80103e5e:	90                   	nop
80103e5f:	5d                   	pop    %ebp
80103e60:	c3                   	ret

80103e61 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103e61:	55                   	push   %ebp
80103e62:	89 e5                	mov    %esp,%ebp
80103e64:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103e67:	83 ec 08             	sub    $0x8,%esp
80103e6a:	68 f4 a8 10 80       	push   $0x8010a8f4
80103e6f:	68 40 72 11 80       	push   $0x80117240
80103e74:	e8 99 0f 00 00       	call   80104e12 <initlock>
80103e79:	83 c4 10             	add    $0x10,%esp
}
80103e7c:	90                   	nop
80103e7d:	c9                   	leave
80103e7e:	c3                   	ret

80103e7f <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103e7f:	55                   	push   %ebp
80103e80:	89 e5                	mov    %esp,%ebp
80103e82:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e85:	e8 10 00 00 00       	call   80103e9a <mycpu>
80103e8a:	2d c0 9a 11 80       	sub    $0x80119ac0,%eax
80103e8f:	c1 f8 04             	sar    $0x4,%eax
80103e92:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103e98:	c9                   	leave
80103e99:	c3                   	ret

80103e9a <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103e9a:	55                   	push   %ebp
80103e9b:	89 e5                	mov    %esp,%ebp
80103e9d:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ea0:	e8 a5 ff ff ff       	call   80103e4a <readeflags>
80103ea5:	25 00 02 00 00       	and    $0x200,%eax
80103eaa:	85 c0                	test   %eax,%eax
80103eac:	74 0d                	je     80103ebb <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103eae:	83 ec 0c             	sub    $0xc,%esp
80103eb1:	68 fc a8 10 80       	push   $0x8010a8fc
80103eb6:	e8 ee c6 ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103ebb:	e8 1e f1 ff ff       	call   80102fde <lapicid>
80103ec0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ec3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103eca:	eb 2d                	jmp    80103ef9 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ecf:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ed5:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80103eda:	0f b6 00             	movzbl (%eax),%eax
80103edd:	0f b6 c0             	movzbl %al,%eax
80103ee0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103ee3:	75 10                	jne    80103ef5 <mycpu+0x5b>
      return &cpus[i];
80103ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee8:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103eee:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80103ef3:	eb 1b                	jmp    80103f10 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103ef5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ef9:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80103efe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103f01:	7c c9                	jl     80103ecc <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103f03:	83 ec 0c             	sub    $0xc,%esp
80103f06:	68 22 a9 10 80       	push   $0x8010a922
80103f0b:	e8 99 c6 ff ff       	call   801005a9 <panic>
}
80103f10:	c9                   	leave
80103f11:	c3                   	ret

80103f12 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f12:	55                   	push   %ebp
80103f13:	89 e5                	mov    %esp,%ebp
80103f15:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103f18:	e8 82 10 00 00       	call   80104f9f <pushcli>
  c = mycpu();
80103f1d:	e8 78 ff ff ff       	call   80103e9a <mycpu>
80103f22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f28:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f31:	e8 b6 10 00 00       	call   80104fec <popcli>
  return p;
80103f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f39:	c9                   	leave
80103f3a:	c3                   	ret

80103f3b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f3b:	55                   	push   %ebp
80103f3c:	89 e5                	mov    %esp,%ebp
80103f3e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f41:	83 ec 0c             	sub    $0xc,%esp
80103f44:	68 40 72 11 80       	push   $0x80117240
80103f49:	e8 e6 0e 00 00       	call   80104e34 <acquire>
80103f4e:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f51:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f58:	eb 0e                	jmp    80103f68 <allocproc+0x2d>
    if(p->state == UNUSED){
80103f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f5d:	8b 40 0c             	mov    0xc(%eax),%eax
80103f60:	85 c0                	test   %eax,%eax
80103f62:	74 27                	je     80103f8b <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f64:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103f68:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80103f6f:	72 e9                	jb     80103f5a <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103f71:	83 ec 0c             	sub    $0xc,%esp
80103f74:	68 40 72 11 80       	push   $0x80117240
80103f79:	e8 24 0f 00 00       	call   80104ea2 <release>
80103f7e:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f81:	b8 00 00 00 00       	mov    $0x0,%eax
80103f86:	e9 b2 00 00 00       	jmp    8010403d <allocproc+0x102>
      goto found;
80103f8b:	90                   	nop

found:
  p->state = EMBRYO;
80103f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8f:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103f96:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103f9b:	8d 50 01             	lea    0x1(%eax),%edx
80103f9e:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fa4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fa7:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103faa:	83 ec 0c             	sub    $0xc,%esp
80103fad:	68 40 72 11 80       	push   $0x80117240
80103fb2:	e8 eb 0e 00 00       	call   80104ea2 <release>
80103fb7:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103fba:	e8 cb ec ff ff       	call   80102c8a <kalloc>
80103fbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fc2:	89 42 08             	mov    %eax,0x8(%edx)
80103fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc8:	8b 40 08             	mov    0x8(%eax),%eax
80103fcb:	85 c0                	test   %eax,%eax
80103fcd:	75 11                	jne    80103fe0 <allocproc+0xa5>
    p->state = UNUSED;
80103fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103fd9:	b8 00 00 00 00       	mov    $0x0,%eax
80103fde:	eb 5d                	jmp    8010403d <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe3:	8b 40 08             	mov    0x8(%eax),%eax
80103fe6:	05 00 10 00 00       	add    $0x1000,%eax
80103feb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103fee:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ff8:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ffb:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103fff:	ba a0 64 10 80       	mov    $0x801064a0,%edx
80104004:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104007:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104009:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010400d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104010:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104013:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104019:	8b 40 1c             	mov    0x1c(%eax),%eax
8010401c:	83 ec 04             	sub    $0x4,%esp
8010401f:	6a 14                	push   $0x14
80104021:	6a 00                	push   $0x0
80104023:	50                   	push   %eax
80104024:	e8 81 10 00 00       	call   801050aa <memset>
80104029:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010402c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104032:	ba 75 47 10 80       	mov    $0x80104775,%edx
80104037:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010403a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010403d:	c9                   	leave
8010403e:	c3                   	ret

8010403f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010403f:	55                   	push   %ebp
80104040:	89 e5                	mov    %esp,%ebp
80104042:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104045:	e8 f1 fe ff ff       	call   80103f3b <allocproc>
8010404a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010404d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104050:	a3 74 92 11 80       	mov    %eax,0x80119274
  if((p->pgdir = setupkvm()) == 0){
80104055:	e8 9c 39 00 00       	call   801079f6 <setupkvm>
8010405a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010405d:	89 42 04             	mov    %eax,0x4(%edx)
80104060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104063:	8b 40 04             	mov    0x4(%eax),%eax
80104066:	85 c0                	test   %eax,%eax
80104068:	75 0d                	jne    80104077 <userinit+0x38>
    panic("userinit: out of memory?");
8010406a:	83 ec 0c             	sub    $0xc,%esp
8010406d:	68 32 a9 10 80       	push   $0x8010a932
80104072:	e8 32 c5 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104077:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010407c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407f:	8b 40 04             	mov    0x4(%eax),%eax
80104082:	83 ec 04             	sub    $0x4,%esp
80104085:	52                   	push   %edx
80104086:	68 ec f4 10 80       	push   $0x8010f4ec
8010408b:	50                   	push   %eax
8010408c:	e8 22 3c 00 00       	call   80107cb3 <inituvm>
80104091:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104097:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010409d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a0:	8b 40 18             	mov    0x18(%eax),%eax
801040a3:	83 ec 04             	sub    $0x4,%esp
801040a6:	6a 4c                	push   $0x4c
801040a8:	6a 00                	push   $0x0
801040aa:	50                   	push   %eax
801040ab:	e8 fa 0f 00 00       	call   801050aa <memset>
801040b0:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801040b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b6:	8b 40 18             	mov    0x18(%eax),%eax
801040b9:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801040bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c2:	8b 40 18             	mov    0x18(%eax),%eax
801040c5:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801040cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ce:	8b 50 18             	mov    0x18(%eax),%edx
801040d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d4:	8b 40 18             	mov    0x18(%eax),%eax
801040d7:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040db:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801040df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e2:	8b 50 18             	mov    0x18(%eax),%edx
801040e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e8:	8b 40 18             	mov    0x18(%eax),%eax
801040eb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040ef:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801040f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f6:	8b 40 18             	mov    0x18(%eax),%eax
801040f9:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104103:	8b 40 18             	mov    0x18(%eax),%eax
80104106:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010410d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104110:	8b 40 18             	mov    0x18(%eax),%eax
80104113:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010411a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411d:	83 c0 6c             	add    $0x6c,%eax
80104120:	83 ec 04             	sub    $0x4,%esp
80104123:	6a 10                	push   $0x10
80104125:	68 4b a9 10 80       	push   $0x8010a94b
8010412a:	50                   	push   %eax
8010412b:	e8 7d 11 00 00       	call   801052ad <safestrcpy>
80104130:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104133:	83 ec 0c             	sub    $0xc,%esp
80104136:	68 54 a9 10 80       	push   $0x8010a954
8010413b:	e8 e5 e3 ff ff       	call   80102525 <namei>
80104140:	83 c4 10             	add    $0x10,%esp
80104143:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104146:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104149:	83 ec 0c             	sub    $0xc,%esp
8010414c:	68 40 72 11 80       	push   $0x80117240
80104151:	e8 de 0c 00 00       	call   80104e34 <acquire>
80104156:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104163:	83 ec 0c             	sub    $0xc,%esp
80104166:	68 40 72 11 80       	push   $0x80117240
8010416b:	e8 32 0d 00 00       	call   80104ea2 <release>
80104170:	83 c4 10             	add    $0x10,%esp
}
80104173:	90                   	nop
80104174:	c9                   	leave
80104175:	c3                   	ret

80104176 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104176:	55                   	push   %ebp
80104177:	89 e5                	mov    %esp,%ebp
80104179:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010417c:	e8 91 fd ff ff       	call   80103f12 <myproc>
80104181:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104184:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104187:	8b 00                	mov    (%eax),%eax
80104189:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010418c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104190:	7e 2e                	jle    801041c0 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104192:	8b 55 08             	mov    0x8(%ebp),%edx
80104195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104198:	01 c2                	add    %eax,%edx
8010419a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010419d:	8b 40 04             	mov    0x4(%eax),%eax
801041a0:	83 ec 04             	sub    $0x4,%esp
801041a3:	52                   	push   %edx
801041a4:	ff 75 f4             	push   -0xc(%ebp)
801041a7:	50                   	push   %eax
801041a8:	e8 43 3c 00 00       	call   80107df0 <allocuvm>
801041ad:	83 c4 10             	add    $0x10,%esp
801041b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041b7:	75 3b                	jne    801041f4 <growproc+0x7e>
      return -1;
801041b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041be:	eb 4f                	jmp    8010420f <growproc+0x99>
  } else if(n < 0){
801041c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041c4:	79 2e                	jns    801041f4 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041c6:	8b 55 08             	mov    0x8(%ebp),%edx
801041c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041cc:	01 c2                	add    %eax,%edx
801041ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041d1:	8b 40 04             	mov    0x4(%eax),%eax
801041d4:	83 ec 04             	sub    $0x4,%esp
801041d7:	52                   	push   %edx
801041d8:	ff 75 f4             	push   -0xc(%ebp)
801041db:	50                   	push   %eax
801041dc:	e8 14 3d 00 00       	call   80107ef5 <deallocuvm>
801041e1:	83 c4 10             	add    $0x10,%esp
801041e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041eb:	75 07                	jne    801041f4 <growproc+0x7e>
      return -1;
801041ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f2:	eb 1b                	jmp    8010420f <growproc+0x99>
  }
  curproc->sz = sz;
801041f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fa:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801041fc:	83 ec 0c             	sub    $0xc,%esp
801041ff:	ff 75 f0             	push   -0x10(%ebp)
80104202:	e8 0d 39 00 00       	call   80107b14 <switchuvm>
80104207:	83 c4 10             	add    $0x10,%esp
  return 0;
8010420a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010420f:	c9                   	leave
80104210:	c3                   	ret

80104211 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104211:	55                   	push   %ebp
80104212:	89 e5                	mov    %esp,%ebp
80104214:	57                   	push   %edi
80104215:	56                   	push   %esi
80104216:	53                   	push   %ebx
80104217:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010421a:	e8 f3 fc ff ff       	call   80103f12 <myproc>
8010421f:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104222:	e8 14 fd ff ff       	call   80103f3b <allocproc>
80104227:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010422a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010422e:	75 0a                	jne    8010423a <fork+0x29>
    return -1;
80104230:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104235:	e9 48 01 00 00       	jmp    80104382 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010423a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010423d:	8b 10                	mov    (%eax),%edx
8010423f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104242:	8b 40 04             	mov    0x4(%eax),%eax
80104245:	83 ec 08             	sub    $0x8,%esp
80104248:	52                   	push   %edx
80104249:	50                   	push   %eax
8010424a:	e8 44 3e 00 00       	call   80108093 <copyuvm>
8010424f:	83 c4 10             	add    $0x10,%esp
80104252:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104255:	89 42 04             	mov    %eax,0x4(%edx)
80104258:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010425b:	8b 40 04             	mov    0x4(%eax),%eax
8010425e:	85 c0                	test   %eax,%eax
80104260:	75 30                	jne    80104292 <fork+0x81>
    kfree(np->kstack);
80104262:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104265:	8b 40 08             	mov    0x8(%eax),%eax
80104268:	83 ec 0c             	sub    $0xc,%esp
8010426b:	50                   	push   %eax
8010426c:	e8 7f e9 ff ff       	call   80102bf0 <kfree>
80104271:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104274:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104277:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010427e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104281:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428d:	e9 f0 00 00 00       	jmp    80104382 <fork+0x171>
  }
  np->sz = curproc->sz;
80104292:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104295:	8b 10                	mov    (%eax),%edx
80104297:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010429a:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010429c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010429f:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042a2:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801042a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042a8:	8b 48 18             	mov    0x18(%eax),%ecx
801042ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042ae:	8b 40 18             	mov    0x18(%eax),%eax
801042b1:	89 c2                	mov    %eax,%edx
801042b3:	89 cb                	mov    %ecx,%ebx
801042b5:	b8 13 00 00 00       	mov    $0x13,%eax
801042ba:	89 d7                	mov    %edx,%edi
801042bc:	89 de                	mov    %ebx,%esi
801042be:	89 c1                	mov    %eax,%ecx
801042c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801042c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042c5:	8b 40 18             	mov    0x18(%eax),%eax
801042c8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801042cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801042d6:	eb 3b                	jmp    80104313 <fork+0x102>
    if(curproc->ofile[i])
801042d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042de:	83 c2 08             	add    $0x8,%edx
801042e1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042e5:	85 c0                	test   %eax,%eax
801042e7:	74 26                	je     8010430f <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
801042e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042ef:	83 c2 08             	add    $0x8,%edx
801042f2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042f6:	83 ec 0c             	sub    $0xc,%esp
801042f9:	50                   	push   %eax
801042fa:	e8 55 cd ff ff       	call   80101054 <filedup>
801042ff:	83 c4 10             	add    $0x10,%esp
80104302:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104305:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104308:	83 c1 08             	add    $0x8,%ecx
8010430b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010430f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104313:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104317:	7e bf                	jle    801042d8 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80104319:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010431c:	8b 40 68             	mov    0x68(%eax),%eax
8010431f:	83 ec 0c             	sub    $0xc,%esp
80104322:	50                   	push   %eax
80104323:	e8 90 d6 ff ff       	call   801019b8 <idup>
80104328:	83 c4 10             	add    $0x10,%esp
8010432b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010432e:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104331:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104334:	8d 50 6c             	lea    0x6c(%eax),%edx
80104337:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010433a:	83 c0 6c             	add    $0x6c,%eax
8010433d:	83 ec 04             	sub    $0x4,%esp
80104340:	6a 10                	push   $0x10
80104342:	52                   	push   %edx
80104343:	50                   	push   %eax
80104344:	e8 64 0f 00 00       	call   801052ad <safestrcpy>
80104349:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010434c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010434f:	8b 40 10             	mov    0x10(%eax),%eax
80104352:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104355:	83 ec 0c             	sub    $0xc,%esp
80104358:	68 40 72 11 80       	push   $0x80117240
8010435d:	e8 d2 0a 00 00       	call   80104e34 <acquire>
80104362:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104365:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104368:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010436f:	83 ec 0c             	sub    $0xc,%esp
80104372:	68 40 72 11 80       	push   $0x80117240
80104377:	e8 26 0b 00 00       	call   80104ea2 <release>
8010437c:	83 c4 10             	add    $0x10,%esp

  return pid;
8010437f:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104382:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104385:	5b                   	pop    %ebx
80104386:	5e                   	pop    %esi
80104387:	5f                   	pop    %edi
80104388:	5d                   	pop    %ebp
80104389:	c3                   	ret

8010438a <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010438a:	55                   	push   %ebp
8010438b:	89 e5                	mov    %esp,%ebp
8010438d:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104390:	e8 7d fb ff ff       	call   80103f12 <myproc>
80104395:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104398:	a1 74 92 11 80       	mov    0x80119274,%eax
8010439d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801043a0:	75 0d                	jne    801043af <exit+0x25>
    panic("init exiting");
801043a2:	83 ec 0c             	sub    $0xc,%esp
801043a5:	68 56 a9 10 80       	push   $0x8010a956
801043aa:	e8 fa c1 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801043af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801043b6:	eb 3f                	jmp    801043f7 <exit+0x6d>
    if(curproc->ofile[fd]){
801043b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043be:	83 c2 08             	add    $0x8,%edx
801043c1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043c5:	85 c0                	test   %eax,%eax
801043c7:	74 2a                	je     801043f3 <exit+0x69>
      fileclose(curproc->ofile[fd]);
801043c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043cf:	83 c2 08             	add    $0x8,%edx
801043d2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043d6:	83 ec 0c             	sub    $0xc,%esp
801043d9:	50                   	push   %eax
801043da:	e8 c6 cc ff ff       	call   801010a5 <fileclose>
801043df:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801043e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043e8:	83 c2 08             	add    $0x8,%edx
801043eb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801043f2:	00 
  for(fd = 0; fd < NOFILE; fd++){
801043f3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801043f7:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801043fb:	7e bb                	jle    801043b8 <exit+0x2e>
    }
  }

  begin_op();
801043fd:	e8 1e f1 ff ff       	call   80103520 <begin_op>
  iput(curproc->cwd);
80104402:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104405:	8b 40 68             	mov    0x68(%eax),%eax
80104408:	83 ec 0c             	sub    $0xc,%esp
8010440b:	50                   	push   %eax
8010440c:	e8 42 d7 ff ff       	call   80101b53 <iput>
80104411:	83 c4 10             	add    $0x10,%esp
  end_op();
80104414:	e8 93 f1 ff ff       	call   801035ac <end_op>
  curproc->cwd = 0;
80104419:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010441c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104423:	83 ec 0c             	sub    $0xc,%esp
80104426:	68 40 72 11 80       	push   $0x80117240
8010442b:	e8 04 0a 00 00       	call   80104e34 <acquire>
80104430:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104433:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104436:	8b 40 14             	mov    0x14(%eax),%eax
80104439:	83 ec 0c             	sub    $0xc,%esp
8010443c:	50                   	push   %eax
8010443d:	e8 20 04 00 00       	call   80104862 <wakeup1>
80104442:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104445:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
8010444c:	eb 37                	jmp    80104485 <exit+0xfb>
    if(p->parent == curproc){
8010444e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104451:	8b 40 14             	mov    0x14(%eax),%eax
80104454:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104457:	75 28                	jne    80104481 <exit+0xf7>
      p->parent = initproc;
80104459:	8b 15 74 92 11 80    	mov    0x80119274,%edx
8010445f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104462:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104468:	8b 40 0c             	mov    0xc(%eax),%eax
8010446b:	83 f8 05             	cmp    $0x5,%eax
8010446e:	75 11                	jne    80104481 <exit+0xf7>
        wakeup1(initproc);
80104470:	a1 74 92 11 80       	mov    0x80119274,%eax
80104475:	83 ec 0c             	sub    $0xc,%esp
80104478:	50                   	push   %eax
80104479:	e8 e4 03 00 00       	call   80104862 <wakeup1>
8010447e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104481:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104485:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
8010448c:	72 c0                	jb     8010444e <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010448e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104491:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104498:	e8 e5 01 00 00       	call   80104682 <sched>
  panic("zombie exit");
8010449d:	83 ec 0c             	sub    $0xc,%esp
801044a0:	68 63 a9 10 80       	push   $0x8010a963
801044a5:	e8 ff c0 ff ff       	call   801005a9 <panic>

801044aa <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801044aa:	55                   	push   %ebp
801044ab:	89 e5                	mov    %esp,%ebp
801044ad:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801044b0:	e8 5d fa ff ff       	call   80103f12 <myproc>
801044b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801044b8:	83 ec 0c             	sub    $0xc,%esp
801044bb:	68 40 72 11 80       	push   $0x80117240
801044c0:	e8 6f 09 00 00       	call   80104e34 <acquire>
801044c5:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801044c8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044cf:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801044d6:	e9 a1 00 00 00       	jmp    8010457c <wait+0xd2>
      if(p->parent != curproc)
801044db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044de:	8b 40 14             	mov    0x14(%eax),%eax
801044e1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801044e4:	0f 85 8d 00 00 00    	jne    80104577 <wait+0xcd>
        continue;
      havekids = 1;
801044ea:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801044f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f4:	8b 40 0c             	mov    0xc(%eax),%eax
801044f7:	83 f8 05             	cmp    $0x5,%eax
801044fa:	75 7c                	jne    80104578 <wait+0xce>
        // Found one.
        pid = p->pid;
801044fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ff:	8b 40 10             	mov    0x10(%eax),%eax
80104502:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104508:	8b 40 08             	mov    0x8(%eax),%eax
8010450b:	83 ec 0c             	sub    $0xc,%esp
8010450e:	50                   	push   %eax
8010450f:	e8 dc e6 ff ff       	call   80102bf0 <kfree>
80104514:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104524:	8b 40 04             	mov    0x4(%eax),%eax
80104527:	83 ec 0c             	sub    $0xc,%esp
8010452a:	50                   	push   %eax
8010452b:	e8 89 3a 00 00       	call   80107fb9 <freevm>
80104530:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104536:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010453d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104540:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010454e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104551:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104562:	83 ec 0c             	sub    $0xc,%esp
80104565:	68 40 72 11 80       	push   $0x80117240
8010456a:	e8 33 09 00 00       	call   80104ea2 <release>
8010456f:	83 c4 10             	add    $0x10,%esp
        return pid;
80104572:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104575:	eb 51                	jmp    801045c8 <wait+0x11e>
        continue;
80104577:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104578:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010457c:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104583:	0f 82 52 ff ff ff    	jb     801044db <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104589:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010458d:	74 0a                	je     80104599 <wait+0xef>
8010458f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104592:	8b 40 24             	mov    0x24(%eax),%eax
80104595:	85 c0                	test   %eax,%eax
80104597:	74 17                	je     801045b0 <wait+0x106>
      release(&ptable.lock);
80104599:	83 ec 0c             	sub    $0xc,%esp
8010459c:	68 40 72 11 80       	push   $0x80117240
801045a1:	e8 fc 08 00 00       	call   80104ea2 <release>
801045a6:	83 c4 10             	add    $0x10,%esp
      return -1;
801045a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ae:	eb 18                	jmp    801045c8 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801045b0:	83 ec 08             	sub    $0x8,%esp
801045b3:	68 40 72 11 80       	push   $0x80117240
801045b8:	ff 75 ec             	push   -0x14(%ebp)
801045bb:	e8 fb 01 00 00       	call   801047bb <sleep>
801045c0:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801045c3:	e9 00 ff ff ff       	jmp    801044c8 <wait+0x1e>
  }
}
801045c8:	c9                   	leave
801045c9:	c3                   	ret

801045ca <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801045ca:	55                   	push   %ebp
801045cb:	89 e5                	mov    %esp,%ebp
801045cd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801045d0:	e8 c5 f8 ff ff       	call   80103e9a <mycpu>
801045d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801045d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045db:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045e2:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801045e5:	e8 70 f8 ff ff       	call   80103e5a <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801045ea:	83 ec 0c             	sub    $0xc,%esp
801045ed:	68 40 72 11 80       	push   $0x80117240
801045f2:	e8 3d 08 00 00       	call   80104e34 <acquire>
801045f7:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045fa:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104601:	eb 61                	jmp    80104664 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104606:	8b 40 0c             	mov    0xc(%eax),%eax
80104609:	83 f8 03             	cmp    $0x3,%eax
8010460c:	75 51                	jne    8010465f <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010460e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104611:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104614:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010461a:	83 ec 0c             	sub    $0xc,%esp
8010461d:	ff 75 f4             	push   -0xc(%ebp)
80104620:	e8 ef 34 00 00       	call   80107b14 <switchuvm>
80104625:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462b:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104635:	8b 40 1c             	mov    0x1c(%eax),%eax
80104638:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010463b:	83 c2 04             	add    $0x4,%edx
8010463e:	83 ec 08             	sub    $0x8,%esp
80104641:	50                   	push   %eax
80104642:	52                   	push   %edx
80104643:	e8 d7 0c 00 00       	call   8010531f <swtch>
80104648:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010464b:	e8 ab 34 00 00       	call   80107afb <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104653:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010465a:	00 00 00 
8010465d:	eb 01                	jmp    80104660 <scheduler+0x96>
        continue;
8010465f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104660:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104664:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
8010466b:	72 96                	jb     80104603 <scheduler+0x39>
    }
    release(&ptable.lock);
8010466d:	83 ec 0c             	sub    $0xc,%esp
80104670:	68 40 72 11 80       	push   $0x80117240
80104675:	e8 28 08 00 00       	call   80104ea2 <release>
8010467a:	83 c4 10             	add    $0x10,%esp
    sti();
8010467d:	e9 63 ff ff ff       	jmp    801045e5 <scheduler+0x1b>

80104682 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104682:	55                   	push   %ebp
80104683:	89 e5                	mov    %esp,%ebp
80104685:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104688:	e8 85 f8 ff ff       	call   80103f12 <myproc>
8010468d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104690:	83 ec 0c             	sub    $0xc,%esp
80104693:	68 40 72 11 80       	push   $0x80117240
80104698:	e8 d2 08 00 00       	call   80104f6f <holding>
8010469d:	83 c4 10             	add    $0x10,%esp
801046a0:	85 c0                	test   %eax,%eax
801046a2:	75 0d                	jne    801046b1 <sched+0x2f>
    panic("sched ptable.lock");
801046a4:	83 ec 0c             	sub    $0xc,%esp
801046a7:	68 6f a9 10 80       	push   $0x8010a96f
801046ac:	e8 f8 be ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801046b1:	e8 e4 f7 ff ff       	call   80103e9a <mycpu>
801046b6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801046bc:	83 f8 01             	cmp    $0x1,%eax
801046bf:	74 0d                	je     801046ce <sched+0x4c>
    panic("sched locks");
801046c1:	83 ec 0c             	sub    $0xc,%esp
801046c4:	68 81 a9 10 80       	push   $0x8010a981
801046c9:	e8 db be ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801046ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d1:	8b 40 0c             	mov    0xc(%eax),%eax
801046d4:	83 f8 04             	cmp    $0x4,%eax
801046d7:	75 0d                	jne    801046e6 <sched+0x64>
    panic("sched running");
801046d9:	83 ec 0c             	sub    $0xc,%esp
801046dc:	68 8d a9 10 80       	push   $0x8010a98d
801046e1:	e8 c3 be ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801046e6:	e8 5f f7 ff ff       	call   80103e4a <readeflags>
801046eb:	25 00 02 00 00       	and    $0x200,%eax
801046f0:	85 c0                	test   %eax,%eax
801046f2:	74 0d                	je     80104701 <sched+0x7f>
    panic("sched interruptible");
801046f4:	83 ec 0c             	sub    $0xc,%esp
801046f7:	68 9b a9 10 80       	push   $0x8010a99b
801046fc:	e8 a8 be ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104701:	e8 94 f7 ff ff       	call   80103e9a <mycpu>
80104706:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010470c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010470f:	e8 86 f7 ff ff       	call   80103e9a <mycpu>
80104714:	8b 40 04             	mov    0x4(%eax),%eax
80104717:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010471a:	83 c2 1c             	add    $0x1c,%edx
8010471d:	83 ec 08             	sub    $0x8,%esp
80104720:	50                   	push   %eax
80104721:	52                   	push   %edx
80104722:	e8 f8 0b 00 00       	call   8010531f <swtch>
80104727:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010472a:	e8 6b f7 ff ff       	call   80103e9a <mycpu>
8010472f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104732:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104738:	90                   	nop
80104739:	c9                   	leave
8010473a:	c3                   	ret

8010473b <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010473b:	55                   	push   %ebp
8010473c:	89 e5                	mov    %esp,%ebp
8010473e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104741:	83 ec 0c             	sub    $0xc,%esp
80104744:	68 40 72 11 80       	push   $0x80117240
80104749:	e8 e6 06 00 00       	call   80104e34 <acquire>
8010474e:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104751:	e8 bc f7 ff ff       	call   80103f12 <myproc>
80104756:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010475d:	e8 20 ff ff ff       	call   80104682 <sched>
  release(&ptable.lock);
80104762:	83 ec 0c             	sub    $0xc,%esp
80104765:	68 40 72 11 80       	push   $0x80117240
8010476a:	e8 33 07 00 00       	call   80104ea2 <release>
8010476f:	83 c4 10             	add    $0x10,%esp
}
80104772:	90                   	nop
80104773:	c9                   	leave
80104774:	c3                   	ret

80104775 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104775:	55                   	push   %ebp
80104776:	89 e5                	mov    %esp,%ebp
80104778:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010477b:	83 ec 0c             	sub    $0xc,%esp
8010477e:	68 40 72 11 80       	push   $0x80117240
80104783:	e8 1a 07 00 00       	call   80104ea2 <release>
80104788:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010478b:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104790:	85 c0                	test   %eax,%eax
80104792:	74 24                	je     801047b8 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104794:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010479b:	00 00 00 
    iinit(ROOTDEV);
8010479e:	83 ec 0c             	sub    $0xc,%esp
801047a1:	6a 01                	push   $0x1
801047a3:	e8 d9 ce ff ff       	call   80101681 <iinit>
801047a8:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801047ab:	83 ec 0c             	sub    $0xc,%esp
801047ae:	6a 01                	push   $0x1
801047b0:	e8 4c eb ff ff       	call   80103301 <initlog>
801047b5:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801047b8:	90                   	nop
801047b9:	c9                   	leave
801047ba:	c3                   	ret

801047bb <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801047bb:	55                   	push   %ebp
801047bc:	89 e5                	mov    %esp,%ebp
801047be:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801047c1:	e8 4c f7 ff ff       	call   80103f12 <myproc>
801047c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801047c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047cd:	75 0d                	jne    801047dc <sleep+0x21>
    panic("sleep");
801047cf:	83 ec 0c             	sub    $0xc,%esp
801047d2:	68 af a9 10 80       	push   $0x8010a9af
801047d7:	e8 cd bd ff ff       	call   801005a9 <panic>

  if(lk == 0)
801047dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047e0:	75 0d                	jne    801047ef <sleep+0x34>
    panic("sleep without lk");
801047e2:	83 ec 0c             	sub    $0xc,%esp
801047e5:	68 b5 a9 10 80       	push   $0x8010a9b5
801047ea:	e8 ba bd ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801047ef:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
801047f6:	74 1e                	je     80104816 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801047f8:	83 ec 0c             	sub    $0xc,%esp
801047fb:	68 40 72 11 80       	push   $0x80117240
80104800:	e8 2f 06 00 00       	call   80104e34 <acquire>
80104805:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104808:	83 ec 0c             	sub    $0xc,%esp
8010480b:	ff 75 0c             	push   0xc(%ebp)
8010480e:	e8 8f 06 00 00       	call   80104ea2 <release>
80104813:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104819:	8b 55 08             	mov    0x8(%ebp),%edx
8010481c:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010481f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104822:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104829:	e8 54 fe ff ff       	call   80104682 <sched>

  // Tidy up.
  p->chan = 0;
8010482e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104831:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104838:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
8010483f:	74 1e                	je     8010485f <sleep+0xa4>
    release(&ptable.lock);
80104841:	83 ec 0c             	sub    $0xc,%esp
80104844:	68 40 72 11 80       	push   $0x80117240
80104849:	e8 54 06 00 00       	call   80104ea2 <release>
8010484e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104851:	83 ec 0c             	sub    $0xc,%esp
80104854:	ff 75 0c             	push   0xc(%ebp)
80104857:	e8 d8 05 00 00       	call   80104e34 <acquire>
8010485c:	83 c4 10             	add    $0x10,%esp
  }
}
8010485f:	90                   	nop
80104860:	c9                   	leave
80104861:	c3                   	ret

80104862 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104862:	55                   	push   %ebp
80104863:	89 e5                	mov    %esp,%ebp
80104865:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104868:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
8010486f:	eb 24                	jmp    80104895 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104871:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104874:	8b 40 0c             	mov    0xc(%eax),%eax
80104877:	83 f8 02             	cmp    $0x2,%eax
8010487a:	75 15                	jne    80104891 <wakeup1+0x2f>
8010487c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010487f:	8b 40 20             	mov    0x20(%eax),%eax
80104882:	39 45 08             	cmp    %eax,0x8(%ebp)
80104885:	75 0a                	jne    80104891 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104887:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010488a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104891:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104895:	81 7d fc 74 92 11 80 	cmpl   $0x80119274,-0x4(%ebp)
8010489c:	72 d3                	jb     80104871 <wakeup1+0xf>
}
8010489e:	90                   	nop
8010489f:	90                   	nop
801048a0:	c9                   	leave
801048a1:	c3                   	ret

801048a2 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048a2:	55                   	push   %ebp
801048a3:	89 e5                	mov    %esp,%ebp
801048a5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801048a8:	83 ec 0c             	sub    $0xc,%esp
801048ab:	68 40 72 11 80       	push   $0x80117240
801048b0:	e8 7f 05 00 00       	call   80104e34 <acquire>
801048b5:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801048b8:	83 ec 0c             	sub    $0xc,%esp
801048bb:	ff 75 08             	push   0x8(%ebp)
801048be:	e8 9f ff ff ff       	call   80104862 <wakeup1>
801048c3:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801048c6:	83 ec 0c             	sub    $0xc,%esp
801048c9:	68 40 72 11 80       	push   $0x80117240
801048ce:	e8 cf 05 00 00       	call   80104ea2 <release>
801048d3:	83 c4 10             	add    $0x10,%esp
}
801048d6:	90                   	nop
801048d7:	c9                   	leave
801048d8:	c3                   	ret

801048d9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801048d9:	55                   	push   %ebp
801048da:	89 e5                	mov    %esp,%ebp
801048dc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048df:	83 ec 0c             	sub    $0xc,%esp
801048e2:	68 40 72 11 80       	push   $0x80117240
801048e7:	e8 48 05 00 00       	call   80104e34 <acquire>
801048ec:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048ef:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801048f6:	eb 45                	jmp    8010493d <kill+0x64>
    if(p->pid == pid){
801048f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fb:	8b 40 10             	mov    0x10(%eax),%eax
801048fe:	39 45 08             	cmp    %eax,0x8(%ebp)
80104901:	75 36                	jne    80104939 <kill+0x60>
      p->killed = 1;
80104903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104906:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010490d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104910:	8b 40 0c             	mov    0xc(%eax),%eax
80104913:	83 f8 02             	cmp    $0x2,%eax
80104916:	75 0a                	jne    80104922 <kill+0x49>
        p->state = RUNNABLE;
80104918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104922:	83 ec 0c             	sub    $0xc,%esp
80104925:	68 40 72 11 80       	push   $0x80117240
8010492a:	e8 73 05 00 00       	call   80104ea2 <release>
8010492f:	83 c4 10             	add    $0x10,%esp
      return 0;
80104932:	b8 00 00 00 00       	mov    $0x0,%eax
80104937:	eb 22                	jmp    8010495b <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104939:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010493d:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104944:	72 b2                	jb     801048f8 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104946:	83 ec 0c             	sub    $0xc,%esp
80104949:	68 40 72 11 80       	push   $0x80117240
8010494e:	e8 4f 05 00 00       	call   80104ea2 <release>
80104953:	83 c4 10             	add    $0x10,%esp
  return -1;
80104956:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010495b:	c9                   	leave
8010495c:	c3                   	ret

8010495d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010495d:	55                   	push   %ebp
8010495e:	89 e5                	mov    %esp,%ebp
80104960:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104963:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
8010496a:	e9 d7 00 00 00       	jmp    80104a46 <procdump+0xe9>
    if(p->state == UNUSED)
8010496f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104972:	8b 40 0c             	mov    0xc(%eax),%eax
80104975:	85 c0                	test   %eax,%eax
80104977:	0f 84 c4 00 00 00    	je     80104a41 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010497d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104980:	8b 40 0c             	mov    0xc(%eax),%eax
80104983:	83 f8 05             	cmp    $0x5,%eax
80104986:	77 23                	ja     801049ab <procdump+0x4e>
80104988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010498b:	8b 40 0c             	mov    0xc(%eax),%eax
8010498e:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104995:	85 c0                	test   %eax,%eax
80104997:	74 12                	je     801049ab <procdump+0x4e>
      state = states[p->state];
80104999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499c:	8b 40 0c             	mov    0xc(%eax),%eax
8010499f:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801049a9:	eb 07                	jmp    801049b2 <procdump+0x55>
    else
      state = "???";
801049ab:	c7 45 ec c6 a9 10 80 	movl   $0x8010a9c6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049b5:	8d 50 6c             	lea    0x6c(%eax),%edx
801049b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049bb:	8b 40 10             	mov    0x10(%eax),%eax
801049be:	52                   	push   %edx
801049bf:	ff 75 ec             	push   -0x14(%ebp)
801049c2:	50                   	push   %eax
801049c3:	68 ca a9 10 80       	push   $0x8010a9ca
801049c8:	e8 27 ba ff ff       	call   801003f4 <cprintf>
801049cd:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801049d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049d3:	8b 40 0c             	mov    0xc(%eax),%eax
801049d6:	83 f8 02             	cmp    $0x2,%eax
801049d9:	75 54                	jne    80104a2f <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801049db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049de:	8b 40 1c             	mov    0x1c(%eax),%eax
801049e1:	8b 40 0c             	mov    0xc(%eax),%eax
801049e4:	83 c0 08             	add    $0x8,%eax
801049e7:	89 c2                	mov    %eax,%edx
801049e9:	83 ec 08             	sub    $0x8,%esp
801049ec:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801049ef:	50                   	push   %eax
801049f0:	52                   	push   %edx
801049f1:	e8 fe 04 00 00       	call   80104ef4 <getcallerpcs>
801049f6:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801049f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a00:	eb 1c                	jmp    80104a1e <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a05:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a09:	83 ec 08             	sub    $0x8,%esp
80104a0c:	50                   	push   %eax
80104a0d:	68 d3 a9 10 80       	push   $0x8010a9d3
80104a12:	e8 dd b9 ff ff       	call   801003f4 <cprintf>
80104a17:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a1e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a22:	7f 0b                	jg     80104a2f <procdump+0xd2>
80104a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a27:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a2b:	85 c0                	test   %eax,%eax
80104a2d:	75 d3                	jne    80104a02 <procdump+0xa5>
    }
    cprintf("\n");
80104a2f:	83 ec 0c             	sub    $0xc,%esp
80104a32:	68 d7 a9 10 80       	push   $0x8010a9d7
80104a37:	e8 b8 b9 ff ff       	call   801003f4 <cprintf>
80104a3c:	83 c4 10             	add    $0x10,%esp
80104a3f:	eb 01                	jmp    80104a42 <procdump+0xe5>
      continue;
80104a41:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a42:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104a46:	81 7d f0 74 92 11 80 	cmpl   $0x80119274,-0x10(%ebp)
80104a4d:	0f 82 1c ff ff ff    	jb     8010496f <procdump+0x12>
  }
}
80104a53:	90                   	nop
80104a54:	90                   	nop
80104a55:	c9                   	leave
80104a56:	c3                   	ret

80104a57 <exit2>:

void
exit2(int status)
{
80104a57:	55                   	push   %ebp
80104a58:	89 e5                	mov    %esp,%ebp
80104a5a:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104a5d:	e8 b0 f4 ff ff       	call   80103f12 <myproc>
80104a62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a65:	a1 74 92 11 80       	mov    0x80119274,%eax
80104a6a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a6d:	75 0d                	jne    80104a7c <exit2+0x25>
    panic("init exiting");
80104a6f:	83 ec 0c             	sub    $0xc,%esp
80104a72:	68 56 a9 10 80       	push   $0x8010a956
80104a77:	e8 2d bb ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a7c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a83:	eb 3f                	jmp    80104ac4 <exit2+0x6d>
    if(curproc->ofile[fd]){
80104a85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a88:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a8b:	83 c2 08             	add    $0x8,%edx
80104a8e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a92:	85 c0                	test   %eax,%eax
80104a94:	74 2a                	je     80104ac0 <exit2+0x69>
      fileclose(curproc->ofile[fd]);
80104a96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a99:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a9c:	83 c2 08             	add    $0x8,%edx
80104a9f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104aa3:	83 ec 0c             	sub    $0xc,%esp
80104aa6:	50                   	push   %eax
80104aa7:	e8 f9 c5 ff ff       	call   801010a5 <fileclose>
80104aac:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104aaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ab2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ab5:	83 c2 08             	add    $0x8,%edx
80104ab8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104abf:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104ac0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104ac4:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104ac8:	7e bb                	jle    80104a85 <exit2+0x2e>
    }
  }

  begin_op();
80104aca:	e8 51 ea ff ff       	call   80103520 <begin_op>
  iput(curproc->cwd);
80104acf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ad2:	8b 40 68             	mov    0x68(%eax),%eax
80104ad5:	83 ec 0c             	sub    $0xc,%esp
80104ad8:	50                   	push   %eax
80104ad9:	e8 75 d0 ff ff       	call   80101b53 <iput>
80104ade:	83 c4 10             	add    $0x10,%esp
  end_op();
80104ae1:	e8 c6 ea ff ff       	call   801035ac <end_op>
  curproc->cwd = 0;
80104ae6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ae9:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104af0:	83 ec 0c             	sub    $0xc,%esp
80104af3:	68 40 72 11 80       	push   $0x80117240
80104af8:	e8 37 03 00 00       	call   80104e34 <acquire>
80104afd:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104b00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b03:	8b 40 14             	mov    0x14(%eax),%eax
80104b06:	83 ec 0c             	sub    $0xc,%esp
80104b09:	50                   	push   %eax
80104b0a:	e8 53 fd ff ff       	call   80104862 <wakeup1>
80104b0f:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b12:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104b19:	eb 37                	jmp    80104b52 <exit2+0xfb>
    if(p->parent == curproc){
80104b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1e:	8b 40 14             	mov    0x14(%eax),%eax
80104b21:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104b24:	75 28                	jne    80104b4e <exit2+0xf7>
      p->parent = initproc;
80104b26:	8b 15 74 92 11 80    	mov    0x80119274,%edx
80104b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2f:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b35:	8b 40 0c             	mov    0xc(%eax),%eax
80104b38:	83 f8 05             	cmp    $0x5,%eax
80104b3b:	75 11                	jne    80104b4e <exit2+0xf7>
        wakeup1(initproc);
80104b3d:	a1 74 92 11 80       	mov    0x80119274,%eax
80104b42:	83 ec 0c             	sub    $0xc,%esp
80104b45:	50                   	push   %eax
80104b46:	e8 17 fd ff ff       	call   80104862 <wakeup1>
80104b4b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b4e:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104b52:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104b59:	72 c0                	jb     80104b1b <exit2+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->xstate = status;
80104b5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b5e:	8b 55 08             	mov    0x8(%ebp),%edx
80104b61:	89 50 7c             	mov    %edx,0x7c(%eax)
  curproc->state = ZOMBIE;
80104b64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b67:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b6e:	e8 0f fb ff ff       	call   80104682 <sched>
  panic("zombie exit");
80104b73:	83 ec 0c             	sub    $0xc,%esp
80104b76:	68 63 a9 10 80       	push   $0x8010a963
80104b7b:	e8 29 ba ff ff       	call   801005a9 <panic>

80104b80 <wait2>:
}

int
wait2(int *status)
{
80104b80:	55                   	push   %ebp
80104b81:	89 e5                	mov    %esp,%ebp
80104b83:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b86:	e8 87 f3 ff ff       	call   80103f12 <myproc>
80104b8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b8e:	83 ec 0c             	sub    $0xc,%esp
80104b91:	68 40 72 11 80       	push   $0x80117240
80104b96:	e8 99 02 00 00       	call   80104e34 <acquire>
80104b9b:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b9e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ba5:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104bac:	e9 b6 00 00 00       	jmp    80104c67 <wait2+0xe7>
      if(p->parent != curproc)
80104bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb4:	8b 40 14             	mov    0x14(%eax),%eax
80104bb7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104bba:	0f 85 a2 00 00 00    	jne    80104c62 <wait2+0xe2>
        continue;
      havekids = 1;
80104bc0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bca:	8b 40 0c             	mov    0xc(%eax),%eax
80104bcd:	83 f8 05             	cmp    $0x5,%eax
80104bd0:	0f 85 8d 00 00 00    	jne    80104c63 <wait2+0xe3>
        // Found one.
        pid = p->pid;
80104bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd9:	8b 40 10             	mov    0x10(%eax),%eax
80104bdc:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be2:	8b 40 08             	mov    0x8(%eax),%eax
80104be5:	83 ec 0c             	sub    $0xc,%esp
80104be8:	50                   	push   %eax
80104be9:	e8 02 e0 ff ff       	call   80102bf0 <kfree>
80104bee:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfe:	8b 40 04             	mov    0x4(%eax),%eax
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	50                   	push   %eax
80104c05:	e8 af 33 00 00       	call   80107fb9 <freevm>
80104c0a:	83 c4 10             	add    $0x10,%esp

        if(status != 0)
80104c0d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104c11:	74 0b                	je     80104c1e <wait2+0x9e>
          *status = p->xstate;
80104c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c16:	8b 50 7c             	mov    0x7c(%eax),%edx
80104c19:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1c:	89 10                	mov    %edx,(%eax)

        p->pid = 0;
80104c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c21:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c35:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c46:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104c4d:	83 ec 0c             	sub    $0xc,%esp
80104c50:	68 40 72 11 80       	push   $0x80117240
80104c55:	e8 48 02 00 00       	call   80104ea2 <release>
80104c5a:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c60:	eb 51                	jmp    80104cb3 <wait2+0x133>
        continue;
80104c62:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c63:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104c67:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104c6e:	0f 82 3d ff ff ff    	jb     80104bb1 <wait2+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c74:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c78:	74 0a                	je     80104c84 <wait2+0x104>
80104c7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c7d:	8b 40 24             	mov    0x24(%eax),%eax
80104c80:	85 c0                	test   %eax,%eax
80104c82:	74 17                	je     80104c9b <wait2+0x11b>
      release(&ptable.lock);
80104c84:	83 ec 0c             	sub    $0xc,%esp
80104c87:	68 40 72 11 80       	push   $0x80117240
80104c8c:	e8 11 02 00 00       	call   80104ea2 <release>
80104c91:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c99:	eb 18                	jmp    80104cb3 <wait2+0x133>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c9b:	83 ec 08             	sub    $0x8,%esp
80104c9e:	68 40 72 11 80       	push   $0x80117240
80104ca3:	ff 75 ec             	push   -0x14(%ebp)
80104ca6:	e8 10 fb ff ff       	call   801047bb <sleep>
80104cab:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104cae:	e9 eb fe ff ff       	jmp    80104b9e <wait2+0x1e>
  }
}
80104cb3:	c9                   	leave
80104cb4:	c3                   	ret

80104cb5 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104cb5:	55                   	push   %ebp
80104cb6:	89 e5                	mov    %esp,%ebp
80104cb8:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cbe:	83 c0 04             	add    $0x4,%eax
80104cc1:	83 ec 08             	sub    $0x8,%esp
80104cc4:	68 03 aa 10 80       	push   $0x8010aa03
80104cc9:	50                   	push   %eax
80104cca:	e8 43 01 00 00       	call   80104e12 <initlock>
80104ccf:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd5:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cd8:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80104cde:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce7:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104cee:	90                   	nop
80104cef:	c9                   	leave
80104cf0:	c3                   	ret

80104cf1 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104cf1:	55                   	push   %ebp
80104cf2:	89 e5                	mov    %esp,%ebp
80104cf4:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cfa:	83 c0 04             	add    $0x4,%eax
80104cfd:	83 ec 0c             	sub    $0xc,%esp
80104d00:	50                   	push   %eax
80104d01:	e8 2e 01 00 00       	call   80104e34 <acquire>
80104d06:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104d09:	eb 15                	jmp    80104d20 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0e:	83 c0 04             	add    $0x4,%eax
80104d11:	83 ec 08             	sub    $0x8,%esp
80104d14:	50                   	push   %eax
80104d15:	ff 75 08             	push   0x8(%ebp)
80104d18:	e8 9e fa ff ff       	call   801047bb <sleep>
80104d1d:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104d20:	8b 45 08             	mov    0x8(%ebp),%eax
80104d23:	8b 00                	mov    (%eax),%eax
80104d25:	85 c0                	test   %eax,%eax
80104d27:	75 e2                	jne    80104d0b <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104d29:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104d32:	e8 db f1 ff ff       	call   80103f12 <myproc>
80104d37:	8b 50 10             	mov    0x10(%eax),%edx
80104d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3d:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104d40:	8b 45 08             	mov    0x8(%ebp),%eax
80104d43:	83 c0 04             	add    $0x4,%eax
80104d46:	83 ec 0c             	sub    $0xc,%esp
80104d49:	50                   	push   %eax
80104d4a:	e8 53 01 00 00       	call   80104ea2 <release>
80104d4f:	83 c4 10             	add    $0x10,%esp
}
80104d52:	90                   	nop
80104d53:	c9                   	leave
80104d54:	c3                   	ret

80104d55 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104d55:	55                   	push   %ebp
80104d56:	89 e5                	mov    %esp,%ebp
80104d58:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5e:	83 c0 04             	add    $0x4,%eax
80104d61:	83 ec 0c             	sub    $0xc,%esp
80104d64:	50                   	push   %eax
80104d65:	e8 ca 00 00 00       	call   80104e34 <acquire>
80104d6a:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104d76:	8b 45 08             	mov    0x8(%ebp),%eax
80104d79:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104d80:	83 ec 0c             	sub    $0xc,%esp
80104d83:	ff 75 08             	push   0x8(%ebp)
80104d86:	e8 17 fb ff ff       	call   801048a2 <wakeup>
80104d8b:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d91:	83 c0 04             	add    $0x4,%eax
80104d94:	83 ec 0c             	sub    $0xc,%esp
80104d97:	50                   	push   %eax
80104d98:	e8 05 01 00 00       	call   80104ea2 <release>
80104d9d:	83 c4 10             	add    $0x10,%esp
}
80104da0:	90                   	nop
80104da1:	c9                   	leave
80104da2:	c3                   	ret

80104da3 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104da3:	55                   	push   %ebp
80104da4:	89 e5                	mov    %esp,%ebp
80104da6:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104da9:	8b 45 08             	mov    0x8(%ebp),%eax
80104dac:	83 c0 04             	add    $0x4,%eax
80104daf:	83 ec 0c             	sub    $0xc,%esp
80104db2:	50                   	push   %eax
80104db3:	e8 7c 00 00 00       	call   80104e34 <acquire>
80104db8:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbe:	8b 00                	mov    (%eax),%eax
80104dc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc6:	83 c0 04             	add    $0x4,%eax
80104dc9:	83 ec 0c             	sub    $0xc,%esp
80104dcc:	50                   	push   %eax
80104dcd:	e8 d0 00 00 00       	call   80104ea2 <release>
80104dd2:	83 c4 10             	add    $0x10,%esp
  return r;
80104dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104dd8:	c9                   	leave
80104dd9:	c3                   	ret

80104dda <readeflags>:
{
80104dda:	55                   	push   %ebp
80104ddb:	89 e5                	mov    %esp,%ebp
80104ddd:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104de0:	9c                   	pushf
80104de1:	58                   	pop    %eax
80104de2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104de5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104de8:	c9                   	leave
80104de9:	c3                   	ret

80104dea <cli>:
{
80104dea:	55                   	push   %ebp
80104deb:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ded:	fa                   	cli
}
80104dee:	90                   	nop
80104def:	5d                   	pop    %ebp
80104df0:	c3                   	ret

80104df1 <sti>:
{
80104df1:	55                   	push   %ebp
80104df2:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104df4:	fb                   	sti
}
80104df5:	90                   	nop
80104df6:	5d                   	pop    %ebp
80104df7:	c3                   	ret

80104df8 <xchg>:
{
80104df8:	55                   	push   %ebp
80104df9:	89 e5                	mov    %esp,%ebp
80104dfb:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104dfe:	8b 55 08             	mov    0x8(%ebp),%edx
80104e01:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e04:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e07:	f0 87 02             	lock xchg %eax,(%edx)
80104e0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104e0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104e10:	c9                   	leave
80104e11:	c3                   	ret

80104e12 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104e12:	55                   	push   %ebp
80104e13:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104e15:	8b 45 08             	mov    0x8(%ebp),%eax
80104e18:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e1b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104e27:	8b 45 08             	mov    0x8(%ebp),%eax
80104e2a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104e31:	90                   	nop
80104e32:	5d                   	pop    %ebp
80104e33:	c3                   	ret

80104e34 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104e34:	55                   	push   %ebp
80104e35:	89 e5                	mov    %esp,%ebp
80104e37:	53                   	push   %ebx
80104e38:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104e3b:	e8 5f 01 00 00       	call   80104f9f <pushcli>
  if(holding(lk)){
80104e40:	8b 45 08             	mov    0x8(%ebp),%eax
80104e43:	83 ec 0c             	sub    $0xc,%esp
80104e46:	50                   	push   %eax
80104e47:	e8 23 01 00 00       	call   80104f6f <holding>
80104e4c:	83 c4 10             	add    $0x10,%esp
80104e4f:	85 c0                	test   %eax,%eax
80104e51:	74 0d                	je     80104e60 <acquire+0x2c>
    panic("acquire");
80104e53:	83 ec 0c             	sub    $0xc,%esp
80104e56:	68 0e aa 10 80       	push   $0x8010aa0e
80104e5b:	e8 49 b7 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104e60:	90                   	nop
80104e61:	8b 45 08             	mov    0x8(%ebp),%eax
80104e64:	83 ec 08             	sub    $0x8,%esp
80104e67:	6a 01                	push   $0x1
80104e69:	50                   	push   %eax
80104e6a:	e8 89 ff ff ff       	call   80104df8 <xchg>
80104e6f:	83 c4 10             	add    $0x10,%esp
80104e72:	85 c0                	test   %eax,%eax
80104e74:	75 eb                	jne    80104e61 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104e76:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104e7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104e7e:	e8 17 f0 ff ff       	call   80103e9a <mycpu>
80104e83:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104e86:	8b 45 08             	mov    0x8(%ebp),%eax
80104e89:	83 c0 0c             	add    $0xc,%eax
80104e8c:	83 ec 08             	sub    $0x8,%esp
80104e8f:	50                   	push   %eax
80104e90:	8d 45 08             	lea    0x8(%ebp),%eax
80104e93:	50                   	push   %eax
80104e94:	e8 5b 00 00 00       	call   80104ef4 <getcallerpcs>
80104e99:	83 c4 10             	add    $0x10,%esp
}
80104e9c:	90                   	nop
80104e9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ea0:	c9                   	leave
80104ea1:	c3                   	ret

80104ea2 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104ea2:	55                   	push   %ebp
80104ea3:	89 e5                	mov    %esp,%ebp
80104ea5:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104ea8:	83 ec 0c             	sub    $0xc,%esp
80104eab:	ff 75 08             	push   0x8(%ebp)
80104eae:	e8 bc 00 00 00       	call   80104f6f <holding>
80104eb3:	83 c4 10             	add    $0x10,%esp
80104eb6:	85 c0                	test   %eax,%eax
80104eb8:	75 0d                	jne    80104ec7 <release+0x25>
    panic("release");
80104eba:	83 ec 0c             	sub    $0xc,%esp
80104ebd:	68 16 aa 10 80       	push   $0x8010aa16
80104ec2:	e8 e2 b6 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80104eca:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104edb:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee3:	8b 55 08             	mov    0x8(%ebp),%edx
80104ee6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104eec:	e8 fb 00 00 00       	call   80104fec <popcli>
}
80104ef1:	90                   	nop
80104ef2:	c9                   	leave
80104ef3:	c3                   	ret

80104ef4 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104ef4:	55                   	push   %ebp
80104ef5:	89 e5                	mov    %esp,%ebp
80104ef7:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104efa:	8b 45 08             	mov    0x8(%ebp),%eax
80104efd:	83 e8 08             	sub    $0x8,%eax
80104f00:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104f03:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104f0a:	eb 38                	jmp    80104f44 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104f0c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104f10:	74 53                	je     80104f65 <getcallerpcs+0x71>
80104f12:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104f19:	76 4a                	jbe    80104f65 <getcallerpcs+0x71>
80104f1b:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104f1f:	74 44                	je     80104f65 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104f21:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f2e:	01 c2                	add    %eax,%edx
80104f30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f33:	8b 40 04             	mov    0x4(%eax),%eax
80104f36:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104f38:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f3b:	8b 00                	mov    (%eax),%eax
80104f3d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104f40:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f44:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f48:	7e c2                	jle    80104f0c <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104f4a:	eb 19                	jmp    80104f65 <getcallerpcs+0x71>
    pcs[i] = 0;
80104f4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f56:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f59:	01 d0                	add    %edx,%eax
80104f5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104f61:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f65:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f69:	7e e1                	jle    80104f4c <getcallerpcs+0x58>
}
80104f6b:	90                   	nop
80104f6c:	90                   	nop
80104f6d:	c9                   	leave
80104f6e:	c3                   	ret

80104f6f <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104f6f:	55                   	push   %ebp
80104f70:	89 e5                	mov    %esp,%ebp
80104f72:	53                   	push   %ebx
80104f73:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104f76:	8b 45 08             	mov    0x8(%ebp),%eax
80104f79:	8b 00                	mov    (%eax),%eax
80104f7b:	85 c0                	test   %eax,%eax
80104f7d:	74 16                	je     80104f95 <holding+0x26>
80104f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f82:	8b 58 08             	mov    0x8(%eax),%ebx
80104f85:	e8 10 ef ff ff       	call   80103e9a <mycpu>
80104f8a:	39 c3                	cmp    %eax,%ebx
80104f8c:	75 07                	jne    80104f95 <holding+0x26>
80104f8e:	b8 01 00 00 00       	mov    $0x1,%eax
80104f93:	eb 05                	jmp    80104f9a <holding+0x2b>
80104f95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f9d:	c9                   	leave
80104f9e:	c3                   	ret

80104f9f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104f9f:	55                   	push   %ebp
80104fa0:	89 e5                	mov    %esp,%ebp
80104fa2:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104fa5:	e8 30 fe ff ff       	call   80104dda <readeflags>
80104faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104fad:	e8 38 fe ff ff       	call   80104dea <cli>
  if(mycpu()->ncli == 0)
80104fb2:	e8 e3 ee ff ff       	call   80103e9a <mycpu>
80104fb7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104fbd:	85 c0                	test   %eax,%eax
80104fbf:	75 14                	jne    80104fd5 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104fc1:	e8 d4 ee ff ff       	call   80103e9a <mycpu>
80104fc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fc9:	81 e2 00 02 00 00    	and    $0x200,%edx
80104fcf:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104fd5:	e8 c0 ee ff ff       	call   80103e9a <mycpu>
80104fda:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104fe0:	83 c2 01             	add    $0x1,%edx
80104fe3:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104fe9:	90                   	nop
80104fea:	c9                   	leave
80104feb:	c3                   	ret

80104fec <popcli>:

void
popcli(void)
{
80104fec:	55                   	push   %ebp
80104fed:	89 e5                	mov    %esp,%ebp
80104fef:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104ff2:	e8 e3 fd ff ff       	call   80104dda <readeflags>
80104ff7:	25 00 02 00 00       	and    $0x200,%eax
80104ffc:	85 c0                	test   %eax,%eax
80104ffe:	74 0d                	je     8010500d <popcli+0x21>
    panic("popcli - interruptible");
80105000:	83 ec 0c             	sub    $0xc,%esp
80105003:	68 1e aa 10 80       	push   $0x8010aa1e
80105008:	e8 9c b5 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
8010500d:	e8 88 ee ff ff       	call   80103e9a <mycpu>
80105012:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105018:	83 ea 01             	sub    $0x1,%edx
8010501b:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105021:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105027:	85 c0                	test   %eax,%eax
80105029:	79 0d                	jns    80105038 <popcli+0x4c>
    panic("popcli");
8010502b:	83 ec 0c             	sub    $0xc,%esp
8010502e:	68 35 aa 10 80       	push   $0x8010aa35
80105033:	e8 71 b5 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105038:	e8 5d ee ff ff       	call   80103e9a <mycpu>
8010503d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105043:	85 c0                	test   %eax,%eax
80105045:	75 14                	jne    8010505b <popcli+0x6f>
80105047:	e8 4e ee ff ff       	call   80103e9a <mycpu>
8010504c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105052:	85 c0                	test   %eax,%eax
80105054:	74 05                	je     8010505b <popcli+0x6f>
    sti();
80105056:	e8 96 fd ff ff       	call   80104df1 <sti>
}
8010505b:	90                   	nop
8010505c:	c9                   	leave
8010505d:	c3                   	ret

8010505e <stosb>:
{
8010505e:	55                   	push   %ebp
8010505f:	89 e5                	mov    %esp,%ebp
80105061:	57                   	push   %edi
80105062:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105063:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105066:	8b 55 10             	mov    0x10(%ebp),%edx
80105069:	8b 45 0c             	mov    0xc(%ebp),%eax
8010506c:	89 cb                	mov    %ecx,%ebx
8010506e:	89 df                	mov    %ebx,%edi
80105070:	89 d1                	mov    %edx,%ecx
80105072:	fc                   	cld
80105073:	f3 aa                	rep stos %al,%es:(%edi)
80105075:	89 ca                	mov    %ecx,%edx
80105077:	89 fb                	mov    %edi,%ebx
80105079:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010507c:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010507f:	90                   	nop
80105080:	5b                   	pop    %ebx
80105081:	5f                   	pop    %edi
80105082:	5d                   	pop    %ebp
80105083:	c3                   	ret

80105084 <stosl>:
{
80105084:	55                   	push   %ebp
80105085:	89 e5                	mov    %esp,%ebp
80105087:	57                   	push   %edi
80105088:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105089:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010508c:	8b 55 10             	mov    0x10(%ebp),%edx
8010508f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105092:	89 cb                	mov    %ecx,%ebx
80105094:	89 df                	mov    %ebx,%edi
80105096:	89 d1                	mov    %edx,%ecx
80105098:	fc                   	cld
80105099:	f3 ab                	rep stos %eax,%es:(%edi)
8010509b:	89 ca                	mov    %ecx,%edx
8010509d:	89 fb                	mov    %edi,%ebx
8010509f:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050a2:	89 55 10             	mov    %edx,0x10(%ebp)
}
801050a5:	90                   	nop
801050a6:	5b                   	pop    %ebx
801050a7:	5f                   	pop    %edi
801050a8:	5d                   	pop    %ebp
801050a9:	c3                   	ret

801050aa <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801050aa:	55                   	push   %ebp
801050ab:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801050ad:	8b 45 08             	mov    0x8(%ebp),%eax
801050b0:	83 e0 03             	and    $0x3,%eax
801050b3:	85 c0                	test   %eax,%eax
801050b5:	75 43                	jne    801050fa <memset+0x50>
801050b7:	8b 45 10             	mov    0x10(%ebp),%eax
801050ba:	83 e0 03             	and    $0x3,%eax
801050bd:	85 c0                	test   %eax,%eax
801050bf:	75 39                	jne    801050fa <memset+0x50>
    c &= 0xFF;
801050c1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801050c8:	8b 45 10             	mov    0x10(%ebp),%eax
801050cb:	c1 e8 02             	shr    $0x2,%eax
801050ce:	89 c1                	mov    %eax,%ecx
801050d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d3:	c1 e0 18             	shl    $0x18,%eax
801050d6:	89 c2                	mov    %eax,%edx
801050d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801050db:	c1 e0 10             	shl    $0x10,%eax
801050de:	09 c2                	or     %eax,%edx
801050e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801050e3:	c1 e0 08             	shl    $0x8,%eax
801050e6:	09 d0                	or     %edx,%eax
801050e8:	0b 45 0c             	or     0xc(%ebp),%eax
801050eb:	51                   	push   %ecx
801050ec:	50                   	push   %eax
801050ed:	ff 75 08             	push   0x8(%ebp)
801050f0:	e8 8f ff ff ff       	call   80105084 <stosl>
801050f5:	83 c4 0c             	add    $0xc,%esp
801050f8:	eb 12                	jmp    8010510c <memset+0x62>
  } else
    stosb(dst, c, n);
801050fa:	8b 45 10             	mov    0x10(%ebp),%eax
801050fd:	50                   	push   %eax
801050fe:	ff 75 0c             	push   0xc(%ebp)
80105101:	ff 75 08             	push   0x8(%ebp)
80105104:	e8 55 ff ff ff       	call   8010505e <stosb>
80105109:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010510c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010510f:	c9                   	leave
80105110:	c3                   	ret

80105111 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105111:	55                   	push   %ebp
80105112:	89 e5                	mov    %esp,%ebp
80105114:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105117:	8b 45 08             	mov    0x8(%ebp),%eax
8010511a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010511d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105120:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105123:	eb 2e                	jmp    80105153 <memcmp+0x42>
    if(*s1 != *s2)
80105125:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105128:	0f b6 10             	movzbl (%eax),%edx
8010512b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010512e:	0f b6 00             	movzbl (%eax),%eax
80105131:	38 c2                	cmp    %al,%dl
80105133:	74 16                	je     8010514b <memcmp+0x3a>
      return *s1 - *s2;
80105135:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105138:	0f b6 00             	movzbl (%eax),%eax
8010513b:	0f b6 d0             	movzbl %al,%edx
8010513e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105141:	0f b6 00             	movzbl (%eax),%eax
80105144:	0f b6 c0             	movzbl %al,%eax
80105147:	29 c2                	sub    %eax,%edx
80105149:	eb 1a                	jmp    80105165 <memcmp+0x54>
    s1++, s2++;
8010514b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010514f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105153:	8b 45 10             	mov    0x10(%ebp),%eax
80105156:	8d 50 ff             	lea    -0x1(%eax),%edx
80105159:	89 55 10             	mov    %edx,0x10(%ebp)
8010515c:	85 c0                	test   %eax,%eax
8010515e:	75 c5                	jne    80105125 <memcmp+0x14>
  }

  return 0;
80105160:	ba 00 00 00 00       	mov    $0x0,%edx
}
80105165:	89 d0                	mov    %edx,%eax
80105167:	c9                   	leave
80105168:	c3                   	ret

80105169 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105169:	55                   	push   %ebp
8010516a:	89 e5                	mov    %esp,%ebp
8010516c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010516f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105172:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105175:	8b 45 08             	mov    0x8(%ebp),%eax
80105178:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010517b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010517e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105181:	73 54                	jae    801051d7 <memmove+0x6e>
80105183:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105186:	8b 45 10             	mov    0x10(%ebp),%eax
80105189:	01 d0                	add    %edx,%eax
8010518b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010518e:	73 47                	jae    801051d7 <memmove+0x6e>
    s += n;
80105190:	8b 45 10             	mov    0x10(%ebp),%eax
80105193:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105196:	8b 45 10             	mov    0x10(%ebp),%eax
80105199:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010519c:	eb 13                	jmp    801051b1 <memmove+0x48>
      *--d = *--s;
8010519e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801051a2:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801051a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051a9:	0f b6 10             	movzbl (%eax),%edx
801051ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051af:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801051b1:	8b 45 10             	mov    0x10(%ebp),%eax
801051b4:	8d 50 ff             	lea    -0x1(%eax),%edx
801051b7:	89 55 10             	mov    %edx,0x10(%ebp)
801051ba:	85 c0                	test   %eax,%eax
801051bc:	75 e0                	jne    8010519e <memmove+0x35>
  if(s < d && s + n > d){
801051be:	eb 24                	jmp    801051e4 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801051c0:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051c3:	8d 42 01             	lea    0x1(%edx),%eax
801051c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
801051c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051cc:	8d 48 01             	lea    0x1(%eax),%ecx
801051cf:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801051d2:	0f b6 12             	movzbl (%edx),%edx
801051d5:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801051d7:	8b 45 10             	mov    0x10(%ebp),%eax
801051da:	8d 50 ff             	lea    -0x1(%eax),%edx
801051dd:	89 55 10             	mov    %edx,0x10(%ebp)
801051e0:	85 c0                	test   %eax,%eax
801051e2:	75 dc                	jne    801051c0 <memmove+0x57>

  return dst;
801051e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801051e7:	c9                   	leave
801051e8:	c3                   	ret

801051e9 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801051e9:	55                   	push   %ebp
801051ea:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801051ec:	ff 75 10             	push   0x10(%ebp)
801051ef:	ff 75 0c             	push   0xc(%ebp)
801051f2:	ff 75 08             	push   0x8(%ebp)
801051f5:	e8 6f ff ff ff       	call   80105169 <memmove>
801051fa:	83 c4 0c             	add    $0xc,%esp
}
801051fd:	c9                   	leave
801051fe:	c3                   	ret

801051ff <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801051ff:	55                   	push   %ebp
80105200:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105202:	eb 0c                	jmp    80105210 <strncmp+0x11>
    n--, p++, q++;
80105204:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105208:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010520c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105210:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105214:	74 1a                	je     80105230 <strncmp+0x31>
80105216:	8b 45 08             	mov    0x8(%ebp),%eax
80105219:	0f b6 00             	movzbl (%eax),%eax
8010521c:	84 c0                	test   %al,%al
8010521e:	74 10                	je     80105230 <strncmp+0x31>
80105220:	8b 45 08             	mov    0x8(%ebp),%eax
80105223:	0f b6 10             	movzbl (%eax),%edx
80105226:	8b 45 0c             	mov    0xc(%ebp),%eax
80105229:	0f b6 00             	movzbl (%eax),%eax
8010522c:	38 c2                	cmp    %al,%dl
8010522e:	74 d4                	je     80105204 <strncmp+0x5>
  if(n == 0)
80105230:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105234:	75 07                	jne    8010523d <strncmp+0x3e>
    return 0;
80105236:	ba 00 00 00 00       	mov    $0x0,%edx
8010523b:	eb 14                	jmp    80105251 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
8010523d:	8b 45 08             	mov    0x8(%ebp),%eax
80105240:	0f b6 00             	movzbl (%eax),%eax
80105243:	0f b6 d0             	movzbl %al,%edx
80105246:	8b 45 0c             	mov    0xc(%ebp),%eax
80105249:	0f b6 00             	movzbl (%eax),%eax
8010524c:	0f b6 c0             	movzbl %al,%eax
8010524f:	29 c2                	sub    %eax,%edx
}
80105251:	89 d0                	mov    %edx,%eax
80105253:	5d                   	pop    %ebp
80105254:	c3                   	ret

80105255 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105255:	55                   	push   %ebp
80105256:	89 e5                	mov    %esp,%ebp
80105258:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010525b:	8b 45 08             	mov    0x8(%ebp),%eax
8010525e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105261:	90                   	nop
80105262:	8b 45 10             	mov    0x10(%ebp),%eax
80105265:	8d 50 ff             	lea    -0x1(%eax),%edx
80105268:	89 55 10             	mov    %edx,0x10(%ebp)
8010526b:	85 c0                	test   %eax,%eax
8010526d:	7e 2c                	jle    8010529b <strncpy+0x46>
8010526f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105272:	8d 42 01             	lea    0x1(%edx),%eax
80105275:	89 45 0c             	mov    %eax,0xc(%ebp)
80105278:	8b 45 08             	mov    0x8(%ebp),%eax
8010527b:	8d 48 01             	lea    0x1(%eax),%ecx
8010527e:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105281:	0f b6 12             	movzbl (%edx),%edx
80105284:	88 10                	mov    %dl,(%eax)
80105286:	0f b6 00             	movzbl (%eax),%eax
80105289:	84 c0                	test   %al,%al
8010528b:	75 d5                	jne    80105262 <strncpy+0xd>
    ;
  while(n-- > 0)
8010528d:	eb 0c                	jmp    8010529b <strncpy+0x46>
    *s++ = 0;
8010528f:	8b 45 08             	mov    0x8(%ebp),%eax
80105292:	8d 50 01             	lea    0x1(%eax),%edx
80105295:	89 55 08             	mov    %edx,0x8(%ebp)
80105298:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010529b:	8b 45 10             	mov    0x10(%ebp),%eax
8010529e:	8d 50 ff             	lea    -0x1(%eax),%edx
801052a1:	89 55 10             	mov    %edx,0x10(%ebp)
801052a4:	85 c0                	test   %eax,%eax
801052a6:	7f e7                	jg     8010528f <strncpy+0x3a>
  return os;
801052a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052ab:	c9                   	leave
801052ac:	c3                   	ret

801052ad <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801052ad:	55                   	push   %ebp
801052ae:	89 e5                	mov    %esp,%ebp
801052b0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801052b3:	8b 45 08             	mov    0x8(%ebp),%eax
801052b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801052b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052bd:	7f 05                	jg     801052c4 <safestrcpy+0x17>
    return os;
801052bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052c2:	eb 32                	jmp    801052f6 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801052c4:	90                   	nop
801052c5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801052c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052cd:	7e 1e                	jle    801052ed <safestrcpy+0x40>
801052cf:	8b 55 0c             	mov    0xc(%ebp),%edx
801052d2:	8d 42 01             	lea    0x1(%edx),%eax
801052d5:	89 45 0c             	mov    %eax,0xc(%ebp)
801052d8:	8b 45 08             	mov    0x8(%ebp),%eax
801052db:	8d 48 01             	lea    0x1(%eax),%ecx
801052de:	89 4d 08             	mov    %ecx,0x8(%ebp)
801052e1:	0f b6 12             	movzbl (%edx),%edx
801052e4:	88 10                	mov    %dl,(%eax)
801052e6:	0f b6 00             	movzbl (%eax),%eax
801052e9:	84 c0                	test   %al,%al
801052eb:	75 d8                	jne    801052c5 <safestrcpy+0x18>
    ;
  *s = 0;
801052ed:	8b 45 08             	mov    0x8(%ebp),%eax
801052f0:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801052f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052f6:	c9                   	leave
801052f7:	c3                   	ret

801052f8 <strlen>:

int
strlen(const char *s)
{
801052f8:	55                   	push   %ebp
801052f9:	89 e5                	mov    %esp,%ebp
801052fb:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801052fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105305:	eb 04                	jmp    8010530b <strlen+0x13>
80105307:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010530b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010530e:	8b 45 08             	mov    0x8(%ebp),%eax
80105311:	01 d0                	add    %edx,%eax
80105313:	0f b6 00             	movzbl (%eax),%eax
80105316:	84 c0                	test   %al,%al
80105318:	75 ed                	jne    80105307 <strlen+0xf>
    ;
  return n;
8010531a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010531d:	c9                   	leave
8010531e:	c3                   	ret

8010531f <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010531f:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105323:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105327:	55                   	push   %ebp
  pushl %ebx
80105328:	53                   	push   %ebx
  pushl %esi
80105329:	56                   	push   %esi
  pushl %edi
8010532a:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010532b:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010532d:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010532f:	5f                   	pop    %edi
  popl %esi
80105330:	5e                   	pop    %esi
  popl %ebx
80105331:	5b                   	pop    %ebx
  popl %ebp
80105332:	5d                   	pop    %ebp
  ret
80105333:	c3                   	ret

80105334 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105334:	55                   	push   %ebp
80105335:	89 e5                	mov    %esp,%ebp
80105337:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010533a:	e8 d3 eb ff ff       	call   80103f12 <myproc>
8010533f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105345:	8b 00                	mov    (%eax),%eax
80105347:	39 45 08             	cmp    %eax,0x8(%ebp)
8010534a:	73 0f                	jae    8010535b <fetchint+0x27>
8010534c:	8b 45 08             	mov    0x8(%ebp),%eax
8010534f:	8d 50 04             	lea    0x4(%eax),%edx
80105352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105355:	8b 00                	mov    (%eax),%eax
80105357:	39 d0                	cmp    %edx,%eax
80105359:	73 07                	jae    80105362 <fetchint+0x2e>
    return -1;
8010535b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105360:	eb 0f                	jmp    80105371 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105362:	8b 45 08             	mov    0x8(%ebp),%eax
80105365:	8b 10                	mov    (%eax),%edx
80105367:	8b 45 0c             	mov    0xc(%ebp),%eax
8010536a:	89 10                	mov    %edx,(%eax)
  return 0;
8010536c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105371:	c9                   	leave
80105372:	c3                   	ret

80105373 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105373:	55                   	push   %ebp
80105374:	89 e5                	mov    %esp,%ebp
80105376:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105379:	e8 94 eb ff ff       	call   80103f12 <myproc>
8010537e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105384:	8b 00                	mov    (%eax),%eax
80105386:	39 45 08             	cmp    %eax,0x8(%ebp)
80105389:	72 07                	jb     80105392 <fetchstr+0x1f>
    return -1;
8010538b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105390:	eb 41                	jmp    801053d3 <fetchstr+0x60>
  *pp = (char*)addr;
80105392:	8b 55 08             	mov    0x8(%ebp),%edx
80105395:	8b 45 0c             	mov    0xc(%ebp),%eax
80105398:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010539a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010539d:	8b 00                	mov    (%eax),%eax
8010539f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801053a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053a5:	8b 00                	mov    (%eax),%eax
801053a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053aa:	eb 1a                	jmp    801053c6 <fetchstr+0x53>
    if(*s == 0)
801053ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053af:	0f b6 00             	movzbl (%eax),%eax
801053b2:	84 c0                	test   %al,%al
801053b4:	75 0c                	jne    801053c2 <fetchstr+0x4f>
      return s - *pp;
801053b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b9:	8b 10                	mov    (%eax),%edx
801053bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053be:	29 d0                	sub    %edx,%eax
801053c0:	eb 11                	jmp    801053d3 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
801053c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801053c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801053cc:	72 de                	jb     801053ac <fetchstr+0x39>
  }
  return -1;
801053ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053d3:	c9                   	leave
801053d4:	c3                   	ret

801053d5 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801053d5:	55                   	push   %ebp
801053d6:	89 e5                	mov    %esp,%ebp
801053d8:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801053db:	e8 32 eb ff ff       	call   80103f12 <myproc>
801053e0:	8b 40 18             	mov    0x18(%eax),%eax
801053e3:	8b 40 44             	mov    0x44(%eax),%eax
801053e6:	8b 55 08             	mov    0x8(%ebp),%edx
801053e9:	c1 e2 02             	shl    $0x2,%edx
801053ec:	01 d0                	add    %edx,%eax
801053ee:	83 c0 04             	add    $0x4,%eax
801053f1:	83 ec 08             	sub    $0x8,%esp
801053f4:	ff 75 0c             	push   0xc(%ebp)
801053f7:	50                   	push   %eax
801053f8:	e8 37 ff ff ff       	call   80105334 <fetchint>
801053fd:	83 c4 10             	add    $0x10,%esp
}
80105400:	c9                   	leave
80105401:	c3                   	ret

80105402 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105402:	55                   	push   %ebp
80105403:	89 e5                	mov    %esp,%ebp
80105405:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105408:	e8 05 eb ff ff       	call   80103f12 <myproc>
8010540d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105410:	83 ec 08             	sub    $0x8,%esp
80105413:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105416:	50                   	push   %eax
80105417:	ff 75 08             	push   0x8(%ebp)
8010541a:	e8 b6 ff ff ff       	call   801053d5 <argint>
8010541f:	83 c4 10             	add    $0x10,%esp
80105422:	85 c0                	test   %eax,%eax
80105424:	79 07                	jns    8010542d <argptr+0x2b>
    return -1;
80105426:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010542b:	eb 3b                	jmp    80105468 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010542d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105431:	78 1f                	js     80105452 <argptr+0x50>
80105433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105436:	8b 00                	mov    (%eax),%eax
80105438:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010543b:	39 c2                	cmp    %eax,%edx
8010543d:	73 13                	jae    80105452 <argptr+0x50>
8010543f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105442:	89 c2                	mov    %eax,%edx
80105444:	8b 45 10             	mov    0x10(%ebp),%eax
80105447:	01 c2                	add    %eax,%edx
80105449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544c:	8b 00                	mov    (%eax),%eax
8010544e:	39 d0                	cmp    %edx,%eax
80105450:	73 07                	jae    80105459 <argptr+0x57>
    return -1;
80105452:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105457:	eb 0f                	jmp    80105468 <argptr+0x66>
  *pp = (char*)i;
80105459:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010545c:	89 c2                	mov    %eax,%edx
8010545e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105461:	89 10                	mov    %edx,(%eax)
  return 0;
80105463:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105468:	c9                   	leave
80105469:	c3                   	ret

8010546a <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010546a:	55                   	push   %ebp
8010546b:	89 e5                	mov    %esp,%ebp
8010546d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105470:	83 ec 08             	sub    $0x8,%esp
80105473:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105476:	50                   	push   %eax
80105477:	ff 75 08             	push   0x8(%ebp)
8010547a:	e8 56 ff ff ff       	call   801053d5 <argint>
8010547f:	83 c4 10             	add    $0x10,%esp
80105482:	85 c0                	test   %eax,%eax
80105484:	79 07                	jns    8010548d <argstr+0x23>
    return -1;
80105486:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010548b:	eb 12                	jmp    8010549f <argstr+0x35>
  return fetchstr(addr, pp);
8010548d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105490:	83 ec 08             	sub    $0x8,%esp
80105493:	ff 75 0c             	push   0xc(%ebp)
80105496:	50                   	push   %eax
80105497:	e8 d7 fe ff ff       	call   80105373 <fetchstr>
8010549c:	83 c4 10             	add    $0x10,%esp
}
8010549f:	c9                   	leave
801054a0:	c3                   	ret

801054a1 <syscall>:
[SYS_exit2]   sys_exit2,
};

void
syscall(void)
{
801054a1:	55                   	push   %ebp
801054a2:	89 e5                	mov    %esp,%ebp
801054a4:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801054a7:	e8 66 ea ff ff       	call   80103f12 <myproc>
801054ac:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801054af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b2:	8b 40 18             	mov    0x18(%eax),%eax
801054b5:	8b 40 1c             	mov    0x1c(%eax),%eax
801054b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801054bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054bf:	7e 2f                	jle    801054f0 <syscall+0x4f>
801054c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c4:	83 f8 17             	cmp    $0x17,%eax
801054c7:	77 27                	ja     801054f0 <syscall+0x4f>
801054c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054cc:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801054d3:	85 c0                	test   %eax,%eax
801054d5:	74 19                	je     801054f0 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801054d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054da:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801054e1:	ff d0                	call   *%eax
801054e3:	89 c2                	mov    %eax,%edx
801054e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054e8:	8b 40 18             	mov    0x18(%eax),%eax
801054eb:	89 50 1c             	mov    %edx,0x1c(%eax)
801054ee:	eb 2c                	jmp    8010551c <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801054f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f3:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801054f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f9:	8b 40 10             	mov    0x10(%eax),%eax
801054fc:	ff 75 f0             	push   -0x10(%ebp)
801054ff:	52                   	push   %edx
80105500:	50                   	push   %eax
80105501:	68 3c aa 10 80       	push   $0x8010aa3c
80105506:	e8 e9 ae ff ff       	call   801003f4 <cprintf>
8010550b:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
8010550e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105511:	8b 40 18             	mov    0x18(%eax),%eax
80105514:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010551b:	90                   	nop
8010551c:	90                   	nop
8010551d:	c9                   	leave
8010551e:	c3                   	ret

8010551f <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010551f:	55                   	push   %ebp
80105520:	89 e5                	mov    %esp,%ebp
80105522:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105525:	83 ec 08             	sub    $0x8,%esp
80105528:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010552b:	50                   	push   %eax
8010552c:	ff 75 08             	push   0x8(%ebp)
8010552f:	e8 a1 fe ff ff       	call   801053d5 <argint>
80105534:	83 c4 10             	add    $0x10,%esp
80105537:	85 c0                	test   %eax,%eax
80105539:	79 07                	jns    80105542 <argfd+0x23>
    return -1;
8010553b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105540:	eb 4f                	jmp    80105591 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105542:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105545:	85 c0                	test   %eax,%eax
80105547:	78 20                	js     80105569 <argfd+0x4a>
80105549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010554c:	83 f8 0f             	cmp    $0xf,%eax
8010554f:	7f 18                	jg     80105569 <argfd+0x4a>
80105551:	e8 bc e9 ff ff       	call   80103f12 <myproc>
80105556:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105559:	83 c2 08             	add    $0x8,%edx
8010555c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105560:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105563:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105567:	75 07                	jne    80105570 <argfd+0x51>
    return -1;
80105569:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556e:	eb 21                	jmp    80105591 <argfd+0x72>
  if(pfd)
80105570:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105574:	74 08                	je     8010557e <argfd+0x5f>
    *pfd = fd;
80105576:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105579:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557c:	89 10                	mov    %edx,(%eax)
  if(pf)
8010557e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105582:	74 08                	je     8010558c <argfd+0x6d>
    *pf = f;
80105584:	8b 45 10             	mov    0x10(%ebp),%eax
80105587:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010558a:	89 10                	mov    %edx,(%eax)
  return 0;
8010558c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105591:	c9                   	leave
80105592:	c3                   	ret

80105593 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105593:	55                   	push   %ebp
80105594:	89 e5                	mov    %esp,%ebp
80105596:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105599:	e8 74 e9 ff ff       	call   80103f12 <myproc>
8010559e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801055a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801055a8:	eb 2a                	jmp    801055d4 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
801055aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055b0:	83 c2 08             	add    $0x8,%edx
801055b3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801055b7:	85 c0                	test   %eax,%eax
801055b9:	75 15                	jne    801055d0 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801055bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055c1:	8d 4a 08             	lea    0x8(%edx),%ecx
801055c4:	8b 55 08             	mov    0x8(%ebp),%edx
801055c7:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801055cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ce:	eb 0f                	jmp    801055df <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801055d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801055d4:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801055d8:	7e d0                	jle    801055aa <fdalloc+0x17>
    }
  }
  return -1;
801055da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055df:	c9                   	leave
801055e0:	c3                   	ret

801055e1 <sys_dup>:

int
sys_dup(void)
{
801055e1:	55                   	push   %ebp
801055e2:	89 e5                	mov    %esp,%ebp
801055e4:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801055e7:	83 ec 04             	sub    $0x4,%esp
801055ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055ed:	50                   	push   %eax
801055ee:	6a 00                	push   $0x0
801055f0:	6a 00                	push   $0x0
801055f2:	e8 28 ff ff ff       	call   8010551f <argfd>
801055f7:	83 c4 10             	add    $0x10,%esp
801055fa:	85 c0                	test   %eax,%eax
801055fc:	79 07                	jns    80105605 <sys_dup+0x24>
    return -1;
801055fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105603:	eb 31                	jmp    80105636 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105605:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105608:	83 ec 0c             	sub    $0xc,%esp
8010560b:	50                   	push   %eax
8010560c:	e8 82 ff ff ff       	call   80105593 <fdalloc>
80105611:	83 c4 10             	add    $0x10,%esp
80105614:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105617:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010561b:	79 07                	jns    80105624 <sys_dup+0x43>
    return -1;
8010561d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105622:	eb 12                	jmp    80105636 <sys_dup+0x55>
  filedup(f);
80105624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105627:	83 ec 0c             	sub    $0xc,%esp
8010562a:	50                   	push   %eax
8010562b:	e8 24 ba ff ff       	call   80101054 <filedup>
80105630:	83 c4 10             	add    $0x10,%esp
  return fd;
80105633:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105636:	c9                   	leave
80105637:	c3                   	ret

80105638 <sys_read>:

int
sys_read(void)
{
80105638:	55                   	push   %ebp
80105639:	89 e5                	mov    %esp,%ebp
8010563b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010563e:	83 ec 04             	sub    $0x4,%esp
80105641:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105644:	50                   	push   %eax
80105645:	6a 00                	push   $0x0
80105647:	6a 00                	push   $0x0
80105649:	e8 d1 fe ff ff       	call   8010551f <argfd>
8010564e:	83 c4 10             	add    $0x10,%esp
80105651:	85 c0                	test   %eax,%eax
80105653:	78 2e                	js     80105683 <sys_read+0x4b>
80105655:	83 ec 08             	sub    $0x8,%esp
80105658:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010565b:	50                   	push   %eax
8010565c:	6a 02                	push   $0x2
8010565e:	e8 72 fd ff ff       	call   801053d5 <argint>
80105663:	83 c4 10             	add    $0x10,%esp
80105666:	85 c0                	test   %eax,%eax
80105668:	78 19                	js     80105683 <sys_read+0x4b>
8010566a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010566d:	83 ec 04             	sub    $0x4,%esp
80105670:	50                   	push   %eax
80105671:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105674:	50                   	push   %eax
80105675:	6a 01                	push   $0x1
80105677:	e8 86 fd ff ff       	call   80105402 <argptr>
8010567c:	83 c4 10             	add    $0x10,%esp
8010567f:	85 c0                	test   %eax,%eax
80105681:	79 07                	jns    8010568a <sys_read+0x52>
    return -1;
80105683:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105688:	eb 17                	jmp    801056a1 <sys_read+0x69>
  return fileread(f, p, n);
8010568a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010568d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105693:	83 ec 04             	sub    $0x4,%esp
80105696:	51                   	push   %ecx
80105697:	52                   	push   %edx
80105698:	50                   	push   %eax
80105699:	e8 46 bb ff ff       	call   801011e4 <fileread>
8010569e:	83 c4 10             	add    $0x10,%esp
}
801056a1:	c9                   	leave
801056a2:	c3                   	ret

801056a3 <sys_write>:

int
sys_write(void)
{
801056a3:	55                   	push   %ebp
801056a4:	89 e5                	mov    %esp,%ebp
801056a6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801056a9:	83 ec 04             	sub    $0x4,%esp
801056ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056af:	50                   	push   %eax
801056b0:	6a 00                	push   $0x0
801056b2:	6a 00                	push   $0x0
801056b4:	e8 66 fe ff ff       	call   8010551f <argfd>
801056b9:	83 c4 10             	add    $0x10,%esp
801056bc:	85 c0                	test   %eax,%eax
801056be:	78 2e                	js     801056ee <sys_write+0x4b>
801056c0:	83 ec 08             	sub    $0x8,%esp
801056c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056c6:	50                   	push   %eax
801056c7:	6a 02                	push   $0x2
801056c9:	e8 07 fd ff ff       	call   801053d5 <argint>
801056ce:	83 c4 10             	add    $0x10,%esp
801056d1:	85 c0                	test   %eax,%eax
801056d3:	78 19                	js     801056ee <sys_write+0x4b>
801056d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056d8:	83 ec 04             	sub    $0x4,%esp
801056db:	50                   	push   %eax
801056dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056df:	50                   	push   %eax
801056e0:	6a 01                	push   $0x1
801056e2:	e8 1b fd ff ff       	call   80105402 <argptr>
801056e7:	83 c4 10             	add    $0x10,%esp
801056ea:	85 c0                	test   %eax,%eax
801056ec:	79 07                	jns    801056f5 <sys_write+0x52>
    return -1;
801056ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f3:	eb 17                	jmp    8010570c <sys_write+0x69>
  return filewrite(f, p, n);
801056f5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801056f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801056fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fe:	83 ec 04             	sub    $0x4,%esp
80105701:	51                   	push   %ecx
80105702:	52                   	push   %edx
80105703:	50                   	push   %eax
80105704:	e8 93 bb ff ff       	call   8010129c <filewrite>
80105709:	83 c4 10             	add    $0x10,%esp
}
8010570c:	c9                   	leave
8010570d:	c3                   	ret

8010570e <sys_close>:

int
sys_close(void)
{
8010570e:	55                   	push   %ebp
8010570f:	89 e5                	mov    %esp,%ebp
80105711:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105714:	83 ec 04             	sub    $0x4,%esp
80105717:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010571a:	50                   	push   %eax
8010571b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010571e:	50                   	push   %eax
8010571f:	6a 00                	push   $0x0
80105721:	e8 f9 fd ff ff       	call   8010551f <argfd>
80105726:	83 c4 10             	add    $0x10,%esp
80105729:	85 c0                	test   %eax,%eax
8010572b:	79 07                	jns    80105734 <sys_close+0x26>
    return -1;
8010572d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105732:	eb 27                	jmp    8010575b <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105734:	e8 d9 e7 ff ff       	call   80103f12 <myproc>
80105739:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010573c:	83 c2 08             	add    $0x8,%edx
8010573f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105746:	00 
  fileclose(f);
80105747:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010574a:	83 ec 0c             	sub    $0xc,%esp
8010574d:	50                   	push   %eax
8010574e:	e8 52 b9 ff ff       	call   801010a5 <fileclose>
80105753:	83 c4 10             	add    $0x10,%esp
  return 0;
80105756:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010575b:	c9                   	leave
8010575c:	c3                   	ret

8010575d <sys_fstat>:

int
sys_fstat(void)
{
8010575d:	55                   	push   %ebp
8010575e:	89 e5                	mov    %esp,%ebp
80105760:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105763:	83 ec 04             	sub    $0x4,%esp
80105766:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105769:	50                   	push   %eax
8010576a:	6a 00                	push   $0x0
8010576c:	6a 00                	push   $0x0
8010576e:	e8 ac fd ff ff       	call   8010551f <argfd>
80105773:	83 c4 10             	add    $0x10,%esp
80105776:	85 c0                	test   %eax,%eax
80105778:	78 17                	js     80105791 <sys_fstat+0x34>
8010577a:	83 ec 04             	sub    $0x4,%esp
8010577d:	6a 14                	push   $0x14
8010577f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105782:	50                   	push   %eax
80105783:	6a 01                	push   $0x1
80105785:	e8 78 fc ff ff       	call   80105402 <argptr>
8010578a:	83 c4 10             	add    $0x10,%esp
8010578d:	85 c0                	test   %eax,%eax
8010578f:	79 07                	jns    80105798 <sys_fstat+0x3b>
    return -1;
80105791:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105796:	eb 13                	jmp    801057ab <sys_fstat+0x4e>
  return filestat(f, st);
80105798:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010579b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579e:	83 ec 08             	sub    $0x8,%esp
801057a1:	52                   	push   %edx
801057a2:	50                   	push   %eax
801057a3:	e8 e5 b9 ff ff       	call   8010118d <filestat>
801057a8:	83 c4 10             	add    $0x10,%esp
}
801057ab:	c9                   	leave
801057ac:	c3                   	ret

801057ad <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801057ad:	55                   	push   %ebp
801057ae:	89 e5                	mov    %esp,%ebp
801057b0:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801057b3:	83 ec 08             	sub    $0x8,%esp
801057b6:	8d 45 d8             	lea    -0x28(%ebp),%eax
801057b9:	50                   	push   %eax
801057ba:	6a 00                	push   $0x0
801057bc:	e8 a9 fc ff ff       	call   8010546a <argstr>
801057c1:	83 c4 10             	add    $0x10,%esp
801057c4:	85 c0                	test   %eax,%eax
801057c6:	78 15                	js     801057dd <sys_link+0x30>
801057c8:	83 ec 08             	sub    $0x8,%esp
801057cb:	8d 45 dc             	lea    -0x24(%ebp),%eax
801057ce:	50                   	push   %eax
801057cf:	6a 01                	push   $0x1
801057d1:	e8 94 fc ff ff       	call   8010546a <argstr>
801057d6:	83 c4 10             	add    $0x10,%esp
801057d9:	85 c0                	test   %eax,%eax
801057db:	79 0a                	jns    801057e7 <sys_link+0x3a>
    return -1;
801057dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e2:	e9 68 01 00 00       	jmp    8010594f <sys_link+0x1a2>

  begin_op();
801057e7:	e8 34 dd ff ff       	call   80103520 <begin_op>
  if((ip = namei(old)) == 0){
801057ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
801057ef:	83 ec 0c             	sub    $0xc,%esp
801057f2:	50                   	push   %eax
801057f3:	e8 2d cd ff ff       	call   80102525 <namei>
801057f8:	83 c4 10             	add    $0x10,%esp
801057fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105802:	75 0f                	jne    80105813 <sys_link+0x66>
    end_op();
80105804:	e8 a3 dd ff ff       	call   801035ac <end_op>
    return -1;
80105809:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010580e:	e9 3c 01 00 00       	jmp    8010594f <sys_link+0x1a2>
  }

  ilock(ip);
80105813:	83 ec 0c             	sub    $0xc,%esp
80105816:	ff 75 f4             	push   -0xc(%ebp)
80105819:	e8 d4 c1 ff ff       	call   801019f2 <ilock>
8010581e:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105824:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105828:	66 83 f8 01          	cmp    $0x1,%ax
8010582c:	75 1d                	jne    8010584b <sys_link+0x9e>
    iunlockput(ip);
8010582e:	83 ec 0c             	sub    $0xc,%esp
80105831:	ff 75 f4             	push   -0xc(%ebp)
80105834:	e8 ea c3 ff ff       	call   80101c23 <iunlockput>
80105839:	83 c4 10             	add    $0x10,%esp
    end_op();
8010583c:	e8 6b dd ff ff       	call   801035ac <end_op>
    return -1;
80105841:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105846:	e9 04 01 00 00       	jmp    8010594f <sys_link+0x1a2>
  }

  ip->nlink++;
8010584b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010584e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105852:	83 c0 01             	add    $0x1,%eax
80105855:	89 c2                	mov    %eax,%edx
80105857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010585e:	83 ec 0c             	sub    $0xc,%esp
80105861:	ff 75 f4             	push   -0xc(%ebp)
80105864:	e8 ac bf ff ff       	call   80101815 <iupdate>
80105869:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010586c:	83 ec 0c             	sub    $0xc,%esp
8010586f:	ff 75 f4             	push   -0xc(%ebp)
80105872:	e8 8e c2 ff ff       	call   80101b05 <iunlock>
80105877:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010587a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010587d:	83 ec 08             	sub    $0x8,%esp
80105880:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105883:	52                   	push   %edx
80105884:	50                   	push   %eax
80105885:	e8 b7 cc ff ff       	call   80102541 <nameiparent>
8010588a:	83 c4 10             	add    $0x10,%esp
8010588d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105894:	74 71                	je     80105907 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105896:	83 ec 0c             	sub    $0xc,%esp
80105899:	ff 75 f0             	push   -0x10(%ebp)
8010589c:	e8 51 c1 ff ff       	call   801019f2 <ilock>
801058a1:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801058a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a7:	8b 10                	mov    (%eax),%edx
801058a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ac:	8b 00                	mov    (%eax),%eax
801058ae:	39 c2                	cmp    %eax,%edx
801058b0:	75 1d                	jne    801058cf <sys_link+0x122>
801058b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b5:	8b 40 04             	mov    0x4(%eax),%eax
801058b8:	83 ec 04             	sub    $0x4,%esp
801058bb:	50                   	push   %eax
801058bc:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801058bf:	50                   	push   %eax
801058c0:	ff 75 f0             	push   -0x10(%ebp)
801058c3:	e8 c6 c9 ff ff       	call   8010228e <dirlink>
801058c8:	83 c4 10             	add    $0x10,%esp
801058cb:	85 c0                	test   %eax,%eax
801058cd:	79 10                	jns    801058df <sys_link+0x132>
    iunlockput(dp);
801058cf:	83 ec 0c             	sub    $0xc,%esp
801058d2:	ff 75 f0             	push   -0x10(%ebp)
801058d5:	e8 49 c3 ff ff       	call   80101c23 <iunlockput>
801058da:	83 c4 10             	add    $0x10,%esp
    goto bad;
801058dd:	eb 29                	jmp    80105908 <sys_link+0x15b>
  }
  iunlockput(dp);
801058df:	83 ec 0c             	sub    $0xc,%esp
801058e2:	ff 75 f0             	push   -0x10(%ebp)
801058e5:	e8 39 c3 ff ff       	call   80101c23 <iunlockput>
801058ea:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801058ed:	83 ec 0c             	sub    $0xc,%esp
801058f0:	ff 75 f4             	push   -0xc(%ebp)
801058f3:	e8 5b c2 ff ff       	call   80101b53 <iput>
801058f8:	83 c4 10             	add    $0x10,%esp

  end_op();
801058fb:	e8 ac dc ff ff       	call   801035ac <end_op>

  return 0;
80105900:	b8 00 00 00 00       	mov    $0x0,%eax
80105905:	eb 48                	jmp    8010594f <sys_link+0x1a2>
    goto bad;
80105907:	90                   	nop

bad:
  ilock(ip);
80105908:	83 ec 0c             	sub    $0xc,%esp
8010590b:	ff 75 f4             	push   -0xc(%ebp)
8010590e:	e8 df c0 ff ff       	call   801019f2 <ilock>
80105913:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105919:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010591d:	83 e8 01             	sub    $0x1,%eax
80105920:	89 c2                	mov    %eax,%edx
80105922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105925:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105929:	83 ec 0c             	sub    $0xc,%esp
8010592c:	ff 75 f4             	push   -0xc(%ebp)
8010592f:	e8 e1 be ff ff       	call   80101815 <iupdate>
80105934:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105937:	83 ec 0c             	sub    $0xc,%esp
8010593a:	ff 75 f4             	push   -0xc(%ebp)
8010593d:	e8 e1 c2 ff ff       	call   80101c23 <iunlockput>
80105942:	83 c4 10             	add    $0x10,%esp
  end_op();
80105945:	e8 62 dc ff ff       	call   801035ac <end_op>
  return -1;
8010594a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010594f:	c9                   	leave
80105950:	c3                   	ret

80105951 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105951:	55                   	push   %ebp
80105952:	89 e5                	mov    %esp,%ebp
80105954:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105957:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010595e:	eb 40                	jmp    801059a0 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105963:	6a 10                	push   $0x10
80105965:	50                   	push   %eax
80105966:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105969:	50                   	push   %eax
8010596a:	ff 75 08             	push   0x8(%ebp)
8010596d:	e8 6c c5 ff ff       	call   80101ede <readi>
80105972:	83 c4 10             	add    $0x10,%esp
80105975:	83 f8 10             	cmp    $0x10,%eax
80105978:	74 0d                	je     80105987 <isdirempty+0x36>
      panic("isdirempty: readi");
8010597a:	83 ec 0c             	sub    $0xc,%esp
8010597d:	68 58 aa 10 80       	push   $0x8010aa58
80105982:	e8 22 ac ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105987:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010598b:	66 85 c0             	test   %ax,%ax
8010598e:	74 07                	je     80105997 <isdirempty+0x46>
      return 0;
80105990:	b8 00 00 00 00       	mov    $0x0,%eax
80105995:	eb 1b                	jmp    801059b2 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599a:	83 c0 10             	add    $0x10,%eax
8010599d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059a0:	8b 45 08             	mov    0x8(%ebp),%eax
801059a3:	8b 40 58             	mov    0x58(%eax),%eax
801059a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059a9:	39 c2                	cmp    %eax,%edx
801059ab:	72 b3                	jb     80105960 <isdirempty+0xf>
  }
  return 1;
801059ad:	b8 01 00 00 00       	mov    $0x1,%eax
}
801059b2:	c9                   	leave
801059b3:	c3                   	ret

801059b4 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801059b4:	55                   	push   %ebp
801059b5:	89 e5                	mov    %esp,%ebp
801059b7:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801059ba:	83 ec 08             	sub    $0x8,%esp
801059bd:	8d 45 cc             	lea    -0x34(%ebp),%eax
801059c0:	50                   	push   %eax
801059c1:	6a 00                	push   $0x0
801059c3:	e8 a2 fa ff ff       	call   8010546a <argstr>
801059c8:	83 c4 10             	add    $0x10,%esp
801059cb:	85 c0                	test   %eax,%eax
801059cd:	79 0a                	jns    801059d9 <sys_unlink+0x25>
    return -1;
801059cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d4:	e9 bf 01 00 00       	jmp    80105b98 <sys_unlink+0x1e4>

  begin_op();
801059d9:	e8 42 db ff ff       	call   80103520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801059de:	8b 45 cc             	mov    -0x34(%ebp),%eax
801059e1:	83 ec 08             	sub    $0x8,%esp
801059e4:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801059e7:	52                   	push   %edx
801059e8:	50                   	push   %eax
801059e9:	e8 53 cb ff ff       	call   80102541 <nameiparent>
801059ee:	83 c4 10             	add    $0x10,%esp
801059f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059f8:	75 0f                	jne    80105a09 <sys_unlink+0x55>
    end_op();
801059fa:	e8 ad db ff ff       	call   801035ac <end_op>
    return -1;
801059ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a04:	e9 8f 01 00 00       	jmp    80105b98 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105a09:	83 ec 0c             	sub    $0xc,%esp
80105a0c:	ff 75 f4             	push   -0xc(%ebp)
80105a0f:	e8 de bf ff ff       	call   801019f2 <ilock>
80105a14:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105a17:	83 ec 08             	sub    $0x8,%esp
80105a1a:	68 6a aa 10 80       	push   $0x8010aa6a
80105a1f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a22:	50                   	push   %eax
80105a23:	e8 91 c7 ff ff       	call   801021b9 <namecmp>
80105a28:	83 c4 10             	add    $0x10,%esp
80105a2b:	85 c0                	test   %eax,%eax
80105a2d:	0f 84 49 01 00 00    	je     80105b7c <sys_unlink+0x1c8>
80105a33:	83 ec 08             	sub    $0x8,%esp
80105a36:	68 6c aa 10 80       	push   $0x8010aa6c
80105a3b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a3e:	50                   	push   %eax
80105a3f:	e8 75 c7 ff ff       	call   801021b9 <namecmp>
80105a44:	83 c4 10             	add    $0x10,%esp
80105a47:	85 c0                	test   %eax,%eax
80105a49:	0f 84 2d 01 00 00    	je     80105b7c <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105a4f:	83 ec 04             	sub    $0x4,%esp
80105a52:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105a55:	50                   	push   %eax
80105a56:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a59:	50                   	push   %eax
80105a5a:	ff 75 f4             	push   -0xc(%ebp)
80105a5d:	e8 72 c7 ff ff       	call   801021d4 <dirlookup>
80105a62:	83 c4 10             	add    $0x10,%esp
80105a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a68:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a6c:	0f 84 0d 01 00 00    	je     80105b7f <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105a72:	83 ec 0c             	sub    $0xc,%esp
80105a75:	ff 75 f0             	push   -0x10(%ebp)
80105a78:	e8 75 bf ff ff       	call   801019f2 <ilock>
80105a7d:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a83:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a87:	66 85 c0             	test   %ax,%ax
80105a8a:	7f 0d                	jg     80105a99 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105a8c:	83 ec 0c             	sub    $0xc,%esp
80105a8f:	68 6f aa 10 80       	push   $0x8010aa6f
80105a94:	e8 10 ab ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a9c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105aa0:	66 83 f8 01          	cmp    $0x1,%ax
80105aa4:	75 25                	jne    80105acb <sys_unlink+0x117>
80105aa6:	83 ec 0c             	sub    $0xc,%esp
80105aa9:	ff 75 f0             	push   -0x10(%ebp)
80105aac:	e8 a0 fe ff ff       	call   80105951 <isdirempty>
80105ab1:	83 c4 10             	add    $0x10,%esp
80105ab4:	85 c0                	test   %eax,%eax
80105ab6:	75 13                	jne    80105acb <sys_unlink+0x117>
    iunlockput(ip);
80105ab8:	83 ec 0c             	sub    $0xc,%esp
80105abb:	ff 75 f0             	push   -0x10(%ebp)
80105abe:	e8 60 c1 ff ff       	call   80101c23 <iunlockput>
80105ac3:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ac6:	e9 b5 00 00 00       	jmp    80105b80 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105acb:	83 ec 04             	sub    $0x4,%esp
80105ace:	6a 10                	push   $0x10
80105ad0:	6a 00                	push   $0x0
80105ad2:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ad5:	50                   	push   %eax
80105ad6:	e8 cf f5 ff ff       	call   801050aa <memset>
80105adb:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ade:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ae1:	6a 10                	push   $0x10
80105ae3:	50                   	push   %eax
80105ae4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ae7:	50                   	push   %eax
80105ae8:	ff 75 f4             	push   -0xc(%ebp)
80105aeb:	e8 43 c5 ff ff       	call   80102033 <writei>
80105af0:	83 c4 10             	add    $0x10,%esp
80105af3:	83 f8 10             	cmp    $0x10,%eax
80105af6:	74 0d                	je     80105b05 <sys_unlink+0x151>
    panic("unlink: writei");
80105af8:	83 ec 0c             	sub    $0xc,%esp
80105afb:	68 81 aa 10 80       	push   $0x8010aa81
80105b00:	e8 a4 aa ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
80105b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b08:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b0c:	66 83 f8 01          	cmp    $0x1,%ax
80105b10:	75 21                	jne    80105b33 <sys_unlink+0x17f>
    dp->nlink--;
80105b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b15:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b19:	83 e8 01             	sub    $0x1,%eax
80105b1c:	89 c2                	mov    %eax,%edx
80105b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b21:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105b25:	83 ec 0c             	sub    $0xc,%esp
80105b28:	ff 75 f4             	push   -0xc(%ebp)
80105b2b:	e8 e5 bc ff ff       	call   80101815 <iupdate>
80105b30:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105b33:	83 ec 0c             	sub    $0xc,%esp
80105b36:	ff 75 f4             	push   -0xc(%ebp)
80105b39:	e8 e5 c0 ff ff       	call   80101c23 <iunlockput>
80105b3e:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b44:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b48:	83 e8 01             	sub    $0x1,%eax
80105b4b:	89 c2                	mov    %eax,%edx
80105b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b50:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b54:	83 ec 0c             	sub    $0xc,%esp
80105b57:	ff 75 f0             	push   -0x10(%ebp)
80105b5a:	e8 b6 bc ff ff       	call   80101815 <iupdate>
80105b5f:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b62:	83 ec 0c             	sub    $0xc,%esp
80105b65:	ff 75 f0             	push   -0x10(%ebp)
80105b68:	e8 b6 c0 ff ff       	call   80101c23 <iunlockput>
80105b6d:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b70:	e8 37 da ff ff       	call   801035ac <end_op>

  return 0;
80105b75:	b8 00 00 00 00       	mov    $0x0,%eax
80105b7a:	eb 1c                	jmp    80105b98 <sys_unlink+0x1e4>
    goto bad;
80105b7c:	90                   	nop
80105b7d:	eb 01                	jmp    80105b80 <sys_unlink+0x1cc>
    goto bad;
80105b7f:	90                   	nop

bad:
  iunlockput(dp);
80105b80:	83 ec 0c             	sub    $0xc,%esp
80105b83:	ff 75 f4             	push   -0xc(%ebp)
80105b86:	e8 98 c0 ff ff       	call   80101c23 <iunlockput>
80105b8b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b8e:	e8 19 da ff ff       	call   801035ac <end_op>
  return -1;
80105b93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b98:	c9                   	leave
80105b99:	c3                   	ret

80105b9a <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b9a:	55                   	push   %ebp
80105b9b:	89 e5                	mov    %esp,%ebp
80105b9d:	83 ec 38             	sub    $0x38,%esp
80105ba0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105ba3:	8b 55 10             	mov    0x10(%ebp),%edx
80105ba6:	8b 45 14             	mov    0x14(%ebp),%eax
80105ba9:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105bad:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105bb1:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105bb5:	83 ec 08             	sub    $0x8,%esp
80105bb8:	8d 45 de             	lea    -0x22(%ebp),%eax
80105bbb:	50                   	push   %eax
80105bbc:	ff 75 08             	push   0x8(%ebp)
80105bbf:	e8 7d c9 ff ff       	call   80102541 <nameiparent>
80105bc4:	83 c4 10             	add    $0x10,%esp
80105bc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bce:	75 0a                	jne    80105bda <create+0x40>
    return 0;
80105bd0:	b8 00 00 00 00       	mov    $0x0,%eax
80105bd5:	e9 90 01 00 00       	jmp    80105d6a <create+0x1d0>
  ilock(dp);
80105bda:	83 ec 0c             	sub    $0xc,%esp
80105bdd:	ff 75 f4             	push   -0xc(%ebp)
80105be0:	e8 0d be ff ff       	call   801019f2 <ilock>
80105be5:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105be8:	83 ec 04             	sub    $0x4,%esp
80105beb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bee:	50                   	push   %eax
80105bef:	8d 45 de             	lea    -0x22(%ebp),%eax
80105bf2:	50                   	push   %eax
80105bf3:	ff 75 f4             	push   -0xc(%ebp)
80105bf6:	e8 d9 c5 ff ff       	call   801021d4 <dirlookup>
80105bfb:	83 c4 10             	add    $0x10,%esp
80105bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c01:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c05:	74 50                	je     80105c57 <create+0xbd>
    iunlockput(dp);
80105c07:	83 ec 0c             	sub    $0xc,%esp
80105c0a:	ff 75 f4             	push   -0xc(%ebp)
80105c0d:	e8 11 c0 ff ff       	call   80101c23 <iunlockput>
80105c12:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105c15:	83 ec 0c             	sub    $0xc,%esp
80105c18:	ff 75 f0             	push   -0x10(%ebp)
80105c1b:	e8 d2 bd ff ff       	call   801019f2 <ilock>
80105c20:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105c23:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105c28:	75 15                	jne    80105c3f <create+0xa5>
80105c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c31:	66 83 f8 02          	cmp    $0x2,%ax
80105c35:	75 08                	jne    80105c3f <create+0xa5>
      return ip;
80105c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3a:	e9 2b 01 00 00       	jmp    80105d6a <create+0x1d0>
    iunlockput(ip);
80105c3f:	83 ec 0c             	sub    $0xc,%esp
80105c42:	ff 75 f0             	push   -0x10(%ebp)
80105c45:	e8 d9 bf ff ff       	call   80101c23 <iunlockput>
80105c4a:	83 c4 10             	add    $0x10,%esp
    return 0;
80105c4d:	b8 00 00 00 00       	mov    $0x0,%eax
80105c52:	e9 13 01 00 00       	jmp    80105d6a <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105c57:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5e:	8b 00                	mov    (%eax),%eax
80105c60:	83 ec 08             	sub    $0x8,%esp
80105c63:	52                   	push   %edx
80105c64:	50                   	push   %eax
80105c65:	e8 d5 ba ff ff       	call   8010173f <ialloc>
80105c6a:	83 c4 10             	add    $0x10,%esp
80105c6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c70:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c74:	75 0d                	jne    80105c83 <create+0xe9>
    panic("create: ialloc");
80105c76:	83 ec 0c             	sub    $0xc,%esp
80105c79:	68 90 aa 10 80       	push   $0x8010aa90
80105c7e:	e8 26 a9 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105c83:	83 ec 0c             	sub    $0xc,%esp
80105c86:	ff 75 f0             	push   -0x10(%ebp)
80105c89:	e8 64 bd ff ff       	call   801019f2 <ilock>
80105c8e:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105c91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c94:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105c98:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9f:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105ca3:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105caa:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105cb0:	83 ec 0c             	sub    $0xc,%esp
80105cb3:	ff 75 f0             	push   -0x10(%ebp)
80105cb6:	e8 5a bb ff ff       	call   80101815 <iupdate>
80105cbb:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105cbe:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105cc3:	75 6a                	jne    80105d2f <create+0x195>
    dp->nlink++;  // for ".."
80105cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ccc:	83 c0 01             	add    $0x1,%eax
80105ccf:	89 c2                	mov    %eax,%edx
80105cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd4:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105cd8:	83 ec 0c             	sub    $0xc,%esp
80105cdb:	ff 75 f4             	push   -0xc(%ebp)
80105cde:	e8 32 bb ff ff       	call   80101815 <iupdate>
80105ce3:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce9:	8b 40 04             	mov    0x4(%eax),%eax
80105cec:	83 ec 04             	sub    $0x4,%esp
80105cef:	50                   	push   %eax
80105cf0:	68 6a aa 10 80       	push   $0x8010aa6a
80105cf5:	ff 75 f0             	push   -0x10(%ebp)
80105cf8:	e8 91 c5 ff ff       	call   8010228e <dirlink>
80105cfd:	83 c4 10             	add    $0x10,%esp
80105d00:	85 c0                	test   %eax,%eax
80105d02:	78 1e                	js     80105d22 <create+0x188>
80105d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d07:	8b 40 04             	mov    0x4(%eax),%eax
80105d0a:	83 ec 04             	sub    $0x4,%esp
80105d0d:	50                   	push   %eax
80105d0e:	68 6c aa 10 80       	push   $0x8010aa6c
80105d13:	ff 75 f0             	push   -0x10(%ebp)
80105d16:	e8 73 c5 ff ff       	call   8010228e <dirlink>
80105d1b:	83 c4 10             	add    $0x10,%esp
80105d1e:	85 c0                	test   %eax,%eax
80105d20:	79 0d                	jns    80105d2f <create+0x195>
      panic("create dots");
80105d22:	83 ec 0c             	sub    $0xc,%esp
80105d25:	68 9f aa 10 80       	push   $0x8010aa9f
80105d2a:	e8 7a a8 ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d32:	8b 40 04             	mov    0x4(%eax),%eax
80105d35:	83 ec 04             	sub    $0x4,%esp
80105d38:	50                   	push   %eax
80105d39:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d3c:	50                   	push   %eax
80105d3d:	ff 75 f4             	push   -0xc(%ebp)
80105d40:	e8 49 c5 ff ff       	call   8010228e <dirlink>
80105d45:	83 c4 10             	add    $0x10,%esp
80105d48:	85 c0                	test   %eax,%eax
80105d4a:	79 0d                	jns    80105d59 <create+0x1bf>
    panic("create: dirlink");
80105d4c:	83 ec 0c             	sub    $0xc,%esp
80105d4f:	68 ab aa 10 80       	push   $0x8010aaab
80105d54:	e8 50 a8 ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105d59:	83 ec 0c             	sub    $0xc,%esp
80105d5c:	ff 75 f4             	push   -0xc(%ebp)
80105d5f:	e8 bf be ff ff       	call   80101c23 <iunlockput>
80105d64:	83 c4 10             	add    $0x10,%esp

  return ip;
80105d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105d6a:	c9                   	leave
80105d6b:	c3                   	ret

80105d6c <sys_open>:

int
sys_open(void)
{
80105d6c:	55                   	push   %ebp
80105d6d:	89 e5                	mov    %esp,%ebp
80105d6f:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105d72:	83 ec 08             	sub    $0x8,%esp
80105d75:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d78:	50                   	push   %eax
80105d79:	6a 00                	push   $0x0
80105d7b:	e8 ea f6 ff ff       	call   8010546a <argstr>
80105d80:	83 c4 10             	add    $0x10,%esp
80105d83:	85 c0                	test   %eax,%eax
80105d85:	78 15                	js     80105d9c <sys_open+0x30>
80105d87:	83 ec 08             	sub    $0x8,%esp
80105d8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d8d:	50                   	push   %eax
80105d8e:	6a 01                	push   $0x1
80105d90:	e8 40 f6 ff ff       	call   801053d5 <argint>
80105d95:	83 c4 10             	add    $0x10,%esp
80105d98:	85 c0                	test   %eax,%eax
80105d9a:	79 0a                	jns    80105da6 <sys_open+0x3a>
    return -1;
80105d9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da1:	e9 61 01 00 00       	jmp    80105f07 <sys_open+0x19b>

  begin_op();
80105da6:	e8 75 d7 ff ff       	call   80103520 <begin_op>

  if(omode & O_CREATE){
80105dab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dae:	25 00 02 00 00       	and    $0x200,%eax
80105db3:	85 c0                	test   %eax,%eax
80105db5:	74 2a                	je     80105de1 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105db7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105dba:	6a 00                	push   $0x0
80105dbc:	6a 00                	push   $0x0
80105dbe:	6a 02                	push   $0x2
80105dc0:	50                   	push   %eax
80105dc1:	e8 d4 fd ff ff       	call   80105b9a <create>
80105dc6:	83 c4 10             	add    $0x10,%esp
80105dc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105dcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dd0:	75 75                	jne    80105e47 <sys_open+0xdb>
      end_op();
80105dd2:	e8 d5 d7 ff ff       	call   801035ac <end_op>
      return -1;
80105dd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ddc:	e9 26 01 00 00       	jmp    80105f07 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105de1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105de4:	83 ec 0c             	sub    $0xc,%esp
80105de7:	50                   	push   %eax
80105de8:	e8 38 c7 ff ff       	call   80102525 <namei>
80105ded:	83 c4 10             	add    $0x10,%esp
80105df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105df3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105df7:	75 0f                	jne    80105e08 <sys_open+0x9c>
      end_op();
80105df9:	e8 ae d7 ff ff       	call   801035ac <end_op>
      return -1;
80105dfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e03:	e9 ff 00 00 00       	jmp    80105f07 <sys_open+0x19b>
    }
    ilock(ip);
80105e08:	83 ec 0c             	sub    $0xc,%esp
80105e0b:	ff 75 f4             	push   -0xc(%ebp)
80105e0e:	e8 df bb ff ff       	call   801019f2 <ilock>
80105e13:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e19:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e1d:	66 83 f8 01          	cmp    $0x1,%ax
80105e21:	75 24                	jne    80105e47 <sys_open+0xdb>
80105e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e26:	85 c0                	test   %eax,%eax
80105e28:	74 1d                	je     80105e47 <sys_open+0xdb>
      iunlockput(ip);
80105e2a:	83 ec 0c             	sub    $0xc,%esp
80105e2d:	ff 75 f4             	push   -0xc(%ebp)
80105e30:	e8 ee bd ff ff       	call   80101c23 <iunlockput>
80105e35:	83 c4 10             	add    $0x10,%esp
      end_op();
80105e38:	e8 6f d7 ff ff       	call   801035ac <end_op>
      return -1;
80105e3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e42:	e9 c0 00 00 00       	jmp    80105f07 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105e47:	e8 9b b1 ff ff       	call   80100fe7 <filealloc>
80105e4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e4f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e53:	74 17                	je     80105e6c <sys_open+0x100>
80105e55:	83 ec 0c             	sub    $0xc,%esp
80105e58:	ff 75 f0             	push   -0x10(%ebp)
80105e5b:	e8 33 f7 ff ff       	call   80105593 <fdalloc>
80105e60:	83 c4 10             	add    $0x10,%esp
80105e63:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105e66:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105e6a:	79 2e                	jns    80105e9a <sys_open+0x12e>
    if(f)
80105e6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e70:	74 0e                	je     80105e80 <sys_open+0x114>
      fileclose(f);
80105e72:	83 ec 0c             	sub    $0xc,%esp
80105e75:	ff 75 f0             	push   -0x10(%ebp)
80105e78:	e8 28 b2 ff ff       	call   801010a5 <fileclose>
80105e7d:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105e80:	83 ec 0c             	sub    $0xc,%esp
80105e83:	ff 75 f4             	push   -0xc(%ebp)
80105e86:	e8 98 bd ff ff       	call   80101c23 <iunlockput>
80105e8b:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e8e:	e8 19 d7 ff ff       	call   801035ac <end_op>
    return -1;
80105e93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e98:	eb 6d                	jmp    80105f07 <sys_open+0x19b>
  }
  iunlock(ip);
80105e9a:	83 ec 0c             	sub    $0xc,%esp
80105e9d:	ff 75 f4             	push   -0xc(%ebp)
80105ea0:	e8 60 bc ff ff       	call   80101b05 <iunlock>
80105ea5:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ea8:	e8 ff d6 ff ff       	call   801035ac <end_op>

  f->type = FD_INODE;
80105ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ebc:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ecc:	83 e0 01             	and    $0x1,%eax
80105ecf:	85 c0                	test   %eax,%eax
80105ed1:	0f 94 c0             	sete   %al
80105ed4:	89 c2                	mov    %eax,%edx
80105ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed9:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105edf:	83 e0 01             	and    $0x1,%eax
80105ee2:	85 c0                	test   %eax,%eax
80105ee4:	75 0a                	jne    80105ef0 <sys_open+0x184>
80105ee6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ee9:	83 e0 02             	and    $0x2,%eax
80105eec:	85 c0                	test   %eax,%eax
80105eee:	74 07                	je     80105ef7 <sys_open+0x18b>
80105ef0:	b8 01 00 00 00       	mov    $0x1,%eax
80105ef5:	eb 05                	jmp    80105efc <sys_open+0x190>
80105ef7:	b8 00 00 00 00       	mov    $0x0,%eax
80105efc:	89 c2                	mov    %eax,%edx
80105efe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f01:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105f04:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f07:	c9                   	leave
80105f08:	c3                   	ret

80105f09 <sys_mkdir>:

int
sys_mkdir(void)
{
80105f09:	55                   	push   %ebp
80105f0a:	89 e5                	mov    %esp,%ebp
80105f0c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105f0f:	e8 0c d6 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105f14:	83 ec 08             	sub    $0x8,%esp
80105f17:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f1a:	50                   	push   %eax
80105f1b:	6a 00                	push   $0x0
80105f1d:	e8 48 f5 ff ff       	call   8010546a <argstr>
80105f22:	83 c4 10             	add    $0x10,%esp
80105f25:	85 c0                	test   %eax,%eax
80105f27:	78 1b                	js     80105f44 <sys_mkdir+0x3b>
80105f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2c:	6a 00                	push   $0x0
80105f2e:	6a 00                	push   $0x0
80105f30:	6a 01                	push   $0x1
80105f32:	50                   	push   %eax
80105f33:	e8 62 fc ff ff       	call   80105b9a <create>
80105f38:	83 c4 10             	add    $0x10,%esp
80105f3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f42:	75 0c                	jne    80105f50 <sys_mkdir+0x47>
    end_op();
80105f44:	e8 63 d6 ff ff       	call   801035ac <end_op>
    return -1;
80105f49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f4e:	eb 18                	jmp    80105f68 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105f50:	83 ec 0c             	sub    $0xc,%esp
80105f53:	ff 75 f4             	push   -0xc(%ebp)
80105f56:	e8 c8 bc ff ff       	call   80101c23 <iunlockput>
80105f5b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f5e:	e8 49 d6 ff ff       	call   801035ac <end_op>
  return 0;
80105f63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f68:	c9                   	leave
80105f69:	c3                   	ret

80105f6a <sys_mknod>:

int
sys_mknod(void)
{
80105f6a:	55                   	push   %ebp
80105f6b:	89 e5                	mov    %esp,%ebp
80105f6d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105f70:	e8 ab d5 ff ff       	call   80103520 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105f75:	83 ec 08             	sub    $0x8,%esp
80105f78:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f7b:	50                   	push   %eax
80105f7c:	6a 00                	push   $0x0
80105f7e:	e8 e7 f4 ff ff       	call   8010546a <argstr>
80105f83:	83 c4 10             	add    $0x10,%esp
80105f86:	85 c0                	test   %eax,%eax
80105f88:	78 4f                	js     80105fd9 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105f8a:	83 ec 08             	sub    $0x8,%esp
80105f8d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f90:	50                   	push   %eax
80105f91:	6a 01                	push   $0x1
80105f93:	e8 3d f4 ff ff       	call   801053d5 <argint>
80105f98:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105f9b:	85 c0                	test   %eax,%eax
80105f9d:	78 3a                	js     80105fd9 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105f9f:	83 ec 08             	sub    $0x8,%esp
80105fa2:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fa5:	50                   	push   %eax
80105fa6:	6a 02                	push   $0x2
80105fa8:	e8 28 f4 ff ff       	call   801053d5 <argint>
80105fad:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105fb0:	85 c0                	test   %eax,%eax
80105fb2:	78 25                	js     80105fd9 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105fb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fb7:	0f bf c8             	movswl %ax,%ecx
80105fba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fbd:	0f bf d0             	movswl %ax,%edx
80105fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc3:	51                   	push   %ecx
80105fc4:	52                   	push   %edx
80105fc5:	6a 03                	push   $0x3
80105fc7:	50                   	push   %eax
80105fc8:	e8 cd fb ff ff       	call   80105b9a <create>
80105fcd:	83 c4 10             	add    $0x10,%esp
80105fd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105fd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd7:	75 0c                	jne    80105fe5 <sys_mknod+0x7b>
    end_op();
80105fd9:	e8 ce d5 ff ff       	call   801035ac <end_op>
    return -1;
80105fde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe3:	eb 18                	jmp    80105ffd <sys_mknod+0x93>
  }
  iunlockput(ip);
80105fe5:	83 ec 0c             	sub    $0xc,%esp
80105fe8:	ff 75 f4             	push   -0xc(%ebp)
80105feb:	e8 33 bc ff ff       	call   80101c23 <iunlockput>
80105ff0:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ff3:	e8 b4 d5 ff ff       	call   801035ac <end_op>
  return 0;
80105ff8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ffd:	c9                   	leave
80105ffe:	c3                   	ret

80105fff <sys_chdir>:

int
sys_chdir(void)
{
80105fff:	55                   	push   %ebp
80106000:	89 e5                	mov    %esp,%ebp
80106002:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106005:	e8 08 df ff ff       	call   80103f12 <myproc>
8010600a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010600d:	e8 0e d5 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106012:	83 ec 08             	sub    $0x8,%esp
80106015:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106018:	50                   	push   %eax
80106019:	6a 00                	push   $0x0
8010601b:	e8 4a f4 ff ff       	call   8010546a <argstr>
80106020:	83 c4 10             	add    $0x10,%esp
80106023:	85 c0                	test   %eax,%eax
80106025:	78 18                	js     8010603f <sys_chdir+0x40>
80106027:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010602a:	83 ec 0c             	sub    $0xc,%esp
8010602d:	50                   	push   %eax
8010602e:	e8 f2 c4 ff ff       	call   80102525 <namei>
80106033:	83 c4 10             	add    $0x10,%esp
80106036:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106039:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010603d:	75 0c                	jne    8010604b <sys_chdir+0x4c>
    end_op();
8010603f:	e8 68 d5 ff ff       	call   801035ac <end_op>
    return -1;
80106044:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106049:	eb 68                	jmp    801060b3 <sys_chdir+0xb4>
  }
  ilock(ip);
8010604b:	83 ec 0c             	sub    $0xc,%esp
8010604e:	ff 75 f0             	push   -0x10(%ebp)
80106051:	e8 9c b9 ff ff       	call   801019f2 <ilock>
80106056:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106059:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106060:	66 83 f8 01          	cmp    $0x1,%ax
80106064:	74 1a                	je     80106080 <sys_chdir+0x81>
    iunlockput(ip);
80106066:	83 ec 0c             	sub    $0xc,%esp
80106069:	ff 75 f0             	push   -0x10(%ebp)
8010606c:	e8 b2 bb ff ff       	call   80101c23 <iunlockput>
80106071:	83 c4 10             	add    $0x10,%esp
    end_op();
80106074:	e8 33 d5 ff ff       	call   801035ac <end_op>
    return -1;
80106079:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010607e:	eb 33                	jmp    801060b3 <sys_chdir+0xb4>
  }
  iunlock(ip);
80106080:	83 ec 0c             	sub    $0xc,%esp
80106083:	ff 75 f0             	push   -0x10(%ebp)
80106086:	e8 7a ba ff ff       	call   80101b05 <iunlock>
8010608b:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010608e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106091:	8b 40 68             	mov    0x68(%eax),%eax
80106094:	83 ec 0c             	sub    $0xc,%esp
80106097:	50                   	push   %eax
80106098:	e8 b6 ba ff ff       	call   80101b53 <iput>
8010609d:	83 c4 10             	add    $0x10,%esp
  end_op();
801060a0:	e8 07 d5 ff ff       	call   801035ac <end_op>
  curproc->cwd = ip;
801060a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060ab:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801060ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060b3:	c9                   	leave
801060b4:	c3                   	ret

801060b5 <sys_exec>:

int
sys_exec(void)
{
801060b5:	55                   	push   %ebp
801060b6:	89 e5                	mov    %esp,%ebp
801060b8:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801060be:	83 ec 08             	sub    $0x8,%esp
801060c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060c4:	50                   	push   %eax
801060c5:	6a 00                	push   $0x0
801060c7:	e8 9e f3 ff ff       	call   8010546a <argstr>
801060cc:	83 c4 10             	add    $0x10,%esp
801060cf:	85 c0                	test   %eax,%eax
801060d1:	78 18                	js     801060eb <sys_exec+0x36>
801060d3:	83 ec 08             	sub    $0x8,%esp
801060d6:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801060dc:	50                   	push   %eax
801060dd:	6a 01                	push   $0x1
801060df:	e8 f1 f2 ff ff       	call   801053d5 <argint>
801060e4:	83 c4 10             	add    $0x10,%esp
801060e7:	85 c0                	test   %eax,%eax
801060e9:	79 0a                	jns    801060f5 <sys_exec+0x40>
    return -1;
801060eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f0:	e9 c6 00 00 00       	jmp    801061bb <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801060f5:	83 ec 04             	sub    $0x4,%esp
801060f8:	68 80 00 00 00       	push   $0x80
801060fd:	6a 00                	push   $0x0
801060ff:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106105:	50                   	push   %eax
80106106:	e8 9f ef ff ff       	call   801050aa <memset>
8010610b:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010610e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106118:	83 f8 1f             	cmp    $0x1f,%eax
8010611b:	76 0a                	jbe    80106127 <sys_exec+0x72>
      return -1;
8010611d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106122:	e9 94 00 00 00       	jmp    801061bb <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612a:	c1 e0 02             	shl    $0x2,%eax
8010612d:	89 c2                	mov    %eax,%edx
8010612f:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106135:	01 c2                	add    %eax,%edx
80106137:	83 ec 08             	sub    $0x8,%esp
8010613a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106140:	50                   	push   %eax
80106141:	52                   	push   %edx
80106142:	e8 ed f1 ff ff       	call   80105334 <fetchint>
80106147:	83 c4 10             	add    $0x10,%esp
8010614a:	85 c0                	test   %eax,%eax
8010614c:	79 07                	jns    80106155 <sys_exec+0xa0>
      return -1;
8010614e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106153:	eb 66                	jmp    801061bb <sys_exec+0x106>
    if(uarg == 0){
80106155:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010615b:	85 c0                	test   %eax,%eax
8010615d:	75 27                	jne    80106186 <sys_exec+0xd1>
      argv[i] = 0;
8010615f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106162:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106169:	00 00 00 00 
      break;
8010616d:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010616e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106171:	83 ec 08             	sub    $0x8,%esp
80106174:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010617a:	52                   	push   %edx
8010617b:	50                   	push   %eax
8010617c:	e8 09 aa ff ff       	call   80100b8a <exec>
80106181:	83 c4 10             	add    $0x10,%esp
80106184:	eb 35                	jmp    801061bb <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80106186:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010618c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010618f:	c1 e2 02             	shl    $0x2,%edx
80106192:	01 c2                	add    %eax,%edx
80106194:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010619a:	83 ec 08             	sub    $0x8,%esp
8010619d:	52                   	push   %edx
8010619e:	50                   	push   %eax
8010619f:	e8 cf f1 ff ff       	call   80105373 <fetchstr>
801061a4:	83 c4 10             	add    $0x10,%esp
801061a7:	85 c0                	test   %eax,%eax
801061a9:	79 07                	jns    801061b2 <sys_exec+0xfd>
      return -1;
801061ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b0:	eb 09                	jmp    801061bb <sys_exec+0x106>
  for(i=0;; i++){
801061b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801061b6:	e9 5a ff ff ff       	jmp    80106115 <sys_exec+0x60>
}
801061bb:	c9                   	leave
801061bc:	c3                   	ret

801061bd <sys_pipe>:

int
sys_pipe(void)
{
801061bd:	55                   	push   %ebp
801061be:	89 e5                	mov    %esp,%ebp
801061c0:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801061c3:	83 ec 04             	sub    $0x4,%esp
801061c6:	6a 08                	push   $0x8
801061c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061cb:	50                   	push   %eax
801061cc:	6a 00                	push   $0x0
801061ce:	e8 2f f2 ff ff       	call   80105402 <argptr>
801061d3:	83 c4 10             	add    $0x10,%esp
801061d6:	85 c0                	test   %eax,%eax
801061d8:	79 0a                	jns    801061e4 <sys_pipe+0x27>
    return -1;
801061da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061df:	e9 ae 00 00 00       	jmp    80106292 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
801061e4:	83 ec 08             	sub    $0x8,%esp
801061e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061ea:	50                   	push   %eax
801061eb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061ee:	50                   	push   %eax
801061ef:	e8 5b d8 ff ff       	call   80103a4f <pipealloc>
801061f4:	83 c4 10             	add    $0x10,%esp
801061f7:	85 c0                	test   %eax,%eax
801061f9:	79 0a                	jns    80106205 <sys_pipe+0x48>
    return -1;
801061fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106200:	e9 8d 00 00 00       	jmp    80106292 <sys_pipe+0xd5>
  fd0 = -1;
80106205:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010620c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010620f:	83 ec 0c             	sub    $0xc,%esp
80106212:	50                   	push   %eax
80106213:	e8 7b f3 ff ff       	call   80105593 <fdalloc>
80106218:	83 c4 10             	add    $0x10,%esp
8010621b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010621e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106222:	78 18                	js     8010623c <sys_pipe+0x7f>
80106224:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106227:	83 ec 0c             	sub    $0xc,%esp
8010622a:	50                   	push   %eax
8010622b:	e8 63 f3 ff ff       	call   80105593 <fdalloc>
80106230:	83 c4 10             	add    $0x10,%esp
80106233:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106236:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010623a:	79 3e                	jns    8010627a <sys_pipe+0xbd>
    if(fd0 >= 0)
8010623c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106240:	78 13                	js     80106255 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80106242:	e8 cb dc ff ff       	call   80103f12 <myproc>
80106247:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010624a:	83 c2 08             	add    $0x8,%edx
8010624d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106254:	00 
    fileclose(rf);
80106255:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106258:	83 ec 0c             	sub    $0xc,%esp
8010625b:	50                   	push   %eax
8010625c:	e8 44 ae ff ff       	call   801010a5 <fileclose>
80106261:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106264:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106267:	83 ec 0c             	sub    $0xc,%esp
8010626a:	50                   	push   %eax
8010626b:	e8 35 ae ff ff       	call   801010a5 <fileclose>
80106270:	83 c4 10             	add    $0x10,%esp
    return -1;
80106273:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106278:	eb 18                	jmp    80106292 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
8010627a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010627d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106280:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106282:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106285:	8d 50 04             	lea    0x4(%eax),%edx
80106288:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010628b:	89 02                	mov    %eax,(%edx)
  return 0;
8010628d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106292:	c9                   	leave
80106293:	c3                   	ret

80106294 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106294:	55                   	push   %ebp
80106295:	89 e5                	mov    %esp,%ebp
80106297:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010629a:	e8 72 df ff ff       	call   80104211 <fork>
}
8010629f:	c9                   	leave
801062a0:	c3                   	ret

801062a1 <sys_exit>:

int
sys_exit(void)
{
801062a1:	55                   	push   %ebp
801062a2:	89 e5                	mov    %esp,%ebp
801062a4:	83 ec 08             	sub    $0x8,%esp
  exit();
801062a7:	e8 de e0 ff ff       	call   8010438a <exit>
  return 0;  // not reached
801062ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062b1:	c9                   	leave
801062b2:	c3                   	ret

801062b3 <sys_wait>:

int
sys_wait(void)
{
801062b3:	55                   	push   %ebp
801062b4:	89 e5                	mov    %esp,%ebp
801062b6:	83 ec 08             	sub    $0x8,%esp
  return wait();
801062b9:	e8 ec e1 ff ff       	call   801044aa <wait>
}
801062be:	c9                   	leave
801062bf:	c3                   	ret

801062c0 <sys_kill>:

int
sys_kill(void)
{
801062c0:	55                   	push   %ebp
801062c1:	89 e5                	mov    %esp,%ebp
801062c3:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801062c6:	83 ec 08             	sub    $0x8,%esp
801062c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801062cc:	50                   	push   %eax
801062cd:	6a 00                	push   $0x0
801062cf:	e8 01 f1 ff ff       	call   801053d5 <argint>
801062d4:	83 c4 10             	add    $0x10,%esp
801062d7:	85 c0                	test   %eax,%eax
801062d9:	79 07                	jns    801062e2 <sys_kill+0x22>
    return -1;
801062db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e0:	eb 0f                	jmp    801062f1 <sys_kill+0x31>
  return kill(pid);
801062e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e5:	83 ec 0c             	sub    $0xc,%esp
801062e8:	50                   	push   %eax
801062e9:	e8 eb e5 ff ff       	call   801048d9 <kill>
801062ee:	83 c4 10             	add    $0x10,%esp
}
801062f1:	c9                   	leave
801062f2:	c3                   	ret

801062f3 <sys_getpid>:

int
sys_getpid(void)
{
801062f3:	55                   	push   %ebp
801062f4:	89 e5                	mov    %esp,%ebp
801062f6:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801062f9:	e8 14 dc ff ff       	call   80103f12 <myproc>
801062fe:	8b 40 10             	mov    0x10(%eax),%eax
}
80106301:	c9                   	leave
80106302:	c3                   	ret

80106303 <sys_sbrk>:

int
sys_sbrk(void)
{
80106303:	55                   	push   %ebp
80106304:	89 e5                	mov    %esp,%ebp
80106306:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106309:	83 ec 08             	sub    $0x8,%esp
8010630c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010630f:	50                   	push   %eax
80106310:	6a 00                	push   $0x0
80106312:	e8 be f0 ff ff       	call   801053d5 <argint>
80106317:	83 c4 10             	add    $0x10,%esp
8010631a:	85 c0                	test   %eax,%eax
8010631c:	79 07                	jns    80106325 <sys_sbrk+0x22>
    return -1;
8010631e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106323:	eb 27                	jmp    8010634c <sys_sbrk+0x49>
  addr = myproc()->sz;
80106325:	e8 e8 db ff ff       	call   80103f12 <myproc>
8010632a:	8b 00                	mov    (%eax),%eax
8010632c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010632f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106332:	83 ec 0c             	sub    $0xc,%esp
80106335:	50                   	push   %eax
80106336:	e8 3b de ff ff       	call   80104176 <growproc>
8010633b:	83 c4 10             	add    $0x10,%esp
8010633e:	85 c0                	test   %eax,%eax
80106340:	79 07                	jns    80106349 <sys_sbrk+0x46>
    return -1;
80106342:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106347:	eb 03                	jmp    8010634c <sys_sbrk+0x49>
  return addr;
80106349:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010634c:	c9                   	leave
8010634d:	c3                   	ret

8010634e <sys_sleep>:

int
sys_sleep(void)
{
8010634e:	55                   	push   %ebp
8010634f:	89 e5                	mov    %esp,%ebp
80106351:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106354:	83 ec 08             	sub    $0x8,%esp
80106357:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010635a:	50                   	push   %eax
8010635b:	6a 00                	push   $0x0
8010635d:	e8 73 f0 ff ff       	call   801053d5 <argint>
80106362:	83 c4 10             	add    $0x10,%esp
80106365:	85 c0                	test   %eax,%eax
80106367:	79 07                	jns    80106370 <sys_sleep+0x22>
    return -1;
80106369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010636e:	eb 76                	jmp    801063e6 <sys_sleep+0x98>
  acquire(&tickslock);
80106370:	83 ec 0c             	sub    $0xc,%esp
80106373:	68 80 9a 11 80       	push   $0x80119a80
80106378:	e8 b7 ea ff ff       	call   80104e34 <acquire>
8010637d:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106380:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
80106385:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106388:	eb 38                	jmp    801063c2 <sys_sleep+0x74>
    if(myproc()->killed){
8010638a:	e8 83 db ff ff       	call   80103f12 <myproc>
8010638f:	8b 40 24             	mov    0x24(%eax),%eax
80106392:	85 c0                	test   %eax,%eax
80106394:	74 17                	je     801063ad <sys_sleep+0x5f>
      release(&tickslock);
80106396:	83 ec 0c             	sub    $0xc,%esp
80106399:	68 80 9a 11 80       	push   $0x80119a80
8010639e:	e8 ff ea ff ff       	call   80104ea2 <release>
801063a3:	83 c4 10             	add    $0x10,%esp
      return -1;
801063a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ab:	eb 39                	jmp    801063e6 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
801063ad:	83 ec 08             	sub    $0x8,%esp
801063b0:	68 80 9a 11 80       	push   $0x80119a80
801063b5:	68 b4 9a 11 80       	push   $0x80119ab4
801063ba:	e8 fc e3 ff ff       	call   801047bb <sleep>
801063bf:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801063c2:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
801063c7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801063ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063cd:	39 d0                	cmp    %edx,%eax
801063cf:	72 b9                	jb     8010638a <sys_sleep+0x3c>
  }
  release(&tickslock);
801063d1:	83 ec 0c             	sub    $0xc,%esp
801063d4:	68 80 9a 11 80       	push   $0x80119a80
801063d9:	e8 c4 ea ff ff       	call   80104ea2 <release>
801063de:	83 c4 10             	add    $0x10,%esp
  return 0;
801063e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063e6:	c9                   	leave
801063e7:	c3                   	ret

801063e8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801063e8:	55                   	push   %ebp
801063e9:	89 e5                	mov    %esp,%ebp
801063eb:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801063ee:	83 ec 0c             	sub    $0xc,%esp
801063f1:	68 80 9a 11 80       	push   $0x80119a80
801063f6:	e8 39 ea ff ff       	call   80104e34 <acquire>
801063fb:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801063fe:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
80106403:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106406:	83 ec 0c             	sub    $0xc,%esp
80106409:	68 80 9a 11 80       	push   $0x80119a80
8010640e:	e8 8f ea ff ff       	call   80104ea2 <release>
80106413:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106416:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106419:	c9                   	leave
8010641a:	c3                   	ret

8010641b <sys_exit2>:

int
sys_exit2(void)
{
8010641b:	55                   	push   %ebp
8010641c:	89 e5                	mov    %esp,%ebp
8010641e:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
80106421:	83 ec 08             	sub    $0x8,%esp
80106424:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106427:	50                   	push   %eax
80106428:	6a 00                	push   $0x0
8010642a:	e8 a6 ef ff ff       	call   801053d5 <argint>
8010642f:	83 c4 10             	add    $0x10,%esp
80106432:	85 c0                	test   %eax,%eax
80106434:	79 07                	jns    8010643d <sys_exit2+0x22>
    return -1;
80106436:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643b:	eb 14                	jmp    80106451 <sys_exit2+0x36>
  exit2(status);
8010643d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106440:	83 ec 0c             	sub    $0xc,%esp
80106443:	50                   	push   %eax
80106444:	e8 0e e6 ff ff       	call   80104a57 <exit2>
80106449:	83 c4 10             	add    $0x10,%esp
  return 0;
8010644c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106451:	c9                   	leave
80106452:	c3                   	ret

80106453 <sys_wait2>:

int
sys_wait2(void)
{
80106453:	55                   	push   %ebp
80106454:	89 e5                	mov    %esp,%ebp
80106456:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void*)&status, sizeof(*status)) < 0)
80106459:	83 ec 04             	sub    $0x4,%esp
8010645c:	6a 04                	push   $0x4
8010645e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106461:	50                   	push   %eax
80106462:	6a 00                	push   $0x0
80106464:	e8 99 ef ff ff       	call   80105402 <argptr>
80106469:	83 c4 10             	add    $0x10,%esp
8010646c:	85 c0                	test   %eax,%eax
8010646e:	79 07                	jns    80106477 <sys_wait2+0x24>
    return -1;
80106470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106475:	eb 0f                	jmp    80106486 <sys_wait2+0x33>
  return wait2(status);
80106477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647a:	83 ec 0c             	sub    $0xc,%esp
8010647d:	50                   	push   %eax
8010647e:	e8 fd e6 ff ff       	call   80104b80 <wait2>
80106483:	83 c4 10             	add    $0x10,%esp
}
80106486:	c9                   	leave
80106487:	c3                   	ret

80106488 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106488:	1e                   	push   %ds
  pushl %es
80106489:	06                   	push   %es
  pushl %fs
8010648a:	0f a0                	push   %fs
  pushl %gs
8010648c:	0f a8                	push   %gs
  pushal
8010648e:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010648f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106493:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106495:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106497:	54                   	push   %esp
  call trap
80106498:	e8 d7 01 00 00       	call   80106674 <trap>
  addl $4, %esp
8010649d:	83 c4 04             	add    $0x4,%esp

801064a0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801064a0:	61                   	popa
  popl %gs
801064a1:	0f a9                	pop    %gs
  popl %fs
801064a3:	0f a1                	pop    %fs
  popl %es
801064a5:	07                   	pop    %es
  popl %ds
801064a6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801064a7:	83 c4 08             	add    $0x8,%esp
  iret
801064aa:	cf                   	iret

801064ab <lidt>:
{
801064ab:	55                   	push   %ebp
801064ac:	89 e5                	mov    %esp,%ebp
801064ae:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801064b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801064b4:	83 e8 01             	sub    $0x1,%eax
801064b7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801064bb:	8b 45 08             	mov    0x8(%ebp),%eax
801064be:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801064c2:	8b 45 08             	mov    0x8(%ebp),%eax
801064c5:	c1 e8 10             	shr    $0x10,%eax
801064c8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801064cc:	8d 45 fa             	lea    -0x6(%ebp),%eax
801064cf:	0f 01 18             	lidtl  (%eax)
}
801064d2:	90                   	nop
801064d3:	c9                   	leave
801064d4:	c3                   	ret

801064d5 <rcr2>:

static inline uint
rcr2(void)
{
801064d5:	55                   	push   %ebp
801064d6:	89 e5                	mov    %esp,%ebp
801064d8:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801064db:	0f 20 d0             	mov    %cr2,%eax
801064de:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801064e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801064e4:	c9                   	leave
801064e5:	c3                   	ret

801064e6 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801064e6:	55                   	push   %ebp
801064e7:	89 e5                	mov    %esp,%ebp
801064e9:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801064ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801064f3:	e9 c3 00 00 00       	jmp    801065bb <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801064f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fb:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
80106502:	89 c2                	mov    %eax,%edx
80106504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106507:	66 89 14 c5 80 92 11 	mov    %dx,-0x7fee6d80(,%eax,8)
8010650e:	80 
8010650f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106512:	66 c7 04 c5 82 92 11 	movw   $0x8,-0x7fee6d7e(,%eax,8)
80106519:	80 08 00 
8010651c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651f:	0f b6 14 c5 84 92 11 	movzbl -0x7fee6d7c(,%eax,8),%edx
80106526:	80 
80106527:	83 e2 e0             	and    $0xffffffe0,%edx
8010652a:	88 14 c5 84 92 11 80 	mov    %dl,-0x7fee6d7c(,%eax,8)
80106531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106534:	0f b6 14 c5 84 92 11 	movzbl -0x7fee6d7c(,%eax,8),%edx
8010653b:	80 
8010653c:	83 e2 1f             	and    $0x1f,%edx
8010653f:	88 14 c5 84 92 11 80 	mov    %dl,-0x7fee6d7c(,%eax,8)
80106546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106549:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
80106550:	80 
80106551:	83 e2 f0             	and    $0xfffffff0,%edx
80106554:	83 ca 0e             	or     $0xe,%edx
80106557:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
8010655e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106561:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
80106568:	80 
80106569:	83 e2 ef             	and    $0xffffffef,%edx
8010656c:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
80106573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106576:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
8010657d:	80 
8010657e:	83 e2 9f             	and    $0xffffff9f,%edx
80106581:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
80106588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658b:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
80106592:	80 
80106593:	83 ca 80             	or     $0xffffff80,%edx
80106596:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
8010659d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a0:	8b 04 85 80 f0 10 80 	mov    -0x7fef0f80(,%eax,4),%eax
801065a7:	c1 e8 10             	shr    $0x10,%eax
801065aa:	89 c2                	mov    %eax,%edx
801065ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065af:	66 89 14 c5 86 92 11 	mov    %dx,-0x7fee6d7a(,%eax,8)
801065b6:	80 
  for(i = 0; i < 256; i++)
801065b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065bb:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801065c2:	0f 8e 30 ff ff ff    	jle    801064f8 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801065c8:	a1 80 f1 10 80       	mov    0x8010f180,%eax
801065cd:	66 a3 80 94 11 80    	mov    %ax,0x80119480
801065d3:	66 c7 05 82 94 11 80 	movw   $0x8,0x80119482
801065da:	08 00 
801065dc:	0f b6 05 84 94 11 80 	movzbl 0x80119484,%eax
801065e3:	83 e0 e0             	and    $0xffffffe0,%eax
801065e6:	a2 84 94 11 80       	mov    %al,0x80119484
801065eb:	0f b6 05 84 94 11 80 	movzbl 0x80119484,%eax
801065f2:	83 e0 1f             	and    $0x1f,%eax
801065f5:	a2 84 94 11 80       	mov    %al,0x80119484
801065fa:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
80106601:	83 c8 0f             	or     $0xf,%eax
80106604:	a2 85 94 11 80       	mov    %al,0x80119485
80106609:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
80106610:	83 e0 ef             	and    $0xffffffef,%eax
80106613:	a2 85 94 11 80       	mov    %al,0x80119485
80106618:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
8010661f:	83 c8 60             	or     $0x60,%eax
80106622:	a2 85 94 11 80       	mov    %al,0x80119485
80106627:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
8010662e:	83 c8 80             	or     $0xffffff80,%eax
80106631:	a2 85 94 11 80       	mov    %al,0x80119485
80106636:	a1 80 f1 10 80       	mov    0x8010f180,%eax
8010663b:	c1 e8 10             	shr    $0x10,%eax
8010663e:	66 a3 86 94 11 80    	mov    %ax,0x80119486

  initlock(&tickslock, "time");
80106644:	83 ec 08             	sub    $0x8,%esp
80106647:	68 bc aa 10 80       	push   $0x8010aabc
8010664c:	68 80 9a 11 80       	push   $0x80119a80
80106651:	e8 bc e7 ff ff       	call   80104e12 <initlock>
80106656:	83 c4 10             	add    $0x10,%esp
}
80106659:	90                   	nop
8010665a:	c9                   	leave
8010665b:	c3                   	ret

8010665c <idtinit>:

void
idtinit(void)
{
8010665c:	55                   	push   %ebp
8010665d:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010665f:	68 00 08 00 00       	push   $0x800
80106664:	68 80 92 11 80       	push   $0x80119280
80106669:	e8 3d fe ff ff       	call   801064ab <lidt>
8010666e:	83 c4 08             	add    $0x8,%esp
}
80106671:	90                   	nop
80106672:	c9                   	leave
80106673:	c3                   	ret

80106674 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106674:	55                   	push   %ebp
80106675:	89 e5                	mov    %esp,%ebp
80106677:	57                   	push   %edi
80106678:	56                   	push   %esi
80106679:	53                   	push   %ebx
8010667a:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010667d:	8b 45 08             	mov    0x8(%ebp),%eax
80106680:	8b 40 30             	mov    0x30(%eax),%eax
80106683:	83 f8 40             	cmp    $0x40,%eax
80106686:	75 3b                	jne    801066c3 <trap+0x4f>
    if(myproc()->killed)
80106688:	e8 85 d8 ff ff       	call   80103f12 <myproc>
8010668d:	8b 40 24             	mov    0x24(%eax),%eax
80106690:	85 c0                	test   %eax,%eax
80106692:	74 05                	je     80106699 <trap+0x25>
      exit();
80106694:	e8 f1 dc ff ff       	call   8010438a <exit>
    myproc()->tf = tf;
80106699:	e8 74 d8 ff ff       	call   80103f12 <myproc>
8010669e:	8b 55 08             	mov    0x8(%ebp),%edx
801066a1:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801066a4:	e8 f8 ed ff ff       	call   801054a1 <syscall>
    if(myproc()->killed)
801066a9:	e8 64 d8 ff ff       	call   80103f12 <myproc>
801066ae:	8b 40 24             	mov    0x24(%eax),%eax
801066b1:	85 c0                	test   %eax,%eax
801066b3:	0f 84 15 02 00 00    	je     801068ce <trap+0x25a>
      exit();
801066b9:	e8 cc dc ff ff       	call   8010438a <exit>
    return;
801066be:	e9 0b 02 00 00       	jmp    801068ce <trap+0x25a>
  }

  switch(tf->trapno){
801066c3:	8b 45 08             	mov    0x8(%ebp),%eax
801066c6:	8b 40 30             	mov    0x30(%eax),%eax
801066c9:	83 e8 20             	sub    $0x20,%eax
801066cc:	83 f8 1f             	cmp    $0x1f,%eax
801066cf:	0f 87 c4 00 00 00    	ja     80106799 <trap+0x125>
801066d5:	8b 04 85 64 ab 10 80 	mov    -0x7fef549c(,%eax,4),%eax
801066dc:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801066de:	e8 9c d7 ff ff       	call   80103e7f <cpuid>
801066e3:	85 c0                	test   %eax,%eax
801066e5:	75 3d                	jne    80106724 <trap+0xb0>
      acquire(&tickslock);
801066e7:	83 ec 0c             	sub    $0xc,%esp
801066ea:	68 80 9a 11 80       	push   $0x80119a80
801066ef:	e8 40 e7 ff ff       	call   80104e34 <acquire>
801066f4:	83 c4 10             	add    $0x10,%esp
      ticks++;
801066f7:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
801066fc:	83 c0 01             	add    $0x1,%eax
801066ff:	a3 b4 9a 11 80       	mov    %eax,0x80119ab4
      wakeup(&ticks);
80106704:	83 ec 0c             	sub    $0xc,%esp
80106707:	68 b4 9a 11 80       	push   $0x80119ab4
8010670c:	e8 91 e1 ff ff       	call   801048a2 <wakeup>
80106711:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106714:	83 ec 0c             	sub    $0xc,%esp
80106717:	68 80 9a 11 80       	push   $0x80119a80
8010671c:	e8 81 e7 ff ff       	call   80104ea2 <release>
80106721:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106724:	e8 d7 c8 ff ff       	call   80103000 <lapiceoi>
    break;
80106729:	e9 20 01 00 00       	jmp    8010684e <trap+0x1da>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010672e:	e8 29 c1 ff ff       	call   8010285c <ideintr>
    lapiceoi();
80106733:	e8 c8 c8 ff ff       	call   80103000 <lapiceoi>
    break;
80106738:	e9 11 01 00 00       	jmp    8010684e <trap+0x1da>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010673d:	e8 09 c7 ff ff       	call   80102e4b <kbdintr>
    lapiceoi();
80106742:	e8 b9 c8 ff ff       	call   80103000 <lapiceoi>
    break;
80106747:	e9 02 01 00 00       	jmp    8010684e <trap+0x1da>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010674c:	e8 51 03 00 00       	call   80106aa2 <uartintr>
    lapiceoi();
80106751:	e8 aa c8 ff ff       	call   80103000 <lapiceoi>
    break;
80106756:	e9 f3 00 00 00       	jmp    8010684e <trap+0x1da>
  case T_IRQ0 + 0xB:
    i8254_intr();
8010675b:	e8 77 2b 00 00       	call   801092d7 <i8254_intr>
    lapiceoi();
80106760:	e8 9b c8 ff ff       	call   80103000 <lapiceoi>
    break;
80106765:	e9 e4 00 00 00       	jmp    8010684e <trap+0x1da>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010676a:	8b 45 08             	mov    0x8(%ebp),%eax
8010676d:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106770:	8b 45 08             	mov    0x8(%ebp),%eax
80106773:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106777:	0f b7 d8             	movzwl %ax,%ebx
8010677a:	e8 00 d7 ff ff       	call   80103e7f <cpuid>
8010677f:	56                   	push   %esi
80106780:	53                   	push   %ebx
80106781:	50                   	push   %eax
80106782:	68 c4 aa 10 80       	push   $0x8010aac4
80106787:	e8 68 9c ff ff       	call   801003f4 <cprintf>
8010678c:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010678f:	e8 6c c8 ff ff       	call   80103000 <lapiceoi>
    break;
80106794:	e9 b5 00 00 00       	jmp    8010684e <trap+0x1da>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106799:	e8 74 d7 ff ff       	call   80103f12 <myproc>
8010679e:	85 c0                	test   %eax,%eax
801067a0:	74 11                	je     801067b3 <trap+0x13f>
801067a2:	8b 45 08             	mov    0x8(%ebp),%eax
801067a5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067a9:	0f b7 c0             	movzwl %ax,%eax
801067ac:	83 e0 03             	and    $0x3,%eax
801067af:	85 c0                	test   %eax,%eax
801067b1:	75 39                	jne    801067ec <trap+0x178>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801067b3:	e8 1d fd ff ff       	call   801064d5 <rcr2>
801067b8:	89 c3                	mov    %eax,%ebx
801067ba:	8b 45 08             	mov    0x8(%ebp),%eax
801067bd:	8b 70 38             	mov    0x38(%eax),%esi
801067c0:	e8 ba d6 ff ff       	call   80103e7f <cpuid>
801067c5:	8b 55 08             	mov    0x8(%ebp),%edx
801067c8:	8b 52 30             	mov    0x30(%edx),%edx
801067cb:	83 ec 0c             	sub    $0xc,%esp
801067ce:	53                   	push   %ebx
801067cf:	56                   	push   %esi
801067d0:	50                   	push   %eax
801067d1:	52                   	push   %edx
801067d2:	68 e8 aa 10 80       	push   $0x8010aae8
801067d7:	e8 18 9c ff ff       	call   801003f4 <cprintf>
801067dc:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801067df:	83 ec 0c             	sub    $0xc,%esp
801067e2:	68 1a ab 10 80       	push   $0x8010ab1a
801067e7:	e8 bd 9d ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801067ec:	e8 e4 fc ff ff       	call   801064d5 <rcr2>
801067f1:	89 c6                	mov    %eax,%esi
801067f3:	8b 45 08             	mov    0x8(%ebp),%eax
801067f6:	8b 40 38             	mov    0x38(%eax),%eax
801067f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801067fc:	e8 7e d6 ff ff       	call   80103e7f <cpuid>
80106801:	89 c3                	mov    %eax,%ebx
80106803:	8b 45 08             	mov    0x8(%ebp),%eax
80106806:	8b 48 34             	mov    0x34(%eax),%ecx
80106809:	89 4d e0             	mov    %ecx,-0x20(%ebp)
8010680c:	8b 45 08             	mov    0x8(%ebp),%eax
8010680f:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106812:	e8 fb d6 ff ff       	call   80103f12 <myproc>
80106817:	8d 50 6c             	lea    0x6c(%eax),%edx
8010681a:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010681d:	e8 f0 d6 ff ff       	call   80103f12 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106822:	8b 40 10             	mov    0x10(%eax),%eax
80106825:	56                   	push   %esi
80106826:	ff 75 e4             	push   -0x1c(%ebp)
80106829:	53                   	push   %ebx
8010682a:	ff 75 e0             	push   -0x20(%ebp)
8010682d:	57                   	push   %edi
8010682e:	ff 75 dc             	push   -0x24(%ebp)
80106831:	50                   	push   %eax
80106832:	68 20 ab 10 80       	push   $0x8010ab20
80106837:	e8 b8 9b ff ff       	call   801003f4 <cprintf>
8010683c:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010683f:	e8 ce d6 ff ff       	call   80103f12 <myproc>
80106844:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010684b:	eb 01                	jmp    8010684e <trap+0x1da>
    break;
8010684d:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010684e:	e8 bf d6 ff ff       	call   80103f12 <myproc>
80106853:	85 c0                	test   %eax,%eax
80106855:	74 23                	je     8010687a <trap+0x206>
80106857:	e8 b6 d6 ff ff       	call   80103f12 <myproc>
8010685c:	8b 40 24             	mov    0x24(%eax),%eax
8010685f:	85 c0                	test   %eax,%eax
80106861:	74 17                	je     8010687a <trap+0x206>
80106863:	8b 45 08             	mov    0x8(%ebp),%eax
80106866:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010686a:	0f b7 c0             	movzwl %ax,%eax
8010686d:	83 e0 03             	and    $0x3,%eax
80106870:	83 f8 03             	cmp    $0x3,%eax
80106873:	75 05                	jne    8010687a <trap+0x206>
    exit();
80106875:	e8 10 db ff ff       	call   8010438a <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010687a:	e8 93 d6 ff ff       	call   80103f12 <myproc>
8010687f:	85 c0                	test   %eax,%eax
80106881:	74 1d                	je     801068a0 <trap+0x22c>
80106883:	e8 8a d6 ff ff       	call   80103f12 <myproc>
80106888:	8b 40 0c             	mov    0xc(%eax),%eax
8010688b:	83 f8 04             	cmp    $0x4,%eax
8010688e:	75 10                	jne    801068a0 <trap+0x22c>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106890:	8b 45 08             	mov    0x8(%ebp),%eax
80106893:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106896:	83 f8 20             	cmp    $0x20,%eax
80106899:	75 05                	jne    801068a0 <trap+0x22c>
    yield();
8010689b:	e8 9b de ff ff       	call   8010473b <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801068a0:	e8 6d d6 ff ff       	call   80103f12 <myproc>
801068a5:	85 c0                	test   %eax,%eax
801068a7:	74 26                	je     801068cf <trap+0x25b>
801068a9:	e8 64 d6 ff ff       	call   80103f12 <myproc>
801068ae:	8b 40 24             	mov    0x24(%eax),%eax
801068b1:	85 c0                	test   %eax,%eax
801068b3:	74 1a                	je     801068cf <trap+0x25b>
801068b5:	8b 45 08             	mov    0x8(%ebp),%eax
801068b8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068bc:	0f b7 c0             	movzwl %ax,%eax
801068bf:	83 e0 03             	and    $0x3,%eax
801068c2:	83 f8 03             	cmp    $0x3,%eax
801068c5:	75 08                	jne    801068cf <trap+0x25b>
    exit();
801068c7:	e8 be da ff ff       	call   8010438a <exit>
801068cc:	eb 01                	jmp    801068cf <trap+0x25b>
    return;
801068ce:	90                   	nop
}
801068cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068d2:	5b                   	pop    %ebx
801068d3:	5e                   	pop    %esi
801068d4:	5f                   	pop    %edi
801068d5:	5d                   	pop    %ebp
801068d6:	c3                   	ret

801068d7 <inb>:
{
801068d7:	55                   	push   %ebp
801068d8:	89 e5                	mov    %esp,%ebp
801068da:	83 ec 14             	sub    $0x14,%esp
801068dd:	8b 45 08             	mov    0x8(%ebp),%eax
801068e0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801068e4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801068e8:	89 c2                	mov    %eax,%edx
801068ea:	ec                   	in     (%dx),%al
801068eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801068ee:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801068f2:	c9                   	leave
801068f3:	c3                   	ret

801068f4 <outb>:
{
801068f4:	55                   	push   %ebp
801068f5:	89 e5                	mov    %esp,%ebp
801068f7:	83 ec 08             	sub    $0x8,%esp
801068fa:	8b 55 08             	mov    0x8(%ebp),%edx
801068fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80106900:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106904:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106907:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010690b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010690f:	ee                   	out    %al,(%dx)
}
80106910:	90                   	nop
80106911:	c9                   	leave
80106912:	c3                   	ret

80106913 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106913:	55                   	push   %ebp
80106914:	89 e5                	mov    %esp,%ebp
80106916:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106919:	6a 00                	push   $0x0
8010691b:	68 fa 03 00 00       	push   $0x3fa
80106920:	e8 cf ff ff ff       	call   801068f4 <outb>
80106925:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106928:	68 80 00 00 00       	push   $0x80
8010692d:	68 fb 03 00 00       	push   $0x3fb
80106932:	e8 bd ff ff ff       	call   801068f4 <outb>
80106937:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
8010693a:	6a 0c                	push   $0xc
8010693c:	68 f8 03 00 00       	push   $0x3f8
80106941:	e8 ae ff ff ff       	call   801068f4 <outb>
80106946:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106949:	6a 00                	push   $0x0
8010694b:	68 f9 03 00 00       	push   $0x3f9
80106950:	e8 9f ff ff ff       	call   801068f4 <outb>
80106955:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106958:	6a 03                	push   $0x3
8010695a:	68 fb 03 00 00       	push   $0x3fb
8010695f:	e8 90 ff ff ff       	call   801068f4 <outb>
80106964:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106967:	6a 00                	push   $0x0
80106969:	68 fc 03 00 00       	push   $0x3fc
8010696e:	e8 81 ff ff ff       	call   801068f4 <outb>
80106973:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106976:	6a 01                	push   $0x1
80106978:	68 f9 03 00 00       	push   $0x3f9
8010697d:	e8 72 ff ff ff       	call   801068f4 <outb>
80106982:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106985:	68 fd 03 00 00       	push   $0x3fd
8010698a:	e8 48 ff ff ff       	call   801068d7 <inb>
8010698f:	83 c4 04             	add    $0x4,%esp
80106992:	3c ff                	cmp    $0xff,%al
80106994:	74 61                	je     801069f7 <uartinit+0xe4>
    return;
  uart = 1;
80106996:	c7 05 b8 9a 11 80 01 	movl   $0x1,0x80119ab8
8010699d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801069a0:	68 fa 03 00 00       	push   $0x3fa
801069a5:	e8 2d ff ff ff       	call   801068d7 <inb>
801069aa:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801069ad:	68 f8 03 00 00       	push   $0x3f8
801069b2:	e8 20 ff ff ff       	call   801068d7 <inb>
801069b7:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801069ba:	83 ec 08             	sub    $0x8,%esp
801069bd:	6a 00                	push   $0x0
801069bf:	6a 04                	push   $0x4
801069c1:	e8 52 c1 ff ff       	call   80102b18 <ioapicenable>
801069c6:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801069c9:	c7 45 f4 e4 ab 10 80 	movl   $0x8010abe4,-0xc(%ebp)
801069d0:	eb 19                	jmp    801069eb <uartinit+0xd8>
    uartputc(*p);
801069d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d5:	0f b6 00             	movzbl (%eax),%eax
801069d8:	0f be c0             	movsbl %al,%eax
801069db:	83 ec 0c             	sub    $0xc,%esp
801069de:	50                   	push   %eax
801069df:	e8 16 00 00 00       	call   801069fa <uartputc>
801069e4:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801069e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ee:	0f b6 00             	movzbl (%eax),%eax
801069f1:	84 c0                	test   %al,%al
801069f3:	75 dd                	jne    801069d2 <uartinit+0xbf>
801069f5:	eb 01                	jmp    801069f8 <uartinit+0xe5>
    return;
801069f7:	90                   	nop
}
801069f8:	c9                   	leave
801069f9:	c3                   	ret

801069fa <uartputc>:

void
uartputc(int c)
{
801069fa:	55                   	push   %ebp
801069fb:	89 e5                	mov    %esp,%ebp
801069fd:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106a00:	a1 b8 9a 11 80       	mov    0x80119ab8,%eax
80106a05:	85 c0                	test   %eax,%eax
80106a07:	74 53                	je     80106a5c <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a10:	eb 11                	jmp    80106a23 <uartputc+0x29>
    microdelay(10);
80106a12:	83 ec 0c             	sub    $0xc,%esp
80106a15:	6a 0a                	push   $0xa
80106a17:	e8 ff c5 ff ff       	call   8010301b <microdelay>
80106a1c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a1f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a23:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a27:	7f 1a                	jg     80106a43 <uartputc+0x49>
80106a29:	83 ec 0c             	sub    $0xc,%esp
80106a2c:	68 fd 03 00 00       	push   $0x3fd
80106a31:	e8 a1 fe ff ff       	call   801068d7 <inb>
80106a36:	83 c4 10             	add    $0x10,%esp
80106a39:	0f b6 c0             	movzbl %al,%eax
80106a3c:	83 e0 20             	and    $0x20,%eax
80106a3f:	85 c0                	test   %eax,%eax
80106a41:	74 cf                	je     80106a12 <uartputc+0x18>
  outb(COM1+0, c);
80106a43:	8b 45 08             	mov    0x8(%ebp),%eax
80106a46:	0f b6 c0             	movzbl %al,%eax
80106a49:	83 ec 08             	sub    $0x8,%esp
80106a4c:	50                   	push   %eax
80106a4d:	68 f8 03 00 00       	push   $0x3f8
80106a52:	e8 9d fe ff ff       	call   801068f4 <outb>
80106a57:	83 c4 10             	add    $0x10,%esp
80106a5a:	eb 01                	jmp    80106a5d <uartputc+0x63>
    return;
80106a5c:	90                   	nop
}
80106a5d:	c9                   	leave
80106a5e:	c3                   	ret

80106a5f <uartgetc>:

static int
uartgetc(void)
{
80106a5f:	55                   	push   %ebp
80106a60:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106a62:	a1 b8 9a 11 80       	mov    0x80119ab8,%eax
80106a67:	85 c0                	test   %eax,%eax
80106a69:	75 07                	jne    80106a72 <uartgetc+0x13>
    return -1;
80106a6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a70:	eb 2e                	jmp    80106aa0 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106a72:	68 fd 03 00 00       	push   $0x3fd
80106a77:	e8 5b fe ff ff       	call   801068d7 <inb>
80106a7c:	83 c4 04             	add    $0x4,%esp
80106a7f:	0f b6 c0             	movzbl %al,%eax
80106a82:	83 e0 01             	and    $0x1,%eax
80106a85:	85 c0                	test   %eax,%eax
80106a87:	75 07                	jne    80106a90 <uartgetc+0x31>
    return -1;
80106a89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8e:	eb 10                	jmp    80106aa0 <uartgetc+0x41>
  return inb(COM1+0);
80106a90:	68 f8 03 00 00       	push   $0x3f8
80106a95:	e8 3d fe ff ff       	call   801068d7 <inb>
80106a9a:	83 c4 04             	add    $0x4,%esp
80106a9d:	0f b6 c0             	movzbl %al,%eax
}
80106aa0:	c9                   	leave
80106aa1:	c3                   	ret

80106aa2 <uartintr>:

void
uartintr(void)
{
80106aa2:	55                   	push   %ebp
80106aa3:	89 e5                	mov    %esp,%ebp
80106aa5:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106aa8:	83 ec 0c             	sub    $0xc,%esp
80106aab:	68 5f 6a 10 80       	push   $0x80106a5f
80106ab0:	e8 21 9d ff ff       	call   801007d6 <consoleintr>
80106ab5:	83 c4 10             	add    $0x10,%esp
}
80106ab8:	90                   	nop
80106ab9:	c9                   	leave
80106aba:	c3                   	ret

80106abb <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106abb:	6a 00                	push   $0x0
  pushl $0
80106abd:	6a 00                	push   $0x0
  jmp alltraps
80106abf:	e9 c4 f9 ff ff       	jmp    80106488 <alltraps>

80106ac4 <vector1>:
.globl vector1
vector1:
  pushl $0
80106ac4:	6a 00                	push   $0x0
  pushl $1
80106ac6:	6a 01                	push   $0x1
  jmp alltraps
80106ac8:	e9 bb f9 ff ff       	jmp    80106488 <alltraps>

80106acd <vector2>:
.globl vector2
vector2:
  pushl $0
80106acd:	6a 00                	push   $0x0
  pushl $2
80106acf:	6a 02                	push   $0x2
  jmp alltraps
80106ad1:	e9 b2 f9 ff ff       	jmp    80106488 <alltraps>

80106ad6 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ad6:	6a 00                	push   $0x0
  pushl $3
80106ad8:	6a 03                	push   $0x3
  jmp alltraps
80106ada:	e9 a9 f9 ff ff       	jmp    80106488 <alltraps>

80106adf <vector4>:
.globl vector4
vector4:
  pushl $0
80106adf:	6a 00                	push   $0x0
  pushl $4
80106ae1:	6a 04                	push   $0x4
  jmp alltraps
80106ae3:	e9 a0 f9 ff ff       	jmp    80106488 <alltraps>

80106ae8 <vector5>:
.globl vector5
vector5:
  pushl $0
80106ae8:	6a 00                	push   $0x0
  pushl $5
80106aea:	6a 05                	push   $0x5
  jmp alltraps
80106aec:	e9 97 f9 ff ff       	jmp    80106488 <alltraps>

80106af1 <vector6>:
.globl vector6
vector6:
  pushl $0
80106af1:	6a 00                	push   $0x0
  pushl $6
80106af3:	6a 06                	push   $0x6
  jmp alltraps
80106af5:	e9 8e f9 ff ff       	jmp    80106488 <alltraps>

80106afa <vector7>:
.globl vector7
vector7:
  pushl $0
80106afa:	6a 00                	push   $0x0
  pushl $7
80106afc:	6a 07                	push   $0x7
  jmp alltraps
80106afe:	e9 85 f9 ff ff       	jmp    80106488 <alltraps>

80106b03 <vector8>:
.globl vector8
vector8:
  pushl $8
80106b03:	6a 08                	push   $0x8
  jmp alltraps
80106b05:	e9 7e f9 ff ff       	jmp    80106488 <alltraps>

80106b0a <vector9>:
.globl vector9
vector9:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $9
80106b0c:	6a 09                	push   $0x9
  jmp alltraps
80106b0e:	e9 75 f9 ff ff       	jmp    80106488 <alltraps>

80106b13 <vector10>:
.globl vector10
vector10:
  pushl $10
80106b13:	6a 0a                	push   $0xa
  jmp alltraps
80106b15:	e9 6e f9 ff ff       	jmp    80106488 <alltraps>

80106b1a <vector11>:
.globl vector11
vector11:
  pushl $11
80106b1a:	6a 0b                	push   $0xb
  jmp alltraps
80106b1c:	e9 67 f9 ff ff       	jmp    80106488 <alltraps>

80106b21 <vector12>:
.globl vector12
vector12:
  pushl $12
80106b21:	6a 0c                	push   $0xc
  jmp alltraps
80106b23:	e9 60 f9 ff ff       	jmp    80106488 <alltraps>

80106b28 <vector13>:
.globl vector13
vector13:
  pushl $13
80106b28:	6a 0d                	push   $0xd
  jmp alltraps
80106b2a:	e9 59 f9 ff ff       	jmp    80106488 <alltraps>

80106b2f <vector14>:
.globl vector14
vector14:
  pushl $14
80106b2f:	6a 0e                	push   $0xe
  jmp alltraps
80106b31:	e9 52 f9 ff ff       	jmp    80106488 <alltraps>

80106b36 <vector15>:
.globl vector15
vector15:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $15
80106b38:	6a 0f                	push   $0xf
  jmp alltraps
80106b3a:	e9 49 f9 ff ff       	jmp    80106488 <alltraps>

80106b3f <vector16>:
.globl vector16
vector16:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $16
80106b41:	6a 10                	push   $0x10
  jmp alltraps
80106b43:	e9 40 f9 ff ff       	jmp    80106488 <alltraps>

80106b48 <vector17>:
.globl vector17
vector17:
  pushl $17
80106b48:	6a 11                	push   $0x11
  jmp alltraps
80106b4a:	e9 39 f9 ff ff       	jmp    80106488 <alltraps>

80106b4f <vector18>:
.globl vector18
vector18:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $18
80106b51:	6a 12                	push   $0x12
  jmp alltraps
80106b53:	e9 30 f9 ff ff       	jmp    80106488 <alltraps>

80106b58 <vector19>:
.globl vector19
vector19:
  pushl $0
80106b58:	6a 00                	push   $0x0
  pushl $19
80106b5a:	6a 13                	push   $0x13
  jmp alltraps
80106b5c:	e9 27 f9 ff ff       	jmp    80106488 <alltraps>

80106b61 <vector20>:
.globl vector20
vector20:
  pushl $0
80106b61:	6a 00                	push   $0x0
  pushl $20
80106b63:	6a 14                	push   $0x14
  jmp alltraps
80106b65:	e9 1e f9 ff ff       	jmp    80106488 <alltraps>

80106b6a <vector21>:
.globl vector21
vector21:
  pushl $0
80106b6a:	6a 00                	push   $0x0
  pushl $21
80106b6c:	6a 15                	push   $0x15
  jmp alltraps
80106b6e:	e9 15 f9 ff ff       	jmp    80106488 <alltraps>

80106b73 <vector22>:
.globl vector22
vector22:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $22
80106b75:	6a 16                	push   $0x16
  jmp alltraps
80106b77:	e9 0c f9 ff ff       	jmp    80106488 <alltraps>

80106b7c <vector23>:
.globl vector23
vector23:
  pushl $0
80106b7c:	6a 00                	push   $0x0
  pushl $23
80106b7e:	6a 17                	push   $0x17
  jmp alltraps
80106b80:	e9 03 f9 ff ff       	jmp    80106488 <alltraps>

80106b85 <vector24>:
.globl vector24
vector24:
  pushl $0
80106b85:	6a 00                	push   $0x0
  pushl $24
80106b87:	6a 18                	push   $0x18
  jmp alltraps
80106b89:	e9 fa f8 ff ff       	jmp    80106488 <alltraps>

80106b8e <vector25>:
.globl vector25
vector25:
  pushl $0
80106b8e:	6a 00                	push   $0x0
  pushl $25
80106b90:	6a 19                	push   $0x19
  jmp alltraps
80106b92:	e9 f1 f8 ff ff       	jmp    80106488 <alltraps>

80106b97 <vector26>:
.globl vector26
vector26:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $26
80106b99:	6a 1a                	push   $0x1a
  jmp alltraps
80106b9b:	e9 e8 f8 ff ff       	jmp    80106488 <alltraps>

80106ba0 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ba0:	6a 00                	push   $0x0
  pushl $27
80106ba2:	6a 1b                	push   $0x1b
  jmp alltraps
80106ba4:	e9 df f8 ff ff       	jmp    80106488 <alltraps>

80106ba9 <vector28>:
.globl vector28
vector28:
  pushl $0
80106ba9:	6a 00                	push   $0x0
  pushl $28
80106bab:	6a 1c                	push   $0x1c
  jmp alltraps
80106bad:	e9 d6 f8 ff ff       	jmp    80106488 <alltraps>

80106bb2 <vector29>:
.globl vector29
vector29:
  pushl $0
80106bb2:	6a 00                	push   $0x0
  pushl $29
80106bb4:	6a 1d                	push   $0x1d
  jmp alltraps
80106bb6:	e9 cd f8 ff ff       	jmp    80106488 <alltraps>

80106bbb <vector30>:
.globl vector30
vector30:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $30
80106bbd:	6a 1e                	push   $0x1e
  jmp alltraps
80106bbf:	e9 c4 f8 ff ff       	jmp    80106488 <alltraps>

80106bc4 <vector31>:
.globl vector31
vector31:
  pushl $0
80106bc4:	6a 00                	push   $0x0
  pushl $31
80106bc6:	6a 1f                	push   $0x1f
  jmp alltraps
80106bc8:	e9 bb f8 ff ff       	jmp    80106488 <alltraps>

80106bcd <vector32>:
.globl vector32
vector32:
  pushl $0
80106bcd:	6a 00                	push   $0x0
  pushl $32
80106bcf:	6a 20                	push   $0x20
  jmp alltraps
80106bd1:	e9 b2 f8 ff ff       	jmp    80106488 <alltraps>

80106bd6 <vector33>:
.globl vector33
vector33:
  pushl $0
80106bd6:	6a 00                	push   $0x0
  pushl $33
80106bd8:	6a 21                	push   $0x21
  jmp alltraps
80106bda:	e9 a9 f8 ff ff       	jmp    80106488 <alltraps>

80106bdf <vector34>:
.globl vector34
vector34:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $34
80106be1:	6a 22                	push   $0x22
  jmp alltraps
80106be3:	e9 a0 f8 ff ff       	jmp    80106488 <alltraps>

80106be8 <vector35>:
.globl vector35
vector35:
  pushl $0
80106be8:	6a 00                	push   $0x0
  pushl $35
80106bea:	6a 23                	push   $0x23
  jmp alltraps
80106bec:	e9 97 f8 ff ff       	jmp    80106488 <alltraps>

80106bf1 <vector36>:
.globl vector36
vector36:
  pushl $0
80106bf1:	6a 00                	push   $0x0
  pushl $36
80106bf3:	6a 24                	push   $0x24
  jmp alltraps
80106bf5:	e9 8e f8 ff ff       	jmp    80106488 <alltraps>

80106bfa <vector37>:
.globl vector37
vector37:
  pushl $0
80106bfa:	6a 00                	push   $0x0
  pushl $37
80106bfc:	6a 25                	push   $0x25
  jmp alltraps
80106bfe:	e9 85 f8 ff ff       	jmp    80106488 <alltraps>

80106c03 <vector38>:
.globl vector38
vector38:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $38
80106c05:	6a 26                	push   $0x26
  jmp alltraps
80106c07:	e9 7c f8 ff ff       	jmp    80106488 <alltraps>

80106c0c <vector39>:
.globl vector39
vector39:
  pushl $0
80106c0c:	6a 00                	push   $0x0
  pushl $39
80106c0e:	6a 27                	push   $0x27
  jmp alltraps
80106c10:	e9 73 f8 ff ff       	jmp    80106488 <alltraps>

80106c15 <vector40>:
.globl vector40
vector40:
  pushl $0
80106c15:	6a 00                	push   $0x0
  pushl $40
80106c17:	6a 28                	push   $0x28
  jmp alltraps
80106c19:	e9 6a f8 ff ff       	jmp    80106488 <alltraps>

80106c1e <vector41>:
.globl vector41
vector41:
  pushl $0
80106c1e:	6a 00                	push   $0x0
  pushl $41
80106c20:	6a 29                	push   $0x29
  jmp alltraps
80106c22:	e9 61 f8 ff ff       	jmp    80106488 <alltraps>

80106c27 <vector42>:
.globl vector42
vector42:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $42
80106c29:	6a 2a                	push   $0x2a
  jmp alltraps
80106c2b:	e9 58 f8 ff ff       	jmp    80106488 <alltraps>

80106c30 <vector43>:
.globl vector43
vector43:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $43
80106c32:	6a 2b                	push   $0x2b
  jmp alltraps
80106c34:	e9 4f f8 ff ff       	jmp    80106488 <alltraps>

80106c39 <vector44>:
.globl vector44
vector44:
  pushl $0
80106c39:	6a 00                	push   $0x0
  pushl $44
80106c3b:	6a 2c                	push   $0x2c
  jmp alltraps
80106c3d:	e9 46 f8 ff ff       	jmp    80106488 <alltraps>

80106c42 <vector45>:
.globl vector45
vector45:
  pushl $0
80106c42:	6a 00                	push   $0x0
  pushl $45
80106c44:	6a 2d                	push   $0x2d
  jmp alltraps
80106c46:	e9 3d f8 ff ff       	jmp    80106488 <alltraps>

80106c4b <vector46>:
.globl vector46
vector46:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $46
80106c4d:	6a 2e                	push   $0x2e
  jmp alltraps
80106c4f:	e9 34 f8 ff ff       	jmp    80106488 <alltraps>

80106c54 <vector47>:
.globl vector47
vector47:
  pushl $0
80106c54:	6a 00                	push   $0x0
  pushl $47
80106c56:	6a 2f                	push   $0x2f
  jmp alltraps
80106c58:	e9 2b f8 ff ff       	jmp    80106488 <alltraps>

80106c5d <vector48>:
.globl vector48
vector48:
  pushl $0
80106c5d:	6a 00                	push   $0x0
  pushl $48
80106c5f:	6a 30                	push   $0x30
  jmp alltraps
80106c61:	e9 22 f8 ff ff       	jmp    80106488 <alltraps>

80106c66 <vector49>:
.globl vector49
vector49:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $49
80106c68:	6a 31                	push   $0x31
  jmp alltraps
80106c6a:	e9 19 f8 ff ff       	jmp    80106488 <alltraps>

80106c6f <vector50>:
.globl vector50
vector50:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $50
80106c71:	6a 32                	push   $0x32
  jmp alltraps
80106c73:	e9 10 f8 ff ff       	jmp    80106488 <alltraps>

80106c78 <vector51>:
.globl vector51
vector51:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $51
80106c7a:	6a 33                	push   $0x33
  jmp alltraps
80106c7c:	e9 07 f8 ff ff       	jmp    80106488 <alltraps>

80106c81 <vector52>:
.globl vector52
vector52:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $52
80106c83:	6a 34                	push   $0x34
  jmp alltraps
80106c85:	e9 fe f7 ff ff       	jmp    80106488 <alltraps>

80106c8a <vector53>:
.globl vector53
vector53:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $53
80106c8c:	6a 35                	push   $0x35
  jmp alltraps
80106c8e:	e9 f5 f7 ff ff       	jmp    80106488 <alltraps>

80106c93 <vector54>:
.globl vector54
vector54:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $54
80106c95:	6a 36                	push   $0x36
  jmp alltraps
80106c97:	e9 ec f7 ff ff       	jmp    80106488 <alltraps>

80106c9c <vector55>:
.globl vector55
vector55:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $55
80106c9e:	6a 37                	push   $0x37
  jmp alltraps
80106ca0:	e9 e3 f7 ff ff       	jmp    80106488 <alltraps>

80106ca5 <vector56>:
.globl vector56
vector56:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $56
80106ca7:	6a 38                	push   $0x38
  jmp alltraps
80106ca9:	e9 da f7 ff ff       	jmp    80106488 <alltraps>

80106cae <vector57>:
.globl vector57
vector57:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $57
80106cb0:	6a 39                	push   $0x39
  jmp alltraps
80106cb2:	e9 d1 f7 ff ff       	jmp    80106488 <alltraps>

80106cb7 <vector58>:
.globl vector58
vector58:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $58
80106cb9:	6a 3a                	push   $0x3a
  jmp alltraps
80106cbb:	e9 c8 f7 ff ff       	jmp    80106488 <alltraps>

80106cc0 <vector59>:
.globl vector59
vector59:
  pushl $0
80106cc0:	6a 00                	push   $0x0
  pushl $59
80106cc2:	6a 3b                	push   $0x3b
  jmp alltraps
80106cc4:	e9 bf f7 ff ff       	jmp    80106488 <alltraps>

80106cc9 <vector60>:
.globl vector60
vector60:
  pushl $0
80106cc9:	6a 00                	push   $0x0
  pushl $60
80106ccb:	6a 3c                	push   $0x3c
  jmp alltraps
80106ccd:	e9 b6 f7 ff ff       	jmp    80106488 <alltraps>

80106cd2 <vector61>:
.globl vector61
vector61:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $61
80106cd4:	6a 3d                	push   $0x3d
  jmp alltraps
80106cd6:	e9 ad f7 ff ff       	jmp    80106488 <alltraps>

80106cdb <vector62>:
.globl vector62
vector62:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $62
80106cdd:	6a 3e                	push   $0x3e
  jmp alltraps
80106cdf:	e9 a4 f7 ff ff       	jmp    80106488 <alltraps>

80106ce4 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ce4:	6a 00                	push   $0x0
  pushl $63
80106ce6:	6a 3f                	push   $0x3f
  jmp alltraps
80106ce8:	e9 9b f7 ff ff       	jmp    80106488 <alltraps>

80106ced <vector64>:
.globl vector64
vector64:
  pushl $0
80106ced:	6a 00                	push   $0x0
  pushl $64
80106cef:	6a 40                	push   $0x40
  jmp alltraps
80106cf1:	e9 92 f7 ff ff       	jmp    80106488 <alltraps>

80106cf6 <vector65>:
.globl vector65
vector65:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $65
80106cf8:	6a 41                	push   $0x41
  jmp alltraps
80106cfa:	e9 89 f7 ff ff       	jmp    80106488 <alltraps>

80106cff <vector66>:
.globl vector66
vector66:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $66
80106d01:	6a 42                	push   $0x42
  jmp alltraps
80106d03:	e9 80 f7 ff ff       	jmp    80106488 <alltraps>

80106d08 <vector67>:
.globl vector67
vector67:
  pushl $0
80106d08:	6a 00                	push   $0x0
  pushl $67
80106d0a:	6a 43                	push   $0x43
  jmp alltraps
80106d0c:	e9 77 f7 ff ff       	jmp    80106488 <alltraps>

80106d11 <vector68>:
.globl vector68
vector68:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $68
80106d13:	6a 44                	push   $0x44
  jmp alltraps
80106d15:	e9 6e f7 ff ff       	jmp    80106488 <alltraps>

80106d1a <vector69>:
.globl vector69
vector69:
  pushl $0
80106d1a:	6a 00                	push   $0x0
  pushl $69
80106d1c:	6a 45                	push   $0x45
  jmp alltraps
80106d1e:	e9 65 f7 ff ff       	jmp    80106488 <alltraps>

80106d23 <vector70>:
.globl vector70
vector70:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $70
80106d25:	6a 46                	push   $0x46
  jmp alltraps
80106d27:	e9 5c f7 ff ff       	jmp    80106488 <alltraps>

80106d2c <vector71>:
.globl vector71
vector71:
  pushl $0
80106d2c:	6a 00                	push   $0x0
  pushl $71
80106d2e:	6a 47                	push   $0x47
  jmp alltraps
80106d30:	e9 53 f7 ff ff       	jmp    80106488 <alltraps>

80106d35 <vector72>:
.globl vector72
vector72:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $72
80106d37:	6a 48                	push   $0x48
  jmp alltraps
80106d39:	e9 4a f7 ff ff       	jmp    80106488 <alltraps>

80106d3e <vector73>:
.globl vector73
vector73:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $73
80106d40:	6a 49                	push   $0x49
  jmp alltraps
80106d42:	e9 41 f7 ff ff       	jmp    80106488 <alltraps>

80106d47 <vector74>:
.globl vector74
vector74:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $74
80106d49:	6a 4a                	push   $0x4a
  jmp alltraps
80106d4b:	e9 38 f7 ff ff       	jmp    80106488 <alltraps>

80106d50 <vector75>:
.globl vector75
vector75:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $75
80106d52:	6a 4b                	push   $0x4b
  jmp alltraps
80106d54:	e9 2f f7 ff ff       	jmp    80106488 <alltraps>

80106d59 <vector76>:
.globl vector76
vector76:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $76
80106d5b:	6a 4c                	push   $0x4c
  jmp alltraps
80106d5d:	e9 26 f7 ff ff       	jmp    80106488 <alltraps>

80106d62 <vector77>:
.globl vector77
vector77:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $77
80106d64:	6a 4d                	push   $0x4d
  jmp alltraps
80106d66:	e9 1d f7 ff ff       	jmp    80106488 <alltraps>

80106d6b <vector78>:
.globl vector78
vector78:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $78
80106d6d:	6a 4e                	push   $0x4e
  jmp alltraps
80106d6f:	e9 14 f7 ff ff       	jmp    80106488 <alltraps>

80106d74 <vector79>:
.globl vector79
vector79:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $79
80106d76:	6a 4f                	push   $0x4f
  jmp alltraps
80106d78:	e9 0b f7 ff ff       	jmp    80106488 <alltraps>

80106d7d <vector80>:
.globl vector80
vector80:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $80
80106d7f:	6a 50                	push   $0x50
  jmp alltraps
80106d81:	e9 02 f7 ff ff       	jmp    80106488 <alltraps>

80106d86 <vector81>:
.globl vector81
vector81:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $81
80106d88:	6a 51                	push   $0x51
  jmp alltraps
80106d8a:	e9 f9 f6 ff ff       	jmp    80106488 <alltraps>

80106d8f <vector82>:
.globl vector82
vector82:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $82
80106d91:	6a 52                	push   $0x52
  jmp alltraps
80106d93:	e9 f0 f6 ff ff       	jmp    80106488 <alltraps>

80106d98 <vector83>:
.globl vector83
vector83:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $83
80106d9a:	6a 53                	push   $0x53
  jmp alltraps
80106d9c:	e9 e7 f6 ff ff       	jmp    80106488 <alltraps>

80106da1 <vector84>:
.globl vector84
vector84:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $84
80106da3:	6a 54                	push   $0x54
  jmp alltraps
80106da5:	e9 de f6 ff ff       	jmp    80106488 <alltraps>

80106daa <vector85>:
.globl vector85
vector85:
  pushl $0
80106daa:	6a 00                	push   $0x0
  pushl $85
80106dac:	6a 55                	push   $0x55
  jmp alltraps
80106dae:	e9 d5 f6 ff ff       	jmp    80106488 <alltraps>

80106db3 <vector86>:
.globl vector86
vector86:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $86
80106db5:	6a 56                	push   $0x56
  jmp alltraps
80106db7:	e9 cc f6 ff ff       	jmp    80106488 <alltraps>

80106dbc <vector87>:
.globl vector87
vector87:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $87
80106dbe:	6a 57                	push   $0x57
  jmp alltraps
80106dc0:	e9 c3 f6 ff ff       	jmp    80106488 <alltraps>

80106dc5 <vector88>:
.globl vector88
vector88:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $88
80106dc7:	6a 58                	push   $0x58
  jmp alltraps
80106dc9:	e9 ba f6 ff ff       	jmp    80106488 <alltraps>

80106dce <vector89>:
.globl vector89
vector89:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $89
80106dd0:	6a 59                	push   $0x59
  jmp alltraps
80106dd2:	e9 b1 f6 ff ff       	jmp    80106488 <alltraps>

80106dd7 <vector90>:
.globl vector90
vector90:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $90
80106dd9:	6a 5a                	push   $0x5a
  jmp alltraps
80106ddb:	e9 a8 f6 ff ff       	jmp    80106488 <alltraps>

80106de0 <vector91>:
.globl vector91
vector91:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $91
80106de2:	6a 5b                	push   $0x5b
  jmp alltraps
80106de4:	e9 9f f6 ff ff       	jmp    80106488 <alltraps>

80106de9 <vector92>:
.globl vector92
vector92:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $92
80106deb:	6a 5c                	push   $0x5c
  jmp alltraps
80106ded:	e9 96 f6 ff ff       	jmp    80106488 <alltraps>

80106df2 <vector93>:
.globl vector93
vector93:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $93
80106df4:	6a 5d                	push   $0x5d
  jmp alltraps
80106df6:	e9 8d f6 ff ff       	jmp    80106488 <alltraps>

80106dfb <vector94>:
.globl vector94
vector94:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $94
80106dfd:	6a 5e                	push   $0x5e
  jmp alltraps
80106dff:	e9 84 f6 ff ff       	jmp    80106488 <alltraps>

80106e04 <vector95>:
.globl vector95
vector95:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $95
80106e06:	6a 5f                	push   $0x5f
  jmp alltraps
80106e08:	e9 7b f6 ff ff       	jmp    80106488 <alltraps>

80106e0d <vector96>:
.globl vector96
vector96:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $96
80106e0f:	6a 60                	push   $0x60
  jmp alltraps
80106e11:	e9 72 f6 ff ff       	jmp    80106488 <alltraps>

80106e16 <vector97>:
.globl vector97
vector97:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $97
80106e18:	6a 61                	push   $0x61
  jmp alltraps
80106e1a:	e9 69 f6 ff ff       	jmp    80106488 <alltraps>

80106e1f <vector98>:
.globl vector98
vector98:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $98
80106e21:	6a 62                	push   $0x62
  jmp alltraps
80106e23:	e9 60 f6 ff ff       	jmp    80106488 <alltraps>

80106e28 <vector99>:
.globl vector99
vector99:
  pushl $0
80106e28:	6a 00                	push   $0x0
  pushl $99
80106e2a:	6a 63                	push   $0x63
  jmp alltraps
80106e2c:	e9 57 f6 ff ff       	jmp    80106488 <alltraps>

80106e31 <vector100>:
.globl vector100
vector100:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $100
80106e33:	6a 64                	push   $0x64
  jmp alltraps
80106e35:	e9 4e f6 ff ff       	jmp    80106488 <alltraps>

80106e3a <vector101>:
.globl vector101
vector101:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $101
80106e3c:	6a 65                	push   $0x65
  jmp alltraps
80106e3e:	e9 45 f6 ff ff       	jmp    80106488 <alltraps>

80106e43 <vector102>:
.globl vector102
vector102:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $102
80106e45:	6a 66                	push   $0x66
  jmp alltraps
80106e47:	e9 3c f6 ff ff       	jmp    80106488 <alltraps>

80106e4c <vector103>:
.globl vector103
vector103:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $103
80106e4e:	6a 67                	push   $0x67
  jmp alltraps
80106e50:	e9 33 f6 ff ff       	jmp    80106488 <alltraps>

80106e55 <vector104>:
.globl vector104
vector104:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $104
80106e57:	6a 68                	push   $0x68
  jmp alltraps
80106e59:	e9 2a f6 ff ff       	jmp    80106488 <alltraps>

80106e5e <vector105>:
.globl vector105
vector105:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $105
80106e60:	6a 69                	push   $0x69
  jmp alltraps
80106e62:	e9 21 f6 ff ff       	jmp    80106488 <alltraps>

80106e67 <vector106>:
.globl vector106
vector106:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $106
80106e69:	6a 6a                	push   $0x6a
  jmp alltraps
80106e6b:	e9 18 f6 ff ff       	jmp    80106488 <alltraps>

80106e70 <vector107>:
.globl vector107
vector107:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $107
80106e72:	6a 6b                	push   $0x6b
  jmp alltraps
80106e74:	e9 0f f6 ff ff       	jmp    80106488 <alltraps>

80106e79 <vector108>:
.globl vector108
vector108:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $108
80106e7b:	6a 6c                	push   $0x6c
  jmp alltraps
80106e7d:	e9 06 f6 ff ff       	jmp    80106488 <alltraps>

80106e82 <vector109>:
.globl vector109
vector109:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $109
80106e84:	6a 6d                	push   $0x6d
  jmp alltraps
80106e86:	e9 fd f5 ff ff       	jmp    80106488 <alltraps>

80106e8b <vector110>:
.globl vector110
vector110:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $110
80106e8d:	6a 6e                	push   $0x6e
  jmp alltraps
80106e8f:	e9 f4 f5 ff ff       	jmp    80106488 <alltraps>

80106e94 <vector111>:
.globl vector111
vector111:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $111
80106e96:	6a 6f                	push   $0x6f
  jmp alltraps
80106e98:	e9 eb f5 ff ff       	jmp    80106488 <alltraps>

80106e9d <vector112>:
.globl vector112
vector112:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $112
80106e9f:	6a 70                	push   $0x70
  jmp alltraps
80106ea1:	e9 e2 f5 ff ff       	jmp    80106488 <alltraps>

80106ea6 <vector113>:
.globl vector113
vector113:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $113
80106ea8:	6a 71                	push   $0x71
  jmp alltraps
80106eaa:	e9 d9 f5 ff ff       	jmp    80106488 <alltraps>

80106eaf <vector114>:
.globl vector114
vector114:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $114
80106eb1:	6a 72                	push   $0x72
  jmp alltraps
80106eb3:	e9 d0 f5 ff ff       	jmp    80106488 <alltraps>

80106eb8 <vector115>:
.globl vector115
vector115:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $115
80106eba:	6a 73                	push   $0x73
  jmp alltraps
80106ebc:	e9 c7 f5 ff ff       	jmp    80106488 <alltraps>

80106ec1 <vector116>:
.globl vector116
vector116:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $116
80106ec3:	6a 74                	push   $0x74
  jmp alltraps
80106ec5:	e9 be f5 ff ff       	jmp    80106488 <alltraps>

80106eca <vector117>:
.globl vector117
vector117:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $117
80106ecc:	6a 75                	push   $0x75
  jmp alltraps
80106ece:	e9 b5 f5 ff ff       	jmp    80106488 <alltraps>

80106ed3 <vector118>:
.globl vector118
vector118:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $118
80106ed5:	6a 76                	push   $0x76
  jmp alltraps
80106ed7:	e9 ac f5 ff ff       	jmp    80106488 <alltraps>

80106edc <vector119>:
.globl vector119
vector119:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $119
80106ede:	6a 77                	push   $0x77
  jmp alltraps
80106ee0:	e9 a3 f5 ff ff       	jmp    80106488 <alltraps>

80106ee5 <vector120>:
.globl vector120
vector120:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $120
80106ee7:	6a 78                	push   $0x78
  jmp alltraps
80106ee9:	e9 9a f5 ff ff       	jmp    80106488 <alltraps>

80106eee <vector121>:
.globl vector121
vector121:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $121
80106ef0:	6a 79                	push   $0x79
  jmp alltraps
80106ef2:	e9 91 f5 ff ff       	jmp    80106488 <alltraps>

80106ef7 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $122
80106ef9:	6a 7a                	push   $0x7a
  jmp alltraps
80106efb:	e9 88 f5 ff ff       	jmp    80106488 <alltraps>

80106f00 <vector123>:
.globl vector123
vector123:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $123
80106f02:	6a 7b                	push   $0x7b
  jmp alltraps
80106f04:	e9 7f f5 ff ff       	jmp    80106488 <alltraps>

80106f09 <vector124>:
.globl vector124
vector124:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $124
80106f0b:	6a 7c                	push   $0x7c
  jmp alltraps
80106f0d:	e9 76 f5 ff ff       	jmp    80106488 <alltraps>

80106f12 <vector125>:
.globl vector125
vector125:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $125
80106f14:	6a 7d                	push   $0x7d
  jmp alltraps
80106f16:	e9 6d f5 ff ff       	jmp    80106488 <alltraps>

80106f1b <vector126>:
.globl vector126
vector126:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $126
80106f1d:	6a 7e                	push   $0x7e
  jmp alltraps
80106f1f:	e9 64 f5 ff ff       	jmp    80106488 <alltraps>

80106f24 <vector127>:
.globl vector127
vector127:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $127
80106f26:	6a 7f                	push   $0x7f
  jmp alltraps
80106f28:	e9 5b f5 ff ff       	jmp    80106488 <alltraps>

80106f2d <vector128>:
.globl vector128
vector128:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $128
80106f2f:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f34:	e9 4f f5 ff ff       	jmp    80106488 <alltraps>

80106f39 <vector129>:
.globl vector129
vector129:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $129
80106f3b:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f40:	e9 43 f5 ff ff       	jmp    80106488 <alltraps>

80106f45 <vector130>:
.globl vector130
vector130:
  pushl $0
80106f45:	6a 00                	push   $0x0
  pushl $130
80106f47:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106f4c:	e9 37 f5 ff ff       	jmp    80106488 <alltraps>

80106f51 <vector131>:
.globl vector131
vector131:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $131
80106f53:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f58:	e9 2b f5 ff ff       	jmp    80106488 <alltraps>

80106f5d <vector132>:
.globl vector132
vector132:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $132
80106f5f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106f64:	e9 1f f5 ff ff       	jmp    80106488 <alltraps>

80106f69 <vector133>:
.globl vector133
vector133:
  pushl $0
80106f69:	6a 00                	push   $0x0
  pushl $133
80106f6b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106f70:	e9 13 f5 ff ff       	jmp    80106488 <alltraps>

80106f75 <vector134>:
.globl vector134
vector134:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $134
80106f77:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106f7c:	e9 07 f5 ff ff       	jmp    80106488 <alltraps>

80106f81 <vector135>:
.globl vector135
vector135:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $135
80106f83:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106f88:	e9 fb f4 ff ff       	jmp    80106488 <alltraps>

80106f8d <vector136>:
.globl vector136
vector136:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $136
80106f8f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106f94:	e9 ef f4 ff ff       	jmp    80106488 <alltraps>

80106f99 <vector137>:
.globl vector137
vector137:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $137
80106f9b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106fa0:	e9 e3 f4 ff ff       	jmp    80106488 <alltraps>

80106fa5 <vector138>:
.globl vector138
vector138:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $138
80106fa7:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106fac:	e9 d7 f4 ff ff       	jmp    80106488 <alltraps>

80106fb1 <vector139>:
.globl vector139
vector139:
  pushl $0
80106fb1:	6a 00                	push   $0x0
  pushl $139
80106fb3:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106fb8:	e9 cb f4 ff ff       	jmp    80106488 <alltraps>

80106fbd <vector140>:
.globl vector140
vector140:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $140
80106fbf:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106fc4:	e9 bf f4 ff ff       	jmp    80106488 <alltraps>

80106fc9 <vector141>:
.globl vector141
vector141:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $141
80106fcb:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106fd0:	e9 b3 f4 ff ff       	jmp    80106488 <alltraps>

80106fd5 <vector142>:
.globl vector142
vector142:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $142
80106fd7:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106fdc:	e9 a7 f4 ff ff       	jmp    80106488 <alltraps>

80106fe1 <vector143>:
.globl vector143
vector143:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $143
80106fe3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106fe8:	e9 9b f4 ff ff       	jmp    80106488 <alltraps>

80106fed <vector144>:
.globl vector144
vector144:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $144
80106fef:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106ff4:	e9 8f f4 ff ff       	jmp    80106488 <alltraps>

80106ff9 <vector145>:
.globl vector145
vector145:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $145
80106ffb:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107000:	e9 83 f4 ff ff       	jmp    80106488 <alltraps>

80107005 <vector146>:
.globl vector146
vector146:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $146
80107007:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010700c:	e9 77 f4 ff ff       	jmp    80106488 <alltraps>

80107011 <vector147>:
.globl vector147
vector147:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $147
80107013:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107018:	e9 6b f4 ff ff       	jmp    80106488 <alltraps>

8010701d <vector148>:
.globl vector148
vector148:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $148
8010701f:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107024:	e9 5f f4 ff ff       	jmp    80106488 <alltraps>

80107029 <vector149>:
.globl vector149
vector149:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $149
8010702b:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107030:	e9 53 f4 ff ff       	jmp    80106488 <alltraps>

80107035 <vector150>:
.globl vector150
vector150:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $150
80107037:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010703c:	e9 47 f4 ff ff       	jmp    80106488 <alltraps>

80107041 <vector151>:
.globl vector151
vector151:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $151
80107043:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107048:	e9 3b f4 ff ff       	jmp    80106488 <alltraps>

8010704d <vector152>:
.globl vector152
vector152:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $152
8010704f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107054:	e9 2f f4 ff ff       	jmp    80106488 <alltraps>

80107059 <vector153>:
.globl vector153
vector153:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $153
8010705b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107060:	e9 23 f4 ff ff       	jmp    80106488 <alltraps>

80107065 <vector154>:
.globl vector154
vector154:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $154
80107067:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010706c:	e9 17 f4 ff ff       	jmp    80106488 <alltraps>

80107071 <vector155>:
.globl vector155
vector155:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $155
80107073:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107078:	e9 0b f4 ff ff       	jmp    80106488 <alltraps>

8010707d <vector156>:
.globl vector156
vector156:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $156
8010707f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107084:	e9 ff f3 ff ff       	jmp    80106488 <alltraps>

80107089 <vector157>:
.globl vector157
vector157:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $157
8010708b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107090:	e9 f3 f3 ff ff       	jmp    80106488 <alltraps>

80107095 <vector158>:
.globl vector158
vector158:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $158
80107097:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010709c:	e9 e7 f3 ff ff       	jmp    80106488 <alltraps>

801070a1 <vector159>:
.globl vector159
vector159:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $159
801070a3:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801070a8:	e9 db f3 ff ff       	jmp    80106488 <alltraps>

801070ad <vector160>:
.globl vector160
vector160:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $160
801070af:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801070b4:	e9 cf f3 ff ff       	jmp    80106488 <alltraps>

801070b9 <vector161>:
.globl vector161
vector161:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $161
801070bb:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801070c0:	e9 c3 f3 ff ff       	jmp    80106488 <alltraps>

801070c5 <vector162>:
.globl vector162
vector162:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $162
801070c7:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801070cc:	e9 b7 f3 ff ff       	jmp    80106488 <alltraps>

801070d1 <vector163>:
.globl vector163
vector163:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $163
801070d3:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801070d8:	e9 ab f3 ff ff       	jmp    80106488 <alltraps>

801070dd <vector164>:
.globl vector164
vector164:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $164
801070df:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801070e4:	e9 9f f3 ff ff       	jmp    80106488 <alltraps>

801070e9 <vector165>:
.globl vector165
vector165:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $165
801070eb:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801070f0:	e9 93 f3 ff ff       	jmp    80106488 <alltraps>

801070f5 <vector166>:
.globl vector166
vector166:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $166
801070f7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801070fc:	e9 87 f3 ff ff       	jmp    80106488 <alltraps>

80107101 <vector167>:
.globl vector167
vector167:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $167
80107103:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107108:	e9 7b f3 ff ff       	jmp    80106488 <alltraps>

8010710d <vector168>:
.globl vector168
vector168:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $168
8010710f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107114:	e9 6f f3 ff ff       	jmp    80106488 <alltraps>

80107119 <vector169>:
.globl vector169
vector169:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $169
8010711b:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107120:	e9 63 f3 ff ff       	jmp    80106488 <alltraps>

80107125 <vector170>:
.globl vector170
vector170:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $170
80107127:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010712c:	e9 57 f3 ff ff       	jmp    80106488 <alltraps>

80107131 <vector171>:
.globl vector171
vector171:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $171
80107133:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107138:	e9 4b f3 ff ff       	jmp    80106488 <alltraps>

8010713d <vector172>:
.globl vector172
vector172:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $172
8010713f:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107144:	e9 3f f3 ff ff       	jmp    80106488 <alltraps>

80107149 <vector173>:
.globl vector173
vector173:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $173
8010714b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107150:	e9 33 f3 ff ff       	jmp    80106488 <alltraps>

80107155 <vector174>:
.globl vector174
vector174:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $174
80107157:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010715c:	e9 27 f3 ff ff       	jmp    80106488 <alltraps>

80107161 <vector175>:
.globl vector175
vector175:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $175
80107163:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107168:	e9 1b f3 ff ff       	jmp    80106488 <alltraps>

8010716d <vector176>:
.globl vector176
vector176:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $176
8010716f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107174:	e9 0f f3 ff ff       	jmp    80106488 <alltraps>

80107179 <vector177>:
.globl vector177
vector177:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $177
8010717b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107180:	e9 03 f3 ff ff       	jmp    80106488 <alltraps>

80107185 <vector178>:
.globl vector178
vector178:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $178
80107187:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010718c:	e9 f7 f2 ff ff       	jmp    80106488 <alltraps>

80107191 <vector179>:
.globl vector179
vector179:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $179
80107193:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107198:	e9 eb f2 ff ff       	jmp    80106488 <alltraps>

8010719d <vector180>:
.globl vector180
vector180:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $180
8010719f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801071a4:	e9 df f2 ff ff       	jmp    80106488 <alltraps>

801071a9 <vector181>:
.globl vector181
vector181:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $181
801071ab:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801071b0:	e9 d3 f2 ff ff       	jmp    80106488 <alltraps>

801071b5 <vector182>:
.globl vector182
vector182:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $182
801071b7:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801071bc:	e9 c7 f2 ff ff       	jmp    80106488 <alltraps>

801071c1 <vector183>:
.globl vector183
vector183:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $183
801071c3:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801071c8:	e9 bb f2 ff ff       	jmp    80106488 <alltraps>

801071cd <vector184>:
.globl vector184
vector184:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $184
801071cf:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801071d4:	e9 af f2 ff ff       	jmp    80106488 <alltraps>

801071d9 <vector185>:
.globl vector185
vector185:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $185
801071db:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801071e0:	e9 a3 f2 ff ff       	jmp    80106488 <alltraps>

801071e5 <vector186>:
.globl vector186
vector186:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $186
801071e7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801071ec:	e9 97 f2 ff ff       	jmp    80106488 <alltraps>

801071f1 <vector187>:
.globl vector187
vector187:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $187
801071f3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801071f8:	e9 8b f2 ff ff       	jmp    80106488 <alltraps>

801071fd <vector188>:
.globl vector188
vector188:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $188
801071ff:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107204:	e9 7f f2 ff ff       	jmp    80106488 <alltraps>

80107209 <vector189>:
.globl vector189
vector189:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $189
8010720b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107210:	e9 73 f2 ff ff       	jmp    80106488 <alltraps>

80107215 <vector190>:
.globl vector190
vector190:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $190
80107217:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010721c:	e9 67 f2 ff ff       	jmp    80106488 <alltraps>

80107221 <vector191>:
.globl vector191
vector191:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $191
80107223:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107228:	e9 5b f2 ff ff       	jmp    80106488 <alltraps>

8010722d <vector192>:
.globl vector192
vector192:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $192
8010722f:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107234:	e9 4f f2 ff ff       	jmp    80106488 <alltraps>

80107239 <vector193>:
.globl vector193
vector193:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $193
8010723b:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107240:	e9 43 f2 ff ff       	jmp    80106488 <alltraps>

80107245 <vector194>:
.globl vector194
vector194:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $194
80107247:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010724c:	e9 37 f2 ff ff       	jmp    80106488 <alltraps>

80107251 <vector195>:
.globl vector195
vector195:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $195
80107253:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107258:	e9 2b f2 ff ff       	jmp    80106488 <alltraps>

8010725d <vector196>:
.globl vector196
vector196:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $196
8010725f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107264:	e9 1f f2 ff ff       	jmp    80106488 <alltraps>

80107269 <vector197>:
.globl vector197
vector197:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $197
8010726b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107270:	e9 13 f2 ff ff       	jmp    80106488 <alltraps>

80107275 <vector198>:
.globl vector198
vector198:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $198
80107277:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010727c:	e9 07 f2 ff ff       	jmp    80106488 <alltraps>

80107281 <vector199>:
.globl vector199
vector199:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $199
80107283:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107288:	e9 fb f1 ff ff       	jmp    80106488 <alltraps>

8010728d <vector200>:
.globl vector200
vector200:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $200
8010728f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107294:	e9 ef f1 ff ff       	jmp    80106488 <alltraps>

80107299 <vector201>:
.globl vector201
vector201:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $201
8010729b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801072a0:	e9 e3 f1 ff ff       	jmp    80106488 <alltraps>

801072a5 <vector202>:
.globl vector202
vector202:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $202
801072a7:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801072ac:	e9 d7 f1 ff ff       	jmp    80106488 <alltraps>

801072b1 <vector203>:
.globl vector203
vector203:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $203
801072b3:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801072b8:	e9 cb f1 ff ff       	jmp    80106488 <alltraps>

801072bd <vector204>:
.globl vector204
vector204:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $204
801072bf:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801072c4:	e9 bf f1 ff ff       	jmp    80106488 <alltraps>

801072c9 <vector205>:
.globl vector205
vector205:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $205
801072cb:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801072d0:	e9 b3 f1 ff ff       	jmp    80106488 <alltraps>

801072d5 <vector206>:
.globl vector206
vector206:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $206
801072d7:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801072dc:	e9 a7 f1 ff ff       	jmp    80106488 <alltraps>

801072e1 <vector207>:
.globl vector207
vector207:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $207
801072e3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801072e8:	e9 9b f1 ff ff       	jmp    80106488 <alltraps>

801072ed <vector208>:
.globl vector208
vector208:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $208
801072ef:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801072f4:	e9 8f f1 ff ff       	jmp    80106488 <alltraps>

801072f9 <vector209>:
.globl vector209
vector209:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $209
801072fb:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107300:	e9 83 f1 ff ff       	jmp    80106488 <alltraps>

80107305 <vector210>:
.globl vector210
vector210:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $210
80107307:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010730c:	e9 77 f1 ff ff       	jmp    80106488 <alltraps>

80107311 <vector211>:
.globl vector211
vector211:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $211
80107313:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107318:	e9 6b f1 ff ff       	jmp    80106488 <alltraps>

8010731d <vector212>:
.globl vector212
vector212:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $212
8010731f:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107324:	e9 5f f1 ff ff       	jmp    80106488 <alltraps>

80107329 <vector213>:
.globl vector213
vector213:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $213
8010732b:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107330:	e9 53 f1 ff ff       	jmp    80106488 <alltraps>

80107335 <vector214>:
.globl vector214
vector214:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $214
80107337:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010733c:	e9 47 f1 ff ff       	jmp    80106488 <alltraps>

80107341 <vector215>:
.globl vector215
vector215:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $215
80107343:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107348:	e9 3b f1 ff ff       	jmp    80106488 <alltraps>

8010734d <vector216>:
.globl vector216
vector216:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $216
8010734f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107354:	e9 2f f1 ff ff       	jmp    80106488 <alltraps>

80107359 <vector217>:
.globl vector217
vector217:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $217
8010735b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107360:	e9 23 f1 ff ff       	jmp    80106488 <alltraps>

80107365 <vector218>:
.globl vector218
vector218:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $218
80107367:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010736c:	e9 17 f1 ff ff       	jmp    80106488 <alltraps>

80107371 <vector219>:
.globl vector219
vector219:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $219
80107373:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107378:	e9 0b f1 ff ff       	jmp    80106488 <alltraps>

8010737d <vector220>:
.globl vector220
vector220:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $220
8010737f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107384:	e9 ff f0 ff ff       	jmp    80106488 <alltraps>

80107389 <vector221>:
.globl vector221
vector221:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $221
8010738b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107390:	e9 f3 f0 ff ff       	jmp    80106488 <alltraps>

80107395 <vector222>:
.globl vector222
vector222:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $222
80107397:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010739c:	e9 e7 f0 ff ff       	jmp    80106488 <alltraps>

801073a1 <vector223>:
.globl vector223
vector223:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $223
801073a3:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801073a8:	e9 db f0 ff ff       	jmp    80106488 <alltraps>

801073ad <vector224>:
.globl vector224
vector224:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $224
801073af:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801073b4:	e9 cf f0 ff ff       	jmp    80106488 <alltraps>

801073b9 <vector225>:
.globl vector225
vector225:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $225
801073bb:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801073c0:	e9 c3 f0 ff ff       	jmp    80106488 <alltraps>

801073c5 <vector226>:
.globl vector226
vector226:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $226
801073c7:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801073cc:	e9 b7 f0 ff ff       	jmp    80106488 <alltraps>

801073d1 <vector227>:
.globl vector227
vector227:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $227
801073d3:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801073d8:	e9 ab f0 ff ff       	jmp    80106488 <alltraps>

801073dd <vector228>:
.globl vector228
vector228:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $228
801073df:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801073e4:	e9 9f f0 ff ff       	jmp    80106488 <alltraps>

801073e9 <vector229>:
.globl vector229
vector229:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $229
801073eb:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801073f0:	e9 93 f0 ff ff       	jmp    80106488 <alltraps>

801073f5 <vector230>:
.globl vector230
vector230:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $230
801073f7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801073fc:	e9 87 f0 ff ff       	jmp    80106488 <alltraps>

80107401 <vector231>:
.globl vector231
vector231:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $231
80107403:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107408:	e9 7b f0 ff ff       	jmp    80106488 <alltraps>

8010740d <vector232>:
.globl vector232
vector232:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $232
8010740f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107414:	e9 6f f0 ff ff       	jmp    80106488 <alltraps>

80107419 <vector233>:
.globl vector233
vector233:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $233
8010741b:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107420:	e9 63 f0 ff ff       	jmp    80106488 <alltraps>

80107425 <vector234>:
.globl vector234
vector234:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $234
80107427:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010742c:	e9 57 f0 ff ff       	jmp    80106488 <alltraps>

80107431 <vector235>:
.globl vector235
vector235:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $235
80107433:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107438:	e9 4b f0 ff ff       	jmp    80106488 <alltraps>

8010743d <vector236>:
.globl vector236
vector236:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $236
8010743f:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107444:	e9 3f f0 ff ff       	jmp    80106488 <alltraps>

80107449 <vector237>:
.globl vector237
vector237:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $237
8010744b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107450:	e9 33 f0 ff ff       	jmp    80106488 <alltraps>

80107455 <vector238>:
.globl vector238
vector238:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $238
80107457:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010745c:	e9 27 f0 ff ff       	jmp    80106488 <alltraps>

80107461 <vector239>:
.globl vector239
vector239:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $239
80107463:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107468:	e9 1b f0 ff ff       	jmp    80106488 <alltraps>

8010746d <vector240>:
.globl vector240
vector240:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $240
8010746f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107474:	e9 0f f0 ff ff       	jmp    80106488 <alltraps>

80107479 <vector241>:
.globl vector241
vector241:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $241
8010747b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107480:	e9 03 f0 ff ff       	jmp    80106488 <alltraps>

80107485 <vector242>:
.globl vector242
vector242:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $242
80107487:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010748c:	e9 f7 ef ff ff       	jmp    80106488 <alltraps>

80107491 <vector243>:
.globl vector243
vector243:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $243
80107493:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107498:	e9 eb ef ff ff       	jmp    80106488 <alltraps>

8010749d <vector244>:
.globl vector244
vector244:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $244
8010749f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801074a4:	e9 df ef ff ff       	jmp    80106488 <alltraps>

801074a9 <vector245>:
.globl vector245
vector245:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $245
801074ab:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801074b0:	e9 d3 ef ff ff       	jmp    80106488 <alltraps>

801074b5 <vector246>:
.globl vector246
vector246:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $246
801074b7:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801074bc:	e9 c7 ef ff ff       	jmp    80106488 <alltraps>

801074c1 <vector247>:
.globl vector247
vector247:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $247
801074c3:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801074c8:	e9 bb ef ff ff       	jmp    80106488 <alltraps>

801074cd <vector248>:
.globl vector248
vector248:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $248
801074cf:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801074d4:	e9 af ef ff ff       	jmp    80106488 <alltraps>

801074d9 <vector249>:
.globl vector249
vector249:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $249
801074db:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801074e0:	e9 a3 ef ff ff       	jmp    80106488 <alltraps>

801074e5 <vector250>:
.globl vector250
vector250:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $250
801074e7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801074ec:	e9 97 ef ff ff       	jmp    80106488 <alltraps>

801074f1 <vector251>:
.globl vector251
vector251:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $251
801074f3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801074f8:	e9 8b ef ff ff       	jmp    80106488 <alltraps>

801074fd <vector252>:
.globl vector252
vector252:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $252
801074ff:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107504:	e9 7f ef ff ff       	jmp    80106488 <alltraps>

80107509 <vector253>:
.globl vector253
vector253:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $253
8010750b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107510:	e9 73 ef ff ff       	jmp    80106488 <alltraps>

80107515 <vector254>:
.globl vector254
vector254:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $254
80107517:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010751c:	e9 67 ef ff ff       	jmp    80106488 <alltraps>

80107521 <vector255>:
.globl vector255
vector255:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $255
80107523:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107528:	e9 5b ef ff ff       	jmp    80106488 <alltraps>

8010752d <lgdt>:
{
8010752d:	55                   	push   %ebp
8010752e:	89 e5                	mov    %esp,%ebp
80107530:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107533:	8b 45 0c             	mov    0xc(%ebp),%eax
80107536:	83 e8 01             	sub    $0x1,%eax
80107539:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010753d:	8b 45 08             	mov    0x8(%ebp),%eax
80107540:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107544:	8b 45 08             	mov    0x8(%ebp),%eax
80107547:	c1 e8 10             	shr    $0x10,%eax
8010754a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010754e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107551:	0f 01 10             	lgdtl  (%eax)
}
80107554:	90                   	nop
80107555:	c9                   	leave
80107556:	c3                   	ret

80107557 <ltr>:
{
80107557:	55                   	push   %ebp
80107558:	89 e5                	mov    %esp,%ebp
8010755a:	83 ec 04             	sub    $0x4,%esp
8010755d:	8b 45 08             	mov    0x8(%ebp),%eax
80107560:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107564:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107568:	0f 00 d8             	ltr    %eax
}
8010756b:	90                   	nop
8010756c:	c9                   	leave
8010756d:	c3                   	ret

8010756e <lcr3>:

static inline void
lcr3(uint val)
{
8010756e:	55                   	push   %ebp
8010756f:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107571:	8b 45 08             	mov    0x8(%ebp),%eax
80107574:	0f 22 d8             	mov    %eax,%cr3
}
80107577:	90                   	nop
80107578:	5d                   	pop    %ebp
80107579:	c3                   	ret

8010757a <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010757a:	55                   	push   %ebp
8010757b:	89 e5                	mov    %esp,%ebp
8010757d:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107580:	e8 fa c8 ff ff       	call   80103e7f <cpuid>
80107585:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010758b:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80107590:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107596:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010759c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801075a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a8:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801075ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075af:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075b3:	83 e2 f0             	and    $0xfffffff0,%edx
801075b6:	83 ca 0a             	or     $0xa,%edx
801075b9:	88 50 7d             	mov    %dl,0x7d(%eax)
801075bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bf:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075c3:	83 ca 10             	or     $0x10,%edx
801075c6:	88 50 7d             	mov    %dl,0x7d(%eax)
801075c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075d0:	83 e2 9f             	and    $0xffffff9f,%edx
801075d3:	88 50 7d             	mov    %dl,0x7d(%eax)
801075d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075dd:	83 ca 80             	or     $0xffffff80,%edx
801075e0:	88 50 7d             	mov    %dl,0x7d(%eax)
801075e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075ea:	83 ca 0f             	or     $0xf,%edx
801075ed:	88 50 7e             	mov    %dl,0x7e(%eax)
801075f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801075f7:	83 e2 ef             	and    $0xffffffef,%edx
801075fa:	88 50 7e             	mov    %dl,0x7e(%eax)
801075fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107600:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107604:	83 e2 df             	and    $0xffffffdf,%edx
80107607:	88 50 7e             	mov    %dl,0x7e(%eax)
8010760a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107611:	83 ca 40             	or     $0x40,%edx
80107614:	88 50 7e             	mov    %dl,0x7e(%eax)
80107617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010761a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010761e:	83 ca 80             	or     $0xffffff80,%edx
80107621:	88 50 7e             	mov    %dl,0x7e(%eax)
80107624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107627:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010762b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107635:	ff ff 
80107637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107641:	00 00 
80107643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107646:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010764d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107650:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107657:	83 e2 f0             	and    $0xfffffff0,%edx
8010765a:	83 ca 02             	or     $0x2,%edx
8010765d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107666:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010766d:	83 ca 10             	or     $0x10,%edx
80107670:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107679:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107680:	83 e2 9f             	and    $0xffffff9f,%edx
80107683:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107689:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107693:	83 ca 80             	or     $0xffffff80,%edx
80107696:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010769c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076a6:	83 ca 0f             	or     $0xf,%edx
801076a9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076b9:	83 e2 ef             	and    $0xffffffef,%edx
801076bc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076cc:	83 e2 df             	and    $0xffffffdf,%edx
801076cf:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076df:	83 ca 40             	or     $0x40,%edx
801076e2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076eb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076f2:	83 ca 80             	or     $0xffffff80,%edx
801076f5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fe:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107708:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010770f:	ff ff 
80107711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107714:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010771b:	00 00 
8010771d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107720:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107731:	83 e2 f0             	and    $0xfffffff0,%edx
80107734:	83 ca 0a             	or     $0xa,%edx
80107737:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010773d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107740:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107747:	83 ca 10             	or     $0x10,%edx
8010774a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107753:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010775a:	83 ca 60             	or     $0x60,%edx
8010775d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107766:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010776d:	83 ca 80             	or     $0xffffff80,%edx
80107770:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107779:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107780:	83 ca 0f             	or     $0xf,%edx
80107783:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107789:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778c:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107793:	83 e2 ef             	and    $0xffffffef,%edx
80107796:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010779c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077a6:	83 e2 df             	and    $0xffffffdf,%edx
801077a9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077b9:	83 ca 40             	or     $0x40,%edx
801077bc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077cc:	83 ca 80             	or     $0xffffff80,%edx
801077cf:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d8:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801077df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e2:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801077e9:	ff ff 
801077eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ee:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801077f5:	00 00 
801077f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fa:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107804:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010780b:	83 e2 f0             	and    $0xfffffff0,%edx
8010780e:	83 ca 02             	or     $0x2,%edx
80107811:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107821:	83 ca 10             	or     $0x10,%edx
80107824:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010782a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107834:	83 ca 60             	or     $0x60,%edx
80107837:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010783d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107840:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107847:	83 ca 80             	or     $0xffffff80,%edx
8010784a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107853:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010785a:	83 ca 0f             	or     $0xf,%edx
8010785d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107866:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010786d:	83 e2 ef             	and    $0xffffffef,%edx
80107870:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107879:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107880:	83 e2 df             	and    $0xffffffdf,%edx
80107883:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107893:	83 ca 40             	or     $0x40,%edx
80107896:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010789c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078a6:	83 ca 80             	or     $0xffffff80,%edx
801078a9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b2:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801078b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bc:	83 c0 70             	add    $0x70,%eax
801078bf:	83 ec 08             	sub    $0x8,%esp
801078c2:	6a 30                	push   $0x30
801078c4:	50                   	push   %eax
801078c5:	e8 63 fc ff ff       	call   8010752d <lgdt>
801078ca:	83 c4 10             	add    $0x10,%esp
}
801078cd:	90                   	nop
801078ce:	c9                   	leave
801078cf:	c3                   	ret

801078d0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801078d0:	55                   	push   %ebp
801078d1:	89 e5                	mov    %esp,%ebp
801078d3:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801078d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801078d9:	c1 e8 16             	shr    $0x16,%eax
801078dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078e3:	8b 45 08             	mov    0x8(%ebp),%eax
801078e6:	01 d0                	add    %edx,%eax
801078e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801078eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078ee:	8b 00                	mov    (%eax),%eax
801078f0:	83 e0 01             	and    $0x1,%eax
801078f3:	85 c0                	test   %eax,%eax
801078f5:	74 14                	je     8010790b <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801078f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078fa:	8b 00                	mov    (%eax),%eax
801078fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107901:	05 00 00 00 80       	add    $0x80000000,%eax
80107906:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107909:	eb 42                	jmp    8010794d <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010790b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010790f:	74 0e                	je     8010791f <walkpgdir+0x4f>
80107911:	e8 74 b3 ff ff       	call   80102c8a <kalloc>
80107916:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107919:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010791d:	75 07                	jne    80107926 <walkpgdir+0x56>
      return 0;
8010791f:	b8 00 00 00 00       	mov    $0x0,%eax
80107924:	eb 3e                	jmp    80107964 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107926:	83 ec 04             	sub    $0x4,%esp
80107929:	68 00 10 00 00       	push   $0x1000
8010792e:	6a 00                	push   $0x0
80107930:	ff 75 f4             	push   -0xc(%ebp)
80107933:	e8 72 d7 ff ff       	call   801050aa <memset>
80107938:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010793b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793e:	05 00 00 00 80       	add    $0x80000000,%eax
80107943:	83 c8 07             	or     $0x7,%eax
80107946:	89 c2                	mov    %eax,%edx
80107948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010794b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010794d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107950:	c1 e8 0c             	shr    $0xc,%eax
80107953:	25 ff 03 00 00       	and    $0x3ff,%eax
80107958:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010795f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107962:	01 d0                	add    %edx,%eax
}
80107964:	c9                   	leave
80107965:	c3                   	ret

80107966 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107966:	55                   	push   %ebp
80107967:	89 e5                	mov    %esp,%ebp
80107969:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010796c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010796f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107974:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107977:	8b 55 0c             	mov    0xc(%ebp),%edx
8010797a:	8b 45 10             	mov    0x10(%ebp),%eax
8010797d:	01 d0                	add    %edx,%eax
8010797f:	83 e8 01             	sub    $0x1,%eax
80107982:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107987:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010798a:	83 ec 04             	sub    $0x4,%esp
8010798d:	6a 01                	push   $0x1
8010798f:	ff 75 f4             	push   -0xc(%ebp)
80107992:	ff 75 08             	push   0x8(%ebp)
80107995:	e8 36 ff ff ff       	call   801078d0 <walkpgdir>
8010799a:	83 c4 10             	add    $0x10,%esp
8010799d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079a4:	75 07                	jne    801079ad <mappages+0x47>
      return -1;
801079a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079ab:	eb 47                	jmp    801079f4 <mappages+0x8e>
    if(*pte & PTE_P)
801079ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079b0:	8b 00                	mov    (%eax),%eax
801079b2:	83 e0 01             	and    $0x1,%eax
801079b5:	85 c0                	test   %eax,%eax
801079b7:	74 0d                	je     801079c6 <mappages+0x60>
      panic("remap");
801079b9:	83 ec 0c             	sub    $0xc,%esp
801079bc:	68 ec ab 10 80       	push   $0x8010abec
801079c1:	e8 e3 8b ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801079c6:	8b 45 18             	mov    0x18(%ebp),%eax
801079c9:	0b 45 14             	or     0x14(%ebp),%eax
801079cc:	83 c8 01             	or     $0x1,%eax
801079cf:	89 c2                	mov    %eax,%edx
801079d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079d4:	89 10                	mov    %edx,(%eax)
    if(a == last)
801079d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801079dc:	74 10                	je     801079ee <mappages+0x88>
      break;
    a += PGSIZE;
801079de:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801079e5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801079ec:	eb 9c                	jmp    8010798a <mappages+0x24>
      break;
801079ee:	90                   	nop
  }
  return 0;
801079ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801079f4:	c9                   	leave
801079f5:	c3                   	ret

801079f6 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801079f6:	55                   	push   %ebp
801079f7:	89 e5                	mov    %esp,%ebp
801079f9:	53                   	push   %ebx
801079fa:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801079fd:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107a04:	a1 90 9d 11 80       	mov    0x80119d90,%eax
80107a09:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107a0e:	29 c2                	sub    %eax,%edx
80107a10:	89 d0                	mov    %edx,%eax
80107a12:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a15:	a1 88 9d 11 80       	mov    0x80119d88,%eax
80107a1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a1d:	8b 15 88 9d 11 80    	mov    0x80119d88,%edx
80107a23:	a1 90 9d 11 80       	mov    0x80119d90,%eax
80107a28:	01 d0                	add    %edx,%eax
80107a2a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107a2d:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a37:	83 c0 30             	add    $0x30,%eax
80107a3a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107a3d:	89 10                	mov    %edx,(%eax)
80107a3f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a42:	89 50 04             	mov    %edx,0x4(%eax)
80107a45:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a48:	89 50 08             	mov    %edx,0x8(%eax)
80107a4b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107a4e:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107a51:	e8 34 b2 ff ff       	call   80102c8a <kalloc>
80107a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107a59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a5d:	75 07                	jne    80107a66 <setupkvm+0x70>
    return 0;
80107a5f:	b8 00 00 00 00       	mov    $0x0,%eax
80107a64:	eb 78                	jmp    80107ade <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107a66:	83 ec 04             	sub    $0x4,%esp
80107a69:	68 00 10 00 00       	push   $0x1000
80107a6e:	6a 00                	push   $0x0
80107a70:	ff 75 f0             	push   -0x10(%ebp)
80107a73:	e8 32 d6 ff ff       	call   801050aa <memset>
80107a78:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107a7b:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107a82:	eb 4e                	jmp    80107ad2 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a87:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8d:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a93:	8b 58 08             	mov    0x8(%eax),%ebx
80107a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a99:	8b 40 04             	mov    0x4(%eax),%eax
80107a9c:	29 c3                	sub    %eax,%ebx
80107a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa1:	8b 00                	mov    (%eax),%eax
80107aa3:	83 ec 0c             	sub    $0xc,%esp
80107aa6:	51                   	push   %ecx
80107aa7:	52                   	push   %edx
80107aa8:	53                   	push   %ebx
80107aa9:	50                   	push   %eax
80107aaa:	ff 75 f0             	push   -0x10(%ebp)
80107aad:	e8 b4 fe ff ff       	call   80107966 <mappages>
80107ab2:	83 c4 20             	add    $0x20,%esp
80107ab5:	85 c0                	test   %eax,%eax
80107ab7:	79 15                	jns    80107ace <setupkvm+0xd8>
      freevm(pgdir);
80107ab9:	83 ec 0c             	sub    $0xc,%esp
80107abc:	ff 75 f0             	push   -0x10(%ebp)
80107abf:	e8 f5 04 00 00       	call   80107fb9 <freevm>
80107ac4:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ac7:	b8 00 00 00 00       	mov    $0x0,%eax
80107acc:	eb 10                	jmp    80107ade <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ace:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107ad2:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107ad9:	72 a9                	jb     80107a84 <setupkvm+0x8e>
    }
  return pgdir;
80107adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107ade:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107ae1:	c9                   	leave
80107ae2:	c3                   	ret

80107ae3 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107ae3:	55                   	push   %ebp
80107ae4:	89 e5                	mov    %esp,%ebp
80107ae6:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107ae9:	e8 08 ff ff ff       	call   801079f6 <setupkvm>
80107aee:	a3 bc 9a 11 80       	mov    %eax,0x80119abc
  switchkvm();
80107af3:	e8 03 00 00 00       	call   80107afb <switchkvm>
}
80107af8:	90                   	nop
80107af9:	c9                   	leave
80107afa:	c3                   	ret

80107afb <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107afb:	55                   	push   %ebp
80107afc:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107afe:	a1 bc 9a 11 80       	mov    0x80119abc,%eax
80107b03:	05 00 00 00 80       	add    $0x80000000,%eax
80107b08:	50                   	push   %eax
80107b09:	e8 60 fa ff ff       	call   8010756e <lcr3>
80107b0e:	83 c4 04             	add    $0x4,%esp
}
80107b11:	90                   	nop
80107b12:	c9                   	leave
80107b13:	c3                   	ret

80107b14 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107b14:	55                   	push   %ebp
80107b15:	89 e5                	mov    %esp,%ebp
80107b17:	56                   	push   %esi
80107b18:	53                   	push   %ebx
80107b19:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107b1c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b20:	75 0d                	jne    80107b2f <switchuvm+0x1b>
    panic("switchuvm: no process");
80107b22:	83 ec 0c             	sub    $0xc,%esp
80107b25:	68 f2 ab 10 80       	push   $0x8010abf2
80107b2a:	e8 7a 8a ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b32:	8b 40 08             	mov    0x8(%eax),%eax
80107b35:	85 c0                	test   %eax,%eax
80107b37:	75 0d                	jne    80107b46 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107b39:	83 ec 0c             	sub    $0xc,%esp
80107b3c:	68 08 ac 10 80       	push   $0x8010ac08
80107b41:	e8 63 8a ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107b46:	8b 45 08             	mov    0x8(%ebp),%eax
80107b49:	8b 40 04             	mov    0x4(%eax),%eax
80107b4c:	85 c0                	test   %eax,%eax
80107b4e:	75 0d                	jne    80107b5d <switchuvm+0x49>
    panic("switchuvm: no pgdir");
80107b50:	83 ec 0c             	sub    $0xc,%esp
80107b53:	68 1d ac 10 80       	push   $0x8010ac1d
80107b58:	e8 4c 8a ff ff       	call   801005a9 <panic>

  pushcli();
80107b5d:	e8 3d d4 ff ff       	call   80104f9f <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107b62:	e8 33 c3 ff ff       	call   80103e9a <mycpu>
80107b67:	89 c3                	mov    %eax,%ebx
80107b69:	e8 2c c3 ff ff       	call   80103e9a <mycpu>
80107b6e:	83 c0 08             	add    $0x8,%eax
80107b71:	89 c6                	mov    %eax,%esi
80107b73:	e8 22 c3 ff ff       	call   80103e9a <mycpu>
80107b78:	83 c0 08             	add    $0x8,%eax
80107b7b:	c1 e8 10             	shr    $0x10,%eax
80107b7e:	88 45 f7             	mov    %al,-0x9(%ebp)
80107b81:	e8 14 c3 ff ff       	call   80103e9a <mycpu>
80107b86:	83 c0 08             	add    $0x8,%eax
80107b89:	c1 e8 18             	shr    $0x18,%eax
80107b8c:	89 c2                	mov    %eax,%edx
80107b8e:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107b95:	67 00 
80107b97:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107b9e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107ba2:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107ba8:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107baf:	83 e0 f0             	and    $0xfffffff0,%eax
80107bb2:	83 c8 09             	or     $0x9,%eax
80107bb5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bbb:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107bc2:	83 c8 10             	or     $0x10,%eax
80107bc5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bcb:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107bd2:	83 e0 9f             	and    $0xffffff9f,%eax
80107bd5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107bdb:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107be2:	83 c8 80             	or     $0xffffff80,%eax
80107be5:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107beb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107bf2:	83 e0 f0             	and    $0xfffffff0,%eax
80107bf5:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107bfb:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c02:	83 e0 ef             	and    $0xffffffef,%eax
80107c05:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c0b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c12:	83 e0 df             	and    $0xffffffdf,%eax
80107c15:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c1b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c22:	83 c8 40             	or     $0x40,%eax
80107c25:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c2b:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c32:	83 e0 7f             	and    $0x7f,%eax
80107c35:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c3b:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107c41:	e8 54 c2 ff ff       	call   80103e9a <mycpu>
80107c46:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c4d:	83 e2 ef             	and    $0xffffffef,%edx
80107c50:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107c56:	e8 3f c2 ff ff       	call   80103e9a <mycpu>
80107c5b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107c61:	8b 45 08             	mov    0x8(%ebp),%eax
80107c64:	8b 40 08             	mov    0x8(%eax),%eax
80107c67:	89 c3                	mov    %eax,%ebx
80107c69:	e8 2c c2 ff ff       	call   80103e9a <mycpu>
80107c6e:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107c74:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107c77:	e8 1e c2 ff ff       	call   80103e9a <mycpu>
80107c7c:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107c82:	83 ec 0c             	sub    $0xc,%esp
80107c85:	6a 28                	push   $0x28
80107c87:	e8 cb f8 ff ff       	call   80107557 <ltr>
80107c8c:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80107c92:	8b 40 04             	mov    0x4(%eax),%eax
80107c95:	05 00 00 00 80       	add    $0x80000000,%eax
80107c9a:	83 ec 0c             	sub    $0xc,%esp
80107c9d:	50                   	push   %eax
80107c9e:	e8 cb f8 ff ff       	call   8010756e <lcr3>
80107ca3:	83 c4 10             	add    $0x10,%esp
  popcli();
80107ca6:	e8 41 d3 ff ff       	call   80104fec <popcli>
}
80107cab:	90                   	nop
80107cac:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107caf:	5b                   	pop    %ebx
80107cb0:	5e                   	pop    %esi
80107cb1:	5d                   	pop    %ebp
80107cb2:	c3                   	ret

80107cb3 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107cb3:	55                   	push   %ebp
80107cb4:	89 e5                	mov    %esp,%ebp
80107cb6:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107cb9:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107cc0:	76 0d                	jbe    80107ccf <inituvm+0x1c>
    panic("inituvm: more than a page");
80107cc2:	83 ec 0c             	sub    $0xc,%esp
80107cc5:	68 31 ac 10 80       	push   $0x8010ac31
80107cca:	e8 da 88 ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107ccf:	e8 b6 af ff ff       	call   80102c8a <kalloc>
80107cd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107cd7:	83 ec 04             	sub    $0x4,%esp
80107cda:	68 00 10 00 00       	push   $0x1000
80107cdf:	6a 00                	push   $0x0
80107ce1:	ff 75 f4             	push   -0xc(%ebp)
80107ce4:	e8 c1 d3 ff ff       	call   801050aa <memset>
80107ce9:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cef:	05 00 00 00 80       	add    $0x80000000,%eax
80107cf4:	83 ec 0c             	sub    $0xc,%esp
80107cf7:	6a 06                	push   $0x6
80107cf9:	50                   	push   %eax
80107cfa:	68 00 10 00 00       	push   $0x1000
80107cff:	6a 00                	push   $0x0
80107d01:	ff 75 08             	push   0x8(%ebp)
80107d04:	e8 5d fc ff ff       	call   80107966 <mappages>
80107d09:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107d0c:	83 ec 04             	sub    $0x4,%esp
80107d0f:	ff 75 10             	push   0x10(%ebp)
80107d12:	ff 75 0c             	push   0xc(%ebp)
80107d15:	ff 75 f4             	push   -0xc(%ebp)
80107d18:	e8 4c d4 ff ff       	call   80105169 <memmove>
80107d1d:	83 c4 10             	add    $0x10,%esp
}
80107d20:	90                   	nop
80107d21:	c9                   	leave
80107d22:	c3                   	ret

80107d23 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107d23:	55                   	push   %ebp
80107d24:	89 e5                	mov    %esp,%ebp
80107d26:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107d29:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d2c:	25 ff 0f 00 00       	and    $0xfff,%eax
80107d31:	85 c0                	test   %eax,%eax
80107d33:	74 0d                	je     80107d42 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107d35:	83 ec 0c             	sub    $0xc,%esp
80107d38:	68 4c ac 10 80       	push   $0x8010ac4c
80107d3d:	e8 67 88 ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107d42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d49:	e9 8f 00 00 00       	jmp    80107ddd <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107d4e:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d54:	01 d0                	add    %edx,%eax
80107d56:	83 ec 04             	sub    $0x4,%esp
80107d59:	6a 00                	push   $0x0
80107d5b:	50                   	push   %eax
80107d5c:	ff 75 08             	push   0x8(%ebp)
80107d5f:	e8 6c fb ff ff       	call   801078d0 <walkpgdir>
80107d64:	83 c4 10             	add    $0x10,%esp
80107d67:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d6a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d6e:	75 0d                	jne    80107d7d <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107d70:	83 ec 0c             	sub    $0xc,%esp
80107d73:	68 6f ac 10 80       	push   $0x8010ac6f
80107d78:	e8 2c 88 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107d7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d80:	8b 00                	mov    (%eax),%eax
80107d82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d87:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107d8a:	8b 45 18             	mov    0x18(%ebp),%eax
80107d8d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d90:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107d95:	77 0b                	ja     80107da2 <loaduvm+0x7f>
      n = sz - i;
80107d97:	8b 45 18             	mov    0x18(%ebp),%eax
80107d9a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107d9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107da0:	eb 07                	jmp    80107da9 <loaduvm+0x86>
    else
      n = PGSIZE;
80107da2:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107da9:	8b 55 14             	mov    0x14(%ebp),%edx
80107dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daf:	01 d0                	add    %edx,%eax
80107db1:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107db4:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107dba:	ff 75 f0             	push   -0x10(%ebp)
80107dbd:	50                   	push   %eax
80107dbe:	52                   	push   %edx
80107dbf:	ff 75 10             	push   0x10(%ebp)
80107dc2:	e8 17 a1 ff ff       	call   80101ede <readi>
80107dc7:	83 c4 10             	add    $0x10,%esp
80107dca:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107dcd:	74 07                	je     80107dd6 <loaduvm+0xb3>
      return -1;
80107dcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107dd4:	eb 18                	jmp    80107dee <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107dd6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de0:	3b 45 18             	cmp    0x18(%ebp),%eax
80107de3:	0f 82 65 ff ff ff    	jb     80107d4e <loaduvm+0x2b>
  }
  return 0;
80107de9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107dee:	c9                   	leave
80107def:	c3                   	ret

80107df0 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107df0:	55                   	push   %ebp
80107df1:	89 e5                	mov    %esp,%ebp
80107df3:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107df6:	8b 45 10             	mov    0x10(%ebp),%eax
80107df9:	85 c0                	test   %eax,%eax
80107dfb:	79 0a                	jns    80107e07 <allocuvm+0x17>
    return 0;
80107dfd:	b8 00 00 00 00       	mov    $0x0,%eax
80107e02:	e9 ec 00 00 00       	jmp    80107ef3 <allocuvm+0x103>
  if(newsz < oldsz)
80107e07:	8b 45 10             	mov    0x10(%ebp),%eax
80107e0a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e0d:	73 08                	jae    80107e17 <allocuvm+0x27>
    return oldsz;
80107e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e12:	e9 dc 00 00 00       	jmp    80107ef3 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e1a:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107e27:	e9 b8 00 00 00       	jmp    80107ee4 <allocuvm+0xf4>
    mem = kalloc();
80107e2c:	e8 59 ae ff ff       	call   80102c8a <kalloc>
80107e31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107e34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e38:	75 2e                	jne    80107e68 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107e3a:	83 ec 0c             	sub    $0xc,%esp
80107e3d:	68 8d ac 10 80       	push   $0x8010ac8d
80107e42:	e8 ad 85 ff ff       	call   801003f4 <cprintf>
80107e47:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107e4a:	83 ec 04             	sub    $0x4,%esp
80107e4d:	ff 75 0c             	push   0xc(%ebp)
80107e50:	ff 75 10             	push   0x10(%ebp)
80107e53:	ff 75 08             	push   0x8(%ebp)
80107e56:	e8 9a 00 00 00       	call   80107ef5 <deallocuvm>
80107e5b:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e5e:	b8 00 00 00 00       	mov    $0x0,%eax
80107e63:	e9 8b 00 00 00       	jmp    80107ef3 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107e68:	83 ec 04             	sub    $0x4,%esp
80107e6b:	68 00 10 00 00       	push   $0x1000
80107e70:	6a 00                	push   $0x0
80107e72:	ff 75 f0             	push   -0x10(%ebp)
80107e75:	e8 30 d2 ff ff       	call   801050aa <memset>
80107e7a:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e80:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e89:	83 ec 0c             	sub    $0xc,%esp
80107e8c:	6a 06                	push   $0x6
80107e8e:	52                   	push   %edx
80107e8f:	68 00 10 00 00       	push   $0x1000
80107e94:	50                   	push   %eax
80107e95:	ff 75 08             	push   0x8(%ebp)
80107e98:	e8 c9 fa ff ff       	call   80107966 <mappages>
80107e9d:	83 c4 20             	add    $0x20,%esp
80107ea0:	85 c0                	test   %eax,%eax
80107ea2:	79 39                	jns    80107edd <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107ea4:	83 ec 0c             	sub    $0xc,%esp
80107ea7:	68 a5 ac 10 80       	push   $0x8010aca5
80107eac:	e8 43 85 ff ff       	call   801003f4 <cprintf>
80107eb1:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107eb4:	83 ec 04             	sub    $0x4,%esp
80107eb7:	ff 75 0c             	push   0xc(%ebp)
80107eba:	ff 75 10             	push   0x10(%ebp)
80107ebd:	ff 75 08             	push   0x8(%ebp)
80107ec0:	e8 30 00 00 00       	call   80107ef5 <deallocuvm>
80107ec5:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107ec8:	83 ec 0c             	sub    $0xc,%esp
80107ecb:	ff 75 f0             	push   -0x10(%ebp)
80107ece:	e8 1d ad ff ff       	call   80102bf0 <kfree>
80107ed3:	83 c4 10             	add    $0x10,%esp
      return 0;
80107ed6:	b8 00 00 00 00       	mov    $0x0,%eax
80107edb:	eb 16                	jmp    80107ef3 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107edd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee7:	3b 45 10             	cmp    0x10(%ebp),%eax
80107eea:	0f 82 3c ff ff ff    	jb     80107e2c <allocuvm+0x3c>
    }
  }
  return newsz;
80107ef0:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ef3:	c9                   	leave
80107ef4:	c3                   	ret

80107ef5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ef5:	55                   	push   %ebp
80107ef6:	89 e5                	mov    %esp,%ebp
80107ef8:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107efb:	8b 45 10             	mov    0x10(%ebp),%eax
80107efe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f01:	72 08                	jb     80107f0b <deallocuvm+0x16>
    return oldsz;
80107f03:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f06:	e9 ac 00 00 00       	jmp    80107fb7 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107f0b:	8b 45 10             	mov    0x10(%ebp),%eax
80107f0e:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107f1b:	e9 88 00 00 00       	jmp    80107fa8 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f23:	83 ec 04             	sub    $0x4,%esp
80107f26:	6a 00                	push   $0x0
80107f28:	50                   	push   %eax
80107f29:	ff 75 08             	push   0x8(%ebp)
80107f2c:	e8 9f f9 ff ff       	call   801078d0 <walkpgdir>
80107f31:	83 c4 10             	add    $0x10,%esp
80107f34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107f37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f3b:	75 16                	jne    80107f53 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f40:	c1 e8 16             	shr    $0x16,%eax
80107f43:	83 c0 01             	add    $0x1,%eax
80107f46:	c1 e0 16             	shl    $0x16,%eax
80107f49:	2d 00 10 00 00       	sub    $0x1000,%eax
80107f4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f51:	eb 4e                	jmp    80107fa1 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f56:	8b 00                	mov    (%eax),%eax
80107f58:	83 e0 01             	and    $0x1,%eax
80107f5b:	85 c0                	test   %eax,%eax
80107f5d:	74 42                	je     80107fa1 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f62:	8b 00                	mov    (%eax),%eax
80107f64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f69:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107f6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f70:	75 0d                	jne    80107f7f <deallocuvm+0x8a>
        panic("kfree");
80107f72:	83 ec 0c             	sub    $0xc,%esp
80107f75:	68 c1 ac 10 80       	push   $0x8010acc1
80107f7a:	e8 2a 86 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107f7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f82:	05 00 00 00 80       	add    $0x80000000,%eax
80107f87:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107f8a:	83 ec 0c             	sub    $0xc,%esp
80107f8d:	ff 75 e8             	push   -0x18(%ebp)
80107f90:	e8 5b ac ff ff       	call   80102bf0 <kfree>
80107f95:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107fa1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fab:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fae:	0f 82 6c ff ff ff    	jb     80107f20 <deallocuvm+0x2b>
    }
  }
  return newsz;
80107fb4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107fb7:	c9                   	leave
80107fb8:	c3                   	ret

80107fb9 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107fb9:	55                   	push   %ebp
80107fba:	89 e5                	mov    %esp,%ebp
80107fbc:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107fbf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107fc3:	75 0d                	jne    80107fd2 <freevm+0x19>
    panic("freevm: no pgdir");
80107fc5:	83 ec 0c             	sub    $0xc,%esp
80107fc8:	68 c7 ac 10 80       	push   $0x8010acc7
80107fcd:	e8 d7 85 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107fd2:	83 ec 04             	sub    $0x4,%esp
80107fd5:	6a 00                	push   $0x0
80107fd7:	68 00 00 00 80       	push   $0x80000000
80107fdc:	ff 75 08             	push   0x8(%ebp)
80107fdf:	e8 11 ff ff ff       	call   80107ef5 <deallocuvm>
80107fe4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107fe7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fee:	eb 48                	jmp    80108038 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80107ffd:	01 d0                	add    %edx,%eax
80107fff:	8b 00                	mov    (%eax),%eax
80108001:	83 e0 01             	and    $0x1,%eax
80108004:	85 c0                	test   %eax,%eax
80108006:	74 2c                	je     80108034 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108012:	8b 45 08             	mov    0x8(%ebp),%eax
80108015:	01 d0                	add    %edx,%eax
80108017:	8b 00                	mov    (%eax),%eax
80108019:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010801e:	05 00 00 00 80       	add    $0x80000000,%eax
80108023:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108026:	83 ec 0c             	sub    $0xc,%esp
80108029:	ff 75 f0             	push   -0x10(%ebp)
8010802c:	e8 bf ab ff ff       	call   80102bf0 <kfree>
80108031:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108034:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108038:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010803f:	76 af                	jbe    80107ff0 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108041:	83 ec 0c             	sub    $0xc,%esp
80108044:	ff 75 08             	push   0x8(%ebp)
80108047:	e8 a4 ab ff ff       	call   80102bf0 <kfree>
8010804c:	83 c4 10             	add    $0x10,%esp
}
8010804f:	90                   	nop
80108050:	c9                   	leave
80108051:	c3                   	ret

80108052 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108052:	55                   	push   %ebp
80108053:	89 e5                	mov    %esp,%ebp
80108055:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108058:	83 ec 04             	sub    $0x4,%esp
8010805b:	6a 00                	push   $0x0
8010805d:	ff 75 0c             	push   0xc(%ebp)
80108060:	ff 75 08             	push   0x8(%ebp)
80108063:	e8 68 f8 ff ff       	call   801078d0 <walkpgdir>
80108068:	83 c4 10             	add    $0x10,%esp
8010806b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010806e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108072:	75 0d                	jne    80108081 <clearpteu+0x2f>
    panic("clearpteu");
80108074:	83 ec 0c             	sub    $0xc,%esp
80108077:	68 d8 ac 10 80       	push   $0x8010acd8
8010807c:	e8 28 85 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80108081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108084:	8b 00                	mov    (%eax),%eax
80108086:	83 e0 fb             	and    $0xfffffffb,%eax
80108089:	89 c2                	mov    %eax,%edx
8010808b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808e:	89 10                	mov    %edx,(%eax)
}
80108090:	90                   	nop
80108091:	c9                   	leave
80108092:	c3                   	ret

80108093 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108093:	55                   	push   %ebp
80108094:	89 e5                	mov    %esp,%ebp
80108096:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108099:	e8 58 f9 ff ff       	call   801079f6 <setupkvm>
8010809e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080a5:	75 0a                	jne    801080b1 <copyuvm+0x1e>
    return 0;
801080a7:	b8 00 00 00 00       	mov    $0x0,%eax
801080ac:	e9 eb 00 00 00       	jmp    8010819c <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801080b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080b8:	e9 b7 00 00 00       	jmp    80108174 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801080bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c0:	83 ec 04             	sub    $0x4,%esp
801080c3:	6a 00                	push   $0x0
801080c5:	50                   	push   %eax
801080c6:	ff 75 08             	push   0x8(%ebp)
801080c9:	e8 02 f8 ff ff       	call   801078d0 <walkpgdir>
801080ce:	83 c4 10             	add    $0x10,%esp
801080d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801080d4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801080d8:	75 0d                	jne    801080e7 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801080da:	83 ec 0c             	sub    $0xc,%esp
801080dd:	68 e2 ac 10 80       	push   $0x8010ace2
801080e2:	e8 c2 84 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801080e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801080ea:	8b 00                	mov    (%eax),%eax
801080ec:	83 e0 01             	and    $0x1,%eax
801080ef:	85 c0                	test   %eax,%eax
801080f1:	75 0d                	jne    80108100 <copyuvm+0x6d>
      panic("copyuvm: page not present");
801080f3:	83 ec 0c             	sub    $0xc,%esp
801080f6:	68 fc ac 10 80       	push   $0x8010acfc
801080fb:	e8 a9 84 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80108100:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108103:	8b 00                	mov    (%eax),%eax
80108105:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010810a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010810d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108110:	8b 00                	mov    (%eax),%eax
80108112:	25 ff 0f 00 00       	and    $0xfff,%eax
80108117:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010811a:	e8 6b ab ff ff       	call   80102c8a <kalloc>
8010811f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108122:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108126:	74 5d                	je     80108185 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108128:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010812b:	05 00 00 00 80       	add    $0x80000000,%eax
80108130:	83 ec 04             	sub    $0x4,%esp
80108133:	68 00 10 00 00       	push   $0x1000
80108138:	50                   	push   %eax
80108139:	ff 75 e0             	push   -0x20(%ebp)
8010813c:	e8 28 d0 ff ff       	call   80105169 <memmove>
80108141:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108144:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108147:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010814a:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108153:	83 ec 0c             	sub    $0xc,%esp
80108156:	52                   	push   %edx
80108157:	51                   	push   %ecx
80108158:	68 00 10 00 00       	push   $0x1000
8010815d:	50                   	push   %eax
8010815e:	ff 75 f0             	push   -0x10(%ebp)
80108161:	e8 00 f8 ff ff       	call   80107966 <mappages>
80108166:	83 c4 20             	add    $0x20,%esp
80108169:	85 c0                	test   %eax,%eax
8010816b:	78 1b                	js     80108188 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
8010816d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108177:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010817a:	0f 82 3d ff ff ff    	jb     801080bd <copyuvm+0x2a>
      goto bad;
  }
  return d;
80108180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108183:	eb 17                	jmp    8010819c <copyuvm+0x109>
      goto bad;
80108185:	90                   	nop
80108186:	eb 01                	jmp    80108189 <copyuvm+0xf6>
      goto bad;
80108188:	90                   	nop

bad:
  freevm(d);
80108189:	83 ec 0c             	sub    $0xc,%esp
8010818c:	ff 75 f0             	push   -0x10(%ebp)
8010818f:	e8 25 fe ff ff       	call   80107fb9 <freevm>
80108194:	83 c4 10             	add    $0x10,%esp
  return 0;
80108197:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010819c:	c9                   	leave
8010819d:	c3                   	ret

8010819e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010819e:	55                   	push   %ebp
8010819f:	89 e5                	mov    %esp,%ebp
801081a1:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801081a4:	83 ec 04             	sub    $0x4,%esp
801081a7:	6a 00                	push   $0x0
801081a9:	ff 75 0c             	push   0xc(%ebp)
801081ac:	ff 75 08             	push   0x8(%ebp)
801081af:	e8 1c f7 ff ff       	call   801078d0 <walkpgdir>
801081b4:	83 c4 10             	add    $0x10,%esp
801081b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801081ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bd:	8b 00                	mov    (%eax),%eax
801081bf:	83 e0 01             	and    $0x1,%eax
801081c2:	85 c0                	test   %eax,%eax
801081c4:	75 07                	jne    801081cd <uva2ka+0x2f>
    return 0;
801081c6:	b8 00 00 00 00       	mov    $0x0,%eax
801081cb:	eb 22                	jmp    801081ef <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
801081cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d0:	8b 00                	mov    (%eax),%eax
801081d2:	83 e0 04             	and    $0x4,%eax
801081d5:	85 c0                	test   %eax,%eax
801081d7:	75 07                	jne    801081e0 <uva2ka+0x42>
    return 0;
801081d9:	b8 00 00 00 00       	mov    $0x0,%eax
801081de:	eb 0f                	jmp    801081ef <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
801081e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e3:	8b 00                	mov    (%eax),%eax
801081e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081ea:	05 00 00 00 80       	add    $0x80000000,%eax
}
801081ef:	c9                   	leave
801081f0:	c3                   	ret

801081f1 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801081f1:	55                   	push   %ebp
801081f2:	89 e5                	mov    %esp,%ebp
801081f4:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801081f7:	8b 45 10             	mov    0x10(%ebp),%eax
801081fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801081fd:	eb 7f                	jmp    8010827e <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801081ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80108202:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108207:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010820a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010820d:	83 ec 08             	sub    $0x8,%esp
80108210:	50                   	push   %eax
80108211:	ff 75 08             	push   0x8(%ebp)
80108214:	e8 85 ff ff ff       	call   8010819e <uva2ka>
80108219:	83 c4 10             	add    $0x10,%esp
8010821c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010821f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108223:	75 07                	jne    8010822c <copyout+0x3b>
      return -1;
80108225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010822a:	eb 61                	jmp    8010828d <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010822c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010822f:	2b 45 0c             	sub    0xc(%ebp),%eax
80108232:	05 00 10 00 00       	add    $0x1000,%eax
80108237:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010823a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010823d:	39 45 14             	cmp    %eax,0x14(%ebp)
80108240:	73 06                	jae    80108248 <copyout+0x57>
      n = len;
80108242:	8b 45 14             	mov    0x14(%ebp),%eax
80108245:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108248:	8b 45 0c             	mov    0xc(%ebp),%eax
8010824b:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010824e:	89 c2                	mov    %eax,%edx
80108250:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108253:	01 d0                	add    %edx,%eax
80108255:	83 ec 04             	sub    $0x4,%esp
80108258:	ff 75 f0             	push   -0x10(%ebp)
8010825b:	ff 75 f4             	push   -0xc(%ebp)
8010825e:	50                   	push   %eax
8010825f:	e8 05 cf ff ff       	call   80105169 <memmove>
80108264:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108267:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010826a:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010826d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108270:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108273:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108276:	05 00 10 00 00       	add    $0x1000,%eax
8010827b:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010827e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108282:	0f 85 77 ff ff ff    	jne    801081ff <copyout+0xe>
  }
  return 0;
80108288:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010828d:	c9                   	leave
8010828e:	c3                   	ret

8010828f <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010828f:	55                   	push   %ebp
80108290:	89 e5                	mov    %esp,%ebp
80108292:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108295:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
8010829c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010829f:	8b 40 08             	mov    0x8(%eax),%eax
801082a2:	05 00 00 00 80       	add    $0x80000000,%eax
801082a7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801082aa:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801082b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b4:	8b 40 24             	mov    0x24(%eax),%eax
801082b7:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
801082bc:	c7 05 80 9d 11 80 00 	movl   $0x0,0x80119d80
801082c3:	00 00 00 

  while(i<madt->len){
801082c6:	e9 bd 00 00 00       	jmp    80108388 <mpinit_uefi+0xf9>
    uchar *entry_type = ((uchar *)madt)+i;
801082cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801082ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082d1:	01 d0                	add    %edx,%eax
801082d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801082d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082d9:	0f b6 00             	movzbl (%eax),%eax
801082dc:	0f b6 c0             	movzbl %al,%eax
801082df:	83 f8 05             	cmp    $0x5,%eax
801082e2:	0f 87 a0 00 00 00    	ja     80108388 <mpinit_uefi+0xf9>
801082e8:	8b 04 85 18 ad 10 80 	mov    -0x7fef52e8(,%eax,4),%eax
801082ef:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801082f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801082f7:	a1 80 9d 11 80       	mov    0x80119d80,%eax
801082fc:	83 f8 03             	cmp    $0x3,%eax
801082ff:	7f 28                	jg     80108329 <mpinit_uefi+0x9a>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108301:	8b 15 80 9d 11 80    	mov    0x80119d80,%edx
80108307:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010830a:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010830e:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80108314:	81 c2 c0 9a 11 80    	add    $0x80119ac0,%edx
8010831a:	88 02                	mov    %al,(%edx)
          ncpu++;
8010831c:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80108321:	83 c0 01             	add    $0x1,%eax
80108324:	a3 80 9d 11 80       	mov    %eax,0x80119d80
        }
        i += lapic_entry->record_len;
80108329:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010832c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108330:	0f b6 c0             	movzbl %al,%eax
80108333:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108336:	eb 50                	jmp    80108388 <mpinit_uefi+0xf9>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108338:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010833b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010833e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108341:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108345:	a2 84 9d 11 80       	mov    %al,0x80119d84
        i += ioapic->record_len;
8010834a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010834d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108351:	0f b6 c0             	movzbl %al,%eax
80108354:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108357:	eb 2f                	jmp    80108388 <mpinit_uefi+0xf9>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010835c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010835f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108362:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108366:	0f b6 c0             	movzbl %al,%eax
80108369:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010836c:	eb 1a                	jmp    80108388 <mpinit_uefi+0xf9>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010836e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108371:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108374:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108377:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010837b:	0f b6 c0             	movzbl %al,%eax
8010837e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108381:	eb 05                	jmp    80108388 <mpinit_uefi+0xf9>

      case 5:
        i = i + 0xC;
80108383:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108387:	90                   	nop
  while(i<madt->len){
80108388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838b:	8b 40 04             	mov    0x4(%eax),%eax
8010838e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108391:	0f 82 34 ff ff ff    	jb     801082cb <mpinit_uefi+0x3c>
    }
  }

}
80108397:	90                   	nop
80108398:	90                   	nop
80108399:	c9                   	leave
8010839a:	c3                   	ret

8010839b <inb>:
{
8010839b:	55                   	push   %ebp
8010839c:	89 e5                	mov    %esp,%ebp
8010839e:	83 ec 14             	sub    $0x14,%esp
801083a1:	8b 45 08             	mov    0x8(%ebp),%eax
801083a4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801083a8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801083ac:	89 c2                	mov    %eax,%edx
801083ae:	ec                   	in     (%dx),%al
801083af:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801083b2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801083b6:	c9                   	leave
801083b7:	c3                   	ret

801083b8 <outb>:
{
801083b8:	55                   	push   %ebp
801083b9:	89 e5                	mov    %esp,%ebp
801083bb:	83 ec 08             	sub    $0x8,%esp
801083be:	8b 55 08             	mov    0x8(%ebp),%edx
801083c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801083c8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801083cb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801083cf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801083d3:	ee                   	out    %al,(%dx)
}
801083d4:	90                   	nop
801083d5:	c9                   	leave
801083d6:	c3                   	ret

801083d7 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801083d7:	55                   	push   %ebp
801083d8:	89 e5                	mov    %esp,%ebp
801083da:	83 ec 28             	sub    $0x28,%esp
801083dd:	8b 45 08             	mov    0x8(%ebp),%eax
801083e0:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801083e3:	6a 00                	push   $0x0
801083e5:	68 fa 03 00 00       	push   $0x3fa
801083ea:	e8 c9 ff ff ff       	call   801083b8 <outb>
801083ef:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801083f2:	68 80 00 00 00       	push   $0x80
801083f7:	68 fb 03 00 00       	push   $0x3fb
801083fc:	e8 b7 ff ff ff       	call   801083b8 <outb>
80108401:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108404:	6a 0c                	push   $0xc
80108406:	68 f8 03 00 00       	push   $0x3f8
8010840b:	e8 a8 ff ff ff       	call   801083b8 <outb>
80108410:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108413:	6a 00                	push   $0x0
80108415:	68 f9 03 00 00       	push   $0x3f9
8010841a:	e8 99 ff ff ff       	call   801083b8 <outb>
8010841f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108422:	6a 03                	push   $0x3
80108424:	68 fb 03 00 00       	push   $0x3fb
80108429:	e8 8a ff ff ff       	call   801083b8 <outb>
8010842e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108431:	6a 00                	push   $0x0
80108433:	68 fc 03 00 00       	push   $0x3fc
80108438:	e8 7b ff ff ff       	call   801083b8 <outb>
8010843d:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108440:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108447:	eb 11                	jmp    8010845a <uart_debug+0x83>
80108449:	83 ec 0c             	sub    $0xc,%esp
8010844c:	6a 0a                	push   $0xa
8010844e:	e8 c8 ab ff ff       	call   8010301b <microdelay>
80108453:	83 c4 10             	add    $0x10,%esp
80108456:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010845a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010845e:	7f 1a                	jg     8010847a <uart_debug+0xa3>
80108460:	83 ec 0c             	sub    $0xc,%esp
80108463:	68 fd 03 00 00       	push   $0x3fd
80108468:	e8 2e ff ff ff       	call   8010839b <inb>
8010846d:	83 c4 10             	add    $0x10,%esp
80108470:	0f b6 c0             	movzbl %al,%eax
80108473:	83 e0 20             	and    $0x20,%eax
80108476:	85 c0                	test   %eax,%eax
80108478:	74 cf                	je     80108449 <uart_debug+0x72>
  outb(COM1+0, p);
8010847a:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010847e:	0f b6 c0             	movzbl %al,%eax
80108481:	83 ec 08             	sub    $0x8,%esp
80108484:	50                   	push   %eax
80108485:	68 f8 03 00 00       	push   $0x3f8
8010848a:	e8 29 ff ff ff       	call   801083b8 <outb>
8010848f:	83 c4 10             	add    $0x10,%esp
}
80108492:	90                   	nop
80108493:	c9                   	leave
80108494:	c3                   	ret

80108495 <uart_debugs>:

void uart_debugs(char *p){
80108495:	55                   	push   %ebp
80108496:	89 e5                	mov    %esp,%ebp
80108498:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010849b:	eb 1b                	jmp    801084b8 <uart_debugs+0x23>
    uart_debug(*p++);
8010849d:	8b 45 08             	mov    0x8(%ebp),%eax
801084a0:	8d 50 01             	lea    0x1(%eax),%edx
801084a3:	89 55 08             	mov    %edx,0x8(%ebp)
801084a6:	0f b6 00             	movzbl (%eax),%eax
801084a9:	0f be c0             	movsbl %al,%eax
801084ac:	83 ec 0c             	sub    $0xc,%esp
801084af:	50                   	push   %eax
801084b0:	e8 22 ff ff ff       	call   801083d7 <uart_debug>
801084b5:	83 c4 10             	add    $0x10,%esp
  while(*p){
801084b8:	8b 45 08             	mov    0x8(%ebp),%eax
801084bb:	0f b6 00             	movzbl (%eax),%eax
801084be:	84 c0                	test   %al,%al
801084c0:	75 db                	jne    8010849d <uart_debugs+0x8>
  }
}
801084c2:	90                   	nop
801084c3:	90                   	nop
801084c4:	c9                   	leave
801084c5:	c3                   	ret

801084c6 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801084c6:	55                   	push   %ebp
801084c7:	89 e5                	mov    %esp,%ebp
801084c9:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801084cc:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801084d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084d6:	8b 50 14             	mov    0x14(%eax),%edx
801084d9:	8b 40 10             	mov    0x10(%eax),%eax
801084dc:	a3 88 9d 11 80       	mov    %eax,0x80119d88
  gpu.vram_size = boot_param->graphic_config.frame_size;
801084e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084e4:	8b 50 1c             	mov    0x1c(%eax),%edx
801084e7:	8b 40 18             	mov    0x18(%eax),%eax
801084ea:	a3 90 9d 11 80       	mov    %eax,0x80119d90
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801084ef:	a1 90 9d 11 80       	mov    0x80119d90,%eax
801084f4:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801084f9:	29 c2                	sub    %eax,%edx
801084fb:	89 15 8c 9d 11 80    	mov    %edx,0x80119d8c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108501:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108504:	8b 50 24             	mov    0x24(%eax),%edx
80108507:	8b 40 20             	mov    0x20(%eax),%eax
8010850a:	a3 94 9d 11 80       	mov    %eax,0x80119d94
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010850f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108512:	8b 50 2c             	mov    0x2c(%eax),%edx
80108515:	8b 40 28             	mov    0x28(%eax),%eax
80108518:	a3 98 9d 11 80       	mov    %eax,0x80119d98
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010851d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108520:	8b 50 34             	mov    0x34(%eax),%edx
80108523:	8b 40 30             	mov    0x30(%eax),%eax
80108526:	a3 9c 9d 11 80       	mov    %eax,0x80119d9c
}
8010852b:	90                   	nop
8010852c:	c9                   	leave
8010852d:	c3                   	ret

8010852e <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010852e:	55                   	push   %ebp
8010852f:	89 e5                	mov    %esp,%ebp
80108531:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108534:	8b 15 9c 9d 11 80    	mov    0x80119d9c,%edx
8010853a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010853d:	0f af d0             	imul   %eax,%edx
80108540:	8b 45 08             	mov    0x8(%ebp),%eax
80108543:	01 d0                	add    %edx,%eax
80108545:	c1 e0 02             	shl    $0x2,%eax
80108548:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
8010854b:	8b 15 8c 9d 11 80    	mov    0x80119d8c,%edx
80108551:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108554:	01 d0                	add    %edx,%eax
80108556:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108559:	8b 45 10             	mov    0x10(%ebp),%eax
8010855c:	0f b6 10             	movzbl (%eax),%edx
8010855f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108562:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108564:	8b 45 10             	mov    0x10(%ebp),%eax
80108567:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010856b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010856e:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108571:	8b 45 10             	mov    0x10(%ebp),%eax
80108574:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108578:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010857b:	88 50 02             	mov    %dl,0x2(%eax)
}
8010857e:	90                   	nop
8010857f:	c9                   	leave
80108580:	c3                   	ret

80108581 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108581:	55                   	push   %ebp
80108582:	89 e5                	mov    %esp,%ebp
80108584:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108587:	8b 15 9c 9d 11 80    	mov    0x80119d9c,%edx
8010858d:	8b 45 08             	mov    0x8(%ebp),%eax
80108590:	0f af c2             	imul   %edx,%eax
80108593:	c1 e0 02             	shl    $0x2,%eax
80108596:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108599:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
8010859f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a2:	29 c2                	sub    %eax,%edx
801085a4:	8b 0d 8c 9d 11 80    	mov    0x80119d8c,%ecx
801085aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ad:	01 c8                	add    %ecx,%eax
801085af:	89 c1                	mov    %eax,%ecx
801085b1:	a1 8c 9d 11 80       	mov    0x80119d8c,%eax
801085b6:	83 ec 04             	sub    $0x4,%esp
801085b9:	52                   	push   %edx
801085ba:	51                   	push   %ecx
801085bb:	50                   	push   %eax
801085bc:	e8 a8 cb ff ff       	call   80105169 <memmove>
801085c1:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801085c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c7:	8b 0d 8c 9d 11 80    	mov    0x80119d8c,%ecx
801085cd:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
801085d3:	01 d1                	add    %edx,%ecx
801085d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085d8:	29 d1                	sub    %edx,%ecx
801085da:	89 ca                	mov    %ecx,%edx
801085dc:	83 ec 04             	sub    $0x4,%esp
801085df:	50                   	push   %eax
801085e0:	6a 00                	push   $0x0
801085e2:	52                   	push   %edx
801085e3:	e8 c2 ca ff ff       	call   801050aa <memset>
801085e8:	83 c4 10             	add    $0x10,%esp
}
801085eb:	90                   	nop
801085ec:	c9                   	leave
801085ed:	c3                   	ret

801085ee <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801085ee:	55                   	push   %ebp
801085ef:	89 e5                	mov    %esp,%ebp
801085f1:	53                   	push   %ebx
801085f2:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801085f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085fc:	e9 b1 00 00 00       	jmp    801086b2 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80108601:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108608:	e9 97 00 00 00       	jmp    801086a4 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
8010860d:	8b 45 10             	mov    0x10(%ebp),%eax
80108610:	83 e8 20             	sub    $0x20,%eax
80108613:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108619:	01 d0                	add    %edx,%eax
8010861b:	0f b7 84 00 40 ad 10 	movzwl -0x7fef52c0(%eax,%eax,1),%eax
80108622:	80 
80108623:	0f b7 d0             	movzwl %ax,%edx
80108626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108629:	bb 01 00 00 00       	mov    $0x1,%ebx
8010862e:	89 c1                	mov    %eax,%ecx
80108630:	d3 e3                	shl    %cl,%ebx
80108632:	89 d8                	mov    %ebx,%eax
80108634:	21 d0                	and    %edx,%eax
80108636:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010863c:	ba 01 00 00 00       	mov    $0x1,%edx
80108641:	89 c1                	mov    %eax,%ecx
80108643:	d3 e2                	shl    %cl,%edx
80108645:	89 d0                	mov    %edx,%eax
80108647:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010864a:	75 2b                	jne    80108677 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
8010864c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010864f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108652:	01 c2                	add    %eax,%edx
80108654:	b8 0e 00 00 00       	mov    $0xe,%eax
80108659:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010865c:	89 c1                	mov    %eax,%ecx
8010865e:	8b 45 08             	mov    0x8(%ebp),%eax
80108661:	01 c8                	add    %ecx,%eax
80108663:	83 ec 04             	sub    $0x4,%esp
80108666:	68 e0 f4 10 80       	push   $0x8010f4e0
8010866b:	52                   	push   %edx
8010866c:	50                   	push   %eax
8010866d:	e8 bc fe ff ff       	call   8010852e <graphic_draw_pixel>
80108672:	83 c4 10             	add    $0x10,%esp
80108675:	eb 29                	jmp    801086a0 <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108677:	8b 55 0c             	mov    0xc(%ebp),%edx
8010867a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867d:	01 c2                	add    %eax,%edx
8010867f:	b8 0e 00 00 00       	mov    $0xe,%eax
80108684:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108687:	89 c1                	mov    %eax,%ecx
80108689:	8b 45 08             	mov    0x8(%ebp),%eax
8010868c:	01 c8                	add    %ecx,%eax
8010868e:	83 ec 04             	sub    $0x4,%esp
80108691:	68 a0 9d 11 80       	push   $0x80119da0
80108696:	52                   	push   %edx
80108697:	50                   	push   %eax
80108698:	e8 91 fe ff ff       	call   8010852e <graphic_draw_pixel>
8010869d:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801086a0:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801086a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086a8:	0f 89 5f ff ff ff    	jns    8010860d <font_render+0x1f>
  for(int i=0;i<30;i++){
801086ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086b2:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801086b6:	0f 8e 45 ff ff ff    	jle    80108601 <font_render+0x13>
      }
    }
  }
}
801086bc:	90                   	nop
801086bd:	90                   	nop
801086be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086c1:	c9                   	leave
801086c2:	c3                   	ret

801086c3 <font_render_string>:

void font_render_string(char *string,int row){
801086c3:	55                   	push   %ebp
801086c4:	89 e5                	mov    %esp,%ebp
801086c6:	53                   	push   %ebx
801086c7:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801086ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801086d1:	eb 33                	jmp    80108706 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801086d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086d6:	8b 45 08             	mov    0x8(%ebp),%eax
801086d9:	01 d0                	add    %edx,%eax
801086db:	0f b6 00             	movzbl (%eax),%eax
801086de:	0f be d8             	movsbl %al,%ebx
801086e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801086e4:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801086e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086ea:	89 d0                	mov    %edx,%eax
801086ec:	c1 e0 04             	shl    $0x4,%eax
801086ef:	29 d0                	sub    %edx,%eax
801086f1:	83 c0 02             	add    $0x2,%eax
801086f4:	83 ec 04             	sub    $0x4,%esp
801086f7:	53                   	push   %ebx
801086f8:	51                   	push   %ecx
801086f9:	50                   	push   %eax
801086fa:	e8 ef fe ff ff       	call   801085ee <font_render>
801086ff:	83 c4 10             	add    $0x10,%esp
    i++;
80108702:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108706:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108709:	8b 45 08             	mov    0x8(%ebp),%eax
8010870c:	01 d0                	add    %edx,%eax
8010870e:	0f b6 00             	movzbl (%eax),%eax
80108711:	84 c0                	test   %al,%al
80108713:	74 06                	je     8010871b <font_render_string+0x58>
80108715:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108719:	7e b8                	jle    801086d3 <font_render_string+0x10>
  }
}
8010871b:	90                   	nop
8010871c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010871f:	c9                   	leave
80108720:	c3                   	ret

80108721 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108721:	55                   	push   %ebp
80108722:	89 e5                	mov    %esp,%ebp
80108724:	53                   	push   %ebx
80108725:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108728:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010872f:	eb 6b                	jmp    8010879c <pci_init+0x7b>
    for(int j=0;j<32;j++){
80108731:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108738:	eb 58                	jmp    80108792 <pci_init+0x71>
      for(int k=0;k<8;k++){
8010873a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108741:	eb 45                	jmp    80108788 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108743:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108746:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874c:	83 ec 0c             	sub    $0xc,%esp
8010874f:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108752:	53                   	push   %ebx
80108753:	6a 00                	push   $0x0
80108755:	51                   	push   %ecx
80108756:	52                   	push   %edx
80108757:	50                   	push   %eax
80108758:	e8 b0 00 00 00       	call   8010880d <pci_access_config>
8010875d:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108760:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108763:	0f b7 c0             	movzwl %ax,%eax
80108766:	3d ff ff 00 00       	cmp    $0xffff,%eax
8010876b:	74 17                	je     80108784 <pci_init+0x63>
        pci_init_device(i,j,k);
8010876d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108770:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108776:	83 ec 04             	sub    $0x4,%esp
80108779:	51                   	push   %ecx
8010877a:	52                   	push   %edx
8010877b:	50                   	push   %eax
8010877c:	e8 37 01 00 00       	call   801088b8 <pci_init_device>
80108781:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108784:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108788:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010878c:	7e b5                	jle    80108743 <pci_init+0x22>
    for(int j=0;j<32;j++){
8010878e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108792:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108796:	7e a2                	jle    8010873a <pci_init+0x19>
  for(int i=0;i<256;i++){
80108798:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010879c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801087a3:	7e 8c                	jle    80108731 <pci_init+0x10>
      }
      }
    }
  }
}
801087a5:	90                   	nop
801087a6:	90                   	nop
801087a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801087aa:	c9                   	leave
801087ab:	c3                   	ret

801087ac <pci_write_config>:

void pci_write_config(uint config){
801087ac:	55                   	push   %ebp
801087ad:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801087af:	8b 45 08             	mov    0x8(%ebp),%eax
801087b2:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801087b7:	89 c0                	mov    %eax,%eax
801087b9:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801087ba:	90                   	nop
801087bb:	5d                   	pop    %ebp
801087bc:	c3                   	ret

801087bd <pci_write_data>:

void pci_write_data(uint config){
801087bd:	55                   	push   %ebp
801087be:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801087c0:	8b 45 08             	mov    0x8(%ebp),%eax
801087c3:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801087c8:	89 c0                	mov    %eax,%eax
801087ca:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801087cb:	90                   	nop
801087cc:	5d                   	pop    %ebp
801087cd:	c3                   	ret

801087ce <pci_read_config>:
uint pci_read_config(){
801087ce:	55                   	push   %ebp
801087cf:	89 e5                	mov    %esp,%ebp
801087d1:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801087d4:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801087d9:	ed                   	in     (%dx),%eax
801087da:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801087dd:	83 ec 0c             	sub    $0xc,%esp
801087e0:	68 c8 00 00 00       	push   $0xc8
801087e5:	e8 31 a8 ff ff       	call   8010301b <microdelay>
801087ea:	83 c4 10             	add    $0x10,%esp
  return data;
801087ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801087f0:	c9                   	leave
801087f1:	c3                   	ret

801087f2 <pci_test>:


void pci_test(){
801087f2:	55                   	push   %ebp
801087f3:	89 e5                	mov    %esp,%ebp
801087f5:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801087f8:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801087ff:	ff 75 fc             	push   -0x4(%ebp)
80108802:	e8 a5 ff ff ff       	call   801087ac <pci_write_config>
80108807:	83 c4 04             	add    $0x4,%esp
}
8010880a:	90                   	nop
8010880b:	c9                   	leave
8010880c:	c3                   	ret

8010880d <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010880d:	55                   	push   %ebp
8010880e:	89 e5                	mov    %esp,%ebp
80108810:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108813:	8b 45 08             	mov    0x8(%ebp),%eax
80108816:	c1 e0 10             	shl    $0x10,%eax
80108819:	25 00 00 ff 00       	and    $0xff0000,%eax
8010881e:	89 c2                	mov    %eax,%edx
80108820:	8b 45 0c             	mov    0xc(%ebp),%eax
80108823:	c1 e0 0b             	shl    $0xb,%eax
80108826:	0f b7 c0             	movzwl %ax,%eax
80108829:	09 c2                	or     %eax,%edx
8010882b:	8b 45 10             	mov    0x10(%ebp),%eax
8010882e:	c1 e0 08             	shl    $0x8,%eax
80108831:	25 00 07 00 00       	and    $0x700,%eax
80108836:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108838:	8b 45 14             	mov    0x14(%ebp),%eax
8010883b:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108840:	09 d0                	or     %edx,%eax
80108842:	0d 00 00 00 80       	or     $0x80000000,%eax
80108847:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010884a:	ff 75 f4             	push   -0xc(%ebp)
8010884d:	e8 5a ff ff ff       	call   801087ac <pci_write_config>
80108852:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108855:	e8 74 ff ff ff       	call   801087ce <pci_read_config>
8010885a:	8b 55 18             	mov    0x18(%ebp),%edx
8010885d:	89 02                	mov    %eax,(%edx)
}
8010885f:	90                   	nop
80108860:	c9                   	leave
80108861:	c3                   	ret

80108862 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108862:	55                   	push   %ebp
80108863:	89 e5                	mov    %esp,%ebp
80108865:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108868:	8b 45 08             	mov    0x8(%ebp),%eax
8010886b:	c1 e0 10             	shl    $0x10,%eax
8010886e:	25 00 00 ff 00       	and    $0xff0000,%eax
80108873:	89 c2                	mov    %eax,%edx
80108875:	8b 45 0c             	mov    0xc(%ebp),%eax
80108878:	c1 e0 0b             	shl    $0xb,%eax
8010887b:	0f b7 c0             	movzwl %ax,%eax
8010887e:	09 c2                	or     %eax,%edx
80108880:	8b 45 10             	mov    0x10(%ebp),%eax
80108883:	c1 e0 08             	shl    $0x8,%eax
80108886:	25 00 07 00 00       	and    $0x700,%eax
8010888b:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010888d:	8b 45 14             	mov    0x14(%ebp),%eax
80108890:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108895:	09 d0                	or     %edx,%eax
80108897:	0d 00 00 00 80       	or     $0x80000000,%eax
8010889c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010889f:	ff 75 fc             	push   -0x4(%ebp)
801088a2:	e8 05 ff ff ff       	call   801087ac <pci_write_config>
801088a7:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801088aa:	ff 75 18             	push   0x18(%ebp)
801088ad:	e8 0b ff ff ff       	call   801087bd <pci_write_data>
801088b2:	83 c4 04             	add    $0x4,%esp
}
801088b5:	90                   	nop
801088b6:	c9                   	leave
801088b7:	c3                   	ret

801088b8 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801088b8:	55                   	push   %ebp
801088b9:	89 e5                	mov    %esp,%ebp
801088bb:	53                   	push   %ebx
801088bc:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801088bf:	8b 45 08             	mov    0x8(%ebp),%eax
801088c2:	a2 a4 9d 11 80       	mov    %al,0x80119da4
  dev.device_num = device_num;
801088c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801088ca:	a2 a5 9d 11 80       	mov    %al,0x80119da5
  dev.function_num = function_num;
801088cf:	8b 45 10             	mov    0x10(%ebp),%eax
801088d2:	a2 a6 9d 11 80       	mov    %al,0x80119da6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801088d7:	ff 75 10             	push   0x10(%ebp)
801088da:	ff 75 0c             	push   0xc(%ebp)
801088dd:	ff 75 08             	push   0x8(%ebp)
801088e0:	68 84 c3 10 80       	push   $0x8010c384
801088e5:	e8 0a 7b ff ff       	call   801003f4 <cprintf>
801088ea:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801088ed:	83 ec 0c             	sub    $0xc,%esp
801088f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801088f3:	50                   	push   %eax
801088f4:	6a 00                	push   $0x0
801088f6:	ff 75 10             	push   0x10(%ebp)
801088f9:	ff 75 0c             	push   0xc(%ebp)
801088fc:	ff 75 08             	push   0x8(%ebp)
801088ff:	e8 09 ff ff ff       	call   8010880d <pci_access_config>
80108904:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108907:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010890a:	c1 e8 10             	shr    $0x10,%eax
8010890d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108910:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108913:	25 ff ff 00 00       	and    $0xffff,%eax
80108918:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
8010891b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891e:	a3 a8 9d 11 80       	mov    %eax,0x80119da8
  dev.vendor_id = vendor_id;
80108923:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108926:	a3 ac 9d 11 80       	mov    %eax,0x80119dac
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
8010892b:	83 ec 04             	sub    $0x4,%esp
8010892e:	ff 75 f0             	push   -0x10(%ebp)
80108931:	ff 75 f4             	push   -0xc(%ebp)
80108934:	68 b8 c3 10 80       	push   $0x8010c3b8
80108939:	e8 b6 7a ff ff       	call   801003f4 <cprintf>
8010893e:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108941:	83 ec 0c             	sub    $0xc,%esp
80108944:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108947:	50                   	push   %eax
80108948:	6a 08                	push   $0x8
8010894a:	ff 75 10             	push   0x10(%ebp)
8010894d:	ff 75 0c             	push   0xc(%ebp)
80108950:	ff 75 08             	push   0x8(%ebp)
80108953:	e8 b5 fe ff ff       	call   8010880d <pci_access_config>
80108958:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010895b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010895e:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108961:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108964:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108967:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010896a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010896d:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108970:	0f b6 c0             	movzbl %al,%eax
80108973:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108976:	c1 eb 18             	shr    $0x18,%ebx
80108979:	83 ec 0c             	sub    $0xc,%esp
8010897c:	51                   	push   %ecx
8010897d:	52                   	push   %edx
8010897e:	50                   	push   %eax
8010897f:	53                   	push   %ebx
80108980:	68 dc c3 10 80       	push   $0x8010c3dc
80108985:	e8 6a 7a ff ff       	call   801003f4 <cprintf>
8010898a:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010898d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108990:	c1 e8 18             	shr    $0x18,%eax
80108993:	a2 b0 9d 11 80       	mov    %al,0x80119db0
  dev.sub_class = (data>>16)&0xFF;
80108998:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010899b:	c1 e8 10             	shr    $0x10,%eax
8010899e:	a2 b1 9d 11 80       	mov    %al,0x80119db1
  dev.interface = (data>>8)&0xFF;
801089a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089a6:	c1 e8 08             	shr    $0x8,%eax
801089a9:	a2 b2 9d 11 80       	mov    %al,0x80119db2
  dev.revision_id = data&0xFF;
801089ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089b1:	a2 b3 9d 11 80       	mov    %al,0x80119db3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801089b6:	83 ec 0c             	sub    $0xc,%esp
801089b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089bc:	50                   	push   %eax
801089bd:	6a 10                	push   $0x10
801089bf:	ff 75 10             	push   0x10(%ebp)
801089c2:	ff 75 0c             	push   0xc(%ebp)
801089c5:	ff 75 08             	push   0x8(%ebp)
801089c8:	e8 40 fe ff ff       	call   8010880d <pci_access_config>
801089cd:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801089d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089d3:	a3 b4 9d 11 80       	mov    %eax,0x80119db4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801089d8:	83 ec 0c             	sub    $0xc,%esp
801089db:	8d 45 ec             	lea    -0x14(%ebp),%eax
801089de:	50                   	push   %eax
801089df:	6a 14                	push   $0x14
801089e1:	ff 75 10             	push   0x10(%ebp)
801089e4:	ff 75 0c             	push   0xc(%ebp)
801089e7:	ff 75 08             	push   0x8(%ebp)
801089ea:	e8 1e fe ff ff       	call   8010880d <pci_access_config>
801089ef:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801089f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089f5:	a3 b8 9d 11 80       	mov    %eax,0x80119db8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801089fa:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108a01:	75 5a                	jne    80108a5d <pci_init_device+0x1a5>
80108a03:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108a0a:	75 51                	jne    80108a5d <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108a0c:	83 ec 0c             	sub    $0xc,%esp
80108a0f:	68 21 c4 10 80       	push   $0x8010c421
80108a14:	e8 db 79 ff ff       	call   801003f4 <cprintf>
80108a19:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108a1c:	83 ec 0c             	sub    $0xc,%esp
80108a1f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a22:	50                   	push   %eax
80108a23:	68 f0 00 00 00       	push   $0xf0
80108a28:	ff 75 10             	push   0x10(%ebp)
80108a2b:	ff 75 0c             	push   0xc(%ebp)
80108a2e:	ff 75 08             	push   0x8(%ebp)
80108a31:	e8 d7 fd ff ff       	call   8010880d <pci_access_config>
80108a36:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108a39:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a3c:	83 ec 08             	sub    $0x8,%esp
80108a3f:	50                   	push   %eax
80108a40:	68 3b c4 10 80       	push   $0x8010c43b
80108a45:	e8 aa 79 ff ff       	call   801003f4 <cprintf>
80108a4a:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108a4d:	83 ec 0c             	sub    $0xc,%esp
80108a50:	68 a4 9d 11 80       	push   $0x80119da4
80108a55:	e8 09 00 00 00       	call   80108a63 <i8254_init>
80108a5a:	83 c4 10             	add    $0x10,%esp
  }
}
80108a5d:	90                   	nop
80108a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108a61:	c9                   	leave
80108a62:	c3                   	ret

80108a63 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108a63:	55                   	push   %ebp
80108a64:	89 e5                	mov    %esp,%ebp
80108a66:	53                   	push   %ebx
80108a67:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a6d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108a71:	0f b6 c8             	movzbl %al,%ecx
80108a74:	8b 45 08             	mov    0x8(%ebp),%eax
80108a77:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a7b:	0f b6 d0             	movzbl %al,%edx
80108a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a81:	0f b6 00             	movzbl (%eax),%eax
80108a84:	0f b6 c0             	movzbl %al,%eax
80108a87:	83 ec 0c             	sub    $0xc,%esp
80108a8a:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108a8d:	53                   	push   %ebx
80108a8e:	6a 04                	push   $0x4
80108a90:	51                   	push   %ecx
80108a91:	52                   	push   %edx
80108a92:	50                   	push   %eax
80108a93:	e8 75 fd ff ff       	call   8010880d <pci_access_config>
80108a98:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108a9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a9e:	83 c8 04             	or     $0x4,%eax
80108aa1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108aa4:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80108aaa:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108aae:	0f b6 c8             	movzbl %al,%ecx
80108ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ab4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108ab8:	0f b6 d0             	movzbl %al,%edx
80108abb:	8b 45 08             	mov    0x8(%ebp),%eax
80108abe:	0f b6 00             	movzbl (%eax),%eax
80108ac1:	0f b6 c0             	movzbl %al,%eax
80108ac4:	83 ec 0c             	sub    $0xc,%esp
80108ac7:	53                   	push   %ebx
80108ac8:	6a 04                	push   $0x4
80108aca:	51                   	push   %ecx
80108acb:	52                   	push   %edx
80108acc:	50                   	push   %eax
80108acd:	e8 90 fd ff ff       	call   80108862 <pci_write_config_register>
80108ad2:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80108ad8:	8b 40 10             	mov    0x10(%eax),%eax
80108adb:	05 00 00 00 40       	add    $0x40000000,%eax
80108ae0:	a3 bc 9d 11 80       	mov    %eax,0x80119dbc
  uint *ctrl = (uint *)base_addr;
80108ae5:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108aed:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108af2:	05 d8 00 00 00       	add    $0xd8,%eax
80108af7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108afd:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b06:	8b 00                	mov    (%eax),%eax
80108b08:	0d 00 00 00 04       	or     $0x4000000,%eax
80108b0d:	89 c2                	mov    %eax,%edx
80108b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b12:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b17:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b20:	8b 00                	mov    (%eax),%eax
80108b22:	83 c8 40             	or     $0x40,%eax
80108b25:	89 c2                	mov    %eax,%edx
80108b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b2a:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b2f:	8b 10                	mov    (%eax),%edx
80108b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b34:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108b36:	83 ec 0c             	sub    $0xc,%esp
80108b39:	68 50 c4 10 80       	push   $0x8010c450
80108b3e:	e8 b1 78 ff ff       	call   801003f4 <cprintf>
80108b43:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108b46:	e8 3f a1 ff ff       	call   80102c8a <kalloc>
80108b4b:	a3 c8 9d 11 80       	mov    %eax,0x80119dc8
  *intr_addr = 0;
80108b50:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
80108b55:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108b5b:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
80108b60:	83 ec 08             	sub    $0x8,%esp
80108b63:	50                   	push   %eax
80108b64:	68 72 c4 10 80       	push   $0x8010c472
80108b69:	e8 86 78 ff ff       	call   801003f4 <cprintf>
80108b6e:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108b71:	e8 50 00 00 00       	call   80108bc6 <i8254_init_recv>
  i8254_init_send();
80108b76:	e8 69 03 00 00       	call   80108ee4 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108b7b:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b82:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108b85:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b8c:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108b8f:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108b96:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108b99:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ba0:	0f b6 c0             	movzbl %al,%eax
80108ba3:	83 ec 0c             	sub    $0xc,%esp
80108ba6:	53                   	push   %ebx
80108ba7:	51                   	push   %ecx
80108ba8:	52                   	push   %edx
80108ba9:	50                   	push   %eax
80108baa:	68 80 c4 10 80       	push   $0x8010c480
80108baf:	e8 40 78 ff ff       	call   801003f4 <cprintf>
80108bb4:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108bc0:	90                   	nop
80108bc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108bc4:	c9                   	leave
80108bc5:	c3                   	ret

80108bc6 <i8254_init_recv>:

void i8254_init_recv(){
80108bc6:	55                   	push   %ebp
80108bc7:	89 e5                	mov    %esp,%ebp
80108bc9:	57                   	push   %edi
80108bca:	56                   	push   %esi
80108bcb:	53                   	push   %ebx
80108bcc:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108bcf:	83 ec 0c             	sub    $0xc,%esp
80108bd2:	6a 00                	push   $0x0
80108bd4:	e8 e8 04 00 00       	call   801090c1 <i8254_read_eeprom>
80108bd9:	83 c4 10             	add    $0x10,%esp
80108bdc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108bdf:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108be2:	a2 c0 9d 11 80       	mov    %al,0x80119dc0
  mac_addr[1] = data_l>>8;
80108be7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108bea:	c1 e8 08             	shr    $0x8,%eax
80108bed:	a2 c1 9d 11 80       	mov    %al,0x80119dc1
  uint data_m = i8254_read_eeprom(0x1);
80108bf2:	83 ec 0c             	sub    $0xc,%esp
80108bf5:	6a 01                	push   $0x1
80108bf7:	e8 c5 04 00 00       	call   801090c1 <i8254_read_eeprom>
80108bfc:	83 c4 10             	add    $0x10,%esp
80108bff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108c02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c05:	a2 c2 9d 11 80       	mov    %al,0x80119dc2
  mac_addr[3] = data_m>>8;
80108c0a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108c0d:	c1 e8 08             	shr    $0x8,%eax
80108c10:	a2 c3 9d 11 80       	mov    %al,0x80119dc3
  uint data_h = i8254_read_eeprom(0x2);
80108c15:	83 ec 0c             	sub    $0xc,%esp
80108c18:	6a 02                	push   $0x2
80108c1a:	e8 a2 04 00 00       	call   801090c1 <i8254_read_eeprom>
80108c1f:	83 c4 10             	add    $0x10,%esp
80108c22:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108c25:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c28:	a2 c4 9d 11 80       	mov    %al,0x80119dc4
  mac_addr[5] = data_h>>8;
80108c2d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c30:	c1 e8 08             	shr    $0x8,%eax
80108c33:	a2 c5 9d 11 80       	mov    %al,0x80119dc5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108c38:	0f b6 05 c5 9d 11 80 	movzbl 0x80119dc5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c3f:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108c42:	0f b6 05 c4 9d 11 80 	movzbl 0x80119dc4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c49:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108c4c:	0f b6 05 c3 9d 11 80 	movzbl 0x80119dc3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c53:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108c56:	0f b6 05 c2 9d 11 80 	movzbl 0x80119dc2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c5d:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108c60:	0f b6 05 c1 9d 11 80 	movzbl 0x80119dc1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c67:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108c6a:	0f b6 05 c0 9d 11 80 	movzbl 0x80119dc0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108c71:	0f b6 c0             	movzbl %al,%eax
80108c74:	83 ec 04             	sub    $0x4,%esp
80108c77:	57                   	push   %edi
80108c78:	56                   	push   %esi
80108c79:	53                   	push   %ebx
80108c7a:	51                   	push   %ecx
80108c7b:	52                   	push   %edx
80108c7c:	50                   	push   %eax
80108c7d:	68 98 c4 10 80       	push   $0x8010c498
80108c82:	e8 6d 77 ff ff       	call   801003f4 <cprintf>
80108c87:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108c8a:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108c8f:	05 00 54 00 00       	add    $0x5400,%eax
80108c94:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108c97:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108c9c:	05 04 54 00 00       	add    $0x5404,%eax
80108ca1:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108ca4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ca7:	c1 e0 10             	shl    $0x10,%eax
80108caa:	0b 45 d8             	or     -0x28(%ebp),%eax
80108cad:	89 c2                	mov    %eax,%edx
80108caf:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108cb2:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108cb4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108cb7:	0d 00 00 00 80       	or     $0x80000000,%eax
80108cbc:	89 c2                	mov    %eax,%edx
80108cbe:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108cc1:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108cc3:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108cc8:	05 00 52 00 00       	add    $0x5200,%eax
80108ccd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108cd0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108cd7:	eb 19                	jmp    80108cf2 <i8254_init_recv+0x12c>
    mta[i] = 0;
80108cd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108cdc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ce3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ce6:	01 d0                	add    %edx,%eax
80108ce8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108cee:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108cf2:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108cf6:	7e e1                	jle    80108cd9 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108cf8:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108cfd:	05 d0 00 00 00       	add    $0xd0,%eax
80108d02:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d05:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108d08:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108d0e:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d13:	05 c8 00 00 00       	add    $0xc8,%eax
80108d18:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108d1b:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108d1e:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108d24:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d29:	05 28 28 00 00       	add    $0x2828,%eax
80108d2e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108d31:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108d34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108d3a:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d3f:	05 00 01 00 00       	add    $0x100,%eax
80108d44:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108d47:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108d4a:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108d50:	e8 35 9f ff ff       	call   80102c8a <kalloc>
80108d55:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108d58:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d5d:	05 00 28 00 00       	add    $0x2800,%eax
80108d62:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108d65:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d6a:	05 04 28 00 00       	add    $0x2804,%eax
80108d6f:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108d72:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d77:	05 08 28 00 00       	add    $0x2808,%eax
80108d7c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108d7f:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d84:	05 10 28 00 00       	add    $0x2810,%eax
80108d89:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108d8c:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d91:	05 18 28 00 00       	add    $0x2818,%eax
80108d96:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108d99:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d9c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108da2:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108da5:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108da7:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108daa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108db0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108db3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108db9:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108dbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108dc2:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108dc5:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108dcb:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108dce:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108dd1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108dd8:	eb 73                	jmp    80108e4d <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108dda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ddd:	c1 e0 04             	shl    $0x4,%eax
80108de0:	89 c2                	mov    %eax,%edx
80108de2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108de5:	01 d0                	add    %edx,%eax
80108de7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108dee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108df1:	c1 e0 04             	shl    $0x4,%eax
80108df4:	89 c2                	mov    %eax,%edx
80108df6:	8b 45 98             	mov    -0x68(%ebp),%eax
80108df9:	01 d0                	add    %edx,%eax
80108dfb:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108e01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e04:	c1 e0 04             	shl    $0x4,%eax
80108e07:	89 c2                	mov    %eax,%edx
80108e09:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e0c:	01 d0                	add    %edx,%eax
80108e0e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e17:	c1 e0 04             	shl    $0x4,%eax
80108e1a:	89 c2                	mov    %eax,%edx
80108e1c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e1f:	01 d0                	add    %edx,%eax
80108e21:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108e25:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e28:	c1 e0 04             	shl    $0x4,%eax
80108e2b:	89 c2                	mov    %eax,%edx
80108e2d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e30:	01 d0                	add    %edx,%eax
80108e32:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108e36:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e39:	c1 e0 04             	shl    $0x4,%eax
80108e3c:	89 c2                	mov    %eax,%edx
80108e3e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e41:	01 d0                	add    %edx,%eax
80108e43:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108e49:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108e4d:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108e54:	7e 84                	jle    80108dda <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e56:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108e5d:	eb 57                	jmp    80108eb6 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108e5f:	e8 26 9e ff ff       	call   80102c8a <kalloc>
80108e64:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108e67:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108e6b:	75 12                	jne    80108e7f <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108e6d:	83 ec 0c             	sub    $0xc,%esp
80108e70:	68 b8 c4 10 80       	push   $0x8010c4b8
80108e75:	e8 7a 75 ff ff       	call   801003f4 <cprintf>
80108e7a:	83 c4 10             	add    $0x10,%esp
      break;
80108e7d:	eb 3d                	jmp    80108ebc <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108e7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e82:	c1 e0 04             	shl    $0x4,%eax
80108e85:	89 c2                	mov    %eax,%edx
80108e87:	8b 45 98             	mov    -0x68(%ebp),%eax
80108e8a:	01 d0                	add    %edx,%eax
80108e8c:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108e8f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e95:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e97:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e9a:	83 c0 01             	add    $0x1,%eax
80108e9d:	c1 e0 04             	shl    $0x4,%eax
80108ea0:	89 c2                	mov    %eax,%edx
80108ea2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ea5:	01 d0                	add    %edx,%eax
80108ea7:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108eaa:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108eb0:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108eb2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108eb6:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108eba:	7e a3                	jle    80108e5f <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108ebc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ebf:	8b 00                	mov    (%eax),%eax
80108ec1:	83 c8 02             	or     $0x2,%eax
80108ec4:	89 c2                	mov    %eax,%edx
80108ec6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ec9:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108ecb:	83 ec 0c             	sub    $0xc,%esp
80108ece:	68 d8 c4 10 80       	push   $0x8010c4d8
80108ed3:	e8 1c 75 ff ff       	call   801003f4 <cprintf>
80108ed8:	83 c4 10             	add    $0x10,%esp
}
80108edb:	90                   	nop
80108edc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108edf:	5b                   	pop    %ebx
80108ee0:	5e                   	pop    %esi
80108ee1:	5f                   	pop    %edi
80108ee2:	5d                   	pop    %ebp
80108ee3:	c3                   	ret

80108ee4 <i8254_init_send>:

void i8254_init_send(){
80108ee4:	55                   	push   %ebp
80108ee5:	89 e5                	mov    %esp,%ebp
80108ee7:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108eea:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108eef:	05 28 38 00 00       	add    $0x3828,%eax
80108ef4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108ef7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108efa:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108f00:	e8 85 9d ff ff       	call   80102c8a <kalloc>
80108f05:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108f08:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f0d:	05 00 38 00 00       	add    $0x3800,%eax
80108f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108f15:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f1a:	05 04 38 00 00       	add    $0x3804,%eax
80108f1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108f22:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f27:	05 08 38 00 00       	add    $0x3808,%eax
80108f2c:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108f2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f32:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f3b:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108f46:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108f49:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108f4f:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f54:	05 10 38 00 00       	add    $0x3810,%eax
80108f59:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108f5c:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f61:	05 18 38 00 00       	add    $0x3818,%eax
80108f66:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108f69:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108f6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108f72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108f75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108f7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f7e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108f81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f88:	e9 82 00 00 00       	jmp    8010900f <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f90:	c1 e0 04             	shl    $0x4,%eax
80108f93:	89 c2                	mov    %eax,%edx
80108f95:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f98:	01 d0                	add    %edx,%eax
80108f9a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fa4:	c1 e0 04             	shl    $0x4,%eax
80108fa7:	89 c2                	mov    %eax,%edx
80108fa9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fac:	01 d0                	add    %edx,%eax
80108fae:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb7:	c1 e0 04             	shl    $0x4,%eax
80108fba:	89 c2                	mov    %eax,%edx
80108fbc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fbf:	01 d0                	add    %edx,%eax
80108fc1:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc8:	c1 e0 04             	shl    $0x4,%eax
80108fcb:	89 c2                	mov    %eax,%edx
80108fcd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fd0:	01 d0                	add    %edx,%eax
80108fd2:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fd9:	c1 e0 04             	shl    $0x4,%eax
80108fdc:	89 c2                	mov    %eax,%edx
80108fde:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fe1:	01 d0                	add    %edx,%eax
80108fe3:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fea:	c1 e0 04             	shl    $0x4,%eax
80108fed:	89 c2                	mov    %eax,%edx
80108fef:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ff2:	01 d0                	add    %edx,%eax
80108ff4:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ffb:	c1 e0 04             	shl    $0x4,%eax
80108ffe:	89 c2                	mov    %eax,%edx
80109000:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109003:	01 d0                	add    %edx,%eax
80109005:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010900b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010900f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109016:	0f 8e 71 ff ff ff    	jle    80108f8d <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010901c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109023:	eb 57                	jmp    8010907c <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80109025:	e8 60 9c ff ff       	call   80102c8a <kalloc>
8010902a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
8010902d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109031:	75 12                	jne    80109045 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80109033:	83 ec 0c             	sub    $0xc,%esp
80109036:	68 b8 c4 10 80       	push   $0x8010c4b8
8010903b:	e8 b4 73 ff ff       	call   801003f4 <cprintf>
80109040:	83 c4 10             	add    $0x10,%esp
      break;
80109043:	eb 3d                	jmp    80109082 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109045:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109048:	c1 e0 04             	shl    $0x4,%eax
8010904b:	89 c2                	mov    %eax,%edx
8010904d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109050:	01 d0                	add    %edx,%eax
80109052:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109055:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010905b:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010905d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109060:	83 c0 01             	add    $0x1,%eax
80109063:	c1 e0 04             	shl    $0x4,%eax
80109066:	89 c2                	mov    %eax,%edx
80109068:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010906b:	01 d0                	add    %edx,%eax
8010906d:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109070:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109076:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109078:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010907c:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109080:	7e a3                	jle    80109025 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109082:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80109087:	05 00 04 00 00       	add    $0x400,%eax
8010908c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010908f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109092:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109098:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
8010909d:	05 10 04 00 00       	add    $0x410,%eax
801090a2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801090a5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801090a8:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801090ae:	83 ec 0c             	sub    $0xc,%esp
801090b1:	68 f8 c4 10 80       	push   $0x8010c4f8
801090b6:	e8 39 73 ff ff       	call   801003f4 <cprintf>
801090bb:	83 c4 10             	add    $0x10,%esp

}
801090be:	90                   	nop
801090bf:	c9                   	leave
801090c0:	c3                   	ret

801090c1 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801090c1:	55                   	push   %ebp
801090c2:	89 e5                	mov    %esp,%ebp
801090c4:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801090c7:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
801090cc:	83 c0 14             	add    $0x14,%eax
801090cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801090d2:	8b 45 08             	mov    0x8(%ebp),%eax
801090d5:	c1 e0 08             	shl    $0x8,%eax
801090d8:	0f b7 c0             	movzwl %ax,%eax
801090db:	83 c8 01             	or     $0x1,%eax
801090de:	89 c2                	mov    %eax,%edx
801090e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090e3:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801090e5:	83 ec 0c             	sub    $0xc,%esp
801090e8:	68 18 c5 10 80       	push   $0x8010c518
801090ed:	e8 02 73 ff ff       	call   801003f4 <cprintf>
801090f2:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801090f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f8:	8b 00                	mov    (%eax),%eax
801090fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801090fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109100:	83 e0 10             	and    $0x10,%eax
80109103:	85 c0                	test   %eax,%eax
80109105:	75 02                	jne    80109109 <i8254_read_eeprom+0x48>
  while(1){
80109107:	eb dc                	jmp    801090e5 <i8254_read_eeprom+0x24>
      break;
80109109:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
8010910a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010910d:	8b 00                	mov    (%eax),%eax
8010910f:	c1 e8 10             	shr    $0x10,%eax
}
80109112:	c9                   	leave
80109113:	c3                   	ret

80109114 <i8254_recv>:
void i8254_recv(){
80109114:	55                   	push   %ebp
80109115:	89 e5                	mov    %esp,%ebp
80109117:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
8010911a:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
8010911f:	05 10 28 00 00       	add    $0x2810,%eax
80109124:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109127:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
8010912c:	05 18 28 00 00       	add    $0x2818,%eax
80109131:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109134:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80109139:	05 00 28 00 00       	add    $0x2800,%eax
8010913e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109141:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109144:	8b 00                	mov    (%eax),%eax
80109146:	05 00 00 00 80       	add    $0x80000000,%eax
8010914b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010914e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109151:	8b 10                	mov    (%eax),%edx
80109153:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109156:	8b 00                	mov    (%eax),%eax
80109158:	29 c2                	sub    %eax,%edx
8010915a:	89 d0                	mov    %edx,%eax
8010915c:	25 ff 00 00 00       	and    $0xff,%eax
80109161:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109164:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109168:	7e 37                	jle    801091a1 <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010916a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010916d:	8b 00                	mov    (%eax),%eax
8010916f:	c1 e0 04             	shl    $0x4,%eax
80109172:	89 c2                	mov    %eax,%edx
80109174:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109177:	01 d0                	add    %edx,%eax
80109179:	8b 00                	mov    (%eax),%eax
8010917b:	05 00 00 00 80       	add    $0x80000000,%eax
80109180:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109183:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109186:	8b 00                	mov    (%eax),%eax
80109188:	83 c0 01             	add    $0x1,%eax
8010918b:	0f b6 d0             	movzbl %al,%edx
8010918e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109191:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109193:	83 ec 0c             	sub    $0xc,%esp
80109196:	ff 75 e0             	push   -0x20(%ebp)
80109199:	e8 13 09 00 00       	call   80109ab1 <eth_proc>
8010919e:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801091a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a4:	8b 10                	mov    (%eax),%edx
801091a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a9:	8b 00                	mov    (%eax),%eax
801091ab:	39 c2                	cmp    %eax,%edx
801091ad:	75 9f                	jne    8010914e <i8254_recv+0x3a>
      (*rdt)--;
801091af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091b2:	8b 00                	mov    (%eax),%eax
801091b4:	8d 50 ff             	lea    -0x1(%eax),%edx
801091b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ba:	89 10                	mov    %edx,(%eax)
  while(1){
801091bc:	eb 90                	jmp    8010914e <i8254_recv+0x3a>

801091be <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801091be:	55                   	push   %ebp
801091bf:	89 e5                	mov    %esp,%ebp
801091c1:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801091c4:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
801091c9:	05 10 38 00 00       	add    $0x3810,%eax
801091ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801091d1:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
801091d6:	05 18 38 00 00       	add    $0x3818,%eax
801091db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801091de:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
801091e3:	05 00 38 00 00       	add    $0x3800,%eax
801091e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801091eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091ee:	8b 00                	mov    (%eax),%eax
801091f0:	05 00 00 00 80       	add    $0x80000000,%eax
801091f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801091f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091fb:	8b 10                	mov    (%eax),%edx
801091fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109200:	8b 00                	mov    (%eax),%eax
80109202:	29 c2                	sub    %eax,%edx
80109204:	0f b6 c2             	movzbl %dl,%eax
80109207:	ba 00 01 00 00       	mov    $0x100,%edx
8010920c:	29 c2                	sub    %eax,%edx
8010920e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109211:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109214:	8b 00                	mov    (%eax),%eax
80109216:	25 ff 00 00 00       	and    $0xff,%eax
8010921b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010921e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109222:	0f 8e a8 00 00 00    	jle    801092d0 <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109228:	8b 45 08             	mov    0x8(%ebp),%eax
8010922b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010922e:	89 d1                	mov    %edx,%ecx
80109230:	c1 e1 04             	shl    $0x4,%ecx
80109233:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109236:	01 ca                	add    %ecx,%edx
80109238:	8b 12                	mov    (%edx),%edx
8010923a:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109240:	83 ec 04             	sub    $0x4,%esp
80109243:	ff 75 0c             	push   0xc(%ebp)
80109246:	50                   	push   %eax
80109247:	52                   	push   %edx
80109248:	e8 1c bf ff ff       	call   80105169 <memmove>
8010924d:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109250:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109253:	c1 e0 04             	shl    $0x4,%eax
80109256:	89 c2                	mov    %eax,%edx
80109258:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010925b:	01 d0                	add    %edx,%eax
8010925d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109260:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109264:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109267:	c1 e0 04             	shl    $0x4,%eax
8010926a:	89 c2                	mov    %eax,%edx
8010926c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010926f:	01 d0                	add    %edx,%eax
80109271:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109275:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109278:	c1 e0 04             	shl    $0x4,%eax
8010927b:	89 c2                	mov    %eax,%edx
8010927d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109280:	01 d0                	add    %edx,%eax
80109282:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109286:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109289:	c1 e0 04             	shl    $0x4,%eax
8010928c:	89 c2                	mov    %eax,%edx
8010928e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109291:	01 d0                	add    %edx,%eax
80109293:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109297:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010929a:	c1 e0 04             	shl    $0x4,%eax
8010929d:	89 c2                	mov    %eax,%edx
8010929f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092a2:	01 d0                	add    %edx,%eax
801092a4:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801092aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801092ad:	c1 e0 04             	shl    $0x4,%eax
801092b0:	89 c2                	mov    %eax,%edx
801092b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092b5:	01 d0                	add    %edx,%eax
801092b7:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801092bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092be:	8b 00                	mov    (%eax),%eax
801092c0:	83 c0 01             	add    $0x1,%eax
801092c3:	0f b6 d0             	movzbl %al,%edx
801092c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092c9:	89 10                	mov    %edx,(%eax)
    return len;
801092cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801092ce:	eb 05                	jmp    801092d5 <i8254_send+0x117>
  }else{
    return -1;
801092d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801092d5:	c9                   	leave
801092d6:	c3                   	ret

801092d7 <i8254_intr>:

void i8254_intr(){
801092d7:	55                   	push   %ebp
801092d8:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801092da:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
801092df:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801092e5:	90                   	nop
801092e6:	5d                   	pop    %ebp
801092e7:	c3                   	ret

801092e8 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801092e8:	55                   	push   %ebp
801092e9:	89 e5                	mov    %esp,%ebp
801092eb:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801092ee:	8b 45 08             	mov    0x8(%ebp),%eax
801092f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801092f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f7:	0f b7 00             	movzwl (%eax),%eax
801092fa:	66 3d 00 01          	cmp    $0x100,%ax
801092fe:	74 0a                	je     8010930a <arp_proc+0x22>
80109300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109305:	e9 4f 01 00 00       	jmp    80109459 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
8010930a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930d:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109311:	66 83 f8 08          	cmp    $0x8,%ax
80109315:	74 0a                	je     80109321 <arp_proc+0x39>
80109317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010931c:	e9 38 01 00 00       	jmp    80109459 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80109321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109324:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109328:	3c 06                	cmp    $0x6,%al
8010932a:	74 0a                	je     80109336 <arp_proc+0x4e>
8010932c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109331:	e9 23 01 00 00       	jmp    80109459 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109339:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010933d:	3c 04                	cmp    $0x4,%al
8010933f:	74 0a                	je     8010934b <arp_proc+0x63>
80109341:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109346:	e9 0e 01 00 00       	jmp    80109459 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010934b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010934e:	83 c0 18             	add    $0x18,%eax
80109351:	83 ec 04             	sub    $0x4,%esp
80109354:	6a 04                	push   $0x4
80109356:	50                   	push   %eax
80109357:	68 e4 f4 10 80       	push   $0x8010f4e4
8010935c:	e8 b0 bd ff ff       	call   80105111 <memcmp>
80109361:	83 c4 10             	add    $0x10,%esp
80109364:	85 c0                	test   %eax,%eax
80109366:	74 27                	je     8010938f <arp_proc+0xa7>
80109368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010936b:	83 c0 0e             	add    $0xe,%eax
8010936e:	83 ec 04             	sub    $0x4,%esp
80109371:	6a 04                	push   $0x4
80109373:	50                   	push   %eax
80109374:	68 e4 f4 10 80       	push   $0x8010f4e4
80109379:	e8 93 bd ff ff       	call   80105111 <memcmp>
8010937e:	83 c4 10             	add    $0x10,%esp
80109381:	85 c0                	test   %eax,%eax
80109383:	74 0a                	je     8010938f <arp_proc+0xa7>
80109385:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010938a:	e9 ca 00 00 00       	jmp    80109459 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010938f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109392:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109396:	66 3d 00 01          	cmp    $0x100,%ax
8010939a:	75 69                	jne    80109405 <arp_proc+0x11d>
8010939c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010939f:	83 c0 18             	add    $0x18,%eax
801093a2:	83 ec 04             	sub    $0x4,%esp
801093a5:	6a 04                	push   $0x4
801093a7:	50                   	push   %eax
801093a8:	68 e4 f4 10 80       	push   $0x8010f4e4
801093ad:	e8 5f bd ff ff       	call   80105111 <memcmp>
801093b2:	83 c4 10             	add    $0x10,%esp
801093b5:	85 c0                	test   %eax,%eax
801093b7:	75 4c                	jne    80109405 <arp_proc+0x11d>
    uint send = (uint)kalloc();
801093b9:	e8 cc 98 ff ff       	call   80102c8a <kalloc>
801093be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801093c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801093c8:	83 ec 04             	sub    $0x4,%esp
801093cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801093ce:	50                   	push   %eax
801093cf:	ff 75 f0             	push   -0x10(%ebp)
801093d2:	ff 75 f4             	push   -0xc(%ebp)
801093d5:	e8 1f 04 00 00       	call   801097f9 <arp_reply_pkt_create>
801093da:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801093dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093e0:	83 ec 08             	sub    $0x8,%esp
801093e3:	50                   	push   %eax
801093e4:	ff 75 f0             	push   -0x10(%ebp)
801093e7:	e8 d2 fd ff ff       	call   801091be <i8254_send>
801093ec:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801093ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093f2:	83 ec 0c             	sub    $0xc,%esp
801093f5:	50                   	push   %eax
801093f6:	e8 f5 97 ff ff       	call   80102bf0 <kfree>
801093fb:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801093fe:	b8 02 00 00 00       	mov    $0x2,%eax
80109403:	eb 54                	jmp    80109459 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109408:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010940c:	66 3d 00 02          	cmp    $0x200,%ax
80109410:	75 42                	jne    80109454 <arp_proc+0x16c>
80109412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109415:	83 c0 18             	add    $0x18,%eax
80109418:	83 ec 04             	sub    $0x4,%esp
8010941b:	6a 04                	push   $0x4
8010941d:	50                   	push   %eax
8010941e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109423:	e8 e9 bc ff ff       	call   80105111 <memcmp>
80109428:	83 c4 10             	add    $0x10,%esp
8010942b:	85 c0                	test   %eax,%eax
8010942d:	75 25                	jne    80109454 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010942f:	83 ec 0c             	sub    $0xc,%esp
80109432:	68 1c c5 10 80       	push   $0x8010c51c
80109437:	e8 b8 6f ff ff       	call   801003f4 <cprintf>
8010943c:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010943f:	83 ec 0c             	sub    $0xc,%esp
80109442:	ff 75 f4             	push   -0xc(%ebp)
80109445:	e8 af 01 00 00       	call   801095f9 <arp_table_update>
8010944a:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010944d:	b8 01 00 00 00       	mov    $0x1,%eax
80109452:	eb 05                	jmp    80109459 <arp_proc+0x171>
  }else{
    return -1;
80109454:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109459:	c9                   	leave
8010945a:	c3                   	ret

8010945b <arp_scan>:

void arp_scan(){
8010945b:	55                   	push   %ebp
8010945c:	89 e5                	mov    %esp,%ebp
8010945e:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109461:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109468:	eb 6f                	jmp    801094d9 <arp_scan+0x7e>
    uint send = (uint)kalloc();
8010946a:	e8 1b 98 ff ff       	call   80102c8a <kalloc>
8010946f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109472:	83 ec 04             	sub    $0x4,%esp
80109475:	ff 75 f4             	push   -0xc(%ebp)
80109478:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010947b:	50                   	push   %eax
8010947c:	ff 75 ec             	push   -0x14(%ebp)
8010947f:	e8 62 00 00 00       	call   801094e6 <arp_broadcast>
80109484:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109487:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010948a:	83 ec 08             	sub    $0x8,%esp
8010948d:	50                   	push   %eax
8010948e:	ff 75 ec             	push   -0x14(%ebp)
80109491:	e8 28 fd ff ff       	call   801091be <i8254_send>
80109496:	83 c4 10             	add    $0x10,%esp
80109499:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010949c:	eb 22                	jmp    801094c0 <arp_scan+0x65>
      microdelay(1);
8010949e:	83 ec 0c             	sub    $0xc,%esp
801094a1:	6a 01                	push   $0x1
801094a3:	e8 73 9b ff ff       	call   8010301b <microdelay>
801094a8:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801094ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094ae:	83 ec 08             	sub    $0x8,%esp
801094b1:	50                   	push   %eax
801094b2:	ff 75 ec             	push   -0x14(%ebp)
801094b5:	e8 04 fd ff ff       	call   801091be <i8254_send>
801094ba:	83 c4 10             	add    $0x10,%esp
801094bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801094c0:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801094c4:	74 d8                	je     8010949e <arp_scan+0x43>
    }
    kfree((char *)send);
801094c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801094c9:	83 ec 0c             	sub    $0xc,%esp
801094cc:	50                   	push   %eax
801094cd:	e8 1e 97 ff ff       	call   80102bf0 <kfree>
801094d2:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801094d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801094d9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801094e0:	7e 88                	jle    8010946a <arp_scan+0xf>
  }
}
801094e2:	90                   	nop
801094e3:	90                   	nop
801094e4:	c9                   	leave
801094e5:	c3                   	ret

801094e6 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801094e6:	55                   	push   %ebp
801094e7:	89 e5                	mov    %esp,%ebp
801094e9:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801094ec:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801094f0:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801094f4:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801094f8:	8b 45 10             	mov    0x10(%ebp),%eax
801094fb:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801094fe:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109505:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
8010950b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109512:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109518:	8b 45 0c             	mov    0xc(%ebp),%eax
8010951b:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109521:	8b 45 08             	mov    0x8(%ebp),%eax
80109524:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109527:	8b 45 08             	mov    0x8(%ebp),%eax
8010952a:	83 c0 0e             	add    $0xe,%eax
8010952d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109533:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109537:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953a:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010953e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109541:	83 ec 04             	sub    $0x4,%esp
80109544:	6a 06                	push   $0x6
80109546:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109549:	52                   	push   %edx
8010954a:	50                   	push   %eax
8010954b:	e8 19 bc ff ff       	call   80105169 <memmove>
80109550:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109556:	83 c0 06             	add    $0x6,%eax
80109559:	83 ec 04             	sub    $0x4,%esp
8010955c:	6a 06                	push   $0x6
8010955e:	68 c0 9d 11 80       	push   $0x80119dc0
80109563:	50                   	push   %eax
80109564:	e8 00 bc ff ff       	call   80105169 <memmove>
80109569:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
8010956c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956f:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109577:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
8010957d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109580:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109587:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
8010958b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010958e:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109594:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109597:	8d 50 12             	lea    0x12(%eax),%edx
8010959a:	83 ec 04             	sub    $0x4,%esp
8010959d:	6a 06                	push   $0x6
8010959f:	8d 45 e0             	lea    -0x20(%ebp),%eax
801095a2:	50                   	push   %eax
801095a3:	52                   	push   %edx
801095a4:	e8 c0 bb ff ff       	call   80105169 <memmove>
801095a9:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801095ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095af:	8d 50 18             	lea    0x18(%eax),%edx
801095b2:	83 ec 04             	sub    $0x4,%esp
801095b5:	6a 04                	push   $0x4
801095b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801095ba:	50                   	push   %eax
801095bb:	52                   	push   %edx
801095bc:	e8 a8 bb ff ff       	call   80105169 <memmove>
801095c1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801095c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c7:	83 c0 08             	add    $0x8,%eax
801095ca:	83 ec 04             	sub    $0x4,%esp
801095cd:	6a 06                	push   $0x6
801095cf:	68 c0 9d 11 80       	push   $0x80119dc0
801095d4:	50                   	push   %eax
801095d5:	e8 8f bb ff ff       	call   80105169 <memmove>
801095da:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801095dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e0:	83 c0 0e             	add    $0xe,%eax
801095e3:	83 ec 04             	sub    $0x4,%esp
801095e6:	6a 04                	push   $0x4
801095e8:	68 e4 f4 10 80       	push   $0x8010f4e4
801095ed:	50                   	push   %eax
801095ee:	e8 76 bb ff ff       	call   80105169 <memmove>
801095f3:	83 c4 10             	add    $0x10,%esp
}
801095f6:	90                   	nop
801095f7:	c9                   	leave
801095f8:	c3                   	ret

801095f9 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801095f9:	55                   	push   %ebp
801095fa:	89 e5                	mov    %esp,%ebp
801095fc:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801095ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109602:	83 c0 0e             	add    $0xe,%eax
80109605:	83 ec 0c             	sub    $0xc,%esp
80109608:	50                   	push   %eax
80109609:	e8 bc 00 00 00       	call   801096ca <arp_table_search>
8010960e:	83 c4 10             	add    $0x10,%esp
80109611:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109614:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109618:	78 2d                	js     80109647 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010961a:	8b 45 08             	mov    0x8(%ebp),%eax
8010961d:	8d 48 08             	lea    0x8(%eax),%ecx
80109620:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109623:	89 d0                	mov    %edx,%eax
80109625:	c1 e0 02             	shl    $0x2,%eax
80109628:	01 d0                	add    %edx,%eax
8010962a:	01 c0                	add    %eax,%eax
8010962c:	01 d0                	add    %edx,%eax
8010962e:	05 e0 9d 11 80       	add    $0x80119de0,%eax
80109633:	83 c0 04             	add    $0x4,%eax
80109636:	83 ec 04             	sub    $0x4,%esp
80109639:	6a 06                	push   $0x6
8010963b:	51                   	push   %ecx
8010963c:	50                   	push   %eax
8010963d:	e8 27 bb ff ff       	call   80105169 <memmove>
80109642:	83 c4 10             	add    $0x10,%esp
80109645:	eb 70                	jmp    801096b7 <arp_table_update+0xbe>
  }else{
    index += 1;
80109647:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
8010964b:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010964e:	8b 45 08             	mov    0x8(%ebp),%eax
80109651:	8d 48 08             	lea    0x8(%eax),%ecx
80109654:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109657:	89 d0                	mov    %edx,%eax
80109659:	c1 e0 02             	shl    $0x2,%eax
8010965c:	01 d0                	add    %edx,%eax
8010965e:	01 c0                	add    %eax,%eax
80109660:	01 d0                	add    %edx,%eax
80109662:	05 e0 9d 11 80       	add    $0x80119de0,%eax
80109667:	83 c0 04             	add    $0x4,%eax
8010966a:	83 ec 04             	sub    $0x4,%esp
8010966d:	6a 06                	push   $0x6
8010966f:	51                   	push   %ecx
80109670:	50                   	push   %eax
80109671:	e8 f3 ba ff ff       	call   80105169 <memmove>
80109676:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109679:	8b 45 08             	mov    0x8(%ebp),%eax
8010967c:	8d 48 0e             	lea    0xe(%eax),%ecx
8010967f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109682:	89 d0                	mov    %edx,%eax
80109684:	c1 e0 02             	shl    $0x2,%eax
80109687:	01 d0                	add    %edx,%eax
80109689:	01 c0                	add    %eax,%eax
8010968b:	01 d0                	add    %edx,%eax
8010968d:	05 e0 9d 11 80       	add    $0x80119de0,%eax
80109692:	83 ec 04             	sub    $0x4,%esp
80109695:	6a 04                	push   $0x4
80109697:	51                   	push   %ecx
80109698:	50                   	push   %eax
80109699:	e8 cb ba ff ff       	call   80105169 <memmove>
8010969e:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801096a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096a4:	89 d0                	mov    %edx,%eax
801096a6:	c1 e0 02             	shl    $0x2,%eax
801096a9:	01 d0                	add    %edx,%eax
801096ab:	01 c0                	add    %eax,%eax
801096ad:	01 d0                	add    %edx,%eax
801096af:	05 ea 9d 11 80       	add    $0x80119dea,%eax
801096b4:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801096b7:	83 ec 0c             	sub    $0xc,%esp
801096ba:	68 e0 9d 11 80       	push   $0x80119de0
801096bf:	e8 83 00 00 00       	call   80109747 <print_arp_table>
801096c4:	83 c4 10             	add    $0x10,%esp
}
801096c7:	90                   	nop
801096c8:	c9                   	leave
801096c9:	c3                   	ret

801096ca <arp_table_search>:

int arp_table_search(uchar *ip){
801096ca:	55                   	push   %ebp
801096cb:	89 e5                	mov    %esp,%ebp
801096cd:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801096d0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801096d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801096de:	eb 59                	jmp    80109739 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801096e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801096e3:	89 d0                	mov    %edx,%eax
801096e5:	c1 e0 02             	shl    $0x2,%eax
801096e8:	01 d0                	add    %edx,%eax
801096ea:	01 c0                	add    %eax,%eax
801096ec:	01 d0                	add    %edx,%eax
801096ee:	05 e0 9d 11 80       	add    $0x80119de0,%eax
801096f3:	83 ec 04             	sub    $0x4,%esp
801096f6:	6a 04                	push   $0x4
801096f8:	ff 75 08             	push   0x8(%ebp)
801096fb:	50                   	push   %eax
801096fc:	e8 10 ba ff ff       	call   80105111 <memcmp>
80109701:	83 c4 10             	add    $0x10,%esp
80109704:	85 c0                	test   %eax,%eax
80109706:	75 05                	jne    8010970d <arp_table_search+0x43>
      return i;
80109708:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010970b:	eb 38                	jmp    80109745 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010970d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109710:	89 d0                	mov    %edx,%eax
80109712:	c1 e0 02             	shl    $0x2,%eax
80109715:	01 d0                	add    %edx,%eax
80109717:	01 c0                	add    %eax,%eax
80109719:	01 d0                	add    %edx,%eax
8010971b:	05 ea 9d 11 80       	add    $0x80119dea,%eax
80109720:	0f b6 00             	movzbl (%eax),%eax
80109723:	84 c0                	test   %al,%al
80109725:	75 0e                	jne    80109735 <arp_table_search+0x6b>
80109727:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010972b:	75 08                	jne    80109735 <arp_table_search+0x6b>
      empty = -i;
8010972d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109730:	f7 d8                	neg    %eax
80109732:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109735:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109739:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010973d:	7e a1                	jle    801096e0 <arp_table_search+0x16>
    }
  }
  return empty-1;
8010973f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109742:	83 e8 01             	sub    $0x1,%eax
}
80109745:	c9                   	leave
80109746:	c3                   	ret

80109747 <print_arp_table>:

void print_arp_table(){
80109747:	55                   	push   %ebp
80109748:	89 e5                	mov    %esp,%ebp
8010974a:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010974d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109754:	e9 92 00 00 00       	jmp    801097eb <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109759:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010975c:	89 d0                	mov    %edx,%eax
8010975e:	c1 e0 02             	shl    $0x2,%eax
80109761:	01 d0                	add    %edx,%eax
80109763:	01 c0                	add    %eax,%eax
80109765:	01 d0                	add    %edx,%eax
80109767:	05 ea 9d 11 80       	add    $0x80119dea,%eax
8010976c:	0f b6 00             	movzbl (%eax),%eax
8010976f:	84 c0                	test   %al,%al
80109771:	74 74                	je     801097e7 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109773:	83 ec 08             	sub    $0x8,%esp
80109776:	ff 75 f4             	push   -0xc(%ebp)
80109779:	68 2f c5 10 80       	push   $0x8010c52f
8010977e:	e8 71 6c ff ff       	call   801003f4 <cprintf>
80109783:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109786:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109789:	89 d0                	mov    %edx,%eax
8010978b:	c1 e0 02             	shl    $0x2,%eax
8010978e:	01 d0                	add    %edx,%eax
80109790:	01 c0                	add    %eax,%eax
80109792:	01 d0                	add    %edx,%eax
80109794:	05 e0 9d 11 80       	add    $0x80119de0,%eax
80109799:	83 ec 0c             	sub    $0xc,%esp
8010979c:	50                   	push   %eax
8010979d:	e8 54 02 00 00       	call   801099f6 <print_ipv4>
801097a2:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801097a5:	83 ec 0c             	sub    $0xc,%esp
801097a8:	68 3e c5 10 80       	push   $0x8010c53e
801097ad:	e8 42 6c ff ff       	call   801003f4 <cprintf>
801097b2:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801097b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097b8:	89 d0                	mov    %edx,%eax
801097ba:	c1 e0 02             	shl    $0x2,%eax
801097bd:	01 d0                	add    %edx,%eax
801097bf:	01 c0                	add    %eax,%eax
801097c1:	01 d0                	add    %edx,%eax
801097c3:	05 e0 9d 11 80       	add    $0x80119de0,%eax
801097c8:	83 c0 04             	add    $0x4,%eax
801097cb:	83 ec 0c             	sub    $0xc,%esp
801097ce:	50                   	push   %eax
801097cf:	e8 70 02 00 00       	call   80109a44 <print_mac>
801097d4:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801097d7:	83 ec 0c             	sub    $0xc,%esp
801097da:	68 40 c5 10 80       	push   $0x8010c540
801097df:	e8 10 6c ff ff       	call   801003f4 <cprintf>
801097e4:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801097e7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801097eb:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801097ef:	0f 8e 64 ff ff ff    	jle    80109759 <print_arp_table+0x12>
    }
  }
}
801097f5:	90                   	nop
801097f6:	90                   	nop
801097f7:	c9                   	leave
801097f8:	c3                   	ret

801097f9 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801097f9:	55                   	push   %ebp
801097fa:	89 e5                	mov    %esp,%ebp
801097fc:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801097ff:	8b 45 10             	mov    0x10(%ebp),%eax
80109802:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010980b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010980e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109811:	83 c0 0e             	add    $0xe,%eax
80109814:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109817:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010981a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010981e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109821:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109825:	8b 45 08             	mov    0x8(%ebp),%eax
80109828:	8d 50 08             	lea    0x8(%eax),%edx
8010982b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010982e:	83 ec 04             	sub    $0x4,%esp
80109831:	6a 06                	push   $0x6
80109833:	52                   	push   %edx
80109834:	50                   	push   %eax
80109835:	e8 2f b9 ff ff       	call   80105169 <memmove>
8010983a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010983d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109840:	83 c0 06             	add    $0x6,%eax
80109843:	83 ec 04             	sub    $0x4,%esp
80109846:	6a 06                	push   $0x6
80109848:	68 c0 9d 11 80       	push   $0x80119dc0
8010984d:	50                   	push   %eax
8010984e:	e8 16 b9 ff ff       	call   80105169 <memmove>
80109853:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109856:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109859:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010985e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109861:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010986a:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010986e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109871:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109878:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010987e:	8b 45 08             	mov    0x8(%ebp),%eax
80109881:	8d 50 08             	lea    0x8(%eax),%edx
80109884:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109887:	83 c0 12             	add    $0x12,%eax
8010988a:	83 ec 04             	sub    $0x4,%esp
8010988d:	6a 06                	push   $0x6
8010988f:	52                   	push   %edx
80109890:	50                   	push   %eax
80109891:	e8 d3 b8 ff ff       	call   80105169 <memmove>
80109896:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109899:	8b 45 08             	mov    0x8(%ebp),%eax
8010989c:	8d 50 0e             	lea    0xe(%eax),%edx
8010989f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098a2:	83 c0 18             	add    $0x18,%eax
801098a5:	83 ec 04             	sub    $0x4,%esp
801098a8:	6a 04                	push   $0x4
801098aa:	52                   	push   %edx
801098ab:	50                   	push   %eax
801098ac:	e8 b8 b8 ff ff       	call   80105169 <memmove>
801098b1:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801098b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098b7:	83 c0 08             	add    $0x8,%eax
801098ba:	83 ec 04             	sub    $0x4,%esp
801098bd:	6a 06                	push   $0x6
801098bf:	68 c0 9d 11 80       	push   $0x80119dc0
801098c4:	50                   	push   %eax
801098c5:	e8 9f b8 ff ff       	call   80105169 <memmove>
801098ca:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801098cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d0:	83 c0 0e             	add    $0xe,%eax
801098d3:	83 ec 04             	sub    $0x4,%esp
801098d6:	6a 04                	push   $0x4
801098d8:	68 e4 f4 10 80       	push   $0x8010f4e4
801098dd:	50                   	push   %eax
801098de:	e8 86 b8 ff ff       	call   80105169 <memmove>
801098e3:	83 c4 10             	add    $0x10,%esp
}
801098e6:	90                   	nop
801098e7:	c9                   	leave
801098e8:	c3                   	ret

801098e9 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801098e9:	55                   	push   %ebp
801098ea:	89 e5                	mov    %esp,%ebp
801098ec:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801098ef:	83 ec 0c             	sub    $0xc,%esp
801098f2:	68 42 c5 10 80       	push   $0x8010c542
801098f7:	e8 f8 6a ff ff       	call   801003f4 <cprintf>
801098fc:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801098ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109902:	83 c0 0e             	add    $0xe,%eax
80109905:	83 ec 0c             	sub    $0xc,%esp
80109908:	50                   	push   %eax
80109909:	e8 e8 00 00 00       	call   801099f6 <print_ipv4>
8010990e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109911:	83 ec 0c             	sub    $0xc,%esp
80109914:	68 40 c5 10 80       	push   $0x8010c540
80109919:	e8 d6 6a ff ff       	call   801003f4 <cprintf>
8010991e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109921:	8b 45 08             	mov    0x8(%ebp),%eax
80109924:	83 c0 08             	add    $0x8,%eax
80109927:	83 ec 0c             	sub    $0xc,%esp
8010992a:	50                   	push   %eax
8010992b:	e8 14 01 00 00       	call   80109a44 <print_mac>
80109930:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109933:	83 ec 0c             	sub    $0xc,%esp
80109936:	68 40 c5 10 80       	push   $0x8010c540
8010993b:	e8 b4 6a ff ff       	call   801003f4 <cprintf>
80109940:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109943:	83 ec 0c             	sub    $0xc,%esp
80109946:	68 59 c5 10 80       	push   $0x8010c559
8010994b:	e8 a4 6a ff ff       	call   801003f4 <cprintf>
80109950:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109953:	8b 45 08             	mov    0x8(%ebp),%eax
80109956:	83 c0 18             	add    $0x18,%eax
80109959:	83 ec 0c             	sub    $0xc,%esp
8010995c:	50                   	push   %eax
8010995d:	e8 94 00 00 00       	call   801099f6 <print_ipv4>
80109962:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109965:	83 ec 0c             	sub    $0xc,%esp
80109968:	68 40 c5 10 80       	push   $0x8010c540
8010996d:	e8 82 6a ff ff       	call   801003f4 <cprintf>
80109972:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109975:	8b 45 08             	mov    0x8(%ebp),%eax
80109978:	83 c0 12             	add    $0x12,%eax
8010997b:	83 ec 0c             	sub    $0xc,%esp
8010997e:	50                   	push   %eax
8010997f:	e8 c0 00 00 00       	call   80109a44 <print_mac>
80109984:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109987:	83 ec 0c             	sub    $0xc,%esp
8010998a:	68 40 c5 10 80       	push   $0x8010c540
8010998f:	e8 60 6a ff ff       	call   801003f4 <cprintf>
80109994:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109997:	83 ec 0c             	sub    $0xc,%esp
8010999a:	68 70 c5 10 80       	push   $0x8010c570
8010999f:	e8 50 6a ff ff       	call   801003f4 <cprintf>
801099a4:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801099a7:	8b 45 08             	mov    0x8(%ebp),%eax
801099aa:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099ae:	66 3d 00 01          	cmp    $0x100,%ax
801099b2:	75 12                	jne    801099c6 <print_arp_info+0xdd>
801099b4:	83 ec 0c             	sub    $0xc,%esp
801099b7:	68 7c c5 10 80       	push   $0x8010c57c
801099bc:	e8 33 6a ff ff       	call   801003f4 <cprintf>
801099c1:	83 c4 10             	add    $0x10,%esp
801099c4:	eb 1d                	jmp    801099e3 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801099c6:	8b 45 08             	mov    0x8(%ebp),%eax
801099c9:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099cd:	66 3d 00 02          	cmp    $0x200,%ax
801099d1:	75 10                	jne    801099e3 <print_arp_info+0xfa>
    cprintf("Reply\n");
801099d3:	83 ec 0c             	sub    $0xc,%esp
801099d6:	68 85 c5 10 80       	push   $0x8010c585
801099db:	e8 14 6a ff ff       	call   801003f4 <cprintf>
801099e0:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801099e3:	83 ec 0c             	sub    $0xc,%esp
801099e6:	68 40 c5 10 80       	push   $0x8010c540
801099eb:	e8 04 6a ff ff       	call   801003f4 <cprintf>
801099f0:	83 c4 10             	add    $0x10,%esp
}
801099f3:	90                   	nop
801099f4:	c9                   	leave
801099f5:	c3                   	ret

801099f6 <print_ipv4>:

void print_ipv4(uchar *ip){
801099f6:	55                   	push   %ebp
801099f7:	89 e5                	mov    %esp,%ebp
801099f9:	53                   	push   %ebx
801099fa:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801099fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109a00:	83 c0 03             	add    $0x3,%eax
80109a03:	0f b6 00             	movzbl (%eax),%eax
80109a06:	0f b6 d8             	movzbl %al,%ebx
80109a09:	8b 45 08             	mov    0x8(%ebp),%eax
80109a0c:	83 c0 02             	add    $0x2,%eax
80109a0f:	0f b6 00             	movzbl (%eax),%eax
80109a12:	0f b6 c8             	movzbl %al,%ecx
80109a15:	8b 45 08             	mov    0x8(%ebp),%eax
80109a18:	83 c0 01             	add    $0x1,%eax
80109a1b:	0f b6 00             	movzbl (%eax),%eax
80109a1e:	0f b6 d0             	movzbl %al,%edx
80109a21:	8b 45 08             	mov    0x8(%ebp),%eax
80109a24:	0f b6 00             	movzbl (%eax),%eax
80109a27:	0f b6 c0             	movzbl %al,%eax
80109a2a:	83 ec 0c             	sub    $0xc,%esp
80109a2d:	53                   	push   %ebx
80109a2e:	51                   	push   %ecx
80109a2f:	52                   	push   %edx
80109a30:	50                   	push   %eax
80109a31:	68 8c c5 10 80       	push   $0x8010c58c
80109a36:	e8 b9 69 ff ff       	call   801003f4 <cprintf>
80109a3b:	83 c4 20             	add    $0x20,%esp
}
80109a3e:	90                   	nop
80109a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109a42:	c9                   	leave
80109a43:	c3                   	ret

80109a44 <print_mac>:

void print_mac(uchar *mac){
80109a44:	55                   	push   %ebp
80109a45:	89 e5                	mov    %esp,%ebp
80109a47:	57                   	push   %edi
80109a48:	56                   	push   %esi
80109a49:	53                   	push   %ebx
80109a4a:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a50:	83 c0 05             	add    $0x5,%eax
80109a53:	0f b6 00             	movzbl (%eax),%eax
80109a56:	0f b6 f8             	movzbl %al,%edi
80109a59:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5c:	83 c0 04             	add    $0x4,%eax
80109a5f:	0f b6 00             	movzbl (%eax),%eax
80109a62:	0f b6 f0             	movzbl %al,%esi
80109a65:	8b 45 08             	mov    0x8(%ebp),%eax
80109a68:	83 c0 03             	add    $0x3,%eax
80109a6b:	0f b6 00             	movzbl (%eax),%eax
80109a6e:	0f b6 d8             	movzbl %al,%ebx
80109a71:	8b 45 08             	mov    0x8(%ebp),%eax
80109a74:	83 c0 02             	add    $0x2,%eax
80109a77:	0f b6 00             	movzbl (%eax),%eax
80109a7a:	0f b6 c8             	movzbl %al,%ecx
80109a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a80:	83 c0 01             	add    $0x1,%eax
80109a83:	0f b6 00             	movzbl (%eax),%eax
80109a86:	0f b6 d0             	movzbl %al,%edx
80109a89:	8b 45 08             	mov    0x8(%ebp),%eax
80109a8c:	0f b6 00             	movzbl (%eax),%eax
80109a8f:	0f b6 c0             	movzbl %al,%eax
80109a92:	83 ec 04             	sub    $0x4,%esp
80109a95:	57                   	push   %edi
80109a96:	56                   	push   %esi
80109a97:	53                   	push   %ebx
80109a98:	51                   	push   %ecx
80109a99:	52                   	push   %edx
80109a9a:	50                   	push   %eax
80109a9b:	68 a4 c5 10 80       	push   $0x8010c5a4
80109aa0:	e8 4f 69 ff ff       	call   801003f4 <cprintf>
80109aa5:	83 c4 20             	add    $0x20,%esp
}
80109aa8:	90                   	nop
80109aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109aac:	5b                   	pop    %ebx
80109aad:	5e                   	pop    %esi
80109aae:	5f                   	pop    %edi
80109aaf:	5d                   	pop    %ebp
80109ab0:	c3                   	ret

80109ab1 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109ab1:	55                   	push   %ebp
80109ab2:	89 e5                	mov    %esp,%ebp
80109ab4:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80109aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109abd:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac0:	83 c0 0e             	add    $0xe,%eax
80109ac3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ac9:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109acd:	3c 08                	cmp    $0x8,%al
80109acf:	75 1b                	jne    80109aec <eth_proc+0x3b>
80109ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ad4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109ad8:	3c 06                	cmp    $0x6,%al
80109ada:	75 10                	jne    80109aec <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109adc:	83 ec 0c             	sub    $0xc,%esp
80109adf:	ff 75 f0             	push   -0x10(%ebp)
80109ae2:	e8 01 f8 ff ff       	call   801092e8 <arp_proc>
80109ae7:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109aea:	eb 24                	jmp    80109b10 <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aef:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109af3:	3c 08                	cmp    $0x8,%al
80109af5:	75 19                	jne    80109b10 <eth_proc+0x5f>
80109af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109afa:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109afe:	84 c0                	test   %al,%al
80109b00:	75 0e                	jne    80109b10 <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109b02:	83 ec 0c             	sub    $0xc,%esp
80109b05:	ff 75 08             	push   0x8(%ebp)
80109b08:	e8 8d 00 00 00       	call   80109b9a <ipv4_proc>
80109b0d:	83 c4 10             	add    $0x10,%esp
}
80109b10:	90                   	nop
80109b11:	c9                   	leave
80109b12:	c3                   	ret

80109b13 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109b13:	55                   	push   %ebp
80109b14:	89 e5                	mov    %esp,%ebp
80109b16:	83 ec 04             	sub    $0x4,%esp
80109b19:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b20:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b24:	66 c1 c0 08          	rol    $0x8,%ax
}
80109b28:	c9                   	leave
80109b29:	c3                   	ret

80109b2a <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109b2a:	55                   	push   %ebp
80109b2b:	89 e5                	mov    %esp,%ebp
80109b2d:	83 ec 04             	sub    $0x4,%esp
80109b30:	8b 45 08             	mov    0x8(%ebp),%eax
80109b33:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109b37:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109b3b:	66 c1 c0 08          	rol    $0x8,%ax
}
80109b3f:	c9                   	leave
80109b40:	c3                   	ret

80109b41 <H2N_uint>:

uint H2N_uint(uint value){
80109b41:	55                   	push   %ebp
80109b42:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109b44:	8b 45 08             	mov    0x8(%ebp),%eax
80109b47:	c1 e0 18             	shl    $0x18,%eax
80109b4a:	25 00 00 00 0f       	and    $0xf000000,%eax
80109b4f:	89 c2                	mov    %eax,%edx
80109b51:	8b 45 08             	mov    0x8(%ebp),%eax
80109b54:	c1 e0 08             	shl    $0x8,%eax
80109b57:	25 00 f0 00 00       	and    $0xf000,%eax
80109b5c:	09 c2                	or     %eax,%edx
80109b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b61:	c1 e8 08             	shr    $0x8,%eax
80109b64:	83 e0 0f             	and    $0xf,%eax
80109b67:	01 d0                	add    %edx,%eax
}
80109b69:	5d                   	pop    %ebp
80109b6a:	c3                   	ret

80109b6b <N2H_uint>:

uint N2H_uint(uint value){
80109b6b:	55                   	push   %ebp
80109b6c:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b71:	c1 e0 18             	shl    $0x18,%eax
80109b74:	89 c2                	mov    %eax,%edx
80109b76:	8b 45 08             	mov    0x8(%ebp),%eax
80109b79:	c1 e0 08             	shl    $0x8,%eax
80109b7c:	25 00 00 ff 00       	and    $0xff0000,%eax
80109b81:	01 c2                	add    %eax,%edx
80109b83:	8b 45 08             	mov    0x8(%ebp),%eax
80109b86:	c1 e8 08             	shr    $0x8,%eax
80109b89:	25 00 ff 00 00       	and    $0xff00,%eax
80109b8e:	01 c2                	add    %eax,%edx
80109b90:	8b 45 08             	mov    0x8(%ebp),%eax
80109b93:	c1 e8 18             	shr    $0x18,%eax
80109b96:	01 d0                	add    %edx,%eax
}
80109b98:	5d                   	pop    %ebp
80109b99:	c3                   	ret

80109b9a <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109b9a:	55                   	push   %ebp
80109b9b:	89 e5                	mov    %esp,%ebp
80109b9d:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba3:	83 c0 0e             	add    $0xe,%eax
80109ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bac:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109bb0:	0f b7 d0             	movzwl %ax,%edx
80109bb3:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
80109bb8:	39 c2                	cmp    %eax,%edx
80109bba:	74 60                	je     80109c1c <ipv4_proc+0x82>
80109bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bbf:	83 c0 0c             	add    $0xc,%eax
80109bc2:	83 ec 04             	sub    $0x4,%esp
80109bc5:	6a 04                	push   $0x4
80109bc7:	50                   	push   %eax
80109bc8:	68 e4 f4 10 80       	push   $0x8010f4e4
80109bcd:	e8 3f b5 ff ff       	call   80105111 <memcmp>
80109bd2:	83 c4 10             	add    $0x10,%esp
80109bd5:	85 c0                	test   %eax,%eax
80109bd7:	74 43                	je     80109c1c <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bdc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109be0:	0f b7 c0             	movzwl %ax,%eax
80109be3:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109beb:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109bef:	3c 01                	cmp    $0x1,%al
80109bf1:	75 10                	jne    80109c03 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109bf3:	83 ec 0c             	sub    $0xc,%esp
80109bf6:	ff 75 08             	push   0x8(%ebp)
80109bf9:	e8 a3 00 00 00       	call   80109ca1 <icmp_proc>
80109bfe:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109c01:	eb 19                	jmp    80109c1c <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c06:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109c0a:	3c 06                	cmp    $0x6,%al
80109c0c:	75 0e                	jne    80109c1c <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109c0e:	83 ec 0c             	sub    $0xc,%esp
80109c11:	ff 75 08             	push   0x8(%ebp)
80109c14:	e8 b3 03 00 00       	call   80109fcc <tcp_proc>
80109c19:	83 c4 10             	add    $0x10,%esp
}
80109c1c:	90                   	nop
80109c1d:	c9                   	leave
80109c1e:	c3                   	ret

80109c1f <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109c1f:	55                   	push   %ebp
80109c20:	89 e5                	mov    %esp,%ebp
80109c22:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109c25:	8b 45 08             	mov    0x8(%ebp),%eax
80109c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c2e:	0f b6 00             	movzbl (%eax),%eax
80109c31:	83 e0 0f             	and    $0xf,%eax
80109c34:	01 c0                	add    %eax,%eax
80109c36:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109c39:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c40:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109c47:	eb 48                	jmp    80109c91 <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109c49:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c4c:	01 c0                	add    %eax,%eax
80109c4e:	89 c2                	mov    %eax,%edx
80109c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c53:	01 d0                	add    %edx,%eax
80109c55:	0f b6 00             	movzbl (%eax),%eax
80109c58:	0f b6 c0             	movzbl %al,%eax
80109c5b:	c1 e0 08             	shl    $0x8,%eax
80109c5e:	89 c2                	mov    %eax,%edx
80109c60:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c63:	01 c0                	add    %eax,%eax
80109c65:	8d 48 01             	lea    0x1(%eax),%ecx
80109c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c6b:	01 c8                	add    %ecx,%eax
80109c6d:	0f b6 00             	movzbl (%eax),%eax
80109c70:	0f b6 c0             	movzbl %al,%eax
80109c73:	01 d0                	add    %edx,%eax
80109c75:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109c78:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109c7f:	76 0c                	jbe    80109c8d <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109c81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c84:	0f b7 c0             	movzwl %ax,%eax
80109c87:	83 c0 01             	add    $0x1,%eax
80109c8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c8d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109c91:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109c95:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109c98:	7c af                	jl     80109c49 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109c9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c9d:	f7 d0                	not    %eax
}
80109c9f:	c9                   	leave
80109ca0:	c3                   	ret

80109ca1 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109ca1:	55                   	push   %ebp
80109ca2:	89 e5                	mov    %esp,%ebp
80109ca4:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80109caa:	83 c0 0e             	add    $0xe,%eax
80109cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cb3:	0f b6 00             	movzbl (%eax),%eax
80109cb6:	0f b6 c0             	movzbl %al,%eax
80109cb9:	83 e0 0f             	and    $0xf,%eax
80109cbc:	c1 e0 02             	shl    $0x2,%eax
80109cbf:	89 c2                	mov    %eax,%edx
80109cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cc4:	01 d0                	add    %edx,%eax
80109cc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ccc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109cd0:	84 c0                	test   %al,%al
80109cd2:	75 4f                	jne    80109d23 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cd7:	0f b6 00             	movzbl (%eax),%eax
80109cda:	3c 08                	cmp    $0x8,%al
80109cdc:	75 45                	jne    80109d23 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109cde:	e8 a7 8f ff ff       	call   80102c8a <kalloc>
80109ce3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109ce6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109ced:	83 ec 04             	sub    $0x4,%esp
80109cf0:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109cf3:	50                   	push   %eax
80109cf4:	ff 75 ec             	push   -0x14(%ebp)
80109cf7:	ff 75 08             	push   0x8(%ebp)
80109cfa:	e8 78 00 00 00       	call   80109d77 <icmp_reply_pkt_create>
80109cff:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109d02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d05:	83 ec 08             	sub    $0x8,%esp
80109d08:	50                   	push   %eax
80109d09:	ff 75 ec             	push   -0x14(%ebp)
80109d0c:	e8 ad f4 ff ff       	call   801091be <i8254_send>
80109d11:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d17:	83 ec 0c             	sub    $0xc,%esp
80109d1a:	50                   	push   %eax
80109d1b:	e8 d0 8e ff ff       	call   80102bf0 <kfree>
80109d20:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109d23:	90                   	nop
80109d24:	c9                   	leave
80109d25:	c3                   	ret

80109d26 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109d26:	55                   	push   %ebp
80109d27:	89 e5                	mov    %esp,%ebp
80109d29:	53                   	push   %ebx
80109d2a:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d30:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109d34:	0f b7 c0             	movzwl %ax,%eax
80109d37:	83 ec 0c             	sub    $0xc,%esp
80109d3a:	50                   	push   %eax
80109d3b:	e8 d3 fd ff ff       	call   80109b13 <N2H_ushort>
80109d40:	83 c4 10             	add    $0x10,%esp
80109d43:	0f b7 d8             	movzwl %ax,%ebx
80109d46:	8b 45 08             	mov    0x8(%ebp),%eax
80109d49:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d4d:	0f b7 c0             	movzwl %ax,%eax
80109d50:	83 ec 0c             	sub    $0xc,%esp
80109d53:	50                   	push   %eax
80109d54:	e8 ba fd ff ff       	call   80109b13 <N2H_ushort>
80109d59:	83 c4 10             	add    $0x10,%esp
80109d5c:	0f b7 c0             	movzwl %ax,%eax
80109d5f:	83 ec 04             	sub    $0x4,%esp
80109d62:	53                   	push   %ebx
80109d63:	50                   	push   %eax
80109d64:	68 c3 c5 10 80       	push   $0x8010c5c3
80109d69:	e8 86 66 ff ff       	call   801003f4 <cprintf>
80109d6e:	83 c4 10             	add    $0x10,%esp
}
80109d71:	90                   	nop
80109d72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109d75:	c9                   	leave
80109d76:	c3                   	ret

80109d77 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109d77:	55                   	push   %ebp
80109d78:	89 e5                	mov    %esp,%ebp
80109d7a:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109d83:	8b 45 08             	mov    0x8(%ebp),%eax
80109d86:	83 c0 0e             	add    $0xe,%eax
80109d89:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d8f:	0f b6 00             	movzbl (%eax),%eax
80109d92:	0f b6 c0             	movzbl %al,%eax
80109d95:	83 e0 0f             	and    $0xf,%eax
80109d98:	c1 e0 02             	shl    $0x2,%eax
80109d9b:	89 c2                	mov    %eax,%edx
80109d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109da0:	01 d0                	add    %edx,%eax
80109da2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109da5:	8b 45 0c             	mov    0xc(%ebp),%eax
80109da8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109dab:	8b 45 0c             	mov    0xc(%ebp),%eax
80109dae:	83 c0 0e             	add    $0xe,%eax
80109db1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db7:	83 c0 14             	add    $0x14,%eax
80109dba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109dbd:	8b 45 10             	mov    0x10(%ebp),%eax
80109dc0:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dc9:	8d 50 06             	lea    0x6(%eax),%edx
80109dcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dcf:	83 ec 04             	sub    $0x4,%esp
80109dd2:	6a 06                	push   $0x6
80109dd4:	52                   	push   %edx
80109dd5:	50                   	push   %eax
80109dd6:	e8 8e b3 ff ff       	call   80105169 <memmove>
80109ddb:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109dde:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109de1:	83 c0 06             	add    $0x6,%eax
80109de4:	83 ec 04             	sub    $0x4,%esp
80109de7:	6a 06                	push   $0x6
80109de9:	68 c0 9d 11 80       	push   $0x80119dc0
80109dee:	50                   	push   %eax
80109def:	e8 75 b3 ff ff       	call   80105169 <memmove>
80109df4:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109df7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dfa:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109dfe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e01:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e08:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109e0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e0e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109e12:	83 ec 0c             	sub    $0xc,%esp
80109e15:	6a 54                	push   $0x54
80109e17:	e8 0e fd ff ff       	call   80109b2a <H2N_ushort>
80109e1c:	83 c4 10             	add    $0x10,%esp
80109e1f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e22:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109e26:	0f b7 15 a0 a0 11 80 	movzwl 0x8011a0a0,%edx
80109e2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e30:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109e34:	0f b7 05 a0 a0 11 80 	movzwl 0x8011a0a0,%eax
80109e3b:	83 c0 01             	add    $0x1,%eax
80109e3e:	66 a3 a0 a0 11 80    	mov    %ax,0x8011a0a0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109e44:	83 ec 0c             	sub    $0xc,%esp
80109e47:	68 00 40 00 00       	push   $0x4000
80109e4c:	e8 d9 fc ff ff       	call   80109b2a <H2N_ushort>
80109e51:	83 c4 10             	add    $0x10,%esp
80109e54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e57:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e5e:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109e62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e65:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109e69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e6c:	83 c0 0c             	add    $0xc,%eax
80109e6f:	83 ec 04             	sub    $0x4,%esp
80109e72:	6a 04                	push   $0x4
80109e74:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e79:	50                   	push   %eax
80109e7a:	e8 ea b2 ff ff       	call   80105169 <memmove>
80109e7f:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e85:	8d 50 0c             	lea    0xc(%eax),%edx
80109e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e8b:	83 c0 10             	add    $0x10,%eax
80109e8e:	83 ec 04             	sub    $0x4,%esp
80109e91:	6a 04                	push   $0x4
80109e93:	52                   	push   %edx
80109e94:	50                   	push   %eax
80109e95:	e8 cf b2 ff ff       	call   80105169 <memmove>
80109e9a:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109e9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109ea6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ea9:	83 ec 0c             	sub    $0xc,%esp
80109eac:	50                   	push   %eax
80109ead:	e8 6d fd ff ff       	call   80109c1f <ipv4_chksum>
80109eb2:	83 c4 10             	add    $0x10,%esp
80109eb5:	0f b7 c0             	movzwl %ax,%eax
80109eb8:	83 ec 0c             	sub    $0xc,%esp
80109ebb:	50                   	push   %eax
80109ebc:	e8 69 fc ff ff       	call   80109b2a <H2N_ushort>
80109ec1:	83 c4 10             	add    $0x10,%esp
80109ec4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ec7:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ece:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109ed1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ed4:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109edb:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109edf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ee2:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109ee6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ee9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109eed:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ef0:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109ef4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ef7:	8d 50 08             	lea    0x8(%eax),%edx
80109efa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109efd:	83 c0 08             	add    $0x8,%eax
80109f00:	83 ec 04             	sub    $0x4,%esp
80109f03:	6a 08                	push   $0x8
80109f05:	52                   	push   %edx
80109f06:	50                   	push   %eax
80109f07:	e8 5d b2 ff ff       	call   80105169 <memmove>
80109f0c:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109f0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f12:	8d 50 10             	lea    0x10(%eax),%edx
80109f15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f18:	83 c0 10             	add    $0x10,%eax
80109f1b:	83 ec 04             	sub    $0x4,%esp
80109f1e:	6a 30                	push   $0x30
80109f20:	52                   	push   %edx
80109f21:	50                   	push   %eax
80109f22:	e8 42 b2 ff ff       	call   80105169 <memmove>
80109f27:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109f2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f2d:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109f33:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f36:	83 ec 0c             	sub    $0xc,%esp
80109f39:	50                   	push   %eax
80109f3a:	e8 1c 00 00 00       	call   80109f5b <icmp_chksum>
80109f3f:	83 c4 10             	add    $0x10,%esp
80109f42:	0f b7 c0             	movzwl %ax,%eax
80109f45:	83 ec 0c             	sub    $0xc,%esp
80109f48:	50                   	push   %eax
80109f49:	e8 dc fb ff ff       	call   80109b2a <H2N_ushort>
80109f4e:	83 c4 10             	add    $0x10,%esp
80109f51:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f54:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109f58:	90                   	nop
80109f59:	c9                   	leave
80109f5a:	c3                   	ret

80109f5b <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109f5b:	55                   	push   %ebp
80109f5c:	89 e5                	mov    %esp,%ebp
80109f5e:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109f61:	8b 45 08             	mov    0x8(%ebp),%eax
80109f64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109f67:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109f6e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109f75:	eb 48                	jmp    80109fbf <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109f77:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f7a:	01 c0                	add    %eax,%eax
80109f7c:	89 c2                	mov    %eax,%edx
80109f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f81:	01 d0                	add    %edx,%eax
80109f83:	0f b6 00             	movzbl (%eax),%eax
80109f86:	0f b6 c0             	movzbl %al,%eax
80109f89:	c1 e0 08             	shl    $0x8,%eax
80109f8c:	89 c2                	mov    %eax,%edx
80109f8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f91:	01 c0                	add    %eax,%eax
80109f93:	8d 48 01             	lea    0x1(%eax),%ecx
80109f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f99:	01 c8                	add    %ecx,%eax
80109f9b:	0f b6 00             	movzbl (%eax),%eax
80109f9e:	0f b6 c0             	movzbl %al,%eax
80109fa1:	01 d0                	add    %edx,%eax
80109fa3:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109fa6:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109fad:	76 0c                	jbe    80109fbb <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109faf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109fb2:	0f b7 c0             	movzwl %ax,%eax
80109fb5:	83 c0 01             	add    $0x1,%eax
80109fb8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109fbb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109fbf:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109fc3:	7e b2                	jle    80109f77 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109fc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109fc8:	f7 d0                	not    %eax
}
80109fca:	c9                   	leave
80109fcb:	c3                   	ret

80109fcc <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109fcc:	55                   	push   %ebp
80109fcd:	89 e5                	mov    %esp,%ebp
80109fcf:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd5:	83 c0 0e             	add    $0xe,%eax
80109fd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fde:	0f b6 00             	movzbl (%eax),%eax
80109fe1:	0f b6 c0             	movzbl %al,%eax
80109fe4:	83 e0 0f             	and    $0xf,%eax
80109fe7:	c1 e0 02             	shl    $0x2,%eax
80109fea:	89 c2                	mov    %eax,%edx
80109fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fef:	01 d0                	add    %edx,%eax
80109ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ff7:	83 c0 14             	add    $0x14,%eax
80109ffa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109ffd:	e8 88 8c ff ff       	call   80102c8a <kalloc>
8010a002:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a005:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a00c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a00f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a013:	0f b6 c0             	movzbl %al,%eax
8010a016:	83 e0 02             	and    $0x2,%eax
8010a019:	85 c0                	test   %eax,%eax
8010a01b:	74 3d                	je     8010a05a <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a01d:	83 ec 0c             	sub    $0xc,%esp
8010a020:	6a 00                	push   $0x0
8010a022:	6a 12                	push   $0x12
8010a024:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a027:	50                   	push   %eax
8010a028:	ff 75 e8             	push   -0x18(%ebp)
8010a02b:	ff 75 08             	push   0x8(%ebp)
8010a02e:	e8 a2 01 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a033:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a036:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a039:	83 ec 08             	sub    $0x8,%esp
8010a03c:	50                   	push   %eax
8010a03d:	ff 75 e8             	push   -0x18(%ebp)
8010a040:	e8 79 f1 ff ff       	call   801091be <i8254_send>
8010a045:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a048:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
8010a04d:	83 c0 01             	add    $0x1,%eax
8010a050:	a3 a4 a0 11 80       	mov    %eax,0x8011a0a4
8010a055:	e9 69 01 00 00       	jmp    8010a1c3 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a05a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a05d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a061:	3c 18                	cmp    $0x18,%al
8010a063:	0f 85 10 01 00 00    	jne    8010a179 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
8010a069:	83 ec 04             	sub    $0x4,%esp
8010a06c:	6a 03                	push   $0x3
8010a06e:	68 de c5 10 80       	push   $0x8010c5de
8010a073:	ff 75 ec             	push   -0x14(%ebp)
8010a076:	e8 96 b0 ff ff       	call   80105111 <memcmp>
8010a07b:	83 c4 10             	add    $0x10,%esp
8010a07e:	85 c0                	test   %eax,%eax
8010a080:	74 74                	je     8010a0f6 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
8010a082:	83 ec 0c             	sub    $0xc,%esp
8010a085:	68 e2 c5 10 80       	push   $0x8010c5e2
8010a08a:	e8 65 63 ff ff       	call   801003f4 <cprintf>
8010a08f:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a092:	83 ec 0c             	sub    $0xc,%esp
8010a095:	6a 00                	push   $0x0
8010a097:	6a 10                	push   $0x10
8010a099:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a09c:	50                   	push   %eax
8010a09d:	ff 75 e8             	push   -0x18(%ebp)
8010a0a0:	ff 75 08             	push   0x8(%ebp)
8010a0a3:	e8 2d 01 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a0a8:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a0ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0ae:	83 ec 08             	sub    $0x8,%esp
8010a0b1:	50                   	push   %eax
8010a0b2:	ff 75 e8             	push   -0x18(%ebp)
8010a0b5:	e8 04 f1 ff ff       	call   801091be <i8254_send>
8010a0ba:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a0bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0c0:	83 c0 36             	add    $0x36,%eax
8010a0c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a0c6:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a0c9:	50                   	push   %eax
8010a0ca:	ff 75 e0             	push   -0x20(%ebp)
8010a0cd:	6a 00                	push   $0x0
8010a0cf:	6a 00                	push   $0x0
8010a0d1:	e8 5a 04 00 00       	call   8010a530 <http_proc>
8010a0d6:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a0d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a0dc:	83 ec 0c             	sub    $0xc,%esp
8010a0df:	50                   	push   %eax
8010a0e0:	6a 18                	push   $0x18
8010a0e2:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0e5:	50                   	push   %eax
8010a0e6:	ff 75 e8             	push   -0x18(%ebp)
8010a0e9:	ff 75 08             	push   0x8(%ebp)
8010a0ec:	e8 e4 00 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a0f1:	83 c4 20             	add    $0x20,%esp
8010a0f4:	eb 62                	jmp    8010a158 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a0f6:	83 ec 0c             	sub    $0xc,%esp
8010a0f9:	6a 00                	push   $0x0
8010a0fb:	6a 10                	push   $0x10
8010a0fd:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a100:	50                   	push   %eax
8010a101:	ff 75 e8             	push   -0x18(%ebp)
8010a104:	ff 75 08             	push   0x8(%ebp)
8010a107:	e8 c9 00 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a10c:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a10f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a112:	83 ec 08             	sub    $0x8,%esp
8010a115:	50                   	push   %eax
8010a116:	ff 75 e8             	push   -0x18(%ebp)
8010a119:	e8 a0 f0 ff ff       	call   801091be <i8254_send>
8010a11e:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a121:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a124:	83 c0 36             	add    $0x36,%eax
8010a127:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a12a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a12d:	50                   	push   %eax
8010a12e:	ff 75 e4             	push   -0x1c(%ebp)
8010a131:	6a 00                	push   $0x0
8010a133:	6a 00                	push   $0x0
8010a135:	e8 f6 03 00 00       	call   8010a530 <http_proc>
8010a13a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a13d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a140:	83 ec 0c             	sub    $0xc,%esp
8010a143:	50                   	push   %eax
8010a144:	6a 18                	push   $0x18
8010a146:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a149:	50                   	push   %eax
8010a14a:	ff 75 e8             	push   -0x18(%ebp)
8010a14d:	ff 75 08             	push   0x8(%ebp)
8010a150:	e8 80 00 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a155:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a158:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a15b:	83 ec 08             	sub    $0x8,%esp
8010a15e:	50                   	push   %eax
8010a15f:	ff 75 e8             	push   -0x18(%ebp)
8010a162:	e8 57 f0 ff ff       	call   801091be <i8254_send>
8010a167:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a16a:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
8010a16f:	83 c0 01             	add    $0x1,%eax
8010a172:	a3 a4 a0 11 80       	mov    %eax,0x8011a0a4
8010a177:	eb 4a                	jmp    8010a1c3 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a179:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a17c:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a180:	3c 10                	cmp    $0x10,%al
8010a182:	75 3f                	jne    8010a1c3 <tcp_proc+0x1f7>
    if(fin_flag == 1){
8010a184:	a1 a8 a0 11 80       	mov    0x8011a0a8,%eax
8010a189:	83 f8 01             	cmp    $0x1,%eax
8010a18c:	75 35                	jne    8010a1c3 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a18e:	83 ec 0c             	sub    $0xc,%esp
8010a191:	6a 00                	push   $0x0
8010a193:	6a 01                	push   $0x1
8010a195:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a198:	50                   	push   %eax
8010a199:	ff 75 e8             	push   -0x18(%ebp)
8010a19c:	ff 75 08             	push   0x8(%ebp)
8010a19f:	e8 31 00 00 00       	call   8010a1d5 <tcp_pkt_create>
8010a1a4:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a1a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1aa:	83 ec 08             	sub    $0x8,%esp
8010a1ad:	50                   	push   %eax
8010a1ae:	ff 75 e8             	push   -0x18(%ebp)
8010a1b1:	e8 08 f0 ff ff       	call   801091be <i8254_send>
8010a1b6:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a1b9:	c7 05 a8 a0 11 80 00 	movl   $0x0,0x8011a0a8
8010a1c0:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a1c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1c6:	83 ec 0c             	sub    $0xc,%esp
8010a1c9:	50                   	push   %eax
8010a1ca:	e8 21 8a ff ff       	call   80102bf0 <kfree>
8010a1cf:	83 c4 10             	add    $0x10,%esp
}
8010a1d2:	90                   	nop
8010a1d3:	c9                   	leave
8010a1d4:	c3                   	ret

8010a1d5 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a1d5:	55                   	push   %ebp
8010a1d6:	89 e5                	mov    %esp,%ebp
8010a1d8:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a1db:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a1e1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1e4:	83 c0 0e             	add    $0xe,%eax
8010a1e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a1ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1ed:	0f b6 00             	movzbl (%eax),%eax
8010a1f0:	0f b6 c0             	movzbl %al,%eax
8010a1f3:	83 e0 0f             	and    $0xf,%eax
8010a1f6:	c1 e0 02             	shl    $0x2,%eax
8010a1f9:	89 c2                	mov    %eax,%edx
8010a1fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1fe:	01 d0                	add    %edx,%eax
8010a200:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a203:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a206:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a209:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a20c:	83 c0 0e             	add    $0xe,%eax
8010a20f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a212:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a215:	83 c0 14             	add    $0x14,%eax
8010a218:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a21b:	8b 45 18             	mov    0x18(%ebp),%eax
8010a21e:	8d 50 36             	lea    0x36(%eax),%edx
8010a221:	8b 45 10             	mov    0x10(%ebp),%eax
8010a224:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a226:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a229:	8d 50 06             	lea    0x6(%eax),%edx
8010a22c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a22f:	83 ec 04             	sub    $0x4,%esp
8010a232:	6a 06                	push   $0x6
8010a234:	52                   	push   %edx
8010a235:	50                   	push   %eax
8010a236:	e8 2e af ff ff       	call   80105169 <memmove>
8010a23b:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a23e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a241:	83 c0 06             	add    $0x6,%eax
8010a244:	83 ec 04             	sub    $0x4,%esp
8010a247:	6a 06                	push   $0x6
8010a249:	68 c0 9d 11 80       	push   $0x80119dc0
8010a24e:	50                   	push   %eax
8010a24f:	e8 15 af ff ff       	call   80105169 <memmove>
8010a254:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a257:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a25a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a25e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a261:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a268:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a26b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a26e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a272:	8b 45 18             	mov    0x18(%ebp),%eax
8010a275:	83 c0 28             	add    $0x28,%eax
8010a278:	0f b7 c0             	movzwl %ax,%eax
8010a27b:	83 ec 0c             	sub    $0xc,%esp
8010a27e:	50                   	push   %eax
8010a27f:	e8 a6 f8 ff ff       	call   80109b2a <H2N_ushort>
8010a284:	83 c4 10             	add    $0x10,%esp
8010a287:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a28a:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a28e:	0f b7 15 a0 a0 11 80 	movzwl 0x8011a0a0,%edx
8010a295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a298:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a29c:	0f b7 05 a0 a0 11 80 	movzwl 0x8011a0a0,%eax
8010a2a3:	83 c0 01             	add    $0x1,%eax
8010a2a6:	66 a3 a0 a0 11 80    	mov    %ax,0x8011a0a0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a2ac:	83 ec 0c             	sub    $0xc,%esp
8010a2af:	6a 00                	push   $0x0
8010a2b1:	e8 74 f8 ff ff       	call   80109b2a <H2N_ushort>
8010a2b6:	83 c4 10             	add    $0x10,%esp
8010a2b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2bc:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a2c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2c3:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a2c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ca:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a2ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2d1:	83 c0 0c             	add    $0xc,%eax
8010a2d4:	83 ec 04             	sub    $0x4,%esp
8010a2d7:	6a 04                	push   $0x4
8010a2d9:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a2de:	50                   	push   %eax
8010a2df:	e8 85 ae ff ff       	call   80105169 <memmove>
8010a2e4:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a2e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2ea:	8d 50 0c             	lea    0xc(%eax),%edx
8010a2ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2f0:	83 c0 10             	add    $0x10,%eax
8010a2f3:	83 ec 04             	sub    $0x4,%esp
8010a2f6:	6a 04                	push   $0x4
8010a2f8:	52                   	push   %edx
8010a2f9:	50                   	push   %eax
8010a2fa:	e8 6a ae ff ff       	call   80105169 <memmove>
8010a2ff:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a305:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a30b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a30e:	83 ec 0c             	sub    $0xc,%esp
8010a311:	50                   	push   %eax
8010a312:	e8 08 f9 ff ff       	call   80109c1f <ipv4_chksum>
8010a317:	83 c4 10             	add    $0x10,%esp
8010a31a:	0f b7 c0             	movzwl %ax,%eax
8010a31d:	83 ec 0c             	sub    $0xc,%esp
8010a320:	50                   	push   %eax
8010a321:	e8 04 f8 ff ff       	call   80109b2a <H2N_ushort>
8010a326:	83 c4 10             	add    $0x10,%esp
8010a329:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a32c:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a330:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a333:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a337:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a33a:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a33d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a340:	0f b7 10             	movzwl (%eax),%edx
8010a343:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a346:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a34a:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
8010a34f:	83 ec 0c             	sub    $0xc,%esp
8010a352:	50                   	push   %eax
8010a353:	e8 e9 f7 ff ff       	call   80109b41 <H2N_uint>
8010a358:	83 c4 10             	add    $0x10,%esp
8010a35b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a35e:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a361:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a364:	8b 40 04             	mov    0x4(%eax),%eax
8010a367:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a36d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a370:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a373:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a376:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a37a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a37d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a381:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a384:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a388:	8b 45 14             	mov    0x14(%ebp),%eax
8010a38b:	89 c2                	mov    %eax,%edx
8010a38d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a390:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a393:	83 ec 0c             	sub    $0xc,%esp
8010a396:	68 90 38 00 00       	push   $0x3890
8010a39b:	e8 8a f7 ff ff       	call   80109b2a <H2N_ushort>
8010a3a0:	83 c4 10             	add    $0x10,%esp
8010a3a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3a6:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a3aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3ad:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a3b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b6:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a3bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3bf:	83 ec 0c             	sub    $0xc,%esp
8010a3c2:	50                   	push   %eax
8010a3c3:	e8 1f 00 00 00       	call   8010a3e7 <tcp_chksum>
8010a3c8:	83 c4 10             	add    $0x10,%esp
8010a3cb:	83 c0 08             	add    $0x8,%eax
8010a3ce:	0f b7 c0             	movzwl %ax,%eax
8010a3d1:	83 ec 0c             	sub    $0xc,%esp
8010a3d4:	50                   	push   %eax
8010a3d5:	e8 50 f7 ff ff       	call   80109b2a <H2N_ushort>
8010a3da:	83 c4 10             	add    $0x10,%esp
8010a3dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3e0:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a3e4:	90                   	nop
8010a3e5:	c9                   	leave
8010a3e6:	c3                   	ret

8010a3e7 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a3e7:	55                   	push   %ebp
8010a3e8:	89 e5                	mov    %esp,%ebp
8010a3ea:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a3ed:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a3f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3f6:	83 c0 14             	add    $0x14,%eax
8010a3f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a3fc:	83 ec 04             	sub    $0x4,%esp
8010a3ff:	6a 04                	push   $0x4
8010a401:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a406:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a409:	50                   	push   %eax
8010a40a:	e8 5a ad ff ff       	call   80105169 <memmove>
8010a40f:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a412:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a415:	83 c0 0c             	add    $0xc,%eax
8010a418:	83 ec 04             	sub    $0x4,%esp
8010a41b:	6a 04                	push   $0x4
8010a41d:	50                   	push   %eax
8010a41e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a421:	83 c0 04             	add    $0x4,%eax
8010a424:	50                   	push   %eax
8010a425:	e8 3f ad ff ff       	call   80105169 <memmove>
8010a42a:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a42d:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a431:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a435:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a438:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a43c:	0f b7 c0             	movzwl %ax,%eax
8010a43f:	83 ec 0c             	sub    $0xc,%esp
8010a442:	50                   	push   %eax
8010a443:	e8 cb f6 ff ff       	call   80109b13 <N2H_ushort>
8010a448:	83 c4 10             	add    $0x10,%esp
8010a44b:	83 e8 14             	sub    $0x14,%eax
8010a44e:	0f b7 c0             	movzwl %ax,%eax
8010a451:	83 ec 0c             	sub    $0xc,%esp
8010a454:	50                   	push   %eax
8010a455:	e8 d0 f6 ff ff       	call   80109b2a <H2N_ushort>
8010a45a:	83 c4 10             	add    $0x10,%esp
8010a45d:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a461:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a468:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a46b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a46e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a475:	eb 33                	jmp    8010a4aa <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a47a:	01 c0                	add    %eax,%eax
8010a47c:	89 c2                	mov    %eax,%edx
8010a47e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a481:	01 d0                	add    %edx,%eax
8010a483:	0f b6 00             	movzbl (%eax),%eax
8010a486:	0f b6 c0             	movzbl %al,%eax
8010a489:	c1 e0 08             	shl    $0x8,%eax
8010a48c:	89 c2                	mov    %eax,%edx
8010a48e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a491:	01 c0                	add    %eax,%eax
8010a493:	8d 48 01             	lea    0x1(%eax),%ecx
8010a496:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a499:	01 c8                	add    %ecx,%eax
8010a49b:	0f b6 00             	movzbl (%eax),%eax
8010a49e:	0f b6 c0             	movzbl %al,%eax
8010a4a1:	01 d0                	add    %edx,%eax
8010a4a3:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a4a6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a4aa:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a4ae:	7e c7                	jle    8010a477 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a4b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a4b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a4bd:	eb 33                	jmp    8010a4f2 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a4bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4c2:	01 c0                	add    %eax,%eax
8010a4c4:	89 c2                	mov    %eax,%edx
8010a4c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4c9:	01 d0                	add    %edx,%eax
8010a4cb:	0f b6 00             	movzbl (%eax),%eax
8010a4ce:	0f b6 c0             	movzbl %al,%eax
8010a4d1:	c1 e0 08             	shl    $0x8,%eax
8010a4d4:	89 c2                	mov    %eax,%edx
8010a4d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4d9:	01 c0                	add    %eax,%eax
8010a4db:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4de:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4e1:	01 c8                	add    %ecx,%eax
8010a4e3:	0f b6 00             	movzbl (%eax),%eax
8010a4e6:	0f b6 c0             	movzbl %al,%eax
8010a4e9:	01 d0                	add    %edx,%eax
8010a4eb:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a4ee:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a4f2:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a4f6:	0f b7 c0             	movzwl %ax,%eax
8010a4f9:	83 ec 0c             	sub    $0xc,%esp
8010a4fc:	50                   	push   %eax
8010a4fd:	e8 11 f6 ff ff       	call   80109b13 <N2H_ushort>
8010a502:	83 c4 10             	add    $0x10,%esp
8010a505:	66 d1 e8             	shr    $1,%ax
8010a508:	0f b7 c0             	movzwl %ax,%eax
8010a50b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a50e:	7c af                	jl     8010a4bf <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a510:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a513:	c1 e8 10             	shr    $0x10,%eax
8010a516:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a51c:	f7 d0                	not    %eax
}
8010a51e:	c9                   	leave
8010a51f:	c3                   	ret

8010a520 <tcp_fin>:

void tcp_fin(){
8010a520:	55                   	push   %ebp
8010a521:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a523:	c7 05 a8 a0 11 80 01 	movl   $0x1,0x8011a0a8
8010a52a:	00 00 00 
}
8010a52d:	90                   	nop
8010a52e:	5d                   	pop    %ebp
8010a52f:	c3                   	ret

8010a530 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a530:	55                   	push   %ebp
8010a531:	89 e5                	mov    %esp,%ebp
8010a533:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a536:	8b 45 10             	mov    0x10(%ebp),%eax
8010a539:	83 ec 04             	sub    $0x4,%esp
8010a53c:	6a 00                	push   $0x0
8010a53e:	68 eb c5 10 80       	push   $0x8010c5eb
8010a543:	50                   	push   %eax
8010a544:	e8 65 00 00 00       	call   8010a5ae <http_strcpy>
8010a549:	83 c4 10             	add    $0x10,%esp
8010a54c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a54f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a552:	83 ec 04             	sub    $0x4,%esp
8010a555:	ff 75 f4             	push   -0xc(%ebp)
8010a558:	68 fe c5 10 80       	push   $0x8010c5fe
8010a55d:	50                   	push   %eax
8010a55e:	e8 4b 00 00 00       	call   8010a5ae <http_strcpy>
8010a563:	83 c4 10             	add    $0x10,%esp
8010a566:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a569:	8b 45 10             	mov    0x10(%ebp),%eax
8010a56c:	83 ec 04             	sub    $0x4,%esp
8010a56f:	ff 75 f4             	push   -0xc(%ebp)
8010a572:	68 19 c6 10 80       	push   $0x8010c619
8010a577:	50                   	push   %eax
8010a578:	e8 31 00 00 00       	call   8010a5ae <http_strcpy>
8010a57d:	83 c4 10             	add    $0x10,%esp
8010a580:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a583:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a586:	83 e0 01             	and    $0x1,%eax
8010a589:	85 c0                	test   %eax,%eax
8010a58b:	74 11                	je     8010a59e <http_proc+0x6e>
    char *payload = (char *)send;
8010a58d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a590:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a593:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a596:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a599:	01 d0                	add    %edx,%eax
8010a59b:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a59e:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a5a1:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5a4:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a5a6:	e8 75 ff ff ff       	call   8010a520 <tcp_fin>
}
8010a5ab:	90                   	nop
8010a5ac:	c9                   	leave
8010a5ad:	c3                   	ret

8010a5ae <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a5ae:	55                   	push   %ebp
8010a5af:	89 e5                	mov    %esp,%ebp
8010a5b1:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a5b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a5bb:	eb 20                	jmp    8010a5dd <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a5bd:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5c0:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5c3:	01 d0                	add    %edx,%eax
8010a5c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a5c8:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5cb:	01 ca                	add    %ecx,%edx
8010a5cd:	89 d1                	mov    %edx,%ecx
8010a5cf:	8b 55 08             	mov    0x8(%ebp),%edx
8010a5d2:	01 ca                	add    %ecx,%edx
8010a5d4:	0f b6 00             	movzbl (%eax),%eax
8010a5d7:	88 02                	mov    %al,(%edx)
    i++;
8010a5d9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a5dd:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5e0:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5e3:	01 d0                	add    %edx,%eax
8010a5e5:	0f b6 00             	movzbl (%eax),%eax
8010a5e8:	84 c0                	test   %al,%al
8010a5ea:	75 d1                	jne    8010a5bd <http_strcpy+0xf>
  }
  return i;
8010a5ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a5ef:	c9                   	leave
8010a5f0:	c3                   	ret
