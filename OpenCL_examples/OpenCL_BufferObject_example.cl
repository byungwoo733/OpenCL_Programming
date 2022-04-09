// Buffer Object
// Create Buffer Object
cl_mem clCreateBuffer (cl_context context, cl_mem_flags flags,
    size_t size, void *host_ptr, cl_int *errcode_ret)

cl_mem clCreateSubBuffer (cl_mem buffer, cl_mem_flags flags,
    cl_buffer_create_type buffer_create_type,
    const void *buffer_create_info, cl_int *errcode_ret)

flags for clCreateBuffer and clCreateSubBuffer:
    CL_MEM_READ_WRITE, CL_MEM_{WRITE, READ}_ONLY,
    CL_MEM_{USE, ALLOC, COPY}_HOST_PTR

//Read, Write, Copy about Buffer Object
cl_int clEnqueueReadBuffer ( cl_command_queue command_queue,
    cl_mem buffer, cl_bool blocking_read, size_t offset, size_t cb,
    void *ptr, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueWriteBuffer ( cl_command_queue command_queue,
    cl_mem buffer, cl_bool blocking_write, size_t offset, size_t cb,
    const void *ptr, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueReadBufferRect ( cl_command_queue command_queue,
    cl_mem buffer, cl_bool blocking_read, 
    const size_t buffer_origin[3], const size_t host_origin[3],
    const size_t region[3], size_t buffer_row_pitch,
    size_t buffer_slice_pitch, size_t host_row_pitch,
    size_t host_slice_pitch, void *ptr,
    cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueWriteBufferRect ( cl_command_queue command_queue,
    cl_mem buffer, cl_bool blocking_write,
    const size_t buffer_origin[3], const size_t host_origin[3],
    const size_t region[3], size_t buffer_row_pitch,
    size_t buffer_slice_pitch, size_t host_row_pitch,
    size_t host_slice_pitch, void *ptr,
    cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueCopyBuffer ( cl_command_queue command_queue,
    cl_mem src_buffer, cl_mem dst_buffer, size_t src_offset,
    size_t dst_offset, size_t cb, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueReadBuffer ( cl_command_queue command_queue,
    cl_mem src_buffer, cl_mem dst_buffer, const size_t src_origin[3],
    const size_t dst_origin[3], const size_t region[3],
    size_t src_row_pitch, size_t src_slice_pitch,
    size_t dst_row_pitch, size_t dst_slice_pitch,
    cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

// Buffer Object Mapping
void * clEnqueueMapBuffer (cl_command_queue command_queue,
    cl_mem buffer, cl_bool blocking_map, cl_map_flags map_flags,
    size_t offset, size_t cb, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event,
    cl_int *errcode_ret)

// Buffer Object Management
cl_int clRetainMemObject (cl_mem memobj)

cl_int clReleaseMemObject (cl_mem memobj)

cl_int clSetMemObjectDestructorCallback (cl_mem memobj,
    void (CL_CALLBACK *pfn_notify) (cl_mem memobj, void *user_data),
    void *user_data)

cl_int clEnqueueUnmapMemObject (cl_command_queue command_queue,
    cl_mem memobj, void *mapped_ptr, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

// Buffer Object Inquiry
cl_int clGetMemObjectInfo (cl_mem memobj, cl_mem_info param_name,
    size_t param_value_size, void *param_value,
    size_t *param_value_size_ret)
param_name: CL_MEM_{TYPE, FLAGS, SIZE, HOST_PTR},
    CL_MEM_{MAP, REFERENCE}_COUNT, CL_MEM_OFFSET,
    CL_MEM_CONTEXT, CL_MEM_ASSOCIATED_MEMOBJECT