package client

import (
	"log"
	"net"
	"net/http"
)

// Display Client's IP via Headers
func Ip(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		w.Header().Set("Cache-Control", "no-cache")
		log.Printf("response=%d client=%s method=%s url=%s userAgent=%s", http.StatusNotImplemented, r.RemoteAddr, r.Method, r.RequestURI, r.UserAgent())
		w.WriteHeader(http.StatusNotImplemented)
	} else {
		w.Header().Set("Content-Type", "text/html")
		w.Header().Set("Cache-Control", "no-cache")

		if r.Header.Get("X-Forwarded-For") != "" {
			clientIp := net.ParseIP(r.Header.Get("X-Forwarded-For"))
			if clientIp != nil {
				log.Printf("response=%d client=%s method=%s url=%s userAgent=%s", http.StatusOK, r.RemoteAddr, r.Method, r.RequestURI, r.UserAgent())
				w.Write([]byte(clientIp.String()))
			} else {
				log.Printf("response=%d client=%s method=%s url=%s userAgent=%s", http.StatusServiceUnavailable, r.RemoteAddr, r.Method, r.RequestURI, r.UserAgent())
				w.WriteHeader(http.StatusServiceUnavailable)
			}
		} else {
			log.Printf("response=%d client=%s method=%s url=%s userAgent=%s", http.StatusServiceUnavailable, r.RemoteAddr, r.Method, r.RequestURI, r.UserAgent())
			w.WriteHeader(http.StatusServiceUnavailable)
		}
	}
}
