# test/Makefile

SIM            ?= icarus
TOPLEVEL_LANG  ?= verilog

SRC_DIR         = $(PWD)/../src
PROJECT_SOURCES = project.v

ifneq ($(GATES),yes)
  SIM_BUILD        = sim_build/rtl
  VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
else
  SIM_BUILD        = sim_build/gl
  COMPILE_ARGS    += -DGL_TEST -DFUNCTIONAL -DUSE_POWER_PINS -DSIM -DUNIT_DELAY=\#1
  VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
  VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
  VERILOG_SOURCES += $(PWD)/gate_level_netlist.v
endif

# Include design headers
COMPILE_ARGS    += -I$(SRC_DIR)

# **Use COMPILE_ARGS, not EXTRA_ARGS, for -g2012**
COMPILE_ARGS    += -g2012

# Testbench & Python module
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL         = tb
MODULE           = test

# Always emit results.xml here
export COCOTB_RESULTS_FILE := $(PWD)/results.xml

WAVES ?= 1
export IVERILOG_DUMPER := fst       # or vcd, either is fine
export DUMPFILE := $(PWD)/tb.vcd    # matches your CI upload path


include $(shell cocotb-config --makefiles)/Makefile.sim
