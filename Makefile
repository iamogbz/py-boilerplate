$(shell test -s ".env" || cp ".env.example" ".env")

.PHONY: upstream
upstream:
	@git remote add upstream https://github.com/iamogbz/py-boilerplate
	@git push origin master
	@git push --all
	@echo "upstream: remote successfully configured"

.PHONY: eject
eject:
	@git fetch --all --prune
	@git checkout -b boilerplate-ejection
	@git pull upstream master --allow-unrelated-histories --no-edit -Xours
	@git pull upstream boilerplate-ejection --no-edit -Xours
	@git reset master --soft && git add --all && git commit -m "chore: eject" -n
	@echo "eject: branch created, complete by replacing placeholder values"

.PHONY: help
help:
	@echo "make help                         - show commands that can be run"
	@echo "make install                      - install project requirements"
	@echo "make test keyword='Parse'         - run only test match keyword"
	@echo "make tests                        - run all tests"
	@echo "make coverage                     - run all tests and collect coverage"
	@echo "make build                        - build executable from src"

.PHONY: venv
venv:
	test -d venv || python3 -m venv venv
	touch venv/bin/activate

.PHONY: install
install: venv
	venv/bin/python -m pip install -U pip
	venv/bin/python -m pip install -Ur requirements.txt
	venv/bin/python -m python_githooks

ifndef VERBOSE
.SILENT:
endif
