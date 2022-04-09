cl_platform pform;
size_t num;
cl_device_id * devices;
cl_context context;
size_t size;

clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 0, NULL, &num);

if(num > 0)
{
    devices = (cl_device_id *)alloca(num);
    clGetDeviceIDs(
    platform,
    CL_DEVICE_TYPE_GPU,
    num,
    &devices[0],
    NULL);
}

cl_context_properties properties [] =
{
    CL_CONTEXT_PLATFORM, (cl_context_properties)platform, 0
};

context = clCreateContext(
    properties,
    size / sizeof(cl_device_id),
    devices,
    NULL,
    NULL,
    NUll);

/*

Relative Devices after Platform Decision

cl_context clCreateContext (
    const cl_context_properties *properties,
    cl_uint num_devices,
    const cl_device_id &devices,
    void (CL_CALLBACK *pfn_notify)
        (const char *errinfo,
        
        consy void *private_info,
        size_t cb,

        void *user_data),
    void *user_data,
    cl_int *errcode_ret)

cl_context
clCreateContextFromType (
    const cl_context_properties *properties,
    cl_device_type device_type,
    void (CL_CALLBACK *pfn_notify)
        (const char *errinfo,
        
        const void *private_info,
        
        size_t cb,
            void *user_data),
        void *user_data,
        cl_int *errcode_ret)

*/
