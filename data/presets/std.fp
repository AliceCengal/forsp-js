(
  (>x x)                               >force
  (>x <x <x)                           >dup
  (>_)                                 >drop
  (>x >y <x <y)                        >swap
  (>f (>x (<x x) f) dup force)         >Y
  (>g (<g Y))                          >rec

  ('())                                >nil
  ('() eq?)                            >null?
  (tag 1 eq?)                          >atom?
  (tag 2 eq?)                          >num?
  (tag 3 eq?)                          >pair?
  (tag 4 eq?)                          >closure?
  ('() eq?)                            >not?
  (swap force dup cswap drop force)    >or?
  (swap force dup not? cswap drop force) >and?

  ((>x x cswap >_ >x x))               >if
  (>f >t >c >fn <f <t <c fn)           >endif
  ((>c >t >f (<f <t <c if >x x) endif)) >elseif

  ;; bitwise ops

  ;; >b-nor is primitive
  (dup b-nor swap dup b-nor b-nor)     >b-and
  (b-nor dup b-nor)                    >b-or
  (dup b-nor)                          >b-not

  ;; List

  (tag >t (<t 0 eq?) (<t 3 eq?) or?)   >list?

  (
    >fn 'end-list fn nil
    (
      >self >list >item
      if (<item 'end-list eq?)
        (list)
        (<list <item cons self)
      endif
    ) rec force
  )                                    >list

  ; length [ list -> num ]
  (
    >self >list
    if (<list null?)
      0
      (<list cdr self 1 +)
    endif
  ) rec                                >length

  ; explode [ list[n] -> n[ val ] ]
  (
    >self >list
    if (<list null?)
      ()
      (<list cdr self <list car)
    endif
  ) rec                                >explode

  ; implode [ n n[ val ] -> list[n] ]
  (
    >self >n
    if (0 <n eq?)
      nil
      (>tmp <n 1 - self <tmp cons)
    endif
  ) rec                                >implode

  ;; Dictionary

  (
    >maybe-dict
    (<maybe-dict null?)
    (
      (<maybe-dict pair?)
      (<maybe-dict car pair?) and?
      (<maybe-dict car car atom?) and?
    ) or?
  )                                    >dict?

  ; Make dict
  ; Example: 
  ;   (
  ;     ('hello 4)
  ;     ('world 5)
  ;   ) dict >e
  (
    >fn 'end-dict fn
    (
      >self >kv
      if (<kv closure?)
        (self kv swap cons cons)
        '()
      endif
    ) rec force
  )                                    >dict

  ; dict-get [ key dict -> value? ]
  (
    >self >key >dict
    if (<dict null?)
      nil
    elseif (<dict car car <key eq?)
      (<dict car cdr)
      (<dict cdr <key self)
    endif
  ) rec                                >dict-get

  ; dict-set [ (value key) dict -> dict ]
  (
    ;force swap cons cons
    force >v >k
    (
      >self >dict
      if (<dict null?)
        (nil v k cons cons)
      elseif (<dict car car k eq?)
        (<dict cdr v k cons cons)
        (<dict cdr self <dict car cons)
      endif
    ) rec force
  )                                 >dict-set

  (
    
  ) rec >dict-delete

  ;; String

  (tag 6 eq?)                           >string?

)