package ipcheck

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/netip"

	"github.com/tprasadtp/protonwire/internal/ua"
)

func Invoke(ctx context.Context, endpoint string) (*netip.Addr, error) {
	req, _ := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	req.Header.Set(ua.Header())

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("protonwire(ipcheck): %w", err)
	}
	body, err := io.ReadAll(resp.Body)
	defer resp.Body.Close()
	if err != nil {
		return nil, fmt.Errorf("protonwire(ipcheck): %w", err)
	}

	ip, err := netip.ParseAddr(string(body))
	if err != nil {
		return nil, fmt.Errorf("protonwire(ipcheck): endpoint returned invalid ip address %s", string(body))
	}

	return &ip, nil
}
