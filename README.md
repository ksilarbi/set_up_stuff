# set_up_stuff
Juste a few helper scripts and Makefiles to set up boilerplate python projects

## The Makefile to init a project folder 

This makefile creates a virtualenv, installs some tools I usually use and sets up a gitignore and vscode settings...

- have `make` installed on your machine:
    - Linux: `sudo apt-get install build-essential`
    - MacOS: `brew install make`
- have `virtualenv` installed on your machine:
    - `python -m pip install virtualenv`
- then run:
```bash
make init_project PROJECT_NAME='project_name' PYTHON_VERSION='3.7'
```
