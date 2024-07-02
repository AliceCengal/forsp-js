(
  "../presets/std" import*

  (>n '(2) 3
    (>self >x >list
      <list iter$ 
      (>p <x <p divides?) filter$ 
      collect$ null? >is-prime?
      
      <list
      if (is-prime?)
        (<x cons)
        ()
      endif
      if (<x 2 + <n lte?)
        (<x 2 + self)
        ()
      endif
    ) rec force
  ) >primes-upto

  (>n
    <n primes-upto >primes
    primes iter$
    (>p <p <n log <p log / floor ** 0.000000001 - ceil) map$
    (*) reduce$
  ) >solve

  20 solve print
)