(
  "../presets/std" import*
  "./test-lib" import >lib

  lib 'h dict-get print
  lib @f print
  lib @g force

  ; h print ; should throw error

  (
    ('hello 4)
    ('world 5)
  ) dict >e

  "hello" dict? print;
  nil dict? print;
  <e dict? print;
  <e print;
  <e @hello print;

  <e ('hello 6) dict-set;
  dup @hello print;
  dup print;

  ('foo 8) dict-set;
  dup print;
  @foo print;
  
  stack print;
)