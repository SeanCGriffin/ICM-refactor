# Based on code from ComPair and BurstCube projects, originally ported from NASA GSFC Code 500 SDL. 

set BUILD "[lindex $argv 0]"

# get the directory where this script resides
set thisDir [file dirname [info script]]

# source common utilities
source -notrace $thisDir/utils.tcl

set PROJECT_BASE [file normalize "$thisDir/../"]
set CORES_BASE [file normalize "$PROJECT_BASE/cores/"]
set BUILD_WORKSPACE [file normalize "$PROJECT_BASE/work/$BUILD"]
set HDL_SRC_DIR [file normalize "$PROJECT_BASE/src/hdl"]

puts "================================================"
puts "     PROJECT_BASE: $PROJECT_BASE"
puts "            BUILD: $BUILD"
puts "       CORES_BASE: $CORES_BASE"
puts "  BUILD_WORKSPACE: $BUILD_WORKSPACE"
puts "================================================"

#set_param board.repoPaths $PROJECT_BASE/board_files/

create_project -force $BUILD $BUILD_WORKSPACE/project -part xa7s25ftgb196-2I

#update_ip_catalog

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $BUILD]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/$BUILD.cache/ip" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj

puts "INFO: Project created: $BUILD"

### Include HDL

# Create 'sources_1' fileset (if not found)

if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

#Import common build files.
set obj [get_filesets sources_1]
set files [glob $PROJECT_BASE/src/common/vhdl/*]
add_files -norecurse -fileset $obj $files
#Import build-specific files.
set obj [get_filesets sources_1]
set files [glob $PROJECT_BASE/src/$BUILD/*]
add_files -norecurse -fileset $obj $files

# Set the file types for everything we just imported. 
set file_obj [get_files -of_objects [get_filesets sources_1]]
#puts $file_obj
set_property -name "file_type" -value "VHDL" -objects $file_obj

# Now import IP xci files:
set files [ glob $PROJECT_BASE/src/common/ip_cores/*.xci]
import_ip $files

generate_target all [get_ips]

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "icm_top_020" -objects $obj




### Include constraints 
# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]
# Add/Import constrs file and set constrs file properties
set file "[file normalize "$PROJECT_BASE/src/constr/$BUILD.xdc"]"
add_files -norecurse -fileset $obj $file



# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -flow {Vivado Synthesis 2020} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2020" [get_runs synth_1]
}

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -flow {Vivado Implementation 2020} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2020" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj





touch {.setup.done}