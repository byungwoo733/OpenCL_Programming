// Running Kernel
// Set the kernel parameters (result, a, b).
errNum = clSetKernelArg(kernel, 0, sizeof(cl_mem), &memObjects[0]);
errNum = clSetKernelArg(kernel, 1, sizeof(cl_mem), &memObjects[1]);
errNum = clSetKernelArg(kernel, 2, sizeof(cl_mem), &memObjects[2]);
if (errNum != CL_SUCCESS)
{
    cerr << "Error setting kernel arguments." << endl;
    Cleanup(context, commandQueue, program, kernel, memObjects);
    return 1;
}

size_t globalWorkSize[1] = { ARRAY_SIZE };
size_t localWorkSize[1] = { 1 };

// Queue the kernel for execution.
errNum = clEnqueueNDRangeKernel(commandQueue, kernel, 1, NULL, 
                                globalWorkSize, localWorkSize,
                                0, NULL, NULL);
if (errNum != CL_SUCCESS)
{
    cerr << "Error queing kernel for execution." <<endl;
    Cleanup(context, commandQueue, program, kernel, memObjects);
    return 1;
}

// Read the output buffer back to the host.
errNum = clEnqueueReadBuffer(commandQueue, memObjects[2],
                                CL_TRUE,0,
                                ARRAY_SIZE * sizeof(float), result,
                                0, NULL, NULL);
if (errNum != CL_SUCCESS)
{
    cerr << "Error reading result buffer." <<endl;
    Cleanup(context, commandQueue, program, kernel, memObjects);
    return 1;
}

// Print the result buffer.
for (int i = 0; i < ARRAY_SIZE; i++)
{
    cout << result[i] << " ";

    }