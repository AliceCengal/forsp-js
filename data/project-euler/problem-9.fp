(
  "../presets/std" import*

  (>x <x <x *) >sqr

  (>self >n >m
    <m sqr <n sqr - >a
    2 <m * <n * >b
    <m sqr <n sqr + >c

    if (1000 <a <b <c + + divides?)
      (
        1000 <a <b <c + + / >f
        (<a <f * <b <f * <c <f *) list print
        <a <f * <b <f * <c <f * * *
      )
    elseif (<m 10 eq?)
      ()
    elseif (<m <n - 1 eq?)
      (<m 1 + 1 self)
      (<m <n 1 + self)
    endif 
  ) rec >solve

  2 1 solve print
)