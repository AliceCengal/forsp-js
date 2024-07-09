(
  ; https://en.wikipedia.org/wiki/Van_Wijngaarden_transformation
  
  "./std" import*

  (>p <p cdr <p car) >splat
  
  (
    0 0
    (>self >k >prev
      if (k 2 divides?) (1) (-1) endif >sgn
      <sgn 2 k * 1 + / <prev + >term
      (<term <k 1 + self)
      <term
      cons
    ) rec force
  ) >pi$

  (>self >n >$
    if (n zero?)
      <$
      (<$ <$ 1 drop$ zip$ (splat + 2 /) map$ n 1 - self)
    endif
  ) rec >accelerate-converge$

  pi$ 8 accelerate-converge$
  
  5 take$ (print) each$;
)
