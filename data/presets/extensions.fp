(
  ;; Differences found in the forsp-js implementation

  ; truth is represented by `#t` instead of just `t`, and the equality test is
  ; `eq?`, following Scheme convention

  3 4 + 7 eq? print ; #t

  ; POP and PUSH use the '>' and '<' sigils

  5 >x <x print;

  ; All numbers follow JS number semantics

  4.765 print;

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

  ; It is also common to execute a closure freshly taken out of a 
  ; dictionary. Use the `@!` form to tack on an additional `force`

  "hello world" std @!string? print ; same as the above expression

  ; since dict-get is defined in "std.fp" , the above syntax is only valid after
  ; a `"./std" import*`

)