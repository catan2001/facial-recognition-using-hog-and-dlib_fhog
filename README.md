# Face Detection Hardware Accelerator (Histogram Of Oriented Graphs)

This project represents a structured and comprehensive implementation of a hardware accelerator for the Histogram of Oriented Gradients (HOG) algorithm, specifically tailored for face detection. The primary focus of this project was to optimize the HOG algorithm for hardware acceleration, enabling faster and more efficient processing compared to traditional software-based implementations.

---

<p align="center">
  <img src="/misc/Chip.png" />
</p>


## Introduction

The project was developed as part of the coursework during the fourth year of undergraduate studies at the Faculty of Technical Sciences in Novi Sad. It serves both as a demonstration of theoretical knowledge and as practical experience in the design and implementation of hardware accelerators. 

## Stages of Project

The project encompassed several distinct but interconnected stages, each addressing a critical aspect of the hardware accelerator's development. From conceptualizing the design on a virtual platform to integrating it with a Linux operating system, the stages were carefully planned to ensure the successful realization of the accelerator.

### ESL (Electronic System Level)

The first stage of the project involved the development of an abstract model using a virtual platform in SystemC. This stage was crucial for exploring high-level design decisions without delving into hardware implementation details. The ESL model served as a blueprint for the project, helping to validate the overall architecture, functionality, and data flow. 

Using SystemC allowed early detection of potential bottlenecks, enabling iterative refinement before hardware synthesis. The virtual platform also facilitated experimentation with various configurations and provided a software environment to begin developing the firmware and drivers in parallel.
[Read More...](/ESL/README.md)
### Hardware Design

The hardware design was implemented using VHDL, with a focus on the Zynq-7000 SoC. This stage involved translating the high-level design from the ESL model into a detailed register-transfer-level (RTL) description. 

Key considerations during this phase included:
- **Resource Optimization**: Ensuring efficient use of the FPGA fabric to maximize performance while minimizing resource usage.
- **Timing Analysis**: Achieving timing closure to meet the performance requirements of the application.
- **Modular Design**: Structuring the hardware into reusable and maintainable modules.
  
The design leveraged the unique capabilities of the Zynq-7000, particularly its tightly coupled ARM processing system and programmable logic, which allowed for a seamless blend of hardware acceleration and software control.
[Read More...]()
### UVM (Universal Verification Methodology)

Verification played a critical role in ensuring the correctness and reliability of the hardware design. A UVM testbench was developed in parallel with the hardware design to simulate and validate the functionality of the RTL modules. 

The UVM environment included:
- **Sequence Items and Sequences**: To represent and generate various transaction scenarios.
- **Drivers and Monitors**: To drive stimulus and capture responses from the DUT (Device Under Test).
- **Scoreboard**: For result comparison and coverage analysis.
- **Functional Coverage**: To measure the completeness of verification and ensure that all corner cases were tested.

Using UVM allowed for a modular, scalable, and reusable verification environment, which significantly reduced the debugging time and ensured high-quality hardware design.
[Read More...](/UVM/README.md)
### Linux Device Driver

Once the hardware design was verified and implemented on the Zynq-7000 board, the next step was integrating it into a Linux environment. This stage involved the installation of Linux on the Zynq board, followed by the development of a Linux device driver to facilitate communication between the software application and the hardware accelerator.

The device driver included:
- **Initialization**: Setting up the hardware resources, such as memory-mapped registers and interrupts.
- **IOCTL Calls**: Providing user-space applications with an interface to control and monitor the hardware accelerator.
- **Interrupt Handling**: Ensuring efficient handling of hardware events to minimize latency.

This stage bridged the gap between the hardware and software, enabling the integration of the hardware accelerator into real-world applications running on a Linux-based system.
[Read More...]()
## Results

After the system was deployed, testing was conducted to evaluate its functionality. The system was tested for its ability to detect faces in photographs, using the same test samples that were previously utilized during simulations on the virtual platform. The values stored in the DRAM memory matched the expected values, providing additional verification of the system's operation.

Since the filtered pixel values aligned with expectations, additional functions were invoked to compute the coordinates of the detected faces in the images. These functions processed the filtered data to produce precise locations of faces, ensuring the accuracy and reliability of the detection algorithm. This successful outcome confirmed the system's capability to perform face detection as designed, marking a critical milestone in its validation.

The resulting image showcasing the detected faces can be seen below:

<p align="center">
  <img src="/results/arithmetic_face.png" />
</p>

It highlights the successful implementation of the system, where the identified face coordinates are accurately marked on the test images. This visual output serves as a concrete demonstration of the system's ability to process and analyze input data, confirming the correct functioning of the hardware and software components.


## Documentation (Serbian Language)
- [Electronic System Level](/Documentation/Specifikacija_esl.docx)
- [Hardware Design](/Documentation/Dokumentacija_PSDS.docx)
- [Functional Verification](/Documentation/FV_dokumentacija.docx)
- [Linux Device Driver](/Documentation/EOS_doc.docx)

## Software Guides
- [Ubuntu, Vivado Suite, PetaLinux Install Guide](/Ubuntu,%20Vivado%20Suite,%20PetaLinux%20Install%20Guide.md)
- [Git Tutorial](/GIT%20notes.md)
- [SystemC Install Guide](https://gist.github.com/bagheriali2001/0736fabf7da95fb02bbe6777d53fabf7)