PID = tmp/.pid
PORT = 3000
CLUSTER = auto

NODE = node
GRUNT = ./node_modules/.bin/grunt
MOCHA = ./node_modules/.bin/mocha
BOWER = ./node_modules/.bin/bower
FOREMAN = bundle exec foreman

REPORTER = dot
MOCHA_OPTS = --colors --growl --bail --check-leaks

debug:
	@$(FOREMAN) start -p $(PORT) -f Procfile

start:
	@[[ ! -f $(PID) ]] && NODE_PID=$(PID) NODE_CLUSTER=$(CLUSTER) NODE_ENV=production  $(NODE) ./bin/www

start-dev:
	@[[ ! -f $(PID) ]] && NODE_PID=$(PID) NODE_CLUSTER=$(CLUSTER) NODE_ENV=development $(NODE) ./bin/www

quit:
	@[[ -f $(PID) ]] && kill -s QUIT `cat $(PID)` && sleep 1

stop:
	@[[ -f $(PID) ]] && kill -s TERM `cat $(PID)`

reload:
	@[[ -f $(PID) ]] && kill -s WINCH `cat $(PID)`

restart: quit start

build:
	@$(GRUNT) production

build-dev:
	@$(GRUNT) development

test:
	@./node_modules/.bin/mocha \
		--compilers coffee:coffee-script/register \
		--reporter $(REPORTER) \
		--recursive test \
		$(MOCHA_OPTS)

setup:
	@echo "\n===> bundle install\n"
	@bundle install --path=vendor/bundle && bundle update && bundle clean
	@echo "\n===> npm install\n"
	@npm install && npm prune
	@echo "\n===> npm prune\n"
	@npm prune
	@echo "\n===> npm dedupe\n"
	@npm dedupe
	@echo "\n===> bower install\n"
	@$(BOWER) install
	@echo "\n===> bower prune\n"
	@$(BOWER) prune

.PHONY: debug start start-dev quit stop reload restart build build-dev test setup

