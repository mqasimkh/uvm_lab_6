class router_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(router_scoreboard)

    `uvm_analysis_imp_decl (_yapp)
    `uvm_analysis_imp_decl (_chann0)
    `uvm_analysis_imp_decl (_chann1)
    `uvm_analysis_imp_decl (_chann2)

    int received = 0;
    int matched = 0;
    int wrong = 0;

    yapp_packet q0[$];
    yapp_packet q1[$];
    yapp_packet q2[$];

    uvm_analysis_imp_yapp   #(yapp_packet,    router_scoreboard)   yapp_in;
    uvm_analysis_imp_chann0 #(channel_packet, router_scoreboard) chann0_in;
    uvm_analysis_imp_chann1 #(channel_packet, router_scoreboard) chann1_in;
    uvm_analysis_imp_chann2 #(channel_packet, router_scoreboard) chann2_in;

    function new (string name = "router_scoreboard", uvm_component parent);
        super.new(name, parent);
        yapp_in = new ("yapp_in", this);
        chann0_in = new ("chann0_in", this);
        chann1_in = new ("chann1_in", this);
        chann2_in = new ("chann2_in", this);
    endfunction: new

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                 write yapp method                   ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

    function void write_yapp (input yapp_packet packet);
        yapp_packet yp;
        $cast(yp, packet.clone());
        case(yp.addr)
            2'b00: q0.push_back(yp);
            2'b01: q1.push_back(yp);
            2'b10: q2.push_back(yp);
        endcase
    endfunction: write_yapp


/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                write channel methods                ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

    function void write_chann0(input channel_packet packet);
        yapp_packet yp;
        yp = q0.pop_front();
        received++;
        //if (comp_equal(yp, packet)) begin
        if (custom_comp(yp, packet)) begin
            `uvm_info("MATCHED", "PACKET is MATCHED at Channel 0", UVM_LOW)
            matched++;
        end
        else begin
            `uvm_info("WRONG", "PACKET is NOT MATCHED", UVM_LOW)
            wrong++;
        end
    endfunction: write_chann0

    function void write_chann1(input channel_packet packet);
        yapp_packet yp;
        yp = q1.pop_front();
        received++;
        //if (comp_equal(yp, packet)) begin
        if (custom_comp(yp, packet)) begin
            `uvm_info("MATCHED", "PACKET is MATCHED at Channel 1", UVM_LOW)
            matched++;
        end
        else begin
            `uvm_info("WRONG", "PACKET is NOT MATCHED", UVM_LOW)
            wrong++;
        end
    endfunction: write_chann1

    function void write_chann2(input channel_packet packet);
        yapp_packet yp;
        yp = q2.pop_front();
        received++;
        //if (comp_equal(yp, packet)) begin
        if (custom_comp(yp, packet)) begin
            `uvm_info("MATCHED", "PACKET is MATCHED at Channel 2", UVM_LOW)
            matched++;
        end
        else begin
            `uvm_info("WRONG", "PACKET is NOT MATCHED", UVM_LOW)
            wrong++;
        end
    endfunction: write_chann2

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                comp_equal function                  ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

    function bit comp_equal (input yapp_packet yp, input channel_packet cp);
    // returns first mismatch only
    if (yp.addr != cp.addr) begin
        `uvm_error("PKT_COMPARE",$sformatf("Address mismatch YAPP %0d Chan %0d",yp.addr,cp.addr))
        return(0);
    end

    if (yp.length != cp.length) begin
        `uvm_error("PKT_COMPARE",$sformatf("Length mismatch YAPP %0d Chan %0d",yp.length,cp.length))
        return(0);
    end

    foreach (yp.payload [i])

    if (yp.payload[i] != cp.payload[i]) begin
        `uvm_error("PKT_COMPARE",$sformatf("Payload[%0d] mismatch YAPP %0d Chan %0d",i,yp.payload[i],cp.payload[i]))
        return(0);
    end

    if (yp.parity != cp.parity) begin
        `uvm_error("PKT_COMPARE",$sformatf("Parity mismatch YAPP %0d Chan %0d",yp.parity,cp.parity))
        return(0);
    end

    return(1);

    endfunction: comp_equal


/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                  custom_comp method                 ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

    function bit custom_comp (yapp_packet yp, channel_packet cp, uvm_comparer comparer = null);
        if (comparer == null)
            comparer = new();
        
        custom_comp = comparer.compare_field("addr", yp.addr, cp.addr, 2);
        custom_comp &= comparer.compare_field("length", yp.length, cp.length, 6);
        custom_comp &= comparer.compare_field("parity", yp.parity, cp.parity, 8);

        foreach (yp.payload [i])
            custom_comp &= comparer.compare_field("payload", yp.payload[i], cp.payload[i], 8);

        return custom_comp;
    endfunction: custom_comp

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
//                                      report_phase
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

    function void report_phase (uvm_phase phase);
        $display("===============================================================================================================================================");
        $display("                                                      SCOREBOARD REPORT                                                                        ");
        $display("===============================================================================================================================================");
        `uvm_info(get_type_name(), $sformatf("Total Packets Received\t:   %0d", received), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Packets Matched\t:   %0d", matched), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Packets Mis-Matched\t:   %0d", wrong), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Packets Left in Queue 0\t:   %0d", q0.size()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Packets Left in Queue 1\t:   %0d", q1.size()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Packets Left in Queue 2\t:   %0d", q2.size()), UVM_LOW)
        $display("------------------------------------------------------------------------------------------------------------------------------------------------");
    endfunction: report_phase

endclass: router_scoreboard
