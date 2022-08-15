setup:
	# Create python virtualenv & source it
	# source ~/.devops/bin/activate
	python3 -m venv ~/.devops

install:
	# This should be run from inside a virtualenv
	. ~/.devops/bin/activate
	pip install --upgrade pip && \
		pip install -r requirements.txt

validate-circleci:
	# See https://circleci.com/docs/2.0/local-cli/#processing-a-config
	circleci config process .circleci/config.yml 

run-circleci-local:
	# See https://circleci.com/docs/2.0/local-cli/#running-a-job
	# chgrp -R git objects
	# chmod -R g+rws objects
	# chmod -R 777 .git/objects
	circleci local execute 
deploy-cloud9:
	# See https://circleci.com/docs/2.0/local-cli/#running-a-job
	circleci local execute --job deploy-cloud9
test:
	# Additional, optional, tests could go here
	#python -m pytest -vv --cov=myrepolib tests/*.py
	#python -m pytest --nbval notebook.ipynb

lint:
	. ~/.devops/bin/activate
	# See local hadolint install instructions:   https://github.com/hadolint/hadolint
	# This is linter for Dockerfiles
	hadolint Dockerfile
	# This is a linter for Python source code linter: https://www.pylint.org/
	# This should be run from inside a virtualenv
	pylint --disable=R,C,W1203,W1202 app.py
	# This is the linter for cloudformation
	cfn-lint ecs.yaml

all: install lint test