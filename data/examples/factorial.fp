(
  ;; factorial test
  ;; adapted from xorvoid
  
  (>_) >drop

  (>x <x <x) >dup
  (>x >y >z <y <x <z) >rot
  (>x x) >force

  (force cswap >_ force) >if
  (>f >t >c >fn <f <t <c fn) >endif

  (>f (>x (<x x) f) dup force) >Y
  (>g (<g Y)) >rec

  (>self >n
    <if <n 0 eq? 
      1
      (<n 1 - self <n *)
    endif
  ) rec >factorial

  1 factorial print
  2 factorial print
  3 factorial print
  4 factorial print
  5 factorial print
  6 factorial print
  ; 50 factorial print
)