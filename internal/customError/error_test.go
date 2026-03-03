package customerror

import (
	"errors"
	"testing"
)

func TestErrorAtInput_Error(t *testing.T) {
	tests := []struct {
		name     string
		msg      string
		err      error
		expected string
	}{
		{
			name:     "only message",
			msg:      "something went wrong",
			err:      nil,
			expected: "something went wrong",
		},
		{
			name:     "message and wrapped error",
			msg:      "failed to process",
			err:      errors.New("connection refused"),
			expected: "failed to process: connection refused",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			e := &ErrorAtInput{
				Msg: tt.msg,
				Err: tt.err,
			}
			if got := e.Error(); got != tt.expected {
				t.Errorf("ErrorAtInput.Error() = %v, want %v", got, tt.expected)
			}
		})
	}
}
