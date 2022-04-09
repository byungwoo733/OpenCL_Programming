// Platform List
void displayInfo (void)
{
    cl_int errNum;
    cl_uint numPlatforms;
    cl_platform_id * platformIds;
    cl_context context = NULL;

    // Ask All Platform Number 
    errNum = clGetPlatformIDs(0, NULL, &numPlatforms);
    if (errNum != CL_SUCCESS || numPlatforms <= 0)
    {
        std::cerr << "Failed to find any OpenCL platform." << std::endl;
        return;
    }

    // Next, Memory divide about Installed Platform
    // Ask for getting list
    platformIds = (cl_platform_id *)alloca(
        sizeof(cl_platform_id) * numPlatforms);
    
    // rUN Platform ID 
    errNum = clGetPlatformIDs(numPlatforms, platformIds, NULL);
    if (errNum != CL_SUCCESS)
    {
        std::cerr << "Failed to find any OpenCL platforms"
                  << std::endl;
        return;
    }

    std::cout << "Number of platforms: \t"
              << numPlatforms
              << std::endl;
    // Show Platform lists information repeat.
    for (cl_uint i = 0; i < numPlatforms; i++) {
        // First, Show Related Platform information list.
        DisplayPlatformInfo(
            platformIds[i], CL_PLATFORM_PROFILE, "CL_PLATFORM_PROFILE");
        DisplayPlatformInfo(
            platformIds[i], CL_PLATFORM_VERSION, "CL_PLATFORM_VERSION");
        DisplayPlatformInfo(
            platformIds[i], CL_PLATFORM_VENDOR, "CL_PLATFORM_VENDOR");
        DisplayPlatformInfo(
            platformIds[i],
            CL_PLATFORM_EXTENSIONS,
            "CL_PLATFORM_EXTENSIONS");
        )
    }

//===========================================
// Ask & Output Platform Special Information

void DisplayPlatformInfo(
    cl_platform_id id,
    cl_platform_info name,
    std::string str)
{
    cl_int errNum;
    std::size_t paramValueSize;

    errNum = clGetPlatformInfo(
        id,
        name,
        0,
        NULL,
        &paramValueSize);
    if (errNum != CL_SUCCESS)
    {
        std::cerr << "Failed to find OpenCL platform"
                  << str << "." << std::endl;
        return;
    }

    char * info = (char *)alloca(sizeof(char) * paramValueSize);
    errNum = clGetPlatformInfo(
        id,
        name,
        paramValueSize,
        info,
        NULL);
    if (errNum != CL_SUCCESS)
    {
        std::cerr << "Failed to find OpenCL platform"
                  << str << "." << std::endl;
        return;
    }

    std::cout << "\t" << str << ":\t" << info << std::endl;
}




/*
cl_int clGetPlatformIDs (cl_uint num_entries,
                         cl_platform_id * platforms,
                         cl_uint * num_platforms)

ex)

cl_int errNum;
cl_uint numPlatforms;
cl_platform_id * platformIds;
cl_context context = NULL;

errNum = clGetPlatformIDs(0, NULL, 7numPlatforms);

platformIds = (cl_platform_id *)alloca(
    sizeof(cl_platform_id) * numPlatforms);

errNum = clGetPlatformIDs(numPlatforms, platformIds, NULL);



cl_int clGetPlatformInfo (cl_platform_id platform,
                          cl_platform_info param_name,
                          size_t param_value_size,
                          void * param_value,
                          size_t * param_value_size_ret)
ex)

cl_int err;
size_t size;

err = clGetPlatformInfo(id, CL_PLATFORM_NAME, 0, NULL, &size);
char * name = (char *)allloca(sizeof(char) * size);
err = clGetPlatformInfo(id, CL_PLATFORM_NAME, size, info, NULL);

err = clGetPlatformInfo(id, CL_PLATFORM_VENDOR, 0, NULL, &size);
char * vname = (char *)alloca(sizeof(char) * size);
err = clGetPlatformInfo(id, CL_PLATFORM_VENDOR, size, info, NULL);

std::cout << "Platform name: " << name << std::endl
          << "Vendor name  : " << vname << std::endl;

===============================
Platform name : ATI Stream
Vendor name   : Advanced Micro Devices, Inc. (AMD)

*/
