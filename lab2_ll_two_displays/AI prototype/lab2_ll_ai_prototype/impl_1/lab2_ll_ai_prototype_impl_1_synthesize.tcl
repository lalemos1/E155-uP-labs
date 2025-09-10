if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2024.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/llemos/Documents/GitHub/E155-uP-labs/lab2_ll_two_displays/AI prototype/lab2_ll_ai_prototype"
if {![file exists {C:/Users/llemos/Documents/GitHub/E155-uP-labs/lab2_ll_two_displays/AI prototype/lab2_ll_ai_prototype/impl_1}]} {
  file mkdir {C:/Users/llemos/Documents/GitHub/E155-uP-labs/lab2_ll_two_displays/AI prototype/lab2_ll_ai_prototype/impl_1}
}
cd {C:/Users/llemos/Documents/GitHub/E155-uP-labs/lab2_ll_two_displays/AI prototype/lab2_ll_ai_prototype/impl_1}
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- lab2_ll_ai_prototype_impl_1.vm lab2_ll_ai_prototype_impl_1.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/llemos/Documents/GitHub/E155-uP-labs/lab2_ll_two_displays/AI prototype/lab2_ll_ai_prototype/impl_1/lab2_ll_ai_prototype_impl_1_lattice.synproj" -logfile "lab2_ll_ai_prototype_impl_1_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o lab2_ll_ai_prototype_impl_1_syn.udb lab2_ll_ai_prototype_impl_1.vm] [list lab2_ll_ai_prototype_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
