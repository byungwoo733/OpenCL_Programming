    // Platform Information Device Inquiry
    cl_int clGetPlatformIDs (cl_uint num_entries,
        cl_platform_id *platforms, cl_uint *num_platforms)
    
    cl_int clGetPlatformInfo (cl_platform_id platform,
        cl_platform_info param_name, size_t param_value_size,
        void *param_value, size_t *param_value_size_ret)
    param_name: CL_PLATFORM_{PROFILE, VERSION},
        CL_PLATFORM_{NAME, VENDOR, EXTENSIONS}
    
    cl_int clGetDeviceIDs (cl_platform_id platform,
        cl_device_type device_type, cl_uint num_entries,
        cl_device_id *devices, cl_uint *num_devices)
    device_type: CL_DEVICE_TYPE_{CPU, GPU},
        CL_DEVICE_TYPE_{ACCELERATOR, DEFAULT, ALL}
    
    cl_int clGetDeviceInfo (cl_device_id device,
        cl_device_info param_name, size_t param_value_size,
        void *param_value, size_t *param_value_size_ret)
    param_name: CL_DEVICE_TYPE,
        CL_DEVICE_VENDOR_ID,
        CL_DEVICE_MAX_COMPUTE_UNITS,
        CL_DEVICE_MAX_WORK_ITEM_{DIMENSIONS, SIZES},
        CL_DEVICE_MAX_WORK_GROUP_SIZE,
        CL_DEVICE_{NATIVE, PREFERRED}_VECTOR_WIDTH_CHAR,
        CL_DEVICE_{NATIVE, PREFERRED}_VECTOR_WIDTH_SHORT,
        CL_DEVICE_{NATIVE, PREFERRED}_VECTOR_WIDTH_INT,
        CL_DEVICE_{NATIVE, PREFERRED}_VECTOR_WIDTH_LONG,
        CL_DEVICE_{NATIVE, PREFERRED}_VECTOR_WIDTH_FLOAT,
        CL_DEVICE_{NATIVE, PREFERRED}_VECTOR_WIDTH_DOUBLE,
        CL_DEVICE_{NATIVE, PREFERRED}_VECTOR_WIDTH_HALF,
        CL_DEVICE_MAX_CLOCK_FREQUENCY,
        CL_DEVICE_ADDRESS_BITS,
        CL_DEVICE_MAX_MEM_ALLOC_SIZE,
        CL_DEVICE_IMAGE_SUPPORT,
        CL_DEVICE_{READ, WRITE}_IMAGE_ARGS,
        CL_DEVICE_IMAGE2D_MAX_{WIDTH, HEIGHT},
        CL_DEVICE_IMAGE3D_MAX_{WIDTH, HEIGHT, DEPTH},
        CL_DEVICE_MAX_SAMPLERS,
        CL_DEVICE_MAX_PARAMETER_SIZE,
        CL_DEVICE_MEM_BASE_ADDR_ALIGN,
        CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE,
        CL_DEVICE_SINGLE_FP_CONFIG,
        CL_DEVICE_GLOBAL_MEM_CACHE{TYPE, SIZE},
        CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE,
        CL_DEVICE_GLOBAL_MEM_SIZE,
        CL_DEVICE_MAX_CONSTANT_{BUFFER_SIZE, ARGS}
        CL_DEVICE_LOCAL_MEM {TYPE, SIZE},
        CL_DEVICE_ERROR_CORRECTION_SUPPORT,
        CL_DEVICE_PROFILING_TIMERRESOLUTION,
        CL_DEVICE_ENDIAN_LITTLE,
        CL_DEVICE_AVAILABLE,
        CL_DEVICE_EXECUTION_CAPABILITIES,
        CL_DEVICE_QUEUE_PROPERTIES,
        CL_DEVICE_{NAME, VENDOR, PROFILE, EXTENSIONS},
        CL_DEVICE_HOST_UNIFIED_MEORY,
        CL_DEVICE_OPENCL_C_VERSION,
        CL_DEVICE_VERSION,
        CL_DRIVER_VERSION, CL_DEVICE_PLATFORM