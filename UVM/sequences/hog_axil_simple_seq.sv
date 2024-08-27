`ifndef HOG_AXIL_SIMPLE_SEQ_SV
 `define HOG_AXIL_SIMPLE_SEQ_SV

class hog_axil_simple_seq extends hog_axil_base_seq;

   `uvm_object_utils (hog_axil_simple_seq)

   function new(string name = "hog_axil_simple_seq");
      super.new(name);
   endfunction

   virtual task body();
      // simple example - just send one item
      hog_axil_seq_item hog_axil_it;
      // prvi korak kreiranje transakcije
      hog_axil_it = hog_seq_item::type_id::create("hog_axil_it");
      // drugi korak − start
      start_item(hog_axil_it);
      // treci korak priprema
      // po potrebi moguce prosiriti sa npr. inline ogranicenjima
      assert (hog_axil_it.randomize() with {hog_axil_it. });
      // cetvrti korak − finish
      finish_item(hog_axil_it);
      
   endtask : body

endclass : hog_axil_simple_seq

`endif
