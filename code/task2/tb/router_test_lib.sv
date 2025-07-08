class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    function new (string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    router_tb tb;

    function void build_phase(uvm_phase phase);
    //     uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", 
    //     "default_sequence",
    //     yapp_5_packets::get_type());

        //tb = new("tb", this);
        tb = router_tb::type_id::create("tb", this);

        `uvm_info(get_type_name(), "Build phase of test is being executed", UVM_HIGH);
        uvm_config_int::set(this, "*", "recording_detail", 1);
    endfunction: build_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH);
    endfunction: start_of_simulation_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction: end_of_elaboration_phase

    //new added
    task run_phase (uvm_phase phase);
        uvm_objection obj;
        obj = phase.get_objection();
        obj.set_drain_time(this, 200ns);
    endtask: run_phase

    function void check_phase(uvm_phase phase);
        check_config_usage();
    endfunction: check_phase

endclass: base_test

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                simple_test                          ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

class simple_test extends base_test;
    `uvm_component_utils(simple_test)

    function new (string name = "simple_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_012_seq::get_type());
        uvm_config_wrapper::set(this, "tb.c?.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::get_type());
        uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());
    endfunction: build_phase

endclass: simple_test

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////              test_uvc_integration                   ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

class test_uvc_integration extends base_test;
    `uvm_component_utils(test_uvc_integration)

    function new (string name = "test_uvc_integration", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_four::get_type());
        uvm_config_wrapper::set(this, "tb.c?.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::get_type());
        uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());
        uvm_config_wrapper::set(this, "tb.hbu.masters[?].sequencer.run_phase", "default_sequence", hbus_small_packet_seq::get_type());
    endfunction: build_phase

endclass: test_uvc_integration

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                multi_channel                        ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

class multi_channel extends base_test;
    `uvm_component_utils(multi_channel)

    function new (string name = "multi_channel", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        uvm_config_wrapper::set(this, "tb.c?.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::get_type());
        uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());
        uvm_config_wrapper::set(this, "tb.mcseq.run_phase", "default_sequence", router_mcseqs::get_type());
    endfunction: build_phase

endclass: multi_channel

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                Short Packet Test                    ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class short_packet_test extends base_test;
//     `uvm_component_utils(short_packet_test)

//     function new (string name = "short_packet_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
//     endfunction: build_phase
// endclass: short_packet_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                Set Config Test                      ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class set_config_test extends base_test;
//     `uvm_component_utils(set_config_test)

//     function new (string name = "set_config_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         uvm_config_int::set(this, "tb.uvc.agent", "is_active", UVM_PASSIVE);
//         super.build_phase(phase);
//     endfunction: build_phase

// endclass: set_config_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                incr_payload_test                    ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class incr_payload_test extends base_test;
//     `uvm_component_utils(incr_payload_test)

//     function new (string name = "incr_payload_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
//         uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_incr_payload_seq::get_type());
//     endfunction: build_phase

// endclass: incr_payload_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                exhaustive_seq_test                  ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class exhaustive_seq_test extends base_test;
//     `uvm_component_utils(exhaustive_seq_test)

//     function new (string name = "exhaustive_seq_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
//         uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_exhaustive_seq::get_type());
//     endfunction: build_phase

// endclass: exhaustive_seq_test

// /////////////////////////////////////////////////////////////////////////////////////////////////////
// ////////////////////////                task_2_test                          ////////////////////////
// /////////////////////////////////////////////////////////////////////////////////////////////////////

// class task_2_test extends base_test;
//     `uvm_component_utils(task_2_test)

//     function new (string name = "task_2_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
//         uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_012_seq::get_type());
//     endfunction: build_phase

// endclass: task_2_test