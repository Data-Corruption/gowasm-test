//go:build js && wasm

package main

import (
	"syscall/js"
)

func main() {
	doc := js.Global().Get("document")

	// Set the innerText of the paragraph with the id "paragraph-example"
	p := doc.Call("getElementById", "paragraph-example")
	p.Set("innerText", "Hello from Go WebAssembly! 🚀")

	// on click-btn click, increment the value of click-value
	clickBtn := doc.Call("getElementById", "click-btn")
	clickValue := doc.Call("getElementById", "click-value")
	clicks := 0
	clickBtn.Call("addEventListener", "click", js.FuncOf(func(this js.Value, args []js.Value) interface{} {
		clicks++
		clickValue.Set("innerText", clicks)
		return nil
	}))

	select {} // Keep WASM running
}
