# 4_port_Ethernet_Switch
This project was made by me and my colleague Ilya Chaschin in summer 2019.
This is a working protorype of 4-port Ethernet switch.
Our project uses 8-bit GMII interface and was tested on clock of 125 MHz. So it works without major error on 1Gb/s speed.
FPGA design was tested on MD1-1RU communication system (made by Micran company from Tomsk) which contained Altera Cyclone 5 5CGXBC7C6F23C7 SoC.

Software used in this project:
- Quartus 2 15.0 Web Edition
- ModelSim 10.3 D
- Visual Studio Code

Used languages:
- Verilog/System Verilog

How to use?
1) Open top_level.qpf in Quartus 2 (Open project)
2) Open "Useful Pictures" folder and make sure, that all files included like in "Necessary files.png"
3) Compile
4) Program it into FPGA
5) To experience full capabilities of this project you will need a Printed Circuit Board with at least 4 Ethernet ports, clock generator with minimum frequency of 125 MHz and Cyclone 5 FPGA

"Useful Pictures" folder contains:
- "Useful_Pictures.png" - screenshot from Quartus 2 that show us the amount of FPGA resourses used in this project.
- "Switch clock.png" - all clocks from this project. Both external and PLL-generated.
- "RTL_model.png" - RTL representation of Ethernet switch. This can help you to understand the work that was done.
- "Necessary files.png" - had been described above.
- "Architecure.pdf" - grafical representation of how 4-port Ethernet switch works.

Hope this project will be useful for you!
Have a good day!
