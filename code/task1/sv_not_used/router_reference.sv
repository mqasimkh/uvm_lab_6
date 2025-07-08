class router_reference extends uvm_component;
    `uvm_component_utils(router_reference)

    `uvm_analysis_imp_decl(_yapp)
    `uvm_analysis_imp_decl(_hbus)

    uvm_analysis_port #(yapp_packet) yapp_valid;

    uvm_analysis_imp_yapp #(yapp_packet,         router_reference)      yapp_in;
    uvm_analysis_imp_hbus #(hbus_transaction,    router_reference)      hbus_in;

    int maxpktsize;
    bit router_en;
    int invalid_packets_size, invalid_packets_addr, invalid_packets_en;

    function new (string name = "router_reference", uvm_component parent);
        super.new(name, parent);
        yapp_in = new("yapp_in", this);
        hbus_in = new("hbus_in", this);
        yapp_valid = new ("yapp_valid", this);
    endfunction: new

    function void write_hbus(hbus_transaction hbu_pkt);
        hbus_transaction pkt_p;
        $cast(pkt_p, hbu_pkt.clone());
        if (pkt_p.haddr == 16'h1000)
            maxpktsize = pkt_p.hdata;
        if (pkt_p.haddr == 16'h1001)
            router_en = 1;
    endfunction: write_hbus

    function void write_yapp (input yapp_packet packet);
        yapp_packet yp;
        $cast(yp, packet.clone());

        if ((router_en) && (packet.length <= maxpktsize)) begin
            yapp_valid.write(packet);
        end

        else if (!router_en)
            invalid_packets_en++;

        else if (packet.length > maxpktsize)
            invalid_packets_size++;

        else if (packet.addr == 3)
            invalid_packets_addr++;

    endfunction: write_yapp

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
//                                      report_phase
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

    function void report_phase (uvm_phase phase);
        $display("===============================================================================================================================================");
        $display("                                                    REFERENCE MODEL REPORT                                                                     ");
        $display("===============================================================================================================================================");
        `uvm_info(get_type_name(), $sformatf("Packets Dropped Due to Size\t:   %0d", invalid_packets_size), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Packets Dropped Due to Add\t:   %0d", invalid_packets_addr), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Packets Dropped Due to Enable\t:   %0d", invalid_packets_en), UVM_LOW)
        $display("------------------------------------------------------------------------------------------------------------------------------------------------");
    endfunction: report_phase

endclass: router_reference