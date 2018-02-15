build-host:
	docker build -t alpine-repo-host host/

start-host: build-host
		docker run --rm --name alpine-apk-server -p80:80 -d alpine-repo-host nginx

stop-host:
	docker container stop alpine-apk-server