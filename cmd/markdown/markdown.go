// Render a text from STDIN as markdown
package main

import (
	markdown "github.com/MichaelMure/go-term-markdown"
	"io"
	"os"
)

func main() {
	text, _ := io.ReadAll(os.Stdin)
	print(string(markdown.Render(string(text), 80, 0)))
}
