(
  ;; Differences found in the forsp-js implementation

  ; truth is represented by `#t` instead of just `t`, and the equality test is
  ; `eq?`, following Scheme convention

  3 4 + 7 eq? print ; #t

  ; POP and PUSH use the '>' and '<' sigils.
  ; colon and apostrophe both denote symbols

  5 >x <x print;
  'example print;
  :example print;

  ; All numbers follow Javascript number semantics

  4.765 print;

  ; `cswap` checks if the condition operand is not equal to nil.
  ; this means only nil is falsy, everything else is truthy

  ; No low-level memory unsafe operations

  ;; The following are extensions provided by forsp-js , not available in the 
  ;; original C implementation

  ; String values in double quotes

  "Hello world" print;

  ; import* statement executes another Forsp script file with the given name and 
  ; appends the env created by that file into the current env. There is no protection
  ; against recursive import, so you are free to blow your own stack.

  "./std" import*

  "hello world" string? print; #t

  ; import statement executes another Forsp script file with the given name and
  ; pushes a dictionary containing the env created by that file onto the stack.
  ; Again, no protection against recursive import.

  "./std" import >std

  ; A dictionary is an ordered list of key-value pairs built from cons shells.
  ; Since this data structure is so commonly used in many programming tasks,
  ; there is a special syntax to access its value.

  "hello world"
  std @string?  ; <-- dictionary get syntax
  force print ;  #t

  ; the above expression desugars into:

  "hello world"
  std 'string? dict-get
  force print ; #t

  ; It is also common to execute a function freshly taken out of a 
  ; dictionary. Use the `@!` form to tack on an additional `force`

  "hello world" std @!string? print ; same as the above expression

  ; since `dict-get` and `force` are defined in "std.fp" , the above 
  ; syntax is only valid after a `"./std" import*`

  ; "std.fp" provides many commonly used utility functions

  ; stack operations
  ; -- force dup drop swap rec

  ; value type tests
  ; -- null? atom? num? pair? closure? string?

  ; logic operators
  ; -- nil not? or? and? gt? gte? lt? lte?

  ; bitwise operators
  ; -- | & ~ ^ >> <<

  ; if statement
  ; -- if elseif endif

  5 >n
  if (<n 4 eq?)
    ("that's four" print)
  elseif (<n 3 eq?)
    ("that's three" print)
    ("It's a mystery" print)
  endif

  ; mathematical operations
  ; -- + - * / % 
  ; -- divides? max min ** TAU TAU* sin cos tan 
  ; -- log exp floor ceil rand

  ; list operations
  ; -- list? list length

  (1 2 3) list >gg
  <gg list? print ; #t
  <gg length print ; 3

  ; dictionary operations
  ; -- dict? dict dict-get dict-set

  (
    (:hello 1)
    (:world 2)
  ) dict >hh
  <hh dict? print ; #t
  <hh length print ; 2

  ; stream operations
  ; 
  ; by convention, stream functions have the '$' suffix,
  ; but this is just a visual aid, the interpreter doesn't 
  ; do anything special to these functions.
  ; 
  ; -- iter$ enumerate$ rand$ join$ zip$ take$ take-while$ drop$
  ; -- map$ filter$ fold$ reduce$ each$ collect$

  1 enumerate$           ; infinite stream of integers starting from 1
  (10 lt?) take-while$   ; -> 1 2 3 ... 8 9
  5 take$                ; -> 1 2 3 4 5
  2 drop$                ; -> 3 4 5

  rand$                  ; infinite stream of random number between 0 and 1
  (100 * floor) map$     ; infinite stream of random number 0 to 99
  (2 divides?) filter$   ; infinite stream of even random number 0 to 98

  ; fold$, reduce$, each$, and collect$ are stream consumers.
  ; take care to not call them on infinite streams, that will
  ; cause infinite loop. Make sure to limit the stream first with 
  ; take$ or take-while$

  5 take$ >$
  <$ collect$ print;

  <$ 0 (+) fold$ print;
  <$ (+) reduce$ print;
  <$ (print) each$;

  ; join$ first consumes the first stream operand until it terminates,
  ; then starts consuming the second stream operand

  '(1 2 3) iter$ rand$ join$

  ; zip$ will terminate when one of its operand stream terminates

  '(1 2 3) iter$ rand$ zip$ collect$ print;
)