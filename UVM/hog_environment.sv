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
        if (!uvm_config_db#(virtual axil_gp_if)::get(this, "", "axil_gp_if", axil_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".axil_vif"})


        uvm_config_db#(virtual axil_gp_if)::set(this, "axil_gp_agent", "axil_gp_if", axil_vif);

        axil_gp_agent = hog_axil_gp_agent::type_id::create("axil_gp_agent",this);
        //Dodavanje scoreboard-a
    endfunction : build_phase   
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction
    

	endclass : hog_environment

`endif