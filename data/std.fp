(
  (>x x)                               >force
  (>x <x <x)                           >dup
  (>_)                                 >drop
  (>x >y <x <y)                        >swap

  ('())                                >nil
  ('() eq)                             >null?

  (force cswap drop force)             >if
  (>f >t >c >fn <f <t <c fn)           >endif

  (>f (>x (<x x) f) dup force)         >Y
  (>g (<g Y))                          >rec

  ;; List

  ; length [ list -> num ]
  (
    >self >list
    <if (<list null?)
      0
      (<list cdr self 1 +)
  ) rec                                >length

  ; explode [ list[n] -> n[ val ] ]
  (
    >self >list
    <if (<list null?)
      ()
      (<list cdr self <list car)
    endif
  ) rec                                >explode

  ; implode [ n n[ val ] -> list[n] ]
  (
    >self >n
    <if (0 <n eq)
      nil
      (>tmp <n 1 - self <tmp cons)
  ) rec                                >implode

  ;; Dictionary

  ; dict-get [ key dict -> value? ]
  (
    >self >key >dict
    <if (<dict null?)
      nil
      (
        <if (<dict car car <key eq)
          <dict car cdr
          (<dict cdr <key self)
        endif
      )
    endif
  ) rec                                >dict-get

  ; dict-set [ value key dict -> dict ]
  (
    >self >dict >key >value
  ) rec                                >dict-set

  (
    
  ) rec >dict-nil

  ;; String


)