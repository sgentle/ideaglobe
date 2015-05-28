.PHONY: all build watch

all: build

build:
	NODE_ENV=production node_modules/.bin/webpack

watch:
	node_modules/.bin/webpack --watch
