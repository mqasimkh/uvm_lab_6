class router_scoreboard_new extends uvm_scoreboard;
    `uvm_component_utils(router_scoreboard_new)

    uvm_tlm_analysis_fifo #(yapp_packet) yapp_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chann0_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chann1_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chann2_fifo;
    uvm_tlm_analysis_fifo #(hbus_transaction) hbus_fifo;

    uvm_get_port #(yapp_packet) yapp_get;
    uvm_get_port #(channel_packet) chann0_get;
    uvm_get_port #(channel_packet) chann1_get;
    uvm_get_port #(channel_packet) chann2_get;
    uvm_get_port #(hbus_transaction) hbus_get;

    int received = 0;
    int matched = 0;
    int wrong = 0;
    int maxpktsize=63;
    int router_en=1;

    int droppped;
    int not_droppped;

    function new (string name = "router_scoreboard_new", uvm_component parent);
        super.new(name, parent);

        yapp_fifo = new ("yapp_fifo", this);
        chann0_fifo = new ("chann0_fifo", this);
        chann1_fifo = new ("chann1_fifo", this);
        chann2_fifo = new ("chann2_fifo", this);
        hbus_fifo = new ("hbus_fifo", this);

        yapp_get = new ("yapp_get", this);
        chann0_get = new ("chann0_get", this);
        chann1_get = new ("chann1_get", this);
        chann2_get = new ("chann2_get", this);
        hbus_get = new ("hbus_get", this);

    endfunction: new

//-----------------------------------------------------------------------------------------------------
//                                      connect_phase
//-----------------------------------------------------------------------------------------------------

    function void connect_phase (uvm_phase phase);

        yapp_get.connect(yapp_fifo.get_peek_export);
        chann0_get.connect(chann0_fifo.get_peek_export);
        chann1_get.connect(chann1_fifo.get_peek_export);
        chann2_get.connect(chann2_fifo.get_peek_export);
        hbus_get.connect(hbus_fifo.get_peek_export);

    endfunction: connect_phase

//-----------------------------------------------------------------------------------------------------
//                                     run_phase
//-----------------------------------------------------------------------------------------------------

    task run_phase (uvm_phase phase);
        fork
            yapp_pkt_method();
            hbus_f();
        join
    endtask: run_phase

//-----------------------------------------------------------------------------------------------------
//                                     yapp_pkt_method
//-----------------------------------------------------------------------------------------------------

    task yapp_pkt_method();
        yapp_packet pkt;
        channel_packet cp;
        forever begin

        yapp_get.get(pkt);
        received++;
        // if (!(!router_en || (maxpktsize > pkt.length) || (pkt.addr > 2))) begin
        if ((!router_en)|| (pkt.length > maxpktsize) || (pkt.addr > 2 ) ) begin
            `uvm_info(get_type_name(), "PACKET DROPPED", UVM_LOW)
            droppped++;
        end
        else begin
            case(pkt.addr)
                2'b00: chann0_get.get(cp);
                2'b01: chann1_get.get(cp);
                2'b10: chann2_get.get(cp);
            endcase
            not_droppped++;
            if (custom_comp(pkt, cp)) begin
                `uvm_info(get_type_name(), "PACKET MATCHED", UVM_LOW)
                matched++;
            end
            else begin
                `uvm_info(get_type_name(), "PACKET WRONG", UVM_LOW)
                wrong++;
            end
        end
        end
    endtask: yapp_pkt_method

//-----------------------------------------------------------------------------------------------------
//                                     hbus_function
//-----------------------------------------------------------------------------------------------------

    task hbus_f();
        hbus_transaction hbus_pkt;
        hbus_get.get(hbus_pkt);
        if (hbus_pkt.haddr == 16'h1001) begin
            router_en = 1;
        end
        if (hbus_pkt.haddr == 16'h1000) begin
            maxpktsize = hbus_pkt.hdata;
        end
    endtask: hbus_f

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
        $display("=======================================================================================================================================================================");
        $display("                                                            SCOREBOARD REPORT                                                                                          ");
        $display("=======================================================================================================================================================================");
        `uvm_info(get_type_name(), $sformatf("Total Packets Received\t:   %0d", received), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Packets Matched\t:   %0d", matched), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Packets Mis-Matched\t:   %0d", wrong), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Packets Dropped\t:   %0d", droppped), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Packets Not Dropped\t:   %0d", not_droppped), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("FIFO Yapp\t:   %0d", yapp_fifo.size()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("FIFO Chan 0\t:   %0d", chann0_fifo.size()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("FIFO Chan 1\t:   %0d", chann1_fifo.size()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("FIFO Chan 2\t:   %0d", chann2_fifo.size()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("FIFO HBUS\t:   %0d", hbus_fifo.size()), UVM_LOW)     
        $display("-----------------------------------------------------------------------------------------------------------------------------------------------------------------------");
    endfunction: report_phase

endclass: router_scoreboard_new
