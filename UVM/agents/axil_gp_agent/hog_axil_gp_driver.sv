`ifndef HOG_AXIL_GP_DRIVER_SV
    `define HOG_AXIL_GP_DRIVER_SV

    class hog_axil_gp_driver extends uvm_driver#(hog_axil_seq_item);

        `uvm_component_utils(hog_axil_gp_driver)
        virtual interface axil_gp_if vif;
        function new(string name = "hog_axil_gp_driver", uvm_component parent = null);
            super.new(name,parent);
        endfunction // new
        
        function void build_phase(uvm_phase phase);
            if (!uvm_config_db#(virtual axil_gp_if)::get(null, "*", "axil_gp_if", vif))
                `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
        endfunction // build_phase

        task main_phase(uvm_phase phase);
            forever begin
                @(posedge vif.clk);	 
                if (!vif.rst)
                begin
                    seq_item_port.get_next_item(req);

                    `uvm_info(get_type_name(), $sformatf("Driver sending...\n%s", req.sprint()), UVM_HIGH)	      

                    @(posedge vif.clk) begin
						// enter code here...
                    end // @ (posedge vif.s_axi_aclk)                    
                end
                seq_item_port.item_done();
                `uvm_info(get_type_name(), $sformatf("Driver finished sending over AXI LITE GP..."), UVM_HIGH)	      
            end
        endtask : main_phase

    endclass : calc_driver

`endif

