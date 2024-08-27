`ifndef HOG_AXIF_BASE_SEQ_SV
 `define HOG_AXIF_BASE_SEQ_SV

class hog_axif_base_seq extends uvm_sequence#(hog_axif_seq_item);

   `uvm_object_utils(hog_axif_base_seq)
   `uvm_declare_p_sequencer(hog_axif_sequencer)

   function new(string name = "hog_axif_base_seq");
      super.new(name);
   endfunction

   // objections are raised in pre_body
   virtual task pre_body();
      uvm_phase phase = get_starting_phase();
      if (phase != null)
        phase.raise_objection(this, {"Running sequence '", get_full_name(), "'"});
      uvm_test_done.set_drain_time(this, 200ms);      
   endtask : pre_body

   // objections are dropped in post_body
   virtual task post_body();
      uvm_phase phase = get_starting_phase();
      if (phase != null)
        phase.drop_objection(this, {"Completed sequence '", get_full_name(), "'"});
   endtask : post_body

   // task body(); will be implemented in child class.
endclass : hog_axif_base_seq

`endif
