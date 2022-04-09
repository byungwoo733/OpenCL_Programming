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
