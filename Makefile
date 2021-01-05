BASE_IMAGE:=base
BASE_IMAGE_TAG:=fastapi-0.63.0
IMAGE:=app
TARGET:=dev
TAG:=local
CMD:=

format: test_modules
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m black -l 100 app
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m isort -l 100 --tc --multi-line 3 --known-local-folder app app

build:
	docker build --target ${TARGET} --build-arg BASE_IMAGE=${BASE_IMAGE} --build-arg BASE_IMAGE_TAG=${BASE_IMAGE_TAG} -t ${IMAGE}/${TARGET}:${TAG} .

build-dev:
	make build TARGET=dev

build-prod:
	make build TARGET=prod TAG=$$(git rev-parse HEAD)

build-base-image:
	cd baseimage && docker build -t ${BASE_IMAGE}:${BASE_IMAGE_TAG} .

run:
	docker run -it --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e APP_CONFIG_FILE=local ${IMAGE}/${TARGET}:${TAG} ${CMD}

requirements.lock:
	docker run -it --rm -v $$(pwd):/app ${BASE_IMAGE}:${BASE_IMAGE_TAG} bash -c 'pip install -r requirements.txt && pip freeze > requirements.lock'

test_modules:
	docker run -it --rm -v $$(pwd):/app ${BASE_IMAGE}:${BASE_IMAGE_TAG} bash -c 'pip install -t test_modules -r requirements_test.txt'

test: test_modules
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m black --check -l 100 app
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m isort --check -l 100 --tc --multi-line 3 --known-local-folder app app
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules -e APP_CONFIG_FILE=test ${IMAGE}/${TARGET}:${TAG} python3 -m pytest -v --last-failed app
	docker run --rm --name ${IMAGE} -p 80:80 -v $$(pwd):/app -e PYTHONPATH=test_modules ${IMAGE}/${TARGET}:${TAG} python3 -m mypy --ignore-missing-imports app

