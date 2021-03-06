BASE_IMAGE:=base
BASE_IMAGE_TAG:=fastapi-0.63.0
IMAGE:=app
TARGET:=dev
TAG:=local
CMD:=
MARK:="not optional"

format: test_modules
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m black app
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m isort app

build: requirements.lock
	docker build --target ${TARGET} --build-arg BASE_IMAGE=${BASE_IMAGE} --build-arg BASE_IMAGE_TAG=${BASE_IMAGE_TAG} -t ${IMAGE}/${TARGET}:${TAG} .

build-dev:
	@make build TARGET=dev

build-prod:
	@make build TARGET=prod TAG=$$(git rev-parse HEAD)

build-base-image:
	cd baseimage && docker build -t ${BASE_IMAGE}:${BASE_IMAGE_TAG} .

run:
	docker run -it --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e APP_CONFIG_FILE=local ${IMAGE}/${TARGET}:${TAG} ${CMD}

requirements.lock:
	docker run -it --rm -v $$(pwd):/app ${BASE_IMAGE}:${BASE_IMAGE_TAG} bash -c 'pip install -r requirements.txt && pip freeze > requirements.lock'

test_modules:
	docker run -it --rm -v $$(pwd):/app ${BASE_IMAGE}:${BASE_IMAGE_TAG} bash -c 'pip install -t test_modules -r requirements_test.txt'

test: test_modules
	@make test-format
	@make test-pytest
	@make test-mypy

test-format:
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m black --check app
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m isort --check app

test-mypy:
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m mypy app

test-pytest:
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m pytest -m ${MARK}

test-all:
	@make test MARK='""'
