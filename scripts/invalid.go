package client

import (
	"log"
	"net/http"
)

func Invalid(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		w.Header().Set("Cache-Control", "no-cache")
		log.Printf("response=%d client=%s method=%s url=%s userAgent=%s", http.StatusNotImplemented, r.RemoteAddr, r.Method, r.RequestURI, r.UserAgent())
		w.WriteHeader(http.StatusNotImplemented)
	} else {
		w.Header().Set("Content-Type", "text/plain")
		w.Header().Set("Cache-Control", "no-cache")

		if r.Header.Get("X-Forwarded-For") != "" {
			log.Printf("response=%d client=%s method=%s url=%s userAgent=%s", http.StatusOK, r.RemoteAddr, r.Method, r.RequestURI, r.UserAgent())
			w.Write([]byte("1.1.1.1"))
		} else {
			log.Printf("response=%d client=%s method=%s url=%s userAgent=%s", http.StatusServiceUnavailable, r.RemoteAddr, r.Method, r.RequestURI, r.UserAgent())
			w.WriteHeader(http.StatusBadGateway)
		}
	}
}
