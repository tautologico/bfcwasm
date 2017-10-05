# bfcwasm

bfcwasm is a brainfuck compiler targetting WebAssembly.

## Requirements

* [Chez Scheme](https://cisco.github.io/ChezScheme/)
* [WebAssembly Binary Toolkit (wabt)](https://github.com/WebAssembly/wabt)

## Installing Chez Scheme

On macOS it is available in homebrew:

```
brew install chezscheme
```

If you don't have homebrew or are using Linux, it may be easier to build from
sources. You'll need development versions of the `ncurses` and `libx11`
libraries.

## Compiling and running

The compiler uses the [nanopass framework](http://nanopass.org), but it's already
configured as a git submodule. To get it after cloning this repository:

```
git submodule init
git submodule update
```

After this you can compile programs using the script:

```
./compile.sh test/hello.bf
```

This will generate a `bfprog.wat`, a textual representation of the generated
WebAssembly program. The `wabt` tools are needed to transform it to a binary
module:

```
wat2wasm bfprog.wat -o bfprog.wasm
```

Now copy the generated `bfprog.wasm` and the HTML page `runtime/bfprog.html`
to the same directory, and open the HTML file in a browser with WebAssembly
support (the easiest is probably a recent Firefox). The page will show the
result of running the brainfuck program.
