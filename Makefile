.PHONY: all build watch

all: build

build:
	NODE_ENV=production node_modules/.bin/webpack

watch:
	node_modules/.bin/webpack --watch

couch: build
	node_modules/.bin/couchapp push couchapp.js http://localhost:5984/ideas
