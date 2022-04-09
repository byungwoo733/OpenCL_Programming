// Kernel & Event Object
// Kernel Object Creation
cl_kernel clCreateKernel (cl_program program,
    const char *kernel_name, cl_int *errcode_ret)

cl_int clCreateKernelsInProgram (cl_program program,
    cl_uint num_kernels, cl_kernel *kernels,
    cl_uint *num_kernels_ret)

cl_int clRetainKernel (cl_kernel kernel)

cl_int clReleaseKernel (cl_kernel kernel)

// Kernel Argument & Object Inquiry
cl_int clSetKernelArg (cl_kernel kernel, cl_uint arg_index,
    size_t arg_size, const void *arg_value)

cl_int clGetKernelInfo (cl_kernel kernel, cl_kernel_info param_name,
    size_t param_value_size, void *param_value,
    size_t *param_value_size_ret)
param_name: CL_KERNEL_FUNCTION_NAME, CL_KERNEL_NUM_ARGS,
    CL_KERNEL_REFERENCE_COUNT, CL_KERNEL_CONTEXT, CL_KERNEL_PROGRAM

cl_int clGetKernelorkGroupInfo (cl_kernel kernel,
    cl_device_id device, cl_kernel_work_group_info param_name,
    size_t param_value_size, void *param_value,
    size_t *param_value_size_ret)
param_name: CL_KERNEL_WORK_GROUP_SIZE,
    CL_KERNEL_COMPILE_WORK_GROUP_SIZE,
    CL_KERNEL_{LOCAL, PRIVATE}_MEM_SIZE,

// Kernel Running
cl_int clEnqueueNDRangeKernel ( cl_command_queue command_queue,
    cl_kernel kernel, cl_uint work_dim,
    const size_t *global_work_offset,
    const size_t *global_work_size,
    const size_t *local_work_size, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueTask (cl_command_queue command_queue,
    cl_kernel kernel, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueNativeKernel (cl_command_queue command_queue,
    void (*user_func)(void *), void *args, size_t cb_args,
    cl_uint num_mem_objects, const cl_mem *mem_list,
    const void **args_mem_loc, cl_uint num_events_in_wait_li

// Event Object
cl_event clCreateUserEvent (cl_context context, cl_int *errcode_ret)

cl_int clSetUserEventStatus (cl_event event,
    cl_int execution_status)

cl_int clWaitForEvents (cl_event event,
    const cl_event *event_list)

cl_int clWaitForEvents (cl_uint num_events,
    const cl_event *event_list)

cl_int clGetEventInfo (cl_event event, cl_event_info param_name,
    size_t param_value_size, void *param_value,
    size_t *param_value_size_ret)
param_name: CL_EVENT_COMMAND_{QUEUE, TYPE},
    CL_EVENT_{CONTEXT, REFERENCE_COUNT},
    CL_EVENT_COMMAND_EXECUTION_STATUS

cl_int clSetEventCallback (cl_event event,
    cl_int command_exec_callback_type,
    void (CL_CALLBACK *pfn_event_notify)(cl_event event,
    cl_int event_command_exec_status,
    void *user_data), void *user_data)

cl_int clRetainEvent (cl_event event)
cl_int clReleaseEvent (cl_event event)

// Out-of-order Kernel Running & Memory Object Instruction
cl_int clEnqueueMarker (cl_command_queue command_queue,
    cl_event *event)

cl_int clEnqueueWaitForEvents (cl_command_queue command_queue,
    cl_uint num_events, const cl_event *event_list)

cl_int clEnqueueBarrier (cl_command_queue command_queue)

// Profiling Arithmetic
cl_int clGetEventProfilingInfo (cl_event event,
    cl_profiling_info param_name, size_t param_value_size,
    void *param_value, size_t *param_value_size_ret)
param_name: CL_PROFILING_COMMAND_QUEUED,
    CL_PROFILING_COMMAND_{SUBMIT, START, END}

// Flush & Finish
cl_int clFlush (cl_command_queue command_queue)

cl_int clFinish (cl_command_queue command_queue)