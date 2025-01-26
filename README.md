# Face Detection Hardware Accelerator (Histogram Of Oriented Graphs)

This project represents a structured and comprehensive implementation of a hardware accelerator for the Histogram of Oriented Gradients (HOG) algorithm, specifically tailored for face detection. The primary focus of this project was to optimize the HOG algorithm for hardware acceleration, enabling faster and more efficient processing compared to traditional software-based implementations.

---


<div style="text-align:center;"> <svg xmlns="http://www.w3.org/2000/svg" width="125" height="125" viewBox="0 0 16 16">
  <defs>
    <linearGradient id="fadeColor" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#90D5FF">
        <animate attributeName="stop-color" values="#90D5FF;#90D5FF;#696969;#90D5FF" dur="5s" repeatCount="indefinite" />
      </stop>
      <stop offset="100%" stop-color="#90D5FF">
        <animate attributeName="stop-color" values="#90D5FF;#90D5FF;#696969;#90D5FF" dur="5s" repeatCount="indefinite" />
      </stop>
    </linearGradient> 
  </defs>
  <path d="M5 0a.5.5 0 0 1 .5.5V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 1 0V2A2.5 2.5 0 0 1 14 4.5h1.5a.5.5 0 0 1 0 1H14v1h1.5a.5.5 0 0 1 0 1H14v1h1.5a.5.5 0 0 1 0 1H14v1h1.5a.5.5 0 0 1 0 1H14a2.5 3.5 0 0 1-2.5 2.5v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-1 0V14A2.5 2.5 0 0 1 2 11.5H.5a.5.5 0 0 1 0-1H2v-1H.5a.5.5 0 0 1 0-1H2v-1H.5a.5.5 0 0 1 0-1H2v-1H.5a.5.5 0 0 1 0-1H2A2.5 2.5 0 0 1 4.5 2V.5A.5.5 0 0 1 5 0m-.5 3A1.5 1.5 0 0 0 3 4.5v7A1.5 1.5 0 0 0 4.5 13h7a1.5 1.5 0 0 0 1.5-1.5v-7A1.5 1.5 0 0 0 11.5 3zM5 6.5A1.5 1.5 0 0 1 6.5 5h3A1.5 1.5 0 0 1 11 6.5v3A1.5 1.5 0 0 1 9.5 11h-3A1.5 1.5 0 0 1 5 9.5zM6.5 6a.5.5 0 0 0-.5.5v3a.5.5 0 0 0 .5.5h3a.5.5 0 0 0 .5-.5v-3a.5.5 0 0 0-.5-.5z" fill="url(#fadeColor)" />
</svg></div>

## Introduction

The project was developed as part of the coursework during the fourth year of undergraduate studies at the Faculty of Technical Sciences in Novi Sad. It serves both as a demonstration of theoretical knowledge and as practical experience in the design and implementation of hardware accelerators. 

## Stages of Project

The project encompassed several distinct but interconnected stages, each addressing a critical aspect of the hardware accelerator's development. From conceptualizing the design on a virtual platform to integrating it with a Linux operating system, the stages were carefully planned to ensure the successful realization of the accelerator.

### ESL (Electronic System Level)

The first stage of the project involved the development of an abstract model using a virtual platform in SystemC. This stage was crucial for exploring high-level design decisions without delving into hardware implementation details. The ESL model served as a blueprint for the project, helping to validate the overall architecture, functionality, and data flow. 

Using SystemC allowed early detection of potential bottlenecks, enabling iterative refinement before hardware synthesis. The virtual platform also facilitated experimentation with various configurations and provided a software environment to begin developing the firmware and drivers in parallel.

### Hardware Design

The hardware design was implemented using VHDL, with a focus on the Zynq-7000 SoC. This stage involved translating the high-level design from the ESL model into a detailed register-transfer-level (RTL) description. 

Key considerations during this phase included:
- **Resource Optimization**: Ensuring efficient use of the FPGA fabric to maximize performance while minimizing resource usage.
- **Timing Analysis**: Achieving timing closure to meet the performance requirements of the application.
- **Modular Design**: Structuring the hardware into reusable and maintainable modules.
  
The design leveraged the unique capabilities of the Zynq-7000, particularly its tightly coupled ARM processing system and programmable logic, which allowed for a seamless blend of hardware acceleration and software control.

### UVM (Universal Verification Methodology)

Verification played a critical role in ensuring the correctness and reliability of the hardware design. A UVM testbench was developed in parallel with the hardware design to simulate and validate the functionality of the RTL modules. 

The UVM environment included:
- **Sequence Items and Sequences**: To represent and generate various transaction scenarios.
- **Drivers and Monitors**: To drive stimulus and capture responses from the DUT (Device Under Test).
- **Scoreboard**: For result comparison and coverage analysis.
- **Functional Coverage**: To measure the completeness of verification and ensure that all corner cases were tested.

Using UVM allowed for a modular, scalable, and reusable verification environment, which significantly reduced the debugging time and ensured high-quality hardware design.

### Linux Device Driver

Once the hardware design was verified and implemented on the Zynq-7000 board, the next step was integrating it into a Linux environment. This stage involved the installation of Linux on the Zynq board, followed by the development of a Linux device driver to facilitate communication between the software application and the hardware accelerator.

The device driver included:
- **Initialization**: Setting up the hardware resources, such as memory-mapped registers and interrupts.
- **IOCTL Calls**: Providing user-space applications with an interface to control and monitor the hardware accelerator.
- **Interrupt Handling**: Ensuring efficient handling of hardware events to minimize latency.

This stage bridged the gap between the hardware and software, enabling the integration of the hardware accelerator into real-world applications running on a Linux-based system.


