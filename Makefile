
.PHONY: run build

run: build
	love .

build:
	moonc .