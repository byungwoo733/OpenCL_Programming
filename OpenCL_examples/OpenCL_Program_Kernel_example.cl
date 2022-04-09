cl_program CreateProgram(cl_context context, cl_device_id device,
                         const char* fileName)
{
    cl_int errNum;
    cl_program program;

    ifstream kernelFile(fileName, ios::in);
    if (!kernelFile.is_open())
    {
        cerr << "Fialed to open file for reading: " << fileName << endl;
        return NULL;
    }

    ostringstream oss;
    oss << kernelFile.rdbuf();

    string srcStdStr = oss.str();
    const char *srcStr = srcStdStr.c_str();

    program = clCreateProgramWithSource(context, 1,
                                        (const char**)&srcStr,
                                        NULL, NULL);
    if (program == NULL)
    {
        cerr << "Failed to create CL program from source." << endl;return NULL;
    }

    errNum = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    if (errNum != CL_SUCCESS)
    {
        // Decide the reason about Error
        char buildLog[16384];
        clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG,
                              sizeof(buildLog), buildLog, NULL);
        
        cerr << "Error in kernel: " << endl;
        cerr << buildLog;
        clReleaseProgram(program);
        return NULL;
    }

    return program;
}



/* 
// Create Program
cl_program clCreateProgramWithSource(cl_context context,
                                     cl_uint count,
                                     const char **strings,
                                     const size_t *lengths,
                                     cl_int *errcode_ret)


// Program Object Build
cl_int clBuildProgram(cl_program program,
                      cl_uint num_devices,
                      const cl_device_id *device_list,
                      const char *options,
                      void (CL_CALLBACK *pfn_notify)
                           (cl_program program,
                           void *user_data),
                      void *user_data)

Preprocessor variable define case:
Program Build of Original Kernel Function include Program Object should be same about All Devices 

#ifdef SOME_MACRO
__kernel void my_kernel(__global const float* p) {
     // ...
}

#else // !SOME_MACRO
__kernel void my_kernel(__global const int* p) {
    // ...
}

#endif // !SOME_MACRO

*/

// ========================================================
// ********************************************************
// ========================================================

// When First Running, does Program Binary Cash
program = CreateProgramFromBinary(context, device,
                                  "HelloWorld.cl.bin");

if (program == NULL)
{
    program = CreateProgram(context, device,
                            "HelloWorld.cl");

    if (program == NULL)
    {
        Cleanup(context, commandQueue, program,
                kernel, memObjects);
        return 1;
    }

    if (SaveProgramBinary(program, device, "HelloWorld.cl.bin")
                            == false)
    {
        std::cerr << "Failed to write program binary"
                  << std::endl;
        Cleanup(context, commandQueue, program,
                kernel, memObjects);
        return 1;
    }
}
else
{
    std::cout << "Read program from binary." << std::endl;
}

// ====================================================
// Question & Save about Program Binary

bool SaveProgramBinary(cl_program program, cl_device_id device,
                       const char* fileName)
{
    cl_uint numDevices = 0;
    cl_int errNum;

    // 1 -Relative Device Number Question about Program
    errNum = clGetProgramInfo(program, CL_PROGRAM_NUM_DEVICES,
                              sizeof(cl_uint),
                              &numDevices, NULL);
    if (errNum != CL_SUCCESS)
    {
        STD::CERR << "Error querying for number of devices."
                  << std::endl;
                  return false;
    }

    // 2 - Get All Device ID 
    cl_device_id *devices = new cl_device_id[numDevices];
    errNum = clGetProgramInfo(program, CL_PROGRAM_DEVICES,
                              sizeof(cl_device_id) * numDevices,
                              devices, NULL);
    if (errNum != CL_SUCCESS)
    {
        STD::CERR << "Error querying for devices." << std::endl;
        delete [] devices;
        return false;
    }

    // 3 - Decide Each Program Binaries Size 
    size_t *programBinarySizes = new size_t [numDevices];
    errNum = clGetProgramInfo(program, CL_PROGRAM_BINARY_SIZES,
                              sizeof(size_t) ** numDevices,
                              programBinarySizes, NULL);
    if (errNum != CL_SUCCESS)
    {
        std::cerr << "Error querying for program binary sizes."
                  << std::endl;
        delete [] devices;
        delete [] programBinarySizes;
        return false;
    }

    unsigned char **programBinaries = 
        new unsigned char*[nunmDevices];
    for (cl_uint i = 0; i < numDevices; i++)
    {
        programBinaries[i] = 
            new unsigned char[programBinarySizes[i]];
    }

    // 4 - Get All Program Binaries
    errNum = clGetProgramInfo(program, CL_PROGRAM_BINARIES,
                              sizeof(unsigned char*) * numDevices,
                              programBinaries, NULL);
    if (errNum != CL_SUCCESS)
    {
        std::cerr << "Error querying for program binaries"
                  << std::endl;

        delete [] devices;
        delete [] programBinarySizes;
        for (cl_uint i = 0; i < numDevices; i++)
        {
            delete [] programBinaries[i];
        }
        delete [] programBinaries;
        return false;
    }

    // 5 - Finally, Binary about Request Device
    // When Reads Later, Save in Disk.
    for (cl_uint i = 0; < numDevices; i++)
    {
        // Only, Save about Request Device
        // in using sinario in Various Devices
        // All Binaries saves here.
        if (devices[i] == device)
        {
            FILE *FP = FOPEN(fileName, "wb");
            fwrite(programBinaries[i], 1,
                   programBinarySizes[i], fp);
            fclose(fp);
            break;
        } 
    }

    // Summary
    delete [] devices;
    delete [] programBinarySizes;
    for (cl_uint i = 0; i < numDevices; i++)
    {
        delete [] programBinaries[i];
    }
    delete [] programBinaries;

    return true;
}

//============================================
cl_program CreateProgramFromBinary(cl_context context,
                                   cl_device_id device,
                                   const char* fileName)
{
    FILE *fp = fopen(fileName, "rb");
    if (fp == NULL)
    {
        return NULL;
    }

    // Decide Binary Size.
    size_t binarySize;
    fseek(fp, 0, SEEK_END);
    binarySize = ftell(fp);
    rewind(fp);

    // Binary Stack in Disk
    unsigned char *programBinary = new unsigned char[binarySize];
    fread(programBinary, 1, binarySize, fp);
    fclose(fp);

    cl_int errNum = 0;
    cl_program program;
    cl_int binaryStatus;

    program = clCreateProgramWithBinary(context,
                1,
                &device,
                &binarySize,
                (const unsigned char**)&programBinary,
                &binaryStatus,
                &errNum);
    
    delete [] programBinary;
    if (errNum != CL_SUCCESSS)
    {
        std::cerr << "Error loading program binary." << std::endl;
        return NULL;
    }
    if (binaryStatus != CL_SUCCESS)
    {
        std::cerr << "Invalid binary for device" << std::endl;
        return NULL;
    }

    errNum = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    if (errNum != CL_SUCCESS)
    {
        // Determine the reason for the error
        char buildLog[16384];
        clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG,
                              sizeof(buildLog), buildLog, NULL);
        std::cerr << "Error in program: " << std::endl;
        std::cerr << buildLog << std::endl;
        clReleaseProgram(program);
        return NULL;
    }

    return program;
}


/*
// Creates Program From Binary 
// Get Program Binary From Build Completed Program
cl_int clGetProgramInfo(cl_program program,
                        cl_program_info param_name,
                        size_t param_value_size,
                        void *param_value,
                        size_t *param_value_size_ret)

// Save Program Binary in Disk
cl_program clCreateProgramWithBinary(cl_context context,
                                     cl_uint num_devices,
                                     const cl_device_id *
                                        device_list,
                                     const size_t *lengths,
                                     const unsigned char
                                        **binaries,
                                     cl_int *binary_status,
                                     cl_int *errcode_ret) 

=====================================
// Create Kernel Object & Kernel Argument
cl_kernel clCreateKernel(cl_program program,
                         const char *kernel_name,
                         cl_int *errcode_ret)

 
cl_int clSetKernelArg(cl_kernel kernel,
                       cl_uint arg_index,
                       size_t *arg_size,
                       const void *arg_value)

========================================

__kernel void hello_kernel(__global const float *a,
                           __global const float *b,
                           __global float *result)
    {
        int gid = get_global_id(0);

        result[gid] = a[gid] + b[gid];
    }

-----------------------------
kernel = clCreateKernel(program, "hello_kernel", NULL);
    if (kernel == NULL)
{
    std::cerr << "Failed to create kernel" << std::endl;
    Cleanup(context, commandQueue, program, kernel, memObjects);
    return 1;
}

// Setting Kernel Argument(result, a, b)
errNum = clSetKernelArg(kernel, 0, sizeof(cl_mem),
                         &memObjects[0]);
errNum |= clSetKernelArg(kernel, 1, sizeof(cl_mem),
                         &memObjects[1]);
errNum |= clSetKernelArg(kernel, 2, sizeof(cl_mem),
                         &memObjects[2]);
if (errNum != CL_SUCCESS)
{
    std::cerr << "Error setting kernel arguments." <<std::endl;
    Cleanup(context, commandQueue, program, kernel, memObjects);
    return 1;
}


------------------------------
// Float Point Buffer
__kernel void arg_example(global int *vertexArray,
                          int vertexCount,
                          float weight,
                          local float* localArray)
                          {
                            ...
                          }

------------------------------
kernel = clCreateKernel(program, "arg_example", NULL);
cl_int vertexCount;
cl_float weight;
cl_mem vertexArray;
cl_int localWorkSize[1] = {32};

// Create VertexArray using clCreateBuffer
// vertexCount & weight gives Value.
...
errNum = clSetKernelArg(kernel, 0, sizeof(cl_mem), &vertexArray);
errNum |= clSetKernelArg(kernel, 1, sizeof(cl_int), &vertexCount);
errNum |= clSetKernelArg(kernel, 2, sizeof(cl_float), &weight);
errNum |= clSetKernelArg(kernel, 3, sizeof(cl_float) 8 localWorkSize[0], NULL);

===================================
// Create Kernel in Program
cl_int clCreateKernelsInProgram(cl_program program,
                                cl_uint num_kernels,
                                cl_kernel *kernels,
                                cl_uint *num_kernels_ret)
------------------------------------
ex)
cl_uint numKernels;
errNum = clCreateKernelsInProgram(program, NULL, NULL, &numKernels);

cl_kernel *kernels = new cl_kernel[numKernels];
errNum = clCreateKernelsInProgram(program, numKernels, kernels, &numKernels);

====================================
// Keep going Kernel & Question
cl_int clGetKernelInfo(cl_kernel kernel,
                       cl_kernel_info param_name,
                       size_t param_value_size,
                       void *param_value,
                       size_t *param_value_size_ret)

-------------------------------------
// Kernel Working Information
cl_int clGetKernelWorkGroupInfo(cl_kernel kernel,
                                cl_device_id device,
                                cl_kernel_work_group_info param_name,
                                size_t param_value_size,
                                void *param_value,
                                size_t *param_value_size_ret)
------------------------------------
ex)
cl_program program = clCreateProgramWithSource(...);
clBuildProgram(program, ...);
cl_kernel k = clCreateKernel(program, "foo");

// Callback CL APIs of Kernel & Other Instructions in Instruction-Queue.
cl_BuildProgram(program, ...); // Kernel Object "k" up
                               // Because Not yet cancel 
                               // Callback Failure 


*/
