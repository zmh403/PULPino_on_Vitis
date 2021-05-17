// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
Vendor: Xilinx
Associated Filename: main.c
#Purpose: This example shows a basic vector add +1 (constant) by manipulating
#         memory inplace.
*******************************************************************************/

#include <fcntl.h>
#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <CL/opencl.h>
#include <CL/cl_ext.h>
#include "xclhal2.h"
#include <fstream>

////////////////////////////////////////////////////////////////////////////////

#define NUM_WORKGROUPS (1)
#define WORKGROUP_SIZE (256)
#define MAX_LENGTH 8192
#define MEM_ALIGNMENT 4096
#if defined(VITIS_PLATFORM) && !defined(TARGET_DEVICE)
#define STR_VALUE(arg)      #arg
#define GET_STRING(name) STR_VALUE(name)
#define TARGET_DEVICE GET_STRING(VITIS_PLATFORM)
#endif

using namespace std;
////////////////////////////////////////////////////////////////////////////////
// SPI Load file
////////////////////////////////////////////////////////////////////////////////
// Convert_32-bit_Hex_char to int
cl_uint Sum_of_hex(char* buffer){
	cl_uint sum = 0;
	for (int i=0;i<8;i++){
		switch (buffer[i]){
			case '0':sum += 0; break;
			case '1':sum += pow(16,(7-i)); break;
			case '2':sum += pow(16,(7-i))*2; break;
			case '3':sum += pow(16,(7-i))*3; break;
			case '4':sum += pow(16,(7-i))*4; break;
			case '5':sum += pow(16,(7-i))*5; break;
			case '6':sum += pow(16,(7-i))*6; break;
			case '7':sum += pow(16,(7-i))*7; break;
			case '8':sum += pow(16,(7-i))*8; break;
			case '9':sum += pow(16,(7-i))*9; break;
			case 'A':sum += pow(16,(7-i))*10; break;
			case 'B':sum += pow(16,(7-i))*11; break;
			case 'C':sum += pow(16,(7-i))*12; break;
			case 'D':sum += pow(16,(7-i))*13; break;
			case 'E':sum += pow(16,(7-i))*14; break;
			case 'F':sum += pow(16,(7-i))*15; break;
			default:cout<<"Failed, SUM: "<<sum<<endl; break;
		}
	}
	return sum;
}

cl_uint Load_file(cl_uint* spi_data, cl_uint* instr_num){
	char addr_buffer[10000][10];
	char data_buffer[10000][10];
	cl_uint spi_addr[10000];
	cl_uint temp_line = 0;
	cl_uint addr_cmd_num = 0;
	// Read the file
	ifstream ifs;
	char buffer[20];

	ifs.open("../../spi_stim.txt");
	if(!ifs.is_open()) {
		cout<<"Failed to open file.\n";
		return -1;
	}else{
		while (!ifs.eof()) {
			ifs.getline(buffer,sizeof(buffer));
			for(int i=0;i<8;i++){
				addr_buffer[temp_line][i] = buffer[i];
				data_buffer[temp_line][i] = buffer[i+9];
			}
			temp_line++;
		}
		ifs.close();
		//file_line:1000 ---> temp_line:1001 not 1000
		//temp_line--;
		// Convert the bits of data from hex to decimal in interger type.
		//printf("temp_line: %d\n",temp_line);
		for(cl_uint i=0;i<temp_line-1;i++){
			spi_addr[i] = Sum_of_hex(addr_buffer[i]);
			spi_data[i] = Sum_of_hex(data_buffer[i]);
			//printf("spi_data: %x\n",spi_data[i]);
			if(spi_addr[i]==1048576){
				addr_cmd_num = i;
				cout<<"ADDR number: "<<addr_cmd_num<<endl;
			}
		}
	}
	//temp_line = instruction number + 1
	*instr_num = temp_line;
	return addr_cmd_num;
}

////////////////////////////////////////////////////////////////////////////////

cl_uint load_file_to_memory(const char *filename, char **result)
{
    cl_uint size = 0;
    FILE *f = fopen(filename, "rb");
    if (f == NULL) {
        *result = NULL;
        return -1; // -1 means file opening fail
    }
    fseek(f, 0, SEEK_END);
    size = ftell(f);
    fseek(f, 0, SEEK_SET);
    *result = (char *)malloc(size+1);
    if (size != fread(*result, sizeof(char), size, f)) {
        free(*result);
        return -2; // -2 means file reading fail
    }
    fclose(f);
    (*result)[size] = 0;
    return size;
}

int main(int argc, char** argv)
{

    cl_int err;                            // error code returned from api calls
    cl_uint check_status = 0;
    const cl_uint number_of_words = 4096; // 16KB of data


    cl_platform_id platform_id;         // platform id
    cl_device_id device_id;             // compute device id
    cl_context context;                 // compute context
    cl_command_queue commands;          // compute command queue
    cl_program program;                 // compute programs
    cl_kernel kernel;                   // compute kernel

    cl_uint addr_cmd_num;
    cl_uint instr_num;
   	cl_uint spi_data[10000];
    cl_uint* h_data;                                // host memory for input vector
    char cl_platform_vendor[1001];
    char target_device_name[1001] = TARGET_DEVICE;

    cl_uint* h_spi_data_output = (cl_uint*)aligned_alloc(MEM_ALIGNMENT,MAX_LENGTH * sizeof(cl_uint*)); // host memory for output vector
    cl_mem d_spi_data;                         // device memory used for a vector

    if (argc != 2) {
        printf("Usage: %s xclbin\n", argv[0]);
        return EXIT_FAILURE;
    }

    // Fill our data sets with pattern
    h_data = (cl_uint*)aligned_alloc(MEM_ALIGNMENT,MAX_LENGTH * sizeof(cl_uint*));
    addr_cmd_num = Load_file(spi_data, &instr_num);
    printf("instr_num = %d\n", instr_num);
    for(cl_uint i = 0; i < instr_num-1; i++) {
        h_data[i]  = spi_data[i];
        h_spi_data_output[i] = 0;
        //printf("h_data[%d] = %08x \n", i, h_data[i]);
    }

    // Get all platforms and then select Xilinx platform
    cl_platform_id platforms[16];       // platform id
    cl_uint platform_count;
    cl_uint platform_found = 0;
    err = clGetPlatformIDs(16, platforms, &platform_count);
    if (err != CL_SUCCESS) {
        printf("ERROR: Failed to find an OpenCL platform!\n");
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }
    printf("INFO: Found %d platforms\n", platform_count);

    // Find Xilinx Plaftorm
    for (cl_uint iplat=0; iplat<platform_count; iplat++) {
        err = clGetPlatformInfo(platforms[iplat], CL_PLATFORM_VENDOR, 1000, (void *)cl_platform_vendor,NULL);
        if (err != CL_SUCCESS) {
            printf("ERROR: clGetPlatformInfo(CL_PLATFORM_VENDOR) failed!\n");
            printf("ERROR: Test failed\n");
            return EXIT_FAILURE;
        }
        if (strcmp(cl_platform_vendor, "Xilinx") == 0) {
            printf("INFO: Selected platform %d from %s\n", iplat, cl_platform_vendor);
            platform_id = platforms[iplat];
            platform_found = 1;
        }
    }
    if (!platform_found) {
        printf("ERROR: Platform Xilinx not found. Exit.\n");
        return EXIT_FAILURE;
    }

    // Get Accelerator compute device
    cl_uint num_devices;
    cl_uint device_found = 0;
    cl_device_id devices[16];  // compute device id
    char cl_device_name[1001];
    err = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_ACCELERATOR, 16, devices, &num_devices);
    printf("INFO: Found %d devices\n", num_devices);
    if (err != CL_SUCCESS) {
        printf("ERROR: Failed to create a device group!\n");
        printf("ERROR: Test failed\n");
        return -1;
    }

    //iterate all devices to select the target device.
    for (cl_uint i=0; i<num_devices; i++) {
        err = clGetDeviceInfo(devices[i], CL_DEVICE_NAME, 1024, cl_device_name, 0);
        if (err != CL_SUCCESS) {
            printf("ERROR: Failed to get device name for device %d!\n", i);
            printf("ERROR: Test failed\n");
            return EXIT_FAILURE;
        }
        printf("CL_DEVICE_NAME %s\n", cl_device_name);
        if(strcmp(cl_device_name, target_device_name) == 0) {
            device_id = devices[i];
            device_found = 1;
            printf("Selected %s as the target device\n", cl_device_name);
        }
    }

    if (!device_found) {
        printf("ERROR:Target device %s not found. Exit.\n", target_device_name);
        return EXIT_FAILURE;
    }

    // Create a compute context
    //
    context = clCreateContext(0, 1, &device_id, NULL, NULL, &err);
    if (!context) {
        printf("ERROR: Failed to create a compute context!\n");
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }

    // Create a command commands
    commands = clCreateCommandQueue(context, device_id, CL_QUEUE_PROFILING_ENABLE | CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE, &err);
    if (!commands) {
        printf("ERROR: Failed to create a command commands!\n");
        printf("ERROR: code %i\n",err);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }

    cl_int status;

    // Create Program Objects
    // Load binary from disk
    unsigned char *kernelbinary;
    char *xclbin = argv[1];

    //------------------------------------------------------------------------------
    // xclbin
    //------------------------------------------------------------------------------
    printf("INFO: loading xclbin %s\n", xclbin);
    cl_uint n_i0 = load_file_to_memory(xclbin, (char **) &kernelbinary);
    if (n_i0 < 0) {
        printf("ERROR: failed to load kernel from xclbin: %s\n", xclbin);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }

    size_t n0 = n_i0;

    // Create the compute program from offline
    program = clCreateProgramWithBinary(context, 1, &device_id, &n0,
                                        (const unsigned char **) &kernelbinary, &status, &err);
    free(kernelbinary);

    if ((!program) || (err!=CL_SUCCESS)) {
        printf("ERROR: Failed to create compute program from binary %d!\n", err);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }


    // Build the program executable
    //
    err = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    if (err != CL_SUCCESS) {
        size_t len;
        char buffer[2048];

        printf("ERROR: Failed to build program executable!\n");
        clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
        printf("%s\n", buffer);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }

    // Create the compute kernel in the program we wish to run
    //
    kernel = clCreateKernel(program, "PULPino_System", &err);
    if (!kernel || err != CL_SUCCESS) {
        printf("ERROR: Failed to create compute kernel!\n");
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }

    // Create structs to define memory bank mapping
    cl_mem_ext_ptr_t mem_ext;
    mem_ext.obj = NULL;
    mem_ext.param = kernel;


    mem_ext.flags = 4;
    d_spi_data = clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(cl_uint) * number_of_words, &mem_ext, &err);
    if (err != CL_SUCCESS) {
      std::cout << "Return code for clCreateBuffer flags=" << mem_ext.flags << ": " << err << std::endl;
    }


    if (!(d_spi_data)) {
        printf("ERROR: Failed to allocate device memory!\n");
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }


    err = clEnqueueWriteBuffer(commands, d_spi_data, CL_TRUE, 0, sizeof(cl_uint) * number_of_words, h_data, 0, NULL, NULL);
    if (err != CL_SUCCESS) {
        printf("ERROR: Failed to write to source array h_data: d_spi_data: %d!\n", err);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }


    // Set the arguments to our compute kernel
    // cl_uint vector_length = MAX_LENGTH;
    err = 0;
    cl_uchar d_spi_enable = 1;
    err |= clSetKernelArg(kernel, 0, sizeof(cl_uchar), &d_spi_enable); // Not used in example RTL logic.
    cl_uchar d_use_qspi = 1;
    err |= clSetKernelArg(kernel, 1, sizeof(cl_uchar), &d_use_qspi); // Not used in example RTL logic.
    cl_uint d_spi_addr_idx = addr_cmd_num;
    err |= clSetKernelArg(kernel, 2, sizeof(cl_uint), &d_spi_addr_idx); // Not used in example RTL logic.
    cl_uint d_instr_num = instr_num;
    err |= clSetKernelArg(kernel, 3, sizeof(cl_uint), &d_instr_num); // Not used in example RTL logic.
    err |= clSetKernelArg(kernel, 4, sizeof(cl_mem), &d_spi_data); 

    printf("spi_enable = %d, use_qspi = %d, spi_addr_idx = %d, instr_num = %d\n", d_spi_enable, d_use_qspi, d_spi_addr_idx, d_instr_num);

    if (err != CL_SUCCESS) {
        printf("ERROR: Failed to set kernel arguments! %d\n", err);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }

    size_t global[1];
    size_t local[1];
    // Execute the kernel over the entire range of our 1d input data set
    // using the maximum number of work group items for this device

    global[0] = 1;
    local[0] = 1;
    printf("Start Enqueue Kernel.\n");
    err = clEnqueueNDRangeKernel(commands, kernel, 1, NULL, (size_t*)&global, (size_t*)&local, 0, NULL, NULL);
    if (err) {
        printf("ERROR: Failed to execute kernel! %d\n", err);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }

    clFinish(commands);


    // Read back the results from the device to verify the output
    //
    cl_event readevent;

    err = 0;
    err |= clEnqueueReadBuffer( commands, d_spi_data, CL_TRUE, 0, sizeof(cl_uint) * number_of_words, h_spi_data_output, 0, NULL, &readevent );


    if (err != CL_SUCCESS) {
        printf("ERROR: Failed to read output array! %d\n", err);
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    }
    clWaitForEvents(1, &readevent);
    // Check Results

    for (cl_uint i = 0; i < instr_num; i++) {
    	printf("idx = %d  output = %x\n", i, h_spi_data_output[i]);
        //if ((h_data[i] + 1) != h_spi_data_output[i]) {
        //    printf("ERROR in PULPino_System::spi_axi - array index %d (host addr 0x%03x) - input=%d (0x%x), output=%d (0x%x)\n", i, i*4, h_data[i], h_data[i], h_spi_data_output[i], h_spi_data_output[i]);
        //    check_status = 1;
        //}
      //  printf("i=%d, input=%d, output=%d\n", i,  h_spi_data_input[i], h_spi_data_output[i]);
    }


    //--------------------------------------------------------------------------
    // Shutdown and cleanup
    //-------------------------------------------------------------------------- 
    clReleaseMemObject(d_spi_data);
    free(h_spi_data_output);



    free(h_data);
    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(commands);
    clReleaseContext(context);

    if (check_status) {
        printf("ERROR: Test failed\n");
        return EXIT_FAILURE;
    } else {
        printf("INFO: Test completed successfully.\n");
        return EXIT_SUCCESS;
    }


} // end of main

