package validator

import (
	"strings"
)

func Validate() string {
	arr := []string{"hello", "from", "validate"}
	return strings.Join(arr, " ")
}
