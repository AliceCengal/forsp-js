(
  ; introduces a way of representing a HTML document in Forsp S-expression
  ; and a program to print out this S-expression as proper HTML 
  
  "./std" import*

  "https://cdn.jsdelivr.net" >cdn-url
  
  (:html 
    :lang "en"
    (:head
      (:meta :charset "UTF-8")
      (:meta
        :name "description"
        :content "RPN scientific calculator")
      (:link
        :rel "shortcut icon"
        :href "manifest.json")
      (:meta
        :name "viewport"
        :content "width=device-width, initial-scale=1.0"))
      ; (:title "Calculator")
      (:link 
        :rel "stylesheet"
        ; :href "https://cdn.jsdelivr.net")
        :href cdn-url)
    (:body
      (:div
        :id "app")
      (:script
        :type "module"
        :src "/src/main.tsx"))
  )
  >example-page

  ;<page list >page-list
  ;<page-list print

  ; self-closing tags
  (
    (:meta 1)
    (:link 1)
  ) dict >self-closing-tags

  ; uncomment to suppress new lines
  ; <print >print-line
  
  (>self >html-clos
    <html-clos list >html-list
    <html-list car >html-tag

    ; store closing tag
    ; ">" <html-tag "</"
    if (<self-closing-tags <html-tag dict-get)
      ("" "" "")
      (">" <html-tag "</")
    endif
    
    ; print opening tag
    <html-tag "<" "" print-line print print
    <html-list cdr >next

    (>self >html-list
      if (<html-list null?)
        (<html-list) ; do nothing
        (
          <html-list car >curr
          <html-list cdr >next
          if (<curr atom?)
            ("=" <curr " " print print print
            <next self)
          elseif (<curr string?)
            ("\"" <curr "\"" print print print
            <next self)
          elseif (<curr num?)
            (<curr print)
          elseif (<curr closure?)
            ; leave the remaining data on the stack and pass
            (<html-list) 
            () ; do nothing
          endif
        )
      endif
    ) rec >process-attrs
    
    <next process-attrs
    ; ">" print
    if (<self-closing-tags <html-tag dict-get)
      (" />" print)
      (">" print)
    endif

    (>self-2 >html-list
      if (<html-list null?)
        () ; do nothing
        (
          <html-list car >curr
          <html-list cdr >next
          ; "" print-line
          <curr self
          <next self-2
        )
      endif
    ) rec >process-childs

    process-childs

    ; print closing tag
    ; "" print-line
    print print print
    ; ">" <html-tag "</" print print print
  ) rec >generate-html

  <example-page generate-html
  "Done" "" print-line print-line
)