package prompt

import "testing"

func TestLegacyEcho(t *testing.T) {
	tests := []struct{ input, want string }{
		{"plain", "plain"},
		{"trailing\\", "trailing\\"},
		{"\\\\\\a\\b\\e\\E\\f\\n\\r\\t\\v", "\\\a\b\x1b\x1b\f\n\r\t\v"},
		{"before\\cafter", "before"},
		{"\\0101", "A"},
		{"\\0", "\x00"},
		{"\\x41", "A"},
		{"\\x", "\\x"},
		{"\\u03bb", "λ"},
		{"\\U0001f40d", "🐍"},
		{"\\u12", "\\u12"},
		{"\\q", "\\q"},
	}
	for _, test := range tests {
		if got := legacyEcho(test.input); got != test.want {
			t.Errorf("legacyEcho(%q) = %q, want %q", test.input, got, test.want)
		}
	}
}

func TestParseDigits(t *testing.T) {
	if value, count := parseDigits("fZ", 16, 2); value != 15 || count != 1 {
		t.Fatalf("hex parse = %d, %d", value, count)
	}
	if value, count := parseDigits("Z", 16, 2); value != 0 || count != 0 {
		t.Fatalf("invalid parse = %d, %d", value, count)
	}
}
