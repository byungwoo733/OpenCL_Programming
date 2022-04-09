// Image Histogram
// RGB Histogram Sequence Realiztion
// This Function caculates Histogram about R, G, B.
//
// image_data is per channel 8-Bit RGBA Image.
// w is Image Width to Pixel Unit.
// h is Image High to Pixel Unit.
//
// histogram is 256 Pixels Array about R, G, B 
// Each Pixel Entry Unsigned int 32-Bit Value
//

unsigned int*
histogram_rgba_unorm8(void *image_data, int w, int h)
{
    unsigned char *img = (unsigned char *)image_data;
    unsigned int *ref_histogram_results;
    unsigned int *ptr;
    int i;

    // Histogram Buffer Buffer 0 Initialization
    //
    // Histogram Buffer saves Histogram Value about R
    // Save about B after saving Histogram Value about G
    // beacuse there's 256 pixels about 8-BIt Color Channel
    // Histogram Buffer has 256 * 3 Entry
    // Each Entry unsigned integer 32-Bit Value.
    //
    ref_histogram_results = (unsigned int *)malloc(256 * 3 *
                                        sizeof(unsigned int));
    ptr = ref_histogram_results;
    memset(ref_histogram_results, 0x0, 256 * 3 *
                                       sizeof(unsigned int));
    
    // Calculate Histogram about R
    for (i=0; i<w*h*4; i+=4)
    {
        int indx = img[i];
        ptr[index]++;
    }

    ptr += 256;
    // Calculate Histogram about G.
    for (i=0; i<w*h*4; i+=4)
    {
        int indx = img[i];
        ptr[index]++;
    }

    ptr += 256;
    // Calculate Histogram about B.
    for (i=0; i<w*h*4; i+=4)
    {
        int indx = img[i];
        ptr[index]++;
    }

    return ref_histogram_results;
}

// Image Histogram Parallel
// RGB Histogram Parallel Version. Part Histogram Calcuates.
//***************************************************************
// This Kernel receives 8-Bit Inout Image per RGBA Channel
// Create Part Histogram about R, G, B
// Each Working Group One  Image Tile Expression.
// Calculate The tile about Histogram
//
// partial_histogram is Array what has num_groups * (256 * 3) Entery.
// Each Entry is Unsigned Integer 32-Bit Value.
//
// Saves 256 R-pixels.
// Saves 256 G-pixel & 256 B-pixels.
//***************************************************************

kernel void
histogram_partial_image_rgba_unorm8(image2d_t img,
                                    global uint *histogram)
{
int    local_size = (int)get_local_size(0) *
                    (int)get_local_size(1);
int    image_width = get_image_height(img);
int    image_height = get_image_height(img);
int    group_indx = (get_group_id(1) * get_num_groups(0)
                                    + get_local_id(0));
int    j =  256 * 3;
int    index = 0;


// Part Histogram Buffer inCreation Area
// 0 Initialization
do
{
    if (tid < j)
        tmp_histogram[idex_tid] = 0;
    
    j -= local_size;
    indx += local_size;
} while (j > 0);

barrier(CLK_LOCAL_MEM_FENCE);

if ((x < image_width) && (y < image_height))
{
    float4 clr = read_imagef(img,
                     CLK_NORMALIZED_COORDS_FALSE |
                     CLK_ADDRESS_CLAMP_TO_EDGE |
                     CLK_FILTER_NEAREST,
                     (float2)(x, y));

    uchar indx_x, indx_y, indx_z;
    indx_x = convert_uchar_sat(clr.x * 255.0f);
    indx_y = convert_uchar_sat(clr.y * 255.0f);
    indx_z = convert_uchar_sat(clr.z * 255.0f);
    atomic_inc(&tmp_histogram[indx_x]);
    atomic_inc(&tmp_histogram[256+(uint)indx_y]);
    atomic_inc(&tmp_histogram[256+(uint)indx_y]);
}

barrier(CLK_LOCAL_MEM_FENCE);

// in Histogram to group_indx
// Part Histogram Copy to Position 
if (local_size >= (256 * 3))
{
    if (tid < (256 * 3))
        histogram[group_indx + tid] = tmp_histogram[tid];
}
else
{
    j = 256 * 3;
    indx = 0;
    do
    {
        if (tid < j)
            histogram[group_indx + indx + tid] =
                                    tmp_histogram[indx + tid];
        
        j -= local_size;
        indx += local_size;
    } while (j > 0);

}

}

//====================================
// Parallel Version RGB Histogram. Add Part Histogram.
//*****************************************************
// This Kernel is Part Histogram Results
// Add Final One Histogram Result.
//
// num_groups calcultes used Part Histogram 
// Working Group is number.
// 
// partial_histogram is Array what has num_groups * (256 * 3) Entry.
// We save 256 R-pixels.
// saves 256 G-pixels & 256 B-pixels
//
// Finally Add Result reutrns to Histogram
//***************************************************
kernel void
histogram_sum_partial_results_unorm8(
                        global uint *partial_histogram,
                        int_num_groups,
                        global uint *histogram)

{
    int tid = (int)get_global_id(0);
    int group_indx;
    int n = num_groups;
    local uint tmp_histogram[256 * 3];

    tmp_histogram[tid] = partial_histogram[tid];

    group_indx = 256*3;
    while (--n > 0)
    {
        tmp_histogram[tid] += partial_histogram[group_indx + tid];
        group_indx += 256*3;
    }

    histogram[tid] = tmp_histogram[tid];
}

//=====================================================
// Host Code For CL API Callback For putting Histogram Kernel in Queue
int        image_width = 1920;
int        image_height = 1080;
size_t     global_work_size[2];
size_t     local_work_size[2];
size_t     partial_global_work_size[2];
size_t     partial_local_work_size[2];
size_t     workgroup_size;
size_t     num_groups;
cl_kernel  histogram_rgba_unorm8;
cl_kernel  histogram_sum_partial_results_unorm8;
size_t     gsize[2];

// Kernel Creation
histogram_rgba_unorm8 = clCreateKernel(program,
                                        "histogranm_image_rgba_unorm8",
                                        &err);
histogram_sum_partial_results_unorm8 = clcREATEkERNEL(PROGRAM,
                                        "HISTOGRAM_SUM_PARTIAL_RESULTS_UNORM8",
                                        &err);

// histogram_image_rgba_unorm8 Kernel Enable Use
// Best Working Group Size
clGetKernelWorkGroupInfo(histogram_rgba_unorm8, device,
                         CL_KERNEL_WORK_GROUP_SIZE,
                         sizeof(size_t), &worgroup_size, NULL);

if (workgroup_size <= 256)
{
    gsize[0] = 16;
    gsize[1] = workgroup_size / 16;
}
else if (workgroup_size <= 1024)
{
    gsize[0] = workgroup_size / 16;
    gsize[1] = 16;
}
else
{
    gsize[0] = workgroup_size / 32;
    gsize[1] = 32;
}

local_work_size[0] = gsize[0];
local_work_size[1] = gsize[1];

global_work_size[0] = ((image_width + gsize[0] - 1 ) / gsize[0]);
global_work_size[0] = ((image_height + gsize[1] - 1 ) / gsize[1]);

num_groups = global_work_size[0] * global_work_size[1];
global_work_size[0] *= gsize[0];
global_work_size[1] *= gsize[1];

err = clEnqueueNDRangeKernel(queue,
                             histogram_rgba_unorm8,
                             2, NULL, global_work_size, local_work_size,
                             0, NULL, NULL);

// enable use in Histogram_sum_partial_results_unorm8 Kernel
// Best Working Group Size
clGetKernelWorkGroupInfo(histogram_sum_partial_results_unorm8,
                         device, CL_KERNEL_WORK_GROUP_SIZE,
                         sizeof(size_t), &workgroup_size, NULL);

if (workgroup_size < 256)
{
    printf("A mon. of 256 work-itemss in work-group is needed for 
            histogram_sum_partial_results_unorm8 kernel. (%d)\n",
            (int)workgroup_size);
    return EXIT_FAILURE;
}

partial_global_work_size[0] = 256*3;
partial_local_work_size[0] = 
        (workgroup_size > 256) ? 256 : workgroup_size;
err = clEnqueueNDRangeKernel(queue,
            histogram_sum_partial_results_unorm8,
            1, NULL, partial_global_work_size,
            partial_local_work_size, 0, NULL, NULL);
if (err)
{
    printf("clEnqueueNDRangeKernel() failed for
    histogram_sum_partial_results_unorm8 kernel.
    (%d)\n", err);
    return EXIT_FAILURE;
}

// Parallel Version RGB Histogram. Optimization Version
//
// This Kernel receives 8-Bit Input Image per RGBA Channel
// Part Histogram Creates about R, G, B
// calculate Histogram about the tile
//
// When Working Item calculates Histogram, num_pixels_per_workitem
// Caculate Pixel Numbers List chapter 14.3 wrtitten 
// num_pixels_per_workitem = 1
//
// partial_histogram has num_groups * (256 * 3) Entry.
// Each Entry is unsigned integer 32-Bit Value.
// num_group receives influence value of num_pixels_per_workitem
//
// Saves 256 R-pixels, After saving 256 G-pixel.
// Saves 256 B-pixels.
//

kernel void
histogram_partial_rgba_unorm8(image2d_t img,
                              int num_pixels_per_workitem,
                              glbal uint *partial_histogram)
{
    int local_size = (int)get_local_size(0) *
                     (int)get_local_size(1);
    int image_width = get_image_width(img);
    int image_height - get_image_height(img);
    int group_indx = (get_group_id(1) * get_num_groups(0) +
                                        get_group_id(0)) * 256 * 3;

    int x = get_global_id(0);
    int x = get_global_id(1);

    local uint tmp_histogram[256 * 3];

    int tid = get_local_id(1) * get_local_size(0) + get_local_id(0);
    int j = 256 * 3;
    int indx = 0;

    // Part Histogram Creation lLocal Buffer 0 Initailization.
    do 
    {
        if(tid < j)
            tmp_histogram[indx+tid] = 0;

        j -= local_size;
        indx += local_size;
    } while (j > 0);

    barrier(CLK_LOCAL_MEM_FENCE);

    int i, idx;
    for (i=0, idx=x; i<num_pixels_per_workitem;
                             i++, idx+=get_global_size(0))
    
    {
        if ((idx < image_width) && (y < image_height))
        {
            float4 clr = read_imagef(img,
                                     (CLK_NORMALIZED_COORDS_FALSE |
                                     CLK_ADDRESS_CLAMP_TO_EDGE |
                                     CLK_FILTER_NEAREST),
                                     (float2)(idx, y));
            
            uchar indx_x = convert_uchar_sat(clr.x * 255.0f);
            uchar indx_y = convert_uchar_sat(clr.y * 255.0f);
            uchar indx_z = convert_uchar_sat(clr.z * 255.0f);
            atmoic_inc(&tmp_histogram[indx_x]);
            atomic_inc(&tmp_histogram[256+(uint)indx_y]);
            atomic_inc(&tmp_histogram[512+(uint)indx_z]);
        }
    }

    barrier(CLK_LOCAL_MEM_FENXE);

    // group_index Histogram Local
    // Part Histogram Copy
    if (local_size >= (256 * 3))
    {
        if (tid < (256 * 3))
            partial_histogram[group_indx _tid] =
                                        tmp_histogram[tid];
    }
    else
    {
        j =256 * 3;
        indx = 0;
        do
        {
            if (tid < j)
                partial_histogram[group_indx + indx + tid] =
                                    tmp_histogram[indx +tid];
            j -= local_size;
            indx += local_size;
        } while (j > 0);
    }
}

/* histogram_sum_partial_results_unorm8 Kernel is same with List 14.3 */

//======================================================
// Calculates Histogram to Half-Float or Float Value about Each Channel
// Parallel Version RGB Histogram, half-float & float channel uses.
//******************************************************
// This Kernel receives 32-Bit or 16-Bit floating point input image per RGBA Channel Input
// Each Work Group One Image Tile Expression.
// calculate Histogram about the tile
//
// partial_histogram has num_groups * (257 * 3) Entry
// Each Entry unsigned integer 32-Bit Value
//
// Saves 257 R-pixels, after saving 257 G-pixels
// Saves 257 B-pixels
//
//*******************************************************

kernel void
histogram_image_rgba_fp(image2d_t img,
                        int num_pixels_per_workitem,
                        global uint *histogram)
{
    int local_size = (int)get_local_size(0) *
                     (int)get_local_size(1);
    int image_width = get_image_width(img);
    int image_height = get_image_height(img);
    int group_indx = (get_group_id(1) * get_num_groups(0)
                             + get_group_id(0)) * 257 *3;
    
    int x = get_global_id(0);
    int y = get_global_id(1);

    local uint tmp_histogram[257 * 3];

    int tid = get_local_id(1) * get_local_size(0)
                              + get_local_id(0);
    int j = 257 * 3;
    int indx = 0;

    // Part Histogram Creation Local Buffer
    // 0 Initializtion
    do
    {
        if (tid < j)
            tmp_histogram[indx_tid] = 0;
        
        j -= local_size;
        indx += local_size;
    } while (j > 0);

    barrier(CLK_LOCAL_MEM_FENCE);

    int i, idx;
    for (i=0, idx=x; i<num_pixels_per_workitem;
                     i++, idx+=get_global_size(0))
    {
        if ((idx < image_width) && (y < image_height))
        {
            float4 clr = read_imagef(img,
                              CLK_NORMALIZED_COORDS_FALSE |
                              CLK_ADDRESS_CLAMP_TO_EDGE |
                              CLK_FILTER_NEAREST,
                              (float2)(idx, y));
            
            ushort indx;
            indx = convert_ushort_sat(min(clr.x, 1.0f) * 256.0f);
            atomic_inc(&tmp_histogram[indx]);

            indx = convert_ushort_sat(min(clr.y, 1.0f) * 256.0f);
            atomic_inc(&tmp_histogram[257+indx]);

            indx = convert_ushort_sat(min(clr.z, 1.0f) * 256.0f);
            atomic_inc(&tmp_histogram[514+indx]);
        }
    }

    barrier(CLK_LOCAL_MEM_FENCE);

    // group_index Histogram Local
    // Part Histogram Copy
    if (local_size >= (257 * 3))
    {
        if (tid < (257 * 3))
            histogram[group_indx + tid] = tmp_histogram[tid];   
        }
        else
        {
            j = 257 * 3;
            indx = 0;
            do
            {
                if (tid < j)
                    histogram[group_indx + indx + tid] =
                                        tmp_histogram[indx + tid];
                    
                    j -= local_size;
                    indx += local_size;
                } while (j > 0);
            }
        } 
    }

//*************************************************************
// This Kernel Part Histogram Add
// Final One Histogram Result
// 
// num_groups for calculating Part Histogram 
// used Working Group Number
//
// partial_histogram has num_groups * (257 * 3) Entry
//
// Saves 257 R-pixels, after saving 257 G-pixels
// Saves 257 B-pixels
//
// Finally Add Result returns to Histogram
//*************************************************************

kernel void
histogram_sum_partial_results_fp(global uint *partial_histogram,
                                 int num_groups,
                                 global uint *histogram)
{
    int     tid = (int)get_global_id(0);
    int     group_id = (int)get_group_id(0);
    int     group_indx;
    int     n = num_groups;
    uint    tmp_histogram, tmp_histogram_first;

    int first_workitem_not_in_first_group =
                ((get_local_id(0) == 0) && group_id);
    
    tid += group_id;
    int    tid_first = tid - 1;
    if (first_workitem_not_in_first_group)
        tmp_histogram_first = partial_histogram[tid_first];
        tmp_histogram = partial_histogram[tid];
    
    group_indx = 257*3;
    while (--n > 0)
    {
        if (first_workitem_not_in_first_group)
            tmp_histogram_first += partial_histogram[tid_first];
        
        tmp_histogram +=partial_histogram[group_indx+tid];
        group_indx += 257*3;
    }

        if (first_workitem_not_in_first_group)
            histogram[tid_first] = tmp_histogram_first;

        histogram[tid] = tmp_histogram;
}

/* Histogram Whole Source Code (Kernel & Host Code) Chapter_14/histogram Directory provides */