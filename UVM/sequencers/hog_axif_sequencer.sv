`ifndef HOG_AXIF_SEQUENCER_SV
    `define HOG_AXIF_SEQUENCER_SV

    class hog_axif_sequencer extends uvm_sequencer#(hog_axif_seq_item);

        `uvm_component_utils(hog_axif_sequencer)

        function new(string name = "hog_axif_sequencer", uvm_component parent = null);
            super.new(name,parent);
        endfunction

    endclass : hog_axif_sequencer

`endif

//typedef uvm_sequencer#(hog_axif_seq_item) hog_axif_sequencer;