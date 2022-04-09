// OpenCL Platform Choice & Create Context
cl_context CreateContext()
{
    cl_int errNum;
    cl_uint numPlatforms;
    cl_platform_id firstPlatformId;
    cl_context context = NULL;

    // First, select the OpenCL platform to run on.
    // In this example, we simply select the first available platform.
    // In general, by querying all available platforms,
    // You will choose the most appropriate one.

    errNum = clGetPlatformIDs(1, &firstPlatformId, &numPlatforms);
    if (errNum != CL_SUCCESS || numPlatforms <= 0)
    {
        cerr << "Failed to find any OpenCL platforms." <<endl;
        return NULL;
    }

    // Next, create an OpenCL context on the platform.
    // Attempts to create a GPU-based context, and if that fails
    // Attempts to create a CPU-based context.
    cl_context_properties contextProperties[] =
    {
        CL_CONTEXT_PLATFORM,
        (cl_context_properties)firstPlatformId,
        0
    };
    context = clCreateContextFromType(contextProperties,
                                      CL_DEVICE_TYPE_GPU,
                                      NULL, NULL, &errNum);
    
    if (errNum != CL_SUCCESS)
    {
        cout << "Could not create GPU context, tring CPU..."
             << endl;
        context = clCreateContextFromType(contextProperties,
                                          CL_DEVICE_TYPE_CPU,
                                          NULL, NULL, &errNUM);
        if (errNum != CL_SUCCESS)
        {
            cerr <<
                "Failed to create an OpenCL GPU or CPU context.";
            return NULL;
        }
    }

    return context;
}