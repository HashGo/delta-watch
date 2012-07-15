PROJECT = delta-watch
PROJECT_DIR = $(shell pwd)
VERSION=$(shell perl -wnl -e '/"version"\s*:\s*"([^"]+)"/ and print $$1' package.json)

TESTTIMEOUT = 15000
REPORTER 	= spec
TESTS = $(shell find test -name \*.coffee)

install:
	npm install

version:
	@echo $(VERSION)

build:
	@find src -name "*.coffee" -print0 | xargs -0 ./node_modules/coffeelint/bin/coffeelint -f coffeelint.json
	@mkdir -p lib && coffee -c -o lib src

clean:
	@rm -rf lib 

test:
	@NODE_ENV=test ./node_modules/mocha/bin/mocha -c -b --compilers coffee:coffee-script --reporter $(REPORTER) --timeout $(TESTTIMEOUT) $(TESTS)

all: install build test

.PHONY: all test

