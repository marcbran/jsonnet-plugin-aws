package aws

import (
	"fmt"
	"math"
	"net/http"
	"time"
)

func timestampFormat(member Traits, shape Traits, fallback string) string {
	if f := member.String("smithy.api#timestampFormat"); f != "" {
		return f
	}
	if f := shape.String("smithy.api#timestampFormat"); f != "" {
		return f
	}
	return fallback
}

func parseTimestamp(v any) (time.Time, error) {
	switch t := v.(type) {
	case float64:
		sec, frac := math.Modf(t)
		return time.Unix(int64(sec), int64(frac*1e9)).UTC(), nil
	case string:
		for _, layout := range []string{time.RFC3339Nano, http.TimeFormat, time.RFC1123} {
			parsed, err := time.Parse(layout, t)
			if err == nil {
				return parsed.UTC(), nil
			}
		}
		return time.Time{}, fmt.Errorf("invalid timestamp %q", t)
	default:
		return time.Time{}, fmt.Errorf("timestamp must be a string or number")
	}
}

func formatTimestamp(t time.Time, format string) any {
	switch format {
	case "epoch-seconds":
		return float64(t.UnixNano()) / 1e9
	case "http-date":
		return t.UTC().Format(http.TimeFormat)
	default:
		return t.UTC().Format(time.RFC3339Nano)
	}
}
