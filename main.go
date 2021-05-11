package main

import (
	_ "embed"
	"log"
	"net/http"
)

//go:embed releases.json
var releases []byte

func handle(w http.ResponseWriter, req *http.Request) {
	w.Header().Add("Content-Type", "application/json; charset=utf-8")
	_, err := w.Write(releases)
	if err != nil {
		log.Printf("Failed to write response: %s", err)
	}
}

func main() {
	http.ListenAndServeTLS(":9443", "combined.pem", "server-key.pem", http.HandlerFunc(handle))
}