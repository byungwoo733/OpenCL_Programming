// OpenCL Runtime
//Command-Queue
cl_command_queue clCreateCommandQueue (cl_context context,
    cl_device_id device, cl_command_queue_properties properties,
    cl_int *errcode_ret)
properties: CL_QUEUE_PROFILING_ENABLE,
    CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE

cl_int clRetainCommandQueue (cl_command_queue command_queue)

cl_int clReleaseCommandQueue (cl_command_queue command_queue)

cl_int clGetCommandQueueInfo (cl_command_queue command_queue,
    cl_command_queue_info param_name, size_t param_value_size,
    void *param_value, size_t *param_value_size_ret)
param_name: CL_QUEUE_CONTEXT, CL_QUEUE_DEVICE,
    CL_QUEUE_REFERENCE_COUNT, CL_QUEUE_PROPERTIES