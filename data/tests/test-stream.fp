(
  "../presets/std" import*

  '(1 2 3 4) iter$ collect$ print;
  '(1 2 3 4) iter$ 6 take$ collect$ print;
  rand$ 2 take$ collect$ print;
  2 enumerate$ 8 take$ collect$ print
  1 enumerate$ (5 lt?) take-while$ collect$ print;

  2 enumerate$ 3 take$ 
  rand$ 2 take$ 
  join$ collect$ print;

  '("hello" "world" "foo" "bar")
  1 enumerate$
  zip$
  collect$ print;

  '(1 2 3 4 5) iter$ 2 drop$ collect$ print;
  '(1 2 3 4 5) iter$ (2 divides?) filter$ collect$ print;

  '(1 2 3 4 5) iter$ -100 (+) fold$ print;
  '(1 2 3 4 5) iter$ (+) reduce$ print;

  1 enumerate$
  (10 lt?) take-while$
  5 take$
  2 drop$
  collect$ print;

  rand$ (100 * floor) map$
  (2 divides?) filter$
  5 take$
  collect$ print;

  stack print;
)