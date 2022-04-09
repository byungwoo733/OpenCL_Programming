/*
// OpenGL Sharing Extension Question
CL_DEVICE_EXTENSION char [] cl_khr_fp64
                            cl_khr_int64_base_atomics
                            cl_khr_int64_extended_atomics
                            cl_khr_fp16
                            cl_khr_gl_sharing
                            cl_khr_gl_event
                            cl_khr_d3d10_sharing
-----------------------------------------
size_t  extensionSize;
ciErrNum = clGetDeviceInfo(cdDevices[i], CL_DEVICE_EXTENSIONS, 0,
   NULL, &extensionSize );

char* extensions = (char*)malloc(extensionSize);
ciErrNum = clGetDeviceInfo(cdDevices[i], CL_DEVICE_EXTENSIONS,
   extensionSize, extensions, &extensionSize);

ex) 
#define GL_SHARINGEXTENSION "cl_khr_gl_sharing"
std::string stdDevString(extensions);
free(extensions);

size_t szOldPos = 0;
size_t szSpacePos = stdDevString.find(' ', szOldPos);
// Extension Char Array Empty
while (szSpacePos != stdDevString.npos)
{
    if( strcmp(GL_SHARING_EXTENSION, stdDevString.substr(szOldPos,
szSpacePos - szOldPos).c_str()) == 0)
    {
        // Device support OpenGL Sharing.
        uiDeviceUsed = i;
        bSharingSupported = true;
        break;
    }
    do {
        szOldPos = szSpacePos + 1;
        szSpacePos = stdDevString.find(' ', szOldPos);
    }
    while (szSpacePos == szOldPos);
}

===================================================
// Create OpenCL Buffer From OpenGL Buffer
cl_mem clCreateFromGLBuffer(cl_context cl_context,
                            cl_mem_flags cl_flags,
                            GLuint bufobj,
                            cl_int *errcode_ret)

//-----------------------------------------------

ex)

GLuint initVBO( int vbolen)
{
    GLint bsize;
    GLint vbo_buffer;
    glGenBuffers(1, &vbo_buffer);

    glBindBuffer(GL_ARRAY_BUFFER, vbo_buffer);

    // Create Buffer. Basically Size Setting & Allocation
    glBufferData (GL_ARRAY_BUFFER, vbolen *sizeof(float)*4,
        NULL, GL_STREAM_DRAW);

        // Creating Buffer Size Request Same 
        // Checking Again.
        glGetBufferParameteriv(GL_ARRAY_BUFFER,
           GL_BUFFER_SIZE, &bsize);
        if ((GLuint)bsize != (vbolen*sizeof(float)*4)) {
            printf(
            "Vertex Buffer object (%d) has incorrect size (%d). \n",
            (unsigned)vbo_buffer, (unsigned)bsize);
        }

        //Binding cancel about buffer because all Running Finish
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        return vbo_buffer;
}

// GLuint vbo initVBO(640, 480);
// This Handle "vbo" callback From clCreateFromGLBuffer():
// cl_vbo_mem = clCreateFromGLbuffer(context, CL_MEM_READ_WRITE, vbo,&err);
===============================
===============================
// Use Coomand-Queue
cl_int clEnqueueAcquireGLObjects(cl_command_queue command_queue,
                                 cl_uint num_objects,,
                                 const cl_mem 8 mem_objects,
                                 cl_uint num_events_in_wait_list,
                                 const cl_event *event_wait_list,
                                 cl_event *event)
------------------------------------
// OpenCL Object cancel
cl_int clEnqueueReleaseGLobjects(cl_command_queue command_queue,
                                 cl_uint num_objects,
                                 const cl_mem * mem_objects,
                                 cl_uint num_events_in_wait_list,
                                 const cl_event *event_wait_list,
                                 cl_event *event)

ex1) Start Static Position & End Static Position Save Array

__kernel void init_vbo_kernel(__global float4 *vbo,
  int w, int h, int seq)
  {
      int gid = get_global_id(0);
      float4 linepts;
      float f = 1.0f;
      float a = (float)h/4.0f;
      float b = w/2.0f;

      linepts.x = gid;
      linepts.y = b + a*sin(3.14*2.0*((float)gid/(float)w*f + 
         (float)seq/(float)w));
      linepts.z = gid+1.0f;
      linepts.w = b + a*sin(3.14*2.0*((float)(gid+1.0f)/(float)w*f +
          (float)seq/(float)w));

      void[gid] = linepts;
  }

ex2) Buffer Cancel For using OpenGL
glFinish();
errNum = clEnqueueAcquireGLObjects(commandQueue, 1, &cl_tex_mem,
   0, NULL, NULL );
errNum = clEnqueueNDRangeKernel(commandQueue, tex_kernel, 2, NULL,
    tex_globalWorkSize,
    tex_localWorkSize,
    0, NULL, NULL);
clFinish(commandQueue);
errNum = clEnqueueReleaseGLObjects(commandQueue, 1, &cl_tex_mem, 0,
  NULL, NULL );

==================================================
==================================================
// Create OpenCL Image From OpenGL Texture (Texture 2D)
cl_mem clCreateFromGLTexture2D(cl_context cl_context,
                               cl_mem_flags cl_flags,
                               GLenum texture_target,
                               GLint miplevel,
                               GLuint texture,
                               cl_int *errcode_ret)
----------------------------------------------------
// Create OpenCL Image From OpenGL Texture (Texture 3D)
cl_mem clCreateFromGLTexture3D(cl_context cl_context,
                               cl_mem_flags cl_flags,
                               GLenum texture_target,
                               GLint miplevel,
                               GLuint texture,
                               cl_int *errcode_ret)

//*p_cl_tex_mem = clCreateFromGLTexture2D(context,
                        CL_MEM_READ_WRITE, GL_TEXTURE_RECTANDGLE_ARB,
                        0, tex, &errNum );

//====================================================
// GL Render Buffer
cl_mem clCreateFromGLRenderbuffer(cl_context context,
                                  cl_mem_flags flags,
                                  GLuint renderbuffer,
                                  cl_int *errcode_ret)

// OpenGL Object Information Question
cl_int clGetGLObjectInfo(cl_mem memobj,
                         cl_gl_object_type *gl_object_type,
                         GLint *gl_object_name)

// Texture Object Similar Feature Function (clGetTextureObjectInfo())
cl_int clGetGLTextureInfo(cl_mem memobj,
                          cl_gl_texture_info param_name,
                          size_t param_value_size,
                          void *param_value,
                          size_t *param_value_size_ret)

//====================================================
// Synchro among OpenGL & OpenCL
cl_event clCreateEventFromGLsyncKHR(cl_context context,
                                    GLsync sync,
                                    cl_int *errcode_ret)

// OpenGL ARB Event Object Extension (GLsync)
GLsync glCreateSyncFromCLeventARB(cl_context context,
                                  cl_event event,
                                  bitfield flags)

// Remove OpenGL Sync Object (glDeleteSync())
void gldELETEsYNC(GLsync sync)
---------------------------
// OpenCL Kernel callback OenGL & Sync
cl_event release_event;

GLsync sync = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
gl_event = clCreateEventFromGLsyncKHR(context, sync, NULL );
errNum = clEnqueueAcquireGLObjects(commmandQueue, 1,
    &cl_tex_mem, 0, &gl_event, NULL );
errNum = clEnqueueNDRangeKernel(commandQueue, tex_kernel, 2, NULL,
    tex_globalWorkSize, tex_localWorkSize,
    0, NULL, 0);
errNum = clEnqueueReleaseGLObjects(commandQueue, 1,
    &cl_tex_mem, 0, NULL, &release_event);
GLsync cl_sync = glCreateSyncFromCLeventARB(context,
    release_event, 0);
glWaitSync( cl_sync, 0, GL_TIMEOUT_IGNORED );

*/

// Image Object
// Image Object Creation
cl_mem clCreateImage2D (cl_context context, cl_mem_flags flags,
    const cl_image_format *image_format, size_t image_width,
    size_t image_height, size_t image_rowpitch, void *host_ptr,
    cl_int *errcode_ret)

flags: (also for clCreatwImage3D, clGetSupportedImageFormats)
    CL_MEM_READ_WRITE, CL_MEM_{WRITE, READ}_ONLY,
    CL_MEM_{USE, ALLOC, COPY}_HOST_PTR

cl_mem clCreateImage3D (cl_context context, cl_mem_flags flags,
    const cl_image_format *image_format, size_t image_width,
    size_t image_height, size_t image_depth,
    size_t image_row_pitch, size_t image_slice_pitch,
    void *host_ptr, cl_int *errcode_ret)
flags: See clCreateImage2D

// Support Image Format Inquiry List
cl_int clGetSupportedImageFormats (cl_context context,
    cl_mem_flags flags, cl_mem_object_type image_type,
    cl_uint num_entries, cl_image_format *image_formats,
    cl_uint *num_image_formats)
flags: See clCreateImage2D

// Copy between Image, Buffer Object 
cl_int clEnqueueCopyImageToBuffer (cl_command_queue command_queue,
    cl_mem src_image, cl_mem dst_buffer, const size_t src_origin[3],
    const size_t region[3], size_t dst_offset,
    cl_uint num_events_in_wait_list, const cl_event *event_wait_list,
    cl_event *event)

cl_int clEnqueueCopyBufferToImage (cl_command_queue command_queue,
    const size_t dst_origin[3], const size_t region[3],
    size_t *image_row_pitch, size_t *image_slice_pitch,
    cl_uint num_events_in_wait_list, const cl_event *event_wait_list,
    cl_event *event, cl_int *errcode_ret)

// Image Object Read, Write, Copy
cl_int clEnqueueReadImage (cl_command_queue command_queue,
    cl_mem image, cl_bool blocking_read, const size_t orgin[3],
    const size_t region[3], size_t row_pitch, size_t slice_pitch,
    void *ptr, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueWriteImage (cl_command_queue command_queue,
    cl_mem image, cl_bool blocking_write, const size_t origin[3],
    const size_t region[3], size_t input_row_pitch,
    size_t input_slice_pitch, const void *ptr,
    cl_uint num_events_in_wait_list, const cl_event *event_wait_list,
    cl_event *event)

cl_int clEnqueueCopyImage (cl_command_queue command_queue,
    cl_mem src_image, cl_mem dst_image, const size_t src_origin[3],
    const size_t dst_origin[3], const size_t region[3],
    cl_uint num_events_inwait_list, const cl_event *event_wait_list,
    cl_event *event)

// Image Object Inquiry
cl_int clGetMemObjectInfo (cl_mem memobj, cl_mem_info param_name,
    size_t param_value_size, void *param_value,
    size_t *param_value_size_ret)

param_name: CL_MEM_{TYPE, FLAGS, SIZE, HOST_PTR},
    CL_MEM_{MAP, REFERENCE}_COUNT, CL_MEM_{CONTEXT, OFFSET},
    CL_MEM_ASSOCIATED_MEMOBJECT

cl_int ckGetImageInfo (cl_mem image, cl_image_info param_name,
    size_t param_value_size, void *param_value,
    size_t *param_value_size_ret)
param_name: CL_IMAGE_{FORMAT, ELEMENT_SIZE},
    CL_IMAGE_{ROW, SLICE}_PITCH, CL_IMAGE_{HEIGHT, WIDTH, DEPTH},
    CL_IMAGE_D3D10_SUBRESOURCE_KHR, CL_MEM_D3D10_RESOURCE_KHR

// Access Indicator
__read_only, read_only
__write_only, write_only

// Sampler Object
cl_sampler clCreateSampler (cl_context context,
    cl_bool normalized_coords, cl_addressing_mode addressing_mode,
    cl_filter_mode filter_mode, cl_int *errcode_ret)

    cl_int clRetainSampler (cl_sampler sampler)

    cl_int clReleaseSampler (cl_sampler sampler)

    cl_int clGetSamplerInfo (cl_sampler sampler,
        cl_sampler_info param_name, size_t *param_value_size,
        void *param_value, size_t *param_value_size_ret)
    param_name: CL_SAMPLER_REFERENCE_COUNT,
        CL_SAMPLER_{CONTEXT, FILTER_MODE},
        CL_SAMPLER_ADDRESSING_MODE, CL_SAMPLER_NORMALIZED_COORDS

// Sampler declaration Field
const sampler_t <sampler-name> =
                <normalized-mode> | <address-mode> | <filter-mode>

normalized-mode:
    CLK_NORMALIZED_COORDS_{TRUE, FALSE}
address-mode:
    CLK_ADDRESS_{REPEAT, CLAMP, NONE},
    CLK_ADDRESS_{CLAMP_TO_EDGE, MIRRORED_REPEAT}
filter-mode:
    CLK_FILTER_NEAREST, CLK_FILTER_LINEAR

// OpenCL/OpenGL Sharing API
clCreateFromGLBuffer, 
clCreateFromGLTexture2D, 
clCreateFromGLTexture3D, 
clCreateFromGLRenderbuffer

/* if creates OpenCL Memory Object From OpenGL using APIs, during to exist OpenCL Memory Object,
OpenGL Object Saving Space never remove */

// CL Buffer Object > GL Buffer Object
cl_mem clCreateFromGLBuffer (cl_context context, cl_mem_flags flags,
`GLuint bufobj, int *errcode_ret)
flags: CL_MEM_{READ, WRITE}_ONLY, CL_MEM_READ_WRITE

// CL Image Object > GL Texture
cl_mem clCreateFromGLTexture2D (cl_context context,
    cl_mem_flags flags, GLenum texture_target, GLint miplevel,
    GLuint texture, cl_int *errcode_ret)
flags: See clCreateFromGLBuffer
texture_target: GL_TEXTURE_{2D, RECTANGLE},
    GL_TEXTURE_CUBE_MAP_POSITIVE_{X, Y, Z},
    GL_TEXTURE_CUBE_MAP_NEGATIVE_{X, Y, Z}

cl_mem clCreateFromGLTexture3D (cl_context context,
    cl_mem_flags flags, GLenum texture_target, GLint miplevel,
    GLuint texture, cl_int *errcode_ret)
flags: See clCreateFromGLBuffer
texture_target: GL_TEXTURE_3D

// CL Image Object > GL Render Buffer
cl_mem clCreateFromGLRenderbuffer (cl_context context, 
    cl_mem_flags flags, GLuint renderbuffer, cl_int *errcode_ret)
flags: clCreateFromGLBuffer

// Inquiry Information
cl_int clGetGLObjectInfo (cl_mem memobj,
    cl_gl_object_type *gl_object_type, GLuint *gl_object_name)
*gl_object_type returns: CL_GL_OBJECT_BUFFER,
    CL_GL_OBJECT_{TEXTURE2D, TEXTURE3D}, CL_GL_OBJECT_RENDERBUFFER
    cl_int clGetGLTextureInfo (cl_mem memobj,
        cl_gl_texture_info param_name, size_t param_value_size,
        void *param_value, size_t *param_value_size_ret)
    param_name: CL_GL_TEXTURE_TARGET, CL_GL_MIPMAP_LEVEL

// Object Sharing
cl_int clEnqueueAcquireGLObjects (cl_command_queue command_queue,
    cl_uint num_objects, const cl_mem *mem_objects,
    cl_uint num_events_in_wait_lsi,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueReleaseGLObjects (cl_command_queue command_queue,
    cl_uint num_objects, const cl_mem *mem_objects,
    cl_uint num_events_in_wait_list, const cl_event *event_wait_list,
    cl_event *event)

// CL Event Object > GL Synchronization Object
cl_event clCreateEventFromGLsyncKHR (cl_context context,
    GLsync sync, cl_int *errcode_ret)

// CL Context > GL Context, Sharing Group
cl_int clGetGLContextInfoKHR (
    const cl_context_properties *properties,
    cl_gl_context_info param_name, size_t param_value_size,
    void *param_value, size_t *param_value_size_ret)
param_name: CL_DEVICES_FOR_GL_CONTEXT_KHR,
    CL_CURRENT_DEVICE_FOR_GL_CONTEXT_KHR

// OpenCL/Direct3D 10 Sharing API
clCreateFromGLBuffer, 
clCreateFromGLTextyre2D, 
clCreateFromGLTexture3D, 
clCreateFromGLRenderBuffer


cl_int clGetDeviceIDsFromD3D10KHR (cl_platform_id platform,
    cl_d3d10_device_source_khr d3d_device_source, void *d3d_object,
    cl_d3d10_device_set_khr d3d_device_set, cl_uint num_entries,
    cl_device_id *devices, cl_uint *num_devices)
d3d_device_source: CL_D3D10Device, IDXGIAdapter
d3d_object: ID3D10Device, IDXGIAdapter
d3d_device_set: CL_ALL_DEVICES_FOR_D3D10_KHR,
    CL_PREFERRED_DEVICES_FOR_D3D10_KHR

cl_mem clCreateFromD3D10BufferKHR (cl_context context,
    cl_mem_flags flags, ID3D10Buffer *resource, cl_int *errcode_ret)
flags: CL_MEM_{READ, WRITE}_ONLY, CL_MEM_READ_WRITE

cl_mem clCreateFromD3D10Texture2DKHR (cl_context context,
    cl_mem_flags flags, ID3D10Texture2D *resource, UINT subresource, cl_int *errcode_ret)
flags: See clCreateFromD3D10BufferKHR

cl_mem clCreateFromD3D10Texture3DKHR (cl_context context,
    cl_mem_flags flags, ID3D10Texture3D *resource, UINT subresource, cl_int *errcode_ret)
flags: See clCreateFromD3D10BufferKHR

cl_int clEnqueueAcquireD3D10ObjectsKHR (
    cl_ command_queue command_queue, cl_uint num_objects,
    const cl_mem *mem_objects, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)

cl_int clEnqueueReleaseD3D10ObjectsKHR (
    cl_ command_queue command_queue, cl_uint num_objects,
    const cl_mem *mem_objects, cl_uint num_events_in_wait_list,
    const cl_event *event_wait_list, cl_event *event)