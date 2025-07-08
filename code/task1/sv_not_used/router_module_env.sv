class router_module_env extends uvm_env;
    `uvm_component_utils(router_module_env)

    router_reference reference_model;
    router_scoreboard scoreboard;

    uvm_analysis_export #(yapp_packet) ref_model_yapp;
    uvm_analysis_export #(hbus_transaction) ref_model_hbus;

    uvm_analysis_export #(channel_packet) scr_chan0;
    uvm_analysis_export #(channel_packet) scr_chan1;
    uvm_analysis_export #(channel_packet) scr_chan2;


    function new (string name = "router_module_env", uvm_component parent);
        super.new(name, parent);

        ref_model_yapp = new("ref_model_yapp", this);
        ref_model_hbus = new("ref_model_hbus", this);

        scr_chan0 = new("scr_chan0", this);
        scr_chan1 = new("scr_chan1", this);
        scr_chan2 = new("scr_chan2", this);

    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        reference_model = router_reference::type_id::create("router_reference", this);
        scoreboard = router_scoreboard::type_id::create("router_scoreboard", this);

    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        reference_model.yapp_valid.connect(scoreboard.yapp_in);

        ref_model_yapp.connect(reference_model.yapp_in);
        ref_model_hbus.connect(reference_model.hbus_in);

        scr_chan0.connect(scoreboard.chann0_in);
        scr_chan1.connect(scoreboard.chann1_in);
        scr_chan2.connect(scoreboard.chann2_in);

    endfunction: connect_phase

endclass: router_module_env