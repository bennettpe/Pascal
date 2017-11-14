program PASCALCOMPILER ( INPUT , OUTPUT , PRR , LISTING , DBGINFO ,
                         TRACEF ) ;

(********************************************************************)
(*$D-,N+,A-                                                         *)
(********************************************************************)
(*                                                                  *)
(*         S T A N F O R D   P A S C A L   C O M P I L E R          *)
(*                                                                  *)
(*              OPPOLZER VERSION                                    *)
(*                                                                  *)
(*                                                                  *)
(*         AUTHOR OF ORIGINAL PROGRAM:                              *)
(*                                                                  *)
(*              URS AMMANN                                          *)
(*              FACHGRUPPE COMPUTERWISSENSCHAFTEN                   *)
(*              EIDG. TECHNISCHE HOCHSCHULE                         *)
(*              CH-8006 ZUERICH                                     *)
(*                                                                  *)
(*                                                                  *)
(*         AUTHOR OF SECOND VERSION:                                *)
(*                                                                  *)
(*              KESAV NORI                                          *)
(*              COMPUTER GROUP                                      *)
(*              T.I.F.R.                                            *)
(*              HOMI BHABHA ROAD                                    *)
(*              BOMBAY - 400005                                     *)
(*              INDIA                                               *)
(*                                                                  *)
(*                                                                  *)
(*         AUTHOR OF THIRD VERSION (STANFORD PASCAL):               *)
(*                                                                  *)
(*              S. HAZEGHI                                          *)
(*              COMPUTATION RESEARCH GROUP                          *)
(*              STANFORD LINEAR ACCELERATOR CENTER                  *)
(*              STANFORD, CA. 94305.                                *)
(*                                                                  *)
(*                                                                  *)
(*         AUTHOR OF FOURTH VERSION (MCGILL PASCAL):                *)
(*                                                                  *)
(*              R. NIGEL HORSPOOL                                   *)
(*              SCHOOL OF COMPUTER SCIENCE                          *)
(*              MCGILL UNIVERSITY                                   *)
(*              MONTREAL  QUEBEC  H3A 2K6                           *)
(*                                                                  *)
(*                                                                  *)
(*         AUTHOR OF This VERSION (Oppolzer Version):               *)
(*                                                                  *)
(*              Bernd Oppolzer                                      *)
(*              Diplom-Informatiker                                 *)
(*              Baerenhofstr. 23                                    *)
(*              D-70771 Leinfelden-Echterdingen                     *)
(*              Germany                                             *)
(*                                                                  *)
(*==================================================================*)
(*                                                                  *)
(* 02FEB2007 - Changes by Dave Edwards to use hex codes C0,D0       *)
(*    (was 8B,9B) for EBCDIC brace characters (curly brackets).     *)
(*    New constants CHLBRACE and CHRBRACE defined.                  *)
(*    VERSION date left unchanged as MAY -82.                       *)
(*    Hex C0,D0 seem to be the codes used by most curr. software    *)
(*    such as tn3270 clients, Ascii-EBCDIC translate tables, etc.   *)
(*    and conform to the standard IBM-037 US code page.             *)
(*    See additional notes in file ccde:pascal_info.txt .           *)
(*  - Also, in INITTABLES procedure, set UPSHIFT to only upshift    *)
(*    lowercase chars (e.g. exclude tilde, which is in the range    *)
(*    a to z), and add comments re. definition of SSY array.        *)
(*    Note that curly brackets and backslash are within the         *)
(*    range A to Z in the EBCDIC character set.                     *)
(*  - Also fix spacing of text for BGN output record: change        *)
(*    TIME:9 to TIME:8. Was causing last char of year to be         *)
(*    truncated, in the info text at the start of $PASMAIN          *)
(*    csect in the object file.                                     *)
(*  - Source changes are identified by flag DE near beginning       *)
(*    of lines.                                                     *)
(*    (Write date of previous source file: 14sep1983.)              *)
(*                                                                  *)
(*==================================================================*)
(*                                                                  *)
(*  Oct.2011 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*    PASCAL 1982 ported to VM370 R6 on Hercules (from MUSIC/SP)    *)
(*                                                                  *)
(*    Summary of Changes:                                           *)
(*                                                                  *)
(*    - another substitute for brackets: (. .) - not only (/ /)     *)
(*                                                                  *)
(*    - substitute for pointer symbol: ->                           *)
(*                                                                  *)
(*    - comments like PL/1 and C: /* ... */                         *)
(*                                                                  *)
(*    - year 2000 problem fixed (still TIME DEC used in PASMONN)    *)
(*                                                                  *)
(*    - new loop control statements: BREAK and CONTINUE             *)
(*                                                                  *)
(*    - RETURN statement                                            *)
(*                                                                  *)
(*  to be done:                                                     *)
(*                                                                  *)
(*    - allow shorter String constants to be assigned               *)
(*      (padded with blanks)                                        *)
(*                                                                  *)
(*    - allow static definitions (local to procs and functions)     *)
(*                                                                  *)
(*==================================================================*)
(*                                                                  *)
(*  Aug.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  to support the runtime extensions (PASCSP) regarding            *)
(*  textfile I/O, the implicit RESET on INPUT on the beginning      *)
(*  of the MAIN function has been removed; RESET is now done        *)
(*  when the first READ operation is encountered. That means        *)
(*  that the char variable INPUT -> is undefined until the          *)
(*  end of the first READ operation                                 *)
(*                                                                  *)
(*==================================================================*)
(*                                                                  *)
(*  Sep.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  a) shorter strings allowed on const initializers                *)
(*     (on structured - typed - constants)                          *)
(*                                                                  *)
(*  b) shorter string constants on assignments                      *)
(*                                                                  *)
(*  c) even strings of length 1 (single chars) and zero ('')        *)
(*                                                                  *)
(*  d) prepared for new typeclass (charstring) -                    *)
(*     but not yet used or implemented; could make some             *)
(*     things simpler                                               *)
(*                                                                  *)
(*  e) using this: IDLNGTH changed from 12 to 20,                   *)
(*     so that the first 20 characters are significant on           *)
(*     identifiers (not only 12). The initializers needed           *)
(*     not be changed; although they are still 12 bytes long,       *)
(*     the fields are filled with blanks up to length 20            *)
(*                                                                  *)
(*  f) correct output to P-Code file, where necessary;              *)
(*     format changes observed on CST, ENT and BGN                  *)
(*                                                                  *)
(*  g) no changes so far to caching routines etc.                   *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Sep.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  New functions added to support the construction of a new        *)
(*  storage management library using Pascal:                        *)
(*                                                                  *)
(*  - ADDR to get the address of any variable;                      *)
(*    the result of this function is a pointer without type         *)
(*    (aka void pointer) similar to the NIL pointer,                *)
(*    which is compatible with every other pointer type             *)
(*                                                                  *)
(*  - PTRADD to add an integer expression to a pointer              *)
(*    (of any type) - this adds addresses in contrast to C,         *)
(*    where element sizes are added; PTRADD without a               *)
(*    second argument (which is the same as PTRADD (X,0))           *)
(*    can be used to convert a typed pointer to a void pointer      *)
(*                                                                  *)
(*  - PTRDIFF, that subtracts two pointers (of any type),           *)
(*    giving an integer result                                      *)
(*                                                                  *)
(*  - SIZEOF, which works much the same as the C function           *)
(*    of the same name; as with C, you can specify a variable       *)
(*    as argument or a type identifier                              *)
(*                                                                  *)
(*  - PTR2INT, which converts a pointer to an integer value         *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Sep.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  New keyword MODULE; a module is a collection of                 *)
(*  external procedures without a main program. The keyword         *)
(*  MODULE replaces the keyword PROGRAM on modules.                 *)
(*  It sets the compiler switch X implicitly and enforces that      *)
(*  the main block (which still has to be coded) is empty,          *)
(*  that is: "begin end.". No main block is generated, so           *)
(*  it is now possible to add multiply modules to a Pascal          *)
(*  program without name conflicts.                                 *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Sep.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  Standard functions and procedures may not only be               *)
(*  implemented by inline code or CSP calls; another                *)
(*  possible (new) technique is to call an external function        *)
(*  in a library module.                                            *)
(*                                                                  *)
(*  To support this, several atributes have been added to the       *)
(*  internal Standard procedure description:                        *)
(*                                                                  *)
(*     STANDARD :                                                   *)
(*       ( KEY : INTEGER ;                                          *)
(*         LIBNAME : EXTNAMTP ;                                     *)
(*         FUNCCODE : INTEGER ;                                     *)
(*         PARMCNT : INTEGER ;                                      *)
(*         PROCTYP : CHAR ) ;                                       *)
(*                                                                  *)
(*   KEY is the only attribute that was present before and          *)
(*   is the number of the CSP call.                                 *)
(*                                                                  *)
(*   If LIBNAME is not blank, the Standard Proc is implemented      *)
(*   by a library function call. It gets the FUNCCODE as first      *)
(*   parameter; PARMCNT and PROCTYP are other attributes that       *)
(*   are needed to set up the CUP call for the library function     *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Sep.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  Four new standard functions have been added using               *)
(*  the library function facility:                                  *)
(*                                                                  *)
(*  - ALLOC, which gets a length and returns a pointer              *)
(*    to a new area of that length                                  *)
(*                                                                  *)
(*  - ALLOCX, which does the same, but does not use the             *)
(*    (yet to come) sophisticated logic like LE, but does a pure    *)
(*    GETMAIN on every ALLOCX call, which is simple, but slow       *)
(*                                                                  *)
(*  - FREE, which frees the storage retrieved by ALLOC              *)
(*                                                                  *)
(*  - FREEX, which frees the storage retrieved by ALLOCX,           *)
(*    that is: FREEMAIN                                             *)
(*                                                                  *)
(*  The four new functions are implemented in the module            *)
(*  PASLIBX, seperate from the compiler (in Pascal)                 *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Oct.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  New functions:                                                  *)
(*                                                                  *)
(*  - PTRCAST as a substitute for PTRADD with only one              *)
(*    argument; used to cast pointers of different types            *)
(*                                                                  *)
(*  - CHKHEAP to check the integrity of heap segments               *)
(*                                                                  *)
(*  - FILEFCB returns the pointer to the file control block         *)
(*    of the specified file (which contains the DCB at              *)
(*    position 36)                                                  *)
(*                                                                  *)
(*  - Pointers of any type can be written directly using            *)
(*    WRITE; the output format is 8 hex digits                      *)
(*                                                                  *)
(*  Other changes:                                                  *)
(*                                                                  *)
(*  The CSECTs of the internal procedures are now called            *)
(*  $PRVxxxx (xxxx is numbered starting from 0002).                 *)
(*                                                                  *)
(*  For external modules, the CSECT names of the internal           *)
(*  procedures are derived from the module name, for example:       *)
(*  module $PASLIBX --> CSECT names $LIBXxxx                        *)
(*                                                                  *)
(*  Only procs and funcs at level 1 are visible from outside        *)
(*  and keep their original names                                   *)
(*                                                                  *)
(*  If the new keyword LOCAL is specified in front of a             *)
(*  procedure or function declaration, the procedure is             *)
(*  local, even if it appears in an external module at level 1.     *)
(*                                                                  *)
(*  This all helps to reduce name conflicts and to allow            *)
(*  more than one external module (which was not possible           *)
(*  in original Stanford Pascal)                                    *)
(*                                                                  *)
(*  Changes to the environment:                                     *)
(*                                                                  *)
(*  in CMS the RUNPARM module was used to start Pascal programs     *)
(*  and to build an OS parm string out of the CMS tokenized         *)
(*  parameters, but: the CMS tokens were concatenated without       *)
(*  separating blanks. The new XRUNPARM module does the same,       *)
(*  but inserts blanks between the CMS tokens.                      *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Oct.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  Static variables are supported; the new keyword static          *)
(*  starts a declaration section for static variables (like         *)
(*  the keyword var does it for "normal" auto variables)            *)
(*                                                                  *)
(*  This is done the same way in IBMs Pascal VS                     *)
(*                                                                  *)
(*  There is a separate STATIC CSECT for every Code CSECT           *)
(*  (every proc/func) which can hold up to 4k of static             *)
(*  variables or structured constants ... the same CSECT            *)
(*  is used for both. The CSECT is part of the load module,         *)
(*  that is: writing into this STATIC CSECT makes the program       *)
(*  non-reentrant.                                                  *)
(*                                                                  *)
(*  The SNAPSHOT routine (now called PASSNAP) has been              *)
(*  enhanced to be able to show static variables, too.              *)
(*  To support this, the address of the STATIC CSECT is             *)
(*  stored at a certain place in the function prolog, which         *)
(*  can easily be found at run time (displacement of the            *)
(*  branch instruction at the EPA minus 4). If the address          *)
(*  at this place is zero, there are no static variables.           *)
(*                                                                  *)
(*  PASSNAP was further enhanced to show the EP addresses           *)
(*  of every function, the call offset at every call level          *)
(*  and the storage class, offset and address of every              *)
(*  variable (in addition to the variable name and the              *)
(*  value at the time of error or SNAPSHOT - in Pascal              *)
(*  notation).                                                      *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Nov.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  To enable the port to ASCII platforms, the following            *)
(*  changes have been made:                                         *)
(*                                                                  *)
(*  - the upper limit of for loops with loop control variables      *)
(*    of type char is encoded in char representation instead        *)
(*    of the internal numeric code in the P-Code source             *)
(*                                                                  *)
(*  - set constants of set of char have a new representation        *)
(*    in the P-Code, envolving char representation of the           *)
(*    chars contained in the set                                    *)
(*                                                                  *)
(*  - not related to the port: set constants in P-Code are          *)
(*    represented by hexa byte strings instead of integer           *)
(*    strings, which makes them much better readable                *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Dec.2016 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  Another portability issue:                                      *)
(*                                                                  *)
(*  the branch table used with case statements implies the          *)
(*  EBCDIC char set, if the case control variable is of type        *)
(*  char. I changed the XJP logic to a portable representation      *)
(*  of the branch table and shifted the construction of the         *)
(*  "real" branch table to the second pass. This way, XJP           *)
(*  instructions and "portable branch tables" can be moved          *)
(*  to foreign platforms with foreign character sets.               *)
(*                                                                  *)
(*  see boolean constant 'PORTABLE_BRANCHTABLE'                     *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Jan.2017 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  First version, which was extended / improved on Windows         *)
(*  first and later moved to Hercules/VM.                           *)
(*                                                                  *)
(*  From some discussions on the FPC mailing list, I got the        *)
(*  idea to support bit operations on integer operands, too.        *)
(*                                                                  *)
(*  The operations AND, OR, NOT have been extended to do            *)
(*  bit operations, when being used with integers (was error        *)
(*  134 before). Another operation XOR is provided (new             *)
(*  reserved symbol) for exclusive or operation; can be used        *)
(*  with integer or boolean operands.                               *)
(*                                                                  *)
(*  New P-Code instruction XOR; the P-Code instructions             *)
(*  AND, IOR, NOT and XOR have a type parameter (B or I).           *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Jan.2017 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  Change SEARCHID, to prevent additional errors, when             *)
(*  encountering a procedure call for a procedure without           *)
(*  declaration; the proc name was entered into the id list         *)
(*  as a dummy var declaration, which leaded to more errors.        *)
(*  Now the insert into the id list is deferred until the next      *)
(*  symbol has been read. (SEARCHID has got much more               *)
(*  parameters to be able to do this).                              *)
(*                                                                  *)
(*  New error code for "undeclared proc" (changed from 104          *)
(*  "identifier not declared" to 184 "procedure not                 *)
(*  declared").                                                     *)
(*                                                                  *)
(*  Error 184 is changed to warning, this way it is possible        *)
(*  to generate code (which makes some sense) even for              *)
(*  undeclared procedures and functions - much the same way         *)
(*  as some other languages (including PL/1 and C and FORTRAN)      *)
(*  do it. The types of the parameters are                          *)
(*  taken from the types of the arguments, which will               *)
(*  hopefully fit to the external definition of the                 *)
(*  procedure. If the arguments are variables, the args             *)
(*  are passed by reference; if not, by value.                      *)
(*                                                                  *)
(*  New field CSTNAME for declared procs (records the name          *)
(*  of the STATIC CSECT assigned to the proc). This was needed,     *)
(*  because all STATIC CSECTs of the (empty) main programs of       *)
(*  external modules had the same name #PASMAI#, which led to       *)
(*  name conflicts. The CSTNAME now is determined when the          *)
(*  procedure is created, already.                                  *)
(*                                                                  *)
(*  MODULE PASCALVS implements some of the functions that           *)
(*  are known from the PASCAL/VS compiler, e.g. DATETIME,           *)
(*  DATTIM10 (with century), TERMIN and TERMOUT, HALT               *)
(*                                                                  *)
(*  CLOSE standard function added as new CSP P-Code operation;      *)
(*  it turned out that it was not sufficient to simply set          *)
(*  the file status to zero, but instead the runtime on             *)
(*  the mainframe has to flush the buffers etc., so a true CSP      *)
(*  is the better solution. Now it is possible to close a file      *)
(*  before program termination without reopening it again.          *)
(*  Up until now this was only possible by issuing RESET or         *)
(*  REWRITE, leaving the file open until program termination.       *)
(*                                                                  *)
(*  DATE and TIME had to be added as new CSP P-Code operations,     *)
(*  too, because DATE and TIME values up until now only were        *)
(*  retrieved from the system once at initialization time.          *)
(*  Now it is done at every reference to DATE or TIME, by calling   *)
(*  the new CSP operations.                                         *)
(*                                                                  *)
(*  Floating Point output operations have been fixed;               *)
(*  WRITE (X : N) prints exponential format (n.nnnE+xx)             *)
(*  WRITE (X : N : P) prints decimal format, but if P = 0,          *)
(*  only the integer part of X is printed on all platforms          *)
(*                                                                  *)
(*  New standard function FLOOR (gets real parm, yields             *)
(*  real result), which returns the next lower "integer"            *)
(*  (but real type). This is NOT the same as TRUNC.                 *)
(*  FLOOR exists in C, too.                                         *)
(*                                                                  *)
(*  New standard function ROUNDX (round extended), which            *)
(*  rounds real values at a given positon (for example,             *)
(*  at the second decimal position) - as accurate as possible       *)
(*                                                                  *)
(*  Undefined functions don't give errors 104 and follow-up         *)
(*  errors, but a warning 186 instead (undefined function);         *)
(*  the function is assumed to have result type integer, and        *)
(*  the parameters are handled in the same way as with              *)
(*  undefined procedures, see above.                                *)
(*                                                                  *)
(*  Some errors on floating point rounding and output have been     *)
(*  fixed; now in most cases the same results are presented on      *)
(*  all platforms.                                                  *)
(*                                                                  *)
(*  The Pascal monitor PASMONN has been reworked, so that           *)
(*  the 8k limit is no problem any more (subroutines have their     *)
(*  own base register); Pascal subroutines (from PASLIBX) can       *)
(*  be called from CSP implementations written in ASSEMBLER;        *)
(*  these Pascal subroutines can in turn call other CSP             *)
(*  subroutines (and so on ...)                                     *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  May.2017 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  The compiler now runs on MVS (Hercules), too.                   *)
(*  Same source code (PASCAL1, PASCAL2) as with CMS,                *)
(*  same runtime (PASMONN) - although there are some                *)
(*  CMS dependencies, controlled by SYSPARM(CMS).                   *)
(*  Different PASSNAP ... see below.                                *)
(*                                                                  *)
(*  Several changes and corrections to PASMONN (Pascal runtime)     *)
(*  have been made. The most important: PASMONN now supports        *)
(*  RESET and REWRITE of PO members with their name specified       *)
(*  at runtime using the new function ASSIGNMEM. After RESET,       *)
(*  success can be checked by looking at a flag in the Pascal       *)
(*  FCB, accessed by the (existing) function FILEFCB.               *)
(*                                                                  *)
(*  This has been necessary to provide a MVS variant of PASSNAP;    *)
(*  PASSNAP reads debug information at runtime, which depends       *)
(*  on the name of the source file. In CMS, this was accomplished   *)
(*  using CMS FILEDEFs, issued from the Pascal program.             *)
(*  In MVS, ASSIGNMEM is used. The version of PASSNAP for MVS       *)
(*  is located in the source file PASSNAPM. The technique to        *)
(*  open the debug information file is the only difference          *)
(*  between PASSNAP (CMS) and PASSNAPM (MVS).                       *)
(*                                                                  *)
(*  There is still room for some improvement in the area of         *)
(*  error handling etc.; some ideas:                                *)
(*                                                                  *)
(*  - register and PSW output in both PASSNAP and the simple        *)
(*    error output written by PASMONN                               *)
(*                                                                  *)
(*  - correct handling of 1006 - stack/heap collision               *)
(*                                                                  *)
(*  - control PASSNAP output by runtime option                      *)
(*                                                                  *)
(*  - control ABEND with SYSUDUMP after PASSNAP by runtime option   *)
(*                                                                  *)
(*  - use CAMLST to determine the type of the assigned dataset      *)
(*    (PS or PO) to prevent error 013-14 (which is unrecoverable)   *)
(*                                                                  *)
(*  - read directory or BLDL instead of reacting on 013-18          *)
(*    using the DCB ABEND EXIT (which is recoverable)               *)
(*                                                                  *)
(*  - if no member specified and dataset assigned is a PDS,         *)
(*    change RECFM to U on the fly and read directory               *)
(*                                                                  *)
(*  Thanks to Gerhard Postpischil and Juergen Winckelmann           *)
(*  for help and good advice and for encouraging me to do           *)
(*  the MVS port.                                                   *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  May.2017 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  - Minor error: allow CLOSE for non-Text-Files, too.             *)
(*                                                                  *)
(*  - New standard type ANYFILE, compatible to every other          *)
(*    file type; file variables can be arguments to var             *)
(*    parameters of type ANYFILE, and so functions and              *)
(*    procedures can be written that accept files of any            *)
(*    type as parameters                                            *)
(*                                                                  *)
(*  - standard type VOIDPTR renamed to ANYPTR; VOIDPTR is           *)
(*    allowed, too (for compatibility reasons)                      *)
(*                                                                  *)
(*  - X -> is invalid (flagged by the compiler) for variables       *)
(*    of type ANYPTR or ANYFILE; two new error messages 187         *)
(*    and 188                                                       *)
(*                                                                  *)
(*  - new error message 182 for var parameters with                 *)
(*    different lengths (was 142); this error is supressed          *)
(*    when file arguments are passed to ANYFILE parameters          *)
(*    (ANYFILEs variables have no file buffers, so they             *)
(*    are shorter than other file variables)                        *)
(*                                                                  *)
(*  - yet to be done: a function that tells if an ANYFILE           *)
(*    variable is a TEXT or a binary file; a function that          *)
(*    returns the size and the address of the file buffer           *)
(*    of an ANYFILE variable. What should already work with         *)
(*    ANYFILEs: functions like ASSIGN, REWRITE, RESET, CLOSE,       *)
(*    GET, PUT, and FILEFCB, which returns the address of the       *)
(*    Pascal FCB of the file. Maybe: a function that casts          *)
(*    an ANYFILE variable to a variable of type TEXT (so that       *)
(*    functions requiring TEXT files can be used on ANYFILES).      *)
(*                                                                  *)
(********************************************************************)
(*                                                                  *)
(*  Jun.2017 - Extensions to the Compiler by Bernd Oppolzer         *)
(*             (berndoppolzer@yahoo.com)                            *)
(*                                                                  *)
(*  - Character constants may be coded in hexadecimal and           *)
(*    binary (X'nn', B'bbbbbbbb'); this is a large topic and        *)
(*    not yet finished completely                                   *)
(*                                                                  *)
(*  - The implementation of sets will be reworked completely;       *)
(*    larger sets will be allowed (up to 2000 elements), and        *)
(*    some restrictions regarding set limits will be dropped        *)
(*                                                                  *)
(********************************************************************)



const VERSION = '08.2017' ;
      PAGESIZE = 55 ;

      (******************************************)
      (* MAX # OF LINES PER PAGE OF LISTING     *)
      (******************************************)

      MAXINT = 2147483647 ;
      MAXADDR = 16777215 ;

      (******************************************)
      (* LARGEST ELEMENT USED IN THIS CODE      *)
      (******************************************)

      BUFLEN = 122 ;

      (******************************************)
      (* MAX LINE LENGTH + 2                    *)
      (******************************************)

      INTSIZE = 4 ;
      HINTSIZE = 2 ;
      REALSIZE = 8 ;
      CHARSIZE = 1 ;
      MXDATASZE = 8 ;
      BOOLSIZE = 1 ;
      WORDSIZE = 4 ;

      (*****************************************)
      (*  some more size constants             *)
      (*****************************************)

      PTRSIZE = 4 ;
      FILHDRSIZE = 8 ;
      FILMINSIZE = 12 ;
      REALLNGTH = 20 ;

      (******************************************)
      (* STRING REPRESENTATION OF REAL NUMBERS  *)
      (******************************************)

      DIGMAX = 19 ;

      (******************************************)
      (* REALLNGTH - 1                          *)
      (******************************************)

      IDLNGTH = 20 ;
      ALFALNGTH = 10 ;
      MAXSTRL = 254 ;
      DISPLIMIT = 20 ;
      MAX_BKT = 58 ;

      (******************************************)
      (* HASH TABLE SIZE                        *)
      (******************************************)

      MAXLEVEL = 9 ;
      ORDCHMAX = 255 ;

      (******************************************)
      (* SIZE OF CHAR SET OF TARGET MACHINE     *)
      (******************************************)

      OPMAX = 80 ;

      (*****************)
      (* OPCODE RANGE  *)
      (*****************)

      MAXERRNR = 401 ;

      (******************************************)
      (* MAX VAL OF ERROR CODE                  *)
      (******************************************)

      MAXERRLOG = 8 ;

      (******************************************)
      (* > (MAXERRNR DIV SETMAX)                *)
      (******************************************)

      MAXRW = 50 ;

      (******************************************)
      (* room for 50 reserved words             *)
      (******************************************)

      MAXRWLEN = 9 ;

      (*****************************************)
      (* longest reserved word has length = 9  *)
      (* controls size of table frw            *)
      (*****************************************)

      CTRMAX = 16384 ;
      EXTNAMSZ = 8 ;

      (***********************************************)
      (* EXTERNAL NAME LENGTH                        *)
      (* SAVE AREAS, FUNCTION RETURN VALUE SPACE,    *)
      (* DISPLAY AREA, ETC.                          *)
      (***********************************************)

      LCAFTMST = 80 ;
      FPSAVEAREA = 32 ;
      RUNCHKAREA = 96 ;
      DISPADR = 80 ;
      FNCRSLT = 72 ;
      DISPAREA = 40 ;
      FIRSTCONSTLC = 16 ;
      FIRSTFILBUF = 248 ;

      (******************************************)
      (* = LCAFTMST + RUNCHKAREA + DSPLYAREA    *)
      (******************************************)

      TIMEDATELOC = 328 ;

      (******************************************)
      (* LOCATION OF TIME/DATE PREDEF. VARS     *)
      (******************************************)

      OSPARMLOC = 348 ;

      (******************************************)
      (* LOCATION FOR 'OSPARM' PTR.             *)
      (******************************************)

      FIRSTGVAR = 352 ;

      (******************************************)
      (* FIRST USER DEFINED GLOBAL VARIABLE     *)
      (******************************************)

      CHLBRACE = '{' ;

      (******************************************)
      (* LEFT CURLY BRACKET: EBCDIC HEX CODE C0 *)
      (******************************************)

      CHRBRACE = '}' ;

      (*******************************************)
      (* RIGHT CURLY BRACKET: EBCDIC HEX CODE D0 *)
      (* portable_branchtable: new style of B.T. *)
      (* cixmax: maximum difference of highest   *)
      (* and lowest case label                   *)
      (*******************************************)

      PORTABLE_BRANCHTABLE = TRUE ;
      CIXMAX = 400 ;

      (***************************************************)
      (* old set maximum, still used by some             *)
      (* errlog routines                                 *)
      (***************************************************)

      OLDSETMAX = 63 ;

      (***************************************************)
      (* new set related constants                       *)
      (* maxsetl = maximum set length in bytes (netto)   *)
      (* setmaxsize = maximum set length in bits         *)
      (* setupplimit = upper limit for setmax            *)
      (* setlowlimit = lower limit for setmin            *)
      (*    (setupplimit - setlowlimit) div 8 has to be  *)
      (*    stored in 3 bytes internally ...             *)
      (***************************************************)

      MAXSETL = 252 ;
      SETMAXSIZE = 2000 ;
      SETUPPLIMIT = 64000000 ;
      SETLOWLIMIT = - 64000000 ;


type ALPHA = array [ 1 .. IDLNGTH ] of CHAR ;
     EXTNAMTP = array [ 1 .. EXTNAMSZ ] of CHAR ;
     SET_CHAR = set of CHAR ;

     (******************)
     (* BASIC SYMBOLS  *)
     (******************)

     SYMBOL = ( IDENT , INTCONST , REALCONST , STRINGCONST , NOTSY ,
              MULOP , ADDOP , RELOP , LPARENT , RPARENT , LBRACK ,
              RBRACK , COMMA , SEMICOLON , PERIOD , ARROW , COLON ,
              DOTDOT , BECOMES , LABELSY , CONSTSY , TYPESY , VARSY ,
              FUNCSY , PROGSY , PROCSY , SETSY , PACKEDSY , ARRAYSY ,
              RECORDSY , FILESY , FORWARDSY , BEGINSY , IFSY , CASESY ,
              REPEATSY , WHILESY , FORSY , WITHSY , GOTOSY , ENDSY ,
              ELSESY , UNTILSY , OFSY , DOSY , TOSY , DOWNTOSY , THENSY
              , FRTRNSY , EXTRNSY , OTHERWISESY , OTHERSY , BREAKSY ,
              CONTINUESY , RETURNSY , MODULESY , LOCALSY , STATICSY ,
              NOTUSED ) ;
     OPERSYMB = ( MUL , RDIV , ANDOP , IDIV , IMOD , PLUS , MINUS ,
                OROP , XOROP , LTOP , LEOP , GEOP , GTOP , NEOP , EQOP
                , INOP , NOOP , ATOZCH , NUMCH , QUOTCH , DQUOTCH ,
                COLONCH , DOTCH , LPARCH , RPARCH , LBRACE , UNDSCH ,
                DOLLARCH , SKIPCH , SPECH , ILLEGCH ) ;

     (***********************************)
     (* some set related definitions    *)
     (***********************************)

     SSETINX = 1 .. 4 ;
     SSETRANGE = set of 0 .. OLDSETMAX ;
     SETRANGE = array [ SSETINX ] of SSETRANGE ;
     SETOFSYS = set of SYMBOL ;
     SETSTRING = array [ 1 .. MAXSETL ] of CHAR ;

     (******************)
     (* CONSTANTS      *)
     (******************)

     CSTCLASS = ( XINT , REEL , PSET , STRG ) ;

     /********************************************************/
     /* neue darstellung fuer konstanten                     */
     /* typ valu entfaellt                                   */
     /* basis ist kurze einfache struktur                    */
     /* lange bereiche fuer sets und strings werden erst     */
     /* bei bedarf dazugeholt                                */
     /********************************************************/

     SSP = -> XSTRCON ;
     XSTRCON = record
                 LENGTH : INTEGER ;
                 case TAG : CHAR of
                   'S' :
                     ( SSTR : array [ 1 .. MAXSTRL ] of CHAR ) ;
                   'P' :
                     ( PSTR : SETSTRING )
               end ;
     CONSTP = -> XCONSTANT ;
     XCONSTANT = record
                   STRTYPE : CHAR ;
                   case CSTCLASS of
                     XINT :
                       ( IVAL : INTEGER ) ;
                     REEL :
                       ( RVAL : array [ 1 .. REALLNGTH ] of CHAR ) ;
                     PSET :
                       ( SETMIN : INTEGER ;
                         SETMAX : INTEGER ;
                         SETOFFS : INTEGER ;
                         PVAL : SSP ) ;
                     STRG :
                       ( SVAL : SSP )
                 end ;

     (********************)
     (* DATA STRUCTURES  *)
     (********************)

     LEVRANGE = 0 .. MAXLEVEL ;
     ADDRRANGE = 0 .. MAXADDR ;
     ALNRNG = 1 .. 8 ;
     LABELRNG = 0 .. 1000 ;
     BKT_RNG = 0 .. MAX_BKT ;

     (*************************************************)
     (* variant structure typerec for type definition *)
     (*************************************************)

     TTP = -> TYPEREC ;
     IDP = -> IDENTIFIER ;

     (**********************)
     (* basic type classes *)
     (**********************)

     TYPECLASS = ( SCALAR , SUBRANGE , POINTER , POWER , CHARSTRING ,
                 ARRAYS , RECORDS , FILES , TAGFLD , VARIANT ) ;
     DECLKIND = ( STANDARD , DECLARED ) ;
     TYPEREC = record
                 SIZE : ADDRRANGE ;

     (********************)
     (* ALIGNMENT FACTOR *)
     (********************)

                 ALN : ALNRNG ;
                 case FORM : TYPECLASS of
                   SCALAR :
                     ( case SCALKIND : DECLKIND of
                         DECLARED :
                           ( FCONST : IDP ;
                             LITOFFS : ADDRRANGE ;
                             CSTNAME : EXTNAMTP ) ) ;
                   SUBRANGE :
                     ( RANGETYPE : TTP ;
                       MIN , MAX : XCONSTANT ) ;
                   POINTER :
                     ( ELTYPE : TTP ) ;

     (********************************************)
     (* new fields for set definition - 06.2017  *)
     (* elset   = base type of set (subrange,    *)
     (*           scalar, maybe char)            *)
     (* setmin  = minimum value for set          *)
     (* setmax  = maximum value for set          *)
     (* setoffs = where bit string starts        *)
     (*           (minimum value div 8)          *)
     (********************************************)

                   POWER :
                     ( ELSET : TTP ;
                       SETMIN : INTEGER ;
                       SETMAX : INTEGER ;
                       SETOFFS : INTEGER ) ;
                   ARRAYS :
                     ( AELTYPE , INXTYPE : TTP ) ;
                   RECORDS :
                     ( FSTFLD : IDP ;
                       RECVAR : TTP ;
                       NO_FLDS : 0 .. 1000 ;
                       FLD_DISP_LEV : - 1 .. DISPLIMIT ) ;
                   FILES :
                     ( FILTYPE : TTP ) ;
                   TAGFLD :
                     ( TAGFIELDP : IDP ;
                       FSTVAR : TTP ) ;
                   VARIANT :
                     ( NXTVAR , SUBVAR : TTP ;
                       FSTSUBFLD : IDP ;
                       VARVAL : XCONSTANT )
               end ;

     (**************************************************)
     (* type to store set constant infos temporarily   *)
     (**************************************************)

     PSETINFO = -> SETINFO_TEMP ;
     SETINFO_TEMP = record
                      ELEMCOUNT : INTEGER ;
                      SETMIN : INTEGER ;
                      SETMAX : INTEGER ;
                      RANGEERR : INTEGER ;
                      SETELEMS : array [ 1 .. SETMAXSIZE ] of BOOLEAN ;
                      CHARTYPE : BOOLEAN ;
                      HEXORBIN : CHAR ;
                      CONST_IN_SET : INTEGER ;
                      VARS_IN_SET : INTEGER ;
                      MODUS : CHAR ;
                    end ;

     (******************************)
     (* identifier classes         *)
     (******************************)

     IDCLASS = ( TYPES , KONST , STRUCTKONST , VARS , FIELD , PROC ,
               FUNC ) ;
     SETOFIDS = set of IDCLASS ;

     (******************************)
     (* standard procedures        *)
     (******************************)

     CSPTYPE = ( PPAG , PGET , PPUT , PRES , PREW , PRDC , PWRI , PWRE
               , PWRR , PWRC , PWRS , PWRX , PRDB , PWRB , PRDR , PRDH
               , PRDY , PEOL , PEOT , PRDD , PWRD , PCLK , PWLN , PRLN
               , PRDI , PEOF , PELN , PRDS , PTRP , PXIT , PFDF , PSIO
               , PEIO , PMSG , PSKP , PLIM , PTRA , PWRP , PCLS , PDAT
               , PTIM , PFLR , PTRC , PRND , UNDEF_CSP ) ;

     (******************************)
     (* types of parameters        *)
     (******************************)

     IDKIND = ( ACTUAL , FORMAL ) ;

     (******************************)
     (* storage classes            *)
     (******************************)

     STORAGE_CLASS = ( XAUTO , XSTATIC ) ;

     (******************************)
     (* identifier entries         *)
     (******************************)

     IDENTIFIER = record
                    NAME : ALPHA ;
                    IDTYPE : TTP ;
                    NEXT_IN_BKT , NEXT : IDP ;
                    DECL_LEV : LEVRANGE ;
                    case KLASS : IDCLASS of
                      KONST :
                        ( VALUES : XCONSTANT ) ;
                      STRUCTKONST :
                        ( SKOWNERPROC : EXTNAMTP ;
                          SKADDR : ADDRRANGE ) ;
                      VARS :
                        ( VKIND : IDKIND ;
                          VLEV : LEVRANGE ;
                          STKLASS : STORAGE_CLASS ;
                          VOWNERPROC : EXTNAMTP ;
                          VADDR : ADDRRANGE ;
                          SPECIAL : INTEGER ) ;
                      FIELD :
                        ( FLDADDR : ADDRRANGE ;
                          OWNER : TTP ) ;
                      PROC , FUNC :
                        ( case PFDECKIND : DECLKIND of
                            STANDARD :
                              ( KEY : INTEGER ;
                                LIBNAME : EXTNAMTP ;
                                FUNCCODE : INTEGER ;
                                PARMCNT : INTEGER ;
                                PROCTYP : CHAR ) ;
                            DECLARED :
                              ( PFLEV : INTEGER ;
                                PFNAME : LABELRNG ;
                                PRMPTR , NXTFWRD : IDP ;
                                PFKIND : IDKIND ;
                                FWDECL , EXTRN , FRTRN : BOOLEAN ;
                                DECLMISSING : BOOLEAN ;
                                EXTNAME : EXTNAMTP ;
                                CSTNAME : EXTNAMTP ) )
                  end ;
     DISPRANGE = 0 .. DISPLIMIT ;
     HASH_TABLE = array [ BKT_RNG ] of IDP ;
     WHERE = ( BLCK , CREC , VREC , REC ) ;

     (******************)
     (* EXPRESSIONS    *)
     (******************)

     ATTRKIND = ( CST , VARBL , EXPR ) ;
     VACCESS = ( DRCT , INDRCT , INXD , STKEXPR ) ;
     ATTR = record

     (*********************************)
     (* TYPE AS AN EXPR. ON RUN-STACK *)
     (*********************************)

              TYPTR : TTP ;

     (*********************************)
     (* TYPE AS A VARIABLE IN MEMORY  *)
     (*********************************)

              BTYPE : TTP ;
              case KIND : ATTRKIND of
                CST :
                  ( CVAL : XCONSTANT ) ;
                VARBL :
                  ( case ACCESS : VACCESS of
                      DRCT :
                        ( VLEVEL : LEVRANGE ;
                          DPLMT : ADDRRANGE ) ;
                      INDRCT :
                        ( IDPLMT : ADDRRANGE ) ;
                      STKEXPR :
                        ( STKDPLMT , STKLEN : ADDRRANGE ) )
            end ;
     TESTP = -> TESTPOINTER ;
     TESTPOINTER = record
                     ELT1 , ELT2 : TTP ;
                     LASTTESTP : TESTP
                   end ;

     (*************)
     (* LABELS    *)
     (*************)

     LBP = -> LABL ;
     LABL = record
              NEXTLAB : LBP ;
              LABVAL : INTEGER ;
              LABNAME , XNO : LABELRNG ;
              DEFINED : BOOLEAN
            end ;
     FRECPTR = -> FILEREC ;
     FILEREC = record
                 FILIDPTR : IDP ;
                 NEXTFILE : FRECPTR ;
               end ;
     PRNTTYLISTP = -> PRNTTYLIST ;
     PRNTTYLIST = record
                    ELT : TTP ;
                    TNO : 0 .. 999 ;
                    NXT : PRNTTYLISTP
                  end ;
     ERRCODE = 0 .. MAXERRNR ;
     CTRRANGE = 0 .. CTRMAX ;
     CTRTYPE = ( CTRPROC , CTRLBL , CTRGOTO , CTRIF , CTRWHILE ,
               CTRREPEAT , CTRFOR , CTRCASE ) ;
     LOOPCTL = record
                 LEVEL : INTEGER ;
                 BREAKLABEL : LABELRNG ;
                 BREAKUSED : BOOLEAN ;
                 CONTLABEL : LABELRNG ;
                 CONTUSED : BOOLEAN ;
               end ;
     SUBRCTL = record
                 RETURNLABEL : LABELRNG ;
                 RETURNUSED : BOOLEAN ;
               end ;

     (********************************************)
     (* zum Anschauen von TYPECLASS Inhalten     *)
     (********************************************)

     FORMTEST = record
                  case BOOLEAN of
                    FALSE :
                      ( X1 : 0 .. 32000 ) ;
                    TRUE :
                      ( X2 : TYPECLASS ) ;
                end ;


var TRACEF : TEXT ;
    LISTING : TEXT ;
    DBGINFO : TEXT ;
    SOURCENAME : EXTNAMTP ;
    SX : INTEGER ;

    /*****************/
    /* some new vars */
    /*****************/

    DUMMYBOOL : BOOLEAN ;

    (*******************************************************)
    (*RETURNED BY SOURCE PROGRAM SCANNER    INSYMBOL:      *)
    (*                                      *********      *)
    (*******************************************************)

    SY : SYMBOL ;

    (******************************************)
    (*LAST SYMBOL                             *)
    (******************************************)

    OP : OPERSYMB ;

    (******************************************)
    (*CLASSIFICATION OF LAST SYMBOL           *)
    (******************************************)

    VAL : XCONSTANT ;

    (******************************************)
    (*VALUE OF LAST CONSTANT                  *)
    (******************************************)

    LNGTH : INTEGER ;

    (******************************************)
    (*LENGTH OF LAST STRING CONSTANT          *)
    (******************************************)

    PROGNAME , ID : ALPHA ;
    NAME_PATTERN : ALPHA ;

    (******************************************)
    (*LAST IDENTIFIER (POSSIBLY TRUNCATED)    *)
    (******************************************)

    CH : CHAR ;

    (******************************************)
    (*LAST CHARACTER READ                     *)
    (******************************************)

    EOL : BOOLEAN ;

    (******************************************)
    (* END OF LINE FLAG                       *)
    (*                                        *)
    (* COUNTERS:                              *)
    (* *********                              *)
    (******************************************)

    CHCNT : 0 .. BUFLEN ;

    (******************************************)
    (* CHARACTER COUNTER                      *)
    (******************************************)

    CONSTLCOUNTER , LCOUNTER , ICOUNTER , OLDICOUNTER : ADDRRANGE ;
    STRCOUNTER : ADDRRANGE ;

    (***********************************************************)
    (* CONSTLCOUNTER = DATA LOC. FOR STRUCTURED CONSTANTS      *)
    (* LCOUNTER      = DATA LOCATION                           *)
    (* ICOUNTER      = INSTRUCTION COUNTER                     *)
    (* OLDICOUNTER   = OLD INSTRUCTION COUNTER                 *)
    (* STRCOUNTER    = STRING INSTRUCTION COUNTER              *)
    (***********************************************************)

    LINECNT , OLDLN , PLCNT , ERRLN , PAGECNT , LASTLINELISTED :
                                                   INTEGER ;

    (******************************************)
    (* SWITCHES:                              *)
    (* *********                              *)
    (******************************************)

    HP : BOOLEAN ;

    (******************************************)
    (* HEADER PART                            *)
    (******************************************)

    DOTFLG : BOOLEAN ;

    (******************************************)
    (* ONE DOT ALREADY SEEN                   *)
    (******************************************)

    ASSIGN , PACKDATA : BOOLEAN ;

    (******************************************)
    (* ASSIGNMENT GOING ON,PACKING IN EFFECT  *)
    (******************************************)

    LIST , PRCODE : BOOLEAN ;

    (******************************************)
    (* LIST SOURCE, OUTPUT P-CODE             *)
    (******************************************)

    DEBUG , MWARN : BOOLEAN ;

    (******************************************)
    (* DEBUG CODE WANTED, MARGINS WARNING     *)
    (******************************************)

    FLIPDEBUG , NOPACKING : BOOLEAN ;

    (******************************************)
    (* DEBUG FLIPPED, PACKING SUPPRESSED      *)
    (******************************************)

    NESTCOMM : BOOLEAN ;

    (******************************************)
    (* NESTED COMMENTS ALLOWED                *)
    (******************************************)

    WARNING , EXTUSED : BOOLEAN ;

    (******************************************)
    (* WARNINGS WANTED, EXTENSIONS USED       *)
    (******************************************)

    ASSEMBLE , ASMVERB : BOOLEAN ;

    (******************************************)
    (* POSTPROCESSOR TRANSLATION, VERBOSE     *)
    (******************************************)

    IS_MODULE : BOOLEAN ;

    (******************************************)
    (* true, if source is a module            *)
    (******************************************)

    GET_STAT , SAVEREGS , SAVEFPRS : BOOLEAN ;
    LISTTAG : CHAR ;

    (******************************************)
    (* LISTING TAG, 'D'/'C'/'N'/' '           *)
    (******************************************)

    DEBUG_LEV : 0 .. 9 ;

    (******************************************)
    (*POINTERS:                               *)
    (**********                               *)
    (******************************************)

    INPUTPTR , OUTPUTPTR : IDP ;

    (************************************)
    (* PREDEFINED FILES INPUT + OUTPUT  *)
    (************************************)

    INTPTR , REALPTR , CHARPTR , BOOLPTR , ANYPTR , ANYFILEPTR ,
    TEXTPTR , ALFAPTR : TTP ;

    (******************************************)
    (*POINTERS TO ENTRIES OF STANDARD IDS     *)
    (******************************************)

    UTYPPTR , UCSTPTR , UVARPTR , UFLDPTR , UPRCPTR , UFCTPTR ,

    (*****************************************)
    (*POINTERS TO ENTRIES FOR UNDECLARED IDS *)
    (*****************************************)


    MAINPROG ,

    (******************************************)
    (*POINTER TO $PASMAIN ENTRY               *)
    (******************************************)


    FRTPARHD ,

    (******************************************)
    (*POINTER TO LIST OF FORTRAN PROC PARMS   *)
    (******************************************)


    FWPTR : IDP ;

    (******************************************)
    (*HEAD OF CHAIN OF FORW DECL TYPE IDS     *)
    (******************************************)

    FILEHEAD : FRECPTR ;

    (******************************************)
    (*HEAD OF CHAIN OF EXTERNAL FILES         *)
    (******************************************)

    OPEN_RECORD : TTP ;

    (******************************************)
    (*CURRENT RECORD OPENED BY "WITH"         *)
    (******************************************)

    GLOBTESTP : TESTP ;

    (******************************************)
    (*LAST TESTPOINTER                        *)
    (******************************************)

    PRNTTYPHD : PRNTTYLISTP ;

    (******************************************)
    (*LIST OF HEAP STORAGE ITEMS FOR DEBUG    *)
    (******************************************)

    PRNTTYNO : 0 .. 999 ;

    (******************************************)
    (*BOOKKEEPING OF DECLARATION LEVELS:      *)
    (***********************************      *)
    (******************************************)

    LEVEL : LEVRANGE ;

    (******************************************)
    (*CURRENT STATIC LEVEL                    *)
    (******************************************)

    STMTNEST : 0 .. 100 ;

    (******************************************)
    (*CURRENT STATEMENT NESTING               *)
    (******************************************)

    DISX ,

    (******************************************)
    (*LEVEL OF LAST ID SEARCHED BY SEARCHID   *)
    (******************************************)


    TOP : - 1 .. DISPLIMIT ;

    (******************************************)
    (*TOP OF DISPLAY                          *)
    (******************************************)

    DISPLAY :

    (******************************************)
    (*WHERE:   MEANS:                         *)
    (******************************************)


    array [ DISPRANGE ] of record

    (*******************************************)
    (*=BLCK:   ID IS VARIABLE ID               *)
    (*                                         *)
    (*******************************************)

                             case OCCUR : WHERE of

    (******************************************)
    (*=CREC:   ID IS FIELD ID IN RECORD WITH  *)
    (******************************************)

                               BLCK :
                                 ( FLABEL : LBP ) ;

    (******************************************)
    (*         CONSTANT ADDRESS               *)
    (******************************************)

                               CREC :
                                 ( CLEV : LEVRANGE ;

    (******************************************)
    (*=VREC:   ID IS FIELD ID IN RECORD WITH  *)
    (******************************************)

                                   CDSPL : ADDRRANGE ) ;

    (******************************************)
    (*         VARIABLE ADDRESS               *)
    (******************************************)

                               VREC :
                                 ( VDSPL : ADDRRANGE )
                           end ;

    (******************************************)
    (* --> PROCEDURE WITHSTATEMENT            *)
    (*RUN-TIME PROFILER COUNTERS              *)
    (***************************              *)
    (******************************************)

    CTRCNT : CTRRANGE ;
    CTRCNTLBL : LABELRNG ;
    CTROPTION : BOOLEAN ;

    (******************************************)
    (*EXPRESSION COMPILATION:                 *)
    (************************                 *)
    (******************************************)

    GATTR : ATTR ;

    (******************************************)
    (*DESCRIBES THE EXPR CURRENTLY COMPILED   *)
    (******************************************)

    MXINT10 : INTEGER ;
    PSIGLOB : PSETINFO ;

    (******************************************)
    (*BUFFERS, READ ONLY TABLES ETC.          *)
    (******************************           *)
    (******************************************)

    LSTOP : CHAR ;

    (********************************)
    (*MARKS THE BEGINNING OF LINEBUF*)
    (********************************)

    LINEBUF : array [ 1 .. BUFLEN ] of CHAR ;

    (********************************)
    (*CURRENT LINE BUFFER           *)
    (********************************)

    LMARGIN , RMARGIN , LINELEN , BUFEND , LASTCOL : 0 .. BUFLEN ;

    (********************************)
    (*LEFT, RIGHT MARGINS ant PTRS  *)
    (********************************)

    INTLABEL , PROCLAB , XLABNO : LABELRNG ;
    CALL_LVL : array [ BOOLEAN ] of INTEGER ;

    (**********************************************************)
    (*  UPSHIFT and SSY in an ideal world should cover        *)
    (*  the whole range of characters / B.Oppolzer - 2016     *)
    (**********************************************************)
    (*  must include all chars for port to Windows / Linux    *)
    (**********************************************************)

    SOP : array [ CHAR ] of OPERSYMB ;
    UPSHIFT : array [ CHAR ] of CHAR ;
    SSY : array [ CHAR ] of SYMBOL ;
    BUCKET : HASH_TABLE ;

    (******************************************)
    (* SYMBOL TABLE USAGE STATISTICS          *)
    (* ****** ***** ***** **********          *)
    (******************************************)

    FENT_CNT , SF_CNT , SF_TOT ,

    (******************************************)
    (* # FIELD ENTRIES, SEARCHES, PRODUCT     *)
    (******************************************)


    WE_CNT , RE_CNT ,

    (******************************************)
    (* # "WITH" LOOKUPS, # RECORDS            *)
    (******************************************)


    WS_CNT : INTEGER ;

    (******************************************)
    (* # WITH STATEMENTS                      *)
    (******************************************)

    PROC_CNT , ENT_CNT : array [ LEVRANGE ] of INTEGER ;
    LU_CNT : array [ LEVRANGE , DISPRANGE ] of INTEGER ;
    WLU_CNT : array [ 1 .. 10 , 1 .. 10 ] of INTEGER ;

    (******************************************)
    (*ERROR MESSAGES:                         *)
    (****************                         *)
    (******************************************)

    ERRLOG : array [ 0 .. MAXERRLOG ] of SSETRANGE ;

    (****************************)
    (* = 400 DIV OLDSETMAX + 1  *)
    (****************************)

    ERRORCNT , WARNCNT ,

    (******************************************)
    (*ERRORS AND WARNINGS COUNTS              *)
    (******************************************)


    CTIME : INTEGER ;

    (******************************************)
    (*COMPILATION TIME                        *)
    (******************************************)

    ERRINX : 0 .. 10 ;

    (******************************************)
    (*NR OF ERRORS IN CURRENT SOURCE LINE     *)
    (******************************************)

    ERRKIND : CHAR ;

    (******************************************)
    (*KIND OF ERROR, 'E' / 'W' (WARNING)      *)
    (******************************************)

    ERRLIST : array [ 1 .. 10 ] of record
                                     NMR : 1 .. 401 ;
                                     KIND : CHAR ;
                                     POS : 1 .. 81
                                   end ;

    (********************************************)
    (* STRUCTURED CONSTANTS, READ-ONLY TABLES   *)
    (* ********** *********  **** **** ******   *)
    (********************************************)



const BLANKID : ALPHA = '            ' ;
      HEXTAB : array [ 0 .. 15 ] of CHAR = '0123456789abcdef' ;
      LOW_LETTERS : SET_CHAR =
      [ 'a' .. 'i' , 'j' .. 'r' , 's' .. 'z' ] ;
      UP_LETTERS : SET_CHAR =
      [ 'A' .. 'I' , 'J' .. 'R' , 'S' .. 'Z' ] ;
      HEX_CHARS : SET_CHAR =
      [ 'a' .. 'f' , 'A' .. 'F' , '0' .. '9' ] ;
      BIN_CHARS : SET_CHAR =
      [ '0' .. '1' ] ;
      CONSTBEGSYS : SETOFSYS =
      [ ADDOP , INTCONST , REALCONST , STRINGCONST , IDENT ] ;
      SIMPTYPEBEGSYS : SETOFSYS =
      [ ADDOP , INTCONST , REALCONST , STRINGCONST , IDENT , LPARENT ]
        ;
      TYPEBEGSYS : SETOFSYS =
      [ ARROW , PACKEDSY , ARRAYSY , RECORDSY , SETSY , FILESY , ADDOP
        , INTCONST , REALCONST , STRINGCONST , IDENT , LPARENT ] ;
      TYPEDELS : SETOFSYS =
      [ ARRAYSY , RECORDSY , SETSY , FILESY , PACKEDSY ] ;
      BLOCKBEGSYS : SETOFSYS =
      [ LABELSY , CONSTSY , TYPESY , VARSY , STATICSY , PROCSY , FUNCSY
        , LOCALSY , BEGINSY ] ;
      SELECTSYS : SETOFSYS =
      [ ARROW , PERIOD , LBRACK , LPARENT ] ;
      FACBEGSYS : SETOFSYS =
      [ INTCONST , REALCONST , STRINGCONST , IDENT , LPARENT , LBRACK ,
        NOTSY ] ;
      STATBEGSYS : SETOFSYS =
      [ BEGINSY , GOTOSY , IFSY , WHILESY , REPEATSY , FORSY , WITHSY ,
        CASESY , BREAKSY , CONTINUESY , RETURNSY ] ;
      PROCCALLENDSYS : SETOFSYS =
      [ LPARENT , SEMICOLON , ENDSY , ELSESY , UNTILSY ] ;

      (*********************************************************)
      (*   new reserved symbols in the 2011 version:           *)
      (*   break, return, continue                             *)
      (*********************************************************)

      RW : array [ 1 .. MAXRW ] of ALPHA =
      ( 'IF          ' , 'DO          ' , 'OF          ' ,
        'TO          ' , 'IN          ' , 'OR          ' ,
        'END         ' , 'FOR         ' , 'VAR         ' ,
        'DIV         ' , 'MOD         ' , 'SET         ' ,
        'AND         ' , 'NOT         ' , 'XOR         ' ,
        'THEN        ' , 'ELSE        ' , 'WITH        ' ,
        'GOTO        ' , 'CASE        ' , 'TYPE        ' ,
        'FILE        ' , 'BEGIN       ' , 'UNTIL       ' ,
        'WHILE       ' , 'ARRAY       ' , 'CONST       ' ,
        'LABEL       ' , 'LOCAL       ' , 'BREAK       ' ,
        'REPEAT      ' , 'RECORD      ' , 'DOWNTO      ' ,
        'PACKED      ' , 'RETURN      ' , 'MODULE      ' ,
        'STATIC      ' , 'FORWARD     ' , 'PROGRAM     ' ,
        'FORTRAN     ' , 'EXTERNAL    ' , 'FUNCTION    ' ,
        'CONTINUE    ' , 'PROCEDURE   ' , 'OTHERWISE   ' ,
        '            ' , '            ' , '            ' ,
        '            ' , '            ' ) ;
      FRW : array [ 1 .. 12 ] of 1 .. MAXRW =

      (**********************************************************)
      (*  1  2  3    4    5    6    7    8    9   10   11   12  *)
      (**********************************************************)

      ( 1 , 1 , 7 , 16 , 23 , 31 , 38 , 41 , 44 , 46 , - 1 , - 1 ) ;
      RSY : array [ 1 .. MAXRW ] of SYMBOL =
      ( IFSY , DOSY , OFSY , TOSY , RELOP , ADDOP , ENDSY , FORSY ,
        VARSY , MULOP , MULOP , SETSY , MULOP , NOTSY , ADDOP , THENSY
        , ELSESY , WITHSY , GOTOSY , CASESY , TYPESY , FILESY , BEGINSY
        , UNTILSY , WHILESY , ARRAYSY , CONSTSY , LABELSY , LOCALSY ,
        BREAKSY , REPEATSY , RECORDSY , DOWNTOSY , PACKEDSY , RETURNSY
        , MODULESY , STATICSY , FORWARDSY , PROGSY , FRTRNSY , EXTRNSY
        , FUNCSY , CONTINUESY , PROCSY , OTHERWISESY , NOTUSED ,
        NOTUSED , NOTUSED , NOTUSED , NOTUSED ) ;
      ROP : array [ 1 .. MAXRW ] of OPERSYMB =
      ( NOOP , NOOP , NOOP , NOOP , INOP , OROP , NOOP , NOOP , NOOP ,
        IDIV , IMOD , NOOP , ANDOP , NOOP , XOROP , NOOP , NOOP , NOOP
        , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP
        , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP
        , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP , NOOP
        , NOOP , NOOP , NOOP , NOOP , NOOP ) ;
      MN : array [ 0 .. OPMAX ] of array [ 1 .. 4 ] of CHAR =
      ( ' ABI' , ' ABR' , ' ADI' , ' ADR' , ' AND' , ' DIF' , ' DVI' ,
        ' DVR' , ' SBR' , ' FLO' , ' FLT' , ' INN' , ' INT' , ' IOR' ,
        ' MOD' , ' MPI' , ' MPR' , ' NGI' , ' NGR' , ' NOT' , ' ODD' ,
        ' SBI' , ' DEC' , ' INC' , ' SQI' , ' SQR' , ' STO' , ' ---' ,
        ' ---' , ' SCL' , ' CSP' , ' UNI' , ' ENT' , ' FJP' , ' POP' ,
        ' IND' , ' IXA' , ' LCA' , ' CTS' , ' CTI' , ' MOV' , ' MST' ,
        ' RET' , ' STP' , ' XJP' , ' CHK' , ' CUP' , ' EQU' , ' GEQ' ,
        ' GRT' , ' LDA' , ' LDC' , ' LEQ' , ' LES' , ' LOD' , ' NEQ' ,
        ' STR' , ' UJP' , ' NEW' , ' SAV' , ' RST' , ' ORD' , ' CHR' ,
        ' DEF' , ' LAB' , ' CRD' , ' XPO' , ' ASE' , ' SLD' , ' SMV' ,
        ' DFC' , ' CST' , ' BGN' , ' UXJ' , ' XLB' , ' END' , ' PAK' ,
        ' ADA' , ' SBA' , ' XOR' , '    ' ) ;

      (*********************************************************)
      (*   names of CSPs, index type should be CSPTYPE,        *)
      (*   but it is indexed by ORD (CSP) in GEN1 ...          *)
      (*********************************************************)

      SNA : array [ 0 .. 47 ] of array [ 1 .. 3 ] of CHAR =
      ( 'PAG' , 'GET' , 'PUT' , 'RES' , 'REW' , 'RDC' , 'WRI' , 'WRE' ,
        'WRR' , 'WRC' , 'WRS' , 'WRX' , 'RDB' , 'WRB' , 'RDR' , 'RDH' ,
        'RDY' , 'EOL' , 'EOT' , 'RDD' , 'WRD' , 'CLK' , 'WLN' , 'RLN' ,
        'RDI' , 'EOF' , 'ELN' , 'RDS' , 'TRP' , 'XIT' , 'FDF' , 'SIO' ,
        'EIO' , 'MSG' , 'SKP' , 'LIM' , 'TRA' , 'WRP' , 'CLS' , 'DAT' ,
        'TIM' , 'FLR' , 'TRC' , 'RND' , '   ' , '   ' , '   ' , '   ' )
        ;

      (****************************************************************)
      (*------------------------------------------------------------- *)
      (****************************************************************)




procedure TOALFA ( var X : ALPHA ; Y : EXTNAMTP ) ;

   var I : INTEGER ;

   begin (* TOALFA *)
     X := BLANKID ;
     for I := 1 to EXTNAMSZ do
       X [ I ] := Y [ I ]
   end (* TOALFA *) ;



procedure WRITEHEXBYTE ( var F : TEXT ; I : INTEGER ) ;

   begin (* WRITEHEXBYTE *)
     WRITE ( F , HEXTAB [ I DIV 16 ] , HEXTAB [ I MOD 16 ] ) ;
   end (* WRITEHEXBYTE *) ;



procedure WRITEBINBYTE ( var F : TEXT ; I : INTEGER ) ;

   var X : INTEGER ;
       Y : INTEGER ;

   begin (* WRITEBINBYTE *)
     X := 128 ;
     for Y := 1 to 8 do
       begin
         if I >= X then
           begin
             WRITE ( F , '1' ) ;
             I := I - X ;
           end (* then *)
         else
           WRITE ( F , '0' ) ;
         X := X DIV 2 ;
       end (* for *)
   end (* WRITEBINBYTE *) ;



function MODP ( X : INTEGER ; Y : INTEGER ) : INTEGER ;

   var M : INTEGER ;

   begin (* MODP *)
     M := X MOD Y ;
     if M < 0 then
       M := M + Y ;
     MODP := M ;
   end (* MODP *) ;



procedure ERROR ( FERRNR : ERRCODE ) ;

(*********************)
(*MAXERRNR DIV SETMAX*)
(*********************)


   var I : 0 .. 10 ;

   begin (* ERROR *)
     if ( ERRKIND <> 'W' ) or WARNING then
       begin
         if ERRINX >= 9 then
           begin
             FERRNR := 255 ;
             ERRINX := 10
           end (* then *)
         else
           ERRINX := ERRINX + 1 ;
         with ERRLIST [ ERRINX ] do
           begin
             KIND := ERRKIND ;
             NMR := FERRNR ;
             POS := CHCNT
           end (* with *) ;
         I := FERRNR DIV ( OLDSETMAX + 1 ) ;
         ERRLOG [ I ] := ERRLOG [ I ] + [ FERRNR MOD ( OLDSETMAX + 1 )
                         ] ;
         if ERRKIND <> 'W' then
           ERRORCNT := ERRORCNT + 1
         else
           WARNCNT := WARNCNT + 1 ;
       end (* then *) ;
     ERRKIND := 'E' ;
   end (* ERROR *) ;



procedure PRINTLINE ;

   var DCN : ADDRRANGE ;

   begin (* PRINTLINE *)
     if PLCNT >= PAGESIZE then
       begin
         PAGECNT := PAGECNT + 1 ;
         PLCNT := 0 ;
         WRITELN ( LISTING , '1  LINE #  D/NEST  LVL' ,
                   '< STANFORD PASCAL, OPPOLZER VERSION OF ' : 44 ,
                   VERSION , ' >' , TIME : 14 , DATE , 'PAGE' : 8 ,
                   PAGECNT : 4 ) ;
         WRITELN ( LISTING , '------  ------  ---' : 22 , '---- ---' :
                   89 ) ;
         WRITELN ( LISTING ) ;
       end (* then *) ;
     if LINECNT > LASTLINELISTED then
       begin
         LASTLINELISTED := LINECNT ;
         PLCNT := PLCNT + 1 ;
         WRITE ( LISTING , LINECNT : 9 ) ;
         if LISTTAG = 'N' then
           DCN := STMTNEST
         else
           if LISTTAG = 'D' then
             DCN := LCOUNTER
           else
             if LISTTAG = 'S' then
               DCN := CONSTLCOUNTER
             else
               if LISTTAG = 'C' then
                 DCN := CONSTLCOUNTER
               else
                 DCN := 0 ;
         if DCN < 0 then
           DCN := 0 ;
         if ( LISTTAG in [ 'D' , 'S' , 'C' ] ) or ( DCN > 0 ) then
           WRITE ( LISTING , DCN : 7 , LISTTAG , LEVEL : 3 )
         else
           WRITE ( LISTING , ' ' : 11 ) ;
         WRITELN ( LISTING , ') ' , LINEBUF : LINELEN ) ;
       end (* then *) ;
   end (* PRINTLINE *) ;



procedure PRINTERROR ;

   var LASTPOS , FREEPOS , CURRPOS , CURRNMR , F , K , DCN : INTEGER ;
       CURRKIND , LASTKIND : CHAR ;

   begin (* PRINTERROR *)
     PRINTLINE ;
     PLCNT := PLCNT + 2 ;

     (***************************)
     (* TWO LINES OF ERROR INFO *)
     (***************************)

     WRITE ( LISTING , '****' : 9 , ' ' : 13 ) ;
     LASTPOS := 0 ;
     FREEPOS := 1 ;
     LASTKIND := '?' ;
     for K := 1 to ERRINX do
       begin
         with ERRLIST [ K ] do
           begin
             CURRPOS := POS ;
             CURRNMR := NMR ;
             CURRKIND := KIND
           end (* with *) ;
         if CURRPOS = LASTPOS then
           if CURRKIND = LASTKIND then
             WRITE ( LISTING , ',' )
           else
             WRITE ( LISTING , CURRKIND )
         else
           begin
             LASTKIND := CURRKIND ;
             while FREEPOS < CURRPOS do
               begin
                 WRITE ( LISTING , ' ' ) ;
                 FREEPOS := FREEPOS + 1
               end (* while *) ;
             WRITE ( LISTING , CURRKIND ) ;
             LASTPOS := CURRPOS
           end (* else *) ;
         if CURRNMR < 10 then
           F := 1
         else
           if CURRNMR < 100 then
             F := 2
           else
             F := 3 ;
         WRITE ( LISTING , CURRNMR : F ) ;
         FREEPOS := FREEPOS + F + 1
       end (* for *) ;
     WRITELN ( LISTING ) ;
     ERRINX := 0 ;
     if ERRORCNT > 0 then
       PRCODE := FALSE ;
     if ERRLN > 0 then
       WRITELN ( LISTING , '****' : 9 ,
                 '  PREVIOUS ERROR/WARNING ON LINE -->' , ERRLN : 4 ) ;
     ERRLN := LINECNT ;
   end (* PRINTERROR *) ;



procedure ENDOFLINE ;

   label 10 ;

   var I : 1 .. 9 ;
       DCN : INTEGER ;

   begin (* ENDOFLINE *)
     if ERRINX > 0 then
       PRINTERROR ;
     READLN ( INPUT , LINEBUF ) ;
     LINELEN := BUFEND ;

     (*******************************************************)
     (*THIS WILL SPEED THINGS UP IF NO MARGIN IS SET/RESET  *)
     (*$D-  ... MUST BE IN EFFECT FOR THIS LOOP             *)
     (*******************************************************)

     repeat
       LINELEN := LINELEN - 1 ;
     until LINEBUF [ LINELEN ] <> ' ' ;

     (***********************************************************)
     (* IF NEEDED, DEBUG SWITCH SHOULD BE RESTORED HERE ---> $D+*)
     (***********************************************************)

     10 :
     if LINELEN > RMARGIN then
       begin
         MWARN := TRUE ;
         LASTCOL := RMARGIN
       end (* then *)
     else
       LASTCOL := LINELEN ;
     LINECNT := LINECNT + 1 ;
     if LIST then
       PRINTLINE ;
     if HP then
       begin
         ICOUNTER := 0 ;
         LISTTAG := ' ' ;
         HP := FALSE
       end (* then *) ;
     LINEBUF [ LASTCOL + 1 ] := '#' ;

     (********************************************)
     (*TO STOP 'SKIPBLNK' + PROVIDE VALID EOL CH.*)
     (********************************************)

     CHCNT := LMARGIN ;
   end (* ENDOFLINE *) ;



procedure LISTMSGS ;

   var I , J : ERRCODE ;
       MSG : array [ 1 .. 64 ] of CHAR ;

   begin (* LISTMSGS *)
     WRITELN ( OUTPUT ) ;
     if ERRLN > 0 then
       begin
         WRITELN ( OUTPUT , '****' : 9 ,
                   '  LAST ERROR/WARNING ON LINE -->' , ERRLN : 4 ) ;
         WRITELN ( OUTPUT ) ;
       end (* then *) ;
     WRITELN ( OUTPUT , '****' : 9 ,
               '  ERROR/WARNING CODES FOR THIS PROGRAM :' ) ;
     WRITELN ( LISTING ) ;
     if ERRLN > 0 then
       begin
         WRITELN ( LISTING , '****' : 9 ,
                   '  LAST ERROR/WARNING ON LINE -->' , ERRLN : 4 ) ;
         WRITELN ( LISTING ) ;
       end (* then *) ;
     WRITELN ( LISTING , '****' : 9 ,
               '  ERROR/WARNING CODES FOR THIS PROGRAM :' ) ;
     RESET ( PRD ) ;
     J := 0 ;
     for I := 1 to MAXERRNR do
       if ( I MOD ( OLDSETMAX + 1 ) ) in ERRLOG [ I DIV ( OLDSETMAX + 1
       ) ] then
         begin
           while ( not EOF ( PRD ) ) and ( I > J ) do
             READLN ( PRD , J , MSG ) ;
           if J = I then
             begin
               WRITELN ( '****' : 9 , J : 6 , MSG ) ;
               WRITELN ( LISTING , '****' : 9 , J : 6 , MSG ) ;
             end (* then *)
         end (* then *) ;
   end (* LISTMSGS *) ;



procedure GOODBYE ;

   begin (* GOODBYE *)
     CTIME := ( CLOCK ( 0 ) - CTIME ) ;
     WRITELN ( OUTPUT , '****' : 9 ,
               ' STANFORD PASCAL COMPILER, OPPOLZER VERSION OF ' ,
               VERSION ) ;
     WRITELN ( OUTPUT ) ;
     if WARNING then
       begin
         if EXTUSED then
           WRITELN ( OUTPUT , '****' : 9 ,
                     ' WARNING: PASCAL EXTENSIONS USED.' ) ;
         if WARNCNT > 0 then
           WRITELN ( OUTPUT , '****' : 9 , WARNCNT : 8 ,
                     ' WARNING MESSAGE(S) ISSUED.' ) ;
         if MWARN then
           WRITELN ( OUTPUT , '****' : 9 ,
                     ' CONTENTS OF SOURCE LINES OUTSIDE  ' , LMARGIN :
                     1 , '..' , RMARGIN : 1 , '  MARGINS IGNORED.' ) ;
       end (* then *) ;
     if ERRORCNT = 0 then
       WRITE ( OUTPUT , '****      NO' : 17 )
     else
       WRITE ( OUTPUT , '****' : 9 , ERRORCNT : 8 ) ;
     WRITELN ( OUTPUT , ' SYNTAX ERROR(S) DETECTED.' ) ;
     WRITELN ( OUTPUT , '****' : 9 , LINECNT : 8 , ' LINE(S) READ, ' ,
               PROCLAB : 4 , ' PROCEDURE(S) COMPILED,' ) ;
     WRITELN ( OUTPUT , '****' : 9 , OLDICOUNTER : 8 ,
               ' P_INSTRUCTIONS GENERATED,' , CTIME * 0.001 : 7 : 2 ,
               ' SECONDS IN COMPILATION.' ) ;
     WRITELN ( LISTING ) ;
     if WARNING then
       begin
         if EXTUSED then
           WRITELN ( LISTING , '****' : 9 ,
                     ' WARNING: PASCAL EXTENSIONS USED.' ) ;
         if WARNCNT > 0 then
           WRITELN ( LISTING , '****' : 9 , WARNCNT : 8 ,
                     ' WARNING MESSAGE(S) ISSUED.' ) ;
         if MWARN then
           WRITELN ( LISTING , '****' : 9 ,
                     ' CONTENTS OF SOURCE LINES OUTSIDE  ' , LMARGIN :
                     1 , '..' , RMARGIN : 1 , '  MARGINS IGNORED.' ) ;
       end (* then *) ;
     if ERRORCNT = 0 then
       WRITE ( LISTING , '****      NO' : 17 )
     else
       WRITE ( LISTING , '****' : 9 , ERRORCNT : 8 ) ;
     WRITELN ( LISTING , ' SYNTAX ERROR(S) DETECTED.' ) ;
     WRITELN ( LISTING , '****' : 9 , LINECNT : 8 , ' LINE(S) READ, ' ,
               PROCLAB : 4 , ' PROCEDURE(S) COMPILED,' ) ;
     WRITELN ( LISTING , '****' : 9 , OLDICOUNTER : 8 ,
               ' P_INSTRUCTIONS GENERATED,' , CTIME * 0.001 : 7 : 2 ,
               ' SECONDS IN COMPILATION.' ) ;
     if ( ERRORCNT > 0 ) or ( WARNCNT > 0 ) then
       LISTMSGS ;
     EXIT ( ERRORCNT ) ;
   end (* GOODBYE *) ;



procedure FATALERROR ( CODE : ERRCODE ) ;

   begin (* FATALERROR *)
     ERROR ( CODE ) ;
     PRINTERROR ;
     if CODE <> 390 then
       WRITELN ( LISTING , '0    ****   FATAL ERROR - ' ,
                 'COMPILATION TERMINATED PREMATURELY.' ) ;
     GOODBYE ;
   end (* FATALERROR *) ;



procedure INSYMBOL ;

(**************************************************************)
(*                                                            *)
(*   READ NEXT BASIS SYMBOL OF SOURCE PROGRAM AND RETURN      *)
(*   ITS DESCRIPTION IN THE GLOBAL VARIABLES                  *)
(*   SY, OP, ID, VAL AND LNGTH                                *)
(*                                                            *)
(*------------------------------------------------------------*)
(*                                                            *)
(*   REWORKED 24.10.2011 - BERND OPPOLZER                     *)
(*                                                            *)
(*   ADDED THE FOLLOWING SYMBOL SPELLINGS:                    *)
(*                                                            *)
(*   (. AND .) AS ANOTHER POSSIBILITY FOR [ ] AND (/ /)       *)
(*                                                            *)
(*   -> AS AN ALTERNATIVE FOR @                               *)
(*                                                            *)
(*   COMMENTS ALSO LIKE THIS: /* ... COMMENT ... */           *)
(*                                                            *)
(**************************************************************)


   label 1 , 2 , 3 ;

   var I , K , STATE : INTEGER ;
       DIGIT : array [ 1 .. REALLNGTH ] of CHAR ;
       XSTRING : array [ 1 .. MAXSTRL ] of CHAR ;
       LVP : CONSTP ;
       TEST , DIGSEEN : BOOLEAN ;
       CHSAVE : CHAR ;


   procedure SKIPBLNK ;

   (******************************************************)
   (*   SKIP BLANKS, ENDOFLINE, AND (OPTIONAL) MARGIN,   *)
   (*   SKIPS AT LEAST ONE LINE                          *)
   (******************************************************)


      begin (* SKIPBLNK *)
        repeat
          if EOL then
            begin
              if EOF ( INPUT ) then
                FATALERROR ( 390 ) ;
              ENDOFLINE ;
            end (* then *) ;
          repeat
            CHCNT := CHCNT + 1 ;
          until LINEBUF [ CHCNT ] <> ' ' ;

        (********************************************)
        (*   NOTE THAT LINEBUF[LINELEN+1] <> ' '    *)
        (********************************************)

          EOL := CHCNT > LASTCOL ;
        until not EOL ;
        CH := LINEBUF [ CHCNT ] ;
      end (* SKIPBLNK *) ;


   procedure NEXTCH ;

      begin (* NEXTCH *)
        if EOL then
          begin
            if EOF ( INPUT ) then
              FATALERROR ( 390 ) ;
            ENDOFLINE ;
          end (* then *) ;
        CHCNT := CHCNT + 1 ;
        EOL := ( CHCNT > LASTCOL ) ;
        CH := LINEBUF [ CHCNT ] ;
      end (* NEXTCH *) ;


   procedure OPTIONS ( CCH : CHAR ) ;

   (***********************************)
   (*   CCH = COMMENT TERMINATOR CH   *)
   (***********************************)


      var SCH : CHAR ;
          OLDLIST : BOOLEAN ;
          TERMCH : CHAR ;


      function DECNUM : INTEGER ;

         var NUM : INTEGER ;

         begin (* DECNUM *)
           NUM := 0 ;
           NEXTCH ;
           while CH >= '0' do
             begin
               NUM := NUM * 10 + ORD ( CH ) - ORD ( '0' ) ;
               NEXTCH
             end (* while *) ;
           DECNUM := NUM
         end (* DECNUM *) ;


      begin (* OPTIONS *)
        if ( CCH = '/' ) or ( CCH = ')' ) then
          TERMCH := '*'
        else
          TERMCH := CHRBRACE ;
        repeat
          NEXTCH ;
          if CH in LOW_LETTERS + UP_LETTERS then
            begin
              SCH := UPSHIFT [ CH ] ;
              NEXTCH ;
              case SCH of
                'L' : begin
                        OLDLIST := LIST ;
                        LIST := CH <> '-' ;
                        if not OLDLIST then
                          if LIST then
                            PRINTLINE ;
                      end (* tag/ca *) ;
                'C' : PRCODE := CH <> '-' ;
                'E' : if LIST then
                        PLCNT := PAGESIZE ;
                'A' : ASSEMBLE := CH = '+' ;
                'M' : begin
                        if CH = '+' then
                          begin
                            LMARGIN := 0 ;
                            RMARGIN := 72 ;
                          end (* then *)
                        else
                          if CH = '-' then
                            begin
                              LMARGIN := 0 ;
                              BUFEND := BUFLEN ;
                              RMARGIN := BUFLEN ;
                            end (* then *)
                          else
                            if CH = '(' then
                              begin
                                LMARGIN := DECNUM - 1 ;
                                if LMARGIN < 0 then
                                  LMARGIN := 0 ;
                                if CH = ',' then
                                  RMARGIN := DECNUM
                                else
                                  RMARGIN := BUFLEN ;
                                if ( RMARGIN <= LMARGIN ) or ( RMARGIN
                                >= BUFLEN ) then
                                  RMARGIN := BUFLEN - 1 ;
                                BUFEND := BUFLEN ;
                              end (* then *)
                      end (* tag/ca *) ;
                'S' : SAVEREGS := CH <> '-' ;
                'F' : SAVEFPRS := CH <> '-' ;
                'D' : if CH >= '0' then
                        begin
                          DEBUG_LEV := ORD ( CH ) - ORD ( '0' ) ;
                          DEBUG := DEBUG_LEV >= 2 ;
                        end (* then *)
                      else
                        begin
                          DEBUG := CH <> '-' ;
                          DEBUG_LEV := ORD ( DEBUG ) * 2 ;
                        end (* else *) ;
                'V' : ASMVERB := CH = '+' ;
                'W' : WARNING := CH <> '-' ;
                'U' : GET_STAT := CH = '+' ;
                'P' : NOPACKING := CH = '-' ;
                'K' : CTROPTION := CH = '+' ;
                'N' : NESTCOMM := CH = '+' ;
              end (* case *) ;
              if CH <> TERMCH then
                if CH <> ',' then
                  NEXTCH ;
            end (* then *)
        until CH <> ','
      end (* OPTIONS *) ;


   procedure COMMENT ( CCH : CHAR ) ;

   (***********************************)
   (*   CCH = COMMENT TERMINATOR CH   *)
   (***********************************)


      var TERMCH : CHAR ;

      begin (* COMMENT *)
        if ( CCH = '/' ) or ( CCH = ')' ) then
          TERMCH := '*'
        else
          TERMCH := CHRBRACE ;

        (*****************************************)
        (*   SET TERMCH - EXPECTED COMMENT       *)
        (*   TERMINATING CHARACTER               *)
        (*****************************************)

        repeat
          if CH <> TERMCH then
            repeat
              if NESTCOMM then
                begin

        (*****************************************)
        (*   ONLY ALLOW NESTING OF COMMENTS      *)
        (*   OF SAME TYPE                        *)
        (*****************************************)

                  if CH = CHLBRACE then
                    if CCH = CHRBRACE then
                      begin
                        EOL := FALSE ;
                        COMMENT ( CHRBRACE )
                      end (* then *) ;
                  if CH = '(' then
                    if LINEBUF [ CHCNT + 1 ] = '*' then
                      if CCH = ')' then
                        begin
                          EOL := FALSE ;
                          NEXTCH ;
                          NEXTCH ;
                          COMMENT ( ')' ) ;
                        end (* then *) ;
                  if CH = '/' then
                    if LINEBUF [ CHCNT + 1 ] = '*' then
                      if CCH = '/' then
                        begin
                          EOL := FALSE ;
                          NEXTCH ;
                          NEXTCH ;
                          COMMENT ( '/' ) ;
                        end (* then *) ;
                end (* then *) ;
              if CHCNT > LASTCOL then
                begin
                  if EOF ( INPUT ) then
                    FATALERROR ( 390 ) ;
                  ENDOFLINE ;
                end (* then *) ;
              CHCNT := CHCNT + 1 ;
              CH := LINEBUF [ CHCNT ] ;
            until CH = TERMCH ;
          if CCH <> CHRBRACE then
            begin
              CHCNT := CHCNT + 1 ;
              CH := LINEBUF [ CHCNT ] ;
            end (* then *)
        until CH = CCH ;

        (*****************************************)
        (*   PREPARE FOR NEXT CALL TO 'NEXTCH'   *)
        (*****************************************)

        EOL := FALSE ;
      end (* COMMENT *) ;


   procedure INSTRING ( STRTYPE : CHAR ) ;

      var XSTRING : array [ 1 .. MAXSTRL ] of CHAR ;


      procedure MODSTRING ( STRTYPE : CHAR ; var L : INTEGER ) ;

         var IX : INTEGER ;
             LNEU : INTEGER ;
             L1 : INTEGER ;
             X : INTEGER ;
             X2 : INTEGER ;
             INEU : INTEGER ;

         begin (* MODSTRING *)
           IX := 1 ;
           case STRTYPE of
             'B' : begin
                     LNEU := ( L + 7 ) DIV 8 ;
                     L1 := L MOD 8 ;
                     if L1 = 0 then
                       L1 := 8 ;
                     for X := 1 to LNEU do
                       begin
                         INEU := 0 ;
                         for X2 := 1 to L1 do
                           begin
                             INEU := INEU * 2 ;
                             if XSTRING [ IX ] = '1' then
                               INEU := INEU + 1 ;
                             IX := IX + 1 ;
                           end (* for *) ;
                         L1 := 8 ;
                         XSTRING [ X ] := CHR ( INEU ) ;
                       end (* for *) ;
                     L := LNEU ;
                   end (* tag/ca *) ;
             'X' : begin
                     LNEU := ( L + 1 ) DIV 2 ;
                     L1 := L MOD 2 ;
                     if L1 = 0 then
                       L1 := 2 ;
                     for X := 1 to LNEU do
                       begin
                         INEU := 0 ;
                         for X2 := 1 to L1 do
                           begin
                             INEU := INEU * 16 ;
                             if XSTRING [ IX ] in [ '1' .. '9' ] then
                               INEU := INEU + ORD ( XSTRING [ IX ] ) -
                                       ORD ( '0' )
                             else
                               if XSTRING [ IX ] in [ 'A' .. 'F' ] then
                                 INEU := INEU + ORD ( XSTRING [ IX ] )
                                         - ORD ( 'A' ) + 10 ;
                             IX := IX + 1 ;
                           end (* for *) ;
                         L1 := 2 ;
                         XSTRING [ X ] := CHR ( INEU ) ;
                       end (* for *) ;
                     L := LNEU ;
                   end (* tag/ca *)
           end (* case *) ;
         end (* MODSTRING *) ;


      begin (* INSTRING *)
        LNGTH := 0 ;

        (*****************************************)
        (*   neu: XSTRING wird mit zwei blanks   *)
        (*   intialisiert (spaeter mit leerem    *)
        (*   string)                             *)
        (*****************************************)

        XSTRING := ' ' ;
        SY := STRINGCONST ;
        OP := NOOP ;
        repeat
          repeat
            repeat
              NEXTCH ;
              if EOL then
                begin
                  ERROR ( 202 ) ;
                  CH := ''''
                end (* then *) ;
              if ( CH = '''' ) or ( STRTYPE = 'C' ) then
                begin
                  LNGTH := LNGTH + 1 ;
                  if LNGTH <= MAXSTRL then
                    XSTRING [ LNGTH ] := CH
                end (* then *)
              else
                case STRTYPE of
                  'B' : begin
                          if CH = '_' then
                            continue ;
                          if CH in BIN_CHARS then
                            begin
                              LNGTH := LNGTH + 1 ;
                              if LNGTH <= MAXSTRL then
                                XSTRING [ LNGTH ] := CH
                            end (* then *)
                          else
                            ERROR ( 210 )
                        end (* tag/ca *) ;
                  'X' : begin
                          if CH = '_' then
                            continue ;
                          if CH in HEX_CHARS then
                            begin
                              LNGTH := LNGTH + 1 ;
                              if LNGTH <= MAXSTRL then
                                XSTRING [ LNGTH ] := UPSHIFT [ CH ]
                            end (* then *)
                          else
                            ERROR ( 209 )
                        end (* tag/ca *)
                end (* case *)
            until CH = '''' ;
            NEXTCH
          until ( CH <> '''' ) or ( STRTYPE <> 'C' ) ;
          XSTRING [ LNGTH ] := ' ' ;
          LNGTH := LNGTH - 1 ;
          if ( CH = ' ' ) or ( CH = '#' ) then
            SKIPBLNK ;
        until CH <> '''' ;

        (*****************************************)
        (*   NOW LNGTH = NR OF CHARS IN STRING   *)
        (*****************************************)
        (*   modify LNGTH in case of hex or bin  *)
        (*****************************************)

        case STRTYPE of
          'B' : begin
                  MODSTRING ( STRTYPE , LNGTH ) ;
                end (* tag/ca *) ;
          'X' : begin
                  MODSTRING ( STRTYPE , LNGTH ) ;
                end (* tag/ca *)
        end (* case *) ;
        VAL . STRTYPE := STRTYPE ;
        if LNGTH = 0 then
          begin

        (*****************************************)
        (*   new: allow '' - handle like blank   *)
        (*   was: error (205) - opp / 2016       *)
        (*****************************************)
        (*   LGNTH := 1 is needed because        *)
        (*   otherwise strange errors occur      *)
        (*   (string of length 0 are             *)
        (*   generated instead of single chars   *)
        (*   which leads to 0C4 in mod_strconst) *)
        (*****************************************)

            VAL . IVAL := ORD ( ' ' ) ;
            LNGTH := 1 ;
          end (* then *)
        else
          if LNGTH = 1 then
            VAL . IVAL := ORD ( XSTRING [ 1 ] )
          else
            begin
              if LNGTH > MAXSTRL then
                begin
                  ERROR ( 398 ) ;
                  LNGTH := MAXSTRL
                end (* then *) ;
              NEW ( VAL . SVAL ) ;
              VAL . SVAL -> . TAG := 'S' ;
              VAL . SVAL -> . LENGTH := LNGTH ;
              VAL . SVAL -> . SSTR := XSTRING ;
            end (* else *)
      end (* INSTRING *) ;


   begin (* INSYMBOL *)
     VAL . IVAL := 0 ;
     VAL . STRTYPE := ' ' ;
     1 :
     if CH = ' ' then
       SKIPBLNK ;
     case SOP [ CH ] of

     (*********************)
     (*   LETTER A TO Z   *)
     (*********************)

       ATOZCH :
         begin
           ID := ' ' ;
           K := 0 ;
           CHSAVE := UPSHIFT [ CH ] ;
           NEXTCH ;
           if CHSAVE in [ 'X' , 'B' ] then
             begin
               if CH = '''' then
                 begin

     (**********************************)
     (*   hex or binary char constant  *)
     (**********************************)

                   INSTRING ( CHSAVE ) ;
                   goto 2 ;
                 end (* then *)
             end (* then *) ;
           ID [ 1 ] := CHSAVE ;
           K := 1 ;
           while SOP [ CH ] in [ ATOZCH , NUMCH , UNDSCH , DOLLARCH ]
           do
             begin
               if K < IDLNGTH then
                 begin
                   K := K + 1 ;
                   ID [ K ] := UPSHIFT [ CH ]
                 end (* then *) ;
               NEXTCH
             end (* while *) ;

     (**********************************************************)
     (*   maxrwlen = laenge des laengsten reservierten wortes  *)
     (*   die tabelle frw ist nur so lang                      *)
     (**********************************************************)

           if K <= MAXRWLEN then
             for I := FRW [ K ] to FRW [ K + 1 ] - 1 do
               if RW [ I ] = ID then
                 begin
                   SY := RSY [ I ] ;
                   OP := ROP [ I ] ;
                   goto 2
                 end (* then *) ;
           SY := IDENT ;
           OP := NOOP ;
           2 :
           
         end (* tag/ca *) ;

     (*********************)
     (*   NUMBER 0 TO 9   *)
     (*********************)

       NUMCH : begin
                 OP := NOOP ;
                 SY := REALCONST ;

     (**************************************)
     (*   initialize digit - important     *)
     (*   otherwise checking for x at      *)
     (*   position 2 without checking      *)
     (*   for length leaded to errors      *)
     (**************************************)

                 DIGIT := '' ;
                 K := 0 ;
                 STATE := 0 ;
                 repeat
                   DIGSEEN := FALSE ;
                   3 :
                   K := K + 1 ;
                   if K <= DIGMAX then
                     DIGIT [ K ] := CH ;
                   NEXTCH ;
                   if SOP [ CH ] = NUMCH then
                     begin
                       DIGSEEN := TRUE ;
                       goto 3
                     end (* then *) ;

     (**************************************)
     (*   state = 8: 0x already seen       *)
     (**************************************)

                   if STATE = 8 then
                     if ( SOP [ CH ] = NUMCH ) or ( CH in [ 'A' .. 'F'
                     ] ) or ( CH in [ 'a' .. 'f' ] ) then
                       goto 3 ;

     (***************************************)
     (*   digseen: at least one digit seen  *)
     (***************************************)

                   if DIGSEEN then
                     STATE := STATE + 1 ;
                   case STATE of

     (**************************************)
     (*   LEADING DIGIT SEQUENCE SCANNED   *)
     (**************************************)

                     0 , 1 : if CH = '.' then
                               STATE := 2
                             else
                               if CH = 'E' then
                                 STATE := 4
                               else
                                 if CH = 'e' then
                                   STATE := 4
                                 else

     /*******************************************/
     /*   if 0x, this is an intconst            */
     /*   set sy to intconst and set state      */
     /*   to 8                                  */
     /*******************************************/

                                   if ( ( CH = 'X' ) or ( CH = 'x' ) )
                                   and ( K = 1 ) and ( DIGIT [ 1 ] =
                                   '0' ) then
                                     begin
                                       SY := INTCONST ;
                                       STATE := 8
                                     end (* then *)
                                   else

     /*******************************************/
     /*   other symbol which terminates the     */
     /*   intconst; set state tol zero          */
     /*******************************************/

                                     begin
                                       SY := INTCONST ;
                                       STATE := 0
                                     end (* else *) ;

     (**********************************)
     (*   DECIMAL POINT JUST SCANNED   *)
     (*   if period follows, we have   *)
     (*   no float constant, but       *)
     (*   two dots.                    *)
     (*   if rparent follows, we have  *)
     (*   substitute for rbracket      *)
     (**********************************)

                     2 : if CH = '.' then
                           begin
                             SY := INTCONST ;
                             K := K - 1 ;
                             DOTFLG := TRUE ;
                             STATE := 0
                           end (* then *)
                         else
                           if CH = ')' then
                             begin
                               SY := INTCONST ;
                               K := K - 1 ;
                               DOTFLG := TRUE ;
                               STATE := 0
                             end (* then *)
                           else
                             if UPSHIFT [ CH ] = 'E' then
                               begin
                                 K := K - 1 ;
                                 STATE := 4
                               end (* then *)
                             else
                               STATE := - 1 ;

     (********************************************)
     (*   DIGIT SEQUENCE AFTER POINT JUST SEEN   *)
     (********************************************)

                     3 : if CH = 'E' then
                           STATE := 4
                         else
                           if CH = 'e' then
                             STATE := 4
                           else
                             STATE := 0 ;

     (*********************************)
     (*   EXPONENT SYMBOL JUST SEEN   *)
     (*********************************)

                     4 : if CH = '-' then
                           STATE := 6
                         else
                           if CH = '+' then
                             STATE := 6
                           else
                             STATE := - 1 ;

     (****************************************************)
     (*   DIGIT STRING IN EXPONENT ended by other char   *)
     (****************************************************)

                     5 , 7 : STATE := 0 ;

     (**********************************************)
     (*   BAD CHARACTER AFTER 'E+' OR 'E-' FOUND   *)
     (**********************************************)

                     6 : STATE := - 1 ;

     (***************************************)
     (*   hex intconst ended by other char  *)
     (*   9 will be set cause of digseen    *)
     (***************************************)

                     8 , 9 : STATE := 0 ;
                   end (* case *) ;
                 until STATE <= 0 ;

     (***********************************)
     (*   LEXICAL ERROR IN REAL CONST   *)
     (***********************************)

                 if STATE < 0 then
                   ERROR ( 201 ) ;
                 if SY = REALCONST then
                   begin
                     for I := 1 to REALLNGTH do
                       VAL . RVAL [ I ] := ' ' ;
                     if K <= DIGMAX then
                       for I := 2 to K + 1 do
                         VAL . RVAL [ I ] := DIGIT [ I - 1 ]
                     else
                       begin
                         ERROR ( 203 ) ;
                         UNPACK ( '0.0' , VAL . RVAL , 2 )
                       end (* else *)
                   end (* then *)
                 else
                   begin
                     VAL . IVAL := 0 ;

     (***********************************************)
     (*   if hex const, translate to integer / ival *)
     (***********************************************)

                     if ( DIGIT [ 2 ] = 'X' ) or ( DIGIT [ 2 ] = 'x' )
                     then
                       begin
                         with VAL do
                           if K > 10 then
                             begin
                               ERROR ( 203 ) ;
                               IVAL := 0
                             end (* then *)
                           else
                             for I := 3 to K do
                               begin
                                 case DIGIT [ I ] of
                                   '0' .. '9' :
                                     IVAL := IVAL * 16 + ORD ( DIGIT [
                                             I ] ) - ORD ( '0' ) ;
                                   'A' .. 'F' :
                                     IVAL := IVAL * 16 + ORD ( DIGIT [
                                             I ] ) - ORD ( 'A' ) + 10 ;
                                   'a' .. 'f' :
                                     IVAL := IVAL * 16 + ORD ( DIGIT [
                                             I ] ) - ORD ( 'a' ) + 10 ;
                                 end (* case *)
                               end (* for *)
                       end (* then *)
                     else
                       begin

     (*************************)
     (*   normal int constant *)
     (*************************)

                         if K > DIGMAX then
                           ERROR ( 203 )
                         else
                           with VAL do
                             for I := 1 to K do
                               if IVAL <= MXINT10 then
                                 IVAL := IVAL * 10 + ( ORD ( DIGIT [ I
                                         ] ) - ORD ( '0' ) )
                               else
                                 begin
                                   ERROR ( 203 ) ;
                                   IVAL := 0
                                 end (* else *)
                       end (* else *)
                   end (* else *)
               end (* tag/ca *) ;

     (****************************)
     (*   QUOTE = HOCHKOMMA      *)
     (****************************)

       QUOTCH :
         INSTRING ( 'C' ) ;

     (****************************)
     (*   COLON = DOPPELPUNKT    *)
     (****************************)

       COLONCH :
         begin
           OP := NOOP ;
           NEXTCH ;
           if CH = '=' then
             begin
               SY := BECOMES ;
               NEXTCH
             end (* then *)
           else
             SY := COLON
         end (* tag/ca *) ;

     (****************************)
     (*   DOT = PUNKT            *)
     (****************************)

       DOTCH : begin
                 OP := NOOP ;
                 if not DOTFLG then
                   NEXTCH ;
                 if CH = '.' then
                   begin
                     SY := DOTDOT ;
                     DOTFLG := FALSE ;
                     NEXTCH
                   end (* then *)
                 else
                   if CH = ')' then
                     begin
                       SY := RBRACK ;
                       DOTFLG := FALSE ;
                       NEXTCH
                     end (* then *)
                   else
                     SY := PERIOD
               end (* tag/ca *) ;

     (****************************)
     (*   LT = KLEINERZEICHEN    *)
     (****************************)

       LTOP : begin
                NEXTCH ;
                SY := RELOP ;
                if CH = '=' then
                  begin
                    OP := LEOP ;
                    NEXTCH
                  end (* then *)
                else
                  if CH = '>' then
                    begin
                      OP := NEOP ;
                      NEXTCH
                    end (* then *)
                  else
                    OP := LTOP
              end (* tag/ca *) ;

     (****************************)
     (*   GT = GROESSERZEICHEN   *)
     (****************************)

       GTOP : begin
                NEXTCH ;
                SY := RELOP ;
                if CH = '=' then
                  begin
                    OP := GEOP ;
                    NEXTCH
                  end (* then *)
                else
                  OP := GTOP
              end (* tag/ca *) ;

     (*******************************)
     (*   LPARCH = LINKE KLAMMER    *)
     (*******************************)

       LPARCH :
         begin
           NEXTCH ;
           if CH = '*' then
             begin
               NEXTCH ;
               if CH = '$' then
                 OPTIONS ( ')' ) ;
               COMMENT ( ')' ) ;
               NEXTCH ;
               goto 1 ;
             end (* then *) ;
           if CH = '/' then
             begin
               SY := LBRACK ;
               OP := NOOP ;
               NEXTCH
             end (* then *)
           else
             if CH = '.' then
               begin
                 SY := LBRACK ;
                 OP := NOOP ;
                 NEXTCH
               end (* then *)
             else
               begin
                 SY := LPARENT ;
                 OP := NOOP
               end (* else *)
         end (* tag/ca *) ;

     (**********************************************************)
     (*   vielleicht wurde schon .) gelesen, beim              *)
     (*   einlesen einer zahl, die wie eine gleitkommazahl     *)
     (*   aussah: (.1..10.) - altes problem der pascal-syntax  *)
     (**********************************************************)

       RPARCH :
         begin
           if DOTFLG then
             begin
               SY := SSY [ ']' ] ;
               OP := SOP [ ']' ] ;
               DOTFLG := FALSE ;
             end (* then *)
           else
             begin
               SY := SSY [ ')' ] ;
               OP := SOP [ ')' ] ;
             end (* else *) ;
           NEXTCH
         end (* tag/ca *) ;

     (**********************************************************)
     (*   DIVERSE OPERATORZEICHEN                              *)
     (*   VEREINFACHT, WEIL LOGIK WG. RBRACK NUR BEI           *)
     (*   RDIV NOETIG IST / OPPOLZER                           *)
     (**********************************************************)

       PLUS , MUL , EQOP , OROP , ANDOP , SPECH :
         begin
           SY := SSY [ CH ] ;
           OP := SOP [ CH ] ;
           NEXTCH
         end (* tag/ca *) ;

     (**********************************************************)
     (*   RDIV = SCHRAEGSTRICH                                 *)
     (*   MAYBE A RIGHT BRACKET, IF A RIGHT PARANTH. FOLLOWS   *)
     (*   AND: MAY START /* ... */ STYLE COMMENTS              *)
     (**********************************************************)

       RDIV : begin
                NEXTCH ;
                if CH = '*' then
                  begin
                    NEXTCH ;
                    if CH = '$' then
                      OPTIONS ( '/' ) ;
                    COMMENT ( '/' ) ;
                    NEXTCH ;
                    goto 1 ;
                  end (* then *) ;
                if CH = ')' then
                  begin
                    SY := RBRACK ;
                    OP := NOOP ;
                    NEXTCH ;
                  end (* then *)
                else
                  begin
                    SY := SSY [ '/' ] ;
                    OP := SOP [ '/' ] ;
                  end (* else *)
              end (* tag/ca *) ;

     (**********************************************************)
     (*   MINUS                                                *)
     (*   MAYBE A POINTER SYM, IF A GTOP FOLLOWS               *)
     (**********************************************************)

       MINUS : begin
                 NEXTCH ;
                 if CH = '>' then
                   begin
                     SY := ARROW ;
                     OP := NOOP ;
                     NEXTCH ;
                   end (* then *)
                 else
                   begin
                     SY := SSY [ '-' ] ;
                     OP := SOP [ '-' ] ;
                   end (* else *)
               end (* tag/ca *) ;

     (*****************************************)
     (*   DOUBLE QUOTE = ANFUEHRUNGSZEICHEN   *)
     (*   ALLES ZWISCHEN ANFUEHRUNGSZEICHEN   *)
     (*   WIRD IGNORIERT !!!                  *)
     (*****************************************)

       DQUOTCH :
         begin
           repeat
             NEXTCH
           until CH = '"' ;
           NEXTCH ;
           goto 1 ;
         end (* tag/ca *) ;

     (********************************************)
     (*   LBRACE = LINKE GESCHWEIFTE KLAMMER -   *)
     (*   STANDARD KOMMENTAR IN PASCAL -         *)
     (*   HINZUGEFUEGT VON DAVE EDWARDS          *)
     (********************************************)

       LBRACE :
         begin
           NEXTCH ;
           if CH = '$' then
             OPTIONS ( CHRBRACE ) ;
           COMMENT ( CHRBRACE ) ;
           NEXTCH ;
           goto 1 ;
         end (* tag/ca *) ;

     (****************************)
     (*   SKIPCH                 *)
     (****************************)

       SKIPCH :
         begin
           NEXTCH ;
           goto 1
         end (* tag/ca *) ;

     (****************************)
     (*   ILLEGALE ZEICHEN       *)
     (****************************)

       ILLEGCH , DOLLARCH , UNDSCH :
         begin
           SY := OTHERSY ;
           OP := NOOP ;
           ERROR ( 6 ) ;
           NEXTCH
         end (* tag/ca *)
     end (* case *) ;
     if FALSE then
       WRITELN ( TRACEF , 'insymbol returns sy = ' , SY , ' linecnt = '
                 , LINECNT : 1 , ' chcnt = ' , CHCNT : 1 ) ;
   end (* INSYMBOL *) ;



function HASH ( ID : ALPHA ) : BKT_RNG ;

   var OL : record
              case INTEGER of
                1 :
                  ( IDK : ALPHA ) ;
                2 :
                  ( INT1 , INT2 , INT3 : INTEGER )
            end ;

   begin (* HASH *)
     with OL do
       begin
         IDK := ID ;

     (***********************************)
     (* NO OVERFLOW CHECK FOR NEXT STMT *)
     (***********************************)

         HASH := ABS ( ( INT1 * 2 + INT2 ) * 2 + INT3 ) MOD ( MAX_BKT +
                 1 ) ;
       end (* with *)
   end (* HASH *) ;



procedure ENTERID ( FCP : IDP ) ;

   var K : BKT_RNG ;
       NAM : ALPHA ;
       LCP : IDP ;

   begin (* ENTERID *)
     NAM := FCP -> . NAME ;
     K := HASH ( NAM ) ;
     LCP := BUCKET [ K ] ;
     FCP -> . DECL_LEV := LEVEL ;
     FCP -> . NEXT_IN_BKT := LCP ;
     BUCKET [ K ] := FCP ;

     (***************************************)
     (* NOW CHECK FOR DUPLICATE DECLARATION *)
     (***************************************)

     while LCP <> NIL do
       with LCP -> do
         begin
           if NAME = NAM then
             if KLASS <> FIELD then
               begin
                 if TOP = DECL_LEV then
                   begin
                     ERROR ( 101 ) ;
                     break ;
                   end (* then *)
               end (* then *)
             else

     (*****************************)
     (* SPECIAL LOOKUP FOR FIELDS *)
     (*****************************)

               if TOP = OWNER -> . FLD_DISP_LEV then
                 begin
                   ERROR ( 101 ) ;
                   break ;
                 end (* then *) ;
           LCP := NEXT_IN_BKT ;
         end (* with *) ;
     if GET_STAT then
       if TOP = LEVEL then
         ENT_CNT [ LEVEL ] := ENT_CNT [ LEVEL ] + 1
       else
         FENT_CNT := FENT_CNT + 1 ;
   end (* ENTERID *) ;



procedure SEARCHSECTION ( FSP : TTP ; var FCP : IDP ) ;

(****************************************************)
(* FINDS FIELD IN RECORD STRUCTURE INDICATED BY FSP *)
(****************************************************)


   var LCP : IDP ;

   begin (* SEARCHSECTION *)
     LCP := BUCKET [ HASH ( ID ) ] ;
     while LCP <> NIL do
       with LCP -> do
         begin
           if NAME = ID then
             if KLASS = FIELD then
               if OWNER = FSP then
                 begin
                   if GET_STAT then
                     begin
                       SF_CNT := SF_CNT + 1 ;
                       SF_TOT := SF_TOT + FSP -> . NO_FLDS ;
                     end (* then *) ;
                   break ;
                 end (* then *) ;
           LCP := NEXT_IN_BKT ;
         end (* with *) ;
     FCP := LCP ;
   end (* SEARCHSECTION *) ;



function SEARCHID ( ID : ALPHA ; PRTERR : BOOLEAN ; INSERT_ON_ERR :
                  BOOLEAN ; FIDCLS : SETOFIDS ; var FCP : IDP ) :
                  BOOLEAN ;

(********************************************************)
(*   prueft, ob bestimmte Bezeichner bekannt sind       *)
(*                                                      *)
(*   id      - um diesen Bezeichner geht es             *)
(*   prterr  - Fehler anzeigen oder nicht               *)
(*   fidcls  - Bezeichnerklasse                         *)
(*   fcp     - Zeiger auf Datentyp usw.                 *)
(********************************************************)


   var LCP : IDP ;
       DL , EL : - 1 .. DISPLIMIT ;
       K : BKT_RNG ;

   begin (* SEARCHID *)
     SEARCHID := TRUE ;
     K := HASH ( ID ) ;
     LCP := BUCKET [ K ] ;
     FCP := NIL ;
     EL := - 1 ;
     DISX := EL ;

     /************************************************************/
     /* der bezeichner wird in den entsprechenden listen gesucht */
     /************************************************************/

     while LCP <> NIL do
       with LCP -> do
         begin
           if NAME = ID then
             begin
               if KLASS <> FIELD then
                 DL := DECL_LEV
               else
                 DL := OWNER -> . FLD_DISP_LEV ;
               if DL > DISX then
                 if KLASS in FIDCLS then
                   begin
                     FCP := LCP ;
                     DISX := DL ;
                     if TOP = LEVEL then

     (*******************************)
     (* NO POINT IN FURTHER SEARCH  *)
     (*******************************)

                       break
                   end (* then *)
                 else
                   EL := DL ;
             end (* then *) ;
           LCP := NEXT_IN_BKT ;
         end (* with *) ;

     /************************************************/
     /* bezeichner gefunden, hat aber falsche klasse */
     /************************************************/

     if EL > DISX then
       begin
         SEARCHID := FALSE ;
         if PRTERR then
           ERROR ( 103 ) ;
       end (* then *) ;

     /*****************************/
     /* bezeichner nicht gefunden */
     /*****************************/

     if DISX < 0 then
       begin
         SEARCHID := FALSE ;
         if PRTERR then
           begin

     /****************************************************/
     /* fehler nur ausgeben, wenn nicht schon fehler 103 */
     /****************************************************/

             if EL < 0 then
               ERROR ( 104 ) ;
             DISX := LEVEL ;
           end (* then *)
         else
           DISX := 0 ;
         if INSERT_ON_ERR then
           begin

     /***************************************************/
     /* im fehlerfall bezeichner mit der entsprechenden */
     /* id-klasse eintragen, um folgefehler zu          */
     /* vermeiden                                       */
     /***************************************************/

             NEW ( LCP ) ;
             if ( FIELD in FIDCLS ) and ( TOP > LEVEL ) then
               LCP -> := UFLDPTR ->
             else
               if VARS in FIDCLS then
                 LCP -> := UVARPTR ->
               else
                 if TYPES in FIDCLS then
                   LCP -> := UTYPPTR ->
                 else
                   if KONST in FIDCLS then
                     LCP -> := UCSTPTR ->
                   else
                     if PROC in FIDCLS then
                       LCP -> := UPRCPTR ->
                     else
                       LCP -> := UFCTPTR -> ;
             with LCP -> do
               begin
                 NAME := ID ;
                 DECL_LEV := LEVEL ;
                 NEXT_IN_BKT := BUCKET [ K ] ;
                 BUCKET [ K ] := LCP ;
                 FCP := LCP ;
                 if KLASS = FIELD then
                   OWNER := OPEN_RECORD ;
               end (* with *) ;
           end (* then *)
       end (* then *) ;
     if GET_STAT then
       begin
         if DISX <= LEVEL then
           LU_CNT [ DISX , TOP ] := LU_CNT [ DISX , TOP ] + 1
         else
           WLU_CNT [ DISX - LEVEL , TOP - LEVEL ] := WLU_CNT [ DISX -
                                                   LEVEL , TOP - LEVEL
                                                   ] + 1 ;
         if TOP <> LEVEL then
           WE_CNT := WE_CNT + 1
       end (* then *) ;
   end (* SEARCHID *) ;



function GETIDLEN ( X : ALPHA ) : INTEGER ;

   var I : INTEGER ;

   begin (* GETIDLEN *)
     I := IDLNGTH ;
     while X [ I ] = ' ' do
       begin
         I := I - 1 ;
         if I <= 0 then
           break
       end (* while *) ;
     GETIDLEN := I ;
   end (* GETIDLEN *) ;



procedure GETBOUNDS ( FSP : TTP ; var FMIN , FMAX : INTEGER ) ;

(******************************************************)
(* GET INTERNAL BOUNDS OF SUBRANGE OR SCALAR TYPE     *)
(* ASSUME (FSP <> NIL) AND (FSP@.FORM <= SUBRANGE)    *)
(* AND (FSP <> INTPTR)                                *)
(* AND NOT COMPTYPES (REALPTR, FSP)                   *)
(******************************************************)


   begin (* GETBOUNDS *)
     with FSP -> do
       if FORM = SUBRANGE then
         begin
           FMIN := MIN . IVAL ;
           FMAX := MAX . IVAL
         end (* then *)
       else
         begin
           FMIN := 0 ;
           if FSP = CHARPTR then
             FMAX := ORDCHMAX
           else
             if ( FORM = SCALAR ) and ( FSP -> . FCONST <> NIL ) then
               FMAX := FSP -> . FCONST -> . VALUES . IVAL
             else
               FMAX := 0
         end (* else *)
   end (* GETBOUNDS *) ;



function GETTYPE ( OPERAND : TTP ) : INTEGER ;

   begin (* GETTYPE *)
     GETTYPE := ORD ( 'I' ) ;

     (***********************)
     (* ASSUME INTEGER TYPE *)
     (***********************)

     if OPERAND = NIL then
       begin
         if ERRORCNT = 0 then
           ERROR ( 401 )
       end (* then *)
     else
       if OPERAND -> . FORM > POWER then
         GETTYPE := ORD ( 'A' )
       else
         if OPERAND -> . FORM = POWER then
           GETTYPE := ORD ( 'S' )
         else
           if OPERAND -> . FORM = POINTER then
             GETTYPE := ORD ( 'A' )
           else
             if OPERAND = REALPTR then
               GETTYPE := ORD ( 'R' )
             else
               if OPERAND = BOOLPTR then
                 GETTYPE := ORD ( 'B' )
               else
                 if OPERAND -> . SIZE = HINTSIZE then
                   GETTYPE := ORD ( 'H' )
                 else
                   if OPERAND -> . SIZE = CHARSIZE then
                     GETTYPE := ORD ( 'C' )
                   else
                     ;
   end (* GETTYPE *) ;



procedure CALC_SETSIZE ( SETMIN : INTEGER ; SETMAX : INTEGER ; var
                       SETMIN_NEW : INTEGER ; var SETSIZE : INTEGER ) ;

   var BITS_NEEDED : INTEGER ;

   begin (* CALC_SETSIZE *)
     SETMIN := SETMIN - MODP ( SETMIN , 8 ) ;
     SETMIN_NEW := SETMIN ;
     BITS_NEEDED := SETMAX - SETMIN + 1 ;
     SETSIZE := ( BITS_NEEDED + 7 ) DIV 8 + 4 ;
   end (* CALC_SETSIZE *) ;



procedure CALC_SETTYPSIZE ( ELT : TTP ; var SETSIZE : INTEGER ; var
                          SETMIN : INTEGER ; var SETMAX : INTEGER ; var
                          SETOFFS : INTEGER ) ;

(**************************************************)
(* COMPUTES SIZE OF SET WHOSE ELEMENT TYPE IS ELT *)
(*------------------------------------------------*)
(* 12.2016 - opp - size for char-based sets       *)
(* always 32 due to codepage issues               *)
(*------------------------------------------------*)
(* 06.2017 - opp - changed again for new          *)
(* representation of sets                         *)
(**************************************************)


   var MIN , MAX : INTEGER ;
       MIN_NEW : INTEGER ;

   begin (* CALC_SETTYPSIZE *)
     MIN := 0 ;
     MAX := - 1 ;
     if ELT <> NIL then
       begin
         if ELT = CHARPTR then
           MAX := ORDCHMAX
         else
           if ELT -> . FORM = SUBRANGE then
             if ELT -> . RANGETYPE = CHARPTR then
               MAX := ORDCHMAX ;
         if MAX = - 1 then
           GETBOUNDS ( ELT , MIN , MAX ) ;
       end (* then *) ;
     CALC_SETSIZE ( MIN , MAX , MIN_NEW , SETSIZE ) ;
     SETMIN := MIN ;
     SETMAX := MAX ;
     SETOFFS := SETMIN - MODP ( SETMIN , 8 ) ;
     SETOFFS := SETOFFS DIV 8 ;
   end (* CALC_SETTYPSIZE *) ;



function OPNDSETSIZE ( FATTR : ATTR ; var SETOFFS : INTEGER ; var
                     CHARTYPE : BOOLEAN ) : INTEGER ;

(*************************************************)
(* COMPUTES THE SIZE OF A SET USED AS AN OPERAND *)
(*************************************************)
(* opp 12.2016: sets with base type char are     *)
(* always 32 bytes long - code page dependency   *)
(*************************************************)
(* opp 07.2017: char now 36 bytes ...            *)
(* due to new representation of set types        *)
(*************************************************)


   var SETSIZE : INTEGER ;
       SETMIN_NEW : INTEGER ;
       ELT : TTP ;

   begin (* OPNDSETSIZE *)
     OPNDSETSIZE := 0 ;
     SETOFFS := 0 ;
     CHARTYPE := FALSE ;
     with FATTR do
       if TYPTR <> NIL then
         if TYPTR -> . FORM = POWER then
           begin
             ELT := TYPTR -> . ELSET ;
             if ELT <> NIL then
               begin
                 if ELT = CHARPTR then
                   CHARTYPE := TRUE
                 else
                   if ELT -> . FORM = SUBRANGE then
                     if ELT -> . RANGETYPE = CHARPTR then
                       CHARTYPE := TRUE ;
               end (* then *) ;
             CALC_SETSIZE ( TYPTR -> . SETMIN , TYPTR -> . SETMAX ,
                            SETMIN_NEW , SETSIZE ) ;
             OPNDSETSIZE := SETSIZE ;
             SETOFFS := TYPTR -> . SETMIN - MODP ( TYPTR -> . SETMIN ,
                        8 ) ;
             SETOFFS := SETOFFS DIV 8 ;
           end (* then *)
   end (* OPNDSETSIZE *) ;



procedure GENLABEL ( var NXTLAB : LABELRNG ) ;

   begin (* GENLABEL *)
     INTLABEL := INTLABEL + 1 ;
     NXTLAB := INTLABEL
   end (* GENLABEL *) ;





(***********************************************************)
(*  THE FOLLOWING OUTPUTS A SYMBOL TABLE FILE              *)
(*  FOR USE BY 'SNAPSHOT' PROGRAM                          *)
(***********************************************************)




procedure PRNTSYMBL ( LCP : IDP ) ;

   var LINELN : INTEGER ;

       (*****************************************)
       (* CURRENT SYMBOL TABLE FILE LINE LENGTH *)
       (*****************************************)

       TPT1 : PRNTTYLISTP ;


   procedure CHECKLN ( LEN : INTEGER ) ;

      begin (* CHECKLN *)
        if ( LINELN + LEN ) >= 80 then
          begin
            WRITELN ( DBGINFO ) ;
            WRITE ( DBGINFO , ' ' ) ;
            LINELN := LEN
          end (* then *)
        else
          LINELN := LINELN + LEN
      end (* CHECKLN *) ;


   procedure PRNTVAR ( VRP : IDP ) ;

      FORWARD ;


   procedure PRNTTYPE ( TYPP : TTP ) ;

      label 1 ;

      var VP , LVP : IDP ;
          RMIN , RMAX : INTEGER ;
          TPT , LPT : PRNTTYLISTP ;
          TNO : 0 .. 999 ;

      begin (* PRNTTYPE *)
        CHECKLN ( 4 ) ;
        if TYPP = INTPTR then
          WRITE ( DBGINFO , 'I4; ' )
        else
          if TYPP = REALPTR then
            WRITE ( DBGINFO , 'R; ' )
          else
            if TYPP = BOOLPTR then
              WRITE ( DBGINFO , 'B; ' )
            else
              if TYPP = CHARPTR then
                WRITE ( DBGINFO , 'C; ' )
              else
                if TYPP <> NIL then
                  with TYPP -> do
                    case FORM of
                      SUBRANGE :
                        if RANGETYPE = CHARPTR then
                          WRITE ( DBGINFO , 'C; ' )
                        else
                          if RANGETYPE = INTPTR then
                            WRITE ( DBGINFO , 'I' , SIZE : 1 , '; ' )
                          else
                            WRITE ( DBGINFO , 'L' , SIZE : 1 , '; ' ) ;
                      SCALAR :
                        WRITE ( DBGINFO , 'L' , SIZE : 1 , '; ' ) ;
                      POINTER :
                        begin
                          if ELTYPE <> NIL then
                            begin
                              TPT := PRNTTYPHD ;
                              LPT := TPT ;
                              while TPT <> NIL do
                                if TPT -> . ELT = ELTYPE then
                                  begin
                                    TNO := TPT -> . TNO ;
                                    goto 1
                                  end (* then *)
                                else
                                  begin
                                    LPT := TPT ;
                                    TPT := TPT -> . NXT ;
                                  end (* else *) ;
                              NEW ( TPT ) ;
                              if PRNTTYPHD = NIL then
                                PRNTTYPHD := TPT
                              else
                                LPT -> . NXT := TPT ;
                              with TPT -> do
                                begin
                                  NXT := NIL ;
                                  ELT := ELTYPE ;
                                  PRNTTYNO := PRNTTYNO + 1 ;
                                  TNO := PRNTTYNO
                                end (* with *) ;
                              TNO := PRNTTYNO ;
                            end (* then *)
                          else
                            TNO := 0 ;
                          1 :
                          CHECKLN ( 3 ) ;
                          WRITE ( DBGINFO , 'P ' , TNO : 1 , '; ' ) ;
                        end (* tag/ca *) ;
                      POWER : if ELSET <> NIL then
                                begin
                                  WRITE ( DBGINFO , 'S ' ) ;
                                  CHECKLN ( 10 ) ;
                                  GETBOUNDS ( ELSET , RMIN , RMAX ) ;
                                  WRITE ( DBGINFO , RMIN : 1 , ' ' ,
                                          RMAX : 1 , ' ; ' ) ;
                                end (* then *) ;
                      FILES : begin
                                WRITE ( DBGINFO , 'F ' ) ;
                                PRNTTYPE ( FILTYPE ) ;
                              end (* tag/ca *) ;
                      RECORDS :
                        begin
                          WRITE ( DBGINFO , 'D' , ALN : 1 , '(' ) ;
                          VP := FSTFLD ;
                          LVP := VP ;
                          while VP <> NIL do
                            begin
                              PRNTVAR ( VP ) ;
                              LVP := VP ;
                              VP := VP -> . NEXT ;
                            end (* while *) ;
                          if RECVAR <> NIL then
                            begin
                              if RECVAR -> . TAGFIELDP <> NIL then
                                if RECVAR -> . TAGFIELDP -> . NAME <>
                                BLANKID then
                                  begin
                                    LVP := RECVAR -> . TAGFIELDP ;
                                    PRNTVAR ( LVP ) ;
                                  end (* then *) ;
                              if LVP <> NIL then
                                begin
                                  CHECKLN ( 12 ) ;
                                  RMAX := SIZE - LVP -> . FLDADDR ;
                                  if LVP -> . IDTYPE <> NIL then
                                    RMAX := RMAX - LVP -> . IDTYPE -> .
                                            SIZE ;
                                  if RMAX > 0 then
                                    WRITE ( DBGINFO , 'ETC=X' , RMAX :
                                            1 , '; ' ) ;
                                end (* then *) ;
                            end (* then *) ;
                          CHECKLN ( 3 ) ;
                          WRITE ( DBGINFO , '); ' ) ;
                        end (* tag/ca *) ;
                      ARRAYS :
                        if INXTYPE <> NIL then
                          begin
                            WRITE ( DBGINFO , 'A ' ) ;
                            CHECKLN ( 26 ) ;
                            GETBOUNDS ( INXTYPE , RMIN , RMAX ) ;
                            WRITE ( DBGINFO , RMIN : 1 , ' ' , RMAX : 1
                                    , ' ' ) ;
                            PRNTTYPE ( AELTYPE ) ;
                          end (* then *) ;
                    end (* case *)
                else
                  WRITE ( DBGINFO , ';' ) ;
      end (* PRNTTYPE *) ;


   procedure PRNTVAR ;

      var I : 0 .. IDLNGTH ;

      begin (* PRNTVAR *)
        with VRP -> do
          begin
            I := GETIDLEN ( NAME ) ;
            CHECKLN ( I + 1 ) ;
            WRITE ( DBGINFO , NAME : I , '=' ) ;
            PRNTTYPE ( IDTYPE ) ;
          end (* with *)
      end (* PRNTVAR *) ;


   begin (* PRNTSYMBL *)
     if PRCODE then
       if LCP <> NIL then
         with LCP -> do
           begin
             if KLASS = VARS then
               begin
                 LINELN := 5 ;
                 if VKIND = FORMAL then
                   begin
                     WRITE ( DBGINFO , '@ ' ) ;
                     LINELN := 7
                   end (* then *) ;
                 WRITE ( DBGINFO , VADDR : 1 , ' ' ) ;
                 if STKLASS = XAUTO then
                   WRITE ( DBGINFO , 'A' )
                 else
                   WRITE ( DBGINFO , 'S' ) ;
                 WRITE ( DBGINFO , ' ' ) ;
                 PRNTVAR ( LCP ) ;
               end (* then *)
             else
               if KLASS in [ PROC , FUNC ] then
                 begin
                   WRITELN ( DBGINFO , '% ' , NAME , ' ' , PFNAME ) ;
                   LCP := PRMPTR ;
                   while LCP <> NIL do

     (*****************************)
     (* SKIP PROC/FUNC PARAMETERS *)
     (*****************************)

                     begin
                       if LCP -> . KLASS = VARS then
                         PRNTSYMBL ( LCP ) ;
                       LCP := LCP -> . NEXT
                     end (* while *) ;
                 end (* then *) ;
             WRITELN ( DBGINFO ) ;
           end (* with *)
       else

     (**************************************)
     (* DUMP HEAP STORAGE TYPE DEFINITIONS *)
     (**************************************)

         begin
           TPT1 := PRNTTYPHD ;
           while TPT1 <> NIL do
             begin
               WRITE ( DBGINFO , '>' , TPT1 -> . TNO : 1 , ' ' ) ;
               LINELN := 5 ;
               PRNTTYPE ( TPT1 -> . ELT ) ;
               WRITELN ( DBGINFO ) ;
               TPT1 := TPT1 -> . NXT ;
             end (* while *) ;
           PRNTTYPHD := NIL ;
           PRNTTYNO := 0 ;
         end (* else *) ;
   end (* PRNTSYMBL *) ;



procedure PROC_TO_STATNAME ( PROCNAME : EXTNAMTP ; EXTRN : BOOLEAN ;
                           var STATNAME : EXTNAMTP ) ;

(******************************************************)
(* builds static csect name from procedure csect name *)
(* by inserting some # chars somewhere                *)
(******************************************************)


   var LMAX : INTEGER ;

   begin (* PROC_TO_STATNAME *)
     STATNAME := PROCNAME ;
     LMAX := EXTNAMSZ ;
     if not EXTRN then
       LMAX := 4 ;
     repeat
       STATNAME [ LMAX ] := '#' ;
       LMAX := LMAX - 1
     until STATNAME [ LMAX ] <> ' ' ;
   end (* PROC_TO_STATNAME *) ;



procedure BLOCK ( FSYS : SETOFSYS ; FSY : SYMBOL ; FPROCP : IDP ) ;

   var LSY : SYMBOL ;
       TEST : BOOLEAN ;
       SEGSIZE : LABELRNG ;
       LCP , FWRDPRCL : IDP ;
       DEC_ORDER : 0 .. 4 ;
       PLOCAL : BOOLEAN ;
       STATIC_VORHANDEN : BOOLEAN ;


   procedure SKIP ( FSYS : SETOFSYS ) ;

   (***********************************************)
   (*SKIP INPUT STRING UNTIL RELEVANT SYMBOL FOUND*)
   (***********************************************)


      begin (* SKIP *)
        while not ( SY in FSYS ) do
          INSYMBOL ;
      end (* SKIP *) ;


   procedure ALIGN ( var Q : ADDRRANGE ; P : ADDRRANGE ) ;

      begin (* ALIGN *)
        case P of
          REALSIZE :
            Q := ( ( Q + 7 ) DIV 8 ) * 8 ;
          INTSIZE :
            Q := ( ( Q + 3 ) DIV 4 ) * 4 ;
          HINTSIZE :
            if ODD ( Q ) then
              Q := Q + 1 ;
          CHARSIZE :
            ;
          otherwise
            if ERRORCNT = 0 then
              ERROR ( 401 ) ;
        end (* case *) ;
      end (* ALIGN *) ;


   procedure GEN_STRCONST ( VAL : XCONSTANT ) ;

   (*****************************)
   (* generate string constant  *)
   (* into file prr             *)
   (*****************************)


      var I : INTEGER ;
          OUTPOS : INTEGER ;

      begin (* GEN_STRCONST *)
        with VAL , VAL . SVAL -> do
          begin
            WRITE ( PRR , LENGTH : 1 , ',' ) ;
            if STRTYPE in [ 'B' , 'X' ] then
              WRITE ( PRR , STRTYPE ) ;
            WRITE ( PRR , '''' ) ;
            OUTPOS := 4 ;
            I := 1 ;
            while I <= LENGTH do
              begin
                if OUTPOS >= 56 then
                  begin
                    WRITELN ( PRR , ''',' ) ;
                    WRITE ( PRR , '       ''' ) ;
                    OUTPOS := 0 ;
                  end (* then *) ;
                case STRTYPE of
                  'X' : begin
                          WRITEHEXBYTE ( PRR , ORD ( SSTR [ I ] ) ) ;
                          OUTPOS := OUTPOS + 2 ;
                        end (* tag/ca *) ;
                  'B' : begin
                          WRITEBINBYTE ( PRR , ORD ( SSTR [ I ] ) ) ;
                          OUTPOS := OUTPOS + 8 ;
                        end (* tag/ca *) ;
                  otherwise
                    begin
                      WRITE ( PRR , SSTR [ I ] : 1 ) ;
                      OUTPOS := OUTPOS + 1 ;
                      if SSTR [ I ] = '''' then
                        begin
                          WRITE ( PRR , '''' ) ;
                          OUTPOS := OUTPOS + 1
                        end (* then *) ;
                    end (* otherw *)
                end (* case *) ;
                I := I + 1
              end (* while *) ;
            WRITE ( PRR , '''' ) ;
          end (* with *)
      end (* GEN_STRCONST *) ;


   procedure MOD_STRCONST ( CT_RESULT : INTEGER ; var V : XCONSTANT ;
                          var TYP : TTP ; SIZE_NEU : INTEGER ) ;

   (************************************************************)
   (* modify string constant: add blanks up to size            *)
   (* change size to new size                                  *)
   (************************************************************)
   (* if no string (valp), but char of length 1,               *)
   (* change constant to string and adjust length              *)
   (* as in the other (simpler) case                           *)
   (************************************************************)
   (* if typ is given, modify it to char array type            *)
   (* (later charstring)                                       *)
   (************************************************************)


      var I : INTEGER ;
          CH : CHAR ;
          CP : CONSTP ;

      begin (* MOD_STRCONST *)
        case CT_RESULT of
          2 : begin
                with V . SVAL -> do
                  begin
                    for I := LENGTH + 1 to SIZE_NEU do
                      SSTR [ I ] := ' ' ;
                    LENGTH := SIZE_NEU ;
                  end (* with *)
              end (* tag/ca *) ;
          3 : begin
                if TYP = CHARPTR then
                  begin
                    NEW ( TYP , ARRAYS ) ;
                    with TYP -> do
                      begin
                        AELTYPE := CHARPTR ;
                        INXTYPE := NIL ;
                        SIZE := SIZE_NEU * CHARSIZE ;
                        FORM := ARRAYS ;
                        ALN := CHARSIZE ;
                      end (* with *)
                  end (* then *) ;
                CH := CHR ( V . IVAL ) ;
                NEW ( V . SVAL ) ;
                with V . SVAL -> do
                  begin
                    TAG := 'S' ;
                    SSTR := ' ' ;
                    SSTR [ 1 ] := CH ;
                    LENGTH := SIZE_NEU ;
                  end (* with *)
              end (* tag/ca *) ;
        end (* case *) ;
      end (* MOD_STRCONST *) ;


   procedure CONSTANT ( FSYS : SETOFSYS ; var FSP : TTP ; var FVALU :
                      XCONSTANT ) ;

      var LSP : TTP ;
          LCP : IDP ;
          SIGN : ( NONE , POS , NEG ) ;
          LVP : CONSTP ;
          I : 2 .. REALLNGTH ;

      begin (* CONSTANT *)
        LSP := NIL ;
        FVALU . IVAL := 0 ;
        FVALU . STRTYPE := ' ' ;
        if not ( SY in CONSTBEGSYS ) then
          begin
            ERROR ( 50 ) ;
            SKIP ( FSYS + CONSTBEGSYS )
          end (* then *) ;
        if SY in CONSTBEGSYS then
          begin
            if SY = STRINGCONST then
              begin
                if LNGTH <= 1 then
                  LSP := CHARPTR
                else
                  begin
                    NEW ( LSP , ARRAYS ) ;
                    with LSP -> do
                      begin
                        AELTYPE := CHARPTR ;
                        INXTYPE := NIL ;
                        SIZE := LNGTH * CHARSIZE ;
                        FORM := ARRAYS ;
                        ALN := CHARSIZE ;
                      end (* with *)
                  end (* else *) ;
                FVALU := VAL ;
                INSYMBOL
              end (* then *)
            else
              begin
                SIGN := NONE ;
                if ( SY = ADDOP ) and ( OP in [ PLUS , MINUS ] ) then
                  begin
                    if OP = PLUS then
                      SIGN := POS
                    else
                      SIGN := NEG ;
                    INSYMBOL
                  end (* then *) ;
                if SY = IDENT then
                  begin
                    DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE , [ KONST
                                 ] , LCP ) ;
                    with LCP -> do
                      begin
                        LSP := IDTYPE ;
                        FVALU := VALUES
                      end (* with *) ;
                    if SIGN <> NONE then
                      if LSP = INTPTR then
                        begin
                          if SIGN = NEG then
                            FVALU . IVAL := - FVALU . IVAL
                        end (* then *)
                      else
                        if LSP = REALPTR then
                          begin
                            if SIGN = NEG then
                              begin
                                if FVALU . RVAL [ 1 ] = '-' then
                                  FVALU . RVAL [ 1 ] := '+'
                                else
                                  FVALU . RVAL [ 1 ] := '-' ;
                              end (* then *)
                          end (* then *)
                        else
                          ERROR ( 105 ) ;
                    INSYMBOL ;
                  end (* then *)
                else
                  if SY = INTCONST then
                    begin
                      if SIGN = NEG then
                        VAL . IVAL := - VAL . IVAL ;
                      LSP := INTPTR ;
                      FVALU := VAL ;
                      INSYMBOL
                    end (* then *)
                  else
                    if SY = REALCONST then
                      begin
                        if SIGN = NEG then
                          VAL . RVAL [ 1 ] := '-' ;
                        LSP := REALPTR ;
                        FVALU := VAL ;
                        INSYMBOL
                      end (* then *)
                    else
                      begin
                        ERROR ( 106 ) ;
                        SKIP ( FSYS )
                      end (* else *)
              end (* else *) ;
            if not ( SY in FSYS ) then
              begin
                ERROR ( 6 ) ;
                SKIP ( FSYS )
              end (* then *)
          end (* then *) ;
        FSP := LSP
      end (* CONSTANT *) ;


   function COMPTYPES ( FSP1 , FSP2 : TTP ) : INTEGER ;

   (***********************************************************)
   (* DECIDE WHETHER STRUCTURES POINTED AT BY FSP1 AND FSP2   *)
   (* ARE COMPATIBLE                                          *)
   (*---------------------------------------------------------*)
   (* 09.2016 - bernd oppolzer                                *)
   (* function result type changed from boolean to integer    *)
   (* 0: not compatible                                       *)
   (* 1: compatible                                           *)
   (* 2: char arrays with different lengths, size1 > size2    *)
   (* 3: fsp1 = char array, fsp2 = single char                *)
   (***********************************************************)


      var NXT1 , NXT2 : IDP ;
          COMP : INTEGER ;
          LTESTP1 , LTESTP2 : TESTP ;

      begin (* COMPTYPES *)

        (**********************************************************)
        (* comptypes ok, wenn typen gleich sind (gleiches         *)
        (* typ-objekt)                                            *)
        (**********************************************************)

        if FSP1 = FSP2 then
          begin
            COMPTYPES := 1 ;
            return
          end (* then *) ;

        (**********************************************************)
        (* comptypes ok, wenn einer der beiden typen nil ist      *)
        (* zur vermeidung von folgefehlern                        *)
        (**********************************************************)

        if ( FSP1 = NIL ) or ( FSP2 = NIL ) then
          begin
            COMPTYPES := 1 ;
            return
          end (* then *) ;

        (**********************************************************)
        (* jetzt kommen die normalfaelle, wenn die typklasse      *)
        (* dieselbe ist                                           *)
        (**********************************************************)

        if FSP1 -> . FORM = FSP2 -> . FORM then
          begin
            case FSP1 -> . FORM of
              SCALAR :
                COMPTYPES := 0 ;

        (**********************************************************)
        (* IDENTICAL SCALARS DECLARED ON DIFFERENT LEVELS ARE     *)
        (*                  NOT RECOGNIZED TO BE COMPATIBLE       *)
        (**********************************************************)

              SUBRANGE :
                COMPTYPES := COMPTYPES ( FSP1 -> . RANGETYPE , FSP2 ->
                             . RANGETYPE ) ;
              POINTER :
                begin
                  COMP := 0 ;
                  LTESTP1 := GLOBTESTP ;
                  LTESTP2 := GLOBTESTP ;
                  while LTESTP1 <> NIL do
                    with LTESTP1 -> do
                      begin
                        if ( ELT1 = FSP1 -> . ELTYPE ) and ( ELT2 =
                        FSP2 -> . ELTYPE ) then
                          COMP := 1 ;
                        LTESTP1 := LASTTESTP
                      end (* with *) ;
                  if COMP = 0 then
                    begin
                      NEW ( LTESTP1 ) ;
                      with LTESTP1 -> do
                        begin
                          ELT1 := FSP1 -> . ELTYPE ;
                          ELT2 := FSP2 -> . ELTYPE ;
                          LASTTESTP := GLOBTESTP
                        end (* with *) ;
                      GLOBTESTP := LTESTP1 ;
                      COMP := COMPTYPES ( FSP1 -> . ELTYPE , FSP2 -> .
                              ELTYPE )
                    end (* then *) ;
                  COMPTYPES := COMP ;
                  GLOBTESTP := LTESTP2
                end (* tag/ca *) ;
              POWER : COMPTYPES := COMPTYPES ( FSP1 -> . ELSET , FSP2
                                   -> . ELSET ) ;

        (**********************************************************)
        (* hier besonderheit und modifikation:                    *)
        (* char arrays mit unterschiedlicher laenge               *)
        (* ergeben comptypes = 2 (wenn zweiter laenger als 1.)    *)
        (**********************************************************)

              ARRAYS :
                begin
                  COMP := 0 ;
                  if ( COMPTYPES ( FSP1 -> . AELTYPE , FSP2 -> .
                  AELTYPE ) > 0 ) and ( FSP1 -> . SIZE = FSP2 -> . SIZE
                  ) then
                    COMP := 1 ;
                  if COMP = 0 then
                    if ( FSP1 -> . AELTYPE = CHARPTR ) and ( FSP2 -> .
                    AELTYPE = CHARPTR ) and ( FSP1 -> . SIZE > FSP2 ->
                    . SIZE ) and ( FSP1 -> . SIZE <= MAXSTRL ) then
                      COMP := 2 ;
                  COMPTYPES := COMP ;
                end (* tag/ca *) ;

        (**************************************************************)
        (*ALTERNATIVES: -- ADD A THIRD BOOLEAN TERM: INDEXTYPE MUST   *)
        (*                 BE COMPATIBLE.                             *)
        (*              -- ADD A FOURTH BOOLEAN TERM: LOWBOUNDS MUST  *)
        (*                 BE THE SAME                                *)
        (**************************************************************)

              RECORDS :
                begin
                  COMP := 0 ;
                  NXT1 := FSP1 -> . FSTFLD ;
                  NXT2 := FSP2 -> . FSTFLD ;
                  if ( FSP1 -> . RECVAR = FSP2 -> . RECVAR ) then
                    COMP := 1 ;
                  while ( COMP = 1 ) and ( NXT1 <> NIL ) and ( NXT2 <>
                  NIL ) do
                    begin
                      if COMPTYPES ( NXT1 -> . IDTYPE , NXT2 -> .
                      IDTYPE ) = 0 then
                        COMP := 0 ;
                      if NXT1 -> . IDTYPE -> . SIZE <> NXT2 -> . IDTYPE
                      -> . SIZE then
                        COMP := 0 ;
                      NXT1 := NXT1 -> . NEXT ;
                      NXT2 := NXT2 -> . NEXT
                    end (* while *) ;
                  if ( COMP = 1 ) and ( NXT1 = NIL ) and ( NXT2 = NIL )
                  then
                    COMPTYPES := 1
                  else
                    COMPTYPES := 0
                end (* tag/ca *) ;

        (**************************************************************)
        (*IDENTICAL RECORDS ARE RECOGNIZED TO BE COMPATIBLE           *)
        (*                  IFF NO VARIANTS OCCUR                     *)
        (**************************************************************)

              FILES : COMPTYPES := COMPTYPES ( FSP1 -> . FILTYPE , FSP2
                                   -> . FILTYPE )
            end (* case *) ;
            return
          end (* then *) ;

        (**********************************************************)
        (* jetzt kommen die faelle, wo die typklasse nicht        *)
        (* uebereinstimmt                                         *)
        (* FSP1 -> . FORM <> FSP2 -> . FORM                       *)
        (**********************************************************)

        if FSP1 -> . FORM = SUBRANGE then
          begin
            COMPTYPES := COMPTYPES ( FSP1 -> . RANGETYPE , FSP2 ) ;
            return
          end (* then *) ;
        if FSP2 -> . FORM = SUBRANGE then
          begin
            COMPTYPES := COMPTYPES ( FSP1 , FSP2 -> . RANGETYPE ) ;
            return
          end (* then *) ;

        (**********************************************************)
        (* neu: korrekt ist auch, wenn links ein char-array       *)
        (* steht und rechts ein einzelner char                    *)
        (* dann wird comptypes = 3 zurueckgegeben                 *)
        (**********************************************************)

        if ( FSP1 -> . FORM = ARRAYS ) and ( FSP1 -> . AELTYPE =
        CHARPTR ) and ( FSP2 = CHARPTR ) and ( FSP1 -> . SIZE <=
        MAXSTRL ) then
          begin
            COMPTYPES := 3 ;
            return
          end (* then *) ;
        COMPTYPES := 0
      end (* COMPTYPES *) ;


   function XSTRING ( FSP : TTP ) : BOOLEAN ;

      begin (* XSTRING *)
        XSTRING := FALSE ;
        if FSP <> NIL then
          begin
            if FSP -> . FORM = ARRAYS then
              XSTRING := ( COMPTYPES ( FSP -> . AELTYPE , CHARPTR ) = 1
                         )
          end (* then *)
      end (* XSTRING *) ;


   procedure PUTIC ;

      begin (* PUTIC *)
        if LINECNT > OLDLN then
          begin
            WRITELN ( PRR , ' LOC ' , LINECNT : 1 ) ;
            OLDLN := LINECNT
          end (* then *) ;
      end (* PUTIC *) ;


   procedure CHECKSTARTCST ;

      var I : INTEGER ;
          CSTEXTNAME : EXTNAMTP ;

      begin (* CHECKSTARTCST *)
        if CONSTLCOUNTER < 0 then

        (****************************)
        (* NO CONSTANTS WRITTEN YET *)
        (****************************)

          with FPROCP -> do
            begin
              CSTEXTNAME := FPROCP -> . CSTNAME ;

        (********)
        (*CST   *)
        (********)

              WRITELN ( PRR , CSTEXTNAME , MN [ 71 ] , ' ' , NAME ,
                        PFNAME : 5 , ',' , ASSEMBLE : 1 , ',' ,
                        GET_STAT : 1 , ',' , ASMVERB : 1 ) ;
              CONSTLCOUNTER := FIRSTCONSTLC ;
            end (* with *) ;
      end (* CHECKSTARTCST *) ;


   procedure BUILD_SET ( var SETVAL : XCONSTANT ; PSI : PSETINFO ) ;

      var LVP : SSP ;
          SETMIN_NEW : INTEGER ;
          SETMAX_NEW : INTEGER ;
          SETSIZE : INTEGER ;
          I : INTEGER ;
          TX : INTEGER ;
          W : INTEGER ;

      begin (* BUILD_SET *)
        NEW ( SETVAL . PVAL ) ;
        LVP := SETVAL . PVAL ;
        for I := 1 to MAXSETL do
          LVP -> . PSTR [ I ] := CHR ( 0 ) ;
        SETVAL . STRTYPE := PSI -> . HEXORBIN ;
        CALC_SETSIZE ( PSI -> . SETMIN , PSI -> . SETMAX , SETMIN_NEW ,
                       SETSIZE ) ;
        SETMAX_NEW := PSI -> . SETMAX - MODP ( PSI -> . SETMAX , 8 ) +
                      7 ;
        if FALSE then
          begin
            WRITELN ( TRACEF ) ;
            WRITELN ( TRACEF , 'start build_set' ) ;
            WRITELN ( TRACEF , 'psi.setmin    = ' , PSI -> . SETMIN ) ;
            WRITELN ( TRACEF , 'psi.setmax    = ' , PSI -> . SETMAX ) ;
            WRITELN ( TRACEF , 'setmin_new    = ' , SETMIN_NEW ) ;
            WRITELN ( TRACEF , 'setmax_new    = ' , SETMAX_NEW ) ;
            WRITELN ( TRACEF , 'setsize       = ' , SETSIZE ) ;
          end (* then *) ;
        TX := 0 ;
        W := 0 ;
        for I := SETMIN_NEW to SETMAX_NEW do
          begin
            if I MOD 8 = 0 then
              begin
                if TX > 0 then
                  begin
                    if FALSE then
                      WRITELN ( TRACEF , 'pval ' , TX : 1 , ' = chr ' ,
                                W : 1 ) ;
                    LVP -> . PSTR [ TX ] := CHR ( W ) ;
                  end (* then *) ;
                TX := TX + 1 ;
                W := 0 ;
              end (* then *) ;
            W := W * 2 ;
            if ( I >= PSI -> . SETMIN ) and ( I <= PSI -> . SETMAX )
            then
              if ( PSI -> . SETELEMS [ I - PSI -> . SETMIN + 1 ] ) then
                W := W + 1 ;
          end (* for *) ;
        if TX > 0 then
          begin
            if FALSE then
              WRITELN ( TRACEF , 'pstr ' , TX : 1 , ' = chr ' , W : 1 )
                        ;
            LVP -> . PSTR [ TX ] := CHR ( W ) ;
          end (* then *) ;
        if FALSE then
          WRITELN ( TRACEF ) ;
        SETVAL . SETMIN := PSI -> . SETMIN ;
        SETVAL . SETMAX := PSI -> . SETMAX ;
        SETVAL . SETOFFS := SETMIN_NEW DIV 8 ;
        LVP -> . TAG := 'P' ;
        LVP -> . LENGTH := SETSIZE ;
      end (* BUILD_SET *) ;


   procedure WRITESET ( VAL : XCONSTANT ; ELTYPE : TTP ) ;

      var I , W , X , COL , LEN : INTEGER ;
          S : SETSTRING ;
          CW : INTEGER ;
          CH : CHAR ;
          HEXORBIN : BOOLEAN ;

      begin (* WRITESET *)
        LEN := VAL . PVAL -> . LENGTH ;
        S := VAL . PVAL -> . PSTR ;
        HEXORBIN := not ( VAL . STRTYPE in [ ' ' , 'N' ] ) ;

        (***********************)
        (* empty = leere menge *)
        (***********************)

        if LEN = 0 then
          WRITELN ( PRR , '0,E()' )
        else
          if ( ELTYPE = CHARPTR ) and not HEXORBIN then

        (***************************************************)
        (* menge mit basistyp = char oder subrange davon   *)
        (* dann zeichen ausgeben - portable darstellung    *)
        (***************************************************)
        (* immer laenge 32 - anderen orts wird dafuer      *)
        (* gesorgt, dass sets of char immer 32 bytes lang  *)
        (* sind - siehe function opndsetsize               *)
        (***************************************************)
        (* 06.2017 - modifikation                          *)
        (* die sets werden intern anders abgelegt ...      *)
        (* setoffs gibt an, wo die interne darstellung     *)
        (* beginnt (mit wieviel bytes versatz)             *)
        (* setsize gibt die anzahl belegte bytes an        *)
        (* - plus 4 fuer die metadaten                     *)
        (***************************************************)

            begin
              WRITE ( PRR , '0,C''' ) ;
              CW := VAL . SETOFFS * 8 ;
              COL := 11 ;
              for I := 1 to LEN - 4 do
                begin
                  W := ORD ( S [ I ] ) ;
                  X := 128 ;
                  while X > 0 do
                    begin
                      if ( W and X ) <> 0 then
                        begin
                          CH := CHR ( CW ) ;
                          if COL >= 65 then
                            begin
                              WRITELN ( PRR , ''',' ) ;
                              COL := 7 ;
                              WRITE ( PRR , '     ''' ) ;
                            end (* then *) ;
                          WRITE ( PRR , CH ) ;
                          COL := COL + 1 ;
                        end (* then *) ;
                      X := X DIV 2 ;
                      CW := CW + 1 ;
                    end (* while *) ;
                end (* for *) ;
              WRITELN ( PRR , '''' )
            end (* then *)
          else

        (***************************************************)
        (* menge mit anderen Basistypen,                   *)
        (* dann menge als bitstring in hex-darstellung     *)
        (***************************************************)

            begin
              WRITE ( PRR , VAL . SETOFFS : 1 , ',' ) ;
              WRITE ( PRR , 'X' , LEN - 4 : 1 , '''' ) ;
              COL := 18 ;
              for I := 1 to LEN - 4 do
                begin
                  if COL >= 65 then
                    begin
                      WRITELN ( PRR , ''',' ) ;
                      COL := 7 ;
                      WRITE ( PRR , '     ''' ) ;
                    end (* then *) ;
                  WRITEHEXBYTE ( PRR , ORD ( S [ I ] ) ) ;
                  COL := COL + 2 ;
                end (* for *) ;
              WRITELN ( PRR , '''' )
            end (* else *) ;
      end (* WRITESET *) ;


   procedure NORMALIZE_SETCONST ( var LVALU : XCONSTANT ; SETOFFS_NEW :
                                INTEGER ) ;

   (***************************************************)
   (* normalize_setconst                              *)
   (* setoffs_new shall be the new setoffs of the     *)
   (* set constant, inherited from the set type.      *)
   (* the set representation (bit string) has to      *)
   (* be changed (shifted) accordingly                *)
   (***************************************************)


      var I : INTEGER ;
          SHIFT : INTEGER ;

      begin (* NORMALIZE_SETCONST *)
        with LVALU , LVALU . PVAL -> do
          begin
            SHIFT := SETOFFS - SETOFFS_NEW ;
            for I := LENGTH DOWNTO SHIFT + 1 do
              PSTR [ I ] := PSTR [ I - SHIFT ] ;
            for I := 1 to SHIFT do
              PSTR [ I ] := CHR ( 0 ) ;
            SETOFFS := SETOFFS_NEW ;
          end (* with *)
      end (* NORMALIZE_SETCONST *) ;


   procedure WRITEDFC ( ELSP1 : TTP ; ELSIZE : INTEGER ; LVALU :
                      XCONSTANT ; INIT : BOOLEAN ) ;

      var CH : CHAR ;

      begin (* WRITEDFC *)
        PUTIC ;
        WRITE ( PRR , CONSTLCOUNTER : 1 , MN [ 70 ] ) ;

        (********)
        (*DFC   *)
        (********)

        if INIT then
          begin
            if ELSP1 = REALPTR then
              WRITELN ( PRR , ' R,' , 0.0 )
            else
              if ELSP1 -> . FORM <= SUBRANGE then
                begin
                  CH := 'I' ;
                  if ELSIZE = 2 then
                    CH := 'H'
                  else
                    if ELSIZE = 1 then
                      if ELSP1 = CHARPTR then
                        CH := 'C'
                      else
                        CH := 'B' ;
                  if CH = 'C' then
                    WRITELN ( PRR , CH : 2 , ','' ''' )
                  else
                    WRITELN ( PRR , CH : 2 , ',' , 0 : 1 )
                end (* then *)
              else
                if ELSP1 -> . FORM = POINTER then
                  WRITELN ( PRR , ' N' )
                else
                  if XSTRING ( ELSP1 ) then
                    begin
                      WRITE ( PRR , ' M,' ) ;
                      WRITE ( PRR , '''' , ' ' : ELSIZE , '''' ) ;
                      WRITELN ( PRR ) ;
                    end (* then *)
                  else
                    begin
                      WRITE ( PRR , ' 0,' , ELSIZE : 1 ) ;
                      WRITELN ( PRR ) ;
                    end (* else *)
          end (* then *)
        else
          begin
            if ELSP1 = NIL then
              return ;
            if ELSP1 = REALPTR then
              begin
                WRITELN ( PRR , ' R,' , LVALU . RVAL ) ;
                return
              end (* then *) ;
            if ELSP1 -> . FORM <= SUBRANGE then
              begin
                CH := 'I' ;
                if ELSIZE = 2 then
                  CH := 'H'
                else
                  if ELSIZE = 1 then
                    if ELSP1 = CHARPTR then
                      CH := 'C'
                    else
                      CH := 'B' ;
                if CH = 'C' then
                  WRITELN ( PRR , CH : 2 , ',' , '''' , CHR ( LVALU .
                            IVAL ) , '''' )
                else
                  WRITELN ( PRR , CH : 2 , ',' , LVALU . IVAL : 1 ) ;
                return ;
              end (* then *) ;
            if ELSP1 -> . FORM = POINTER then
              begin
                WRITELN ( PRR , ' N' ) ;
                return
              end (* then *) ;
            if ELSP1 -> . FORM = POWER then
              begin
                WRITE ( PRR , ' S,' ) ;
                LVALU . PVAL -> . LENGTH := ELSP1 -> . SIZE ;

        (***************************************************)
        (* when writing set consts in DFC statements,      *)
        (* the setoffs should be built according to the    *)
        (* type of the setconst. so the set representation *)
        (* must be normalized, that is: shifted to the     *)
        (* right (in some cases), and the setoffs has      *)
        (* to be adjusted                                  *)
        (***************************************************)

                if FALSE then
                  begin
                    WRITELN ( TRACEF , 'dcf/set - elsp1->.setoffs = ' ,
                              ELSP1 -> . SETOFFS ) ;
                    WRITELN ( TRACEF , 'dcf/set - lvalu->.setoffs = ' ,
                              LVALU . SETOFFS ) ;
                    WRITELN ( TRACEF , '-------------------------' )
                  end (* then *) ;
                if ELSP1 -> . SETOFFS <> LVALU . SETOFFS then
                  begin
                    NORMALIZE_SETCONST ( LVALU , ELSP1 -> . SETOFFS ) ;
                    if FALSE then
                      begin
                        WRITELN ( TRACEF , 'nach korrektur:' ) ;
                        WRITELN ( TRACEF ,
                                  'dcf/set - elsp1->.setoffs = ' ,
                                  ELSP1 -> . SETOFFS ) ;
                        WRITELN ( TRACEF ,
                                  'dcf/set - lvalu->.setoffs = ' ,
                                  LVALU . SETOFFS ) ;
                        WRITELN ( TRACEF , '-------------------------'
                                  )
                      end (* then *)
                  end (* then *) ;
                WRITESET ( LVALU , ELSP1 -> . ELSET ) ;
                return ;
              end (* then *) ;
            if XSTRING ( ELSP1 ) then
              begin
                WRITE ( PRR , ' M,' ) ;
                GEN_STRCONST ( LVALU ) ;
                WRITELN ( PRR ) ;
                return ;
              end (* then *)
          end (* else *)
      end (* WRITEDFC *) ;


   procedure TYP ( FSYS : SETOFSYS ; var FSP : TTP ; var FSIZE :
                 ADDRRANGE ) ;

      var LSP , LSP1 , LSP2 : TTP ;
          OLDTOP : DISPRANGE ;
          LCP , LCP2 : IDP ;
          LSIZE , DISPL : ADDRRANGE ;
          LMIN , LMAX : INTEGER ;
          ALNFCT : ALNRNG ;
          OLDPACKST , PACKST2 : BOOLEAN ;


      procedure SIMPLETYPE ( FSYS : SETOFSYS ; var FSP : TTP ) ;

         var LSP , LSP1 : TTP ;
             LCP , LCP1 : IDP ;
             TTOP : DISPRANGE ;
             LCNT : INTEGER ;
             LVALU : XCONSTANT ;
             FLAG : BOOLEAN ;
             VALX : XCONSTANT ;
             SCAL_OFFS : INTEGER ;
             IDL : INTEGER ;
             IX : INTEGER ;

         begin (* SIMPLETYPE *)
           if not ( SY in SIMPTYPEBEGSYS ) then
             begin
               ERROR ( 1 ) ;
               SKIP ( FSYS + SIMPTYPEBEGSYS )
             end (* then *) ;
           if SY in SIMPTYPEBEGSYS then
             begin
               if SY = LPARENT then
                 begin
                   TTOP := TOP ;

           (***********************************************)
           (*  declare new scalar type                    *)
           (***********************************************)

                   TOP := LEVEL ;
                   NEW ( LSP , SCALAR , DECLARED ) ;
                   with LSP -> do
                     begin
                       SIZE := INTSIZE ;
                       FORM := SCALAR ;
                       SCALKIND := DECLARED
                     end (* with *) ;

           (***********************************************)
           (*  declare constants which belong to the new  *)
           (*  scalar type                                *)
           (***********************************************)

                   LCP1 := NIL ;
                   LCNT := 0 ;
                   repeat
                     INSYMBOL ;
                     if SY = IDENT then
                       begin
                         NEW ( LCP , KONST ) ;
                         with LCP -> do
                           begin
                             NAME := ID ;
                             IDTYPE := LSP ;
                             NEXT := LCP1 ;
                             VALUES . IVAL := LCNT ;
                             VALUES . STRTYPE := ' ' ;
                             KLASS := KONST
                           end (* with *) ;
                         ENTERID ( LCP ) ;
                         LCNT := LCNT + 1 ;
                         LCP1 := LCP ;
                         INSYMBOL
                       end (* then *)
                     else
                       ERROR ( 2 ) ;
                     if not ( SY in FSYS + [ COMMA , RPARENT ] ) then
                       begin
                         ERROR ( 6 ) ;
                         SKIP ( FSYS + [ COMMA , RPARENT ] )
                       end (* then *)
                   until SY <> COMMA ;
                   if not NOPACKING then
                     begin
                       LSP -> . SIZE := HINTSIZE ;
                       if PACKDATA then
                         if LCNT <= ORDCHMAX then
                           LSP -> . SIZE := CHARSIZE
                     end (* then *) ;
                   LSP -> . ALN := LSP -> . SIZE ;
                   LSP -> . FCONST := LCP1 ;

           /***************************************/
           /*  im statischen Bereich Vektor mit   */
           /*  den namen der skalaren konstanten  */
           /*  anlegen fuer die spaeteren         */
           /*  ein- und ausgabe-Funktionen        */
           /*-------------------------------------*/
           /*  erweiterung opp - 11.2016          */
           /***************************************/

                   CHECKSTARTCST ;

           /*****************************************************/
           /*  zunaechst einen vektor aus Halbworten mit        */
           /*  Offset und Laenge der Bezeichnungen anlegen;     */
           /*  letzte zuerst; Anzahl = hoechster Wert plus      */
           /*  eins, Offset demnach (Anzahl + 1) * 4.           */
           /*  Die Offsets werden je nach Laenge des            */
           /*  Bezeichners weitergeschaltet. Anhand des         */
           /*  Offsets kann man auch die Groesse des            */
           /*  Vektors und damit die Groesse des skalaren       */
           /*  Typs ableiten                                    */
           /*****************************************************/

                   ALIGN ( CONSTLCOUNTER , HINTSIZE ) ;
                   LSP -> . CSTNAME := FPROCP -> . CSTNAME ;
                   LSP -> . LITOFFS := CONSTLCOUNTER ;
                   LCP1 := LSP -> . FCONST ;
                   SCAL_OFFS := ( LCP1 -> . VALUES . IVAL ) + 1 ;
                   SCAL_OFFS := SCAL_OFFS * 4 ;
                   while LCP1 <> NIL do
                     begin
                       VALX . IVAL := SCAL_OFFS ;
                       VALX . STRTYPE := ' ' ;
                       WRITEDFC ( INTPTR , 2 , VALX , FALSE ) ;
                       CONSTLCOUNTER := CONSTLCOUNTER + 2 ;
                       VALX . IVAL := GETIDLEN ( LCP1 -> . NAME ) ;
                       VALX . STRTYPE := ' ' ;
                       WRITEDFC ( INTPTR , 2 , VALX , FALSE ) ;
                       CONSTLCOUNTER := CONSTLCOUNTER + 2 ;
                       SCAL_OFFS := SCAL_OFFS + VALX . IVAL + 1 ;
                       LCP1 := LCP1 -> . NEXT ;
                     end (* while *) ;

           /*****************************************************/
           /*  jetzt die Konstanten selbst ablegen              */
           /*****************************************************/

                   LCP1 := LSP -> . FCONST ;
                   while LCP1 <> NIL do
                     begin
                       IDL := GETIDLEN ( LCP1 -> . NAME ) + 1 ;
                       WRITEDFC ( NIL , IDL , VALX , FALSE ) ;
                       WRITE ( PRR , ' M,''' ) ;
                       for IX := 1 to IDL - 1 do
                         WRITE ( PRR , LCP1 -> . NAME [ IX ] ) ;
                       WRITELN ( PRR , ' ''' ) ;
                       CONSTLCOUNTER := CONSTLCOUNTER + IDL ;
                       LCP1 := LCP1 -> . NEXT ;
                     end (* while *) ;
                   IDL := 1 ;
                   WRITEDFC ( NIL , IDL , VALX , FALSE ) ;
                   WRITELN ( PRR , ' M,''*''' ) ;
                   CONSTLCOUNTER := CONSTLCOUNTER + IDL ;

           /***************************************/
           /*  ende erweiterung 11.2016           */
           /***************************************/

                   TOP := TTOP ;
                   if SY = RPARENT then
                     INSYMBOL
                   else
                     ERROR ( 4 )
                 end (* then *)
               else
                 begin
                   if SY = IDENT then
                     begin
                       DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE , [
                                    TYPES , KONST ] , LCP ) ;
                       INSYMBOL ;
                       if LCP -> . KLASS = KONST then
                         begin
                           NEW ( LSP , SUBRANGE ) ;
                           with LSP -> , LCP -> do
                             begin
                               RANGETYPE := IDTYPE ;
                               FORM := SUBRANGE ;
                               if XSTRING ( RANGETYPE ) then
                                 begin
                                   ERROR ( 148 ) ;
                                   RANGETYPE := NIL
                                 end (* then *) ;
                               MIN := VALUES ;
                               SIZE := IDTYPE -> . SIZE
                             end (* with *) ;
                         end (* then *)
                       else
                         LSP := NIL ;

           (************************)
           (* SIGNALS TYPE ID SEEN *)
           (************************)

                     end (* then *)
                   else
                     begin
                       NEW ( LSP , SUBRANGE ) ;
                       LSP -> . FORM := SUBRANGE ;
                       CONSTANT ( FSYS + [ DOTDOT ] , LSP1 , LVALU ) ;
                       if XSTRING ( LSP1 ) then
                         begin
                           ERROR ( 148 ) ;
                           LSP1 := NIL
                         end (* then *) ;
                       with LSP -> do
                         begin
                           RANGETYPE := LSP1 ;
                           MIN := LVALU ;
                           SIZE := INTSIZE ;
                           if LSP1 <> NIL then
                             SIZE := LSP1 -> . SIZE ;
                         end (* with *) ;
                     end (* else *) ;
                   if LSP <> NIL then

           (**********************)
           (* CONSTANT JUST SEEN *)
           (**********************)

                     begin
                       if SY = DOTDOT then
                         INSYMBOL
                       else
                         ERROR ( 5 ) ;
                       CONSTANT ( FSYS , LSP1 , LVALU ) ;
                       LSP -> . MAX := LVALU ;
                       if LSP1 -> . SIZE > CHARSIZE then

           (*********************)
           (* SCOPE FOR PACKING *)
           (*********************)

                         if not NOPACKING then
                           if LVALU . IVAL <= 32767 then
                             if LSP -> . MIN . IVAL >= - 32768 then
                               begin
                                 LSP -> . SIZE := HINTSIZE ;
                                 if PACKDATA then
                                   if LVALU . IVAL <= ORDCHMAX then
                                     if LSP -> . MIN . IVAL >= 0 then
                                       LSP -> . SIZE := CHARSIZE ;
                               end (* then *) ;
                       LSP -> . ALN := LSP -> . SIZE ;
                       if LSP -> . RANGETYPE <> LSP1 then
                         ERROR ( 107 )
                     end (* then *)
                   else
                     begin
                       LSP := LCP -> . IDTYPE ;
                       FLAG := FALSE ;
                       if PACKDATA then
                         if not NOPACKING then
                           if LSP <> NIL then
                             with LSP -> do
                               if SIZE > CHARSIZE then
                                 if FORM = SCALAR then
                                   if SCALKIND = DECLARED then
                                     begin
                                       LCNT := - 1 ;
                                       LCP1 := FCONST ;
                                       while LCP1 <> NIL do
                                         begin
                                           LCNT := LCNT + 1 ;
                                           LCP1 := LCP1 -> . NEXT ;
                                         end (* while *) ;
                                       if LCNT <= ORDCHMAX then
                                         FLAG := TRUE
                                     end (* then *)
                                   else
                                     
                                 else
                                   if FORM = SUBRANGE then
                                     if MIN . IVAL >= 0 then
                                       if MAX . IVAL <= ORDCHMAX then
                                         FLAG := TRUE ;
                       if FLAG then
                         begin

           (************************************)
           (*CREATE PACKED VERSION OF THIS TYPE*)
           (************************************)

                           NEW ( LSP1 ) ;
                           LSP1 -> := LSP -> ;
                           with LSP1 -> do
                             begin
                               SIZE := CHARSIZE ;
                               ALN := CHARSIZE ;
                               if FORM = SCALAR then

           (******************************)
           (* CONVERT TO SUBRANGE        *)
           (******************************)

                                 begin
                                   FORM := SUBRANGE ;
                                   RANGETYPE := LSP ;
                                   MIN . IVAL := 0 ;
                                   MAX . IVAL := LCNT ;
                                 end (* then *) ;
                             end (* with *) ;
                           LSP := LSP1 ;
                         end (* then *)
                     end (* else *) ;
                   if LSP <> NIL then
                     with LSP -> do
                       if FORM = SUBRANGE then
                         if RANGETYPE <> NIL then
                           if RANGETYPE = REALPTR then
                             ERROR ( 398 )
                           else
                             if MIN . IVAL > MAX . IVAL then
                               ERROR ( 102 )
                 end (* else *) ;
               FSP := LSP ;
               if not ( SY in FSYS ) then
                 begin
                   ERROR ( 6 ) ;
                   SKIP ( FSYS )
                 end (* then *)
             end (* then *)
           else
             FSP := NIL
         end (* SIMPLETYPE *) ;


      procedure FIELDLIST ( FSYS : SETOFSYS ; var FRECVAR : TTP ; var
                          RECALN : ALNRNG ; FLDOWNER : TTP ; var
                          FIRSTFLD : IDP ) ;

         label 10 ;

         var LCP , LCP1 , NXT , NXT1 : IDP ;
             LSP , LSP1 , LSP2 , LSP3 , LSP4 : TTP ;
             MINSIZE , MAXSIZE , LSIZE : ADDRRANGE ;
             LVALU : XCONSTANT ;
             LALNFCT : ALNRNG ;

         begin (* FIELDLIST *)
           NXT := NIL ;
           FIRSTFLD := NIL ;
           LSP := NIL ;
           RECALN := 1 ;
           if not ( SY in FSYS + [ IDENT , CASESY ] ) then
             begin
               ERROR ( 19 ) ;
               SKIP ( FSYS + [ IDENT , CASESY ] )
             end (* then *) ;
           while SY = IDENT do
             begin
               NXT1 := NIL ;
               repeat
                 if SY = IDENT then
                   begin
                     NEW ( LCP , FIELD ) ;
                     with LCP -> do
                       begin
                         NAME := ID ;
                         IDTYPE := NIL ;
                         NEXT := NIL ;
                         OWNER := FLDOWNER ;
                         KLASS := FIELD ;
                         if GET_STAT then
                           FLDOWNER -> . NO_FLDS := FLDOWNER -> .
                                                   NO_FLDS + 1 ;
                       end (* with *) ;
                     if NXT1 = NIL then
                       NXT1 := LCP ;
                     if NXT <> NIL then
                       NXT -> . NEXT := LCP ;
                     NXT := LCP ;
                     ENTERID ( LCP ) ;
                     INSYMBOL
                   end (* then *)
                 else
                   ERROR ( 2 ) ;
                 if not ( SY in [ COMMA , COLON ] ) then
                   begin
                     ERROR ( 6 ) ;
                     SKIP ( FSYS + [ COMMA , COLON , SEMICOLON , CASESY
                            ] )
                   end (* then *) ;
                 TEST := SY <> COMMA ;
                 if not TEST then
                   INSYMBOL
               until TEST ;
               if SY = COLON then
                 INSYMBOL
               else
                 ERROR ( 5 ) ;
               if FIRSTFLD = NIL then
                 FIRSTFLD := NXT1 ;
               TYP ( FSYS + [ CASESY , SEMICOLON ] , LSP , LSIZE ) ;
               LALNFCT := 1 ;
               if LSP <> NIL then
                 LALNFCT := LSP -> . ALN ;
               while NXT1 <> NIL do

           (******************************************)
           (* ANY "FIELDS" DEFINED IN THIS ROUND ?   *)
           (******************************************)

                 begin
                   with NXT1 -> do
                     begin
                       IDTYPE := LSP ;
                       ALIGN ( DISPL , LALNFCT ) ;
                       FLDADDR := DISPL ;
                       DISPL := DISPL + LSIZE ;
                       NXT1 := NEXT ;
                     end (* with *) ;
                 end (* while *) ;
               if LALNFCT > RECALN then
                 RECALN := LSP -> . ALN ;
               if SY = SEMICOLON then
                 begin
                   INSYMBOL ;
                   if not ( SY in [ IDENT , CASESY , ENDSY ] ) then

           (**********************)
           (* IGNOR EXTRA ;      *)
           (**********************)

                     begin
                       ERROR ( 19 ) ;
                       SKIP ( FSYS + [ IDENT , CASESY ] )
                     end (* then *)
                 end (* then *)
             end (* while *) ;
           if SY = CASESY then
             begin
               NEW ( LSP , TAGFLD ) ;
               with LSP -> do
                 begin
                   TAGFIELDP := NIL ;
                   FSTVAR := NIL ;
                   FORM := TAGFLD
                 end (* with *) ;
               FRECVAR := LSP ;
               INSYMBOL ;
               if SY = IDENT then
                 begin
                   NEW ( LCP , FIELD ) ;
                   with LCP -> do
                     begin
                       NAME := ID ;
                       IDTYPE := NIL ;
                       KLASS := FIELD ;
                       NEXT := NIL ;

           (****************************************)
           (*FLDADDR WILL BE SET WHEN TYPE IS KNOWN*)
           (****************************************)

                       OWNER := FLDOWNER ;
                       if GET_STAT then
                         FLDOWNER -> . NO_FLDS := FLDOWNER -> . NO_FLDS
                                                  + 1 ;
                     end (* with *) ;
                   INSYMBOL ;
                   if SY = COLON then

           (**********************)
           (* EXPLICIT TAG FIELD *)
           (**********************)

                     begin
                       ENTERID ( LCP ) ;
                       INSYMBOL ;
                       if SY <> IDENT then
                         goto 10
                     end (* then *)
                   else
                     begin
                       ID := LCP -> . NAME ;
                       LCP -> . NAME := BLANKID ;
                     end (* else *) ;
                   DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE , [ TYPES ]
                                , LCP1 ) ;
                   LSP1 := LCP1 -> . IDTYPE ;
                   if LSP1 <> NIL then
                     with LSP1 -> do
                       begin
                         if LCP -> . NAME <> BLANKID then
                           begin
                             ALIGN ( DISPL , ALN ) ;
                             if ALN > RECALN then
                               RECALN := ALN ;
                             LCP -> . FLDADDR := DISPL ;
                             DISPL := DISPL + SIZE ;
                           end (* then *) ;
                         if ( FORM <= SUBRANGE ) or XSTRING ( LSP1 )
                         then
                           begin
                             if COMPTYPES ( REALPTR , LSP1 ) = 1 then
                               ERROR ( 109 )
                             else
                               if XSTRING ( LSP1 ) then
                                 ERROR ( 398 ) ;
                             LCP -> . IDTYPE := LSP1 ;
                             LSP -> . TAGFIELDP := LCP ;
                           end (* then *)
                         else
                           ERROR ( 110 ) ;
                       end (* with *) ;
                   if LCP -> . NAME <> BLANKID then
                     INSYMBOL ;
                 end (* then *)
               else
                 10 :
                 begin
                   ERROR ( 2 ) ;
                   SKIP ( FSYS + [ OFSY , LPARENT ] )
                 end ;
               LSP -> . SIZE := DISPL ;
               if SY = OFSY then
                 INSYMBOL
               else
                 ERROR ( 8 ) ;
               LSP1 := NIL ;
               MINSIZE := DISPL ;
               MAXSIZE := DISPL ;
               repeat
                 LSP2 := NIL ;
                 repeat
                   CONSTANT ( FSYS + [ COMMA , COLON , LPARENT ] , LSP3
                              , LVALU ) ;
                   if LSP -> . TAGFIELDP <> NIL then
                     if COMPTYPES ( LSP -> . TAGFIELDP -> . IDTYPE ,
                     LSP3 ) <> 1 then
                       ERROR ( 111 ) ;
                   NEW ( LSP3 , VARIANT ) ;
                   with LSP3 -> do
                     begin
                       NXTVAR := LSP1 ;
                       SUBVAR := LSP2 ;
                       VARVAL := LVALU ;
                       FSTSUBFLD := NIL ;
                       FORM := VARIANT
                     end (* with *) ;
                   LSP1 := LSP3 ;
                   LSP2 := LSP3 ;
                   TEST := SY <> COMMA ;
                   if not TEST then
                     INSYMBOL
                 until TEST ;
                 if SY = COLON then
                   INSYMBOL
                 else
                   ERROR ( 5 ) ;
                 if SY = LPARENT then
                   INSYMBOL
                 else
                   ERROR ( 9 ) ;
                 FIELDLIST ( FSYS + [ RPARENT , SEMICOLON ] , LSP2 ,
                             LALNFCT , FLDOWNER , LCP1 ) ;
                 if LALNFCT > RECALN then
                   RECALN := LALNFCT ;
                 if DISPL > MAXSIZE then
                   MAXSIZE := DISPL ;
                 while LSP3 <> NIL do
                   with LSP3 -> do
                     begin
                       LSP4 := SUBVAR ;
                       SUBVAR := LSP2 ;
                       SIZE := DISPL ;
                       FSTSUBFLD := LCP1 ;
                       LSP3 := LSP4
                     end (* with *) ;
                 if SY = RPARENT then
                   begin
                     INSYMBOL ;
                     if not ( SY in FSYS + [ SEMICOLON ] ) then
                       begin
                         ERROR ( 6 ) ;
                         SKIP ( FSYS + [ SEMICOLON ] )
                       end (* then *)
                   end (* then *)
                 else
                   ERROR ( 4 ) ;
                 TEST := SY <> SEMICOLON ;
                 if not TEST then
                   begin
                     DISPL := MINSIZE ;
                     INSYMBOL ;
                     TEST := SY = ENDSY ;

           (*****************)
           (* IGNORE EXTRA ;*)
           (*****************)

                   end (* then *)
               until TEST ;
               DISPL := MAXSIZE ;
               LSP -> . FSTVAR := LSP1 ;
             end (* then *)
           else
             FRECVAR := NIL
         end (* FIELDLIST *) ;


      begin (* TYP *)
        OLDPACKST := PACKDATA ;
        if not ( SY in TYPEBEGSYS ) then
          begin
            ERROR ( 10 ) ;
            SKIP ( FSYS + TYPEBEGSYS )
          end (* then *) ;
        if SY in TYPEBEGSYS then
          begin
            if SY in SIMPTYPEBEGSYS then
              SIMPLETYPE ( FSYS , FSP )
            else
              if SY = ARROW then
                begin
                  NEW ( LSP , POINTER ) ;
                  FSP := LSP ;
                  with LSP -> do
                    begin
                      ELTYPE := NIL ;
                      SIZE := PTRSIZE ;
                      ALN := PTRSIZE ;
                      FORM := POINTER
                    end (* with *) ;
                  INSYMBOL ;
                  if SY = IDENT then
                    begin

        (***********************************)
        (*NO ERROR IF SEARCH NOT SUCCESSFUL*)
        (***********************************)

                      DUMMYBOOL := SEARCHID ( ID , FALSE , FALSE , [
                                   TYPES ] , LCP ) ;
                      if LCP = NIL then

        (****************************)
        (*FORWARD REFERENCED TYPE ID*)
        (****************************)

                        begin
                          NEW ( LCP , TYPES ) ;
                          with LCP -> do
                            begin
                              NAME := ID ;
                              IDTYPE := LSP ;
                              NEXT := FWPTR ;
                              KLASS := TYPES
                            end (* with *) ;
                          FWPTR := LCP
                        end (* then *)
                      else
                        begin
                          if LCP -> . IDTYPE <> NIL then
                            if LCP -> . IDTYPE -> . FORM = FILES then
                              ERROR ( 108 )
                            else
                              LSP -> . ELTYPE := LCP -> . IDTYPE
                        end (* else *) ;
                      INSYMBOL ;
                    end (* then *)
                  else
                    ERROR ( 2 ) ;
                end (* then *)
              else
                begin
                  LSP := NIL ;

        (*******************************)
        (*  keyword recognized         *)
        (*******************************)

                  if SY = PACKEDSY then
                    begin
                      INSYMBOL ;
                      PACKDATA := TRUE ;
                      if not ( SY in TYPEDELS ) then
                        begin
                          ERROR ( 10 ) ;
                          SKIP ( FSYS + TYPEDELS )
                        end (* then *)
                    end (* then *)
                  else
                    PACKDATA := FALSE ;

        (*********************************************************)
        (*  case statement for complex types:                    *)
        (*  arrays, records, sets, files                         *)
        (*********************************************************)

                  case SY of

        (*******************************)
        (*  keyword array recognized   *)
        (*******************************)

                    ARRAYSY :
                      begin
                        INSYMBOL ;
                        if SY = LBRACK then
                          INSYMBOL
                        else
                          begin
                            if SY = LPARENT then
                              begin
                                ERRKIND := 'W' ;
                                INSYMBOL
                              end (* then *) ;
                            ERROR ( 11 )
                          end (* else *) ;
                        LSP1 := NIL ;
                        PACKST2 := PACKDATA ;
                        PACKDATA := FALSE ;
                        repeat
                          NEW ( LSP , ARRAYS ) ;
                          with LSP -> do
                            begin
                              AELTYPE := LSP1 ;
                              INXTYPE := NIL ;
                              FORM := ARRAYS
                            end (* with *) ;
                          LSP1 := LSP ;
                          SIMPLETYPE ( FSYS + [ COMMA , RBRACK , OFSY ,
                                       RPARENT ] , LSP2 ) ;
                          if LSP2 <> NIL then
                            if LSP2 -> . FORM <= SUBRANGE then
                              begin
                                if LSP2 = REALPTR then
                                  begin
                                    ERROR ( 109 ) ;
                                    LSP2 := NIL
                                  end (* then *)
                                else
                                  if LSP2 = INTPTR then
                                    begin
                                      ERROR ( 149 ) ;
                                      LSP2 := NIL
                                    end (* then *) ;
                                LSP -> . INXTYPE := LSP2
                              end (* then *)
                            else
                              begin
                                ERROR ( 113 ) ;
                                LSP2 := NIL
                              end (* else *) ;
                          TEST := SY <> COMMA ;
                          if not TEST then
                            INSYMBOL
                        until TEST ;
                        if SY = RBRACK then
                          INSYMBOL
                        else
                          begin
                            if SY = RPARENT then
                              begin
                                ERRKIND := 'W' ;
                                INSYMBOL
                              end (* then *) ;
                            ERROR ( 12 )
                          end (* else *) ;
                        if SY = OFSY then
                          INSYMBOL
                        else
                          ERROR ( 8 ) ;
                        PACKDATA := PACKST2 ;
                        TYP ( FSYS , LSP , LSIZE ) ;
                        if LSP <> NIL then
                          ALIGN ( LSIZE , LSP -> . ALN ) ;
                        repeat
                          with LSP1 -> do
                            begin
                              LSP2 := AELTYPE ;
                              AELTYPE := LSP ;
                              if INXTYPE <> NIL then
                                begin
                                  GETBOUNDS ( INXTYPE , LMIN , LMAX ) ;
                                  LSIZE := LSIZE * ( LMAX - LMIN + 1 )
                                           ;
                                  SIZE := LSIZE ;
                                  if LSP <> NIL then
                                    ALN := LSP -> . ALN

        (*****************)
        (*PROPAGATE ALN  *)
        (*****************)


                                           ;
                                end (* then *)
                              else

        (***************)
        (*INXTYPE = NIL*)
        (***************)

                                SIZE := 0
                            end (* with *) ;
                          LSP := LSP1 ;
                          LSP1 := LSP2
                        until LSP1 = NIL
                      end (* tag/ca *) ;

        (*******************************)
        (*  keyword record recognized  *)
        (*******************************)

                    RECORDSY :
                      begin
                        INSYMBOL ;
                        if GET_STAT then
                          RE_CNT := RE_CNT + 1 ;
                        if TOP < DISPLIMIT then
                          begin
                            TOP := TOP + 1 ;
                            with DISPLAY [ TOP ] do
                              OCCUR := REC
                          end (* then *)
                        else
                          FATALERROR ( 250 ) ;
                        DISPL := 0 ;
                        NEW ( LSP , RECORDS ) ;
                        with LSP -> do
                          begin
                            FLD_DISP_LEV := TOP ;
                            FSTFLD := NIL ;
                            NO_FLDS := 0 ;
                            FIELDLIST ( FSYS - [ SEMICOLON ] + [ ENDSY
                                        ] , LSP1 , ALNFCT , LSP ,
                                        FSTFLD ) ;
                            RECVAR := LSP1 ;
                            SIZE := DISPL ;
                            FORM := RECORDS ;
                            ALN := ALNFCT ;
                            FLD_DISP_LEV := - 1 ;
                          end (* with *) ;
                        TOP := TOP - 1 ;
                        if SY = ENDSY then
                          INSYMBOL
                        else
                          ERROR ( 13 )
                      end (* tag/ca *) ;

        (*******************************)
        (*  keyword set recognized     *)
        (*******************************)

                    SETSY : begin
                              INSYMBOL ;
                              if SY = OFSY then
                                INSYMBOL
                              else
                                ERROR ( 8 ) ;
                              PACKDATA := FALSE ;
                              SIMPLETYPE ( FSYS , LSP1 ) ;
                              if LSP1 <> NIL then
                                if LSP1 = INTPTR then
                                  ERROR ( 304 )
                                else
                                  if ( LSP1 -> . FORM > SUBRANGE ) then
                                    begin
                                      ERROR ( 115 ) ;
                                      LSP1 := NIL
                                    end (* then *)
                                  else
                                    if LSP1 = REALPTR then
                                      ERROR ( 114 )
                                    else
                                      if LSP1 -> . FORM = SUBRANGE then
                                        begin
                                          if LSP1 -> . MAX . IVAL -
                                          LSP1 -> . MIN . IVAL + 1 >
                                          SETMAXSIZE then
                                            ERROR ( 307 ) ;
                                          if LSP1 -> . MAX . IVAL >
                                          SETUPPLIMIT then
                                            ERROR ( 308 ) ;
                                          if LSP1 -> . MIN . IVAL <
                                          SETLOWLIMIT then
                                            ERROR ( 309 )
                                        end (* then *) ;
                              NEW ( LSP , POWER ) ;
                              with LSP -> do
                                begin
                                  ELSET := LSP1 ;
                                  CALC_SETTYPSIZE ( LSP1 , SIZE ,
                                                   SETMIN , SETMAX ,
                                                   SETOFFS ) ;
                                  ALN := WORDSIZE ;
                                  FORM := POWER
                                end (* with *) ;
                            end (* tag/ca *) ;

        (*******************************)
        (*  keyword file recognized    *)
        (*******************************)

                    FILESY :
                      begin
                        INSYMBOL ;
                        if SY = OFSY then
                          INSYMBOL
                        else
                          ERROR ( 8 ) ;
                        TYP ( FSYS , LSP1 , LSIZE ) ;
                        LSP := TEXTPTR ;

        (**************************)
        (* ASSUME THE COMMON CASE *)
        (**************************)

                        if LSP1 <> NIL then
                          if LSP1 <> CHARPTR then

        (******************)
        (* NOT A TEXTFILE *)
        (******************)

                            if LSP1 -> . FORM <> FILES then
                              begin
                                NEW ( LSP , FILES ) ;
                                with LSP -> do
                                  begin
                                    FILTYPE := LSP1 ;
                                    ALN := LSP1 -> . ALN ;
                                    SIZE := LSIZE + FILHDRSIZE ;
                                    if SIZE < FILMINSIZE then
                                      SIZE := FILMINSIZE ;
                                    if ALN < PTRSIZE then
                                      ALN := PTRSIZE ;
                                    FORM := FILES ;
                                  end (* with *)
                              end (* then *)
                            else
                              begin
                                LSP := NIL ;
                                ERROR ( 108 )
                              end (* else *) ;
                      end (* tag/ca *)
                  end (* case *) ;

        (*********************************************************)
        (*  end case statement for complex types:                *)
        (*  arrays, records, sets, files                         *)
        (*********************************************************)

                  FSP := LSP
                end (* else *) ;
            if not ( SY in FSYS ) then
              begin
                ERROR ( 6 ) ;
                SKIP ( FSYS )
              end (* then *)
          end (* then *)
        else
          FSP := NIL ;
        if FSP = NIL then
          FSIZE := 1
        else
          FSIZE := FSP -> . SIZE ;
        PACKDATA := OLDPACKST ;
      end (* TYP *) ;


   procedure LABELDECLARATION ;

      var LLP : LBP ;
          REDEF : BOOLEAN ;
          LBNAME : LABELRNG ;

      begin (* LABELDECLARATION *)
        repeat
          if SY = INTCONST then
            with DISPLAY [ TOP ] do
              begin
                LLP := FLABEL ;
                REDEF := FALSE ;
                while ( LLP <> NIL ) and not REDEF do
                  if LLP -> . LABVAL <> VAL . IVAL then
                    LLP := LLP -> . NEXTLAB
                  else
                    begin
                      REDEF := TRUE ;
                      ERROR ( 166 )
                    end (* else *) ;
                if not REDEF then
                  begin
                    NEW ( LLP ) ;
                    with LLP -> do
                      begin
                        LABVAL := VAL . IVAL ;
                        GENLABEL ( LBNAME ) ;
                        XNO := 0 ;

        (**********************************)
        (* 0 => NOT AN EXTERNAL ENTRY PT. *)
        (**********************************)

                        DEFINED := FALSE ;
                        NEXTLAB := FLABEL ;
                        LABNAME := LBNAME
                      end (* with *) ;
                    FLABEL := LLP
                  end (* then *) ;
                INSYMBOL
              end (* with *)
          else
            ERROR ( 15 ) ;
          if not ( SY in FSYS + [ COMMA , SEMICOLON ] ) then
            begin
              ERROR ( 6 ) ;
              SKIP ( FSYS + [ COMMA , SEMICOLON ] )
            end (* then *) ;
          TEST := SY <> COMMA ;
          if not TEST then
            INSYMBOL
        until TEST ;
        if SY = SEMICOLON then
          INSYMBOL
        else
          ERROR ( 14 )
      end (* LABELDECLARATION *) ;


   function SET_CONST_PART ( TYP1 : TTP ; VAL1 : XCONSTANT ; PSI :
                           PSETINFO ) : BOOLEAN ;

   /***********************************/
   /* typ1 = type of first constant   */
   /* lval1 = lvalu of first constant */
   /***********************************/


      var LATTR : ATTR ;
          OK : BOOLEAN ;
          TYP2 : TTP ;
          VAL2 : XCONSTANT ;
          I : INTEGER ;
          OFFS : INTEGER ;

      begin (* SET_CONST_PART *)
        TYP2 := TYP1 ;
        VAL2 := VAL1 ;

        (****************************************)
        (* if char type, check for hex constant *)
        (****************************************)

        if TYP1 = CHARPTR then
          begin
            PSI -> . CHARTYPE := TRUE ;
            if VAL1 . STRTYPE in [ 'X' , 'B' ] then
              if PSI -> . HEXORBIN in [ ' ' , 'J' ] then
                PSI -> . HEXORBIN := 'J'
              else
                PSI -> . HEXORBIN := 'T'
            else
              if PSI -> . HEXORBIN in [ ' ' , 'N' ] then
                PSI -> . HEXORBIN := 'N'
              else
                PSI -> . HEXORBIN := 'T'
          end (* then *) ;

        (***************************)
        (* dotdot = constant range *)
        (***************************)

        if SY = DOTDOT then
          begin
            INSYMBOL ;
            CONSTANT ( FSYS + [ COMMA , RBRACK ] , TYP2 , VAL2 ) ;
            if COMPTYPES ( TYP2 , TYP1 ) <> 1 then
              begin
                VAL2 . IVAL := VAL1 . IVAL ;
                ERROR ( 137 )
              end (* then *) ;

        (****************************************)
        (* if char type, check for hex constant *)
        (****************************************)

            if TYP2 = CHARPTR then
              begin
                if VAL2 . STRTYPE in [ 'X' , 'B' ] then
                  if PSI -> . HEXORBIN in [ ' ' , 'J' ] then
                    PSI -> . HEXORBIN := 'J'
                  else
                    PSI -> . HEXORBIN := 'T'
                else
                  if PSI -> . HEXORBIN in [ ' ' , 'N' ] then
                    PSI -> . HEXORBIN := 'N'
                  else
                    PSI -> . HEXORBIN := 'T'
              end (* then *) ;
          end (* then *) ;

        (***************************************)
        (* some global set checks              *)
        (* first: val2 >= val1                 *)
        (***************************************)

        OK := TRUE ;
        if TYP2 <> NIL then
          if VAL2 . IVAL < VAL1 . IVAL then
            begin
              ERROR ( 310 ) ;
              OK := FALSE
            end (* then *) ;

        (***************************************)
        (* second: val2 not > setupplimit      *)
        (***************************************)

        if OK then
          if VAL2 . IVAL > SETUPPLIMIT then
            begin
              ERROR ( 308 ) ;
              OK := FALSE
            end (* then *) ;

        (**************************************)
        (* third: val2 not < setlowlimit      *)
        (**************************************)

        if OK then
          if VAL1 . IVAL < SETLOWLIMIT then
            begin
              ERROR ( 309 ) ;
              OK := FALSE
            end (* then *) ;
        OFFS := 0 ;
        if OK then
          begin
            if PSI -> . ELEMCOUNT = 0 then
              begin
                for I := 1 to SETMAXSIZE do
                  PSI -> . SETELEMS [ I ] := FALSE ;
                PSI -> . SETMIN := VAL1 . IVAL ;
                PSI -> . SETMAX := VAL2 . IVAL ;
                PSI -> . ELEMCOUNT := 1 ;
              end (* then *)
            else
              begin
                if PSI -> . SETMIN > VAL1 . IVAL then
                  begin
                    OFFS := PSI -> . SETMIN - VAL1 . IVAL ;
                    PSI -> . SETMIN := VAL1 . IVAL ;
                  end (* then *) ;
                if PSI -> . SETMAX < VAL2 . IVAL then
                  PSI -> . SETMAX := VAL2 . IVAL ;
                PSI -> . ELEMCOUNT := PSI -> . ELEMCOUNT + 1 ;
              end (* else *) ;
            if PSI -> . SETMAX - PSI -> . SETMIN + 1 > SETMAXSIZE then
              begin
                ERROR ( 311 ) ;
                PSI -> . RANGEERR := 1 ;
                OK := FALSE
              end (* then *) ;
          end (* then *) ;

        (**************************************)
        (* shift values in temp vector        *)
        (* insert values into temp vector     *)
        (**************************************)

        if OK then
          begin
            if OFFS > 0 then
              begin
                for I := SETMAXSIZE DOWNTO OFFS + 1 do
                  PSI -> . SETELEMS [ I ] := PSI -> . SETELEMS [ I -
                                             OFFS ] ;
                for I := 1 to OFFS do
                  PSI -> . SETELEMS [ I ] := FALSE ;
              end (* then *) ;
            for I := VAL1 . IVAL to VAL2 . IVAL do
              PSI -> . SETELEMS [ I - PSI -> . SETMIN + 1 ] := TRUE ;
          end (* then *) ;

        /************************************/
        /*   bei comma:                     */
        /*   naechstes symbol und           */
        /*   nochmal ein set_const_part     */
        /*   signalisieren                  */
        /************************************/

        if SY = COMMA then
          begin
            INSYMBOL ;
            SET_CONST_PART := TRUE ;
          end (* then *)
        else
          begin
            SET_CONST_PART := FALSE ;
          end (* else *)
      end (* SET_CONST_PART *) ;


   procedure STRUCTCONSTANT ( FSYS : SETOFSYS ; var FSP : TTP ; var
                            FVALU : XCONSTANT ; var SLC : INTEGER ) ;

      label 10 ;

      var LSET : SETSTRING ;
          I , J , K , L : INTEGER ;
          OK : BOOLEAN ;
          NOCHMAL : BOOLEAN ;
          PSI : PSETINFO ;
          LVALU : XCONSTANT ;
          LSP , LSP1 , ELT , LRECVAR : TTP ;
          DUMMY_TYP : TTP ;
          FLDPR : IDP ;
          LX : ADDRRANGE ;
          CT_RESULT : INTEGER ;
          SIZE1 : INTEGER ;
          SIZE2 : INTEGER ;
          TEST : BOOLEAN ;


      procedure STOWCONST ( ELSP : TTP ) ;

         var ELSIZE : INTEGER ;
             ELSP1 : TTP ;
             CT_RESULT : INTEGER ;
             SIZE1 : ADDRRANGE ;
             SIZE2 : ADDRRANGE ;

         begin (* STOWCONST *)
           ELSP1 := ELSP ;
           if ELSP <> NIL then
             begin
               ALIGN ( CONSTLCOUNTER , ELSP -> . ALN ) ;
               ELSIZE := ELSP -> . SIZE
             end (* then *)
           else
             ELSIZE := 1 ;
           STRUCTCONSTANT ( FSYS + [ COMMA , RPARENT ] , ELSP1 , LVALU
                            , I ) ;

           (******************************************)
           (* accept comptypes = 2 here too          *)
           (* no problem, if const string is shorter *)
           (******************************************)

           CT_RESULT := COMPTYPES ( ELSP , ELSP1 ) ;
           if not ( CT_RESULT in [ 1 , 2 , 3 ] ) then
             begin
               ERROR ( 145 ) ;
               ELSP1 := NIL
             end (* then *) ;
           if ELSP1 <> NIL then
             begin

           (******************************************)
           (* if comptypes returns 2, adjust         *)
           (* string constant size to size of        *)
           (* constant definition                    *)
           (******************************************)

               if CT_RESULT in [ 2 , 3 ] then
                 MOD_STRCONST ( CT_RESULT , LVALU , ELSP1 , ELSP -> .
                                SIZE ) ;
               if PRCODE then
                 if I < 0 then
                   begin
                     WRITEDFC ( ELSP1 , ELSIZE , LVALU , FALSE ) ;
                     CONSTLCOUNTER := CONSTLCOUNTER + ELSIZE ;
                   end (* then *)
             end (* then *) ;
         end (* STOWCONST *) ;


      begin (* STRUCTCONSTANT *)
        LSP := FSP ;
        FVALU . IVAL := 0 ;
        FVALU . STRTYPE := ' ' ;
        SLC := - 1 ;
        if SY in CONSTBEGSYS then

        (************************************************)
        (* simple constant is used here to recognize    *)
        (* for example the strings that are used inside *)
        (* of complex structured constants, so the      *)
        (* return code 2 has to be accepted here;       *)
        (* it is checked again by the caller, which     *)
        (* takes then appropriate action                *)
        (************************************************)

          begin
            CONSTANT ( FSYS , FSP , FVALU ) ;
            CT_RESULT := COMPTYPES ( LSP , FSP ) ;
            if CT_RESULT in [ 1 , 2 , 3 ] then
              begin
                if LSP <> NIL then
                  begin
                    FSP := LSP ;
                    if CT_RESULT in [ 2 , 3 ] then
                      MOD_STRCONST ( CT_RESULT , FVALU , DUMMY_TYP ,
                                     LSP -> . SIZE ) ;
                  end (* then *) ;
              end (* then *)
            else
              begin
                ERROR ( 145 ) ;
                FSP := NIL
              end (* else *)
          end (* then *)
        else
          if SY = LBRACK then
            begin

        (**********************************************)
        (* read set constant, that is:                *)
        (* empty set or a sequence of set const parts *)
        (* which consist of single constants or       *)
        (* constant ranges, separated by commas       *)
        (* see set const part                         *)
        (**********************************************)

              INSYMBOL ;
              ELT := NIL ;
              for I := 1 to MAXSETL do
                LSET [ I ] := CHR ( 0 ) ;
              if LSP <> NIL then
                if LSP -> . FORM = POWER then
                  ELT := LSP -> . ELSET
                else
                  ERROR ( 145 ) ;
              PSI := PSIGLOB ;
              PSI -> . ELEMCOUNT := 0 ;
              PSI -> . SETMIN := 0 ;
              PSI -> . SETMAX := 0 ;
              PSI -> . RANGEERR := 0 ;
              PSI -> . CHARTYPE := FALSE ;
              PSI -> . HEXORBIN := ' ' ;
              PSI -> . CONST_IN_SET := 0 ;
              PSI -> . VARS_IN_SET := 0 ;
              if SY <> RBRACK then
                repeat
                  CONSTANT ( FSYS + [ RBRACK , COMMA , DOTDOT ] , LSP1
                             , LVALU ) ;
                  if COMPTYPES ( LSP1 , ELT ) <> 1 then
                    ERROR ( 145 ) ;
                  ELT := LSP1 ;
                  NOCHMAL := SET_CONST_PART ( ELT , LVALU , PSI ) ;
                until not NOCHMAL ;
              if SY = RBRACK then
                INSYMBOL
              else
                ERROR ( 12 ) ;
              if FALSE then
                begin
                  WRITELN ( TRACEF ) ;
                  WRITELN ( TRACEF , 'psi.elemcount = ' , PSI -> .
                            ELEMCOUNT ) ;
                  WRITELN ( TRACEF , 'psi.setmin    = ' , PSI -> .
                            SETMIN ) ;
                  WRITELN ( TRACEF , 'psi.setmax    = ' , PSI -> .
                            SETMAX ) ;
                  WRITELN ( TRACEF , 'psi.rangeerr  = ' , PSI -> .
                            RANGEERR ) ;
                  for I := 1 to SETMAXSIZE do
                    if PSI -> . SETELEMS [ I ] then
                      WRITELN ( TRACEF , 'in set        = ' , PSI -> .
                                SETMIN + I - 1 ) ;
                end (* then *) ;

        (************************************)
        (* create set constant and store it *)
        (************************************)

              BUILD_SET ( FVALU , PSI ) ;
              if LSP = NIL then
                begin
                  NEW ( LSP , POWER ) ;
                  with LSP -> do
                    begin
                      ELSET := ELT ;
                      FORM := POWER ;
                      SIZE := FVALU . PVAL -> . LENGTH ;
                      ALN := WORDSIZE
                    end (* with *) ;
                  FSP := LSP
                end (* then *)
            end (* then *)
          else
            if SY = LPARENT then

        (**************************)
        (*ARRAY OR RECORD CONSTANT*)
        (**************************)

              begin
                INSYMBOL ;
                K := 0 ;
                CHECKSTARTCST ;
                if LSP <> NIL then
                  with LSP -> do
                    if FORM = ARRAYS then
                      begin
                        ALIGN ( CONSTLCOUNTER , ALN ) ;
                        SLC := CONSTLCOUNTER ;
                        J := SLC ;
                        if AELTYPE <> NIL then
                          L := AELTYPE -> . SIZE
                        else
                          L := 1 ;
                        LX := L ;
                        ALIGN ( LX , ALN ) ;
                        L := LX ;
                        TEST := FALSE ;
                        repeat
                          K := K + 1 ;
                          STOWCONST ( AELTYPE ) ;
                          if SY = COMMA then
                            begin
                              INSYMBOL ;
                              J := J + L ;
                              CONSTLCOUNTER := J
                            end (* then *)
                          else
                            TEST := TRUE
                        until TEST ;
                        if SY = RPARENT then
                          INSYMBOL
                        else
                          ERROR ( 4 ) ;
                        if INXTYPE <> NIL then
                          begin
                            GETBOUNDS ( INXTYPE , I , J ) ;
                            J := J - I + 1
                          end (* then *)
                        else
                          J := SIZE DIV L ;
                        if K <> J then
                          if K > J then
                            ERROR ( 207 )
                          else
                            begin
                              ERRKIND := 'W' ;
                              ERROR ( 306 ) ;
                              if PRCODE then
                                WRITELN ( PRR , SLC + SIZE - 1 : 1 , MN
                                          [ 70 ] , ' B,0' ) ;

        (********)
        (*DFC   *)
        (********)

                            end (* else *) ;
                        CONSTLCOUNTER := SLC + SIZE ;
                      end (* then *)
                    else
                      if FORM = RECORDS then
                        begin
                          ALIGN ( CONSTLCOUNTER , ALN ) ;
                          SLC := CONSTLCOUNTER ;
                          L := SIZE ;
                          LRECVAR := RECVAR ;
                          TEST := TRUE ;
                          FLDPR := FSTFLD ;
                          10 :
                          while TEST and ( FLDPR <> NIL ) do
                            with FLDPR -> do
                              begin
                                CONSTLCOUNTER := SLC + FLDADDR ;
                                STOWCONST ( IDTYPE ) ;
                                FLDPR := NEXT ;
                                if SY = COMMA then
                                  INSYMBOL
                                else
                                  TEST := FALSE
                              end (* with *) ;
                          if TEST then
                            if LRECVAR <> NIL then

        (*******************)
        (*TAG FIELD VALUE  *)
        (*        IS NEXT  *)
        (*******************)

                              with LRECVAR -> do
                                if TAGFIELDP <> NIL then
                                  with TAGFIELDP -> do
                                    begin
                                      if NAME <> BLANKID then
                                        begin
                                          CONSTLCOUNTER := SLC +
                                                   FLDADDR ;
                                          STOWCONST ( IDTYPE )
                                        end (* then *)
                                      else
                                        begin
                                          CONSTANT ( FSYS + [ COMMA ,
                                                   RPARENT ] , LSP1 ,
                                                   LVALU ) ;
                                          if COMPTYPES ( IDTYPE , LSP1
                                          ) <> 1 then
                                            ERROR ( 145 ) ;
                                        end (* else *) ;
                                      if SY = COMMA then
                                        INSYMBOL
                                      else
                                        TEST := FALSE ;
                                      LSP1 := FSTVAR ;
                                      L := SIZE ;
                                      while LSP1 <> NIL do
                                        with LSP1 -> do
                                          if VARVAL . IVAL = LVALU .
                                          IVAL then
                                            begin
                                              LRECVAR := SUBVAR ;
                                              L := SIZE ;
                                              FLDPR := FSTSUBFLD ;
                                              goto 10
                                            end (* then *)
                                          else
                                            LSP1 := NXTVAR ;
                                    end (* with *) ;
                          CONSTLCOUNTER := SLC + L ;
                          if SY <> RPARENT then
                            ERROR ( 4 )
                          else
                            INSYMBOL ;
                        end (* then *)
                      else
                        ERROR ( 208 ) ;

        (*************************)
        (*WRONG FORM FOR CONSTANT*)
        (*************************)

              end (* then *)
            else
              ERROR ( 50 ) ;
      end (* STRUCTCONSTANT *) ;


   procedure CONSTDECLARATION ;

      var LCP : IDP ;
          LSP : TTP ;
          LVALU : XCONSTANT ;
          SKID : ALPHA ;
          SKLC : ADDRRANGE ;

      begin (* CONSTDECLARATION *)
        LISTTAG := 'C' ;
        if SY <> IDENT then
          begin
            ERROR ( 2 ) ;
            SKIP ( FSYS + [ IDENT ] )
          end (* then *) ;
        while SY = IDENT do
          begin
            SKID := ID ;
            INSYMBOL ;
            if SY = COLON then
              begin
                INSYMBOL ;
                EXTUSED := TRUE ;
                TYP ( FSYS + [ RELOP ] , LSP , SKLC ) ;
              end (* then *)
            else
              LSP := NIL ;
            if ( SY = RELOP ) and ( OP = EQOP ) then
              begin
                INSYMBOL ;
                STRUCTCONSTANT ( FSYS + [ SEMICOLON ] , LSP , LVALU ,
                                 SKLC ) ;
                if SKLC >= 0 then
                  NEW ( LCP , STRUCTKONST )
                else
                  NEW ( LCP , KONST ) ;
                with LCP -> do
                  begin
                    NAME := SKID ;
                    IDTYPE := LSP ;
                    NEXT := NIL ;
                    if SKLC >= 0 then
                      begin
                        KLASS := STRUCTKONST ;
                        SKOWNERPROC := FPROCP -> . CSTNAME ;
                        SKADDR := SKLC
                      end (* then *)
                    else
                      begin
                        KLASS := KONST ;
                        VALUES := LVALU
                      end (* else *)
                  end (* with *) ;
                ENTERID ( LCP ) ;
              end (* then *)
            else
              ERROR ( 16 ) ;
            if SY = SEMICOLON then
              begin
                INSYMBOL ;
                if not ( SY in FSYS + [ IDENT ] ) then
                  begin
                    ERROR ( 6 ) ;
                    SKIP ( FSYS + [ IDENT ] )
                  end (* then *)
              end (* then *)
            else
              ERROR ( 14 )
          end (* while *) ;
        LISTTAG := ' ' ;
      end (* CONSTDECLARATION *) ;


   procedure TYPEDECLARATION ;

      var LCP , LCP1 , LCP2 : IDP ;
          LSP : TTP ;
          LSIZE : ADDRRANGE ;

      begin (* TYPEDECLARATION *)
        if SY <> IDENT then
          begin
            ERROR ( 2 ) ;
            SKIP ( FSYS + [ IDENT ] )
          end (* then *) ;
        while SY = IDENT do
          begin
            NEW ( LCP , TYPES ) ;
            with LCP -> do
              begin
                NAME := ID ;
                IDTYPE := NIL ;
                KLASS := TYPES
              end (* with *) ;
            INSYMBOL ;
            if ( SY = RELOP ) and ( OP = EQOP ) then
              INSYMBOL
            else
              ERROR ( 16 ) ;
            TYP ( FSYS + [ SEMICOLON ] , LSP , LSIZE ) ;
            ENTERID ( LCP ) ;
            LCP -> . IDTYPE := LSP ;

        (*******************************************)
        (*HAS ANY FORWARD REFERENCE BEEN SATISFIED:*)
        (*******************************************)

            LCP1 := FWPTR ;
            while LCP1 <> NIL do
              begin
                if LCP1 -> . NAME = LCP -> . NAME then
                  begin
                    LCP1 -> . IDTYPE -> . ELTYPE := LCP -> . IDTYPE ;
                    if LCP1 <> FWPTR then
                      LCP2 -> . NEXT := LCP1 -> . NEXT
                    else
                      FWPTR := LCP1 -> . NEXT ;
                  end (* then *) ;
                LCP2 := LCP1 ;
                LCP1 := LCP1 -> . NEXT
              end (* while *) ;
            if SY = SEMICOLON then
              begin
                INSYMBOL ;
                if not ( SY in FSYS + [ IDENT ] ) then
                  begin
                    ERROR ( 6 ) ;
                    SKIP ( FSYS + [ IDENT ] )
                  end (* then *)
              end (* then *)
            else
              ERROR ( 14 )
          end (* while *) ;
        if FWPTR <> NIL then
          begin
            ERROR ( 117 ) ;
            WRITELN ( LISTING ) ;
            PLCNT := PLCNT + 1 ;
            repeat
              WRITELN ( LISTING , ' UNDEFINED TYPE: ' , FWPTR -> . NAME
                        ) ;
              PLCNT := PLCNT + 1 ;
              FWPTR := FWPTR -> . NEXT
            until FWPTR = NIL ;
          end (* then *)
      end (* TYPEDECLARATION *) ;


   procedure VARDECLARATION ;

      var LCP , NXT , NXT1 : IDP ;
          LSP : TTP ;
          LSIZE : ADDRRANGE ;
          LFPTR : FRECPTR ;

      begin (* VARDECLARATION *)
        if IS_MODULE and ( LEVEL <= 1 ) then
          ERROR ( 194 ) ;
        LISTTAG := 'D' ;
        NXT := NIL ;
        repeat
          NXT1 := NIL ;
          repeat
            if SY = IDENT then
              begin
                NEW ( LCP , VARS ) ;
                with LCP -> do
                  begin
                    NAME := ID ;
                    NEXT := NIL ;
                    KLASS := VARS ;
                    IDTYPE := NIL ;
                    VKIND := ACTUAL ;
                    VLEV := LEVEL ;
                    STKLASS := XAUTO ;
                    VOWNERPROC := ' ' ;
                    SPECIAL := 0 ;
                  end (* with *) ;
                ENTERID ( LCP ) ;
                if NXT1 = NIL then
                  NXT1 := LCP ;

        (*************************)
        (*BEGINNING OF THIS ROUND*)
        (*************************)

                if NXT <> NIL then
                  NXT -> . NEXT := LCP ;

        (************************)
        (*LINK TO PREVIOUS CHAIN*)
        (************************)

                NXT := LCP ;
                INSYMBOL ;
              end (* then *)
            else
              ERROR ( 2 ) ;
            if not ( SY in FSYS + [ COMMA , COLON ] + TYPEDELS ) then
              begin
                ERROR ( 6 ) ;
                SKIP ( FSYS + [ COMMA , COLON , SEMICOLON ] + TYPEDELS
                       )
              end (* then *) ;
            TEST := SY <> COMMA ;
            if not TEST then
              INSYMBOL
          until TEST ;
          if SY = COLON then
            INSYMBOL
          else
            ERROR ( 5 ) ;
          TYP ( FSYS + [ SEMICOLON ] + TYPEDELS , LSP , LSIZE ) ;
          while NXT1 <> NIL do
            with NXT1 -> do
              begin
                IDTYPE := LSP ;
                if LSP <> NIL then
                  begin
                    ALIGN ( LCOUNTER , LSP -> . ALN ) ;
                    VADDR := LCOUNTER ;
                    LCOUNTER := LCOUNTER + LSIZE ;
                    if LSP -> . FORM = FILES then
                      if LEVEL > 1 then
                        ERROR ( 398 )

        (*******************************)
        (* ONLY GLOBAL FILES SUPPORTED *)
        (*******************************)

                      else
                        begin
                          NEW ( LFPTR ) ;
                          LFPTR -> . FILIDPTR := NXT1 ;
                          LFPTR -> . NEXTFILE := FILEHEAD ;
                          FILEHEAD := LFPTR
                        end (* else *)
                  end (* then *)
                else
                  VADDR := LCOUNTER ;
                if DEBUG_LEV > 0 then
                  PRNTSYMBL ( NXT1 ) ;
                NXT1 := NEXT ;
              end (* with *) ;
          if SY = SEMICOLON then
            begin
              INSYMBOL ;
              if not ( SY in FSYS + [ IDENT ] ) then
                begin
                  ERROR ( 6 ) ;
                  SKIP ( FSYS + [ IDENT ] )
                end (* then *)
            end (* then *)
          else
            ERROR ( 14 )
        until ( SY <> IDENT ) and not ( SY in TYPEDELS ) ;
        LISTTAG := ' ' ;
        if FWPTR <> NIL then
          begin
            ERROR ( 117 ) ;
            WRITELN ( LISTING ) ;
            PLCNT := PLCNT + 1 ;
            repeat
              WRITELN ( LISTING , ' UNDEFINED TYPE: ' , FWPTR -> . NAME
                        ) ;
              PLCNT := PLCNT + 1 ;
              FWPTR := FWPTR -> . NEXT
            until FWPTR = NIL ;
          end (* then *) ;
      end (* VARDECLARATION *) ;


   procedure STATICDECLARATION ;

      var LCP , NXT , NXT1 : IDP ;
          LSP : TTP ;
          LSIZE : ADDRRANGE ;
          LFPTR : FRECPTR ;
          LVALU_DUMMY : XCONSTANT ;
          ELSIZE : INTEGER ;

      begin (* STATICDECLARATION *)
        LVALU_DUMMY . IVAL := 0 ;
        LVALU_DUMMY . STRTYPE := ' ' ;
        LISTTAG := 'S' ;
        NXT := NIL ;
        repeat
          NXT1 := NIL ;
          repeat
            if SY = IDENT then
              begin
                NEW ( LCP , VARS ) ;
                with LCP -> do
                  begin
                    NAME := ID ;
                    NEXT := NIL ;
                    KLASS := VARS ;
                    IDTYPE := NIL ;
                    VKIND := ACTUAL ;
                    VLEV := LEVEL ;
                    STKLASS := XSTATIC ;
                    VOWNERPROC := FPROCP -> . CSTNAME ;
                    SPECIAL := 0 ;
                  end (* with *) ;
                ENTERID ( LCP ) ;
                if NXT1 = NIL then
                  NXT1 := LCP ;

        (*************************)
        (*BEGINNING OF THIS ROUND*)
        (*************************)

                if NXT <> NIL then
                  NXT -> . NEXT := LCP ;

        (************************)
        (*LINK TO PREVIOUS CHAIN*)
        (************************)

                NXT := LCP ;
                INSYMBOL ;
              end (* then *)
            else
              ERROR ( 2 ) ;
            if not ( SY in FSYS + [ COMMA , COLON ] + TYPEDELS ) then
              begin
                ERROR ( 6 ) ;
                SKIP ( FSYS + [ COMMA , COLON , SEMICOLON ] + TYPEDELS
                       )
              end (* then *) ;
            TEST := SY <> COMMA ;
            if not TEST then
              INSYMBOL
          until TEST ;
          if SY = COLON then
            INSYMBOL
          else
            ERROR ( 5 ) ;
          TYP ( FSYS + [ SEMICOLON ] + TYPEDELS , LSP , LSIZE ) ;
          while NXT1 <> NIL do
            with NXT1 -> do
              begin
                IDTYPE := LSP ;
                CHECKSTARTCST ;
                if LSP <> NIL then
                  begin
                    if LSP -> . FORM = FILES then
                      ERROR ( 398 )
                    else
                      begin
                        ALIGN ( CONSTLCOUNTER , LSP -> . ALN ) ;
                        ELSIZE := LSP -> . SIZE ;
                        VADDR := CONSTLCOUNTER ;
                        WRITEDFC ( LSP , ELSIZE , LVALU_DUMMY , TRUE )
                                   ;
                        CONSTLCOUNTER := CONSTLCOUNTER + LSIZE ;
                      end (* else *)
                  end (* then *)
                else
                  VADDR := CONSTLCOUNTER ;
                if DEBUG_LEV > 0 then
                  PRNTSYMBL ( NXT1 ) ;
                NXT1 := NEXT ;
              end (* with *) ;
          if SY = SEMICOLON then
            begin
              INSYMBOL ;
              if not ( SY in FSYS + [ IDENT ] ) then
                begin
                  ERROR ( 6 ) ;
                  SKIP ( FSYS + [ IDENT ] )
                end (* then *)
            end (* then *)
          else
            ERROR ( 14 )
        until ( SY <> IDENT ) and not ( SY in TYPEDELS ) ;
        LISTTAG := ' ' ;
        if FWPTR <> NIL then
          begin
            ERROR ( 117 ) ;
            WRITELN ( LISTING ) ;
            PLCNT := PLCNT + 1 ;
            repeat
              WRITELN ( LISTING , ' UNDEFINED TYPE: ' , FWPTR -> . NAME
                        ) ;
              PLCNT := PLCNT + 1 ;
              FWPTR := FWPTR -> . NEXT
            until FWPTR = NIL ;
          end (* then *) ;
      end (* STATICDECLARATION *) ;


   procedure MKNAME ( var ALB : ALPHA ; NLB : INTEGER ; NCFLAG :
                    BOOLEAN ) ;

   /*************************************/
   /* generische Namen fuer Labels usw. */
   /*************************************/


      var I , J : INTEGER ;

      begin (* MKNAME *)
        I := 1 ;
        J := 8 ;
        if not NCFLAG then
          J := 5 ;
        repeat
          if ALB [ I ] = '_' then
            ALB [ I ] := '$' ;
          I := I + 1
        until ( I > J ) or ( ALB [ I ] = ' ' ) ;
        if not NCFLAG then
          for J := 8 DOWNTO I do
            begin
              ALB [ J ] := CHR ( ORD ( '0' ) + NLB MOD 10 ) ;
              NLB := NLB DIV 10
            end (* for *) ;
      end (* MKNAME *) ;


   procedure MKPROCNAME ( var NAM : ALPHA ; NAMPAT : ALPHA ; NUM :
                        INTEGER ; INTERN : BOOLEAN ) ;

   /********************************************************/
   /* generische Namen fuer interne und externe Prozeduren */
   /********************************************************/


      var I , J : INTEGER ;

      begin (* MKPROCNAME *)
        J := 8 ;
        if INTERN then
          begin
            NAM := NAMPAT ;
            I := 8 ;
            while NAM [ I ] = ' ' do
              I := I - 1 ;
            I := I + 1 ;
          end (* then *)
        else
          begin
            I := 1 ;
            while I < 9 do
              begin
                if NAM [ I ] = ' ' then
                  break ;
                if NAM [ I ] = '_' then
                  NAM [ I ] := '$' ;
                I := I + 1
              end (* while *)
          end (* else *) ;
        if INTERN then
          for J := 8 DOWNTO I do
            begin
              NAM [ J ] := CHR ( ORD ( '0' ) + NUM MOD 10 ) ;
              NUM := NUM DIV 10
            end (* for *) ;
      end (* MKPROCNAME *) ;


   procedure PROCDECLARATION ( FSY : SYMBOL ; PLOCAL : BOOLEAN ) ;

      var LSY : SYMBOL ;
          LCP , LCP1 , LCP2 : IDP ;
          LSP : TTP ;
          FORW : BOOLEAN ;
          K , PARCNT : INTEGER ;
          OLDLABEL : LABELRNG ;
          LLC , LCM : ADDRRANGE ;
          I , NAME : INTEGER ;
          MARKP : -> INTEGER ;
          OLD_HASH : HASH_TABLE ;
          INTERN : BOOLEAN ;


      procedure PARAMETERLIST ( FSY : SETOFSYS ; FPAR : IDP ; FW :
                              BOOLEAN ) ;

         var LCP , LCP1 , LCP2 , LCP3 , LCP4 : IDP ;
             LSP : TTP ;
             LKIND : IDKIND ;
             LLC , LEN , LALN : ADDRRANGE ;
             LSY : SYMBOL ;

         begin (* PARAMETERLIST *)
           LCP1 := NIL ;
           LCP := NIL ;
           if not ( SY in FSY + [ LPARENT ] ) then
             begin
               ERROR ( 7 ) ;
               SKIP ( FSYS + FSY + [ LPARENT ] )
             end (* then *) ;
           if SY = LPARENT then
             begin
               if FORW then
                 ERROR ( 119 )
               else
                 LCOUNTER := LCAFTMST + FPSAVEAREA ;
               INSYMBOL ;
               if not ( SY in [ IDENT , VARSY , PROCSY , FUNCSY ] )
               then
                 begin
                   ERROR ( 7 ) ;
                   SKIP ( FSYS + [ IDENT , RPARENT ] )
                 end (* then *) ;
               while SY in [ IDENT , VARSY , PROCSY , FUNCSY ] do
                 begin
                   LCP3 := NIL ;
                   if SY in [ PROCSY , FUNCSY ] then
                     begin
                       LSY := SY ;

           (***************************)
           (*REMEMBER IF PROC OR FUNC *)
           (***************************)

                       INSYMBOL ;
                       if SY = IDENT then
                         begin
                           if LSY = PROCSY then
                             NEW ( LCP , PROC , DECLARED )
                           else
                             NEW ( LCP , FUNC , DECLARED ) ;
                           if LCP3 <> NIL then
                             LCP4 -> . NEXT := LCP
                           else
                             LCP3 := LCP ;
                           LCP4 := LCP ;
                           ALIGN ( LCOUNTER , PTRSIZE ) ;
                           with LCP -> do
                             begin
                               NAME := ID ;
                               IDTYPE := NIL ;
                               NEXT := NIL ;
                               PFDECKIND := DECLARED ;
                               PFKIND := FORMAL ;
                               FRTRN := FALSE ;
                               EXTRN := FALSE ;
                               DECLMISSING := FALSE ;
                               EXTNAME := '*PFPARM*' ;
                               PFLEV := LCOUNTER * 10 + LEVEL ;

           (***************************************)
           (*I.E. PFLEV > LCAFTMST => PROC PARM   *)
           (***************************************)

                               PROCLAB := PROCLAB + 1 ;
                               PFNAME := PROCLAB ;
                               if LSY = PROCSY then
                                 KLASS := PROC
                               else
                                 KLASS := FUNC ;
                             end (* with *) ;
                           ENTERID ( LCP ) ;
                           LCOUNTER := LCOUNTER + DISPAREA ;
                           INSYMBOL ;
                           LLC := LCOUNTER ;
                           if LSY = PROCSY then
                             PARAMETERLIST ( [ SEMICOLON , RPARENT ] ,
                                             LCP , FALSE )
                           else
                             PARAMETERLIST ( [ SEMICOLON , COLON ] ,
                                             LCP , FALSE ) ;
                           LCOUNTER := LLC ;
                         end (* then *)
                       else
                         ERROR ( 2 ) ;
                       if not ( SY in FSYS + [ SEMICOLON , RPARENT ] )
                       then
                         begin
                           ERROR ( 7 ) ;
                           SKIP ( FSYS + [ SEMICOLON , RPARENT ] )
                         end (* then *)
                     end (* then *)
                   else
                     begin
                       if SY = VARSY then
                         begin
                           LKIND := FORMAL ;
                           INSYMBOL
                         end (* then *)
                       else
                         LKIND := ACTUAL ;
                       repeat
                         if SY = IDENT then
                           begin
                             NEW ( LCP , VARS ) ;
                             LCP -> . STKLASS := XAUTO ;
                             LCP -> . VOWNERPROC := ' ' ;
                             LCP -> . SPECIAL := 0 ;
                             if LCP3 <> NIL then
                               LCP4 -> . NEXT := LCP
                             else
                               LCP3 := LCP ;
                             LCP4 := LCP ;
                             with LCP -> do
                               begin
                                 NAME := ID ;
                                 IDTYPE := NIL ;
                                 KLASS := VARS ;
                                 VKIND := LKIND ;
                                 NEXT := NIL ;
                                 VLEV := LEVEL ;
                               end (* with *) ;
                             ENTERID ( LCP ) ;
                             INSYMBOL ;
                           end (* then *) ;
                         if not ( SY in [ COMMA , COLON ] + FSYS ) then
                           begin
                             ERROR ( 7 ) ;
                             SKIP ( FSYS + [ COMMA , SEMICOLON ,
                                    RPARENT ] )
                           end (* then *) ;
                         TEST := SY <> COMMA ;
                         if not TEST then
                           INSYMBOL
                       until TEST ;
                       if SY = COLON then
                         begin
                           INSYMBOL ;
                           if SY = IDENT then
                             begin
                               DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE
                                            , [ TYPES ] , LCP4 ) ;
                               LEN := PTRSIZE ;
                               LSP := LCP4 -> . IDTYPE ;
                               LALN := PTRSIZE ;
                               if LSP <> NIL then
                                 if ( LKIND = ACTUAL ) then
                                   if LSP -> . FORM = FILES then
                                     begin
                                       ERROR ( 121 ) ;
                                       LKIND := FORMAL
                                     end (* then *)
                                   else
                                     begin
                                       LEN := LSP -> . SIZE ;
                                       LALN := LSP -> . ALN
                                     end (* else *) ;
                               LCP4 := LCP3 ;
                               while LCP4 <> NIL do
                                 begin
                                   with LCP4 -> do
                                     begin
                                       IDTYPE := LSP ;
                                       ALIGN ( LCOUNTER , LALN ) ;
                                       VADDR := LCOUNTER ;
                                       LCOUNTER := LCOUNTER + LEN ;
                                     end (* with *) ;
                                   LCP4 := LCP4 -> . NEXT
                                 end (* while *) ;
                               INSYMBOL
                             end (* then *)
                           else
                             ERROR ( 2 ) ;
                           if not ( SY in FSYS + [ SEMICOLON , RPARENT
                           ] ) then
                             begin
                               ERROR ( 7 ) ;
                               SKIP ( FSYS + [ SEMICOLON , RPARENT ] )
                             end (* then *)
                         end (* then *)
                       else
                         ERROR ( 5 ) ;
                     end (* else *) ;
                   if SY = SEMICOLON then
                     begin
                       INSYMBOL ;
                       if not ( SY in FSYS + [ IDENT , VARSY , PROCSY ,
                       FUNCSY ] ) then
                         begin
                           ERROR ( 7 ) ;
                           SKIP ( FSYS + [ IDENT , RPARENT ] )
                         end (* then *)
                     end (* then *) ;
                   if LCP1 <> NIL then
                     LCP2 -> . NEXT := LCP3
                   else
                     LCP1 := LCP3 ;
                   LCP2 := LCP ;
                 end (* while *) ;
               if SY = RPARENT then
                 begin
                   INSYMBOL ;
                   if not ( SY in FSY + FSYS ) then
                     begin
                       ERROR ( 6 ) ;
                       SKIP ( FSY + FSYS )
                     end (* then *)
                 end (* then *)
               else
                 ERROR ( 4 ) ;
             end (* then *)
           else

           (********************)
           (* IF SY <> LPARENT *)
           (********************)

             ;
           if not FW then
             FPAR -> . PRMPTR := LCP1 ;
           if FPAR -> . KLASS = FUNC then
             if SY = COLON then
               begin
                 INSYMBOL ;
                 if SY = IDENT then
                   begin
                     if FW then
                       ERROR ( 122 ) ;
                     DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE , [ TYPES
                                  ] , LCP1 ) ;
                     LSP := LCP1 -> . IDTYPE ;
                     FPAR -> . IDTYPE := LSP ;
                     if LSP <> NIL then
                       if LSP -> . FORM >= POWER then
                         begin
                           ERROR ( 120 ) ;
                           FPAR -> . IDTYPE := NIL
                         end (* then *) ;
                     INSYMBOL
                   end (* then *)
                 else
                   begin
                     ERROR ( 2 ) ;
                     SKIP ( FSYS + [ SEMICOLON ] )
                   end (* else *)
               end (* then *)
             else
               if not FW then
                 ERROR ( 123 )
         end (* PARAMETERLIST *) ;


      begin (* PROCDECLARATION *)
        LLC := LCOUNTER ;
        LCOUNTER := LCAFTMST + FPSAVEAREA ;

        (***************************)
        (* ADR. OF 1ST VAR OR PARM *)
        (***************************)

        LCM := LCAFTMST ;
        LCP := UPRCPTR ;

        (*******************************)
        (* TO INITIALIZE LCP IN CASE ! *)
        (*******************************)

        if SY = IDENT then
          begin

        (**************************************)
        (* SEE IF PROC. ON FORWARD DECL. LIST *)
        (**************************************)

            FORW := FALSE ;
            LCP := FWRDPRCL ;
            LCP2 := NIL ;
            while LCP <> NIL do
              if LCP -> . NAME = ID then
                begin
                  FORW := TRUE ;
                  if LCP2 <> NIL then
                    LCP2 -> . NXTFWRD := LCP -> . NXTFWRD
                  else
                    FWRDPRCL := LCP -> . NXTFWRD ;
                  break
                end (* then *)
              else
                begin
                  LCP2 := LCP ;
                  LCP := LCP -> . NXTFWRD
                end (* else *) ;
            if not FORW then
              begin
                if FSY = PROCSY then
                  NEW ( LCP , PROC , DECLARED )
                else
                  NEW ( LCP , FUNC , DECLARED ) ;
                with LCP -> do
                  begin
                    NAME := ID ;
                    IDTYPE := NIL ;
                    PFLEV := LEVEL ;
                    PROCLAB := PROCLAB + 1 ;
                    PFDECKIND := DECLARED ;
                    PFKIND := ACTUAL ;
                    PFNAME := PROCLAB ;
                    INTERN := ( not IS_MODULE ) or ( LEVEL > 1 ) or (
                              PLOCAL ) ;
                    MKPROCNAME ( ID , NAME_PATTERN , PFNAME , INTERN )
                                 ;
                    EXTRN := not INTERN ;
                    FRTRN := FALSE ;
                    FWDECL := FALSE ;
                    DECLMISSING := FALSE ;
                    PACK ( ID , 1 , EXTNAME ) ;
                    PROC_TO_STATNAME ( EXTNAME , EXTRN , CSTNAME ) ;
                    if FSY = PROCSY then
                      KLASS := PROC
                    else
                      KLASS := FUNC
                  end (* with *) ;
                ENTERID ( LCP ) ;
                OLD_HASH := BUCKET ;

        (*************************)
        (* NEW SCOPE BEGINS NEXT *)
        (*************************)

              end (* then *)
            else
              begin
                LCP1 := LCP -> . PRMPTR ;
                LCP -> . FWDECL := FALSE ;
                OLD_HASH := BUCKET ;

        (************************)
        (* NEW SCOPE BEGINS NOW *)
        (************************)

                LEVEL := LEVEL + 1 ;
                TOP := LEVEL ;
                while LCP1 <> NIL do
                  begin
                    ENTERID ( LCP1 ) ;

        (*******************************)
        (* NAME NEEDS TO BE RE-ENTERED *)
        (*******************************)

                    with LCP1 -> do
                      if KLASS = VARS then
                        if IDTYPE <> NIL then
                          begin
                            if VKIND = FORMAL then
                              LCM := VADDR + PTRSIZE
                            else
                              LCM := VADDR + IDTYPE -> . SIZE ;
                            if LCM > LCOUNTER then
                              LCOUNTER := LCM
                          end (* then *) ;
                    LCP1 := LCP1 -> . NEXT
                  end (* while *) ;
                LEVEL := LEVEL - 1 ;
                TOP := LEVEL
              end (* else *) ;
            INSYMBOL
          end (* then *)
        else
          ERROR ( 2 ) ;
        OLDLABEL := INTLABEL ;
        INTLABEL := 0 ;
        if LEVEL < MAXLEVEL then
          LEVEL := LEVEL + 1
        else
          FATALERROR ( 251 ) ;
        TOP := LEVEL ;
        with DISPLAY [ TOP ] do
          begin
            OCCUR := BLCK ;
            FLABEL := NIL
          end (* with *) ;
        if GET_STAT then
          PROC_CNT [ LEVEL ] := PROC_CNT [ LEVEL ] + 1 ;
        if FSY = PROCSY then
          PARAMETERLIST ( [ SEMICOLON ] , LCP , FORW )
        else
          PARAMETERLIST ( [ SEMICOLON , COLON ] , LCP , FORW ) ;
        LCP -> . FWDECL := FALSE ;
        if SY = SEMICOLON then
          INSYMBOL
        else
          ERROR ( 14 ) ;
        if SY in [ FORWARDSY , FRTRNSY , EXTRNSY ] then
          begin
            if SY = FORWARDSY then
              begin
                if FORW then
                  ERROR ( 161 ) ;
                LCP -> . FWDECL := TRUE ;
                LCP -> . NXTFWRD := FWRDPRCL ;

        (*******************)
        (* LINK PROC. INTO *)
        (*******************)

                FWRDPRCL := LCP ;

        (**********************)
        (* FORWARD PROC. LIST *)
        (**********************)

                INSYMBOL
              end (* then *)
            else
              begin

        (*********************************)
        (* SY MUST BE FRTRNSY OR EXTRNSY *)
        (*********************************)

                if SY = FRTRNSY then
                  LCP -> . FRTRN := TRUE
                else
                  LCP -> . EXTRN := TRUE ;
                INSYMBOL ;
                with LCP -> do
                  if SY = STRINGCONST then
                    with VAL . SVAL -> do
                      begin
                        while LENGTH < EXTNAMSZ do
                          begin
                            LENGTH := LENGTH + 1 ;
                            SSTR [ I ] := ' '
                          end (* while *) ;
                        PACK ( SSTR , 1 , EXTNAME ) ;
                        PROC_TO_STATNAME ( EXTNAME , EXTRN , CSTNAME )
                                           ;
                        INSYMBOL
                      end (* with *)
                  else
                    begin
                      PACK ( NAME , 1 , EXTNAME ) ;
                      PROC_TO_STATNAME ( EXTNAME , EXTRN , CSTNAME ) ;
                    end (* else *)
              end (* else *) ;
            if SY = SEMICOLON then
              INSYMBOL
            else
              ERROR ( 14 ) ;
            if not ( SY in FSYS ) then
              begin
                ERROR ( 6 ) ;
                SKIP ( FSYS )
              end (* then *)
          end (* then *)
        else
          begin
            if DEBUG_LEV > 0 then
              PRNTSYMBL ( LCP ) ;
            MARK ( MARKP ) ;

        (*****************************)
        (* MARK HEAP FOR BLOCK ENTRY *)
        (*****************************)

            repeat
              BLOCK ( FSYS , SEMICOLON , LCP ) ;
              if SY = SEMICOLON then
                begin
                  INSYMBOL ;
                  if not ( SY in [ BEGINSY , PROCSY , FUNCSY , LOCALSY
                  ] ) then
                    begin
                      ERROR ( 6 ) ;
                      SKIP ( FSYS )
                    end (* then *)
                end (* then *)
              else
                ERROR ( 14 )
            until SY in [ BEGINSY , PROCSY , FUNCSY , LOCALSY ] ;
            RELEASE ( MARKP ) ;

        (****************************************)
        (* RETURN LOCAL ENTRIES ON RUNTIME HEAP *)
        (****************************************)

          end (* else *) ;
        LEVEL := LEVEL - 1 ;
        TOP := LEVEL ;
        LCOUNTER := LLC ;
        INTLABEL := OLDLABEL ;
        BUCKET := OLD_HASH ;

        (**********************)
        (*RESTORE SYMBOL TABLE*)
        (**********************)

      end (* PROCDECLARATION *) ;


   function PROCTYPE ( FPROCP : IDP ) : INTEGER ;

      begin (* PROCTYPE *)
        PROCTYPE := ORD ( 'P' ) ;
        if FPROCP <> NIL then
          with FPROCP -> do
            begin
              if FRTRN then
                PROCTYPE := ORD ( 'F' ) ;
              if FPROCP -> . IDTYPE <> NIL then
                with FPROCP -> do
                  begin
                    if IDTYPE = REALPTR then
                      if FRTRN then
                        PROCTYPE := ORD ( 'Z' )
                      else
                        PROCTYPE := ORD ( 'R' )
                    else
                      if IDTYPE = BOOLPTR then
                        if FRTRN then
                          PROCTYPE := ORD ( 'X' )
                        else
                          PROCTYPE := ORD ( 'B' )
                      else
                        if IDTYPE -> . FORM = POINTER then
                          PROCTYPE := ORD ( 'A' )
                        else
                          if IDTYPE -> . SIZE = 1 then
                            PROCTYPE := ORD ( 'C' )
                          else
                            if FRTRN then
                              PROCTYPE := ORD ( 'Y' )
                            else
                              if IDTYPE -> . SIZE = HINTSIZE then
                                PROCTYPE := ORD ( 'H' )
                              else
                                PROCTYPE := ORD ( 'I' ) ;
                  end (* with *)
            end (* with *) ;
      end (* PROCTYPE *) ;


   procedure BODY ( FSYS : SETOFSYS ) ;

      type OPRANGE = 0 .. OPMAX ;
           CALLED_PROC = record
                           NAME : ALPHA ;
                           LVL : LEVRANGE ;
                           CNT : 1 .. 100 ;
                           NXT : -> CALLED_PROC
                         end ;

      var CALL_HEAD , T2_CLIST , T_CLIST : -> CALLED_PROC ;
          LOCAL_CALL , MODIFYING : BOOLEAN ;

          (*********************************************)
          (* LOCAL_CALL = THIS PROC CALLS A LOCAL PROC *)
          (* MODIFYING = A PROGRAM VAR BEING MODIFIED  *)
          (*********************************************)

          VAR_REF , VAR_MOD : INTEGER ;

          (***************************************)
          (* # OF VARIABLES ACCESSED/REFERENCED  *)
          (***************************************)

          DDNAME : XCONSTANT ;
          CNSTPTR : CONSTP ;
          I : INTEGER ;
          LCMAX , LLC1 : ADDRRANGE ;
          LCP , LLCP : IDP ;
          LLP : LBP ;
          FIRSTLN : INTEGER ;
          CTRNO : CTRRANGE ;
          LOOP0 : LOOPCTL ;
          SUBR : SUBRCTL ;
          LRETURN : LABELRNG ;
          CSTEXTNAME : EXTNAMTP ;
          XCSP : CSPTYPE ;


      procedure GEN0 ( FOP : OPRANGE ) ;

         begin (* GEN0 *)
           if PRCODE then
             begin
               PUTIC ;
               WRITELN ( PRR , MN [ FOP ] : 4 )
             end (* then *) ;
           ICOUNTER := ICOUNTER + 1
         end (* GEN0 *) ;


      procedure GEN_LCA_S ( ELTYPE : TTP ; VAL : XCONSTANT ) ;

         begin (* GEN_LCA_S *)
           if PRCODE then
             begin
               PUTIC ;
               WRITE ( PRR , MN [ 37 ] : 4 ) ;

           (********)
           (*LCA S *)
           (********)

               WRITE ( PRR , ' S,' ) ;
               WRITESET ( VAL , ELTYPE ) ;
             end (* then *) ;
           ICOUNTER := ICOUNTER + 1
         end (* GEN_LCA_S *) ;


      procedure GEN_LCA_M ( VAL : XCONSTANT ) ;

         begin (* GEN_LCA_M *)
           if PRCODE then
             begin
               PUTIC ;
               WRITE ( PRR , MN [ 37 ] : 4 ) ;

           (********)
           (*LCA M *)
           (********)

               WRITE ( PRR , ' M,' ) ;
               GEN_STRCONST ( VAL ) ;
               STRCOUNTER := STRCOUNTER + VAL . SVAL -> . LENGTH ;
               WRITELN ( PRR ) ;
             end (* then *) ;
           ICOUNTER := ICOUNTER + 1
         end (* GEN_LCA_M *) ;


      procedure GEN1 ( FOP : OPRANGE ; FP2 : INTEGER ) ;

         var K : INTEGER ;
             LCCALLER : ADDRRANGE ;

         begin (* GEN1 *)
           if PRCODE then
             begin
               PUTIC ;
               WRITE ( PRR , MN [ FOP ] : 4 ) ;
               case FOP of
                 30 : begin

           (********)
           (*CSP   *)
           (********)

                        WRITE ( PRR , SNA [ FP2 ] : 4 ) ;
                        LCCALLER := LCOUNTER ;
                        ALIGN ( LCCALLER , MXDATASZE ) ;
                        WRITELN ( PRR , ',' , LCCALLER : 1 ) ;
                      end (* tag/ca *) ;
                 37 : begin

           (*********************************)
           (*LCA P = LOAD PROCEDURE ADDRESS *)
           (*********************************)

                        if FP2 = ORD ( 'P' ) then
                          WRITELN ( PRR , ' P,' , ID : EXTNAMSZ )
                      end (* tag/ca *) ;
                 26 , 42 :
                   begin

           (*********)
           (*STO,RET*)
           (*********)

                     WRITELN ( PRR , CHR ( FP2 ) : 2 )
                   end (* tag/ca *) ;
                 otherwise
                   begin
                     WRITELN ( PRR , ' ' , FP2 : 1 )
                   end (* otherw *)
               end (* case *)
             end (* then *) ;
           ICOUNTER := ICOUNTER + 1
         end (* GEN1 *) ;


      procedure GEN_SET ( FOP : OPRANGE ; FP1 , FP2 : INTEGER ) ;

         begin (* GEN_SET *)
           if PRCODE then
             begin
               PUTIC ;
               WRITE ( PRR , MN [ FOP ] : 4 , ' ' ) ;
               case FOP of

           (*********)
           (*SCL    *)
           (*********)

                 29 : WRITELN ( PRR , FP1 : 1 , ',' , FP2 : 1 ) ;

           (*********)
           (*SLD    *)
           (*********)

                 68 : WRITELN ( PRR , FP1 : 1 , ',' , FP2 : 1 ) ;

           (*********)
           (*SMV    *)
           (*********)

                 69 : WRITELN ( PRR , FP1 : 1 ) ;
               end (* case *) ;
             end (* then *) ;
           ICOUNTER := ICOUNTER + 1
         end (* GEN_SET *) ;


      procedure GEN2 ( FOP : OPRANGE ; FP1 , FP2 : INTEGER ) ;

         var I , J , K : INTEGER ;

         begin (* GEN2 *)
           if PRCODE then
             begin
               PUTIC ;
               WRITE ( PRR , MN [ FOP ] : 4 , ' ' ) ;
               case FOP of

           (*********************)
           (*DEC,INC,IND,LDO,SRO*)
           (*********************)

                 22 , 23 , 35 , 39 , 43 :
                   WRITELN ( PRR , CHR ( FP1 ) , ',' , FP2 : 1 ) ;

           (*************************)
           (*MST,LDA,NEW            *)
           (*************************)

                 41 , 50 , 58 :
                   WRITELN ( PRR , FP1 : 1 , ',' , FP2 : 1 ) ;

           (*************************)
           (*SCL,SLD,SMV            *)
           (*deprecated here,       *)
           (*is now implemented     *)
           (*in GEN_SET ...         *)
           (*************************)

                 29 , 68 , 69 :
                   begin
                     WRITELN ( TRACEF , '+++ error, see procedure gen2'
                               ) ;
                     WRITELN ( PRR , FP1 : 1 , ',' , FP2 : 1 ,
                               ' +++ error +++' ) ;
                   end (* tag/ca *) ;

           (*****************)
           (*AND,IOR,NOT,XOR*)
           (*****************)

                 4 , 13 , 19 , 79 :
                   WRITELN ( PRR , CHR ( FP1 ) ) ;

           (**********)
           (*EQU..NEQ*)
           (**********)

                 47 , 48 , 49 , 52 , 53 , 55 :
                   begin
                     WRITE ( PRR , CHR ( FP1 ) ) ;
                     if FP1 = ORD ( 'M' ) then
                       WRITE ( PRR , ',' , FP2 : 1 ) ;
                     WRITELN ( PRR )
                   end (* tag/ca *) ;

           (********)
           (*LDC   *)
           (********)

                 51 : case FP1 of
                        0 : WRITELN ( PRR , 'C,''' , CHR ( FP2 ) : 1 ,
                                      '''' ) ;
                        1 : WRITELN ( PRR , 'I,' , FP2 : 1 ) ;
                        2 : begin
                              WRITE ( PRR , 'R,' ) ;
                              with CNSTPTR -> do
                                for K := 1 to REALLNGTH do
                                  if RVAL [ K ] <> ' ' then
                                    WRITE ( PRR , RVAL [ K ] ) ;
                              WRITELN ( PRR )
                            end (* tag/ca *) ;
                        3 : WRITELN ( PRR , 'B,' , FP2 : 1 ) ;
                        4 : WRITELN ( PRR , 'N' ) ;
                        otherwise
                          ERROR ( 400 ) ;
                      end (* case *)
               end (* case *) ;
             end (* then *) ;
           ICOUNTER := ICOUNTER + 1
         end (* GEN2 *) ;


      procedure GEN3 ( FOP : OPRANGE ; FP0 , FP1 , FP2 : INTEGER ) ;

         begin (* GEN3 *)
           if PRCODE then
             begin
               PUTIC ;
               if FOP = 76

           (********)
           (*PAK   *)
           (********)


               then
                 WRITELN ( PRR , MN [ FOP ] : 4 , ' ' , FP0 : 1 , ' ' ,
                           FP1 : 1 , ' ' , FP2 : 1 )
               else
                 WRITELN ( PRR , MN [ FOP ] : 4 , CHR ( FP0 ) : 2 , ','
                           , FP1 : 1 , ',' , FP2 : 1 )
             end (* then *) ;
           ICOUNTER := ICOUNTER + 1
         end (* GEN3 *) ;


      procedure LOAD ;

         begin (* LOAD *)
           with GATTR do
             if TYPTR <> NIL then
               begin
                 case KIND of
                   CST : if ( TYPTR -> . FORM = SCALAR ) and ( TYPTR <>
                         REALPTR ) then
                           if TYPTR = BOOLPTR then

           (********)
           (*LDC   *)
           (********)

                             GEN2 ( 51 , 3 , CVAL . IVAL )
                           else
                             if TYPTR = CHARPTR then

           (******************************************************)
           (*LDC - if char constant has been coded in binary     *)
           (*      or hex, it will be presented in integer       *)
           (*      format to the LDC P-Code operation - 06.2017  *)
           (******************************************************)

                               if CVAL . STRTYPE in [ 'X' , 'B' ] then
                                 GEN2 ( 51 , 1 , CVAL . IVAL )
                               else
                                 GEN2 ( 51 , 0 , CVAL . IVAL )
                             else

           (********)
           (*LDC   *)
           (********)

                               GEN2 ( 51 , 1 , CVAL . IVAL )

           (*********)
           (*INTEGER*)
           (*********)

                         else
                           if TYPTR = ANYPTR then

           (********)
           (*LDC   *)
           (********)

                             GEN2 ( 51 , 4 , 0 )
                           else
                             begin
                               CNSTPTR := ADDR ( CVAL ) ;
                               if TYPTR = REALPTR then

           (********)
           (*LDC   *)
           (********)

                                 GEN2 ( 51 , 2 , 0 )
                               else

           (********)
           (*LDC   *)
           (********)

                                 GEN2 ( 51 , 5 , 0 )
                             end (* else *) ;
                   VARBL : case ACCESS of

           (********)
           (*LOD   *)
           (********)

                             DRCT : GEN3 ( 54 , GETTYPE ( BTYPE ) ,
                                           VLEVEL , DPLMT ) ;

           (********)
           (*IND   *)
           (********)

                             INDRCT :
                               GEN2 ( 35 , GETTYPE ( BTYPE ) , IDPLMT )
                                      ;
                             INXD , STKEXPR :
                               ERROR ( 400 )
                           end (* case *) ;
                   EXPR :
                 end (* case *) ;
                 if KIND = VARBL then
                   VAR_REF := VAR_REF + 1 ;
                 KIND := EXPR
               end (* then *)
         end (* LOAD *) ;


      procedure STORE ( var FATTR : ATTR ) ;

         begin (* STORE *)
           with FATTR do
             if TYPTR <> NIL then
               case ACCESS of

           (********)
           (*STR   *)
           (********)

                 DRCT : GEN3 ( 56 , GETTYPE ( BTYPE ) , VLEVEL , DPLMT
                               ) ;
                 INDRCT :
                   if IDPLMT <> 0 then
                     ERROR ( 400 )
                   else

           (********)
           (*STO   *)
           (********)

                     GEN1 ( 26 , GETTYPE ( BTYPE ) ) ;
                 INXD , STKEXPR :
                   ERROR ( 400 )
               end (* case *)
         end (* STORE *) ;


      procedure LOADADDRESS ;

         begin (* LOADADDRESS *)
           with GATTR do
             if TYPTR <> NIL then
               begin
                 case KIND of
                   CST : if XSTRING ( TYPTR ) then
                           GEN_LCA_M ( CVAL )
                         else
                           if TYPTR -> . FORM = CHARSTRING then
                             GEN_LCA_M ( CVAL )
                           else
                             if TYPTR -> . FORM = POWER then
                               GEN_LCA_S ( TYPTR -> . ELSET , CVAL )
                             else
                               ERROR ( 400 ) ;
                   VARBL : case ACCESS of

           (********)
           (*LDA   *)
           (********)

                             DRCT : GEN2 ( 50 , VLEVEL , DPLMT ) ;
                             INDRCT :
                               if IDPLMT <> 0 then

           (********)
           (*INC   *)
           (********)

                                 GEN2 ( 23 , ORD ( 'A' ) , IDPLMT ) ;
                             INXD : ERROR ( 400 ) ;
                             STKEXPR :
                               ;

           (***************************************)
           (*SET ALREADY REPRESENTED BY AN ADDRESS*)
           (***************************************)

                           end (* case *) ;
                   EXPR : ERROR ( 400 )
                 end (* case *) ;
                 KIND := VARBL ;
                 ACCESS := INDRCT ;
                 IDPLMT := 0
               end (* then *)
         end (* LOADADDRESS *) ;


      procedure GENFJP ( FADDR : INTEGER ) ;

         begin (* GENFJP *)
           LOAD ;
           if GATTR . TYPTR <> NIL then
             if GATTR . TYPTR <> BOOLPTR then
               ERROR ( 144 ) ;
           if PRCODE then
             begin
               PUTIC ;
               WRITELN ( PRR , MN [ 33 ] : 4 , ' L' , FADDR : 1 )
             end (* then *) ;
           ICOUNTER := ICOUNTER + 1
         end (* GENFJP *) ;


      procedure GENUJPFJP ( FOP : OPRANGE ; FP2 : INTEGER ) ;

         begin (* GENUJPFJP *)
           if PRCODE then
             begin
               PUTIC ;
               if FOP = 44 then
                 begin
                   if PORTABLE_BRANCHTABLE then
                     WRITELN ( PRR , MN [ FOP ] : 4 , ' N,L' , FP2 : 1
                               )
                   else
                     WRITELN ( PRR , MN [ FOP ] : 4 , ' L' , FP2 : 1 )
                 end (* then *)
               else
                 WRITELN ( PRR , MN [ FOP ] : 4 , ' L' , FP2 : 1 )
             end (* then *) ;
           ICOUNTER := ICOUNTER + 1
         end (* GENUJPFJP *) ;


      procedure GENDEF ( LABELNR : ADDRRANGE ; TYP : CHAR ; WERT :
                       ADDRRANGE ) ;

         begin (* GENDEF *)
           if PRCODE then
             begin
               PUTIC ;

           (********)
           (*DEF   *)
           (********)

               if LABELNR > 0 then
                 WRITE ( PRR , 'L' , LABELNR : 1 ) ;
               WRITE ( PRR , MN [ 63 ] , ' ' ) ;
               WRITE ( PRR , TYP , ',' ) ;
               case TYP of
                 'I' : WRITE ( PRR , WERT : 1 ) ;
                 'C' : WRITE ( PRR , '''' , CHR ( WERT ) , '''' ) ;
               end (* case *) ;
               WRITELN ( PRR ) ;
             end (* then *)
         end (* GENDEF *) ;


      procedure CHKBNDS ( FSP : TTP ) ;

         var LMIN , LMAX : INTEGER ;

         begin (* CHKBNDS *)
           if FSP <> NIL then
             if FSP <> BOOLPTR then
               if FSP <> INTPTR then
                 if FSP <> REALPTR then

           (*********************************************)
           (* typ = voidptr rausnehmen                  *)
           (* opp 09.2016                               *)
           (*********************************************)

                   if FSP <> ANYPTR then
                     if FSP -> . FORM <= POINTER then

           (*********************************************)
           (* LMAX <= LMIN (?)                          *)
           (* diese checks nicht mehr, weil pointer     *)
           (* nicht nur heap-pointer sein koennen       *)
           (* siehe pasmonn / $ptrchk                   *)
           (* opp 09.2016                               *)
           (*********************************************)

                       if FSP -> . FORM = POINTER then
                         begin
                           if FALSE then
                             begin
                               FLIPDEBUG := TRUE ;
                               if ASSIGN then
                                 GEN3 ( 45 , ORD ( 'A' ) , - 1 , 0 )
                               else
                                 GEN3 ( 45 , ORD ( 'A' ) , 0 , 0 )
                             end (* then *)
                         end (* then *)
                       else
                         begin

           (*************************)
           (* chk befehl generieren *)
           (*************************)

                           GETBOUNDS ( FSP , LMIN , LMAX ) ;
                           GEN3 ( 45 , ORD ( 'I' ) , LMIN , LMAX ) ;
                         end (* else *) ;
         end (* CHKBNDS *) ;


      procedure PUTLABEL ( LABNAME : INTEGER ) ;

         begin (* PUTLABEL *)
           if PRCODE then

           (********)
           (*LAB   *)
           (********)

             WRITELN ( PRR , 'L' , LABNAME : 1 , MN [ 64 ] )
         end (* PUTLABEL *) ;


      function CTRGEN : CTRRANGE ;

      (************************************)
      (* CREATE A UNIQUE STMT COUNTER     *)
      (* AND EMIT P-CODE TO INCREMENT IT  *)
      (* R. L. SITES  3 AUG 77            *)
      (************************************)


         begin (* CTRGEN *)
           CTRGEN := CTRCNT ;
           if CTROPTION then
             begin

           (********)
           (*CTI   *)
           (********)

               GEN1 ( 39 , CTRCNT ) ;
               CTRCNT := CTRCNT + 1 ;
             end (* then *) ;
         end (* CTRGEN *) ;


      procedure CTREMIT ( CTRT : CTRTYPE ; CTRNO : CTRRANGE ; FLN , MLN
                        , LLN : INTEGER ) ;

      (**************************************************)
      (* WRITE AN ENTRY DESCRIBING A STATEMENT COUNTER. *)
      (* R. L. SITES  3 AUG 77                          *)
      (**************************************************)


         begin (* CTREMIT *)
           if CTROPTION then
             WRITELN ( DBGINFO , '#CTR    ' , ORD ( CTRT ) : 4 , CTRNO
                       : 6 , FLN : 7 , MLN : 7 , LLN : 7 ) ;
         end (* CTREMIT *) ;


      procedure STATEMENT ( FSYS : SETOFSYS ; var LOOPC : LOOPCTL ; var
                          SUBR : SUBRCTL ) ;

         label 1 ;

         var LCP : IDP ;
             LLP : LBP ;
             TTOP : DISPRANGE ;
             XLABEL : ALPHA ;
             CTRNO : CTRRANGE ;
             IDFOUND : BOOLEAN ;
             STARTID : ALPHA ;
             CHCNT_SAVE : 0 .. BUFLEN ;
             CHCNT_SAVE2 : 0 .. BUFLEN ;


         procedure EXPRESSION ( FSYS : SETOFSYS ) ;

            FORWARD ;


         procedure FORCETEMPSET ( X : INTEGER ; TARGETSIZE : INTEGER )
                                ;

         (**************************************)
         (* "LOADS" CURRENT SET ONTO RUN-STACK *)
         (**************************************)


            var LSIZE : ADDRRANGE ;
                SETOFFS : INTEGER ;
                CHARTYPE : BOOLEAN ;
                SMV_OK : BOOLEAN ;

            begin (* FORCETEMPSET *)
              with GATTR do
                if TYPTR <> NIL then
                  if TYPTR -> . FORM = POWER then
                    begin
                      if KIND = VARBL then
                        if ACCESS = STKEXPR then
                          return ;
                      LSIZE := OPNDSETSIZE ( GATTR , SETOFFS , CHARTYPE
                               ) ;
                      if TARGETSIZE < 0 then
                        TARGETSIZE := LSIZE ;
                      if FALSE then
                        begin
                          WRITELN ( TRACEF , 'Forcetempset: linecnt = '
                                    , LINECNT : 1 , ' x = ' , X : 1 ,
                                    ' lsize = ' , LSIZE : 1 ) ;
                          WRITELN ( TRACEF ,
                                    'Forcetempset: chartype = ' ,
                                    CHARTYPE ) ;
                          WRITELN ( TRACEF ,
                                    'Forcetempset: targetsize = ' ,
                                    TARGETSIZE ) ;
                        end (* then *) ;
                      ALIGN ( LCOUNTER , WORDSIZE ) ;
                      LOADADDRESS ;

              (********)
              (*LDA   *)
              (********)

                      GEN2 ( 50 , LEVEL , LCOUNTER ) ;
                      SMV_OK := FALSE ;

              (*************************************************)
              (*  if PSI -> . CHARTYPE and                     *)
              (*     ( PSI -> . HEXORBIN = 'N' ) then          *)
              (*       SMV_OK := TRUE ;                        *)
              (*************************************************)

                      if SMV_OK then

              (********)
              (*SMV   *)
              (********)

                        GEN_SET ( 69 , - TARGETSIZE , 0 )
                      else

              (********)
              (*SLD   *)
              (********)

                        GEN_SET ( 68 , - TARGETSIZE , SETOFFS ) ;
                      KIND := VARBL ;
                      ACCESS := STKEXPR ;
                      STKLEN := LSIZE ;
                      STKDPLMT := LCOUNTER ;
                      LCOUNTER := LCOUNTER + LSIZE ;
                      if LCOUNTER > LCMAX then
                        LCMAX := LCOUNTER ;
                    end (* then *) ;
            end (* FORCETEMPSET *) ;


         procedure SELECTOR ( FSYS : SETOFSYS ; FCP : IDP ) ;

            var LATTR : ATTR ;
                LCP : IDP ;
                LMIN , LMAX : INTEGER ;

            begin (* SELECTOR *)
              with FCP -> , GATTR do
                begin
                  TYPTR := IDTYPE ;
                  BTYPE := TYPTR ;
                  KIND := VARBL ;
                  case KLASS of

              (****************************************************)
              (*   Erweiterung am 26.10.2016:                     *)
              (*   fuer den zugriff auf statische variablen       *)
              (*   - erkennbar an stklass = xstatic -             *)
              (*   wurde die logik aus dem zweig                  *)
              (*   fuer strukturierte Konstanten uebernommen;     *)
              (*   die ID des Owners kommt aus VOWNER;            *)
              (*   die VARS-Struktur wurde entsprechend           *)
              (*   erweitert                                      *)
              (****************************************************)

                    VARS : if STKLASS = XAUTO then
                             begin
                               if VKIND = ACTUAL then
                                 begin
                                   ACCESS := DRCT ;
                                   VLEVEL := VLEV ;
                                   DPLMT := VADDR
                                 end (* then *)
                               else
                                 begin

              (********)
              (*LOD   *)
              (********)

                                   GEN3 ( 54 , ORD ( 'A' ) , VLEV ,
                                          VADDR ) ;
                                   ACCESS := INDRCT ;
                                   IDPLMT := 0
                                 end (* else *)
                             end (* then *)
                           else
                             begin
                               ID := ' ' ;
                               UNPACK ( VOWNERPROC , ID , 1 ) ;

              (********)
              (*LCA   *)
              (********)

                               GEN1 ( 37 , ORD ( 'P' ) ) ;
                               ACCESS := INDRCT ;
                               VLEVEL := VLEV ;
                               IDPLMT := VADDR
                             end (* else *) ;
                    FIELD : with DISPLAY [ DISX ] do
                              if OCCUR = CREC then
                                begin
                                  ACCESS := DRCT ;
                                  VLEVEL := CLEV ;
                                  DPLMT := CDSPL + FLDADDR
                                end (* then *)
                              else
                                begin

              (********)
              (*LOD   *)
              (********)

                                  GEN3 ( 54 , ORD ( 'A' ) , LEVEL ,
                                         VDSPL ) ;
                                  ACCESS := INDRCT ;
                                  IDPLMT := FLDADDR
                                end (* else *) ;
                    STRUCTKONST :
                      begin
                        ID := ' ' ;
                        UNPACK ( SKOWNERPROC , ID , 1 ) ;

              (********)
              (*LCA   *)
              (********)

                        GEN1 ( 37 , ORD ( 'P' ) ) ;
                        ACCESS := INDRCT ;
                        IDPLMT := SKADDR
                      end (* tag/ca *) ;
                    FUNC : if FCP <> UFCTPTR then
                             if PFDECKIND = STANDARD then
                               ERROR ( 150 )
                             else
                               if PFLEV = 0 then
                                 ERROR ( 150 )

              (**************)
              (*EXTERNAL FCT*)
              (**************)

                               else
                                 if PFKIND = FORMAL then
                                   ERROR ( 151 )
                                 else
                                   if ( FPROCP <> FCP ) then
                                     ERROR ( 177 )
                                   else
                                     begin
                                       ACCESS := DRCT ;
                                       VLEVEL := PFLEV + 1 ;
                                       DPLMT := FNCRSLT ;

              (*****************************)
              (*RELAT. ADDR. OF FCT. RESULT*)
              (*****************************)

                                     end (* else *)
                  end (* case *) ;
                  if TYPTR <> NIL then
                    if TYPTR -> . FORM = SUBRANGE then
                      TYPTR := TYPTR -> . RANGETYPE ;
                end (* with *) ;
              if not ( SY in SELECTSYS + FSYS ) then
                begin
                  ERROR ( 59 ) ;
                  SKIP ( SELECTSYS + FSYS )
                end (* then *) ;
              while SY in SELECTSYS do
                begin
                  if SY = LPARENT then

              (****************************)
              (* THIS IS AN ERROR, BUT .. *)
              (****************************)

                    begin
                      SY := LBRACK ;
                      if GATTR . TYPTR <> NIL then
                        if GATTR . TYPTR -> . FORM = ARRAYS then
                          begin
                            ERRKIND := 'W' ;
                            ERROR ( 11 )
                          end (* then *)
                    end (* then *) ;

              (****************)
              (* LEFT BRACKET *)
              (****************)

                  if SY = LBRACK then
                    begin
                      repeat
                        LATTR := GATTR ;
                        with LATTR do
                          if TYPTR <> NIL then
                            if TYPTR -> . FORM <> ARRAYS then
                              begin
                                ERROR ( 138 ) ;
                                TYPTR := NIL
                              end (* then *) ;
                        LOADADDRESS ;
                        INSYMBOL ;
                        EXPRESSION ( FSYS + [ COMMA , RBRACK , RPARENT
                                     ] ) ;
                        LOAD ;
                        if GATTR . TYPTR <> NIL then
                          if GATTR . TYPTR -> . FORM <> SCALAR then
                            ERROR ( 113 ) ;
                        if LATTR . TYPTR <> NIL then
                          with LATTR . TYPTR -> do
                            begin
                              if COMPTYPES ( INXTYPE , GATTR . TYPTR )
                              = 1 then
                                begin
                                  if INXTYPE <> NIL then
                                    begin
                                      GETBOUNDS ( INXTYPE , LMIN , LMAX
                                                  ) ;
                                      if DEBUG then

              (********)
              (*CHK   *)
              (********)

                                        GEN3 ( 45 , ORD ( 'J' ) , LMIN
                                               , LMAX ) ;
                                      if LMIN > 0 then

              (********)
              (*DEC   *)
              (********)

                                        GEN2 ( 22 , GETTYPE ( GATTR .
                                               TYPTR ) , LMIN )
                                      else
                                        if LMIN < 0 then

              (********)
              (*INC   *)
              (********)

                                          GEN2 ( 23 , GETTYPE ( GATTR .
                                                 TYPTR ) , - LMIN )

              (**************************)
              (*OR SIMPLY GEN1(31, LMIN)*)
              (**************************)

                                    end (* then *)
                                end (* then *)
                              else
                                ERROR ( 139 ) ;
                              with GATTR do
                                begin
                                  TYPTR := AELTYPE ;
                                  KIND := VARBL ;
                                  ACCESS := INDRCT ;
                                  IDPLMT := 0 ;
                                  if GATTR . TYPTR <> NIL then
                                    begin
                                      LMIN := TYPTR -> . SIZE ;
                                      ALIGN ( LMIN , TYPTR -> . ALN ) ;

              (********)
              (*IXA   *)
              (********)

                                      GEN1 ( 36 , LMIN )
                                    end (* then *) ;
                                end (* with *) ;
                            end (* with *)
                      until SY <> COMMA ;
                      if SY = RBRACK then
                        INSYMBOL
                      else
                        begin
                          if SY = RPARENT then
                            begin
                              ERRKIND := 'W' ;
                              INSYMBOL
                            end (* then *) ;
                          ERROR ( 12 )
                        end (* else *) ;
                    end (* then *)
                  else

              (**********)
              (* PERIOD *)
              (**********)

                    if SY = PERIOD then
                      begin
                        with GATTR do
                          begin
                            if TYPTR <> NIL then
                              if TYPTR -> . FORM <> RECORDS then
                                begin
                                  ERROR ( 140 ) ;
                                  TYPTR := NIL
                                end (* then *) ;
                            INSYMBOL ;
                            if SY = IDENT then
                              begin
                                if TYPTR <> NIL then
                                  begin
                                    SEARCHSECTION ( TYPTR , LCP ) ;
                                    if LCP = NIL then
                                      begin
                                        ERROR ( 152 ) ;
                                        TYPTR := NIL
                                      end (* then *)
                                    else
                                      with LCP -> do
                                        begin
                                          TYPTR := IDTYPE ;
                                          case ACCESS of
                                            DRCT : DPLMT := DPLMT +
                                                   FLDADDR ;
                                            INDRCT :
                                              IDPLMT := IDPLMT +
                                                   FLDADDR ;
                                            INXD , STKEXPR :
                                              ERROR ( 400 )
                                          end (* case *)
                                        end (* with *)
                                  end (* then *) ;
                                INSYMBOL
                              end (* then *)
                            else
                              ERROR ( 2 )
                          end (* with *)
                      end (* then *)
                    else

              (*****************************)
              (* POINTER SYMBOL aka arrow  *)
              (*****************************)

                      begin
                        if GATTR . TYPTR <> NIL then
                          with GATTR , TYPTR -> do
                            if FORM = POINTER then
                              begin

              (***********************************)
              (* error if eltype = NIL, that is: *)
              (* anyptr - no deref allowed       *)
              (***********************************)

                                if ELTYPE = NIL then
                                  ERROR ( 187 ) ;
                                LOAD ;
                                if DEBUG then
                                  CHKBNDS ( GATTR . TYPTR ) ;
                                TYPTR := ELTYPE ;
                                with GATTR do
                                  begin
                                    KIND := VARBL ;
                                    ACCESS := INDRCT ;
                                    IDPLMT := 0
                                  end (* with *)
                              end (* then *)
                            else
                              if FORM = FILES then
                                begin
                                  if FILTYPE = NIL then
                                    ERROR ( 188 ) ;
                                  TYPTR := FILTYPE ;
                                  case ACCESS of
                                    DRCT : DPLMT := DPLMT + FILHDRSIZE
                                                   ;
                                    INDRCT :
                                      IDPLMT := IDPLMT + FILHDRSIZE ;
                                    INXD , STKEXPR :
                                      ERROR ( 400 )
                                  end (* case *)
                                end (* then *)
                              else
                                ERROR ( 141 ) ;
                        INSYMBOL
                      end (* else *) ;
                  if not ( SY in FSYS + SELECTSYS ) then
                    begin
                      ERROR ( 6 ) ;
                      SKIP ( FSYS + SELECTSYS )
                    end (* then *) ;
                  GATTR . BTYPE := GATTR . TYPTR ;
                  if GATTR . TYPTR <> NIL then
                    if GATTR . TYPTR -> . FORM = SUBRANGE then
                      GATTR . TYPTR := GATTR . TYPTR -> . RANGETYPE ;
                end (* while *) ;
            end (* SELECTOR *) ;


         procedure CALL ( FSYS : SETOFSYS ; FCP : IDP ) ;

            var LKEY : INTEGER ;
                MATCHPAR : BOOLEAN ;
                RWFILE : TTP ;
                LCCALLER : ADDRRANGE ;
                LCPARM : ADDRRANGE ;


            procedure VARIABLE ( FSYS : SETOFSYS ) ;

               var LCP : IDP ;

               begin (* VARIABLE *)
                 if SY = IDENT then
                   begin
                     DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE , [ VARS
                                  , FIELD ] , LCP ) ;
                     INSYMBOL
                   end (* then *)
                 else
                   begin
                     ERROR ( 2 ) ;
                     LCP := UVARPTR
                   end (* else *) ;
                 SELECTOR ( FSYS , LCP )
               end (* VARIABLE *) ;


            procedure PREPLIBRARYFUNC ( var LCCALLER : ADDRRANGE ; var
                                      LCPARM : ADDRRANGE ) ;

               begin (* PREPLIBRARYFUNC *)

                 (********)
                 (*mst   *)
                 (********)

                 GEN2 ( 41 , 0 , 0 ) ;

                 (***************************************************)
                 (* adresse fuer parameter ermitteln und ausrichten *)
                 (***************************************************)

                 LCCALLER := LCOUNTER ;
                 ALIGN ( LCCALLER , MXDATASZE ) ;
                 LCPARM := LCCALLER + LCAFTMST + FPSAVEAREA
               end (* PREPLIBRARYFUNC *) ;


            procedure CALLLIBRARYFUNC ( FCP : IDP ; LLCALLER :
                                      ADDRRANGE ) ;

               begin (* CALLLIBRARYFUNC *)
                 if PRCODE then
                   begin
                     PUTIC ;

                 (********)
                 (*CUP   *)
                 (********)

                     WRITE ( PRR , MN [ 46 ] ) ;
                     WRITE ( PRR , FCP -> . PROCTYP : 2 ) ;
                     WRITE ( PRR , ',' , FCP -> . PARMCNT * 2 + 3 : 1 )
                             ;
                     WRITE ( PRR , ',' , FCP -> . LIBNAME ) ;
                     WRITELN ( PRR , ',' , LLCALLER : 1 ) ;
                   end (* then *) ;
               end (* CALLLIBRARYFUNC *) ;


            procedure RWSETUP ( DFILE : IDP ; GENSIO : BOOLEAN ) ;

            (***************************************************)
            (* TO SET UP FILE ADDRESS PARAMETER FOR READ/WRITE *)
            (***************************************************)


               var LCP : IDP ;
                   SAVED : BOOLEAN ;
                   TEMPID : ALPHA ;
                   TEMPSY : SYMBOL ;

               begin (* RWSETUP *)
                 SAVED := TRUE ;
                 RWFILE := NIL ;
                 if MATCHPAR then

                 (*************************************)
                 (* OTHERWISE THERE ARE NO PARAMETERS *)
                 (*************************************)

                   if SY = IDENT then
                     begin
                       DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE , [
                                    VARS , FIELD , FUNC , KONST ,
                                    STRUCTKONST ] , LCP ) ;
                       if LCP -> . IDTYPE <> NIL then
                         with LCP -> . IDTYPE -> do
                           if FORM = FILES then
                             SAVED := FALSE ;
                     end (* then *) ;
                 if SAVED then
                   begin

                 (*************************)
                 (* USE IMPLIED FILE NAME *)
                 (*************************)

                     TEMPSY := SY ;
                     TEMPID := ID ;
                     SY := COMMA ;
                     if DFILE = NIL then
                       ERROR ( 185 ) ;
                     LCP := DFILE ;
                   end (* then *)
                 else
                   INSYMBOL ;
                 SELECTOR ( FSYS + [ COMMA , RPARENT ] , LCP ) ;
                 with GATTR do
                   if COMPTYPES ( TYPTR , TEXTPTR ) <> 1 then
                     if TYPTR <> NIL then
                       if TYPTR -> . FORM <> FILES then
                         ERROR ( 116 )
                       else
                         begin
                           RWFILE := TYPTR -> . FILTYPE ;
                           if not ( LKEY in [ 1 .. 6 , 25 , 36 , 37 ,
                           46 , 70 ] ) then
                             ERROR ( 116 ) ;

                 (**********************************************)
                 (*   NON-TEXT FILES PERMITTED ONLY FOR:       *)
                 (*   GET, PUT, RESET, READ, WRITE,            *)
                 (*   REWRITE, EOF, SKIP, LINELIMIT            *)
                 (**********************************************)

                         end (* else *) ;
                 LOADADDRESS ;
                 if GENSIO then
                   begin
                     GEN1 ( 30 , ORD ( PSIO ) ) ;
                   end (* then *) ;
                 if SAVED then
                   begin
                     ID := TEMPID ;
                     SY := TEMPSY
                   end (* then *) ;
               end (* RWSETUP *) ;


            procedure GETPUTRESETREWRITE ;

               begin (* GETPUTRESETREWRITE *)
                 if LKEY = 46 then
                   RWSETUP ( NIL , TRUE )
                 else
                   if ODD ( LKEY ) then
                     RWSETUP ( INPUTPTR , TRUE )
                   else
                     RWSETUP ( OUTPUTPTR , TRUE ) ;
                 case LKEY of
                   0 .. 4 :
                     GEN1 ( 30 , LKEY ) ;
                   46 : GEN1 ( 30 , 38 ) ;
                 end (* case *) ;

                 (*****************************)
                 (*CSP - GET,PUT,RES,REW,PAG  *)
                 (*CSP - CLS                  *)
                 (*****************************)

                 GEN1 ( 30 , ORD ( PEIO ) ) ;
               end (* GETPUTRESETREWRITE *) ;


            procedure READ1 ;

               var XCSP : CSPTYPE ;
                   TEST : BOOLEAN ;

               begin (* READ1 *)
                 RWSETUP ( INPUTPTR , TRUE ) ;
                 if RWFILE <> NIL then
                   if LKEY = 11 then
                     ERROR ( 116 ) ;
                 if MATCHPAR then

                 (*************************************)
                 (* OTHERWISE THERE ARE NO PARAMETERS *)
                 (*************************************)

                   begin
                     if SY = COMMA then
                       INSYMBOL ;
                     if LKEY = 5 then

                 (********)
                 (*READ  *)
                 (********)

                       if SY <> IDENT then
                         ERROR ( 2 ) ;
                     TEST := FALSE ;
                     if SY = IDENT then
                       repeat
                         VARIABLE ( FSYS + [ COMMA , RPARENT ] ) ;
                         LOADADDRESS ;
                         if GATTR . TYPTR <> NIL then
                           if RWFILE = NIL then
                             if XSTRING ( GATTR . TYPTR ) then
                               begin

                 (********)
                 (*LDC   *)
                 (********)

                                 GEN2 ( 51 , 1 , GATTR . TYPTR -> .
                                        SIZE DIV CHARSIZE ) ;
                                 XCSP := PRDS ;
                               end (* then *)
                             else
                               begin
                                 if GATTR . TYPTR = INTPTR then
                                   if GATTR . BTYPE -> . SIZE = INTSIZE
                                   then
                                     XCSP := PRDI
                                   else
                                     if GATTR . BTYPE -> . SIZE =
                                     HINTSIZE then
                                       XCSP := PRDH
                                     else
                                       XCSP := PRDY

                 (*****************************)
                 (*RDY - ONE BYTE INTEGER READ*)
                 (*****************************)

                                 else
                                   if GATTR . TYPTR = REALPTR then
                                     XCSP := PRDR
                                   else
                                     if GATTR . TYPTR = CHARPTR then
                                       XCSP := PRDC
                                     else
                                       if GATTR . TYPTR = BOOLPTR then
                                         XCSP := PRDB
                                       else
                                         begin
                                           ERROR ( 116 ) ;
                                           XCSP := PRDI
                                         end (* else *) ;
                               end (* else *)
                           else

                 (***********************)
                 (* NON-TEXT FILE INPUT *)
                 (***********************)

                             begin
                               if COMPTYPES ( GATTR . TYPTR , RWFILE )
                               <> 1 then
                                 ERROR ( 153 ) ;

                 (********)
                 (*LDC   *)
                 (********)

                               GEN2 ( 51 , 1 , GATTR . BTYPE -> . SIZE
                                      ) ;
                               XCSP := PRDD ;
                               EXTUSED := TRUE ;
                             end (* else *) ;
                         GEN1 ( 30 , ORD ( XCSP ) ) ;
                         if SY = COMMA then
                           INSYMBOL
                         else
                           TEST := TRUE ;
                       until TEST ;
                   end (* then *) ;
                 if LKEY = 11 then
                   GEN1 ( 30 , ORD ( PRLN ) ) ;
                 GEN1 ( 30 , ORD ( PEIO ) ) ;
               end (* READ1 *) ;


            procedure WRITE1 ;

               var LSP : TTP ;
                   DEFAULT , DEFAULT1 , TEST : BOOLEAN ;
                   LLKEY : INTEGER ;
                   LEN : ADDRRANGE ;
                   XCSP : CSPTYPE ;


               procedure WRITE2 ;

                  const LDC = 51 ;

                  begin (* WRITE2 *)
                    if LSP = NIL then
                      return ;

                    (************************)
                    (* write integer values *)
                    (************************)

                    if LSP = INTPTR then
                      begin
                        if DEFAULT then
                          GEN2 ( LDC , 1 , 12 ) ;
                        XCSP := PWRI ;
                        return
                      end (* then *) ;

                    (*********************)
                    (* write real values *)
                    (*********************)

                    if LSP = REALPTR then
                      begin
                        if DEFAULT then
                          GEN2 ( LDC , 1 , 14 ) ;
                        if DEFAULT1 then
                          GEN2 ( LDC , 1 , - 1 ) ;
                        XCSP := PWRR ;
                        return
                      end (* then *) ;

                    (*********************)
                    (* write char values *)
                    (*********************)

                    if LSP = CHARPTR then
                      begin
                        if DEFAULT then
                          GEN2 ( LDC , 1 , 1 ) ;
                        XCSP := PWRC ;
                        return
                      end (* then *) ;

                    (************************)
                    (* write boolean values *)
                    (************************)

                    if LSP = BOOLPTR then
                      begin
                        if DEFAULT then
                          GEN2 ( LDC , 1 , 5 ) ;
                        XCSP := PWRB ;
                        return
                      end (* then *) ;

                    (************************)
                    (* write pointer values *)
                    (************************)

                    if LSP -> . FORM = POINTER then
                      begin
                        if DEFAULT then
                          GEN2 ( LDC , 1 , 8 ) ;
                        XCSP := PWRP ;
                        return
                      end (* then *) ;

                    (***********************)
                    (* write scalar values *)
                    (***********************)

                    if LSP -> . FORM = SCALAR then
                      begin
                        if DEFAULT then
                          GEN2 ( LDC , 1 , 1 ) ;

                    (************************************)
                    (* LCA P for static csect of consts *)
                    (************************************)

                        ID := ' ' ;
                        UNPACK ( LSP -> . CSTNAME , ID , 1 ) ;
                        GEN1 ( 37 , ORD ( 'P' ) ) ;

                    (********)
                    (*INC A *)
                    (********)

                        GEN2 ( 23 , ORD ( 'A' ) , LSP -> . LITOFFS ) ;
                        XCSP := PWRX ;
                        return
                      end (* then *) ;

                    (************************************)
                    (* write string vars and constants  *)
                    (************************************)

                    if XSTRING ( LSP ) then
                      begin
                        LEN := LSP -> . SIZE DIV CHARSIZE ;
                        if DEFAULT then

                    (********)
                    (*LDC   *)
                    (********)

                          GEN2 ( LDC , 1 , LEN ) ;

                    (********)
                    (*LDC   *)
                    (********)

                        GEN2 ( LDC , 1 , LEN ) ;
                        XCSP := PWRS ;
                        return
                      end (* then *) ;

                    (***********************)
                    (* erroneous parameter *)
                    (***********************)

                    ERROR ( 116 ) ;
                    XCSP := PWRI ;
                  end (* WRITE2 *) ;


               begin (* WRITE1 *)
                 LLKEY := LKEY ;
                 TEST := FALSE ;
                 RWSETUP ( OUTPUTPTR , TRUE ) ;
                 if RWFILE <> NIL then
                   if LLKEY = 12 then
                     ERROR ( 116 ) ;
                 if MATCHPAR then

                 (***************************)
                 (* OTHERWISE NO PARAMETERS *)
                 (***************************)

                   begin
                     if SY = RPARENT then
                       if LLKEY = 6 then
                         ERROR ( 116 ) ;
                     if SY = COMMA then
                       begin
                         INSYMBOL ;
                         if not ( SY in SIMPTYPEBEGSYS ) then
                           ERROR ( 6 )
                       end (* then *) ;
                     if SY in SIMPTYPEBEGSYS then
                       repeat
                         EXPRESSION ( FSYS + [ COMMA , COLON , RPARENT
                                      ] ) ;
                         LSP := GATTR . TYPTR ;
                         if LSP -> . FORM <= POINTER then
                           LOAD
                         else
                           LOADADDRESS ;
                         if RWFILE = NIL then
                           begin
                             DEFAULT := TRUE ;
                             DEFAULT1 := TRUE ;
                             if SY = COLON then
                               begin
                                 INSYMBOL ;
                                 EXPRESSION ( FSYS + [ COMMA , COLON ,
                                              RPARENT ] ) ;
                                 LOAD ;
                                 if GATTR . TYPTR <> NIL then
                                   if GATTR . TYPTR <> INTPTR then
                                     ERROR ( 116 ) ;
                                 DEFAULT := FALSE ;
                                 if SY = COLON then
                                   begin
                                     INSYMBOL ;
                                     EXPRESSION ( FSYS + [ COMMA ,
                                                  RPARENT ] ) ;
                                     LOAD ;
                                     if GATTR . TYPTR <> NIL then
                                       if GATTR . TYPTR <> INTPTR then
                                         ERROR ( 116 ) ;
                                     if LSP <> REALPTR then
                                       ERROR ( 124 ) ;
                                     DEFAULT1 := FALSE ;
                                   end (* then *) ;
                               end (* then *) ;

                 (**************************************)
                 (* call write funcs depending on type *)
                 (**************************************)

                             WRITE2
                           end (* then *)
                         else

                 (*****************)
                 (* NON-TEXT FILE *)
                 (*****************)

                           begin
                             if COMPTYPES ( LSP , RWFILE ) <> 1 then
                               ERROR ( 145 ) ;

                 (********)
                 (*LDC   *)
                 (********)

                             GEN2 ( 51 , 1 , RWFILE -> . SIZE ) ;
                             EXTUSED := TRUE ;
                             if LSP <> NIL then
                               if LSP -> . FORM <= SUBRANGE then
                                 XCSP := PWRE
                               else
                                 XCSP := PWRD
                           end (* else *) ;
                         GEN1 ( 30 , ORD ( XCSP ) ) ;
                         if SY = COMMA then
                           INSYMBOL
                         else
                           TEST := TRUE ;
                       until TEST ;
                   end (* then *) ;

                 (***********)
                 (* WRITELN *)
                 (***********)

                 if LLKEY = 12 then
                   GEN1 ( 30 , ORD ( PWLN ) ) ;
                 GEN1 ( 30 , ORD ( PEIO ) ) ;
               end (* WRITE1 *) ;


            procedure SKIPLIM ;

               begin (* SKIPLIM *)
                 RWSETUP ( OUTPUTPTR , TRUE ) ;
                 if SY = COMMA then
                   begin
                     INSYMBOL ;
                     if not ( SY in SIMPTYPEBEGSYS ) then
                       ERROR ( 6 )
                   end (* then *) ;
                 if SY in SIMPTYPEBEGSYS then
                   begin
                     EXPRESSION ( FSYS + [ RPARENT ] ) ;
                     LOAD ;
                     if GATTR . TYPTR <> NIL then
                       if GATTR . TYPTR <> INTPTR then
                         ERROR ( 125 ) ;

                 (*****************)
                 (* CSP - SKP/LIM *)
                 (*****************)

                     GEN1 ( 30 , LKEY - 2 ) ;
                     GEN1 ( 30 , ORD ( PEIO ) ) ;
                   end (* then *)
               end (* SKIPLIM *) ;


            procedure MESSAGE1 ;

               var LEN : INTEGER ;

               begin (* MESSAGE1 *)
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;
                 if GATTR . TYPTR <> NIL then
                   if XSTRING ( GATTR . TYPTR ) then
                     LEN := GATTR . TYPTR -> . SIZE DIV CHARSIZE
                   else
                     ERROR ( 125 ) ;
                 LOADADDRESS ;

                 (********)
                 (*LDC   *)
                 (********)

                 GEN2 ( 51 , 1 , LEN ) ;
                 GEN1 ( 30 , ORD ( PMSG ) ) ;
               end (* MESSAGE1 *) ;


            procedure PACK1 ;

               var LSP , LSP1 : TTP ;
                   LSIZE , IMIN , IMAX : INTEGER ;
                   LCNT , RCNT , LELEMSIZE , RELEMSIZE : INTEGER ;

               begin (* PACK1 *)
                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;
                 LSP := NIL ;
                 LSP1 := NIL ;
                 if GATTR . TYPTR <> NIL then
                   with GATTR , GATTR . TYPTR -> do
                     if FORM = ARRAYS then
                       begin
                         LSP := INXTYPE ;
                         LSP1 := AELTYPE ;
                         IMIN := 1 ;
                         LSIZE := SIZE ;
                         IMAX := LSIZE ;
                         if LSP <> NIL then
                           GETBOUNDS ( LSP , IMIN , IMAX ) ;
                         LCNT := IMAX - IMIN + 1 ;
                         LELEMSIZE := LSIZE DIV LCNT ;
                         LOADADDRESS ;
                       end (* then *)
                     else
                       ERROR ( 116 ) ;
                 if SY = COMMA then
                   INSYMBOL
                 else
                   ERROR ( 20 ) ;
                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> SCALAR then
                     ERROR ( 116 )
                   else
                     if COMPTYPES ( LSP , GATTR . TYPTR ) <> 1 then
                       ERROR ( 116 )
                     else
                       begin
                         LOAD ;
                         if DEBUG then

                 (********)
                 (*CHK   *)
                 (********)

                           GEN3 ( 45 , ORD ( 'J' ) , IMIN , IMAX ) ;
                         if IMIN > 0 then

                 (********)
                 (*DEC   *)
                 (********)

                           GEN2 ( 22 , GETTYPE ( GATTR . TYPTR ) , IMIN
                                  )
                         else
                           if IMIN < 0 then

                 (********)
                 (*INC   *)
                 (********)

                             GEN2 ( 23 , GETTYPE ( GATTR . TYPTR ) , -
                                    IMIN ) ;

                 (********)
                 (*IXA   *)
                 (********)

                         GEN1 ( 36 , LELEMSIZE ) ;
                       end (* else *) ;
                 if SY = COMMA then
                   INSYMBOL
                 else
                   ERROR ( 20 ) ;
                 VARIABLE ( FSYS + [ RPARENT ] ) ;
                 if GATTR . TYPTR <> NIL then
                   with GATTR . TYPTR -> do
                     if FORM = ARRAYS then
                       begin
                         if ( COMPTYPES ( AELTYPE , LSP1 ) <> 1 ) or (
                         COMPTYPES ( INXTYPE , LSP ) <> 1 ) then
                           ERROR ( 116 )
                         else
                           begin
                             LOADADDRESS ;
                             LSP := INXTYPE ;
                             LSP1 := AELTYPE ;
                             if LSP <> NIL then
                               GETBOUNDS ( LSP , IMIN , IMAX )
                             else
                               begin
                                 IMIN := 1 ;
                                 IMAX := SIZE
                               end (* else *) ;
                             RCNT := IMAX - IMIN + 1 ;
                             RELEMSIZE := SIZE DIV RCNT ;
                             if RCNT > LCNT then
                               ERROR ( 303 ) ;
                             if LELEMSIZE = RELEMSIZE then

                 (*********************)
                 (* A MOVE WORK S OK  *)
                 (*********************)

                               GEN1 ( 40 , - SIZE )

                 (********)
                 (*MOV   *)
                 (********)

                             else

                 (********)
                 (*PAK   *)
                 (********)

                               GEN3 ( 76 , RCNT , LELEMSIZE , RELEMSIZE
                                      ) ;
                           end (* else *) ;
                       end (* then *)
                     else
                       ERROR ( 116 )
               end (* PACK1 *) ;


            procedure UNPACK1 ;

               var LSP , LSP1 : TTP ;
                   IMIN , IMAX , LSIZE : INTEGER ;
                   LCNT , RCNT , LELEMSIZE , RELEMSIZE : INTEGER ;

               begin (* UNPACK1 *)
                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;
                 LSP := NIL ;
                 LSP1 := NIL ;
                 if GATTR . TYPTR <> NIL then
                   with GATTR . TYPTR -> do
                     if FORM = ARRAYS then
                       begin
                         LSP := INXTYPE ;
                         LSP1 := AELTYPE ;
                         IMIN := 1 ;
                         LSIZE := SIZE ;
                         IMAX := LSIZE ;
                         if LSP <> NIL then
                           GETBOUNDS ( LSP , IMIN , IMAX ) ;
                         LCNT := IMAX - IMIN + 1 ;
                         LELEMSIZE := LSIZE DIV LCNT ;
                         LOADADDRESS ;
                       end (* then *)
                     else
                       ERROR ( 116 ) ;
                 if SY = COMMA then
                   INSYMBOL
                 else
                   ERROR ( 20 ) ;
                 VARIABLE ( FSYS + [ COMMA , RPARENT ] ) ;
                 if GATTR . TYPTR <> NIL then
                   with GATTR , GATTR . TYPTR -> do
                     if FORM = ARRAYS then
                       begin
                         if ( COMPTYPES ( AELTYPE , LSP1 ) <> 1 ) or (
                         COMPTYPES ( INXTYPE , LSP ) <> 1 ) then
                           ERROR ( 116 )
                         else
                           begin
                             if INXTYPE <> NIL then
                               GETBOUNDS ( INXTYPE , IMIN , IMAX )
                             else
                               begin
                                 IMIN := 1 ;
                                 IMAX := SIZE
                               end (* else *) ;
                             RCNT := IMAX - IMIN + 1 ;
                             RELEMSIZE := SIZE DIV RCNT ;
                             if LCNT > RCNT then
                               ERROR ( 303 ) ;
                             LOADADDRESS ;
                           end (* else *) ;
                       end (* then *)
                     else
                       ERROR ( 116 ) ;
                 if SY = COMMA then
                   INSYMBOL
                 else
                   ERROR ( 20 ) ;
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> SCALAR then
                     ERROR ( 116 )
                   else
                     if COMPTYPES ( LSP , GATTR . TYPTR ) <> 1 then
                       ERROR ( 116 )
                     else
                       begin
                         LOAD ;
                         if DEBUG then

                 (********)
                 (*CHK   *)
                 (********)

                           GEN3 ( 45 , ORD ( 'J' ) , IMIN , IMAX ) ;
                         if IMIN > 0 then

                 (********)
                 (*DEC   *)
                 (********)

                           GEN2 ( 22 , GETTYPE ( GATTR . TYPTR ) , IMIN
                                  )
                         else
                           if IMIN < 0 then

                 (********)
                 (*INC   *)
                 (********)

                             GEN2 ( 23 , GETTYPE ( GATTR . TYPTR ) , -
                                    IMIN ) ;

                 (********)
                 (*IXA   *)
                 (********)

                         GEN1 ( 36 , RELEMSIZE ) ;
                         if LELEMSIZE = RELEMSIZE then

                 (*****************)
                 (* A MOVE IS OK  *)
                 (*****************)

                           GEN1 ( 40 , - LSIZE )

                 (********)
                 (*MOV   *)
                 (********)

                         else

                 (********)
                 (*PAK   *)
                 (********)

                           GEN3 ( 76 , LCNT , LELEMSIZE , RELEMSIZE ) ;
                       end (* else *) ;
               end (* UNPACK1 *) ;


            procedure NEW1 ;

               label 1 ;

               var LSP , LSP1 : TTP ;
                   VARTS , LMIN , LMAX : INTEGER ;
                   LSIZE , LSZ : ADDRRANGE ;
                   LVAL : XCONSTANT ;
                   LALN : ALNRNG ;

               begin (* NEW1 *)
                 VARIABLE ( FSYS + [ COMMA , RPARENT ] ) ;
                 LOADADDRESS ;
                 LSP := NIL ;
                 VARTS := 0 ;
                 LSIZE := 0 ;
                 LALN := INTSIZE ;
                 if GATTR . TYPTR <> NIL then
                   with GATTR . TYPTR -> do
                     if FORM = POINTER then
                       begin
                         if ELTYPE <> NIL then
                           begin
                             LSIZE := ELTYPE -> . SIZE ;
                             if ELTYPE -> . ALN > INTSIZE then
                               LALN := REALSIZE ;
                             if ELTYPE -> . FORM = RECORDS then
                               LSP := ELTYPE -> . RECVAR
                           end (* then *)
                       end (* then *)
                     else
                       ERROR ( 116 ) ;
                 while SY = COMMA do
                   begin
                     INSYMBOL ;
                     CONSTANT ( FSYS + [ COMMA , RPARENT ] , LSP1 ,
                                LVAL ) ;
                     VARTS := VARTS + 1 ;

                 (*****************************************)
                 (*   CHECK TO INSERT HERE:               *)
                 (*   IS CONSTANT IN TAGFIELDTYPE RANGE   *)
                 (*****************************************)

                     if LSP = NIL then
                       ERROR ( 158 )
                     else
                       if LSP -> . FORM <> TAGFLD then
                         ERROR ( 162 )
                       else
                         if LSP -> . TAGFIELDP <> NIL then
                           if XSTRING ( LSP1 ) or ( LSP1 = REALPTR )
                           then
                             ERROR ( 159 )
                           else
                             if COMPTYPES ( LSP -> . TAGFIELDP -> .
                             IDTYPE , LSP1 ) = 1 then
                               begin
                                 LSP1 := LSP -> . FSTVAR ;
                                 while LSP1 <> NIL do
                                   with LSP1 -> do
                                     if VARVAL . IVAL = LVAL . IVAL
                                     then
                                       begin
                                         LSIZE := SIZE ;
                                         LSP := SUBVAR ;
                                         goto 1
                                       end (* then *)
                                     else
                                       LSP1 := NXTVAR ;
                                 LSIZE := LSP -> . SIZE ;
                                 LSP := NIL ;
                               end (* then *)
                             else
                               ERROR ( 116 ) ;
                     1 :
                     
                   end (* while *) ;
                 ALIGN ( LSIZE , INTSIZE ) ;

                 (********)
                 (*NEW   *)
                 (********)

                 GEN2 ( 58 , LSIZE , LALN ) ;
               end (* NEW1 *) ;


            procedure MARKRELEASE ;

               begin (* MARKRELEASE *)
                 VARIABLE ( FSYS + [ RPARENT ] ) ;
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM = POINTER then
                     if LKEY = 13

                 (********)
                 (*MARK  *)
                 (********)


                     then
                       begin
                         LOADADDRESS ;

                 (********)
                 (*SAV   *)
                 (********)

                         GEN0 ( 59 )
                       end (* then *)
                     else

                 (**********************)
                 (* LKEY = 10, RELEASE *)
                 (**********************)

                       begin
                         LOAD ;

                 (********)
                 (*RST   *)
                 (********)

                         GEN0 ( 60 )
                       end (* else *)
                   else
                     ERROR ( 125 )
               end (* MARKRELEASE *) ;


            procedure ADDR1 ;

               begin (* ADDR1 *)
                 VARIABLE ( FSYS + [ RPARENT ] ) ;

                 (*******************************)
                 (* load addr of variable and   *)
                 (* set result type to void ptr *)
                 (*******************************)

                 LOADADDRESS ;
                 GATTR . TYPTR := ANYPTR ;
               end (* ADDR1 *) ;


            procedure PTRADD1 ;

               begin (* PTRADD1 *)
                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     LOAD ;
                 if SY = COMMA then
                   INSYMBOL
                 else
                   begin

                 (******************************************)
                 (* if only one parameter, then simply     *)
                 (* cast pointer to void pointer type      *)
                 (* so assignments of any pointer types    *)
                 (* are possible using ptradd              *)
                 (******************************************)

                     GATTR . TYPTR := ANYPTR ;
                     return ;
                   end (* else *) ;
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (***********************************)
                 (* if type of expr = integer then  *)
                 (* load it and generate ada instr  *)
                 (* - add integer to address        *)
                 (***********************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> INTPTR then
                     ERROR ( 191 )
                   else
                     begin
                       LOAD ;
                       GEN0 ( 77 ) ;
                     end (* else *) ;
                 GATTR . TYPTR := ANYPTR ;
               end (* PTRADD1 *) ;


            procedure PTRCAST1 ;

               begin (* PTRCAST1 *)
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     LOAD ;
                 GATTR . TYPTR := ANYPTR ;
               end (* PTRCAST1 *) ;


            procedure PTR2INT1 ;

               begin (* PTR2INT1 *)
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     LOAD ;
                 GATTR . TYPTR := INTPTR ;
               end (* PTR2INT1 *) ;


            procedure PTRDIFF1 ;

               begin (* PTRDIFF1 *)
                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     LOAD ;
                 if SY = COMMA then
                   INSYMBOL
                 else
                   begin
                     ERROR ( 192 ) ;
                     if SY = RPARENT then
                       begin
                         INSYMBOL ;
                         return
                       end (* then *)
                   end (* else *) ;
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (************************************)
                 (* if type of expr = pointer then   *)
                 (* load it and generate sba instr   *)
                 (* - subtract adresses              *)
                 (************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     begin
                       LOAD ;
                       GEN0 ( 78 )
                     end (* else *) ;
                 GATTR . TYPTR := INTPTR ;
               end (* PTRDIFF1 *) ;


            procedure SIZEOF1 ;

               var SIZE : INTEGER ;
                   LCP : IDP ;
                   XTYPE : TTP ;

               begin (* SIZEOF1 *)
                 SIZE := 0 ;
                 LCP := NIL ;
                 if SY = IDENT then
                   begin

                 (********************************)
                 (* schauen, ob typ bezeichner   *)
                 (********************************)

                     DUMMYBOOL := SEARCHID ( ID , FALSE , FALSE , [
                                  TYPES ] , LCP ) ;
                     if LCP <> NIL then
                       begin
                         XTYPE := LCP -> . IDTYPE ;
                         SIZE := XTYPE -> . SIZE ;
                         INSYMBOL ;
                       end (* then *)
                   end (* then *) ;
                 if LCP = NIL then
                   begin

                 (***********************************)
                 (* wenn kein Typ gefunden:         *)
                 (* variable suchen                 *)
                 (* if type of variable known       *)
                 (* then load size of that type     *)
                 (***********************************)

                     VARIABLE ( FSYS + [ RPARENT ] ) ;
                     if GATTR . TYPTR <> NIL then
                       begin
                         SIZE := GATTR . TYPTR -> . SIZE ;
                       end (* then *)
                   end (* then *) ;
                 GATTR . TYPTR := INTPTR ;
                 GEN2 ( 51 , 1 , SIZE ) ;
               end (* SIZEOF1 *) ;


            procedure ALLOC1 ;

               var LLC1 : ADDRRANGE ;

               begin (* ALLOC1 *)
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = integer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> INTPTR then
                     ERROR ( 191 )
                   else
                     LOAD ;
                 GEN3 ( 56 , ORD ( 'I' ) , LEVEL , LCPARM ) ;
                 LCPARM := LCPARM + INTSIZE ;
                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
                 GATTR . TYPTR := ANYPTR ;
               end (* ALLOC1 *) ;


            procedure ALLOCX1 ;

               var LLC1 : ADDRRANGE ;

               begin (* ALLOCX1 *)
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = integer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> INTPTR then
                     ERROR ( 191 )
                   else
                     LOAD ;
                 GEN3 ( 56 , ORD ( 'I' ) , LEVEL , LCPARM ) ;
                 LCPARM := LCPARM + INTSIZE ;
                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
                 GATTR . TYPTR := ANYPTR ;
               end (* ALLOCX1 *) ;


            procedure FREE1 ;

               begin (* FREE1 *)
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     LOAD ;
                 GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LCPARM ) ;
                 LCPARM := LCPARM + PTRSIZE ;
                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
               end (* FREE1 *) ;


            procedure FREEX1 ;

               begin (* FREEX1 *)
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     LOAD ;
                 GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LCPARM ) ;
                 LCPARM := LCPARM + PTRSIZE ;
                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
               end (* FREEX1 *) ;


            procedure CHKHEAP1 ;

               begin (* CHKHEAP1 *)
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = integer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> INTPTR then
                     ERROR ( 191 )
                   else
                     LOAD ;
                 GEN3 ( 56 , ORD ( 'I' ) , LEVEL , LCPARM ) ;
                 LCPARM := LCPARM + INTSIZE ;
                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
               end (* CHKHEAP1 *) ;


            procedure FILEFCB1 ;

               begin (* FILEFCB1 *)
                 if SY <> IDENT then
                   ERROR ( 193 ) ;
                 RWSETUP ( INPUTPTR , FALSE ) ;
                 RWFILE := NIL ;
                 GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LCPARM ) ;
                 LCPARM := LCPARM + PTRSIZE ;
                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
                 GATTR . TYPTR := ANYPTR ;
               end (* FILEFCB1 *) ;


            procedure CHKALLOC1 ;

               var LLC1 : ADDRRANGE ;

               begin (* CHKALLOC1 *)
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     LOAD ;
                 GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LCPARM ) ;
                 LCPARM := LCPARM + PTRSIZE ;
                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
                 GATTR . TYPTR := ANYPTR ;
               end (* CHKALLOC1 *) ;


            procedure MEMSET1 ;

               begin (* MEMSET1 *)
                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;

                 (******************************************)
                 (* 1. parameter                           *)
                 (******************************************)

                 if SY = RPARENT then
                   begin
                     ERROR ( 197 ) ;
                     INSYMBOL ;
                     return
                   end (* then *) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     begin
                       LOAD ;
                       GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LCPARM ) ;
                       LCPARM := LCPARM + PTRSIZE ;
                     end (* else *) ;
                 if SY = COMMA then
                   INSYMBOL ;

                 (******************************************)
                 (* 2. parameter                           *)
                 (******************************************)

                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;
                 if SY = RPARENT then
                   begin
                     ERROR ( 197 ) ;
                     INSYMBOL ;
                     return
                   end (* then *) ;

                 (******************************************)
                 (* if type of expr = char then load it    *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> CHARPTR then
                     ERROR ( 199 )
                   else
                     begin
                       LOAD ;
                       GEN3 ( 56 , ORD ( 'I' ) , LEVEL , LCPARM ) ;
                       LCPARM := LCPARM + INTSIZE ;
                     end (* else *) ;
                 if SY = COMMA then
                   INSYMBOL ;

                 (******************************************)
                 (* 3. parameter                           *)
                 (******************************************)

                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;
                 if SY = COMMA then
                   begin
                     ERROR ( 198 ) ;
                     INSYMBOL ;
                     return
                   end (* then *) ;

                 (******************************************)
                 (* if type of expr = integer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> INTPTR then
                     ERROR ( 191 )
                   else
                     begin
                       LOAD ;
                       GEN3 ( 56 , ORD ( 'I' ) , LEVEL , LCPARM ) ;
                       LCPARM := LCPARM + INTSIZE ;
                     end (* else *) ;

                 (******************************************)
                 (* call procedure                         *)
                 (******************************************)

                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
               end (* MEMSET1 *) ;


            procedure MEMCPY1 ;

               begin (* MEMCPY1 *)
                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;

                 (******************************************)
                 (* 1. parameter                           *)
                 (******************************************)

                 if SY = RPARENT then
                   begin
                     ERROR ( 197 ) ;
                     INSYMBOL ;
                     return
                   end (* then *) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     begin
                       LOAD ;
                       GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LCPARM ) ;
                       LCPARM := LCPARM + PTRSIZE ;
                     end (* else *) ;
                 if SY = COMMA then
                   INSYMBOL ;

                 (******************************************)
                 (* 2. parameter                           *)
                 (******************************************)

                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;
                 if SY = RPARENT then
                   begin
                     ERROR ( 197 ) ;
                     INSYMBOL ;
                     return
                   end (* then *) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> POINTER then
                     ERROR ( 190 )
                   else
                     begin
                       LOAD ;
                       GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LCPARM ) ;
                       LCPARM := LCPARM + PTRSIZE ;
                     end (* else *) ;
                 if SY = COMMA then
                   INSYMBOL ;

                 (******************************************)
                 (* 3. parameter                           *)
                 (******************************************)

                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;
                 if SY = COMMA then
                   begin
                     ERROR ( 198 ) ;
                     INSYMBOL ;
                     return
                   end (* then *) ;

                 (******************************************)
                 (* if type of expr = integer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> INTPTR then
                     ERROR ( 191 )
                   else
                     begin
                       LOAD ;
                       GEN3 ( 56 , ORD ( 'I' ) , LEVEL , LCPARM ) ;
                       LCPARM := LCPARM + INTSIZE ;
                     end (* else *) ;

                 (******************************************)
                 (* call procedure                         *)
                 (******************************************)

                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
               end (* MEMCPY1 *) ;


            procedure ROUNDX1 ;

               var LCPARM1 : INTEGER ;
                   LCPARM2 : INTEGER ;

               begin (* ROUNDX1 *)
                 LCPARM1 := LCPARM + INTSIZE ;
                 LCPARM2 := LCPARM ;
                 LCPARM := LCPARM + INTSIZE + REALSIZE ;
                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;

                 (******************************************)
                 (* 1. parameter                           *)
                 (******************************************)

                 if SY = RPARENT then
                   begin
                     ERROR ( 197 ) ;
                     INSYMBOL ;
                     return
                   end (* then *) ;

                 (******************************************)
                 (* if type of expr = pointer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> REALPTR then
                     ERROR ( 189 )
                   else
                     begin
                       LOAD ;
                       GEN3 ( 56 , ORD ( 'R' ) , LEVEL , LCPARM1 ) ;
                     end (* else *) ;
                 if SY = COMMA then
                   INSYMBOL ;

                 (******************************************)
                 (* 2. parameter                           *)
                 (******************************************)

                 EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;
                 if SY = COMMA then
                   begin
                     ERROR ( 198 ) ;
                     INSYMBOL ;
                     return
                   end (* then *) ;

                 (******************************************)
                 (* if type of expr = integer then load it *)
                 (******************************************)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> INTPTR then
                     ERROR ( 191 )
                   else
                     begin
                       LOAD ;
                       GEN3 ( 56 , ORD ( 'I' ) , LEVEL , LCPARM2 ) ;
                     end (* else *) ;

                 (******************************************)
                 (* call procedure                         *)
                 (******************************************)

                 CALLLIBRARYFUNC ( FCP , LCCALLER ) ;
                 GATTR . TYPTR := REALPTR ;
               end (* ROUNDX1 *) ;


            procedure TRAPEXIT ;

            (**********************************************************)
            (*   THIS PROCEDURE IS TO SIMPLIFY COMMUNICATION          *)
            (*   WITH THE OUTSIDE WORLD AND PROVIDE BREAK POINTS      *)
            (*   IN THE PASCAL PROGRAM.                               *)
            (*   'TRAP(I, R)'  RETURNS THE INTEGER CONSTANT I         *)
            (*   AS WELL AS A POINTER TO THE SECOND PARAMETER 'R'     *)
            (*   (I.E. ADDRESS OF R) TO THE OPERATING SYSTEM.         *)
            (*   THE FIRST PARAMETER IS INTENDED TO BE USED AS A      *)
            (*   'FUNCTION NUMBER' AND THE SECOND ONE AS THE 'VAR'    *)
            (*   TYPE ARGUMENT WHICH MAY BE INSPECTED AND MODIFIED,   *)
            (*   TO THAT FUNCTION                                     *)
            (**********************************************************)


               var LLC : ADDRRANGE ;

               begin (* TRAPEXIT *)
                 LLC := LCOUNTER ;

                 (********************************)
                 (* IN CASE OF SET TYPE ARGUMENT *)
                 (********************************)

                 if GATTR . TYPTR <> INTPTR then
                   ERROR ( 116 ) ;
                 if LKEY = 14 then

                 (********)
                 (*TRAP  *)
                 (********)

                   begin
                     if SY <> COMMA then
                       ERROR ( 6 )
                     else
                       begin
                         INSYMBOL ;
                         EXPRESSION ( FSYS + [ RPARENT ] ) ;
                         with GATTR do
                           if TYPTR <> NIL then
                             begin
                               if KIND <> VARBL then
                                 if TYPTR -> . FORM < POWER then
                                   begin
                                     LOAD ;
                                     KIND := VARBL ;
                                     ACCESS := DRCT ;
                                     VLEVEL := LEVEL ;
                                     ALIGN ( LCOUNTER , MXDATASZE ) ;
                                     DPLMT := LCOUNTER ;
                                     BTYPE := TYPTR ;
                                     STORE ( GATTR ) ;
                                   end (* then *) ;
                               LOADADDRESS ;
                             end (* then *) ;
                       end (* else *) ;
                   end (* then *) ;

                 (*****************)
                 (* CSP - TRP/XIT *)
                 (*****************)

                 GEN1 ( 30 , LKEY + 14 ) ;
                 LCOUNTER := LLC ;
               end (* TRAPEXIT *) ;


            procedure SQRABS ;

               var OP : OPRANGE ;

               begin (* SQRABS *)
                 OP := 0 ;

                 (********)
                 (*ABI   *)
                 (********)

                 if LKEY = 17 then
                   OP := 24 ;

                 (********)
                 (*SQI   *)
                 (********)

                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR = INTPTR then

                 (********)
                 (*ABI   *)
                 (*SQI   *)
                 (********)

                     GEN0 ( OP )
                   else
                     if GATTR . TYPTR = REALPTR then

                 (********)
                 (*ABR   *)
                 (*ABR   *)
                 (********)

                       GEN0 ( OP + 1 )
                     else
                       begin
                         ERROR ( 125 ) ;
                         GATTR . TYPTR := INTPTR
                       end (* else *)
               end (* SQRABS *) ;


            procedure TRUNCROUND ;

               begin (* TRUNCROUND *)
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> REALPTR then
                     ERROR ( 125 ) ;

                 (********)
                 (*TRC   *)
                 (*RND   *)
                 (********)

                 if LKEY = 18 then
                   GEN1 ( 30 , ORD ( PTRC ) )
                 else
                   GEN1 ( 30 , ORD ( PRND ) ) ;
                 GATTR . TYPTR := INTPTR
               end (* TRUNCROUND *) ;


            procedure FLOOR1 ;

               begin (* FLOOR1 *)
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> REALPTR then
                     ERROR ( 125 ) ;

                 (********)
                 (*FLR   *)
                 (********)

                 GEN1 ( 30 , ORD ( PFLR ) ) ;
                 GATTR . TYPTR := REALPTR ;
               end (* FLOOR1 *) ;


            procedure EXPO1 ;

               begin (* EXPO1 *)
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR = INTPTR then

                 (********)
                 (*FLT   *)
                 (********)

                     GEN0 ( 10 )
                   else
                     if GATTR . TYPTR <> REALPTR then
                       ERROR ( 125 ) ;

                 (********)
                 (*XPO   *)
                 (********)

                 GEN0 ( 66 ) ;
                 GATTR . TYPTR := INTPTR ;
               end (* EXPO1 *) ;


            procedure CARD1 ;

               var LLC , LEN : ADDRRANGE ;

               begin (* CARD1 *)
                 LLC := LCOUNTER ;
                 EXPRESSION ( FSYS + [ RPARENT ] ) ;
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM = POWER then
                     begin
                       FORCETEMPSET ( 1 , - 1 ) ;

                 (********)
                 (*CRD   *)
                 (********)

                       GEN0 ( 65 ) ;
                     end (* then *)
                   else
                     ERROR ( 125 ) ;
                 LCOUNTER := LLC ;
                 GATTR . TYPTR := INTPTR ;
               end (* CARD1 *) ;


            procedure ODD1 ;

               begin (* ODD1 *)
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> INTPTR then
                     ERROR ( 125 ) ;

                 (********)
                 (*ODD   *)
                 (********)

                 GEN0 ( 20 ) ;
                 GATTR . TYPTR := BOOLPTR
               end (* ODD1 *) ;


            procedure ORD1 ;

               var X : FORMTEST ;

               begin (* ORD1 *)
                 if GATTR . TYPTR <> NIL then
                   begin
                     if GATTR . TYPTR -> . FORM >= POWER then
                       ERROR ( 125 ) ;
                   end (* then *) ;

                 (********)
                 (*ORD   *)
                 (********)

                 GEN0 ( 61 ) ;
                 GATTR . TYPTR := INTPTR
               end (* ORD1 *) ;


            procedure CHR1 ;

               begin (* CHR1 *)
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR <> INTPTR then
                     ERROR ( 125 ) ;

                 (********)
                 (*CHR   *)
                 (********)

                 GEN0 ( 62 ) ;
                 GATTR . TYPTR := CHARPTR
               end (* CHR1 *) ;


            procedure PREDSUCCTIM ;

               begin (* PREDSUCCTIM *)
                 if GATTR . TYPTR <> NIL then
                   if ( LKEY = 24 ) or ( LKEY = 30 ) then
                     begin
                       if GATTR . TYPTR <> INTPTR then
                         ERROR ( 116 ) ;
                       if LKEY = 24 then
                         GEN1 ( 30 , ORD ( PCLK ) )
                       else
                         GEN1 ( 30 , ORD ( PTRA ) )
                     end (* then *)
                   else
                     if ( GATTR . TYPTR = REALPTR ) or ( GATTR . TYPTR
                     -> . FORM <> SCALAR ) then
                       ERROR ( 125 )
                     else

                 (*********)
                 (*DEC,INC*)
                 (*********)

                       GEN2 ( LKEY , GETTYPE ( GATTR . TYPTR ) , 1 ) ;

                 (*********************************************)
                 (*   LKEY HAPPENS TO BE THE OPCODE AS WELL   *)
                 (*********************************************)

               end (* PREDSUCCTIM *) ;


            procedure EOFEOLN ;

               begin (* EOFEOLN *)
                 RWSETUP ( INPUTPTR , TRUE ) ;
                 if GATTR . TYPTR <> NIL then
                   if GATTR . TYPTR -> . FORM <> FILES then
                     ERROR ( 125 ) ;
                 if LKEY >= 28 then
                   begin
                     EXTUSED := TRUE ;

                 (*****************)
                 (* CSP - EOL/EOT *)
                 (*****************)

                     GEN1 ( 30 , LKEY - 11 ) ;
                   end (* then *)
                 else

                 (*****************)
                 (* CSP - EOF/ELN *)
                 (*****************)

                   GEN1 ( 30 , LKEY ) ;
                 GEN1 ( 30 , ORD ( PEIO ) ) ;
                 GATTR . TYPTR := BOOLPTR
               end (* EOFEOLN *) ;


            procedure CALLNONSTANDARD ;

               label 10 ;

               var NXT , LCP , LCP2 : IDP ;
                   LSP : TTP ;
                   LB : BOOLEAN ;
                   LOCPAR , LLC , LSIZE , LLC1 , LLC2 , LLC3 , LLC_PARM
                   , LLC5 : ADDRRANGE ;
                   I : INTEGER ;
                   PROCNAME : ALPHA ;


               function COMPTLIST ( CP1 , CP2 : IDP ) : BOOLEAN ;

               (*************************************)
               (* MATCH PARAMETER LISTS CP1 AND CP2 *)
               (*************************************)


                  var X : BOOLEAN ;

                  begin (* COMPTLIST *)
                    while ( CP1 <> NIL ) and ( CP2 <> NIL ) do
                      begin

                    (***********************)
                    (* I.E. PROC PARAMETER *)
                    (***********************)

                        if CP1 -> . KLASS in [ PROC , FUNC ] then
                          if ( CP1 -> . KLASS = CP2 -> . KLASS ) and (
                          CP1 -> . IDTYPE = CP2 -> . IDTYPE ) and ( CP1
                          -> . PFDECKIND = CP2 -> . PFDECKIND ) then
                            X := COMPTLIST ( CP1 -> . PRMPTR , CP2 -> .
                                 PRMPTR ) and ( CP1 -> . VKIND = CP2 ->
                                 . VKIND )
                          else
                            X := FALSE
                        else
                          X := ( COMPTYPES ( CP1 -> . IDTYPE , CP2 -> .
                               IDTYPE ) = 1 ) ;
                        if X then
                          begin
                            CP1 := CP1 -> . NEXT ;
                            CP2 := CP2 -> . NEXT
                          end (* then *)
                        else
                          CP1 := NIL ;
                      end (* while *) ;
                    COMPTLIST := CP1 <> CP2 ;
                  end (* COMPTLIST *) ;


               procedure WORK_PARAMETER ;

                  var CT_RESULT : INTEGER ;
                      PARMTYPE : TTP ;
                      PARMKIND : IDKIND ;
                      PARMLEN : INTEGER ;
                      PARMALN : INTEGER ;
                      LSETOFFS : INTEGER ;
                      DUMMY_CHARTYPE : BOOLEAN ;

                      (************************************)
                      (* deutlich vereinfacht bzw. klarer *)
                      (* durch die return-Anweisungen     *)
                      (* am anfang; spart einrueckungen   *)
                      (************************************)


                  begin (* WORK_PARAMETER *)

                    /********************************************/
                    /* expression                               */
                    /********************************************/

                    EXPRESSION ( FSYS + [ COMMA , RPARENT ] ) ;
                    if GATTR . TYPTR = NIL then
                      return ;

                    /********************************************/
                    /* neu 01.2017:                             */
                    /* wenn nxt = nil ist, d.h. es gibt keine   */
                    /* beschreibung der parameter anhand der    */
                    /* prozedur-deklaration, dann werden die    */
                    /* hier bereits bekannten attribute des     */
                    /* ausdrucks verwendet.                     */
                    /********************************************/

                    PARMLEN := 0 ;
                    PARMALN := 0 ;
                    if NXT <> NIL then
                      begin
                        PARMTYPE := NXT -> . IDTYPE ;
                        PARMKIND := NXT -> . VKIND ;
                      end (* then *)
                    else
                      begin
                        PARMTYPE := GATTR . TYPTR ;
                        if GATTR . KIND = VARBL then
                          PARMKIND := FORMAL
                        else
                          PARMKIND := ACTUAL ;
                      end (* else *) ;
                    if PARMTYPE = NIL then
                      return ;

                    /********************************************/
                    /* ab jetzt: parmtype ist vorhanden         */
                    /********************************************/

                    if PARMKIND = FORMAL then
                      begin
                        PARMLEN := PTRSIZE ;
                        PARMALN := PTRSIZE ;
                      end (* then *)
                    else
                      if PARMTYPE <> NIL then
                        begin
                          PARMLEN := PARMTYPE -> . SIZE ;
                          PARMALN := PARMTYPE -> . ALN
                        end (* then *) ;

                    (*******************************************)
                    (* ausrichten parm-offset entsprechend typ *)
                    (*******************************************)

                    ALIGN ( LLC_PARM , PARMALN ) ;
                    LSIZE := 0 ;

                    (**********************)
                    (* typen vergleichen  *)
                    (**********************)

                    CT_RESULT := COMPTYPES ( PARMTYPE , GATTR . TYPTR )
                                 ;
                    if PARMKIND = ACTUAL then
                      begin

                    (*************************************************)
                    (* maybe source string has shorter size          *)
                    (* if so, adjust size                            *)
                    (*************************************************)

                        if CT_RESULT in [ 2 , 3 ] then
                          begin
                            if ( GATTR . KIND = CST ) and ( XSTRING (
                            GATTR . TYPTR ) or ( GATTR . TYPTR =
                            CHARPTR ) ) then
                              begin
                                MOD_STRCONST ( CT_RESULT , GATTR . CVAL
                                               , GATTR . TYPTR ,
                                               PARMTYPE -> . SIZE ) ;
                              end (* then *)
                            else
                              begin
                                CT_RESULT := 0
                              end (* else *)
                          end (* then *) ;

                    (*************************************************)
                    (* end insertion 09.2016                         *)
                    (*************************************************)

                        if PARMTYPE -> . FORM < POWER then
                          begin
                            LOAD ;
                            if DEBUG then
                              begin
                                ASSIGN := TRUE ;
                                CHKBNDS ( PARMTYPE ) ;
                                ASSIGN := FALSE ;
                              end (* then *) ;
                            if COMPTYPES ( REALPTR , PARMTYPE ) = 1
                            then
                              if ( GATTR . TYPTR = INTPTR ) then
                                begin

                    (********)
                    (*FLT   *)
                    (********)

                                  GEN0 ( 10 ) ;
                                  GATTR . TYPTR := REALPTR ;
                                  GATTR . BTYPE := REALPTR ;
                                  CT_RESULT := 1 ;
                                end (* then *) ;
                            LOCPAR := LOCPAR + 1 ;

                    (*********************)
                    (* fuer fortran      *)
                    (*********************)

                            if FCP -> . FRTRN then
                              begin
                                ALIGN ( LLC2 , PARMTYPE -> . ALN ) ;
                                with GATTR do
                                  begin
                                    VLEVEL := LEVEL ;
                                    DPLMT := LLC2 ;
                                    BTYPE := PARMTYPE ;
                                    KIND := VARBL ;
                                    ACCESS := DRCT
                                  end (* with *) ;
                                STORE ( GATTR ) ;
                                LOADADDRESS ;

                    (********)
                    (*STR   *)
                    (********)

                                GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LLC3
                                       ) ;
                                LLC3 := LLC3 + PTRSIZE ;
                                LLC2 := LLC2 + PARMTYPE -> . SIZE ;
                              end (* then *)

                    (****************************************)
                    (* fuer normalfall / nicht fortran      *)
                    (****************************************)

                            else
                              begin
                                GEN3 ( 56 , GETTYPE ( PARMTYPE ) ,
                                       LEVEL , LLC_PARM ) ;
                                LSIZE := PARMTYPE -> . SIZE ;
                              end (* else *)
                          end (* then *)
                        else

                    (**********************************)
                    (*  PARMTYPE -> . FORM >= POWER   *)
                    (**********************************)

                          begin
                            LOCPAR := LOCPAR + 1 ;

                    (*********************)
                    (*  fuer fortran     *)
                    (*********************)

                            if FCP -> . FRTRN then
                              begin
                                if ( PARMTYPE -> . FORM = POWER ) and (
                                GATTR . ACCESS = STKEXPR ) then
                                  begin
                                    ALIGN ( LLC2 , PARMTYPE -> . ALN )
                                            ;
                                    FORCETEMPSET ( 2 , - 1 ) ;
                                    LSIZE := OPNDSETSIZE ( GATTR ,
                                             LSETOFFS , DUMMY_CHARTYPE
                                             ) ;

                    (********)
                    (*LDA   *)
                    (********)

                                    GEN2 ( 50 , LEVEL , LLC2 ) ;
                                    if ( PARMTYPE -> . SIZE = LSIZE )
                                    and ( PARMTYPE -> . SETOFFS =
                                    LSETOFFS ) then
                                      begin

                    (********)
                    (*SMV   *)
                    (********)

                                        GEN_SET ( 69 , - LSIZE ,
                                                  LSETOFFS )
                                      end (* then *)
                                    else
                                      begin
                                        ERROR ( 396 )
                                      end (* else *) ;

                    (********)
                    (*LDA   *)
                    (********)

                                    GEN2 ( 50 , LEVEL , LLC2 ) ;
                                    LLC2 := LLC2 + PARMTYPE -> . SIZE ;
                                  end (* then *)
                                else
                                  LOADADDRESS ;

                    (********)
                    (*STR   *)
                    (********)

                                GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LLC3
                                       ) ;
                                LLC3 := LLC3 + PTRSIZE ;
                                LSIZE := 0 ;
                              end (* then *)

                    (****************************************)
                    (* fuer normalfall / nicht fortran      *)
                    (****************************************)

                            else
                              if PARMTYPE -> . FORM = POWER then
                                begin
                                  LSIZE := OPNDSETSIZE ( GATTR ,
                                           LSETOFFS , DUMMY_CHARTYPE )
                                           ;
                                  LOADADDRESS ;

                    (********)
                    (*LDA   *)
                    (********)

                                  GEN2 ( 50 , LEVEL , LLC_PARM ) ;
                                  if ( PARMTYPE -> . SIZE = LSIZE ) and
                                  ( PARMTYPE -> . SETOFFS = LSETOFFS )
                                  then
                                    begin

                    (********)
                    (*SMV   *)
                    (********)

                                      GEN_SET ( 69 , - LSIZE , LSETOFFS
                                                )
                                    end (* then *)
                                  else
                                    begin
                                      ERROR ( 396 )
                                    end (* else *)
                                end (* then *)
                              else
                                begin
                                  LOADADDRESS ;

                    (********)
                    (*LDA   *)
                    (********)

                                  GEN2 ( 50 , LEVEL , LLC_PARM ) ;

                    (********)
                    (*MOV   *)
                    (********)

                                  GEN1 ( 40 , - PARMTYPE -> . SIZE ) ;
                                  LSIZE := PARMTYPE -> . SIZE ;
                                end (* else *)
                          end (* else *) ;
                        if not ( CT_RESULT in [ 1 , 2 , 3 ] ) then
                          ERROR ( 142 ) ;
                        return ;
                      end (* then *) ;

                    (*********************************)
                    (* VKIND = FORMAL I.E.  VAR PARM *)
                    (*********************************)

                    if GATTR . KIND = VARBL then
                      begin
                        LOADADDRESS ;
                        if not FCP -> . FRTRN then
                          begin
                            GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LLC_PARM
                                   ) ;
                            LSIZE := PTRSIZE ;
                          end (* then *)
                        else
                          begin
                            GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LLC3 ) ;
                            LLC3 := LLC3 + PTRSIZE ;
                          end (* else *) ;
                        if GATTR . ACCESS = STKEXPR then
                          ERROR ( 154 ) ;
                        LOCPAR := LOCPAR + 1 ;

                    (**********************************)
                    (* kein fehler 182 bei anyfile    *)
                    (* alle files passen              *)
                    (**********************************)

                        if GATTR . BTYPE -> . SIZE <> PARMTYPE -> .
                        SIZE then
                          if PARMTYPE <> ANYFILEPTR then
                            ERROR ( 182 ) ;
                      end (* then *)
                    else
                      ERROR ( 154 ) ;

                    (**********************************)
                    (* hier muss der Typ genau passen *)
                    (**********************************)

                    if CT_RESULT <> 1 then
                      ERROR ( 142 ) ;
                  end (* WORK_PARAMETER *) ;


               begin (* CALLNONSTANDARD *)
                 LOCPAR := 0 ;
                 LLC1 := LCOUNTER ;
                 ALIGN ( LLC1 , MXDATASZE ) ;
                 LLC_PARM := LLC1 + LCAFTMST + FPSAVEAREA ;
                 with FCP -> do
                   begin
                     NXT := PRMPTR ;
                     if PFLEV > LCAFTMST then

                 (*******************)
                 (* PROC. PARAMETER *)
                 (*******************)

                       begin
                         LLC5 := LLC1 ;
                         LLC1 := LLC1 + DISPAREA
                       end (* then *)
                     else
                       LLC5 := 0 ;

                 (********)
                 (*MST   *)
                 (********)

                     GEN2 ( 41 , PFLEV , LLC5 ) ;
                     if PFLEV = LEVEL then
                       LOCAL_CALL := TRUE ;
                   end (* with *) ;

                 (***************************************)
                 (* wenn klammer: es geht los           *)
                 (* mit den parametern                  *)
                 (***************************************)

                 if SY = LPARENT then
                   begin
                     LSIZE := 0 ;
                     LLC := LLC1 ;

                 (***************************************)
                 (* bei fortran:                        *)
                 (* RESERVE STORAGE FOR COPIES OF PARMS *)
                 (* LLC2 und LLC3 nur fuer fortran      *)
                 (***************************************)

                     LLC2 := LLC1 ;
                     if FCP -> . FRTRN then
                       begin
                         LCP := NXT ;
                         while LCP <> NIL do
                           begin
                             LSP := LCP -> . IDTYPE ;
                             if LSP <> NIL then
                               if LSP -> . FORM <= POWER then
                                 begin
                                   ALIGN ( LLC1 , LSP -> . ALN ) ;
                                   LLC1 := LLC1 + LSP -> . SIZE
                                 end (* then *) ;
                             LCP := LCP -> . NEXT
                           end (* while *) ;
                         ALIGN ( LLC1 , MXDATASZE ) ;
                       end (* then *) ;
                     LLC3 := LLC1 ;

                 (***************************************)
                 (* paremeter abarbeiten                *)
                 (***************************************)

                     repeat
                       LB := FALSE ;

                 (*****************************************)
                 (*DECIDE WHETHER PROC/FUNC MUST BE PASSED*)
                 (*****************************************)

                       if NXT = NIL then
                         begin
                           if not FCP -> . DECLMISSING then
                             ERROR ( 126 )
                         end (* then *)
                       else
                         LB := NXT -> . KLASS in [ PROC , FUNC ] ;

                 (*********************************************)
                 (*   FOR FORMAL PROC/FUNC LB IS FALSE AND    *)
                 (*   EXPRESSION WILL BE CALLED, WHICH WILL   *)
                 (*   ALWAYS INTERPRET A PROC/FUNC ID AT      *)
                 (*   ITS BEGINNING AS A CALL RATHER THAN     *)
                 (*   A PARAMETER PASSING. IN THIS            *)
                 (*   IMPLEMENTATION, PARAMETER PROCEDURES    *)
                 (*   /FUNCTIONS ARE THEREFORE NOT ALLOWED    *)
                 (*   TO HAVE PROCEDURE/FUNCTION PARAMETERS   *)
                 (*********************************************)

                       INSYMBOL ;
                       if LB then

                 (****************************)
                 (*PASS FUNCTION OR PROCEDURE*)
                 (****************************)

                         begin
                           if SY <> IDENT then
                             begin
                               ERROR ( 2 ) ;
                               SKIP ( FSYS + [ COMMA , RPARENT ] )
                             end (* then *)
                           else
                             begin
                               DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE
                                            , [ NXT -> . KLASS ] , LCP
                                            ) ;
                               if not COMPTLIST ( LCP , NXT ) then
                                 ERROR ( 128 )
                               else
                                 begin
                                   LOCAL_CALL := TRUE ;

                 (************************)
                 (* => UPDATES DISP REGS *)
                 (************************)

                                   LLC_PARM := LLC1 + NXT -> . PFLEV
                                               DIV 10 ;
                                   LCOUNTER := LLC_PARM ;

                 (**********************************************)
                 (* PFLEV = ADDR OF PROC IN NEW ACTIV RECORD   *)
                 (**********************************************)

                                   LSIZE := DISPAREA ;
                                   if LCP -> . PFKIND = ACTUAL then
                                     with LCP -> do
                                       begin
                                         if FRTRN then
                                           begin

                 (********************************)
                 (* REMEMBER THIS PROC FOR LATER *)
                 (********************************)

                                             LCP2 := FRTPARHD ;
                                             while LCP2 <> NIL do
                                               if LCP2 -> . EXTNAME =
                                               EXTNAME then
                                                 goto 10

                 (********************)
                 (* ALREADY ON LIST  *)
                 (********************)

                                               else
                                                 LCP2 := LCP2 -> .
                                                   NXTFWRD ;
                                             NEW ( LCP2 , PROC ,
                                                   DECLARED ) ;
                                             LCP2 -> := LCP -> ;
                                             with LCP2 -> do
                                               begin
                                                 NAME := '            '
                                                   ;
                                                 UNPACK ( EXTNAME ,
                                                   NAME , 1 ) ;
                                                 PROCLAB := PROCLAB + 1
                                                   ;
                                                 PFNAME := PROCLAB ;
                                                 NXTFWRD := FRTPARHD ;
                                                 FRTPARHD := LCP2 ;
                                               end (* with *) ;
                                             10 :
                                             LCP := LCP2 ;
                                           end (* then *) ;

                 (*****************)
                 (* PASSING PROC  *)
                 (*****************)

                                         UNPACK ( EXTNAME , ID , 1 ) ;

                 (********)
                 (*LCA   *)
                 (********)

                                         GEN1 ( 37 , ORD ( 'P' ) ) ;

                 (********)
                 (*STR   *)
                 (********)

                                         GEN3 ( 56 , ORD ( 'A' ) ,
                                                LEVEL , LLC_PARM ) ;

                 (********)
                 (*LDA   *)
                 (********)

                                         GEN2 ( 50 , LEVEL , LLC_PARM +
                                                PTRSIZE ) ;

                 (********)
                 (*LDA   *)
                 (********)

                                         GEN2 ( 50 , 1 , DISPADR +
                                                PTRSIZE ) ;

                 (********)
                 (*MOV   *)
                 (********)

                                         GEN1 ( 40 , DISPAREA - PTRSIZE
                                                ) ;
                                       end (* with *)
                                   else

                 (***************************************)
                 (* PROC PARM IS ITSELF A PASSED PROC   *)
                 (***************************************)

                                     begin

                 (********)
                 (*LDA   *)
                 (********)

                                       GEN2 ( 50 , LEVEL , LLC_PARM ) ;

                 (*******************************************)
                 (* COPY ENTIRE PROC RECORD INTO PARM LIST  *)
                 (*******************************************)

                                       GEN2 ( 50 , LEVEL , LCP -> .
                                              PFLEV DIV 10 ) ;

                 (********)
                 (*MOV   *)
                 (********)

                                       GEN1 ( 40 , DISPAREA ) ;
                                     end (* else *) ;
                                   LLC_PARM := LLC_PARM + LSIZE ;
                                 end (* else *) ;
                               INSYMBOL ;
                               if not ( SY in FSYS + [ COMMA , RPARENT
                               ] ) then
                                 begin
                                   ERROR ( 6 ) ;
                                   SKIP ( FSYS + [ COMMA , RPARENT ] )
                                 end (* then *)
                             end (* else *)
                         end (* then *)
                       else
                         begin

                 (*******************************************)
                 (* neue funktion work_parameter            *)
                 (* setzt u.a. LLC_PARM und LSIZE ...       *)
                 (* hier muesste eigentlich LLC_PARM mit    *)
                 (* dem Wert aus NXT -> uebereinstimmen,    *)
                 (* ist aber nicht immer so ...             *)
                 (*******************************************)

                           if NXT <> NIL then
                             LLC_PARM := LLC1 + NXT -> . VADDR ;
                           LCOUNTER := LLC_PARM ;
                           WORK_PARAMETER ;
                           LLC_PARM := LLC_PARM + LSIZE ;

                 (*******************************************)
                 (* arbeit ausgelagert wg. programm stuktur *)
                 (*******************************************)

                         end (* else *) ;
                       if ( NXT <> NIL ) then
                         NXT := NXT -> . NEXT
                     until SY <> COMMA ;
                     LCOUNTER := LLC_PARM ;
                     if LCOUNTER > LCMAX then
                       LCMAX := LCOUNTER ;
                     LCOUNTER := LLC ;
                     if SY = RPARENT then
                       INSYMBOL
                     else
                       ERROR ( 4 )
                   end (* then *) ;
                 LOCPAR := LOCPAR * 2 ;
                 if NXT <> NIL then
                   if not FCP -> . DECLMISSING then
                     ERROR ( 126 ) ;
                 with FCP -> do
                   begin
                     if SAVEFPRS then
                       LOCPAR := LOCPAR + 1 ;

                 (********************)
                 (*ENCODE SAVEFPR FLG*)
                 (********************)

                     if PRCODE then
                       begin
                         PUTIC ;

                 (********)
                 (*CUP   *)
                 (********)

                         WRITELN ( PRR , MN [ 46 ] , CHR ( PROCTYPE (
                                   FCP ) ) : 2 , ',' , LOCPAR : 1 , ','
                                   , EXTNAME , ',' , LLC1 : 1 ) ;
                       end (* then *) ;
                   end (* with *) ;
                 with GATTR do
                   begin
                     TYPTR := FCP -> . IDTYPE ;
                     BTYPE := TYPTR ;
                     if TYPTR <> NIL then
                       if TYPTR -> . FORM = SUBRANGE then
                         TYPTR := TYPTR -> . RANGETYPE
                   end (* with *) ;
               end (* CALLNONSTANDARD *) ;


            begin (* CALL *)
              if FCP -> . PFDECKIND = STANDARD then
                begin

              (************************************************)
              (*  if library routine, that is:                *)
              (*  implemented using external pascal module    *)
              (*  insert funccode as first parameter          *)
              (*  for external procedure                      *)
              (*  opp / 06.2016                               *)
              (************************************************)

                  if FCP -> . LIBNAME [ 1 ] <> ' ' then
                    begin
                      PREPLIBRARYFUNC ( LCCALLER , LCPARM ) ;
                      GEN2 ( 51 , 1 , FCP -> . FUNCCODE ) ;
                      GEN3 ( 56 , ORD ( 'I' ) , LEVEL , LCPARM ) ;
                      LCPARM := LCPARM + INTSIZE ;
                    end (* then *) ;

              (************************************************)
              (*  opp / 06.2016 - end insertion               *)
              (************************************************)

                  LKEY := FCP -> . KEY ;
                  if SY = LPARENT then
                    begin
                      INSYMBOL ;
                      MATCHPAR := TRUE ;

              (*****************************************************)
              (*  diese Prozeduren kommen auch ohne Parameter aus  *)
              (*****************************************************)

                      if SY = RPARENT then
                        if not ( LKEY in [ 0 , 1 , 2 , 3 , 4 , 11 , 12
                        , 25 , 26 , 28 , 29 ] ) then
                          ERROR ( 7 ) ;
                    end (* then *)
                  else
                    begin

              (*****************************************************)
              (*  diese Prozeduren kommen auch ohne Parameter aus  *)
              (*****************************************************)

                      if not ( LKEY in [ 0 , 1 , 2 , 3 , 4 , 11 , 12 ,
                      25 , 26 , 28 , 29 ] ) then
                        ERROR ( 7 ) ;
                      MATCHPAR := FALSE ;
                    end (* else *) ;
                  if LKEY in [ 14 .. 24 , 30 , 33 , 39 , 47 ] then

              (*********************************)
              (*TRAP,EXIT,ABS...,TRACE,ODD,EXPO*)
              (*********************************)

                    begin

              (********)
              (*TRAP  *)
              (********)

                      if LKEY = 14 then
                        EXPRESSION ( FSYS + [ COMMA ] )
                      else
                        EXPRESSION ( FSYS + [ RPARENT ] ) ;
                      LOAD ;
                    end (* then *) ;
                  case LKEY of
                    0 , 1 , 2 , 3 , 4 :
                      GETPUTRESETREWRITE ;
                    5 , 11 :
                      READ1 ;
                    6 , 12 :
                      WRITE1 ;
                    7 : PACK1 ;
                    8 : UNPACK1 ;
                    9 : NEW1 ;
                    10 , 13 :
                      MARKRELEASE ;
                    14 , 15 :
                      TRAPEXIT ;
                    16 , 17 :
                      SQRABS ;
                    18 , 19 :
                      TRUNCROUND ;
                    20 : ORD1 ;
                    21 : CHR1 ;
                    22 , 23 , 24 , 30 :
                      PREDSUCCTIM ;
                    25 , 26 , 28 , 29 :
                      EOFEOLN ;
                    33 : ODD1 ;
                    35 : MESSAGE1 ;
                    36 , 37 :
                      SKIPLIM ;
                    38 : CARD1 ;
                    39 : EXPO1 ;
                    40 : ADDR1 ;
                    41 : PTRADD1 ;
                    42 : PTRDIFF1 ;
                    43 : SIZEOF1 ;
                    44 : PTR2INT1 ;
                    45 : PTRCAST1 ;
                    46 : GETPUTRESETREWRITE ;
                    47 : FLOOR1 ;
                    61 : ALLOC1 ;
                    62 : ALLOCX1 ;
                    63 : FREE1 ;
                    64 : FREEX1 ;
                    65 : CHKHEAP1 ;
                    66 : CHKALLOC1 ;
                    70 : FILEFCB1 ;
                    75 : MEMSET1 ;
                    76 : MEMCPY1 ;
                    77 : ROUNDX1 ;
                  end (* case *) ;
                  if LKEY in [ 16 .. 26 , 28 , 29 , 33 , 38 , 39 , 40 ,
                  41 , 42 , 43 , 44 , 47 , 63 , 64 ] then
                    GATTR . BTYPE := GATTR . TYPTR ;
                  if MATCHPAR then
                    if SY = RPARENT then
                      INSYMBOL
                    else
                      ERROR ( 4 ) ;
                end (* then *)
              else
                CALLNONSTANDARD
            end (* CALL *) ;


         procedure GENSETOP ( LATTR : ATTR ; OP : OPRANGE ) ;

            begin (* GENSETOP *)
              with GATTR do
                if ( TYPTR <> NIL ) and ( LATTR . TYPTR <> NIL ) then
                  if ( TYPTR -> . FORM = POWER ) and ( COMPTYPES (
                  TYPTR , LATTR . TYPTR ) = 1 ) then
                    begin
                      FORCETEMPSET ( 3 , - 1 ) ;
                      GEN0 ( OP ) ;
                      if OP = 12 then
                        if LATTR . STKLEN < STKLEN then
                          STKLEN := LATTR . STKLEN ;
                      if OP = 31 then
                        if LATTR . STKLEN > STKLEN then
                          STKLEN := LATTR . STKLEN ;
                      if OP = 5 then
                        STKLEN := LATTR . STKLEN ;
                      STKDPLMT := LATTR . STKDPLMT ;
                      LCOUNTER := STKDPLMT + STKLEN ;
                      if LCOUNTER > LCMAX then
                        LCMAX := LCOUNTER ;
                    end (* then *)
                  else
                    begin
                      ERROR ( 134 ) ;
                      GATTR . TYPTR := NIL ;
                      GATTR . BTYPE := NIL
                    end (* else *)
            end (* GENSETOP *) ;


         procedure EXPRESSION ;

            const COMPARE_OP : array [ LTOP .. EQOP ] of 0 .. OPMAX =
                  ( 53 , 52 , 48 , 49 , 55 , 47 ) ;

            var LATTR : ATTR ;
                LOP : OPERSYMB ;
                TYPIND : CHAR ;
                LLC , LSIZE : ADDRRANGE ;
                CT_RESULT : INTEGER ;


            procedure SIMPLEEXPRESSION ( FSYS : SETOFSYS ) ;

               var LATTR : ATTR ;
                   LOP : OPERSYMB ;
                   SIGNED : BOOLEAN ;
                   LVPR : CONSTP ;


               procedure TERM ( FSYS : SETOFSYS ) ;

                  var LATTR : ATTR ;
                      LOP : OPERSYMB ;


                  procedure FACTOR ( FSYS : SETOFSYS ) ;

                     var LCP : IDP ;
                         SETVAL : XCONSTANT ;
                         LVP : SSP ;
                         LATTR : ATTR ;
                         LSP : TTP ;
                         I , J : INTEGER ;
                         SETLOCAL_LC , SETVAR_SIZE : ADDRRANGE ;
                         SETOFFS_LOCAL : INTEGER ;
                         NOCHMAL : BOOLEAN ;
                         PSI : PSETINFO ;


                     procedure FACT_KONST ;

                        begin (* FACT_KONST *)
                          with GATTR , LCP -> do
                            begin
                              TYPTR := IDTYPE ;
                              KIND := CST ;
                              CVAL := VALUES ;
                              if SY in [ LBRACK , LPARENT ] then
                                if XSTRING ( TYPTR ) then
                                  begin
                                    if SY = LPARENT then
                                      begin
                                        ERRKIND := 'W' ;
                                        ERROR ( 11 )
                                      end (* then *) ;
                                    LATTR := GATTR ;
                                    LOADADDRESS ;
                                    INSYMBOL ;
                                    EXPRESSION ( FSYS + [ RBRACK ,
                                                 RPARENT ] ) ;
                                    LOAD ;
                                    LSP := LATTR . TYPTR -> . INXTYPE ;
                                    if COMPTYPES ( TYPTR , LSP ) = 1
                                    then
                                      begin
                                        if LSP <> NIL then
                                          GETBOUNDS ( LSP , I , J )
                                        else
                                          begin
                                            I := 1 ;
                                            J := LATTR . TYPTR -> .
                                                 SIZE
                                          end (* else *) ;
                                        if DEBUG then

                          (********)
                          (*CHK   *)
                          (********)

                                          GEN3 ( 45 , ORD ( 'J' ) , I ,
                                                 J DIV CHARSIZE ) ;
                                        if I <> 0 then

                          (********)
                          (*DEC   *)
                          (********)

                                          GEN2 ( 22 , ORD ( 'I' ) , I )
                                                 ;

                          (********)
                          (*IXA   *)
                          (********)

                                        GEN1 ( 36 , CHARSIZE ) ;
                                      end (* then *)
                                    else
                                      ERROR ( 139 ) ;
                                    TYPTR := CHARPTR ;
                                    KIND := VARBL ;
                                    BTYPE := CHARPTR ;
                                    ACCESS := INDRCT ;
                                    IDPLMT := 0 ;
                                    if SY = RBRACK then
                                      INSYMBOL
                                    else
                                      if SY = RPARENT then
                                        begin
                                          ERRKIND := 'W' ;
                                          ERROR ( 12 ) ;
                                          INSYMBOL ;
                                        end (* then *)
                                      else
                                        ERROR ( 12 ) ;
                                  end (* then *)
                            end (* with *)
                        end (* FACT_KONST *) ;


                     function FACT_SET_UP : BOOLEAN ;

                        var OK : BOOLEAN ;
                            NOCHMAL : BOOLEAN ;
                            SETMIN_DUMMY : INTEGER ;
                            SETMAX_DUMMY : INTEGER ;

                        begin (* FACT_SET_UP *)
                          LSP -> . ELSET := GATTR . TYPTR ;
                          if GATTR . KIND = CST then
                            begin

                          (******************************)
                          (* set_const_part, that is:   *)
                          (* single constant or         *)
                          (* range of constants         *)
                          (******************************)

                              NOCHMAL := SET_CONST_PART ( GATTR . TYPTR
                                         , GATTR . CVAL , PSI ) ;
                              PSI -> . CONST_IN_SET := PSI -> .
                                                   CONST_IN_SET + 1 ;
                              FACT_SET_UP := NOCHMAL ;
                            end (* then *)
                          else
                            begin

                          (******************************)
                          (* if variable, the integer   *)
                          (* value is simply put on     *)
                          (* the stack and the          *)
                          (* number of stack values     *)
                          (* is incremented, so that    *)
                          (* later ASE instructions     *)
                          (* can be triggered           *)
                          (******************************)

                              LOAD ;
                              if GATTR . TYPTR <> INTPTR then

                          (********)
                          (*ORD   *)
                          (********)

                                GEN0 ( 61 ) ;
                              SETVAR_SIZE := MAXSETL + 4 ;
                              if GATTR . TYPTR <> NIL then
                                if GATTR . TYPTR <> INTPTR then
                                  CALC_SETTYPSIZE ( GATTR . TYPTR ,
                                                   SETVAR_SIZE ,
                                                   SETMIN_DUMMY ,
                                                   SETMAX_DUMMY ,
                                                   SETOFFS_LOCAL ) ;
                              if SETVAR_SIZE > MAXSETL + 4 then
                                SETVAR_SIZE := MAXSETL + 4 ;
                              PSI -> . VARS_IN_SET := PSI -> .
                                                   VARS_IN_SET + 1 ;
                              FACT_SET_UP := FALSE ;
                            end (* else *)
                        end (* FACT_SET_UP *) ;


                     procedure SPECIAL_WORK ( LCP : IDP ) ;

                        begin (* SPECIAL_WORK *)
                          if LCP -> . KLASS = VARS then
                            case LCP -> . SPECIAL of
                              1 : begin
                                    GEN1 ( 30 , ORD ( PDAT ) )
                                  end (* tag/ca *) ;
                              2 : begin
                                    GEN1 ( 30 , ORD ( PTIM ) ) ;
                                  end (* tag/ca *) ;
                            end (* case *) ;
                        end (* SPECIAL_WORK *) ;


                     procedure FACTOR_IDENT ;

                        begin (* FACTOR_IDENT *)
                          IDFOUND := SEARCHID ( ID , FALSE , FALSE , [
                                     STRUCTKONST , KONST , VARS , FIELD
                                     , FUNC ] , LCP ) ;
                          STARTID := ID ;
                          INSYMBOL ;

                          /************************************/
                          /* add id of appropriate class      */
                          /* to prevent more errors           */
                          /*   in case of notfound            */
                          /* special error code,              */
                          /*   if undecl. function            */
                          /************************************/

                          if not IDFOUND then
                            if SY = LPARENT then
                              begin
                                ERRKIND := 'W' ;
                                ERROR ( 186 ) ;
                                DUMMYBOOL := SEARCHID ( STARTID , FALSE
                                             , TRUE , [ FUNC ] , LCP )
                                             ;
                                LCP -> . IDTYPE := INTPTR ;
                                LCP -> . KLASS := FUNC ;
                                LCP -> . DECLMISSING := TRUE ;
                                LCP -> . EXTRN := TRUE ;
                                PACK ( STARTID , 1 , LCP -> . EXTNAME )
                                       ;
                              end (* then *)
                            else
                              begin
                                ERROR ( 104 ) ;
                                DUMMYBOOL := SEARCHID ( STARTID , FALSE
                                             , TRUE , [ VARS ] , LCP )
                              end (* else *) ;
                          if LCP <> NIL then
                            SPECIAL_WORK ( LCP ) ;
                          if LCP -> . KLASS = FUNC then
                            begin
                              CALL ( FSYS , LCP ) ;
                              GATTR . KIND := EXPR
                            end (* then *)
                          else
                            if LCP -> . KLASS = KONST then
                              FACT_KONST
                            else
                              SELECTOR ( FSYS , LCP )
                        end (* FACTOR_IDENT *) ;


                     begin (* FACTOR *)
                       if not ( SY in FACBEGSYS ) then
                         begin
                           ERROR ( 58 ) ;
                           SKIP ( FSYS + FACBEGSYS ) ;
                           GATTR . TYPTR := NIL
                         end (* then *) ;
                       while SY in FACBEGSYS do
                         begin
                           case SY of
                             IDENT : FACTOR_IDENT ;
                             INTCONST :
                               begin
                                 with GATTR do
                                   begin
                                     TYPTR := INTPTR ;
                                     KIND := CST ;
                                     CVAL := VAL
                                   end (* with *) ;
                                 INSYMBOL
                               end (* tag/ca *) ;
                             REALCONST :
                               begin
                                 with GATTR do
                                   begin
                                     TYPTR := REALPTR ;
                                     KIND := CST ;
                                     CVAL := VAL
                                   end (* with *) ;
                                 INSYMBOL
                               end (* tag/ca *) ;
                             STRINGCONST :
                               begin
                                 with GATTR do
                                   begin
                                     if LNGTH = 1 then
                                       TYPTR := CHARPTR
                                     else
                                       begin
                                         NEW ( LSP , ARRAYS ) ;
                                         with LSP -> do
                                           begin
                                             AELTYPE := CHARPTR ;
                                             FORM := ARRAYS ;
                                             INXTYPE := NIL ;
                                             SIZE := LNGTH * CHARSIZE ;
                                             ALN := CHARSIZE ;
                                           end (* with *) ;
                                         TYPTR := LSP
                                       end (* else *) ;
                                     KIND := CST ;
                                     CVAL := VAL ;
                                   end (* with *) ;
                                 INSYMBOL
                               end (* tag/ca *) ;
                             LPARENT :
                               begin
                                 INSYMBOL ;
                                 EXPRESSION ( FSYS + [ RPARENT ] ) ;
                                 if SY = RPARENT then
                                   INSYMBOL
                                 else
                                   ERROR ( 4 )
                               end (* tag/ca *) ;
                             NOTSY : begin
                                       INSYMBOL ;
                                       FACTOR ( FSYS ) ;
                                       LOAD ;

                       (********)
                       (*NOT   *)
                       (********)

                                       if GATTR . TYPTR <> NIL then
                                         if GATTR . TYPTR = BOOLPTR
                                         then
                                           GEN2 ( 19 , ORD ( 'B' ) , 0
                                                  )
                                         else
                                           if GATTR . TYPTR = INTPTR
                                           then
                                             GEN2 ( 19 , ORD ( 'I' ) ,
                                                   0 )
                                           else
                                             begin
                                               ERROR ( 135 ) ;
                                               GATTR . TYPTR := NIL
                                             end (* else *) ;
                                     end (* tag/ca *) ;
                             LBRACK :
                               begin
                                 PSI := PSIGLOB ;
                                 PSI -> . ELEMCOUNT := 0 ;
                                 PSI -> . SETMIN := 0 ;
                                 PSI -> . SETMAX := 0 ;
                                 PSI -> . RANGEERR := 0 ;
                                 PSI -> . CHARTYPE := FALSE ;
                                 PSI -> . HEXORBIN := ' ' ;
                                 PSI -> . VARS_IN_SET := 0 ;
                                 PSI -> . CONST_IN_SET := 0 ;
                                 INSYMBOL ;

                       /**********************************************/
                       /* store set values in array of size          */
                       /* setmaxsize                                 */
                       /* compute setmin and setmax, while reading   */
                       /* constant elements; offset at the end       */
                       /* build cstpart setstring at the end         */
                       /**********************************************/

                                 NEW ( LSP , POWER ) ;
                                 with LSP -> do
                                   begin
                                     ELSET := NIL ;
                                     SIZE := 4 ;
                                     SETMIN := 0 ;
                                     SETMAX := 0 ;
                                     SETOFFS := 0 ;
                                     FORM := POWER
                                   end (* with *) ;
                                 if SY = RBRACK then
                                   begin
                                     with GATTR do
                                       begin
                                         TYPTR := LSP ;
                                         KIND := CST
                                       end (* with *) ;
                                     INSYMBOL
                                   end (* then *)
                                 else
                                   begin
                                     repeat
                                       EXPRESSION ( FSYS + [ COMMA ,
                                                   DOTDOT , RBRACK ] )
                                                   ;
                                       NOCHMAL := FALSE ;
                                       if GATTR . TYPTR <> NIL then
                                         if GATTR . TYPTR -> . FORM <>
                                         SCALAR then
                                           begin
                                             ERROR ( 136 ) ;
                                             GATTR . TYPTR := NIL
                                           end (* then *)
                                         else
                                           if COMPTYPES ( LSP -> .
                                           ELSET , GATTR . TYPTR ) = 1
                                           then
                                             NOCHMAL := FACT_SET_UP
                                           else
                                             ERROR ( 137 ) ;

                       /*******************************/
                       /* nochmal may already be true */
                       /* and sy neq comma            */
                       /* - set by fact_set_up        */
                       /*******************************/

                                       if SY = COMMA then
                                         begin
                                           INSYMBOL ;
                                           NOCHMAL := TRUE ;
                                         end (* then *)
                                     until not NOCHMAL ;
                                     if SY = RBRACK then
                                       INSYMBOL
                                     else
                                       ERROR ( 12 ) ;
                                     if FALSE then
                                       begin
                                         WRITELN ( TRACEF ) ;
                                         WRITELN ( TRACEF ,
                                                   'psi.elemcount = ' ,
                                                   PSI -> . ELEMCOUNT )
                                                   ;
                                         WRITELN ( TRACEF ,
                                                   'psi.setmin    = ' ,
                                                   PSI -> . SETMIN ) ;
                                         WRITELN ( TRACEF ,
                                                   'psi.setmax    = ' ,
                                                   PSI -> . SETMAX ) ;
                                         WRITELN ( TRACEF ,
                                                   'psi.rangeerr  = ' ,
                                                   PSI -> . RANGEERR )
                                                   ;
                                         for I := 1 to SETMAXSIZE do
                                           if PSI -> . SETELEMS [ I ]
                                           then
                                             WRITELN ( TRACEF ,
                                                   'in set        = ' ,
                                                   PSI -> . SETMIN + I
                                                   - 1 ) ;
                                       end (* then *) ;
                                   end (* else *) ;
                                 if PSI -> . VARS_IN_SET > 0 then
                                   begin
                                     BUILD_SET ( SETVAL , PSI ) ;
                                     ALIGN ( LCOUNTER , WORDSIZE ) ;

                       (*******************************)
                       (* compute needed storage size *)
                       (*******************************)

                                     if PSI -> . CONST_IN_SET > 0 then
                                       begin

                       (********)
                       (*LCA   *)
                       (********)

                                         GEN_LCA_S ( LSP -> . ELSET ,
                                                   SETVAL ) ;
                                         ALIGN ( LCOUNTER , WORDSIZE )
                                                 ;
                                         SETLOCAL_LC := LCOUNTER ;
                                         if PSI -> . CHARTYPE then
                                           begin

                       (********)
                       (*LDA   *)
                       (********)

                                             GEN2 ( 50 , LEVEL ,
                                                   LCOUNTER ) ;

                       (********)
                       (*SMV   *)
                       (********)

                                             GEN_SET ( 69 , -
                                                   SETVAR_SIZE , 0 )
                                           end (* then *)
                                         else
                                           begin

                       (********)
                       (*LDA   *)
                       (********)

                                             GEN2 ( 50 , LEVEL ,
                                                   LCOUNTER ) ;

                       (********)
                       (*SLD   *)
                       (********)

                                             GEN_SET ( 68 , SETVAR_SIZE
                                                   , SETOFFS_LOCAL )
                                           end (* else *) ;
                                         LCOUNTER := LCOUNTER +
                                                   SETVAR_SIZE ;
                                         if LCOUNTER > LCMAX then
                                           LCMAX := LCOUNTER ;
                                       end (* then *)
                                     else
                                       begin
                                         ALIGN ( LCOUNTER , WORDSIZE )
                                                 ;
                                         SETLOCAL_LC := LCOUNTER ;

                       (********)
                       (*LDA   *)
                       (********)

                                         GEN2 ( 50 , LEVEL , LCOUNTER )
                                                ;

                       (********)
                       (*SCL   *)
                       (********)

                                         GEN_SET ( 29 , SETVAR_SIZE ,
                                                   SETOFFS_LOCAL ) ;
                                         LCOUNTER := LCOUNTER +
                                                   SETVAR_SIZE ;
                                         if LCOUNTER > LCMAX then
                                           LCMAX := LCOUNTER ;
                                       end (* else *) ;
                                     for I := 1 to PSI -> . VARS_IN_SET
                                     do
                                       begin

                       (********)
                       (*ASE   *)
                       (********)

                                         GEN1 ( 67 , SETVAR_SIZE )
                                       end (* for *) ;
                                     GATTR . KIND := VARBL ;
                                     GATTR . ACCESS := STKEXPR ;
                                     GATTR . STKDPLMT := SETLOCAL_LC ;
                                     GATTR . STKLEN := SETVAR_SIZE ;
                                     LSP -> . SIZE := SETVAR_SIZE ;
                                   end (* then *)
                                 else
                                   begin
                                     BUILD_SET ( SETVAL , PSI ) ;
                                     LSP -> . SIZE := SETVAL . PVAL ->
                                                   . LENGTH ;
                                     GATTR . KIND := CST ;
                                     GATTR . CVAL := SETVAL ;
                                   end (* else *) ;
                                 GATTR . TYPTR := LSP ;
                               end (* tag/ca *)
                           end (* case *) ;
                           if not ( SY in FSYS ) then
                             begin
                               ERROR ( 6 ) ;
                               SKIP ( FSYS + FACBEGSYS )
                             end (* then *) ;
                           if GATTR . KIND <> VARBL then
                             GATTR . BTYPE := GATTR . TYPTR
                           else
                             if GATTR . TYPTR = NIL then
                               GATTR . BTYPE := NIL ;
                         end (* while *) ;
                       if GATTR . TYPTR -> . FORM = POWER then
                         begin
                           WRITELN ( TRACEF ,
                                 '*** Start Testausg. Ende Factor ***'
                                     ) ;
                           WRITELN ( TRACEF , 'gattr.kind          = '
                                     , GATTR . KIND ) ;
                           WRITELN ( TRACEF , 'gattr.access        = '
                                     , GATTR . ACCESS ) ;
                           WRITELN ( TRACEF , 'gattr.typtr.setmin  = '
                                     , GATTR . TYPTR -> . SETMIN ) ;
                           WRITELN ( TRACEF , 'gattr.typtr.setmax  = '
                                     , GATTR . TYPTR -> . SETMAX ) ;
                           WRITELN ( TRACEF , 'gattr.typtr.setoffs = '
                                     , GATTR . TYPTR -> . SETOFFS ) ;
                           if GATTR . TYPTR -> . ELSET = NIL then
                             WRITELN ( TRACEF ,
                                       'gattr.typtr.elset   = ' , 'nil'
                                       )
                           else
                             if GATTR . TYPTR -> . ELSET = CHARPTR then
                               WRITELN ( TRACEF ,
                                         'gattr.typtr.elset   = ' ,
                                         'char' )
                             else
                               WRITELN ( TRACEF ,
                                         'gattr.typtr.elset   = ' ,
                                         'other' ) ;
                           if GATTR . KIND = CST then
                             begin
                               WRITELN ( TRACEF ,
                                         'gattr.cval.strtype  = ' ,
                                         GATTR . CVAL . STRTYPE ) ;
                             end (* then *) ;
                           WRITELN ( TRACEF ,
                                  '*** Ende Testausg. Ende Factor ***'
                                     ) ;
                         end (* then *)
                     end (* FACTOR *) ;


                  begin (* TERM *)
                    FACTOR ( FSYS + [ MULOP ] ) ;
                    while SY = MULOP do
                      begin
                        if GATTR . TYPTR <> NIL then
                          if GATTR . TYPTR -> . FORM < POWER then
                            LOAD
                          else
                            FORCETEMPSET ( 4 , - 1 ) ;
                        LATTR := GATTR ;
                        LOP := OP ;
                        INSYMBOL ;
                        FACTOR ( FSYS + [ MULOP ] ) ;
                        if GATTR . TYPTR <> NIL then
                          if GATTR . TYPTR -> . FORM < POWER then
                            LOAD ;
                        if ( LATTR . TYPTR <> NIL ) and ( GATTR . TYPTR
                        <> NIL ) then
                          case LOP of
                            MUL : if ( LATTR . TYPTR = INTPTR ) and (
                                  GATTR . TYPTR = INTPTR ) then

                    (********)
                    (*MPI   *)
                    (********)

                                    GEN0 ( 15 )
                                  else
                                    begin
                                      if GATTR . TYPTR = INTPTR then
                                        begin

                    (********)
                    (*FLT   *)
                    (********)

                                          GEN0 ( 10 ) ;
                                          GATTR . TYPTR := REALPTR
                                        end (* then *)
                                      else
                                        if LATTR . TYPTR = INTPTR then
                                          begin

                    (********)
                    (*FLO   *)
                    (********)

                                            GEN0 ( 9 ) ;
                                            LATTR . TYPTR := REALPTR
                                          end (* then *) ;
                                      if ( LATTR . TYPTR = REALPTR )
                                      and ( GATTR . TYPTR = REALPTR )
                                      then

                    (********)
                    (*MPR   *)
                    (********)

                                        GEN0 ( 16 )
                                      else

                    (********)
                    (*INT   *)
                    (********)

                                        GENSETOP ( LATTR , 12 ) ;
                                    end (* else *) ;
                            RDIV : begin
                                     if GATTR . TYPTR = INTPTR then
                                       begin

                    (********)
                    (*FLT   *)
                    (********)

                                         GEN0 ( 10 ) ;
                                         GATTR . TYPTR := REALPTR
                                       end (* then *) ;
                                     if LATTR . TYPTR = INTPTR then
                                       begin

                    (********)
                    (*FLO   *)
                    (********)

                                         GEN0 ( 9 ) ;
                                         LATTR . TYPTR := REALPTR
                                       end (* then *) ;
                                     if ( LATTR . TYPTR = REALPTR ) and
                                     ( GATTR . TYPTR = REALPTR ) then

                    (********)
                    (*DVR   *)
                    (********)

                                       GEN0 ( 7 )
                                     else
                                       begin
                                         ERROR ( 134 ) ;
                                         GATTR . TYPTR := NIL
                                       end (* else *)
                                   end (* tag/ca *) ;
                            IDIV : if ( LATTR . TYPTR = INTPTR ) and (
                                   GATTR . TYPTR = INTPTR ) then

                    (********)
                    (*DVI   *)
                    (********)

                                     GEN0 ( 6 )
                                   else
                                     begin
                                       ERROR ( 134 ) ;
                                       GATTR . TYPTR := NIL
                                     end (* else *) ;
                            IMOD : if ( LATTR . TYPTR = INTPTR ) and (
                                   GATTR . TYPTR = INTPTR ) then
                                     GEN0 ( 14 )
                                   else
                                     begin
                                       ERROR ( 134 ) ;
                                       GATTR . TYPTR := NIL
                                     end (* else *) ;
                            ANDOP : if ( LATTR . TYPTR = BOOLPTR ) and
                                    ( GATTR . TYPTR = BOOLPTR ) then

                    (********)
                    (*AND   *)
                    (********)

                                      GEN2 ( 4 , ORD ( 'B' ) , 0 )
                                    else
                                      if ( LATTR . TYPTR = INTPTR ) and
                                      ( GATTR . TYPTR = INTPTR ) then

                    (********)
                    (*AND   *)
                    (********)

                                        GEN2 ( 4 , ORD ( 'I' ) , 0 )
                                      else
                                        begin
                                          ERROR ( 134 ) ;
                                          GATTR . TYPTR := NIL
                                        end (* else *)
                          end (* case *)
                        else
                          GATTR . TYPTR := NIL ;
                        GATTR . BTYPE := GATTR . TYPTR ;
                      end (* while *)
                  end (* TERM *) ;


               begin (* SIMPLEEXPRESSION *)
                 SIGNED := FALSE ;
                 if ( SY = ADDOP ) and ( OP in [ PLUS , MINUS ] ) then
                   begin
                     SIGNED := OP = MINUS ;
                     INSYMBOL
                   end (* then *) ;
                 TERM ( FSYS + [ ADDOP ] ) ;
                 if SIGNED then

                 /********************************************/
                 /*  new in 06.2017 - opp:                   */
                 /*  when constant and signed, don't load    */
                 /*  and generate NGI and NGR                */
                 /*  negate the constants instead            */
                 /********************************************/

                   if GATTR . KIND = CST then
                     begin
                       if GATTR . TYPTR = INTPTR then
                         GATTR . CVAL . IVAL := - GATTR . CVAL . IVAL
                       else
                         if GATTR . TYPTR = REALPTR then
                           begin
                             if GATTR . CVAL . RVAL [ 1 ] = '-' then
                               GATTR . CVAL . RVAL [ 1 ] := '+'
                             else
                               GATTR . CVAL . RVAL [ 1 ] := '-' ;
                           end (* then *)
                         else
                           begin
                             ERROR ( 134 ) ;
                             GATTR . TYPTR := NIL
                           end (* else *)
                     end (* then *)
                   else
                     begin
                       LOAD ;
                       if GATTR . TYPTR = INTPTR then

                 (********)
                 (*NGI   *)
                 (********)

                         GEN0 ( 17 )
                       else
                         if GATTR . TYPTR = REALPTR then

                 (********)
                 (*NGR   *)
                 (********)

                           GEN0 ( 18 )
                         else
                           begin
                             ERROR ( 134 ) ;
                             GATTR . TYPTR := NIL
                           end (* else *)
                     end (* else *) ;
                 while SY = ADDOP do
                   begin
                     if GATTR . TYPTR <> NIL then
                       if GATTR . TYPTR -> . FORM < POWER then
                         LOAD
                       else
                         FORCETEMPSET ( 5 , - 1 ) ;
                     LATTR := GATTR ;
                     LOP := OP ;
                     INSYMBOL ;
                     TERM ( FSYS + [ ADDOP ] ) ;
                     if GATTR . TYPTR <> NIL then
                       if GATTR . TYPTR -> . FORM < POWER then
                         LOAD ;
                     if ( LATTR . TYPTR <> NIL ) and ( GATTR . TYPTR <>
                     NIL ) then
                       case LOP of
                         PLUS : if ( LATTR . TYPTR = INTPTR ) and (
                                GATTR . TYPTR = INTPTR ) then

                 (********)
                 (*ADI   *)
                 (********)

                                  GEN0 ( 2 )
                                else
                                  begin
                                    if GATTR . TYPTR = INTPTR then
                                      begin

                 (********)
                 (*FLT   *)
                 (********)

                                        GEN0 ( 10 ) ;
                                        GATTR . TYPTR := REALPTR
                                      end (* then *)
                                    else
                                      if LATTR . TYPTR = INTPTR then
                                        begin

                 (********)
                 (*FLO   *)
                 (********)

                                          GEN0 ( 9 ) ;
                                          LATTR . TYPTR := REALPTR
                                        end (* then *) ;
                                    if ( LATTR . TYPTR = REALPTR ) and
                                    ( GATTR . TYPTR = REALPTR ) then

                 (********)
                 (*ADR   *)
                 (********)

                                      GEN0 ( 3 )
                                    else

                 (********)
                 (*UNI   *)
                 (********)

                                      GENSETOP ( LATTR , 31 ) ;
                                  end (* else *) ;
                         MINUS : if ( LATTR . TYPTR = INTPTR ) and (
                                 GATTR . TYPTR = INTPTR ) then

                 (********)
                 (*SBI   *)
                 (********)

                                   GEN0 ( 21 )
                                 else
                                   begin
                                     if GATTR . TYPTR = INTPTR then
                                       begin

                 (********)
                 (*FLT   *)
                 (********)

                                         GEN0 ( 10 ) ;
                                         GATTR . TYPTR := REALPTR
                                       end (* then *)
                                     else
                                       if LATTR . TYPTR = INTPTR then
                                         begin

                 (********)
                 (*FLO   *)
                 (********)

                                           GEN0 ( 9 ) ;
                                           LATTR . TYPTR := REALPTR
                                         end (* then *) ;
                                     if ( LATTR . TYPTR = REALPTR ) and
                                     ( GATTR . TYPTR = REALPTR ) then

                 (********)
                 (*SBR   *)
                 (********)

                                       GEN0 ( 8 )
                                     else

                 (********)
                 (*DIF   *)
                 (********)

                                       GENSETOP ( LATTR , 5 ) ;
                                   end (* else *) ;
                         OROP : if ( LATTR . TYPTR = BOOLPTR ) and (
                                GATTR . TYPTR = BOOLPTR ) then

                 (********)
                 (*IOR   *)
                 (********)

                                  GEN2 ( 13 , ORD ( 'B' ) , 0 )
                                else
                                  if ( LATTR . TYPTR = INTPTR ) and (
                                  GATTR . TYPTR = INTPTR ) then

                 (********)
                 (*IOR   *)
                 (********)

                                    GEN2 ( 13 , ORD ( 'I' ) , 0 )
                                  else
                                    begin
                                      ERROR ( 134 ) ;
                                      GATTR . TYPTR := NIL
                                    end (* else *) ;
                         XOROP : if ( LATTR . TYPTR = BOOLPTR ) and (
                                 GATTR . TYPTR = BOOLPTR ) then

                 (********)
                 (*IOR   *)
                 (********)

                                   begin
                                     GEN2 ( 79 , ORD ( 'B' ) , 0 )
                                   end (* then *)
                                 else
                                   if ( LATTR . TYPTR = INTPTR ) and (
                                   GATTR . TYPTR = INTPTR ) then

                 (********)
                 (*IOR   *)
                 (********)

                                     begin
                                       GEN2 ( 79 , ORD ( 'I' ) , 0 )
                                     end (* then *)
                                   else
                                     begin
                                       ERROR ( 134 ) ;
                                       GATTR . TYPTR := NIL
                                     end (* else *)
                       end (* case *)
                     else
                       GATTR . TYPTR := NIL ;
                     GATTR . BTYPE := GATTR . TYPTR ;
                   end (* while *)
               end (* SIMPLEEXPRESSION *) ;


            begin (* EXPRESSION *)
              LLC := LCOUNTER ;
              SIMPLEEXPRESSION ( FSYS + [ RELOP ] ) ;
              if SY = RELOP then
                begin
                  if GATTR . TYPTR <> NIL then
                    if GATTR . TYPTR -> . FORM < POWER then
                      LOAD
                    else
                      if GATTR . TYPTR -> . FORM = POWER then
                        FORCETEMPSET ( 6 , - 1 )
                      else
                        LOADADDRESS ;
                  LATTR := GATTR ;
                  LOP := OP ;
                  if LOP = INOP then
                    if GATTR . TYPTR <> INTPTR then

              (********)
              (*ORD   *)
              (********)

                      GEN0 ( 61 ) ;
                  INSYMBOL ;
                  SIMPLEEXPRESSION ( FSYS ) ;

              (****************************************************)
              (*  vorkehrungen fuer unterschiedlich lange strings *)
              (****************************************************)

                  if ( LATTR . TYPTR <> NIL ) and ( GATTR . TYPTR <>
                  NIL ) then
                    begin
                      CT_RESULT := COMPTYPES ( LATTR . TYPTR , GATTR .
                                   TYPTR ) ;

              (*************************************************)
              (* maybe source string has shorter size          *)
              (* if so, adjust size                            *)
              (*************************************************)

                      if CT_RESULT in [ 2 , 3 ] then
                        begin
                          if ( GATTR . KIND = CST ) and ( XSTRING (
                          GATTR . TYPTR ) or ( GATTR . TYPTR = CHARPTR
                          ) ) then
                            begin
                              MOD_STRCONST ( CT_RESULT , GATTR . CVAL ,
                                             GATTR . TYPTR , LATTR .
                                             TYPTR -> . SIZE ) ;
                            end (* then *)
                        end (* then *) ;
                    end (* then *) ;
                  if GATTR . TYPTR <> NIL then
                    if GATTR . TYPTR -> . FORM < POWER then
                      LOAD
                    else
                      if GATTR . TYPTR -> . FORM = POWER then

              (**********************)
              (* foRCETEMPSET ( 7 ) *)
              (**********************)

                        LOADADDRESS
                      else
                        LOADADDRESS ;
                  if ( LATTR . TYPTR <> NIL ) and ( GATTR . TYPTR <>
                  NIL ) then

              (********)
              (*IN    *)
              (********)

                    if LOP = INOP then
                      if GATTR . TYPTR -> . FORM = POWER then
                        if COMPTYPES ( LATTR . TYPTR , GATTR . TYPTR ->
                        . ELSET ) = 1 then

              (********)
              (*INN   *)
              (********)

                          GEN0 ( 11 )
                        else
                          begin
                            ERROR ( 129 ) ;
                            GATTR . TYPTR := NIL
                          end (* else *)
                      else
                        begin
                          ERROR ( 130 ) ;
                          GATTR . TYPTR := NIL
                        end (* else *)
                    else
                      begin
                        if LATTR . TYPTR <> GATTR . TYPTR then
                          if GATTR . TYPTR = INTPTR then
                            begin

              (********)
              (*FLT   *)
              (********)

                              GEN0 ( 10 ) ;
                              GATTR . TYPTR := REALPTR
                            end (* then *)
                          else
                            if LATTR . TYPTR = INTPTR then
                              begin

              (********)
              (*FLO   *)
              (********)

                                GEN0 ( 9 ) ;
                                LATTR . TYPTR := REALPTR
                              end (* then *) ;
                        CT_RESULT := COMPTYPES ( LATTR . TYPTR , GATTR
                                     . TYPTR ) ;
                        if CT_RESULT in [ 1 , 2 ] then
                          begin
                            LSIZE := LATTR . TYPTR -> . SIZE ;
                            case LATTR . TYPTR -> . FORM of
                              SCALAR :
                                if LATTR . TYPTR = REALPTR then
                                  TYPIND := 'R'
                                else
                                  if LATTR . TYPTR = BOOLPTR then
                                    TYPIND := 'B'
                                  else
                                    if LATTR . TYPTR = CHARPTR then
                                      TYPIND := 'C'
                                    else
                                      TYPIND := 'I' ;
                              POINTER :
                                begin
                                  if LOP in [ LTOP , LEOP , GTOP , GEOP
                                  ] then
                                    ERROR ( 131 ) ;
                                  TYPIND := 'A'
                                end (* tag/ca *) ;
                              POWER : begin
                                        if LOP in [ LTOP , GTOP ] then
                                          ERROR ( 132 ) ;
                                        TYPIND := 'S' ;
                                      end (* tag/ca *) ;
                              ARRAYS :
                                begin
                                  if not XSTRING ( LATTR . TYPTR ) then
                                    if LOP in [ LTOP , LEOP , GTOP ,
                                    GEOP ] then
                                      ERROR ( 131 ) ;
                                  TYPIND := 'M'
                                end (* tag/ca *) ;
                              RECORDS :
                                begin
                                  if LOP in [ LTOP , LEOP , GTOP , GEOP
                                  ] then
                                    ERROR ( 131 ) ;
                                  TYPIND := 'M'
                                end (* tag/ca *) ;
                              FILES : begin
                                        ERROR ( 133 ) ;
                                        TYPIND := 'F'
                                      end (* tag/ca *)
                            end (* case *) ;
                            GEN2 ( COMPARE_OP [ LOP ] , ORD ( TYPIND )
                                   , LSIZE ) ;
                          end (* then *)
                        else
                          ERROR ( 129 )
                      end (* else *) ;
                  GATTR . TYPTR := BOOLPTR ;
                  GATTR . BTYPE := BOOLPTR ;
                  GATTR . KIND := EXPR ;
                  LCOUNTER := LLC ;
                end (* then *)
            end (* EXPRESSION *) ;


         procedure ASSIGNMENT ( FCP : IDP ) ;

            var LATTR : ATTR ;
                LSIZE , RSIZE , LLC : ADDRRANGE ;
                CT_RESULT : INTEGER ;
                XSAVE : TYPECLASS ;
                LSETOFFS : INTEGER ;
                LCHARTYPE : BOOLEAN ;
                RSETOFFS : INTEGER ;
                RCHARTYPE : BOOLEAN ;

            begin (* ASSIGNMENT *)
              LLC := LCOUNTER ;
              SELECTOR ( FSYS + [ BECOMES ] , FCP ) ;
              VAR_MOD := VAR_MOD + 1 ;
              if SY = BECOMES then
                begin
                  if GATTR . TYPTR <> NIL then
                    if ( GATTR . ACCESS <> DRCT ) or ( GATTR . TYPTR ->
                    . FORM >= POWER ) then
                      LOADADDRESS ;
                  LATTR := GATTR ;
                  INSYMBOL ;
                  EXPRESSION ( FSYS ) ;

              (********************************)
              (* new: check comptypes first,  *)
              (* maybe short string constant  *)
              (* comptypes = 2                *)
              (********************************)

                  CT_RESULT := 0 ;
                  if ( LATTR . TYPTR <> NIL ) and ( GATTR . TYPTR <>
                  NIL ) then
                    begin
                      CT_RESULT := COMPTYPES ( LATTR . TYPTR , GATTR .
                                   TYPTR ) ;

              (*************************************************)
              (* maybe source string has shorter size          *)
              (* if so, adjust size                            *)
              (*************************************************)

                      if CT_RESULT in [ 2 , 3 ] then
                        begin
                          if ( GATTR . KIND = CST ) and ( XSTRING (
                          GATTR . TYPTR ) or ( GATTR . TYPTR = CHARPTR
                          ) ) then
                            begin
                              MOD_STRCONST ( CT_RESULT , GATTR . CVAL ,
                                             GATTR . TYPTR , LATTR .
                                             TYPTR -> . SIZE ) ;
                            end (* then *)
                          else
                            begin
                              CT_RESULT := 0
                            end (* else *)
                        end (* then *)
                    end (* then *) ;

              (*************************************************)
              (* load source of assignment                     *)
              (*************************************************)

                  if GATTR . TYPTR <> NIL then
                    if GATTR . TYPTR -> . FORM < POWER then
                      LOAD
                    else
                      if GATTR . TYPTR -> . FORM = POWER then
                        FORCETEMPSET ( 8 , LATTR . TYPTR -> . SIZE )
                      else
                        LOADADDRESS ;

              (********************************)
              (* if both sides are ok         *)
              (********************************)

                  if ( LATTR . TYPTR <> NIL ) and ( GATTR . TYPTR <>
                  NIL ) then
                    begin
                      if ( LATTR . TYPTR = REALPTR ) and ( GATTR .
                      TYPTR = INTPTR ) then
                        begin

              (**************************************)
              (* assignment integer to real is ok;  *)
              (* modify right hand type to real     *)
              (* set ct_result to 1 to avoid $E129  *)
              (* generate FLT instruction           *)
              (**************************************)

                          GEN0 ( 10 ) ;
                          GATTR . TYPTR := REALPTR ;
                          CT_RESULT := 1 ;
                        end (* then *) ;

              (*******************************************)
              (* store result depending on object class  *)
              (*******************************************)

                      if CT_RESULT in [ 1 , 2 , 3 ] then
                        begin
                          if DEBUG then
                            begin
                              ASSIGN := TRUE ;
                              CHKBNDS ( LATTR . BTYPE ) ;
                              ASSIGN := FALSE
                            end (* then *) ;
                          case LATTR . TYPTR -> . FORM of
                            SCALAR , SUBRANGE , POINTER :
                              STORE ( LATTR ) ;
                            POWER : begin
                                      LSIZE := OPNDSETSIZE ( LATTR ,
                                               LSETOFFS , LCHARTYPE ) ;
                                      RSIZE := OPNDSETSIZE ( GATTR ,
                                               RSETOFFS , RCHARTYPE ) ;
                                      WRITELN ( TRACEF ,
                                              'assignment: linecnt = '
                                                , LINECNT : 1 ,
                                               ' --------------------'
                                                ) ;
                                      WRITELN ( TRACEF , 'lsetoffs  = '
                                                , LSETOFFS : 1 ) ;
                                      WRITELN ( TRACEF , 'lchartype = '
                                                , LCHARTYPE ) ;
                                      WRITELN ( TRACEF , 'rsetoffs  = '
                                                , LSETOFFS : 1 ) ;
                                      WRITELN ( TRACEF , 'rchartype = '
                                                , LCHARTYPE ) ;
                                      WRITELN ( TRACEF ,
                                              'assignment: linecnt = '
                                                , LINECNT : 1 ,
                                               ' --------------------'
                                                ) ;
                                      if RCHARTYPE then

              (********)
              (*SMV   *)
              (********)

                                        GEN_SET ( 69 , LATTR . TYPTR ->
                                                  . SIZE , 0 )
                                      else

              (********)
              (*SLD   *)
              (********)

                                        GEN_SET ( 68 , LATTR . TYPTR ->
                                                  . SIZE , LSETOFFS ) ;
                                    end (* tag/ca *) ;
                            ARRAYS , RECORDS :
                              

              (********)
              (*MOV   *)
              (********)


                              GEN1 ( 40 , LATTR . TYPTR -> . SIZE ) ;
                            FILES : ERROR ( 146 )
                          end (* case *)
                        end (* then *)
                      else
                        ERROR ( 129 )
                    end (* then *)
                end (* then *)
              else
                ERROR ( 51 ) ;
              LCOUNTER := LLC ;
            end (* ASSIGNMENT *) ;


         procedure GOTOSTATEMENT ;

            label 10 ;

            var LLP : LBP ;
                TTOP : DISPRANGE ;
                XLABEL : ALPHA ;

            begin (* GOTOSTATEMENT *)
              if SY = INTCONST then
                begin
                  TTOP := LEVEL ;
                  repeat
                    LLP := DISPLAY [ TTOP ] . FLABEL ;
                    while LLP <> NIL do
                      with LLP -> do
                        if LABVAL = VAL . IVAL then
                          begin
                            if TTOP = LEVEL then

              (********)
              (*UJP   *)
              (********)

                              GENUJPFJP ( 57 , LABNAME )
                            else
                              begin
                                if XNO = 0 then

              (*****************************************)
              (*   FIRST DEEP GOTO TO THIS LABEL       *)
              (*****************************************)

                                  begin
                                    XLABNO := XLABNO + 1 ;
                                    XNO := XLABNO
                                  end (* then *) ;
                                XLABEL := '############' ;
                                MKNAME ( XLABEL , XNO , FALSE ) ;
                                if PRCODE then
                                  WRITELN ( PRR , MN [ 73 ] , ' ' ,
                                            XLABEL : EXTNAMSZ ) ;
                              end (* else *) ;
                            CTREMIT ( CTRGOTO , 0 , LINECNT , 0 ,
                                      LINECNT ) ;
                            goto 10
                          end (* then *)
                        else
                          LLP := NEXTLAB ;
                    TTOP := TTOP - 1
                  until TTOP = 0 ;
                  ERROR ( 167 ) ;
                  10 :
                  INSYMBOL
                end (* then *)
              else
                ERROR ( 15 )
            end (* GOTOSTATEMENT *) ;


         procedure COMPOUNDSTATEMENT ;

            begin (* COMPOUNDSTATEMENT *)
              repeat
                repeat
                  STATEMENT ( FSYS + [ SEMICOLON , ENDSY ] , LOOPC ,
                              SUBR ) ;
                until not ( SY in STATBEGSYS ) ;
                TEST := SY <> SEMICOLON ;
                if not TEST then
                  INSYMBOL
              until TEST ;
              if SY = ENDSY then
                INSYMBOL
              else
                ERROR ( 13 )
            end (* COMPOUNDSTATEMENT *) ;


         procedure IFSTATEMENT ;

            var LCIX1 , LCIX2 : LABELRNG ;
                FIRSTLN , MIDLN : INTEGER ;
                CTRNO : CTRRANGE ;

            begin (* IFSTATEMENT *)
              EXPRESSION ( FSYS + [ THENSY ] ) ;
              GENLABEL ( LCIX1 ) ;
              GENFJP ( LCIX1 ) ;
              if SY = THENSY then
                INSYMBOL
              else
                ERROR ( 52 ) ;
              FIRSTLN := LINECNT ;
              CTRNO := CTRGEN ;

              (********************)
              (*** COUNTER HERE ***)
              (********************)

              STATEMENT ( FSYS + [ ELSESY ] , LOOPC , SUBR ) ;
              if SY = ELSESY then
                begin
                  GENLABEL ( LCIX2 ) ;

              (********)
              (*UJP   *)
              (********)

                  GENUJPFJP ( 57 , LCIX2 ) ;
                  PUTLABEL ( LCIX1 ) ;
                  INSYMBOL ;
                  MIDLN := LINECNT ;
                  STATEMENT ( FSYS , LOOPC , SUBR ) ;
                  PUTLABEL ( LCIX2 )
                end (* then *)
              else
                begin
                  PUTLABEL ( LCIX1 ) ;
                  MIDLN := 0 ;
                end (* else *) ;
              CTREMIT ( CTRIF , CTRNO , FIRSTLN , MIDLN , LINECNT )
            end (* IFSTATEMENT *) ;


         procedure CASESTATEMENT ;

            type CIP = -> CASEINFO ;
                 CASEINFO = record
                              NEXT : CIP ;
                              CSSTART : LABELRNG ;
                              HEXORBIN : CHAR ;
                              CSLAB1 , CSLAB2 : XCONSTANT ;
                            end ;

            var LSP , LSP1 : TTP ;
                FSTPTR , LPT1 , LPT2 , LPT3 : CIP ;
                LVAL1 , LVAL2 : XCONSTANT ;
                LADDR , LCIX , LCIX1 , UBND , LBND , XADDR : LABELRNG ;
                LMIN , LMAX : INTEGER ;
                OTHWC : BOOLEAN ;
                FIRSTLN : INTEGER ;
                TEMPLN : INTEGER ;
                CTRCASES : INTEGER ;
                CTRNO : CTRRANGE ;
                STRT : CHAR ;

            begin (* CASESTATEMENT *)
              EXPRESSION ( FSYS + [ OFSY , COMMA , COLON ] ) ;
              LOAD ;
              LSP := GATTR . TYPTR ;
              if LSP <> NIL then
                if ( LSP -> . FORM <> SCALAR ) or ( LSP = REALPTR )
                then
                  begin
                    ERROR ( 144 ) ;
                    LSP := NIL
                  end (* then *)
                else
                  if COMPTYPES ( LSP , INTPTR ) <> 1 then

              (********)
              (*ORD   *)
              (********)

                    GEN0 ( 61 ) ;
              if DEBUG then
                CHKBNDS ( GATTR . TYPTR ) ;
              if SY = OFSY then
                INSYMBOL
              else
                ERROR ( 8 ) ;
              FSTPTR := NIL ;

              (******************************************)
              (* four labels are generated in both      *)
              (* cases (new = portable and old):        *)
              (* lbnd = lower bound                     *)
              (* ubnd = upper bound                     *)
              (* lcix = begin of branch table           *)
              (* laddr = default addr                   *)
              (******************************************)

              GENLABEL ( LBND ) ;
              GENLABEL ( UBND ) ;
              GENLABEL ( LCIX ) ;
              GENLABEL ( LADDR ) ;
              GENLABEL ( XADDR ) ;

              (*****************************************)
              (*XJP - if new, to LCIX, if old, to LBND *)
              (*****************************************)

              if not PORTABLE_BRANCHTABLE then
                GENUJPFJP ( 44 , LBND )
              else
                GENUJPFJP ( 44 , LCIX ) ;
              OTHWC := FALSE ;
              FIRSTLN := LINECNT ;
              CTRCASES := 0 ;
              repeat
                LPT3 := NIL ;
                GENLABEL ( LCIX1 ) ;
                if not ( SY in [ SEMICOLON , ENDSY ] ) then
                  begin
                    if SY <> OTHERWISESY then
                      begin
                        repeat

              /*****************************/
              /* first case label constant */
              /*****************************/

                          CONSTANT ( FSYS + [ COMMA , COLON , DOTDOT ]
                                     , LSP1 , LVAL1 ) ;
                          if LSP <> NIL then
                            if COMPTYPES ( LSP , LSP1 ) = 1 then
                              begin
                                LVAL2 := LVAL1 ;
                                if SY = DOTDOT then
                                  begin

              /********************************/
              /* second constant after dotdot */
              /********************************/

                                    INSYMBOL ;
                                    CONSTANT ( FSYS + [ COMMA , COLON ]
                                               , LSP1 , LVAL2 )
                                  end (* then *) ;
                                if COMPTYPES ( LSP , LSP1 ) = 1 then
                                  if LVAL2 . IVAL >= LVAL1 . IVAL then
                                    begin

              /**********************************/
              /* check if new constants overlap */
              /* with existing constants        */
              /* and look for the right place   */
              /* to insert new element          */
              /**********************************/

                                      LPT1 := FSTPTR ;
                                      LPT2 := NIL ;
                                      while LPT1 <> NIL do
                                        with LPT1 -> do
                                          begin
                                            if LVAL2 . IVAL >= CSLAB2 .
                                            IVAL then
                                              begin
                                                if LVAL1 . IVAL <=
                                                CSLAB2 . IVAL then
                                                  ERROR ( 156 ) ;
                                                break ;
                                              end (* then *) ;
                                            LPT2 := LPT1 ;
                                            LPT1 := NEXT
                                          end (* with *) ;
                                      NEW ( LPT3 ) ;
                                      with LPT3 -> do
                                        begin
                                          NEXT := LPT1 ;
                                          CSLAB1 := LVAL1 ;
                                          CSLAB2 := LVAL2 ;
                                          HEXORBIN := 'N' ;
                                          if CSLAB1 . STRTYPE in [ 'B'
                                          , 'X' ] then
                                            HEXORBIN := 'T' ;
                                          if CSLAB2 . STRTYPE in [ 'B'
                                          , 'X' ] then
                                            if HEXORBIN = 'T' then
                                              HEXORBIN := 'J'
                                            else
                                              HEXORBIN := 'T' ;
                                          if FALSE then
                                            WRITELN ( TRACEF , 'case: '
                                                   , CSLAB1 . IVAL : 4
                                                   , CSLAB2 . IVAL : 4
                                                   , CSLAB1 . STRTYPE :
                                                   2 , CSLAB2 . STRTYPE
                                                   : 2 , HEXORBIN : 2 )
                                                   ;
                                          CSSTART := LCIX1
                                        end (* with *) ;
                                      if LPT2 = NIL then
                                        FSTPTR := LPT3
                                      else
                                        LPT2 -> . NEXT := LPT3
                                    end (* then *)
                                  else
                                    ERROR ( 102 )
                                else
                                  ERROR ( 147 ) ;
                              end (* then *)
                            else
                              ERROR ( 147 ) ;
                          TEST := SY <> COMMA ;
                          if not TEST then
                            INSYMBOL
                        until TEST ;
                        if SY = COLON then
                          INSYMBOL
                        else
                          ERROR ( 5 )
                      end (* then *)
                    else

              (********************)
              (* SY = OTHERWISESY *)
              (********************)

                      begin
                        if OTHWC then
                          ERROR ( 156 )
                        else
                          LCIX1 := LADDR ;
                        OTHWC := TRUE ;
                        INSYMBOL ;
                        if SY = COLON then
                          INSYMBOL

              (********************)
              (* IGNORE : FOR NOW *)
              (********************)

                      end (* else *) ;
                    PUTLABEL ( LCIX1 ) ;
                    TEMPLN := LINECNT ;

              (********************)
              (*** COUNTER HERE ***)
              (********************)

                    CTRNO := CTRGEN ;
                    CTRCASES := CTRCASES + 1 ;
                    repeat
                      STATEMENT ( FSYS + [ SEMICOLON ] , LOOPC , SUBR )
                                  ;
                    until not ( SY in STATBEGSYS ) ;

              (********)
              (*UJP   *)
              (********)

                    GENUJPFJP ( 57 , XADDR ) ;
                    CTREMIT ( CTRCASE , CTRNO , TEMPLN , 0 , LINECNT )
                              ;
                  end (* then *) ;
                TEST := SY <> SEMICOLON ;
                if not TEST then
                  INSYMBOL ;
              until TEST ;
              if FSTPTR <> NIL then
                begin
                  LMAX := FSTPTR -> . CSLAB2 . IVAL ;

              (******************)
              (*REVERSE POINTERS*)
              (******************)

                  LPT1 := FSTPTR ;
                  FSTPTR := NIL ;
                  repeat
                    LPT2 := LPT1 -> . NEXT ;
                    LPT1 -> . NEXT := FSTPTR ;
                    FSTPTR := LPT1 ;
                    LPT1 := LPT2
                  until LPT1 = NIL ;
                  LMIN := FSTPTR -> . CSLAB1 . IVAL ;
                end (* then *)
              else
                begin
                  LMIN := 1 ;
                  LMAX := 0 ;
                end (* else *) ;

              /*************************************/
              /* portable branch table: no need    */
              /* for LBND / UBND constants ...     */
              /* LBND and UBND are derived from    */
              /* constants in the branch table,    */
              /* but in pass 2                     */
              /*************************************/

              if not PORTABLE_BRANCHTABLE then
                begin
                  if LSP = CHARPTR then
                    begin
                      GENDEF ( LBND , 'C' , LMIN ) ;
                      GENDEF ( UBND , 'C' , LMAX ) ;
                    end (* then *)
                  else
                    begin
                      GENDEF ( LBND , 'I' , LMIN ) ;
                      GENDEF ( UBND , 'I' , LMAX ) ;
                    end (* else *)
                end (* then *) ;
              PUTLABEL ( LCIX ) ;
              if LMAX - LMIN < CIXMAX then
                begin
                  if FSTPTR <> NIL then
                    repeat
                      with FSTPTR -> do
                        begin
                          while CSLAB1 . IVAL > LMIN do
                            begin

              /*************************************/
              /* portable branch table: dont build */
              /* ujp for undefined cases (= holes) */
              /* opp - 11.2016                     */
              /*************************************/

                              if not PORTABLE_BRANCHTABLE then
                                GENUJPFJP ( 57 , LADDR ) ;
                              LMIN := LMIN + 1
                            end (* while *) ;
                          repeat

              /*************************************/
              /* portable branch table: build      */
              /* defines for the constants         */
              /* together with the ujps            */
              /* opp - 11.2016                     */
              /*************************************/

                            if PORTABLE_BRANCHTABLE then
                              begin
                                if ( LSP = CHARPTR ) and ( HEXORBIN =
                                'N' ) then
                                  GENDEF ( 0 , 'C' , LMIN )
                                else
                                  GENDEF ( 0 , 'I' , LMIN )
                              end (* then *) ;

              /*************************************/
              /* like before: build ujps to        */
              /* fill the branch table             */
              /*************************************/

                            GENUJPFJP ( 57 , CSSTART ) ;
                            LMIN := LMIN + 1 ;
                          until LMIN > CSLAB2 . IVAL ;
                          FSTPTR := NEXT ;
                        end (* with *)
                    until FSTPTR = NIL ;
                  if not OTHWC then
                    PUTLABEL ( LADDR ) ;
                  PUTLABEL ( XADDR ) ;
                  CTREMIT ( CTRCASE , 0 , FIRSTLN , CTRCASES , LINECNT
                            ) ;
                end (* then *)
              else
                ERROR ( 157 ) ;
              if SY = ENDSY then
                INSYMBOL
              else
                ERROR ( 13 )
            end (* CASESTATEMENT *) ;


         procedure BREAKSTATEMENT ;

            begin (* BREAKSTATEMENT *)
              if LOOPC . LEVEL <= 0 then
                ERROR ( 70 )
              else
                begin
                  GENUJPFJP ( 57 , LOOPC . BREAKLABEL ) ;
                  LOOPC . BREAKUSED := TRUE ;
                end (* else *)
            end (* BREAKSTATEMENT *) ;


         procedure CONTSTATEMENT ;

            begin (* CONTSTATEMENT *)
              if LOOPC . LEVEL <= 0 then
                ERROR ( 71 )
              else
                begin
                  GENUJPFJP ( 57 , LOOPC . CONTLABEL ) ;
                  LOOPC . CONTUSED := TRUE ;
                end (* else *)
            end (* CONTSTATEMENT *) ;


         procedure RETURNSTATEMENT ;

            begin (* RETURNSTATEMENT *)
              GENUJPFJP ( 57 , SUBR . RETURNLABEL ) ;
              SUBR . RETURNUSED := TRUE ;
            end (* RETURNSTATEMENT *) ;


         procedure REPEATSTATEMENT ;

            var LADDR : LABELRNG ;
                LEXIT : LABELRNG ;
                LCONT : LABELRNG ;
                FIRSTLN : INTEGER ;
                CTRNO : CTRRANGE ;
                LOOPR : LOOPCTL ;

            begin (* REPEATSTATEMENT *)
              GENLABEL ( LADDR ) ;
              GENLABEL ( LCONT ) ;
              GENLABEL ( LEXIT ) ;
              PUTLABEL ( LADDR ) ;
              LOOPR . LEVEL := LOOPC . LEVEL + 1 ;
              LOOPR . BREAKLABEL := LEXIT ;
              LOOPR . BREAKUSED := FALSE ;
              LOOPR . CONTLABEL := LCONT ;
              LOOPR . CONTUSED := FALSE ;
              FIRSTLN := LINECNT ;
              CTRNO := CTRGEN ;

              (********************)
              (*** COUNTER HERE ***)
              (********************)

              repeat
                repeat
                  STATEMENT ( FSYS + [ SEMICOLON , UNTILSY ] , LOOPR ,
                              SUBR ) ;
                until not ( SY in STATBEGSYS ) ;
                TEST := SY <> SEMICOLON ;
                if not TEST then
                  INSYMBOL
              until TEST ;
              if SY = UNTILSY then
                begin
                  if LOOPR . CONTUSED then
                    PUTLABEL ( LCONT ) ;
                  INSYMBOL ;
                  EXPRESSION ( FSYS ) ;
                  GENFJP ( LADDR ) ;
                  if LOOPR . BREAKUSED then
                    PUTLABEL ( LEXIT ) ;
                  CTREMIT ( CTRREPEAT , CTRNO , FIRSTLN , 0 , LINECNT )
                end (* then *)
              else
                ERROR ( 53 ) ;
            end (* REPEATSTATEMENT *) ;


         procedure WHILESTATEMENT ;

            var LADDR , LCIX : LABELRNG ;
                FIRSTLN : INTEGER ;
                CTRNO : CTRRANGE ;
                LOOPW : LOOPCTL ;

            begin (* WHILESTATEMENT *)
              GENLABEL ( LADDR ) ;
              GENLABEL ( LCIX ) ;
              LOOPW . LEVEL := LOOPC . LEVEL + 1 ;
              LOOPW . BREAKLABEL := LCIX ;
              LOOPW . BREAKUSED := FALSE ;
              LOOPW . CONTLABEL := LADDR ;
              LOOPW . CONTUSED := FALSE ;
              PUTLABEL ( LADDR ) ;
              EXPRESSION ( FSYS + [ DOSY ] ) ;
              GENFJP ( LCIX ) ;
              if SY = DOSY then
                INSYMBOL
              else
                ERROR ( 54 ) ;
              FIRSTLN := LINECNT ;
              CTRNO := CTRGEN ;

              (********************)
              (*** COUNTER HERE ***)
              (********************)

              STATEMENT ( FSYS , LOOPW , SUBR ) ;

              (********)
              (*UJP   *)
              (********)

              GENUJPFJP ( 57 , LADDR ) ;
              PUTLABEL ( LCIX ) ;
              CTREMIT ( CTRWHILE , CTRNO , FIRSTLN , 0 , LINECNT ) ;
            end (* WHILESTATEMENT *) ;


         procedure FORSTATEMENT ;

            var LATTR : ATTR ;
                LSP : TTP ;
                LSY : SYMBOL ;
                LOP : OPRANGE ;
                XT , CV1 , CV2 : INTEGER ;
                CB1 , CB2 : BOOLEAN ;
                LCIX , LADDR , LINCR : LABELRNG ;
                LLC : ADDRRANGE ;
                FIRSTLN : INTEGER ;
                CTRNO : CTRRANGE ;
                LOOPF : LOOPCTL ;

            begin (* FORSTATEMENT *)
              if SY = IDENT then
                begin
                  DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE , [ VARS ] ,
                               LCP ) ;
                  with LCP -> , LATTR do
                    begin
                      TYPTR := IDTYPE ;
                      KIND := VARBL ;
                      BTYPE := TYPTR ;
                      if TYPTR <> NIL then
                        if TYPTR -> . FORM = SUBRANGE then
                          TYPTR := TYPTR -> . RANGETYPE ;
                      if VKIND = ACTUAL then
                        begin
                          if STKLASS = XAUTO then
                            begin
                              ACCESS := DRCT ;
                              VLEVEL := VLEV ;
                              DPLMT := VADDR ;
                            end (* then *)
                          else
                            begin

              /**********************************/
              /* zunaechst compiler restriction */
              /**********************************/

                              ERROR ( 398 ) ;
                              TYPTR := NIL
                            end (* else *)
                        end (* then *)
                      else
                        begin
                          ERROR ( 155 ) ;
                          TYPTR := NIL
                        end (* else *)
                    end (* with *) ;
                  if LATTR . TYPTR <> NIL then
                    if ( LATTR . TYPTR -> . FORM > SUBRANGE ) or (
                    LATTR . TYPTR = REALPTR ) then
                      begin
                        ERROR ( 143 ) ;
                        LATTR . TYPTR := NIL
                      end (* then *) ;
                  INSYMBOL
                end (* then *)
              else
                begin
                  ERROR ( 2 ) ;
                  LATTR . TYPTR := NIL ;
                  SKIP ( FSYS + [ BECOMES , TOSY , DOWNTOSY , DOSY ] )
                end (* else *) ;
              if SY = BECOMES then
                begin
                  INSYMBOL ;
                  EXPRESSION ( FSYS + [ TOSY , DOWNTOSY , DOSY ] ) ;
                  if GATTR . TYPTR <> NIL then
                    if GATTR . TYPTR -> . FORM <> SCALAR then
                      ERROR ( 144 )
                    else
                      if COMPTYPES ( LATTR . TYPTR , GATTR . TYPTR ) =
                      1 then
                        begin
                          if GATTR . KIND = CST then
                            begin
                              CB1 := TRUE ;
                              CV1 := GATTR . CVAL . IVAL
                            end (* then *)
                          else
                            CB1 := FALSE ;
                          LOAD ;
                          STORE ( LATTR ) ;
                        end (* then *)
                      else
                        ERROR ( 145 )
                end (* then *)
              else
                begin
                  ERROR ( 51 ) ;
                  SKIP ( FSYS + [ TOSY , DOWNTOSY , DOSY ] )
                end (* else *) ;
              if ( SY = TOSY ) or ( SY = DOWNTOSY ) then
                begin
                  LSY := SY ;
                  INSYMBOL ;
                  EXPRESSION ( FSYS + [ DOSY ] ) ;
                  if GATTR . TYPTR <> NIL then
                    if GATTR . TYPTR -> . FORM <> SCALAR then
                      ERROR ( 144 )
                    else
                      if COMPTYPES ( LATTR . TYPTR , GATTR . TYPTR ) =
                      1 then
                        begin
                          if GATTR . KIND = CST then
                            begin
                              CB2 := TRUE ;
                              LLC := LCOUNTER ;
                              CV2 := GATTR . CVAL . IVAL
                            end (* then *)
                          else
                            begin
                              CB2 := FALSE ;
                              LOAD ;
                              ALIGN ( LCOUNTER , INTSIZE ) ;
                              LLC := LCOUNTER ;
                              if GATTR . TYPTR <> INTPTR then

              (********)
              (*ORD   *)
              (********)

                                GEN0 ( 61 ) ;

              (********)
              (*STR   *)
              (********)

                              GEN3 ( 56 , ORD ( 'I' ) , LEVEL , LLC ) ;
                              LCOUNTER := LCOUNTER + INTSIZE ;
                              if LCOUNTER > LCMAX then
                                LCMAX := LCOUNTER ;
                            end (* else *) ;
                          if CB1 and CB2 then
                            begin
                              XT := 1 ;
                              if LSY = TOSY then
                                if CV1 > CV2 then
                                  XT := 0
                                else
                                  
                              else
                                if CV1 < CV2 then
                                  XT := 0 ;

              (********)
              (*LDC   *)
              (********)

                              GEN2 ( 51 , 3 , XT ) ;
                            end (* then *)
                          else
                            begin
                              if CB1 then

              (********)
              (*LDC   *)
              (********)

                                GEN2 ( 51 , 1 , CV1 )
                              else
                                begin
                                  GATTR := LATTR ;
                                  LOAD ;
                                  if GATTR . TYPTR <> INTPTR then

              (********)
              (*ORD   *)
              (********)

                                    GEN0 ( 61 ) ;
                                end (* else *) ;
                              if CB2 then
                                begin

              (********)
              (*LDC   *)
              (********)

                                  GATTR := LATTR ;
                                  if GATTR . TYPTR = CHARPTR then
                                    begin
                                      GEN2 ( 51 , 0 , CV2 ) ;
                                      GEN0 ( 61 )
                                    end (* then *)
                                  else
                                    GEN2 ( 51 , 1 , CV2 )
                                end (* then *)
                              else

              (********)
              (*LOD   *)
              (********)

                                GEN3 ( 54 , ORD ( 'I' ) , LEVEL , LLC )
                                       ;
                              if LSY = TOSY then
                                LOP := 52
                              else
                                LOP := 48 ;
                              GEN2 ( LOP , ORD ( 'I' ) , 1 ) ;
                            end (* else *) ;
                        end (* then *)
                      else
                        ERROR ( 145 )
                end (* then *)
              else
                begin
                  ERROR ( 55 ) ;
                  SKIP ( FSYS + [ DOSY ] )
                end (* else *) ;
              GENLABEL ( LADDR ) ;
              GENLABEL ( LINCR ) ;
              GENLABEL ( LCIX ) ;
              LOOPF . LEVEL := LOOPC . LEVEL + 1 ;
              LOOPF . BREAKLABEL := LCIX ;
              LOOPF . BREAKUSED := FALSE ;
              LOOPF . CONTLABEL := LINCR ;
              LOOPF . CONTUSED := FALSE ;

              (********)
              (*FJP   *)
              (********)

              GENUJPFJP ( 33 , LCIX ) ;
              PUTLABEL ( LADDR ) ;

              (***********************************)
              (*   BEGINNING OF THE FOR 'LOOP'   *)
              (***********************************)

              if SY = DOSY then
                INSYMBOL
              else
                ERROR ( 54 ) ;
              FIRSTLN := LINECNT ;
              CTRNO := CTRGEN ;

              (********************)
              (*** COUNTER HERE ***)
              (********************)

              STATEMENT ( FSYS , LOOPF , SUBR ) ;
              if LOOPF . CONTUSED then
                PUTLABEL ( LINCR ) ;
              GATTR := LATTR ;
              LOAD ;
              if GATTR . TYPTR <> INTPTR then

              (********)
              (*ORD   *)
              (********)

                GEN0 ( 61 ) ;
              if CB2 then
                begin
                  GATTR := LATTR ;
                  if GATTR . TYPTR = CHARPTR then
                    begin
                      GEN2 ( 51 , 0 , CV2 ) ;
                      GEN0 ( 61 )
                    end (* then *)
                  else

              (********)
              (*LDC   *)
              (********)

                    GEN2 ( 51 , 1 , CV2 )
                end (* then *)
              else

              (********)
              (*LOD   *)
              (********)

                GEN3 ( 54 , ORD ( 'I' ) , LEVEL , LLC ) ;

              (********)
              (*NEQ   *)
              (********)

              GEN2 ( 55 , ORD ( 'I' ) , 1 ) ;

              (********)
              (*FJP   *)
              (********)

              GENUJPFJP ( 33 , LCIX ) ;
              GATTR := LATTR ;
              LOAD ;
              LOP := 23 ;

              (********)
              (*INC   *)
              (********)

              if LSY <> TOSY then
                LOP := 22 ;

              (********)
              (*DEC   *)
              (********)

              GEN2 ( LOP , GETTYPE ( GATTR . TYPTR ) , 1 ) ;
              if DEBUG then
                CHKBNDS ( LATTR . TYPTR ) ;
              STORE ( LATTR ) ;

              (********)
              (*UJP   *)
              (********)

              GENUJPFJP ( 57 , LADDR ) ;
              PUTLABEL ( LCIX ) ;
              LCOUNTER := LLC ;
              CTREMIT ( CTRFOR , CTRNO , FIRSTLN , 0 , LINECNT ) ;
            end (* FORSTATEMENT *) ;


         procedure WITHSTATEMENT ;

            var LCP : IDP ;
                LCNT : DISPRANGE ;
                LLC : ADDRRANGE ;
                OLD_LEV : - 1 .. DISPLIMIT ;
                REC_STR : TTP ;

            begin (* WITHSTATEMENT *)
              LLC := LCOUNTER ;
              if GET_STAT then
                WS_CNT := WS_CNT + 1 ;
              if SY = IDENT then
                begin
                  DUMMYBOOL := SEARCHID ( ID , TRUE , TRUE , [ VARS ,
                               FIELD ] , LCP ) ;
                  INSYMBOL
                end (* then *)
              else
                begin
                  ERROR ( 2 ) ;
                  LCP := UVARPTR
                end (* else *) ;
              SELECTOR ( FSYS + [ COMMA , DOSY ] , LCP ) ;
              REC_STR := GATTR . TYPTR ;
              if GATTR . TYPTR <> NIL then
                if GATTR . TYPTR -> . FORM = RECORDS then
                  if TOP < DISPLIMIT then
                    begin
                      TOP := TOP + 1 ;
                      with DISPLAY [ TOP ] do
                        begin
                          OLD_LEV := REC_STR -> . FLD_DISP_LEV ;
                          REC_STR -> . FLD_DISP_LEV := TOP ;
                          if GATTR . ACCESS = DRCT then
                            begin
                              OCCUR := CREC ;
                              CLEV := GATTR . VLEVEL ;
                              CDSPL := GATTR . DPLMT
                            end (* then *)
                          else
                            begin
                              LOADADDRESS ;
                              ALIGN ( LCOUNTER , PTRSIZE ) ;

              (********)
              (*STR   *)
              (********)

                              GEN3 ( 56 , ORD ( 'A' ) , LEVEL ,
                                     LCOUNTER ) ;
                              OCCUR := VREC ;
                              VDSPL := LCOUNTER ;
                              LCOUNTER := LCOUNTER + PTRSIZE ;
                              if LCOUNTER > LCMAX then
                                LCMAX := LCOUNTER
                            end (* else *)
                        end (* with *)
                    end (* then *)
                  else
                    FATALERROR ( 250 )
                else
                  begin
                    ERROR ( 140 ) ;
                    REC_STR := NIL
                  end (* else *) ;
              OPEN_RECORD := REC_STR ;
              if SY = COMMA then
                begin
                  INSYMBOL ;
                  WITHSTATEMENT
                end (* then *)
              else
                begin
                  if SY = DOSY then
                    INSYMBOL
                  else
                    ERROR ( 54 ) ;
                  STATEMENT ( FSYS , LOOPC , SUBR ) ;
                end (* else *) ;
              if REC_STR <> NIL then
                REC_STR -> . FLD_DISP_LEV := OLD_LEV ;
              TOP := TOP - 1 ;
              LCOUNTER := LLC ;
              OPEN_RECORD := NIL ;
            end (* WITHSTATEMENT *) ;


         begin (* STATEMENT *)
           if SY = INTCONST then

           (********)
           (*LABEL *)
           (********)

             begin
               LLP := DISPLAY [ LEVEL ] . FLABEL ;
               while LLP <> NIL do
                 with LLP -> do
                   if LABVAL = VAL . IVAL then
                     begin
                       if DEFINED then
                         ERROR ( 165 ) ;
                       if XNO > 0 then

           (***********************************)
           (* LABEL IS AN EXTERNAL ENTRY PT.  *)
           (***********************************)

                         begin
                           XLABEL := '############' ;
                           MKNAME ( XLABEL , XNO , FALSE ) ;
                           if PRCODE then
                             WRITELN ( PRR , XLABEL : EXTNAMSZ , MN [
                                       74 ] ) ;
                           XNO := 0 ;

           (***************************)
           (* IN CASE OF REDEFINITION *)
           (***************************)

                         end (* then *) ;
                       PUTLABEL ( LABNAME ) ;
                       DEFINED := TRUE ;
                       CTRNO := CTRGEN ;
                       CTREMIT ( CTRLBL , CTRNO , LINECNT , 0 , LINECNT
                                 ) ;

           (********************)
           (*** COUNTER HERE ***)
           (********************)

                       goto 1
                     end (* then *)
                   else
                     LLP := NEXTLAB ;
               ERROR ( 167 ) ;
               1 :
               INSYMBOL ;
               if SY = COLON then
                 INSYMBOL
               else
                 ERROR ( 5 )
             end (* then *) ;
           if not ( SY in FSYS + [ IDENT ] ) then
             begin
               ERROR ( 6 ) ;
               SKIP ( FSYS )
             end (* then *) ;
           if SY in STATBEGSYS + [ IDENT ] then
             begin
               case SY of
                 IDENT : begin
                           IDFOUND := SEARCHID ( ID , FALSE , FALSE , [
                                      VARS , FIELD , FUNC , PROC ] ,
                                      LCP ) ;
                           STARTID := ID ;
                           CHCNT_SAVE := CHCNT ;
                           INSYMBOL ;
                           CHCNT_SAVE2 := CHCNT ;

           /*************************************************/
           /* add id of appropriate class                   */
           /* to prevent more errors in case of notfound    */
           /* special error code, if undecl. procedure      */
           /*************************************************/

                           if not IDFOUND then
                             if SY in PROCCALLENDSYS then
                               begin
                                 CHCNT := CHCNT_SAVE ;
                                 ERRKIND := 'W' ;
                                 ERROR ( 184 ) ;
                                 DUMMYBOOL := SEARCHID ( STARTID ,
                                              FALSE , TRUE , [ PROC ] ,
                                              LCP ) ;
                                 LCP -> . DECLMISSING := TRUE ;
                                 LCP -> . EXTRN := TRUE ;
                                 PACK ( STARTID , 1 , LCP -> . EXTNAME
                                        ) ;
                               end (* then *)
                             else
                               begin
                                 CHCNT := CHCNT_SAVE ;
                                 ERROR ( 104 ) ;
                                 DUMMYBOOL := SEARCHID ( STARTID ,
                                              FALSE , TRUE , [ VARS ] ,
                                              LCP )
                               end (* else *) ;
                           CHCNT := CHCNT_SAVE2 ;

           /*************************************************/
           /* end of special error handling                 */
           /* after first id of statement                   */
           /*************************************************/

                           if LCP -> . KLASS = PROC then
                             begin
                               CALL ( FSYS , LCP )
                             end (* then *)
                           else
                             begin
                               ASSIGNMENT ( LCP )
                             end (* else *)
                         end (* tag/ca *) ;
                 BEGINSY :
                   begin
                     STMTNEST := STMTNEST + 1 ;
                     INSYMBOL ;
                     COMPOUNDSTATEMENT ;
                     STMTNEST := STMTNEST - 1 ;
                   end (* tag/ca *) ;
                 GOTOSY :
                   begin
                     INSYMBOL ;
                     GOTOSTATEMENT
                   end (* tag/ca *) ;
                 IFSY : begin
                          INSYMBOL ;
                          IFSTATEMENT
                        end (* tag/ca *) ;
                 CASESY :
                   begin
                     STMTNEST := STMTNEST + 1 ;
                     INSYMBOL ;
                     CASESTATEMENT ;
                     STMTNEST := STMTNEST - 1
                   end (* tag/ca *) ;
                 WHILESY :
                   begin
                     INSYMBOL ;
                     WHILESTATEMENT
                   end (* tag/ca *) ;
                 REPEATSY :
                   begin
                     STMTNEST := STMTNEST + 1 ;
                     INSYMBOL ;
                     REPEATSTATEMENT ;
                     STMTNEST := STMTNEST - 1
                   end (* tag/ca *) ;
                 FORSY : begin
                           INSYMBOL ;
                           FORSTATEMENT
                         end (* tag/ca *) ;
                 BREAKSY :
                   begin
                     INSYMBOL ;
                     BREAKSTATEMENT
                   end (* tag/ca *) ;
                 CONTINUESY :
                   begin
                     INSYMBOL ;
                     CONTSTATEMENT
                   end (* tag/ca *) ;
                 RETURNSY :
                   begin
                     INSYMBOL ;
                     RETURNSTATEMENT
                   end (* tag/ca *) ;
                 WITHSY :
                   begin
                     INSYMBOL ;
                     WITHSTATEMENT
                   end (* tag/ca *)
               end (* case *) ;
               if not ( SY in [ SEMICOLON , ENDSY , ELSESY , UNTILSY ]
               ) then
                 begin
                   ERROR ( 6 ) ;
                   SKIP ( FSYS )
                 end (* then *)
             end (* then *)
         end (* STATEMENT *) ;


      procedure FRTPARMS ;

      (*********************************)
      (* THIS BORING PROCEDURE         *)
      (* GENERATES DUMMY ROUTINES      *)
      (* TO REPLACE FORTRAN ROUTINES   *)
      (* PASSED AS PROC. PARAMETERS    *)
      (*********************************)


         var PT , LOCPAR : INTEGER ;
             LLC , LCM : ADDRRANGE ;
             LCP1 : IDP ;
             FNAME : ALPHA ;

         begin (* FRTPARMS *)
           LEVEL := LEVEL + 1 ;
           OLDICOUNTER := ICOUNTER ;
           while FRTPARHD <> NIL do
             with FRTPARHD -> do
               begin
                 ICOUNTER := 0 ;
                 FRTRN := FALSE ;
                 PT := PROCTYPE ( FRTPARHD ) ;
                 FNAME := NAME ;
                 MKPROCNAME ( FNAME , NAME_PATTERN , PFNAME , TRUE ) ;

           (********)
           (*ENT   *)
           (********)

                 WRITE ( PRR , FNAME : 8 , MN [ 32 ] , CHR ( PT ) : 2 ,
                         ',' , LEVEL : 1 , ',L' , SEGSIZE : 1 , NAME :
                         IDLNGTH + 2 , ',' , SAVEREGS : 1 , ',' ,
                         ASSEMBLE : 1 , ',' , GET_STAT : 1 , ',' ,
                         ASMVERB : 1 , ',' , DEBUG_LEV : 1 , ',' ,
                         PFNAME : 1 , ',,' ) ;
                 if DEBUG_LEV > 0 then
                   begin
                     WRITE ( PRR , SOURCENAME ) ;
                   end (* then *) ;
                 WRITELN ( PRR ) ;
                 WRITELN ( DBGINFO , '#BGN    ' , NAME , ' ' , LEVEL :
                           4 ) ;
                 LCP1 := PRMPTR ;
                 LCOUNTER := LCAFTMST + FPSAVEAREA ;
                 while LCP1 <> NIL do
                   with LCP1 -> do
                     begin
                       if KLASS = VARS then
                         if IDTYPE <> NIL then
                           begin
                             if VKIND = FORMAL then
                               LCM := VADDR + PTRSIZE
                             else
                               LCM := VADDR + IDTYPE -> . SIZE ;
                             if LCM > LCOUNTER then
                               LCOUNTER := LCM ;
                           end (* then *) ;
                       LCP1 := NEXT
                     end (* with *) ;
                 ALIGN ( LCOUNTER , PTRSIZE ) ;
                 LLC := LCOUNTER ;
                 LCP1 := PRMPTR ;
                 while LCP1 <> NIL do
                   with LCP1 -> do
                     begin
                       if KLASS = VARS then
                         if IDTYPE <> NIL then
                           begin
                             if VKIND = FORMAL then

           (********)
           (*LOD   *)
           (********)

                               GEN3 ( 54 , ORD ( 'A' ) , LEVEL , VADDR
                                      )
                             else

           (********)
           (*LDA   *)
           (********)

                               GEN2 ( 50 , LEVEL , VADDR ) ;

           (********)
           (*STR   *)
           (********)

                             GEN3 ( 56 , ORD ( 'A' ) , LEVEL , LLC ) ;
                             LLC := LLC + PTRSIZE ;
                           end (* then *) ;
                       LCP1 := NEXT ;
                     end (* with *) ;
                 FRTRN := TRUE ;
                 LOCPAR := ( LLC - LCOUNTER ) DIV 2 + 1 ;
                 PUTIC ;

           (********)
           (*CUP   *)
           (********)

                 WRITELN ( PRR , MN [ 46 ] , CHR ( PROCTYPE ( FRTPARHD
                           ) ) : 2 , ',' , LOCPAR : 1 , ',' , EXTNAME ,
                           ',' , LCOUNTER : 1 ) ;
                 if KLASS = FUNC then

           (********)
           (*STR   *)
           (********)

                   GEN3 ( 56 , PT , LEVEL , FNCRSLT ) ;

           (********)
           (*RET   *)
           (********)

                 GEN1 ( 42 , PT ) ;
                 GENDEF ( SEGSIZE , 'I' , LLC ) ;
                 WRITELN ( DBGINFO , '#PROC   ' , NAME : IDLNGTH , ' '
                           , PFNAME : 4 , ' ' , FALSE : 1 , ICOUNTER :
                           6 , LLC : 8 , ' ' , FALSE : 1 ) ;
                 WRITELN ( DBGINFO , '#VARS   ' , 'REF/MOD RATIO      '
                           , 0 : 6 , 0 : 6 , 0.0 : 10 : 6 ) ;
                 WRITELN ( DBGINFO , '#END' ) ;
                 OLDICOUNTER := OLDICOUNTER + ICOUNTER ;
                 FRTPARHD := NXTFWRD ;
               end (* with *) ;
           LEVEL := LEVEL - 1 ;
           ICOUNTER := OLDICOUNTER ;
         end (* FRTPARMS *) ;


      begin (* BODY *)
        STMTNEST := 1 ;
        LISTTAG := 'N' ;
        PUTIC ;
        if FPROCP = MAINPROG then

        (********)
        (*BGN   *)
        (********)

          WRITELN ( PRR , MN [ 72 ] , ' ' , PROGNAME , ' ' , TIME : 8 ,
                    ' ' , DATE ) ;

        (********)
        (*ENT   *)
        (********)

        WRITE ( PRR , FPROCP -> . EXTNAME , MN [ 32 ] , CHR ( PROCTYPE
                ( FPROCP ) ) : 2 , ',' , LEVEL : 1 , ',L' , SEGSIZE : 1
                , FPROCP -> . NAME : IDLNGTH + 2 , ',' , SAVEREGS : 1 ,
                ',' , ASSEMBLE : 1 , ',' , GET_STAT : 1 , ',' , ASMVERB
                : 1 , ',' , DEBUG_LEV : 1 , ',' : 1 , FPROCP -> .
                PFNAME : 1 , ',' ) ;
        if STATIC_VORHANDEN then
          begin
            CSTEXTNAME := FPROCP -> . CSTNAME ;
            WRITE ( PRR , CSTEXTNAME ) ;
          end (* then *) ;
        WRITE ( PRR , ',' ) ;
        if DEBUG_LEV > 0 then
          begin
            WRITE ( PRR , SOURCENAME ) ;
          end (* then *) ;
        WRITELN ( PRR ) ;
        ICOUNTER := ICOUNTER + 1 ;
        STRCOUNTER := 0 ;

        (******************************)
        (* LENGTH OF STRING CONSTANTS *)
        (******************************)

        LOCAL_CALL := FALSE ;
        VAR_REF := 0 ;
        VAR_MOD := 0 ;
        WRITELN ( DBGINFO , '#BGN    ' , FPROCP -> . NAME , ' ' , LEVEL
                  : 4 ) ;
        if FPROCP = MAINPROG then

        (**********************************************************)
        (* ENTERING MAIN BLOCK                                    *)
        (* this is where the implicit resets and rewrites for     *)
        (* the default files are generated; I decided in 2016     *)
        (* to remove the default reset for input and instead      *)
        (* to do the reset on the first read call                 *)
        (* - bernd oppolzer                                       *)
        (* some days later I removed the implicit rewrites        *)
        (* for the other predefined files, too, because           *)
        (* rewrite is now implicitly done at the first write      *)
        (* action by the pascal runtime.                          *)
        (* there is one problem with removing the reset for       *)
        (* input, because eof(input) is true before the reset     *)
        (* occured, and some programs (including the compiler)    *)
        (* have a problem with this. no problem for output files. *)
        (**********************************************************)

          begin
            while FILEHEAD <> NIL do
              begin
                with FILEHEAD -> do
                  begin

        /***********************************************************/
        /* input ueberlesen mithilfe neuer continue-anweisung :-)  */
        /* das war: if FILIDPTR = INPUTPTR then                    */
        /* jetzt aber: alle standard-files ueberlesen.             */
        /***********************************************************/

                    if FILIDPTR -> . VADDR < FIRSTGVAR then
                      begin
                        FILEHEAD := FILEHEAD -> . NEXTFILE ;
                        continue
                      end (* then *) ;

        (**************************)
        (* 3 = code for reset     *)
        (* 4 = code for rewrite   *)
        (**************************)

                    with FILIDPTR -> do
                      begin

        (********)
        (*LDA   *)
        (********)

                        GEN2 ( 50 , 1 , VADDR ) ;
                        GEN1 ( 30 , ORD ( PSIO ) ) ;
                        if VADDR >= FIRSTGVAR then

        (**********************)
        (* USER DEFINED FILES *)
        (**********************)

                          begin
                            NEW ( DDNAME . SVAL ) ;
                            with DDNAME . SVAL -> do
                              begin
                                TAG := 'S' ;
                                LENGTH := 8 ;

        (****************)
        (*OS NAME LENGTH*)
        (****************)

                                for I := 1 to 8 do
                                  SSTR [ I ] := NAME [ I ] ;
                              end (* with *) ;
                            GEN_LCA_M ( DDNAME ) ;
                            LLC1 := 0 ;

        (*******************************)
        (* LENGTH CODE FOR A TEXT FILE *)
        (*******************************)

                            if COMPTYPES ( IDTYPE , TEXTPTR ) <> 1 then
                              if IDTYPE <> NIL then
                                if IDTYPE -> . FILTYPE <> NIL then
                                  LLC1 := IDTYPE -> . FILTYPE -> . SIZE
                                          ;

        (********)
        (*LDC   *)
        (********)

                            GEN2 ( 51 , 1 , LLC1 ) ;
                            GEN1 ( 30 , ORD ( PFDF ) ) ;
                          end (* then *)
                        else

        (******************************)
        (* I.E. IF VADDR < FIRSTUSERF *)
        (******************************)

                          begin
                            XCSP := PRES ;
                            if FILIDPTR = OUTPUTPTR then
                              XCSP := PREW
                            else
                              if NAME [ 3 ] = 'R' then
                                XCSP := PREW ;

        (*****************)
        (* CSP - RES/REW *)
        (*****************)

                            GEN1 ( 30 , ORD ( XCSP ) )
                          end (* else *) ;
                        GEN1 ( 30 , ORD ( PEIO ) ) ;
                      end (* with *) ;
                  end (* with *) ;
                FILEHEAD := FILEHEAD -> . NEXTFILE
              end (* while *) ;
            if CTROPTION then
              begin
                GENLABEL ( CTRCNTLBL ) ;

        (********)
        (*CTS   *)
        (********)

                GENUJPFJP ( 38 , CTRCNTLBL ) ;
              end (* then *) ;
          end (* then *) ;

        (*************************)
        (* PROCESSING MAIN BLOCK *)
        (*************************)

        FIRSTLN := LINECNT ;
        CTRNO := CTRGEN ;

        (********************)
        (*** COUNTER HERE ***)
        (********************)

        LCMAX := LCOUNTER ;
        LOOP0 . LEVEL := 0 ;
        LOOP0 . BREAKLABEL := 0 ;
        LOOP0 . BREAKUSED := FALSE ;
        LOOP0 . CONTLABEL := 0 ;
        LOOP0 . CONTUSED := FALSE ;
        GENLABEL ( LRETURN ) ;
        SUBR . RETURNLABEL := LRETURN ;
        SUBR . RETURNUSED := FALSE ;

        (***************************************************)
        (* COMPILE THE STATEMENTS WITHIN THIS BLOCK (BODY) *)
        (***************************************************)

        repeat
          repeat
            STATEMENT ( FSYS + [ SEMICOLON , ENDSY ] , LOOP0 , SUBR ) ;
          until not ( SY in STATBEGSYS ) ;
          TEST := SY <> SEMICOLON ;
          if not TEST then
            INSYMBOL
        until TEST ;
        if SY = ENDSY then
          INSYMBOL
        else
          ERROR ( 13 ) ;
        if SUBR . RETURNUSED then
          PUTLABEL ( LRETURN ) ;
        STMTNEST := 0 ;
        LISTTAG := ' ' ;
        LLP := DISPLAY [ TOP ] . FLABEL ;

        (*****************************)
        (* TEST FOR UNDEFINED LABELS *)
        (*****************************)

        while LLP <> NIL do
          with LLP -> do
            begin
              if not DEFINED then
                begin
                  PLCNT := PLCNT + 1 ;
                  WRITELN ( LISTING , '**** UNDEF. LABEL:' : 23 ,
                            LABVAL ) ;
                  ERROR ( 168 ) ;
                end (* then *) ;
              LLP := NEXTLAB
            end (* with *) ;
        CTREMIT ( CTRPROC , CTRNO , FIRSTLN , 0 , LINECNT ) ;
        if FPROCP = MAINPROG then

        (******************)
        (* RESET COUNTERS *)
        (******************)

          begin
            CTREMIT ( CTRPROC , 0 , 0 , 0 , 0 ) ;

        (*************************)
        (* EOF FOR COUNTER TABLE *)
        (*************************)

            if ODD ( CTRCNT ) then
              CTRCNT := CTRCNT + 1 ;
            if CTROPTION then
              GENDEF ( CTRCNTLBL , 'I' , CTRCNT ) ;
          end (* then *) ;

        (********)
        (*RET   *)
        (********)

        GEN1 ( 42 , PROCTYPE ( FPROCP ) ) ;
        ALIGN ( LCMAX , MXDATASZE ) ;
        if PRCODE then
          GENDEF ( SEGSIZE , 'I' , LCMAX ) ;
        CALL_LVL [ LOCAL_CALL ] := CALL_LVL [ LOCAL_CALL ] + 1 ;
        WRITELN ( DBGINFO , '#PROC   ' , FPROCP -> . NAME : IDLNGTH ,
                  ' ' , FPROCP -> . PFNAME : 4 , ' ' , LOCAL_CALL : 1 ,
                  ' ' , ICOUNTER + ( STRCOUNTER DIV 4 ) : 6 , ' ' ,
                  LCMAX : 8 , ' ' , FLIPDEBUG : 1 ) ;
        WRITE ( DBGINFO , '#VARS   ' , 'REF/MOD RATIO      ' , VAR_MOD
                : 6 , VAR_MOD + VAR_REF : 6 ) ;
        if ( VAR_MOD + VAR_REF ) = 0 then
          WRITELN ( DBGINFO , 0.0 : 10 : 6 )
        else
          WRITELN ( DBGINFO , VAR_MOD / ( VAR_MOD + VAR_REF ) : 10 : 6
                    ) ;
        WRITELN ( DBGINFO , '#END' ) ;
        OLDICOUNTER := OLDICOUNTER + ICOUNTER ;
        ICOUNTER := OLDICOUNTER ;

        (**************************)
        (* DISPLAY CUMULATIVE ICO *)
        (*UNTER                   *)
        (**************************)

        HP := TRUE ;
        if FRTPARHD <> NIL then
          FRTPARMS ;
        if FPROCP = MAINPROG then

        (********)
        (*STP   *)
        (********)

          GEN0 ( 43 ) ;
      end (* BODY *) ;


   begin (* BLOCK *)
     ICOUNTER := 0 ;
     GENLABEL ( SEGSIZE ) ;
     CONSTLCOUNTER := - 1 ;
     STATIC_VORHANDEN := FALSE ;
     FWRDPRCL := NIL ;
     DEC_ORDER := 0 ;
     repeat
       while SY in [ LABELSY , CONSTSY , TYPESY , VARSY , STATICSY ] do
         begin
           LSY := SY ;
           INSYMBOL ;
           case LSY of
             LABELSY :
               begin
                 LABELDECLARATION ;
                 if DEC_ORDER >= 1 then
                   EXTUSED := TRUE ;
                 DEC_ORDER := 1 ;
               end (* tag/ca *) ;
             CONSTSY :
               begin
                 CONSTDECLARATION ;
                 if DEC_ORDER >= 2 then
                   EXTUSED := TRUE ;
                 DEC_ORDER := 2 ;
               end (* tag/ca *) ;
             TYPESY :
               begin
                 TYPEDECLARATION ;
                 if DEC_ORDER >= 3 then
                   EXTUSED := TRUE ;
                 DEC_ORDER := 3 ;
               end (* tag/ca *) ;
             VARSY : begin
                       VARDECLARATION ;
                       if DEC_ORDER >= 4 then
                         EXTUSED := TRUE ;
                       DEC_ORDER := 4 ;
                     end (* tag/ca *) ;
             STATICSY :
               begin
                 STATICDECLARATION ;
                 EXTUSED := TRUE ;
                 DEC_ORDER := 5 ;
               end (* tag/ca *) ;
           end (* case *) ;
         end (* while *) ;
       if CONSTLCOUNTER >= 0 then

     (***********************************)
     (* A CONSTANTS BLOCK WAS GENERATED *)
     (***********************************)

         begin
           CONSTLCOUNTER := - 1 ;
           STATIC_VORHANDEN := TRUE ;
           WRITELN ( PRR , MN [ 75 ] ) ;
         end (* then *) ;
       if DEBUG_LEV > 0 then
         PRNTSYMBL ( NIL ) ;

     (**************************)
     (* PRINT HEAP TYPE DEFNS. *)
     (**************************)

       while SY in [ PROCSY , FUNCSY , LOCALSY ] do
         begin
           if SY = LOCALSY then
             begin
               INSYMBOL ;
               PLOCAL := TRUE ;
               if not ( SY in [ PROCSY , FUNCSY ] ) then
                 ERROR ( 6 ) ;
             end (* then *)
           else
             PLOCAL := FALSE ;
           LSY := SY ;
           INSYMBOL ;
           PROCDECLARATION ( LSY , PLOCAL )
         end (* while *) ;
       if SY <> BEGINSY then
         begin
           ERROR ( 18 ) ;
           SKIP ( FSYS )
         end (* then *)
     until SY in STATBEGSYS ;
     if SY = BEGINSY then
       INSYMBOL
     else
       ERROR ( 17 ) ;
     while FWRDPRCL <> NIL do
       begin
         WRITELN ( '**** MISSING FORWARD DECLARED PROCEDURE:' : 50 ,
                   FWRDPRCL -> . NAME : 14 ) ;
         PLCNT := PLCNT + 1 ;
         FWRDPRCL := FWRDPRCL -> . NXTFWRD
       end (* while *) ;

     (***************************************)
     (* force empty main program for module *)
     (***************************************)

     if ( FPROCP = MAINPROG ) and ( FPROCP -> . EXTNAME = '#PASMAIN' )
     then
       begin
         if SY <> ENDSY then
           ERROR ( 195 ) ;
         INSYMBOL ;
         if SY <> PERIOD then
           begin
             ERROR ( 196 ) ;
             SY := PERIOD
           end (* then *) ;

     (********)
     (*STP   *)
     (********)

         if PRCODE then
           begin
             PUTIC ;
             WRITELN ( PRR , MN [ 43 ] )
           end (* then *) ;
         ICOUNTER := ICOUNTER + 1
       end (* then *)
     else
       repeat
         BODY ( FSYS + [ CASESY ] ) ;
         if SY <> FSY then
           begin
             ERROR ( 6 ) ;
             SKIP ( FSYS + [ FSY ] )
           end (* then *)
       until ( SY = FSY ) or ( SY in BLOCKBEGSYS ) ;
   end (* BLOCK *) ;



procedure PROGRAMME ( FSYS : SETOFSYS ) ;

   var LFPTR : FRECPTR ;
       LCP : IDP ;
       I , J : INTEGER ;

   begin (* PROGRAMME *)
     CALL_LVL [ FALSE ] := 0 ;
     CALL_LVL [ TRUE ] := 0 ;

     (*************************************************)
     (* 09.2016: support modules without main program *)
     (* only external procedures. is_module has to be *)
     (* true in this case, and $ has to be allowed    *)
     (* as start char of identifiers                  *)
     (*************************************************)

     if SY in [ PROGSY , MODULESY ] then
       begin
         if SY = MODULESY then
           begin
             IS_MODULE := TRUE ;
             SOP [ '$' ] := ATOZCH ;
           end (* then *) ;
         INSYMBOL ;
         if SY <> IDENT then
           ERROR ( 2 ) ;
         PROGNAME := ID ;

     (*************************************************)
     (* 10.2016: CSECT names for internal procs       *)
     (* are $PRVxxxx; for modules,                    *)
     (* the CSECT names of the internal               *)
     (* procs are derived from the PROGNAME, so       *)
     (* hopefully there will be no name conflicts     *)
     (* - later a compiler option will be provided    *)
     (* to control the naming of the internal procs   *)
     (*************************************************)

         if IS_MODULE then
           begin
             NAME_PATTERN := PROGNAME ;

     (*************************************************)
     (* for modules:                                  *)
     (* first 5 chars are used for CSECT pattern;     *)
     (* but: if module name starts with $PAS, then    *)
     (* the $ and the 4 following chars are used.     *)
     (* for example: $PASLIBX --> $LIBXxxx            *)
     (*************************************************)

             if ( NAME_PATTERN [ 1 ] = '$' ) and ( NAME_PATTERN [ 2 ] =
             'P' ) and ( NAME_PATTERN [ 3 ] = 'A' ) and ( NAME_PATTERN
             [ 4 ] = 'S' ) then
               begin
                 NAME_PATTERN [ 2 ] := NAME_PATTERN [ 5 ] ;
                 NAME_PATTERN [ 3 ] := NAME_PATTERN [ 6 ] ;
                 NAME_PATTERN [ 4 ] := NAME_PATTERN [ 7 ] ;
                 NAME_PATTERN [ 5 ] := NAME_PATTERN [ 8 ] ;
               end (* then *) ;
             for I := 6 to 20 do
               begin
                 NAME_PATTERN [ I ] := ' ' ;
               end (* for *)
           end (* then *)
         else
           NAME_PATTERN := '$PRV' ;
         INSYMBOL ;
         if not ( SY in [ LPARENT , SEMICOLON ] ) then
           ERROR ( 14 ) ;
         if SY = LPARENT then
           begin

     (**************************)
     (* IGNORE BAD PROG. PARMS *)
     (**************************)

             repeat
               INSYMBOL ;
               if SY = IDENT then
                 begin
                   DUMMYBOOL := SEARCHID ( ID , FALSE , FALSE , [ VARS
                                ] , LCP ) ;
                   if LCP <> NIL then
                     if LCP -> . IDTYPE = TEXTPTR then
                       begin
                         NEW ( LFPTR ) ;
                         with LFPTR -> do
                           begin
                             FILIDPTR := LCP ;
                             NEXTFILE := FILEHEAD ;
                           end (* with *) ;
                         FILEHEAD := LFPTR ;
                       end (* then *) ;
                   INSYMBOL ;
                   if not ( SY in [ COMMA , RPARENT ] ) then
                     ERROR ( 20 )
                 end (* then *)
               else
                 ERROR ( 2 )
             until SY <> COMMA ;
             if SY <> RPARENT then
               ERROR ( 4 ) ;
             INSYMBOL
           end (* then *) ;
         if SY <> SEMICOLON then
           ERROR ( 14 )
         else
           INSYMBOL ;
       end (* then *) ;
     NEW ( MAINPROG , PROC , DECLARED ) ;
     with MAINPROG -> do
       begin
         NAME := '$PASMAIN    ' ;
         EXTNAME := '$PASMAIN' ;
         CSTNAME := '$PASMAI#' ;
         PFNAME := 0 ;
         IDTYPE := NIL ;
         FWDECL := FALSE ;
         PFLEV := 0 ;
         KLASS := PROC ;
         PFDECKIND := DECLARED ;
         NEXT := NIL ;
         NEXT_IN_BKT := NIL ;
         DECL_LEV := 0 ;
         FRTRN := FALSE ;
         EXTRN := FALSE ;
         DECLMISSING := FALSE ;
         if IS_MODULE then
           begin
             EXTRN := TRUE ;
             EXTNAME [ 1 ] := '#' ;
             PACK ( PROGNAME , 1 , CSTNAME ) ;
             PROC_TO_STATNAME ( CSTNAME , TRUE , CSTNAME ) ;
           end (* then *) ;
       end (* with *) ;
     if DEBUG_LEV > 0 then
       WRITELN ( DBGINFO , '% $PASMAIN  0' ) ;
     repeat
       BLOCK ( FSYS , PERIOD , MAINPROG ) ;
       if SY <> PERIOD then
         ERROR ( 21 )
     until SY = PERIOD ;
     WRITELN ( DBGINFO , '#HLT    ' , 'CALL RATIO         ' , CALL_LVL
               [ TRUE ] : 6 , CALL_LVL [ FALSE ] : 6 , CALL_LVL [ TRUE
               ] + CALL_LVL [ FALSE ] : 6 ) ;
     if ERRINX > 0 then
       PRINTERROR ;
     if GET_STAT then
       begin

     (*********************************)
     (* PRINT SYMBOL TABLE STATISTICS *)
     (*********************************)

         WRITELN ( DBGINFO , '&SYT1 ' , FENT_CNT : 1 , ' ' , SF_CNT : 1
                   , ' ' , SF_TOT : 1 , ' ' , WE_CNT : 1 , ' ' , RE_CNT
                   : 1 , ' ' , WS_CNT : 1 ) ;
         WRITE ( DBGINFO , '&SYT2' ) ;
         for I := 0 to MAXLEVEL do
           WRITE ( DBGINFO , ' ' , PROC_CNT [ I ] : 1 ) ;
         WRITELN ( DBGINFO ) ;
         WRITE ( DBGINFO , '&SYT3' ) ;
         for I := 0 to MAXLEVEL do
           WRITE ( DBGINFO , ' ' , ENT_CNT [ I ] : 1 ) ;
         for I := 0 to MAXLEVEL do
           begin
             WRITELN ( DBGINFO ) ;
             WRITE ( DBGINFO , '&SYT4' ) ;
             for J := 0 to DISPLIMIT do
               WRITE ( DBGINFO , ' ' , LU_CNT [ I , J ] : 1 ) ;
           end (* for *) ;
         for I := 1 to 10 do
           begin
             WRITELN ( DBGINFO ) ;
             WRITE ( DBGINFO , '&SYT5' ) ;
             for J := 1 to 10 do
               WRITE ( DBGINFO , ' ' , WLU_CNT [ I , J ] : 1 ) ;
           end (* for *) ;
       end (* then *) ;
   end (* PROGRAMME *) ;



procedure ENTERSTDTYPES ;

   const INTTYP : TYPEREC =
         ( INTSIZE , INTSIZE , SCALAR , STANDARD ) ;
         REALTYPE : TYPEREC =
         ( REALSIZE , REALSIZE , SCALAR , STANDARD ) ;
         CHARTYPE : TYPEREC =
         ( CHARSIZE , CHARSIZE , SCALAR , STANDARD ) ;
         BOOLTYPE : TYPEREC =
         ( BOOLSIZE , BOOLSIZE , SCALAR , DECLARED , NIL ) ;
         ANYPTYPE : TYPEREC =
         ( PTRSIZE , PTRSIZE , POINTER , NIL ) ;
         ANYFILETYPE : TYPEREC =
         ( 0 , PTRSIZE , FILES , NIL ) ;
         TEXTTYPE : TYPEREC =
         ( 0 , PTRSIZE , FILES , NIL ) ;
         ALFATYPE : TYPEREC =
         ( ALFALNGTH , CHARSIZE , ARRAYS , NIL , NIL ) ;
         ALFAINX : TYPEREC =
         ( INTSIZE , INTSIZE , SUBRANGE , NIL , ( ' ' , XINT , 1 ) , (
           ' ' , XINT , ALFALNGTH ) ) ;
         UTYP : IDENTIFIER =
         ( BLANKID , NIL , NIL , NIL , 0 , TYPES ) ;
         UCST : IDENTIFIER =
         ( BLANKID , NIL , NIL , NIL , 0 , KONST , ( ' ' , XINT , 1 ) )
           ;
         UVAR : IDENTIFIER =
         ( BLANKID , NIL , NIL , NIL , 0 , VARS , ACTUAL , 0 , XAUTO ,
           ' ' , 0 , 0 ) ;
         UFLD : IDENTIFIER =
         ( BLANKID , NIL , NIL , NIL , 0 , FIELD , 0 , NIL ) ;
         UPF : IDENTIFIER =
         ( BLANKID , NIL , NIL , NIL , 0 , PROC , DECLARED , 0 , 0 ,
           NIL , NIL , ACTUAL , FALSE , FALSE , FALSE , TRUE ,
           '$UNK_PF ' ) ;
         UREC : TYPEREC =
         ( 1 , 1 , RECORDS , NIL , NIL , 0 , 0 ) ;

   var SP : TTP ;

   begin (* ENTERSTDTYPES *)

     (**************************************)
     (* integer type                       *)
     (**************************************)

     NEW ( INTPTR ) ;
     INTPTR -> := INTTYP ;

     (**************************************)
     (* real type                          *)
     (**************************************)

     NEW ( REALPTR ) ;
     REALPTR -> := REALTYPE ;

     (**************************************)
     (* char type                          *)
     (**************************************)

     NEW ( CHARPTR ) ;
     CHARPTR -> := CHARTYPE ;

     (**************************************)
     (* boolean type                       *)
     (**************************************)

     NEW ( BOOLPTR ) ;
     BOOLPTR -> := BOOLTYPE ;

     (**************************************)
     (* anyptr type = type of nil constant *)
     (**************************************)

     NEW ( ANYPTR ) ;
     ANYPTR -> := ANYPTYPE ;

     (**************************************)
     (* anyfile type =                     *)
     (* type of undefined element type     *)
     (**************************************)

     NEW ( ANYFILEPTR ) ;
     ANYFILEPTR -> := ANYFILETYPE ;
     with ANYFILEPTR -> do
       begin
         FILTYPE := NIL ;
         SIZE := FILMINSIZE ;
       end (* with *) ;

     (**************************************)
     (* text (file) type                   *)
     (**************************************)

     NEW ( TEXTPTR ) ;
     TEXTPTR -> := TEXTTYPE ;
     with TEXTPTR -> do
       begin
         FILTYPE := CHARPTR ;
         SIZE := CHARSIZE + FILHDRSIZE ;
         if SIZE < FILMINSIZE then
           SIZE := FILMINSIZE ;
       end (* with *) ;

     (**************************************)
     (* alfa type (char array)             *)
     (**************************************)

     NEW ( ALFAPTR ) ;
     ALFAPTR -> := ALFATYPE ;
     with ALFAPTR -> do
       begin
         AELTYPE := CHARPTR ;
         NEW ( INXTYPE ) ;
         INXTYPE -> := ALFAINX ;
       end (* with *) ;

     (**************************************)
     (* undefined constant                 *)
     (* undefined type                     *)
     (* undefined var                      *)
     (* etc.                               *)
     (**************************************)

     NEW ( UCSTPTR ) ;
     UCSTPTR -> := UCST ;
     NEW ( UTYPPTR ) ;
     UTYPPTR -> := UTYP ;
     NEW ( UVARPTR ) ;
     UVARPTR -> := UVAR ;
     NEW ( UFLDPTR ) ;
     UFLDPTR -> := UFLD ;
     NEW ( UPRCPTR ) ;
     UPRCPTR -> := UPF ;
     GENLABEL ( UPRCPTR -> . PFNAME ) ;
     NEW ( UFCTPTR ) ;
     UFCTPTR -> := UPF ;
     GENLABEL ( UFCTPTR -> . PFNAME ) ;
     NEW ( SP ) ;
     SP -> := UREC ;
     UFLDPTR -> . OWNER := SP ;
   end (* ENTERSTDTYPES *) ;



procedure ENTSTDNAMES ;

   type STDPROC = record
                    NAME : ALPHA ;
                    KEY : INTEGER ;
                    KLASS : IDCLASS
                  end ;
        ESTDPROC = record
                     NAME : ALPHA ;
                     EXTNAM : EXTNAMTP
                   end ;
        XSTDPROC = record
                     NAME : ALPHA ;
                     KEY : INTEGER ;
                     KLASS : IDCLASS ;
                     LIBNAME : EXTNAMTP ;
                     FUNCCODE : INTEGER ;
                     PARMCNT : INTEGER ;
                     PROCTYP : CHAR ;
                   end ;

   var CP , CP1 : IDP ;
       I , J : INTEGER ;
       SP : STDPROC ;
       ESP : ESTDPROC ;
       XSP : XSTDPROC ;

   const CNA : array [ 1 .. 2 ] of ALPHA =
         ( 'FALSE   ' , 'TRUE    ' ) ;
         DTFNA : array [ 1 .. 2 ] of ALPHA =
         ( 'DATE    ' , 'TIME    ' ) ;
         FILNA : array [ 1 .. 6 ] of ALPHA =
         ( 'INPUT   ' , 'OUTPUT  ' , 'PRD     ' , 'PRR    ' ,
           'QRD     ' , 'QRR     ' ) ;
         STDP : array [ 1 .. 50 ] of STDPROC =
         ( ( 'PAGE      ' , 0 , PROC ) , ( 'GET       ' , 1 , PROC ) ,
           ( 'PUT       ' , 2 , PROC ) , ( 'RESET     ' , 3 , PROC ) ,
           ( 'REWRITE   ' , 4 , PROC ) , ( 'READ      ' , 5 , PROC ) ,
           ( 'WRITE     ' , 6 , PROC ) , ( 'PACK      ' , 7 , PROC ) ,
           ( 'UNPACK    ' , 8 , PROC ) , ( 'NEW       ' , 9 , PROC ) ,
           ( 'RELEASE  ' , 10 , PROC ) , ( 'READLN   ' , 11 , PROC ) ,
           ( 'WRITELN  ' , 12 , PROC ) , ( 'MARK     ' , 13 , PROC ) ,
           ( 'TRAP     ' , 14 , PROC ) , ( 'EXIT     ' , 15 , PROC ) ,
           ( 'TRACE    ' , 30 , PROC ) , ( 'ABS      ' , 16 , FUNC ) ,
           ( 'SQR      ' , 17 , FUNC ) , ( 'TRUNC    ' , 18 , FUNC ) ,
           ( 'ROUND    ' , 19 , FUNC ) , ( 'ORD      ' , 20 , FUNC ) ,
           ( 'CHR      ' , 21 , FUNC ) , ( 'PRED     ' , 22 , FUNC ) ,
           ( 'SUCC     ' , 23 , FUNC ) , ( 'CLOCK    ' , 24 , FUNC ) ,
           ( 'EOF      ' , 25 , FUNC ) , ( 'EOLN     ' , 26 , FUNC ) ,
           ( 'ODD      ' , 33 , FUNC ) , ( 'EOL      ' , 28 , FUNC ) ,
           ( 'EOT      ' , 29 , FUNC ) , ( 'MESSAGE  ' , 35 , PROC ) ,
           ( 'SKIP     ' , 36 , PROC ) , ( 'LINELIMIT' , 37 , PROC ) ,
           ( 'CARD     ' , 38 , FUNC ) , ( 'EXPO     ' , 39 , FUNC ) ,
           ( 'ADDR     ' , 40 , FUNC ) , ( 'PTRADD   ' , 41 , FUNC ) ,
           ( 'PTRDIFF  ' , 42 , FUNC ) , ( 'SIZEOF   ' , 43 , FUNC ) ,
           ( 'PTR2INT  ' , 44 , FUNC ) , ( 'PTRCAST  ' , 45 , FUNC ) ,
           ( 'CLOSE    ' , 46 , PROC ) , ( 'FLOOR    ' , 47 , FUNC ) ,
           ( '        ' , - 1 , PROC ) , ( '        ' , - 1 , PROC ) ,
           ( '        ' , - 1 , PROC ) , ( '        ' , - 1 , PROC ) ,
           ( '        ' , - 1 , PROC ) , ( '        ' , - 1 , PROC ) )
           ;
         ESTDP : array [ 1 .. 10 ] of ESTDPROC =
         ( ( 'SIN     ' , 'DSIN    ' ) , ( 'COS     ' , 'DCOS    ' ) ,
           ( 'EXP     ' , 'DEXP    ' ) , ( 'SQRT    ' , 'DSQRT   ' ) ,
           ( 'LN      ' , 'DLOG    ' ) , ( 'ARCTAN  ' , 'DATAN   ' ) ,
           ( '        ' , '        ' ) , ( '        ' , '        ' ) ,
           ( '        ' , '        ' ) , ( '        ' , '        ' ) )
           ;
         XSTDP : array [ 1 .. 20 ] of XSTDPROC =
         ( ( 'ALLOC        ' , 61 , FUNC , '$PASMEM ' , 1 , 1 , 'A' ) ,
           ( 'ALLOCX       ' , 62 , FUNC , '$PASMEM ' , 2 , 1 , 'A' ) ,
           ( 'FREE         ' , 63 , PROC , '$PASMEM ' , 3 , 1 , 'P' ) ,
           ( 'FREEX        ' , 64 , PROC , '$PASMEM ' , 4 , 1 , 'P' ) ,
           ( 'CHKHEAP      ' , 65 , PROC , '$PASMEM ' , 5 , 1 , 'P' ) ,
           ( 'CHKALLOC     ' , 66 , FUNC , '$PASMEM ' , 6 , 1 , 'A' ) ,
           ( 'FILEFCB      ' , 70 , FUNC , '$PASMEM ' , 7 , 1 , 'A' ) ,
           ( 'MEMSET       ' , 75 , PROC , '$PASSTR ' , 1 , 3 , 'P' ) ,
           ( 'MEMCPY       ' , 76 , PROC , '$PASSTR ' , 2 , 3 , 'P' ) ,
           ( 'ROUNDX       ' , 77 , FUNC , '$PASMAT ' , 1 , 2 , 'R' ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) ,
           ( '                ' , - 1 , PROC , '        ' , - 1 , 0 ) )
           ;

   begin (* ENTSTDNAMES *)

     (****************)
     (* ANYPTR       *)
     (****************)

     NEW ( CP , TYPES ) ;
     with CP -> do
       begin
         NAME := 'ANYPTR     ' ;
         IDTYPE := ANYPTR ;
         KLASS := TYPES
       end (* with *) ;
     ENTERID ( CP ) ;

     (**********************************)
     (* VOIDPTR = SYNONYM FOR ANYPTR   *)
     (**********************************)

     NEW ( CP , TYPES ) ;
     with CP -> do
       begin
         NAME := 'VOIDPTR    ' ;
         IDTYPE := ANYPTR ;
         KLASS := TYPES
       end (* with *) ;
     ENTERID ( CP ) ;

     (****************)
     (* INTEGER      *)
     (****************)

     NEW ( CP , TYPES ) ;
     with CP -> do
       begin
         NAME := 'INTEGER     ' ;
         IDTYPE := INTPTR ;
         KLASS := TYPES
       end (* with *) ;
     ENTERID ( CP ) ;

     (****************)
     (* REAL         *)
     (****************)

     NEW ( CP , TYPES ) ;
     with CP -> do
       begin
         NAME := 'REAL        ' ;
         IDTYPE := REALPTR ;
         KLASS := TYPES
       end (* with *) ;
     ENTERID ( CP ) ;

     (****************)
     (* CHAR         *)
     (****************)

     NEW ( CP , TYPES ) ;
     with CP -> do
       begin
         NAME := 'CHAR        ' ;
         IDTYPE := CHARPTR ;
         KLASS := TYPES
       end (* with *) ;
     ENTERID ( CP ) ;

     (****************)
     (* BOOLEAN      *)
     (****************)

     NEW ( CP , TYPES ) ;
     with CP -> do
       begin
         NAME := 'BOOLEAN     ' ;
         IDTYPE := BOOLPTR ;
         KLASS := TYPES
       end (* with *) ;
     ENTERID ( CP ) ;

     (****************)
     (* ANYFILE      *)
     (****************)

     NEW ( CP , TYPES ) ;
     with CP -> do
       begin
         NAME := 'ANYFILE     ' ;
         IDTYPE := ANYFILEPTR ;
         KLASS := TYPES
       end (* with *) ;
     ENTERID ( CP ) ;

     (****************)
     (* TEXT         *)
     (****************)

     NEW ( CP , TYPES ) ;
     with CP -> do
       begin
         NAME := 'TEXT        ' ;
         IDTYPE := TEXTPTR ;
         KLASS := TYPES
       end (* with *) ;
     ENTERID ( CP ) ;

     (****************)
     (* ALFA         *)
     (****************)

     NEW ( CP , TYPES ) ;
     with CP -> do
       begin
         NAME := 'ALFA        ' ;
         IDTYPE := ALFAPTR ;
         KLASS := TYPES
       end (* with *) ;
     ENTERID ( CP ) ;

     (****************)
     (* MAXINT       *)
     (****************)

     NEW ( CP , KONST ) ;
     with CP -> do
       begin
         NAME := 'MAXINT      ' ;
         IDTYPE := INTPTR ;
         KLASS := KONST ;
         VALUES . IVAL := MAXINT ;
         VALUES . STRTYPE := ' ' ;
       end (* with *) ;
     ENTERID ( CP ) ;

     (*****************************)
     (* constants of boolean type *)
     (*****************************)

     CP1 := NIL ;
     for I := 1 to 2 do
       begin

     (******************)
     (* FALSE, TRUE    *)
     (******************)

         NEW ( CP , KONST ) ;
         with CP -> do
           begin
             NAME := CNA [ I ] ;
             IDTYPE := BOOLPTR ;
             NEXT := CP1 ;
             VALUES . IVAL := I - 1 ;
             VALUES . STRTYPE := ' ' ;
             KLASS := KONST
           end (* with *) ;
         ENTERID ( CP ) ;
         CP1 := CP
       end (* for *) ;
     BOOLPTR -> . FCONST := CP ;

     (***************)
     (* NIL         *)
     (***************)

     NEW ( CP , KONST ) ;
     with CP -> do
       begin
         NAME := 'NIL         ' ;
         IDTYPE := ANYPTR ;
         NEXT := NIL ;
         VALUES . IVAL := 0 ;
         VALUES . STRTYPE := ' ' ;
         KLASS := KONST
       end (* with *) ;
     ENTERID ( CP ) ;

     (********************)
     (* predefined files *)
     (********************)

     for I := 1 to 6 do
       begin
         NEW ( CP , VARS ) ;
         with CP -> do
           begin
             NAME := FILNA [ I ] ;
             IDTYPE := TEXTPTR ;
             KLASS := VARS ;
             VKIND := ACTUAL ;
             STKLASS := XAUTO ;
             VOWNERPROC := ' ' ;
             SPECIAL := 0 ;
             NEXT := NIL ;
             VLEV := 1 ;
             VADDR := FIRSTFILBUF + ( I - 1 ) * FILMINSIZE ;
             if I = 1 then
               INPUTPTR := CP
             else
               if I = 2 then
                 OUTPUTPTR := CP ;
           end (* with *) ;
         ENTERID ( CP )
       end (* for *) ;

     (***************************)
     (* date and time functions *)
     (***************************)

     for I := 1 to 2 do
       begin
         NEW ( CP , VARS ) ;
         with CP -> do
           begin
             NAME := DTFNA [ I ] ;
             IDTYPE := ALFAPTR ;
             KLASS := VARS ;
             VKIND := ACTUAL ;
             STKLASS := XAUTO ;
             VOWNERPROC := ' ' ;
             NEXT := NIL ;
             VLEV := 1 ;
             VADDR := TIMEDATELOC + ( I - 1 ) * ALFALNGTH ;
             SPECIAL := I ;
           end (* with *) ;
         ENTERID ( CP )
       end (* for *) ;

     (******************************************************)
     (*   OSPARM PTR                                       *)
     (*   THE REST OF THIS CODE IS TO DEFINE:              *)
     (*    VAR:  OSPARM: @ RECORD                          *)
     (*                    LENGTH: INTEGER;                *)
     (*                    STRING: ARRAY [1..64] OF CHAR   *)
     (*                    END;                            *)
     (*                                                    *)
     (******************************************************)

     NEW ( CP , VARS ) ;
     with CP -> do
       begin
         NAME := 'OSPARM      ' ;
         KLASS := VARS ;
         VKIND := ACTUAL ;
         STKLASS := XAUTO ;
         VOWNERPROC := ' ' ;
         NEXT := NIL ;
         VLEV := 1 ;
         VADDR := OSPARMLOC ;
         SPECIAL := 3 ;
         ENTERID ( CP ) ;
         NEW ( IDTYPE , POINTER ) ;
         with IDTYPE -> do
           begin
             SIZE := PTRSIZE ;
             ALN := PTRSIZE ;
             FORM := POINTER ;
             NEW ( ELTYPE , RECORDS ) ;

     (***************************)
     (* TYPE OF THE PARM RECORD *)
     (***************************)

             with ELTYPE -> do
               begin
                 SIZE := INTSIZE + MAXSTRL * CHARSIZE ;
                 ALN := PTRSIZE ;
                 FORM := RECORDS ;
                 RECVAR := NIL ;
                 FLD_DISP_LEV := - 1 ;
                 NO_FLDS := 2 ;
                 NEW ( FSTFLD , FIELD ) ;
                 with FSTFLD -> do
                   begin
                     NAME := 'LENGTH      ' ;
                     IDTYPE := INTPTR ;
                     FLDADDR := 0 ;
                     KLASS := FIELD ;
                     TOP := TOP + 1 ;

     (**********************************)
     (* FIELDS ENTERED AT HIGHER SCOPE *)
     (**********************************)

                     ENTERID ( FSTFLD ) ;
                     OWNER := CP -> . IDTYPE -> . ELTYPE ;
                     NEW ( NEXT , FIELD ) ;
                     with NEXT -> do
                       begin
                         NAME := 'STRING      ' ;
                         FLDADDR := PTRSIZE ;
                         NEXT := NIL ;
                         KLASS := FIELD ;
                         NEW ( IDTYPE , ARRAYS ) ;
                         with IDTYPE -> do
                           begin
                             SIZE := MAXSTRL * CHARSIZE ;
                             ALN := CHARSIZE ;
                             FORM := ARRAYS ;
                             AELTYPE := CHARPTR ;
                             NEW ( INXTYPE , SUBRANGE ) ;
                             with INXTYPE -> do
                               begin
                                 FORM := SUBRANGE ;
                                 RANGETYPE := INTPTR ;
                                 MIN . IVAL := 1 ;
                                 MIN . STRTYPE := ' ' ;
                                 MAX . IVAL := MAXSTRL ;
                                 MAX . STRTYPE := ' ' ;
                               end (* with *) ;
                           end (* with *) ;
                       end (* with *) ;
                     ENTERID ( NEXT ) ;
                     NEXT -> . OWNER := CP -> . IDTYPE -> . ELTYPE ;
                     TOP := TOP - 1 ;
                   end (* with *) ;
               end (* with *) ;
           end (* with *) ;
       end (* with *) ;

     (***************************************)
     (* predefined procedures and functions *)
     (***************************************)

     for I := 1 to 50 do
       begin
         SP := STDP [ I ] ;
         if SP . NAME [ 1 ] = ' ' then
           break ;
         NEW ( CP , PROC , STANDARD ) ;
         with CP -> do
           begin
             NAME := SP . NAME ;
             IDTYPE := NIL ;
             NEXT := NIL ;
             KEY := SP . KEY ;
             LIBNAME := ' ' ;
             FUNCCODE := - 1 ;
             PARMCNT := 0 ;
             KLASS := SP . KLASS ;
             PFDECKIND := STANDARD ;
           end (* with *) ;
         ENTERID ( CP )
       end (* for *) ;

     (***********************************)
     (* PARAMETER OF math FUNCTIONS     *)
     (***********************************)

     NEW ( CP1 , VARS ) ;
     with CP1 -> do
       begin
         NAME := BLANKID ;
         IDTYPE := REALPTR ;
         KLASS := VARS ;
         VKIND := ACTUAL ;
         STKLASS := XAUTO ;
         VOWNERPROC := ' ' ;
         SPECIAL := 0 ;
         NEXT := NIL ;
         VLEV := 1 ;
         VADDR := LCAFTMST + FPSAVEAREA ;
       end (* with *) ;

     (***********************************)
     (* external fortran functions      *)
     (* that is: math functions         *)
     (* SIN, COS, EXP, SQRT, LN, ARCTAN *)
     (***********************************)

     for I := 1 to 10 do
       begin
         ESP := ESTDP [ I ] ;
         if ESP . NAME [ 1 ] = ' ' then
           break ;
         NEW ( CP , FUNC , DECLARED ) ;
         with CP -> do
           begin
             NAME := ESP . NAME ;
             IDTYPE := REALPTR ;
             NEXT := NIL ;
             PRMPTR := CP1 ;
             FWDECL := FALSE ;
             EXTRN := FALSE ;
             FRTRN := TRUE ;
             KLASS := FUNC ;
             PFDECKIND := DECLARED ;
             PFKIND := ACTUAL ;
             PFLEV := 0 ;
             PFNAME := 0 ;
             EXTNAME := ESP . EXTNAM ;
             CSTNAME := ' ' ;
           end (* with *) ;
         ENTERID ( CP ) ;
       end (* for *) ;

     (***********************************)
     (* external library functions      *)
     (***********************************)

     for I := 1 to 20 do
       begin
         XSP := XSTDP [ I ] ;
         if XSP . NAME [ 1 ] = ' ' then
           break ;
         NEW ( CP , PROC , STANDARD ) ;
         with CP -> do
           begin
             NAME := XSP . NAME ;
             IDTYPE := NIL ;
             NEXT := NIL ;
             KEY := XSP . KEY ;
             KLASS := XSP . KLASS ;
             PFDECKIND := STANDARD ;
             LIBNAME := XSP . LIBNAME ;
             FUNCCODE := XSP . FUNCCODE ;
             PARMCNT := XSP . PARMCNT ;
             PROCTYP := XSP . PROCTYP ;
           end (* with *) ;
         ENTERID ( CP ) ;
       end (* for *) ;

     (**************************************)
     (* SNAPSHOT                           *)
     (**************************************)

     NEW ( CP , PROC , DECLARED ) ;
     with CP -> do
       begin
         NAME := 'SNAPSHOT    ' ;
         IDTYPE := NIL ;
         FRTRN := FALSE ;
         FWDECL := FALSE ;
         EXTRN := TRUE ;
         PFLEV := 0 ;
         PFNAME := 0 ;
         KLASS := PROC ;
         PFDECKIND := DECLARED ;
         PFKIND := ACTUAL ;
         EXTNAME := '$PASSNAP' ;
         CSTNAME := ' ' ;
         DECLMISSING := FALSE ;
         NEXT := NIL ;
       end (* with *) ;
     ENTERID ( CP ) ;

     (*******************************)
     (* FIRST PARAMETER OF SNAPSHOT *)
     (*******************************)

     NEW ( CP -> . PRMPTR , VARS ) ;

     (********************************)
     (* SECOND PARAMETER OF SNAPSHOT *)
     (********************************)

     NEW ( CP1 , VARS ) ;
     with CP1 -> do
       begin
         IDTYPE := INTPTR ;
         KLASS := VARS ;
         VKIND := ACTUAL ;
         STKLASS := XAUTO ;
         VOWNERPROC := ' ' ;
         SPECIAL := 0 ;
         NEXT := NIL ;
         VLEV := 1 ;
         VADDR := LCAFTMST + FPSAVEAREA + INTSIZE
       end (* with *) ;

     (*******************************)
     (* FIRST PARAMETER OF SNAPSHOT *)
     (*******************************)

     with CP -> . PRMPTR -> do
       begin
         IDTYPE := INTPTR ;
         KLASS := VARS ;
         VKIND := ACTUAL ;
         STKLASS := XAUTO ;
         VOWNERPROC := ' ' ;
         NEXT := CP1 ;
         VLEV := 1 ;
         VADDR := LCAFTMST + FPSAVEAREA
       end (* with *) ;
   end (* ENTSTDNAMES *) ;



procedure INITSCALARS ;

   begin (* INITSCALARS *)
     FWPTR := NIL ;
     STMTNEST := 0 ;
     LISTTAG := ' ' ;
     LIST := TRUE ;
     PRCODE := TRUE ;
     ERRINX := 0 ;
     CONSTLCOUNTER := - 1 ;
     HP := FALSE ;
     ICOUNTER := 0 ;
     INTLABEL := 0 ;
     FILEHEAD := NIL ;
     LCOUNTER := FIRSTGVAR ;

     (***************************************)
     (* ADR. OF THE FIRST GLOBAL VARIABLE   *)
     (* NOTE IN THE ABOVE RESERVATION Of    *)
     (* BUFFER STORE FOR TEXT FILES         *)
     (***************************************)

     OLDICOUNTER := 0 ;
     ICOUNTER := 0 ;
     EOL := TRUE ;
     LINECNT := 0 ;
     CH := ' ' ;
     CHCNT := 0 ;
     PAGECNT := 0 ;
     PLCNT := PAGESIZE ;

     (****************************)
     (* GENERATES FIRST HEADLINE *)
     (****************************)

     LMARGIN := 0 ;
     RMARGIN := 80 ;
     BUFEND := 81 ;
     OLDLN := 0 ;
     MWARN := FALSE ;
     LSTOP := '#' ;
     GLOBTESTP := NIL ;
     OPEN_RECORD := NIL ;
     LASTLINELISTED := 0 ;
     PROGNAME := '$PASMAIN    ' ;
     MXINT10 := MAXINT DIV 10 ;
     PROCLAB := 0 ;
     ERRORCNT := 0 ;
     WARNCNT := 0 ;
     ASSEMBLE := FALSE ;
     NESTCOMM := FALSE ;
     ERRKIND := 'E' ;
     SAVEREGS := TRUE ;
     SAVEFPRS := TRUE ;
     DEBUG := TRUE ;
     DEBUG_LEV := 2 ;
     ASSIGN := FALSE ;
     FLIPDEBUG := FALSE ;
     EXTUSED := FALSE ;
     WARNING := TRUE ;
     DOTFLG := FALSE ;
     NOPACKING := FALSE ;
     PACKDATA := FALSE ;
     IS_MODULE := FALSE ;

     (*************************)
     (*GENERATES UNIQUE NAMES *)
     (*************************)

     PRNTTYPHD := NIL ;
     PRNTTYNO := 0 ;
     FRTPARHD := NIL ;
     XLABNO := 0 ;
     GET_STAT := TRUE ;
     ASMVERB := FALSE ;
     CTRCNT := 0 ;
     CTROPTION := FALSE ;
     FENT_CNT := 0 ;
     SF_CNT := 0 ;
     SF_TOT := 0 ;
     WE_CNT := 0 ;
     RE_CNT := 0 ;
     WS_CNT := 0 ;

     (***************************************************)
     (* alloc storage for - relatively large - set info *)
     (***************************************************)

     NEW ( PSIGLOB ) ;
   end (* INITSCALARS *) ;



procedure INITTABLES ;

   var K : BKT_RNG ;
       I , J : INTEGER ;


   procedure RATORS ;

      var I : INTEGER ;
          CH : CHAR ;

      begin (* RATORS *)

        (***************************************)
        (*   useful initializations            *)
        (***************************************)

        for CH := CHR ( 0 ) to CHR ( ORDCHMAX ) do
          begin
            UPSHIFT [ CH ] := CH ;
            SOP [ CHR ( I ) ] := ILLEGCH ;
            SSY [ CHR ( I ) ] := NOTUSED ;
          end (* for *) ;
        for CH := 'A' to 'I' do
          SOP [ CH ] := ATOZCH ;
        for CH := 'J' to 'R' do
          SOP [ CH ] := ATOZCH ;
        for CH := 'S' to 'Z' do
          SOP [ CH ] := ATOZCH ;

        (***************************************)
        (*   an old comment told about some    *)
        (*   troubles with upshift, because    *)
        (*   some meaningful chars (to pascal) *)
        (*   are in the letter range 'a' to    *)
        (*   'z', but are no letters ...       *)
        (*   see the EBCDIC letter gaps.       *)
        (*   I avoided those problems by       *)
        (*   the three loops below             *)
        (*   - bernd oppolzer (2016)           *)
        (***************************************)

        for CH := 'a' to 'i' do
          begin
            SOP [ CH ] := ATOZCH ;
            UPSHIFT [ CH ] := CHR ( ORD ( CH ) - ORD ( 'a' ) + ORD (
                              'A' ) ) ;
          end (* for *) ;
        for CH := 'j' to 'r' do
          begin
            SOP [ CH ] := ATOZCH ;
            UPSHIFT [ CH ] := CHR ( ORD ( CH ) - ORD ( 'a' ) + ORD (
                              'A' ) ) ;
          end (* for *) ;
        for CH := 's' to 'z' do
          begin
            SOP [ CH ] := ATOZCH ;
            UPSHIFT [ CH ] := CHR ( ORD ( CH ) - ORD ( 'a' ) + ORD (
                              'A' ) ) ;
          end (* for *) ;
        for CH := '0' to '9' do
          SOP [ CH ] := NUMCH ;
        SOP [ '"' ] := DQUOTCH ;
        SOP [ CHLBRACE ] := LBRACE ;
        SOP [ '#' ] := SKIPCH ;
        SOP [ '$' ] := DOLLARCH ;
        SOP [ '''' ] := QUOTCH ;
        SOP [ '(' ] := LPARCH ;
        SOP [ ')' ] := RPARCH ;
        SOP [ ',' ] := SPECH ;
        SOP [ '.' ] := DOTCH ;
        SOP [ ':' ] := COLONCH ;
        SOP [ ';' ] := SPECH ;
        SOP [ '@' ] := SPECH ;
        SOP [ '[' ] := SPECH ;
        SOP [ '|' ] := SPECH ;
        SOP [ ']' ] := SPECH ;
        SOP [ '^' ] := SPECH ;
        SOP [ '_' ] := UNDSCH ;
        SOP [ '+' ] := PLUS ;
        SOP [ '-' ] := MINUS ;
        SOP [ '*' ] := MUL ;
        SOP [ '/' ] := RDIV ;
        SOP [ '=' ] := EQOP ;
        SOP [ '<' ] := LTOP ;
        SOP [ '>' ] := GTOP ;
        SOP [ '|' ] := OROP ;
        SOP [ '&' ] := ANDOP ;

        (**************************************************************)
        (* Note: SSY array should be defined as full range of         *)
        (*       characters, but it's ok as is for now because it is  *)
        (*       currently indexed only for specific characters.      *)
        (*       If it were indexed by higher chars (e.g. backslash   *)
        (*       or curly brackets) in the future, its definition     *)
        (*       would have to change. Currently, SPECH does not      *)
        (*       include any of these higher chars. - D.E. 02feb2007  *)
        (**************************************************************)
        (* fixed in 2016 during Windows / Linux port - bernd oppolzer *)
        (**************************************************************)

        SSY [ '+' ] := ADDOP ;
        SSY [ '-' ] := ADDOP ;
        SSY [ '*' ] := MULOP ;
        SSY [ '/' ] := MULOP ;
        SSY [ '(' ] := LPARENT ;
        SSY [ ')' ] := RPARENT ;
        SSY [ '[' ] := LBRACK ;
        SSY [ ']' ] := RBRACK ;
        SSY [ ',' ] := COMMA ;
        SSY [ ':' ] := COLON ;
        SSY [ '|' ] := ADDOP ;
        SSY [ '&' ] := MULOP ;
        SSY [ '<' ] := RELOP ;
        SSY [ '>' ] := RELOP ;
        SSY [ '=' ] := RELOP ;
        SSY [ '@' ] := ARROW ;
        SSY [ '^' ] := ARROW ;
        SSY [ ';' ] := SEMICOLON ;
        SSY [ '.' ] := PERIOD ;
      end (* RATORS *) ;


   begin (* INITTABLES *)
     RATORS ;
     for I := 0 to MAXERRLOG do
       ERRLOG [ I ] := [ ] ;

     (*****************)
     (*CLEAR ERROR LOG*)
     (*****************)

     for K := 0 to MAX_BKT do
       BUCKET [ K ] := NIL ;
     for I := 0 to MAXLEVEL do
       begin
         PROC_CNT [ I ] := 0 ;
         ENT_CNT [ I ] := 0 ;
         for J := 0 to DISPLIMIT do
           LU_CNT [ I , J ] := 0 ;
       end (* for *) ;
     for I := 1 to 10 do
       for J := 1 to 10 do
         WLU_CNT [ I , J ] := 0 ;
     PROC_CNT [ 1 ] := 1 ;
   end (* INITTABLES *) ;



begin (* HAUPTPROGRAMM *)

  (**********************************************************)
  (* INITIALIZE                                             *)
  (**********************************************************)

  INITSCALARS ;
  INITTABLES ;

  (******************************************)
  (*ENTER STANDARD NAMES AND STANDARD TYPES:*)
  (******************************************)

  LEVEL := 0 ;
  TOP := 0 ;
  with DISPLAY [ 0 ] do
    begin
      OCCUR := BLCK ;
      FLABEL := NIL ;
    end (* with *) ;
  ENTERSTDTYPES ;
  ENTSTDNAMES ;
  TOP := 1 ;
  LEVEL := 1 ;
  with DISPLAY [ 1 ] do
    begin
      OCCUR := BLCK ;
      FLABEL := NIL ;
    end (* with *) ;
  GET_STAT := FALSE ;

  (*************************************************)
  (*set options passed as parameter to the compiler*)
  (*************************************************)

  if OSPARM = NIL then
    SOURCENAME := ' '
  else
    with OSPARM -> do
      begin
        SOURCENAME := ' ' ;
        for SX := 1 to 8 do
          if SX <= LENGTH then
            SOURCENAME [ SX ] := STRING [ SX ] ;
        if LENGTH > 8 then
          begin
            CH := CHLBRACE ;
            LINEBUF := ' ' ;
            LINEBUF [ 1 ] := '{' ;
            LINEBUF [ 2 ] := '$' ;
            if LENGTH > 72 then
              LENGTH := 72 ;
            for CHCNT := 9 to LENGTH do
              LINEBUF [ CHCNT - 6 ] := STRING [ CHCNT ] ;
            LINEBUF [ LENGTH - 5 ] := CHRBRACE ;
            LINEBUF [ LENGTH - 4 ] := '#' ;
            EOL := FALSE ;
            CHCNT := 1 ;
            LASTCOL := LENGTH - 5 ;
          end (* then *)
      end (* with *) ;

  (**********)
  (*COMPILE:*)
  (**********)

  CTIME := CLOCK ( 0 ) ;

  (*****************************************)
  (* FIRST HEADLINE PRINTED BY 'ENDOFLINE' *)
  (*****************************************)

  INSYMBOL ;
  PROGRAMME ( BLOCKBEGSYS + STATBEGSYS - [ CASESY ] ) ;

  (***********************************)
  (* PRINT POST COMPILATION MESSAGES *)
  (***********************************)

  GOODBYE ;
end (* HAUPTPROGRAMM *) .
