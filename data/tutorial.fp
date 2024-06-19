(
  ;; tutorial
  ;; adapted from xorvoid

  5
  stack print
  4 3
  stack print

  print
  stack print

  * print
  stack print

  5 >my-variable
  stack print

  <my-variable
  stack print

  >_

  <my-variable <my-variable * print ;

  (>x <x <x *) >square

  67 square
  stack print

  'something
  '(1 2 3)
  '(abd (1 foo) ())
  stack print

  quote other
  stack print

  (>_) >drop

  drop drop drop drop drop

  (>x <x <x) >dup

  7 dup * print;

  (>x >y <x <y) >swap
  (>x >y <y <x <y) >over
  (>x >y >z <y <x <z) >rot

  9 8 7 stack print  ; [ 9 , 8 , 7 ]
  swap stack print   ; [ 9 , 7 , 8 ]
  over stack print   ; [ 9 , 7 , 8 , 7 ]
  drop stack print   ; [ 9 , 7 , 8 ]
  rot stack print    ; [ 7 , 8 , 9 ]

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