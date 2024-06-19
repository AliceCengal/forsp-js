(
  (>x x)                               >force
  (>x <x <x)                           >dup
  (>_)                                 >drop
  (>x >y <x <y)                        >swap

  ('())                                >nil
  ('() eq)                             >null?

  (>x x cswap >_ >x x)                 >if
  (>f >t >c >fn <f <t <c fn)           >endif

  (>f (>x (<x x) f) dup force)         >Y
  (>g (<g Y))                          >rec

  (tag 1 eq)                           >atom?
  (tag 2 eq)                           >num?
  (tag 3 eq)                           >pair?

  ;; bitwise ops

  ;; >b-nor is primitive
  (dup b-nor swap dup b-nor b-nor)     >b-and
  (b-nor dup b-nor)                    >b-or
  (dup b-nor)                          >b-not

  ;; List

  (
    >thing
    <if (<thing tag 0 eq)
      #t
      (
        <if (<thing tag 3 eq)
          #t
          '()
        endif
      )
    endif
  )                                    >list?

  ; length [ list -> num ]
  (
    >self >list
    <if (<list null?)
      0
      (<list cdr self 1 +)
    endif
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
    endif
  ) rec                                >implode

  ;; Dictionary

  (
    >maybe-dict
    <if (<maybe-dict pair?)
      (
        <if (<maybe-dict car pair?)
          (
            <if (<maybe-dict car car atom?)
              #t
              '()
            endif
          )
          '()
        endif
      )
      '()
    endif
  )                                    >dict?

  ; dict-get [ key dict -> value? ]
  (
    >self >key >dict
    <if (<dict null?)
      nil
      (
        <if (<dict car car <key eq)
          (<dict car cdr)
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

  (tag 6 eq)                           >string?

)