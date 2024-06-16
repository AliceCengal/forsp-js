(
  (
    "./std" import >std
    <std print
    "import success" print
  ) >test-dict-import

  (
    "./std" import*
    dump-env
    <h print
  ) >test-star-import
  
  test-star-import 

  ; @(std h)
  ; quote std quote h dict-get 

  ; @(std h bar)
  ; quote std quote h dict-get quote bar dict-get
)