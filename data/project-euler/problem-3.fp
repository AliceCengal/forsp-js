(
  "../presets/std" import*

  (0.5 ** ceil) >sqrt

  (
    >n
    <n sqrt >limit

    <n 3 3
    (
      >self >f >g >n
      if (<n <f divides?)
        (<n f / <f <f self)
      elseif (<f limit lt?)
        (<n <g <f 2 + self)
        (<g)
      endif
    ) rec force
  ) >largest-prime-factor

  13195 largest-prime-factor print;
  ; 600851475143 largest-prime-factor print;

)