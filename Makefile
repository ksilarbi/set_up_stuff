.PHONY = help init_project create_env remove_env 
.DEFAULT_GOAL = help

SHELL := /bin/bash

YELLOW=\033[1;33m
GREEN=\033[1;32m
BLUE=\033[1;34m
NC=\033[0m

ENV_NAME=env_name_placeholder
PYTHON_VERSION=3.7
PROJECT_NAME='project_name_placeholder'

help:
	@echo -e "${BLUE}|---------------  HELP  ----------------->${NC}"
	@echo -e "${BLUE}|${NC} Create a project -> ${GREEN}make init_project PROJECT_NAME='project_name' PYTHON_VERSION='3.7'${NC}"
	@echo -e "${BLUE}|${NC} To create a virtualenv -> ${GREEN}make create_env ENV_NAME='env_name' PYTHON_VERSION='3.7'${NC}"
	@echo -e "${BLUE}|${NC} To remove virtuenv env -> ${GREEN}make remove_env ENV_NAME='env_name'${NC}"
	@echo -e "${BLUE}|---------------------------------------->${NC}"

create_env:
	@echo -e "${YELLOW}-> Creating virtual env: $(ENV_NAME) with python version $(PYTHON_VERSION)${NC}"
	@virtualenv -p python$(PYTHON_VERSION) "$(ENV_NAME)" \
	&& source $(ENV_NAME)/bin/activate \
	&& python -m pip install pip-chill pip-tools notebook ipykernel loguru flake8 pytest \
	&& pip-chill > requirements.in \
	&& python -m ipykernel install --user --name="$(ENV_NAME)" --display-name "$(ENV_NAME)"
	@echo -e "${YELLOW}-> New env $(ENV_NAME) ready.${NC}"
	@echo -e "${YELLOW}-> you can activate it with:${NC}"
	@echo -e "${GREEN}source $(ENV_NAME)/bin/activate${NC}"

remove_env:
	@echo -e "${YELLOW}-> Cleaning up...${NC}"
	@jupyter kernelspec list | grep -q "$(echo "${ENV_NAME}" | awk '{print tolower($0)}')" \
	|| echo -e "${YELLOW}-> No kernel to remove, exiting.${NC}" \
	&& exit 0
	@echo -e "${YELLOW}-> Kernel  ${ENV_NAME} found and will be removed${NC}"
	@echo -e "${YELLOW}-> Removing kernel $(ENV_NAME).${NC}"
	@echo "${ENV_NAME}" | awk '{print tolower($0)}' | xargs -I {} jupyter kernelspec uninstall -f {}
	@echo -e "${YELLOW}-> Here are the remaining kernels:${NC}"
	@jupyter kernelspec list
	@rm -r $(ENV_NAME)
	@echo -e "${YELLOW}-> Deleted folder $(ENV_NAME).${NC}"
	@echo -e "${YELLOW}-> Done.${NC}"	

init_project:
	@$(MAKE) create_env ENV_NAME="env_$(PROJECT_NAME)" PYTHON_VERSION="$(PYTHON_VERSION)"
	@echo -e "${YELLOW}-> Creating folder $(PROJECT_NAME)${NC}"
	@mkdir $(PROJECT_NAME) \
	&& echo -e "${YELLOW}-> Moving requirements.in in $(PROJECT_NAME)${NC}" \
	&& mv requirements.in $(PROJECT_NAME) \
	&& echo -e "${YELLOW}-> Writing boilerplate README.md in $(PROJECT_NAME)${NC}" \
	&& echo -e "# Project $(PROJECT_NAME)\n\n## Installation guide\n\n## Tests\n" > $(PROJECT_NAME)/README.md \
	&& echo -e "${YELLOW}-> Editting vscode setting: flake8 options and path to env${NC}" \
	&& mkdir $(PROJECT_NAME)/.vscode/ \
	&& echo -e "{\n\t\"python.pythonPath\": \"$$(pwd)/env_${PROJECT_NAME}/bin/python\",\
			     \n\t\"python.linting.flake8Enabled\": true,\
			     \n\t\"python.linting.enabled\": true,\
			     \n\t\"python.linting.flake8Args\": [\"--max-line-length=120\", \"--verbose\"]\n}\n" \
			  > $(PROJECT_NAME)/.vscode/settings.json
	@echo -e "${YELLOW}-> Creating boilerplate .gitignore file${NC}"
	@echo -e "# secrets\nsecrets/\ncredentials/\n\n# vscode\n**/.vscode/\n\n# MACOS\n.DS_Store\n\n" > $(PROJECT_NAME)/.gitignore \
	&& curl https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore | tee >> $(PROJECT_NAME)/.gitignore
	@echo -e "${YELLOW}-> Compiling requirements.in${NC}"
	@source "env_${PROJECT_NAME}"/bin/activate \
	&& cd $(PROJECT_NAME) \
	&& pip-compile \
	&& echo -e "${YELLOW}-> Opening vscode${NC}" \
	&& code .
	@echo -e "\n\n\n${GREEN}-> Project $(PROJECT_NAME) ready. Let's start coding !${NC}"
