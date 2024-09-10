`ifndef HOG_ENVIRONMENT_SV
	`define HOG_ENVIRONMENT_SV

	class hog_environment extends uvm_env;

        hog_axil_gp_agent axil_gp_agent;
        hog_axis_hp0_agent axis_hp0_agent;
        hog_axis_hp1_agent axis_hp1_agent;

        virtual interface axil_gp_if axil_vif;
        virtual interface axis_hp0_if axis_hp0_vif;
        virtual interface axis_hp1_if axis_hp1_vif;

        `uvm_component_utils(hog_environment);

        function new(string name = "hog_environment" , uvm_component parent = null);  
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            // Getting interfaces from configuration base //
            if (!uvm_config_db#(virtual axil_gp_if)::get(this, "", "axil_gp_if", axil_vif))
                `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".axil_vif"})

            if (!uvm_config_db#(virtual axis_hp0_if)::get(this, "", "axis_hp0_if", axis_hp0_vif))
                `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".axis_hp0_vif"})

            if (!uvm_config_db#(virtual axis_hp1_if)::get(this, "", "axis_hp1_if", axis_hp1_vif))
                `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".axis_hp1_vif"})

            uvm_config_db#(virtual axil_gp_if)::set(this, "axil_gp_agent", "axil_gp_if", axil_vif);
            uvm_config_db#(virtual axis_hp0_if)::set(this, "axis_hp0_agent", "axis_hp0_if", axis_hp0_vif);
            uvm_config_db#(virtual axis_hp1_if)::set(this, "axis_hp1_agent", "axis_hp1_if", axis_hp1_vif);

            axil_gp_agent = hog_axil_gp_agent::type_id::create("axil_gp_agent",this);
            axis_hp0_agent = hog_axis_hp0_agent::type_id::create("axis_hp0_agent",this);
            axis_hp1_agent = hog_axis_hp1_agent::type_id::create("axis_hp1_agent",this);
            
            //Dodavanje scoreboard-a
        endfunction : build_phase   
        
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
        endfunction

	endclass : hog_environment

`endif