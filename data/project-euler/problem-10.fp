(
  "../presets/std" import*

  (>self >n >list
    if (<list null?)
      #t
    elseif (<n <list car divides?)
      '()
      (<list cdr <n self)
    endif
  ) rec >prime?

  10 >limit
  ; 2000000 >limit
  
  (>self >n >list
    if (<n limit gte?)
      (<list)
      (
        <list <n prime? >is-prime

        if (is-prime)
          (<list <n cons)
          (<list)
        endif

        <n 2 + self
      )
    endif 
  ) rec >solve

  '(2) 3 solve print

  ; cannot compute
)