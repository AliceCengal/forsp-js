(
  ;; Differences found in the forsp-js implementation

  ; truth is represented by #t instead of just t, following Scheme convention

  3 4 + 7 eq print ; #t

  ; All numbers follow JS number semantics

  ; No low-level memory unsafe operations

  ;; The following are extensions provided forsp-js , not available in the 
  ;; original C implementation

  ; String values in double quotes

  "Hello world" print;

  ; import* statement executes another Forsp script file with the given name and 
  ; appends the env created by that file into the current env. There is no protection
  ; against recursive import, so you are free to blow your own stack

  "./std" import*

  "hello world" string? print; #t

  ; import statement executes another Forsp script file with the given name and
  ; pushes a dictionary containing the env created by that file onto the stack

  "./std" import >std

  ; A dictionary is an ordered list of key-value pairs built from cons shells.
  ; Given that is this is a very common structure in most programming tasks,
  ; there is a special syntax to access its value

  "hello world"
  @(std string?)  ; <-- dictionary get syntax
  force print ;  #t

  ; the above expression desugars into:

  "hello world"
  <std 'string? dict-get 
  force print ; #t

  ; since dict-get is defined in "./std" , the above syntax is only valid after
  ; a `"./std" import*`


)