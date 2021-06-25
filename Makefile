ssl:
  openssl req -x509 -newkey rsa:4096 --nodes -keyout bin/key.pem -out bin/cert.pem -days 365

build:
	shards build --ignore-crystal-version 

run:
	cd bin && ./murcure
