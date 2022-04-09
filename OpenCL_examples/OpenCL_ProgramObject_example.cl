// Program Object
// Program Object Creation
cl_program clCreateProgramWithSource ( cl_context context,
    cl_uint count, const char **strings, const size_t *lengths,
    cl_int *errcode_ret)

cl_program clCreateProgramWithBinary (cl_context context,
    cl_uint num_devices, const cl_device_id *device_list,
    const size_t *lengths, const unsigned char **binaries,
    cl_int *binary_status, cl_int *errcode_ret)

cl_int clRetainProgram (cl_program program)

cl_int clReleaseProgram (cl_program program)

// Program Running File Build
cl_int clBuildProgram (cl_program program, cl_uint num_devices,
    const cl_device_id *device_list, const char *options,
    void (CL_CALLBACK*pfn_notify) (cl_program program,
    void *user_data), void *user_data)

// Build Option
// Preproceessor
(-D processed in order listed in clBuildProgram)
-D name
-D name=definition
-I dir

// Optimization Option
-cl-opt-disable
-cl-strict-aliasing
-cl-mad-enable
-cl-no-signed-zeros
-cl-finite-math-only
-cl-fast-relaxed-math
-cl-unsafe-math-optimizations

// Math 
-cl-single-precision-constant
-cl_denorms-are-zero

// Warning Request / Hide
-w
-Werror

// OpenCL C version Control
-cl-std=CL1.1 // OpenCL 1.1 specification.

// Program Object Inquiry
cl_int clGetProgramInfo (cl_program program,
    cl_program_info param_name,size_t param_value_size,
    void *param_value, size_t *param_value_size_ret)
param_name: CL_PROGRAM_{REFERENCE_COUNT},
    CL_PROGRAM_{CONTEXT, NUM_DEVICES, DEVICES},
    CL_PROGRAM_{SOURCE, BINARY_SIZES, BINARIES}

cl_int clGetProgramBuildInfo (cl_program program,
    cl_device_id device, cl_program_build_info param_name,
    size_t param_value_size, void *param_value,
    size_t *param_value_size_ret)
param_name: CL_PROGRAM_BUILD_{STATUS, OPTIONS, LOG}

// OpenCL Compiler Unload
cl_int clUnloadCompiler (void)