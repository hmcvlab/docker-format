.PHONY: format lint test build deploy install-hooks

URL = hmcvlab
NAME = format
HASH = $(shell git rev-parse --short HEAD)
TAG = $(shell git tag --sort=committerdate | tail -1)

format:
	docker run --rm -v .:/app \
		${URL}/format:latest

lint:
	docker run --rm -v .:/app \
		${URL}/lint:latest

build:
	docker build -t ${URL}/${NAME}:${HASH} --file Dockerfile .

test:
	docker run --rm --tty \
		--entrypoint "" \
		-v .:/app \
		${URL}/${NAME}:${HASH} \
		pytest

deploy: test
	docker buildx create --use --name tmp-builder && \
	docker buildx build \
		-t ${URL}/${NAME}:${TAG} \
		-t ${URL}/${NAME}:latest \
		--push \
		--platform linux/amd64,linux/arm64 \
		--file Dockerfile . && \
	docker buildx rm tmp-builder

install-hooks:
	@echo "make format && make lint" > .git/hooks/pre-commit
	@echo "make test" > .git/hooks/pre-push
	chmod +x .git/hooks/pre-*
