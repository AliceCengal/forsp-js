(
  "../presets/std" import*
  
  (
    >n
    3 enumerate$ (n lt?) take-while$
    (>x (<x 3 divides?) (<x 5 divides?) or?) filter$
    (+) reduce$ 
  ) >solve

  ; 10 solve print; 23
  1000 solve print;
)