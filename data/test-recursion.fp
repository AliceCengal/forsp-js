(
  ;; recursion test
  ;; adapted from xorvoid

  (>_) >drop

  (>x <x <x) >dup
  (>x >y >z <y <x <z) >rot
  (>x x) >force

  (>cond >true >false cond <false <true rot cswap drop force) >if

  (>false >true >cond >if <false <true <cond if) >endif

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