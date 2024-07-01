(
  "../presets/std" import*

  (
    1 >a 1 >b
    (
      <b
      (:b <a <b +) set!
      (:a <b <a -) set!
    )
  ) >fibonacci$

  fibonacci$ 
  (4000000 lt?) take-while$
  (2 divides?) filter$
  (+) reduce$ print;
)