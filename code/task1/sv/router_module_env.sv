class router_module_env extends uvm_env;
    `uvm_component_utils(router_module_env)

    router_reference reference_model;
    router_scoreboard scoreboard;

    function new (string name = "router_module_env", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        reference_model = router_reference::type_id::create("router_reference", this);
        scoreboard = router_scoreboard::type_id::create("router_scoreboard", this);

    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        reference_model.yapp_valid.connect(scoreboard.yapp_in);
    endfunction: connect_phase

endclass: router_module_env