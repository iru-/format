warnings off
require mf/mf.f

variable 'empty
: rl  'empty @ execute s" format.f" included ;
marker empty
' empty 'empty !


( Table of xts )
               58 constant items/table
items/table cells constant /table

create 'table /table allot

: 0table  'table /table erase ;
: item  ( b - a )  items/table mod cells 'table + ;

0table


( Formatting buffer )
128 constant /fbuf
variable fbuf-position
create fbuf /fbuf allot

: 0fbuf  fbuf /fbuf erase  /fbuf 1- fbuf-position ! ;
: .fbuf  fbuf /fbuf dump ;

0fbuf

: remaining  ( - u )  fbuf-position @ 1+ ;
: fbuf-cur   ( - a )  fbuf fbuf-position @ + ;
: fbuf>s  ( - a u )   fbuf-cur  /fbuf fbuf-position @ - ;

: ?space  ( n - )  remaining > abort" format: no space in formatting buffer" ;
: ?exhausted       1 ?space ;

: fbuf+  ( n - )  \ TODO check for overflow/underflow in both directions
  dup ?space fbuf-position +! ;

: fbuf-  ( n - )  negate fbuf+ ;

: fbuf-reserve  ( u - a )  fbuf- fbuf-cur 1+ ;

: >fbuf   ( a u - )  \ may truncate the output
  dup ?space  remaining min  dup fbuf-reserve  swap move ;

: b>fbuf    ( b - )  ?exhausted  fbuf-cur c!  1 fbuf- ;


( Format operations )
: dec>c  ( b - b' )  [char] 0 + ;

create hextable
  '0' c,  '1' c,  '2' c,  '3' c,
  '4' c,  '5' c,  '6' c,  '7' c,
  '8' c,  '9' c,  'A' c,  'B' c,
  'C' c,  'D' c,  'E' c,  'F' c,

: hex>c  ( b - b' )  hextable + c@ ;


: dec>fbuf  ( n - )
  dup abs begin
    10 /mod  swap dec>c b>fbuf  dup 0=
  until
  drop  0< if [char] - b>fbuf then ;

: hex>fbuf  ( n - )
  begin
    dup 15 and  hex>c b>fbuf
    4 rshift dup 0=
  until
  drop ;

: quoted>fbuf  ( a u - )  [char] " b>fbuf  >fbuf  [char] " b>fbuf ;


( Format string )
0 value 'fstr
0 value #fstr
variable fstr-position

: fstr-cur  ( - a )  'fstr fstr-position @ + ;
: fstr-  -1 fstr-position +! ;

: .fstr  fstr-cur #fstr fstr-position @ - type ;

: peek  ( - b )   fstr-cur c@ ;  \ XXX possible off-by-one
: getb  ( - c )   peek fstr- ;
: end?  ( - fl )  fstr-position @ 0< ;


: escape  ( b - )
  dup [char] n = if drop 10 b>fbuf exit then
  dup [char] t = if drop 9  b>fbuf exit then
  drop ;

: special  ( b - )
  dup item @ dup if nip execute exit then
  drop b>fbuf [char] % b>fbuf ;

: process  ( b - )
  peek [char] % =  if fstr- special exit then
  peek [char] \ =  if fstr- escape  exit then
  b>fbuf ;
  

: format  ( ... a u - a' u' )
  dup to #fstr  1- fstr-position !  to 'fstr  0fbuf
  begin getb process end? until 
  fbuf>s ;

: ftype  ( ... a u - )  format type ;


( Default formats )
' b>fbuf       char c  item !
' >fbuf        char s  item !
' dec>fbuf     char d  item !
' quoted>fbuf  char q  item !
' hex>fbuf     char x  item !
