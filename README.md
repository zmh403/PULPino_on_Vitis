# PULPino_on_Vitis
## Target
Use Xilinx RTL Wizard flow to run program on the SoC PULPino through Vitis platform.
## Small Target
1. Pass behavior simulation in Vivado.
	In version2, design can pass the behavior simulation in Vivado 2020.1.
2. Pass Haredware Emulation in Vitis platform.
	Host cann't read the data which transfer from the kernel through the buffer.
3. Use stream interface to recieve the uart signals from the kernel.
4. Replace the RTL Load_File_Controller module and  with C models.


