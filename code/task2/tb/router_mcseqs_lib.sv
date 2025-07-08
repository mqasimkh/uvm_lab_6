
class router_mcseqs extends uvm_sequence;
    `uvm_object_utils(router_mcseqs)
    // `include "router_mcsequencer.sv"
    `uvm_declare_p_sequencer(router_mcsequencer)

    hbus_small_packet_seq hbu_small;
    hbus_read_max_pkt_seq hbu_read;
    yapp_012_seq yapp_1;
    hbus_set_default_regs_seq hbu_large;
    six_yapp_seq yapp_2;

    function new (string name = "router_mcseqs");
        super.new(name);
    endfunction: new

    task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
    // in UVM1.2, get starting phase from method
        phase = get_starting_phase();
    `else
        phase = starting_phase;
    `endif
    if (phase != null) begin
        phase.raise_objection(this, get_type_name());
        `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
    endtask : pre_body

    virtual task body();
    super.body();
    `uvm_info(get_type_name(), "Executing router_mcseqs sequence", UVM_LOW)

    `uvm_do_on(hbu_small, p_sequencer.hbus)
    `uvm_do_on(hbu_read, p_sequencer.hbus)
    repeat(2)
        `uvm_do_on(yapp_1, p_sequencer.yapps)
    `uvm_do_on(hbu_large, p_sequencer.hbus)
    `uvm_do_on(hbu_read, p_sequencer.hbus)
    `uvm_do_on(yapp_2, p_sequencer.yapps)

    endtask: body

    task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
    // in UVM1.2, get starting phase from method
        phase = get_starting_phase();
    `else
        phase = starting_phase;
    `endif
    if (phase != null) begin
        phase.drop_objection(this, get_type_name());
        `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
    endtask : post_body

endclass