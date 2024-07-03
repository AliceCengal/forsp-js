(
  "../presets/std" import*

  1 enumerate$ 10 take$ (+) reduce$ dup *;
  1 enumerate$ 10 take$ (dup *) map$ (+) reduce$;
  - print;

  1 enumerate$ 100 take$ (+) reduce$ dup *;
  1 enumerate$ 100 take$ (dup *) map$ (+) reduce$;
  - print;
)