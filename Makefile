run:

ca.pem ca-key.pem ca.csr: ca-csr.json
	cfssl genkey -initca $+ | cfssljson -bare ca
OBJECTS += ca.pem ca-key.pem ca.csr

server.pem server-key.pem server.csr: ca.pem ca-key.pem server-csr.json
	cfssl gencert -ca ca.pem -ca-key ca-key.pem server-csr.json | cfssljson -bare server
OBJECTS += server.pem server-key.pem server.csr

combined.pem: server.pem ca.pem
	cat $+ > $@
OBJECTS += combined.pem

releases.json:
	curl -o "$@" 'https://api.github.com/repos/k3s-io/k3s/releases?per_page=10'
OBJECTS += releases.json

main: main.go combined.pem server-key.pem releases.json
	go build -o $@ .
OBJECTS += main

run: main.go combined.pem server-key.pem releases.json
	go run .

.PHONY: run

clean:
	-rm -f ${OBJECTS}
