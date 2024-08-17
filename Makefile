TAG = $(shell git tag --sort=committerdate | tail -1)

create-builder:
	docker buildx rm tmp-builder
	docker buildx create --use --name=tmp-builder --platform linux/arm64,linux/amd64


build-dockerhub: create-builder
	docker buildx build --push --platform linux/arm64,linux/amd64 \
		--tag behretv/format:latest \
		--tag behretv/format:${TAG} \
		.
	docker buildx rm tmp-builder

build-gitlab: create-builder
	docker buildx build --push --platform linux/arm64,linux/amd64 \
		--provenance=false \
		--tag gitlab.lrz.de:5005/messtechnik-labor/docker/format:latest \
		--tag gitlab.lrz.de:5005/messtechnik-labor/docker/format:${TAG} \
		.
	docker buildx rm tmp-builder

