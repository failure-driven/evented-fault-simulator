.DEFAULT_GOAL := usage

# user and repo
USER        = $$(whoami)
CURRENT_DIR = $(notdir $(shell pwd))

# terminal colours
RED     = \033[0;31m
GREEN   = \033[0;32m
YELLOW  = \033[0;33m
BLUE    = \033[0;34m
MAGENTA = \033[0;35m
NC      = \033[0m

.PHONY: install
install:
	brew bundle
	pushd simple-telemetry && bundle && popd
	pushd e2e-tests && bundle && popd

.PHONY: test
test:
	pushd simple-telemetry && bundle exec rake && popd
	pushd e2e-tests && bundle exec rspec && popd
		
.PHONY: demo
demo:
	@echo "demo goes here"

.PHONY:clean
clean:
	@echo "clean up here"

.PHONY: usage
usage:
	@echo
	@echo "Hi ${GREEN}${USER}!${NC} Welcome to ${RED}${CURRENT_DIR}${NC}"
	@echo
	@echo "$(COLOR $YELLOW)hi in yellow$(COLOR $NC)"
	@echo
	@echo "Getting started"
	@echo
	@echo "${YELLOW}make${NC}                     this handy usage guide"
	@echo
	@echo "${YELLOW}make install${NC}             install"
	@echo "${YELLOW}make test${NC}                run tests"
	@echo "${YELLOW}make demo${NC}                run the demo"
	@echo "${YELLOW}make clean${NC}               clean up"
	@echo
