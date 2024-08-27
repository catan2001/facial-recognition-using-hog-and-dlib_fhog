# Universal Verification Methodology (UVM)

## Verification of HOG

## UVM Guidelines 

### Interfaces 

They are used to connect design and testbench. All signals that connect DUT and testbench should be defined inside of interfaces, this yields code structure clarity.

>       virtual memory_if mem_i;

### Sequences

Sekvence su objekti (ne komponente) koje sadrze logiku generisanja stimulusa. Unutar njih se kreira objekat klase Seqeunce item koji se preko sekvencera prosledjuje drajveru

Sve sekvence u okruºenju treba da, direktno ili indirektno, nasleuju uvm_sequence klasu. Tri najcesce koriscene metode su pre_body(), body() i post_body(). Glavna logika treba da se nalazi u body() tasku. Pre_body() i post_body() su taskovi koji se pozivaju pre, odnosno posle body() taska

>        class calc_seq extends uvm_sequence#(calc_seq_item); // parameter calc_seq_item
>            `uvm_object_utils(calc_seq) // factory registration
>            `uvm_declare_p_sequencer(calc_sequencer) // sequencer that is being used

>            function new(string name = "calc_seq"); // constructor
>                super.new(name);
>            endfunction

>            virtual task pre_body(); // can be used for raising objections
>                // ...
>            endtask : pre_body

>            // transaction generating logic in body
>            virtual task body();
>                // calls to uvm_do or uvm_do with macro
>                // or start / nish item
>                // ...
>            endtask : body

>            virtual task post_body(); // can be used for raising objections
>                // ...
>            endtask : post_body
>        endclass : calc_seq

#### **Generisanje stimulusa**

Za generisanje transakcije potrebno ispratiti nekoliko koraka:

- Kreiranje - veoma je bitno kreirati paket koristeci factory kako bi se olaksala ponovna upotreba
odnosno kako bi se dozvolio override metod ukoliko je to potrebno
- start_item() - blokirajuci poziv koji ceka da se uspostavi veza sa drajverom. Sekvenceru salje
pokazivaz na sledeci objekat
- Randomizacija paketa (polja unutar sequence item-a) ukoliko je to potrebno
-  finish_item() - blokirajuci poziv koji ceka da drajver zavrsi sa paketom (napomena: start_item()
i finish_item() cekaju na drajver kako bi se osigurao korektan transfer paketa, ali oni ne trose
simulaciono vreme)
- get_response() - opcioni poziv ako je potrebno da drajver posalje odgovor sekvenceru.


>        virtual task body();
>            calc_seq_item calc_it;
            
>            // prvi korak kreiranje transakcije
>            calc_it = calc_seq_item::type_id::create("calc_it");
            
>            // drugi korak − start
>            start_item(calc_it);
            
>            // treci korak priprema
>            // po potrebi moguce prosiriti sa npr. inline ogranicenjima
>            assert (calc_it.randomize());
            
>            // cetvrti korak − finish
>            finish_item(calc_it);
>        endtask: body

#### `uvm_do

>        virtual task body();
>            `uvm_do(req)
>        endtask : body


#### `uvm_do_with

>        virtual task body();
>            `uvm_do_with(req, { req.>data==16'h5A5A })
>        endtask : body

U ovom primeru se salje jedna transakcija pri cemu je vrednost data polja ograni£ena na 16'h5A5A.


### Coverage

To know when is verification done, you have to answer two main questions:
- Did I cover every s
- Is there a part of design code that was never used in verification? 

There are two main coverage metrics:
- Structural coverage - *implicite*
- Functional coverage [**prefered one**] - *explicite*

#### **Functional Coverage**.

In SystemVerilog there are two main types of construction for such metric:
- Cover groups
- Cover properties

