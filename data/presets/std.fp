(
  (>x x)                               >force
  (>x <x <x)                           >dup
  (>_)                                 >drop
  (>x >y <x <y)                        >swap
  (>f (>x (<x x) f) dup force)         >Y
  (>g (<g Y))                          >rec

  ;; Boolean logic

  ; #t is primitive
  ('())                                >nil
  ('() eq?)                            >null?
  ('() eq?)                            >not?
  (swap force dup cswap drop force)    >or?
  (swap force dup not? cswap >_ force) >and?

  (tag 1 eq?)                          >atom?
  (tag 2 eq?)                          >num?
  (tag 3 eq?)                          >pair?
  (tag 4 eq?)                          >closure?

  ((>x x cswap >_ >x x))               >if
  (>f >t >c >fn <f <t <c fn)           >endif
  ((>c >t >f (<f <t <c if >x x) endif)) >elseif

  ; `gt?` is primitive
  (swap gt? not?)                      >gte?
  (swap gt?)                           >lt?
  (gt? not?)                           >lte?

  ;; bitwise ops

  ; `nand` is primitive
  (dup nand swap dup nand nand)        >|
  (nand dup nand)                      >&
  (dup nand)                           >~
  (
    >b >a <a <b nand >ab
    <a <ab nand <b <ab nand nand
  )                                    >^

  (0 |)                                >trunc

  (
    >n <n trunc >n_
    if (<n 0 gte?)
      (<n_)
    elseif (<n <n_ - 0 eq?)
      (<n_)
      (<n_ 1 -)
    endif
  )                                    >floor

  (
    >n <n trunc >n_
    if (<n 0 lte?)
      (<n_)
    elseif (<n <n_ - 0 eq?)
      (<n_)
      (<n_ 1 +)
    endif
  )                                    >ceil

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
    >list 0 <list
    (
      >self >list
      if (<list null?)
        ()
        (1 + <list cdr self)
      endif
    ) rec force
  )                                    >length

  (
    >list
    (
      (<list null? not?)
      (
        <list car 
        ('list <list cdr) set!
      ) and?
    )
  )                                    >iter$

  ; sort

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
  ;     (:hello 4)
  ;     (:world 5)
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
  (force swap cons cons)               >dict-set

  ;; String

  (tag 6 eq?)                           >string?

  ;; Stream constructors and higher order functions

  ; enumerate
  (>n (<n ('n <n 1 +) set!))           >enumerate$

  ((rand))                             >rand$

  (
    >n >stream$
    (
      (<n 0 eq? not?)
      (
        stream$
        ('n n 1 -) set!
      ) and?
    )
  )                                    >take$

  (
    >n >stream$ <n
    (
      >self >n
      if (<n 0 eq?)
        ()
        (stream$ drop <n 1 - self)
      endif
    ) rec force
    <stream$
  )                                    >drop$

  (
    >fn >stream$
    (
      stream$ >item
      (<item null? not?)
      (<item fn) and?
    )
  )                                    >map$

  (
    >fn >stream$
    (
      >self
      stream$ >item
      if (<item null?)
        nil
      elseif (<item fn not?)
        (self)
        (<item)
      endif
    ) rec
  ) >filter$

  ; fold
  (
    >fn >init >stream$ <init
    (
      >self >val stream$ >item
      if (<item null?)
        (val)
        (val <item fn self)
      endif
    ) rec force
  )                                    >fold$

  ; foldr

  (>fn >$ <$ $ <fn fold$)              >reduce$

  (
    >fn >stream$
    (
      >self stream$ >item
      if (<item null?)
        ()
        (<item fn self)
      endif
    ) rec force
  ) >each$

  (
    >stream$
    (
      >self stream$ >item
      (<item null? not?)
      (self <item cons) and?
    ) rec force
  )                                    >collect$
)