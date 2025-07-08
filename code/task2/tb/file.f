-timescale 1ns/1ns

-incdir ../../yapp/sv
-incdir ../../channel/sv
-incdir ../../hbus/sv
-incdir ../../clock_and_reset/sv
-incdir ../../router_module_uvc

-incdir ./tb
-incdir ../sv
-incdir ../../router_rtl

../../yapp/sv/yapp_if.sv
../../yapp/sv/yapp_pkg.sv

../../channel/sv/channel_if.sv
../../channel/sv/channel_pkg.sv

../../hbus/sv/hbus_if.sv
../../hbus/sv/hbus_pkg.sv

../../clock_and_reset/sv/clock_and_reset_if.sv
../../clock_and_reset/sv/clock_and_reset_pkg.sv

// ../sv/router_module.sv

../../router_module_uvc/router_module.sv

clkgen.sv
../../router_rtl/yapp_router.sv
hw_top_dut.sv
tb_top.sv

+UVM_TESTNAME=multi_channel
+UVM_VERBOSITY=UVM_HIGH