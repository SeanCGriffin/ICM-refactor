#
#  IceCube Comms Module Project Makefile
#

ROOTDIR=../..#$(PWD)

# Common options
VIVADOCOMOPS = -mode batch
XSCTCOMOPS = -batch

# Determine the OS shell
UNAME := $(shell uname)

# on windows you have to prefix vivado call with a cmd shell with /c
ifeq ($(UNAME), Linux)
PREFIX =
POSTFIX =
else
PREFIX = cmd //c "
POSTFIX = "
endif


ifndef BUILD
$(info **********)
$(info BUILD not set)
$(info On Linux: export BUILD=<build>)
$(info On Windows: set BUILD=<build>)
$(info Valid BUILD options = {ICM_in_ice, ICM_mini_fieldhub})
$(info **********)
$(error Error: Need to set BUILD in environment.)
endif

SETUP_PROJECT = -source $(ROOTDIR)/scripts/setup_project.tcl -log setup.log -jou setup.jou -notrace -tclargs $(BUILD)
COMPILE_PROJECT = -source $(ROOTDIR)/scripts/compile.tcl -log compile.log -jou compile.jou -notrace -tclargs $(BUILD) 

all: setup 

# Launch the Vivado gui.
launch :
	@echo "================================================"
	@echo "    Launching Vivado GUI..."
	cd work/$(BUILD); $(PREFIX) vivado project/$(BUILD).xpr $(POSTFIX)

setup : ./work/$(BUILD)/.setup.done
./work/$(BUILD)/.setup.done :
	@echo "================================================"
	@echo "    Running $(BUILD) setup"
	scripts/mk_project_dir.sh
	@echo $(PWD)
	cd work/$(BUILD); $(PREFIX) vivado $(VIVADOCOMOPS) $(SETUP_PROJECT) $(POSTFIX)

compile : ./work/$(BUILD)/.compile.done 
./work/$(BUILD)/.compile.done : ./work/$(BUILD)/.setup.done
	cd work/$(BUILD); $(PREFIX) vivado $(VIVADOCOMOPS) $(COMPILE_PROJECT) $(POSTFIX)

# Remove the work directory. Cannot be undone!
clean:
	@echo "================================================"
	@echo "    Removing working directory."
	rm -rf work
	mkdir work

help:
	@echo "================================================"
	@echo "Valid BUILD options = {ICM_in_ice, ICM_mini_fieldhub}"
	@echo ""
	@echo "Make options:"
	@echo "setup                -- Generate project."
	@echo "compile              -- Compile."
	@echo "Launch               -- Launch Vivado."
	@echo "help                 -- Prints this help."