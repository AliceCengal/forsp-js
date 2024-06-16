(
  ;; tutorial
  ;; adapted from xorvoid

  5
  dump-stack
  4 3
  dump-stack

  print
  dump-stack

  * print
  dump-stack

  5 >my-variable
  dump-stack

  <my-variable
  dump-stack

  >_

  <my-variable <my-variable * print ;

  (>x <x <x *) >square

  67 square
  dump-stack

  'something
  '(1 2 3)
  '(abd (1 foo) ())
  dump-stack

  quote other
  dump-stack

  (>_) >drop

  drop drop drop drop drop

  (>x <x <x) >dup

  7 dup * print;

  (>x >y <x <y) >swap
  (>x >y <y <x <y) >over
  (>x >y >z <y <x <z) >rot

  9 8 7 dump-stack  ; [ 9 , 8 , 7 ]
  swap dump-stack   ; [ 9 , 7 , 8 ]
  over dump-stack   ; [ 9 , 7 , 8 , 7 ]
  drop dump-stack   ; [ 9 , 7 , 8 ]
  rot dump-stack    ; [ 7 , 8 , 9 ]

  (0 swap - -) >plus
  4 5 plus print ; 

  (>x x) >force

  (dup *) 8 swap force print;

  (>cond >true >false cond <false <true rot cswap drop force) >if

  (5) (4) 't  if print
  (5) (4) '() if print

  (>false >true >cond >if <false <true <cond if) >endif

  <if (1 2 eq)
    ('true print)
    ('false print)
  endif

  <if (1 1 eq)
    ('true print)
    ('false print)
  endif

  (>f (>x (<x x) f) dup force) >Y

  (>g (<g Y)) >rec

  (>self >list
    <if (<list '() eq) 0 (
      <list cdr self 1 +
    ) endif
  ) rec >length

  '()      length print ; 0
  '(5)     length print ; 1
  '(8 9)   length print ; 2
  '(1 2 3) length print ; 3
)