# GMII_Ethernet_receiver
This code was written by me in summer 2019 as an internship task for Micran Company. 
It's a 8-bit GMII interface and was tested on clock of 125 MHz. So it works on 1Gb/s speed.
FPGA design was tested on MD1-1RU communication system (made by Micran company from Tomsk) which contained Altera Cyclone 5 5CGXBC7C6F23C7 SoC. These code snippets were used later in 4-port 1Gbit/s Ethernet switch project.

## Software used in this project:
- Quartus 2 15.0 Web Edition
- ModelSim 10.3 D
- Visual Studio Code

 ## "Hardware Info" folder contains:
- "Useful_Pictures.png" - screenshot from Quartus 2 that show us the amount of FPGA resourses used in this project.
- "Switch clock.png" - all clocks from this project. Both external and PLL-generated.
- "RTL_model.png" - RTL representation of Ethernet switch. This can help you to understand the work that was done.
- "Necessary files.png" - had been described above.
- "Architecure.pdf" - grafical representation of how 4-port Ethernet switch works.

Unfortunately, the majority of the comments in the code are in Russian. I will translate them into English later

Hope this project will be useful for you!
Have a good day!
