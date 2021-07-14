ssl:
	openssl req -x509 -newkey rsa:4096 --nodes -keyout run/key.pem -out run/cert.pem -days 365

build:
	shards build --release --ignore-crystal-version
	cp ./bin/murcure ./run/

configure:
	cp run/config.default.yml run/config.yml

run:
	cd run && ./murcure 

run_w_udp:
	cd run && ./murcure -u
