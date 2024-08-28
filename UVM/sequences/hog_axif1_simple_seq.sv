`ifndef HOG_AXIF1_SIMPLE_SEQ_SV
 `define HOG_AXIF1_SIMPLE_SEQ_SV

class hog_axif1_simple_seq extends hog_axif_base_seq;

   `uvm_object_utils (hog_axif1_simple_seq)

   function new(string name = "hog_axif1_simple_seq");
		super.new(name);
   endfunction

   virtual task body();
		// simple example - just send one item
		hog_axif_seq_item hog_axif1_it;
		// prvi korak kreiranje transakcije
		hog_axif1_it = hog_axif_seq_item::type_id::create("hog_axif1_it");
		// drugi korak − start
		start_item(hog_axif1_it);
		// treci korak priprema
		// po potrebi moguce prosiriti sa npr. inline ogranicenjima
		//assert (hog_axif1_it.randomize() with {hog_axif1_it. });
		// cetvrti korak − finish
	  	finish_item(hog_axif1_it);
	  
   endtask : body

endclass : hog_axif1_simple_seq

`endif