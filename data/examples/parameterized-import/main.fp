(
  ; Since the imported module is executed in the current scope
  ; the script has access to the current stack and environment,
  ; which means that the import can be parameterized

  "../../presets/std" import*

  "Pumpkin pie sugary high"
  "./lib" import >lib
  lib @!holler


  "Bamboo cakes jack off Jake's"
  "./lib" import >lib2
  lib2 @!holler

  lib @!holler
)