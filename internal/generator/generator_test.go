package generator

import (
	"testing"
)

func TestFindTemplatePath(t *testing.T) {
	tests := []struct {
		name      string
		lang      string
		framework string
		arch      string
		wantErr   bool
	}{
		{
			name:      "valid python flask microservice",
			lang:      "python",
			framework: "flask",
			arch:      "microservice",
			wantErr:   false,
		},
		{
			name:      "valid golang gin monolith",
			lang:      "golang",
			framework: "gin",
			arch:      "monolith",
			wantErr:   false,
		},
		{
			name:      "valid node express microservice",
			lang:      "node/js",
			framework: "express",
			arch:      "microservice",
			wantErr:   false,
		},
		{
			name:      "invalid language",
			lang:      "ruby",
			framework: "rails",
			arch:      "monolith",
			wantErr:   true,
		},
		{
			name:      "invalid framework",
			lang:      "python",
			framework: "unknown",
			arch:      "monolith",
			wantErr:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := findTemplatePath(tt.lang, tt.framework, tt.arch)
			if (err != nil) != tt.wantErr {
				t.Errorf("findTemplatePath() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
