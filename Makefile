
.PHONY: help
help:
	@# Magic line used to create self-documenting makefiles.
	@# See https://stackoverflow.com/a/35730928
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' Makefile | column -s: -t

.PHONY: all
# Install everything needed for development and run all checks.
all: install check

.PHONY: install
# Install everything needed for development.
install:
	python -m pip install pipenv
	python -m pipenv --rm || true
	python -m pipenv install --dev

.PHONY: check
# Run all formatting and linting checks.
check:
	# Run all formatting and linting checks:
	python -m pipenv run black --check src
	python -m pipenv run black --check tests
	python -m pipenv run isort --profile black --check-only src
	python -m pipenv run isort --profile black --check-only tests
	python -m pipenv run pydocstyle src
	python -m pipenv run mypy src
	python -m pipenv run flake8 --show-source --statistics src
	python -m pipenv run flake8 --show-source --statistics tests
	# Checking package safety
	python -m pipenv check

.PHONY: format
# Run code formatters.
format:
	# Format code via black and imports via isort:
	python -m pipenv run black src
	python -m pipenv run black tests
	python -m pipenv run isort --profile black src
	python -m pipenv run isort --profile black tests

.PHONY: docs
# Build the API documentation.
docs:
	python -m pipenv run lazydocs --overview-file=README.md --src-base-url=https://github.com/lukasmasuch/streamlit-pydantic/blob/main streamlit_pydantic

.PHONY: build
# Build everything for release.
build: docs
	rm -rf ./dist
	rm -rf ./build
	python -m pipenv run python -m build
	python -m pipenv run twine check dist/*

.PHONY: test
# Run unit tests.
test:
	python -m pipenv run coverage erase
	python -m pipenv run pytest -m "not slow"

.PHONY: release
# Build everything and upload distribution to PyPi.
release: build
	twine upload -u "__token__" dist/*
