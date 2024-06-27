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
)