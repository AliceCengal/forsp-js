(
  "../presets/std" import*

  1 enumerate$
  (2 *) map$
  (1 +) map$
  (1 +) map$
  10 take$ collect$ print;

  1 enumerate$
  (>n 3 <n divides?) filter$
  (>n 5 <n divides?) filter$
  10 take$ collect$ print;
)