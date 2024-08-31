`ifndef HOG_ENVIRONMENT_SV
	`define HOG_ENVIRONMENT_SV

	class hog_environment extends uvm_env;

	hog_axil_gp_agent axil_gp_agent;

	virtual interface axil_gp_if axil_vif;

	`uvm_component_utils(hog_environment);

	function new(string name = "hog_environment" , uvm_component parent = null);  
    	super.new(name,parent);
    endfunction

	 function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Getting interfaces from configuration base //
        if (!uvm_config_db#(virtual hough_interface)::get(this, "", "hog_interface", axil_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".axil_vif"})

        //if (!uvm_config_db#(hog_config)::get(this, "", "hog_config", cfg))
        //    `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".cfg"})

        // Setting to configurartion base //
        //uvm_config_db#(hough_config)::set(this, "agent", "hough_config", cfg);
        //uvm_config_db#(hough_config)::set(this, "h_scbd","hough_config", cfg);
        //uvm_config_db#(virtual hough_interface)::set(this, "agent", "hough_interface", h_vif);
        //uvm_config_db#(virtual hough_interface)::set(this, "axi_agent", "hough_interface", h_vif);

        axil_gp_agent = hog_axil_gp_agent::type_id::create("axil_gp_agent",this);
        //Dodavanje scoreboard-a
        //h_scbd = hough_scoreboard::type_id::create("h_scbd",this);
    endfunction : build_phase   
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //agent.mon.item_collected_port.connect(h_scbd.item_collected_import);
    endfunction
    

	endclass : hog_environment

`endif