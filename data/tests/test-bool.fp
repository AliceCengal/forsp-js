(
  "../presets/std" import*

  (#t) (#t) or? print
  (#t) ('()) or? print
  ('()) (#t) or? print
  ('()) ('()) or? print

  (#t) (#t) and? print
  (#t) ('()) and? print
  ('()) (#t) and? print
  ('()) ('()) and? print

  12 10 & print; 8 
  12 10 | print; 14
  12 10 ^ print; 6
  
  2 1 << print; 4
  2 1 >> print; 1

  "gt test" print;

  5 4 gt? print; #t
  5 5 gt? print; '()
  5 6 gt? print; '()

  "gte test" print;

  5 4 gte? print; #t
  5 5 gte? print; #t
  5 6 gte? print; '()

  "lt test" print;

  5 4 lt? print; '()
  5 5 lt? print; '()
  5 6 lt? print; #t

  "lte test" print;

  5 4 lte? print; '()
  5 5 lte? print; #t
  5 6 lte? print; #t


)