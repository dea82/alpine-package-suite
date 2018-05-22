.PHONY: build start stop attach
build:
	docker build -t alpine-package-builder-container .

start: build
#	docker run --privileged --cap-add SYS_ADMIN --device /dev/fuse -itd --rm --name alpine-package-builder alpine-package-builder-container
	docker run --privileged -itd --rm --name alpine-package-builder alpine-package-builder-container

	docker exec --user root alpine-package-builder mount-sshfs.sh
	docker exec alpine-package-builder buildrepo.sh

stop:
	docker container stop alpine-package-builder

attach:
	docker exec -i -t alpine-package-builder /bin/sh
