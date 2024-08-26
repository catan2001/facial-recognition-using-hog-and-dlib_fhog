# Universal Verification Methodology (UVM)

## Verification of HOG

### UVM Guidelines

#### Interfaces 

They are used to connect design and testbench. All signals that connect DUT and testbench should be defined inside of interfaces, this yields code structure clarity.

>       virtual memory_if mem_i;