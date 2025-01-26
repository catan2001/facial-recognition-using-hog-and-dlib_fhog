# ESL - Electronic System Level (Histogram of Oriented Graphs)

This **README** provides a straightforward explanation of the purpose of ESL and its application in the HOG project. For a more in-depth understanding, please refer to the link in the [References](#references) section.

## Introduction

The **Electronic System Level** (ESL) design methodology is a crucial foundation for any project. It acts as a guideline for subsequent sections and involves creating an abstract model of the hardware structure and its communication with the rest of the system.

**NOTE:** A thorough understanding of the core components of the hardware system you're working with is essential for effectively integrating all parts of your virtual platform. Specifically, for [Zynq-7000](#other) architecture, it is highly recommended to familiarize yourself with its main components and interconnects to avoid getting overwhelmed by unnecessary details.

### List of Sections

- [1. Time Analysis](#time-analysis)
- [2. Fixed-Point Analysis](#fixed-point-analysis)
- [3. Virtual Platform](#virtual-platform)
- [4. References](#references)

## Time Analysis

The first step in the ESL design process is understanding how your programs functions work and identifying which parts of the program are the slowest. This can be achieved by using **profiling tools**, which analyze the performance of each function in your program. The function with the highest execution time is typically the best candidate for hardware integration to achieve faster performance.

**NOTE:** When using profiling tools, it’s ideal to work with a program that minimizes branching. Ideally, you want a single function to dominate execution time (e.g., taking up 90% of CPU processing time) to simplify hardware translation and optimization.

### Tools Used:
- [Callgrind](https://valgrind.org/docs/manual/cl-manual.html)
- [KCachegrind](https://kcachegrind.sourceforge.net/html/Home.html)

--- 
Before using these profiling tools, it’s highly recommended to rewrite your program in C or C++ if it’s not already implemented in a low-level programming language. This can save significant time and effort later in the process.

**Advice:** If you lack experience with programming, try to avoid large, complex libraries that are difficult to understand. Such libraries can make it challenging to isolate and analyze the specific function that needs to be translated into hardware.

To install and run these tools, please follow the provided [tutorial](https://baptiste-wicht.com/posts/2011/09/profile-c-application-with-callgrind-kcachegrind.html). After installation, compile your program and run the tools. You should obtain results similar to what we achieved in our project.


![alt text](/ESL/misc/Profiled%20Program.png)

The same is shown in the table below:

|  #  |  Function  |  Time Spent (%)   |  
| :-: | :-------: | :-------: | 
|  1  |   face_recogntion_range   |   96,21   | 
|  2  |   face_recognition   |   96,21   | 
|  3  |   extract_hog   |   96,21   | 
|  4  |   filter_image   |   51,55   | 
|  5  |   get_gradient   |   26,57   | 
|  5  |   build_histogram   |   6,24   | 


The profiling results we obtained revealed that the percentages were not ideal for hardware acceleration. While the function **filter_image** was identified as a primary candidate for optimization, even if it were translated into hardware, the overall acceleration would not be as impactful as expected.

This insight underscores a critical takeaway: your main focus should always be on optimizing the function that consumes the majority of the execution time. Prioritizing the wrong function may result in negligible performance gains, even with hardware acceleration.

Since this project is for students, we used **filter_image** function for acceleration.

### Broader Insights and Considerations:

1. **Selecting the Right Function**  
   Profiling tools give you valuable data about the execution time of each function in your program. While functions with high execution times are candidates for hardware acceleration, always assess the potential impact on overall system performance. Focus on the function that truly dominates the program’s runtime. If your chosen function does not significantly impact the total execution time, the acceleration may not yield noticeable improvements.

2. **Amdahl's Law**  
   To better evaluate the potential benefits of hardware acceleration, consider applying [Amdahl’s Law](https://en.wikipedia.org/wiki/Amdahl%27s_law). This principle provides a theoretical framework to estimate how much faster a task or system can perform when specific components are optimized or additional resources are added. By analyzing the law’s implications, you can determine whether the effort of accelerating a particular function is worth the expected performance gain.

   Amdahl’s Law formula:  
    ```math
    Speedup = 1/((1-P)+P/S)
    ```

   - \( P \) is the proportion of execution time affected by the optimization.
   - \( S \) is the speedup of the optimized portion.

    **NOTE:** We did not use this in our project but it is advised to try it.

### Advice for Future Optimization:  

- **Reassess Profiling Results:** Re-run your profiling tools after making changes to your program or hardware. This ensures your focus remains on the most resource-intensive areas.  
- **Iterative Design:** Optimization is rarely a one-shot process. Apply profiling, optimize a function, re-profile, and refine your approach.  
- **Understand System Bottlenecks:** Beyond individual functions, examine broader system bottlenecks like memory access, I/O operations, and communication delays between hardware and software components.  
- **Experiment with Small Changes:** Even minor adjustments to algorithms or hardware designs can yield significant improvements.  

After you do profiling we can continue to [Bitwise Analysis](#fixed-point-analysis)

## Fixed-Point Analysis
After conducting time analysis, the next critical step in the ESL design process is defining the data types the system will use. Bit-width analysis plays a significant role in optimizing performance and resource usage while maintaining precision. The larger data you use in your project the more resources you will spend. 

This step decides how large the data used is. In other terms it describes how big data bus has to be to translate a single data and how much single data takes bytes to store in memory. 

Since you will probably use floating point values in your program, you have to convert them into fixed point values. This process includes a percentage of error that affects how accurately the floating point data is represented in fixed point. To understand this better please read this [article](https://en.wikipedia.org/wiki/Fixed-point_arithmetic). Also, in the first excercise of ESL you can find code example how it should be done.

---
Bit-width analysis was performed using C++ and **SystemC libraries**. This iterative process started with a 64-bit data width and gradually reduced it to find the optimal configuration. The objective was to balance precision and hardware resource efficiency.

Rule of thumb is to use multiples of 8 (eg. 8-bits, 16-bits, 24-bits and more).

Your code to calcualte fixed-point representation should follow similar algorithm to this:

- 1. Take maximum possible fixed-point representation for a given value(eg. 64bits).
- 2. Calculate the result of the function
- 3. Calculate the difference between the result of the function and the expected values - Error.
- 4. Using previous Error decide to continue further or exit the program
- 5. If the Error is still very low, lower the number of bits for fixed-point representation by 1 and repeat step 2.

You can use **do-while loop** for this.

Using this algorithm we concluded that the best represenation for data is:

- For the input, a 16-bit fixed-point representation was chosen:

    - 1 bit for the non-negative integer part
    - 15 bits for the fractional part

This means that input values into hardware are in range [0, 1].

- For the output, another 16-bit fixed-point format was selected:

    - 4 bits for the integer part
    - 12 bits for the fractional part

This means that output values from hardware are in range [-4, 4] .

**NOTE:** Please take in consideration that representing negative values also affects the number of bits.

After calculating the number of bits needed to represent input and output data we can continue to the last section of modeling [Virtual Platform](#virtual-platform)

## Virtual Platform

The final and most critical step in the ESL design process is developing a Virtual Platform. This platform abstracts unnecessary low-level implementation details, allowing engineers to focus on the high-level architecture and how different parts of the system interact. A Virtual Platform enables rapid prototyping, early validation, and fast iterations by simulating the system's behavior in software before committing to hardware.

By eliminating hardware-specific details, the Virtual Platform allows engineers to concentrate on the functionality and communication between components. This helps in identifying and addressing architectural issues early. The Virtual Platform serves as a simulation environment where you can test how the system works as a whole. It enables rapid modifications and fine-tuning of the design without the overhead of re-synthesizing or re-implementing in hardware.

Before creating the Virtual Platform, it is crucial to thoroughly understand the FPGA board and its available resources. Familiarize yourself with:

- The processing elements (e.g., ARM cores on Zynq devices).
- Available memory types and sizes (e.g., DDR, block RAM).
- I/O peripherals and communication interfaces (e.g., AXI Lite, AXI Full).    This knowledge ensures your Virtual Platform accurately reflects the target hardware and system constraints.

The communication between components in the Virtual Platform is implemented using the Transaction-Level Modeling (TLM) 2.0 standard.

- TLM 2.0 defines how components communicate at a transactional level, abstracting away timing and signal-level details.
- It simplifies system design by focusing on data transactions (e.g., read/write operations) rather than signal-level interactions.

This abstraction allows engineers to prioritize system functionality and architecture before diving into detailed hardware modeling, such as clock cycles or signal paths.

---

A visualization of the virtual platform design, showing the interconnection between memory and computation units, is shown below.

![alt text](/ESL/misc/VP.png)

The system utilizes 16 Block RAM (BRAM) blocks for storing input data, as well as 16 BRAM blocks for each of the dx and dy outputs of the Sobel operator. To accelerate processing, a loop unrolling technique with a factor of 16 is applied, allowing the system to compute eight dx values and eight dy values in a single iteration. This approach significantly reduces the computation time per iteration and enhances the throughput of the system.

During the partitioning process, configuration registers were defined to manage the system's operation. To optimize the use of these registers, Software Accessible Hardware Elements (SAHE) were incorporated. SAHE allows more efficient utilization of hardware resources by enabling multiple data values to be stored in a single register. Instead of dedicating one register for each individual data element, multiple values can be packed into a single SAHE register, reducing the overall number of registers needed. This not only conserves hardware resources but also improves spatial efficiency, which is particularly beneficial in resource-limited systems.

With fewer registers in use, more resources can be allocated to other critical components of the design. Detailed overview of SAHE can be found in the picture below:

![alt text](/ESL/misc/SAHE.png)


## References
#### SystemC
- [SystemC - Official Site](https://systemc.org/)
- [SystemC - Language Reference Manual](http://homes.di.unimi.it/pedersini/AD/SystemC_v201_LRM.pdf)
- [Accellera - Official GitHub](https://github.com/accellera-official/systemc)
- [UC Irvine - Presentation](https://newport.eecs.uci.edu/~doemer/f19_ecps203/DAC15_SystemC_Training.pdf)


#### Transaction Level Modeling Standard   
- [LRM - see previous](#systemc)

#### Other
- [Excercises - DEET](https://www.elektronika.ftn.uns.ac.rs/projektovanje-elektronskih-uredjaja-na-sistemskom-nivou/specifikacija/specifikacija-predmeta/)
- [Fixed Point Analysis - Wikipedia](https://en.wikipedia.org/wiki/Fixed-point_arithmetic) 
- [Zynq7000 - CookBook](https://www.zynqbook.com/download-book.php)
- [Zynq7000 - Technical Reference Manual](https://docs.amd.com/r/en-US/ug585-zynq-7000-SoC-TRM)
- **Vuk Vranjković, "Projektovanje elektronskih uređaja na sistemskom nivou - računarske vežbe"** - *Library of the Faculty of Technical Sciences Novi Sad*
