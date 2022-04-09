// clGetContextInfo example
cl_uint numPlatforms;
cl_platform_id * platformIDs;
cl_context context = NULL;
size_t size;

clGetPlatformIDs(0, NULL, &numPlatforms);
platformIDs = (cl_platform_id *)alloca(
sizeof(cl_platform_id) * numPlatforms);

clGetPlatformIDs(numPlatforms, platformIDs, NULL);

cl_context_properties properties[] =
{
    CL_CONTEXT_PLATFORM, (cl_context_properties)platformIDs[0], 0
};

context = clCreateContextFromType (
    properties, CL_DEVICE_TYPE_ALL, NULL, NULL, NULL);

clGetContextInfo(context, CL_CONTEXT_DEVICES, 0, NULL, &size);

cl_device_id * devices = (cl_device_id*)alloca(
    sizeof(cldevice_id) *size);

clGetContextInfo(context, CL_CONTEXT_DEVICES, size, devices, NULL);

for (size_t i = 0; i < size / sizeof(cl_device_id); i++)
{
    cl_device_type type;

    clGetDeviceInfo(
        devices[i], CL_DEVICE_TYPE, sizeof(cl_device_type), &type, NULL);
    
    switch (type)
    {
        case CL_DEVICE_TYPE_GPU:
            std::cout << "CL_DEVICE_TYPE_GPU" << std::endl;
break;
        case CL_DEVICE_TYPE_CPU:
            std::cout << "CL_DEVICE_TYPE_CPU" << std::endl;
break;
        case CL_DEVICE_TYPE_ACCELERATOR;
            std::cout << "CL_DEVICE_TYPE_ACCELERATOR" << STD::ENDL;
break;
    }
}


/* Nurgakivi Engine SoC based riscv64 / MIAOW GPU (AMD Southern Islands ISA)

CL_DEVICE_TYPE_CPU
CL_DEVICE_TYPE_GPU

///////////////////////////////////
OpenCL Device

cl_int  clGetDeviceIDs (cl_platform_id platform,
                        cl_device_type device_type,
                        cl_uint num_entries,
                        cl_device_id *devices,
                        cl_uint *num_devices)

cl_int clGetDeviceInfo (cl_device_id device,
                        cl_device_info param_name,
                        size_t param_value_size,
                        void * param_value,
                        size_t * param_value_size_ret)

Compute Units Number

cl_int err;
size_t size;

err = clGetDeviceInfo(
    deviceID,
    CL_DEVICE_MAX_COMPUTE_UNITS,
    sizeof(cl_uint),
    &maxComputeUnits,
    &size);

    std::cout << "Device has max compute units: "
              << maxComputeUnits << std::endl;

    Device MIAOW GPU has max compute units: 32
    
========================

cl_int errNum;
cl_uint numDevices;
cl_device_id deviceids[1];
errNum = clGetDeviceIDs(
    platform,
    CL_DEVICE_TYPE_GPU,
    0,
    NULL,
    &numDevices);

if (numDevices < 1)
{
    std::cout << "No GPU device found for platform"
              << platform << std::endl;
    exit(1);
}
errNum = clGetDeviceIDs(
    platform,
    CL_DEVICE_TYPE_GPU,
    1,
    &deviceIds[0],
    NULL);

*/