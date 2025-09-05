# Project Overview

## Environment Setup
Execute the `source setup.sh` command to setup the Flutter environment before making any code changes. Fix any issue reported by the `setup.sh`. 

## Task Instruction
Please follow the user instruction to implement the user story located at docs/stories/*. 
You can refer to the docs/prd.md and docs/architecture.md for more information.

If you facing issue of Flutter environment such as not able to find the flutter, dart, or melos executables in a new bash session.
Please execute `source $HOME/.bashrc` command to set the PATH environment variable as it is updated by the setup.sh.

## Before you submit changes
Make sure you execute the following commands and fix any reported error:
```bash
flutter analyze
melos generate_packages --no-select
melos generate
chromedriver --port=4444 &
sleep 3
melos ci_integration_test --no-select
```