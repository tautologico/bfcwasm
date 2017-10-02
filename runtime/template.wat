(module
  (import "console" "writech" (func $writech (param i32)))

  (global $i (mut i32) (i32.const 0))
  (memory $mem 1)

  (func $incrindex
    get_global $i
    i32.const 1
    i32.add
    set_global $i)

  (func $decrindex
    get_global $i
    i32.const 1
    i32.sub
    set_global $i)

  (func (export "getindex") (result i32)
    get_global $i)

  (func (export "getmem") (result i32)
    get_global $i
    i32.load)

  (func $incracc
    get_global $i
    get_global $i
    i32.load
    i32.const 1
    i32.add
    i32.store)

  (func $decracc
    get_global $i
    get_global $i
    i32.load    
    i32.const 1
    i32.sub
    i32.store)

  (func (export "program")
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc

    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc

    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc

    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc

    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc

    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc

    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc
    call $incracc

    get_global $i
    i32.load
    call $writech)

)
