if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/llemos/Documents/GitHub/E155-uP-labs/lab1-fpga-7-seg-display/fpga/radiant_project/fpga_dev_board_test"
if {![file exists {C:/Users/llemos/Documents/GitHub/E155-uP-labs/lab1-fpga-7-seg-display/fpga/radiant_project/fpga_dev_board_test/impl_1}]} {
  file mkdir {C:/Users/llemos/Documents/GitHub/E155-uP-labs/lab1-fpga-7-seg-display/fpga/radiant_project/fpga_dev_board_test/impl_1}
}
cd {C:/Users/llemos/Documents/GitHub/E155-uP-labs/lab1-fpga-7-seg-display/fpga/radiant_project/fpga_dev_board_test/impl_1}
# synthesize IPs
# synthesize VMs
# synthesize top design
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o dev_board_test_impl_1_syn.udb dev_board_test_impl_1.vm] [list dev_board_test_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
