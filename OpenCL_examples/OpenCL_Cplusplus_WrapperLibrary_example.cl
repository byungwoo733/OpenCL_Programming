// Vector Add Example Program using C+= API 
// OpenCL C++ Exception Activation
#define__CL_ENABLE_EXCEPTIONS

#if defined(__APPLE__) || defined(__MACOSX)
#include <OpenCL/cl.hpp>
#else
#include <CL/cl.hpp>
#endif

#include <cstdio>
#include <cstdlib>
#include <iostream>

#define BUFFER_SIZE 20
int A[BUFFER_SIZE];
int B[BUFFER_SIZE];
int C[BUFFER_SIZE];

static char

kernelSourceCode[] =
"__kernel void \n"
"vadd(__global int * a, __global int * b, __global int * c) \n"
"{                                                          \n"
"    size_t i =get_global_id(0);                            \n"
"                                                           \n"
"    c[i] = a[i] + b[i]                                     \n"
"}                                                          \n"
;

int
mian(void)
{
    cl_int err;

    // A, B, C Initialization
    for (int i = 0; i < BUFFER_SIZE; i++) {\
      A[i] = i;
      A[i] = i * 2;
      A[i] = 0;
    }

    try {
        std::vector<cl::Platform> platformList;

        // Choose Platform.
        cl::Platform::get(&platformList);

        // Choose First Platform
        cl_context_properties cprops[] = (
            CL_CONTEXT_PLATFORM,
            (cl_context_properties)(platformList[0]) (), 0);
        cl::Context context(CL_DEVICE_TYPE_GPU, cprops);

        // Context relative Devices Inquiry
        std::vector<cl::Device> devices =
            context.getInfo<CL_CONTEXT_DEVICES>();
        
        // Command_Queue Creation
        cl::CommandQueue queue(context, devices[0], 0);

        // Program Creation From Source
        cl::Program::Sources sources(
            1,
            std::make_pair(kernelSourceCode,
            0));
        cl::Program program(context, sources);
    
        // Program Build
        program.build(devices);

        // Buffer Creation about A & Host Content Copy.
        cl::Buffer aBuffer = cl::Buffer(
            context,
            CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
            BUFFER_SIZE * sizeof(int),
            (void *) &A[0]);

        //  Buffer Creation about B & Host Content Copy.
        cl::Buffer aBuffer = cl::Buffer(
            context,
            CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
            BUFFER_SIZE * sizeof(int),
            (void *) &B[0]);

        // Buffer Creation about C & Host Content Copy.
        cl::Buffer aBuffer = cl::Buffer(
            context,
            CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
            BUFFER_SIZE * sizeof(int),
            (void *) &C[0]);
    
        // Kernel Object Creation.
        cl::Kernel kernel(program, "vadd");

        // Kernel Argument Setting
        kernel.seTaRG(0, aBuffer);
        kernel.setArg(1, bBuffer);
        kernel.setArg(2, cBuffer);

        // Working Running.
        queue.enqueueNDRangeKernel(
            kernel,
            cl::NullRange,
            cl::NDRange(BUFFER_SIZE),
            cl::NullRange);

        // cBuffer Host Pointer Mapping. This forces Host & Syncronization    
        // We should remember GPU Device Choice.
        int * output = (int *) queue.enqueueMapBuffer(
            cBuffer,
            CL_TRUE, // block
            CL_MAP_READ,
            0,
            Buffer_SIZE * sizeof(int));

        for (int i = 0; i < BUFFER_SIZE; i++) {
            std::cout << C[i] << " ";
        }
        std::cout << std::endl;

        // Lastly, Memory Access Cancellation.
        err = queue.enqueueUnmapMemObject(
            cBuffer,
            (void *) output);
        
        // Last Mapping Cancellation Finsihes Management or Anything Object Cancellation Useless.
        // Because Evreything in C++ API 
        // Happening 
    }
    catch (cl::Error err) {
        std::cerr
            << "ERROR: "
            << err.what()
            << "("
            << err.err()
            << ")"
            <<std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}  


/*
(Import)
C++ API (include OpenCL C API)
#include <cl.hpp>


std::vector<cl::Platform> platformList;
cl::Platform::get(&platformList);
cl_platform platform = platformList[0] ();


//------------------------
extern void someFunction (cl_program);

cl_platform platform;
{
    std::vector<cl::Platform>platformList;
    cl::Platform::get(&platformList);
    platform = platformList[0]();

    someFunction(platform); // safe call
}

someFunction(platform); // not safe

// C++ API Exception
__CL_ENABLE_EXCEPTIONS

// Basic Running Override
__CL_USER_OVERRIDE_ERROR_STRINGS

--------------------------------

// OpenCL Platform Choice & Context Creation

Callback cl::Platform::get
std::vector<cl::Platform> platformList;
cl::Platform::get(&getPlatformList);

// Context Creation Code
cl_context_properties cprops[] = {
    CL_CONTEXT_PLATFORM,
    (cl_context_properties) (platformList[0])(),
    0};

cl::Context context(CL_DEVICE_TYPE_GPU, cprops);

// Device Choice & Command-Queue Creation
templete <cl_int> typename
detail::param_traites<detail::cl_XX_info, name>::param_type
cl::Object::getInfo(void);

-----------------------------------

// What kind of Context Devices Inquiry
std::vector<cl::Device> devices =
    context.getInfo<CL_CONTEXT_DEVICES>();

// Command-Queue Creation
cl::CommandQueue queue(context, devices[0], 0);

// Program Object Creation & Build
cl::Program::Sources sources(
    1,
    std::make_pair(kernelSourceCode,
    0));
cl::Program program(context, sources);

program.build(devices);

// Kernel & Memory Object Creation
// Code Buffer Assignment
cl::Buffer aBuffer = cl::Buffer(
    context,
    CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
    BUFFER_SIZE * sizeof(int),
    (void *) &A[0]);

cl::Buffer bBuffer = cl::Buffer(
    context,
    CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
    BUFFER_SIZE * sizeof(int),
    (void *) &B[0]);

cl::Buffer cBuffer = cl::Buffer(
    context,
    CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
    BUFFER_SIZE * sizeof(int),
    (void *) &C[0]);

// Creation through Callback cl::Kernel() Function 
cl::Kernel kernel(program, "vadd");

------------------------------

// Vector Add Kernel Running:
kernel.SetArg(0, aBuffer);
kernel.SetArg(1, bBuffer);
kernel.SetArg(2, cBuffer);


// Working Size:
queue.enqueueNDRangeKernel(
    kernel,
    cl::NullRange,
    cl::NDRange(BUFFER_SIZE),
    cl::NullRange);

// Host Pointer Mapping:
int * output = (int *) queue.enqueueMapBuffer(
    cBuffer,
    CL_TRUE, // block
    CL_MAP_READ,
    0,
    BUFFER_SIZE * sizeof(int));

// output position data complete, Mapping Memory Callback & cancellation by cl::CommandQueue::enqueueUnmapMemOBj()
err = queue.enqueueUnmapMemObject(
    cBuffer,
    (void *) output);
