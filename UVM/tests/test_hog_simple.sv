`ifndef TEST_HOG_SIMPLE_SV
    `define TEST_HOG_SIMPLE_SV

class test_hog_simple extends test_hog_base; 

    `uvm_component_utils(test_hog_simple)

    hog_axil_simple_seq axil_simple_seq;
    hog_axis_hp0_simple_seq axis_hp0_simple;
    hog_axis_hp1_simple_seq axis_hp1_simple;

    function new(string name = "test_hog_simple",uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase); 
        `uvm_info(get_type_name(),"Starting build phase...",UVM_LOW)
        axil_simple_seq = hog_axil_simple_seq::type_id::create("axil_simple_seq");    
        axis_hp0_simple = hog_axis_hp0_simple_seq::type_id::create("axis_hp0_simple");    
        axis_hp1_simple = hog_axis_hp1_simple_seq::type_id::create("axis_hp1_simple");    
    endfunction : build_phase

    task main_phase(uvm_phase phase);
        phase.raise_objection(this);
        fork
            // Thread 1: axil NOTE: maybe we dont need this one, axis's could wait anyways...
            axil_simple_seq.start(env.axil_gp_agent.axil_seqr); // TODO: possible error here...
            // Thread 2: axis hp0
            axis_hp0_simple.start(env.axis_hp0_agent.axis_hp0_seqr); // TODO: possible error here...
            // Thread 3: axis hp1
            axis_hp1_simple.start(env.axis_hp1_agent.axis_hp1_seqr); // TODO: possible error here...
            #5us;
        join
        phase.drop_objection(this);    
    endtask
   
endclass : test_hog_simple

`endif