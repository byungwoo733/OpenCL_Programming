// OpenCL Device ID using inquiry For Direct3D Compatibility ( clGetDeviceIDsFromD3D10khr() )
cl_int clGetDeviceIDsFromD3D10KHR (cl_platform_id platform,
                                    cl_d3d10_device_source_khr
                                    d3d_device_source,
                                    void *d3d_object,
                                    cl_d3d10_device_set_khr d3d_device_set,
                                    cl_uint num_entries,
                                    cl_device_id *devices,
                                    cl_uint *num_devices)

//==============================================
/*
ex) errNum = clGetDeviceIDsFromD3D10KHR(
    cpPlatform,
    CL_D3D10_DEVICE_KHR,
    g_pD3DDeivce,
    CL_PREFERRED_DEVICES_FOR_D3D10_KHR,
    1,
    &cdDevice,
    &num_devices);

    if (errNum == CL_INVALID_PLATFORM) {
        printf("Invalid Platform: ",
               "Specified platform is not valid\n");
        ) else if( errNum == CL_INVALID_VALUE) {
            PRINTF("Invalid Value: ",
                   "d3d_device_source, d3d_device_set is not valid ",
                   "or num_entries = 0 and devices != NULL ",
                   "or num_devices == devices == NULL\n");
        } else if( errNum == CL_DEVICE_NOT_FOUND) {
            printf("No OpenCL devices corresponding to the",
                   "d3d_object were found\n");
        )

// Context Creation For D3D Sharing
cl_context_properties contextProperties[] =
{
    CL_CONTEXT_D3D10_DEVICE_KHR,
    (cl_context_properties)g_pD3DDevice,
    CL_CONTEXT_PLATFORM,
    (cl_context_properties)*pFirstPlatformId,
    0
};
context = clCreateContextFromType(contextProperties,
    CL_DEVICE_TYPE_GPU,
    NULL, NULL, &errNum);
*/

==================================
// OpenCL Memory Creation From Direct3D Buffer * Texture ( clCreateFromD3D10BufferKHR() )
cl_mem clCreateFromD3D10BufferKHR(cl_context context
                                  cl_mem_flags flags,
                                  ID3D10Buffer *resource,
                                  cl_int *errcode_ret )
//=================================

// Create Texture in D3D10
int g_WindowWidth = 256;
int g_WindowHeight = 256;
...
ZeroMemory( &desc, sizeof(D3D10_TEXTURE2D_DESC) );
desc.Width = g_WindowWidth;
desc.Height = g_WindowHeight;
desc.MipLevels = 1;
desc.ArraySize = 1;
desc.Format = DXGI_FORMATR8G8B8A8_UNORM;
descSampleDesc.Count = 1;
desc.Usage = D3D10_USAGE_DEFAULT;
desc.BindFlags = D3D10_BIND_SHADER_RESOURCE;
if (FAILED(g_pD3DDevice->CreateTexture2D(
    &desc, NULL, &g_pTexture2D)))
    return E_FAIL;

//===================================
// OpenCL Image Object Creation From Texture
cl_mem clCreateFromD3D10Texture2DKHR(cl_context context
                                     cl_mem_flags flags,
                                     ID3D10Texture2D *resource,
                                     uint subresource,
                                     cl_int *errcode_ret )

//----------------------------
/*
ex)

g_clTexture2D = clCreateFromD3D10tEXTURE2dkhr(
    Context,
    CL_MEM_READ_WRITE,
    g_pTexure2D,
    0,
    &errNum);

*/

======================================
//OpenCL 3D Image Creation
cl_mem clCreateFromD3D10Texture3DKHR(cl_context context
                                     cl_mem_flags flags,
                                     ID3D10Texture *resource,
                                     uint subresource,
                                     cl_int *errcode_ret )

=====================================
// Get & Cancellation Direct3D Object in OpenCL ( clEnqueueAcquireD3D10ObjectsKHR() )
cl_int clEnqueueAcquireD3D10ObjectsKHR(
                                cl_command_queue command_queue,
                                cl_uint num_objects,
                                const cl_mem *mem_objects,
                                cl_uint num_events_in_wait_list,
                                const cl_event *event_wait_list,
                                cl_event *event)

===================================
// Synchronization before event complete
cl_int clEnqueueReleaseD3D10ObjectsKHR
                        cl_command_queue command_queue,
                        cl_uint num_objects,
                        const cl_mem *mem_objects,
                        cl_uint num_events_in_wait_list,
                        const cl_event *event_wait_list,
                        cl_event *event)

//=====================================
//=====================================
// Direct3D Render in OpenCL

void Render()
{
    // Back Buffer Red, Green, Blue, Alpha
    // Initialization
    float ClearColor[4] = { 0.0f, 0.125f, 0.1f, 1.0f };
    g_pD3DDevice->ClearRenderTargetView(
        g_pRenderTargetView, ClearColor);
    
    computeTexture();
    // Square Render
    D3D10_TECHNIQUE_DESC techDesc;
    g_pTechnique->GetDesc ( &techDesc );
    for( UINT p = 0; p < techDesc.Passes; ++p )
    {
        g_pTechnique->GetPassByIndex( p )->Apply( 0 );
        g_pD3DDevice->Draw( 4, 0 );
    }

    // Rendering Information in Back Buffer
    // Front Buffer (Screen) Output
    g_pSwapChain->Present( 0, 0 );
}
//-------------------------------
// Whole Code
// Texture Background Color Unit using OpenCL
cl_int computeTexture()
{
    cl_int errNum;

    static cl_int seq =0;
    seq = (seq+1)%(g_WindowWidth*2);

    errNum = clSetKernelArg(tex_kernel, 0, sizeof(cl_mem),
       &g_clTexture2D);
    errNum = clSetKernelArg(tex_kernel, 1, sizeof(cl_int),
       &g_WindowWidth);
    errNum = clSetKernelArg(tex_kernel, 2, sizeof(cl_int),
       &g_WindowHeight);
    errNum = clSetKernelArg(tex_kernel, 3, sizeof(cl_int),
       &seq);
    size_t tex_globalWorkSize[2] ={ 32, 4 };
    errNum = clEnqueueAcquireD3D10ObjectsKHR(commandQueue, 1,
        &g_clTexture2D, 0, NULL, NULL );
    
    ERRnUM = clEnqueueNDRangeKernel(commandQueue, tex_kernel, 2,
        NULL,
        tex_globalWorkSize, tex_localWorkSize,
        0, NULL, NULL);
    if(errNum != CL_SUCCESS)
    {
        std::cerr << "Error queuing kernel for excution." <<
        std::endl;
    }
    errNum = clEnqueueReleaseD3D10ObjectsKHR(commandQueue, 1,
       &g_clTexture2D, 0, NULL, NULL );
    clFinish(commandQueue);
    return 0;
} 
//-----------------------------------
// Full D3D Texture Object Content Unit in OpenCL Kernel
__kernel void init_texture_kernel(__write_only image2d_t im,
    int w, int h, int seq )
{
    int2 coord = { get_global_id(0), get_global_id(1) };
    float4 color = {
        (float)coord.x/(float)w,
        (float)coord.y/(float)h,
        (float)abs(seq-w)/(float)w,
        1.0f);
    write_imagef( im, coord, color );
}
//-----------------------------------
// 
//Vertex Shader
//
PS_INPUT VS( VS_INPUT input)
{
    PS_INPUT output = (PS_INPUT)0;
    output.Pos = input.Pos;
    output.Tex = input.Tex;

    return output;
}
technique10 Render
{
    pass P0
    {
        SetVertexhader( CompilShader( vs_4_0, VS() ) );
        SetGeometryShader( NULL );
        SetPixelShader( CompilShader( ps_4_0, PS() ) );
    }
}
//----------------------------------
//Change Texture Running & Output in OpenCL Kernel
SamplerState samLinear
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

float4 PS( PS_INPUT input) : SV_Target
{
    return txDiffuse.Sample( samLinear, input.Tex );
}

//==============================================
//==============================================
// D3D Vertex Shader in OpenCL
struct SimpleSineVertex
{
    D3DXVECTOR4 Pos;
};

//-----------------------------
// Create D3D10 Buffer here from This Structure
bd.Usage = D3D10_USAGE_DEFAULT;
bd.ByteWidth = sizeof ( SimpleSineVertex ) * 256;
bd.BindFlags = D3D10_BIND_VERTEX_BUFFER;
bd.CPUAccessFlags = 0;
bd.MiscFlags = 0;
hr = g_pD3DDevice->CreateBuffer( &bd, NULL,
&G_PSineVertexBuffer );
//------------------------------
// if create D3D Buffer "g_pSineVertexBuffer", Create OpenCL Buffer(g_clBuffer) from g_pSineVertexBuffer By clCreateFromD3D10BufferKHR() function:
g_clBuffer = clCreateFromD3D10BufferKHR( CONTEXT, 
    CL_MEM_READ_WRITE, g_pSineVertexBuffer, &errNum );

//------------------------------
// Create Sine Vertex in Kernel:
__kernel void init_vbo_kernel(__global float4 *vbo,
    int w, int h, int seq)
{
    int gid = get_global_id(0);
    float4 linepts;
    float f = 1.0f;
    float a = 0.4f;
    float b = 0.0f;

    linepts.x = gid/(w/2.0f)-1.0f;
    linepts.y = b + a*sin(3.14*2.0*((float)gid/(float)w*f +
        (float)seq/(float)w));
    linepts.z = 0.5f;
    linepts.w = 0.0f;

    vbo[gid] = linepts;
}

//--------------------------------
// Redering Pipline Active & Draw 256 Data Points
// Input Arrangement Setting
g_pD3DDevice->IASetInputLayout ( g_pSineVertexLayout );
// Vertex Buffer Setting
srtide = sizeof( SimpleSineVertex );
offset = 0;
g_pD3Device->IASetVertexBuffers( 0, 1, &g_pSineVertexBuffer,
    &stride, &offset );
// Basic Topology Setting
g_pD3DDevice->IASetPrimitiveTopology(
    D3D10_PRIMITIVE_TOPOLOGY_LINESTRIP );
computeBuffer();
g_pTechnique->GetPassByIndex( 1 )->Apply( 0 );
g_pD3DDevice->Draw( 256, 0);