(
  "../presets/std" import*

  (
    1 1
    (>self >a >b
      (<b <a + <b self) <b cons
    ) rec force
  ) >fibonacci$

  fibonacci$ 
  (4000000 lt?) take-while$
  (2 divides?) filter$
  (+) reduce$ print;
)