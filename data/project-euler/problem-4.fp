(
  "../presets/std" import*

  (
    >list nil <list
    (
      >self >list
      if (<list null?)
        ()
        (<list car cons <list cdr self)
      endif
    ) rec force
  ) >reverse

  (
    >n
    <n nil
    (
      >self >list >x
      if (<x 10 lt?)
        (<list x cons)
        (
          <x 10 / floor >x2
          <x2 <list <x <x2 10 * - cons self
        )
      endif
    ) rec force >digits
    <digits iter$
    <digits reverse iter$ zip$
    (>p if (<p car <p cdr eq?) 1 0 endif) map$
    #t (1 eq? and?) fold$
  ) >palindrome?

  ;91619 palindrome? print;
  
  nil 999
  (
    >self >a >list
    if (<a 700 eq?)
      (<list)
      (
        <list <a 1 -
        (
          >self >b >list
          if (<b 600 eq?)
            (<list)
          elseif (<a <b * palindrome?)
            (<list <a <b * cons <b 1 - self)
            (<list <b 1 - self)
          endif
        ) rec force
      )
    endif
  ) rec >solve

   solve print;
)