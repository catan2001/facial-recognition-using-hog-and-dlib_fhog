# Verification Progress

## AXI GP LITE
- [x] Writes into all registers
- [x] Reads from all registers
- [x] Reset check
- [x] Convert to complete UVM
---
- [x] Monitor
- [x] Scoreboard
- [x] Checker
- [x] Coverage

## AXIS HP0
- [x] Monitor
- [x] Scoreboard
- [x] Checker
- [x] Coverage

## AXIS HP1
- [x] Monitor
- [x] Scoreboard
- [x] Checker
- [x] Coverage

## Golden Vectors

|  #  |  Picture  |  Padded   |  Verified  |    Date    |
| :-: | :-------: | :-------: | :--------: |:---------: |
|  1  |   42_42   |   44_44   |  Success   | 22.09.2024 |
|  2  |   54_54   |   56_56   |  Success   | 22.09.2024 |
|  3  |   66_66   |   68_68   |  Success   | 22.09.2024 |
|  4  |   78_78   |   80_80   |  Success   | 22.09.2024 |
|  4  |   90_90   |   92_92   |  Success   | 22.09.2024 |
|  4  |  102_102  |  106_106  |  Success   | 22.09.2024 |
|  1  |  114_114  |  118_118  |  Success   | 22.09.2024 |
|  2  |  126_126  |  128_128  |  Success   | 22.09.2024 |
|  3  |  138_138  |  140_140  |  Success   | 22.09.2024 |
|  4  |  150_150  |  152_152  |  Success   | 22.09.2024 |
|  5  |  246_300  |  248_302  |  Success   | 22.09.2024 |
|  6  |  250_186  |  252_188  |  Success   | 22.09.2024 |


## Found Bugs
|  #  |   Bug Source  |   Status  |                   Description                  |    Date    |
| :-: |   :-------:   | :-------: | :--------------------------------------------: |:---------: |
|  1  |      UVM      |   Fixed   | Driver was not able to read and write properly | 17.09.2024 |
|  2  | Control Logic |   Fixed   | Wrong R/W for i=12, j=0. Signal w_out was 0xf000, should be 0x0000 | 17.09.2024 |
|  3  | Control Logic |   Fixed   | Signal valid_out did not go to '0' when calculating next row | 18.09.2024 |
|  4  | Control Logic |   Fixed   | Signal w_out was set wrong just before BR2DR state. Overwrites bram blocks 4,5,6 and 7 , should be 0x0000 | 22.09.2024 |