`ifndef SCOREBOARD_SV
    `define SCOREBOARD_SV
    
    class scoreboard extends uvm_scoreboard;
    
        bit checks_enable = 1;
        bit coverage_enable = 1;
        
        uvm_analysis_imp#(hog_axil_seq_item, scoreboard) item_collected_import;
        
        int num_of_tr;
        
        `uvm_component_utils_begin(scoreboard)
            `uvm_field_int(checks_enable, UVM_DEFAULT)
            `uvm_field_int(coverage_enable, UVM_DEFAULT)
        `uvm_component_utils_end
        
        function new(string name = "scoreboard", uvm_component parent = null);
            super.new(name, parent);
            item_collected_import = new("item_collected_import", this);
        endfunction : new
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
        endfunction : build_phase
        
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
        endfunction : connect_phase
        
        function write(hog_axil_seq_item tr);
            hog_axil_seq_item tr_clone;
            if(checks_enable) begin
                // CODE HERE:
                
            end
        endfunction : write
        
        function void report_phase(uvm_phase phase);
            `uvm_info(get_type_name(), $sformatf("Scoreboard examined: $0d transactions", num_of_tr), UVM_LOW);
        endfunction : report_phase
        
        
    endclass : scoreboard
    
`endif