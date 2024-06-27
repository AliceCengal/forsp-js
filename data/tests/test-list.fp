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
  3 implode
  stack print;
)