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
	pushd simulator-frontend && npm install && popd

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
	tmux -L "evented-sim" send-keys -t "0:1" "sleep 10 && tmux -L "evented-sim" send-keys -t "0:1".0 C-c" Enter
	tmux -L "evented-sim" -CC attach-session

.PHONY:launch-server
launch-server:
	@echo "experimenetal 🧪 web server 🔫"
	@echo "will need to find puma job to kill it"
	@echo "\n\t${YELLOW}ps aux | grep puma${NC}"
	@echo "\n\t${YELLOW}ps aux | grep simple-telemetry-server | \\\\ ${NC}"
	@echo "\t  ${YELLOW}awk '{print "'$$2'"}' | xargs kill -9${NC}"
	@echo "\n\t${YELLOW}kill -9 <PID>${NC}\n"
	SIMPLE_TELEMETRY_WEB_SERVER=1 \
		SIMPLE_TELEMETRY_HOST=localhost \
		SIMPLE_TELEMETRY_PORT=1234 \
		SIMPLE_TELEMETRY_WEB_PORT=9292 \
		e2e-tests/bin/simple-telemetry-server.rb

.PHONY:kill-server
kill-server:
	ps aux | grep simple-telemetry-server | \
	  awk '{print $$2}' | xargs kill -9

.PHONY:launch-simulator
launch-simulator:
	@echo "experimenetal 🧪 simulator frontend 🔫"
	pushd simulator-frontend && npm start && popd

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
	@echo "${GREEN}🔬 experimental 🔫${NC}"
	@echo
	@echo "${YELLOW}make launch-server${NC}       launch telemetry server with web enabled"
	@echo "${RED}make kill-server${NC}         kill server"
	@echo "${YELLOW}make launch-simulator${NC}    launch simulator frontend"
	@echo
