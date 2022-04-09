// Copyright (c) 2010 Advanced Micro Devices, Inc. All rights reserved.
//
// A minimalist OpenCL program.

// [OpenCL Example Code 1] AMD Minimalist OpenCL program

#include <CL/cl.h>
#include <stdio.h>
#define NWITEMS 512
// A simple memset kernel
const char *source =
"__kernel void memset( __global uint *dst ) \n"
"{ \n"
" dst[get_global_id(0)] = get_global_id(0); \n"
"} \n";
int main(int argc, char ** argv)
{
 // 1. Get a platform.
 cl_platform_id platform;

 clGetPlatformIDs( 1, &platform, NULL );
 // 2. Find a gpu device.
 cl_device_id device;

 clGetDeviceIDs( platform, CL_DEVICE_TYPE_GPU,
 1,
 &device,
 NULL);
 // 3. Create a context and command queue on that device.
 cl_context context = clCreateContext( NULL,
 1,
 &device,
 NULL, NULL, NULL);
 cl_command_queue queue = clCreateCommandQueue( context,
 device,
 0, NULL );
 // 4. Perform runtime source compilation, and obtain kernel entry point.
 cl_program program = clCreateProgramWithSource( context,
 1,
 &source,
 NULL, NULL );
 clBuildProgram( program, 1, &device, NULL, NULL, NULL );
 cl_kernel kernel = clCreateKernel( program, "memset", NULL );
 // 5. Create a data buffer.
 cl_mem buffer = clCreateBuffer( context,
 CL_MEM_WRITE_ONLY,

 // 6. Launch the kernel. Let OpenCL pick the local work size.
 size_t global_work_size = NWITEMS;
 clSetKernelArg(kernel, 0, sizeof(buffer), (void*) &buffer);
 clEnqueueNDRangeKernel( queue,
 kernel,
 1,
 NULL,
 &global_work_size,
 NULL, 0, NULL, NULL);
 clFinish( queue );
 // 7. Look at the results via synchronous buffer map.
 cl_uint *ptr;
 ptr = (cl_uint *) clEnqueueMapBuffer( queue,
 buffer,
 CL_TRUE,
 CL_MAP_READ,
 0,
 NWITEMS * sizeof(cl_uint),
 0, NULL, NULL, NULL );
 int i;
 for(i=0; i < NWITEMS; i++)
 printf("%d %d\n", i, ptr[i]);
 return 0;
}


/////////////////////////////////////////////////////////////////

// [OpenCL Example Code 2] AMD Minimalist OpenCL program

#define __CL_ENABLE_EXCEPTIONS
#include <CL/cl.hpp>
#include <string>
#include <iostream>
#include <string>
using std::cout;
using std::cerr;
using std::endl;
using std::string;
/////////////////////////////////////////////////////////////////
// Helper function to print vector elements
/////////////////////////////////////////////////////////////////
void printVector(const std::string arrayName,
 const cl_float * arrayData,
 const unsigned int length)
{
 int numElementsToPrint = (256 < length) ? 256 : length;
 cout << endl << arrayName << ":" << endl;
 for(int i = 0; i < numElementsToPrint; ++i)
 cout << arrayData[i] << " ";
 cout << endl;
}
/////////////////////////////////////////////////////////////////
// Globals
/////////////////////////////////////////////////////////////////
int length = 256;
cl_float * pX = NULL;
cl_float * pY = NULL;
cl_float a = 2.f;
std::vector<cl::Platform> platforms;
cl::Context context;
std::vector<cl::Device> devices;
cl::CommandQueue queue;
cl::Program program;

cl::Kernel kernel;
cl::Buffer bufX;
cl::Buffer bufY;
/////////////////////////////////////////////////////////////////
// The saxpy kernel
/////////////////////////////////////////////////////////////////
string kernelStr =
 "__kernel void saxpy(const __global float * x,\n"
 " __global float * y,\n"
 " const float a)\n"
 "{\n"
 " uint gid = get_global_id(0);\n"
 " y[gid] = a* x[gid] + y[gid];\n"
 "}\n";
/////////////////////////////////////////////////////////////////
// Allocate and initialize memory on the host
/////////////////////////////////////////////////////////////////
void initHost()
{
 size_t sizeInBytes = length * sizeof(cl_float);
 pX = (cl_float *) malloc(sizeInBytes);
 if(pX == NULL)
 throw(string("Error: Failed to allocate input memory on host\n"));
 pY = (cl_float *) malloc(sizeInBytes);
 if(pY == NULL)
 throw(string("Error: Failed to allocate input memory on host\n"));
 for(int i = 0; i < length; i++)
 {
 pX[i] = cl_float(i);
 pY[i] = cl_float(length-1-i);
 }
 printVector("X", pX, length);
 printVector("Y", pY, length);
}
/////////////////////////////////////////////////////////////////
// Release host memory
/////////////////////////////////////////////////////////////////
void cleanupHost()
{
 if(pX)
 {
 free(pX);
 pX = NULL;
 }
 if(pY != NULL)
 {
 free(pY);
 pY = NULL;
 }
}
void
main(int argc, char * argv[])
{
 try
 {
 /////////////////////////////////////////////////////////////////
 // Allocate and initialize memory on the host 
 /////////////////////////////////////////////////////////////////
 initHost();
 /////////////////////////////////////////////////////////////////
 // Find the platform
 /////////////////////////////////////////////////////////////////
 cl::Platform::get(&platforms);
 std::vector<cl::Platform>::iterator iter;
 for(iter = platforms.begin(); iter != platforms.end(); ++iter)
 {
if(!strcmp((*iter).getInfo<CL_PLATFORM_VENDOR>().c_str(),
"Advanced Micro Devices, Inc."))
{
break;
} }
 /////////////////////////////////////////////////////////////////
 // Create an OpenCL context
 /////////////////////////////////////////////////////////////////
 cl_context_properties cps[3] = { CL_CONTEXT_PLATFORM,
(cl_context_properties)(*iter)(), 0 };
 context = cl::Context(CL_DEVICE_TYPE_GPU, cps);
 /////////////////////////////////////////////////////////////////
 // Detect OpenCL devices
 /////////////////////////////////////////////////////////////////
 devices = context.getInfo<CL_CONTEXT_DEVICES>();
 /////////////////////////////////////////////////////////////////
 // Create an OpenCL command queue
 /////////////////////////////////////////////////////////////////
 queue = cl::CommandQueue(context, devices[0]);
 /////////////////////////////////////////////////////////////////
 // Create OpenCL memory buffers
 /////////////////////////////////////////////////////////////////
 bufX = cl::Buffer(context,
 CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
 sizeof(cl_float) * length,
 pX);
 bufY = cl::Buffer(context,
 CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
 sizeof(cl_float) * length,
 pY);
 /////////////////////////////////////////////////////////////////
 // Load CL file, build CL program object, create CL kernel object
 /////////////////////////////////////////////////////////////////
 cl::Program::Sources sources(1, std::make_pair(kernelStr.c_str(),
kernelStr.length()));
 program = cl::Program(context, sources);
 program.build(devices);
 kernel = cl::Kernel(program, "saxpy");
 /////////////////////////////////////////////////////////////////
 // Set the arguments that will be used for kernel execution
 /////////////////////////////////////////////////////////////////
 kernel.setArg(0, bufX);
 kernel.setArg(1, bufY);
 kernel.setArg(2, a);
 /////////////////////////////////////////////////////////////////
 // Enqueue the kernel to the queue
 // with appropriate global and local work sizes
 /////////////////////////////////////////////////////////////////
 queue.enqueueNDRangeKernel(kernel, cl::NDRange(),
 cl::NDRange(length), cl::NDRange(64));

 /////////////////////////////////////////////////////////////////
 // Enqueue blocking call to read back buffer Y
 /////////////////////////////////////////////////////////////////
queue.enqueueReadBuffer(bufY, CL_TRUE, 0, length *
sizeof(cl_float), pY);
 printVector("Y", pY, length);

 /////////////////////////////////////////////////////////////////
 // Release host resources
 /////////////////////////////////////////////////////////////////
 cleanupHost();
 }
 catch (cl::Error err)
 {
 /////////////////////////////////////////////////////////////////
 // Catch OpenCL errors and print log if it is a build error
 /////////////////////////////////////////////////////////////////
 cerr << "ERROR: " << err.what() << "(" << err.err() << ")" <<
endl;
 if (err.err() == CL_BUILD_PROGRAM_FAILURE)
 {
 string str =
program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(devices[0]);
 cout << "Program Info: " << str << endl;
 }
 cleanupHost();
 }
 catch(string msg)
 {
 cerr << "Exception caught in main(): " << msg << endl;
 cleanupHost();
 }
}

/////////////////////////////////////////////////////////////////

// [OpenCL Example Code 3] AMD Minimalist OpenCL program

//
// Copyright (c) 2010 Advanced Micro Devices, Inc. All rights reserved.
//
#include <CL/cl.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "Timer.h"
#define NDEVS 2
// A parallel min() kernel that works well on CPU and GPU
const char *kernel_source =
" \n"
"#pragma OPENCL EXTENSION cl_khr_local_int32_extended_atomics : enable \n"
"#pragma OPENCL EXTENSION cl_khr_global_int32_extended_atomics : enable \n"
" \n"
" // 9. The source buffer is accessed as 4-vectors. \n"
" \n"
"__kernel void minp( __global uint4 *src, \n"
" __global uint *gmin, \n"
" __local uint *lmin, \n"
" __global uint *dbg, \n"
" int nitems, \n"
" uint dev ) \n"
"{ \n"
" // 10. Set up __global memory access pattern. \n"
" \n"
" uint count = ( nitems / 4 ) / get_global_size(0); \n"
" uint idx = (dev == 0) ? get_global_id(0) * count \n"
" : get_global_id(0); \n"
" uint stride = (dev == 0) ? 1 : get_global_size(0); \n"
" uint pmin = (uint) -1; \n"
" \n"
" // 11. First, compute private min, for this work-item. \n"
" \n"
" for( int n=0; n < count; n++, idx += stride ) \n"
" { \n"
" pmin = min( pmin, src[idx].x ); \n"
" pmin = min( pmin, src[idx].y ); \n"
" pmin = min( pmin, src[idx].z ); \n"
" pmin = min( pmin, src[idx].w ); \n"
" } \n"
" \n"
" // 12. Reduce min values inside work-group. \n"
" \n"
" if( get_local_id(0) == 0 ) \n"
" lmin[0] = (uint) -1; \n"
" \n"
" barrier( CLK_LOCAL_MEM_FENCE ); \n"
" \n"
" (void) atom_min( lmin, pmin ); \n"
" \n"
" barrier( CLK_LOCAL_MEM_FENCE ); \n"
" \n"
" // Write out to __global. \n"
" \n"
" if( get_local_id(0) == 0 ) \n"
" gmin[ get_group_id(0) ] = lmin[0]; \n"
" \n"
" // Dump some debug information. \n"
" \n"
" if( get_global_id(0) == 0 ) \n"
" { \n"
" dbg[0] = get_num_groups(0); \n"
" dbg[1] = get_global_size(0); \n"
" dbg[2] = count; \n"
" dbg[3] = stride; \n"
" } \n"
"} \n"
" \n"
"// 13. Reduce work-group min values from __global to __global. \n"
" \n"
"__kernel void reduce( __global uint4 *src, \n"
" __global uint *gmin ) \n"
"{ \n"
" (void) atom_min( gmin, gmin[get_global_id(0)] ) ; \n"
"} \n";
int main(int argc, char ** argv)
{
 cl_platform_id platform;
 int dev, nw;
 cl_device_type devs[NDEVS] = { CL_DEVICE_TYPE_CPU,
 CL_DEVICE_TYPE_GPU };
 cl_uint *src_ptr;
 unsigned int num_src_items = 4096*4096;
 // 1. quick & dirty MWC random init of source buffer.
 // Random seed (portable).
 time_t ltime;
 time(&ltime);
 src_ptr = (cl_uint *) malloc( num_src_items * sizeof(cl_uint) );

 cl_uint a = (cl_uint) ltime,
 b = (cl_uint) ltime;
 cl_uint min = (cl_uint) -1;
 // Do serial computation of min() for result verification.
 for( int i=0; i < num_src_items; i++ )
 {
 src_ptr[i] = (cl_uint) (b = ( a * ( b & 65535 )) + ( b >> 16 ));
 min = src_ptr[i] < min ? src_ptr[i] : min;
 }
// Get a platform.
 clGetPlatformIDs( 1, &platform, NULL );
 // 3. Iterate over devices.
 for(dev=0; dev < NDEVS; dev++)
 {
 cl_device_id device;
 cl_context context;
 cl_command_queue queue;
 cl_program program;
 cl_kernel minp;
 cl_kernel reduce;
 cl_mem src_buf;
 cl_mem dst_buf;
 cl_mem dbg_buf;
 cl_uint *dst_ptr,
 *dbg_ptr;
 printf("\n%s: ", dev == 0 ? "CPU" : "GPU");
 // Find the device.
 clGetDeviceIDs( platform,
 devs[dev],
 1,
 &device,
 NULL);
 // 4. Compute work sizes.
 cl_uint compute_units;
 size_t global_work_size;
 size_t local_work_size;
 size_t num_groups;
 clGetDeviceInfo( device,
 CL_DEVICE_MAX_COMPUTE_UNITS,
 sizeof(cl_uint),
 &compute_units,
 NULL);
 if( devs[dev] == CL_DEVICE_TYPE_CPU )
 {
 global_work_size = compute_units * 1; // 1 thread per core
 local_work_size = 1;
 }
 else
 {
     cl_uint ws = 64;
 global_work_size = compute_units * 7 * ws; // 7 wavefronts per SIMD
 while( (num_src_items / 4) % global_work_size != 0 )
 global_work_size += ws;
 local_work_size = ws;
 }
 num_groups = global_work_size / local_work_size;
 // Create a context and command queue on that device.
 context = clCreateContext( NULL,
 1,
 &device,
 NULL, NULL, NULL);
 queue = clCreateCommandQueue(context,
 device,
 0, NULL);
 // Minimal error check.
 if( queue == NULL )
{
 printf("Compute device setup failed\n");
 return(-1);
 }
 // Perform runtime source compilation, and obtain kernel entry point.
 program = clCreateProgramWithSource( context,
 1,
 &kernel_source,
 NULL, NULL );
 //Tell compiler to dump intermediate .il and .isa GPU files.
ret = clBuildProgram( program,
1,
&device,
“-save-temps”,
NUL, NULL );
 // 5. Print compiler error messages
 if(ret != CL_SUCCESS)
 {
 printf("clBuildProgram failed: %d\n", ret);
 char buf[0x10000];
 clGetProgramBuildInfo( program,
 device,
 CL_PROGRAM_BUILD_LOG,
 0x10000,
 buf,
 NULL);
 printf("\n%s\n", buf);
 return(-1);
 }
 minp = clCreateKernel( program, "minp", NULL );
 reduce = clCreateKernel( program, "reduce", NULL );
 // Create input, output and debug buffers.
 src_buf = clCreateBuffer( context,
 CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
 num_src_items * sizeof(cl_uint),
 src_ptr,
 NULL );
 dst_buf = clCreateBuffer( context,
 CL_MEM_READ_WRITE,
 num_groups * sizeof(cl_uint),
 NULL, NULL );
 dbg_buf = clCreateBuffer( context,
 CL_MEM_WRITE_ONLY,
 global_work_size * sizeof(cl_uint),
 NULL, NULL );
 clSetKernelArg(minp, 0, sizeof(void *), (void*) &src_buf);
 clSetKernelArg(minp, 1, sizeof(void *), (void*) &dst_buf);
 clSetKernelArg(minp, 2, 1*sizeof(cl_uint), (void*) NULL);
 clSetKernelArg(minp, 3, sizeof(void *), (void*) &dbg_buf);
 clSetKernelArg(minp, 4, sizeof(num_src_items), (void*) &num_src_items);
 clSetKernelArg(minp, 5, sizeof(dev), (void*) &dev);
 clSetKernelArg(reduce, 0, sizeof(void *), (void*) &src_buf);
 clSetKernelArg(reduce, 1, sizeof(void *), (void*) &dst_buf);
 CPerfCounter t;
 t.Reset();
 t.Start();
 // 6. Main timing loop.
#define NLOOPS 500
 cl_event ev;
 int nloops = NLOOPS;
 while(nloops--)
{
 clEnqueueNDRangeKernel( queue,
 minp,
 1,
 NULL,
 &global_work_size,
 &local_work_size,
 0, NULL, &ev);
 clEnqueueNDRangeKernel( queue,
 reduce,
 1,
 NULL,
 &num_groups,
 NULL, 1, &ev, NULL);
 }
 clFinish( queue );
 t.Stop();

 printf("B/W %.2f GB/sec, ", ((float) num_src_items *
 sizeof(cl_uint) * NLOOPS) /
 t.GetElapsedTime() / 1e9 );
 // 7. Look at the results via synchronous buffer map.
 dst_ptr = (cl_uint *) clEnqueueMapBuffer( queue,
 dst_buf,
 CL_TRUE,
 CL_MAP_READ,
 0,
 num_groups * sizeof(cl_uint),
 0, NULL, NULL, NULL );
 dbg_ptr = (cl_uint *) clEnqueueMapBuffer( queue,
 dbg_buf,
 CL_TRUE,
 CL_MAP_READ,
 0,
 global_work_size *
 sizeof(cl_uint),
 0, NULL, NULL, NULL );
 // 8. Print some debug info.
 printf("%d groups, %d threads, count %d, stride %d\n", dbg_ptr[0],
 dbg_ptr[1],
 dbg_ptr[2],
 dbg_ptr[3] );
 if( dst_ptr[0] == min )
 printf("result correct\n");
 else
 printf("result INcorrect\n");
 }
 printf("\n");
 return 0;
}



/*
template<typename T>
T add(T a, T b) {
    return a + b;
}
kernel void k(global int* in1, global int* in2, global int* out) {
    auto index = get_global_id(0);
    out[index] = add(in1[index], in2[index]);
}

// Unrolled Kernel Using float4 for Vectorization
__kernel void loopKernel4(int loopCount,
                          global float3 *output,
                          global const float4 *input)
{
    uint gid = get_global_id(0);

    for (int i=0; i<loopCount; i+=1) {
        float4 Velm = input[i] * 6.0 + 17.0;

        output[gid+i] = Velm;
    }
}

*/