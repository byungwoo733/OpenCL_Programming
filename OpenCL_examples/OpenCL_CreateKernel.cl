// Create OpenCL Kernel 
kernel = clCreateKernel(program, "hello_kernel", NULL);
if (kernel == NULL)
{
    cerr << "Failed to create kernel" << endl;
    Cleanup(context, commandQueue, program, kernel, memObjects);
    return 1;
}

// Creates a memory object to be used as an argument to the kernel.
// First, it will be used to store the kernel parameters.
// Create a host memory array.
float result[ARRAY_SIZE];
float a[ARRAY_SIZE];
float b[ARRAY_SIZE];
for (int i = 0; i < ARRAY_SIZE; i++)
{
    a[i] = (float)i;
    b[i] = (float)(i * 2);
}

if (!CreateMemObjects(context, memObjects, a, b))
{
    Cleanup(context, recommandQueue, program, kernel, memObjects);
    return 1;
}
