(
  ;; fibonacci
  ;; adapted from xorvoid

  (>_) >drop

  (>x <x <x) >dup
  (>x >y <x <y)             >swap
  (>x >y >z <y <x <z) >rot
  (>x x) >force
  ('()) >nil
  ('() eq) >null?

  (force cswap >_ force) >if
  (>f >t >c >fn <f <t <c fn) >endif

  (>f (>x (<x x) f) dup force) >Y
  (>g (<g Y)) >rec

  ; range
  (
    >self >start >end
    <if <start <end eq
      nil
      (<end <start 1 + self <start cons)
    endif
  ) rec >range

  ; map [>fn >list -> <out-list]
  (
    >self >fn >list
    <if <list null?
      nil
      (<list car fn <list cdr <fn self swap cons)
    endif
  ) rec >map

  (
    1 1
    (
      >self >a >b >n
      <if <n 0 eq
        <b
        (<n 1 - <a <b + <b self)
      endif
    ) rec force
  ) >fibonacci

  10 0 range <fibonacci map print;
)