class router_mcsequencer extends uvm_sequencer;

    `uvm_component_utils(router_mcsequencer)

    hbus_master_sequencer hbus;
    yapp_tx_sequencer yapps;

    function new (string name = "router_mcsequencer", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH);
    endfunction: start_of_simulation_phase

endclass