.PHONY: build-host
build-host:
	docker build -t alpine-repo-host host/

.PHONY: start-host
start-host: build-host
		docker run --rm --name alpine-apk-server -p80:80 -d alpine-repo-host nginx

.PHONY: stop-host
stop-host:
	docker container stop alpine-apk-server

.PHONY: build-builder
build-builder:
	docker build -t alpine-package-builder builder/
