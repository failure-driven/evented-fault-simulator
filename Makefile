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

.PHONY: demo-tmux
demo-tmux:
	tmux -L "evented-sim" new-session -d

.PHONY: tmux-reattach
tmux-reattach:
	tmux -L "evented-sim" -CC attach-session

.PHONY: tmux-down
tmux-down:
	tmux -L "evented-sim" kill-session

ENV_VARS = SIMPLE_TELEMETRY_HOST=localhost SIMPLE_TELEMETRY_PORT=1234
.PHONY: demo
demo: demo-tmux
	tmux -L "evented-sim" new-window -d -n 1 -t "0:1"
	tmux -L "evented-sim" rename-window -t "0:1" "demo"
	tmux -L "evented-sim" send-keys -t "0:1" "${ENV_VARS} ./e2e-tests/bin/simple-telemetry-server.rb" Enter
	tmux -L "evented-sim" split-window -t "0:1" -h
	tmux -L "evented-sim" send-keys -t "0:1" "repeat 3 { ${ENV_VARS} ./e2e-tests/bin/example-process.rb `uuidgen` & }" Enter
	tmux -L "evented-sim" -CC attach-session

.PHONY:clean
clean: tmux-down

.PHONY: usage
usage:
	@echo
	@echo "Hi ${GREEN}${USER}!${NC} Welcome to ${RED}${CURRENT_DIR}${NC}"
	@echo
	@echo "${MAGENTA}Getting started${NC}"
	@echo
	@echo "${YELLOW}make${NC}                     this handy usage guide"
	@echo
	@echo "${YELLOW}make install${NC}             install"
	@echo "${YELLOW}make test${NC}                run tests"
	@echo "${YELLOW}make demo${NC}                run the demo"
	@echo "${YELLOW}make clean${NC}               clean up"
	@echo
	@echo "${BLUE}TMUX related${NC}"
	@echo
	@echo "${YELLOW}make tmux-reattach${NC}       reattach to tmux session"
	@echo "${YELLOW}make tmux-down${NC}           kill tmux session (make clean)"
	@echo
