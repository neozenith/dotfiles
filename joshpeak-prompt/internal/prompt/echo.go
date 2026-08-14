package prompt

import (
	"strconv"
	"strings"
	"unicode/utf8"
)

// legacyEcho reproduces the escape expansion performed by zsh's echo -e.
// Prompt values can contain escapes, so this is part of the byte contract.
func legacyEcho(value string) string {
	var output strings.Builder
	for index := 0; index < len(value); index++ {
		if value[index] != '\\' || index+1 >= len(value) {
			output.WriteByte(value[index])
			continue
		}
		index++
		switch value[index] {
		case '\\':
			output.WriteByte('\\')
		case 'a':
			output.WriteByte('\a')
		case 'b':
			output.WriteByte('\b')
		case 'c':
			return output.String()
		case 'e', 'E':
			output.WriteByte(0x1b)
		case 'f':
			output.WriteByte('\f')
		case 'n':
			output.WriteByte('\n')
		case 'r':
			output.WriteByte('\r')
		case 't':
			output.WriteByte('\t')
		case 'v':
			output.WriteByte('\v')
		case '0':
			parsed, consumed := parseDigits(value[index+1:], 8, 3)
			if consumed == 0 {
				output.WriteByte(0)
			} else {
				output.WriteByte(byte(parsed))
				index += consumed
			}
		case 'x':
			parsed, consumed := parseDigits(value[index+1:], 16, 2)
			if consumed == 0 {
				output.WriteString("\\x")
			} else {
				output.WriteByte(byte(parsed))
				index += consumed
			}
		case 'u', 'U':
			limit := 4
			if value[index] == 'U' {
				limit = 8
			}
			parsed, consumed := parseDigits(value[index+1:], 16, limit)
			if consumed != limit || !utf8.ValidRune(rune(parsed)) {
				output.WriteByte('\\')
				output.WriteByte(value[index])
			} else {
				output.WriteRune(rune(parsed))
				index += consumed
			}
		default:
			output.WriteByte('\\')
			output.WriteByte(value[index])
		}
	}
	return output.String()
}

func parseDigits(value string, base, limit int) (uint64, int) {
	consumed := 0
	for consumed < len(value) && consumed < limit {
		if _, err := strconv.ParseUint(value[consumed:consumed+1], base, 8); err != nil {
			break
		}
		consumed++
	}
	if consumed == 0 {
		return 0, 0
	}
	parsed, _ := strconv.ParseUint(value[:consumed], base, 32)
	return parsed, consumed
}
