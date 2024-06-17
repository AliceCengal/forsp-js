(
  "./std" import*
  "./test-lib" import >lib

  lib 'h dict-get print
  @(lib f) print
  @(lib g)

  ; h print ; should throw error
)