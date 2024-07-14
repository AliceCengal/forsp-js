(
  "../presets/std" import*

  (>n
    <n 0.5 ** ceil >limit
    
    '() 1
    (>self >x
      if (x limit gte?)
        ()
      elseif (n x divides?)
        (x cons x 1 + self n x / cons)
        (x 1 + self)
      endif
    ) rec force
  ) >divisors

  (>n <n 0.5 ** ceil >limit
    1 enumerate$ (dup * <n lt?) take-while$
    (>x <n <x divides?) filter$
    0 (>_ 1 +) fold$ 2 *
  ) >divisor-count

  ; 10 divisors print;
  ; 15 divisors print;
  ; 21 divisors print;
  ; 28 divisors print;

  ; 10 divisor-count print;
  ; 15 divisor-count print;
  ; 21 divisor-count print;
  ; 28 divisor-count print;

  1 enumerate$
  (>n <n <n 1 + * 2 /) map$ ; triangle numbers
  ; (>n <n divisor-count <n cons) map$
  ; (cdr 10 lt?) take-while$
  (divisor-count) map$
  ; (100 lt?) take-while$
  10 take$
  collect$ print;

  ; cannot compute
)