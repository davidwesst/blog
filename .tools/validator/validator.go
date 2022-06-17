package main

import (
	"fmt"

	validator "github.com/davidwesst/blog/tools/validator/lib"
)

func main() {
	msg := validator.Validate()
	fmt.Println(msg)
}
