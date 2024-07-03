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

  (>self >n ># >list
    if (<# 1 lte?)
      (<list)
      (
        <list <n prime? >is-prime

        if (is-prime)
          (<list <n cons <# 1 -)
          (<list <#)
        endif

        <n 2 + self
      )
    endif 
  ) rec >solve

  '(2) 40 3 solve print
)