.PHONY: build-builder
build-builder:
	docker build -t alpine-package-builder-container .

.PHONY: start-builder
start-builder: build-builder
	docker run --privileged --cap-add SYS_ADMIN --device /dev/fuse -itd --rm --name alpine-package-builder alpine-package-builder-container
	docker exec --user root alpine-package-builder mount-sshfs.sh
	docker exec alpine-package-builder buildrepo.sh

.PHONY: stop-builder
stop-builder:
	docker container stop alpine-package-builder
