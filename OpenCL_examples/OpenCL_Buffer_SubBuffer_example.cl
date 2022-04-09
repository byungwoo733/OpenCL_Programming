//  Buffer & Sub-Buffer
// Buffer Creation
#define NUM_BUFFER_ELEMENTS 100
cl_int errNum;
cl_context;
cl_kernel kernel;
cl_command_queue queue;
float inputOutput[NUM_BUFFET_ELEMENTS];
cl_mem buffer;

// Here writes for creating Context, Kernel, Command-Queue

// inputOutput Initialization
buffer = clCreateBuffer(
    context,
    CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
    sizeof(float) * NUM_BUFFER_ELEMENTS,
    &errNum);

// Error Test

errNum = setKernelArg(kernel, 0, sizeof(buffer), &buffer);

// Define Buffer input to Argument Example
// (ex)
__kernel void squre(__global float * buffer)
{
    size_t id = get_global_id(0);
    buffer[id] = buffer[id] * buffer[id];
}

// How clEnqueueNDRangeKernel Offset Argument calculate Buffer Offset example
// (ex)
#define NUM_BUFFER_ELEMENTS 100
cl_int errNum;
cl_uint numDevices;
cl_device_id * deviceIDs;
cl_context;
cl_kernel kernel;
std::vector<cl_command_queue> queues;
float * inputOutput;
cl_mem buffer;

// Here writes for creating Context, Kernel, Command-Queue

// inputOutput Initialization

buffer = clCreateBuffer(
    context,
    CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
    sizeof(float) * NUM_BUFFER_ELEMENTS,
    inputOutput,
    &errNum);

// Error Test

errNum = setKernelArg(kernel, 0, sizeof(buffer), &buffer);

// Each Devices Command-Queue Creation
for (int i = 0; i < numDevices; i++)
{
    cl_command_queue queue = 
    clCreateCommandQueue(
        context,
        deviceIDs[i],
        0,
        &errNum);
    queues.push_back(queue);
}  

// Put Each Queues in Kernel
for (int i = 0; i < queues.size(); i++)
{
    cl_event event;

    size_t qWI = NUM_BUFFER_ELEMENTS;
    size_t offset = i * NUM_BUFFER_ELEMENTS * sizeof(int);

    errNum = clEnqueueNDRangeKernel(
    queue[i],
    kernel,
    1,
    (const size_t*)&offset,
    (const size_t*)&gWI,
    (const size_t*)NULL,
    0,
    0,
    &event);

    events.push_back(event);
} 

// Wait until Command Complete.
clWaitForEvents(events.size(), events.data());

/*
cl_mem clCreateBuffer(cl_context context,
                      cl_mem_flags flags,
                      size_t size,
                      void * host_ptr,
                      cl_int *errcode_ref)


*/

//====================================
// Sub-Buffer Creation
#define NUM_BUFFER_ELEMENTS 100
cl_int errNum;
cl_uint numDevices;
cl_device_id * deviceIDs;
cl_context;
cl_kernel kernel;
std::vector<cl_command_queue> queues;
std::vector<cl_mem> buffers;
float * inputOutput;
cl_mem buffer;

// Here writes for creating Context, Kernel, Command-Queue
// inputOutput Initialization

buffer = clCreate(
    context,
    CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
    sizeof(float) * NUM_BUFFER_ELEMENTS,
    inputOutput,
    &errNum);

buffers.push_back(buffer);

// Each Devices Command-Queue Creation
for (int i = 0; i < numDevices; i++)
{
    cl_command_queue queue = 
    clCreateCommandQueue(
        context,
        deviceIDs[i],
        0,
        &errNum);
    queues.push_back(queue);

    cl_kernel kernel = clCreateKernel(
        program,
        "square",
        &errNum);

    errNum = clSetKernelArg(
        kernel,
        0,
        sizeof(cl_mem),
        (void *)&buffers[i]);
    
    kernels.push_back(kernel);
}

    std::vector<cl_event> events;
    // Put Each Queues in Kernel
    for (int i = 0; i < queues.size(); i++)
    {
         cl_event event;

        size_t qWI = NUM_BUFFER_ELEMENTS;

        errNum = clEnqueueNDRangeKernel(
            queue[i],
            kernel[i],
            1,
            NULL,
            (const size_t*)&gWI,
            (const size_t*)NULL,
            0,
            0,
            &event);

    events.push_back(event);
} 

// Wait until Command Complete.
clWaitForEvents(events.size(), events.data());

/*
cl_mem clCreateSubBuffer(
    cl_context context,
    cl_mem_flags flags,
    cl_buffer_create_type buffer_create_type,
    const void * buffer_create_info,
    cl_int *errcode_ref)

*/

//===================================
// Be in front of Sub-Buffer For OpenGL Buffer Resource Cancellation 
for (int i = 0; i < buffers.size(); i++)
{
    buffers.clReleaseMemObject(buffers[i]);
}

//====================================
//====================================
// Buffer & Sub-Buffer Inquiry
cl_int clGetMemObjectInfo(cl_mem buffer,
                          cl_mem_info param_name,
                          size_t param_value_size,
                          void * param_value,
                          size_t *param_value_size_ret) 

//------------------------------------
// How does it do inquiry for deciding Buffer Object or Other Memory Object of OpenCL after Inquiry about Memory Object  
cl_int errNum;
cl_mem memory;
cl_mem_object_type type;

// Memory Object etc Initialization
errNum = clGetMemObjectInfo(
    memory,
    CL_MEM_TYPE,
    sizeof(cl_mem_object_type),
    &type,
    NULL);
switch(type)
{
    case CL_MEM_OBJECT_BUFFER:
    {
        // this case says if Object is Buffer or Sub-Buffer.
        break;  
    }
    case CL_MEM_OBJECT_IMAGE2D:
    case CL_MEM_OBJECT_IMAGE3D:
    {
        // this case says if Object is 2D OR 3D Image Object.
        break;
    }
    default
    // Happened So Bad Work
    break;
}

//=======================================
//=======================================
// Read, Write, Copy about Buffer & Sub-Buffer 
cl_int clEnqueueWriteBuffer(cl_command_queue command_queue,
                            cl_mem buffer,
                            cl_bool blocking_write,
                            size_t offset,
                            size_t cb,
                            void * ptr,
                            cl_uint num_events_in_wait_list,
                            const cl_event * event_wait_list,
                            cl_event *event)

//----------------------------------------
// When Buffer creates, This is Same Runnning be instead of Data Copy from Host Pointer 
cl_mem buffer = clCreateBuffer(
    context,
    CL_MEM_READ_WRITE,
    sizeof(int) * NUM_BUFFER_ELEMENTS * numDevices,
    NULL,
    &errNUm);

// Sub-Buffer, Command-Queue etc Creation Code

// Buffer 0 writes Data using Command-Queue 0
clEnqueueWriteBuffer(
     queues[0],
     buffers[0],
     CL_TRUE,
     0,
     sizeof(int) * NUM_BUFFER_ELEMENTS * numDevices,
     (void*)inputOutput,
     0,
     NULL,
     NULL);

//===========================================
// Put Read Command in Command-Queue For Host Memory:
cl_int clEnqueueReadBuffer(cl_command_queue command_queue,
                           cl_mem buffer,
                           cl_bool blocking_raed,
                           size_t offset,
                           size_t cb,
                           void * ptr,
                           cl_uint num_events_in_wait_list,
                           const cl_event * event_wait_list,
                           cl_event *event)

//-------------------------------------------
// Read & Output Square Kernel Running Result 
// Read Calculated dat 
clEnqueueReadBuffer(
    queues[0],
    buffer[0],
    CL_TRUE,
    0,
    sizeof(int) * NUM_BUFFER_ELEMENTS * numDevices,
    (void*)inputOutput,
    0,
    NULL,
    NULL);

// Array Output
for (unsigned i = 0; i < numDevices; i++)
{
    for (unsigned elems = i * NUM_BUFFER_ELEMENTS;
         elems < ((i+1) * NUM_BUFFER_ELEMENTS);
         elems++)
    {
        std::cout << " " << inputOutput[elems];   
    }

  std::cout << std::endl;
}

//------------------------------------------
// Kernel Code Example about Buffer & Sub-Buffer Creation, Write, Read  
simple.cl

__kernel void square(
    __global int * buffer)
{
    const size_t id = get_global_id(0);

    buffer[id] = buffer[id] * buffer[id];
}

//------------------------------------------
// Host Code Example about Buffer & Sub-Buffer Creation, Write, Read
simple.cpp

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

#include "info.hpp"

// if Platfrom one over is setting up
// Setting Value by Real Usage Value.
#define PLATFORM_INDEX 0

#define NUM_BUFFER_ELEMENTS 10

// OpenCL Error Test running Function
checkErr(cl_int err, const char * name)
{
    if (err != CL_SUCCESS) {
        std::cerr << "ERROR: "
                  << NAME << " (" << err << ")" << std::endl;
        exit(EXIT_FAILURE);
    }
}

///
// main() for Simple Buffer & Sub-Buffer example
//
int main(int argc, char** argv)
{
    cl_int errNum;
    cl_uint numPlatforms;
    cl_uint numDevices;
    cl_platform_id * platformIDs;
    cl_device_id * deviceIDs;
    cl_context context;
    cl_program program;
    std::vector<cl_kernel> kernels;
    std::vector<cl_command_queue> queues;
    std::vector<cl_mem> buffers;
    int * inputOutput;

    std::cout << "Simple buffer and sub-buffer Example"
              << std::endl;
    
    // First, Decide Running OpenCL Platform.
    errNum = clGetPlatformIDs(0, NULL, &numPlatforms);
    checkErr(
        (errNum != CL_SUCCESS) ?
         errNum : (NUMpLATFORMS <= 0 ? -1 : cl_success),
         "CLgETpLATFORMidS");

    std::ifstream srcFile("simple.cl");
    checkErr(srcFile.is_open() ?
             CL_SUCCESS : -1,
             "reading simple.cl");

    std::string srcProg(
        std::istreambuf_iterator<char>(srcFile),
        (std::istreambuf_iterator<char()));

    const char * src = srcProg.c_str();
    size_t length = srcProg.length();

    deviceIDs = NULL;

    DisplayPlatformInfo(
        platformIDs[PLATFORM_INDEX],
        CL_PLATFORM_VENDOR,
        "CL_PLATFORM_VENDOR");

    errNum = clGetDeviceIDa(
        platformIDs[PLATFORM_INDEX],
        CL_DEVICE_TYPE_ALL,
        0,
        NULL,
        &numDevices);
    if (errNum != CL_SUCCESS && errNum != CL_DEVICE_NOT_FOUND)
    {
        checkErr(errNum, "clGetDeviceIDs");
    }

    deviceIDs = (cl_device_id *)alloca(
        sizeof(cl_device_id) * numDevices);
    errNum = clGetDeviceIDs(
        platformIDs[PLATFORM_INDEX],
        CL_DEVICE_TYPE_ALL,
        numDevices,
        &deviceIDs[0],
        NULL);
    checkErr(errNum, "clGetDeviceIDs");

    cl_context_properties contextProperties[] =
    {
        CL_CONTEXT_PLATFORM,
        (cl_context_properties)platformIDs[PLATFORM_INDEX],
        0
    };
    
    context = clCreateContext(
        contextProperties,
        numDevices,
        deviceIDs,
        NULL,
        NULL,
        &errNum);
    checkErr(errNum, "clCreateContext");

    // Program Creation From Source
    program = clCreateProgramWithSource(
        context,
        1,
        &src,
        &length,
        &errNum);
    checkErr(errNum, "clCreateProgramWithSource");

    // Program Build
    errNum = clBuildProgram(
        program,
        numDevices,
        deviceIDs,
        "-I.",
        NULL,
        NULL);
    if (errNum != CL_SUCCESS)
    {
        // Reason Decision about Error.
        char buildingLog[16384];
        clGetProgramBuildInfo(
            program,
            deviceIDs[0],
            CL_PROGRAM_BUILD_LOG,
            sizeof(building),
            buildLog,
            NULL);

            std::cerr << "Error in OpenCL C source: " << std::endl;
            std::cerr << buildLog;
            checkErr(errNum, "clBuildProgram");
    }

    // Buffer & Sub-Buffer Creation
    inputOutput = new int[NUM_BUFFER_ELEMENTS * numDevices];
    for (unsigned int i = 0;
        i < NUM_BUFFER_ELEMENTS * numDevices;
        i++)
    {
        inputOutput[i] = i;
    }

    // Single Buffer Creation For All Input Data Control
    cl_mem buffer = clCreateBuffer(
        context,
        CL_MEM_READ_WRITE,
        sizeof(int) * NUM_BUFFER_ELEMENTS * numDevices,
        NULL,
        &errNum);
    checkErr(errNum, "clCreateBuffer");
    buffers.push_back(buffer);

    // Now, Remain All Device Creates Sub-Buffer except First Device.
    for (unsigned int i = 1; i < numDevices; i++)
    {
        cl_buffer_region region =
        {
            NUM_BUFFER_ELEMENTS * i * sizeof(int),
            NUM_BUFFER_ELEMENTS * sizeof(int)
        };
    buffer = clCreateSubBuffer(
        buffers[0],
        CL_BUFFER_CREATE_TYPE_REGION,
        &region,
        &errNUm);
    checkErr(errNum, "clCreateSubBuffer");

    buffers.push_back(buffer);
}

// Command-Queue Creation
for (int i = 0; i < numDevices; i++)
{
    InfoDevice<cl_device_type>::display(
        deviceIDs[i],
        CL_DEVICE_TYPE,
        "CL_DEVICE_TYPE");

    cl_command_queue queue =
        clCreateCommandQueue(
            context,
            deviceIDs[i],
            0,
            &errNum);
        checkErr(errNum, "clCreateKernel(square)");

        errNum = clSetKernelArg(
    kernel,
    0,
    sizeof(cl_mem), (void *)&buffers[i]);
checkErr(errNum, "clSetKernelArg(square)");

        kernels.push_back(kernel);
}

// Write Input Data
clEnqueueWriteBuffer(
    queues[0],
    buffers[0],
    CL_TRUE,
    0,
    sizeof(int) * NUM_BUFFER_ELEMENTS * numDevices,
    (void*)inputOutput,
    0,
    NULL,
    NULL);

std::vector<cl_event> events;
// Callback Kernel about Each devices
for (int i = 0; i < queues.size(); i++)
{
    cl_event event;

    size_t gWI = NUM_BUFFER_ELEMENTS;

    errNum = clEnqueueNDRangeKernel(
        queues[i],
        kernels[i],
        1,
        NULL,
        (const size_t*)&gWI,
        (const size_t*)NULL,
        0,
        0,
        &event);
        events.push_back(event);
}

// Technically, This is useless because of running Blocking Reading From In-order Command-Queue.
clWriteForEvents(events.size(), events.data());

// Read Again Calculated Result
clEnqueueReadBuffer(
    queues[0],
    buffers[0],
    CL_TRUE,
    0,
    sizeof(int) * NUM_BUFFER_ELEMENTS * numDevices,
    (void*)inputOutput,
    0,
    NULL,
    NULL);

// Result Array Output.
for (unsigned i = 0; i < numDevices; i++)
{
    for (unsigned elems = i * NUM_BUFFER_ELEMENTS;
        elems < ((i+1) * NUM_BUFFER_ELEMENTS);
        elems++)
    {
        std::cout << " " << inputOutput[elems];
    }

    std::cout << std::endl;
}

std::cout << "Program completed successfully" << std::endl;

    return 0;

}

//====================================================
// Read, Write Buffer & Host Memory
/*
cl_int clEnqueueReadBufferRect(
                          
                          cl_command_queue command_queue,
                          cl_mem buffer,
                          cl_bool blocking_read,
                          const size_t buffer_origin[3],
                          const size_t host_origin[3],
                          const size_t region[3],
                          size_t buffer_row_pitch,
                          size_t host_row_pitch,
                          size_t host_slice_pitch,
                          void * ptr,
                          cl_uint num_events_in_wait_list,
                          const cl_event * event_wait_list,
                          cl_event * event)
*/

// Offset about Memory Area Calculation: Buffer 
buffer_origin[2] * buffer_slice_pitch +
buffer_origin[1] * buffer_row_pitch +
buffer_origin[0]

// Offset about Memory Area Calculation: Host
host_origin[2] * host_slice_pitch +
host_origin[1] * host_row_pitch +
host_origin[0]

// 2x2 Read From Buffer to Host:
#define NUM_BUFFER_ELEMENTS 16
cl_int errNum;
cl_command_queue queue;
cl_context context;
cl_mem buffer;

// Context, Queue etc Initialization

cl_int hostBuffer [NUM_BUFFER_ELEMENTS] =
{
    0, 1, 2, 3, 4, 5, 6, 7,
    8, 9, 10, 11, 12, 13, 14, 15
};

BUFFER = clCreateBuffer(
    context,
    CL_MEM_RAED | CL_MEM_COPY_HOST_PTR,
    sizeof(int) * NUM_BUFFER_ELEMENTS,
    hostBuffer,
    &errNum);

int ptr[4] = {-1, -1, -1, -1};
size_t buffer_origin[3] = {1*sizeof(int), 1, 0};
size_t host_origin[3]   = {0, 0, 0};
size_t region[3]        = {2* sizeof(int), 2, 1};

errNum = clEnqueueReadBufferRect(
    queue,
    buffer,
    CL_TRUE,
    buffer_origin,
    host_origin,
    region,
    (NUM_BUFFER_ELEMENTS / 4) * sizeof(int),
    0,
    0,
    2*sizeof(int),
    static_cast<void*>(ptr),
    0,
    NULL,
    NULL);

std::cout << " " << ptr[0];
std::cout << " " << ptr[1] << std::endl;
std::cout << " " << ptr[2];
std::cout << " " << ptr[3] << std::endl;

//=======================================
// Buffer in Host Memory using Function From Buffer in 2D & 3D area
cl_int clEnqueueWriteBufferRect(
                            cl_command_queue command_queue,
                            cl_mem buffer,
                            cl_bool blocking_write,
                            const size_t buffer_origin[3],
                            const size_t host_origin[3],
                            const size_t region[3],
                            size_t buffer_row_pitch,
                            size_t buffer_slice_pitch,
                            size_t host_row_pitch,
                            size_t host_slice_pitch,
                            void * ptr,
                            cl_uint num_events_in_wait_list,
                            const cl_event * event_wait_list,
                            cl_event * event)

//======================================== 
// Data Copy Between Two Buffers
cl_int clEnqueueCopyBuffer(
                          cl_command_queue command_queue,
                          cl_mem src_buffer,
                          cl_mem dst_buffer,
                          size_t src_offset,
                          size_t dst_offset,
                          size_t cb,
                          cl_uint num_events_in_wait_list,
                          const cl_event * event_wait_list,
                          cl_event * event)

//========================================
// From  Buffer 2D or 3D to Other Buffer Copy like Buffer Read &  Write
cl_int clEnqueueCopyBuffer(
                          cl_command_queue command_queue,
                          cl_mem src_buffer,
                          cl_mem dst_buffer,
                          const size_t src_origin[3],
                          const size_t dst_origin[3],
                          const size_t region[3],
                          size_t src_row_pitch,
                          size_t src_slice_pitch,
                          size_t dst_row_pitch,
                          size_t dst_slice_pitch,
                          cl_uint num_events_in_wait_list,
                          const cl_event * event_wait_list,
                          cl_event * event)

//========================================
// Buffer & Sub-Buffer Mapping
void * clEnqueueMapBuffer(cl_command_queue command_queue,
                          cl_mem buffer,
                          cl_bool blocking_map,
                          cl_map_flags map_flags,
                          size_t offset,
                          size_t cb,
                          cl_uint num_events_in_wait_list,
                          const cl_event * event_wait_list,
                          cl_event *event,
                          cl_int *errcode_ref)

//========================================
cl_in clEnqueueUnmapMemObject(cl_command_queue command_queue,
                              cl_mem buffer,
                              void * mapped_pointer,
                              cl_uint num_events_in_wait_list,
                              const cl_event * event_wait_list,
                              cl_event *event)

//=======================================
// How Data  Buffer Move using clEnqueueReadBuffer or clEnqueueWriteBuffer 
// instead of clEnqueueMapBuffer & clEnqueueUnmapMemObject
cl_int * mapPtr = (cl_int*) clEnqueueMapBuffer(
    queues[0],
    buffers[0],
    CL_TRUE,
    CL_MAP_WRITE,
    0,
    sizeof(cl_int) * NUM_BUFFER_ELEMENTS * NUMdEVICES, 
    0,
    null,
    null,
    &errNum);
checkErr (errNum, "clEnqueueMapBuffer(...)");

for (unsigned int i = 0;
    i < NUM_BUFFER_ELEMENTS * numDevices;
    i++)
{
    mapPtr[i] = inputOutput[i];
}

errNum = clEnqueueUnmapMemObject(
    queues[0],
    buffer[0],
    mapPtr,
    0,
    NULL,
    NULL);
clFinish(queues[0]);

// Lastly, Read Data Again 
cl_int * mapPtr = (cl_int*) clEnqueueMapBuffer(
    queues[0],
    buffers[0],
    CL_TRUE,
    CL_MAP_READ,
    0,
    sizeof(cl_int) * NUM_BUFFER_ELEMENTS * numDevices,
    0,
    NULL,
    NULL,
    &errNum);
checkErr(errNum, "clEnqueueMapBuffer(..)");

for (unsigned int i = 0;
    i < NUM_BUFFER_ELEMENTS * numDevices;
    i++)
{
    inputOutput[i] = mapPtr[i];
}

errNum = clEnqueueUnmapMemObject(
    queues[0],
    buffers[0],
    mapPtr,
    0,
    NULL,
    NULL);
    clFinish(queues[0]);