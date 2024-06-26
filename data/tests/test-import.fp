(
  (
    "./test-lib" import >std
    <std print
    "dict import success" print
    ; f print; should throw error
  ) >test-dict-import

  (
    "./test-lib" import*
    <h print
    "star import success" print
  ) >test-star-import
  
  test-star-import 
  test-dict-import 
  ; <h print ; should throw error
  ; <std print ; should throw error
)