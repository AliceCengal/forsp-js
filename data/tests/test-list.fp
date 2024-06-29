(
  "../presets/std" import*

  (1 2 3 4 5) list >l
  ; env print;
  l print;
  l car print;
  l list? print;

  5 list? print;
  nil list? print;
  l length print;

  l explode stack print;
  3 implode stack print;

  <l iter$ collect$ print;

  -5 enumerate$ 11 take$ 
  (2 /) map$ 
  collect$ print;

  -5 enumerate$ 11 take$ 
  (2 / floor) map$ 
  collect$ print;

  -5 enumerate$ 11 take$ 
  (2 / ceil) map$ 
  collect$ print;

  1 enumerate$ 6 take$
  0 (+) fold$ print;

  1 enumerate$ 6 take$
  (+) reduce$ print;

  1 enumerate$ 6 take$
  nil (cons) fold$ print;
)