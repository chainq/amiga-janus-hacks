{*
 * janus.library Amiga side support unit for Free Pascal
 *
 * Original C files, as published on the JANUS_2_1-DEVEL disk:
 * Copyright (c) 1986, 1987, 1988, Commodore Amiga Inc., All rights reserved.
 *
 * Free Pascal Conversion:
 * Copyright (c) 2018-2022, Karoly Balogh <charlie@amigaspirit.hu>
 * See LICENSE file for details on the licensing of this file.
 *}

{$mode fpc}
{$packrecords 2}
unit janus;

interface

uses
  exec;

{************************************************************************
 * (Amiga side file)
 *
 * janusreg.h -- janus hardware registers (from amiga point of view)
 *
 * Copyright (c) 1986, Commodore Amiga Inc., All rights reserved.
 *
 * 7-15-88 - Bill Koester - Modified for self inclusion of required files
 *10-23-89 - Bill Koester - Added DISKTO[PC|AMIGA] bits for floppy switch
 ************************************************************************}

{* hardware interrupt bits (all bits are active low)                    *}
const
    JINTB_MINT    = (0);     {* mono video ram written to              *}
    JINTB_GINT    = (1);     {* color video ram written to             *}
    JINTB_CRT1INT = (2);     {* mono video control registers changed   *}
    JINTB_CRT2INT = (3);     {* color video control registers changed  *}
    JINTB_ENBKB   = (4);     {* keyboard ready for next character      *}
    JINTB_LPT1INT = (5);     {* parallel control register              *}
    JINTB_COM2INT = (6);     {* serial control register                *}
    JINTB_SYSINT  = (7);     {* software int request                   *}

    JINTF_MINT    = (1 shl 0);
    JINTF_GINT    = (1 shl 1);
    JINTF_CRT1INT = (1 shl 2);
    JINTF_CRT2INT = (1 shl 3);
    JINTF_ENBKB   = (1 shl 4);
    JINTF_LPT1INT = (1 shl 5);
    JINTF_COM2INT = (1 shl 6);
    JINTF_SYSINT  = (1 shl 7);


{* These are the defs for the io registers.  All the registers are byte *}
{* wide and the address are for Byte Access addresses                   *}
const
    jio_1000KeyboardData = $061f; {* data that keybd will read in a1000 *}
    jio_2000KeyboardData = $1fff; {* data that keybd will read in a2000 *}

    jio_SystemStatus     = $003f; {* pc only register                   *}
    jio_NmiEnable        = $005f; {* pc only register                   *}

    jio_Com2XmitData     = $007d;
    jio_Com2ReceiveData  = $009d;
    jio_Com2IntEnableW   = $00bd;
    jio_Com2IntEnableR   = $00dd;
    jio_Com2DivisorLSB   = $007f;
    jio_Com2DivisorMSB   = $009f;
    jio_Com2IntID        = $00ff;
    jio_Com2LineCntrl    = $011f;
    jio_Com2ModemCntrl   = $013f;
    jio_Com2LineStatus   = $015f;
    jio_Com2ModemStatus  = $017f;

    jio_Lpt1Data         = $019f; {* data byte                          *}
    jio_Lpt1Status       = $01bf; {* see equates below                  *}
    jio_Lpt1Control      = $01df; {* see equates below                  *}

    jio_MonoAddressInd   = $01ff; {* current index into crt data regs   *}
    jio_MonoData         = $02a1; {* every other byte for 16 registers  *}
    jio_MonoControlReg   = $02ff;

    jio_ColorAddressInd  = $021f; {* current index into crt data regs   *}
    jio_ColorData        = $02c1; {* every other byte for 16 registers  *}
    jio_ColorControlReg  = $023f;
    jio_ColorSelectReg   = $025f;
    jio_ColorStatusReg   = $027f;

    jio_DisplaySystemReg = $029f;

    jio_IntReq           = $1ff1; {* read clears, pc -> amiga ints      *}
    jio_PcIntReq         = $1ff3; {* r/o, amiga -> pc ints              *}
    jio_ReleasePcReset   = $1ff5; {* r/o, strobe release pc's reset     *}
    jio_PCconfiguration  = $1ff7; {* r/w, give/set PC config.           *}
    jio_IntEna           = $1ff9; {* r/w, enables pc int lines          *}
    jio_PcIntGen         = $1ffb; {* w/o, bit == 0 -> cause pc int      *}
    jio_Control          = $1ffd; {* w/o, random control lines          *}

{* now the magic bits in each register (and boy, are there a lot of them!) *}

{* bits for Lpt1Status register                                            *}
const
    JPCLSB_STROBE    = (0);
    JPCLSB_AUTOFEED  = (1);
    JPCLSB_INIT      = (2);
    JPCLSB_SELECTIN  = (3);
    JPCLSB_IRQENABLE = (4);     {* active 1                               *}

    JPCLSF_STROBE    = (1 shl 0);
    JPCLSF_AUTOFEED  = (1 shl 1);
    JPCLSF_INIT      = (1 shl 2);
    JPCLSF_SELECTIN  = (1 shl 3);
    JPCLSF_IRQENABLE = (1 shl 4);

{* bits for Lpt1Control register                                           *}
const
    JPCLCB_ERROR   = (3);
    JPCLCB_SELECT  = (4);
    JPCLCB_NOPAPER = (5);
    JPCLCB_ACK     = (6);
    JPCLCB_BUSY    = (7);

    JPCLCF_ERROR   = (1 shl 3);
    JPCLCF_SELECT  = (1 shl 4);
    JPCLCF_NOPAPER = (1 shl 5);
    JPCLCF_ACK     = (1 shl 6);
    JPCLCF_BUSY    = (1 shl 7);

{* bits for PcIntReq, PcIntGen registers                                   *}
const
    JPCINTB_IRQ1 = (0);         {* active high                            *}
    JPCINTB_IRQ3 = (1);         {* active low                             *}
    JPCINTB_IRQ4 = (2);         {* active low                             *}
    JPCINTB_IRQ7 = (3);         {* active low                             *}

    JPCINTF_IRQ1 = (1 shl 0);
    JPCINTF_IRQ3 = (1 shl 1);
    JPCINTF_IRQ4 = (1 shl 2);
    JPCINTF_IRQ7 = (1 shl 3);

{* pc side interrupts                                                      *}
const
    JPCKEYINT   = ($ff);       {* keycode available                      *}
    JPCSENDINT  = ($fc);       {* system request                         *}
    JPCLPT1INT  = ($f6);       {* printer acknowledge                    *}


{* bits for RamSize                                                        *}
const
    JRAMB_EXISTS = (0);         {* unset if there is any ram at all       *}
    JRAMB_2MEG   = (1);         {* set if 2 meg, clear if 1/2 meg         *}

    JRAMF_EXISTS = (1 shl 0);      {* unset if there is any ram at all       *}
    JRAMF_2MEG   = (1 shl 1);      {* set if 2 meg, clear if 1/2 meg         *}

{* bits for control register                                               *}
const
    JCNTRLB_ENABLEINT   = (0);   {* enable amiga interrupts               *}
    JCNTRLB_DISABLEINT  = (1);   {* disable amiga interrupts              *}
    JCNTRLB_RESETPC     = (2);   {* reset the pc. remember to strobe      *}
                                 {* ReleasePcReset afterwards             *}
    JCNTRLB_CLRPCINT    = (3);   {* turn off all amiga->pc ints (except   *}
                                 {* keyboard                              *}
    JCNTRLB_CLRBUSY     = (4);   {* interfaces parallel busy bit          *}
    JCNTRLB_DISKTOAMIGA = (5);   {* Floppy switch bits                    *}
    JCNTRLB_DISKTOPC    = (6);
    JCNTRLF_ENABLEINT   = (1 shl 0);{* enable amiga interrupts               *}
    JCNTRLF_DISABLEINT  = (1 shl 1);{* disable amiga interrupts              *}
    JCNTRLF_RESETPC     = (1 shl 2);{* reset the pc. remember to strobe      *}
                                    {* ReleasePcReset afterwards             *}
    JCNTRLF_CLRPCINT    = (1 shl 3);{* turn off all amiga->pc ints (except   *}
                                    {* keyboard                              *}
    JCNTRLF_CLRBUSY     = (1 shl 4);{* interfaces parallel busy bit          *}
    JCNTRLF_DISKTOAMIGA = (1 shl 5);{* Switch disk to Amiga for floppy switch*}
                                    {* Active low                            *}
    JCNTRLF_DISKTOPC    = (1 shl 6);{* Switch disk to PC for floppy switch   *}
                                    {* Active low                            *}


{************************************************************************
 * (Amiga side file)
 *
 * Memory.h -- Structures and defines for Janus emeory
 *
 * Copyright (c) 1986, Commodore Amiga Inc.,  All rights reserved.
 *
 * 7-15-88 - Bill Koester - Modified for self inclusion of required files
 ************************************************************************}

type
    PRPTR = ^RPTR;
    RPTR = Word;

{* magic constants for memory allocation                                *}
const
    MEM_TYPEMASK      = $00ff;  {* 8 memory areas                       *}
    MEMB_PARAMETER    = (0);    {* parameter memory                     *}
    MEMB_BUFFER       = (1);    {* buffer memory                        *}

    MEMF_PARAMETER    = (1 shl 0); {* parameter memory                     *}
    MEMF_BUFFER       = (1 shl 1); {* buffer memory                        *}

    MEM_ACCESSMASK    = $3000; {* bits that participate in access types*}
    MEM_BYTEACCESS    = $0000; {* pointer to byte access address space *}
    MEM_WORDACCESS    = $1000; {* pointer to word access address space *}
    MEM_GRAPHICACCESS = $2000; {* ptr to graphic access address space  *}
    MEM_IOACCESS      = $3000; {* pointer to i/o access address space  *}

    TYPEACCESSTOADDR  = 5;     {* # of bits to turn access mask to addr*}

{*
 * The amiga side of the janus board has four sections of its address space.
 * Three of these parts are different arrangements of the same memory.  The
 * fourth part has the specific amiga accesible IO registers (jio_??).
 * The other three parts all contain the same data, but the data is arranged
 * in different ways: Byte Access lets the 68k read byte streams written
 * by the 8088, Word Access lets the 68k read word streams written by the
 * 8088, and Graphic Access lets the 68k read medium res graphics memory
 * in a more efficient manner (the pc uses packed two bit pixels ; graphic
 * access rearranges these data bits into two bytes, one for each bit plane).
 *}
const
    ByteAccessOffset    = $00000;
    WordAccessOffset    = $20000;
    GraphicAccessOffset = $40000;
    IoAccessOffset      = $60000;


{*
 * within each bank of memory are several sub regions.  These are the
 * definitions for the sub regions
 *}
const
    BufferOffset      = $00000;
    ColorOffset       = $10000;
    ParameterOffset   = $18000;
    MonoVideoOffset   = $1c000;
    IoRegOffset       = $1e000;

    BufferSize        = $10000;
    ParameterSize     = $04000;

{* constants for sizes of various janus regions                            *}
const
    JANUSTOTALSIZE = (512*1024); {* 1/2 megabyte                          *}
    JANUSBANKSIZE  = (128*1024); {* 128K per memory bank                  *}
    JANUSNUMBANKS  = (4);        {* four memory banks                     *}
    JANUSBANKMASK  = ($60000);   {* mask bits for bank region             *}


{*
 * all bytes described here are described in the byte order of the 8088.
 * Note that words and longwords in these structures will be accessed from
 * the word access space to preserve the byte order in a word -- the 8088
 * will access longwords by reversing the words : like a 68000 access to the
 * word access memory
 *
 * JanusMemHead -- a data structure roughly analogous to an exec mem chunk.
 * It is used to keep track of memory used between the 8088 and the 68000.
 *}

type
    PJanusMemHead = ^TJanusMemHead;
    TJanusMemHead = record
      jmh_Lock: byte;            {* lock byte between processors        *}
      jmh_pad0: byte;
      jmh_68000Base: Pointer;    {* rptr's are relative to this         *}
      jmh_8088Segment: Word;     {* segment base for 8088               *}
      jmh_First: RPTR;           {* offset to first free chunk          *}
      jmh_Max: RPTR;             {* max allowable index                 *}
      jmh_Free: Word;            {* total number of free bytes -1       *}
    end;


type
    PJanusMemChunk = ^TJanusMemChunk;
    TJanusMemChunk = record
      jmc_Next: RPTR;            {* rptr to next free chunk             *}
      jmc_Size: Word;            {* size of chunk                       *}
    end;

{*
 * === ===================================================================== 
 * === JanusRemember Structure ============================================= 
 * === ===================================================================== 
 * This is the structure used for the JRemember memory management routines 
 *}

type
    PJanusRemember = ^TJanusRemember;
    TJanusRemember = record
      jrm_NextRemember: RPTR; {* Pointer to the next JanusRemember struct *}
      jrm_Offset: RPTR;       {* Janus offset to this memory allocation   *}
      jrm_Size: Word;         {* Size of this memory allocation           *}
      jrm_Type: Word;         {* Type of this memory allocation           *}
    end;



{************************************************************************
 * (Amiga side file)
 *
 * memrw.h -- parameter area definition for access to other processors mem
 *
 * Copyright (c) 1986, Commodore Amiga Inc.,  All rights reserved
 *
 * 7-15-88 - Bill Koester - Modified for self inclusion of required files
 ************************************************************************}

{*
 * this is the parameter block for the JSERV_READPC and JSERV_READAMIGA
 * services -- read and/or write the other processors memory.
 *}
type
    TMemReadWrite = record
      mrw_Command: Word;    {* see below for list of commands         *}
      mrw_Count: Word;      {* number of bytes to transfer            *}
      mrw_Address: DWord;   {* local address to access.  This is      *}
                            {* a machine pointer for the 68000, and   *}
                            {* a segment/offset pair for the 808x.    *}
                            {* The address is arranged so the native  *}
                            {* processor may read it directly.        *}
      mrw_Buffer: Word;     {* The offset in buffer memory for the    *}
                            {* other buffer.                          *}
      mrw_Status: Word;     {* See below for status.                  *}
    end;


{* command definitions                                                  *}
const
    MRWC_NOP       = 0;     {* do nothing -- return OK status code    *}
    MRWC_READ      = 1;     {* xfer from address to buffer            *}
    MRWC_WRITE     = 2;     {* xfer from buffer to address            *}
    MRWC_READIO    = 3;     {* only on 808x -- read from IO space     *}
    MRWC_WRITEIO   = 4;     {* only on 808x -- write to IO space      *}
    MRWC_WRITEREAD = 5;     {* write from buffer, then read back      *}


{* status definitions                                                   *}
const
    MRWS_INPROGRESS = $ffff; {* we've noticed command and are working *}
    MRWS_OK         = $0000; {* completed OK                          *}
    MRWS_ACCESSERR  = $0001; {* some sort of protection violation     *}
    MRWS_BADCMD     = $0002; {* unknown command                       *}


{************************************************************************
 * (Amiga side file)
 *
 * janusvar.h -- the software data structures for the janus board
 *
 * Copyright (c) 1986, Commodore Amiga Inc.,  All rights reserved.
 *
 * Date       Name
 * --------   -------------   -------------------------------------------
 * 07-15-88 - Bill Koester  - Modified for self inclusion of required files
 * 07-26-88 - Bill Koester  - Added ja_Reserved to JanusAmiga
 *                            Added ja_AmigaState, ja_PCState and related
 *                            flags to JanusAmiga
 * 10-05-88 - Bill Koester  - Added Ver/Rev fields to JanusAmiga struc
 * 10-06-88 - Bill Koester  - Added HandlerLoaded field to JanusAMiga
 * 11-08-88 - Bill Koester  - Added AMIGA_PC_READY flags
 * 07-09-88 - Bill Koester  - Added variables for software locking
 ************************************************************************}

{*
 * all bytes described here are described in the byte order of the 8088.
 * Note that words and longwords in these structures will be accessed from
 * the word access space to preserve the byte order in a word -- the 8088
 * will access longwords by reversing the words : like a 68000 access to the
 * word access memory
 *}

type
  PJanusAmiga = ^TJanusAmiga;
  TJanusAmiga = record
    ja_Lock: byte;              {* also used to handshake at 8088 reset *}
    ja_8088Go: byte;            {* unlocked to signal 8088 to init      *}
    ja_ParamMem: TJanusMemHead;
    ja_BufferMem: TJanusMemHead;
    ja_Interrupts: RPTR;
    ja_Parameters: RPTR;
    ja_NumInterrupts: Word;

   {* This field is used by janus.library to communicate Amiga states
    * to the PC.  The bits of this field may be read by anyone, but
    * may be written only by janus.library.
    *}
   ja_AmigaState: Word;

   {* This field is used by the PC to communicate PC states
    * to the Amiga.  The bits of this field may be read by anyone, but
    * may be written only by the PC operating system.
    *}
   ja_PCState: Word;

   {* These fields are set by janus.library and the PC janus handler so
    * they can read each others version numbers.
    *}
   ja_JLibRev: Word;
   ja_JLibVer: Word;
   ja_JHandlerRev: Word;
   ja_JHandlerVer: Word;

   {* This field is zero before the PC is running and is set to nonzero
    * When the PC's JanusHandler has finished initializing.
    *}
   ja_HandlerLoaded: Word;

   ja_PCFlag: byte;
   ja_AmigaFlag: byte;
   ja_Turn: byte;
   ja_Pad: byte;

   ja_Reserved: array[0..3] of DWord;
 end;


{* === AmigaState Definitions === *}
const
  AMIGASTATE_RESERVED  = $FFF8;
  AMIGA_NUMLOCK_SET    = $0001;
  AMIGA_NUMLOCK_SETn   = 0;
  AMIGA_NUMLOCK_RESET  = $0002;
  AMIGA_NUMLOCK_RESETn = 1;
  AMIGA_PC_READY       = $0004;
  AMIGA_PC_READYn      = 2;

{* === PCState Definitions === *}
const
  PCSTATE_RESERVED    = $FFFF;

{*------ constant to set to indicate a pending software interrupt       *}
const
  JSETINT = $7f;


{*************************************************************************
 * (Amiga side file)
 *
 * HardDisk.h -- Structures for using the PC hard disk with JSERV_HARDISK
 *
 * Copyright (c) 1986, Commodore Amiga Inc.,  All rights reserved.
 *
 * 7-15-88 - Bill Koester - Modified for self inclusion of required files
 **************************************************************************}


{* disk request structure for raw amiga access to 8086's disk
   goes directly to PC BIOS (via PC int 13 scheduler) *}
type
    PHDskAbsReq = ^THDskAbsReq;
    THDskAbsReq = record
        har_FktCode: Word;   {* bios function code (see ibm tech ref)  *}
        har_Count: Word;     {* sector count                           *}
        har_Track: Word;     {* cylinder #                             *}
        har_Sector: Word;    {* sector #                               *}
        har_Drive: Word;     {* drive                                  *}
        har_Head: Word;      {* head                                   *}
        har_Offset: Word;    {* offset of buffer in MEMF_BUFFER memory *}
        har_Status: Word;    {* return status                          *}
    end;


{* definition of an AMIGA disk partition.  returned by info function *}
type
    PHDskPartition = ^THDskPartition;
    THDskPartition = record
        hdp_Next: Word;      {* 8088 ptr to next part.  0 -> end of list   *}
        hdp_BaseCyl: Word;   {* cyl # where partition starts               *}
        hdp_EndCyl: Word;    {* last cyclinder # of this partition         *}
        hdp_DrvNum: Word;    {* DOS drive number (80H, 81H, ...)           *}
        hdp_NumHeads: Word;  {* number of heads for this drive             *}
        hdp_NumSecs: Word;   {* number of sectors per track for this drive *}
    end;


{* disk request structure for higher level amiga disk request to 8086    *}
type
    PHDskReq = ^THDskReq;
    THDskReq = record
        hdr_Fnctn: Word;      {* function code (see below)                  *}
        hdr_Part: Word;       {* partition number (0 is first partition)    *}
        hdr_Offset: DWord;    {* byte offset into partition                 *}
        hdr_Count: DWord;     {* number of bytes to transfer                *}
        hdr_BufferAddr: Word; {* offset into MEMF_BUFFER memory for buffer  *}
        hdr_Err: Word;        {* return code, 0 if all OK                   *}
    end;


{* function codes for HardDskReq hdr_Fnctn word                         *}
const
    HDR_FNCTN_INIT  = 0;   {* given nothing, sets adr_Part to #partitions*}
    HDR_FNCTN_READ  = 1;   {* given partition, offset, count, buffer     *}
    HDR_FNCTN_WRITE = 2;   {* given partition, offset, count, buffer     *}
    HDR_FNCTN_SEEK  = 3;   {* given partition, offset                    *}
    HDR_FNCTN_INFO   =4;   {* given part, buff adr, cnt, copys in a      *}
                           {* DskPartition structure. cnt set to actual  *}
                           {* number of bytes copied.                    *}


{* error codes for hdr_Err, returned in low byte                         *}
const
    HDR_ERR_OK         = 0;  {* no error                                *}
    HDR_ERR_OFFSET     = 1;  {* offset not on sector boundary           *}
    HDR_ERR_COUNT      = 2;  {* dsk_count not a multiple of sector size *}
    HDR_ERR_PART       = 3;  {* partition does not exist                *}
    HDR_ERR_FNCT       = 4;  {* illegal function code                   *}
    HDR_ERR_EOF        = 5;  {* offset past end of partition            *}
    HDR_ERR_MULPL      = 6;  {* multiple calls while pending service    *}
    HDR_ERR_FILE_COUNT = 7;  {* too many open files                     *}

{* error condition from IBM-PC BIOS, returned in high byte               *}
const
    HDR_ERR_SENSE_FAIL      = $ff;
    HDR_ERR_UNDEF_ERR       = $bb;
    HDR_ERR_TIME_OUT        = $80;
    HDR_ERR_BAD_SEEK        = $40;
    HDR_ERR_BAD_CNTRLR      = $20;
    HDR_ERR_DATA_CORRECTED  = $11;  {* data corrected                 *}
    HDR_ERR_BAD_ECC         = $10;
    HDR_ERR_BAD_TRACK       = $0b;
    HDR_ERR_DMA_BOUNDARY    = $09;
    HDR_ERR_INIT_FAIL       = $07;
    HDR_ERR_BAD_RESET       = $05;
    HDR_ERR_RECRD_NOT_FOUND = $04;
    HDR_ERR_BAD_ADDR_MARK   = $02;
    HDR_ERR_BAD_CMD         = $01;



{************************************************************************
 * (Amiga side file)
 *
 * syscall.h -- interface definitions between amiga and commodore-pc
 *
 * Copyright (c) 1986, Commodore Amiga Inc., All rights reserved
 *
 * 7-15-88 - Bill Koester - Modified for self inclusion of required files
 ************************************************************************}


{*
 * All registers in this section are arranged to be read and written
 * from the WordAccessOffset area of the shared memory.   If you really
 * need to use the ByteAccessArea, all the words will need to be byte
 * swapped.
 *}


{* Syscall86 -- how the 8086/8088 wants its parameter block arranged    *}
type
    PSyscall86 = ^TSyscall86;
    TSyscall86 = record
        s86_AX: Word;
        s86_BX: Word;
        s86_CX: Word;
        s86_DX: Word;
        s86_SI: Word;
        s86_DS: Word;
        s86_DI: Word;
        s86_ES: Word;
        s86_BP: Word;
        s86_PSW: Word;
        s86_INT: Word;          {* 8086 int # that will be called         *}
    end;


{* Syscall68 -- the way the 68000 wants its parameters arranged         *}
type
    PSyscall68 = ^TSyscall68;
    TSyscall68 = record
        s68_D0: DWord;
        s68_D1: DWord;
        s68_D2: DWord;
        s68_D3: DWord;
        s68_D4: DWord;
        s68_D5: DWord;
        s68_D6: DWord;
        s68_D7: DWord;
        s68_A0: DWord;
        s68_A1: DWord;
        s68_A2: DWord;
        s68_A3: DWord;
        s68_A4: DWord;
        s68_A5: DWord;
        s68_A6: DWord;
        s68_PC: DWord;        {* pc to start execution from                 *}
        s68_ArgStack: DWord;  {* array to be pushed onto stack              *}
        s68_ArgLength: DWord; {* number of bytes to be pushed (must be even)*}
        s68_MinStack: DWord;  {* minimum necessary stack (0 = use default)  *}
        s68_CCR: DWord;       {* condition code register                    *}
        s68_Process: DWord;   {* ptr to process for this block.             *}
        s68_Command: Word;    {* special commands: see below                *}
        s68_Status: Word;
        s68_SigNum: Word;    {* internal use: signal to wake up process    *}
    end;


const
    S68COM_DOCALL  = 0; {* normal case -- jsr to specified Program cntr *}
    S68COM_REMPROC = 1; {* kill process                                 *}
    S68COM_CRPROC  = 2; {* create the proces, but do not call anything  *}



{************************************************************************
 * (Amiga side file)
 *
 * services.h -- Service Definitions and Data Structures
 *
 * Copyright (c) 1986, 1987, 1988, Commodore Amiga Inc., All rights reserved
 * 
 * HISTORY
 * Date       name                Description
 * --------   -----------------   ---------------------------------------------
 * early 86 - Burns/Katin clone - Created this file
 * 02-22-88 - RJ Mical          - Added service data structures
 * 07-15-88 - Bill Koester      - Mod for self inclusion of required files
 * 07-25-88 - Bill Koester      - Added ServiceCustomer structure
 * 07-26-88 - Bill Koester      - Added sd_PCUserCount to ServiceData
 *                                Changed sd_UserCount to sd_AmigaUserCount
 *                                Added sd_ReservedByte to ServiceData
 * 10-05-88 - Bill Koester      - Added SERVICE_PCWAIT flag definitions
 * 10-09-88 - Bill Koester      - Added PC/AMIGA_EXCLUSVIE & SERVICE_ADDED
 *                                flag definitions.
 *                              - Added sd_Semaphore field to ServiceData
 *                              - Self inclusion of exec/semaphores.h
 * 11-08-88 - Bill Koester      - Added AUTOWAIT flags
 ************************************************************************}

{*
 * As a coding convenience, we assume a maximum of 32 handlers.
 * People should avoid using this in their code, because we want
 * to be able to relax this constraint in the future.  All the
 * standard commands' syntactically support any number of interrupts,
 * but the internals are limited to 32.
 *}
const
    MAXHANDLER = 32;

{*
 *
 * this is the table of hard coded services.  Other services may exist
 * that are dynamically allocated.
 *
 *}


{* service numbers constrained by hardware                              *}
const
    JSERV_MINT      = 0;  {* monochrome display written to            *}
    JSERV_GINT      = 1;  {* color display written to                 *}
    JSERV_CRT1INT   = 2;  {* mono display's control registers changed *}
    JSERV_CRT2INT   = 3;  {* color display's control registers changed*}
    JSERV_ENBKB     = 4;  {* keyboard ready for next character        *}
    JSERV_LPT1INT   = 5;  {* parallel control register                *}
    JSERV_COM2INT   = 6;  {* serial control register                  *}

{* hard coded service numbers                                           *}
const
    JSERV_PCBOOTED     = 7;  {* PC is ready to service soft interrupts*}
    JSERV_SCROLL       = 8;  {* PC is scrolling its screen            *}
    JSERV_HARDDISK     = 9;  {* Amiga reading PC hard disk            *}
    JSERV_READAMIGA    = 10; {* PC reading Amiga mem                  *}
    JSERV_READPC       = 11; {* Amiga reading PC mem                  *}
    JSERV_AMIGACALL    = 12; {* PC causing Amiga function call        *}
    JSERV_PCCALL       = 13; {* Amiga causing PC interrupt            *}
    JSERV_AMIGASERVICE = 14; {* PC initiating Amiga side of a service *}
    JSERV_PCSERVICE    = 15; {* Amiga initiating PC side of a service *}
    JSERV_PCDISK       = 16; {* PC using AmigaDos files               *}
    JSERV_AMOUSE       = 17; {* AMouse Communications                 *}

{*--- JANUS PC Function calls -----------
 *
 * This is the table of function codes. These functions allow controlling
 * of dynamically allocated services (dyn-service).
 *
 * 1.Generation:   (befor Mai'88)
 *}
const
    JFUNC_GETSERVICE1 = 0; {* not supported any more        *}
    JFUNC_GETBASE     = 1; {* report segments, offset of janus mem *}
    JFUNC_ALLOCMEM    = 2; {* allocate janus memory *}
    JFUNC_FREEMEM     = 3; {* free janus memory *}
    JFUNC_SETPARAM    = 4; {* set pointer to service parameter *}
    JFUNC_SETSERVICE  = 5; {* not supported any more        *}
    JFUNC_STOPSERVICE = 6; {* not supported any more        *}
    JFUNC_CALLAMIGA   = 7; {* call service on Amiga side *}
    JFUNC_WAITAMIGA   = 8; {* wait for service becomes ready *}
    JFUNC_CHECKAMIGA  = 9; {* check service status *}
{*
 * 2.Generation:
 *}
const
    JFUNC_ADDSERVICE        = 10; {* add a dyn-service *}
    JFUNC_GETSERVICE        = 11; {* link to a dyn-service*}
    JFUNC_CALLSERVICE       = 12; {* call a dyn-service*}
    JFUNC_RELEASESERVICE    = 13; {* unlink from a dyn-service*}
    JFUNC_DELETESERVICE     = 14; {* delete a dyn-service*}
    JFUNC_LOCKSERVICEDATA   = 15; {* lock private mem of a dyn-service*}
    JFUNC_UNLOCKSERVICEDATA = 16; {* unlock private mem of a dyn-service*}
    JFUNC_INITLOCK          = 17;
    JFUNC_LOCKATTEMPT       = 18;
    JFUNC_LOCK              = 19;
    JFUNC_UNLOCK            = 20;
    JFUNC_ALLOCJREMEMBER    = 21;
    JFUNC_ATTACHJREMEMBER   = 22;
    JFUNC_FREEJREMEMBER     = 23;
    JFUNC_ALLOCSERVICEMEM   = 24;
    JFUNC_FREESERVICEMEM    = 25;

    JFUNC_MAX      = 25;    {* Last function (for range check only) *}

    JFUNC_JINT     = $0b;


{*
 * === ServiceData Structure =============================================== 
 * The ServiceData structure is used to share data among all callers of 
 * all of the Service routines.  One of these is allocated in janus memory 
 * for each service.
 *}
type
    PPServiceData = ^PServiceData;
    PServiceData = ^TServiceData;
    TServiceData = record
   {*
    * The ServiceData ID numbers are used to uniquely identify
    * application-specific services.  There are two ID numbers:
    * the global ApplicationID and the application's local LocalID.
    *
    * The ApplicationID is a 32-bit number which *must* be assigned to
    * an application designer by Commodore-Amiga.
    * Once a service ApplicationID is assigned to an application
    * designer, that designer "owns" that ID number forever.
    * Note that this will provide unique ServiceData identification
    * numbers only for the first 4.3 billion ServiceData designers
    * after that, there's some risk of a collision.
    *
    * The LocalID, defined by the application designer, is a local
    * subcategory of the global ApplicationID.  These can mean anything
    * at all.  There are 65,536 of these local ID's.
    *}
        sd_ApplicationID: DWord;
        sd_LocalID: Word;

   {*
    * The flag bits are defined below.  Some of these are set by the
    * application programs which use the service, and some are set
    * by the system.
    *}
        sd_Flags: Word;

   {*
    * This field is initialized by the system for you, and then
    * is never touched by the system again.  Users of the
    * service can agree by convention that they have to obtain
    * this lock before using the service.
    * If you are the AddService() caller and you want this lock
    * to be locked before the service is linked into the system,
    * set the AddService() ADDS_LOCKDATA argument flag.
    *}
        sd_ServiceDataLock: Byte;

   {*
    * This tracks the number of users currently connected
    * to this service.
    *}
        sd_AmigaUserCount: Byte;
        sd_PCUserCount: Byte;
        sd_ReservedByte: Byte;

   {*
    * These are the standard janus memory descriptions, which describe
    * the parameter memory associated with this service.  This memory
    * (if any) will be allocated automatically by the system when the
    * service if first added.  The creator of the service
    * (the one who calls AddService()) supplies the MemSize and
    * MemType values * after the service is added the MemPtr field
    * will point to the parameter memory.  GetService() callers, after
    * the service comes available, will find all of these fields
    * filled in with the appropriate values.
    * The AmigaMemPtr and PCMemPtr both point to the same location
    * of Janus memory; an Amiga program should use the AmigaMemPtr,
    * and a PC program should use the PCMemPtr
    *}
        sd_MemSize: Word;
        sd_MemType: Word;
        sd_MemOffset: RPTR;
        sd_AmigaMemPtr: APTR;
        sd_PCMemPtr: APTR;

   {*
    * This offset is used as the key for calls to AllocServiceMem()
    * and FreeServiceMem().  This key can be used by any one
    * who's learned about this service via either AddService()
    * or GetService().  The system makes no memory allocations
    * using this key, so it's completely under application control.
    * Any memory attached to this key by calls to AllocServiceMem()
    * will be freed automatically after the service has been
    * deleted and all users of the service have released the service.
    *}
        sd_JRememberKey: RPTR;

   {*
    * These pointers are for the system-maintained lists of
    * structures.  If you disturb any of these pointers, you will be
    * tickling the guru's nose, and when the guru sneezes ...
    *}
        sd_NextServiceData: RPTR;
        sd_FirstPCCustomer: APTR;
        sd_FirstAmigaCustomer: APTR;

   {*
    * Semaphore structure pointer for services that allow multiple customers
    *}
        sd_Semaphore: PSignalSemaphore;

   {*
    * These fields are reserved for future use
    *}
        sd_ZaphodReserved: array[0..3] of DWord;
    end;




{*
 * === Flag Definitions === 
 *}
const
    SERVICE_DELETED    = $0001;   {* Owner of this service deleted it *}
    SERVICE_DELETEDn   = 0;
    EXPUNGE_SERVICE    = $0002;   {* Owner of service should delete   *}
    EXPUNGE_SERVICEn   = 1;
    SERVICE_AMIGASIDE  = $0004;   {* Set if Amiga created the service *}
    SERVICE_AMIGASIDEn = 2;
    SERVICE_PCWAIT     = $0008;   {* Set when PC calls a service      *}
    SERVICE_PCWAITn    = 3;       {* Cleared when service replys      *}
    AMIGA_EXCLUSIVE    = $0010;   {* Only one Amiga customer allowed  *}
    AMIGA_EXCLUSIVEn   = 4;
    PC_EXCLUSIVE       = $0020;   {* Only one PC customer allowed     *}
    PC_EXCLUSIVEn      = 5;
    SERVICE_ADDED      = $0040;   {* Set when service is added        *}
    SERVICE_ADDEDn     = 6;


{* === ServiceCustomer Structure =========================================== 
 * A ServiceCustomer structure is created for each "customer" of a given 
 * channel
 *}
type
    PServiceCustomer = ^TServiceCustomer;
    TServiceCustomer = record
        scs_NextCustomer: APTR;

        scs_Flags: Word;

        scs_Task: APTR;           {* This points to the task of the customer *}
        scs_SignalBit: DWord;     {* Signal the customer with this bit       *}

        scs_JazzReserved: array[0..3] of DWord;
    end;

{* === Flag Definitions === *}
{* These flags are set/cleared by the system *}
const
    CALL_TOPC_ONLY        = $0100;
    CALL_TOPC_ONLYn       = 8;
    CALL_FROMPC_ONLY      = $0200;
    CALL_FROMPC_ONLYn     = 9;
    CALL_TOAMIGA_ONLY     = $0400;
    CALL_TOAMIGA_ONLYn    = 10;
    CALL_FROMAMIGA_ONLY   = $0800;
    CALL_FROMAMIGA_ONLYn  = 11;




{*
 * === AddService() Flags ==================================================
 * These are the definitions of the flag arguments that can be passed to the
 * AddService() function.
 *}
const
    ADDS_EXCLUSIVE       = $0001; {* want to be only Amiga customer     *}
    ADDS_EXCLUSIVEn      = 0;
    ADDS_TOPC_ONLY       = $0002; {* want to send signals only to PC    *}
    ADDS_TOPC_ONLYn      = 1;
    ADDS_FROMPC_ONLY     = $0004; {* want to get signals only from PC   *}
    ADDS_FROMPC_ONLYn    = 2;
    ADDS_TOAMIGA_ONLY    = $0008; {* want to send signals only to Amiga *}
    ADDS_TOAMIGA_ONLYn   = 3;
    ADDS_FROMAMIGA_ONLY  = $0010; {* want to get signals only from Amiga*}
    ADDS_FROMAMIGA_ONLYn = 4;
    ADDS_LOCKDATA        = $0020; {* S'DataLock locked before linking to*}
    ADDS_LOCKDATAn       = 5;      {* system                             *}

{*
 * These are the system's AddService() Flags 
 *}
const
    SD_CREATED         = $0100;
    SD_CREATEDn        = 8;



{*
 * === GetService() Flags ==================================================
 * These are the definitions of the flag arguments that can be passed to the
 * GetService() function.
 *}
const
    GETS_WAIT            = $0001; {* wait till service is available     *}
    GETS_WAITn           = 0;
    GETS_TOPC_ONLY       = $0002; {* want to send signals only to PC    *}
    GETS_TOPC_ONLYn      = 1;
    GETS_FROMPC_ONLY     = $0004; {* want to get signals only from PC   *}
    GETS_FROMPC_ONLYn    = 2;
    GETS_TOAMIGA_ONLY    = $0008; {* want to send signals only to Amiga *}
    GETS_TOAMIGA_ONLYn   = 3;
    GETS_FROMAMIGA_ONLY  = $0010; {* want to get signals only from Amiga*}
    GETS_FROMAMIGA_ONLYn = 4;
    GETS_EXCLUSIVE       = $0020; {* want to be only Amiga customer     *}
    GETS_EXCLUSIVEn      = 5;
    GETS_ALOAD_A         = $0040; {* Autoload the Amiga service         *}
    GETS_ALOAD_An        = 6;
    GETS_ALOAD_PC        = $0080; {* Autoload the PC service            *}
    GETS_ALOAD_PCn       = 7;
    GETS_WAITmask        = $0300;
    GETS_WAIT_15         = $0100; {* Wait up to 15 seconds for a service*}
    GETS_WAIT_30         = $0200; {*      "     30          "           *}
    GETS_WAIT_120        = $0300; {*      "    120          "           *}



{*
 * === AddService() and GetService() Result Codes ==========================
 * These are the result codes that may be returned by a call to AddService()
 * or GetService()
 *}
const
    JSERV_NOFUNCTION   =  -1; {* Tried to call a not supported function *}
    JSERV_OK           =  0;  {* All is well *}
    JSERV_PENDING      =  0;  {* Called service still pending on Amiga side *}
    JSERV_FINISHED     =  1;  {* Called service is finished on Amiga side *}
    JSERV_NOJANUSBASE  =  2;  {* ServiceBase structure not defined *}
    JSERV_NOJANUSMEM   =  3;  {* We ran out of Janus memory *}
    JSERV_NOAMIGAMEM   =  4;  {* On the Amiga side we ran out of Amiga memory *}
    JSERV_NOPCMEM      =  5;  {* On the PC side we ran out of PC memory *}
    JSERV_NOSERVICE    =  6;  {* Tried to get a service that doesn't exist *}
    JSERV_DUPSERVICE   =  7;  {* Tried to add a service that already existed *}
    JSERV_ILLFUNCTION  =  8;  {* Tried to call an illegal function *}
    JSERV_NOTEXCLUSIVE =  9;  {* Wanted to but couldn't be exclusive user *}
    JSERV_BADAUTOLOAD  =  10; {* Wanted to autoload but couldn't *}



{************************************************************************
 * (Amiga side file)
 *
 * TimeServ.h - TimeServ specific data structures
 *
 * 4-19-88 - Bill Koester - Created this file
 * 7-15-88 - Bill Koester - Modified for self inclusion of required files
 ************************************************************************}

const
    TIMESERV_APPLICATION_ID = 1;
    TIMESERV_LOCAL_ID       = 1;

{* Time request structure for Amiga Date/Time request from 8086 *}
type
    PTimeServReq = ^TTimeServReq;
    TTimeServReq = record
        tsr_Year: Word;
        tsr_Month: Byte;
        tsr_Day: Byte;
        tsr_Hour: Byte;
        tsr_Minutes: Byte;
        tsr_Seconds: Byte;
        tsr_String: array[0..26] of Byte;
        tsr_Err: Byte;       {* Return code (see below) 0 if all OK *}
    end;

{* Error codes for adr_Err, returned in low byte                        *}
const
    TSR_ERR_OK       = 0;     {* No error                            *}
    TSR_ERR_NOT_SET  = 1;     {* Time not set on Amiga               *}



{************************************************************************
 * (Amiga side file)
 *
 * DOSServ.h - DOSServ specific data structures
 *
 * 11-19-90 - Bill Koester - Created this file
 ************************************************************************}

const
    DOSSERV_APPLICATION_ID  = 1;
    DOSSERV_LOCAL_ID        = 3;

{*************************}
{* DOS request structure *}
{*************************}

type
    PDOSServReq = ^TDOSServReq;
    TDOSServReq = record
        dsr_Function: Word;
        dsr_Lock: Byte;
        dsr_Pad: Byte;
        dsr_Buffer_Seg: Word;
        dsr_Buffer_Off: Word;
        dsr_Buffer_Size: Word;
        dsr_Err: Word;       {* Return code (see below) 0 if all OK *}
        dsr_Arg1_h: Word;
        dsr_Arg1_l: Word;
        dsr_Arg2_h: Word;
        dsr_Arg2_l: Word;
        dsr_Arg3_h: Word;
        dsr_Arg3_l: Word;
    end;

{***********************************}
{* Function codes for dsr_Function *}
{***********************************}
const
    DSR_FUNC_OPEN_OLD         =  1;
    DSR_FUNC_OPEN_NEW         =  2;
    DSR_FUNC_OPEN_READ_WRITE  =  3;
    DSR_FUNC_CLOSE            =  4;
    DSR_FUNC_READ             =  5;
    DSR_FUNC_WRITE            =  6;
    DSR_FUNC_SEEK_BEGINING    =  7;
    DSR_FUNC_SEEK_END         =  8;
    DSR_FUNC_SEEK_CURRENT     =  9;
    DSR_FUNC_SEEK_EXTEND      = 10;
    DSR_FUNC_CREATE_DIR       = 11;
    DSR_FUNC_LOCK             = 12;
    DSR_FUNC_UNLOCK           = 13;
    DSR_FUNC_EXAMINE          = 14;
    DSR_FUNC_EXNEXT           = 15;
    DSR_FUNC_GETCURRENTDIR    = 16;
    DSR_FUNC_SETCURRENTDIR    = 17;
    DSR_FUNC_DELETEFILE       = 18;
    DSR_FUNC_DUPLOCK          = 19;
    DSR_FUNC_PARENTDIR        = 20;
    DSR_FUNC_RENAME           = 21;
    DSR_FUNC_SETPROTECTION    = 22;
    DSR_FUNC_PARSEPATTERN     = 23;
    DSR_FUNC_MATCHPATTERN     = 24;
    DSR_FUNC_ENDCURRENTDIR    = 25;
    DSR_FUNC_SETFILEDATE      = 26;

{***************************}
{* Error codes for dsr_Err *}
{***************************}
const
    DSR_ERR_OK                = 0;
    DSR_ERR_UNKNOWN_FUNCTION  = 1;
    DSR_ERR_TOO_MANY_FILES    = 2;
    DSR_ERR_OPEN_ERROR        = 3;
    DSR_ERR_FILE_NOT_OPEN     = 4;
    DSR_ERR_SEEK_ERROR        = 5;
    DSR_ERR_TOO_MANY_LOCKS    = 6;



{************************************************************************
 * (Amiga side file)
 *
 * JanusBase.h  --  Primary include file for janus.library
 *
 * This file contains all AMIGA SPECIFIC definitions and does not contain
 * any definitions required on the PC
 *
 * Copyright (c) 1986, 1987, 1988, Commodore Amiga Inc.
 * All rights reserved
 *
 * Date        Name               Description
 * --------   ---------------     ----------------------------------------
 * Early 86 - Katin/Burns clone - Created this file!
 * 02-12-88 - RJ Mical          - Added JanusRemember structure
 * 07-15-88 - Bill Koester      - Modified for self inclusion of required files
 * 07-25-88 - Bill Koester      - Added jb_Reserved to JanusBase
 * 
 ************************************************************************}


{*
 * === ===================================================================== 
 * === JanusBase Structure =================================================
 * === ===================================================================== 
 * JanusBase -- the main janus.library data structure.
 * This is the structure that you must declare a pointer to:
 *
 *   struct JanusBase *JanusBase = NULL;
 *
 * and initialize by opening janus.library:
 *
 *   JanusBase = OpenLibrary(JANUSNAME, myJANUSVERSION);
 *
 *  before using any of the Janus routines.  
 *}

type
    PPInterrupt = ^PInterrupt;

type
    PJanusBase = ^TJanusBase;
    TJanusBase = record
        jb_LibNode: TLibrary;

        jb_IntReq: DWord;          {* software copy of outstanding requests   *}
        jb_IntEna: DWord;          {* software copy of enabled interrupts     *}
        jb_ParamMem: PByte;        {* ptr to (byte arranged) param mem        *}
        jb_IoBase: PByte;          {* ptr to base of io register region       *}
        jb_ExpanBase: PByte;       {* ptr to start of shared memory           *}
        jb_ExecBase: APTR;         {* ptr to exec library                     *}
        jb_DOSBase: APTR;          {* ptr to DOS library                      *}
        jb_SegList: APTR;          {* ptr to loaded code                      *}
        jb_IntHandlers: PPInterrupt; {* base array of int handler ptrs *}
        jb_IntServer: TInterrupt;    {* INTB_PORTS server              *}
        jb_ReadHandler: TInterrupt;  {* JSERV_READAMIGA handler        *}

        jb_KeyboardRegisterOffset: Word;    {* exactly that                   *}
        jb_ATFlag: Word;                    {* 1 if this is an AT             *}
        jb_ATOffset: Word;                  {* offset to the AT ROM bank      *}

        jb_ServiceBase: APTR; {* Amiga Services data structure  *}

        jb_Reserved: array[0..3] of DWord;
    end;



{*
 * === ===================================================================== 
 * === Miscellaneous ======================================================= 
 * === ===================================================================== 
 * hide a byte field in the lib_pad field 
 *}

//#define jb_SpurriousMask LIB_pad


{*
 * === ===================================================================== 
 * === Miscellaneous ======================================================= 
 * === ===================================================================== 
 *}

{************************************************************************
 *
 * data structure for SetupJanusSig() routine
 *
 ************************************************************************}

type
    PSetupSig = ^TSetupSig;
    TSetupSig = record
        ss_Interrupt: TInterrupt;
        ss_TaskPtr: Pointer;
        ss_SigMask: DWord;
        ss_ParamPtr: Pointer;
        ss_ParamSize: DWord;
        ss_JanusIntNum: Word;
    end;


{*
 * JanusResource - an entity which keeps track of the reset state of the 8088
 * if this resource does not exist, it is assumed the 8088 can be reset
 *}

type
    PJanusResource = ^TJanusResource;
    TJanusResource = record
        jr_BoardAddress: APTR; {* Address of Janus board                *}
        jr_Reset: Byte;        {* non-zero indicates 8088 is held reset *}
        jr_Pad0: Byte;
    end;



const
    JANUSNAME = 'janus.library';

var
    JanusBase : PJanusBase;


function AddService(servicedata: PPServiceData location 'a0'; appid: DWord location 'd0'; localid: Word location 'd1'; memsize: Word location 'd2'; MemType: Word location 'd3'; signalbit: Word location 'd4'; Flags: Word location 'd5'): SmallInt; syscall JanusBase 138;
function AllocJanusMem(size: DWord location 'd0'; _type: DWord location 'd1'): Pointer; syscall JanusBase 60;
function AllocJRemember(key: PRPTR location 'a0'; size: Word location 'd0'; _type: Word location 'd1'): Pointer; syscall JanusBase 192;
function AllocServiceMem(servicedata: PServiceData location 'a0'; size: Word location 'd0'; _type: Word location 'd1'): Pointer; syscall JanusBase 210;
procedure AttachJRemember(tokey: PRPTR location 'a0'; fromkey: PRPTR location 'a1'); syscall JanusBase 204;
procedure CallService(servicedata: PServiceData location 'a0'); syscall JanusBase 150;
function CheckJanusInt(jintnum: DWord location 'd0'): DWord; syscall JanusBase 54;
procedure CleanupJanusSig(setupsig: PSetupSig location 'a0'); syscall JanusBase 114;
procedure DeleteService(servicedata: PServiceData location 'a0'); syscall JanusBase 162;
procedure FreeJanusMem(ptr: Pointer location 'a1'; size: DWord location 'd0'); syscall JanusBase 66;
procedure FreeJRemember(key: PRPTR location 'a0'; reallyforget: DWord location 'd0'); syscall JanusBase 198;
procedure FreeServiceMem(servicedata: PServiceData location 'a0'; ptr: Pointer location 'a1'); syscall JanusBase 216;
function GetJanusStart: Pointer; syscall JanusBase 102;
function GetParamOffset(jintnum: DWord location 'd0'): SmallInt; syscall JanusBase 90;
function GetService(servicedata: PPServiceData location 'a0'; appid: DWord location 'd0'; localid: Word location 'd1'; signal: SmallInt location 'd2'; flags: Word location 'd3'): SmallInt; syscall JanusBase 90;
procedure JanusInitLock(ptr: Pointer location 'a0'); syscall JanusBase 240;
procedure JanusLock(ptr: Pointer location 'a0'); syscall JanusBase 120;
function JanusLockAttempt(ptr: Pointer location 'a0'): DWord; syscall JanusBase 222;
function JanusMemBase(_type: DWord location 'd0'): Pointer; syscall JanusBase 72;
function JanusMemToOffset(ptr: Pointer location 'd0'): Word; syscall JanusBase 84;
function JanusMemType(ptr: Pointer location 'd0'): DWord; syscall JanusBase 78;
function JanusOffsetToMem(offset: Word location 'd0'; _type: Word location 'd1'): Pointer; syscall JanusBase 168;
procedure JanusUnlock(ptr: Pointer location 'a0'); syscall JanusBase 126;
procedure JBCopy(source: Pointer location 'a0'; destination: Pointer location 'a1'; length: DWord location 'd0'); syscall JanusBase 132;
procedure LockServiceData(servicedata: PServiceData location 'a0'); syscall JanusBase 228;
function MakeBytePtr(ptr: Pointer location 'a0'): PByte; syscall JanusBase 180;
function MakeWordPtr(ptr: Pointer location 'a0'): PWord; syscall JanusBase 186;
procedure ReleaseService(servicedata: PServiceData location 'a0'); syscall JanusBase 156;
procedure SendJanusInt(jintnum: DWord location 'd0'); syscall JanusBase 48;
function SetJanusEnable(jintnum: DWord location 'd0'; newvalue: DWord location 'd1'): DWord; syscall JanusBase 36;
function SetJanusHandler(jintnum: DWord location 'd0'; intserver: Pointer location 'a1'): Pointer; syscall JanusBase 30;
function SetJanusRequest(jintnum: DWord location 'd0'; newvalue: DWord location 'd1'): DWord; syscall JanusBase 42;
function SetParamOffset(jintnum: DWord location 'd0'; offset: Word location 'd1'): Word; syscall JanusBase 96;
function SetupJanusSig(jintnum: Word location 'd0'; signum: Word location 'd1'; memsize: DWord location 'd2'; memtype: DWord location 'd3'): PSetupSig; syscall JanusBase 108;
function TranslateJanusPtr(ptr: Pointer location 'a0'; _type: Word location 'd0'): Pointer; syscall JanusBase 174;
procedure UnlockServiceData(servicedaata: PServiceData location 'a0'); syscall JanusBase 234;


implementation


initialization
  JanusBase := PJanusBase(OpenLibrary(JANUSNAME,0));
finalization
  if Assigned(JanusBase) then
    CloseLibrary(PLibrary(JanusBase));
end.
