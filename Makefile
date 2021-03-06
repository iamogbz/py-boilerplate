$(shell test -s ".env" || cp ".env.example" ".env")
ifdef CI
	PYTHON=python
else
	PYTHON=venv/bin/python
endif

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
	@echo "inv --list                        - show installed invoke commands"

.PHONY: venv
venv:
	test -d venv || python3 -m venv venv
	touch venv/bin/activate

.PHONY: install
install: venv
	$(PYTHON) -m pip install -U pip
	$(PYTHON) -m pip install -Ur requirements.txt
	$(PYTHON) -m python_githooks

ifndef VERBOSE
.SILENT:
endif
