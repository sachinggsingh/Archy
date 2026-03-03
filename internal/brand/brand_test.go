package brand

import (
	"strings"
	"testing"
)

func TestBanner(t *testing.T) {
	banner := Banner()
	if banner == "" {
		t.Error("Banner() returned an empty string")
	}

	if !strings.Contains(banner, "Your Architect Assistant") {
		t.Errorf("Banner() does not contain expected subtitle")
	}
}
