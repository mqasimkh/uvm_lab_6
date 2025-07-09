# UVM Lab # 6: TLM Connection

In this lab, need to modify `module UVC` created in last lab to use `TLM exports` and then modify `scoreboard` use `TLM analysis FIFO`.

## Table of Contents

## Table of Contents

- [UVM Lab # 6: TLM Connection](#uvm-lab--6-tlm-connection)
  - [Task 1: Using TLM Export Connectors](#task-1-using-tlm-export-connectors)
    - [Changes in `router_module_env` & `router_tb`](#changes-in-router_module_env--router_tb)
    - [Testing the Changes](#testing-the-changes)
  - [Task 2: Using TLM Analysis FIFOs](#task-2-using-tlm-analysis-fifos)
    - [`router_scoreboard_new.sv`](#router_scoreboard_newsv)
    - [Running Test](#running-test)

---

## Task 1: Using TLM Export Connectors

### changes in `router_module_env` & `router_tb`

Created analysis export objects in `router_module_env`.

```systemverilog
    uvm_analysis_export #(yapp_packet) ref_model_yapp;
    uvm_analysis_export #(hbus_transaction) ref_model_hbus;

    uvm_analysis_export #(channel_packet) scr_chan0;
    uvm_analysis_export #(channel_packet) scr_chan1;
    uvm_analysis_export #(channel_packet) scr_chan2;
```

Connected these export objects to the `imp objects` in reference model and scoreboard.

```systemverilog
    ref_model_yapp.connect(reference_model.yapp_in);
    ref_model_hbus.connect(reference_model.hbus_in);

    scr_chan0.connect(scoreboard.chann0_in);
    scr_chan1.connect(scoreboard.chann1_in);
    scr_chan2.connect(scoreboard.chann2_in);
```

No need to create create export object for yapp_valid because it is internal between `reference model` and `scoreboard`.

Modified the `connections` in `router_tb.sv` connect_phase to these newly created `export objects` in module UVC top instead of `imp objects` in `scoreboard` and `reference model`.

Now instead of direct connection between `monitor` component in `interface UVC` and `module UVC scoreboard & reference model`, the conncetion from interface UVC is to the export port in module `UVC top env` and from there transaction passed to respective `imp objects`.

![screenshot-image](/screenshots/image.png)

```systemverilog
    c0.rx_agent.monitor.item_collected_port.connect(router_mod.scr_chan0);
    c1.rx_agent.monitor.item_collected_port.connect(router_mod.scr_chan1);
    c2.rx_agent.monitor.item_collected_port.connect(router_mod.scr_chan2);

    uvc.agent.monitor.yapp_collected_port.connect(router_mod.ref_model_yapp);
    hbu.bus_monitor.item_collected_port.connect(router_mod.ref_model_hbus);
```

### testing the changes

Ran the same test as in `task 3` of last lab with `short packet` and same results.

![screenshot-1](/screenshots/1.png)

## Task 2: Using TLM Analysis FIFOs

Instead of using `reference model`, created a new scoreboard and used `TLM analysis FIFOs` and declared methods to pass check the compare the correct packets only.

### router_scoreboard_new.sv

Created a new scoreboard and created analysis FIFOs to replace `imp objects`

```systemverilog
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
```

Declared 2 global variables `maxpktsize` and `router_en`.

Created `hbus_f` method which asserts `router_en` variable if `hbus packet` addr == 16'h1001 and `maxpktsize` value to `hdata` in hbus as addr == 16'h1000 (same as we did in reference model).

Created a `yapp_pkt_method`, we drop the packet if `router_en` is not high, or `packet length` is greated than `maxpktsize` or `pkt addr` is greater than 2.

Else, passed both input and output packets (input from yapp UVC and output from channel UVC) to `custom_comp` function and if matched, incremented matched counter else not matched (wrong) counter.

In report phase, displayed the status counters.

```systemverilog
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
```


```systemverilog
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
```

### Running test

Ran the test with `yapp_short_packet` and the changes were verified, no packet dropped and all good.

![screenshot-2](/screenshots/2.png)

Ran the test again with `yapp_packet` which now include invalid length, it shows functions working correctly.

***`recieved packets` = `matched` + `not matched` + `dropped`.***

![screenshot-4](/screenshots/4.png)