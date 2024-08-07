(
  (>x x)                               >force
  (>x <x <x)                           >dup
  (>_)                                 >drop
  (>x >y <x <y)                        >swap
  (>f (>x (<x x) f) dup force)         >Y
  (>f ((>x (<x x) f) >x <x x))         >rec

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

  ((>c c cswap >_ >x x))               >if
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

  ;; Maths

  (0 eq?)                              >zero?
  (% 0 eq?)                            >divides?
  (>b >a <a <b <a <b lt? cswap drop)   >max
  (>b >a <a <b <a <b gt? cswap drop)   >min

  (>ex log <ex * exp)                  >**
  (TAU *)                              >TAU*

  ;; `cos` is primitive
  (0.25 TAU* - cos)                    >sin
  (>x <x sin <x cos /)                 >tan

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

  (tag 6 eq?)                          >string?

  ;; Stream constructors and higher order functions

  (>self >n 
    (<n 1 + self) <n cons
  ) rec                                >enumerate$

  (>self
    (self) rand cons
  ) rec                                >rand$

  <car                                 >car$
  (cdr force)                          >cdr$
  (>$ <$ cdr$ <$ car$)                 >next$

  (>self >list
    (<list)
    ((<list cdr self) <list car cons) and?
  ) rec                                >iter$

  (>self >n >$
    (<$) (<n 0 gt?) and?
    ((<$ cdr$ <n 1 - self) <$ car$ cons) and?
  ) rec                                >take$

  (>self >fn >$
    (<$) (<$ car$ fn) and?
    ((<$ cdr$ <fn self) <$ car$ cons) and?
  ) rec                                >take-while$

  (>self >$2 >$1 
    if (<$1)
      (($1 cdr$ $2 self) $1 car$ cons)
      $2
    endif
  ) rec                                >join$

  (>self >$2 >$1
    ($1 $2 and?)
    (
      (<$1 cdr$ <$2 cdr$ self) 
      $2 car$ $1 car$ cons 
      cons
    ) and?
  ) rec                                >zip$

  (>self >n >$
    if (<n 0 gt? (<$) and?)
      (<$ cdr$ <n 1 - self)
      (<$)
    endif
  ) rec                                >drop$

  (>self >fn >$
    <$
    ((<$ cdr$ <fn self) <$ car$ fn cons) and?
  ) rec                                >map$

  (>self >fn >$
    (<$)
    (
      <$ car$ >it
      if (<it fn)
        ((<$ cdr$ <fn self) <it cons)
        (<$ cdr$ <fn self)
      endif
    ) and?
  ) rec                                >filter$

  (>self >fn >val >$
    if (<$)
      (<$ cdr$ val <$ car$ fn <fn self)
      (val)
    endif
  ) rec                                >fold$

  (>fn next$ <fn fold$)                >reduce$

  (>self >fn >$
    if (<$)
      (
        <$ car$ fn
        <$ cdr$ <fn self
      )
      ()
    endif
  ) rec                                >each$

  (>self >$
    (<$)
    (<$ cdr$ self <$ car$ cons) and?
  ) rec                                >collect$

)